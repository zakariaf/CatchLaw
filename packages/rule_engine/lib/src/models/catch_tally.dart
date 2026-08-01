import 'package:meta/meta.dart';

/// What has already been taken, against which a bag or vessel limit is read.
///
/// A value type with fields and no behaviour. E03/T08 adds the period
/// accessors when it has a caller for them; adding them now would be code the
/// analyzer cannot see is dead.
@immutable
class CatchTally {
  /// All four counts are required, because a missing one is not zero — it is a
  /// question nobody asked, and defaulting it to zero would report a limit as
  /// unmet when it may already have been reached.
  const CatchTally({
    required this.perDay,
    required this.perTrip,
    required this.perSeason,
    required this.vesselCount,
  });

  /// Taken so far today.
  final int perDay;

  /// Taken so far on this trip.
  final int perTrip;

  /// Taken so far this season.
  final int perSeason;

  /// Taken so far by this vessel.
  final int vesselCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatchTally &&
          other.perDay == perDay &&
          other.perTrip == perTrip &&
          other.perSeason == perSeason &&
          other.vesselCount == vesselCount;

  @override
  int get hashCode => Object.hash(perDay, perTrip, perSeason, vesselCount);

  @override
  String toString() => 'CatchTally(day $perDay, trip $perTrip, season $perSeason)';
}
