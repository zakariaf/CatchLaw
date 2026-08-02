import 'dart:ui';

import 'package:catchlaw/theme/lonja_primitives.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/colour_math.dart';
import '../../testing/theme/pigment_table.dart';

void main() {
  test('cieLStar returns 0.0 for black', () {
    // The lower anchor, and the case a cube-root-only implementation returns
    // −16 for.
    expect(cieLStar(const Color(0xFF000000)), closeTo(0, 0.01));
  });

  test('cieLStar returns 100.0 for white', () {
    expect(cieLStar(const Color(0xFFFFFFFF)), closeTo(100, 0.01));
  });

  test('cieLStar resolves the linear branch below the CIE knee', () {
    // ink07's Y is 0.00774, under (6/29)³. The cube root gives 6.94 and the
    // naming law loses its footing at the dark end.
    expect(cieLStar(LonjaPrimitives.ink07), closeTo(6.99, 0.01));
  });

  test('contrastRatio returns 21.00 for black on white', () {
    // T03's contrast proof and T08's greyscale proof both stand on this; if it
    // is wrong they are all wrong together, and silently.
    expect(contrastRatio(LonjaPrimitives.black00, LonjaPrimitives.white100), closeTo(21, 0.005));
  });

  test('contrastRatio is symmetric in its arguments', () {
    // WCAG defines the ratio as lighter-over-darker. An implementation that
    // takes its arguments in order returns a number below 1 half the time.
    expect(
      contrastRatio(LonjaPrimitives.ink11, LonjaPrimitives.paper90),
      closeTo(contrastRatio(LonjaPrimitives.paper90, LonjaPrimitives.ink11), 1e-9),
    );
  });

  // Loop-generated: the name is interpolated so `--plain-name` selects one row.
  for (final PigmentRow row in kPigmentTable) {
    test('LonjaPrimitives.${row.name} measures L* ${row.lStar}', () {
      expect(cieLStar(row.colour), closeTo(row.lStar, 0.05));
    });

    test('LonjaPrimitives.${row.name} carries its measured lightness in its name', () {
      // `lonja-design-tokens` rule 2. A hex nudged without a rename is exactly
      // the drift the naming law exists to prevent. 0.6 is the widest gap the
      // published table contains — paper90 measures 90.54.
      expect((cieLStar(row.colour) - row.nameNumber).abs(), lessThan(0.6));
    });

    test('LonjaPrimitives.${row.name} is the ARGB value published for it', () {
      // Catches a transposed hex digit that happens to land within 0.6 L* of
      // the right lightness.
      expect(row.colour.toARGB32(), row.argb);
    });
  }

  test('kPigmentTable lists twenty-five pigments', () {
    // "Twenty-five primitives, and adding a twenty-sixth is a reviewed change."
    // A silent 26th is what this asserts against.
    expect(kPigmentTable.length, 25);
  });

  test('kPigmentTable binds every name to a distinct value', () {
    // Two names for one hex means one of them is a lie about what the theme
    // binds.
    expect(kPigmentTable.map((PigmentRow r) => r.argb).toSet(), hasLength(25));
  });

  test('LonjaPrimitives.paper90 and .paper89 are different colours', () {
    // 1.2 L* apart; one is the paper ground and one is night's primary text.
    // The single most plausible copy-paste in the file.
    expect(LonjaPrimitives.paper90, isNot(LonjaPrimitives.paper89));
  });

  test('LonjaPrimitives.ochre47 and .ochre38 are different colours', () {
    // ochre38 exists only so sunlight's warn clears 7:1. Using ochre47 there
    // ships 3.97:1 into the theme built for 100,000 lux.
    expect(LonjaPrimitives.ochre47, isNot(LonjaPrimitives.ochre38));
  });

  test('LonjaPrimitives.paper90 is a canonicalised const', () {
    // FLUTTER_GUIDE.md §8.2 mechanism 1: the const short-circuit only exists if
    // these really are compile-time constants.
    expect(identical(const Color(0xFFE6E4DC), LonjaPrimitives.paper90), isTrue);
  });
}
