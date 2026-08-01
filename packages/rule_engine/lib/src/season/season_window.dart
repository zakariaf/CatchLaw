import 'package:rule_engine/src/date.dart';
import 'package:rule_engine/src/engine_exception.dart';
import 'package:rule_engine/src/failure.dart';
import 'package:rule_engine/src/models/closed_season.dart';

/// One materialised occurrence of a closure, and where the evaluation date sits
/// inside it.
///
/// A record rather than a class because it has no identity: it is the answer to
/// one question about one date, and nothing holds on to it.
typedef SeasonStatus = ({
  bool inForce,
  String startsOn,
  String endsOn,
  int dayOfClosure,
  int lengthInDays,
});

/// Where [on] falls relative to [season], with the occurrence materialised.
///
/// **The arithmetic is done on materialised dates, never on month-day tuples.**
/// A tuple comparison answers "is it in force" correctly and cannot answer
/// either of the other two questions the product needs:
/// `catchlaw-verdict-contract`'s finding grammar requires *Closed season —
/// 1 March to 30 April. In force today, day 14 of 61*, and its rule 3 makes the
/// numeric margin mandatory rather than decorative. Without it the app has
/// published its own conclusion instead of quoting a rule.
///
/// The payoff is the leap year. A 1 February to 31 March closure is 60 days in
/// 2024 and 59 in 2025, and 1 March is day 30 in one and day 29 in the other. A
/// month-length lookup table gets that wrong once every four years, in one
/// direction, silently. Here the calendar does the work.
///
/// **Every date is UTC**, because [parseIsoDate] returns UTC midnight and
/// `Duration.inDays` truncates. On local-time dates a window crossing a
/// daylight-saving transition is 58.958 days, which truncates to 58 — reporting
/// the closure a day shorter than it is, for half the year, in Spain and Brazil.
/// The Galician *vedas* windows sit across the March transition.
///
/// [ruleId] names the row in any [MalformedSeason] this returns. It is an
/// argument rather than a field of [ClosedSeason] because §7.1 hangs the season
/// off the rule and E03/T01 modelled that as containment, so the season does not
/// know its own parent — and a content defect that cannot name a row is a defect
/// E04's build assertions cannot report.
Result<SeasonStatus> seasonStatus(ClosedSeason season, String on, {required int ruleId}) {
  final DateTime date = parseIsoDate(on);

  // Branch on `recurrence`, never on which fields happen to be null. The two
  // kinds use different columns, which is why §7.1 makes all six nullable.
  switch (season.recurrence) {
    case Recurrence.fixed:
      return _fixed(season, date, ruleId);
    case Recurrence.annual:
      return _annual(season, date, ruleId);
  }
}

Result<SeasonStatus> _fixed(ClosedSeason season, DateTime on, int ruleId) {
  final String? start = season.startDate;
  final String? end = season.endDate;
  if (start == null || end == null) {
    return Result<SeasonStatus>.error(
      MalformedSeason(ruleId: ruleId, field: start == null ? 'startDate' : 'endDate'),
    );
  }
  final DateTime from = parseIsoDate(start);
  final DateTime to = parseIsoDate(end);
  if (to.isBefore(from)) {
    return Result<SeasonStatus>.error(
      MalformedSeason(ruleId: ruleId, field: 'endDate before startDate'),
    );
  }
  return Result<SeasonStatus>.ok(_measure(from, to, on));
}

Result<SeasonStatus> _annual(ClosedSeason season, DateTime on, int ruleId) {
  final int? sm = season.startMonth;
  final int? sd = season.startDay;
  final int? em = season.endMonth;
  final int? ed = season.endDay;
  if (sm == null || sd == null || em == null || ed == null) {
    final missing = sm == null
        ? 'startMonth'
        : sd == null
        ? 'startDay'
        : em == null
        ? 'endMonth'
        : 'endDay';
    return Result<SeasonStatus>.error(MalformedSeason(ruleId: ruleId, field: missing));
  }

  // 29 February as a BOUND of an annual recurrence is undefined: three years in
  // four there is no such date, and the engine would have to invent 28 February
  // or 1 March — either of which adds or removes a day of closure that no
  // instrument declared. §7.3 and §7.1 are silent and no bundled instrument is
  // known to do it, so it is a content defect surfaced at authoring time rather
  // than at sea. INSIDE a window the 29th is handled by construction.
  if ((sm == 2 && sd == 29) || (em == 2 && ed == 29)) {
    return Result<SeasonStatus>.error(
      MalformedSeason(ruleId: ruleId, field: 'annual bound on 29 February'),
    );
  }

  // The wrap is a branch on the BOUNDS and not on the date, so the same closure
  // behaves identically on 15 December and 15 January.
  final bool wraps = sm > em || (sm == em && sd > ed);
  final int year = on.year;

  if (!wraps) {
    final from = DateTime.utc(year, sm, sd);
    final to = DateTime.utc(year, em, ed);
    // After this year's window closes, the next occurrence is next year's.
    if (on.isAfter(to)) {
      return Result<SeasonStatus>.ok(
        _measure(DateTime.utc(year + 1, sm, sd), DateTime.utc(year + 1, em, ed), on),
      );
    }
    return Result<SeasonStatus>.ok(_measure(from, to, on));
  }

  // Wrapping, three cases:
  //   on or after the start month-day  -> starts this year, ends next
  //   on or before the end month-day   -> started last year, ends this
  //   between the two                  -> the NEXT occurrence, dayOfClosure 0
  final thisYearStart = DateTime.utc(year, sm, sd);
  final thisYearEnd = DateTime.utc(year, em, ed);
  if (!on.isBefore(thisYearStart)) {
    return Result<SeasonStatus>.ok(_measure(thisYearStart, DateTime.utc(year + 1, em, ed), on));
  }
  if (!on.isAfter(thisYearEnd)) {
    return Result<SeasonStatus>.ok(_measure(DateTime.utc(year - 1, sm, sd), thisYearEnd, on));
  }
  return Result<SeasonStatus>.ok(_measure(thisYearStart, DateTime.utc(year + 1, em, ed), on));
}

/// Derives every number from two concrete dates.
///
/// Both ends inclusive: 1 March to 30 April is 31 + 30 = 61, and 1 March is
/// day 1. `lengthInDays` is returned even when the closure is not in force,
/// because E10 renders a satisfied closure row in the rule table beneath a
/// different headline and that row states the window — non-deciding findings
/// are not discarded.
SeasonStatus _measure(DateTime from, DateTime to, DateTime on) {
  final bool inForce = !on.isBefore(from) && !on.isAfter(to);
  return (
    inForce: inForce,
    startsOn: _iso(from),
    endsOn: _iso(to),
    dayOfClosure: inForce ? on.difference(from).inDays + 1 : 0,
    lengthInDays: to.difference(from).inDays + 1,
  );
}

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
