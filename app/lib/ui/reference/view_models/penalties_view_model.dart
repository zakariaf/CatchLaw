import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/penalty_schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

/// Which jurisdiction's ledger, in which language.
///
/// A record and not a bare `String`, because the locale is part of the answer:
/// the offence names and the licence consequences are `content_string` rows,
/// and a family keyed on the code alone would keep a Galician ledger on screen
/// after the fisher switched the app to Arabic.
typedef PenaltyRequest = ({String jurisdictionCode, String locale});

/// S20's ledger, for one jurisdiction.
///
/// A `FutureProvider.family` and not a `Notifier`: nothing on this page
/// mutates. It is the back cover of the printed booklet — a schedule that is
/// read, never worked — and a notifier with no methods is a class whose only
/// job is to be subclassed later.
///
/// **A failed read throws rather than returning an empty schedule.** An empty
/// schedule is a statement about the law — "this jurisdiction records no
/// penalty" — and making it when the device could not read the file is the app
/// inventing the absence of a penalty, which is the same defect as inventing
/// one.
final penaltyScheduleProvider = FutureProvider.autoDispose.family<PenaltySchedule, PenaltyRequest>((
  Ref ref,
  PenaltyRequest request,
) async {
  final Result<PenaltySchedule> schedule = await ref
      .read(penaltyRepositoryProvider)
      .forJurisdiction(request.jurisdictionCode, locale: request.locale);
  return switch (schedule) {
    Ok<PenaltySchedule>(:final PenaltySchedule value) => value,
    Failure<PenaltySchedule>(:final Exception exception) => throw exception,
  };
});
