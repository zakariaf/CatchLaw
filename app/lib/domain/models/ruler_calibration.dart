import 'package:meta/meta.dart';

/// What one device's screen measures.
///
/// **The one shared transform in this subsystem.** Every pixel-to-millimetre
/// conversion in the app goes through [millimetresFor], and every
/// millimetre-to-pixel conversion through [pixelsForMillimetres]. A painter
/// that did its own arithmetic and a readout that did its own would agree until
/// one of them was changed, and the day they disagree is the day the ruler
/// draws 45 cm and the number under it says 44.
@immutable
class RulerCalibration {
  /// A measured scale, stamped with when it was taken.
  const RulerCalibration({required this.pxPerMm, required this.capturedOn});

  /// Logical pixels per millimetre, measured against an ID-1 card.
  final double pxPerMm;

  /// When, in UTC.
  ///
  /// Stored so S4 can say how old the calibration is. A stale calibration is
  /// **shown**, never silently reused as if it were fresh — the same posture
  /// invariant 5 takes about a stale ruleset.
  final DateTime capturedOn;

  /// [px] as whole millimetres.
  ///
  /// **Rounds to an integer, and storage is integer millimetres** (`SPEC.md`
  /// §9.5). A double millimetre would let two screens that measured the same
  /// fish store different numbers, and the difference between 449.6 and 450.4
  /// is the difference between a fine and a legal fish.
  int millimetresFor(double px) => (px / pxPerMm).round();

  /// [mm] as logical pixels.
  double pixelsForMillimetres(int mm) => mm * pxPerMm;

  @override
  bool operator ==(Object other) =>
      other is RulerCalibration && other.pxPerMm == pxPerMm && other.capturedOn == capturedOn;

  @override
  int get hashCode => Object.hash(pxPerMm, capturedOn);

  @override
  String toString() => 'RulerCalibration(${pxPerMm.toStringAsFixed(3)} px/mm @ $capturedOn)';
}
