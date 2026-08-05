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
    // Both lower registers are dropped by the SIGNAL SET, not by whether one
    // was passed: that is what makes "protected prints no measurement" a
    // property of the category rather than of whichever caller happened to
    // leave it null. They are two flags and not one, because a closure prints
    // its own figures — which day of the window today is — and never a margin.
    final String? detail = signals.detailed ? stamp.detail : null;
    final String? meta = signals.measured ? stamp.meta : null;

    // The one place in this app where a widget branches on the skin, and it is
    // a change of construction rather than of colour: at 100 000 lux a hairline
    // frame around tilted ink is absent, not dim, so the block reverses out
    // onto a solid ground and gives up the tilt with it (D-20).
    final reversed = LonjaSkinScope.of(context) == LonjaSkin.sunlight;

    return _VerdictStamp(
      headline: stamp.headline,
      detail: detail,
      meta: meta,
      glyph: signals.glyph,
      ink: reversed ? tokens.surface : ink,
      ground: reversed ? ink : null,
      tilt: reversed ? 0 : kVerdictStampTilt,
    );
  }
}

/// The struck block itself — three registers between two double rules.
///
/// **Three type steps, not one.** The block used to set the whole finding at
/// `type.verdict`: at 42 pt a sentence carrying two numbers and a method wraps
/// to four lines and pushes the facts table it rests on off the screen. The
/// state now takes the `title` step, the figures the mono `datum` step, and the
/// margin the tracked `microLabel` — which is the order a glance reads them in.
class _VerdictStamp extends StatelessWidget {
  const _VerdictStamp({
    required this.headline,
    required this.detail,
    required this.meta,
    required this.glyph,
    required this.ink,
    required this.ground,
    required this.tilt,
  });

  final String headline;

  /// The figures line, or null where the category prints none.
  final String? detail;

  /// The margin line, or null where no measurement applies.
  final String? meta;

  final LonjaGlyph glyph;
  final Color ink;

  /// The fill behind the block, or null where the stamp is struck on the sheet.
  final Color? ground;

  /// The strike angle, in radians. Zero where the stamp is reversed out.
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final String? detail = this.detail;
    final String? meta = this.meta;

    // One node, and the category word first. Four sibling nodes would be read
    // in four orders — four chances to hear "38 centimetres" without hearing
    // what it fails. Splitting the stamp into three registers is a change to
    // how it is SET, not to how it is announced.
    //
    // `excludeSemantics` rather than a `MergeSemantics` wrapper: with the
    // descendants merged rather than dropped, the label below would be read
    // AND then the same words again from the Text nodes under it.
    return Semantics(
      header: true,
      liveRegion: true,
      label: <String>[headline, ?detail, ?meta].join('. '),
      excludeSemantics: true,
      child: Padding(
        // `.stamp{margin:var(--s6) var(--s4) 0}`. The top gap was s7 — 48 dp of
        // nothing between the plate caption and the answer, on the screen whose
        // whole claim is that the answer is readable in five seconds.
        padding: const EdgeInsetsDirectional.fromSTEB(
          LonjaSpace.s4,
          LonjaSpace.s6,
          LonjaSpace.s4,
          0,
        ),
        child: Transform.rotate(
          angle: tilt,
          // The whole block is set in one ink, so the glyph, the rules and the
          // words cannot come out in three colours. `copyWith` carries a colour
          // and nothing else — the metrics are the ramp's
          // (`lonja-typography` rule 4), and the three registers name their own
          // steps over this one.
          child: DefaultTextStyle.merge(
            style: type.title.copyWith(color: ink),
            child: _Ground(
              ground: ground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // `.phone.sun .stamp{border:0}`. Once the block reverses out,
                  // the double rules are what the reversal already did: a solid
                  // field of ink IS the frame, and a white rule riding inside
                  // it is a hairline drawn across a stamp — the exact mark that
                  // at 100 000 lux is absent rather than dim.
                  if (ground == null) const _DoubleRule(),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: LonjaSpace.s3),
                    child: Row(
                      // Centred on the headline, not hung from its top: the
                      // glyph and the state word are one mark, and a 30 dp
                      // glyph top-aligned against a 26 pt line reads as a
                      // bullet that slipped.
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Excluded rather than labelled: the glyph says exactly
                        // what the headline beside it says, and two nodes read
                        // it twice.
                        ExcludeSemantics(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(end: LonjaSpace.s3),
                            child: LonjaIcon(glyph, size: LonjaIconSize.stamp),
                          ),
                        ),
                        // No FittedBox, no ellipsis and no clamped text scale:
                        // truncating a verdict removes the half carrying the
                        // threshold, and the page scrolls instead.
                        Expanded(
                          child: Text(
                            // Cased HERE and never in the ARB, because the ARB
                            // is what a translator reads and a shouted sentence
                            // is not the wording anybody approved. A silent
                            // no-op on Arabic, which is why the Arabic ramp
                            // carries the weight instead of the tracking.
                            headline.toUpperCase(), // lonja-type: ok
                            style: type.title,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (detail != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: LonjaSpace.s2),
                      child: Text(
                        detail,
                        // Body ink and not the verdict's, and the mono step:
                        // these are figures to be checked against a ruler and
                        // an article, and they align on a decimal spine only
                        // in tabular numerals. Where the block is reversed out
                        // onto a solid ground there is no body ink to take —
                        // the figures go with the rest of the stamp, or they
                        // are printed dark on dark at 100 000 lux.
                        style: type.datum.copyWith(color: ground == null ? tokens.onSurface : ink),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  if (meta != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: LonjaSpace.s2),
                      child: Text(
                        meta.toUpperCase(), // lonja-type: ok
                        // Inherits the stamp's ink: the margin belongs to the
                        // verdict, not to the body copy.
                        style: type.microLabel,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  if (ground == null) ...<Widget>[
                    const SizedBox(height: LonjaSpace.s3),
                    const _DoubleRule(),
                  ],
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
      // `.phone.sun .stamp{padding:var(--s5) var(--s4)}`. A flat s3 all round
      // set the words hard against the edge of the field: a reversed-out block
      // needs the ink around the letters to read as struck rather than as
      // clipped, and the vertical inset is the one that does that work.
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: LonjaSpace.s4,
          vertical: LonjaSpace.s5,
        ),
        child: child,
      ),
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
