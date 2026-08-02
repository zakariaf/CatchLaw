import 'package:catchlaw/domain/models/species_facts.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// What the rules say about a set of species, here, today.
///
/// **The zone chain arrives as an argument, and that is
/// `catchlaw-reference-database` rule 11.** The active zone lives in
/// `user_profile.active_zone_code` in `user.db`; the rules live in
/// `reference.db`. `ATTACH` is banned because a wholesale content swap leaves
/// any statement spanning both files pointing at an unlinked inode. So the
/// caller resolves the zone and its ancestors once per zone change, and the SQL
/// runs inside `reference.db` alone.
abstract interface class SpeciesFactsRepository {
  /// Facts for [speciesIds], keyed by species id.
  ///
  /// A species absent from the returned map has **no rule row in this pack** —
  /// which is not "no limit in instrument", and the caller keeps the two apart.
  ///
  /// [zoneChain] is the active zone followed by its ancestors, innermost first.
  /// A rule reaches the active zone when its `zone_id` is `NULL` — it covers
  /// the whole jurisdiction — or is any member of that chain (§7.3 step 2).
  ///
  /// [onDate] is an ISO day. **Expiry does not filter here**: the statement
  /// selects on `valid_from` and never on `valid_to`, because §7.3 step 1 says
  /// so and invariant 5 says a stale ruleset is still evaluated and still
  /// shown.
  @useResult
  Future<Result<Map<int, SpeciesFacts>>> factsFor({
    required List<int> speciesIds,
    required int jurisdictionId,
    required List<int> zoneChain,
    required String onDate,
  });

  /// The active zone and its ancestors, innermost first.
  ///
  /// Walked **once per zone change**, not once per keystroke: re-deriving it
  /// inside the search would put a recursive walk inside the §13 budget.
  @useResult
  Future<Result<List<int>>> zoneChain(int zoneId);
}
