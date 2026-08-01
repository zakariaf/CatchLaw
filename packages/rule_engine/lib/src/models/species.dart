import 'package:meta/meta.dart';

/// `SPEC.md` §7.1's `species.taxon_group` CHECK list.
enum TaxonGroup {
  /// Bony fish.
  finfish,

  /// Crabs, shrimp, lobster.
  crustacean,

  /// Clams, mussels, oysters.
  bivalve,

  /// Snails and limpets.
  gastropod,

  /// Squid, cuttlefish, octopus.
  cephalopod,

  /// Sea urchins and sea cucumbers.
  echinoderm,

  /// Sharks, rays and skates.
  elasmobranch,

  /// Anything the seven above do not cover.
  other,
}

/// One species, identified by the binomial the Catalogue of Life carries.
///
/// The vernacular names live elsewhere: this package resolves rules, and the
/// name the fisher reads comes back from the row unmodified (D-7).
@immutable
class Species {
  /// [colId] is optional because not every species has a Catalogue of Life id.
  const Species({
    required this.id,
    required this.scientificName,
    required this.taxonGroup,
    this.colId,
  });

  /// The `species.id` a rule's `species_id` points at.
  final int id;

  /// The binomial — `Epinephelus coioides`.
  final String scientificName;

  /// Which of the eight groups it belongs to.
  final TaxonGroup taxonGroup;

  /// The Catalogue of Life taxon id, where one exists (CC BY 4.0).
  final String? colId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Species &&
          other.id == id &&
          other.scientificName == scientificName &&
          other.taxonGroup == taxonGroup &&
          other.colId == colId;

  @override
  int get hashCode => Object.hash(id, scientificName, taxonGroup, colId);

  @override
  String toString() => 'Species($id, $scientificName)';
}
