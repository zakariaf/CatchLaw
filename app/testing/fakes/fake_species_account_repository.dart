import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/species_account_repository.dart';
import 'package:catchlaw/domain/models/species_account.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// An in-memory [SpeciesAccountRepository].
final class FakeSpeciesAccountRepository implements SpeciesAccountRepository {
  /// Serves [accounts], or fails every call with [failure].
  FakeSpeciesAccountRepository(this.accounts, {this.failure});

  /// species id → its account.
  final Map<int, SpeciesAccount> accounts;

  /// What every call fails with, when the test is about a broken store.
  final Exception? failure;

  /// Every species id this repository was asked for, in order.
  final List<int> asked = <int>[];

  @override
  Future<Result<SpeciesAccount>> accountFor(int speciesId, {required String locale}) async {
    asked.add(speciesId);
    if (failure != null) return Result<SpeciesAccount>.error(failure!);
    final SpeciesAccount? found = accounts[speciesId];
    if (found == null) {
      // The same failure the real one raises for a retired species: a soft
      // reference into a file a content update replaces wholesale.
      return Result<SpeciesAccount>.error(DataNotFound(entity: 'species', id: '$speciesId'));
    }
    return Result<SpeciesAccount>.ok(found);
  }
}
