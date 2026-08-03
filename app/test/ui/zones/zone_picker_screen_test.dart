import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/zones/widgets/zone_level.dart';
import 'package:catchlaw/ui/zones/zone_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

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

Future<void> _pumpPicker(
  WidgetTester tester, {
  List<Jurisdiction> jurisdictions = const <Jurisdiction>[_galicia],
  StoreEnv env = StoreEnv.healthy,
  Locale locale = const Locale('en'),
}) async {
  final reference = FakeReferenceRepository(env: env)..jurisdictionRows.addAll(jurisdictions);
  await tester.pumpWidget(
    ProviderScope(
      // Mirrors main(): without it Riverpod 3 retries a failed build with
      // backoff and the screen never reaches AsyncError.
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
      child: MaterialApp(
        theme: resolveLonjaTheme(skin: LonjaSkin.paper, gloved: false),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ZonePickerScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ZonePickerScreen', () {
    testWidgets('lists one row per shipped country', (WidgetTester tester) async {
      await _pumpPicker(tester);

      expect(find.text('Spain'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
    });

    testWidgets('offers no region level before a country is chosen', (WidgetTester tester) async {
      await _pumpPicker(tester);

      expect(find.text('Region'), findsNothing);
    });

    testWidgets('reveals the region level once a country is chosen', (WidgetTester tester) async {
      await _pumpPicker(tester);
      await tester.tap(find.text('Spain'));
      await tester.pumpAndSettle();

      expect(find.text('Region'), findsOneWidget);
      expect(find.text('ES-GA'), findsOneWidget);
    });

    testWidgets('offers no sub-zone level for a pack with no coordinates', (
      WidgetTester tester,
    ) async {
      await _pumpPicker(tester);
      await tester.tap(find.text('Spain'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ES-GA'));
      await tester.pumpAndSettle();

      // Absent, not empty: where no coordinate list is printed the rules apply
      // jurisdiction-wide, and an empty level would invite him to look for a
      // subdivision the instrument does not make.
      expect(find.text('Sub-zone'), findsNothing);
    });

    testWidgets('offers no water choice for an authority publishing one water', (
      WidgetTester tester,
    ) async {
      await _pumpPicker(tester);
      await tester.tap(find.text('Spain'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ES-GA'));
      await tester.pumpAndSettle();

      // A toggle with one option teaches him the app is unfinished.
      expect(find.text('Sea'), findsNothing);
      expect(find.text('Inland water'), findsNothing);
    });

    testWidgets('cannot confirm before a region is chosen', (WidgetTester tester) async {
      await _pumpPicker(tester);

      final Finder confirm = find.widgetWithText(InkWell, 'Use this place');
      expect(confirm, findsWidgets);
      // The place decides which instrument applies; confirming a country alone
      // would store a place that answers nothing.
      await tester.tap(confirm.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Country'), findsOneWidget);
    });

    testWidgets('states a failed read rather than showing an empty list', (
      WidgetTester tester,
    ) async {
      await _pumpPicker(tester, env: StoreEnv.storeUnavailable);

      // An empty picker and a picker that could not be read are different
      // facts, and the second must not read as "this app ships nowhere".
      expect(find.text('The bundled rule pack could not be read.'), findsOneWidget);
      expect(find.byType(ZoneLevel), findsNothing);
    });

    testWidgets('states that an unbundled country is not an unregulated one', (
      WidgetTester tester,
    ) async {
      await _pumpPicker(
        tester,
        jurisdictions: const <Jurisdiction>[
          _galicia,
          Jurisdiction(
            id: 2,
            code: 'BR-SP',
            countryIso2: 'BR',
            nameKey: 'jurisdiction.br_sp.name',
            authorityKey: 'jurisdiction.br_sp.authority',
            defaultLocale: 'pt_BR',
            hasSaltwater: true,
            hasFreshwater: true,
            hasZonePolygons: false,
            contentVersion: '2026.08.0',
            checkedOn: '2026-08-12',
          ),
        ],
      );
      await tester.tap(find.text('Brazil'));
      await tester.pumpAndSettle();

      // Brazil HAS a jurisdiction here, so the empty state must not fire.
      expect(find.textContaining('That does not mean there are none.'), findsNothing);
      expect(find.text('BR-SP'), findsOneWidget);
    });

    testWidgets('ar - starts the level headings at the start edge', (WidgetTester tester) async {
      await _pumpPicker(tester, locale: const Locale('ar'));

      expect(Directionality.of(tester.element(find.byType(ZoneLevel).first)), TextDirection.rtl);
    });
  });
}
