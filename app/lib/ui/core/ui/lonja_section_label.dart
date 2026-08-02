import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/widgets.dart';

/// The gazette device: a tracked label, then a rule running to the margin.
///
/// The text arrives **as authored**, and a case transform is banned in UI code
/// by `check_lonja_type.sh` check 6 for a reason invisible in English: on
/// Arabic it is a silent no-op, so a label whose hierarchy came from casing
/// would shout in Galician and look exactly like body text in `ar`. In that
/// locale the `microLabel` step carries w700 instead, and the rule beside it is
/// what makes it a heading in every locale alike.
class LonjaSectionLabel extends StatelessWidget {
  /// Labels a section with [text].
  const LonjaSectionLabel({required this.text, super.key});

  /// Already localised and already cased.
  final String text;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    return Semantics(
      header: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            text,
            style: type.microLabel.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
          const SizedBox(width: LonjaSpace.s2),
          const Expanded(child: LonjaRule.block()),
        ],
      ),
    );
  }
}
