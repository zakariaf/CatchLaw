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
                      Text(
                        hint!,
                        style: type.datum.copyWith(color: tokens.onSurfaceMuted),
                        textAlign: TextAlign.end,
                      ),
                    ],
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
