part of 'finding.dart';

/// Shared shape of the two size findings.
///
/// Millimetres and `int` throughout, so the comparison is integer comparison
/// and the whole class of floating-point boundary bugs —
/// `44.999999999999996 < 45.0` — does not exist on this path. The app divides
/// by ten for a `cm` display in whichever numeral system E06 resolves.
///
/// Rounding from the ruler's pixels to a whole millimetre belongs to
/// `catchlaw-measurement-ruler` and happens in E09, before a [Landing] is
/// constructed. By the time a value reaches here it is a decided integer, and
/// nothing here second-guesses it: a 446 mm measurement is stated as 446, never
/// nudged toward the threshold it sits beside.
sealed class SizeFinding extends Finding {
  const SizeFinding({
    required super.citation,
    required super.isExpired,
    required this.thresholdMm,
    required this.method,
    required this.measuredMm,
    required this.measuredMethod,
  });

  /// What the rule requires, in millimetres.
  final int thresholdMm;

  /// The method [thresholdMm] is expressed in.
  final MeasurementMethod method;

  /// What was measured, or `null` if the fish was not measured.
  final int? measuredMm;

  /// The method the reading was taken by, or `null` if there is no reading.
  final MeasurementMethod? measuredMethod;

  /// Whether the reading and the rule use different methods.
  ///
  /// A FIELD rather than a fourth [FindingOutcome]. The outcome the rest of the
  /// engine needs is "this decides nothing", which is exactly
  /// [FindingOutcome.indeterminate] — T09 must not headline it and T10 must not
  /// report it as a pass, and both follow from the existing member. A fourth
  /// member would force every switch in T09 and T10 to grow an arm that behaves
  /// identically to the one beside it.
  bool get methodMismatch => measuredMethod != null && measuredMethod != method;

  /// Whether a comparison can be made at all.
  bool get _comparable => measuredMm != null && !methodMismatch;
}

/// A minimum size, and whether the individual meets it.
final class MinimumSizeFinding extends SizeFinding {
  /// Built by [sizeFindings].
  const MinimumSizeFinding({
    required super.citation,
    required super.isExpired,
    required super.thresholdMm,
    required super.method,
    required super.measuredMm,
    required super.measuredMethod,
  });

  @override
  FindingKind get kind => FindingKind.minSize;

  /// Inclusive on the legal side: a fish exactly at the minimum MEETS it.
  ///
  /// Off-by-one here is not a rounding nicety — it is the difference between a
  /// legal fish and an offence at the one millimetre where the instrument is
  /// most precise, and it is the direction a `<=` typo fails in.
  @override
  FindingOutcome get outcome => !_comparable
      ? FindingOutcome.indeterminate
      : measuredMm! < thresholdMm
      ? FindingOutcome.fails
      : FindingOutcome.passes;
}

/// A maximum size, and whether the individual is within it.
final class MaximumSizeFinding extends SizeFinding {
  /// Built by [sizeFindings].
  const MaximumSizeFinding({
    required super.citation,
    required super.isExpired,
    required super.thresholdMm,
    required super.method,
    required super.measuredMm,
    required super.measuredMethod,
  });

  @override
  FindingKind get kind => FindingKind.maxSize;

  /// Inclusive on the legal side: a fish exactly at the maximum MEETS it.
  @override
  FindingOutcome get outcome => !_comparable
      ? FindingOutcome.indeterminate
      : measuredMm! > thresholdMm
      ? FindingOutcome.fails
      : FindingOutcome.passes;
}

/// The zero, one or two size findings [rule] produces for [landing].
///
/// **The method is compared, never converted.** `catchlaw-rule-engine` rule 12
/// gives the number: 65 cm fork length on a Kanaad is roughly 71 cm total
/// length. A conversion factor bridging the two would manufacture a pass at the
/// centimetre that costs AED 3,000, and it would be the app performing an
/// interpretation the carve-out bans outright. On a mismatch the finding is
/// emitted with `methodMismatch: true`, an indeterminate outcome, and NO
/// COMPARISON PERFORMED — both readings and both methods carried, so the app can
/// state two facts side by side and draw no conclusion.
///
/// A missing reading is indeterminate and never a pass. Silence is not
/// permission: a fisher who picks a species without measuring gets a page
/// stating the size rule and stating that nothing has been measured, not a
/// green stamp. Closure and protection still evaluate.
///
/// Returns a list rather than a nullable finding because §7.1 lets one row carry
/// both bounds — a slot limit, where `maxSize` outranks `minSize` in T09's
/// precedence because slot rules protect spawners. An empty list composes; a
/// nullable finding makes every caller write the same null check.
///
/// The `custom` method is safe to compare here only because stage 1 has already
/// filtered to one jurisdiction: §7.1 gives every custom method the same code,
/// so two jurisdictions' would compare equal. Epic risk 3 records the schema
/// change that would make it sound unconditionally.
List<Finding> sizeFindings(Rule rule, Landing? landing, {bool isExpired = false}) {
  final MeasurementMethod? method = rule.measurementMethod;
  if (method == null) return const <Finding>[];

  final int? measuredMm = landing?.lengthMm;
  final MeasurementMethod? measuredMethod = landing?.method;

  return <Finding>[
    // maxSize first, so a slot rule's two findings arrive in precedence order
    // even before T09 sorts them.
    if (rule.maxSizeMm case final int maxSizeMm)
      MaximumSizeFinding(
        citation: rule.citation,
        isExpired: isExpired,
        thresholdMm: maxSizeMm,
        method: method,
        measuredMm: measuredMm,
        measuredMethod: measuredMethod,
      ),
    if (rule.minSizeMm case final int minSizeMm)
      MinimumSizeFinding(
        citation: rule.citation,
        isExpired: isExpired,
        thresholdMm: minSizeMm,
        method: method,
        measuredMm: measuredMm,
        measuredMethod: measuredMethod,
      ),
  ];
}
