import 'dart:convert';
import 'dart:io';

import 'package:catchlaw/data/services/app_directories.dart';
import 'package:catchlaw/data/services/asset_bundle_service.dart';
import 'package:catchlaw/data/services/reference_install_failure.dart';
import 'package:convert/convert.dart' show AccumulatorSink;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show FlutterError, debugPrint, kDebugMode;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

/// What `reference.build.json` recorded about the build being installed.
///
/// Both numbers are over the **uncompressed** file: rule 6 verifies the digest
/// *after* decompression, and the determinate progress bar counts the bytes the
/// user is actually waiting for. A digest of the `.gz` would be verified before
/// the bytes that matter existed.
@immutable
class ReferenceBuild {
  /// The build the asset carries.
  const ReferenceBuild({required this.buildDate, required this.bytes, required this.sha256});

  /// `content_meta.build_date`, and the value written to the completion marker.
  final String buildDate;

  /// The uncompressed byte count.
  final int bytes;

  /// The uncompressed sha256.
  final String sha256;
}

/// Where the "this build is installed" fact is recorded.
///
/// A port, because D-6 assigns the marker to `app_meta.content_build_date` in
/// `user.db` and E05/T03 supplies that implementation. The skill's worked
/// example uses an `INSTALLED` stamp file; **two markers would be one too many,
/// and the one that is not written last is the one that lies.**
abstract interface class MarkerStore {
  /// The installed build date, or `null` when nothing is installed.
  Future<String?> read();

  /// Records [buildDate] as installed.
  Future<void> write(String buildDate);

  /// Forgets whatever was installed.
  Future<void> clear();
}

/// Installs the shipped rule book: temp file, verify, atomic rename.
///
/// **Only `rename` is durable; everything before it is disposable.** Of the
/// states a kill can leave behind, exactly one is a state a later launch can
/// misread — a truncated file at the live path. `File.rename` within one
/// directory is atomic on APFS and on ext4/f2fs, so that path holds either the
/// previous database or a fully verified new one, never a prefix of one.
///
/// Writing straight to the live path is the version anybody writes first, and it
/// leaves a file that **opens cleanly** and answers with wrong minimum lengths.
/// That is worse than no database at all, because the app still looks confident.
final class ReferenceInstaller {
  /// Installs [expected] from [bundle] into `directories.reference()`.
  ReferenceInstaller({
    required this.bundle,
    required this.directories,
    required this.marker,
    required this.expected,
    this.assetKey = kReferenceAssetKey,
  });

  /// The bundled `.gz`.
  final AssetBundleService bundle;

  /// Where the extracted file goes.
  final AppDirectories directories;

  /// Where completion is recorded.
  final MarkerStore marker;

  /// What the build says the payload is.
  final ReferenceBuild expected;

  /// The bundle key, `assets/db/reference.db.gz` by default.
  final String assetKey;

  /// The bundled asset D-6 ships.
  static const String kReferenceAssetKey = 'assets/db/reference.db.gz';

  /// The live file name.
  static const String kFileName = 'reference.db';

  /// Progress fires at most once per this many bytes.
  ///
  /// The reporting cadence is part of the budget, not decoration: a callback per
  /// chunk on a 41 MB payload is thousands of frames of work the extraction did
  /// not need to do.
  static const int kProgressStride = 64 * 1024;

  /// Extracts the rule book if it is not already installed.
  ///
  /// Reports progress against the **real** uncompressed byte count, so the bar
  /// cannot finish at 94 % or run past 100 %. `SPEC.md` §13 makes the
  /// determinate indicator part of the requirement: six indeterminate seconds on
  /// a dark boat reads as a hang, and a hang on first launch is the moment the
  /// app is deleted.
  Future<Result<File>> ensureInstalled({void Function(int done, int total)? onProgress}) async {
    final Directory dir;
    final File live;
    final File temp;
    try {
      dir = await directories.reference()
        ..createSync(recursive: true);
      live = File(p.join(dir.path, kFileName));
      temp = File('${live.path}.tmp');

      // 1. THE ORPHAN SWEEP, FIRST. A .tmp is evidence of a kill, so it is
      // deleted rather than resumed: a resumed gunzip has no way to know where
      // the compressed stream left off. An orphan nobody sweeps is forty
      // megabytes of dead storage on the fisher's phone.
      if (temp.existsSync()) temp.deleteSync();

      // 2. Already installed, and verified when it was.
      if (await marker.read() == expected.buildDate && live.existsSync()) {
        return Result<File>.ok(live);
      }
    } on FileSystemException catch (e, st) {
      return _io('sweep', e, st);
    }

    // 3. CLEAR THE MARKER BEFORE THE FIRST BYTE. The subtle one: if the marker
    // survived a failed extraction, a kill between the rename and the marker
    // write would be indistinguishable from success, and the app would trust a
    // file it never verified.
    try {
      await marker.clear();
    } on Exception catch (e, st) {
      return _io('marker', e, st);
    }

    // The ladder says retry ONCE. A single bad read is more likely than a bad
    // asset, and a retry loop on a genuinely corrupt payload is a boot loop.
    for (var attempt = 0; attempt < 2; attempt++) {
      final Result<File> result = await _extractOnce(live, temp, onProgress: onProgress);
      if (result is Ok<File>) return result;
      final bool corrupt = result is Failure<File> && result.exception is ReferencePayloadCorrupt;
      if (!corrupt || attempt == 1) return result;
    }
    // Unreachable: the loop returns on both arms of its last iteration.
    return const Result<File>.error(ReferenceInstallIoFailed(step: 'write'));
  }

  Future<Result<File>> _extractOnce(
    File live,
    File temp, {
    void Function(int done, int total)? onProgress,
  }) async {
    var written = 0;
    var reported = 0;
    IOSink? sink;
    final digest = AccumulatorSink<Digest>();
    final ByteConversionSink hasher = sha256.startChunkedConversion(digest);

    try {
      sink = temp.openWrite();
      final Stream<List<int>> stream = gzip.decoder.bind(bundle.openRead(assetKey));
      await for (final List<int> chunk in stream) {
        sink.add(chunk);
        hasher.add(chunk);
        written += chunk.length;
        if (written - reported >= kProgressStride) {
          reported = written;
          onProgress?.call(written, expected.bytes);
        }
      }
      await sink.flush();
      await sink.close();
      sink = null;
      hasher.close();
    } on FormatException catch (e, st) {
      // A corrupt gzip stream.
      await _discard(sink, temp);
      return _io('write', e, st);
    } on FileSystemException catch (e, st) {
      await _discard(sink, temp);
      // errno 28 is ENOSPC. The user can act on a number of megabytes.
      if (e.osError?.errorCode == 28) {
        _log('disk full extracting the rule book', e, st);
        return Result<File>.error(ReferenceNoSpace(neededBytes: expected.bytes));
      }
      return _io('write', e, st);
    } on FlutterError catch (e, st) {
      await _discard(sink, temp);
      _log('the rule book asset is not in the bundle', e, st);
      return Result<File>.error(ReferenceAssetMissing(assetKey: assetKey));
    }

    // 5 and 6. Length first — nearly free, and it catches the truncation class
    // before the hash is even computed.
    if (written != expected.bytes || '${digest.events.single}' != expected.sha256) {
      await _discard(null, temp);
      return Result<File>.error(
        ReferencePayloadCorrupt(
          expectedSha256: expected.sha256,
          expectedBytes: expected.bytes,
          actualBytes: written,
        ),
      );
    }

    try {
      // 7. THE ONE DURABLE STEP. `rename` within one directory is atomic on
      // APFS and on ext4/f2fs, so the live path holds either the previous
      // database or a fully verified new one — never a prefix of one.
      final File renamed = await temp.rename(live.path);
      // 8. And only then the marker: written first it is a claim about a file
      // that does not exist.
      await marker.write(expected.buildDate);
      onProgress?.call(expected.bytes, expected.bytes);
      return Result<File>.ok(renamed);
    } on FileSystemException catch (e, st) {
      await _discard(null, temp);
      return _io('rename', e, st);
    } on Exception catch (e, st) {
      return _io('marker', e, st);
    }
  }

  Future<void> _discard(IOSink? sink, File temp) async {
    try {
      await sink?.close();
    } on Exception {
      // The sink is already broken; the file is about to be deleted anyway.
    }
    if (temp.existsSync()) temp.deleteSync();
  }

  Result<File> _io(String step, Object error, StackTrace stackTrace) {
    _log('rule book extraction failed at $step', error, stackTrace);
    return Result<File>.error(ReferenceInstallIoFailed(step: step));
  }

  /// Logged **before** the typed failure is returned.
  ///
  /// For an app that cannot phone home, the local stack trace is the only
  /// diagnostic that will ever exist.
  void _log(String message, Object error, StackTrace stackTrace) {
    if (kDebugMode) debugPrint('ReferenceInstaller: $message\n$error\n$stackTrace');
  }
}
