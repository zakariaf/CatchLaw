import 'package:drift/drift.dart';

/// `SPEC.md` §7.2 `trip`.
@DataClassName('TripRow')
class Trips extends Table {
  @override
  String get tableName => 'trip';

  IntColumn get id => integer().autoIncrement()();

  /// ISO-8601 UTC `TEXT`, per §7.2 and §12's export format. It sorts
  /// lexicographically in chronological order, so `idx_trip_started` serves
  /// `ORDER BY started_at DESC` exactly as an integer column would.
  TextColumn get startedAt => text().named('started_at')();

  /// `null` while the trip is open.
  TextColumn get endedAt => text().named('ended_at').nullable()();

  TextColumn get jurisdictionCode => text().named('jurisdiction_code')();

  TextColumn get zoneCode => text().named('zone_code')();

  TextColumn get label => text().nullable()();

  TextColumn get notes => text().nullable()();

  @override
  bool get isStrict => true;
}
