import 'dart:io';

import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/l10n/number_symbols_guard.dart';

/// Deliberately **not** tagged `golden`.
///
/// It renders nothing. Tagging it would exclude the one file that checks the
/// lane's own rules from the everyday run, which is where a broken rule would
/// otherwise sit unnoticed until the next Linux job.
Directory get _lane => Directory('test/l10n/golden');

File get _workflow => File('../.github/workflows/validate.yml');

void main() {
  test('the l10n golden lane holds at most 12 images', () {
    // CONVENTIONS.md §6 budgets 4–6 screens × 6 locales × 2 themes for the
    // WHOLE product. That budget dies one image at a time, so the ceiling is a
    // number somebody has to change in a diff.
    final List<File> images = Directory(
      '${_lane.path}/goldens',
    ).listSync().whereType<File>().where((File f) => f.path.endsWith('.png')).toList();
    expect(images, isNotEmpty, reason: 'a lane with no images is not a lane');
    expect(images.length, lessThanOrEqualTo(12), reason: '${images.length} images');
  });

  test('every test file under test/l10n/golden carries the golden tag', () {
    // An untagged golden runs in the everyday lane, on whatever host a
    // developer happens to have, and churns on font rasterisation.
    final List<File> suites = _lane
        .listSync()
        .whereType<File>()
        .where((File f) => f.path.endsWith('_test.dart'))
        .where((File f) => f.path != '${_lane.path}/golden_hygiene_test.dart')
        .toList();
    expect(suites, isNotEmpty, reason: 'a scan over no files proves nothing');
    for (final suite in suites) {
      expect(suite.readAsStringSync(), contains("@Tags(<String>['golden'])"), reason: suite.path);
    }
  });

  test('the ci workflow runs the golden lane on ubuntu only', () {
    // FLUTTER_GUIDE.md §6.4 point 2: font rasterisation, subpixel positioning
    // and antialiasing differ per host and per engine revision. One environment
    // is the source of truth or the files never stop moving.
    final List<String> lines = _workflow.readAsLinesSync();
    final int step = lines.indexWhere((String l) => l.contains('--tags golden'));
    expect(step, greaterThanOrEqualTo(0), reason: 'no golden lane in the workflow');
    final String job = lines.sublist(0, step).lastWhere((String l) => l.contains('runs-on:'));
    expect(job, contains('ubuntu'));
  });

  test('the ci workflow never passes --update-goldens', () {
    // A blessing step turns the suite into a ratchet that approves whatever
    // shipped. Regeneration is a deliberate, reviewed, local act.
    //
    // Comments are stripped first: the workflow says in prose WHY it does not
    // bless, and a scan that cannot tell a prohibition from its rationale
    // forces the rationale out of the file.
    final String runnable = _workflow
        .readAsLinesSync()
        .where((String l) => !l.trimLeft().startsWith('#'))
        .join('\n');
    expect(runnable, isNot(contains('--update-goldens')));
  });

  test('the everyday lane excludes the golden tag', () {
    expect(_workflow.readAsStringSync(), contains('--exclude-tags golden'));
  });

  test('OFL.txt ships beside the font files', () {
    // SPEC.md §8: bundling is permitted BECAUSE the files are not renamed and
    // the licence text ships. A licence obligation, not a nicety.
    final ofl = File('assets/fonts/OFL.txt');
    expect(ofl.existsSync(), isTrue);
    expect(ofl.readAsStringSync(), contains('SIL OPEN FONT LICENSE'));
    expect(File('assets/fonts/NotoSans-Regular.ttf').existsSync(), isTrue);
    expect(File('assets/fonts/NotoNaskhArabic-Regular.ttf').existsSync(), isTrue);
  });

  test('numberSymbolsArePristine reports false when the ar entry was replaced', () {
    // The guard flutter_test_config.dart installs, tested directly rather than
    // by staging a corrupted run and hoping to notice it.
    captureNumberSymbols();
    addTearDown(restoreNumberSymbols);
    expect(numberSymbolsArePristine(), isTrue);
    applyNumeralSystem(NumeralSystem.arab);
    expect(numberSymbolsArePristine(), isFalse);
  });
}
