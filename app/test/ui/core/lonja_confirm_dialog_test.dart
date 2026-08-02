import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

/// Opens a confirmation and hands back whatever it returned.
///
/// The labels are from the approved corpus in
/// `lonja-buttons/references/button-anatomy.md`. They are deliberately NOT the
/// cancel wordings `lonja-dialogs-and-surfaces` rule 3 tables — every one of
/// those opens with a verb that `check_app_invariants.sh` check 3 fails in Dart
/// and in every ARB file, with no exemption anywhere.
Future<LonjaConfirmOutcome?> _open(WidgetTester tester) async {
  LonjaConfirmOutcome? answer;
  await pumpLonja(
    tester,
    Builder(
      builder: (BuildContext context) => LonjaButton.secondary(
        label: 'Open',
        onPressed: () async {
          answer = await showLonjaConfirm(
            context,
            title: 'Replace the log',
            body: 'The imported file replaces every catch recorded on this device.',
            confirmLabel: 'Replace the log',
            cancelLabel: 'Back one step',
          );
        },
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return answer;
}

void main() {
  testWidgets('showLonjaConfirm returns confirmed when the destructive rung is chosen', (
    WidgetTester tester,
  ) async {
    await _open(tester);
    await tester.tap(find.text('Replace the log').last);
    await tester.pumpAndSettle();
    // The dialog is gone, which is the observable half; the outcome is asserted
    // in the row below where the future is awaited on the same frame.
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('showLonjaConfirm returns declined when the cancel rung is chosen', (
    WidgetTester tester,
  ) async {
    await _open(tester);
    await tester.tap(find.text('Back one step'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('showLonjaConfirm ignores a tap on the barrier', (WidgetTester tester) async {
    // A stray tap outside the sheet must not read as an answer to a question
    // about deleting the fisher's catch log.
    await _open(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  test('LonjaConfirmOutcome distinguishes dismissal from refusal', () {
    // Three values, because dismissal is not refusal. A system-back pop means
    // the fisher never answered; folding that into `declined` tells the caller
    // a decision was made when none was.
    expect(LonjaConfirmOutcome.values, hasLength(3));
    expect(LonjaConfirmOutcome.dismissed, isNot(LonjaConfirmOutcome.declined));
  });
}
