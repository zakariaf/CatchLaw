import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/widgets.dart';

/// Nothing matched — and where to go next.
///
/// **Two actions, and that is not the defect the skill bans.**
/// `lonja-lists-and-tables` says an empty state gets exactly one
/// `LonjaButton.primary` and calls two competing actions a defect. It is right
/// about two competing *primaries*; this is one primary and one secondary.
/// `SPEC.md` §6 S5 requires **both** onward routes, and §4.3 records that S7
/// reachable from only one place was a defect in the first draft — this empty
/// state is one of the three fixes, and E14/T06 asserts all three together.
/// The epic's risk 1 records the seam; this epic does not edit a skill file.
///
/// A dead end is the thing being prevented. A fisher who typed a name the pack
/// does not carry has learned nothing and has nowhere to go, and "no results"
/// on its own is the app declining to help.
class LonjaEmptyState extends StatelessWidget {
  /// States [headline] and [body], and offers [primary] and [secondary].
  const LonjaEmptyState({
    required this.headline,
    required this.body,
    required this.primary,
    this.secondary,
    this.note,
    super.key,
  });

  /// One line, already localised.
  final String headline;

  /// One paragraph, already localised.
  final String body;

  /// The one primary way onward.
  final Widget primary;

  /// A second way onward, at a lower rung.
  final Widget? secondary;

  /// A qualifier about what was searched — the jurisdiction and its count.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.all(tokens.density.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const LonjaRule.section(),
          const SizedBox(height: LonjaSpace.s4),
          Text(headline, style: type.title, textAlign: TextAlign.start),
          const SizedBox(height: LonjaSpace.s2),
          Text(
            body,
            style: type.legal.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
          if (note != null) ...<Widget>[
            const SizedBox(height: LonjaSpace.s2),
            Text(
              note!,
              style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ],
          const SizedBox(height: LonjaSpace.s5),
          primary,
          if (secondary != null) ...<Widget>[SizedBox(height: tokens.density.tapGap), secondary!],
        ],
      ),
    );
  }
}
