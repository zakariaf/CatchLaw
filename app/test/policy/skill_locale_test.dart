import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'repo_root.dart';

/// The four files E01/T09 corrects. D-3 names the first three; D-4 the builder.
const correctedFiles = <String>[
  '.claude/skills/catchlaw-conventions-index/SKILL.md',
  '.claude/skills/catchlaw-conventions-index/references/routing-table.md',
  '.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh',
  '.claude/skills/catchlaw-verdict-contract/SKILL.md',
];

/// D-3. Catalan ships; Urdu does not. The region travels on Portuguese.
const shippedArb = <String>[
  'app_ar.arb',
  'app_en.arb',
  'app_es.arb',
  'app_gl.arb',
  'app_ca.arb',
  'app_pt_BR.arb',
];

final _staleLocale = RegExp(r'app_ur\.arb|\bUrdu\b');
final _staleBuilder = RegExp(r'content_build(?!er)|packages/content_build');
final _stalePt = RegExp(r'app_pt\.arb');

String frontmatterDescription(String path) {
  final String raw = repoFile(path).readAsStringSync();
  return (loadYaml(raw.split('---')[1]) as YamlMap)['description'] as String;
}

/// `<path> <epic>` lines: the files that legitimately still carry the old wording.
Set<String> recordedDrift() => repoFile('tools/gates/known_skill_drift.txt')
    .readAsLinesSync()
    .map((l) => l.split('#').first.trim())
    .where((l) => l.isNotEmpty)
    .map((l) => l.split(RegExp(r'\s+')).first)
    .toSet();

void main() {
  test('The four corrected skill files name no Urdu ARB or Urdu RTL lane', () {
    final offenders = <String>[
      for (final p in correctedFiles)
        if (_staleLocale.hasMatch(repoFile(p).readAsStringSync())) p,
    ];
    expect(
      offenders,
      isEmpty,
      reason:
          'D-3: Urdu appears nowhere in SPEC.md and no bundled instrument is '
          'published in it:\n${offenders.join('\n')}',
    );
  });

  test('The four corrected skill files name every ARB file with its full locale', () {
    final offenders = <String>[
      for (final p in correctedFiles)
        if (_stalePt.hasMatch(repoFile(p).readAsStringSync())) p,
    ];
    expect(
      offenders,
      isEmpty,
      reason:
          'D-3: the region travels because the content is Brazilian, not Iberian:\n'
          '${offenders.join('\n')}',
    );
    final String index = repoFile(correctedFiles.first).readAsStringSync();
    expect(
      shippedArb.where(index.contains),
      hasLength(shippedArb.length),
      reason: 'rule 12 must list all six',
    );
  });

  test('The four corrected skill files name the content builder as content_builder', () {
    final offenders = <String>[
      for (final p in correctedFiles)
        if (_staleBuilder.hasMatch(repoFile(p).readAsStringSync())) p,
    ];
    expect(offenders, isEmpty, reason: 'D-4: one name:\n${offenders.join('\n')}');
  });

  test('catchlaw-conventions-index frontmatter description stays within the CI bound', () {
    final String d = frontmatterDescription(correctedFiles.first);
    expect(
      d.length,
      inInclusiveRange(200, 1024),
      reason:
          "validate.yml's skills job fails outside this range — breaking a CI job "
          'while correcting a document is the mistake this test is for',
    );
    expect(d, isNot(anyOf(contains('<'), contains('>'))));
  });

  test('check_app_invariants.sh still scans every ARB file regardless of locale', () {
    final String script = repoFile(correctedFiles[2]).readAsStringSync();
    // The task file predicted two occurrences; the script ships one. The number
    // was never the contract — LOCALE-AGNOSTICISM is. So this pins both halves:
    // the wildcard include survives, and no locale-specific include appears
    // beside it. The edit in this task is a report LABEL; a narrowed --include
    // would stop the gate seeing locales while it kept printing a label that
    // claims it sees them.
    expect(
      "--include='*.arb'".allMatches(script).length,
      1,
      reason: 'the wildcard ARB include must survive any edit to the label',
    );
    expect(
      RegExp(r"--include='app_[a-zA-Z_]*\.arb'").hasMatch(script),
      isFalse,
      reason: 'a per-locale include would silently stop the gate scanning the rest',
    );
  });

  test('Files still carrying the pre-decision wording are exactly those recorded in '
      'known_skill_drift.txt', () {
    final Set<String> actual = repoDir('.claude/skills')
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path.replaceFirst('${repoRoot().path}/', ''))
        .where((p) {
          final String t = repoFile(p).readAsStringSync();
          return _staleLocale.hasMatch(t) ||
              _staleBuilder.hasMatch(t) ||
              _stalePt.hasMatch(t) ||
              RegExp(r"'ur'|`ur`").hasMatch(t);
        })
        .toSet();
    expect(
      actual,
      recordedDrift(),
      reason:
          'either this task left one of its four files unfixed, or a later change '
          'introduced the pre-decision wording into a file with no owning epic',
    );
  });
}
