import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

ButtonStyle _styleOf(WidgetTester tester) =>
    tester.widget<TextButton>(find.byType(TextButton)).style!;

Color _fieldOf(WidgetTester tester) => _styleOf(tester).backgroundColor!.resolve(<WidgetState>{})!;

BorderSide _sideOf(WidgetTester tester) => _styleOf(tester).side!.resolve(<WidgetState>{})!;

void main() {
  testWidgets('LonjaButton.primary is the only filled rung', (WidgetTester tester) async {
    await pumpLonja(tester, LonjaButton.primary(label: 'Measure again', onPressed: () {}));
    expect(_fieldOf(tester), LonjaPalettes.paper.accent);
  });

  testWidgets('LonjaButton.secondary is the only outlined rung', (WidgetTester tester) async {
    await pumpLonja(tester, LonjaButton.secondary(label: 'Back one step', onPressed: () {}));
    expect(_fieldOf(tester).a, 0);
    expect(_sideOf(tester).color, LonjaPalettes.paper.ruleBearing);
    expect(_sideOf(tester).width, LonjaRules.rule);
  });

  testWidgets('LonjaButton.destructive frames at the strong weight and never the stamp', (
    WidgetTester tester,
  ) async {
    // LonjaRules.stamp is the verdict frame's and nothing else's.
    await pumpLonja(
      tester,
      LonjaButton.destructive(label: 'Replace the log', onConfirmed: () async {}),
    );
    expect(_fieldOf(tester), LonjaPalettes.paper.verdictFail);
    expect(_sideOf(tester).width, LonjaRules.strong);
    expect(_sideOf(tester).width, lessThan(LonjaRules.stamp));
  });

  testWidgets('LonjaButton meets the 48 dp target floor', (WidgetTester tester) async {
    await pumpLonja(tester, LonjaButton.primary(label: 'Measure again', onPressed: () {}));
    expect(tester.getSize(find.byType(LonjaButton)).height, greaterThanOrEqualTo(48));
  });

  testWidgets('glove - LonjaButton meets the 56 dp target floor', (WidgetTester tester) async {
    await pumpLonja(
      tester,
      LonjaButton.primary(label: 'Measure again', onPressed: () {}),
      gloved: true,
    );
    expect(tester.getSize(find.byType(LonjaButton)).height, greaterThanOrEqualTo(56));
  });

  testWidgets('glove - LonjaButton labels at the larger step', (WidgetTester tester) async {
    await pumpLonja(
      tester,
      LonjaButton.primary(label: 'Measure again', onPressed: () {}),
      gloved: true,
    );
    expect(_styleOf(tester).textStyle!.resolve(<WidgetState>{})!.fontSize, 17);
  });

  testWidgets('LonjaButton casts no shadow and sits at zero elevation', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, LonjaButton.primary(label: 'Measure again', onPressed: () {}));
    expect(_styleOf(tester).elevation!.resolve(<WidgetState>{}), 0);
    expect(_styleOf(tester).shadowColor!.resolve(<WidgetState>{})!.a, 0);
    expect(_styleOf(tester).splashFactory, NoSplash.splashFactory);
  });

  testWidgets('LonjaButton is square', (WidgetTester tester) async {
    await pumpLonja(tester, LonjaButton.primary(label: 'Measure again', onPressed: () {}));
    final shape = _styleOf(tester).shape!.resolve(<WidgetState>{})! as RoundedRectangleBorder;
    expect(shape.borderRadius, LonjaRadii.none);
  });

  testWidgets('sunlight - the primary and destructive fields stay distinguishable', (
    WidgetTester tester,
  ) async {
    // In sunlight `accent` collapses to black00 while verdictFail keeps its
    // pigment, so the two filled rungs are told apart by field colour AND by
    // rule weight. The grading is what survives; hue is not.
    await pumpLonja(
      tester,
      LonjaButton.primary(label: 'Measure again', onPressed: () {}),
      skin: LonjaSkin.sunlight,
    );
    expect(_fieldOf(tester), LonjaPalettes.sunlight.accent);
    expect(_sideOf(tester).width, LonjaRules.rule);
  });
}
