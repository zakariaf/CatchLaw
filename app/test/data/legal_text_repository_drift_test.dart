import 'dart:io';

import 'package:catchlaw/data/repositories/legal_text_repository_drift.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/legal_article.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Ok, Result;

import '../../testing/fixtures/reference_fixture.dart';

List<LegalArticle> _unwrap(Result<List<LegalArticle>> result) =>
    (result as Ok<List<LegalArticle>>).value;

void main() {
  if (!builtReferenceExists()) {
    // Skipped out loud. A green tick meaning "I found nothing" and one meaning
    // "I looked at nothing" are the same pixel.
    test('the built reference.db is present', () {
      markTestSkipped('run `dart run content_builder:build` first');
    }, skip: true);
    return;
  }

  late ReferenceDatabase db;
  late File file;
  late DriftLegalTextRepository repo;

  setUp(() async {
    (db, file) = await openBuiltReference();
    repo = DriftLegalTextRepository(db);
    addTearDown(() async {
      await db.close();
      if (file.parent.existsSync()) file.parent.deleteSync(recursive: true);
    });
  });

  test('DriftLegalTextRepository returns an empty list for a citation with no text', () async {
    // A citation whose text was not transcribed is not a citation that does not
    // exist, and the two are not merged into one word here either.
    expect(_unwrap(await repo.byCitation(999999)), isEmpty);
  });

  test('DriftLegalTextRepository returns articles in reading order', () async {
    for (var citationId = 1; citationId <= 8; citationId++) {
      final List<LegalArticle> articles = _unwrap(await repo.byCitation(citationId));
      if (articles.isEmpty) continue;
      final List<int> order = articles.map((LegalArticle a) => a.sortOrder).toList();
      expect(order, List<int>.from(order)..sort(), reason: 'citation $citationId');
      for (final article in articles) {
        // Single-locale by construction: bundled law exists only in the
        // language the authority published it in (§9.6).
        expect(article.locale, isNotEmpty, reason: 'citation $citationId');
        expect(article.body, isNotEmpty, reason: 'citation $citationId');
      }
      return;
    }
    markTestSkipped('the shipped pack transcribes no legal_text row yet');
  });
}
