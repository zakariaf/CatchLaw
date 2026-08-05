import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/domain/models/legal_article.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/reference/widgets/rule_text_screen.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_citation_footnote.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_legal_text_repository.dart';
import '../../../testing/models/result_fixtures.dart';

const String _authority = 'Ministry of Climate Change and Environment';

const LegalArticle _article = LegalArticle(
  locale: 'ar',
  body: 'يحظر صيد أو بيع أو حيازة الأنواع المدرجة في الجدول رقم (1) المرفق بهذا القرار.',
  sortOrder: 1,
  articleRef: 'Art. 3',
);

/// The tap the fisher makes: the footnote under a verdict, wired the way S2
/// wires it.
Widget _footnote(BuildContext context) => ResultCitationFootnote(
  citation: kCitationDisplayMd580,
  citationId: 7,
  jurisdiction: _authority,
  marker: 1,
  onOpenRuleText: (int citationId, CitationDisplay citation) => Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext context) =>
          RuleTextRoute(citationId: citationId, citation: citation, authority: _authority),
    ),
  ),
);

Future<void> _pump(WidgetTester tester, FakeLegalTextRepository legalText) => tester.pumpWidget(
  ProviderScope(
    // Mirrors main(). Without it Riverpod 3 retries a provider whose build
    // threw, with backoff, and a failing read never reaches AsyncError.
    retry: noRetry,
    overrides: <Override>[legalTextRepositoryProvider.overrideWithValue(legalText)],
    child: MaterialApp(
      theme: LonjaTheme.paper(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: Builder(builder: _footnote)),
    ),
  ),
);

void main() {
  group('RuleTextRoute', () {
    testWidgets('opens the verbatim text of the citation the footnote was tapped on', (
      WidgetTester tester,
    ) async {
      // SPEC.md §14's device checklist: tapping a citation reaches the bundled
      // text. Before this the footnote announced itself as a button and did
      // nothing at all.
      final legalText = FakeLegalTextRepository(<int, List<LegalArticle>>{
        7: <LegalArticle>[_article],
      });
      await _pump(tester, legalText);

      await tester.tap(find.byKey(ResultCitationFootnote.openKey));
      await tester.pumpAndSettle();

      expect(legalText.asked, <int>[7]);
      expect(find.byType(RuleTextScreen), findsOneWidget);
      expect(find.text(_article.body), findsOneWidget);
    });

    testWidgets('heads the page with the instrument the footnote printed', (
      WidgetTester tester,
    ) async {
      // Carried through the tap rather than looked up again: a second lookup is
      // how the head of the article page and the footnote under the verdict
      // come to disagree.
      await _pump(
        tester,
        FakeLegalTextRepository(<int, List<LegalArticle>>{
          7: <LegalArticle>[_article],
        }),
      );

      await tester.tap(find.byKey(ResultCitationFootnote.openKey));
      await tester.pumpAndSettle();

      final RuleTextScreen page = tester.widget<RuleTextScreen>(find.byType(RuleTextScreen));
      expect(page.citation, kCitationDisplayMd580);
      expect(page.authority, _authority);
    });

    testWidgets('states a failed read and never an instrument with no text', (
      WidgetTester tester,
    ) async {
      // "Nothing was transcribed" is a claim about the law. Making it when the
      // device could not read the file invents the absence of a text.
      final AppLocalizations l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await _pump(
        tester,
        FakeLegalTextRepository(
          const <int, List<LegalArticle>>{},
          failure: const DataNotFound(entity: 'legal_text', id: '7'),
        ),
      );

      await tester.tap(find.byKey(ResultCitationFootnote.openKey));
      await tester.pumpAndSettle();

      expect(find.text(l10n.ruleTextNoneRecordedHeadline), findsNothing);
      expect(find.byType(RuleTextScreen), findsNothing);
    });

    testWidgets('keeps the way back on the article page', (WidgetTester tester) async {
      final AppLocalizations l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await _pump(
        tester,
        FakeLegalTextRepository(<int, List<LegalArticle>>{
          7: <LegalArticle>[_article],
        }),
      );

      await tester.tap(find.byKey(ResultCitationFootnote.openKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(l10n.navBack));
      await tester.pumpAndSettle();

      // A pushed screen with no back affordance is a screen the fisher is
      // stuck on.
      expect(find.byType(RuleTextScreen), findsNothing);
      expect(find.byType(ResultCitationFootnote), findsOneWidget);
    });
  });
}
