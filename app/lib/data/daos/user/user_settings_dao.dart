import 'package:catchlaw/data/services/tables/user/app_meta.dart';
import 'package:catchlaw/data/services/tables/user/rule_flag.dart';
import 'package:catchlaw/data/services/tables/user/saved_zone.dart';
import 'package:catchlaw/data/services/tables/user/species_recent.dart';
import 'package:catchlaw/data/services/tables/user/user_profile.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:drift/drift.dart';

part 'user_settings_dao.g.dart';

/// Reads and writes the settings singleton.
@DriftAccessor(tables: <Type>[UserProfiles])
class UserProfileDao extends DatabaseAccessor<UserDatabase> with _$UserProfileDaoMixin {
  /// Reads the profile from [db].
  UserProfileDao(super.db);

  /// The one settings row, as a live stream.
  ///
  /// `watchSingle`, not `watchSingleOrNull`: `CHECK (id = 1)` and the
  /// `beforeOpen` seed together mean the row always exists, and a nullable
  /// stream here would push a `?` into every screen that reads a setting.
  Stream<UserProfileRow> watchProfile() =>
      (select(userProfiles)..where(($UserProfilesTable t) => t.id.equals(1))).watchSingle();

  /// The one settings row, once.
  Future<UserProfileRow> read() =>
      (select(userProfiles)..where(($UserProfilesTable t) => t.id.equals(1))).getSingle();

  /// Updates the settings row.
  Future<int> updateProfile(UserProfilesCompanion changes) =>
      (update(userProfiles)..where(($UserProfilesTable t) => t.id.equals(1))).write(changes);
}

/// Reads and writes the fisher's saved places.
@DriftAccessor(tables: <Type>[SavedZones])
class SavedZoneDao extends DatabaseAccessor<UserDatabase> with _$SavedZoneDaoMixin {
  /// Reads saved zones from [db].
  SavedZoneDao(super.db);

  /// Every saved zone, in the fisher's own order.
  Stream<List<SavedZoneRow>> watchAll() =>
      (select(savedZones)..orderBy(<OrderClauseGenerator<$SavedZonesTable>>[
            ($SavedZonesTable t) => OrderingTerm(expression: t.sortOrder),
          ]))
          .watch();

  /// Saves a zone, or relabels the one already saved for that code pair.
  ///
  /// The conflict target is the `(jurisdiction_code, zone_code)` UNIQUE, not the
  /// primary key. drift's `insertOnConflictUpdate` targets the primary key, and
  /// with an autoincrement id it never conflicts — so saving the same place
  /// twice raises `UNIQUE constraint failed` instead of relabelling it, and the
  /// fisher gets an error for tapping the star twice.
  Future<int> save({required String jurisdictionCode, required String zoneCode, String? label}) =>
      into(savedZones).insert(
        SavedZonesCompanion.insert(
          jurisdictionCode: jurisdictionCode,
          zoneCode: zoneCode,
          label: Value<String?>(label),
        ),
        onConflict: DoUpdate<$SavedZonesTable, SavedZoneRow>(
          ($SavedZonesTable old) => SavedZonesCompanion(label: Value<String?>(label)),
          target: <Column<Object>>[savedZones.jurisdictionCode, savedZones.zoneCode],
        ),
      );

  /// Removes one.
  Future<int> remove(int id) =>
      (delete(savedZones)..where(($SavedZonesTable t) => t.id.equals(id))).go();

  /// Rewrites the order, in one transaction.
  ///
  /// A half-applied reorder is a list with two zones at position 3 and none at
  /// position 5, which renders as a list that has quietly lost a place.
  Future<void> reorder(List<int> idsInOrder) => db.transaction(() async {
    for (var i = 0; i < idsInOrder.length; i++) {
      await (update(savedZones)..where(($SavedZonesTable t) => t.id.equals(idsInOrder[i]))).write(
        SavedZonesCompanion(sortOrder: Value<int>(i)),
      );
    }
  });
}

/// Reads the species this place has seen recently.
@DriftAccessor(tables: <Type>[SpeciesRecents])
class SpeciesRecentDao extends DatabaseAccessor<UserDatabase> with _$SpeciesRecentDaoMixin {
  /// Reads recents from [db].
  SpeciesRecentDao(super.db);

  /// What S1 offers first: most used, then most recent.
  ///
  /// Keyed by exactly the three columns of the primary key, which is why
  /// §7.2 makes the table `WITHOUT ROWID` — the key IS the access path, on the
  /// 1.2 s cold-start render.
  Stream<List<SpeciesRecentRow>> watchRecent({
    required String jurisdictionCode,
    required String zoneCode,
    int limit = 12,
  }) =>
      (select(speciesRecents)
            ..where(
              ($SpeciesRecentsTable t) =>
                  t.jurisdictionCode.equals(jurisdictionCode) & t.zoneCode.equals(zoneCode),
            )
            ..orderBy(<OrderClauseGenerator<$SpeciesRecentsTable>>[
              ($SpeciesRecentsTable t) =>
                  OrderingTerm(expression: t.useCount, mode: OrderingMode.desc),
              ($SpeciesRecentsTable t) =>
                  OrderingTerm(expression: t.lastUsedAt, mode: OrderingMode.desc),
            ])
            ..limit(limit))
          .watch();

  /// Records that this species was opened here, now.
  ///
  /// **Upsert, not read-modify-write.** Two taps a frame apart on a wet screen
  /// would otherwise both read `use_count = 3` and both write `4`, and the
  /// species the fisher actually catches most would drift down the strip. The
  /// increment happens inside SQLite, where the row is locked.
  Future<void> recordUse({
    required int speciesId,
    required String jurisdictionCode,
    required String zoneCode,
    required String at,
  }) => customStatement(
    'INSERT INTO species_recent (species_id, jurisdiction_code, zone_code, use_count, last_used_at) '
    'VALUES (?1, ?2, ?3, 1, ?4) '
    'ON CONFLICT (species_id, jurisdiction_code, zone_code) DO UPDATE SET '
    'use_count = use_count + 1, last_used_at = excluded.last_used_at',
    <Object>[speciesId, jurisdictionCode, zoneCode, at],
  );
}

/// Reads and writes "this looks wrong to me".
///
/// Local only. It is a note the fisher can export (§12), never a report the app
/// sends — there is no network code path to send it down.
@DriftAccessor(tables: <Type>[RuleFlags])
class RuleFlagDao extends DatabaseAccessor<UserDatabase> with _$RuleFlagDaoMixin {
  /// Reads flags from [db].
  RuleFlagDao(super.db);

  /// Every flag, newest first.
  Stream<List<RuleFlagRow>> watchAll() =>
      (select(ruleFlags)..orderBy(<OrderClauseGenerator<$RuleFlagsTable>>[
            ($RuleFlagsTable t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
          .watch();

  /// Records one.
  Future<int> flag({
    required int ruleId,
    required String note,
    required String createdAt,
    String? citationRef,
  }) => into(ruleFlags).insert(
    RuleFlagsCompanion.insert(
      ruleId: ruleId,
      note: note,
      createdAt: createdAt,
      citationRef: Value<String?>(citationRef),
    ),
  );
}

/// Reads and writes `app_meta`. What [AppMetaMarkerStore] sits on.
@DriftAccessor(tables: <Type>[AppMetas])
class AppMetaDao extends DatabaseAccessor<UserDatabase> with _$AppMetaDaoMixin {
  /// Reads app metadata from [db].
  AppMetaDao(super.db);

  /// One value, or `null`.
  Future<String?> read(String key) async => (await (select(
    appMetas,
  )..where(($AppMetasTable t) => t.key.equals(key))).getSingleOrNull())?.value;

  /// Writes one value, replacing whatever was there.
  Future<int> write(String key, String value) =>
      into(appMetas).insertOnConflictUpdate(AppMetasCompanion.insert(key: key, value: value));

  /// Everything, for the About screen and the §12 export.
  Future<Map<String, String>> readAll() async {
    final List<AppMetaRow> rows = await select(appMetas).get();
    return <String, String>{for (final AppMetaRow r in rows) r.key: r.value};
  }
}
