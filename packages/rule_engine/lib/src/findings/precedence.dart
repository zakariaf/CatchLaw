import 'package:meta/meta.dart';
import 'package:rule_engine/src/failure.dart';
import 'package:rule_engine/src/findings/finding.dart';
import 'package:rule_engine/src/models/catch_tally.dart';
import 'package:rule_engine/src/models/closed_season.dart';
import 'package:rule_engine/src/models/landing.dart';
import 'package:rule_engine/src/models/rule.dart';

/// `SPEC.md` §7.3's precedence ladder, in one place.
///
/// The reason for each rung, because these are what stop somebody "fixing" the
/// order: **protected** is species-level, so no size or season applies to it at
/// all; a **closure** applies to every size; a slot **maximum** protects
/// spawners; a **minimum** applies to this individual; a **bag limit** is
/// per-person; a **vessel limit** is per-hull and therefore the widest scope,
/// and last.
///
/// An explicit map rather than `FindingKind.index`. The declaration order in
/// E03/T06 happens to match today, and that is exactly the coupling that breaks
/// silently the first time somebody adds a seventh kind in a tidy alphabetical
/// position. [precedenceOf] throws on a kind with no entry, so a new member
/// fails loudly instead of sorting to an arbitrary rung.
const Map<FindingKind, int> kFindingPrecedence = <FindingKind, int>{
  FindingKind.protected: 60,
  FindingKind.closedSeason: 50,
  FindingKind.maxSize: 40,
  FindingKind.minSize: 30,
  FindingKind.bagLimit: 20,
  FindingKind.vesselLimit: 10,
};

/// Where [kind] sits on the ladder. Higher outranks lower.
int precedenceOf(FindingKind kind) =>
    kFindingPrecedence[kind] ??
    (throw StateError('no precedence for $kind — add it to kFindingPrecedence'));

/// One headline finding and everything else, ranked.
@immutable
class RankedFindings {
  /// Built by [rankFindings].
  const RankedFindings({required this.headline, required this.secondary});

  /// The one thing at the top of the screen.
  final Finding headline;

  /// Every other finding, in the same ranked order.
  ///
  /// Passes and indeterminates INCLUDED. Non-deciding findings are not
  /// discarded: a closed-season headline still carries the size finding here so
  /// the rule table can print *Size rule — 45 cm total length, satisfied*
  /// beneath the closure. The stamp states one thing; the table states
  /// everything. This is not a list of "other failures".
  final List<Finding> secondary;
}

/// Ranks [findings] once, and names the headline.
///
/// **The ranking happens exactly once, here.** `catchlaw-rule-engine` rule 7
/// bans any surface from re-sorting, and names the failure: a protected sawfish
/// headlined as *below the minimum* reads as a size problem, solvable by
/// finding a bigger one. Different offence, different penalty, landed fish.
///
/// Sort by precedence, then by ARRIVAL INDEX — Dart's `List.sort` is unstable,
/// and a shifting order between two runs of one input is the same defect
/// E03/T04 guards against one layer up.
///
/// The headline is the highest-precedence `fails`, or failing that the
/// highest-precedence `passes`, or failing that the highest-precedence
/// `indeterminate`. Three tiers, one deterministic answer. The skill's own
/// example writes `failures.isNotEmpty ? failures.first : findings.first`, and
/// `findings.first` is whatever order the query happened to return — which
/// reintroduces exactly the query-order dependence this function exists to
/// remove.
///
/// `indeterminate` ranks last on purpose: a determinate pass is a STRONGER
/// statement than an open question, and headlining the question above it reads
/// as the app having failed. It still headlines when it is all there is,
/// because §4.1's no-rule-versus-no-data requirement means an open question must
/// be visible rather than hidden.
RankedFindings rankFindings(List<Finding> findings) {
  if (findings.isEmpty) {
    throw ArgumentError.value(findings, 'findings', 'cannot rank an empty list');
  }

  final indexed = <({Finding finding, int index})>[
    for (var i = 0; i < findings.length; i++) (finding: findings[i], index: i),
  ];
  indexed.sort((({Finding finding, int index}) a, ({Finding finding, int index}) b) {
    final int byPrecedence = precedenceOf(b.finding.kind).compareTo(precedenceOf(a.finding.kind));
    return byPrecedence != 0 ? byPrecedence : a.index.compareTo(b.index);
  });

  final ranked = <Finding>[for (final ({Finding finding, int index}) e in indexed) e.finding];

  final Finding headline = ranked.firstWhere(
    (Finding f) => f.outcome == FindingOutcome.fails,
    orElse: () => ranked.firstWhere(
      (Finding f) => f.outcome == FindingOutcome.passes,
      orElse: () => ranked.first,
    ),
  );

  return RankedFindings(
    headline: headline,
    secondary: <Finding>[
      for (final Finding f in ranked)
        if (!identical(f, headline)) f,
    ],
  );
}

/// Every finding [rule] produces, unranked.
///
/// The producers run in ladder order — protected, closure, size, limits — so
/// the pre-sort list is already close to sorted and a reader sees the precedence
/// twice. [rankFindings] still sorts; the order here is legibility, not a
/// contract.
///
/// This is where the `Result`-returning producers are unwrapped, so ONE content
/// defect fails the whole evaluation rather than producing a partial finding
/// list with a silent hole in it.
Result<List<Finding>> findingsFor(
  Rule rule, {
  required Landing? landing,
  required CatchTally? tally,
  required String on,
  required bool isExpired,
}) {
  final out = <Finding>[];

  if (rule.isProtected) {
    out.add(ProtectedFinding(citation: rule.citation, isExpired: isExpired));
  }

  for (final ClosedSeason season in rule.closedSeasons) {
    final Result<ClosedSeasonFinding> r = closedSeasonFinding(
      season,
      on,
      ruleId: rule.id,
      isExpired: isExpired,
    );
    switch (r) {
      case Failure<ClosedSeasonFinding>(:final Exception exception, :final StackTrace? stackTrace):
        return Result<List<Finding>>.error(exception, stackTrace);
      case Ok<ClosedSeasonFinding>(:final ClosedSeasonFinding value):
        out.add(value);
    }
  }

  out.addAll(sizeFindings(rule, landing, isExpired: isExpired));

  final Result<List<Finding>> limits = limitFindings(rule, tally, isExpired: isExpired);
  switch (limits) {
    case Failure<List<Finding>>(:final Exception exception, :final StackTrace? stackTrace):
      return Result<List<Finding>>.error(exception, stackTrace);
    case Ok<List<Finding>>(:final List<Finding> value):
      out.addAll(value);
  }

  return Result<List<Finding>>.ok(out);
}
