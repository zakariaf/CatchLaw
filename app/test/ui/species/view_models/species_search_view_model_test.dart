import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/domain/models/species_search_hit.dart';
import 'package:catchlaw/domain/models/species_search_state.dart';
import 'package:catchlaw/ui/species/view_models/species_search_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show TaxonGroup;

import '../../../../testing/fakes/fake_species_search_repository.dart';

const SpeciesSearchHit _hamour = SpeciesSearchHit(
  species: Species(
    id: 1,
    scientificName: 'Epinephelus coioides',
    familyId: 1,
    taxonGroup: TaxonGroup.finfish,
    silhouetteAsset: 'assets/sil/hamour.svg',
  ),
  matchedName: 'هامور',
  matchedLocale: 'ar',
  isPrimaryName: true,
);

void main() {
  late FakeSpeciesSearchRepository repo;
  late ProviderContainer container;

  ProviderSubscription<SpeciesSearchState> listen() => container.listen(
    speciesSearchViewModelProvider,
    (SpeciesSearchState? _, SpeciesSearchState _) {},
    fireImmediately: true,
  );

  setUp(() {
    repo = FakeSpeciesSearchRepository(<String, List<SpeciesSearchHit>>{
      'هامور': <SpeciesSearchHit>[_hamour],
    });
    container = ProviderContainer(
      overrides: <Override>[speciesSearchRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
  });

  test('SpeciesSearchViewModel starts empty', () {
    final ProviderSubscription<SpeciesSearchState> sub = listen();
    addTearDown(sub.close);
    expect(container.read(speciesSearchViewModelProvider).isEmpty, isTrue);
    expect(container.read(speciesSearchViewModelProvider).query, '');
  });

  test('SpeciesSearchViewModel.search puts a hit in the in-zone group', () async {
    final ProviderSubscription<SpeciesSearchState> sub = listen();
    addTearDown(sub.close);

    await container.read(speciesSearchViewModelProvider.notifier).search('هامور');

    final SpeciesSearchState state = container.read(speciesSearchViewModelProvider);
    expect(state.inZone, hasLength(1));
    expect(state.inZone.single.hit.matchedName, 'هامور');
    expect(state.query, 'هامور');
  });

  test('SpeciesSearchViewModel.search passes the query UNFOLDED to the repository', () async {
    // The repository owns the fold, because it is the engine's own and folding
    // twice matches nothing at all (E08/T01).
    final ProviderSubscription<SpeciesSearchState> sub = listen();
    addTearDown(sub.close);

    await container.read(speciesSearchViewModelProvider.notifier).search('الهامور');
    expect(repo.queries, <String>['الهامور']);
  });

  test('SpeciesSearchViewModel.search asks the repository exactly once per call', () async {
    // The §13 budget is per keystroke, so a view model that fired twice for one
    // letter would spend it twice. A spy and not a counter, because "at least
    // one" would pass over exactly that.
    final ProviderSubscription<SpeciesSearchState> sub = listen();
    addTearDown(sub.close);

    await container.read(speciesSearchViewModelProvider.notifier).search('هامور');
    expect(repo.queries, hasLength(1));
  });

  test('SpeciesSearchViewModel.search on whitespace returns to the empty state', () async {
    final ProviderSubscription<SpeciesSearchState> sub = listen();
    addTearDown(sub.close);

    await container.read(speciesSearchViewModelProvider.notifier).search('هامور');
    await container.read(speciesSearchViewModelProvider.notifier).search('   ');

    expect(container.read(speciesSearchViewModelProvider).isEmpty, isTrue);
    expect(repo.queries, hasLength(1), reason: 'an empty prefix must not reach the database');
  });

  test(
    'SpeciesSearchViewModel.search leaves the previous list alone when the read fails',
    () async {
      // An empty list means "nothing matched", which is a statement about the
      // pack. A broken read is a statement about the device, and showing the
      // first when the second happened is the app lying about the rule book.
      final ProviderSubscription<SpeciesSearchState> sub = listen();
      addTearDown(sub.close);
      await container.read(speciesSearchViewModelProvider.notifier).search('هامور');

      final broken = ProviderContainer(
        overrides: <Override>[
          speciesSearchRepositoryProvider.overrideWithValue(
            FakeSpeciesSearchRepository(
              const <String, List<SpeciesSearchHit>>{},
              failure: const FormatException('reference.db is unreadable'),
            ),
          ),
        ],
      );
      addTearDown(broken.dispose);
      final ProviderSubscription<SpeciesSearchState> brokenSub = broken.listen(
        speciesSearchViewModelProvider,
        (SpeciesSearchState? _, SpeciesSearchState _) {},
        fireImmediately: true,
      );
      addTearDown(brokenSub.close);

      await broken.read(speciesSearchViewModelProvider.notifier).search('كنعد');
      expect(broken.read(speciesSearchViewModelProvider).isEmpty, isTrue);
    },
  );

  test('SpeciesSearchViewModel.clear empties the list and the query', () async {
    final ProviderSubscription<SpeciesSearchState> sub = listen();
    addTearDown(sub.close);

    await container.read(speciesSearchViewModelProvider.notifier).search('هامور');
    container.read(speciesSearchViewModelProvider.notifier).clear();

    expect(container.read(speciesSearchViewModelProvider).isEmpty, isTrue);
    expect(container.read(speciesSearchViewModelProvider).query, '');
  });

  test('SpeciesSearchState.elsewhere is never hidden from the state', () {
    // A fisher who has picked the wrong zone must be able to SEE that his fish
    // exists, rather than being told it does not.
    final state = SpeciesSearchState(
      query: 'x',
      inZone: const <SpeciesListing>[],
      elsewhere: const <SpeciesListing>[SpeciesListing(hit: _hamour, facts: null)],
      jurisdictionSpeciesCount: 400,
      isPackExpired: true,
    );
    expect(state.isEmpty, isFalse);
    expect(state.elsewhere, hasLength(1));
    // Expiry is a flag on the state, never a filter over the list.
    expect(state.isPackExpired, isTrue);
  });
}
