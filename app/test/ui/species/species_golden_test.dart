@Tags(<String>['golden'])
library;

import 'dart:io' show Platform;

import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/core/ui/lonja_species_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden.dart';

const String _hostSkipReason =
    'goldens are generated and verified on Linux only (FLUTTER_GUIDE.md §6.4 point 2)';

bool _skippedOffLinux() {
  if (Platform.isLinux) return false;
  markTestSkipped(_hostSkipReason);
  return true;
}

/// A short strip of species lines — E08's own primitive, not a whole screen.
///
/// E20 owns the screen matrix. What earns a golden here is the ROW: it is where
/// a local name, a binomial and a one-word hint sit together, and the only way
/// to see that an Arabic name and a Latin binomial share a line correctly is to
/// look at the pixels.
class _SpeciesLines extends StatelessWidget {
  const _SpeciesLines({required this.arabic});

  final bool arabic;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LonjaSpeciesLine(
          name: arabic ? 'هامور' : 'Mero',
          scientificName: 'Epinephelus coioides',
          hint: arabic ? 'محمي' : 'protected',
          onTap: () {},
        ),
        LonjaSpeciesLine(
          name: arabic ? 'كنعد' : 'Ameixa babosa',
          scientificName: 'Scomberomorus commerson',
          onTap: () {},
        ),
      ],
    ),
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required LonjaSkin skin,
  required bool gloved,
  required Locale locale,
}) async {
  tester.useDevice(const Device('species', Size(400, 260), 2));
  await tester.pumpWidget(
    MaterialApp(
      theme: resolveLonjaTheme(skin: skin, gloved: gloved),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: _SpeciesLines(arabic: locale.languageCode == 'ar')),
    ),
  );
  await tester.pump();
}

void main() {
  // Four lanes and no more. CONVENTIONS.md §6 caps the golden budget for the
  // WHOLE product, and E07 already spent eight on the design system; a screen
  // matrix is E20's, not this epic's.
  testWidgets('LonjaSpeciesLine matches its golden on paper', (WidgetTester tester) async {
    if (_skippedOffLinux()) return;
    await _pump(tester, skin: LonjaSkin.paper, gloved: false, locale: const Locale('en'));
    await expectLater(
      find.byType(_SpeciesLines),
      matchesGoldenFile('goldens/species_lines_paper.png'),
    );
  });

  testWidgets('glove - LonjaSpeciesLine matches its golden at the larger row height', (
    WidgetTester tester,
  ) async {
    if (_skippedOffLinux()) return;
    await _pump(tester, skin: LonjaSkin.paper, gloved: true, locale: const Locale('en'));
    await expectLater(
      find.byType(_SpeciesLines),
      matchesGoldenFile('goldens/species_lines_paper_glove.png'),
    );
  });

  testWidgets('sunlight - LonjaSpeciesLine matches its golden with no mid-greys', (
    WidgetTester tester,
  ) async {
    if (_skippedOffLinux()) return;
    await _pump(tester, skin: LonjaSkin.sunlight, gloved: false, locale: const Locale('en'));
    await expectLater(
      find.byType(_SpeciesLines),
      matchesGoldenFile('goldens/species_lines_sunlight.png'),
    );
  });

  testWidgets('ar - LonjaSpeciesLine matches its golden with the binomial still Latin', (
    WidgetTester tester,
  ) async {
    // The one lane that can catch a binomial rendered in the Naskh face, which
    // would be a synthetic oblique slanting a right-to-left script into
    // unreadability.
    if (_skippedOffLinux()) return;
    await _pump(tester, skin: LonjaSkin.paper, gloved: false, locale: const Locale('ar'));
    await expectLater(
      find.byType(_SpeciesLines),
      matchesGoldenFile('goldens/species_lines_ar.png'),
    );
  });
}
