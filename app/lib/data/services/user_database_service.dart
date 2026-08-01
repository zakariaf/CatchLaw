import 'dart:io';

import 'package:catchlaw/data/services/tables/user/app_meta.dart';
import 'package:catchlaw/data/services/tables/user/catch.dart';
import 'package:catchlaw/data/services/tables/user/rule_flag.dart';
import 'package:catchlaw/data/services/tables/user/saved_zone.dart';
import 'package:catchlaw/data/services/tables/user/species_recent.dart';
import 'package:catchlaw/data/services/tables/user/trip.dart';
import 'package:catchlaw/data/services/tables/user/user_profile.dart';
import 'package:catchlaw/data/services/user_migration.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'user_database_service.g.dart';

/// The writable half: everything in `SPEC.md` §7.2.
///
/// **The opposite lifecycle to `reference.db`, and therefore the opposite
/// pragmas.** The rule book is regenerable and read-only, so its connection sets
/// nothing that writes. This one holds data that exists nowhere else — there is
/// no cloud copy to recover from — so `synchronous = FULL` rather than `NORMAL`:
/// SQLite states that WAL with `NORMAL` may roll back the last transactions
/// after a power failure, and a fisher's last catch is exactly the row a power
/// failure would take.
///
/// A content update replaces `reference.db` wholesale and **cannot touch this
/// file**. That separation is the reason the two are separate databases rather
/// than one with an `ATTACH`.
@DriftDatabase(
  tables: <Type>[UserProfiles, SavedZones, Trips, Catches, SpeciesRecents, RuleFlags, AppMetas],
)
class UserDatabase extends _$UserDatabase {
  /// Opens the fisher's log over [executor].
  UserDatabase(super.executor);

  /// The schema version this build of the app understands.
  ///
  /// Named separately from [schemaVersion] because E05/T06 compares it against
  /// what is actually in the file: a database written by a NEWER build is
  /// refused rather than opened, because drift would otherwise run no migration
  /// at all and the app would read columns it does not know about as absent.
  static const int understoodSchemaVersion = 1;

  @override
  int get schemaVersion => understoodSchemaVersion;

  @override
  MigrationStrategy get migration => userMigration(this);
}

/// A [LazyDatabase] over the fisher's log at [file].
///
/// Lazy because `FLUTTER_GUIDE.md` §5.2 forbids awaiting a database open before
/// `runApp`, and background because this connection genuinely writes: a
/// `synchronous = FULL` commit on the platform thread is a dropped frame at the
/// moment a catch is recorded.
QueryExecutor userExecutor(File file) =>
    LazyDatabase(() async => NativeDatabase.createInBackground(file));
