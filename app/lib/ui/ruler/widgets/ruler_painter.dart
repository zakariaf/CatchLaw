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
      _cmTick = Paint()
        ..color = scene.ink
        ..strokeWidth = scene.cmTickPx
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

  /// How tall each class of tick stands, in logical pixels.
  ///
  /// A centimetre reads at arm's length, a half-centimetre orients, and a
  /// millimetre is only there so the eye can count between them. The three
  /// heights and the two weights together are what let a fisher find 42 cm on
  /// a wet screen without counting from zero.
  static const double cmTickHeight = 30;

  /// The half-centimetre tick.
  static const double halfCmTickHeight = 18;

  /// The millimetre tick.
  static const double mmTickHeight = 10;

  /// Where the centimetre numerals sit — a row of their own, under the band.
  static const double labelTop = 36;

  /// How far a numeral is inset from the tick it names.
  static const double labelInset = 3;

  final Paint _ink;
  final Paint _tick;
  final Paint _cmTick;
  final Paint _mark;

  /// Millimetre and half-centimetre tick vertices, as pairs of points. Built
  /// once.
  late final Float32List _tickPoints;

  /// Centimetre tick vertices, drawn with the heavier paint. Built once.
  late final Float32List _cmTickPoints;

  /// Every centimetre label, laid out once.
  late final List<TextPainter> _labels = <TextPainter>[];

  /// A reusable two-point buffer for the cursor, so a drag allocates nothing.
  final Float32List _cursorPoints = Float32List(4);

  void _buildTicks() {
    final int millimetres = (scene.spanPx / scene.pxPerMm).floor();
    final points = <double>[];
    final cmPoints = <double>[];
    for (var mm = 0; mm <= millimetres; mm++) {
      // The SAME transform the hit-tester uses, in the same direction. Deriving
      // tick positions from `size` instead is how a painter and a hit-tester
      // come to disagree by three pixels.
      final double x = mm * scene.pxPerMm;
      final isCentimetre = mm % 10 == 0;
      final double height = switch (mm % 10) {
        0 => cmTickHeight,
        5 => halfCmTickHeight,
        _ => mmTickHeight,
      };
      // Two buffers rather than one, because the centimetre is stroked heavier
      // and a canvas takes one width per call.
      (isCentimetre ? cmPoints : points)
        ..add(x)
        ..add(0)
        ..add(x)
        ..add(height);
    }
    _tickPoints = Float32List.fromList(points);
    _cmTickPoints = Float32List.fromList(cmPoints);
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
      ..drawRawPoints(PointMode.lines, _tickPoints, _tick)
      ..drawRawPoints(PointMode.lines, _cmTickPoints, _cmTick);

    for (var i = 0; i < _labels.length; i++) {
      final TextPainter label = _labels[i];
      // Under the band and inset from its own tick, so the numeral row reads as
      // a row rather than as ink hanging off the scale.
      label.paint(canvas, Offset(i * 10 * scene.pxPerMm + labelInset, labelTop));
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
