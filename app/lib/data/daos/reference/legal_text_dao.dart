import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/tables/reference/legal_text.dart';
import 'package:drift/drift.dart';

part 'legal_text_dao.g.dart';

/// Reads the verbatim law, and searches it.
@DriftAccessor(tables: <Type>[LegalTexts])
class LegalTextDao extends DatabaseAccessor<ReferenceDatabase> with _$LegalTextDaoMixin {
  /// Reads legal text from [db].
  LegalTextDao(super.db);

  /// Articles matching [normalisedQuery], through `legal_text_fts`.
  ///
  /// The query must already be folded by the engine's `normaliseSpeciesTerm`:
  /// the index is over `body_norm`, which the content build wrote with that
  /// exact function, and FTS5's `unicode61` cannot fold Arabic orthographic
  /// variants at all. A query folded any other way returns nothing — silently,
  /// which reads as "the text is not in the app".
  Future<List<LegalTextRow>> search(String normalisedQuery, {int limit = 50}) async {
    if (normalisedQuery.trim().isEmpty) return const <LegalTextRow>[];
    final List<QueryRow> rows = await customSelect(
      'SELECT t.* FROM legal_text_fts f '
      'JOIN legal_text t ON t.id = f.rowid '
      'WHERE f.body_norm MATCH ?1 '
      'ORDER BY t.jurisdiction_id, t.sort_order LIMIT ?2',
      variables: <Variable<Object>>[Variable<String>(normalisedQuery), Variable<int>(limit)],
      readsFrom: <ResultSetImplementation<HasResultSet, Object>>{legalTexts},
    ).get();
    return rows.map((QueryRow r) => legalTexts.map(r.data)).toList();
  }

  /// Every article of one jurisdiction in one locale, in reading order.
  Future<List<LegalTextRow>> articlesFor(int jurisdictionId, String locale) =>
      (select(legalTexts)
            ..where(
              ($LegalTextsTable t) =>
                  t.jurisdictionId.equals(jurisdictionId) & t.locale.equals(locale),
            )
            ..orderBy(<OrderClauseGenerator<$LegalTextsTable>>[
              ($LegalTextsTable t) => OrderingTerm(expression: t.sortOrder),
            ]))
          .get();

  /// The languages this jurisdiction's law actually exists in.
  ///
  /// §9.6: bundled law is single-locale, in the language the authority
  /// published it. S13 renders a language-availability notice from this rather
  /// than falling back — the §9.2 chain applies to `content_string` only and
  /// never silently substitutes a different language of law.
  Future<List<String>> localesAvailable(int jurisdictionId) async {
    final List<LegalTextRow> rows = await (select(
      legalTexts,
    )..where(($LegalTextsTable t) => t.jurisdictionId.equals(jurisdictionId))).get();
    return rows.map((LegalTextRow r) => r.locale).toSet().toList()..sort();
  }
}
