/// The data layer's dependency-injection seams.
///
/// **Every one of these throws.** A provider that constructed a real database
/// on demand would open SQLite inside a widget test and would hide a forgotten
/// override until whichever screen first read it — which, for the settings
/// singleton, is the first frame on a fisher's phone. Failing at the first read
/// with a name attached is the whole point.
///
/// They are plain `Provider`s and deliberately not `autoDispose`: these are
/// app-scope singletons, and one that tore down when the last listener went
/// away would reopen SQLite on the next navigation.
library;

import 'package:catchlaw/data/repositories/calibration_repository.dart';
import 'package:catchlaw/data/repositories/look_alike_repository.dart';
import 'package:catchlaw/data/repositories/measurement_repository.dart';
import 'package:catchlaw/data/repositories/reference_repository.dart';
import 'package:catchlaw/data/repositories/settings_repository.dart';
import 'package:catchlaw/data/repositories/species_account_repository.dart';
import 'package:catchlaw/data/repositories/species_browse_repository.dart';
import 'package:catchlaw/data/repositories/species_facts_repository.dart';
import 'package:catchlaw/data/repositories/species_recent_repository.dart';
import 'package:catchlaw/data/repositories/species_search_repository.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Override and ProviderBase are exported from misc.dart in Riverpod 3, not
// from the main entry point.
import 'package:flutter_riverpod/misc.dart';

/// The shipped, read-only rule book.
final Provider<ReferenceDatabase> referenceDatabaseProvider = Provider<ReferenceDatabase>(
  (Ref ref) => throw UnimplementedError('override with dataOverrides() in main()'),
);

/// The fisher's log — the only writable database.
final Provider<UserDatabase> userDatabaseProvider = Provider<UserDatabase>(
  (Ref ref) => throw UnimplementedError('override with dataOverrides() in main()'),
);

/// What the app asks the rule book.
final Provider<ReferenceRepository> referenceRepositoryProvider = Provider<ReferenceRepository>(
  (Ref ref) => throw UnimplementedError('override with dataOverrides() in main()'),
);

/// The catch-log write path.
final Provider<MeasurementRepository> measurementRepositoryProvider =
    Provider<MeasurementRepository>(
      (Ref ref) => throw UnimplementedError('override with dataOverrides() in main()'),
    );

/// The settings singleton and the saved places.
final Provider<SettingsRepository> settingsRepositoryProvider = Provider<SettingsRepository>(
  (Ref ref) => throw UnimplementedError('override with dataOverrides() in main()'),
);

/// What S5's search box asks the rule book.
final Provider<SpeciesSearchRepository> speciesSearchRepositoryProvider =
    Provider<SpeciesSearchRepository>(
      (Ref ref) => throw UnimplementedError('override with dataOverrides() in main()'),
    );

/// What the rules say about a species, here, today.
final Provider<SpeciesFactsRepository> speciesFactsRepositoryProvider =
    Provider<SpeciesFactsRepository>(
      (Ref ref) => throw UnimplementedError('override with dataOverrides() in main()'),
    );

/// S6's grid.
final Provider<SpeciesBrowseRepository> speciesBrowseRepositoryProvider =
    Provider<SpeciesBrowseRepository>(
      (Ref ref) => throw UnimplementedError('override with dataOverrides() in main()'),
    );

/// S2's static half.
final Provider<SpeciesAccountRepository> speciesAccountRepositoryProvider =
    Provider<SpeciesAccountRepository>(
      (Ref ref) => throw UnimplementedError('override with dataOverrides() in main()'),
    );

/// The species one species is mistaken for.
final Provider<LookAlikeRepository> lookAlikeRepositoryProvider = Provider<LookAlikeRepository>(
  (Ref ref) => throw UnimplementedError('override with dataOverrides() in main()'),
);

/// What this place has seen recently — the one seam that spans both databases.
final Provider<SpeciesRecentRepository> speciesRecentRepositoryProvider =
    Provider<SpeciesRecentRepository>(
      (Ref ref) => throw UnimplementedError('override with dataOverrides() in main()'),
    );

/// What this device's screen measures.
final Provider<CalibrationRepository> calibrationRepositoryProvider =
    Provider<CalibrationRepository>(
      (Ref ref) => throw UnimplementedError('override with dataOverrides() in main()'),
    );

/// Every seam `dataOverrides` must fill.
///
/// A list rather than a comment, so "is this one wired?" is a test rather than
/// a review: a seam added to `providers.dart` and forgotten in
/// `bootstrap_data.dart` is a throw on a screen several epics from here.
final List<ProviderBase<Object?>> kDataSeams = <ProviderBase<Object?>>[
  referenceDatabaseProvider,
  userDatabaseProvider,
  referenceRepositoryProvider,
  measurementRepositoryProvider,
  settingsRepositoryProvider,
  speciesSearchRepositoryProvider,
  speciesFactsRepositoryProvider,
  speciesBrowseRepositoryProvider,
  speciesAccountRepositoryProvider,
  lookAlikeRepositoryProvider,
  speciesRecentRepositoryProvider,
  calibrationRepositoryProvider,
];
