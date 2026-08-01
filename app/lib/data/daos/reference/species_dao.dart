import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/tables/reference/taxonomy.dart';
import 'package:drift/drift.dart';

part 'species_dao.g.dart';

/// Reads species, their names and their lookalikes out of the rule book.
///
/// **The search is a prefix scan over `search_norm`, not a `LIKE '%…%'`.**
/// `idx_name_search` is a B-tree, so a leading wildcard cannot use it and the
/// query degrades to a full scan of 2,400 rows at every keystroke — which is
/// the difference between the §13 budget and a search box that stutters on a
/// wet phone.
///
/// The caller passes an **already normalised** prefix. Normalising here would be
/// a second fold: the index was written by the content build using the engine's
/// `normaliseSpeciesTerm`, and a query folded any other way matches nothing at
/// all, silently.
@DriftAccessor(tables: <Type>[SpeciesTable, SpeciesNames, Lookalikes])
class SpeciesDao extends DatabaseAccessor<ReferenceDatabase> with _$SpeciesDaoMixin {
  /// Reads species from [db].
  SpeciesDao(super.db);

  /// Species whose normalised name starts with [prefix].
  ///
  /// Returns **distinct** species: an Arabic name carrying `ال` has two
  /// `species_name` rows with the same display name (E04/T07), and without the
  /// distinct the same fish appears twice in the list.
  Future<List<SpeciesRow>> searchByNormalisedPrefix(String prefix, {int limit = 40}) async {
    if (prefix.isEmpty) return const <SpeciesRow>[];
    final List<QueryRow> rows = await customSelect(
      'SELECT DISTINCT s.* FROM species s '
      'JOIN species_name n ON n.species_id = s.id '
      'WHERE n.search_norm >= ?1 AND n.search_norm < ?2 '
      'ORDER BY s.scientific_name LIMIT ?3',
      variables: <Variable<Object>>[
        Variable<String>(prefix),
        // The half-open upper bound that keeps this a range scan. Appending a
        // high codepoint is what turns `LIKE 'ham%'` into two B-tree seeks.
        Variable<String>('$prefix\u{10FFFF}'),
        Variable<int>(limit),
      ],
      readsFrom: <ResultSetImplementation<HasResultSet, Object>>{speciesTable, speciesNames},
    ).get();
    return rows.map((QueryRow r) => speciesTable.map(r.data)).toList();
  }

  /// One species, or `null` when the pack no longer carries it.
  ///
  /// Nullable on purpose: `catch.species_id` is a **soft** reference into a file
  /// a content update replaces wholesale, and a record whose species has been
  /// retired must still render.
  Future<SpeciesRow?> byId(int id) =>
      (select(speciesTable)..where(($SpeciesTableTable t) => t.id.equals(id))).getSingleOrNull();

  /// Every species of one family, for S6's browse-by-shape.
  Future<List<SpeciesRow>> byFamily(int familyId) =>
      (select(speciesTable)
            ..where(($SpeciesTableTable t) => t.familyId.equals(familyId))
            ..orderBy(<OrderClauseGenerator<$SpeciesTableTable>>[
              ($SpeciesTableTable t) => OrderingTerm(expression: t.scientificName),
            ]))
          .get();

  /// Every name of one species, in every locale.
  ///
  /// The caller filters by locale and **must** select distinct display names or
  /// filter on `is_primary`: the article-stripped row shares its `name` with the
  /// row it was derived from.
  Future<List<SpeciesNameRow>> namesFor(int speciesId) =>
      (select(speciesNames)..where(($SpeciesNamesTable t) => t.speciesId.equals(speciesId))).get();

  /// What this species is confused with, and how to tell them apart.
  Future<List<LookalikeRow>> lookalikesFor(int speciesId) =>
      (select(lookalikes)..where(($LookalikesTable t) => t.speciesId.equals(speciesId))).get();
}
