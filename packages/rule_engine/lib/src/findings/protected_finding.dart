part of 'finding.dart';

/// The species may not be taken at all under this rule.
///
/// `is_protected` is a boolean column with no threshold, no method and no
/// period, so there is no arithmetic here — but it is the top rung of the
/// precedence ladder and getting it wrong is the failure
/// `catchlaw-rule-engine` rule 7 names: a protected sawfish headlined as
/// *below the minimum* reads to the fisher as a size problem, solvable by
/// finding a bigger one.
///
/// A rule with the flag CLEAR produces no finding at all rather than a passing
/// one. "This species is not protected" is not a statement any instrument makes
/// about every species in it, and printing it would be the app manufacturing a
/// fact.
final class ProtectedFinding extends Finding {
  /// Built by [findingsFor], and only when the flag is set.
  const ProtectedFinding({required super.citation, required super.isExpired});

  @override
  FindingKind get kind => FindingKind.protected;

  /// Always [FindingOutcome.fails]: the finding exists only when it is true.
  @override
  FindingOutcome get outcome => FindingOutcome.fails;
}
