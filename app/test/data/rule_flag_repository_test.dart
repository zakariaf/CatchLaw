import 'dart:async';

import 'package:catchlaw/data/repositories/rule_flag_repository_drift.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/rule_flag.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Ok;

const RuleFlagDraft _draft = RuleFlagDraft(
  ruleId: 41,
  note: 'The gazette says 45 cm, this says 40.',
  createdAt: '2026-08-03T05:40:00Z',
  citationRef: 'Ministerial Decision 580/2015, Art. 3',
);

void main() {
  late UserDatabase db;
  late DriftRuleFlagRepository repository;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    repository = DriftRuleFlagRepository(db);
    addTearDown(db.close);
  });

  test('DriftRuleFlagRepository.flag writes one row with every column populated', () async {
    expect(await repository.flag(_draft), isA<Ok<void>>());

    final List<RuleFlagRow> rows = await db.select(db.ruleFlags).get();
    expect(rows, hasLength(1));
    expect(rows.single.ruleId, 41);
    expect(rows.single.note, _draft.note);
    expect(rows.single.createdAt, '2026-08-03T05:40:00Z');
    // Text and not a foreign key: a content update replaces the pack wholesale
    // and can renumber the rows, and a note pointing at a row id that no longer
    // means what it meant is a note nobody can read.
    expect(rows.single.citationRef, 'Ministerial Decision 580/2015, Art. 3');
  });

  test('DriftRuleFlagRepository.flag writes exactly one row per call', () async {
    await repository.flag(_draft);
    await repository.flag(_draft);

    // One transaction per call: a partially written flag is not a flag, and a
    // doubled one is a second doubt the reader never had.
    expect(await db.select(db.ruleFlags).get(), hasLength(2));
  });

  test('DriftRuleFlagRepository.watchAll emits again after a flag', () async {
    final emissions = <List<RuleFlag>>[];
    final StreamSubscription<List<RuleFlag>> sub = repository.watchAll().listen(emissions.add);
    addTearDown(sub.cancel);

    await repository.flag(_draft);
    await repository.flag(_draft);
    await Future<void>.delayed(Duration.zero);

    // E17 exports from this stream, and an export built from a snapshot taken
    // before the last write is missing the row the reader is exporting for.
    expect(emissions, isNotEmpty);
    expect(emissions.last, hasLength(2));
  });

  test('DriftRuleFlagRepository.watchAll returns the newest flag first', () async {
    await repository.flag(_draft);
    await repository.flag(
      const RuleFlagDraft(ruleId: 42, note: 'second', createdAt: '2026-08-03T06:00:00Z'),
    );

    final List<RuleFlag> flags = await repository.watchAll().first;
    expect(flags.first.ruleId, 42);
  });
}
