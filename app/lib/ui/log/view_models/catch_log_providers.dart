import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:catchlaw/ui/settings/widgets/settings_screen.dart';
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
/// The active place, as two codes.
///
/// **From the profile, not from `EvaluationScope`.** The tally needs a
/// jurisdiction and a zone; the scope additionally resolves the zone chain, the
/// water type, the pack version and its expiry, and rebuilds its whole stream
/// whenever any of those dependencies move. Depending on it meant the tally was
/// re-created on churn that had nothing to do with the two strings it uses — and
/// a `StreamProvider` rebuilt before its first event drops back to loading, so
/// the page sat blank with correct rows underneath it.
///
/// `user_profile` is also the same source the RECORD path writes against, so the
/// read and the write cannot disagree about where the fisher is.
final Provider<({String jurisdiction, String zone})?> activePlaceProvider =
    Provider<({String jurisdiction, String zone})?>((Ref ref) {
      final UserProfile? profile = ref.watch(settingsProfileProvider).value;
      final String? jurisdiction = profile?.activeJurisdiction;
      final String? zone = profile?.activeZoneCode;
      if (jurisdiction == null || zone == null) return null;
      return (jurisdiction: jurisdiction, zone: zone);
    });

/// The day's tally for the active place.
///
/// Empty — not an error — when no place is set. A fisher who has not answered
/// "where are you fishing?" has no day to tally, and S8 says so in words rather
/// than failing.
final StreamProvider<List<SpeciesTallyEntry>> dayTallyProvider =
    StreamProvider<List<SpeciesTallyEntry>>((Ref ref) {
      final ({String jurisdiction, String zone})? place = ref.watch(activePlaceProvider);
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
