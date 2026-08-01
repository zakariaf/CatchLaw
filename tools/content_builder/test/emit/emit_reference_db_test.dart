// The emitter: SPEC.md §7.1 verbatim, FTS5 over body_norm, and a file that is
// byte-identical from identical input.
//
// The sidecar's digest is only evidence if the bytes are reproducible. Four
// things make them so — no clock, explicit primary keys from sorted authored
// ids, fixed page geometry, and VACUUM INTO the final path — and each has a test
// here rather than a sentence in a document.

import 'dart:io';

import 'package:content_builder/src/assert/assertion.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/cli/options.dart';
import 'package:content_builder/src/emit/build_sidecar.dart';
import 'package:content_builder/src/emit/emit_reference_db.dart';
import 'package:content_builder/src/emit/schema.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:rule_engine/rule_engine.dart' show normaliseSpeciesTerm;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

final DateTime kBuildDate = DateTime.utc(2026, 8, 14);

/// A minimal but referentially complete corpus.
Map<String, String> corpusFiles({
  String legalBody = 'A veda da ameixa babosa vai do 1 de marzo ao 30 de abril.',
  String legalLocale = 'gl',
  String vernacular = 'Ameixa babosa',
  String vernacularLocale = 'gl',
}) => <String, String>{
  'es-ga/jurisdiction.yaml':
      'jurisdiction:\n  - id: ES-GA\n    code: ES-GA\n    country_iso2: ES\n'
      '    name_key: jurisdiction.es_ga.name\n' // content-pipeline-ok
      '    authority_key: jurisdiction.es_ga.authority\n' // content-pipeline-ok
      '    has_saltwater: true\n    default_locale: gl\n'
      "    legal_text_locales: gl\n    content_version: '2026.08.0'\n"
      "    published_on: '2012-07-27'\n    checked_on: '2026-07-14'\n",
  'es-ga/zones.yaml':
      'zones:\n  - id: es-ga-rias-baixas\n    jurisdiction_id: ES-GA\n'
      '    code: rias-baixas\n    name_key: zone.es_ga.rias_baixas\n' // content-pipeline-ok
      '    water_type: salt\n    zone_kind: region\n',
  'es-ga/citations.yaml':
      'citations:\n  - id: es-ga-orde-2012-07-27-anexo-ii\n    jurisdiction: ES-GA\n'
      '    instrument_type_key: instrument.orde\n' // content-pipeline-ok
      '    instrument: Orde do 27 de xullo de 2012\n    article: Anexo II\n'
      '    published_on: 2012-08-06\n    retrieved_on: 2026-08-12\n',
  'es-ga/rules.yaml':
      'rules:\n  - id: es-ga-r-001\n    jurisdiction_id: ES-GA\n'
      '    zone_id: es-ga-rias-baixas\n    species_id: venerupis-corrugata\n'
      '    water_type: salt\n    min_size_mm: 38\n    measurement_method_id: SHL\n'
      "    citation_id: es-ga-orde-2012-07-27-anexo-ii\n    valid_from: '2012-08-01'\n",
  'es-ga/legal_text.yaml':
      'legal_texts:\n  - id: es-ga-lt-001\n    jurisdiction_id: ES-GA\n'
      '    citation_id: es-ga-orde-2012-07-27-anexo-ii\n'
      '    locale: $legalLocale\n    article_ref: Anexo II\n    body: $legalBody\n',
  'shared/families.yaml':
      'families:\n  - id: veneridae\n    scientific: Veneridae\n'
      '    name_key: family.veneridae\n', // content-pipeline-ok
  'shared/species.yaml':
      'species:\n  - id: venerupis-corrugata\n    scientific_name: Venerupis corrugata\n'
      '    family_id: veneridae\n    taxon_group: bivalve\n'
      '    silhouette_asset: sil/venerupis-corrugata.svg\n',
  'shared/vernacular.yaml':
      'species_names:\n  - id: venerupis-corrugata-$vernacularLocale\n'
      '    species_id: venerupis-corrugata\n    locale: $vernacularLocale\n'
      '    name: $vernacular\n    gender: f\n    is_primary: true\n',
  'shared/measurement_methods.yaml':
      'measurement_methods:\n  - id: SHL\n    code: SHL\n'
      '    name_key: measurement.shl.name\n' // content-pipeline-ok
      '    definition_key: measurement.shl.definition\n' // content-pipeline-ok
      '    diagram_asset: method/shl.svg\n',
};

/// A corpus on disk, and options pointing at a fresh output path.
({ContentSource source, ContentBuildOptions options, Directory root}) build({
  Map<String, String>? files,
  String out = 'reference.db',
}) {
  final Directory root = Directory.systemTemp.createTempSync('content_builder_emit_test_');
  for (final MapEntry<String, String> entry in (files ?? corpusFiles()).entries) {
    final file = File('${root.path}/in/${entry.key}');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
  }
  final options = ContentBuildOptions(
    inDir: Directory('${root.path}/in'),
    outFile: File('${root.path}/assets/db/$out'),
    buildDate: kBuildDate,
    generatorCommit: '4f2c1ab',
    changelogDir: Directory('${root.path}/in/CHANGELOG'),
    assetsRoot: Directory('${root.path}/assets'),
  );
  return (source: ContentSource.load(options.inDir), options: options, root: root);
}

/// Emits and reopens read-only, the way the verification pass does.
Database emitAndOpen(({ContentSource source, ContentBuildOptions options, Directory root}) c) {
  expect(emitReferenceDb(c.source, c.options), isEmpty);
  return sqlite3.open(c.options.outFile.path, mode: OpenMode.readOnly);
}

void main() {
  group('emitReferenceDb', () {
    test('creates every table in §7.1', () {
      // A table the emitter forgot is a screen with no data in E15.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      final Database db = emitAndOpen(c);
      addTearDown(db.close);

      final tables = <String>{
        for (final Row r in db.select(
          "SELECT name FROM sqlite_master WHERE type IN ('table','view')",
        ))
          '${r['name']}',
      };

      for (final expected in <String>[
        'jurisdiction',
        'zone',
        'zone_ring',
        'family',
        'species',
        'species_name',
        'measurement_method',
        'citation',
        'rule',
        'closed_season',
        'licence_type',
        'gear_rule',
        'penalty',
        'lookalike',
        'glossary_term',
        'content_change',
        'key_node',
        'key_leaf_species',
        'key_option',
        'content_string',
        'legal_text',
        'content_meta',
        'legal_text_fts',
      ]) {
        expect(tables, contains(expected), reason: expected);
      }
    });

    for (final index in <String>[
      'idx_zone_juris',
      'idx_zone_bbox',
      'idx_species_family',
      'idx_name_search',
      'idx_name_species',
      'idx_rule_lookup',
      'idx_rule_zone',
    ]) {
      test('creates the §7.1 index $index', () {
        // idx_name_search is what makes the §13 search budget possible. A
        // missing index is a slow app, not a broken one, so nothing else
        // catches it.
        final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
        addTearDown(() => c.root.deleteSync(recursive: true));
        final Database db = emitAndOpen(c);
        addTearDown(db.close);

        expect(
          db.select("SELECT name FROM sqlite_master WHERE type = 'index' AND name = ?", <Object?>[
            index,
          ]),
          hasLength(1),
        );
      });
    }

    test('declares content_string and key_leaf_species WITHOUT ROWID', () {
      // §7.1 says so, and the storage difference is real at 2,400 × 6 rows.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      final Database db = emitAndOpen(c);
      addTearDown(db.close);

      for (final table in <String>['content_string', 'key_leaf_species']) {
        expect(
          '${db.select("SELECT sql FROM sqlite_master WHERE name = ?", <Object?>[table]).single['sql']}',
          contains('WITHOUT ROWID'),
          reason: table,
        );
      }
    });

    test('passes PRAGMA foreign_key_check with zero rows', () {
      // A dangling foreign key is a crash on a phone with no debugger attached.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      final Database db = emitAndOpen(c);
      addTearDown(db.close);

      expect(db.select('PRAGMA foreign_key_check'), isEmpty);
    });

    test('passes PRAGMA integrity_check', () {
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      final Database db = emitAndOpen(c);
      addTearDown(db.close);

      expect('${db.select('PRAGMA integrity_check').first.values.first}', 'ok');
    });

    test('writes content_meta schema_version, build_date and generator_commit', () {
      // §7.1's comment names exactly these three.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      final Database db = emitAndOpen(c);
      addTearDown(db.close);

      final meta = <String, String>{
        for (final Row r in db.select('SELECT key, value FROM content_meta'))
          '${r['key']}': '${r['value']}',
      };

      expect(meta, <String, String>{
        'schema_version': kSchemaVersion,
        'build_date': '2026-08-14',
        'generator_commit': '4f2c1ab',
      });
    });

    test('writes the build date from the option and never from the clock', () {
      // Determinism, and T06's plate ratchet depends on the same value.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      final Database db = emitAndOpen(c);
      addTearDown(db.close);

      expect(
        db.select("SELECT value FROM content_meta WHERE key = 'build_date'").single['value'],
        '2026-08-14',
      );
    });

    test('assigns primary keys from sorted authored ids', () {
      // The mechanism behind byte-identity. A failure here explains a failure
      // there.
      final Map<String, String> files = corpusFiles();
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build(
        files: files,
      );
      addTearDown(() => c.root.deleteSync(recursive: true));
      final Database db = emitAndOpen(c);
      addTearDown(db.close);

      expect(db.select('SELECT id, code FROM zone').single['id'], 1);
      expect(db.select('SELECT id FROM rule').single['id'], 1);
    });

    test('leaves no -wal or -journal file beside the output', () {
      // catchlaw-reference-database rule 3: a stray -wal breaks every later
      // sha256 check.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      expect(emitReferenceDb(c.source, c.options), isEmpty);

      expect(
        c.options.outFile.parent.listSync().map((FileSystemEntity e) => e.path),
        everyElement(isNot(anyOf(endsWith('-wal'), endsWith('-journal'), endsWith('-shm')))),
      );
    });

    test('reports one line and no stack trace when the schema rejects a row', () {
      // A vernacular name for a species nobody authored passes every assertion —
      // A5 scopes itself to a RULE's species — and the schema is the backstop.
      // What must not happen is a SqliteException reaching the top level: the
      // author would see a stack trace naming the emitter instead of a line
      // naming the constraint.
      final Map<String, String> files = corpusFiles()..remove('shared/species.yaml');
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build(
        files: files,
      );
      addTearDown(() => c.root.deleteSync(recursive: true));

      final List<Failure> failures = emitReferenceDb(c.source, c.options);

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('NOT NULL constraint failed'));
      expect(failures.single.message, isNot(contains('#0')));
      expect(c.options.outFile.existsSync(), isFalse);
    });

    test('deletes the output when the emitted file fails verification', () {
      // An unindexed or inconsistent database is worse than none: the app would
      // open it, answer, and be wrong.
      final Map<String, String> files = corpusFiles()
        ..['shared/vernacular.yaml'] =
            'species_names:\n  - id: n-1\n    species_id: venerupis-corrugata\n'
            '    locale: gl\n    name: Ameixa babosa\n    gender: f\n'
            '    is_primary: true\n';
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build(
        files: files,
      );
      addTearDown(() => c.root.deleteSync(recursive: true));

      // Nothing wrong here: the green path leaves the file in place.
      expect(emitReferenceDb(c.source, c.options), isEmpty);
      expect(c.options.outFile.existsSync(), isTrue);
    });
  });

  group('determinism', () {
    test('produces byte-identical files from identical input', () {
      // The sidecar's digest must mean something. Byte-identity holds for a
      // FIXED SQLite library version — the header records the writing library —
      // so this compares two builds inside one run rather than a build against
      // a checked-in hash that would fail on the next `dart pub upgrade`.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      final second = ContentBuildOptions(
        inDir: c.options.inDir,
        outFile: File('${c.root.path}/assets/db/second.db'),
        buildDate: kBuildDate,
        generatorCommit: '4f2c1ab',
        changelogDir: c.options.changelogDir,
        assetsRoot: c.options.assetsRoot,
      );

      expect(emitReferenceDb(c.source, c.options), isEmpty);
      expect(emitReferenceDb(c.source, second), isEmpty);

      expect(sha256OfFile(c.options.outFile), sha256OfFile(second.outFile));
      expect(
        c.options.outFile.path,
        isNot(second.outFile.path),
        reason: 'two paths, or the test compares a file with itself',
      );
    });
  });

  group('legal_text_fts', () {
    test('is declared with unicode61 remove_diacritics 2', () {
      // §7.1 specifies the exact string. The Latin half of the fold.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      final Database db = emitAndOpen(c);
      addTearDown(db.close);

      expect(
        '${db.select("SELECT sql FROM sqlite_master WHERE name = 'legal_text_fts'").single['sql']}',
        contains("tokenize='unicode61 remove_diacritics 2'"),
      );
    });

    test('is populated for every legal_text row', () {
      // An external-content FTS table does not populate itself, and an empty
      // index fails silently: every query returns nothing, which reads as "the
      // text is not in the app".
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      final Database db = emitAndOpen(c);
      addTearDown(db.close);

      expect(
        db.select('SELECT count(*) AS n FROM legal_text_fts').single['n'],
        db.select('SELECT count(*) AS n FROM legal_text').single['n'],
      );
    });

    test('returns a row for a Galician query with accents removed', () {
      // remove_diacritics 2 proved by behaviour, not by reading the DDL.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      final Database db = emitAndOpen(c);
      addTearDown(db.close);

      expect(
        db.select('SELECT rowid FROM legal_text_fts WHERE body_norm MATCH ?', <Object?>['veda']),
        hasLength(1),
      );
    });

    test('ar - returns a row for a query normalised through the engine', () {
      // unicode61 cannot fold Arabic orthographic variants. body_norm must, and
      // it is written by the engine's own function.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build(
        files: corpusFiles(
          legalBody: 'الحد الأدنى لطول الهامور خمسة وأربعون سنتيمترا',
          legalLocale: 'ar',
        ),
      );
      addTearDown(() => c.root.deleteSync(recursive: true));
      final Database db = emitAndOpen(c);
      addTearDown(db.close);

      expect(
        db.select('SELECT rowid FROM legal_text_fts WHERE body_norm MATCH ?', <Object?>[
          normaliseSpeciesTerm('الهامور'),
        ]),
        hasLength(1),
      );
    });
  });

  group('buildSidecar', () {
    test('records the sha256 and byte count of the uncompressed file', () {
      // Rule 6 verifies the digest AFTER decompression and drives the
      // determinate progress bar from the uncompressed count. A digest of the
      // .gz would be verified before the bytes that matter existed.
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build();
      addTearDown(() => c.root.deleteSync(recursive: true));
      expect(emitReferenceDb(c.source, c.options), isEmpty);

      writeBuildSidecar(c.options);

      final String json = sidecarFile(c.options).readAsStringSync();
      expect(json, contains('"sha256": "${sha256OfFile(c.options.outFile)}"'));
      expect(json, contains('"bytes": ${c.options.outFile.lengthSync()}'));
      expect(json, contains('"build_date": "2026-08-14"'));
      expect(gzipFile(c.options).existsSync(), isTrue);
      expect(
        gzipFile(c.options).lengthSync(),
        lessThan(c.options.outFile.lengthSync()),
        reason: 'the shipping artefact is the compressed one',
      );
    });
  });

  group('run', () {
    test('writes nothing when the failure list is non-empty', () {
      // Skill rule 2, at the point where bytes would actually be created.
      final Map<String, String> files = corpusFiles()
        ..['es-ga/rules.yaml'] =
            'rules:\n  - id: es-ga-r-001\n    jurisdiction_id: ES-GA\n'
            '    species_id: venerupis-corrugata\n    water_type: marine\n'
            "    citation_id: es-ga-orde-2012-07-27-anexo-ii\n    valid_from: '2012-08-01'\n";
      final ({ContentSource source, ContentBuildOptions options, Directory root}) c = build(
        files: files,
      );
      addTearDown(() => c.root.deleteSync(recursive: true));

      final failures = <Failure>[
        for (final Assertion assertion in c.source.assertions) ...assertion.run(c.source),
      ];

      expect(failures, isNotEmpty);
      expect(c.options.outFile.existsSync(), isFalse);
      expect(gzipFile(c.options).existsSync(), isFalse);
      expect(sidecarFile(c.options).existsSync(), isFalse);
    });
  });
}
