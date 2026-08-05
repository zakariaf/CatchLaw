import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/id1_card.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
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

/// 300 mm — the span the expected-error band is quoted over.
///
/// A figure of the SCREEN and not of a fish: it is the length of drawn scale a
/// misfit is amplified across, chosen because it is roughly the longest reading
/// a phone can take in one step and because a band quoted over a millimetre
/// reads as zero.
const double kErrorSpanMm = 300;

/// S4's state.
@immutable
class CalibrationState {
  /// The screen, mid-calibration.
  const CalibrationState({
    required this.handleWidthPx,
    this.step = CalibrationStep.fit,
    this.lastOutcome,
    this.saved,
  });

  /// Where the handle is, in logical pixels from the fixed start edge.
  final double handleWidthPx;

  /// Fit, or verify.
  final CalibrationStep step;

  /// What the last save attempt produced, or `null` before one.
  final CalibrationOutcome? lastOutcome;

  /// The scale already stored for this device, or `null` before any.
  ///
  /// Read so the screen can say **when** the stored scale was measured. A
  /// calibration taken a year ago on a cracked screen is still used; it is
  /// never silently reused as if it were fresh, which is the same posture
  /// invariant 5 takes about a stale ruleset.
  final RulerCalibration? saved;

  /// The scale the current handle position implies.
  double get pxPerMm => handleWidthPx / kId1WidthMm;

  /// How far out a reading over [kErrorSpanMm] can be if the fit was one
  /// logical pixel off the edge of the card.
  ///
  /// Derived, never asserted: the card is 85.60 mm and the reading is 300 mm,
  /// so a one-pixel misfit is amplified by the ratio between them. Quoting a
  /// constant band here would be a claim about a device this code has never
  /// seen.
  double get expectedErrorMm => kErrorSpanMm / handleWidthPx;

  /// This state with the named fields replaced.
  CalibrationState copyWith({
    double? handleWidthPx,
    CalibrationStep? step,
    CalibrationOutcome? lastOutcome,
    RulerCalibration? saved,
    bool clearOutcome = false,
  }) => CalibrationState(
    handleWidthPx: handleWidthPx ?? this.handleWidthPx,
    step: step ?? this.step,
    lastOutcome: clearOutcome ? null : (lastOutcome ?? this.lastOutcome),
    saved: saved ?? this.saved,
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

  /// Moves the handle [deltaPx] from where it stands.
  ///
  /// What a corner handle reports is a delta, not a position: the drag starts
  /// wherever the thumb landed on the handle, and treating that as an absolute
  /// coordinate would snap the card by the width of a thumb the moment the
  /// gesture began.
  void dragBy(double deltaPx) => dragTo(state.handleWidthPx + deltaPx);

  /// Reads the scale already stored for this device, if there is one.
  ///
  /// The handle is **not** moved to it. A stored scale is what the last fit
  /// produced, and starting a new fit already seated on it would let a fisher
  /// save the old number by tapping through without ever laying a card down.
  Future<void> load() async {
    final RulerCalibration? saved = await ref.read(calibrationRepositoryProvider).read();
    if (saved == null) return;
    state = state.copyWith(saved: saved);
  }

  /// Returns the handle to where it started.
  ///
  /// What it restores is a **starting position** and never a scale: the nominal
  /// ratio is never stored and never measures. A fisher whose drag ran away
  /// gets the screen back, not a calibration.
  void reset() =>
      state = state.copyWith(handleWidthPx: kNominalPxPerMm * kId1WidthMm, clearOutcome: true);

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
    state = state.copyWith(
      lastOutcome: outcome,
      saved: outcome is CalibrationAccepted ? outcome.calibration : null,
    );
    return outcome;
  }
}

/// S4's state.
final NotifierProvider<CalibrationViewModel, CalibrationState> calibrationViewModelProvider =
    NotifierProvider<CalibrationViewModel, CalibrationState>(
      CalibrationViewModel.new,
      isAutoDispose: true,
    );
