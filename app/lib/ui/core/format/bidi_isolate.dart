/// FIRST STRONG ISOLATE — U+2068.
const String _fsi = '\u2068';

/// LEFT-TO-RIGHT ISOLATE — U+2066.
const String _lri = '\u2066';

/// POP DIRECTIONAL ISOLATE — U+2069.
const String _pdi = '\u2069';

/// [run] wrapped so a right-to-left line cannot reorder it.
///
/// **A known direction rather than first-strong**, because first-strong
/// mis-guesses on leading punctuation and an instrument name often starts with
/// one. `Ministerial Decision 580/2015, Art. 3` inside an Arabic sentence
/// otherwise puts the article number at the wrong end of the line — which is
/// not a typographic nicety when the number is what the reader is checking
/// against a printed page.
///
/// **View layer only.** An isolate character that reaches storage, search or an
/// export is a character in the data, so this is applied where the string is
/// drawn and nowhere earlier.
String isolateLtr(String run) => '$_lri$run$_pdi';

/// [run] wrapped when its direction is not known in advance.
String isolate(String run) => '$_fsi$run$_pdi';
