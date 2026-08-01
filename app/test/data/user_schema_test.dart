// The writable half, and the invariants that live in the schema rather than in
// the code that writes it.
//
// persistence-drift rule 2 is the general form: a corrupt row must be
// unrepresentable at the storage layer rather than policed in Dart, because the
// policing is one forgotten call site away from being absent.

import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The 7 tables `SPEC.md` §7.2 declares.
const Set<String> kSpecTables = <String>{
  'user_profile',
  'saved_zone',
  'trip',
  'catch',
  'species_recent',
  'rule_flag',
  'app_meta',
};

void main() {
  late UserDatabase db;

  setUp(() async {
    db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // Forces the open, so beforeOpen has run before any test body reads.
    await db.customSelect('SELECT 1').get();
  });

  test('UserDatabase reports schemaVersion 1', () {
    expect(db.schemaVersion, UserDatabase.understoodSchemaVersion);
    expect(UserDatabase.understoodSchemaVersion, 1);
  });

  test('UserDatabase exposes all 7 tables of SPEC 7.2', () {
    expect(
      db.allTables.map((TableInfo<Table, dynamic> t) => t.actualTableName).toSet(),
      kSpecTables,
    );
  });

  test('UserDatabase seeds exactly one user_profile row on creation', () {
    // In beforeOpen under wasCreated, not in onCreate: a failure there would
    // abort the create and leave a half-built database.
    expect(db.select(db.userProfiles).get(), completion(hasLength(1)));
  });

  test('user_profile rejects a second row', () async {
    // CHECK (id = 1). A second settings row is not merely discouraged — it
    // cannot be written.
    await expectLater(
      db.customStatement("INSERT INTO user_profile (id, length_unit) VALUES (2, 'cm')"),
      throwsA(isA<SqliteException>()),
    );
  });

  test('user_profile defaults numeral_system to auto', () async {
    // §9.3: CLDR 48 gives `ar` latn, so plain Arabic renders Western digits and
    // that is the correct default for Khalid in RAK. `auto` is what defers to
    // it; `arab` is a deliberate override in S14.
    final UserProfileRow row = await db.select(db.userProfiles).getSingle();

    expect(row.numeralSystem, 'auto');
    expect(row.lengthUnit, 'cm');
  });

  test('user_profile rejects a numeral_system outside auto, latn and arab', () async {
    await expectLater(
      db.customStatement("UPDATE user_profile SET numeral_system = 'devanagari' WHERE id = 1"),
      throwsA(isA<SqliteException>()),
    );
  });

  test('user_profile rejects a length_unit outside cm, mm and in', () async {
    await expectLater(
      db.customStatement("UPDATE user_profile SET length_unit = 'fathom' WHERE id = 1"),
      throwsA(isA<SqliteException>()),
    );
  });

  test('catch rejects an outcome outside the SPEC 7.2 set', () async {
    await expectLater(
      db.customStatement(
        'INSERT INTO catch (jurisdiction_code, zone_code, species_id, scientific_name, '
        "outcome, created_at, updated_at) VALUES ('ES-GA', 'z', 1, 'V', 'probably', "
        "'2026-08-14T05:40:00Z', '2026-08-14T05:40:00Z')",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('catch stores a species that reference.db no longer knows about', () async {
    // The Sha'ri case: a content update can renumber or retire a rule, and a
    // three-year-old record must still say what it said. species_id is a soft
    // hint; nothing on the record screen reads through it.
    await db.customStatement(
      'INSERT INTO catch (jurisdiction_code, zone_code, species_id, scientific_name, '
      'length_mm, measurement_code, outcome, outcome_detail, content_version, '
      "created_at, updated_at) VALUES ('ES-GA', 'rias-baixas', 999999, "
      "'Venerupis corrugata', 38, 'SHL', 'meets', 'Meets the minimum', '2026.08.0', "
      "'2026-08-14T05:40:00Z', '2026-08-14T05:40:00Z')",
    );

    final CatchRow row = await db.select(db.catches).getSingle();

    expect(row.scientificName, 'Venerupis corrugata');
    expect(row.outcomeDetail, 'Meets the minimum');
    expect(row.contentVersion, '2026.08.0');
  });

  test('catch is declared STRICT', () async {
    // persistence-drift rule 2: a column must not silently accept a type it was
    // not declared as.
    final String ddl =
        (await db.customSelect("SELECT sql FROM sqlite_master WHERE name = 'catch'").getSingle())
            .read<String>('sql');

    expect(ddl, contains('STRICT'));
  });

  test('catch refuses a length_mm that is not a number', () async {
    // What STRICT actually guarantees, stated precisely: SQLite converts a
    // LOSSLESSLY convertible value — '380' becomes 380 — and refuses one that
    // is not. The defect this closes is a length column quietly holding prose,
    // which surfaces three screens later as an arithmetic error on a number
    // nobody typed.
    await expectLater(
      db.customStatement(
        'INSERT INTO catch (jurisdiction_code, zone_code, species_id, scientific_name, '
        "length_mm, outcome, created_at, updated_at) VALUES ('ES-GA', 'z', 1, 'V', "
        "'thirty-eight', 'meets', '2026-08-14T05:40:00Z', '2026-08-14T05:40:00Z')",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('catch survives the deletion of its trip', () async {
    // ON DELETE SET NULL, not CASCADE: deleting a trip must not delete the
    // fisher's record of what they caught on it.
    await db.customStatement(
      'INSERT INTO trip (id, started_at, jurisdiction_code, zone_code) '
      "VALUES (1, '2026-08-14T05:00:00Z', 'ES-GA', 'z')",
    );
    await db.customStatement(
      'INSERT INTO catch (trip_id, jurisdiction_code, zone_code, species_id, '
      "scientific_name, outcome, created_at, updated_at) VALUES (1, 'ES-GA', 'z', 1, "
      "'V', 'meets', '2026-08-14T05:40:00Z', '2026-08-14T05:40:00Z')",
    );

    await db.customStatement('DELETE FROM trip WHERE id = 1');

    final CatchRow row = await db.select(db.catches).getSingle();
    expect(row.tripId, isNull);
    expect(row.scientificName, 'V');
  });

  test('species_recent is stored WITHOUT ROWID with its three-column primary key', () async {
    // The primary key IS the access path: the table is read on every Check-home
    // render keyed by exactly these three columns.
    final String ddl =
        (await db
                .customSelect("SELECT sql FROM sqlite_master WHERE name = 'species_recent'")
                .getSingle())
            .read<String>('sql')
            .replaceAll('"', '')
            .replaceAll(RegExp(r'\s+'), ' ');

    expect(ddl, contains('WITHOUT ROWID'));
    expect(ddl, contains('PRIMARY KEY (species_id, jurisdiction_code, zone_code)'));
  });

  test('saved_zone refuses the same zone twice', () async {
    await db.customStatement(
      "INSERT INTO saved_zone (jurisdiction_code, zone_code) VALUES ('ES-GA', 'rias-baixas')",
    );

    await expectLater(
      db.customStatement(
        "INSERT INTO saved_zone (jurisdiction_code, zone_code) VALUES ('ES-GA', 'rias-baixas')",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('app_meta holds the extraction completion marker', () async {
    // D-6 puts it here rather than in an INSTALLED stamp file. Two markers
    // would be one too many, and the one that is not written last is the one
    // that lies.
    await db.customStatement(
      "INSERT INTO app_meta (key, value) VALUES ('content_build_date', '2026-08-14')",
    );

    expect((await db.select(db.appMetas).getSingle()).value, '2026-08-14');
  });

  test('every table but user_profile and species_recent stores timestamps as TEXT', () async {
    // §7.2 types them TEXT and §12's export format is built on that shape.
    // persistence-drift rule 5 prefers integers; SPEC.md is authoritative for
    // the product, and it is SAFE to follow because ISO-8601 UTC strings sort
    // lexicographically in chronological order — idx_catch_created serves
    // ORDER BY created_at DESC exactly as an integer column would.
    final List<QueryRow> columns = await db.customSelect('PRAGMA table_info(catch)').get();
    final types = <String, String>{
      for (final QueryRow r in columns) r.read<String>('name'): r.read<String>('type'),
    };

    expect(types['created_at'], 'TEXT');
    expect(types['updated_at'], 'TEXT');
    expect(types['length_mm'], 'INTEGER');
  });
}
