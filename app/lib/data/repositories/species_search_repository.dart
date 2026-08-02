import 'package:catchlaw/domain/models/species_search_hit.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// What S5's search box asks the rule book.
///
/// Separate from `ReferenceRepository` because the question is different: that
/// one answers "what does the law say about this species", this one answers
/// "which species did those five letters mean". They are read at different
/// times, by different screens, at different latencies — §13 budgets 50 ms for
/// this one at 400 species and 2 400 names, on every keystroke.
abstract interface class SpeciesSearchRepository {
  /// Species whose name starts with [rawQuery], in [locale] first.
  ///
  /// **[rawQuery] is raw.** It arrives as the fisher typed it, with whatever
  /// case, diacritics and Arabic definite article came off the keyboard, and it
  /// is folded here by the engine's own `normaliseSpeciesTerm` — the exact
  /// function the content build used to write `search_norm`. A caller that
  /// folded it first would fold it twice, and a term folded any other way
  /// matches nothing at all, silently.
  @useResult
  Future<Result<List<SpeciesSearchHit>>> search(
    String rawQuery, {
    required String locale,
    int limit,
  });

  /// How many species the pack carries.
  ///
  /// S5's empty state says the list covers the active jurisdiction only, and
  /// that sentence is dishonest without a number behind it.
  @useResult
  Future<Result<int>> speciesCount();
}
