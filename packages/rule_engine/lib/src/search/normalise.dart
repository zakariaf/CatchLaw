import 'package:unorm_dart/unorm_dart.dart' as unorm;

/// Combining diacritical marks, U+0300 to U+036F.
///
/// Deliberately narrow. Arabic harakat sit at U+064B to U+0652 and are a
/// separate, later step of the contract, so widening this class would silently
/// do that step's work in the wrong position and change the key.
///
/// Written as escapes because a literal combining mark in source renders on top
/// of the character before it, which makes the range invisible to a reviewer.
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
/// `catchlaw-rule-engine/references/normalisation-contract.md`. They are not
/// restated here — one copy of that list, and it is the contract's.
///
/// Lowercasing is invariant, never locale-aware. A key whose value depends on
/// the device locale is a key the builder cannot reproduce.
///
/// This is a fold, not a tokeniser: punctuation survives, so
/// `Orange-spotted grouper` keeps its hyphen.
String normaliseSpeciesTerm(String input) {
  var s = input;

  // Contract steps 1 to 8 — NFKC, tatweel, harakat and superscript alef, the
  // alef family, hamza on waw and ya, alef maqsura, the word-final collapse and
  // the digit fold — are inserted HERE, in order, by E02/T03 to E02/T06. The
  // file reads in the contract's order so prose can be diffed against code.

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
