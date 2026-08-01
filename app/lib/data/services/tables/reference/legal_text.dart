import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `legal_text` — the article as the authority published it.
///
/// **Single-locale.** §9.6: bundled law exists only in the language(s) the
/// authority published it in. We do not translate legal text.
///
/// `body_norm` carries the same fold as `species_name.search_norm`, because
/// FTS5's `unicode61` does **not** fold Arabic orthographic variants — the
/// tokeniser alone cannot make `الهامور` and `هامور` meet.
@DataClassName('LegalTextRow')
class LegalTexts extends Table {
  @override
  String get tableName => 'legal_text';

  IntColumn get id => integer()();

  IntColumn get jurisdictionId =>
      integer().named('jurisdiction_id').customConstraint('NOT NULL REFERENCES jurisdiction(id)')();

  IntColumn get citationId =>
      integer().named('citation_id').customConstraint('NOT NULL REFERENCES citation(id)')();

  TextColumn get locale => text()();

  TextColumn get articleRef => text().named('article_ref').nullable()();

  TextColumn get body => text()();

  TextColumn get bodyNorm => text().named('body_norm')();

  IntColumn get sortOrder => integer().named('sort_order')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
