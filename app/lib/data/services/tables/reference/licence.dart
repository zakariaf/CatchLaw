import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `licence_type`.
@DataClassName('LicenceTypeRow')
class LicenceTypes extends Table {
  @override
  String get tableName => 'licence_type';

  IntColumn get id => integer()();

  IntColumn get jurisdictionId =>
      integer().named('jurisdiction_id').customConstraint('NOT NULL REFERENCES jurisdiction(id)')();

  IntColumn get zoneId =>
      integer().named('zone_id').nullable().customConstraint('REFERENCES zone(id)')();

  TextColumn get waterType => text()
      .named('water_type')
      .customConstraint("NOT NULL CHECK (water_type IN ('salt','fresh','both'))")();

  TextColumn get code => text()();

  TextColumn get nameKey => text().named('name_key')();

  /// It states what the instrument says and never what to do about it.
  TextColumn get descriptionKey => text().named('description_key')();

  IntColumn get citationId =>
      integer().named('citation_id').customConstraint('NOT NULL REFERENCES citation(id)')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
