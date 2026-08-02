import 'package:catchlaw/data/model/enum_codecs.dart';

/// The single conversion point from stored millimetres to a displayed length.
///
/// **Storage is always integer millimetres** (`SPEC.md` §9.5), and the display
/// unit is a separate decision the fisher makes in S14. Keeping the conversion
/// in one function means a length shown on the result screen and the same
/// length shown in the catch log cannot round differently — and a legal
/// minimum that reads 44 cm on one screen and 45 cm on another is the failure
/// this product exists to prevent.
abstract final class LengthDisplay {
  /// [millimetres] in [unit], as a number without its unit word.
  ///
  /// The unit word is an ARB value and belongs beside the number in a
  /// localised message, glued with a non-breaking space — never concatenated
  /// here, where the word order would be wrong in Arabic.
  ///
  /// Centimetres round to one decimal and drop a trailing `.0`, because
  /// `45 cm` is what the instrument says and `45.0 cm` reads as a measurement
  /// rather than as a limit. Inches keep one decimal always: a quarter inch
  /// matters and 17 vs 17.5 is a different fish.
  static String format(int millimetres, LengthUnit unit) => switch (unit) {
    LengthUnit.mm => '$millimetres',
    LengthUnit.cm => _trimZero((millimetres / 10).toStringAsFixed(1)),
    LengthUnit.inches => (millimetres / 25.4).toStringAsFixed(1),
  };

  static String _trimZero(String value) =>
      value.endsWith('.0') ? value.substring(0, value.length - 2) : value;
}
