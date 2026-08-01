import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'repo_root.dart';

typedef GateRow = ({String script, String target, String glob, int minFiles});

List<GateRow> gateTable() => repoFile('tools/gates/skill_gates.tsv')
    .readAsLinesSync()
    .map((l) => l.split('#').first.trim())
    .where((l) => l.isNotEmpty)
    .map((l) {
      final List<String> c = l.split('\t').map((s) => s.trim()).toList();
      return (script: c[0], target: c[1], glob: c[2], minFiles: int.parse(c[3]));
    })
    .toList();

/// Every check script under `.claude/skills/`, which after D-13 holds only the
/// sixteen `catchlaw-*` and `lonja-*` gates this repository owns.
///
/// Deliberately NOT scoped to those two prefixes. The 33 vendored general
/// Flutter skills live in `.claude/skills-flutter/` precisely so that
/// `check_app_invariants.sh`'s check-9 fan-out — which globs every sibling of
/// itself — sees only these sixteen. Scoping this list by prefix instead would
/// let a general skill be dropped back into `.claude/skills/` without any test
/// noticing, and the fan-out would start failing on a router E12 has not built.
List<String> scriptsOnDisk() =>
    repoDir('.claude/skills')
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path.replaceFirst('${repoRoot().path}/', ''))
        .where((p) => RegExp(r'\.claude/skills/[^/]+/scripts/check_[a-z_]+\.sh$').hasMatch(p))
        .toList()
      ..sort();

ProcessResult runRunner({String? table}) => Process.runSync('bash', <String>[
  repoFile('tools/gates/run_skill_gates.sh').path,
  table ?? repoFile('tools/gates/skill_gates.tsv').path,
], workingDirectory: repoRoot().path);

/// A copy of the real table with the first row's target swapped for [target].
String tableWithFirstRowTargeting(String target) {
  final List<GateRow> rows = gateTable();
  final lines = <String>[
    '${rows.first.script}\t$target\t${rows.first.glob}\t${rows.first.minFiles}',
    for (final r in rows.skip(1)) '${r.script}\t${r.target}\t${r.glob}\t${r.minFiles}',
  ];
  final f = File('${Directory.systemTemp.createTempSync('catchlaw_gate').path}/table.tsv')
    ..writeAsStringSync(lines.join('\n'));
  return f.path;
}

void main() {
  test('Gate table names every check script shipped under .claude/skills', () {
    final List<String> missing = scriptsOnDisk()
        .where((s) => !gateTable().any((r) => r.script == s))
        .toList();
    expect(
      missing,
      isEmpty,
      reason: 'a gate with no row is a gate nobody runs:\n${missing.join('\n')}',
    );
  });

  test('Gate table names no script that does not exist', () {
    final List<String> ghosts = gateTable()
        .map((r) => r.script)
        .where((s) => !repoFile(s).existsSync())
        .toList();
    expect(ghosts, isEmpty, reason: 'renamed or removed:\n${ghosts.join('\n')}');
  });

  test('Gate table names sixteen scripts', () {
    // Sixteen SCRIPTS, not sixteen rows. A script may appear more than once
    // when it has more than one documented target, and
    // check_content_pipeline.sh has two: its Dart checks find a subject under
    // tools/content_builder, and checks 1, 2, 3, 5, 6 and 7 read only *.yaml,
    // which lives at content/.
    expect(gateTable().map((GateRow r) => r.script).toSet(), hasLength(16));
  });

  test('Gate table runs check_content_pipeline.sh against both its targets', () {
    // CLAUDE.md names both. Running only tools/content_builder means CI never
    // scans the authored corpus at all — and a gate that is not run is a gate
    // that is not there, whatever colour it prints.
    final Set<String> targets = gateTable()
        .where((GateRow r) => r.script.endsWith('check_content_pipeline.sh'))
        .map((GateRow r) => r.target)
        .toSet();

    expect(targets, <String>{'tools/content_builder', 'content'});
  });

  test("Gate runner fails when a target directory holds no file matching the gate's glob", () {
    final Directory empty = Directory.systemTemp.createTempSync('catchlaw_empty_gate_target');
    addTearDown(() => empty.deleteSync(recursive: true));
    final ProcessResult r = runRunner(table: tableWithFirstRowTargeting(empty.path));
    expect(r.exitCode, 1);
    expect(
      r.stdout,
      contains('scanned 0 files'),
      reason: 'a gate over an empty tree reports success — CONVENTIONS.md §7',
    );
  });

  test('Gate runner fails when a target directory does not exist', () {
    final ProcessResult r = runRunner(table: tableWithFirstRowTargeting('no/such/dir'));
    expect(r.exitCode, 1);
    expect(
      r.stdout,
      contains('no/such/dir'),
      reason: 'the runner must name the row and the path, not just relay an exit 2',
    );
  });

  test('Gate runner prints the file count it scanned for every row', () {
    final ProcessResult r = runRunner();
    final int counted = RegExp('scanned [0-9]+ files').allMatches('${r.stdout}').length;
    expect(
      counted,
      gateTable().length,
      reason: 'the number is the evidence; "OK" with no number is the claim, not the check',
    );
  });

  test('Gate runner runs every row after one fails', () {
    final ProcessResult r = runRunner(table: tableWithFirstRowTargeting('no/such/dir'));
    final int counted = RegExp('scanned [0-9]+ files').allMatches('${r.stdout}').length;
    expect(
      counted,
      gateTable().length - 1,
      reason: 'stopping at the first red hides fifteen results and produces one fix per push',
    );
  });

  test('Gate runner exits non-zero when any gate exits non-zero', () {
    expect(runRunner(table: tableWithFirstRowTargeting('no/such/dir')).exitCode, isNot(0));
  });

  test('Gate table routes check_rule_engine.sh at packages/rule_engine/lib', () {
    final GateRow row = gateTable().firstWhere((r) => r.script.endsWith('check_rule_engine.sh'));
    expect(
      row.target,
      'packages/rule_engine/lib',
      reason: 'pointed at app/lib the engine gate passes over the wrong tree (D-1)',
    );
  });

  test('Gate table routes check_content_pipeline.sh at tools/content_builder', () {
    final GateRow row = gateTable().firstWhere(
      (r) => r.script.endsWith('check_content_pipeline.sh'),
    );
    expect(row.target, 'tools/content_builder', reason: 'D-4');
  });

  test('Gate table gives content a non-empty scan', () {
    // The row would have been an EMPTY SCAN before E04/T03 authored the first
    // strings.yaml, which is why it is added here and not in E01.
    final GateRow row = gateTable().firstWhere((GateRow r) => r.target == 'content');
    final int yaml = repoDir('content')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.yaml'))
        .length;

    expect(yaml, greaterThanOrEqualTo(row.minFiles));
  });

  test('Gate table routes every lonja gate at app/lib', () {
    final List<String> wrong = gateTable()
        .where((r) => r.script.contains('/lonja-') && r.target != 'app/lib')
        .map((r) => r.script)
        .toList();
    expect(
      wrong,
      isEmpty,
      reason:
          'the lonja gates exempt tokens by the path fragment /theme/, which only '
          'resolves under app/lib (D-2):\n${wrong.join('\n')}',
    );
  });

  test('Every target directory named in the gate table exists', () {
    final List<String> missing = gateTable()
        .map((r) => r.target)
        .where((t) => !repoDir(t).existsSync())
        .toList();
    expect(
      missing,
      isEmpty,
      reason: "a typo'd path exits 2 five minutes into a CI run:\n${missing.join('\n')}",
    );
  });
}
