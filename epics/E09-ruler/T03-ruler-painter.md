# E09/T03 — `RulerPainter`

| | |
|---|---|
| **Epic** | E09 — Ruler and calibration |
| **Branch** | `epic/09-ruler` (shared) |
| **Commit** | `feat(ruler): draw the scale from an immutable RulerScene with no allocation in paint()` |
| **Depends on** | T01 (`RulerCalibration.pixelsForMillimetres` is the transform the painter draws with) |
| **Size** | L |
| **Spec** | `SPEC.md` §6 S3 (full-bleed ruler along the long edge), §13 (low-end devices, frame budget), §4.2 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `custom-canvas-and-gestures` | The whole architecture of this task: View/Painter/Scene, `shouldRepaint` as one value compare, the two-path repaint pitfall, zero-allocation `paint()`, `ExcludeSemantics` |
| `catchlaw-measurement-ruler` | Rules 5 and 6: the painter has no `BuildContext`, `labelDirection` is a constructor field compared in `shouldRepaint`, and mirroring — if it ever happens — is `canvas.scale(-1, 1)` with glyphs after `restore()` |
| `lonja-design-tokens` | Rule 12 — the painter takes a `LonjaTokens` snapshot; and rule 5, which is why a physical hairline is not a fifth rule weight |
| `accessibility-as-code` | A canvas is opaque to TalkBack: the painted surface is excluded and a sibling node speaks the reading |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `FLUTTER_GUIDE.md` | §8.3 | `Directionality` does not reach a `CustomPainter`; pass `textDirection` in and include it in `shouldRepaint`; cache `Paint` and `TextPainter`; drive repaints via `repaint:` |
| `FLUTTER_GUIDE.md` | §5.3 item 4 | "For the ruler specifically: don't drive the painter from a rebuild at all" — bridge to a `Listenable` and pass it as `repaint:` |
| `FLUTTER_GUIDE.md` | §8.1 | Why the View is a widget class and not a `Widget _buildRuler()` helper |
| `.claude/skills/custom-canvas-and-gestures/references/painter-and-scene.md` | "The View / Painter / Scene split", "The two-path repaint pitfall", "Zero-allocation paint()" | The collaborator table, the config-path vs animation-path rule, and what may be hoisted |
| `.claude/skills/custom-canvas-and-gestures/references/text-and-shapes.md` | "True hairlines", "Physical-pixel snapping" | `1.0 / devicePixelRatio` for a real hairline, and snapping so a 1 px line does not straddle two device pixels |
| `.claude/skills/catchlaw-measurement-ruler/examples/ruler_painter.dart` | whole file | The worked shape: `Float32List` tick vertices, constructor-built `TextPainter`s, `shouldRepaint` over every field. Two deliberate divergences are named below |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | rule weights, radii, tier-2 slots | `LonjaRules.hair/rule/strong`, `LonjaRadii.hair` (2, "chips and the ruler thumb only"), and the slot names the scene snapshots |
| `.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh` | checks 6, 7, 8 | Check 8 greps the identifier `BuildContext` inside `*_painter.dart`; check 7 bans `fontSize:` outside `lib/theme/`, so the label `TextStyle` arrives on the scene |
| `epics/DECISIONS.md` | D-2 | Why the tokens live at `app/lib/theme/` and the painter therefore cannot be exempted by the `/theme/` path fragment |

## What this delivers

- `app/lib/ui/ruler/widgets/ruler_scene.dart` — `RulerScene`, `@immutable`, value equality over every
  field: `pxPerMm`, `spanPx`, `tickLabels` (`List<String>`, one per centimetre, already formatted),
  `labelDirection`, `labelStyle` (`TextStyle`, snapshotted from the theme), `ink`, `mark`,
  `hairlinePx`, `tickPx`, `cursorPx` (stroke widths, already resolved in device-pixel terms).
- `app/lib/ui/ruler/widgets/ruler_painter.dart` — `RulerPainter extends CustomPainter`. Constructor
  builds the `Paint`s, the `Float32List` of tick vertices and every label `TextPainter`; `paint()`
  allocates nothing; `shouldRepaint` is `old.scene != scene`. The moving cursor arrives through
  `repaint:` as a `ValueListenable<double>` and is drawn from a pre-allocated 4-element buffer.
- `app/test/ui/ruler/ruler_scene_test.dart` and `app/test/ui/ruler/ruler_painter_test.dart` — the unit
  half. The `paints`-matcher half is T08.

No widget, no screen, no gesture. The `RulerView` that pins direction is T04; the screen that hosts
it is T05.

## Why it is built this way

**A dumb painter with one input.** The Scene is the painter's entire input and a value type, which is
what makes `shouldRepaint` a single cheap compare and what lets T08 golden the painter by
constructing a Scene with no app wiring. `=> true` repaints every frame even when idle;
`check_painter_hygiene.sh` fails on it outright. *Rejected:* a painter holding the notifier or the
calibration and deciding what to draw — `painter-and-scene.md` forbids a `Notifier`, a `BuildContext`,
a `DateTime` or a domain rule inside the painter, and every one of those makes the repaint question
unanswerable.

**The scale is drawn from T01's transform, not from a second derivation.** Tick *n* sits at
`calibration.pixelsForMillimetres(n)`, and the drag handler in T05 converts back with
`millimetresFor`. That is `custom-canvas-and-gestures` rule 3 — one mapping, both directions, exact
inverses, never re-derived from `size`. The single most corrosive defect in a hand-painted surface is
a painter and a hit-tester that disagree by three pixels; here that would be a reading three pixels
short of a legal minimum.

**Two deliberate divergences from `examples/ruler_painter.dart`, both with reasons.**

- *The example shapes Arabic-Indic digits from a private `_ar` map.* This painter does not. Numerals
  are the user's setting: `SPEC.md` §9.3 makes the numeral system a S14 preference implemented by
  swapping `numberFormatSymbols` at bootstrap, and a private digit map cannot honour that. Labels are
  formatted **upstream** with the app's `NumberFormat` and arrive on the Scene as finished strings,
  which is also `custom-canvas-and-gestures` rule 9 — canonical in, display out, never shape numerals
  inside `paint()`. T04 owns the formatter wiring.
- *The example paints the live readout on the canvas.* This painter does not. The readout string
  changes on every frame of a drag, so painting it means re-laying-out a `TextPainter` per frame —
  precisely the allocation the zero-allocation rule exists to prevent — and a canvas glyph cannot be a
  `liveRegion`. The readout is a sibling `Text` widget (T05), which screen readers can announce and
  which `accessibility-as-code` requires anyway.

**The moving cursor goes through `repaint:`, not through the Scene.** `painter-and-scene.md` names
this the two-path pitfall: put the animated value in the Scene *and* drive it through `repaint:` and
you double-repaint; put it only in the Scene and every drag frame rebuilds the widget tree.
`FLUTTER_GUIDE.md` §5.3 item 4 says the same thing about this exact painter. So the Scene carries the
static description and a `ValueListenable<double> cursorPx` carries the motion; `paint()` reads
`cursorPx.value`, writes it into a `Float32List(4)` field and draws. Mutating a pre-allocated buffer
is not an allocation.

**Stroke widths arrive already resolved.** A true hairline is one *physical* pixel —
`1.0 / devicePixelRatioOf(context)` — and the painter has no context to read it from, so the View
computes it and puts it on the Scene. This is not a fifth Lonja rule weight: check 6 of
`check_lonja_tokens.sh` is scoped to `BorderSide`/`Border.all`/`Divider` widths, and the four named
weights are logical-pixel *document* rules. A millimetre tick is a physical instrument mark, and the
whole point of the epic is that its geometry is physical. The distinction is documented in a comment
on the field so the next reader does not "fix" it.

**Ticks are one draw call.** `drawRawPoints(PointMode.lines, …)` over a `Float32List` built in the
constructor draws all ~145 millimetre ticks in one pass with zero per-frame allocation, instead of 145
`drawLine` calls each allocating two `Offset`s. On the 2 GB Android 7 device `SPEC.md` §13 names, that
difference is a young-generation GC mid-drag. The consequence for T08 is real and stated there:
`paints..line(...)` will not match a `drawRawPoints` call, so the matcher tests use
`something`/`everything` predicates.

## Tests first

Write every row before touching `ruler_painter.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `RulerScene compares equal field by field` | two identical scenes | `==` true, equal `hashCode` | `shouldRepaint` is one value compare; without this the ruler either never repaints or always does |
| 2 | `RulerScene compares unequal when a tick label changes` | same scene, `tickLabels[3]` differs | `==` false | `List.==` is identity, so the scene must compare contents or a numeral-system switch never repaints |
| 3 | `RulerScene compares unequal when labelDirection changes` | ltr vs rtl | `==` false | The skill's rule 5 failure: omit it and Arabic labels keep Latin shaping until an unrelated rebuild clears them |
| 4 | `RulerPainter.shouldRepaint returns false for an equal scene` | two equal scenes | `false` | The 60 fps drag budget |
| 5 | `RulerPainter.shouldRepaint returns true when pxPerMm changes` | 6.299 vs 6.31 | `true` | A recalibration must redraw every tick |
| 6 | `RulerPainter.shouldRepaint returns true when the token snapshot changes` | paper vs night tokens | `true` | Theme switch; the snapshot is what makes it provable |
| 7 | `RulerPainter builds one tick vertex pair per millimetre of span` | span 915 px at 6.299 | 146 vertex pairs (`floor(915 / 6.299) + 1`) | The tick count is the scale; an off-by-one here is a missing millimetre at the end of the ruler |
| 8 | `RulerPainter places the decade tick at ten times the millimetre pitch` | pxPerMm 6.299 | vertex x for mm 10 is `10 * 6.299` within 1e-9 | The centimetre marks are what a fisher reads; they must land on T01's transform, not on a rounded pitch |
| 9 | `RulerPainter draws a longer stroke on every tenth tick` | default | the mm-10 vertex y exceeds the mm-1 vertex y | Legibility at arm's length; also the only way to tell 4 cm from 5 cm through spray |
| 10 | `RulerPainter builds one label per centimetre of span` | span 915 px at 6.299 | 15 `TextPainter`s | 145 mm of scale is 14 whole centimetres plus zero |
| 11 | `RulerPainter lays every label out in its constructor` | after construction, before `paint` | every label `TextPainter.width` is greater than zero | Proves the layout happened once; a `layout()` inside `paint()` is the classic jank source |
| 12 | `RulerPainter paints identical invocations on two consecutive frames with an unchanged cursor` | record twice | the two recorded invocation lists are equal | The closest a `flutter_test` can get to "allocates nothing" — it proves nothing is rebuilt per frame |
| 13 | `RulerPainter moves the cursor when the listenable changes without a new scene` | set `cursorPx.value` | the recorded cursor x changes, `shouldRepaint` was never consulted | The two-path rule: motion goes through `repaint:`, configuration through `shouldRepaint` |
| 14 | `RulerPainter contains no Matrix4 rotation` | source grep in the test | no match | `catchlaw-measurement-ruler` rule 6 and check 4 of `check_measurement.sh`; a Y-rotation is a 3-D transform on a 2-D canvas and ships every glyph backwards |

```dart
// app/test/ui/ruler/ruler_painter_test.dart
import 'package:catchlaw/ui/ruler/widgets/ruler_painter.dart';
import 'package:catchlaw/ui/ruler/widgets/ruler_scene.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/scenes.dart'; // kRulerSceneNominal, tokens fixtures

void main() {
  group('RulerPainter', () {
    test('.shouldRepaint returns false for an equal scene', () {
      final cursor = ValueNotifier<double>(0);
      addTearDown(cursor.dispose);
      final a = RulerPainter(kRulerSceneNominal, cursorPx: cursor);
      final b = RulerPainter(kRulerSceneNominal, cursorPx: cursor);
      expect(b.shouldRepaint(a), isFalse);
    });

    test('.shouldRepaint returns true when pxPerMm changes', () {
      final cursor = ValueNotifier<double>(0);
      addTearDown(cursor.dispose);
      final a = RulerPainter(kRulerSceneNominal, cursorPx: cursor);
      final b = RulerPainter(
          kRulerSceneNominal.copyWith(pxPerMm: 6.31), cursorPx: cursor);
      expect(b.shouldRepaint(a), isTrue);
    });

    test('builds one tick vertex pair per millimetre of span', () {
      final cursor = ValueNotifier<double>(0);
      addTearDown(cursor.dispose);
      final painter = RulerPainter(kRulerSceneNominal, cursorPx: cursor);
      // spanPx 915 at 6.299 px/mm -> floor(145.26) + 1 = 146 ticks, 4 floats each.
      expect(painter.debugTickVertices.length, 146 * 4);
    });

    test('places the decade tick at ten times the millimetre pitch', () {
      final cursor = ValueNotifier<double>(0);
      addTearDown(cursor.dispose);
      final painter = RulerPainter(kRulerSceneNominal, cursorPx: cursor);
      expect(painter.debugTickVertices[10 * 4],
          moreOrLessEquals(10 * 6.299, epsilon: 1e-9));
    });
  });
}
```

```dart
// app/test/ui/ruler/ruler_scene_test.dart
import 'package:catchlaw/ui/ruler/widgets/ruler_scene.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/scenes.dart';

void main() {
  group('RulerScene', () {
    test('compares unequal when a tick label changes', () {
      final other = kRulerSceneNominal.copyWith(
          tickLabels: <String>[...kRulerSceneNominal.tickLabels]..[3] = '٣');
      expect(other == kRulerSceneNominal, isFalse);
    });

    test('compares unequal when labelDirection changes', () {
      expect(
          kRulerSceneNominal.copyWith(labelDirection: TextDirection.rtl) ==
              kRulerSceneNominal,
          isFalse);
    });
  });
}
```

**Run:** `cd app && flutter test test/ui/ruler/ruler_painter_test.dart test/ui/ruler/ruler_scene_test.dart`
→ 14 failures. If row 4 passes before `shouldRepaint` exists, the test is wrong.

## Implementation outline

1. `app/test/support/scenes.dart` (a helper, **not** `_test.dart`): `kRulerSceneNominal` at
   `pxPerMm: 6.299`, `spanPx: 915`, fifteen Latin tick labels, a paper-theme token snapshot.
   Fixture constants are `k`-prefixed (`CONVENTIONS.md` §6).
2. `ruler_scene.dart`: `@immutable final class RulerScene` with a const constructor, `copyWith`,
   `operator ==` (using `listEquals` for `tickLabels`) and `hashCode` (`Object.hash` with
   `Object.hashAll(tickLabels)`).
3. `ruler_painter.dart`: constructor takes `(RulerScene scene, {required ValueListenable<double>
   cursorPx})` and passes `cursorPx` to `super(repaint: cursorPx)`. In the initialiser list build
   `_tickPaint`, `_cursorPaint` and `_tickVertices`; in the body lay out the label `TextPainter`s and
   their origins. Expose `debugTickVertices` as `@visibleForTesting`.
4. `paint()`: `drawRawPoints(PointMode.lines, _tickVertices, _tickPaint)`, then write
   `cursorPx.value` into `_cursorVertices[0]`/`[2]` and draw it, then paint the label
   `TextPainter`s. No `Paint()`, no `Path()`, no string, no closure inside the method.
5. `shouldRepaint(RulerPainter old) => old.scene != scene;` — one line, nothing else.
6. Snap the cursor x to the physical grid before drawing, per `text-and-shapes.md`, so a one-pixel
   cursor does not straddle two device pixels and blur under a wet thumb.
7. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 14 tests pass, and each failed first.
- [ ] `ruler_painter.dart` contains none of: `BuildContext`, `Theme.of`, `LonjaTokens.of`,
      `Directionality`, `MediaQuery`, `Matrix4`, `DateTime`, `Color(0x`, `fontSize:`.
- [ ] `paint()` contains no `Paint(`, `Path(`, `TextPainter(`, `Offset(`, string interpolation or
      closure — verified by reading the method, which is short enough to read.
- [ ] `shouldRepaint` is exactly `old.scene != scene`.
- [ ] Every drawing colour and stroke width came from the Scene, and every one of those came from a
      `LonjaTokens` slot or a device-pixel computation in the View.
- [ ] `check_lonja_tokens.sh app/lib` check 8 is clean, and `check_measurement.sh app/lib` checks 3
      and 4 are clean.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
```

Plus the `custom-canvas-and-gestures` plugin's `scripts/check_painter_hygiene.sh` against `app/lib`;
confirm it names the files it scanned, because it exits 0 rather than 2 on a missing directory.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(ruler): draw the scale from an immutable RulerScene with no allocation in paint()

The painter is dumb: one immutable Scene in, pixels out, shouldRepaint a single
value compare. Ticks are one drawRawPoints call over a Float32List built in the
constructor rather than 145 drawLine calls allocating two Offsets each, which
on the 2 GB Android 7 target is the difference between a smooth drag and a
young-gen GC mid-frame.

Two deliberate divergences from the skill's worked example, both because the
example predates the constraint. Tick numerals are formatted upstream through
the app's NumberFormat instead of a private Arabic-Indic map, because SPEC 9.3
makes the numeral system a Settings preference that a private map cannot
honour. The live readout is a sibling Text rather than a canvas glyph, because
it changes every drag frame and because a screen reader cannot announce a
painted number.

Task: E09/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
