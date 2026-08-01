import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/content_row.dart';

/// A `measurement_method` row: `TL`, `FL`, `SL`, `CW`, `CL`, `ML`, `DW`, `SHL`
/// or `CUSTOM`.
class MeasurementMethodRow extends ContentRow {
  /// A method read from [path] at [line].
  const MeasurementMethodRow({
    required super.path,
    required super.line,
    required super.id,
    required this.code,
    required this.nameKey,
    required this.definitionKey,
    required this.diagramAsset,
  });

  /// Reads a method from [row].
  factory MeasurementMethodRow.fromRow(YamlRow row) => MeasurementMethodRow(
    path: row.path,
    line: row.line,
    id: row.id,
    code: row.string('code'),
    nameKey: row.string('name_key'),
    definitionKey: row.string('definition_key'),
    diagramAsset: row.string('diagram_asset'),
  );

  /// The SQL spelling. TL and FL differ by 6–9 cm on a *Scomberomorus
  /// commerson*, which is why a size never travels without one.
  final String? code;

  /// Localised method name.
  final String? nameKey;

  /// Localised definition: where on the fish the measurement starts and ends.
  final String? definitionKey;

  /// Originated SVG. It does not mirror in RTL — a fork-length arrow must point
  /// at the actual fork.
  final String? diagramAsset;

  @override
  Map<String, String?> get keyColumns => <String, String?>{
    'name_key': nameKey,
    'definition_key': definitionKey,
  };
}

/// A `citation` row: the instrument a finding quotes.
class CitationRow extends ContentRow {
  /// A citation read from [path] at [line].
  const CitationRow({
    required super.path,
    required super.line,
    required super.id,
    required this.jurisdictionId,
    required this.instrumentTypeKey,
    required this.instrumentRef,
    required this.publishedOn,
    required this.retrievedOn,
    this.articleRef,
    this.sourceUrl,
    this.sha256,
    this.lineageId,
  });

  /// Reads a citation from [row].
  factory CitationRow.fromRow(YamlRow row) => CitationRow(
    path: row.path,
    line: row.line,
    id: row.id,
    // `jurisdiction`, `instrument` and `article` rather than the §7.1 column
    // names: check_content_pipeline.sh check 2 is an awk window looking for
    // `instrument:|article:` beside `retrieved_on:`, and against `*_ref` names
    // it cannot fire at all. D-2's rule of thumb — the gate beats the prose
    // about a shape. The §7.1 names are still accepted, so a corpus authored
    // either way loads.
    jurisdictionId: row.string('jurisdiction') ?? row.string('jurisdiction_id'),
    instrumentTypeKey: row.string('instrument_type_key'),
    instrumentRef: row.string('instrument') ?? row.string('instrument_ref'),
    articleRef: row.string('article') ?? row.string('article_ref'),
    lineageId: row.string('lineage_id'),
    publishedOn: row.string('published_on'),
    sourceUrl: row.string('source_url'),
    retrievedOn: row.string('retrieved_on'),
    sha256: row.string('sha256'),
  );

  /// The authority that published it.
  final String? jurisdictionId;

  /// Localised label for the kind of instrument — decision, orde, portaria.
  final String? instrumentTypeKey;

  /// `MD 580/2015`, `Orde 27/07/2012`.
  final String? instrumentRef;

  /// `Art. 3`, `Anexo II`.
  final String? articleRef;

  /// When the authority published it.
  final String? publishedOn;

  /// The official gazette. Selectable text only, never launched; and never an
  /// NGO abstract, which is both copyrighted and paraphrased.
  final String? sourceUrl;

  /// When a human opened the gazette. A4 requires it, and it is authored:
  /// `DateTime.now()` records when a machine ran, which is not what the
  /// footnote claims.
  final String? retrievedOn;

  /// Digest of the fetched document, so the transcription can be re-checked
  /// against the same bytes.
  ///
  /// An **authoring** field, not a `SPEC.md` §7.1 column. §7.1 is authoritative
  /// for the schema, so the digest is asserted at build time and carried into
  /// the per-jurisdiction changelog rather than into the database — inventing a
  /// column would put this builder and E05's drift schema out of step.
  final String? sha256;

  /// The instrument lineage this article belongs to.
  ///
  /// The engine collapses candidates per `(zone_id, citation lineage)` and takes
  /// the greatest `valid_from`, so an amending order must carry the lineage of
  /// the order it amends or both will resolve at once.
  final String? lineageId;

  @override
  Map<String, String?> get keyColumns => <String, String?>{
    'instrument_type_key': instrumentTypeKey,
  };
}

/// A `rule` row.
class RuleRow extends ContentRow {
  /// A rule read from [path] at [line].
  const RuleRow({
    required super.path,
    required super.line,
    required super.id,
    required this.jurisdictionId,
    required this.speciesId,
    required this.waterType,
    required this.citationId,
    required this.validFrom,
    this.zoneId,
    this.minSizeMm,
    this.maxSizeMm,
    this.measurementMethodId,
    this.bagLimit,
    this.bagLimitUnit,
    this.bagLimitPeriod,
    this.vesselLimit,
    this.isProtected = false,
    this.licenceTypeId,
    this.notesKey,
    this.validTo,
    this.specificity = 0,
    this.minSizeMmConfirmed = false,
  });

  /// Reads a rule from [row].
  factory RuleRow.fromRow(YamlRow row) => RuleRow(
    path: row.path,
    line: row.line,
    id: row.id,
    jurisdictionId: row.string('jurisdiction_id'),
    zoneId: row.string('zone_id'),
    speciesId: row.string('species_id'),
    waterType: row.string('water_type'),
    minSizeMm: row.integer('min_size_mm'),
    maxSizeMm: row.integer('max_size_mm'),
    measurementMethodId: row.string('measurement_method_id'),
    bagLimit: row.integer('bag_limit'),
    bagLimitUnit: row.string('bag_limit_unit'),
    bagLimitPeriod: row.string('bag_limit_period'),
    vesselLimit: row.integer('vessel_limit'),
    isProtected: row.boolean('is_protected') ?? false,
    licenceTypeId: row.string('licence_type_id'),
    notesKey: row.string('notes_key'),
    citationId: row.string('citation_id'),
    validFrom: row.string('valid_from'),
    validTo: row.string('valid_to'),
    specificity: row.integer('specificity') ?? 0,
    minSizeMmConfirmed: row.boolean('min_size_mm_confirmed') ?? false,
  );

  /// The authority whose instrument this row transcribes.
  final String? jurisdictionId;

  /// `null` means the whole jurisdiction.
  final String? zoneId;

  /// The species the rule bites on.
  final String? speciesId;

  /// `salt`, `fresh` or `both`.
  final String? waterType;

  /// Millimetres, always. A `45` meant as centimetres is wrong by a factor of
  /// ten and validates cleanly, which is why A1 range-checks it by taxon group.
  final int? minSizeMm;

  /// Millimetres, always.
  final int? maxSizeMm;

  /// Required whenever either size is present.
  final String? measurementMethodId;

  /// How many, of [bagLimitUnit], per [bagLimitPeriod].
  final int? bagLimit;

  /// `count` or `kg`.
  final String? bagLimitUnit;

  /// `day`, `trip` or `season`.
  final String? bagLimitPeriod;

  /// A per-vessel cap, distinct from the per-person bag limit.
  final int? vesselLimit;

  /// A protected species admits no size threshold at all.
  final bool isProtected;

  /// The licence this rule is conditioned on, when the instrument names one.
  final String? licenceTypeId;

  /// Localised note printed under the finding.
  final String? notesKey;

  /// Required. Invariant 3: every result carries a citation, and A4 makes an
  /// uncited row unshippable.
  final String? citationId;

  /// When the rule came into force.
  final String? validFrom;

  /// When it lapsed. Expiry **tags** and never deletes: a lapsed Spanish *orde
  /// de vedas* is still evaluated and still shown behind the ochre bar.
  final String? validTo;

  /// The specificity ladder: exclusion 40, reserve 30, bank/basin 20,
  /// subzone 10, region 0. Derived from the zone when not authored.
  final int specificity;

  /// Clears A1's sub-100 mm finfish range check for a genuinely small threshold,
  /// leaving an audit trail. There is no warning tier to put it in.
  final bool minSizeMmConfirmed;

  @override
  Map<String, String?> get keyColumns => <String, String?>{'notes_key': notesKey};
}

/// A `closed_season` row.
class ClosedSeasonRow extends ContentRow {
  /// A closure read from [path] at [line].
  const ClosedSeasonRow({
    required super.path,
    required super.line,
    required super.id,
    required this.ruleId,
    required this.recurrence,
    this.startMonth,
    this.startDay,
    this.endMonth,
    this.endDay,
    this.startDate,
    this.endDate,
    this.notesKey,
    this.citationId,
    this.wrapsYear = false,
  });

  /// Reads a closure from [row].
  factory ClosedSeasonRow.fromRow(YamlRow row) => ClosedSeasonRow(
    path: row.path,
    line: row.line,
    id: row.id,
    ruleId: row.string('rule_id'),
    recurrence: row.string('recurrence'),
    startMonth: row.integer('start_month'),
    startDay: row.integer('start_day'),
    endMonth: row.integer('end_month'),
    endDay: row.integer('end_day'),
    startDate: row.string('start_date'),
    endDate: row.string('end_date'),
    notesKey: row.string('notes_key'),
    citationId: row.string('citation_id'),
    wrapsYear: row.boolean('wraps_year') ?? false,
  );

  /// The rule this closure belongs to.
  final String? ruleId;

  /// `annual` or `fixed`. The two kinds use different columns, which is why all
  /// six bounds are nullable and A1 checks the pair the recurrence names.
  final String? recurrence;

  /// Annual bound, 1–12.
  final int? startMonth;

  /// Annual bound, 1–31. `02-29` is rejected: three years in four it is not a
  /// date, and a closure that shifts by a day in three years of four is a defect
  /// nobody finds.
  final int? startDay;

  /// Annual bound, 1–12.
  final int? endMonth;

  /// Annual bound, 1–31.
  final int? endDay;

  /// Fixed bound, ISO date.
  final String? startDate;

  /// Fixed bound, ISO date.
  final String? endDate;

  /// Localised note.
  final String? notesKey;

  /// The instrument declaring the closure, when it differs from the rule's.
  final String? citationId;

  /// Declared, never inferred from `end < start`: a November-to-February
  /// closure is legal and an inverted one is a typo, and the two look identical.
  final bool wrapsYear;

  @override
  Map<String, String?> get keyColumns => <String, String?>{'notes_key': notesKey};
}

/// A `licence_type` row.
class LicenceTypeRow extends ContentRow {
  /// A licence type read from [path] at [line].
  const LicenceTypeRow({
    required super.path,
    required super.line,
    required super.id,
    required this.jurisdictionId,
    required this.waterType,
    required this.code,
    required this.nameKey,
    required this.descriptionKey,
    required this.citationId,
    this.zoneId,
  });

  /// Reads a licence type from [row].
  factory LicenceTypeRow.fromRow(YamlRow row) => LicenceTypeRow(
    path: row.path,
    line: row.line,
    id: row.id,
    jurisdictionId: row.string('jurisdiction_id'),
    zoneId: row.string('zone_id'),
    waterType: row.string('water_type'),
    code: row.string('code'),
    nameKey: row.string('name_key'),
    descriptionKey: row.string('description_key'),
    citationId: row.string('citation_id'),
  );

  /// The authority issuing it.
  final String? jurisdictionId;

  /// `null` means the whole jurisdiction.
  final String? zoneId;

  /// `salt`, `fresh` or `both`.
  final String? waterType;

  /// The authority's own code for the licence.
  final String? code;

  /// Localised licence name.
  final String? nameKey;

  /// Localised description. It states what the instrument says and never what
  /// to do about it.
  final String? descriptionKey;

  /// The instrument establishing it.
  final String? citationId;

  @override
  Map<String, String?> get keyColumns => <String, String?>{
    'name_key': nameKey,
    'description_key': descriptionKey,
  };
}

/// A `gear_rule` row.
class GearRuleRow extends ContentRow {
  /// A gear rule read from [path] at [line].
  const GearRuleRow({
    required super.path,
    required super.line,
    required super.id,
    required this.jurisdictionId,
    required this.gearCode,
    required this.gearNameKey,
    required this.isAllowed,
    required this.citationId,
    this.zoneId,
    this.speciesId,
    this.constraintKey,
  });

  /// Reads a gear rule from [row].
  factory GearRuleRow.fromRow(YamlRow row) => GearRuleRow(
    path: row.path,
    line: row.line,
    id: row.id,
    jurisdictionId: row.string('jurisdiction_id'),
    zoneId: row.string('zone_id'),
    speciesId: row.string('species_id'),
    gearCode: row.string('gear_code'),
    gearNameKey: row.string('gear_name_key'),
    isAllowed: row.boolean('is_allowed'),
    constraintKey: row.string('constraint_key'),
    citationId: row.string('citation_id'),
  );

  /// The authority.
  final String? jurisdictionId;

  /// `null` means the whole jurisdiction.
  final String? zoneId;

  /// `null` means every species.
  final String? speciesId;

  /// The authority's gear code.
  final String? gearCode;

  /// Localised gear name.
  final String? gearNameKey;

  /// Whether the instrument permits the gear.
  final bool? isAllowed;

  /// Localised constraint, e.g. a minimum mesh.
  final String? constraintKey;

  /// The instrument.
  final String? citationId;

  @override
  Map<String, String?> get keyColumns => <String, String?>{
    'gear_name_key': gearNameKey,
    'constraint_key': constraintKey,
  };
}

/// A `penalty` row.
class PenaltyRow extends ContentRow {
  /// A penalty read from [path] at [line].
  const PenaltyRow({
    required super.path,
    required super.line,
    required super.id,
    required this.jurisdictionId,
    required this.offenceKey,
    required this.citationId,
    this.occurrence = 1,
    this.amountMin,
    this.amountMax,
    this.currency,
    this.secondaryKey,
  });

  /// Reads a penalty from [row].
  factory PenaltyRow.fromRow(YamlRow row) => PenaltyRow(
    path: row.path,
    line: row.line,
    id: row.id,
    jurisdictionId: row.string('jurisdiction_id'),
    offenceKey: row.string('offence_key'),
    occurrence: row.integer('occurrence') ?? 1,
    amountMin: row.integer('amount_min'),
    amountMax: row.integer('amount_max'),
    currency: row.string('currency'),
    secondaryKey: row.string('secondary_key'),
    citationId: row.string('citation_id'),
  );

  /// The authority.
  final String? jurisdictionId;

  /// Localised description of the offence.
  final String? offenceKey;

  /// First, second or subsequent occurrence — instruments scale by it.
  final int occurrence;

  /// Lower bound of the fine, in the jurisdiction's own currency.
  final int? amountMin;

  /// Upper bound of the fine.
  final int? amountMax;

  /// Never converted: an instrument states a figure in one currency.
  final String? currency;

  /// Localised secondary consequence, e.g. a licence suspension.
  final String? secondaryKey;

  /// The instrument.
  final String? citationId;

  @override
  Map<String, String?> get keyColumns => <String, String?>{
    'offence_key': offenceKey,
    'secondary_key': secondaryKey,
  };
}

/// A `legal_text` row: the article as the authority published it.
class LegalTextRow extends ContentRow {
  /// A text read from [path] at [line].
  const LegalTextRow({
    required super.path,
    required super.line,
    required super.id,
    required this.jurisdictionId,
    required this.citationId,
    required this.locale,
    required this.body,
    this.articleRef,
    this.sortOrder = 0,
  });

  /// Reads a text from [row].
  factory LegalTextRow.fromRow(YamlRow row) => LegalTextRow(
    path: row.path,
    line: row.line,
    id: row.id,
    jurisdictionId: row.string('jurisdiction_id'),
    citationId: row.string('citation_id'),
    locale: row.string('locale'),
    articleRef: row.string('article_ref'),
    body: row.string('body'),
    sortOrder: row.integer('sort_order') ?? 0,
  );

  /// The authority.
  final String? jurisdictionId;

  /// The instrument this is the text of.
  final String? citationId;

  /// **One** locale, the language of publication. Verbatim law is never
  /// translated: an unofficial rendering of a penal instrument is a liability
  /// and falls outside Spain's Art. 13 LPI carve-out entirely.
  final String? locale;

  /// `Art. 3`, `Anexo II`.
  final String? articleRef;

  /// The article, verbatim.
  final String? body;

  /// Reading order within the instrument.
  final int sortOrder;

  @override
  Map<String, String?> get keyColumns => const <String, String?>{};
}
