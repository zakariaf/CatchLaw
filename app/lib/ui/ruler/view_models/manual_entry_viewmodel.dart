import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The plausible range of a fish, in millimetres.
///
/// Wide on purpose: a 3 mm entry is a slipped thumb and a 4 m entry is a
/// keypad nobody stopped, but a 2 m fish is a real thing somebody lands.
const int kMinPlausibleLengthMm = 10;

/// 3 000 mm — three metres.
const int kMaxPlausibleLengthMm = 3000;

/// What has been typed so far.
@immutable
class ManualEntryState {
  /// A number under construction.
  const ManualEntryState({this.millimetres = 0});

  /// The accumulator, in millimetres.
  ///
  /// **An `int`, accumulated by arithmetic — never a `String` that gets
  /// parsed.** A parsed rendered string is a number that has been through a
  /// locale's separators and digit shapes and back, and `١٬٢٣٤` round-trips to
  /// nothing at all. Keeping it an integer means the digits a fisher pressed
  /// are the number that gets stored.
  final int millimetres;

  /// Whether the number could be a fish.
  bool get isPlausible =>
      millimetres >= kMinPlausibleLengthMm && millimetres <= kMaxPlausibleLengthMm;

  /// Whether anything has been typed.
  bool get isEmpty => millimetres == 0;
}

/// Manual length entry.
///
/// **This is what makes the product complete on a virgin install.** Everything
/// else in E09 depends on a bank card; this does not. `SPEC.md` §4.2 states it
/// as an acceptance condition — the core loop works before calibration — so a
/// fisher who opens the app at 05:40 with a fish in his hand and no card in his
/// pocket can still get an answer.
class ManualEntryViewModel extends Notifier<ManualEntryState> {
  @override
  ManualEntryState build() => const ManualEntryState();

  /// Appends [digit].
  ///
  /// Shifts and adds rather than concatenating text, and refuses to grow past
  /// the ceiling — a keypad held down must not silently wrap an int.
  void digit(int digit) {
    if (digit < 0 || digit > 9) return;
    final int next = state.millimetres * 10 + digit;
    if (next > kMaxPlausibleLengthMm * 10) return;
    state = ManualEntryState(millimetres: next);
  }

  /// Removes the last digit.
  void backspace() => state = ManualEntryState(millimetres: state.millimetres ~/ 10);

  /// Starts again.
  void clear() => state = const ManualEntryState();
}

/// Manual length entry.
final NotifierProvider<ManualEntryViewModel, ManualEntryState> manualEntryViewModelProvider =
    NotifierProvider<ManualEntryViewModel, ManualEntryState>(
      ManualEntryViewModel.new,
      isAutoDispose: true,
    );
