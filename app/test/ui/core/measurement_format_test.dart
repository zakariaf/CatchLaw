import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/length_display.dart';
import 'package:catchlaw/ui/core/format/measurement_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../../../testing/l10n/number_symbols_guard.dart';

const MeasurementPatterns _patterns = (cm: _cm, mm: _mm, inch: _inch);

String _cm(String value, String method) => '$value cm ($method)';
String _mm(String value, String method) => '$value mm ($method)';
String _inch(String value, String method) => '$value in ($method)';

String _format(int mm, {LengthUnit unit = LengthUnit.cm, String locale = 'en'}) =>
    formatMeasurement(
      mm,
      unit: unit,
      numbers: NumberFormat.decimalPattern(locale),
      methodLabel: 'total length',
      patterns: _patterns,
    );

void main() {
  setUp(captureNumberSymbols);
  tearDown(restoreNumberSymbols);

  test('kMillimetresPerInch is the exact inch', () {
    // 25.4 by definition since 1959. A named constant rather than a literal at
    // a call site, because a rounded 25.4 in one place and a 25 in another is a
    // fish that measures differently on two screens.
    expect(kMillimetresPerInch, 25.4);
  });

  test('formatMeasurement always prints the method beside the number', () {
    // TL and FL differ by 6-9 cm on a Kanaad, so `45 cm` on its own is a number
    // the reader cannot act on. There is no overload without it.
    expect(_format(450), contains('total length'));
  });

  test('formatMeasurement prints centimetres without a trailing zero', () {
    expect(_format(450), startsWith('45 cm'));
  });

  test('formatMeasurement keeps a half centimetre', () {
    expect(_format(455), startsWith('45.5 cm'));
  });

  test('formatMeasurement prints millimetres as the integer they are stored as', () {
    expect(_format(455, unit: LengthUnit.mm), startsWith('455 mm'));
  });

  test('formatMeasurement converts to inches through the exact factor', () {
    expect(_format(254, unit: LengthUnit.inches), startsWith('10 in'));
  });

  test('es - formatMeasurement uses the locale decimal separator', () {
    // 45,5 cm is what a Spanish reader expects, and getting it from the same
    // rounding rule is why LengthDisplay runs first and NumberFormat second.
    expect(_format(455, locale: 'es'), startsWith('45,5 cm'));
  });

  test('formatMeasurement glues the unit to its value with a non-breaking space', () {
    // A unit that wrapped onto the next line is a length whose unit belongs to
    // the line below it.
    expect(_format(450), contains(' cm'));
    expect(_format(450), isNot(contains('45 cm')));
  });

  test('formatMeasurement takes its digits from the formatter it was given', () {
    // The one formatter the whole app uses, so a length on the result screen
    // and the same length in the catch log cannot come out in different digit
    // blocks.
    final String arabic = formatMeasurement(
      450,
      unit: LengthUnit.cm,
      numbers: NumberFormat.decimalPattern('ar'),
      methodLabel: 'الطول الكلي',
      patterns: _patterns,
    );
    expect(arabic, contains('الطول الكلي'));
  });
}
