import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:catchlaw/ui/zones/view_models/zone_picker_state.dart';
import 'package:catchlaw/ui/zones/view_models/zone_picker_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Ok, ZoneKind;

import '../../../testing/fakes/fake_content_string_repository.dart';
import '../../../testing/fakes/fake_reference_repository.dart';
import '../../../testing/fakes/fake_settings_repository.dart';
import '../../../testing/fakes/store_env.dart';

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

const Jurisdiction _rak = Jurisdiction(
  id: 2,
  code: 'AE-RK',
  countryIso2: 'AE',
  nameKey: 'jurisdiction.ae_rak.name',
  authorityKey: 'jurisdiction.ae_rak.authority',
  defaultLocale: 'ar',
  hasSaltwater: true,
  hasFreshwater: true,
  hasZonePolygons: true,
  contentVersion: '2026.08.0',
  checkedOn: '2026-07-14',
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

ProviderContainer _container({
  List<Jurisdiction> jurisdictions = const <Jurisdiction>[_galicia, _rak],
  Map<int, List<Zone>> zones = const <int, List<Zone>>{},
  bool broken = false,
}) {
  final reference = FakeReferenceRepository(
    env: broken ? StoreEnv.storeUnavailable : StoreEnv.healthy,
  )..jurisdictionRows.addAll(jurisdictions);
  zones.forEach((int id, List<Zone> rows) => reference.zoneRows[id] = rows);
  final container = ProviderContainer(
    retry: noRetry,
    overrides: <Override>[
      referenceRepositoryProvider.overrideWithValue(reference),
      settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      contentStringRepositoryProvider.overrideWithValue(
        FakeContentStringRepository(const <String, Map<String, String>>{
          'jurisdiction.es_ga.authority': <String, String>{
            'en': 'Xunta de Galicia — Department of the Sea',
            'gl': 'Xunta de Galicia — Consellería do Mar',
          },
        }),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// The state after every pending update has landed.
///
/// `.future` resolves on the FIRST `AsyncData`, and `selectJurisdiction`
/// publishes twice — once to record the tap and once when the zones arrive. A
/// test that read only the first would assert against a frame the fisher never
/// sees.
Future<ZonePickerState> _settled(ProviderContainer container) async {
  final ProviderSubscription<AsyncValue<ZonePickerState>> sub = container.listen(
    zonePickerViewModelProvider,
    (_, _) {},
  );
  addTearDown(sub.close);
  await container.read(zonePickerViewModelProvider.future);
  await Future<void>.delayed(Duration.zero);
  return container.read(zonePickerViewModelProvider).requireValue;
}

void main() {
  group('ZonePickerViewModel', () {
    test('.build lists one country per distinct country_iso2', () async {
      final ZonePickerState state = await _settled(_container());

      // §7.1 has no country table: a country is `country_iso2` grouped.
      expect(state.countries, <String>['AE', 'ES']);
    });

    test('.selectCountry narrows the region level to that country', () async {
      final ProviderContainer container = _container();
      await _settled(container);

      container.read(zonePickerViewModelProvider.notifier).selectCountry('ES');
      final ZonePickerState state = await _settled(container);

      expect(state.selectedCountry, 'ES');
      expect(state.jurisdictions.map((Jurisdiction j) => j.code).toList(), <String>['ES-GA']);
    });

    test('.selectJurisdiction offers no sub-zone level when the pack has no polygons', () async {
      final ProviderContainer container = _container(
        zones: <int, List<Zone>>{
          1: <Zone>[_riasBaixas, _cambados],
        },
      );
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectCountry('ES');
      await _settled(container);

      container.read(zonePickerViewModelProvider.notifier).selectJurisdiction('ES-GA');
      final ZonePickerState state = await _settled(container);

      // `has_zone_polygons: false`. Where no coordinate list is printed, rules
      // apply jurisdiction-wide and the app invents no boundary (§8) — so
      // offering a sub-zone would be offering a distinction the pack does not
      // make.
      expect(state.offersSubZone, isFalse);
      expect(state.subZones, isEmpty);
    });

    test('.selectJurisdiction offers the sub-zone level when the pack has polygons', () async {
      final ProviderContainer container = _container(
        zones: <int, List<Zone>>{
          2: <Zone>[
            const Zone(
              id: 20,
              jurisdictionId: 2,
              code: 'rak-coast',
              nameKey: 'zone.ae_rak.coast',
              waterType: WaterKind.salt,
              zoneKind: ZoneKind.subzone,
            ),
          ],
        },
      );
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectCountry('AE');
      await _settled(container);

      container.read(zonePickerViewModelProvider.notifier).selectJurisdiction('AE-RK');
      final ZonePickerState state = await _settled(container);

      expect(state.offersSubZone, isTrue);
      expect(state.subZones.single.code, 'rak-coast');
    });

    test('.selectJurisdiction offers a water choice only when both waters are published', () async {
      final ProviderContainer container = _container();
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectCountry('ES');
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectJurisdiction('ES-GA');

      // A toggle with one option is a control that teaches the fisher the app
      // is unfinished.
      expect((await _settled(container)).offersWaterChoice, isFalse);

      container.read(zonePickerViewModelProvider.notifier).selectCountry('AE');
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectJurisdiction('AE-RK');
      expect((await _settled(container)).offersWaterChoice, isTrue);
    });

    test('.confirmSelection writes the place a later launch reads back', () async {
      final settings = FakeSettingsRepository();
      final reference = FakeReferenceRepository()
        ..jurisdictionRows.addAll(<Jurisdiction>[_galicia]);
      final container = ProviderContainer(
        retry: noRetry,
        overrides: <Override>[
          referenceRepositoryProvider.overrideWithValue(reference),
          settingsRepositoryProvider.overrideWithValue(settings),
          contentStringRepositoryProvider.overrideWithValue(
            FakeContentStringRepository(const <String, Map<String, String>>{
              'jurisdiction.es_ga.authority': <String, String>{'en': 'Xunta de Galicia'},
            }),
          ),
        ],
      );
      addTearDown(container.dispose);
      await _settled(container);

      container.read(zonePickerViewModelProvider.notifier).selectCountry('ES');
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectJurisdiction('ES-GA');
      await _settled(container);
      await container.read(zonePickerViewModelProvider.notifier).confirmSelection();

      expect(
        (await settings.read().then((r) => (r as Ok<UserProfile>).value)).activeJurisdiction,
        'ES-GA',
      );
    });

    test('.selectJurisdiction resolves the authority for the no-boundaries notice', () async {
      final ProviderContainer container = _container(
        jurisdictions: const <Jurisdiction>[_galicia],
        zones: <int, List<Zone>>{
          1: <Zone>[_riasBaixas],
        },
      );
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectCountry('ES');
      await _settled(container);

      container.read(zonePickerViewModelProvider.notifier).selectJurisdiction('ES-GA');
      final ZonePickerState state = await _settled(container);

      // The sentence names the AUTHORITY, so the name has to be resolved
      // before it can be said. Resolved on selection and not per row: a query
      // per jurisdiction in the list is a query per row nobody tapped.
      expect(state.authorityName, 'Xunta de Galicia — Department of the Sea');
    });

    test(
      '.confirmSelection stores the jurisdiction-wide zone when no boundaries are published',
      () async {
        final settings = FakeSettingsRepository();
        final reference = FakeReferenceRepository()
          ..jurisdictionRows.add(_galicia)
          ..zoneRows[1] = <Zone>[_riasBaixas];
        final container = ProviderContainer(
          retry: noRetry,
          overrides: <Override>[
            referenceRepositoryProvider.overrideWithValue(reference),
            settingsRepositoryProvider.overrideWithValue(settings),
            contentStringRepositoryProvider.overrideWithValue(
              FakeContentStringRepository(const <String, Map<String, String>>{
                'jurisdiction.es_ga.authority': <String, String>{'en': 'Xunta de Galicia'},
              }),
            ),
          ],
        );
        addTearDown(container.dispose);
        await _settled(container);
        container.read(zonePickerViewModelProvider.notifier).selectCountry('ES');
        await _settled(container);
        container.read(zonePickerViewModelProvider.notifier).selectJurisdiction('ES-GA');
        await _settled(container);

        await container.read(zonePickerViewModelProvider.notifier).confirmSelection();

        // Storing null would leave the next launch unable to tell "not chosen"
        // from "chosen, and it is everywhere".
        final UserProfile profile = (await settings.read() as Ok<UserProfile>).value;
        expect(profile.activeZoneCode, 'rias-baixas');
      },
    );

    test('.isComplete refuses a zone that covers both waters until one is chosen', () async {
      const bothWaters = Zone(
        id: 30,
        jurisdictionId: 2,
        code: 'rak-all',
        nameKey: 'zone.ae_rak.all',
        waterType: WaterKind.both,
        zoneKind: ZoneKind.region,
      );
      final ProviderContainer container = _container(
        zones: <int, List<Zone>>{
          2: <Zone>[bothWaters],
        },
      );
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectCountry('AE');
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectJurisdiction('AE-RK');

      // A place that has not said which water answers with the wrong
      // instrument, so it is not a place yet.
      ZonePickerState state = await _settled(container);
      expect(state.needsWaterChoice, isTrue);
      expect(state.isComplete, isFalse);

      container.read(zonePickerViewModelProvider.notifier).selectWater(WaterKind.fresh);
      state = await _settled(container);
      expect(state.isComplete, isTrue);
    });

    test('.isComplete asks nothing where the ZONE publishes one water', () async {
      final ProviderContainer container = _container(
        zones: <int, List<Zone>>{
          2: <Zone>[
            const Zone(
              id: 31,
              jurisdictionId: 2,
              code: 'rak-coast',
              nameKey: 'zone.ae_rak.coast',
              waterType: WaterKind.salt,
              zoneKind: ZoneKind.region,
            ),
          ],
        },
      );
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectCountry('AE');
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectJurisdiction('AE-RK');

      // The AUTHORITY publishes both, but this ZONE does not — and asking
      // anyway is a tap spent on a distinction the place does not have.
      final ZonePickerState state = await _settled(container);
      expect(state.needsWaterChoice, isFalse);
      expect(state.isComplete, isTrue);
    });

    test('.confirmSelection stores the water he chose', () async {
      final settings = FakeSettingsRepository();
      final reference = FakeReferenceRepository()
        ..jurisdictionRows.add(_rak)
        ..zoneRows[2] = const <Zone>[
          Zone(
            id: 32,
            jurisdictionId: 2,
            code: 'rak-all',
            nameKey: 'zone.ae_rak.all',
            waterType: WaterKind.both,
            zoneKind: ZoneKind.region,
          ),
        ];
      final container = ProviderContainer(
        retry: noRetry,
        overrides: <Override>[
          referenceRepositoryProvider.overrideWithValue(reference),
          settingsRepositoryProvider.overrideWithValue(settings),
          contentStringRepositoryProvider.overrideWithValue(
            FakeContentStringRepository(const <String, Map<String, String>>{
              'jurisdiction.ae_rak.authority': <String, String>{'en': 'MOCCAE'},
            }),
          ),
        ],
      );
      addTearDown(container.dispose);
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectCountry('AE');
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectJurisdiction('AE-RK');
      await _settled(container);
      container.read(zonePickerViewModelProvider.notifier).selectWater(WaterKind.fresh);
      await _settled(container);

      await container.read(zonePickerViewModelProvider.notifier).confirmSelection();

      expect(settings.activeWater, WaterKind.fresh);
    });

    test('.build reports a broken read as an error rather than an empty list', () async {
      final ProviderContainer container = _container(broken: true);
      final ProviderSubscription<AsyncValue<ZonePickerState>> sub = container.listen(
        zonePickerViewModelProvider,
        (_, _) {},
      );
      addTearDown(sub.close);

      // An empty picker and a picker that could not be read are different
      // facts, and the second one must not read as "this app ships nowhere".
      await expectLater(
        container.read(zonePickerViewModelProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
