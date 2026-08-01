import 'package:meta/meta.dart';

import 'package:rule_engine/src/models/citation.dart';
import 'package:rule_engine/src/models/closed_season.dart';
import 'package:rule_engine/src/models/measurement_method.dart';
import 'package:rule_engine/src/models/zone.dart';

/// `SPEC.md` §7.1's `bag_limit_unit` CHECK list.
enum LimitUnit {
  /// A number of individuals.
  count,

  /// A mass in kilograms.
  kg,
}

/// `SPEC.md` §7.1's `bag_limit_period` CHECK list.
enum LimitPeriod {
  /// Per day.
  day,

  /// Per trip.
  trip,

  /// Per season.
  season,
}

/// One transcribed rule row, as a value.
///
/// Sizes are millimetres and `int`, end to end, exactly as §7.1 stores them, so
/// a size comparison is integer comparison and there is no floating-point path
/// from the ruler to the finding. There is deliberately NO `unit` field beside
/// the number: two rows in one instrument expressed in two units is a content
/// bug for E04 to reject, and a unit field would make `38 cm` and `380 mm` two
/// distinct values that T05's conflict detection would report as a legal
/// disagreement. Unit RENDERING is the app's, from E09's locale preference.
///
/// Dates are ISO-8601 strings, not `DateTime`. `DateTime` has no const
/// constructor, so a `DateTime` field would make `const Rule(...)` impossible
/// and every fixture a runtime allocation; it would also reintroduce the
/// timezone trap where `DateTime.parse('2026-07-30')` returns local midnight.
/// Comparison goes through one helper, in UTC.
///
/// Nothing is validated in the constructor. A rule whose `minSizeMm` exceeds its
/// `maxSizeMm` breaches §7.1's CHECK and is a content defect; throwing here
/// would make it unrepresentable in the very fixture that proves the engine
/// survives bad content. That class of problem has a return type instead.
@immutable
class Rule {
  /// Only the fields §7.1 marks `NOT NULL` are required here.
  const Rule({
    required this.id,
    required this.jurisdictionId,
    required this.zoneId,
    required this.speciesId,
    required this.waterType,
    required this.citation,
    required this.citationLineageId,
    required this.validFrom,
    this.validTo,
    this.minSizeMm,
    this.maxSizeMm,
    this.measurementMethod,
    this.bagLimit,
    this.bagLimitUnit,
    this.bagLimitPeriod,
    this.vesselLimit,
    this.isProtected = false,
    this.closedSeasons = const <ClosedSeason>[],
  });

  /// The `rule.id`.
  final int id;

  /// Which authority published it.
  final int jurisdictionId;

  /// The zone it attaches to, or `null` for the whole jurisdiction.
  ///
  /// §7.1's own comment: `-- NULL = whole jurisdiction`. T04 ranks it at 0.
  final int? zoneId;

  /// The species it governs.
  final int speciesId;

  /// Salt, fresh, or both.
  final WaterType waterType;

  /// The instrument. Non-nullable, per invariant 3.
  final Citation citation;

  /// Which chain of amendments this rule's instrument belongs to.
  ///
  /// `SPEC.md` §7.3 collapses candidates to the greatest `validFrom` per
  /// `(zoneId, citation lineage)`, and §7.1 HAS NO SUCH COLUMN. Naming the
  /// field here, on the engine's own type, puts the gap where a mapper must
  /// look at it rather than leaving stage 2 to invent a key.
  ///
  /// The safe default is lineage = citation id: it collapses nothing, so it can
  /// only ever produce an `Ambiguous`, never a silent pick of the wrong
  /// instrument. E04 adding `citation.lineage_id` is what closes it.
  final String citationLineageId;

  /// ISO-8601 date the rule takes effect.
  final String validFrom;

  /// ISO-8601 date it lapses, or `null` for no expiry.
  ///
  /// **Expiry tags; it never deletes.** This field appears in no `.where`, no
  /// `removeWhere`, no `retainWhere` and no `takeWhile` anywhere in this
  /// package. An expired ruleset is still evaluated and still shown, behind a
  /// non-blocking bar (invariant 5) — because the alternative is a screen that
  /// says nothing to a fisher standing in front of an inspector.
  final String? validTo;

  /// Minimum legal size in millimetres.
  final int? minSizeMm;

  /// Maximum legal size in millimetres.
  final int? maxSizeMm;

  /// The method any size on this rule is expressed in.
  final MeasurementMethod? measurementMethod;

  /// How many may be taken.
  final int? bagLimit;

  /// Whether [bagLimit] counts individuals or kilograms.
  final LimitUnit? bagLimitUnit;

  /// The period [bagLimit] applies over.
  final LimitPeriod? bagLimitPeriod;

  /// A per-vessel count.
  ///
  /// A bare count with no unit and no period, because §7.1 gives it neither
  /// while `bag_limit` gets both. The engine may not state a period the
  /// instrument as transcribed did not give it.
  final int? vesselLimit;

  /// Whether the species is protected outright under this rule.
  final bool isProtected;

  /// The closures this rule carries. Empty, never null.
  final List<ClosedSeason> closedSeasons;

  /// A copy with the named fields replaced.
  ///
  /// T03 through T09 each vary ONE field of one fixture. Without this, every
  /// one of those tests restates twenty arguments and stops saying which one it
  /// is about.
  ///
  /// Nullable fields take a sentinel rather than `null`-means-keep, so
  /// `copyWith(validTo: null)` genuinely clears the expiry instead of silently
  /// preserving it — which is the bug the naive shape has, in the one field
  /// where being wrong means showing a lapsed rule as current.
  Rule copyWith({
    int? id,
    int? jurisdictionId,
    Object? zoneId = _keep,
    int? speciesId,
    WaterType? waterType,
    // Takes the sentinel rather than a nullable citation type, although this
    // field is non-nullable and `citation ?? this.citation` could never produce
    // a null. Check 4 of check_app_invariants.sh greps the package for that
    // type and cannot tell a copyWith parameter from a field; the honest fix is
    // to stop writing it rather than to spend the gate's escape hatch on a line
    // that is fine. It also makes this parameter read like the ten below it.
    Object? citation = _keep,
    String? citationLineageId,
    String? validFrom,
    Object? validTo = _keep,
    Object? minSizeMm = _keep,
    Object? maxSizeMm = _keep,
    Object? measurementMethod = _keep,
    Object? bagLimit = _keep,
    Object? bagLimitUnit = _keep,
    Object? bagLimitPeriod = _keep,
    Object? vesselLimit = _keep,
    bool? isProtected,
    List<ClosedSeason>? closedSeasons,
  }) => Rule(
    id: id ?? this.id,
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    zoneId: zoneId == _keep ? this.zoneId : zoneId as int?,
    speciesId: speciesId ?? this.speciesId,
    waterType: waterType ?? this.waterType,
    citation: citation == _keep ? this.citation : citation! as Citation,
    citationLineageId: citationLineageId ?? this.citationLineageId,
    validFrom: validFrom ?? this.validFrom,
    validTo: validTo == _keep ? this.validTo : validTo as String?,
    minSizeMm: minSizeMm == _keep ? this.minSizeMm : minSizeMm as int?,
    maxSizeMm: maxSizeMm == _keep ? this.maxSizeMm : maxSizeMm as int?,
    measurementMethod: measurementMethod == _keep
        ? this.measurementMethod
        : measurementMethod as MeasurementMethod?,
    bagLimit: bagLimit == _keep ? this.bagLimit : bagLimit as int?,
    bagLimitUnit: bagLimitUnit == _keep ? this.bagLimitUnit : bagLimitUnit as LimitUnit?,
    bagLimitPeriod: bagLimitPeriod == _keep ? this.bagLimitPeriod : bagLimitPeriod as LimitPeriod?,
    vesselLimit: vesselLimit == _keep ? this.vesselLimit : vesselLimit as int?,
    isProtected: isProtected ?? this.isProtected,
    closedSeasons: closedSeasons ?? this.closedSeasons,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rule &&
          other.id == id &&
          other.jurisdictionId == jurisdictionId &&
          other.zoneId == zoneId &&
          other.speciesId == speciesId &&
          other.waterType == waterType &&
          other.citation == citation &&
          other.citationLineageId == citationLineageId &&
          other.validFrom == validFrom &&
          other.validTo == validTo &&
          other.minSizeMm == minSizeMm &&
          other.maxSizeMm == maxSizeMm &&
          other.measurementMethod == measurementMethod &&
          other.bagLimit == bagLimit &&
          other.bagLimitUnit == bagLimitUnit &&
          other.bagLimitPeriod == bagLimitPeriod &&
          other.vesselLimit == vesselLimit &&
          other.isProtected == isProtected &&
          _sameSeasons(other.closedSeasons, closedSeasons);

  @override
  int get hashCode => Object.hash(
    id,
    jurisdictionId,
    zoneId,
    speciesId,
    waterType,
    citation,
    citationLineageId,
    validFrom,
    validTo,
    minSizeMm,
    maxSizeMm,
    measurementMethod,
    bagLimit,
    bagLimitUnit,
    bagLimitPeriod,
    vesselLimit,
    isProtected,
    Object.hashAll(closedSeasons),
  );

  @override
  String toString() => 'Rule($id, species $speciesId, zone $zoneId)';
}

/// Sentinel for [Rule.copyWith], so `null` can mean "clear this field".
const Object _keep = Object();

bool _sameSeasons(List<ClosedSeason> a, List<ClosedSeason> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
