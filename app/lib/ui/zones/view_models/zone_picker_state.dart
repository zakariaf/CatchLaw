import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:rule_engine/rule_engine.dart' show ZoneKind;

/// What S9 has to draw: three levels, and how far down them the fisher is.
///
/// **Three levels read from two tables.** `SPEC.md` §7.1 has no `country` table,
/// so a country is `jurisdiction.country_iso2` grouped, the region is the
/// jurisdiction row itself, and the sub-zone is its `zone` rows.
@immutable
class ZonePickerState {
  /// One frame of the picker.
  const ZonePickerState({
    required this.all,
    required this.zonesOfSelected,
    this.selectedCountry,
    this.selectedJurisdictionCode,
    this.selectedZoneCode,
    this.water = WaterKind.salt,
    this.authorityName,
  });

  /// Every jurisdiction the pack carries.
  final List<Jurisdiction> all;

  /// The zones of [selectedJurisdictionCode], or empty.
  final List<Zone> zonesOfSelected;

  /// Which country, or `null` before the first tap.
  final String? selectedCountry;

  /// Which jurisdiction.
  final String? selectedJurisdictionCode;

  /// Which sub-zone, where the pack offers any.
  final String? selectedZoneCode;

  /// Salt or fresh, where the jurisdiction publishes both.
  final WaterKind water;

  /// The selected authority's own name, resolved through `content_string`.
  ///
  /// Needed for one sentence only — the notice that says why there is no
  /// sub-zone level — and that sentence names the AUTHORITY on purpose: it
  /// states what a government publishes, not what this app could not load.
  final String? authorityName;

  /// The countries, de-duplicated and ordered.
  List<String> get countries =>
      (all.map((Jurisdiction j) => j.countryIso2).toSet().toList()..sort());

  /// The jurisdictions inside [selectedCountry].
  List<Jurisdiction> get jurisdictions => <Jurisdiction>[
    for (final Jurisdiction j in all)
      if (j.countryIso2 == selectedCountry) j,
  ];

  /// The selected jurisdiction, or `null`.
  Jurisdiction? get jurisdiction {
    for (final Jurisdiction j in all) {
      if (j.code == selectedJurisdictionCode) return j;
    }
    return null;
  }

  /// Whether a sub-zone level is offered at all.
  ///
  /// **Only where the pack printed coordinates.** `SPEC.md` §8: where no
  /// coordinate list is published, rules apply jurisdiction-wide and the app
  /// invents no boundary — so offering a sub-zone would offer a distinction the
  /// instrument does not make, and every rule would then be attached to a line
  /// somebody in this repository drew.
  bool get offersSubZone => (jurisdiction?.hasZonePolygons ?? false) && _subdivisions.isNotEmpty;

  /// The sub-zones the fisher may pick from.
  ///
  /// **Empty when the level is not offered, rather than merely unrendered.** A
  /// caller cannot show a list the pack does not support, because there is no
  /// list to show — which is a stronger guarantee than every call site
  /// remembering to check [offersSubZone] first.
  List<Zone> get subZones => offersSubZone ? _subdivisions : const <Zone>[];

  /// The jurisdiction-wide zone, where the pack carries one.
  ///
  /// What a zero-polygon jurisdiction stores as its active zone: the rules
  /// apply across the whole jurisdiction, and the region rung is what the
  /// engine already ranks level with a `NULL` zone id.
  Zone? get regionZone {
    for (final Zone z in zonesOfSelected) {
      if (z.zoneKind == ZoneKind.region) return z;
    }
    return null;
  }

  List<Zone> get _subdivisions => <Zone>[
    for (final Zone z in zonesOfSelected)
      if (z.zoneKind != ZoneKind.region) z,
  ];

  /// Whether the fisher is offered a choice of water.
  ///
  /// Only when the authority publishes both. A toggle with one option is a
  /// control that teaches him the app is unfinished.
  bool get offersWaterChoice =>
      (jurisdiction?.hasSaltwater ?? false) && (jurisdiction?.hasFreshwater ?? false);

  /// Whether there is enough here to confirm.
  bool get isComplete => selectedJurisdictionCode != null;

  /// This frame with the given fields replaced.
  ZonePickerState copyWith({
    List<Zone>? zonesOfSelected,
    String? selectedCountry,
    String? selectedJurisdictionCode,
    String? selectedZoneCode,
    WaterKind? water,
    String? authorityName,
    bool clearJurisdiction = false,
    bool clearZone = false,
  }) => ZonePickerState(
    all: all,
    zonesOfSelected: zonesOfSelected ?? this.zonesOfSelected,
    selectedCountry: selectedCountry ?? this.selectedCountry,
    selectedJurisdictionCode: clearJurisdiction
        ? null
        : selectedJurisdictionCode ?? this.selectedJurisdictionCode,
    selectedZoneCode: clearZone ? null : selectedZoneCode ?? this.selectedZoneCode,
    water: water ?? this.water,
    authorityName: clearJurisdiction ? null : authorityName ?? this.authorityName,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZonePickerState &&
          listEquals(other.all, all) &&
          listEquals(other.zonesOfSelected, zonesOfSelected) &&
          other.selectedCountry == selectedCountry &&
          other.selectedJurisdictionCode == selectedJurisdictionCode &&
          other.selectedZoneCode == selectedZoneCode &&
          other.water == water &&
          other.authorityName == authorityName;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(all),
    Object.hashAll(zonesOfSelected),
    selectedCountry,
    selectedJurisdictionCode,
    selectedZoneCode,
    water,
    authorityName,
  );
}
