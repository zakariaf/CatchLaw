import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/tables/reference/rule.dart';
import 'package:drift/drift.dart';

part 'rule_dao.g.dart';

/// Reads the rows `SPEC.md` §7.3 resolves over.
@DriftAccessor(tables: <Type>[Rules, ClosedSeasons])
class RuleDao extends DatabaseAccessor<ReferenceDatabase> with _$RuleDaoMixin {
  /// Reads rules from [db].
  RuleDao(super.db);

  /// Every rule that could bite, **including expired ones**.
  ///
  /// **There is no `valid_to` clause here, and that is the correctness fix
  /// §7.3 exists to record.** The first draft filtered on `date < valid_to`,
  /// which meant that on the day a Spanish annual *orden de vedas* or a
  /// Brazilian piracema portaria lapsed, every rule sourced from it vanished
  /// and every species fell through to "no rule recorded". Those annual
  /// instruments are exactly the rows that carry a `valid_to`.
  ///
  /// Expiry is **tagged** by the engine and shown behind a non-blocking ochre
  /// bar. Filtering it here would turn a defensible frozen snapshot into a de
  /// facto live-data product — the brief's auto-reject — and would contradict
  /// §4.7 and §14, both of which promise a verdict *plus* a warning.
  ///
  /// `water_type` matches the request or `both`: a `both` rule bites in either,
  /// and a request is never `both`.
  Future<List<RuleRow>> candidatesFor({
    required int jurisdictionId,
    required int speciesId,
    required String waterType,
    required String onDate,
  }) =>
      (select(rules)..where(
            ($RulesTable t) =>
                t.jurisdictionId.equals(jurisdictionId) &
                t.speciesId.equals(speciesId) &
                (t.waterType.equals(waterType) | t.waterType.equals('both')) &
                t.validFrom.isSmallerOrEqualValue(onDate),
          ))
          .get();

  /// The closures attached to [ruleIds], read in one query.
  ///
  /// One query rather than one per rule: §13 budgets a single evaluation at
  /// under 10 ms over at most twenty candidates, and twenty round trips is the
  /// budget spent on round trips.
  Future<List<ClosedSeasonRow>> closedSeasonsFor(Iterable<int> ruleIds) {
    final List<int> ids = ruleIds.toList();
    if (ids.isEmpty) return Future<List<ClosedSeasonRow>>.value(const <ClosedSeasonRow>[]);
    return (select(closedSeasons)..where(($ClosedSeasonsTable t) => t.ruleId.isIn(ids))).get();
  }
}
