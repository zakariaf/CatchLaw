import 'package:catchlaw/data/repositories/calibration_repository.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';

/// An in-memory [CalibrationRepository].
///
/// Bare `implements`: adding a method to the interface must be a compile error
/// here, not a runtime surprise three screens later. Every later task in this
/// epic pumps against it.
final class FakeCalibrationRepository implements CalibrationRepository {
  /// Starts holding [stored], or nothing.
  FakeCalibrationRepository([this.stored]);

  /// What [read] returns. `null` is the pre-calibration state, which is a real
  /// state: manual entry works before any calibration exists.
  RulerCalibration? stored;

  /// How many times it was saved, in order.
  final List<RulerCalibration> saves = <RulerCalibration>[];

  /// How many times it was cleared.
  int clears = 0;

  @override
  Future<RulerCalibration?> read() async => stored;

  @override
  Future<void> save(RulerCalibration calibration) async {
    saves.add(calibration);
    stored = calibration;
  }

  @override
  Future<void> clear() async {
    clears++;
    stored = null;
  }
}
