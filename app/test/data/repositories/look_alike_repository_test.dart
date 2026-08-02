import 'package:catchlaw/data/repositories/content_string_repository.dart';
import 'package:catchlaw/data/repositories/look_alike_repository.dart';
import 'package:catchlaw/data/repositories/look_alike_repository_drift.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/look_alike.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Ok, Result;

import '../../../testing/fakes/fake_content_string_repository.dart';
import '../../../testing/fixtures/rules_fixture.dart';

T _unwrap<T>(Result<T> r) => switch (r) {
  Ok<T>(:final T value) => value,
  _ => throw StateError('look-alikes failed: $r'),
};

void main() {
  late ReferenceDatabase db;
  late LookAlikeRepository repo;

  setUp(() async {
    db = await buildRulesFixture();
    addTearDown(db.close);
    // Species 1 and 2 are confusable; only 1 -> 2 is recorded, so the reverse
    // direction is what the union has to supply.
    await db
        .into(db.lookalikes)
        .insert(
          LookalikesCompanion.insert(
            id: const Value<int>(1),
            speciesId: 1,
            confusedWith: 2,
            differenceKey: 'lookalike.1_2.difference',
          ),
        );
    final ContentStringRepository strings = FakeContentStringRepository(
      <String, Map<String, String>>{
        'lookalike.1_2.difference': <String, String>{'gl': 'Escultura concéntrica, non cruzada.'},
      },
    );
    repo = DriftLookAlikeRepository(db, contentStrings: strings);
  });

  test('DriftLookAlikeRepository.forSpecies finds the pair from the recorded side', () async {
    final List<LookAlike> pairs = _unwrap(await repo.forSpecies(1, locale: 'gl'));
    expect(pairs, hasLength(1));
    expect(pairs.single.confusedWithSpeciesId, 2);
  });

  test('DriftLookAlikeRepository.forSpecies finds the pair from the OTHER side too', () async {
    // The union is the point. A pack that records `A confused with B` and not
    // the reverse would warn the reader who opened A and say nothing to the
    // reader who opened B — and it is the second one who is about to keep a
    // protected fish.
    final List<LookAlike> pairs = _unwrap(await repo.forSpecies(2, locale: 'gl'));
    expect(pairs, hasLength(1));
    expect(pairs.single.confusedWithSpeciesId, 1);
  });

  test('DriftLookAlikeRepository.forSpecies resolves the difference sentence', () async {
    // A sentence FROM THE PACK, describing a physical character. The §9.2 chain
    // means it can never render a raw key.
    final List<LookAlike> pairs = _unwrap(await repo.forSpecies(1, locale: 'gl'));
    expect(pairs.single.difference, 'Escultura concéntrica, non cruzada.');
    expect(pairs.single.difference, isNot(contains('lookalike.')));
  });

  test('DriftLookAlikeRepository.forSpecies marks a protected look-alike', () async {
    // Species 4 is the protected one in the fixture.
    await db
        .into(db.lookalikes)
        .insert(
          LookalikesCompanion.insert(
            id: const Value<int>(2),
            speciesId: 3,
            confusedWith: 4,
            differenceKey: 'lookalike.1_2.difference',
          ),
        );
    final List<LookAlike> pairs = _unwrap(await repo.forSpecies(3, locale: 'gl'));
    expect(pairs.single.confusedWithIsProtected, isTrue);
  });

  test('DriftLookAlikeRepository.forSpecies returns nothing for a species with no pair', () async {
    expect(_unwrap(await repo.forSpecies(5, locale: 'gl')), isEmpty);
  });

  test('DriftLookAlikeRepository.forSpecies drops a pair naming a retired species', () async {
    // A warning about nothing is worse than no warning: it spends the reader's
    // attention and gives back a blank.
    await db
        .into(db.lookalikes)
        .insert(
          LookalikesCompanion.insert(
            id: const Value<int>(3),
            speciesId: 1,
            confusedWith: 9999,
            differenceKey: 'lookalike.1_2.difference',
          ),
        );
    final List<LookAlike> pairs = _unwrap(await repo.forSpecies(1, locale: 'gl'));
    expect(pairs.map((LookAlike p) => p.confusedWithSpeciesId), <int>[2]);
  });
}
