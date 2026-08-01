import 'package:drift/drift.dart';

/// `SPEC.md` §7.2 `species_recent` — what S1 offers first.
///
/// `WITHOUT ROWID` with a three-column primary key, because the table is read on
/// every Check-home render keyed by exactly those three columns: the primary key
/// **is** the access path, and a rowid would be one extra indirection on the
/// 1.2 s cold-start path.
@DataClassName('SpeciesRecentRow')
class SpeciesRecents extends Table {
  @override
  String get tableName => 'species_recent';

  IntColumn get speciesId => integer().named('species_id')();

  TextColumn get jurisdictionCode => text().named('jurisdiction_code')();

  TextColumn get zoneCode => text().named('zone_code')();

  IntColumn get useCount => integer().named('use_count').withDefault(const Constant<int>(1))();

  TextColumn get lastUsedAt => text().named('last_used_at')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{speciesId, jurisdictionCode, zoneCode};

  @override
  bool get withoutRowId => true;

  @override
  bool get isStrict => true;
}
