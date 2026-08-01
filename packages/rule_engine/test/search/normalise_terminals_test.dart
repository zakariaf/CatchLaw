// Contract step 7: the word-final ta-marbuta and ha collapse.
//
// SPEC.md §9.4 records the first draft folding ة to ه, which produced هاموره
// from هامورة. That string is neither equal to nor a PREFIX of هامور, and
// search is a prefix query over an indexed search_norm column (§13), so losing
// the prefix property does not rank the fish lower — it removes it from the
// result set. Both terminal forms therefore collapse to NOTHING.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('normaliseSpeciesTerm', () {
    test('strips a word-final ta marbuta', () {
      expect(normaliseSpeciesTerm('هامورة'), 'هامور');
    });

    test('leaves a bare stem unchanged', () {
      expect(normaliseSpeciesTerm('هامور'), 'هامور');
    });

    test('strips a word-final ha', () {
      // هاموره is the exact string SPEC.md §9.4 records the first draft
      // producing. The corrected fold must land it on the same key as the
      // stem, not merely stop creating it.
      expect(normaliseSpeciesTerm('هاموره'), 'هامور');
    });

    test('keeps a medial ha', () {
      // The over-fold guard. A global replaceAll would delete this ه and merge
      // unrelated names — the contract's "two species collapse into one".
      expect(normaliseSpeciesTerm('شهري'), 'شهري');
    });

    test('keeps a word-final ya', () {
      // T03 folded ى onto ي; this step must not now delete it. Deleting a
      // word-final ya would put شعري, one of §9.1's five species, on the same
      // key as شعر.
      expect(normaliseSpeciesTerm('شعري'), 'شعري');
    });

    test('strips a terminal form in each word of a phrase', () {
      // Word-final means every word, not the string's last character.
      expect(normaliseSpeciesTerm('سمكة كبيرة'), 'سمك كبير');
    });

    test('strips a terminal form before an Arabic comma', () {
      // The boundary is not end-of-string. U+060C is what a gazette species
      // list is punctuated with, and Dart's \b would not fire here at all.
      expect(normaliseSpeciesTerm('هامورة،'), 'هامور،');
    });

    test('is idempotent', () {
      final String once = normaliseSpeciesTerm('هامورة');
      expect(normaliseSpeciesTerm(once), once);
      expect(once, 'هامور');
    });

    test('runs the terminal collapse after the alef fold', () {
      // T03 and this task asserted together: order is part of the contract.
      expect(normaliseSpeciesTerm('أهامورة'), 'اهامور');
    });

    test('returns an empty string when the input is empty', () {
      expect(normaliseSpeciesTerm(''), '');
    });

    test('maps هامورة and هامور to the same key', () {
      // The property rather than the transform. This is the row §9.4's
      // acceptance test rests on, and it survives a refactor that changes the
      // output alphabet.
      expect(normaliseSpeciesTerm('هامورة'), normaliseSpeciesTerm('هامور'));
    });
  });
}
