// The order of S4, as a fact about the tree.
//
// The screen shipped from E09 as four widgets — a sentence, a sunken strip, one
// caption and a button — where the mockup is a dimensioned drawing followed by
// the figures it produces. What that stub could not do is say what the fit
// measured, how far out it could be, or when the stored scale was taken, and a
// calibration screen that states none of those is asking to be trusted rather
// than checked.

import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/ruler/widgets/calibration_card_drawing.dart';
import 'package:catchlaw/ui/ruler/widgets/calibration_screen.dart';
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
        home: const CalibrationScreen(),
      ),
    ),
  );
  // Twice: the stored scale is read in a post-frame callback.
  await tester.pump();
  await tester.pump();
  return AppLocalizations.of(tester.element(find.byType(CalibrationScreen)));
}

void main() {
  testWidgets('CalibrationScreen stamps its bar with how often calibration happens', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await _pump(tester);

    expect(find.byType(LonjaScreenBar), findsOneWidget);
    expect(find.text(l10n.calibrateSup), findsOneWidget);
  });

  testWidgets('CalibrationScreen quotes both card dimensions above the drawing', (
    WidgetTester tester,
  ) async {
    await _pump(tester);

    // The premise of the screen, not a caption on the control: ID-1 is a
    // published constant and both of its dimensions come from the standard.
    final Finder constant = find.textContaining('ISO/IEC 7810 ID-1');
    expect(constant, findsOneWidget);
    expect(find.textContaining('85.60'), findsWidgets);
    expect(find.textContaining('53.98'), findsWidgets);
    expect(
      tester.getBottomLeft(constant).dy,
      lessThan(tester.getTopLeft(find.byType(CalibrationCardDrawing)).dy),
    );
  });

  testWidgets('CalibrationScreen prints the resulting scale under the drawing', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await _pump(tester);

    final double drawingBottom = tester.getBottomLeft(find.byType(CalibrationCardDrawing)).dy;
    expect(
      tester.getTopLeft(find.widgetWithText(LonjaSectionLabel, l10n.calibrateScaleLabel)).dy,
      greaterThan(drawingBottom),
    );
    for (final label in <String>[
      l10n.calibrateRowScale,
      l10n.calibrateRowDensity,
      l10n.calibrateRowError,
      l10n.calibrateRowLastCalibrated,
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('CalibrationScreen states no date when nothing has been measured', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await _pump(tester);

    // A stated absence rather than a blank cell, which would read as a figure
    // that failed to load.
    expect(find.text(l10n.calibrateNotYet), findsOneWidget);
  });

  testWidgets('CalibrationScreen dates the stored scale when one exists', (
    WidgetTester tester,
  ) async {
    await _pump(tester, stored: _calibration);

    // ISO and unlocalised, so it compares by eye against the same line on
    // another device.
    expect(find.textContaining('2026-07-02'), findsOneWidget);
  });

  testWidgets('CalibrationScreen offers a reset under the one primary', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await _pump(tester);

    final double primaryTop = tester.getTopLeft(find.text(l10n.calibrateVerifyAction)).dy;
    expect(tester.getTopLeft(find.text(l10n.calibrateReset)).dy, greaterThan(primaryTop));
  });

  testWidgets('CalibrationScreen closes with what a case or a protector changes', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await _pump(tester);

    expect(find.text(l10n.calibrateGlassNote), findsOneWidget);
  });
}
