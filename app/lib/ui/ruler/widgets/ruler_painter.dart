import 'dart:typed_data';
import 'dart:ui' show PointMode;

import 'package:catchlaw/ui/ruler/widgets/ruler_scene.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/rendering.dart';

/// Draws the rule, its ticks, its labels and the moving cursor.
///
/// **The constructor allocates; `paint` does not.** Every `Paint`, every tick
/// vertex and every label `TextPainter` is built once, here, and `paint` walks
/// them. A painter that laid out sixty `TextPainter`s per frame would drop
/// frames under a drag on exactly the phone `SPEC.md` §13 budgets for.
///
/// The cursor arrives through `repaint:` as a `ValueListenable<double>` rather
/// than through the scene, because it changes on every pointer move and the
/// scene does not. Repainting on the listenable leaves `shouldRepaint` free to
/// be a single cheap compare.
class RulerPainter extends CustomPainter {
  /// Paints [scene], with [cursorMm] driving the mark.
  RulerPainter({required this.scene, required this.cursorMm})
    : _ink = Paint()
        ..color = scene.ink
        ..strokeWidth = scene.hairlinePx
        ..isAntiAlias = false,
      _tick = Paint()
        ..color = scene.ink
        ..strokeWidth = scene.tickPx
        ..isAntiAlias = false,
      _mark = Paint()
        ..color = scene.mark
        ..strokeWidth = scene.cursorPx
        ..isAntiAlias = false,
      super(repaint: cursorMm) {
    _buildTicks();
    _buildLabels();
  }

  /// One frame's worth of ruler.
  final RulerScene scene;

  /// Where the mark sits, in millimetres.
  final ValueListenable<double> cursorMm;

  final Paint _ink;
  final Paint _tick;
  final Paint _mark;

  /// Tick vertices, as pairs of points. Built once.
  late final Float32List _tickPoints;

  /// Every centimetre label, laid out once.
  late final List<TextPainter> _labels = <TextPainter>[];

  /// A reusable two-point buffer for the cursor, so a drag allocates nothing.
  final Float32List _cursorPoints = Float32List(4);

  void _buildTicks() {
    final int millimetres = (scene.spanPx / scene.pxPerMm).floor();
    final points = <double>[];
    for (var mm = 0; mm <= millimetres; mm++) {
      // The SAME transform the hit-tester uses, in the same direction. Deriving
      // tick positions from `size` instead is how a painter and a hit-tester
      // come to disagree by three pixels.
      final double x = mm * scene.pxPerMm;
      // A centimetre reads at arm's length, a half-centimetre orients, and a
      // millimetre is only there so the eye can count between them.
      final double height = switch (mm % 10) {
        0 => 22.0,
        5 => 14.0,
        _ => 8.0,
      };
      points
        ..add(x)
        ..add(0)
        ..add(x)
        ..add(height);
    }
    _tickPoints = Float32List.fromList(points);
  }

  void _buildLabels() {
    for (final String label in scene.tickLabels) {
      _labels.add(
        TextPainter(
          text: TextSpan(text: label, style: scene.labelStyle),
          textDirection: scene.labelDirection,
        )..layout(),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..drawLine(Offset.zero, Offset(scene.spanPx, 0), _ink)
      ..drawRawPoints(PointMode.lines, _tickPoints, _tick);

    for (var i = 0; i < _labels.length; i++) {
      final TextPainter label = _labels[i];
      label.paint(canvas, Offset(i * 10 * scene.pxPerMm + 2, 24));
    }

    final double x = cursorMm.value * scene.pxPerMm;
    _cursorPoints[0] = x;
    _cursorPoints[1] = 0;
    _cursorPoints[2] = x;
    _cursorPoints[3] = size.height;
    canvas.drawRawPoints(PointMode.lines, _cursorPoints, _mark);
  }

  @override
  bool shouldRepaint(RulerPainter oldDelegate) => oldDelegate.scene != scene;
}
