# E01/T08 — Wire the sixteen skill gates into CI, and prove they scanned something

| | |
|---|---|
| **Epic** | E01 — Foundation, workspace and the offline gates |
| **Branch** | `epic/01-foundation` (shared) |
| **Commit** | `ci(check): run all sixteen skill gates and fail when one scans an empty tree` |
| **Depends on** | T02 (`app/analysis_options.yaml`), T03 (the workflow), T05 (`tools/gates/` and the fixture pattern), T06 (`app/android/app/src` for check 3) |
| **Size** | L |
| **Spec** | `SPEC.md` §15 step 1, §14 static block |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `ci-pipeline-and-gates` | Rules 1, 7 and 10, and `references/policy-grep-gate.md`'s accumulate-and-fail-once discipline. This task is sixteen gates wired to one contract each, plus one meta-gate about whether they ran |
| `catchlaw-conventions-index` | Rule 9 (route before you edit) and its own `scripts/check_app_invariants.sh`, whose check 9 fans out to every sibling gate — the behaviour this task has to account for rather than mistake for coverage |
| `catchlaw-offline-guarantee` | `check_no_network.sh` is one of the sixteen, and its layer-1 and layer-2 checks only fire when the target's neighbours (`pubspec.yaml`, `analysis_options.yaml`, `android/app/src`) exist |
| `project-structure-and-packages` | Which directory is the real target for the engine gate and the content-pipeline gate — D-1's tree, not the skills' root-relative assumption |
| `dependency-hygiene` | Nothing new is added to any pubspec here, and the runner is dependency-free bash for that reason |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `CONVENTIONS.md` | §7 "Gate scripts" | The rule this task implements, in its own words: *A gate that scans a path with no files reports success. That is the failure mode that makes a gate worse than no gate, so E01/T08 asserts each gate is scanning a non-empty tree before trusting it* |
| `epics/DECISIONS.md` | D-1, "Consequence for the gate scripts" | Every script takes an optional `TARGET_DIR` and exits 2 when it does not exist; CI must never let one default to `lib/` |
| `epics/DECISIONS.md` | D-2 | The `lonja-*` gates exempt token constructs by the path fragment `/theme/`, which only resolves under `app/lib` |
| `epics/DECISIONS.md` | D-4 | `tools/content_builder/` is the content-pipeline gate's real target |
| `.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh` | checks 2, 7 and 9 | `ROOT` is `dirname(TARGET)`; the `rule_engine` layer check prints a **skip** when no engine is found under that root; check 9 delegates to every sibling with the same target |
| `.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh` | checks 1, 2, 3 | `ROOT` is `TARGET/..`, so `app/lib` gives it `app/pubspec.yaml`, `app/analysis_options.yaml` and `app/android/app/src` |
| `.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh` | usage header | "pass `.` to cover `content/`, `tools/` and `packages/` as well" — why its row targets the package rather than its `lib/` |
| `.claude/skills/catchlaw-offline-guarantee/examples/no_network_test.dart` | `setUpAll` | The same assertion, already made by the guard test: *lib/ scanned but empty — the guard would pass vacuously*. Prior art for the rule this task generalises |
| `.claude/skills/ci-pipeline-and-gates/references/policy-grep-gate.md` | "Accumulate all offenders; fail once" | Why the runner runs all sixteen rows before failing |

## What this delivers

- `tools/gates/skill_gates.tsv` — the routing table. Sixteen rows, four tab-separated columns:
  `script` · `target` · `glob` · `min_files`. Every row carries a trailing `# ` comment naming the decision
  that fixes its target (D-1, D-2 or D-4).
- `tools/gates/run_skill_gates.sh` — reads the table, and for each row: asserts the target exists, counts
  the files matching the glob, refuses to run the gate when the count is below `min_files`, runs it,
  records the exit code and the count. Prints one summary table. Fails once, at the end.
- A `skill-gates` step in the `flutter` job of `.github/workflows/validate.yml`.
- `app/test/policy/skill_gates_test.dart`.

The table at E01 (target column, in full):

| Script | Target | Fixed by |
|---|---|---|
| `catchlaw-conventions-index/check_app_invariants.sh` | `app/lib` | D-1 |
| `catchlaw-offline-guarantee/check_no_network.sh` | `app/lib` | D-1 |
| `catchlaw-verdict-contract/check_verdict_contract.sh` | `app/lib` | D-1 |
| `catchlaw-reference-database/check_reference_db.sh` | `app/lib` | D-1 |
| `catchlaw-measurement-ruler/check_measurement.sh` | `app/lib` | D-1 |
| the nine `lonja-*/check_lonja_*.sh` | `app/lib` | D-1, D-2 |
| `catchlaw-rule-engine/check_rule_engine.sh` | `packages/rule_engine/lib` | D-1 |
| `catchlaw-content-pipeline/check_content_pipeline.sh` | `tools/content_builder` | D-4 |

## Why it is built this way

**The failure this task exists for, in one sentence.** Every `check_*.sh` exits 2 when its target directory
is *missing* — that part is already right, and D-1 records it. But a directory that **exists and holds
nothing** takes a different path: each check is a `grep -r … "$TARGET" … || true`, an empty hit set is not
a violation, and the script prints `check_x: OK (app/lib)` and exits 0. A green tick that means "I found
nothing" and a green tick that means "I looked at nothing" are the same pixel. `CONVENTIONS.md` §7 names
this the failure mode that makes a gate worse than no gate, and it is worse precisely because it is
*reassuring*: the job goes green, the PR merges, and the evidence a reviewer relied on was never produced.

**So the runner counts before it runs.** Each row declares the glob the gate actually reads — `*.dart` for
most, `*.dart` plus `*.arb` for `check_verdict_contract.sh`, `*.dart` plus `*.yaml` for
`check_content_pipeline.sh` — and the runner refuses to invoke a gate whose target holds fewer than
`min_files` matching files. The count is printed for every row, passing or failing, because the number is
the evidence. `check_x: OK` with no number is a claim; `check_x: OK — 47 files scanned` is a check.

**`min_files` is 1 today, and the column exists so a later epic can raise it.** The contract E01 signs is
*n ≥ 1*: at this point `app/lib` holds `main.dart`, `packages/rule_engine/lib` holds `rule_engine.dart`,
and `tools/content_builder` holds a pubspec and a `bin/build.dart`. A floor tied to today's count would
churn on every commit and be relaxed the first time it fired for a good reason. The column is the hook, not
a number to be tuned now.

**`check_app_invariants.sh` fans out, and the runner must not read that as coverage.** Its check 9
delegates to every sibling `check_*.sh` with the *same* target, so `check_app_invariants.sh app/lib` runs
fifteen more scripts over `app/lib`. That is useful — it is how the index skill enforces its role — but
`check_rule_engine.sh app/lib` is a scan of the app, not of the engine, and it passes trivially. The two
non-app rows (`packages/rule_engine/lib` and `tools/content_builder`) are the runs that see their real
subject, and the table exists so that fact is written down rather than reconstructed.

**A second, quieter version of the same problem is inside `check_app_invariants.sh` itself.** It derives
`ROOT` as `dirname(TARGET)`, so with `app/lib` it searches only under `app/` and prints
`· no rule_engine package found under … — layer check skipped`. That skip is a vacuous pass wearing a
bullet point. The runner therefore also greps each gate's stdout for `skipped` and prints those lines in
the summary as **notes**, not failures — a failure there would be wrong, because some skips are correct at
E01 (there are no ARB files until E06) — and the summary makes them visible so that "which checks did not
actually run?" is answerable from the job log rather than from reading four hundred lines of bash.

**Rejected: running only `check_app_invariants.sh` and relying on its delegation.** It is the tempting
shape — one command, sixteen gates — and it fails in two ways at once. Every delegated gate gets `app/lib`,
so the engine and content-pipeline gates never see their subject; and a gate that fails inside the
delegation loop is reported by the loop, not by a named CI step, so the job log says
"check_app_invariants: FAIL" and the reviewer goes looking.

**Rejected: sixteen separate workflow steps.** Sixteen `- run:` lines is the most obvious wiring and it
breaks `policy-grep-gate.md`'s accumulate-and-fail-once rule: the job stops at the first red gate, hides
the other fifteen results, and teaches the author to fix one gate per push. It also puts the target
directories in YAML, where D-1's decisions are invisible, instead of in a table with the decision cited on
each row.

**Rejected: making the runner tolerate a missing script.** A `check_*.sh` that disappears from
`.claude/skills/` is either a skill being removed — which is a decision — or a bad merge. Either way the
runner fails, and test 1 catches the opposite case: a seventeenth skill added with no row in the table.

**Why bash and not Dart.** The gates are bash and the runner is their harness; a Dart runner would need the
suite to build in order to report that the suite's own invariants hold. `policy-grep-gate.md` notes the
tradeoff explicitly — the shell form runs even when the Dart suite is broken — and that is the case this
runner is for. The Dart test in this task drives the runner; it does not replace it.

## Tests first

Write `app/test/policy/skill_gates_test.dart` before writing the table or the runner. Run it. **All twelve
must fail** — `tools/gates/skill_gates.tsv` and `tools/gates/run_skill_gates.sh` do not exist.

| # | Test name | Asserts | Why this case exists |
|---|---|---|---|
| 1 | `Gate table names every check script shipped under .claude/skills` | table ⊇ scripts on disk | A seventeenth skill added in a later epic with no row is a gate nobody runs, and nothing else would notice |
| 2 | `Gate table names no script that does not exist` | table ⊆ scripts on disk | The other direction: a renamed or removed script leaves a row that fails for the wrong reason and gets deleted along with the check |
| 3 | `Gate table names sixteen scripts` | count | `CONVENTIONS.md` §7 and the epic DoD both publish the number. A silent drop from sixteen to fifteen is invisible in a diff of a TSV |
| 4 | `Gate runner fails when a target directory holds no file matching the gate's glob` | empty temp dir → exit 1, message names the row | The headline. A gate over an empty tree reports success, and a reassuring green is worse than no gate at all |
| 5 | `Gate runner fails when a target directory does not exist` | exit 1, and the script's own exit 2 is surfaced | D-1's consequence. The runner must report *which* row and *which* path, not just that something exited 2 |
| 6 | `Gate runner prints the file count it scanned for every row` | one count per row in stdout | The number is the evidence. "OK" with no number is the claim being made rather than the check being run |
| 7 | `Gate runner runs every row after one fails` | 16 rows in the summary when row 1 fails | Accumulate and fail once. Stopping at the first red hides fifteen results and produces one fix per push |
| 8 | `Gate runner exits non-zero when any gate exits non-zero` | exit 1 | The obvious one, and the one a refactor of the accumulator breaks first |
| 9 | `Gate table routes check_rule_engine.sh at packages/rule_engine/lib` | target column | Pointed at `app/lib` the engine gate passes over the wrong tree — and it would pass, which is the point (D-1) |
| 10 | `Gate table routes check_content_pipeline.sh at tools/content_builder` | target column | D-4, and the script's own header says to pass a directory that covers `tools/` |
| 11 | `Gate table routes every lonja gate at app/lib` | target column | D-2: the `lonja-*` gates exempt token constructs by the path fragment `/theme/`, which only resolves under `app/lib` |
| 12 | `Every target directory named in the gate table exists` | filesystem | A typo'd path exits 2 in CI five minutes into a run; this makes it a one-second local failure |

```dart
// app/test/policy/skill_gates_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'repo_root.dart';

typedef GateRow = ({String script, String target, String glob, int minFiles});

List<GateRow> gateTable() => repoFile('tools/gates/skill_gates.tsv')
    .readAsLinesSync()
    .map((l) => l.split('#').first.trim())
    .where((l) => l.isNotEmpty)
    .map((l) {
      final c = l.split('\t').map((s) => s.trim()).toList();
      return (script: c[0], target: c[1], glob: c[2], minFiles: int.parse(c[3]));
    })
    .toList();

List<String> scriptsOnDisk() => repoDir('.claude/skills')
    .listSync(recursive: true)
    .whereType<File>()
    .map((f) => f.path.replaceFirst('${repoRoot().path}/', ''))
    .where((p) => RegExp(r'\.claude/skills/[^/]+/scripts/check_[a-z_]+\.sh$').hasMatch(p))
    .toList()
  ..sort();

ProcessResult runRunner({String? table}) => Process.runSync(
      'bash',
      <String>[
        repoFile('tools/gates/run_skill_gates.sh').path,
        table ?? repoFile('tools/gates/skill_gates.tsv').path,
      ],
      workingDirectory: repoRoot().path,
    );

/// A copy of the real table with one row's target swapped for [target].
String tableWithFirstRowTargeting(String target) {
  final rows = gateTable();
  final lines = <String>[
    '${rows.first.script}\t$target\t${rows.first.glob}\t${rows.first.minFiles}',
    for (final r in rows.skip(1)) '${r.script}\t${r.target}\t${r.glob}\t${r.minFiles}',
  ];
  final f = File('${Directory.systemTemp.createTempSync('catchlaw_gate').path}/table.tsv')
    ..writeAsStringSync(lines.join('\n'));
  return f.path;
}

void main() {
  test('Gate table names every check script shipped under .claude/skills', () {
    final missing =
        scriptsOnDisk().where((s) => !gateTable().any((r) => r.script == s)).toList();
    expect(missing, isEmpty,
        reason: 'a gate with no row is a gate nobody runs:\n${missing.join('\n')}');
  });

  test('Gate table names no script that does not exist', () {
    final ghosts = gateTable()
        .map((r) => r.script)
        .where((s) => !repoFile(s).existsSync())
        .toList();
    expect(ghosts, isEmpty, reason: 'renamed or removed:\n${ghosts.join('\n')}');
  });

  test('Gate table names sixteen scripts', () {
    expect(gateTable(), hasLength(16));
  });

  test('Gate runner fails when a target directory holds no file matching the gate\'s glob', () {
    final empty = Directory.systemTemp.createTempSync('catchlaw_empty_gate_target');
    addTearDown(() => empty.deleteSync(recursive: true));
    final r = runRunner(table: tableWithFirstRowTargeting(empty.path));
    expect(r.exitCode, 1);
    expect(r.stdout, contains('scanned 0 files'),
        reason: 'a gate over an empty tree reports success — CONVENTIONS.md §7');
  });

  test('Gate runner fails when a target directory does not exist', () {
    final r = runRunner(table: tableWithFirstRowTargeting('no/such/dir'));
    expect(r.exitCode, 1);
    expect(r.stdout, contains('no/such/dir'),
        reason: 'the runner must name the row and the path, not just relay an exit 2');
  });

  test('Gate runner prints the file count it scanned for every row', () {
    final r = runRunner();
    final counted = RegExp('scanned [0-9]+ files').allMatches('${r.stdout}').length;
    expect(counted, gateTable().length,
        reason: 'the number is the evidence; "OK" with no number is the claim, not the check');
  });

  test('Gate runner runs every row after one fails', () {
    final r = runRunner(table: tableWithFirstRowTargeting('no/such/dir'));
    final counted = RegExp('scanned [0-9]+ files').allMatches('${r.stdout}').length;
    expect(counted, gateTable().length - 1,
        reason: 'stopping at the first red hides fifteen results and produces one fix per push');
  });

  test('Gate runner exits non-zero when any gate exits non-zero', () {
    expect(runRunner(table: tableWithFirstRowTargeting('no/such/dir')).exitCode, isNot(0));
  });

  test('Gate table routes check_rule_engine.sh at packages/rule_engine/lib', () {
    final row = gateTable().firstWhere((r) => r.script.endsWith('check_rule_engine.sh'));
    expect(row.target, 'packages/rule_engine/lib',
        reason: 'pointed at app/lib the engine gate passes over the wrong tree (D-1)');
  });

  test('Gate table routes check_content_pipeline.sh at tools/content_builder', () {
    final row = gateTable().firstWhere((r) => r.script.endsWith('check_content_pipeline.sh'));
    expect(row.target, 'tools/content_builder', reason: 'D-4');
  });

  test('Gate table routes every lonja gate at app/lib', () {
    final wrong = gateTable()
        .where((r) => r.script.contains('/lonja-') && r.target != 'app/lib')
        .map((r) => r.script)
        .toList();
    expect(wrong, isEmpty,
        reason: 'the lonja gates exempt tokens by the path fragment /theme/, which only '
            'resolves under app/lib (D-2):\n${wrong.join('\n')}');
  });

  test('Every target directory named in the gate table exists', () {
    final missing =
        gateTable().map((r) => r.target).where((t) => !repoDir(t).existsSync()).toList();
    expect(missing, isEmpty, reason: 'a typo\'d path exits 2 five minutes into a CI run:\n'
        '${missing.join('\n')}');
  });
}
```

**Run:** `cd app && flutter test test/policy/skill_gates_test.dart` → 12 failures, all
`FileSystemException` on the missing table and runner.

## Implementation outline

1. Write `tools/gates/skill_gates.tsv`. Generate the script column from
   `ls .claude/skills/*/scripts/check_*.sh` so nothing is typed; fill the target column by hand, one row at
   a time, each with the deciding reference in a trailing comment. Sixteen rows.
2. Write `tools/gates/run_skill_gates.sh`:
   - `TABLE="${1:-tools/gates/skill_gates.tsv}"`; exit 2 if it is missing.
   - For each row: strip the comment, split on tabs.
   - If the target is not a directory → record `MISSING`, print the row and the path, continue.
   - `count=$(find "$target" -type f \( -name '<glob1>' -o -name '<glob2>' \) | wc -l)`. Print
     `<script> <target> — scanned $count files` for **every** row, before the verdict.
   - If `count < min_files` → record `EMPTY SCAN`, print
     `would have passed over an empty tree — see CONVENTIONS.md §7`, continue **without running the gate**.
   - Otherwise run `bash "$script" "$target"`, capture stdout and the exit code, and record the result.
     Echo any line of that output containing `skipped` into a `notes` block.
   - After all sixteen: print the summary table, then the notes block, then fail once if any row is
     `MISSING`, `EMPTY SCAN` or non-zero.
   - The header comment states the consequence, for the stranger at 2am: *a gate that scans nothing prints
     the same green as a gate that found nothing, and this repository's offline claim is read off those
     greens.*
3. Add the workflow step, after the banned-API step:
   ```yaml
   - name: Skill gates (all sixteen, with a non-empty scan asserted)
     run: bash tools/gates/run_skill_gates.sh tools/gates/skill_gates.tsv
   ```
4. Run it locally and read the whole output, not the exit code. Expect skips at E01 and confirm each is
   correct: no `*.arb` files until E06, no `/theme/` directory until E07, no engine layer check under
   `app/` (see "Why it is built this way"). Any skip that is **not** explained by a later epic is a bug in
   the table, not a note.
5. Prove the meta-gate once against the live tree: `mkdir -p /tmp/empty && bash
   tools/gates/run_skill_gates.sh` with a temporary table pointing row 1 at `/tmp/empty`, confirm the row
   reports `scanned 0 files` and the run fails, and confirm the other fifteen rows still ran.
6. Re-run the twelve tests plus the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 tests pass, and each failed first.
- [ ] Sixteen rows, sixteen scripts on disk, no row without a script and no script without a row.
- [ ] The runner prints a scanned-file count for **every** row, including rows it refuses to run.
- [ ] Every skip printed by a gate at E01 is accounted for in the commit body, naming the epic that makes
      it stop skipping. An unexplained skip is a defect in the table.
- [ ] The two non-`app/lib` rows are present and were confirmed to actually see their subject:
      `check_rule_engine.sh packages/rule_engine/lib` reports a non-zero file count, and so does
      `check_content_pipeline.sh tools/content_builder`.
- [ ] Pointing any row at an empty directory turns the job red with a message naming that row, and pointing
      it at a missing directory does the same with a different message. Both proved by hand.
- [ ] The runner runs all sixteen rows even when the first fails, and the summary shows sixteen lines.
- [ ] No `check_*.sh` under `.claude/skills/` was edited by this task. Editing a skill is E01/T09's licence,
      not this one's.

## Gates

```bash
bash tools/gates/run_skill_gates.sh tools/gates/skill_gates.tsv
bash -n tools/gates/run_skill_gates.sh
cd app && flutter test && cd ..
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
bash tools/gates/no_banned_apis.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
ci(check): run all sixteen skill gates and fail when one scans an empty tree

Every check_*.sh exits 2 when its target directory is missing, which D-1
already relies on. A directory that EXISTS and holds nothing takes a different
path: each check is a grep -r ... || true, an empty hit set is not a violation,
and the script prints "OK" and exits 0. A green tick meaning "I found nothing"
and a green tick meaning "I looked at nothing" are the same pixel, and this
repository's offline claim is read off those greens.

So the runner counts before it runs. Each row declares the glob its gate reads,
the runner refuses to invoke a gate whose target holds no matching file, and it
prints the count for every row whether it passes or not. "check_x: OK" is a
claim; "check_x: OK — 47 files scanned" is a check.

Two rows do not point at app/lib. check_rule_engine.sh takes
packages/rule_engine/lib and check_content_pipeline.sh takes
tools/content_builder (D-1, D-4), because check_app_invariants.sh's check 9
delegates every sibling gate the SAME target — so the fan-out runs the engine
gate over the app tree, where it passes trivially. That fan-out is useful; it
is not coverage of the engine, and the table says so.

check_app_invariants.sh also derives ROOT as dirname(TARGET), so with app/lib
it prints "no rule_engine package found — layer check skipped". Skips like that
are printed in a notes block rather than failed, because some are correct at
E01 — there are no ARB files until E06 and no /theme/ until E07 — but they are
made visible so "which checks did not actually run?" is answerable from the job
log.

Rejected: sixteen workflow steps, which stop at the first red and hide fifteen
results; and running only check_app_invariants.sh and trusting its delegation,
which gives every gate the wrong target.

No file under .claude/skills/ was edited here. That is E01/T09's licence.

Task: E01/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
