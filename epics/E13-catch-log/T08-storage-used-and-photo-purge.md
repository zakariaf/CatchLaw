# E13/T08 — Storage used, and a purge that keeps the records

| | |
|---|---|
| **Epic** | E13 — The catch log |
| **Branch** | `epic/13-catch-log` (shared) |
| **Commit** | `feat(log): report bytes used and purge photos without losing a record` |
| **Depends on** | T04 (`PhotoStore` and the photo directory), T07 (the pending-delete set the sweep must respect) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.5 (Storage management), §6 S14 ("storage used + bulk photo purge"), §13 (8,000 rows under 4 MB, ~200 KB per photo), §12 (the raw-database escape hatch S14 also offers) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `persistence-drift` | Rules 9 and 10: bytes live on disk with a relative path, and a database is measured through `VACUUM INTO` and never `File.copy`d live. |
| `lonja-dialogs-and-surfaces` | Rules 2, 3, 4 and `references/modal-decision-matrix.md` §2, §3, §5, §6 — this is the one destructive action in the epic with **no** undo, so the typed result and the consequence-naming label carry all the weight. |
| `lonja-lists-and-tables` | `references/row-and-table-anatomy.md`'s settings-row and `pair` column classes, and the tabular-figure rule the byte figures depend on. |
| `error-handling-typed-results` | Rules 3, 4, 5: the purge returns a typed report rather than throwing, and a failed unlink is a value the panel can state. |
| `catchlaw-reference-database` | `references/two-database-contract.md` — `user.db` is ~200 KB and irreplaceable while `reference.db` is ~40 MB and disposable; the figure S14 shows must not confuse the two. |
| `catchlaw-conventions-index` | Invariant 4 and rule 11: the storage state is never colour alone, and nothing here uploads, syncs or reports a byte anywhere. |
| `accessibility-as-code` | Rules 5 and 8: a byte figure at 200% scale is where `FittedBox` gets reached for. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.5 row "Storage management" | "Settings shows bytes used and offers bulk photo purge that keeps the records" |
| `SPEC.md` | §6 S14 | The element list: "storage used + bulk photo purge" sits between the mode toggles and export |
| `SPEC.md` | §13 row "DB size at realistic usage" | 5 yrs × 200 trips × 8 catches ≈ 8,000 rows ≈ **< 4 MB**, plus ~200 KB per photo; "photos are the only real growth" |
| `SPEC.md` | §12 "Manual escape hatch" | S14 also shows the on-device path of `user.db` — the same panel, so the figures must name the right file |
| `$FLUTTER_SKILLS/persistence-drift/references/backup-and-wal.md` | the checkpoint → `VACUUM INTO` → verify-by-reopen primitive | How to measure a live WAL database without corrupting it |
| `$FLUTTER_SKILLS/persistence-drift/references/schema-and-daos.md` | "Blobs are files on disk, paths relative" | The `ref_count`/GC sweep idea this task adapts to a one-owner column |
| `.claude/skills/lonja-dialogs-and-surfaces/references/modal-decision-matrix.md` | §2, §3, §5, §6 | The "Reset the user database" row is the closest precedent: modal, typed confirm, `barrierDismissible: false` |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The settings row", "The ledger table — column classes", "Numeric alignment and RTL mirroring" | 58 dp / 68 dp glove, the `pair` class, tabular figures and `TextAlign.end` |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "Ownership matrix" | `reference.db` is 40 MB and regenerable; `user.db` is ~200 KB and irreplaceable |
| `epics/E13-catch-log/epic.md` | "Follow-ups deliberately not in this PR" | E16 mounts this panel into S14 and does not re-implement it |

## What this delivers

- `app/lib/domain/models/storage_usage.dart` — `StorageUsage(userDbBytes, photoBytes, photoCount,
  catchCount, tripCount, userDbPath)`.
- `app/lib/domain/use_cases/storage_usage_use_case.dart`.
- `app/lib/domain/use_cases/purge_photos_use_case.dart` — returns `PurgeReport(rowsCleared,
  filesDeleted, filesLeft)`.
- `app/lib/data/services/photo_store.dart` — extended with `totalBytes()`, `listRelativePaths()`,
  `delete(relativePath)` and `sweepOrphans(Set<String> referenced)`.
- `app/lib/data/repositories/catch_log_repository.dart` — `clearAllPhotoPaths()` on the interface,
  returning the set of relative paths it cleared; and `referencedPhotoPaths()` for the sweep.
- `app/lib/ui/settings/widgets/storage_usage_panel.dart` — the figures and the purge action.
  **E16 mounts this widget into S14. E16 does not re-implement it.**
- `app/lib/ui/settings/widgets/purge_photos_dialog.dart` — returning
  `enum PurgeOutcome { purged, kept, dismissed }`.
- ARB keys ×6 for both figures, the purge action, the dialog title, body and both labels, and the
  report line.
- Tests: `app/test/domain/use_cases/storage_usage_use_case_test.dart`,
  `app/test/domain/use_cases/purge_photos_use_case_test.dart`,
  `app/test/data/services/photo_store_sweep_test.dart`,
  `app/test/data/services/user_db/user_db_size_test.dart`,
  `app/test/ui/settings/storage_usage_panel_test.dart`.

## Why it is built this way

**Two figures, not one, because they behave completely differently.** §13 says it plainly: 8,000 rows
of trips and catches fit in under 4 MB, and *"photos are the only real growth"* at roughly 200 KB
each. A single "storage used" number hides the only fact that matters — that deleting photos reclaims
almost everything and deleting records reclaims almost nothing. The panel shows the database figure
and the photo figure separately, with the photo count beside it, so the purge action has a number
attached to it before it is tapped.

**The database figure counts the sidecars.** A WAL-mode `user.db` is a main file plus `-wal` plus
`-shm`, and a fisher looking at 180 KB while the `-wal` holds another 2 MB is being told something
untrue. The reported figure is the sum. **Rejected:** running `PRAGMA wal_checkpoint(TRUNCATE)` before
measuring to make the number tidier — that is a write, and a Settings screen must not mutate the only
irreplaceable file in the product to render a label.

**The reference database is not in the figure.** `two-database-contract.md`'s ownership matrix:
`reference.db` is ~40 MB, generated, disposable and regenerable by deleting it. Folding it into
"storage used" beside a purge action would invite the fisher to try to reclaim it, and there is
nothing here that can. If it is ever shown it is a separate line, labelled as the rule book, with no
action attached.

**The purge clears rows first and unlinks files second.** If the files went first and the process died
before the rows were cleared, every affected record would point at a file that no longer exists — and
`persistence-drift` rule 9 names that failure exactly: the row survives, the tile renders blank
forever, and nothing errors. In this order the crash window leaves **orphan files**, which cost bytes
and are reclaimed by the sweep in the same use case. It is the same argument T04 makes for the capture
path and E17's PR body makes for its Replace path; three places, one rule: unlink last, always.

**A failed unlink is a report, not a failure.** The records are already safe once the transaction
commits, so an `Err` here would be a lie about what happened. `PurgeReport` carries how many rows were
cleared, how many files went and how many are left, and the panel states the leftover count. The next
sweep collects them.

**The orphan sweep is what makes T04 and T07 affordable.** T04 leaves a file behind when a capture is
never attached to a catch; T07 leaves one when the process dies between the row delete and the unlink.
Both are deliberate — the alternative in each case was a row pointing at nothing. The sweep deletes
every file under `photos/` that no catch row references, which reclaims both classes with one pass.

**The sweep reads rows, including rows inside T07's undo window.** A pending delete has not been
written, so the row is still there and its photo is still referenced. Test 14 pins this: sweeping
during an undo window must not delete the photo of a row the fisher is about to restore.

**The purge is the one destructive action in this epic with no undo, and the dialog says so.** A row
can be held in memory for ten seconds; a directory of photos cannot. So there is no deferred write and
no snackbar action — instead the confirmation is a modal with `barrierDismissible: false`, a typed
`PurgeOutcome` whose `dismissed` case writes nothing, and a confirm label that names both halves of
the consequence: **Delete every photo, keep every record**, against **Keep the photos**.
`modal-decision-matrix.md` §5 bans `OK` and `Cancel` and requires the cancel label to name the
preservation.

**8,000 rows under 4 MB is a test, not an aspiration.** §13 gives the shape (5 years × 200 trips × 8
catches) and the ceiling. The test seeds it, takes a `VACUUM INTO` copy — `persistence-drift` rule 10
forbids `File.copy` of a live WAL database, which is torn and unrestorable — and measures that. If it
fails, the fix is a schema conversation with E05 and a `DECISIONS.md` entry, not a looser assertion.

`backup-and-wal.md`'s primitive begins with `PRAGMA wal_checkpoint(TRUNCATE)`, which is a write, so it
lives **only** in that test against a fixture database. The Settings figure of test 2 does none of
it — that path reads three file lengths and nothing else.

## Tests first

Write every row before touching `purge_photos_use_case.dart`. Run them. **They must fail.** A row that
passes now is testing nothing.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `StorageUsageUseCase reports the user database size including its WAL sidecars` | a DB with a non-empty `-wal` | main + `-wal` + `-shm` bytes | A figure that ignores the sidecars understates the file by megabytes and is simply untrue |
| 2 | `StorageUsageUseCase does not checkpoint the database to measure it` | measure twice | the file's mtime is unchanged | A Settings label must not write to the only irreplaceable file in the product |
| 3 | `StorageUsageUseCase excludes the reference database from the figure` | both files present | only `user.db` counted | `reference.db` is 40 MB and disposable; counting it invites a reclaim attempt nothing here can serve |
| 4 | `StorageUsageUseCase totals every file under the photos directory` | 3 photos | the sum of their lengths and a count of 3 | The number the purge action is attached to |
| 5 | `StorageUsageUseCase reports zero photo bytes when the directory does not exist` | fresh install | 0 bytes, 0 photos, no throw | First launch, before any capture. A directory-not-found throw here is a Settings screen that crashes on a new device |
| 6 | `StorageUsageUseCase reports the catch and trip counts separately from the byte figures` | 12 catches, 2 trips | both counts present | §13's "photos are the only real growth" is only legible if records and bytes are shown apart |
| 7 | `PurgePhotosUseCase leaves every catch row in place` | 40 catches, 12 with photos | row count still 40 | §4.5's exact promise: "bulk photo purge **that keeps the records**" |
| 8 | `PurgePhotosUseCase nulls photoPath on every catch that had one` | as above | 12 rows with `photo_path` NULL | The other half; without it the rows point at deleted files |
| 9 | `PurgePhotosUseCase changes no other column on an affected row` | as above | every other column byte-identical | A purge that bumps `updated_at` on 12 rows would lose 12 merges in E17 for no reason |
| 10 | `PurgePhotosUseCase deletes every photo file` | 12 files | the directory is empty | The reclaim actually happening |
| 11 | `PurgePhotosUseCase clears the rows before it unlinks any file` | a `PhotoStore` that records the call order | rows cleared, then files | The ordering argument. The other order leaves rows pointing at nothing — permanent and silent |
| 12 | `PurgePhotosUseCase reports the files it could not delete` | store failing on 2 of 12 unlinks | `PurgeReport(rowsCleared: 12, filesDeleted: 10, filesLeft: 2)`, `Ok` | The records are already safe, so an `Err` would misdescribe what happened; the leftovers are the sweep's job |
| 13 | `PurgePhotosUseCase rolls back the row clear entirely when the transaction fails` | forced violation | `Err`, `dumpAllRows()` byte-identical, every file still present | A half-cleared purge leaves some rows pointing at files that are about to be deleted |
| 14 | `PhotoStore.sweepOrphans keeps a photo referenced by a catch inside its undo window` | T07 pending delete at 5 s | the file survives | A pending delete is an unwritten delete: the row is still there and the fisher may still tap undo |
| 15 | `PhotoStore.sweepOrphans deletes a file no catch references` | one abandoned capture | file gone | T04's abandoned-capture class, which is deliberate and needs a reclaim path |
| 16 | `PhotoStore.sweepOrphans keeps a file a catch references` | one attached photo | file present | The guard on case 15; a sweep that is slightly too eager destroys a fisher's photo with no undo |
| 17 | `UserDatabase holds 8,000 catches across 200 trips in under 4 MB` | seeded fixture, `VACUUM INTO` | measured size < 4 MB | `SPEC.md` §13's number, verbatim. A failure here is a schema conversation, not a looser assertion |
| 18 | `PurgePhotosDialog sets barrierDismissible to false and returns a typed outcome` | open, tap the barrier | nothing pops; back returns `PurgeOutcome.dismissed` | This is the one destructive action with no undo, so a stray wet-hand tap must not resolve it |
| 19 | `PurgePhotosDialog names both halves of the consequence in its confirm label` | open | "Delete every photo, keep every record" and "Keep the photos" | `modal-decision-matrix.md` §5; `check_lonja_dialogs.sh` fails on `OK`/`Cancel` |
| 20 | `StorageUsagePanel end-aligns both byte figures with tabular figures` | any usage | mono, tabular, `TextAlign.end` | Proportional digits make two figures wobble down the column so they cannot be compared at a glance |
| 21 | `ar - StorageUsagePanel renders byte figures in the resolved numeral system` | `ar` locale | numerals per the S14 numeral-system setting | §9.3's numeral lever; a hardcoded `'$n'` never shows Arabic-Indic digits |
| 22 | `Storage-used label exists in <locale>` (loop over `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`) | each ARB file | key present and non-empty | D-3, and §14's static check |

```dart
// app/test/domain/use_cases/purge_photos_use_case_test.dart
void main() {
  test('PurgePhotosUseCase leaves every catch row in place', () async {
    await seedCatches(db, count: 40, withPhotos: 12);

    final report = await useCase.run();

    expect((report as Ok).value.rowsCleared, 12);
    expect(await db.select(db.catches).get(), hasLength(40)); // SPEC §4.5: keeps the records
    expect(await store.listRelativePaths(), isEmpty);
  });

  test('PurgePhotosUseCase clears the rows before it unlinks any file', () async {
    final store = RecordingPhotoStore();
    await PurgePhotosUseCase(db: db, store: store).run();

    // The other order leaves rows pointing at nothing: permanent, silent, unreportable.
    expect(store.firstUnlinkHappenedAfterCommit, isTrue);
  });

  test('PurgePhotosUseCase reports the files it could not delete', () async {
    final store = FailingPhotoStore(failOn: 2);
    final result = await PurgePhotosUseCase(db: db, store: store).run();

    expect(result, isA<Ok<PurgeReport, StorageFailure>>()); // the records are safe
    expect((result as Ok).value.filesLeft, 2);              // and the sweep will collect them
  });
}
```

```dart
// app/test/data/services/photo_store_sweep_test.dart
test('PhotoStore.sweepOrphans keeps a photo referenced by a catch inside its undo window', () {
  fakeAsync((async) {
    pendingDeletion.beginDelete(kCatchWithPhotoId);
    async.elapse(const Duration(seconds: 5));   // the row has NOT been written away yet

    unawaited(store.sweepOrphans(referencedPhotoPathsFrom(db)));
    async.flushMicrotasks();

    expect(store.exists(kPhotoPath), isTrue);   // undo must still restore a complete record
  });
});
```

```dart
// app/test/data/services/user_db/user_db_size_test.dart
test('UserDatabase holds 8,000 catches across 200 trips in under 4 MB', () async {
  await seedRealisticUsage(db, trips: 200, catchesPerTrip: 40); // SPEC §13's five-year shape

  // VACUUM INTO, never File.copy: a live WAL database copied raw is torn and unrestorable.
  final measured = await vacuumIntoTempFile(db);

  expect(measured.lengthSync(), lessThan(4 * 1024 * 1024));
});
```

**Run:** `cd app && flutter test test/domain/use_cases test/data/services test/ui/settings` →
22 failures.

## Implementation outline

1. Extend `PhotoStore` (T04's file) with `totalBytes()`, `listRelativePaths()`, `delete()` and
   `sweepOrphans()`. It remains the only file that joins a photo path.
2. `storage_usage.dart` and `storage_usage_use_case.dart` — pure reads. The database figure sums the
   main file and both sidecars if they exist; it opens nothing and writes nothing.
3. `purge_photos_use_case.dart` — the ordering:

   ```
   final cleared = await repo.clearAllPhotoPaths();   // ONE transaction, commits first
   final report  = await store.deleteAll(cleared);    // then unlink, collecting failures
   await store.sweepOrphans(await repo.referencedPhotoPaths());
   return Ok(report);
   ```
   `clearAllPhotoPaths()` writes only `photo_path`; it does not touch `updated_at` (test 9).
4. `purge_photos_dialog.dart` — the filename matters for `check_lonja_dialogs.sh`.
   `barrierDismissible: false`, `PurgeOutcome`, `autofocus` on **Keep the photos**, focus restored to
   the opener behind an `if (!context.mounted) return;`.
5. `storage_usage_panel.dart` — a `pair`-class `Table`: the database figure, the photo figure with its
   count, the `user.db` path from §12's escape hatch, and one `LonjaButton.destructive` for the purge.
   Every figure mono, tabular, `TextAlign.end`, formatted through the locale's `NumberFormat` so §9.3's
   numeral lever applies.
6. Run the sweep at one more moment besides the purge: after T07's pending delete commits. Wire it
   there rather than on app start — a sweep on the launch path costs directory I/O against the
   `< 1.2 s` cold-start budget of §13.
7. Re-run the whole suite, including T04's `PhotoStore` tests and T07's pending-deletion tests.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 22 tests pass, and each failed first.
- [ ] A purge changes no row count and changes no column but `photo_path`.
- [ ] Rows are cleared and committed strictly before the first unlink.
- [ ] The sweep never deletes a photo referenced by a row inside T07's undo window.
- [ ] The storage figure includes `user.db`'s `-wal` and `-shm`, excludes `reference.db`, and is
      produced without writing to any database.
- [ ] 8,000 catches across 200 trips measure under 4 MB via `VACUUM INTO`; no `File.copy` of a live
      database exists anywhere in `app/lib`.
- [ ] The purge dialog returns `PurgeOutcome`, sets `barrierDismissible: false` explicitly, and its
      labels name the consequence and the preservation.
- [ ] `StorageUsagePanel` is a widget E16 can mount unchanged; nothing in it imports
      `app/lib/ui/settings/settings_screen.dart`.
- [ ] Every figure is tabular, end-aligned, and formatted through the locale's `NumberFormat`.
- [ ] Every new label exists in all six locales of D-3 and none of them instructs.

## Gates

```bash
dart format --set-exit-if-changed .
cd app && flutter analyze && flutter test && cd ..
grep -rnE "\.copy\(" app/lib/data                      # no File.copy of a database
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh    app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                 app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh    app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-persistence-bans.sh         app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

This is the last task of E13. After the commit, open the PR from `epics/E13-catch-log/epic.md`'s
"PR description" section and follow `CONVENTIONS.md` §1 steps 3–5.

## Commit

```
feat(log): report bytes used and purge photos without losing a record

Two figures, not one. SPEC §13 says 8,000 rows of trips and catches fit under
4 MB and that photos are the only real growth at ~200 KB each, so a single
"storage used" number would hide the only fact that matters: deleting photos
reclaims nearly everything and deleting records reclaims nearly nothing. The
database figure sums the main file and both WAL sidecars, and it is produced
without checkpointing — a Settings label must not write to the one
irreplaceable file in the product.

The purge clears the rows in one transaction, commits, and only then unlinks.
The other order leaves records pointing at files that no longer exist, which
renders blank forever and errors never. This order leaves orphan files, which
the sweep in the same use case reclaims — along with the captures T04
abandons and the leftovers T07's crash window creates.

The sweep reads rows, so a photo belonging to a catch inside T07's ten-second
undo window is still referenced and survives. Undo must restore a complete
record, not a record with a hole in it.

This is the one destructive action in the epic with no undo — a directory of
photos cannot be held in memory the way a row can — so the confirmation names
both halves: delete every photo, keep every record.

Task: E13/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
