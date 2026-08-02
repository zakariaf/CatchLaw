import 'package:catchlaw/domain/models/species.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show TaxonGroup;

/// One species, and the name the fisher's typing actually matched.
///
/// **The matched name travels with the hit**, and that is the whole point of a
/// separate type. A search for `هامور` and a search for `Epinephelus` reach the
/// same species, and a row that showed only the species could not say which
/// word it answered — so the fisher who typed a local name would be shown a
/// Latin binomial and would not recognise his own fish.
///
/// Value equality, so `List` de-duplication and Riverpod's `==` filtering both
/// behave (`FLUTTER_GUIDE.md` §5.3): a view model that rebuilt on every
/// keystroke because two identical result lists compared unequal would spend
/// the §13 latency budget on nothing.
@immutable
class SpeciesSearchHit {
  /// A species and the name that matched.
  const SpeciesSearchHit({
    required this.species,
    required this.matchedName,
    required this.matchedLocale,
    required this.isPrimaryName,
  });

  /// The species itself.
  final Species species;

  /// The vernacular or scientific name the query prefix hit.
  final String matchedName;

  /// Which locale that name is filed under.
  final String matchedLocale;

  /// Whether it is that locale's primary name rather than a regional variant.
  final bool isPrimaryName;

  /// The pack's id.
  int get speciesId => species.id;

  /// The binomial.
  String get scientificName => species.scientificName;

  /// Its family.
  int get familyId => species.familyId;

  /// One of `SPEC.md` §7.1's eight groups.
  TaxonGroup get taxonGroup => species.taxonGroup;

  /// Originated SVG line art.
  String get silhouetteAsset => species.silhouetteAsset;

  /// A cleared plate, or `null` — and `null` is the normal case.
  String? get plateAsset => species.plateAsset;

  @override
  bool operator ==(Object other) =>
      other is SpeciesSearchHit &&
      other.species.id == species.id &&
      other.matchedName == matchedName &&
      other.matchedLocale == matchedLocale &&
      other.isPrimaryName == isPrimaryName;

  @override
  int get hashCode => Object.hash(species.id, matchedName, matchedLocale, isPrimaryName);

  @override
  String toString() => 'SpeciesSearchHit($matchedName [$matchedLocale] -> ${species.id})';
}
