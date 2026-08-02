import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every directory a Lonja gate is pointed at, and what it must contain before
/// that gate's green means anything.
const Map<String, String> _targets = <String, String>{
  'lib/theme': 'the palette, the ramp and the button style',
  'lib/ui/core/ui': 'the four Lonja components',
};

int _dartFilesUnder(String path) => Directory(
  path,
).listSync(recursive: true).whereType<File>().where((File f) => f.path.endsWith('.dart')).length;

void main() {
  // CONVENTIONS.md §7: a gate pointed at a path with no files reports success,
  // which makes it worse than no gate — the green is now evidence of nothing.
  // check_lonja_tokens.sh app/lib was green from E01 over a tree with almost no
  // colour in it. This epic is the first that gives those gates something real
  // to find, so this is where the non-empty scan stops being assumed.
  _targets.forEach((String path, String what) {
    test('the gate target $path holds $what', () {
      expect(Directory(path).existsSync(), isTrue, reason: path);
      expect(_dartFilesUnder(path), greaterThan(0), reason: path);
    });
  });

  test('lib/theme holds the six files the Lonja gates read', () {
    for (final file in const <String>[
      'lib/theme/lonja_primitives.dart',
      'lib/theme/lonja_tokens.dart',
      'lib/theme/lonja_theme.dart',
      'lib/theme/lonja_faces.dart',
      'lib/theme/lonja_typography.dart',
      'lib/theme/lonja_button_style.dart',
    ]) {
      expect(File(file).existsSync(), isTrue, reason: file);
    }
  });

  test('app/lib declares a colour, a TextStyle and a button for the gates to find', () {
    // The three constructs check_lonja_tokens, check_lonja_type and
    // check_lonja_buttons exist to police. Until this epic there was one of
    // none of them, so all three gates were scanning for something that could
    // not be present.
    final String theme = File('lib/theme/lonja_primitives.dart').readAsStringSync();
    expect(theme, contains('Color(0x'));
    expect(File('lib/theme/lonja_typography.dart').readAsStringSync(), contains('TextStyle('));
    expect(File('lib/theme/lonja_button_style.dart').readAsStringSync(), contains('ButtonStyle('));
  });
}
