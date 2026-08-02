import 'package:catchlaw/domain/models/look_alike.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/species/widgets/look_alike_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const LookAlike _lentjan = LookAlike(
  confusedWithSpeciesId: 2,
  confusedWithName: 'Shaeri',
  confusedWithScientificName: 'Lethrinus lentjan',
  difference: 'A red margin on the gill cover, and no blue spangles on the cheek.',
  confusedWithIsProtected: true,
  confusedWithSilhouetteAsset: 'assets/sil/2.svg',
  confusedWithPlateAsset: 'assets/plates/2.svg',
);

Future<int> _pump(
  WidgetTester tester,
  List<LookAlike> pairs, {
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
        body: SingleChildScrollView(
          child: LookAlikeCard(lookAlikes: pairs, onOpenSpecies: (int _) => opened++),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return opened;
}

void main() {
  testWidgets('LookAlikeCard states the difference rather than advising', (
    WidgetTester tester,
  ) async {
    // The card does not classify. It states that two fish look alike, quotes
    // one physical character from the pack, and lets the reader look at the
    // fish in his hand.
    await _pump(tester, const <LookAlike>[_lentjan]);
    expect(find.textContaining('red margin on the gill cover'), findsOneWidget);
    expect(find.text('How to tell them apart'), findsOneWidget);
  });

  testWidgets('LookAlikeCard marks a protected look-alike', (WidgetTester tester) async {
    // The whole reason the card matters: mistaking an unprotected fish for a
    // protected one costs nothing, and the reverse costs a licence.
    await _pump(tester, const <LookAlike>[_lentjan]);
    expect(find.text('Protected somewhere in this jurisdiction'), findsOneWidget);
  });

  testWidgets('LookAlikeCard renders nothing when there is no confusable species', (
    WidgetTester tester,
  ) async {
    // An empty heading over nothing reads as content that failed to load.
    await _pump(tester, const <LookAlike>[]);
    expect(find.text('Easily confused with'), findsNothing);
  });

  testWidgets('LookAlikeCard opens the other species on tap', (WidgetTester tester) async {
    // A fisher comparing two emperors taps back and forth; the card is a way
    // into the other account, not a dead end.
    await _pump(tester, const <LookAlike>[_lentjan]);
    await tester.tap(find.text('Shaeri'));
    await tester.pump();
    expect(find.text('Shaeri'), findsOneWidget);
  });

  testWidgets('LookAlikeCard gives each entry a target that meets the floor', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const <LookAlike>[_lentjan]);
    expect(tester.getSize(find.byType(InkWell).first).height, greaterThanOrEqualTo(48));
  });

  testWidgets('LookAlikeCard sets the binomial after the local name', (WidgetTester tester) async {
    await _pump(tester, const <LookAlike>[_lentjan]);
    expect(
      tester.getTopLeft(find.text('Shaeri')).dy,
      lessThan(tester.getTopLeft(find.text('Lethrinus lentjan')).dy),
    );
  });

  testWidgets('ar - LookAlikeCard lays out right to left', (WidgetTester tester) async {
    await _pump(tester, const <LookAlike>[_lentjan], locale: const Locale('ar'));
    expect(Directionality.of(tester.element(find.text('Shaeri'))), TextDirection.rtl);
  });
}
