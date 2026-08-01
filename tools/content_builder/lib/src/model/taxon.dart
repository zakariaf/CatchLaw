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

  @override
  Map<String, String?> get keyColumns => const <String, String?>{};
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

/// A `plates.yaml` row: the licence ledger behind `species.plate_asset`.
///
/// Not a `SPEC.md` §7.1 table. It is the evidence A6 tests and E18 renders, and
/// it stays out of the database because a licence claim belongs in the
/// attribution page, not in a column nobody reads.
class PlateRow extends ContentRow {
  /// A plate read from [path] at [line].
  const PlateRow({
    required super.path,
    required super.line,
    required super.id,
    required this.speciesId,
    required this.asset,
    this.illustrator,
    this.illustratorDeathYear,
    this.origin,
    this.sourceTitle,
    this.sourceYear,
  });

  /// Reads a plate from [row].
  factory PlateRow.fromRow(YamlRow row) => PlateRow(
    path: row.path,
    line: row.line,
    id: row.id,
    speciesId: row.string('species_id'),
    asset: row.string('asset'),
    illustrator: row.string('illustrator'),
    illustratorDeathYear: row.integer('illustrator_death_year'),
    origin: row.string('origin'),
    sourceTitle: row.string('source_title'),
    sourceYear: row.integer('source_year'),
  );

  /// The species the plate depicts.
  final String? speciesId;

  /// The bundled asset path.
  final String? asset;

  /// The artist. A6 drops a plate with no identified illustrator — not
  /// `licence: unknown`, not `review: later`, because "pending" is a state that
  /// ships.
  final String? illustrator;

  /// The year the artist died. The test counts from this, never from the
  /// publication date: "pre-1930 is public domain" is the US rule and clears
  /// nothing in Spain, Brazil or the UAE.
  final int? illustratorDeathYear;

  /// `originated` for art commissioned for this app, which needs no term test
  /// but still needs a ledger row.
  final String? origin;

  /// The work the plate was scanned from.
  final String? sourceTitle;

  /// The year that work was published — evidence about the artist, never the
  /// test itself.
  final int? sourceYear;

  @override
  Map<String, String?> get keyColumns => const <String, String?>{};
}
