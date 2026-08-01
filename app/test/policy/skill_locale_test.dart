import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'repo_root.dart';

/// The conventions index — the front door, and the one file that must LIST the
/// six ARB names rather than merely avoid the wrong ones.
const conventionsIndex = '.claude/skills/catchlaw-conventions-index/SKILL.md';
const invariantsGate = '.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh';

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
final _staleUr = RegExp("'ur'|`ur`");

/// Every file under `.claude/skills/`, read once. The vendored general skills
/// live in `.claude/skills-flutter/` (D-13) and are deliberately out of scope:
/// they are upstream's text, corrected upstream.
final Map<String, String> _skillFiles = {
  for (final f in repoDir('.claude/skills').listSync(recursive: true).whereType<File>())
    f.path.replaceFirst('${repoRoot().path}/', ''): f.readAsStringSync(),
};

/// Skill files matching [pattern]. The whole tree, never a hand-kept list: a
/// per-decision test that names its own files can only ever find what its author
/// already knew about, which is how six files sat stale behind four green tests.
Set<String> staleFiles(RegExp pattern) => {
  for (final e in _skillFiles.entries)
    if (pattern.hasMatch(e.value)) e.key,
};

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
  test('The skill scan reads the sixteen app skills and not the vendored ones', () {
    // Five tests below pass by finding NOTHING. If this scan ever reads an empty
    // tree — a renamed directory, a typo, a checkout without .claude — every one
    // of them goes green over nothing, which is CONVENTIONS.md §7's failure
    // arriving through a test instead of a gate. So the count is the evidence.
    final Set<String> skills = {for (final p in _skillFiles.keys) p.split('/')[2]};
    expect(skills, hasLength(16), reason: 'CONVENTIONS.md §7: exactly sixteen (D-13)');
    expect(
      _skillFiles.keys.where((p) => p.contains('skills-flutter')),
      isEmpty,
      reason: "D-13: the vendored 33 are upstream's text, corrected upstream",
    );
    expect(_skillFiles.length, greaterThan(60));
  });

  test('No skill file names an Urdu ARB or an Urdu RTL lane', () {
    expect(
      staleFiles(_staleLocale),
      isEmpty,
      reason:
          'D-3: Urdu appears nowhere in SPEC.md and no bundled instrument is '
          'published in it. There is one RTL locale, ar.',
    );
  });

  test('No skill file names a bare ur locale', () {
    expect(
      staleFiles(_staleUr),
      isEmpty,
      reason:
          'D-3: the sixth locale is ca, not ur. SPEC.md §9.5 line 815 names the '
          'gendered set — ar, es, gl, ca, pt_BR — and §9.1 line 840 gives '
          "Catalan's justification, so neither was ever an open question.",
    );
  });

  test('No skill file names a region-less Portuguese ARB', () {
    expect(
      staleFiles(_stalePt),
      isEmpty,
      reason: 'D-3: the region travels because the content is Brazilian, not Iberian',
    );
  });

  test('The conventions index lists all six shipped ARB files', () {
    final String index = _skillFiles[conventionsIndex]!;
    expect(
      shippedArb.where(index.contains),
      hasLength(shippedArb.length),
      reason: 'rule 12 must list all six',
    );
  });

  test('No skill file names the content builder as content_build', () {
    expect(
      staleFiles(_staleBuilder),
      isEmpty,
      reason:
          'D-4: one name — directory tools/content_builder, package '
          'content_builder, executable `dart run content_builder:build`',
    );
  });

  test('catchlaw-conventions-index frontmatter description stays within the CI bound', () {
    final String d = frontmatterDescription(conventionsIndex);
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
    final String script = _skillFiles[invariantsGate]!;
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
    final Set<String> actual = {
      ...staleFiles(_staleLocale),
      ...staleFiles(_staleBuilder),
      ...staleFiles(_stalePt),
      ...staleFiles(_staleUr),
    };
    expect(
      actual,
      recordedDrift(),
      reason:
          'The register is EMPTY as of the E01 close-out, so this now asserts that '
          'no skill file carries the pre-decision wording at all. A failure here '
          'means a later change reintroduced it into a file with no owning epic. '
          'The four tests above name which decision was broken; this one is the '
          'accumulator that no per-decision test can be forgotten from.',
    );
  });
}
