/// Inline authoring YAML for the build tool's tests.
///
/// These are `String` constants and not `test/fixtures/*.yaml` files on purpose.
/// `check_content_pipeline.sh` checks 2, 3 and 5 are `awk` window scans over
/// every `*.yaml` under the target directory and — unlike checks 1, 4, 6 and 7 —
/// they do **not** honour the `content-pipeline-ok` escape hatch. Every
/// assertion task needs a deliberately broken row, and a broken row in a `.yaml`
/// file would fail the very gate it exists to prove, with no way to exempt it.
/// A `String` in Dart is invisible to a `*.yaml` scan and keeps the fixture
/// beside the test that explains it.
///
/// Line numbers are load-bearing. Every failure the build prints is
/// `<id> <file>:<line> <message>`, so a fixture's row positions are asserted
/// directly and a stray blank line here breaks a test rather than a build.
library;

/// Three rule rows, opening at lines 2, 5 and 8.
///
/// Field names mirror the `SPEC.md` §7.1 SQL columns rather than the tidier
/// spellings in `build-assertions.md`: the loader's models are the schema, and a
/// renamed column costs the next reader a diff.
const String kThreeRuleRowsYaml = '''
rules:
  - id: es-ga-r-001
    species_id: venerupis-corrugata
    zone_id: es-ga-rias-baixas
  - id: es-ga-r-002
    species_id: maja-brachydactyla
    zone_id: es-ga-rias-baixas
  - id: es-ga-r-003
    species_id: necora-puber
    zone_id: es-ga-rias-baixas
''';

/// A document whose top-level section is misspelt: `speceis` for `species`.
///
/// The defect this catches is not the typo but its consequence — a section
/// nobody recognises loads as "no rows", and a whole file goes missing without
/// a single failure line.
const String kUnknownSectionYaml = '''
speceis:
  - id: venerupis-corrugata
    scientific_name: Venerupis corrugata
''';

/// Two rows sharing `id: es-ga-r-001`, at lines 2 and 5.
///
/// A duplicate id makes the T09 changelog diff and the T08 resolution grid
/// disagree about which row is which, and neither of them says so.
const String kDuplicateRowIdYaml = '''
rules:
  - id: es-ga-r-001
    species_id: venerupis-corrugata
    zone_id: es-ga-rias-baixas
  - id: es-ga-r-001
    species_id: maja-brachydactyla
    zone_id: es-ga-rias-baixas
''';

/// YAML that does not parse: a second `:` inside a plain scalar, on line 3.
///
/// An unterminated flow sequence would have done as well but reports at
/// end-of-file, which is the one line the author did not write. The failure has
/// to name line 3, and it must be a failure line rather than a `YamlException`
/// stack trace naming the loader.
const String kMalformedYaml = '''
rules:
  - id: es-ga-r-001
    zone_id: es-ga: rias-baixas
''';

/// A section holding a scalar where a list of rows belongs.
const String kSectionIsNotAListYaml = '''
rules: es-ga-r-001
''';

/// A row that is a scalar rather than a mapping.
const String kRowIsNotAMappingYaml = '''
rules:
  - es-ga-r-001
''';

/// A row carrying no `id`.
const String kRowWithoutIdYaml = '''
rules:
  - species_id: venerupis-corrugata
    zone_id: es-ga-rias-baixas
''';

/// `content/shared/species.yaml` for the two-directory load fixture.
const String kSharedSpeciesYaml = '''
species:
  - id: venerupis-corrugata
    scientific_name: Venerupis corrugata
    family_id: veneridae
    taxon_group: bivalve
    silhouette_asset: sil/venerupis-corrugata.svg
''';

/// `content/es-ga/rules.yaml` for the two-directory load fixture.
const String kGaliciaRulesYaml = '''
rules:
  - id: es-ga-r-001
    species_id: venerupis-corrugata
    zone_id: es-ga-rias-baixas
    water_type: salt
    min_size_mm: 38
    measurement_method_id: SHL
    citation_id: es-ga-orde-2012-07-27-anexo-ii
    valid_from: '2012-08-01'
''';

/// `content/es-ga/jurisdiction.yaml` for the two-directory load fixture.
const String kGaliciaJurisdictionYaml = '''
jurisdiction:
  - id: ES-GA
    code: ES-GA
    country_iso2: ES
    default_locale: gl
    legal_text_locales: gl,es
    content_version: '2026.08.0'
    published_on: '2012-07-27'
    checked_on: '2026-07-14'
''';
