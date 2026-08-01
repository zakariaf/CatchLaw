// SPEC.md §7.3 step 4: when two equally specific rules disagree, return both
// and choose neither.
//
// THE REFUSAL IS A PRODUCT FEATURE AND IT IS LOAD-BEARING LEGALLY. §5.1 lists
// five structural commitments that keep CatchLaw inside the brief's
// "reference/logging tool with no advisory function" carve-out, and the third
// is stated as a contrast: "An advice product would pick one."
// the-five-part-carve-out.md sharpens it into one of the three things that void
// the carve-out outright — "any silent resolution of a genuine legal conflict".
//
// So a later /simplify pass spotting "we could just take the first one" is to
// be answered with this paragraph, not with a patch.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/fixtures.dart';

const _bankPath = <Zone>[kZoneGalicia, kZoneBancoDeCambados];

/// A rule in the bank (specificity 20) unless [zoneId] says otherwise.
Rule _rule(int id, {int? zoneId = 11, int? minSizeMm = 380, String lineage = 'a'}) =>
    kRuleHamourMinSize.copyWith(
      id: id,
      jurisdictionId: 11,
      zoneId: zoneId,
      minSizeMm: minSizeMm,
      citationLineageId: lineage,
    );

Candidate _c(Rule rule, {bool isExpired = false}) => Candidate(rule: rule, isExpired: isExpired);

List<int> _ids(List<Candidate> cs) => cs.map((Candidate c) => c.rule.id).toList();

void main() {
  group('outcomeEquals', () {
    test('reports two rules with the same minimum size as equal', () {
      // Corroboration: two instruments saying the same thing must not raise D4.
      expect(outcomeEquals(_rule(1), _rule(2)), isTrue);
    });

    test('ignores the citation', () {
      // The comparison is SUBSTANCE only. Using Rule.== here would invert the
      // whole feature: it includes id and citation, so it would report
      // corroboration as a conflict. "Two identically-worded rules from two
      // instruments are not an ambiguity; they are corroboration."
      expect(
        outcomeEquals(_rule(1), _rule(2, lineage: 'b').copyWith(citation: kCitationRakLocal)),
        isTrue,
      );
    });

    test('ignores valid_from and valid_to', () {
      // Expiry is not part of a rule's substance; it is a fact about the
      // instrument's currency.
      expect(
        outcomeEquals(_rule(1), _rule(2).copyWith(validFrom: '2024-01-01', validTo: '2024-06-30')),
        isTrue,
      );
    });

    test('reports two different minimum sizes as unequal', () {
      expect(outcomeEquals(_rule(1, minSizeMm: 380), _rule(2, minSizeMm: 400)), isFalse);
    });

    test('reports the same number under two methods as unequal', () {
      // 65 cm fork length is roughly 71 cm total: the number alone is not the
      // outcome. Same specificity, different methods is a conflict.
      expect(
        outcomeEquals(
          _rule(1, minSizeMm: 650),
          _rule(2, minSizeMm: 650).copyWith(measurementMethod: MeasurementMethod.forkLength),
        ),
        isFalse,
      );
    });

    test('reports differing protected flags as unequal', () {
      // Protection is the highest-precedence outcome; two instruments
      // disagreeing about it is the most consequential conflict there is.
      expect(outcomeEquals(_rule(1), _rule(2).copyWith(isProtected: true)), isFalse);
    });

    test('reports differing bag limits as unequal', () {
      expect(
        outcomeEquals(
          _rule(
            1,
          ).copyWith(bagLimit: 5, bagLimitUnit: LimitUnit.count, bagLimitPeriod: LimitPeriod.day),
          _rule(
            2,
          ).copyWith(bagLimit: 8, bagLimitUnit: LimitUnit.count, bagLimitPeriod: LimitPeriod.day),
        ),
        isFalse,
      );
    });

    test('reports differing closure windows as unequal', () {
      // A fortnight is a real disagreement, and closure dates are in the
      // compared set.
      const toApril30 = ClosedSeason(
        recurrence: Recurrence.annual,
        startMonth: 3,
        startDay: 1,
        endMonth: 4,
        endDay: 30,
        citation: kCitationMd580,
      );
      const toApril15 = ClosedSeason(
        recurrence: Recurrence.annual,
        startMonth: 3,
        startDay: 1,
        endMonth: 4,
        endDay: 15,
        citation: kCitationMd580,
      );
      expect(
        outcomeEquals(
          _rule(1).copyWith(closedSeasons: const <ClosedSeason>[toApril30]),
          _rule(2).copyWith(closedSeasons: const <ClosedSeason>[toApril15]),
        ),
        isFalse,
      );
    });
  });

  group('findConflict', () {
    test('returns an empty list when the top two differ in specificity', () {
      // Different specificity is not ambiguity. T04 already settled it and the
      // settlement is legitimate: a narrower instrument beating a wider one is
      // what the instruments themselves say. The wider rule becomes a secondary
      // finding in T09, not a conflict.
      expect(
        findConflict(<Candidate>[
          _c(_rule(1, minSizeMm: 380)),
          _c(_rule(2, zoneId: 10, minSizeMm: 400)),
        ], _bankPath),
        isEmpty,
      );
    });

    test('returns an empty list when two equally specific rules agree', () {
      expect(findConflict(<Candidate>[_c(_rule(1)), _c(_rule(2))], _bankPath), isEmpty);
    });

    test('returns both rules when two equally specific rules disagree', () {
      // The headline case, in the source order T04 preserved.
      expect(
        _ids(
          findConflict(<Candidate>[
            _c(_rule(7, minSizeMm: 380)),
            _c(_rule(3, minSizeMm: 400)),
          ], _bankPath),
        ),
        <int>[7, 3],
      );
    });

    test('returns all three when three are equally specific and one differs', () {
      // Returning only the two that disagree drops a citation the fisher is
      // entitled to read aloud, and makes the output depend on which pair the
      // implementation happened to compare first.
      expect(
        _ids(
          findConflict(<Candidate>[
            _c(_rule(1, minSizeMm: 380)),
            _c(_rule(2, minSizeMm: 380)),
            _c(_rule(3, minSizeMm: 400)),
          ], _bankPath),
        ),
        <int>[1, 2, 3],
      );
    });

    test('returns both rules when one of two disagreeing rivals is expired', () {
      // THE TIE-BREAK THAT LOOKS MOST LIKE GOOD ENGINEERING. "Prefer the rule
      // still in force" is T03's deletion semantics wearing a costume: it means
      // that on the day one of two conflicting instruments lapses, the app
      // silently starts reporting the other one, with no warning and no second
      // citation. Expiry is NOT a tie-breaker.
      expect(
        _ids(
          findConflict(<Candidate>[
            _c(_rule(1, minSizeMm: 380), isExpired: true),
            _c(_rule(2, minSizeMm: 400)),
          ], _bankPath),
        ),
        <int>[1, 2],
      );
    });

    test('returns both rules when a jurisdiction-wide rule disagrees with a region rule', () {
      // Both rank 0 by T04's deliberate choice. This is the conflict that
      // ranking-by-anything would have hidden.
      expect(
        _ids(
          findConflict(<Candidate>[
            _c(_rule(1, zoneId: null, minSizeMm: 380)),
            _c(_rule(2, zoneId: 10, minSizeMm: 400)),
          ], _bankPath),
        ),
        <int>[1, 2],
      );
    });

    test('returns an empty list for a single candidate', () {
      // A conflict detector that fires on one rule fires on every screen.
      expect(findConflict(<Candidate>[_c(_rule(1))], _bankPath), isEmpty);
    });

    test('returns an empty list for no candidates', () {
      // The boundary a `ranked.first` implementation throws on.
      expect(findConflict(const <Candidate>[], _bankPath), isEmpty);
    });
  });
}
