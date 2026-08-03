import 'dart:io';

import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fixtures/reference_fixture.dart';

/// What the pack that actually ships contains.
///
/// **The regression that makes "zero rules" fail loudly.** For ten epics every
/// answer this app could give was `NoRuleFound` — honest, and useless — and
/// nothing said so. If a pack is ever emptied, or a build ships the schema
/// without the rows, this is the test that notices.
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

  Future<List<Map<String, Object?>>> rows(String sql) async =>
      (await db.customSelect(sql).get()).map((QueryRow r) => r.data).toList();

  test('the shipped pack carries at least one rule row', () async {
    expect(await rows('SELECT id FROM rule'), isNotEmpty);
  });

  test('every rule in the shipped pack names a measurement method', () async {
    // A1 asserted against the BUILT artefact and not only against the source:
    // a number measured by an unstated method is a confident wrong verdict, and
    // TL and FL differ by 6-9 cm on the same fish.
    final List<Map<String, Object?>> sized = await rows(
      'SELECT id, measurement_method_id FROM rule '
      'WHERE min_size_mm IS NOT NULL OR max_size_mm IS NOT NULL',
    );
    expect(sized, isNotEmpty);
    for (final row in sized) {
      expect(row['measurement_method_id'], isNotNull, reason: '${row['id']}');
    }
  });

  test('every rule in the shipped pack cites an instrument that resolves', () async {
    final List<Map<String, Object?>> uncited = await rows(
      'SELECT r.id FROM rule r LEFT JOIN citation c ON c.id = r.citation_id WHERE c.id IS NULL',
    );
    // Invariant 3, asserted against the file the phone opens.
    expect(uncited, isEmpty);
  });

  test('every citation in the shipped pack carries both dates and a gazette url', () async {
    final List<Map<String, Object?>> citations = await rows(
      'SELECT instrument_ref, published_on, retrieved_on, source_url FROM citation',
    );
    for (final row in citations) {
      expect(row['published_on'], isNotNull, reason: '${row['instrument_ref']}');
      expect(row['retrieved_on'], isNotNull, reason: '${row['instrument_ref']}');
      expect(
        row['source_url'],
        anyOf(contains('xunta.gal'), contains('boe.es')),
        reason: '${row['instrument_ref']}',
      );
    }
  });
}
