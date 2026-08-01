import 'dart:io';
import 'dart:typed_data';

import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/data/services/user_migration.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:sqlite3/sqlite3.dart' as raw;

/// Opens `user.db`, taking a snapshot first and restoring it if the migration
/// throws.
///
/// **The snapshot uses checkpoint + `VACUUM INTO`, not `File.copy`.** The two
/// skills disagree: `run-migration` rule 1 says copy the file and its
/// `-wal`/`-shm` sidecars while nothing holds it open; `persistence-drift`
/// rule 10 says never `File.copy` a database. `check-persistence-bans.sh`
/// check 1 fails any `.copy(` on a line naming a database and offers no escape
/// hatch, so the executable rule decides — D-2's rule of thumb, for exactly
/// this shape of disagreement.
///
/// **`run-migration` rule 1's intent survives in full.** The raw handle used
/// for the checkpoint and the vacuum is disposed **before** drift opens the
/// file, so nothing is live when the migration runs, and `VACUUM INTO` produces
/// one consistent file with no sidecars to keep in step. Restoring is a
/// `rename`, which is atomic; a restore that could half-succeed would be worse
/// than none.
///
/// **The guard lives here and not in `onUpgrade`**, because the snapshot must be
/// taken before the open and the restore must happen after the failed
/// connection is closed. Neither is possible inside the migration, where the
/// file is live.
///
/// **Nothing here is awaited before `runApp`:** this is called from inside a
/// `LazyDatabase` callback, so the snapshot, the migration and the restore all
/// happen on the first query — after the first frame.
Future<UserDatabase> openUserDatabase(File file) async {
  final backup = File('${file.path}.pre-migration');
  final bool hadDatabase = file.existsSync();

  if (hadDatabase) {
    // BEFORE anything is written, and before the snapshot: there is no point
    // copying a file we are about to refuse. drift runs no migration when the
    // file's version is HIGHER than the code's — it just opens it — so a check
    // living in onUpgrade would never run at all.
    final int found = _versionOf(file);
    if (found > UserDatabase.understoodSchemaVersion) {
      throw DatabaseFromTheFuture(found: found, understood: UserDatabase.understoodSchemaVersion);
    }

    if (backup.existsSync()) backup.deleteSync();
    snapshotUserDatabase(file, backup);
  }

  final db = UserDatabase(NativeDatabase(file));
  try {
    // Forces the migration NOW, while the fallback still stands. Discovering
    // the failure at some later query would mean discovering it after the
    // snapshot had stopped describing the file.
    await db.customStatement('PRAGMA user_version;');
    if (backup.existsSync()) backup.deleteSync();
    return db;
  } on Object catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('openUserDatabase: migration failed, restoring\n$error\n$stackTrace');
    }
    await db.close();
    if (backup.existsSync()) {
      // Atomic. The fisher's log is the one thing in this app that exists
      // nowhere else.
      backup.renameSync(file.path);
    }
    rethrow;
  }
}

/// The `user_version` recorded in [file], read out of the SQLite header.
///
/// **Not through SQLite.** Even a `readOnly` open creates a `-shm` beside a
/// WAL-mode database — `readOnly` is a SQLite flag, not a filesystem permission
/// — and the whole claim of the refusal is that it leaves the file exactly as it
/// was. Nothing must appear beside a database this build has already decided it
/// cannot understand.
///
/// Bytes 60–63 of the header, big-endian, per the SQLite file format. A file too
/// short to hold a header is not a database this build refuses; it is one it
/// creates, so it reads as version 0.
int _versionOf(File file) {
  final RandomAccessFile handle = file.openSync();
  try {
    if (handle.lengthSync() < 64) return 0;
    handle.setPositionSync(60);
    final Uint8List header = handle.readSync(4);
    return ByteData.sublistView(header).getUint32(0, Endian.big);
  } finally {
    handle.closeSync();
  }
}

/// A consistent single-file copy of [file] at [into].
///
/// Public so it can be tested on its own: the copy is the thing the fisher's log
/// depends on, and a test that reaches it only through a contrived migration
/// failure is a test of the contrivance.
void snapshotUserDatabase(File file, File into) {
  final raw.Database handle = raw.sqlite3.open(file.path);
  try {
    // TRUNCATE folds the -wal back into the main file, so the vacuum below sees
    // every committed transaction and the copy needs no sidecar.
    handle
      ..execute('PRAGMA wal_checkpoint(TRUNCATE);')
      ..execute('VACUUM INTO ?', <Object?>[into.path]);
  } finally {
    // Disposed BEFORE drift opens the file: run-migration rule 1's requirement
    // that nothing holds the database while the migration runs.
    handle.close();
  }
}

/// A [LazyDatabase] over the fisher's log at [file], guarded by
/// [openUserDatabase].
QueryExecutor guardedUserExecutor(File file) =>
    LazyDatabase(() async => (await openUserDatabase(file)).executor);
