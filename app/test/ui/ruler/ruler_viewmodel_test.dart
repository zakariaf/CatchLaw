import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:catchlaw/ui/ruler/view_models/ruler_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_calibration_repository.dart';

final RulerCalibration _calibration = RulerCalibration(
  pxPerMm: 10,
  capturedOn: DateTime.utc(2026, 8, 1),
);

void main() {
  late ProviderContainer container;

  ProviderSubscription<RulerState> listen() => container.listen(
    rulerViewModelProvider,
    (RulerState? _, RulerState _) {},
    fireImmediately: true,
  );

  setUp(() {
    container = ProviderContainer(
      retry: noRetry,
      overrides: <Override>[
        calibrationRepositoryProvider.overrideWithValue(FakeCalibrationRepository(_calibration)),
      ],
    );
    addTearDown(container.dispose);
  });

  RulerViewModel model() => container.read(rulerViewModelProvider.notifier);
  RulerState read() => container.read(rulerViewModelProvider);

  test('RulerViewModel starts uncalibrated and with an empty draft', () {
    // null is a real state: manual entry works without a calibration, so a
    // fisher can measure on the first launch of a wet morning.
    final ProviderSubscription<RulerState> sub = listen();
    addTearDown(sub.close);
    expect(read().isCalibrated, isFalse);
    expect(read().draft.isEmpty, isTrue);
  });

  test('RulerViewModel.load picks up the stored calibration', () async {
    final ProviderSubscription<RulerState> sub = listen();
    addTearDown(sub.close);
    await model().load();
    expect(read().calibration, _calibration);
  });

  test('RulerViewModel.dragTo converts through the one shared transform', () async {
    // The SAME transform the painter places its ticks with, in the other
    // direction. A hit-tester doing its own arithmetic would disagree with the
    // ruler by a few pixels, and a few pixels is a reading short of a legal
    // minimum.
    final ProviderSubscription<RulerState> sub = listen();
    addTearDown(sub.close);
    await model().load();

    model().dragTo(450);
    expect(model().cursorMm.value, closeTo(45, 1e-9));
  });

  test('RulerViewModel.dragTo does nothing without a calibration', () {
    // There is no scale to convert with, and a nominal one would be a number
    // nobody measured presented as one somebody did.
    final ProviderSubscription<RulerState> sub = listen();
    addTearDown(sub.close);
    model().dragTo(450);
    expect(model().cursorMm.value, 0);
  });

  test('RulerViewModel.dragTo clamps a drag past the zero edge', () {
    // A negative reading is not a short fish, it is a gesture that ran off the
    // start of the rule.
    final ProviderSubscription<RulerState> sub = listen();
    addTearDown(sub.close);
    model()
      ..state = RulerState(draft: read().draft, calibration: _calibration)
      ..dragTo(-100);
    expect(model().cursorMm.value, 0);
  });

  test('RulerViewModel.mark records a whole-millimetre segment and resets the cursor', () async {
    final ProviderSubscription<RulerState> sub = listen();
    addTearDown(sub.close);
    await model().load();

    model()
      ..dragTo(1804)
      ..mark();
    expect(read().draft.segmentsMm, <int>[180]);
    expect(model().cursorMm.value, 0);
  });

  test('RulerViewModel.mark refuses a zero-length segment', () {
    // A tap with no drag is not a measurement.
    final ProviderSubscription<RulerState> sub = listen();
    addTearDown(sub.close);
    model().mark();
    expect(read().draft.isEmpty, isTrue);
  });

  test('RulerViewModel.cancel keeps what was accepted', () async {
    // Wet hands hit cancel by accident, and a cancel that wiped an accepted
    // 380 mm costs a measurement that cannot be retaken once the fish is in the
    // bin.
    final ProviderSubscription<RulerState> sub = listen();
    addTearDown(sub.close);
    await model().load();

    model()
      ..dragTo(1800)
      ..mark()
      ..dragTo(2000)
      ..mark()
      ..accept();
    expect(read().draft.committedMm, 380);

    model()
      ..dragTo(500)
      ..mark()
      ..cancel();
    expect(read().draft.committedMm, 380);
    expect(read().draft.segmentsMm, isEmpty);
  });

  test('RulerViewModel.undo removes only the last segment', () async {
    final ProviderSubscription<RulerState> sub = listen();
    addTearDown(sub.close);
    await model().load();

    model()
      ..dragTo(1800)
      ..mark()
      ..dragTo(2000)
      ..mark()
      ..undo();
    expect(read().draft.segmentsMm, <int>[180]);
  });

  test('RulerViewModel sums segments into a total longer than the phone', () async {
    // The whole reason a draft is a list: a 65 cm Kanaad does not fit on a
    // 15 cm screen.
    final ProviderSubscription<RulerState> sub = listen();
    addTearDown(sub.close);
    await model().load();

    for (final px in const <int>[1500, 1500, 1500, 1000]) {
      model()
        ..dragTo(px.toDouble())
        ..mark();
    }
    expect(read().draft.totalMm, 550);
  });
}
