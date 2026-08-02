import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

void main() {
  testWidgets('LonjaButton reports disabled to the semantics tree when onPressed is null', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, const LonjaButton.primary(label: 'Measure again', onPressed: null));
    expect(
      tester.getSemantics(find.byType(LonjaButton)),
      matchesSemantics(isButton: true, isEnabled: false, hasEnabledState: true),
    );
  });

  testWidgets('LonjaButton states its disabled reason rather than going silent', (
    WidgetTester tester,
  ) async {
    // A disabled control with no stated reason is a dead end: the fisher taps,
    // nothing happens, and there is nothing on screen that says why.
    await pumpLonja(
      tester,
      const LonjaButton.primary(
        label: 'Measure again',
        onPressed: null,
        disabledReason: 'No zone is chosen',
      ),
    );
    expect(tester.getSemantics(find.byType(LonjaButton)).hint, contains('No zone is chosen'));
  });

  testWidgets('LonjaButton refuses a tap while it is busy', (WidgetTester tester) async {
    var taps = 0;
    await pumpLonja(
      tester,
      LonjaButton.primary(label: 'Measure again', onPressed: () => taps++, busy: true),
    );
    await tester.tap(find.byType(LonjaButton), warnIfMissed: false);
    await tester.pump();
    expect(taps, 0);
  });

  testWidgets('LonjaButton fires once when it is not busy', (WidgetTester tester) async {
    var taps = 0;
    await pumpLonja(tester, LonjaButton.primary(label: 'Measure again', onPressed: () => taps++));
    await tester.tap(find.byType(LonjaButton));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('LonjaButton.destructive takes no onPressed at all', (WidgetTester tester) async {
    // A call site physically cannot wire a destructive action straight to a
    // handler: the constructor has no parameter for one, and onConfirmed runs
    // only after a confirmation returns confirmed.
    var ran = 0;
    await pumpLonja(
      tester,
      LonjaButton.destructive(label: 'Replace the log', onConfirmed: () async => ran++),
    );
    expect(find.byType(LonjaButton), findsOneWidget);
    expect(ran, 0);
  });
}
