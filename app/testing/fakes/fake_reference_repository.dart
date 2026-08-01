import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/reference_repository.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:rule_engine/rule_engine.dart' show Citation, ClosedSeason, Result, Rule;

import 'store_env.dart';

/// A [ReferenceRepository] with no database behind it.
///
/// **Bare `implements`, no `Mock` superclass and no `noSuchMethod`.** Adding a
/// method to the interface must be a compile error here, not a runtime surprise
/// in whichever test happens to call it first.
final class FakeReferenceRepository implements ReferenceRepository {
  /// A rule book in [env], answering with [species], [rules] and
  /// [stringValues].
  ///
  /// `stringValues` rather than `strings`, because [strings] is a method on the
  /// interface and a field cannot share its name.
  FakeReferenceRepository({
    this.env = StoreEnv.healthy,
    this.species = const <Species>[],
    this.rules = const <Rule>[],
    this.stringValues = const <String, String>{},
  });

  /// Which world this store is in.
  final StoreEnv env;

  /// What this rule book knows.
  final List<Species> species;

  /// The rules it will hand back.
  final List<Rule> rules;

  /// The `content_string` values it can resolve.
  final Map<String, String> stringValues;

  /// Every prefix [searchSpecies] was asked for, in order.
  ///
  /// A spy list, so a test asserts WHAT was searched rather than that
  /// searching happened — the normalisation is the thing most likely to be
  /// wrong, and it is invisible to a call count.
  final List<String> searched = <String>[];

  @override
  Future<Result<List<Species>>> searchSpecies(String normalisedPrefix, {int limit = 40}) async {
    searched.add(normalisedPrefix);
    return _read(
      env == StoreEnv.empty
          ? const <Species>[]
          : species
                .where((Species s) => s.scientificName.toLowerCase().contains(normalisedPrefix))
                .take(limit)
                .toList(),
    );
  }

  @override
  Future<Result<Species>> speciesById(int id) async {
    final Species? found = species.where((Species s) => s.id == id).firstOrNull;
    if (found == null || env == StoreEnv.empty) {
      return Result<Species>.error(DataNotFound(entity: 'species', id: '$id'));
    }
    return _read(found);
  }

  @override
  Future<Result<List<SpeciesName>>> namesFor(int speciesId) async => _read(const <SpeciesName>[]);

  @override
  Future<Result<List<Rule>>> candidateRules({
    required int jurisdictionId,
    required int speciesId,
    required String waterType,
    required String onDate,
  }) async => _read(
    env == StoreEnv.empty
        ? const <Rule>[]
        : rules.where((Rule r) => r.speciesId == speciesId).toList(),
  );

  @override
  Future<Result<List<ClosedSeason>>> closedSeasonsFor(Iterable<int> ruleIds) async =>
      _read(<ClosedSeason>[
        for (final Rule r in rules.where((Rule r) => ruleIds.contains(r.id))) ...r.closedSeasons,
      ]);

  @override
  Future<Result<List<Citation>>> citations(Iterable<int> ids) async =>
      _read(<Citation>[for (final Rule r in rules) r.citation]);

  @override
  Future<Result<Map<String, String>>> strings(Iterable<String> keys, String locale) async =>
      _read(<String, String>{
        for (final String k in keys)
          if (stringValues.containsKey(k)) k: stringValues[k]!,
      });

  @override
  Future<Result<List<Zone>>> zones(int jurisdictionId) async => _read(const <Zone>[]);

  @override
  Future<Result<Map<String, String>>> contentMeta() async =>
      _read(const <String, String>{'content_version': 'fake'});

  Result<T> _read<T>(T value) {
    final DataFailure? failure = env.readFailure;
    return failure == null ? Result<T>.ok(value) : Result<T>.error(failure);
  }
}
