import 'package:meta/meta.dart';

/// One authority that publishes rules, and what it publishes them about.
///
/// The **region** rung of `SPEC.md` §4.4's country → region → sub-zone ladder.
/// §7.1 gives no `country` table, so a country is this row's [countryIso2]
/// grouped — which is why the picker reads two tables and not three.
@immutable
class Jurisdiction {
  /// One `jurisdiction` row.
  const Jurisdiction({
    required this.id,
    required this.code,
    required this.countryIso2,
    required this.nameKey,
    required this.authorityKey,
    required this.defaultLocale,
    required this.hasSaltwater,
    required this.hasFreshwater,
    required this.hasZonePolygons,
    required this.contentVersion,
    required this.checkedOn,
    this.validUntil,
  });

  /// The pack's id.
  final int id;

  /// `ES-GA`, `AE-RK`, `BR-SP`.
  final String code;

  /// The country it sits in — the level above it in the picker.
  final String countryIso2;

  /// Its localised name, through `content_string`.
  final String nameKey;

  /// The authority named in the disclaimer, through `content_string`.
  final String authorityKey;

  /// The language this authority publishes in — §9.2 step 2.
  final String defaultLocale;

  /// Whether it publishes sea rules.
  final bool hasSaltwater;

  /// Whether it publishes inland-water rules.
  ///
  /// **Both flags, not one enum.** A jurisdiction with only one of them offers
  /// the fisher no choice to make, and a toggle with one option is a control
  /// that teaches him the app is unfinished.
  final bool hasFreshwater;

  /// Whether its zones carry coordinate rings.
  ///
  /// `false` for every jurisdiction shipped today. Where no coordinate list is
  /// printed, rules apply jurisdiction-wide and the app invents no boundary
  /// (`SPEC.md` §8) — the sub-zone level is simply not offered.
  final bool hasZonePolygons;

  /// The pack version this row came from.
  final String contentVersion;

  /// When a human last verified this jurisdiction's transcription, ISO-8601.
  final String checkedOn;

  /// When the pack states its rules stop being current, or `null`.
  ///
  /// Past does not mean withheld: an expired ruleset is still evaluated and
  /// still shown, behind the ochre bar.
  final String? validUntil;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Jurisdiction && other.id == id && other.code == code;

  @override
  int get hashCode => Object.hash(id, code);
}
