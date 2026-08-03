// SPEC.md §9.5: millimetres are the ONLY stored unit, and the display unit is a
// separate decision. A structural proof, because the failure it prevents is one
// nobody notices until two screens disagree about the same fish.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

List<File> _dartFilesUnder(String path) => Directory(path)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
    .toList();

String _withoutComments(String source) =>
    source.split('\n').where((String l) => !l.trimLeft().startsWith('//')).join('\n');

void main() {
  test('no column stores a length as a real or a text', () {
    // A length held as a double is a length that rounds differently on two
    // devices; a length held as text is one that has been through a locale's
    // separators. check_measurement check 1 greps for exactly this, and this
    // row is what makes the claim readable where a developer will meet it.
    // A column whose name ends in `Unit` stores which unit to DISPLAY in, not
    // a length — the storage unit is never a choice. The real gate exempts it
    // by its documented hatch; this row excludes it by shape.
    final softLength = RegExp(r'(RealColumn|TextColumn)\s+get\s+\w*[Ll]ength(?!Unit)\w*\s*=>');
    for (final File file in _dartFilesUnder('lib/data/services/tables')) {
      expect(
        softLength.hasMatch(_withoutComments(file.readAsStringSync())),
        isFalse,
        reason: file.path,
      );
    }
  });

  test('the inch factor is named in exactly one place', () {
    // A rounded 25.4 in one file and a 25 in another is a fish that measures
    // differently on two screens.
    final List<String> holders = _dartFilesUnder('lib')
        .where((File f) => _withoutComments(f.readAsStringSync()).contains('25.4'))
        .map((File f) => f.path)
        .toList();
    expect(holders, <String>['lib/domain/models/length_display.dart']);
  });

  test('every length the domain layer carries is an int', () {
    // The measurement draft, the rule hint and the catch record all hold
    // millimetres. A double anywhere in that chain is a rounding difference
    // waiting for a legal minimum.
    // A FIELD, not a factor: kMillimetresPerInch is legitimately a double, and
    // this row is about what a length is held as rather than what it is
    // divided by.
    final doubleLength = RegExp(r'\bdouble\s+(\w*[Ll]engthMm|millimetres)\b');
    for (final File file in _dartFilesUnder('lib/domain')) {
      expect(
        doubleLength.hasMatch(_withoutComments(file.readAsStringSync())),
        isFalse,
        reason: file.path,
      );
    }
  });
}
