import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/format/bidi_isolate.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The footnote: which instrument said this, and when anybody last read it.
///
/// **Printed unconditionally, and additionally tappable.** The four fields are
/// on the page with no interaction at all — a citation the reader has to go
/// looking for is not evidence at the counter — and the block is *also* a
/// button onto the verbatim article, which is `SPEC.md` §4.6's requirement read
/// from the other side.
///
/// **Nothing here hands a URL to a browser.** An `ACTION_VIEW` performs the
/// fetch under the browser's own permission, so an app that never opens a
/// socket still defeats the guarantee a release manifest without INTERNET is
/// supposed to give. The URL is selectable text: the reader can copy it and
/// type it somewhere else, which is a different act by a different actor.
/// Named for what it is rather than the `ResultCitationRow` E10/T05 asks for:
/// `layering_test.dart` bans every `*Row` identifier outside `lib/data`, drift
/// names its generated row classes that way, and `RuleFact` and `_FindingLine`
/// took the same rename in T01 and T03.
class ResultCitationFootnote extends StatelessWidget {
  /// Prints [citation], marked [marker], for [jurisdiction].
  const ResultCitationFootnote({
    required this.citation,
    required this.citationId,
    required this.jurisdiction,
    required this.marker,
    required this.onOpenRuleText,
    this.sourceUrl,
    this.provenance,
    super.key,
  });

  /// The copy affordance.
  static const Key copyKey = Key('result-citation-copy');

  /// The block that opens the verbatim article.
  static const Key openKey = Key('result-citation-open');

  /// The short rule above the footnote.
  static const Key footnoteRuleKey = Key('result-citation-rule');

  /// Instrument, article, published, checked. Required and non-nullable.
  final CitationDisplay citation;

  /// Which citation row the verbatim text hangs off.
  final int citationId;

  /// The authority that published it, already localised.
  final String jurisdiction;

  /// The footnote number the finding rows point at.
  final int marker;

  /// Selectable text, never a link. Absent for an instrument that records none.
  final String? sourceUrl;

  /// The second marker on an expired pack: which pack, and when it lapsed.
  ///
  /// Under the instrument it qualifies rather than in the bar, because a reader
  /// checking the footnote is asking a different question from one glancing at
  /// the top of the screen — and the answer to "how current is this" belongs
  /// beside the thing it is about.
  final String? provenance;

  /// Opens the bundled verbatim article.
  ///
  /// A callback rather than a route, so this widget holds no knowledge of the
  /// navigation stack and can be pumped without one.
  final void Function(int citationId) onOpenRuleText;

  /// The exact line the footnote prints, and the exact line copy puts on the
  /// clipboard.
  ///
  /// One string for both, because a copy that differs from the print is two
  /// citations — and the one that travels in a message is the one nobody can
  /// check against the page it came from.
  String get printedLine =>
      '$jurisdiction — ${citation.instrument}, ${citation.article}'
      ' · published ${citation.publishedOn} · checked ${citation.checkedOn}';

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? sourceUrl = this.sourceUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // The short rule that says "what follows is apparatus, not argument".
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 0.44,
            child: SizedBox(
              key: footnoteRuleKey,
              height: LonjaRules.rule,
              child: ColoredBox(color: tokens.hairline),
            ),
          ),
        ),
        const SizedBox(height: LonjaSpace.s2),
        Semantics(
          button: true,
          label: printedLine,
          child: InkWell(
            key: openKey,
            onTap: () => onOpenRuleText(citationId),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: tokens.density.tapMin),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: LonjaSpace.s1),
                    child: Text(
                      '$marker',
                      style: type.articleNumber.copyWith(color: tokens.onSurfaceMuted),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          jurisdiction,
                          style: type.eyebrow.copyWith(color: tokens.onSurfaceMuted),
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          // The instrument name is Latin script and is never
                          // translated, so inside an Arabic line it is isolated
                          // — otherwise the article number lands at the wrong
                          // end of the line the reader is checking.
                          isolateLtr('${citation.instrument}, ${citation.article}'),
                          style: type.citation.copyWith(color: tokens.onSurface),
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          // ISO, unlocalised, Western digits in every locale:
                          // the same string in six languages, comparable by eye
                          // against the printed instrument.
                          'published ${citation.publishedOn} · checked ${citation.checkedOn}',
                          style: type.citation.copyWith(color: tokens.onSurfaceMuted),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    // The accessible name first, before any argument whose own
                    // closing paren ends a line: check_lonja_buttons reads a
                    // short window and stops at the first one it finds, and an
                    // icon button silent to TalkBack is the failure it is for.
                    key: copyKey,
                    tooltip: l10n.citationCopyAction,
                    icon: _CopyMark(label: l10n.citationCopyAction),
                    onPressed: () => Clipboard.setData(ClipboardData(text: printedLine)),
                    constraints: BoxConstraints(
                      minWidth: tokens.density.tapMin,
                      minHeight: tokens.density.tapMin,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (provenance case final String provenance) ...<Widget>[
          const SizedBox(height: LonjaSpace.s1),
          Text(
            provenance,
            style: type.citation.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ],
        if (sourceUrl != null) ...<Widget>[
          const SizedBox(height: LonjaSpace.s1),
          // Selectable, and with no gesture of any kind. The failure mode is a
          // helpful onTap added later by somebody who read it as a link.
          SelectableText(
            sourceUrl,
            style: type.citation.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ],
      ],
    );
  }
}

/// The copy mark: two offset rules, drawn from the inherited ink.
///
/// Two nested squares rather than a glyph in `LonjaIcons`, because the family is
/// the verdict set and a chrome affordance is not a verdict. D-20 says a glyph
/// is added by the task that renders it; this one is a control, and E16 owns
/// the chrome set.
class _CopyMark extends StatelessWidget {
  const _CopyMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    return Semantics(
      label: label,
      child: SizedBox.square(
        dimension: LonjaSpace.s5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: tokens.ruleBearing, width: LonjaRules.rule),
          ),
        ),
      ),
    );
  }
}
