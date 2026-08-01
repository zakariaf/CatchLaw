// Three absences that look identical from a caller's seat and are legally miles
// apart.
//
//   NoLimitInInstrument  the instrument covers this species here and POSITIVELY
//                        RECORDS no limit — one citation, the instrument says so
//   NoRuleFound          the species is in the database; no rule row covers it
//                        in this zone — what was searched, and when it was
//                        last verified
//   UnknownSpecies       the id is not in this jurisdiction's list at all
//
// Collapsing any two is the failure catchlaw-rule-engine rule 8 names: "absence
// of evidence stamped as permission fails silently in exactly the zones with the
// thinnest content." Those are the zones E22 has not reached yet, which is most
// of them for most of this product's life.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/fixtures.dart';
import '../../testing/utils/result.dart';

EvaluationRequest _request({Species? species = kSpeciesHamour, int speciesId = 42}) =>
    EvaluationRequest(
      jurisdictionId: 7,
      speciesId: speciesId,
      species: species,
      waterType: WaterType.salt,
      zonePath: const <Zone>[kZoneUae, kZoneRasAlKhaimah],
      on: '2026-07-30',
      contentCheckedOn: '2026-07-14',
      landing: kLandingUndersize,
      tally: kTallyEmpty,
      searched: const <Citation>[kCitationMd580, kCitationRakLocal],
    );

void main() {
  group('UnknownSpecies', () {
    test('is returned when the species is not in this jurisdiction list', () {
      final Resolution r = evaluate(_request(species: null, speciesId: 999), <Rule>[
        kRuleHamourMinSize,
      ]).asOk.value;
      expect(r, isA<UnknownSpecies>());
      expect((r as UnknownSpecies).speciesId, 999);
    });

    test('is returned even when rule rows for other species were supplied', () {
      // The species check happens BEFORE stage 1, so a full candidate list
      // cannot mask it.
      final Resolution r = evaluate(_request(species: null), <Rule>[
        kRuleHamourMinSize,
        kRuleShariClosedSeason,
      ]).asOk.value;
      expect(r, isA<UnknownSpecies>());
    });

    test('carries what was searched and when it was checked', () {
      final r = evaluate(_request(species: null), const <Rule>[]).asOk.value as UnknownSpecies;
      expect(r.searched, hasLength(2));
      expect(r.checkedOn, '2026-07-14');
    });

    test('is never expired, because nothing was evaluated', () {
      final r = evaluate(_request(species: null), const <Rule>[]).asOk.value as UnknownSpecies;
      expect(r.isExpired, isFalse);
    });
  });

  group('NoRuleFound', () {
    test('is returned when the species exists and no rule covers this zone', () {
      final Resolution r = evaluate(_request(), <Rule>[
        kRuleHamourMinSize.copyWith(zoneId: 999), // a zone not on the path
      ]).asOk.value;
      expect(r, isA<NoRuleFound>());
    });

    test('is returned when no rule rows were supplied at all', () {
      expect(evaluate(_request(), const <Rule>[]).asOk.value, isA<NoRuleFound>());
    });

    test('carries what was searched and when it was checked', () {
      // "what was looked in, so he can say what was looked in".
      final r = evaluate(_request(), const <Rule>[]).asOk.value as NoRuleFound;
      expect(r.searched, hasLength(2));
      expect(r.checkedOn, '2026-07-14');
    });

    test('is a different type from UnknownSpecies', () {
      // §4.1 requires two VISUALLY DISTINCT states, which the app can only
      // render if the engine returns two distinct types.
      final Resolution absent = evaluate(_request(), const <Rule>[]).asOk.value;
      final Resolution unknown = evaluate(_request(species: null), const <Rule>[]).asOk.value;
      expect(absent.runtimeType, isNot(unknown.runtimeType));
    });

    test('is a different type from NoLimitInInstrument', () {
      // The third absence: an instrument that WAS found and records no limit.
      final Resolution recorded = evaluate(_request(), <Rule>[
        kRuleHamourMinSize.copyWith(minSizeMm: null, measurementMethod: null),
      ]).asOk.value;
      final Resolution absent = evaluate(_request(), const <Rule>[]).asOk.value;
      expect(recorded, isA<NoLimitInInstrument>());
      expect(absent, isA<NoRuleFound>());
    });
  });

  group('the absence arms', () {
    test('cite a non-empty list of what was consulted', () {
      // An empty List<Citation> is a nullable citation in a different coat and
      // would let an uncited absence ship. This does not weaken invariant 3: it
      // is the reading that holds its PURPOSE, because naming an instrument for
      // a rule that does not exist is the banned "?? Local fisheries rules"
      // fallback.
      for (final r in <Resolution>[
        evaluate(_request(), const <Rule>[]).asOk.value,
        evaluate(_request(species: null), const <Rule>[]).asOk.value,
      ]) {
        expect(r.citations, isNotEmpty, reason: '${r.runtimeType} cited nothing');
      }
    });

    test('cannot reach a permissive outcome', () {
      // The structural claim, and the durable half of this task. Decided
      // requires a headline Finding; a Finding requires a rule to have been
      // found; neither arm can produce one. The `findings.isEmpty ? meets`
      // shape is not avoided here — it is UNREPRESENTABLE.
      for (final r in <Resolution>[
        evaluate(_request(), const <Rule>[]).asOk.value,
        evaluate(_request(species: null), const <Rule>[]).asOk.value,
      ]) {
        expect(r, isNot(isA<Decided>()));
      }
    });
  });

  group('Resolution', () {
    test('switches exhaustively over all five arms', () {
      // Adding two arms to a sealed union is the point of it being sealed:
      // every switch in the app fails to compile until both are handled.
      String arm(Resolution r) => switch (r) {
        Decided() => 'decided',
        Ambiguous() => 'ambiguous',
        NoLimitInInstrument() => 'no-limit',
        NoRuleFound() => 'no-rule',
        UnknownSpecies() => 'unknown',
      };
      expect(arm(evaluate(_request(), const <Rule>[]).asOk.value), 'no-rule');
      expect(arm(evaluate(_request(species: null), const <Rule>[]).asOk.value), 'unknown');
    });
  });

  group('EvaluationRequest', () {
    test('rejects an empty searched list', () {
      // A bundled jurisdiction always has at least one citation row or it would
      // not have passed E04's content build, so this can only fire on a mapper
      // defect — which is exactly when an uncited absence would otherwise ship.
      expect(
        () => EvaluationRequest(
          jurisdictionId: 7,
          speciesId: 42,
          species: kSpeciesHamour,
          waterType: WaterType.salt,
          zonePath: const <Zone>[kZoneUae],
          on: '2026-07-30',
          contentCheckedOn: '2026-07-14',
          landing: kLandingUndersize,
          tally: kTallyEmpty,
          searched: const <Citation>[],
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
