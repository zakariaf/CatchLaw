// One round trip per mapper.
//
// A mapper is fifteen lines of field assignment, which is exactly why it is
// worth testing: nothing about `minLat: row.minLat, minLon: row.minLon` fails
// to compile when the two are swapped, and a swapped pair puts a bounding box
// in the wrong hemisphere. Each test writes a row through SQL, reads it back
// through the DAO and asserts the domain object field by field.

import 'package:catchlaw/data/daos/reference/citation_dao.dart';
import 'package:catchlaw/data/daos/reference/rule_dao.dart';
import 'package:catchlaw/data/daos/reference/species_dao.dart';
import 'package:catchlaw/data/daos/reference/zone_dao.dart';
import 'package:catchlaw/data/daos/user/catch_dao.dart';
import 'package:catchlaw/data/daos/user/trip_dao.dart';
import 'package:catchlaw/data/daos/user/user_settings_dao.dart';
import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/model/mappers.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' as engine;

import '../../../testing/fixtures/reference_fixture.dart';
import '../../../testing/models/user_fixtures.dart';

void main() {
  group('reference', () {
    late ReferenceDatabase db;

    setUp(() async {
      db = inMemoryReference();
      addTearDown(db.close);
      await _seedReference(db);
    });

    test('toSpecies carries every column of the species row', () async {
      final Species species = toSpecies((await SpeciesDao(db).byId(1))!);

      expect(species.id, 1);
      expect(species.scientificName, kHostileScientificName);
      expect(species.familyId, 1);
      expect(species.taxonGroup, engine.TaxonGroup.finfish);
      expect(species.silhouetteAsset, 'sil/e.svg');
      expect(species.colId, 'COL:6X2QW');
      expect(species.plateAsset, 'plate/e.webp');
    });

    test('toSpeciesName carries the gender a gendered locale requires', () async {
      final List<SpeciesName> names = (await SpeciesDao(
        db,
      ).namesFor(1)).map(toSpeciesName).toList();

      expect(names.single.name, kHostileVernacular);
      expect(names.single.locale, 'ar');
      expect(names.single.gender, NameGender.m);
      expect(names.single.isPrimary, isTrue);
    });

    test('toZone keeps the bounding box corners apart', () async {
      // The swap that compiles. min/max and lat/lon are four doubles of the same
      // type in the same order, and a zone whose corners are crossed matches
      // nothing — which reads as "no rule recorded" for the whole ría.
      final Zone zone = (await ZoneDao(db).byJurisdiction(1)).map(toZone).single;

      expect(zone.code, 'RIA-AROUSA');
      expect(zone.waterType, WaterKind.salt);
      expect(zone.zoneKind, engine.ZoneKind.region);
      expect((zone.minLat, zone.maxLat), (42.4, 42.7));
      expect((zone.minLon, zone.maxLon), (-9.1, -8.7));
    });

    test('toCitation carries the four fields the footnote prints', () async {
      final engine.Citation citation = toCitation((await CitationDao(db).byId(1))!);

      expect(citation.instrument, 'Orde do 27 de xullo de 2012');
      expect(citation.article, 'Anexo II');
      expect(citation.publishedOn, '2012-08-06');
      // checkedOn is retrieved_on: when a HUMAN read the gazette, which is the
      // only fact the footnote claims.
      expect(citation.checkedOn, '2026-07-14');
    });

    test('toRule requires the citation rather than defaulting one', () async {
      // Invariant 3 at the one seam that could break it. A placeholder Citation
      // renders a footnote that cites nothing, and a verdict that cites nothing
      // is an opinion.
      final RuleRow row = (await RuleDao(db).candidatesFor(
        jurisdictionId: 1,
        speciesId: 1,
        waterType: 'salt',
        onDate: '2026-08-01',
      )).single;
      final engine.Citation citation = toCitation((await CitationDao(db).byId(1))!);

      // The method is passed IN, resolved from `measurement_method.code`. The
      // mapper deliberately cannot derive it from `measurement_method_id`: the
      // build numbers that column by insertion order.
      final engine.Rule rule = toRule(
        row,
        citation: citation,
        method: engine.MeasurementMethod.shellLength,
      );

      expect(rule.citation.instrument, 'Orde do 27 de xullo de 2012');
      expect(rule.minSizeMm, 450);
      expect(rule.waterType, engine.WaterType.salt);
      expect(rule.isProtected, isFalse);
      expect(rule.validTo, isNull);
    });

    test('toClosedSeason carries the recurrence and both endpoints', () async {
      final ClosedSeasonRow row = (await RuleDao(db).closedSeasonsFor(<int>[1])).single;
      final engine.Citation citation = toCitation((await CitationDao(db).byId(1))!);

      final engine.ClosedSeason season = toClosedSeason(row, citation: citation);

      expect(season.recurrence, engine.Recurrence.annual);
      expect((season.startMonth, season.startDay), (5, 1));
      expect((season.endMonth, season.endDay), (8, 31));
      expect(season.citation.instrument, 'Orde do 27 de xullo de 2012');
    });
  });

  group('user', () {
    late UserDatabase db;

    setUp(() {
      db = UserDatabase(NativeDatabase.memory());
      addTearDown(db.close);
    });

    test('toCatchRecord survives an apostrophe, an em dash and a backslash', () async {
      await TripDao(db).startTrip(
        startedAt: '2026-08-01T05:40:00Z',
        jurisdictionCode: 'ES-GA',
        zoneCode: 'RIA-AROUSA',
        label: kHostileTripLabel,
      );
      final dao = CatchDao(db);
      await dao.insertCatch(kCatchDraftAmeixa.toCompanion(tripId: 1));

      final CatchRecord record = (await dao.watchForTrip(1).first).map(toCatchRecord).single;

      expect(record.outcomeDetail, kHostileOutcomeDetail);
      expect(record.ruleCitationRef, kHostileCitationRef);
      expect(record.outcome, CatchOutcome.fails);
      expect(record.lengthMm, 380, reason: 'integer millimetres, never a double centimetre');
      expect(record.wasKept, isFalse);
      expect((record.latitude, record.longitude), (null, null));
    });

    test('toTallyEntry carries the counts the day sheet prints', () async {
      final dao = CatchDao(db);
      await dao.insertCatch(kCatchDraftAmeixa.toCompanion());

      final SpeciesTallyEntry entry =
          (await dao
                  .watchTallyForDay('2026-08-01', jurisdictionCode: 'ES-GA', zoneCode: 'RIA-AROUSA')
                  .first)
              .map(toTallyEntry)
              .single;

      expect(entry.scientificName, kHostileScientificName);
      expect((entry.count, entry.kept), (1, 0));
    });

    test('toTrip keeps a whitespace-only note as whitespace', () async {
      // Not null, and not empty. A TRIM-then-NULLIF somewhere in the chain
      // discards it, and the fisher's note is gone with nothing to say so.
      await TripDao(db).startTrip(
        startedAt: '2026-08-01T05:40:00Z',
        jurisdictionCode: 'ES-GA',
        zoneCode: 'RIA-AROUSA',
        label: kHostileTripLabel,
      );
      await db.customStatement('UPDATE trip SET notes = ? WHERE id = 1', <Object?>[
        kHostileTripNotes,
      ]);

      final Trip trip = toTrip((await TripDao(db).watchOpenTrip().first)!);

      expect(trip.label, kHostileTripLabel);
      expect(trip.notes, kHostileTripNotes);
      expect(trip.endedAt, isNull);
    });

    test('toSavedZone and toRecentSpecies carry their ordering columns', () async {
      await SavedZoneDao(
        db,
      ).save(jurisdictionCode: 'ES-GA', zoneCode: 'RIA-AROUSA', label: kHostileTripLabel);
      await CatchDao(db).insertCatch(kCatchDraftAmeixa.toCompanion());

      final SavedZone zone = (await SavedZoneDao(db).watchAll().first).map(toSavedZone).single;
      final RecentSpecies recent =
          (await SpeciesRecentDao(
                db,
              ).watchRecent(jurisdictionCode: 'ES-GA', zoneCode: 'RIA-AROUSA').first)
              .map(toRecentSpecies)
              .single;

      expect(zone.sortOrder, 0);
      expect(zone.label, kHostileTripLabel);
      expect(recent.useCount, 1, reason: 'the recency bump is what puts a species back on S1');
      expect(recent.lastUsedAt, '2026-08-01T05:40:00Z');
    });

    test('toUserProfile decodes every CHECKed column into its enum', () async {
      final UserProfile profile = toUserProfile(await UserProfileDao(db).read());

      expect(profile.numeralSystem, NumeralSystem.auto);
      expect(profile.lengthUnit, LengthUnit.cm);
      expect(profile.captureCoordinates, isFalse);
      expect(profile.sunlightMode, isFalse);
      expect(profile.gloveMode, isFalse);
    });

    test('toUserProfile falls back rather than throwing on an unrecognised value', () async {
      // The string comes out of a file a content update replaces wholesale. A
      // `values.byName` here throws at 05:40 on a row written by a build this
      // one has never seen, and the fallback is a setting rendered wrong for one
      // launch instead of an app that will not start.
      await db.customStatement("UPDATE user_profile SET numeral_system = 'auto' WHERE id = 1");

      final UserProfile profile = toUserProfile(
        (await UserProfileDao(db).read()).copyWith(numeralSystem: 'devanagari'),
      );

      expect(profile.numeralSystem, NumeralSystem.auto);
    });
  });
}

Future<void> _seedReference(ReferenceDatabase db) async {
  await db.customStatement(
    'INSERT INTO jurisdiction (id, code, country_iso2, name_key, authority_key, '
    'default_locale, legal_text_locales, content_version, published_on, checked_on) '
    "VALUES (1, 'ES-GA', 'ES', 'k', 'k', 'gl', 'gl', '1', '2012-07-27', '2026-07-14')",
  );
  await db.customStatement(
    'INSERT INTO zone (id, jurisdiction_id, code, name_key, water_type, zone_kind, '
    "min_lat, min_lon, max_lat, max_lon) VALUES (1, 1, 'RIA-AROUSA', 'k', 'salt', "
    "'region', 42.4, -9.1, 42.7, -8.7)",
  );
  await db.customStatement(
    "INSERT INTO family (id, scientific, name_key) VALUES (1, 'Serranidae', 'k')",
  );
  await db.customStatement(
    'INSERT INTO species (id, scientific_name, family_id, taxon_group, silhouette_asset, '
    "col_id, plate_asset) VALUES (1, ?, 1, 'finfish', 'sil/e.svg', 'COL:6X2QW', 'plate/e.webp')",
    <Object?>[kHostileScientificName],
  );
  await db.customStatement(
    'INSERT INTO species_name (id, species_id, locale, name, search_norm, gender, is_primary) '
    "VALUES (1, 1, 'ar', ?, ?, 'm', 1)",
    <Object?>[kHostileVernacular, kHostileVernacular],
  );
  await db.customStatement(
    'INSERT INTO citation (id, jurisdiction_id, instrument_type_key, instrument_ref, '
    "article_ref, published_on, retrieved_on) VALUES (1, 1, 'k', "
    "'Orde do 27 de xullo de 2012', 'Anexo II', '2012-08-06', '2026-07-14')",
  );
  await db.customStatement(
    'INSERT INTO rule (id, jurisdiction_id, species_id, water_type, min_size_mm, '
    "citation_id, valid_from) VALUES (1, 1, 1, 'salt', 450, 1, '2012-08-01')",
  );
  await db.customStatement(
    'INSERT INTO closed_season (id, rule_id, recurrence, start_month, start_day, '
    "end_month, end_day, citation_id) VALUES (1, 1, 'annual', 5, 1, 8, 31, 1)",
  );
}
