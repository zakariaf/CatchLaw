import 'package:catchlaw/data/repositories/content_string_repository.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// An in-memory [ContentStringRepository], for the resolver's rows.
///
/// Bare `implements`, never `extends` with a `noSuchMethod` catch-all: adding a
/// method to the interface must be a compile error here, not a runtime surprise
/// three screens later (`testing-strategy` rule 5).
final class FakeContentStringRepository implements ContentStringRepository {
  /// Serves [rows], or fails every call with [failure] when one is given.
  FakeContentStringRepository(this.rows, {this.failure});

  /// key → locale → value.
  final Map<String, Map<String, String>> rows;

  /// What every call fails with, when the test is about a broken store rather
  /// than an absent key.
  final Exception? failure;

  /// How many times [valuesFor] has been called.
  ///
  /// The chain has four steps and one of them must not become four queries.
  /// A counter is the only thing that keeps that shape from regressing
  /// silently, because a per-step version passes every other row here.
  int callCount = 0;

  @override
  Future<Result<Map<String, String>>> valuesFor(String key) async {
    callCount++;
    if (failure != null) return Result<Map<String, String>>.error(failure!);
    return Result<Map<String, String>>.ok(rows[key] ?? const <String, String>{});
  }
}
