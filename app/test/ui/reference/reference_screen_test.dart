import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/family_group.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/core/ui/app_shell.dart';
import 'package:catchlaw/ui/reference/widgets/reference_contents_line.dart';
import 'package:catchlaw/ui/reference/widgets/reference_masthead.dart';
import 'package:catchlaw/ui/reference/widgets/reference_pack_block.dart';
import 'package:catchlaw/ui/reference/widgets/reference_screen.dart';
import 'package:catchlaw/ui/reference/widgets/reference_section_screen.dart';
import 'package:catchlaw/ui/species/widgets/species_browse_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_content_string_repository.dart';
import '../../../testing/fakes/fake_reference_repository.dart';
import '../../../testing/fakes/fake_settings_repository.dart';
import '../../../testing/fakes/fake_species_browse_repository.dart';
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
  contentVersion: '2026.08.2',
  checkedOn: '2026-08-03',
);

const Map<String, Map<String, String>> _galicianStrings = <String, Map<String, String>>{
  'jurisdiction.es_ga.name': <String, String>{'en': 'Galicia', 'gl': 'Galicia'},
  'jurisdiction.es_ga.authority': <String, String>{
    'en': 'Consellería do Mar',
    'gl': 'Consellería do Mar',
  },
};

FamilyGroup _family(int id, int speciesCount) => FamilyGroup(
  familyId: id,
  scientificFamily: 'Sparidae',
  localisedFamilyName: 'Sparids',
  species: <SpeciesTile>[
    for (int i = 0; i < speciesCount; i++)
      SpeciesTile(
        speciesId: id * 100 + i,
        silhouetteAsset: 'assets/sil/$id-$i.svg',
        displayName: 'Fish $i',
        scientificName: 'Genus species$i',
        isProtected: false,
      ),
  ],
);

Future<void> _pumpHub(
  WidgetTester tester, {
  List<Jurisdiction> jurisdictions = const <Jurisdiction>[_galicia],
  Map<String, Map<String, String>> strings = _galicianStrings,
  List<FamilyGroup> families = const <FamilyGroup>[],
  UserProfile profile = const UserProfile(),
  StoreEnv env = StoreEnv.healthy,
  Widget home = const ReferenceScreen(),
}) async {
  // A sheet tall enough for the whole page. The contents and the packs are
  // built lazily, so on the default 800×600 surface the entries below the fold
  // are never constructed — and a test asserting on the eighth would be
  // asserting about the viewport rather than about the page.
  tester.view.physicalSize = const Size(1200, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final reference = FakeReferenceRepository(env: env);
  reference.jurisdictionRows.addAll(jurisdictions);

  await tester.pumpWidget(
    ProviderScope(
      // Mirrors main(). Without it Riverpod 3 retries a provider whose build
      // threw, with backoff — so a failing read never reaches AsyncError and
      // the page sits in `loading` forever.
      retry: noRetry,
      overrides: <Override>[
        referenceRepositoryProvider.overrideWithValue(reference),
        contentStringRepositoryProvider.overrideWithValue(FakeContentStringRepository(strings)),
        speciesBrowseRepositoryProvider.overrideWithValue(FakeSpeciesBrowseRepository(families)),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository(profile: profile)),
      ],
      child: MaterialApp(
        theme: LonjaTheme.paper(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _topOf(WidgetTester tester, String text) => tester.getTopLeft(find.text(text)).dy;

void main() {
  group('ReferenceScreen', () {
    testWidgets('heads the branch with a gazette mast and an italic part-title', (
      WidgetTester tester,
    ) async {
      await _pumpHub(tester);

      expect(find.byType(ReferenceMasthead), findsOneWidget);
      // Cased at the call site on the localised word, never authored shouting
      // into the ARB.
      expect(find.text('REFERENCE'), findsOneWidget);
      // Twice: the part-title under the wordmark, and the rubric over the list
      // it names. They are the same word because they name the same list.
      expect(find.text('Contents'), findsNWidgets(2));

      final Text subline = tester.widget<Text>(
        find.descendant(of: find.byType(ReferenceMasthead), matching: find.text('Contents')),
      );
      expect(subline.style?.fontStyle, FontStyle.italic);
    });

    testWidgets('opens with the lede above the contents', (WidgetTester tester) async {
      await _pumpHub(tester);

      const lede =
          'Everything a verdict is drawn from, held in full on this device and '
          'readable without a signal.';
      expect(find.text(lede), findsOneWidget);
      expect(_topOf(tester, lede), lessThan(_topOf(tester, 'Rule text')));
    });

    testWidgets('sets eight entries in roman-numeral order', (WidgetTester tester) async {
      await _pumpHub(tester);

      expect(find.byType(ReferenceContentsLine), findsNWidgets(8));
      const numerals = <String>['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII'];
      for (final numeral in numerals) {
        expect(find.text(numeral), findsOneWidget, reason: 'numeral $numeral');
      }
      for (var i = 1; i < numerals.length; i++) {
        expect(
          _topOf(tester, numerals[i]),
          greaterThan(_topOf(tester, numerals[i - 1])),
          reason: '${numerals[i]} follows ${numerals[i - 1]}',
        );
      }
    });

    testWidgets('names each entry and what that section holds', (WidgetTester tester) async {
      await _pumpHub(tester);

      expect(find.text('Rule text'), findsOneWidget);
      expect(find.text('Protected species'), findsOneWidget);
      expect(find.text('Gear and methods'), findsOneWidget);
      expect(find.text('Penalties'), findsOneWidget);
      expect(find.text('Licences'), findsOneWidget);
      expect(find.text('Glossary'), findsOneWidget);
      expect(find.text('Changelog'), findsOneWidget);
      expect(find.text('Species plates'), findsOneWidget);
      expect(find.text('Fines and licence consequences, by offence'), findsOneWidget);
      expect(find.text('Silhouettes grouped by family, for a fish known by shape'), findsOneWidget);
    });

    testWidgets('marks the entries this copy does not print', (WidgetTester tester) async {
      // Every entry states its own status rather than the list quietly dropping
      // the sections this release does not set: a book that listed only what
      // works would state that it contains a plate of silhouettes and nothing
      // else, which is a claim about the product that is not true.
      await _pumpHub(tester);

      expect(find.text('not printed'), findsWidgets);
    });

    testWidgets('counts the species behind the plates entry', (WidgetTester tester) async {
      await _pumpHub(tester, families: <FamilyGroup>[_family(1, 2), _family(2, 3)]);

      expect(find.text('5 species'), findsOneWidget);
    });

    testWidgets('never marks the plates entry as unprinted', (WidgetTester tester) async {
      await _pumpHub(tester);

      // Zero families read means zero species, and a count of nothing is still
      // a count: what is asserted here is that the plates entry never borrows
      // the "not printed" mark, which would state that S6 is absent from a copy
      // that ships it.
      final ReferenceContentsLine plates = tester.widget<ReferenceContentsLine>(
        find.byType(ReferenceContentsLine).last,
      );
      expect(plates.title, 'Species plates');
      expect(plates.count, isNot('not printed'));
    });

    testWidgets('opens the browse plate from the species-plates entry', (
      WidgetTester tester,
    ) async {
      await _pumpHub(tester, families: <FamilyGroup>[_family(1, 1)]);

      await tester.tap(find.text('Species plates'));
      await tester.pumpAndSettle();

      expect(find.byType(SpeciesBrowseScreen), findsOneWidget);
    });

    testWidgets('states that a section is not printed when an unset entry is opened', (
      WidgetTester tester,
    ) async {
      await _pumpHub(tester);

      await tester.tap(find.text('Glossary'));
      await tester.pumpAndSettle();

      expect(find.byType(ReferenceSectionScreen), findsOneWidget);
      expect(
        find.text(
          'This section is not printed in this copy. This version answers whether a fish '
          'meets the rules in the place it was landed, and cites the instrument it read.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('names each held pack with its authority, its printing and the day it was '
        'checked', (WidgetTester tester) async {
      await _pumpHub(tester);

      expect(find.byType(ReferencePackBlock), findsOneWidget);
      expect(find.text('GALICIA'), findsOneWidget);
      expect(find.text('Consellería do Mar'), findsOneWidget);
      // ISO and unlocalised, like every other date this app quotes.
      expect(find.text('pack 2026.08.2 · checked 2026-08-03'), findsOneWidget);
    });

    testWidgets('falls back to the jurisdiction code when the pack carries no name for it', (
      WidgetTester tester,
    ) async {
      await _pumpHub(tester, strings: const <String, Map<String, String>>{});

      expect(find.text('ES-GA'), findsOneWidget);
    });

    testWidgets('states that no jurisdiction is held when the pack carries none', (
      WidgetTester tester,
    ) async {
      await _pumpHub(tester, jurisdictions: const <Jurisdiction>[]);

      expect(find.text('No jurisdiction is held in this copy.'), findsOneWidget);
      expect(find.byType(ReferencePackBlock), findsNothing);
    });

    testWidgets('states that no jurisdiction is held when the rule book cannot be read', (
      WidgetTester tester,
    ) async {
      await _pumpHub(tester, env: StoreEnv.storeUnavailable);

      expect(find.text('No jurisdiction is held in this copy.'), findsOneWidget);
    });

    testWidgets('closes the held packs with what this book does with them', (
      WidgetTester tester,
    ) async {
      await _pumpHub(tester);

      expect(
        find.text('This book quotes the instruments it holds. It does not summarise them.'),
        findsOneWidget,
      );
    });

    testWidgets('stamps the mast with the zone and the printing when a place is chosen', (
      WidgetTester tester,
    ) async {
      await _pumpHub(
        tester,
        profile: const UserProfile(activeJurisdiction: 'ES-GA', activeZoneCode: 'ES-GA'),
      );

      expect(find.text('ES-GA'), findsOneWidget);
      expect(find.text('2026.08.2'), findsOneWidget);
    });

    testWidgets('leaves the mast unstamped before a place is chosen', (WidgetTester tester) async {
      // A hub with no place is still a hub: what this book HOLDS does not
      // depend on where the fisher is standing, so the contents are printed and
      // only the stamp is absent.
      await _pumpHub(tester);

      expect(find.text('2026.08.2'), findsNothing);
      expect(find.byType(ReferenceContentsLine), findsNWidgets(8));
    });
  });

  group('AppShell', () {
    testWidgets('reaches the reference hub from the ledger strip', (WidgetTester tester) async {
      // The whole point of the screen: four branches shipped built and
      // reachable from nowhere, and an unrouted hub would be the fifth.
      // `hitTestable` is what makes this an assertion about the VISIBLE branch —
      // an IndexedStack builds every branch, and finding the widget proves only
      // that it was constructed.
      await _pumpHub(
        tester,
        home: const AppShell(
          check: SizedBox.shrink(),
          today: SizedBox.shrink(),
          trips: SizedBox.shrink(),
          reference: ReferenceScreen(),
          settings: SizedBox.shrink(),
        ),
      );

      expect(find.byType(ReferenceMasthead).hitTestable(), findsNothing);

      await tester.tap(find.text('Reference'));
      await tester.pumpAndSettle();

      expect(find.byType(ReferenceMasthead).hitTestable(), findsOneWidget);
      expect(find.byType(ReferenceContentsLine).hitTestable(), findsWidgets);
    });
  });
}
