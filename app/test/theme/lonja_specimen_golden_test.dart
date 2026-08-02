@Tags(<String>['golden'])
library;

import 'dart:io' show Platform;

import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/lonja_specimen.dart';
import '../../testing/theme/pump_lonja.dart';
import '../support/golden.dart';

const String _hostSkipReason =
    'goldens are generated and verified on Linux only (FLUTTER_GUIDE.md §6.4 point 2)';

bool _skippedOffLinux() {
  if (Platform.isLinux) return false;
  markTestSkipped(_hostSkipReason);
  return true;
}

/// The specimen at one device size, tall enough for the whole sheet.
const Device _sheet = Device('specimen', Size(420, 1100), 2);

void main() {
  // Eight lanes, and the matrix stops there. CONVENTIONS.md §6 caps the golden
  // budget for the WHOLE product, and that budget dies one image at a time.
  for (final LonjaSkin skin in LonjaSkin.values) {
    for (final gloved in <bool>[false, true]) {
      final density = gloved ? 'glove' : 'standard';
      testWidgets('LonjaSpecimenSheet matches its golden for ${skin.name} at $density', (
        WidgetTester tester,
      ) async {
        if (_skippedOffLinux()) return;
        tester.useDevice(_sheet);
        await pumpLonja(tester, const LonjaSpecimenSheet(), skin: skin, gloved: gloved);
        await expectLater(
          find.byType(LonjaSpecimenSheet),
          matchesGoldenFile('goldens/specimen_${skin.name}_$density.png'),
        );
      });
    }
  }

  testWidgets('ar - LonjaSpecimenSheet matches its golden on the Naskh ramp', (
    WidgetTester tester,
  ) async {
    // The lane that proves the type ramp resolves per script rather than per
    // stylesheet. E06/T08 loads the font that makes it mean anything.
    if (_skippedOffLinux()) return;
    tester.useDevice(_sheet);
    await pumpLonja(tester, const LonjaSpecimenSheet(arabic: true), locale: const Locale('ar'));
    await expectLater(
      find.byType(LonjaSpecimenSheet),
      matchesGoldenFile('goldens/specimen_paper_ar.png'),
    );
  });

  testWidgets('greyscale - every button rung stays distinguishable without hue', (
    WidgetTester tester,
  ) async {
    // Paired with greyscale_proof_test.dart, which is what makes this image
    // EVIDENCE rather than a picture: a golden proves the frame rendered, not
    // that a human could tell two controls apart, and it passes silently if
    // both rungs become identical grey boxes together.
    if (_skippedOffLinux()) return;
    tester.useDevice(_sheet);
    await pumpLonja(
      tester,
      const ColorFiltered(
        colorFilter: ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0, 0, 0, 1, 0, //
        ]),
        child: LonjaSpecimenSheet(),
      ),
    );
    await expectLater(
      find.byType(LonjaSpecimenSheet),
      matchesGoldenFile('goldens/specimen_greyscale.png'),
    );
  });
}
