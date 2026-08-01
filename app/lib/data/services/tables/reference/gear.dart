import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `gear_rule`.
@DataClassName('GearRuleRow')
class GearRules extends Table {
  @override
  String get tableName => 'gear_rule';

  IntColumn get id => integer()();

  IntColumn get jurisdictionId =>
      integer().named('jurisdiction_id').customConstraint('NOT NULL REFERENCES jurisdiction(id)')();

  IntColumn get zoneId =>
      integer().named('zone_id').nullable().customConstraint('REFERENCES zone(id)')();

  /// `null` means every species.
  IntColumn get speciesId =>
      integer().named('species_id').nullable().customConstraint('REFERENCES species(id)')();

  TextColumn get gearCode => text().named('gear_code')();

  TextColumn get gearNameKey => text().named('gear_name_key')();

  BoolColumn get isAllowed => boolean().named('is_allowed')();

  /// Localised constraint, e.g. a minimum mesh.
  TextColumn get constraintKey => text().named('constraint_key').nullable()();

  IntColumn get citationId =>
      integer().named('citation_id').customConstraint('NOT NULL REFERENCES citation(id)')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
