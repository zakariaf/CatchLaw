import 'package:meta/meta.dart';
import 'package:rule_engine/src/models/rule.dart';

/// A rule that survived selection, carrying whether its instrument has lapsed.
///
/// The tag is the whole point. `SPEC.md` §7.3 keeps an expired row in the result
/// set at full strength — its numbers intact, its citation intact — and marks
/// it, so E10 can render a non-blocking ochre bar above an otherwise unchanged
/// verdict. A kept row with no tag would be a silently stale verdict, which is
/// worse than either filtering it or showing it plainly.
@immutable
class Candidate {
  /// Pairs [rule] with the [isExpired] tag computed against the request date.
  const Candidate({required this.rule, required this.isExpired});

  /// The rule itself, unmodified.
  final Rule rule;

  /// Whether `rule.validTo` had passed on the evaluation date.
  ///
  /// The boundary is INCLUSIVE: a rule valid until 30 June is not expired ON
  /// 30 June, because an instrument in force "until 30 June" is in force that
  /// day.
  final bool isExpired;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Candidate && other.rule == rule && other.isExpired == isExpired;

  @override
  int get hashCode => Object.hash(rule, isExpired);

  @override
  String toString() => 'Candidate(${rule.id}, expired: $isExpired)';
}
