import 'dart:async';

import 'package:catchlaw/data/repositories/rule_flag_repository.dart';
import 'package:catchlaw/domain/models/rule_flag.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// An in-memory [RuleFlagRepository].
final class FakeRuleFlagRepository implements RuleFlagRepository {
  /// Records into memory, or fails every call with [failure].
  FakeRuleFlagRepository({this.failure});

  /// What every call fails with, when the test is about a broken store.
  final Exception? failure;

  /// Every draft this repository was handed, in order.
  final List<RuleFlagDraft> written = <RuleFlagDraft>[];

  final StreamController<List<RuleFlag>> _flags = StreamController<List<RuleFlag>>.broadcast();

  @override
  Future<Result<void>> flag(RuleFlagDraft draft) async {
    if (failure != null) return Result<void>.error(failure!);
    written.add(draft);
    _flags.add(<RuleFlag>[
      for (final (int index, RuleFlagDraft d) in written.indexed.toList().reversed)
        RuleFlag(
          id: index + 1,
          ruleId: d.ruleId,
          note: d.note,
          createdAt: d.createdAt,
          citationRef: d.citationRef,
        ),
    ]);
    return const Result<void>.ok(null);
  }

  @override
  Stream<List<RuleFlag>> watchAll() => _flags.stream;

  /// Closes the stream. A test that opens one closes it.
  Future<void> dispose() => _flags.close();
}
