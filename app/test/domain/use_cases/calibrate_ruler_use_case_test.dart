import 'package:catchlaw/domain/models/id1_card.dart';
import 'package:catchlaw/domain/use_cases/calibrate_ruler_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

final DateTime _fixedNow = DateTime.utc(2026, 8, 1, 5, 40);

CalibrateRulerUseCase _useCase() => CalibrateRulerUseCase(() => _fixedNow);

void main() {
  test('CalibrateRulerUseCase divides the traced width by the ID-1 width', () {
    // The scale is MEASURED. Flutter cannot tell you a panel's physical DPI —
    // devicePixelRatio is a logical-to-physical ratio and no arithmetic on it
    // yields millimetres — so the fisher lays a card he already carries on the
    // glass and the app divides.
    final CalibrationOutcome outcome = _useCase()(kNominalPxPerMm * kId1WidthMm);
    expect(outcome, isA<CalibrationAccepted>());
    expect((outcome as CalibrationAccepted).calibration.pxPerMm, closeTo(kNominalPxPerMm, 1e-9));
  });

  test('CalibrateRulerUseCase stamps the calibration from its injected clock', () {
    // Injected, so this row does not depend on when it ran.
    final CalibrationOutcome outcome = _useCase()(kNominalPxPerMm * kId1WidthMm);
    expect((outcome as CalibrationAccepted).calibration.capturedOn, _fixedNow);
    expect(outcome.calibration.capturedOn.isUtc, isTrue);
  });

  test('CalibrateRulerUseCase refuses a drag that collapsed', () {
    final CalibrationOutcome outcome = _useCase()(30);
    expect(outcome, isA<CalibrationImplausible>());
  });

  test('CalibrateRulerUseCase carries the measured number into its refusal', () {
    // A number and not a message: D-7's rule one layer up, and the number is
    // what makes the refusal actionable — a fisher who dragged to 0.35 px/mm
    // can see that he collapsed the handle.
    final CalibrationOutcome outcome = _useCase()(30);
    expect((outcome as CalibrationImplausible).measuredPxPerMm, closeTo(30 / kId1WidthMm, 1e-9));
  });

  test('CalibrateRulerUseCase refuses a zero-width drag rather than dividing', () {
    // A zero-width drag is an infinite scale, and an infinity stored in user.db
    // is a ruler that draws nothing forever.
    final CalibrationOutcome outcome = _useCase()(0);
    expect(outcome, isA<CalibrationImplausible>());
    expect((outcome as CalibrationImplausible).measuredPxPerMm, 0);
  });

  test('CalibrateRulerUseCase refuses a negative width', () {
    expect(_useCase()(-10), isA<CalibrationImplausible>());
  });

  test('CalibrateRulerUseCase accepts both ends of the plausible window', () {
    expect(_useCase()(kMinPxPerMm * kId1WidthMm), isA<CalibrationAccepted>());
    expect(_useCase()(kMaxPxPerMm * kId1WidthMm), isA<CalibrationAccepted>());
  });
}
