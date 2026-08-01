import 'dart:io';

import 'package:content_builder/src/assert/assertion.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/locales.dart';
import 'package:content_builder/src/model/taxon.dart';
import 'package:path/path.dart' as p;

/// A5 — every rule's species has a silhouette on disk and a name in every
/// locale, or a declared reason for having none.
///
/// **The one place E04 refines a `SPEC.md` §8 bullet.** Bullet 5 read literally
/// requires an Arabic name for *Venerupis corrugata*. No Galician instrument
/// names a clam in Arabic, the Catalogue of Life vernacular extension may not
/// either, and §9.2 step 3 says plainly that *a wrong vernacular name is worse
/// than no name, because it produces a confident wrong finding*. Inventing a
/// transliteration is also what `normalisation-contract.md` forbids —
/// normalisation folds orthography and never guesses transliteration.
///
/// So a species may declare, per locale, `no_vernacular: {ar: reason.…}`, whose
/// value is a `*_key` and is therefore translated into all six locales by A2.
/// A5 accepts that as coverage; a locale with **neither** a name nor a
/// declaration still fails. A silent gap and a decided absence must not look the
/// same in a diff.
///
/// **The silhouette is checked on disk.** §7.1 makes `silhouette_asset`
/// `NOT NULL`, so a missing value is already a schema error. The failure that
/// actually happens is a path pointing at a file nobody drew.
final class SpeciesAssetAssertion implements Assertion {
  /// The A5 assertion. Stateless: the corpus is the argument.
  const SpeciesAssetAssertion();

  @override
  String get id => 'A5';

  @override
  Iterable<Failure> run(ContentSource source) sync* {
    final species = <String, SpeciesRow>{
      for (final SpeciesRow s in source.typedRows.whereType<SpeciesRow>()) s.id: s,
    };

    final named = <String, Set<String>>{};
    for (final SpeciesNameRow row in source.typedRows.whereType<SpeciesNameRow>()) {
      (named[row.speciesId ?? ''] ??= <String>{}).add(row.locale ?? '');
    }

    // Scoped to a RULE's species: §8's own wording. The identification key
    // carries species with no rule of their own, and E22 authors them ahead of
    // the instruments that will regulate them.
    final seen = <String>{};
    for (final YamlRow rule in source.section('rules')) {
      final String? speciesId = rule.string('species_id');
      if (speciesId == null || !seen.add(speciesId)) continue;

      final SpeciesRow? row = species[speciesId];
      if (row == null) {
        // A dangling species_id would otherwise pass every check below by
        // having nothing to check.
        yield Failure(_id, rule.path, rule.line, "species '$speciesId' does not resolve");
        continue;
      }

      yield* _silhouette(row, source.assetsRoot);
      yield* _vernacular(row, named[speciesId] ?? const <String>{});
    }
  }

  Iterable<Failure> _silhouette(SpeciesRow row, Directory? assetsRoot) sync* {
    final String? asset = row.silhouetteAsset;
    if (asset == null || asset.trim().isEmpty) {
      yield Failure(_id, row.path, row.line, "'${row.id}' has no silhouette");
      return;
    }
    if (assetsRoot == null) return; // no assets tree to check against

    if (!File(p.join(assetsRoot.path, asset)).existsSync()) {
      // The recorded cause: a shellfish added late, art not commissioned.
      yield Failure(_id, row.path, row.line, "'${row.id}' has no silhouette file at $asset");
    }
  }

  Iterable<Failure> _vernacular(SpeciesRow row, Set<String> locales) sync* {
    final missing = <String>[];
    for (final String locale in kShippedLocales) {
      if (locales.contains(locale)) continue;

      final String? reason = row.noVernacular[locale];
      if (reason == null) {
        missing.add(locale);
      } else if (reason.trim().isEmpty) {
        // An empty reason is a silent gap wearing the escape's clothes.
        yield Failure(
          _id,
          row.path,
          row.line,
          "'${row.id}' declares no_vernacular for $locale with no reason key",
        );
      }
    }

    if (missing.isNotEmpty) {
      // One line naming six locales, not six lines naming one species.
      yield Failure(
        _id,
        row.path,
        row.line,
        "'${row.id}' has no vernacular name for ${missing.join(', ')} "
        'and no no_vernacular declaration',
      );
    }
  }

  static const String _id = 'A5';
}
