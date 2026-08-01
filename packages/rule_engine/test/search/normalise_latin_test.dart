// The Latin half of the SPEC.md §9.4 fold: steps 9 and 10 of the ordered
// pipeline in catchlaw-rule-engine/references/normalisation-contract.md.
//
// Four of the six shipping locales (D-3) publish species names with accents the
// fisher will not type — gl, ca, es and pt_BR — so this half has four customers,
// not one. The Arabic steps 1 to 8 arrive in T03 to T06 and every test here must
// still pass when they do.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('normaliseSpeciesTerm', () {
    test('folds n-tilde to n', () {
      expect(normaliseSpeciesTerm('Señorita'), 'senorita');
    });

    test('folds c-cedilla and a-tilde to c and a', () {
      expect(normaliseSpeciesTerm('Cação'), 'cacao');
    });

    test('folds a-acute to a', () {
      expect(normaliseSpeciesTerm('Sábalo'), 'sabalo');
    });

    test('folds e-acute to e', () {
      expect(normaliseSpeciesTerm('Nécora'), 'necora');
    });

    test('lowercases a scientific name', () {
      expect(normaliseSpeciesTerm('EPINEPHELUS COIOIDES'), 'epinephelus coioides');
    });

    test('collapses a run of spaces to one', () {
      expect(normaliseSpeciesTerm('epinephelus  coioides'), 'epinephelus coioides');
    });

    test('trims leading and trailing whitespace', () {
      expect(normaliseSpeciesTerm('  hamour '), 'hamour');
    });

    test('keeps an internal hyphen', () {
      expect(normaliseSpeciesTerm('Orange-spotted grouper'), 'orange-spotted grouper');
    });

    test('maps a precomposed and a decomposed a-acute to one key', () {
      // A lookup table of precomposed characters passes every test above and
      // fails this one, which is the whole reason NFD is a dependency rather
      // than a map literal.
      const precomposed = 'S\u00E1balo'; // a-acute as ONE code point
      const decomposed = 'Sa\u0301balo'; // a, then COMBINING acute
      expect(precomposed, isNot(decomposed), reason: 'the inputs must genuinely differ');
      expect(normaliseSpeciesTerm(precomposed), normaliseSpeciesTerm(decomposed));
      expect(normaliseSpeciesTerm(decomposed), 'sabalo');
    });

    test('is idempotent for a Latin term', () {
      // The builder folds at build time and the app folds at query time. A
      // non-idempotent step makes a rebuilt database drift from the running app.
      final String once = normaliseSpeciesTerm('Ameixa babosa');
      expect(normaliseSpeciesTerm(once), once);
      expect(once, 'ameixa babosa');
    });

    test('returns an empty string when the input is empty', () {
      expect(normaliseSpeciesTerm(''), '');
    });

    test('returns an empty string when the input is only whitespace', () {
      expect(normaliseSpeciesTerm('   '), '');
    });
  });
}
