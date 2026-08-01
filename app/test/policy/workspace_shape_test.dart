import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'repo_root.dart';

const members = <String>[
  'app',
  'packages/rule_engine',
  'packages/analysis_defaults',
  'tools/content_builder',
];

YamlMap pubspecOf(String relativeDir) =>
    loadYaml(repoFile('$relativeDir/pubspec.yaml').readAsStringSync()) as YamlMap;

void main() {
  test('Workspace root declares exactly the four members', () {
    expect((pubspecOf('.')['workspace'] as YamlList).cast<String>(), members);
  });

  test('Workspace root package is named catchlaw_workspace', () {
    expect(pubspecOf('.')['name'], 'catchlaw_workspace');
  });

  test('Every workspace member declares resolution: workspace', () {
    final offenders = <String>[
      for (final m in members)
        if (pubspecOf(m)['resolution'] != 'workspace') m,
    ];
    expect(
      offenders,
      isEmpty,
      reason:
          'a member without resolution: workspace resolves a stale copy and '
          'its changes are never seen:\n${offenders.join('\n')}',
    );
  });

  test('Every workspace member declares the Dart SDK constraint ^3.12.0', () {
    final offenders = <String>[
      for (final m in [...members, '.'])
        if ((pubspecOf(m)['environment'] as YamlMap)['sdk'] != '^3.12.0') m,
    ];
    expect(
      offenders,
      isEmpty,
      reason:
          'version solving fails on mismatched member constraints, and names '
          'neither member in the message (D-5):\n${offenders.join('\n')}',
    );
  });

  test('Exactly one pubspec.lock exists in the repository', () {
    final List<String> locks = repoRoot()
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('pubspec.lock') && !f.path.contains('/.dart_tool/'))
        .map((f) => f.path)
        .toList();
    expect(
      locks,
      hasLength(1),
      reason:
          'a second lock means dart pub get ran inside a package directory:\n'
          '${locks.join('\n')}',
    );
  });

  test('pubspec.lock is not gitignored', () {
    expect(
      repoFile('.gitignore').readAsLinesSync().map((l) => l.trim()),
      isNot(contains('pubspec.lock')),
      reason:
          "this is an application — the committed lock is what makes a stranger's "
          'clone resolve the versions that were tested on a device',
    );
  });

  test('rule_engine pubspec declares no flutter dependency', () {
    final String raw = repoFile('packages/rule_engine/pubspec.yaml').readAsStringSync();
    expect(
      RegExp(r'^\s*flutter\s*:', multiLine: true).hasMatch(raw),
      isFalse,
      reason:
          'the missing line IS the purity guarantee: an import of package:flutter '
          'is then a compile error, not a lint (FLUTTER_GUIDE §4.6 layer 1)',
    );
  });

  test('rule_engine pubspec declares exactly its two reviewed runtime dependencies', () {
    final deps = pubspecOf('packages/rule_engine')['dependencies'] as YamlMap;
    expect(
      deps.keys,
      ['meta', 'unorm_dart'],
      reason:
          'Every runtime dependency of the engine is a thing a reviewer must '
          'reason about before believing it is pure, so the set is pinned rather '
          'than bounded. unorm_dart arrived in E02/T02 because dart:core offers '
          'neither NFD nor the NFKC SPEC.md §9.4 opens with. A third entry is a '
          'failing test, which is the point — not a number to raise.',
    );
  });

  test('content_builder package is named content_builder', () {
    expect(pubspecOf('tools/content_builder')['name'], 'content_builder');
  });

  test('.fvmrc records Flutter 3.44.6 as JSON', () {
    final decoded = jsonDecode(repoFile('.fvmrc').readAsStringSync()) as Map<String, dynamic>;
    expect(decoded['flutter'], '3.44.6');
  });

  test('app main is not async', () {
    final String raw = repoFile('app/lib/main.dart').readAsStringSync();
    expect(
      RegExp(r'(void|Future<void>)\s+main\(\)\s+async').hasMatch(raw),
      isFalse,
      reason:
          'nothing is awaited before runApp — a black screen is indistinguishable '
          'from a crash (catchlaw-conventions-index rule 8)',
    );
  });

  test('app pubspec sets publish_to to none', () {
    expect(pubspecOf('app')['publish_to'], 'none');
  });
}
