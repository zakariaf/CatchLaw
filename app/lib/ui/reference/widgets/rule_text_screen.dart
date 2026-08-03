import 'package:catchlaw/domain/models/legal_article.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:flutter/material.dart';

/// What the instrument actually says, verbatim.
///
/// **A minimal reader, and E15 replaces it.** `SPEC.md` §14's device checklist
/// requires tapping a citation to reach the bundled text, and E10 lands nine
/// epics before E15 — shipping the tap with nowhere to go would leave a dead
/// affordance on the screen with the highest legal exposure. Full-text search
/// over `body_norm`, article navigation and the §9.6 language-availability
/// notice are E15's and are deliberately absent here.
///
/// **Nothing is truncated.** No `maxLines`, no ellipsis, no clamped text scale:
/// the clause that gets cut is the one that makes the verdict defensible, and
/// the page scrolls instead.
class RuleTextScreen extends StatelessWidget {
  /// Shows [articles], under [citation].
  const RuleTextScreen({required this.citation, required this.articles, super.key});

  /// The instrument, printed as a header so the reader knows what he is in.
  final CitationDisplay citation;

  /// Its articles, in reading order, in the language of publication.
  final List<LegalArticle> articles;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.all(tokens.density.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${citation.instrument}, ${citation.article}',
                style: type.title,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: LonjaSpace.s1),
              Text(
                // The reader has to know how current the transcription is, and
                // ISO is the form he can check against the printed page.
                'published ${citation.publishedOn} · checked ${citation.checkedOn}',
                style: type.citation.copyWith(color: tokens.onSurfaceMuted),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: LonjaSpace.s5),
              for (final LegalArticle article in articles) ...<Widget>[
                if (article.articleRef case final String ref)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: LonjaSpace.s1),
                    child: Text(
                      ref,
                      style: type.eyebrow.copyWith(color: tokens.onSurfaceMuted),
                      textAlign: TextAlign.start,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: LonjaSpace.s5),
                  // In the language the authority published it in, and in the
                  // serif that says so. The direction is set ON THE TEXT and
                  // not by constructing a `Directionality`: this is one
                  // standalone run whose script is known, not a subtree whose
                  // layout must stop following the locale — and D-8's gate is
                  // right to ban the wider thing.
                  child: Text(
                    article.body,
                    style: type.legal,
                    textAlign: TextAlign.start,
                    textDirection: _directionFor(article.locale),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// The direction [locale]'s script reads in.
  ///
  /// Of the six shipped languages only Arabic is right-to-left, and this is
  /// about the LAW's language rather than the reader's — which is exactly why
  /// it cannot come from `Directionality.of(context)`.
  TextDirection _directionFor(String locale) =>
      locale.startsWith('ar') ? TextDirection.rtl : TextDirection.ltr;
}
