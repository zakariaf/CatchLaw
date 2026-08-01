// Annual closures: materialised occurrences, wrap-around, and leap years.
//
// The naive implementation compares (month, day) tuples. It answers "is it in
// force" correctly and cannot answer either of the other two questions the
// product needs: catchlaw-verdict-contract's finding grammar requires
// "Closed season — 1 March to 30 April. In force today, day 14 of 61.", and its
// rule 3 makes the numeric margin mandatory rather than decorative — without it
// the app has published its own conclusion instead of quoting a rule.
//
// So the occurrence containing (or next following) `on` is materialised into two
// concrete dates and everything is derived from them. The payoff is the leap
// year: a 1 Feb to 31 Mar closure is 60 days in 2024 and 59 in 2025, and a
// month-length lookup table gets that wrong once every four years, in one
// direction, silently.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/fixtures.dart';
import '../../testing/utils/result.dart';

ClosedSeason _annual(int sm, int sd, int em, int ed) => ClosedSeason(
  recurrence: Recurrence.annual,
  startMonth: sm,
  startDay: sd,
  endMonth: em,
  endDay: ed,
  citation: kCitationMd580,
);

SeasonStatus _status(ClosedSeason s, String on) => seasonStatus(s, on, ruleId: 1).asOk.value;

void main() {
  group('seasonStatus annual', () {
    test('reports in force on a date inside the window', () {
      expect(_status(_annual(3, 1, 4, 30), '2026-03-14').inForce, isTrue);
    });

    test('reports not in force on a date outside the window', () {
      expect(_status(_annual(3, 1, 4, 30), '2026-07-30').inForce, isFalse);
    });

    test('reports in force on the first day of the window', () {
      // Inclusive both ends: a closure that opens on 1 March is closed on
      // 1 March.
      expect(_status(_annual(3, 1, 4, 30), '2026-03-01').inForce, isTrue);
    });

    test('reports in force on the last day of the window', () {
      expect(_status(_annual(3, 1, 4, 30), '2026-04-30').inForce, isTrue);
    });

    test('reports not in force on the day after the window closes', () {
      expect(_status(_annual(3, 1, 4, 30), '2026-05-01').inForce, isFalse);
    });

    test('counts 1 March to 30 April as 61 days', () {
      // 31 + 30. The number in catchlaw-verdict-contract's own example sentence.
      expect(_status(_annual(3, 1, 4, 30), '2026-03-14').lengthInDays, 61);
    });

    test('counts 14 March as day 14 of the window', () {
      expect(_status(_annual(3, 1, 4, 30), '2026-03-14').dayOfClosure, 14);
    });

    test('reports day 1 on the opening day', () {
      expect(_status(_annual(3, 1, 4, 30), '2026-03-01').dayOfClosure, 1);
    });

    test('reports day 0 when the closure is not in force', () {
      expect(_status(_annual(3, 1, 4, 30), '2026-07-30').dayOfClosure, 0);
    });

    test('counts 1 February to 31 March as 60 days in a leap year', () {
      // 29 + 31. THE LEAP-YEAR PAYOFF: a month-length lookup table says 59.
      expect(_status(_annual(2, 1, 3, 31), '2024-03-01').lengthInDays, 60);
    });

    test('counts 1 February to 31 March as 59 days in a common year', () {
      // 28 + 31, the same window one year later.
      expect(_status(_annual(2, 1, 3, 31), '2025-03-01').lengthInDays, 59);
    });

    test('counts 1 March as day 30 of a February window in a leap year', () {
      expect(_status(_annual(2, 1, 3, 31), '2024-03-01').dayOfClosure, 30);
    });

    test('counts 1 March as day 29 of a February window in a common year', () {
      // One day earlier in the window than the leap year, because February was
      // one day shorter. The calendar did the arithmetic, not a table.
      expect(_status(_annual(2, 1, 3, 31), '2025-03-01').dayOfClosure, 29);
    });

    test('materialises the window as ISO dates', () {
      final SeasonStatus s = _status(_annual(3, 1, 4, 30), '2026-03-14');
      expect(s.startsOn, '2026-03-01');
      expect(s.endsOn, '2026-04-30');
    });

    test('reports in force in December for a window wrapping the year end', () {
      // 1 Nov to 28 Feb. The wrap is a branch on the BOUNDS, not on the date:
      // the same closure must behave identically on 15 December and 15 January.
      expect(_status(_annual(11, 1, 2, 28), '2026-12-15').inForce, isTrue);
    });

    test('reports in force in January for a window wrapping the year end', () {
      expect(_status(_annual(11, 1, 2, 28), '2027-01-15').inForce, isTrue);
    });

    test('reports not in force in June for a window wrapping the year end', () {
      expect(_status(_annual(11, 1, 2, 28), '2026-06-15').inForce, isFalse);
    });

    test('materialises a wrapping window that started last year', () {
      // On 15 January the occurrence began the PREVIOUS November.
      final SeasonStatus s = _status(_annual(11, 1, 2, 28), '2027-01-15');
      expect(s.startsOn, '2026-11-01');
      expect(s.endsOn, '2027-02-28');
    });

    test('materialises a wrapping window that starts this year', () {
      final SeasonStatus s = _status(_annual(11, 1, 2, 28), '2026-12-15');
      expect(s.startsOn, '2026-11-01');
      expect(s.endsOn, '2027-02-28');
    });

    test('materialises the next occurrence when between two wrapping windows', () {
      // The third case, and the reason lengthInDays is returned even when the
      // closure is not in force: E10 renders a satisfied closure row in the
      // rule table beneath a different headline, and that row states the window.
      final SeasonStatus s = _status(_annual(11, 1, 2, 28), '2026-06-15');
      expect(s.startsOn, '2026-11-01');
      expect(s.endsOn, '2027-02-28');
      expect(s.dayOfClosure, 0);
      expect(s.lengthInDays, 120);
    });

    test('counts a wrapping window across a leap February', () {
      // 1 Nov 2027 to 28 Feb 2028: 30 + 31 + 31 + 28 = 120. The February bound
      // is the 28th, so the leap day falls outside it.
      expect(_status(_annual(11, 1, 2, 28), '2027-12-15').lengthInDays, 120);
    });

    test('returns a Failure when an annual window has a null bound', () {
      // The two recurrence kinds use different columns, so §7.1 makes all six
      // nullable. A row claiming `annual` with no start month has not said what
      // it claims to say.
      final Result<SeasonStatus> r = seasonStatus(
        const ClosedSeason(
          recurrence: Recurrence.annual,
          startMonth: null,
          startDay: 1,
          endMonth: 4,
          endDay: 30,
          citation: kCitationMd580,
        ),
        '2026-03-14',
        ruleId: 91,
      );
      expect(r.asFailure.exception, isA<MalformedSeason>());
      expect((r.asFailure.exception as MalformedSeason).ruleId, 91);
    });

    test('returns a Failure when an annual window is bounded on 29 February', () {
      // Three years in four there is no such date, and the engine would have to
      // invent 28 February or 1 March — either of which adds or removes a day
      // of closure no instrument declared. SPEC.md §7.3 and §7.1 are silent and
      // no bundled instrument is known to do it, so it is a content defect that
      // E04's build assertions surface at authoring time rather than at sea.
      final Result<SeasonStatus> r = seasonStatus(_annual(2, 1, 2, 29), '2024-02-15', ruleId: 92);
      expect(r.asFailure.exception, isA<MalformedSeason>());
      expect((r.asFailure.exception as MalformedSeason).field, contains('29'));
    });

    test('accepts 29 February INSIDE a window', () {
      // Handled by construction: 1 February to 31 March in 2024 contains it,
      // and the materialised arithmetic counts it.
      final SeasonStatus s = _status(_annual(2, 1, 3, 31), '2024-02-29');
      expect(s.inForce, isTrue);
      expect(s.dayOfClosure, 29);
    });
  });
}
