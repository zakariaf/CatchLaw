import 'package:catchlaw/data/daos/user/catch_dao.dart';
import 'package:catchlaw/data/daos/user/trip_dao.dart';
import 'package:catchlaw/data/model/mappers.dart';
import 'package:catchlaw/data/repositories/catch_log_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/trip.dart' as domain;
import 'package:drift/drift.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// [CatchLogRepository] over `user.db`.
///
/// **Reads no reference row and joins nothing across the two files.** The catch
/// table already carries `scientific_name`, the outcome sentence and the
/// citation reference, so the log renders with `reference.db` closed — which is
/// what makes it survive a wholesale pack replacement, and what keeps
/// `catchlaw-reference-database` rule 11's `ATTACH` ban costless here.
final class DriftCatchLogRepository implements CatchLogRepository {
  /// Reads and writes the log through [db].
  DriftCatchLogRepository(this.db, {this.boundary = const StorageBoundary()})
    : _catches = CatchDao(db),
      _trips = TripDao(db);

  /// The writable connection.
  final UserDatabase db;

  /// Turns a thrown storage error into a `Failure`.
  final StorageBoundary boundary;

  final CatchDao _catches;
  final TripDao _trips;

  @override
  Stream<List<SpeciesTallyEntry>> watchDay({
    required String isoDay,
    required String jurisdictionCode,
    required String zoneCode,
  }) => _catches
      .watchTallyForDay(isoDay, jurisdictionCode: jurisdictionCode, zoneCode: zoneCode)
      .map(
        (List<SpeciesTally> rows) => <SpeciesTallyEntry>[
          for (final SpeciesTally r in rows)
            SpeciesTallyEntry(
              speciesId: r.speciesId,
              scientificName: r.scientificName,
              count: r.count,
              kept: r.kept,
            ),
        ],
      );

  @override
  Stream<List<domain.Trip>> watchTrips({int limit = 20}) =>
      _trips.watchRecentTrips(limit: limit).map((List<TripRow> rows) => rows.map(toTrip).toList());

  @override
  Stream<domain.Trip?> watchOpenTrip() =>
      _trips.watchOpenTrip().map((TripRow? row) => row == null ? null : toTrip(row));

  @override
  Future<Result<int>> record(CatchDraft draft) => boundary.guard(
    () => _catches.insertCatch(
      CatchesCompanion.insert(
        tripId: Value<int?>(draft.tripId),
        jurisdictionCode: draft.jurisdictionCode,
        zoneCode: draft.zoneCode,
        speciesId: draft.speciesId,
        scientificName: draft.scientificName,
        lengthMm: Value<int?>(draft.lengthMm),
        measurementCode: Value<String?>(draft.measurementCode),
        outcome: draft.outcome.sql,
        outcomeDetail: Value<String?>(draft.outcomeDetail),
        ruleCitationRef: Value<String?>(draft.ruleCitationRef),
        contentVersion: Value<String?>(draft.contentVersion),
        wasKept: Value<bool>(draft.wasKept),
        createdAt: draft.createdAt,
        updatedAt: draft.createdAt,
      ),
    ),
  );

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
  Future<Result<int>> removeLatest({
    required int speciesId,
    required String isoDay,
    required String jurisdictionCode,
    required String zoneCode,
  }) => boundary.guard(
    () => db.customUpdate(
      'DELETE FROM catch WHERE id = (SELECT id FROM catch WHERE species_id = ?1 '
      'AND jurisdiction_code = ?2 AND zone_code = ?3 AND created_at LIKE ?4 '
      'ORDER BY created_at DESC, id DESC LIMIT 1)',
      variables: <Variable<Object>>[
        Variable<int>(speciesId),
        Variable<String>(jurisdictionCode),
        Variable<String>(zoneCode),
        Variable<String>('$isoDay%'),
      ],
      updates: <TableInfo<Table, Object>>{db.catches},
    ),
  );

  @override
  Future<Result<int>> setLatestKept({
    required int speciesId,
    required String isoDay,
    required String jurisdictionCode,
    required String zoneCode,
    required bool kept,
  }) => boundary.guard(
    () => db.customUpdate(
      'UPDATE catch SET was_kept = ?5, updated_at = created_at WHERE id = '
      '(SELECT id FROM catch WHERE species_id = ?1 AND jurisdiction_code = ?2 '
      'AND zone_code = ?3 AND created_at LIKE ?4 '
      'ORDER BY created_at DESC, id DESC LIMIT 1)',
      variables: <Variable<Object>>[
        Variable<int>(speciesId),
        Variable<String>(jurisdictionCode),
        Variable<String>(zoneCode),
        Variable<String>('$isoDay%'),
        Variable<int>(kept ? 1 : 0),
      ],
      updates: <TableInfo<Table, Object>>{db.catches},
    ),
  );

  @override
  Future<Result<void>> endTrip(int tripId, String endedAt) =>
      boundary.guard(() => _trips.endTrip(tripId, endedAt));
}
