import 'dart:io';

import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/pump_lonja.dart';

void main() {
  group('LonjaIcons', () {
    test('draws every glyph on the 24-unit grid', () {
      for (final LonjaGlyph glyph in <LonjaGlyph>[
        LonjaIcons.tick,
        LonjaIcons.cross,
        LonjaIcons.ban,
        LonjaIcons.closedSeason,
      ]) {
        final Rect bounds = glyph.draw().getBounds();
        // Off the grid is a glyph that clips at one size and floats at another.
        expect(bounds.left, greaterThanOrEqualTo(0), reason: glyph.name);
        expect(bounds.top, greaterThanOrEqualTo(0), reason: glyph.name);
        expect(bounds.right, lessThanOrEqualTo(24), reason: glyph.name);
        expect(bounds.bottom, lessThanOrEqualTo(24), reason: glyph.name);
      }
    });

    test('mirrors no verdict glyph under RTL', () {
      // A tick, a cross and a ban are fixed-meaning marks. Mirroring them makes
      // an Arabic screen look like a different app rather than the same one
      // read the other way.
      for (final LonjaGlyph glyph in <LonjaGlyph>[
        LonjaIcons.tick,
        LonjaIcons.cross,
        LonjaIcons.ban,
        LonjaIcons.closedSeason,
      ]) {
        expect(glyph.mirrorInRtl, isFalse, reason: glyph.name);
      }
    });

    test('declares four sizes and no fifth', () {
      expect(LonjaIconSize.values.map((LonjaIconSize s) => s.px).toList(), <double>[
        16,
        22,
        30,
        44,
      ]);
    });
  });

  group('LonjaIconTheme', () {
    testWidgets('widens the burin in sunlight and nowhere else', (WidgetTester tester) async {
      final strokes = <LonjaSkin, double>{};
      for (final LonjaSkin skin in LonjaSkin.values) {
        await pumpLonja(
          tester,
          Builder(
            builder: (BuildContext context) {
              strokes[skin] = LonjaIconTheme.of(context).stroke;
              return const SizedBox.shrink();
            },
          ),
          skin: skin,
        );
        // MaterialApp animates a theme change over 200 ms, and both extensions
        // interpolate: read before the animation settles and the assertion is
        // about a frame halfway between two themes.
        await tester.pumpAndSettle();
      }

      expect(strokes[LonjaSkin.paper], 1.45);
      expect(strokes[LonjaSkin.night], 1.45);
      // At 100 000 lux a 1.45 stroke is absent rather than thin.
      expect(strokes[LonjaSkin.sunlight], 1.95);
    });

    testWidgets('holds the stroke constant across all four sizes', (WidgetTester tester) async {
      for (final LonjaIconSize size in LonjaIconSize.values) {
        await pumpLonja(tester, LonjaIcon(LonjaIcons.tick, size: size, semanticLabel: 'tick'));
        await tester.pumpAndSettle();

        final LonjaGlyphPainter painter = tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .map((CustomPaint p) => p.painter)
            .whereType<LonjaGlyphPainter>()
            .single;
        // Scaling the stroke with the box is what makes a 44 px mark read as a
        // different family from a 16 px one.
        expect(painter.stroke, 1.45, reason: size.name);
        expect(painter.scale, size.px / 24, reason: size.name);
      }
    });
  });

  group('LonjaSkinScope', () {
    testWidgets('reports the skin the tree renders in', (WidgetTester tester) async {
      for (final LonjaSkin skin in LonjaSkin.values) {
        late LonjaSkin seen;
        await pumpLonja(
          tester,
          Builder(
            builder: (BuildContext context) {
              seen = LonjaSkinScope.of(context);
              return const SizedBox.shrink();
            },
          ),
          skin: skin,
        );
        await tester.pumpAndSettle();
        expect(seen, skin);
      }
    });

    test('is read by exactly one file under app/lib', () {
      // E07's doctrine is that a widget never branches on the skin — the palette
      // does the work. The verdict stamp is the one sanctioned exception (D-20),
      // because reversing out is a change of construction and no palette entry
      // can express one. This test is what keeps the exception single.
      final List<File> dartFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((File f) => f.path.endsWith('.dart'))
          .toList();
      expect(
        dartFiles,
        isNotEmpty,
        reason: 'a scan over no files is not evidence about any of them',
      );

      final List<String> readers = dartFiles
          .where((File f) => !f.path.startsWith('lib/theme/'))
          .where((File f) => f.readAsStringSync().contains('LonjaSkinScope.of'))
          .map((File f) => f.path)
          .toList();

      expect(readers, <String>['lib/ui/result/widgets/result_verdict_panel.dart']);
    });
  });
}
