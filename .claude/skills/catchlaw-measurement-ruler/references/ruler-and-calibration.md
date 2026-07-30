# Ruler and Calibration

Scope: the ID-1 calibration procedure and its maths, the plausibility band, the step-and-mark state
machine, the manual-entry ground floor, the RTL exception, and the measured accuracy budget.

## The card is the ruler

ISO/IEC 7810 ID-1 — the format of every bank card, national ID and driving licence — is
**85.60 × 53.98 mm**, with corner radius 3.18 mm. It is the one precisely-dimensioned object every
fisher on every quay already carries, in a pocket, in the dark, with no signal.

| Constant | Value | Where |
|---|---|---|
| `kId1WidthMm` | `85.60` | `lib/features/measure/calibration/id1.dart` |
| `kId1HeightMm` | `53.98` | same |
| `kNominalPxPerMm` | `6.299` | 160 logical dp per inch ÷ 25.4 |
| `kMinPxPerMm` | `4.50` | plausibility floor, measured |
| `kMaxPxPerMm` | `9.00` | plausibility ceiling, measured |

Logical pixels are nominally 160 per inch, so `pxPerMm` clusters near 6.3 — but real panels deviate,
which is exactly why the value is measured per device and never derived. `devicePixelRatio` is a
logical-to-physical ratio, NOT a physical DPI; no arithmetic on it yields millimetres.

## Procedure

1. The user lays a card flat on the screen against the fixed left edge of the calibration surface.
2. One draggable handle sets the card's right edge. Handle hit target 56 dp, glove-mode 64 dp.
3. `pxPerMm = cardWidthPx / kId1WidthMm`.
4. The result is judged BEFORE it is stored (below).
5. On acceptance, `RulerCalibration(pxPerMm:, capturedOn:)` is written to the user DB. There is one
   row; recalibration replaces it and is always available from the measure screen.

## Plausibility band

| Measured `pxPerMm` | Verdict | Effect |
|---|---|---|
| `< 4.50` | `CalibrationImplausible` | nothing stored; previous calibration survives |
| `4.50 – 9.00` | `CalibrationAccepted` | stored with `capturedOn` |
| `> 9.00` | `CalibrationImplausible` | nothing stored; previous calibration survives |
| non-finite / `0` | `CalibrationImplausible` | nothing stored |

The rejection message is a statement: "That width would make the screen 34 cm wide." It never
instructs, and it never falls back to `kNominalPxPerMm` — a plausible-looking wrong scale is worse
than no ruler at all, because every reading afterwards is confidently wrong and nothing signals it.

## Step-and-mark

A 92 cm Kanaad is longer than any phone, so the fish is stepped along the screen.

| State | Trigger | Effect |
|---|---|---|
| `idle` | screen opened | `segmentsMm: []`, `committedMm` = last saved reading or null |
| `marking` | first drag | live segment shown, running total shown beside it |
| `marking` | MARK pressed | segment appended to `segmentsMm`, handle returns to zero |
| `marking` | UNDO pressed | last segment removed; total recomputes |
| `idle` | CANCEL pressed | `segmentsMm` cleared, `committedMm` RESTORED unchanged |
| `committed` | ACCEPT pressed | `Measurement(lengthMm: totalMm, method: rule.method)` stored |

Invariants: the running total is always visible, always in millimetres internally, always printed
with its method. CANCEL never yields zero and never yields null. Segment count is unbounded; the
draft is held in memory only and is not persisted mid-measurement.

## Manual entry is the ground floor

| Condition | Ruler tab | Manual entry |
|---|---|---|
| `calibration == null` (virgin install) | disabled, with a one-line reason | ENABLED |
| calibration present | enabled | ENABLED |
| calibration rejected this session | disabled | ENABLED |
| screen smaller than the card | disabled | ENABLED |

The manual path is complete on its own: species → jurisdiction → keypad → verdict. A widget test
runs exactly that path with no calibration row in the user DB. Gating the measure step on
calibration would mean no answer at 05:40 for a fisher who left the card ashore.

## The RTL exception

| Element | Direction | Why |
|---|---|---|
| Ruler tick geometry | ALWAYS `ltr` | a physical scale has a physical origin; zero must sit at the same screen edge as the fish's snout |
| Zero mark | left edge in all six locales | mirroring would put zero at the tail |
| Tick labels | ambient direction | they are text |
| Label numerals | locale numeral system (٠١٢ in `ar`) | they are numbers a human reads |
| Surrounding chrome, buttons, sheets | ambient direction | ordinary UI, owned by `i18n-rtl-l10n` |

Implementation: `Directionality(textDirection: TextDirection.ltr)` wrapping ONLY the ruler subtree,
carrying the comment `// catchlaw: a physical scale never mirrors`. The painter cannot see it —
`CustomPainter` has no `BuildContext` — so `labelDirection` is a constructor field taken from
`Directionality.of(context)` in the widget above and compared in `shouldRepaint`.

If a tick band must flip, use `canvas.save(); canvas.scale(-1, 1); canvas.translate(-width, 0);` and
draw every glyph AFTER `canvas.restore()`. This is the SDK's own pattern, used in
`decoration_image.dart` and `progress_indicator.dart`. `Matrix4.rotationY(pi)` appears in ZERO
places in the framework source and is not the answer here either.

## Accuracy budget

Stated, then measured. The number is a legal exposure, so it is never asserted from a simulator.

| Metric | Target |
|---|---|
| Median absolute error over a 150 mm steel reference | ≤ 1.5 mm |
| Worst device in the matrix | ≤ 3.0 mm |
| Calibration repeatability, same device, 5 runs | ≤ 1.0 mm spread |
| Reading repeatability, same user, 5 runs | ≤ 2.0 mm spread |

Protocol: calibrate against an ID-1 card, measure a 150 mm engineering rule ten times, record the
absolute error of each reading, take the median. Repeat per device, per release.

| Device | OS | pxPerMm | Median abs. error | Worst | Date |
|---|---|---|---|---|---|
| _fill per release_ | | | | | |
| _low-end Android target_ | | | | | |
| _iPhone target_ | | | | | |
| _10-inch tablet_ | | | | | |

A release with an empty matrix does not ship the ruler tab; manual entry alone is a complete,
honest product and always was.

## Failure modes seen in the field

- **Card under a thick case.** Reads narrow, `pxPerMm` low; the band catches it below 4.50.
- **Screen protector parallax.** Adds up to ~1 mm at a shallow viewing angle; inside budget, and the
  reason the budget is 1.5 mm and not 0.5 mm.
- **Wet screen, ghost touches.** The handle is drag-only, never tap-to-place, so a spurious tap does
  not move a saved calibration.
- **Tablet in landscape.** `pxPerMm` is identical; only the usable length changes, which changes the
  number of step-and-mark segments and nothing else.
- **Locale switched mid-measurement.** The draft holds integers, so nothing is reparsed; only labels
  re-render, and `shouldRepaint` sees `labelDirection` change.
