import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// `flutter test` runs with the package root as its working directory, which is
// `app/` — so both the gate and its fixtures are one level up.
const String _gate = '../tools/gates/no_directional_geometry.sh';
const String _fixtures = '../tools/gates/testdata/directional';

ProcessResult _run(String target) => Process.runSync(_gate, <String>[target]);

void main() {
  test('no_directional_geometry.sh exits 2 when the target directory does not exist', () {
    // D-1 and CONVENTIONS.md §7: a gate that exits 0 on a typo'd path is a gate
    // that never ran, and nothing downstream can tell the difference.
    expect(_run('$_fixtures/does_not_exist').exitCode, 2);
  });

  test('no_directional_geometry.sh exits 1 when it scans zero Dart files', () {
    expect(
      _run('$_fixtures/no_dart_files').exitCode,
      1,
      reason: 'a gate that scans nothing must not report success',
    );
  });

  // One row per banned construct; the fixture directory names the case, so a
  // failure says which construct stopped being caught.
  for (final fixture in const <String>[
    'edge_insets_only_left',
    'edge_insets_only_right',
    'edge_insets_from_ltrb',
    'alignment_center_left',
    'alignment_top_right',
    'positioned_left',
    'text_align_right',
    'border_radius_top_left',
    'icons_arrow_back',
    'directionality',
  ]) {
    test('no_directional_geometry.sh exits 1 for $fixture', () {
      final ProcessResult r = _run('$_fixtures/$fixture');
      expect(r.exitCode, 1, reason: r.stdout.toString());
      expect(
        r.stdout.toString(),
        contains('offender.dart'),
        reason: 'a gate that fails without naming the file is a gate nobody can act on',
      );
    });
  }

  for (final fixture in const <String>[
    'edge_insets_symmetric',
    'edge_insets_directional',
    'hatched_line',
    'hatched_above',
    'generated_file',
  ]) {
    test('no_directional_geometry.sh exits 0 for $fixture', () {
      final ProcessResult r = _run('$_fixtures/$fixture');
      expect(r.exitCode, 0, reason: r.stdout.toString());
    });
  }

  test('no_directional_geometry.sh exits 0 over app/lib', () {
    final ProcessResult r = _run('lib');
    expect(r.exitCode, 0, reason: r.stdout.toString());
  });

  test('no_directional_geometry.sh reports the number of files it scanned', () {
    // A human reading a green log must be able to see that it scanned
    // something. Thirteen of the sixteen skill gates cannot say this.
    expect(_run('lib').stdout.toString(), matches(RegExp(r'scanned [1-9][0-9]* dart files')));
  });

  test('the only directional escape hatch in app/lib is the ruler instrument', () {
    // E06/T05 asserted this was EMPTY and named the file that would first earn
    // a marker. E09/T04 is that file: SPEC.md §9.3's one documented exception,
    // the ruler, which is an instrument rather than a layout — a mirrored scale
    // puts zero at the tail of a real fish.
    //
    // The assertion is now "exactly this one file", which is stronger than
    // "none": a second hatch anywhere is a physical inset swept under a rug,
    // and it fails here rather than in a golden six epics later.
    final List<String> hatched = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .where((File f) => f.readAsStringSync().contains('catchlaw-directional-ok'))
        .map((File f) => f.path)
        .toList();
    expect(hatched, <String>['lib/ui/ruler/widgets/ltr_instrument.dart']);
  });
}
