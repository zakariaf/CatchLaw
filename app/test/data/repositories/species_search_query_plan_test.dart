// The query PLAN, not the results. A search that returns the right rows by
// scanning 2,400 of them passes every other test in this directory and misses
// the §13 budget on a wet phone.

import 'dart:io';

import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter_test/flutter_test.dart';

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

  test('the name search uses an index rather than scanning species_name', () async {
    // The reason the statement is a range predicate and not a LIKE. `LIKE 'q%'`
    // CAN be optimised into the same range — but only while the collation is
    // BINARY, case_sensitive_like is at its default, and the prefix is a
    // literal. A future PRAGMA or a COLLATE NOCASE on a rebuilt content
    // database removes any of those silently, and the query degrades to a full
    // scan with nothing failing. The range cannot be defeated, and this row is
    // what says so.
    final List<QueryRow> plan = await db
        .customSelect(
          'EXPLAIN QUERY PLAN '
          'SELECT n.* FROM species_name n '
          "WHERE n.search_norm >= 'ham' AND n.search_norm < 'ham\u{10FFFF}' "
          'ORDER BY n.is_primary DESC LIMIT 40',
        )
        .get();

    final String detail = plan.map((QueryRow r) => r.read<String>('detail')).join(' | ');
    expect(detail.toUpperCase(), contains('INDEX'), reason: detail);
    expect(
      detail.toUpperCase(),
      isNot(contains('SCAN SPECIES_NAME')),
      reason: 'a full scan of the name table at every keystroke — $detail',
    );
  });
}
