import 'package:rule_engine/src/models/rule.dart';
import 'package:rule_engine/src/models/zone.dart';
import 'package:rule_engine/src/resolve/candidate.dart';
import 'package:rule_engine/src/resolve/evaluation_request.dart';

/// Where [rule] sits on `SPEC.md` §7.3's specificity ladder, given [zonePath].
///
/// Derived from the MATCHED ZONE'S KIND, never from `rule.specificity`. §7.1
/// stores that integer on the row and E04 writes it; two sources of truth need
/// a tie-break, and the one that should win is the ladder §7.3 publishes rather
/// than a value a content author could mistype into one YAML row. Nothing in
/// this package reads the column, which is what makes E04's build-time
/// assertion (epic risk 6) the only place the two can be seen to diverge.
///
/// A `NULL` zone id ranks 0, the same as [ZoneKind.region], and that is not an
/// oversight: `resolution-algorithm.md` states the intent directly — a national
/// minimum and a regional minimum that disagree is a genuine ambiguity, not
/// something the sort order should quietly settle. Ranking the jurisdiction-wide
/// rule below the regional one would silently resolve exactly the conflict this
/// product refuses to resolve.
int specificityOf(Rule rule, List<Zone> zonePath) {
  final int? zoneId = rule.zoneId;
  if (zoneId == null) return 0;
  for (final zone in zonePath) {
    if (zone.id == zoneId) return zone.zoneKind.specificity;
  }
  return 0;
}

/// Stage 3 of `SPEC.md` §7.3: keep the candidates that apply here, strictest
/// first.
///
/// A rule applies when its `zoneId` is null, or equals ANY zone on the request's
/// ancestry path — not merely the active one. Dropping the ancestors is the
/// mistake that deletes every regional rule the moment a subzone is picked.
///
/// Ancestry is a list-membership test rather than a tree walk. The path arrives
/// materialised from E05, root first, because `resolution-algorithm.md` puts it
/// plainly: ancestry is a membership test, not a recursive CTE at 05:40, and
/// §13's 10 ms budget is the number behind that. The engine holding every zone
/// in the jurisdiction so it could walk `parentZoneId` itself would be five
/// hundred rows to reproduce a result one indexed query already has.
///
/// **The sort is stable, by construction.** Dart's `List.sort` is documented as
/// unstable, `the-five-part-carve-out.md` part 3 requires two conflicting rules
/// to print in SOURCE order, and `catchlaw-verdict-contract` rule 6 bans a
/// `sort` in the ambiguity path for the same reason. If equal-specificity rows
/// came out in a different order on two runs of one input, D4 would render its
/// two citations in a shifting order — which looks like the app choosing, and
/// that is the one thing it must never look like. The comparator therefore
/// breaks ties on the candidate's original index.
List<Candidate> matchAndRank(EvaluationRequest request, List<Candidate> candidates) {
  final matched = <({Candidate candidate, int index, int specificity})>[];
  for (var i = 0; i < candidates.length; i++) {
    final Candidate candidate = candidates[i];
    final int? zoneId = candidate.rule.zoneId;
    if (zoneId != null && !request.zonePath.any((Zone z) => z.id == zoneId)) continue;
    matched.add((
      candidate: candidate,
      index: i,
      specificity: specificityOf(candidate.rule, request.zonePath),
    ));
  }

  // Index-decorated, so equal specificities fall back on source order and the
  // result cannot depend on which sort algorithm the list length selected.
  // package:collection's mergeSort would also work and is one more dependency
  // in the package tools/content_builder compiles under a plain `dart run`.
  matched.sort((
    ({Candidate candidate, int index, int specificity}) a,
    ({Candidate candidate, int index, int specificity}) b,
  ) {
    final int bySpecificity = b.specificity.compareTo(a.specificity);
    return bySpecificity != 0 ? bySpecificity : a.index.compareTo(b.index);
  });

  return <Candidate>[
    for (final ({Candidate candidate, int index, int specificity}) m in matched) m.candidate,
  ];
}
