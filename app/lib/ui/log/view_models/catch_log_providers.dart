import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/ui/zones/view_models/zone_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today, as the log stores it.
///
/// Injected rather than read from the clock inside a provider, for the reason
/// `catchlaw-rule-engine` gives about `DateTime.now()`: a value read at build
/// time freezes at whenever the widget last built, so a boat that crosses
/// midnight keeps tallying yesterday. Overridden in tests to a fixed day.
final Provider<String> todayIsoProvider = Provider<String>((Ref ref) {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
});

/// The day's tally for the active place.
///
/// Empty — not an error — when no place is set. A fisher who has not answered
/// "where are you fishing?" has no day to tally, and S8 says so in words rather
/// than failing.
/// **Watched by `select`, on the two codes and nothing else.** `WatchEvaluationScope`
/// builds a fresh stream on every rebuild of its own dependencies, so watching
/// the whole `AsyncValue` re-created this provider each time the scope
/// re-emitted an IDENTICAL place — and a `StreamProvider` rebuilt before its
/// first event goes back to loading. The screen then sat in a permanent loading
/// state and rendered blank, with three correct rows in the database and a
/// correct query over them. Selecting the codes means an unchanged place is not
/// a change.
final StreamProvider<List<SpeciesTallyEntry>> dayTallyProvider =
    StreamProvider<List<SpeciesTallyEntry>>((Ref ref) {
      final ({String jurisdiction, String zone})? place = ref.watch(
        evaluationScopeProvider.select(
          (AsyncValue<EvaluationScope?> a) => a.value == null
              ? null
              : (jurisdiction: a.value!.jurisdictionCode, zone: a.value!.zoneCode),
        ),
      );
      if (place == null) return Stream<List<SpeciesTallyEntry>>.value(const <SpeciesTallyEntry>[]);

      return ref
          .watch(catchLogRepositoryProvider)
          .watchDay(
            isoDay: ref.watch(todayIsoProvider),
            jurisdictionCode: place.jurisdiction,
            zoneCode: place.zone,
          );
    });

/// Every outing, most recent first.
final StreamProvider<List<Trip>> tripsProvider = StreamProvider<List<Trip>>(
  (Ref ref) => ref.watch(catchLogRepositoryProvider).watchTrips(),
);

/// The outing still running, or null.
final StreamProvider<Trip?> openTripProvider = StreamProvider<Trip?>(
  (Ref ref) => ref.watch(catchLogRepositoryProvider).watchOpenTrip(),
);
