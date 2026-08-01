/// A defect in the authored content, as distinct from a legal statement about it.
///
/// The line this type draws is the one `catchlaw-rule-engine` rule 8 insists on:
///
/// | Situation | Channel |
/// |---|---|
/// | No rule row for this species here | `Ok(NoRuleFound(...))` |
/// | Species not in this jurisdiction's list | `Ok(UnknownSpecies(...))` |
/// | The instrument records no limit | `Ok(NoLimitInInstrument(...))` |
/// | Two equally specific rules disagree | `Ok(Ambiguous(...))` |
/// | A `minSize` rule with a null `minSizeMm` | `Failure(MalformedRule)` |
/// | An `annual` season with a null `startMonth` | `Failure(MalformedSeason)` |
///
/// The first four are answers. The last two are not: there is no legal
/// statement to make about a row that does not say what it claims to say, and
/// inventing one is how a content bug becomes a wrong verdict on a phone.
///
/// Sealed with exactly two subclasses, so a third is a visible decision and
/// every `switch` over it fails to compile until somebody handles it.
sealed class EngineException implements Exception {
  const EngineException();

  /// The authored row that produced the defect.
  ///
  /// A content defect is useless to E04's build assertions unless it names the
  /// row a human has to go and fix.
  int get ruleId;

  /// The field that was missing or unusable.
  String get field;
}

/// A `rule` row that does not carry what its own shape requires.
final class MalformedRule extends EngineException {
  /// Names the offending [ruleId] and [field].
  const MalformedRule({required this.ruleId, required this.field});

  @override
  final int ruleId;

  @override
  final String field;

  @override
  String toString() => 'MalformedRule(rule $ruleId, field $field)';
}

/// A `closed_season` row whose bounds do not match its recurrence.
final class MalformedSeason extends EngineException {
  /// Names the parent [ruleId] and the offending [field].
  const MalformedSeason({required this.ruleId, required this.field});

  @override
  final int ruleId;

  @override
  final String field;

  @override
  String toString() => 'MalformedSeason(rule $ruleId, field $field)';
}
