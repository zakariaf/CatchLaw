import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:drift/drift.dart';

/// A `user.db` written by a build of the app newer than this one.
///
/// **Refused, not opened.** drift runs no migration when the file's version is
/// higher than the code's — it opens the database and carries on. Every column
/// a newer build added is then a column this build reads as absent, and every
/// row it writes is a row the newer build will read back with those columns
/// silently empty. The fisher downgrades once, uses the app for a week, and
/// upgrades to find a week of catches with their measurement method gone.
///
/// `SPEC.md` §7.4: forward-only. Backwards is not a migration, it is a data
/// loss with a progress bar.
final class DatabaseFromTheFuture implements Exception {
  /// A file at [found] opened by a build that understands [understood].
  const DatabaseFromTheFuture({required this.found, required this.understood});

  /// The schema version in the file.
  final int found;

  /// The schema version this build knows.
  final int understood;

  /// The stable identifier a log line and a support conversation both name.
  String get code => 'user_db.from_the_future';

  @override
  String toString() => '$code(found v$found, this build understands v$understood)';
}

/// The forward-only migration for `user.db`.
///
/// **`foreign_keys` is toggled OUTSIDE the transaction, and checked after the
/// body.** `PRAGMA foreign_keys` is silently ignored once a transaction is open
/// — a migration that toggles it inside one has simply not toggled it. So it
/// goes off at the top, the steps run in one transaction, and then
/// `PRAGMA foreign_key_check` runs **in production, not only in tests**: a
/// migration that leaves a dangling reference has lost a record, and SQLite will
/// report it to nobody.
MigrationStrategy userMigration(UserDatabase db) => MigrationStrategy(
  onCreate: (Migrator m) => m.createAll(),
  onUpgrade: (Migrator m, int from, int to) async {
    // A database from the FUTURE. drift only calls onUpgrade when the file's
    // version is lower, so this is belt-and-braces for a path drift does not
    // reach — the real guard is in openUserDatabase, before drift is given the
    // file at all.
    if (from > to) throw DatabaseFromTheFuture(found: from, understood: to);
    await db.customStatement('PRAGMA foreign_keys = OFF;');
    await m.database.transaction(() async {
      await _steps(m, from, to);
    });
    final List<QueryRow> dangling = await db.customSelect('PRAGMA foreign_key_check').get();
    if (dangling.isNotEmpty) {
      throw StateError(
        'migration $from -> $to left ${dangling.length} dangling references; '
        'the fisher has lost a record and SQLite would have told nobody',
      );
    }
    await db.customStatement('PRAGMA foreign_keys = ON;');
  },
  beforeOpen: (OpeningDetails details) async {
    // Per-connection and NOT persisted in the file, so they are re-asserted on
    // every open. `journal_mode` IS persisted, but is set idempotently so a
    // freshly created or restored database adopts it.
    await db.customStatement('PRAGMA foreign_keys = ON;');
    await db.customStatement('PRAGMA journal_mode = WAL;');
    await db.customStatement('PRAGMA synchronous = FULL;');
    await db.customStatement('PRAGMA busy_timeout = 5000;');

    if (details.wasCreated) {
      // The one place seeding is licensed. NOT in onCreate, where a failure
      // would abort the create and leave a half-built database.
      await db.into(db.userProfiles).insert(UserProfilesCompanion.insert(id: const Value<int>(1)));
    }
  },
);

/// The per-version steps.
///
/// Empty at version 1 and deliberately so: `user.db` has no `from → to` pair
/// yet, and this is exactly when the harness around it is cheap to build and
/// impossible to retrofit under pressure. E13 or E16 adds the first case here
/// and the every-pair test loop is already non-empty the moment they do.
Future<void> _steps(Migrator m, int from, int to) async {
  for (var version = from; version < to; version++) {
    switch (version) {
      case 1:
        // The first real migration lands here. Nothing to do at v1 -> v1.
        break;
      default:
        throw UnsupportedError(
          'no migration step from schema version $version; user.db is '
          'forward-only and a version it cannot reach is a version it must '
          'refuse rather than guess at',
        );
    }
  }
}
