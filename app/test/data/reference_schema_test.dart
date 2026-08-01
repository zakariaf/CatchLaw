// The schema drift describes, checked against the SPEC.md §7.1 it must mirror.
//
// These run against an in-memory database created by drift's own createAll(),
// which is a SECOND description of a schema whose producer is
// tools/content_builder/. Nothing forces the two to agree, so the DAO tests of
// T07 read a real built file — and reference_open_test.dart proves the two
// descriptions match on the file that ships.

import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fixtures/reference_fixture.dart';

/// The 22 tables `SPEC.md` §7.1 declares.
const Set<String> kSpecTables = <String>{
  'jurisdiction',
  'zone',
  'zone_ring',
  'family',
  'species',
  'species_name',
  'measurement_method',
  'citation',
  'rule',
  'closed_season',
  'licence_type',
  'gear_rule',
  'penalty',
  'lookalike',
  'glossary_term',
  'content_change',
  'key_node',
  'key_leaf_species',
  'key_option',
  'content_string',
  'legal_text',
  'content_meta',
};

/// The 7 indexes `SPEC.md` §7.1 declares.
const Set<String> kSpecIndexes = <String>{
  'idx_zone_juris',
  'idx_zone_bbox',
  'idx_species_family',
  'idx_name_search',
  'idx_name_species',
  'idx_rule_lookup',
  'idx_rule_zone',
};

void main() {
  late ReferenceDatabase db;

  setUp(() {
    db = inMemoryReference();
    addTearDown(db.close);
  });

  test('ReferenceDatabase reports schemaVersion 1', () {
    // Frozen. A bump here is how somebody starts treating content as
    // migratable, and an incrementally patched reference database has no single
    // provenance for catch.content_version to name.
    expect(db.schemaVersion, 1);
  });

  test('ReferenceDatabase.migration throws from onCreate', () async {
    // Rule 4 in executable form: content is shipped, never created. The
    // forTesting seam is the one exception and it is marked as such.
    final shipped = ReferenceDatabase(NativeDatabase.memory());
    addTearDown(shipped.close);

    await expectLater(
      shipped.customStatement('SELECT 1'),
      throwsA(isA<StateError>()),
      reason: 'the first statement forces the open, which forces onCreate',
    );
  });

  test('ReferenceDatabase.migration throws from onUpgrade', () async {
    // The half an ALTER TABLE would arrive through.
    await expectLater(db.migration.onUpgrade(Migrator(db), 1, 2), throwsA(isA<StateError>()));
  });

  test('ReferenceDatabase exposes all 22 tables of SPEC 7.1', () {
    // A table silently missing from @DriftDatabase is invisible until the
    // screen that needs it, five epics later.
    expect(
      db.allTables.map((TableInfo<Table, dynamic> t) => t.actualTableName).toSet(),
      kSpecTables,
    );
  });

  test('ReferenceDatabase declares the 7 indexes of SPEC 7.1', () async {
    // Search latency at 2,400 names is an index, not a hope.
    final List<QueryRow> rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'")
        .get();

    expect(rows.map((QueryRow r) => r.read<String>('name')).toSet(), kSpecIndexes);
  });

  test('content_string is stored WITHOUT ROWID', () async {
    // The difference between one page read and two on every localised string.
    expect(await _ddl(db, 'content_string'), contains('WITHOUT ROWID'));
  });

  test('key_leaf_species is stored WITHOUT ROWID with a composite primary key', () async {
    final String ddl = await _ddl(db, 'key_leaf_species');

    expect(ddl, contains('WITHOUT ROWID'));
    // Quoting is drift's; the shape is §7.1's.
    expect(
      ddl.replaceAll('"', '').replaceAll(RegExp(r'\s+'), ' '),
      contains('PRIMARY KEY (node_id, species_id)'),
    );
  });

  test('species_name rejects a gender outside m, f and n', () async {
    // §9.5 needs gender to be trustworthy in five gendered locales.
    await _seedSpecies(db);

    await expectLater(
      db.customStatement(
        'INSERT INTO species_name (id, species_id, locale, name, search_norm, gender) '
        "VALUES (1, 1, 'es', 'Almeja', 'almeja', 'x')",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('zone rejects a water_type outside salt, fresh and both', () async {
    await _seedJurisdiction(db);

    await expectLater(
      db.customStatement(
        'INSERT INTO zone (id, jurisdiction_id, code, name_key, water_type, zone_kind) '
        "VALUES (1, 1, 'z', 'k', 'brackish', 'region')",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('rule rejects max_size_mm below min_size_mm', () async {
    // An inverted window makes every fish both too small and too large.
    await _seedSpecies(db);
    await _seedCitation(db);

    await expectLater(
      db.customStatement(
        'INSERT INTO rule (id, jurisdiction_id, species_id, water_type, min_size_mm, '
        'max_size_mm, citation_id, valid_from) '
        "VALUES (1, 1, 1, 'salt', 450, 380, 1, '2012-08-01')",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('zone_ring cascades when its zone is deleted', () async {
    // ON DELETE CASCADE only fires with PRAGMA foreign_keys = ON, so this also
    // proves the pragma reached the connection.
    await db.customStatement('PRAGMA foreign_keys = ON');
    await _seedJurisdiction(db);
    await db.customStatement(
      'INSERT INTO zone (id, jurisdiction_id, code, name_key, water_type, zone_kind) '
      "VALUES (1, 1, 'z', 'k', 'salt', 'region')",
    );
    await db.customStatement(
      'INSERT INTO zone_ring (id, zone_id, ring_index, point_count, coords) '
      "VALUES (1, 1, 0, 0, x'')",
    );

    await db.customStatement('DELETE FROM zone WHERE id = 1');

    expect(await db.customSelect('SELECT * FROM zone_ring').get(), isEmpty);
  });
}

Future<String> _ddl(ReferenceDatabase db, String table) async =>
    (await db
            .customSelect(
              'SELECT sql FROM sqlite_master WHERE name = ?',
              variables: <Variable<Object>>[Variable<String>(table)],
            )
            .getSingle())
        .read<String>('sql');

Future<void> _seedJurisdiction(ReferenceDatabase db) => db.customStatement(
  'INSERT INTO jurisdiction (id, code, country_iso2, name_key, authority_key, '
  'default_locale, legal_text_locales, content_version, published_on, checked_on) '
  "VALUES (1, 'ES-GA', 'ES', 'k', 'k', 'gl', 'gl', '1', '2012-07-27', '2026-07-14')",
);

Future<void> _seedSpecies(ReferenceDatabase db) async {
  await _seedJurisdiction(db);
  await db.customStatement("INSERT INTO family (id, scientific, name_key) VALUES (1, 'V', 'k')");
  await db.customStatement(
    'INSERT INTO species (id, scientific_name, family_id, taxon_group, silhouette_asset) '
    "VALUES (1, 'Venerupis corrugata', 1, 'bivalve', 'sil/v.svg')",
  );
}

Future<void> _seedCitation(ReferenceDatabase db) => db.customStatement(
  'INSERT INTO citation (id, jurisdiction_id, instrument_type_key, instrument_ref, '
  "published_on, retrieved_on) VALUES (1, 1, 'k', 'Orde', '2012-08-06', '2026-08-12')",
);
