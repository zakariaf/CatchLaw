import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show MeasurementMethod;

/// The one-word hint a species row carries — and it is a hint about a **rule**.
///
/// **Not `SpeciesHint`, and not in a `*species*.dart` file.**
/// `check_measurement.sh` check 6 fails a measurement method declared in one,
/// and it is right to: the same fish is measured differently in two countries,
/// so TL versus FL is a column on the rule row and never a property of the
/// species. A type named for the species would assert exactly the thing that
/// turns a legal fish into a fine.
///
/// **Numbers and enums only — no sentence, in any language.** D-7 keeps every
/// user-visible word out of the engine; this applies the same rule one layer
/// up, because a hint that carried its own English string would be a second
/// place a legal statement is authored, outside the ARB files and outside
/// `check_verdict_contract.sh`'s reach.
///
/// Sealed, so a `switch` that renders it cannot miss an arm: a hint nobody
/// drew is a row that silently says nothing about a protected species.
@immutable
sealed class RuleHint {
  const RuleHint();
}

/// The species may not be taken at all.
final class ProtectedHint extends RuleHint {
  /// Marks a protected species.
  const ProtectedHint();
}

/// A closure covers the day being asked about.
final class ClosedSeasonHint extends RuleHint {
  /// Marks a species inside a closed season.
  const ClosedSeasonHint();
}

/// A minimum size applies.
final class MinimumSizeHint extends RuleHint {
  /// Records [millimetres] measured by [method].
  const MinimumSizeHint({required this.millimetres, required this.method});

  /// Integer millimetres. Storage is always millimetres and the display unit is
  /// a separate decision (`SPEC.md` §9.5).
  final int millimetres;

  /// TL, FL, CW or SHL — inseparable from the number. A minimum with no method
  /// is a number the engine would have to guess at, and TL and FL differ by
  /// 6–9 cm on a Kanaad.
  final MeasurementMethod method;

  @override
  bool operator ==(Object other) =>
      other is MinimumSizeHint && other.millimetres == millimetres && other.method == method;

  @override
  int get hashCode => Object.hash(millimetres, method);
}

/// Nothing to say in one word.
///
/// **Not the same as "no rule recorded".** This says the row has no *headline*;
/// whether a rule exists at all is the resolution's answer, and merging the two
/// would turn silence into permission.
final class NoHint extends RuleHint {
  /// Marks a row with no headline.
  const NoHint();
}
