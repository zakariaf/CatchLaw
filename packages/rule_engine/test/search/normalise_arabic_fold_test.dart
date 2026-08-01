// Steps 1 to 6 of the SPEC.md §9.4 fold, plus the invisible-mark deletion the
// contract's character reference carries and §9.4's numbered list does not.
//
// Arabic LETTERS are written literally here because they are legible to a
// reviewer. Everything INVISIBLE — harakat, the superscript alef, tatweel, the
// zero-width and bidi marks — is written as a \u escape, because a character
// nobody can see in the diff is a character nobody can review.
//
// Every Presentation Form below was checked against the Unicode chart before
// this file was run, not after: U+FEE9 heh, U+FE8D alef, U+FEE1 meem, U+FEED
// waw, U+FEAD reh, U+FE83 alef-with-hamza-above.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

/// `هامور` as a naive text extraction of a gazette PDF emits it: isolated
/// Presentation Forms-B rather than letters (SPEC.md §8, §9.4 step 1).
const _hamourPresentationForms = 'ﻩﺍﻡﻭﺭ';

/// The same word as an Arabic keyboard produces it.
const _hamourTyped = 'هامور';

void main() {
  group('normaliseSpeciesTerm', () {
    test('folds an Arabic Presentation Form to its canonical letter', () {
      expect(
        _hamourPresentationForms,
        isNot(_hamourTyped),
        reason: 'the input must really be in Presentation Forms',
      );
      expect(normaliseSpeciesTerm(_hamourPresentationForms), _hamourTyped);
    });

    test('treats a Presentation-Form paste and typed Arabic as one key', () {
      // The property, not the transform. T07's acceptance table rests on this.
      expect(normaliseSpeciesTerm(_hamourPresentationForms), normaliseSpeciesTerm(_hamourTyped));
    });

    test('runs NFKC before the alef fold', () {
      // U+FE83 is ALEF WITH HAMZA ABOVE, isolated form. NFKC maps it to U+0623,
      // and only then does the alef fold's class match and produce U+0627. The
      // fold's class does NOT contain U+FE83, so a plain alef here is proof of
      // the ordering — the correction SPEC.md §9.4 records the first draft
      // omitting, and the anti-pattern catchlaw-rule-engine names by hand.
      expect(normaliseSpeciesTerm('ﺃ'), 'ا');
    });

    test('strips tatweel', () {
      expect(normaliseSpeciesTerm('ه\u0640\u0640امور'), _hamourTyped);
    });

    test('strips harakat', () {
      // fatha on heh, damma on meem — a voweled paste from a PDF.
      expect(normaliseSpeciesTerm('ه\u064Eام\u064Fور'), _hamourTyped);
    });

    test('strips the superscript alef', () {
      // U+0670 sits OUTSIDE the U+064B-U+0652 run, so an implementation with a
      // single range passes the harakat test above and fails this one.
      expect(normaliseSpeciesTerm('ه\u0670امور'), _hamourTyped);
    });

    for (final form in const ['آ', 'أ', 'إ', 'ٱ']) {
      test('folds "$form" to plain alef', () {
        expect(normaliseSpeciesTerm('$formمور'), 'امور');
      });
    }

    test('folds hamza-on-waw to waw', () {
      expect(normaliseSpeciesTerm('لؤلؤ'), 'لولو');
    });

    test('folds hamza-on-ya to ya', () {
      expect(normaliseSpeciesTerm('صائد'), 'صايد');
    });

    test('folds alef maqsura to ya', () {
      // Egyptian-style spelling onto the Gulf one. Never DELETED word-finally:
      // SPEC.md §9.1 names شعري and صافي, and a word-final ya must survive.
      expect(normaliseSpeciesTerm('شعرى'), 'شعري');
    });

    test('deletes the zero-width and bidi marks', () {
      expect(normaliseSpeciesTerm('ه\u200Cامور'), _hamourTyped);
      expect(normaliseSpeciesTerm('\u200Fهامور\u200E'), _hamourTyped);
    });

    test('keeps هامور and شعري on different keys', () {
      // Steps 4 to 6 are lossy on purpose. This is the cheap proof they are not
      // lossy enough to merge two of the five species SPEC.md §9.1 names.
      expect(normaliseSpeciesTerm('هامور'), isNot(normaliseSpeciesTerm('شعري')));
    });

    test('keeps all five headline Gulf species on five distinct keys', () {
      // The pair above is not enough on its own. A fold that mapped every
      // Arabic letter to alef would still keep هامور and شعري apart, because
      // they differ in LENGTH — so the two-name guard passes under a mutation
      // that has destroyed the index. SPEC.md §9.1 names five species the folds
      // must keep apart, so all five are asserted, pairwise.
      const names = <String>['هامور', 'شعري', 'صافي', 'بدح', 'كنعد'];
      final Set<String> keys = names.map(normaliseSpeciesTerm).toSet();
      expect(
        keys,
        hasLength(names.length),
        reason: 'two of §9.1\'s five species collapsed onto one key: $keys',
      );
    });

    test('is idempotent for an Arabic term', () {
      final String once = normaliseSpeciesTerm(_hamourPresentationForms);
      expect(normaliseSpeciesTerm(once), once);
      expect(once, _hamourTyped);
    });

    test('folds a mixed Arabic and Latin string', () {
      // The regression an insertion above the Latin steps could cause: proves
      // T02's steps 9 and 10 still run after steps 1 to 6 were put in front.
      expect(normaliseSpeciesTerm('هامور  Epinephelus'), 'هامور epinephelus');
    });
  });
}
