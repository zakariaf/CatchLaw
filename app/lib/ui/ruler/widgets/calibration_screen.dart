import 'package:catchlaw/domain/models/id1_card.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/ruler/view_models/calibration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S4 — teach the screen how big it is.
///
/// **Why this exists at all.** A phone reports logical pixels, not millimetres,
/// and the ratio between them differs by model. So a ruler drawn without
/// calibration is drawn at a guessed scale — and a guessed scale produces a
/// number that LOOKS measured, which is worse than no ruler at all.
///
/// **The reference object is a bank card**, because ISO/IEC 7810 ID-1 fixes it
/// at 85.60 × 53.98 mm and every fisher already has one. Lay the card on the
/// glass, drag the handle to its edge, and the screen knows its own scale.
///
/// **Two steps, and the second one is the point.** The fit step measures how
/// steady a hand is; the verify step draws a bar of known length and asks
/// whether it matches the card. A fit alone accepts a drag that stopped one
/// centimetre short, and every length measured afterwards is wrong by that
/// much — silently, and in the direction that makes an undersized fish look
/// legal.
class CalibrationScreen extends ConsumerWidget {
  /// Opens calibration.
  const CalibrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final CalibrationState state = ref.watch(calibrationViewModelProvider);
    final CalibrationViewModel vm = ref.read(calibrationViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.calibrateTitle)),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(tokens.density.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                state.step == CalibrationStep.fit
                    ? l10n.calibrateFitBody
                    : l10n.calibrateVerifyBody,
                style: type.legal,
              ),
              const SizedBox(height: LonjaSpace.s5),
              // The handle. Dragged, not typed: the fisher is matching a
              // physical edge on the glass, and a number he types is a number
              // he guessed.
              GestureDetector(
                onHorizontalDragUpdate: (DragUpdateDetails d) => vm.dragTo(d.localPosition.dx),
                child: Container(
                  height: 96,
                  alignment: AlignmentDirectional.centerStart,
                  decoration: BoxDecoration(
                    color: tokens.surfaceSunk,
                    border: Border.all(color: tokens.hairline, width: LonjaRules.rule),
                  ),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: state.handleWidthPx,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: tokens.accent.withValues(alpha: 0.18)),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      Container(width: LonjaRules.stamp, height: 96, color: tokens.onSurface),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: LonjaSpace.s3),
              Text(
                l10n.calibrateCardWidth(kId1WidthMm.toStringAsFixed(2)),
                style: type.datum.copyWith(color: tokens.onSurfaceMuted),
              ),
              const SizedBox(height: LonjaSpace.s5),
              // ONE primary, whose label and action follow the step. Two
              // `LonjaButton.primary` in one file trips `check_lonja_buttons.sh`
              // even in mutually exclusive branches — and the gate has the
              // better shape: there is one way forward from this screen at any
              // moment, so there is one button.
              LonjaButton.primary(
                label: state.step == CalibrationStep.fit
                    ? l10n.calibrateVerifyAction
                    : l10n.calibrateSaveAction,
                onPressed: state.step == CalibrationStep.fit
                    ? vm.advanceToVerify
                    : () async {
                        await vm.save();
                        if (context.mounted) Navigator.of(context).pop();
                      },
              ),
              if (state.lastOutcome != null) ...<Widget>[
                const SizedBox(height: LonjaSpace.s3),
                // The plausibility band said no. Stated as a fact about the
                // measurement rather than as a scolding: a scale outside the
                // band is a drag that slipped, not a fisher who did it wrong.
                Text(
                  l10n.calibrateImplausible,
                  style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
