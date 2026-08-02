import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/tables/reference/content_string.dart';
import 'package:drift/drift.dart';

part 'content_string_dao.g.dart';

/// Resolves tier-two content strings.
@DriftAccessor(tables: <Type>[ContentStrings])
class ContentStringDao extends DatabaseAccessor<ReferenceDatabase> with _$ContentStringDaoMixin {
  /// Reads strings from [db].
  ContentStringDao(super.db);

  /// The values of [keys] in [locale], for the keys that exist there.
  ///
  /// Returns only what is present, and **applies no fallback**. The §9.2 chain —
  /// requested locale, jurisdiction default, `en`, scientific name — is a
  /// decision about which locale to ask for, and it belongs to E06 where the
  /// jurisdiction's `default_locale` is in scope. Baking one step of it in here
  /// would mean a caller could not tell a resolved `gl` string from an `en` one
  /// silently substituted for it.
  ///
  /// One query for every key, not one per key: a result screen resolves a dozen
  /// and twelve round trips is a visible pause.
  Future<Map<String, String>> resolve(Iterable<String> keys, String locale) async {
    final List<String> wanted = keys.toSet().toList();
    if (wanted.isEmpty) return const <String, String>{};

    final List<ContentStringRow> rows = await (select(
      contentStrings,
    )..where(($ContentStringsTable t) => t.key.isIn(wanted) & t.locale.equals(locale))).get();

    return <String, String>{for (final ContentStringRow r in rows) r.key: r.value};
  }

  /// Every locale row for one [key], keyed by locale.
  ///
  /// The whole key in one statement, because the §9.2 fallback chain has four
  /// steps and S5 renders up to forty rows: a statement per step would be a
  /// hundred and sixty round trips against a `WITHOUT ROWID` table for one
  /// screen (`SPEC.md` §13).
  Future<Map<String, String>> valuesFor(String key) async {
    final List<ContentStringRow> rows = await (select(
      contentStrings,
    )..where(($ContentStringsTable t) => t.key.equals(key))).get();
    return <String, String>{for (final ContentStringRow r in rows) r.locale: r.value};
  }

  /// Every locale [key] resolves in. E15's language-availability notice.
  Future<List<String>> localesFor(String key) async {
    final List<ContentStringRow> rows = await (select(
      contentStrings,
    )..where(($ContentStringsTable t) => t.key.equals(key))).get();
    return rows.map((ContentStringRow r) => r.locale).toList()..sort();
  }
}
