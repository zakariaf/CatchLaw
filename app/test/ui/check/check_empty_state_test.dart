import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
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

    testWidgets('carries the glass that says what the box reads', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        LonjaSearchField(hint: 'hamour, mero', semanticLabel: 'Species', onChanged: (String _) {}),
      );

      final Iterable<LonjaIcon> glyphs = tester.widgetList<LonjaIcon>(find.byType(LonjaIcon));
      expect(glyphs.map((LonjaIcon i) => i.glyph), contains(LonjaIcons.search));
    });

    testWidgets('offers no way to empty a box with nothing in it', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        LonjaSearchField(hint: 'hamour, mero', semanticLabel: 'Species', onChanged: (String _) {}),
      );

      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('empties the box and the list it fed when the cross is taken', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final typed = <String>[];
      await pumpLonja(
        tester,
        LonjaSearchField(
          controller: controller,
          hint: 'hamour, mero',
          semanticLabel: 'Species',
          onChanged: typed.add,
        ),
      );

      await tester.enterText(find.byType(TextField), 'mero');
      await tester.pump();
      expect(find.byType(IconButton), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // The box AND the callback: a cross that emptied the field without
      // walking the same seam a keystroke walks would leave the old matches
      // standing under an empty field.
      expect(controller.text, isEmpty);
      expect(typed.last, isEmpty);
      expect(find.byType(IconButton), findsNothing);
    });
  });
}
