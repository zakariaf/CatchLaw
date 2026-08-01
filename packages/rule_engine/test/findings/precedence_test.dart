// SPEC.md §7.3 precedence, applied EXACTLY ONCE.
//
// catchlaw-rule-engine rule 7 names the failure a re-sorting surface produces:
// a protected sawfish headlined as "below the minimum" reads to the fisher as a
// size problem, solvable by finding a bigger one. Different offence, different
// penalty, landed fish. So the ranking happens here and E10 renders the list it
// is given.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/fixtures.dart';
import '../../testing/utils/result.dart';

const _tl = MeasurementMethod.totalLength;

Finding _min({int measured = 380}) => MinimumSizeFinding(
  citation: kCitationMd580,
  isExpired: false,
  thresholdMm: 450,
  method: _tl,
  measuredMm: measured,
  measuredMethod: _tl,
);

Finding _minIndeterminate() => const MinimumSizeFinding(
  citation: kCitationMd580,
  isExpired: false,
  thresholdMm: 450,
  method: _tl,
  measuredMm: null,
  measuredMethod: null,
);

Finding _protected() => const ProtectedFinding(citation: kCitationMd580, isExpired: false);

Finding _closure({bool inForce = true}) => ClosedSeasonFinding(
  citation: kCitationMd580,
  isExpired: false,
  recurrence: Recurrence.annual,
  inForce: inForce,
  startsOn: '2026-03-01',
  endsOn: '2026-04-30',
  dayOfClosure: inForce ? 14 : 0,
  lengthInDays: 61,
);

Finding _bag({int recorded = 9}) => BagLimitFinding(
  citation: kCitationMd580,
  isExpired: false,
  limit: 6,
  unit: LimitUnit.count,
  period: LimitPeriod.day,
  recorded: recorded,
);

void main() {
  group('precedenceOf', () {
    test('assigns protected 60, closedSeason 50, maxSize 40, minSize 30, bagLimit 20 '
        'and vesselLimit 10', () {
      expect(precedenceOf(FindingKind.protected), 60);
      expect(precedenceOf(FindingKind.closedSeason), 50);
      expect(precedenceOf(FindingKind.maxSize), 40);
      expect(precedenceOf(FindingKind.minSize), 30);
      expect(precedenceOf(FindingKind.bagLimit), 20);
      expect(precedenceOf(FindingKind.vesselLimit), 10);
    });

    for (final FindingKind kind in FindingKind.values) {
      test('covers ${kind.name}', () {
        // A seventh kind added later must fail HERE rather than sort to an
        // arbitrary place. The map is explicit rather than FindingKind.index
        // precisely so that adding a member in a tidy alphabetical position
        // breaks loudly instead of silently reordering the ladder.
        expect(() => precedenceOf(kind), returnsNormally);
      });
    }

    test('ranks maxSize above minSize', () {
      // A slot maximum protects spawners; a minimum applies to this individual.
      expect(precedenceOf(FindingKind.maxSize), greaterThan(precedenceOf(FindingKind.minSize)));
    });

    test('ranks vesselLimit last', () {
      // Per-hull, and therefore the widest scope.
      expect(precedenceOf(FindingKind.vesselLimit), lessThan(precedenceOf(FindingKind.bagLimit)));
    });
  });

  group('rankFindings', () {
    test('headlines a protected failure above a size failure', () {
      // THE FAILURE RULE 7 NAMES. A protected sawfish must never be headlined
      // as "below the minimum": that reads as a size problem, solvable by
      // finding a bigger one.
      final RankedFindings r = rankFindings(<Finding>[_min(), _protected()]);
      expect(r.headline.kind, FindingKind.protected);
    });

    test('headlines a closure above a size failure', () {
      final RankedFindings r = rankFindings(<Finding>[_min(), _closure()]);
      expect(r.headline.kind, FindingKind.closedSeason);
    });

    test('headlines the highest-precedence failure over a higher-precedence pass', () {
      // A satisfied closure does not outrank a real size failure, or every
      // screen headlines the thing that is fine.
      final RankedFindings r = rankFindings(<Finding>[_closure(inForce: false), _min()]);
      expect(r.headline.kind, FindingKind.minSize);
      expect(r.headline.outcome, FindingOutcome.fails);
    });

    test('headlines the highest-precedence pass when nothing fails', () {
      // The fallback the skill's example gets wrong with `findings.first`,
      // which is whatever order the query happened to return.
      final RankedFindings r = rankFindings(<Finding>[
        _min(measured: 470),
        _closure(inForce: false),
      ]);
      expect(r.headline.kind, FindingKind.closedSeason);
      expect(r.headline.outcome, FindingOutcome.passes);
    });

    test('headlines a determinate pass over an indeterminate finding of higher precedence', () {
      // An open question is a WEAKER statement than a determinate pass, and
      // headlining it reads as the app having failed.
      final RankedFindings r = rankFindings(<Finding>[
        _minIndeterminate(),
        _closure(inForce: false),
      ]);
      expect(r.headline.outcome, FindingOutcome.passes);
    });

    test('headlines an indeterminate finding when it is all there is', () {
      // §4.1's no-rule-versus-no-data requirement: an open question must be
      // VISIBLE rather than hidden.
      final RankedFindings r = rankFindings(<Finding>[_minIndeterminate()]);
      expect(r.headline.outcome, FindingOutcome.indeterminate);
      expect(r.secondary, isEmpty);
    });

    test('keeps every non-headline finding in secondary, passes included', () {
      // "Non-deciding findings are NOT discarded: a closed-season headline
      // still carries the size finding in secondary, so the rule table can
      // print 'Size rule — 45 cm total length, satisfied' beneath a closure."
      // secondary is not a list of other failures.
      final RankedFindings r = rankFindings(<Finding>[
        _min(measured: 470), // passes
        _closure(), // fails
        _bag(recorded: 3), // passes
      ]);
      expect(r.headline.kind, FindingKind.closedSeason);
      expect(r.secondary.map((Finding f) => f.kind).toList(), <FindingKind>[
        FindingKind.minSize,
        FindingKind.bagLimit,
      ]);
    });

    test('orders secondary by precedence', () {
      final RankedFindings r = rankFindings(<Finding>[_bag(), _min(), _protected()]);
      expect(r.secondary.map((Finding f) => f.kind).toList(), <FindingKind>[
        FindingKind.minSize,
        FindingKind.bagLimit,
      ]);
    });

    test('preserves arrival order between two findings of the same kind', () {
      // Two rules of one kind, both failing. Dart's sort is unstable, and a
      // shifting order here is the same defect T04 guards against one layer up.
      final Finding a = _min(measured: 100);
      final Finding b = _min(measured: 200);
      final RankedFindings r = rankFindings(<Finding>[a, b]);
      expect(identical(r.headline, a), isTrue);
      expect(identical(r.secondary.single, b), isTrue);
    });
  });

  group('ProtectedFinding', () {
    test('fails whenever it exists', () {
      expect(_protected().outcome, FindingOutcome.fails);
      expect(_protected().kind, FindingKind.protected);
    });

    test('is not produced for a rule whose protected flag is clear', () {
      // "This species is not protected" is not a statement any instrument makes
      // about every species in it, and printing it would be the app
      // manufacturing a fact.
      final List<Finding> got = findingsFor(
        kRuleHamourMinSize.copyWith(isProtected: false),
        landing: kLandingUndersize,
        tally: kTallyEmpty,
        on: '2026-07-30',
        isExpired: false,
      ).asOk.value;
      expect(got.where((Finding f) => f.kind == FindingKind.protected), isEmpty);
    });
  });

  group('findingsFor', () {
    test('collects protection, closure, size and limits from one rule', () {
      final List<Finding> got = findingsFor(
        kRuleHamourMinSize.copyWith(
          isProtected: true,
          bagLimit: 6,
          bagLimitUnit: LimitUnit.count,
          bagLimitPeriod: LimitPeriod.day,
          closedSeasons: kRuleShariClosedSeason.closedSeasons,
        ),
        landing: kLandingUndersize,
        tally: kTallyEmpty,
        on: '2026-03-14',
        isExpired: false,
      ).asOk.value;
      expect(got.map((Finding f) => f.kind).toSet(), <FindingKind>{
        FindingKind.protected,
        FindingKind.closedSeason,
        FindingKind.minSize,
        FindingKind.bagLimit,
      });
    });

    test('fails the whole evaluation on one content defect', () {
      // A single defect fails everything rather than producing a partial
      // finding list with a silent hole in it.
      final Result<List<Finding>> r = findingsFor(
        kRuleHamourMinSize.copyWith(bagLimit: 6, bagLimitPeriod: null),
        landing: kLandingUndersize,
        tally: kTallyEmpty,
        on: '2026-07-30',
        isExpired: false,
      );
      expect(r.asFailure.exception, isA<MalformedRule>());
    });

    test('carries the isExpired tag onto every finding it produces', () {
      final List<Finding> got = findingsFor(
        kRuleHamourMinSize,
        landing: kLandingUndersize,
        tally: kTallyEmpty,
        on: '2026-07-30',
        isExpired: true,
      ).asOk.value;
      expect(got, isNotEmpty);
      expect(got.every((Finding f) => f.isExpired), isTrue);
    });
  });
}
