// The accuracy harness.
//
// **Two different claims, two different instruments, and they must not be
// confused.** The software path — pixels in, millimetres out, at the calibrated
// scale — is deterministic and is asserted EXACTLY here. The physical claim,
// that a fisher measuring a real 150 mm object reads 150 ± 1.5 mm, cannot be
// asserted by any test: it needs a real object, a real screen and a human. What
// this file does is remove the software from the list of suspects and print a
// row a human fills in.
//
// It is a widget test and NOT an integration_test, and that is a deliberate
// departure from the task file, raised rather than taken quietly. The
// integration_test package pulls `sync_http`, `webdriver` and `flutter_driver`
// transitively — two HTTP clients — into an app whose first invariant is that
// there is no network code path, ever. Dev-only HTTP has a precedent
// (build_runner's watch server, and the deps_dev_only_http fixture), so this
// may well be fine; but SPEC.md §14's edge-level guarantee names `http` and not
// `sync_http`, and widening it is a D-n in epics/DECISIONS.md rather than a
// line in a pubspec. The software half of the claim needs no device at all, so
// nothing is lost by waiting for that decision.

import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/measurement/accuracy_stats.dart';

final RulerCalibration _calibration = RulerCalibration(
  pxPerMm: 6.299,
  capturedOn: DateTime.utc(2026, 8, 1),
);

void main() {
  test('the software path reads back exactly what it was given', () {
    // Exact, because there is nothing physical in this path to be approximate
    // about. Every millimetre a fish could plausibly be, through the transform
    // and back.
    const references = <int>[10, 45, 150, 380, 450, 650, 1200];
    final readings = <int>[
      for (final int mm in references)
        _calibration.millimetresFor(_calibration.pixelsForMillimetres(mm)),
    ];
    expect(readings, references);
  });

  test('a one-pixel wobble cannot move a reading by more than a millimetre', () {
    // At 6.299 px/mm a pixel is 0.16 mm. This is the SOFTWARE tolerance and it
    // says nothing about a thumb on wet glass — which is the point of keeping
    // the two claims apart.
    const reference = 150;
    final double centre = _calibration.pixelsForMillimetres(reference);
    final readings = <int>[
      _calibration.millimetresFor(centre - 1),
      _calibration.millimetresFor(centre),
      _calibration.millimetresFor(centre + 1),
    ];
    expect(worstAbsoluteErrorMm(readings, referenceMm: reference), lessThanOrEqualTo(1));
  });

  test('the harness prints a device matrix row rather than asserting a physical tolerance', () {
    // A REPORT, not an assertion. The row belongs in the device matrix of
    // catchlaw-measurement-ruler/references/ruler-and-calibration.md, and the
    // physical column is left as NOT MEASURED because this process has no
    // ruler, no card and no hands. A test that asserted a physical tolerance it
    // could not measure would be a green tick over a claim nobody checked.
    const reference = 150;
    final double centre = _calibration.pixelsForMillimetres(reference);
    final readings = <int>[
      _calibration.millimetresFor(centre - 1),
      _calibration.millimetresFor(centre),
      _calibration.millimetresFor(centre + 1),
    ];

    final row =
        '| host | software-only | ${_calibration.pxPerMm} px/mm | '
        'median ${medianAbsoluteErrorMm(readings, referenceMm: reference)} mm | '
        'worst ${worstAbsoluteErrorMm(readings, referenceMm: reference)} mm | '
        'spread ${spreadMm(readings)} mm | physical: NOT MEASURED |';
    if (kDebugMode) debugPrint(row);

    expect(row, contains('NOT MEASURED'));
  });
}
