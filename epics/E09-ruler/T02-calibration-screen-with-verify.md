# E09/T02 — S4: calibration, with a verify step

| | |
|---|---|
| **Epic** | E09 — Ruler and calibration |
| **Branch** | `epic/09-ruler` (shared) |
| **Commit** | `feat(ruler): add S4 calibration with a live readout and a 50 mm verify bar` |
| **Depends on** | T01 (the model, the band and the repository must already exist) |
| **Size** | L |
| **Spec** | `SPEC.md` §6 S4 (every element and the error state), §4.2 (calibration row), §11 Both (landscape), §4.9 (targets) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-measurement-ruler` | Owns the procedure: fixed start edge, one draggable handle, 56 dp hit target, judged before stored, previous survives a rejection |
| `lonja-design-tokens` | Every colour, gap, rule weight and radius on this screen; and rule 12 — the card-outline painter takes a `LonjaTokens` snapshot, never a `BuildContext` |
| `lonja-forms-and-controls` | The drag handle and the Save action are Lonja instruments, not Material chrome: ruled cells, no pill, no filled ground, target from `LonjaTargets`/`LonjaTokens.density` |
| `custom-canvas-and-gestures` | View/Painter/Scene split for the card outline, `localPosition` through the shared transform, `HitTestBehavior.opaque`, `ExcludeSemantics` + a sibling node |
| `state-management-riverpod` | The `CalibrationViewModel` shape: one `Notifier` over one immutable value, intent methods only, collaborators injected |
| `accessibility-as-code` | The handle is a ≥ 44 dp single-tap-and-drag target with a labelled `Semantics` node, and the rejection is announced, not merely coloured |
| `i18n-rtl-l10n` | Six ARB values for every string on the screen, ICU for the readout, and `EdgeInsetsDirectional` on all the chrome around the instrument |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S4 | The exact element list — outline overlay, pinch/drag to fit, live mm-per-pixel readout, Verify step with a 50 mm bar, Save — and the error state |
| `SPEC.md` | §11 "Both" | Landscape is available on the ruler; this screen inherits that allowance (see "Why", point 2) |
| `SPEC.md` | §4.9 | ≥ 48 dp targets, ≥ 56 dp in glove mode; every control labelled |
| `.claude/skills/catchlaw-measurement-ruler/references/ruler-and-calibration.md` | "Procedure", "Plausibility band", "Failure modes seen in the field" | The five numbered steps, the rejection sentence's grammar, and why the handle is drag-only rather than tap-to-place |
| `.claude/skills/catchlaw-measurement-ruler/SKILL.md` | rules 7, 8 | The card and nothing but the card; an implausible scale is rejected, never stored |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | tier-2 slots, rule weights, density set | `surface`, `onSurface`, `ruleBearing`, `LonjaRules.strong`, `LonjaDensity.tapMin` |
| `.claude/skills/lonja-design-tokens/SKILL.md` | rules 4, 6, 12 | No shadow, no radius above 2; a frame that identifies uses `ruleBearing`; the painter takes a snapshot |
| `.claude/skills/lonja-forms-and-controls/references/control-anatomy.md` | "Targets and density", "State matrix" | The error row: `ochre` marginal glyph plus the word, never `oxblood` on an input |
| `.claude/skills/custom-canvas-and-gestures/references/gestures-and-semantics.md` | "The gesture is a pure translator", "Axis-locked drag is a clamp" | `localPosition` → transform → typed command → notifier; the drag bound is snapshotted at drag-start |
| `.claude/skills/accessibility-as-code/SKILL.md` | rules 1, 6, 8 | Semantics on the handle, non-colour channel on the rejection, ≥ 44 px target |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariant 2 and its banned lexicon | **`Return` is banned** — no control on this screen may be labelled with it |
| `FLUTTER_GUIDE.md` | §8.1 | Private `StatelessWidget` classes in the same file, never `Widget _buildX()` |
| `epics/DECISIONS.md` | D-2, D-3 | Tokens live under `app/lib/theme/`; the six ARB filenames |

## What this delivers

- `app/lib/ui/ruler/widgets/calibration_screen.dart` — `CalibrationScreen` (S4) plus its private
  `_CardSurface`, `_ScaleReadout`, `_VerifyStep` and `_RejectionNote` widget classes.
- `app/lib/ui/ruler/widgets/card_outline_painter.dart` — `CardOutlinePainter`: the ID-1 outline at
  the current handle width, its 3.18 mm corner radius, the fixed start edge and the moving end edge.
  Takes a `CardOutlineScene` snapshot; the file contains no `BuildContext`.
- `app/lib/ui/ruler/view_models/calibration_viewmodel.dart` — `CalibrationViewModel extends
  Notifier<CalibrationState>` with `state` holding `handleWidthPx`, `step` (`fit` | `verify`) and
  `lastOutcome`; intent methods `dragTo(double localDx)`, `advanceToVerify()`, `back()`, `save()`.
- ARB keys in all six of `app/lib/l10n/app_{ar,en,es,gl,ca,pt_BR}.arb`:
  `calibrationTitle`, `calibrationCardExplainer`, `calibrationHandleLabel`, `calibrationScaleReadout`
  (ICU, one `{mmPerPixel}` placeholder), `calibrationVerifyExplainer`, `calibrationVerifyBarLabel`,
  `calibrationSaveAction`, `calibrationCancelAction`, `calibrationImplausible` (ICU, one
  `{screenWidthCm}` placeholder), `calibrationTooSmallScreen`.
- Tests: `app/test/ui/ruler/calibration_screen_test.dart`,
  `app/test/ui/ruler/calibration_viewmodel_test.dart`.

## Why it is built this way

**1 — The handle sets one edge and the other edge is fixed.** The procedure in
`ruler-and-calibration.md` is a straight line: card flat against the fixed start edge, one draggable
handle at the far edge, `pxPerMm = cardWidthPx / kId1WidthMm`. *Rejected:* two draggable handles, and
pinch-to-zoom as the primary gesture. Two handles double the error sources for no gain, and a pinch
on a wet screen with a card held down by one thumb is not a gesture a fisher can complete.
`SPEC.md` §6 S4 says "pinch/drag to fit"; the drag is the mechanism and a pinch, if it is added at
all, resolves through the same `dragTo` command and the same transform. The handle is **drag-only,
never tap-to-place** — a ghost touch from a wet screen must not move a saved calibration.

**2 — This screen is landscape, and it has to be.** 85.60 mm at the nominal 6.299 logical px/mm is
**539 logical px**. The widest current phone is about 412 dp across in portrait, and even at the
band's 4.50 px/mm floor the card is 385 px. The card therefore does not fit across any phone held
upright, and calibration is a landscape procedure in practice. S4 uses the same orientation allowance
T07 wires for S3, and lays out from `LayoutBuilder` constraints so it is correct either way. When the
longest available edge is under `kId1WidthMm * kMinPxPerMm` the screen renders
`calibrationTooSmallScreen` and offers no handle at all — the "screen smaller than the card" row of
the skill's manual-entry table, where the ruler is disabled and manual entry stays live.

**3 — Verify is a 50 mm bar and not a 53.98 mm one.** `SPEC.md` §6 S4 asks for a 50 mm bar checked
against the card's **short edge**, which is 53.98 mm. That 3.98 mm difference is the point: a bar
exactly as long as the edge cannot be told apart from a bar 4% wrong, whereas a bar that should stop
a visible sliver short of the edge fails obviously when the scale is off. At a correct calibration the
bar ends 3.98 mm short; an 8% error moves that gap to either 0 mm or 8 mm, both of which a fisher can
see without instruments. *Rejected:* verifying against the long edge (the card is already fitted to
it, so the check would be circular) and printing a numeric confirmation only (a number cannot be
checked against a physical object).

**4 — The readout states mm-per-pixel and its consequence.** `SPEC.md` §6 S4 specifies a live
mm-per-pixel readout, so it is there. On its own it is meaningless to the user, so the same line also
states the implied physical width of the screen — which is the quantity a human can sanity-check, and
which the rejection message already uses ("That width would make the screen 34 cm wide"). Both come
from one ICU message; the stored value remains `pxPerMm`, and the reciprocal is display-only.

**5 — The rejection is a statement, and it never falls back.** Invariant 2 binds this screen as
firmly as it binds a verdict: the copy states what was measured and what it would imply, and it never
tells the fisher what to do. Note that **`Return` is in the banned lexicon**
(`product-invariants.md` §2), so the cancel affordance is `calibrationCancelAction` — "Cancel" — and
never "Return". On rejection nothing is written; the previously saved calibration reads back
unchanged, which is asserted here at the widget layer as well as at the repository layer in T01.

**6 — The outline is a painter, not a stack of `Container`s.** It needs a 3.18 mm corner radius that
scales with the live handle position; that is `Canvas.drawRRect` with a computed radius, not a
`BorderRadius` (which would in any case breach the radius ceiling of 2 —
`check_lonja_tokens.sh` check 4 counts `Radius.circular` outside `lib/theme/`, so the painter's
`Radius.circular(kId1CornerRadiusMm * pxPerMm)` needs the `// lonja-token-ok` hatch with a comment
saying it is a physical dimension in millimetres, not a design radius). The painter takes a
`LonjaTokens` snapshot in its constructor per `lonja-design-tokens` rule 12, and the file must not
mention `BuildContext` at all — check 8 greps the identifier itself, not just `Theme.of`.

## Tests first

Write every row before touching `calibration_screen.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `CalibrationViewModel.dragTo publishes the dragged width` | drag to 539.2 px | `state.handleWidthPx` is 539.2 | The one intent method the gesture calls; a handler that mutated state directly would pass a widget test and fail review |
| 2 | `CalibrationViewModel.dragTo clamps to the surface width` | drag to 5000 px on a 915 px surface | `handleWidthPx` is 915 | `gestures-and-semantics.md`: an axis-locked drag is a clamp snapshotted at drag-start, never per-frame collision |
| 3 | `CalibrationViewModel.dragTo clamps at zero` | drag to -40 px | `handleWidthPx` is 0 | A drag that crosses the origin must not produce a negative scale |
| 4 | `CalibrationViewModel.save stores an accepted calibration` | width 539.2 px | `FakeCalibrationRepository.saveCount` is 1 | The single write path |
| 5 | `CalibrationViewModel.save stores nothing when the scale is implausible` | width 384 px | `saveCount` is 0, `lastOutcome` is `CalibrationImplausible` | T01's contract, proved at the layer the user actually touches |
| 6 | `CalibrationViewModel.save leaves a previous calibration intact when rejected` | seed 6.31, then save 384 px | the repository still reads 6.31 | "Previous survives" is the whole reason the band exists |
| 7 | `CalibrationScreen shows the live mm-per-pixel readout while dragging` | drag to 539.2 px | the readout text contains the mm-per-pixel figure for 6.299 | `SPEC.md` §6 S4 names this element explicitly |
| 8 | `CalibrationScreen renders the verify bar at 50 mm of the measured scale` | accepted 6.299, tap through to verify | the bar's `getSize().width` is `50 * 6.299` within 0.5 px | The verify step is only a check if the bar is drawn at the scale being verified |
| 9 | `CalibrationScreen states the implied screen width when the scale is rejected` | width 384 px, save | the rejection sentence is present and names a width in cm | Invariant 2: a statement of fact, with the number that makes it checkable |
| 10 | `CalibrationScreen offers no handle when the surface is narrower than the card at 4.50 px/mm` | 360 dp surface | `calibrationTooSmallScreen` shown, no drag target | The skill's "screen smaller than the card" row; the alternative is a handle that cannot reach a valid value |
| 11 | `CalibrationScreen exposes the handle as a labelled slider-like node` | default | `isSemantics(label: …, hasEnabledState: true, isEnabled: true)` on the handle | `accessibility-as-code` rule 1; a raw `GestureDetector` locks out every switch and screen-reader user |
| 12 | `glove - CalibrationScreen sizes the handle at the glove target` | glove density on | handle `getSize()` clears the SPEC §4.9 glove floor of 56 dp | Wet gloves are the operating condition; the value comes from the theme, never a literal |
| 13 | `CalibrationScreen meets androidTapTargetGuideline` | default | `await expectLater(tester, meetsGuideline(androidTapTargetGuideline))` | Advisory tripwire only — the explicit `getSize` assertion in row 12 is the gate |
| 14 | `RTL - CalibrationScreen keeps the card's fixed edge at the same physical edge as in LTR` | pump in `ar` and in `en` | the fixed edge's `getRect().left` is equal in both | The instrument does not mirror; T04 owns the exception and its comment, this row guards the calibration surface |
| 15 | `CardOutlinePainter.shouldRepaint returns false for an equal scene` | two equal scenes | `false` | `custom-canvas-and-gestures` rule 2: `=> true` repaints every frame of a 60 fps drag |
| 16 | `CardOutlinePainter.shouldRepaint returns true when the token snapshot changes` | night vs paper tokens | `true` | A theme switch must repaint; the snapshot is what makes that provable |

```dart
// app/test/ui/ruler/calibration_viewmodel_test.dart
import 'package:catchlaw/domain/models/id1_card.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:catchlaw/ui/ruler/view_models/calibration_viewmodel.dart';
import 'package:catchlaw/testing/fakes/fake_calibration_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CalibrationViewModel.save stores nothing when the scale is implausible',
      () async {
    final repository = FakeCalibrationRepository()
      ..stored = RulerCalibration(
          pxPerMm: 6.31, capturedOn: DateTime.utc(2026, 7, 2));
    final container = ProviderContainer(overrides: [
      calibrationRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);

    final viewModel = container.read(calibrationViewModelProvider.notifier)
      ..dragTo(kId1WidthMm * 4.486); // below the 4.50 floor
    await viewModel.save();

    expect(repository.saveCount, 0);
    expect(repository.stored!.pxPerMm, 6.31); // untouched
    expect(container.read(calibrationViewModelProvider).lastOutcome,
        isA<CalibrationImplausible>());
  });
}
```

```dart
// app/test/ui/ruler/calibration_screen_test.dart
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  testWidgets('CalibrationScreen renders the verify bar at 50 mm of the '
      'measured scale', (tester) async {
    tester.useDevice(Device.mediumLandscape);
    await tester.pumpCalibration(handleWidthPx: 539.2); // 6.299 px/mm
    await tester.tap(find.bySemanticsLabel(RegExp('Verify')));
    await tester.pump();

    final bar = tester.getSize(find.byKey(const ValueKey('verify_bar_50mm')));
    expect(bar.width, moreOrLessEquals(50 * 6.299, epsilon: 0.5));
  });

  testWidgets('RTL - CalibrationScreen keeps the card\'s fixed edge at the '
      'same physical edge as in LTR', (tester) async {
    tester.useDevice(Device.mediumLandscape);
    await tester.pumpCalibration(locale: const Locale('en'));
    final ltr = tester.getRect(find.byKey(const ValueKey('card_fixed_edge')));
    await tester.pumpCalibration(locale: const Locale('ar'));
    final rtl = tester.getRect(find.byKey(const ValueKey('card_fixed_edge')));

    expect(rtl.left, moreOrLessEquals(ltr.left, epsilon: 0.5));
  });
}
```

**Run:** `cd app && flutter test test/ui/ruler` → 16 failures. If row 15 passes before the painter
exists, the test is wrong.

## Implementation outline

1. Extend `app/test/support/harness.dart` (E07's, if it exists; otherwise create it per
   `widget-golden-and-a11y-testing`) with a `Device.mediumLandscape` preset — 915 × 412 logical at
   DPR 2.625 — and a `pumpCalibration` helper that overrides `calibrationRepositoryProvider`.
   `physicalSize` is **physical** pixels: multiply the logical size by the DPR, and
   `addTearDown(view.reset)`.
2. `CalibrationState` as an immutable value type with `==`; `CalibrationViewModel extends
   Notifier<CalibrationState>` reading `calibrationRepositoryProvider` and
   `calibrateRulerUseCaseProvider`. Every mutation assigns a new value.
3. `CardOutlineScene` (`@immutable`, `==` over every field: `handleWidthPx`, `surfaceWidthPx`,
   `tokens`, `strokePx`) and `CardOutlinePainter`, drawing a `RRect` from the start edge to
   `handleWidthPx` with radius `kId1CornerRadiusMm * pxPerMm`. `shouldRepaint` is `old.scene != scene`.
4. `CalibrationScreen`: `LayoutBuilder` → if `constraints.maxWidth < kId1WidthMm * kMinPxPerMm`,
   render `_TooSmall`; else `RepaintBoundary` → `ExcludeSemantics(CustomPaint(...))` with a sibling
   `Semantics` node carrying the handle's label and value, under `HitTestBehavior.opaque`.
5. The drag handler reads `DragUpdateDetails.localPosition` only, clamps against the bound
   snapshotted at `onPanStart`, and calls `ref.read(...notifier).dragTo(dx)`. Never `globalPosition`
   — check 4 of `check_painter_hygiene.sh` fails on it.
6. `_VerifyStep`: a `SizedBox(width: 50 * pxPerMm)` keyed `verify_bar_50mm`, with the explainer text
   and the Save action beneath it.
7. ARB: author `app_en.arb` first with `@description` and typed placeholders, then mirror into the
   other five with real translations and identical placeholder names. Re-read the copy against the
   banned lexicon before running the gate.
8. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 16 tests pass, and each failed first.
- [ ] No numeric literal sizes any control: every height and gap resolves through the theme symbol
      E07 published, and the assertions compare against `SPEC.md` §4.9's 48/56 dp floors.
- [ ] `card_outline_painter.dart` contains no `BuildContext`, no `Theme.of`, no `LonjaTokens.of`.
- [ ] Exactly one `// lonja-token-ok` in the diff, on the physical corner radius, with the reason on
      the same line.
- [ ] All six ARB files gained the same keys with identical placeholders, and no value contains a
      word from the invariant-2 lexicon (`Keep`, `Return`, `Release`, `Discard`, `Throw`, `Toss`,
      `Retain`).
- [ ] A rejected calibration writes nothing — asserted at the view model (row 5) and the repository
      (row 6).
- [ ] `flutter analyze` reports no `use_build_context_synchronously` in the save path.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
```

The `custom-canvas-and-gestures` plugin's `scripts/check_painter_hygiene.sh` is run against
`app/lib` as well. Note it **exits 0** on a missing directory rather than 2, so confirm it reported
scanned files before trusting a pass (`CONVENTIONS.md` §7).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(ruler): add S4 calibration with a live readout and a 50 mm verify bar

An ID-1 card is 539 logical pixels wide at the nominal scale, which is wider
than any phone in portrait, so the fit surface lays out from its constraints
and offers no handle at all below 385 px — the documented screen-smaller-than-
the-card case, where manual entry remains the path.

The verify bar is 50 mm against the card's 53.98 mm short edge on purpose: a
bar the same length as the edge cannot be told from a bar four percent wrong,
while one that should stop a visible sliver short fails visibly. A rejected
scale writes nothing and the previous calibration reads back unchanged; the
message states the width it would imply and never instructs.

Task: E09/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
