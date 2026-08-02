import 'package:catchlaw/theme/lonja_primitives.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/material.dart';

/// The three palettes, each with all thirteen slots written out.
///
/// **Sunlight is authored, not derived, and the arithmetic is the reason.** The
/// tempting one-liner — `paper.copyWith(surface: white100, onSurface: black00)`
/// — leaves `onSurfaceMuted` at `ink30` (9.29:1 on white, fine on a desk),
/// `onSurfaceFaint` at `ink49` (4.60:1, gone in the sun), `hairline` at
/// `paper79` (1.75:1, gone indoors too) and `accent` at `harbour30`, a blue
/// that reads as grey outdoors. Every one of those is a measured pass on a
/// bench and a failure in the hand.
///
/// At roughly 100 000 lux through a salt-hazed screen the *middle* of the tonal
/// range disappears first, so sunlight **deletes** the middle rather than
/// compressing it: seven neutral slots collapse to `black00`, `surfaceSunk`
/// collapses into `surface` because white paper has no second stock, and
/// `accent` gives up `harbour` because chrome colour is the first thing to
/// spend. What survives is the verdict — the only chroma in the build, and
/// therefore unmistakably the answer.
///
/// This is also why sunlight is **not** "high contrast mode": high contrast
/// raises ratios, sunlight removes tonal steps. The consequence lands on every
/// later epic and is stated here so it is not rediscovered — a widget that
/// relies on `surfaceSunk` to mark a block must **also** carry a rule, because
/// in sunlight the stock change does not exist.
abstract final class LonjaPalettes {
  /// The regulations booklet indoors.
  static const LonjaTokens paper = LonjaTokens(
    surface: LonjaPrimitives.paper90,
    surfaceSunk: LonjaPrimitives.paper87,
    onSurface: LonjaPrimitives.ink11,
    onSurfaceMuted: LonjaPrimitives.ink30,
    onSurfaceFaint: LonjaPrimitives.ink49,
    hairline: LonjaPrimitives.paper79,
    hairlineStrong: LonjaPrimitives.paper70,
    ruleBearing: LonjaPrimitives.ink30,
    accent: LonjaPrimitives.harbour30,
    onAccent: LonjaPrimitives.paper90,
    verdictPass: LonjaPrimitives.verdant36,
    verdictFail: LonjaPrimitives.oxblood28,
    verdictWarn: LonjaPrimitives.ochre47,
    density: LonjaDensity.standard,
  );

  /// The same booklet under a deck lamp.
  static const LonjaTokens night = LonjaTokens(
    surface: LonjaPrimitives.ink07,
    surfaceSunk: LonjaPrimitives.ink10,
    onSurface: LonjaPrimitives.paper89,
    onSurfaceMuted: LonjaPrimitives.paper72,
    onSurfaceFaint: LonjaPrimitives.paper57,
    hairline: LonjaPrimitives.ink22,
    hairlineStrong: LonjaPrimitives.ink26,
    ruleBearing: LonjaPrimitives.paper57,
    accent: LonjaPrimitives.harbour69,
    onAccent: LonjaPrimitives.ink07,
    verdictPass: LonjaPrimitives.verdant72,
    verdictFail: LonjaPrimitives.oxblood70,
    verdictWarn: LonjaPrimitives.ochre76,
    density: LonjaDensity.standard,
  );

  /// The same booklet at Gulf noon.
  static const LonjaTokens sunlight = LonjaTokens(
    surface: LonjaPrimitives.white100,
    surfaceSunk: LonjaPrimitives.white100,
    onSurface: LonjaPrimitives.black00,
    onSurfaceMuted: LonjaPrimitives.black00,
    onSurfaceFaint: LonjaPrimitives.black00,
    hairline: LonjaPrimitives.black00,
    hairlineStrong: LonjaPrimitives.black00,
    ruleBearing: LonjaPrimitives.black00,
    accent: LonjaPrimitives.black00,
    onAccent: LonjaPrimitives.white100,
    verdictPass: LonjaPrimitives.verdant36,
    verdictFail: LonjaPrimitives.oxblood28,
    // ochre38 and not ochre47: paper's warn measures 5.06:1 on white, a WCAG
    // AA pass that misses SPEC.md §13's 7:1 sunlight floor by two points.
    verdictWarn: LonjaPrimitives.ochre38,
    density: LonjaDensity.standard,
  );
}

/// `ThemeData` for each palette.
///
/// The `ColorScheme` is **hand-authored and never `ColorScheme.fromSeed`**. A
/// seed generates thirty tonal values nobody measured, none of which appear in
/// any contrast table, and it silently overrides the slots above it. The scheme
/// is populated because Material widgets read it underneath us; it is a shim
/// over the slots, not a second source of truth.
abstract final class LonjaTheme {
  /// The paper theme.
  static ThemeData paper() => _build(LonjaPalettes.paper, Brightness.light);

  /// The night theme.
  static ThemeData night() => _build(LonjaPalettes.night, Brightness.dark);

  /// The sunlight theme.
  ///
  /// A **light** theme with a white ground. Reporting `dark` would invert the
  /// system UI over it.
  static ThemeData sunlight() => _build(LonjaPalettes.sunlight, Brightness.light);

  static ThemeData _build(LonjaTokens tokens, Brightness brightness) => ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: tokens.surface,
    // Paper does not float. The cheapest way a shadow appears in this app is a
    // Material default nobody overrode, so it is overridden here once.
    shadowColor: const Color(0x00000000),
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: tokens.accent,
      onPrimary: tokens.onAccent,
      secondary: tokens.accent,
      onSecondary: tokens.onAccent,
      error: tokens.verdictFail,
      onError: tokens.onAccent,
      surface: tokens.surface,
      onSurface: tokens.onSurface,
    ),
    extensions: <ThemeExtension<dynamic>>[tokens],
  );
}
