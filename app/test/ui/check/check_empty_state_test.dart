import 'package:catchlaw/ui/check/widgets/check_empty_state.dart';
import 'package:catchlaw/ui/core/ui/lonja_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

void main() {
  group('CheckEmptyState', () {
    testWidgets('states what this device has done', (WidgetTester tester) async {
      await pumpLonja(tester, const CheckEmptyState());

      expect(find.text('Nothing checked here yet'), findsOneWidget);
    });

    testWidgets('explains the mechanism rather than instructing', (WidgetTester tester) async {
      await pumpLonja(tester, const CheckEmptyState());

      // "Search for a species to get started" is an instruction, and this app
      // does not instruct — not about fish, and not about itself.
      final String copy = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => (t.data ?? '').toLowerCase())
          .join(' ');
      for (final banned in const <String>['tap ', 'search for', 'get started', 'try ']) {
        expect(copy.contains(banned), isFalse, reason: banned);
      }
    });

    testWidgets('offers no action of its own', (WidgetTester tester) async {
      await pumpLonja(tester, const CheckEmptyState());

      // The search field is directly below and is the only thing to do on this
      // screen; a button here would be a second way to reach a control already
      // on the same page.
      expect(find.byType(ButtonStyleButton), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('ar - reads right to left', (WidgetTester tester) async {
      await pumpLonja(tester, const CheckEmptyState(), locale: const Locale('ar'));

      expect(find.text('لم يُفحص شيء هنا بعد'), findsOneWidget);
    });
  });

  group('LonjaSearchField', () {
    testWidgets('does not raise the keyboard on launch', (WidgetTester tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpLonja(
        tester,
        LonjaSearchField(
          controller: controller,
          hint: 'hamour, mero',
          semanticLabel: 'Species',
          onChanged: (String _) {},
        ),
      );

      // An auto-raised keyboard covers the recents strip, which is the one-tap
      // path to a verdict, and §3's five seconds get spent dismissing it.
      expect(tester.widget<TextField>(find.byType(TextField)).autofocus, isFalse);
    });
  });
}
