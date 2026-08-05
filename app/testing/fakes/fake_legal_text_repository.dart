import 'package:catchlaw/data/repositories/legal_text_repository.dart';
import 'package:catchlaw/domain/models/legal_article.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// An in-memory [LegalTextRepository].
final class FakeLegalTextRepository implements LegalTextRepository {
  /// Serves [articles], or fails every call with [failure].
  FakeLegalTextRepository(this.articles, {this.failure});

  /// citation id → the articles recorded against it, in reading order.
  final Map<int, List<LegalArticle>> articles;

  /// What every call fails with, when the test is about a store that broke.
  final Exception? failure;

  /// Every citation id this repository was asked for, in order.
  final List<int> asked = <int>[];

  @override
  Future<Result<List<LegalArticle>>> byCitation(int citationId) async {
    asked.add(citationId);
    if (failure != null) return Result<List<LegalArticle>>.error(failure!);
    // An empty list rather than a failure for a citation nobody transcribed:
    // §7.1 lets one citation carry no article text, and that absence is a real
    // answer the reader is entitled to see stated.
    return Result<List<LegalArticle>>.ok(articles[citationId] ?? const <LegalArticle>[]);
  }
}
