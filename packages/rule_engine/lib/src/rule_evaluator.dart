import 'package:rule_engine/src/failure.dart';
import 'package:rule_engine/src/findings/finding.dart';
import 'package:rule_engine/src/findings/precedence.dart';
import 'package:rule_engine/src/models/rule.dart';
import 'package:rule_engine/src/resolve/candidate.dart';
import 'package:rule_engine/src/resolve/candidate_selection.dart';
import 'package:rule_engine/src/resolve/conflict.dart';
import 'package:rule_engine/src/resolve/evaluation_request.dart';
import 'package:rule_engine/src/resolve/zone_match.dart';
import 'package:rule_engine/src/verdict/resolution.dart';

/// Answers the question the whole product exists to answer.
///
/// The only public entry point. Everything E03/T03 to T09 delivered stays
/// exported for testing, but the composition lives here so `SPEC.md` §7.3's
/// stage order — which `catchlaw-rule-engine` rule 4 calls fixed — is readable
/// in one screen.
///
/// **The [Result] wrapper carries content defects and nothing else.** Every
/// legally meaningful outcome is an `Ok`: no rule recorded, species not listed,
/// no limit in the instrument and two rules disagreeing are all ANSWERS. Only a
/// row that does not say what it claims to say — a `minSize` with no number, a
/// bag limit with no period, an annual closure with no bounds — travels as a
/// `Failure`, because there is no legal statement to make about it. The shape
/// invites the opposite reading, so it is said here.
Result<Resolution> evaluate(EvaluationRequest request, Iterable<Rule> rows) {
  // Stage 0 — the species check, and it happens FIRST. Whether the id is in
  // this jurisdiction's list is a fact the reference database knows and the
  // engine does not, because the engine is handed rule rows and never queries.
  // Inferring it from an empty candidate list instead would conflate "we have
  // never heard of this fish" with "nobody has transcribed this zone yet", and
  // send the reader to the protected-species list for a fish that is simply not
  // covered here.
  if (request.species == null) {
    return Result<Resolution>.ok(
      UnknownSpecies(
        speciesId: request.speciesId,
        searched: request.searched,
        checkedOn: request.contentCheckedOn,
      ),
    );
  }

  // Stages 1 and 2 — select on jurisdiction, species, water type and
  // validFrom, then collapse superseded rows per (zone, lineage). validTo is
  // never a filter.
  final Result<List<Candidate>> selected = selectCandidates(request, rows);
  if (selected case Failure<List<Candidate>>(
    :final Exception exception,
    :final StackTrace? stackTrace,
  )) {
    return Result<Resolution>.error(exception, stackTrace);
  }
  final List<Candidate> candidates = (selected as Ok<List<Candidate>>).value;

  // Stage 3 — keep what applies here, strictest first, source order preserved.
  final List<Candidate> ranked = matchAndRank(request, candidates);
  if (ranked.isEmpty) {
    // The species exists here and no rule row covers it. NOT a permission, and
    // structurally incapable of becoming one: there is no path from this arm to
    // a Finding, and therefore none to a Decided.
    return Result<Resolution>.ok(
      NoRuleFound(
        searched: request.searched,
        checkedOn: request.contentCheckedOn,
        isExpired: false,
      ),
    );
  }

  // Stage 4 — a disagreement at the top rung is returned, never resolved.
  final List<Candidate> conflict = findConflict(ranked, request.zonePath);
  if (conflict.isNotEmpty) {
    return Result<Resolution>.ok(
      Ambiguous(
        rules: <Rule>[for (final Candidate c in conflict) c.rule],
        isExpired: conflict.any((Candidate c) => c.isExpired),
      ),
    );
  }

  // Stage 5 — collect the findings of every applicable rule, strictest first.
  final Candidate winner = ranked.first;
  final all = <Finding>[];
  for (final candidate in ranked) {
    final Result<List<Finding>> found = findingsFor(
      candidate.rule,
      landing: request.landing,
      tally: request.tally,
      on: request.on,
      isExpired: candidate.isExpired,
    );
    if (found case Failure<List<Finding>>(
      :final Exception exception,
      :final StackTrace? stackTrace,
    )) {
      return Result<Resolution>.error(exception, stackTrace);
    }
    all.addAll((found as Ok<List<Finding>>).value);
  }

  // A winning rule that produced no finding at all is an instrument that covers
  // this species here and records no limit — a cited, positive statement, and
  // a different thing from the absence T11 handles.
  if (all.isEmpty) {
    return Result<Resolution>.ok(
      NoLimitInInstrument(citation: winner.rule.citation, isExpired: winner.isExpired),
    );
  }

  // Stage 6 — rank once, here, and never again on any surface.
  final RankedFindings result = rankFindings(all);
  return Result<Resolution>.ok(Decided(headline: result.headline, secondary: result.secondary));
}
