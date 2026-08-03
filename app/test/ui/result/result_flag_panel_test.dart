import 'package:catchlaw/ui/result/view_models/flag_rule_viewmodel.dart';
import 'package:catchlaw/ui/result/widgets/result_flag_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_rule_flag_repository.dart';
import '../../../testing/theme/pump_lonja.dart';

void main() {
  late FakeRuleFlagRepository repository;

  Future<void> pumpPanel(WidgetTester tester) {
    repository = FakeRuleFlagRepository();
    addTearDown(repository.dispose);
    return pumpLonja(
      tester,
      ResultFlagPanel(
        ruleId: 41,
        citationRef: 'Ministerial Decision 580/2015, Art. 3',
        viewModel: FlagRuleViewModel(repository),
        now: '2026-08-03T05:40:00Z',
      ),
    );
  }

  group('ResultFlagPanel', () {
    testWidgets('opens no modal', (WidgetTester tester) async {
      await pumpPanel(tester);
      await tester.tap(find.byKey(ResultFlagPanel.openKey));
      await tester.pumpAndSettle();

      // Writing a note is not a decision the app cannot proceed without, so
      // the field opens IN PLACE. Asserted as "no dialog and the field is
      // inside the panel" rather than "no ModalBarrier anywhere", because
      // every MaterialApp route carries a barrier of its own.
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find.descendant(
          of: find.byType(ResultFlagPanel),
          matching: find.byKey(ResultFlagPanel.noteKey),
        ),
        findsOneWidget,
      );
    });

    testWidgets('writes one flag and states the completed fact', (WidgetTester tester) async {
      await pumpPanel(tester);
      await tester.tap(find.byKey(ResultFlagPanel.openKey));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(ResultFlagPanel.noteKey), 'The gazette says 45.');
      await tester.tap(find.byKey(ResultFlagPanel.saveKey));
      await tester.pumpAndSettle();

      expect(repository.written.single.ruleId, 41);
      expect(repository.written.single.note, 'The gazette says 45.');
      // The receipt is in the past tense and promises nothing.
      expect(find.text('Saved on this device.'), findsOneWidget);
    });

    testWidgets('writes nothing for an empty note and says so', (WidgetTester tester) async {
      await pumpPanel(tester);
      await tester.tap(find.byKey(ResultFlagPanel.openKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ResultFlagPanel.saveKey));
      await tester.pumpAndSettle();

      expect(repository.written, isEmpty);
      expect(find.text('The note is empty.'), findsOneWidget);
    });

    testWidgets('names the effect and its whole extent on the save target', (
      WidgetTester tester,
    ) async {
      await pumpPanel(tester);
      await tester.tap(find.byKey(ResultFlagPanel.openKey));
      await tester.pumpAndSettle();

      // There is no network: a label reading "Report" or "Send" would describe
      // an act the app cannot perform.
      expect(find.text('Save this note on this device'), findsOneWidget);
      final List<String> labels = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => (t.data ?? '').toLowerCase())
          .toList();
      for (final banned in const <String>['send', 'report', 'submit', 'upload']) {
        expect(labels.any((String l) => l.contains(banned)), isFalse, reason: banned);
      }
    });
  });
}
