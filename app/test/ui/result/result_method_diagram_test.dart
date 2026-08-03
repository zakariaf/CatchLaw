import 'package:catchlaw/ui/result/widgets/result_method_diagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

/// The asset the diagram actually asked the bundle for.
String _assetOf(WidgetTester tester) =>
    (tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader as SvgAssetLoader).assetName;

Future<void> _pumpDiagram(
  WidgetTester tester, {
  String? asset = 'assets/method/tl_arrow.svg',
  String method = 'Total length',
  Locale locale = const Locale('en'),
}) => pumpLonja(
  tester,
  ResultMethodDiagram(assetPath: asset, methodName: method),
  locale: locale,
);

void main() {
  group('ResultMethodDiagram', () {
    testWidgets('loads the asset the rule row names', (WidgetTester tester) async {
      await _pumpDiagram(tester);

      expect(_assetOf(tester), 'assets/method/tl_arrow.svg');
    });

    testWidgets('renders a different asset for a second jurisdiction rule', (
      WidgetTester tester,
    ) async {
      // The same species, measured differently in two countries: the diagram
      // comes from the rule row, never from the species.
      await _pumpDiagram(tester, asset: 'assets/method/fl_arrow.svg', method: 'Fork length');

      expect(_assetOf(tester), 'assets/method/fl_arrow.svg');
    });

    testWidgets('renders nothing when the rule row states no method', (WidgetTester tester) async {
      await _pumpDiagram(tester, asset: null);

      // A blank ruled frame reads as a missing illustration.
      expect(find.byType(SvgPicture), findsNothing);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('RTL - does not mirror the drawing', (WidgetTester tester) async {
      await _pumpDiagram(tester, locale: const Locale('ar'));

      // A mirrored fork-length arrow points at the snout.
      expect(Directionality.of(tester.element(find.byType(SvgPicture))), TextDirection.ltr);
    });

    testWidgets('RTL - localises the caption outside the LTR island', (WidgetTester tester) async {
      await _pumpDiagram(tester, locale: const Locale('ar'), method: 'الطول الكلي');

      // The exception is the drawing, not the words about it.
      expect(Directionality.of(tester.element(find.text('الطول الكلي'))), TextDirection.rtl);
    });

    testWidgets('names the method for a screen reader', (WidgetTester tester) async {
      await _pumpDiagram(tester);

      // An unlabelled drawing is invisible to TalkBack.
      expect(find.bySemanticsLabel('Total length'), findsWidgets);
    });

    testWidgets('asks the bundle and nothing else', (WidgetTester tester) async {
      await _pumpDiagram(tester);

      // §5.3 and §14: nothing on this screen fetches. SvgPicture.network is
      // grep-banned; this asserts the loader that is actually constructed.
      expect(tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader, isA<SvgAssetLoader>());
    });
  });
}
