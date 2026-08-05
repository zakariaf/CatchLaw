import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/repositories/species_recent_repository.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/recent_species_entry.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/domain/models/species_search_hit.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/check/check_screen.dart';
import 'package:catchlaw/ui/core/ui/lonja_masthead.dart';
import 'package:catchlaw/ui/core/ui/lonja_search_field.dart';
import 'package:catchlaw/ui/zones/zone_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Result, ZoneKind;

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
  List<RecentSpeciesEntry> recents = const <RecentSpeciesEntry>[],
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
        speciesRecentRepositoryProvider.overrideWithValue(_FakeRecents(recents)),
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
      expect(find.byType(LonjaSearchField), findsNothing);
    });

    testWidgets('opens straight to the search once a place is stored', (WidgetTester tester) async {
      await _pumpCheck(tester, jurisdictionCode: 'ES-GA');

      // No splash, no login, no onboarding, no what's-new: §3 budgets five
      // seconds from pocket to verdict and every screen between spends it.
      expect(find.byType(LonjaSearchField), findsOneWidget);
      expect(find.byType(ZonePickerScreen), findsNothing);
    });

    testWidgets('prints the masthead above the search box', (WidgetTester tester) async {
      await _pumpCheck(tester, jurisdictionCode: 'ES-GA');

      // The page opens with its masthead, the way the mockup's does: the place
      // the answers below are for is read before anything is typed into them.
      expect(
        tester.getBottomLeft(find.byType(LonjaMasthead)).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(LonjaSearchField)).dy),
      );
    });

    testWidgets('prints the search box above the recents strip', (WidgetTester tester) async {
      await _pumpCheck(
        tester,
        jurisdictionCode: 'ES-GA',
        recents: const <RecentSpeciesEntry>[
          RecentSpeciesEntry(
            speciesId: 7,
            useCount: 3,
            lastUsedAt: '2026-08-12',
            displayName: 'Ameixa babosa',
            silhouetteAsset: 'assets/sil/venerupis.svg',
          ),
        ],
      );

      // The mockup's order, and the app's was the other way round: the entry
      // line is the screen's one instrument, and the strip is the shortcut
      // under it.
      expect(
        tester.getBottomLeft(find.byType(LonjaSearchField)).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.text('Recent here')).dy),
      );
    });

    testWidgets('stamps the pack version in the masthead meta block', (WidgetTester tester) async {
      await _pumpCheck(tester, jurisdictionCode: 'ES-GA');

      // Which printing of the rules this device is holding — two devices side
      // by side at the quay differ in exactly this line, and it is set at the
      // trailing margin of the mast, opposite the place it qualifies.
      expect(find.text('2026.08.0'), findsOneWidget);
      expect(
        tester.getBottomRight(find.text('2026.08.0')).dx,
        greaterThan(tester.getBottomRight(find.text('rias-baixas')).dx),
      );
      // The place is printed once. The mast carries the code as the place line
      // until it resolves to a display name, so the meta block leaves its own
      // code line empty rather than printing the same fact twice.
      expect(find.text('rias-baixas'), findsOneWidget);
    });

    testWidgets('stands on one scaffold', (WidgetTester tester) async {
      await _pumpCheck(tester, jurisdictionCode: 'ES-GA');

      // A screen embedded whole inside another paid for two scaffolds and two
      // safe areas, and the second one inset the body a second time.
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('carries no standing label over the entry line', (WidgetTester tester) async {
      await _pumpCheck(tester, jurisdictionCode: 'ES-GA');

      // The mockup's search box has no label: the placeholder inside it names
      // the field, and the screen reader is told by the field's own semantics
      // rather than by a line of chrome the sighted reader has to step over.
      expect(find.text('Species'), findsNothing);
      expect(find.bySemanticsLabel('Species'), findsOneWidget);
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

/// The recents this screen is pumped with, and nothing else.
///
/// `RecentsStrip` has its own suite, so the seam is filled rather than faked in
/// detail: what these rows are for here is the ORDER they sit in.
final class _FakeRecents implements SpeciesRecentRepository {
  const _FakeRecents(this._entries);

  final List<RecentSpeciesEntry> _entries;

  @override
  Stream<List<RecentSpeciesEntry>> watchRecents({
    required String jurisdictionCode,
    required String zoneCode,
    int limit = 6,
  }) => Stream<List<RecentSpeciesEntry>>.value(_entries);

  @override
  Future<Result<void>> recordUse(
    int speciesId, {
    required String jurisdictionCode,
    required String zoneCode,
    required String at,
  }) async => const Result<void>.ok(null);
}
