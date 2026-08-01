# E09/T04 — The deliberate LTR exception

| | |
|---|---|
| **Epic** | E09 — Ruler and calibration |
| **Branch** | `epic/09-ruler` (shared) |
| **Commit** | `feat(ruler): pin the scale to LTR in every locale and localise only its numerals` |
| **Depends on** | T03 (`RulerScene` and `RulerPainter` must exist for the View to feed) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.3 (the ruler does not mirror — a deliberate exception, commented as such), §9.5 (numerals), §4.2 (measurement diagrams) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `i18n-rtl-l10n` | Owns direction and numerals everywhere else in the app; this task is the one documented exception to its mirroring rule, and it must be written the way that skill prescribes |
| `catchlaw-measurement-ruler` | Rules 4 and 5: the pin, the comment, and `labelDirection` as a constructor field taken from the **ambient** direction read before the pin |
| `custom-canvas-and-gestures` | Rule 11 — geometry is direction-agnostic and only chrome mirrors; and why a `Directionality` island beats a flip transform |
| `lonja-typography` | The face and the `FontFeature.tabularFigures()` numeric style the tick labels are set in, and the Arabic role stack |
| `widget-golden-and-a11y-testing` | The RTL golden lane: real fonts via `loadAppFonts`, `@Tags(['golden'])`, and why an Ahem lane cannot prove a numeral block |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.3 | The exception in the authoritative words, including "commented as such in the code" and "Measurement diagrams likewise do not mirror" |
| `SPEC.md` | §9.3 "Numerals — corrected twice" | Plain `ar` renders Western digits per CLDR 48; the only lever is the `numberFormatSymbols` map, swapped at bootstrap from `user_profile.numeral_system` |
| `FLUTTER_GUIDE.md` | §9.2 "Forcing the ruler LTR" | The exact mechanism, and why `Directionality` rather than a `Transform`: zero effect on hit-test coordinates, and no mirrored glyphs |
| `FLUTTER_GUIDE.md` | §9.1 | `intl` has no numbering-system API; `-u-nu-` is accepted and discarded; `ZERO_DIGIT` *is* the numbering system |
| `.claude/skills/catchlaw-measurement-ruler/references/ruler-and-calibration.md` | "The RTL exception" | The five-row element/direction table: geometry ltr, zero at the same edge, labels ambient, numerals localised, chrome ambient |
| `.claude/skills/catchlaw-measurement-ruler/references/measurement-methods.md` | "What each method's diagram must draw" | The diagrams are plates with a directional arrow at a real anatomical point; they never mirror either |
| `.claude/skills/i18n-rtl-l10n/references/rtl-and-bidi.md` | "CustomPainter — do NOT auto-mirror", "A fixed expression must not flip" | Pin only that subtree; map pointers through the painter's transform; never invert `dx` for RTL |
| `.claude/skills/i18n-rtl-l10n/references/numerals-and-calendars.md` | "The four digit systems", "Format — pin the numbering system" | `ar` is U+0660–0669 and Persian U+06F0–06F9 are a different block; assert the emitted block in a test |
| `.claude/skills/catchlaw-measurement-ruler/examples/ruler_painter.dart` | `RulerView` | The ambient direction is read **before** the pin and handed in as a plain field |
| `epics/DECISIONS.md` | D-3 | Six locales, `ar` is the only RTL lane; there is no `ur` |

## What this delivers

- `app/lib/ui/ruler/widgets/ltr_instrument.dart` — `LtrInstrument`, a `StatelessWidget` that wraps
  its child in `Directionality(textDirection: TextDirection.ltr)` and carries the exception comment
  `SPEC.md` §9.3 demands, in one place, with the reason. Both the ruler (this task) and the
  calibration surface (T02) route through it, so the exception exists once and is reviewed once.
- `app/lib/ui/ruler/widgets/ruler_view.dart` — `RulerView`: reads `Directionality.of(context)` and
  the locale's `NumberFormat` **above** the pin, builds the tick label strings, computes the physical
  hairline from `MediaQuery.devicePixelRatioOf(context)`, snapshots `LonjaTokens`, assembles the
  `RulerScene`, and hands it to `RepaintBoundary` → `ExcludeSemantics` → `CustomPaint`, with a
  sibling `Semantics` node speaking the reading.
- `app/lib/ui/ruler/widgets/measurement_diagram.dart` — `MeasurementDiagram`, which renders the rule
  row's `measurement_method.diagram_asset` SVG inside the same `LtrInstrument`, so a fork-length
  arrow points at the actual fork in `ar`.
- ARB keys in all six locales: `rulerSemanticLabel` (ICU, `{lengthMm}` and `{method}` placeholders),
  `rulerZeroLabel`.
- Tests: `app/test/ui/ruler/ruler_view_direction_test.dart`,
  `app/test/ui/ruler/ruler_view_numerals_test.dart`, and the golden
  `app/test/ui/ruler/goldens/ruler_ar.png` with its `@Tags(['golden'])` test file.

## Why it is built this way

**The exception, stated once.** Everything else in this app mirrors: `EdgeInsetsDirectional`,
`AlignmentDirectional`, `Icons.adaptive`, and a grep gate (D-8) that rejects a physical `left`. The
ruler does not, because it is not a layout — it is an instrument. A physical measuring scale runs
from a physical edge; mirroring it puts zero at the tail of a real fish while the fisher's hand is at
the snout, and the Arabic build then reads every fish backwards. `SPEC.md` §9.3 requires the code to
say so, so the comment lives on `LtrInstrument` where a reviewer meets it once instead of
rediscovering it at three call sites.

**`Directionality`, not a transform.** `FLUTTER_GUIDE.md` §9.2 is unambiguous: a `Directionality`
island changes layout semantics for the subtree with **zero** effect on hit-testing coordinates,
whereas a flip matrix mirrors pixels but leaves hit geometry transformed and renders tick labels as
unreadable mirrored glyphs. *Rejected:* `Transform(transform: Matrix4.rotationY(pi))`, which appears
in **zero** places in the framework source and would also fail check 4 of `check_measurement.sh`.
*Also rejected:* mirroring inside `paint()` with `canvas.scale(-1, 1)`. That is the correct technique
if a band ever genuinely has to flip — and it is documented in the skill for that case — but here
nothing flips, so introducing the machinery would only invite someone to use it.

**The labels are text and they localise.** The scale does not mirror; its labels are read by a human
and follow the ambient direction and the ambient numeral system. `Directionality.of(context)` is read
**before** the pin, because after it the answer is always `ltr` and every Arabic label would keep
Latin shaping. The painter cannot read it at all — it has no `BuildContext` — so it arrives as
`RulerScene.labelDirection` and is compared in `shouldRepaint` (T03 row 3).

**Numerals come from `intl`, and the default for `ar` is Western.** This surprises everyone and it is
correct: CLDR 48 gives `ar` `defaultNumberingSystem: "latn"`, `intl` has no numbering-system API, and
`ar-u-nu-arab` is accepted as a string and silently discarded. The only lever is the mutable
`numberFormatSymbols` map, swapped in `main()` from `user_profile.numeral_system` — E06 owns that
wiring. This task consumes it: the View formats each label with the app's `NumberFormat` and the test
asserts the emitted **digit block**, so if the lever is ever disconnected the test fails instead of
the ruler quietly rendering the wrong digits. Because that map is process-wide and order-dependent,
the numeral test resets it in `tearDown` — `FLUTTER_GUIDE.md` §9.1 warns it will otherwise silently
corrupt every other test in the isolate.

**The diagrams do not mirror either, and that is a legal point.** `SPEC.md` §9.3 puts it in the same
paragraph: a fork-length arrow must point at the actual fork. A mirrored plate would show the caret
at the snout while the caption says fork length, and the reading taken from it would be wrong by the
whole caudal fork — on *Scomberomorus commerson* that is about 9% of the fish
(`measurement-methods.md`: TL ≈ 1.09 × FL). The same `LtrInstrument` wraps the plate.

## Tests first

Write every row before touching `ruler_view.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `RulerView pins its subtree to TextDirection.ltr` | pump under `Directionality.rtl` | `Directionality.of` inside the ruler is `ltr` | The mechanism itself; everything else in this task is downstream of it |
| 2 | `ar - RulerView places zero at the same physical edge as en` | pump in `ar`, then `en` | the zero tick's `getRect().left` is equal within 0.5 px | The headline requirement of `SPEC.md` §9.3 stated as a measurement |
| 3 | `ar - RulerView places the maximum tick at the same physical edge as en` | same | the last tick's `getRect().right` is equal | Row 2 alone passes if the whole ruler is empty; this pins the other end |
| 4 | `RulerView passes the ambient direction to the scene, not the pinned one` | pump under rtl | `scene.labelDirection` is `rtl` | The subtle failure: read the direction after the pin and every Arabic label keeps Latin shaping |
| 5 | `ar - RulerView emits Arabic-Indic tick numerals when the numeral system is arab` | `numberFormatSymbols['ar']` swapped, locale `ar` | every label's runes are in U+0660–0669 | Asserts the digit *block*, so a silent Latin fallback fails a test instead of shipping |
| 6 | `ar - RulerView emits Western tick numerals by default` | locale `ar`, no swap | labels are ASCII digits | CLDR 48 says plain `ar` is `latn`, and that is the correct default for Khalid in RAK |
| 7 | `RulerView emits Western tick numerals in gl` | locale `gl` | ASCII digits | The other five locales must not be collateral damage of the `ar` lever |
| 8 | `RulerView computes the hairline as one physical pixel` | DPR 3.0 | `scene.hairlinePx` is `1 / 3` | A `Border.all()` default is 1 logical px ≈ 3 physical px — a table border, not an instrument mark |
| 9 | `RulerView exposes the reading as a labelled live region` | length 450 mm, method TL | `isSemantics(label: contains('450'), liveRegion: true)` | A canvas says nothing to TalkBack; `accessibility-as-code` rule 1 and the §4.9 live-region requirement |
| 10 | `RulerView excludes the painted surface from semantics` | default | the `CustomPaint` subtree contributes no node | Otherwise the reading is announced twice, once meaninglessly |
| 11 | `MeasurementDiagram pins its plate to TextDirection.ltr` | pump under rtl | `ltr` inside | `SPEC.md` §9.3's second sentence: a fork arrow must point at the fork |
| 12 | `LtrInstrument carries the SPEC 9.3 exception comment` | read the source file in the test | the file contains the marker `catchlaw: a physical scale never mirrors` | The spec requires the comment; a test is the only thing that keeps a comment alive through a refactor |
| 13 | `ar - RulerView golden matches the recorded scale` | `loadAppFonts`, locale `ar`, `@Tags(['golden'])` | matches `goldens/ruler_ar.png` | Geometry tests cannot see glyph shaping or which digit block rendered; this lane can |

```dart
// app/test/ui/ruler/ruler_view_direction_test.dart
import 'package:catchlaw/ui/ruler/widgets/ruler_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  testWidgets('RulerView pins its subtree to TextDirection.ltr',
      (tester) async {
    tester.useDevice(Device.mediumLandscape);
    await tester.pumpRuler(locale: const Locale('ar')); // ambient rtl
    final inner = tester.element(find.byKey(const ValueKey('ruler_canvas')));
    expect(Directionality.of(inner), TextDirection.ltr);
  });

  testWidgets('ar - RulerView places zero at the same physical edge as en',
      (tester) async {
    tester.useDevice(Device.mediumLandscape);
    await tester.pumpRuler(locale: const Locale('en'));
    final ltrZero = tester.getRect(find.byKey(const ValueKey('tick_0')));
    await tester.pumpRuler(locale: const Locale('ar'));
    final rtlZero = tester.getRect(find.byKey(const ValueKey('tick_0')));

    expect(rtlZero.left, moreOrLessEquals(ltrZero.left, epsilon: 0.5));
  });
}
```

```dart
// app/test/ui/ruler/ruler_view_numerals_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/number_symbols_data.dart';

import '../../support/harness.dart';

void main() {
  // numberFormatSymbols is process-wide and order-dependent (FLUTTER_GUIDE 9.1):
  // leaving it swapped corrupts every later test sharing this isolate.
  final original = numberFormatSymbols['ar'];
  tearDown(() => numberFormatSymbols['ar'] = original!);

  testWidgets('ar - RulerView emits Arabic-Indic tick numerals when the '
      'numeral system is arab', (tester) async {
    numberFormatSymbols['ar'] = numberFormatSymbols['ar_EG']!;
    tester.useDevice(Device.mediumLandscape);
    await tester.pumpRuler(locale: const Locale('ar'));

    final label = tester.widget<Text>(find.byKey(const ValueKey('tick_label_1')));
    for (final rune in label.data!.runes) {
      expect(rune, inInclusiveRange(0x0660, 0x0669),
          reason: 'rune U+${rune.toRadixString(16)} is not Arabic-Indic');
    }
  });

  testWidgets('ar - RulerView emits Western tick numerals by default',
      (tester) async {
    tester.useDevice(Device.mediumLandscape);
    await tester.pumpRuler(locale: const Locale('ar'));
    final label = tester.widget<Text>(find.byKey(const ValueKey('tick_label_1')));
    expect(label.data, '1');
  });
}
```

**Run:** `cd app && flutter test test/ui/ruler` → 13 failures. If row 6 passes before the View exists,
the test is wrong. Note rows 5 and 6 must fail for *different* reasons; if they both fail identically,
the harness is not applying the locale.

## Implementation outline

1. `ltr_instrument.dart`: a nine-line `StatelessWidget`. The comment above the `textDirection`
   argument names `SPEC.md` §9.3, states the reason (zero at the snout, not the tail), and contains
   the literal marker string row 12 greps for.
2. `ruler_view.dart`: read `Directionality.of(context)`, `Localizations.localeOf(context)`,
   `MediaQuery.devicePixelRatioOf(context)` and `LonjaTokens.of(context)` — all four **before**
   returning the `LtrInstrument`. Build the label list with the app's `NumberFormat` inside a
   `LayoutBuilder`, so a resize is simply a new Scene.
3. Key each tick and each label (`tick_0`, `tick_label_1`, …) so the geometry tests use
   `find.byKey` rather than `find.byType` — the latter couples the suite to the class hierarchy.
4. Wrap: `RepaintBoundary(child: Semantics(liveRegion: true, label: …, child: ExcludeSemantics(child:
   CustomPaint(...))))`. `isComplex: true`, `willChange` only while a drag is live.
5. `measurement_diagram.dart`: `SvgPicture.asset` inside the same `LtrInstrument`. **Never**
   `SvgPicture.network` — it is grep-banned by `SPEC.md` §14 and by check 1 of
   `check_app_invariants.sh`.
6. Golden: `@Tags(['golden']) library;` at the top of the file, `setUpAll(loadAppFonts)`, one `ar`
   case. Generate on Linux CI only (`FLUTTER_GUIDE.md` §6.3).
7. Re-run the whole suite, including T02's and T03's.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 13 tests pass, and each failed first.
- [ ] `Directionality(textDirection: TextDirection.ltr)` appears in exactly one file in `app/lib`,
      with the `SPEC.md` §9.3 comment on it.
- [ ] T02's calibration surface has been re-pointed at `LtrInstrument`, and its RTL row still passes.
- [ ] No `Matrix4`, no `canvas.scale(-1`, no `Transform` appears anywhere in `app/lib/ui/ruler/`.
- [ ] The numeral test restores `numberFormatSymbols` in `tearDown`, and the full suite passes when
      run in a single isolate (`flutter test --concurrency=1`) as well as in parallel.
- [ ] All six ARB files gained `rulerSemanticLabel` and `rulerZeroLabel` with identical placeholders.
- [ ] The `ar` golden is byte-stable across two consecutive runs on the same host.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
cd app && flutter test --concurrency=1 test/ui/ruler
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
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
feat(ruler): pin the scale to LTR in every locale and localise only its numerals

A physical measuring scale runs from a physical edge. Mirroring it in Arabic
puts zero at the tail of a real fish while the fisher's hand is at the snout,
so the ruler subtree is pinned TextDirection.ltr and the exception is
commented where SPEC 9.3 requires it — in one widget, so a reviewer meets it
once rather than rediscovering it at three call sites. Measurement diagrams
take the same pin: a fork-length arrow that mirrors points at the snout, and
the reading is then wrong by the whole caudal fork.

Directionality rather than a flip transform, because it changes layout
semantics with zero effect on hit-test coordinates; Matrix4.rotationY appears
in zero places in the framework source. The labels are text, so they keep the
ambient direction, read before the pin, and their digits come from intl —
plain ar is Western per CLDR 48, and the Arabic-Indic lever is the
numberFormatSymbols swap, asserted here by digit block.

Task: E09/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
