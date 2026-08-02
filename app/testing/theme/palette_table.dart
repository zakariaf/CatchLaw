import 'dart:ui' show Color;

import 'package:catchlaw/theme/lonja_primitives.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';

/// One published tier-two binding: which pigment a theme puts in a slot.
class PaletteRow {
  /// Records one binding.
  const PaletteRow(this.theme, this.slot, this.primitiveName, this.expected);

  /// `paper`, `night` or `sunlight`.
  final String theme;

  /// The slot name.
  final String slot;

  /// The pigment the table names.
  final String primitiveName;

  /// The pigment itself.
  final Color expected;

  /// What the palette actually binds.
  ///
  /// Resolved at read time rather than stored: a field read on a `const`
  /// object is not itself a constant expression, and the table is `const` so
  /// that a missing row is a compile error rather than a runtime surprise.
  Color get actual => slotOf(kPalettesByName[theme]!, slot);
}

/// One slot of [tokens], addressed by its published name.
///
/// A `switch` and not a map: a slot added to [LonjaTokens] without a case here
/// is a compile error, which is the whole reason the tables can be trusted.
Color slotOf(LonjaTokens tokens, String name) => switch (name) {
  'surface' => tokens.surface,
  'surfaceSunk' => tokens.surfaceSunk,
  'onSurface' => tokens.onSurface,
  'onSurfaceMuted' => tokens.onSurfaceMuted,
  'onSurfaceFaint' => tokens.onSurfaceFaint,
  'hairline' => tokens.hairline,
  'hairlineStrong' => tokens.hairlineStrong,
  'ruleBearing' => tokens.ruleBearing,
  'accent' => tokens.accent,
  'onAccent' => tokens.onAccent,
  'verdictPass' => tokens.verdictPass,
  'verdictFail' => tokens.verdictFail,
  'verdictWarn' => tokens.verdictWarn,
  _ => throw ArgumentError.value(name, 'name', 'not a Lonja slot'),
};

/// One published contrast measurement.
class ContrastRow {
  /// Records one measurement and the floor it must clear.
  const ContrastRow(this.theme, this.slot, this.vsSurface, this.vsSurfaceSunk, this.floor);

  /// `paper`, `night` or `sunlight`.
  final String theme;

  /// The slot name.
  final String slot;

  /// The published ratio against the ground.
  final double vsSurface;

  /// The published ratio against the recessed stock.
  final double vsSurfaceSunk;

  /// The floor, or `null` for an ornament hairline, which has none and may
  /// never be the sole boundary of a control.
  final double? floor;
}

/// The palette for a theme name, so a loop can address all three.
const Map<String, LonjaTokens> kPalettesByName = <String, LonjaTokens>{
  'paper': LonjaPalettes.paper,
  'night': LonjaPalettes.night,
  'sunlight': LonjaPalettes.sunlight,
};

/// `token-tables.md` "Tier 2 — the thirteen semantic slots", typed out.
///
/// Transcribed and not derived, for the reason [kPigmentTable] is: a table
/// generated from the palettes would compare the file with itself.
const List<PaletteRow> kPaletteTable = <PaletteRow>[
  PaletteRow('paper', 'surface', 'paper90', LonjaPrimitives.paper90),
  PaletteRow('paper', 'surfaceSunk', 'paper87', LonjaPrimitives.paper87),
  PaletteRow('paper', 'onSurface', 'ink11', LonjaPrimitives.ink11),
  PaletteRow('paper', 'onSurfaceMuted', 'ink30', LonjaPrimitives.ink30),
  PaletteRow('paper', 'onSurfaceFaint', 'ink49', LonjaPrimitives.ink49),
  PaletteRow('paper', 'hairline', 'paper79', LonjaPrimitives.paper79),
  PaletteRow('paper', 'hairlineStrong', 'paper70', LonjaPrimitives.paper70),
  PaletteRow('paper', 'ruleBearing', 'ink30', LonjaPrimitives.ink30),
  PaletteRow('paper', 'accent', 'harbour30', LonjaPrimitives.harbour30),
  PaletteRow('paper', 'onAccent', 'paper90', LonjaPrimitives.paper90),
  PaletteRow('paper', 'verdictPass', 'verdant36', LonjaPrimitives.verdant36),
  PaletteRow('paper', 'verdictFail', 'oxblood28', LonjaPrimitives.oxblood28),
  PaletteRow('paper', 'verdictWarn', 'ochre47', LonjaPrimitives.ochre47),
  PaletteRow('night', 'surface', 'ink07', LonjaPrimitives.ink07),
  PaletteRow('night', 'surfaceSunk', 'ink10', LonjaPrimitives.ink10),
  PaletteRow('night', 'onSurface', 'paper89', LonjaPrimitives.paper89),
  PaletteRow('night', 'onSurfaceMuted', 'paper72', LonjaPrimitives.paper72),
  PaletteRow('night', 'onSurfaceFaint', 'paper57', LonjaPrimitives.paper57),
  PaletteRow('night', 'hairline', 'ink22', LonjaPrimitives.ink22),
  PaletteRow('night', 'hairlineStrong', 'ink26', LonjaPrimitives.ink26),
  PaletteRow('night', 'ruleBearing', 'paper57', LonjaPrimitives.paper57),
  PaletteRow('night', 'accent', 'harbour69', LonjaPrimitives.harbour69),
  PaletteRow('night', 'onAccent', 'ink07', LonjaPrimitives.ink07),
  PaletteRow('night', 'verdictPass', 'verdant72', LonjaPrimitives.verdant72),
  PaletteRow('night', 'verdictFail', 'oxblood70', LonjaPrimitives.oxblood70),
  PaletteRow('night', 'verdictWarn', 'ochre76', LonjaPrimitives.ochre76),
  PaletteRow('sunlight', 'surface', 'white100', LonjaPrimitives.white100),
  PaletteRow('sunlight', 'surfaceSunk', 'white100', LonjaPrimitives.white100),
  PaletteRow('sunlight', 'onSurface', 'black00', LonjaPrimitives.black00),
  PaletteRow('sunlight', 'onSurfaceMuted', 'black00', LonjaPrimitives.black00),
  PaletteRow('sunlight', 'onSurfaceFaint', 'black00', LonjaPrimitives.black00),
  PaletteRow('sunlight', 'hairline', 'black00', LonjaPrimitives.black00),
  PaletteRow('sunlight', 'hairlineStrong', 'black00', LonjaPrimitives.black00),
  PaletteRow('sunlight', 'ruleBearing', 'black00', LonjaPrimitives.black00),
  PaletteRow('sunlight', 'accent', 'black00', LonjaPrimitives.black00),
  PaletteRow('sunlight', 'onAccent', 'white100', LonjaPrimitives.white100),
  PaletteRow('sunlight', 'verdictPass', 'verdant36', LonjaPrimitives.verdant36),
  PaletteRow('sunlight', 'verdictFail', 'oxblood28', LonjaPrimitives.oxblood28),
  PaletteRow('sunlight', 'verdictWarn', 'ochre38', LonjaPrimitives.ochre38),
];

/// The three "Measured contrast" tables, typed out.
///
/// The floors are NOT uniform and must not be flattened. `onSurfaceFaint`
/// measures 3.62:1 on paper — legal at 19 sp and above and **never carrying a
/// fact** — and `ochre47` measures 3.97:1, which clears a frame and a glyph
/// and fails as text, which is exactly why the verdict stamp is framed and
/// never filled. A blanket `greaterThan(4.5)` would fail both legitimate rows
/// and teach the next author to relax the assertion.
const List<ContrastRow> kContrastTable = <ContrastRow>[
  ContrastRow('paper', 'onSurface', 13.12, 12.06, 4.5),
  ContrastRow('paper', 'onSurfaceMuted', 7.29, 6.70, 4.5),
  ContrastRow('paper', 'onSurfaceFaint', 3.62, 3.32, 3.0),
  ContrastRow('paper', 'hairline', 1.37, 1.26, null),
  ContrastRow('paper', 'hairlineStrong', 1.81, 1.67, null),
  ContrastRow('paper', 'ruleBearing', 7.29, 6.70, 3.0),
  ContrastRow('paper', 'accent', 7.27, 6.68, 4.5),
  ContrastRow('paper', 'verdictPass', 5.94, 5.46, 4.5),
  ContrastRow('paper', 'verdictFail', 7.90, 7.26, 4.5),
  ContrastRow('paper', 'verdictWarn', 3.97, 3.65, 3.0),
  ContrastRow('night', 'onSurface', 13.84, 12.94, 4.5),
  ContrastRow('night', 'onSurfaceMuted', 8.50, 7.95, 4.5),
  ContrastRow('night', 'onSurfaceFaint', 5.12, 4.78, 3.0),
  ContrastRow('night', 'hairline', 1.49, 1.39, null),
  ContrastRow('night', 'hairlineStrong', 1.70, 1.59, null),
  ContrastRow('night', 'ruleBearing', 5.12, 4.78, 3.0),
  ContrastRow('night', 'accent', 7.73, 7.23, 4.5),
  ContrastRow('night', 'verdictPass', 8.51, 7.96, 4.5),
  ContrastRow('night', 'verdictFail', 8.02, 7.50, 4.5),
  ContrastRow('night', 'verdictWarn', 9.42, 8.81, 4.5),
  ContrastRow('sunlight', 'onSurface', 21.00, 21.00, 7.0),
  ContrastRow('sunlight', 'onSurfaceMuted', 21.00, 21.00, 7.0),
  ContrastRow('sunlight', 'onSurfaceFaint', 21.00, 21.00, 7.0),
  ContrastRow('sunlight', 'hairline', 21.00, 21.00, 7.0),
  ContrastRow('sunlight', 'hairlineStrong', 21.00, 21.00, 7.0),
  ContrastRow('sunlight', 'ruleBearing', 21.00, 21.00, 7.0),
  ContrastRow('sunlight', 'accent', 21.00, 21.00, 7.0),
  ContrastRow('sunlight', 'verdictPass', 7.56, 7.56, 7.0),
  ContrastRow('sunlight', 'verdictFail', 10.05, 10.05, 7.0),
  ContrastRow('sunlight', 'verdictWarn', 7.07, 7.07, 7.0),
];

/// `onAccent` is measured against the accent FILL, not against the ground.
const List<ContrastRow> kOnAccentTable = <ContrastRow>[
  ContrastRow('paper', 'onAccent', 7.27, 7.27, 4.5),
  ContrastRow('night', 'onAccent', 7.73, 7.73, 4.5),
  ContrastRow('sunlight', 'onAccent', 21.00, 21.00, 7.0),
];
