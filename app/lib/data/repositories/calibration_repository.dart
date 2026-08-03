import 'package:catchlaw/domain/models/ruler_calibration.dart';

/// Where the measured scale lives between launches.
///
/// It writes exactly two columns of `user_profile` — `ruler_px_per_mm` and
/// `ruler_calibrated_at` — and touches no other. A repository that took the
/// whole profile would let a calibration write clear the fisher's jurisdiction
/// on a partial object.
abstract interface class CalibrationRepository {
  /// The stored calibration, or `null` before one exists.
  ///
  /// `null` is a real state and not an error: manual entry works before any
  /// calibration, so a fisher can measure on the first launch of a wet morning
  /// without lining a card up first (E09/T06).
  Future<RulerCalibration?> read();

  /// Stores [calibration].
  Future<void> save(RulerCalibration calibration);

  /// Forgets the calibration.
  Future<void> clear();
}
