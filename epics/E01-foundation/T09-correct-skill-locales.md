# E01/T09 — Correct the skills that disagree with the spec

| | |
|---|---|
| **Epic** | E01 — Foundation, workspace and the offline gates |
| **Branch** | `epic/01-foundation` (shared) |
| **Commit** | `docs(check): correct four skill files to the six shipped locales and the builder's name` |
| **Depends on** | T01 (its tests live in `app/test/policy/`) |
| **Size** | S |
| **Spec** | `SPEC.md` §9.1 (the six locales and the evidence for each), §9.2, §8 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-conventions-index` | Three of the four edited files are its own. Rule 12 is the rule being corrected, and rule 10 — a general rule is never forked — is why the correction happens in the skill rather than in a note somewhere else |
| `catchlaw-verdict-contract` | Its definition-of-done line names `app_pt.arb`. This task changes that one filename and nothing about the wording law the skill owns |
| `ci-pipeline-and-gates` | Rule 9: a gate verifies, it never blesses. The change to `check_app_invariants.sh` is a **report label**, and the distinction between a label and a regex is the whole care in this task |
| `dependency-hygiene` | Nothing is added to any pubspec. Named here so the reader knows that was checked rather than forgotten |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `epics/DECISIONS.md` | D-3 | The decision: `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`; RTL golden lanes are `ar` only; the three places that say `app_ur.arb` and the one that says `app_pt.arb`; **Skill correction: E01/T09** |
| `epics/DECISIONS.md` | D-4 | One name: directory `tools/content_builder/`, package `content_builder`, executable `dart run content_builder:build` |
| `SPEC.md` | §9.1 | Why each locale ships, with the evidence per row. Catalonia, Valencia and the Balearics publish their fishing orders in Catalan; Urdu appears nowhere and no bundled instrument is published in it |
| `SPEC.md` | §9.2 | The ARB filenames, listed with `app_pt_BR.arb` carrying its region because the content is Brazilian rather than Iberian |
| `.claude/skills/catchlaw-conventions-index/SKILL.md` | rule 12, rule 6, the routing table, the definition of done, the frontmatter description | The nine lines this task edits in that file |
| `.claude/skills/catchlaw-conventions-index/references/routing-table.md` | the layer map and the app-skills table | The four lines this task edits there |
| `.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh` | line 65 report label, line 101 comment | The two lines this task edits, **neither of which is a regex** |
| `.claude/skills/catchlaw-verdict-contract/SKILL.md` | definition of done | The one filename this task edits |
| `.github/workflows/validate.yml` | job `skills` | The three checks this task must not break: `bash -n` on every script, frontmatter parsing to exactly `name` + `description` with a 200–1024-character description, and no dangling bundled-file citation |
| `.github/CODEOWNERS` | whole | `/.claude/skills/catchlaw-verdict-contract/` is a named legal-liability surface; the PR needs code-owner review, which D-9's `--admin` path already covers |

## What this delivers

Four files edited, and nothing else in the repository except the new test.

**1. `.claude/skills/catchlaw-conventions-index/SKILL.md` — nine lines.**

| Line | From | To | Decision |
|---|---|---|---|
| frontmatter `description` | `content_build CLI` | `content_builder CLI` | D-4 |
| rule 6 | breaks the `content_build` CLI | breaks the `content_builder` CLI | D-4 |
| rule 12 | `app_pt.arb` and `app_ur.arb`; "Arabic and Urdu RTL lanes" | `app_ca.arb` and `app_pt_BR.arb`; "an Arabic RTL lane" | D-3 |
| the layer-map paragraph | `packages/content_build/` | `tools/content_builder/` | D-1, D-4 |
| routing-table row | the `content_build` CLI | the `content_builder` CLI | D-4 |
| anti-patterns | breaks `content_build` | breaks `content_builder` | D-4 |
| definition of done | "`ar` and `ur` golden lanes green" | "the `ar` golden lane green" | D-3 |
| related skills (×2) | `content_build` | `content_builder` | D-4 |

**2. `.claude/skills/catchlaw-conventions-index/references/routing-table.md` — four lines.**
`packages/content_build/` → `tools/content_builder/` in the layer map; the `lib/l10n/` row's ARB list →
`app_ar.arb`, `app_en.arb`, `app_es.arb`, `app_gl.arb`, `app_ca.arb`, `app_pt_BR.arb`; "Arabic or Urdu
faces" → "Arabic faces"; the app-skills row's `content_build` CLI → `content_builder` CLI.

**3. `.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh` — two lines, both
non-executable.** The check-3 **report label** loses `app_ur.arb` and gains `app_ca.arb`; the check-7
**comment** loses `content_build` and gains `content_builder`. No regex, no `--include` pattern, no
control flow and no exit code changes.

**4. `.claude/skills/catchlaw-verdict-contract/SKILL.md` — one line.** The definition-of-done line reading
"`app_ar.arb` and `app_pt.arb` included" becomes "`app_ar.arb` and `app_pt_BR.arb` included".

Plus:

- `tools/gates/known_skill_drift.txt` — the recorded set of files that still carry the pre-D-3/D-4 wording
  and the epic that fixes each.
- `app/test/policy/skill_locale_test.dart`.

## Why it is built this way

**This is the one place in the whole plan where a task edits a skill, and the reason is that the skills are
wrong.** `SPEC.md` §9.1 justifies every shipped locale by the publication language of the instrument being
bundled — Catalan because Catalonia, Valencia and the Balearics publish their fishing orders in Catalan.
Urdu appears nowhere in `SPEC.md`, and no bundled instrument is published in it. Three skill files
nonetheless name `app_ur.arb` and speak of "Arabic and Urdu RTL lanes", and one names `app_pt.arb` without
the region. D-3 settles it and names this task as the correction site. Nothing here is re-argued; the
decision is cited.

**The `ur` → `ca` swap is not cosmetic, because of what a skill is for.** These files are read by a model
about to write `app/lib/l10n/`. A rule that says six ARB files and lists the wrong two produces a PR with
`app_ur.arb` in it and a golden matrix with an RTL lane for a language nobody ships — and every one of
those artefacts then looks correct against the skill that produced it. Leaving the correction to E06 would
mean E02 through E05 are executed against a rule that is wrong, and the first person to notice would be
holding a diff, not a decision.

**`app_pt` versus `app_pt_BR` is a real difference, not a spelling.** D-3: the region travels because the
content is Brazilian and not Iberian Portuguese. `SPEC.md` §9.1 justifies the locale by piracema, minimum
sizes and quotas being per-state and Portuguese-language in Brazil. A `pt` ARB would resolve for a
Portugal-locale device and present Brazilian state rules to somebody they do not apply to.

**The script edit is a label and a comment, and that distinction is the whole care in this task.**
`check_app_invariants.sh` check 3 greps `--include='*.arb'` over the target — it is locale-agnostic and
scans whatever ARB files exist. Only the human-readable string in `report "…"` names two locales as
examples. Changing the label changes what a failing run *says*; changing the regex would change what it
*catches*. Test 5 pins the `--include` patterns so that a future edit to this line cannot narrow the scan,
and `bash -n` plus the `skills` job's own parse step guard the rest.

**Rejected: rewriting the routing table's root-relative paths.** The table still places the app at the
repository root — `lib/data/`, `lib/ui/`, `lib/l10n/`, `assets/db/` — and D-1 overrules that. D-1 also
names E01/T09 as its skill-correction site, but this epic's task list scopes T09 to D-3 and D-4 and
`CONVENTIONS.md` forbids changing what a task covers. The rows are not load-bearing for any gate — D-1
records that no script needs editing, and T08's table is where the real target directories now live. The
gap is in the epic's Risks with the resolution named: a line in `DECISIONS.md` naming the task that
rewrites those paths.

**Rejected: fixing `catchlaw-content-pipeline`.** It carries the same two defects at greater depth — its
shipped-locale list is `['ar','en','es','gl','pt_BR','ur']`, its gendered-locale set includes `ur` and
omits `ca`, and it names the CLI `tools/content_build` throughout, including in an executable example and a
build-assertions table row justifying `ur` as a "Gulf crew language". That is not a find-and-replace: the
gender rule for Catalan and the removal of a locale from a build assertion are content decisions that
belong with the epic that builds the pipeline. D-4 names **E04/T01** as its applier and D-3 names
**E06/T01**. The skill is also a `.github/CODEOWNERS` legal-liability surface. `tools/gates/known_skill_drift.txt`
records every remaining file with the epic that owns it, and test 6 asserts the set does not grow — so this
is a scheduled correction with a test behind it, not a thing that was missed.

**Rejected: also editing `references/product-invariants.md` and `examples/catchlaw_layering.dart`.** Each
carries one residual occurrence — the citation section's "every locale including `ar` and `ur`", and a doc
comment naming "the content_build CLI". They belong to the same skill as file 1, and including them would
make this a six-file task where the plan says four. They are in `known_skill_drift.txt` with their owning
epic, for the same reason as above.

**The frontmatter description is length-gated and this task touches it.** `validate.yml`'s `skills` job
fails a description outside 200–1024 characters. The current one is 945; `content_build` →
`content_builder` makes it 947. Test 4 asserts the bound rather than the exact number, because the number
is not the contract — the job's range is.

## Tests first

Write `app/test/policy/skill_locale_test.dart` and `tools/gates/known_skill_drift.txt` before editing any
skill file. Run them. **Tests 1, 2, 3 and 6 must fail** — the four files still carry the old wording. Tests
4 and 5 assert properties that already hold, so they pass early and are asserting nothing yet: prove each
red first by padding the description past 1024 characters and by narrowing an `--include` pattern in a
scratch copy, then revert both.

| # | Test name | Asserts | Why this case exists |
|---|---|---|---|
| 1 | `The four corrected skill files name no Urdu ARB or Urdu RTL lane` | no `app_ur.arb`, no `Urdu` in those four files | D-3. A skill that lists the wrong ARB set produces a PR with `app_ur.arb` in it, and that PR looks correct against the skill that produced it |
| 2 | `The four corrected skill files name every ARB file with its full locale` | `app_pt_BR.arb`, never `app_pt.arb` | D-3: the region travels because the content is Brazilian. A `pt` ARB resolves on a Portugal-locale device and shows Brazilian state rules to somebody they do not apply to |
| 3 | `The four corrected skill files name the content builder as content_builder` | no `content_build` that is not `content_builder`, no `packages/content_build/` | D-4. Three names for one deliverable was going to cost somebody an afternoon |
| 4 | `catchlaw-conventions-index frontmatter description stays within the CI bound` | 200 ≤ length ≤ 1024, no `<` or `>` | This task edits the description, and `validate.yml`'s `skills` job fails outside that range. Breaking a CI job while correcting a document is the plausible mistake here |
| 5 | `check_app_invariants.sh still scans every ARB file regardless of locale` | both `--include='*.arb'` occurrences intact | The edit is a report **label**. If the `--include` ever narrowed, the gate would stop seeing locales while still printing a label that claims it sees them |
| 6 | `Files still carrying the pre-decision wording are exactly those recorded in known_skill_drift.txt` | set equality | Pins the residual: this task cannot leave one of its four files unfixed, and a later epic cannot introduce the wording into a new file without the test naming it |

```dart
// app/test/policy/skill_locale_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'repo_root.dart';

/// The four files E01/T09 corrects. D-3 names the first three; D-4 the builder.
const correctedFiles = <String>[
  '.claude/skills/catchlaw-conventions-index/SKILL.md',
  '.claude/skills/catchlaw-conventions-index/references/routing-table.md',
  '.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh',
  '.claude/skills/catchlaw-verdict-contract/SKILL.md',
];

/// D-3. Catalan ships; Urdu does not. The region travels on Portuguese.
const shippedArb = <String>[
  'app_ar.arb', 'app_en.arb', 'app_es.arb',
  'app_gl.arb', 'app_ca.arb', 'app_pt_BR.arb',
];

final _staleLocale = RegExp(r'app_ur\.arb|\bUrdu\b');
final _staleBuilder = RegExp(r'content_build(?!er)|packages/content_build');
final _stalePt = RegExp(r'app_pt\.arb');

String frontmatterDescription(String path) {
  final raw = repoFile(path).readAsStringSync();
  return (loadYaml(raw.split('---')[1]) as YamlMap)['description'] as String;
}

/// `<path> <epic>` lines: the files that legitimately still carry the old wording.
Set<String> recordedDrift() => repoFile('tools/gates/known_skill_drift.txt')
    .readAsLinesSync()
    .map((l) => l.split('#').first.trim())
    .where((l) => l.isNotEmpty)
    .map((l) => l.split(RegExp(r'\s+')).first)
    .toSet();

void main() {
  test('The four corrected skill files name no Urdu ARB or Urdu RTL lane', () {
    final offenders = <String>[
      for (final p in correctedFiles)
        if (_staleLocale.hasMatch(repoFile(p).readAsStringSync())) p,
    ];
    expect(offenders, isEmpty,
        reason: 'D-3: Urdu appears nowhere in SPEC.md and no bundled instrument is '
            'published in it:\n${offenders.join('\n')}');
  });

  test('The four corrected skill files name every ARB file with its full locale', () {
    final offenders = <String>[
      for (final p in correctedFiles)
        if (_stalePt.hasMatch(repoFile(p).readAsStringSync())) p,
    ];
    expect(offenders, isEmpty,
        reason: 'D-3: the region travels because the content is Brazilian, not Iberian:\n'
            '${offenders.join('\n')}');
    final index = repoFile(correctedFiles.first).readAsStringSync();
    expect(shippedArb.where(index.contains), hasLength(shippedArb.length),
        reason: 'rule 12 must list all six');
  });

  test('The four corrected skill files name the content builder as content_builder', () {
    final offenders = <String>[
      for (final p in correctedFiles)
        if (_staleBuilder.hasMatch(repoFile(p).readAsStringSync())) p,
    ];
    expect(offenders, isEmpty, reason: 'D-4: one name:\n${offenders.join('\n')}');
  });

  test('catchlaw-conventions-index frontmatter description stays within the CI bound', () {
    final d = frontmatterDescription(correctedFiles.first);
    expect(d.length, inInclusiveRange(200, 1024),
        reason: 'validate.yml\'s skills job fails outside this range — breaking a CI job '
            'while correcting a document is the mistake this test is for');
    expect(d, isNot(anyOf(contains('<'), contains('>'))));
  });

  test('check_app_invariants.sh still scans every ARB file regardless of locale', () {
    final script = repoFile(correctedFiles[2]).readAsStringSync();
    expect("--include='*.arb'".allMatches(script).length, 2,
        reason: 'the edit is a report LABEL. A narrowed --include would stop the gate '
            'seeing locales while it kept printing a label claiming it sees them');
  });

  test('Files still carrying the pre-decision wording are exactly those recorded in '
      'known_skill_drift.txt', () {
    final actual = repoDir('.claude/skills')
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path.replaceFirst('${repoRoot().path}/', ''))
        .where((p) {
          final t = repoFile(p).readAsStringSync();
          return _staleLocale.hasMatch(t) ||
              _staleBuilder.hasMatch(t) ||
              _stalePt.hasMatch(t) ||
              RegExp(r"'ur'|`ur`").hasMatch(t);
        })
        .toSet();
    expect(actual, recordedDrift(),
        reason: 'either this task left one of its four files unfixed, or a later change '
            'introduced the pre-decision wording into a file with no owning epic');
  });
}
```

**Run:** `cd app && flutter test test/policy/skill_locale_test.dart` → 4 failures (tests 1, 2, 3, 6) and 2
early passes (4, 5). Prove 4 and 5 red as described above before writing a single skill edit.

## Implementation outline

1. Write `tools/gates/known_skill_drift.txt`. One line per remaining file: the path, the owning epic and
   task, and one clause saying what is stale. At the time of writing that is the four
   `catchlaw-content-pipeline` files (D-4 → E04/T01; D-3 → E06/T01),
   `catchlaw-conventions-index/references/product-invariants.md` and
   `catchlaw-conventions-index/examples/catchlaw_layering.dart`. A header comment says the file is a
   *schedule*, not an exemption, and that a line is deleted when its epic lands.
2. Edit `catchlaw-conventions-index/SKILL.md`, the nine lines in the table above. Rule 12's new text keeps
   its **WHY** clause unchanged — the reason a missing Arabic key is dangerous does not depend on which six
   locales ship.
3. Edit `references/routing-table.md`, the four lines. Leave the root-relative `lib/` paths alone; they are
   D-1's and are recorded in the epic's Risks.
4. Edit `scripts/check_app_invariants.sh`, the report label on check 3 and the comment on check 7. **Change
   nothing else.** Run `git diff --stat` and confirm two lines changed in that file, then `git diff` and
   confirm neither is inside a `grep`.
5. Edit `catchlaw-verdict-contract/SKILL.md`, the one filename.
6. Run the four `skills`-job checks locally before pushing, because they are the checks this task is most
   likely to break:
   ```bash
   bash -n .claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh
   python3 -c "import glob,yaml,os;[print(os.path.basename(os.path.dirname(p)), len(yaml.safe_load(open(p).read().split('---')[1])['description'])) for p in sorted(glob.glob('.claude/skills/*/SKILL.md'))]"
   ```
7. Run `check_app_invariants.sh app/lib` before and after the edit and diff the two outputs. The only
   difference must be the label text. Same exit code, same checks, same fan-out.
8. Re-run the six tests plus the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 6 tests pass. Tests 1, 2, 3 and 6 failed first; tests 4 and 5 were proved red against a planted
      violation and the plant was reverted.
- [ ] `git diff --stat` shows exactly four files under `.claude/skills/` and nothing else there.
- [ ] `check_app_invariants.sh app/lib` produces byte-identical output before and after the edit **except**
      for the one report label, and the same exit code. Confirmed by diffing two captured runs.
- [ ] `bash -n` passes on the edited script (the `skills` job's first step).
- [ ] Both edited `SKILL.md` frontmatters still parse to exactly `name` + `description`, with the
      description between 200 and 1024 characters and containing no `<` or `>` (the `skills` job's second
      step).
- [ ] No `SKILL.md` cites a bundled file that does not exist (the `skills` job's third step) — nothing was
      renamed, so this should hold, and it is checked rather than assumed.
- [ ] `tools/gates/known_skill_drift.txt` names an owning epic and task for every remaining file, and D-3
      and D-4 agree with what it says.
- [ ] No skill's rules, thresholds, regexes or exit codes changed. This task changes what four documents
      *say*, not what any gate *does*.

## Gates

```bash
bash -n .claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
bash tools/gates/run_skill_gates.sh tools/gates/skill_gates.tsv
cd app && flutter test && cd ..
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
docs(check): correct four skill files to the six shipped locales and the builder's name

D-3: the shipped locales are ar, en, es, gl, ca and pt_BR, and the RTL golden
lane is ar only. SPEC.md §9.1 justifies each by the publication language of the
instrument being bundled — Catalan because Catalonia, Valencia and the Balearics
publish their fishing orders in Catalan. Urdu appears nowhere in SPEC.md and no
bundled instrument is published in it, yet three skill files name app_ur.arb and
speak of Arabic and Urdu RTL lanes.

These files are read by whoever is about to write app/lib/l10n/. A rule that
lists the wrong two ARB files produces a PR containing app_ur.arb and a golden
matrix with a lane for a language nobody ships, and that PR looks correct
against the skill that produced it. Leaving the fix to E06 would mean E02
through E05 are executed against a rule that is wrong.

app_pt.arb becomes app_pt_BR.arb: the region travels because the content is
Brazilian, not Iberian. A pt ARB resolves on a Portugal-locale device and
presents Brazilian state rules to somebody they do not apply to.

D-4: one name for the builder — tools/content_builder/, package content_builder.

The change to check_app_invariants.sh is a report LABEL on check 3 and a comment
on check 7. Its --include='*.arb' patterns are untouched: the grep is
locale-agnostic and always was. Before and after runs of the script over app/lib
were diffed and differ only in that label.

Deliberately not here: catchlaw-content-pipeline carries the same two defects at
greater depth — a shipped-locale list missing ca, a gendered-locale set
including ur, and tools/content_build throughout, including in a runnable
example. Those are content decisions for the epic that builds the pipeline;
D-4 names E04/T01 and D-3 names E06/T01. tools/gates/known_skill_drift.txt
records every remaining file with its owning epic and a test asserts the set
does not grow.

Task: E01/T09
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
