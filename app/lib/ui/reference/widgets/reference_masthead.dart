import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/material.dart';

/// The gazette head of the reference: the book's name, what part of it this is,
/// and which printing the device holds.
///
/// **A masthead and not a screen bar.** `LonjaScreenBar` is the band a *pushed*
/// route carries and it opens with a way back; this is the head of a branch,
/// which has nowhere to go back to. And it is not `LonjaMasthead` either: that
/// one names the PLACE a verdict is answered against and offers to change it,
/// which is S1's question. The question here is *what is in this book*, so the
/// wordmark carries the part-title under it in the gazette's own hand and the
/// trailing block carries the zone and the printing.
class ReferenceMasthead extends StatelessWidget {
  /// Heads the branch [wordmark], sub-titled [subline].
  const ReferenceMasthead({
    required this.wordmark,
    required this.subline,
    this.zoneCode,
    this.packVersion,
    super.key,
  });

  /// The branch's name, already localised and already cased.
  final String wordmark;

  /// Which part of the book this is, already localised.
  final String subline;

  /// The zone the book is read against — the first meta line, or absent.
  ///
  /// **Printed as authored.** A code is an identifier rather than a sentence:
  /// it is the same string in all six locales, and it is what a fisher reads
  /// off the printed pack to compare against another device.
  final String? zoneCode;

  /// Which printing of the rules this device holds — the second meta line.
  final String? packVersion;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final String? zone = zoneCode;
    final String? version = packVersion;

    return ColoredBox(
      color: tokens.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                tokens.density.gutter,
                LonjaSpace.s3,
                tokens.density.gutter,
                LonjaSpace.s3,
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
                        // The ramp's only italic. It belongs to scientific
                        // names and this is the one other place it is set: a
                        // part-title under a wordmark is the gazette device the
                        // mockup draws, and the alternative — a seventeenth
                        // ramp step — is invented at a call site, which is the
                        // thing lonja-typography exists to prevent.
                        Text(
                          subline,
                          style: type.binomial.copyWith(color: tokens.onSurfaceMuted),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                  if (zone != null || version != null) ...<Widget>[
                    const SizedBox(width: LonjaSpace.s4),
                    _MastMeta(zoneCode: zone, packVersion: version),
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

/// The two stacked lines at the trailing edge of the mast.
///
/// A widget class rather than a helper method, so the `LonjaTokens.of` inside
/// it registers this element as the dependent instead of rebuilding the whole
/// band on a theme change, a density toggle or an RTL flip.
class _MastMeta extends StatelessWidget {
  const _MastMeta({this.zoneCode, this.packVersion});

  final String? zoneCode;

  final String? packVersion;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final TextStyle style = type.articleNumber.copyWith(color: tokens.onSurfaceMuted);
    final String? zone = zoneCode;
    final String? version = packVersion;

    return Column(
      // Resolved against the ambient direction, so the block sits at the
      // trailing margin in `ar` as it does in `en`.
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (zone != null) Text(zone, style: style, textAlign: TextAlign.end),
        if (version != null) Text(version, style: style, textAlign: TextAlign.end),
      ],
    );
  }
}
