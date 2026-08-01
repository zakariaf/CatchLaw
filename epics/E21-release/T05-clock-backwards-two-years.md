# E21/T05 — The clock moved backwards two years

| | |
|---|---|
| **Epic** | E21 — Offline verification and release readiness |
| **Branch** | `epic/21-release` (shared) |
| **Commit** | `test(check): evaluate seasonal rules against a device clock set back two years` |
| **Depends on** | T04 (the clock harness, the fixture rule and `docs/release/clock-tests.md`) |
| **Size** | S |
| **Spec** | `SPEC.md` §14 dynamic row 17; §7.3; §9.3 (numerals); §6 S2 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-conventions-index` | `references/product-invariants.md` invariant 5 edge cases — a device clock behind the pack's `publishedOn` is a clock problem, not an expiry, and there is no time server to correct it with |
| `service-boundary-and-native` | Rule 8: the same injected `clockProvider` T04 established; a backwards clock is the case where a stray `DateTime.now()` produces a different answer from the injected one |
| `testing-strategy` | Rule 1: this is a season-boundary evaluation, expressible as `f(date) -> finding`, so most of it belongs below the widget tier |
| `catchlaw-offline-guarantee` | Rule 11: no affordance may appear offering to fix the clock; there is nothing to fix it against |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §14 dynamic row 17 | Seasonal rules evaluate against the device date without crashing, **and** the date used is displayed |
| `SPEC.md` | §7.3 | `valid_from <= date` is the only date filter; a rule not yet in force on the shifted date is simply not selected, which is correct and not an error |
| `SPEC.md` | §9.3 | The numeral system resolves from the locale, so a displayed date is a numeral surface |
| `SPEC.md` | §6 S2 | Where the evaluation date is displayed |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | "5 — Stale beats absent" edge cases | A clock behind `publishedOn` is still evaluated, still not blocked, and is never "corrected" |
| `service-boundary-and-native` → `SKILL.md` (Flutter-Skills plugin) | rule 8 | One source of "now" |
| `epics/CONVENTIONS.md` | §5, §9 | Test naming, and invariant 5 |
| `epics/DECISIONS.md` | D-3 | The six locales; `ar` is the only RTL lane, and the one whose numeral system is a variable |
| `epics/E21-release/T04-clock-forward-past-valid-to.md` | "What this delivers" | The harness and the shared procedure document this task extends |

## What this delivers

- `app/integration_test/clock_backwards_test.dart` — the device-tier case with the app clock pinned two
  years back.
- `app/test/features/result/evaluation_date_visible_test.dart` — the widget-tier cases: the date is
  shown, it is the date that was used, and it renders in the active locale's resolved numeral system.
- A second section in `docs/release/clock-tests.md` (created by T04) — the backwards procedure and what
  to observe.
- `docs/release/<version>/evidence/clock-backwards.png`.

## Why it is built this way

**A backwards clock is not an error state.** §7.3 filters on `valid_from <= date` and on nothing else,
so a clock two years back simply selects an earlier generation of rules, or none where the content only
begins later. `product-invariants.md` records the ruling directly: a device clock behind the pack's
`publishedOn` is a clock problem, not an expiry — still evaluate, still no block, and do not attempt to
correct the clock, because there is no time server to correct it against. So this task asserts that
nothing throws and nothing blocks, which is a smaller claim than T04's and is why this is an S.

**The second clause is the one that earns the row.** "The date used is displayed" is what makes a
wrong-clock result legible instead of baffling. A fisher whose phone reset to 2024 after a flat battery
gets an answer that looks wrong; the displayed date is the only thing that tells him why. So the test
does not assert that *a* date is on screen — it asserts the displayed date equals the pinned instant,
because a screen showing today's date while evaluating against 2024 is worse than showing nothing.

**Rejected: asserting "no crash" alone.** That is the whole of the row as most people would read it, and
it would pass on a screen that silently evaluated against the wrong date and said nothing. §14's second
clause exists precisely because the first is not enough.

**Rejected: re-testing season-boundary arithmetic here.** Leap-year and wrap-around season boundaries are
E03's, built at `SPEC.md` §15 step 2 and unit-tested there. Repeating them at the device tier would be
slow, would duplicate an owner, and would blur which layer broke. This task owns the device-date path
into that logic, not the logic.

**Rejected: shifting by a fixed number of days.** Two years is specified, and two calendar years is not
730 days in general. The shift is computed on the calendar so the pinned instant lands on the same
month and day, which is what makes a seasonal rule's in-force window comparable across the shift.

## Tests first

Write every row before extending the harness. Run them. **They must fail** — the widget rows because
nothing yet renders an evaluation date under a pinned clock, the integration row because
`clock_backwards_test.dart` does not exist. If row 1 passes now, the test is wrong: "does not throw" is
trivially true on a screen that renders nothing, so the row must also assert that the result surface
built.

| # | Test name | Tier | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `Result screen evaluates a seasonal rule without throwing when the clock is two years back` | widget | result surface built, no exception | §14 row 17 clause one. Paired with an assertion that the surface exists, so an empty screen cannot pass it |
| 2 | `Result screen displays the evaluation date when the clock is two years back` | widget | the pinned date's text present | §14 row 17 clause two — the clause that makes a wrong-clock answer legible |
| 3 | `Result screen displays the date it evaluated against, not the current date` | widget | pinned date shown, real today absent | The failure mode row 2 alone would miss: a screen that evaluates on one date and prints another |
| 4 | `Result screen evaluates a rule published after the device date without blocking` | widget | finding rendered, no error surface | `product-invariants.md`: a clock behind `publishedOn` is a clock problem, not an expiry. This is where somebody would add an error screen |
| 5 | `Result screen offers no clock-correction action when the clock is two years back` | widget | no such affordance | There is no time server. An affordance that cannot work teaches the user the app is broken while it is working as designed |
| 6 | `ar - Result screen renders the evaluation date in the numeral system resolved for the locale` | widget | digits match the resolved system | §9.3. A date is a numeral surface, and this is the one date rendered outside the normal flow |
| 7 | `Check flow evaluates a seasonal rule and displays the date used when the device clock is two years back` | integration | finding and date | §14 row 17 on hardware, through the real content |

```dart
// app/test/features/result/evaluation_date_visible_test.dart
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/rules.dart'; // kSeasonalRule

void main() {
  // Two calendar years back from the pack's own reference instant — not 730 days.
  final DateTime twoYearsBack = DateTime(
    kSeasonalRule.referenceDate.year - 2,
    kSeasonalRule.referenceDate.month,
    kSeasonalRule.referenceDate.day,
  );

  testWidgets('Result screen displays the date it evaluated against, not the current date',
      (WidgetTester t) async {
    await withClock(Clock.fixed(twoYearsBack), () async {
      await t.pumpWidget(await resultHarness(rule: kSeasonalRule, lengthCm: 38));
      expect(find.textContaining('${twoYearsBack.year}'), findsWidgets);
      expect(find.textContaining('${DateTime.now().year}'), findsNothing);
    });
  });

  testWidgets('Result screen evaluates a rule published after the device date without blocking',
      (WidgetTester t) async {
    await withClock(Clock.fixed(twoYearsBack), () async {
      await t.pumpWidget(await resultHarness(rule: kSeasonalRule, lengthCm: 38));
      expect(find.byType(FindingRow), findsWidgets);
      expect(find.byType(RulePackErrorScreen), findsNothing);
    });
  });

  // … rows 1, 2, 5, 6
}
```

**Run:** `cd app && flutter test test/features/result/evaluation_date_visible_test.dart` → 6 failures,
and `flutter test integration_test/clock_backwards_test.dart -d <device>` → 1 failure. Any pass now is a
wrong test.

## Implementation outline

1. Add `kSeasonalRule` to `app/testing/models/rules.dart` — a closed-season row from the Galicia seed
   with a known in-force window, and the reference instant the shift is computed from.
2. Extend `app/integration_test/harness/clock.dart` (T04) with a `twoCalendarYearsBack` helper. Compute
   on the calendar, not in days.
3. Write the seven rows. Run them. They fail.
4. Expect no production change. If the evaluation date is not displayed anywhere on S2, that is a real
   gap left by E10 and it is closed here — with the smallest possible addition, and named in the commit
   body so a reviewer sees that this task changed behaviour rather than only adding tests.
5. Perform the manual device run: automatic time off, date set two calendar years back, open the same
   species, confirm the finding and the displayed date, screenshot, restore automatic time immediately.
6. Add the backwards section to `docs/release/clock-tests.md`.
7. Re-run the suite. All 7 green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 7 tests pass, and each failed first.
- [ ] Row 3 asserts both halves — the pinned date present **and** the real current year absent.
- [ ] The shift is two calendar years, computed on the calendar, and this is visible in the harness.
- [ ] No error screen, no dialog, no disabled control and no clock-correction affordance appears with
      the clock two years back.
- [ ] The manual device run happened on the physical Android device named in T08's checklist, the
      screenshot is committed, and automatic time was restored before the next §14 row.
- [ ] `docs/release/clock-tests.md` now carries both the forward and the backward procedure, and repeats
      the warning that the clock tests never share a session with the packet capture.
- [ ] Season-boundary arithmetic is still owned and tested by E03; nothing was duplicated into this task.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze --fatal-infos && flutter test
cd app && flutter test integration_test/clock_backwards_test.dart -d <device-id>
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh    app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(check): evaluate seasonal rules against a device clock set back two years

§7.3 filters on valid_from <= date and on nothing else, so a clock two years
back selects an earlier generation of rules rather than erroring — and
product-invariants records that a device clock behind the pack's publishedOn is
a clock problem, not an expiry, with no time server to correct it against. The
row that earns its place is the second clause: the date used is displayed. A
test asserting only "does not crash" passes on a screen that silently evaluates
against 2024 and prints today, which is worse than printing nothing, so the
displayed date is compared against the pinned instant and today's year is
asserted absent. The shift is two calendar years, not 730 days.

Task: E21/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
