// Demonstrates a zero-allocation CatchLaw ruler: an immutable RulerScene carrying textDirection,
// pxPerMm, lengthMm and the localised method label; a RulerPainter that builds every Paint,
// TextPainter, tick vertex and label origin ONCE in its constructor so paint() allocates nothing;
// and a shouldRepaint comparing every field, textDirection included. Above it, RulerView pins the
// ruler subtree to TextDirection.ltr — a physical scale never mirrors — while the labels keep the
// AMBIENT direction, read from the context BEFORE the pin and handed in as a plain field, because
// a CustomPainter has no BuildContext and cannot read an InheritedWidget. Calibration, the
// plausibility gate and step-and-mark live in SKILL.md and the references.
// Conceptually compiles against package:flutter/widgets.dart.

import 'dart:typed_data' show Float32List;
import 'dart:ui' as ui show FontFeature, PointMode;

import 'package:flutter/widgets.dart';

enum NumeralSystem { latin, arabicIndic }

// Scene: an immutable snapshot with == over every field. The painter reads no widget tree.
@immutable
final class RulerScene {
  const RulerScene({
    required this.textDirection, required this.numerals, required this.pxPerMm,
    required this.spanPx, required this.lengthMm, required this.methodLabel,
    required this.ink, required this.mark,
  });

  /// The AMBIENT direction, captured before the ltr pin: labels localise, the scale does not.
  final TextDirection textDirection;
  final NumeralSystem numerals; // Arabic-Indic in ar, Latin in en, es, gl, pt
  final double pxPerMm;         // from the stored calibration; never a constant
  final double spanPx;          // from the LayoutBuilder — a resize is simply a new Scene
  final int lengthMm;           // running step-and-mark total: 450 Hamour, 650 Kanaad, 38 Ameixa
  final String methodLabel;     // localised upstream by l10n, never assembled inside paint()
  final Color ink;              // lonja ink #16201C
  final Color mark;             // lonja harbour #1B4D5E

  @override
  bool operator ==(Object o) =>
      o is RulerScene && o.textDirection == textDirection && o.numerals == numerals &&
          o.pxPerMm == pxPerMm && o.spanPx == spanPx && o.lengthMm == lengthMm &&
          o.methodLabel == methodLabel && o.ink == ink && o.mark == mark;
  @override
  int get hashCode =>
      Object.hash(textDirection, numerals, pxPerMm, spanPx, lengthMm, methodLabel, ink, mark);
}

// The view: the ruler subtree does NOT mirror; the chrome around it does.
class RulerView extends StatelessWidget {
  const RulerView({
    required this.pxPerMm, required this.lengthMm, required this.methodLabel,
    required this.numerals, super.key,
  });

  final double pxPerMm;     // from RulerCalibration, which rejected anything implausible
  final int lengthMm;       // integer millimetres, rounded exactly once at capture
  final String methodLabel; // "total length (TL)" or "الطول الكلي" — resolved by l10n, not here
  final NumeralSystem numerals;

  @override
  Widget build(BuildContext context) {
    final ambient = Directionality.of(context); // read BEFORE the pin below
    return LayoutBuilder(
      builder: (context, box) => Directionality(
        // catchlaw: a physical scale never mirrors. Mirroring puts zero at the tail of a real
        // fish while the fisher's hand is at the snout. Deliberate, reviewed exception — rule 4.
        textDirection: TextDirection.ltr,
        child: CustomPaint(
          size: Size(box.maxWidth, 96),
          painter: RulerPainter(RulerScene(
            textDirection: ambient, numerals: numerals, pxPerMm: pxPerMm,
            spanPx: box.maxWidth, lengthMm: lengthMm, methodLabel: methodLabel,
            ink: const Color(0xFF16201C), mark: const Color(0xFF1B4D5E),
          )),
        ),
      ),
    );
  }
}

class RulerPainter extends CustomPainter {
  RulerPainter(this.scene)
      : _tick = (Paint()..color = scene.ink..strokeWidth = 1.5),
        _cursor = (Paint()..color = scene.mark..strokeWidth = 3),
        _ticks = _tickVertices(scene),
        _cursorLine = _cursorVertices(scene) {
    _layoutGlyphs(); // every glyph shaped and measured ONCE, here — never per frame
  }

  final RulerScene scene;
  final Paint _tick, _cursor;
  final Float32List _ticks, _cursorLine; // x0,y0,x1,y1 per segment, PointMode.lines order
  final List<TextPainter> _glyphs = <TextPainter>[];
  final List<Offset> _origins = <Offset>[];

  static const List<String> _ar = <String>['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];

  static String _digits(int v, NumeralSystem n) {
    if (n == NumeralSystem.latin) return '$v';
    final out = StringBuffer();
    for (final u in '$v'.codeUnits) out.write(_ar[u - 0x30]);
    return out.toString();
  }

  static Float32List _tickVertices(RulerScene s) {
    final count = (s.spanPx / s.pxPerMm).floor() + 1; // one tick per millimetre
    final out = Float32List(count * 4);
    for (var mm = 0; mm < count; mm++) {
      final i = mm * 4, x = mm * s.pxPerMm;
      out[i] = x; out[i + 2] = x;
      out[i + 3] = mm % 10 == 0 ? 30 : (mm % 5 == 0 ? 18 : 10);
    }
    return out;
  }

  static Float32List _cursorVertices(RulerScene s) => Float32List.fromList(
      <double>[s.lengthMm * s.pxPerMm, 0, s.lengthMm * s.pxPerMm, 72]);

  void _layoutGlyphs() {
    final style = TextStyle(color: scene.ink, fontSize: 13,
        fontFeatures: const <ui.FontFeature>[ui.FontFeature.tabularFigures()]);
    for (var cm = 0; cm * 10 * scene.pxPerMm <= scene.spanPx; cm++) {
      _glyphs.add(TextPainter(
        text: TextSpan(text: _digits(cm, scene.numerals), style: style),
        textDirection: scene.textDirection, // passed in, never inherited
      )..layout());
      _origins.add(Offset(cm * 10 * scene.pxPerMm + 3, 34));
    }
    // The readout always carries its method: an unlabelled figure states nothing legal.
    final n = scene.numerals, mm = scene.lengthMm;
    final readout = '${_digits(mm ~/ 10, n)}${n == NumeralSystem.arabicIndic ? '٫' : '.'}'
        '${_digits(mm % 10, n)} ${scene.methodLabel}'; // ICU owns the separator in real code
    _glyphs.add(TextPainter(
      text: TextSpan(text: readout, style: style), textDirection: scene.textDirection,
    )..layout(maxWidth: scene.spanPx));
    _origins.add(const Offset(4, 64));
  }

  /// Allocates NOTHING: no Paint, no TextPainter, no Offset, no closure, no string. Every object
  /// touched here was built in the constructor above.
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRawPoints(ui.PointMode.lines, _ticks, _tick);
    canvas.drawRawPoints(ui.PointMode.lines, _cursorLine, _cursor);
    for (var i = 0; i < _glyphs.length; i++) {
      _glyphs[i].paint(canvas, _origins[i]); // glyphs LAST, never inside a mirrored frame
    }
    // Were a band ever to flip: save(); scale(-1, 1); translate(-size.width, 0); ...geometry...;
    // restore(); THEN the glyphs. A Matrix4 Y-rotation appears in ZERO places in the framework.
  }

  /// Every field, textDirection included. Drop that one line and Arabic labels keep Latin shaping
  /// until some unrelated rebuild happens to clear them.
  @override
  bool shouldRepaint(RulerPainter old) =>
      old.scene.textDirection != scene.textDirection ||
      old.scene.numerals != scene.numerals ||
      old.scene.pxPerMm != scene.pxPerMm ||
      old.scene.spanPx != scene.spanPx ||
      old.scene.lengthMm != scene.lengthMm ||
      old.scene.methodLabel != scene.methodLabel ||
      old.scene.ink != scene.ink ||
      old.scene.mark != scene.mark;
}
