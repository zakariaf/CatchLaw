import 'package:catchlaw/data/repositories/content_string_repository.dart';
import 'package:catchlaw/domain/models/content_string_missing.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

/// The `SPEC.md` §9.2 fallback chain, in §9.2's order.
///
/// A use case rather than a repository method: it joins a row set with the
/// resolved locale and the jurisdiction's `default_locale`, and
/// `FLUTTER_GUIDE.md` §1.9 puts every cross-source join here. Pure over its
/// inputs — no `BuildContext`, no clock, no global — so its rows run under
/// `flutter test` with no container and no pump.
///
/// It is app-side and stays there. D-7: `packages/rule_engine/` returns types
/// carrying numbers, enums and a `Citation`, and a resolver that returns
/// "Mero moteado" is the definition of what may not live in it.
final class ContentStringResolver {
  /// Resolves against [repository].
  const ContentStringResolver(this.repository);

  /// Where the rows come from.
  final ContentStringRepository repository;

  /// The best value for [key], by `SPEC.md` §9.2's chain.
  ///
  /// The order carries meaning and is not a preference:
  ///
  /// 1. [requestedLocale] — what the fisher asked for.
  /// 2. [defaultLocale] — the jurisdiction's publication language. A Galician
  ///    rule written in Galician is closer to the source than an English gloss
  ///    of it; this is §9.1's argument applied one row at a time.
  /// 3. `en` — the only language with a cross-jurisdiction vernacular source
  ///    (Catalogue of Life, §9.2 point 2).
  /// 4. [scientificName] — Latin, present in every locale, and never wrong.
  ///
  /// Step 4 is species-only, which is why it is a parameter rather than a step
  /// the chain always has. A gear name or a penalty description has no binomial
  /// to fall back to, so for those the chain ends at `en` and exhausting it
  /// throws [ContentStringMissing].
  ///
  /// One repository call, whatever the chain does. The whole key's row set is
  /// fetched once and the steps run in Dart: S5 renders forty rows, and a
  /// statement per step would be a hundred and sixty round trips for one
  /// screen (`SPEC.md` §13).
  ///
  /// A storage failure is rethrown as itself rather than folded into
  /// [ContentStringMissing]. A store that could not be read has not told us the
  /// key is absent, and this project does not merge two states into one word.
  Future<String> resolve(
    String key, {
    required String requestedLocale,
    required String defaultLocale,
    String? scientificName,
  }) async {
    final Result<Map<String, String>> result = await repository.valuesFor(key);
    final Map<String, String> values = switch (result) {
      Ok<Map<String, String>>(:final Map<String, String> value) => value,
      Failure<Map<String, String>>(:final Exception exception) => throw exception,
    };

    for (final locale in <String>[requestedLocale, defaultLocale, 'en']) {
      // An exact match only. `pt_BR` is not `pt`: D-3 carries the region
      // because the content is Brazilian, and a prefix match here would ship
      // Iberian wording to Brazil.
      final String? value = values[locale];
      if (value != null && value.isNotEmpty) return value;
    }

    if (scientificName != null && scientificName.isNotEmpty) return scientificName;
    throw ContentStringMissing(key);
  }
}
