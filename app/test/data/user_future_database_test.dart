// A user.db written by a build of the app NEWER than this one is refused, not
// opened.
//
// drift runs no migration when the file's version is higher than the code's —
// it opens the database and carries on. Every column a newer build added is
// then a column this build reads as absent, and every row it writes is a row
// the newer build reads back with those columns silently empty. The fisher
// downgrades once, uses the app for a week, and upgrades to find a week of
// catches with their measurement method gone.
//
// SPEC.md §7.4: forward-only. Backwards is not a migration, it is a data loss
// with a progress bar.

import 'dart:io';

import 'package:catchlaw/data/services/user_database_opener.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/data/services/user_migration.dart';
import 'package:drift/drift.dart' show Migrator;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import '../../testing/models/user_fixtures.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('catchlaw_future_db_'));
  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  File dbFile() => File('${dir.path}/user.db');

  /// Writes a real database and stamps it with [version].
  Future<void> seedAt(int version) async {
    final UserDatabase db = await openUserDatabase(dbFile());
    await db.customStatement(
      'INSERT INTO trip (id, started_at, jurisdiction_code, zone_code, label) '
      'VALUES (1, ?, ?, ?, ?)',
      <Object?>['2026-08-14T05:00:00Z', 'AE-RK', 'rak', kHostileTripLabel],
    );
    await db.close();

    final raw.Database handle = raw.sqlite3.open(dbFile().path);
    handle
      ..execute('PRAGMA user_version = $version;')
      ..close();
  }

  test('openUserDatabase refuses a database from a newer build', () async {
    await seedAt(UserDatabase.understoodSchemaVersion + 1);

    await expectLater(openUserDatabase(dbFile()), throwsA(isA<DatabaseFromTheFuture>()));
  });

  test('the refusal names both versions', () async {
    // "Update the app" is actionable; "database error" is not.
    await seedAt(7);

    try {
      await openUserDatabase(dbFile());
      fail('a database from the future must not open');
    } on DatabaseFromTheFuture catch (e) {
      expect(e.found, 7);
      expect(e.understood, UserDatabase.understoodSchemaVersion);
      expect(e.code, 'user_db.from_the_future');
      expect('$e', contains('v7'));
    }
  });

  test('the refused database is left exactly as it was', () async {
    // The whole point. A build that cannot understand the file must not be the
    // build that writes to it — and drift's own beforeOpen writes pragmas, so
    // the check happens BEFORE drift is given the file at all.
    await seedAt(9);
    final int lengthBefore = dbFile().lengthSync();
    final List<String> before =
        dir.listSync().map((FileSystemEntity e) => e.uri.pathSegments.last).toList()..sort();

    await expectLater(openUserDatabase(dbFile()), throwsA(isA<DatabaseFromTheFuture>()));

    expect(dbFile().lengthSync(), lengthBefore);
    expect(
      dir.listSync().map((FileSystemEntity e) => e.uri.pathSegments.last).toList()..sort(),
      before,
      reason:
          'the refusal creates nothing — not a -wal, and not a snapshot of a '
          'file we are not going to open',
    );
  });

  test('the refused database still holds its rows for the newer build', () async {
    await seedAt(9);
    await expectLater(openUserDatabase(dbFile()), throwsA(isA<DatabaseFromTheFuture>()));

    // Read back the way the newer build would.
    final raw.Database handle = raw.sqlite3.open(dbFile().path, mode: raw.OpenMode.readOnly);
    addTearDown(handle.close);

    expect(handle.select('SELECT label FROM trip').single.columnAt(0), kHostileTripLabel);
    expect(handle.select('PRAGMA user_version').first.columnAt(0), 9);
  });

  test('openUserDatabase opens a database at the version this build understands', () async {
    // The other side: equal is fine, and lower is a migration.
    await seedAt(UserDatabase.understoodSchemaVersion);

    final UserDatabase db = await openUserDatabase(dbFile());
    addTearDown(db.close);

    expect(await db.select(db.trips).get(), hasLength(1));
  });

  test('onUpgrade refuses a backwards migration it should never be handed', () async {
    // Belt-and-braces for a path drift does not reach. The real guard is in
    // openUserDatabase, before drift is given the file — but a migration
    // callback that would silently accept from > to is one refactor away from
    // being the only guard there is.
    final db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    await expectLater(
      db.migration.onUpgrade(Migrator(db), 9, 1),
      throwsA(isA<DatabaseFromTheFuture>()),
    );
  });
}
