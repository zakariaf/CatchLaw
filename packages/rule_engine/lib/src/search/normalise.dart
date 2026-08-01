import 'package:unorm_dart/unorm_dart.dart' as unorm;

// Every character class below is a \u escape. A literal harakat renders on top
// of the letter before it, a literal ZWNJ renders as nothing at all, and a
// reviewer cannot approve what they cannot see. Keeping them all in this one
// file is also what check 4 of check_rule_engine.sh requires: a second file
// carrying an Arabic class is reported as a drifting normaliser, which is
// exactly what it would be.

/// U+0640 ARABIC TATWEEL — a typographic stretch, never a letter.
final RegExp _tatweel = RegExp('\u0640');

/// U+064B-U+0652 harakat, plus U+0670 ARABIC LETTER SUPERSCRIPT ALEF.
///
/// U+0670 sits outside the run, and is the character an implementation with a
/// single range silently misses.
final RegExp _harakat = RegExp('[\u064B-\u0652\u0670]');

/// U+200C-U+200F: ZWNJ, ZWJ, LRM, RLM.
final RegExp _invisibleMarks = RegExp('[\u200C-\u200F]');

/// U+0622 آ, U+0623 أ, U+0625 إ, U+0671 ٱ — hamza placement is inconsistent
/// across sources and keyboards. U+0627 ا is absent because it is the target.
final RegExp _alefFamily = RegExp('[\u0622\u0623\u0625\u0671]');

/// U+0624 ؤ, hamza on waw.
final RegExp _hamzaOnWaw = RegExp('\u0624');

/// U+0626 ئ hamza on ya, and U+0649 ى alef maqsura.
///
/// The maqsura is FOLDED here, never deleted word-finally. `SPEC.md` §9.1 names
/// شعري and صافي, so a word-final ya must survive; deleting a word-final
/// maqsura instead would split the Egyptian spelling of a name from the Gulf
/// one. E02/T04 carries the full argument.
final RegExp _yaFamily = RegExp('[\u0626\u0649]');

/// U+0629 ة or U+0647 ه at the end of a WORD, and nowhere else.
///
/// Deleting a medial ه merges unrelated names, which is the contract's "two
/// species collapse into one". The anchor is a negative lookahead on the Arabic
/// letter block rather than `\b`: Dart's word boundary is defined on ASCII word
/// characters, so it never fires between ة and a space and does fire inside
/// Arabic text where nobody intends it. The lookahead makes the Arabic comma
/// U+060C a boundary, which is how a gazette species list is punctuated.
///
/// U+0649 ى is deliberately absent. T03 folded it onto ي, and a word-final ي is
/// never deleted — §9.1 names شعري and صافي.
final RegExp _wordFinalTaMarbutaOrHa = RegExp('[\u0629\u0647](?![\u0621-\u064A\u0671-\u06D3])');

/// U+0660-U+0669 Arabic-Indic digits and U+06F0-U+06F9 the Eastern set.
///
/// Both, because both are typed: a device configured for Persian or Urdu digit
/// entry emits the second range even for Arabic text, and a keyboard is not a
/// locale. Mapping only the first passes every test written with ٣٨ and fails
/// silently on a keyboard nobody tested.
///
/// The bounds are explicit rather than "any Unicode decimal digit", which would
/// swallow Devanagari and Thai digits — characters whose presence in a key would
/// mean something went wrong upstream. U+066A ٪ sits immediately above the first
/// range and must survive; a test sits on that boundary.
final RegExp _arabicIndicDigits = RegExp('[\u0660-\u0669\u06F0-\u06F9]');

/// Combining diacritical marks, U+0300 to U+036F.
///
/// Deliberately narrow. Arabic harakat sit at U+064B to U+0652 and are a
/// separate, earlier step of the contract, so widening this class would do that
/// step's work in the wrong position and change the key.
final RegExp _combiningMarks = RegExp('[\u0300-\u036F]');

/// Runs of whitespace, including the tab and newline an OCR paste carries.
final RegExp _whitespaceRun = RegExp(r'\s+');

/// Folds one written form of a name into the single key CatchLaw searches on.
///
/// The content builder calls this when it writes `species_name.search_norm` and
/// `legal_text.body_norm`, and the app calls it on whatever the fisher types.
/// Both sides must call this one function: a second implementation that agrees
/// today produces, on the day it stops agreeing, a database whose keys the app
/// cannot reproduce and a search that silently returns nothing.
///
/// The ordered steps are `SPEC.md` §9.4, numbered 1 to 10 in
/// `catchlaw-rule-engine/references/normalisation-contract.md`. The order is a
/// contract shared with `tools/content_builder/`, not an implementation detail.
/// The steps are not restated here — one copy of that list, and it is the
/// contract's.
///
/// Lowercasing is invariant, never locale-aware. A key whose value depends on
/// the device locale is a key the builder cannot reproduce.
///
/// This is a fold, not a tokeniser: punctuation survives, so
/// `Orange-spotted grouper` keeps its hyphen.
String normaliseSpeciesTerm(String input) {
  // Step 1 — NFKC, and it is FIRST for a reason that has a failure behind it.
  // The Gulf text is transcribed from gazette PDFs (SPEC.md §8) and a naive
  // extraction of those emits Arabic Presentation Forms, not letters. Fold the
  // alef family before this line and its class never matches U+FE83, the
  // Presentation Form survives into the key, Latin search keeps working, and
  // Arabic search silently returns nothing.
  String s = unorm.nfkc(input);

  // Step 2 — tatweel.
  s = s.replaceAll(_tatweel, '');

  // Step 3 — harakat and the superscript alef. Vowel marks are optional in
  // practice, so keeping them makes every voweled paste unreachable.
  s = s.replaceAll(_harakat, '');

  // Not numbered in §9.4, but in the contract's character reference: the
  // zero-width and bidi marks. They sit inside a word and make an otherwise
  // identical string a different key, and they cannot be seen in a diff, in a
  // review, or in a test failure message.
  s = s.replaceAll(_invisibleMarks, '');

  // Steps 4 to 6 — the letter families. Lossy on purpose, and safe because the
  // output is a SEARCH KEY: display_name_ar is stored unmodified and is what
  // the plate prints.
  s = s.replaceAll(_alefFamily, '\u0627'); // to U+0627 alef
  s = s.replaceAll(_hamzaOnWaw, '\u0648'); // to U+0648 waw
  s = s.replaceAll(_yaFamily, '\u064A'); // to U+064A ya

  // Step 7 — the word-final collapse, to NOTHING rather than to a shared
  // letter. SPEC.md §9.4 records the first draft folding ة to ه, which turned
  // هامورة into هاموره — neither equal to nor a PREFIX of هامور. Search is a
  // prefix query over an indexed column (§13), so losing the prefix property
  // does not rank the fish lower, it removes it from the result set.
  s = s.replaceAll(_wordFinalTaMarbutaOrHa, '');

  // Step 8 — both Arabic-Indic digit ranges to ASCII, by code-unit offset
  // rather than a twenty-entry map. The map is the version where one row has a
  // typo nobody sees; an offset cannot be half-right.
  s = s.replaceAllMapped(
    _arabicIndicDigits,
    (Match m) => String.fromCharCode(
      // Whichever range matched, the digit's value is its distance from that
      // range's zero.
      m[0]!.codeUnitAt(0) - (m[0]!.codeUnitAt(0) >= 0x06F0 ? 0x06F0 : 0x0660) + 0x30,
    ),
  );

  // Step 9 — the Latin fold. NFD splits a precomposed letter into its base and
  // its mark; deleting the marks is what turns ñ ç ã á into n c a a. A table of
  // precomposed characters passes every named case in §9.4 and fails a
  // decomposed paste, which is why this is a decomposition and not a map.
  s = unorm.nfd(s);
  s = s.replaceAll(_combiningMarks, '');
  s = s.toLowerCase();

  // Step 10 — collapse and trim. An untrimmed key is a key nothing matches.
  return s.replaceAll(_whitespaceRun, ' ').trim();
}

/// U+0627 U+0644 — the Arabic definite article.
const String _definiteArticle = '\u0627\u0644';

/// Below this many characters, a leading `ال` is a word, not an article.
///
/// The contract's guard, and it is mechanical on purpose: it declines to strip
/// whether or not the `ا` `ل` really was an article, because a two-letter key
/// under a prefix query capped at 40 results (`SPEC.md` §13) matches half the
/// table.
const int _minimumStemLength = 3;

/// The one or two keys [term] should be findable under, most specific first.
///
/// `SPEC.md` §9.4 step 5 requires the leading `ال` to be stripped AND both forms
/// indexed. That is a key VARIANT rather than a fold step, so it lives here and
/// not in [normaliseSpeciesTerm]: a fold that stripped the article would make
/// the unstripped key unproducible, and a fisher who types `الهامور` would find
/// nothing. The contract names that failure by hand, and Khalid types the
/// article.
///
/// Both sides call this. The content builder writes one `species_name` row per
/// key — §7.1 gives that table one `search_norm` column, so a second key is a
/// second row — and the query tries the keys in the order yielded. The order is
/// therefore fixed, not incidental.
///
/// Yields nothing for a term that folds away to nothing. An empty key in the
/// index matches every prefix query.
Iterable<String> indexKeys(String term) sync* {
  final String key = normaliseSpeciesTerm(term);
  if (key.isEmpty) return;
  yield key;
  if (key.startsWith(_definiteArticle) &&
      key.length - _definiteArticle.length >= _minimumStemLength) {
    yield key.substring(_definiteArticle.length);
  }
}
