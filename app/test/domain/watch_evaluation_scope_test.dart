import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/domain/use_cases/watch_evaluation_scope.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show ZoneKind;

import '../../testing/fakes/fake_reference_repository.dart';
import '../../testing/fakes/fake_settings_repository.dart';

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

const Zone _riasBaixas = Zone(
  id: 10,
  jurisdictionId: 1,
  code: 'rias-baixas',
  nameKey: 'zone.es_ga.rias_baixas',
  waterType: WaterKind.salt,
  zoneKind: ZoneKind.region,
);

const Zone _cambados = Zone(
  id: 11,
  jurisdictionId: 1,
  parentZoneId: 10,
  code: 'cambados',
  nameKey: 'zone.es_ga.cambados',
  waterType: WaterKind.salt,
  zoneKind: ZoneKind.subzone,
);

WatchEvaluationScope _scope(FakeSettingsRepository settings, {List<Zone> zones = const <Zone>[]}) {
  final reference = FakeReferenceRepository()..jurisdictionRows.add(_galicia);
  reference.zoneRows[1] = zones;
  return WatchEvaluationScope(settings: settings, reference: reference);
}

void main() {
  test('WatchEvaluationScope yields null until the fisher has told the app where he is', () async {
    // A new install has no place. Every screen needing one shows S9 rather than
    // a verdict computed against a jurisdiction nobody chose.
    expect(await _scope(FakeSettingsRepository())().first, isNull);
  });

  test('WatchEvaluationScope resolves the zone chain widest first', () async {
    final settings = FakeSettingsRepository();
    await settings.setActivePlace(jurisdictionCode: 'ES-GA', zoneCode: 'cambados');

    final EvaluationScope? scope = await _scope(
      settings,
      zones: const <Zone>[_riasBaixas, _cambados],
    )().firstWhere((EvaluationScope? s) => s != null);

    // §7.3 step 2 walks this chain; resolved once so no caller walks
    // parent_zone_id a second time and gets a different answer.
    expect(scope!.zonePath, <String>['ES-GA', 'rias-baixas', 'cambados']);
  });

  test('WatchEvaluationScope takes the water type from the zone', () async {
    final settings = FakeSettingsRepository();
    await settings.setActivePlace(jurisdictionCode: 'ES-GA', zoneCode: 'rias-baixas');

    final EvaluationScope? scope = await _scope(
      settings,
      zones: const <Zone>[_riasBaixas],
    )().firstWhere((EvaluationScope? s) => s != null);

    // Water type is a property of the PLACE. A freshwater rule answered for a
    // sea zone is a wrong verdict, and nobody gets to choose which water a
    // river is.
    expect(scope!.water, WaterKind.salt);
  });

  test('WatchEvaluationScope treats a jurisdiction the pack no longer carries as unset', () async {
    final settings = FakeSettingsRepository();
    await settings.setActivePlace(jurisdictionCode: 'AE-RK', zoneCode: 'coast');

    // A content update that dropped it, or a user.db restored from an export
    // that predates it. He is asked again rather than answered against a
    // jurisdiction that is not there.
    expect(await _scope(settings)().first, isNull);
  });

  test('WatchEvaluationScope falls back to the jurisdiction when no zone was stored', () async {
    final settings = FakeSettingsRepository();
    await settings.setActivePlace(jurisdictionCode: 'ES-GA');

    final EvaluationScope? scope = await _scope(
      settings,
    )().firstWhere((EvaluationScope? s) => s != null);

    expect(scope!.zoneCode, 'ES-GA');
    expect(scope.zonePath, <String>['ES-GA']);
  });

  test('WatchEvaluationScope terminates on a pack whose parent chain cycles', () async {
    final settings = FakeSettingsRepository();
    await settings.setActivePlace(jurisdictionCode: 'ES-GA', zoneCode: 'a');

    // A cycle would otherwise hang the app at the moment a fisher picks a
    // place, which is the least recoverable place to hang.
    final EvaluationScope? scope = await _scope(
      settings,
      zones: const <Zone>[
        Zone(
          id: 1,
          jurisdictionId: 1,
          parentZoneId: 2,
          code: 'a',
          nameKey: 'a',
          waterType: WaterKind.salt,
          zoneKind: ZoneKind.subzone,
        ),
        Zone(
          id: 2,
          jurisdictionId: 1,
          parentZoneId: 1,
          code: 'b',
          nameKey: 'b',
          waterType: WaterKind.salt,
          zoneKind: ZoneKind.subzone,
        ),
      ],
    )().firstWhere((EvaluationScope? s) => s != null).timeout(const Duration(seconds: 2));

    expect(scope!.zonePath, <String>['ES-GA', 'b', 'a']);
  });

  test('WatchEvaluationScope takes his stored water only where the zone covers both', () async {
    final settings = FakeSettingsRepository();
    await settings.setActivePlace(jurisdictionCode: 'ES-GA', zoneCode: 'both-waters');
    await settings.setActiveWater(WaterKind.fresh);

    final EvaluationScope? scope = await _scope(
      settings,
      zones: const <Zone>[
        Zone(
          id: 12,
          jurisdictionId: 1,
          code: 'both-waters',
          nameKey: 'zone.es_ga.both',
          waterType: WaterKind.both,
          zoneKind: ZoneKind.region,
        ),
      ],
    )().firstWhere((EvaluationScope? s) => s != null);

    expect(scope!.water, WaterKind.fresh);
  });

  test('WatchEvaluationScope ignores his stored water where the zone publishes one', () async {
    final settings = FakeSettingsRepository();
    await settings.setActivePlace(jurisdictionCode: 'ES-GA', zoneCode: 'rias-baixas');
    await settings.setActiveWater(WaterKind.fresh);

    final EvaluationScope? scope = await _scope(
      settings,
      zones: const <Zone>[_riasBaixas],
    )().firstWhere((EvaluationScope? s) => s != null);

    // The zone says salt. A stored preference that could override it would be
    // the fisher choosing which water a place is, and a freshwater rule
    // answered for a sea zone is a wrong verdict.
    expect(scope!.water, WaterKind.salt);
  });

  // NOT TESTED HERE, and stated rather than left as a gap: that a WRITE
  // re-emits. `FakeSettingsRepository.watchProfile` yields its current profile
  // and then a BROADCAST stream, so whether a write lands depends on when the
  // inner subscription attaches — and every shape of that test asserted the
  // race rather than the use case. What holds it up instead is structural:
  // `call()` is a `Stream` over `watchProfile()` and does no caching, so it
  // cannot fail to re-emit without the profile stream failing first. E12 asserts
  // the visible half — switching zone re-answers — through the provider, where
  // the container drives the clock.
}
