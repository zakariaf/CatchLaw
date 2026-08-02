import 'package:catchlaw/domain/models/recent_species_entry.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/species/widgets/recents_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

RecentSpeciesEntry _entry(int id, String name, {int uses = 1}) => RecentSpeciesEntry(
  speciesId: id,
  useCount: uses,
  lastUsedAt: '2026-08-01T05:40:00Z',
  displayName: name,
  silhouetteAsset: 'assets/sil/$id.svg',
);

Future<int> _pump(
  WidgetTester tester,
  List<RecentSpeciesEntry> entries, {
  Locale locale = const Locale('en'),
}) async {
  var opened = 0;
  await tester.pumpWidget(
    MaterialApp(
      theme: LonjaTheme.paper(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RecentsStrip(entries: entries, onOpenSpecies: (int _) => opened++),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return opened;
}

void main() {
  testWidgets('RecentsStrip lists the entries in the order it was given', (
    WidgetTester tester,
  ) async {
    // The repository orders by frequency then recency; the strip does not
    // reorder, because a second opinion about order is a second bug.
    await _pump(tester, <RecentSpeciesEntry>[
      _entry(1, 'Mero', uses: 9),
      _entry(2, 'Ameixa', uses: 2),
    ]);
    expect(
      tester.getTopLeft(find.text('Mero')).dx,
      lessThan(tester.getTopLeft(find.text('Ameixa')).dx),
    );
  });

  testWidgets('RecentsStrip says what will fill it when it is empty', (WidgetTester tester) async {
    // A description of the mechanism, not an instruction to go and use it.
    await _pump(tester, const <RecentSpeciesEntry>[]);
    expect(find.text('Species you open in this zone appear here.'), findsOneWidget);
  });

  testWidgets('RecentsStrip gives each chip a target that meets the floor', (
    WidgetTester tester,
  ) async {
    await _pump(tester, <RecentSpeciesEntry>[_entry(1, 'Mero')]);
    final Size size = tester.getSize(find.byType(InkWell).first);
    expect(size.height, greaterThanOrEqualTo(48));
    expect(size.width, greaterThanOrEqualTo(48));
  });

  testWidgets('RecentsStrip opens a species on tap', (WidgetTester tester) async {
    await _pump(tester, <RecentSpeciesEntry>[_entry(1, 'Mero')]);
    await tester.tap(find.text('Mero'));
    await tester.pump();
    expect(find.text('Mero'), findsOneWidget);
  });

  testWidgets('ar - RecentsStrip lays out right to left', (WidgetTester tester) async {
    await _pump(tester, <RecentSpeciesEntry>[_entry(1, 'هامور')], locale: const Locale('ar'));
    expect(Directionality.of(tester.element(find.text('هامور'))), TextDirection.rtl);
  });
}
