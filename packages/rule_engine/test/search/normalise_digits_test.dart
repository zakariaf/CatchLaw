// Contract step 8: both Arabic-Indic digit ranges to ASCII.
//
// Two ranges because both are typed. A device configured for Persian or Urdu
// digit entry emits U+06F0-U+06F9 even for Arabic text — neither is a shipping
// locale (D-3), but a keyboard is not a locale — and several digits are
// visually near-identical across the two sets. An implementation that maps only
// the first range passes every test written with ٣٨ and fails silently on a
// keyboard nobody tested.
//
// This is a KEY transform and never a display one. The numeral system the user
// SEES is decided elsewhere (SPEC.md §9.3, i18n-rtl-l10n); nothing in this
// package formats a number a person reads.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('normaliseSpeciesTerm', () {
    for (var d = 0; d < 10; d++) {
      final arabicIndic = String.fromCharCode(0x0660 + d);
      test('maps Arabic-Indic "$arabicIndic" to "$d"', () {
        expect(normaliseSpeciesTerm(arabicIndic), '$d');
      });
    }

    for (var d = 0; d < 10; d++) {
      final eastern = String.fromCharCode(0x06F0 + d);
      test('maps Eastern Arabic-Indic "$eastern" to "$d"', () {
        expect(normaliseSpeciesTerm(eastern), '$d');
      });
    }

    test('maps a multi-digit Arabic-Indic number', () {
      // Multi-digit is where a per-character map that forgets to be global
      // fails.
      expect(normaliseSpeciesTerm('٣٨'), '38');
    });

    test('leaves an ASCII digit unchanged', () {
      // A map that subtracts an offset unconditionally corrupts this one.
      expect(normaliseSpeciesTerm('45'), '45');
    });

    test('maps digits inside an Arabic phrase', () {
      // A real shape: a zone code. Also asserts the digit map runs AFTER T04's
      // terminal collapse, since the ة of المنطقة is gone.
      expect(normaliseSpeciesTerm('المنطقة ٣'), 'المنطق 3');
    });

    test('leaves the Arabic percent sign unchanged', () {
      // U+066A sits immediately above the Arabic-Indic range. An off-by-one on
      // the upper bound silently corrupts a percentage.
      expect(normaliseSpeciesTerm('٪'), '٪');
    });

    test('leaves the Arabic-Indic range lower neighbour unchanged', () {
      // U+065F ARABIC WAVY HAMZA BELOW — the other end of the same boundary. It
      // also deliberately survives T03: the harakat range is U+064B-U+0652 plus
      // U+0670, and U+065F is in neither.
      expect(normaliseSpeciesTerm('\u065F'), '\u065F');
    });

    test('maps the two numeral sets onto one key', () {
      // A Persian-keyboard five and an Arabic-keyboard five are the same key.
      expect(normaliseSpeciesTerm('٥'), normaliseSpeciesTerm('۵'));
      expect(normaliseSpeciesTerm('٥'), '5');
    });
  });

  group('indexKeys', () {
    test('maps digits on the query side as well as the index side', () {
      // §9.4 step 6 says "in both the index and the query", and indexKeys is
      // what both sides call.
      expect(indexKeys('٣٨').toList(), indexKeys('38').toList());
      expect(indexKeys('٣٨').toList(), ['38']);
    });
  });
}
