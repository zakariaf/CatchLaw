# E12/T03 — The tally summary bar

| | |
|---|---|
| **Epic** | E12 — Check home and the navigation shell |
| **Release** | **v2 — deferred.** Not built for v1; see `epics/RELEASES.md` |
| **Branch** | `epic/12-check-home` (shared) |
| **Commit** | `feat(check): state today's tally against the bag limit on Check` |
| **Depends on** | T02 (S1 owns the slot the bar sits in) |
| **Size** | M |
| **Spec** | `SPEC.md` §6 S1 ("today's tally summary bar"), §4.5 (today's tally), §7.1 `rule.bag_limit`, §7.2 `catch` |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | The bar is a two-column `pair` ledger: tabular figures, end-aligned, hairline-ruled, never zebra-striped, and it states rather than instructs. |
| `lonja-design-tokens` | The count against a limit is a status: glyph plus word plus colour, framed and never filled, using `verdictPass` / `verdictWarn` values. |
| `catchlaw-conventions-index` | Invariant 2 (a statement, never an instruction) and invariant 4 (colour is never the only signal) both bind this widget's end slot. |
| `state-management-riverpod` | The tally is live: a drift stream through a `StreamProvider`, with the `List.==` rebuild trap avoided by scoping. |
| `flutter-performance` | `.select` scoping so a tally emission does not rebuild the recents strip or the entry points below it. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S1 | The element is a tally **summary** bar — the word "summary" is load-bearing |
| `SPEC.md` | §4.5, "Today's tally" row | Live count per species against the bag limit; visible on Check without navigating away |
| `SPEC.md` | §6 S8 | Where the full per-species list and the vessel-limit aggregate live — one tap away on the strip |
| `SPEC.md` | §7.2, `catch` | `jurisdiction_code`, `zone_code`, `species_id`, `outcome`, `created_at`, and `idx_catch_created` |
| `SPEC.md` | §7.1, `rule` | `bag_limit`, `bag_limit_unit` (`count`/`kg`), `bag_limit_period` (`day`/`trip`/`season`) |
| `SPEC.md` | §4.1, "No-rule-vs-no-data" row | Two visually distinct states; a null `bag_limit` is not zero |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rules 4, 5, 8, 9 | Tabular end-aligned numerics; ruled not striped; a row states, never instructs; status is glyph AND word AND colour |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The ledger table — column classes", "Numeric alignment and RTL mirroring" | The `pair` class; `TextAlign.end` not `TextAlign.right`; tone overrides are semantic only |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "Tier 2", "Measured contrast — paper theme" | `verdictWarn` is `ochre47` at 3.97:1 — a mark, never text; the warning **word** is `onSurface` |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariants 2 and 4 | The banned lexicon, and three signals per state |
| `FLUTTER_GUIDE.md` | Part 1.1 | "Repositories should never be aware of each other" — the reason this aggregation lives in `domain/use_cases/` |
| `FLUTTER_GUIDE.md` | Part 5.3 | `List.==` is identity, so every drift re-query rebuilds every list consumer unless it is scoped |
| `epics/DECISIONS.md` | D-3, D-6, D-7 | Six locales; two database files; the engine holds no sentence, so the wording is assembled here |

## What this delivers

- `app/lib/ui/check/widgets/tally_summary_bar.dart` — the bar.
- `app/lib/domain/models/today_tally.dart` — an immutable value: total count, and the one species
  nearest its limit with its count, limit, unit and period.
- `app/lib/domain/use_cases/watch_today_tally.dart` — combines the catch repository (`user.db`) and the
  reference repository (`reference.db`), because a repository may not know another repository exists.
- `app/lib/data/repositories/catch_log_repository.dart` + `catch_log_repository_drift.dart` — the read
  half only: `watchTodayCounts({jurisdiction, zone, dayStart, dayEnd})`.
- `app/testing/fakes/fake_catch_log_repository.dart`, `app/testing/models/k_today_tally.dart`.
- `app/lib/l10n/app_*.arb` × 6 — `tallyTotalToday`, `tallyNoneToday`, `tallyAgainstLimit`,
  `tallyLimitNotRecorded`.
- `app/test/ui/check/widgets/tally_summary_bar_test.dart`,
  `app/test/domain/use_cases/watch_today_tally_test.dart`.

The write half of `catch_log_repository.dart` belongs to E13. This task adds read methods to the same
interface; it does not create a second repository over the same table.

## Why it is built this way

**The bar is a summary because the screen has a budget.** §4.5 wants a live count per species against
the bag limit; §6 S1 calls the element a tally **summary** bar; §4.9 wants the four species entry
points in the bottom third. Rendering every species inline satisfies the first and breaks the third —
after four species the entry points are off the bottom of a 640 dp screen. So the bar states the total
and the single species nearest its limit, and the full per-species list is S8, which is one tap on the
strip. The screen a fisher looks at while holding a fish shows the number that is about to matter.

**"Nearest its limit" is a ratio, not a count.** Three of a five-fish limit outranks eight of a
species with no limit recorded. Ties break on the higher absolute count, then on species id, so the bar
is deterministic — a bar that reshuffles between two frames is unreadable at arm's length.

**The aggregation is a use case, not a repository method.** It needs today's catches from `user.db` and
the bag limits from `reference.db`. `FLUTTER_GUIDE.md` Part 1.1 is explicit that repositories never
know about each other and that logic needing two of them belongs in the ViewModel or the domain layer.
Putting the join in `CatchLogRepository` would give it a reference to `ReferenceRepository` and make
both untestable in isolation.

**A null `bag_limit` is not zero.** §4.1 distinguishes "no limit exists in this instrument" from "we
have not transcribed this species". The bar states the count and says the limit is not recorded; it
never renders `3 / 0` and never implies a breach. That is the same distinction the result screen makes,
and it must not disagree with it.

**The bar states and does not instruct, and it is not a tap target.** §6 S1 lists no destination for
it, and Today is already one tap away on the strip. Inventing a second route to the same screen teaches
two gestures for one destination. The copy is `4 fish today · Hamour 3 of 5`, never "you have 2 left"
and never an imperative — invariant 2 covers the tally bar exactly as it covers the verdict.

**Colour is the third signal.** A species at or over its limit is marked with a glyph, the word, and
`verdictWarn`. `token-tables.md` measures `ochre47` at 3.97:1 on paper — legal as a frame or a glyph,
not as text — so the words stay `onSurface` and the colour frames. That keeps the bar readable in
greyscale and in the sunlight theme, which is invariant 4.

**Rejected: computing the tally in the ViewModel from a raw catch list.** It would pull every one of
today's rows into Dart to count them, and §13 budgets 8,000 rows across five years without ever loading
them. `GROUP BY species_id` over `idx_catch_created` is the query the index exists for.

**Rejected: a rolling 24-hour window.** `bag_limit_period` is `day`, which in every instrument the
content pipeline transcribes means a calendar day in local time. A rolling window would let a fisher
land four at 23:50 and four at 00:10 and see eight against a five-fish daily limit.

## Tests first

Write every row before touching `tally_summary_bar.dart`. Run them. **They must fail.** If the
zero-catches row passes first, the widget is rendering a default rather than an authored state — fix
the test's finder before writing code.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `TallySummaryBar states the total number of fish recorded today` | 4 catches today | "4" present | §4.5's headline number |
| 2 | `TallySummaryBar states the species nearest its bag limit with its count and limit` | Hamour 3 of 5, Kanaad 8 of null | Hamour row shown | The ratio rule, not the raw count |
| 3 | `TallySummaryBar counts only catches created on the device's current day` | one at 23:59 yesterday, one today | total 1 | The calendar-day boundary `bag_limit_period = 'day'` means |
| 4 | `TallySummaryBar counts only catches in the active jurisdiction and zone` | rows in two zones | active zone only | §7.2 stores both codes on the catch for exactly this |
| 5 | `TallySummaryBar shows the new total when a catch is inserted` | insert into the fake stream | total increments without a manual refresh | §4.5: the count is live |
| 6 | `TallySummaryBar states that nothing is recorded when today has no catches` | zero rows | the authored line, not a blank strip | A blank strip at sea is indistinguishable from a crash |
| 7 | `TallySummaryBar states the count when the bag limit is not recorded` | limit null | count plus "limit not recorded" | §4.1's no-rule-vs-no-data distinction |
| 8 | `TallySummaryBar states a kg bag limit in kg` | `bag_limit_unit = 'kg'` | unit rendered as kg, not as a count | The unit column exists because both are real in the bundled instruments |
| 9 | `TallySummaryBar renders counts as tabular figures aligned to the inline-end edge` | 2 rows, 1 and 402 | `FontFeature.tabularFigures`, `TextAlign.end` | Proportional digits wobble down a column and cannot be compared in swell |
| 10 | `RTL - TallySummaryBar keeps the count on the inline-end edge` | `ar` | count on the left | `TextAlign.right` would put the figure under its own label in Arabic |
| 11 | `TallySummaryBar marks a species at its limit with a glyph and a word` | 5 of 5 | glyph + word + `verdictWarn` frame | Invariant 4; the sunlight theme deletes every grey |
| 12 | `sunlight - TallySummaryBar distinguishes a species at its limit without hue` | sunlight theme, greyscale | still distinguishable | The greyscale proof invariant 4 is measured by |
| 13 | `TallySummaryBar states a fact and never instructs` | any state | rendered text contains no banned imperative | Invariant 2 — an imperative in a tally is fishing advice |
| 14 | `TallySummaryBar keeps the four species entry points in the bottom third at 360x640` | 6 species today | entry-point centres still below `height * 2 / 3` | The bar must not grow into the reach zone |
| 15 | `WatchTodayTally ranks a species by its share of the limit` | 3 of 5 vs 8 of 20 | 3 of 5 ranks first | The ranking rule, stated once and tested once |
| 16 | `WatchTodayTally breaks a ranking tie on the higher count` | 2 of 4 vs 1 of 2 | 2 of 4 first | A bar that reshuffles between frames is unreadable |
| 17 | `WatchTodayTally aggregates counts in SQL and returns one row per species` | 40 catches, 3 species | 3 rows | §13's 8,000-row budget; no row list ever reaches Dart |
| 18 | `ar - TallySummaryBar renders the no-catches line from app_ar.arb` | locale `ar` | Arabic line | D-3 |

```dart
// app/test/ui/check/widgets/tally_summary_bar_test.dart
import 'package:catchlaw/ui/check/widgets/tally_summary_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/models/k_today_tally.dart';
import '../../../utils/harness.dart';

void main() {
  testWidgets('TallySummaryBar states that nothing is recorded when today has no catches',
      (tester) async {
    await pumpLonja(tester, const TallySummaryBar(tally: TodayTally.none));

    expect(find.text(l10nEn.tallyNoneToday), findsOneWidget);
    expect(find.byType(SizedBox).evaluate().isEmpty, isFalse); // never an empty strip
  });

  testWidgets('TallySummaryBar states a fact and never instructs', (tester) async {
    await pumpLonja(tester, const TallySummaryBar(tally: kTallyHamourAtLimit));

    final rendered = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' ')
        .toLowerCase();
    for (final banned in const ['keep', 'return', 'release', 'discard', 'throw']) {
      expect(rendered, isNot(contains(banned)));
    }
  });

  testWidgets('TallySummaryBar renders counts as tabular figures aligned to the inline-end edge',
      (tester) async {
    await pumpLonja(tester, const TallySummaryBar(tally: kTallyTwoSpecies));

    final count = tester.widget<Text>(find.byKey(const ValueKey('tally.count')));
    expect(count.textAlign, TextAlign.end);
    expect(count.style!.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  // … one test per row above, one behaviour each
}
```

```dart
// app/test/domain/use_cases/watch_today_tally_test.dart
test('WatchTodayTally ranks a species by its share of the limit', () async {
  final useCase = WatchTodayTally(
    catches: FakeCatchLogRepository(counts: {kHamourId: 3, kKanaadId: 8}),
    reference: FakeReferenceRepository(bagLimits: {kHamourId: 5, kKanaadId: 20}),
  );

  final tally = await useCase(jurisdiction: 'AE-RK', zone: 'RAK-GULF').first;

  expect(tally.nearest!.speciesId, kHamourId); // 3/5 = 0.60 beats 8/20 = 0.40
});
```

**Run:** `cd app && flutter test test/ui/check/widgets/tally_summary_bar_test.dart test/domain/use_cases/watch_today_tally_test.dart`
→ 18 failures. If any passes now, the test is wrong.

## Implementation outline

1. `today_tally.dart`: an immutable value with `const` constructor, `==`, and a `TodayTally.none`
   constant. Domain models never carry a drift row (`FLUTTER_GUIDE.md` Part 2.5 rule 6).
2. `catch_log_repository.dart`: add
   `Stream<List<SpeciesDayCount>> watchTodayCounts({required String jurisdiction, required String zone, required DateTime dayStart, required DateTime dayEnd})`
   to the existing interface. `GROUP BY species_id` in SQL, over `idx_catch_created`.
3. `watch_today_tally.dart`: takes both repositories in its constructor as private fields, emits a
   `TodayTally`. Ranking by `count / limit`, ties on count, then on species id.
4. `tally_summary_bar.dart`: a `Table` in the `pair` class — uppercase tracked sans key on the start
   edge, mono tabular value on the end edge, `hairlineDotted` between rows, `groupOpen` above the first.
   No fill, no `Card`, no radius.
5. The at-limit marker: glyph, word and a `LonjaRules.rule` frame in `verdictWarn`. Words stay
   `onSurface` (3.97:1 fails 4.5:1 as text).
6. Wire the provider into `check_screen.dart` with `.select` so a tally emission rebuilds the bar and
   nothing else (`FLUTTER_GUIDE.md` Part 5.3).
7. Four ARB keys into all six locales, `gen-l10n`, re-run the suite including T02's layout tests.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 tests pass, and each failed first.
- [ ] The tally is aggregated in SQL; no list of `catch` rows crosses into Dart.
- [ ] `CatchLogRepository` does not import `ReferenceRepository`, and vice versa.
- [ ] Every number in the bar is tabular and end-aligned, and the `ar` test proves the mirroring.
- [ ] A species at or over its limit carries a glyph, a word and a frame — never colour alone.
- [ ] The rendered text of every state is free of the banned imperative lexicon in
      `product-invariants.md` §2, in all six locales.
- [ ] T02's bottom-third test still passes with six species in today's tally.
- [ ] The four ARB keys exist in all six locales (D-3).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh  app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh    app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
tools/gates/no_directional_geometry.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(check): state today's tally against the bag limit on Check

SPEC.md §4.5 wants the count visible without navigating away and §4.9 wants
the four species entry points in the bottom third. Rendering every species
inline satisfies the first and breaks the second — after four species the
entry points leave a 640 dp screen. So the bar states the total and the one
species nearest its limit by share, and S8 holds the full list one tap away
on the strip. §6 S1 calls the element a summary bar.

The join lives in domain/use_cases/ because it needs today's catches from
user.db and the bag limits from reference.db, and a repository may not know
another repository exists.

A null bag_limit is not zero: the bar states the count and says the limit is
not recorded, keeping §4.1's no-rule-versus-no-data distinction intact.

Task: E12/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
