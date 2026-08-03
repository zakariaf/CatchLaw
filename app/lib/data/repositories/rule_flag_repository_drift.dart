import 'package:catchlaw/data/repositories/rule_flag_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/rule_flag.dart';
import 'package:drift/drift.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// [RuleFlagRepository] over `user.db`.
final class DriftRuleFlagRepository implements RuleFlagRepository {
  /// Writes flags into [db].
  DriftRuleFlagRepository(this.db, {this.boundary = const StorageBoundary()});

  /// The one writable database.
  final UserDatabase db;

  /// Where a storage exception becomes a `DataFailure`.
  final StorageBoundary boundary;

  @override
  Future<Result<void>> flag(RuleFlagDraft draft) => boundary.guard(() async {
    // One transaction: a partially written flag is not a flag, and the row is
    // either wholly present when the future completes or wholly absent.
    await db.transaction(() async {
      await db
          .into(db.ruleFlags)
          .insert(
            RuleFlagsCompanion.insert(
              ruleId: draft.ruleId,
              note: draft.note,
              createdAt: draft.createdAt,
              citationRef: Value<String?>(draft.citationRef),
            ),
          );
    });
  });

  @override
  Stream<List<RuleFlag>> watchAll() =>
      (db.select(db.ruleFlags)..orderBy(<OrderClauseGenerator<$RuleFlagsTable>>[
            ($RuleFlagsTable t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ]))
          .watch()
          .map(
            (List<RuleFlagRow> rows) => <RuleFlag>[
              for (final RuleFlagRow row in rows)
                RuleFlag(
                  id: row.id,
                  ruleId: row.ruleId,
                  note: row.note,
                  createdAt: row.createdAt,
                  citationRef: row.citationRef,
                ),
            ],
          );
}
