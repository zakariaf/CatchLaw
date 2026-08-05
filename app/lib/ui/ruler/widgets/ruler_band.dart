import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/format/bidi_isolate.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/ruler/widgets/ruler_view.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

/// The scale, docked to the head of the screen and running to both edges.
///
/// **Full bleed, and that is the whole point.** The band carries no gutter,
/// because the zero mark has to sit on the physical edge of the glass: the
/// instrument on this screen is "lay the screen edge at the snout", and a
/// ruler inset by 16 dp starts measuring 16 dp along the fish. A gutter here
/// is not a spacing choice, it is a systematic error in the fisher's favour on
/// every reading he takes.
///
/// **The provenance line is part of the instrument, not a caption.** A scale
/// drawn on glass is only as good as the calibration behind it, so the band
/// states when the screen was measured and what it measured — both in mono,
/// both comparable by eye against the same line on another device.
class RulerBand extends StatelessWidget {
  /// Draws the scale at [calibration], with the mark at [cursorMm].
  const RulerBand({required this.calibration, required this.cursorMm, this.onDrag, super.key});

  /// The measured scale.
  final RulerCalibration calibration;

  /// Where the mark sits, in millimetres.
  final ValueListenable<double> cursorMm;

  /// Moves the mark to a position in logical pixels from the zero edge.
  final ValueChanged<double>? onDrag;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final ValueChanged<double>? drag = onDrag;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ColoredBox(
          color: tokens.surfaceSunk,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: RulerView.bandHeight,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints c) => GestureDetector(
                    // Opaque, so the whole band takes the drag rather than only
                    // the pixels the painter happened to ink. A fisher sliding
                    // a wet thumb along a comb of hairlines is not aiming.
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: drag == null
                        ? null
                        : (DragUpdateDetails d) => drag(d.localPosition.dx),
                    child: RulerView(
                      calibration: calibration,
                      cursorMm: cursorMm,
                      spanPx: c.maxWidth,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  tokens.density.gutter,
                  LonjaSpace.s1,
                  tokens.density.gutter,
                  LonjaSpace.s2,
                ),
                child: _Provenance(calibration: calibration),
              ),
            ],
          ),
        ),
        // The 2 pt rule that closes the instrument off from the page. Heavier
        // than a block hairline on purpose: everything below it is prose about
        // the measurement, and everything above it is the measurement.
        const LonjaRule.section(),
      ],
    );
  }
}

/// When the screen was measured, and what it measured.
class _Provenance extends StatelessWidget {
  const _Provenance({required this.calibration});

  final RulerCalibration calibration;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Text(
      // Isolated: a date and a scale are Latin runs of figures, and an Arabic
      // line would otherwise carry the unit to the wrong end of them.
      isolateLtr(
        l10n.measureCalibrationProvenance(
          // ISO and unlocalised, like every other date this app quotes.
          calibration.capturedOn.toIso8601String().substring(0, 10),
          // Formatted at the point of use and never through a retained
          // formatter: one held across a numeral-lever change keeps the digits
          // it was constructed with.
          numberFormatFor(
            Localizations.localeOf(context),
          ).format(double.parse((calibration.pxPerMm * 10).toStringAsFixed(1))),
        ),
      ),
      style: type.citation.copyWith(color: tokens.onSurfaceMuted),
      textAlign: TextAlign.start,
    );
  }
}
