import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/measurement_draft.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:flutter/foundation.dart' show ValueNotifier, immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S3's state.
@immutable
class RulerState {
  /// The ruler, mid-measurement.
  const RulerState({required this.draft, this.calibration});

  /// What has been marked and what was accepted.
  final MeasurementDraft draft;

  /// The measured scale, or `null` before any calibration.
  ///
  /// `null` is a real state and the screen handles it: manual entry works
  /// without a calibration (T06), so a fisher can measure on the first launch
  /// of a wet morning without lining a card up first.
  final RulerCalibration? calibration;

  /// Whether the ruler can be drawn at all.
  bool get isCalibrated => calibration != null;
}

/// S3 — the ruler.
///
/// The cursor lives in a [ValueNotifier] rather than in the state, because it
/// changes on every pointer move and the state does not. The painter takes it
/// as its `repaint:` listenable, so a drag repaints the canvas without
/// rebuilding a single widget.
class RulerViewModel extends Notifier<RulerState> {
  /// Where the mark sits, in millimetres. Driven by the drag, read by the
  /// painter.
  final ValueNotifier<double> cursorMm = ValueNotifier<double>(0);

  @override
  RulerState build() {
    ref.onDispose(cursorMm.dispose);
    return RulerState(draft: MeasurementDraft());
  }

  /// Loads the stored calibration, if there is one.
  Future<void> load() async {
    final RulerCalibration? calibration = await ref.read(calibrationRepositoryProvider).read();
    state = RulerState(draft: state.draft, calibration: calibration);
  }

  /// Moves the cursor to [localDx] logical pixels from the zero edge.
  ///
  /// Converts through **the one shared transform** — the same one the painter
  /// places its ticks with, in the other direction. A hit-tester that did its
  /// own arithmetic would disagree with the ruler by a few pixels, and a few
  /// pixels is a reading short of a legal minimum.
  void dragTo(double localDx) {
    final RulerCalibration? calibration = state.calibration;
    if (calibration == null) return;
    cursorMm.value = localDx.clamp(0, double.infinity) / calibration.pxPerMm;
  }

  /// Marks the current cursor position as one segment.
  void mark() {
    // Rounded to whole millimetres here, once, by the same transform: storage
    // is integer millimetres and a segment stored as a double would let two
    // screens disagree about the same fish.
    final int segment = cursorMm.value.round();
    if (segment <= 0) return;
    state = RulerState(draft: state.draft.mark(segment), calibration: state.calibration);
    cursorMm.value = 0;
  }

  /// Removes the last segment.
  void undo() => state = RulerState(draft: state.draft.undo(), calibration: state.calibration);

  /// Abandons the marks in progress, keeping whatever was accepted.
  void cancel() {
    state = RulerState(draft: state.draft.cancel(), calibration: state.calibration);
    cursorMm.value = 0;
  }

  /// Commits the running total.
  void accept() {
    state = RulerState(draft: state.draft.accept(), calibration: state.calibration);
    cursorMm.value = 0;
  }
}

/// S3's state.
final NotifierProvider<RulerViewModel, RulerState> rulerViewModelProvider =
    NotifierProvider<RulerViewModel, RulerState>(RulerViewModel.new, isAutoDispose: true);
