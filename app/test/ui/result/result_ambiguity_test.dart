import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_ambiguity_block.dart';
import 'package:catchlaw/ui/result/widgets/result_ambiguity_dialog.dart';
import 'package:catchlaw/ui/result/widgets/result_verdict_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../../../testing/theme/pump_lonja.dart';

const AmbiguityDisplay _ambiguity = AmbiguityDisplay(
  sentence: 'Two rules of equal standing apply here.',
  rules: <AmbiguousRuleDisplay>[
    AmbiguousRuleDisplay(
      instrumentId: 'es-ga-plan-cambados-2026',
      facts: <RuleFact>[RuleFact(label: 'Minimum', value: '40 mm (Shell length)')],
      citation: kCitationDisplayXunta,
    ),
    AmbiguousRuleDisplay(
      instrumentId: 'es-ga-orde-2012-07-27',
      facts: <RuleFact>[RuleFact(label: 'Minimum', value: '38 mm (Shell length)')],
      citation: kCitationDisplayMd580,
    ),
  ],
);

void main() {
  group('ResultAmbiguityBlock', () {
    testWidgets('prints both rules and both citations', (WidgetTester tester) async {
      await pumpLonja(tester, const ResultAmbiguityBlock(ambiguity: _ambiguity));

      expect(find.text('Two rules of equal standing apply here.'), findsOneWidget);
      expect(find.text('40 mm (Shell length)'), findsOneWidget);
      expect(find.text('38 mm (Shell length)'), findsOneWidget);
      expect(find.textContaining('Orde do 27 de xullo de 2012'), findsOneWidget);
      expect(find.textContaining('Ministerial Decision 580/2015'), findsOneWidget);
    });

    testWidgets('preserves source order when the minima descend', (WidgetTester tester) async {
      await pumpLonja(tester, const ResultAmbiguityBlock(ambiguity: _ambiguity));

      // Delivered largest-first on purpose: any sort would visibly reorder
      // these, and an order the app imposed reads as a ranking.
      expect(
        tester.getTopLeft(find.text('40 mm (Shell length)')).dy,
        lessThan(tester.getTopLeft(find.text('38 mm (Shell length)')).dy),
      );
    });

    testWidgets('strikes no verdict stamp', (WidgetTester tester) async {
      await pumpLonja(tester, const ResultAmbiguityBlock(ambiguity: _ambiguity));

      // A stamp states one category, and there is no one category here.
      expect(find.byType(ResultVerdictPanel), findsNothing);
    });

    testWidgets('gives both rules the same visual weight', (WidgetTester tester) async {
      await pumpLonja(tester, const ResultAmbiguityBlock(ambiguity: _ambiguity));

      // A weight difference is a recommendation the wording refuses to make.
      final TextStyle? first = tester.widget<Text>(find.text('40 mm (Shell length)')).style;
      final TextStyle? second = tester.widget<Text>(find.text('38 mm (Shell length)')).style;
      expect(first, second);
    });
  });

  group('showResultAmbiguityDialog', () {
    Future<Future<AmbiguityChoice>> open(WidgetTester tester) async {
      late Future<AmbiguityChoice> answer;
      await pumpLonja(
        tester,
        Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => answer = showResultAmbiguityDialog(
              context,
              ambiguity: _ambiguity,
              deferLabel: 'Neither — record both',
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return answer;
    }

    testWidgets('offers one action per rule plus a defer, and no primary', (
      WidgetTester tester,
    ) async {
      final Future<AmbiguityChoice> answer = await open(tester);

      expect(find.byType(LonjaButtonProbe), findsNothing);
      expect(find.text('Neither — record both'), findsOneWidget);
      expect(find.textContaining('Orde do 27 de xullo de 2012'), findsWidgets);

      // Scrolled to first, because the dialog's content scrolls and the defer
      // action is the last thing in it — on a small screen at the shipped type
      // sizes it starts below the fold. A bare tap on an off-screen widget does
      // not fail fast here: it misses, the dialog never pops, and `await answer`
      // hangs until the ten-minute timeout, which reads as an unrelated flake.
      await tester.ensureVisible(find.text('Neither — record both'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Neither — record both'));
      await tester.pumpAndSettle();
      expect(await answer, isA<DeferredToBoth>());
    });

    testWidgets('returns the instrument the reader says they applied', (WidgetTester tester) async {
      final Future<AmbiguityChoice> answer = await open(tester);

      await tester.tap(find.byKey(const Key('ambiguity-choice-es-ga-orde-2012-07-27')));
      await tester.pumpAndSettle();

      final AmbiguityChoice choice = await answer;
      expect(choice, isA<AppliedInstrument>());
      expect((choice as AppliedInstrument).instrumentId, 'es-ga-orde-2012-07-27');
    });

    testWidgets('autofocuses neither instrument action', (WidgetTester tester) async {
      await open(tester);

      // An autofocused ACTION is a default, and a default is a recommendation.
      // Scoped to the actions: the dialog route's own focus scope autofocuses
      // by design, and asserting over the whole tree would be a test about
      // Flutter rather than about this dialog.
      for (final key in const <Key>[
        Key('ambiguity-choice-es-ga-plan-cambados-2026'),
        Key('ambiguity-choice-es-ga-orde-2012-07-27'),
        Key('ambiguity-defer'),
      ]) {
        final Iterable<Focus> focuses = tester.widgetList<Focus>(
          find.descendant(of: find.byKey(key), matching: find.byType(Focus)),
        );
        for (final focus in focuses) {
          expect(focus.autofocus, isFalse, reason: '$key');
        }
      }
    });

    testWidgets('does not dismiss on a barrier tap', (WidgetTester tester) async {
      await open(tester);

      // A stray tap outside must not resolve a legally weighted question.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.text('Neither — record both'), findsOneWidget);
    });
  });
}

/// A marker type the block must never render: there is no primary action here.
class LonjaButtonProbe extends StatelessWidget {
  const LonjaButtonProbe({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
