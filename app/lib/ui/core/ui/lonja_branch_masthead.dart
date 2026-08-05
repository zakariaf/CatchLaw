import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/material.dart';

/// The gazette head of a branch: its name, what this page of it is, and the
/// stamp at the trailing margin.
///
/// **A masthead and not a screen bar.** `LonjaScreenBar` is the band a *pushed*
/// route carries and it opens with a way back; this is the head of a branch,
/// which has nowhere to go back to. And it is not `LonjaMasthead` either: that
/// one names the PLACE a verdict is answered against and offers to change it,
/// which is S1's question and S1's alone.
///
/// **Every line arrives already localised and already cased.** A case transform
/// belongs at the call site on the localised string, never in the ARB, and
/// never here: `check_lonja_type.sh` check 6 bans it under `lib/` because on
/// Arabic it is a silent no-op, so a wordmark whose hierarchy came from casing
/// would read as body text in exactly one locale.
class LonjaBranchMasthead extends StatelessWidget {
  /// Heads the branch [wordmark], sub-titled [subline], stamped [meta].
  const LonjaBranchMasthead({
    required this.wordmark,
    required this.subline,
    this.meta = const <String>[],
    super.key,
  });

  /// The branch's name, already localised and already cased.
  final String wordmark;

  /// Which page of the branch this is, already localised.
  final String subline;

  /// The stacked lines at the trailing edge — the day, the zone, the printing.
  ///
  /// **A code among them is printed as authored.** A code is an identifier
  /// rather than a sentence: it is the same string in all six locales, and it
  /// is what a fisher reads off the printed pack to compare against another
  /// device. Two lines are what the mast was drawn for; a third sets, and a
  /// fourth is a block that has stopped being a stamp.
  final List<String> meta;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return ColoredBox(
      color: tokens.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: tokens.density.gutter,
                vertical: LonjaSpace.s3,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Semantics(
                          header: true,
                          child: Text(wordmark, style: type.title, textAlign: TextAlign.start),
                        ),
                        // The ramp's only italic, and the second place it is
                        // set: a part-title under a wordmark is the gazette
                        // device the mockup draws, and the alternative — a
                        // seventeenth ramp step — is a metric invented at a
                        // call site, which is the thing lonja-typography
                        // exists to prevent.
                        Text(
                          subline,
                          style: type.binomial.copyWith(color: tokens.onSurfaceMuted),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                  if (meta.isNotEmpty) ...<Widget>[
                    const SizedBox(width: LonjaSpace.s4),
                    _MastMeta(lines: meta),
                  ],
                ],
              ),
            ),
            // The 2 pt rule under a mast, not the hairline under a pushed page:
            // this is the head of a document rather than another page of one.
            const LonjaRule.section(),
          ],
        ),
      ),
    );
  }
}

/// The stacked lines at the trailing edge of the mast.
///
/// A widget class rather than a helper method, so the `LonjaTokens.of` inside
/// it registers this element as the dependent instead of rebuilding the whole
/// band on a theme change, a density toggle or an RTL flip.
class _MastMeta extends StatelessWidget {
  const _MastMeta({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    // The mono ramp step, because these are figures and codes compared
    // character by character against a printed pack — and quiet, because the
    // wordmark beside them is the line that is read first.
    final TextStyle style = type.articleNumber.copyWith(color: tokens.onSurfaceMuted);

    return Column(
      // Resolved against the ambient direction, so the block sits at the
      // trailing margin in `ar` as it does in `en`.
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final String line in lines) Text(line, style: style, textAlign: TextAlign.end),
      ],
    );
  }
}
