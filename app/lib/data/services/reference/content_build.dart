import 'dart:io';

import 'package:catchlaw/data/services/reference/content_build.constants.dart';
import 'package:catchlaw/data/services/reference_installer.dart';
import 'package:meta/meta.dart';

/// The payload this binary ships with, assembled from the generated constants.
///
/// Compiled in, so it is structurally incapable of disagreeing with the asset it
/// travels beside.
const ReferenceBuild kReferenceBuild = ReferenceBuild(
  buildDate: kContentBuildDate,
  bytes: kContentBuildBytes,
  sha256: kContentBuildSha256,
);

/// What the extraction gate concluded.
///
/// **A sealed type, not a bool.** Four outcomes matter and they are not the
/// same, and a `bool` collapses the last two — the one that gets collapsed is
/// the one that needs the log line.
@immutable
sealed class ExtractionDecision {
  const ExtractionDecision();

  /// Whether the installer has work to do.
  bool get needsExtraction => this is! AlreadyInstalled;
}

/// The marker names this build and the file is there. Skip.
final class AlreadyInstalled extends ExtractionDecision {
  /// Nothing to do.
  const AlreadyInstalled();
}

/// No marker at all: a genuine first launch. E12 shows the determinate bar.
final class NeverInstalled extends ExtractionDecision {
  /// The first run on this device.
  const NeverInstalled();
}

/// The marker names a different build: an app update carrying new content.
///
/// Worth logging, because it is the only decision that says *which* pack is
/// being replaced by which.
final class BuildMoved extends ExtractionDecision {
  /// The pack on disk is [installed]; the binary ships [expected].
  const BuildMoved({required this.installed, required this.expected});

  /// What `app_meta.content_build_date` says.
  final String installed;

  /// What this binary was compiled with.
  final String expected;
}

/// A marker with no database behind it: the user cleared storage.
final class FileMissing extends ExtractionDecision {
  /// The marker survived and the file did not.
  const FileMissing({required this.installed});

  /// What the marker still claims.
  final String installed;
}

/// Decides whether the rule book must be extracted, **without opening it**.
///
/// That is the property `SPEC.md` §7.4 states and that a spy asserts: the two
/// values compared are already in hand. [kContentBuildDate] is compiled into the
/// binary — zero I/O — and `app_meta.content_build_date` is one indexed row in a
/// file every screen opens anyway.
///
/// §7.4 records the first draft's circular gate: reading the build date out of
/// the shipped database means opening it, which means decompressing ten
/// megabytes to disk, which is the entire job the check exists to skip. The
/// naive design re-extracts on every launch and pays the worst possible cost —
/// every time, on the cold-start path, for a comparison of twenty bytes.
Future<ExtractionDecision> decideExtraction({
  required MarkerStore marker,
  required File referenceFile,
  String expected = kContentBuildDate,
}) async {
  final String? installed = await marker.read();
  if (installed == null) return const NeverInstalled();
  if (!referenceFile.existsSync()) return FileMissing(installed: installed);
  if (installed != expected) return BuildMoved(installed: installed, expected: expected);
  return const AlreadyInstalled();
}
