import 'dart:math' as math;

import 'package:catchlaw/domain/models/id1_card.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/format/bidi_isolate.dart';
import 'package:flutter/material.dart';

/// The card, drawn at the scale the handle currently implies.
///
/// **Two dimensions, because a card has two.** The control it replaces was a
/// full-width strip with a bar on the end: a fisher matched one edge and
/// guessed the rest, and a strip gives him no way to see that the card is
/// seated square rather than merely overlapping. The outline is sized on one
/// axis and drawn on both, from the published ratio — so a card laid on the
/// glass either sits inside the rule or it does not.
///
/// **The outline is clipped rather than shrunk when it runs past the glass.**
/// ID-1 is 85.60 mm on its long side and a phone is narrower than that, so at a
/// true scale the card genuinely does run off the screen. Scaling the drawing
/// down to fit would draw a rectangle at a size nothing on the desk matches,
/// which is the one thing this screen may never do; the drag handle stays
/// clamped inside the well so it is always reachable.
///
/// The four corner marks are registration, and only the filled one moves. That
/// distinction is stated in words beside the drawing, because a mark that looks
/// like a control and is not is a mark a wet thumb will fight.
class CalibrationCardDrawing extends StatelessWidget {
  /// Draws the card at [handleWidthPx], reporting drags through [onDragBy].
  const CalibrationCardDrawing({required this.handleWidthPx, required this.onDragBy, super.key});

  /// The card's long side, in logical pixels — the fit itself.
  final double handleWidthPx;

  /// Called with the logical pixels the handle moved, in the reading direction.
  final ValueChanged<double> onDragBy;

  /// The registration marks at the three fixed corners.
  static const double _markSize = LonjaSpace.s4;

  /// The one corner that moves.
  static const double _handleSize = LonjaSpace.s5;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final double cardHeight = handleWidthPx * kId1HeightMm / kId1WidthMm;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surfaceSunk,
        border: Border.all(color: tokens.hairline, width: LonjaRules.rule),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: LonjaSpace.s3,
          vertical: LonjaSpace.s5,
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final double target = tokens.density.tapMin;
            // The card's own corners, in the coordinates of the well. The top
            // is inset by half a target so a mark sitting on the corner is not
            // clipped by the frame.
            final double cardTop = target / 2;
            final double cardBottom = cardTop + cardHeight;
            // The handle is pulled back inside the well when the card runs past
            // it. A control a fisher cannot reach is a screen he cannot leave.
            final double handleCentre = math.min(handleWidthPx, c.maxWidth - target / 2);

            return SizedBox(
              height: cardHeight + target,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: <Widget>[
                  PositionedDirectional(
                    start: 0,
                    top: cardTop,
                    width: handleWidthPx,
                    height: cardHeight,
                    child: _CardOutline(),
                  ),
                  _DimensionLabel(
                    text: l10n.calibrateDimension(kId1WidthMm.toStringAsFixed(2)),
                    start: LonjaSpace.s4,
                    top: cardBottom - LonjaSpace.s6,
                  ),
                  _DimensionLabel(
                    text: l10n.calibrateDimension(kId1HeightMm.toStringAsFixed(2)),
                    start: LonjaSpace.s4,
                    top: cardTop + LonjaSpace.s3,
                  ),
                  for (final (double start, double top) in <(double, double)>[
                    (0, cardTop),
                    (handleCentre, cardTop),
                    (0, cardBottom),
                  ])
                    PositionedDirectional(
                      start: start - _markSize / 2,
                      top: top - _markSize / 2,
                      child: _CornerMark(),
                    ),
                  PositionedDirectional(
                    start: handleCentre - target / 2,
                    top: cardBottom - target / 2,
                    child: _DragHandle(
                      // Mirrored deliberately: the card grows towards the
                      // trailing edge, and in an Arabic layout that edge is on
                      // the other side of the glass. A drag that ignored the
                      // reading direction would shrink the card as the thumb
                      // pulled it open.
                      onDragBy: (double delta) => onDragBy(isRtl ? -delta : delta),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The card's own rule, with an inset second rule inside it.
///
/// Two rules rather than one, because a single line on paper is ambiguous about
/// which side of it the card belongs on.
class _CardOutline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border.all(color: tokens.onSurface, width: LonjaRules.strong),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(LonjaSpace.s2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: tokens.hairline, width: LonjaRules.hair),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// One published dimension, quoted on the drawing.
class _DimensionLabel extends StatelessWidget {
  const _DimensionLabel({required this.text, required this.start, required this.top});

  final String text;

  final double start;

  final double top;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return PositionedDirectional(
      start: start,
      top: top,
      child: Text(
        // A Latin run of figures and a unit: isolated so an Arabic page cannot
        // carry the unit to the wrong end of the number.
        isolateLtr(text),
        style: type.articleNumber.copyWith(color: tokens.onSurfaceMuted),
        textAlign: TextAlign.start,
      ),
    );
  }
}

/// A corner that does not move.
class _CornerMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border.all(color: tokens.accent, width: LonjaRules.strong),
        ),
        child: const SizedBox(
          width: CalibrationCardDrawing._markSize,
          height: CalibrationCardDrawing._markSize,
        ),
      ),
    );
  }
}

/// The corner that does.
///
/// Filled where the others are outlined, so the one control on the drawing is
/// distinguishable by fill and not only by colour — the same rule the verdict
/// stamps keep, for the same reason: in sunlight mode every neutral collapses
/// and hue stops carrying anything.
class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.onDragBy});

  final ValueChanged<double> onDragBy;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);

    return Semantics(
      label: l10n.calibrationHandleLabel,
      child: GestureDetector(
        // Opaque and wider than the ink: the target is the density floor, and
        // the mark inside it is what the eye aims at.
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (DragUpdateDetails d) => onDragBy(d.delta.dx),
        child: SizedBox(
          width: tokens.density.tapMin,
          height: tokens.density.tapMin,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.accent,
                border: Border.all(color: tokens.accent, width: LonjaRules.strong),
              ),
              child: const SizedBox(
                width: CalibrationCardDrawing._handleSize,
                height: CalibrationCardDrawing._handleSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
