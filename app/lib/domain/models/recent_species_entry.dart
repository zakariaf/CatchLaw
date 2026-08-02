import 'package:meta/meta.dart';

/// One species in the recents strip, with the art and name it renders as.
///
/// A separate type from `RecentSpecies`, which is the `user.db` row and knows
/// nothing about a name: the strip needs both halves, and the join between them
/// happens in Dart because `ATTACH` is banned across the two files.
@immutable
class RecentSpeciesEntry {
  /// A recent species and how it draws.
  const RecentSpeciesEntry({
    required this.speciesId,
    required this.useCount,
    required this.lastUsedAt,
    required this.displayName,
    required this.silhouetteAsset,
    this.plateAsset,
  });

  /// The soft species reference.
  final int speciesId;

  /// How many times it has been opened here.
  final int useCount;

  /// When, last.
  final String lastUsedAt;

  /// Its name in the reader's own language.
  final String displayName;

  /// Its silhouette.
  final String silhouetteAsset;

  /// Its plate, when one cleared.
  final String? plateAsset;

  @override
  bool operator ==(Object other) =>
      other is RecentSpeciesEntry &&
      other.speciesId == speciesId &&
      other.useCount == useCount &&
      other.lastUsedAt == lastUsedAt;

  @override
  int get hashCode => Object.hash(speciesId, useCount, lastUsedAt);
}
