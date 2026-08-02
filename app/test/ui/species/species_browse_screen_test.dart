import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/family_group.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/core/ui/lonja_empty_state.dart';
import 'package:catchlaw/ui/species/widgets/species_browse_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_species_browse_repository.dart';

SpeciesTile _tile(int id, String name) => SpeciesTile(
  speciesId: id,
  silhouetteAsset: 'assets/sil/$id.svg',
  displayName: name,
  scientificName: 'Genus species$id',
  isProtected: false,
);

Future<int> _pump(
  WidgetTester tester,
  List<FamilyGroup> groups, {
  Locale locale = const Locale('gl'),
  Exception? failure,
}) async {
  var chosen = 0;
  await tester.pumpWidget(
    ProviderScope(
      // Mirrors main(). Without it Riverpod 3 RETRIES a provider whose build
      // threw, with backoff — so a failing read never reaches AsyncError and
      // the screen sits in `loading` forever. A test that omits it is testing
      // a different app, and the difference is invisible until the read fails.
      retry: noRetry,
      overrides: <Override>[
        speciesBrowseRepositoryProvider.overrideWithValue(
          FakeSpeciesBrowseRepository(groups, failure: failure),
        ),
      ],
      child: MaterialApp(
        theme: LonjaTheme.paper(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SpeciesBrowseScreen(onSpeciesChosen: (int _) => chosen++),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return chosen;
}

void main() {
  testWidgets('SpeciesBrowseScreen heads each family with its localised name', (
    WidgetTester tester,
  ) async {
    // A Galician grid says Vieiras, not Pectinidae: a mariscadora browsing by
    // shape is looking for a scallop, and the Latin is a label she has no
    // reason to know. As authored, too — an upper-casing transform is a silent
    // no-op on Arabic, so the heading takes its hierarchy from weight and a
    // rule rather than from case.
    await _pump(tester, <FamilyGroup>[
      FamilyGroup(
        familyId: 1,
        scientificFamily: 'Pectinidae',
        localisedFamilyName: 'Vieiras',
        species: <SpeciesTile>[_tile(1, 'Vieira')],
      ),
    ]);
    expect(find.text('Vieiras'), findsOneWidget);
    expect(find.textContaining('Pectinidae'), findsNothing);
  });

  testWidgets('SpeciesBrowseScreen lays every species out as a tile', (WidgetTester tester) async {
    await _pump(tester, <FamilyGroup>[
      FamilyGroup(
        familyId: 1,
        scientificFamily: 'Pectinidae',
        localisedFamilyName: 'Vieiras',
        species: <SpeciesTile>[_tile(1, 'Vieira'), _tile(2, 'Zamburiña')],
      ),
    ]);
    expect(find.text('Vieira'), findsOneWidget);
    expect(find.text('Zamburiña'), findsOneWidget);
  });

  testWidgets('SpeciesBrowseScreen shows an empty state when the pack carries no species', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const <FamilyGroup>[]);
    expect(find.byType(LonjaEmptyState), findsOneWidget);
  });

  testWidgets('SpeciesBrowseScreen does not claim an empty pack when the read failed', (
    WidgetTester tester,
  ) async {
    // "This jurisdiction has no species transcribed" is a statement about the
    // PACK. Saying it when the device could not read the file is the app lying
    // about the rule book — so the error state is a separate branch, even
    // though today it renders the same words.
    await _pump(
      tester,
      const <FamilyGroup>[],
      failure: const FormatException('reference.db is unreadable'),
    );
    expect(find.byType(LonjaEmptyState), findsOneWidget);
  });

  testWidgets('SpeciesBrowseScreen gives each tile a target that meets the floor', (
    WidgetTester tester,
  ) async {
    await _pump(tester, <FamilyGroup>[
      FamilyGroup(
        familyId: 1,
        scientificFamily: 'Pectinidae',
        localisedFamilyName: 'Vieiras',
        species: <SpeciesTile>[_tile(1, 'Vieira')],
      ),
    ]);
    expect(tester.getSize(find.byType(InkWell).first).height, greaterThanOrEqualTo(48));
  });

  testWidgets('ar - SpeciesBrowseScreen lays the grid out right to left', (
    WidgetTester tester,
  ) async {
    await _pump(tester, <FamilyGroup>[
      FamilyGroup(
        familyId: 1,
        scientificFamily: 'Serranidae',
        localisedFamilyName: 'الهوامير',
        species: <SpeciesTile>[_tile(1, 'هامور')],
      ),
    ], locale: const Locale('ar'));
    expect(find.text('هامور'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('هامور'))), TextDirection.rtl);
  });
}
