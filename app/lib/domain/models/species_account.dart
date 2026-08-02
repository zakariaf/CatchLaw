import 'dart:collection';

import 'package:catchlaw/domain/models/species.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show TaxonGroup;

/// Everything S2 knows about one species that does not depend on a rule.
///
/// **The primary name is the reader's own, and the binomial is last.** Khalid
/// does not read Latin: a header that led with *Epinephelus coioides* would put
/// the one string he cannot check at the top of a screen he has ten seconds
/// for. The other-locale names are kept and shown small, because a fisher
/// working a Spanish market with a Galician boat needs both words.
@immutable
class SpeciesAccount {
  /// One species, as its account page reads.
  SpeciesAccount({
    required this.species,
    required this.familyName,
    required this.primaryName,
    required List<SpeciesName> otherNames,
    required this.isProtectedAnywhere,
  }) : otherNames = UnmodifiableListView<SpeciesName>(otherNames);

  /// The species and its assets.
  final Species species;

  /// The family, in the reader's own language.
  final String familyName;

  /// The name to set large.
  ///
  /// Nullable in no sense: §9.2's chain ends at the binomial, so a species with
  /// no name in any locale still has one to show — Latin is present in every
  /// locale and is never wrong.
  final String primaryName;

  /// Every other name the pack carries, in every locale.
  final UnmodifiableListView<SpeciesName> otherNames;

  /// Whether any rule in this pack protects it.
  ///
  /// **Anywhere, and it is not a verdict.** The account page is reached from a
  /// search and from a grid, neither of which knows a zone yet; a species
  /// protected in the next ría along is one a reader should see marked before
  /// he measures it. E10's finding is what states the rule with its citation.
  final bool isProtectedAnywhere;

  /// The pack's id.
  int get speciesId => species.id;

  /// The binomial.
  String get scientificName => species.scientificName;

  /// One of `SPEC.md` §7.1's eight groups.
  TaxonGroup get taxonGroup => species.taxonGroup;

  /// Originated SVG line art.
  String get silhouetteAsset => species.silhouetteAsset;

  /// A cleared plate, or `null` — and `null` is the normal case.
  String? get plateAsset => species.plateAsset;
}
