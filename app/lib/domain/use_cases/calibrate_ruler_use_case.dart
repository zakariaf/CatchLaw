import 'package:catchlaw/domain/models/id1_card.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:meta/meta.dart';

/// What a calibration attempt produced.
///
/// Sealed, so a caller that renders it cannot miss the refusal arm — and a
/// refusal that fell through to a default would store a scale nobody measured.
@immutable
sealed class CalibrationOutcome {
  const CalibrationOutcome();
}

/// The drag traced something card-shaped.
final class CalibrationAccepted extends CalibrationOutcome {
  /// Accepts [calibration].
  const CalibrationAccepted(this.calibration);

  /// The measured scale.
  final RulerCalibration calibration;
}

/// The drag did not trace a card.
///
/// Carries the number it measured rather than a message: D-7's rule one layer
/// up — the use case decides, the screen says. And the number is what makes the
/// refusal actionable, because a fisher who dragged to 2.1 px/mm can see that
/// he collapsed the handle.
final class CalibrationImplausible extends CalibrationOutcome {
  /// Refuses [measuredPxPerMm].
  const CalibrationImplausible(this.measuredPxPerMm);

  /// What the drag divided out to.
  final double measuredPxPerMm;
}

/// Turns a traced card width into a calibration.
///
/// Takes its clock, so a row about the stamp does not depend on when it ran.
final class CalibrateRulerUseCase {
  /// Calibrates against [now].
  const CalibrateRulerUseCase(this.now);

  /// The clock, injected.
  final DateTime Function() now;

  /// Judges [cardWidthPx] and either builds a calibration or refuses.
  ///
  /// A non-positive width is refused rather than dividing: a zero-width drag is
  /// an infinite scale, and an infinity stored in `user.db` is a ruler that
  /// draws nothing forever.
  CalibrationOutcome call(double cardWidthPx) {
    if (cardWidthPx <= 0) return const CalibrationImplausible(0);
    final double pxPerMm = cardWidthPx / kId1WidthMm;
    if (!isPlausiblePxPerMm(pxPerMm)) return CalibrationImplausible(pxPerMm);
    return CalibrationAccepted(RulerCalibration(pxPerMm: pxPerMm, capturedOn: now().toUtc()));
  }
}
