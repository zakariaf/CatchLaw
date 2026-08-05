import 'dart:async';

import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/services/reference_install_progress.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/bootstrap/first_run_screen.dart';
import 'package:catchlaw/ui/check/check_screen.dart';
import 'package:catchlaw/ui/core/ui/app_shell.dart';
import 'package:catchlaw/ui/core/ui/lonja_nav_strip.dart';
import 'package:catchlaw/ui/zones/view_models/zone_providers.dart';
import 'package:catchlaw/ui/zones/zone_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

/// A place stream that never answers — the window the extraction runs in.
///
/// On a genuine first launch `evaluationScopeProvider` reaches the reference
/// database, whose `LazyDatabase` callback is what triggers the extraction; so
/// "the place has not resolved" and "the rule book is being written" are the
/// same seconds, and this is how a test holds that window open.
Stream<EvaluationScope?> _neverAnswers() =>
    Stream<EvaluationScope?>.fromFuture(Completer<EvaluationScope?>().future);

Future<void> _pumpCheck(WidgetTester tester, {required ReferenceInstallReporter reporter}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: <Override>[
        evaluationScopeProvider.overrideWith((Ref ref) => _neverAnswers()),
        referenceInstallReporterProvider.overrideWithValue(reporter),
      ],
      child: MaterialApp(
        theme: resolveLonjaTheme(skin: LonjaSkin.paper, gloved: false),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CheckScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('CheckScreen', () {
    testWidgets('shows the first-run extraction while the place resolves and bytes are landing', (
      WidgetTester tester,
    ) async {
      // The reachability this whole screen turns on: the extraction ran
      // headlessly for a release, and the Check branch drew a blank box in
      // front of it.
      await _pumpCheck(
        tester,
        reporter: ReferenceInstallReporter.at(
          const ReferenceInstallProgress(bytesWritten: 64 * 1024, bytesTotal: 200704),
        ),
      );

      expect(find.byType(FirstRunScreen), findsOneWidget);
      expect(find.text('Setting out the rule book'), findsOneWidget);
      expect(find.byType(ZonePickerScreen), findsNothing);
    });

    testWidgets('shows no extraction screen while the place resolves and no bytes have landed', (
      WidgetTester tester,
    ) async {
      // The second launch and every launch after it. `ReferenceInstaller`
      // reports nothing when the marker already names this build, so a takeover
      // keyed on `loading` alone would flash the words "Setting out the rule
      // book" every single time the app opened.
      await _pumpCheck(tester, reporter: ReferenceInstallReporter());

      expect(find.byType(FirstRunScreen), findsNothing);
      expect(find.text('Setting out the rule book'), findsNothing);
    });

    testWidgets('redraws the bar as the extraction reports further bytes', (
      WidgetTester tester,
    ) async {
      // The place stream emits once, at the end. A branch that only rebuilt
      // with it would print whichever figure happened to be current on the
      // frame it mounted, and the bar would sit still while the file grew.
      final reporter = ReferenceInstallReporter();
      addTearDown(reporter.dispose);
      reporter.report(50000, 200000);
      await _pumpCheck(tester, reporter: reporter);

      expect(find.textContaining('25%'), findsOneWidget);

      reporter.report(150000, 200000);
      await tester.pump();

      expect(find.textContaining('75%'), findsOneWidget);
    });
  });

  group('AppShell', () {
    // No `ProviderScope`: the shell takes the listenable as an argument, so
    // the strip, the stack and branch history stay pumpable with five
    // `SizedBox`es and no container.
    Future<void> pumpShell(WidgetTester tester, ReferenceInstallReporter reporter) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: resolveLonjaTheme(skin: LonjaSkin.paper, gloved: false),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppShell(
            check: const SizedBox.shrink(),
            today: const SizedBox.shrink(),
            trips: const SizedBox.shrink(),
            reference: const SizedBox.shrink(),
            settings: const SizedBox.shrink(),
            installProgress: reporter.listenable,
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('hides the strip while the one-time extraction is running', (
      WidgetTester tester,
    ) async {
      // Every branch reads the same file. A strip under the takeover offers
      // four destinations that would each land on the same wait, and a tap that
      // leads to a second blank screen reads as an app that has hung.
      await pumpShell(
        tester,
        ReferenceInstallReporter.at(
          const ReferenceInstallProgress(bytesWritten: 64 * 1024, bytesTotal: 200704),
        ),
      );

      expect(find.byType(LonjaNavStrip), findsNothing);
    });

    testWidgets('draws the strip when no extraction is running', (WidgetTester tester) async {
      await pumpShell(tester, ReferenceInstallReporter());

      expect(find.byType(LonjaNavStrip), findsOneWidget);
    });

    testWidgets('draws the strip again once the last byte is written', (WidgetTester tester) async {
      // Keyed on `isInstalling` and not on `hasStarted`: a session-long flag
      // would suppress the strip for as long as the app stayed open.
      await pumpShell(
        tester,
        ReferenceInstallReporter.at(
          const ReferenceInstallProgress(bytesWritten: 200704, bytesTotal: 200704),
        ),
      );

      expect(find.byType(LonjaNavStrip), findsOneWidget);
    });
  });
}
