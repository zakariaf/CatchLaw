import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'repo_root.dart';

const nested = <String>[
  'app/analysis_options.yaml',
  'packages/rule_engine/analysis_options.yaml',
  'tools/content_builder/analysis_options.yaml',
];

YamlMap rootYaml() => loadYaml(repoFile('analysis_options.yaml').readAsStringSync()) as YamlMap;

void main() {
  test('Root analysis options include the flutter_lints rule set', () {
    expect(rootYaml()['include'], 'package:flutter_lints/flutter.yaml');
  });

  test('Root analysis options declare plugins as a top-level key', () {
    final YamlMap root = rootYaml();
    expect(root.containsKey('plugins'), isTrue);
    expect(
      (root['analyzer'] as YamlMap).containsKey('plugins'),
      isFalse,
      reason:
          'analyzer: plugins: is the pre-Dart-3.10 form. It loads nothing and '
          'reports nothing, which reads exactly like a plugin with no findings',
    );
  });

  test('Root analysis options pin riverpod_lint to exactly 3.1.4', () {
    expect(
      (rootYaml()['plugins'] as YamlMap)['riverpod_lint'],
      '3.1.4',
      reason:
          'a caret range resolves 3.1.6, which fails version solving on '
          'analyzer ^12 vs ^13 (FLUTTER_GUIDE 4.1 fact 3)',
    );
  });

  test('Root analysis options promote depend_on_referenced_packages to error', () {
    final errors = (rootYaml()['analyzer'] as YamlMap)['errors'] as YamlMap;
    expect(errors['depend_on_referenced_packages'], 'error');
  });

  test('Root analysis options use list form throughout the linter rules block', () {
    expect(
      (rootYaml()['linter'] as YamlMap)['rules'] is YamlList,
      isTrue,
      reason:
          'a block mixing "- rule" and "rule: true" is a config parse error — '
          'a broken analyzer reads as a green build',
    );
  });

  test('App analysis options include the workspace root options file', () {
    final yaml = loadYaml(repoFile('app/analysis_options.yaml').readAsStringSync()) as YamlMap;
    expect(yaml['include'], '../analysis_options.yaml');
  });

  test('rule_engine analysis options include the workspace root options file', () {
    final yaml =
        loadYaml(repoFile('packages/rule_engine/analysis_options.yaml').readAsStringSync())
            as YamlMap;
    expect(
      yaml['include'],
      '../../analysis_options.yaml',
      reason:
          'a nested options file REPLACES the parent for its subtree — without '
          'this line the package silently loses every rule (FLUTTER_GUIDE 4.3)',
    );
  });

  test('No nested analysis options file declares a plugins key', () {
    final offenders = <String>[
      for (final path in nested)
        if ((loadYaml(repoFile(path).readAsStringSync()) as YamlMap).containsKey('plugins')) path,
    ];
    expect(
      offenders,
      isEmpty,
      reason:
          'plugins: is top-level only and cannot appear in a nested options '
          'file:\n${offenders.join('\n')}',
    );
  });

  test('App analysis options state depend_on_referenced_packages as error in their own text', () {
    expect(
      repoFile('app/analysis_options.yaml').readAsStringSync(),
      contains('depend_on_referenced_packages: error'),
      reason:
          'check_no_network.sh check 2 greps the options file beside its target '
          'and cannot follow an include: — without the restated line the gate skips',
    );
  });

  test('Root analysis options do not exclude generated Dart files', () {
    final List<String> excludes = ((rootYaml()['analyzer'] as YamlMap)['exclude'] as YamlList)
        .cast<String>();
    final List<String> offenders = excludes
        .where(
          (e) => e.contains('.g.dart') || e.contains('.freezed.dart') || e.contains('.drift.dart'),
        )
        .toList();
    expect(
      offenders,
      isEmpty,
      reason:
          'exclude still resolves and type-checks the file and only hides its '
          'diagnostics, so a real error in generated code survives to build time '
          '(FLUTTER_GUIDE 4.4):\n${offenders.join('\n')}',
    );
  });

  test('Root analysis options enable document_ignores and unnecessary_ignore', () {
    final List<String> rules = ((rootYaml()['linter'] as YamlMap)['rules'] as YamlList)
        .cast<String>();
    expect(rules, containsAll(<String>['document_ignores', 'unnecessary_ignore']));
  });

  test('No package declares a test analysis options file', () {
    final List<String> offenders = repoRoot()
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .map((f) => f.path)
        .where((p) => p.endsWith('/test/analysis_options.yaml'))
        .toList();
    expect(
      offenders,
      isEmpty,
      reason:
          'it replaces the whole root config for the test tree; use per-file '
          '// ignore_for_file: instead (FLUTTER_GUIDE 4.5):\n${offenders.join('\n')}',
    );
  });
}
