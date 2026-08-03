import 'dart:io';

import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/repositories/calibration_repository_drift.dart';
import 'package:catchlaw/data/repositories/content_string_repository_drift.dart';
import 'package:catchlaw/data/repositories/look_alike_repository_drift.dart';
import 'package:catchlaw/data/repositories/measurement_repository_drift.dart';
import 'package:catchlaw/data/repositories/reference_repository_drift.dart';
import 'package:catchlaw/data/repositories/settings_repository_drift.dart';
import 'package:catchlaw/data/repositories/species_account_repository_drift.dart';
import 'package:catchlaw/data/repositories/species_browse_repository_drift.dart';
import 'package:catchlaw/data/repositories/species_facts_repository_drift.dart';
import 'package:catchlaw/data/repositories/species_recent_repository_drift.dart';
import 'package:catchlaw/data/repositories/species_search_repository_drift.dart';
import 'package:catchlaw/data/services/app_directories.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/reference_installer.dart';
import 'package:catchlaw/data/services/user_database_opener.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:path/path.dart' as p;

/// The real data layer, wired into the seams of `providers.dart`.
///
/// **Synchronous, and that is the requirement.** `catchlaw-conventions-index`
/// rule 8: nothing is awaited before `runApp`. Both `UserDatabase` and
/// `ReferenceDatabase` take a `LazyDatabase`, which opens nothing until the
/// first query — so this resolves no directory, touches no file and needs no
/// platform channel. An `await` here is a black screen on a dark boat, and a
/// black screen is indistinguishable from a crashed app.
///
/// [directories] is a port precisely so this stays true: `path_provider` needs
/// a platform channel, and the channel is called inside the lazy callback,
/// after the first frame.
List<Override> dataOverrides({required AppDirectories directories}) {
  final reference = ReferenceDatabase(
    referenceExecutorAt(() async => _file(await directories.reference(), _kReferenceFile)),
  );
  final user = UserDatabase(
    guardedUserExecutorAt(() async => _file(await directories.user(), _kUserFile)),
  );

  return <Override>[
    // ref.onDispose closes each database with the root scope. Not autoDispose:
    // an app-scope singleton that tore down with its last listener would reopen
    // SQLite on the next navigation.
    referenceDatabaseProvider.overrideWith((Ref ref) {
      ref.onDispose(reference.close);
      return reference;
    }),
    userDatabaseProvider.overrideWith((Ref ref) {
      ref.onDispose(user.close);
      return user;
    }),
    referenceRepositoryProvider.overrideWith(
      (Ref ref) => DriftReferenceRepository(ref.watch(referenceDatabaseProvider)),
    ),
    measurementRepositoryProvider.overrideWith(
      (Ref ref) => DriftMeasurementRepository(ref.watch(userDatabaseProvider)),
    ),
    settingsRepositoryProvider.overrideWith(
      (Ref ref) => DriftSettingsRepository(ref.watch(userDatabaseProvider)),
    ),
    speciesSearchRepositoryProvider.overrideWith(
      (Ref ref) => DriftSpeciesSearchRepository(ref.watch(referenceDatabaseProvider)),
    ),
    speciesFactsRepositoryProvider.overrideWith(
      (Ref ref) => DriftSpeciesFactsRepository(ref.watch(referenceDatabaseProvider)),
    ),
    calibrationRepositoryProvider.overrideWith(
      (Ref ref) => DriftCalibrationRepository(ref.watch(userDatabaseProvider)),
    ),
    contentStringRepositoryProvider.overrideWith(
      (Ref ref) => ContentStringRepositoryDrift(ref.watch(referenceDatabaseProvider)),
    ),
    speciesRecentRepositoryProvider.overrideWith(
      (Ref ref) => DriftSpeciesRecentRepository(
        userDb: ref.watch(userDatabaseProvider),
        referenceDb: ref.watch(referenceDatabaseProvider),
      ),
    ),
    lookAlikeRepositoryProvider.overrideWith(
      (Ref ref) => DriftLookAlikeRepository(
        ref.watch(referenceDatabaseProvider),
        contentStrings: ContentStringRepositoryDrift(ref.watch(referenceDatabaseProvider)),
      ),
    ),
    speciesAccountRepositoryProvider.overrideWith(
      (Ref ref) => DriftSpeciesAccountRepository(
        ref.watch(referenceDatabaseProvider),
        contentStrings: ContentStringRepositoryDrift(ref.watch(referenceDatabaseProvider)),
      ),
    ),
    speciesBrowseRepositoryProvider.overrideWith(
      (Ref ref) => DriftSpeciesBrowseRepository(
        ref.watch(referenceDatabaseProvider),
        contentStrings: ContentStringRepositoryDrift(ref.watch(referenceDatabaseProvider)),
      ),
    ),
  ];
}

/// Riverpod's retry policy for CatchLaw: **do not**.
///
/// Riverpod 3 retries a failing provider through roughly 38 s of exponential
/// backoff. Every failure reachable in this app is local — a corrupt file, a
/// missing asset, a database from a build that has not shipped yet — and none
/// of them get better by waiting. Retrying turns T06's refusal into half a
/// minute of spinner on a screen whose whole job is to state a fact.
Duration? noRetry(int retryCount, Object error) => null;

const String _kReferenceFile = ReferenceInstaller.kFileName;
const String _kUserFile = 'user.db';

File _file(Directory dir, String name) => File(p.join(dir.path, name));
