import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/ruler/widgets/ruler_painter.dart';
import 'package:catchlaw/ui/ruler/widgets/ruler_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/l10n/number_symbols_guard.dart';

final RulerCalibration _calibration = RulerCalibration(
  pxPerMm: 6.299,
  capturedOn: DateTime.utc(2026, 8, 1),
);

Future<List<String>> _tickLabels(WidgetTester tester, Locale locale) async {
  final cursor = ValueNotifier<double>(45);
  addTearDown(cursor.dispose);
  await tester.pumpWidget(
    MaterialApp(
      theme: LonjaTheme.paper(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RulerView(
          calibration: _calibration,
          cursorMm: cursor,
          spanPx: 300,
          unit: LengthUnit.cm,
        ),
      ),
    ),
  );
  await tester.pump();
  final painter =
      tester.widget<CustomPaint>(find.byType(CustomPaint).last).painter! as RulerPainter;
  return painter.scene.tickLabels;
}

void main() {
  setUp(captureNumberSymbols);
  tearDown(restoreNumberSymbols);

  testWidgets('RulerView labels its ticks through the one formatter', (WidgetTester tester) async {
    // Formatted through numberFormatFor — the same function the chrome uses —
    // so a scale and the text beside it can never disagree about which digits
    // to draw.
    expect(await _tickLabels(tester, const Locale('en')), contains('1'));
  });

  testWidgets('ar - RulerView labels its ticks in Western digits by default', (
    WidgetTester tester,
  ) async {
    // CLDR 48 gives ar defaultNumberingSystem latn, and that is CORRECT for
    // Khalid in Ras Al Khaimah (E06/T04). The pin fixes the GEOMETRY, not the
    // language — a scale that came out in the wrong digits because it sat below
    // the pin would be a different bug wearing the same coat.
    expect(await _tickLabels(tester, const Locale('ar')), contains('1'));
  });

  testWidgets('ar - RulerView follows the numeral lever into Arabic-Indic digits', (
    WidgetTester tester,
  ) async {
    applyNumeralSystem(NumeralSystem.arab);
    final List<String> labels = await _tickLabels(tester, const Locale('ar'));
    // U+0661 is Arabic-Indic one. Asserted on the code point rather than
    // against a literal, because an Arabic literal in a test file is invisible
    // to review.
    expect(labels.any((String l) => l.runes.any((int r) => r >= 0x0660 && r <= 0x0669)), isTrue);
  });

  testWidgets('RulerView labels one tick per centimetre', (WidgetTester tester) async {
    // 300 px at 6.299 px/mm is 47.6 mm, so four full centimetres plus zero.
    final List<String> labels = await _tickLabels(tester, const Locale('en'));
    expect(labels, hasLength(5));
  });
}
