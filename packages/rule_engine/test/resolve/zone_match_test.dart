// Stage 3 of SPEC.md §7.3: match the rule's zone against the request's ancestry
// path, then rank by the specificity ladder.
//
// The ladder is a CLOSED INTEGER TABLE on the enum and nothing derives it.
// catchlaw-rule-engine rule 5 names the failure a depth heuristic produces:
// banco-de-cambados is a bank at depth 3, and a no-take exclusion drawn INSIDE
// it is at depth 4 in some encodings and depth 3 in others depending on how the
// path was built. A specificity computed from path depth therefore ranks the
// bank above the exclusion about half the time — and hands the permissive rule
// to a fisher standing exactly where the strict one applies.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/fixtures.dart';

/// The UAE path: region, subzone, reserve, exclusion — outermost first.
const _uaePath = <Zone>[kZoneUae, kZoneRasAlKhaimah, kZoneRakMangroveReserve, kZoneRakNoTakeCore];

EvaluationRequest _request({List<Zone> zonePath = _uaePath}) => EvaluationRequest(
  jurisdictionId: 7,
  speciesId: 42,
  species: kSpeciesHamour,
  waterType: WaterType.salt,
  zonePath: zonePath,
  on: '2026-07-30',
  contentCheckedOn: '2026-07-14',
  landing: kLandingUndersize,
  tally: kTallyEmpty,
);

Candidate _candidate(int id, int? zoneId) => Candidate(
  rule: kRuleHamourMinSize.copyWith(id: id, zoneId: zoneId),
  isExpired: false,
);

void main() {
  group('ZoneKind', () {
    test('assigns exclusion 40, reserve 30, bank 20, basin 20, subzone 10 and region 0', () {
      expect(ZoneKind.exclusion.specificity, 40);
      expect(ZoneKind.reserve.specificity, 30);
      expect(ZoneKind.bank.specificity, 20);
      expect(ZoneKind.basin.specificity, 20);
      expect(ZoneKind.subzone.specificity, 10);
      expect(ZoneKind.region.specificity, 0);
    });

    test('basin ranks equal to bank', () {
      // §7.3 says "bank/basin 20"; resolution-algorithm.md's table omits basin
      // entirely. This row is why it cannot be dropped again.
      expect(ZoneKind.basin.specificity, ZoneKind.bank.specificity);
    });
  });

  group('specificityOf', () {
    test('returns 0 for a rule with a null zone id', () {
      // NULL is the whole jurisdiction, and it sits DELIBERATELY level with
      // region: a national minimum and a regional minimum that disagree is a
      // genuine ambiguity, not something the sort order should quietly settle.
      expect(specificityOf(kRuleHamourMinSize.copyWith(zoneId: null), _uaePath), 0);
    });

    for (final Zone zone in _uaePath) {
      test('returns ${zone.zoneKind.name} rank ${zone.zoneKind.specificity} for a rule in it', () {
        expect(
          specificityOf(kRuleHamourMinSize.copyWith(zoneId: zone.id), _uaePath),
          zone.zoneKind.specificity,
        );
      });
    }

    test('returns basin rank 20 for a rule in a basin', () {
      // basin is not on the UAE path above, so it gets its own case rather than
      // being silently untested.
      const basin = Zone(
        id: 20,
        jurisdictionId: 7,
        parentZoneId: 0,
        code: 'ae-basin',
        waterType: WaterType.salt,
        zoneKind: ZoneKind.basin,
      );
      expect(
        specificityOf(kRuleHamourMinSize.copyWith(zoneId: 20), const <Zone>[kZoneUae, basin]),
        20,
      );
    });

    test('ignores the stored specificity column', () {
      // Two sources of truth need a tie-break and the published ladder wins.
      // §7.1 stores rule.specificity; a content author mistyping 40 into one
      // YAML row must not outrank §7.3's table. E04 owes a build-time assertion
      // that the two agree (epic risk 6); nothing in this package reads the
      // column, which is what makes that assertion the only place they can
      // diverge.
      expect(specificityOf(kRuleHamourMinSize.copyWith(zoneId: kZoneUae.id), _uaePath), 0);
    });
  });

  group('matchAndRank', () {
    test('keeps a candidate whose zone id is null', () {
      expect(matchAndRank(_request(), <Candidate>[_candidate(1, null)]), hasLength(1));
    });

    test('keeps a candidate whose zone id equals the active zone', () {
      expect(
        matchAndRank(_request(), <Candidate>[_candidate(1, kZoneRakNoTakeCore.id)]),
        hasLength(1),
      );
    });

    test('keeps a candidate whose zone id is an ancestor of the active zone', () {
      // The case a naive equality check drops, deleting every regional rule the
      // moment a subzone is picked.
      expect(matchAndRank(_request(), <Candidate>[_candidate(1, kZoneUae.id)]), hasLength(1));
    });

    test('drops a candidate whose zone is not on the path', () {
      // A neighbouring emirate's rule is not law where he stands.
      expect(matchAndRank(_request(), <Candidate>[_candidate(1, 999)]), isEmpty);
    });

    test('sorts an exclusion above a reserve', () {
      // resolution-algorithm.md's worked trace: the no-take core drawn inside
      // the reserve. This is the pair a depth heuristic gets wrong.
      final List<Candidate> got = matchAndRank(_request(), <Candidate>[
        _candidate(1, kZoneRakMangroveReserve.id), // 30
        _candidate(2, kZoneRakNoTakeCore.id), // 40
      ]);
      expect(got.map((Candidate c) => c.rule.id).toList(), <int>[2, 1]);
    });

    test('sorts a subzone above a region', () {
      // The ordinary case a fisher hits daily.
      final List<Candidate> got = matchAndRank(_request(), <Candidate>[
        _candidate(1, kZoneUae.id), // 0
        _candidate(2, kZoneRasAlKhaimah.id), // 10
      ]);
      expect(got.map((Candidate c) => c.rule.id).toList(), <int>[2, 1]);
    });

    test('ranks a null zone id level with a region so neither wins', () {
      // Both land on 0 and the source order survives, so T05 can return both
      // rather than the sort quietly settling a national-versus-regional
      // disagreement.
      final List<Candidate> got = matchAndRank(_request(), <Candidate>[
        _candidate(1, null),
        _candidate(2, kZoneUae.id),
      ]);
      expect(got.map((Candidate c) => c.rule.id).toList(), <int>[1, 2]);
    });

    test('preserves source order between two candidates of equal specificity', () {
      // the-five-part-carve-out.md part 3 requires two conflicting rules to
      // print in SOURCE order, and Dart's List.sort is documented as not
      // stable. This is the only thing between D4 and a screen that reorders
      // itself between two runs on the same input — which looks like the app
      // choosing, the one thing it must never look like.
      final List<Candidate> got = matchAndRank(_request(), <Candidate>[
        _candidate(7, kZoneRasAlKhaimah.id),
        _candidate(3, kZoneRasAlKhaimah.id),
      ]);
      expect(got.map((Candidate c) => c.rule.id).toList(), <int>[7, 3]);
    });

    test('preserves source order across 40 equal candidates', () {
      // Dart's sort switches algorithm by length, so a two-element test can
      // pass while the real path scrambles.
      final input = <Candidate>[for (var i = 0; i < 40; i++) _candidate(i, kZoneRasAlKhaimah.id)];
      expect(
        matchAndRank(_request(), input).map((Candidate c) => c.rule.id).toList(),
        List<int>.generate(40, (int i) => i),
      );
    });

    test('keeps only null and jurisdiction-scoped rows when zonePath has one element', () {
      // A jurisdiction with has_zone_polygons = 0 still gets a valid answer.
      final List<Candidate> got = matchAndRank(
        _request(zonePath: const <Zone>[kZoneUae]),
        <Candidate>[
          _candidate(1, null),
          _candidate(2, kZoneUae.id),
          _candidate(3, kZoneRasAlKhaimah.id),
        ],
      );
      expect(got.map((Candidate c) => c.rule.id).toList(), <int>[1, 2]);
    });

    test('returns an empty list when no candidate zone is on the path', () {
      // Empty here is not an error; T11 turns it into a legal statement.
      expect(
        matchAndRank(_request(), <Candidate>[
          _candidate(1, 901),
          _candidate(2, 902),
          _candidate(3, 903),
        ]),
        isEmpty,
      );
    });
  });
}
