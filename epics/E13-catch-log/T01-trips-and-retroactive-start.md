# E13/T01 — Trips, including a retroactive start

| | |
|---|---|
| **Epic** | E13 — The catch log |
| **Branch** | `epic/13-catch-log` (shared) |
| **Commit** | `feat(data): start, end and retroactively open a trip, with one open trip enforced by the schema` |
| **Depends on** | — (first task of the epic; E05 merged) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.5 (Trip log), §7.2 (`trip`), §13 (crash safety) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `persistence-drift` | Rules 2, 4, 5, 7 and 8: invariants in the schema, one transaction per mutation with every statement awaited, canonical storage, the DAO↔repository split, scoped `.watch()` streams. This task writes the first of them. |
| `error-handling-typed-results` | The `Result`/`Failure` spine every repository method returns, and `references/never-lose-data.md` §1 — the blocking rollback test that proves the retroactive start is atomic. |
| `service-boundary-and-native` | Rule 8: "now" enters through `clockProvider` (`package:clock`) and nowhere else, so `started_at` is deterministic in tests. |
| `catchlaw-reference-database` | `references/two-database-contract.md` — `user.db` is the only writable and the only irreplaceable file, and no statement here may span both databases. |
| `catchlaw-conventions-index` | Rule 6, the one-way layer map: `trip` rows map to a value object inside `app/lib/data/`; nothing above sees a drift class. |
| `run-migration` | The forward-only ritual for the partial unique index this task adds. It ships `disable-model-invocation: true` — read the file and execute the steps by hand, in order, do not improvise. |
| `state-management-riverpod` | Rule 5 (single write path) and the DI shape for `tripRepositoryProvider`; the ViewModel that consumes it is T03's. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.2 `trip` | The seven columns and `idx_trip_started`. Do not add a column. |
| `SPEC.md` | §4.5 row "Trip log" | "Start/end a trip; catches attach to it; can be started retroactively" — the three behaviours this task owns. |
| `SPEC.md` | §13 row "Crash safety" | "Every write transactional… no in-memory-only state that matters." |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "Why two files at all", "The ATTACH ban" | `user.db` is the only copy of three seasons of trips; no SQL spans both files. |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | whole | The five invariants this task must not weaken. |
| `$FLUTTER_SKILLS/persistence-drift/references/schema-and-daos.md` | "Invariants live in the schema", "DAOs vs repositories", "The index & query-plan strategy" | Partial `UNIQUE INDEX` for uniqueness, single-table DAO vs cross-table repository, `NativeDatabase.memory()` for logic tests. |
| `$FLUTTER_SKILLS/error-handling-typed-results/references/never-lose-data.md` | §1 "One transaction per multi-table mutation" | The prep-outside/write-inside split, the forbidden-inside-a-transaction table, and the rollback test recipe copied verbatim below. |
| `FLUTTER_GUIDE.md` | Part 1.4, Part 5.2 | Drift behind a Service, the repository that takes no `Ref`, "return the stream, do not `await for` it". |
| `epics/DECISIONS.md` | D-1, D-5 | Paths; drift 2.34.2 and Riverpod 3.4.1. |
| `epics/E13-catch-log/epic.md` | Risks 4, 5, 9 | The §7.2-versus-`persistence-drift` shapes question is already settled in E05; do not re-open it. |

## What this delivers

- `app/lib/data/services/user_db/user_database.dart` — `schemaVersion` bumped by exactly one, one
  appended `stepByStep` branch creating `ux_one_open_trip`. No shipped step is edited.
- `app/drift_schemas/` — the committed schema snapshot for the new version, plus the regenerated
  `schema_versions.dart`.
- `app/lib/data/services/user_db/daos/trip_dao.dart` — `@DriftAccessor(tables: [Trips])`, single-table
  queries only: `watchOpenTrip()`, `watchTrips()`, `byId()`, `insertTrip()`, `setEndedAt()`.
- `app/lib/domain/models/trip.dart` — the immutable `Trip` value object with `bool get isOpen`.
- `app/lib/domain/failures/catch_log_failure.dart` — one sealed family under E05/T09's `DataFailure`:
  `TripAlreadyOpen`, `TripStartInTheFuture`, `TripNotFound`, `TripAlreadyEnded`,
  `CatchLogStoreUnavailable`, `CatchLogTransactionRolledBack`. Stable `code`, typed params, no strings.
- `app/lib/data/model/iso_utc.dart` — `formatIsoUtc(DateTime)` and `parseIsoUtc(String)`, the single
  owner of the timestamp format every `TEXT` timestamp column in `user.db` uses.
- `app/lib/data/model/trip_mapper.dart` — row → `Trip`, and the companion builder back.
- `app/lib/data/repositories/trip_repository.dart` — the abstract interface.
- `app/lib/data/repositories/trip_repository_drift.dart` — the drift implementation.
- `app/testing/fakes/fake_trip_repository.dart` — hand-written, `implements`, failure paths reachable.
- `app/lib/ui/log/providers/trip_providers.dart` — `tripRepositoryProvider` and
  `openTripProvider` (a `StreamProvider`, `autoDispose`).
- Tests: `app/test/data/repositories/trip_repository_test.dart`,
  `app/test/data/services/user_db/one_open_trip_index_test.dart`,
  `app/test/data/model/iso_utc_test.dart`, `app/test/domain/models/trip_test.dart`.

## Why it is built this way

**At most one trip is open at a time, and the schema is what says so.** T02 must decide which trip a
catch attaches to without asking, and a quick-add at 05:40 has nobody to ask. Two open trips make
that attachment ambiguous, and an ambiguous attachment corrupts every per-trip total in S10 and every
trip report in E17 silently. `persistence-drift` rule 2 says a corrupt row must be unrepresentable at
the storage layer rather than policed in Dart, so the invariant is a partial unique index:

```sql
CREATE UNIQUE INDEX ux_one_open_trip ON trip(ended_at IS NULL) WHERE ended_at IS NULL;
```

The indexed expression evaluates to `1` for every row the partial predicate admits, so a second open
row collides. It is an expression index over a column of the table being indexed, which SQLite
permits; test 4 below is what proves it on the real engine rather than on this paragraph.

**Rejected:** enforcing "one open trip" only in `TripRepositoryDrift`. E17's import writes rows
through its own transactional path, and a repository-level guard is exactly the kind of rule an
importer forgets. Rejected too: letting several trips stay open and asking the fisher which one on
every quick-add — that is a decision the app can answer itself, and the whole product exists to
remove decisions from a man holding a live fish.

**Retroactive means two things at once, and the second is the useful one.** `startTrip(at:)` accepts
an instant in the past, and in the *same transaction* adopts every catch that is still an orphan
(`trip_id IS NULL`) and was created at or after that instant. Without adoption, "start it
retroactively" only backdates a label; the three quick-adds the fisher already made stay outside the
trip and S10's per-trip total is wrong. Adoption is bounded **only** by time, not by jurisdiction or
zone: the catch carries its own `jurisdiction_code` and `zone_code` (§4.5), so a fisher who crossed a
zone boundary mid-morning still had one trip.

**A start in the future is refused, not clamped.** A `started_at` after `clock.now()` makes every
catch already recorded appear to precede its own trip, and S10 orders by time. `Err(TripStartInTheFuture)`
is a typed failure the UI can state; silently clamping to now would hide a device-clock problem that
§14 explicitly tests for by moving the clock.

**The prep happens outside the transaction.** `clock.now()` is resolved, the future check runs and
the ISO string is formatted before `_db.transaction(...)` opens, per
`never-lose-data.md` §1's forbidden-inside table. Reading the clock inside the body is listed there as
AVOID; awaiting anything unrelated is FORBIDDEN.

**One timestamp format, owned by one file.** `SPEC.md` §7.2 types timestamps as `TEXT`; E05's epic
Risks §3 records that this is safe *because ISO-8601 UTC strings sort lexicographically in
chronological order*. That is true only for a fixed-width, always-UTC form, so `iso_utc.dart` writes
`YYYY-MM-DDTHH:MM:SS.sssZ` and nothing else. `DateTime.toIso8601String()` on a local `DateTime`
emits no offset at all and would sort wrongly across a DST change; on a UTC `DateTime` it omits
trailing zeros in some Dart versions, which breaks fixed width. Both are rejected in favour of an
explicit formatter with its own test.

**Rejected:** storing `started_at` as epoch millis. `persistence-drift` rule 5 prefers it, and E05
already settled the question in favour of §7.2's `TEXT` because §12's export format and the
`(created_at, species_id, length_mm)` merge key are published against those shapes. This task does not
re-open it (epic Risks 4).

## Tests first

Write every row before touching `trip_dao.dart`. Run them. **They must fail.** A test that passes
before the implementation exists is testing nothing — fix the test, then write the code.

Tests run against a real `NativeDatabase.memory()`, never a `Map`-backed fake: a fake accepts rows a
real `CHECK` or partial unique index rejects, which is precisely what tests 4 and 8 exist to catch.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `TripRepository.startTrip stores startedAt from the injected clock` | `Clock.fixed(2026-08-01T05:41:12.000Z)` | row `started_at` = `2026-08-01T05:41:12.000Z` | Proves no `DateTime.now()` is reachable from the write path (`service-boundary-and-native` rule 8); a real clock makes every later assertion below non-deterministic |
| 2 | `IsoUtc.format writes a fixed-width UTC string with milliseconds` | `DateTime.utc(2026, 1, 2, 3, 4, 5)` | `2026-01-02T03:04:05.000Z` | The keyset cursor (T06) and §12's merge key compare these strings; a variable-width or offset-bearing form sorts wrongly and the defect surfaces only at a page boundary |
| 3 | `IsoUtc.format converts a local DateTime to UTC before writing` | a non-UTC `DateTime` | the same instant, `Z`-suffixed | The one-line mistake that makes every timestamp in the file incomparable; caught here, once |
| 4 | `UserDatabase rejects a second open trip` | raw insert of a second row with `ended_at` NULL | `SqliteException` | Rule 2 — the invariant lives in the schema, so E17's importer and any future DAO inherit it without knowing it exists |
| 5 | `TripRepository.startTrip returns TripAlreadyOpen when a trip is already open` | one open trip, then `startTrip()` | `Err(TripAlreadyOpen(id))` carrying the open id | The UI must be able to name the trip it will not open a second one over; a bare failure cannot |
| 6 | `TripRepository.startTrip returns TripStartInTheFuture when at is after the clock` | `at` = clock + 1 min | `Err(TripStartInTheFuture(at))`, zero rows written | §14 moves the device clock deliberately; a clamped start would hide the condition instead of stating it |
| 7 | `TripRepository.startTrip adopts an orphan catch recorded at or after the retroactive start` | orphans at t−3 h, t−30 min; `startTrip(at: t−1 h)` | the t−30 min row gains `trip_id`; the t−3 h row does not | The §4.5 headline case, plus the bound: adoption is a window, not "every orphan" |
| 8 | `TripRepository.startTrip leaves a catch that already belongs to a trip untouched` | one catch on a closed trip, inside the window | its `trip_id` is unchanged | Adoption must never steal a row out of a finished trip and silently rewrite its totals in S10 and in E17's PDF |
| 9 | `TripRepository.startTrip rolls back the insert when the adoption update fails` | forced constraint violation on the second statement | `Err(CatchLogTransactionRolledBack)` and `dumpAllRows()` byte-identical | `never-lose-data.md` §1's blocking test. A half-applied retroactive start leaves a trip with no catches and is invisible until someone reads S10 three weeks later |
| 10 | `TripRepository.startTrip bumps updatedAt on every adopted catch` | as case 7 | adopted row's `updated_at` = clock | §7.2 gives `catch` an `updated_at`; a row changed without stamping it defeats E17's merge tiebreak |
| 11 | `TripRepository.endTrip sets endedAt from the injected clock and leaves startedAt alone` | open trip, `endTrip(id)` | `ended_at` = clock, `started_at` unchanged | The paired write; a repository that rewrites `started_at` on close destroys a retroactive start |
| 12 | `TripRepository.endTrip returns TripAlreadyEnded when the trip is closed` | closed trip | `Err(TripAlreadyEnded(id))`, row unchanged | Two wet taps on **End trip** 90 ms apart must not rewrite yesterday's end time (`lonja-buttons` rule 11) |
| 13 | `TripRepository.endTrip returns TripNotFound with an unknown id` | id 999 | `Err(TripNotFound(999))` | E17's import can hand a stale id; a silent no-op returns `Ok` and looks like success |
| 14 | `TripRepository.watchOpenTrip emits null after the open trip is ended` | open trip, then `endTrip` | stream emits `Trip`, then `null` | `FLUTTER_GUIDE.md` §5.2 — the committed write is what republishes; if this fails someone added a manual `state =` |
| 15 | `TripMapper maps a row with a null label and null notes without loss` | row with both NULL | `Trip` with both `null`, and back to an identical row | Guide §2.5 rule 6: drift rows never escape `data/`; a lossy mapper drops `notes` and nobody notices until E17 exports it |
| 16 | `Trip.isOpen reports true when endedAt is null` | `Trip(endedAt: null)` | `true` | Derive, don't store (`persistence-drift` rule 6) — the open flag must never become a column that can disagree with `ended_at` |

```dart
// app/test/data/repositories/trip_repository_test.dart
import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late UserDatabase db;
  late TripRepository repo;
  final t0 = DateTime.utc(2026, 8, 1, 5, 41, 12);

  setUp(() {
    db = UserDatabase(NativeDatabase.memory()); // catchlaw-db-ok — in-memory test harness
    repo = TripRepositoryDrift(db, clock: Clock.fixed(t0));
  });
  tearDown(() => db.close());

  test('TripRepository.startTrip stores startedAt from the injected clock', () async {
    final result = await repo.startTrip();
    expect(result, isA<Ok<Trip, CatchLogFailure>>());
    final row = await db.select(db.trips).getSingle();
    expect(row.startedAt, '2026-08-01T05:41:12.000Z');
  });

  test('TripRepository.startTrip adopts an orphan catch recorded at or after the retroactive start',
      () async {
    await _seedOrphanCatch(db, createdAt: t0.subtract(const Duration(hours: 3)));
    await _seedOrphanCatch(db, createdAt: t0.subtract(const Duration(minutes: 30)));

    await repo.startTrip(at: t0.subtract(const Duration(hours: 1)));

    final rows = await db.select(db.catches).get();
    expect(rows.where((r) => r.tripId != null), hasLength(1));
    expect(rows.singleWhere((r) => r.tripId != null).createdAt,
        '2026-08-01T05:11:12.000Z');
  });

  test('TripRepository.startTrip rolls back the insert when the adoption update fails', () async {
    final before = await db.dumpAllRows();
    final result = await repo.startTrip(at: t0, adoptionFailsForTest: true);
    expect(result, isA<Err<Trip, CatchLogFailure>>());
    expect((result as Err).failure, isA<CatchLogTransactionRolledBack>());
    expect(await db.dumpAllRows(), equals(before)); // no partial write survived
  });

  // … one test per row above, one behaviour each
}
```

```dart
// app/test/data/services/user_db/one_open_trip_index_test.dart
test('UserDatabase rejects a second open trip', () async {
  await db.into(db.trips).insert(_openTripCompanion(zone: 'es-gal-rb'));
  await expectLater(
    db.into(db.trips).insert(_openTripCompanion(zone: 'es-gal-ar')),
    throwsA(isA<SqliteException>()),
  );
});
```

**Run:** `cd app && flutter test test/data test/domain/models/trip_test.dart` → 16 failures. If any
passes now, that test is wrong; fix the test before writing a line of production code.

## Implementation outline

1. **The migration, by the `run-migration` ritual, in order.** Snapshot first, `schemaVersion` + 1,
   append one `from(n).to(n+1)` branch that runs the `CREATE UNIQUE INDEX` above, run
   `drift_dev make-migrations`, commit the snapshot under `app/drift_schemas/` and the regenerated
   `schema_versions.dart`. Never edit a shipped step.
2. `iso_utc.dart` — two pure functions, no Flutter import, its own test file. Everything else in the
   epic formats through it.
3. `catch_log_failure.dart` — one sealed family, each variant a `final class` with a `const`
   constructor, `final` fields and a stable `code` (`trip.already_open`, `trip.start_in_future`, …).
   No `==`, no `hashCode`, no freezed: these are switched on by type, never compared.
4. `trip_dao.dart` — single-table only. `watchOpenTrip()` is `select(trips)..where((t) => t.endedAt.isNull())`
   mapped to `Trip?`; `watchTrips()` is scoped and ordered by `started_at DESC` to use `idx_trip_started`.
   Return value objects, never rows.
5. `trip_repository_drift.dart` — holds `UserDatabase` (not just the DAO) because `startTrip` is a
   cross-table transaction, which `persistence-drift` rule 7 puts in the repository. Shape:

   ```
   resolve now from the injected Clock, format it            // outside the transaction
   if (at != null && at.isAfter(now)) return Err(TripStartInTheFuture)
   if (await dao.openTripId() != null) return Err(TripAlreadyOpen)
   try {
     await db.transaction(() async {
       final id = await dao.insertTrip(...);                  // awaited
       await dao.adoptOrphansFrom(startedAt, tripId: id, at: nowIso); // awaited
     });
     return Ok(trip);
   } on SqliteException catch (e, st) { log first, then Err(...) }
   ```
6. `trip_repository.dart` — the abstract interface, value types only, every method `@useResult` and
   returning `Future<Result<T, CatchLogFailure>>` or `Stream<T>`.
7. `fake_trip_repository.dart` — `implements` (not `extends`) so a new interface method breaks the
   build, with constructors for the reachable failure paths.
8. `trip_providers.dart` — a plain `Provider` for the repository, a `StreamProvider.autoDispose` for
   the open trip. No logic in either body.
9. Re-run the whole suite, not just this file. E05's migration tests must still be green — a bumped
   `schemaVersion` with no matching branch means no migration runs at all on a real device.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 16 tests pass, and each failed first.
- [ ] `schemaVersion` moved by exactly one, exactly one step was appended, no shipped step was edited,
      and the schema snapshot is committed.
- [ ] Every E05 migration test still passes, including the multi-version jump.
- [ ] `startTrip` and `endTrip` are each exactly one `db.transaction` with every statement inside it
      awaited; nothing unrelated is awaited inside a body.
- [ ] No `DateTime.now()` appears anywhere in `app/lib/data/repositories/` or `app/lib/domain/`.
- [ ] `TripRepositoryDrift` touches no table in `reference.db`, and no `ATTACH` exists in `app/lib`.
- [ ] `Trip` is immutable, has no `isOpen` column behind it, and no drift type appears in its
      signature.
- [ ] Every `CatchLogFailure` variant carries a stable `code` and typed params, and zero user-facing
      strings.
- [ ] The rollback test asserts the database is byte-identical, not merely that an `Err` came back.

## Gates

```bash
dart format --set-exit-if-changed .
cd app && flutter analyze && flutter test && cd ..
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh    app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-drift-confinement.sh        app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-persistence-bans.sh         app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh app/lib
$FLUTTER_SKILLS/state-management-riverpod/scripts/ban-legacy-providers.sh   app/lib
```

Always pass the target directory. The in-repo gates exit 2 on a missing one; `check-drift-confinement.sh`
prints `SKIP` and exits **0**, which is worse — it looks like a pass.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

Both run **before** the commit and their findings are fixed inside it. A follow-up commit for a defect
this task's own review caught is churn (`CONVENTIONS.md` §2).

## Commit

```
feat(data): start, end and retroactively open a trip, with one open trip enforced by the schema

A quick-add has to attach itself to a trip without asking anybody, so at most
one trip may be open. That invariant is a partial unique index rather than an
`if` in the repository, because E17's importer writes rows through its own path
and would not inherit a Dart guard.

Starting retroactively adopts, in the same transaction, every orphan catch
created at or after the backdated start. Without that, backdating only moves a
label and the three fish already recorded stay outside the trip, so every
per-trip total in S10 is quietly wrong. Adoption is bounded by time alone: the
catch carries its own jurisdiction and zone, so crossing a boundary mid-morning
is still one trip.

Timestamps go through one formatter that always writes a fixed-width UTC
string. SPEC §7.2 stores them as TEXT and E05 recorded that this is safe
because ISO-8601 UTC sorts lexicographically — which holds only for that exact
form, and T06's keyset cursor depends on it.

Task: E13/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
