import 'package:meta/meta.dart';

/// `SPEC.md` §7.1's `zone.water_type` CHECK list.
///
/// [both] is the member that makes a rule apply in salt and fresh water alike,
/// and it is the one an implementation drops by accident — stage 1's filter has
/// to admit it as well as the exact match.
enum WaterType {
  /// Sea water only.
  salt,

  /// Fresh water only.
  fresh,

  /// Either.
  both,
}

/// `SPEC.md` §7.1's `zone.zone_kind` CHECK list.
///
/// [basin] is absent from `catchlaw-rule-engine`'s ladder table and present in
/// both §7.1's CHECK and §7.3's prose ("bank/basin 20"). `SPEC.md` is
/// authoritative for the product, so it is a member here. The specificity
/// integers are E03/T04's, which is the task that publishes the ladder.
enum ZoneKind {
  /// A whole region. Rank 0 — level with a `NULL` zone id, deliberately.
  region(0),

  /// A named subdivision of a region.
  subzone(10),

  /// A fishing bank.
  bank(20),

  /// A basin. `SPEC.md` §7.3 says "bank/basin 20"; it shares the rung.
  basin(20),

  /// A protected reserve.
  reserve(30),

  /// An exclusion zone — the strictest scope there is.
  exclusion(40);

  const ZoneKind(this.specificity);

  /// Where this kind sits on `SPEC.md` §7.3's ladder. Higher wins.
  ///
  /// A CLOSED TABLE, and nothing derives it. `catchlaw-rule-engine` rule 5
  /// names what a depth heuristic produces: `banco-de-cambados` is a bank at
  /// depth 3, and a no-take exclusion drawn INSIDE it is at depth 4 in some
  /// encodings and depth 3 in others, depending on how the path was built. A
  /// specificity computed from path depth ranks the bank above the exclusion
  /// roughly half the time — handing the permissive rule to a fisher standing
  /// exactly where the strict one applies.
  final int specificity;
}

/// A geometry a rule attaches to.
///
/// The polygon itself is not here: the engine takes a materialised ancestry
/// path and E11 is what produces it from a fix. This type carries only what
/// resolution needs — who the parent is, and what kind of zone it is.
@immutable
class Zone {
  /// [parentZoneId] is required but nullable: a root zone must SAY it has no
  /// parent rather than omit the argument.
  const Zone({
    required this.id,
    required this.jurisdictionId,
    required this.parentZoneId,
    required this.code,
    required this.waterType,
    required this.zoneKind,
  });

  /// The `zone.id` a rule's `zone_id` points at.
  final int id;

  /// Which authority published it.
  final int jurisdictionId;

  /// The containing zone, or `null` for a root zone.
  ///
  /// Nullable because §7.1's `parent_zone_id` is: the jurisdiction-level zone
  /// has no parent.
  final int? parentZoneId;

  /// The stable code — `ae-rak`, `es-rias-baixas-cambados`.
  final String code;

  /// Salt, fresh, or both.
  final WaterType waterType;

  /// Which rung of T04's specificity ladder this zone sits on.
  final ZoneKind zoneKind;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Zone &&
          other.id == id &&
          other.jurisdictionId == jurisdictionId &&
          other.parentZoneId == parentZoneId &&
          other.code == code &&
          other.waterType == waterType &&
          other.zoneKind == zoneKind;

  @override
  int get hashCode => Object.hash(id, jurisdictionId, parentZoneId, code, waterType, zoneKind);

  @override
  String toString() => 'Zone($id, $code, $zoneKind)';
}
