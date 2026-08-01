// The package's only public entry point, composing T03 to T09.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../testing/models/fixtures.dart';
import '../testing/utils/result.dart';

const _on = '2026-07-30';

EvaluationRequest _request({String on = _on, Landing landing = kLandingUndersize}) =>
    EvaluationRequest(
      jurisdictionId: 7,
      speciesId: 42,
      species: kSpeciesHamour,
      waterType: WaterType.salt,
      zonePath: const <Zone>[kZoneUae, kZoneRasAlKhaimah],
      on: on,
      contentCheckedOn: '2026-07-14',
      landing: landing,
      tally: kTallyEmpty,
      searched: const <Citation>[kCitationMd580],
    );

Resolution _resolve(List<Rule> rows, {EvaluationRequest? request}) =>
    evaluate(request ?? _request(), rows).asOk.value;

void main() {
  group('evaluate', () {
    test('returns Decided with the failing size finding headlined', () {
      // 38 cm against a 45 cm minimum: the spec's worked example, end to end.
      final Resolution r = _resolve(<Rule>[kRuleHamourMinSize]);
      expect(r, isA<Decided>());
      final d = r as Decided;
      expect(d.headline.kind, FindingKind.minSize);
      expect(d.headline.outcome, FindingOutcome.fails);
      expect((d.headline as MinimumSizeFinding).measuredMm, 380);
      expect((d.headline as MinimumSizeFinding).thresholdMm, 450);
    });

    test('returns Decided with a passing headline when the fish is legal', () {
      // There is no Meets arm: a legal fish is a Decided whose headline PASSES,
      // so rule 3's margin — "Meets the minimum — 47 cm measured, minimum
      // 45 cm" — is still printable from the finding's own numbers.
      final d =
          _resolve(
                <Rule>[kRuleHamourMinSize],
                request: _request(
                  landing: const Landing(lengthMm: 470, method: MeasurementMethod.totalLength),
                ),
              )
              as Decided;
      expect(d.headline.outcome, FindingOutcome.passes);
      expect((d.headline as MinimumSizeFinding).measuredMm, 470);
    });

    test('returns Ambiguous when two equally specific rules disagree', () {
      final Resolution r = _resolve(<Rule>[
        kRuleHamourMinSize,
        kRuleHamourMinSize.copyWith(id: 2, minSizeMm: 480, citationLineageId: 'b'),
      ]);
      expect(r, isA<Ambiguous>());
      expect((r as Ambiguous).rules, hasLength(2));
      expect(r.citations, hasLength(2));
    });

    test('returns NoLimitInInstrument when the winning rule records no limit', () {
      // A cited, POSITIVE statement — the instrument was searched and says
      // nothing applies. Distinct from the absences T11 handles.
      final Resolution r = _resolve(<Rule>[
        kRuleHamourMinSize.copyWith(minSizeMm: null, measurementMethod: null),
      ]);
      expect(r, isA<NoLimitInInstrument>());
      expect((r as NoLimitInInstrument).citation, kCitationMd580);
    });

    test('returns a Failure for a content defect and never an Ok', () {
      // T02's boundary, at the entry point: a row that does not say what it
      // claims to say has no legal statement to make.
      final Result<Resolution> r = evaluate(_request(), <Rule>[
        kRuleHamourMinSize.copyWith(minSizeMm: null),
      ]);
      expect(r.asFailure.exception, isA<MalformedRule>());
    });

    test('evaluates an expired rule at full strength and tags it', () {
      // Invariant 5, end to end. The numbers survive; the flag is set; nothing
      // is withheld.
      final d = _resolve(<Rule>[kRuleHamourMinSize.copyWith(validTo: '2024-06-30')]) as Decided;
      expect(d.isExpired, isTrue);
      expect((d.headline as MinimumSizeFinding).thresholdMm, 450);
      expect(d.citation, kCitationMd580);
    });

    test('headlines a closure above a size failure end to end', () {
      final d =
          _resolve(<Rule>[
                kRuleHamourMinSize.copyWith(closedSeasons: kRuleShariClosedSeason.closedSeasons),
              ], request: _request(on: '2026-03-14'))
              as Decided;
      expect(d.headline.kind, FindingKind.closedSeason);
      expect(d.secondary.map((Finding f) => f.kind), contains(FindingKind.minSize));
    });

    test('carries every citation on every arm, never an empty list', () {
      // Invariant 3 without a nullable citation anywhere: an empty list would
      // be the nullable citation wearing a different type.
      for (final r in <Resolution>[
        _resolve(<Rule>[kRuleHamourMinSize]),
        _resolve(<Rule>[
          kRuleHamourMinSize,
          kRuleHamourMinSize.copyWith(id: 2, minSizeMm: 480, citationLineageId: 'b'),
        ]),
        _resolve(<Rule>[kRuleHamourMinSize.copyWith(minSizeMm: null, measurementMethod: null)]),
      ]) {
        expect(r.citations, isNotEmpty, reason: '${r.runtimeType} cited nothing');
      }
    });

    test('switches exhaustively over every arm', () {
      // The sealed union's whole purpose, DEMONSTRATED: this switch had three
      // arms when T10 wrote it and stopped compiling the moment T11 added
      // NoRuleFound and UnknownSpecies. A `default:` would have compiled
      // through both and silently reported an absence as whatever the fallback
      // said — which is the failure the union exists to make impossible.
      String arm(Resolution r) => switch (r) {
        Decided() => 'decided',
        Ambiguous() => 'ambiguous',
        NoLimitInInstrument() => 'no-limit',
        NoRuleFound() => 'no-rule',
        UnknownSpecies() => 'unknown',
      };
      expect(arm(_resolve(<Rule>[kRuleHamourMinSize])), 'decided');
    });
  });
}
