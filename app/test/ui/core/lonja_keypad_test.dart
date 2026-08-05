import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/ui/core/ui/lonja_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/l10n/number_symbols_guard.dart';
import '../../../testing/theme/pump_lonja.dart';

void main() {
  setUp(captureNumberSymbols);
  tearDown(restoreNumberSymbols);

  testWidgets('LonjaKeypad lays ten digits and a delete over four rows', (
    WidgetTester tester,
  ) async {
    // A shape before it is a set of controls. A Wrap reflows with the text
    // scale and the locale, so the key under a thumb moves between two phones
    // — and a fisher entering 450 with wet hands is typing by position.
    await pumpLonja(
      tester,
      LonjaKeypad(onDigit: (int _) {}, onBackspace: () {}, backspaceLabel: 'Back'),
    );

    for (var digit = 0; digit <= 9; digit++) {
      expect(find.text('$digit'), findsOneWidget, reason: '$digit');
    }
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('LonjaKeypad keeps 1, 4 and 7 on one column and 2 under 1', (
    WidgetTester tester,
  ) async {
    await pumpLonja(
      tester,
      LonjaKeypad(onDigit: (int _) {}, onBackspace: () {}, backspaceLabel: 'Back'),
    );

    final double one = tester.getCenter(find.text('1')).dx;
    expect(tester.getCenter(find.text('4')).dx, one);
    expect(tester.getCenter(find.text('7')).dx, one);
    expect(tester.getCenter(find.text('2')).dy, tester.getCenter(find.text('1')).dy);
    expect(tester.getCenter(find.text('4')).dy, greaterThan(tester.getCenter(find.text('1')).dy));
  });

  testWidgets('LonjaKeypad sits the zero under the eight', (WidgetTester tester) async {
    await pumpLonja(
      tester,
      LonjaKeypad(onDigit: (int _) {}, onBackspace: () {}, backspaceLabel: 'Back'),
    );

    expect(tester.getCenter(find.text('0')).dx, tester.getCenter(find.text('8')).dx);
    expect(tester.getCenter(find.text('0')).dy, greaterThan(tester.getCenter(find.text('8')).dy));
  });

  testWidgets('LonjaKeypad reports the digit that was pressed', (WidgetTester tester) async {
    final pressed = <int>[];
    var deletes = 0;
    await pumpLonja(
      tester,
      LonjaKeypad(onDigit: pressed.add, onBackspace: () => deletes++, backspaceLabel: 'Back'),
    );

    await tester.tap(find.text('4'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('0'));
    await tester.tap(find.text('Back'));

    expect(pressed, <int>[4, 5, 0]);
    expect(deletes, 1);
  });

  testWidgets('LonjaKeypad holds every key at the density floor', (WidgetTester tester) async {
    await pumpLonja(
      tester,
      LonjaKeypad(onDigit: (int _) {}, onBackspace: () {}, backspaceLabel: 'Back'),
    );

    // 48 dp ungloved. A key smaller than the floor is a mistyped length, and a
    // mistyped length is a fish measured wrong.
    expect(tester.getSize(find.byType(InkWell).first).height, greaterThanOrEqualTo(48));
  });

  testWidgets('ar - LonjaKeypad draws its keys in the digits the reader asked for', (
    WidgetTester tester,
  ) async {
    // An Arabic reader who has asked for Arabic-Indic figures must find the
    // same glyph on the key and in the readout above it. U+0664 is four.
    applyNumeralSystem(NumeralSystem.arab);
    await pumpLonja(
      tester,
      LonjaKeypad(onDigit: (int _) {}, onBackspace: () {}, backspaceLabel: 'حذف'),
      locale: const Locale('ar'),
    );

    expect(find.text(String.fromCharCode(0x0664)), findsOneWidget);
    expect(find.text('4'), findsNothing);
  });
}
