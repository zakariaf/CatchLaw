// Fixed closures: two absolute dates, no wrapping, no recurrence.
//
// T06 branches on `recurrence` and NEVER on which fields happen to be null.
// That is what keeps a fixed window with a coincidentally-populated month
// column from being read as an annual one.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/fixtures.dart';
import '../../testing/utils/result.dart';

ClosedSeason _fixed(String start, String end) => ClosedSeason(
  recurrence: Recurrence.fixed,
  startDate: start,
  endDate: end,
  citation: kCitationMd580,
);

SeasonStatus _status(ClosedSeason s, String on) => seasonStatus(s, on, ruleId: 1).asOk.value;

void main() {
  group('seasonStatus fixed', () {
    test('reports in force on a date inside the window', () {
      expect(_status(_fixed('2026-03-01', '2026-04-30'), '2026-03-14').inForce, isTrue);
    });

    test('reports in force on both boundary days', () {
      final ClosedSeason s = _fixed('2026-03-01', '2026-04-30');
      expect(_status(s, '2026-03-01').inForce, isTrue);
      expect(_status(s, '2026-04-30').inForce, isTrue);
    });

    test('reports not in force before the window opens', () {
      expect(_status(_fixed('2026-03-01', '2026-04-30'), '2026-02-28').inForce, isFalse);
    });

    test('reports not in force after the window closes', () {
      // A fixed window does not recur, so a date after it is simply outside —
      // there is no next occurrence to materialise.
      expect(_status(_fixed('2026-03-01', '2026-04-30'), '2026-05-01').inForce, isFalse);
    });

    test('counts the window inclusively', () {
      expect(_status(_fixed('2026-03-01', '2026-04-30'), '2026-03-14').lengthInDays, 61);
    });

    test('counts the day of closure from the start date', () {
      expect(_status(_fixed('2026-03-01', '2026-04-30'), '2026-03-14').dayOfClosure, 14);
    });

    test('reports day 0 outside the window', () {
      expect(_status(_fixed('2026-03-01', '2026-04-30'), '2026-05-01').dayOfClosure, 0);
    });

    test('returns the window unchanged as ISO dates', () {
      final SeasonStatus s = _status(_fixed('2026-03-01', '2026-04-30'), '2026-03-14');
      expect(s.startsOn, '2026-03-01');
      expect(s.endsOn, '2026-04-30');
    });

    test('accepts 29 February as a bound', () {
      // In a FIXED window it is an ordinary date: the year is named, so it
      // either exists or the mapper handed us a date that does not parse.
      final SeasonStatus s = _status(_fixed('2024-02-01', '2024-02-29'), '2024-02-29');
      expect(s.inForce, isTrue);
      expect(s.lengthInDays, 29);
    });

    test('spans a year boundary without wrapping logic', () {
      // A fixed window carries both years explicitly, so December to February
      // needs no wrap branch at all.
      final SeasonStatus s = _status(_fixed('2026-12-01', '2027-02-28'), '2027-01-15');
      expect(s.inForce, isTrue);
      expect(s.lengthInDays, 90);
    });

    test('returns a Failure when a fixed window has a null date', () {
      final Result<SeasonStatus> r = seasonStatus(
        const ClosedSeason(
          recurrence: Recurrence.fixed,
          startDate: '2026-03-01',
          endDate: null,
          citation: kCitationMd580,
        ),
        '2026-03-14',
        ruleId: 93,
      );
      expect(r.asFailure.exception, isA<MalformedSeason>());
      expect((r.asFailure.exception as MalformedSeason).ruleId, 93);
    });

    test('returns a Failure when a fixed window ends before it starts', () {
      final Result<SeasonStatus> r = seasonStatus(
        _fixed('2026-04-30', '2026-03-01'),
        '2026-03-14',
        ruleId: 94,
      );
      expect(r.asFailure.exception, isA<MalformedSeason>());
    });
  });
}
