import 'package:meta/meta.dart';
import 'package:rule_engine/src/models/rule.dart';

/// What has already been recorded, against which a bag or vessel limit is read.
///
/// Every field is NULLABLE, and null does not mean zero. `SPEC.md` §4.5 makes
/// the catch log a feature the fisher chooses to use, so an absent count is a
/// question nobody asked rather than an answer of none — and a limit compared
/// against an assumed zero passes for a fisher who has taken forty fish and
/// never opened the log.
///
/// Mass is carried in GRAMS as an `int`. `bag_limit` is an `INTEGER` and its
/// unit may be `kg`, so the instrument's number is whole kilograms; keeping the
/// tally in integer grams means the comparison never touches a `double`.
/// Kilograms as floating point would put `0.1 + 0.2 == 0.30000000000000004` on
/// the path between a fisher's eighth fish and a fine, and it would surface only
/// at the boundary, which is the only place anybody looks.
@immutable
class CatchTally {
  /// Every count is optional: an absent one is unrecorded, never zero.
  const CatchTally({
    this.countPerDay,
    this.countPerTrip,
    this.countPerSeason,
    this.gramsPerDay,
    this.gramsPerTrip,
    this.gramsPerSeason,
    this.vesselCount,
  });

  /// Individuals recorded today.
  final int? countPerDay;

  /// Individuals recorded on this trip.
  final int? countPerTrip;

  /// Individuals recorded this season.
  final int? countPerSeason;

  /// Grams recorded today.
  final int? gramsPerDay;

  /// Grams recorded on this trip.
  final int? gramsPerTrip;

  /// Grams recorded this season.
  final int? gramsPerSeason;

  /// Individuals recorded against this vessel.
  ///
  /// Its own field rather than the day count, because they are different
  /// numbers and `SPEC.md` §7.2 does not currently distinguish them either.
  /// Keeping them apart means the engine never silently equates one fisher with
  /// one hull while the schema question is open (epic risk 2).
  final int? vesselCount;

  /// Individuals recorded over [period], or `null` if none were.
  int? countFor(LimitPeriod period) => switch (period) {
    LimitPeriod.day => countPerDay,
    LimitPeriod.trip => countPerTrip,
    LimitPeriod.season => countPerSeason,
  };

  /// Grams recorded over [period], or `null` if none were.
  int? gramsFor(LimitPeriod period) => switch (period) {
    LimitPeriod.day => gramsPerDay,
    LimitPeriod.trip => gramsPerTrip,
    LimitPeriod.season => gramsPerSeason,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatchTally &&
          other.countPerDay == countPerDay &&
          other.countPerTrip == countPerTrip &&
          other.countPerSeason == countPerSeason &&
          other.gramsPerDay == gramsPerDay &&
          other.gramsPerTrip == gramsPerTrip &&
          other.gramsPerSeason == gramsPerSeason &&
          other.vesselCount == vesselCount;

  @override
  int get hashCode => Object.hash(
    countPerDay,
    countPerTrip,
    countPerSeason,
    gramsPerDay,
    gramsPerTrip,
    gramsPerSeason,
    vesselCount,
  );

  @override
  String toString() => 'CatchTally(day $countPerDay, trip $countPerTrip, season $countPerSeason)';
}
