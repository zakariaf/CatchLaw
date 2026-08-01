# E10/T03 — The findings list

| | |
|---|---|
| **Epic** | E10 — The result screen |
| **Branch** | `epic/10-result` (shared) |
| **Commit** | `feat(result): render the secondary findings in engine precedence order` |
| **Depends on** | T01 (the display model), T02 (the stamp that carries the headline) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.3 last paragraph, §4.1 "Rule evaluation", §6 S2 "findings list" |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 7 — precedence is fixed, total and applied exactly once, and NO surface re-ranks it |
| `catchlaw-verdict-contract` | Rules 1, 3, 4: every secondary finding is itself a statement of fact carrying its numbers and its named method |
| `lonja-verdict-and-status` | The rule that non-deciding findings still appear, so the stamp states one thing and the page states everything |
| `lonja-typography` | The serif for anything quoting law, mono tabular figures for every comparable number in the list |
| `accessibility-as-code` | Rules 2 and 6: each row's status is a glyph plus a word, never a bare coloured dot |
| `widget-composition` | A `.builder` list is wrong here (bounded, small) — a `Column` of `const` private rows, extracted as classes |
| `catchlaw-conventions-index` | Invariant 3 — each row names its rule and its citation, not just its outcome |
| `i18n-rtl-l10n` | Rule 5: the row's glyph, label and value must mirror by construction under `ar` |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.3 final paragraph | The precedence order and the headline/secondary split, verbatim as the source of truth |
| `SPEC.md` | §4.1 "Rule evaluation" row | "Every finding names its rule row and citation" — the acceptance condition of this task |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "Finding precedence", "Edge cases" | The six kinds with their headline examples, and that `indeterminate` never prints as a pass |
| `.claude/skills/lonja-verdict-and-status/references/states-and-signals.md` | "Precedence when several rules bite" | That the surface never re-ranks, and that a closed-season stamp still prints the size row |
| `.claude/skills/lonja-verdict-and-status/references/verdict-anatomy.md` | "The rule table" | The `th`/`td` setting the findings list shares with T04's table |
| `FLUTTER_GUIDE.md` | §1.2 | Why sorting in the View is disallowed even when it looks harmless |
| `epics/DECISIONS.md` | D-7 | The list renders sentences T01 built; it composes none |

## What this delivers

- `app/lib/ui/result/widgets/result_findings_list.dart` — `ResultFindingsList`, taking
  `List<FindingDisplay>` and rendering one `_FindingRow` per entry: glyph, the finding sentence,
  the rule row identity (`instrument`, `article`) and a citation marker that ties the row to T05's
  footnote.
- The list wired into `ResultSection`'s fixed slot, directly beneath the stamp.
- `app/test/ui/result/result_findings_list_test.dart`.

## Why it is built this way

**The stamp states one thing; the page states everything.** §7.3 says the first failure is headlined
and the rest are listed as secondary findings. `states-and-signals.md` is more specific: a
closed-season stamp still prints "Size rule — 45 cm total length, satisfied" beneath it, so the
fisher sees the whole picture without the stamp equivocating. This list is that "everything", and it
carries the findings the stamp deliberately does not.

**The order arrives already correct and is never touched.** `catchlaw-rule-engine` rule 7 makes
precedence fixed, total and applied exactly once in the engine; its anti-pattern list names
`findings.sort(...)` in the surface explicitly. A second sort in the widget is a second opinion about
legal precedence, held in the layer with the weakest tests. `ResultFindingsList` therefore renders
`display.secondary` in arrival order, and the test that proves it feeds a list in an order the widget
would "want" to fix.

**Every row names its rule row and its citation.** §4.1's acceptance condition for rule evaluation is
literally "Every finding names its rule row and citation". A row that says only "Below the minimum —
34 mm, minimum 38 mm" is an assertion; the same row with "Orde 27/07/2012, Art. 12" beside it is a
quotation. The marker is a superscript mono numeral matching the footnote T05 prints, so the reader
can walk from a row to its instrument without a tap.

**A satisfied rule is a finding, not silence.** A row reading "Size rule — minimum 45 cm (total
length), satisfied" is a statement of fact about a rule that was read. Dropping satisfied rules would
make a page with one closure look identical to a page where no size rule was ever transcribed — the
exact confusion §4.1's "no-rule-vs-no-data" row exists to prevent.

**`indeterminate` prints as an open question and never as a pass.** `resolution-algorithm.md` edge
cases: a size rule with no reading, or a bag limit with no catch log, is `indeterminate`. The row
reads "Bag limit — 6 per day; today's count not recorded", which is a true statement, and it takes
the neutral ink rather than verdant. Rendering it as satisfied would state that a limit was checked
when nothing was.

**Rejected — an `ExpansionTile` of secondary findings.** It hides the size rule under the closure
that outranked it, and the reader who most needs the second finding is the one who stops reading at
the stamp. Nothing on this screen is behind a tap except the rule text itself.

**Rejected — a `ListView.builder`.** The list is bounded by the six `FindingKind`s, so there is
nothing to virtualise; a builder inside the scrolling `ResultSection` would need a shrink-wrap and
buys a nested viewport for zero rows saved.

**Rejected — colour-coding the rows and dropping the glyph.** `accessibility-as-code` rule 6 and
invariant 4: a green dot beside a satisfied rule and an oxblood dot beside a failed one is one
channel, and the greyscale golden E19 owns would show two identical dots.

## Tests first

Write every row before touching `result_findings_list.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ResultFindingsList renders one row per secondary finding` | 3 findings | 3 `_FindingRow` widgets | The baseline: nothing is silently dropped |
| 2 | `ResultFindingsList preserves the engine order when the list is not sorted by severity` | `[bagLimit, minSize]` as delivered | rendered in that order | Proves the widget has no sort; a widget that "helpfully" reorders re-decides precedence |
| 3 | `ResultFindingsList renders the headline finding only in the stamp` | headline `closedSeason`, secondary `[minSize]` | the closure sentence appears once on the page | A doubled headline reads as two separate rules biting |
| 4 | `ResultFindingsList prints the size finding beneath a closed-season headline` | Sha'ri, closure headline | "minimum 45 cm (total length)" row present | The `states-and-signals.md` worked case; the whole point of secondary findings |
| 5 | `ResultFindingsList names the instrument and article on every row` | 2 findings, 2 citations | both instrument strings and both article strings found | §4.1: every finding names its rule row and citation |
| 6 | `ResultFindingsList marks each row with the citation index used by the footnote` | 2 distinct citations | markers `1` and `2`, matching T05's footnote order | A marker that disagrees with the footnote sends the reader to the wrong instrument |
| 7 | `ResultFindingsList reuses one marker for two findings from the same citation` | 2 findings, 1 citation | both rows carry marker `1` | Two markers for one instrument implies two instruments |
| 8 | `ResultFindingsList renders a satisfied rule as a stated finding` | `minSize` satisfied | row present, reading "satisfied", neutral ink | A read-and-satisfied rule is not the same as a rule that was never transcribed |
| 9 | `ResultFindingsList renders an indeterminate bag limit as an open question` | bag limit, no tally | row states the limit and that today's count is not recorded | Never a pass; "cannot be evaluated" is a safe statement of fact |
| 10 | `ResultFindingsList pairs a glyph with a word on every row` | mixed pass/fail rows | every row has an `Icon` and a text label | Colour alone fails greyscale and 8% of readers |
| 11 | `ResultFindingsList renders nothing when there are no secondary findings` | empty list | the list widget is absent, not an empty box | An empty ruled block reads as missing content |
| 12 | `ResultFindingsList states the method in words on every measurement row` | minSize + maxSize | both rows contain a spelled-out method | A bare `TL` turns a correct number into a wrong verdict |
| 13 | `RTL - ResultFindingsList places the marker at the start edge` | locale `ar` | marker rect start < sentence rect start | Physical geometry compiles and silently breaks in `ar` |
| 14 | `ResultFindingsList survives a 200% text scale with no overflow` | `textScaler: 2.0` | no overflow exception | §4.9's stated target on the densest block of the screen |
| 15 | `ResultFindingsList uses tabular figures for every number` | 2 rows, differing digit counts | both value styles carry `FontFeature.tabularFigures()` | `38 cm` and `188 cm` must share a decimal spine or the column reads as noise |

```dart
// app/test/ui/result/result_findings_list_test.dart
import 'package:catchlaw/ui/result/widgets/result_findings_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../harness.dart';

void main() {
  group('ResultFindingsList', () {
    testWidgets('preserves the engine order when the list is not sorted by severity',
        (tester) async {
      // Deliberately delivered least-severe first: the engine ranked once, and the
      // widget must not "fix" it.
      await tester.pumpApp(const ResultFindingsList(
        findings: <FindingDisplay>[kFindingBagLimitFails, kFindingMinSizeFails],
      ));

      final rows = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
      expect(rows.indexWhere((s) => s!.contains('daily bag')),
          lessThan(rows.indexWhere((s) => s!.contains('minimum'))));
    });

    testWidgets('renders an indeterminate bag limit as an open question', (tester) async {
      await tester.pumpApp(const ResultFindingsList(
        findings: <FindingDisplay>[kFindingBagLimitIndeterminate],
      ));

      expect(find.textContaining('not recorded'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('reuses one marker for two findings from the same citation', (tester) async {
      await tester.pumpApp(const ResultFindingsList(
        findings: <FindingDisplay>[kFindingMinSizeFails, kFindingMaxSizeSatisfiedSameCitation],
      ));

      expect(find.text('1'), findsNWidgets(2));
      expect(find.text('2'), findsNothing);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/ui/result/result_findings_list_test.dart` → 15 failures. If any
passes now, the test is wrong.

## Implementation outline

1. Add `citationIndex` to `FindingDisplay` in T01's file if T01 did not already assign it — the index
   is computed once in the presenter by de-duplicating citations in first-appearance order, so the
   list and the footnote cannot disagree.
2. `ResultFindingsList({required this.findings})`. `build()` returns `SizedBox.shrink()` when
   `findings.isEmpty` — the only `if` the View is allowed (`FLUTTER_GUIDE.md` §1.2).
3. `_FindingRow`: a private `StatelessWidget` in the same file, laid out with
   `EdgeInsetsDirectional` and `CrossAxisAlignment.start`: marker (mono, superscript), glyph
   (`ExcludeSemantics`, because the row's word already carries the state), sentence (serif),
   instrument and article (mono `t.citation`).
4. Resolve every style from `LonjaType.of(context)` and every colour from `LonjaColors.of(context)`.
   A satisfied row takes `ink`; a failed row takes the semantic ink; an indeterminate row takes
   `ink-muted`. No raw hex.
5. Wire it into `ResultSection` between the stamp and T04's table slot.
6. Re-run the whole suite. All 15 green, and T02's 22 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 15 tests pass, and each failed first.
- [ ] `result_findings_list.dart` contains no `sort`, no `reduce`, no `where` that drops a finding.
- [ ] Every row carries a glyph, a word and a citation reference.
- [ ] No satisfied finding is rendered with the same ink as a failed one.
- [ ] `check_lonja_verdict.sh app/lib` and `check_lonja_type.sh app/lib` are clean.
- [ ] The marker indices rendered here equal the footnote order T05 will print (asserted in T05).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh      app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
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
feat(result): render the secondary findings in engine precedence order

SPEC §7.3 headlines the first failure and lists the rest. The list renders
display.secondary in arrival order and contains no sort: precedence is
fixed, total and applied exactly once in the engine, and a second sort in
the widget would be a second opinion about legal precedence held in the
layer with the weakest tests.

Satisfied and indeterminate rules are printed too. A page with one closure
and no size row is indistinguishable from a page where the size rule was
never transcribed, which is exactly the confusion §4.1's
no-rule-vs-no-data requirement exists to prevent.

Task: E10/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
