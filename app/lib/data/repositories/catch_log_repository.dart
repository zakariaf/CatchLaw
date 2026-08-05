import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// What the fisher has landed, and the outings he landed it on.
///
/// **Everything here reads and writes `user.db` only.** The catch row
/// denormalises `scientific_name`, the outcome sentence and the citation
/// reference precisely so the log survives a wholesale content swap: a pack
/// update replaces `reference.db` outright, and a log that joined against it
/// would rewrite history every time the rules changed. What he read on the day
/// is what the record keeps.
///
/// **This is a private complement to the EU's `RecFishing` app, never a
/// substitute.** `SPEC.md` §5 refuses presenting the log as satisfying any
/// declaration duty, so nothing here submits, exports or transmits — and there
/// is no method on this interface that could.
abstract interface class CatchLogRepository {
  /// Today's tally for one place, live.
  ///
  /// Grouped by species in SQL rather than folded in Dart: the screen rebuilds
  /// on every insert, and folding a season of rows in the UI isolate is a
  /// dropped frame at the moment a fish is landed.
  Stream<List<SpeciesTallyEntry>> watchDay({
    required String isoDay,
    required String jurisdictionCode,
    required String zoneCode,
  });

  /// The outings, most recent first.
  Stream<List<Trip>> watchTrips({int limit});

  /// The outing still running, or null.
  Stream<Trip?> watchOpenTrip();

  /// Records one catch, exactly as it was read.
  ///
  /// [outcomeDetail] is the sentence the fisher saw, passed in rather than
  /// regenerated. Regenerating it later against a newer pack would put words in
  /// the record that were never on the screen.
  @useResult
  Future<Result<int>> record(CatchDraft draft);

  /// Opens an outing here, closing any that was still running.
  @useResult
  Future<Result<int>> startTrip({
    required String startedAt,
    required String jurisdictionCode,
    required String zoneCode,
    String? label,
  });

  /// Removes the most recent catch of [speciesId] recorded on [isoDay] here.
  ///
  /// The most recent one, not all of them: a fisher who tapped twice wants the
  /// second tap undone, and a delete that cleared the whole species would throw
  /// away a morning's work to fix a slip. Deleting from a tally is unusual, so
  /// the row it removes is stated to be the newest rather than left to the
  /// reader to guess.
  @useResult
  Future<Result<int>> removeLatest({
    required int speciesId,
    required String isoDay,
    required String jurisdictionCode,
    required String zoneCode,
  });

  /// Marks ONE more catch of [speciesId] on [isoDay] here as kept.
  ///
  /// **The most recent one that is not kept already**, which is what makes the
  /// action countable. Marking simply "the most recent" targets the same row
  /// every time, so a fisher with six in the tally could never get past one
  /// kept however often he tapped — the first version did exactly that.
  ///
  /// Returns the number of rows changed, so a caller can tell "marked one" from
  /// "they are all marked already" without re-reading the tally.
  ///
  /// Kept is authored by the fisher and is never inferred from a verdict: a
  /// legal fish put back is still a legal fish, and a record that decided this
  /// for him would be a record about the rules rather than about his morning.
  @useResult
  Future<Result<int>> markOneKept({
    required int speciesId,
    required String isoDay,
    required String jurisdictionCode,
    required String zoneCode,
  });

  /// Closes [tripId] at [endedAt].
  @useResult
  Future<Result<void>> endTrip(int tripId, String endedAt);
}
