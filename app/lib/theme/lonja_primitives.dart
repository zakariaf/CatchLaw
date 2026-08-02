import 'dart:ui' show Color;

/// The Lonja pigment box: twenty-five colours, and nothing else.
///
/// **A primitive is named by its measured CIE L\*** (D65, sRGB), never by rank
/// or appearance (`lonja-design-tokens` rule 2). `grey700` says where a colour
/// sits in a list somebody invented; `ink11` says what it measures, and a test
/// recomputes that number from the hex on every run. If the hex changes, the
/// name changes — a name whose number does not match its hex is a defect, not
/// a nit.
///
/// **Nothing outside `lib/theme/` may read this class.** Widgets read the
/// thirteen semantic slots on `LonjaTokens`; a feature file that reaches for a
/// pigment has bound a decision to a hex instead of to a meaning, and
/// `check_lonja_tokens.sh` check 2 fails it. This file and its siblings under
/// `/theme/` are the only place `Color(0x` is legal at all.
///
/// The scales — spacing, rule weights, radii, motion, density — are tier-one
/// values too but live in `lonja_tokens.dart`, because a widget is *supposed*
/// to read `LonjaSpace.s4`. Keeping them apart makes the import line itself
/// diagnostic: a feature file importing this one is already wrong, before a
/// reviewer reads its body.
///
/// Adding a twenty-sixth is a reviewed change, and the five-step process is in
/// `lonja-design-tokens/references/token-tables.md`.
abstract final class LonjaPrimitives {
  /// L\* 100.0 — sunlight ground. Mockup alias `sun-paper`.
  static const Color white100 = Color(0xFFFFFFFF);

  /// L\* 90.5 — paper ground, paper onAccent. Mockup alias `paper`.
  static const Color paper90 = Color(0xFFE6E4DC);

  /// L\* 89.3 — night primary text.
  static const Color paper89 = Color(0xFFDDE2DB);

  /// L\* 87.4 — paper recessed stock. Mockup alias `paper-sunk`.
  static const Color paper87 = Color(0xFFDEDBD1);

  /// L\* 79.0 — paper hairline. Mockup alias `rule`.
  static const Color paper79 = Color(0xFFC2C5BB);

  /// L\* 72.3 — night secondary text.
  static const Color paper72 = Color(0xFFA9B4AC);

  /// L\* 69.8 — paper strong hairline. Mockup alias `rule-strong`.
  static const Color paper70 = Color(0xFFA9AC9F);

  /// L\* 56.6 — night tertiary text, night bearing rule.
  static const Color paper57 = Color(0xFF7E8B83);

  /// L\* 49.3 — paper tertiary text. Mockup alias `ink-faint`.
  static const Color ink49 = Color(0xFF6C7871);

  /// L\* 30.2 — paper secondary text, paper bearing rule. Mockup alias `ink-muted`.
  static const Color ink30 = Color(0xFF3D4A44);

  /// L\* 26.1 — night strong hairline.
  static const Color ink26 = Color(0xFF33413A);

  /// L\* 22.2 — night hairline.
  static const Color ink22 = Color(0xFF2C3830);

  /// L\* 11.2 — paper primary text. Mockup alias `ink`.
  static const Color ink11 = Color(0xFF16201C);

  /// L\* 10.4 — night recessed stock.
  static const Color ink10 = Color(0xFF161E1A);

  /// L\* 7.0 — night ground, night onAccent.
  static const Color ink07 = Color(0xFF101714);

  /// L\* 0.0 — every sunlight neutral. Mockup alias `sun-ink`.
  static const Color black00 = Color(0xFF000000);

  /// L\* 69.2 — night accent.
  static const Color harbour69 = Color(0xFF6FB3C4);

  /// L\* 30.3 — paper accent. Mockup alias `harbour`.
  static const Color harbour30 = Color(0xFF1B4D5E);

  /// L\* 72.3 — night verdictPass.
  static const Color verdant72 = Color(0xFF7FC08D);

  /// L\* 35.8 — paper + sunlight verdictPass. Mockup alias `verdant`.
  static const Color verdant36 = Color(0xFF2E5E3A);

  /// L\* 70.4 — night verdictFail.
  static const Color oxblood70 = Color(0xFFE19A95);

  /// L\* 28.0 — paper + sunlight verdictFail. Mockup alias `oxblood`.
  static const Color oxblood28 = Color(0xFF7A2320);

  /// L\* 75.7 — night verdictWarn.
  static const Color ochre76 = Color(0xFFD8B84A);

  /// L\* 46.7 — paper verdictWarn (mark only). Mockup alias `ochre`.
  static const Color ochre47 = Color(0xFF8A6A16);

  /// L\* 37.6 — sunlight verdictWarn.
  static const Color ochre38 = Color(0xFF6E5512);
}
