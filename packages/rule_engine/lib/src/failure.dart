/// The `Result` union of `FLUTTER_GUIDE.md` §1.6, vendored rather than
/// depended on.
///
/// `result_dart` exists and is named in the official docs; the guidance is
/// still to vendor the forty lines. For THIS package the argument is stronger
/// than for the app: `tools/content_builder/` compiles `rule_engine` under a
/// plain `dart run`, so every dependency this package takes is a dependency the
/// content build takes.
///
/// The error arm is called `Failure` and not `Error`, which costs divergence
/// from every doc snippet and buys back `dart:core`. A file importing an
/// unrenamed `Error` loses the one `AssertionError` and `StateError` extend.
library;

/// Either a value or the exception that stopped one being produced.
///
/// Sealed, so a `switch` over it with a missed arm is a compile error rather
/// than a silent fall-through — which is the entire reason for the type.
sealed class Result<T> {
  const Result();

  /// A successful outcome carrying [value].
  const factory Result.ok(T value) = Ok<T>;

  /// A failed outcome carrying [exception] and, where one was captured,
  /// [stackTrace].
  const factory Result.error(Exception exception, [StackTrace? stackTrace]) = Failure<T>;
}

/// The success arm.
final class Ok<T> extends Result<T> {
  /// Wraps [value].
  const Ok(this.value);

  /// The value produced.
  final T value;

  @override
  String toString() => 'Ok($value)';
}

/// The failure arm.
///
/// The error channel is `Exception` and deliberately not `Object`. A `TypeError`
/// from a bad cast escapes `Result`-based control flow entirely, so this type is
/// NOT crash-proofing — said here so nobody later widens the field believing
/// they are hardening something.
final class Failure<T> extends Result<T> {
  /// Wraps [exception], and [stackTrace] when one was captured.
  const Failure(this.exception, [this.stackTrace]);

  /// What went wrong.
  final Exception exception;

  /// Where it went wrong, when the construction site had a trace to hand.
  ///
  /// The reference implementation drops this. CatchLaw cannot phone home, so
  /// the local stack trace is all anybody gets, and there is no provider
  /// boundary inside this package at which to convert one later.
  final StackTrace? stackTrace;

  @override
  String toString() => 'Failure($exception)';
}
