# E09/T07 — Landscape, and millimetres as the only stored unit

| | |
|---|---|
| **Epic** | E09 — Ruler and calibration |
| **Branch** | `epic/09-ruler` (shared) |
| **Commit** | `feat(ruler): run S3 in landscape and make cm, mm and inch display-only` |
| **Depends on** | T05, T06 (both surfaces must exist before they are laid out and formatted) |
| **Size** | M |
| **Spec** | `SPEC.md` §11 Both (landscape on S3), §9.5 (units and numbers), §4.2 (measurement methods), §7.2 (`user_profile.length_unit`) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `adaptive-layout` | Branch on constraints, never on a device; `MediaQuery.sizeOf` over `.of`; and rule 6, which this task deliberately reads narrowly and says so |
| `value-objects-money-and-units` | Rule 10 — store canonical, convert at the edge; `to<Unit>()` getters return a `double` used only at the presentation edge |
| `catchlaw-measurement-ruler` | Rules 1, 3 and 11 — integer millimetres everywhere, every figure printed with its method, one rounding at capture and never again |
| `i18n-rtl-l10n` | The locale decimal separator, the numeral system, and why the formatter output is a leaf that is never re-parsed |
| `lonja-typography` | Mono tabular figures for every quantity, and the mono face the TL/FL/SHL codes are set in so a column of readings aligns |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §11 "Both" | "Landscape on S3 (a 25 cm fish fits better across a phone held sideways) and S13; portrait elsewhere" |
| `SPEC.md` | §9.5 "Units", "Numbers" | cm default everywhere; inches available and default only for `en` with a US device region; **everything stored as integer millimetres, conversion display-only**; locale decimal separator |
| `SPEC.md` | §7.2 `user_profile.length_unit` | The persisted preference and its CHECK constraint: `cm`, `mm`, `in` |
| `.claude/skills/catchlaw-measurement-ruler/references/measurement-methods.md` | "Storage", "Rounding and comparison", "Display formatting" | The layer/unit table, the three worked rounding rows, the sub-100 mm display rule, and the per-locale output table |
| `.claude/skills/catchlaw-measurement-ruler/SKILL.md` | rules 1, 3, 11 | `RealColumn` and `TextColumn` are never correct for a length; every surface prints through `formatMeasurement` |
| `.claude/skills/value-objects-money-and-units/references/canonical-storage.md` | "Physical value objects", "Conversion factors" | The `.from<Unit>` / `to<Unit>()` shape, and exact factors where an exact definition exists |
| `.claude/skills/adaptive-layout/SKILL.md` | rules 1, 3, 6, 9 | Constraints not devices; the aspect getters; never lock orientation; never assume a fixed cell height |
| `.claude/skills/lonja-forms-and-controls/references/search-field-and-keypad.md` | "Unit and method copy" | The three worked strings: `45 · cm · Total length (TL)`, `65 · cm · Fork length (FL)`, `38 · mm · Shell length` |
| `epics/E09-ruler/epic.md` | Risks 3 and 6 | The four-segment reach in landscape, and who owns `setPreferredOrientations` |
| `epics/DECISIONS.md` | D-3 | The six locales whose decimal separators the formatter test must cover |

## What this delivers

- `app/lib/domain/models/length_unit.dart` — `enum LengthUnit { auto, cm, mm, inch }` mapped from
  `user_profile.length_unit` (`cm`, `mm`, `in`), with the exact conversion factor
  `kMillimetresPerInch = 25.4` as a named constant.
- `app/lib/ui/core/format/measurement_format.dart` — `formatMeasurement`, plus the
  `MeasurementPatterns` record that carries the three localised ICU patterns:

  ```dart
  typedef MeasurementPatterns = ({
    String Function(String value, String method) cm,   // l10n.measurementCm
    String Function(String value, String method) mm,   // l10n.measurementMm
    String Function(String value, String method) inch, // l10n.measurementInch
  });

  String formatMeasurement(
    Measurement m, {
    required LengthUnit unit,
    required NumberFormat numbers,
    required String methodLabel,
    required MeasurementPatterns patterns,
  });
  ```

  A pure function over already-localised pieces, so it is unit-tested without a widget binding and
  so no unit word is ever a Dart literal. Its output is a leaf: nothing parses it, compares it or
  stores it.
- `app/lib/ui/ruler/widgets/ruler_orientation_scope.dart` — `RulerOrientationScope`, a
  `StatefulWidget` that widens the allowed orientation set on `initState` and restores the app
  default in `dispose`. S3 and S4 are its only two call sites.
- Changes to `ruler_screen.dart` and `manual_length_entry.dart`: every figure now goes through
  `formatMeasurement`; the ruler lays its scale along the longer edge from `LayoutBuilder`
  constraints; the segment-ceiling copy states the reach for the *current* span rather than a
  constant.
- ARB keys in all six locales: `measurementCm`, `measurementMm`, `measurementInch` (ICU patterns
  taking `{value}` and `{method}`), `rulerLandscapeHint`.
- Tests: `app/test/ui/core/measurement_format_test.dart`,
  `app/test/ui/ruler/ruler_orientation_test.dart`, and landscape rows added to
  `app/test/ui/ruler/ruler_screen_test.dart`.

## Why it is built this way

**Landscape, with the arithmetic stated.** `SPEC.md` §11 says landscape on S3 and gives the reason —
a 25 cm fish fits better across a phone held sideways. The numbers behind "better" are worth writing
down because they drive T05's ceiling copy: at the nominal 6.299 logical px/mm, a 412 dp portrait
width is about **65 mm** of usable scale, and a 915 dp landscape width is about **145 mm**. A 250 mm
fish therefore takes four segments in portrait — exactly the cap — and two in landscape. Four
landscape segments reach about 580 mm, which is still short of the 650 mm fork-length minimum for
*Scomberomorus commerson*, so the ceiling copy and T06's keypad are not decoration.

**How this squares with "never lock orientation".** `adaptive-layout` rule 6 bans
`SystemChrome.setPreferredOrientations` used to force portrait so a layout never has to handle
landscape. This task does the opposite: it **widens** the allowed set for two screens and does the
layout work anyway, branching on `LayoutBuilder` constraints so the scale runs along the longer edge
whichever way the phone is held. The app-wide default is E01's or E12's to own; `RulerOrientationScope`
restores whatever it was on dispose and never assumes it. *Rejected:* pinning S3 to landscape only.
A phone in a mount, a tablet, and an accessibility stand all defeat it, and a fisher who cannot rotate
his hand mid-fish would be stuck with an unusable screen.

**Millimetres are the only thing stored, and there is one rounding.** `SPEC.md` §9.5 and
`catchlaw-measurement-ruler` rule 1 agree: `int lengthMm` in the domain, `INTEGER` in drift, `450` for
a Hamour and `38` for an *Ameixa babosa*. `RealColumn` and `TextColumn` are never correct for a
length. The rounding happened once, at capture, in T01's `millimetresFor`; `formatMeasurement` divides
for display and its output never travels back. *Rejected:* storing the user's chosen unit alongside
the value, or storing a formatted string. A double accumulates 44.99999 and rounds under the 45 cm
limit on one device and over it on another; a localised string is unsortable, uncomparable, and wrong
the first time the user switches locale.

**`auto` resolves the mm/cm threshold; the preference overrides it.** Three sources have to be
reconciled and they do reconcile. `measurement-methods.md` gives a display convention — below 100 mm
print millimetres with no decimal, at or above 100 mm print centimetres with one decimal.
`search-field-and-keypad.md` gives the instrument-shaped rule — mm for `shl`/`cw` rules, cm for
`tl`/`fl`/`sl`/`ml`. `SPEC.md` §9.5 adds an inch option. So: `LengthUnit.auto` applies the 100 mm
threshold, which lands a 38 mm *Venerupis corrugata* on `38 mm` and a 450 mm Hamour on `45,0 cm`, and
agrees with the instrument rule for every method in the shipped content. An explicit `cm`, `mm` or
`in` from `user_profile.length_unit` overrides it. One function, one place to change.

**Inches convert with an exact factor.** 25.4 mm per inch is exact by definition. The formatter prints
one decimal for inches; the stored integer is untouched. Inches are default only for `en` with a US
device region (`SPEC.md` §9.5), which is a resolution rule E06 owns — this task consumes the resolved
`LengthUnit` and does not re-derive it.

**Every figure carries its method, in every locale.** The output is
`45,0 cm longitud total (TL)` in `es` and `٤٥٫٠ سم الطول الكلي` in `ar` — the Arabic form drops the
parenthesised Latin code because the Arabic name is already unambiguous, and it never drops the method
itself. The codes are set in the mono face with tabular figures so a column of readings aligns.

## Tests first

Write every row before touching `measurement_format.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `formatMeasurement prints centimetres with one decimal at or above 100 mm` | 450 mm `tl`, `auto`, `en` | `45.0 cm total length (TL)` | The headline worked row in `measurement-methods.md` |
| 2 | `formatMeasurement prints millimetres with no decimal below 100 mm` | 38 mm `shl`, `auto`, `en` | `38 mm shell length (SHL)` | *Venerupis corrugata*; a `3.8 cm` here would be read as 3.8 something |
| 3 | `formatMeasurement uses the locale decimal separator in es` | 450 mm `tl`, `auto`, `es` | `45,0 cm longitud total (TL)` | Four of the six locales use a comma; a hardcoded `.` is wrong in four builds |
| 4 | `ar - formatMeasurement drops the parenthesised code and keeps the method` | 450 mm `tl`, `auto`, `ar` | contains `الطول الكلي`, contains no `(TL)` | The documented Arabic form; the method is never what gets dropped |
| 5 | `formatMeasurement prints inches with one decimal when the unit is inch` | 450 mm `tl`, `inch`, `en` | `17.7 in total length (TL)` | 450 / 25.4 = 17.716…; proves the exact factor and the single rounding at display |
| 6 | `formatMeasurement respects an explicit mm preference above 100 mm` | 450 mm `tl`, `mm`, `en` | `450 mm total length (TL)` | The `user_profile.length_unit` override beats the auto threshold |
| 7 | `formatMeasurement never returns a bare figure` | every unit × every method | the output always contains the method label | Rule 3 as a property, not an example: a bare 65 cm is read as total length and lands a fish six centimetres short |
| 8 | `formatMeasurement output does not round-trip into storage` | format then attempt to parse | the test asserts no parse helper exists for it | Rule 11's round trip is the manufactured pass at exactly 450 mm |
| 9 | `LengthUnit.fromColumn maps the three stored codes` | `cm`, `mm`, `in` | the three enum values | The `user_profile` CHECK constraint is `('cm','mm','in')`, not `('cm','mm','inch')` |
| 10 | `RulerScreen lays the scale along the longer edge in landscape` | 915 × 412 | the ruler's `getSize().width` is the longer dimension | The reason SPEC asks for landscape at all |
| 11 | `RulerScreen lays the scale along the longer edge in portrait` | 412 × 915 | still the longer dimension of the available box | Never lock orientation; the layout must be correct either way |
| 12 | `RulerScreen states a segment ceiling computed from the current span` | 915 dp landscape at 6.299 | the stated reach is within 5 mm of 4 × 145 mm | A constant here would lie on every device that is not the one it was written on |
| 13 | `RulerOrientationScope restores the previous orientation set on dispose` | push then pop S3 | the restored set equals the set captured on mount | The app default is not this epic's to change permanently |
| 14 | `RulerScreen holds its layout at 200% text scale in landscape` | `TextScaler.linear(2.0)`, 915 × 412 | `tester.takeException()` is null and the readout fits its computed cell | `SPEC.md` §4.9: layouts survive 200%; a clipped `Text` reports nothing, so the fit assertion is the gate |
| 15 | `ManualLengthEntry holds its layout at 200% text scale` | `TextScaler.linear(2.0)` | no overflow, keys still clear the target floor | The keypad is the tallest thing on the screen and the first to overflow |

```dart
// app/test/ui/core/measurement_format_test.dart
import 'package:catchlaw/domain/models/length_unit.dart';
import 'package:catchlaw/ui/core/format/measurement_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:rule_engine/rule_engine.dart' show Measurement, MeasurementMethod;

void main() {
  // Stand-ins for the six ARB patterns; the real ones come from AppLocalizations,
  // which is why no unit word is ever a Dart literal in app/lib.
  const MeasurementPatterns en = (
    cm: _cmEn,
    mm: _mmEn,
    inch: _inchEn,
  );

  String format(int mm, MeasurementMethod method, LengthUnit unit,
          String methodLabel) =>
      formatMeasurement(
        Measurement(lengthMm: mm, method: method),
        unit: unit,
        numbers: NumberFormat.decimalPattern('en'),
        methodLabel: methodLabel,
        patterns: en,
      );

  group('formatMeasurement', () {
    test('prints centimetres with one decimal at or above 100 mm', () {
      expect(format(450, MeasurementMethod.tl, LengthUnit.auto,
          'total length (TL)'), '45.0 cm total length (TL)');
    });

    test('prints millimetres with no decimal below 100 mm', () {
      expect(format(38, MeasurementMethod.shl, LengthUnit.auto,
          'shell length (SHL)'), '38 mm shell length (SHL)');
    });

    test('prints inches with one decimal when the unit is inch', () {
      // 450 / 25.4 = 17.716…, rounded once, for display only.
      expect(format(450, MeasurementMethod.tl, LengthUnit.inch,
          'total length (TL)'), '17.7 in total length (TL)');
    });
  });
}

String _cmEn(String value, String method) => '$value cm $method';
String _mmEn(String value, String method) => '$value mm $method';
String _inchEn(String value, String method) => '$value in $method';
```

```dart
// app/test/ui/ruler/ruler_orientation_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  testWidgets('RulerOrientationScope restores the previous orientation set on '
      'dispose', (tester) async {
    final calls = <List<String>>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemChrome.setPreferredOrientations') {
          calls.add(List<String>.from(call.arguments as List));
        }
        return null;
      },
    );

    await tester.pumpRulerScreen(calibration: kNominalCalibration);
    await tester.popRulerScreen();

    expect(calls.length, 2);
    expect(calls.last, kAppDefaultOrientations); // restored, not widened
  });
}
```

**Run:** `cd app && flutter test test/ui/core test/ui/ruler` → 15 failures. Row 5 is the one most
likely to pass early by accident if a formatter already exists; if it does, delete the accidental
formatter rather than the test.

## Implementation outline

1. `length_unit.dart`: the enum, `fromColumn(String)`/`toColumn()` matching the `user_profile` CHECK
   constraint exactly, and `const kMillimetresPerInch = 25.4` with a comment that it is exact by
   definition.
2. `measurement_format.dart`: the `MeasurementPatterns` record, then one function — one `switch` over
   `LengthUnit`, the 100 mm threshold in the `auto` arm, `numbers.format` for the figure, and the
   selected ARB pattern for the sentence. The unit word lives only in the six ARB files; nothing in
   `app/lib` concatenates a unit onto a number.
3. Replace every figure-rendering site from T02, T05 and T06 with a `formatMeasurement` call. After
   this task there is no other way to print a length in `app/lib`.
4. `ruler_orientation_scope.dart`: capture the current preferred set — from the app config E01
   published, not from a guess — widen it in `initState`, restore in `dispose`. Never call it from
   `build`.
5. `RulerScreen`: compute the span inside `LayoutBuilder`; use the longer of the two constraint
   dimensions; recompute the segment ceiling from `span / pxPerMm * 4` and feed it to
   `rulerSegmentCeiling`.
6. Add the 200%-scale rows as **one `testWidgets` per tuple** — overflow is reported once per
   `RenderObject`, so a loop inside a single test silently under-reports every scale after the first.
7. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 15 tests pass, and each failed first.
- [ ] `grep -rn "formatMeasurement" app/lib` finds every place a length is rendered, and no Dart
      string literal in `app/lib` contains a bare ` mm` or ` cm` — the unit words come from the ARB
      patterns, which is what makes check 2 of `check_measurement.sh` pass without a hatch.
- [ ] No `RealColumn` or `TextColumn` holds a length anywhere in `app/lib`.
- [ ] No `SystemChrome.setPreferredOrientations` call exists outside `ruler_orientation_scope.dart`,
      and that file restores what it captured.
- [ ] No `Platform.is*` or `kIsWeb` is used to select a layout.
- [ ] The 200% rows exist as separate `testWidgets` calls, one per tuple, with a `getSize` fit
      assertion behind the overflow check.
- [ ] All six ARB files gained the same measurement patterns; the `ar` value omits the Latin code and
      keeps the method.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh    app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh   app/lib
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
feat(ruler): run S3 in landscape and make cm, mm and inch display-only

At 6.299 logical px/mm a 412 dp portrait width is about 65 mm of usable scale
and a 915 dp landscape width is about 145 mm, so a 25 cm fish takes four
segments upright and two sideways. That is what SPEC 11 means by "fits better",
and it is why the segment ceiling is now computed from the live span instead of
a constant that would be wrong on every device except the one it was written
on.

Orientation is widened for S3 and S4 and restored on dispose, never pinned: the
layout branches on constraints and puts the scale along the longer edge either
way, so a mount, a tablet and an accessibility stand all still work.

Every length remains an integer of millimetres rounded exactly once at capture.
formatMeasurement is now the only way to render one, it always prints the
method beside the figure, and its output is a leaf — nothing parses it back,
because 449 mm shown as 45 cm and re-read as 450 manufactures a pass at the
exact millimetre that costs a fine.

Task: E09/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
