import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/widgets.dart';

/// The ochre bar: this pack's rules have passed their `valid_to`.
///
/// **Non-blocking and non-dismissable, and both halves matter.** Invariant 5:
/// an expired ruleset is still evaluated and still shown. The bar states that
/// the data is stale; it does not hide the numbers, refuse to answer, or ask
/// for a confirmation — a fisher standing in front of an inspector needs the
/// finding he has, not a modal telling him it might be old.
///
/// The word is [LonjaTokens.onSurface] and never the ochre. `ochre47` measures
/// 3.97:1 on paper, which clears the non-text floor for a frame and a mark and
/// **fails** 4.5:1 as text — which is why the stale signal is a rule and a
/// glyph, and the sentence beside it is ordinary ink.
class LonjaStaleBar extends StatelessWidget {
  /// States that [message] applies to stale data.
  const LonjaStaleBar({required this.message, super.key});

  /// Already localised, and a statement of fact rather than an instruction.
  final String message;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surfaceSunk,
          border: BorderDirectional(
            start: BorderSide(color: tokens.verdictWarn, width: LonjaRules.stamp),
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LonjaSpace.s3,
            vertical: LonjaSpace.s2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                message,
                style: type.legalSmall.copyWith(color: tokens.onSurface),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Six ruled skeleton rows, and no spinner.
///
/// A spinner says "something is happening"; a skeleton says "a list of rows is
/// coming, and it will be this shape". On a 1.2 s cold start the second is the
/// one that stops a fisher tapping again.
class LonjaListSkeleton extends StatelessWidget {
  /// Draws [rows] placeholder rows.
  const LonjaListSkeleton({this.rows = 6, super.key});

  /// How many.
  final int rows;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    return Column(
      children: <Widget>[
        for (var i = 0; i < rows; i++) ...<Widget>[
          SizedBox(
            height: tokens.density.rowHeight,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: LonjaSpace.s3),
              child: DecoratedBox(decoration: BoxDecoration(color: tokens.surfaceSunk)),
            ),
          ),
          const LonjaRule.row(),
        ],
      ],
    );
  }
}
