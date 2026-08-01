// Bag and vessel limits. The tally is an INPUT, its absence is indeterminate,
// mass is integer grams, and the period comes from the rule.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/fixtures.dart';
import '../../testing/utils/result.dart';

Rule _bag(int limit, {LimitUnit unit = LimitUnit.count, LimitPeriod? period = LimitPeriod.day}) =>
    kRuleHamourMinSize.copyWith(
      minSizeMm: null,
      measurementMethod: null,
      bagLimit: limit,
      bagLimitUnit: unit,
      bagLimitPeriod: period,
    );

Rule _vessel(int limit) =>
    kRuleHamourMinSize.copyWith(minSizeMm: null, measurementMethod: null, vesselLimit: limit);

CatchTally _tally({int? day, int? trip, int? season, int? gramsDay, int? vessel}) => CatchTally(
  countPerDay: day,
  countPerTrip: trip,
  countPerSeason: season,
  gramsPerDay: gramsDay,
  vesselCount: vessel,
);

List<Finding> _findings(Rule rule, CatchTally? tally) =>
    limitFindings(rule, tally, isExpired: false).asOk.value;

BagLimitFinding _bagFinding(Rule rule, CatchTally? tally) =>
    _findings(rule, tally).whereType<BagLimitFinding>().single;

void main() {
  group('CatchTally', () {
    test('countFor reads the period the rule names', () {
      final CatchTally t = _tally(day: 3, trip: 9, season: 40);
      expect(t.countFor(LimitPeriod.day), 3);
      expect(t.countFor(LimitPeriod.trip), 9);
      expect(t.countFor(LimitPeriod.season), 40);
    });

    test('countFor returns null for a period nothing was recorded against', () {
      expect(_tally(day: 3).countFor(LimitPeriod.season), isNull);
    });

    test('gramsFor reads the period the rule names', () {
      expect(_tally(gramsDay: 4500).gramsFor(LimitPeriod.day), 4500);
    });
  });

  group('BagLimitFinding', () {
    test('passes when fewer than the limit have been recorded', () {
      expect(_bagFinding(_bag(6), _tally(day: 3)).outcome, FindingOutcome.passes);
    });

    test('passes when exactly the limit has been recorded', () {
      // bag_limit = 6 means SIX ARE PERMITTED. The margin sentence in rule 3
      // reads "Above the daily bag — 9 recorded, limit 6", which is only
      // correct under this reading.
      expect(_bagFinding(_bag(6), _tally(day: 6)).outcome, FindingOutcome.passes);
    });

    test('fails when one more than the limit has been recorded', () {
      expect(_bagFinding(_bag(6), _tally(day: 7)).outcome, FindingOutcome.fails);
    });

    test('carries the limit, the recorded count and the period', () {
      final BagLimitFinding f = _bagFinding(_bag(6), _tally(day: 9));
      expect(f.limit, 6);
      expect(f.recorded, 9);
      expect(f.period, LimitPeriod.day);
      expect(f.unit, LimitUnit.count);
      expect(f.kind, FindingKind.bagLimit);
    });

    test('is indeterminate when there is no tally at all', () {
      // §4.5 makes the catch log a feature the fisher CHOOSES to use, and the
      // app records nothing about him by default. Reporting a bag limit as
      // satisfied because the app has no data is the same error class as
      // reporting an untranscribed species as legal.
      final BagLimitFinding f = _bagFinding(_bag(6), null);
      expect(f.outcome, FindingOutcome.indeterminate);
      expect(f.recorded, isNull);
      expect(f.limit, 6, reason: 'the rule is still quoted');
    });

    test('is indeterminate when the tally has nothing for the rule period', () {
      // A season quota with only a day's tally recorded cannot be answered.
      expect(
        _bagFinding(_bag(40, period: LimitPeriod.season), _tally(day: 3)).outcome,
        FindingOutcome.indeterminate,
      );
    });

    test('reads the season tally for a season limit, not the day tally', () {
      // THE FALSE PASS THIS PREVENTS: defaulting to the day tally makes a
      // season quota pass on every single day of a season it has already
      // exhausted — at scale, in the direction that costs the fisher.
      final BagLimitFinding f = _bagFinding(
        _bag(40, period: LimitPeriod.season),
        _tally(day: 3, season: 55),
      );
      expect(f.recorded, 55);
      expect(f.outcome, FindingOutcome.fails);
    });

    test('compares kilogram limits in integer grams', () {
      // The instrument's number is a whole number of kilograms; the tally is
      // grams. Kilograms as double would put 0.1 + 0.2 == 0.30000000000000004
      // between a fisher's eighth fish and a fine, and it would show up only at
      // the boundary — the one place anybody looks.
      final BagLimitFinding f = _bagFinding(_bag(5, unit: LimitUnit.kg), _tally(gramsDay: 5000));
      expect(f.limit, 5);
      expect(f.recorded, 5000);
      expect(f.outcome, FindingOutcome.passes, reason: 'exactly 5 kg is permitted');
    });

    test('fails a kilogram limit one gram over', () {
      expect(
        _bagFinding(_bag(5, unit: LimitUnit.kg), _tally(gramsDay: 5001)).outcome,
        FindingOutcome.fails,
      );
    });

    test('does not add the fish in hand to the tally', () {
      // The engine states what HAS been recorded. Adding one for the fish being
      // checked would make the finding a prediction about an action the fisher
      // has not taken, which is the advisory shape the carve-out excludes. E13
      // records the catch, and the next check states the new fact.
      expect(_bagFinding(_bag(6), _tally(day: 6)).recorded, 6);
    });

    test('returns a Failure when a bag limit row carries no period', () {
      // Defaulting to `day` is the rejected option, and this is the channel the
      // rejection needs.
      final Result<List<Finding>> r = limitFindings(
        _bag(6, period: null),
        _tally(day: 3),
        isExpired: false,
      );
      expect(r.asFailure.exception, isA<MalformedRule>());
    });
  });

  group('VesselLimitFinding', () {
    test('carries no period at all', () {
      // §7.1 gives bag_limit a unit and a period and gives vessel_limit
      // neither. The engine may not state a period the instrument did not give
      // it — that would be the app interpreting.
      final VesselLimitFinding f = _findings(
        _vessel(20),
        _tally(vessel: 12),
      ).whereType<VesselLimitFinding>().single;
      expect(f.limit, 20);
      expect(f.recorded, 12);
      expect(f.kind, FindingKind.vesselLimit);
    });

    test('reads the vessel count and not the day count', () {
      // A different number from the personal one. CatchTally carries it as its
      // own field so the engine does not silently equate one fisher with one
      // hull while §7.2 leaves the question open (epic risk 2).
      final VesselLimitFinding f = _findings(
        _vessel(20),
        _tally(day: 3, vessel: 25),
      ).whereType<VesselLimitFinding>().single;
      expect(f.recorded, 25);
      expect(f.outcome, FindingOutcome.fails);
    });

    test('is indeterminate when no vessel count was recorded', () {
      expect(
        _findings(_vessel(20), _tally(day: 3)).whereType<VesselLimitFinding>().single.outcome,
        FindingOutcome.indeterminate,
      );
    });

    test('passes at exactly the limit', () {
      expect(
        _findings(_vessel(20), _tally(vessel: 20)).whereType<VesselLimitFinding>().single.outcome,
        FindingOutcome.passes,
      );
    });
  });

  group('limitFindings shape', () {
    test('returns an empty list when the rule carries no limits', () {
      expect(
        _findings(
          kRuleHamourMinSize.copyWith(minSizeMm: null, measurementMethod: null),
          _tally(day: 3),
        ),
        isEmpty,
      );
    });

    test('returns both findings when a rule carries a bag and a vessel limit', () {
      final Rule both = _bag(6).copyWith(vesselLimit: 20);
      expect(_findings(both, _tally(day: 3, vessel: 12)), hasLength(2));
    });
  });
}
