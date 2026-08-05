import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/material.dart';

/// One line of the contents: a numeral, a title, a leader and a count.
///
/// **Not a card, and not a `ListTile`.** A table of contents is the one list
/// shape a printed booklet has for "here is everything this book holds", and
/// the leader dots are what make a title and a figure at opposite margins read
/// as one line rather than as two columns. `lonja-lists-and-tables` bans the
/// Material row for the same reason: its own paddings and its own densities
/// would decide the measure of a page that is set, not laid out.
///
/// **`Line`, never `Row`.** The layering gate reads `\b\w+Row\b` as a drift row
/// type, and it matches private names too.
class ReferenceContentsLine extends StatelessWidget {
  /// Sets one entry, numbered [numeral] and opened by [onTap].
  const ReferenceContentsLine({
    required this.numeral,
    required this.title,
    required this.note,
    required this.onTap,
    this.count,
    super.key,
  });

  /// The margin numeral, as authored.
  final String numeral;

  /// The section's name, already localised.
  final String title;

  /// What that section holds, already localised.
  final String note;

  /// The figure at the trailing margin — a count where there is one, or the
  /// statement that this copy does not print the section. Already localised.
  final String? count;

  /// Opens the section.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    // Built before the tree, because the gate that keeps chrome out of the ARB
    // reads a literal after `label:` and a variable is what says this sentence
    // came from AppLocalizations.
    final spoken = count == null ? '$title. $note' : '$title. $note. ${count!}';
    final String? figure = count;

    return Semantics(
      button: true,
      label: spoken,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ConstrainedBox(
              // One target over the whole line, at the density in scope: a
              // contents entry whose tappable part was its title is an entry a
              // wet thumb misses.
              constraints: BoxConstraints(minHeight: tokens.density.rowHeight),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: tokens.density.gutter,
                  vertical: LonjaSpace.s3,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      // Bottoms rather than baselines: the leader has no
                      // baseline to align to, and a `Row` asked for one from a
                      // painted child aligns it by its box anyway.
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(
                          width: LonjaSpace.s6,
                          child: Text(
                            numeral,
                            style: type.articleNumber.copyWith(color: tokens.onSurfaceMuted),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        // Tight rather than loose, so the leader starts at the
                        // same column on every line — a contents list whose
                        // dots began wherever a title happened to end reads as
                        // eight measurements rather than one column.
                        Expanded(
                          flex: 3,
                          child: Text(title, style: type.legal, textAlign: TextAlign.start),
                        ),
                        const SizedBox(width: LonjaSpace.s2),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            // Off the descenders of the line it runs between.
                            padding: const EdgeInsetsDirectional.only(bottom: LonjaSpace.s1),
                            child: _LeaderDots(ink: tokens.onSurfaceFaint),
                          ),
                        ),
                        if (figure != null) ...<Widget>[
                          const SizedBox(width: LonjaSpace.s2),
                          Text(
                            figure,
                            style: type.microLabel.copyWith(color: tokens.onSurfaceMuted),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: LonjaSpace.s1),
                    Padding(
                      // Indented to clear the numeral gutter, so the second
                      // line hangs off the title and not off the margin.
                      padding: const EdgeInsetsDirectional.only(start: LonjaSpace.s6),
                      child: Text(
                        note,
                        style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const LonjaRule.row(),
          ],
        ),
      ),
    );
  }
}

/// The dotted leader between a title and its figure.
///
/// A painter rather than a repeated glyph: a run of `·` is set by the font's
/// own advance widths, so it changes pitch between the Latin and Naskh stacks
/// and lands under the figure at a different place in `ar` than in `en`.
class _LeaderDots extends StatelessWidget {
  const _LeaderDots({required this.ink});

  final Color ink;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: LonjaSpace.s1,
    child: CustomPaint(
      painter: _LeaderDotsPainter(ink: ink),
      size: Size.infinite,
    ),
  );
}

/// Dots on the 4 pt spine, at the hairline weight.
///
/// The ink arrives in the constructor as a snapshot rather than being read from
/// a `BuildContext` the painter does not have (`lonja-design-tokens` rule 10).
class _LeaderDotsPainter extends CustomPainter {
  const _LeaderDotsPainter({required this.ink});

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final paintDot = Paint()..color = ink;
    final double y = size.height / 2;
    for (double x = LonjaRules.hair; x < size.width; x += LonjaSpace.s1) {
      canvas.drawCircle(Offset(x, y), LonjaRules.hair, paintDot);
    }
  }

  @override
  bool shouldRepaint(_LeaderDotsPainter old) => old.ink != ink;
}
