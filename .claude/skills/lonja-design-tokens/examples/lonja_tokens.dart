// Demonstrates tier 1 and tier 2 of the Lonja value layer: the L*-named primitive box, the 4pt
// spine, the four rule weights, the radius ceiling, the orthogonal density set, and the LonjaTokens
// ThemeExtension with its asserting of(), copyWith, lerp and value equality.
// NOTE copyWith is NARROWED to density on purpose: widening it to the thirteen colours would let
// any call site mint a fourth palette that no contrast table and no golden lane covers — which is
// exactly how a derived "sunlight" keeps the mid-greys it exists to delete.
// The palettes and the three ThemeData builders live next door in lonja_theme.dart, mirroring the
// lib/theme/ split. Every hex and ratio below is measured; full tables in
// references/token-tables.md. Conceptually compiles against flutter (material + foundation).

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Tier 1. The pigment box. The number in each name is the measured CIE L*.
abstract final class LonjaPrimitives {
  static const white100 = Color(0xFFFFFFFF), paper90 = Color(0xFFE6E4DC); // 100.0 / 90.5 the sheet
  static const paper89 = Color(0xFFDDE2DB), paper87 = Color(0xFFDEDBD1); //  89.3 / 87.4 sunk stock
  static const paper79 = Color(0xFFC2C5BB), paper72 = Color(0xFFA9B4AC); //  79.0 / 72.3
  static const paper70 = Color(0xFFA9AC9F), paper57 = Color(0xFF7E8B83); //  69.8 / 56.6
  static const ink49 = Color(0xFF6C7871), ink30 = Color(0xFF3D4A44); //  49.3 / 30.2
  static const ink26 = Color(0xFF33413A), ink22 = Color(0xFF2C3830); //  26.1 / 22.2
  static const ink11 = Color(0xFF16201C), ink10 = Color(0xFF161E1A); //  11.2 impression / 10.4
  static const ink07 = Color(0xFF101714), black00 = Color(0xFF000000); //   7.0 / 0.0
  static const harbour30 = Color(0xFF1B4D5E), harbour69 = Color(0xFF6FB3C4); // chrome: paper/night
  static const verdant36 = Color(0xFF2E5E3A), verdant72 = Color(0xFF7FC08D); // meets the rule
  static const oxblood28 = Color(0xFF7A2320), oxblood70 = Color(0xFFE19A95); // fails the rule
  static const ochre47 = Color(0xFF8A6A16), ochre76 = Color(0xFFD8B84A); // stale rule data
  static const ochre38 = Color(0xFF6E5512); // sunlight warn, 7.07:1 on white
}

/// The 4pt spine. Eight steps, nothing between them; a zero gap is EdgeInsets.zero.
abstract final class LonjaSpace {
  static const s1 = 4.0, s2 = 8.0, s3 = 12.0, s4 = 16.0;
  static const s5 = 24.0, s6 = 32.0, s7 = 48.0, s8 = 64.0;
}

/// Four rule weights and no fifth. A printed sheet separates with rules, not shadows.
abstract final class LonjaRules {
  static const hair = 0.5, rule = 1.0, strong = 2.0, stamp = 3.0; // stamp = verdict frame only
}

/// Radius ceiling 2. There is deliberately no shadow group and no elevation group.
abstract final class LonjaRadii {
  static const none = BorderRadius.zero; // the default for every surface
  static const hair = BorderRadius.all(Radius.circular(2)); // the ceiling
}

abstract final class LonjaMotion {
  static const none = Duration.zero, quick = Duration(milliseconds: 90);
  static const page = Duration(milliseconds: 140);
}

/// Density is orthogonal to the theme: 3 palettes x 2 densities, never 6 themes.
@immutable
class LonjaDensity {
  const LonjaDensity(this.tapMin, this.tapGap, this.rowHeight, this.hitSlop, this.gutter);
  final double tapMin, tapGap, rowHeight, hitSlop, gutter;

  static const standard = LonjaDensity(48, LonjaSpace.s1, 56, 0, LonjaSpace.s4);
  static const glove = LonjaDensity(56, LonjaSpace.s2, 72, 4, LonjaSpace.s5);

  List<Object?> get _props => [tapMin, tapGap, rowHeight, hitSlop, gutter];
  @override
  bool operator ==(Object o) => o is LonjaDensity && listEquals(o._props, _props);
  @override
  int get hashCode => Object.hashAll(_props);
}

/// Tier 2. The thirteen role slots every widget reads, plus the density set.
@immutable
class LonjaTokens extends ThemeExtension<LonjaTokens> {
  const LonjaTokens(
      {required this.surface,
      required this.surfaceSunk,
      required this.onSurface,
      required this.onSurfaceMuted,
      required this.onSurfaceFaint,
      required this.hairline,
      required this.hairlineStrong,
      required this.ruleBearing,
      required this.accent,
      required this.onAccent,
      required this.verdictPass,
      required this.verdictFail,
      required this.verdictWarn,
      required this.density});

  final Color surface, surfaceSunk;
  final Color onSurface, onSurfaceMuted, onSurfaceFaint;
  final Color hairline, hairlineStrong, ruleBearing;
  final Color accent, onAccent;
  final Color verdictPass, verdictFail, verdictWarn;
  final LonjaDensity density;

  /// The only legal way for a widget to reach a value. Asserts rather than falling back: a
  /// fallback would ship a palette that no golden lane ever rendered.
  static LonjaTokens of(BuildContext context) {
    final tokens = Theme.of(context).extension<LonjaTokens>();
    assert(tokens != null, 'LonjaTokens missing — build ThemeData with LonjaTheme.');
    return tokens!;
  }

  /// Narrowed on purpose: density is the only slot a caller may vary. See the header note.
  @override
  LonjaTokens copyWith({LonjaDensity? density}) => LonjaTokens(
      surface: surface, surfaceSunk: surfaceSunk,
      onSurface: onSurface, onSurfaceMuted: onSurfaceMuted, onSurfaceFaint: onSurfaceFaint,
      hairline: hairline, hairlineStrong: hairlineStrong, ruleBearing: ruleBearing,
      accent: accent, onAccent: onAccent,
      verdictPass: verdictPass, verdictFail: verdictFail, verdictWarn: verdictWarn,
      density: density ?? this.density);

  @override
  LonjaTokens lerp(ThemeExtension<LonjaTokens>? other, double t) {
    if (other is! LonjaTokens) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return LonjaTokens(
        surface: c(surface, other.surface), surfaceSunk: c(surfaceSunk, other.surfaceSunk),
        onSurface: c(onSurface, other.onSurface),
        onSurfaceMuted: c(onSurfaceMuted, other.onSurfaceMuted),
        onSurfaceFaint: c(onSurfaceFaint, other.onSurfaceFaint),
        hairline: c(hairline, other.hairline),
        hairlineStrong: c(hairlineStrong, other.hairlineStrong),
        ruleBearing: c(ruleBearing, other.ruleBearing),
        accent: c(accent, other.accent), onAccent: c(onAccent, other.onAccent),
        verdictPass: c(verdictPass, other.verdictPass),
        verdictFail: c(verdictFail, other.verdictFail),
        verdictWarn: c(verdictWarn, other.verdictWarn),
        // Density SNAPS. A half-interpolated tap target is legal in neither mode.
        density: t < 0.5 ? density : other.density);
  }

  List<Object?> get _props => [
        surface, surfaceSunk, onSurface, onSurfaceMuted, onSurfaceFaint, hairline, //
        hairlineStrong, ruleBearing, accent, onAccent, verdictPass, verdictFail, //
        verdictWarn, density,
      ];

  // Value equality is what lets a painter hold a snapshot and answer shouldRepaint honestly.
  @override
  bool operator ==(Object o) => o is LonjaTokens && listEquals(o._props, _props);
  @override
  int get hashCode => Object.hashAll(_props);
}

/// The engraved species plate. Takes a snapshot, never a BuildContext, so shouldRepaint can be
/// answered by value comparison instead of "true".
class SpeciesPlatePainter extends CustomPainter {
  const SpeciesPlatePainter({required this.tokens});
  final LonjaTokens tokens;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawLine(
      Offset(0, size.height), Offset(size.width, size.height),
      Paint()..color = tokens.hairline..strokeWidth = LonjaRules.hair);

  @override
  bool shouldRepaint(SpeciesPlatePainter old) => old.tokens != tokens;
}
