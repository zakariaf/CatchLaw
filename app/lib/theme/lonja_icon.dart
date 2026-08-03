import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:flutter/material.dart';

/// One glyph, stroked in the inherited ink.
///
/// The colour defaults to `DefaultTextStyle`'s, so a glyph inside a verdict
/// stamp cannot drift from the words beside it: they are one ink, set once by
/// the stamp, and there is no second place to get it wrong.
///
/// [semanticLabel] is required to be a deliberate decision rather than an
/// omission — pass one, or wrap the glyph in `ExcludeSemantics` because the
/// text beside it already says the same thing.
class LonjaIcon extends StatelessWidget {
  /// Draws [glyph] at [size].
  const LonjaIcon(
    this.glyph, {
    this.size = LonjaIconSize.ui,
    this.color,
    this.semanticLabel,
    super.key,
  });

  /// Which glyph.
  final LonjaGlyph glyph;

  /// How big its box is. The stroke does not change with it.
  final LonjaIconSize size;

  /// The ink, or the inherited text colour when null.
  final Color? color;

  /// What a screen reader says, or null when an ancestor excludes it.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bool mirror = glyph.mirrorInRtl && Directionality.of(context) == TextDirection.rtl;
    // Read here, in the widget, and handed to the painter as plain values: a
    // painter that reaches for Theme.of paints from a tree it is not painting.
    final Widget canvas = CustomPaint(
      size: Size.square(size.px),
      painter: LonjaGlyphPainter(
        glyph: glyph,
        ink:
            color ??
            DefaultTextStyle.of(context).style.color ??
            Theme.of(context).colorScheme.onSurface,
        stroke: LonjaIconTheme.of(context).stroke,
        scale: size.px / 24,
        mirror: mirror,
      ),
    );
    final String? label = semanticLabel;
    return label == null ? canvas : Semantics(label: label, child: canvas);
  }
}

/// Strokes a [LonjaGlyph] onto the canvas.
///
/// Public because a golden lane and the stamp test both construct one directly;
/// it holds no state and takes every value it paints from.
class LonjaGlyphPainter extends CustomPainter {
  /// Paints [glyph] in [ink].
  const LonjaGlyphPainter({
    required this.glyph,
    required this.ink,
    required this.stroke,
    required this.scale,
    required this.mirror,
  });

  /// What to draw.
  final LonjaGlyph glyph;

  /// The stroke colour.
  final Color ink;

  /// The burin width, constant across every size.
  final double stroke;

  /// 24-unit grid to logical pixels.
  final double scale;

  /// Whether to flip across the vertical axis.
  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (mirror) {
      // A negative x-scale and a translate, never a y-axis rotation matrix: the
      // rotation ships every glyph backwards only in the locale nobody
      // screenshots.
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    canvas
      ..scale(scale)
      ..drawPath(
        glyph.draw(),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke / scale
          ..strokeCap = StrokeCap.square
          ..strokeJoin = StrokeJoin.miter
          ..color = ink
          ..isAntiAlias = true,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(LonjaGlyphPainter oldDelegate) =>
      oldDelegate.glyph != glyph ||
      oldDelegate.ink != ink ||
      oldDelegate.stroke != stroke ||
      oldDelegate.scale != scale ||
      oldDelegate.mirror != mirror;
}
