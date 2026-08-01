// The read boundary: drift rows in, domain types and a typed Result out.
//
// Every test here is about the seam rather than the query — the queries are
// T07's, and they are tested against the real built file there. What is new is
// that nothing drift-shaped crosses this line, and that a storage exception
// becomes a value instead of an escape.

import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/reference_repository_drift.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result, Rule;

import '../../../testing/fixtures/reference_fixture.dart';

void main() {
  late ReferenceDatabase db;
  late DriftReferenceRepository repository;
  late List<Object> logged;

  setUp(() async {
    db = inMemoryReference();
    addTearDown(db.close);
    logged = <Object>[];
    repository = DriftReferenceRepository(
      db,
      boundary: StorageBoundary(log: (Object e, StackTrace st) => logged.add(e)),
    );
    await _seed(db);
  });

  test('DriftReferenceRepository.searchSpecies returns Ok carrying domain species', () async {
    final Result<List<Species>> result = await repository.searchSpecies('ameixa');

    // isA<Ok<List<Species>>> is the assertion that matters: the static type is
    // the domain one, so a drift row could not reach here even if it wanted to.
    expect(result, isA<Ok<List<Species>>>());
    expect((result as Ok<List<Species>>).value.map((Species s) => s.scientificName), <String>[
      'Venerupis corrugata',
    ]);
  });

  test('DriftReferenceRepository.speciesById returns DataNotFound for an unknown id', () async {
    final Result<Species> result = await repository.speciesById(999999);

    // An expected miss is a VALUE. A repository that threw here would make
    // "no such species" indistinguishable from "the database is broken".
    expect(
      result,
      isA<Failure<Species>>().having(
        (Failure<Species> f) => f.exception,
        'exception',
        isA<DataNotFound>()
            .having((DataNotFound e) => e.entity, 'entity', 'species')
            .having((DataNotFound e) => e.id, 'id', '999999'),
      ),
    );
  });

  test('DriftReferenceRepository maps a closed database to DataStoreUnavailable', () async {
    // The leak this boundary exists to stop. drift signals a closed database
    // with a StateError, and a StateError arriving in a Notifier is a red
    // screen where a sentence about the law should be.
    await db.close();

    final Result<List<Species>> result = await repository.searchSpecies('ameixa');

    expect(
      result,
      isA<Failure<List<Species>>>().having(
        (Failure<List<Species>> f) => f.exception,
        'exception',
        isA<DataStoreUnavailable>(),
      ),
    );
  });

  test('DriftReferenceRepository logs the original error before returning a failure', () async {
    await db.close();

    await repository.searchSpecies('ameixa');

    // Log FIRST, then return. For an app that cannot phone home the local
    // stack trace is the only diagnostic that will ever exist, and a boundary
    // that converts before logging has already thrown the original away.
    expect(logged, hasLength(1));
    expect('${logged.single}', isNot(contains('data.store_unavailable')));
  });

  test('DriftReferenceRepository.strings returns Ok with the keys that resolved', () async {
    final Result<Map<String, String>> result = await repository.strings(<String>[
      'species.venerupis_corrugata',
    ], 'gl');

    expect((result as Ok<Map<String, String>>).value, <String, String>{
      'species.venerupis_corrugata': 'Ameixa babosa',
    });
  });

  test('DriftReferenceRepository.candidateRules attaches a Citation to every rule', () async {
    // Invariant 3, at the seam that could break it: the engine's Rule requires
    // a non-nullable Citation, and this is the only place one is constructed
    // from a row. A placeholder here is a footnote that cites nothing.
    final Result<List<Rule>> result = await repository.candidateRules(
      jurisdictionId: 1,
      speciesId: 1,
      waterType: 'salt',
      onDate: '2026-08-01',
    );

    final List<Rule> rules = (result as Ok<List<Rule>>).value;
    expect(rules, hasLength(1));
    expect(rules.single.citation.instrument, 'Orde do 27 de xullo de 2012');
    expect(rules.single.closedSeasons, hasLength(1));
  });
}

Future<void> _seed(ReferenceDatabase db) async {
  await db.customStatement(
    'INSERT INTO jurisdiction (id, code, country_iso2, name_key, authority_key, '
    'default_locale, legal_text_locales, content_version, published_on, checked_on) '
    "VALUES (1, 'ES-GA', 'ES', 'k', 'k', 'gl', 'gl', '1', '2012-07-27', '2026-07-14')",
  );
  await db.customStatement("INSERT INTO family (id, scientific, name_key) VALUES (1, 'V', 'k')");
  await db.customStatement(
    'INSERT INTO species (id, scientific_name, family_id, taxon_group, silhouette_asset) '
    "VALUES (1, 'Venerupis corrugata', 1, 'bivalve', 'sil/v.svg')",
  );
  await db.customStatement(
    'INSERT INTO species_name (id, species_id, locale, name, search_norm, gender) '
    "VALUES (1, 1, 'gl', 'Ameixa babosa', 'ameixa babosa', 'f')",
  );
  await db.customStatement(
    'INSERT INTO citation (id, jurisdiction_id, instrument_type_key, instrument_ref, '
    "article_ref, published_on, retrieved_on) VALUES (1, 1, 'k', "
    "'Orde do 27 de xullo de 2012', 'Anexo II', '2012-08-06', '2026-07-14')",
  );
  await db.customStatement(
    'INSERT INTO rule (id, jurisdiction_id, species_id, water_type, min_size_mm, '
    "citation_id, valid_from) VALUES (1, 1, 1, 'salt', 380, 1, '2012-08-01')",
  );
  await db.customStatement(
    'INSERT INTO closed_season (id, rule_id, recurrence, start_month, start_day, '
    "end_month, end_day, citation_id) VALUES (1, 1, 'annual', 5, 1, 8, 31, 1)",
  );
  await db.customStatement(
    'INSERT INTO content_string (key, locale, value) '
    "VALUES ('species.venerupis_corrugata', 'gl', 'Ameixa babosa')",
  );
}
