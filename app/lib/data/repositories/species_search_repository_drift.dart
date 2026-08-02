import 'package:catchlaw/data/daos/reference/species_search_dao.dart';
import 'package:catchlaw/data/model/mappers.dart';
import 'package:catchlaw/data/repositories/species_search_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/domain/models/species_search_hit.dart';
import 'package:rule_engine/rule_engine.dart' show Result, normaliseSpeciesTerm;

/// [SpeciesSearchRepository] over the read-only `reference.db` (D-6).
final class DriftSpeciesSearchRepository implements SpeciesSearchRepository {
  /// Searches [db].
  DriftSpeciesSearchRepository(this.db, {this.boundary = const StorageBoundary()})
    : _dao = SpeciesSearchDao(db);

  /// The rule book.
  final ReferenceDatabase db;

  /// Where a storage exception becomes a `DataFailure`.
  final StorageBoundary boundary;

  final SpeciesSearchDao _dao;

  @override
  Future<Result<List<SpeciesSearchHit>>> search(
    String rawQuery, {
    required String locale,
    int limit = 40,
  }) => boundary.guard(() async {
    // The engine's own fold, the one the content build used to write
    // search_norm. Folding here rather than at the call site means there is
    // exactly one place it can be got wrong.
    final String prefix = normaliseSpeciesTerm(rawQuery);
    if (prefix.isEmpty) return const <SpeciesSearchHit>[];

    final List<SpeciesNameRow> names = await _dao.matchingNames(
      prefix,
      locale: locale,
      limit: limit,
    );
    if (names.isEmpty) return const <SpeciesSearchHit>[];

    final speciesById = <int, SpeciesRow>{
      for (final SpeciesRow row in await _dao.speciesByIds(
        names.map((SpeciesNameRow n) => n.speciesId),
      ))
        row.id: row,
    };

    // One hit per species, keeping the FIRST name row — which the statement
    // already ordered by locale, then primary, then brevity. An Arabic name
    // carrying `ال` has two rows with the same display name (E04/T07), and
    // without this the same fish appears twice.
    final hits = <int, SpeciesSearchHit>{};
    for (final name in names) {
      if (hits.containsKey(name.speciesId)) continue;
      final SpeciesRow? row = speciesById[name.speciesId];
      // A name whose species is absent is a pack this build did not produce;
      // it is dropped rather than rendered as a row with no fish behind it.
      if (row == null) continue;
      final Species species = toSpecies(row);
      hits[name.speciesId] = SpeciesSearchHit(
        species: species,
        matchedName: name.name,
        matchedLocale: name.locale,
        isPrimaryName: name.isPrimary,
      );
    }
    return hits.values.toList();
  });

  @override
  Future<Result<int>> speciesCount() => boundary.guard(_dao.speciesCount);
}
