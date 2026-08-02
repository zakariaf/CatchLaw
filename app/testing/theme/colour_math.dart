/// The colour arithmetic every proof in E07 is written against.
///
/// Test-only, never imported from `lib/` (`CONVENTIONS.md` §6). Its job is to
/// make the naming law in `lonja-design-tokens` rule 2 falsifiable: `ink11` is
/// `#16201C` **because** its measured CIE L\* is 11.2, and a number in a name
/// that nothing computes is decoration that drifts the first time a hex is
/// nudged.
library;

import 'dart:math' as math;
import 'dart:ui';

/// Relative luminance, WCAG 2.x: sRGB channels linearised, then Rec. 709
/// weights.
double relativeLuminance(Color c) {
  double channel(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// CIE L\* (D65, sRGB).
///
/// The piecewise-linear branch below the knee is **not optional**. `ink07`'s
/// relative luminance is 0.00774, under (6/29)³ = 0.008856, so a cube-root-only
/// implementation reports 6.94 instead of 6.99 — and reports **−16.00** for
/// `black00`, which would take the whole naming law with it at the dark end.
double cieLStar(Color c) {
  final double y = relativeLuminance(c);
  const double delta = 6 / 29;
  final double f = y > delta * delta * delta
      ? math.pow(y, 1 / 3).toDouble()
      : y / (3 * delta * delta) + 4 / 29;
  return 116 * f - 16;
}

/// The WCAG contrast ratio of [a] and [b].
///
/// Symmetric by construction: WCAG defines it as lighter-over-darker, and an
/// implementation that takes its arguments in order returns a number below 1
/// half the time.
double contrastRatio(Color a, Color b) {
  final double la = relativeLuminance(a);
  final double lb = relativeLuminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}
