# E21/T08 — The release checklist, signed off

| | |
|---|---|
| **Epic** | E21 — Offline verification and release readiness |
| **Branch** | `epic/21-release` (shared) |
| **Commit** | `docs(ci): the signed-off release checklist and the gate that refuses an unfilled one` |
| **Depends on** | T01–T07 (every row it records is produced by one of them) |
| **Size** | M |
| **Spec** | `SPEC.md` §14 in full — all 21 checkboxes; §13 (the two budgets recorded on it) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-offline-guarantee` | `references/verification-ritual.md` owns the release checklist shape, which steps block a release and which do not, and the evidence-retention table this artefact implements |
| `ci-pipeline-and-gates` | Rule 10: state plainly what CI cannot prove, so the manual on-device pass is treated as a load-bearing release artifact rather than a chore. This task is that treatment |
| `testing-strategy` | `references/coverage-and-budget.md`: hand structurally-untestable paths to a **tracked, dated** checklist ticked before every release, on the release build, on real hardware |
| `catchlaw-conventions-index` | The five invariants, so the checklist's closing section can assert each was re-checked rather than assumed |
| `catchlaw-reference-database` | Rule 7's first-launch budget and the < 1.2 s cold start — the two §13 numbers the checklist records as measurements rather than as claims |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §14 | All 21 checkboxes verbatim — 5 static and 16 dynamic. The checklist's rows are these, and the gate proves they still are |
| `SPEC.md` | §13 | < 6 s first launch with a determinate indicator on a Snapdragon 665; < 1.2 s subsequent cold start on the same device |
| `SPEC.md` | §11 | The two platforms the dynamic rows are run on |
| `.claude/skills/catchlaw-offline-guarantee/references/verification-ritual.md` | "The release checklist", "Evidence retention", "Cadence" | The nine-step shape, which steps block, the artefact names, the two-year window, and the per-release / per-dependency-bump / per-SDK-upgrade cadence |
| `testing-strategy` → `references/coverage-and-budget.md` (Flutter-Skills plugin) | "Hand structurally-untestable paths to a named manual pass" | Tracked, dated, before every release, on the release build, on real hardware |
| `ci-pipeline-and-gates` → `references/policy-grep-gate.md` (Flutter-Skills plugin) | "The three-criteria bar", "Write the reason for a stranger" | Why the checklist gate qualifies, and how its failure message must read |
| `epics/E21-release/epic.md` | "§14 — every checkbox has an owner" | The 21-row owner map this checklist is the executed form of |
| `epics/CONVENTIONS.md` | §8, §9 | The floor under every task; the five invariants the closing section re-checks |
| `epics/DECISIONS.md` | D-9 | Merging on all-green with `--squash --admin`; the checklist is what "all-green" means for the rows CI cannot run |

## What this delivers

- `docs/release/RELEASE-CHECKLIST.template.md` — 21 rows, one per §14 checkbox, each with: the §14 text,
  the owning task, the person who ran it, the device (model and OS version), the build (version, build
  number, artefact sha256), the ISO date, the result, and the relative path to its evidence.
- `docs/release/<version>/RELEASE-CHECKLIST.md` — the first filled instance, for the release this epic
  certifies. Header block: artefact path, artefact sha256, artefact build date, the two devices, the
  two §13 measurements taken during T02's walkthrough, and the resolved `aapt2` path from T01.
- `docs/release/<version>/evidence/` — the two `.pcap` files, the `aapt2` manifest dump, the
  `dart pub deps` snapshot (`deps-<version>.txt`, per the retention table), the `TrafficStats` log, and
  the four screenshots from T04, T05 and T06.
- `tools/gates/check_release_checklist.sh` — the gate.
- `app/test/policy/release_checklist_gate_test.dart` — drives it against fixtures.
- `tools/gates/fixtures/checklist-*.md` — six fixtures, one per failure mode plus one clean.

## Why it is built this way

**The problem is not that checks go unrun. It is that nobody can tell afterwards.** A release where the
capture was taken, the clock was moved and the reinstall was performed is indistinguishable, a month
later, from one where they were not — unless somebody wrote down who did what, on which handset, on what
date. `verification-ritual.md` already prescribes evidence retention for exactly this reason: the
capture is what turns "we do not collect location" from an assertion into a record. This task makes the
record mandatory and machine-checked.

**Every row names a person and a device, and the gate enforces it.** "Verified" with no name is the
sentence that ends an incident review badly. `coverage-and-budget.md` requires the manual pass be
*tracked and dated*; a device model matters because §13's budgets are stated against a Snapdragon 665
and a result from a flagship says nothing about them.

**Evidence may not predate the artefact it certifies.** This is the gate's most useful rule and the
least obvious one. A capture taken against last week's build, attached to this week's release, is
exactly the shape a rushed release takes — nothing was faked, a file was simply reused. So the header
carries the artefact's build date and its sha256, and the gate fails any row dated before that build
date, and fails when the sha256 in the header does not match the file at the recorded path.

**The row set is derived from `SPEC.md` §14 and checked against it.** T01 already asserts the static
block still has five rows; this gate asserts the whole checklist still has 21 and that each row's text
still matches a §14 bullet. Editing §14 therefore fails the release gate until the checklist is updated
in the same PR — which is the only mechanism that stops a new §14 row shipping unowned and unrun.

**Not every row blocks in the same way, and the file says which.** `verification-ritual.md` marks the
merger report as "no, but attach it" while the two captures block. The template carries a **Blocks
release** column copied from that table's shape, so an operator under time pressure is making a recorded
decision rather than an invisible one.

**Rejected: a GitHub issue template or a PR checklist.** Both live outside the repository's history of
the artefact. `verification-ritual.md`'s retention table wants the `pub deps` snapshot committed as
`docs/deps-<version>.txt` and the captures attached to the release tag; a file in the tree is what a
`git log` on a two-year-old tag can still produce.

**Rejected: a coverage-percentage-style summary at the top.** `ci-pipeline-and-gates` rule 8's argument
generalises: "19 of 21 passed" is a number that makes an incomplete release look almost complete. There
is no score. There are 21 rows and each has a result.

**Rejected: allowing `n/a` on a dynamic row.** A row that does not apply to a platform — the iOS
reinstall behaviour in T06 — is recorded with its **observed** result and §11's reason, not blanked. An
`n/a` is where the next release's unrun check will hide.

## Tests first

Write every row before creating the template. Run them. **They must fail** — the gate script does not
exist. If row 1 passes now, the test is wrong: it is almost certainly counting `- [ ]` lines in a file
that does not exist and getting zero, which compares equal to nothing useful, so assert the count is 21
rather than asserting it is non-zero.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `check_release_checklist.sh exits 2 when the checklist does not exist` | missing path | exit `2` | `CONVENTIONS.md` §7. A release with no checklist must abort loudly, not pass for want of a file to fail on |
| 2 | `check_release_checklist.sh fails when the checklist has fewer than 21 rows` | `checklist-missing-row.md` | exit `1`, message names the count | §14 has 21 checkboxes. A checklist with 20 has one unowned check, and that is the whole failure this epic exists to prevent |
| 3 | `check_release_checklist.sh fails when a row's text does not match a SPEC §14 bullet` | `checklist-drifted-text.md` | exit `1`, names the row | A row reworded into something easier to pass is the quiet version of dropping it |
| 4 | `check_release_checklist.sh fails when a cell is empty` | `checklist-empty-cell.md` | exit `1` | An unfilled cell is an unrun check wearing the appearance of a run one |
| 5 | `check_release_checklist.sh fails when a cell reads TBD` | `checklist-tbd.md` | exit `1` | The same failure, one step more deliberate, and the one a non-empty-cell check alone would miss |
| 6 | `check_release_checklist.sh fails when a dynamic row names no device` | `checklist-no-device.md` | exit `1` | §13's budgets are stated against a named device. A result with no device attached cannot be compared to them or to the next release |
| 7 | `check_release_checklist.sh fails when a row's evidence path does not exist` | `checklist-dangling-evidence.md` | exit `1`, names the path | A pointer to a missing file is worse than no pointer: it reads as evidence in every summary |
| 8 | `check_release_checklist.sh fails when a row is dated before the artefact build date` | `checklist-stale-evidence.md` | exit `1` | Reusing last build's capture. Nothing is faked and the release is still uncertified |
| 9 | `check_release_checklist.sh fails when the header sha256 does not match the artefact` | `checklist-wrong-sha.md` | exit `1` | The checklist certifies one specific file. Without this, it certifies whatever is at that path today |
| 10 | `check_release_checklist.sh fails when a dynamic row reads n/a` | `checklist-na-row.md` | exit `1` | Where the next unrun check will hide. T06's iOS row records what was observed and why, never a blank |
| 11 | `check_release_checklist.sh passes on a fully filled checklist` | `checklist-clean.md` | exit `0` | The pass path must be reachable, or the gate gets bypassed on the night it matters |
| 12 | `SPEC §14 lists twenty-one checks` | `../SPEC.md` | `21` | Five static plus sixteen dynamic. A twenty-second row added without a checklist row is the drift this catches, and it fails here as well as in T01 |

```dart
// app/test/policy/release_checklist_gate_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _gates = '../tools/gates';
const String _fixtures = '$_gates/fixtures';

ProcessResult _check(String fixture) => Process.runSync(
      'bash',
      <String>['$_gates/check_release_checklist.sh', '$_fixtures/$fixture'],
    );

void main() {
  test('check_release_checklist.sh exits 2 when the checklist does not exist', () {
    final ProcessResult r = Process.runSync(
      'bash',
      <String>['$_gates/check_release_checklist.sh', '/nonexistent/RELEASE-CHECKLIST.md'],
    );
    expect(r.exitCode, 2);
  });

  test('check_release_checklist.sh fails when a row is dated before the artefact build date', () {
    final ProcessResult r = _check('checklist-stale-evidence.md');
    expect(r.exitCode, 1);
    expect(r.stderr, contains('predates the artefact'));
  });

  test('check_release_checklist.sh passes on a fully filled checklist', () {
    final ProcessResult r = _check('checklist-clean.md');
    expect(r.exitCode, 0, reason: r.stderr.toString());
  });

  test('SPEC §14 lists twenty-one checks', () {
    final List<String> lines = File('../SPEC.md').readAsLinesSync();
    final int start = lines.indexWhere((String l) => l.startsWith('## 14. Offline verification'));
    final int end = lines.indexWhere((String l) => l.startsWith('## 15. Build order'), start);
    final Iterable<String> boxes =
        lines.sublist(start, end).where((String l) => l.startsWith('- [ ] '));
    expect(boxes, hasLength(21),
        reason: 'a §14 checkbox was added or removed — update the checklist template and its owner map');
  });

  // … rows 2–7, 9, 10
}
```

**Run:** `cd app && flutter test test/policy/release_checklist_gate_test.dart` → 12 failures. Any pass
now is a wrong test.

## Implementation outline

1. Write the twelve rows and the six fixtures. Build each fixture by copying the clean one and breaking
   exactly one thing — a fixture that breaks two makes a passing gate ambiguous about which rule caught
   it.
2. Write `docs/release/RELEASE-CHECKLIST.template.md`. Header block first: artefact path, artefact
   sha256, artefact build date (ISO), Android device (model, OS version), iOS device (model, OS
   version), first-launch extraction time against §13's < 6 s, subsequent cold start against < 1.2 s,
   resolved `aapt2` path. Then the 21-row table with columns: `#`, `§14 check`, `Task`, `Blocks
   release`, `Ran by`, `Device`, `Date`, `Result`, `Evidence`.
3. Copy the 21 check texts out of `SPEC.md` §14 mechanically — a script, not a retype, so row 3's match
   is exact on the first run.
4. Write `tools/gates/check_release_checklist.sh`. Order the checks so the most diagnostic failure wins:
   file missing (2), row count, row-text match against `SPEC.md`, empty or `TBD` or `n/a` cell, missing
   device on a dynamic row, dangling evidence path, date before the artefact build date, sha256
   mismatch. Every failure message names the row number and says what to do, per
   `policy-grep-gate.md`'s "write the reason for a stranger".
5. Fill `docs/release/<version>/RELEASE-CHECKLIST.md` from T01–T07's results. Every dynamic row is
   filled by the person who ran it, not by whoever is assembling the file.
6. Move the evidence into `docs/release/<version>/evidence/` with the names from
   `verification-ritual.md`'s retention table, and commit `docs/deps-<version>.txt`.
7. Add a closing section to the filled checklist: the five invariants from `CONVENTIONS.md` §9, each with
   the row or rows that re-checked it during this release.
8. Run the gate against the filled instance. It must pass without editing the gate.
9. Re-run the suite. All 12 green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 tests pass, and each failed first.
- [ ] `docs/release/<version>/RELEASE-CHECKLIST.md` has 21 rows and the gate passes on it.
- [ ] Every row names a person, and every dynamic row names a device model and an OS version.
- [ ] No cell is empty, and none reads `TBD` or `n/a`.
- [ ] Every evidence path resolves, and the header sha256 matches the artefact at the recorded path.
- [ ] No row is dated before the artefact's build date.
- [ ] The two §13 measurements are recorded as numbers taken on the named Android device, against the
      < 6 s and < 1.2 s targets.
- [ ] `docs/deps-<version>.txt` is committed, and both `.pcap` files are in place under
      `docs/release/<version>/evidence/`.
- [ ] The closing section maps all five invariants to the rows that re-checked them this release.
- [ ] The template contains no result. It is a template; the filled instance is a separate file.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze --fatal-infos && flutter test
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh app/lib
bash -n tools/gates/check_release_checklist.sh
tools/gates/check_release_checklist.sh docs/release/<version>/RELEASE-CHECKLIST.md
tools/gates/check_release_aab_manifest.sh app/build/app/outputs/bundle/release/app-release.aab
tools/gates/check_dependency_allowlist.sh app
tools/gates/check_store_listings.sh store
tools/gates/assert_zero_packets.sh docs/release/<version>/evidence/catchlaw-android-<version>.pcap
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
docs(ci): the signed-off release checklist and the gate that refuses an unfilled one

A release where the capture was taken, the clock was moved and the reinstall was
performed is indistinguishable a month later from one where they were not,
unless somebody wrote down who did what on which handset on what date. Twenty-one
rows, one per SPEC §14 checkbox, each naming a person, a device, a date and a
path to its evidence — and a gate that refuses an empty cell, a TBD, an n/a on a
dynamic row, a dangling evidence path, or a row whose text has drifted from the
spec bullet it claims to be. The rule that earns its keep is the date one:
evidence may not predate the artefact it certifies, because reusing last build's
capture fakes nothing and still leaves the release uncertified. There is no
score at the top; "19 of 21" makes an incomplete release look almost complete.

Task: E21/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
