import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/rule_hint.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/domain/models/species_facts.dart';
import 'package:catchlaw/domain/models/species_search_hit.dart';
import 'package:catchlaw/domain/models/species_search_state.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_empty_state.dart';
import 'package:catchlaw/ui/core/ui/lonja_silhouette.dart';
import 'package:catchlaw/ui/core/ui/lonja_species_line.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/species/view_models/species_search_view_model.dart';
import 'package:catchlaw/ui/species/widgets/species_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Citation, TaxonGroup;

import '../../../testing/fakes/fake_species_search_repository.dart';

const Citation _citation = Citation(
  instrument: 'Orde do 1 de xaneiro de 2026',
  article: 'Art. 3',
  publishedOn: '2026-01-01',
  checkedOn: '2026-07-14',
);

SpeciesSearchHit _hit(int id, String name) => SpeciesSearchHit(
  species: Species(
    id: id,
    scientificName: 'Genus species$id',
    familyId: 1,
    taxonGroup: TaxonGroup.finfish,
    silhouetteAsset: 'assets/sil/$id.svg',
  ),
  matchedName: name,
  matchedLocale: 'gl',
  isPrimaryName: true,
);

/// Mounts S5 with a state pinned directly, so a row is about the SCREEN rather
/// than about the view model — which has its own suite.
Future<({int chosen, int identify, int browse})> _pump(
  WidgetTester tester,
  SpeciesSearchState state, {
  Locale locale = const Locale('en'),
}) async {
  var chosen = 0;
  var identify = 0;
  var browse = 0;

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        speciesSearchRepositoryProvider.overrideWithValue(
          FakeSpeciesSearchRepository(const <String, List<SpeciesSearchHit>>{}),
        ),
        speciesSearchViewModelProvider.overrideWith(() => _PinnedViewModel(state)),
      ],
      child: MaterialApp(
        theme: LonjaTheme.paper(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SpeciesSearchScreen(
          onSpeciesChosen: (int _) => chosen++,
          onIdentify: () => identify++,
          onBrowseByShape: () => browse++,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (chosen: chosen, identify: identify, browse: browse);
}

class _PinnedViewModel extends SpeciesSearchViewModel {
  _PinnedViewModel(this._pinned);
  final SpeciesSearchState _pinned;

  @override
  SpeciesSearchState build() => _pinned;
}

void main() {
  testWidgets('SpeciesSearchScreen shows the in-zone group before the elsewhere group', (
    WidgetTester tester,
  ) async {
    // In your zone first, because it is the answer to the question actually
    // being asked.
    await _pump(
      tester,
      SpeciesSearchState(
        query: 'mero',
        inZone: <SpeciesListing>[SpeciesListing(hit: _hit(1, 'Mero'), facts: null)],
        elsewhere: <SpeciesListing>[SpeciesListing(hit: _hit(2, 'Meroliña'), facts: null)],
        jurisdictionSpeciesCount: 412,
        isPackExpired: false,
      ),
    );

    final double inZoneY = tester.getTopLeft(find.text('In your zone')).dy;
    final double elsewhereY = tester.getTopLeft(find.text('Elsewhere in this jurisdiction')).dy;
    expect(inZoneY, lessThan(elsewhereY));
  });

  testWidgets('SpeciesSearchScreen never hides the elsewhere group', (WidgetTester tester) async {
    // A fisher who picked the wrong zone must be able to SEE that his fish
    // exists, rather than being told it does not.
    await _pump(
      tester,
      SpeciesSearchState(
        query: 'mero',
        inZone: const <SpeciesListing>[],
        elsewhere: <SpeciesListing>[SpeciesListing(hit: _hit(2, 'Meroliña'), facts: null)],
        jurisdictionSpeciesCount: 412,
        isPackExpired: false,
      ),
    );
    expect(find.text('Meroliña'), findsOneWidget);
    expect(find.byType(LonjaEmptyState), findsNothing);
  });

  testWidgets('SpeciesSearchScreen offers both onward routes when nothing matched', (
    WidgetTester tester,
  ) async {
    // SPEC.md §6 S5 requires BOTH. §4.3 records that S7 reachable from only one
    // place was a defect in the first draft, and this empty state is one of the
    // three fixes.
    await _pump(
      tester,
      SpeciesSearchState(
        query: 'zzzz',
        inZone: const <SpeciesListing>[],
        elsewhere: const <SpeciesListing>[],
        jurisdictionSpeciesCount: 412,
        isPackExpired: false,
      ),
    );
    expect(find.text('Identify this fish'), findsOneWidget);
    expect(find.text('Browse by shape'), findsOneWidget);
  });

  testWidgets('SpeciesSearchScreen offers exactly one primary rung in its empty state', (
    WidgetTester tester,
  ) async {
    // The skill's defect is two competing PRIMARIES, which this is not: one
    // primary and one secondary.
    await _pump(
      tester,
      SpeciesSearchState(
        query: 'zzzz',
        inZone: const <SpeciesListing>[],
        elsewhere: const <SpeciesListing>[],
        jurisdictionSpeciesCount: 412,
        isPackExpired: false,
      ),
    );
    final Iterable<LonjaButton> buttons = tester.widgetList<LonjaButton>(find.byType(LonjaButton));
    expect(buttons.where((LonjaButton b) => b.variant == LonjaButtonVariant.primary), hasLength(1));
  });

  testWidgets('SpeciesSearchScreen states the jurisdiction count in its empty state', (
    WidgetTester tester,
  ) async {
    // "This list covers the active jurisdiction only" is a sentence nobody can
    // check without a number.
    await _pump(
      tester,
      SpeciesSearchState(
        query: 'zzzz',
        inZone: const <SpeciesListing>[],
        elsewhere: const <SpeciesListing>[],
        jurisdictionSpeciesCount: 412,
        isPackExpired: false,
      ),
    );
    expect(find.textContaining('412'), findsOneWidget);
  });

  testWidgets('SpeciesSearchScreen shows the stale bar above the list, not over it', (
    WidgetTester tester,
  ) async {
    // Invariant 5: an expired ruleset is still evaluated and still shown. The
    // bar states the data is stale; it never covers what it warns about.
    await _pump(
      tester,
      SpeciesSearchState(
        query: 'mero',
        inZone: <SpeciesListing>[SpeciesListing(hit: _hit(1, 'Mero'), facts: null)],
        elsewhere: const <SpeciesListing>[],
        jurisdictionSpeciesCount: 412,
        isPackExpired: true,
      ),
    );
    expect(find.byType(LonjaStaleBar), findsOneWidget);
    expect(find.text('Mero'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(LonjaStaleBar)).dy,
      lessThan(tester.getTopLeft(find.text('Mero')).dy),
    );
  });

  testWidgets('SpeciesSearchScreen renders a protected species with its one-word hint', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      SpeciesSearchState(
        query: 'mero',
        inZone: <SpeciesListing>[
          SpeciesListing(
            hit: _hit(1, 'Mero'),
            facts: const SpeciesFacts(
              inActiveZone: true,
              hint: ProtectedHint(),
              citation: _citation,
            ),
          ),
        ],
        elsewhere: const <SpeciesListing>[],
        jurisdictionSpeciesCount: 412,
        isPackExpired: false,
      ),
    );
    expect(find.text('protected'), findsOneWidget);
  });

  testWidgets('SpeciesSearchScreen labels the results with how many the name matched', (
    WidgetTester tester,
  ) async {
    // A sentence and not a ratio: `2 of 412` is a measurement, and what the
    // reader is asking is how many rows are under his thumb. It sits above the
    // first group, because it counts both of them.
    await _pump(
      tester,
      SpeciesSearchState(
        query: 'mero',
        inZone: <SpeciesListing>[SpeciesListing(hit: _hit(1, 'Mero'), facts: null)],
        elsewhere: <SpeciesListing>[SpeciesListing(hit: _hit(2, 'Meroliña'), facts: null)],
        jurisdictionSpeciesCount: 412,
        isPackExpired: false,
      ),
    );
    expect(find.text('2 matching results'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('2 matching results')).dy,
      lessThan(tester.getTopLeft(find.text('In your zone')).dy),
    );
  });

  testWidgets('SpeciesSearchScreen draws the shape beside every name', (WidgetTester tester) async {
    // A row that is only a name is a row a fisher has to read. The drawing is
    // what he recognises before he reads it, which is the whole of S6 carried
    // into the list S5 returns.
    await _pump(
      tester,
      SpeciesSearchState(
        query: 'mero',
        inZone: <SpeciesListing>[
          SpeciesListing(hit: _hit(1, 'Mero'), facts: null),
          SpeciesListing(hit: _hit(2, 'Meroliña'), facts: null),
        ],
        elsewhere: const <SpeciesListing>[],
        jurisdictionSpeciesCount: 412,
        isPackExpired: false,
      ),
    );
    expect(find.byType(LonjaSilhouette), findsNWidgets(2));
  });

  testWidgets('SpeciesSearchScreen marks every row as one that opens something', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      SpeciesSearchState(
        query: 'mero',
        inZone: <SpeciesListing>[SpeciesListing(hit: _hit(1, 'Mero'), facts: null)],
        elsewhere: const <SpeciesListing>[],
        jurisdictionSpeciesCount: 412,
        isPackExpired: false,
      ),
    );
    final Iterable<LonjaGlyph> glyphs = tester
        .widgetList<LonjaIcon>(find.byType(LonjaIcon))
        .map((LonjaIcon icon) => icon.glyph);
    expect(glyphs, contains(LonjaIcons.forward));
  });

  testWidgets('SpeciesSearchScreen gives each species row one tap target', (
    WidgetTester tester,
  ) async {
    // A row whose only tappable part is its title is a row a wet thumb misses.
    await _pump(
      tester,
      SpeciesSearchState(
        query: 'mero',
        inZone: <SpeciesListing>[SpeciesListing(hit: _hit(1, 'Mero'), facts: null)],
        elsewhere: const <SpeciesListing>[],
        jurisdictionSpeciesCount: 412,
        isPackExpired: false,
      ),
    );
    expect(tester.getSize(find.byType(LonjaSpeciesLine)).height, greaterThanOrEqualTo(48));
  });

  testWidgets('ar - SpeciesSearchScreen lays the empty state out right to left', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      SpeciesSearchState(
        query: 'zzzz',
        inZone: const <SpeciesListing>[],
        elsewhere: const <SpeciesListing>[],
        jurisdictionSpeciesCount: 412,
        isPackExpired: false,
      ),
      locale: const Locale('ar'),
    );
    expect(find.text('تحديد هذه السمكة'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(LonjaEmptyState))), TextDirection.rtl);
  });
}
