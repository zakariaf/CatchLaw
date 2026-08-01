// The two artefacts the app's extraction gate needs, and the reason there are
// two of them.
//
// The generated Dart constant is what the gate compares: compiled into the
// binary, zero I/O, and structurally incapable of disagreeing with the payload
// that shipped alongside it. The JSON sidecar is what the installer reads for
// the determinate bar's denominator and what E18 reads for the counts. Neither
// should require opening ten megabytes of SQLite.

import 'dart:convert';
import 'dart:io';

import 'package:content_builder/src/cli/options.dart';
import 'package:content_builder/src/emit/content_build.dart';
import 'package:content_builder/src/emit/emit_reference_db.dart';
import 'package:content_builder/src/emit/schema.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

import 'emit_reference_db_test.dart' show build, kBuildDate;

void main() {
  group('emitContentBuild', () {
    test('writes a sidecar carrying the uncompressed byte count and sha256', () {
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      expect(emitReferenceDb(c.source, c.options), isEmpty);

      emitContentBuild(c.options);

      final json =
          jsonDecode(contentBuildJson(c.options).readAsStringSync()) as Map<String, Object?>;
      expect(json['bytes'], c.options.outFile.lengthSync());
      expect(json['sha256'], '${sha256.convert(c.options.outFile.readAsBytesSync())}');
      expect(json['build_date'], '2026-08-14');
      expect(json['schema_version'], int.parse(kSchemaVersion));
    });

    test('writes a Dart constant carrying the same four values', () {
      // A stale constant against a fresh payload is a bar that finishes at 94 %
      // and a review that reads it as "extraction is slow".
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      expect(emitReferenceDb(c.source, c.options), isEmpty);

      emitContentBuild(c.options);

      final String dart = contentBuildDart(c.options).readAsStringSync();
      expect(dart, contains("const String kContentBuildDate = '2026-08-14';"));
      expect(dart, contains('const int kContentBuildBytes = ${c.options.outFile.lengthSync()};'));
      expect(
        dart,
        contains(
          'const String kContentBuildSha256 = '
          "'${sha256.convert(c.options.outFile.readAsBytesSync())}';",
        ),
      );
    });

    test('marks the Dart file as generated', () {
      // A hand-edited constant is a claim about a payload nobody built.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      expect(emitReferenceDb(c.source, c.options), isEmpty);

      emitContentBuild(c.options);

      expect(contentBuildDart(c.options).readAsStringSync(), contains('DO NOT EDIT'));
    });

    test('derives both paths from the assets root', () {
      // One --out fixes every path this build writes, so two options cannot
      // disagree about which app they are building for.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));

      expect(contentBuildJson(c.options).path, '${c.options.assetsRoot.path}/content_build.json');
      expect(
        contentBuildDart(c.options).path,
        endsWith('lib/data/services/reference/content_build.constants.dart'),
      );
    });

    test('produces identical artefacts from two builds of one corpus', () {
      // The constants travel with the payload; if they moved on their own, the
      // gate would compare a value to a payload it did not describe.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      expect(emitReferenceDb(c.source, c.options), isEmpty);

      emitContentBuild(c.options);
      final String first = contentBuildDart(c.options).readAsStringSync();
      emitContentBuild(c.options);

      expect(contentBuildDart(c.options).readAsStringSync(), first);
    });

    test('names the build date it was given and never the clock', () {
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      expect(emitReferenceDb(c.source, c.options), isEmpty);

      emitContentBuild(c.options);

      expect(
        contentBuildJson(c.options).readAsStringSync(),
        contains(kBuildDate.toString().split(' ').first),
      );
    });

    test('creates the reference directory when the app has none yet', () {
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      expect(emitReferenceDb(c.source, c.options), isEmpty);

      expect(() => emitContentBuild(c.options), returnsNormally);
      expect(File(contentBuildDart(c.options).path).existsSync(), isTrue);
    });
  });
}
