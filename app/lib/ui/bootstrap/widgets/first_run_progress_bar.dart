import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/widgets.dart';

/// The determinate bar: a ruled trough, a solid fill, and ten decile marks.
///
/// **Determinate or nothing.** `SPEC.md` §13 makes the real denominator part of
/// the requirement, and `ReferenceInstaller` reports against the uncompressed
/// byte count the payload declares — so there is no honest reason to draw a
/// spinner here, and every reason not to: six indeterminate seconds on a dark
/// boat reads as a hang, and a hang on first launch is the moment the app is
/// deleted.
///
/// **The decile marks are the second signal.** A fill that grows is a change of
/// colour and length, and on a wet screen in glare the length is the only half
/// that survives. Ruling the trough into tenths gives the fill an edge to be
/// measured against, so *a fifth of the way* is readable without reading the
/// figure beside it — and the figure is printed anyway.
///
/// No `LinearProgressIndicator`: it rounds its ends, animates an indeterminate
/// sweep by default and carries Material's own colour roles.
class FirstRunProgressBar extends StatelessWidget {
  /// Fills to [fraction] of the trough, clamped by the caller.
  const FirstRunProgressBar({required this.fraction, super.key});

  /// Written over declared, in `0..1`.
  final double fraction;

  /// How many marks rule the trough.
  static const int deciles = 10;

  /// The trough's height — the 4pt spine's third step, and the same in both
  /// densities: this is a reading, not a target, and nothing here is tapped.
  static const double troughHeight = LonjaSpace.s3;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: tokens.ruleBearing, width: LonjaRules.rule),
        borderRadius: LonjaRadii.none,
      ),
      child: SizedBox(
        height: troughHeight,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ColoredBox(color: tokens.surfaceSunk),
            // Resolved against the ambient direction: the bar grows from the
            // leading margin, so it fills right-to-left in `ar` without a
            // second code path.
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: fraction,
                heightFactor: 1,
                child: ColoredBox(color: tokens.accent),
              ),
            ),
            const _DecileMarks(),
          ],
        ),
      ),
    );
  }
}

/// Nine hairlines dividing the trough into tenths.
///
/// Nine and not ten: the tenth mark is the trough's own trailing rule, and a
/// line drawn on top of it reads as a thicker border rather than as a mark.
class _DecileMarks extends StatelessWidget {
  const _DecileMarks();

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    return Row(
      children: <Widget>[
        for (int decile = 0; decile < FirstRunProgressBar.deciles; decile++)
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: decile == FirstRunProgressBar.deciles - 1
                  ? const SizedBox.shrink()
                  : SizedBox(
                      width: LonjaRules.rule,
                      height: FirstRunProgressBar.troughHeight,
                      child: ColoredBox(color: tokens.hairlineStrong),
                    ),
            ),
          ),
      ],
    );
  }
}
