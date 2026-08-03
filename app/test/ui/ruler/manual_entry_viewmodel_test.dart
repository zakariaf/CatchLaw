import 'package:catchlaw/ui/ruler/view_models/manual_entry_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  ProviderSubscription<ManualEntryState> listen() => container.listen(
    manualEntryViewModelProvider,
    (ManualEntryState? _, ManualEntryState _) {},
    fireImmediately: true,
  );

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  ManualEntryViewModel model() => container.read(manualEntryViewModelProvider.notifier);
  ManualEntryState read() => container.read(manualEntryViewModelProvider);

  test('ManualEntryViewModel starts empty', () {
    final ProviderSubscription<ManualEntryState> sub = listen();
    addTearDown(sub.close);
    expect(read().isEmpty, isTrue);
  });

  test('ManualEntryViewModel accumulates digits by arithmetic', () {
    // An int, shifted and added — never a String that gets parsed. A parsed
    // rendered string is a number that has been through a locale's separators
    // and digit shapes and back, and ١٬٢٣٤ round-trips to nothing at all.
    final ProviderSubscription<ManualEntryState> sub = listen();
    addTearDown(sub.close);

    model()
      ..digit(4)
      ..digit(5)
      ..digit(0);
    expect(read().millimetres, 450);
  });

  test('ManualEntryViewModel.backspace removes the last digit', () {
    final ProviderSubscription<ManualEntryState> sub = listen();
    addTearDown(sub.close);

    model()
      ..digit(4)
      ..digit(5)
      ..digit(0)
      ..backspace();
    expect(read().millimetres, 45);
  });

  test('ManualEntryViewModel.backspace on an empty entry is a no-op', () {
    final ProviderSubscription<ManualEntryState> sub = listen();
    addTearDown(sub.close);
    model().backspace();
    expect(read().millimetres, 0);
  });

  test('ManualEntryViewModel refuses to grow past the ceiling', () {
    // A keypad held down must not silently wrap an int, which would turn a
    // stuck thumb into a negative length.
    final ProviderSubscription<ManualEntryState> sub = listen();
    addTearDown(sub.close);

    for (var i = 0; i < 20; i++) {
      model().digit(9);
    }
    expect(read().millimetres, lessThanOrEqualTo(kMaxPlausibleLengthMm * 10));
    expect(read().millimetres, greaterThan(0));
  });

  test('ManualEntryViewModel ignores a non-digit', () {
    final ProviderSubscription<ManualEntryState> sub = listen();
    addTearDown(sub.close);
    model()
      ..digit(-1)
      ..digit(10);
    expect(read().millimetres, 0);
  });

  test('ManualEntryState marks a plausible fish plausible', () {
    // Wide on purpose: a 3 mm entry is a slipped thumb and a 4 m entry is a
    // keypad nobody stopped, but a 2 m fish is a real thing somebody lands.
    expect(const ManualEntryState(millimetres: 450).isPlausible, isTrue);
    expect(const ManualEntryState(millimetres: 2000).isPlausible, isTrue);
  });

  test('ManualEntryState marks a slipped thumb implausible', () {
    expect(const ManualEntryState(millimetres: 3).isPlausible, isFalse);
    expect(const ManualEntryState(millimetres: 40000).isPlausible, isFalse);
  });

  test('ManualEntryViewModel.clear starts again', () {
    final ProviderSubscription<ManualEntryState> sub = listen();
    addTearDown(sub.close);
    model()
      ..digit(4)
      ..digit(5)
      ..clear();
    expect(read().isEmpty, isTrue);
  });
}
