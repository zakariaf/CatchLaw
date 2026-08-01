# E01/T03 — CI: format, analyze and test across every workspace member

| | |
|---|---|
| **Epic** | E01 — Foundation, workspace and the offline gates |
| **Branch** | `epic/01-foundation` (shared) |
| **Commit** | `ci(workspace): run format, analyze and every member's suite on each pull request` |
| **Depends on** | T01 (the members), T02 (the config `flutter analyze` reads) |
| **Size** | M |
| **Spec** | `SPEC.md` §15 step 1 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `ci-pipeline-and-gates` | Owns the workflow. Rules 1, 2, 4, 6 and 10 are the shape of this job: one gate per named contract, a pinned runner **and** toolchain, `--set-exit-if-changed` and `--fatal-infos` as hard gates, randomised test ordering, and never `continue-on-error` on a gate |
| `codegen-and-toolchain` | `references/toolchain-and-workspace.md`: the CI action's requested version must equal the pinned one, and `build_runner` runs once at the workspace root, never inside one member |
| `dependency-hygiene` | Rule 4 — CI reads the recorded SDK string, which is why the job uses `flutter-version-file: .fvmrc` rather than a literal |
| `project-structure-and-packages` | The member list and the rule that each package carries its own `test/` run with `dart test` for pure packages and `flutter_test` for Flutter ones |
| `catchlaw-conventions-index` | Rule 9 — route before you edit. This job is where every later gate is hung, so its job names are a contract other tasks cite |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `.github/workflows/validate.yml` | whole | The two existing jobs, `skills` and `invariants`. This task **extends** the file; neither job is removed or renamed |
| `.claude/skills/ci-pipeline-and-gates/references/workflow-skeleton.md` | the `verify` job | Step order, `ubuntu-24.04`, `subosito/flutter-action@v2`, `libsqlite3-dev` before a real-DB suite, and the `# VERIFY:` convention for an unconfirmed action major |
| `.claude/skills/ci-pipeline-and-gates/references/policy-grep-gate.md` | "The three-criteria bar", "Accumulate all offenders; fail once" | The bar this task's policy test has to clear, and the reason it collects every offender |
| `.claude/skills/codegen-and-toolchain/references/toolchain-and-workspace.md` | "Scoping codegen in a workspace" | Why one `dart pub get` at the root, and what a second lockfile means |
| `FLUTTER_GUIDE.md` | Part 2.4 | One `dart pub get` at the root, one `pubspec.lock`, one `.dart_tool` |
| `FLUTTER_GUIDE.md` | Part 6.4 | The test budget: the engine carries the weight at 100% branch coverage, the app aims at ~80% excluding generated code |
| `CONVENTIONS.md` | §6 | Where tests live, and that `testing/` holds fakes that are never shipped and never collected as tests |
| `epics/DECISIONS.md` | D-5 | Flutter 3.44.6 — the value `.fvmrc` carries and the action requests |

## What this delivers

- `.github/workflows/validate.yml` gains one job, `flutter`, named **`format · analyze · test`**. The
  existing `skills` and `invariants` jobs are untouched.
- `.github/workflows/validate.yml` gains a `concurrency` block so a force-push does not leave two runs
  racing on the same ref.
- `app/test/policy/ci_workflow_test.dart` — the policy test over the workflow file.
- `tools/gates/ci_members.txt` — two lines, `suite=<member>` and `no-suite=<member>`, that both the
  workflow and the policy test read, so "which members run a suite" is stated once.

The job, in step order:

```yaml
  flutter:
    name: format · analyze · test
    runs-on: ubuntu-24.04            # pinned, not -latest: image drift moves the toolchain
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@v4                 # VERIFY: confirm the current major
      - uses: subosito/flutter-action@v2          # v2 is current; there is no v3
        with:
          channel: stable
          flutter-version-file: .fvmrc            # D-5 — one recorded version, local == CI
          cache: true
          pub-cache: true
      - run: flutter --version
      - run: dart pub get                         # ONCE, at the workspace root
      - name: Exactly one lockfile, at the root
        run: |
          n=$(find . -name pubspec.lock -not -path './.dart_tool/*' | wc -l | tr -d ' ')
          [ "$n" = 1 ] || { echo "::error::$n pubspec.lock files — a pub get ran inside a member"; exit 1; }
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --fatal-infos
      - run: sudo apt-get update -qq && sudo apt-get install -y -qq libsqlite3-dev
      - name: rule_engine suite
        run: cd packages/rule_engine && dart test --test-randomize-ordering-seed random --reporter expanded
      - name: content_builder suite
        run: cd tools/content_builder && dart test --test-randomize-ordering-seed random --reporter expanded
      - name: app suite
        run: cd app && flutter test --test-randomize-ordering-seed random --reporter expanded
```

## Why it is built this way

**It extends `validate.yml` rather than replacing it.** The `skills` job is the only thing checking that
sixteen `SKILL.md` frontmatters parse, that every bundled-file citation resolves and that every
`check_*.sh` survives `bash -n`. T09 edits four skill files and depends on all three of those steps still
running. A new `ci.yml` beside it would leave two workflows that both claim to be the gate, and the first
person to add a check would pick the wrong one.

**One `dart pub get`, at the root, and a step that counts the lockfiles.** The workspace's whole value is
single-context resolution: one lock, one `.dart_tool/`, the CLI and the app provably on the same
`rule_engine`. `toolchain-and-workspace.md`'s failure table lists "two lockfiles appear" as a real symptom
with a real cause — a `pub get` run inside a package directory. The count step turns a symptom somebody
notices weeks later into a failed job.

**`flutter-version-file: .fvmrc`, not a literal version.** `dependency-hygiene` rule 4 and
`toolchain-and-workspace.md`: the action's requested version must equal the pinned one, and the only way to
guarantee that is for them to be the same string in one file. A literal in the YAML is a second copy that
drifts on the next upgrade and reproduces "works on my machine" as a formatter that emits different bytes.

**`--fatal-infos` on analyze.** `ci-pipeline-and-gates` rule 4 states the mechanism: an info left unfixed is
a warning that gets ignored next. `CONVENTIONS.md` §8 requires `flutter analyze` clean; this is what clean
means.

**`--test-randomize-ordering-seed random`.** Free detection of inter-test state leakage, which matters most
from E05 onward when suites share one in-memory drift database. Adding it now means E05 does not have to
discover a pre-existing ordering dependency and a new one in the same PR.

**`libsqlite3-dev` before the suites, in this task and not in E05.** On Linux `flutter test` runs in a plain
Dart VM where `sqlite3_flutter_libs` does nothing, so a real-DB suite fails for a reason that looks like a
broken repository. Installing it now costs about four seconds and removes a whole class of confusing E05
failure. The step names that reason.

**Rejected: a matrix over the four members.** A matrix buys parallelism and costs a shared `dart pub get`;
each leg would resolve the workspace again. Four short steps in one job is faster in wall-clock and keeps
one log to read.

**Rejected: coverage as a gate.** `ci-pipeline-and-gates` rule 8: coverage is a published report, never a
threshold. `FLUTTER_GUIDE.md` §6.4 sets the budget (100% branch on the engine, ~80% on the app) as a
target for the author, not a number for a machine. Coverage collection is deliberately not wired here
either — the upward-lie fix (generating an import-everything file so untested files land in the
denominator) only means something once there is a body of untested code, which is E03 at the earliest.

**Rejected: a codegen freshness gate.** There is no generated code until E05, and a `build_runner` step
that generates nothing is a step that will be assumed to be working when it is not. It lands with drift.

**`packages/analysis_defaults` runs no suite, and that is written down.** It holds a YAML file and a README.
A member with no suite and a member whose CI line was deleted in a merge look identical in a workflow file.
`tools/gates/ci_members.txt` states the split, the workflow's steps are generated from the `suite=` lines
by hand, and test 6 asserts that the member set equals the union — so adding E04's next package without a
CI line fails here rather than three epics later.

## Tests first

Write `app/test/policy/ci_workflow_test.dart` before editing the workflow. Run it. **All ten must fail** —
the `flutter` job does not exist and `tools/gates/ci_members.txt` does not exist. A test that passes now is
matching something in the two pre-existing jobs and is asking the wrong question.

This test clears `policy-grep-gate.md`'s three-criteria bar: the invariant is textually decidable (it is a
YAML file), silent when broken (a deleted step leaves a green job), and one line to break (a merge
resolution).

| # | Test name | Asserts | Why this case exists |
|---|---|---|---|
| 1 | `validate.yml keeps the skills and invariants jobs` | both job keys present | T09 depends on all three `skills` steps still running. Replacing the file instead of extending it is the plausible mistake |
| 2 | `validate.yml pins every runner to an exact Ubuntu image` | no `ubuntu-latest` anywhere | Image drift moves lcov and toolchain versions under the workflow with no diff to review (`ci-pipeline-and-gates` rule 2) |
| 3 | `validate.yml resolves the Flutter toolchain from .fvmrc` | `flutter-version-file: .fvmrc`, no literal `flutter-version:` | Two copies of the version string drift on the next upgrade; the drift shows up as a formatter emitting different bytes in CI than on the laptop |
| 4 | `validate.yml runs dart format with --set-exit-if-changed` | the exact flag | `dart format` is the sole whitespace authority; a gate that formats in place asserts nothing (rule 9) |
| 5 | `validate.yml runs flutter analyze with --fatal-infos` | the exact flag | Without it the analyzer's advisory findings accumulate until nobody reads the log |
| 6 | `validate.yml runs a suite for every workspace member not listed as no-suite` | members == suite ∪ no-suite | The headline: a member added in a later epic with no CI line is invisible, and `packages/analysis_defaults` must be a stated decision rather than an omission |
| 7 | `validate.yml randomises test ordering in every suite step` | `--test-randomize-ordering-seed random` on each | Inter-test state leakage is silent until the day CI reorders on its own; from E05 the suites share a database |
| 8 | `validate.yml sets continue-on-error on no step` | no occurrence | Rule 10: a red gate blocks. `continue-on-error` on a gate is the same as deleting it, with a green tick on top |
| 9 | `validate.yml runs dart pub get exactly once` | one occurrence, before the format step | A per-member `pub get` creates a second lockfile and the two disagree within a week (`toolchain-and-workspace.md`) |
| 10 | `validate.yml installs libsqlite3-dev before the first suite step` | step order | `flutter test` on Linux uses a plain Dart VM; without the host library an E05 database suite fails in a way that reads as a broken repository |

```dart
// app/test/policy/ci_workflow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'repo_root.dart';

String workflowText() => repoFile('.github/workflows/validate.yml').readAsStringSync();

YamlMap workflow() => loadYaml(workflowText()) as YamlMap;

YamlMap jobs() => workflow()['jobs'] as YamlMap;

List<String> stepRuns(String job) => [
      for (final step in (jobs()[job] as YamlMap)['steps'] as YamlList)
        if ((step as YamlMap)['run'] != null) (step['run'] as String),
    ];

/// `suite=<member>` and `no-suite=<member>` lines. Stated once, read by the
/// workflow author and by this test, so the split is a decision and not an omission.
Map<String, List<String>> ciMembers() {
  final out = <String, List<String>>{'suite': [], 'no-suite': []};
  for (final line in repoFile('tools/gates/ci_members.txt').readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final parts = trimmed.split('=');
    out[parts.first]!.add(parts.last);
  }
  return out;
}

void main() {
  test('validate.yml keeps the skills and invariants jobs', () {
    expect(jobs().keys, containsAll(<String>['skills', 'invariants', 'flutter']));
  });

  test('validate.yml pins every runner to an exact Ubuntu image', () {
    expect(workflowText(), isNot(contains('ubuntu-latest')),
        reason: 'image drift moves the toolchain under the workflow with no diff to review');
  });

  test('validate.yml resolves the Flutter toolchain from .fvmrc', () {
    expect(workflowText(), contains('flutter-version-file: .fvmrc'));
    expect(RegExp(r'flutter-version:\s*[\x27"]?\d').hasMatch(workflowText()), isFalse,
        reason: 'a literal version is a second copy of the pin and drifts on the next upgrade');
  });

  test('validate.yml runs dart format with --set-exit-if-changed', () {
    expect(stepRuns('flutter').join('\n'), contains('--set-exit-if-changed'));
  });

  test('validate.yml runs flutter analyze with --fatal-infos', () {
    expect(stepRuns('flutter').join('\n'), contains('flutter analyze --fatal-infos'));
  });

  test('validate.yml runs a suite for every workspace member not listed as no-suite', () {
    final root = loadYaml(repoFile('pubspec.yaml').readAsStringSync()) as YamlMap;
    final members = (root['workspace'] as YamlList).cast<String>().toSet();
    final declared = ciMembers();
    expect({...declared['suite']!, ...declared['no-suite']!}, members,
        reason: 'a member with no suite and a member whose CI line was deleted look '
            'identical in a workflow file');
    final runs = stepRuns('flutter').join('\n');
    final missing = declared['suite']!.where((m) => !runs.contains('cd $m &&')).toList();
    expect(missing, isEmpty, reason: 'no CI step runs:\n${missing.join('\n')}');
  });

  test('validate.yml randomises test ordering in every suite step', () {
    final suiteSteps =
        stepRuns('flutter').where((r) => r.contains(' test ')).toList();
    final missing =
        suiteSteps.where((r) => !r.contains('--test-randomize-ordering-seed random')).toList();
    expect(missing, isEmpty, reason: 'unrandomised suite step:\n${missing.join('\n')}');
  });

  test('validate.yml sets continue-on-error on no step', () {
    expect(workflowText(), isNot(contains('continue-on-error')),
        reason: 'continue-on-error on a gate is a deleted gate with a green tick on top');
  });

  test('validate.yml runs dart pub get exactly once', () {
    final gets = stepRuns('flutter').where((r) => r.trim() == 'dart pub get').length;
    expect(gets, 1, reason: 'a per-member pub get creates a second lockfile');
  });

  test('validate.yml installs libsqlite3-dev before the first suite step', () {
    final runs = stepRuns('flutter');
    final sqlite = runs.indexWhere((r) => r.contains('libsqlite3-dev'));
    final firstSuite = runs.indexWhere((r) => r.contains(' test '));
    expect(sqlite, greaterThanOrEqualTo(0));
    expect(sqlite, lessThan(firstSuite),
        reason: 'flutter test on Linux runs in a plain Dart VM; without the host library '
            'an E05 database suite fails in a way that reads as a broken repository');
  });
}
```

**Run:** `cd app && flutter test test/policy/ci_workflow_test.dart` → 10 failures. Tests 1, 3–7, 9 and 10
fail because the `flutter` job does not exist; test 6 also throws on the missing
`tools/gates/ci_members.txt`. Tests 2 and 8 will fail only if the current file contains the forbidden
string — it does not, so **they will pass early**. That means those two are asserting nothing yet: before
writing the job, plant `ubuntu-latest` and a `continue-on-error: true` in a scratch copy of the file,
confirm both go red, and revert. A test that has never been red is a test that has never been run.

## Implementation outline

1. Create `tools/gates/ci_members.txt` with four lines: three `suite=` and
   `no-suite=packages/analysis_defaults`, each with a trailing comment giving the reason.
2. Add the `concurrency` block to `validate.yml` (`group: validate-${{ github.ref }}`,
   `cancel-in-progress: true`).
3. Add the `flutter` job in the step order given above. Mark `actions/checkout@v4` with `# VERIFY:` —
   `ci-pipeline-and-gates` rule 3 forbids guessing an action major, and `subosito/flutter-action@v2` is
   confirmed current with no v3.
4. Push and read the first run. Two things are being learned, not assumed:
   - whether `flutter analyze --fatal-infos` at a workspace root whose root package is not a Flutter
     package covers all four members in one context (the epic's Risk 1). Confirm by planting a deliberate
     `unused_import` in `packages/rule_engine/lib/rule_engine.dart`, watching the job go red, and reverting.
     If it does not cover them, split into one analyze step per member and say so in the workflow comment.
   - whether `subosito/flutter-action@v2` can fetch 3.44.6 on `ubuntu-24.04` (Risk 10). If it cannot,
     `.fvmrc` and D-5 are revisited together, not `.fvmrc` alone.
5. Re-run the ten tests plus the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 10 tests pass. Tests 1, 3–7, 9 and 10 failed first; tests 2 and 8 were proved red against a
      planted violation and the planted violation was reverted.
- [ ] The `skills` and `invariants` jobs are byte-identical to their state before this commit.
- [ ] The `flutter` job is green on the PR, and a deliberately unformatted file, a deliberate
      `unused_import` and a deliberately failing test were each confirmed to turn it red before this task
      was closed.
- [ ] The analyze-coverage question in Risk 1 is answered in the commit body with what was observed, not
      with what was expected.
- [ ] `tools/gates/ci_members.txt` accounts for all four workspace members.
- [ ] No step carries `continue-on-error`, and no gate writes to the repository — no `--update-goldens`,
      no `dart format` without `--output=none`, no committed regeneration (`ci-pipeline-and-gates` rule 9).

## Gates

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
cd app && flutter test && cd ..
cd packages/rule_engine && dart test && cd ../..
bash -n .github/workflows/validate.yml 2>/dev/null || true   # YAML, not shell — parse it instead:
python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/validate.yml')); print('validate.yml parses')"
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
ci(workspace): run format, analyze and every member's suite on each pull request

SPEC.md §15 step 1 wants every static check running from commit one. This adds
the job the rest of E01 hangs its gates on: one pinned runner, the toolchain
resolved from .fvmrc so the version CI requests is the version D-5 records,
one dart pub get at the workspace root, and a step that fails if a second
pubspec.lock ever appears.

validate.yml is extended, not replaced. Its skills job is the only thing
checking that sixteen SKILL.md frontmatters parse and that every bundled-file
citation resolves, and E01/T09 depends on all of it still running.

packages/analysis_defaults runs no suite because it holds a YAML file and a
README. That is recorded in tools/gates/ci_members.txt and asserted by a test,
because a member with no suite and a member whose CI line was lost in a merge
look identical in a workflow file.

libsqlite3-dev is installed now rather than in E05: on Linux flutter test runs
in a plain Dart VM where sqlite3_flutter_libs does nothing, and the failure it
prevents reads as a broken repository rather than a missing library.

Task: E01/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
