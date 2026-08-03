import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/domain/models/species_search_hit.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/check/check_screen.dart';
import 'package:catchlaw/ui/species/widgets/species_search_screen.dart';
import 'package:catchlaw/ui/zones/zone_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show ZoneKind;

import '../../../testing/fakes/fake_content_string_repository.dart';
import '../../../testing/fakes/fake_reference_repository.dart';
import '../../../testing/fakes/fake_settings_repository.dart';
import '../../../testing/fakes/fake_species_search_repository.dart';
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

const Zone _riasBaixas = Zone(
  id: 10,
  jurisdictionId: 1,
  code: 'rias-baixas',
  nameKey: 'zone.es_ga.rias_baixas',
  waterType: WaterKind.salt,
  zoneKind: ZoneKind.region,
);

Future<void> _pumpCheck(
  WidgetTester tester, {
  String? jurisdictionCode,
  StoreEnv env = StoreEnv.healthy,
}) async {
  final settings = FakeSettingsRepository();
  if (jurisdictionCode != null) {
    await settings.setActivePlace(jurisdictionCode: jurisdictionCode, zoneCode: 'rias-baixas');
  }
  final reference = FakeReferenceRepository(env: env)..jurisdictionRows.add(_galicia);
  reference.zoneRows[1] = const <Zone>[_riasBaixas];

  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: <Override>[
        settingsRepositoryProvider.overrideWithValue(settings),
        referenceRepositoryProvider.overrideWithValue(reference),
        speciesSearchRepositoryProvider.overrideWithValue(
          FakeSpeciesSearchRepository(const <String, List<SpeciesSearchHit>>{}),
        ),
        contentStringRepositoryProvider.overrideWithValue(
          FakeContentStringRepository(const <String, Map<String, String>>{
            'jurisdiction.es_ga.authority': <String, String>{'en': 'Xunta de Galicia'},
          }),
        ),
      ],
      child: MaterialApp(
        theme: resolveLonjaTheme(skin: LonjaSkin.paper, gloved: false),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CheckScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('CheckScreen', () {
    testWidgets('asks where he is when no place is stored', (WidgetTester tester) async {
      await _pumpCheck(tester);

      // Every answer behind this screen is answered against a jurisdiction, and
      // a species picked before one is chosen is a tap that leads nowhere.
      expect(find.byType(ZonePickerScreen), findsOneWidget);
      expect(find.byType(SpeciesSearchScreen), findsNothing);
    });

    testWidgets('opens straight to the search once a place is stored', (WidgetTester tester) async {
      await _pumpCheck(tester, jurisdictionCode: 'ES-GA');

      // No splash, no login, no onboarding, no what's-new: §3 budgets five
      // seconds from pocket to verdict and every screen between spends it.
      expect(find.byType(SpeciesSearchScreen), findsOneWidget);
      expect(find.byType(ZonePickerScreen), findsNothing);
    });

    testWidgets('asks again when the pack no longer carries the stored place', (
      WidgetTester tester,
    ) async {
      await _pumpCheck(tester, jurisdictionCode: 'AE-RK');

      // A content update that dropped it, or a user.db restored from an export
      // that predates it. He is asked rather than answered against a
      // jurisdiction that is not there.
      expect(find.byType(ZonePickerScreen), findsOneWidget);
    });

    testWidgets('asks where he is when the place could not be read', (WidgetTester tester) async {
      await _pumpCheck(tester, jurisdictionCode: 'ES-GA', env: StoreEnv.storeUnavailable);

      // A place that could not be read is not a place that was never chosen,
      // and the picker states the difference rather than the search box
      // pretending everything is fine.
      expect(find.byType(ZonePickerScreen), findsOneWidget);
    });
  });
}
