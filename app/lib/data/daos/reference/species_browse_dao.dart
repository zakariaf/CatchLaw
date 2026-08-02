import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/tables/reference/rule.dart';
import 'package:catchlaw/data/services/tables/reference/taxonomy.dart';
import 'package:drift/drift.dart';

part 'species_browse_dao.g.dart';

/// S6's grid: every species, grouped by family.
@DriftAccessor(tables: <Type>[SpeciesTable, Families, SpeciesNames, Rules])
class SpeciesBrowseDao extends DatabaseAccessor<ReferenceDatabase> with _$SpeciesBrowseDaoMixin {
  /// Reads the grid from [db].
  SpeciesBrowseDao(super.db);

  /// Every family that has at least one species, with its name key.
  Future<List<FamilyRow>> familiesWithSpecies() async {
    final List<QueryRow> rows = await customSelect(
      'SELECT f.* FROM family f '
      'WHERE EXISTS (SELECT 1 FROM species s WHERE s.family_id = f.id) '
      'ORDER BY f.scientific',
      readsFrom: <ResultSetImplementation<HasResultSet, Object>>{families, speciesTable},
    ).get();
    return rows.map((QueryRow r) => families.map(r.data)).toList();
  }

  /// Every species, ordered by family and then by scientific name.
  ///
  /// Ordered here only as a stable base; the **display** order is by localised
  /// name and is applied in Dart, because SQLite's `ORDER BY` collates bytes
  /// and `Ñ` would sort after `Z` in a Galician grid.
  Future<List<SpeciesRow>> allSpecies() =>
      (select(speciesTable)..orderBy(<OrderClauseGenerator<$SpeciesTableTable>>[
            (t) => OrderingTerm.asc(t.familyId),
            (t) => OrderingTerm.asc(t.scientificName),
          ]))
          .get();

  /// The species this pack protects anywhere in it.
  ///
  /// Anywhere, deliberately: a grid tile is a browse affordance rather than a
  /// verdict, and a species protected in the next zone along is one a fisher
  /// should see marked before he taps it.
  Future<Set<int>> protectedSpeciesIds() async {
    final List<QueryRow> rows = await customSelect(
      'SELECT DISTINCT species_id FROM rule WHERE is_protected = 1',
      readsFrom: <ResultSetImplementation<HasResultSet, Object>>{rules},
    ).get();
    return rows.map((QueryRow r) => r.read<int>('species_id')).toSet();
  }
}
