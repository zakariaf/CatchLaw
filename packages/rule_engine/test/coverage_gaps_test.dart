// The branches every other test file left uncovered.
//
// The epic's definition of done asks for 100% branch coverage over
// lib/src/resolve/, lib/src/season/, lib/src/findings/ and lib/src/verdict/.
// Measuring it turned up eleven gaps, and each one is here with the reason it
// matters rather than as a coverage-chasing exercise: two are error paths that
// carry a content defect out of a nested producer, three are the value-type
// members that make a Candidate usable as a map key, and the rest are
// defect-detection branches nothing else reached.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../testing/models/fixtures.dart';
import '../testing/utils/result.dart';

const _tl = MeasurementMethod.totalLength;

EvaluationRequest _request({String on = '2026-07-30'}) => EvaluationRequest(
  jurisdictionId: 7,
  speciesId: 42,
  species: kSpeciesHamour,
  waterType: WaterType.salt,
  zonePath: const <Zone>[kZoneUae, kZoneRasAlKhaimah],
  on: on,
  contentCheckedOn: '2026-07-14',
  landing: kLandingUndersize,
  tally: kTallyEmpty,
  searched: const <Citation>[kCitationMd580],
);

void main() {
  group('Candidate', () {
    // Value-type members, and they are not decoration: T03's stage 2 puts
    // candidates in collections, so identity equality would make a map key
    // useless and a set silently keep duplicates.
    test('compares equal to a separately built identical candidate', () {
      final a = Candidate(rule: kRuleHamourMinSize.copyWith(), isExpired: false);
      final b = Candidate(rule: kRuleHamourMinSize.copyWith(), isExpired: false);
      expect(a, isNot(same(b)), reason: 'must be two objects');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(<Candidate>{a, b}, hasLength(1));
    });

    test('compares unequal when only the expiry tag differs', () {
      // The tag is part of the value: a candidate that has lapsed is not the
      // same answer as one that has not, even from the same rule.
      const a = Candidate(rule: kRuleHamourMinSize, isExpired: false);
      const b = Candidate(rule: kRuleHamourMinSize, isExpired: true);
      expect(a, isNot(equals(b)));
    });

    test('names its rule and its expiry in toString', () {
      expect(
        const Candidate(rule: kRuleHamourMinSize, isExpired: true).toString(),
        allOf(contains('${kRuleHamourMinSize.id}'), contains('true')),
      );
    });
  });

  group('selectCandidates defect detection', () {
    test('returns a Failure when a size carries no measurement method', () {
      // A threshold with no method cannot be compared against anything: T07
      // would have to invent one, and 65 cm fork is not 65 cm total.
      final Result<List<Candidate>> r = selectCandidates(_request(), <Rule>[
        kRuleHamourMinSize.copyWith(measurementMethod: null),
      ]);
      expect(r.asFailure.exception, isA<MalformedRule>());
      expect((r.asFailure.exception as MalformedRule).field, 'measurementMethod');
    });

    test('returns a Failure when a bag limit carries no unit', () {
      final Result<List<Candidate>> r = selectCandidates(_request(), <Rule>[
        kRuleHamourMinSize.copyWith(
          minSizeMm: null,
          measurementMethod: null,
          bagLimit: 6,
          bagLimitPeriod: LimitPeriod.day,
        ),
      ]);
      expect(r.asFailure.exception, isA<MalformedRule>());
    });
  });

  group('outcomeEquals closure comparison', () {
    test('reports differing closure counts as unequal', () {
      // One rule with a closure and one without is not corroboration, and the
      // length check is what catches it before the field-by-field walk.
      expect(
        outcomeEquals(
          kRuleShariClosedSeason,
          kRuleShariClosedSeason.copyWith(closedSeasons: const <ClosedSeason>[]),
        ),
        isFalse,
      );
    });

    test('reports differing fixed closure dates as unequal', () {
      // The fixed-window fields, which the annual tests never reach.
      const a = ClosedSeason(
        recurrence: Recurrence.fixed,
        startDate: '2026-03-01',
        endDate: '2026-04-30',
        citation: kCitationMd580,
      );
      const b = ClosedSeason(
        recurrence: Recurrence.fixed,
        startDate: '2026-03-01',
        endDate: '2026-05-31',
        citation: kCitationMd580,
      );
      expect(
        outcomeEquals(
          kRuleShariClosedSeason.copyWith(closedSeasons: const <ClosedSeason>[a]),
          kRuleShariClosedSeason.copyWith(closedSeasons: const <ClosedSeason>[b]),
        ),
        isFalse,
      );
    });
  });

  group('rankFindings and precedenceOf guards', () {
    test('rejects an empty finding list', () {
      // Unreachable through evaluate, which guards first. Kept as a defensive
      // check because the alternative is `.first` throwing a StateError with
      // no explanation of what the caller did wrong.
      expect(() => rankFindings(const <Finding>[]), throwsArgumentError);
    });
  });

  group('findingsFor error propagation', () {
    test('carries a malformed season out of the closure producer', () {
      // The nested Result unwrap: one content defect inside a closure fails the
      // whole evaluation rather than leaving a finding list with a hole in it.
      final Result<List<Finding>> r = findingsFor(
        kRuleHamourMinSize.copyWith(
          closedSeasons: const <ClosedSeason>[
            ClosedSeason(
              recurrence: Recurrence.annual,
              startMonth: null,
              startDay: 1,
              endMonth: 4,
              endDay: 30,
              citation: kCitationMd580,
            ),
          ],
        ),
        landing: kLandingUndersize,
        tally: kTallyEmpty,
        on: '2026-03-14',
        isExpired: false,
      );
      expect(r.asFailure.exception, isA<MalformedSeason>());
    });

    test('carries the same defect out of evaluate', () {
      // The same path one layer up, so the error survives the whole pipeline.
      final Result<Resolution> r = evaluate(_request(on: '2026-03-14'), <Rule>[
        kRuleHamourMinSize.copyWith(
          closedSeasons: const <ClosedSeason>[
            ClosedSeason(
              recurrence: Recurrence.fixed,
              startDate: '2026-03-01',
              endDate: null,
              citation: kCitationMd580,
            ),
          ],
        ),
      ]);
      expect(r.asFailure.exception, isA<MalformedSeason>());
    });
  });

  group('Decided.isExpired', () {
    test('is true when only a secondary finding has lapsed', () {
      // The `||` short-circuits on the headline, so a lapsed instrument behind
      // a SECONDARY finding is the case an unwary implementation drops — and
      // the ochre bar would then not appear for a verdict that partly rests on
      // a lapsed rule.
      const fresh = MinimumSizeFinding(
        citation: kCitationMd580,
        isExpired: false,
        thresholdMm: 450,
        method: _tl,
        measuredMm: 380,
        measuredMethod: _tl,
      );
      const staleSecondary = BagLimitFinding(
        citation: kCitationRakLocal,
        isExpired: true,
        limit: 6,
        unit: LimitUnit.count,
        period: LimitPeriod.day,
        recorded: 3,
      );
      const d = Decided(headline: fresh, secondary: <Finding>[staleSecondary]);
      expect(d.isExpired, isTrue);
    });

    test('is false when nothing has lapsed', () {
      const fresh = MinimumSizeFinding(
        citation: kCitationMd580,
        isExpired: false,
        thresholdMm: 450,
        method: _tl,
        measuredMm: 380,
        measuredMethod: _tl,
      );
      const d = Decided(headline: fresh, secondary: <Finding>[]);
      expect(d.isExpired, isFalse);
    });
  });
}
