import 'package:catchlaw/data/daos/user/catch_dao.dart';
import 'package:catchlaw/data/daos/user/trip_dao.dart';
import 'package:catchlaw/data/daos/user/user_settings_dao.dart';
import 'package:catchlaw/data/model/mappers.dart';
import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/measurement_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// [MeasurementRepository] over `user.db` — the only writable database.
///
/// **The single write path.** Nothing else inserts a catch: the recency bump
/// that has to happen with it lives in one transaction inside the DAO, and a
/// second caller doing half of the pair is a tally that disagrees with the log
/// it was counted from.
final class DriftMeasurementRepository implements MeasurementRepository {
  /// Records into [db].
  DriftMeasurementRepository(this.db, {this.boundary = const StorageBoundary()})
    : _catches = CatchDao(db),
      _trips = TripDao(db),
      _recents = SpeciesRecentDao(db);

  /// The fisher's log.
  final UserDatabase db;

  /// Where a storage exception becomes a [DataFailure].
  final StorageBoundary boundary;

  final CatchDao _catches;
  final TripDao _trips;
  final SpeciesRecentDao _recents;

  @override
  Stream<List<CatchRecord>> watchForTrip(int tripId) =>
      _catches.watchForTrip(tripId).map((List<CatchRow> rows) => rows.map(toCatchRecord).toList());

  @override
  Stream<List<SpeciesTallyEntry>> watchTallyForDay(
    String isoDay, {
    required String jurisdictionCode,
    required String zoneCode,
  }) => _catches
      .watchTallyForDay(isoDay, jurisdictionCode: jurisdictionCode, zoneCode: zoneCode)
      .map((List<SpeciesTally> rows) => rows.map(toTallyEntry).toList());

  @override
  Future<Result<List<CatchRecord>>> pageBefore(String cursorCreatedAt, {int limit = 30}) =>
      boundary.guard(
        () async =>
            (await _catches.pageBefore(cursorCreatedAt, limit: limit)).map(toCatchRecord).toList(),
      );

  @override
  Future<Result<CatchRecord>> recordCatch(CatchDraft draft, {String? updatedAt}) =>
      boundary.guard(() async {
        final int id = await _catches.insertCatch(draft.toCompanion(updatedAt: updatedAt));
        final CatchRow? saved = await _catches.byId(id);
        // Read back rather than reconstruct. Returning a value assembled from
        // the draft would report the DEFAULTS §7.2 applied as whatever the
        // draft happened to say, and the first divergence would be invisible.
        if (saved == null) throw const DataTransactionRolledBack();
        return toCatchRecord(saved);
      });

  @override
  Future<Result<void>> deleteCatch(int id) => boundary.guard(() async {
    final int removed = await _catches.deleteCatch(id);
    if (removed == 0) throw DataNotFound(entity: 'catch', id: '$id');
  });

  @override
  Stream<Trip?> watchOpenTrip() =>
      _trips.watchOpenTrip().map((TripRow? row) => row == null ? null : toTrip(row));

  @override
  Future<Result<int>> startTrip({
    required String startedAt,
    required String jurisdictionCode,
    required String zoneCode,
    String? label,
  }) => boundary.guard(
    () => _trips.startTrip(
      startedAt: startedAt,
      jurisdictionCode: jurisdictionCode,
      zoneCode: zoneCode,
      label: label,
    ),
  );

  @override
  Future<Result<void>> endTrip(int id, String endedAt) => boundary.guard(() async {
    final int updated = await _trips.endTrip(id, endedAt);
    if (updated == 0) throw DataNotFound(entity: 'trip', id: '$id');
  });

  @override
  Stream<List<RecentSpecies>> watchRecentSpecies({
    required String jurisdictionCode,
    required String zoneCode,
    int limit = 12,
  }) => _recents
      .watchRecent(jurisdictionCode: jurisdictionCode, zoneCode: zoneCode, limit: limit)
      .map((List<SpeciesRecentRow> rows) => rows.map(toRecentSpecies).toList());
}
