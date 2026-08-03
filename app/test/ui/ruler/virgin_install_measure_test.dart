// The epic's headline case, and SPEC.md §4.2's acceptance condition: the core
// loop is complete on first launch.
//
// A fisher opens the app at 05:40 with a fish in his hand and no bank card in
// his pocket. Everything else in E09 depends on that card. This does not.

import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/repositories/calibration_repository.dart';
import 'package:catchlaw/data/repositories/calibration_repository_drift.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/ui/ruler/view_models/manual_entry_viewmodel.dart';
import 'package:catchlaw/ui/ruler/view_models/ruler_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late UserDatabase db;
  late ProviderContainer container;

  setUp(() {
    // A REAL, empty user.db — the state a phone is in the first time the app
    // opens. A fake seeded with null would prove the fake, not the install.
    db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    container = ProviderContainer(
      retry: noRetry,
      overrides: <Override>[
        calibrationRepositoryProvider.overrideWithValue(DriftCalibrationRepository(db)),
      ],
    );
    addTearDown(container.dispose);
  });

  test('a virgin install carries no calibration', () async {
    final CalibrationRepository repo = container.read(calibrationRepositoryProvider);
    expect(await repo.read(), isNull);
  });

  test('the ruler reports itself uncalibrated on a virgin install', () async {
    final ProviderSubscription<RulerState> sub = container.listen(
      rulerViewModelProvider,
      (RulerState? _, RulerState _) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    await container.read(rulerViewModelProvider.notifier).load();
    expect(container.read(rulerViewModelProvider).isCalibrated, isFalse);
  });

  test('a fisher measures 45 cm on a virgin install without ever seeing a card', () async {
    // THE row. Manual entry does not read the calibration, does not ask for
    // one, and does not fall back to a nominal scale — which would be a number
    // nobody measured presented as one somebody did.
    final ProviderSubscription<ManualEntryState> sub = container.listen(
      manualEntryViewModelProvider,
      (ManualEntryState? _, ManualEntryState _) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    container.read(manualEntryViewModelProvider.notifier)
      ..digit(4)
      ..digit(5)
      ..digit(0);

    final ManualEntryState entry = container.read(manualEntryViewModelProvider);
    expect(entry.millimetres, 450);
    expect(entry.isPlausible, isTrue);

    // And the store is still untouched: measuring manually never writes a
    // calibration, so the next launch does not think the screen was measured.
    expect(await container.read(calibrationRepositoryProvider).read(), isNull);
  });

  test('manual entry never consults the calibration repository', () async {
    // Structural, not incidental. If manual entry ever reached for a scale it
    // would stop working on exactly the install this test is about.
    final ProviderSubscription<ManualEntryState> sub = container.listen(
      manualEntryViewModelProvider,
      (ManualEntryState? _, ManualEntryState _) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    container.read(manualEntryViewModelProvider.notifier).digit(4);
    // The calibration provider is still a throwing placeholder in a container
    // that never overrode it — reached, this would have thrown.
    final ProviderContainer bare = ProviderContainer(retry: noRetry);
    addTearDown(bare.dispose);
    final ProviderSubscription<ManualEntryState> bareSub = bare.listen(
      manualEntryViewModelProvider,
      (ManualEntryState? _, ManualEntryState _) {},
      fireImmediately: true,
    );
    addTearDown(bareSub.close);

    bare.read(manualEntryViewModelProvider.notifier)
      ..digit(4)
      ..digit(5)
      ..digit(0);
    expect(bare.read(manualEntryViewModelProvider).millimetres, 450);
  });
}
