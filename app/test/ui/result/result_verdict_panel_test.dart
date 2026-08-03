import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_verdict_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../../../testing/theme/pump_lonja.dart';

/// The glyph the panel actually drew.
LonjaGlyph _glyphIn(WidgetTester tester) => tester.widget<LonjaIcon>(find.byType(LonjaIcon)).glyph;

/// The stamp's own `Transform`, not whichever one `MaterialApp` put in the way.
Finder _stampTransform() =>
    find.descendant(of: find.byType(ResultVerdictPanel), matching: find.byType(Transform));

/// The private `_DoubleRule` instances in the tree.
Finder _doubleRules() => find.descendant(
  of: find.byType(ResultVerdictPanel),
  matching: find.byWidgetPredicate((Widget w) => w.runtimeType.toString() == '_DoubleRule'),
);

/// Mounts the panel with [stamp], the way the screen mounts it.
///
/// One place decides how the panel is pumped, so a row that meant to vary the
/// skin cannot vary the citation by accident.
Future<void> _pumpPanel(
  WidgetTester tester,
  VerdictStampDisplay stamp, {
  LonjaSkin skin = LonjaSkin.paper,
  Locale locale = const Locale('en'),
}) => pumpLonja(
  tester,
  ResultVerdictPanel(stamp: stamp, citation: kCitationDisplayMd580),
  skin: skin,
  locale: locale,
);

void main() {
  group('ResultVerdictPanel', () {
    testWidgets('renders the glyph and the headline for a met minimum', (
      WidgetTester tester,
    ) async {
      await _pumpPanel(tester, kStampMeets);

      expect(_glyphIn(tester), LonjaIcons.tick);
      expect(find.textContaining('Meets the minimum'), findsOneWidget);
      expect(find.textContaining('Over the minimum by'), findsOneWidget);
    });

    testWidgets('renders the ban glyph for a protected species', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampProtected);

      expect(_glyphIn(tester), LonjaIcons.ban);
      expect(_glyphIn(tester), isNot(LonjaIcons.cross));
    });

    testWidgets('omits the measurement sub-line for a protected species', (
      WidgetTester tester,
    ) async {
      await _pumpPanel(tester, kStampProtected);

      expect(find.textContaining('Short of the minimum'), findsNothing);
    });

    testWidgets('omits the measurement sub-line for a closure', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampClosedSeason);

      expect(find.textContaining('Short of the minimum'), findsNothing);
      expect(find.textContaining('day 14 of 61'), findsOneWidget);
    });

    testWidgets('renders the measurement sub-line below a minimum', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampBelowMinimum);

      expect(find.textContaining('Short of the minimum by'), findsOneWidget);
    });

    testWidgets('distinguishes a prohibition from a short fish by glyph and sub-line', (
      WidgetTester tester,
    ) async {
      await _pumpPanel(tester, kStampProtected);
      final LonjaGlyph protectedGlyph = _glyphIn(tester);
      final bool protectedHasSubLine = find
          .textContaining('Short of the minimum')
          .evaluate()
          .isNotEmpty;

      await _pumpPanel(tester, kStampBelowMinimum);

      expect(protectedGlyph, isNot(_glyphIn(tester)));
      expect(
        protectedHasSubLine,
        isNot(find.textContaining('Short of the minimum').evaluate().isNotEmpty),
      );
    });

    testWidgets('draws no Card, no elevation and no shadow', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampBelowMinimum);

      expect(find.byType(Card), findsNothing);
      for (final Material material in tester.widgetList<Material>(find.byType(Material))) {
        expect(material.elevation, 0);
      }
      for (final DecoratedBox box in tester.widgetList<DecoratedBox>(find.byType(DecoratedBox))) {
        expect((box.decoration as BoxDecoration).boxShadow, anyOf(isNull, isEmpty));
      }
    });

    testWidgets('strikes the stamp at the fixed tilt', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampBelowMinimum);

      final Transform transform = tester.widget<Transform>(_stampTransform());
      expect(transform.transform, Matrix4.rotationZ(kVerdictStampTilt));
    });

    testWidgets('strikes a double rule above and below the block', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampBelowMinimum);

      expect(_doubleRules(), findsNWidgets(2));
    });

    testWidgets('sunlight - reverses the stamp out with no tilt', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampBelowMinimum, skin: LonjaSkin.sunlight);

      final Transform transform = tester.widget<Transform>(_stampTransform());
      expect(transform.transform, Matrix4.identity());
      expect(_doubleRules(), findsNWidgets(2));
    });

    testWidgets('sunlight - prints the block in the ground colour', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampBelowMinimum, skin: LonjaSkin.sunlight);

      final Text headline = tester.widget<Text>(find.textContaining('Below the minimum'));
      final DefaultTextStyle inherited = DefaultTextStyle.of(
        tester.element(find.textContaining('Below the minimum')),
      );
      expect(headline.style?.color, isNull, reason: 'the ink is inherited, never set per text');
      expect(inherited.style.color, LonjaPalettes.sunlight.surface);
    });

    testWidgets('RTL - places the glyph at the start edge', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampBelowMinimum, locale: const Locale('ar'));

      final double glyphStart = tester.getTopRight(find.byType(LonjaIcon)).dx;
      final double headlineStart = tester.getTopRight(find.textContaining('Below the minimum')).dx;
      expect(glyphStart, greaterThan(headlineStart), reason: 'start is the right edge under RTL');
    });

    testWidgets('ar - wraps a long headline instead of truncating it', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampBelowMinimum, locale: const Locale('ar'));

      expect(find.byType(FittedBox), findsNothing);
      for (final Text text in tester.widgetList<Text>(find.byType(Text))) {
        expect(text.overflow, isNot(TextOverflow.ellipsis));
        expect(text.maxLines, isNull);
      }
    });

    testWidgets('survives a 200 percent text scale with no overflow', (WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(1080, 1920)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      // Mounted the way the screen mounts it, inside a scroll view: §4.9's
      // target is that nothing is clipped or clamped at 200%, and the PAGE
      // scrolls. The ambient MediaQuery is COPIED rather than replaced — a
      // fresh MediaQueryData carries a zero size, which lays the tree out
      // against nothing and reports an overflow that is about the harness.
      await pumpLonja(
        tester,
        Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
            child: const SingleChildScrollView(
              child: ResultVerdictPanel(stamp: kStampBelowMinimum, citation: kCitationDisplayMd580),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
