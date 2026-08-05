import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';

/// A ruled band of standing facts, set between the mast and the entry line.
///
/// **A stamp on the page, not a Material chip.** No radius, no fill, no
/// elevation and no delete cross: a chip here is one short line of type inside
/// a hairline frame on sunk stock, the way a docket carries a rubber-stamped
/// note in the margin. `LonjaChip.fact` states something; `LonjaChip.action`
/// states it AND is the way to change it, and says so with a chevron that
/// mirrors under `Directionality`.
///
/// It sits on [LonjaDensity.tapMin] exactly — the mockup's §13 puts chips at
/// the floor of the glove set, 56 dp, where a button is 66 and the entry line
/// is 72 — so a band of them is the smallest thing on S1 that can still be hit
/// with a neoprene thumb.
class LonjaChip extends StatelessWidget {
  const LonjaChip._({
    required this.label,
    required this.glyph,
    required this.isFact,
    this.onTap,
    this.hint,
    super.key,
  });

  /// A standing fact: what this device is holding, and since when.
  ///
  /// Not tappable, and deliberately not framed as one — a fact the reader
  /// cannot act on that looks like a button is a dead end at 05:40. Its label
  /// is a date or a code, so it is set in the mono step.
  const LonjaChip.fact({required String label, required LonjaGlyph glyph, Key? key})
    : this._(label: label, glyph: glyph, isFact: true, key: key);

  /// A word that is also the way to change what it names.
  const LonjaChip.action({
    required String label,
    required LonjaGlyph glyph,
    required VoidCallback onTap,
    String? hint,
    Key? key,
  }) : this._(label: label, glyph: glyph, isFact: false, onTap: onTap, hint: hint, key: key);

  /// Already localised. This widget never reaches for an ARB key.
  final String label;

  /// The mark that opens the chip, and never the only signal: the word beside
  /// it says the same thing.
  final LonjaGlyph glyph;

  /// Whether this is a standing fact rather than a way to change one.
  ///
  /// It settles both halves of the chip's setting at once, because on this band
  /// they never come apart: a fact carries a date or a code, so it takes the
  /// mono step and the seal's own slot; an action carries a word, so it takes
  /// the sans step and chrome's.
  final bool isFact;

  /// What tapping it opens, or null on a fact.
  final VoidCallback? onTap;

  /// What a screen reader adds after [label] on an action.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final VoidCallback? tap = onTap;
    final Color mark = isFact ? tokens.verdictPass : tokens.accent;

    final Widget body = ConstrainedBox(
      constraints: BoxConstraints(minHeight: tokens.density.tapMin),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surfaceSunk,
          border: Border.all(
            // A bearing rule on the tappable one, because it is a control
            // frame and carries the 3:1 floor; ornament on the fact, which
            // frames a line of type and identifies nothing.
            color: tap == null ? tokens.hairline : tokens.ruleBearing,
            width: LonjaRules.rule,
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LonjaSpace.s3,
            vertical: LonjaSpace.s2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ExcludeSemantics(
                child: LonjaIcon(glyph, size: LonjaIconSize.caption, color: mark),
              ),
              const SizedBox(width: LonjaSpace.s2),
              Flexible(
                child: Text(
                  label,
                  // A date or a code goes in the mono step, to be read
                  // character by character against a printed pack; a word goes
                  // in the sans one, because mono prose is a machine talking.
                  style: (isFact ? type.articleNumber : type.uiSmall).copyWith(
                    color: tokens.onSurface,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              if (tap != null) ...<Widget>[
                const SizedBox(width: LonjaSpace.s2),
                ExcludeSemantics(
                  child: LonjaIcon(
                    LonjaIcons.forward,
                    size: LonjaIconSize.caption,
                    color: tokens.onSurfaceMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (tap == null) return Semantics(label: label, excludeSemantics: true, child: body);

    return Semantics(
      button: true,
      label: label,
      hint: hint,
      excludeSemantics: true,
      child: InkWell(onTap: tap, child: body),
    );
  }
}
