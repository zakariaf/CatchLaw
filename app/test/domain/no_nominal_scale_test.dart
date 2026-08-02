import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

List<File> _dartFilesUnder(String path) => Directory(
  path,
).listSync(recursive: true).whereType<File>().where((File f) => f.path.endsWith('.dart')).toList();

String _withoutComments(String source) =>
    source.split('\n').where((String l) => !l.trimLeft().startsWith('//')).join('\n');

void main() {
  test('kNominalPxPerMm is read only where a drag handle is positioned', () {
    // check_measurement.sh check 5 fails a hardcoded px-per-mm, and it is right
    // to: a constant scale is a saved 40% error. This constant carries the
    // gate's documented hatch, and the hatch is only honest if the claim beside
    // it — "a handle position, never a scale" — is enforced rather than
    // asserted.
    //
    // So: no file that performs a pixels-to-millimetres division may name it.
    // The one shared transform lives on RulerCalibration, which is built from a
    // MEASURED scale and cannot see this constant.
    final List<File> readers = _dartFilesUnder('lib')
        .where((File f) => !f.path.endsWith('id1_card.dart'))
        .where((File f) => _withoutComments(f.readAsStringSync()).contains('kNominalPxPerMm'))
        .toList();

    for (final file in readers) {
      final String source = _withoutComments(file.readAsStringSync());
      expect(
        source.contains('millimetresFor') || source.contains('/ pxPerMm'),
        isFalse,
        reason: '${file.path} both names the nominal scale and converts with one',
      );
    }
  });

  test('the shared transform divides by a measured scale and nothing else', () {
    // RulerCalibration.millimetresFor is the ONE conversion. If a second one
    // appears, this row is what says so before a painter and a readout start
    // disagreeing about the same fish.
    final List<File> dividers = _dartFilesUnder(
      'lib',
    ).where((File f) => _withoutComments(f.readAsStringSync()).contains('/ pxPerMm')).toList();
    expect(dividers.map((File f) => f.path), <String>['lib/domain/models/ruler_calibration.dart']);
  });
}
