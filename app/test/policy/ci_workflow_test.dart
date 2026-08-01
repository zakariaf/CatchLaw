import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'repo_root.dart';

// Memoised: ten tests read this file, several of them twice.
String? _text;

String workflowText() => _text ??= repoFile('.github/workflows/validate.yml').readAsStringSync();

YamlMap jobs() => (loadYaml(workflowText()) as YamlMap)['jobs'] as YamlMap;

List<String> stepRuns(String job) => [
  for (final step in (jobs()[job] as YamlMap)['steps'] as YamlList)
    if ((step as YamlMap)['run'] != null) step['run'] as String,
];

/// `suite=<member>` and `no-suite=<member>` lines. Stated once, read by the
/// workflow author and by this test, so the split is a decision and not an
/// omission.
Map<String, List<String>> ciMembers() {
  final out = <String, List<String>>{'suite': [], 'no-suite': []};
  final List<String> lines = repoFile('tools/gates/ci_members.txt').readAsLinesSync();
  for (final line in lines) {
    final String trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final List<String> parts = trimmed.split('#').first.trim().split('=');
    out[parts.first]!.add(parts.last.trim());
  }
  return out;
}

void main() {
  test('validate.yml keeps the skills and invariants jobs', () {
    expect(jobs().keys, containsAll(<String>['skills', 'invariants', 'flutter']));
  });

  test('validate.yml pins every runner to an exact Ubuntu image', () {
    expect(
      workflowText(),
      isNot(contains('ubuntu-latest')),
      reason: 'image drift moves the toolchain under the workflow with no diff to review',
    );
  });

  test('validate.yml resolves the Flutter toolchain from .fvmrc', () {
    expect(workflowText(), contains('flutter-version-file: .fvmrc'));
    expect(
      RegExp(r'flutter-version:\s*[\x27"]?\d').hasMatch(workflowText()),
      isFalse,
      reason: 'a literal version is a second copy of the pin and drifts on the next upgrade',
    );
  });

  test('validate.yml runs dart format with --set-exit-if-changed', () {
    expect(stepRuns('flutter').join('\n'), contains('--set-exit-if-changed'));
  });

  test('validate.yml runs flutter analyze with --fatal-infos', () {
    expect(stepRuns('flutter').join('\n'), contains('flutter analyze --fatal-infos'));
  });

  test('validate.yml runs a suite for every workspace member not listed as no-suite', () {
    final root = loadYaml(repoFile('pubspec.yaml').readAsStringSync()) as YamlMap;
    final Set<String> members = (root['workspace'] as YamlList).cast<String>().toSet();
    final Map<String, List<String>> declared = ciMembers();
    expect(
      {...declared['suite']!, ...declared['no-suite']!},
      members,
      reason:
          'a member with no suite and a member whose CI line was deleted look '
          'identical in a workflow file',
    );
    final String runs = stepRuns('flutter').join('\n');
    final List<String> missing = declared['suite']!
        .where((m) => !runs.contains('cd $m &&'))
        .toList();
    expect(missing, isEmpty, reason: 'no CI step runs:\n${missing.join('\n')}');
  });

  test('validate.yml randomises test ordering in every suite step', () {
    final List<String> suiteSteps = stepRuns('flutter').where((r) => r.contains(' test ')).toList();
    final List<String> missing = suiteSteps
        .where((r) => !r.contains('--test-randomize-ordering-seed random'))
        .toList();
    expect(missing, isEmpty, reason: 'unrandomised suite step:\n${missing.join('\n')}');
  });

  test('validate.yml sets continue-on-error on no step', () {
    expect(
      workflowText(),
      isNot(contains('continue-on-error')),
      reason: 'continue-on-error on a gate is a deleted gate with a green tick on top',
    );
  });

  test('validate.yml runs dart pub get exactly once', () {
    final int gets = stepRuns('flutter').where((r) => r.trim() == 'dart pub get').length;
    expect(gets, 1, reason: 'a per-member pub get creates a second lockfile');
  });

  test('validate.yml installs libsqlite3-dev before the first suite step', () {
    final List<String> runs = stepRuns('flutter');
    final int sqlite = runs.indexWhere((r) => r.contains('libsqlite3-dev'));
    final int firstSuite = runs.indexWhere((r) => r.contains(' test '));
    expect(sqlite, greaterThanOrEqualTo(0));
    expect(
      sqlite,
      lessThan(firstSuite),
      reason:
          'flutter test on Linux runs in a plain Dart VM; without the host library '
          'an E05 database suite fails in a way that reads as a broken repository',
    );
  });
}
