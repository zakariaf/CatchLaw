# E17/T06 — Import preview, and the merge rule

| | |
|---|---|
| **Epic** | E17 — Export and import |
| **Branch** | `epic/17-portability` (shared) |
| **Commit** | `feat(import): preview an import before writing, and merge with existing records winning` |
| **Depends on** | T01 (the envelope and its decoder), T04 (the zip and the relative photo paths) |
| **Size** | L |
| **Spec** | `SPEC.md` §12 (import; the Merge rule), §6 S16, §7.2 (`user.db` schema and its UNIQUE constraints), §4.5 (photos live in the sandbox) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `persistence-drift` | The merge runs as one drift transaction over five tables with a foreign key between two of them; this skill owns DAOs, transactions and the batch insert |
| `error-handling-typed-results` | Every step returns `Failure`; the preview is what makes a failure *visible before* it can do damage |
| `catchlaw-conventions-index` | Invariant 11 — no identifier ever leaves or enters the device; an imported file carries no device id, and the merge must not invent one |
| `catchlaw-verdict-contract` | Imported `outcome_detail` strings are user-visible sentences that came from another device. Rules 1 and 2 bind them, and the preview is where a file full of imperatives would be caught |
| `lonja-buttons` | S16's ladder: the preview screen's primary is `Merge into my catches`, and `Replace everything` is destructive (T07) |
| `lonja-lists-and-tables` | The preview's counts table, its empty state, and the ledger row shape |
| `lonja-typography` | Counts are comparable numerals — mono, tabular figures |
| `i18n-rtl-l10n` | The S16 ARB keys in six locales, and the plural categories on "3 trips, 17 catches" |
| `testing-strategy` | The merge is tested against a real in-memory drift database, not a mock — the dedupe rule is a SQL-semantics question |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §12, the import paragraph | "accepts the JSON or the zip, shows a preview (counts of trips, catches, flags; source app version), and requires an explicit choice" |
| `SPEC.md` | §12, the Merge bullet | "deduplicates on `(created_at, species_id, length_mm)`; existing records win on conflict" — the whole rule, verbatim |
| `SPEC.md` | §7.2 | `saved_zone`'s `UNIQUE (jurisdiction_code, zone_code)`; `catch.trip_id REFERENCES trip(id) ON DELETE SET NULL`; `length_mm` nullable; `user_profile` singleton `CHECK (id = 1)` |
| `SPEC.md` | §6, S16 | The screen's error state: "malformed or newer-schema file → named, specific error, nothing written" |
| `SPEC.md` | §4.5, "Photo handling" | Images live inside the app sandbox — an imported `photos/` entry has to be re-rooted there, never referenced from wherever it was unzipped |
| `SPEC.md` | §9.5, Plurals | `ar` needs all six ICU categories; `es`, `ca` and `pt` carry `many`; only `gl` is `one`/`other`. The counts line is a plural |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §1 | The "Allowed" line — `getApplicationSupportDirectory()`; nothing here reaches further |
| `.claude/skills/lonja-buttons/references/variant-ladder-and-states.md` | "The ladder", "Deciding the rung" | Why `Merge into my catches` is the primary and `Replace everything` is not |
| `.claude/skills/lonja-dialogs-and-surfaces/references/modal-decision-matrix.md` | §1, §2 | S16's preview is a **route**, not a modal — the user can leave it and nothing is pending |
| `FLUTTER_GUIDE.md` | §1.4 | Repositories own the mutation of a data type; the merge is a use case because it spans five of them |
| `FLUTTER_GUIDE.md` | §1.6 | `Failure` in the data layer, unwrapped at the provider boundary |
| `epics/DECISIONS.md` | D-3 | Six locales for every ARB key, and the `ar` plural categories |

## What this delivers

- `app/lib/domain/models/portability/import_preview.dart` — `ImportPreview`: `tripCount`,
  `catchCount`, `ruleFlagCount`, `savedZoneCount`, `photoCount`, `sourceAppVersion`,
  `sourceSchemaVersion`, `exportedAt`, `jurisdictionCodes`.
- `app/lib/domain/use_cases/preview_import.dart` — `PreviewImport`, which reads a file (JSON or zip),
  decodes it, and returns the counts **without opening a write transaction**.
- `app/lib/domain/use_cases/merge_import.dart` — `MergeImport`, the dedupe rules below, in one drift
  transaction.
- `app/lib/data/services/portability/import_archive_reader.dart` — unzips into a scratch directory,
  rejects any entry name containing `..` or a leading `/`.
- `app/lib/data/services/portability/photo_importer.dart` — copies `photos/<id>.<ext>` into the app
  sandbox and returns the new absolute path.
- `app/lib/data/repositories/portability_repository.dart` gains `applyMerge(MergePlan)`.
- `app/lib/ui/settings/import/import_preview_screen.dart` and `import_preview_view_model.dart` — S16.
- ARB keys in all six locales (D-3): `importTitle`, `importChooseFile`, `importPreviewTrips`,
  `importPreviewCatches`, `importPreviewFlags`, `importPreviewZones`, `importPreviewPhotos`,
  `importPreviewSourceVersion`, `importPreviewExportedAt`, `importActionMerge`,
  `importMergeExplainer`, `importMergeResultAdded`, `importMergeResultSkipped`. The three count keys
  are ICU plurals with all six `ar` categories.
- Tests: `app/test/domain/use_cases/preview_import_test.dart`,
  `app/test/domain/use_cases/merge_import_test.dart`,
  `app/test/ui/settings/import/import_preview_view_model_test.dart`.

## Why it is built this way

**The preview exists so nothing is written on hope.** §12 requires counts and the source app version
before the user chooses, and S16's error state requires that a bad file writes nothing. Those are the
same requirement seen from two sides: the decode runs to completion, over the whole file, before any
transaction opens. `PreviewImport` therefore returns a fully decoded `ExportEnvelope` alongside the
counts, and `MergeImport` takes that envelope rather than a path — so the "validate then write" split
is a type signature, not a convention someone can forget.

**The dedupe key is `(created_at, species_id, length_mm)`, and `length_mm` is nullable.** This is the
trap. §7.2 makes `length_mm` nullable, because a catch recorded from the tally has no measurement. In
SQL, `NULL = NULL` is not true, so a key comparison written as `=` never matches two unmeasured
catches and the merge duplicates every one of them on each import. The rule implemented here is
`IS NOT DISTINCT FROM` semantics: two nulls are equal for the purposes of the key. The comparison is
done in Dart over the decoded envelope against a keyed index built from one query, rather than in
SQL, so the semantics are explicit and testable and do not depend on which SQLite version the device
carries.

**Existing records win, and winning means the incoming row is skipped whole.** §12 says "existing
records win on conflict". It does not say "fields are merged", and field-level merging is where this
would go wrong: an incoming row with a photo and a null `outcome_detail` would half-overwrite a local
row that had the detail and no photo, producing a record that never existed on either device. The
implemented rule is: key matches → skip the incoming row entirely, count it as skipped, and report
the count. Rejected: last-write-wins on `updated_at` — that silently overwrites an edit the fisher
made on *this* phone with a stale copy from a backup, and §4.5 lists edit and delete as first-class.

**Trips are matched on `(started_at, jurisdiction_code, zone_code)`, and this is recorded here
because §12 is silent.** §12 gives a key for catches only. Trips need one anyway, because the catch
rows carry `trip_id` and importing a duplicate trip would split one day's catches across two entries.
`started_at` is the natural identity of a trip; jurisdiction and zone disambiguate two trips started
at the same minute in different places. When an incoming trip matches an existing one, the surviving
id is the **existing** id, and every incoming catch that referenced the incoming trip is remapped to
it before insertion. That remap is the single most intricate part of this task and has three test
rows of its own.

**A catch whose trip is not in the file keeps a null `trip_id`.** §7.2 declares
`ON DELETE SET NULL` precisely because a catch can outlive its trip, and §4.5 says quick-added catches
have no trip at all. An incoming `trip_id` that resolves to nothing becomes null rather than
inventing a trip or dropping the catch.

**Saved zones dedupe on the schema's own `UNIQUE (jurisdiction_code, zone_code)`.** No new rule is
invented; the constraint is already there, and the merge does an upsert that leaves the existing row.
The `label` and `sort_order` of the local row survive, because they are the fisher's own arrangement.

**The profile is not overwritten by a merge.** `user_profile` is a singleton (`CHECK (id = 1)`), so a
naive restore would replace it. `ruler_px_per_mm` and `ruler_calibrated_at` are **calibration for
this specific screen** (§4.2, S4): importing another device's value would silently mis-measure every
subsequent fish on this phone, and the fisher would have no way to know. Merge therefore leaves the
whole profile alone. Replace (T07) does restore it, because replacing is an explicit statement that
this phone should become that phone — and T07 documents the calibration consequence in its own
confirmation copy.

**Rule flags dedupe on `(rule_id, created_at)`.** Two flags against the same rule at the same instant
are the same flag. The `note` is not part of the key, because an edited note is still the same
report, and existing wins.

**`species_recent` is neither exported (T01) nor imported.** It is a usage cache. Importing it would
reorder this fisher's Recents strip on S1 against his own habit.

**Photos are copied into the sandbox, not referenced in place.** The zip is unpacked to a scratch
directory that the OS may reclaim. §4.5 requires images inside the app sandbox and never in the
shared camera roll. So each `photos/<id>.<ext>` is copied to the sandbox and the row's `photo_path`
is set to the new absolute path. A photo whose catch was skipped as a duplicate is not copied — that
would grow storage (§13) for a row nobody will see.

**Entry names are validated before anything is extracted.** T04 asserts the writer never produces an
entry containing `..` or a leading `/`; the reader must not trust that, because the file being
imported may have been hand-edited or produced by another tool. An unchecked entry name is the
classic zip-slip write outside the sandbox.

**S16's preview is a route, not a modal.** `modal-decision-matrix.md` §1's single question: can the
user do anything useful while this is on screen? Yes — he can leave, look at his trips, and come
back. Nothing is pending. Only the Replace confirmation (T07) blocks.

## Tests first

Write every row before touching `merge_import.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `PreviewImport.call reports counts of trips, catches and flags` | envelope with 3/17/2 | `tripCount: 3, catchCount: 17, ruleFlagCount: 2` | §12 names exactly these three counts |
| 2 | `PreviewImport.call reports the source app version` | header `app_version: '1.4.0'` | `sourceAppVersion: '1.4.0'` | §12 names it; it is how a user recognises which phone the file came from |
| 3 | `PreviewImport.call opens no write transaction` | any file | the fake database records zero writes | "nothing written" (S16) is only true if the preview cannot write |
| 4 | `PreviewImport.call accepts a zip and a bare JSON file` | both fixtures | identical preview from both | §12: "accepts the JSON or the zip" |
| 5 | `ImportArchiveReader rejects an entry name containing ..` | hand-built zip with `../evil.json` | `Failure`, nothing extracted | Zip slip — the reader cannot trust the writer, because the file may not have come from us |
| 6 | `ImportArchiveReader rejects an entry name with a leading slash` | `/etc/passwd` entry | `Failure`, nothing extracted | The second half of the same attack |
| 7 | `MergeImport.call inserts a catch whose key is not present` | empty database, 1 catch | 1 row, reported as added | The base case, and the one that proves the key comparison is not matching everything |
| 8 | `MergeImport.call skips a catch whose (created_at, species_id, length_mm) already exists` | database with the same catch | still 1 row, reported as skipped | §12's rule, verbatim |
| 9 | `MergeImport.call treats two null length_mm values as the same key` | existing and incoming both null-length, same instant and species | 1 row, reported as skipped | The SQL `NULL = NULL` trap; without this the tally-only catches duplicate on every import |
| 10 | `MergeImport.call keeps the existing row's fields when a key collides` | existing has `outcome_detail`, incoming has a photo | existing row unchanged, photo not attached | "Existing records win" means the whole row wins, not a field-wise blend |
| 11 | `MergeImport.call is idempotent when run twice over the same file` | merge, then merge again | second run adds 0 rows | The property the dedupe rule exists to give; a user will re-import by accident |
| 12 | `MergeImport.call matches a trip on (started_at, jurisdiction_code, zone_code)` | existing trip, same key | 1 trip, reported as skipped | The key §12 leaves unspecified, decided and recorded here |
| 13 | `MergeImport.call remaps an incoming catch to the surviving trip id` | incoming trip id 7 collides with existing id 2 | the imported catch has `trip_id: 2` | The remap: without it every imported catch orphans, and S10's per-trip totals are wrong |
| 14 | `MergeImport.call sets trip_id to null when the incoming trip is absent from the file` | catch with `trip_id: 9`, no trip 9 | row inserted, `trip_id` null | §7.2's `ON DELETE SET NULL` and §4.5's quick-add both make this a legal state |
| 15 | `MergeImport.call leaves the local user_profile untouched` | file with a different `ruler_px_per_mm` | local value unchanged | Importing another screen's calibration silently mis-measures every later fish |
| 16 | `MergeImport.call leaves an existing saved zone's label and sort order` | same `(jurisdiction_code, zone_code)`, different label | local label and order survive | The fisher's own arrangement of his zones is his |
| 17 | `MergeImport.call inserts a saved zone that is not present` | new zone code | inserted | The other half of the UNIQUE constraint |
| 18 | `MergeImport.call skips a rule flag matching (rule_id, created_at)` | duplicate flag | 1 row | An edited note is still the same report |
| 19 | `MergeImport.call copies an imported photo into the application support directory` | zip with `photos/12.jpg` | file exists in the sandbox and `photo_path` points at it | §4.5 — the scratch directory is reclaimed and a reference into it dangles |
| 20 | `MergeImport.call does not copy a photo whose catch was skipped` | duplicate catch with a photo | no new file on disk | §13 storage; a photo for a row nobody will see |
| 21 | `MergeImport.call writes nothing when any row fails validation` | 17 catches, the 12th with a bad outcome | row counts unchanged | The transactional promise T08 hardens, asserted here so the merge path already has it |
| 22 | `MergeImport.call reports added and skipped counts that sum to the file's catch count` | 17 catches, 5 duplicates | `added: 12, skipped: 5` | The number shown to the user after the import; a mismatch means a row went somewhere unaccounted |
| 23 | `ar - ImportPreviewScreen renders the counts with all six plural categories` | 0, 1, 2, 3, 11, 100 trips | six distinct strings, none falling back | §9.5 — an `ar` ARB entry missing a category is a build failure, and the counts line is the plural most likely to be authored with two |
| 24 | `ImportPreviewScreen builds exactly one primary action` | pump S16 with a preview | one `LonjaButtonVariant.primary`, labelled from ARB | `lonja-buttons` rule 1, and the primary is Merge rather than Replace |

```dart
// app/test/domain/use_cases/merge_import_test.dart
import 'package:catchlaw/domain/use_cases/merge_import.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/portability_fixtures.dart';
import '../../../testing/fakes/in_memory_user_database.dart';

void main() {
  late InMemoryUserDatabase db;

  setUp(() async => db = await InMemoryUserDatabase.open());
  tearDown(() async => db.close());

  group('MergeImport', () {
    test('.call treats two null length_mm values as the same key', () async {
      await db.insertCatch(kCatchNoLength);
      final result = await MergeImport(db).call(kEnvelopeWithSameNullLengthCatch);

      expect((result as Ok<MergeReport>).value.catchesAdded, 0);
      expect(result.value.catchesSkipped, 1);
      expect(await db.catchCount(), 1);
    });

    test('.call remaps an incoming catch to the surviving trip id', () async {
      final existingTripId = await db.insertTrip(kTripArousa20260714); // local id 2
      final result = await MergeImport(db).call(kEnvelopeSameTripDifferentId); // file id 7

      expect(result, isA<Ok<MergeReport>>());
      expect(await db.tripCount(), 1);
      expect(await db.tripIdOfCatch(kCatchXoubina.createdAt), existingTripId);
    });

    test('.call is idempotent when run twice over the same file', () async {
      await MergeImport(db).call(kEnvelopeGaliciaTwoTrips);
      final before = await db.catchCount();

      final second = await MergeImport(db).call(kEnvelopeGaliciaTwoTrips);

      expect((second as Ok<MergeReport>).value.catchesAdded, 0);
      expect(await db.catchCount(), before);
    });

    test('.call leaves the local user_profile untouched', () async {
      await db.setRulerPxPerMm(9.42);
      await MergeImport(db).call(kEnvelopeWithDifferentCalibration);

      expect(await db.rulerPxPerMm(), 9.42);
    });

    test('.call writes nothing when any row fails validation', () async {
      final before = await db.catchCount();

      final result = await MergeImport(db).call(kEnvelopeWithBadOutcomeAtIndex12);

      expect(result, isA<Err<MergeReport>>());
      expect(await db.catchCount(), before);
    });

    // … one test per row in the table above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/domain/use_cases/merge_import_test.dart` → 24 failures. If row
9 passes now the test is wrong — a merge that has not been written cannot be deduplicating anything,
so a green result means the fixture already contained the expected state.

## Implementation outline

1. Write `ImportPreview` and `PreviewImport`. `PreviewImport` returns a record of
   `(ImportPreview preview, ExportEnvelope envelope)` so the validated envelope flows into the apply
   step and there is no second decode.
2. Write `ImportArchiveReader`: validate every entry name against `..` and a leading `/` **before**
   extracting anything, then extract to a scratch directory under
   `getTemporaryDirectory()/catchlaw_import/`.
3. Write the key types: `CatchKey(createdAt, speciesId, lengthMm)` and
   `TripKey(startedAt, jurisdictionCode, zoneCode)`, each with `operator ==` treating two nulls as
   equal. That equality is the null-safety rule from the "why" section, expressed once.
4. Write `MergeImport`:
   a. Query the existing catch keys, trip keys, saved-zone keys and flag keys — four `SELECT`s, one
      pass each, into `Set`s.
   b. Build a `Map<int, int>` from incoming trip id to surviving local trip id.
   c. Partition the incoming rows into added and skipped.
   d. Open one drift `transaction()`: insert the new trips, capture their real ids, extend the id
      map, insert the new catches with remapped `trip_id`, then zones and flags.
   e. Outside the transaction, after commit, copy the photos of the inserted catches into the
      sandbox and update their `photo_path` in a second short transaction. Photo copying is
      filesystem work and must not hold a write lock over an 8,000-row import.
5. Write `PhotoImporter` — copy `photos/<id>.<ext>` to
   `getApplicationSupportDirectory()/photos/<newCatchId>.<ext>`.
6. Write `ImportPreviewViewModel` and `ImportPreviewScreen`. `file_picker` (added in T05) supplies
   the file. One primary, `Merge into my catches`; `Replace everything` steps down and is wired in
   T07.
7. Add the 13 ARB keys to all six locale files, with the three count keys as ICU plurals carrying all
   six `ar` categories (§9.5). Run `gen-l10n`.
8. Re-run the suite. All 24 green, and every E13 catch-log test still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 24 tests pass, and each failed first.
- [ ] `PreviewImport` cannot write: its only database dependency is a read-only interface, asserted
      by a fake that fails the test on any write call.
- [ ] The dedupe key comparison treats two nulls as equal, and a test proves it.
- [ ] A merge run twice over the same file adds zero rows on the second run.
- [ ] `user_profile` is untouched by `MergeImport` — grep the file for `userProfile` and find only
      reads.
- [ ] Every incoming catch either lands with a remapped `trip_id`, lands with a null `trip_id`, or is
      counted as skipped; the three counts sum to the file's catch count.
- [ ] Archive entry names are validated before extraction, not after.
- [ ] The 13 ARB keys exist in all six locales, and every `ar` plural carries all six categories.
- [ ] Line coverage on `merge_import.dart` is ≥ 95% — this is the file where a missed branch loses
      data.
- [ ] `check_lonja_buttons.sh app/lib` clean; S16 builds exactly one primary.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh        app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh    app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh   app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                  app/lib
tools/gates/no_directional_geometry.sh                                       app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(import): preview an import before writing, and merge with existing records winning

The preview decodes the whole file and counts trips, catches and flags before
any transaction opens, so S16's "nothing written" is a type signature rather
than a promise: PreviewImport returns the validated envelope and MergeImport
takes an envelope, not a path.

§12's dedupe key is (created_at, species_id, length_mm) and length_mm is
nullable, so the comparison uses IS NOT DISTINCT FROM semantics — in SQL
NULL = NULL is not true, and a naive key would duplicate every tally-only
catch on every import. Existing wins means the whole incoming row is skipped,
not blended field by field: a blend produces a record that never existed on
either device.

Trips are matched on (started_at, jurisdiction_code, zone_code) — §12 is
silent on trips, and the choice is recorded in the task file — and every
incoming catch is remapped to the surviving trip id so a day's catches do not
split across two entries. The local user_profile is never overwritten by a
merge: ruler_px_per_mm is calibration for this screen, and another device's
value would silently mis-measure every later fish.

Task: E17/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
