import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:rule_engine/rule_engine.dart' show Result;
import 'package:sqlite3/sqlite3.dart' show SqliteException;

/// Where a storage exception stops being an exception.
///
/// **One conversion, in one place, at the boundary.** A `SqliteException`
/// reaching a Notifier is a red screen where a sentence about the law should
/// be, and a `catch` per method is fifteen chances to get the mapping subtly
/// different.
///
/// It **logs before it converts**. CatchLaw cannot phone home, so the local
/// stack trace is the only diagnostic anybody will ever have; a boundary that
/// converted first would have thrown the original away by the time it decided
/// to record something.
final class StorageBoundary {
  /// Converts through [log], which defaults to a debug-only print.
  const StorageBoundary({this.log = logToDebugConsole});

  /// Called with the original error and trace, before any conversion.
  final void Function(Object error, StackTrace stackTrace) log;

  /// Runs [body], converting a storage failure into a [DataFailure].
  Future<Result<T>> guard<T>(Future<T> Function() body) async {
    try {
      return Result<T>.ok(await body());
    } on DataFailure catch (e, st) {
      // Already typed — a `DataNotFound` thrown by a repository's own lookup.
      // Logged all the same: a miss that keeps happening is a bug somewhere
      // upstream, and this is the only record of it.
      log(e, st);
      return Result<T>.error(e, st);
    } on SqliteException catch (e, st) {
      log(e, st);
      return Result<T>.error(dataFailureFor(e), st);
    } on StateError catch (e, st) {
      // drift signals a closed database with a StateError, which is an Error
      // and not an Exception. Catching an Error is normally wrong and is right
      // exactly here: this is the one place that knows drift's signal, and
      // letting it through would put "Bad state: Cannot operate on a closed
      // database" on a screen in Arabic.
      log(e, st);
      return Result<T>.error(const DataStoreUnavailable(), st);
    }
  }
}

/// The [DataFailure] for [e].
///
/// SQLITE_CONSTRAINT is 19, and every constraint subtype is `19 | (n << 8)` —
/// so the low byte of the extended code is what identifies the family, and
/// comparing the extended code to 19 directly misses all nineteen of them.
DataFailure dataFailureFor(SqliteException e) => (e.extendedResultCode & 0xFF) == 19
    ? DataConstraintViolated(field: offendingColumn(e.message))
    : const DataTransactionRolledBack();

/// The column [message] names, or [kUnknownColumn].
///
/// **Best-effort, and documented as such.** `SqliteException` exposes
/// `resultCode`, `extendedResultCode`, `message` and `explanation` and has no
/// column field at all, so the name is recovered from the message or it is not
/// recovered. The fallback is a constant rather than an empty string, so a
/// caller that renders it renders something a bug report can be opened about.
String offendingColumn(String message) {
  final RegExpMatch? match = _constraintMessage.firstMatch(message);
  return match?.group(1) ?? kUnknownColumn;
}

/// What [offendingColumn] returns when the message names nothing.
const String kUnknownColumn = 'unknown';

/// Logs to the debug console, and only in debug.
///
/// Named and public so a test can pass a spy in its place, and so the default
/// is visible rather than an anonymous closure in a constructor.
void logToDebugConsole(Object error, StackTrace stackTrace) {
  if (kDebugMode) debugPrint('data: $error\n$stackTrace');
}

/// The first identifier after the colon.
///
/// `UNIQUE constraint failed: saved_zone.zone_code` gives the qualified column;
/// `CHECK constraint failed: length_unit IN ('cm','mm','in'), constraint failed
/// (code 275)` gives `length_unit` and stops there, which is why this matches an
/// identifier rather than the rest of the line. `FOREIGN KEY constraint failed`
/// names nothing at all and falls back.
final RegExp _constraintMessage = RegExp(r'constraint failed:\s*([\w.]+)');
