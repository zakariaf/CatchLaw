import 'package:catchlaw/data/repositories/species_facts_repository.dart';
import 'package:catchlaw/domain/models/species_facts.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// An in-memory [SpeciesFactsRepository].
///
/// Bare `implements`: adding a method to the interface must be a compile error
/// here, not a runtime surprise three screens later.
final class FakeSpeciesFactsRepository implements SpeciesFactsRepository {
  /// Serves [facts], or fails every call with [failure].
  FakeSpeciesFactsRepository(this.facts, {this.failure, this.chain = const <int>[]});

  /// species id → what the rules say.
  ///
  /// A species **absent** from this map is a species with no rule row in the
  /// pack, which is not "no limit in instrument" — the fake models the same
  /// three states the real one does.
  final Map<int, SpeciesFacts> facts;

  /// What every call fails with, when the test is about a broken store.
  final Exception? failure;

  /// What [zoneChain] reports.
  final List<int> chain;

  /// Every id set this repository was asked about, in order.
  final List<List<int>> asked = <List<int>>[];

  @override
  Future<Result<Map<int, SpeciesFacts>>> factsFor({
    required List<int> speciesIds,
    required int jurisdictionId,
    required List<int> zoneChain,
    required String onDate,
  }) async {
    asked.add(speciesIds);
    if (failure != null) return Result<Map<int, SpeciesFacts>>.error(failure!);
    return Result<Map<int, SpeciesFacts>>.ok(<int, SpeciesFacts>{
      for (final int id in speciesIds)
        if (facts.containsKey(id)) id: facts[id]!,
    });
  }

  @override
  Future<Result<List<int>>> zoneChain(int zoneId) async {
    if (failure != null) return Result<List<int>>.error(failure!);
    return Result<List<int>>.ok(chain);
  }
}
