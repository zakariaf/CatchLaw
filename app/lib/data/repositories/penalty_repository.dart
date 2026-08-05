import 'package:catchlaw/domain/models/penalty_schedule.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// What the bundled pack records about the cost of a breach.
///
/// **Keyed by code, never by row id.** `reference.db` is replaced wholesale by
/// a content update and a row id that meant one jurisdiction in one pack can
/// mean another in the next; the codes survive the replacement.
abstract interface class PenaltyRepository {
  /// The penalty ledger [jurisdictionCode] publishes, resolved into [locale].
  ///
  /// A jurisdiction with no penalty transcribed returns a schedule whose tiers
  /// are empty — not a failure, and not an absent schedule. "Nothing was
  /// recorded" and "the file could not be read" are different facts, and this
  /// product does not merge two states into one word.
  @useResult
  Future<Result<PenaltySchedule>> forJurisdiction(
    String jurisdictionCode, {
    required String locale,
  });
}
