import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `rule`.
@TableIndex(
  name: 'idx_rule_lookup',
  columns: <Symbol>{#jurisdictionId, #speciesId, #waterType, #validFrom},
)
@TableIndex(name: 'idx_rule_zone', columns: <Symbol>{#zoneId})
@DataClassName('RuleRow')
class Rules extends Table {
  @override
  String get tableName => 'rule';

  IntColumn get id => integer()();

  IntColumn get jurisdictionId =>
      integer().named('jurisdiction_id').customConstraint('NOT NULL REFERENCES jurisdiction(id)')();

  /// `null` means the whole jurisdiction.
  IntColumn get zoneId =>
      integer().named('zone_id').nullable().customConstraint('REFERENCES zone(id)')();

  IntColumn get speciesId =>
      integer().named('species_id').customConstraint('NOT NULL REFERENCES species(id)')();

  TextColumn get waterType => text()
      .named('water_type')
      .customConstraint("NOT NULL CHECK (water_type IN ('salt','fresh','both'))")();

  /// Millimetres, always. A `45` meant as centimetres is wrong by a factor of
  /// ten and validates cleanly, which is why A1 range-checks it by taxon group.
  IntColumn get minSizeMm => integer().named('min_size_mm').nullable()();

  IntColumn get maxSizeMm => integer().named('max_size_mm').nullable()();

  IntColumn get measurementMethodId => integer()
      .named('measurement_method_id')
      .nullable()
      .customConstraint('REFERENCES measurement_method(id)')();

  IntColumn get bagLimit => integer().named('bag_limit').nullable()();

  TextColumn get bagLimitUnit => text()
      .named('bag_limit_unit')
      .nullable()
      .customConstraint("CHECK (bag_limit_unit IN ('count','kg'))")();

  TextColumn get bagLimitPeriod => text()
      .named('bag_limit_period')
      .nullable()
      .customConstraint("CHECK (bag_limit_period IN ('day','trip','season'))")();

  /// A per-vessel cap, distinct from the per-person bag limit.
  IntColumn get vesselLimit => integer().named('vessel_limit').nullable()();

  BoolColumn get isProtected =>
      boolean().named('is_protected').withDefault(const Constant<bool>(false))();

  IntColumn get licenceTypeId => integer()
      .named('licence_type_id')
      .nullable()
      .customConstraint('REFERENCES licence_type(id)')();

  TextColumn get notesKey => text().named('notes_key').nullable()();

  IntColumn get citationId =>
      integer().named('citation_id').customConstraint('NOT NULL REFERENCES citation(id)')();

  TextColumn get validFrom => text().named('valid_from')();

  /// **Expiry does not delete** (§7.3). A lapsed *orde de vedas* is still
  /// evaluated and still shown, behind the ochre bar.
  TextColumn get validTo => text().named('valid_to').nullable()();

  IntColumn get specificity => integer().withDefault(const Constant<int>(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  /// §7.1's one table-level `CHECK`. An inverted window makes every fish both
  /// too small and too large.
  @override
  List<String> get customConstraints => <String>[
    'CHECK (min_size_mm IS NULL OR max_size_mm IS NULL OR max_size_mm >= min_size_mm)',
  ];
}

/// `SPEC.md` §7.1 `closed_season`.
///
/// The two recurrence kinds use different columns, which is why all six bounds
/// are nullable and A1 checks the pair the recurrence names.
@DataClassName('ClosedSeasonRow')
class ClosedSeasons extends Table {
  @override
  String get tableName => 'closed_season';

  IntColumn get id => integer()();

  IntColumn get ruleId => integer()
      .named('rule_id')
      .customConstraint('NOT NULL REFERENCES rule(id) ON DELETE CASCADE')();

  TextColumn get recurrence =>
      text().customConstraint("NOT NULL CHECK (recurrence IN ('annual','fixed'))")();

  IntColumn get startMonth => integer().named('start_month').nullable()();

  IntColumn get startDay => integer().named('start_day').nullable()();

  IntColumn get endMonth => integer().named('end_month').nullable()();

  IntColumn get endDay => integer().named('end_day').nullable()();

  TextColumn get startDate => text().named('start_date').nullable()();

  TextColumn get endDate => text().named('end_date').nullable()();

  TextColumn get notesKey => text().named('notes_key').nullable()();

  IntColumn get citationId =>
      integer().named('citation_id').nullable().customConstraint('REFERENCES citation(id)')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
