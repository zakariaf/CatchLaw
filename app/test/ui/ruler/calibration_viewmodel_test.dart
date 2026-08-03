import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/id1_card.dart';
import 'package:catchlaw/domain/use_cases/calibrate_ruler_use_case.dart';
import 'package:catchlaw/ui/ruler/view_models/calibration_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_calibration_repository.dart';

void main() {
  late FakeCalibrationRepository repo;
  late ProviderContainer container;

  ProviderSubscription<CalibrationState> listen() => container.listen(
    calibrationViewModelProvider,
    (CalibrationState? _, CalibrationState _) {},
    fireImmediately: true,
  );

  setUp(() {
    repo = FakeCalibrationRepository();
    container = ProviderContainer(
      retry: noRetry,
      overrides: <Override>[calibrationRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
  });

  CalibrationViewModel model() => container.read(calibrationViewModelProvider.notifier);
  CalibrationState read() => container.read(calibrationViewModelProvider);

  test('CalibrationViewModel starts on the fit step', () {
    final ProviderSubscription<CalibrationState> sub = listen();
    addTearDown(sub.close);
    expect(read().step, CalibrationStep.fit);
  });

  test('CalibrationViewModel starts the handle at the nominal position', () {
    // A starting position and nothing else: it is never stored and never
    // measures. The fisher moves it, and what he moves it to is the scale.
    final ProviderSubscription<CalibrationState> sub = listen();
    addTearDown(sub.close);
    expect(read().pxPerMm, closeTo(kNominalPxPerMm, 1e-9));
  });

  test('CalibrationViewModel.dragTo clamps rather than refusing', () {
    // A drag that runs off the edge should stop at the edge, not throw the
    // fisher back to the start of the gesture with his card still on the glass.
    final ProviderSubscription<CalibrationState> sub = listen();
    addTearDown(sub.close);

    model().dragTo(-500);
    expect(read().pxPerMm, closeTo(kMinPxPerMm, 1e-9));

    model().dragTo(99999);
    expect(read().pxPerMm, closeTo(kMaxPxPerMm, 1e-9));
  });

  test('CalibrationViewModel.save stores a plausible scale', () async {
    final ProviderSubscription<CalibrationState> sub = listen();
    addTearDown(sub.close);

    model().dragTo(kNominalPxPerMm * kId1WidthMm);
    expect(await model().save(), isA<CalibrationAccepted>());
    expect(repo.saves, hasLength(1));
    expect(repo.saves.single.pxPerMm, closeTo(kNominalPxPerMm, 1e-9));
  });

  test('CalibrationViewModel.save keeps the refusal on the state', () async {
    // A refusal that vanished would leave the fisher looking at the same handle
    // with no idea why nothing happened. The clamp means only a hand-built
    // state can reach here, which is why the row builds one.
    final ProviderSubscription<CalibrationState> sub = listen();
    addTearDown(sub.close);

    model().state = const CalibrationState(handleWidthPx: 10);
    expect(await model().save(), isA<CalibrationImplausible>());
    expect(read().lastOutcome, isA<CalibrationImplausible>());
    expect(repo.saves, isEmpty);
  });

  test('CalibrationViewModel.advanceToVerify moves to the second step', () {
    // Two steps, and the second is the point: a fit step alone measures
    // whatever the fisher dragged to, including a handle he nudged with his
    // palm.
    final ProviderSubscription<CalibrationState> sub = listen();
    addTearDown(sub.close);

    model().advanceToVerify();
    expect(read().step, CalibrationStep.verify);
  });

  test('CalibrationViewModel.back returns to the fit step', () {
    // Always available: a fisher who looks at the verify bar and sees it is
    // wrong must be able to drag again, not start the screen over.
    final ProviderSubscription<CalibrationState> sub = listen();
    addTearDown(sub.close);

    model()
      ..advanceToVerify()
      ..back();
    expect(read().step, CalibrationStep.fit);
  });

  test('CalibrationViewModel.dragTo clears a stale refusal', () {
    // The note is about the handle position that produced it. Leaving it up
    // after the handle moved would be the app refusing something the fisher is
    // no longer proposing.
    final ProviderSubscription<CalibrationState> sub = listen();
    addTearDown(sub.close);

    model().state = const CalibrationState(
      handleWidthPx: 10,
      lastOutcome: CalibrationImplausible(0.1),
    );
    model().dragTo(kNominalPxPerMm * kId1WidthMm);
    expect(read().lastOutcome, isNull);
  });
}
