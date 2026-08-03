import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/stale_rule_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

const StaleDisplay _stale = StaleDisplay(
  sentence: 'These rules passed their stated end date on 2026-06-30. They are shown as published.',
  provenance:
      'Bundled rule pack RAK-GULF v2026.2 passed its validity date on 2026-06-30. '
      'The text above is the last verified wording.',
);

Future<void> _pumpBar(WidgetTester tester, {ProviderContainer? container}) => pumpLonja(
  tester,
  UncontrolledProviderScope(
    container: container ?? ProviderContainer(),
    child: const StaleRuleBar(stale: _stale, packId: 'RAK-GULF v2026.2'),
  ),
);

void main() {
  group('StaleRuleBar', () {
    testWidgets('states the end date the pack recorded', (WidgetTester tester) async {
      await _pumpBar(tester);

      expect(find.textContaining('2026-06-30'), findsWidgets);
    });

    testWidgets('carries no dismiss control on the bar itself', (WidgetTester tester) async {
      await _pumpBar(tester);

      // The bar is the invariant; only its detail may be put away.
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('carries no retry or refresh affordance', (WidgetTester tester) async {
      await _pumpBar(tester);

      // There is nothing to retry on a device with no network by design, and
      // an affordance offering one would be a lie about what the app can do.
      final List<String> labels = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => (t.data ?? '').toLowerCase())
          .toList();
      for (final banned in const <String>['refresh', 'retry', 'update', 'download']) {
        expect(labels.any((String l) => l.contains(banned)), isFalse, reason: banned);
      }
    });

    testWidgets('states a fact and never an instruction', (WidgetTester tester) async {
      await _pumpBar(tester);

      final String copy = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data ?? '')
          .join(' ')
          .toLowerCase();
      // Invariant 2 applies to the bar too.
      for (final banned in const <String>['you ', 'your ', 'should', 'must ', 'please']) {
        expect(copy.contains(banned), isFalse, reason: banned);
      }
    });

    testWidgets('pairs a glyph with the sentence', (WidgetTester tester) async {
      await _pumpBar(tester);

      // Amber alone is invisible in greyscale and to eight percent of readers.
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.textContaining('passed their stated end date'), findsOneWidget);
    });

    testWidgets('closes the detail for the session and leaves the bar in place', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await _pumpBar(tester, container: container);

      expect(find.textContaining('Bundled rule pack'), findsOneWidget);
      await tester.tap(find.byKey(StaleRuleBar.closeDetailKey));
      await tester.pumpAndSettle();

      expect(find.textContaining('Bundled rule pack'), findsNothing);
      expect(find.textContaining('passed their stated end date'), findsOneWidget);
    });

    testWidgets('does not persist a dismissal beyond the session', (WidgetTester tester) async {
      final first = ProviderContainer();
      addTearDown(first.dispose);
      await _pumpBar(tester, container: first);
      await tester.tap(find.byKey(StaleRuleBar.closeDetailKey));
      await tester.pumpAndSettle();

      // A fisher who closed it in June and opens the app in September is a
      // different reader with a different question.
      final second = ProviderContainer();
      addTearDown(second.dispose);
      await _pumpBar(tester, container: second);

      expect(find.textContaining('Bundled rule pack'), findsOneWidget);
    });
  });
}
