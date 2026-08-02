// The content_string repository, against the REAL built reference.db.
//
// Not against a drift-created in-memory schema: drift's Table classes and the
// content builder's DDL are two descriptions of one schema with nothing forcing
// them to agree, and a test that reads the same description it wrote proves
// nothing about the file that ships.

import 'dart:io';

import 'package:catchlaw/data/repositories/content_string_repository.dart';
import 'package:catchlaw/data/repositories/content_string_repository_drift.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/use_cases/content_string_resolver.dart';
import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Ok, Result;

import '../../testing/fixtures/reference_fixture.dart';

/// The locales D-3 ships, as they appear in `content_string.locale`.
const List<String> kContentLocales = <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR'];

Map<String, String> _unwrap(Result<Map<String, String>> r) => switch (r) {
  Ok<Map<String, String>>(:final Map<String, String> value) => value,
  _ => throw StateError('valuesFor failed: $r'),
};

void main() {
  if (!builtReferenceExists()) {
    test('the built reference.db is present', () {
      markTestSkipped('run `dart run content_builder:build` first');
    }, skip: true);
    return;
  }

  late ReferenceDatabase db;
  late File file;
  late ContentStringRepository repo;

  setUp(() async {
    (db, file) = await openBuiltReference();
    repo = ContentStringRepositoryDrift(db);
    addTearDown(() async {
      await db.close();
      if (file.parent.existsSync()) file.parent.deleteSync(recursive: true);
    });
  });

  test('ContentStringRepositoryDrift.valuesFor returns every locale row for one key', () async {
    final String key = await _anyKey(db);
    final Map<String, String> values = _unwrap(await repo.valuesFor(key));

    expect(values.keys, containsAll(kContentLocales));
    expect(values.values.every((String v) => v.isNotEmpty), isTrue);
  });

  test('ContentStringRepositoryDrift.valuesFor returns an empty map for an unknown key', () async {
    // The resolver's exhausted-chain path has to be reachable from real SQL,
    // not only from the fake.
    expect(_unwrap(await repo.valuesFor('no.such.key.at.all')), isEmpty);
  });

  test('ContentStringRepositoryDrift.valuesFor reads a handle opened read-only', () async {
    // D-6's read-only open is asserted by reference_open_test.dart. What is
    // asserted here is the consequence nobody checks: that this repository
    // reaches its rows over that handle without drift attempting a write on
    // first use, which would fail the open rather than the query.
    expect(_unwrap(await repo.valuesFor(await _anyKey(db))), isNotEmpty);
  });

  test('every content_string key in the built reference.db resolves for all six locales', () async {
    // The §8 build assertion, mirrored on the app side — it catches a
    // reference.db produced by an older builder, which the build assertion
    // by definition cannot.
    final resolver = ContentStringResolver(repo);
    final List<String> keys = await _allKeys(db);
    expect(keys, isNotEmpty, reason: 'a pass over zero keys is not evidence about any of them');

    for (final key in keys) {
      for (final String locale in kContentLocales) {
        final String value = await resolver.resolve(
          key,
          requestedLocale: locale,
          defaultLocale: locale,
        );
        expect(value, isNot(key), reason: '$key in $locale rendered its own key');
        expect(value, isNotEmpty, reason: '$key in $locale rendered an empty string');
      }
    }
  });
}

Future<String> _anyKey(ReferenceDatabase db) async => (await _allKeys(db)).first;

Future<List<String>> _allKeys(ReferenceDatabase db) async {
  final List<QueryRow> rows = await db
      .customSelect('SELECT DISTINCT key FROM content_string ORDER BY key')
      .get();
  return rows.map((QueryRow r) => r.read<String>('key')).toList();
}
