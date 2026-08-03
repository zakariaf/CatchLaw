// The composition, not the parts.
//
// `ReferenceInstaller` was built, tested and correct for ten epics, and nothing
// called it: `dataOverrides` handed the reference database an executor that
// opened `<support>/reference.db` directly, a path that exists only AFTER
// extraction. On every clean install the first query was `SqliteException(14)`
// and the app was unusable — on a phone it had never run on, which is every
// phone.
//
// 1459 tests were blind to it for one reason worth naming: every suite that
// reads the pack builds its own executor, because that is the seam a test
// exists to replace. The one path that composes the installer WITH the database
// is the production one, and it had no test at all. This file is that test.
//
// It runs against the real shipped `reference.db.gz`, so the sha256 and the
// byte count that `ReferenceInstaller` verifies are the ones `kReferenceBuild`
// actually carries — a synthetic payload could not clear that check, and
// weakening the check to accept one would delete the assertion.

import 'dart:io';

import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/services/app_directories.dart';
import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes/fake_asset_bundle_service.dart';

/// The gz that ships, read from the repository rather than synthesised.
File get _shippedGz => File('assets/db/reference.db.gz');

/// Both databases under one throwaway directory.
final class _TempDirectories implements AppDirectories {
  _TempDirectories(this.dir);

  final Directory dir;

  @override
  Future<Directory> reference() async => dir;

  @override
  Future<Directory> user() async => dir;
}

void main() {
  if (!_shippedGz.existsSync()) {
    test('the shipped reference.db.gz is present', () {
      markTestSkipped('run `dart run content_builder:build` first');
    }, skip: true);
    return;
  }

  late Directory dir;
  late FakeAssetBundleService bundle;
  late ProviderContainer container;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('catchlaw_bootstrap_');
    bundle = FakeAssetBundleService(AssetEnv.healthy, payload: _shippedGz.readAsBytesSync());
    container = ProviderContainer(
      overrides: dataOverrides(directories: _TempDirectories(dir), bundle: bundle),
    );
    addTearDown(() {
      container.dispose();
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });
  });

  /// One real query through the composed stack — which is what forces the
  /// `LazyDatabase` callback, and therefore the extraction, to run.
  Future<List<QueryRow>> firstQuery() =>
      container.read(referenceDatabaseProvider).customSelect('SELECT id FROM rule').get();

  test('dataOverrides extracts the reference pack before the first query', () async {
    expect(
      File('${dir.path}/reference.db').existsSync(),
      isFalse,
      reason: 'a clean install has no extracted pack, which is the state that broke',
    );

    expect(await firstQuery(), isNotEmpty);

    expect(File('${dir.path}/reference.db').existsSync(), isTrue);
    expect(bundle.opens, 1);
  });

  test('dataOverrides awaits nothing before the first query', () {
    // The whole reason extraction lives in the LazyDatabase callback: main.dart
    // is not async, and ~6 s of decompression before runApp is a black screen
    // on a dark boat (`catchlaw-conventions-index` rule 8).
    dataOverrides(directories: _TempDirectories(dir), bundle: bundle);

    expect(bundle.opens, 0, reason: 'building the overrides must touch no asset');
    expect(File('${dir.path}/reference.db').existsSync(), isFalse);
  });

  test('dataOverrides reads no asset when the pack is already installed', () async {
    await firstQuery();
    expect(bundle.opens, 1);

    // A second container over the SAME directory: the marker written to user.db
    // is what makes a warm launch skip ~10 MB of decompression.
    final warm = FakeAssetBundleService(AssetEnv.healthy, payload: _shippedGz.readAsBytesSync());
    final second = ProviderContainer(
      overrides: dataOverrides(directories: _TempDirectories(dir), bundle: warm),
    );
    addTearDown(second.dispose);

    expect(
      await second.read(referenceDatabaseProvider).customSelect('SELECT id FROM rule').get(),
      isNotEmpty,
    );
    expect(warm.opens, 0, reason: 'the marker matches, so extraction is skipped entirely');
  });

  // NOT tested here: that a failed extraction surfaces the installer's own
  // failure rather than a SQLite errno. It does — `_installedReference` throws
  // `ReferenceInstallFailure` and never falls through to the un-extracted path,
  // which is the whole fix — but `LazyDatabase` retains the rejected open future
  // and the test harness reports it as an unhandled async error whatever the
  // caller catches. That is drift's behaviour, not ours, and a test that fails
  // for a reason outside the app is worse than no test. The property is asserted
  // directly, one layer down, in `reference_installer_test.dart`.

  test('dataOverrides opens the user database in the same directory', () async {
    await container.read(userDatabaseProvider).customSelect('SELECT 1').get();

    expect(File('${dir.path}/user.db').existsSync(), isTrue);
  });
}
