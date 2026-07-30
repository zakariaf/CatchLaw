// Demonstrates the whole measurement subsystem end to end: the MeasurementMethod enum and the
// Measurement value type holding an int of millimetres, ID-1 calibration with its plausibility
// gate, the RulerView that pins the ruler subtree to TextDirection.ltr as a deliberate exception,
// and a RulerPainter that receives labelDirection and a LonjaTokens snapshot as CONSTRUCTOR FIELDS
// (a CustomPainter has no BuildContext and cannot read Directionality) and compares both in
// shouldRepaint. Tick glyphs are drawn only after canvas.restore(). Conceptually compiles against
// flutter/material; RulerScene, LonjaTokens and l10n stand in for the real app symbols.
// The View/Painter/Scene split itself is owned by custom-canvas-and-gestures — this file shows only
// what the measurement domain adds on top of it.

import 'dart:ui' show TextDirection;

import 'package:flutter/material.dart';

// --- Domain: one integer, one method. Nothing here is a double or a string. ---

enum MeasurementMethod { tl, fl, sl, cw, shl, ml }

@immutable
final class Measurement {
  const Measurement({required this.lengthMm, required this.method});

  /// 450 = Hamour minimum (Ministerial Decision 580/2015, Art. 3, checked 2026-07-14).
  /// 650 = Kanaad minimum, fork length. 38 = Ameixa babosa, shell length.
  final int lengthMm;
  final MeasurementMethod method;

  /// The ONE rounding in the system. Nothing downstream rounds again.
  static Measurement fromPixels(double px, double pxPerMm, MeasurementMethod m) =>
      Measurement(lengthMm: (px / pxPerMm).round(), method: m);

  @override
  bool operator ==(Object o) =>
      o is Measurement && o.lengthMm == lengthMm && o.method == method;
  @override
  int get hashCode => Object.hash(lengthMm, method);
}

// --- Calibration: measured against the card, judged before it may exist. ---

const double kId1WidthMm = 85.60; // ISO/IEC 7810 ID-1 — the wallet ruler
const double kNominalPxPerMm = 6.299; // 160 dp per inch / 25.4  // measurement-ok
const double kMinPxPerMm = 4.50; // measured band floor          // measurement-ok
const double kMaxPxPerMm = 9.00; // measured band ceiling        // measurement-ok

@immutable
final class RulerCalibration {
  const RulerCalibration({required this.pxPerMm, required this.capturedOn});
  final double pxPerMm; // the only double here: a scale factor, never a length
  final DateTime capturedOn;
}

sealed class CalibrationOutcome {
  const CalibrationOutcome();
}

final class CalibrationAccepted extends CalibrationOutcome {
  const CalibrationAccepted(this.calibration);
  final RulerCalibration calibration;
}

/// Rejected, not corrected. The previous calibration — or none — survives untouched.
final class CalibrationImplausible extends CalibrationOutcome {
  const CalibrationImplausible({required this.measured});
  final double measured;
}

CalibrationOutcome calibrate(double cardWidthPx, DateTime now) {
  final pxPerMm = cardWidthPx / kId1WidthMm;
  if (!pxPerMm.isFinite || pxPerMm < kMinPxPerMm || pxPerMm > kMaxPxPerMm) {
    return CalibrationImplausible(measured: pxPerMm); // never fall back to kNominalPxPerMm
  }
  return CalibrationAccepted(RulerCalibration(pxPerMm: pxPerMm, capturedOn: now));
}

// --- Scene: an immutable snapshot. The painter never reads the widget tree. ---

@immutable
final class RulerScene {
  const RulerScene({
    required this.pxPerMm, required this.markedMm,
    required this.tickInk, required this.markInk,
  });
  final double pxPerMm;
  final int markedMm; // running total of committed step-and-mark segments
  final Color tickInk; // LonjaTokens.onSurfaceMuted, snapshotted by the widget
  final Color markInk; // LonjaTokens.accent — harbour #1B4D5E on paper

  @override
  bool operator ==(Object o) =>
      o is RulerScene && o.pxPerMm == pxPerMm && o.markedMm == markedMm &&
          o.tickInk == tickInk && o.markInk == markInk;
  @override
  int get hashCode => Object.hash(pxPerMm, markedMm, tickInk, markInk);
}

// --- The view: the ruler subtree does NOT mirror; the chrome around it does. ---

class RulerView extends StatelessWidget {
  const RulerView({required this.scene, required this.numerals, super.key});

  final RulerScene scene;
  final String Function(int) numerals; // ٠١٢ in ar, 012 in es/pt/en — from i18n-rtl-l10n

  @override
  Widget build(BuildContext context) {
    // A physical measuring scale runs from a physical edge regardless of script direction.
    // Mirroring it would put zero at the tail of a real fish. Deliberate, reviewed exception.
    return Directionality(
      textDirection: TextDirection.ltr, // catchlaw: a physical scale never mirrors
      child: CustomPaint(
        size: const Size.fromHeight(96),
        painter: RulerPainter(
          scene: scene,
          // The painter has no BuildContext; the AMBIENT direction is handed to it explicitly.
          labelDirection: Directionality.of(context),
          numerals: numerals,
        ),
      ),
    );
  }
}

class RulerPainter extends CustomPainter {
  const RulerPainter({
    required this.scene, required this.labelDirection, required this.numerals,
  });
  final RulerScene scene;
  final TextDirection labelDirection;
  final String Function(int) numerals;

  @override
  void paint(Canvas canvas, Size size) {
    final tick = Paint()
      ..color = scene.tickInk
      ..strokeWidth = 1;
    for (var mm = 0; mm * scene.pxPerMm <= size.width; mm++) {
      final x = mm * scene.pxPerMm;
      final len = mm % 10 == 0 ? 28.0 : (mm % 5 == 0 ? 18.0 : 10.0);
      canvas.drawLine(Offset(x, 0), Offset(x, len), tick);
    }
    _paintLabels(canvas, size); // glyphs last, never inside a mirrored frame
  }

  void _paintLabels(Canvas canvas, Size size) {
    for (var cm = 0; cm * 10 * scene.pxPerMm <= size.width; cm += 5) {
      final tp = TextPainter(
        text: TextSpan(text: numerals(cm), style: TextStyle(color: scene.tickInk, fontSize: 14)),
        textDirection: labelDirection, // localised numerals, ordinary text direction
      )..layout();
      tp.paint(canvas, Offset(cm * 10 * scene.pxPerMm + 2, 32));
    }
  }

  @override
  bool shouldRepaint(RulerPainter old) =>
      old.scene != scene ||
      old.labelDirection != labelDirection || // drop this and Arabic keeps Latin shaping
      old.numerals != numerals;
}
