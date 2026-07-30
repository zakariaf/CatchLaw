// Demonstrates the three hand-authored Lonja palettes and the three ThemeData builders that carry
// them, plus the orthogonal density parameter.
// NOTE every slot of every palette is written out. Sunlight is NOT derived from paper: a copyWith
// chain would keep onSurfaceMuted, onSurfaceFaint and both hairlines as mid-greys, which are
// exactly the tones that disappear at 100,000 lux — the failure sunlight exists to prevent.
// Tier 1 and the LonjaTokens extension live next door in lonja_tokens.dart, mirroring the
// lib/theme/ split. Every ratio in the comments is measured against that palette's own surface;
// full tables in references/token-tables.md. Conceptually compiles against flutter (material).

import 'package:flutter/material.dart';

import 'lonja_tokens.dart';

/// The three palettes. Every slot is bound explicitly; none is derived from another.
abstract final class LonjaPalettes {
  static const paper = LonjaTokens(
      surface: LonjaPrimitives.paper90, surfaceSunk: LonjaPrimitives.paper87,
      onSurface: LonjaPrimitives.ink11, // 13.12:1 — the verdict word, measurements
      onSurfaceMuted: LonjaPrimitives.ink30, // 7.29:1 — citations, dates
      onSurfaceFaint: LonjaPrimitives.ink49, // 3.62:1 — 19sp+ ornament, NEVER a fact
      hairline: LonjaPrimitives.paper79, hairlineStrong: LonjaPrimitives.paper70, // ornament only
      ruleBearing: LonjaPrimitives.ink30, // 7.29:1 — control frames, active tab
      accent: LonjaPrimitives.harbour30, onAccent: LonjaPrimitives.paper90, // 7.27:1 — chrome
      verdictPass: LonjaPrimitives.verdant36, verdictFail: LonjaPrimitives.oxblood28, // 5.94 / 7.90
      verdictWarn: LonjaPrimitives.ochre47, // 3.97:1 — frame and glyph only, never text
      density: LonjaDensity.standard);

  static const night = LonjaTokens(
      surface: LonjaPrimitives.ink07, surfaceSunk: LonjaPrimitives.ink10,
      onSurface: LonjaPrimitives.paper89, // 13.84:1
      onSurfaceMuted: LonjaPrimitives.paper72, // 8.50:1
      onSurfaceFaint: LonjaPrimitives.paper57, // 5.12:1 — still restricted; the limit is global
      hairline: LonjaPrimitives.ink22, hairlineStrong: LonjaPrimitives.ink26, // ornament only
      ruleBearing: LonjaPrimitives.paper57, // 5.12:1
      accent: LonjaPrimitives.harbour69, onAccent: LonjaPrimitives.ink07, // 7.73:1 — chrome
      verdictPass: LonjaPrimitives.verdant72, verdictFail: LonjaPrimitives.oxblood70, // 8.51 / 8.02
      verdictWarn: LonjaPrimitives.ochre76, // 9.42:1
      density: LonjaDensity.standard);

  /// Maximum contrast, every grey deleted, exactly one colour left: the verdict.
  static const sunlight = LonjaTokens(
      surface: LonjaPrimitives.white100,
      surfaceSunk: LonjaPrimitives.white100, // white paper has no second stock
      onSurface: LonjaPrimitives.black00, onSurfaceMuted: LonjaPrimitives.black00, // 21.00:1
      onSurfaceFaint: LonjaPrimitives.black00, hairline: LonjaPrimitives.black00,
      hairlineStrong: LonjaPrimitives.black00, ruleBearing: LonjaPrimitives.black00,
      accent: LonjaPrimitives.black00, // harbour is spent: chrome loses its colour first
      onAccent: LonjaPrimitives.white100,
      verdictPass: LonjaPrimitives.verdant36, verdictFail: LonjaPrimitives.oxblood28, // 7.56 /10.05
      verdictWarn: LonjaPrimitives.ochre38, // 7.07:1 — the darkened ochre, sunlight only
      density: LonjaDensity.standard);
}

/// The three ThemeData builders. Density is a parameter, never a fourth theme.
abstract final class LonjaTheme {
  static ThemeData paper({LonjaDensity density = LonjaDensity.standard}) =>
      _build(LonjaPalettes.paper, Brightness.light, density);
  static ThemeData night({LonjaDensity density = LonjaDensity.standard}) =>
      _build(LonjaPalettes.night, Brightness.dark, density);
  static ThemeData sunlight({LonjaDensity density = LonjaDensity.standard}) =>
      _build(LonjaPalettes.sunlight, Brightness.light, density);

  static ThemeData _build(LonjaTokens base, Brightness brightness, LonjaDensity density) {
    final t = base.copyWith(density: density);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      // Hand-authored, never ColorScheme.fromSeed: a seed invents 30 tonal values nobody measured
      // and silently overrides the slots above.
      colorScheme: ColorScheme(
          brightness: brightness,
          primary: t.accent, onPrimary: t.onAccent,
          secondary: t.ruleBearing, onSecondary: t.surface,
          error: t.verdictFail, onError: t.surface,
          surface: t.surface, onSurface: t.onSurface),
      scaffoldBackgroundColor: t.surface,
      dividerTheme: DividerThemeData(
          color: t.hairline, thickness: LonjaRules.rule, space: LonjaSpace.s4),
      // No shadow, no elevation, no radius anywhere in the app: paper does not float.
      shadowColor: const Color(0x00000000),
      cardTheme: CardThemeData(
          elevation: 0, margin: EdgeInsets.zero, color: t.surfaceSunk,
          shape: const RoundedRectangleBorder(borderRadius: LonjaRadii.none)),
      extensions: <ThemeExtension<dynamic>>[t],
    );
  }
}

/// Both axes, resolved at the top of the app. Three palettes x two densities = six renderings,
/// and still only three palettes to hand-author and keep in the contrast tables.
ThemeData resolveLonjaTheme({required LonjaSkin skin, required bool gloved}) {
  final density = gloved ? LonjaDensity.glove : LonjaDensity.standard;
  return switch (skin) {
    LonjaSkin.paper => LonjaTheme.paper(density: density),
    LonjaSkin.night => LonjaTheme.night(density: density),
    LonjaSkin.sunlight => LonjaTheme.sunlight(density: density),
  };
}

enum LonjaSkin { paper, night, sunlight }
