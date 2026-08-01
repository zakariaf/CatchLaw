// Layer 4 of the offline proof for this package (FLUTTER_GUIDE.md §4.6).
//
// Layer 1 is the compiler: pubspec.yaml declares no flutter key, so
// `import 'package:flutter/material.dart'` here is `Target of URI doesn't
// exist`. That guarantee is stronger than anything below. This file exists
// because the compile error only fires once somebody tries to build, and a
// named defect with a file and a line beats a resolution error nobody expects.
//
// Deliberately NOT a copy of app/test/no_network_test.dart. That file is a
// verbatim mirror of catchlaw-offline-guarantee's example and answers a
// different question — whether app code can reach a socket. This one answers
// whether this package can reach FLUTTER, which is what lets the content
// builder compile it under a plain `dart run` with no Flutter SDK installed.
//
// Escape hatch: a trailing `// no-network-ok` on a line that is provably fine.

import 'dart:io';

import 'package:test/test.dart';

const String _escapeHatch = 'no-network-ok';

/// Imports that would forfeit the compile-error guarantee of layer 1.
final Map<RegExp, String> _bannedImports = <RegExp, String>{
  RegExp(r'''package:flutter/'''): 'the Flutter framework',
  RegExp(r'''\bdart:ui\b'''): 'dart:ui, which only resolves inside the Flutter engine',
};

/// The networking half of `dart:io`, per SPEC.md §14's static block.
///
/// `File`, `Directory` and `Platform` are deliberately absent: a wholesale
/// `dart:io` ban is unenforceable, and this test file itself reads `lib/`.
final Map<RegExp, String> _bannedIdentifiers = <RegExp, String>{
  RegExp(r'\bHttp(Client|Server)\b'): 'HTTP client or server',
  RegExp(r'\b(Raw|Secure|Server)?Socket\b'): 'TCP socket',
  RegExp(r'\bRawDatagramSocket\b'): 'UDP socket',
  RegExp(r'\bWebSocket\b'): 'web socket',
  RegExp(r'\bInternetAddress\b'): 'DNS resolution',
  RegExp(r'\bNetworkInterface\b'): 'interface enumeration',
};

/// Packages that must never appear in this package's `pubspec.yaml`.
const List<String> _bannedPackages = <String>[
  'http',
  'dio',
  'web_socket_channel',
  'connectivity_plus',
  'firebase_core',
];

typedef _Violation = ({String file, int line, String detail});

String _render(List<_Violation> hits) =>
    hits.map((_Violation v) => '  ${v.file}:${v.line} — ${v.detail}').join('\n');

/// Every Dart file under `lib/`, sorted, as package-relative paths.
///
/// `dart test` runs with the package directory as the working directory, so
/// these resolve against `packages/rule_engine/`.
List<String> _libDartPaths() =>
    Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .map((File f) => f.path.replaceAll(r'\', '/'))
        .where((String p) => p.endsWith('.dart'))
        .toList()
      ..sort();

/// Scans [paths] for [patterns], ignoring `//` comment tails and escape hatches.
List<_Violation> _scan(List<String> paths, Map<RegExp, String> patterns) {
  final hits = <_Violation>[];
  for (final path in paths) {
    final List<String> lines = File(path).readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].contains(_escapeHatch)) continue;
      final String code = lines[i].replaceFirst(RegExp('//.*'), '');
      patterns.forEach((RegExp re, String why) {
        if (re.hasMatch(code)) {
          hits.add((file: path, line: i + 1, detail: '${re.pattern} — $why'));
        }
      });
    }
  }
  return hits;
}

void main() {
  group('rule_engine package', () {
    test('pubspec declares no flutter sdk dependency', () {
      expect(
        File('pubspec.yaml').readAsStringSync(),
        isNot(contains('sdk: flutter')),
        reason:
            'FLUTTER_GUIDE.md §4.6 layer 1: with no flutter key, package:flutter '
            'is a compile error here. That is what lets tools/content_builder '
            'compile this package with no Flutter SDK on the machine',
      );
    });

    test('pubspec declares no networking dependency', () {
      final List<String> lines = File('pubspec.yaml').readAsLinesSync();
      final hits = <_Violation>[
        for (var i = 0; i < lines.length; i++)
          if (!lines[i].trimLeft().startsWith('#'))
            if (_bannedPackages.contains(
              RegExp(r'^\s{2,}([a-z0-9_]+)\s*:').firstMatch(lines[i])?.group(1),
            ))
              (file: 'pubspec.yaml', line: i + 1, detail: 'banned by invariant 1'),
      ];
      expect(
        hits,
        isEmpty,
        reason: 'a transitive socket arrives through a direct dependency first:\n${_render(hits)}',
      );
    });

    test('lib holds exactly the expected Dart files', () {
      // Not a wildcard. CONVENTIONS.md §7: an empty scan reports success, so
      // tests 3 and 4 below are only worth their green tick if this set is
      // known. It grows one deliberate line per task, never automatically.
      expect(_libDartPaths(), <String>[
        'lib/rule_engine.dart',
        'lib/src/date.dart', // E03/T03
        'lib/src/engine_exception.dart', // E03/T02
        'lib/src/failure.dart', // E03/T02
        'lib/src/models/catch_tally.dart', // E03/T03
        'lib/src/models/citation.dart', // E03/T01
        'lib/src/models/closed_season.dart', // E03/T01
        'lib/src/models/landing.dart', // E03/T01
        'lib/src/models/measurement_method.dart', // E03/T01
        'lib/src/models/rule.dart', // E03/T01
        'lib/src/models/species.dart', // E03/T01
        'lib/src/models/zone.dart', // E03/T01
        'lib/src/resolve/candidate.dart', // E03/T03
        'lib/src/resolve/candidate_selection.dart', // E03/T03
        'lib/src/resolve/evaluation_request.dart', // E03/T03
        'lib/src/resolve/zone_match.dart', // E03/T04
        'lib/src/search/normalise.dart', // E02/T02
      ]);
    });

    test('lib imports no package:flutter and no dart:ui', () {
      final List<String> paths = _libDartPaths();
      expect(paths, isNotEmpty, reason: 'an empty scan reports success — CONVENTIONS.md §7');
      final List<_Violation> hits = _scan(paths, _bannedImports);
      expect(
        hits,
        isEmpty,
        reason:
            'layer 4 breached — one Flutter symbol stops the whole content build:\n'
            '${_render(hits)}',
      );
    });

    test('lib names no banned networking identifier', () {
      final List<String> paths = _libDartPaths();
      expect(paths, isNotEmpty, reason: 'an empty scan reports success — CONVENTIONS.md §7');
      final List<_Violation> hits = _scan(paths, _bannedIdentifiers);
      expect(hits, isEmpty, reason: 'SPEC.md §14 static block:\n${_render(hits)}');
    });

    test('analysis_options includes the workspace configuration', () {
      expect(
        File('analysis_options.yaml').readAsLinesSync(),
        contains(startsWith('include:')),
        reason:
            'FLUTTER_GUIDE.md §4.3, verified: a nested options file REPLACES the '
            'parent, so without this line the package silently loses strict-casts '
            'and every promoted error — and dart analyze still reports zero problems',
      );
    });

    test('analysis_options enables public_member_api_docs', () {
      expect(
        File('analysis_options.yaml').readAsStringSync(),
        contains('public_member_api_docs'),
        reason: 'two consumers make an undocumented public member real debt (§4.3)',
      );
    });
  });
}
