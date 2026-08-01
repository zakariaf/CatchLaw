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

// ---------------------------------------------------------------------------
// E04/T02 — A1 row validation.
//
// Every builder below opens its single row on **line 4**, and the preamble is
// part of the fixture rather than decoration: a failure prints
// `A1 <file>:<line> <message>`, the line is asserted, and an off-by-one sends
// the author to a row that is fine.
// ---------------------------------------------------------------------------

/// The line every fixture row below opens on.
const int kFixtureRowLine = 4;

/// A `rules.yaml` document with one row carrying [fields], indented four spaces.
String ruleYaml(String fields) =>
    '''
# rules.yaml — one row, opening on line 4.
rules:
  # Venerupis corrugata — Rías Baixas
  - id: es-ga-r-001
    jurisdiction_id: ES-GA
    species_id: venerupis-corrugata
    citation_id: es-ga-orde-2012-07-27-anexo-ii
    valid_from: '2012-08-01'
$fields
''';

/// A `zones.yaml` document with one row carrying [fields].
///
/// The `name_key` carries the gate's own escape hatch. `check_content_pipeline.sh`
/// check 1 scans `*.dart` as well as `*.yaml` for a `*_key:` reference with no
/// matching `content_string` definition, and it finds this one inside a Dart
/// string. The hatch is the documented one — a trailing `content-pipeline-ok`,
/// written as a YAML comment so the document still parses — and it is used here
/// because a fixture is not shipped content. An ARB value or a real
/// `content/**.yaml` row is never exempt.
String zoneYaml(String fields) =>
    '''
# zones.yaml — one row, opening on line 4.
zones:
  # The Rías Baixas
  - id: es-ga-rias-baixas
    jurisdiction_id: ES-GA
    code: rias-baixas
    name_key: zone.es_ga.rias_baixas  # content-pipeline-ok
$fields
''';

/// A `species.yaml` document with one row carrying [fields].
String speciesYaml(String fields) =>
    '''
# species.yaml — one row, opening on line 4.
species:
  # Ameixa babosa
  - id: venerupis-corrugata
    scientific_name: Venerupis corrugata
    family_id: veneridae
    silhouette_asset: sil/venerupis-corrugata.svg
$fields
''';

/// A `closed_seasons.yaml` document with one row carrying [fields].
String closedSeasonYaml(String fields) =>
    '''
# closed_seasons.yaml — one row, opening on line 4.
closed_seasons:
  # The spring closure
  - id: es-ga-cs-001
    rule_id: es-ga-r-001
$fields
''';

/// A `vernacular.yaml` document with one row carrying [fields].
String speciesNameYaml(String fields) =>
    '''
# vernacular.yaml — one row, opening on line 4.
species_names:
  # Ameixa babosa
  - id: venerupis-corrugata-gl
    species_id: venerupis-corrugata
    name: Ameixa babosa
$fields
''';

/// A size with no method: the headline `SPEC.md` §8 bullet-1 case.
final String kMinSizeWithoutMethodYaml = ruleYaml('    min_size_mm: 380');

/// A slot rule's upper bound needs a method as much as its lower one does.
final String kMaxSizeWithoutMethodYaml = ruleYaml('    max_size_mm: 1200');

/// The passing case. An assertion with no green path fails everything.
final String kMinSizeWithMethodYaml = ruleYaml(
  '    min_size_mm: 380\n    measurement_method_id: SHL',
);

/// The one `SPEC.md` §7.1 `CHECK` that is an inequality rather than a set.
final String kMaxBelowMinYaml = ruleYaml(
  '    min_size_mm: 500\n    max_size_mm: 450\n    measurement_method_id: TL',
);

/// A protected species admits no threshold; the ladder headlines `protected`
/// and the size would never be read.
final String kProtectedWithSizeYaml = ruleYaml(
  '    is_protected: true\n    min_size_mm: 450\n    measurement_method_id: TL',
);

/// A rule whose `water_type` is [value].
String kRuleWithWaterType(String value) => ruleYaml('    water_type: $value');

/// A rule whose `measurement_method_id` is [code].
String kRuleWithMeasurementCode(String code) =>
    ruleYaml('    min_size_mm: 380\n    measurement_method_id: $code');

/// A zone whose `zone_kind` is [value].
String kZoneWithZoneKind(String value) => zoneYaml('    water_type: salt\n    zone_kind: $value');

/// A species whose `taxon_group` is [value].
String kSpeciesWithTaxonGroup(String value) => speciesYaml('    taxon_group: $value');

/// A vernacular name whose `gender` is [value].
String kSpeciesNameWithGender(String value) =>
    speciesNameYaml('    locale: gl\n    gender: $value');

/// "5" per what — count or kg?
final String kBagLimitWithoutUnitYaml = ruleYaml('    bag_limit: 5');

/// Per day, per trip and per season are three different limits.
final String kBagLimitWithoutPeriodYaml = ruleYaml('    bag_limit: 5\n    bag_limit_unit: count');

/// A closure with no window applies for zero days or for ever.
final String kAnnualSeasonWithoutBoundsYaml = closedSeasonYaml('    recurrence: annual');

/// A boundary that exists in one year of four shifts silently in the other
/// three.
final String kSeasonOnLeapDayYaml = closedSeasonYaml(
  '    recurrence: annual\n    start_month: 2\n    start_day: 29\n'
  '    end_month: 3\n    end_day: 31',
);

/// A November-to-February closure with the wrap left to be inferred.
final String kWrappingSeasonYaml = closedSeasonYaml(
  '    recurrence: annual\n    start_month: 11\n    start_day: 1\n'
  '    end_month: 2\n    end_day: 28',
);

/// The same closure, declared. The declared form must be shippable.
final String kWrappingSeasonDeclaredYaml = closedSeasonYaml(
  '    recurrence: annual\n    start_month: 11\n    start_day: 1\n'
  '    end_month: 2\n    end_day: 28\n    wraps_year: true',
);

/// A dead validity window: the engine would resolve nothing for this lineage.
final String kDeadValidityWindowYaml = ruleYaml("    valid_to: '2011-05-01'");

/// A rule carrying [minSizeMm], optionally cleared with `min_size_mm_confirmed`.
String kRuleWithMinSize(int minSizeMm, {bool confirmed = false}) => ruleYaml(
  '    min_size_mm: $minSizeMm\n    measurement_method_id: TL'
  '${confirmed ? '\n    min_size_mm_confirmed: true' : ''}',
);

/// `species.yaml` declaring `venerupis-corrugata` in [taxonGroup].
String kSpeciesInGroup(String taxonGroup) => speciesYaml('    taxon_group: $taxonGroup');

/// Two broken rows in one file, opening on lines 4 and 11.
const String kTwoBrokenRuleRowsYaml = '''
# rules.yaml — two broken rows.
rules:
  # no method
  - id: es-ga-r-001
    jurisdiction_id: ES-GA
    species_id: venerupis-corrugata
    citation_id: es-ga-orde-2012-07-27-anexo-ii
    valid_from: '2012-08-01'
    min_size_mm: 380
  # water_type outside the §7.1 set
  - id: es-ga-r-002
    jurisdiction_id: ES-GA
    species_id: maja-brachydactyla
    citation_id: es-ga-orde-2012-07-27-anexo-ii
    valid_from: '2012-08-01'
    water_type: marine
''';

/// A `citations.yaml` document — a section A1 has no closed set for.
const String kCitationYaml = '''
# citations.yaml — one row, opening on line 4.
citations:
  # Orde da Xunta de Galicia, 27/07/2012
  - id: es-ga-orde-2012-07-27-anexo-ii
    jurisdiction_id: ES-GA
    instrument_ref: Orde 27/07/2012
    article_ref: Anexo II
''';

/// A fixed closure with neither absolute date.
final String kFixedSeasonWithoutDatesYaml = closedSeasonYaml('    recurrence: fixed');

/// A fixed closure that ends before it starts.
final String kInvertedFixedSeasonYaml = closedSeasonYaml(
  "    recurrence: fixed\n    start_date: '2026-04-30'\n    end_date: '2026-03-01'",
);

/// The passing fixed closure. A fixed window carries both years explicitly, so
/// December to February needs no wrap declaration at all.
final String kFixedSeasonYaml = closedSeasonYaml(
  "    recurrence: fixed\n    start_date: '2026-12-01'\n    end_date: '2027-02-28'",
);

/// A closure that does not say which kind it is.
final String kSeasonWithoutRecurrenceYaml = closedSeasonYaml(
  '    start_month: 3\n    start_day: 1',
);

/// The leap day as the CLOSING bound rather than the opening one.
final String kSeasonEndingOnLeapDayYaml = closedSeasonYaml(
  '    recurrence: annual\n    start_month: 2\n    start_day: 1\n'
  '    end_month: 2\n    end_day: 29',
);

/// A closure claiming a recurrence `SPEC.md` §7.1 does not declare.
final String kSeasonWithUnknownRecurrenceYaml = closedSeasonYaml('    recurrence: monthly');

/// A February closure bounded on the 28th — legal, and the near miss the
/// leap-day check must not fire on.
final String kFebruaryClosureYaml = closedSeasonYaml(
  '    recurrence: annual\n    start_month: 2\n    start_day: 1\n'
  '    end_month: 2\n    end_day: 28',
);
