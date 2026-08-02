@Tags(<String>['golden'])
library;

import 'dart:io' show Platform;

import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/l10n/number_symbols_guard.dart';
import '../../support/golden.dart';
import 'numeral_specimen.dart';

/// Why a pixel row does not run here.
///
/// `FLUTTER_GUIDE.md` §6.4 point 2: font rasterisation, subpixel positioning
/// and antialiasing differ per host and per engine revision, so ONE
/// environment is the source of truth or the files never stop moving. That
/// environment is the Linux lane in `validate.yml`.
///
/// A visible skip and not a silent pass: a developer on macOS is told these
/// rows were not verified, rather than being shown a green tick that means
/// nothing about the bytes in git.
const String _hostSkipReason =
    'goldens are generated and verified on Linux only (FLUTTER_GUIDE.md §6.4 point 2)';

/// Whether this host may speak about pixels. Reports the skip out loud —
/// `testWidgets` takes only a `bool` skip, so the reason is announced from
/// inside the body instead.
bool _skippedOffLinux() {
  if (Platform.isLinux) return false;
  markTestSkipped(_hostSkipReason);
  return true;
}

void main() {
  setUp(captureNumberSymbols);
  tearDown(restoreNumberSymbols);

  for (final locale in const <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('gl'),
    Locale('ca'),
    Locale('pt', 'BR'),
  ]) {
    final String tag = localeTag(locale);
    testWidgets('NumeralSpecimen matches its golden for $tag', (WidgetTester tester) async {
      if (_skippedOffLinux()) return;
      tester.useDevice(Device.small);
      await tester.pumpLocalised(const NumeralSpecimen(), locale);
      await expectLater(
        find.byType(NumeralSpecimen),
        matchesGoldenFile('goldens/numeral_specimen_$tag.png'),
      );
    });
  }

  testWidgets('ar - NumeralSpecimen matches its golden under NumeralSystem.arab', (
    WidgetTester tester,
  ) async {
    if (_skippedOffLinux()) return;
    // The only image in the matrix that shows U+0660–U+0669. If E06/T04's lever
    // regresses, this is what says so in pixels.
    applyNumeralSystem(NumeralSystem.arab);
    tester.useDevice(Device.small);
    await tester.pumpLocalised(const NumeralSpecimen(), const Locale('ar'));
    await expectLater(
      find.byType(NumeralSpecimen),
      matchesGoldenFile('goldens/numeral_specimen_ar_arab.png'),
    );
  });
}
