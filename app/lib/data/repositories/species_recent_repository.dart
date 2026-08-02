import 'package:catchlaw/domain/models/recent_species_entry.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// What this place has seen recently.
///
/// **The one place the two databases meet, and they meet in Dart.**
/// `species_recent` lives in `user.db`; the name and the silhouette live in
/// `reference.db`. `catchlaw-reference-database` rule 11 bans `ATTACH` because
/// a wholesale content swap leaves any statement spanning both files pointing
/// at an unlinked inode — so the recents are read from one, the art from the
/// other, and joined here.
abstract interface class SpeciesRecentRepository {
  /// The strip, most used first and then most recent.
  ///
  /// Frequency before recency, deliberately: the six species a fisher actually
  /// catches should stay at the top of the screen, and a strip ordered only by
  /// recency would be reshuffled by the one unusual fish he looked up last
  /// week.
  Stream<List<RecentSpeciesEntry>> watchRecents({
    required String jurisdictionCode,
    required String zoneCode,
    int limit,
  });

  /// Records that [speciesId] was opened here, now.
  @useResult
  Future<Result<void>> recordUse(
    int speciesId, {
    required String jurisdictionCode,
    required String zoneCode,
    required String at,
  });
}
