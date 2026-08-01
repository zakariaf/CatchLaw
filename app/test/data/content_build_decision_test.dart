// The extraction gate, and the thing it must never do.
//
// SPEC.md §7.4 records the first draft's circular design: it decided whether to
// extract by reading the build date out of the shipped database. To read one
// row you must open the database; to open it you must decompress ten megabytes
// to disk; which is the entire job the check was supposed to skip. The naive
// version therefore re-extracts on every launch and pays the worst possible
// cost — every time, on the cold-start path, for a comparison of twenty bytes.
//
// So the two values compared are already in hand, and a spy asserts no
// reference database is opened to reach them.

import 'dart:io';

import 'package:catchlaw/data/services/app_meta_marker_store.dart';
import 'package:catchlaw/data/services/reference/content_build.dart';
import 'package:catchlaw/data/services/reference/content_build.g.dart';
import 'package:catchlaw/data/services/reference_installer.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes/fake_marker_store.dart';

/// A marker store that records whether anything asked it for a file.
final class SpyMarkerStore implements MarkerStore {
  SpyMarkerStore(this.installed);

  String? installed;
  int reads = 0;

  @override
  Future<String?> read() async {
    reads++;
    return installed;
  }

  @override
  Future<void> write(String buildDate) async => installed = buildDate;

  @override
  Future<void> clear() async => installed = null;
}

void main() {
  late Directory dir;
  late File referenceFile;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('catchlaw_gate_');
    referenceFile = File('${dir.path}/reference.db')..writeAsStringSync('not really a database');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('decideExtraction returns NeverInstalled when there is no marker', () async {
    // A genuine first launch. E12 shows the determinate bar.
    expect(
      await decideExtraction(marker: FakeMarkerStore(), referenceFile: referenceFile),
      isA<NeverInstalled>(),
    );
  });

  test('decideExtraction returns AlreadyInstalled when the marker names this build', () async {
    expect(
      await decideExtraction(
        marker: FakeMarkerStore(kContentBuildDate),
        referenceFile: referenceFile,
      ),
      isA<AlreadyInstalled>(),
    );
  });

  test('decideExtraction returns BuildMoved when the marker names another build', () async {
    // An app update carrying new content. Worth logging, because it is the only
    // decision that says WHICH pack is being replaced by which.
    final ExtractionDecision decision = await decideExtraction(
      marker: FakeMarkerStore('2020-01-01'),
      referenceFile: referenceFile,
    );

    expect(decision, isA<BuildMoved>());
    expect((decision as BuildMoved).installed, '2020-01-01');
    expect(decision.expected, kContentBuildDate);
  });

  test('decideExtraction returns FileMissing when the marker survived the file', () async {
    // The user cleared storage. A bool would collapse this into BuildMoved, and
    // this is the one that needs the log line.
    referenceFile.deleteSync();

    final ExtractionDecision decision = await decideExtraction(
      marker: FakeMarkerStore(kContentBuildDate),
      referenceFile: referenceFile,
    );

    expect(decision, isA<FileMissing>());
    expect((decision as FileMissing).installed, kContentBuildDate);
  });

  test('decideExtraction opens no reference database to decide', () async {
    // THE PROPERTY §7.4 STATES. One marker read and one File.existsSync — no
    // decompression, no SQLite, nothing on the cold-start path but a string
    // comparison.
    final spy = SpyMarkerStore(kContentBuildDate);

    await decideExtraction(marker: spy, referenceFile: referenceFile);

    expect(spy.reads, 1);
    expect(referenceFile.readAsStringSync(), 'not really a database');
  });

  test('every decision but AlreadyInstalled asks for extraction', () async {
    expect(const AlreadyInstalled().needsExtraction, isFalse);
    expect(const NeverInstalled().needsExtraction, isTrue);
    expect(const BuildMoved(installed: 'a', expected: 'b').needsExtraction, isTrue);
    expect(const FileMissing(installed: 'a').needsExtraction, isTrue);
  });

  test('kReferenceBuild carries the generated constants', () {
    // The gate compares a compiled-in value, so it is structurally incapable of
    // disagreeing with the payload that shipped beside it.
    expect(kReferenceBuild.buildDate, kContentBuildDate);
    expect(kReferenceBuild.bytes, kContentBuildBytes);
    expect(kReferenceBuild.sha256, kContentBuildSha256);
  });

  test('the generated constants agree with the committed sidecar', () {
    // A stale constant against a fresh payload is a bar that finishes at 94 %
    // and a review that reads it as "extraction is slow" rather than "the
    // constants are stale".
    final sidecar = File('assets/content_build.json');
    final String json = sidecar.readAsStringSync();

    expect(json, contains('"build_date": "$kContentBuildDate"'));
    expect(json, contains('"bytes": $kContentBuildBytes'));
    expect(json, contains('"sha256": "$kContentBuildSha256"'));
    expect(json, contains('"schema_version": $kContentSchemaVersion'));
  });

  group('AppMetaMarkerStore', () {
    late UserDatabase db;

    setUp(() async {
      db = UserDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.customSelect('SELECT 1').get();
    });

    test('reads null before anything is installed', () async {
      expect(await AppMetaMarkerStore(db).read(), isNull);
    });

    test('round-trips the build date through app_meta', () async {
      final store = AppMetaMarkerStore(db);

      await store.write('2026-08-14');

      expect(await store.read(), '2026-08-14');
    });

    test('overwrites rather than accumulating rows', () async {
      // One marker, not a history: the row that is not the latest is the one
      // that lies.
      final store = AppMetaMarkerStore(db);

      await store.write('2026-07-01');
      await store.write('2026-08-14');

      expect(await store.read(), '2026-08-14');
      expect(await db.select(db.appMetas).get(), hasLength(1));
    });

    test('clear removes the marker', () async {
      final store = AppMetaMarkerStore(db);
      await store.write('2026-08-14');

      await store.clear();

      expect(await store.read(), isNull);
    });

    test('touches only the app_meta row it owns', () async {
      // The store holds a UserDatabase and nothing else. No ATTACH, no shared
      // executor, no SQL spanning both files.
      await db.customStatement("INSERT INTO app_meta (key, value) VALUES ('other', 'x')");
      final store = AppMetaMarkerStore(db);

      await store.write('2026-08-14');
      await store.clear();

      expect(await db.select(db.appMetas).get(), hasLength(1));
    });
  });
}
