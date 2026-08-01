import 'package:meta/meta.dart';

/// Why the rule book could not be installed.
///
/// A sealed family so a new failure is a compile error at every `switch`, and
/// each arm carries the **parameters** a caller needs rather than a formatted
/// sentence: this package holds no user-visible wording, and the E12 screen that
/// renders it must be free to say it in six languages.
///
/// Every arm's [code] is stable. It is what a log line and a support
/// conversation both name, and it must survive a rewording of the message.
@immutable
sealed class ReferenceInstallFailure implements Exception {
  const ReferenceInstallFailure();

  /// The stable identifier, e.g. `reference.payload_corrupt`.
  String get code;
}

/// The gzipped asset is not in the bundle.
///
/// Names the key, so a mis-typed `pubspec.yaml` entry is one line to diagnose
/// rather than an afternoon.
final class ReferenceAssetMissing extends ReferenceInstallFailure {
  /// The asset key that was asked for.
  const ReferenceAssetMissing({required this.assetKey});

  /// The bundle key, e.g. `assets/db/reference.db.gz`.
  final String assetKey;

  @override
  String get code => 'reference.asset_missing';

  @override
  String toString() => '$code($assetKey)';
}

/// The extracted bytes are not the bytes the build produced.
///
/// Both numbers travel, because the two say different things: a byte count that
/// is short is truncation, and a byte count that matches with a different digest
/// is corruption.
final class ReferencePayloadCorrupt extends ReferenceInstallFailure {
  /// A payload that failed verification.
  const ReferencePayloadCorrupt({
    required this.expectedSha256,
    required this.expectedBytes,
    required this.actualBytes,
  });

  /// The digest `reference.build.json` recorded, over the **uncompressed** file.
  final String expectedSha256;

  /// The uncompressed byte count the build measured.
  final int expectedBytes;

  /// What actually arrived.
  final int actualBytes;

  @override
  String get code => 'reference.payload_corrupt';

  @override
  String toString() => '$code(expected $expectedBytes bytes, got $actualBytes)';
}

/// There is not enough room to extract.
///
/// Carries the byte count, because the user can act on "needs 41 MB" and cannot
/// act on "write failed".
final class ReferenceNoSpace extends ReferenceInstallFailure {
  /// A disk-full failure needing [neededBytes].
  const ReferenceNoSpace({required this.neededBytes});

  /// The uncompressed size the extraction requires.
  final int neededBytes;

  @override
  String get code => 'reference.no_space';

  @override
  String toString() => '$code($neededBytes bytes)';
}

/// The filesystem refused a step, and the step is named.
final class ReferenceInstallIoFailed extends ReferenceInstallFailure {
  /// An I/O failure at [step].
  const ReferenceInstallIoFailed({required this.step});

  /// `sweep`, `open`, `write`, `verify`, `rename` or `marker`.
  final String step;

  @override
  String get code => 'reference.io_failed';

  @override
  String toString() => '$code($step)';
}
