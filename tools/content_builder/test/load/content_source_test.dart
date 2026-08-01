// The corpus: one shared directory and one directory per jurisdiction, so E22
// adds a sibling and touches nothing that already ships.

import 'dart:io';

import 'package:content_builder/src/assert/assertion.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:test/test.dart';

import '../../testing/fixtures/yaml_fixtures.dart';

/// Writes `files` — relative path to contents — into a fresh temporary tree.
Directory treeOf(Map<String, String> files) {
  final Directory root = Directory.systemTemp.createTempSync('content_builder_tree_');
  for (final MapEntry<String, String> entry in files.entries) {
    final file = File('${root.path}/${entry.key}');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
  }
  return root;
}

Map<String, String> get kTwoDirectoryTree => <String, String>{
  'shared/species.yaml': kSharedSpeciesYaml,
  'es-ga/jurisdiction.yaml': kGaliciaJurisdictionYaml,
  'es-ga/rules.yaml': kGaliciaRulesYaml,
};

void main() {
  group('ContentSource', () {
    test('.load reads one jurisdiction directory and the shared directory', () {
      final Directory root = treeOf(kTwoDirectoryTree);
      addTearDown(() => root.deleteSync(recursive: true));

      final source = ContentSource.load(root);

      expect(source.failures, isEmpty);
      expect(source.section('species'), hasLength(1));
      expect(source.section('rules'), hasLength(1));
      expect(source.section('jurisdiction'), hasLength(1));
    });

    test('.load tags a jurisdiction row with its directory', () {
      final Directory root = treeOf(kTwoDirectoryTree);
      addTearDown(() => root.deleteSync(recursive: true));

      expect(ContentSource.load(root).section('rules').single.jurisdiction, 'es-ga');
    });

    test('.load leaves a shared row untagged', () {
      // shared/ is every jurisdiction's, so a species that carries one
      // directory's tag would be filtered out of every other one's diff.
      final Directory root = treeOf(kTwoDirectoryTree);
      addTearDown(() => root.deleteSync(recursive: true));

      expect(ContentSource.load(root).section('species').single.jurisdiction, isNull);
    });

    test('.load reports the display path relative to the corpus root', () {
      final Directory root = treeOf(kTwoDirectoryTree);
      addTearDown(() => root.deleteSync(recursive: true));

      expect(ContentSource.load(root).section('rules').single.path, 'es-ga/rules.yaml');
    });

    test('.load rejects an unknown top-level key', () {
      // A typo'd section loads as "no rows", and a whole file goes missing with
      // no failure line to show for it.
      final Directory root = treeOf(<String, String>{'es-ga/rules.yaml': kUnknownSectionYaml});
      addTearDown(() => root.deleteSync(recursive: true));

      final source = ContentSource.load(root);

      expect(source.failures.single.message, contains('speceis'));
      expect(source.failures.single.line, 1);
    });

    test('.load rejects a file whose name is not part of the authoring format', () {
      // The same defect one level up: `rule.yaml` for `rules.yaml` is a file
      // nobody reads and nobody misses.
      final Directory root = treeOf(<String, String>{'es-ga/rule.yaml': kThreeRuleRowsYaml});
      addTearDown(() => root.deleteSync(recursive: true));

      expect(ContentSource.load(root).failures.single.message, contains('rule.yaml'));
    });

    test('.load rejects a duplicate row id within a file', () {
      // The T09 changelog diff and the T08 resolution grid would disagree about
      // which row is which, and neither would say so.
      final Directory root = treeOf(<String, String>{'es-ga/rules.yaml': kDuplicateRowIdYaml});
      addTearDown(() => root.deleteSync(recursive: true));

      final source = ContentSource.load(root);

      expect(source.failures.single.message, contains('es-ga-r-001'));
      expect(source.failures.single.message, contains('2'), reason: 'names the first line');
      expect(source.failures.single.line, 5, reason: 'and is reported at the second');
    });

    test('.load ignores README.md and the CHANGELOG directory', () {
      final Directory root = treeOf(<String, String>{
        ...kTwoDirectoryTree,
        'README.md': '# authoring format\n',
        'CHANGELOG/es-ga.md': '# ES-GA\n',
      });
      addTearDown(() => root.deleteSync(recursive: true));

      expect(ContentSource.load(root).failures, isEmpty);
    });

    test('.load rejects a YAML file sitting at the corpus root', () {
      // Every authored file belongs to `shared/` or to a jurisdiction. One
      // dropped at the root is read by nothing and missed by nobody — the same
      // defect as a misspelt file name, one level further up.
      final Directory root = treeOf(<String, String>{
        ...kTwoDirectoryTree,
        'rules.yaml': kThreeRuleRowsYaml,
      });
      addTearDown(() => root.deleteSync(recursive: true));

      expect(ContentSource.load(root).failures.single.message, contains('rules.yaml'));
    });

    test('.load rejects a corpus holding no jurisdiction directory', () {
      // The silent green this whole tool exists to avoid. A corpus with nothing
      // in it satisfies all ten assertions, and the build writes a database with
      // no rules in it and exits 0.
      final Directory root = treeOf(<String, String>{'shared/species.yaml': kSharedSpeciesYaml});
      addTearDown(() => root.deleteSync(recursive: true));

      expect(ContentSource.load(root).failures.single.message, contains('no jurisdiction'));
    });

    test('.load reports a missing corpus directory rather than an empty one', () {
      // An input directory that is not there must not read as a corpus with no
      // rows, which passes every assertion there is.
      final Directory root = Directory.systemTemp.createTempSync('content_builder_tree_');
      root.deleteSync();

      expect(ContentSource.load(root).failures.single.message, contains('not found'));
    });

    test('.assertions exposes the registry in the order E04 lands it', () {
      // The registry T02-T09 plug into. It held nothing at T01 and holds exactly
      // what has landed since — a list that ran ahead of the tasks would make a
      // missing assertion look exactly like a finished one.
      final Directory root = treeOf(kTwoDirectoryTree);
      addTearDown(() => root.deleteSync(recursive: true));

      expect(ContentSource.load(root).assertions.map((Assertion a) => a.id), <String>['A1', 'A2']);
    });

    test('.failures are sorted by path then line', () {
      // build-assertions.md "Failure format". One build round-trip must read
      // top to bottom like the corpus does.
      final Directory root = treeOf(<String, String>{
        'es-ga/zones.yaml': kUnknownSectionYaml,
        'es-ga/rules.yaml': kDuplicateRowIdYaml,
      });
      addTearDown(() => root.deleteSync(recursive: true));

      expect(ContentSource.load(root).failures.map((Failure f) => f.path), <String>[
        'es-ga/rules.yaml',
        'es-ga/zones.yaml',
      ]);
    });
  });
}
