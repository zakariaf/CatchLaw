// A10 — a jurisdiction whose rows changed has a changelog that says so.
//
// The failure this prevents is recorded in build-assertions.md as "a rule edited
// without regenerating": a minimum size that changed with nothing in S23 to say
// so. SPEC.md §4.7 promises the user can see currency, and an undocumented
// change breaks that promise silently.
//
// A machine cannot write a summary_key and does not try. The mechanical diff
// DETECTS the change; the author WRITES it. A generated English sentence would
// fail A2 the moment it was generated, and generating six locales of it is
// machine translation of a legal note.

import 'dart:io';

import 'package:content_builder/src/assert/a10_changelog.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/diff/content_diff.dart';
import 'package:content_builder/src/diff/snapshot.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:test/test.dart';

/// A jurisdiction file at [version].
String jurisdictionYaml(String version) =>
    'jurisdiction:\n  - id: ES-GA\n    code: ES-GA\n    country_iso2: ES\n'
    "    content_version: '$version'\n    default_locale: gl\n";

/// A rules file with one rule at [minSizeMm].
String rulesYaml({int minSizeMm = 380, String id = 'es-ga-r-001'}) =>
    'rules:\n  - id: $id\n    jurisdiction_id: ES-GA\n'
    '    species_id: venerupis-corrugata\n    water_type: salt\n'
    '    min_size_mm: $minSizeMm\n    measurement_method_id: SHL\n'
    "    citation_id: es-ga-c-001\n    valid_from: '2012-08-01'\n";

/// A changes file whose one entry covers [ruleIds].
String changesYaml(List<String> ruleIds) =>
    'changes:\n  - id: es-ga-ch-001\n    jurisdiction_id: ES-GA\n'
    "    from_version: '2026.07.0'\n    to_version: '2026.08.0'\n"
    '    summary_key: change.es_ga.2026_08\n' // content-pipeline-ok
    "    changed_on: '2026-08-01'\n"
    '    rule_ids:\n${ruleIds.map((String id) => '      - $id\n').join()}';

/// A corpus on disk holding [files], relative to the root.
Directory corpusOn(Map<String, String> files) {
  final Directory root = Directory.systemTemp.createTempSync('content_builder_diff_');
  for (final MapEntry<String, String> entry in files.entries) {
    final file = File('${root.path}/${entry.key}');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
  }
  return root;
}

ContentSource load(Directory root) => ContentSource.load(root);

List<Failure> a10(Directory root, {bool check = false}) =>
    ChangelogAssertion(check: check).run(load(root)).toList();

void main() {
  group('Snapshot', () {
    test('.of projects only the fields that ship', () {
      // A snapshot that carried authoring metadata would report a diff every
      // time a note was reworded, and a diff full of noise is a diff nobody
      // reads.
      final Directory root = corpusOn(<String, String>{
        'es-ga/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'es-ga/rules.yaml':
            '${rulesYaml()}    min_size_mm_confirmed: true\n    supersedes: es-ga-r-000\n',
      });
      addTearDown(() => root.deleteSync(recursive: true));

      final Map<String, Object?> row = Snapshot.of(load(root), 'es-ga').rows['rules/es-ga-r-001']!;

      expect(row.containsKey('min_size_mm'), isTrue);
      expect(row.containsKey('min_size_mm_confirmed'), isFalse);
      expect(row.containsKey('supersedes'), isFalse);
    });

    test('.of sorts rows by id', () {
      // A diff driven by file order is noise, and noise is what makes a diff
      // unread.
      final Directory root = corpusOn(<String, String>{
        'es-ga/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'es-ga/rules.yaml':
            'rules:\n${rulesYaml(id: 'es-ga-r-002').substring(7)}'
            '${rulesYaml(id: 'es-ga-r-001').substring(7)}',
      });
      addTearDown(() => root.deleteSync(recursive: true));

      expect(Snapshot.of(load(root), 'es-ga').rows.keys, <String>[
        'rules/es-ga-r-001',
        'rules/es-ga-r-002',
      ]);
    });

    test('.of is stable across two runs over identical input', () {
      // The snapshot is committed; an unstable projection makes every build a
      // diff.
      final Directory root = corpusOn(<String, String>{
        'es-ga/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'es-ga/rules.yaml': rulesYaml(),
      });
      addTearDown(() => root.deleteSync(recursive: true));

      expect(Snapshot.of(load(root), 'es-ga').toJson(), Snapshot.of(load(root), 'es-ga').toJson());
    });

    test('.fromJson reads back what .toJson wrote', () {
      final Directory root = corpusOn(<String, String>{
        'es-ga/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'es-ga/rules.yaml': rulesYaml(),
      });
      addTearDown(() => root.deleteSync(recursive: true));
      final original = Snapshot.of(load(root), 'es-ga');

      final round = Snapshot.fromJson('es-ga', original.toJson());

      expect(round.contentVersion, original.contentVersion);
      expect(round.rows, original.rows);
    });

    test('.of scopes a shared plate to the jurisdictions whose rules reach it', () {
      // plates.yaml is shared. A drop should show up where the species is
      // actually shown, not in every changelog in the repository.
      final Directory root = corpusOn(<String, String>{
        'es-ga/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'es-ga/rules.yaml': rulesYaml(),
        'br-sp/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'br-sp/rules.yaml': rulesYaml(
          id: 'br-sp-r-001',
        ).replaceAll('venerupis-corrugata', 'lethrinus-nebulosus'),
        'shared/plates.yaml':
            'plates:\n  - id: bloch-venerupis\n    species_id: venerupis-corrugata\n'
            '    asset: plate/bloch.webp\n    origin: public_domain\n'
            '    illustrator: Marcus Elieser Bloch\n    illustrator_death_year: 1799\n',
      });
      addTearDown(() => root.deleteSync(recursive: true));
      final ContentSource source = load(root);

      expect(Snapshot.of(source, 'es-ga').rows.keys, contains('plates/bloch-venerupis'));
      expect(Snapshot.of(source, 'br-sp').rows.keys, isNot(contains('plates/bloch-venerupis')));
    });

    test('.fromJson survives a file that is not an object', () {
      expect(Snapshot.fromJson('es-ga', '[]').rows, isEmpty);
    });
  });

  group('ContentDiff', () {
    Snapshot snapshotWith(Map<String, Map<String, Object?>> rows, {String version = '1'}) =>
        Snapshot(jurisdiction: 'es-ga', contentVersion: version, rows: rows);

    test('.between reports an added rule', () {
      final diff = ContentDiff.between(
        Snapshot.empty('es-ga'),
        snapshotWith(<String, Map<String, Object?>>{
          'rules/r-1': <String, Object?>{'min_size_mm': 380},
        }),
      );

      expect(diff.entries.single.kind, ChangeKind.added);
      expect(diff.entries.single.id, 'r-1');
    });

    test('.between reports an amended rule with old and new values', () {
      // "It changed" answers none of the questions the changelog exists for.
      final diff = ContentDiff.between(
        snapshotWith(<String, Map<String, Object?>>{
          'rules/r-1': <String, Object?>{'min_size_mm': 380},
        }),
        snapshotWith(<String, Map<String, Object?>>{
          'rules/r-1': <String, Object?>{'min_size_mm': 400},
        }, version: '2'),
      );

      expect(diff.entries.single.kind, ChangeKind.amended);
      expect(diff.entries.single.fields['min_size_mm'], (from: 380, to: 400));
      expect(diff.entries.single.render(), contains('380'));
      expect(diff.entries.single.render(), contains('400'));
    });

    test('.between reports a withdrawn rule', () {
      // A rule that disappears is the change least likely to be noticed in
      // review.
      final diff = ContentDiff.between(
        snapshotWith(<String, Map<String, Object?>>{
          'rules/r-1': <String, Object?>{'min_size_mm': 380},
        }),
        Snapshot.empty('es-ga'),
      );

      expect(diff.entries.single.kind, ChangeKind.withdrawn);
    });

    test('.between reports a re-retrieved citation', () {
      // §4.7 currency: the footnote's date changed and the user can see why.
      final diff = ContentDiff.between(
        snapshotWith(<String, Map<String, Object?>>{
          'citations/c-1': <String, Object?>{'retrieved_on': '2026-07-14'},
        }),
        snapshotWith(<String, Map<String, Object?>>{
          'citations/c-1': <String, Object?>{'retrieved_on': '2026-08-12'},
        }, version: '2'),
      );

      expect(diff.entries.single.fields.keys, <String>['retrieved_on']);
    });

    test('.between reports a dropped plate', () {
      // T06 drops plates; S17's attribution list shrinks and the reason must be
      // recorded.
      final diff = ContentDiff.between(
        snapshotWith(<String, Map<String, Object?>>{
          'plates/p-1': <String, Object?>{'illustrator': 'Bloch'},
        }),
        Snapshot.empty('es-ga'),
      );

      expect(diff.entries.single.section, 'plates');
      expect(diff.entries.single.kind, ChangeKind.withdrawn);
    });

    test('.between reports nothing when the corpus is unchanged', () {
      // The green path, and the one that runs on every build that changes
      // nothing.
      final Snapshot same = snapshotWith(<String, Map<String, Object?>>{
        'rules/r-1': <String, Object?>{'min_size_mm': 380},
      });

      expect(ContentDiff.between(same, same).isEmpty, isTrue);
    });

    test('.toString renders the same line the changelog prints', () {
      const entry = ChangeEntry(kind: ChangeKind.withdrawn, section: 'rules', id: 'r-1');

      expect(entry.toString(), entry.render());
    });

    test('.renderMarkdown says so plainly when nothing changed', () {
      expect(
        ContentDiff.between(Snapshot.empty('es-ga'), Snapshot.empty('es-ga')).renderMarkdown(),
        contains('No shipping rows changed'),
      );
    });

    test('.renderMarkdown names both versions', () {
      final diff = ContentDiff.between(
        snapshotWith(<String, Map<String, Object?>>{
          'rules/r-1': <String, Object?>{'min_size_mm': 380},
        }),
        snapshotWith(<String, Map<String, Object?>>{
          'rules/r-1': <String, Object?>{'min_size_mm': 400},
        }, version: '2026.08.0'),
      );

      expect(diff.renderMarkdown(), contains('1 → 2026.08.0'));
    });
  });

  group('ChangelogAssertion', () {
    test('reports A10 when a changed rule has no authored change entry', () {
      // The failure this assertion exists for.
      final Directory root = corpusOn(<String, String>{
        'es-ga/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'es-ga/rules.yaml': rulesYaml(minSizeMm: 400),
        'es-ga/snapshot.json': const Snapshot(
          jurisdiction: 'es-ga',
          contentVersion: '2026.07.0',
          rows: <String, Map<String, Object?>>{
            'rules/es-ga-r-001': <String, Object?>{'min_size_mm': 380},
          },
        ).toJson(),
      });
      addTearDown(() => root.deleteSync(recursive: true));

      final List<Failure> failures = a10(root);

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A10');
      expect(failures.single.message, contains('es-ga-r-001'));
    });

    test('accepts a changed rule covered by an authored entry', () {
      final Directory root = corpusOn(<String, String>{
        'es-ga/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'es-ga/rules.yaml': rulesYaml(minSizeMm: 400),
        'es-ga/changes.yaml': changesYaml(<String>['es-ga-r-001']),
        'es-ga/snapshot.json': const Snapshot(
          jurisdiction: 'es-ga',
          contentVersion: '2026.07.0',
          rows: <String, Map<String, Object?>>{
            'rules/es-ga-r-001': <String, Object?>{'min_size_mm': 380},
          },
        ).toJson(),
      });
      addTearDown(() => root.deleteSync(recursive: true));

      expect(a10(root), isEmpty);
    });

    test('reports A10 when rows changed and content_version did not', () {
      // catch.content_version would point at two different rulesets, and §7.1
      // denormalises it precisely so history survives a content update.
      final Directory root = corpusOn(<String, String>{
        'es-ga/jurisdiction.yaml': jurisdictionYaml('2026.07.0'),
        'es-ga/rules.yaml': rulesYaml(minSizeMm: 400),
        'es-ga/changes.yaml': changesYaml(<String>['es-ga-r-001']),
        'es-ga/snapshot.json': const Snapshot(
          jurisdiction: 'es-ga',
          contentVersion: '2026.07.0',
          rows: <String, Map<String, Object?>>{
            'rules/es-ga-r-001': <String, Object?>{'min_size_mm': 380},
          },
        ).toJson(),
      });
      addTearDown(() => root.deleteSync(recursive: true));

      final List<Failure> failures = a10(root);

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('content_version'));
    });

    test('reports A10 in --check mode when snapshot.json is stale', () {
      // The generated-file discipline. Without it A10 can never fire: a build
      // that regenerates both every time makes the committed files correct by
      // construction.
      final Directory root = corpusOn(<String, String>{
        'es-ga/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'es-ga/rules.yaml': rulesYaml(minSizeMm: 400),
        'es-ga/changes.yaml': changesYaml(<String>['es-ga-r-001']),
        'es-ga/snapshot.json': const Snapshot(
          jurisdiction: 'es-ga',
          contentVersion: '2026.07.0',
          rows: <String, Map<String, Object?>>{
            'rules/es-ga-r-001': <String, Object?>{'min_size_mm': 380},
          },
        ).toJson(),
      });
      addTearDown(() => root.deleteSync(recursive: true));

      final List<Failure> failures = a10(root, check: true);

      expect(failures.where((Failure f) => f.path.endsWith('snapshot.json')), hasLength(1));
    });

    test('reports A10 in --check mode when the changelog markdown is stale', () {
      final Directory root = corpusOn(<String, String>{
        'es-ga/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'es-ga/rules.yaml': rulesYaml(minSizeMm: 400),
        'es-ga/changes.yaml': changesYaml(<String>['es-ga-r-001']),
        'es-ga/snapshot.json': const Snapshot(
          jurisdiction: 'es-ga',
          contentVersion: '2026.07.0',
          rows: <String, Map<String, Object?>>{
            'rules/es-ga-r-001': <String, Object?>{'min_size_mm': 380},
          },
        ).toJson(),
        'CHANGELOG/es-ga.md': '# stale\n',
      });
      addTearDown(() => root.deleteSync(recursive: true));

      final List<Failure> failures = a10(root, check: true);

      expect(failures.where((Failure f) => f.path.endsWith('es-ga.md')), hasLength(1));
    });

    test('accepts the artefacts it has just written in --check mode', () {
      final Directory root = corpusOn(<String, String>{
        'es-ga/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'es-ga/rules.yaml': rulesYaml(minSizeMm: 400),
        'es-ga/changes.yaml': changesYaml(<String>['es-ga-r-001']),
      });
      addTearDown(() => root.deleteSync(recursive: true));
      writeChangelogs(load(root));

      expect(a10(root, check: true), isEmpty);
    });

    test('writes one changelog file per jurisdiction', () {
      // Parallel authoring, per §15 step 19: two authors on two jurisdictions
      // must not collide in one file.
      final Directory root = corpusOn(<String, String>{
        'es-ga/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'es-ga/rules.yaml': rulesYaml(),
        'br-sp/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'br-sp/rules.yaml': rulesYaml(id: 'br-sp-r-001'),
      });
      addTearDown(() => root.deleteSync(recursive: true));

      writeChangelogs(load(root));

      expect(File('${root.path}/CHANGELOG/es-ga.md').readAsStringSync(), contains('es-ga-r-001'));
      expect(
        File('${root.path}/CHANGELOG/es-ga.md').readAsStringSync(),
        isNot(contains('br-sp-r-001')),
      );
      expect(File('${root.path}/CHANGELOG/br-sp.md').readAsStringSync(), contains('br-sp-r-001'));
    });

    test('accepts an unchanged corpus', () {
      final Directory root = corpusOn(<String, String>{
        'es-ga/jurisdiction.yaml': jurisdictionYaml('2026.08.0'),
        'es-ga/rules.yaml': rulesYaml(),
      });
      addTearDown(() => root.deleteSync(recursive: true));
      writeChangelogs(load(root));

      expect(a10(root), isEmpty);
    });

    test('does nothing for a corpus that is not on disk', () {
      // A corpus built from strings has no committed snapshot to compare
      // against, and inventing one would report every row as added.
      expect(
        const ChangelogAssertion(
          check: true,
        ).run(const ContentSource(sources: <YamlSource>[], failures: <Failure>[])),
        isEmpty,
      );
    });

    test('reports nothing about generated files for a corpus built from strings', () {
      // A corpus with no directory has no committed snapshot to compare
      // against. Reporting one as stale would fail every test that builds a
      // corpus inline.
      final inMemory = ContentSource(
        sources: <YamlSource>[
          YamlSource.fromString(
            jurisdictionYaml('2026.08.0'),
            displayPath: 'es-ga/jurisdiction.yaml',
            jurisdiction: 'es-ga',
          ),
          YamlSource.fromString(
            rulesYaml(),
            displayPath: 'es-ga/rules.yaml',
            jurisdiction: 'es-ga',
          ),
        ],
        failures: const <Failure>[],
      );

      final List<Failure> failures = const ChangelogAssertion(check: true).run(inMemory).toList();

      expect(failures.where((Failure f) => f.message.contains('stale')), isEmpty);
    });

    test('writes nothing for a corpus built from strings', () {
      expect(
        () => writeChangelogs(const ContentSource(sources: <YamlSource>[], failures: <Failure>[])),
        returnsNormally,
      );
    });

    test('.id is A10', () {
      expect(const ChangelogAssertion().id, 'A10');
    });
  });
}
