import 'dart:ui' show Color;

import 'package:catchlaw/theme/lonja_primitives.dart';

/// One published row of the tier-one table.
class PigmentRow {
  /// Names a pigment and what the table says about it.
  const PigmentRow(this.name, this.colour, this.argb, this.lStar, this.nameNumber);

  /// The constant's identifier.
  final String name;

  /// The constant itself.
  final Color colour;

  /// The 32-bit ARGB value published for it.
  final int argb;

  /// The measured L\* the table prints, to one decimal.
  final double lStar;

  /// The integer carried in the name.
  final int nameNumber;
}

/// `token-tables.md` "Tier 1 — the pigment box", typed out by hand.
///
/// **Transcribed and not derived.** A table generated from
/// [LonjaPrimitives] would compare the file with itself and pass forever;
/// typed out, it fails when the code and the published table disagree, which
/// is the only failure worth catching here.
const List<PigmentRow> kPigmentTable = <PigmentRow>[
  PigmentRow('white100', LonjaPrimitives.white100, 0xFFFFFFFF, 100.0, 100),
  PigmentRow('paper90', LonjaPrimitives.paper90, 0xFFE6E4DC, 90.5, 90),
  PigmentRow('paper89', LonjaPrimitives.paper89, 0xFFDDE2DB, 89.3, 89),
  PigmentRow('paper87', LonjaPrimitives.paper87, 0xFFDEDBD1, 87.4, 87),
  PigmentRow('paper79', LonjaPrimitives.paper79, 0xFFC2C5BB, 79.0, 79),
  PigmentRow('paper72', LonjaPrimitives.paper72, 0xFFA9B4AC, 72.3, 72),
  PigmentRow('paper70', LonjaPrimitives.paper70, 0xFFA9AC9F, 69.8, 70),
  PigmentRow('paper57', LonjaPrimitives.paper57, 0xFF7E8B83, 56.6, 57),
  PigmentRow('ink49', LonjaPrimitives.ink49, 0xFF6C7871, 49.3, 49),
  PigmentRow('ink30', LonjaPrimitives.ink30, 0xFF3D4A44, 30.2, 30),
  PigmentRow('ink26', LonjaPrimitives.ink26, 0xFF33413A, 26.1, 26),
  PigmentRow('ink22', LonjaPrimitives.ink22, 0xFF2C3830, 22.2, 22),
  PigmentRow('ink11', LonjaPrimitives.ink11, 0xFF16201C, 11.2, 11),
  PigmentRow('ink10', LonjaPrimitives.ink10, 0xFF161E1A, 10.4, 10),
  PigmentRow('ink07', LonjaPrimitives.ink07, 0xFF101714, 7.0, 7),
  PigmentRow('black00', LonjaPrimitives.black00, 0xFF000000, 0.0, 0),
  PigmentRow('harbour69', LonjaPrimitives.harbour69, 0xFF6FB3C4, 69.2, 69),
  PigmentRow('harbour30', LonjaPrimitives.harbour30, 0xFF1B4D5E, 30.3, 30),
  PigmentRow('verdant72', LonjaPrimitives.verdant72, 0xFF7FC08D, 72.3, 72),
  PigmentRow('verdant36', LonjaPrimitives.verdant36, 0xFF2E5E3A, 35.8, 36),
  PigmentRow('oxblood70', LonjaPrimitives.oxblood70, 0xFFE19A95, 70.4, 70),
  PigmentRow('oxblood28', LonjaPrimitives.oxblood28, 0xFF7A2320, 28.0, 28),
  PigmentRow('ochre76', LonjaPrimitives.ochre76, 0xFFD8B84A, 75.7, 76),
  PigmentRow('ochre47', LonjaPrimitives.ochre47, 0xFF8A6A16, 46.7, 47),
  PigmentRow('ochre38', LonjaPrimitives.ochre38, 0xFF6E5512, 37.6, 38),
];
