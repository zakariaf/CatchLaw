import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/species_account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

/// S2's static half, for one species.
///
/// A `FutureProvider.family` and not a `Notifier`: this half of S2 has no
/// intents. Nothing on it mutates — the ruler is E09's and the verdict is
/// E10's — and a notifier with no methods is a class whose only job is to be
/// subclassed later.
///
/// Keyed by species id, so opening a second species does not evict the first: a
/// fisher comparing two look-alikes taps back and forth, and re-reading the
/// pack each time is work the §13 budget did not price.
final speciesAccountProvider = FutureProvider.family<SpeciesAccount, int>((
  Ref ref,
  int speciesId,
) async {
  final Result<SpeciesAccount> account = await ref
      .read(speciesAccountRepositoryProvider)
      .accountFor(speciesId, locale: 'en');
  return switch (account) {
    Ok<SpeciesAccount>(:final SpeciesAccount value) => value,
    // A species the pack no longer carries and a read that failed are two
    // different states, and the repository keeps them apart. The screen
    // shows the exception rather than an empty page, because an empty page
    // is a claim that the species has nothing to say.
    Failure<SpeciesAccount>(:final Exception exception) => throw exception,
  };
});
