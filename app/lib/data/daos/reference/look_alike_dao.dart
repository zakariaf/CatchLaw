import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/tables/reference/taxonomy.dart';
import 'package:drift/drift.dart';

part 'look_alike_dao.g.dart';

/// The confusable pairs, in both directions.
@DriftAccessor(tables: <Type>[Lookalikes, SpeciesTable])
class LookAlikeDao extends DatabaseAccessor<ReferenceDatabase> with _$LookAlikeDaoMixin {
  /// Reads pairs from [db].
  LookAlikeDao(super.db);

  /// Every species [speciesId] is confused with.
  ///
  /// **Both directions**, and the union is the point: a pack that records
  /// `A confused with B` and not the reverse would warn the reader who opened
  /// A and say nothing to the reader who opened B — and it is the second one
  /// who is about to keep a protected fish.
  Future<List<LookalikeRow>> forSpecies(int speciesId) async {
    final List<QueryRow> rows = await customSelect(
      'SELECT * FROM lookalike WHERE species_id = ?1 '
      'UNION ALL '
      'SELECT id, confused_with AS species_id, species_id AS confused_with, difference_key '
      'FROM lookalike WHERE confused_with = ?1',
      variables: <Variable<Object>>[Variable<int>(speciesId)],
      readsFrom: <ResultSetImplementation<HasResultSet, Object>>{lookalikes},
    ).get();
    return rows.map((QueryRow r) => lookalikes.map(r.data)).toList();
  }
}
