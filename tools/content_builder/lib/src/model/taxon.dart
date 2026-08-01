import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/content_row.dart';

/// A `family` row.
class FamilyRow extends ContentRow {
  /// A family read from [path] at [line].
  const FamilyRow({
    required super.path,
    required super.line,
    required super.id,
    required this.scientific,
    required this.nameKey,
  });

  /// Reads a family from [row].
  factory FamilyRow.fromRow(YamlRow row) => FamilyRow(
    path: row.path,
    line: row.line,
    id: row.id,
    scientific: row.string('scientific'),
    nameKey: row.string('name_key'),
  );

  /// `Lethrinidae`.
  final String? scientific;

  /// Localised family name.
  final String? nameKey;

  @override
  Map<String, String?> get keyColumns => <String, String?>{'name_key': nameKey};
}

/// A `species` row.
class SpeciesRow extends ContentRow {
  /// A species read from [path] at [line].
  const SpeciesRow({
    required super.path,
    required super.line,
    required super.id,
    required this.scientificName,
    required this.familyId,
    required this.taxonGroup,
    required this.silhouetteAsset,
    this.colId,
    this.plateAsset,
    this.noVernacular = const <String, String>{},
  });

  /// Reads a species from [row].
  factory SpeciesRow.fromRow(YamlRow row) => SpeciesRow(
    path: row.path,
    line: row.line,
    id: row.id,
    scientificName: row.string('scientific_name'),
    colId: row.string('col_id'),
    familyId: row.string('family_id'),
    taxonGroup: row.string('taxon_group'),
    silhouetteAsset: row.string('silhouette_asset'),
    plateAsset: row.string('plate_asset'),
    noVernacular: <String, String>{
      for (final MapEntry<String, Object?> e
          in (row.map('no_vernacular') ?? const <String, Object?>{}).entries)
        if (e.value is String) e.key: e.value! as String,
    },
  );

  /// The binomial, e.g. `Venerupis corrugata`.
  final String? scientificName;

  /// Catalogue of Life taxon id, attributed CC BY 4.0 in S17.
  final String? colId;

  /// The family this species belongs to.
  final String? familyId;

  /// One of the eight `SPEC.md` §7.1 groups. It scopes A1's millimetre range
  /// check and is the identification key's entry point.
  final String? taxonGroup;

  /// Originated SVG line art. Required: A5 fails a rule whose species has none.
  final String? silhouetteAsset;

  /// Optional detailed plate, cleared per A6's illustrator death-year test.
  final String? plateAsset;

  /// Locales in which this species deliberately has **no** vernacular name, and
  /// the `*_key` explaining why.
  ///
  /// `SPEC.md` §8 bullet 5 read literally requires an Arabic name for *Venerupis
  /// corrugata*, and no Galician instrument names a clam in Arabic. §9.2 step 3
  /// is explicit that a wrong vernacular name is worse than no name, because it
  /// produces a confident wrong finding. A declared absence is reviewable,
  /// greppable, appears in the changelog diff when it changes, and lets §9.2's
  /// fallback chain run down to the scientific name — which is where the chain
  /// already ends. A SILENT gap still fails A5.
  final Map<String, String> noVernacular;

  @override
  Map<String, String?> get keyColumns => <String, String?>{
    // The reason key is itself a content string, so A2 forces its six
    // translations. An untranslated reason would be a blank line explaining a
    // blank line.
    for (final MapEntry<String, String> e in noVernacular.entries)
      'no_vernacular.${e.key}': e.value,
  };
}

/// A `species_name` row: one vernacular name in one locale.
///
/// `search_norm` is not authored. E04/T07 computes it with the engine's own
/// `normaliseSpeciesTerm`, because a second normaliser means the index and the
/// query disagree and Arabic search silently returns nothing at all.
class SpeciesNameRow extends ContentRow {
  /// A name read from [path] at [line].
  const SpeciesNameRow({
    required super.path,
    required super.line,
    required super.id,
    required this.speciesId,
    required this.locale,
    required this.name,
    this.gender,
    this.isPrimary = false,
    this.regionHint,
  });

  /// Reads a name from [row].
  factory SpeciesNameRow.fromRow(YamlRow row) => SpeciesNameRow(
    path: row.path,
    line: row.line,
    id: row.id,
    speciesId: row.string('species_id'),
    locale: row.string('locale'),
    name: row.string('name'),
    gender: row.string('gender'),
    isPrimary: row.boolean('is_primary') ?? false,
    regionHint: row.string('region_hint'),
  );

  /// The species this name belongs to.
  final String? speciesId;

  /// One of D-3's six: `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`.
  final String? locale;

  /// The name as the instrument writes it.
  final String? name;

  /// `m`, `f` or `n`. A3 requires it in every locale but `en`: "la mero"
  /// destroys the printed-document register the verdict is believed through.
  final String? gender;

  /// The one name S2 prints. Exactly one per (species, locale).
  final bool isPrimary;

  /// `RAK`, `Rías Baixas` — where this name is the one people use.
  final String? regionHint;

  @override
  Map<String, String?> get keyColumns => const <String, String?>{};
}

/// A `lookalike` row: a species this one is confused with, and how to tell them
/// apart.
class LookalikeRow extends ContentRow {
  /// A lookalike read from [path] at [line].
  const LookalikeRow({
    required super.path,
    required super.line,
    required super.id,
    required this.speciesId,
    required this.confusedWith,
    required this.differenceKey,
  });

  /// Reads a lookalike from [row].
  factory LookalikeRow.fromRow(YamlRow row) => LookalikeRow(
    path: row.path,
    line: row.line,
    id: row.id,
    speciesId: row.string('species_id'),
    confusedWith: row.string('confused_with'),
    differenceKey: row.string('difference_key'),
  );

  /// The species being looked at.
  final String? speciesId;

  /// The species it is mistaken for.
  final String? confusedWith;

  /// The localised distinguishing feature.
  final String? differenceKey;

  @override
  Map<String, String?> get keyColumns => <String, String?>{'difference_key': differenceKey};
}
