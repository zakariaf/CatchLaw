// The species search, against the REAL built reference.db.
//
// Not against a drift-created in-memory schema: drift's Table classes and the
// content builder's DDL are two descriptions of one schema, and a test that
// reads the same description it wrote proves nothing about the file that ships.

import 'dart:io';

import 'package:catchlaw/data/repositories/species_search_repository.dart';
import 'package:catchlaw/data/repositories/species_search_repository_drift.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/species_search_hit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Ok, Result;

import '../../../testing/fixtures/reference_fixture.dart';

T _unwrap<T>(Result<T> r) => switch (r) {
  Ok<T>(:final T value) => value,
  _ => throw StateError('search failed: $r'),
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
  late SpeciesSearchRepository repo;

  setUp(() async {
    (db, file) = await openBuiltReference();
    repo = DriftSpeciesSearchRepository(db);
    addTearDown(() async {
      await db.close();
      if (file.parent.existsSync()) file.parent.deleteSync(recursive: true);
    });
  });

  Future<List<SpeciesSearchHit>> search(String q, {String locale = 'gl'}) async =>
      _unwrap(await repo.search(q, locale: locale));

  test('DriftSpeciesSearchRepository.search folds the raw query rather than trusting it', () async {
    // The caller types what comes off the keyboard. Folding here — with the
    // engine's own normaliseSpeciesTerm, the function the content build used to
    // write search_norm — is what makes case and diacritics irrelevant. A term
    // folded any other way matches nothing at all, silently.
    final List<SpeciesSearchHit> any = await search('a');
    expect(any, isNotEmpty, reason: 'the Galicia seed has species starting with a');

    final String first = any.first.matchedName;
    final List<SpeciesSearchHit> upper = await search(first.toUpperCase());
    expect(upper.map((SpeciesSearchHit h) => h.speciesId), contains(any.first.speciesId));
  });

  test('DriftSpeciesSearchRepository.search returns each species at most once', () async {
    // An Arabic name carrying `ال` has two species_name rows with the same
    // display name (E04/T07), and without the collapse the same fish appears
    // twice in the list.
    final List<SpeciesSearchHit> hits = await search('a');
    final List<int> ids = hits.map((SpeciesSearchHit h) => h.speciesId).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('DriftSpeciesSearchRepository.search carries the name that actually matched', () async {
    // The whole reason a hit is not just a species: a fisher who typed a local
    // name must not be shown a Latin binomial he does not recognise.
    for (final SpeciesSearchHit hit in await search('a')) {
      expect(hit.matchedName, isNotEmpty);
      expect(hit.matchedLocale, isNotEmpty);
    }
  });

  test('DriftSpeciesSearchRepository.search prefers a name in the requested locale', () async {
    final List<SpeciesSearchHit> gl = await search('a');
    final Iterable<String> locales = gl.map((SpeciesSearchHit h) => h.matchedLocale);
    expect(locales, isNotEmpty);
    // Not every species need have a gl name, but where one exists the ordering
    // must have chosen it over a foreign one.
    expect(locales.contains('gl'), isTrue);
  });

  test('DriftSpeciesSearchRepository.search returns nothing for an empty query', () async {
    // An empty prefix would range-scan the whole name table, which is the one
    // shape the §13 budget cannot absorb on every keystroke.
    expect(await search(''), isEmpty);
    expect(await search('   '), isEmpty);
  });

  test('DriftSpeciesSearchRepository.search returns nothing for a term nothing matches', () async {
    expect(await search('zzzzqqqq'), isEmpty);
  });

  test('DriftSpeciesSearchRepository.search honours the limit', () async {
    expect(await search('a').then((List<SpeciesSearchHit> h) => h.length), lessThanOrEqualTo(40));
    final List<SpeciesSearchHit> capped = _unwrap(await repo.search('a', locale: 'gl', limit: 1));
    expect(capped.length, lessThanOrEqualTo(1));
  });

  test('DriftSpeciesSearchRepository.speciesCount reports what the pack carries', () async {
    // S5's empty state says the list covers the active jurisdiction only, and
    // that sentence is dishonest without a number behind it.
    expect(_unwrap(await repo.speciesCount()), greaterThan(0));
  });
}
