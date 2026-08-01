import 'package:drift/drift.dart';

/// `SPEC.md` §7.2 `saved_zone` — the places the fisher works.
@DataClassName('SavedZoneRow')
class SavedZones extends Table {
  @override
  String get tableName => 'saved_zone';

  IntColumn get id => integer().autoIncrement()();

  /// Codes, never ids: `reference.db` is a separate file that a content update
  /// replaces wholesale.
  TextColumn get jurisdictionCode => text().named('jurisdiction_code')();

  TextColumn get zoneCode => text().named('zone_code')();

  /// What the fisher calls it, which may not be what the instrument calls it.
  TextColumn get label => text().nullable()();

  IntColumn get sortOrder => integer().named('sort_order').withDefault(const Constant<int>(0))();

  @override
  List<String> get customConstraints => <String>['UNIQUE (jurisdiction_code, zone_code)'];

  @override
  bool get isStrict => true;
}
