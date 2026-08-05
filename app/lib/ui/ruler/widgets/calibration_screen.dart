import 'package:catchlaw/domain/models/id1_card.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/format/bidi_isolate.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/ruler/view_models/calibration_viewmodel.dart';
import 'package:catchlaw/ui/ruler/widgets/calibration_card_drawing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S4 — teach the screen how big it is.
///
/// **A dimensioned drawing, not a friendly wizard.** The card is a physical
/// constant and the page says so before it asks for anything: the standard is
/// quoted at the top, the outline is drawn to the scale the handle currently
/// implies, and the figures that fit produces are printed underneath in a table
/// a fisher can read against another device.
///
/// **Why this exists at all.** A phone reports logical pixels, not millimetres,
/// and the ratio between them differs by model. So a ruler drawn without
/// calibration is drawn at a guessed scale — and a guessed scale produces a
/// number that LOOKS measured, which is worse than no ruler at all.
///
/// **The reference object is a bank card**, because ISO/IEC 7810 ID-1 fixes it
/// at 85.60 × 53.98 mm and every fisher already has one. Lay the card on the
/// glass, drag the handle to its corner, and the screen knows its own scale.
///
/// **Two steps, and the second one is the point.** The fit step measures how
/// steady a hand is; the verify step asks whether the drawn outline still sits
/// on the card. A fit alone accepts a drag that stopped one centimetre short,
/// and every length measured afterwards is wrong by that much — silently, and
/// in the direction that makes an undersized fish look legal.
class CalibrationScreen extends ConsumerStatefulWidget {
  /// Opens calibration.
  const CalibrationScreen({super.key});

  @override
  ConsumerState<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends ConsumerState<CalibrationScreen> {
  @override
  void initState() {
    super.initState();
    // After the first frame, not in build: the read touches user.db, and a read
    // started during build is a provider mutation mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calibrationViewModelProvider.notifier).load();
    });
  }

  Future<void> _save() async {
    await ref.read(calibrationViewModelProvider.notifier).save();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final CalibrationState state = ref.watch(calibrationViewModelProvider);
    final CalibrationViewModel vm = ref.read(calibrationViewModelProvider.notifier);

    return Scaffold(
      appBar: LonjaScreenBar(
        title: l10n.calibrateTitle,
        sup: l10n.calibrateSup,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsDirectional.all(tokens.density.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // The physical act, in serif: what the fisher does with the
                // card in his hand, before any figure appears on the page.
                Text(
                  state.step == CalibrationStep.fit
                      ? l10n.calibrateFitBody
                      : l10n.calibrateVerifyBody,
                  style: type.legal,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: LonjaSpace.s2),
                // The premise, above the drawing rather than captioned under
                // the control: the reference object is published, and both of
                // its dimensions come from the standard that fixes them.
                Text(
                  isolateLtr(
                    l10n.calibrateCardConstant(
                      kId1WidthMm.toStringAsFixed(2),
                      kId1HeightMm.toStringAsFixed(2),
                    ),
                  ),
                  style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: LonjaSpace.s5),
                CalibrationCardDrawing(handleWidthPx: state.handleWidthPx, onDragBy: vm.dragBy),
                const SizedBox(height: LonjaSpace.s3),
                Center(
                  child: Text(
                    l10n.calibrateDragHandleNote,
                    style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: LonjaSpace.s6),
                LonjaSectionLabel(text: l10n.calibrateScaleLabel),
                const SizedBox(height: LonjaSpace.s3),
                _ScaleTable(state: state),
                const SizedBox(height: LonjaSpace.s5),
                // ONE primary, whose label and action follow the step. Two
                // `LonjaButton.primary` in one file trips `check_lonja_buttons`
                // even in mutually exclusive branches — and the gate has the
                // better shape: there is one way forward from this screen at
                // any moment, so there is one button.
                LonjaButton.primary(
                  label: state.step == CalibrationStep.fit
                      ? l10n.calibrateVerifyAction
                      : l10n.calibrateSaveAction,
                  onPressed: state.step == CalibrationStep.fit ? vm.advanceToVerify : _save,
                ),
                SizedBox(height: tokens.density.tapGap),
                LonjaButton.secondary(label: l10n.calibrateReset, onPressed: vm.reset),
                if (state.lastOutcome != null) ...<Widget>[
                  const SizedBox(height: LonjaSpace.s3),
                  // The plausibility band said no. Stated as a fact about the
                  // measurement rather than as a scolding: a scale outside the
                  // band is a drag that slipped, not a fisher who did it wrong.
                  Text(
                    l10n.calibrateImplausible,
                    style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
                    textAlign: TextAlign.start,
                  ),
                ],
                const SizedBox(height: LonjaSpace.s5),
                Text(
                  l10n.calibrateGlassNote,
                  style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// What the current fit produces, as a ruled sheet.
///
/// **Four rows, and the third one is the honest one.** A calibration screen
/// that printed only the scale would read as a precision it has not got; the
/// expected-error row states how far out a length can be if the fit was one
/// pixel off, derived from the fit itself rather than asserted as a constant.
class _ScaleTable extends StatelessWidget {
  const _ScaleTable({required this.state});

  final CalibrationState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final RulerCalibration? saved = state.saved;
    // Formatted at the point of use and never through a retained formatter:
    // one held across a numeral-lever change keeps the digits it was
    // constructed with.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // The heavier rule opens the sheet and hairlines separate the rows, the
        // way a printed table is ruled.
        const LonjaRule.section(),
        _ScaleLine(
          label: l10n.calibrateRowScale,
          value: isolateLtr(
            numberFormatFor(
              Localizations.localeOf(context),
            ).format(double.parse((state.pxPerMm * 10).toStringAsFixed(1))),
          ),
        ),
        const LonjaRule.row(),
        const _DensityLine(),
        const LonjaRule.row(),
        _ScaleLine(
          label: l10n.calibrateRowError,
          value: l10n.calibrateErrorValue(
            numberFormatFor(
              Localizations.localeOf(context),
            ).format(double.parse(state.expectedErrorMm.toStringAsFixed(1))),
          ),
        ),
        const LonjaRule.row(),
        _ScaleLine(
          label: l10n.calibrateRowLastCalibrated,
          // ISO and unlocalised, like every other date this app quotes; a
          // stated absence rather than a blank cell, which would read as a
          // figure that failed to load.
          value: saved == null
              ? l10n.calibrateNotYet
              : isolateLtr(saved.capturedOn.toIso8601String().substring(0, 10)),
        ),
        const LonjaRule.row(),
      ],
    );
  }
}

/// What the device says about itself.
///
/// Printed beside the measured scale precisely because it does **not** produce
/// it: no arithmetic on a density yields a millimetre, and a fisher comparing
/// two phones deserves to see both figures rather than be told one explains the
/// other.
class _DensityLine extends StatelessWidget {
  const _DensityLine();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return _ScaleLine(
      label: l10n.calibrateRowDensity,
      value: l10n.calibrateDensityValue(
        numberFormatFor(
          Localizations.localeOf(context),
        ).format(MediaQuery.sizeOf(context).width.round()),
        numberFormatFor(
          Localizations.localeOf(context),
        ).format(double.parse(MediaQuery.devicePixelRatioOf(context).toStringAsFixed(2))),
      ),
    );
  }
}

/// One label, one figure.
class _ScaleLine extends StatelessWidget {
  const _ScaleLine({required this.label, required this.value});

  final String label;

  final String value;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: LonjaSpace.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: type.eyebrow.copyWith(color: tokens.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: LonjaSpace.s2),
          Expanded(
            child: Text(
              // Printed as the caller composed it. A figure is isolated at the
              // call site rather than here, because a stated ABSENCE is an
              // ordinary sentence — and an isolate wrapped round an Arabic
              // phrase would force it to read left to right.
              value,
              // Tabular figures, from the ramp: two devices compared side by
              // side only line up on a decimal spine.
              style: type.datum,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
