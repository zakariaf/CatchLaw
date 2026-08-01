/// The closed sets `SPEC.md` §7.1 writes as `CHECK (… IN (…))`.
///
/// Every spelling here is read out of the schema, not out of memory. A value
/// outside one of these sets either aborts the emitter's insert with a message
/// about SQLite rather than about the row, or is silently coerced by a lenient
/// author — and both are found at sea rather than at authoring time.
library;

/// One member of a `SPEC.md` §7.1 closed set, and the spelling SQL uses for it.
abstract interface class SqlEnum {
  /// The value as the `CHECK` constraint writes it.
  String get sql;
}

/// The member of [values] spelt [sql], or `null` when there is none.
T? bySql<T extends SqlEnum>(List<T> values, String sql) {
  for (final value in values) {
    if (value.sql == sql) return value;
  }
  return null;
}

/// The legal spellings of [values], in schema order, for a failure message.
String legalSet(List<SqlEnum> values) => values.map((SqlEnum v) => v.sql).join(', ');

/// `water_type` on `zone`, `rule` and `licence_type`.
enum WaterType implements SqlEnum {
  /// The sea.
  salt('salt'),

  /// Rivers, reservoirs and lakes.
  fresh('fresh'),

  /// A property of a rule, never of a request: a `both` rule bites in either.
  both('both');

  const WaterType(this.sql);

  @override
  final String sql;
}

/// `zone_kind` on `zone` — the specificity ladder the resolver sorts on.
enum ZoneKind implements SqlEnum {
  /// Specificity 0.
  region('region'),

  /// Specificity 10.
  subzone('subzone'),

  /// Specificity 20.
  bank('bank'),

  /// Specificity 20, alongside `bank`.
  basin('basin'),

  /// Specificity 30.
  reserve('reserve'),

  /// Specificity 40 — the most specific thing an instrument can say.
  exclusion('exclusion');

  const ZoneKind(this.sql);

  @override
  final String sql;
}

/// `taxon_group` on `species` and `key_node`.
///
/// §7.1 splits molluscs into `bivalve`, `gastropod` and `cephalopod`. Collapsing
/// them loses the identification key's entry point, and scopes A1's millimetre
/// range check wrongly: a 38 mm clam is legal and a 38 mm grouper is a typo.
enum TaxonGroup implements SqlEnum {
  /// Bony fish. The only group A1 range-checks.
  finfish('finfish'),

  /// Crabs, lobsters, prawns.
  crustacean('crustacean'),

  /// Clams, cockles, mussels, scallops.
  bivalve('bivalve'),

  /// Whelks, limpets, abalone.
  gastropod('gastropod'),

  /// Octopus, squid, cuttlefish.
  cephalopod('cephalopod'),

  /// Sea urchins, sea cucumbers.
  echinoderm('echinoderm'),

  /// Sharks, skates and rays.
  elasmobranch('elasmobranch'),

  /// Everything the seven above do not cover.
  other('other');

  const TaxonGroup(this.sql);

  @override
  final String sql;
}

/// `bag_limit_unit` on `rule`.
enum LimitUnit implements SqlEnum {
  /// A number of individuals.
  count('count'),

  /// A mass. Stored in the instrument's own unit and never converted.
  kg('kg');

  const LimitUnit(this.sql);

  @override
  final String sql;
}

/// `bag_limit_period` on `rule`. Per day, per trip and per season are three
/// different limits, and an instrument names exactly one.
enum LimitPeriod implements SqlEnum {
  /// Per calendar day.
  day('day'),

  /// Per trip, however long the trip is.
  trip('trip'),

  /// Per season, as the instrument defines the season.
  season('season');

  const LimitPeriod(this.sql);

  @override
  final String sql;
}

/// `gender` on `species_name`.
///
/// Required in every locale but `en`: "la mero" instead of "el mero" reads as
/// machine translation, and a document that reads machine-translated is not
/// believed when it states a prohibition.
enum Gender implements SqlEnum {
  /// Masculine.
  m('m'),

  /// Feminine.
  f('f'),

  /// Neuter.
  n('n');

  const Gender(this.sql);

  @override
  final String sql;
}

/// `recurrence` on `closed_season`.
///
/// The two kinds use different columns, which is why all six bounds are
/// nullable and A1 checks the pair the recurrence names rather than whichever
/// pair happens to be populated.
enum Recurrence implements SqlEnum {
  /// Repeats every year, bounded by (month, day) pairs.
  annual('annual'),

  /// Two absolute dates. It does not recur.
  fixed('fixed');

  const Recurrence(this.sql);

  @override
  final String sql;
}

/// `measurement_method.code` — all nine of them.
///
/// `check_content_pipeline.sh` check 5 recognises four. The build validates
/// against nine and is authoritative; the gap is recorded in
/// `content/README.md`.
enum MeasurementCode implements SqlEnum {
  /// Total length: snout to the tip of the tail.
  totalLength('TL'),

  /// Fork length: snout to the fork of the tail. 6–9 cm shorter than TL on a
  /// *Scomberomorus commerson*, which is the whole reason this column exists.
  forkLength('FL'),

  /// Standard length: snout to the base of the tail.
  standardLength('SL'),

  /// Carapace width — *Necora puber*, *Cancer pagurus*.
  carapaceWidth('CW'),

  /// Carapace length — *Maja squinado*.
  carapaceLength('CL'),

  /// Mantle length — cephalopods.
  mantleLength('ML'),

  /// Disc width — rays.
  discWidth('DW'),

  /// Shell length — *Venerupis corrugata*, 38 mm.
  shellLength('SHL'),

  /// Anything an instrument defines for itself, described in `definition_key`.
  custom('CUSTOM');

  const MeasurementCode(this.sql);

  @override
  final String sql;
}
