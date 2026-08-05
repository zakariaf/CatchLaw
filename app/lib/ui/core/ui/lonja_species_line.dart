import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/material.dart';

/// One species in a list.
///
/// **One tap target over the whole rectangle**, at `density.rowHeight`. A row
/// whose only tappable part is its title is a row a wet thumb misses, and §4.9
/// puts the floor at 48 dp — 56 dp gloved — for exactly that reason.
///
/// Every slot is a plain parameter rather than a builder: the row decides
/// nothing about what a hint says or which art to draw, because those are
/// decisions with citations behind them and they belong where the citation is.
class LonjaSpeciesLine extends StatelessWidget {
  /// Renders one species.
  const LonjaSpeciesLine({
    required this.name,
    required this.onTap,
    this.art,
    this.hint,
    this.scientificName,
    super.key,
  });

  /// The name the fisher will recognise — a local name, not a binomial.
  final String name;

  /// Opens the species.
  final VoidCallback onTap;

  /// A silhouette or a plate, already resolved.
  final Widget? art;

  /// One word: a size, `protected`, `closed`. Already localised.
  final String? hint;

  /// The binomial, set small and last, because Khalid does not read Latin.
  final String? scientificName;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Semantics(
      button: true,
      label: name,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: tokens.density.rowHeight),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: LonjaSpace.s4,
                  vertical: LonjaSpace.s3,
                ),
                child: Row(
                  children: <Widget>[
                    if (art != null) ...<Widget>[
                      SizedBox(width: LonjaSpace.s8, child: art),
                      const SizedBox(width: LonjaSpace.s3),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(name, style: type.subtitle, textAlign: TextAlign.start),
                          if (scientificName != null)
                            Text(
                              scientificName!,
                              style: type.binomial.copyWith(color: tokens.onSurfaceMuted),
                              textAlign: TextAlign.start,
                            ),
                        ],
                      ),
                    ),
                    if (hint != null) ...<Widget>[
                      const SizedBox(width: LonjaSpace.s3),
                      _HintStamp(word: hint!),
                    ],
                    const SizedBox(width: LonjaSpace.s2),
                    // Outboard of the stamp, and on every row: it says the row
                    // opens something, which a name and a status word do not.
                    // Excluded from semantics because the row above it is
                    // already announced as a button carrying the same name.
                    ExcludeSemantics(
                      child: LonjaIcon(
                        LonjaIcons.forward,
                        size: LonjaIconSize.caption,
                        color: tokens.onSurfaceFaint,
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

/// The one-word status, struck as a stamp rather than set as text.
///
/// **The frame carries the emphasis and the ink stays ordinary.** The obvious
/// alternative — the word itself in ochre or oxblood — puts a legal status on a
/// colour that measures under 4.5:1 on paper, so the one part of the row a
/// fisher reads at arm's length in glare is the part that disappears first. A
/// ruled box and a mono, tracked word survive greyscale, sunlight and a wet
/// screen alike, which is invariant 4 stated in one widget.
class _HintStamp extends StatelessWidget {
  const _HintStamp({required this.word});

  /// Already localised, and a statement of fact rather than an instruction.
  final String word;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: tokens.ruleBearing, width: LonjaRules.rule),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: LonjaSpace.s1,
          vertical: LonjaSpace.s1,
        ),
        child: Text(
          word,
          style: type.articleNumber.copyWith(color: tokens.onSurface),
          textAlign: TextAlign.end,
        ),
      ),
    );
  }
}
