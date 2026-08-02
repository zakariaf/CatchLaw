import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/widgets.dart';

/// A block of recessed stock, framed.
///
/// **The border is unconditional, and that is the point.** In sunlight
/// `surfaceSunk` equals `surface` — white paper has no recessed stock — so a
/// block marked *only* by a change of fill becomes invisible at exactly the
/// moment the fisher is standing in 100 000 lux. Drawing the rule only "when
/// the fill is too close to the ground" would put that decision at a call site,
/// and the call site that gets it wrong is the one nobody reads outdoors.
///
/// Square, unfilled by shadow, and at zero elevation: a printed page separates
/// things with a rule, a change of stock, or space, and it has no fourth
/// mechanism and no z-axis.
class LonjaPanel extends StatelessWidget {
  /// Wraps [child] in a framed panel.
  const LonjaPanel({required this.child, super.key});

  /// What sits inside the frame.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surfaceSunk,
        border: Border.all(color: tokens.hairline, width: LonjaRules.rule),
        borderRadius: LonjaRadii.none,
      ),
      child: Padding(padding: EdgeInsetsDirectional.all(tokens.density.gutter), child: child),
    );
  }
}
