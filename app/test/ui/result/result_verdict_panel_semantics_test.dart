import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/ui/result/widgets/result_verdict_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../../../testing/theme/pump_lonja.dart';

void main() {
  group('ResultVerdictPanel', () {
    testWidgets('announces the verdict as a live region', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        const ResultVerdictPanel(stamp: kStampBelowMinimum, citation: kCitationDisplayMd580),
      );

      final SemanticsNode node = tester.getSemantics(find.byType(ResultVerdictPanel));
      // §4.9's screen-reader requirement, stated as a fact about the tree: the
      // answer is announced when it arrives, without the reader hunting for it.
      expect(node, matchesSemantics(label: node.label, isHeader: true, isLiveRegion: true));
    });

    testWidgets('announces the category before the measurement', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        const ResultVerdictPanel(stamp: kStampBelowMinimum, citation: kCitationDisplayMd580),
      );

      final String label = tester.getSemantics(find.byType(ResultVerdictPanel)).label;
      expect(label.indexOf('Below the minimum'), lessThan(label.indexOf('38')));
    });

    testWidgets('reads the verdict as one node', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        const ResultVerdictPanel(stamp: kStampBelowMinimum, citation: kCitationDisplayMd580),
      );

      // Three sibling nodes would be read in three orders — three chances to
      // hear "38 centimetres" without hearing what it fails.
      final SemanticsNode node = tester.getSemantics(find.byType(ResultVerdictPanel));
      expect(node.childrenCount, 0);
      expect(node.label, contains('Below the minimum'));
      expect(node.label, contains('Short of the minimum by'));
    });

    testWidgets('excludes the glyph from the semantics tree', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        const ResultVerdictPanel(stamp: kStampBelowMinimum, citation: kCitationDisplayMd580),
      );

      // The glyph says exactly what the headline beside it says; a second node
      // reads it twice.
      expect(tester.widget<LonjaIcon>(find.byType(LonjaIcon)).semanticLabel, isNull);
      expect(
        find.descendant(of: find.byType(LonjaIcon), matching: find.byType(Semantics)),
        findsNothing,
      );
    });

    testWidgets('announces nothing further when rebuilt with an identical stamp', (
      WidgetTester tester,
    ) async {
      await pumpLonja(
        tester,
        const ResultVerdictPanel(stamp: kStampBelowMinimum, citation: kCitationDisplayMd580),
      );
      final SemanticsNode first = tester.getSemantics(find.byType(ResultVerdictPanel));
      final String label = first.label;

      await pumpLonja(
        tester,
        const ResultVerdictPanel(stamp: kStampBelowMinimum, citation: kCitationDisplayMd580),
      );

      // The ruler emits several times a second. An identical stamp must produce
      // an identical node, or every reading re-announces the verdict.
      final SemanticsNode second = tester.getSemantics(find.byType(ResultVerdictPanel));
      expect(second.label, label);
      expect(second.id, first.id);
    });
  });
}
