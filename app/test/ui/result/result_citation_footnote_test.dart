import 'package:catchlaw/ui/result/widgets/result_citation_footnote.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../../../testing/theme/pump_lonja.dart';

Future<void> _pumpRow(
  WidgetTester tester, {
  String? sourceUrl = 'https://www.xunta.gal/dog/Publicados/2012/20120806/AnuncioG0165.pdf',
  String jurisdiction = 'United Arab Emirates',
  Locale locale = const Locale('en'),
  bool gloved = false,
  void Function(int citationId)? onOpen,
}) => pumpLonja(
  tester,
  ResultCitationFootnote(
    citation: kCitationDisplayMd580,
    citationId: 4,
    jurisdiction: jurisdiction,
    marker: 1,
    sourceUrl: sourceUrl,
    onOpenRuleText: onOpen ?? (int _) {},
  ),
  locale: locale,
  gloved: gloved,
);

void main() {
  group('ResultCitationFootnote', () {
    testWidgets('prints the instrument, the article and both dates', (WidgetTester tester) async {
      await _pumpRow(tester);

      // An uncited verdict is an opinion, and a citation the reader has to go
      // looking for is not evidence at the counter.
      expect(find.textContaining('Ministerial Decision 580/2015'), findsOneWidget);
      expect(find.textContaining('Art. 3'), findsOneWidget);
      expect(find.textContaining('2015-11-03'), findsOneWidget);
      expect(find.textContaining('2026-07-14'), findsOneWidget);
    });

    testWidgets('prints the jurisdiction ahead of the instrument', (WidgetTester tester) async {
      await _pumpRow(tester);

      final List<String> texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data ?? '')
          .toList();
      expect(
        texts.indexWhere((String s) => s.contains('United Arab Emirates')),
        lessThan(texts.indexWhere((String s) => s.contains('Ministerial Decision'))),
      );
    });

    testWidgets('es - prints both dates in unlocalised ISO form', (WidgetTester tester) async {
      await _pumpRow(tester, locale: const Locale('es'));

      // The same string in six locales, comparable against a printed
      // instrument by eye.
      expect(find.textContaining('2015-11-03'), findsOneWidget);
      expect(find.textContaining('03/11/2015'), findsNothing);
    });

    testWidgets('ar - prints Western digits in the dates', (WidgetTester tester) async {
      await _pumpRow(tester, locale: const Locale('ar'));

      // Quoted from a printed instrument, not formatted for the reader.
      expect(find.textContaining('2015-11-03'), findsOneWidget);
      expect(find.textContaining('٢٠١٥'), findsNothing);
    });

    testWidgets('renders the citation with no expansion affordance', (WidgetTester tester) async {
      await _pumpRow(tester);

      // No ExpansionTile and no collapsed state: rule 11 bans hiding the four
      // fields. A tooltip on the copy CONTROL is not the citation being hidden
      // — it is the control's accessible name, which check_lonja_buttons
      // requires — so what is asserted here is that the citation text itself is
      // on the page with no interaction at all.
      expect(find.byType(ExpansionTile), findsNothing);
      expect(find.textContaining('Ministerial Decision 580/2015'), findsOneWidget);
      expect(find.textContaining('published 2015-11-03'), findsOneWidget);
    });

    testWidgets('copies the printed citation line and not the verdict', (
      WidgetTester tester,
    ) async {
      String? copied;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await _pumpRow(tester);
      await tester.tap(find.byKey(ResultCitationFootnote.copyKey));
      await tester.pump();

      // What is copied equals what is printed. A verdict on the clipboard is a
      // statement about one fish, detached from its source.
      expect(copied, contains('Ministerial Decision 580/2015'));
      expect(copied, contains('Art. 3'));
      expect(copied, contains('published 2015-11-03'));
      expect(copied, contains('checked 2026-07-14'));
      expect(copied, isNot(contains('minimum')));
      expect(copied, isNot(contains('Below')));
    });

    testWidgets('invokes onOpenRuleText with the citation id when tapped', (
      WidgetTester tester,
    ) async {
      final opened = <int>[];
      await _pumpRow(tester, onOpen: opened.add);

      await tester.tap(find.byKey(ResultCitationFootnote.openKey));
      await tester.pump();

      expect(opened, <int>[4]);
    });

    testWidgets('renders the source url as selectable text with no gesture', (
      WidgetTester tester,
    ) async {
      await _pumpRow(tester);

      // §5.3: an ACTION_VIEW fetches under the browser's own permission and
      // defeats the Android guarantee. The reader is the actor.
      final SelectableText url = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(url.data, contains('xunta.gal'));
      expect(url.onTap, isNull);
    });

    testWidgets('omits the url line when the instrument records none', (WidgetTester tester) async {
      await _pumpRow(tester, sourceUrl: null);

      expect(find.byType(SelectableText), findsNothing);
    });

    testWidgets('exposes the rule text as a button at the standard target size', (
      WidgetTester tester,
    ) async {
      await _pumpRow(tester);

      // A subset match: the node also carries the merged text of the block,
      // and pinning that would make this a test about wording rather than
      // about the affordance.
      expect(
        tester.getSemantics(find.byKey(ResultCitationFootnote.openKey)),
        isSemantics(isButton: true, hasTapAction: true),
      );
      expect(
        tester.getSize(find.byKey(ResultCitationFootnote.openKey)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('glove - exposes the rule text at the glove target size', (
      WidgetTester tester,
    ) async {
      await _pumpRow(tester, gloved: true);

      expect(
        tester.getSize(find.byKey(ResultCitationFootnote.openKey)).height,
        greaterThanOrEqualTo(56),
      );
    });

    testWidgets('RTL - starts the footnote rule at the start edge', (WidgetTester tester) async {
      await _pumpRow(tester, locale: const Locale('ar'));

      // A physically-left rule under RTL detaches the footnote from its text.
      final Rect rule = tester.getRect(find.byKey(ResultCitationFootnote.footnoteRuleKey));
      final Rect block = tester.getRect(find.byType(ResultCitationFootnote));
      expect(rule.right, closeTo(block.right, 0.5));
    });

    testWidgets('ar - isolates the Latin instrument run', (WidgetTester tester) async {
      await _pumpRow(tester, locale: const Locale('ar'));

      // Without isolation the trailing article number jumps to the wrong end of
      // the line.
      final Text instrument = tester.widget<Text>(
        find.textContaining('Ministerial Decision 580/2015'),
      );
      expect(instrument.data, contains('\u2066'));
      expect(instrument.data, contains('\u2069'));
    });
  });
}
