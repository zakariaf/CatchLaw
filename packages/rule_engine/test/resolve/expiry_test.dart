// Invariant 5, as a unit test, three epics before it is a device test in E21.
//
// An expired ruleset is STILL EVALUATED and STILL SHOWN. The row stays in the
// result set at full strength with its numbers intact, carrying a tag that E10
// renders as an ochre bar above an otherwise unchanged verdict.
//
// What the alternative costs is not "a wrong answer" — it is that the product
// changes category. A bundled snapshot with a known as-of date is a defensible
// thing to ship offline: it is a printed booklet, and a booklet does not stop
// being a booklet on 1 May. A snapshot that silently empties itself when its
// instruments lapse is a live-data product with no way to fetch live data.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/fixtures.dart';
import '../../testing/utils/result.dart';

const _on = '2026-07-30';

EvaluationRequest _request({String on = _on}) => EvaluationRequest(
  jurisdictionId: 7,
  speciesId: 42,
  species: kSpeciesHamour,
  waterType: WaterType.salt,
  zonePath: const <Zone>[kZoneUae, kZoneRasAlKhaimah],
  on: on,
  contentCheckedOn: '2026-07-14',
  landing: kLandingUndersize,
  tally: kTallyEmpty,
);

Candidate _only(Rule rule) => selectCandidates(_request(), <Rule>[rule]).asOk.value.single;

void main() {
  group('selectCandidates', () {
    test('keeps a rule whose valid_to is in the past', () {
      // THE HEADLINE CASE. SPEC.md §14's expiry test in unit form: a lapsed
      // orden de vedas still produces a rule, with its numbers unchanged.
      final Candidate c = _only(kRuleHamourMinSize.copyWith(validTo: '2024-06-30'));
      expect(c.rule.minSizeMm, 450, reason: 'the numbers survive expiry intact');
      expect(c.rule.citation, kCitationMd580);
    });

    test('tags is_expired when valid_to is before the date', () {
      // The tag is what E10's ochre bar reads. A kept row with no tag is a
      // silently stale verdict, which is worse than either alternative.
      expect(_only(kRuleHamourMinSize.copyWith(validTo: '2024-06-30')).isExpired, isTrue);
    });

    test('leaves is_expired false when valid_to equals the date', () {
      // resolution-algorithm.md's expiry table, row 4: the boundary is
      // INCLUSIVE. An instrument in force "until 30 June" is in force ON
      // 30 June. isBefore gives this for free; isAfter-flavoured phrasings do
      // not, which is why check_rule_engine.sh check 2 treats isAfter near
      // validTo as a filter.
      expect(_only(kRuleHamourMinSize.copyWith(validTo: _on)).isExpired, isFalse);
    });

    test('leaves is_expired false when valid_to is null', () {
      // product-invariants.md §5: a pack with no validUntil is valid, never
      // expired. A null-as-expired bug would flag every permanent decision.
      expect(_only(kRuleHamourMinSize).isExpired, isFalse);
    });

    test('leaves is_expired false when valid_to is after the date', () {
      // The ordinary in-force case, so the three tests above cannot all be
      // satisfied by returning a constant.
      expect(_only(kRuleHamourMinSize.copyWith(validTo: '2027-07-30')).isExpired, isFalse);
    });

    test('keeps every rule when all of them have lapsed', () {
      // The 1 May scenario at the scale it actually happens: an entire
      // jurisdiction's annual instruments lapse on one day. A validTo filter
      // empties this list; a tag leaves it full.
      final List<Candidate> got = selectCandidates(_request(), <Rule>[
        kRuleHamourMinSize.copyWith(id: 1, validTo: '2024-06-30'),
        kRuleHamourMinSize.copyWith(
          id: 2,
          citationLineageId: 'b',
          citation: kCitationRakLocal,
          validTo: '2025-04-30',
        ),
      ]).asOk.value;
      expect(got, hasLength(2));
      expect(got.every((Candidate c) => c.isExpired), isTrue);
    });
  });
}
