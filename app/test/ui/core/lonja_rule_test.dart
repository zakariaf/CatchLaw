import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

Color _inkOf(WidgetTester tester) {
  final DecoratedBox box = tester.widget<DecoratedBox>(
    find.descendant(of: find.byType(LonjaRule), matching: find.byType(DecoratedBox)),
  );
  return (box.decoration as BoxDecoration).color!;
}

double _heightOf(WidgetTester tester) => tester.getSize(find.byType(LonjaRule)).height;

void main() {
  testWidgets('LonjaRule.row draws a hairline at 0.5', (WidgetTester tester) async {
    await pumpLonja(tester, const LonjaRule.row());
    expect(_inkOf(tester), LonjaPalettes.paper.hairline);
    expect(_heightOf(tester), LonjaRules.hair);
  });

  testWidgets('LonjaRule.block draws a hairline at 1', (WidgetTester tester) async {
    await pumpLonja(tester, const LonjaRule.block());
    expect(_inkOf(tester), LonjaPalettes.paper.hairline);
    expect(_heightOf(tester), LonjaRules.rule);
  });

  testWidgets('LonjaRule.section draws a strong hairline at 2', (WidgetTester tester) async {
    await pumpLonja(tester, const LonjaRule.section());
    expect(_inkOf(tester), LonjaPalettes.paper.hairlineStrong);
    expect(_heightOf(tester), LonjaRules.strong);
  });

  testWidgets('LonjaRule.bearing draws the bearing tone at 1', (WidgetTester tester) async {
    // Anything that IDENTIFIES takes ruleBearing. hairline measures 1.37:1 on
    // paper — invisible on a wet screen at arm's length — which is fine between
    // two table rows and unacceptable as the frame of a tappable control.
    await pumpLonja(tester, const LonjaRule.bearing());
    expect(_inkOf(tester), LonjaPalettes.paper.ruleBearing);
    expect(_heightOf(tester), LonjaRules.rule);
  });

  testWidgets('LonjaRule.row follows the theme into night', (WidgetTester tester) async {
    // The whole reason a widget reads a slot rather than a pigment.
    await pumpLonja(tester, const LonjaRule.row(), skin: LonjaSkin.night);
    expect(_inkOf(tester), LonjaPalettes.night.hairline);
  });

  testWidgets('sunlight - LonjaRule.bearing is black in sunlight', (WidgetTester tester) async {
    await pumpLonja(tester, const LonjaRule.bearing(), skin: LonjaSkin.sunlight);
    expect(_inkOf(tester), LonjaPalettes.sunlight.ruleBearing);
  });

  testWidgets('LonjaRule never exceeds the stamp weight', (WidgetTester tester) async {
    // Four weights and no fifth, and .stamp is reserved for the verdict frame —
    // so no rule constructor may reach it.
    for (final rule in const <LonjaRule>[
      LonjaRule.row(),
      LonjaRule.block(),
      LonjaRule.section(),
      LonjaRule.bearing(),
    ]) {
      expect(rule.weight, lessThan(LonjaRules.stamp));
    }
  });
}
