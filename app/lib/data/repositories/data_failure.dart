import 'package:meta/meta.dart';

/// Why a repository could not answer.
///
/// A sealed family, so a new failure is a compile error at every `switch`, and
/// each arm carries **parameters** rather than a formatted sentence: this layer
/// holds no user-visible wording, and the screen that renders it must be free to
/// say it in six languages.
@immutable
sealed class DataFailure implements Exception {
  const DataFailure();

  /// The stable identifier a log line and a support conversation both name.
  String get code;
}

/// The row is not there.
///
/// **Not the same as a rule that says nothing.** "No rule recorded" is a
/// verdict the engine returns with citations; this is a lookup that found
/// nothing, and the two must never render the same way.
final class DataNotFound extends DataFailure {
  /// [entity] with id [id] does not exist.
  const DataNotFound({required this.entity, required this.id});

  /// `catch`, `trip`, `species`.
  final String entity;

  /// What was asked for.
  final String id;

  @override
  String get code => 'data.not_found';

  @override
  String toString() => '$code($entity/$id)';
}

/// The write violated a `CHECK`, a `UNIQUE` or a foreign key.
final class DataConstraintViolated extends DataFailure {
  /// [field] is what the storage layer refused.
  const DataConstraintViolated({required this.field});

  /// The column or constraint SQLite named.
  final String field;

  @override
  String get code => 'data.constraint_violated';

  @override
  String toString() => '$code($field)';
}

/// The database could not be reached at all.
///
/// The one failure the user can act on directly — usually by restarting, and
/// occasionally by freeing space.
final class DataStoreUnavailable extends DataFailure {
  /// The store is not open.
  const DataStoreUnavailable();

  @override
  String get code => 'data.store_unavailable';

  @override
  String toString() => code;
}

/// The transaction rolled back, so **nothing** in it happened.
///
/// Distinct from [DataConstraintViolated] on purpose: the caller needs to know
/// that the second half of a pair did not run either, because a tally that
/// disagrees with the log it was counted from is the failure this whole layer
/// is arranged to prevent.
final class DataTransactionRolledBack extends DataFailure {
  /// Nothing in the transaction was applied.
  const DataTransactionRolledBack();

  @override
  String get code => 'data.transaction_rolled_back';

  @override
  String toString() => code;
}
