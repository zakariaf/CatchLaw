# E17/T07 — Replace, behind a typed word

| | |
|---|---|
| **Epic** | E17 — Export and import |
| **Branch** | `epic/17-portability` (shared) |
| **Commit** | `feat(import): wipe and restore behind a typed confirmation word` |
| **Depends on** | T06 (the preview and the validated envelope reach this path already decoded) |
| **Size** | M |
| **Spec** | `SPEC.md` §12 (the Replace bullet), §6 S16 and D1, §7.2 (`user.db` schema and its foreign key), §4.5 (edit, delete and storage), §9.4 (the shared normalisation used by the word comparison) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-dialogs-and-surfaces` | Owns the destructive-confirm surface: `barrierDismissible: false`, a typed result never `bool`, a confirm label that names the consequence, focus captured and restored. `references/modal-decision-matrix.md` has the "Reset the user database" row explicitly |
| `lonja-buttons` | Rule 12 — destructive is oxblood, is never the screen's primary, and its confirm repeats the verb. Rule 9 — a disabled action states its reason in adjacent prose, which is exactly the state the typed word gates |
| `i18n-rtl-l10n` | The confirmation word is an ARB value per locale, not an English constant. Also the directional geometry of the dialog |
| `catchlaw-verdict-contract` | Rules 1, 2 and 7: the confirmation copy is a statement of fact — "Every saved trip, catch and flag on this phone will be erased" — never "Are you sure?" and never second person |
| `persistence-drift` | The wipe and the restore are one transaction across five tables with a foreign key; this skill owns the transaction and the delete order |
| `error-handling-typed-results` | A failed restore rolls back to the pre-wipe state and says why; there is no half-replaced database |
| `catchlaw-rule-engine` | The typed word is compared through the shared `normaliseArabic` / `normaliseLatin` from `packages/rule_engine/` — this skill owns that function and its ordered contract |
| `accessibility-as-code` | The dialog's semantics scope and the announcement; a destructive confirm that a screen-reader user cannot complete is a lockout |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §12, the Replace bullet | "wipes and restores; requires typing a confirmation word" — the whole rule |
| `SPEC.md` | §7.2 | The five tables to wipe, the singleton `user_profile` with `CHECK (id = 1)`, and `catch.trip_id REFERENCES trip(id) ON DELETE SET NULL` which decides the delete order |
| `SPEC.md` | §6, Dialogs D1 | Delete confirmation with undo — and why *this* one has no undo, which has to be argued rather than assumed |
| `SPEC.md` | §4.5, "Storage management" | S14 shows bytes used and offers bulk photo purge that keeps the records — the mechanism that reclaims any photo orphaned by this operation |
| `SPEC.md` | §9.4 | The ordered Arabic fold: NFKC, tatweel and harakat stripped, alef unified, terminals collapsed, leading `ال` stripped, digits mapped. All of it applies to a typed word |
| `.claude/skills/lonja-dialogs-and-surfaces/references/modal-decision-matrix.md` | §2 (the matrix), §3, §4, §5, §6 | The "Reset the user database → modal, typed confirm → `ResetOutcome`" row; barrier policy; focus capture and return; the destructive label table (`Erase all saved catches` / `Keep my catches`); typed results as an enum |
| `.claude/skills/lonja-dialogs-and-surfaces/SKILL.md` | rules 2, 3, 4, 7, 9, 12 | Typed result, consequence-naming labels, explicit `barrierDismissible: false`, focus restore, the deferred-write undo policy this task deliberately does not use, and no spinner over a barrier |
| `.claude/skills/lonja-buttons/references/variant-ladder-and-states.md` | "The ladder", "Disabled: the reason is part of the state" | `destructive` is a rung of its own with max 1 per screen; a disabled control needs adjacent prose naming the missing precondition |
| `.claude/skills/catchlaw-verdict-contract/SKILL.md` | rules 1, 2, 7 | No imperative, no second person, and no softened wording in the confirmation copy |
| `FLUTTER_GUIDE.md` | §1.6 | `Failure` carries the rollback outcome; `asOk` is test-only and never ships |
| `epics/DECISIONS.md` | D-3 | The confirmation word exists in `ar`, `en`, `es`, `gl`, `ca`, `pt_BR` |

## What this delivers

- `app/lib/ui/settings/import/replace_confirm_dialog.dart` — the typed-word confirmation, returning
  `ReplaceOutcome { replaced, kept, dismissed }`.
- `app/lib/domain/use_cases/replace_import.dart` — `ReplaceImport`: wipe and restore in one drift
  transaction, then reclaim orphaned photo files.
- `app/lib/data/repositories/portability_repository.dart` gains `applyReplace(ExportEnvelope)`.
- `app/lib/domain/services/confirmation_word_matcher.dart` — compares the typed text against the
  locale's confirmation word through the shared normalisation from `packages/rule_engine/`.
- ARB keys in all six locales (D-3): `importReplaceConfirmWord`, `importReplaceTitle`,
  `importReplaceBody`, `importReplacePrompt`, `importReplaceMismatchReason`,
  `importReplaceActionErase`, `importReplaceActionKeep`, `importReplaceCalibrationNote`.
- Tests: `app/test/domain/use_cases/replace_import_test.dart`,
  `app/test/ui/settings/import/replace_confirm_dialog_test.dart`,
  `app/test/domain/services/confirmation_word_matcher_test.dart`.

## Why it is built this way

**A typed word, because a red button is muscle memory.** §12 requires it, and the reason is the same
one `lonja-dialogs-and-surfaces` rule 3 gives for banning "OK": at 05:40 with wet hands a confirm is
tapped by reflex. Replace is the only operation in the product that destroys everything — every trip,
every catch, every flag, every photo — with no undo. Typing a word is the only affordance that cannot
be produced by a bounced tap. Rejected: a two-step "tap twice to confirm", which is two reflexes;
rejected: a hold-to-confirm, which a glove defeats.

**No undo, and that is deliberate.** D1 (§6) gives delete an undo, and `lonja-dialogs-and-surfaces`
rule 9 specifies an 8-second deferred write for exactly that case. This operation cannot use it: the
deferred-write trick works because a single row is held in memory, and holding an entire `user.db` in
memory for 8 seconds so a snackbar can cancel it is not a design, it is a second database. The
protection here is placed *before* the write rather than after it, which is why the word is typed
rather than tapped. This is written down because a reviewer who knows rule 9 will otherwise ask.

**The confirmation word is an ARB value, and the comparison is normalised.** An English `REPLACE`
hardcoded into the dialog would make this operation unusable for the product's primary persona — an
Arabic keyboard does not produce Latin letters without a layout switch, and a fisher who cannot type
the word cannot restore his own backup. So each locale carries its own word, reviewed under §9.2's
two-tier translation. The comparison then runs through the shared normalisation from
`packages/rule_engine/` (§9.4, E02): NFKC, tatweel and harakat stripped, alef forms unified, word-final
terminals collapsed, a leading `ال` stripped, Arabic-Indic digits mapped. Concretely, a user typing
`استبدال` or `الاستبدال` or `اسْتِبْدال` all match. Trailing whitespace is trimmed and Latin case is
folded for the same reason. Being generous about *how* the word is typed costs nothing; the
protection is that it must be typed at all.

**`barrierDismissible: false`, and the result is a typed enum.** Both are `lonja-dialogs-and-surfaces`
rules 4 and 2, and `modal-decision-matrix.md` §2 lists "Reset the user database" as a modal with an
explicit `false` barrier and a typed result. A `bool?` would collapse confirmed, declined and
barrier-dismissed into two states plus a null the caller treats as "no" — harmless here, until
someone inverts the condition. `ReplaceOutcome.dismissed` makes the third state unmissable.

**The confirm is oxblood and is not the screen's primary.** `lonja-buttons` rule 12 and the ladder:
`destructive` is its own rung, one per screen, and the screen's primary stays `Merge into my catches`
(T06). The confirm button repeats the verb — `Erase everything and restore this file` — so the
fisher never confirms an unnamed action. The cancel names the preservation, not the abstention:
`Keep my catches`, per `modal-decision-matrix.md` §5.

**Disabled until the word matches, with the reason beside it.** `lonja-buttons` rule 9: a dead control
with no explanation reads as a broken app. One line of ink-muted prose states the missing
precondition, and it is a sibling in the same column — never a tooltip, never a snackbar fired on
tap.

**The wipe and the restore are one transaction, in foreign-key order.** `catch.trip_id REFERENCES
trip(id) ON DELETE SET NULL` (§7.2), and `PRAGMA foreign_keys = ON`. Delete `catch` before `trip`, or
every catch row is rewritten with a null `trip_id` on the way to being deleted — correct, but 8,000
pointless writes. Then `saved_zone`, `rule_flag`, `species_recent`, and finally reset `user_profile`
to the file's values. Any failure rolls the whole thing back and `user.db` is exactly as it was.

**Replace *does* restore the profile — and says what that means.** T06 argued that Merge must not
touch `ruler_px_per_mm`, because importing another screen's calibration silently mis-measures every
later fish. Replace is an explicit statement that this phone should become that phone, so the profile
is restored; but the consequence has to be visible, so the confirmation body carries one line —
`importReplaceCalibrationNote` — stating as a fact that the ruler calibration in the file will replace
the one on this phone, and that S4 re-calibrates. That is a statement of fact, not an instruction
(verdict contract rules 1 and 2).

**Photo files are unlinked after the commit, not before.** Deleting files is not transactional and
cannot be rolled back. Unlinking first means a failed restore has already destroyed photos the
rollback would have kept. Unlinking after commit means a crash in that window leaves orphan files —
which is storage, not data, and S14's bulk photo purge (§4.5, E16) reclaims them. That is the correct
direction of failure, and the epic's risk section records it.

## Tests first

Write every row before touching `replace_import.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ReplaceConfirmDialog disables the erase action until the word is typed` | empty field | action disabled | §12's requirement, and the reason the dialog exists |
| 2 | `ReplaceConfirmDialog enables the erase action when the word matches` | exact word | action enabled | The other half; a gate that never opens is a lockout |
| 3 | `ReplaceConfirmDialog renders a reason line while the action is disabled` | empty field | ink-muted prose naming the missing precondition | `lonja-buttons` rule 9 — a dead control with no explanation reads as broken |
| 4 | `ReplaceConfirmDialog sets barrierDismissible to false` | pumped route | the route's `barrierDismissible` is `false` | `lonja-dialogs-and-surfaces` rule 4; a stray wet-hand tap must not resolve this |
| 5 | `ReplaceConfirmDialog returns ReplaceOutcome.dismissed when popped by the back button` | system back | `dismissed`, no write | The third state a `bool?` would lose |
| 6 | `ReplaceConfirmDialog restores focus to the opener after it pops` | opener focused, dialog opened and popped | opener holds focus again | Rule 7 — without it a screen-reader user re-reads the whole screen |
| 7 | `ReplaceConfirmDialog labels the confirm with the verb and the cancel with the preservation` | pumped | `Erase everything and restore this file` / `Keep my catches` | `modal-decision-matrix.md` §5; and no `OK`, `Cancel`, `Yes`, `No` literal survives the gate |
| 8 | `ReplaceConfirmDialog states the calibration consequence` | pumped | the calibration note is present | Replace restores `ruler_px_per_mm`; a silent change to the ruler is the one consequence a fisher cannot detect |
| 9 | `ConfirmationWordMatcher.matches accepts the exact word` | `REPLACE` in `en` | true | The base case |
| 10 | `ConfirmationWordMatcher.matches accepts a differently cased word` | `replace` | true | Case is not the protection; typing at all is |
| 11 | `ConfirmationWordMatcher.matches accepts surrounding whitespace` | `  REPLACE  ` | true | A soft keyboard adds a trailing space after autocomplete |
| 12 | `ar - ConfirmationWordMatcher.matches accepts the word with a leading definite article` | `الاستبدال` against `استبدال` | true | §9.4 step 5 — instruments write `ال`, users type without it, and the shared fold already handles this |
| 13 | `ar - ConfirmationWordMatcher.matches accepts the word with harakat` | `اسْتِبْدال` | true | §9.4 step 2; a keyboard with diacritics enabled must not lock the user out of his own restore |
| 14 | `ConfirmationWordMatcher.matches rejects a different word` | `DELETE` | false | The gate must actually be a gate |
| 15 | `ConfirmationWordMatcher.matches rejects an empty string` | `''` | false | The default field state must never open the gate |
| 16 | `importReplaceConfirmWord is non-empty and script-appropriate in all six locales` | loop over the six | non-empty; the `ar` value contains only Arabic-script code points | An English word in `app_ar.arb` locks the primary persona out of his own backup |
| 17 | `ReplaceImport.call removes every existing trip, catch, flag and saved zone` | populated database, file with 1 trip | only the file's rows remain | "wipes and restores" |
| 18 | `ReplaceImport.call restores every row from the file` | file with 2 trips and 17 catches | 2 and 17, all columns equal | The restore half, column by column |
| 19 | `ReplaceImport.call restores the user profile from the file` | file with a different `ruler_px_per_mm` | the file's value is in place | The deliberate difference from Merge (T06) |
| 20 | `ReplaceImport.call deletes catches before trips` | ordered fake | catch delete recorded first | `ON DELETE SET NULL` would otherwise rewrite 8,000 rows on the way to deleting them |
| 21 | `ReplaceImport.call leaves the database unchanged when the restore fails midway` | file whose 12th catch fails to insert | pre-existing rows all present | The transactional promise; a half-replaced database is the worst outcome available |
| 22 | `ReplaceImport.call unlinks orphaned photo files after the transaction commits` | 3 local photos, none in the file | the three files are gone, the transaction had already committed | §13 storage, and the ordering that makes a rollback safe |
| 23 | `ReplaceImport.call unlinks no photo file when the transaction rolls back` | failing restore, 3 local photos | all three still on disk | Files are not transactional; unlinking first destroys what a rollback would have kept |
| 24 | `ReplaceImport.call restores into an empty database` | empty database, full file | every row present | The reinstall case §14 tests: "a pre-taken export restores it completely" |

```dart
// app/test/domain/services/confirmation_word_matcher_test.dart
import 'package:catchlaw/domain/services/confirmation_word_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfirmationWordMatcher', () {
    test('.matches accepts a differently cased word', () {
      expect(const ConfirmationWordMatcher(expected: 'REPLACE').matches('replace'), isTrue);
    });

    test('ar - .matches accepts the word with a leading definite article', () {
      expect(const ConfirmationWordMatcher(expected: 'استبدال').matches('الاستبدال'), isTrue);
    });

    test('ar - .matches accepts the word with harakat', () {
      expect(const ConfirmationWordMatcher(expected: 'استبدال').matches('اسْتِبْدال'), isTrue);
    });

    test('.matches rejects an empty string', () {
      expect(const ConfirmationWordMatcher(expected: 'REPLACE').matches(''), isFalse);
    });
  });
}
```

```dart
// app/test/domain/use_cases/replace_import_test.dart
import 'package:catchlaw/domain/use_cases/replace_import.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/in_memory_user_database.dart';
import '../../../testing/models/portability_fixtures.dart';

void main() {
  late InMemoryUserDatabase db;

  setUp(() async => db = await InMemoryUserDatabase.open());
  tearDown(() async => db.close());

  group('ReplaceImport', () {
    test('.call leaves the database unchanged when the restore fails midway', () async {
      await db.seed(kSeedThreeTripsTwentyCatches);
      final before = await db.snapshot();

      final result = await ReplaceImport(db).call(kEnvelopeFailingAtCatch12);

      expect(result, isA<Err<ReplaceReport>>());
      expect(await db.snapshot(), before);
    });

    test('.call unlinks no photo file when the transaction rolls back', () async {
      final photos = await db.seedWithPhotos(kSeedThreePhotos);

      await ReplaceImport(db).call(kEnvelopeFailingAtCatch12);

      for (final photo in photos) {
        expect(photo.existsSync(), isTrue);
      }
    });

    test('.call deletes catches before trips', () async {
      final recorder = RecordingUserDatabase(db);

      await ReplaceImport(recorder).call(kEnvelopeGaliciaTwoTrips);

      expect(recorder.deleteOrder, <String>['catch', 'trip', 'saved_zone', 'rule_flag',
        'species_recent']);
    });

    // … one test per row in the table above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/domain/use_cases/replace_import_test.dart test/domain/services/confirmation_word_matcher_test.dart test/ui/settings/import/replace_confirm_dialog_test.dart`
→ 24 failures (row 16 counts as six). If row 23 passes now the test is wrong — with no
implementation nothing unlinks anything, so it is asserting a tautology; make it assert the files
existed first.

## Implementation outline

1. Write `ConfirmationWordMatcher` on top of the shared fold from `packages/rule_engine/`. It calls
   the same function E02 built and `tools/content_builder/` uses — not a copy (§9.4: "One shared
   function"). Trim, fold, compare.
2. Add the eight ARB keys to all six locale files (D-3). `importReplaceConfirmWord` needs a
   native-speaker pass per §9.2; the `ar` value is Arabic script, and a test asserts it.
3. Write `ReplaceOutcome` and `ReplaceConfirmDialog`: `FocusScope`, `autofocus` on the text field
   (never on the destructive action — `modal-decision-matrix.md` §4, a stray Enter would confirm it),
   the confirm as `LonjaButton.destructive` disabled until the matcher returns true, the cancel as
   `LonjaButton.quiet` labelled with the preservation, and a reason line while disabled.
4. Open it with `showLonjaDialog<ReplaceOutcome>(barrierDismissible: false, …)`, capturing
   `FocusManager.instance.primaryFocus` before and restoring it after, guarded by
   `if (!context.mounted) return;`.
5. Write `ReplaceImport`: one drift `transaction()` — delete `catch`, `trip`, `saved_zone`,
   `rule_flag`, `species_recent`, in that order; insert the file's trips, capture ids, insert its
   catches with remapped `trip_id`, then zones and flags; reset `user_profile` to the file's values,
   keeping `id = 1`.
6. After the transaction commits, diff the pre-wipe photo file list against the restored
   `photo_path` set and unlink the orphans. On a rollback, unlink nothing.
7. Wire the dialog into `ImportPreviewViewModel` (T06): `Replace everything` is a
   `LonjaButton.destructive` on S16 that opens the dialog and, on `ReplaceOutcome.replaced`, runs
   `ReplaceImport`.
8. Re-run the suite. All 24 green, and every T06 merge test still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 24 tests pass, and each failed first.
- [ ] `importReplaceConfirmWord` exists in all six locales and the `ar` value is Arabic script.
- [ ] The comparison calls the shared normalisation from `packages/rule_engine/` — not a local copy,
      and not `toLowerCase()` alone.
- [ ] `barrierDismissible: false` is passed explicitly; the gate's check 4 is clean.
- [ ] The dialog returns `ReplaceOutcome`; no `bool` and no `true`/`false` pop anywhere in the file.
- [ ] No `OK`, `Cancel`, `Yes`, `No`, `Confirm` or `Dismiss` literal exists in the dialog.
- [ ] The confirm is `LonjaButtonVariant.destructive`, and S16 still builds exactly one
      `LonjaButtonVariant.primary`.
- [ ] Focus is captured before the dialog opens and restored after it pops.
- [ ] The wipe and the restore share one transaction, and a failing restore leaves row counts and
      photo files exactly as they were.
- [ ] Orphaned photo files are unlinked only after the transaction commits.
- [ ] Line coverage on `replace_import.dart` is ≥ 95%.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh        app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh    app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh   app/lib
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh     app/lib
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
feat(import): wipe and restore behind a typed confirmation word

Replace is the only operation in the product that destroys everything with no
undo, and at 05:40 with wet hands a red button is muscle memory. A typed word
is the only affordance a bounced tap cannot produce. D1's 8-second deferred
write does not apply: that trick holds one row in memory, and holding an
entire user.db there so a snackbar can cancel it is a second database.

The word is an ARB value per locale, not an English constant — an Arabic
keyboard does not produce Latin letters, and a fisher who cannot type the
word cannot restore his own backup. The comparison runs through the shared
§9.4 fold from packages/rule_engine, so الاستبدال and اسْتِبْدال both match
استبدال. Being generous about how it is typed costs nothing; the protection
is that it is typed at all.

Wipe and restore share one transaction, catches deleted before trips so
ON DELETE SET NULL does not rewrite 8,000 rows on the way out. Orphaned photo
files are unlinked only after the commit: files are not transactional, and
unlinking first destroys what a rollback would have kept. Unlike Merge, this
path does restore ruler_px_per_mm — and the confirmation states that as a
fact, because a silently changed ruler is the one consequence a fisher cannot
detect.

Task: E17/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
