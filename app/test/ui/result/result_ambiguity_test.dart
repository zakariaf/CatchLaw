import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_panel.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_ambiguity_block.dart';
import 'package:catchlaw/ui/result/widgets/result_ambiguity_dialog.dart';
import 'package:catchlaw/ui/result/widgets/result_disclaimer.dart';
import 'package:catchlaw/ui/result/widgets/result_verdict_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../../../testing/theme/pump_lonja.dart';

const String _eyebrow = 'CONFLICT OF INSTRUMENTS';
const String _headline = 'Two rules of equal standing apply here.';
const String _authority = 'Xunta de Galicia — Consellería do Mar';
final Finder _note = find.textContaining('ranks neither above the other');

const AmbiguityDisplay _ambiguity = AmbiguityDisplay(
  sentence: _headline,
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
    testWidgets('heads the notice with a tracked eyebrow over the headline', (
      WidgetTester tester,
    ) async {
      await pumpLonja(tester, const ResultAmbiguityBlock(ambiguity: _ambiguity));

      // Cased at the call site, so the ARB wording is sentence case and the
      // eyebrow that ships is upper. Tracked, from the ramp's eyebrow step:
      // tracking is what makes an eyebrow, and in Arabic it is all there is.
      final Finder eyebrow = find.text(_eyebrow);
      expect(eyebrow, findsOneWidget);

      final BuildContext context = tester.element(eyebrow);
      expect(
        tester.widget<Text>(eyebrow).style,
        LonjaType.of(context).eyebrow.copyWith(color: LonjaTokens.of(context).onSurfaceMuted),
      );
      expect(tester.getTopLeft(eyebrow).dy, lessThan(tester.getTopLeft(find.text(_headline)).dy));
    });

    testWidgets('closes the head with the section rule before the first instrument', (
      WidgetTester tester,
    ) async {
      await pumpLonja(tester, const ResultAmbiguityBlock(ambiguity: _ambiguity));

      // The masthead rule: LonjaRule.section is the 2pt weight, and it sits
      // under the headline and above every instrument in the block.
      final Finder masthead = find.byWidgetPredicate(
        (Widget w) => w is LonjaRule && w.weight == LonjaRules.strong,
      );
      final double head = tester.getTopLeft(masthead.first).dy;

      expect(head, greaterThan(tester.getTopLeft(find.text(_headline)).dy));
      expect(head, lessThan(tester.getTopLeft(find.text('40 mm (Shell length)')).dy));
    });

    testWidgets('marks each instrument with a rail and never with a frame', (
      WidgetTester tester,
    ) async {
      await pumpLonja(tester, const ResultAmbiguityBlock(ambiguity: _ambiguity));

      // A rail marks where an instrument starts; a frame encloses it and
      // invites the reader to weigh one box against the other.
      expect(find.byType(LonjaPanel), findsNothing);

      final Color accent = LonjaTokens.of(tester.element(find.text(_headline))).accent;
      final Iterable<BoxDecoration> rails = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((DecoratedBox b) => b.decoration)
          .whereType<BoxDecoration>()
          .where((BoxDecoration d) => d.border is BorderDirectional);

      expect(rails.length, 2);
      for (final rail in rails) {
        final border = rail.border! as BorderDirectional;
        // The SAME slot and the SAME weight on both: a second hue would
        // separate the two instruments by ranking them.
        expect(border.start, BorderSide(color: accent, width: LonjaRules.strong));
        expect(border.end, BorderSide.none);
        expect(border.top, BorderSide.none);
        expect(border.bottom, BorderSide.none);
      }
    });

    testWidgets('closes the notice with the note under both instruments', (
      WidgetTester tester,
    ) async {
      await pumpLonja(tester, const ResultAmbiguityBlock(ambiguity: _ambiguity));

      expect(_note, findsOneWidget);
      expect(
        tester.getTopLeft(_note).dy,
        greaterThan(tester.getTopLeft(find.text('38 mm (Shell length)')).dy),
      );
    });

    testWidgets('prints both rules and both citations', (WidgetTester tester) async {
      await pumpLonja(tester, const ResultAmbiguityBlock(ambiguity: _ambiguity));

      expect(find.text(_headline), findsOneWidget);
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
              authority: _authority,
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return answer;
    }

    testWidgets('sets the notice, the disclaimer and the actions in that order', (
      WidgetTester tester,
    ) async {
      await open(tester);

      // The one order the sheet is ever drawn in: the notice states the
      // conflict, the standing disclaimer says what the sheet is, and the
      // actions sit at the foot under everything they act on.
      final double eyebrow = tester.getTopLeft(find.text(_eyebrow)).dy;
      final double headline = tester.getTopLeft(find.text(_headline)).dy;
      final double note = tester.getTopLeft(_note).dy;
      final double disclaimer = tester.getTopLeft(find.byType(ResultDisclaimer)).dy;
      final double firstAction = tester
          .getTopLeft(find.byKey(const Key('ambiguity-choice-es-ga-plan-cambados-2026')))
          .dy;

      expect(eyebrow, lessThan(headline));
      expect(headline, lessThan(note));
      expect(note, lessThan(disclaimer));
      expect(disclaimer, lessThan(firstAction));
    });

    testWidgets('carries the disclaimer naming the authority', (WidgetTester tester) async {
      await open(tester);

      // A modal that covers the result surface covers the disclaimer with it.
      // Unconditional there means unconditional here.
      expect(find.byType(ResultDisclaimer), findsOneWidget);
      expect(tester.widget<ResultDisclaimer>(find.byType(ResultDisclaimer)).authority, _authority);
      expect(find.textContaining(_authority), findsOneWidget);
    });

    testWidgets('states the refusal once and frames the sheet once', (WidgetTester tester) async {
      await open(tester);

      // Printed twice, the refusal read as two different claims about the same
      // conflict. It is the headline, and it is said there only.
      expect(find.text(_headline), findsOneWidget);
      // One ruled sheet: the dialog is the frame, so there is no panel inside
      // it carrying a second border, a second ground and a second padding.
      expect(find.byType(LonjaPanel), findsNothing);
    });

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

      // Scrolled to first, for the reason the sibling test above records: the
      // dialog's content scrolls, the second instrument's action sits below the
      // fold at the shipped type sizes, and a bare tap on an off-screen widget
      // does not fail fast — it misses, the dialog never pops, and `await
      // answer` hangs to the ten-minute timeout as an unrelated-looking flake.
      await tester.ensureVisible(find.byKey(const Key('ambiguity-choice-es-ga-orde-2012-07-27')));
      await tester.pumpAndSettle();
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
