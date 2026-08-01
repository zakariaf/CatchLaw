// SPEC.md §9.4 step 5: strip the leading ال AND index both forms.
//
// The article is a key VARIANT, not a fold step. If normaliseSpeciesTerm
// stripped it, the unstripped key could never be produced by anything and a
// fisher who types the article would miss — which is the contract's named
// failure "الهامور misses but هامور hits, article stripped at index time only".
// Khalid types the article.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('indexKeys', () {
    test('yields the unstripped and the stripped key for الهامور', () {
      expect(indexKeys('الهامور').toList(), ['الهامور', 'هامور']);
    });

    test('yields the unstripped key first', () {
      // The lookup tries them in order, so an unstable order makes a two-hit
      // index nondeterministic. The unstripped key is the more specific match.
      expect(indexKeys('الهامور').first, 'الهامور');
    });

    test('yields one key for a term with no article', () {
      // The common case must not grow a spurious second species_name row.
      expect(indexKeys('هامور').toList(), ['هامور']);
    });

    test('yields both keys for الشعري', () {
      // A second species, so the rule is not fitted to one word.
      expect(indexKeys('الشعري').toList(), ['الشعري', 'شعري']);
    });

    test('yields one key when stripping ال would leave fewer than three characters', () {
      // The contract's short-stem guard: mechanical and deliberately
      // over-cautious. Below three remaining characters it declines to strip
      // whether or not the ا ل really was an article, because a two-letter key
      // under a prefix query capped at 40 results (§13) matches half the table.
      expect(indexKeys('الفن').toList(), ['الفن']);
    });

    test('yields no keys for an empty string', () {
      // An empty key in the index matches every prefix query.
      expect(indexKeys('').toList(), isEmpty);
    });

    test('yields no keys for a whitespace-only string', () {
      // The fold turns this into ''. This asserts the guard reads the FOLDED
      // value and not the raw input.
      expect(indexKeys('   ').toList(), isEmpty);
    });

    test('yields one key for a Latin binomial', () {
      // The article rule is Arabic-only, and the folded form is what is indexed.
      expect(indexKeys('Epinephelus coioides').toList(), ['epinephelus coioides']);
    });

    test('strips the article from the folded form, not the raw input', () {
      // Order: article stripping consumes T04's output. Strip first and the
      // terminal ة survives into both keys.
      expect(indexKeys('الهامورة').toList(), ['الهامور', 'هامور']);
    });

    test('yields the same key for الهامور and for a Presentation-Form paste of it', () {
      // Ties this task to T03: the article check runs on canonical letters, so
      // ال in Presentation Forms is still an article.
      // U+FE8D alef, U+FEDF lam, U+FEE9 heh, U+FE8D alef, U+FEE1 meem,
      // U+FEED waw, U+FEAD reh.
      const paste = 'ﺍﻟﻩﺍﻡﻭﺭ';
      expect(paste, isNot('الهامور'), reason: 'the input must really be in Presentation Forms');
      expect(indexKeys(paste).toList(), indexKeys('الهامور').toList());
      expect(indexKeys(paste).first, 'الهامور');
    });
  });

  group('normaliseSpeciesTerm', () {
    test('leaves the definite article in place', () {
      // The fold must NOT strip. If it did, the unstripped key would be
      // unreachable and the article-typed query would miss.
      expect(normaliseSpeciesTerm('الهامور'), 'الهامور');
    });
  });
}
