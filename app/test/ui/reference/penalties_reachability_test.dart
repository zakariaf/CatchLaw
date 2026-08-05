import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/penalty_schedule.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/core/ui/lonja_destination.dart';
import 'package:catchlaw/ui/reference/widgets/penalties_screen.dart';
import 'package:catchlaw/ui/reference/widgets/reference_screen.dart';
import 'package:catchlaw/ui/reference/widgets/reference_section_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_content_string_repository.dart';
import '../../../testing/fakes/fake_penalty_repository.dart';
import '../../../testing/fakes/fake_reference_repository.dart';
import '../../../testing/fakes/fake_settings_repository.dart';
import '../../../testing/fakes/fake_species_browse_repository.dart';

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

const Map<String, Map<String, String>> _strings = <String, Map<String, String>>{
  'jurisdiction.es_ga.name': <String, String>{'en': 'Galicia', 'gl': 'Galicia'},
  'jurisdiction.es_ga.authority': <String, String>{
    'en': 'Consellería do Mar',
    'gl': 'Consellería do Mar',
  },
};

/// What ES-GA actually carries today: no `penalty` row at all.
const PenaltySchedule _nothingRecorded = PenaltySchedule(
  jurisdictionName: 'Galicia',
  authority: 'Consellería do Mar',
  tiers: <PenaltyTier>[],
);

Future<void> _pumpBranch(WidgetTester tester, {required UserProfile profile}) async {
  // A sheet tall enough for the whole contents list: the entries are built
  // lazily, and IV sits below the fold on the default surface.
  tester.view.physicalSize = const Size(1200, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final reference = FakeReferenceRepository();
  reference.jurisdictionRows.add(_galicia);

  await tester.pumpWidget(
    ProviderScope(
      // Mirrors main(). Without it Riverpod 3 retries a provider whose build
      // threw, with backoff, and a failing read never reaches AsyncError.
      retry: noRetry,
      overrides: <Override>[
        referenceRepositoryProvider.overrideWithValue(reference),
        contentStringRepositoryProvider.overrideWithValue(FakeContentStringRepository(_strings)),
        speciesBrowseRepositoryProvider.overrideWithValue(FakeSpeciesBrowseRepository(const [])),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository(profile: profile)),
        penaltyRepositoryProvider.overrideWithValue(
          FakePenaltyRepository(const <String, PenaltySchedule>{'ES-GA': _nothingRecorded}),
        ),
      ],
      child: MaterialApp(
        theme: LonjaTheme.paper(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ReferenceScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Reference branch opens the penalty schedule from its contents entry', (
    WidgetTester tester,
  ) async {
    await _pumpBranch(
      tester,
      profile: const UserProfile(activeJurisdiction: 'ES-GA', activeZoneCode: 'ES-GA'),
    );

    await tester.tap(find.text('Penalties'));
    await tester.pumpAndSettle();

    // The whole point of the exercise: a screen nothing routes to is a screen
    // that does not exist.
    expect(find.byType(PenaltiesScreen), findsOneWidget);
    expect(find.byType(ReferenceSectionScreen), findsNothing);
  });

  testWidgets('Reference branch opens the schedule for the place the fisher chose', (
    WidgetTester tester,
  ) async {
    await _pumpBranch(
      tester,
      profile: const UserProfile(activeJurisdiction: 'ES-GA', activeZoneCode: 'ES-GA'),
    );

    await tester.tap(find.text('Penalties'));
    await tester.pumpAndSettle();

    // A code and never a row id: `reference.db` is replaced wholesale and the
    // ids do not survive the replacement.
    final PenaltiesScreen screen = tester.widget<PenaltiesScreen>(find.byType(PenaltiesScreen));
    expect(screen.jurisdictionCode, 'ES-GA');
  });

  testWidgets('Reference branch states that no penalty is recorded for the shipped pack', (
    WidgetTester tester,
  ) async {
    await _pumpBranch(
      tester,
      profile: const UserProfile(activeJurisdiction: 'ES-GA', activeZoneCode: 'ES-GA'),
    );

    await tester.tap(find.text('Penalties'));
    await tester.pumpAndSettle();

    // No jurisdiction shipped today carries a transcribed penalty row, and this
    // is the sentence that says so rather than a fabricated table.
    expect(find.text('No penalty recorded'), findsOneWidget);
  });

  testWidgets('Reference branch withholds the schedule until a place is chosen', (
    WidgetTester tester,
  ) async {
    await _pumpBranch(tester, profile: const UserProfile());

    await tester.tap(find.text('Penalties'));
    await tester.pumpAndSettle();

    // A penalty schedule belongs to an authority, and there is no such thing as
    // one for nowhere. The entry says the section is not set here rather than
    // opening an empty page about no jurisdiction.
    expect(find.byType(PenaltiesScreen), findsNothing);
    expect(find.byType(ReferenceSectionScreen), findsOneWidget);
  });

  testWidgets('Reference branch returns to its contents from the schedule', (
    WidgetTester tester,
  ) async {
    await _pumpBranch(
      tester,
      profile: const UserProfile(activeJurisdiction: 'ES-GA', activeZoneCode: 'ES-GA'),
    );

    await tester.tap(find.text('Penalties'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // Pushed onto the BRANCH's own Navigator and not a root one: the ledger
    // strip renders `LonjaDestination.shipped` and keeps Reference lit while
    // the schedule is on screen, which is what makes a second tap on that
    // destination a way back.
    expect(LonjaDestination.shipped, contains(LonjaDestination.reference));
    expect(find.byType(ReferenceScreen), findsOneWidget);
    expect(find.byType(PenaltiesScreen), findsNothing);
  });
}
