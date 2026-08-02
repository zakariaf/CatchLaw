import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/tables/reference/taxonomy.dart';
import 'package:drift/drift.dart';

part 'species_search_dao.g.dart';

/// The two statements S5's search box runs, and nothing else.
///
/// **A range predicate, never a `LIKE`.** `search_norm >= :q AND search_norm <
/// :qUpper` is the one form SQLite can always serve from `idx_name_search`.
/// `LIKE 'q%'` *can* be optimised into the same range — but only while the
/// column collation is `BINARY`, `case_sensitive_like` is at its default, and
/// the prefix is a literal. A future `PRAGMA` or a `COLLATE NOCASE` on a
/// rebuilt content database removes any of those silently, at which point the
/// query degrades to a full scan of 2 400 rows on every keystroke and nothing
/// fails. The range cannot be defeated.
///
/// FTS5 was rejected. §7.1's own comment on `legal_text` records why:
/// *unicode61 does NOT fold Arabic orthographic variants* — which is exactly
/// what `search_norm` exists to do. Reaching for it here would reintroduce the
/// bug the column was added to fix.
@DriftAccessor(tables: <Type>[SpeciesTable, SpeciesNames])
class SpeciesSearchDao extends DatabaseAccessor<ReferenceDatabase> with _$SpeciesSearchDaoMixin {
  /// Searches [db].
  SpeciesSearchDao(super.db);

  /// Every name row whose fold starts with [normalisedPrefix].
  ///
  /// The **name** rows, not the species rows: the caller needs to know which
  /// word matched, and a `SELECT DISTINCT s.*` throws that away. Ordering puts
  /// the reader's own locale first and a primary name before a regional
  /// variant, so `هامور` outranks a Spanish trade name for the same fish on an
  /// Arabic phone.
  Future<List<SpeciesNameRow>> matchingNames(
    String normalisedPrefix, {
    required String locale,
    int limit = 40,
  }) async {
    if (normalisedPrefix.isEmpty) return const <SpeciesNameRow>[];
    final List<QueryRow> rows = await customSelect(
      'SELECT n.* FROM species_name n '
      'WHERE n.search_norm >= ?1 AND n.search_norm < ?2 '
      'ORDER BY (n.locale = ?3) DESC, n.is_primary DESC, LENGTH(n.search_norm) ASC, n.name ASC '
      'LIMIT ?4',
      variables: <Variable<Object>>[
        Variable<String>(normalisedPrefix),
        // The half-open upper bound that keeps this a range scan: appending the
        // highest codepoint is what turns a prefix match into two B-tree seeks.
        Variable<String>('$normalisedPrefix\u{10FFFF}'),
        Variable<String>(locale),
        Variable<int>(limit),
      ],
      readsFrom: <ResultSetImplementation<HasResultSet, Object>>{speciesNames},
    ).get();
    return rows.map((QueryRow r) => speciesNames.map(r.data)).toList();
  }

  /// The species behind a set of name rows, in one statement.
  ///
  /// Two statements rather than one `GROUP BY`: a species can match on several
  /// of its own names, and collapsing in SQL would either lose the matched word
  /// or duplicate the species. Grouping happens in Dart, where the rule for
  /// which name to show is written down.
  Future<List<SpeciesRow>> speciesByIds(Iterable<int> ids) {
    final List<int> wanted = ids.toSet().toList();
    if (wanted.isEmpty) return Future<List<SpeciesRow>>.value(const <SpeciesRow>[]);
    return (select(speciesTable)..where(($SpeciesTableTable t) => t.id.isIn(wanted))).get();
  }

  /// How many species the pack carries.
  Future<int> speciesCount() async => (await customSelect(
    'SELECT COUNT(*) AS c FROM species',
    readsFrom: <ResultSetImplementation<HasResultSet, Object>>{speciesTable},
  ).getSingle()).read<int>('c');
}
