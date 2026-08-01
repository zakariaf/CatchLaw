// A7 runs against the EMITTED database, not the in-memory rows.
//
// Recomputing from the model would prove the model consistent with itself and
// say nothing about what SQLite stored: a truncated column, a TEXT affinity
// surprise or an emit-order bug would all pass. The failure this catches is
// silent — a search that returns nothing reads as "the species is not in the
// app", and there is no error state to notice.

import 'package:content_builder/src/assert/a07_norm_parity.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/normalise/norm_columns.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../normalise/norm_columns_test.dart' show kHamour, kHamourWithArticle;

/// A database holding just enough of §7.1 to exercise the parity pass.
Database emittedWith({
  required List<({String name, String searchNorm})> names,
  List<({String body, String bodyNorm})> texts = const <({String body, String bodyNorm})>[],
}) {
  final Database db = sqlite3.openInMemory()
    ..execute('CREATE TABLE species_name (id INTEGER PRIMARY KEY, name TEXT, search_norm TEXT)')
    ..execute('CREATE TABLE legal_text (id INTEGER PRIMARY KEY, body TEXT, body_norm TEXT)');
  for (final n in names) {
    db.execute('INSERT INTO species_name (name, search_norm) VALUES (?, ?)', <Object?>[
      n.name,
      n.searchNorm,
    ]);
  }
  for (final t in texts) {
    db.execute('INSERT INTO legal_text (body, body_norm) VALUES (?, ?)', <Object?>[
      t.body,
      t.bodyNorm,
    ]);
  }
  return db;
}

void main() {
  group('NormParityAssertion', () {
    test('accepts a database whose keys the shared normaliser reproduces', () {
      final Database db = emittedWith(
        names: <({String name, String searchNorm})>[
          (name: 'Ameixa babosa', searchNorm: 'ameixa babosa'),
        ],
        texts: <({String body, String bodyNorm})>[
          (body: 'Talla mínima', bodyNorm: NormColumns.bodyNorm('Talla mínima')),
        ],
      );
      addTearDown(db.close);

      expect(const NormParityAssertion().verify(db), isEmpty);
    });

    test('reports A7 when a stored search_norm differs from the recomputed value', () {
      // What a divergent normaliser looks like in practice: the build folds
      // tatweel and the app does not, so كنعـد typed by a fisher whose keyboard
      // inserts kashida matches zero rows.
      final Database db = emittedWith(
        names: <({String name, String searchNorm})>[
          (name: 'Ameixa babosa', searchNorm: 'ameixa-babosa'),
        ],
      );
      addTearDown(db.close);

      final List<Failure> failures = const NormParityAssertion().verify(db).toList();

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A7');
      expect(failures.single.message, contains('species_name.search_norm'));
    });

    test('ar - accepts an article-stripped row', () {
      // T07 emits a second row carrying the stripped key. A strict
      // normaliseSpeciesTerm(name) comparison would fail every Arabic name that
      // carries ال — which is most of them, because instruments write the
      // article.
      final Database db = emittedWith(
        names: <({String name, String searchNorm})>[
          (name: kHamourWithArticle, searchNorm: kHamourWithArticle),
          (name: kHamourWithArticle, searchNorm: kHamour),
        ],
      );
      addTearDown(db.close);

      expect(const NormParityAssertion().verify(db), isEmpty);
    });

    test('ar - reports A7 for a key that is neither form of the name', () {
      final Database db = emittedWith(
        names: <({String name, String searchNorm})>[
          (name: kHamourWithArticle, searchNorm: 'hamour'),
        ],
      );
      addTearDown(db.close);

      expect(const NormParityAssertion().verify(db), hasLength(1));
    });

    test('reports A7 when a stored body_norm differs from the recomputed value', () {
      // Both columns, not just the famous one. The FTS index is built over
      // body_norm, so a divergence here makes the Arabic legal-text search
      // return nothing.
      final Database db = emittedWith(
        names: const <({String name, String searchNorm})>[],
        texts: <({String body, String bodyNorm})>[(body: 'Talla mínima', bodyNorm: 'Talla mínima')],
      );
      addTearDown(db.close);

      final List<Failure> failures = const NormParityAssertion().verify(db).toList();

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('legal_text.body_norm'));
    });

    test('names the row id so the offending row can be found', () {
      final Database db = emittedWith(
        names: <({String name, String searchNorm})>[
          (name: 'Ameixa babosa', searchNorm: 'ameixa babosa'),
          (name: 'Almeja babosa', searchNorm: 'wrong'),
        ],
      );
      addTearDown(db.close);

      expect(const NormParityAssertion().verify(db).single.line, 2);
    });

    test('covers every *_norm column in §7.1', () {
      // A column added later must not be silently unparited.
      expect(kNormColumns, hasLength(2));
      expect(kNormColumns.map((NormColumn c) => '${c.table}.${c.norm}'), <String>[
        'species_name.search_norm',
        'legal_text.body_norm',
      ]);
    });

    test('.id is A7', () {
      expect(const NormParityAssertion().id, 'A7');
    });
  });
}
