import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/domain/use_cases/watch_evaluation_scope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The place every verdict on the screen is answered against.
///
/// **`null` is a real state and is not an error.** A new install has no place,
/// and every screen that needs one shows S9 rather than a verdict computed
/// against a jurisdiction nobody chose.
///
/// A stream and not a future, because §4.4 says switching zone re-evaluates
/// instantly: the place is written once by S9, and every screen watching it
/// re-asks without a navigation event or a refresh control.
final StreamProvider<EvaluationScope?> evaluationScopeProvider = StreamProvider<EvaluationScope?>(
  (Ref ref) => WatchEvaluationScope(
    settings: ref.watch(settingsRepositoryProvider),
    reference: ref.watch(referenceRepositoryProvider),
  )(),
);

/// The places the fisher starred, newest order first.
final StreamProvider<List<SavedZone>> savedZonesProvider = StreamProvider<List<SavedZone>>(
  (Ref ref) => ref.watch(settingsRepositoryProvider).watchSavedZones(),
);
