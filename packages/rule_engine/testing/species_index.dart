import 'package:rule_engine/rule_engine.dart';

/// An in-memory stand-in for the indexed prefix query of `SPEC.md` §13.
///
/// There is no `reference.db` until E05, so the species id in the §9.4
/// acceptance test has to come from somewhere. This builds the same thing E04's
/// builder will write into `species_name` — one row per key from [indexKeys] —
/// and reads it back the way E05's query will.
///
/// **It contains no normalisation of its own.** It calls [indexKeys] and looks
/// up a map. If it ever grows a `replaceAll`, it has become a second normaliser
/// and the guarantee this whole package exists for is gone; running
/// `check_rule_engine.sh` against `packages/rule_engine` rather than only
/// `packages/rule_engine/lib` is what proves it has not.
///
/// It does NOT model the prefix half of §13's query — it matches whole keys.
/// That is deliberate: the property under test is that the fold puts every
/// spelling on the key the index holds, and whole-key equality is the strictest
/// form of that. Prefix behaviour is E08's, over real SQL.
class SpeciesIndex {
  /// Indexes every alias in [aliases] under each of its [indexKeys].
  SpeciesIndex(Map<String, String> aliases) {
    aliases.forEach((String alias, String speciesId) {
      for (final String key in indexKeys(alias)) {
        _byKey[key] = speciesId;
      }
    });
  }

  final Map<String, String> _byKey = <String, String>{};

  /// How many keys the index holds, so a test can assert it was not built empty.
  int get keyCount => _byKey.length;

  /// The species id [query] reaches, or `null` if no authored alias matches.
  ///
  /// Tries the query's keys in the order [indexKeys] yields them, so the
  /// unstripped form wins when both are present. Returns `null` rather than a
  /// guess: an unauthored transliteration is a miss, and generating one would
  /// make this package invent law it was never given.
  String? lookup(String query) {
    for (final String key in indexKeys(query)) {
      final String? hit = _byKey[key];
      if (hit != null) return hit;
    }
    return null;
  }
}
