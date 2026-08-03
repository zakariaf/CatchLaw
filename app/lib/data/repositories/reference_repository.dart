import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Citation, ClosedSeason, Result, Rule;

/// What the app can ask the rule book.
///
/// **An interface, so E06 onward can be built and tested without a device and
/// without a real database file.** Every method returns a `Result`, because a
/// repository is a boundary and a boundary that throws makes its failures
/// invisible to the type system.
///
/// Nothing here returns a drift row: `FLUTTER_GUIDE.md` rule 6 keeps those in
/// `data/`, and a view model that held one could not be constructed in a test.
abstract interface class ReferenceRepository {
  /// Species whose normalised name starts with [normalisedPrefix].
  ///
  /// The prefix is **already folded** by the engine's `normaliseSpeciesTerm`.
  /// Folding it again — or differently — matches nothing at all, silently.
  @useResult
  Future<Result<List<Species>>> searchSpecies(String normalisedPrefix, {int limit});

  /// One species, or a `DataNotFound`.
  @useResult
  Future<Result<Species>> speciesById(int id);

  /// Every name of one species, in every locale.
  @useResult
  Future<Result<List<SpeciesName>>> namesFor(int speciesId);

  /// The candidate rules for one cell, **including expired ones**.
  ///
  /// Expiry is tagged by the engine and shown behind a non-blocking ochre bar.
  /// A repository that filtered it here would make every rule sourced from a
  /// lapsed annual instrument vanish on the day it lapsed.
  @useResult
  Future<Result<List<Rule>>> candidateRules({
    required int jurisdictionId,
    required int speciesId,
    required String waterType,
    required String onDate,
  });

  /// The closures attached to those rules.
  @useResult
  Future<Result<List<ClosedSeason>>> closedSeasonsFor(Iterable<int> ruleIds);

  /// The citations behind a resolution.
  @useResult
  Future<Result<List<Citation>>> citations(Iterable<int> ids);

  /// The values of [keys] in [locale], for the keys that exist there.
  ///
  /// No fallback: the §9.2 chain is E06's, where the jurisdiction's
  /// `default_locale` is in scope.
  @useResult
  Future<Result<Map<String, String>>> strings(Iterable<String> keys, String locale);

  /// Every jurisdiction the shipped pack carries, in code order.
  ///
  /// The picker's top two levels come from this one read: §7.1 has no `country`
  /// table, so a country is `country_iso2` grouped. One statement rather than a
  /// query per country — the whole set is a handful of rows, and a query per
  /// level is a round trip per tap.
  @useResult
  Future<Result<List<Jurisdiction>>> jurisdictions();

  /// Every zone of one jurisdiction.
  @useResult
  Future<Result<List<Zone>>> zones(int jurisdictionId);

  /// What the pack says about itself, for the About screen.
  @useResult
  Future<Result<Map<String, String>>> contentMeta();
}
