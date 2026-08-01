// D-7, PROVED rather than asserted.
//
// D-7 says this package returns values carrying numbers, enums, a required
// Citation and an isExpired flag, and contains no user-visible sentence in any
// language. check_verdict_contract.sh scans app/lib and app/lib/l10n, so NO
// SHIPPED GATE LOOKS AT THIS PACKAGE FOR WORDS — which is precisely why this
// task owes a test.

import 'dart:io';

import 'package:test/test.dart';

/// The whole verdict surface: everything in these two directories is an
/// integer, an enum, a bool or a Citation.
const _verdictDirs = <String>['lib/src/findings', 'lib/src/verdict'];

/// Field names that would mean the engine had started composing text.
const _bannedFieldNames = <String>['message', 'label', 'text', 'description', 'title', 'summary'];

List<File> _dartFiles() => <File>[
  for (final String d in _verdictDirs)
    ...Directory(
      d,
    ).listSync(recursive: true).whereType<File>().where((File f) => f.path.endsWith('.dart')),
];

/// Lines with directives and `//` comment tails removed.
Iterable<({String path, int line, String code})> _codeLines() sync* {
  for (final File f in _dartFiles()) {
    final List<String> lines = f.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final String raw = lines[i];
      final String trimmed = raw.trimLeft();
      if (trimmed.startsWith('import ') ||
          trimmed.startsWith('export ') ||
          trimmed.startsWith('part ') ||
          trimmed.startsWith('//')) {
        continue;
      }
      yield (path: f.path, line: i + 1, code: raw.replaceFirst(RegExp('//.*'), ''));
    }
  }
}

void main() {
  test('The verdict surface scan reads both directories', () {
    // CONVENTIONS.md §7: the two assertions below pass by finding NOTHING, so
    // an empty scan would report success over an empty tree.
    expect(_dartFiles(), hasLength(greaterThanOrEqualTo(6)));
    for (final String d in _verdictDirs) {
      expect(Directory(d).existsSync(), isTrue, reason: '$d must exist');
    }
  });

  test('No file under findings or verdict contains a string literal', () {
    // A statement about LITERALS, deliberately — about text the engine AUTHORS.
    // Two kinds of String still travel through and both are fine: ISO-8601
    // dates, and Citation.instrument and Citation.article, which are verbatim
    // references transcribed from a published instrument. Neither is composed
    // here and neither is localised.
    //
    // `throw` lines are excluded, and the exclusion is narrow on purpose. A
    // StateError or an ArgumentError is a PROGRAMMER error: it crashes the
    // process and is never rendered to anybody, so it is not a sentence about a
    // rule and no translator will ever see it. D-7 governs what the engine says
    // to a fisher. The count is capped below so this cannot quietly become the
    // hole every future literal is posted through.
    final offenders = <String>[
      for (final l in _codeLines())
        if (!l.code.contains('throw '))
          if (RegExp("'[^']*'|\"[^\"]*\"").hasMatch(l.code)) '${l.path}:${l.line} ${l.code.trim()}',
    ];
    expect(
      offenders,
      isEmpty,
      reason:
          'the engine has nothing to hand a translator and nothing to compose a '
          'sentence out of:\n${offenders.join('\n')}',
    );
  });

  test('The throw-line exclusion covers no more than two programmer errors', () {
    // The exclusion above is only defensible while it is small. If a third
    // throw appears, somebody must look at it rather than inherit the carve-out.
    final thrown = <String>[
      for (final l in _codeLines())
        if (l.code.contains('throw ') && RegExp("'[^']*'").hasMatch(l.code)) '${l.path}:${l.line}',
    ];
    expect(thrown, hasLength(lessThanOrEqualTo(2)), reason: thrown.join('\n'));
  });

  test('No field under findings or verdict is named like display text', () {
    // Pins the distinction by field name, so a String that IS legitimate
    // cannot quietly become a String that is not.
    final offenders = <String>[
      for (final l in _codeLines())
        for (final String name in _bannedFieldNames)
          if (RegExp('\\b(String|String\\?)\\s+$name\\b').hasMatch(l.code))
            '${l.path}:${l.line} $name',
    ];
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
