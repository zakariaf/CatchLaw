import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app/lib holds no top-level or static final NumberFormat', () {
    // A retained NumberFormat captures its symbols at construction and survives
    // every later applyNumeralSystem call (FLUTTER_GUIDE.md Part 9.1). One grep
    // is what makes "constructed at the point of use" true rather than
    // aspirational — and its job starts in E08, not here.
    final List<File> dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .toList();
    expect(dartFiles, isNotEmpty, reason: 'a scan over no files is not evidence about any of them');

    final offenders = <String>[];
    for (final file in dartFiles) {
      final List<String> lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'^\s*(static\s+)?final\s+NumberFormat\b').hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: 'construct through numberFormatFor at the point of use; never retain',
    );
  });

  test('numberFormatSymbols is touched by exactly one file under app/lib', () {
    // The blast radius of the process-wide mutation, as a fact about the tree.
    //
    // Comments are stripped first. Two table files cross-reference the symbol
    // by name to explain what `user_profile.numeral_system` does, and a scan
    // that cannot tell a prohibition from its rationale forces the rationale
    // out of the file — which is the opposite of what this test is for.
    final List<String> hits = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .where((File f) => _withoutComments(f.readAsStringSync()).contains('numberFormatSymbols'))
        .map((File f) => f.path)
        .toList();
    expect(hits, <String>['lib/l10n/numeral_system.dart']);
  });
}

String _withoutComments(String source) =>
    source.split('\n').where((String l) => !l.trimLeft().startsWith('//')).join('\n');
