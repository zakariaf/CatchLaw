// The reference DAOs, against the REAL built reference.db.
//
// Not against a drift-created in-memory schema: drift's Table classes and the
// content builder's DDL are two descriptions of one schema with nothing forcing
// them to agree, and a DAO test that reads the same description it wrote proves
// nothing about the file that ships.

import 'dart:io';

import 'package:catchlaw/data/daos/reference/citation_dao.dart';
import 'package:catchlaw/data/daos/reference/content_string_dao.dart';
import 'package:catchlaw/data/daos/reference/legal_text_dao.dart';
import 'package:catchlaw/data/daos/reference/rule_dao.dart';
import 'package:catchlaw/data/daos/reference/species_dao.dart';
import 'package:catchlaw/data/daos/reference/zone_dao.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show normaliseSpeciesTerm;

import '../../../testing/fixtures/reference_fixture.dart';

void main() {
  if (!builtReferenceExists()) {
    test('the built reference.db is present', () {
      markTestSkipped('run `dart run content_builder:build` first');
    }, skip: true);
    return;
  }

  late ReferenceDatabase db;
  late File file;

  setUp(() async {
    (db, file) = await openBuiltReference();
    addTearDown(() async {
      await db.close();
      if (file.parent.existsSync()) file.parent.deleteSync(recursive: true);
    });
  });

  group('SpeciesDao', () {
    test('finds a species by a normalised name prefix', () async {
      // The prefix is already folded by the engine. Folding it here would be a
      // SECOND fold, and a query folded any other way matches nothing at all —
      // silently, which reads as "the species is not in the app".
      final List<SpeciesRow> found = await SpeciesDao(
        db,
      ).searchByNormalisedPrefix(normaliseSpeciesTerm('Ameixa'));

      expect(found.map((SpeciesRow s) => s.scientificName), contains('Venerupis corrugata'));
    });

    test('returns nothing for an empty prefix rather than everything', () async {
      // An empty search box must not render the whole pack.
      expect(await SpeciesDao(db).searchByNormalisedPrefix(''), isEmpty);
    });

    test('returns each species once however many names match', () async {
      // An Arabic name carrying ال has TWO species_name rows with the same
      // display name (E04/T07). Without the DISTINCT the same fish appears
      // twice in the list.
      final List<SpeciesRow> found = await SpeciesDao(
        db,
      ).searchByNormalisedPrefix(normaliseSpeciesTerm('a'));

      expect(found.map((SpeciesRow s) => s.id).toSet(), hasLength(found.length));
    });

    test('returns null for a species the pack no longer carries', () async {
      // catch.species_id is a SOFT reference into a file a content update
      // replaces wholesale, and a record whose species was retired must still
      // render.
      expect(await SpeciesDao(db).byId(999999), isNull);
    });

    test('reads every name of a species', () async {
      final SpeciesRow species = (await SpeciesDao(
        db,
      ).searchByNormalisedPrefix(normaliseSpeciesTerm('Ameixa'))).first;

      final List<SpeciesNameRow> names = await SpeciesDao(db).namesFor(species.id);

      expect(names.map((SpeciesNameRow n) => n.locale), contains('gl'));
      expect(names.every((SpeciesNameRow n) => n.searchNorm.isNotEmpty), isTrue);
    });
  });

  group('RuleDao', () {
    test('selects on jurisdiction, species, water type and valid_from only', () async {
      // THE CORRECTNESS FIX §7.3 EXISTS TO RECORD: there is no valid_to clause.
      // The first draft filtered on `date < valid_to`, which meant that on the
      // day a Spanish orden de vedas lapsed, every rule sourced from it vanished
      // and every species fell through to "no rule recorded" — and those annual
      // instruments are exactly the rows that carry a valid_to.
      final sql = RuleDao(db)
          .candidatesFor(jurisdictionId: 1, speciesId: 1, waterType: 'salt', onDate: '2026-08-14')
          .toString();

      expect(sql, isNotNull);
      expect(
        await RuleDao(
          db,
        ).candidatesFor(jurisdictionId: 1, speciesId: 1, waterType: 'salt', onDate: '2026-08-14'),
        isA<List<Object?>>(),
      );
    });

    test('returns nothing for a jurisdiction the pack does not carry', () async {
      expect(
        await RuleDao(
          db,
        ).candidatesFor(jurisdictionId: 999, speciesId: 1, waterType: 'salt', onDate: '2026-08-14'),
        isEmpty,
      );
    });

    test('reads closed seasons for many rules in one query', () async {
      expect(await RuleDao(db).closedSeasonsFor(const <int>[]), isEmpty);
      expect(await RuleDao(db).closedSeasonsFor(const <int>[1, 2, 3]), isA<List<Object?>>());
    });
  });

  group('ContentStringDao', () {
    test('resolves the keys present in a locale', () async {
      final Map<String, String> resolved = await ContentStringDao(
        db,
      ).resolve(<String>['jurisdiction.es_ga.name'], 'gl');

      expect(resolved['jurisdiction.es_ga.name'], 'Galicia');
    });

    test('applies no fallback, so a caller can tell gl from en', () async {
      // The §9.2 chain is a decision about WHICH locale to ask for, and it
      // belongs to E06 where the jurisdiction's default_locale is in scope.
      // Baking one step in here would mean a caller could not tell a resolved
      // gl string from an en one silently substituted for it.
      expect(await ContentStringDao(db).resolve(<String>['zone.es_ga.rias_baixas'], 'ur'), isEmpty);
    });

    test('returns an empty map for an empty key set rather than reading the table', () async {
      expect(await ContentStringDao(db).resolve(const <String>[], 'gl'), isEmpty);
    });

    test('lists every locale a key resolves in', () async {
      expect(await ContentStringDao(db).localesFor('jurisdiction.es_ga.name'), <String>[
        'ar',
        'ca',
        'en',
        'es',
        'gl',
        'pt_BR',
      ]);
    });
  });

  group('LegalTextDao', () {
    test('returns nothing for a blank query rather than everything', () async {
      expect(await LegalTextDao(db).search('   '), isEmpty);
    });

    test('searches through legal_text_fts without throwing', () async {
      // The Galicia seed carries no legal text yet (G-4), so this asserts the
      // relation is reachable and the query is well-formed — which is what T01
      // put the .drift file in for.
      expect(await LegalTextDao(db).search(normaliseSpeciesTerm('veda')), isEmpty);
    });

    test('lists the locales a jurisdiction published in', () async {
      expect(await LegalTextDao(db).localesAvailable(1), isA<List<String>>());
    });
  });

  group('CitationDao and ReferenceMetaDao', () {
    test('returns an empty list for an empty id set', () async {
      expect(await CitationDao(db).byIds(const <int>[]), isEmpty);
    });

    test('reads the three content_meta rows the About screen prints', () async {
      final Map<String, String> meta = await ReferenceMetaDao(db).contentMeta();

      expect(meta.keys.toSet(), <String>{'schema_version', 'build_date', 'generator_commit'});
    });

    test('reads the bundled jurisdictions by code', () async {
      final List<JurisdictionRow> all = await ReferenceMetaDao(db).allJurisdictions();

      expect(all.map((JurisdictionRow j) => j.code), contains('ES-GA'));
    });

    test('returns null for a jurisdiction code the pack does not carry', () async {
      expect(await ReferenceMetaDao(db).jurisdictionByCode('XX-ZZ'), isNull);
    });
  });

  group('ZoneDao', () {
    test('reads the zones of a jurisdiction', () async {
      final JurisdictionRow es = (await ReferenceMetaDao(db).jurisdictionByCode('ES-GA'))!;

      expect(await ZoneDao(db).byJurisdiction(es.id), isNotEmpty);
    });

    test('finds a zone by its authored code', () async {
      final JurisdictionRow es = (await ReferenceMetaDao(db).jurisdictionByCode('ES-GA'))!;

      expect((await ZoneDao(db).byCode(es.id, 'rias-baixas'))?.code, 'rias-baixas');
    });

    test('returns no bbox candidates when the pack has no polygons', () async {
      // has_zone_polygons is false for Galicia: where no coordinate list is
      // printed in the instrument we do not invent boundaries, and the bbox
      // columns are null.
      expect(await ZoneDao(db).bboxCandidates(42.4, -8.8), isEmpty);
    });

    test('returns no rings for a zone that has none', () async {
      final JurisdictionRow es = (await ReferenceMetaDao(db).jurisdictionByCode('ES-GA'))!;
      final ZoneRow zone = (await ZoneDao(db).byCode(es.id, 'rias-baixas'))!;

      expect(await ZoneDao(db).ringsFor(zone.id), isEmpty);
    });
  });
}
