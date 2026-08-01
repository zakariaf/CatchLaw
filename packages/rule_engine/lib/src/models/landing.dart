import 'package:meta/meta.dart';

import 'package:rule_engine/src/models/measurement_method.dart';

/// The individual in the hand: how long it is, and how that was measured.
///
/// Millimetres and `int`, so the comparison against a threshold is integer
/// comparison and no floating-point value reaches a finding.
///
/// Both fields are nullable because both absences are real. A fisher who has
/// identified a fish but not measured it still gets every rule that does not
/// depend on a length — a closed season, a protected listing, a bag limit — and
/// that is the whole point of not requiring a measurement to see an answer.
@immutable
class Landing {
  /// Both arguments are required and both may be null: an unmeasured fish is a
  /// legitimate question, not a missing argument.
  const Landing({required this.lengthMm, required this.method});

  /// The reading in millimetres, or `null` if the fish was not measured.
  final int? lengthMm;

  /// The method the reading was taken by, or `null` if there is no reading.
  ///
  /// `SPEC.md` §4.2: the method comes from the ACTIVE RULE ROW, so a reading
  /// with no method cannot be compared against a threshold at all. A size
  /// finding needs both this and the rule's own method to agree.
  final MeasurementMethod? method;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Landing && other.lengthMm == lengthMm && other.method == method;

  @override
  int get hashCode => Object.hash(lengthMm, method);

  @override
  String toString() => 'Landing($lengthMm mm, $method)';
}
