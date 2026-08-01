// The SPEC.md §9.4 acceptance test.
//
// §4.1's "Done looks like" column says it in as many words: "Typing hamour,
// هامور, هامورة, الهامور or Epinephelus all reach the same species id. This is
// a unit test, not a manual check." A manual check of a search box proves the
// build somebody happened to run; this proves it on every commit, in CI, three
// epics before the database exists.
//
// It asserts SPECIES IDS, not normalised strings. That the fold maps هامورة to
// هامور is already asserted five times over in T02 to T06. The claim here is
// different and larger: the fold and the dual index fan out TOGETHER onto the
// row the builder wrote. A test on intermediate strings passes while those two
// disagree.

import 'package:test/test.dart';

import '../../testing/models/species_aliases.dart';
import '../../testing/species_index.dart';

/// The nine spellings §9.4 and the normalisation contract require to reach one
/// species id.
///
/// §9.4 names five; the contract's acceptance table adds the tatweel spelling,
/// the doubled space and the Presentation-Form paste; the worked example adds
/// HAMOUR, which pins the invariant lowercase. Every extra input traces to a
/// step this epic built.
const kHamourSpellings = <String>[
  'hamour',
  'HAMOUR', // autocapitalisation is on by default in a search field
  'هامور',
  'هامورة',
  'الهامور',
  'ه\u0640\u0640امور', // tatweel: a copy out of a justified PDF column carries it
  'Epinephelus coioides',
  'epinephelus  coioides', // doubled space: OCR and copy-paste both produce it
  // هامور in isolated Presentation Forms-B — U+FEE9 heh, U+FE8D alef,
  // U+FEE1 meem, U+FEED waw, U+FEAD reh. What a naive text extraction of a
  // gazette PDF actually emits, and the reason NFKC is step 1.
  'ﻩﺍﻡﻭﺭ',
];

void main() {
  final index = SpeciesIndex(kSpeciesAliases);

  group('SpeciesIndex', () {
    test('is built over a non-empty set of keys', () {
      // CONVENTIONS.md §7 through the front door of a test: every assertion
      // below is a lookup, and lookups over an empty index would all return
      // null while tests 12 and 14 kept passing.
      expect(index.keyCount, greaterThanOrEqualTo(kSpeciesAliases.length));
    });

    for (final String query in kHamourSpellings) {
      test('lookup resolves "$query" to epinephelus-coioides', () {
        expect(index.lookup(query), 'epinephelus-coioides');
      });
    }

    test('lookup resolves "شعري" to lethrinus-nebulosus', () {
      // Separation. The folds of T03 to T06 are lossy on purpose; this proves
      // they are not lossy enough to merge two of §9.1's species.
      expect(index.lookup('شعري'), 'lethrinus-nebulosus');
    });

    test('lookup resolves "الشعري" to lethrinus-nebulosus', () {
      // The dual index applies to every species, not only the one the
      // acceptance test is written around.
      //
      // THIS IS THE ROW THAT PROVES T05, and الهامور above is not. الهامور is
      // itself an authored alias, so the index holds it whole and the query
      // hits without the article ever being stripped: deleting the strip from
      // indexKeys leaves that row GREEN. شعري is authored WITHOUT the article,
      // so reaching it from الشعري is only possible through the stripped key.
      // Verified by mutation, not assumed.
      expect(index.lookup('الشعري'), 'lethrinus-nebulosus');
    });

    test('lookup returns null for the unauthored transliteration "shari"', () {
      // The line between folding and guessing. hammour is in the table because
      // somebody authored it; shari is not, and normalisation never invents a
      // transliteration. A miss, not a guess.
      expect(index.lookup('shari'), isNull);
    });

    test('lookup resolves "Ameixa babosa" to venerupis-corrugata', () {
      // A Galician name, so this is not an Arabic-only acceptance test. §9.1
      // makes gl a shipping locale because the Xunta publishes in it.
      expect(index.lookup('Ameixa babosa'), 'venerupis-corrugata');
    });

    test('lookup returns null for an empty query', () {
      // indexKeys yields nothing for an empty key, and this asserts the double
      // does not turn that into a match-anything.
      expect(index.lookup(''), isNull);
    });
  });
}
