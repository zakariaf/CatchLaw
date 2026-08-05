import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/core/ui/lonja_plate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

/// Every framed box the surface draws, outermost first.
Finder _frames() =>
    find.descendant(of: find.byType(LonjaPlateSurface), matching: find.byType(DecoratedBox));

/// The outer plate mark.
BoxDecoration _outer(WidgetTester tester) =>
    tester.widget<DecoratedBox>(_frames().first).decoration as BoxDecoration;

/// The inner keyline.
BoxDecoration _inner(WidgetTester tester) =>
    tester.widget<DecoratedBox>(_frames().at(1)).decoration as BoxDecoration;

void main() {
  testWidgets('LonjaPlateSurface frames the plate on all four edges', (WidgetTester tester) async {
    // A single top rule read as a slip pasted onto the page, which is what it
    // used to be — but the mockup engraves a frame, and a frame is the only one
    // of the two that survives sunlight deleting the change of stock.
    await pumpLonja(tester, const LonjaPlateSurface(child: Text('x')));
    final border = _outer(tester).border! as Border;

    expect(_outer(tester).color, LonjaPalettes.paper.surfaceSunk);
    expect(border.isUniform, isTrue);
    for (final side in <BorderSide>[border.top, border.bottom, border.left, border.right]) {
      expect(side.color, LonjaPalettes.paper.hairlineStrong);
      expect(side.width, LonjaRules.strong);
    }
  });

  testWidgets('LonjaPlateSurface sets a lighter keyline inside the plate mark', (
    WidgetTester tester,
  ) async {
    // Two rules of equal weight read as one border struck twice. The engraving
    // convention is a heavy plate mark with a light keyline inside it.
    await pumpLonja(tester, const LonjaPlateSurface(child: Text('x')));
    final inner = _inner(tester).border! as Border;

    expect(_frames(), findsNWidgets(2));
    expect(inner.isUniform, isTrue);
    expect(inner.top.color, LonjaPalettes.paper.hairline);
    expect(inner.top.width, LonjaRules.rule);
    expect(inner.top.width, lessThan(_outer(tester).border!.top.width));
    expect(_inner(tester).color, isNull, reason: 'the keyline tints nothing; the plate mark does');
  });

  testWidgets('LonjaPlateSurface separates the two frames by one spacing step', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, const LonjaPlateSurface(child: Text('x')));
    final Padding gap = tester.widget<Padding>(
      find.descendant(of: find.byType(LonjaPlateSurface), matching: find.byType(Padding)).first,
    );

    expect(gap.padding, const EdgeInsetsDirectional.all(LonjaSpace.s1));
  });

  testWidgets('sunlight - LonjaPlateSurface keeps both frames when the stock equals the ground', (
    WidgetTester tester,
  ) async {
    // `surfaceSunk` collapses onto `surface` at noon and both are white100, so
    // the recessed stock is not there at all: everything marking the plate has
    // to be a rule, and both rules have to be black.
    await pumpLonja(tester, const LonjaPlateSurface(child: Text('x')), skin: LonjaSkin.sunlight);

    expect(_outer(tester).color, LonjaPalettes.sunlight.surface);
    expect(_outer(tester).border!.top.width, LonjaRules.strong);
    expect(_outer(tester).border!.top.color, LonjaPalettes.sunlight.hairlineStrong);
    expect(_inner(tester).border!.top.width, LonjaRules.rule);
    expect(_inner(tester).border!.top.color, LonjaPalettes.sunlight.hairline);
  });

  testWidgets('LonjaPlateSurface has square corners and casts no shadow', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, const LonjaPlateSurface(child: Text('x')));

    for (final decoration in <BoxDecoration>[_outer(tester), _inner(tester)]) {
      expect(decoration.borderRadius, isNull);
      expect(decoration.boxShadow, isNull);
      expect(decoration.gradient, isNull);
    }
  });
}
