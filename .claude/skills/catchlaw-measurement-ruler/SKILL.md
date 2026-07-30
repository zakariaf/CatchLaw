---
name: catchlaw-measurement-ruler
description: >-
  Governs measurement as a legal act: the method system TL, FL, SL, CW carapace width, SHL shell
  length and ML carried on the (species, jurisdiction) rule row not the species, every
  length stored as an INTEGER of millimetres in length_mm, conversion display-only, every figure
  rendered beside its method so a bare 38 cm is a defect, calibration against the ISO/IEC 7810 ID-1
  card at 85.60 x 53.98 mm saved as pxPerMm, a plausibility band rejecting an implausible
  scale, step-and-mark with a running total and a restoring cancel, manual
  millimetre entry working before any calibration exists, and a RulerPainter taking textDirection
  as a parameter and never mirroring. Use when building RulerPainter or CalibrationSheet, storing a
  length in millimetres, formatting a reading, wiring step-and-mark segments, wrapping a ruler in
  Directionality, passing textDirection into a CustomPainter, or reviewing measurement_method.dart
  in a diff.
---

# Catchlaw Measurement Ruler

A measurement is a legal act, not a number: 38 cm decides nothing until it also says total length,
and a length that survives as a double or a localised string has already lost the case. This skill
owns the method system, millimetre storage, ID-1 calibration, step-and-mark, manual entry and the
ruler's refusal to mirror. It owns neither the painter architecture nor directional layout.

Read the reference for the task at hand:
- `references/measurement-methods.md` — method table, per-jurisdiction rows, mm storage, rounding,
  display formatting, method mismatch, edge cases.
- `references/ruler-and-calibration.md` — id-1 card, px-per-mm maths, plausibility band, step-and-
  mark state machine, manual entry, accuracy budget, device matrix.

Run `scripts/check_measurement.sh` before a PR.

The View/Painter/Scene split, `shouldRepaint` and zero-allocation `paint()` belong to
`custom-canvas-and-gestures`; directional geometry, numeral systems and ICU formatting to
`i18n-rtl-l10n`; the canonical-unit principle to `value-objects-money-and-units`; the numeric keypad
and focus order to `lonja-forms-and-controls`; comparing a reading to a rule to
`catchlaw-rule-engine`.

## Non-negotiable rules

1. **Every length is an INTEGER of millimetres, everywhere.** `int lengthMm` in the domain, `INTEGER`
   in drift, `450` for Hamour and `38` for Ameixa babosa — never `double`, never `'45,0 cm'`, never
   `'٤٥ سم'`. **WHY:** a double accumulates 44.99999 and rounds under the 45 cm limit on one device
   and over it on another, and a localised string is unsortable, uncomparable and wrong on relocale.

2. **The method belongs to the RULE ROW, not to the species.** `rules.measurement_method` is a column
   resolved with the rule; `Species` carries no method field. Kanaad is 650 mm FL under Ministerial
   Decision 580/2015 Art. 3 and total length elsewhere. **WHY:** one method hung on the fish makes
   the app silently wrong in five of the six jurisdictions it ships to.

3. **No figure is ever rendered without its method.** Every surface prints through
   `formatMeasurement(Measurement)` — "45 cm total length (TL)", "38 mm shell length (SHL)". A bare
   `'$lengthMm mm'` is a defect, not a shortcut. **WHY:** an unlabelled 65 cm is read as total length
   by a fisher whose rule means fork length, and he lands a fish six centimetres short.

4. **THE RULER DOES NOT MIRROR IN RTL.** Wrap the ruler subtree in
   `Directionality(textDirection: TextDirection.ltr)` with the comment saying why; only its labels
   localise their numerals. **WHY:** a physical scale runs from a physical edge — mirroring puts zero
   at the tail instead of the snout, and the Arabic build reads every fish backwards.

5. **A CustomPainter cannot read Directionality — it is PASSED IN.** `RulerPainter` has no
   `BuildContext`, so `labelDirection` is a constructor field taken from `Directionality.of(context)`
   in the widget above, and it is compared in `shouldRepaint`. **WHY:** omit it from `shouldRepaint`
   and Arabic labels keep Latin shaping until some unrelated rebuild happens to clear them.

6. **Mirroring inside paint() is canvas.scale(-1, 1), and text comes AFTER restore().** The SDK's own
   pattern in `decoration_image.dart` and `progress_indicator.dart`; `Matrix4.rotationY(pi)` appears
   in ZERO places in the framework source. **WHY:** a Y-rotation is a 3-D transform on a 2-D canvas,
   and any glyph drawn inside the mirrored frame ships to a fisher backwards.

7. **Calibration is against the ISO/IEC 7810 ID-1 card and nothing else.** 85.60 x 53.98 mm —
   `kId1WidthMm = 85.60` — because it is the one ruler in every wallet on every quay. No coin table,
   no device-model lookup, no `devicePixelRatio` arithmetic. **WHY:** physical DPI is not knowable
   from Flutter, and a model table is wrong the week a new handset ships.

8. **An implausible scale is REJECTED, never stored.** Accept only `4.50 <= pxPerMm <= 9.00` around
   the nominal 6.299; outside the band return `CalibrationImplausible(measured:)` and leave the
   previous `RulerCalibration` untouched. **WHY:** a mis-dragged handle saves a 40% error that is
   invisible forever after, and every reading taken with it is confidently, quietly wrong.

9. **Manual millimetre entry works BEFORE any calibration exists.** The keypad path is live on a
   virgin install with `calibration == null`; only the ruler tab is disabled, never the measure step
   itself. **WHY:** gating the core loop on a plastic card he left ashore turns a five-second answer
   into no answer at all, at 05:40, with no signal.

10. **Step-and-mark totals in millimetres and cancel RESTORES.** `MeasurementDraft.segmentsMm`
    accumulates, `totalMm` shows a running sum, and `cancel()` returns `committedMm` — never zero,
    never null. **WHY:** wet hands hit cancel by accident, and a cancel that wipes 380 mm of careful
    marking costs him the whole measurement he cannot retake once the fish is in the bin.

11. **Rounding happens exactly ONCE, at capture.** `(px / pxPerMm).round()` produces the stored
    `lengthMm`; `cm()` and every locale formatter are display-only and their output NEVER travels
    back into a field, a query or a comparison. **WHY:** 449 mm shown as "45 cm" and re-parsed as 450
    manufactures a pass at the exact millimetre that costs AED 3,000 and six months of licence.

12. **Accuracy is MEASURED on real devices, never asserted.** Budget: median absolute error at or
    below 1.5 mm over a 150 mm reference, and no device in the matrix worse than 3.0 mm; results
    recorded in `references/ruler-and-calibration.md` with device, OS and date. **WHY:** an accuracy
    claim nobody measured is a legal exposure with a number attached to it.

## Millimetres, integers, and one rounding

The domain holds one integer and one method. Centimetres exist only in a string a human reads, and
that string is a leaf: nothing downstream ever parses it back.

```dart
// WRONG — a double length plus a rendered string; 44.96 prints "45 cm" and fails at 450 mm.
class Reading { final double lengthCm; final String display; } // '٤٥٫٠ سم' — unsortable

// RIGHT — one integer, one method, rounded exactly once at the point of capture.
final class Measurement {
  const Measurement({required this.lengthMm, required this.method});
  final int lengthMm;              // 450 Hamour · 650 Kanaad · 38 Ameixa babosa
  final MeasurementMethod method;  // tl · fl · sl · cw · shl · ml — never inferred, never defaulted
  static Measurement fromPixels(double px, double pxPerMm, MeasurementMethod m) =>
      Measurement(lengthMm: (px / pxPerMm).round(), method: m); // the ONE rounding
}
// Display-only. The output is a leaf: it is never parsed, compared or stored.
String cm(int mm) => (mm / 10).toStringAsFixed(1); // 450 -> '45.0'; 38 mm SHL stays millimetres
```

Full worked file: `examples/ruler_painter.dart`.

## The method rides on the rule row

The same fish is measured differently in two countries, so the method cannot live on the fish. It is
a column of the rule, travels with the citation, and is compared before any number is.

```dart
// WRONG — method hung on the species; Kanaad is FL in Ras Al Khaimah and TL in other instruments.
class Species { final MeasurementMethod method; } // one fish, one method — legally false

// RIGHT — the method is a property of the (species, jurisdiction) rule row.
typedef SizeRule = ({
  String speciesId, String jurisdiction, int minLengthMm,
  MeasurementMethod method, Citation citation, // method travels WITH the citation
});
const kanaadRak = (speciesId: 'scomberomorus-commerson', jurisdiction: 'AE-RK',
    minLengthMm: 650, method: MeasurementMethod.fl, citation: md580Art3); // checked 2026-07-14

// The reading must have been taken by the SAME method before a comparison is legal.
if (reading.method != rule.method) return const MethodMismatch(); // never convert, never guess
```

Full worked file: `examples/ruler_painter.dart`.

## Calibration against the ID-1 card

One card, one measured ratio, one plausibility gate. A calibration that fails the gate is not saved
at all — the previous value, or none, is strictly better than a confident wrong scale.

```dart
const kId1WidthMm = 85.60, kId1HeightMm = 53.98;   // ISO/IEC 7810 ID-1, the wallet ruler
const kNominalPxPerMm = 6.299;                     // 160 dp per inch / 25.4
const kMinPxPerMm = 4.50, kMaxPxPerMm = 9.00;      // measured band, whole device matrix

// WRONG — physical DPI is not knowable from Flutter; this "calibration" is a guess with decimals.
// final pxPerMm = MediaQuery.devicePixelRatioOf(context) * 160 / 25.4;
// RIGHT — measured against the card, then judged BEFORE it is allowed to exist.
CalibrationOutcome calibrate(double cardWidthPx, Clock clock) {
  final pxPerMm = cardWidthPx / kId1WidthMm;
  if (pxPerMm < kMinPxPerMm || pxPerMm > kMaxPxPerMm) {
    return CalibrationImplausible(measured: pxPerMm); // previous calibration SURVIVES untouched
  }
  return CalibrationAccepted(RulerCalibration(pxPerMm: pxPerMm, capturedOn: clock.now()));
}
// pxPerMm is the only double in this subsystem: it is a scale factor, never a length.
```

Full worked file: `examples/ruler_painter.dart`.

## The ruler does not mirror in RTL

A deliberate, commented exception to the app's RTL rule. The instrument keeps its physical origin;
only the numerals localise. Review it as an exception, not as an oversight.

```dart
// WRONG — the ruler flips with the app and zero lands at the tail in the Arabic build.
return RulerView(scene: scene); // inherits TextDirection.rtl from MaterialApp

// RIGHT — the ruler is an instrument, not a text layout.
return Directionality(
  textDirection: TextDirection.ltr, // catchlaw: a physical scale never mirrors — rule 4
  child: CustomPaint(
    painter: RulerPainter(
      scene: scene,                                  // immutable snapshot, == comparable
      pxPerMm: calibration.pxPerMm,
      // The painter has no BuildContext and cannot read the Directionality above it.
      labelDirection: Directionality.of(context),    // the AMBIENT one — labels still localise
      numerals: l10n.numeralSystem,                  // ٠١٢ in ar · 012 in es, pt, en
    ),
  ),
);
```

Full worked file: `examples/ruler_painter.dart`.

## Mirroring inside paint(), if you ever must

If a tick band genuinely has to flip, use the transform the framework itself uses, and keep every
glyph outside the mirrored frame.

```dart
// WRONG — Matrix4.rotationY(pi) appears in ZERO places in the Flutter framework source.
canvas.transform(Matrix4.rotationY(pi).storage); // a 3-D flip on a 2-D canvas

@override
void paint(Canvas canvas, Size size) {
  if (scene.mirrorTicks) {
    canvas.save();
    canvas.scale(-1, 1);                 // the decoration_image.dart / progress_indicator.dart way
    canvas.translate(-size.width, 0);
  }
  _paintTicks(canvas, size);             // geometry ONLY — no glyphs inside the mirrored frame
  if (scene.mirrorTicks) canvas.restore();
  _paintLabels(canvas, size);            // AFTER restore(), or every digit ships backwards
}
@override
bool shouldRepaint(RulerPainter old) =>
    old.pxPerMm != pxPerMm ||
    old.labelDirection != labelDirection || // omit this and stale glyph shaping survives a relocale
    old.numerals != numerals || old.scene != scene;
```

Full worked file: `examples/ruler_painter.dart`.

## Step-and-mark, and the ground floor beneath it

A 92 cm Kanaad is longer than any phone. Segments accumulate in millimetres, the total is the only
thing ever stored, and cancel restores what he already had.

```dart
final class MeasurementDraft {
  const MeasurementDraft({this.segmentsMm = const [], this.committedMm});
  final List<int> segmentsMm;   // [148, 150, 149, 92] — each a screen-length step
  final int? committedMm;       // the previously saved reading; what cancel restores
  int get totalMm => segmentsMm.fold(0, (a, b) => a + b); // running total, shown live
  // WRONG — cancel() => const MeasurementDraft(); wipes the 539 mm already marked.
  MeasurementDraft cancel() =>
      MeasurementDraft(segmentsMm: const [], committedMm: committedMm); // RIGHT — restores
}
// The keypad path is never gated on hardware he may not be carrying.
final canUseRuler = calibration != null;  // only the RULER tab is disabled
const canEnterManually = true;            // ALWAYS — virgin install, no card, wet hands, 05:40
```

Full worked file: `examples/ruler_painter.dart`.

## Anti-patterns

- **`double lengthCm`** — accumulates 44.99999, rounds under the limit on one device and over it on
  another, and no test catches which.
- **`String lengthDisplay` persisted** — stores `'٤٥٫٠ سم'` in the user DB; unsortable, and wrong the
  first time he switches locale.
- **`Species.measurementMethod`** — makes one fish one method, and ships silently wrong rules in five
  of six jurisdictions.
- **`Text('${m.lengthMm / 10} cm')`** — an unlabelled number: a fork-length reading read as total
  length, six centimetres short.
- **`Directionality.of(context)` inside a `*_painter.dart`** — the painter has no context; the line
  either does not compile or reads a different tree than the one being painted.
- **`Matrix4.rotationY(pi)` in `paint()`** — zero framework precedent, breaks glyphs and hit tests;
  use `canvas.scale(-1, 1)` plus `translate`.
- **`_paintLabels()` called before `canvas.restore()`** — every digit on the ruler comes out
  mirrored, and it looks fine in the LTR screenshot.
- **`shouldRepaint` that omits `labelDirection`** — Arabic numerals keep Latin shaping until some
  unrelated rebuild happens to clear it.
- **`const pxPerMm = 6.3;` or `devicePixelRatioOf(context) * 160 / 25.4`** — logical density is not
  physical DPI; a hardcoded scale is a 40% error on a tablet, saved with a constant's confidence.
- **`if (calibration == null) return const DisabledMeasureStep()`** — gates the core loop on a card
  left ashore and leaves him with no answer at all.
- **`int.parse(cmString) * 10`** — a display string parsed back into storage; rule 11's round trip,
  and the manufactured pass at exactly 450 mm.

## Definition of done

- [ ] `scripts/check_measurement.sh` is clean over `lib/`.
- [ ] Every persisted length is `int` millimetres in the domain and `INTEGER` in drift; no `double`
      or `String` length field exists in `lib/` (rule 1).
- [ ] `measurement_method` is a column on the rule row, `Species` has no method field, and a test
      asserts Kanaad resolves `fl` in `AE-RK` (rule 2).
- [ ] Every measurement string in `lib/` is produced by `formatMeasurement`, and a golden proves
      "45 cm total length (TL)" and "38 mm shell length (SHL)" (rule 3).
- [ ] The ruler subtree is wrapped in `Directionality(textDirection: TextDirection.ltr)` with the
      exception comment, and an `ar` golden shows zero at the same physical edge as `en` (rule 4).
- [ ] `RulerPainter` takes `labelDirection` as a field, reads no `BuildContext`, compares it in
      `shouldRepaint`, and contains no `Matrix4.rotationY` (rules 5, 6).
- [ ] A calibration of 3.1 px/mm and one of 12.0 px/mm both return `CalibrationImplausible` and leave
      the stored `RulerCalibration` unchanged (rule 8).
- [ ] A widget test on a virgin install with `calibration == null` completes a measurement by keypad
      alone, and `MeasurementDraft.cancel()` restores `committedMm` over four segments (rules 9, 10).
- [ ] The device accuracy matrix in `references/ruler-and-calibration.md` is filled in for the
      current release, with no device above 3.0 mm (rule 12).

## Related skills

- See `custom-canvas-and-gestures` for the View/Painter/Scene split, `shouldRepaint` contracts and
  zero-allocation `paint()` — this skill only adds what the ruler's domain demands.
- See `i18n-rtl-l10n` for directional geometry, numeral systems and ICU number formatting; the ruler
  is the documented exception to its mirroring rule, not a counter-example.
- See `value-objects-money-and-units` for the canonical-unit principle that makes millimetres the
  only stored unit.
- See `catchlaw-rule-engine` for `methodMismatch` and how a `Measurement` is compared to a rule row.
- See `catchlaw-verdict-contract` for the statement-of-fact sentence a measurement lands inside.
- See `lonja-forms-and-controls` for the numeric keypad, focus order and glove-mode hit targets used
  by manual entry.
- See `lonja-design-tokens` for the `LonjaTokens` snapshot a painter is handed instead of reading the
  theme itself.
- See `widget-golden-and-a11y-testing` for the RTL golden lane proving the ruler did not mirror, and
  `accessibility-as-code` for semantics and 44px targets on the mark and cancel controls.

## References

- Flutter API — CustomPainter: https://api.flutter.dev/flutter/rendering/CustomPainter-class.html
- Flutter API — Directionality: https://api.flutter.dev/flutter/widgets/Directionality-class.html
- Flutter API — Canvas.scale: https://api.flutter.dev/flutter/dart-ui/Canvas/scale-method.html
- Flutter API — TextPainter: https://api.flutter.dev/flutter/painting/TextPainter-class.html
- Flutter API — MediaQuery.devicePixelRatioOf: https://api.flutter.dev/flutter/widgets/MediaQuery/devicePixelRatioOf.html
- Flutter — internationalization: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
- ISO/IEC 7810:2019 identification cards, physical characteristics: https://www.iso.org/standard/70483.html
- Dart language — records: https://dart.dev/language/records
