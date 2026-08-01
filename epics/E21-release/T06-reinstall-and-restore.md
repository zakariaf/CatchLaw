# E21/T06 — Reinstall, and restore from an export

| | |
|---|---|
| **Epic** | E21 — Offline verification and release readiness |
| **Branch** | `epic/21-release` (shared) |
| **Commit** | `test(data): prove the catch log does not survive reinstall and that an export restores it` |
| **Depends on** | T01 (the AAB manifest gate this extends), T02 (the walkthrough that produces the data) |
| **Size** | M |
| **Spec** | `SPEC.md` §14 dynamic row 18; §11 Android and iOS (the deliberate asymmetry); §12 in full |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-reference-database` | Rules 1, 8, 9, 10: which file holds the fisher's record, why a restored catch row carries its own denormalised statement, the refusal of a `user.db` from the future, and which directory is backed up on which platform |
| `catchlaw-conventions-index` | Invariant 11 (nothing leaves the device, so portability is the whole answer) and the three-file/two-database shape a restore has to land in |
| `testing-strategy` | `references/coverage-and-budget.md`: the prior-release migration rehearsal and the export → wipe → import rehearsal through the **real** share sheet are named there as manual-pass rows, not as automated ones |
| `ci-pipeline-and-gates` | Rule 7's three-criteria bar, for the two manifest attributes this task adds to T01's gate |
| `dependency-hygiene` | Rule 8's habit applied to a manifest attribute: a value removed from source that still resolves from a default is the failure that only shows on a clean install |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §14 dynamic row 18 | The two clauses: the catch log is gone, and a pre-taken export restores it **completely** |
| `SPEC.md` | §11 Android | `android:allowBackup="false"`, no `dataExtractionRules`, and the reason — the catch log must not be swept into a Google backup the user did not choose |
| `SPEC.md` | §11 iOS | `NSURLIsExcludedFromBackupKey` is deliberately **not** set; an iCloud device backup is the user's own encrypted backup. The asymmetry is intentional and is explained in S17 |
| `SPEC.md` | §12 | The four export artefacts, the JSON header fields, merge versus replace, transactional import, and the refusal of a newer schema |
| `SPEC.md` | §7.2 | The `user.db` tables a complete restore must land in: `user_profile`, `saved_zone`, `trip`, `catch`, `species_recent`, `rule_flag`, `app_meta` |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | whole | The ownership matrix, the directory and backup policy, and the `user_version` refusal |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | rules 1, 8, 9, 10 | Two lifecycles; denormalised catch columns; refuse a database from the future and say so; support directory and backup policy |
| `testing-strategy` → `references/coverage-and-budget.md` (Flutter-Skills plugin) | "Hand structurally-untestable paths to a named manual pass" | The rehearsal list this row is on, including feeding import a truncated file |
| `epics/CONVENTIONS.md` | §6, §8 | Where fixtures live; the floor under every task |
| `epics/DECISIONS.md` | D-6 | The extraction contract — a reinstall re-extracts `reference.db`, and that is not data loss |

## What this delivers

- Two new checks in `tools/gates/check_release_aab_manifest.sh` (T01's script): the merged manifest's
  `<application>` element must carry `android:allowBackup="false"`, and must carry no
  `android:dataExtractionRules` and no `android:fullBackupContent`.
- Two new fixtures: `tools/gates/fixtures/aab-manifest-allow-backup-true.txt` and
  `aab-manifest-with-extraction-rules.txt`.
- Four new rows in `app/test/policy/release_artifact_gates_test.dart` (T01's file).
- `app/integration_test/reinstall_restore_test.dart` — the automated half: export from a populated
  `user.db`, delete the file to reach the state a reinstall leaves, relaunch, assert the log is empty,
  import the export, assert every count and every denormalised field matches.
- `docs/release/reinstall-and-restore.md` — the device procedure for both platforms, including the
  iOS asymmetry stated rather than glossed.
- `docs/release/<version>/evidence/reinstall-empty.png` and `reinstall-restored.png`.

## Why it is built this way

**`allowBackup="false"` is a promise nobody has watched behave.** It is one attribute in one manifest,
it has never been observed doing anything, and its failure mode is invisible: a build with
`allowBackup="true"` behaves identically until the day a user restores a phone and finds three seasons
of somebody's trip history on a device they did not record it on. §11 is explicit about why — the catch
log must not be swept into a Google backup the user did not choose, and portability is served by the
explicit export in §12 instead. So the attribute is gated on the **merged** manifest (a library manifest
can set it, and the merger resolves it), and then watched on a real device.

**The gate and the device run are not redundant.** The gate proves the attribute survived the merge. The
device run proves the attribute means what we think it means on the reference handset. `dependency-hygiene`
rule 8 is the general shape of this: a value that resolves from a default keeps compiling today and
breaks on the install that matters.

**The iOS half is different on purpose, and the file says so.** §11 records that
`NSURLIsExcludedFromBackupKey` is deliberately not set, because an iCloud device backup is the user's
own encrypted backup and the thing we exclude is a *vendor* server. So on iOS the catch log may well
survive a reinstall, and that is correct behaviour rather than a bug in this row. §14 row 18 names
`allowBackup=false` and is therefore an Android row. `docs/release/reinstall-and-restore.md` states
both, with the reason, because a procedure that implies the iOS result should match Android's produces
a false failure at 23:00 on release night.

**A skill text and `SPEC.md` disagree about `dataExtractionRules`, and this task follows `SPEC.md`.**
`catchlaw-reference-database/references/two-database-contract.md` says Android excludes the
`files/reference/` directory from backup via `android:dataExtractionRules` or
`android:fullBackupContent`. `SPEC.md` §11 declares `android:allowBackup="false"` and **no**
`dataExtractionRules`. Both are internally consistent, and they solve the same problem at different
levels: with `allowBackup="false"` there is no backup to exclude anything from, so the exclusion rules
the skill describes are unnecessary rather than wrong — they presuppose backup is on. `SPEC.md` is
authoritative for the product (and §14 row 18 names `allowBackup=false` explicitly), so the gate bans
both attributes. This is a gap in the skill text, not a decision to make inside a task: it is recorded
in the epic's Risks for a follow-up correction, and no local convention is invented around it.

**"Completely" is asserted field by field, not by row count.** A restore that lands the right number of
rows with an empty `citation_text` has lost the thing that makes a catch row evidence.
`catchlaw-reference-database` rule 8 lists what a catch row denormalises — `scientific_name`,
`citation_text`, `content_version`, `method`, `measured_mm`, `judged_at` — precisely so a three-year-old
record does not restate itself against today's pack. So the assertion walks those fields.

**The automated case reaches the post-reinstall state by deleting the file, and says so.** An
`integration_test` cannot uninstall its own host. Deleting `user.db` under the support directory
produces the same starting state — an app with no record — which is enough to test the restore path
deterministically on every commit. It is **not** enough to test `allowBackup`, and the file does not
pretend it is: the backup behaviour is a manual row, on hardware, exactly as
`coverage-and-budget.md` prescribes for the export → wipe → import rehearsal.

**Rejected: a checked-in export zip as the fixture.** A binary fixture goes stale the first time the
JSON header gains a field, and then the test asserts that an old format still imports — a different and
less useful claim. The test exports first and imports what it exported, so the fixture is always the
current format. The *manual* run uses a genuinely pre-taken export, because "pre-taken" is the point of
§14's wording.

**Rejected: re-testing E17's parser.** Merge deduplication on `(created_at, species_id, length_mm)`,
CSV BOM handling and PDF rendering belong to E17 and are tested there. This task tests the one thing
E17 could not: that the file survives its own app being removed.

**Rejected: treating the re-extraction of `reference.db` as data loss.** D-6 makes the reference database
disposable and regenerable from the asset. After a reinstall it is extracted again; the only
irreplaceable file is `user.db`. The procedure says which absence is expected and which is a failure, so
an operator does not report the first launch's progress bar as a defect.

## Tests first

Write every row before touching the gate script or the harness. Run them. **They must fail** — the gate
rows because the two new checks do not exist, the integration rows because
`reinstall_restore_test.dart` does not exist. If row 3 passes now, the test is wrong: a gate that greps
for `allowBackup` without pinning the value will match `android:allowBackup="true"` and report success.

| # | Test name | Tier | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `check_release_aab_manifest.sh fails when the merged manifest sets allowBackup to true` | policy | exit `1` | §11's attribute, on the artefact. One library manifest or one merged default is all it takes |
| 2 | `check_release_aab_manifest.sh fails when the merged manifest declares dataExtractionRules` | policy | exit `1` | §11 bans it alongside `allowBackup`. Declaring extraction rules re-opens the door `allowBackup=false` closed, and looks responsible while doing it |
| 3 | `check_release_aab_manifest.sh fails when allowBackup is absent from the merged manifest` | policy | exit `1` | The platform default is `true`. An attribute that silently disappeared during the merge must fail, not pass for want of a match |
| 4 | `check_release_aab_manifest.sh passes when allowBackup is false and no extraction rules are declared` | policy | exit `0` | The pass path must be reachable, or the gate is only ever red |
| 5 | `Catch log is empty after user.db is removed` | integration | `trip` and `catch` counts are `0` | The state a reinstall leaves. Asserted before the restore so a restore that appeared to work on stale data cannot pass |
| 6 | `Import of a pre-taken export restores every trip and every catch` | integration | counts equal the pre-export counts | §14 row 18 clause two, and the reason the promise in §12 is load-bearing |
| 7 | `Restored catch rows keep their scientific name, citation text and content version` | integration | all three equal | "Completely" is a field-level claim. A row count restores the shape and loses the evidence |
| 8 | `Import of a pre-taken export restores saved zones and rule flags` | integration | counts equal | §7.2 lists seven tables; a restore that only walks `trip` and `catch` is incomplete and would pass rows 6 and 7 |
| 9 | `Import writes nothing when the export declares a newer user_db_schema_version` | integration | counts still `0`, error names the version | §12: a newer schema is refused with a clear message rather than partially applied. Partial application on a restore is the worst possible moment for it |
| 10 | `Import writes nothing when the zip is truncated` | integration | counts still `0`, specific error | `coverage-and-budget.md` names feeding import a hand-corrupted file. A restore is the one import a user cannot retry from another copy |
| 11 | `Restored photos resolve to a path that exists` | integration | every `photo_path` resolves | §12 rewrites `photo_path` to relative paths inside the zip. A restore that lands dangling paths looks complete and shows blank frames |

```dart
// app/integration_test/reinstall_restore_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness/walkthrough.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Catch log is empty after user.db is removed', (WidgetTester t) async {
    final Walkthrough walk = await Walkthrough.launch(t);
    await walk.recordSampleTrip();
    final File export = await walk.exportJson();
    expect(export.existsSync(), isTrue);

    await walk.close();
    await walk.deleteUserDatabase(); // the state a reinstall leaves; NOT a test of allowBackup
    final Walkthrough fresh = await Walkthrough.launch(t);

    expect(await fresh.tripCount(), 0);
    expect(await fresh.catchCount(), 0);
  });

  testWidgets('Restored catch rows keep their scientific name, citation text and content version',
      (WidgetTester t) async {
    // … export, wipe, relaunch, import, then compare field by field rather than by count
  });

  // … rows 6, 8, 9, 10, 11
}
```

**Run:** `cd app && flutter test test/policy/release_artifact_gates_test.dart` → 4 new failures, and
`flutter test integration_test/reinstall_restore_test.dart -d <device>` → 7 failures. Any pass now is a
wrong test.

## Implementation outline

1. Add the two fixtures. Derive them by editing a real `aapt2 dump xmltree` output from T01, never by
   hand-writing the format.
2. Extend `tools/gates/check_release_aab_manifest.sh`: assert the `<application>` element carries
   `allowBackup` **with the value `false`** — presence alone is not the check — and assert that neither
   `dataExtractionRules` nor `fullBackupContent` appears. Keep the existing exit-code contract: 2
   missing target, 1 violation, 0 clean.
3. Extend `app/test/policy/release_artifact_gates_test.dart` with the four rows.
4. Add `deleteUserDatabase()` and count helpers to `app/integration_test/harness/walkthrough.dart`
   (T02's file). The delete resolves the path through the same `getApplicationSupportDirectory()` the
   app uses — never a hard-coded path, which would silently pass by deleting nothing.
5. Write rows 5 to 11. Field comparisons walk `catchlaw-reference-database` rule 8's list explicitly.
6. Perform the manual device run on Android: record two trips and four catches, take a full export
   including photos through the **real** share sheet, `adb uninstall <applicationId>`, reinstall the
   same release artefact, screenshot the empty log, import the export, screenshot the restored log,
   compare against the pre-uninstall counts.
7. Perform the same run on iOS and record the result **as it is**: the log may survive via iCloud device
   backup, which §11 makes deliberate. Record which iOS behaviour was observed, so the next release has
   a baseline rather than a surprise.
8. Write `docs/release/reinstall-and-restore.md` with both platforms, the asymmetry and its reason, and
   the note that `reference.db` re-extracting on first launch after reinstall is expected (D-6) and is
   not the data loss this row is about.
9. Re-run the suite. All 11 green, and T01's original 14 rows still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 11 tests pass, and each failed first; T01's rows are untouched and still green.
- [ ] The gate pins `allowBackup` to the literal `false` and fails on its absence as well as on `true`.
- [ ] The manual Android reinstall happened on the physical device named in T08's checklist, and both
      screenshots are committed.
- [ ] The export used for the manual restore was taken **before** the uninstall, through the real share
      sheet, and included photos.
- [ ] Every count and every denormalised field matched after the restore; the comparison is recorded in
      `docs/release/reinstall-and-restore.md`, not merely asserted to have passed.
- [ ] The iOS observation is recorded as observed, with §11's reason beside it, and is not written up as
      a failure.
- [ ] `user.db` was never deleted by the app itself during any of this — a downgrade or a corrupt file
      is refused and reported, never "repaired" (`catchlaw-reference-database` rule 9).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze --fatal-infos && flutter test
cd app && flutter test integration_test/reinstall_restore_test.dart -d <device-id>
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
bash -n tools/gates/check_release_aab_manifest.sh
tools/gates/check_release_aab_manifest.sh app/build/app/outputs/bundle/release/app-release.aab
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(data): prove the catch log does not survive reinstall and that an export restores it

allowBackup="false" is one attribute that has never been observed doing
anything, and its failure mode is invisible until somebody restores a phone and
finds another fisher's trip history on it. The gate now reads it out of the
merged manifest inside the AAB and pins the literal value, because a plugin
manifest can set it and the platform default is true — a grep for the attribute
name alone matches "true" and reports success. The device run then watches it
behave. "Restores it completely" is asserted field by field over the columns a
catch row denormalises, not by row count: a restore with the right shape and an
empty citation_text has lost the thing that makes the row evidence. iOS is
deliberately different — NSURLIsExcludedFromBackupKey is not set — and the
procedure records that rather than reporting it as a failure.

Task: E21/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
