import 'package:catchlaw/data/services/reference_install_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReferenceInstallProgress', () {
    test('reports nothing started before the first chunk lands', () {
      expect(ReferenceInstallProgress.unstarted.hasStarted, isFalse);
      expect(ReferenceInstallProgress.unstarted.fraction, 0);
    });

    test('reports the fraction written over the fraction declared', () {
      const progress = ReferenceInstallProgress(bytesWritten: 50, bytesTotal: 200);
      expect(progress.fraction, 0.25);
      expect(progress.hasStarted, isTrue);
      expect(progress.isComplete, isFalse);
    });

    test('clamps the fraction when more arrives than the payload declared', () {
      // A NaN or a 1.4 reaches a layout constraint as an assertion rather than
      // as a wrong number, and the bar must not run past its own trough.
      const progress = ReferenceInstallProgress(bytesWritten: 300, bytesTotal: 200);
      expect(progress.fraction, 1);
      expect(progress.isComplete, isTrue);
    });

    test('reports a zero fraction with no denominator to divide by', () {
      const progress = ReferenceInstallProgress(bytesWritten: 10, bytesTotal: 0);
      expect(progress.fraction, 0);
      expect(progress.isComplete, isFalse);
    });
  });

  group('ReferenceInstallReporter', () {
    test('holds nothing until the installer reports', () {
      final reporter = ReferenceInstallReporter();
      addTearDown(reporter.dispose);

      expect(reporter.value.hasStarted, isFalse);
      expect(reporter.value.remaining, isNull);
    });

    test('publishes each report to whatever is listening', () {
      final reporter = ReferenceInstallReporter();
      addTearDown(reporter.dispose);
      final seen = <int>[];
      void record() => seen.add(reporter.value.bytesWritten);
      reporter.listenable.addListener(record);
      addTearDown(() => reporter.listenable.removeListener(record));

      reporter
        ..report(64 * 1024, 200704)
        ..report(128 * 1024, 200704);

      expect(seen, <int>[64 * 1024, 128 * 1024]);
    });

    test('offers no estimate from the first report alone', () {
      // The first report is the baseline, not a measurement: there is no span
      // of time behind it and nothing to divide by, so an estimate here would
      // be a number the device invented.
      final reporter = ReferenceInstallReporter();
      addTearDown(reporter.dispose);

      reporter.report(64 * 1024, 200704);

      expect(reporter.value.remaining, isNull);
    });

    test('offers no estimate once every declared byte is written', () {
      final reporter = ReferenceInstallReporter();
      addTearDown(reporter.dispose);

      reporter
        ..report(100, 200)
        ..report(200, 200);

      expect(reporter.value.remaining, isNull);
      expect(reporter.value.isComplete, isTrue);
    });

    test('estimates from the bytes it has watched rather than from the launch', () {
      // The clock starts at the FIRST report, and the bytes already on disk at
      // that instant are the baseline — otherwise the estimate divides the
      // whole app launch into the part of the stream nobody watched.
      final reporter = ReferenceInstallReporter();
      addTearDown(reporter.dispose);

      reporter
        ..report(100, 500)
        ..report(200, 500);

      final Duration? remaining = reporter.value.remaining;
      expect(remaining, isNotNull);
      // 100 bytes measured, 300 left: three spans of whatever the first one
      // took. The span itself is a real elapsed time and is not asserted.
      expect(remaining, greaterThan(Duration.zero));
    });
  });
}
