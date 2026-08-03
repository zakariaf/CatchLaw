import 'package:catchlaw/data/daos/user/user_settings_dao.dart';
import 'package:catchlaw/data/repositories/calibration_repository.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:drift/drift.dart';

/// [CalibrationRepository] over `user.db` — the only writable database (D-6).
final class DriftCalibrationRepository implements CalibrationRepository {
  /// Reads and writes the two calibration columns of [db].
  DriftCalibrationRepository(this.db) : _profile = UserProfileDao(db);

  /// The fisher's log.
  final UserDatabase db;

  final UserProfileDao _profile;

  @override
  Future<RulerCalibration?> read() async {
    final UserProfileRow row = await _profile.watchProfile().first;
    final double? pxPerMm = row.rulerPxPerMm;
    final String? at = row.rulerCalibratedAt;
    // Both or neither. A scale with no date could not be aged, and a date with
    // no scale is a claim that a calibration happened which cannot be used.
    if (pxPerMm == null || at == null) return null;
    return RulerCalibration(pxPerMm: pxPerMm, capturedOn: DateTime.parse(at).toUtc());
  }

  @override
  Future<void> save(RulerCalibration calibration) async {
    await (db.update(db.userProfiles)..where(($UserProfilesTable t) => t.id.equals(1))).write(
      UserProfilesCompanion(
        rulerPxPerMm: Value<double>(calibration.pxPerMm),
        rulerCalibratedAt: Value<String>(calibration.capturedOn.toUtc().toIso8601String()),
      ),
    );
  }

  @override
  Future<void> clear() =>
      (db.update(db.userProfiles)..where(($UserProfilesTable t) => t.id.equals(1))).write(
        const UserProfilesCompanion(
          rulerPxPerMm: Value<double?>(null),
          rulerCalibratedAt: Value<String?>(null),
        ),
      );
}
