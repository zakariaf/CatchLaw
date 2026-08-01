/// Unchecked accessors for [Result], for tests only.
///
/// `FLUTTER_GUIDE.md` §1.6 warning 4: the official docs show `result.asOk.value`
/// in production-looking code, and the real Compass app keeps it in
/// `testing/utils/result.dart` instead. It is an unchecked cast that throws on
/// the error path, which defeats the entire point of a type whose job is to make
/// the error path visible to the compiler.
///
/// This lives OUTSIDE `lib/`, so `tools/content_builder/` — which imports the
/// package, not this directory — cannot reach it. `@visibleForTesting` in `lib/`
/// would not do: the annotation is advisory, the analyzer only warns outside the
/// declaring package, and the content builder is outside it.
///
/// A test asserts `lib/` contains no `asOk`.
library;

import 'package:rule_engine/rule_engine.dart';

/// Unchecked casts to one arm of a [Result].
extension ResultTestAccessors<T> on Result<T> {
  /// This result as an [Ok], throwing if it is a [Failure].
  Ok<T> get asOk => this as Ok<T>;

  /// This result as a [Failure], throwing if it is an [Ok].
  Failure<T> get asFailure => this as Failure<T>;
}
