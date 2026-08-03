import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which packs' stale DETAIL the reader has closed, for this app session only.
///
/// **In memory, and deliberately not persisted.** Closing the detail is a
/// "yes, I have read this now" and not a preference: a fisher who dismissed it
/// in June and opens the app again in September is a different reader with a
/// different question, and a stored dismissal would answer it for him. The
/// state dies with the process, which is the shortest lifetime that still stops
/// the detail reappearing on every rebuild in one sitting.
///
/// **The BAR is never closable.** Only its detail is. The bar is the invariant;
/// what can be put away is the paragraph explaining it.
final class StaleDetailSession extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  /// Whether the detail for [packId] is still to be shown.
  bool isOpen(String packId) => !state.contains(packId);

  /// Closes the detail for [packId] until the process ends.
  void close(String packId) => state = <String>{...state, packId};
}

/// The session's closed set.
final NotifierProvider<StaleDetailSession, Set<String>> staleDetailSessionProvider =
    NotifierProvider<StaleDetailSession, Set<String>>(StaleDetailSession.new);
