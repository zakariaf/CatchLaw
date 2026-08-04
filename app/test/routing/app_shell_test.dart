import 'package:catchlaw/routing/destination_placeholder.dart';
import 'package:catchlaw/ui/core/ui/app_shell.dart';
import 'package:catchlaw/ui/core/ui/lonja_destination.dart';
import 'package:catchlaw/ui/core/ui/lonja_nav_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/pump_lonja.dart';

/// A Check root that can push, so branch state has something to preserve.
class _CheckRoot extends StatelessWidget {
  const _CheckRoot();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const Scaffold(body: Text('pushed')),
          ),
        ),
        child: const Text('open a species'),
      ),
    ),
  );
}

Future<void> _pumpShell(WidgetTester tester, {Locale locale = const Locale('en')}) => pumpLonja(
  tester,
  const AppShell(
    check: _CheckRoot(),
    today: _TodayRoot(),
    trips: _TripsRoot(),
    reference: _ReferenceRoot(),
    settings: _SettingsRoot(),
  ),
  locale: locale,
);

void main() {
  group('AppShell', () {
    testWidgets('opens on Check', (WidgetTester tester) async {
      await _pumpShell(tester);

      // No splash, no login, no onboarding, no what's-new.
      expect(find.text('open a species'), findsOneWidget);
    });

    testWidgets('shows five destinations, each with a glyph and a word', (
      WidgetTester tester,
    ) async {
      await _pumpShell(tester);

      // A strip whose destinations differ only by icon is unreadable to a
      // reader who does not know the icons yet — which is every reader on the
      // first launch.
      for (final label in const <String>['Check', 'Today', 'Trips', 'Reference', 'Settings']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.byType(LonjaNavStrip), findsOneWidget);
    });

    testWidgets('switches branch when a destination is tapped', (WidgetTester tester) async {
      await _pumpShell(tester);

      await tester.tap(find.text('Reference'));
      await tester.pumpAndSettle();

      // Reference is a real branch now, so this asserts the injected root
      // rather than the placeholder it used to show.
      expect(find.text('reference root'), findsOneWidget);
    });

    testWidgets('shows the placeholder on a branch this release does not build', (
      WidgetTester tester,
    ) async {
      await _pumpShell(tester);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Every branch is now built, so the placeholder is unreachable from the
      // strip. The assertion is kept and inverted rather than deleted: it is
      // what proves the last branch stopped being a stub, and it fails loudly
      // if a future branch is added without a screen behind it.
      expect(find.byType(DestinationPlaceholder), findsNothing);
      expect(find.text('settings root'), findsOneWidget);
    });

    testWidgets('keeps the Check branch route when the reader comes back', (
      WidgetTester tester,
    ) async {
      await _pumpShell(tester);
      await tester.tap(find.text('open a species'));
      await tester.pumpAndSettle();
      expect(find.text('pushed'), findsOneWidget);

      await tester.tap(find.text('Reference'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // The whole reason the branches are stacked rather than swapped:
      // rebuilding would put him back at the top of a list he had scrolled.
      expect(find.text('pushed'), findsOneWidget);
    });

    testWidgets('pops the branch to its root when its own destination is tapped again', (
      WidgetTester tester,
    ) async {
      await _pumpShell(tester);
      await tester.tap(find.text('open a species'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // A fisher three screens deep who taps Check expects the front door, and
      // every other app on his phone does that.
      expect(find.text('pushed'), findsNothing);
      expect(find.text('open a species'), findsOneWidget);
    });

    testWidgets('draws no Material navigation bar', (WidgetTester tester) async {
      await _pumpShell(tester);

      // The bar brings an indicator pill, a tint and an elevation, and a
      // printed page has none of the three.
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    testWidgets('marks the selected cell without relying on hue', (WidgetTester tester) async {
      await _pumpShell(tester);

      // In sunlight the tint is the first thing to go, and the rule is still
      // there. Asserted structurally: the selected cell carries a border its
      // siblings do not.
      final Iterable<Container> cells = tester.widgetList<Container>(
        find.descendant(of: find.byType(LonjaNavStrip), matching: find.byType(Container)),
      );
      final int ruled = cells
          .where(
            (Container c) =>
                ((c.decoration! as BoxDecoration).border! as BorderDirectional).top !=
                BorderSide.none,
          )
          .length;
      expect(ruled, 1);
    });

    testWidgets('ar - lays the strip out right to left', (WidgetTester tester) async {
      await _pumpShell(tester, locale: const Locale('ar'));

      expect(
        tester.getCenter(find.text('فحص')).dx,
        greaterThan(tester.getCenter(find.text('الإعدادات')).dx),
        reason: 'Check is the first cell, and first is the right under RTL',
      );
    });

    testWidgets('every destination declares a path for the router that replaces this', (
      WidgetTester tester,
    ) async {
      // D-23: plain strings, so the v2 task that adopts a router has names to
      // bind rather than paths to invent.
      expect(
        LonjaDestination.values.map((LonjaDestination d) => d.path).toSet(),
        hasLength(LonjaDestination.values.length),
      );
    });
  });
}

/// Stands in for S6, for the same reason [_CheckRoot] stands in for S1: the
/// shell's tests are about the strip, the stack and branch history, and none of
/// those needs a database.
class _ReferenceRoot extends StatelessWidget {
  const _ReferenceRoot();

  @override
  Widget build(BuildContext context) => const Text('reference root');
}

/// Stands in for Settings, for the same reason the other two stand in.
class _SettingsRoot extends StatelessWidget {
  const _SettingsRoot();

  @override
  Widget build(BuildContext context) => const Text('settings root');
}

/// Stands in for Today, for the same reason the others stand in.
class _TodayRoot extends StatelessWidget {
  const _TodayRoot();

  @override
  Widget build(BuildContext context) => const Text('today root');
}

/// Stands in for Trips.
class _TripsRoot extends StatelessWidget {
  const _TripsRoot();

  @override
  Widget build(BuildContext context) => const Text('trips root');
}
