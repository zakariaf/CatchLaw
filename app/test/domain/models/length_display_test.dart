import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/length_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LengthDisplay.format renders a whole centimetre without a trailing zero', () {
    // `45 cm` is what the instrument says. `45.0 cm` reads as a measurement
    // rather than as a limit.
    expect(LengthDisplay.format(450, LengthUnit.cm), '45');
  });

  test('LengthDisplay.format keeps a half centimetre', () {
    expect(LengthDisplay.format(455, LengthUnit.cm), '45.5');
  });

  test('LengthDisplay.format renders millimetres as the integer they are stored as', () {
    expect(LengthDisplay.format(455, LengthUnit.mm), '455');
  });

  test('LengthDisplay.format keeps one decimal on inches always', () {
    // A quarter inch matters, and 17 versus 17.5 is a different fish.
    expect(LengthDisplay.format(450, LengthUnit.inches), '17.7');
    expect(LengthDisplay.format(254, LengthUnit.inches), '10.0');
  });

  test('LengthDisplay.format never rounds a length up past its stored value in cm', () {
    // A minimum that reads one centimetre larger than it is turns a legal fish
    // into a fine. Checked across the whole range a size rule uses.
    for (var mm = 1; mm <= 1200; mm++) {
      final double shown = double.parse(LengthDisplay.format(mm, LengthUnit.cm));
      expect(shown * 10, lessThanOrEqualTo(mm + 0.5), reason: '$mm mm rendered as $shown cm');
    }
  });

  test('LengthDisplay.format emits no unit word', () {
    // The unit word is an ARB value and belongs beside the number in a
    // localised message, glued with a non-breaking space — never concatenated
    // here, where the word order would be wrong in Arabic.
    for (final LengthUnit unit in LengthUnit.values) {
      expect(LengthDisplay.format(450, unit), matches(RegExp(r'^[0-9.]+$')), reason: unit.name);
    }
  });
}
