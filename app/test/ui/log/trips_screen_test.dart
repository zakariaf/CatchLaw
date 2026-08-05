import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/log/view_models/catch_log_providers.dart';
import 'package:catchlaw/ui/log/widgets/trips_screen.dart';
import 'package:catchlaw/ui/zones/view_models/zone_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

const Trip _open = Trip(
  id: 3,
  startedAt: '2026-07-27T04:55:00',
  jurisdictionCode: 'AE',
  zoneCode: 'Ras Al Khaimah',
);

const Trip _closed = Trip(
  id: 2,
  startedAt: '2026-07-26T04:40:00',
  endedAt: '2026-07-26T09:10:00',
  jurisdictionCode: 'AE',
  zoneCode: 'Ras Al Khaimah',
);

/// A trip filed in the month before the other two, so the ledger has to print a
/// second rubric.
const Trip _june = Trip(
  id: 1,
  startedAt: '2026-06-18T05:10:00',
  endedAt: '2026-06-18T09:55:00',
  jurisdictionCode: 'AE',
  zoneCode: 'Ras Al Khaimah',
);

Future<void> _pumpTrips(
  WidgetTester tester, {
  List<Trip> trips = const <Trip>[_open, _closed, _june],
  Trip? open = _open,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: <Override>[
        tripsProvider.overrideWith((Ref ref) => Stream<List<Trip>>.value(trips)),
        openTripProvider.overrideWith((Ref ref) => Stream<Trip?>.value(open)),
        evaluationScopeProvider.overrideWith((Ref ref) => Stream<EvaluationScope?>.value(null)),
      ],
      child: MaterialApp(
        theme: resolveLonjaTheme(skin: LonjaSkin.paper, gloved: false),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const TripsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TextStyle _styleOf(WidgetTester tester, String text) => tester.widget<Text>(find.text(text)).style!;

void main() {
  group('TripsScreen', () {
    testWidgets('heads the ledger with the branch name and the count stamp', (
      WidgetTester tester,
    ) async {
      await _pumpTrips(tester);

      // The mast, in the order the mockup prints it: the name of the page at
      // the leading margin, the figure at the trailing one.
      expect(find.byType(LonjaScreenBar), findsOneWidget);
      expect(find.text('Trips'), findsOneWidget);
      expect(find.text('3 trips'), findsOneWidget);
    });

    testWidgets('states where the ledger is held above the first entry', (
      WidgetTester tester,
    ) async {
      await _pumpTrips(tester);

      expect(
        tester.getBottomLeft(find.text('Kept on this device only')).dy,
        lessThan(tester.getTopLeft(find.byType(LonjaSectionLabel).first).dy),
      );
    });

    testWidgets('files entries under a rubric for each month they fall in', (
      WidgetTester tester,
    ) async {
      await _pumpTrips(tester);

      expect(find.text('July 2026'), findsOneWidget);
      expect(find.text('June 2026'), findsOneWidget);
      // One rubric per month, not one per row: three trips across two months.
      expect(find.byType(LonjaSectionLabel), findsNWidgets(2));
    });

    testWidgets('leads an entry with its date and demotes the place beneath it', (
      WidgetTester tester,
    ) async {
      await _pumpTrips(tester);

      final Finder date = find.text('Sun, Jul 26');
      final Finder detail = find.text('Ras Al Khaimah · 4:40 AM — 9:10 AM');
      expect(date, findsOneWidget);
      expect(detail, findsOneWidget);
      // The question a fisher brings to a ledger is which morning, not which
      // harbour: the date leads the row and the place follows it.
      expect(tester.getTopLeft(date).dy, lessThan(tester.getTopLeft(detail).dy));
    });

    testWidgets('sets the entry date in the serif step and its detail line in the quiet sans', (
      WidgetTester tester,
    ) async {
      await _pumpTrips(tester);

      final ramp = LonjaTypeScale.latin();
      expect(_styleOf(tester, 'Sun, Jul 26').fontFamily, ramp.subtitle.fontFamily);
      expect(_styleOf(tester, 'Sun, Jul 26').fontSize, ramp.subtitle.fontSize);

      final TextStyle detail = _styleOf(tester, 'Ras Al Khaimah · 4:40 AM — 9:10 AM');
      expect(detail.fontFamily, ramp.uiSmall.fontFamily);
      expect(detail.fontSize, ramp.uiSmall.fontSize);
      expect(detail.color, LonjaPalettes.paper.onSurfaceMuted);
    });

    testWidgets('marks the open trip beside its date and again at the end of its row', (
      WidgetTester tester,
    ) async {
      await _pumpTrips(tester);

      // Twice, and neither mark is a colour: invariant 4 survives greyscale,
      // glare and a screen reader only when the word is one of the signals.
      expect(find.text('· open'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Ras Al Khaimah · 4:55 AM — now'), findsOneWidget);
    });

    testWidgets('stamps the open mark at the trailing edge of its own row', (
      WidgetTester tester,
    ) async {
      await _pumpTrips(tester);

      final Rect row = tester.getRect(find.text('Mon, Jul 27'));
      final Rect stamp = tester.getRect(find.text('Open'));
      expect(stamp.left, greaterThan(row.right));
      expect(stamp.center.dy, closeTo(row.center.dy, row.height));
    });

    testWidgets('prints how long a closed trip ran in the mono step', (WidgetTester tester) async {
      await _pumpTrips(tester);

      final Finder ran = find.text('4h 30m');
      expect(ran, findsOneWidget);
      expect(
        _styleOf(tester, '4h 30m').fontFamily,
        LonjaTypeScale.latin().articleNumber.fontFamily,
      );
    });

    testWidgets('carries no elapsed figure on the trip still running', (WidgetTester tester) async {
      await _pumpTrips(tester, trips: const <Trip>[_open]);

      // An open trip has no elapsed time to state as a fact, and a figure
      // counting up to now would be a number that is wrong the moment it is
      // read.
      expect(find.textContaining(RegExp(r'^\d+h \d+m$')), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('puts its one control at the foot below the last entry', (
      WidgetTester tester,
    ) async {
      await _pumpTrips(tester);

      // S10 has no control at the head. A button standing where the first row
      // belongs is the first thing the fisher's eye lands on, before he has
      // seen a single entry.
      final Finder control = find.byType(LonjaButton);
      expect(control, findsOneWidget);
      expect(
        tester.getTopLeft(control).dy,
        greaterThan(tester.getBottomLeft(find.text('June 2026')).dy),
      );
    });

    testWidgets('offers no control with no open trip and no place set', (
      WidgetTester tester,
    ) async {
      await _pumpTrips(tester, trips: const <Trip>[_closed], open: null);

      // Nothing to end and nowhere to start one: a button that could only fail
      // is a control that teaches the fisher not to trust the others.
      expect(find.byType(LonjaButton), findsNothing);
    });

    testWidgets('states that the ledger is empty rather than rendering a blank page', (
      WidgetTester tester,
    ) async {
      await _pumpTrips(tester, trips: const <Trip>[], open: null);

      expect(find.text('No trips yet'), findsOneWidget);
      // Nothing to count, so the stamp is absent rather than reading zero.
      expect(find.text('0 trips'), findsNothing);
    });
  });
}
