import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

LonjaGlyphPainter _painterOf(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((CustomPaint paint) => paint.painter)
    .whereType<LonjaGlyphPainter>()
    .single;

TextStyle _styleOf(WidgetTester tester, String text) => tester.widget<Text>(find.text(text)).style!;

void main() {
  testWidgets('LonjaScreenBar prints the title and the trailing context stamp', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, LonjaScreenBar(title: 'Hamour', sup: 'RAS AL KHAIMAH', onBack: () {}));

    expect(find.text('Hamour'), findsOneWidget);
    expect(find.text('RAS AL KHAIMAH'), findsOneWidget);
  });

  testWidgets('LonjaScreenBar sets the title in the serif subtitle step', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, const LonjaScreenBar(title: 'Hamour'));

    expect(_styleOf(tester, 'Hamour'), LonjaTypeScale.latin().subtitle);
  });

  testWidgets('LonjaScreenBar sets the context stamp in the mono article step, muted', (
    WidgetTester tester,
  ) async {
    // The stamp is a place, not a sentence: mono, tracked and quiet, so it
    // never competes with the title for the five-second read.
    await pumpLonja(tester, const LonjaScreenBar(title: 'Hamour', sup: 'RAS AL KHAIMAH'));

    final TextStyle style = _styleOf(tester, 'RAS AL KHAIMAH');
    expect(style.fontSize, LonjaTypeScale.latin().articleNumber.fontSize);
    expect(style.fontFamily, LonjaTypeScale.latin().articleNumber.fontFamily);
    expect(style.color, LonjaPalettes.paper.onSurfaceMuted);
  });

  testWidgets('LonjaScreenBar aligns the context stamp to the trailing edge', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, const LonjaScreenBar(title: 'Hamour', sup: 'RAS AL KHAIMAH'));

    final double barEnd = tester.getBottomRight(find.byType(LonjaScreenBar)).dx;
    final double stampEnd = tester.getBottomRight(find.text('RAS AL KHAIMAH')).dx;
    final double titleEnd = tester.getBottomRight(find.text('Hamour')).dx;
    expect(stampEnd, greaterThan(titleEnd));
    expect(barEnd - stampEnd, LonjaDensity.standard.gutter);
  });

  testWidgets('LonjaScreenBar omits the stamp when no context is given', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, const LonjaScreenBar(title: 'Hamour'));

    expect(find.text('Hamour'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('LonjaScreenBar rules its foot with a hairline', (WidgetTester tester) async {
    await pumpLonja(tester, const LonjaScreenBar(title: 'Hamour'));

    final LonjaRule rule = tester.widget<LonjaRule>(find.byType(LonjaRule));
    expect(rule.weight, LonjaRules.rule);
  });

  testWidgets('LonjaScreenBar carries the back glyph when a handler is given', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, LonjaScreenBar(title: 'Hamour', onBack: () {}));

    expect(_painterOf(tester).glyph, LonjaIcons.back);
  });

  testWidgets('LonjaScreenBar omits the back affordance when no handler is given', (
    WidgetTester tester,
  ) async {
    // A bar on a root branch has nowhere to go back to, and a dead chevron is
    // a control that reads as broken.
    await pumpLonja(tester, const LonjaScreenBar(title: 'Hamour'));

    expect(find.byType(LonjaIcon), findsNothing);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('LonjaScreenBar leaves the current screen when the back target is taken', (
    WidgetTester tester,
  ) async {
    var taken = 0;
    await pumpLonja(tester, LonjaScreenBar(title: 'Hamour', onBack: () => taken++));

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(taken, 1);
  });

  testWidgets('LonjaScreenBar names the back target for a screen reader', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, LonjaScreenBar(title: 'Hamour', onBack: () {}));

    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    expect(tester.widget<IconButton>(find.byType(IconButton)).tooltip, 'Back');
  });

  testWidgets('LonjaScreenBar holds the back target at the density floor', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, LonjaScreenBar(title: 'Hamour', onBack: () {}));

    final Size size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(LonjaDensity.standard.tapMin));
    expect(size.height, greaterThanOrEqualTo(LonjaDensity.standard.tapMin));
  });

  testWidgets('glove - LonjaScreenBar widens the back target for a wet hand', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, LonjaScreenBar(title: 'Hamour', onBack: () {}), gloved: true);

    final Size size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(LonjaDensity.glove.tapMin));
    expect(size.height, greaterThanOrEqualTo(LonjaDensity.glove.tapMin));
  });

  testWidgets('LonjaScreenBar reports one height in both densities', (WidgetTester tester) async {
    // A PreferredSizeWidget answers before it has a BuildContext, so the band
    // cannot resize with the density — and a chrome band that changed height
    // under the thumb would move the title mid-read.
    const bar = LonjaScreenBar(title: 'Hamour');
    expect(bar.preferredSize.height, greaterThanOrEqualTo(LonjaDensity.glove.tapMin));

    for (final gloved in <bool>[false, true]) {
      await pumpLonja(
        tester,
        const Scaffold(appBar: LonjaScreenBar(title: 'Hamour')),
        gloved: gloved,
      );
      expect(
        tester.getSize(find.byType(LonjaScreenBar)).height,
        bar.preferredSize.height,
        reason: 'gloved: $gloved',
      );
    }
  });

  testWidgets('ar - LonjaScreenBar mirrors the back glyph', (WidgetTester tester) async {
    // The chevron points at the edge the previous screen went out through, and
    // in Arabic that edge is the other one.
    await pumpLonja(
      tester,
      LonjaScreenBar(title: 'هامور', onBack: () {}),
      locale: const Locale('ar'),
    );

    expect(_painterOf(tester).mirror, isTrue);
  });

  testWidgets('LonjaScreenBar leaves the back glyph unmirrored in a left-to-right locale', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, LonjaScreenBar(title: 'Hamour', onBack: () {}));

    expect(_painterOf(tester).mirror, isFalse);
  });
}
