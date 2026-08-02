import 'package:catchlaw/app.dart';
import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/services/app_directories.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Starts CatchLaw.
///
/// Deliberately synchronous. Nothing is awaited before [runApp]: both databases
/// open lazily on their first query, and every `await` ahead of the first frame
/// is a black screen indistinguishable from a crashed app on the boat where it
/// matters (`catchlaw-conventions-index` rule 8, `SPEC.md` §13).
///
/// [dataOverrides] is the composition root. It builds the real repositories
/// here, once, rather than letting a provider construct a database on demand —
/// so a widget test gets fakes by overriding the same seams, and a forgotten
/// wiring throws by name instead of silently opening SQLite.
void main() {
  // Synchronous, zero I/O: `intl`'s symbol map is process-wide and
  // order-dependent, so it is put in a known state before anything in this
  // process constructs a NumberFormat. Reading the STORED value here would be
  // an await on the launch path — rule 8 again — so NumeralSystemNotifier
  // applies it when `user_profile` resolves, after the first frame.
  applyNumeralSystem(NumeralSystem.auto);

  runApp(
    ProviderScope(
      overrides: dataOverrides(directories: const PathProviderDirectories()),
      retry: noRetry,
      child: const CatchlawApp(),
    ),
  );
}
