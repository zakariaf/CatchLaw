import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/widgets.dart';

/// The engraved plate's frame: a ruled box inside a ruled box.
///
/// **Two frames and not one rule.** The block used to carry a single
/// `hairlineStrong` rule along its top edge over a change of stock, which reads
/// as a slip pasted onto the page — in paper and at night. In sunlight
/// `surfaceSunk` collapses onto `surface`, both are `white100`, and the stock
/// change is *not there*: the plate became a bare line with an illustration
/// hanging under it and no frame at all. Sunlight deletes the middle greys, so
/// anything that leaned on one has to be re-stated in rule, which is what the
/// second frame is.
///
/// The outer frame takes [LonjaRules.strong] in `hairlineStrong` and the inner
/// one [LonjaRules.rule] in `hairline`, separated by [LonjaSpace.s1]. That
/// weighting is the engraving convention the mockup draws: a heavy plate mark
/// with a light inner keyline, never two rules of equal weight, which reads as
/// a double-struck border rather than a frame.
///
/// It carries a child and draws no artwork. The engraved species plate that
/// goes inside belongs to `lonja-icons-and-plates`.
class LonjaPlateSurface extends StatelessWidget {
  /// Wraps [child] in an engraved frame.
  const LonjaPlateSurface({required this.child, super.key});

  /// What sits inside the frame.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surfaceSunk,
        // No borderRadius, and not even LonjaRadii.none: a BoxDecoration
        // asserts that a non-uniform border carries no radius at all. Square is
        // the absence of one, which is the same thing the ceiling says.
        border: Border.all(color: tokens.hairlineStrong, width: LonjaRules.strong),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(LonjaSpace.s1),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: tokens.hairline, width: LonjaRules.rule),
          ),
          child: Padding(padding: EdgeInsetsDirectional.all(tokens.density.gutter), child: child),
        ),
      ),
    );
  }
}
