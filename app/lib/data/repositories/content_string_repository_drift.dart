import 'package:catchlaw/data/daos/reference/content_string_dao.dart';
import 'package:catchlaw/data/repositories/content_string_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// [ContentStringRepository] over the read-only `reference.db` (D-6).
///
/// Nothing here writes. The handle is opened read-only, so a write would fail
/// at the open rather than at the statement, and the shipped file's sha256
/// would stop matching what the build recorded.
final class ContentStringRepositoryDrift implements ContentStringRepository {
  /// Reads strings out of [db].
  ContentStringRepositoryDrift(this.db, {this.boundary = const StorageBoundary()})
    : _strings = ContentStringDao(db);

  /// The rule book.
  final ReferenceDatabase db;

  /// Where a storage exception becomes a `DataFailure`.
  final StorageBoundary boundary;

  final ContentStringDao _strings;

  @override
  Future<Result<Map<String, String>>> valuesFor(String key) =>
      boundary.guard(() => _strings.valuesFor(key));
}
