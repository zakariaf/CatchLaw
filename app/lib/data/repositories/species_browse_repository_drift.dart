import 'package:catchlaw/data/daos/reference/species_browse_dao.dart';
import 'package:catchlaw/data/daos/reference/species_dao.dart';
import 'package:catchlaw/data/repositories/content_string_repository.dart';
import 'package:catchlaw/data/repositories/species_browse_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/family_group.dart';
import 'package:catchlaw/domain/use_cases/content_string_resolver.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// [SpeciesBrowseRepository] over the read-only `reference.db` (D-6).
final class DriftSpeciesBrowseRepository implements SpeciesBrowseRepository {
  /// Reads the grid out of [db].
  DriftSpeciesBrowseRepository(
    this.db, {
    required ContentStringRepository contentStrings,
    this.boundary = const StorageBoundary(),
  }) : _browse = SpeciesBrowseDao(db),
       _species = SpeciesDao(db),
       _resolver = ContentStringResolver(contentStrings);

  /// The rule book.
  final ReferenceDatabase db;

  /// Where a storage exception becomes a `DataFailure`.
  final StorageBoundary boundary;

  final SpeciesBrowseDao _browse;
  final SpeciesDao _species;
  final ContentStringResolver _resolver;

  @override
  Future<Result<List<FamilyGroup>>> browseByFamily({required String locale}) =>
      boundary.guard(() async {
        final List<FamilyRow> families = await _browse.familiesWithSpecies();
        if (families.isEmpty) return const <FamilyGroup>[];

        final List<SpeciesRow> allSpecies = await _browse.allSpecies();
        final Set<int> protectedIds = await _browse.protectedSpeciesIds();

        final groups = <FamilyGroup>[];
        for (final family in families) {
          final List<SpeciesRow> members = allSpecies
              .where((SpeciesRow s) => s.familyId == family.id)
              .toList();
          if (members.isEmpty) continue;

          final tiles = <SpeciesTile>[];
          for (final row in members) {
            tiles.add(
              SpeciesTile(
                speciesId: row.id,
                silhouetteAsset: row.silhouetteAsset,
                plateAsset: row.plateAsset,
                displayName: await _displayName(row, locale),
                scientificName: row.scientificName,
                isProtected: protectedIds.contains(row.id),
              ),
            );
          }
          // Sorted in Dart, not in SQL: SQLite's ORDER BY collates bytes, and
          // `Ñ` would sort after `Z` in a Galician grid.
          tiles.sort((SpeciesTile a, SpeciesTile b) => a.displayName.compareTo(b.displayName));

          groups.add(
            FamilyGroup(
              familyId: family.id,
              scientificFamily: family.scientific,
              // A Galician grid says Vieiras, not Pectinidae. The §9.2 chain
              // ends at the scientific name, so a family with no localised name
              // still has a heading rather than a blank.
              localisedFamilyName: await _resolver.resolve(
                family.nameKey,
                requestedLocale: locale,
                defaultLocale: locale,
                scientificName: family.scientific,
              ),
              species: tiles,
            ),
          );
        }
        return groups;
      });

  /// The species' name in [locale], falling back to its binomial.
  Future<String> _displayName(SpeciesRow row, String locale) async {
    final List<SpeciesNameRow> names = await _species.namesFor(row.id);
    for (final name in names) {
      if (name.locale == locale && name.isPrimary) return name.name;
    }
    for (final name in names) {
      if (name.locale == locale) return name.name;
    }
    // Latin is present in every locale and is never wrong — §9.2's fourth step.
    return row.scientificName;
  }
}
