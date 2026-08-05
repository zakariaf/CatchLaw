import 'package:catchlaw/domain/models/legal_article.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_empty_state.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_search_field.dart';
import 'package:catchlaw/ui/reference/widgets/rule_text_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../../../testing/theme/pump_lonja.dart';

const String _authority = 'Ministry of Climate Change and Environment';

const LegalArticle _article = LegalArticle(
  locale: 'ar',
  body: 'يحظر صيد أو بيع أو حيازة الأنواع المدرجة في الجدول رقم (1) المرفق بهذا القرار.',
  sortOrder: 1,
  articleRef: 'Art. 3',
);

const LegalArticle _closure = LegalArticle(
  locale: 'ar',
  body:
      'تحدد فترات حظر الصيد على النحو الآتي: الشعري والصافي من الأول من مارس حتى الثلاثين من أبريل.',
  sortOrder: 2,
  articleRef: 'Art. 4',
);

Future<void> _pumpReader(
  WidgetTester tester, {
  List<LegalArticle> articles = const <LegalArticle>[_article, _closure],
  Locale locale = const Locale('en'),
}) => pumpLonja(
  tester,
  RuleTextScreen(citation: kCitationDisplayMd580, authority: _authority, articles: articles),
  locale: locale,
);

/// The vertical position of [finder]'s top edge, for the order assertions.
double _top(WidgetTester tester, Finder finder) => tester.getTopLeft(finder).dy;

/// [matching], on the page itself rather than in the band or the chip strip.
///
/// The instrument is printed twice on purpose — stamped on the band and set as
/// the masthead headline — and the article numbers three times: once per chip
/// and once per margin marker. An unscoped finder cannot tell them apart, and
/// an order assertion that picked the band would pass whatever the page did.
Finder _onPage(Finder matching) =>
    find.descendant(of: find.byKey(RuleTextScreen.scrollKey), matching: matching);

/// [matching], inside the chip strip.
Finder _inChips(Finder matching) =>
    find.descendant(of: find.byKey(RuleTextScreen.chipsKey), matching: matching);

void main() {
  group('RuleTextScreen', () {
    testWidgets('renders the verbatim article for the tapped citation', (
      WidgetTester tester,
    ) async {
      await _pumpReader(tester);

      expect(find.text(_article.body), findsOneWidget);
      expect(find.textContaining('Ministerial Decision 580/2015'), findsWidgets);
    });

    testWidgets('heads the page with a band carrying the way back and the instrument', (
      WidgetTester tester,
    ) async {
      // A pushed screen with no back affordance is a screen the fisher is
      // stuck on, and the gap survey records that this one had no band at all.
      await _pumpReader(tester);

      final LonjaScreenBar bar = tester.widget<LonjaScreenBar>(find.byType(LonjaScreenBar));
      final AppLocalizations l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(bar.title, l10n.referenceEntryRuleText);
      // The band takes the mark, the masthead takes the name: a stamp is
      // checked-against-what, not the document's title set twice.
      expect(bar.sup, contains('Art. 3'));
      expect(bar.sup, isNot(contains('Ministerial Decision')));
    });

    testWidgets('sets the masthead over the articles: authority, instrument, dates, rule', (
      WidgetTester tester,
    ) async {
      // The order IS the argument the page makes. The article number belongs
      // in the margin, never fused into the headline above the text.
      await _pumpReader(tester);
      final AppLocalizations l10n = await AppLocalizations.delegate.load(const Locale('en'));

      final double authority = _top(tester, _onPage(find.text(_authority.toUpperCase())));
      final double instrument = _top(
        tester,
        _onPage(find.textContaining('Ministerial Decision 580/2015')),
      );
      final double dates = _top(tester, _onPage(find.textContaining(l10n.ruleTextPublishedLabel)));
      final double rule = _top(tester, find.byKey(RuleTextScreen.mastheadRuleKey));
      final double body = _top(tester, find.text(_article.body));

      expect(authority, lessThan(instrument));
      expect(instrument, lessThan(dates));
      expect(dates, lessThan(rule));
      expect(rule, lessThan(body));
    });

    testWidgets('prints the two dates in mono beside prose labels', (WidgetTester tester) async {
      await _pumpReader(tester);
      final BuildContext context = tester.element(find.byType(RuleTextScreen));
      final LonjaTypeScale type = LonjaType.of(context);
      final AppLocalizations l10n = AppLocalizations.of(context);

      final Text line = tester.widget<Text>(find.textContaining(l10n.ruleTextPublishedLabel));
      final spans = <InlineSpan>[];
      line.textSpan!.visitChildren((InlineSpan span) {
        spans.add(span);
        return true;
      });
      final figures = <InlineSpan>[
        for (final InlineSpan span in spans)
          if (span is TextSpan && (span.text == '2015-11-03' || span.text == '2026-07-14')) span,
      ];

      // Both figures, and both in the mono citation step: a date set in the
      // prose face cannot be read off against a printed gazette.
      expect(figures, hasLength(2));
      for (final figure in figures) {
        expect((figure as TextSpan).style!.fontFamily, type.citation.fontFamily);
      }
    });

    testWidgets('sets the article number in the margin and never as a heading', (
      WidgetTester tester,
    ) async {
      await _pumpReader(tester);
      final BuildContext context = tester.element(find.byType(RuleTextScreen));
      final LonjaTypeScale type = LonjaType.of(context);

      final Finder margin = _onPage(find.text('Art. 3'));
      final Text marker = tester.widget<Text>(margin);
      // Mono, end-aligned against the gutter rule, and beside the text rather
      // than above it.
      expect(marker.style!.fontFamily, type.articleNumber.fontFamily);
      expect(marker.textAlign, TextAlign.end);
      expect(tester.getTopLeft(find.text(_article.body)).dy, closeTo(_top(tester, margin), 8));
      expect(
        tester.getBottomRight(margin).dx,
        lessThan(tester.getTopLeft(find.text(_article.body)).dx),
      );
    });

    testWidgets('justifies the article body to the gutter rule', (WidgetTester tester) async {
      await _pumpReader(tester);

      expect(tester.widget<Text>(find.text(_article.body)).textAlign, TextAlign.justify);
    });

    testWidgets('never truncates the article body', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
            child: const RuleTextScreen(
              citation: kCitationDisplayMd580,
              authority: _authority,
              articles: <LegalArticle>[_article],
            ),
          ),
        ),
      );

      // At twice the type size the masthead fills the viewport, so the article
      // is a sliver that has not been built yet — which is the page scrolling
      // instead of clamping, and is the behaviour under test.
      await tester.dragUntilVisible(
        find.text(_article.body),
        find.byKey(RuleTextScreen.scrollKey),
        const Offset(0, -120),
      );
      await tester.pumpAndSettle();

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
      await _pumpReader(tester, locale: const Locale('gl'));

      expect(tester.widget<Text>(find.text(_article.body)).textDirection, TextDirection.rtl);
    });

    testWidgets('carries an entry line over the full text', (WidgetTester tester) async {
      await _pumpReader(tester);
      final AppLocalizations l10n = await AppLocalizations.delegate.load(const Locale('en'));

      final LonjaSearchField field = tester.widget<LonjaSearchField>(
        find.byKey(RuleTextScreen.searchKey),
      );
      expect(field.hint, l10n.ruleTextSearchHint);
      expect(
        _top(tester, find.byKey(RuleTextScreen.searchKey)),
        lessThan(_top(tester, find.byKey(RuleTextScreen.chipsKey))),
      );
    });

    testWidgets('narrows to one article when its chip is chosen', (WidgetTester tester) async {
      await _pumpReader(tester);

      await tester.tap(_inChips(find.text('Art. 4')));
      await tester.pumpAndSettle();

      expect(find.text(_closure.body), findsOneWidget);
      expect(find.text(_article.body), findsNothing);
    });

    testWidgets('shows the instrument whole again from the leading chip', (
      WidgetTester tester,
    ) async {
      // A filter the reader cannot get out of is a page that has swallowed the
      // rest of the law.
      final AppLocalizations l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await _pumpReader(tester);

      await tester.tap(_inChips(find.text('Art. 4')));
      await tester.pumpAndSettle();
      await tester.tap(_inChips(find.text(l10n.ruleTextAllArticles)));
      await tester.pumpAndSettle();

      expect(find.text(_article.body), findsOneWidget);
      expect(find.text(_closure.body), findsOneWidget);
    });

    testWidgets('keeps only the articles the entry line matches', (WidgetTester tester) async {
      await _pumpReader(tester);

      await tester.enterText(find.byType(TextField), 'مارس');
      await tester.pumpAndSettle();

      expect(find.text(_closure.body), findsOneWidget);
      expect(find.text(_article.body), findsNothing);
    });

    testWidgets('states that nothing matched rather than printing a blank page', (
      WidgetTester tester,
    ) async {
      final AppLocalizations l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await _pumpReader(tester);

      await tester.enterText(find.byType(TextField), 'zzzznotinthetext');
      await tester.pumpAndSettle();

      expect(find.byType(LonjaEmptyState), findsOneWidget);
      expect(find.text(l10n.ruleTextNoMatchHeadline), findsOneWidget);
    });

    testWidgets('states that no text was transcribed when the pack carries none', (
      WidgetTester tester,
    ) async {
      // Not the same fact as "nothing matched", and never permission: the
      // citation is still on the page above it.
      final AppLocalizations l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await _pumpReader(tester, articles: const <LegalArticle>[]);

      expect(find.text(l10n.ruleTextNoneRecordedHeadline), findsOneWidget);
      expect(find.textContaining('Ministerial Decision 580/2015'), findsWidgets);
      expect(find.byKey(RuleTextScreen.chipsKey), findsNothing);
    });

    testWidgets('closes on the apparatus: the short rule, then what this copy holds', (
      WidgetTester tester,
    ) async {
      final AppLocalizations l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await _pumpReader(tester);

      expect(find.byKey(RuleTextScreen.footnoteRuleKey), findsOneWidget);
      expect(find.text(l10n.ruleTextCompleteNote), findsOneWidget);
      expect(
        _top(tester, find.text(_closure.body)),
        lessThan(_top(tester, find.byKey(RuleTextScreen.footnoteRuleKey))),
      );
    });

    testWidgets('names the one language the text exists in when it is not the reader’s', (
      WidgetTester tester,
    ) async {
      // SPEC.md §9.6: the law is never translated, so what the page states is
      // which language it is in — a fact about the data, not an instruction.
      final AppLocalizations l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await _pumpReader(tester);

      expect(find.text(l10n.legalTextLanguageNotice(l10n.languageName('ar'))), findsOneWidget);
    });

    testWidgets('prints no language notice when the law is in the reader’s language', (
      WidgetTester tester,
    ) async {
      final AppLocalizations l10n = await AppLocalizations.delegate.load(const Locale('ar'));
      await _pumpReader(tester, locale: const Locale('ar'));

      expect(find.text(l10n.legalTextLanguageNotice(l10n.languageName('ar'))), findsNothing);
    });
  });
}
