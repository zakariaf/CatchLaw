import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/species_search_hit.dart';
import 'package:catchlaw/domain/models/species_search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

/// S5's state, and the two intents that change it.
///
/// `autoDispose`, unlike the data seams: this is screen state, and a search
/// term left behind when the fisher navigates away is a stale list waiting to
/// be shown as if it were fresh.
///
/// The view model holds **no widget and no `BuildContext`**, so every row below
/// runs through a `ProviderContainer` with no pump — which is what keeps the
/// §13 latency work measurable rather than tangled up with layout.
class SpeciesSearchViewModel extends Notifier<SpeciesSearchState> {
  @override
  SpeciesSearchState build() => SpeciesSearchState.initial();

  /// Runs a search for [rawQuery].
  ///
  /// The raw string, unfolded: the repository owns the fold, because it is the
  /// engine's own and folding twice matches nothing (E08/T01).
  Future<void> search(String rawQuery) async {
    if (rawQuery.trim().isEmpty) {
      clear();
      return;
    }
    final Result<List<SpeciesSearchHit>> hits = await ref
        .read(speciesSearchRepositoryProvider)
        .search(rawQuery, locale: 'en');

    // A failed read leaves the PREVIOUS list alone rather than emptying the
    // screen. An empty list means "nothing matched", which is a statement about
    // the pack; a broken read is a statement about the device, and showing the
    // first when the second happened is the app lying about the rule book.
    switch (hits) {
      case Ok<List<SpeciesSearchHit>>(:final List<SpeciesSearchHit> value):
        state = SpeciesSearchState(
          query: rawQuery,
          inZone: <SpeciesListing>[
            for (final SpeciesSearchHit hit in value) SpeciesListing(hit: hit, facts: null),
          ],
          elsewhere: const <SpeciesListing>[],
          jurisdictionSpeciesCount: state.jurisdictionSpeciesCount,
          isPackExpired: state.isPackExpired,
        );
      case Failure<List<SpeciesSearchHit>>():
        return;
    }
  }

  /// Returns to the empty state.
  void clear() => state = SpeciesSearchState.initial(
    jurisdictionSpeciesCount: state.jurisdictionSpeciesCount,
    isPackExpired: state.isPackExpired,
  );
}

/// S5's state.
final NotifierProvider<SpeciesSearchViewModel, SpeciesSearchState> speciesSearchViewModelProvider =
    NotifierProvider<SpeciesSearchViewModel, SpeciesSearchState>(
      SpeciesSearchViewModel.new,
      isAutoDispose: true,
    );
