// The first Finding, and the base every other one inherits.
//
// The base carries exactly two fields — a required non-nullable Citation and
// isExpired — plus two abstract getters. Putting the citation on the BASE is
// what makes invariant 3 structural: there is no way to write a Finding
// subclass that forgets it, because the superclass constructor demands it.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/fixtures.dart';
import '../../testing/utils/result.dart';

ClosedSeasonFinding _finding({String on = '2026-03-14', bool isExpired = false}) =>
    closedSeasonFinding(
      const ClosedSeason(
        recurrence: Recurrence.annual,
        startMonth: 3,
        startDay: 1,
        endMonth: 4,
        endDay: 30,
        citation: kCitationMd580,
      ),
      on,
      ruleId: 1,
      isExpired: isExpired,
    ).asOk.value;

void main() {
  group('ClosedSeasonFinding', () {
    test('carries the materialised window and both integers', () {
      // Integers and ISO dates, never a sentence. E06 and E10 turn these into
      // "Closed season — 1 March to 30 April. In force today, day 14 of 61."
      // in six locales; there is no String here a translator could be handed.
      final ClosedSeasonFinding f = _finding();
      expect(f.startsOn, '2026-03-01');
      expect(f.endsOn, '2026-04-30');
      expect(f.dayOfClosure, 14);
      expect(f.lengthInDays, 61);
      expect(f.inForce, isTrue);
    });

    test('reports kind closedSeason', () {
      expect(_finding().kind, FindingKind.closedSeason);
    });

    test('fails when the closure is in force', () {
      expect(_finding().outcome, FindingOutcome.fails);
    });

    test('passes when the closure is not in force', () {
      expect(_finding(on: '2026-07-30').outcome, FindingOutcome.passes);
    });

    test('is never indeterminate', () {
      // The device has a date, so the answer always exists. Anything marked
      // indeterminate prints as an open question in the rule table and NEVER as
      // a pass, and a closure is not an open question.
      for (final on in <String>['2026-03-14', '2026-07-30', '2026-04-30', '2026-05-01']) {
        expect(_finding(on: on).outcome, isNot(FindingOutcome.indeterminate));
      }
    });

    test('carries a non-nullable citation from the base', () {
      expect(_finding().citation, kCitationMd580);
    });

    test('carries the isExpired tag through from its candidate', () {
      // A closure whose instrument has lapsed is still evaluated and still
      // tagged — expiry is about the instrument's currency, a closure is about
      // today's date, and they are different questions.
      final ClosedSeasonFinding f = _finding(isExpired: true);
      expect(f.isExpired, isTrue);
      expect(f.inForce, isTrue, reason: 'the closure still evaluates at full strength');
      expect(f.dayOfClosure, 14, reason: 'and its numbers survive intact');
    });

    test('is a Finding', () {
      expect(_finding(), isA<Finding>());
    });
  });

  group('FindingOutcome', () {
    test('exposes passes, fails and indeterminate', () {
      expect(FindingOutcome.values, <FindingOutcome>[
        FindingOutcome.passes,
        FindingOutcome.fails,
        FindingOutcome.indeterminate,
      ]);
    });
  });

  group('FindingKind', () {
    test('exposes the six SPEC 7.3 kinds', () {
      expect(FindingKind.values, <FindingKind>[
        FindingKind.protected,
        FindingKind.closedSeason,
        FindingKind.maxSize,
        FindingKind.minSize,
        FindingKind.bagLimit,
        FindingKind.vesselLimit,
      ]);
    });
  });
}
