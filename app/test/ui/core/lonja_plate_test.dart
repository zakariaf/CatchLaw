import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/core/ui/lonja_plate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

BoxDecoration _decorationOf(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(
                of: find.byType(LonjaPlateSurface),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration
        as BoxDecoration;

void main() {
  testWidgets('LonjaPlateSurface draws a strong top rule over sunk stock', (
    WidgetTester tester,
  ) async {
    // Edge to edge, which is what makes it read as a slip pasted onto the page
    // rather than as a card floating above it.
    await pumpLonja(tester, const LonjaPlateSurface(child: Text('x')));
    final BoxDecoration decoration = _decorationOf(tester);
    expect(decoration.color, LonjaPalettes.paper.surfaceSunk);
    expect(decoration.border!.top.color, LonjaPalettes.paper.hairlineStrong);
    expect(decoration.border!.top.width, LonjaRules.strong);
  });

  testWidgets('LonjaPlateSurface rules only its top edge', (WidgetTester tester) async {
    await pumpLonja(tester, const LonjaPlateSurface(child: Text('x')));
    final border = _decorationOf(tester).border! as BorderDirectional;
    expect(border.bottom, BorderSide.none);
    expect(border.start, BorderSide.none);
    expect(border.end, BorderSide.none);
  });

  testWidgets('sunlight - LonjaPlateSurface keeps its rule when the stock equals the ground', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, const LonjaPlateSurface(child: Text('x')), skin: LonjaSkin.sunlight);
    expect(_decorationOf(tester).border!.top.width, LonjaRules.strong);
  });

  testWidgets('LonjaPlateSurface has square corners and casts no shadow', (
    WidgetTester tester,
  ) async {
    // A BoxDecoration asserts that a non-uniform border carries no radius, so
    // square here is the ABSENCE of one rather than LonjaRadii.none — which is
    // the same thing the 2 dp ceiling says, enforced by the framework.
    await pumpLonja(tester, const LonjaPlateSurface(child: Text('x')));
    final BoxDecoration decoration = _decorationOf(tester);
    expect(decoration.borderRadius, isNull);
    expect(decoration.boxShadow, isNull);
    expect(decoration.gradient, isNull);
  });
}
