import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/penalty_repository.dart';
import 'package:catchlaw/domain/models/penalty_schedule.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// An in-memory [PenaltyRepository].
final class FakePenaltyRepository implements PenaltyRepository {
  /// Serves [schedules], or fails every call with [failure].
  FakePenaltyRepository(this.schedules, {this.failure});

  /// jurisdiction code → its ledger.
  final Map<String, PenaltySchedule> schedules;

  /// What every call fails with, when the test is about a store that broke.
  final Exception? failure;

  /// Every code this repository was asked for, in order.
  final List<String> asked = <String>[];

  /// The locale each of those calls asked in.
  final List<String> locales = <String>[];

  @override
  Future<Result<PenaltySchedule>> forJurisdiction(
    String jurisdictionCode, {
    required String locale,
  }) async {
    asked.add(jurisdictionCode);
    locales.add(locale);
    if (failure != null) return Result<PenaltySchedule>.error(failure!);
    final PenaltySchedule? found = schedules[jurisdictionCode];
    if (found == null) {
      // The same failure the real one raises for a code this pack does not
      // carry — never an empty schedule, which would be a claim about the law.
      return Result<PenaltySchedule>.error(
        DataNotFound(entity: 'jurisdiction', id: jurisdictionCode),
      );
    }
    return Result<PenaltySchedule>.ok(found);
  }
}
