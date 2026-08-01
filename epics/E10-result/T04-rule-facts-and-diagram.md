# E10/T04 — The rule-facts table and the measurement diagram

| | |
|---|---|
| **Epic** | E10 — The result screen |
| **Branch** | `epic/10-result` (shared) |
| **Commit** | `feat(result): print the rule-facts table and the active jurisdiction's method diagram` |
| **Depends on** | T01 (the display model), E04/E05 (`measurement_method.diagram_asset` in the reference DB) |
| **Size** | M |
| **Spec** | `SPEC.md` §6 S2 "rule facts table" and "measurement-method diagram", §4.2 "Method is per-species-per-jurisdiction", §9.3 (diagrams do not mirror) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-verdict-and-status` | Owns the rule table's setting and the rule that only a cell stating a rule outcome takes semantic ink |
| `lonja-typography` | Rule 3 — every comparable numeral is mono with `FontFeature.tabularFigures()`, or the column loses its decimal spine |
| `catchlaw-verdict-contract` | Rule 4 — the method is named in words in the table too, never a bare `TL` or `SHL` |
| `catchlaw-rule-engine` | Rule 12 — a measurement is compared only against its own method; the table prints the method the rule row states |
| `catchlaw-conventions-index` | Invariant 1: the diagram is a bundled asset, and `SvgPicture.network` is a banned symbol |
| `i18n-rtl-l10n` | Rule 5 and the deliberate non-mirroring exception this task implements |
| `accessibility-as-code` | Rule 2 — the diagram is an `Image`/SVG and needs a `semanticLabel` or an explicit `ExcludeSemantics` |
| `widget-composition` | The table is a `Table`/`Column` of `const` private row widgets, not a `_buildRow()` helper |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.2 last two rows | Each method has an SVG diagram showing the two endpoints, and the diagram always comes from the active jurisdiction's rule row |
| `SPEC.md` | §7.1 `measurement_method` and `rule` DDL | `measurement_method_id` lives on the rule row; `diagram_asset` and `name_key` live on the method |
| `SPEC.md` | §9.3 third bullet | Measurement diagrams do not mirror — a fork-length arrow must point at the actual fork |
| `SPEC.md` | §5.3 second bullet | `SvgPicture.network` and `Image.network` are banned by grep |
| `.claude/skills/lonja-verdict-and-status/references/verdict-anatomy.md` | "The rule table", "The vertical order" slots 6 and 7 | `th`/`td` setting, the dotted separators, and that the diagram sits after the table |
| `.claude/skills/lonja-verdict-and-status/references/states-and-signals.md` | "Why protected cannot be below-minimum in another shade" — table row | The protected table shape: Status / Size rule: Not applicable / Season: Not applicable |
| `.claude/skills/catchlaw-verdict-contract/references/verdict-copy-rules.md` | "Numbers, units and dates" | The unit follows the instrument; the measured value is echoed unchanged |
| `FLUTTER_GUIDE.md` | §8.1 "Practical shape" | Private widget classes in the same file, and minimising node count |

## What this delivers

- `app/lib/ui/result/widgets/result_rule_facts_table.dart` — `ResultRuleFactsTable`, taking
  `List<RuleFactRow>` and rendering the `th`/`td` pairs with dotted separators; a cell that states a
  rule outcome takes the semantic ink and `w600`, and only such a cell does.
- `app/lib/ui/result/widgets/result_method_diagram.dart` — `ResultMethodDiagram`, taking the asset
  path and the spelled-out method name from the **active jurisdiction's rule row**, rendering the
  bundled SVG inside a 1 dp ruled `paper-sunk` frame, wrapped in
  `Directionality(textDirection: TextDirection.ltr)` with the exception commented in the code.
- Both wired into `ResultSection`'s slots 6 and 7.
- `app/test/ui/result/result_rule_facts_table_test.dart`,
  `app/test/ui/result/result_method_diagram_test.dart`.

## Why it is built this way

**The diagram comes from the rule row, not from the species.** §4.2's last row is unambiguous: the
same species may be measured differently in two countries, and the diagram always comes from the
active jurisdiction's rule row. The schema encodes that — `measurement_method_id` is a column on
`rule`, not on `species` (§7.1). A diagram sourced from the species would show a total-length arrow
to a fisher standing in a jurisdiction whose instrument states fork length, and he would measure to
the wrong point on the fish while reading a verdict that says he did not. `catchlaw-rule-engine`
rule 12 prices that error: 65 cm fork length is roughly 71 cm total length.

**The diagram does not mirror.** §9.3 makes this a deliberate exception alongside the ruler: a
fork-length arrow must point at the actual fork, and mirroring it under `ar` points it at the snout.
The widget wraps its own subtree in `Directionality(textDirection: TextDirection.ltr)` and says so in
a comment, exactly as `i18n-rtl-l10n` allows for a locale-invariant subtree. Its *caption* localises
normally and sits outside the LTR island.

**The table is the whole picture; the stamp is one line of it.** A closed-season stamp prints no
size number, so the table is where "Size rule — 45 cm total length" is stated. A protected result
takes a different table shape entirely: Status / Size rule: Not applicable / Season: Not applicable,
because printing a size row under a prohibition implies a threshold above which the fish could be
taken.

**Only outcome cells take semantic ink.** `verdict-anatomy.md` is precise: a cell that states a rule
outcome takes the semantic ink and `w600` — `Open all year` in verdant, `Fully protected` in oxblood
— and only such cells do. A table where every value is coloured turns the semantic inks into
decoration, and once the accent can look like a verdict, no colour on the screen is evidence.

**Tabular figures are load-bearing.** `38 cm`, `45 cm` and `188 cm` in one column only align on a
decimal spine if the figures are tabular. Without it the column reads as noise at arm's length in
sunlight, which is the only condition it will ever be read in.

**Rejected — `SvgPicture.network` or any remote asset.** §5.3 lists it as a banned symbol and §14
greps for it; the asset is bundled under `app/assets/method/` and loaded from `rootBundle`.

**Rejected — a Material `DataTable`.** It brings Material dividers with 16 dp physical (non-
directional) padding, a fixed row height that breaks at 200% text scale, and horizontal scrolling
behaviour the ruled sheet does not want. The table is a `Column` of private row widgets separated by
1 dp dotted rules.

**Rejected — caching the rasterised SVG globally.** §13's low-end-device row says SVGs are rasterised
at display size and cached by key, which is the flutter_svg default; a bespoke cache on a screen that
shows one diagram is complexity `/simplify` should delete.

## Tests first

Write every row before touching either widget. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ResultRuleFactsTable renders one row per fact` | 4 facts | 4 label/value pairs | The baseline: nothing dropped, nothing invented |
| 2 | `ResultRuleFactsTable prints the measurement method in words` | min-size fact, method TL | cell reads `total length`, never `TL` | A bare code is a wrong verdict stated with full confidence |
| 3 | `ResultRuleFactsTable keeps the instrument's unit` | shell-length rule in mm | `38 mm`, not `3.8 cm` | The unit follows the instrument, never the locale or the user preference |
| 4 | `ResultRuleFactsTable renders the protected table shape with no size row` | protected display | rows read Status, Size rule: Not applicable, Season: Not applicable | A size row under a prohibition implies a threshold that does not exist |
| 5 | `ResultRuleFactsTable applies the semantic ink only to outcome cells` | mixed table | the outcome cell takes the semantic ink; label and plain value cells do not | Once every cell can look like a verdict, no colour is evidence |
| 6 | `ResultRuleFactsTable uses tabular figures for every value cell` | 2 rows, 2 and 3 digits | both styles carry `FontFeature.tabularFigures()` | Values that do not share a decimal spine cannot be compared at arm's length |
| 7 | `ResultRuleFactsTable separates rows with a dotted rule` | 3 rows | 2 separators, first row topped by a solid rule | The ruled sheet's structure; a missing rule reads as a merged row |
| 8 | `ResultRuleFactsTable survives a 200% text scale with no overflow` | `textScaler: 2.0` | no overflow exception | The densest two-column block on the screen |
| 9 | `RTL - ResultRuleFactsTable start-aligns labels and end-aligns values` | locale `ar` | label rect start < value rect start, mirrored | `th` start-aligned and `td` end-aligned must follow direction, not sides |
| 10 | `ResultMethodDiagram loads the asset named on the active jurisdiction's rule row` | rule row with `method/fl_arrow.svg` | that asset path is requested | The §4.2 requirement this task exists for |
| 11 | `ResultMethodDiagram renders a different asset for the same species in a second jurisdiction` | one species, two rule rows | two different asset paths | The failure case stated in §4.2: the same species measured differently in two countries |
| 12 | `ResultMethodDiagram renders no diagram when the rule row states no method` | rule with `measurement_method_id` null | the frame is absent, not empty | A blank ruled frame reads as a missing illustration |
| 13 | `RTL - ResultMethodDiagram does not mirror the diagram` | locale `ar` | the diagram subtree resolves to `TextDirection.ltr` | A mirrored fork-length arrow points at the snout |
| 14 | `RTL - ResultMethodDiagram localises the caption outside the LTR island` | locale `ar` | the caption text is laid out RTL | The exception is the drawing, not the words about it |
| 15 | `ResultMethodDiagram labels the diagram for a screen reader` | any | a semantics label naming the method | An unlabelled image is invisible to TalkBack |
| 16 | `ResultMethodDiagram loads the diagram from the bundle` | any | the asset is requested from `rootBundle`, and no network symbol is reachable | §5.3 and §14: nothing on this screen fetches |

```dart
// app/test/ui/result/result_method_diagram_test.dart
import 'package:catchlaw/ui/result/widgets/result_method_diagram.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../harness.dart';

void main() {
  group('ResultMethodDiagram', () {
    testWidgets('renders a different asset for the same species in a second jurisdiction',
        (tester) async {
      await tester.pumpApp(const ResultMethodDiagram(
        assetPath: 'assets/method/tl_arrow.svg',
        methodName: 'total length',
      ));
      expect(kRequestedAssets, contains('assets/method/tl_arrow.svg'));

      await tester.pumpApp(const ResultMethodDiagram(
        assetPath: 'assets/method/fl_arrow.svg',
        methodName: 'fork length',
      ));
      expect(kRequestedAssets, contains('assets/method/fl_arrow.svg'));
    });

    testWidgets('RTL - does not mirror the diagram', (tester) async {
      await tester.pumpApp(
        const ResultMethodDiagram(assetPath: 'assets/method/fl_arrow.svg', methodName: 'fork length'),
        locale: const Locale('ar'),
      );

      final drawing = find.byKey(const ValueKey('method-diagram-drawing'));
      expect(Directionality.of(tester.element(drawing)), TextDirection.ltr);
    });

    testWidgets('RTL - localises the caption outside the LTR island', (tester) async {
      await tester.pumpApp(
        const ResultMethodDiagram(assetPath: 'assets/method/fl_arrow.svg', methodName: 'طول الشوكة'),
        locale: const Locale('ar'),
      );

      final caption = find.byKey(const ValueKey('method-diagram-caption'));
      expect(Directionality.of(tester.element(caption)), TextDirection.rtl);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/ui/result/` → 16 new failures. If any passes now, the test is
wrong.

## Implementation outline

1. Extend T01's `RuleFactRow` with `label`, `value`, `isOutcome` and an optional
   `VerdictCategory` for the ink of an outcome cell. The presenter builds the protected table shape;
   the widget does not branch on category.
2. `ResultRuleFactsTable`: a `Column` of `_FactRow` private widgets, first row topped by a 1 dp solid
   `ink` rule, subsequent rows separated by a 1 dp dotted `rule`. `th` start-aligned at 44% width,
   `td` end-aligned. All geometry `EdgeInsetsDirectional` / `AlignmentDirectional`.
3. `ResultMethodDiagram({required this.assetPath, required this.methodName})`. `build()` returns
   `SizedBox.shrink()` when the presenter supplied no asset.
4. The drawing subtree: `Directionality(textDirection: TextDirection.ltr, …)` with a comment naming
   §9.3 as the reason, keyed `method-diagram-drawing`. `SvgPicture.asset` inside a `DecoratedBox`
   with `paper-sunk` fill and a 1 dp `rule` border. The subtree is `ExcludeSemantics` and the frame
   carries one `Semantics(label: methodName)` node, so the reader hears the method once.
5. The caption sits outside the island, keyed `method-diagram-caption`, styled from
   `LonjaType.of(context)`.
6. Wire both into `ResultSection` at slots 6 and 7. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 16 tests pass, and each failed first.
- [ ] `grep -rn "SvgPicture.network\|Image.network\|NetworkImage" app/lib/ui/result` returns nothing.
- [ ] The diagram asset path is read from the rule row's method, never from the species row.
- [ ] The only `Directionality` in `app/lib/ui/result/` is the commented diagram island.
- [ ] Every value cell resolves to a mono step carrying `FontFeature.tabularFigures()`.
- [ ] `check_lonja_type.sh app/lib` and `check_lonja_tokens.sh app/lib` are clean.
- [ ] No raw hex colour in either widget; every colour from `LonjaColors.of(context)`.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh      app/lib
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh       app/lib
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
feat(result): print the rule-facts table and the active jurisdiction's method diagram

measurement_method_id is a column on rule, not on species, because the same
species is measured differently in two countries (§4.2). The diagram is
therefore taken from the active jurisdiction's rule row: sourcing it from
the species would show a total-length arrow to a fisher whose instrument
states fork length, and 65 cm FL is roughly 71 cm TL.

The diagram subtree is pinned to LTR with the reason in a comment (§9.3) —
a mirrored fork-length arrow points at the snout. Its caption localises
normally, outside the island. Only cells that state a rule outcome take a
semantic ink, so the inks keep meaning something.

Task: E10/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
