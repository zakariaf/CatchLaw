# E19/T03 — Two hundred per cent text on a five-inch screen

| | |
|---|---|
| **Epic** | E19 — Accessibility, sunlight and glove modes |
| **Branch** | `epic/19-accessibility` (shared) |
| **Commit** | `fix(a11y): hold every layout at 200% text on a 320 dp surface` |
| **Depends on** | T01 (the registry and the pinned-device harness); E06/T08 (`flutter_test_config.dart` loads a real font) |
| **Size** | L |
| **Spec** | `SPEC.md` §4.9 "Font scaling" row (*layouts survive 200% text scale; no clipping or overlap at 200% on a 5-inch screen*), §13 (layouts hold at 200% text scale), §6 (every screen) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `widget-golden-and-a11y-testing` | Owns the whole mechanism: rule 5 (never suppress overflow), rule 6 (one `testWidgets` per tuple), rule 7 (assert the fit, not just the absence of overflow), rule 12 (never clamp) |
| `accessibility-as-code` | Rules 4 and 5, and "Text scale: the instinct is the bug" — `FittedBox`, computed `fontSize` and `ellipsis` are the same defect wearing a disguise |
| `adaptive-layout` | Rule 9 — never assume a fixed cell height; a hardcoded `SizedBox(height: 48)` clips at 200%. This is the finding the task exists to produce |
| `lonja-typography` | `references/type-ramp.md`: `height` is a ratio and scales, `letterSpacing` is absolute and does not; the measures are multiplied by the live scale at the use site; glove mode never resizes `legal`, `verdict` or `citation` |
| `lonja-design-tokens` | Rule 7 and the 4 pt spine — a fix is a `LonjaSpace` step, never a literal, and `check_lonja_tokens.sh` check 5 is the grep |
| `testing-strategy` | Rule 11 and the suite-time budget: 176 generated cases is a real cost, and the reduction lever is chosen in advance |
| `catchlaw-conventions-index` | Invariant 3 — the citation is the block that gets pushed off screen first when type grows, and an uncited verdict is an opinion |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.9 "Font scaling" row | The requirement and its done condition, including the surface it names: a five-inch screen |
| `SPEC.md` | §13 accessibility row | "layouts hold at 200% text scale" |
| `.claude/skills/widget-golden-and-a11y-testing/references/overflow-and-textscale.md` | whole | The two overflow classes, the three traps, the matrix, the fit assertion, the four wrong fixes and the legitimate resolutions |
| `.claude/skills/widget-golden-and-a11y-testing/references/harness-and-mediaquery.md` | "Device presets", "The four load-bearing lines", "Driving MediaQuery flags" | Logical size × DPR, `addTearDown(view.reset)`, `MediaQuery` above `MaterialApp` from `copyWith`, and what each flag is worth |
| `.claude/skills/widget-golden-and-a11y-testing/examples/overflow_matrix_test.dart` | whole | The worked matrix shape — loop *around* `testWidgets`, never inside it |
| `.claude/skills/accessibility-as-code/SKILL.md` | "Text scale: the instinct is the bug" | Why auto-shrinking is the identical bug in disguise, and what to build instead |
| `.claude/skills/lonja-typography/references/type-ramp.md` | "Measures", "Per-theme response", "Line breaking" | `LonjaMeasure` × live scale; glove never resizes legal prose; Flutter has no `text-wrap: balance`; never hyphenate |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "The density set" | `rowHeight` 56/72 — the value this task converts from a height into a floor |
| `FLUTTER_GUIDE.md` | §6.4 | The test budget, and why the real-font load matters before the bold axis means anything |
| `epics/DECISIONS.md` | D-8 | Directional geometry is a grep gate; a layout fix must not reach for `EdgeInsets.only(left:` |

## What this delivers

- `app/test/a11y/text_scale_matrix_test.dart` — 176 generated `testWidgets`, one per
  (surface, device, scale, bold, density) tuple, each asserting `tester.takeException()` is null.
- `app/test/a11y/text_scale_fit_test.dart` — the fit, wrap, scroll and anti-clamp rows: the silent
  class the overflow net cannot see.
- `app/test/a11y/support/fit_metrics.dart` — `linesOf(tester, finder)` over
  `RenderParagraph.computeLineMetrics()`, and `expectFitsCell(...)`.
- Layout fixes inside `app/lib/ui/` — principally the conversion of fixed row and control heights
  into **minimum** heights. The full set is not knowable before the matrix runs; the known first
  failure is named below.

## Why it is built this way

**A five-inch screen is two surfaces here, and both run.** `SPEC.md` §4.9 says *"no clipping or
overlap at 200% on a 5-inch screen"*. A 5.0-inch 1080p phone reports **360 × 640 logical at DPR
3.0** — the harness's `Device.small`. `Device.compact` is **320 × 640 at DPR 2.0**, narrower than
five inches, and is therefore the conservative floor rather than the literal requirement. The core
loop runs on both; the remaining surfaces run on the narrower one, because a layout that holds at
320 dp holds at 360. `physicalSize` is in physical pixels, so the harness multiplies by DPR — a
`Size(320, 640)` assigned raw at the default DPR 3.0 is a 107 × 213 logical surface, and every test
on it passes for the wrong reason.

**One `testWidgets` per tuple, and the loop is outside it.** `RenderFlex` reports an overflow
**once per `RenderObject`**; the internal flag resets only on `reassemble()`. Loop the scales inside
one test and scales two through five are silently unchecked while the test goes green. This is the
single most expensive mistake available in this task, because the resulting suite looks exactly like
a working one.

**The net already exists; the job is not to lose it.** An overflow routes through
`FlutterError.reportError`, the test binding captures it, and `testWidgets` rethrows at test end.
So there is no `expect` to add to make overflow fail — only ways to disarm it. No `takeException()`
to swallow, no `FlutterError.onError` assignment, no copy of the popular `ignoreOverflowErrors`
helper, and above all no `takeException()` in a global `tearDown`, which clears the pending
exception before the binding rethrows and converts every overflow test in the suite into a no-op.
The explicit `expect(tester.takeException(), isNull, reason: …)` in each case exists for the message,
not for the assertion.

**The fit assertion is the real gate.** A clipped `Text` reports nothing, ever —
`RenderParagraph` has no overflow indicator, and a label running past a fixed height inside a
`SizedBox` produces zero errors, a green test and unreadable words on the phone. So the second file
measures: `getSize` of the label against `getRect` of its cell, and `computeLineMetrics().length`
against a line ceiling.

**A fixed row height is where this breaks first, and the fix is a floor.**
`token-tables.md` publishes `rowHeight` 56 standard and 72 glove, and
`lonja-design-tokens`'s own worked example writes `SizedBox(height: t.density.tapMin, child: …)`.
At 200% the label inside needs more than that box and the `SizedBox` clips it, silently.
`adaptive-layout` rule 9 states the rule directly — *never assume a fixed cell height; a hardcoded
`SizedBox(height: 48)` clips at 200% text scale* — and `accessibility-as-code` rule 5 forbids the
tempting repair. **The resolution keeps both properties:** `ConstrainedBox(constraints:
BoxConstraints(minHeight: density.rowHeight))`, so the token still guarantees the tap floor T02
asserts and the row is free to grow. The token value does not change; its meaning becomes a minimum,
which is what a density floor was always for.

**Rejected — `MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3)`.** It is the one-line fix a
future contributor reaches for when this matrix goes red, and it defeats the entire matrix while
contrast and tap targets stay green. `check_lonja_type.sh` check 5 greps for it and for the
deprecated `textScaleFactor`; row 12 below catches the hand-rolled version the grep cannot see.

**Rejected — `FittedBox`, a computed `fontSize`, `maxLines` + `TextOverflow.ellipsis`.** The same
bug in three disguises: the layout stays tidy and the user's OS setting stops working. `FittedBox`
is the worst of them, because it makes the *longest* string the *smallest* — so the most complex
verdict on the screen becomes the least readable one. `check_lonja_type.sh` check 7 already fails
truncation applied to the `legal`, `citation` or `verdict` steps; row 7 asserts the behaviour.

**Rejected — a smaller font on the offending element.** One uniform size is load-bearing on a
document surface: variable line count reads as a paragraph, variable size reads as a broken page.

**The legitimate resolutions, in the order to try them:** shorten the copy in the ARB; let the region
wrap to more lines; make an unbounded region scroll and assert that it scrolls; accept a denser
layout variant and run the matrix against **both** variants, never the roomy one alone.

**The bold axis is inert unless a real font is loaded.** Under the default test font every glyph is a
fixed em-square with no bold variant, so `boldText: true` lays out identically to `false` and half
the matrix proves nothing. E06/T08 already loads a font with Arabic coverage in
`app/test/flutter_test_config.dart`, which is directory-scoped and scanned upward, so `app/test/a11y/`
inherits it. Row 13 asserts the axis is live rather than assuming it.

**Rejected — a golden as the 200% proof.** A golden of clipped text passes forever once blessed, and
reds on any host that rasterises fonts differently. Computed geometry fails with a sentence naming
the label and its measurement. `FLUTTER_GUIDE.md` §6.4 keeps the golden **matrix** small for exactly
this reason; this task adds none.

## Tests first

Write every row before touching a widget. Run them. **They must fail** — and the first failures will
be fixed-height rows, not exotic ones. Row 1 is generated: its description interpolates the surface,
the device, the scale, the bold flag and the density, or `--plain-name` cannot address one failing
case out of 176.

**The matrix, stated as arithmetic:**

| Lane | Surfaces | Devices | Scales | Bold | Density | Cases |
|---|---|---|---|---|---|---|
| A | the 6 core-loop surfaces | `compact_320`, `small_360` | 1.0, 1.3, 1.5, 2.0, 3.0 | false, true | standard | **120** |
| B | the same 6 | `small_360` | 1.0, 2.0 | false | glove | **12** |
| C | the other 22 | `compact_320` | 1.0, 2.0 | false | standard | **44** |
| | | | | | **total** | **176** |

1.3 and 1.5 are in lane A because Android 14+ scales text non-linearly and the mid-range is the
non-obvious part; 3.0 is iOS AX5 territory. `TextScaler.linear` over-approximates a real device
(which scales large text *less*), which is wanted conservatism and must not be described as
device-faithful. If this file becomes the reason somebody stops running the suite
(`testing-strategy` rule 11), **drop the 1.3 and 3.0 rungs from lane A**. Never drop the 2.0 rung: it
is the §13 requirement. Never drop a surface.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 ×176 | `${s.id} ${s.name} overflows nothing at ${device.name} x$scale$bold$density` | the tuple | `tester.takeException()` is null | The matrix. One case per tuple because overflow is reported once per `RenderObject` and a loop inside one test checks only the first |
| 2 | `Species row grows past 56 dp at 200% text` | a species tile, standard, 2.0 | height at 2.0 > height at 1.0 | The fixed-height row, which is where this breaks first. A row that stays exactly 56 dp is clipping, not fitting |
| 3 | `glove - Species row grows past 72 dp at 200% text` | same, glove | height at 2.0 > 72 | Glove raises the floor; it must still be a floor and not a ceiling |
| 4 | `Species row fits its name and its hint at 200% on a 320 dp surface` | a species tile, 2.0 | label size inside cell rect minus the row inset | The silent class: a clipped `Text` reports nothing, so row 1 cannot see this |
| 5 | `ResultVerdictPanel wraps the verdict headline to a second line at 200%` | below-minimum stamp, 2.0 | `linesOf` ≥ 2 and no `TextOverflow.ellipsis` in the subtree | `type-ramp.md` steps the headline 26 → 21 when it wraps; truncating a verdict removes the half carrying the threshold |
| 6 | `Citation footnote stays readable at 200%` | the result surface, 2.0 | the citation is reachable, non-zero, and not ellipsised | `verdict-anatomy.md` warns that enlarging the legal column is how a citation gets pushed off screen — and invariant 3 says an uncited verdict is an opinion |
| 7 | `LonjaDisclaimer is never truncated at 300% text` | the result surface, 3.0 | no ellipsis, no `FittedBox`, text wraps | The one block with legal exposure; `check_lonja_type.sh` check 7 is the grep and this is the behaviour |
| 8 | `Result screen text scale is honoured and never clamped` | 1.0 then 2.0 | scaled height > base × 1.8 | Catches a clamp built by hand, which no grep and no guideline sees: contrast and tap targets both stay green while the text stops growing |
| 9 | `Species search results scroll rather than clip at 200%` | S5 with 40 results, 2.0 | a scrollable exists and its extent exceeds the viewport | The legitimate resolution for genuinely unbounded content — and it must be asserted, or "it scrolls" is a claim rather than a fact |
| 10 | `Check home reflows its zone and currency chips at 200%` | S1, 2.0, 320 dp | both chips are fully within the viewport width | A horizontal chip bar is the classic 200% casualty; §6 S1 puts two of them on one row |
| 11 | `Ruler readout fits the 320 dp surface at 200%` | S3, 2.0 | the `measure` step's label width ≤ viewport width | `measure` is mono 34 — the largest step in the ramp, and the one the fisher is reading while holding a fish |
| 12 | `No layout in app/lib clamps the scaler by hand` | the six core surfaces, 1.0 vs 2.0 | every measured label grows | The behavioural twin of `check_lonja_type.sh` check 5, which only sees the named APIs |
| 13 | `boldText changes the measured width of a label` | one label, bold false then true | widths differ | The instrument's self-test: under the default test font every glyph is a weight-independent em-square, so without a real font 88 of the 176 cases are inert and nobody would know |

```dart
// app/test/a11y/text_scale_matrix_test.dart
import 'package:catchlaw/theme/lonja_density.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/a11y/audited_surfaces.dart';
import '../utils/harness.dart';

typedef _Case = ({
  AuditedSurface surface,
  Device device,
  double scale,
  bool bold,
  LonjaDensity density,
});

Iterable<_Case> _matrix() sync* {
  for (final AuditedSurface s in kAuditedSurfaces) {
    final bool core = kCoreLoopSurfaces.contains(s.id);
    if (core) {
      for (final Device d in <Device>[Device.compact, Device.small]) {
        for (final double scale in const <double>[1.0, 1.3, 1.5, 2.0, 3.0]) {
          for (final bool bold in const <bool>[false, true]) {
            yield (surface: s, device: d, scale: scale, bold: bold,
                density: LonjaDensity.standard);
          }
        }
      }
      for (final double scale in const <double>[1.0, 2.0]) {
        yield (surface: s, device: Device.small, scale: scale, bold: false,
            density: LonjaDensity.glove);
      }
    } else {
      for (final double scale in const <double>[1.0, 2.0]) {
        yield (surface: s, device: Device.compact, scale: scale, bold: false,
            density: LonjaDensity.standard);
      }
    }
  }
}

void main() {
  // Fonts are loaded by app/test/flutter_test_config.dart (E06/T08); without a
  // real proportional font the bold half of this matrix is metrically inert.
  for (final _Case c in _matrix()) {
    final String bold = c.bold ? ' bold' : '';
    final String glove = c.density == LonjaDensity.glove ? ' glove' : '';

    testWidgets(
        '${c.surface.id} ${c.surface.name} overflows nothing at '
        '${c.device.name} x${c.scale}$bold$glove', (WidgetTester tester) async {
      tester.useDevice(c.device);
      await c.surface.pump(
        tester,
        A11yAxes(
          density: c.density,
          textScaler: TextScaler.linear(c.scale),
          boldText: c.bold,
        ),
      );

      // Explicit for a readable message; the binding also rethrows at test end.
      expect(tester.takeException(), isNull,
          reason: '${c.surface.id} overflowed at ${c.device.name} x${c.scale}$bold$glove');
    });
  }
}
```

```dart
// app/test/a11y/support/fit_metrics.dart
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

int linesOf(WidgetTester tester, Finder text) =>
    tester.renderObject<RenderParagraph>(text).computeLineMetrics().length;

/// The silent class: a clipped Text reports nothing, so measure it.
void expectFitsCell(
  WidgetTester tester, {
  required Finder label,
  required Finder cell,
  required double inset,
  required String what,
}) {
  final Rect box = tester.getRect(cell);
  final Size text = tester.getSize(label);
  expect(text.height, lessThanOrEqualTo(box.height - inset * 2),
      reason: '$what needs ${text.height}dp inside a ${box.height}dp cell — '
          'it is being clipped silently');
  expect(text.width, lessThanOrEqualTo(box.width - inset * 2),
      reason: '$what needs ${text.width}dp inside a ${box.width}dp cell');
}
```

```dart
// app/test/a11y/text_scale_fit_test.dart
void main() {
  testWidgets('Species row grows past 56 dp at 200% text', (WidgetTester tester) async {
    tester.useDevice(Device.compact);

    await pumpSpeciesRow(tester, const A11yAxes());
    final double base = tester.getSize(find.byKey(const ValueKey('species.row.0'))).height;

    await pumpSpeciesRow(tester, const A11yAxes(textScaler: TextScaler.linear(2.0)));
    final double scaled = tester.getSize(find.byKey(const ValueKey('species.row.0'))).height;

    expect(base, greaterThanOrEqualTo(56.0));
    expect(scaled, greaterThan(base),
        reason: 'the row is a fixed height, so at 200% the label is clipped, not wrapped');
  });

  testWidgets('Result screen text scale is honoured and never clamped',
      (WidgetTester tester) async {
    tester.useDevice(Device.compact);
    await pumpResultSurface(tester, const A11yAxes());
    final double base = tester.getSize(find.text('Below the minimum')).height;

    await pumpResultSurface(tester, const A11yAxes(textScaler: TextScaler.linear(2.0)));
    final double scaled = tester.getSize(find.text('Below the minimum')).height;

    // 1.8, not 2.0: tolerate line-height rounding, still fail hard on a clamp.
    expect(scaled, greaterThan(base * 1.8),
        reason: 'the headline did not grow at 2.0x — someone clamped TextScaler');
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/a11y/text_scale_matrix_test.dart test/a11y/text_scale_fit_test.dart`
→ 176 + 12 cases, with failures clustered at scale 2.0 and 3.0 on every surface holding a fixed-height
row. If a 3.0 case passes while its 2.0 twin fails, read the test: the two are almost certainly
inside one `testWidgets` and the second `RenderObject` never reported.

## Implementation outline

1. Confirm `app/test/flutter_test_config.dart` loads the real font (E06/T08) and write row 13 first.
   If the bold axis is inert, fix that before generating 176 cases that half prove nothing.
2. Write both test files and `fit_metrics.dart`. Run. The failure list is the work list.
3. Convert fixed heights to floors, component by component:
   `SizedBox(height: density.rowHeight)` → `ConstrainedBox(BoxConstraints(minHeight: density.rowHeight))`.
   The token is unchanged; T02's tap-floor rows must still pass, and they will, because a minimum is
   still a floor.
4. Reflow horizontal rows that cannot fit — the S1 chip bar, any two-across button row — into a
   `Wrap` past the point where they no longer fit, never a `FittedBox`.
5. Make genuinely unbounded regions scroll, and assert the scroll (row 9). A region that scrolls but
   is never asserted to scroll is one refactor from clipping again.
6. Where copy is the problem, shorten it **in the ARB**, in all six locales in the same commit
   (D-3). Never inject a `\n`; `type-ramp.md` bounds headings with `LonjaMeasure.heading` instead.
7. Re-run T02's rows 7 and 8. A row made flexible must still measure ≥ 48 dp at 1.0 — the two floors
   are independent and this task must not trade one for the other.
8. Re-run the whole `app` suite. Height changes move every rect E08–E18 asserted.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 13 rows pass, row 1 generated to exactly 176 cases, and each failed first.
- [ ] No `takeException()` outside the per-case assertion; none in any `tearDown`; no
      `FlutterError.onError` assignment and no `ignoreOverflowErrors` helper anywhere in `app/test/`.
- [ ] No `MediaQuery.withClampedTextScaling`, no `textScaleFactor`, no `FittedBox`, and no
      `TextOverflow.ellipsis` on a `legal`, `citation` or `verdict` step in `app/lib/`
      (`check_lonja_type.sh` checks 5 and 7 clean).
- [ ] Every fixed control or row height in `app/lib/ui/` is a minimum, not an exact height.
- [ ] Every gap added by a fix is a `LonjaSpace` step; no numeric `EdgeInsets` literal
      (`check_lonja_tokens.sh` check 5 clean).
- [ ] No new `EdgeInsets.only(left:` or `right:` — `no_directional_geometry.sh` clean (D-8).
- [ ] Any ARB text shortened was shortened in all six locales in this commit (D-3).
- [ ] The matrix file's wall time is recorded in the commit body, so the next person deciding
      whether to trim it has the number rather than an impression.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-typography/scripts/check_lonja_type.sh               app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
tools/gates/no_directional_geometry.sh                                    app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
fix(a11y): hold every layout at 200% text on a 320 dp surface

176 cases, one testWidgets per (surface, device, scale, bold, density)
tuple, because RenderFlex reports an overflow once per RenderObject and a
loop inside a single test leaves every scale after the first silently
unchecked while the test goes green.

The failures were fixed heights. A SizedBox(height: density.rowHeight)
clips its label at 200% and reports nothing — RenderParagraph has no
overflow indicator — so the height becomes a minimum via ConstrainedBox and
the token keeps its meaning as a tap floor. No FittedBox, no ellipsis, no
withClampedTextScaling: each of those turns a red matrix green and the
product worse, and the second file measures the fit so the silent class
cannot come back.

Task: E19/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
