import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'repo_root.dart';

/// The allowlist that describes what the app is allowed to contain today.
String liveAllowlist() => repoDir('tools/gates/allowlist').path;

/// A fixture allowlist describing the dependency set CatchLaw reaches once E08
/// adds `flutter_svg` and E17 adds `printing` and `share_plus`. Tests 5-8 need a
/// graph containing those packages, and such a graph cannot also match the live
/// allowlist — so the SPEC.md §14 edge exception is proved against these, three
/// epics before the packages that will exercise it arrive.
///
/// One per case, so that in a failing case the EDGE assertion is the only thing
/// left to object to and the direct-set diff cannot mask it.
String fixtureAllowlist(String name) => repoDir('tools/gates/testdata/allowlist/$name').path;

ProcessResult runGate({required String fixture, String? allowlistDir}) =>
    Process.runSync('python3', <String>[
      repoFile('tools/gates/check_dependency_allowlist.py').path,
      '--deps',
      repoFile('tools/gates/testdata/deps/$fixture').path,
      '--allowlist-dir',
      allowlistDir ?? liveAllowlist(),
    ], workingDirectory: repoRoot().path);

void main() {
  test('Allowlist gate accepts the recorded graph', () {
    final ProcessResult r = runGate(fixture: 'deps_clean.json');
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
  });

  test('Allowlist gate rejects a direct dependency absent from the allowlist', () {
    final ProcessResult r = runGate(fixture: 'deps_extra_direct.json');
    expect(r.exitCode, 1);
    expect(r.stdout, contains('some_new_package'));
  });

  test('Allowlist gate rejects an allowlisted dependency missing from the graph', () {
    final ProcessResult r = runGate(fixture: 'deps_missing_direct.json');
    expect(
      r.exitCode,
      1,
      reason: 'an allowlist that no longer describes the app is not evidence about it',
    );
  });

  test('Allowlist gate rejects http as a direct dependency', () {
    final ProcessResult r = runGate(fixture: 'deps_direct_http.json');
    expect(r.exitCode, 1);
    expect(r.stdout, contains('http'));
  });

  test('Allowlist gate accepts http parented by exactly printing and flutter_svg', () {
    final ProcessResult r = runGate(
      fixture: 'deps_two_http_edges.json',
      allowlistDir: fixtureAllowlist('future'),
    );
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
  });

  test('Allowlist gate rejects http with a third parent', () {
    final ProcessResult r = runGate(
      fixture: 'deps_third_http_edge.json',
      allowlistDir: fixtureAllowlist('future_third_edge'),
    );
    expect(r.exitCode, 1);
    expect(
      r.stdout,
      contains('some_widget_pack'),
      reason: 'SPEC.md §14: a third edge fails, and the message must name it',
    );
  });

  test('Allowlist gate accepts http reachable only through dev_dependencies', () {
    final ProcessResult r = runGate(
      fixture: 'deps_dev_only_http.json',
      allowlistDir: fixtureAllowlist('future_dev_http'),
    );
    expect(
      r.exitCode,
      0,
      reason:
          'build_runner pulls a local HTTP server for watch mode; a gate that '
          'fails on that gets switched off',
    );
  });

  test(
    'Allowlist gate rejects url_launcher_platform_interface with a parent other than share_plus',
    () {
      final ProcessResult r = runGate(
        fixture: 'deps_bad_url_launcher_edge.json',
        allowlistDir: fixtureAllowlist('future'),
      );
      expect(r.exitCode, 1);
    },
  );

  test('Allowlist gate fails when the allowlist file is empty', () {
    final Directory empty = Directory.systemTemp.createTempSync('catchlaw_allowlist');
    addTearDown(() => empty.deleteSync(recursive: true));
    File('${empty.path}/direct_dependencies.txt').writeAsStringSync('');
    File('${empty.path}/transitive_edges.txt').writeAsStringSync('');
    final ProcessResult r = runGate(fixture: 'deps_clean.json', allowlistDir: empty.path);
    expect(
      r.exitCode,
      1,
      reason: 'a gate with nothing to compare against reports success — CONVENTIONS §7',
    );
  });

  test('Allowlist gate fails when the deps JSON cannot be parsed', () {
    final ProcessResult r = runGate(fixture: 'deps_truncated.json');
    expect(
      r.exitCode,
      isNot(0),
      reason: 'a silent parse failure is a green build over an unwalked graph',
    );
  });

  test('Allowlist file is sorted and deduplicated', () {
    final List<String> lines = repoFile(
      'tools/gates/allowlist/direct_dependencies.txt',
    ).readAsLinesSync().where((l) => l.trim().isNotEmpty && !l.startsWith('#')).toList();
    expect(lines, orderedEquals(<String>[...lines]..sort()));
    expect(lines.toSet(), hasLength(lines.length));
  });
}
