import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/widgets.dart';

/// The pasted slip: a full-bleed rule above a block of recessed stock.
///
/// The rule is `hairlineStrong` at [LonjaRules.strong] and runs edge to edge,
/// which is what makes it read as a slip pasted onto the page rather than as a
/// card floating above it. Like [LonjaPanel] it carries the rule
/// unconditionally, because in sunlight the change of stock does not exist.
///
/// It carries a child and draws no artwork. The engraved plate that goes inside
/// belongs to `lonja-icons-and-plates` and to the epic that first draws one —
/// E07 ships no icon and no stroke-width token, because there is no row for one
/// in `token-tables.md` yet.
class LonjaPlateSurface extends StatelessWidget {
  /// Wraps [child] in a pasted slip.
  const LonjaPlateSurface({required this.child, super.key});

  /// What sits on the slip.
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
        border: BorderDirectional(
          top: BorderSide(color: tokens.hairlineStrong, width: LonjaRules.strong),
        ),
      ),
      child: Padding(padding: EdgeInsetsDirectional.all(tokens.density.gutter), child: child),
    );
  }
}
