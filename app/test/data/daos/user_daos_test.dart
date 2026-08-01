// The user DAOs.
//
// Every mutation is one db.transaction with every query inside awaited. A
// missing await inside a transaction lets the block close before the statement
// runs, so the statement executes outside it — and a "record the catch and bump
// the recent-species counter" pair can half-commit. The tally the fisher checks
// against an inspector is then wrong by one.

import 'package:catchlaw/data/daos/user/catch_dao.dart';
import 'package:catchlaw/data/daos/user/trip_dao.dart';
import 'package:catchlaw/data/daos/user/user_settings_dao.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/user_fixtures.dart';

const String kJurisdiction = 'AE-RK';
const String kZone = 'rak';

CatchesCompanion aCatch({
  int speciesId = 42,
  String createdAt = '2026-08-14T05:40:00Z',
  bool wasKept = false,
}) => CatchesCompanion.insert(
  jurisdictionCode: kJurisdiction,
  zoneCode: kZone,
  speciesId: speciesId,
  scientificName: kHostileScientificName,
  outcome: 'meets',
  outcomeDetail: const Value<String?>(kHostileOutcomeDetail),
  createdAt: createdAt,
  updatedAt: createdAt,
  wasKept: Value<bool>(wasKept),
);

void main() {
  late UserDatabase db;

  setUp(() async {
    db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();
  });

  group('CatchDao', () {
    test('records a catch and bumps the species recency in one transaction', () async {
      // The pair is atomic because a half-committed pair is a tally that
      // disagrees with the log it was counted from.
      await CatchDao(db).insertCatch(aCatch());

      expect(await db.select(db.catches).get(), hasLength(1));
      expect(await db.select(db.speciesRecents).get(), hasLength(1));
    });

    test('increments the recency counter rather than inserting a second row', () async {
      final dao = CatchDao(db);

      await dao.insertCatch(aCatch(createdAt: '2026-08-14T05:40:00Z'));
      await dao.insertCatch(aCatch(createdAt: '2026-08-14T06:10:00Z'));

      final List<SpeciesRecentRow> recents = await db.select(db.speciesRecents).get();
      expect(recents, hasLength(1));
      expect(recents.single.useCount, 2);
      expect(recents.single.lastUsedAt, '2026-08-14T06:10:00Z');
    });

    test('tallies the day by species and counts what was kept', () async {
      // Grouped in SQL, not in Dart: S8 rebuilds on every insert, and folding a
      // season of rows in the UI isolate is a dropped frame at the moment a fish
      // is landed.
      final dao = CatchDao(db);
      await dao.insertCatch(aCatch(wasKept: true));
      await dao.insertCatch(aCatch(createdAt: '2026-08-14T06:00:00Z'));
      await dao.insertCatch(aCatch(speciesId: 7, createdAt: '2026-08-14T07:00:00Z', wasKept: true));

      final List<SpeciesTally> tally = await dao
          .watchTallyForDay('2026-08-14', jurisdictionCode: kJurisdiction, zoneCode: kZone)
          .first;

      expect(tally.first.count, 2);
      expect(tally.first.kept, 1);
      expect(tally.map((SpeciesTally t) => t.speciesId), <int>[42, 7]);
    });

    test('tallies only the day asked for', () async {
      final dao = CatchDao(db);
      await dao.insertCatch(aCatch(createdAt: '2026-08-13T05:40:00Z'));
      await dao.insertCatch(aCatch(createdAt: '2026-08-14T05:40:00Z'));

      final List<SpeciesTally> tally = await dao
          .watchTallyForDay('2026-08-14', jurisdictionCode: kJurisdiction, zoneCode: kZone)
          .first;

      expect(tally.single.count, 1);
    });

    test('tallies only the place asked for', () async {
      // §7.2 puts the codes on the catch precisely so this works for a
      // quick-add with no trip.
      final dao = CatchDao(db);
      await dao.insertCatch(aCatch());
      await db
          .into(db.catches)
          .insert(
            CatchesCompanion.insert(
              jurisdictionCode: 'ES-GA',
              zoneCode: 'rias-baixas',
              speciesId: 1,
              scientificName: 'Venerupis corrugata',
              outcome: 'meets',
              createdAt: '2026-08-14T05:40:00Z',
              updatedAt: '2026-08-14T05:40:00Z',
            ),
          );

      final List<SpeciesTally> tally = await dao
          .watchTallyForDay('2026-08-14', jurisdictionCode: kJurisdiction, zoneCode: kZone)
          .first;

      expect(tally, hasLength(1));
    });

    test('pages backwards by keyset rather than by offset', () async {
      // created_at is an ISO-8601 UTC string, which sorts lexicographically in
      // chronological order, so idx_catch_created serves this directly. An
      // OFFSET re-walks every earlier row on every page — a scroll that gets
      // slower the further back the fisher looks — and a row inserted mid-scroll
      // shifts the window and shows one twice.
      final dao = CatchDao(db);
      for (var hour = 1; hour <= 5; hour++) {
        await dao.insertCatch(aCatch(createdAt: '2026-08-14T0$hour:00:00Z'));
      }

      final List<CatchRow> page = await dao.pageBefore('2026-08-14T04:00:00Z', limit: 2);

      expect(page.map((CatchRow c) => c.createdAt), <String>[
        '2026-08-14T03:00:00Z',
        '2026-08-14T02:00:00Z',
      ]);
    });

    test('a row inserted mid-scroll does not shift the page window', () async {
      final dao = CatchDao(db);
      for (var hour = 1; hour <= 5; hour++) {
        await dao.insertCatch(aCatch(createdAt: '2026-08-14T0$hour:00:00Z'));
      }
      await dao.insertCatch(aCatch(createdAt: '2026-08-14T09:00:00Z'));

      final List<CatchRow> page = await dao.pageBefore('2026-08-14T04:00:00Z', limit: 2);

      expect(page.first.createdAt, '2026-08-14T03:00:00Z');
    });

    test('deletes one catch and leaves the rest', () async {
      final dao = CatchDao(db);
      final int id = await dao.insertCatch(aCatch());
      await dao.insertCatch(aCatch(createdAt: '2026-08-14T06:00:00Z'));

      await dao.deleteCatch(id);

      expect(await db.select(db.catches).get(), hasLength(1));
    });
  });

  group('TripDao', () {
    test('starts a trip and reports it as the open one', () async {
      await TripDao(db).startTrip(
        startedAt: '2026-08-14T05:00:00Z',
        jurisdictionCode: kJurisdiction,
        zoneCode: kZone,
        label: kHostileTripLabel,
      );

      expect((await TripDao(db).watchOpenTrip().first)?.label, kHostileTripLabel);
    });

    test('closes the previous trip when a new one starts', () async {
      // Two open trips is a tally counted against the wrong place, and closing
      // the old one AFTER opening the new leaves both open if the process dies
      // between.
      final dao = TripDao(db);
      await dao.startTrip(
        startedAt: '2026-08-13T05:00:00Z',
        jurisdictionCode: kJurisdiction,
        zoneCode: kZone,
      );

      await dao.startTrip(
        startedAt: '2026-08-14T05:00:00Z',
        jurisdictionCode: kJurisdiction,
        zoneCode: kZone,
      );

      final List<TripRow> trips = await db.select(db.trips).get();
      expect(trips.where((dynamic t) => (t as dynamic).endedAt == null), hasLength(1));
      expect((await dao.watchOpenTrip().first)?.startedAt, '2026-08-14T05:00:00Z');
    });

    test('ends a trip with the timestamp the caller supplies', () async {
      // This layer reads no clock: a DAO that stamped its own times would make
      // every test of it depend on when it ran.
      final dao = TripDao(db);
      final int id = await dao.startTrip(
        startedAt: '2026-08-14T05:00:00Z',
        jurisdictionCode: kJurisdiction,
        zoneCode: kZone,
      );

      await dao.endTrip(id, '2026-08-14T11:00:00Z');

      expect(await dao.watchOpenTrip().first, isNull);
    });
  });

  group('UserProfileDao', () {
    test('watches a non-nullable settings row', () async {
      // CHECK (id = 1) and the beforeOpen seed together mean the row always
      // exists, and a nullable stream would push a `?` into every screen that
      // reads a setting.
      expect((await UserProfileDao(db).watchProfile().first).numeralSystem, 'auto');
    });

    test('updates the settings row in place', () async {
      final dao = UserProfileDao(db);

      await dao.updateProfile(const UserProfilesCompanion(numeralSystem: Value<String>('arab')));

      expect((await dao.read()).numeralSystem, 'arab');
      expect(await db.select(db.userProfiles).get(), hasLength(1));
    });
  });

  group('SavedZoneDao', () {
    test('saves a zone and reads it back in order', () async {
      final dao = SavedZoneDao(db);

      await dao.save(jurisdictionCode: kJurisdiction, zoneCode: kZone, label: 'The bank');

      expect((await dao.watchAll().first).single.label, 'The bank');
    });

    test('updates rather than duplicating the same code pair', () async {
      final dao = SavedZoneDao(db);
      await dao.save(jurisdictionCode: kJurisdiction, zoneCode: kZone, label: 'first');

      await dao.save(jurisdictionCode: kJurisdiction, zoneCode: kZone, label: 'second');

      expect(await dao.watchAll().first, hasLength(1));
    });

    test('reorders every zone in one transaction', () async {
      // A half-applied reorder is a list with two zones at position 3 and none
      // at position 5, which renders as a list that has quietly lost a place.
      final dao = SavedZoneDao(db);
      final int a = await dao.save(jurisdictionCode: 'ES-GA', zoneCode: 'a');
      final int b = await dao.save(jurisdictionCode: 'ES-GA', zoneCode: 'b');

      await dao.reorder(<int>[b, a]);

      expect((await dao.watchAll().first).map((dynamic z) => (z as dynamic).zoneCode), <String>[
        'b',
        'a',
      ]);
    });
  });

  group('SpeciesRecentDao', () {
    test('orders by use count, then by recency', () async {
      final catchDao = CatchDao(db);
      await catchDao.insertCatch(aCatch(speciesId: 7, createdAt: '2026-08-14T05:00:00Z'));
      await catchDao.insertCatch(aCatch(speciesId: 42, createdAt: '2026-08-14T06:00:00Z'));
      await catchDao.insertCatch(aCatch(speciesId: 42, createdAt: '2026-08-14T07:00:00Z'));

      final List<SpeciesRecentRow> recents = await SpeciesRecentDao(
        db,
      ).watchRecent(jurisdictionCode: kJurisdiction, zoneCode: kZone).first;

      expect(recents.map((dynamic r) => (r as dynamic).speciesId), <int>[42, 7]);
    });

    test('is scoped to one place', () async {
      await CatchDao(db).insertCatch(aCatch());

      expect(
        await SpeciesRecentDao(db).watchRecent(jurisdictionCode: 'ES-GA', zoneCode: 'x').first,
        isEmpty,
      );
    });
  });

  group('RuleFlagDao and AppMetaDao', () {
    test('records a flag with the note the fisher wrote', () async {
      await RuleFlagDao(db).flag(
        ruleId: 1,
        note: kHostileTripLabel,
        createdAt: '2026-08-14T05:40:00Z',
        citationRef: kHostileCitationRef,
      );

      final List<RuleFlagRow> flags = await RuleFlagDao(db).watchAll().first;
      expect(flags.single.note, kHostileTripLabel);
      expect(flags.single.citationRef, kHostileCitationRef);
    });

    test('round-trips an app_meta value and overwrites rather than accumulating', () async {
      final dao = AppMetaDao(db);

      await dao.write('content_build_date', '2026-07-01');
      await dao.write('content_build_date', '2026-08-14');

      expect(await dao.read('content_build_date'), '2026-08-14');
      expect(await dao.readAll(), hasLength(1));
    });

    test('reads null for a key nobody wrote', () async {
      expect(await AppMetaDao(db).read('nothing'), isNull);
    });
  });
}
