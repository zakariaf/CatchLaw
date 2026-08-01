import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `family`.
@DataClassName('FamilyRow')
class Families extends Table {
  @override
  String get tableName => 'family';

  IntColumn get id => integer()();

  /// `Lethrinidae`. Not translated; the localised name is [nameKey].
  TextColumn get scientific => text().unique()();

  TextColumn get nameKey => text().named('name_key')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// `SPEC.md` §7.1 `species`.
@TableIndex(name: 'idx_species_family', columns: <Symbol>{#familyId})
@DataClassName('SpeciesRow')
class SpeciesTable extends Table {
  @override
  String get tableName => 'species';

  IntColumn get id => integer()();

  TextColumn get scientificName => text().named('scientific_name').unique()();

  /// Catalogue of Life taxon id, attributed CC BY 4.0 in S17.
  TextColumn get colId => text().named('col_id').nullable()();

  IntColumn get familyId =>
      integer().named('family_id').customConstraint('NOT NULL REFERENCES family(id)')();

  /// §7.1 splits molluscs into `bivalve`, `gastropod` and `cephalopod`.
  /// Collapsing them loses S7's entry point.
  TextColumn get taxonGroup => text()
      .named('taxon_group')
      .customConstraint(
        "NOT NULL CHECK (taxon_group IN ('finfish','crustacean','bivalve', "
        "'gastropod','cephalopod','echinoderm','elasmobranch','other'))",
      )();

  /// Originated SVG line art. Required: a verdict with no picture is usable, a
  /// picture with no verdict is not.
  TextColumn get silhouetteAsset => text().named('silhouette_asset')();

  /// Optional, cleared per §8's illustrator death-year test.
  TextColumn get plateAsset => text().named('plate_asset').nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// `SPEC.md` §7.1 `species_name` — one vernacular name in one locale.
///
/// An Arabic name carrying `ال` produces **two** rows with the same display
/// `name`: §9.4 step 5 requires both the stripped and unstripped forms to be
/// indexed and §7.1 gives one `search_norm` column. A name list must therefore
/// select `DISTINCT name` or filter on `is_primary`.
/// `idx_name_search` is what makes §13's "< 50 ms at 2,400 names" possible. A
/// missing index is a slow app rather than a broken one, so nothing else catches
/// it.
@TableIndex(name: 'idx_name_search', columns: <Symbol>{#searchNorm})
@TableIndex(name: 'idx_name_species', columns: <Symbol>{#speciesId, #locale})
@DataClassName('SpeciesNameRow')
class SpeciesNames extends Table {
  @override
  String get tableName => 'species_name';

  IntColumn get id => integer()();

  IntColumn get speciesId => integer()
      .named('species_id')
      .customConstraint('NOT NULL REFERENCES species(id) ON DELETE CASCADE')();

  /// One of D-3's six: `ar`, `ca`, `en`, `es`, `gl`, `pt_BR`.
  TextColumn get locale => text()();

  TextColumn get name => text()();

  /// Computed by the build from the engine's own `normaliseSpeciesTerm`, never
  /// authored: a second normaliser means the index and the query disagree and
  /// Arabic search silently returns nothing.
  TextColumn get searchNorm => text().named('search_norm')();

  /// `m`, `f` or `n`. Required in every locale but `en` — "la mero" destroys the
  /// printed-document register the verdict is believed through.
  TextColumn get gender => text().nullable().customConstraint("CHECK (gender IN ('m','f','n'))")();

  /// The one name S2 prints. Exactly one per (species, locale).
  BoolColumn get isPrimary =>
      boolean().named('is_primary').withDefault(const Constant<bool>(false))();

  /// `RAK`, `Rías Baixas` — where this name is the one people use.
  TextColumn get regionHint => text().named('region_hint').nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// `SPEC.md` §7.1 `lookalike`.
@DataClassName('LookalikeRow')
class Lookalikes extends Table {
  @override
  String get tableName => 'lookalike';

  IntColumn get id => integer()();

  IntColumn get speciesId => integer()
      .named('species_id')
      .customConstraint('NOT NULL REFERENCES species(id) ON DELETE CASCADE')();

  IntColumn get confusedWith =>
      integer().named('confused_with').customConstraint('NOT NULL REFERENCES species(id)')();

  TextColumn get differenceKey => text().named('difference_key')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>['UNIQUE (species_id, confused_with)'];
}
