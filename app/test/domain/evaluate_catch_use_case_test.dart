import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/species.dart' as domain;
import 'package:catchlaw/domain/use_cases/evaluate_catch_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart';

import '../../testing/fakes/fake_reference_repository.dart';
import '../../testing/fakes/store_env.dart';

const Jurisdiction _galicia = Jurisdiction(
  id: 1,
  code: 'ES-GA',
  countryIso2: 'ES',
  nameKey: 'jurisdiction.es_ga.name',
  authorityKey: 'jurisdiction.es_ga.authority',
  defaultLocale: 'gl',
  hasSaltwater: true,
  hasFreshwater: false,
  hasZonePolygons: false,
  contentVersion: '2026.08.0',
  checkedOn: '2026-08-12',
);

const domain.Zone _riasBaixas = domain.Zone(
  id: 10,
  jurisdictionId: 1,
  code: 'rias-baixas',
  nameKey: 'zone.es_ga.rias_baixas',
  waterType: WaterKind.salt,
  zoneKind: ZoneKind.region,
);

const domain.Species _ameixa = domain.Species(
  id: 7,
  scientificName: 'Venerupis corrugata',
  taxonGroup: TaxonGroup.bivalve,
  familyId: 1,
  silhouetteAsset: 'assets/silhouette/venerupis.svg',
);

const Citation _xunta = Citation(
  instrument: 'Orde do 27 de xullo de 2012',
  article: 'Art. 4',
  publishedOn: '2012-08-06',
  checkedOn: '2026-08-12',
);

Rule _minimumRule({String? validTo}) => Rule(
  id: 1,
  jurisdictionId: 1,
  zoneId: null,
  speciesId: 7,
  waterType: WaterType.salt,
  citation: _xunta,
  citationLineageId: 'es-ga-orde-2012-07-27',
  validFrom: '2012-08-06',
  validTo: validTo,
  minSizeMm: 38,
  measurementMethod: MeasurementMethod.shellLength,
);

const EvaluationScope _cambados = EvaluationScope(
  jurisdictionCode: 'ES-GA',
  zoneCode: 'rias-baixas',
  zonePath: <String>['ES-GA', 'rias-baixas'],
  water: WaterKind.salt,
  authorityKey: 'jurisdiction.es_ga.authority',
  defaultLocale: 'gl',
  packVersion: '2026.08.0',
  checkedOn: '2026-08-12',
);

EvaluateCatchUseCase _useCase({
  List<Rule> rules = const <Rule>[],
  List<domain.Species> species = const <domain.Species>[_ameixa],
  StoreEnv env = StoreEnv.healthy,
}) {
  final reference = FakeReferenceRepository(env: env, species: species, rules: rules)
    ..jurisdictionRows.add(_galicia);
  reference.zoneRows[1] = const <domain.Zone>[_riasBaixas];
  return EvaluateCatchUseCase(reference: reference);
}

CatchQuestion _question({int? lengthMm, MeasurementMethod? method, int speciesId = 7}) =>
    CatchQuestion(
      scope: _cambados,
      speciesId: speciesId,
      on: '2026-08-03',
      lengthMm: lengthMm,
      method: method,
    );

Resolution _unwrap(Result<Resolution> r) => (r as Ok<Resolution>).value;

void main() {
  test('EvaluateCatchUseCase decides a species with a rule and a reading', () async {
    final Resolution resolution = _unwrap(
      await _useCase(rules: <Rule>[_minimumRule()])(
        _question(lengthMm: 34, method: MeasurementMethod.shellLength),
      ),
    );

    // The baseline the whole product is.
    expect(resolution, isA<Decided>());
    final Finding headline = (resolution as Decided).headline;
    expect(headline.kind, FindingKind.minSize);
    expect(headline.outcome, FindingOutcome.fails);
  });

  test('EvaluateCatchUseCase carries the reading and its method unchanged', () async {
    final Resolution resolution = _unwrap(
      await _useCase(rules: <Rule>[_minimumRule()])(
        _question(lengthMm: 34, method: MeasurementMethod.shellLength),
      ),
    );

    // A reading altered between the ruler and the engine is a wrong verdict
    // with a plausible number on it.
    final finding = (resolution as Decided).headline as SizeFinding;
    expect(finding.measuredMm, 34);
    expect(finding.measuredMethod, MeasurementMethod.shellLength);
  });

  test('EvaluateCatchUseCase leaves a size open when nothing was measured', () async {
    final Resolution resolution = _unwrap(
      await _useCase(rules: <Rule>[_minimumRule()])(_question()),
    );

    // An unmeasured fish has not met the minimum; nobody has checked.
    expect((resolution as Decided).headline.outcome, FindingOutcome.indeterminate);
  });

  test('EvaluateCatchUseCase answers NoRuleFound for a species with no rule row', () async {
    final Resolution resolution = _unwrap(await _useCase()(_question(lengthMm: 34)));

    // The state the shipped pack is in today, and it must be reachable
    // honestly rather than by accident.
    expect(resolution, isA<NoRuleFound>());
    expect(resolution.citations, isNotEmpty, reason: 'an absence stays cited');
  });

  test('EvaluateCatchUseCase answers UnknownSpecies for an id this pack lacks', () async {
    final Resolution resolution = _unwrap(
      await _useCase(species: const <domain.Species>[])(_question(speciesId: 999)),
    );

    // Different from NoRuleFound: "we have never heard of this fish" and
    // "nobody has transcribed this zone yet" send the reader to different
    // places.
    expect(resolution, isA<UnknownSpecies>());
  });

  test('EvaluateCatchUseCase evaluates an expired rule rather than dropping it', () async {
    final Resolution resolution = _unwrap(
      await _useCase(rules: <Rule>[_minimumRule(validTo: '2020-01-01')])(
        _question(lengthMm: 34, method: MeasurementMethod.shellLength),
      ),
    );

    // Invariant 5 at the seam, not only at the surface.
    expect(resolution, isA<Decided>());
    expect(resolution.isExpired, isTrue);
  });

  test('EvaluateCatchUseCase reports a broken read as a failure', () async {
    final Result<Resolution> result = await _useCase(env: StoreEnv.storeUnavailable)(
      _question(lengthMm: 34),
    );

    // "No rule recorded for this species here" is a legal statement; a file
    // that would not open is not one.
    expect(result, isA<Failure<Resolution>>());
  });

  test('EvaluateCatchUseCase refuses a place whose water never narrowed', () async {
    const open = EvaluationScope(
      jurisdictionCode: 'ES-GA',
      zoneCode: 'rias-baixas',
      zonePath: <String>['ES-GA'],
      water: WaterKind.both,
      authorityKey: 'jurisdiction.es_ga.authority',
      defaultLocale: 'gl',
      packVersion: '2026.08.0',
      checkedOn: '2026-08-12',
    );

    // The engine asserts a request is salt or fresh, and correctly: `both` is a
    // property of a RULE, and a `both` request would make the
    // fresh-drops-in-salt guard meaningless.
    final Result<Resolution> result = await _useCase(rules: <Rule>[_minimumRule()])(
      const CatchQuestion(scope: open, speciesId: 7, on: '2026-08-03', lengthMm: 34),
    );

    expect(result, isA<Failure<Resolution>>());
  });

  test('CatchQuestion compares by value so an unchanged drag asks nothing', () {
    // A family key with identity `==` re-reads reference.db on every frame of a
    // ruler drag.
    expect(_question(lengthMm: 34), _question(lengthMm: 34));
    expect(_question(lengthMm: 34), isNot(_question(lengthMm: 35)));
  });
}
