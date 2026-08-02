import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/widgets.dart';

/// A printed rule.
///
/// **Four named constructors, not two free parameters.** A rule's tone and its
/// weight are not independent choices: `hairline` measures 1.37:1 on paper —
/// invisible on a wet screen at arm's length — which is fine for separating two
/// rows of a table and unacceptable as the frame of a tappable control, where
/// `ruleBearing` measures 7.29:1 and clears the 3:1 non-text floor with room.
/// Encoding the four documented uses as constructors means there is no
/// `LonjaRule(tone: hairline, weight: stamp)` for a call site to write.
///
/// Not a Material `Divider`: that introduces 16 dp of **physical**,
/// non-directional padding and its own thickness defaults. A rule here is a
/// `BorderSide` drawn by a `DecoratedBox`, and nothing else.
class LonjaRule extends StatelessWidget {
  /// Between two rows of a table. Ornament, and never the sole boundary of a
  /// control.
  const LonjaRule.row({super.key}) : weight = LonjaRules.hair, _tone = _Tone.hairline;

  /// Around or under a block.
  const LonjaRule.block({super.key}) : weight = LonjaRules.rule, _tone = _Tone.hairline;

  /// A section head underscore, or the active tab.
  const LonjaRule.section({super.key}) : weight = LonjaRules.strong, _tone = _Tone.hairlineStrong;

  /// A rule that **identifies** rather than decorates — a control frame. Takes
  /// the bearing tone and its 3:1 floor.
  const LonjaRule.bearing({super.key}) : weight = LonjaRules.rule, _tone = _Tone.bearing;

  /// One of the four weights.
  final double weight;

  /// Which slot the ink comes from. Private, because the four constructors
  /// are the whole API.
  final _Tone _tone;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    return SizedBox(
      height: weight,
      child: DecoratedBox(decoration: BoxDecoration(color: _tone.of(tokens))),
    );
  }
}

/// Which slot a rule draws from. Private, because the four constructors are the
/// whole API.
enum _Tone {
  hairline,
  hairlineStrong,
  bearing;

  Color of(LonjaTokens tokens) => switch (this) {
    _Tone.hairline => tokens.hairline,
    _Tone.hairlineStrong => tokens.hairlineStrong,
    _Tone.bearing => tokens.ruleBearing,
  };
}
