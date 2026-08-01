// "One function, both directions" as a PROPERTY, over the whole corpus.
//
// Everything before T08 asserted transforms: this input becomes that string.
// Necessary, not sufficient. The claim that matters is that an alias folded at
// BUILD time and a query folded at RUN time land on a key they share — for
// every name, not for the nine T07 happens to name.
//
// The source-level half of this guarantee is not here and is not this file's:
// check 4 of check_rule_engine.sh reports any file other than normalise.dart
// carrying an Arabic character class, which is what stops a second copy being
// written. This is the behavioural half. Both are needed, because one function
// can still be non-idempotent, and a non-idempotent fold drifts between a
// database built once and a query folded on every keystroke.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/species_corpus.dart';
import '../../testing/species_index.dart';

/// The four ways an authored name and a typed query differ, from the contract's
/// dual-index table. Each pair must share a key.
const _dualIndexPairs = <(String, String)>[
  ('الهامور', 'هامور'), // the definite article
  ('هامورة', 'هامور'), // word-final ta marbuta
  ('ه\u0640\u0640امور', 'هامور'), // tatweel
  ('ﻩﺍﻡﻭﺭ', 'هامور'), // a Presentation-Form paste
];

void main() {
  test('The corpus holds 400 species and 2,400 names', () {
    // CONVENTIONS.md §7: every test below iterates the corpus, so all of them
    // pass vacuously over an empty one. This is the scan-count assertion.
    expect(kSpeciesCorpus, hasLength(kCorpusSpeciesCount * kCorpusNamesPerSpecies));
    expect(kSpeciesCorpus.values.toSet(), hasLength(kCorpusSpeciesCount));
  });

  group('normaliseSpeciesTerm', () {
    for (final (String authored, String typed) in _dualIndexPairs) {
      test('folds "$authored" and "$typed" to a shared key', () {
        final Set<String> a = indexKeys(authored).toSet();
        final Set<String> b = indexKeys(typed).toSet();
        expect(
          a.intersection(b),
          isNotEmpty,
          reason: 'the build side and the query side would never meet: $a vs $b',
        );
      });
    }

    test('is idempotent across the 2,400-name corpus', () {
      // The seam between a build-time fold and a run-time fold. One
      // non-idempotent step is the contract's "results appear then vanish after
      // a content rebuild".
      final offenders = <String>[
        for (final String name in kSpeciesCorpus.keys)
          if (normaliseSpeciesTerm(normaliseSpeciesTerm(name)) != normaliseSpeciesTerm(name)) name,
      ];
      expect(offenders, isEmpty, reason: 'f(f(x)) != f(x) for: ${offenders.take(5)}');
    });
  });

  group('indexKeys', () {
    test('is idempotent across the 2,400-name corpus', () {
      // The article strip must not fire twice on a key that has already lost
      // its article, or a rebuild produces a third key nothing points at.
      final offenders = <String>[
        for (final String name in kSpeciesCorpus.keys)
          for (final String key in indexKeys(name))
            if (indexKeys(key).first != key) key,
      ];
      expect(offenders, isEmpty, reason: 'reindexing changed the key: ${offenders.take(5)}');
    });
  });

  group('SpeciesIndex', () {
    final index = SpeciesIndex(kSpeciesCorpus);

    test('lookup resolves every authored name in the 2,400-name corpus', () {
      // Completeness. No name may fold to a key the query side cannot
      // reproduce — the failure this whole epic exists to prevent, at scale.
      final missed = <String>[
        for (final MapEntry<String, String> e in kSpeciesCorpus.entries)
          if (index.lookup(e.key) != e.value) e.key,
      ];
      expect(missed, isEmpty, reason: 'unreachable names: ${missed.take(5)}');
    });

    test('maps no key onto two species ids in the 2,400-name corpus', () {
      // The over-merge guard at scale, over a corpus built from distinct stems.
      expect(index.collidingKeys, isEmpty);
    });
  });
}
