/// Isolate hygiene for the one process-wide mutation this app performs.
///
/// `applyNumeralSystem` swaps an entry in `intl`'s public mutable
/// `numberFormatSymbols` map. That map is process-wide, so a test that swaps it
/// and does not put it back corrupts every `NumberFormat` constructed later in
/// the same isolate — and the way that surfaces is a golden failing in a file
/// nobody edited, with a diff showing digits, three files away from the cause.
///
/// Every digit-sensitive test runs `setUp(captureNumberSymbols)` and
/// `tearDown(restoreNumberSymbols)`. E06/T08's `flutter_test_config.dart`
/// asserts [numberSymbolsArePristine] at the file level so the pair cannot be
/// forgotten quietly.
library;

import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';

Map<String, NumberSymbols>? _captured;

/// Records the current symbol table so [restoreNumberSymbols] can undo whatever
/// the test does to it.
///
/// A shallow copy is enough: `applyNumeralSystem` replaces whole entries and
/// never mutates a [NumberSymbols] in place.
void captureNumberSymbols() {
  _captured = Map<String, NumberSymbols>.from(numberFormatSymbols.cast<String, NumberSymbols>());
}

/// Puts the symbol table back exactly as [captureNumberSymbols] found it.
void restoreNumberSymbols() {
  final Map<String, NumberSymbols>? snapshot = _captured;
  if (snapshot == null) return;
  numberFormatSymbols
    ..clear()
    ..addAll(snapshot);
  _captured = null;
}

/// Whether the symbol table matches what [captureNumberSymbols] recorded.
///
/// Returns `true` when nothing was captured — a file that never swapped the map
/// has nothing to be dirty about.
bool numberSymbolsArePristine() {
  final Map<String, NumberSymbols>? snapshot = _captured;
  if (snapshot == null) return true;
  if (numberFormatSymbols.length != snapshot.length) return false;
  for (final MapEntry<String, NumberSymbols> e in snapshot.entries) {
    if (!identical(numberFormatSymbols[e.key], e.value)) return false;
  }
  return true;
}
