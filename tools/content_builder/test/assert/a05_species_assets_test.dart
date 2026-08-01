// A5 — every rule's species has a silhouette on disk and a name in every
// locale, or a declared reason for having none.
//
// SPEC.md §8 bullet 5 read literally requires an Arabic name for Venerupis
// corrugata. No Galician instrument names a clam in Arabic, and §9.2 step 3 is
// explicit that a wrong vernacular name is worse than no name because it
// produces a confident wrong finding. So a species may declare, per locale, a
// `no_vernacular:` reason key — reviewable, greppable, and translated into all
// six locales by A2. A SILENT gap still fails.
//
// This is the one place E04 does not implement a §8 bullet to the letter. It is
// recorded in the epic's Risks, and what would resolve it is a §8 amendment.

import 'dart:io';

import 'package:content_builder/src/assert/a05_species_assets.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/locales.dart';
import 'package:test/test.dart';

import '../../testing/fixtures/yaml_fixtures.dart';

const String kSpeciesPath = 'content/shared/species.yaml';
const String kVernacularPath = 'content/shared/vernacular.yaml';
const String kSilhouette = 'sil/venerupis-corrugata.svg';

/// An assets tree holding [files], each written as an empty placeholder.
Directory assetsWith(List<String> files) {
  final Directory root = Directory.systemTemp.createTempSync('content_builder_assets_');
  for (final relative in files) {
    final file = File('${root.path}/$relative');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('<svg/>');
  }
  return root;
}

List<Failure> a5(Map<String, String> files, {required Directory assets}) =>
    const SpeciesAssetAssertion()
        .run(
          ContentSource(
            sources: <YamlSource>[
              for (final MapEntry<String, String> e in files.entries)
                YamlSource.fromString(e.value, displayPath: e.key),
            ],
            failures: const <Failure>[],
            assetsRoot: assets,
          ),
        )
        .toList();

/// Names for `venerupis-corrugata` in every shipped locale but [without].
List<NameSpec> namesExcept(String? without) => <NameSpec>[
  for (final String locale in kShippedLocales)
    if (locale != without) name(locale, gender: locale == 'en' ? null : 'f'),
];

void main() {
  group('SpeciesAssetAssertion', () {
    test("reports A5 when a rule's species has no silhouette file", () {
      // The recorded cause: a shellfish added late, art not commissioned. The
      // column is NOT NULL in §7.1, so the failure that actually happens is a
      // path pointing at a file nobody drew.
      final Directory assets = assetsWith(const <String>[]);
      addTearDown(() => assets.deleteSync(recursive: true));

      final List<Failure> failures = a5(<String, String>{
        kSpeciesPath: speciesWithAssets(),
        kVernacularPath: vernacularYaml(namesExcept(null)),
        'content/es-ga/rules.yaml': ruleCiting(),
      }, assets: assets);

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A5');
      expect(failures.single.message, contains('venerupis-corrugata'));
      expect(failures.single.message, contains('silhouette'));
    });

    test('accepts a species whose silhouette file exists', () {
      final Directory assets = assetsWith(const <String>[kSilhouette]);
      addTearDown(() => assets.deleteSync(recursive: true));

      expect(
        a5(<String, String>{
          kSpeciesPath: speciesWithAssets(),
          kVernacularPath: vernacularYaml(namesExcept(null)),
          'content/es-ga/rules.yaml': ruleCiting(),
        }, assets: assets),
        isEmpty,
      );
    });

    for (final String locale in kShippedLocales) {
      test("reports A5 when a rule's species has no name for $locale", () {
        // Six locales, six chances. pt_BR is the one that gets forgotten.
        final Directory assets = assetsWith(const <String>[kSilhouette]);
        addTearDown(() => assets.deleteSync(recursive: true));

        final List<Failure> failures = a5(<String, String>{
          kSpeciesPath: speciesWithAssets(),
          kVernacularPath: vernacularYaml(namesExcept(locale)),
          'content/es-ga/rules.yaml': ruleCiting(),
        }, assets: assets);

        expect(failures, hasLength(1));
        expect(failures.single.message, contains(locale));
      });
    }

    test('accepts a declared no_vernacular for a locale', () {
      // A decided absence is coverage. It lets §9.2's fallback chain run down to
      // the scientific name, which is where the chain already ends.
      final Directory assets = assetsWith(const <String>[kSilhouette]);
      addTearDown(() => assets.deleteSync(recursive: true));

      expect(
        a5(<String, String>{
          kSpeciesPath: speciesWithAssets(
            noVernacular: const <String, String>{
              'ar': 'reason.no_arabic_name_for_galician_bivalve',
            },
          ),
          kVernacularPath: vernacularYaml(namesExcept('ar')),
          'content/es-ga/rules.yaml': ruleCiting(),
        }, assets: assets),
        isEmpty,
      );
    });

    test('reports A5 when no_vernacular carries no reason key', () {
      // An empty reason is a silent gap wearing the escape's clothes.
      final Directory assets = assetsWith(const <String>[kSilhouette]);
      addTearDown(() => assets.deleteSync(recursive: true));

      final List<Failure> failures = a5(<String, String>{
        kSpeciesPath: speciesWithAssets(noVernacular: const <String, String>{'ar': ''}),
        kVernacularPath: vernacularYaml(namesExcept('ar')),
        'content/es-ga/rules.yaml': ruleCiting(),
      }, assets: assets);

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('ar'));
    });

    test('ignores a species that no rule references', () {
      // §8 scopes the assertion to a RULE's species. The identification key
      // carries species with no rule of their own, and E22 authors them ahead
      // of the instruments that will regulate them.
      final Directory assets = assetsWith(const <String>[]);
      addTearDown(() => assets.deleteSync(recursive: true));

      expect(a5(<String, String>{kSpeciesPath: speciesWithAssets()}, assets: assets), isEmpty);
    });

    test('reports A5 when a rule names a species that does not exist', () {
      // A dangling species_id would otherwise pass every check here by having
      // nothing to check.
      final Directory assets = assetsWith(const <String>[kSilhouette]);
      addTearDown(() => assets.deleteSync(recursive: true));

      final List<Failure> failures = a5(<String, String>{
        kSpeciesPath: speciesWithAssets(),
        'content/es-ga/rules.yaml': ruleCiting(speciesId: 'lethrinus-ghost'),
      }, assets: assets);

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('lethrinus-ghost'));
      expect(failures.single.path, 'content/es-ga/rules.yaml');
    });

    test('reports every missing locale for one species in one failure', () {
      // An author who has authored no names at all needs one line naming six
      // locales, not six lines naming one species.
      final Directory assets = assetsWith(const <String>[kSilhouette]);
      addTearDown(() => assets.deleteSync(recursive: true));

      final List<Failure> failures = a5(<String, String>{
        kSpeciesPath: speciesWithAssets(),
        'content/es-ga/rules.yaml': ruleCiting(),
      }, assets: assets);

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('ar, ca, en, es, gl, pt_BR'));
    });

    test('reports A5 when silhouette_asset is blank', () {
      // §7.1 makes the column NOT NULL, so this is a schema error too — but a
      // blank string satisfies NOT NULL and points at nothing.
      final Directory assets = assetsWith(const <String>[kSilhouette]);
      addTearDown(() => assets.deleteSync(recursive: true));

      final List<Failure> failures = a5(<String, String>{
        kSpeciesPath: speciesWithAssets(silhouette: "''"),
        kVernacularPath: vernacularYaml(namesExcept(null)),
        'content/es-ga/rules.yaml': ruleCiting(),
      }, assets: assets);

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('has no silhouette'));
    });

    test('skips the disk check when there is no assets tree', () {
      // The corpus can be loaded outside a build — by a test, or by T09's diff.
      // A silhouette check with nowhere to look must not invent a failure.
      expect(
        const SpeciesAssetAssertion().run(
          ContentSource(
            sources: <YamlSource>[
              YamlSource.fromString(speciesWithAssets(), displayPath: kSpeciesPath),
              YamlSource.fromString(
                vernacularYaml(namesExcept(null)),
                displayPath: kVernacularPath,
              ),
              YamlSource.fromString(ruleCiting(), displayPath: 'content/es-ga/rules.yaml'),
            ],
            failures: const <Failure>[],
          ),
        ),
        isEmpty,
      );
    });

    test('checks a species once however many rules reference it', () {
      // Galicia carries a size rule and a closed season for the same clam. Two
      // failures for one missing silhouette is two lines to fix one thing.
      final Directory assets = assetsWith(const <String>[]);
      addTearDown(() => assets.deleteSync(recursive: true));

      final List<Failure> failures = a5(<String, String>{
        kSpeciesPath: speciesWithAssets(),
        kVernacularPath: vernacularYaml(namesExcept(null)),
        'content/es-ga/rules.yaml': kTwoRulesOneSpeciesYaml,
      }, assets: assets);

      expect(failures, hasLength(1));
    });

    test('ignores a rule that names no species', () {
      // A required column missing is A1's failure, at A1's message.
      final Directory assets = assetsWith(const <String>[]);
      addTearDown(() => assets.deleteSync(recursive: true));

      expect(
        a5(<String, String>{
          kSpeciesPath: speciesWithAssets(),
          'content/es-ga/rules.yaml': kRuleWithoutSpeciesYaml,
        }, assets: assets),
        isEmpty,
      );
    });

    test('.id is A5', () {
      expect(const SpeciesAssetAssertion().id, 'A5');
    });
  });
}
