import 'package:catchlaw/data/repositories/species_search_repository.dart';
import 'package:catchlaw/domain/models/species_search_hit.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// An in-memory [SpeciesSearchRepository].
///
/// Bare `implements`, never `extends` with a `noSuchMethod` catch-all: adding a
/// method to the interface must be a compile error here, not a runtime surprise
/// three screens later.
final class FakeSpeciesSearchRepository implements SpeciesSearchRepository {
  /// Serves [hitsByPrefix], or fails every call with [failure].
  FakeSpeciesSearchRepository(this.hitsByPrefix, {this.failure, this.count = 0});

  /// Normalised prefix → what that prefix finds.
  final Map<String, List<SpeciesSearchHit>> hitsByPrefix;

  /// What every call fails with, when the test is about a broken store.
  final Exception? failure;

  /// What [speciesCount] reports.
  final int count;

  /// Every query this repository was asked, in order.
  ///
  /// A spy and not a counter: the §13 budget is per keystroke, and a view model
  /// that fired twice for one letter is a bug a count of "at least one" would
  /// pass over.
  final List<String> queries = <String>[];

  @override
  Future<Result<List<SpeciesSearchHit>>> search(
    String rawQuery, {
    required String locale,
    int limit = 40,
  }) async {
    queries.add(rawQuery);
    if (failure != null) return Result<List<SpeciesSearchHit>>.error(failure!);
    return Result<List<SpeciesSearchHit>>.ok(hitsByPrefix[rawQuery] ?? const <SpeciesSearchHit>[]);
  }

  @override
  Future<Result<int>> speciesCount() async {
    if (failure != null) return Result<int>.error(failure!);
    return Result<int>.ok(count);
  }
}
