# E19/T04 — Contrast: 4.5:1, and 7:1 in sunlight

| | |
|---|---|
| **Epic** | E19 — Accessibility, sunlight and glove modes |
| **Branch** | `epic/19-accessibility` (shared) |
| **Commit** | `test(theme): assert contrast where it composites, and 7:1 in sunlight` |
| **Depends on** | T01 (the registry); E07/T03 (the three themes and their contrast rows); E10/T06 (whatever the stale bar's ground was bound to) |
| **Size** | M |
| **Spec** | `SPEC.md` §13 accessibility row (*contrast ≥ 4.5:1, ≥ 7:1 in sunlight mode*), §4.9 "Sunlight mode" row (*a third theme, not a dark-mode variant: maximum contrast, monochrome plus result colour*) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-design-tokens` | Rules 8 and 10, and `references/three-themes-and-modes.md` — sunlight is authored, not derived, and every slot ships a measured row in all three themes |
| `widget-golden-and-a11y-testing` | Rule 9 and `references/a11y-guidelines-and-limits.md`'s "Contrast" section: assert on colour VALUES, never on pixels, because `textContrastGuideline` has an open false negative |
| `accessibility-as-code` | Rule 7 — contrast is measured against the **composited** background in every theme, never against the nominal token, and never on a fill or a translucency |
| `lonja-verdict-and-status` | Rule 10 and `references/verdict-anatomy.md`'s "Sunlight reversal" — the reversed stamp is the one place in the app where text sits on a solid coloured field |
| `lonja-typography` | `references/type-ramp.md` — which step carries a fact, so the "never a fact in `onSurfaceFaint`" rule has a list to check against |
| `lonja-buttons` | Rule 9 and the disabled row of the state matrix — why the disabled *label* is incidental under WCAG 1.4.3 and the adjacent reason prose is not |
| `testing-strategy` | Rule 1 — the ratio is `f(input) → output` and belongs in pure Dart; only "what composites on what" needs a tree |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §13 accessibility row | `Contrast ≥ 4.5:1 (≥ 7:1 in sunlight mode)` — the two floors, and that the second is a property of a theme rather than of a widget |
| `SPEC.md` | §4.9 "Sunlight mode" row | *A third theme (not a dark-mode variant): maximum contrast, monochrome plus result colour* |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | the three "Measured contrast" tables | Every slot's figure per theme, including `onSurfaceFaint` 3.62:1 on paper and `ochre47` 3.97:1 — the two numbers this task's screen-level rules follow from |
| `.claude/skills/lonja-design-tokens/references/three-themes-and-modes.md` | "Why sunlight is a palette, not an inversion" | The four-line arithmetic showing what a `copyWith` third theme keeps, and why sunlight removes tonal steps rather than raising ratios |
| `.claude/skills/widget-golden-and-a11y-testing/references/a11y-guidelines-and-limits.md` | "Contrast: a pure-Dart unit test, because the guideline false-passes" | White on `#FAFAFA` passes the guideline; grayscale is not an independent channel; when a floor fails, change the colour, never the floor |
| `.claude/skills/lonja-verdict-and-status/references/verdict-anatomy.md` | "Sunlight reversal" | The reversed stamp: solid ground, `#FFFFFF` ink, tilt 0 — the one text-on-fill pair on the result screen |
| `.claude/skills/lonja-buttons/references/variant-ladder-and-states.md` | "Theme resolution", "Disabled: the reason is part of the state" | Which slot each rung's label and field resolve to per theme, and that the reason prose is a sibling rather than a tooltip |
| `epics/E07-lonja-theme/epic.md` | Definition of done | E07 already asserts every slot's figure against `surface` and `surfaceSunk`; this task does not repeat it |

## What this delivers

- `app/test/a11y/support/contrast.dart` — `contrastRatio(Color, Color)` in pure Dart, plus
  `resolvedTextColour(tester, finder)` and `resolvedGroundOf(tester, finder)`, which read the
  **declared** colour of a rendered span and of the box it is painted into.
- `app/test/a11y/composited_contrast_test.dart` — the pairs that only exist once a screen has
  composited them, in all three themes.
- `app/test/a11y/sunlight_palette_test.dart` — the 7:1 sweep and the "no grey survived" assertions.
- Colour changes, if any row fails. **The rule when a floor fails is to change the colour, never the
  floor** — and a changed slot means a new row in `token-tables.md` and a re-run of E07's own
  contrast test, in this commit.

## Why it is built this way

**E07 asserted the declaration; this asserts the composition.** E07/T03 already proves every one of
the thirteen slots clears its floor against `surface` and `surfaceSunk` in all three themes, from
the token table. That is necessary and it is not the whole product: `accessibility-as-code` rule 7
says contrast is measured against *what the pixel actually composites to*, and half the pairs in
this app do not exist until a screen builds them — a label on the harbour field of a primary action,
the citation on a `surfaceSunk` block, the disclaimer on its sunk ground, the stale bar's text on the
bar's own ground, and white ink on the reversed sunlight stamp. None of those appear in the token
table, because none of them is a slot-against-surface pair. This task enumerates them from the
screens and asserts each one.

**Values, not pixels — but values read from the tree.** The doctrine is `wcag(theme.onSurface,
theme.surface)` in pure Dart, because `meetsGuideline(textContrastGuideline)` screenshots the layer
and attributes foreground and background by a naive light/dark histogram: white text on `#FAFAFA`
**passes** it, which is an open defect. This task keeps the pure-Dart ratio and changes only where
the two inputs come from: the declared colour of the rendered span and the declared colour of the box
it sits in. Nothing samples a pixel, so nothing can false-pass on a low-variance region. The
guideline itself stays as an advisory tripwire across the six core surfaces in all three themes, and
its name says advisory.

**7:1 is a floor on a theme, not a floor on a widget.** `SPEC.md` §13's parenthesis — *≥ 7:1 in
sunlight mode* — is the entire reason sunlight is hand-authored. At roughly 100,000 lux through a
salt-hazed screen the *middle* of the tonal range disappears first, so sunlight does not raise
ratios, it **deletes tonal steps**: six neutral slots collapse to `black00`, `surfaceSunk` collapses
into `surface`, and `accent` gives up `harbour`. Two assertions follow, and only the second is
interesting: every sunlight text pair clears 7:1, **and** no rendered text on any core surface
resolves to a value that is neither black, white, nor one of the three verdict pigments. A derived
third theme would pass the first and fail the second, which is exactly the failure
`three-themes-and-modes.md` runs the arithmetic on.

**`onSurfaceFaint` may never carry a fact, and that is a screen-level rule.** It measures 3.62:1 on
paper — legal for ornament at 19 sp and above, and never for a measurement, a citation or a date. No
token test can catch a violation, because the token is fine; only a sweep of what the screens
actually render can. So the sweep resolves the colour of every fact-bearing label on the core
surfaces and fails if one of them is `onSurfaceFaint`.

**The disabled label is deliberately not asserted, and the reason prose is.** `lonja-buttons`'s
disabled row puts the label in `onSurfaceFaint` on a `surfaceSunk` field — 3.32:1 by the paper
table, below the body floor. WCAG 1.4.3's incidental clause exempts text that is part of an inactive
user-interface component, so asserting 4.5:1 on it would be inventing a stricter standard than the
one §13 names. What is **not** incidental is rule 9's adjacent prose — *"Select a zone first — rules
differ by zone."* — because it carries the fact the user needs in order to act. That is `ink-muted`
at 7.29:1 and it is asserted. Stating this split explicitly is the point: a reviewer who sees no
disabled-label row should find the reason here rather than assume an oversight.

**The ruler is asserted through its painter's snapshot.** `textContrastGuideline` only sees text
findable through `find.text`, so every numeral E09's `CustomPainter` draws is invisible to it —
and the ruler is the screen a fisher reads in direct sun with a fish in his other hand.
`lonja-design-tokens` rule 12 guarantees the painter takes a `LonjaTokens` snapshot in its
constructor, so the test reads that snapshot and asserts the slot the numerals are drawn in clears
4.5:1 against the surface they are drawn on.

**Rejected — `CustomMinimumContrastGuideline(finder:, minimumRatio: 7.0)` for the sunlight lane.** It
is public and it scopes contrast to a subset, which reads like exactly the right tool. It samples
pixels and carries the same mis-attribution defect as the guideline it is built on, so it would
report a sunlight pass on precisely the low-variance white-on-white regions sunlight consists of.

**Rejected — a grayscale wrapper around the WCAG inputs as a second channel.**
`computeLuminance()` is chroma-blind, so any correct grey of a colour preserves its luminance
exactly and `contrastRatio(gray(a), gray(b))` equals `contrastRatio(a, b)` for all pairs. The
wrapper would prove nothing beyond the ratio already asserted. The real concern grayscale gestures
at — a state distinguished only by chroma — is caught by asserting the luminance ratio **between the
two state colours**, and the screen-level version of that argument is T05, which is a
signal-distinguishability test rather than a contrast test.

**Rejected — asserting a slot's figure to two decimal places here.** That is E07's row, from E07's
table, and two copies of a measured number are two numbers that drift. This task asserts floors on
pairs E07 cannot see.

## Tests first

Write every row before changing a colour. Run them. **They must fail** — the helper does not exist,
so nothing compiles. If a composited row passes on the first run after the helper lands, check that
`resolvedGroundOf` is finding the real box: a null ground silently falling back to `surface` makes
every row a duplicate of E07's.

Rows marked ×3 run once per theme and interpolate the theme into the description, with the
cross-cutting `sunlight - ` prefix where the theme is the point.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `contrastRatio returns 21 for black on white` | `#000000`, `#FFFFFF` | 21.0 ± 0.01 | The instrument's self-test. A ratio function with the terms the wrong way round passes every floor and proves nothing |
| 2 | `contrastRatio is symmetric` | any pair, both orders | equal | The second half of the self-test; the formula orders by luminance, and getting that wrong halves every failing ratio into a pass |
| 3 ×3 | `${theme} - the citation line clears 4.5:1 on the ground it is printed on` | result surface | ratio ≥ 4.5 | The citation is the block that has to survive a photograph taken by an inspector; it is set in `onSurfaceMuted` on a sunk block, a pair that exists only on this screen |
| 4 ×3 | `${theme} - the disclaimer lead clause clears 4.5:1 on its sunk ground` | result surface | ratio ≥ 4.5 | *"Reference only — not legal advice."* is the sentence with the legal exposure, printed on `paper-sunk` rather than on `surface` |
| 5 ×3 | `${theme} - the primary action label clears 4.5:1 on its field` | any surface with a primary | ratio ≥ 4.5 | Text on an accent **fill** — the case rule 7 names, and the one the token table does not cover |
| 6 ×3 | `${theme} - the disabled action's reason prose clears 4.5:1` | a disabled action | ratio ≥ 4.5 | The prose carries the precondition the user must act on; the disabled label itself is incidental under WCAG 1.4.3 and is deliberately not asserted |
| 7 ×3 | `${theme} - the stale bar's text clears 4.5:1 on the bar's ground` | expired pack | ratio ≥ 4.5 | The bar states a fact about the data on a chromatic ground; `ochre47` measures 3.97:1, which is why the **word** is `onSurface` and only the mark is ochre |
| 8 | `sunlight - the reversed stamp's ink clears 7:1 on its adverse ground` | sunlight, below-minimum | ratio ≥ 7.0 | The reversal is the only solid coloured field in the build, and it carries the sentence the whole product exists to print |
| 9 | `sunlight - every text pair on the core surfaces clears 7:1` | six surfaces, sunlight | every resolved pair ≥ 7.0 | `SPEC.md` §13's sunlight clause, asserted where the text is rather than where the token is |
| 10 | `sunlight - no rendered text resolves to a grey` | six surfaces, sunlight | every colour is `black00`, `white100` or a verdict pigment | The row a derived third theme fails: raising ratios keeps the mid-greys, and the mid-greys are what vanish at 100,000 lux |
| 11 | `paper - no fact-carrying label resolves to onSurfaceFaint` | six surfaces, paper | no measurement, citation, date or verdict word in `onSurfaceFaint` | 3.62:1. *"Below the minimum — 38 cm"* set in an unreadable grey is a fact the fisher cannot act on, and the fine is his |
| 12 ×3 | `${theme} - a control frame clears 3:1 against its surface` | a bordered control | ratio ≥ 3.0 | WCAG 1.4.11's non-text floor. `hairline` is 1.37:1 and is ornament; a control identified by a hairline is a control nobody finds on a wet screen |
| 13 | `Ruler numerals paint in a slot clearing 4.5:1 against their surface` | the ruler painter's token snapshot | ratio ≥ 4.5 | `textContrastGuideline` cannot see a `CustomPainter` at all, and the ruler is read in direct sun |
| 14 ×18 | `${theme} - ${s.id} ${s.name} meets textContrastGuideline (advisory)` | six core surfaces × three themes | matcher passes | A catastrophic-regression tripwire. It false-passes white on `#FAFAFA` and cannot see the ruler, which is why rows 3–13 exist |

```dart
// app/test/a11y/support/contrast.dart
import 'dart:math' as math;
import 'dart:ui';

/// WCAG 2.x relative-contrast ratio. Ordered by luminance, so the argument
/// order cannot change the answer.
double contrastRatio(Color foreground, Color background) {
  final double a = foreground.computeLuminance();
  final double b = background.computeLuminance();
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}
```

```dart
// app/test/a11y/composited_contrast_test.dart
import 'package:catchlaw/theme/lonja_skin.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/a11y/audited_surfaces.dart';
import '../utils/harness.dart';
import 'support/contrast.dart';

/// The declared colour of a rendered span — a VALUE from the tree, never a
/// sampled pixel, so it cannot false-pass on a low-variance region.
Color resolvedTextColour(WidgetTester tester, Finder text) {
  final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(text);
  return (paragraph.text as TextSpan).style!.color!;
}

/// The declared colour of the nearest painted box behind [text].
Color resolvedGroundOf(WidgetTester tester, Finder text, {required Finder box}) {
  final BoxDecoration decoration =
      tester.widget<DecoratedBox>(box).decoration as BoxDecoration;
  return decoration.color!;
}

void main() {
  for (final LonjaSkin skin in LonjaSkin.values) {
    testWidgets('${skin.name} - the citation line clears 4.5:1 on the ground it is '
        'printed on', (WidgetTester tester) async {
      await pumpResultSurface(tester, A11yAxes(skin: skin));

      final Color ink = resolvedTextColour(tester, find.byKey(const ValueKey('result.citation')));
      final Color ground = resolvedGroundOf(
        tester,
        find.byKey(const ValueKey('result.citation')),
        box: find.byKey(const ValueKey('result.citation.block')),
      );

      expect(contrastRatio(ink, ground), greaterThanOrEqualTo(4.5),
          reason: '${skin.name}: the citation measures '
              '${contrastRatio(ink, ground).toStringAsFixed(2)}:1 — change the '
              'colour, never the floor');
    });

    // … one test per row above, one behaviour each
  }
}
```

```dart
// app/test/a11y/sunlight_palette_test.dart
void main() {
  testWidgets('sunlight - no rendered text resolves to a grey', (WidgetTester tester) async {
    const Set<int> allowed = <int>{
      0xFF000000, // black00 — every sunlight neutral
      0xFFFFFFFF, // white100 — onAccent, and the reversed stamp's ink
      0xFF2E5E3A, // verdant36  verdictPass
      0xFF7A2320, // oxblood28  verdictFail
      0xFF6E5512, // ochre38    verdictWarn
    };

    for (final String id in kCoreLoopSurfaces) {
      final AuditedSurface surface =
          kAuditedSurfaces.firstWhere((AuditedSurface s) => s.id == id);
      await surface.pump(tester, const A11yAxes(skin: LonjaSkin.sunlight));

      for (final RenderParagraph p
          in tester.renderObjectList<RenderParagraph>(find.byType(RichText))) {
        final Color? colour = (p.text as TextSpan).style?.color;
        expect(allowed.contains(colour?.toARGB32()), isTrue,
            reason: '$id renders text in $colour under sunlight — a surviving '
                'mid-grey is absent at 100,000 lux, not dim');
      }
    }
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/a11y/composited_contrast_test.dart test/a11y/sunlight_palette_test.dart`
→ 2 + 21 + 18 failures. Row 7 may fail to *compile* rather than to assert, if the stale bar's ground
is a raw hex rather than a slot — see the epic's Risks item 2, and fix the binding rather than the
test.

## Implementation outline

1. Write `contrast.dart` and rows 1 and 2 first. The instrument is verified before it is trusted.
2. Enumerate the composited pairs by reading the screens, not by guessing: every `DecoratedBox` or
   `ColoredBox` in `app/lib/ui/` that has text inside it is a pair. There are fewer than a dozen.
3. Write the rows. Run. Record failures.
4. For each failure, change the **colour**, never the floor. A slot rebound in `lib/theme/` needs its
   new figure in `token-tables.md` and E07's own contrast test re-run — in this commit, because a
   token whose published row no longer matches its hex is the defect `lonja-design-tokens` rule 2
   calls "a defect, not a nit".
5. If row 7 finds the stale bar bound to a raw hex, that is a `check_lonja_tokens.sh` check 1
   violation that the gate should already have caught outside `lib/theme/`. Fix the binding at
   source; do not add a `// lonja-token-ok`.
6. Row 13 needs the painter's snapshot, which `lonja-design-tokens` rule 12 guarantees is a
   constructor argument. If the painter reads `Theme.of(context)` inside `paint()` instead, that is
   check 8 of the same gate and it is fixed here.
7. Re-run E07's contrast test and the whole `app` suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 14 rows pass (3–7, 12 and 14 generated per theme), and each failed first.
- [ ] Every composited text pair in `app/lib/ui/` is covered by a row; the enumeration is in the test
      file, not in a comment.
- [ ] Every sunlight pair clears **7:1** and no sunlight text resolves to a grey (§13, §4.9).
- [ ] No fact-carrying label anywhere resolves to `onSurfaceFaint`.
- [ ] Nothing samples a pixel; `textContrastGuideline` appears only in rows whose names say
      "advisory".
- [ ] Any slot whose value changed has an updated row in
      `lonja-design-tokens/references/token-tables.md`… **or**, if that file is out of this
      repository's edit scope for this task, the discrepancy is named in the commit body rather than
      left silent.
- [ ] `check_lonja_tokens.sh app/lib` clean, including check 1 — no raw hex outside `app/lib/theme/`.
- [ ] Nothing under `packages/rule_engine/` changed.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh    app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(theme): assert contrast where it composites, and 7:1 in sunlight

E07 proves every slot clears its floor against surface and surfaceSunk from
the token table. Half the pairs this app actually paints are not slot
against surface: a label on the harbour field, the citation on a sunk
block, the disclaimer on its ground, the stale bar's text on the bar, and
white ink on the reversed sunlight stamp. Those are enumerated from the
screens and asserted here.

The ratio stays pure Dart over colour VALUES read from the tree, because
meetsGuideline(textContrastGuideline) histograms a screenshot and passes
white on #FAFAFA — it runs as an advisory tripwire only, and it cannot see
the ruler's painted numerals at all, so those are asserted through the
painter's token snapshot.

Sunlight gets two rows, and the second is the one that matters: every pair
clears 7:1 (SPEC.md §13) AND no rendered text resolves to a grey. A derived
third theme passes the first and fails the second, which is the whole
reason sunlight is hand-authored.

Task: E19/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
