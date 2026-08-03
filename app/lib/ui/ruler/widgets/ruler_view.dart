import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/length_display.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/ruler/widgets/ltr_instrument.dart';
import 'package:catchlaw/ui/ruler/widgets/ruler_painter.dart';
import 'package:catchlaw/ui/ruler/widgets/ruler_scene.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

/// The ruler, with everything the painter needs resolved above the pin.
///
/// **The locale is read here, outside [LtrInstrument].** The tick labels are
/// formatted in the reader's own digits and the semantic label reads in the
/// reader's own language — what the pin fixes is the *geometry*, not the
/// language. Reading the locale below the pin would silently give an Arabic
/// fisher Western digits on a scale, which is a different bug wearing the same
/// coat.
class RulerView extends StatelessWidget {
  /// Draws a ruler at [calibration], with the mark at [cursorMm].
  const RulerView({
    required this.calibration,
    required this.cursorMm,
    required this.spanPx,
    this.unit = LengthUnit.cm,
    super.key,
  });

  /// The measured scale.
  final RulerCalibration calibration;

  /// Where the mark sits.
  final ValueListenable<double> cursorMm;

  /// How long the rule is.
  final double spanPx;

  /// Which unit the reading is spoken in.
  final LengthUnit unit;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = Localizations.localeOf(context);

    // The physical hairline. A 1.0 logical stroke is 3 device pixels on a
    // modern phone and reads as a smear at the scale a fisher squints at.
    final double devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final double hairline = 1 / devicePixelRatio;

    final int centimetres = (spanPx / calibration.pxPerMm / 10).floor();
    final scene = RulerScene(
      pxPerMm: calibration.pxPerMm,
      spanPx: spanPx,
      // Formatted through the ONE formatter the whole app uses, so a scale and
      // the chrome beside it can never disagree about which digits to draw.
      tickLabels: <String>[
        for (int cm = 0; cm <= centimetres; cm++) numberFormatFor(locale).format(cm),
      ],
      labelDirection: TextDirection.ltr,
      labelStyle: type.articleNumber.copyWith(color: tokens.onSurfaceMuted),
      ink: tokens.onSurface,
      mark: tokens.accent,
      hairlinePx: hairline,
      tickPx: hairline,
      cursorPx: LonjaRules.strong,
    );

    return Semantics(
      // A hundred tick marks is not a reading, so the canvas is excluded and a
      // sibling node speaks the number.
      label: l10n.rulerSemanticLabel(_reading(l10n)),
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: LtrInstrument(
            child: CustomPaint(
              size: Size(spanPx, 64),
              painter: RulerPainter(scene: scene, cursorMm: cursorMm),
            ),
          ),
        ),
      ),
    );
  }

  /// The current reading, as a number and its unit word.
  ///
  /// Assembled from [LengthDisplay] and an ARB unit key, glued with a
  /// non-breaking space — never concatenated as a bare literal, where the order
  /// is wrong in Arabic.
  String _reading(AppLocalizations l10n) {
    final int millimetres = cursorMm.value.round();
    final String number = LengthDisplay.format(millimetres, unit);
    final String word = switch (unit) {
      LengthUnit.mm => l10n.unitMillimetres,
      LengthUnit.cm => l10n.unitCentimetres,
      LengthUnit.inches => l10n.unitCentimetres,
    };
    return '$number $word';
  }
}
