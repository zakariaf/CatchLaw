import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/length_display.dart';
import 'package:intl/intl.dart';

/// The three localised patterns a measurement can be printed with.
///
/// Passed in rather than looked up, so this function needs no `BuildContext`
/// and its rows run with no pump. Each takes the number and the method
/// separately, because the two go on different sides of the sentence in
/// different languages.
typedef MeasurementPatterns = ({
  String Function(String value, String method) cm,
  String Function(String value, String method) mm,
  String Function(String value, String method) inch,
});

/// [millimetres], printed in [unit], with [methodLabel] beside it.
///
/// **The method is not optional and there is no overload without it.** TL and
/// FL differ by 6–9 cm on a Kanaad, so `45 cm` on its own is a number the
/// reader cannot act on — `check_measurement.sh` check 2 exists because a
/// measurement without its method is a defect rather than a shortcut.
///
/// The digits come from [numbers], the one formatter the whole app uses, so a
/// length on the result screen and the same length in the catch log cannot come
/// out in different digit blocks.
String formatMeasurement(
  int millimetres, {
  required LengthUnit unit,
  required NumberFormat numbers,
  required String methodLabel,
  required MeasurementPatterns patterns,
}) {
  final String value = switch (unit) {
    // Formatted through LengthDisplay first, so the rounding rule lives in one
    // place, then through the locale's own NumberFormat so the digits and the
    // decimal separator are the reader's.
    LengthUnit.mm => numbers.format(millimetres),
    LengthUnit.cm => _localise(LengthDisplay.format(millimetres, LengthUnit.cm), numbers),
    LengthUnit.inches => _localise(LengthDisplay.format(millimetres, LengthUnit.inches), numbers),
  };
  return switch (unit) {
    LengthUnit.mm => patterns.mm(value, methodLabel),
    LengthUnit.cm => patterns.cm(value, methodLabel),
    LengthUnit.inches => patterns.inch(value, methodLabel),
  };
}

/// Re-renders an ASCII decimal through the locale's own formatter.
///
/// `LengthDisplay` produces `45.5`; a Spanish reader expects `45,5` and an
/// Arabic reader with the lever pulled expects Arabic-Indic digits. Splitting
/// on the ASCII point and reassembling through `NumberFormat` is what gets both
/// without a second rounding rule.
String _localise(String ascii, NumberFormat numbers) {
  final double parsed = double.parse(ascii);
  return parsed == parsed.roundToDouble() ? numbers.format(parsed.round()) : numbers.format(parsed);
}
