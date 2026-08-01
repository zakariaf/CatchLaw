# E17/T08 — Transactional import

| | |
|---|---|
| **Epic** | E17 — Export and import |
| **Branch** | `epic/17-portability` (shared) |
| **Commit** | `fix(import): refuse a malformed or newer-schema file by name and write nothing` |
| **Depends on** | T06 (merge), T07 (replace) — this task hardens both apply paths |
| **Size** | L |
| **Spec** | `SPEC.md` §12 (the transactional paragraph), §6 S16 error state, §7.4 (the app refuses a higher schema version rather than corrupting it), §13 ("Crash safety — data loss unacceptable"), §14 (import succeeds in airplane mode) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `error-handling-typed-results` | This task *is* the failure taxonomy: a sealed family where every case names a specific, user-showable failure, carried by `Failure` and unwrapped once at the provider boundary |
| `persistence-drift` | The one-transaction guarantee, and the ordering that makes validation cheap: everything is validated before a write lock is taken |
| `run-migration` | `user_db_schema_version` is drift's `schemaVersion`; this skill owns forward-only numbering and the refusal on a higher version |
| `catchlaw-conventions-index` | Invariant 5's shape applied to a different problem — the app states a fact about what went wrong and blocks nothing else |
| `catchlaw-verdict-contract` | Rules 1, 2, 7 and 8: the error copy is a statement of fact, has no second person, is never softened, and carries no hedge ("probably", "appears to") |
| `lonja-dialogs-and-surfaces` | Rule 8 — a failure that matters is a surface, not a snackbar; and rule 12, no spinner over a barrier |
| `i18n-rtl-l10n` | Every failure message is an ARB key with placeholders in six locales; the field path is a placeholder, not a concatenation |
| `dart3-idioms-and-coding-standards` | The sealed failure family and exhaustive `switch` over it |
| `testing-strategy` | The corpus approach: a directory of deliberately broken files, each asserted to leave the database untouched |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §12, the transactional paragraph | "Import is transactional: a malformed file writes nothing and names the specific failure. A file from a *newer* schema version is refused with a clear message rather than partially applied" |
| `SPEC.md` | §6, S16 | "error state: malformed or newer-schema file → named, specific error, nothing written" |
| `SPEC.md` | §7.4, last bullet | "The app refuses to open a `user.db` whose `schema_version` is *higher* than it understands and says so plainly, rather than corrupting it (this happens on downgrade)" — the same rule, applied to a file |
| `SPEC.md` | §13, "Crash safety" | "Data loss unacceptable. Every write transactional" |
| `SPEC.md` | §14, dynamic | "Import of a previously exported zip succeeds, in airplane mode" — the device line E21 executes |
| `.claude/skills/catchlaw-verdict-contract/SKILL.md` | rules 7, 8 | Wording that may not be softened, and the banned hedge lexicon that a failure message will otherwise attract |
| `.claude/skills/lonja-dialogs-and-surfaces/SKILL.md` | rule 8, rule 12 | "Never show a snackbar for … a failure to read the rule database, or anything a prosecutor could ask about"; no `CircularProgressIndicator` inside a modal |
| `FLUTTER_GUIDE.md` | §1.6, points 1–4 | Rename `Error` to `Failure`; the error channel is `Exception` and a `TypeError` escapes it; `Result` drops stack traces; `asOk` is test-only |
| `FLUTTER_GUIDE.md` | §7.5 | `rethrow`, never `throw e` — for an app that cannot phone home the local stack trace is the only diagnostic there will ever be |
| `FLUTTER_GUIDE.md` | §1.7 | Never nest `AsyncValue<Result<T>>`; unwrap in the notifier |
| `epics/DECISIONS.md` | D-3, D-5 | Six locales for every message; the drift version whose `schemaVersion` this compares against |

## What this delivers

- `app/lib/data/services/portability/portability_failure.dart` completed — the sealed family opened
  in T01 gains `NewerSchema(fileVersion, appVersion)`, `UnsupportedSchema(fileVersion, appVersion)`,
  `UnreadableArchive(entryName)`, `UnsafeEntryName(entryName)`, `MissingPhotoEntry(catchId, entry)`
  and `EmptyFile`.
- `app/lib/domain/use_cases/import_user_data.dart` — the single entry point both apply paths run
  through: `validate → refuse or plan → one transaction → report`. `MergeImport` (T06) and
  `ReplaceImport` (T07) become the two strategies it dispatches to.
- `app/lib/ui/settings/import/import_failure_message.dart` — maps each sealed case to its ARB key
  and placeholders. The only place a failure becomes a sentence.
- ARB keys in all six locales (D-3): `importFailedMalformedJson`, `importFailedMissingField`,
  `importFailedWrongType`, `importFailedNewerSchema`, `importFailedUnsupportedSchema`,
  `importFailedUnreadableArchive`, `importFailedUnsafeEntry`, `importFailedMissingPhoto`,
  `importFailedEmptyFile`, `importNothingWasWritten`.
- `app/test/fixtures/portability/malformed/` — the corpus: 14 deliberately broken files, each with a
  one-line README entry naming what is wrong with it.
- Tests: `app/test/domain/use_cases/import_user_data_test.dart`,
  `app/test/ui/settings/import/import_failure_message_test.dart`,
  `app/integration_test/import_round_trip_test.dart`.

## Why it is built this way

**"Writes nothing" is guaranteed by ordering, not by rollback.** A rollback is the second line of
defence; the first is that no write lock is ever taken until the whole file has been decoded and
validated. `ImportUserData` runs three phases with hard boundaries:

1. **Read and refuse.** Open the file, validate archive entry names, decode the header. Refuse on
   schema version here — before the payload is parsed, and long before a transaction exists.
2. **Decode and plan.** Decode every row, validate every `CHECK`-constrained value against §7.2,
   resolve the dedupe keys and the trip-id remap (T06). Produce an `ImportPlan` of concrete inserts.
   Nothing has been written.
3. **Apply.** One drift `transaction()` over the plan. Any exception rethrows and drift rolls back.

Phase 2 is what makes the promise cheap: a bad row at index 900 is found without a rollback, and the
message can name it. Rejected: streaming the file straight into inserts and relying on the rollback —
correct on paper, but it takes a write lock for the length of an 8,000-row import, and a rollback of
that size on a low-end device (§13: 2 GB RAM, Android 7) is exactly the moment a crash produces the
half-applied state §12 forbids.

**A newer schema version is refused before anything else.** §7.4 already refuses to *open* a `user.db`
at a higher schema version, "rather than corrupting it (this happens on downgrade)". A file is the
same problem with a slower fuse: a phone that has been downgraded, or a file exported from a phone
that has been updated, carries columns this build does not know. Partially applying it would drop
those columns silently and the loss would surface years later. The header is the first thing in the
JSON (T01) for exactly this reason.

**An older schema version is refused too, and that is a decision recorded here because §12 is silent.**
At the first release there is exactly one `schemaVersion`, so no older file can exist; accepting one
would mean shipping a decoder for a format that has never been written, which is untestable
speculation. The rule is: the decoder accepts its own version, and refuses anything else with both
numbers named — `UnsupportedSchema(fileVersion: 1, appVersion: 2)`. The branch that upgrades an older
envelope is added by the epic that first bumps `schemaVersion`, together with a fixture file at the
old version, which is the only way to test such a branch honestly.

**Every failure names a place, not a category.** "Import failed" is useless to a man who has one copy
of his data. The sealed cases carry the JSON path (`catches[3].length_mm`), the entry name
(`photos/../evil.jpg`), or the two version numbers. `import_failure_message.dart` is the only file
that turns a case into a sentence, so the six-locale ARB coverage is checkable in one place, and the
paths and numbers are **placeholders** rather than string concatenation — §9.5's rule that content
strings are complete phrases and never assembled from fragments.

**The error copy is a statement of fact.** Verdict-contract rule 8 bans the hedges a failure message
attracts: "probably", "appears to", "seems". Rule 2 bans second person: "This file was exported from
a newer version of CatchLaw (schema 3; this app reads schema 2). Nothing was written." — never "You
need to update". Rule 7's principle applies too: the wording is not softened, and the second sentence
— "Nothing was written." — is the one the fisher actually needs, so it is a separate ARB key appended
to every failure rather than an optional flourish on some of them.

**A failure is a surface, not a snackbar.** `lonja-dialogs-and-surfaces` rule 8: a snackbar
auto-dismisses in four seconds and is invisible to someone looking at a phone in bright sun. An import
failure is exactly "anything a prosecutor could ask about". It renders inline on S16, above the
preview, and stays until the user picks another file.

**The rollback path keeps its stack trace.** `FLUTTER_GUIDE.md` §1.6 point 3: `Result` drops stack
traces, and for an app that cannot phone home the local trace is the only diagnostic that will ever
exist. So the transaction body uses `rethrow` (§7.5), and the boundary that converts to a `Failure`
carries the `StackTrace` alongside it into `AsyncValue.error(e, st)` while it is still in scope.

**`TypeError` cannot reach this layer.** T01's decoder contains no `as` cast, which is why the
failure channel can honestly be `Exception` (`FLUTTER_GUIDE.md` §1.6 point 2). This task adds the
test that proves it over the whole corpus: fourteen broken files, none of which throws.

## Tests first

Write every row before touching `import_user_data.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ImportUserData.call refuses a file whose user_db_schema_version is higher than the app's` | header version `app + 1` | `NewerSchema(fileVersion, appVersion)`, row counts unchanged | §12 and §7.4 — the headline refusal, and the one that prevents silent column loss |
| 2 | `ImportUserData.call names both version numbers in the refusal` | as above | the failure carries `fileVersion` and `appVersion` | "a clear message" (§12) means the reader can tell which phone is which |
| 3 | `ImportUserData.call refuses a newer-schema file before decoding the payload` | newer header, deliberately corrupt payload | `NewerSchema`, not a decode failure | Proves the ordering: the header is refused first, so an 8,000-row parse never runs |
| 4 | `ImportUserData.call refuses a file whose schema version is lower than the app's` | header version `app - 1` | `UnsupportedSchema(fileVersion, appVersion)` | The decision §12 leaves open, recorded and enforced rather than left to a future reader |
| 5 | `ImportUserData.call writes nothing for every file in the malformed corpus` | 14 broken files | row counts unchanged after each | The §12 promise, asserted once per failure mode rather than once in general |
| 6 | `ImportUserData.call throws no exception for any file in the malformed corpus` | 14 broken files | every call returns a `Failure` | `FLUTTER_GUIDE.md` §1.6 point 2 — a `TypeError` would escape `Result` entirely and crash the import screen |
| 7 | `ImportUserData.call names the field path when a value has the wrong type` | `catches[3].length_mm: "forty"` | `WrongType` with that path | The message a user can act on: which row, which column |
| 8 | `ImportUserData.call names the field path when a required field is absent` | catch with no `created_at` | `MissingField('catches[3].created_at')` | The other half; and `created_at` is part of the dedupe key, so an absent one is not recoverable |
| 9 | `ImportUserData.call rejects an outcome value outside the CHECK constraint` | `"outcome": "maybe"` | `WrongType('catches[0].outcome', …)`, nothing written | Caught in phase 2; drift would otherwise fail the insert *inside* the transaction, turning a named error into a rollback |
| 10 | `ImportUserData.call refuses an archive entry name containing ..` | zip with `../evil.json` | `UnsafeEntryName`, nothing extracted, nothing written | Zip slip; the file may have been hand-edited, so T04's writer guarantee is not enough |
| 11 | `ImportUserData.call refuses an empty file` | zero-byte file | `EmptyFile` | The most common real corruption — a share interrupted mid-copy |
| 12 | `ImportUserData.call refuses an archive with no export JSON entry` | zip of only photos | `UnreadableArchive` naming what was missing | A user who zips his `photos/` folder by hand will try this |
| 13 | `ImportUserData.call names the catch id when a referenced photo entry is absent from the archive` | catch says `photos/12.jpg`, entry missing | `MissingPhotoEntry(catchId: 12, entry: 'photos/12.jpg')` | A truncated zip restores rows pointing at nothing; naming the catch lets the user decide |
| 14 | `ImportUserData.call takes no write lock during validation` | recording database | zero transactions opened before the first valid row | The ordering that makes "writes nothing" cheap rather than a large rollback |
| 15 | `ImportUserData.call rolls back when an insert fails inside the transaction` | plan whose 12th insert fails at the database level | row counts unchanged | The second line of defence, exercised directly |
| 16 | `ImportUserData.call preserves the stack trace across the failure boundary` | throwing fake database | the failure carries a non-null `StackTrace` | `FLUTTER_GUIDE.md` §1.6 point 3 — the local trace is the only diagnostic an offline app will ever have |
| 17 | `ImportFailureMessage has an ARB key for every sealed failure case` | exhaustive `switch` | compiles, and every case returns a non-empty string | An unhandled case would render an empty error, which is worse than a wrong one |
| 18 | `ImportFailureMessage appends "Nothing was written" to every failure` | all cases | every message ends with that sentence | The one fact a man with a single copy of his data needs, on every failure and not just some |
| 19 | `ImportFailureMessage uses placeholders rather than concatenation` | the ARB source | every message with a number or a path declares placeholders | §9.5 — content strings are complete phrases, never assembled from fragments |
| 20 | `ImportFailureMessage contains no second person and no hedge in any locale` | all six ARB files | no match for the banned lexicons | Verdict-contract rules 2 and 8, which bind an error message exactly as they bind a verdict |
| 21 | `ar - ImportFailureMessage renders every failure case` | `ar` locale, all cases | non-empty, no English fallback | D-3; a missing `ar` key falls back to English inside the one message a user must understand |
| 22 | `ImportScreen renders a failure inline, not in a snackbar` | failing import | no `SnackBar` in the tree, message present on the surface | `lonja-dialogs-and-surfaces` rule 8 — four seconds and invisible in bright sun |
| 23 | `Merge and Replace both fail through the same validation` | one broken file, both strategies | identical failure from each | Two apply paths with two validators would drift, and one of them would be the lenient one |
| 24 | `An exported zip re-imports into an empty database with every row identical` | export 2 trips and 17 catches, wipe, Replace | every column of every row equal | The round trip §14 tests on device, asserted here where it can fail loudly |

```dart
// app/test/domain/use_cases/import_user_data_test.dart
import 'dart:io';

import 'package:catchlaw/data/services/portability/portability_failure.dart';
import 'package:catchlaw/domain/use_cases/import_user_data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/in_memory_user_database.dart';
import '../../../testing/models/portability_fixtures.dart';

void main() {
  late InMemoryUserDatabase db;

  setUp(() async {
    db = await InMemoryUserDatabase.open();
    await db.seed(kSeedThreeTripsTwentyCatches);
  });
  tearDown(() async => db.close());

  group('ImportUserData', () {
    test('.call refuses a file whose user_db_schema_version is higher than the app\'s', () async {
      final before = await db.snapshot();

      final result = await ImportUserData(db).call(kEnvelopeFileFromNewerSchema,
          strategy: ImportStrategy.merge);

      final failure = (result as Err<ImportReport>).failure as NewerSchema;
      expect(failure.fileVersion, greaterThan(failure.appVersion));
      expect(await db.snapshot(), before);
    });

    test('.call refuses a newer-schema file before decoding the payload', () async {
      final result = await ImportUserData(db).call(kNewerSchemaWithCorruptPayload,
          strategy: ImportStrategy.merge);

      expect((result as Err<ImportReport>).failure, isA<NewerSchema>());
    });

    test('.call writes nothing for every file in the malformed corpus', () async {
      final before = await db.snapshot();

      for (final file in Directory('test/fixtures/portability/malformed').listSync().whereType<File>()) {
        final result = await ImportUserData(db).call(readEnvelopeSource(file),
            strategy: ImportStrategy.merge);
        expect(result, isA<Err<ImportReport>>(), reason: file.path);
        expect(await db.snapshot(), before, reason: file.path);
      }
    });

    test('.call throws no exception for any file in the malformed corpus', () async {
      final files = Directory('test/fixtures/portability/malformed').listSync().whereType<File>();
      expect(files, isNotEmpty, reason: 'the malformed corpus directory is empty');

      for (final file in files) {
        await expectLater(
          ImportUserData(db).call(readEnvelopeSource(file), strategy: ImportStrategy.merge),
          completes,
          reason: file.path,
        );
      }
    });

    test('.call takes no write lock during validation', () async {
      final recorder = RecordingUserDatabase(db);

      await ImportUserData(recorder).call(kEnvelopeWithBadOutcomeAtIndex12,
          strategy: ImportStrategy.merge);

      expect(recorder.transactionCount, 0);
    });

    test('Merge and Replace both fail through the same validation', () async {
      final merge = await ImportUserData(db).call(kEnvelopeWithBadOutcomeAtIndex12,
          strategy: ImportStrategy.merge);
      final replace = await ImportUserData(db).call(kEnvelopeWithBadOutcomeAtIndex12,
          strategy: ImportStrategy.replace);

      expect((merge as Err<ImportReport>).failure, (replace as Err<ImportReport>).failure);
    });

    // … one test per row in the table above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/domain/use_cases/import_user_data_test.dart` → 24 failures. If
row 5 passes now the test is wrong — the corpus directory does not exist yet, so an empty listing
would make the loop vacuously true. Row 6 already asserts the listing is non-empty; add the same
assertion to row 5 before writing any implementation. This is `CONVENTIONS.md` §7's failure mode
(a scan of an empty tree reports success) reproduced inside a test.

## Implementation outline

1. Complete the sealed `PortabilityFailure` family. Every case carries the data its message needs —
   a path, an entry name, a catch id, or two version numbers — and no case carries a pre-built
   sentence (D-7's principle: the data layer holds no user-visible string).
2. Build the malformed corpus under `app/test/fixtures/portability/malformed/`, 14 files, each named
   for its defect: `truncated.json`, `not_json.json`, `empty.json`, `header_missing.json`,
   `newer_schema.json`, `older_schema.json`, `catch_wrong_type.json`, `catch_missing_created_at.json`,
   `catch_bad_outcome.json`, `zip_slip.zip`, `zip_no_json.zip`, `zip_missing_photo.zip`,
   `trip_missing_zone.json`, `flag_missing_rule_id.json`. A `README.md` beside them says in one line
   what each is for, so a future reader does not "fix" one.
3. Write `ImportUserData` with the three phases. Phase 1 and phase 2 take a read-only database
   interface; only phase 3 receives one that can write. That is the ordering guarantee expressed as a
   type, which is what makes row 14 checkable.
4. Refactor `MergeImport` (T06) and `ReplaceImport` (T07) into strategies that consume an
   `ImportPlan`. Neither validates any more. Row 23 is what proves the refactor landed.
5. Write `ImportFailureMessage` with an exhaustive `switch` — no `default` clause, so a new sealed
   case is a compile error rather than an empty string.
6. Add the ten ARB keys to all six locale files with placeholders, and `importNothingWasWritten`
   appended by the mapper to every message rather than duplicated into ten strings.
7. Surface failures inline on S16 above the preview, with no snackbar and no spinner.
8. Write `app/integration_test/import_round_trip_test.dart` — export, wipe, Replace, compare every
   column. The airplane-mode half of §14 is E21's device work; this test does not claim it.
9. Re-run the suite. All 24 green, plus every T01–T07 test.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 24 tests pass, and each failed first.
- [ ] The malformed corpus holds 14 files, the tests assert the listing is non-empty before looping,
      and each file has a one-line entry in the corpus README.
- [ ] No file in the corpus causes an exception to escape `ImportUserData`.
- [ ] Row counts and photo files are unchanged after every corpus file, for both strategies.
- [ ] A newer `user_db_schema_version` is refused with both numbers named, before the payload is
      decoded.
- [ ] An older `user_db_schema_version` is refused with both numbers named.
- [ ] `ImportFailureMessage` has no `default` clause; adding a sealed case breaks the build.
- [ ] Every failure message ends with the "Nothing was written" sentence, in all six locales.
- [ ] No second person and no hedge from the verdict-contract lexicons appears in any of the ten new
      ARB values, `app_ar.arb` included — `check_verdict_contract.sh app/lib` clean.
- [ ] `MergeImport` and `ReplaceImport` contain no validation; both consume an `ImportPlan`.
- [ ] The failure boundary carries a `StackTrace` into `AsyncValue.error(e, st)`.
- [ ] Line coverage on `import_user_data.dart` is ≥ 95%.
- [ ] The round-trip integration test passes: export, wipe, restore, every column identical.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
cd app && flutter test integration_test/import_round_trip_test.dart
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh        app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh    app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh   app/lib
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh     app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                  app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                  app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
fix(import): refuse a malformed or newer-schema file by name and write nothing

"Writes nothing" is guaranteed by ordering, not by rollback. ImportUserData
reads and refuses on the header, decodes and validates the whole payload into
a plan, and only then opens one transaction. A bad row at index 900 is found
without a write lock ever being taken, which is what lets the message name it
— and a rollback of an 8,000-row import on the 2 GB Android 7 device §13
targets is exactly the moment a crash produces the half-applied state §12
forbids.

A newer user_db_schema_version is refused before the payload is parsed, for
the reason §7.4 already gives about opening a user.db at a higher version:
partially applying it drops columns this build does not know about, and the
loss surfaces years later. An older version is refused too — at the first
release no older file can exist, so accepting one would ship a decoder for a
format that has never been written. Both numbers are named in the message.

Every failure carries a place rather than a category: catches[3].length_mm,
photos/../evil.jpg, schema 3 against schema 2. Merge and Replace now consume
a validated plan and do no validation of their own, so there is one validator
and it cannot be the lenient one.

Task: E17/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
