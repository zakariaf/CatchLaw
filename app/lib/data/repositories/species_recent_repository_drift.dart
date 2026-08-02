import 'package:catchlaw/data/daos/reference/species_dao.dart';
import 'package:catchlaw/data/daos/user/user_settings_dao.dart';
import 'package:catchlaw/data/repositories/species_recent_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/recent_species_entry.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// [SpeciesRecentRepository] across both databases.
final class DriftSpeciesRecentRepository implements SpeciesRecentRepository {
  /// Reads recents from [userDb] and their art from [referenceDb].
  DriftSpeciesRecentRepository({
    required UserDatabase userDb,
    required ReferenceDatabase referenceDb,
    this.boundary = const StorageBoundary(),
  }) : _recents = SpeciesRecentDao(userDb),
       _species = SpeciesDao(referenceDb);

  /// Where a storage exception becomes a `DataFailure`.
  final StorageBoundary boundary;

  final SpeciesRecentDao _recents;
  final SpeciesDao _species;

  @override
  Stream<List<RecentSpeciesEntry>> watchRecents({
    required String jurisdictionCode,
    required String zoneCode,
    int limit = 6,
  }) => _recents
      .watchRecent(jurisdictionCode: jurisdictionCode, zoneCode: zoneCode, limit: limit)
      .asyncMap((List<SpeciesRecentRow> rows) async {
        final entries = <RecentSpeciesEntry>[];
        for (final row in rows) {
          // The join, in Dart. ATTACH is banned across the two files because a
          // wholesale content swap leaves any statement spanning them pointing
          // at an unlinked inode.
          final SpeciesRow? species = await _species.byId(row.speciesId);
          // A retired species drops out of the strip rather than appearing as a
          // nameless tile: `species_id` is a SOFT reference into a file a
          // content update replaces wholesale.
          if (species == null) continue;
          entries.add(
            RecentSpeciesEntry(
              speciesId: row.speciesId,
              useCount: row.useCount,
              lastUsedAt: row.lastUsedAt,
              displayName: species.scientificName,
              silhouetteAsset: species.silhouetteAsset,
              plateAsset: species.plateAsset,
            ),
          );
        }
        return entries;
      });

  @override
  Future<Result<void>> recordUse(
    int speciesId, {
    required String jurisdictionCode,
    required String zoneCode,
    required String at,
  }) => boundary.guard(
    () => _recents.recordUse(
      speciesId: speciesId,
      jurisdictionCode: jurisdictionCode,
      zoneCode: zoneCode,
      at: at,
    ),
  );
}
