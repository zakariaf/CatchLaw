import 'package:meta/meta.dart';

/// A doubt the fisher recorded about a rule, before it was written.
///
/// **A note about the TRANSCRIPTION, never a correction to the law.** Flagging
/// records that the reader believes the app's copy of an instrument is wrong;
/// it changes no number, alters no verdict and is not evidence of anything but
/// his disagreement. E17 exports it so somebody can check the gazette.
@immutable
class RuleFlagDraft {
  /// Records a doubt about [ruleId].
  const RuleFlagDraft({
    required this.ruleId,
    required this.note,
    required this.createdAt,
    this.citationRef,
  });

  /// The `rule.id` the reader is disputing.
  final int ruleId;

  /// What he says is wrong, in his own words.
  final String note;

  /// When, ISO-8601, from an injected clock.
  final String createdAt;

  /// The citation as TEXT — `Ministerial Decision 580/2015, Art. 3`.
  ///
  /// Text and not a foreign key on purpose: a content update replaces the pack
  /// wholesale and can renumber the rows, and a note pointing at a row id that
  /// no longer means what it meant is a note nobody can read. The words survive
  /// the renumbering.
  final String? citationRef;
}

/// A recorded flag, as stored.
@immutable
class RuleFlag {
  /// One row of `rule_flag`.
  const RuleFlag({
    required this.id,
    required this.ruleId,
    required this.note,
    required this.createdAt,
    this.citationRef,
  });

  /// The row id.
  final int id;

  /// The rule disputed.
  final int ruleId;

  /// The reader's words.
  final String note;

  /// When it was recorded, ISO-8601.
  final String createdAt;

  /// The citation as text.
  final String? citationRef;
}
