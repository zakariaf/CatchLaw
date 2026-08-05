import 'package:catchlaw/data/repositories/content_string_repository.dart';
import 'package:catchlaw/data/repositories/identification_key_repository.dart';
import 'package:catchlaw/data/repositories/identification_key_repository_drift.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/key_step.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Ok, Result;

import '../../../testing/fakes/fake_content_string_repository.dart';
import '../../../testing/fixtures/rules_fixture.dart';

T _unwrap<T>(Result<T> r) => switch (r) {
  Ok<T>(:final T value) => value,
  _ => throw StateError('the key failed: $r'),
};

/// The strings the fixture's key nodes and options resolve through.
ContentStringRepository _strings() => FakeContentStringRepository(<String, Map<String, String>>{
  'key.1.question': <String, String>{'gl': 'Mira só a aleta caudal.'},
  'key.2.question': <String, String>{'gl': 'Mira só a boca.'},
  'key.1.a': <String, String>{'gl': 'Profundamente furcada'},
  'key.1.b': <String, String>{'gl': 'Redondeada ou cadrada'},
  'key.2.a': <String, String>{'gl': 'Mandíbula saínte'},
  'key.2.b': <String, String>{'gl': 'Mandíbulas iguais'},
});

/// A three-node key over the fixture's six species.
///
/// Node 1 forks to node 2 and to leaf 3; node 2 forks to leaves 4 and 5. The
/// shape is deliberate: the count at node 1 is only right if the query descends
/// through node 2 to the leaves under it.
Future<void> _seedKey(ReferenceDatabase db) async {
  await db.batch((Batch batch) {
    batch
      ..insert(
        db.keyNodes,
        KeyNodesCompanion.insert(
          id: const Value<int>(1),
          taxonGroup: 'finfish',
          questionKey: const Value<String>('key.1.question'),
        ),
      )
      ..insert(
        db.keyNodes,
        KeyNodesCompanion.insert(
          id: const Value<int>(2),
          taxonGroup: 'finfish',
          parentNodeId: const Value<int>(1),
          questionKey: const Value<String>('key.2.question'),
        ),
      )
      ..insert(
        db.keyNodes,
        KeyNodesCompanion.insert(
          id: const Value<int>(3),
          taxonGroup: 'finfish',
          parentNodeId: const Value<int>(1),
        ),
      )
      ..insert(
        db.keyNodes,
        KeyNodesCompanion.insert(
          id: const Value<int>(4),
          taxonGroup: 'finfish',
          parentNodeId: const Value<int>(2),
        ),
      )
      ..insert(
        db.keyNodes,
        KeyNodesCompanion.insert(
          id: const Value<int>(5),
          taxonGroup: 'finfish',
          parentNodeId: const Value<int>(2),
        ),
      )
      ..insert(
        db.keyOptions,
        KeyOptionsCompanion.insert(
          id: const Value<int>(11),
          nodeId: 1,
          optionIndex: 0,
          labelKey: 'key.1.a',
          figureAsset: const Value<String>('sil/forked.svg'),
          nextNodeId: const Value<int>(2),
        ),
      )
      ..insert(
        db.keyOptions,
        KeyOptionsCompanion.insert(
          id: const Value<int>(12),
          nodeId: 1,
          optionIndex: 1,
          labelKey: 'key.1.b',
          nextNodeId: const Value<int>(3),
        ),
      )
      ..insert(
        db.keyOptions,
        KeyOptionsCompanion.insert(
          id: const Value<int>(21),
          nodeId: 2,
          optionIndex: 0,
          labelKey: 'key.2.a',
          nextNodeId: const Value<int>(4),
        ),
      )
      ..insert(
        db.keyOptions,
        KeyOptionsCompanion.insert(
          id: const Value<int>(22),
          nodeId: 2,
          optionIndex: 1,
          labelKey: 'key.2.b',
          nextNodeId: const Value<int>(5),
        ),
      )
      // Leaf 3 carries two candidates, leaf 4 one and leaf 5 one — four in all,
      // reachable from node 1 only by descending two levels.
      ..insert(db.keyLeafSpecies, KeyLeafSpeciesCompanion.insert(nodeId: 3, speciesId: 1))
      ..insert(db.keyLeafSpecies, KeyLeafSpeciesCompanion.insert(nodeId: 3, speciesId: 2))
      ..insert(db.keyLeafSpecies, KeyLeafSpeciesCompanion.insert(nodeId: 4, speciesId: 3))
      ..insert(db.keyLeafSpecies, KeyLeafSpeciesCompanion.insert(nodeId: 5, speciesId: 4));
  });
}

void main() {
  late ReferenceDatabase db;
  late IdentificationKeyRepository repo;

  setUp(() async {
    db = await buildRulesFixture();
    addTearDown(db.close);
    repo = DriftIdentificationKeyRepository(db, contentStrings: _strings());
  });

  test(
    'DriftIdentificationKeyRepository.firstStep answers null when the pack carries no key',
    () async {
      // A jurisdiction may ship rules, species and citations and no key at all.
      // That is a fact about the transcription, and it is not an error.
      expect(_unwrap(await repo.firstStep(locale: 'gl')), isNull);
    },
  );

  test('DriftIdentificationKeyRepository.firstStep enters at the node with no parent', () async {
    await _seedKey(db);
    final KeyStep step = _unwrap(await repo.firstStep(locale: 'gl'))!;
    expect(step.nodeId, 1);
    expect(step.question, 'Mira só a aleta caudal.');
  });

  test(
    'DriftIdentificationKeyRepository counts every species under a node, not just its leaves',
    () async {
      // The whole argument for the recursive descent: node 1 carries no
      // `key_leaf_species` row of its own, and reading only those would print
      // "0 species remain" on every question in the key.
      await _seedKey(db);
      final KeyStep step = _unwrap(await repo.firstStep(locale: 'gl'))!;
      expect(step.candidates, hasLength(4));
    },
  );

  test('DriftIdentificationKeyRepository counts each answer separately', () async {
    await _seedKey(db);
    final KeyStep step = _unwrap(await repo.firstStep(locale: 'gl'))!;
    expect(step.leads, hasLength(2));
    // Node 2 reaches leaves 4 and 5; node 3 is a leaf with two of its own.
    expect(step.leads.first.candidates, hasLength(2));
    expect(step.leads.last.candidates, hasLength(2));
  });

  test(
    'DriftIdentificationKeyRepository marks the answers in the order the key sets them',
    () async {
      await _seedKey(db);
      final KeyStep step = _unwrap(await repo.firstStep(locale: 'gl'))!;
      expect(step.leads.map((KeyLead l) => l.mark), <int>[1, 2]);
      expect(step.leads.first.label, 'Profundamente furcada');
      expect(step.leads.first.figureAsset, 'sil/forked.svg');
    },
  );

  test('DriftIdentificationKeyRepository.stepAt answers a leaf with no question', () async {
    await _seedKey(db);
    final KeyStep leaf = _unwrap(await repo.stepAt(3, locale: 'gl'))!;
    expect(leaf.question, isNull);
    expect(leaf.isLeaf, isTrue);
    expect(leaf.candidates.map((KeyCandidate c) => c.speciesId), <int>[1, 2]);
  });

  test(
    'DriftIdentificationKeyRepository.stepAt answers null for a node the pack does not carry',
    () async {
      await _seedKey(db);
      expect(_unwrap(await repo.stepAt(99, locale: 'gl')), isNull);
    },
  );

  test(
    'DriftIdentificationKeyRepository names a candidate by its binomial when the locale has none',
    () async {
      // §9.2's fourth step: Latin is present in every locale and is never wrong.
      await _seedKey(db);
      final KeyStep leaf = _unwrap(await repo.stepAt(3, locale: 'gl'))!;
      expect(leaf.candidates.first.displayName, 'Genus species1');
    },
  );
}
