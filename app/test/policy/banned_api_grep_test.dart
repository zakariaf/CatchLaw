import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'repo_root.dart';

/// The fifteen needles of SPEC.md §14, in the order the spec prints them.
const spec14Needles = <String>[
  'package:http',
  'package:dio',
  'HttpClient',
  'Socket',
  'WebSocket',
  'firebase',
  'connectivity_plus',
  'PdfGoogleFonts',
  'SvgPicture.network',
  'Image.network',
  'NetworkImage',
  'url_launcher',
  'launchUrl',
  'AndroidIntent',
  'ACTION_VIEW',
];

/// The banned dart:io symbols of four-layers.md "Layer 4 — the dart:io split".
const layer4Symbols = <String>[
  'HttpClient',
  'HttpServer',
  'HttpOverrides',
  'Socket',
  'RawSocket',
  'SecureSocket',
  'ServerSocket',
  'WebSocket',
  'InternetAddress',
  'NetworkInterface',
  'RawDatagramSocket',
  'SecurityContext',
];

ProcessResult runGate(String target) => Process.runSync('bash', <String>[
  repoFile('tools/gates/no_banned_apis.sh').path,
  target,
], workingDirectory: repoRoot().path);

String fixture(String name) => repoDir('tools/gates/testdata/banned_api/$name').path;

String guardSource() => repoFile('app/test/no_network_test.dart').readAsStringSync();

/// Every `RegExp(r'...')` pattern the guard declares, compiled.
///
/// Test 1 asks whether the guard still CATCHES each symbol, not whether the
/// symbol appears in its text: four of the twelve — HttpServer, HttpOverrides,
/// SecureSocket, ServerSocket — are covered only by an alternation
/// (`Http(Client|Server|Overrides)`, `(Raw|Secure|Server)?Socket`) and appear
/// nowhere as literals. A substring check would fail against a correct guard.
List<RegExp> guardPatterns() => RegExp(
  r"RegExp\(r'([^']*)'\)",
).allMatches(guardSource()).map((m) => RegExp(m.group(1)!)).toList();

void main() {
  test('Guard test bans every dart:io networking symbol named in four-layers.md', () {
    final List<RegExp> patterns = guardPatterns();
    expect(patterns, isNotEmpty, reason: 'no RegExp patterns found in the guard');
    final List<String> missing = layer4Symbols
        .where((s) => !patterns.any((re) => re.hasMatch('final x = $s();')))
        .toList();
    expect(
      missing,
      isEmpty,
      reason: 'the guard drifted from the table it was copied from:\n${missing.join('\n')}',
    );
  });

  test('Guard test leaves File, Directory and Platform legal', () {
    for (final allowed in <String>['File', 'Directory', 'Platform']) {
      expect(
        guardSource(),
        isNot(contains("r'\\b$allowed\\b'")),
        reason: 'a wholesale dart:io ban is unenforceable and gets waived in week two',
      );
    }
  });

  test('Guard test fails when app/lib is empty', () {
    expect(
      guardSource(),
      contains('the guard would pass vacuously'),
      reason: 'the setUpAll emptiness assertion is what stops a vacuous green',
    );
  });

  for (final String needle in spec14Needles) {
    test('Banned-API gate rejects $needle', () {
      final ProcessResult r = runGate(
        fixture('needle_${needle.replaceAll(RegExp('[^a-zA-Z]'), '_')}'),
      );
      expect(r.exitCode, 1, reason: '${r.stdout}\n${r.stderr}');
      expect(r.stderr, contains(needle));
    });
  }

  test('Banned-API gate ignores a needle that appears only in a comment', () {
    final ProcessResult r = runGate(fixture('comment_only'));
    expect(r.exitCode, 0, reason: "the gate's own header names all fifteen needles:\n${r.stderr}");
  });

  test('Banned-API gate ignores a needle on a line carrying // no-network-ok', () {
    expect(runGate(fixture('escaped')).exitCode, 0);
  });

  test('Banned-API gate matches Socket as a whole word only', () {
    final ProcessResult r = runGate(fixture('socket_path_label'));
    expect(
      r.exitCode,
      0,
      reason:
          'socketPathLabel is the documented false positive; a gate that cries '
          'wolf gets deleted:\n${r.stderr}',
    );
  });

  test('Banned-API gate reports every offender, not the first', () {
    final ProcessResult r = runGate(fixture('three_offenders'));
    expect(r.exitCode, 1);
    // Count the ::error annotations, not every line naming the fixture: the
    // gate's own summary header names the target directory too.
    expect(
      '${r.stderr}'.split('\n').where((l) => l.startsWith('::error')).length,
      3,
      reason:
          'reporting offender #1 and hiding the rest teaches people to fix one '
          'line per push:\n${r.stderr}',
    );
  });

  test('Banned-API gate exits 2 when the target directory does not exist', () {
    expect(runGate('no/such/dir').exitCode, 2);
  });

  test('Banned-API gate exits 2 when the target directory holds no Dart file', () {
    final Directory empty = Directory.systemTemp.createTempSync('catchlaw_empty_target');
    addTearDown(() => empty.deleteSync(recursive: true));
    expect(
      runGate(empty.path).exitCode,
      2,
      reason: 'a gate that scans a path with no files reports success — CONVENTIONS §7',
    );
  });
}
