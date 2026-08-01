/// The sealed `Finding` hierarchy.
///
/// The subtypes are `part`s of this library rather than separate libraries,
/// because a `sealed` class can only be extended inside the library that
/// declares it — which is exactly the property that makes a `switch` over
/// [Finding] exhaustive, and the reason E03/T10 can close the union at all. One
/// file per subtype keeps FLUTTER_GUIDE.md §6.2's split; `part` is what lets
/// both hold at once.
library;

import 'package:meta/meta.dart';
import 'package:rule_engine/src/engine_exception.dart';
import 'package:rule_engine/src/failure.dart';
import 'package:rule_engine/src/models/catch_tally.dart';
import 'package:rule_engine/src/models/citation.dart';
import 'package:rule_engine/src/models/closed_season.dart';
import 'package:rule_engine/src/models/landing.dart';
import 'package:rule_engine/src/models/measurement_method.dart';
import 'package:rule_engine/src/models/rule.dart';
import 'package:rule_engine/src/season/season_window.dart';

part 'closed_season_finding.dart';
part 'limit_finding.dart';
part 'protected_finding.dart';
part 'size_finding.dart';

/// What a finding is about, in `SPEC.md` §7.3's six kinds.
///
/// The precedence integers are NOT here — E03/T09 publishes them beside the
/// enum in one table, and relying on declaration order instead would make a
/// reordering of this list a silent change to which offence gets named.
enum FindingKind {
  /// The species may not be taken at all.
  protected,

  /// A closure is in force.
  closedSeason,

  /// The individual is above a maximum size.
  maxSize,

  /// The individual is below a minimum size.
  minSize,

  /// A per-person limit.
  bagLimit,

  /// A per-vessel limit.
  vesselLimit,
}

/// Whether a rule is met, breached, or unanswerable on the facts to hand.
enum FindingOutcome {
  /// The rule is met.
  passes,

  /// The rule is breached.
  fails,

  /// The question cannot be answered from what the fisher supplied.
  ///
  /// `resolution-algorithm.md` governs what this means downstream, and it is
  /// worth carrying here: anything marked indeterminate prints as an OPEN
  /// QUESTION in the rule table and NEVER as a pass. An unmeasured fish has not
  /// met the minimum; nobody has checked.
  indeterminate,
}

/// One rule that fired, as numbers and enums.
///
/// The base carries exactly two fields, and [citation] being one of them is
/// what makes invariant 3 structural rather than asserted: there is no way to
/// write a subclass that forgets it, because this constructor demands it. A
/// nullable citation anywhere in this package is a defect
/// `check_app_invariants.sh` check 4 greps for.
///
/// No subclass holds a user-visible sentence in any language (D-7). E06 and E10
/// turn these values into words, in six locales.
@immutable
sealed class Finding {
  /// Every subtype supplies both, because both are required of every finding.
  const Finding({required this.citation, required this.isExpired});

  /// The instrument this finding rests on.
  final Citation citation;

  /// Whether that instrument had lapsed on the evaluation date.
  ///
  /// Carried through from the candidate, never recomputed here. An expired
  /// instrument is still evaluated and still shown; this is the flag E10's
  /// ochre bar reads.
  final bool isExpired;

  /// Which of the six kinds this is.
  FindingKind get kind;

  /// Met, breached, or unanswerable.
  FindingOutcome get outcome;
}
