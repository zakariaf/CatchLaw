import 'package:catchlaw/data/services/reference/content_build.constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How much of the one-time extraction has reached the disk.
///
/// **Bytes, and the real ones.** `ReferenceInstaller` reports against
/// `reference.build.json`'s *uncompressed* count — the same number
/// [kContentBuildBytes] compiles in — so the bar cannot finish at 94 % or run
/// past 100 %. `SPEC.md` §13 makes the determinate indicator part of the
/// requirement: six indeterminate seconds on a dark boat reads as a hang.
@immutable
class ReferenceInstallProgress {
  /// Records [bytesWritten] of [bytesTotal], with [remaining] as observed.
  const ReferenceInstallProgress({
    required this.bytesWritten,
    required this.bytesTotal,
    this.remaining,
  });

  /// Nothing has been reported yet.
  ///
  /// **Two different facts share this value, and only one of them is a first
  /// launch:** a pack that was already installed reports nothing at all, and a
  /// pack being extracted reports nothing until its first chunk lands. That is
  /// why [hasStarted] is what the screen keys off — a takeover shown on the
  /// strength of "no news" would flash on every launch the app ever makes.
  static const ReferenceInstallProgress unstarted = ReferenceInstallProgress(
    bytesWritten: 0,
    bytesTotal: kContentBuildBytes,
  );

  /// Uncompressed bytes written so far.
  final int bytesWritten;

  /// Uncompressed bytes the payload declares.
  final int bytesTotal;

  /// What is left at the rate observed so far, or absent before there is a
  /// rate to divide by.
  ///
  /// Carried rather than derived, because the rate is a fact about the *stream*
  /// — where it started and how long it has run — and a value type that had to
  /// hold a stopwatch to answer would not be a value type.
  final Duration? remaining;

  /// Whether a first chunk has landed.
  bool get hasStarted => bytesWritten > 0;

  /// Written over declared, clamped into `0..1`.
  ///
  /// Clamped rather than trusted: a denominator of zero is a division that
  /// renders as `NaN` inside a layout constraint, which is an assertion rather
  /// than a wrong number.
  double get fraction => bytesTotal <= 0 ? 0 : (bytesWritten / bytesTotal).clamp(0, 1).toDouble();

  /// Whether every declared byte is on disk.
  bool get isComplete => bytesTotal > 0 && bytesWritten >= bytesTotal;

  /// Whether the extraction is the thing the fisher is looking at.
  ///
  /// **One predicate, read in two places, and that is deliberate.** The Check
  /// branch draws the takeover on it and the shell hides its strip on it; two
  /// conditions that drifted apart would put a five-destination strip under a
  /// screen whose four other branches are all waiting on the same file. It ends
  /// at [isComplete] rather than at the frame the branch finally renders,
  /// because a session-long `hasStarted` would suppress the strip for as long
  /// as the app stayed open.
  bool get isInstalling => hasStarted && !isComplete;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceInstallProgress &&
          other.bytesWritten == bytesWritten &&
          other.bytesTotal == bytesTotal &&
          other.remaining == remaining;

  @override
  int get hashCode => Object.hash(bytesWritten, bytesTotal, remaining);

  @override
  String toString() => 'ReferenceInstallProgress($bytesWritten/$bytesTotal, remaining: $remaining)';
}

/// The installer's `onProgress` callback, made readable by a widget.
///
/// **A listenable and not a stream.** The extraction reports at most once per
/// 64 KiB and the screen mounts somewhere in the middle of that: a broadcast
/// stream would hand a late subscriber nothing until the next chunk, and the
/// bar would sit at zero while the file grew. A retained latest value is what
/// makes "whenever the screen mounts" the same as "as soon as it mounts".
///
/// The clock starts at the **first report**, not at construction, and the bytes
/// seen at that instant are the baseline — so the estimate measures the stream
/// and not the app launch that happened to precede it.
final class ReferenceInstallReporter {
  /// A reporter that has seen nothing.
  ReferenceInstallReporter()
    : _progress = ValueNotifier<ReferenceInstallProgress>(ReferenceInstallProgress.unstarted);

  /// A reporter frozen at [progress].
  ///
  /// The screen reads a listenable, so a test that wants one frame of the
  /// extraction should not have to run a gzip stream to get it. The estimate is
  /// the one thing this cannot stand in for — it is measured, so [report] is
  /// what the estimate's own rows exercise.
  @visibleForTesting
  ReferenceInstallReporter.at(ReferenceInstallProgress progress)
    : _progress = ValueNotifier<ReferenceInstallProgress>(progress);

  final ValueNotifier<ReferenceInstallProgress> _progress;

  final Stopwatch _elapsed = Stopwatch();

  int _baselineBytes = 0;

  /// What the screen watches.
  ValueListenable<ReferenceInstallProgress> get listenable => _progress;

  /// The latest report.
  ReferenceInstallProgress get value => _progress.value;

  /// Records [bytesWritten] of [bytesTotal]. Matches `onProgress`'s signature.
  void report(int bytesWritten, int bytesTotal) {
    if (!_elapsed.isRunning) {
      _baselineBytes = bytesWritten;
      _elapsed.start();
    }
    _progress.value = ReferenceInstallProgress(
      bytesWritten: bytesWritten,
      bytesTotal: bytesTotal,
      remaining: _remaining(bytesWritten, bytesTotal),
    );
  }

  Duration? _remaining(int written, int total) {
    final int measured = written - _baselineBytes;
    final int left = total - written;
    final int micros = _elapsed.elapsedMicroseconds;
    // No measured span, no measured bytes, or nothing left: three different
    // reasons there is no honest estimate, and all three print no estimate
    // rather than a zero that reads as "any moment now".
    if (measured <= 0 || left <= 0 || micros <= 0) return null;
    return Duration(microseconds: (micros * left / measured).round());
  }

  /// Releases the notifier.
  void dispose() {
    _elapsed.stop();
    _progress.dispose();
  }
}

/// The extraction's progress, as the first-run state reads it.
///
/// **A real default, unlike every seam in `providers.dart`.** Those throw
/// because a provider that built a database on demand would open SQLite inside
/// a widget test. This one builds an in-memory counter that has seen nothing,
/// which is exactly what a launch with no extraction behind it should read —
/// so the Check branch renders correctly under a `ProviderScope` that has never
/// heard of `dataOverrides`.
final Provider<ReferenceInstallReporter> referenceInstallReporterProvider =
    Provider<ReferenceInstallReporter>((Ref ref) {
      final reporter = ReferenceInstallReporter();
      ref.onDispose(reporter.dispose);
      return reporter;
    });
