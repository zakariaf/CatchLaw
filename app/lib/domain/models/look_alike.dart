import 'package:meta/meta.dart';

/// Two species that are mistaken for each other, and the character that
/// separates them.
///
/// **This card is why the key is auditable and a classifier is not.**
/// `SPEC.md` §5.2 point 2 argues the whole identification design and ends on
/// this: *a wrong confident classification on a protected species is the worst
/// failure this app could have.* The card is where the app admits that two fish
/// look alike and says, in one sentence, which character tells them apart. It
/// is the cheapest possible defence against the most expensive possible error.
@immutable
class LookAlike {
  /// Records the confusion and its resolution.
  const LookAlike({
    required this.confusedWithSpeciesId,
    required this.confusedWithName,
    required this.confusedWithScientificName,
    required this.difference,
    required this.confusedWithIsProtected,
    required this.confusedWithSilhouetteAsset,
    this.confusedWithPlateAsset,
  });

  /// The other species' id.
  final int confusedWithSpeciesId;

  /// Its name in the reader's own language.
  final String confusedWithName;

  /// Its binomial.
  final String confusedWithScientificName;

  /// The one character that separates them, resolved through the §9.2 chain.
  ///
  /// A **sentence from the pack**, not a sentence this app wrote. It describes
  /// a physical character — bar count, spot density, sculpture — and never what
  /// to do about it.
  final String difference;

  /// Whether the other species is protected anywhere in this pack.
  ///
  /// The whole reason the card matters: mistaking an unprotected fish for a
  /// protected one costs nothing, and the reverse costs a licence.
  final bool confusedWithIsProtected;

  /// Its silhouette.
  final String confusedWithSilhouetteAsset;

  /// Its plate, when one cleared.
  ///
  /// A look-alike pair is exactly where a plate earns its licensing cost: a
  /// smudge of outline cannot separate two emperors, which is the failure this
  /// card exists to warn about.
  final String? confusedWithPlateAsset;

  @override
  bool operator ==(Object other) =>
      other is LookAlike && other.confusedWithSpeciesId == confusedWithSpeciesId;

  @override
  int get hashCode => confusedWithSpeciesId.hashCode;
}
