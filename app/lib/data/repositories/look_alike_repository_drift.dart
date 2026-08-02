import 'package:catchlaw/data/daos/reference/look_alike_dao.dart';
import 'package:catchlaw/data/daos/reference/species_browse_dao.dart';
import 'package:catchlaw/data/daos/reference/species_dao.dart';
import 'package:catchlaw/data/repositories/content_string_repository.dart';
import 'package:catchlaw/data/repositories/look_alike_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/look_alike.dart';
import 'package:catchlaw/domain/use_cases/content_string_resolver.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// [LookAlikeRepository] over the read-only `reference.db` (D-6).
final class DriftLookAlikeRepository implements LookAlikeRepository {
  /// Reads pairs out of [db].
  DriftLookAlikeRepository(
    this.db, {
    required ContentStringRepository contentStrings,
    this.boundary = const StorageBoundary(),
  }) : _pairs = LookAlikeDao(db),
       _species = SpeciesDao(db),
       _browse = SpeciesBrowseDao(db),
       _resolver = ContentStringResolver(contentStrings);

  /// The rule book.
  final ReferenceDatabase db;

  /// Where a storage exception becomes a `DataFailure`.
  final StorageBoundary boundary;

  final LookAlikeDao _pairs;
  final SpeciesDao _species;
  final SpeciesBrowseDao _browse;
  final ContentStringResolver _resolver;

  @override
  Future<Result<List<LookAlike>>> forSpecies(int speciesId, {required String locale}) =>
      boundary.guard(() async {
        final List<LookalikeRow> rows = await _pairs.forSpecies(speciesId);
        if (rows.isEmpty) return const <LookAlike>[];

        final Set<int> protectedIds = await _browse.protectedSpeciesIds();
        final pairs = <LookAlike>[];
        final seen = <int>{};

        for (final row in rows) {
          if (!seen.add(row.confusedWith)) continue;
          final SpeciesRow? other = await _species.byId(row.confusedWith);
          // A pair naming a species the pack no longer carries is dropped
          // rather than rendered as a warning about nothing.
          if (other == null) continue;

          pairs.add(
            LookAlike(
              confusedWithSpeciesId: other.id,
              confusedWithName: await _nameFor(other, locale),
              confusedWithScientificName: other.scientificName,
              confusedWithSilhouetteAsset: other.silhouetteAsset,
              confusedWithPlateAsset: other.plateAsset,
              // A sentence FROM THE PACK. It describes a physical character and
              // never what to do about it, and the §9.2 chain means it can
              // never render a raw key.
              difference: await _resolver.resolve(
                row.differenceKey,
                requestedLocale: locale,
                defaultLocale: locale,
              ),
              confusedWithIsProtected: protectedIds.contains(other.id),
            ),
          );
        }
        return pairs;
      });

  Future<String> _nameFor(SpeciesRow row, String locale) async {
    final List<SpeciesNameRow> names = await _species.namesFor(row.id);
    for (final name in names) {
      if (name.locale == locale && name.isPrimary) return name.name;
    }
    for (final name in names) {
      if (name.locale == locale) return name.name;
    }
    return row.scientificName;
  }
}
