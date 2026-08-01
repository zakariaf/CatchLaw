# E20/T04 — The ruler's LTR exception, verified in `ar`

| | |
|---|---|
| **Epic** | E20 — RTL and locale hardening |
| **Branch** | `epic/20-rtl-hardening` (shared) |
| **Commit** | `test(ruler): prove the scale does not mirror under ar and its labels still localise` |
| **Depends on** | T03 (the numeral preference and the `numberFormatSymbols` guard both exist) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.3 "The ruler does not mirror", §6 S3 · S4, §4.2, §14 last dynamic item |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-measurement-ruler` | Owns the exception. Rules 4, 5 and 6 and `references/ruler-and-calibration.md` "The RTL exception" name exactly what must hold and what the wrong implementations look like |
| `i18n-rtl-l10n` | The ruler is this skill's documented exception, not a counter-example. `references/rtl-and-bidi.md` "CustomPainter — do NOT auto-mirror" gives the pin-only-that-subtree rule and the pointer-mapping rule |
| `widget-golden-and-a11y-testing` | Rule 8 — computed geometry beats a golden for layout, and `find.byKey` is the finder for geometry. This task is the geometry half of what T01 photographs |
| `lonja-typography` | `references/arabic-and-scripts.md` numeral rules 1–2: Arabic-Indic digits have no tabular coverage, so a tick column is pinned rather than trusted to figure widths |
| `catchlaw-conventions-index` | Routing: the ruler crosses `i18n-rtl-l10n`, `custom-canvas-and-gestures` and `catchlaw-measurement-ruler`, and rule 9 says find the owner before editing |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.3, "The ruler does not mirror" | The rule, the reason (mirroring puts zero at the wrong end of a real fish), the mechanism (`Directionality(textDirection: TextDirection.ltr)` around the ruler only, labels still localise), and that measurement diagrams do not mirror either |
| `SPEC.md` | §6, S3 | Full-bleed ruler along the long edge, draggable end marker, live readout, method reminder with mini-diagram, step and mark |
| `SPEC.md` | §14, last dynamic item | "the ruler reads correctly left-to-right" in the `ar` device walkthrough — this task is the host-side half of that check |
| `FLUTTER_GUIDE.md` | Part 9.2, "Forcing the ruler LTR" | Why `Directionality` and not a `Transform`: it changes layout semantics with zero effect on hit-testing, where a flip matrix leaves hit geometry transformed and renders labels mirrored |
| `.claude/skills/catchlaw-measurement-ruler/references/ruler-and-calibration.md` | "The RTL exception" | The five-row table of what is pinned and what stays ambient, the required comment, and `labelDirection` as a constructor field compared in `shouldRepaint` |
| `.claude/skills/catchlaw-measurement-ruler/references/ruler-and-calibration.md` | "The card is the ruler" | `kNominalPxPerMm = 6.299`, band 4.50–9.00 — the calibration the test pins |
| `.claude/skills/catchlaw-measurement-ruler/SKILL.md` | rules 4, 5, 6, 11 | The painter takes `labelDirection`; `canvas.scale(-1, 1)` is the only legal mirror and glyphs come after `restore()`; one rounding, at capture |
| `.claude/skills/i18n-rtl-l10n/references/rtl-and-bidi.md` | "CustomPainter — do NOT auto-mirror" | Pin only that subtree; map pointers through the painter's own transform, never by inverting `dx` |
| `epics/DECISIONS.md` | D-8 | The directional-padding ban is a grep gate at `tools/gates/no_directional_geometry.sh`, not a lint |

## What this delivers

- `app/test/ui/ruler/ruler_ar_direction_test.dart` — the whole task.
- Stable geometry anchors on the ruler surface where they are missing: `ValueKey('ruler_zero')`,
  `ValueKey('ruler_end_marker')`, `ValueKey('ruler_readout')`, `ValueKey('ruler_surface')`, and
  `ValueKey('method_diagram_arrow')` on the S2 measurement diagram. `find.byType` is not a geometry
  finder (`widget-golden-and-a11y-testing`, anti-patterns).
- A pure `rulerTickLabel(int millimetres, NumberFormat)` in `app/lib/ui/ruler/` if the label string is
  currently built inside `paint()`. A label that can only be observed by rasterising is a label no test
  can assert; extracting it is the smallest change that makes row 10 possible.
- No change to the `Directionality` pin itself — if it is already right, this task proves it; if it is
  wrong, the fix rides here and is named in the commit body.

## Why it is built this way

**The exception is real and it is narrow.** `SPEC.md` §9.3 and `catchlaw-measurement-ruler` rule 4 both
say it: a physical measuring scale runs from a physical edge, so mirroring it under `ar` puts zero at
the tail of the fish instead of the snout. Every other pixel on the screen mirrors. The test therefore
asserts **both** halves — `TextDirection.ltr` inside the ruler subtree *and* `TextDirection.rtl` in the
chrome around it. Asserting only the first would pass just as happily against the banned
implementation: a root `Directionality(TextDirection.rtl)` never applied, or an app that forgot RTL
entirely (`i18n-rtl-l10n` rule 4 — "a hardcoded root hides physical-side bugs").

**The same-edge claim is a number, not a picture.** T01 blesses `s03_ruler_ar_paper.png`, but a golden
cannot assert anything: bless a mirrored ruler once and it passes forever, green
(`golden-two-lanes.md`). So the load-bearing assertion here is that
`getRect(find.byKey(ValueKey('ruler_zero'))).left` under locale `ar` equals its value under `en` within
0.5 dp, and that the 120 mm tick does too — because zero alone matching would still permit a scale
that runs the other way from a shared origin.

**A real fish, and a real calibration.** `pxPerMm` is pinned to the nominal `6.299`, which is inside
the 4.50–9.00 plausibility band, so 120 mm lands at 755.88 dp and the assertion is an arithmetic
statement rather than a tolerance. The committed reading is **380 mm** — the 38 cm Hamour from
`SPEC.md` §5.1, below its 45 cm total-length minimum. 380 mm does not fit one screen at 6.299 px/mm
(a 800 dp long edge holds ~127 mm), so it arrives through step-and-mark, which is the honest state a
fisher measuring that fish is actually in.

**Landscape, deliberately.** S3 is a full-bleed ruler along the **long** edge. Pinning a portrait
surface would make "the same edge" a claim about the wrong axis, and the test would be measuring
nothing while looking rigorous. The device is pinned at 800 × 360 logical at DPR 3.0 — physical pixels
are logical × DPR (`harness-and-mediaquery.md`), and `addTearDown(view.reset)` keeps the pin from
poisoning the next file.

**`labelDirection` stays ambient, and `shouldRepaint` must see it.** The painter has no
`BuildContext`, so the direction is a constructor field taken from `Directionality.of(context)` in the
widget above — the *ambient* one, not the pinned `ltr`, because tick labels are text and text follows
the locale. `catchlaw-measurement-ruler` rule 5 records the consequence of omitting it from
`shouldRepaint`: Arabic labels keep Latin shaping until some unrelated rebuild happens to clear them.
That is a bug nobody reproduces on demand, so it gets its own row.

**Rejected: `Matrix4.rotationY(pi)`.** It appears in **zero** places in the Flutter framework source. It
is a 3-D transform on a 2-D canvas, it mirrors hit-test geometry along with the pixels, and any glyph
drawn inside the mirrored frame ships backwards. `check_measurement.sh` check 4 already bans it
repository-wide, so this task cites the gate rather than adding a duplicate grep.

**Rejected: mirroring the painter and compensating in the gesture handler.** `FLUTTER_GUIDE.md` Part
9.2 is explicit — `Directionality` changes layout semantics with **zero** effect on hit-testing
coordinates, which is the entire reason it is the right mechanism. Inverting `dx` for RTL is the
anti-pattern `rtl-and-bidi.md` names by hand.

**Rejected: covering the measurement diagram in a separate task.** §9.3 puts the ruler and the
diagrams in the same sentence — "measurement diagrams likewise do not mirror — a fork-length arrow
must point at the actual fork." A fork-length arrow that flips under `ar` sends a fisher measuring a
650 mm Kanaad to the wrong landmark, which is the same failure with a different picture. One row.

## Tests first

Write all 13 before touching the ruler. Run them. **They must fail** — nothing has ever asserted a
direction inside that subtree. If row 3 (the chrome is `rtl`) passes but row 2 (the ruler is `ltr`)
fails, the pin is missing; if both pass immediately, check that the harness really resolved locale `ar`
before believing it.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `RulerScreen resolves TextDirection.rtl for locale ar` | `Locale('ar')` | `Directionality.of(screenRoot) == rtl` | The premise. Every row below is meaningless if the locale did not actually flip the app |
| 2 | `ar - RulerSurface pins TextDirection.ltr inside its own subtree` | `Locale('ar')` | `ltr` at `ruler_surface` | The exception itself (`SPEC.md` §9.3, skill rule 4) |
| 3 | `ar - RulerScreen chrome outside the ruler stays TextDirection.rtl` | `Locale('ar')` | `rtl` at the app bar | Proves the pin is a *subtree island*, not an app that forgot RTL — the failure the ruler test would otherwise hide |
| 4 | `ar - RulerSurface places the zero mark at the same x as en` | zero mark rect in both | equal within 0.5 dp | "Mirroring would put zero at the tail" — the sentence, as a number |
| 5 | `ar - RulerSurface places the 120 mm tick at the same x as en` | tick rect in both | equal within 0.5 dp | Zero alone matching still permits a scale running the other way from a shared origin |
| 6 | `ar - RulerSurface places the end marker 755.88 dp from zero at 120 mm and 6.299 px/mm` | live segment 120 mm | `755.88 ± 0.5` | Ties the geometry to the real calibration constant instead of to a tolerance |
| 7 | `ar - RulerSurface keeps the tick order ascending from the start edge` | first three tick rects | strictly increasing `left` | Catches a `canvas.scale(-1, 1)` applied to the tick band without the matching translate |
| 8 | `RulerPainter takes labelDirection rtl under ar and ltr under en` | painter field | `rtl` / `ltr` | Labels are text and follow the locale — the half of the exception people delete by accident |
| 9 | `RulerPainter.shouldRepaint returns true when labelDirection changes` | two painters, direction differs | `true` | Skill rule 5: omit it and Arabic labels keep Latin shaping until an unrelated rebuild |
| 10 | `rulerTickLabel formats 450 mm as ٤٥ when numeralSystem is arab` | 450 mm | `٤٥` | The labels localise their numerals — §9.3, and the reason the exception is about geometry only |
| 11 | `rulerTickLabel formats 450 mm as 45 when numeralSystem is auto` | 450 mm | `45` | The shipped default for `ar` is Western (§9.3); the exception must not smuggle in a numeral change |
| 12 | `ar - RulerReadout states 38 cm with its method after three marked segments and a remainder` | 120 + 120 + 120 + 20 mm | contains the method label | `catchlaw-measurement-ruler` rule 3: a bare figure is a defect. 380 mm is the §5.1 Hamour, and it only reaches the screen through step-and-mark |
| 13 | `ar - ForkLengthDiagram places its arrow head at the same x as en` | S2 diagram | equal within 0.5 dp | §9.3's second sentence: a fork-length arrow must point at the actual fork. Same failure, different picture |

```dart
// app/test/ui/ruler/ruler_ar_direction_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/l10n/numeral_symbols.dart';
import '../../../testing/ui/pump_app.dart';

/// The ruler is the one screen held sideways: S3 is full-bleed along the LONG edge, so a
/// portrait pin would make "the same edge" a claim about the wrong axis.
const _landscape = Size(800, 360);
const _pxPerMm = 6.299; // kNominalPxPerMm — inside the 4.50–9.00 plausibility band

double _leftOf(WidgetTester t, String key) =>
    t.getRect(find.byKey(ValueKey(key))).left;

void main() {
  guardNumberFormatSymbols();

  Future<double> zeroLeftIn(WidgetTester tester, Locale locale) async {
    tester.useDevice(_landscape, dpr: 3.0);
    await tester.pumpRuler(locale: locale, pxPerMm: _pxPerMm, liveSegmentMm: 120);
    return _leftOf(tester, 'ruler_zero');
  }

  testWidgets('RulerScreen resolves TextDirection.rtl for locale ar', (tester) async {
    tester.useDevice(_landscape, dpr: 3.0);
    await tester.pumpRuler(locale: const Locale('ar'), pxPerMm: _pxPerMm);
    final root = tester.element(find.byKey(const ValueKey('ruler_screen')));
    expect(Directionality.of(root), TextDirection.rtl);
  });

  testWidgets('ar - RulerSurface pins TextDirection.ltr inside its own subtree',
      (tester) async {
    tester.useDevice(_landscape, dpr: 3.0);
    await tester.pumpRuler(locale: const Locale('ar'), pxPerMm: _pxPerMm);
    final surface = tester.element(find.byKey(const ValueKey('ruler_surface')));
    expect(Directionality.of(surface), TextDirection.ltr,
        reason: 'a physical scale never mirrors — SPEC.md §9.3, '
            'catchlaw-measurement-ruler rule 4');
  });

  testWidgets('ar - RulerSurface places the zero mark at the same x as en',
      (tester) async {
    final ar = await zeroLeftIn(tester, const Locale('ar'));
    final en = await zeroLeftIn(tester, const Locale('en'));
    expect(ar, moreOrLessEquals(en, epsilon: 0.5),
        reason: 'zero moved by ${(ar - en).abs()} dp under ar — it is now at the tail');
  });

  testWidgets('ar - RulerSurface places the end marker 755.88 dp from zero '
      'at 120 mm and 6.299 px/mm', (tester) async {
    tester.useDevice(_landscape, dpr: 3.0);
    await tester.pumpRuler(
        locale: const Locale('ar'), pxPerMm: _pxPerMm, liveSegmentMm: 120);
    final span = _leftOf(tester, 'ruler_end_marker') - _leftOf(tester, 'ruler_zero');
    expect(span, moreOrLessEquals(120 * _pxPerMm, epsilon: 0.5)); // 755.88
  });

  test('RulerPainter.shouldRepaint returns true when labelDirection changes', () {
    final ltr = rulerPainterFor(labelDirection: TextDirection.ltr);
    final rtl = rulerPainterFor(labelDirection: TextDirection.rtl);
    expect(rtl.shouldRepaint(ltr), isTrue,
        reason: 'omit labelDirection from shouldRepaint and Arabic labels keep Latin '
            'shaping until some unrelated rebuild clears them');
  });
}
```

**Run:** `cd app && flutter test test/ui/ruler/ruler_ar_direction_test.dart` → red. Row 6 will fail
first on a missing key rather than on a wrong number; add the keys, then read the number.

## Implementation outline

1. Add the five `ValueKey` anchors. They are test seams, not layout — no geometry changes with them.
2. Run rows 1–3. If row 2 is red, the `Directionality(textDirection: TextDirection.ltr)` island is
   missing or is wrapping the wrong node; add it around the ruler subtree **only**, with the comment
   `// catchlaw: a physical scale never mirrors` on the line, which is what makes it reviewable as an
   exception rather than an oversight.
3. Run rows 4–7. A failure here is a real mirror. The fix is the pin, never `canvas.scale(-1, 1)` on
   the whole painter — and if a tick band genuinely needs to flip, it is `save` → `scale(-1, 1)` →
   `translate(-width, 0)` → geometry → `restore()` → **then** glyphs, per skill rule 6.
4. Run rows 8–9. `labelDirection` is a constructor field on `RulerPainter` fed from
   `Directionality.of(context)` in the widget above, and it is compared in `shouldRepaint` alongside
   `pxPerMm`, `numerals` and `scene`.
5. Run rows 10–11. If the label string is built inside `paint()`, extract
   `rulerTickLabel(int millimetres, NumberFormat)` and have `paint()` call it. Feed the painter the
   same `numberFormatFor(locale, numeralSystem)` the chrome uses (T03) — a tick label and the readout
   beside it disagreeing about digits is worse than either being wrong alone.
6. Run rows 12–13. Row 12 drives the step-and-mark state through the draft; row 13 is the S2 diagram.
7. Re-run the full suite, then the golden lane on Linux: `s03_ruler_*` is exactly what a geometry fix
   here would move, and a moved ruler golden is either the fix landing or the fix being wrong.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 13 rows pass, and each failed first.
- [ ] The `Directionality(textDirection: TextDirection.ltr)` island wraps the ruler subtree and nothing
      larger, and carries the exception comment on its line.
- [ ] The chrome around the ruler is still `rtl` under `ar` — the island did not become an app-wide
      opt-out.
- [ ] `RulerPainter` takes `labelDirection` as a constructor field, reads no `BuildContext`, and
      compares `labelDirection` and `numerals` in `shouldRepaint` (skill rules 5, 12).
- [ ] `Matrix4.rotationY` appears nowhere in `app/lib/` — proved by `check_measurement.sh` check 4.
- [ ] No pointer handler inverts `dx` for RTL; gestures map through the painter's own transform on
      `localPosition`.
- [ ] Every reading on the screen still carries its method (`catchlaw-measurement-ruler` rule 3), and
      every stored length is still integer millimetres (rule 1).
- [ ] `tools/gates/no_directional_geometry.sh app/lib` is clean — the ruler's `ltr` island is not a
      licence for a physical `left` inset anywhere near it (D-8).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze
cd app && flutter test --exclude-tags golden
cd app && flutter test --tags golden          # Linux; s03_ruler_* must be unchanged or explained
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh app/lib
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
test(ruler): prove the scale does not mirror under ar and its labels still localise

SPEC.md §9.3 makes the ruler the one deliberate exception to the app's
mirror-everything rule: a physical scale runs from a physical edge, so
flipping it under ar puts zero at the tail of the fish. T01 photographs
s03_ruler_ar, but a golden cannot assert anything — bless a mirrored ruler
once and it passes forever. These are the numbers.

Both halves are asserted. The ruler subtree resolves TextDirection.ltr AND
the chrome around it resolves rtl, because asserting only the first would
pass just as happily against an app that never turned RTL on at all. Zero
and the 120 mm tick sit within 0.5 dp of their en positions, and the end
marker sits 755.88 dp from zero at the nominal 6.299 px/mm — arithmetic,
not tolerance. The readout states 38 cm with its method after three marked
segments and a remainder, which is how a 380 mm Hamour actually reaches a
screen 127 mm long.

labelDirection stays ambient, is a constructor field on the painter, and is
compared in shouldRepaint — omit it and Arabic tick labels keep Latin
shaping until some unrelated rebuild clears them. The tick labels take the
same formatter as the chrome, so ٤٥ on the canvas and ٤٥ beside it can
never disagree. §9.3's second sentence gets a row too: the fork-length
arrow points at the actual fork in ar.

Task: E20/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
