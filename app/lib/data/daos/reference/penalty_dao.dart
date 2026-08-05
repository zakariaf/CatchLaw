import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/tables/reference/penalty.dart';
import 'package:drift/drift.dart';

part 'penalty_dao.g.dart';

/// Reads what a breach costs, as the pack records it.
///
/// One read, and no filter of any kind beyond the jurisdiction. A penalty is
/// not evaluated against a fish, a length or a date — it is a printed schedule,
/// and the screen that renders it is the back cover of the booklet rather than
/// a verdict.
@DriftAccessor(tables: <Type>[Penalties])
class PenaltyDao extends DatabaseAccessor<ReferenceDatabase> with _$PenaltyDaoMixin {
  /// Reads penalties from [db].
  PenaltyDao(super.db);

  /// Every penalty one jurisdiction records, in ledger order.
  ///
  /// Ordered by `offence_key` and then by `occurrence` so the ledger reads the
  /// way the instrument sets it: an offence, then the scale of what a second
  /// and a third one carry. An empty list is a real answer — the pack
  /// transcribed no penalty for this jurisdiction — and is never an error.
  Future<List<PenaltyRow>> forJurisdiction(int jurisdictionId) =>
      (select(penalties)
            ..where(($PenaltiesTable t) => t.jurisdictionId.equals(jurisdictionId))
            ..orderBy(<OrderClauseGenerator<$PenaltiesTable>>[
              ($PenaltiesTable t) => OrderingTerm(expression: t.offenceKey),
              ($PenaltiesTable t) => OrderingTerm(expression: t.occurrence),
            ]))
          .get();
}
