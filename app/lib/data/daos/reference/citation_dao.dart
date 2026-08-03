import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/tables/reference/citation.dart';
import 'package:catchlaw/data/services/tables/reference/content_meta.dart';
import 'package:catchlaw/data/services/tables/reference/jurisdiction.dart';
import 'package:catchlaw/data/services/tables/reference/measurement.dart';
import 'package:drift/drift.dart';

part 'citation_dao.g.dart';

/// Reads the instruments a finding quotes.
///
/// Invariant 3: every result carries one. The engine makes a missing citation
/// unrepresentable and A4 makes it unshippable; this is the read that has to
/// deliver it.
@DriftAccessor(tables: <Type>[Citations])
class CitationDao extends DatabaseAccessor<ReferenceDatabase> with _$CitationDaoMixin {
  /// Reads citations from [db].
  CitationDao(super.db);

  /// One citation, or `null`.
  Future<CitationRow?> byId(int id) =>
      (select(citations)..where(($CitationsTable t) => t.id.equals(id))).getSingleOrNull();

  /// Several citations in one query.
  ///
  /// A resolution carries one citation per finding and a `NoRuleFound` carries
  /// every instrument that was consulted; fetching them one at a time is the
  /// §13 budget spent on round trips.
  Future<List<CitationRow>> byIds(Iterable<int> ids) {
    final List<int> wanted = ids.toSet().toList();
    if (wanted.isEmpty) return Future<List<CitationRow>>.value(const <CitationRow>[]);
    return (select(citations)..where(($CitationsTable t) => t.id.isIn(wanted))).get();
  }
}

/// Reads what the pack says about itself.
@DriftAccessor(tables: <Type>[ContentMetas, Jurisdictions, MeasurementMethods])
class ReferenceMetaDao extends DatabaseAccessor<ReferenceDatabase> with _$ReferenceMetaDaoMixin {
  /// Reads pack metadata from [db].
  ReferenceMetaDao(super.db);

  /// `schema_version`, `build_date` and `generator_commit`.
  ///
  /// What E18's About screen prints, and what makes a stale database traceable
  /// to the tree that wrote it.
  Future<Map<String, String>> contentMeta() async {
    final List<ContentMetaRow> rows = await select(contentMetas).get();
    return <String, String>{for (final ContentMetaRow r in rows) r.key: r.value};
  }

  /// `measurement_method.id` → its `code`.
  ///
  /// The whole table, in one statement: it is nine rows at most, and a join per
  /// rule would be a round trip for a value that never changes within a pack.
  Future<Map<int, String>> methodCodes() async => <int, String>{
    for (final MeasurementMethodRow row in await select(measurementMethods).get()) row.id: row.code,
  };

  /// Every bundled jurisdiction, by code.
  Future<List<JurisdictionRow>> allJurisdictions() =>
      (select(jurisdictions)..orderBy(<OrderClauseGenerator<$JurisdictionsTable>>[
            ($JurisdictionsTable t) => OrderingTerm(expression: t.code),
          ]))
          .get();

  /// One jurisdiction by its `SPEC.md` §7.1 code, or `null`.
  Future<JurisdictionRow?> jurisdictionByCode(String code) => (select(
    jurisdictions,
  )..where(($JurisdictionsTable t) => t.code.equals(code))).getSingleOrNull();
}
