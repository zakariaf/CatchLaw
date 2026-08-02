// Directory-scoped and scanned upward (FLUTTER_GUIDE.md §6.2), so everything
// under app/test/ runs through here.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../testing/l10n/number_symbols_guard.dart';
import 'support/golden.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Without this the test font has no Arabic coverage and an `ar` golden is
  // byte-identical to the `en` golden of the same widget (FLUTTER_GUIDE.md
  // §6.4 point 1).
  await loadCatchlawFonts();

  // E06/T04's lever mutates a process-wide map. The per-test setUp/tearDown
  // pair covers a disciplined file; this covers the undisciplined one, and it
  // fails IN THE FILE THAT LEAKED rather than in a golden three files later.
  //
  // The guard degrades honestly: it can only say "this run left the map dirty"
  // if `flutter test` ever stops giving each file its own isolate. That is
  // still better than a silently wrong-digit golden.
  captureNumberSymbols();
  await testMain();
  if (!numberSymbolsArePristine()) {
    throw StateError(
      'numberFormatSymbols was left modified by this test file. '
      'Add setUp(captureNumberSymbols) and tearDown(restoreNumberSymbols).',
    );
  }
}
