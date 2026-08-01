import 'package:meta/meta.dart';

import 'package:rule_engine/src/models/citation.dart';

/// Whether a closure repeats every year or names two calendar dates once.
///
/// The two kinds use different columns, which is why `SPEC.md` §7.1 makes all
/// six bound columns nullable. E03/T06 branches on THIS, never on which fields
/// happen to be null.
enum Recurrence {
  /// Repeats every year between a month/day pair. May wrap the year end.
  annual,

  /// A single window between two ISO-8601 dates.
  fixed,
}

/// A period during which a rule's species may not be taken.
///
/// A season belongs to a rule: §7.1 hangs `closed_season` off `rule_id` with
/// `ON DELETE CASCADE`, so a season with no rule is not representable in the
/// database and is not representable here either. It is a field of [Rule]
/// rather than a free-standing list, so nothing can attribute a closure to a
/// rule that did not carry it and cite the wrong instrument.
@immutable
class ClosedSeason {
  /// The bound fields a caller supplies depend on [recurrence], not the other
  /// way round.
  const ClosedSeason({
    required this.recurrence,
    required this.citation,
    this.startMonth,
    this.startDay,
    this.endMonth,
    this.endDay,
    this.startDate,
    this.endDate,
  });

  /// Annual or fixed. The discriminator, and the only thing T06 switches on.
  final Recurrence recurrence;

  /// The instrument this closure rests on.
  ///
  /// NON-NULLABLE, although `SPEC.md` §7.1's `closed_season.citation_id` is
  /// nullable while `rule.citation_id` is `NOT NULL`. Invariant 3 wins on the
  /// engine side, and the resolution is not an escape hatch: a `closed_season`
  /// row is a child of a `rule`, so when the season names no instrument of its
  /// own the instrument IS its parent rule's — a real, present, cited row.
  ///
  /// E05's mapper performs that substitution once, in the layer that reads the
  /// schema, and the engine never sees the null. Written here so the mapper's
  /// author finds the reason rather than only the rule.
  final Citation citation;

  /// Month 1-12 the closure opens on, when [recurrence] is [Recurrence.annual].
  final int? startMonth;

  /// Day of month the closure opens on, when [recurrence] is annual.
  final int? startDay;

  /// Month 1-12 the closure closes on, when [recurrence] is annual.
  final int? endMonth;

  /// Day of month the closure closes on, when [recurrence] is annual.
  final int? endDay;

  /// ISO-8601 date the closure opens on, when [recurrence] is [Recurrence.fixed].
  final String? startDate;

  /// ISO-8601 date the closure closes on, when [recurrence] is fixed.
  final String? endDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClosedSeason &&
          other.recurrence == recurrence &&
          other.citation == citation &&
          other.startMonth == startMonth &&
          other.startDay == startDay &&
          other.endMonth == endMonth &&
          other.endDay == endDay &&
          other.startDate == startDate &&
          other.endDate == endDate;

  @override
  int get hashCode =>
      Object.hash(recurrence, citation, startMonth, startDay, endMonth, endDay, startDate, endDate);

  @override
  String toString() => 'ClosedSeason($recurrence)';
}
