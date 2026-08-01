# E13/T07 — S11: edit, and delete with ten seconds of undo

| | |
|---|---|
| **Epic** | E13 — The catch log |
| **Branch** | `epic/13-catch-log` (shared) |
| **Commit** | `feat(log): edit a catch and delete it behind a ten-second deferred write` |
| **Depends on** | T04 (the photo file to unlink), T05 (the coordinate control), T06 (S10, which is where S11 is opened from and where a pending delete must disappear) |
| **Size** | M |
| **Spec** | `SPEC.md` §6 S11 and dialog D1, §4.5 (Edit and delete — "delete undoable for 10 seconds"), §7.2 (`catch`), §13 (crash safety) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-dialogs-and-surfaces` | Rules 2, 3, 4, 7, 8, 9 and `references/modal-decision-matrix.md` — the typed result, the consequence-naming labels, `barrierDismissible: false`, focus return, and the deferred-write undo window. |
| `error-handling-typed-results` | Rules 4 and 11, plus `references/never-lose-data.md` §1 and §3 — the transaction, and the soft-delete design this task deliberately does **not** adopt. |
| `persistence-drift` | Rule 4: one transaction per mutation, every statement awaited, persist before publish. |
| `state-management-riverpod` | Rule 9 (cascade-clean references on delete) and the ViewModel that owns the pending-deletion set above the route, so the undo survives S11 popping. |
| `catchlaw-conventions-index` | Invariants 2 and 3: an edited record still states a fact and still carries a citation, and rule 9's tie-break — the more specific skill wins where two disagree. |
| `lonja-buttons` | Rule 12: the destructive action is oxblood, is never the screen's primary, and its confirmation repeats the same verb. |
| `accessibility-as-code` | Rules 1, 5, 8: S11 is a form, and a form at 200% text scale is where `ellipsis` and `FittedBox` get reached for. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S11 and "Dialogs" D1 | "all fields editable · photo · coordinates with a clear on/off state · delete with undo"; D1 is "Delete confirmation (with undo)" |
| `SPEC.md` | §4.5 row "Edit and delete" | "Any record editable; delete undoable for 10 seconds" |
| `SPEC.md` | §7.2 | The columns an edit may write, and the paragraph explaining why four of them are denormalised |
| `SPEC.md` | §12 "Import (S16)" | The merge key, which is why `created_at` is not editable (epic Risks 11) |
| `.claude/skills/lonja-dialogs-and-surfaces/references/modal-decision-matrix.md` | §2 (the matrix row "Delete a saved catch entry"), §3, §4, §5, §6, §8 | `DeleteOutcome` by name, `barrierDismissible: false`, back intercepted → `dismissed`, the exact confirm and cancel labels, the deferred-write rule and "never stack" |
| `.claude/skills/lonja-dialogs-and-surfaces/SKILL.md` | Rules 2, 3, 8, 9 | Typed result, banned literals, the snackbar's single optional action |
| `$FLUTTER_SKILLS/error-handling-typed-results/references/never-lose-data.md` | §1 and §3 | The transaction shape, and the optimistic soft-delete/Trash design this task rejects with a reason |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §2, §3 | The edited record still states a fact and still names its instrument |
| `.claude/skills/lonja-buttons/SKILL.md` | Rule 12 | Oxblood, never primary, and the confirmation repeats the verb |
| `epics/E13-catch-log/epic.md` | Risks 2, 11 | Ten seconds beats the skill's eight; `created_at` is not editable and why |

## What this delivers

- `app/lib/data/repositories/catch_log_repository.dart` — `update(CatchEdit)` and `delete(int id)`
  added to the interface; the drift implementation of both.
- `app/lib/domain/models/catch_edit.dart` — the edit payload, with the verdict-bearing fields
  separated from the rest at the type level.
- `app/lib/domain/use_cases/re_evaluate_catch_use_case.dart` — re-runs `packages/rule_engine/` when a
  verdict-bearing field changed, and produces the four replacement literals.
- `app/lib/ui/log/catch_detail_screen.dart` — S11.
- `app/lib/ui/log/view_models/catch_detail_view_model.dart`.
- `app/lib/ui/log/widgets/delete_catch_dialog.dart` — D1, returning `enum DeleteOutcome { deleted,
  kept, dismissed }`.
- `app/lib/ui/log/view_models/pending_deletion_notifier.dart` — a `keepAlive` `Notifier` holding the
  set of ids inside their undo window, above the route so the window survives S11 popping.
- `app/lib/ui/log/widgets/undo_snackbar.dart` — the ten-second `SnackBarBehavior.fixed` slab.
- S10's list filters out any id in the pending set; the totals in T06's panel do too.
- ARB keys ×6 for every field label, both dialog labels, the dialog body and the snackbar.
- Tests: `app/test/data/repositories/catch_edit_test.dart`,
  `app/test/ui/log/delete_catch_dialog_test.dart`,
  `app/test/ui/log/pending_deletion_test.dart`,
  `app/test/ui/log/catch_detail_screen_test.dart`.

## Why it is built this way

**An edit to a verdict-bearing field re-evaluates; an edit to anything else does not touch the
denormalised columns.** This is the one place the immutability contract needs a careful reading. §7.2
says history is immutable so that *a content update* cannot rewrite it — the threat is a silent change
by the pipeline, not a deliberate change by the fisher. If he corrects a mistyped 38 cm to 48 cm and
`outcome_detail` still reads "Below the minimum — 38 cm, minimum 45 cm", the row now contradicts its
own numbers, which is worse than either alternative. So:

- **Verdict-bearing:** `species_id`, `length_mm`, `measurement_code`, `jurisdiction_code`,
  `zone_code`. Changing any one re-runs the engine against the **currently installed** pack and
  rewrites `outcome`, `outcome_detail`, `rule_citation_ref` **and** `content_version` together, in one
  transaction. `content_version` moves with them, so the row still names the pack behind the statement
  it is showing.
- **Not verdict-bearing:** `was_kept`, `photo_path`, `latitude`, `longitude`, `trip_id`. These leave
  the four denormalised columns byte-identical.

**Rejected:** keeping the old statement beside a new length — a record that contradicts itself, and the
one an inspector would notice. **Rejected:** refusing to edit length at all — §6 S11 says all fields
editable, and a log you cannot correct is a log people stop keeping. **Rejected:** re-evaluating
against the pack named by the row's stored `content_version` — that pack may no longer be installed,
and there is exactly one `reference.db` on the device (`two-database-contract.md`).

**`created_at` is not editable.** It is when the *record* was written, and §12 uses it as part of the
merge key. Editing it would change a row's identity for E17's importer. That leaves §6 S11's "all
fields editable" not literally satisfied; epic Risks 11 records the gap and what would close it.

**Delete defers its write for the whole window.** `lonja-dialogs-and-surfaces` rule 9 is explicit
about why: writing first and reversing on undo means a crash inside the window makes an "undoable"
delete permanent with no trace. The row is held in a pending set, S10 filters it out immediately so
the list behaves as the fisher expects, and the `DELETE` runs only when the snackbar closes for a
reason other than its action. A process killed inside the window therefore leaves the row — the safe
direction, by construction, for the only data in the product that exists nowhere else (§13).

**The window is ten seconds, per `SPEC.md` §4.5.** The skill says eight. `SPEC.md` is authoritative
for the product and `check_lonja_dialogs.sh` does not inspect durations. Epic Risks 2 records the
divergence and the one-line skill correction that would close it. **Do not re-argue it here.**

**An orderly background commits; a crash does not.** On `AppLifecycleState.paused` the pending delete
is committed and the snackbar closed, because the fisher already confirmed it through a modal whose
button named the consequence — a confirmed destructive write must not be left owned by a process the
OS may kill at any moment. A kill *without* a pause is a crash, nothing is committed, and the row
survives. Both halves are tested.

**Rejected: optimistic soft-delete with `is_deleted` and a Trash screen.**
`error-handling-typed-results` rule 11 and `never-lose-data.md` §3 describe exactly that design, and it
is the right default for most apps. It is wrong here for three reasons that are all local:
`SPEC.md` §7.2 publishes no `is_deleted` or `deleted_at` column on `catch` and §12's export format is
written against those columns; §6's screen inventory has no Trash screen and inventing one adds a
surface nobody specified; and §12's Merge and Replace would each need a policy for soft-deleted rows,
which is a portability decision E17 owns. `catchlaw-conventions-index` rule 9 gives the tie-break —
where two skills both apply, the more specific one wins — and `lonja-dialogs-and-surfaces` is the
CATCHLAW-specific skill here. The gain the general design offers, a survivable delete, is bought
instead by deferring the write.

**Never two snackbars.** `modal-decision-matrix.md` §8: `hideCurrentSnackBar()` before showing a
second, never stack. A second delete inside the first's window therefore closes the first snackbar,
which commits the first delete — the fisher already had his ten seconds and chose to delete something
else. Test 14 pins that so nobody later "improves" it into a queue that silently extends the first
window.

**The photo file is unlinked after the row is gone, never before.** Same argument as T04 and as
E17's Replace path: the crash window must leave an orphan file, which T08 reclaims, rather than a row
pointing at nothing, which renders blank forever with no error.

## Tests first

Write every row before touching `catch_detail_screen.dart`. Run them. **They must fail.** A row that
passes now is testing nothing — fix the test first.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `CatchLogRepository.update bumps updatedAt and leaves createdAt unchanged` | any edit, `Clock.fixed` | `updated_at` = clock, `created_at` unchanged | §12 merges on `created_at` and tiebreaks on `updated_at`; swapping them loses the edit on the next merge |
| 2 | `CatchLogRepository.update rewrites the four denormalised columns when the length changes` | 38 → 48 mm-scaled | `outcome`, `outcome_detail`, `rule_citation_ref`, `content_version` all replaced | A corrected length beside the old statement is a record that contradicts its own numbers |
| 3 | `CatchLogRepository.update leaves the four denormalised columns byte-identical when only wasKept changes` | kept → released | all four unchanged, character for character | The immutability half: a non-verdict edit must not re-run the engine and quietly restate a three-year-old row under today's pack |
| 4 | `CatchLogRepository.update rewrites contentVersion to the installed pack when it re-evaluates` | length edit under a newer pack | `content_version` is the installed one | The row must always name the pack behind the statement it is currently showing |
| 5 | `CatchLogRepository.update rewrites the denormalised columns when the measurement method changes` | TL → FL | all four replaced | The method changes which number the rule compares; §4.2 makes it per-species-per-jurisdiction |
| 6 | `CatchLogRepository.update rewrites the denormalised columns when the zone changes` | zone A → zone B | all four replaced | §7.3 resolves by zone; the same fish in the next bank is a different rule |
| 7 | `CatchLogRepository.update rolls back entirely when the re-evaluation write fails` | forced violation | `Err`, `dumpAllRows()` byte-identical | `never-lose-data.md` §1. A half-applied edit leaves a new length beside an old verdict — the exact state case 2 exists to prevent |
| 8 | `CatchLogRepository.update refuses to change createdAt` | an edit carrying a new `created_at` | stored value unchanged | Epic Risks 11, at the repository so no future screen can do it either |
| 9 | `DeleteCatchDialog sets barrierDismissible to false` | open the dialog | `false`, explicitly | `modal-decision-matrix.md` §3: a stray wet-hand tap outside must not resolve a legally weighted question |
| 10 | `DeleteCatchDialog returns DeleteOutcome.dismissed when the back button is pressed` | system back | `DeleteOutcome.dismissed` | The third outcome a `bool?` would collapse into "declined" — and on a destructive path the null branch is how a record disappears unconfirmed |
| 11 | `DeleteCatchDialog labels its confirm and cancel with their consequences` | open | "Delete this catch entry" and "Keep the entry" | `modal-decision-matrix.md` §5 names both strings; `check_lonja_dialogs.sh` fails on `OK`/`Cancel` |
| 12 | `PendingDeletion commits the delete ten seconds after the snackbar opens` | `fake_async`, no undo | row present at 9 s, absent at 10 s | `SPEC.md` §4.5's number, asserted on both sides so the window is real rather than incidental (epic Risks 2) |
| 13 | `PendingDeletion writes nothing when undo is tapped` | undo at 3 s | no `DELETE` ever issued, row unchanged | The point of deferring: an undone delete is not a reversed write, it is a write that never happened |
| 14 | `PendingDeletion commits the first delete when a second delete starts inside its window` | delete A, then B at 4 s | A committed, B pending | `modal-decision-matrix.md` §8 — never stack. A queue would silently extend A's window past what the fisher was told |
| 15 | `PendingDeletion commits the pending delete when the app is paused` | `AppLifecycleState.paused` at 5 s | row deleted, snackbar closed | A confirmed destructive write must not be left owned by a process the OS may kill |
| 16 | `PendingDeletion leaves the row intact when its owner is disposed without a pause` | dispose at 5 s, no lifecycle event | row present, no `DELETE` | The crash case, and the reason the write is deferred at all |
| 17 | `PendingDeletion hides the row from history for the whole window` | delete, then read S10's page | the id is absent from the page and from the totals | An optimistic-looking list over a deferred write; if the totals are not filtered too they disagree with the rows above them |
| 18 | `PendingDeletion unlinks the photo file only after the row is deleted` | catch with a photo, window elapses | row gone, then file gone | The crash window must leave an orphan file, not a row pointing at nothing |
| 19 | `PendingDeletion leaves the photo file when undo is tapped` | undo at 3 s | file present | The inverse; unlinking eagerly would make undo restore a row whose photo renders blank forever |
| 20 | `CatchDetailScreen restores focus to the opener after the dialog pops` | open and dismiss D1 | the opening control holds focus | `lonja-dialogs-and-surfaces` rule 7 — otherwise TalkBack drops to the top of the route and the user re-reads the whole record |
| 21 | `CatchDetailScreen renders every editable field at 200% text scale without overflow` | `TextScaler.linear(2.0)` | no overflow | `accessibility-as-code` rules 4 and 5: this is the screen where `ellipsis` gets reached for, and reaching for it is the defect |
| 22 | `ar - DeleteCatchDialog orders its action row directionally` | `ar` golden | actions mirrored by `Directionality`, not by a hand-swapped list | `modal-decision-matrix.md` §4 defers directional geometry to `i18n-rtl-l10n`; a hand swap breaks the moment a third action appears |

```dart
// app/test/data/repositories/catch_edit_test.dart
void main() {
  test('CatchLogRepository.update leaves the four denormalised columns byte-identical '
      'when only wasKept changes', () async {
    await repo.record(kDraftShari);                 // judged under v2026.2
    final before = await db.select(db.catches).getSingle();

    await installReferenceFixture(kRenumberedPack); // a newer pack is now installed
    await repo.update(CatchEdit.wasKept(id: before.id, wasKept: false));

    final after = await db.select(db.catches).getSingle();
    expect(after.outcome, before.outcome);
    expect(after.outcomeDetail, before.outcomeDetail);
    expect(after.ruleCitationRef, before.ruleCitationRef);
    expect(after.contentVersion, before.contentVersion); // still v2026.2
    expect(after.wasKept, isFalse);
  });

  test('CatchLogRepository.update rewrites the four denormalised columns when the length changes',
      () async {
    await repo.record(kDraftShariBelowMinimum);
    final before = await db.select(db.catches).getSingle();

    await repo.update(CatchEdit.length(id: before.id, lengthMm: 480));

    final after = await db.select(db.catches).getSingle();
    expect(after.outcome, CatchOutcome.meets.name);
    expect(after.outcomeDetail, isNot(before.outcomeDetail)); // no self-contradicting row
    expect(after.createdAt, before.createdAt);                // identity is untouched
  });
}
```

```dart
// app/test/ui/log/pending_deletion_test.dart
void main() {
  test('PendingDeletion commits the delete ten seconds after the snackbar opens', () {
    fakeAsync((async) {
      notifier.beginDelete(kCatchId);

      async.elapse(const Duration(seconds: 9));
      expect(dao.rowCount, 1);            // still there — SPEC §4.5 promises ten
      async.elapse(const Duration(seconds: 1));
      expect(dao.rowCount, 0);
    });
  });

  test('PendingDeletion writes nothing when undo is tapped', () {
    fakeAsync((async) {
      notifier.beginDelete(kCatchId);
      async.elapse(const Duration(seconds: 3));
      notifier.undo(kCatchId);
      async.elapse(const Duration(seconds: 30));

      expect(dao.deleteCalls, 0);         // not reversed — never issued
      expect(dao.rowCount, 1);
    });
  });

  test('PendingDeletion leaves the row intact when its owner is disposed without a pause', () {
    fakeAsync((async) {
      notifier.beginDelete(kCatchId);
      async.elapse(const Duration(seconds: 5));
      container.dispose();                // the crash case
      async.elapse(const Duration(seconds: 30));

      expect(dao.deleteCalls, 0);
      expect(dao.rowCount, 1);
    });
  });
}
```

```dart
// app/test/ui/log/delete_catch_dialog_test.dart
testWidgets('DeleteCatchDialog returns DeleteOutcome.dismissed when the back button is pressed',
    (tester) async {
  final outcome = _openDialog(tester);
  await tester.pageBack();
  await tester.pumpAndSettle();

  expect(await outcome, DeleteOutcome.dismissed); // never null, never `false`
});
```

**Run:** `cd app && flutter test test/data/repositories/catch_edit_test.dart test/ui/log` →
22 failures.

## Implementation outline

1. `catch_edit.dart` — model the split at the type level, so "did this edit change the verdict?" is a
   question the compiler answers rather than a list of field names someone maintains. A sealed
   `CatchEdit` with `VerdictBearingEdit` and `PlainEdit` subtypes is the shape; the repository switches
   on it exhaustively with no `default:`.
2. `re_evaluate_catch_use_case.dart` — takes the edited values, resolves the rules for the *edited*
   zone through `ReferenceRepository`, calls the engine, and returns the four replacement literals plus
   the installed `content_version`. The sentence is rendered by the same code path E10 uses; nothing
   here composes a string of its own (D-7).
3. `update()` in the drift repository — prep outside, one transaction inside, every statement awaited.
   `created_at` is never in the companion.
4. `delete_catch_dialog.dart` — the filename matters: `check_lonja_dialogs.sh` only permits
   `showDialog` inside `/core/` or a `*_dialog.dart`. `barrierDismissible: false` explicitly, a
   `FocusScope` with `autofocus` on **Keep the entry** (never on the destructive action), the captured
   opener refocused after the await behind an `if (!context.mounted) return;`.
5. `pending_deletion_notifier.dart` — a `keepAlive` `Notifier<Set<int>>` at app scope. It owns the
   timer, the commit, the photo unlink and the lifecycle observer. It is above the route, so popping
   S11 does not cancel the window.
6. S10 and T06's totals panel both read the pending set with `.select` and filter it out. One filter,
   both surfaces — the parity point `never-lose-data.md` §3 makes about soft-delete applies just as
   hard to a pending set.
7. `catch_detail_screen.dart` — the form. Every control ≥ 44 dp; no `ellipsis`, no `FittedBox`; the
   coordinate row from T05 and the photo control from T04 mounted here rather than rebuilt.
8. `undo_snackbar.dart` — `SnackBarBehavior.fixed`, zero radius, ten seconds, exactly one action.
   `hideCurrentSnackBar()` before showing a second.
9. Re-run the whole suite. T06's page tests must still pass with the pending filter in place.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 22 tests pass, and each failed first.
- [ ] A non-verdict edit leaves `outcome`, `outcome_detail`, `rule_citation_ref` and `content_version`
      byte-identical, and a verdict-bearing edit replaces all four together.
- [ ] `created_at` is not writable by any path in `app/lib` except `record()`.
- [ ] No `DELETE` is issued before the window closes; an undone delete issues none at all.
- [ ] The pending set filters S10's rows **and** its totals.
- [ ] The photo file is unlinked strictly after the row is deleted.
- [ ] `grep -rn "showDialog<bool" app/lib` returns nothing; D1 returns `DeleteOutcome` and its null
      case is handled explicitly.
- [ ] `grep -rniE "'(OK|Cancel|Yes|No|Confirm|Dismiss)'" app/lib/ui/log` returns nothing.
- [ ] No `is_deleted` or `deleted_at` column was added to `catch`, and `schemaVersion` did not move in
      this task.
- [ ] Focus returns to the opener after D1 pops, verified with `isSemantics(...)`.
- [ ] S11 renders at `TextScaler.linear(2.0)` with no overflow and no `ellipsis` on a real label.

## Gates

```bash
dart format --set-exit-if-changed .
cd app && flutter analyze && flutter test && cd ..
grep -rn "showDialog<bool" app/lib                     # must return nothing
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh    app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                 app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
tools/gates/no_directional_geometry.sh                                      app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-persistence-bans.sh          app/lib
```

`check-softdelete-parity.sh` is **not** run here: this task ships no soft-delete, deliberately, and the
reasoning is in "Why it is built this way". Do not add the columns to make the script applicable.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(log): edit a catch and delete it behind a ten-second deferred write

SPEC §7.2 makes history immutable so a content update cannot rewrite it — the
threat is a silent change by the pipeline, not a deliberate one by the fisher.
So a corrected length, species, method or zone re-runs the engine against the
installed pack and replaces outcome, outcome_detail, rule_citation_ref and
content_version together; a change to kept-or-released, the photo or the
coordinates leaves all four byte-identical. Leaving the old statement beside a
new length would be a record that contradicts its own numbers.

created_at stays fixed: it is when the record was written and §12 uses it in
the merge key, so editing it would change a row's identity for the importer.
That leaves §6 S11's "all fields editable" not literally satisfied, and the
epic's Risks section records the gap and the caught_at column that would close
it.

Delete defers its write for the whole window. Writing first and reversing on
undo means a crash inside the window makes an "undoable" delete permanent with
no trace; deferring means a crash leaves the row, which is the safe direction
for the only data in the product that exists nowhere else. An orderly pause
commits, because the fisher confirmed it through a modal whose button named
the consequence.

Ten seconds is SPEC §4.5's number, not the skill's eight; the epic records the
divergence rather than re-arguing it here.

Task: E13/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
