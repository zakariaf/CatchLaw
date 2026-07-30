// Demonstrates the CatchLaw species normalisation contract in pure Dart with ZERO Flutter imports:
// the single ordered normaliseSpeciesTerm (NFKC first, then tatweel, harakat, alef/waw/ya folding,
// word-final ta-marbuta, Arabic-Indic digits), dual indexing of the definite article ال so both
// forms hit one species id, and the acceptance test that pins it — hamour, هامور, هامورة, الهامور
// and Epinephelus coioides all resolve to `epinephelus-coioides`, while شعري stays separate.
// Runs under `dart run --enable-asserts`, no Flutter SDK.

/// The ONE normalisation entry point. The CLI indexer and the runtime query BOTH call this, so an
/// index key and a query key can never disagree.
///
/// [nfkc] is injected only so this file stands alone; the app passes a real NFKC implementation and
/// it MUST run first — scanned Gulf gazettes arrive as Arabic Presentation Forms (U+FB50-U+FEFF),
/// and every later step assumes canonical code points.
String normaliseSpeciesTerm(String input, {String Function(String)? nfkc}) {
  var s = (nfkc ?? (String x) => x)(input);
  s = s.replaceAll('ـ', ''); // U+0640 tatweel — a typographic stretch, never a letter
  s = s.replaceAll(RegExp('[ً-ْٰ]'), ''); // U+064B-U+0652 harakat + U+0670 dagger alef
  s = s.replaceAll(RegExp('[آأإٱ]'), 'ا'); // alef family to U+0627
  s = s.replaceAll('ؤ', 'و').replaceAll('ئ', 'ي'); // hamza on waw / ya
  s = s.replaceAll('ى', 'ي'); // U+0649 alef maqsura to U+064A ya
  s = s.replaceAll(RegExp('[ةه]\$'), ''); // word-final ta-marbuta / ha ONLY, never medial
  s = s.replaceAllMapped(RegExp('[٠-٩]'), (m) => '${m[0]!.codeUnitAt(0) - 0x0660}');
  s = s.replaceAllMapped(RegExp('[۰-۹]'), (m) => '${m[0]!.codeUnitAt(0) - 0x06F0}');
  s = s.replaceAll(RegExp('[‌-‏]'), ''); // ZWJ / ZWNJ / LRM / RLM
  // Invariant lowercase, never locale-sensitive: the Turkish dotless i is a real hazard.
  return s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Both keys point at the same species id: the definite article is stripped AND kept.
/// Stripping only at index time is the classic bug — the fisher types الهامور and the search misses.
Iterable<String> indexKeys(String term) sync* {
  final k = normaliseSpeciesTerm(term);
  if (k.isEmpty) return;
  yield k;
  // Not below three remaining characters: that is a word, not an article.
  if (k.startsWith('ال') && k.length - 2 >= 3) yield k.substring(2);
}

/// The alias table as the content pipeline authors it. Display names are stored UNMODIFIED
/// elsewhere; these keys exist only to find a row.
const _aliases = <String, String>{
  'هامور': 'epinephelus-coioides',
  'الهامور': 'epinephelus-coioides',
  'hamour': 'epinephelus-coioides',
  'hammour': 'epinephelus-coioides', // a transliteration variant is AUTHORED, never generated
  'Orange-spotted grouper': 'epinephelus-coioides',
  'Epinephelus coioides': 'epinephelus-coioides',
  'شعري': 'lethrinus-nebulosus',
  'Spangled emperor': 'lethrinus-nebulosus',
  'Lethrinus nebulosus': 'lethrinus-nebulosus',
  'كنعد': 'scomberomorus-commerson',
  'Ameixa babosa': 'venerupis-corrugata',
  'Venerupis corrugata': 'venerupis-corrugata',
};

/// Built once by the CLI indexer, shipped inside the read-only reference DB.
Map<String, String> buildIndex(Map<String, String> aliases) {
  final index = <String, String>{};
  aliases.forEach((alias, speciesId) {
    for (final key in indexKeys(alias)) {
      index[key] = speciesId;
    }
  });
  return index;
}

/// The runtime query normalises through the SAME function, then tries both key forms.
String? lookup(Map<String, String> index, String query) {
  for (final key in indexKeys(query)) {
    final hit = index[key];
    if (hit != null) return hit;
  }
  return null; // NOT "no rule" and NOT permission — just an unrecognised name
}

void main() {
  final index = buildIndex(_aliases);

  // Acceptance: eight spellings of one fish, one species id.
  const hamour = <String>[
    'hamour',
    'HAMOUR',
    'هامور',
    'هامورة', // ta-marbuta
    'الهامور', // definite article
    'هــامور', // tatweel
    'Epinephelus coioides',
    'epinephelus  coioides', // doubled space
  ];
  for (final q in hamour) {
    assert(lookup(index, q) == 'epinephelus-coioides', 'failed to resolve "$q"');
    print('${q.padRight(24)} -> ${lookup(index, q)}');
  }

  // Separation: the folds above must not over-merge distinct species.
  assert(lookup(index, 'شعري') == 'lethrinus-nebulosus');
  assert(lookup(index, 'الشعري') == 'lethrinus-nebulosus');
  assert(lookup(index, 'كنعد') == 'scomberomorus-commerson');
  assert(lookup(index, 'Ameixa babosa') == 'venerupis-corrugata');
  assert(lookup(index, 'shari') == null); // an unauthored transliteration is a miss, not a guess
  print('شعري / الشعري            -> ${lookup(index, "الشعري")}');
  print('Ameixa babosa            -> ${lookup(index, "Ameixa babosa")}');

  // Arabic-Indic digits fold for keys only; the user still SEES the numerals of their locale.
  assert(normaliseSpeciesTerm('٣٨') == '38');
  print('all normalisation acceptance cases pass');
}
