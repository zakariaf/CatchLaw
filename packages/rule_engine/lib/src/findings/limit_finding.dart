part of 'finding.dart';

/// A per-person limit, and how much has been recorded against it.
///
/// The boundary is the LAST PERMITTED VALUE: `bagLimit = 6` means six are
/// permitted, so `fails` is `recorded > limit`, strictly. The margin sentence
/// `catchlaw-verdict-contract` rule 3 requires — *Above the daily bag — 9
/// recorded, limit 6* — is only correct under that reading.
final class BagLimitFinding extends Finding {
  /// Built by [limitFindings].
  const BagLimitFinding({
    required super.citation,
    required super.isExpired,
    required this.limit,
    required this.unit,
    required this.period,
    required this.recorded,
  });

  /// What the instrument permits, in [unit].
  final int limit;

  /// Whether [limit] counts individuals or kilograms.
  final LimitUnit unit;

  /// The period [limit] applies over, taken from the rule.
  final LimitPeriod period;

  /// What has been recorded over [period], or `null` if nothing was.
  ///
  /// In individuals when [unit] is [LimitUnit.count], and in GRAMS when it is
  /// [LimitUnit.kg] — so the comparison against `limit * 1000` stays integer.
  final int? recorded;

  @override
  FindingKind get kind => FindingKind.bagLimit;

  /// Indeterminate when nothing has been recorded for this period.
  ///
  /// Not a pass. Reporting a bag limit as satisfied because the app holds no
  /// data is the same error class as reporting an untranscribed species as
  /// legal, and §4.5 makes the catch log something the fisher opts into — the
  /// app records nothing about him by default.
  @override
  FindingOutcome get outcome {
    final int? recorded = this.recorded;
    if (recorded == null) return FindingOutcome.indeterminate;
    final int threshold = unit == LimitUnit.kg ? limit * 1000 : limit;
    return recorded > threshold ? FindingOutcome.fails : FindingOutcome.passes;
  }
}

/// A per-vessel count, and how much has been recorded against it.
///
/// Carries NO period, because `SPEC.md` §7.1 gives `vessel_limit` neither a unit
/// column nor a period column while `bag_limit` gets both. The engine may not
/// state a period an instrument did not give it — that would be the app
/// interpreting, which `the-five-part-carve-out.md` part 4 forbids. E10 prints
/// the transcribed wording from the rule's `notes_key` beside it instead of
/// paraphrasing.
final class VesselLimitFinding extends Finding {
  /// Built by [limitFindings].
  const VesselLimitFinding({
    required super.citation,
    required super.isExpired,
    required this.limit,
    required this.recorded,
  });

  /// What the instrument permits, as a count.
  final int limit;

  /// What has been recorded against this vessel, or `null` if nothing was.
  final int? recorded;

  @override
  FindingKind get kind => FindingKind.vesselLimit;

  @override
  FindingOutcome get outcome {
    final int? recorded = this.recorded;
    if (recorded == null) return FindingOutcome.indeterminate;
    return recorded > limit ? FindingOutcome.fails : FindingOutcome.passes;
  }
}

/// The zero, one or two limit findings [rule] produces for [tally].
///
/// **The period comes from the rule and is never defaulted.**
/// `resolution-algorithm.md` calls the bag limit "per-person, per-day" as the
/// common case, and defaulting an absent period to `day` would compare a
/// Galician SEASON quota against a single day's tally — passing on every day of
/// a season it has already exhausted. A false pass, at scale, in the direction
/// that costs the fisher. A `bagLimit` with no period is a content defect.
///
/// **The tally is what has already been recorded, not what is in hand.** Nothing
/// here adds one for the fish being checked: whether that fish is kept is a
/// decision the fisher makes and the app does not model, and adding it would
/// turn the finding into a prediction about an action — the advisory shape the
/// carve-out excludes. E13 records the catch, and the next check states the new
/// fact.
Result<List<Finding>> limitFindings(Rule rule, CatchTally? tally, {required bool isExpired}) {
  final out = <Finding>[];

  if (rule.bagLimit case final int limit) {
    final LimitPeriod? period = rule.bagLimitPeriod;
    final LimitUnit unit = rule.bagLimitUnit ?? LimitUnit.count;
    if (period == null) {
      return Result<List<Finding>>.error(MalformedRule.noBagLimitPeriod(ruleId: rule.id));
    }
    out.add(
      BagLimitFinding(
        citation: rule.citation,
        isExpired: isExpired,
        limit: limit,
        unit: unit,
        period: period,
        recorded: unit == LimitUnit.kg ? tally?.gramsFor(period) : tally?.countFor(period),
      ),
    );
  }

  if (rule.vesselLimit case final int limit) {
    out.add(
      VesselLimitFinding(
        citation: rule.citation,
        isExpired: isExpired,
        limit: limit,
        recorded: tally?.vesselCount,
      ),
    );
  }

  return Result<List<Finding>>.ok(out);
}
