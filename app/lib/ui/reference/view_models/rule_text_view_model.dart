import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/legal_article.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

/// The verbatim articles behind one citation, in reading order.
///
/// A `FutureProvider.family` and not a `Notifier`: nothing on S13 mutates the
/// law. The page is read, and the two controls on it — the entry line and the
/// article chips — narrow what is already in hand rather than asking the
/// database a second question.
///
/// **A failed read throws rather than returning an empty list.** An empty list
/// is a statement about the pack — "this copy transcribed no text for this
/// instrument" — and making it when the device could not read the file is the
/// app inventing the absence of a law, which is the same defect as inventing
/// one.
final legalArticlesProvider = FutureProvider.autoDispose.family<List<LegalArticle>, int>((
  Ref ref,
  int citationId,
) async {
  final Result<List<LegalArticle>> articles = await ref
      .read(legalTextRepositoryProvider)
      .byCitation(citationId);
  return switch (articles) {
    Ok<List<LegalArticle>>(:final List<LegalArticle> value) => value,
    Failure<List<LegalArticle>>(:final Exception exception) => throw exception,
  };
});
