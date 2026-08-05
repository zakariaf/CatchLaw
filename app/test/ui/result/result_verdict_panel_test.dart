import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
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
    testWidgets('renders the glyph and three registers for a met minimum', (
      WidgetTester tester,
    ) async {
      await _pumpPanel(tester, kStampMeets);

      expect(_glyphIn(tester), LonjaIcons.tick);
      // The state alone in the headline, cased at the call site; the figures
      // and the margin in their own registers beneath it.
      expect(find.text('MEETS THE MINIMUM'), findsOneWidget);
      expect(find.text('70\u00A0cm measured · minimum 65\u00A0cm · Fork length'), findsOneWidget);
      expect(find.text('OVER THE MINIMUM BY 5\u00A0CM'), findsOneWidget);
    });

    testWidgets('sets the headline, the figures and the margin in three ramp steps', (
      WidgetTester tester,
    ) async {
      await _pumpPanel(tester, kStampBelowMinimum);
      final type = LonjaTypeScale.latin();

      final BuildContext context = tester.element(find.text('BELOW THE MINIMUM'));
      TextStyle resolved(Finder finder) => DefaultTextStyle.of(
        tester.element(finder),
      ).style.merge(tester.widget<Text>(finder).style);

      expect(resolved(find.text('BELOW THE MINIMUM')).fontSize, type.title.fontSize);
      expect(
        resolved(find.text('38\u00A0cm measured · minimum 45\u00A0cm · Total length')).fontSize,
        type.datum.fontSize,
        reason: 'the figures are mono and one register down, never the 42 pt verdict step',
      );
      expect(
        resolved(find.text('SHORT OF THE MINIMUM BY 7\u00A0CM')).fontSize,
        type.microLabel.fontSize,
      );
      expect(LonjaType.of(context).verdict.fontSize, isNot(type.title.fontSize));
    });

    testWidgets('draws the figures for a closure and the margin for none', (
      WidgetTester tester,
    ) async {
      await _pumpPanel(tester, kStampClosedSeason);

      expect(find.text('In force today, day 14 of 61 · applies at every size'), findsOneWidget);
      expect(find.textContaining('SHORT OF THE MINIMUM'), findsNothing);
    });

    testWidgets('draws neither figures nor margin for a protected species', (
      WidgetTester tester,
    ) async {
      // Both are supplied on the fixture on purpose: the CATEGORY drops them.
      await _pumpPanel(tester, kStampProtected);

      expect(find.textContaining('measured'), findsNothing);
      expect(find.textContaining('SHORT OF THE MINIMUM'), findsNothing);
    });

    testWidgets('renders the ban glyph for a protected species', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampProtected);

      expect(_glyphIn(tester), LonjaIcons.ban);
      expect(_glyphIn(tester), isNot(LonjaIcons.cross));
    });

    testWidgets('omits the margin for a protected species', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampProtected);

      expect(find.textContaining('SHORT OF THE MINIMUM'), findsNothing);
    });

    testWidgets('omits the margin for a closure and keeps its own figures', (
      WidgetTester tester,
    ) async {
      await _pumpPanel(tester, kStampClosedSeason);

      expect(find.textContaining('SHORT OF THE MINIMUM'), findsNothing);
      expect(find.textContaining('day 14 of 61'), findsOneWidget);
    });

    testWidgets('renders the margin below a minimum', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampBelowMinimum);

      expect(find.textContaining('SHORT OF THE MINIMUM BY'), findsOneWidget);
    });

    testWidgets('distinguishes a prohibition from a short fish by glyph and margin', (
      WidgetTester tester,
    ) async {
      await _pumpPanel(tester, kStampProtected);
      final LonjaGlyph protectedGlyph = _glyphIn(tester);
      final bool protectedHasMargin = find
          .textContaining('SHORT OF THE MINIMUM')
          .evaluate()
          .isNotEmpty;

      await _pumpPanel(tester, kStampBelowMinimum);

      expect(protectedGlyph, isNot(_glyphIn(tester)));
      expect(
        protectedHasMargin,
        isNot(find.textContaining('SHORT OF THE MINIMUM').evaluate().isNotEmpty),
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

    testWidgets('sets the block one s6 step below whatever is printed above it', (
      WidgetTester tester,
    ) async {
      // `.stamp{margin:var(--s6) var(--s4) 0}`. It was s7 — 48 dp of nothing
      // between the plate caption and the answer.
      await _pumpPanel(tester, kStampBelowMinimum);
      final Padding outer = tester.widget<Padding>(
        find.descendant(of: find.byType(ResultVerdictPanel), matching: find.byType(Padding)).first,
      );

      expect(
        outer.padding,
        const EdgeInsetsDirectional.fromSTEB(LonjaSpace.s4, LonjaSpace.s6, LonjaSpace.s4, 0),
      );
    });

    testWidgets('sunlight - reverses the stamp out with no tilt', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampBelowMinimum, skin: LonjaSkin.sunlight);

      final Transform transform = tester.widget<Transform>(_stampTransform());
      expect(transform.transform, Matrix4.identity());
    });

    testWidgets('sunlight - drops the double rules once the block reverses out', (
      WidgetTester tester,
    ) async {
      // A solid field of ink IS the frame. Keeping the rules printed two white
      // hairlines inside the oxblood, which at 100 000 lux is not a faint mark
      // but a missing one — and a frame that is absent on the one skin built
      // for glare is worse than no frame at all.
      await _pumpPanel(tester, kStampBelowMinimum, skin: LonjaSkin.sunlight);

      expect(_doubleRules(), findsNothing);
    });

    testWidgets('sunlight - insets the reversed block by a full spacing step', (
      WidgetTester tester,
    ) async {
      // `.phone.sun .stamp{padding:var(--s5) var(--s4)}`. A flat s3 set the
      // words hard against the edge of the field.
      await _pumpPanel(tester, kStampBelowMinimum, skin: LonjaSkin.sunlight);
      // The one ColoredBox left inside the panel once the rules are gone is
      // the reversed ground, and the Padding directly under it is the inset.
      final Finder ground = find.descendant(
        of: find.byType(ResultVerdictPanel),
        matching: find.byType(ColoredBox),
      );
      expect(ground, findsOneWidget);
      final Padding inset = tester.widget<Padding>(
        find.descendant(of: ground, matching: find.byType(Padding)).first,
      );

      expect(
        inset.padding,
        const EdgeInsetsDirectional.symmetric(horizontal: LonjaSpace.s4, vertical: LonjaSpace.s5),
      );
    });

    testWidgets('sunlight - prints the block in the ground colour', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampBelowMinimum, skin: LonjaSkin.sunlight);

      final Text headline = tester.widget<Text>(find.text('BELOW THE MINIMUM'));
      final DefaultTextStyle inherited = DefaultTextStyle.of(
        tester.element(find.text('BELOW THE MINIMUM')),
      );
      expect(headline.style?.color, isNull, reason: 'the ink is inherited, never set per text');
      expect(inherited.style.color, LonjaPalettes.sunlight.surface);
    });

    testWidgets('RTL - places the glyph at the start edge', (WidgetTester tester) async {
      await _pumpPanel(tester, kStampBelowMinimum, locale: const Locale('ar'));

      final double glyphStart = tester.getTopRight(find.byType(LonjaIcon)).dx;
      final double headlineStart = tester.getTopRight(find.text('BELOW THE MINIMUM')).dx;
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
