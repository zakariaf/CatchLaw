import 'package:catchlaw/data/daos/reference/citation_dao.dart';
import 'package:catchlaw/data/daos/reference/content_string_dao.dart';
import 'package:catchlaw/data/daos/reference/rule_dao.dart';
import 'package:catchlaw/data/daos/reference/species_dao.dart';
import 'package:catchlaw/data/daos/reference/zone_dao.dart';
import 'package:catchlaw/data/model/mappers.dart';
import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/reference_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:rule_engine/rule_engine.dart'
    show Citation, ClosedSeason, MeasurementMethod, Result, Rule;

/// [ReferenceRepository] over the shipped, read-only `reference.db`.
///
/// The DAOs beneath speak rows; everything above speaks domain and engine
/// types, and this class is the only thing that knows both. Cross-table work —
/// a rule with its citation and its closures — lives here rather than in a DAO,
/// which is `persistence-drift` rule 7 and is also the only place the join can
/// be done in a bounded number of queries.
final class DriftReferenceRepository implements ReferenceRepository {
  /// Reads the rule book through [db].
  DriftReferenceRepository(this.db, {this.boundary = const StorageBoundary()})
    : _species = SpeciesDao(db),
      _rules = RuleDao(db),
      _strings = ContentStringDao(db),
      _citations = CitationDao(db),
      _zones = ZoneDao(db),
      _meta = ReferenceMetaDao(db);

  /// The read-only connection.
  final ReferenceDatabase db;

  /// Where a storage exception becomes a [DataFailure].
  final StorageBoundary boundary;

  final SpeciesDao _species;
  final RuleDao _rules;
  final ContentStringDao _strings;
  final CitationDao _citations;
  final ZoneDao _zones;
  final ReferenceMetaDao _meta;

  @override
  Future<Result<List<Species>>> searchSpecies(String normalisedPrefix, {int limit = 40}) =>
      boundary.guard(
        () async => (await _species.searchByNormalisedPrefix(
          normalisedPrefix,
          limit: limit,
        )).map(toSpecies).toList(),
      );

  @override
  Future<Result<Species>> speciesById(int id) => boundary.guard(() async {
    final SpeciesRow? row = await _species.byId(id);
    if (row == null) throw DataNotFound(entity: 'species', id: '$id');
    return toSpecies(row);
  });

  @override
  Future<Result<List<SpeciesName>>> namesFor(int speciesId) =>
      boundary.guard(() async => (await _species.namesFor(speciesId)).map(toSpeciesName).toList());

  @override
  Future<Result<List<Rule>>> candidateRules({
    required int jurisdictionId,
    required int speciesId,
    required String waterType,
    required String onDate,
  }) => boundary.guard(() async {
    final List<RuleRow> rows = await _rules.candidatesFor(
      jurisdictionId: jurisdictionId,
      speciesId: speciesId,
      waterType: waterType,
      onDate: onDate,
    );
    if (rows.isEmpty) return const <Rule>[];

    // Three queries for the whole candidate set, not three per rule. §13
    // budgets one evaluation at under 10 ms over at most twenty candidates,
    // and sixty round trips is that budget spent entirely on round trips.
    final List<ClosedSeasonRow> seasonRows = await _rules.closedSeasonsFor(
      rows.map((RuleRow r) => r.id),
    );
    final Map<int, Citation> citations = await _citationsById(<int>[
      for (final RuleRow r in rows) r.citationId,
      for (final ClosedSeasonRow s in seasonRows) ?s.citationId,
    ]);

    final byRule = <int, List<ClosedSeason>>{};
    for (final s in seasonRows) {
      (byRule[s.ruleId] ??= <ClosedSeason>[]).add(
        toClosedSeason(s, citation: _require(citations, s.citationId, 'closed_season')),
      );
    }

    // Read once per query, not per rule: the table is nine rows at most and
    // never changes within a pack.
    final Map<int, String> codes = await _meta.methodCodes();

    return <Rule>[
      for (final RuleRow r in rows)
        toRule(
          r,
          citation: _require(citations, r.citationId, 'rule'),
          // Resolved through the CODE. The build assigns
          // `measurement_method.id` by insertion order, so a pack declaring one
          // method gives it id 1 — and an id-to-enum map reads that as total
          // length. A shell-length rule printing as a total-length rule is the
          // failure this whole product exists to prevent.
          method: _methodFor(r.measurementMethodId, codes),
          closedSeasons: byRule[r.id] ?? const <ClosedSeason>[],
        ),
    ];
  });

  @override
  Future<Result<List<ClosedSeason>>> closedSeasonsFor(Iterable<int> ruleIds) =>
      boundary.guard(() async {
        final List<ClosedSeasonRow> rows = await _rules.closedSeasonsFor(ruleIds);
        final Map<int, Citation> citations = await _citationsById(<int>[
          for (final ClosedSeasonRow s in rows) ?s.citationId,
        ]);
        return <ClosedSeason>[
          for (final ClosedSeasonRow s in rows)
            toClosedSeason(s, citation: _require(citations, s.citationId, 'closed_season')),
        ];
      });

  @override
  Future<Result<List<Citation>>> citations(Iterable<int> ids) =>
      boundary.guard(() async => (await _citations.byIds(ids)).map(toCitation).toList());

  @override
  Future<Result<Map<String, String>>> strings(Iterable<String> keys, String locale) =>
      boundary.guard(() => _strings.resolve(keys, locale));

  @override
  Future<Result<List<Jurisdiction>>> jurisdictions() =>
      boundary.guard(() async => (await _meta.allJurisdictions()).map(toJurisdiction).toList());

  @override
  Future<Result<List<Zone>>> zones(int jurisdictionId) => boundary.guard(
    () async => (await _zones.byJurisdiction(jurisdictionId)).map(toZone).toList(),
  );

  @override
  Future<Result<Map<String, String>>> contentMeta() => boundary.guard(_meta.contentMeta);

  /// The engine's method for a rule's `measurement_method_id`.
  ///
  /// A code this build does not recognise resolves to `null` — the same shape
  /// as a rule with no method at all — because the engine emits NO size finding
  /// without one. That is the safe direction: a size rule the app cannot state
  /// the method for is a size rule it does not state.
  MeasurementMethod? _methodFor(int? id, Map<int, String> codes) {
    if (id == null) return null;
    final String? code = codes[id];
    return code == null ? null : MeasurementMethod.fromCode(code);
  }

  Future<Map<int, Citation>> _citationsById(Iterable<int> ids) async => <int, Citation>{
    for (final CitationRow row in await _citations.byIds(ids)) row.id: toCitation(row),
  };

  /// The citation [id], or a [DataNotFound] naming what was missing it.
  ///
  /// A dangling `citation_id` is A6's job to make unshippable, and this is what
  /// happens if one ships anyway: a typed failure, not an empty placeholder.
  /// Invariant 3 says a result carries a citation — so a rule that cannot
  /// produce one does not become a rule with a blank footnote, it does not
  /// become a rule.
  Citation _require(Map<int, Citation> citations, int? id, String owner) =>
      citations[id] ?? (throw DataNotFound(entity: 'citation for $owner', id: '$id'));
}
