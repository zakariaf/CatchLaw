# E16/T06 — Storage used, and the bulk photo purge

| | |
|---|---|
| **Epic** | E16 — Settings |
| **Branch** | `epic/16-settings` (shared) |
| **Commit** | `feat(settings): show storage used and purge catch photos` |
| **Depends on** | T02 (the screen shell and `SettingsRow`), E13 (catches, `photo_path`, the in-app camera) |
| **Size** | M |
| **Spec** | `SPEC.md` §6 S14 (storage used + bulk photo purge), §4.5 Storage management ("Settings shows bytes used and offers bulk photo purge **that keeps the records**"), §4.5 Photo handling (images inside the app sandbox, never the shared camera roll), §7.2 (`catch.photo_path`), §13 (DB size row: ≈ 8,000 rows ≈ **< 4 MB**, plus ~200 KB per photo) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | The ledger `pair` table this section is built from, tabular end-aligned figures, and the four mandatory states — the byte read has a real loading frame and a real empty case |
| `lonja-dialogs-and-surfaces` | The purge confirmation: a typed result, `barrierDismissible: false`, a label that names the consequence, and why the eight-second undo pattern does not apply to a file unlink |
| `lonja-buttons` | `destructive` is oxblood, is never the screen's primary, always confirms, and a disabled control states its reason in adjacent prose |
| `catchlaw-conventions-index` | Rule 7 — `user.db` is the only writable and the only irreplaceable file; this task is the one that deletes from it |
| `persistence-drift` | The transaction that nulls `photo_path` across every catch, and the count query behind the figures |
| `error-handling-typed-results` | What a partial purge returns, and how a failed unlink surfaces without lying about what was deleted |
| `i18n-rtl-l10n` | The photo-count plural: six ICU categories in `ar`, a `many` category in `es`, `ca` and `pt_BR` |
| `flutter-performance` | The directory walk is off the build; the figures come from a `FutureProvider`, not from `build()` |
| `accessibility-as-code` | The destructive control's accessible name, and the disabled state's reason being read out |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.5, Storage management row | "Settings shows bytes used and offers bulk photo purge that keeps the records" — the whole task, and the word "keeps" is the constraint |
| `SPEC.md` | §4.5, Photo handling row | Images are written inside the app sandbox and never into the shared camera roll — so the purge has exactly one directory to sweep |
| `SPEC.md` | §7.2, `catch` DDL | `photo_path TEXT` is nullable; nulling it is a legal state and does not touch any other column |
| `SPEC.md` | §13, DB size row | "5 yrs × 200 trips × 8 catches ≈ 8,000 rows ≈ **< 4 MB**, plus ~200 KB per photo. Photos are the only real growth" — the numbers this screen exists to make visible |
| `SPEC.md` | §6 S14 | "storage used + bulk photo purge" — its place in the element order |
| `SPEC.md` | §9.5, Plurals | `ar` needs all six ICU categories; `es`, `ca` and `pt` carry a `many`; only `gl` is `one`/`other` |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | Rules 4, 5, 6, 7 | Tabular end-aligned numerics; ruled ledgers, never zebra; an authored empty state; the four states and which are exclusive |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The ledger table — column classes"; the `pair` class | The label/value table the byte figures render in, and why it is a `Table` rather than a `Row` per line |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | Precedence; Loading skeleton | `CircularProgressIndicator` is banned; the skeleton is the real row's shape; determinate progress is allowed in exactly one place and this is not it |
| `.claude/skills/lonja-dialogs-and-surfaces/SKILL.md` | Rules 2, 3, 4, 9, 12 | Typed result, consequence-naming labels, explicit `barrierDismissible: false`, the deferred-write undo window, no I/O behind a barrier |
| `.claude/skills/lonja-dialogs-and-surfaces/references/modal-decision-matrix.md` | §2 the matrix; §5 destructive labels; §6 typed results | "Reset the user database — yes — modal, typed confirm — `false` — `ResetOutcome`"; the confirm/cancel label pairs; `enum` for a closed choice |
| `.claude/skills/lonja-buttons/SKILL.md` | Rules 9, 12 | Destructive is oxblood, never primary, always confirms; a disabled control states its reason in adjacent prose |
| `.claude/skills/lonja-buttons/references/variant-ladder-and-states.md` | The ladder; "Disabled: the reason is part of the state" | `destructive` is earned when a row leaves the writable user database; the disabled reason is a sibling line, not a tooltip |
| `.claude/skills/catchlaw-conventions-index/SKILL.md` | Rule 7 | `user.db` is the only writable and the only irreplaceable database |
| `epics/DECISIONS.md` | D-3 | Six locales for the new keys, including the plural |
| `epics/CONVENTIONS.md` | §5, §9 | Test naming; the invariants |

## What this delivers

- `app/lib/data/services/storage_usage_service.dart` — `StorageUsageService`, returning
  `StorageUsage(userDbBytes, photoBytes, photoCount)`. It sums `user.db` and its `-wal` and `-shm`
  siblings when present, and walks the photo directory once.
- `app/lib/domain/use_cases/catch_photo_purge_use_case.dart` — `CatchPhotoPurgeUseCase`, which nulls
  `photo_path` on every catch inside one transaction and then unlinks the files.
- `app/lib/ui/settings/widgets/settings_storage_section.dart` — `SettingsStorageSection`: a ledger
  `pair` table of the three figures and the `LonjaButton.destructive`.
- `app/lib/ui/settings/widgets/photo_purge_dialog.dart` — `PhotoPurgeDialog` returning
  `enum PhotoPurgeOutcome { purged, kept, dismissed }`.
- ARB keys in all six locales: `settingsSectionStorage`, `settingsStorageDatabaseLabel`,
  `settingsStoragePhotosLabel`, `settingsStorageTotalLabel`, `settingsStoragePhotoCount` (**plural**),
  `settingsNoPhotosStored`, `actionDeleteEveryCatchPhoto`, `settingsPurgeTitle`, `settingsPurgeBody`,
  `settingsPurgeKeepPhotos`, `settingsPurgeDone`.
- `app/test/data/services/storage_usage_service_test.dart`,
  `app/test/domain/use_cases/catch_photo_purge_use_case_test.dart`,
  `app/test/ui/settings/settings_storage_section_test.dart`.

## Why it is built this way

**The purge keeps every record.** `SPEC.md` §4.5 says "bulk photo purge that keeps the records", and
`SPEC.md` §7.2's note on the `catch` table explains why the record matters more than the image: a
three-year-old catch "must still say what it said when it was recorded". A photo is 200 KB of evidence
the user chose to attach; the row is the history. So the purge sets `photo_path = NULL` and deletes
nothing else — no `catch` row, no trip, no flag. Row 2 is the test, and it counts rows before and after.

**The column is nulled first, inside a transaction; the files are unlinked after.** Two orderings, two
failure modes:

| Order | Crash mid-way leaves | Consequence |
|---|---|---|
| files first, then the column | `photo_path` values pointing at files that are gone | S11 renders a broken image on a record the user cannot repair |
| **the column first, then the files** | orphan files with no row referring to them | wasted bytes, visible in the same figures, removed by the next purge |

The second is strictly recoverable and the first is not, so the column goes first. The unlink sweep is
by directory listing rather than by the paths it just erased, so an orphan from a previous interrupted
purge is collected too. Row 5 kills the process between the two halves and asserts the recoverable
state.

**A purge is confirmed by a modal, not softened by an undo.** `lonja-dialogs-and-surfaces` rule 9's
eight-second deferred write exists so a deleted *row* can come back. An unlinked file cannot. So this
is `showLonjaDialog<PhotoPurgeOutcome>` with `barrierDismissible: false` (rule 4 — a stray wet-hand tap
must not resolve it) and a typed result (rule 2 — `bool?` collapses confirmed, declined and
barrier-dismissed into two values and a null the caller treats as "no"). The confirm label names the
count: `Delete 132 photos`. The cancel names the preservation: `Keep the photos`
(`modal-decision-matrix.md` §5). No `OK`, no `Cancel`, no `Confirm` — `check_lonja_dialogs.sh` fails
those literals.

**The figures are real bytes, not an estimate.** `SPEC.md` §13 budgets ~8,000 rows under 4 MB and
~200 KB per photo, and says "photos are the only real growth". A screen that multiplied a photo count
by 200 KB would be describing the budget rather than the device. `StorageUsageService` stats the files.

**The read is off the build path.** A directory walk over a few hundred files is not free on the
low-end Android target of `SPEC.md` §13. The figures come from a `FutureProvider`; its `AsyncLoading`
renders the ruled skeleton of the same table (`the-four-states.md`, Loading skeleton), never a spinner
— a spinner in a 100% offline app is network language, and this is the one screen where a user is
already wondering what the app is doing with their data.

**Zero photos: the control stays, disabled, with its reason.** `lonja-buttons` rule 9 and
`variant-ladder-and-states.md`'s "Disabled: the reason is part of the state": the field goes
paper-sunk, the label ink-faint, and one adjacent line reads "No photos are stored on this device".
**Rejected: removing the button**, which makes the screen a different shape on different visits and
moves the destructive control out from under the thumb that learned where it was.

**The photo directory is known in exactly one place.** E13 writes photos into the app sandbox
(`SPEC.md` §4.5). If E13 already has a service that owns that path, this task uses it; if the path is
inlined at the camera call site, this task extracts it. Two definitions of "the photo directory" is how
a purge sweeps the wrong folder — see the definition of done.

**`SELECT` counts, not `photo_path IS NOT NULL` in Dart.** The count and the byte sum are both queries
or file stats; nothing loads a list of catches into memory to count them. At 8,000 rows that is the
difference between a frame and a stall.

## Tests first

Write every row before touching the service, the use case or the widgets. Run them. **They must
fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `StorageUsageService.read sums user.db and its -wal and -shm siblings` | a db file plus a `-wal` | the sum, not the main file alone | The `-wal` can be the larger of the two after a heavy session; reporting only `user.db` understates what the user is being asked about |
| 2 | `CatchPhotoPurgeUseCase.run leaves every catch row in place` | 40 catches, 12 with photos | `SELECT COUNT(*) FROM catch` is 40 before and after | `SPEC.md` §4.5's "keeps the records" — the one thing this feature must not get wrong |
| 3 | `CatchPhotoPurgeUseCase.run sets photo_path to NULL on every catch` | 12 with photos | zero non-null `photo_path` values | The other half; a purge that deletes files and leaves the column is the broken-image defect |
| 4 | `CatchPhotoPurgeUseCase.run unlinks every file in the photo directory` | 12 files | the directory is empty | The bytes must actually go; a purge that only nulls the column leaves the storage figure unchanged and the user rightly distrusts the screen |
| 5 | `CatchPhotoPurgeUseCase.run leaves no photo_path pointing at a missing file when the unlink fails` | an unlink that throws on file 7 | every `photo_path` is `NULL`, files 8–12 remain | The ordering argument, executed: a crash between the halves must leave orphans, never dangling references |
| 6 | `CatchPhotoPurgeUseCase.run keeps outcome, outcome_detail and rule_citation_ref` | one catch with all three set | all three unchanged | §7.2's denormalised history columns; a purge that touched them would rewrite what a three-year-old record said |
| 7 | `CatchPhotoPurgeUseCase.run collects an orphan file left by an interrupted purge` | one file with no referring row | the file is gone | The sweep is by directory listing, not by the paths it just erased |
| 8 | `SettingsStorageSection renders bytes with tabular figures` | 3.6 MB / 2.4 MB | mono, `TextAlign.end` | `lonja-lists-and-tables` rule 4 — proportional digits wobble down the column and cannot be compared |
| 9 | `SettingsStorageSection disables the purge action when the photo count is zero` | 0 photos | disabled, and the reason line renders | `lonja-buttons` rule 9; a screen whose destructive control appears and disappears moves it out from under the thumb |
| 10 | `PhotoPurgeDialog names the photo count in its confirm label` | 132 photos | the label contains `132` | `modal-decision-matrix.md` §5 — a label that does not state its own effect is confirmed by muscle memory |
| 11 | `PhotoPurgeDialog returns PhotoPurgeOutcome.dismissed when the route is popped` | pop without a choice | `dismissed`, and no purge runs | Rule 2: a `bool?` would make the barrier tap indistinguishable from a decline, and null would fall through to a write |
| 12 | `PhotoPurgeDialog sets barrierDismissible to false` | pump, tap the barrier | the dialog is still up | Rule 4, explicitly, because relying on the Flutter default makes the policy invisible in the diff |
| 13 | `SettingsStorageSection renders the skeleton and not a spinner while the figures load` | pending future | no `CircularProgressIndicator`, the ruled skeleton present | `the-four-states.md` — a spinner here reads as a network call on the one screen about the user's own data |
| 14 | `ar - SettingsStorageSection renders the photo count with all six plural categories` | counts 0, 1, 2, 3, 11, 100 | six distinct `ar` strings | `SPEC.md` §9.5: an `ar` ARB entry missing a category is a build failure, and 2 and 3 are the two English speakers forget |
| 15 | `SettingsStorageSection reads the figures once per build` | rebuild the screen twice | the service is called once | The walk is off the build path; a `FutureProvider` recreated in `build()` re-walks the directory on every frame |
| 16 | `glove - PhotoPurgeDialog action row measures 56 dp` | `gloveMode: true` | ≥ 56 | `surfaces-and-plates.md` §8 — glove raises the dialog action row from 48 to 56 dp |

```dart
// app/test/domain/use_cases/catch_photo_purge_use_case_test.dart
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CatchPhotoPurgeUseCase.run leaves every catch row in place', () async {
    final db = UserDatabase(NativeDatabase.memory());
    final dir = await Directory.systemTemp.createTemp('catchlaw_photos');
    await seedCatches(db, total: 40, withPhotosIn: dir, photos: 12);

    final before = await countCatches(db);
    await CatchPhotoPurgeUseCase(catches: CatchRepositoryDrift(db), photoDir: dir).run();
    final after = await countCatches(db);

    expect(before, 40);
    expect(after, 40);                       // SPEC 4.5: the purge keeps the records
    await db.close();
    await dir.delete(recursive: true);
  });

  test('CatchPhotoPurgeUseCase.run leaves no photo_path pointing at a missing file '
      'when the unlink fails', () async {
    // The column is committed first, so an unlink that throws leaves orphan FILES,
    // never a row referring to a file that is gone.
    // …
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/data/services/storage_usage_service_test.dart
test/domain/use_cases/catch_photo_purge_use_case_test.dart test/ui/settings/settings_storage_section_test.dart`
→ 16 failures. If any passes now, the test is wrong.

## Implementation outline

Only after the tests are red.

1. `storage_usage_service.dart` — stat `user.db`, `user.db-wal`, `user.db-shm` (each guarded by
   `existsSync`), then one `Directory.list()` over the photo directory accumulating length and count.
   Returns a `const`-constructible record type with `==`.
2. Resolve the photo directory. If E13 owns it behind a service, depend on that; if it is inlined,
   extract it to one place in this commit and point E13's camera write at it. One definition only.
3. `catch_photo_purge_use_case.dart` — `transaction { update(catch)..write(photoPath: Value(null)) }`,
   awaited to commit, **then** the directory sweep, unlinking each file and collecting failures into a
   typed result rather than throwing on the first one.
4. `photo_purge_dialog.dart` — `showLonjaDialog<PhotoPurgeOutcome>` with `barrierDismissible: false`
   explicitly, a `FocusScope` autofocusing the non-destructive action
   (`modal-decision-matrix.md` §4), and the opener refocused after the pop.
5. `settings_storage_section.dart` — a `Table` in the `pair` class with the three figures, and the
   `LonjaButton.destructive` below it, disabled with its reason at zero photos. Figures from a
   `FutureProvider` declared at file scope, not built inside `build()`.
6. ARB: eleven keys in six files, with `settingsStoragePhotoCount` carrying `zero`, `one`, `two`,
   `few`, `many`, `other` in `app_ar.arb`, a `many` in `es`, `ca` and `pt_BR`, and `one`/`other` in
   `gl` and `en` (`SPEC.md` §9.5).
7. Re-run the whole suite, including E13's catch tests.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 16 rows pass, and each failed first.
- [ ] `grep -rn "photos" app/lib --include=*.dart | grep -i "Directory("` shows the photo directory
      resolved in exactly one file.
- [ ] `grep -rn "delete()" app/lib/domain/use_cases/catch_photo_purge_use_case.dart` shows no delete
      against the `catch` table — only `photo_path` writes and file unlinks.
- [ ] `settingsStoragePhotoCount` has all six ICU categories in `app_ar.arb` and a `many` category in
      `app_es.arb`, `app_ca.arb` and `app_pt_BR.arb` (`SPEC.md` §9.5).
- [ ] `check_lonja_dialogs.sh` clean: no `bool` result, no banned literal, `barrierDismissible: false`
      explicit.
- [ ] The purge button is `destructive`, not primary; `SettingsScreen` still builds zero
      `LonjaButtonVariant.primary`.
- [ ] Golden lanes: `en` paper with photos, `en` paper with zero photos (the disabled state), `ar`
      paper, `ar` paper glove, `en` sunlight, plus the loading skeleton lane with reduced motion.
- [ ] Nothing in this task renders a `CircularProgressIndicator`, a percentage or a cloud glyph.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh  app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh               app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh        app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
tools/gates/no_directional_geometry.sh                                    app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(settings): show storage used and purge catch photos

The figures are stat'ed bytes, not a photo count multiplied by the 200 KB
estimate in SPEC 13 — that number is a budget, and a screen about the
user's own device has to describe the device.

The purge nulls catch.photo_path inside a transaction, commits, and only
then unlinks the files. The other ordering leaves photo_path values
pointing at files that are gone, which renders a broken image on a record
the user cannot repair; this ordering leaves orphan files, which are
visible in the same figures and are collected by the next sweep. Every
catch row, and every denormalised history column on it, is untouched
(SPEC 4.5).

There is no undo, because an unlinked file cannot come back. So it is a
barrier-false typed confirm whose label names the count — "Delete 132
photos" — rather than a snackbar with an eight-second window that would
promise a restore this feature cannot perform.

Task: E16/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
