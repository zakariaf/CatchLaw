import 'package:rule_engine/src/date.dart';
import 'package:rule_engine/src/engine_exception.dart';
import 'package:rule_engine/src/failure.dart';
import 'package:rule_engine/src/models/rule.dart';
import 'package:rule_engine/src/models/zone.dart';
import 'package:rule_engine/src/resolve/candidate.dart';
import 'package:rule_engine/src/resolve/evaluation_request.dart';

/// Stages 1 and 2 of `SPEC.md` §7.3: select, then collapse superseded rows.
///
/// **The selection predicate is jurisdiction AND species AND water type AND
/// `validFrom <= on`. There is no fourth clause.** `validTo` is not consulted,
/// not compared, and not used to order anything — it is read exactly once, to
/// compute a tag.
///
/// §7.3 spends a paragraph on why, and the shape of the failure is not the shape
/// most expiry bugs have. A `date < validTo` filter is correct-looking and
/// passes every test written on a Tuesday. It is wrong on one class of row: the
/// annual instrument. A Spanish *orden de vedas* is reissued yearly and lapses
/// on 30 April; a Brazilian *piracema* portaria lapses with the closure it
/// declares. Those are exactly the rows carrying a non-null `validTo` — a
/// permanent ministerial decision carries none. So the filter does not degrade
/// gracefully: on 1 May every Galician shellfish rule vanishes at once, and each
/// species falls through to "no rule recorded".
///
/// What that costs is not a wrong answer, it is a change of category. A bundled
/// snapshot with a known as-of date is a defensible offline product — a printed
/// booklet, and a booklet does not stop being a booklet on 1 May. A snapshot
/// that empties itself when its instruments lapse is a live-data product with no
/// way to fetch live data.
///
/// Returns a [Failure] only for a content defect: a row that claims a shape it
/// does not carry. An empty list is a legitimate [Ok] — absence is a legal
/// statement about the reference data, and E03/T11 is what says it.
Result<List<Candidate>> selectCandidates(EvaluationRequest request, Iterable<Rule> rules) {
  final DateTime on = parseIsoDate(request.on);

  // Stage 1 — select. Four clauses, and the fourth is validFrom, not validTo.
  final selected = <Rule>[];
  for (final rule in rules) {
    if (rule.jurisdictionId != request.jurisdictionId) continue;
    if (rule.speciesId != request.speciesId) continue;
    // `both` WIDENS the match; it must not disable it. A jurisdiction-wide rule
    // covering an estuary as well as the sea is authored as `both`, and the
    // skill's example predicate (`rule.waterType == request.waterType`) drops
    // every one of them.
    if (rule.waterType != WaterType.both && rule.waterType != request.waterType) continue;
    // <= and not <: an instrument applies on its own commencement day.
    if (parseIsoDate(rule.validFrom).isAfter(on)) continue;

    final Object? defect = _defectIn(rule);
    if (defect != null) return Result<List<Candidate>>.error(defect as Exception);
    selected.add(rule);
  }

  // Stage 2 — collapse to the greatest validFrom per (zoneId, lineage).
  //
  // The key is a PAIR. A 2018 amendment supersedes the 2015 instrument it
  // amends because they share a lineage; a Fujairah local order with a
  // different lineage survives and reaches stage 3 on its own merits.
  // Collapsing on zoneId alone lets one authority's newest instrument delete
  // another authority's rule for the same water.
  //
  // Group-then-filter, NOT a Map assignment. The skill's example writes
  // `if (!latest.containsKey(k) || r.validFrom.isAfter(...)) latest[k] = r`,
  // which on an exact validFrom tie keeps whichever row the iterator yielded
  // first. That is a silent choice between two instruments — the advisory act
  // the carve-out lists as voiding it — and the same skill's own edge-case
  // table rules the other way: a tie is a content bug, surfaced as an
  // ambiguity, never resolved by iteration order. So EVERY row at the maximum
  // survives, and two of them arrive at T05 as an Ambiguous.
  final groups = <String, List<Rule>>{};
  for (final rule in selected) {
    (groups['${rule.zoneId}|${rule.citationLineageId}'] ??= <Rule>[]).add(rule);
  }

  final out = <Candidate>[];
  for (final List<Rule> group in groups.values) {
    // Expiry is NOT an input to the collapse. "Expired loses" would be deletion
    // semantics wearing a tie-break costume.
    DateTime newest = parseIsoDate(group.first.validFrom);
    for (final Rule rule in group.skip(1)) {
      final DateTime from = parseIsoDate(rule.validFrom);
      if (from.isAfter(newest)) newest = from;
    }
    for (final rule in group) {
      if (parseIsoDate(rule.validFrom) != newest) continue;
      out.add(Candidate(rule: rule, isExpired: _isExpired(rule, on)));
    }
  }
  return Result<List<Candidate>>.ok(out);
}

/// Whether [rule] had lapsed on [on].
///
/// `isBefore`, so the boundary is inclusive: a rule valid until 30 June is not
/// expired on 30 June, because an instrument in force "until 30 June" is in
/// force that day. `check_rule_engine.sh` check 2 treats `isBefore` here as
/// legitimate and an `isAfter` near `validTo` as a filter, which is the right
/// way round.
bool _isExpired(Rule rule, DateTime on) {
  final String? validTo = rule.validTo;
  return validTo != null && parseIsoDate(validTo).isBefore(on);
}

/// The content defect in [rule], or `null` if it carries what it claims to.
EngineException? _defectIn(Rule rule) {
  // A row naming a measurement method is a size rule, and a size rule with no
  // threshold has no legal statement to make. It may not become an Ok.
  if (rule.measurementMethod != null && rule.minSizeMm == null && rule.maxSizeMm == null) {
    return MalformedRule.noSizeThreshold(ruleId: rule.id);
  }
  if ((rule.minSizeMm != null || rule.maxSizeMm != null) && rule.measurementMethod == null) {
    return MalformedRule.noMeasurementMethod(ruleId: rule.id);
  }
  if (rule.bagLimit != null && (rule.bagLimitUnit == null || rule.bagLimitPeriod == null)) {
    return MalformedRule.noBagLimitPeriod(ruleId: rule.id);
  }
  return null;
}
