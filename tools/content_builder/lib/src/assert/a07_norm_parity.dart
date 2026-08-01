import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/normalise/norm_columns.dart';
import 'package:rule_engine/rule_engine.dart' show indexKeys;
import 'package:sqlite3/sqlite3.dart';

/// One persisted `*_norm` column and the column it is computed from.
typedef NormColumn = ({String table, String norm, String source});

/// Every `*_norm` column `SPEC.md` §7.1 declares.
///
/// A column added later must not be silently unparited, so the list is asserted
/// by count as well as walked.
const List<NormColumn> kNormColumns = <NormColumn>[
  (table: 'species_name', norm: 'search_norm', source: 'name'),
  (table: 'legal_text', norm: 'body_norm', source: 'body'),
];

/// A7 — every persisted `*_norm` column matches the shared normaliser,
/// byte for byte.
///
/// **Run against the emitted database, not the in-memory rows.** Recomputing
/// from the model would prove the model consistent with itself and say nothing
/// about what SQLite stored: a truncated column, a `TEXT` affinity surprise or
/// an emit-order bug would all pass. The
/// `catchlaw-content-pipeline` worked example runs it after `emitReferenceDb`
/// and deletes the file if it fails, because *an unindexed database is worse
/// than none*.
///
/// It is deliberately **not** an [Assertion]: the others take a
/// [ContentSource] and this one takes bytes that do not exist until the emit
/// phase. E04/T10 wires it in after emit.
final class NormParityAssertion {
  /// The A7 assertion.
  const NormParityAssertion();

  /// The stable assertion id.
  String get id => 'A7';

  /// Every column of [db] whose stored key the shared normaliser disagrees with.
  ///
  /// `species_name.search_norm` accepts **either** key `indexKeys` produces for
  /// the name: E04/T07 emits a second row carrying the article-stripped form, so
  /// a strict `normaliseSpeciesTerm(name)` comparison would fail every Arabic
  /// name that carries `ال`.
  Iterable<Failure> verify(Database db, {String path = 'app/assets/db/reference.db'}) sync* {
    for (final NormColumn column in kNormColumns) {
      final ResultSet rows = db.select(
        'SELECT id, ${column.source} AS src, ${column.norm} AS norm FROM ${column.table}',
      );
      for (final row in rows) {
        final id = row['id'] as int;
        final source = (row['src'] ?? '') as String;
        final stored = (row['norm'] ?? '') as String;

        final bool matches = column.table == 'species_name'
            ? indexKeys(source).contains(stored)
            : stored == NormColumns.bodyNorm(source);
        if (matches) continue;

        yield Failure(
          _id,
          path,
          id,
          '${column.table}.${column.norm} row $id differs from the shared normaliser',
        );
      }
    }
  }

  static const String _id = 'A7';
}
