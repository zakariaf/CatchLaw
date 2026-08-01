/// The alias table as the content pipeline authors it, reproducing the table in
/// `catchlaw-rule-engine/examples/species_normalisation.dart`.
///
/// Every entry is an AUTHORED name mapped to a species id. Display names are
/// stored unmodified elsewhere; nothing here is generated. `hammour` is the case
/// that makes the point: a transliteration variant is a row somebody wrote, not
/// a string the fold produced, and `shari` is absent for the same reason.
///
/// `k`-prefixed because `CONVENTIONS.md` §6 requires it for fixture constants in
/// `testing/models/`. That is the narrower rule and it wins over
/// `FLUTTER_GUIDE.md` §3.1's general ban — for fixtures, and only for fixtures.
const kSpeciesAliases = <String, String>{
  'هامور': 'epinephelus-coioides',
  'الهامور': 'epinephelus-coioides',
  'hamour': 'epinephelus-coioides',
  'hammour': 'epinephelus-coioides', // a transliteration variant is AUTHORED
  'Orange-spotted grouper': 'epinephelus-coioides',
  'Epinephelus coioides': 'epinephelus-coioides',
  'شعري': 'lethrinus-nebulosus',
  'Spangled emperor': 'lethrinus-nebulosus',
  'Lethrinus nebulosus': 'lethrinus-nebulosus',
  'Ameixa babosa': 'venerupis-corrugata',
  'Venerupis corrugata': 'venerupis-corrugata',
};
