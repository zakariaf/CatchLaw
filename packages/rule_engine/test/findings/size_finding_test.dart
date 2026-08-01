// Size findings: integer millimetres, an inclusive legal boundary, and a method
// that is COMPARED and never converted.
//
// catchlaw-rule-engine rule 12 gives the number: 65 cm fork length on a Kanaad
// is roughly 71 cm total length. A conversion factor bridging the two would
// manufacture a pass at the centimetre that costs AED 3,000, and it would be
// the app performing an interpretation — which the-five-part-carve-out.md part
// 4 bans outright.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/fixtures.dart';

const _tl = MeasurementMethod.totalLength;
const _fl = MeasurementMethod.forkLength;

Rule _rule({int? min = 450, int? max, MeasurementMethod? method = _tl}) =>
    kRuleHamourMinSize.copyWith(minSizeMm: min, maxSizeMm: max, measurementMethod: method);

List<Finding> _findings(Rule rule, Landing? landing) => sizeFindings(rule, landing);

MinimumSizeFinding _min(Rule rule, Landing? landing) =>
    _findings(rule, landing).whereType<MinimumSizeFinding>().single;

MaximumSizeFinding _max(Rule rule, Landing? landing) =>
    _findings(rule, landing).whereType<MaximumSizeFinding>().single;

void main() {
  group('sizeFindings minimum', () {
    test('fails when the measurement is below the minimum', () {
      // 38 cm against a 45 cm minimum — the spec's own worked example.
      expect(
        _min(_rule(), const Landing(lengthMm: 380, method: _tl)).outcome,
        FindingOutcome.fails,
      );
    });

    test('passes when the measurement is above the minimum', () {
      expect(
        _min(_rule(), const Landing(lengthMm: 470, method: _tl)).outcome,
        FindingOutcome.passes,
      );
    });

    test('passes when the measurement is exactly the minimum', () {
      // A minimum is a MINIMUM: a fish exactly at it meets the rule. Off-by-one
      // here is the difference between a legal fish and an offence at the one
      // millimetre where the instrument is most precise.
      expect(
        _min(_rule(), const Landing(lengthMm: 450, method: _tl)).outcome,
        FindingOutcome.passes,
      );
    });

    test('fails one millimetre below the minimum', () {
      // The other side of the same boundary, so an inclusive comparison cannot
      // pass both tests by being permissive.
      expect(
        _min(_rule(), const Landing(lengthMm: 449, method: _tl)).outcome,
        FindingOutcome.fails,
      );
    });

    test('carries both integers so the app can state the margin', () {
      final MinimumSizeFinding f = _min(_rule(), const Landing(lengthMm: 380, method: _tl));
      expect(f.measuredMm, 380);
      expect(f.thresholdMm, 450);
      expect(f.method, _tl);
      expect(f.kind, FindingKind.minSize);
    });
  });

  group('sizeFindings maximum', () {
    test('fails when the measurement is above the maximum', () {
      expect(
        _max(_rule(min: null, max: 700), const Landing(lengthMm: 750, method: _tl)).outcome,
        FindingOutcome.fails,
      );
    });

    test('passes when the measurement is exactly the maximum', () {
      expect(
        _max(_rule(min: null, max: 700), const Landing(lengthMm: 700, method: _tl)).outcome,
        FindingOutcome.passes,
      );
    });

    test('fails one millimetre above the maximum', () {
      expect(
        _max(_rule(min: null, max: 700), const Landing(lengthMm: 701, method: _tl)).outcome,
        FindingOutcome.fails,
      );
    });

    test('reports kind maxSize', () {
      expect(
        _max(_rule(min: null, max: 700), const Landing(lengthMm: 750, method: _tl)).kind,
        FindingKind.maxSize,
      );
    });
  });

  group('sizeFindings method mismatch', () {
    test('is indeterminate when the reading was taken by another method', () {
      // NO COMPARISON IS PERFORMED. 650 mm fork length against a 650 mm total
      // length threshold is not a pass and not a fail; it is two facts side by
      // side and no conclusion.
      final MinimumSizeFinding f = _min(_rule(min: 650), const Landing(lengthMm: 650, method: _fl));
      expect(f.outcome, FindingOutcome.indeterminate);
      expect(f.methodMismatch, isTrue);
    });

    test('carries both readings and both methods so each can be stated', () {
      final MinimumSizeFinding f = _min(_rule(min: 650), const Landing(lengthMm: 600, method: _fl));
      expect(f.measuredMm, 600);
      expect(f.measuredMethod, _fl);
      expect(f.thresholdMm, 650);
      expect(f.method, _tl);
    });

    test('does not fail a reading that would have failed under the rule method', () {
      // The guard against a mismatch that quietly falls through to a
      // comparison: 300 mm is far below 650 mm, and it still must not fail.
      final MinimumSizeFinding f = _min(_rule(min: 650), const Landing(lengthMm: 300, method: _fl));
      expect(f.outcome, FindingOutcome.indeterminate);
    });

    test('reports no mismatch when the methods agree', () {
      expect(_min(_rule(), const Landing(lengthMm: 470, method: _tl)).methodMismatch, isFalse);
    });
  });

  group('sizeFindings without a measurement', () {
    test('is indeterminate when the fish was not measured', () {
      // "reading == null on a size rule — the size finding is indeterminate,
      // not a pass". The same legal argument as T11's: silence is not
      // permission. A fisher who picks a species without measuring gets a page
      // stating the rule and stating that nothing has been measured, never a
      // green stamp.
      final MinimumSizeFinding f = _min(_rule(), kLandingUnmeasured);
      expect(f.outcome, FindingOutcome.indeterminate);
      expect(f.measuredMm, isNull);
    });

    test('is indeterminate when there is no landing at all', () {
      expect(_min(_rule(), null).outcome, FindingOutcome.indeterminate);
    });

    test('still states the threshold the rule requires', () {
      // The rule is quoted even though nothing can be compared against it.
      final MinimumSizeFinding f = _min(_rule(), kLandingUnmeasured);
      expect(f.thresholdMm, 450);
      expect(f.method, _tl);
    });
  });

  group('sizeFindings shape', () {
    test('returns two findings for a slot rule', () {
      // §7.1 lets one row carry both bounds — a slot limit. maxSize outranks
      // minSize in T09's precedence because slot rules protect spawners.
      final List<Finding> got = _findings(
        _rule(min: 450, max: 700),
        const Landing(lengthMm: 500, method: _tl),
      );
      expect(got, hasLength(2));
      expect(
        got.map((Finding f) => f.kind),
        containsAll(<FindingKind>[FindingKind.minSize, FindingKind.maxSize]),
      );
    });

    test('returns an empty list when the rule carries no size columns', () {
      // An empty list composes; a nullable finding makes every caller in T09
      // write the same null check.
      expect(
        _findings(_rule(min: null, method: null), const Landing(lengthMm: 500, method: _tl)),
        isEmpty,
      );
    });

    test('carries the citation from the rule', () {
      expect(_min(_rule(), const Landing(lengthMm: 380, method: _tl)).citation, kCitationMd580);
    });
  });
}
