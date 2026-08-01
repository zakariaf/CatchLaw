import 'package:catchlaw/data/services/tables/user/catch.dart';
import 'package:catchlaw/data/services/tables/user/species_recent.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:drift/drift.dart';

part 'catch_dao.g.dart';

/// One species' contribution to the day's tally.
typedef SpeciesTally = ({int speciesId, String scientificName, int count, int kept});

/// Reads and writes the fisher's catches.
///
/// **Every mutation is one `db.transaction` with every query inside awaited.** A
/// missing `await` inside a transaction lets the block close before the
/// statement runs, and the statement then executes outside it — so a "record the
/// catch and bump the recent-species counter" pair can half-commit, and the
/// tally the fisher checks against an inspector is wrong by one.
@DriftAccessor(tables: <Type>[Catches, SpeciesRecents])
class CatchDao extends DatabaseAccessor<UserDatabase> with _$CatchDaoMixin {
  /// Reads catches from [db].
  CatchDao(super.db);

  /// The catches of one trip, newest first, as a live stream.
  Stream<List<CatchRow>> watchForTrip(int tripId) =>
      (select(catches)
            ..where(($CatchesTable t) => t.tripId.equals(tripId))
            ..orderBy(<OrderClauseGenerator<$CatchesTable>>[
              ($CatchesTable t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
            ]))
          .watch();

  /// The day's tally for one place, as a live stream.
  ///
  /// `SPEC.md` §7.2 puts the codes on the catch precisely so this works for a
  /// quick-add with no trip. Grouped in SQL rather than in Dart: S8 rebuilds on
  /// every insert, and folding a season of rows in the UI isolate is a dropped
  /// frame at the moment a fish is landed.
  Stream<List<SpeciesTally>> watchTallyForDay(
    String isoDay, {
    required String jurisdictionCode,
    required String zoneCode,
  }) =>
      customSelect(
        'SELECT species_id, scientific_name, count(*) AS n, '
        'sum(was_kept) AS kept FROM catch '
        'WHERE jurisdiction_code = ?1 AND zone_code = ?2 AND created_at LIKE ?3 '
        'GROUP BY species_id, scientific_name ORDER BY n DESC, scientific_name',
        variables: <Variable<Object>>[
          Variable<String>(jurisdictionCode),
          Variable<String>(zoneCode),
          Variable<String>('$isoDay%'),
        ],
        readsFrom: <ResultSetImplementation<HasResultSet, Object>>{catches},
      ).watch().map(
        (List<QueryRow> rows) => <SpeciesTally>[
          for (final QueryRow r in rows)
            (
              speciesId: r.read<int>('species_id'),
              scientificName: r.read<String>('scientific_name'),
              count: r.read<int>('n'),
              kept: r.read<int>('kept'),
            ),
        ],
      );

  /// The page of catches older than [cursorCreatedAt].
  ///
  /// A **keyset** cursor, not an OFFSET. `created_at` is an ISO-8601 UTC string,
  /// which sorts lexicographically in chronological order, so `idx_catch_created`
  /// serves this directly. An OFFSET re-walks every earlier row on every page,
  /// which on a season's log is a scroll that gets slower the further back the
  /// fisher looks — and a row inserted mid-scroll shifts the window and shows
  /// one twice.
  Future<List<CatchRow>> pageBefore(String cursorCreatedAt, {int limit = 30}) =>
      (select(catches)
            ..where(($CatchesTable t) => t.createdAt.isSmallerThanValue(cursorCreatedAt))
            ..orderBy(<OrderClauseGenerator<$CatchesTable>>[
              ($CatchesTable t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
            ])
            ..limit(limit))
          .get();

  /// Records a catch and bumps the species' recency, in one transaction.
  ///
  /// The pair is atomic because a half-committed pair is a tally that disagrees
  /// with the log it was counted from.
  Future<int> insertCatch(CatchesCompanion entry) => db.transaction(() async {
    final int id = await into(catches).insert(entry);
    await customStatement(
      'INSERT INTO species_recent (species_id, jurisdiction_code, zone_code, use_count, '
      'last_used_at) VALUES (?1, ?2, ?3, 1, ?4) '
      'ON CONFLICT (species_id, jurisdiction_code, zone_code) DO UPDATE SET '
      'use_count = use_count + 1, last_used_at = excluded.last_used_at',
      <Object?>[
        entry.speciesId.value,
        entry.jurisdictionCode.value,
        entry.zoneCode.value,
        entry.createdAt.value,
      ],
    );
    return id;
  });

  /// One catch, or `null`.
  ///
  /// Read back after an insert so a caller renders what is STORED rather than
  /// what it hoped to store — §7.2's DEFAULTs are applied by SQLite, and a
  /// value reassembled from the draft would report them as whatever the draft
  /// happened to say.
  Future<CatchRow?> byId(int id) =>
      (select(catches)..where(($CatchesTable t) => t.id.equals(id))).getSingleOrNull();

  /// Updates a catch. `updated_at` is the caller's: this layer reads no clock.
  Future<bool> updateCatch(CatchRow row) => update(catches).replace(row);

  /// Deletes one catch.
  Future<int> deleteCatch(int id) =>
      (delete(catches)..where(($CatchesTable t) => t.id.equals(id))).go();
}
