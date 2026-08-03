import 'package:catchlaw/data/daos/reference/legal_text_dao.dart';
import 'package:catchlaw/data/repositories/legal_text_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/legal_article.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// [LegalTextRepository] over the read-only `reference.db` (D-6).
final class DriftLegalTextRepository implements LegalTextRepository {
  /// Reads articles out of [db].
  DriftLegalTextRepository(this.db, {this.boundary = const StorageBoundary()})
    : _legalText = LegalTextDao(db);

  /// The rule book.
  final ReferenceDatabase db;

  /// Where a storage exception becomes a `DataFailure`.
  final StorageBoundary boundary;

  final LegalTextDao _legalText;

  @override
  Future<Result<List<LegalArticle>>> byCitation(int citationId) => boundary.guard(() async {
    final List<LegalTextRow> rows = await _legalText.byCitation(citationId);
    return <LegalArticle>[
      for (final LegalTextRow row in rows)
        LegalArticle(
          locale: row.locale,
          body: row.body,
          sortOrder: row.sortOrder,
          articleRef: row.articleRef,
        ),
    ];
  });
}
