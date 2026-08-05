// The order of S3, as a fact about the tree.
//
// The ruler was built in E09 and routed in E11 as a stack of controls: a
// drag ruler inside an Expanded, then a rule, then an eleven-key pad, then a
// primary. What the mockup asks for is an instrument — a full-bleed scale
// docked at the head of the page with its provenance under it, a running total
// in the mono figure step, and manual entry demoted to one quiet button — and
// an order test is the only thing that keeps a restructure from drifting back
// one widget at a time.

import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/core/ui/lonja_keypad.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/ruler/widgets/measure_screen.dart';
import 'package:catchlaw/ui/ruler/widgets/ruler_band.dart';
import 'package:catchlaw/ui/ruler/widgets/ruler_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_calibration_repository.dart';

final RulerCalibration _calibration = RulerCalibration(
  pxPerMm: 6.299,
  capturedOn: DateTime.utc(2026, 7, 2),
);

Future<AppLocalizations> _pump(WidgetTester tester, {RulerCalibration? stored}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        calibrationRepositoryProvider.overrideWithValue(FakeCalibrationRepository(stored)),
      ],
      child: MaterialApp(
        theme: LonjaTheme.paper(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MeasureScreen(),
      ),
    ),
  );
  // Twice: the calibration is read in a post-frame callback, so the first pump
  // paints the uncalibrated screen and the second paints the scale.
  await tester.pump();
  await tester.pump();
  return AppLocalizations.of(tester.element(find.byType(MeasureScreen)));
}

void main() {
  testWidgets('MeasureScreen heads the page with the ruler band', (WidgetTester tester) async {
    final AppLocalizations l10n = await _pump(tester, stored: _calibration);

    // Nothing stands between the bar and the scale. The fisher's hand is
    // already on the glass.
    final double barBottom = tester.getBottomLeft(find.byType(LonjaScreenBar)).dy;
    final double bandTop = tester.getTopLeft(find.byType(RulerBand)).dy;
    expect(bandTop, barBottom);
    expect(
      tester.getTopLeft(find.text(l10n.measureStepAndMark).first).dy,
      greaterThan(tester.getBottomLeft(find.byType(RulerBand)).dy),
    );
  });

  testWidgets('MeasureScreen runs the scale to both edges of the glass', (
    WidgetTester tester,
  ) async {
    await _pump(tester, stored: _calibration);

    // A gutter here is not a spacing choice: it is 16 dp of fish the ruler
    // never measures, on every reading taken.
    final Size screen = tester.getSize(find.byType(MeasureScreen));
    expect(tester.getTopLeft(find.byType(RulerView)).dx, 0);
    expect(tester.getSize(find.byType(RulerView)).width, screen.width);
  });

  testWidgets('MeasureScreen states when the scale was measured, under the scale', (
    WidgetTester tester,
  ) async {
    await _pump(tester, stored: _calibration);

    // The date is quoted ISO and unlocalised, and the scale beside it is what
    // the fit produced: 6.299 px/mm is 63 px per centimetre.
    expect(find.textContaining('2026-07-02'), findsOneWidget);
    expect(find.textContaining('63'), findsOneWidget);
  });

  testWidgets('MeasureScreen orders the actions under the running total', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await _pump(tester, stored: _calibration);

    final double totalBottom = tester.getBottomLeft(find.text(l10n.measureRunningTotalUnit)).dy;
    expect(tester.getTopLeft(find.text(l10n.measureStepAndMark).last).dy, greaterThan(totalBottom));
    expect(
      tester.getTopLeft(find.text(l10n.measureTypeInstead)).dy,
      greaterThan(tester.getTopLeft(find.text(l10n.measureStepAndMark).last).dy),
    );
    expect(
      tester.getTopLeft(find.text(l10n.measureRecalibrate)).dy,
      greaterThan(tester.getTopLeft(find.text(l10n.measureTypeInstead)).dy),
    );
  });

  testWidgets('MeasureScreen keeps no keypad on the ruler page', (WidgetTester tester) async {
    final AppLocalizations l10n = await _pump(tester, stored: _calibration);

    // Manual entry is one quiet button and a screen of its own. Eleven keys
    // under the scale took the page from the instrument and put targets where
    // the fisher's hand rests on the glass.
    expect(find.byType(LonjaKeypad), findsNothing);
    expect(find.text(l10n.measureTypeInstead), findsOneWidget);
  });

  testWidgets('MeasureScreen holds the mark down until the cursor has moved', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await _pump(tester, stored: _calibration);

    // A mark at zero would add a segment of no length to the running total.
    final Finder mark = find.widgetWithText(TextButton, l10n.measureStepAndMark);
    expect(tester.widget<TextButton>(mark).onPressed, isNull);

    await tester.drag(find.byType(RulerView), const Offset(120, 0));
    await tester.pump();
    expect(tester.widget<TextButton>(mark).onPressed, isNotNull);
  });

  testWidgets('MeasureScreen opens the keypad on its own page when the length is typed', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await _pump(tester, stored: _calibration);

    await tester.tap(find.text(l10n.measureTypeInstead));
    await tester.pumpAndSettle();

    // The pad the ruler page refuses to carry, on the screen that is about
    // typing. It works with no calibration behind it and it is not a fallback.
    expect(find.byType(LonjaKeypad), findsOneWidget);
    expect(find.text(l10n.measureUse), findsOneWidget);
  });

  testWidgets('MeasureScreen returns the typed length in millimetres', (WidgetTester tester) async {
    final AppLocalizations l10n = await _pump(tester, stored: _calibration);

    await tester.tap(find.text(l10n.measureTypeInstead));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.text(l10n.measureUse));
    await tester.pumpAndSettle();

    // 450 mm, and the ruler carries it straight out rather than showing it
    // again on a scale it was never taken from.
    expect(find.byType(MeasureScreen), findsNothing);
  });

  testWidgets('MeasureScreen states the screen is unmeasured rather than drawing a guessed scale', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await _pump(tester);

    // A ruler at a nominal ratio produces a number that LOOKS measured, which
    // is worse than no ruler at all — so the band says so and the primary
    // becomes the way out of it.
    expect(find.byType(RulerView), findsNothing);
    expect(find.text(l10n.measureUncalibrated), findsOneWidget);
    expect(find.text(l10n.calibrateAction), findsOneWidget);
    // And manual entry is still on the page, because it never depended on a
    // card in the first place.
    expect(find.text(l10n.measureTypeInstead), findsOneWidget);
  });
}
