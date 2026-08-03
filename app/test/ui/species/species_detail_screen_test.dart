import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/domain/models/species_account.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/species/widgets/species_detail_placeholders.dart';
import 'package:catchlaw/ui/species/widgets/species_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show TaxonGroup;

import '../../../testing/fakes/fake_species_account_repository.dart';

SpeciesAccount _account({bool protectedAnywhere = false, List<SpeciesName>? others}) =>
    SpeciesAccount(
      species: const Species(
        id: 1,
        scientificName: 'Epinephelus coioides',
        familyId: 1,
        taxonGroup: TaxonGroup.finfish,
        silhouetteAsset: 'assets/sil/1.svg',
      ),
      familyName: 'Meros',
      primaryName: 'هامور',
      otherNames: others ?? const <SpeciesName>[],
      isProtectedAnywhere: protectedAnywhere,
    );

Future<void> _pump(
  WidgetTester tester, {
  SpeciesAccount? account,
  Exception? failure,
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      // Mirrors main(). Without it a failing provider retries with backoff and
      // the screen never leaves `loading`.
      retry: noRetry,
      overrides: <Override>[
        speciesAccountRepositoryProvider.overrideWithValue(
          FakeSpeciesAccountRepository(
            account == null ? const <int, SpeciesAccount>{} : <int, SpeciesAccount>{1: account},
            failure: failure,
          ),
        ),
      ],
      child: MaterialApp(
        theme: LonjaTheme.paper(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SpeciesDetailScreen(speciesId: 1),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('SpeciesDetailScreen sets the local name above the binomial', (
    WidgetTester tester,
  ) async {
    // The whole design. Khalid does not read Latin: a header leading with
    // Epinephelus coioides puts the one string he cannot check at the top of a
    // screen he has ten seconds for.
    await _pump(tester, account: _account());
    expect(
      tester.getTopLeft(find.text('هامور')).dy,
      lessThan(tester.getTopLeft(find.text('Epinephelus coioides')).dy),
    );
  });

  testWidgets('SpeciesDetailScreen names the family in the reader’s language', (
    WidgetTester tester,
  ) async {
    await _pump(tester, account: _account());
    expect(find.textContaining('Meros'), findsOneWidget);
  });

  testWidgets('SpeciesDetailScreen lists other-locale names under the header', (
    WidgetTester tester,
  ) async {
    // A fisher working a Spanish market off a Galician boat needs both words.
    await _pump(
      tester,
      account: _account(
        others: const <SpeciesName>[
          SpeciesName(
            speciesId: 1,
            locale: 'es',
            name: 'Mero moteado',
            gender: NameGender.m,
            isPrimary: true,
          ),
        ],
      ),
    );
    expect(find.text('Mero moteado'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('هامور')).dy,
      lessThan(tester.getTopLeft(find.text('Mero moteado')).dy),
    );
  });

  testWidgets(
    'SpeciesDetailScreen marks a species protected somewhere without calling it a verdict',
    (WidgetTester tester) async {
      // SOMEWHERE, on purpose: the page is reached from a search and from a grid,
      // neither of which knows a zone. E10's finding is what states the rule with
      // its citation.
      await _pump(tester, account: _account(protectedAnywhere: true));
      expect(find.text('Protected somewhere in this jurisdiction'), findsOneWidget);
    },
  );

  testWidgets('SpeciesDetailScreen omits the protection mark when nothing protects it', (
    WidgetTester tester,
  ) async {
    await _pump(tester, account: _account());
    expect(find.text('Protected somewhere in this jurisdiction'), findsNothing);
  });

  testWidgets('SpeciesDetailScreen reserves the measurement and verdict slots', (
    WidgetTester tester,
  ) async {
    // Named slots rather than absences: the page's shape is the one that
    // ships, so E09 and E10 do not also have to re-lay out everything around
    // them — and a reviewer can see the measurement was planned, not forgotten.
    //
    // E12/T08 changed what fills the verdict slot, not that it is reserved:
    // `SpeciesVerdict` is always in the tree and renders nothing until the
    // fisher has told the app where he is. A verdict computed against a
    // jurisdiction nobody chose would be worse than an empty slot.
    await _pump(tester, account: _account());
    expect(find.byType(SpeciesMeasurementSlot), findsOneWidget);
    expect(find.byType(SpeciesVerdict), findsOneWidget);
    expect(find.byType(SpeciesVerdictSlot), findsNothing, reason: 'no place chosen yet');
  });

  testWidgets('SpeciesDetailScreen shows the failure rather than an empty page', (
    WidgetTester tester,
  ) async {
    // An empty page is a claim that the species has nothing to say. A read that
    // failed is a statement about the device.
    await _pump(tester, failure: const FormatException('reference.db is unreadable'));
    expect(find.textContaining('unreadable'), findsOneWidget);
  });

  testWidgets('SpeciesDetailScreen reports a retired species rather than rendering blank', (
    WidgetTester tester,
  ) async {
    // catch.species_id is a SOFT reference into a file a content update
    // replaces wholesale, so "retired" is a state the page has to carry.
    await _pump(tester);
    expect(find.textContaining('species'), findsOneWidget);
  });

  testWidgets('ar - SpeciesDetailScreen lays the account out right to left', (
    WidgetTester tester,
  ) async {
    await _pump(tester, account: _account(), locale: const Locale('ar'));
    expect(Directionality.of(tester.element(find.text('هامور'))), TextDirection.rtl);
  });
}
