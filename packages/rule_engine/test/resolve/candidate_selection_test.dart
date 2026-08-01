// Stage 1 and stage 2 of SPEC.md §7.3, and the expiry rule the whole epic
// turns on.
//
// THE SELECTION PREDICATE IS jurisdiction AND species AND water type AND
// validFrom <= on. THERE IS NO FOURTH CLAUSE. validTo is not consulted, not
// compared, and not used to order anything. §7.3 spends a paragraph on why, and
// the shape of the failure is not the shape most expiry bugs have: a
// `date < validTo` filter is correct-looking, passes every test written on a
// Tuesday, and is wrong on exactly one class of row — the annual instrument. A
// Spanish orden de vedas lapses on 30 April; a permanent ministerial decision
// carries no validTo at all. So the filter does not degrade gracefully: on
// 1 May every Galician shellfish rule disappears at once.
//
// Every test here uses a FROZEN date. No test reads the system clock.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/fixtures.dart';
import '../../testing/utils/result.dart';

const _on = '2026-07-30';

EvaluationRequest _request({String on = _on, WaterType water = WaterType.salt}) =>
    EvaluationRequest(
      jurisdictionId: 7,
      speciesId: 42,
      species: kSpeciesHamour,
      waterType: water,
      zonePath: const <Zone>[kZoneUae, kZoneRasAlKhaimah],
      on: on,
      contentCheckedOn: '2026-07-14',
      landing: kLandingUndersize,
      tally: kTallyEmpty,
    );

List<Candidate> _select(Iterable<Rule> rules, {EvaluationRequest? request}) =>
    selectCandidates(request ?? _request(), rules).asOk.value;

void main() {
  group('selectCandidates', () {
    test('keeps a rule whose jurisdiction, species and water type all match', () {
      expect(_select(<Rule>[kRuleHamourMinSize]), hasLength(1));
    });

    test('drops a rule for another species', () {
      expect(_select(<Rule>[kRuleHamourMinSize.copyWith(speciesId: 43)]), isEmpty);
    });

    test('drops a rule for another jurisdiction', () {
      expect(_select(<Rule>[kRuleHamourMinSize.copyWith(jurisdictionId: 8)]), isEmpty);
    });

    test('keeps a rule whose water type is both when the request is salt', () {
      // `both` is what a jurisdiction-wide rule covering an estuary as well as
      // the sea is authored as. The skill's example predicate drops it.
      expect(_select(<Rule>[kRuleHamourMinSize.copyWith(waterType: WaterType.both)]), hasLength(1));
    });

    test('keeps a rule whose water type is both when the request is fresh', () {
      // The mirror case. One-sided handling of `both` is the likeliest partial
      // fix, and it would leave fresh water empty.
      expect(
        _select(<Rule>[
          kRuleHamourMinSize.copyWith(waterType: WaterType.both),
        ], request: _request(water: WaterType.fresh)),
        hasLength(1),
      );
    });

    test('drops a rule whose water type is fresh when the request is salt', () {
      // The over-correction guard: `both` must WIDEN the match, not disable it.
      expect(_select(<Rule>[kRuleHamourMinSize.copyWith(waterType: WaterType.fresh)]), isEmpty);
    });

    test('keeps a rule whose valid_from equals the evaluation date', () {
      // §7.3 says validFrom <= date. A strict < makes an instrument
      // inapplicable on its own commencement day.
      expect(_select(<Rule>[kRuleHamourMinSize.copyWith(validFrom: _on)]), hasLength(1));
    });

    test('drops a rule whose valid_from is in the future', () {
      // Not law yet. An authored future amendment must not take effect early.
      expect(_select(<Rule>[kRuleHamourMinSize.copyWith(validFrom: '2026-07-31')]), isEmpty);
    });

    test('keeps the greatest valid_from within one citation lineage', () {
      // §7.3 step 1. A superseded 2015 row outranking its own 2018 amendment is
      // catchlaw-rule-engine rule 4's named failure.
      final List<Candidate> got = _select(<Rule>[
        kRuleHamourMinSize, // validFrom 2015-11-03
        kRuleHamourMinSize.copyWith(id: 200, validFrom: '2018-02-11', minSizeMm: 480),
      ]);
      expect(got, hasLength(1));
      expect(got.single.rule.minSizeMm, 480);
    });

    test('keeps both rows when two lineages cover one zone', () {
      // The collapse is per (zone, lineage). Collapsing on zone alone lets one
      // authority's newest instrument delete another authority's rule for the
      // same water.
      expect(
        _select(<Rule>[
          kRuleHamourMinSize,
          kRuleHamourMinSize.copyWith(
            id: 201,
            validFrom: '2018-02-11',
            citation: kCitationRakLocal,
            citationLineageId: 'ae-rak-local-4-2018',
          ),
        ]),
        hasLength(2),
      );
    });

    test('keeps both rows when two rows share a lineage and a valid_from', () {
      // resolution-algorithm.md's edge case: a content bug is SURFACED as an
      // ambiguity in T05, never resolved by iteration order. The skill's own
      // example uses a Map assignment and keeps whichever row came first, which
      // is a silent choice between two instruments — the advisory act the
      // carve-out lists as voiding the whole thing.
      expect(
        _select(<Rule>[kRuleHamourMinSize, kRuleHamourMinSize.copyWith(id: 202, minSizeMm: 480)]),
        hasLength(2),
      );
    });

    test('keeps an expired row that supersedes a live one in the same lineage', () {
      // Expiry is not an input to the collapse. "Expired loses" is rule 1's
      // deletion semantics wearing a tie-break costume.
      final List<Candidate> got = _select(<Rule>[
        kRuleHamourMinSize, // 2015, no validTo
        kRuleHamourMinSize.copyWith(id: 203, validFrom: '2024-01-01', validTo: '2024-06-30'),
      ]);
      expect(got, hasLength(1));
      expect(got.single.rule.id, 203);
      expect(got.single.isExpired, isTrue);
    });

    test('returns an empty list when nothing matches', () {
      // Empty is a legitimate Ok, not a Failure. T11 turns it into a legal
      // statement about the reference data.
      final Result<List<Candidate>> r = selectCandidates(_request(), <Rule>[
        kRuleHamourMinSize.copyWith(speciesId: 99),
      ]);
      expect(r, isA<Ok<List<Candidate>>>());
      expect(r.asOk.value, isEmpty);
    });

    test('returns a Failure when a size rule carries no threshold', () {
      // The T02 boundary in practice: a row that claims a measurement method
      // and carries no number has no legal statement to make, so it may not
      // become an Ok.
      final Result<List<Candidate>> r = selectCandidates(_request(), <Rule>[
        kRuleHamourMinSize.copyWith(minSizeMm: null, maxSizeMm: null),
      ]);
      expect(r, isA<Failure<List<Candidate>>>());
      expect(r.asFailure.exception, isA<MalformedRule>());
      expect((r.asFailure.exception as MalformedRule).ruleId, kRuleHamourMinSize.id);
    });

    test('evaluates a date two years before every valid_from without throwing', () {
      // SPEC.md §14: "set the clock backwards two years ... without crashing".
      // Date arithmetic that assumes forward time fails here first.
      final Result<List<Candidate>> r = selectCandidates(_request(on: '2024-01-01'), <Rule>[
        kRuleHamourMinSize.copyWith(validFrom: '2026-01-01'),
      ]);
      expect(r.asOk.value, isEmpty);
    });
  });

  group('EvaluationRequest', () {
    test('rejects a water type of both', () {
      // The fisher stands in salt water or in fresh water. A `both` request
      // would make the fresh-drops-in-salt guard meaningless.
      expect(() => _request(water: WaterType.both), throwsA(isA<AssertionError>()));
    });
  });
}
