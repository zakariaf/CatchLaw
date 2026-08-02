import 'package:catchlaw/domain/models/species_account.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// S2's static half: one species, its names and its art.
abstract interface class SpeciesAccountRepository {
  /// The account for [speciesId], names resolved into [locale].
  ///
  /// A species the pack no longer carries is a `DataNotFound` rather than a
  /// blank page: `catch.species_id` is a **soft** reference into a file a
  /// content update replaces wholesale, and a caller that got an empty account
  /// could not tell "retired" from "failed to read".
  @useResult
  Future<Result<SpeciesAccount>> accountFor(int speciesId, {required String locale});
}
