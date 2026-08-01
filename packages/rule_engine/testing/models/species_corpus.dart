/// A SYNTHETIC corpus. Real vernacular names arrive with E04's Galicia seed and
/// E22; `SPEC.md` §8 is explicit that the content is the moat and that it is
/// weeks of work. Nothing here is authored law.
///
/// It exists to size the fold against `SPEC.md` §13's parameters — 400 species,
/// 2,400 names — and to exercise every step of the contract at scale rather than
/// only in the unit tests. Each species gets six names built from one real stem:
/// the bare form, the article-prefixed form, a ta-marbuta form, a tatweel form,
/// a voweled form, and a Latin binomial.
///
/// Deterministic by construction: no unseeded `Random`, no clock. A failure is
/// reproducible from the test name alone.
library;

/// Arabic stems this epic already uses, from `SPEC.md` §9.1's headline species.
const _arabicStems = <String>['هامور', 'شعري', 'صافي', 'بدح', 'كنعد'];

/// Latin binomials, so the corpus is not an Arabic-only exercise.
const _latinStems = <String>[
  'epinephelus coioides',
  'lethrinus nebulosus',
  'venerupis corrugata',
  'scomberomorus commerson',
  'siganus canaliculatus',
];

/// U+0640 tatweel, U+064E fatha — both invisible or near-invisible in source.
const _tatweel = '\u0640';
const _fatha = '\u064E';

/// The number of species the corpus models (`SPEC.md` §13).
const kCorpusSpeciesCount = 400;

/// Names per species. 400 x 6 = the 2,400 of §13.
const kCorpusNamesPerSpecies = 6;

/// The corpus as the content pipeline would author it: name to species id.
///
/// Built once at import. Every species id is distinct and every name is unique,
/// so a key collision in the folded output means the fold is lossier than the
/// contract allows — which is the property the parity suite asserts.
final Map<String, String> kSpeciesCorpus = _buildCorpus();

Map<String, String> _buildCorpus() {
  final corpus = <String, String>{};
  for (var i = 0; i < kCorpusSpeciesCount; i++) {
    final id = 'species-$i';
    final arabic = '${_arabicStems[i % _arabicStems.length]}$i';
    final latin = '${_latinStems[i % _latinStems.length]} $i';

    // All five Arabic forms fold onto the same key. That is the point: they are
    // the ways one authored name and one typed query can differ.
    // Both marks go AFTER a letter, which is the only place either occurs: a
    // tatweel stretches the join to the next letter and a harakat sits on the
    // letter before it. Prepending them would build a corpus of strings no
    // keyboard and no PDF can produce.
    final stretched = '${arabic[0]}$_tatweel${arabic.substring(1)}';
    final voweled = '${arabic[0]}$_fatha${arabic.substring(1)}';

    corpus[arabic] = id; // the bare stem
    corpus['ال$arabic'] = id; // the definite article (T05)
    corpus['$arabicة'] = id; // arabic + word-final ta marbuta (T04)
    corpus[stretched] = id; // tatweel (T03 step 2)
    corpus[voweled] = id; // a harakat (T03 step 3)
    corpus[latin.toUpperCase()] = id; // invariant lowercase (T02)
  }
  return corpus;
}
