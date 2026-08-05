import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_branch_masthead.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/log/view_models/catch_log_providers.dart';
import 'package:catchlaw/ui/log/widgets/today_screen.dart';
import 'package:catchlaw/ui/result/widgets/result_rule_facts_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

const SpeciesTallyEntry _hamour = SpeciesTallyEntry(
  speciesId: 11,
  scientificName: 'Epinephelus coioides',
  count: 5,
  kept: 3,
);

const SpeciesTallyEntry _zubaidi = SpeciesTallyEntry(
  speciesId: 12,
  scientificName: 'Pampus argenteus',
  count: 2,
  kept: 2,
);

const Trip _open = Trip(
  id: 3,
  startedAt: '2026-07-27T04:55:00',
  jurisdictionCode: 'AE',
  zoneCode: 'Ras Al Khaimah',
);

Future<void> _pumpToday(
  WidgetTester tester, {
  List<SpeciesTallyEntry> tally = const <SpeciesTallyEntry>[_hamour, _zubaidi],
  Trip? open = _open,
  bool hasPlace = true,
  Object? failure,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: <Override>[
        todayIsoProvider.overrideWithValue('2026-07-27'),
        activePlaceProvider.overrideWithValue(
          hasPlace ? (jurisdiction: 'AE', zone: 'AE-RK') : null,
        ),
        openTripProvider.overrideWith((Ref ref) => Stream<Trip?>.value(open)),
        dayTallyProvider.overrideWith(
          (Ref ref) => failure == null
              ? Stream<List<SpeciesTallyEntry>>.value(tally)
              : Stream<List<SpeciesTallyEntry>>.error(failure),
        ),
      ],
      child: MaterialApp(
        theme: resolveLonjaTheme(skin: LonjaSkin.paper, gloved: false),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const TodayScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TextStyle _styleOf(WidgetTester tester, String text) => tester.widget<Text>(find.text(text)).style!;

void main() {
  group('TodayScreen', () {
    testWidgets('heads the day with the wordmark, the open trip, the date and the zone', (
      WidgetTester tester,
    ) async {
      await _pumpToday(tester);

      expect(find.byType(LonjaBranchMasthead), findsOneWidget);
      // Cased at the call site on the localised word, never authored shouting
      // into the ARB.
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('Today'), findsNothing);
      expect(find.text('Trip open since 4:55 AM'), findsOneWidget);
      expect(find.text('MON, JUL 27'), findsOneWidget);
      // The zone code as authored: an identifier is the same string in all six
      // locales and is what a fisher compares against the printed pack.
      expect(find.text('AE-RK'), findsOneWidget);
    });

    testWidgets('states that no trip is open rather than leaving the sub-line blank', (
      WidgetTester tester,
    ) async {
      await _pumpToday(tester, open: null);

      expect(find.text('No trip open'), findsOneWidget);
      expect(find.textContaining('Trip open since'), findsNothing);
    });

    testWidgets('prints no ISO date and no free-standing serif heading above the sheet', (
      WidgetTester tester,
    ) async {
      await _pumpToday(tester);

      // The screen this replaces printed '2026-07-27' in the 18 pt mono step
      // as the second line of the body. The date belongs in the mast's
      // trailing stamp and nowhere else.
      expect(find.text('2026-07-27'), findsNothing);
    });

    testWidgets('sets the mast stamp in the mono step and the sub-line in the ramp italic', (
      WidgetTester tester,
    ) async {
      await _pumpToday(tester);

      final ramp = LonjaTypeScale.latin();
      final TextStyle stamp = _styleOf(tester, 'MON, JUL 27');
      expect(stamp.fontFamily, ramp.articleNumber.fontFamily);
      expect(stamp.fontSize, ramp.articleNumber.fontSize);
      expect(stamp.color, LonjaPalettes.paper.onSurfaceMuted);

      final TextStyle wordmark = _styleOf(tester, 'TODAY');
      expect(wordmark.fontFamily, ramp.title.fontFamily);
      expect(wordmark.fontSize, ramp.title.fontSize);

      expect(_styleOf(tester, 'Trip open since 4:55 AM').fontStyle, FontStyle.italic);
    });

    testWidgets('totals the day in a ruled sheet directly under the mast', (
      WidgetTester tester,
    ) async {
      await _pumpToday(tester);

      expect(find.byType(ResultRuleFactsTable), findsOneWidget);
      // Uppercased by the ruled table at the call site, and tracked.
      expect(find.text('FISH RECORDED'), findsOneWidget);
      expect(find.text('KEPT'), findsOneWidget);
      expect(find.text('SPECIES'), findsOneWidget);
      // Seven fish across two species, five of them kept.
      expect(find.text('7'), findsOneWidget);
      expect(find.text('5 of 7'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Order: the sheet opens the page and the rubric follows it.
      expect(
        tester.getBottomLeft(find.text('FISH RECORDED')).dy,
        lessThan(tester.getTopLeft(find.byType(LonjaSectionLabel)).dy),
      );
    });

    testWidgets('sets every summary figure in the mono step and its label in the tracked sans', (
      WidgetTester tester,
    ) async {
      await _pumpToday(tester);

      final ramp = LonjaTypeScale.latin();
      final TextStyle figure = _styleOf(tester, '5 of 7');
      expect(figure.fontFamily, ramp.datum.fontFamily);
      expect(figure.fontSize, ramp.datum.fontSize);

      final TextStyle label = _styleOf(tester, 'FISH RECORDED');
      expect(label.fontFamily, ramp.microLabel.fontFamily);
      expect(label.fontSize, ramp.microLabel.fontSize);
      expect(label.letterSpacing, ramp.microLabel.letterSpacing);
    });

    testWidgets('files the entries under one tracked rubric', (WidgetTester tester) async {
      await _pumpToday(tester);

      expect(find.text('BY SPECIES'), findsOneWidget);
      expect(find.byType(LonjaSectionLabel), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('BY SPECIES')).dy,
        lessThan(tester.getTopLeft(find.text('Epinephelus coioides')).dy),
      );
    });

    testWidgets('lays an entry out as one line with its figures at the trailing edge', (
      WidgetTester tester,
    ) async {
      await _pumpToday(tester);

      final Rect name = tester.getRect(find.text('Epinephelus coioides'));
      final Rect detail = tester.getRect(find.text('5 recorded · 3 kept'));
      final Rect pips = tester.getRect(find.byKey(TodayScreen.pipKey(0, struck: true)).first);

      // The name leads, the figures hang beneath it, and the struck tally sits
      // outboard of both — one horizontal line, not a stacked block.
      expect(name.top, lessThan(detail.top));
      expect(pips.left, greaterThan(name.right));
      expect(pips.left, greaterThan(detail.right));
    });

    testWidgets('sets the entry binomial in the ramp italic and its count line in mono', (
      WidgetTester tester,
    ) async {
      await _pumpToday(tester);

      final ramp = LonjaTypeScale.latin();
      final TextStyle binomial = _styleOf(tester, 'Epinephelus coioides');
      expect(binomial.fontStyle, FontStyle.italic);
      expect(binomial.fontSize, ramp.binomial.fontSize);

      final TextStyle count = _styleOf(tester, '5 recorded · 3 kept');
      expect(count.fontFamily, ramp.citation.fontFamily);
      expect(count.fontSize, ramp.citation.fontSize);
      expect(count.color, LonjaPalettes.paper.onSurfaceMuted);
    });

    testWidgets('strikes one box per fish recorded and fills one per fish kept', (
      WidgetTester tester,
    ) async {
      await _pumpToday(tester, tally: const <SpeciesTallyEntry>[_hamour]);

      // Five recorded, three kept: three struck boxes then two blank ones, and
      // the figures beside them say the same thing in words. Neither signal is
      // a colour (invariant 4).
      for (var i = 0; i < 3; i++) {
        expect(find.byKey(TodayScreen.pipKey(i, struck: true)), findsOneWidget);
      }
      for (var i = 3; i < 5; i++) {
        expect(find.byKey(TodayScreen.pipKey(i, struck: false)), findsOneWidget);
      }
      expect(find.byKey(TodayScreen.pipKey(5, struck: false)), findsNothing);
    });

    testWidgets('prints the figures alone when the tally outruns the strip', (
      WidgetTester tester,
    ) async {
      await _pumpToday(
        tester,
        tally: const <SpeciesTallyEntry>[
          SpeciesTallyEntry(
            speciesId: 11,
            scientificName: 'Epinephelus coioides',
            count: 9,
            kept: 4,
          ),
        ],
      );

      // Past eight the boxes would be narrower than the rule that draws them,
      // and a strip that reads as a smudge is worse than no strip.
      expect(find.byKey(TodayScreen.pipKey(0, struck: true)), findsNothing);
      expect(find.text('9 recorded · 4 kept'), findsOneWidget);
    });

    testWidgets('carries no control on any entry', (WidgetTester tester) async {
      await _pumpToday(tester);

      // The mockup's entries hold figures and nothing else. Two buttons on
      // every entry made the controls the heaviest thing on a page whose whole
      // subject is a count.
      expect(find.widgetWithText(LonjaButton, 'Kept'), findsNothing);
      expect(find.text('Remove one'), findsNothing);
    });

    testWidgets('puts its one control at the foot below the last entry', (
      WidgetTester tester,
    ) async {
      await _pumpToday(tester);

      final Finder control = find.byType(LonjaButton);
      expect(control, findsOneWidget);
      expect(find.widgetWithText(LonjaButton, 'End this trip'), findsOneWidget);
      expect(
        tester.getTopLeft(control).dy,
        greaterThan(tester.getBottomLeft(find.text('Pampus argenteus')).dy),
      );
    });

    testWidgets('offers no control with no trip running', (WidgetTester tester) async {
      await _pumpToday(tester, open: null);

      // Nothing to end: a button that could only fail teaches the fisher not
      // to trust the others.
      expect(find.byType(LonjaButton), findsNothing);
    });

    testWidgets('states that nothing was recorded rather than rendering a blank page', (
      WidgetTester tester,
    ) async {
      await _pumpToday(tester, tally: const <SpeciesTallyEntry>[]);

      expect(find.text('Nothing recorded today'), findsOneWidget);
      // No sheet of zeros over the empty state: a table counting nothing is a
      // figure that has to be read before it can be discarded.
      expect(find.byType(ResultRuleFactsTable), findsNothing);
      expect(find.byType(LonjaSectionLabel), findsNothing);
    });

    testWidgets('separates no place set from nothing recorded', (WidgetTester tester) async {
      await _pumpToday(tester, tally: const <SpeciesTallyEntry>[], hasPlace: false);

      // Two different emptinesses: one is a fact about the day and one is a
      // fact about the app, and only one of them is something he can act on.
      expect(find.text('No place set'), findsOneWidget);
      expect(find.text('Nothing recorded today'), findsNothing);
    });

    testWidgets('states a failed read in its own words and never as an exception', (
      WidgetTester tester,
    ) async {
      await _pumpToday(tester, failure: Exception('user.db is locked'));

      expect(find.text("The day's tally on this device could not be read."), findsOneWidget);
      expect(find.textContaining('user.db is locked'), findsNothing);
      // A failed read is not an empty day, and the two are never merged.
      expect(find.text('Nothing recorded today'), findsNothing);
    });
  });
}
