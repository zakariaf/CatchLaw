import 'package:catchlaw/data/daos/user/user_settings_dao.dart';
import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/model/mappers.dart';
import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/settings_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/domain/models/user_profile.dart' as domain;
import 'package:drift/drift.dart' show Value;
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// [SettingsRepository] over `user.db`.
///
/// Every setter is a single-column write against the singleton, and every one
/// of them goes through the same `_write`: there is one place that knows the
/// row is `id = 1`, and one place that converts a `CHECK` violation into a
/// typed failure.
final class DriftSettingsRepository implements SettingsRepository {
  /// Reads and writes settings in [db].
  DriftSettingsRepository(this.db, {this.boundary = const StorageBoundary()})
    : _profile = UserProfileDao(db),
      _zones = SavedZoneDao(db);

  /// The fisher's log, which is also where their settings live.
  final UserDatabase db;

  /// Where a storage exception becomes a [DataFailure].
  final StorageBoundary boundary;

  final UserProfileDao _profile;
  final SavedZoneDao _zones;

  @override
  Stream<domain.UserProfile> watchProfile() =>
      _profile.watchProfile().map((UserProfileRow row) => toUserProfile(row));

  @override
  Future<Result<domain.UserProfile>> read() =>
      boundary.guard(() async => toUserProfile(await _profile.read()));

  @override
  Future<Result<void>> setLocaleOverride(String? locale) =>
      _write(UserProfilesCompanion(localeOverride: Value<String?>(locale)));

  @override
  Future<Result<void>> setNumeralSystem(NumeralSystem system) =>
      _write(UserProfilesCompanion(numeralSystem: Value<String>(system.sql)));

  @override
  Future<Result<void>> setLengthUnit(LengthUnit unit) =>
      _write(UserProfilesCompanion(lengthUnit: Value<String>(unit.sql)));

  @override
  Future<Result<void>> setActivePlace({String? jurisdictionCode, String? zoneCode}) => _write(
    UserProfilesCompanion(
      activeJurisdiction: Value<String?>(jurisdictionCode),
      activeZoneCode: Value<String?>(zoneCode),
    ),
  );

  @override
  Future<Result<void>> setRulerCalibration({
    required double pxPerMm,
    required String calibratedAt,
  }) => _write(
    UserProfilesCompanion(
      rulerPxPerMm: Value<double>(pxPerMm),
      rulerCalibratedAt: Value<String>(calibratedAt),
    ),
  );

  @override
  Future<Result<void>> setFlags({bool? captureCoordinates, bool? sunlightMode, bool? gloveMode}) =>
      _write(
        UserProfilesCompanion(
          captureCoordinates: captureCoordinates == null
              ? const Value<bool>.absent()
              : Value<bool>(captureCoordinates),
          sunlightMode: sunlightMode == null
              ? const Value<bool>.absent()
              : Value<bool>(sunlightMode),
          gloveMode: gloveMode == null ? const Value<bool>.absent() : Value<bool>(gloveMode),
        ),
      );

  @override
  Stream<List<SavedZone>> watchSavedZones() =>
      _zones.watchAll().map((List<SavedZoneRow> rows) => rows.map(toSavedZone).toList());

  @override
  Future<Result<int>> saveZone({
    required String jurisdictionCode,
    required String zoneCode,
    String? label,
  }) => boundary.guard(
    () => _zones.save(jurisdictionCode: jurisdictionCode, zoneCode: zoneCode, label: label),
  );

  @override
  Future<Result<void>> removeZone(int id) => boundary.guard(() async {
    final int removed = await _zones.remove(id);
    if (removed == 0) throw DataNotFound(entity: 'saved_zone', id: '$id');
  });

  @override
  Future<Result<void>> reorderZones(List<int> idsInOrder) =>
      boundary.guard(() => _zones.reorder(idsInOrder));

  /// Writes a `length_unit` the [LengthUnit] enum cannot express.
  ///
  /// **Test-only, and here rather than in the test** because the constraint it
  /// exercises is real and the path to it is not: a value outside `cm`, `mm`
  /// and `in` cannot be constructed through [setLengthUnit] at all. The way it
  /// still happens is a future member added to the enum and not to §7.2's
  /// `CHECK`, and this is what that looks like when it does.
  @visibleForTesting
  Future<Result<void>> writeRawLengthUnitForTesting(String unit) =>
      _write(UserProfilesCompanion(lengthUnit: Value<String>(unit)));

  Future<Result<void>> _write(UserProfilesCompanion changes) =>
      boundary.guard(() => _profile.updateProfile(changes));
}
