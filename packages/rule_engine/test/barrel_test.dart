import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('rule_engine exposes exactly one library directly under lib', () {
    final List<String> top = Directory('lib')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.endsWith('.dart'))
        .toList();
    expect(
      top,
      ['rule_engine.dart'],
      reason:
          'FLUTTER_GUIDE.md Part 2.6 sanctions exactly one barrel in the '
          'repository and no other; everything else belongs under lib/src/, '
          'which no other package may import',
    );
  });

  test('rule_engine barrel carries a library-level doc comment', () {
    final List<String> lines = File('lib/rule_engine.dart').readAsLinesSync();
    expect(
      lines.first.startsWith('///'),
      isTrue,
      reason:
          'the library doc comment is the highest-ROI documentation in a package '
          'with two consumers (FLUTTER_GUIDE.md Part 2.5)',
    );
    expect(lines.where((l) => l.trim() == 'library;'), hasLength(1));
  });
}
