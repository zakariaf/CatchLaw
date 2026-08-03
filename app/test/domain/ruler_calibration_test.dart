import 'package:catchlaw/domain/models/id1_card.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:flutter_test/flutter_test.dart';

RulerCalibration _at(double pxPerMm) =>
    RulerCalibration(pxPerMm: pxPerMm, capturedOn: DateTime.utc(2026, 8, 1));

void main() {
  test('kId1WidthMm is the ISO/IEC 7810 ID-1 width', () {
    // Every measurement in the app is divided by this number. It is 85.60 mm
    // because ISO says so, and a fisher already carries a card that is it.
    expect(kId1WidthMm, 85.60);
    expect(kId1HeightMm, 53.98);
  });

  test('millimetresFor rounds to whole millimetres', () {
    // SPEC.md §9.5: storage is integer millimetres. A double would let two
    // screens that measured the same fish store different numbers, and the
    // difference between 449.6 and 450.4 is a fine versus a legal fish.
    // At 1 px/mm the pixels ARE the millimetres, so the rounding is the only
    // thing under test.
    final RulerCalibration unit = _at(1);
    expect(unit.millimetresFor(449.6), 450);
    expect(unit.millimetresFor(449.4), 449);
    expect(unit.millimetresFor(0), 0);

    final RulerCalibration calibration = _at(10);
    expect(calibration.millimetresFor(4500), 450);
  });

  test('pixelsForMillimetres is the inverse of millimetresFor', () {
    // The ONE shared transform. A painter doing its own arithmetic and a
    // readout doing its own agree until one is changed, and the day they
    // disagree the ruler draws 45 cm while the number under it says 44.
    final RulerCalibration calibration = _at(6.299);
    for (final mm in const <int>[1, 45, 450, 1200]) {
      expect(calibration.millimetresFor(calibration.pixelsForMillimetres(mm)), mm);
    }
  });

  test('isPlausiblePxPerMm accepts the nominal reference panel', () {
    expect(isPlausiblePxPerMm(kNominalPxPerMm), isTrue);
  });

  test('isPlausiblePxPerMm rejects a collapsed drag', () {
    // The window catches a handle nudged to the screen edge or a double-tap
    // that collapsed it — not a fisher whose phone is unusual, which is why it
    // is deliberately wide.
    expect(isPlausiblePxPerMm(2.1), isFalse);
    expect(isPlausiblePxPerMm(kMinPxPerMm - 0.01), isFalse);
    expect(isPlausiblePxPerMm(kMaxPxPerMm + 0.01), isFalse);
  });

  test('isPlausiblePxPerMm accepts both ends of its own window', () {
    expect(isPlausiblePxPerMm(kMinPxPerMm), isTrue);
    expect(isPlausiblePxPerMm(kMaxPxPerMm), isTrue);
  });

  test('RulerCalibration == compares the scale and the stamp', () {
    // Value equality, because a screen holds a snapshot: a calibration rebuilt
    // each frame that compared unequal would repaint the ruler on every tick.
    expect(_at(6.299), _at(6.299));
    expect(_at(6.299), isNot(_at(6.3)));
    expect(
      _at(6.299),
      isNot(RulerCalibration(pxPerMm: 6.299, capturedOn: DateTime.utc(2026, 8, 2))),
    );
  });
}
