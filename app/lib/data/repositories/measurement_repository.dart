import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// The catch-log write path.
///
/// Named for what it records rather than for the table it writes: E13 records a
/// measurement and the verdict it produced together, and the pair is what has
/// to be atomic.
///
/// **This interface never mentions the reference side and never will.** A
/// screen that joins content to the fisher's record — the result screen, which
/// wants a species name beside a tally — does the join in `domain/use_cases/`,
/// where it is testable with neither database open. The first time somebody
/// wants that name here, calling across is one line and denormalising is three,
/// which is why `layering_test.dart` asserts the absence of the edge.
abstract interface class MeasurementRepository {
  /// The catches of one trip, newest first.
  Stream<List<CatchRecord>> watchForTrip(int tripId);

  /// The day's tally for one place.
  Stream<List<SpeciesTallyEntry>> watchTallyForDay(
    String isoDay, {
    required String jurisdictionCode,
    required String zoneCode,
  });

  /// The page of catches older than [cursorCreatedAt].
  @useResult
  Future<Result<List<CatchRecord>>> pageBefore(String cursorCreatedAt, {int limit});

  /// Records [draft] and bumps the species' recency, atomically.
  ///
  /// Returns the row **as written**, so the caller renders what is stored
  /// rather than what it hoped to store. The timestamps are the caller's: this
  /// layer reads no clock, so a test of it does not depend on when it ran.
  @useResult
  Future<Result<CatchRecord>> recordCatch(CatchDraft draft, {String? updatedAt});

  /// Deletes one catch.
  @useResult
  Future<Result<void>> deleteCatch(int id);

  /// The open trip, or `null`.
  Stream<Trip?> watchOpenTrip();

  /// Starts a trip, closing whichever one is open.
  @useResult
  Future<Result<int>> startTrip({
    required String startedAt,
    required String jurisdictionCode,
    required String zoneCode,
    String? label,
  });

  /// Ends a trip.
  @useResult
  Future<Result<void>> endTrip(int id, String endedAt);

  /// What this place has seen recently.
  Stream<List<RecentSpecies>> watchRecentSpecies({
    required String jurisdictionCode,
    required String zoneCode,
    int limit,
  });
}
