import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_findings_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../../../testing/theme/pump_lonja.dart';

Future<void> _pumpList(
  WidgetTester tester,
  List<FindingDisplay> findings, {
  Locale locale = const Locale('en'),
}) => pumpLonja(tester, ResultFindingsList(findings: findings), locale: locale);

/// Every glyph the list drew, in tree order.
List<LonjaGlyph> _glyphs(WidgetTester tester) =>
    tester.widgetList<LonjaIcon>(find.byType(LonjaIcon)).map((LonjaIcon i) => i.glyph).toList();

/// Every rendered string, in tree order.
List<String> _texts(WidgetTester tester) =>
    tester.widgetList<Text>(find.byType(Text)).map((Text t) => t.data ?? '').toList();

void main() {
  group('ResultFindingsList', () {
    testWidgets('renders one row per finding', (WidgetTester tester) async {
      await _pumpList(tester, const <FindingDisplay>[
        kFindingMinSizeFails,
        kFindingMaxSizeSatisfied,
        kFindingBagLimitFails,
      ]);

      expect(_glyphs(tester), hasLength(3));
    });

    testWidgets('preserves the engine order when the list is not sorted by severity', (
      WidgetTester tester,
    ) async {
      // Delivered least-severe first on purpose: the engine ranked once, and a
      // widget that "fixes" the order re-decides legal precedence.
      await _pumpList(tester, const <FindingDisplay>[kFindingBagLimitFails, kFindingMinSizeFails]);

      final List<String> texts = _texts(tester);
      expect(
        texts.indexWhere((String s) => s.contains('bag limit')),
        lessThan(texts.indexWhere((String s) => s.contains('minimum'))),
      );
    });

    testWidgets('names the instrument and the article on every row', (WidgetTester tester) async {
      await _pumpList(tester, const <FindingDisplay>[kFindingMinSizeFails, kFindingBagLimitFails]);

      expect(find.textContaining('Ministerial Decision 580/2015 · Art. 3'), findsOneWidget);
      expect(find.textContaining('Orde do 27 de xullo de 2012 · Art. 4'), findsOneWidget);
    });

    testWidgets('marks each row with the footnote its citation carries', (
      WidgetTester tester,
    ) async {
      await _pumpList(tester, const <FindingDisplay>[kFindingMinSizeFails, kFindingBagLimitFails]);

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('reuses one marker for two findings from the same instrument', (
      WidgetTester tester,
    ) async {
      await _pumpList(tester, const <FindingDisplay>[
        kFindingMinSizeFails,
        kFindingMaxSizeSatisfied,
      ]);

      // Two markers for one instrument would say two instruments were read.
      expect(find.text('1'), findsNWidgets(2));
      expect(find.text('2'), findsNothing);
    });

    testWidgets('renders a satisfied rule as a stated finding', (WidgetTester tester) async {
      await _pumpList(tester, const <FindingDisplay>[kFindingMaxSizeSatisfied]);

      // A read-and-satisfied rule is not the same as a rule nobody transcribed.
      expect(find.textContaining('Within the maximum'), findsOneWidget);
      expect(_glyphs(tester).single, LonjaIcons.tick);
    });

    testWidgets('renders an unrecorded bag limit as an open question', (WidgetTester tester) async {
      await _pumpList(tester, const <FindingDisplay>[kFindingBagLimitIndeterminate]);

      expect(find.textContaining('Nothing recorded'), findsOneWidget);
      expect(_glyphs(tester).single, LonjaIcons.openQuestion);
      expect(_glyphs(tester).single, isNot(LonjaIcons.tick));
    });

    testWidgets('inks a satisfied rule differently from a failed one', (WidgetTester tester) async {
      await _pumpList(tester, const <FindingDisplay>[
        kFindingMinSizeFails,
        kFindingMaxSizeSatisfied,
      ]);

      final List<Color?> inks = tester
          .widgetList<LonjaIcon>(find.byType(LonjaIcon))
          .map((LonjaIcon i) => i.color)
          .toList();
      expect(inks.first, isNot(inks.last));
    });

    testWidgets('pairs a glyph with a word on every row', (WidgetTester tester) async {
      await _pumpList(tester, const <FindingDisplay>[
        kFindingMinSizeFails,
        kFindingMaxSizeSatisfied,
        kFindingBagLimitIndeterminate,
      ]);

      // Colour alone fails greyscale and eight percent of readers.
      expect(_glyphs(tester).toSet(), hasLength(3));
      for (final FindingDisplay finding in const <FindingDisplay>[
        kFindingMinSizeFails,
        kFindingMaxSizeSatisfied,
        kFindingBagLimitIndeterminate,
      ]) {
        expect(find.text(finding.sentence), findsOneWidget);
      }
    });

    testWidgets('renders nothing when there are no findings', (WidgetTester tester) async {
      await _pumpList(tester, const <FindingDisplay>[]);

      // An empty ruled block reads as content that failed to load.
      expect(find.byType(LonjaIcon), findsNothing);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('states the method in words on every measurement row', (WidgetTester tester) async {
      await _pumpList(tester, const <FindingDisplay>[
        kFindingMinSizeFails,
        kFindingMaxSizeSatisfied,
      ]);

      // A bare TL turns a correct number into a wrong verdict.
      expect(find.textContaining('(Total length)'), findsNWidgets(2));
    });

    testWidgets('uses tabular figures for the marker and the citation', (
      WidgetTester tester,
    ) async {
      await _pumpList(tester, const <FindingDisplay>[kFindingMinSizeFails]);
      final LonjaTypeScale type = LonjaType.of(tester.element(find.byType(ResultFindingsList)));

      // 38 cm and 188 cm share a decimal spine, or the column reads as noise.
      expect(
        tester.widget<Text>(find.text('1')).style?.fontFeatures,
        type.articleNumber.fontFeatures,
      );
      expect(
        tester.widget<Text>(find.textContaining('Ministerial Decision')).style?.fontFeatures,
        type.citation.fontFeatures,
      );
    });

    testWidgets('RTL - places the marker at the start edge', (WidgetTester tester) async {
      await _pumpList(tester, const <FindingDisplay>[
        kFindingMinSizeFails,
      ], locale: const Locale('ar'));

      final double marker = tester.getTopRight(find.text('1')).dx;
      final double sentence = tester.getTopRight(find.text(kFindingMinSizeFails.sentence)).dx;
      expect(marker, greaterThan(sentence), reason: 'start is the right edge under RTL');
    });

    testWidgets('survives a 200 percent text scale with no overflow', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
            child: const SingleChildScrollView(
              child: ResultFindingsList(
                findings: <FindingDisplay>[kFindingMinSizeFails, kFindingBagLimitFails],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
