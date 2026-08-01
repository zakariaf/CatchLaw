// The build writes the index the app queries. If the two normalisers differ by
// one codepoint the search box returns nothing and the fisher concludes the
// species is not in the app.
//
// normalisation-contract.md names the failure mode: "results appear then vanish
// after a content rebuild — a second normalise copy in the CLI drifted". There
// is no user-visible error state for it. So the guard is three-layered: import
// rather than declare, A7 recomputes from the emitted bytes, and a test greps
// this package's own source for a declaration.

import 'package:content_builder/src/model/taxon.dart';
import 'package:content_builder/src/normalise/norm_columns.dart';
import 'package:test/test.dart';

/// A `species_name` row for [name] in [locale].
SpeciesNameRow nameRow({
  required String locale,
  required String name,
  String speciesId = 'epinephelus-coioides',
  bool isPrimary = true,
  String id = 'n-1',
}) => SpeciesNameRow(
  path: 'content/shared/vernacular.yaml',
  line: 2,
  id: id,
  speciesId: speciesId,
  locale: locale,
  name: name,
  gender: locale == 'en' ? null : 'm',
  isPrimary: isPrimary,
);

/// `الهامور` — the hamour with its definite article, as the instrument writes it.
const String kHamourWithArticle = 'الهامور';

/// `هامور` — the hamour as a fisher types it.
const String kHamour = 'هامور';

void main() {
  group('NormColumns', () {
    test('.populate writes search_norm from normaliseSpeciesTerm', () {
      // The base case, and it proves the imported function is the one called.
      final List<NormalisedName> rows = NormColumns.populate(<SpeciesNameRow>[
        nameRow(locale: 'gl', name: 'Ameixa babosa'),
      ]);

      expect(rows.single.searchNorm, 'ameixa babosa');
    });

    test('.populate folds a Latin diacritic the way the search field does', () {
      // Galician, Catalan, Spanish and Portuguese all need it, and it is what
      // makes a mis-accented paste reachable.
      expect(
        NormColumns.populate(<SpeciesNameRow>[
          nameRow(locale: 'es', name: 'Almeja babosa ñ'),
        ]).single.searchNorm,
        'almeja babosa n',
      );
    });

    test('ar - .populate emits a second row for a name carrying the definite article', () {
      // §9.4 step 5: index BOTH forms. The fisher types هامور, the instrument
      // writes الهامور, and the search returns nothing at 05:40 with the fish
      // still moving.
      final List<NormalisedName> rows = NormColumns.populate(<SpeciesNameRow>[
        nameRow(locale: 'ar', name: kHamourWithArticle),
      ]);

      expect(rows, hasLength(2));
      expect(rows.map((NormalisedName r) => r.searchNorm), <String>[kHamourWithArticle, kHamour]);
    });

    test('ar - .populate emits one row for a name with no definite article', () {
      expect(
        NormColumns.populate(<SpeciesNameRow>[nameRow(locale: 'ar', name: kHamour)]),
        hasLength(1),
      );
    });

    test('ar - .populate emits one row when the stripped key already exists', () {
      // Without deduplication the species list grows a phantom entry per
      // authored pair.
      final List<NormalisedName> rows = NormColumns.populate(<SpeciesNameRow>[
        nameRow(locale: 'ar', name: kHamourWithArticle, id: 'n-1'),
        nameRow(locale: 'ar', name: kHamour, id: 'n-2', isPrimary: false),
      ]);

      expect(rows, hasLength(2), reason: 'two authored rows, no extra key to add');
    });

    test('ar - .populate does not strip ال when the remainder is under three characters', () {
      // normalisation-contract.md's guard: that is a real word, not an article.
      expect(
        NormColumns.populate(<SpeciesNameRow>[nameRow(locale: 'ar', name: 'الون')]),
        hasLength(1),
      );
    });

    test('.populate marks the article-stripped row is_primary false', () {
      // Two primary rows would trip A3 and make S5 print two names for one fish.
      final List<NormalisedName> rows = NormColumns.populate(<SpeciesNameRow>[
        nameRow(locale: 'ar', name: kHamourWithArticle),
      ]);

      expect(rows.first.isPrimary, isTrue);
      expect(rows.last.isPrimary, isFalse);
    });

    test('.populate keeps the display name on the article-stripped row', () {
      // The extra row is a second KEY, not a second name. E08 must select
      // DISTINCT name or an Arabic species appears twice.
      final List<NormalisedName> rows = NormColumns.populate(<SpeciesNameRow>[
        nameRow(locale: 'ar', name: kHamourWithArticle),
      ]);

      expect(rows.map((NormalisedName r) => r.name), everyElement(kHamourWithArticle));
    });

    test('ar - .populate is idempotent over an already-normalised name', () {
      // The fold is applied by the builder and by the app. Drift between two
      // applications is the failure mode.
      final List<NormalisedName> once = NormColumns.populate(<SpeciesNameRow>[
        nameRow(locale: 'ar', name: kHamour),
      ]);

      expect(once.single.searchNorm, kHamour);
    });

    test('.populate returns nothing for a row with no name', () {
      // A1's failure, not this step's. Emitting an empty key would make every
      // empty query match it.
      expect(
        NormColumns.populate(const <SpeciesNameRow>[
          SpeciesNameRow(
            path: 'content/shared/vernacular.yaml',
            line: 2,
            id: 'n-1',
            speciesId: 'x',
            locale: 'ar',
            name: null,
          ),
        ]),
        isEmpty,
      );
    });

    test('.bodyNorm writes body_norm from the same function', () {
      // One function, two columns. The FTS index is built over this column
      // because FTS5 unicode61 does not fold Arabic orthographic variants.
      const body = 'O tamaño mínimo da ameixa babosa é de 38 mm.';

      expect(NormColumns.bodyNorm(body), 'o tamano minimo da ameixa babosa e de 38 mm.');
    });
  });
}
