import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/domain/models/penalty_schedule.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/core/ui/lonja_empty_state.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/reference/widgets/penalties_ledger.dart';
import 'package:catchlaw/ui/reference/widgets/penalties_screen.dart';
import 'package:catchlaw/ui/result/widgets/result_disclaimer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Citation;

import '../../../testing/fakes/fake_penalty_repository.dart';

/// The Gulf instrument, and the only one these fixtures cite.
const Citation _md580 = Citation(
  instrument: 'Ministerial Decision 580/2015',
  article: 'Art. 3',
  publishedOn: '2015-11-03',
  checkedOn: '2026-07-14',
);

/// A second instrument, so the footnote block can be asked to number two.
const Citation _md112 = Citation(
  instrument: 'Ministerial Decision 112/2019',
  article: 'Art. 8',
  publishedOn: '2019-04-02',
  checkedOn: '2026-07-14',
);

/// A schedule with two tiers of one offence, both fully recorded.
const PenaltySchedule _recorded = PenaltySchedule(
  jurisdictionName: 'Ras Al Khaimah',
  authority: 'Ministry of Climate Change & Environment',
  tiers: <PenaltyTier>[
    PenaltyTier(
      offence: 'Landing below the minimum size',
      occurrence: 1,
      citation: _md580,
      amountMin: 3000,
      currency: 'AED',
      consequence: 'Suspension for six months',
    ),
    PenaltyTier(
      offence: 'Landing below the minimum size',
      occurrence: 2,
      citation: _md580,
      amountMin: 5000,
      currency: 'AED',
      consequence: 'Revocation',
    ),
  ],
);

/// The state every pack this repository ships is in: nothing transcribed.
const PenaltySchedule _empty = PenaltySchedule(
  jurisdictionName: 'Galicia',
  authority: 'Xunta de Galicia — Consellería do Mar',
  tiers: <PenaltyTier>[],
);

Future<FakePenaltyRepository> _pump(
  WidgetTester tester, {
  PenaltySchedule? schedule,
  Exception? failure,
  Locale locale = const Locale('en'),
  String code = 'AE-RK',
}) async {
  final repository = FakePenaltyRepository(<String, PenaltySchedule>{
    code: ?schedule,
  }, failure: failure);

  await tester.pumpWidget(
    ProviderScope(
      // Mirrors main(). Without it Riverpod 3 retries a provider whose build
      // threw, with backoff, and the screen sits in `loading` forever — so the
      // error row would pass for the wrong reason.
      retry: noRetry,
      overrides: <Override>[penaltyRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: LonjaTheme.paper(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PenaltiesScreen(jurisdictionCode: code),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('PenaltiesScreen heads the page with the jurisdiction it is read against', (
    WidgetTester tester,
  ) async {
    await _pump(tester, schedule: _recorded);

    // A page of amounts with no place stamped on it is a page of amounts for
    // somewhere else.
    final LonjaScreenBar bar = tester.widget<LonjaScreenBar>(find.byType(LonjaScreenBar));
    expect(bar.title, 'Penalties');
    expect(bar.sup, 'AE-RK');
  });

  testWidgets('PenaltiesScreen prints the recorded fine and its currency unconverted', (
    WidgetTester tester,
  ) async {
    await _pump(tester, schedule: _recorded);

    // The instrument states a figure in one currency. A dirham amount rendered
    // in euros is a number no inspector will recognise.
    expect(find.text('AED 3,000'), findsOneWidget);
    expect(find.text('AED 5,000'), findsOneWidget);
  });

  testWidgets('PenaltiesScreen names the occurrence beside every figure', (
    WidgetTester tester,
  ) async {
    await _pump(tester, schedule: _recorded);

    // The word beside the oxblood figure is the non-colour signal: the cell
    // has to survive greyscale, glare and a reader who sees no red at all.
    expect(find.text('First offence'), findsWidgets);
    expect(find.text('Second offence'), findsWidgets);
  });

  testWidgets('PenaltiesScreen carries a citation for every offence it lists', (
    WidgetTester tester,
  ) async {
    await _pump(tester, schedule: _recorded);

    // Invariant 3 does not stop applying because the claim is short.
    expect(find.byType(PenaltiesOffenceList), findsOneWidget);
    expect(find.textContaining('Ministerial Decision 580/2015'), findsWidgets);
    expect(find.textContaining('published 2015-11-03 · checked 2026-07-14'), findsOneWidget);
  });

  testWidgets('PenaltiesScreen numbers one footnote per distinct instrument', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      schedule: const PenaltySchedule(
        jurisdictionName: 'Ras Al Khaimah',
        authority: 'Ministry of Climate Change & Environment',
        tiers: <PenaltyTier>[
          PenaltyTier(
            offence: 'Landing below the minimum size',
            occurrence: 1,
            citation: _md580,
            amountMin: 3000,
            currency: 'AED',
          ),
          PenaltyTier(
            offence: 'Gear breach',
            occurrence: 1,
            citation: _md112,
            amountMin: 1000,
            currency: 'AED',
          ),
        ],
      ),
    );

    // Two orders, two footnotes, and the pack caveat numbered after them —
    // never one footnote repeated, which reads as two documents consulted.
    expect(find.textContaining('Ministerial Decision 112/2019'), findsWidgets);
    expect(
      find.textContaining('Amounts are those recorded in the bundled rule pack.'),
      findsOneWidget,
    );
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('PenaltiesScreen states that nothing is recorded when the pack carries no tier', (
    WidgetTester tester,
  ) async {
    await _pump(tester, schedule: _empty, code: 'ES-GA');

    // The state every shipped pack is in today, and the screen a fisher
    // reaches right now. A blank frame here would read as a jurisdiction with
    // nothing to lose.
    expect(find.byType(LonjaEmptyState), findsOneWidget);
    expect(find.text('No penalty recorded'), findsOneWidget);
    expect(find.textContaining('That is an absence in the transcription'), findsOneWidget);
  });

  testWidgets('PenaltiesScreen draws no ledger when the pack carries no tier', (
    WidgetTester tester,
  ) async {
    await _pump(tester, schedule: _empty, code: 'ES-GA');

    // An empty ruled frame reads as content that failed to load, which on this
    // screen is a claim about the law.
    expect(find.byType(PenaltiesLedger), findsNothing);
    expect(find.byType(PenaltiesOffenceList), findsNothing);
  });

  testWidgets('PenaltiesScreen keeps the pack caveat and the disclaimer with no tier recorded', (
    WidgetTester tester,
  ) async {
    await _pump(tester, schedule: _empty, code: 'ES-GA');

    // What kind of thing the schedule is stays true of an empty one, and a
    // disclaimer the reader can lose is one that was never shown.
    expect(
      find.textContaining('Amounts are those recorded in the bundled rule pack.'),
      findsOneWidget,
    );
    expect(find.byType(ResultDisclaimer), findsOneWidget);
  });

  testWidgets('PenaltiesScreen refuses the empty state when the read failed', (
    WidgetTester tester,
  ) async {
    await _pump(tester, schedule: _recorded, failure: const DataStoreUnavailable());

    // "Nothing was transcribed" is a claim about the law. Making it when the
    // device could not read the file is the app inventing the absence of a
    // penalty, which is the same defect as inventing one.
    expect(find.byType(LonjaEmptyState), findsNothing);
    expect(find.text('No penalty recorded'), findsNothing);
  });

  testWidgets('PenaltiesScreen asks the pack in the reader\'s own language', (
    WidgetTester tester,
  ) async {
    final FakePenaltyRepository repository = await _pump(
      tester,
      schedule: _recorded,
      locale: const Locale('gl'),
    );

    // The offence names and the licence consequences are content_string rows:
    // a ledger read in one language and rendered under another is the §9.2
    // chain skipped.
    expect(repository.locales, contains('gl'));
    expect(find.text('Sancións'), findsOneWidget);
  });

  testWidgets('PenaltiesScreen names the authority in its standing notice', (
    WidgetTester tester,
  ) async {
    await _pump(tester, schedule: _recorded);

    // A generic "not legal advice" tells a fisher nothing about who to ask
    // instead, and the whole sentence exists to point at somebody who can
    // answer.
    final ResultDisclaimer disclaimer = tester.widget<ResultDisclaimer>(
      find.byType(ResultDisclaimer),
    );
    expect(disclaimer.authority, 'Ministry of Climate Change & Environment');
  });
}
