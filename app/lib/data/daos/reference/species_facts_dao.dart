import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/tables/reference/rule.dart';
import 'package:catchlaw/data/services/tables/reference/zone.dart';
import 'package:drift/drift.dart';

part 'species_facts_dao.g.dart';

/// One row per species: the most specific rule that reaches this place, and
/// whether that rule reaches the active zone.
///
/// **The statement never mentions `valid_to`.** §7.3 step 1 is explicit that
/// expiry is not a filter, and invariant 5 says a stale ruleset is still
/// evaluated and still shown. A species whose only rule lapsed last season must
/// still appear with its numbers, behind a bar — not vanish, which reads as
/// "no rule recorded" and is a different, and permissive, thing.
///
/// The zone chain arrives as a list of ids rather than as a join across
/// `user.db`. `catchlaw-reference-database` rule 11 bans `ATTACH`: a wholesale
/// content swap leaves any statement spanning both files pointing at an
/// unlinked inode.
// Citations are CitationDao's — it already has byIds, and a second accessor
// for the same table is a second place a join can drift.
@DriftAccessor(tables: <Type>[Rules, ClosedSeasons, Zones])
class SpeciesFactsDao extends DatabaseAccessor<ReferenceDatabase> with _$SpeciesFactsDaoMixin {
  /// Reads facts from [db].
  SpeciesFactsDao(super.db);

  /// The zone and every ancestor above it, innermost first.
  ///
  /// Walked once per zone change, not once per query: §7.3 step 2's predicate
  /// needs the whole chain, and re-deriving it on every keystroke would put a
  /// recursive walk inside the §13 budget.
  Future<List<int>> zoneChain(int zoneId) async {
    final chain = <int>[];
    int? next = zoneId;
    // `seen` bounds the walk, so a cyclic parent link in a bad pack cannot hang
    // the search box — a content file is data this build did not produce.
    final seen = <int>{};
    while (next != null && seen.add(next)) {
      final int current = next;
      chain.add(current);
      final ZoneRow? row = await (select(
        zones,
      )..where(($ZonesTable t) => t.id.equals(current))).getSingleOrNull();
      next = row?.parentZoneId;
    }
    return chain;
  }

  /// Every candidate rule for [speciesIds] in this jurisdiction on [onDate].
  ///
  /// Returns rules for the whole jurisdiction, in-zone or not, because the
  /// caller shows both groups: a fisher who has picked the wrong zone must be
  /// able to see that his fish exists.
  Future<List<RuleRow>> candidateRules({
    required List<int> speciesIds,
    required int jurisdictionId,
    required String onDate,
  }) {
    if (speciesIds.isEmpty) return Future<List<RuleRow>>.value(const <RuleRow>[]);
    return (select(rules)
          ..where(
            ($RulesTable t) =>
                t.speciesId.isIn(speciesIds) &
                t.jurisdictionId.equals(jurisdictionId) &
                t.validFrom.isSmallerOrEqualValue(onDate),
          )
          // Most specific first, so the caller takes the first match per
          // species without a second pass.
          ..orderBy(<OrderClauseGenerator<$RulesTable>>[
            (t) => OrderingTerm.desc(t.specificity),
            (t) => OrderingTerm.desc(t.validFrom),
          ]))
        .get();
  }

  /// The closures attached to those rules.
  Future<List<ClosedSeasonRow>> closedSeasonsFor(Iterable<int> ruleIds) {
    final List<int> wanted = ruleIds.toSet().toList();
    if (wanted.isEmpty) return Future<List<ClosedSeasonRow>>.value(const <ClosedSeasonRow>[]);
    return (select(closedSeasons)..where(($ClosedSeasonsTable t) => t.ruleId.isIn(wanted))).get();
  }
}
