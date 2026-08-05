import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/services/reference_install_progress.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/bootstrap/first_run_screen.dart';
import 'package:catchlaw/ui/bootstrap/view_models/first_run_stage.dart';
import 'package:catchlaw/ui/bootstrap/widgets/first_run_manifest.dart';
import 'package:catchlaw/ui/bootstrap/widgets/first_run_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

/// A payload whose quarters are whole kilobytes, so a figure in an expectation
/// is the figure a reader sees rather than a rounding of one.
const int _kTotalBytes = 400 * 1024;

Future<void> _pumpFirstRun(
  WidgetTester tester, {
  required int bytesWritten,
  Duration? remaining,
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: noRetry,
      overrides: <Override>[
        // A reporter frozen at one frame of the extraction: no installer, no
        // gzip stream and no file. The estimate is handed in rather than
        // measured, and the measurement itself is exercised where it lives.
        referenceInstallReporterProvider.overrideWithValue(
          ReferenceInstallReporter.at(
            ReferenceInstallProgress(
              bytesWritten: bytesWritten,
              bytesTotal: _kTotalBytes,
              remaining: remaining,
            ),
          ),
        ),
      ],
      child: MaterialApp(
        theme: resolveLonjaTheme(skin: LonjaSkin.paper, gloved: false),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FirstRunScreen(),
      ),
    ),
  );
  await tester.pump();
}

String _allCopy(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((Text t) => (t.data ?? t.textSpan?.toPlainText() ?? '').toLowerCase())
    .join(' ');

void main() {
  group('FirstRunScreen', () {
    testWidgets('names what is being unpacked', (WidgetTester tester) async {
      await _pumpFirstRun(tester, bytesWritten: _kTotalBytes ~/ 2);

      expect(find.text('Setting out the rule book'), findsOneWidget);
    });

    testWidgets('never says the rule book is being downloaded', (WidgetTester tester) async {
      await _pumpFirstRun(tester, bytesWritten: _kTotalBytes ~/ 2);

      // The payload shipped inside the binary. The wrong verb here teaches the
      // one thing about this product that must not be learned wrongly, at the
      // one moment a reader is most likely to believe it.
      // `account` and `sign-in` are NOT banned here: the footer refuses both by
      // name, and a screen that could not say so would have no way to state the
      // guarantee. What is banned is any word that describes a transfer.
      final String copy = _allCopy(tester);
      for (final banned in const <String>[
        'downloading',
        'connecting',
        'server',
        'internet',
        'wi-fi',
        'updating',
      ]) {
        expect(copy.contains(banned), isFalse, reason: banned);
      }
    });

    testWidgets('states that nothing is being downloaded and nothing can fail', (
      WidgetTester tester,
    ) async {
      await _pumpFirstRun(tester, bytesWritten: _kTotalBytes ~/ 2);

      expect(find.textContaining('there is no network request to fail'), findsOneWidget);
    });

    testWidgets('prints the kilobytes written beside the percentage', (WidgetTester tester) async {
      await _pumpFirstRun(tester, bytesWritten: _kTotalBytes ~/ 4);

      // A bar with no absolute number cannot be told from one that is stuck.
      expect(find.textContaining('100'), findsWidgets);
      expect(find.textContaining('400'), findsWidgets);
      expect(find.textContaining('25%'), findsOneWidget);
    });

    testWidgets('fills the determinate bar to the fraction reported', (WidgetTester tester) async {
      await _pumpFirstRun(tester, bytesWritten: _kTotalBytes ~/ 4);

      final FirstRunProgressBar bar = tester.widget<FirstRunProgressBar>(
        find.byType(FirstRunProgressBar),
      );
      expect(bar.fraction, closeTo(0.25, 0.0001));
    });

    testWidgets('draws no indeterminate indicator at any point', (WidgetTester tester) async {
      await _pumpFirstRun(tester, bytesWritten: 1);

      // Six indeterminate seconds on a dark boat reads as a hang, and a hang on
      // first launch is the moment the app is deleted.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('itemises the four shares of the stream', (WidgetTester tester) async {
      await _pumpFirstRun(tester, bytesWritten: _kTotalBytes ~/ 2);

      expect(find.byType(FirstRunManifest), findsOneWidget);
      expect(find.text('RULE PACK'), findsOneWidget);
      expect(find.text('LEGAL TEXT'), findsOneWidget);
      expect(find.text('SPECIES PLATES'), findsOneWidget);
      expect(find.text('GLOSSARY AND KEY'), findsOneWidget);
    });

    testWidgets('marks the share being written in progress with no tick and no colour', (
      WidgetTester tester,
    ) async {
      // Five eighths: the first two quarters are written, the third is open.
      await _pumpFirstRun(tester, bytesWritten: (_kTotalBytes * 5) ~/ 8);

      expect(find.text('In progress…'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('marks a share the stream has not reached as not yet unpacked', (
      WidgetTester tester,
    ) async {
      await _pumpFirstRun(tester, bytesWritten: (_kTotalBytes * 5) ~/ 8);

      // Distinct from `In progress…`, because a sheet that showed both alike
      // would be claiming work that has not begun.
      expect(find.text('Not yet unpacked'), findsOneWidget);
    });

    testWidgets('prints a byte figure beside every finished share', (WidgetTester tester) async {
      await _pumpFirstRun(tester, bytesWritten: (_kTotalBytes * 5) ~/ 8);

      // Two quarters of 400 kB, each printed as its own 100 kB figure.
      expect(find.textContaining('· done'), findsNWidgets(2));
    });

    testWidgets('omits the estimate until the stream has a rate', (WidgetTester tester) async {
      await _pumpFirstRun(tester, bytesWritten: 1);

      // An estimate printed before there is a rate is a number the device
      // invented, and this screen prints no number it did not measure.
      expect(find.textContaining('remaining'), findsNothing);
    });

    testWidgets('prints the estimate once the stream has a rate', (WidgetTester tester) async {
      await _pumpFirstRun(
        tester,
        bytesWritten: _kTotalBytes ~/ 2,
        remaining: const Duration(milliseconds: 3400),
      );

      // Rounded up, so a wait of 400 ms prints one second rather than none.
      expect(find.text('About 4 s remaining'), findsOneWidget);
    });

    testWidgets('pins the footer below everything the extraction reports', (
      WidgetTester tester,
    ) async {
      await _pumpFirstRun(tester, bytesWritten: _kTotalBytes ~/ 2);

      final Finder footer = find.textContaining('No account. No sign-in. No sync.');
      expect(footer, findsOneWidget);
      expect(
        tester.getTopLeft(footer).dy,
        greaterThan(tester.getBottomLeft(find.byType(FirstRunProgressBar)).dy),
      );
    });

    testWidgets('carries the offline badge this screen alone prints', (WidgetTester tester) async {
      await _pumpFirstRun(tester, bytesWritten: _kTotalBytes ~/ 2);

      expect(find.text('NO SIGNAL · OFFLINE BY DESIGN'), findsOneWidget);
    });

    testWidgets('offers nothing to tap while the extraction runs', (WidgetTester tester) async {
      await _pumpFirstRun(tester, bytesWritten: _kTotalBytes ~/ 2);

      // There is no way to skip an extraction and no reason to offer one: the
      // app cannot answer a single question until the file is on disk.
      expect(find.byType(ButtonStyleButton), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('renders right to left with Arabic copy when the locale is ar', (
      WidgetTester tester,
    ) async {
      await _pumpFirstRun(tester, bytesWritten: _kTotalBytes ~/ 2, locale: const Locale('ar'));

      expect(find.text('ترتيب كتاب الأحكام'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(FirstRunProgressBar))),
        TextDirection.rtl,
      );
    });
  });

  group('FirstRunStage', () {
    test('declares four contiguous shares covering the whole stream', () {
      expect(FirstRunStage.values, hasLength(4));
      expect(FirstRunStage.rulePack.beginsAt, 0);
      expect(FirstRunStage.glossary.completesAt, 1);
      for (var i = 1; i < FirstRunStage.values.length; i++) {
        expect(FirstRunStage.values[i].beginsAt, FirstRunStage.values[i - 1].completesAt);
      }
    });

    test('reports every share pending before a byte has landed', () {
      const progress = ReferenceInstallProgress(bytesWritten: 0, bytesTotal: _kTotalBytes);
      for (final FirstRunStage stage in FirstRunStage.values) {
        expect(stage.stateIn(progress), FirstRunStageState.pending, reason: stage.name);
      }
    });

    test('reports the share holding the cursor running and the ones behind it done', () {
      const progress = ReferenceInstallProgress(
        bytesWritten: (_kTotalBytes * 5) ~/ 8,
        bytesTotal: _kTotalBytes,
      );
      expect(FirstRunStage.rulePack.stateIn(progress), FirstRunStageState.done);
      expect(FirstRunStage.legalText.stateIn(progress), FirstRunStageState.done);
      expect(FirstRunStage.speciesPlates.stateIn(progress), FirstRunStageState.running);
      expect(FirstRunStage.glossary.stateIn(progress), FirstRunStageState.pending);
    });

    test('reports every share done when the last byte lands', () {
      const progress = ReferenceInstallProgress(
        bytesWritten: _kTotalBytes,
        bytesTotal: _kTotalBytes,
      );
      for (final FirstRunStage stage in FirstRunStage.values) {
        expect(stage.stateIn(progress), FirstRunStageState.done, reason: stage.name);
      }
    });
  });
}
