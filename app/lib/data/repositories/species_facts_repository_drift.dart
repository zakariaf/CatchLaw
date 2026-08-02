import 'package:catchlaw/data/daos/reference/citation_dao.dart';
import 'package:catchlaw/data/daos/reference/species_facts_dao.dart';
import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/model/mappers.dart';
import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/species_facts_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/rule_hint.dart';
import 'package:catchlaw/domain/models/species_facts.dart';
import 'package:rule_engine/rule_engine.dart' show Citation, Result;

/// [SpeciesFactsRepository] over the read-only `reference.db` (D-6).
final class DriftSpeciesFactsRepository implements SpeciesFactsRepository {
  /// Reads facts out of [db].
  DriftSpeciesFactsRepository(this.db, {this.boundary = const StorageBoundary()})
    : _facts = SpeciesFactsDao(db),
      _citations = CitationDao(db);

  /// The rule book.
  final ReferenceDatabase db;

  /// Where a storage exception becomes a `DataFailure`.
  final StorageBoundary boundary;

  final SpeciesFactsDao _facts;
  final CitationDao _citations;

  @override
  Future<Result<List<int>>> zoneChain(int zoneId) => boundary.guard(() => _facts.zoneChain(zoneId));

  @override
  Future<Result<Map<int, SpeciesFacts>>> factsFor({
    required List<int> speciesIds,
    required int jurisdictionId,
    required List<int> zoneChain,
    required String onDate,
  }) => boundary.guard(() async {
    final List<RuleRow> candidates = await _facts.candidateRules(
      speciesIds: speciesIds,
      jurisdictionId: jurisdictionId,
      onDate: onDate,
    );
    if (candidates.isEmpty) return const <int, SpeciesFacts>{};

    final Set<int> closed = (await _facts.closedSeasonsFor(
      candidates.map((RuleRow r) => r.id),
    )).map((ClosedSeasonRow c) => c.ruleId).toSet();

    final citationsById = <int, Citation>{
      for (final CitationRow row in await _citations.byIds(
        candidates.map((RuleRow r) => r.citationId),
      ))
        row.id: toCitation(row),
    };

    final facts = <int, SpeciesFacts>{};
    for (final rule in candidates) {
      // The statement already ordered by specificity, so the first rule per
      // species is the most specific one that reaches this jurisdiction.
      if (facts.containsKey(rule.speciesId)) continue;
      facts[rule.speciesId] = SpeciesFacts(
        // §7.3 step 2: a rule reaches the active zone when its zone_id is NULL
        // — it covers the whole jurisdiction — or is any member of the chain.
        inActiveZone: rule.zoneId == null || zoneChain.contains(rule.zoneId),
        hint: _hintFor(rule, isClosed: closed.contains(rule.id)),
        // Throws rather than emitting a fact with a blank footnote, which is
        // E05's established shape for exactly this lookup. Invariant 3 is a
        // REQUIRED, non-nullable Citation, and a hint without one is the app
        // asserting the law on its own authority — so there is no nullable
        // Citation anywhere in this file, not even as a local.
        citation: _requireCitation(citationsById, rule.citationId),
      );
    }
    return facts;
  });

  /// The citation for [id], or a [DataNotFound].
  ///
  /// Same shape as `DriftReferenceRepository._require`, deliberately: E05
  /// established that a rule whose citation does not resolve does not become a
  /// rule with a blank footnote — it does not become a rule. And there is no
  /// nullable `Citation` anywhere in this file, not even as a local, because
  /// invariant 3 is a required non-null field and `check_app_invariants.sh`
  /// reads the token rather than the intent.
  Citation _requireCitation(Map<int, Citation> citations, int id) =>
      citations[id] ?? (throw DataNotFound(entity: 'citation for rule', id: '$id'));

  /// The one-word headline, in the order the fisher needs it.
  ///
  /// Protected outranks a closure and a closure outranks a size, because they
  /// are not three facts of equal weight: a protected species may not be taken
  /// at any size in any month, so leading with a minimum would be true and
  /// useless.
  RuleHint _hintFor(RuleRow rule, {required bool isClosed}) {
    if (rule.isProtected) return const ProtectedHint();
    if (isClosed) return const ClosedSeasonHint();
    final int? minimum = rule.minSizeMm;
    final int? methodId = rule.measurementMethodId;
    // A minimum with no method is a number the engine would have to guess at,
    // and TL and FL differ by 6-9 cm on a Kanaad. E04's build assertion A1
    // rejects such a row, so reaching this branch means a pack this build did
    // not produce — and no headline beats a wrong one.
    if (minimum == null || methodId == null) return const NoHint();
    return MinimumSizeHint(millimetres: minimum, method: measurementMethodOfId(methodId));
  }
}
