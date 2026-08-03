import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_verdict_signals.dart';
import 'package:flutter/material.dart';

/// The tilt, in radians — a shade over half a degree, anticlockwise.
///
/// What makes the block read as *struck* rather than laid out. Small enough
/// that nobody notices it and large enough that its absence is felt, which is
/// also why it is a named constant: a value drifted to `-0.02` looks wrong and
/// reviews clean.
const double kVerdictStampTilt = -0.0096;

/// The verdict, struck between two double rules.
///
/// **Printed matter, not a notification.** No `Card`, no elevation, no radius,
/// no shadow and no fill outside the sunlight reversal — a card reads as
/// something the reader may swipe away, and this is a judgement already printed
/// against a published instrument.
///
/// It renders the sentence T01 built and composes none of its own. The category
/// arrives decided; re-deriving it from a measurement here would put a second,
/// untested copy of the law on the screen, and the day a minimum changes only
/// one of the two copies has tests.
class ResultVerdictPanel extends StatelessWidget {
  /// Strikes [stamp], footnoted by [citation].
  const ResultVerdictPanel({required this.stamp, required this.citation, super.key});

  /// The headline finding, already localised.
  final VerdictStampDisplay stamp;

  /// The instrument it rests on. Required and non-nullable — invariant 3, and
  /// a verdict surface that can be built without one is a verdict shipped as an
  /// opinion.
  final CitationDisplay citation;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final VerdictSignals signals = signalsFor(stamp.category);
    final Color ink = switch (signals.ink) {
      VerdictInk.pass => tokens.verdictPass,
      VerdictInk.fail => tokens.verdictFail,
      VerdictInk.warn => tokens.verdictWarn,
    };
    // The sub-line is dropped by the SIGNAL SET, not by whether one was passed:
    // that is what makes "protected prints no measurement" a property of the
    // category rather than of whichever caller happened to leave it null.
    final String? subLine = signals.measured ? stamp.subLine : null;

    // The one place in this app where a widget branches on the skin, and it is
    // a change of construction rather than of colour: at 100 000 lux a hairline
    // frame around tilted ink is absent, not dim, so the block reverses out
    // onto a solid ground and gives up the tilt with it (D-20).
    final reversed = LonjaSkinScope.of(context) == LonjaSkin.sunlight;

    return _VerdictStamp(
      headline: stamp.headline,
      subLine: subLine,
      glyph: signals.glyph,
      ink: reversed ? tokens.surface : ink,
      ground: reversed ? ink : null,
      tilt: reversed ? 0 : kVerdictStampTilt,
    );
  }
}

/// The struck block itself.
class _VerdictStamp extends StatelessWidget {
  const _VerdictStamp({
    required this.headline,
    required this.subLine,
    required this.glyph,
    required this.ink,
    required this.ground,
    required this.tilt,
  });

  final String headline;
  final String? subLine;
  final LonjaGlyph glyph;
  final Color ink;

  /// The fill behind the block, or null where the stamp is struck on the sheet.
  final Color? ground;

  /// The strike angle, in radians. Zero where the stamp is reversed out.
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final LonjaTypeScale type = LonjaType.of(context);
    final String? subLine = this.subLine;

    // One node, and the category word first. Three sibling nodes would be read
    // in three orders — three chances to hear "38 centimetres" without hearing
    // what it fails.
    //
    // `excludeSemantics` rather than a `MergeSemantics` wrapper: with the
    // descendants merged rather than dropped, the label below would be read
    // AND then the same words again from the Text nodes under it.
    return Semantics(
      header: true,
      liveRegion: true,
      label: subLine == null ? headline : '$headline. $subLine',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          LonjaSpace.s4,
          LonjaSpace.s7,
          LonjaSpace.s4,
          0,
        ),
        child: Transform.rotate(
          angle: tilt,
          // The whole block is set in one ramp step and one ink, so the
          // glyph, the rules and the words cannot come out in three colours.
          // `copyWith` carries a colour and nothing else — the metrics are
          // the ramp's (`lonja-typography` rule 4).
          child: DefaultTextStyle.merge(
            style: type.verdict.copyWith(color: ink),
            child: _Ground(
              ground: ground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const _DoubleRule(),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(vertical: LonjaSpace.s3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Excluded rather than labelled: the glyph says exactly
                        // what the headline beside it says, and two nodes read
                        // it twice.
                        ExcludeSemantics(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(end: LonjaSpace.s2),
                            child: LonjaIcon(glyph, size: LonjaIconSize.stamp),
                          ),
                        ),
                        // No FittedBox, no ellipsis and no clamped text scale:
                        // truncating a verdict removes the half carrying the
                        // threshold, and the page scrolls instead.
                        Expanded(child: Text(headline, textAlign: TextAlign.start)),
                      ],
                    ),
                  ),
                  if (subLine != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: LonjaSpace.s3),
                      child: Text(subLine, style: type.measure, textAlign: TextAlign.start),
                    ),
                  const _DoubleRule(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The solid fill the sunlight stamp reverses out onto.
///
/// A [ColoredBox] and not a `Card`, a `Material` or a `DecoratedBox` with a
/// radius: this is a block of ink on paper, and every one of those alternatives
/// carries elevation, a corner or a tint that turns a printed judgement into an
/// overlay the reader may dismiss.
class _Ground extends StatelessWidget {
  const _Ground({required this.ground, required this.child});

  final Color? ground;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color? ground = this.ground;
    if (ground == null) return child;
    return ColoredBox(
      color: ground,
      child: Padding(padding: const EdgeInsetsDirectional.all(LonjaSpace.s3), child: child),
    );
  }
}

/// A rule, a gap, a rule — the frame a struck stamp sits between.
///
/// Drawn in the inherited ink so it cannot drift from the glyph and the words:
/// one colour is set once by the stamp, and there is no second place to set it
/// wrong.
class _DoubleRule extends StatelessWidget {
  const _DoubleRule();

  @override
  Widget build(BuildContext context) {
    final Color ink = DefaultTextStyle.of(context).style.color ?? LonjaTokens.of(context).onSurface;
    final Widget line = SizedBox(
      height: LonjaRules.rule,
      width: double.infinity,
      child: ColoredBox(color: ink),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        line,
        const SizedBox(height: LonjaRules.strong),
        line,
      ],
    );
  }
}
