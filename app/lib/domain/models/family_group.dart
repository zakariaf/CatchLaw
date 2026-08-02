import 'dart:collection';

import 'package:meta/meta.dart';

/// One species as S6's grid draws it.
@immutable
class SpeciesTile {
  /// A silhouette and the name under it.
  const SpeciesTile({
    required this.speciesId,
    required this.silhouetteAsset,
    required this.displayName,
    required this.scientificName,
    required this.isProtected,
    this.plateAsset,
  });

  /// The pack's id.
  final int speciesId;

  /// Originated SVG line art — black on white, which is what survives sunlight.
  final String silhouetteAsset;

  /// The name in the reader's own language.
  final String displayName;

  /// The binomial, set small and last.
  final String scientificName;

  /// Whether any rule in this pack protects it.
  final bool isProtected;

  /// A cleared plate, or `null` — and `null` is the normal case.
  final String? plateAsset;

  @override
  bool operator ==(Object other) => other is SpeciesTile && other.speciesId == speciesId;

  @override
  int get hashCode => speciesId.hashCode;
}

/// One family, and the species inside it.
///
/// **The family name is localised**, and that is the point of the type. A
/// Galician grid says *Vieiras*, not *Pectinidae*: a mariscadora browsing by
/// shape is looking for a scallop, and the Latin is a label she has no reason
/// to know. The binomial is still carried, small and last, because it is the
/// one name that is the same everywhere.
@immutable
class FamilyGroup {
  /// A family and its species.
  FamilyGroup({
    required this.familyId,
    required this.scientificFamily,
    required this.localisedFamilyName,
    required List<SpeciesTile> species,
  }) : species = UnmodifiableListView<SpeciesTile>(species);

  /// The pack's id.
  final int familyId;

  /// `Pectinidae`.
  final String scientificFamily;

  /// `Vieiras`, resolved through the §9.2 chain.
  final String localisedFamilyName;

  /// Its species, ordered by display name in the reader's own collation.
  final UnmodifiableListView<SpeciesTile> species;

  @override
  bool operator ==(Object other) => other is FamilyGroup && other.familyId == familyId;

  @override
  int get hashCode => familyId.hashCode;
}
