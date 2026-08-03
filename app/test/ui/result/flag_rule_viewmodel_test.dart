import 'package:catchlaw/domain/models/rule_flag.dart';
import 'package:catchlaw/ui/result/view_models/flag_rule_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_rule_flag_repository.dart';

void main() {
  late FakeRuleFlagRepository repository;
  late FlagRuleViewModel viewModel;

  setUp(() {
    repository = FakeRuleFlagRepository();
    viewModel = FlagRuleViewModel(repository);
    addTearDown(repository.dispose);
  });

  test('FlagRuleViewModel.save refuses an empty note', () async {
    // An empty row exports as noise and is indistinguishable from a mis-tap.
    expect(
      await viewModel.save(ruleId: 41, note: '', now: '2026-08-03T05:40:00Z'),
      FlagOutcome.emptyNote,
    );
    expect(repository.written, isEmpty);
  });

  test('FlagRuleViewModel.save refuses a whitespace-only note', () async {
    // The case a first regex gets wrong, and exactly what a fat finger on a wet
    // screen produces.
    expect(
      await viewModel.save(ruleId: 41, note: '   ', now: '2026-08-03T05:40:00Z'),
      FlagOutcome.emptyNote,
    );
    expect(repository.written, isEmpty);
  });

  test('FlagRuleViewModel.save passes the rule and its citation through unchanged', () async {
    await viewModel.save(
      ruleId: 41,
      note: 'The gazette says 45, this says 40.',
      now: '2026-08-03T05:40:00Z',
      citationRef: 'Ministerial Decision 580/2015, Art. 3',
    );

    // A flag against the wrong rule row is worse than no flag.
    final RuleFlagDraft draft = repository.written.single;
    expect(draft.ruleId, 41);
    expect(draft.citationRef, 'Ministerial Decision 580/2015, Art. 3');
  });

  test('FlagRuleViewModel.save stamps the instant it was given', () async {
    await viewModel.save(ruleId: 41, note: 'wrong', now: '2026-08-03T05:40:00Z');

    // No DateTime.now() in state logic: a wall clock is untestable and records
    // when the suite ran rather than when the reader wrote.
    expect(repository.written.single.createdAt, '2026-08-03T05:40:00Z');
  });

  test('FlagRuleViewModel.save trims the note before it stores it', () async {
    await viewModel.save(ruleId: 41, note: '  wrong number  ', now: '2026-08-03T05:40:00Z');

    expect(repository.written.single.note, 'wrong number');
  });

  test('FlagRuleViewModel.save reports a refused write as a failure', () async {
    final broken = FakeRuleFlagRepository(failure: Exception('disk full'));
    addTearDown(broken.dispose);

    expect(
      await FlagRuleViewModel(broken).save(ruleId: 41, note: 'wrong', now: '2026-08-03T05:40:00Z'),
      FlagOutcome.failed,
    );
  });
}
