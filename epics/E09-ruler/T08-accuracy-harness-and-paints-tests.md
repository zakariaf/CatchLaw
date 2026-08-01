# E09/T08 — The accuracy harness and the paints tests

| | |
|---|---|
| **Epic** | E09 — Ruler and calibration |
| **Branch** | `epic/09-ruler` (shared) |
| **Commit** | `test(ruler): add the accuracy harness and paints-matcher coverage for the scale` |
| **Depends on** | T03 (the painter under test), T07 (the harness measures the finished screen) |
| **Size** | L |
| **Spec** | `SPEC.md` §16 R3 (the one-day test and its pass bar), §4.2 (±1.5 mm over 15 cm), §15 step 7 ("validate against a printed scale on three physical devices before proceeding") |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-measurement-ruler` | Rule 12 — accuracy is measured on real devices and never asserted, with the budget and the device matrix this task fills in |
| `testing-strategy` | Rule 3 (round-trip and boundary goldens, seeded fuzz against an independent oracle) and rule 11 (a structurally-untestable path goes into a named manual pass, never faked green) |
| `widget-golden-and-a11y-testing` | The `paints` tier, the harness that pins the device, and why a layout golden is not the gate |
| `custom-canvas-and-gestures` | What the painter promises, so the matcher tests assert the promise rather than the implementation |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §16 R3 | The protocol and the bar: six phones from cheap Android to current iPhone, a printed 300 mm engineering scale, ten readings per device, **median absolute error ≤ 1.5 mm over 150 mm, no device worse than 3 mm** |
| `SPEC.md` | §4.2 "On-screen ruler" | "Within ±1.5 mm over 15 cm on a calibrated device" — the acceptance condition this task instruments |
| `SPEC.md` | §15 step 7 | The instruction to validate on three physical devices *before proceeding* to the result UI |
| `.claude/skills/catchlaw-measurement-ruler/references/ruler-and-calibration.md` | "Accuracy budget", "Failure modes seen in the field" | The four-row budget table, the protocol, the empty device matrix to fill, and the four field failure modes that explain outliers |
| `.claude/skills/catchlaw-measurement-ruler/SKILL.md` | rule 12 and the definition of done | Results recorded with device, OS and date; a release with an empty matrix does not ship the ruler tab |
| `FLUTTER_GUIDE.md` | §6.4 "The budget" | "Widget — one per screen + `paints` matcher tests for the painter" — this task is that line |
| `FLUTTER_GUIDE.md` | §6.2, §6.3 | Helpers must not end in `_test.dart`; goldens live beside their test; `golden_toolkit` is dead |
| `.claude/skills/widget-golden-and-a11y-testing/SKILL.md` | rules 1, 2, 8, 11 | Pin the device, `physicalSize` is physical pixels, prefer computed geometry, and the two golden lanes |
| `.claude/skills/testing-strategy/SKILL.md` | rules 3, 8, 11 | Seeded fuzz with the input echoed in `reason:`; one acceptance gate; the named manual pass |
| `epics/E09-ruler/epic.md` | Risk 1 | Why this task cannot, by itself, prove ±1.5 mm — and what it can prove |

## What this delivers

- `app/testing/measurement/accuracy_stats.dart` — pure Dart, no Flutter import:
  `int medianAbsoluteErrorMm(List<int> readingsMm, {required int referenceMm})`,
  `int worstAbsoluteErrorMm(...)`, `int spreadMm(List<int>)`. A helper, not a `_test.dart` file.
- `app/test/testing/accuracy_stats_test.dart` — unit tests for the statistics, including the
  even-count median and the single-reading case.
- `app/integration_test/ruler_accuracy_test.dart` — the on-device harness. It pins a calibration,
  renders S3 at a known span, drives the marker to a set of known pixel offsets, and asserts the
  millimetres read back are exact. It then prints a copy-pasteable matrix row for the device it ran
  on.
- `app/test/ui/ruler/ruler_painter_paints_test.dart` — the `paints`-matcher coverage: what is drawn,
  in what order, and what is *not* drawn.
- No new documentation file: the protocol and the measured results are recorded as rows in the
  device matrix of
  `.claude/skills/catchlaw-measurement-ruler/references/ruler-and-calibration.md`. **This is the one
  file outside `app/` this epic edits**, and the skill's own rule 12 and definition of done require
  it.

## Why it is built this way

**Two different claims, two different instruments, and they must not be confused.** The software path
— pixels in, millimetres out, drawn at the calibrated scale — is deterministic and can be asserted
exactly. The physical claim — that a fisher measuring a real 150 mm object gets 150 ± 1.5 mm — cannot
be produced by any test that runs on a build machine, because the error lives in the glass, the
screen protector, the viewing angle and the hand. `testing-strategy` rule 11 is explicit that a green
test over a structurally-untestable path is *worse* than an admitted gap, because it stops anyone
checking by hand. So this task delivers an automated harness that proves the arithmetic and the
rendering scale to zero error, plus a documented manual protocol whose results are recorded as data.
*Rejected:* an integration test that asserts `expect(error, lessThan(1.5))` against a simulated
reading. It would be green on every CI run and would prove nothing about any device.

**The harness is repeatable, which is what makes the matrix worth anything.** It fixes the
calibration rather than asking the operator to re-drag it, so calibration repeatability (≤ 1.0 mm
spread over five runs) and reading repeatability (≤ 2.0 mm over five runs) are measured separately
rather than confounded. It prints its row in the matrix's column order, so transcribing six devices
does not become the error source.

**`paints` is the right tier for the painter and goldens are not.** A golden blesses whatever
shipped, including a scale drawn at the wrong pitch, and reds on any host that rasterises fonts
differently. The `paints` matcher asserts *what the painter did* in a sentence a human can act on.
The one thing goldens are for — glyph shaping and which numeral block rendered — is already covered
by T04's `ar` lane.

**A `drawRawPoints` call does not match `paints..line(...)`, and the tests say so.** T03 draws all
~145 ticks in one `drawRawPoints(PointMode.lines, …)` pass for the allocation reason stated there.
`PaintPattern`'s typed predicates (`line`, `rect`, `circle`, `path`) match named canvas methods and
will not match that call, so these tests use `paints..something(...)` and `paints..everything(...)`,
whose predicate receives `(Symbol methodName, List<dynamic> arguments)` and can assert both the method
and its arguments. This is stated here because the first person to write
`expect(painter, paints..line())` will conclude the painter is broken.

**Ordering is asserted because ordering is the bug.** `catchlaw-measurement-ruler` rule 6: if a band
is ever mirrored, glyphs must be drawn *after* `restore()`, and the failure looks fine in every LTR
screenshot. Nothing is mirrored today, so the assertion is simpler and stronger — no `save`/`scale`
pair is recorded at all, and every paragraph is drawn after every geometry call.

**The matrix is a gate on the release, not on this PR.** Three real rows are this epic's definition
of done; the six devices `SPEC.md` §16 R3 asks for belong to the release pass in E21. If the numbers
come back outside budget, the correct response is the one already written down: the ruler tab does
not ship, and manual entry alone is a complete, honest product. That decision is not this task's to
make silently — it is a finding to raise with the numbers attached.

## Tests first

Write every row before touching `accuracy_stats.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `medianAbsoluteErrorMm returns the middle error of an odd sample` | `[149, 150, 152]` vs 150 | `1` | The statistic the pass bar is stated in |
| 2 | `medianAbsoluteErrorMm averages the two middle errors of an even sample` | `[149, 150, 152, 154]` vs 150 | `2` | Ten readings per device is an even count, so this is the path the protocol actually takes |
| 3 | `medianAbsoluteErrorMm returns zero for an exact sample` | `[150, 150]` vs 150 | `0` | The boundary a `sort`-then-index implementation gets wrong first |
| 4 | `worstAbsoluteErrorMm returns the largest error regardless of sign` | `[147, 153]` vs 150 | `3` | The no-device-worse-than-3 mm half of the bar; a signed max would report 3 and miss -3 |
| 5 | `spreadMm returns the range of a repeatability run` | `[149, 150, 151, 150, 150]` | `2` | Calibration repeatability is a spread, not an error against a reference |
| 6 | `RulerPainter draws the tick band before any label` | recorded canvas | every `drawParagraph` index exceeds every geometry index | Glyphs drawn inside a transformed frame ship backwards, and it looks fine in the LTR screenshot |
| 7 | `RulerPainter records no canvas transform` | recorded canvas | no `save`, `scale` or `transform` invocation | Nothing mirrors today; recording the absence is what makes a future mirror a deliberate, reviewed change |
| 8 | `RulerPainter draws the cursor at the calibrated pixel offset` | cursor 450 mm at 6.299 | a recorded vertex at `450 * 6.299` within 1e-6 | The reading a fisher acts on is this pixel; three pixels of drift is half a millimetre of legal exposure |
| 9 | `RulerPainter draws exactly one tick-band call` | default | one `drawRawPoints` invocation | 145 separate `drawLine` calls would pass every other test and jank on the 2 GB target |
| 10 | `RulerPainter draws one paragraph per centimetre label` | span 915 at 6.299 | 15 `drawParagraph` invocations | Ties the recorded output back to T03 row 10 at the canvas level |
| 11 | `Ruler measures a known pixel offset exactly` (integration) | offset for 150 mm at the device's real calibration | `150` mm, zero error | The software path is deterministic; any error here is a bug, not a tolerance |
| 12 | `Ruler measures every decade from 10 mm to 150 mm exactly` (integration) | fifteen offsets, name interpolates the value | each reads back exactly | Loop-generated names interpolate the parameter or `--plain-name` is useless |
| 13 | `Ruler reports a matrix row for the device it ran on` (integration) | one run | a printed row with device, OS, `pxPerMm`, median, worst and date | Transcription is the error source the harness exists to remove |

```dart
// app/test/ui/ruler/ruler_painter_paints_test.dart
import 'package:catchlaw/ui/ruler/widgets/ruler_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/scenes.dart';

void main() {
  group('RulerPainter', () {
    test('draws the tick band before any label', () {
      final cursor = ValueNotifier<double>(0);
      addTearDown(cursor.dispose);
      final painter = RulerPainter(kRulerSceneNominal, cursorPx: cursor);

      // PaintPattern's typed predicates (line/rect/path) match NAMED canvas
      // methods and never match drawRawPoints, so assert with `everything`.
      var sawGeometry = false;
      expect(
        painter,
        paints
          ..everything((Symbol method, List<dynamic> arguments) {
            if (method == #drawRawPoints) sawGeometry = true;
            if (method == #drawParagraph) {
              expect(sawGeometry, isTrue,
                  reason: 'a glyph was drawn before the tick band');
            }
            return true;
          }),
      );
      expect(sawGeometry, isTrue);
    });

    test('records no canvas transform', () {
      final cursor = ValueNotifier<double>(0);
      addTearDown(cursor.dispose);
      expect(
        RulerPainter(kRulerSceneNominal, cursorPx: cursor),
        paints
          ..everything((Symbol method, List<dynamic> arguments) =>
              method != #save && method != #scale && method != #transform),
      );
    });
  });
}
```

```dart
// app/test/testing/accuracy_stats_test.dart
import 'package:catchlaw/testing/measurement/accuracy_stats.dart';
import 'package:test/test.dart';

void main() {
  test('medianAbsoluteErrorMm averages the two middle errors of an even sample',
      () {
    expect(
      medianAbsoluteErrorMm(const <int>[149, 150, 152, 154], referenceMm: 150),
      2, // errors 1, 0, 2, 4 -> sorted 0, 1, 2, 4 -> (1 + 2) / 2
    );
  });

  test('worstAbsoluteErrorMm returns the largest error regardless of sign', () {
    expect(worstAbsoluteErrorMm(const <int>[147, 153], referenceMm: 150), 3);
  });
}
```

```dart
// app/integration_test/ruler_accuracy_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/device_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final mm in const <int>[10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110,
    120, 130, 140, 150]) {
    testWidgets('Ruler measures $mm mm from its calibrated pixel offset exactly',
        (tester) async {
      final harness = await pumpCalibratedRuler(tester);
      await harness.dragMarkerToPixels(harness.calibration.pixelsForMillimetres(mm));

      expect(harness.readingMm, mm,
          reason: 'target=$mm pxPerMm=${harness.calibration.pxPerMm}');
    });
  }
}
```

**Run:** `cd app && flutter test test/testing test/ui/ruler/ruler_painter_paints_test.dart`
→ 10 failures, plus the three integration rows on a device. If row 7 passes before the painter is
written, the harness is not recording anything — check the Scene fixture first.

## Implementation outline

1. `accuracy_stats.dart` under `app/testing/measurement/` — pure Dart, `package:test`-friendly, no
   Flutter import, so it runs at the cheapest tier.
2. The `paints` tests: build the painter from `kRulerSceneNominal` and assert with
   `something`/`everything` predicates. Do **not** reach for `line()`/`rect()` — see "Why", and leave
   the one-line comment in the test so the next reader does not re-learn it.
3. `app/integration_test/support/device_harness.dart` (a helper, not `_test.dart`): pumps S3 with a
   fixed calibration override, exposes `dragMarkerToPixels`, `readingMm` and a `matrixRow()` that
   prints `device | OS | pxPerMm | median | worst | date` in the reference table's column order.
4. Run the manual protocol per `ruler-and-calibration.md`: calibrate against a real ID-1 card,
   measure a 150 mm engineering rule ten times, record every absolute error, take the median. Repeat
   on at least three devices — one low-end Android, one current iPhone, one 10-inch tablet, which is
   the shape the matrix's placeholder rows already ask for.
5. Fill the matrix rows in
   `.claude/skills/catchlaw-measurement-ruler/references/ruler-and-calibration.md` with device, OS,
   `pxPerMm`, median absolute error, worst error and date. Do not delete the placeholder rows for
   device classes that were not tested — leave them named and empty, so the gap is visible.
6. If any device exceeds 3.0 mm, stop and raise it with the numbers. Do not widen the budget, and do
   not adjust `kNominalPxPerMm` to make a device look better — the value is measured per device by
   definition.
7. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 10 host tests pass, and each failed first; the 3 integration rows have been run on a
      physical device at least once and the run is named in the commit body.
- [ ] `accuracy_stats.dart` has zero Flutter imports and lives in `app/testing/`, not `app/test/`.
- [ ] No helper file in the diff ends in `_test.dart`.
- [ ] The `paints` tests assert both what is drawn and what is **not** — no transform, no glyph
      before geometry.
- [ ] The device matrix in `ruler-and-calibration.md` has at least three filled rows with a date, and
      every filled row is within budget: median ≤ 1.5 mm over 150 mm, worst ≤ 3.0 mm.
- [ ] The commit body states which devices were measured and, if any class was not measured, which.
- [ ] No test asserts a physical accuracy figure that was not physically measured.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
cd app && flutter test integration_test/ruler_accuracy_test.dart -d <device-id>
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh    app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
```

The gates scan `app/lib`; this task's code is mostly under `app/test`, `app/testing` and
`app/integration_test`, so a clean run here proves nothing about the new files. That is the failure
mode `CONVENTIONS.md` §7 warns about — read the scripts' file counts rather than their exit codes.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(ruler): add the accuracy harness and paints-matcher coverage for the scale

Two claims, two instruments. The software path — pixels in, millimetres out,
drawn at the calibrated scale — is deterministic, so the integration harness
asserts it to zero error across every decade from 10 to 150 mm. The physical
claim in SPEC 16 R3 cannot be produced by any test that runs on a build
machine, because the error lives in the glass, the protector, the viewing angle
and the hand, so it is a documented protocol whose results are recorded as data
in the skill's device matrix. A green test over that path would be worse than
an admitted gap: it would stop anyone checking by hand.

The paints tests assert what the painter did and what it did not — one
drawRawPoints call for the whole tick band, every glyph after every geometry
call, and no canvas transform at all, so a future mirror has to be a deliberate
change rather than an accident that looks fine in the LTR screenshot. Note that
PaintPattern's typed predicates never match drawRawPoints; these use
something/everything, and the tests say so in a comment.

Task: E09/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
