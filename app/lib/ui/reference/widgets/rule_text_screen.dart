import 'package:catchlaw/domain/models/legal_article.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/locale_codec.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/format/bidi_isolate.dart';
import 'package:catchlaw/ui/core/ui/lonja_empty_state.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_search_field.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/reference/view_models/rule_text_view_model.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule_engine/rule_engine.dart' show normaliseSpeciesTerm;

/// S13 — what the instrument actually says, verbatim.
///
/// **A page of a gazette, set top to bottom in the order the mockup sets it:**
/// the ruled band naming the instrument, the entry line over the whole text,
/// the article chips, then the masthead — issuing authority, instrument,
/// published and checked — closed by a 2 pt rule, then the articles themselves
/// with their numbers in the margin, and the apparatus last.
///
/// **The article number lives in the margin, not in the headline.** A number
/// set as a heading reads as the name of the thing below it; set in the gutter
/// against a vertical rule it reads as what it is — a reference mark the fisher
/// compares against a printed page while an inspector waits.
///
/// **Nothing is truncated.** No `maxLines`, no ellipsis, no clamped text scale
/// on any article: the clause that gets cut is the one that makes the verdict
/// defensible, and the page scrolls instead.
///
/// **The two controls narrow, they do not fetch.** The entry line filters the
/// articles already in hand and the chips select one of them; neither asks the
/// database a second question, so both answer at the speed of a rebuild with no
/// signal and no disk. E15's FTS pass over `body_norm` replaces the filter with
/// an index; it does not change what this page is.
class RuleTextScreen extends StatefulWidget {
  /// Shows [articles] of [citation], published by [authority].
  const RuleTextScreen({
    required this.citation,
    required this.authority,
    required this.articles,
    super.key,
  });

  /// The page's own scroll view, for tests that drive it.
  static const Key scrollKey = Key('rule-text-scroll');

  /// The entry line over the whole text.
  static const Key searchKey = Key('rule-text-search');

  /// The article chips, in reading order behind the leading "all" cell.
  static const Key chipsKey = Key('rule-text-chips');

  /// The 2 pt rule that closes the masthead.
  static const Key mastheadRuleKey = Key('rule-text-masthead-rule');

  /// The short rule that opens the closing apparatus.
  static const Key footnoteRuleKey = Key('rule-text-footnote-rule');

  /// The instrument, printed as a masthead so the reader knows what he is in.
  final CitationDisplay citation;

  /// The body that published it, already localised.
  ///
  /// The eyebrow above the instrument, and the first line of the masthead: an
  /// article with no authority over it is a paragraph of text nobody can place.
  final String authority;

  /// Its articles, in reading order, in the language of publication.
  final List<LegalArticle> articles;

  @override
  State<RuleTextScreen> createState() => _RuleTextScreenState();
}

class _RuleTextScreenState extends State<RuleTextScreen> {
  /// What the reader has typed, folded the way the pack was folded.
  ///
  /// Folded by the engine's own `normaliseSpeciesTerm` and never by
  /// `toLowerCase` alone: `body_norm` was written by that exact function, and a
  /// query folded any other way misses every Arabic orthographic variant —
  /// silently, which reads as "the text is not in the app".
  String _query = '';

  /// The article the chips have narrowed to, or null for the whole instrument.
  String? _articleRef;

  void _onQueryChanged(String value) => setState(() => _query = normaliseSpeciesTerm(value));

  void _onChipChosen(String? ref) => setState(() => _articleRef = ref);

  /// The articles left standing after the two controls.
  List<LegalArticle> get _shown => <LegalArticle>[
    for (final LegalArticle article in widget.articles)
      if ((_articleRef == null || article.articleRef == _articleRef) &&
          (_query.isEmpty || normaliseSpeciesTerm(article.body).contains(_query)))
        article,
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final refs = <String>[
      for (final LegalArticle article in widget.articles)
        if (article.articleRef case final String ref) ref,
    ];
    final List<LegalArticle> shown = _shown;

    return Scaffold(
      appBar: LonjaScreenBar(
        title: l10n.referenceEntryRuleText,
        // The article this page was opened for, stamped the way the mockup
        // stamps the instrument's short number. The band takes a MARK and not
        // a name: laid out beside a flexible title it keeps its full intrinsic
        // width, so an instrument name set there overflows the band at a large
        // text scale — and the instrument is printed whole in the masthead one
        // line below. Latin script in every pack that ships, so it is isolated:
        // inside an Arabic band it would otherwise reorder around its digits.
        sup: isolateLtr(widget.citation.article),
        onBack: navigator.canPop() ? navigator.pop : null,
      ),
      body: SafeArea(
        // The band has already taken the status bar; taking it twice prints
        // the entry line a band lower than the rule it opens under.
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                tokens.density.gutter,
                LonjaSpace.s3,
                tokens.density.gutter,
                0,
              ),
              child: LonjaSearchField(
                key: RuleTextScreen.searchKey,
                hint: l10n.ruleTextSearchHint,
                semanticLabel: l10n.ruleTextSearchHint,
                onChanged: _onQueryChanged,
              ),
            ),
            if (refs.isNotEmpty)
              _ArticleChips(refs: refs, selected: _articleRef, onChosen: _onChipChosen),
            Expanded(
              // The baseline grid the mockup rules the reading column with. It
              // is fixed to the viewport rather than to the text, which is what
              // `background-attachment: scroll` does on a scroll container —
              // and what stops it beating against the lines as they move.
              child: CustomPaint(
                painter: _BaselinePainter(
                  ink: Color.lerp(tokens.surface, tokens.onSurface, _baselineInk)!,
                ),
                child: CustomScrollView(
                  key: RuleTextScreen.scrollKey,
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: _Masthead(citation: widget.citation, authority: widget.authority),
                    ),
                    SliverList.builder(
                      itemCount: shown.length,
                      itemBuilder: (BuildContext context, int index) =>
                          _ArticleBlock(article: shown[index]),
                    ),
                    if (shown.isEmpty)
                      SliverToBoxAdapter(
                        child: widget.articles.isEmpty
                            // Two absences, kept apart. Nothing transcribed for
                            // this instrument is a fact about the pack; nothing
                            // matching is a fact about what the reader typed.
                            // Merging them would say the law is missing when it
                            // is on the page a chip away.
                            ? LonjaEmptyState(
                                headline: l10n.ruleTextNoneRecordedHeadline,
                                body: l10n.ruleTextNoneRecordedBody(widget.citation.instrument),
                                primary: const SizedBox.shrink(),
                              )
                            : LonjaEmptyState(
                                headline: l10n.ruleTextNoMatchHeadline,
                                body: l10n.ruleTextNoMatchBody,
                                primary: const SizedBox.shrink(),
                              ),
                      ),
                    SliverToBoxAdapter(child: _ClosingNote(articles: widget.articles)),
                    const SliverToBoxAdapter(child: SizedBox(height: LonjaSpace.s8)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// How far the baseline rule is carried from the paper towards the ink.
///
/// The mockup's `rgba(22,32,28,.055)` expressed as a fraction of the two slots
/// in scope rather than as a fourth colour: on the sunlight theme, where every
/// grey is deleted, the same fraction of black over white is invisible — which
/// is the correct behaviour for an ornament on a screen read in glare.
const double _baselineInk = 0.055;

/// Which instrument this is, who published it, and how current the
/// transcription is.
///
/// Three registers and not one line: the authority is an eyebrow, the
/// instrument is the headline, and the two dates are prose with the figures set
/// in mono so they read as data against it. The block closes on a 2 pt rule,
/// which is what makes everything below it read as the document rather than as
/// more heading.
class _Masthead extends StatelessWidget {
  const _Masthead({required this.citation, required this.authority});

  final CitationDisplay citation;
  final String authority;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final TextStyle prose = type.uiSmall.copyWith(color: tokens.onSurfaceMuted);
    // Mono, tabular, and the same string in six languages: the dates quote a
    // printed instrument and are compared against it by eye.
    final TextStyle figure = type.citation.copyWith(color: tokens.onSurfaceMuted);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        tokens.density.gutter,
        LonjaSpace.s4,
        tokens.density.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            // Cased at the call site on the LOCALISED word, never authored
            // shouting into the ARB — where it would shout in five locales and
            // do nothing in the sixth.
            authority.toUpperCase(), // lonja-type: ok
            style: type.eyebrow.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: LonjaSpace.s1),
          Text(
            // The instrument alone. The article number is a margin mark and is
            // set in the gutter beside the text it belongs to.
            isolateLtr(citation.instrument),
            style: type.title,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: LonjaSpace.s1),
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: l10n.ruleTextPublishedLabel, style: prose),
                TextSpan(text: ' ', style: prose),
                TextSpan(text: citation.publishedOn, style: figure),
                TextSpan(text: ' · ', style: prose),
                TextSpan(text: l10n.ruleTextCheckedLabel, style: prose),
                TextSpan(text: ' ', style: prose),
                TextSpan(text: citation.checkedOn, style: figure),
              ],
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: LonjaSpace.s5),
          const LonjaRule.section(key: RuleTextScreen.mastheadRuleKey),
        ],
      ),
    );
  }
}

/// One article: its number in the margin, its text against the gutter rule.
///
/// **`Block`, never `Row`.** The layering gate reads `\b\w+Row\b` as a drift
/// row type, and it matches private names too.
class _ArticleBlock extends StatelessWidget {
  const _ArticleBlock({required this.article});

  final LegalArticle article;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        tokens.density.gutter,
        LonjaSpace.s4,
        tokens.density.gutter,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: LonjaSpace.s7,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(top: LonjaSpace.s1, end: LonjaSpace.s2),
              child: Text(
                article.articleRef ?? '',
                style: type.articleNumber.copyWith(color: tokens.onSurfaceMuted),
                // Against the gutter rule, which is where the eye picks it up.
                textAlign: TextAlign.end,
              ),
            ),
          ),
          Expanded(
            child: DecoratedBox(
              // The rule the number hangs off, and the only thing separating
              // the margin from the text. A gap would have made two columns;
              // this makes one page.
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(color: tokens.hairline, width: LonjaRules.rule),
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: LonjaSpace.s4),
                // In the language the authority published it in, and in the
                // serif that says so. The direction is set ON THE TEXT and not
                // by constructing a `Directionality`: this is one standalone
                // run whose script is known, not a subtree whose layout must
                // stop following the locale — and D-8's gate is right to ban
                // the wider thing.
                child: Text(
                  article.body,
                  style: type.legal,
                  // Justified to the gutter rule, as the instrument is set on
                  // paper. Nothing else on this product is justified.
                  textAlign: TextAlign.justify,
                  textDirection: _directionFor(article.locale),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The article chips: the whole instrument, then each article of it.
///
/// A lazy horizontal strip and not a wrapping block, because the number of
/// articles is a property of the instrument and a 40-article order would push
/// the masthead off the screen before a word of law was read.
class _ArticleChips extends StatelessWidget {
  const _ArticleChips({required this.refs, required this.selected, required this.onChosen});

  final List<String> refs;
  final String? selected;
  final void Function(String? ref) onChosen;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: LonjaSpace.s3),
      child: SizedBox(
        height: tokens.density.tapMin,
        child: ListView.separated(
          key: RuleTextScreen.chipsKey,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsetsDirectional.symmetric(horizontal: tokens.density.gutter),
          // The instrument whole is the first cell and not a gesture nobody
          // can see: a chip row whose only way back is a second tap on the
          // selected cell is a filter the reader cannot get out of.
          itemCount: refs.length + 1,
          separatorBuilder: (BuildContext context, int _) => SizedBox(width: tokens.density.tapGap),
          itemBuilder: (BuildContext context, int index) {
            final String? ref = index == 0 ? null : refs[index - 1];
            return _ArticleChip(
              label: ref ?? l10n.ruleTextAllArticles,
              isSelected: ref == selected,
              onTap: () => onChosen(ref),
            );
          },
        ),
      ),
    );
  }
}

/// One ruled cell of the chip strip.
class _ArticleChip extends StatelessWidget {
  const _ArticleChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: tokens.density.tapMin,
            minHeight: tokens.density.tapMin,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              // Selection is a reversal of the ink and not a tint: the cell is
              // struck rather than shaded, so it survives greyscale, glare and
              // the sunlight palette where every grey is deleted.
              color: isSelected ? tokens.onSurface : tokens.surfaceSunk,
              // The chip is the one place LonjaRadii.hair is spent: it is a
              // chip, and the ceiling exists so that spending it stays a
              // decision rather than a habit.
              borderRadius: LonjaRadii.hair,
              border: Border.all(
                color: isSelected ? tokens.onSurface : tokens.hairline,
                width: LonjaRules.rule,
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: LonjaSpace.s3,
                vertical: LonjaSpace.s2,
              ),
              child: Center(
                child: Text(
                  label,
                  style: type.ui.copyWith(
                    color: isSelected ? tokens.surface : tokens.onSurfaceMuted,
                  ),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The apparatus: what this copy holds, and in which language it holds it.
///
/// **Printed, and not a control.** The mockup closes the page on a link onto an
/// English rendering; `LegalArticle` is single-locale by construction
/// (`SPEC.md` §9.6) and no translation of a penal instrument exists to open, so
/// what stands there is the §9.6 notice naming the one language the text exists
/// in. A dead link would have been worse than no link.
class _ClosingNote extends StatelessWidget {
  const _ClosingNote({required this.articles});

  final List<LegalArticle> articles;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final String? reader = encodeLocale(Localizations.localeOf(context));
    final String? published = articles.isEmpty ? null : articles.first.locale;
    // Named in the reader's own language, never as a bare code: `gl` on a page
    // of Galician law tells an Arabic reader nothing at all. Absent when the
    // law is already in his language — a notice printed then would state
    // something he can see for himself.
    final String? notice =
        published != null && reader != null && _selectCode(published) != _selectCode(reader)
        ? l10n.legalTextLanguageNotice(l10n.languageName(_selectCode(published)))
        : null;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        tokens.density.gutter,
        LonjaSpace.s6,
        tokens.density.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Struck in ink rather than in the hairline slot: a footnote rule
          // that cannot be seen on a wet screen in sunlight is a page with no
          // seam between the law and the apparatus under it.
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 0.44,
              child: SizedBox(
                key: RuleTextScreen.footnoteRuleKey,
                height: LonjaRules.rule,
                child: ColoredBox(color: tokens.onSurface),
              ),
            ),
          ),
          const SizedBox(height: LonjaSpace.s2),
          Text(
            l10n.ruleTextCompleteNote,
            style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
          if (notice != null) ...<Widget>[
            const SizedBox(height: LonjaSpace.s1),
            Text(
              notice,
              style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ],
        ],
      ),
    );
  }
}

/// The baseline the reading column is ruled against.
///
/// Fixed to the viewport, at the 32 pt step of the spacing spine. A snapshot of
/// one colour and nothing else: a painter that read the tree could not answer
/// `shouldRepaint` honestly.
class _BaselinePainter extends CustomPainter {
  const _BaselinePainter({required this.ink});

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final rule = Paint()
      ..color = ink
      ..strokeWidth = LonjaRules.rule;
    for (double y = LonjaSpace.s2; y < size.height; y += LonjaSpace.s6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rule);
    }
  }

  @override
  bool shouldRepaint(_BaselinePainter old) => old.ink != ink;
}

/// The direction [locale]'s script reads in.
///
/// Of the six shipped languages only Arabic is right-to-left, and this is about
/// the LAW's language rather than the reader's — which is exactly why it cannot
/// come from `Directionality.of(context)`.
TextDirection _directionFor(String locale) =>
    locale.startsWith('ar') ? TextDirection.rtl : TextDirection.ltr;

/// [locale] as `languageName`'s ICU branch key.
///
/// The ICU keys are canonical lowercase identifiers, so the Brazilian one is
/// `ptBR` where the ARB filename and the stored locale both carry `pt_BR`.
String _selectCode(String locale) {
  final String tag = locale.replaceAll('-', '_');
  return tag == 'pt_BR' ? 'ptBR' : tag.split('_').first;
}

/// S13 with the pack behind it: the citation's articles, read once and shown.
///
/// The screen above is pure over its inputs so it can be pumped without a
/// database; this is the seam that fills it. Loading and failure keep the band,
/// because a page with no way back is a page the fisher is stuck on — and a
/// failed read is stated rather than shown as an empty instrument.
class RuleTextRoute extends ConsumerWidget {
  /// Opens the text recorded against [citationId].
  const RuleTextRoute({
    required this.citationId,
    required this.citation,
    required this.authority,
    super.key,
  });

  /// Which citation row the verbatim text hangs off.
  final int citationId;

  /// The instrument, as the footnote that opened this page printed it.
  final CitationDisplay citation;

  /// The body that published it, already localised.
  final String authority;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<LegalArticle>> articles = ref.watch(legalArticlesProvider(citationId));

    return articles.when(
      loading: () => _RuleTextPending(citation: citation, child: const LonjaListSkeleton(rows: 3)),
      // The raw failure and NOT the empty state. "Nothing was transcribed" is a
      // claim about the law, and making it when the device could not read the
      // file is the app inventing the absence of a text.
      error: (Object error, StackTrace _) => _RuleTextPending(
        citation: citation,
        child: Builder(
          builder: (BuildContext context) => Padding(
            padding: EdgeInsetsDirectional.all(LonjaTokens.of(context).density.gutter),
            child: Text('$error', textAlign: TextAlign.start),
          ),
        ),
      ),
      data: (List<LegalArticle> value) =>
          RuleTextScreen(citation: citation, authority: authority, articles: value),
    );
  }
}

/// The band and nothing under it yet.
class _RuleTextPending extends StatelessWidget {
  const _RuleTextPending({required this.citation, required this.child});

  final CitationDisplay citation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NavigatorState navigator = Navigator.of(context);

    return Scaffold(
      appBar: LonjaScreenBar(
        title: l10n.referenceEntryRuleText,
        sup: isolateLtr(citation.article),
        onBack: navigator.canPop() ? navigator.pop : null,
      ),
      body: SafeArea(top: false, child: child),
    );
  }
}
