import 'package:catchlaw/domain/models/legal_article.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// The verbatim law, by the citation it hangs off.
///
/// One method, because the result screen asks exactly one question: what does
/// the instrument behind this finding actually say. E15 adds the search and the
/// article navigation; this is the seam it will grow from.
abstract interface class LegalTextRepository {
  /// Every article recorded against [citationId], in reading order.
  @useResult
  Future<Result<List<LegalArticle>>> byCitation(int citationId);
}
