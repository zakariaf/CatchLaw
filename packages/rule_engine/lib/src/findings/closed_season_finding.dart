part of 'finding.dart';

/// A closure, with its window materialised and today's position inside it.
///
/// Integers and ISO dates, never a sentence (D-7). E06 and E10 turn these into
/// *Closed season — 1 March to 30 April. In force today, day 14 of 61.* in six
/// locales, and `catchlaw-verdict-contract` rule 3 is why the two integers are
/// here at all: the numeric margin is mandatory, because without it the app has
/// published its own conclusion instead of quoting a rule.
final class ClosedSeasonFinding extends Finding {
  /// Built by [closedSeasonFinding], which is what computes the window.
  const ClosedSeasonFinding({
    required super.citation,
    required super.isExpired,
    required this.recurrence,
    required this.inForce,
    required this.startsOn,
    required this.endsOn,
    required this.dayOfClosure,
    required this.lengthInDays,
  });

  /// Whether the closure repeats annually or names two dates once.
  final Recurrence recurrence;

  /// Whether the closure is in force on the evaluation date.
  final bool inForce;

  /// The materialised opening date, ISO-8601.
  final String startsOn;

  /// The materialised closing date, ISO-8601, inclusive.
  final String endsOn;

  /// Which day of the window today is, 1-based, or `0` when not in force.
  final int dayOfClosure;

  /// How many days the window runs, both ends inclusive.
  ///
  /// Present even when the closure is not in force: E10 renders a satisfied
  /// closure in the rule table beneath a different headline, and that row states
  /// the window. Non-deciding findings are not discarded.
  final int lengthInDays;

  @override
  FindingKind get kind => FindingKind.closedSeason;

  /// Never [FindingOutcome.indeterminate]: the device has a date, so the answer
  /// always exists.
  @override
  FindingOutcome get outcome => inForce ? FindingOutcome.fails : FindingOutcome.passes;
}

/// Builds a [ClosedSeasonFinding] for [season] on [on].
///
/// The closure is evaluated against the EVALUATION DATE, never against the
/// rule's own `validFrom`/`validTo`. They are different questions: expiry is
/// about the instrument's currency, a closure is about today. A closure whose
/// instrument has lapsed is still evaluated and still tagged, which is why
/// [isExpired] is carried in rather than recomputed.
Result<ClosedSeasonFinding> closedSeasonFinding(
  ClosedSeason season,
  String on, {
  required int ruleId,
  required bool isExpired,
}) {
  final Result<SeasonStatus> status = seasonStatus(season, on, ruleId: ruleId);
  return switch (status) {
    Failure<SeasonStatus>(:final Exception exception, :final StackTrace? stackTrace) =>
      Result<ClosedSeasonFinding>.error(exception, stackTrace),
    Ok<SeasonStatus>(:final SeasonStatus value) => Result<ClosedSeasonFinding>.ok(
      ClosedSeasonFinding(
        citation: season.citation,
        isExpired: isExpired,
        recurrence: season.recurrence,
        inForce: value.inForce,
        startsOn: value.startsOn,
        endsOn: value.endsOn,
        dayOfClosure: value.dayOfClosure,
        lengthInDays: value.lengthInDays,
      ),
    ),
  };
}
