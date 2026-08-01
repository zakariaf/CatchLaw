# E10/T08 — Flag this rule

| | |
|---|---|
| **Epic** | E10 — The result screen |
| **Branch** | `epic/10-result` (shared) |
| **Commit** | `feat(result): record a local flag against a rule row` |
| **Depends on** | T01 (the rule identity on the display), T05 (the citation reference stored with the flag), E05 (`user.db`) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.7 "Flag a wrong rule", §6 S2 "Flag this rule", §7.2 `rule_flag`, §12 (the export that carries it) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-conventions-index` | Invariant 1 and rule 11 — no identifier leaves the device, and the allow-list that excludes any compose or send path here |
| `persistence-drift` | The DAO and repository shape, one transaction per mutation, persist-before-publish, no drift symbol past the repository |
| `state-management-riverpod` | Rules 5 and 7 — a single write path through a repository, injected rather than constructed |
| `catchlaw-verdict-contract` | The note UI is user copy too: no second person, no inference, no health vocabulary |
| `lonja-dialogs-and-surfaces` | Why this is an inline panel rather than a modal, and the snackbar policy for the confirmation |
| `lonja-forms-and-controls` | The text field and its label — this task's only form control |
| `accessibility-as-code` | Rules 1 and 8 — the action is a labelled ≥ 44 dp target, ≥ 56 dp in glove mode |
| `error-handling-typed-results` | The repository returns a typed result; a failed write is a value, not a thrown exception on the result screen |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.7 "Flag a wrong rule" | Records a local note against the rule row, included in every export, **composes nothing and sends nothing** |
| `SPEC.md` | §7.2 `rule_flag` DDL | The four columns: `rule_id`, `citation_ref`, `note`, `created_at` |
| `SPEC.md` | §12 | That the export reads this table, so the row shape is a contract with E17 |
| `SPEC.md` | §5 "Deliberately excluded" | Sharing is an auto-reject; the app never becomes a submission channel |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | Invariant 1 "Allowed" | `Share.shareXFiles` for a user-initiated export, `url_launcher` for `mailto:`/`tel:` on the about screen — and nothing here |
| `.claude/skills/lonja-dialogs-and-surfaces/references/modal-decision-matrix.md` | §1, §8 | The single question that makes a modal, and the snackbar rules for the confirmation |
| `.claude/skills/catchlaw-verdict-contract/references/verdict-copy-rules.md` | "The grep lexicon" | Families B, C and D apply to this panel's copy as much as to a verdict |
| `FLUTTER_GUIDE.md` | §2.5 rules 4, 5 and 6 | Abstract repository plus a fake, `Future<Result<T>>` return, drift rows never escaping `data/` |

## What this delivers

- `app/lib/data/repositories/rule_flag_repository.dart` — the abstract interface, one method
  `Future<Result<void>> flag(RuleFlagDraft draft)` plus `Stream<List<RuleFlag>> watchAll()`.
- `app/lib/data/repositories/rule_flag_repository_drift.dart` — the drift implementation writing
  `user.db`'s `rule_flag` in one transaction.
- `app/testing/fakes/fake_rule_flag_repository.dart`.
- `app/lib/ui/result/view_models/flag_rule_viewmodel.dart` — validates the note and calls the
  repository; holds no `BuildContext`.
- `app/lib/ui/result/widgets/result_flag_panel.dart` — the inline panel: the **Flag this rule**
  action, a note field, and a save target whose label names its effect.
- `app/test/data/rule_flag_repository_test.dart`, `app/test/ui/result/result_flag_panel_test.dart`,
  `app/test/ui/result/flag_rule_viewmodel_test.dart`.

## Why it is built this way

**It composes nothing and sends nothing, and that is the feature.** §4.7 states it in bold: the flag
"records a local note against the rule row… **Composes nothing and sends nothing.** The user exports
and mails it themselves if they choose." The moment this action opens a mail composer, the app has a
submission channel; §5 auto-rejects sharing, invariant 1 forbids the network path, and
`check_app_invariants.sh` check 1 fails on the symbols that would implement it. A test in this task
greps the feature for `Share`, `mailto:`, `launchUrl` and `http` so the absence is asserted rather
than assumed — because the natural next request is "send this to us", and the refusal needs to be
visible in the test file rather than only in the spec.

**The row is a contract with E17.** §12's export reads `rule_flag`, so `rule_id`, `citation_ref`,
`note` and `created_at` must all be populated here — including `citation_ref`, which is what makes a
flag legible three years later after a content update has renumbered the rule. §7.2's note on
`catch` explains the principle for the same reason: history is immutable, and a denormalised
reference survives a content update that a foreign key would not.

**An inline panel, not a modal.** `modal-decision-matrix.md` §1 asks one question: can the user do
anything useful while this surface is on screen? Writing a note is not a decision the app cannot
proceed without — he can put the phone down mid-sentence and read the verdict again. So it is an
inline `LonjaPanel` that expands under the action, ruled and inset, with no barrier. That also keeps
`check_lonja_dialogs.sh` check 1 satisfied without a `*_dialog.dart` file that would not have earned
its barrier.

**The confirmation is a snackbar and the write is not deferred.** §8's snackbar rule allows an
informational receipt for something already committed. A flag is not destructive and has no undo
window in §4.7, so the write commits first and the snackbar states the completed fact ("Note saved on
this device", 4 s, no action). The 8-second deferred-write pattern belongs to deletes, and borrowing
it here would leave the note in memory across a process death for no benefit.

**An empty note writes nothing.** A `rule_flag` row with an empty `note` is indistinguishable from a
mis-tap and would export as noise. The view model returns a validation failure and the panel states
it; `note` is `NOT NULL` in §7.2 and the schema is not the place to discover an empty string.

**The panel's copy is verdict copy.** It sits on the result surface, so
`check_verdict_contract.sh`'s second-person sweep can reach it and the grep lexicon applies. The
action reads "Flag this rule"; the field label reads "What is wrong with this rule row?"; the save
target reads "Save this note on the device" — naming its effect, per the destructive-label rule
applied to a non-destructive action. No "you", no "we will look into it" (a promise the app cannot
keep offline), no "report".

**Rejected — a `Share.shareXFiles` of the note.** §4.7's bold sentence, and it would make the app the
transport for a user's complaint about a legal instrument.

**Rejected — writing the flag into `reference.db`.** It is opened `readOnly: true` (invariant 7,
D-6), and a write would leave a `-wal` beside a file whose sha256 is checked on every launch.

**Rejected — a global "flagged rules" screen in this task.** E16 owns Settings and E17 owns export;
the flag is visible where it was made and in the export. Adding a third surface here is scope this
epic does not have.

## Tests first

Write every row before touching the repository. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `DriftRuleFlagRepository.flag writes one row with all four columns populated` | a full draft | one `rule_flag` row, `rule_id`, `citation_ref`, `note`, `created_at` all non-null | §7.2's shape, and E17's export contract |
| 2 | `DriftRuleFlagRepository.flag stores the citation reference as text` | citation `MD 580/2015, Art. 3` | `citation_ref` holds that string | A renumbered rule after a content update leaves the note legible |
| 3 | `DriftRuleFlagRepository.flag commits in one transaction` | a draft | the row is present after the future completes, absent before | Persist-before-publish; a partially written flag is not a flag |
| 4 | `DriftRuleFlagRepository.flag leaves the reference database untouched` | a draft | `reference.db` mtime and sha256 unchanged | The shipped DB is read-only; a write breaks every later integrity check |
| 5 | `DriftRuleFlagRepository.watchAll emits again after a flag` | flag twice | two emissions, second with two rows | E17 reads a stream, and a stale stream exports a stale set |
| 6 | `FlagRuleViewModel.save rejects an empty note` | note `''` | a validation failure, no repository call | An empty row exports as noise and is indistinguishable from a mis-tap |
| 7 | `FlagRuleViewModel.save rejects a whitespace-only note` | note `'   '` | a validation failure | The trimmed case the first regex will get wrong |
| 8 | `FlagRuleViewModel.save passes the rule id and citation reference through unchanged` | a display with rule 41 | the draft carries rule 41 and its citation | A flag against the wrong rule row is worse than no flag |
| 9 | `FlagRuleViewModel.save stamps created_at from the injected clock` | fixed clock | `created_at` equals the fixed instant | No `DateTime.now()` in state logic; a wall clock is untestable |
| 10 | `ResultFlagPanel writes a flag and states the completed fact` | fill and save | the repository received one draft; a snackbar states the fact | The receipt for something already committed |
| 11 | `ResultFlagPanel keeps the verdict unchanged after a flag` | save | the stamp, table and citation strings are unchanged | Flagging records a doubt; it does not alter what the instrument says |
| 12 | `ResultFlagPanel opens no modal` | tap the action | no `Dialog`, no `ModalBarrier` | Writing a note is not a decision the app cannot proceed without |
| 13 | `ResultFlagPanel reaches no compose or send path` | source grep over the feature | no `Share`, `mailto:`, `launchUrl`, `http`, `Intent` | §4.7's bold sentence, asserted in the suite so the refusal is visible |
| 14 | `ResultFlagPanel labels the save target with its effect` | open | the label names saving on the device, and is not `OK` | A label that does not state its effect is confirmed by reflex at 05:40 |
| 15 | `ResultFlagPanel contains no second person in its copy` | open | no `you`/`your` in any rendered string | The panel is on the result surface and the contract sweep reaches it |
| 16 | `ResultFlagPanel exposes the action at 56 dp in glove mode` | glove on | height ≥ 56 | §4.9's glove floor |
| 17 | `ResultFlagPanel survives a 200% text scale with no overflow` | `textScaler: 2.0` | no overflow exception | A text field plus two labels is where 200% breaks first |
| 18 | `RTL - ResultFlagPanel aligns the note field to the start edge` | locale `ar` | field content starts at the start edge | Directional geometry on the one input on this screen |
| 19 | `DriftRuleFlagRepository.flag survives a process restart` | flag, reopen the database | the row is still there | The note is the user's own record; losing it silently is the failure |

```dart
// app/test/data/rule_flag_repository_test.dart
import 'package:catchlaw/data/repositories/rule_flag_repository_drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/models/result_fixtures.dart';

void main() {
  late UserDatabase db;
  late DriftRuleFlagRepository repo;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    repo = DriftRuleFlagRepository(db.ruleFlagDao);
  });

  tearDown(() => db.close());

  group('DriftRuleFlagRepository', () {
    test('.flag writes one row with all four columns populated', () async {
      await repo.flag(kRuleFlagDraftAmeixa);

      final rows = await db.ruleFlagDao.all();
      expect(rows, hasLength(1));
      expect(rows.single.ruleId, kRuleFlagDraftAmeixa.ruleId);
      expect(rows.single.citationRef, 'Orde 27/07/2012, Art. 12');
      expect(rows.single.note, isNotEmpty);
      expect(rows.single.createdAt, isNotNull);
    });

    test('.watchAll emits again after a flag', () async {
      final emissions = <int>[];
      final sub = repo.watchAll().listen((rows) => emissions.add(rows.length));

      await repo.flag(kRuleFlagDraftAmeixa);
      await repo.flag(kRuleFlagDraftHamour);
      await pumpEventQueue();
      await sub.cancel();

      expect(emissions.last, 2);
    });
  });
}
```

```dart
// app/test/ui/result/result_flag_panel_test.dart — the refusal, asserted
test('ResultFlagPanel reaches no compose or send path', () {
  final source = Directory('lib/ui/result')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .map((f) => f.readAsStringSync())
      .join('\n');

  for (final banned in const <String>[
    'Share.', 'shareXFiles', 'mailto:', 'launchUrl', 'package:http', 'AndroidIntent',
  ]) {
    expect(source.contains(banned), isFalse,
        reason: 'the flag composes nothing and sends nothing (SPEC §4.7)');
  }
});
```

**Run:** `cd app && flutter test test/data/rule_flag_repository_test.dart test/ui/result/` → 19 new
failures. If any passes now, the test is wrong.

## Implementation outline

1. Add the `rule_flag` DAO to E05's `UserDatabase` if it does not already exist, and the abstract
   `RuleFlagRepository` with its drift implementation and its fake. The DAO returns domain values;
   no drift row class escapes `data/`.
2. `RuleFlagDraft` is an immutable domain value in `app/lib/domain/models/` carrying `ruleId`,
   `citationRef`, `note` and `createdAt`.
3. `FlagRuleViewModel`: a `Notifier` over an immutable state value holding the draft note and the
   last outcome. `save()` trims, rejects empty, stamps `createdAt` from the injected clock provider,
   and calls the repository once. It never holds a `BuildContext` and never shows the snackbar
   itself — the view listens and performs the UI action.
4. `ResultFlagPanel`: the **Flag this rule** action expands an inline ruled panel with the note field
   and the save target. `ref.listen` on the view model's outcome shows the snackbar
   (`SnackBarBehavior.fixed`, 4 s, no action) and collapses the panel.
5. Add the ARB keys for the action, the field label, the save label and the receipt, each with a
   constraint-carrying `@description`, mirrored into all six locales.
6. Wire the panel into `ResultSection`'s action slot, below the citation and above the disclaimer.
7. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 tests pass, and each failed first.
- [ ] `grep -rnE "Share\.|shareXFiles|mailto:|launchUrl|package:http" app/lib/ui/result app/lib/data/repositories/rule_flag_repository_drift.dart`
      returns nothing.
- [ ] The repository has an abstract interface and a fake in `app/testing/fakes/`.
- [ ] Every public repository method returns `Future<Result<T>>` or `Stream<T>`.
- [ ] No drift row class appears outside `app/lib/data/`.
- [ ] `reference.db` is never opened writable by this path.
- [ ] The panel's copy passes `check_verdict_contract.sh` including the second-person sweep.
- [ ] The four `rule_flag` columns are all populated, and E17's export can read them unchanged.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh       app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh    app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh     app/lib
tools/gates/no_directional_geometry.sh                                      app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(result): record a local flag against a rule row

SPEC §4.7 is explicit that the flag composes nothing and sends nothing —
the user exports and mails it himself if he chooses. So the write goes to
user.db's rule_flag and stops there, and a test greps the whole feature for
Share, mailto:, launchUrl and http, because the natural next request is
"send this to us" and the refusal should be visible in a test file rather
than only in the spec.

citation_ref is stored as text beside rule_id for the same reason catch
denormalises its citation: a content update can renumber a rule, and a
three-year-old note has to stay legible. An empty note is rejected before
the repository is called; an empty row exports as noise.

Task: E10/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
