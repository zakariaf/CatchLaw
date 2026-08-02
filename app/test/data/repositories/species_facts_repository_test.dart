// The §7.3 predicates: which rules reach this zone, what expiry does, and which
// hint outranks which.
//
// Against a SYNTHETIC pack, and that is deliberate. E04's Galicia seed carries
// zero `rule` rows — it is a structural seed, and the authored content is E22's
// whole epic — so a test pointed at the built reference.db would pass over an
// empty table, which is the same silent-green failure CONVENTIONS.md §7 records
// for gates. The question here is about the predicate, not about whether
// drift's Table classes and the builder's DDL agree; that second question is
// what openBuiltReference() is for, and the DAO tests that ask it still do.

import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/repositories/species_facts_repository.dart';
import 'package:catchlaw/data/repositories/species_facts_repository_drift.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/rule_hint.dart';
import 'package:catchlaw/domain/models/species_facts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show MeasurementMethod, Ok, Result;

import '../../../testing/fixtures/rules_fixture.dart';

T _unwrap<T>(Result<T> r) => switch (r) {
  Ok<T>(:final T value) => value,
  _ => throw StateError('facts failed: $r'),
};

void main() {
  late ReferenceDatabase db;
  late SpeciesFactsRepository repo;

  setUp(() async {
    db = await buildRulesFixture();
    addTearDown(db.close);
    repo = DriftSpeciesFactsRepository(db);
  });

  Future<Map<int, SpeciesFacts>> facts({
    List<int> ids = const <int>[1, 2, 3, 4, 5, 6],
    List<int> chain = const <int>[11, 10],
    String on = '2026-08-01',
  }) async => _unwrap(
    await repo.factsFor(speciesIds: ids, jurisdictionId: 1, zoneChain: chain, onDate: on),
  );

  test('DriftSpeciesFactsRepository.factsFor carries a citation for every fact', () async {
    // Invariant 3, and the reason a rule whose citation does not resolve is
    // DROPPED rather than rendered with a blank footnote: a hint with no
    // citation is the app asserting the law on its own authority.
    final Map<int, SpeciesFacts> all = await facts();
    expect(all, isNotEmpty);
    for (final SpeciesFacts fact in all.values) {
      expect(fact.citation.instrument, isNotEmpty);
    }
  });

  test('DriftSpeciesFactsRepository.factsFor omits a species with no rule row', () async {
    // Absent from the map is "no rule recorded", which is NOT "no limit in
    // instrument". Merging the two turns silence into permission.
    expect(await facts(ids: <int>[999]), isEmpty);
  });

  test('DriftSpeciesFactsRepository.factsFor marks a jurisdiction-wide rule as in zone', () async {
    // §7.3 step 2: a NULL zone_id covers the whole jurisdiction, so it reaches
    // the active zone whatever that zone is — including before one is chosen.
    expect((await facts())[1]!.inActiveZone, isTrue);
    expect((await facts(chain: const <int>[]))[1]!.inActiveZone, isTrue);
  });

  test(
    'DriftSpeciesFactsRepository.factsFor marks a rule on the active subzone as in zone',
    () async {
      expect((await facts())[2]!.inActiveZone, isTrue);
    },
  );

  test(
    'DriftSpeciesFactsRepository.factsFor marks a rule on an ancestor zone as in zone',
    () async {
      // The chain is the zone AND its ancestors. A rule pinned to the region
      // reaches a fisher standing in the ría inside it.
      final Map<int, SpeciesFacts> inRegionOnly = _unwrap(
        await repo.factsFor(
          speciesIds: const <int>[2],
          jurisdictionId: 1,
          zoneChain: const <int>[11, 10],
          onDate: '2026-08-01',
        ),
      );
      expect(inRegionOnly[2]!.inActiveZone, isTrue);
    },
  );

  test('DriftSpeciesFactsRepository.factsFor marks a rule on another zone as elsewhere', () async {
    // Elsewhere, and STILL RETURNED: a fisher who has picked the wrong zone
    // must be able to see that his fish exists, rather than being told it does
    // not.
    final Map<int, SpeciesFacts> all = await facts();
    expect(all.containsKey(3), isTrue);
    expect(all[3]!.inActiveZone, isFalse);
  });

  test('DriftSpeciesFactsRepository.factsFor still returns a rule that has expired', () async {
    // §7.3 step 1 and invariant 5: valid_to is not a filter. Species 6's only
    // rule lapsed in 2021 and must still appear WITH its numbers, behind a bar
    // — not vanish, which reads as "no rule recorded" and is permissive.
    final Map<int, SpeciesFacts> all = await facts();
    expect(all.containsKey(6), isTrue);
    expect(all[6]!.hint, isA<MinimumSizeHint>());
    expect((all[6]!.hint as MinimumSizeHint).millimetres, 500);
  });

  test('DriftSpeciesFactsRepository.factsFor honours valid_from', () async {
    // The one date bound that IS a filter: a rule that has not come into force
    // is not law yet.
    expect(await facts(on: '1900-01-01'), isEmpty);
  });

  test(
    'DriftSpeciesFactsRepository.factsFor gives a protected species the protected hint',
    () async {
      // Protected outranks a size, because they are not two facts of equal
      // weight: a protected species may not be taken at any size in any month,
      // so leading with a minimum would be true and useless. Species 4 carries
      // BOTH, and the hint must be the protection.
      expect((await facts())[4]!.hint, isA<ProtectedHint>());
    },
  );

  test('DriftSpeciesFactsRepository.factsFor gives a closed species the closure hint', () async {
    // A closure outranks a size for the same reason, one step down. Species 5
    // carries both.
    expect((await facts())[5]!.hint, isA<ClosedSeasonHint>());
  });

  test(
    'DriftSpeciesFactsRepository.factsFor carries the measurement method with the size',
    () async {
      // The pair is inseparable. TL and FL differ by 6-9 cm on a Kanaad, so a
      // minimum with no method is a number the reader would have to guess at.
      final hint = (await facts())[2]!.hint as MinimumSizeHint;
      expect(hint.millimetres, 650);
      expect(hint.method, MeasurementMethod.forkLength);
    },
  );

  test('DriftSpeciesFactsRepository.zoneChain walks a subzone to its root', () async {
    expect(_unwrap(await repo.zoneChain(11)), <int>[11, 10]);
  });

  test('DriftSpeciesFactsRepository.zoneChain returns a root zone alone', () async {
    expect(_unwrap(await repo.zoneChain(10)), <int>[10]);
  });

  test('measurementMethodOfId falls back rather than throwing on an unknown id', () {
    // The id comes out of a file a content update replaces wholesale, so a
    // value this build does not recognise must not throw on a fisher's phone.
    // A hint that named the wrong method still carries the right number; a
    // crash carries nothing.
    expect(measurementMethodOfId(1), MeasurementMethod.totalLength);
    expect(measurementMethodOfId(2), MeasurementMethod.forkLength);
    expect(measurementMethodOfId(99), MeasurementMethod.totalLength);
  });
}
