import 'package:catchlaw/data/repositories/rule_flag_repository.dart';
import 'package:catchlaw/domain/models/rule_flag.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

/// Why a flag was refused, or that it was written.
///
/// A typed outcome rather than a `bool`: "the note was empty" and "the write
/// failed" are different facts, and the screen says different things about
/// them.
enum FlagOutcome {
  /// The row is committed.
  recorded,

  /// There was nothing in the note. An empty row exports as noise and is
  /// indistinguishable from a mis-tap.
  emptyNote,

  /// The store refused the write.
  failed,
}

/// Validates a flag and records it.
///
/// Holds no `BuildContext`, no clock and no widget: the timestamp arrives as a
/// parameter, so a row's `created_at` is a value a test can state rather than
/// whatever the machine's wall clock said when the suite ran.
@immutable
class FlagRuleViewModel {
  /// Writes through [repository].
  const FlagRuleViewModel(this.repository);

  /// Where the flag goes.
  final RuleFlagRepository repository;

  /// Records [note] against [ruleId], stamped [now].
  ///
  /// The note is trimmed before it is judged AND before it is stored, because
  /// a whitespace-only note is the case a first regex gets wrong and it is
  /// exactly what a fat finger on a wet screen produces.
  Future<FlagOutcome> save({
    required int ruleId,
    required String note,
    required String now,
    String? citationRef,
  }) async {
    final String trimmed = note.trim();
    if (trimmed.isEmpty) return FlagOutcome.emptyNote;

    final Result<void> written = await repository.flag(
      RuleFlagDraft(
        ruleId: ruleId,
        note: trimmed,
        createdAt: now,
        // Carried through unchanged: a flag against the wrong rule row is worse
        // than no flag at all.
        citationRef: citationRef,
      ),
    );
    return switch (written) {
      Ok<void>() => FlagOutcome.recorded,
      Failure<void>() => FlagOutcome.failed,
    };
  }
}
