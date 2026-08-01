import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show TaxonGroup, ZoneKind;

/// A species, as the app shows it.
///
/// The engine already owns [TaxonGroup]; this adds the parts it has no opinion
/// about — the assets and the names — because D-7 keeps every user-visible
/// sentence out of the engine and a silhouette path is not a rule.
@immutable
class Species {
  /// A species and its assets.
  const Species({
    required this.id,
    required this.scientificName,
    required this.familyId,
    required this.taxonGroup,
    required this.silhouetteAsset,
    this.colId,
    this.plateAsset,
  });

  /// The pack's id for it.
  final int id;

  /// The binomial.
  final String scientificName;

  /// Its family.
  final int familyId;

  /// One of `SPEC.md` §7.1's eight groups.
  final TaxonGroup taxonGroup;

  /// Originated SVG line art.
  final String silhouetteAsset;

  /// Catalogue of Life taxon id, attributed CC BY 4.0 in S17.
  final String? colId;

  /// A cleared plate, or `null` — and `null` is the normal case.
  final String? plateAsset;
}

/// One vernacular name in one locale.
@immutable
class SpeciesName {
  /// A name in [locale].
  const SpeciesName({
    required this.speciesId,
    required this.locale,
    required this.name,
    required this.gender,
    required this.isPrimary,
    this.regionHint,
  });

  /// The species it names.
  final int speciesId;

  /// One of D-3's six.
  final String locale;

  /// The name as the instrument writes it.
  final String name;

  /// Grammatical gender. [NameGender.none] is legal only in `en`.
  final NameGender gender;

  /// The one name S2 prints.
  final bool isPrimary;

  /// Where this name is the one people use.
  final String? regionHint;
}

/// A place a rule attaches to.
@immutable
class Zone {
  /// A zone and its bounding box.
  const Zone({
    required this.id,
    required this.jurisdictionId,
    required this.code,
    required this.nameKey,
    required this.waterType,
    required this.zoneKind,
    this.parentZoneId,
    this.minLat,
    this.minLon,
    this.maxLat,
    this.maxLon,
  });

  /// The pack's id.
  final int id;

  /// The authority it belongs to.
  final int jurisdictionId;

  /// The zone it nests inside.
  final int? parentZoneId;

  /// Unique within the jurisdiction.
  final String code;

  /// Its localised name, resolved through `content_string`.
  final String nameKey;

  /// Salt, fresh or both.
  final WaterKind waterType;

  /// The specificity ladder rung, which the engine already ranks.
  final ZoneKind zoneKind;

  /// Bounding box, the prefilter E11 runs behind.
  final double? minLat;

  /// Bounding box.
  final double? minLon;

  /// Bounding box.
  final double? maxLat;

  /// Bounding box.
  final double? maxLon;

  /// Whether this zone has a polygon at all.
  ///
  /// Where no coordinate list is printed in the instrument we do not invent
  /// boundaries, so a zone with no box is a zone S9 offers without a map.
  bool get hasBoundingBox => minLat != null && maxLat != null;
}
