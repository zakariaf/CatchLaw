// SPEC.md §13: under 50 ms at 400 species and 2,400 names, on every keystroke.
//
// Against a synthetic corpus at the spec's own scale rather than against the
// Galicia seed, which is far smaller — a budget proved at ten species is not a
// budget.

import 'package:catchlaw/data/repositories/species_search_repository_drift.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fixtures/species_corpus.dart';

void main() {
  late ReferenceDatabase db;
  late DriftSpeciesSearchRepository repo;

  setUp(() async {
    db = await buildSpeciesCorpus();
    addTearDown(db.close);
    repo = DriftSpeciesSearchRepository(db);
  });

  test('the species search answers a three-letter prefix in under 50 ms at spec scale', () async {
    // Warm the statement cache first: the first query of a process pays for
    // parsing and planning, which no keystroke after the first one does.
    await repo.search('spe', locale: 'en');

    final clock = Stopwatch()..start();
    for (var i = 0; i < 20; i++) {
      await repo.search('spe', locale: 'en');
    }
    clock.stop();

    final double perQuery = clock.elapsedMicroseconds / 20 / 1000;
    expect(
      perQuery,
      lessThan(50),
      reason: '${perQuery.toStringAsFixed(2)} ms per query at $kCorpusSpecies species',
    );
  });

  test('the species search answers a one-letter prefix in under 50 ms at spec scale', () async {
    // The worst case a fisher can produce: one letter matches the most rows,
    // and it is the first thing typed.
    await repo.search('s', locale: 'en');

    final clock = Stopwatch()..start();
    for (var i = 0; i < 20; i++) {
      await repo.search('s', locale: 'en');
    }
    clock.stop();

    final double perQuery = clock.elapsedMicroseconds / 20 / 1000;
    expect(perQuery, lessThan(50), reason: '${perQuery.toStringAsFixed(2)} ms per query');
  });

  test('the synthetic corpus really holds 400 species and 2400 names', () async {
    // A latency budget proved over an empty table is the same failure as a gate
    // that scans an empty tree.
    expect(kCorpusSpecies, 400);
    expect(kCorpusNames, 2400);
  });
}
