import 'package:catchlaw/app.dart';
import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/repositories/species_recent_repository.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/recent_species_entry.dart';
import 'package:catchlaw/domain/models/species.dart' as domain;
import 'package:catchlaw/domain/models/species_account.dart';
import 'package:catchlaw/domain/models/species_search_hit.dart';
import 'package:catchlaw/ui/result/widgets/result_verdict_panel.dart';
import 'package:catchlaw/ui/species/widgets/species_detail_screen.dart';
import 'package:catchlaw/ui/zones/zone_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart';

import '../../../testing/fakes/fake_content_string_repository.dart';
import '../../../testing/fakes/fake_reference_repository.dart';
import '../../../testing/fakes/fake_settings_repository.dart';
import '../../../testing/fakes/fake_species_account_repository.dart';
import '../../../testing/fakes/fake_species_search_repository.dart';

/// The walk this whole release exists to make possible.
///
/// **From a cold launch to a cited verdict, with no code between the taps.**
/// Ten epics built an engine, a database, six locales, a theme, a ruler and a
/// result surface, and until E12/T08 nothing joined them. This is the test that
/// says they are joined: if it passes, v1 is real.
///
/// A widget-level walk and not `integration_test`. That package pulls
/// `sync_http`, `webdriver` and `flutter_driver` into the dependency graph of an
/// app whose central claim is that it has no network code — the edge was
/// inspected and reverted once already, and it is E21's decision to take, not
/// this task's. What is lost is the real device; what is kept is every widget,
/// every provider, every repository seam and the engine itself.
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

const Rule _minimum = Rule(
  id: 1,
  jurisdictionId: 1,
  zoneId: null,
  speciesId: 7,
  waterType: WaterType.salt,
  citation: _xunta,
  citationLineageId: 'es-ga-orde-2012-07-27',
  validFrom: '2012-08-06',
  minSizeMm: 38,
  measurementMethod: MeasurementMethod.shellLength,
);

Future<void> _launch(WidgetTester tester, {String? place}) async {
  final settings = FakeSettingsRepository();
  if (place != null) {
    await settings.setActivePlace(jurisdictionCode: place, zoneCode: 'rias-baixas');
  }
  final reference = FakeReferenceRepository(
    species: const <domain.Species>[_ameixa],
    rules: <Rule>[_minimum],
  )..jurisdictionRows.add(_galicia);
  reference.zoneRows[1] = const <domain.Zone>[_riasBaixas];

  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: <Override>[
        settingsRepositoryProvider.overrideWithValue(settings),
        referenceRepositoryProvider.overrideWithValue(reference),
        speciesSearchRepositoryProvider.overrideWithValue(
          FakeSpeciesSearchRepository(const <String, List<SpeciesSearchHit>>{
            'ameixa': <SpeciesSearchHit>[
              SpeciesSearchHit(
                species: _ameixa,
                matchedName: 'Ameixa babosa',
                matchedLocale: 'gl',
                isPrimaryName: true,
              ),
            ],
          }, count: 1),
        ),
        speciesAccountRepositoryProvider.overrideWithValue(
          FakeSpeciesAccountRepository(<int, SpeciesAccount>{
            7: SpeciesAccount(
              species: _ameixa,
              primaryName: 'Ameixa babosa',
              familyName: 'Ameixas',
              otherNames: const <domain.SpeciesName>[],
              isProtectedAnywhere: false,
            ),
          }),
        ),
        // The recents write fires on every open, so the seam has to be filled
        // even though this walk never reads it back.
        speciesRecentRepositoryProvider.overrideWithValue(_NoRecents()),
        contentStringRepositoryProvider.overrideWithValue(
          FakeContentStringRepository(const <String, Map<String, String>>{
            'jurisdiction.es_ga.authority': <String, String>{
              'en': 'Xunta de Galicia — Department of the Sea',
              'gl': 'Xunta de Galicia — Consellería do Mar',
            },
            'measurement.shl.name': <String, String>{'en': 'Shell length', 'gl': 'Lonxitude'},
          }),
        ),
      ],
      child: const CatchlawApp(locale: Locale('en')),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a cold launch with no place asks where he is', (WidgetTester tester) async {
    await _launch(tester);

    // The first ten seconds of every install, and the only question the app
    // asks before it will answer anything.
    expect(find.byType(ZonePickerScreen), findsOneWidget);
  });

  testWidgets('the place is asked once and remembered', (WidgetTester tester) async {
    await _launch(tester);

    await tester.tap(find.text('Spain'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ES-GA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use this place'));
    await tester.pumpAndSettle();

    // Straight to the search: no confirmation screen, no "you're all set".
    expect(find.byType(ZonePickerScreen), findsNothing);
    expect(find.text('Species'), findsWidgets);
  });

  testWidgets('a cold launch with a place opens on the search', (WidgetTester tester) async {
    await _launch(tester, place: 'ES-GA');

    // No splash, no login, no onboarding, no what's-new.
    expect(find.text('Species'), findsWidgets);
    expect(find.byType(ZonePickerScreen), findsNothing);
  });

  testWidgets('search, tap, and the verdict is on screen with its instrument', (
    WidgetTester tester,
  ) async {
    await _launch(tester, place: 'ES-GA');

    await tester.enterText(find.byType(TextField).first, 'ameixa');
    await tester.pumpAndSettle();
    expect(find.text('Ameixa babosa'), findsWidgets);

    await tester.tap(find.text('Ameixa babosa').first);
    await tester.pumpAndSettle();

    // The whole product, in one assertion: a species page carrying a stamp
    // that names the instrument behind it.
    expect(find.byType(SpeciesDetailScreen), findsOneWidget);
    expect(find.byType(ResultVerdictPanel), findsNothing, reason: 'nothing measured yet');
    expect(find.textContaining('Not measured'), findsWidgets);
    expect(find.textContaining('Orde do 27 de xullo de 2012'), findsWidgets);
  });

  testWidgets('the answer names the authority that published it', (WidgetTester tester) async {
    await _launch(tester, place: 'ES-GA');
    await tester.enterText(find.byType(TextField).first, 'ameixa');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ameixa babosa').first);
    await tester.pumpAndSettle();

    // A generic "not legal advice" tells a fisher nothing about who to ask.
    expect(find.textContaining('Department of the Sea'), findsWidgets);
    expect(find.textContaining('not legal advice'), findsWidgets);
  });

  testWidgets('the unmeasured answer is an open question and never a pass', (
    WidgetTester tester,
  ) async {
    await _launch(tester, place: 'ES-GA');
    await tester.enterText(find.byType(TextField).first, 'ameixa');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ameixa babosa').first);
    await tester.pumpAndSettle();

    // An unmeasured fish has not met the minimum; nobody has checked. The
    // number is still on screen — invariant 5's sibling: an answer that cannot
    // be reached still shows what the instrument requires.
    expect(find.textContaining('Meets the minimum'), findsNothing);
    expect(find.textContaining('Not measured'), findsWidgets);
    expect(find.textContaining('38\u00A0mm'), findsWidgets);
  });
}

/// A recents repository that records nothing and returns nothing.
///
/// The walk opens a species, which records a use. Nothing here reads it back —
/// `RecentsStrip` has its own test — so the seam is filled rather than faked in
/// detail.
final class _NoRecents implements SpeciesRecentRepository {
  @override
  Stream<List<RecentSpeciesEntry>> watchRecents({
    required String jurisdictionCode,
    required String zoneCode,
    int limit = 6,
  }) => const Stream<List<RecentSpeciesEntry>>.empty();

  @override
  Future<Result<void>> recordUse(
    int speciesId, {
    required String jurisdictionCode,
    required String zoneCode,
    required String at,
  }) async => const Result<void>.ok(null);
}
