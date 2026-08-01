// Extraction: temp file, verify, atomic rename.
//
// Only `rename` is durable; everything before it is disposable. Of the states a
// kill can leave behind, exactly one is a state a later launch can MISREAD — a
// truncated file at the live path. Writing straight there is the version
// anybody writes first, and it leaves a file that opens cleanly and answers
// with wrong minimum lengths, which is worse than no database at all because
// the app still looks confident.
//
// Every test runs against a real temp directory and a fake bundle carrying a
// real gzip of real bytes, so the sha256 and the byte count are genuine.

import 'dart:io';

import 'package:catchlaw/data/services/reference_install_failure.dart';
import 'package:catchlaw/data/services/reference_installer.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

import '../../testing/fakes/fake_asset_bundle_service.dart';
import '../../testing/fakes/fake_marker_store.dart';

/// A payload with enough bytes to cross the 64 KiB progress stride twice.
final List<int> kPayload = List<int>.generate(200 * 1024, (int i) => (i * 31) % 256);

/// A different payload of the SAME length, so a corrupt run is caught by the
/// digest rather than by the cheap length check.
final List<int> kOtherPayload = List<int>.generate(200 * 1024, (int i) => (i * 17) % 256);

final List<int> kPayloadGz = gzip.encode(kPayload);
final List<int> kOtherGz = gzip.encode(kOtherPayload);
final String kPayloadSha256 = '${sha256.convert(kPayload)}';

const String kBuildDate = '2026-08-14';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('catchlaw_ref_install_'));
  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  File live() => File('${dir.path}/reference.db');
  File temp() => File('${dir.path}/reference.db.tmp');

  ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker}) build({
    AssetEnv env = AssetEnv.healthy,
    FakeMarkerStore? marker,
    String? sha,
    int? bytes,
  }) {
    final bundle = FakeAssetBundleService(env, payload: kPayloadGz, corruptPayload: kOtherGz);
    final FakeMarkerStore store = marker ?? FakeMarkerStore();
    return (
      installer: ReferenceInstaller(
        bundle: bundle,
        directories: FixedDirectories(dir),
        marker: store,
        expected: ReferenceBuild(
          buildDate: kBuildDate,
          bytes: bytes ?? kPayload.length,
          sha256: sha ?? kPayloadSha256,
        ),
      ),
      bundle: bundle,
      marker: store,
    );
  }

  test('ReferenceInstaller.ensureInstalled extracts the payload on a first launch', () async {
    final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
    c = build();

    final Result<File> result = await c.installer.ensureInstalled();

    expect(result, isA<Ok<File>>());
    expect(live().existsSync(), isTrue);
    expect('${sha256.convert(live().readAsBytesSync())}', kPayloadSha256);
  });

  test('ReferenceInstaller.ensureInstalled deletes an orphan .tmp before extracting', () async {
    // §14's force-quit case: the residue of a kill is swept, never resumed. A
    // resumed gunzip has no way to know where the compressed stream left off.
    temp().writeAsBytesSync(<int>[1, 2, 3]);
    final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
    c = build();

    expect(await c.installer.ensureInstalled(), isA<Ok<File>>());
    expect(temp().existsSync(), isFalse);
  });

  test('ReferenceInstaller.ensureInstalled leaves no openable database when the stream '
      'dies mid-extraction', () async {
    // The §14 sentence, verbatim: no corrupt database is left behind.
    final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
    c = build(env: AssetEnv.diesMidStream);

    final Result<File> result = await c.installer.ensureInstalled();

    expect(result, isA<Failure<File>>());
    expect(live().existsSync(), isFalse);
    expect(temp().existsSync(), isFalse);
    // ReferencePayloadCorrupt, not ReferenceInstallIoFailed as the task file
    // predicted, and the difference is a fact about Dart rather than a choice:
    // a gzip stream that simply ENDS early does not throw — the decoder emits
    // what it has and completes. The truncation is caught by the byte count,
    // which is the cheaper check anyway, and the failure then carries
    // actualBytes where an I/O failure would have carried only a step name.
    // The retry-once ladder also applies, which is exactly right: a short read
    // is the "single bad read" the ladder exists for.
    final failure = (result as Failure<File>).exception as ReferencePayloadCorrupt;
    expect(failure.actualBytes, lessThan(failure.expectedBytes));
  });

  test('ReferenceInstaller.ensureInstalled succeeds on the launch after a stream that '
      'died mid-extraction', () async {
    // "Extraction restarts cleanly" — the other half of §14, and the half that
    // is usually skipped.
    final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
    c = build(env: AssetEnv.diesMidStream);
    await c.installer.ensureInstalled();

    c.bundle.env = AssetEnv.healthy;
    expect(await c.installer.ensureInstalled(), isA<Ok<File>>());
    expect('${sha256.convert(live().readAsBytesSync())}', kPayloadSha256);
  });

  test('ReferenceInstaller.ensureInstalled keeps the previous database when a '
      're-extraction dies mid-stream', () async {
    // The failure ladder: a failed update never degrades the installed pack.
    final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
    c = build();
    await c.installer.ensureInstalled();
    final List<int> installed = live().readAsBytesSync();

    c.bundle.env = AssetEnv.diesMidStream;
    c.marker.installed = 'a-different-build';
    await c.installer.ensureInstalled();

    expect(live().existsSync(), isTrue);
    expect(live().readAsBytesSync(), installed);
  });

  test(
    'ReferenceInstaller.ensureInstalled clears the marker before writing the first byte',
    () async {
      // Step 3 before step 4. If the marker survived a failed extraction, a kill
      // between the rename and the marker write would be indistinguishable from
      // success, and the app would trust a file it never verified.
      final marker = FakeMarkerStore('an-older-build');
      final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
      c = build(env: AssetEnv.diesMidStream, marker: marker);

      await c.installer.ensureInstalled();

      expect(marker.installed, isNull);
      expect(marker.calls, contains('clear'));
    },
  );

  test('ReferenceInstaller.ensureInstalled writes the marker only after the rename', () async {
    // Step 8 after step 7. A marker written first is a claim about a file that
    // does not exist.
    final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
    c = build();

    await c.installer.ensureInstalled();

    expect(c.marker.calls.last, 'write:$kBuildDate');
    expect(live().existsSync(), isTrue);
  });

  test('ReferenceInstaller.ensureInstalled returns ReferencePayloadCorrupt when the '
      'sha256 disagrees', () async {
    // The check that makes the rename safe to trust.
    final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
    c = build(env: AssetEnv.corrupt);

    final Result<File> result = await c.installer.ensureInstalled();

    expect((result as Failure<File>).exception, isA<ReferencePayloadCorrupt>());
    expect(live().existsSync(), isFalse);
    expect(temp().existsSync(), isFalse);
  });

  test('ReferenceInstaller.ensureInstalled returns ReferencePayloadCorrupt when the '
      'byte count disagrees', () async {
    // Truncation is caught by length before the hash is even computed.
    final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
    c = build(bytes: kPayload.length + 1);

    final Result<File> result = await c.installer.ensureInstalled();

    final failure = (result as Failure<File>).exception as ReferencePayloadCorrupt;
    expect(failure.actualBytes, kPayload.length);
    expect(failure.expectedBytes, kPayload.length + 1);
  });

  test(
    'ReferenceInstaller.ensureInstalled retries once before reporting a corrupt payload',
    () async {
      // The ladder says retry ONCE. A single bad read is more likely than a bad
      // asset, and a retry loop on a genuinely bad asset is a boot loop.
      final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
      c = build(env: AssetEnv.corrupt);

      await c.installer.ensureInstalled();

      expect(c.bundle.opens, 2);
    },
  );

  test('ReferenceInstaller.ensureInstalled returns ReferenceAssetMissing when the asset '
      'is absent', () async {
    // Names the key, so a mis-typed pubspec.yaml entry is one line to diagnose.
    final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
    c = build(env: AssetEnv.missing);

    final Result<File> result = await c.installer.ensureInstalled();

    final failure = (result as Failure<File>).exception as ReferenceInstallFailure;
    expect(failure, isA<ReferenceAssetMissing>());
    expect((failure as ReferenceAssetMissing).assetKey, ReferenceInstaller.kReferenceAssetKey);
  });

  test(
    'ReferenceInstaller.ensureInstalled reports progress against the payload byte count',
    () async {
      // A denominator that is a guess is a bar that finishes at 94 %, which reads
      // as "extraction is slow" on a dark boat.
      final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
      c = build();
      final calls = <({int done, int total})>[];

      await c.installer.ensureInstalled(
        onProgress: (int done, int total) => calls.add((done: done, total: total)),
      );

      expect(calls, isNotEmpty);
      expect(calls.map((({int done, int total}) c) => c.total).toSet(), <int>{kPayload.length});
      expect(calls.last.done, kPayload.length);
    },
  );

  test('ReferenceInstaller.ensureInstalled reports progress at most once per 64 KiB', () async {
    // The reporting cadence is part of the budget, not decoration.
    final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
    c = build();
    var calls = 0;

    await c.installer.ensureInstalled(onProgress: (int done, int total) => calls++);

    expect(
      calls,
      lessThanOrEqualTo((kPayload.length / ReferenceInstaller.kProgressStride).ceil() + 1),
    );
  });

  test(
    'ReferenceInstaller.ensureInstalled creates the reference directory when it is absent',
    () async {
      // The genuine first launch: nothing under application support exists yet.
      dir.deleteSync(recursive: true);
      final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
      c = build();

      expect(await c.installer.ensureInstalled(), isA<Ok<File>>());
    },
  );

  test('ReferenceInstaller.ensureInstalled leaves no .tmp behind on a successful run', () async {
    // An orphan nobody sweeps is forty megabytes of dead storage on the
    // fisher's phone.
    final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
    c = build();

    await c.installer.ensureInstalled();

    expect(dir.listSync().map((FileSystemEntity e) => e.uri.pathSegments.last).toList(), <String>[
      'reference.db',
    ]);
  });

  test('ReferenceInstaller.ensureInstalled skips the work when the marker already names '
      'this build', () async {
    // The second launch, and the reason the marker exists at all: re-extracting
    // forty megabytes on every start is six seconds the fisher did not agree to.
    final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
    c = build();
    await c.installer.ensureInstalled();
    final int opensAfterFirst = c.bundle.opens;

    expect(await c.installer.ensureInstalled(), isA<Ok<File>>());
    expect(c.bundle.opens, opensAfterFirst);
  });

  test('ReferenceInstaller.ensureInstalled re-extracts when the marker names a different '
      'build', () async {
    final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
    c = build(marker: FakeMarkerStore('an-older-build'));

    expect(await c.installer.ensureInstalled(), isA<Ok<File>>());
    expect(c.marker.installed, kBuildDate);
  });

  for (final AssetEnv env in AssetEnv.detectable) {
    test('every AssetEnv either installs a verified database or returns a typed failure '
        '(AssetEnv.${env.name})', () async {
      // The absence-of-a-failure-class test. Silent loss here is a confident
      // wrong answer, which is the one outcome this product cannot ship.
      final ({ReferenceInstaller installer, FakeAssetBundleService bundle, FakeMarkerStore marker})
      c = build(env: env);

      final Result<File> result = await c.installer.ensureInstalled();

      switch (result) {
        case Ok<File>():
          expect('${sha256.convert(result.value.readAsBytesSync())}', kPayloadSha256);
        case Failure<File>():
          expect(result.exception, isA<ReferenceInstallFailure>());
          expect(live().existsSync(), isFalse, reason: 'no half-installed rule book');
      }
    });
  }
}
