import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/family_group.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/core/ui/lonja_empty_state.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
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
  testWidgets('SpeciesBrowseScreen heads each family with its localised name and its count', (
    WidgetTester tester,
  ) async {
    // A Galician grid says Vieiras, not Pectinidae: a mariscadora browsing by
    // shape is looking for a scallop, and the Latin is a label she has no
    // reason to know. As authored, too — an upper-casing transform is a silent
    // no-op on Arabic, so the heading takes its hierarchy from weight and a
    // rule rather than from case. The count beside it is what says how deep
    // the plan runs before the plate is scrolled.
    await _pump(tester, <FamilyGroup>[
      FamilyGroup(
        familyId: 1,
        scientificFamily: 'Pectinidae',
        localisedFamilyName: 'Vieiras',
        species: <SpeciesTile>[_tile(1, 'Vieira'), _tile(2, 'Zamburiña')],
      ),
    ]);
    expect(find.text('Vieiras · 2'), findsOneWidget);
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

  testWidgets('SpeciesBrowseScreen sets the binomial under the name it belongs to', (
    WidgetTester tester,
  ) async {
    // Small and last, and present: the local name is what she recognises, and
    // the binomial is the one name that is the same in every port.
    await _pump(tester, <FamilyGroup>[
      FamilyGroup(
        familyId: 1,
        scientificFamily: 'Pectinidae',
        localisedFamilyName: 'Vieiras',
        species: <SpeciesTile>[_tile(1, 'Vieira')],
      ),
    ]);
    expect(find.text('Genus species1'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Vieira')).dy,
      lessThan(tester.getTopLeft(find.text('Genus species1')).dy),
    );
  });

  testWidgets('SpeciesBrowseScreen stamps its bar with what the page draws', (
    WidgetTester tester,
  ) async {
    await _pump(tester, <FamilyGroup>[
      FamilyGroup(
        familyId: 1,
        scientificFamily: 'Pectinidae',
        localisedFamilyName: 'Scallops',
        species: <SpeciesTile>[_tile(1, 'Vieira'), _tile(2, 'Zamburiña')],
      ),
    ], locale: const Locale('en'));
    expect(
      find.descendant(of: find.byType(LonjaScreenBar), matching: find.text('2 species')),
      findsOneWidget,
    );
  });

  testWidgets('SpeciesBrowseScreen holds a long family to one row until it is opened', (
    WidgetTester tester,
  ) async {
    // Four body plans comparable at a glance is the whole of S6. An
    // eleven-species family that floods the screen buries the next plan under
    // a scroll nobody performs at 05:40 — so the plate offers the rest, and
    // reaches all of it.
    await _pump(tester, <FamilyGroup>[
      FamilyGroup(
        familyId: 1,
        scientificFamily: 'Sparidae',
        localisedFamilyName: 'Breams',
        species: <SpeciesTile>[
          _tile(1, 'One'),
          _tile(2, 'Two'),
          _tile(3, 'Three'),
          _tile(4, 'Four'),
          _tile(5, 'Five'),
        ],
      ),
    ], locale: const Locale('en'));

    expect(find.text('Three'), findsNothing);
    expect(find.text('+3'), findsOneWidget);

    await tester.tap(find.text('+3'));
    await tester.pumpAndSettle();

    expect(find.text('+3'), findsNothing);
    for (final name in <String>['One', 'Two', 'Three', 'Four', 'Five']) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
  });

  testWidgets('SpeciesBrowseScreen runs three compartments abreast at any width', (
    WidgetTester tester,
  ) async {
    // A plan that runs three abreast on one phone and four on another is a
    // different plate each time, and the comparison the grid exists for is
    // between the shapes on one row.
    await _pump(tester, <FamilyGroup>[
      FamilyGroup(
        familyId: 1,
        scientificFamily: 'Sparidae',
        localisedFamilyName: 'Breams',
        species: <SpeciesTile>[_tile(1, 'One'), _tile(2, 'Two'), _tile(3, 'Three')],
      ),
    ]);
    final double first = tester.getTopLeft(find.text('One')).dy;
    expect(tester.getTopLeft(find.text('Two')).dy, first);
    expect(tester.getTopLeft(find.text('Three')).dy, first);
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
