# E09/T05 — Step and mark

| | |
|---|---|
| **Epic** | E09 — Ruler and calibration |
| **Branch** | `epic/09-ruler` (shared) |
| **Commit** | `feat(ruler): add S3 with step-and-mark, a running total and a cancel that restores` |
| **Depends on** | T04 (`RulerView` is the instrument this screen hosts) |
| **Size** | M |
| **Spec** | `SPEC.md` §6 S3 (every element and the error state), §4.2 (step-and-mark row: up to 4 segments, running total, cancel restores previous), §4.9 (haptics, live region) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-measurement-ruler` | Rule 10 — `MeasurementDraft` accumulates in millimetres, the total is the only thing stored, and `cancel()` returns `committedMm`, never zero and never null |
| `state-management-riverpod` | One `Notifier` over one immutable value, private state mutated only through intent methods, derive-don't-store for the total |
| `custom-canvas-and-gestures` | The gesture is a pure translator: `localPosition` → the shared transform → a typed command → a notifier method, mutating nothing |
| `lonja-forms-and-controls` | Owns the stepper anatomy and the control target sizes the four mark-bar actions inherit |
| `accessibility-as-code` | The running total is a `liveRegion`; MARK and CANCEL are ≥ 44 dp single-tap targets with authored labels; the commit carries a haptic |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S3 | The element list: full-bleed ruler along the long edge, draggable end marker, live readout, method reminder with mini-diagram, Step and mark, Type instead, Recalibrate — plus the error state |
| `SPEC.md` | §4.2 "Step-and-mark" | Up to **4** segments, running total, cancel restores previous |
| `SPEC.md` | §4.9 | Haptics: distinct patterns for pass and fail; the result announced as a live region |
| `.claude/skills/catchlaw-measurement-ruler/references/ruler-and-calibration.md` | "Step-and-mark" | The six-row state machine: idle → marking → committed, with the trigger and effect of every transition |
| `.claude/skills/catchlaw-measurement-ruler/SKILL.md` | rules 3, 10, 11 | No figure without its method; cancel restores; rounding happens once, at capture |
| `.claude/skills/catchlaw-measurement-ruler/references/measurement-methods.md` | "Method mismatch matrix", "Edge cases" | The method rides on the rule row; a damaged caudal fin records no reading; a 3 m fish is a typo |
| `.claude/skills/custom-canvas-and-gestures/references/gestures-and-semantics.md` | "The gesture is a pure translator", "Axis-locked drag is a clamp" | Never `globalPosition`; snapshot the bound at drag-start and clamp; feedback fires once, on commit |
| `.claude/skills/lonja-forms-and-controls/references/control-anatomy.md` | "Targets and density", "Control inventory" | `LonjaStepper` anatomy and the control heights these actions inherit |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariant 2 lexicon | `Return` is a banned word: the cancel action is "Cancel", never "Return to the previous value" |
| `FLUTTER_GUIDE.md` | §5.2, §5.3 item 4 | The vertical slice, and bridging the notifier to a `Listenable` for the painter's `repaint:` instead of rebuilding the tree |
| `epics/E09-ruler/epic.md` | Risks 3 and 5 | Four segments do not reach a 650 mm Kanaad; the method enum may be shorter than the schema |

## What this delivers

- `app/lib/domain/models/measurement_draft.dart` — `MeasurementDraft`, `@immutable`, value equality:
  `List<int> segmentsMm`, `int? committedMm`, derived `int get totalMm`, and the four transitions
  `mark(int segmentMm)`, `undo()`, `cancel()`, `accept(MeasurementMethod)`.
- `app/lib/ui/ruler/view_models/ruler_viewmodel.dart` — `RulerViewModel extends Notifier<RulerState>`
  holding the draft, the calibration, the active rule row's method, and a `ValueNotifier<double>`
  cursor the painter takes as its `repaint:` listenable. Intent methods only: `dragTo`, `mark`,
  `undo`, `cancel`, `accept`.
- `app/lib/ui/ruler/widgets/ruler_screen.dart` — `RulerScreen` (S3) and its private
  `_RunningTotal`, `_MethodReminder`, `_SegmentStrip`, `_MarkBar` widget classes. Hosts `RulerView`
  (T04) and `MeasurementDiagram` (T04), and offers Type instead (wired in T06) and Recalibrate
  (→ T02's screen).
- ARB keys in all six locales: `rulerMarkAction`, `rulerUndoAction`, `rulerCancelAction`,
  `rulerAcceptAction`, `rulerRunningTotal` (ICU, `{value}` and `{method}`), `rulerSegmentCount`
  (ICU plural, all six categories in `ar`), `rulerSegmentCeiling`, `rulerNotCalibrated`.
- Tests: `app/test/domain/measurement_draft_test.dart`,
  `app/test/ui/ruler/ruler_viewmodel_test.dart`, `app/test/ui/ruler/ruler_screen_test.dart`.

## Why it is built this way

**Cancel restores; it does not clear.** This is the one behaviour in the epic most likely to be
written the obvious wrong way. `cancel()` returns a draft with `segmentsMm` empty and `committedMm`
**unchanged** — never zero, never null. Wet hands hit cancel by accident, and a cancel that wipes
380 mm of careful marking costs a measurement that cannot be retaken once the fish is in the bin.
*Rejected:* `cancel() => const MeasurementDraft()`, which is what the skill's anti-pattern list names
and what a reasonable person writes first.

**Four segments, and the ceiling is stated rather than discovered.** `SPEC.md` §4.2 caps step-and-mark
at four segments. `ruler-and-calibration.md` says the segment count is unbounded; **SPEC is
authoritative for the product**, so four it is, and a fifth MARK is *inert* — not an error state,
which is the same treatment the keypad gives a sixth digit. The arithmetic matters and belongs on
screen: a 915 dp landscape span at 6.299 px/mm is about 145 mm, so four segments reach roughly
580 mm, short of the 650 mm fork-length minimum for *Scomberomorus commerson* in AE-RK. When the
fourth segment is committed, `rulerSegmentCeiling` states the total the ruler can still reach and
points at manual entry (T06). A fisher must not find this out with a live Kanaad in his hands.

**The total is derived, never stored.** `totalMm` is `segmentsMm.fold(0, …)`; there is no second
field to drift. `state-management-riverpod` rule 4 and `value-objects-money-and-units` rule 8 say the
same thing for the same reason.

**The gesture decides nothing.** `onPanUpdate` reads `DragUpdateDetails.localPosition`, converts with
`calibration.millimetresFor` — the same transform T03's painter draws with — clamps against the bound
snapshotted at `onPanStart`, and calls `ref.read(rulerViewModelProvider.notifier).dragTo(mm)`. It
never mutates, never counts, never decides a segment is complete. *Rejected:* `globalPosition`
(check 4 of `check_painter_hygiene.sh` fails on it) and re-deriving the scale from `size` inside the
handler, which produces the "taps land three pixels off" class of bug — three pixels here is half a
millimetre of legal exposure.

**The drag does not rebuild the tree.** The live cursor is a `ValueNotifier<double>` handed to
`CustomPainter(repaint:)`, per `FLUTTER_GUIDE.md` §5.3 item 4, so a 60 fps drag repaints the canvas
without rebuilding a single widget. The committed segments *do* go through state, because they change
the running total, the segment strip and the semantics — three widgets, once per MARK.

**Every figure carries its method.** The running total renders through the formatter, never as
`'$totalMm mm'`. An unlabelled 65 cm is read as total length by a fisher whose rule means fork
length, and he lands a fish six centimetres short. The method comes from the **rule row**, not the
species — `rule.measurement_method_id` in `SPEC.md` §7.1 — and is passed into this screen. Before
assuming a diagram exists for it, read what E03 shipped (epic Risk 5).

**The reading is announced.** `_RunningTotal` is a `Semantics(liveRegion: true)` node so TalkBack
speaks each MARK without navigating, and `HapticFeedback.selectionClick()` fires once on commit —
from the intent method, never from `onPanUpdate` per-frame math. `SPEC.md` §4.9 asks for haptics that
work without looking, which is the actual operating condition.

## Tests first

Write every row before touching `measurement_draft.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `MeasurementDraft.totalMm sums its segments` | `[148, 150, 149, 92]` | `539` | The running total is the number that becomes the reading |
| 2 | `MeasurementDraft.totalMm is zero with no segments` | `[]` | `0` | The idle state, and the boundary a fold gets wrong first |
| 3 | `MeasurementDraft.mark appends a segment` | mark 148 on empty | `segmentsMm` is `[148]` | The core transition |
| 4 | `MeasurementDraft.mark is inert at the fourth segment` | mark five times | four segments, total unchanged by the fifth | `SPEC.md` §4.2's cap; inert, not an error, matching the keypad's treatment of a sixth digit |
| 5 | `MeasurementDraft.undo removes the last segment` | `[148, 150]`, undo | `[148]`, total `148` | The state machine's UNDO row |
| 6 | `MeasurementDraft.undo is inert with no segments` | `[]`, undo | `[]` | Double-tap on a wet screen must not throw |
| 7 | `MeasurementDraft.cancel restores committedMm over four segments` | `committedMm: 380`, four segments, cancel | `segmentsMm` empty, `committedMm` still `380` | The behaviour this task exists to get right; the skill's named anti-pattern |
| 8 | `MeasurementDraft.cancel keeps a null committedMm null` | `committedMm: null`, cancel | `null`, not `0` | Cancel never yields zero **and never yields null where a value existed** — both halves need a case |
| 9 | `MeasurementDraft.accept produces a Measurement carrying the rule's method` | total 539, method `fl` | `Measurement(lengthMm: 539, method: fl)` | Rule 3: no figure without its method, all the way into the value handed to the engine |
| 10 | `RulerViewModel.dragTo converts pixels with the stored calibration` | drag to 2834.6 px at 6.299 | live length is `450` mm | The one transform, shared with the painter |
| 11 | `RulerViewModel.mark commits the live length and returns the cursor to zero` | drag 148 mm, mark | segment `[148]`, cursor `0` | The MARK row of the state machine: the handle returns to zero so the next step starts from the mark |
| 12 | `RulerViewModel.dragTo clamps to the calibrated span` | drag past the surface | length equals the span in mm | An axis-locked drag is a clamp snapshotted at drag-start |
| 13 | `RulerScreen shows the running total with its measurement method` | two segments, method TL | the total text contains both the figure and the localised method label | An unlabelled figure is a defect, not a shortcut |
| 14 | `RulerScreen announces the running total as a live region` | after a MARK | `isSemantics(liveRegion: true, label: contains('298'))` | §4.9: TalkBack reads the finding without navigating |
| 15 | `RulerScreen states the segment ceiling after the fourth mark` | four marks | `rulerSegmentCeiling` is present | Risk 3 made visible before the fisher hits it |
| 16 | `RulerScreen offers manual entry when no calibration exists` | fake repository returns null | Type instead is present and enabled; the ruler is disabled with a one-line reason | The S3 error state, and the guarantee T06 completes |
| 17 | `glove - RulerScreen sizes MARK and CANCEL at the glove target` | glove density | both clear the `SPEC.md` §4.9 glove floor of 56 dp | Wet gloves at 05:40 are the operating condition |
| 18 | `RulerScreen fires one haptic per committed mark` | three marks | three `HapticFeedback` platform calls, none during the drag | Feedback fires on commit, never from per-frame drag math |

```dart
// app/test/domain/measurement_draft_test.dart
import 'package:catchlaw/domain/models/measurement_draft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show MeasurementMethod;

void main() {
  group('MeasurementDraft', () {
    test('.cancel restores committedMm over four segments', () {
      const draft = MeasurementDraft(
          segmentsMm: <int>[148, 150, 149, 92], committedMm: 380);
      final cancelled = draft.cancel();

      expect(cancelled.segmentsMm, isEmpty);
      expect(cancelled.committedMm, 380); // never 0, never null
    });

    test('.mark is inert at the fourth segment', () {
      var draft = const MeasurementDraft();
      for (final mm in <int>[148, 150, 149, 92, 100]) {
        draft = draft.mark(mm);
      }
      expect(draft.segmentsMm.length, 4);
      expect(draft.totalMm, 539);
    });

    test('.accept produces a Measurement carrying the rule\'s method', () {
      const draft = MeasurementDraft(segmentsMm: <int>[148, 150, 149, 92]);
      final measurement = draft.accept(MeasurementMethod.fl);

      expect(measurement.lengthMm, 539);
      expect(measurement.method, MeasurementMethod.fl);
    });
  });
}
```

```dart
// app/test/ui/ruler/ruler_screen_test.dart
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  testWidgets('RulerScreen offers manual entry when no calibration exists',
      (tester) async {
    tester.useDevice(Device.mediumLandscape);
    await tester.pumpRulerScreen(calibration: null); // virgin install

    expect(find.bySemanticsLabel(RegExp('Type')), findsOneWidget);
    final node = tester.getSemantics(find.byKey(const ValueKey('mark_action')));
    expect(node, isSemantics(hasEnabledState: true, isEnabled: false));
  });

  testWidgets('RulerScreen announces the running total as a live region',
      (tester) async {
    tester.useDevice(Device.mediumLandscape);
    await tester.pumpRulerScreen(calibration: kNominalCalibration);
    await tester.dragRulerTo(148);
    await tester.tap(find.byKey(const ValueKey('mark_action')));
    await tester.pump();
    await tester.dragRulerTo(150);
    await tester.tap(find.byKey(const ValueKey('mark_action')));
    await tester.pump();

    expect(tester.getSemantics(find.byKey(const ValueKey('running_total'))),
        isSemantics(liveRegion: true, label: contains('298')));
  });
}
```

**Run:** `cd app && flutter test test/domain/measurement_draft_test.dart test/ui/ruler`
→ 18 failures. Row 7 in particular must fail: if it passes before `cancel()` exists, the harness is
constructing the draft wrong.

## Implementation outline

1. `measurement_draft.dart`: const constructor with `segmentsMm = const []`; every transition returns
   a **new** instance (`state-management-riverpod` rule 3). `mark` returns `this` when
   `segmentsMm.length == 4`.
2. `RulerState`: an immutable value type holding `draft`, `calibration`, `method`, `spanPx` and
   `liveLengthMm`, with `==`.
3. `RulerViewModel`: reads `calibrationRepositoryProvider`; owns a `ValueNotifier<double> cursorPx`
   released in `ref.onDispose`. `dragTo` writes the cursor **and** `liveLengthMm`; only the latter
   goes through `state`, and only the widgets that need it watch it with `.select`.
4. `RulerScreen`: `LayoutBuilder` for the span; `RulerView` under it; `_MarkBar` with the four
   actions; `_SegmentStrip` listing committed segments so the fisher can see what UNDO will remove.
   Each action is a private widget class, never a `Widget _buildMarkButton()` (`FLUTTER_GUIDE.md`
   §8.1).
5. Haptic: `HapticFeedback.selectionClick()` inside `mark()` and `accept()`; assert it in a test with
   a `TestDefaultBinaryMessengerBinding` handler counting `HapticFeedback.vibrate` calls on
   `SystemChannels.platform`.
6. ARB: `rulerSegmentCount` is a plural and `app_ar.arb` must carry all six CLDR categories
   (`zero`, `one`, `two`, `few`, `many`, `other`) or CI fails — `SPEC.md` §14 and §9.5.
7. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 tests pass, and each failed first.
- [ ] Branch coverage on `measurement_draft.dart` is 100% — a cancel that loses a reading is
      unrecoverable at sea, which is `testing-strategy` rule 9's exact criterion.
- [ ] No figure is rendered anywhere in the diff without its method label.
- [ ] The drag path contains no `globalPosition` and no scale re-derived from `size`.
- [ ] `app_ar.arb`'s `rulerSegmentCount` has all six plural categories; all six ARB files carry the
      same keys; no value contains `Return`, `Keep` or any other invariant-2 imperative.
- [ ] The running total, MARK and CANCEL each read a target size from the theme symbol E07 published,
      and the assertions compare against `SPEC.md` §4.9's floors.
- [ ] `ref.onDispose` releases the cursor `ValueNotifier`.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
```

Plus the `custom-canvas-and-gestures` plugin's `scripts/check_painter_hygiene.sh` against `app/lib`
— check 4 is the one that matters here.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(ruler): add S3 with step-and-mark, a running total and a cancel that restores

cancel() clears the segments and leaves committedMm untouched — never zero,
never null. Wet hands hit cancel by accident, and a cancel that wipes 380 mm of
careful marking costs a measurement nobody can retake once the fish is in the
bin.

The segment cap is four, per SPEC 4.2, and the ceiling is stated on screen
rather than discovered: 145 mm of landscape scale times four segments reaches
about 580 mm, short of the 650 mm fork-length minimum for Scomberomorus
commerson in AE-RK. For the large pelagics the keypad is the path, not a
fallback.

The live cursor is a ValueNotifier handed to CustomPainter(repaint:), so a
60 fps drag repaints the canvas without rebuilding a widget; only a committed
mark goes through state, because only that changes the total, the strip and the
announcement.

Task: E09/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
