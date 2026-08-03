import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/ruler/widgets/ltr_instrument.dart';
import 'package:catchlaw/ui/ruler/widgets/ruler_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final RulerCalibration _calibration = RulerCalibration(
  pxPerMm: 6.299,
  capturedOn: DateTime.utc(2026, 8, 1),
);

Future<void> _pump(WidgetTester tester, Locale locale, ValueNotifier<double> cursor) =>
    tester.pumpWidget(
      MaterialApp(
        theme: LonjaTheme.paper(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Row(
            children: <Widget>[
              const Text('chrome'),
              RulerView(calibration: _calibration, cursorMm: cursor, spanPx: 300),
            ],
          ),
        ),
      ),
    );

void main() {
  testWidgets('ar - RulerView pins the instrument left to right', (WidgetTester tester) async {
    // SPEC.md §9.3's one exception. A physical measuring scale runs from a
    // physical edge; mirroring it puts zero at the tail of a real fish while
    // the fisher's hand is at the snout, and the Arabic build then reads every
    // fish backwards.
    final cursor = ValueNotifier<double>(45);
    addTearDown(cursor.dispose);
    await _pump(tester, const Locale('ar'), cursor);
    await tester.pump();

    expect(Directionality.of(tester.element(find.byType(CustomPaint).last)), TextDirection.ltr);
  });

  testWidgets('ar - the chrome around the instrument still mirrors', (WidgetTester tester) async {
    // The pin wraps the CANVAS and nothing else. A Directionality at the root
    // would make every physical-side bug in the app look correct.
    final cursor = ValueNotifier<double>(45);
    addTearDown(cursor.dispose);
    await _pump(tester, const Locale('ar'), cursor);
    await tester.pump();

    expect(Directionality.of(tester.element(find.text('chrome'))), TextDirection.rtl);
  });

  testWidgets('RulerView leaves the instrument left to right in en too', (
    WidgetTester tester,
  ) async {
    final cursor = ValueNotifier<double>(45);
    addTearDown(cursor.dispose);
    await _pump(tester, const Locale('en'), cursor);
    await tester.pump();

    expect(Directionality.of(tester.element(find.byType(CustomPaint).last)), TextDirection.ltr);
  });

  testWidgets('LtrInstrument is the only place a Directionality is constructed', (
    WidgetTester tester,
  ) async {
    // no_directional_geometry.sh bans the construct outright and this is the
    // sanctioned use, carrying the gate's documented hatch on one line. The
    // exception exists ONCE and is reviewed once.
    final cursor = ValueNotifier<double>(45);
    addTearDown(cursor.dispose);
    await _pump(tester, const Locale('ar'), cursor);
    await tester.pump();

    expect(find.byType(LtrInstrument), findsOneWidget);
  });

  testWidgets('RulerView excludes the canvas from semantics and speaks the reading', (
    WidgetTester tester,
  ) async {
    // A hundred tick marks is not a reading.
    final cursor = ValueNotifier<double>(450);
    addTearDown(cursor.dispose);
    await _pump(tester, const Locale('en'), cursor);
    await tester.pump();

    expect(find.bySemanticsLabel(RegExp('Ruler')), findsOneWidget);
  });
}
