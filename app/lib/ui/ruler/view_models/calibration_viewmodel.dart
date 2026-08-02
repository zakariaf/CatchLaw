import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/id1_card.dart';
import 'package:catchlaw/domain/use_cases/calibrate_ruler_use_case.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which half of S4 the fisher is on.
enum CalibrationStep {
  /// Drag the handle to the edge of the card.
  fit,

  /// Look at a bar of known length and say whether it matches.
  verify,
}

/// S4's state.
@immutable
class CalibrationState {
  /// The screen, mid-calibration.
  const CalibrationState({
    required this.handleWidthPx,
    this.step = CalibrationStep.fit,
    this.lastOutcome,
  });

  /// Where the handle is, in logical pixels from the fixed start edge.
  final double handleWidthPx;

  /// Fit, or verify.
  final CalibrationStep step;

  /// What the last save attempt produced, or `null` before one.
  final CalibrationOutcome? lastOutcome;

  /// The scale the current handle position implies.
  double get pxPerMm => handleWidthPx / kId1WidthMm;

  /// This state with the named fields replaced.
  CalibrationState copyWith({
    double? handleWidthPx,
    CalibrationStep? step,
    CalibrationOutcome? lastOutcome,
    bool clearOutcome = false,
  }) => CalibrationState(
    handleWidthPx: handleWidthPx ?? this.handleWidthPx,
    step: step ?? this.step,
    lastOutcome: clearOutcome ? null : (lastOutcome ?? this.lastOutcome),
  );
}

/// S4 — calibration.
///
/// **Two steps, and the second one is the point.** A fit step alone measures
/// whatever the fisher dragged to, including a handle he nudged with his palm.
/// The verify step draws a bar of a length he can check against the same card
/// and asks him to confirm it — so the app never stores a scale that has not
/// been looked at twice.
class CalibrationViewModel extends Notifier<CalibrationState> {
  @override
  CalibrationState build() =>
      // A starting position and nothing else. It is never stored and never
      // measures: the fisher moves it, and what he moves it to is the scale.
      const CalibrationState(handleWidthPx: kNominalPxPerMm * kId1WidthMm);

  /// Moves the handle to [localDx], clamped to the card's own plausible span.
  ///
  /// Clamped rather than refused: a drag that runs off the edge should stop at
  /// the edge, not throw the fisher back to the start of the gesture with his
  /// card still on the glass.
  void dragTo(double localDx) {
    final double clamped = localDx.clamp(kMinPxPerMm * kId1WidthMm, kMaxPxPerMm * kId1WidthMm);
    state = state.copyWith(handleWidthPx: clamped, clearOutcome: true);
  }

  /// Moves to the verify step.
  void advanceToVerify() => state = state.copyWith(step: CalibrationStep.verify);

  /// Returns to the fit step.
  ///
  /// Always available: a fisher who looks at the verify bar and sees it is
  /// wrong must be able to go back and drag again, not start the screen over.
  void back() => state = state.copyWith(step: CalibrationStep.fit, clearOutcome: true);

  /// Judges the current handle position and stores it if it is plausible.
  Future<CalibrationOutcome> save() async {
    final CalibrationOutcome outcome = const CalibrateRulerUseCase(DateTime.now)(
      state.handleWidthPx,
    );
    if (outcome is CalibrationAccepted) {
      await ref.read(calibrationRepositoryProvider).save(outcome.calibration);
    }
    // The refusal is kept on the state so the screen can say what it measured.
    // A refusal that vanished would leave the fisher looking at the same handle
    // with no idea why nothing happened.
    state = state.copyWith(lastOutcome: outcome);
    return outcome;
  }
}

/// S4's state.
final NotifierProvider<CalibrationViewModel, CalibrationState> calibrationViewModelProvider =
    NotifierProvider<CalibrationViewModel, CalibrationState>(
      CalibrationViewModel.new,
      isAutoDispose: true,
    );
