import 'package:catchlaw/domain/models/legal_article.dart';
import 'package:catchlaw/ui/reference/widgets/rule_text_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../../../testing/theme/pump_lonja.dart';

const LegalArticle _article = LegalArticle(
  locale: 'ar',
  body: 'يحظر صيد أو بيع أو حيازة الأنواع المدرجة في الجدول رقم (1) المرفق بهذا القرار.',
  sortOrder: 1,
  articleRef: 'Art. 3',
);

void main() {
  group('RuleTextScreen', () {
    testWidgets('renders the verbatim article for the tapped citation', (
      WidgetTester tester,
    ) async {
      await pumpLonja(
        tester,
        const RuleTextScreen(citation: kCitationDisplayMd580, articles: <LegalArticle>[_article]),
      );

      expect(find.text(_article.body), findsOneWidget);
      expect(find.textContaining('Ministerial Decision 580/2015'), findsOneWidget);
    });

    testWidgets('renders the checked-on date in the header', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        const RuleTextScreen(citation: kCitationDisplayMd580, articles: <LegalArticle>[_article]),
      );

      // The reader has to know how current the transcription is.
      expect(find.textContaining('checked 2026-07-14'), findsOneWidget);
    });

    testWidgets('never truncates the article body', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
            child: const RuleTextScreen(
              citation: kCitationDisplayMd580,
              articles: <LegalArticle>[_article],
            ),
          ),
        ),
      );

      // Truncating legal text removes the clause that makes the verdict
      // defensible.
      final Text body = tester.widget<Text>(find.text(_article.body));
      expect(body.maxLines, isNull);
      expect(body.overflow, isNot(TextOverflow.ellipsis));
      expect(tester.takeException(), isNull);
    });

    testWidgets('reads the law in the direction its own language reads', (
      WidgetTester tester,
    ) async {
      // Arabic law reads right-to-left on a Galician phone: the direction is
      // the LAW's, never the reader's.
      await pumpLonja(
        tester,
        const RuleTextScreen(citation: kCitationDisplayMd580, articles: <LegalArticle>[_article]),
        locale: const Locale('gl'),
      );

      expect(tester.widget<Text>(find.text(_article.body)).textDirection, TextDirection.rtl);
    });
  });
}
