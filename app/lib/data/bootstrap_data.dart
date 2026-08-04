import 'dart:io';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/repositories/calibration_repository_drift.dart';
import 'package:catchlaw/data/repositories/catch_log_repository_drift.dart';
import 'package:catchlaw/data/repositories/content_string_repository_drift.dart';
import 'package:catchlaw/data/repositories/legal_text_repository_drift.dart';
import 'package:catchlaw/data/repositories/look_alike_repository_drift.dart';
import 'package:catchlaw/data/repositories/measurement_repository_drift.dart';
import 'package:catchlaw/data/repositories/reference_repository_drift.dart';
import 'package:catchlaw/data/repositories/rule_flag_repository_drift.dart';
import 'package:catchlaw/data/repositories/settings_repository_drift.dart';
import 'package:catchlaw/data/repositories/species_account_repository_drift.dart';
import 'package:catchlaw/data/repositories/species_browse_repository_drift.dart';
import 'package:catchlaw/data/repositories/species_facts_repository_drift.dart';
import 'package:catchlaw/data/repositories/species_recent_repository_drift.dart';
import 'package:catchlaw/data/repositories/species_search_repository_drift.dart';
import 'package:catchlaw/data/services/app_directories.dart';
import 'package:catchlaw/data/services/app_meta_marker_store.dart';
import 'package:catchlaw/data/services/asset_bundle_service.dart';
import 'package:catchlaw/data/services/reference/content_build.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/reference_installer.dart';
import 'package:catchlaw/data/services/user_database_opener.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:path/path.dart' as p;
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

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
List<Override> dataOverrides({
  required AppDirectories directories,
  AssetBundleService bundle = const RootBundleAssetService(),
}) {
  final user = UserDatabase(
    guardedUserExecutorAt(() async => _file(await directories.user(), _kUserFile)),
  );
  final reference = ReferenceDatabase(
    // **Extracted before it is opened, and inside the lazy callback.** The
    // shipped asset is a `.gz` (D-6); on a first launch there is no
    // `reference.db` on disk at all, and a read-only open of a file that does
    // not exist is `SqliteException(14)` — which the picker renders honestly as
    // "the bundled rule pack could not be read", and which is nonetheless a
    // wiring defect rather than a broken pack.
    //
    // Here rather than in `main()`: `LazyDatabase` runs this on the first
    // QUERY, after the first frame, so nothing is awaited before `runApp`
    // (`catchlaw-conventions-index` rule 8). The extraction is idempotent — the
    // marker in `user.db` is what makes the second launch skip it.
    referenceExecutorAt(() async => _installedReference(directories, user, bundle)),
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
    catchLogRepositoryProvider.overrideWith(
      (Ref ref) => DriftCatchLogRepository(ref.watch(userDatabaseProvider)),
    ),
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
    legalTextRepositoryProvider.overrideWith(
      (Ref ref) => DriftLegalTextRepository(ref.watch(referenceDatabaseProvider)),
    ),
    ruleFlagRepositoryProvider.overrideWith(
      (Ref ref) => DriftRuleFlagRepository(ref.watch(userDatabaseProvider)),
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

const String _kUserFile = 'user.db';

File _file(Directory dir, String name) => File(p.join(dir.path, name));

/// The extracted `reference.db`, installing it first if this build has not been.
///
/// Throws rather than returning a missing file. A `Result` that the executor
/// swallowed would surface as the same `SqliteException(14)` the extraction
/// exists to prevent, three frames later and with the cause gone — and the
/// installer's failure type already says which of the four things went wrong.
Future<File> _installedReference(
  AppDirectories directories,
  UserDatabase user,
  AssetBundleService bundle,
) async {
  final Result<File> installed = await ReferenceInstaller(
    bundle: bundle,
    directories: directories,
    // One marker, in `user.db`, written last. Two markers would be one too
    // many, and the one that is not written last is the one that lies (D-6).
    marker: AppMetaMarkerStore(user),
    expected: kReferenceBuild,
  ).ensureInstalled();

  return switch (installed) {
    Ok<File>(:final File value) => value,
    Failure<File>(:final Exception exception) => throw exception,
  };
}
