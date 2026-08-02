import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/core/ui/lonja_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

BoxDecoration _decorationOf(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(of: find.byType(LonjaPanel), matching: find.byType(DecoratedBox)),
            )
            .decoration
        as BoxDecoration;

void main() {
  testWidgets('LonjaPanel fills with the sunk stock and frames it with a hairline', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, const LonjaPanel(child: Text('x')));
    final BoxDecoration decoration = _decorationOf(tester);
    expect(decoration.color, LonjaPalettes.paper.surfaceSunk);
    expect(decoration.border!.top.color, LonjaPalettes.paper.hairline);
    expect(decoration.border!.top.width, LonjaRules.rule);
  });

  testWidgets('sunlight - LonjaPanel still draws its border when the stock equals the ground', (
    WidgetTester tester,
  ) async {
    // The single most transferable consequence of the sunlight palette. There
    // is no second stock in sunlight — surfaceSunk IS surface — so a block
    // marked only by a change of fill becomes invisible at exactly the moment
    // the fisher is standing in 100,000 lux. The border is unconditional so
    // that decision is not at a call site.
    await pumpLonja(tester, const LonjaPanel(child: Text('x')), skin: LonjaSkin.sunlight);
    final BoxDecoration decoration = _decorationOf(tester);
    expect(decoration.color, LonjaPalettes.sunlight.surface);
    expect(decoration.border!.top.color, LonjaPalettes.sunlight.hairline);
    expect(decoration.border!.top.width, greaterThan(0));
  });

  testWidgets('LonjaPanel has square corners and casts no shadow', (WidgetTester tester) async {
    await pumpLonja(tester, const LonjaPanel(child: Text('x')));
    final BoxDecoration decoration = _decorationOf(tester);
    expect(decoration.borderRadius, LonjaRadii.none);
    expect(decoration.boxShadow, isNull);
    expect(decoration.gradient, isNull);
  });

  testWidgets('glove - LonjaPanel insets by the glove gutter', (WidgetTester tester) async {
    // The sheet breathes when the hand is clumsy.
    await pumpLonja(tester, const LonjaPanel(child: Text('x')), gloved: true);
    final Padding padding = tester.widget<Padding>(
      find.descendant(of: find.byType(LonjaPanel), matching: find.byType(Padding)),
    );
    expect(padding.padding, EdgeInsetsDirectional.all(LonjaDensity.glove.gutter));
  });

  testWidgets('LonjaPanel insets by the standard gutter by default', (WidgetTester tester) async {
    await pumpLonja(tester, const LonjaPanel(child: Text('x')));
    final Padding padding = tester.widget<Padding>(
      find.descendant(of: find.byType(LonjaPanel), matching: find.byType(Padding)),
    );
    expect(padding.padding, EdgeInsetsDirectional.all(LonjaDensity.standard.gutter));
  });
}
