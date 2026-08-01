# E13/T03 — S8: today, and the vessel aggregate

| | |
|---|---|
| **Epic** | E13 — The catch log |
| **Branch** | `epic/13-catch-log` (shared) |
| **Commit** | `feat(log): show today's counts against their limits, the vessel aggregate and quick-add` |
| **Depends on** | T02 (the catch write path and `CatchDao.countSince`) |
| **Size** | M |
| **Spec** | `SPEC.md` §6 S8, §4.5 (Today's tally), §4.1 (rule evaluation takes today's tally), §7.1 (`rule.bag_limit`, `bag_limit_unit`, `bag_limit_period`, `vessel_limit`), §7.3 (finding precedence) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | Rules 4, 5, 6, 7, 8, 9 and `references/row-and-table-anatomy.md`'s `pair` column class — S8 *is* a ledger, and the four states of `references/the-four-states.md` are what it must author. |
| `lonja-buttons` | Rules 1, 2, 3, 11: one primary on S8, verb labels, no instruction about the fish on **End trip** or quick-add, and a latch so a bounced tap does not end the trip twice. |
| `catchlaw-conventions-index` | Invariants 2, 3, 4 and 5 in `references/product-invariants.md` — the row states a fact, carries its citation, never signals by colour alone, and still renders under an expired pack. |
| `state-management-riverpod` | The `StreamNotifier` ViewModel shape, `.select` to keep the ledger from rebuilding on every write, and rule 4 (derive, don't store). |
| `persistence-drift` | Rules 6 and 8: the tally is a fold over rows recomputed on read, never a stored counter; the read is a scoped `.watch()`. |
| `accessibility-as-code` | Rules 1, 2, 5, 6, 8: semantics on every row, no `ellipsis` on a real label, the count-against-limit state carried by glyph and word as well as hue. |
| `error-handling-typed-results` | Rule 4 — the use case's failure switch is exhaustive with no `default:`, so a new `DataFailure` variant is a compile error here. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S8 | The four elements and the exact empty-state sentence: "No catches recorded today." |
| `SPEC.md` | §4.5 row "Today's tally" | "Live count per species against the bag limit… visible on Check without navigating away" |
| `SPEC.md` | §4.1 row "Rule evaluation" | The evaluation input list includes today's tally, and "Every finding names its rule row and citation" |
| `SPEC.md` | §7.1 `rule` | `bag_limit`, `bag_limit_unit` (`count`/`kg`), `bag_limit_period` (`day`/`trip`/`season`), `vessel_limit` |
| `SPEC.md` | §7.3 | Finding precedence ends bag limit → vessel limit; the tally feeds it, it does not replace it |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Precedence", "Empty", "Loading skeleton", "Stale", "Golden coverage matrix" | The `stale` bar is orthogonal and composes with data; the banned spinner; lanes 6, 7, 10 and 11 |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The ledger table — column classes", "Numeric alignment and RTL mirroring", "Density" | The `pair` class, `TextAlign.end` never `.right`, 64 → 76 dp under glove |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §2, §3, §4, §5 | Banned lexicon, the five `Citation` fields, three signals per state, stale renders under an ochre bar |
| `.claude/skills/lonja-buttons/SKILL.md` | Rules 1, 2, 9, 11 | One primary; a disabled control states its reason in adjacent prose; the busy latch |
| `FLUTTER_GUIDE.md` | Part 5.3 | `List.==` is identity, so every drift re-query rebuilds every list consumer — the three mitigations, in order |
| `FLUTTER_GUIDE.md` | Part 2.5 rule 3 | `ReferenceRepository` and the user-side repository never call each other; the join goes in a use case |
| `epics/DECISIONS.md` | D-7 | The engine returns types; whether a count exceeds a limit is a `Finding`, not an `if` in a widget |
| `epics/E13-catch-log/epic.md` | Risks 3, 7 | The kg limit that cannot be counted, and the aggregate that can only count this device |

## What this delivers

- `app/lib/domain/models/day_window.dart` — `DayWindow.forLocalDay(DateTime local)`, a pure function
  returning the UTC bounds of one device-local calendar day.
- `app/lib/domain/models/today_tally.dart` — `TodayTally` and `TallyLine`: species, local name, the
  counted number, the limit, its unit, the window it was counted over, its `Citation`, the optional
  vessel figure, and the `Finding` list the engine returned.
- `app/lib/domain/use_cases/today_tally_use_case.dart` — the one place `ReferenceRepository` and
  `CatchLogRepository` meet.
- `app/lib/ui/log/today_screen.dart` — S8.
- `app/lib/ui/log/view_models/today_view_model.dart` — a `StreamNotifier` whose `build()` returns the
  use case's stream.
- `app/lib/ui/log/widgets/tally_ledger_table.dart` — the `pair`-class `Table`.
- `app/lib/ui/log/widgets/today_empty_state.dart` — the authored empty state.
- `app/lib/ui/log/widgets/quick_add_action.dart` — the quick-add entry point.
- ARB keys for every string on S8, in all six locales of D-3.
- Tests: `app/test/domain/models/day_window_test.dart`,
  `app/test/domain/use_cases/today_tally_use_case_test.dart`,
  `app/test/ui/log/today_screen_test.dart`, and the golden lanes named below.

## Why it is built this way

**A day is a local calendar day, not twenty-four hours back from now.** `persistence-drift` rule 5
draws the line: a value that drives a day boundary must never be an instant. `DayWindow.forLocalDay`
takes a local `DateTime`, builds `DateTime(y, m, d)` and `DateTime(y, m, d + 1)` — which are local and
therefore DST-correct by construction — and converts both to UTC for the query. `d + 1` also handles
month and year rollover, which is why the boundary is not computed with `Duration(days: 1)`: adding
24 hours across a spring-forward lands at 01:00 of the next day, and one catch silently moves.

**The tally counts the window the *rule* names, and the row says which window it counted.**
`SPEC.md` §7.1 lets a bag limit be per `day`, per `trip` or per `season`. Counting a season limit
against one day under-reports — and it under-reports in the permissive direction, which is the only
direction that costs the fisher a fine. So `bag_limit_period` selects the window, and the ledger line
carries the words for it. Where the period is `trip` and no trip is open, the line states that as a
fact rather than showing a zero.

**Where `bag_limit_unit` is `kg`, the line shows the limit and no count.** §7.2's `catch` holds
`length_mm` and no weight, so there is nothing to count. Converting length to weight would be the app
asserting a fact it does not have — the same refusal §4.1 makes between "no rule exists" and "we have
not transcribed this". The line reads as a statement about the limit and carries its citation.

**Whether a count exceeds its limit is a `Finding` from the engine.** D-7 and invariant 2: the app
owns every word, the engine owns every conclusion. A `count > limit` in the widget would be a second
implementation of §7.3's precedence, and the two would disagree within a month — with the app's copy
being the one on screen. The use case hands the tally to `packages/rule_engine/` (which §4.1 already
lists as an evaluation input) and renders the `Finding` it gets back, citation included.

**The vessel aggregate counts what this device holds, and says so.** `rule.vessel_limit` is a
per-boat cap; CATCHLAW has no account and no sync (`catchlaw-conventions-index` rule 11), so the app
cannot know what the rest of the crew landed. The line states the figure it has and the fact that it
is this device's. **Rejected:** presenting it as the boat's total, which would be the app claiming
knowledge it structurally cannot have; and hiding the row entirely, which would lose a limit the
fisher needs to see.

**Counting is scoped to the jurisdiction, not to the zone.** A bag limit constrains the person, and
zones subdivide a jurisdiction rather than resetting its limits. So the count is
`jurisdiction_code = :active AND species_id = :id` over the window, across zones — while the *limit*
shown is the one §7.3 resolves for the active zone, with that zone's citation. `SPEC.md` does not
state the counting scope; this is a decision, and what would resolve it is the text of a real
instrument in E22's authoring pass. Until then the line names the jurisdiction it counted over, so the
scope is visible rather than assumed.

**S8 is a ledger, not a list of cards.** `lonja-lists-and-tables` rule 5 and the `pair` column class:
an uppercase tracked sans key on the start edge, a serif value on the end edge, a 1.5 px `ink` rule
under the header, dotted hairlines between body rows, no fill and no zebra striping. Every numeric
cell is mono with `FontFeature.tabularFigures()` and `TextAlign.end` — never `.right`, which pins the
figure to the start edge in `ar` and lands it under its own label.

**End trip commits directly and opens no modal.** `lonja-dialogs-and-surfaces` rule 1: a modal is
earned only by a decision that must resolve, and ending a trip loses no row — every catch survives and
a new trip can be started. A confirmation here teaches the fisher to swipe modals away, and the one
modal that matters (T07's delete) gets swiped away too. It is a `LonjaButton.secondary` with a latch,
followed by a 4-second informational snackbar with no action (`modal-decision-matrix.md` §8).

**Quick-add records `outcome = 'unknown'` with a null length.** That is exactly what §7.2's fourth
`CHECK` value and the nullable `length_mm` are for: a fish counted but not measured. The line renders
as "no finding recorded" and never as "meets" — invariant 3 is not weakened, because there is no
result to cite, and §7.2 makes `rule_citation_ref` nullable for this case alone.

**The empty state's headline is `SPEC.md`'s, its shape is the skill's.**
`the-four-states.md`'s "Today" row proposes "No fish recorded on this trip yet"; §6 S8 publishes
"No catches recorded today." The spec is authoritative for product copy, so the headline is the spec's
and the plate, body and single action follow the skill's anatomy.

## Tests first

Write every row before touching `today_tally_use_case.dart`. Run them. **They must fail.** A row that
passes now is a row testing nothing — fix the test, not the schedule.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `DayWindow.forLocalDay spans local midnight to the next local midnight` | a local `DateTime` mid-afternoon | start ≤ input < end, both UTC | The base contract; every count below is a window query |
| 2 | `DayWindow.forLocalDay rolls into the next year on 31 December` | 2026-12-31 18:00 local | end is 2027-01-01T00:00 local, as UTC | `DateTime(y, m, d + 1)` is what handles this; `Duration(days: 1)` also would, which is why case 3 exists |
| 3 | `DayWindow.forLocalDay includes 29 February in a leap year` | 2028-02-28 local | end is 2028-02-29 local | The rollover nobody writes by hand correctly |
| 4 | `TodayTallyUseCase excludes a catch recorded before local midnight` | one catch at 23:59 yesterday local | count 0 | The off-by-one that makes yesterday's fish count against today's limit — and towards a fine |
| 5 | `TodayTallyUseCase counts a trip-period limit over the open trip, not the day` | `bag_limit_period = 'trip'`, two catches today, one before the trip opened | count 1 | Counting a trip limit over the day over-counts; counting a day limit over the trip under-counts. Both are wrong and only one is dangerous |
| 6 | `TodayTallyUseCase states no trip is open for a trip-period limit with no open trip` | `bag_limit_period = 'trip'`, no trip | a line with no count and the reason | A zero here reads as "you have caught none of your five", which is a different claim |
| 7 | `TodayTallyUseCase counts a season-period limit over the season window` | `bag_limit_period = 'season'` with a resolvable window | count over that span | The third period; without it a season limit silently becomes a daily one |
| 8 | `TodayTallyUseCase reports the limit and no count when bag_limit_unit is kg` | `bag_limit = 40`, unit `kg` | a line carrying 40 kg, its citation, and no count | Epic Risks 3 — §7.2 stores no weight, and a length-to-weight guess would be the app inventing a fact |
| 9 | `TodayTallyUseCase carries the citation of the rule that set each limit` | any line | non-null `Citation` with instrument, article, published and checked | Invariant 3. An uncited limit is an opinion, and §4.1 requires every finding to name its rule row |
| 10 | `TodayTallyUseCase takes the over-limit finding from the rule engine` | count 6 against a limit of 5 | the engine's `Finding`, not a locally built one | D-7. A `count > limit` in the app is a second implementation of §7.3 that will disagree with the first |
| 11 | `TodayTallyUseCase includes a catch recorded with no trip` | one quick-add, `trip_id` NULL | counted | The §4.5 case the whole epic turns on |
| 12 | `TodayTallyUseCase counts across zones within the active jurisdiction` | two catches today, different `zone_code`, same jurisdiction | count 2 | The counting-scope decision, made visible. If someone narrows it to the zone later, this test is what argues back |
| 13 | `TodayTallyUseCase excludes a catch from another jurisdiction` | one catch with a foreign `jurisdiction_code` | not counted | The other half of case 12; without it a Galician limit counts a Brazilian fish |
| 14 | `TodayTallyUseCase omits the vessel figure when the resolved rule has no vessel_limit` | `vessel_limit` NULL | no vessel line | "Where applicable" (§6 S8) means the rule decides, not the screen |
| 15 | `TodayTallyUseCase reports the vessel figure against vessel_limit when the rule carries one` | `vessel_limit = 20` | a vessel line with the device-scoped count | Epic Risks 7 |
| 16 | `TodayScreen renders the authored empty state with no catches today` | zero rows | headline "No catches recorded today.", one action | `the-four-states.md` — a blank frame reads as a crash to a fisher with no signal, and a blank golden passes review |
| 17 | `TodayScreen renders the stale bar above an unchanged ledger when the pack is expired` | expired pack, three lines | ochre bar present **and** all three lines rendered | Invariant 5. The bar is orthogonal; replacing the ledger removes the only rules he has |
| 18 | `TodayScreen shows a glyph and a word beside every over-limit figure` | one line over its limit | glyph + word + hue | Invariant 4 — verified in the greyscale lane, not by eye |
| 19 | `ar - TodayScreen end-aligns every numeric cell` | `ar` locale golden | figures share the ledger's end edge | `TextAlign.right` puts the figure under its own label in Arabic; the golden is the only thing that catches it |
| 20 | `glove - TodayScreen raises every ledger row to 76 dp` | glove density golden | 76 dp rows, 12 dp separation | `row-and-table-anatomy.md` "Density" — a 64 dp row under a neoprene glove is a mis-tap |
| 21 | `TodayScreen ends the trip once when End trip is tapped twice` | two taps 90 ms apart | one `endTrip` call, one `TripAlreadyEnded` never surfaced | `lonja-buttons` rule 11 |
| 22 | `QuickAdd records a catch with outcome unknown and a null length` | pick a species, no measurement | row with `outcome = 'unknown'`, `length_mm` NULL, `rule_citation_ref` NULL | The fourth `CHECK` value exists for exactly this; a quick-add forced through a fake verdict would fabricate a finding |

```dart
// app/test/domain/use_cases/today_tally_use_case_test.dart
void main() {
  test('TodayTallyUseCase counts a trip-period limit over the open trip, not the day', () async {
    final useCase = TodayTallyUseCase(
      reference: FakeReferenceRepository(rules: [kRuleBagLimitPerTrip]), // bag_limit 5, period trip
      catchLog: FakeCatchLogRepository(rows: [
        kCatchAt(hour: 5),   // before the trip opened
        kCatchAt(hour: 7, tripId: 1),
        kCatchAt(hour: 9, tripId: 1),
      ]),
      openTripId: 1,
      clock: Clock.fixed(DateTime.utc(2026, 8, 1, 10)),
    );

    final tally = await useCase.watch().first;
    expect(tally.lineFor(kSpeciesAmeixa).count, 2);
    expect(tally.lineFor(kSpeciesAmeixa).window, TallyWindow.trip);
  });

  test('TodayTallyUseCase reports the limit and no count when bag_limit_unit is kg', () async {
    final line = (await _useCaseWith(kRuleBagLimitKg).watch().first).lineFor(kSpeciesAmeixa);
    expect(line.limit, 40);
    expect(line.limitUnit, BagLimitUnit.kg);
    expect(line.count, isNull);               // nothing to count — SPEC §7.2 stores no weight
    expect(line.citation, isNotNull);         // invariant 3 holds even with no figure
  });

  test('TodayTallyUseCase takes the over-limit finding from the rule engine', () async {
    final line = (await _useCaseWithCount(6, limit: 5).watch().first).lineFor(kSpeciesAmeixa);
    expect(line.findings, contains(isA<BagLimitExceeded>())); // from packages/rule_engine/
  });

  // … one test per row above, one behaviour each
}
```

```dart
// app/test/ui/log/today_screen_test.dart
testWidgets('TodayScreen renders the stale bar above an unchanged ledger when the pack is expired',
    (tester) async {
  await tester.pumpWidget(_harness(tally: kThreeLineTally, packExpired: true));

  expect(find.byType(LonjaStaleBar), findsOneWidget);
  expect(find.byType(TallyLedgerRow), findsNWidgets(3)); // the ledger is NOT replaced
});

testWidgets('TodayScreen renders the authored empty state with no catches today', (tester) async {
  await tester.pumpWidget(_harness(tally: TodayTally.empty));

  expect(find.text('No catches recorded today.'), findsOneWidget); // SPEC §6 S8, verbatim
  expect(find.byType(LonjaButton), findsOneWidget);                // exactly ONE action
});
```

**Run:** `cd app && flutter test test/domain test/ui/log` → 22 failures.

## Implementation outline

1. `day_window.dart` first — a pure function with its own test file and no Flutter import. Everything
   downstream depends on it being right.
2. `today_tally.dart` — `TallyLine` immutable, with `TallyWindow { day, trip, season }` and
   `BagLimitUnit { count, kg }` mirroring the §7.1 `CHECK` values exactly.
3. `today_tally_use_case.dart` — the join, per `FLUTTER_GUIDE.md` §2.5 rule 3. It takes both
   repository *interfaces*, never a DAO, resolves the rules for the active zone through
   `ReferenceRepository`, folds the counts from `CatchLogRepository`, hands the tally to the engine and
   returns a `Stream<TodayTally>`. Its failure switch is exhaustive with no `default:`.
4. `today_view_model.dart` — a `StreamNotifier` whose `build()` **returns** the use case's stream. Do
   not `await for` it into `state` (`FLUTTER_GUIDE.md` §5.2, `state-management-riverpod` anti-pattern 2).
5. Apply `FLUTTER_GUIDE.md` §5.3's mitigations in order: keep the DAO query narrow so one insert does
   not re-run a five-table join, and `.select` at the consumer so the End-trip button does not rebuild
   when a count changes. Only reach for `.distinct` if a measurement says the subtree is expensive.
6. `tally_ledger_table.dart` — a `Table` with the `pair` column class. `EdgeInsetsDirectional`
   throughout; no `Divider`; no `TableRow` background `color`.
7. `today_empty_state.dart` — plate, `SPEC.md`'s headline, one `LonjaButton.primary`. The gate greps
   for an empty-state reference in any file that builds a lazy list; do not satisfy it with a
   `SizedBox.shrink()`.
8. `quick_add_action.dart` — routes to E08's species search and records through T02's `record()` with
   `outcome: CatchOutcome.unknown`. It builds no verdict and fakes no citation.
9. Wire S8 into E12's bottom-navigation **Today** slot, replacing the placeholder.
10. Re-run the whole suite. E12's S1 tally summary bar reads the same use case; if it was stubbed,
    point it here in this commit rather than leaving two sources for one number.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 22 tests pass, and each failed first.
- [ ] No count, total or aggregate is stored in a column or in a `Notifier` field — every one is a fold
      recomputed on read (`persistence-drift` rule 6).
- [ ] `today_tally_use_case.dart` is the only file that imports both `ReferenceRepository` and
      `CatchLogRepository`.
- [ ] Every `TallyLine` carries a non-nullable `Citation`, and the over-limit conclusion is a `Finding`
      from `packages/rule_engine/` — `grep -n '>\s*limit\|count >' app/lib/ui/log` returns nothing.
- [ ] S8 authors all four states, and the stale bar composes with data rather than replacing it.
- [ ] `grep -rn 'ListTile\|DataTable\|TextAlign.right\|EdgeInsets.only(left' app/lib/ui/log` is empty.
- [ ] S8 builds exactly one `LonjaButtonVariant.primary`; **End trip** and quick-add are below it on
      the ladder.
- [ ] No string on S8 instructs the fisher, in any of the six locales of D-3.
- [ ] Golden lanes 1, 2, 3, 5, 6, 7 and 10 of `the-four-states.md`'s matrix exist for S8 and are green
      on Linux CI.

## Gates

```bash
dart format --set-exit-if-changed .
cd app && flutter analyze && flutter test && cd ..
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                 app/lib
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh    app/lib
$FLUTTER_SKILLS/state-management-riverpod/scripts/ban-legacy-providers.sh   app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(log): show today's counts against their limits, the vessel aggregate and quick-add

The window a line counts over is the one its own rule names. SPEC §7.1 lets a
bag limit be per day, per trip or per season, and counting a season limit
against one day under-reports — in the permissive direction, which is the only
direction that costs the fisher money.

A kg limit shows its number and no count. SPEC §7.2's catch row holds
length_mm and no weight, so there is nothing to count, and guessing a weight
from a length would be the app asserting a fact it does not have.

Whether a count exceeds its limit comes back from packages/rule_engine/ as a
Finding with its citation. A `count > limit` in the widget would be a second
implementation of §7.3's precedence, and the copy on screen would be the one
that drifted.

The vessel figure counts what this device holds and says so. There is no
account and no sync, so the app cannot know what the rest of the crew landed,
and presenting the number as the boat's total would be a claim it cannot make.

End trip opens no modal: no row is lost, and a confirmation here teaches the
habit of swiping modals away that would defeat T07's delete.

Task: E13/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
