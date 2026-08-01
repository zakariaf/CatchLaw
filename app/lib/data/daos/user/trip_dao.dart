import 'package:catchlaw/data/services/tables/user/trip.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:drift/drift.dart';

part 'trip_dao.g.dart';

/// Reads and writes trips.
@DriftAccessor(tables: <Type>[Trips])
class TripDao extends DatabaseAccessor<UserDatabase> with _$TripDaoMixin {
  /// Reads trips from [db].
  TripDao(super.db);

  /// The open trip, or `null`. At most one is open at a time.
  Stream<TripRow?> watchOpenTrip() =>
      (select(trips)
            ..where(($TripsTable t) => t.endedAt.isNull())
            ..orderBy(<OrderClauseGenerator<$TripsTable>>[
              ($TripsTable t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
            ])
            ..limit(1))
          .watchSingleOrNull();

  /// Recent trips, newest first.
  Stream<List<TripRow>> watchRecentTrips({int limit = 20}) =>
      (select(trips)
            ..orderBy(<OrderClauseGenerator<$TripsTable>>[
              ($TripsTable t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
            ])
            ..limit(limit))
          .get()
          .asStream();

  /// Starts a trip, closing any that is still open.
  ///
  /// In one transaction: two open trips is a tally counted against the wrong
  /// place, and closing the old one after opening the new one leaves both open
  /// if the process dies between.
  Future<int> startTrip({
    required String startedAt,
    required String jurisdictionCode,
    required String zoneCode,
    String? label,
  }) => db.transaction(() async {
    await (update(trips)..where(($TripsTable t) => t.endedAt.isNull())).write(
      TripsCompanion(endedAt: Value<String?>(startedAt)),
    );
    return into(trips).insert(
      TripsCompanion.insert(
        startedAt: startedAt,
        jurisdictionCode: jurisdictionCode,
        zoneCode: zoneCode,
        label: Value<String?>(label),
      ),
    );
  });

  /// Ends a trip. The timestamp is the caller's; this layer reads no clock.
  Future<int> endTrip(int id, String endedAt) =>
      (update(trips)..where(($TripsTable t) => t.id.equals(id))).write(
        TripsCompanion(endedAt: Value<String?>(endedAt)),
      );
}
