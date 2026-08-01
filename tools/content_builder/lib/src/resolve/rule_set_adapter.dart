import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/model/enums.dart' as enums;
import 'package:content_builder/src/model/geography.dart';
import 'package:content_builder/src/model/regulation.dart';
import 'package:content_builder/src/model/taxon.dart';
import 'package:rule_engine/rule_engine.dart';

/// The authored corpus, mapped into the plain Dart types `evaluate()` takes.
///
/// **No SQLite, no drift.** The engine must stay constructible from a fixture
/// without opening a database, so nothing here has a row type that pins it to
/// one — that is `catchlaw-rule-engine`'s own anti-pattern.
///
/// Authored ids are kebab strings and the engine's are integers. They are
/// assigned by **sorted** authored id so two runs over one corpus produce the
/// same numbers: a hash-order id would make the resolution grid, its failure
/// messages and T10's rebuild all non-reproducible.
class RuleSetAdapter {
  RuleSetAdapter._({
    required this.rules,
    required this.species,
    required this.zones,
    required this.jurisdictions,
    required this.citations,
    required this.ruleIdOf,
    required this.zonesById,
  });

  /// Maps [source] into engine types.
  factory RuleSetAdapter.of(ContentSource source) {
    final List<SpeciesRow> speciesRows = source.typedRows.whereType<SpeciesRow>().toList();
    final List<ZoneRow> zoneRows = source.typedRows.whereType<ZoneRow>().toList();
    final List<RuleRow> ruleRows = source.typedRows.whereType<RuleRow>().toList();
    final List<CitationRow> citationRows = source.typedRows.whereType<CitationRow>().toList();
    final List<JurisdictionRow> jurisdictionRows = source.typedRows
        .whereType<JurisdictionRow>()
        .toList();
    final List<ClosedSeasonRow> seasonRows = source.typedRows.whereType<ClosedSeasonRow>().toList();

    final Map<String, int> speciesIds = _numbered(speciesRows.map((SpeciesRow r) => r.id));
    final Map<String, int> zoneIds = _numbered(zoneRows.map((ZoneRow r) => r.id));
    final Map<String, int> jurisdictionIds = _numbered(
      jurisdictionRows.map((JurisdictionRow r) => r.id),
    );
    final Map<String, int> ruleIds = _numbered(ruleRows.map((RuleRow r) => r.id));

    final citations = <String, Citation>{
      for (final CitationRow c in citationRows)
        c.id: Citation(
          instrument: c.instrumentRef ?? c.id,
          article: c.articleRef ?? '',
          publishedOn: c.publishedOn ?? '',
          checkedOn: c.retrievedOn ?? '',
        ),
    };

    final seasonsByRule = <String, List<ClosedSeason>>{};
    for (final s in seasonRows) {
      (seasonsByRule[s.ruleId ?? ''] ??= <ClosedSeason>[]).add(
        ClosedSeason(
          recurrence: s.recurrence == enums.Recurrence.fixed.sql
              ? Recurrence.fixed
              : Recurrence.annual,
          citation: citations[s.citationId] ?? _unknownCitation,
          startMonth: s.startMonth,
          startDay: s.startDay,
          endMonth: s.endMonth,
          endDay: s.endDay,
          startDate: s.startDate,
          endDate: s.endDate,
        ),
      );
    }

    // `supersedes:` is implemented as a SHARED CITATION LINEAGE, not as a second
    // precedence rule. The engine already collapses candidates per
    // (zone_id, citation lineage) and keeps the greatest valid_from, so an
    // amending order that adopts the lineage of the order it amends is resolved
    // by §7.3 itself. Writing a superseding pass here would be a second copy of
    // the algorithm, kept in step by hand.
    String lineageOf(RuleRow row) {
      final seen = <String>{};
      var current = row;
      while (current.supersedes != null && seen.add(current.id)) {
        final RuleRow? older = ruleRows
            .where((RuleRow r) => r.id == current.supersedes)
            .firstOrNull;
        if (older == null) break;
        current = older;
      }
      return current.citationLineage ?? current.id;
    }

    final rules = <Rule>[
      for (final RuleRow row in ruleRows)
        Rule(
          id: ruleIds[row.id]!,
          jurisdictionId: jurisdictionIds[row.jurisdictionId] ?? -1,
          zoneId: row.zoneId == null ? null : (zoneIds[row.zoneId] ?? _orphanZoneId),
          speciesId: speciesIds[row.speciesId] ?? -1,
          waterType: enums.bySql(enums.WaterType.values, row.waterType ?? '') == null
              ? WaterType.salt
              : WaterType.values.byName(row.waterType!),
          citation: citations[row.citationId] ?? _unknownCitation,
          citationLineageId: lineageOf(row),
          validFrom: row.validFrom ?? '1970-01-01',
          validTo: row.validTo,
          minSizeMm: row.minSizeMm,
          maxSizeMm: row.maxSizeMm,
          measurementMethod: row.measurementMethodId == null
              ? null
              : MeasurementMethod.fromCode(row.measurementMethodId!),
          bagLimit: row.bagLimit,
          bagLimitUnit: row.bagLimitUnit == null
              ? null
              : LimitUnit.values.byName(row.bagLimitUnit!),
          bagLimitPeriod: row.bagLimitPeriod == null
              ? null
              : LimitPeriod.values.byName(row.bagLimitPeriod!),
          vesselLimit: row.vesselLimit,
          isProtected: row.isProtected,
          closedSeasons: seasonsByRule[row.id] ?? const <ClosedSeason>[],
        ),
    ];

    return RuleSetAdapter._(
      rules: rules,
      species: <String, Species>{
        for (final SpeciesRow s in speciesRows)
          s.id: Species(
            id: speciesIds[s.id]!,
            scientificName: s.scientificName ?? s.id,
            taxonGroup: enums.bySql(enums.TaxonGroup.values, s.taxonGroup ?? '') == null
                ? TaxonGroup.other
                : TaxonGroup.values.byName(s.taxonGroup!),
          ),
      },
      zones: <String, Zone>{
        for (final ZoneRow z in zoneRows)
          z.id: Zone(
            id: zoneIds[z.id]!,
            jurisdictionId: jurisdictionIds[z.jurisdictionId] ?? -1,
            parentZoneId: z.parentZoneId == null ? null : zoneIds[z.parentZoneId],
            code: z.code ?? z.id,
            waterType: enums.bySql(enums.WaterType.values, z.waterType ?? '') == null
                ? WaterType.salt
                : WaterType.values.byName(z.waterType!),
            zoneKind: enums.bySql(enums.ZoneKind.values, z.zoneKind ?? '') == null
                ? ZoneKind.region
                : ZoneKind.values.byName(z.zoneKind!),
          ),
      },
      jurisdictions: jurisdictionIds,
      citations: citations,
      ruleIdOf: <int, String>{
        for (final MapEntry<String, int> e in ruleIds.entries) e.value: e.key,
      },
      zonesById: <String, ZoneRow>{for (final ZoneRow z in zoneRows) z.id: z},
    );
  }

  /// Every authored rule, as an engine [Rule].
  final List<Rule> rules;

  /// Every authored species, by authored id.
  final Map<String, Species> species;

  /// Every authored zone, as an engine [Zone], by authored id.
  final Map<String, Zone> zones;

  /// Every authored jurisdiction's integer id, by authored id.
  final Map<String, int> jurisdictions;

  /// Every authored citation, as an engine [Citation], by authored id.
  final Map<String, Citation> citations;

  /// The authored rule id behind each engine rule id.
  ///
  /// A failure has to name the row the author wrote, not the number the build
  /// gave it.
  final Map<int, String> ruleIdOf;

  /// The authored [ZoneRow] behind each authored zone id, for the parent chain.
  final Map<String, ZoneRow> zonesById;

  /// How many times [collect] has been called.
  ///
  /// The structural budget, measured rather than asserted in prose: `SPEC.md`
  /// §13's per-evaluation cost must not be multiplied by the whole grid, and a
  /// wall-clock test on CI is a flake — a flake in a fatal assertion gets
  /// disabled. A8 calls this once per `(species, water type)`, and the count
  /// says so.
  int collectCalls = 0;

  /// The rules that could bite on [speciesId] in [waterType], read once.
  ///
  /// `SPEC.md` §13 budgets one evaluation at under 10 ms over at most twenty
  /// candidate rows, and that budget includes the device's row read.
  /// Re-collecting per cell would multiply the expensive half by the whole grid,
  /// so A8 calls this once per `(species, water type)` group and sweeps the
  /// group's cells against the same list.
  List<Rule> collect(int speciesId, WaterType waterType) {
    collectCalls++;
    return <Rule>[
      for (final Rule rule in rules)
        if (rule.speciesId == speciesId &&
            (rule.waterType == WaterType.both || rule.waterType == waterType))
          rule,
    ];
  }

  /// [zoneId]'s ancestry, nearest first, as `matchAndRank` expects.
  ///
  /// Materialised once per zone rather than walked per cell: ancestry is a list
  /// membership test, not a recursive walk for every month of the year.
  List<Zone> zonePathOf(String? zoneId) {
    final path = <Zone>[];
    final seen = <String>{};
    var current = zoneId;
    while (current != null && seen.add(current)) {
      final Zone? zone = zones[current];
      if (zone == null) break;
      path.add(zone);
      current = zonesById[current]?.parentZoneId;
    }
    return path;
  }

  static Map<String, int> _numbered(Iterable<String> ids) {
    final List<String> sorted = ids.toSet().toList()..sort();
    return <String, int>{for (var i = 0; i < sorted.length; i++) sorted[i]: i + 1};
  }

  /// The id a rule's `zone_id` gets when it names a zone nobody authored.
  ///
  /// Deliberately unmatchable: the rule then resolves in no cell, which is what
  /// A8 reports. Silently dropping the zone would make the rule apply
  /// jurisdiction-wide — the opposite of what the author wrote.
  static const int _orphanZoneId = -1;

  static const Citation _unknownCitation = Citation(
    instrument: '',
    article: '',
    publishedOn: '',
    checkedOn: '',
  );
}
