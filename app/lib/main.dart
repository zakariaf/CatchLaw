import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/services/app_directories.dart';
import 'package:flutter/material.dart';
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
void main() => runApp(
  ProviderScope(
    overrides: dataOverrides(directories: const PathProviderDirectories()),
    retry: noRetry,
    child: const CatchlawApp(),
  ),
);

/// The application root.
///
/// Carries no theme, no colour and no route yet: the Lonja theme lives at
/// `app/lib/theme/` and arrives in E07 (D-2), and the navigation shell in E12.
class CatchlawApp extends StatelessWidget {
  /// Creates the application root.
  const CatchlawApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: SizedBox.shrink());
}
