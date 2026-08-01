// The open, against the file tools/content_builder/ actually produced.
//
// Everything here is about the property invariant 7 and D-6 rest on: reading
// shipped content must not change it. A writable open lets drift run onCreate
// against the rule book and leaves a -wal beside it; from that moment the
// file's sha256 no longer matches the sidecar, the extraction integrity check
// reports a corrupt payload on a database that is fine, and every later launch
// re-extracts ten megabytes to fix a problem the open created.
//
// These tests need the built file. It is git-ignored — the .gz is what ships —
// so they SKIP with a reason when it is absent rather than failing for the
// wrong one. CI runs the content build before this suite.

import 'dart:io';

import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../testing/fixtures/reference_fixture.dart';

void main() {
  if (!builtReferenceExists()) {
    test('the built reference.db is present', () {
      // Not a silent skip: a suite that quietly passes over a missing file is
      // the CONVENTIONS.md §7 failure in test form.
      markTestSkipped(
        'run `dart run content_builder:build --in content/ '
        '--out app/assets/db/reference.db --build-date <date> '
        '--generator-commit <sha>` first',
      );
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

  test('built reference.db reports a journal_mode that a read-only open can read', () {
    // The failure that does not reproduce on a developer machine, because a
    // stale -wal from an earlier writable open is sitting there making it work.
    // SQLite must create a -shm before it can read a WAL-mode database, and it
    // cannot on a read-only handle: the open fails outright.
    final Database raw = sqlite3.open(file.path, mode: OpenMode.readOnly);
    addTearDown(raw.close);

    final String mode = '${raw.select('PRAGMA journal_mode').first.columnAt(0)}'.toLowerCase();

    expect(
      mode,
      anyOf('delete', 'off'),
      reason:
          'a WAL-mode file cannot be opened read-only; the fix is in the '
          "content builder's DDL, never a relaxation of the open",
    );
  });

  test('referenceExecutor opens the built file read-only', () async {
    // The whole point. If this passes, drift can write to shipped content.
    await expectLater(
      db.customStatement("INSERT INTO content_meta (key, value) VALUES ('x', 'y')"),
      throwsA(isA<SqliteException>()),
    );
  });

  test('opening the built reference.db leaves no -wal and no -shm beside it', () async {
    await db.customSelect('SELECT count(*) FROM species').get();
    await db.close();

    final List<String> siblings = file.parent
        .listSync()
        .whereType<File>()
        .map((File f) => f.uri.pathSegments.last)
        .toList();

    expect(siblings, isNot(anyElement(endsWith('-wal'))));
    expect(siblings, isNot(anyElement(endsWith('-shm'))));
    expect(siblings, <String>['reference.db']);
  });

  test('opening the built reference.db leaves its sha256 unchanged', () async {
    // Restates the previous test as the property that actually matters to the
    // extraction check.
    final before = '${await sha256.bind(file.openRead()).first}';

    await db.customSelect('SELECT count(*) FROM species_name').get();
    await db.close();

    expect(
      '${await sha256.bind(file.openRead()).first}',
      before,
      reason: 'a read must not mutate shipped content',
    );
  });

  test('ReferenceDatabase selects every column of every table in the built file', () async {
    // THE PARITY TEST. drift's Table classes and the content builder's DDL are
    // two descriptions of one schema with nothing forcing them to agree, and
    // the divergence would surface as a runtime SqliteException on one query in
    // one locale, five epics from here.
    for (final TableInfo<Table, dynamic> table in db.allTables) {
      final List<String> declared =
          table.$columns.map((GeneratedColumn<Object> c) => c.name).toList()..sort();
      final List<QueryRow> actual = await db
          .customSelect('PRAGMA table_info(${table.actualTableName})')
          .get();

      expect(
        actual.map((QueryRow r) => r.read<String>('name')).toList()..sort(),
        declared,
        reason: table.actualTableName,
      );
      await expectLater(
        db.customSelect('SELECT * FROM ${table.actualTableName} LIMIT 1').get(),
        completes,
        reason: table.actualTableName,
      );
    }
  });

  test('legal_text_fts is reachable through the same connection', () async {
    // An fts5 relation cannot be a Dart Table subclass, so the .drift file is
    // how drift is told it exists. If this throws, T07 has no typed way to
    // reach S13's search.
    await expectLater(db.customSelect('SELECT count(*) AS n FROM legal_text_fts').get(), completes);
  });
}
