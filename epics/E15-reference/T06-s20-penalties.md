# E15/T06 — S20, penalties

| | |
|---|---|
| **Epic** | E15 — The reference section |
| **Branch** | `epic/15-reference` (shared) |
| **Commit** | `feat(reference): add S20, penalties, in each jurisdiction currency and never converted` |
| **Depends on** | T04 (`ReferenceScreenHeader`), T05 (`matchesFoldedQuery`) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.6 ("the screen that makes people keep the app"), §6 S20, §6's shared line for S18–S23, §7.1 (`penalty`), §9.5 (currency, never converted), §9.3 (numerals) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | This is the screen the ledger table exists for. Rule 4 (tabular, end-aligned numerics), rule 5 (ruled, never zebra-striped), and the semantic tone overrides on a numeric cell |
| `lonja-typography` | Rule 3 — every comparable numeral is mono with `FontFeature.tabularFigures()`; the `datum` and `citation` steps; `LonjaMeasure.digitColumn` |
| `catchlaw-verdict-contract` | A penalty is a statement about a published schedule, not a threat. Rules 1, 2, 3 and 5 all bind the copy here |
| `catchlaw-conventions-index` | Invariant 3 — `penalty.citation_id` is `NOT NULL`; invariant 4 — the oxblood fine cell needs a word beside it |
| `i18n-rtl-l10n` | Per-locale `NumberFormat`, the Arabic-Indic digit block, ICU `select` for the occurrence label, and why the value is stored canonical and formatted at the edge |
| `lonja-forms-and-controls` | The search field over offence labels |
| `persistence-drift` | Rule 5: money is integer minor units keyed to the real ISO-4217 exponent, plus a separate currency code column — the rule that makes epic Risk 1 visible |
| `widget-golden-and-a11y-testing` | The `ar` real-font lane, where the digit block and the pinned numeral column are decided |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.6 | "Penalties (S20) — what a violation costs, per jurisdiction, per occurrence. **The screen that makes people keep the app**" |
| `SPEC.md` | §6 S20 and the S18–S23 line | Searchable list backed by its table, jurisdiction and content version in the header, `content_string` labels, the "not recorded" empty state |
| `SPEC.md` | §7.1 | `penalty(jurisdiction_id, offence_key, occurrence, amount_min, amount_max, currency, secondary_key, citation_id)`. Note what is nullable: both amounts, the currency and the secondary consequence |
| `SPEC.md` | §9.5 | "**Currency:** each jurisdiction's own currency via `NumberFormat.currency`, **never converted**"; and the complete-phrase rule for `secondary_key` |
| `SPEC.md` | §9.3 | The numeral-system reality: `intl` has no numbering-system API, the only lever is `numberFormatSymbols`, and it is process-wide. E06 owns the lever; this screen consumes it |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The ledger table — column classes", "Numeric alignment and RTL mirroring" | `label` / `numeric` / `prose` classes and their widths; `TextAlign.end` never `.right`; "`oxblood` for a fine or a failing count" as a documented semantic tone |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rules 4, 5, 8 | Tabular end-aligned figures; ruled, no fill, no zebra; a row states and never instructs. The worked `Table` snippet is the shape this screen builds |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Numerals" points 1, 2 and 5 | Arabic-Indic digits have **no tabular coverage**, so pin the column with `LonjaMeasure.digitColumn`; citation dates stay Western-digit ISO |
| `.claude/skills/persistence-drift/SKILL.md` | rule 5 | Integer minor units keyed to the currency's real ISO-4217 exponent — "never a hardcoded `* 100`" |
| `.claude/skills/persistence-drift/references/schema-and-daos.md` | "Column type discipline" | `0` for JPY/VND, `2` for most, **`3` for KWD/BHD/OMR** — the three that make a literal divisor wrong in this product |
| `.claude/skills/catchlaw-verdict-contract/references/verdict-copy-rules.md` | "Review checklist", "Numbers, units and dates" | "Can it be prefixed with 'It is recorded that' and still parse?"; the unit follows the instrument, never the device locale |
| `FLUTTER_GUIDE.md` | Part 5.2 | The vertical slice |
| `epics/DECISIONS.md` | D-1, D-3 | Paths; the six locales |

## What this delivers

- `app/lib/data/daos/penalty_dao.dart` — `PenaltyDao.watchPenalties({jurisdictionId})`, ordered
  `offence_key ASC, occurrence ASC`.
- `app/lib/domain/models/penalty_entry.dart` — `PenaltyEntry`: `offenceKey`, `occurrence`,
  `amountMinMinor`, `amountMaxMinor`, `currency`, `secondaryKey`, non-nullable `Citation`.
- `app/lib/domain/models/penalty_group.dart` — `PenaltyGroup`: one offence and its occurrences in
  ascending order.
- `app/lib/data/repositories/penalty_repository.dart` + `_drift.dart` + a fake.
- `app/lib/ui/reference/penalties_screen.dart` — `PenaltiesScreen`.
- `app/lib/ui/reference/widgets/penalty_ledger.dart` — `PenaltyLedger`, the ruled `Table`.
- `app/lib/ui/reference/penalty_amount_format.dart` — `String formatPenaltyAmount({int? minMinor, int?
  maxMinor, required String currency, required AppLocalizations l10n, required String localeName})`.
- `app/lib/ui/core/ui/lonja_ledger_table.dart` — **only if absent.** If E13 already authored
  `LonjaLedgerTable`, use it and author nothing.
- ARB keys in all six files (D-3): `referencePenaltiesTitle`, `referencePenaltyOccurrence`
  (ICU `select`), `referencePenaltyAmountRange`, `referencePenaltyAmountFrom`,
  `referencePenaltyAmountUpTo`, `referencePenaltyAmountNotRecorded`,
  `referencePenaltyColumnOccurrence`, `referencePenaltyColumnAmount`,
  `referencePenaltyColumnConsequence`, `referencePenaltiesEmptyHeadline`,
  `referencePenaltiesEmptyBody`.
- Tests: `app/test/data/penalty_dao_test.dart`,
  `app/test/ui/reference/penalty_amount_format_test.dart`,
  `app/test/ui/reference/penalties_screen_test.dart`.

## Why it is built this way

**§4.6 calls this the screen that makes people keep the app, so it is built as a screen and not as a
list.** It gets the masthead with the jurisdiction and the content version, one
`LonjaSectionLabel` per offence, a ruled ledger of that offence's occurrences, and the citation for
the offence underneath its own table. A reader can hold the phone up and read a schedule.

**The ledger is the right container here, and it was the wrong one in T05.**
`row-and-table-anatomy.md`'s container table sends "a true grid of penalties or limits" to a `Table`
with fixed column classes. Three columns fit: `label` for the occurrence (34 %), `numeric` for the
amount (33 %), `prose` for the secondary consequence (33 %). Unlike S19's four columns of prose, this
fits at 320 dp without a horizontal scroller. Header cells over a 1.5 px `ledgerHead` rule, body rows
on dotted hairlines, **no fill and no zebra stripe** — rule 5, because an alternating background
survives neither sunlight mode nor a screenshot handed to an inspector.

**The amount is integer minor units and the divisor comes from the currency, never from a literal.**
`SPEC.md` §7.1 declares `amount_min INTEGER` and does not say what the integer counts.
`persistence-drift` rule 5 settles it — integer minor units plus a separate ISO-4217 code — and the
exponent is **not 2 everywhere this app ships**: AED, EUR and BRL are 2, but **BHD, KWD and OMR are
3**. A hardcoded `/100` renders a Bahraini fine at ten times its value, on the screen `SPEC.md` says
keeps the user. So `formatPenaltyAmount` takes the number of fraction digits from
`NumberFormat.currency`'s own `decimalDigits` for the currency and never from a constant, and test 8
covers BHD beside AED and EUR. **If `intl` returns the wrong exponent for a currency, that test goes
red and the fix is an explicit `decimalDigits` argument** — the test decides, not an assumption about
the package. This is epic Risk 1, and the proper resolution is one assertion in
`tools/content_builder/` declaring the unit; that is E22's file.

**Never converted means no rate, no second currency, and no "≈".**
§9.5 is one clause and it is absolute. A Galician reader looking at a Ras Al Khaimah penalty sees
dirhams. **Rejected:** an approximate euro figure in parentheses — it would require a rate, a rate
requires a fetch or a stale constant, and invariant 1 forbids the first while the second would put a
wrong number next to a legal one.

**Four amount shapes, four ARB keys, no string concatenation.**
Both amounts, one amount or neither may be recorded (§7.1 makes all of them nullable). Range, `from`,
`up to` and `not recorded` are four separate ICU messages with the formatted amounts as placeholders.
**Rejected:** building `'$min – $max'` in Dart, which puts the dash, the word order and the currency
position outside the translator's reach — and in Arabic the currency name, the range word and the
direction all differ.

**The occurrence label is an ICU `select`, deliberately not a `plural`.**
"First offence", "Second offence" are ordinals, not counts. §9.5 requires an `ar` **plural** to carry
all six CLDR categories and makes a missing one a build failure; that rule binds counts and does not
apply to a `select`. The key therefore takes `occurrence` as a `String` and branches on `1`, `2`, `3`
and `other`, with `other` carrying the number as a placeholder. **This is written down here so nobody
"fixes" it into a plural** and then has to invent Arabic dual and paucal forms for an ordinal.

**The numeric column is pinned, because tabular figures do not exist in Arabic-Indic.**
`arabic-and-scripts.md` is explicit: `FontFeature.tabularFigures()` is a no-op on Arabic-Indic
digits, which fall back to the Naskh face at proportional widths and lose the column's decimal spine.
So the amount column is pinned to `LonjaMeasure.digitColumn` with `TextAlign.end` — never
`TextAlign.right`, which in Arabic pins the figure to the row's *start* edge, landing it under its own
label.

**Oxblood on the fine cell is a documented semantic tone, and it is not the only signal.**
`row-and-table-anatomy.md` allows `oxblood` on a numeric cell for "a fine or a failing count" and
bans tinting for emphasis. The column header names the column and the offence label names the
offence, so the hue adds nothing the words do not already say — invariant 4 is satisfied by the
words, and the colour is the third signal rather than the first.

## Tests first

Write every row before touching `penalty_dao.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `PenaltyDao.watchPenalties groups occurrences under one offence` | 3 rows, one `offence_key` | 1 group of 3 | The screen's shape: an offence with its escalation, not three unrelated rows |
| 2 | `PenaltyDao.watchPenalties orders occurrences ascending` | rows inserted 3, 1, 2 | 1, 2, 3 | An escalation printed out of order misstates which fine applies first |
| 3 | `PenaltyDao.watchPenalties excludes another jurisdiction` | two jurisdictions | only the active one | The reference DB holds every jurisdiction |
| 4 | `PenaltyEntry cannot be constructed without a Citation` | analyzer | compile error | Invariant 3; `penalty.citation_id` is `NOT NULL` |
| 5 | `formatPenaltyAmount renders a range with both bounds` | min 300000, max 500000, AED | one string containing both, in AED | The common shape in a published schedule |
| 6 | `formatPenaltyAmount renders a from-amount when only the minimum is recorded` | min only | the `from` message | §7.1 makes `amount_max` nullable and instruments really do print a floor only |
| 7 | `formatPenaltyAmount renders an up-to amount when only the maximum is recorded` | max only | the `up to` message | The mirror case; without it the screen would print an empty cell |
| 8 | `formatPenaltyAmount renders BHD with three fraction digits` | 3000 minor, BHD | `0.003` scaled by the currency's own exponent, not by 100 | ISO-4217 gives BHD, KWD and OMR an exponent of 3. A literal `/100` is wrong by a factor of ten on the screen that keeps the user |
| 9 | `formatPenaltyAmount renders AED with two fraction digits` | 300000 minor, AED | scaled by 100 | The control case that proves test 8 is measuring the exponent rather than a special case |
| 10 | `formatPenaltyAmount renders EUR with two fraction digits under the gl locale` | 300000 minor, EUR, `gl` | Galician grouping and decimal separators | §9.5's locale separator rule, on a currency that is not the Gulf's |
| 11 | `formatPenaltyAmount renders no second currency and no approximation mark` | any input | no `≈`, no second ISO code | §9.5's "never converted", asserted rather than trusted |
| 12 | `formatPenaltyAmount renders the not-recorded message when both bounds are null` | both null | the `not recorded` message | §7.1 allows it, and a blank cell would read as a zero fine |
| 13 | `ar - PenaltyLedger pins the amount column to digitColumn` | `ar` locale | the amount cell's width equals `LonjaMeasure.digitColumn` | Arabic-Indic digits have no tabular coverage; without the pin the column loses its spine |
| 14 | `ar - PenaltyLedger aligns the amount to the end edge` | `ar` locale | `TextAlign.end`, and the cell's start edge is the row's start | `TextAlign.right` would put the figure under its own label in RTL |
| 15 | `PenaltyLedger sets no background colour on any TableRow` | any fixture | every row's decoration has a border and no fill | Rule 5. A zebra stripe vanishes in sunlight mode |
| 16 | `PenaltyLedger renders the occurrence label from the ICU select in all six locales` | occurrences 1–4 | four distinct labels per locale | The `select`-not-`plural` decision, pinned so the ordinal branches survive review |
| 17 | `PenaltiesScreen renders the citation under each offence group` | two offences | two citations | Invariant 3 at the group level, which is where the instrument actually attaches |
| 18 | `PenaltiesScreen contains no imperative and no second person in any locale` | every ARB value for this screen | none of families A or B | A penalty schedule read as a warning becomes advice |
| 19 | `PenaltiesScreen renders the not-recorded state when no penalty exists` | empty fixture | authored headline and body | Empty surface 5 of eight |
| 20 | `PenaltiesScreen shows the ochre stale bar above a full ledger when the pack is expired` | expired jurisdiction | bar present and every group present | Invariant 5 |

```dart
// app/test/ui/reference/penalty_amount_format_test.dart
import 'package:catchlaw/ui/reference/penalty_amount_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatPenaltyAmount renders BHD with three fraction digits', () {
    // ISO-4217 gives BHD an exponent of 3. A hardcoded /100 is wrong by 10x.
    final s = formatPenaltyAmount(
      minMinor: 3000, maxMinor: null, currency: 'BHD',
      localeName: 'ar', l10n: kTestL10nAr,
    );
    expect(s, contains('3.000'));
    expect(s, isNot(contains('30.00')));
  });

  test('formatPenaltyAmount renders no second currency and no approximation mark', () {
    final s = formatPenaltyAmount(
      minMinor: 300000, maxMinor: 500000, currency: 'AED',
      localeName: 'gl', l10n: kTestL10nGl,
    );
    expect(s, isNot(contains('≈')));
    expect(s, isNot(contains('EUR')));
  });
}
```

```dart
// app/test/ui/reference/penalties_screen_test.dart
testWidgets('PenaltyLedger sets no background colour on any TableRow', (tester) async {
  tester.useDevice(Device.small);
  await tester.pumpApp(overrides: kRakPenaltyOverrides);
  final rows = tester.widgetList<TableRow>(find.byType(TableRow));
  for (final row in rows) {
    final decoration = row.decoration as BoxDecoration?;
    expect(decoration?.color, isNull,
        reason: 'rule 5: ledgers are ruled, never zebra-striped');
    expect(decoration?.border, isNotNull);
  }
});
```

**Run:** `cd app && flutter test test/data/penalty_dao_test.dart test/ui/reference/` → 20 failures.
Test 9 is the one most likely to pass early against a stub that divides by 100; that is exactly why
test 8 sits next to it.

## Implementation outline

1. Write `PenaltyEntry` and `PenaltyGroup` with required non-nullable `Citation`s.
2. Write `PenaltyDao`: one scoped `customSelect` joining `penalty` and `citation`, ordered
   `offence_key ASC, occurrence ASC`; fold into `PenaltyGroup`s in the repository, not in the widget.
3. Write `formatPenaltyAmount`. Read the fraction-digit count from the currency through
   `NumberFormat.currency`, scale the minor units by it, and select one of the four ICU messages.
   **No literal divisor anywhere in the function.**
4. Add the eleven ARB keys. `referencePenaltyOccurrence` is an ICU `select` over a `String` with
   branches `1`, `2`, `3`, `other`; its `@description` states that it is an ordinal and must not be
   converted to a `plural`.
5. Author `LonjaLedgerTable` in `app/lib/ui/core/ui/` **only if it does not already exist**.
6. Write `PenaltyLedger`: three fixed column classes, a header over `ledgerHead`, body rows on
   `hairlineDotted`, the amount cell pinned to `LonjaMeasure.digitColumn` with `TextAlign.end` and the
   `oxblood` tone.
7. Write `PenaltiesScreen`: header, search field over offence labels through `matchesFoldedQuery`,
   one section per offence, the citation under each group, the four states.
8. Author this screen's empty-state copy (surface 5 of eight) inline; T09 consolidates it.
9. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 20 tests pass, and each failed first.
- [ ] `grep -rn '/ 100\|\* 100\|100.0' app/lib/ui/reference/` returns nothing — the divisor comes
      from the currency.
- [ ] No conversion, exchange rate, second currency or `≈` exists anywhere in the diff or in any ARB
      value for this screen.
- [ ] `referencePenaltyOccurrence` is an ICU `select`, and its `@description` says why it is not a
      plural.
- [ ] Every amount cell carries `FontFeature.tabularFigures()`, `TextAlign.end` and a pinned
      `LonjaMeasure.digitColumn` width; the `ar` golden shows a straight column.
- [ ] No `TableRow` sets a background `color`.
- [ ] Every offence group renders its citation.
- [ ] `check_lonja_lists.sh app/lib` and `check_lonja_type.sh app/lib` are clean.
- [ ] `packages/rule_engine/` untouched (D-7).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh     app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
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
feat(reference): add S20, penalties, in each jurisdiction currency and never converted

SPEC.md §4.6 calls this the screen that makes people keep the app, so it is built
as a screen: masthead, one section per offence, a ruled three-column ledger of
that offence's occurrences, and the citation under each group.

Amounts are integer minor units and the fraction-digit count comes from the
currency, never from a literal. ISO-4217 gives BHD, KWD and OMR an exponent of 3
while AED, EUR and BRL take 2, so a hardcoded /100 renders a Bahraini fine at ten
times its value. A test covers BHD beside AED and EUR; if intl returns the wrong
exponent the test decides, not an assumption about the package.

Range, from, up-to and not-recorded are four ICU messages with the formatted
amount as a placeholder. Nothing is concatenated in Dart, because the dash, the
word order and the currency position all move between the six locales.

The occurrence label is an ICU select, not a plural: "First offence" is an
ordinal, and §9.5's six-category rule binds counts.

Task: E15/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
