// The migration harness, shipped before the first migration is.
//
// user.db is at version 1, so there is no from -> to pair yet — and that is
// exactly when this is cheap to build and impossible to retrofit under
// pressure. The every-pair loop runs over 1..understoodSchemaVersion, so it is
// non-empty the instant E13 or E16 adds a column and nobody has to remember to
// write it.
//
// D-17 records what this file does NOT have: a committed drift snapshot, because
// drift_dev's schema tooling cannot run against the drift version D-5 pins in a
// workspace that also has package:test. The content test below is what stands in
// its place, and the decision says precisely what that does and does not prove.

import 'dart:io';

import 'package:catchlaw/data/services/user_database_opener.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/models/user_fixtures.dart';

/// Writes the hostile fixture rows into [db].
Future<void> seedHostile(UserDatabase db) async {
  await db.customStatement(
    'INSERT INTO trip (id, started_at, jurisdiction_code, zone_code, label, notes) '
    'VALUES (1, ?, ?, ?, ?, ?)',
    <Object?>['2026-08-14T05:00:00Z', 'AE-RK', 'rak', kHostileTripLabel, kHostileTripNotes],
  );
  await db.customStatement(
    'INSERT INTO catch (id, trip_id, jurisdiction_code, zone_code, species_id, '
    'scientific_name, length_mm, measurement_code, outcome, outcome_detail, '
    'rule_citation_ref, content_version, created_at, updated_at) '
    'VALUES (1, 1, ?, ?, 42, ?, 380, ?, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      'AE-RK',
      'rak',
      kHostileScientificName,
      'TL',
      'fails',
      kHostileOutcomeDetail,
      kHostileCitationRef,
      '2026.08.0',
      '2026-08-14T05:40:00Z',
      '2026-08-14T05:40:00Z',
    ],
  );
  await db.customStatement(
    'INSERT INTO species_recent (species_id, jurisdiction_code, zone_code, use_count, '
    'last_used_at) VALUES (42, ?, ?, 3, ?)',
    <Object?>['AE-RK', 'rak', '2026-08-14T05:40:00Z'],
  );
}

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('catchlaw_user_migration_'));
  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  File dbFile() => File('${dir.path}/user.db');

  group('every schema pair', () {
    // Empty at version 1, and shaped so it is not empty a moment after E13 or
    // E16 adds a column. A loop written later is a loop written under pressure.
    for (var from = 1; from < UserDatabase.understoodSchemaVersion; from++) {
      for (int to = from + 1; to <= UserDatabase.understoodSchemaVersion; to++) {
        test('user.db migrates from v$from to v$to and keeps its rows', () async {
          fail(
            'E13 or E16 added a schema version without a fixture for $from -> $to. '
            'D-17 names the three ways to verify it, and the third — a '
            'hand-written before/after fixture built by v$from of this schema — '
            'is always available.',
          );
        });
      }
    }

    test('the pair loop covers every version this build understands', () {
      // The loop above is empty today. This is what makes that a FACT rather
      // than an oversight: if the version moves and no pair test appears, this
      // assertion is the one that changes.
      expect(UserDatabase.understoodSchemaVersion, 1);
    });
  });

  group('v1 content', () {
    test('user.db round-trips hostile values through a close and reopen', () async {
      // A green shape check is necessary and never sufficient: migrateAndValidate
      // compares CREATE statements and reads ZERO rows, so a migration that
      // rebuilds a table perfectly and copies NOTHING passes it green. SPEC.md
      // §7.4 asks for row counts and sample values for exactly this reason.
      UserDatabase db = await openUserDatabase(dbFile());
      await seedHostile(db);
      await db.close();

      db = await openUserDatabase(dbFile());
      addTearDown(db.close);

      final TripRow trip = await db.select(db.trips).getSingle();
      final CatchRow row = await db.select(db.catches).getSingle();

      expect(
        trip.label,
        kHostileTripLabel,
        reason: 'an apostrophe that ends a quoted literal early, and an em dash',
      );
      expect(
        trip.notes,
        kHostileTripNotes,
        reason: 'whitespace-only, which a TRIM-then-NULLIF discards silently',
      );
      expect(
        row.scientificName,
        kHostileScientificName,
        reason: 'the binomial the catch record keeps whatever the pack later says',
      );
      expect(
        row.outcomeDetail,
        kHostileOutcomeDetail,
        reason: 'a backslash a naive escape doubles, in the sentence the fisher actually read',
      );
      expect(
        row.ruleCitationRef,
        kHostileCitationRef,
        reason: 'the citation, with its apostrophes',
      );
      expect(row.lengthMm, 380, reason: 'integer millimetres, never coerced from text');
    });

    test('user.db keeps an Arabic value byte-for-byte', () async {
      // A byte-oriented copy truncates mid-codepoint and the failure looks like
      // a rendering bug three screens away.
      final UserDatabase db = await openUserDatabase(dbFile());
      addTearDown(db.close);

      await db.customStatement(
        "INSERT INTO app_meta (key, value) VALUES ('vernacular', ?)",
        <Object?>[kHostileVernacular],
      );

      expect(
        (await db.select(db.appMetas).getSingle()).value,
        kHostileVernacular,
        reason: 'هامور, unchanged',
      );
    });
  });

  group('the connection pragmas', () {
    test('foreign_keys is on after every open', () async {
      // Per-connection and not persisted, so re-asserted in beforeOpen. Without
      // it, ON DELETE SET NULL never fires and a deleted trip takes its catches
      // with it.
      final UserDatabase db = await openUserDatabase(dbFile());
      addTearDown(db.close);

      expect((await db.customSelect('PRAGMA foreign_keys').getSingle()).data.values.first, 1);
    });

    test('synchronous is FULL rather than NORMAL', () async {
      // SQLite states that WAL with NORMAL may roll back the last transactions
      // after a power failure, and there is no cloud copy to recover from: a
      // fisher's last catch is exactly the row that would be lost.
      final UserDatabase db = await openUserDatabase(dbFile());
      addTearDown(db.close);

      expect(
        (await db.customSelect('PRAGMA synchronous').getSingle()).data.values.first,
        2,
        reason: '2 is FULL; 1 would be NORMAL',
      );
    });

    test('journal_mode is WAL', () async {
      final UserDatabase db = await openUserDatabase(dbFile());
      addTearDown(db.close);

      expect(
        '${(await db.customSelect('PRAGMA journal_mode').getSingle()).data.values.first}',
        'wal',
      );
    });
  });

  group('openUserDatabase', () {
    test('creates the database on a first launch and seeds the profile', () async {
      final UserDatabase db = await openUserDatabase(dbFile());
      addTearDown(db.close);

      expect(await db.select(db.userProfiles).get(), hasLength(1));
    });

    test('leaves no pre-migration snapshot behind on a clean open', () async {
      // An orphan snapshot of a database is a second copy of the fisher's log
      // nobody knows about.
      final UserDatabase first = await openUserDatabase(dbFile());
      await first.close();

      final UserDatabase second = await openUserDatabase(dbFile());
      addTearDown(second.close);

      expect(
        dir.listSync().map((FileSystemEntity e) => e.uri.pathSegments.last).toList(),
        isNot(anyElement(endsWith('.pre-migration'))),
      );
    });

    test('takes the snapshot with a handle it disposes before drift opens the file', () async {
      // run-migration rule 1's requirement, kept while using
      // persistence-drift's mechanism: VACUUM INTO rather than File.copy, on a
      // raw handle that is closed before the migration runs. A live handle
      // during a migration is the deadlock that only reproduces on a device.
      final UserDatabase first = await openUserDatabase(dbFile());
      await seedHostile(first);
      await first.close();

      final UserDatabase second = await openUserDatabase(dbFile());
      addTearDown(second.close);

      expect(await second.select(second.catches).get(), hasLength(1));
    });

    test('snapshots the database into a file that opens and holds every row', () async {
      // The copy is the thing the fisher's log depends on, so it is tested
      // directly rather than through a contrived migration failure — a test
      // that reaches it only that way is a test of the contrivance.
      //
      // VACUUM INTO rather than File.copy: check-persistence-bans.sh check 1
      // fails any `.copy(` on a line naming a database and offers no escape
      // hatch, so the executable rule decides (D-2). run-migration rule 1's
      // intent survives — the raw handle is closed before drift opens the file.
      final UserDatabase first = await openUserDatabase(dbFile());
      await seedHostile(first);
      await first.close();
      final copy = File('${dir.path}/snapshot.db');

      snapshotUserDatabase(dbFile(), copy);

      // Asserted BEFORE the copy is opened: opening it sets journal_mode = WAL,
      // which creates the very sidecars this is about.
      expect(
        dir.listSync().map((FileSystemEntity e) => e.uri.pathSegments.last),
        isNot(anyElement(anyOf(endsWith('snapshot.db-wal'), endsWith('snapshot.db-shm')))),
        reason: 'VACUUM INTO produces one consistent file with no sidecars to keep in step',
      );

      final restored = UserDatabase(NativeDatabase(copy));
      addTearDown(restored.close);
      final CatchRow row = await restored.select(restored.catches).getSingle();
      expect(row.outcomeDetail, kHostileOutcomeDetail);
    });

    test('restores by rename, which cannot half-succeed', () async {
      // A restore that could half-succeed would be worse than none: the log is
      // the one thing in this app that exists nowhere else.
      final UserDatabase first = await openUserDatabase(dbFile());
      await seedHostile(first);
      await first.close();
      final backup = File('${dbFile().path}.pre-migration');
      snapshotUserDatabase(dbFile(), backup);
      dbFile().writeAsStringSync('a truncated file at the live path');

      backup.renameSync(dbFile().path);

      final restored = UserDatabase(NativeDatabase(dbFile()));
      addTearDown(restored.close);
      expect(await restored.select(restored.catches).get(), hasLength(1));
      expect(backup.existsSync(), isFalse);
    });
  });
}
