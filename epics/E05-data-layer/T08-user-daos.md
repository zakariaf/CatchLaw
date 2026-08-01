# E05/T08 — The user DAOs

| | |
|---|---|
| **Epic** | E05 — Data layer: two drift databases |
| **Branch** | `epic/05-data-layer` (shared) |
| **Commit** | `feat(data): add the user DAOs and the streams the UI watches` |
| **Depends on** | T04 (the schema), T05 (the opener) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.2 (the tables written here); §4.5 and §6 S8/S10/S11 (what the streams feed); §13 (< 4 MB at ~8,000 rows; crash safety: every write transactional, the catch persisted before the UI animates) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `persistence-drift` | Rules 4, 6, 7 and 8: one transaction per mutation with every query awaited, derive on read, scoped `.watch()` streams, keyset pagination rather than `OFFSET` |
| `state-management-riverpod` | Rules 4, 5 and 6, and the `==` trap these streams walk into: the write returns `void`, the committed write makes the stream re-emit, and nothing republishes by hand |
| `catchlaw-reference-database` | Rule 8: a `catch` row denormalises what it was judged under. These DAOs write literals and never a foreign key into content |
| `error-handling-typed-results` | Rule 11: never lose hand-entered data. The catch is persisted before anything animates, in one transaction |
| `testing-strategy` | Rule 4 and `references/test-layers.md`'s data-layer row: real `NativeDatabase.memory()`, `.watch()` emission ordering asserted, teardown that closes streams |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.2 | The tables and their five indexes — `idx_catch_created`, `idx_catch_trip`, `idx_catch_species`, `idx_catch_zone`, `idx_trip_started` |
| `SPEC.md` | §7.2 closing paragraph | Why the write copies `scientific_name`, `rule_citation_ref` and `content_version` onto the row |
| `SPEC.md` | §4.5 | What the catch log is: trips, quick-adds with no trip, tally, zone filtering — all local |
| `SPEC.md` | §13 | Crash safety: "Every write transactional; the catch is persisted before the UI animates; no in-memory-only state that matters". And the size budget these queries run against |
| `$FLUTTER_SKILLS/persistence-drift/SKILL.md` | rules 4, 6, 7, 8; "DAO + repository: one transaction, mapped to value objects" | The awaited-inside-transaction rule (a dropped `await` is data loss, not style) and keyset pagination |
| `$FLUTTER_SKILLS/persistence-drift/references/schema-and-daos.md` | "The index & query-plan strategy" | Leading column filters, trailing column sorts; prove the plan in a test |
| `$FLUTTER_SKILLS/state-management-riverpod/SKILL.md` | rules 4, 5, 6; "Riverpod: pick the right shape" | `StreamProvider` over a DAO stream, never an `AsyncNotifier` mirroring rows into `state` |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | rule 8 | The denormalised columns, with the AED 3,000 reason |
| `$FLUTTER_SKILLS/testing-strategy/references/test-layers.md` | "Data layer (Drift)" | Assert `.watch()` emission ordering and transaction rollback, not just final state |
| `FLUTTER_GUIDE.md` | §5.2 | "Writes need no state at all" — the insert marks the table dirty and the stream pushes the new state back |
| `FLUTTER_GUIDE.md` | §5.3 | The `==` rebuild trap: `List.==` is identity, so every re-query rebuilds every list consumer. Mitigations 1 and 2 are decided here |
| `FLUTTER_GUIDE.md` | §5.4 | The pause/resume synergy — drift re-runs exactly one query on resume, which is why these are `StreamProvider`s and not hand-rolled `StreamBuilder`s |

## What this delivers

- `app/lib/data/daos/user/catch_dao.dart` — `watchForTrip(int tripId)`,
  `watchTallyForDay(String isoDay, {required String jurisdictionCode, required String zoneCode})`,
  `pageBefore(String cursorCreatedAt, {int limit = 30})`, `insertCatch(CatchCompanion)`,
  `updateCatch(...)`, `deleteCatch(int id)`.
- `app/lib/data/daos/user/trip_dao.dart` — `watchOpenTrip()`, `watchRecentTrips({int limit = 20})`,
  `startTrip(...)`, `endTrip(int id, String endedAt)`.
- `app/lib/data/daos/user/species_recent_dao.dart` — `watchRecent({required String jurisdictionCode,
  required String zoneCode, int limit = 12})`, `recordUse(...)`.
- `app/lib/data/daos/user/saved_zone_dao.dart` — `watchAll()`, `save(...)`, `remove(int id)`,
  `reorder(List<int> idsInOrder)`.
- `app/lib/data/daos/user/rule_flag_dao.dart` — `watchAll()`, `flag(...)`.
- `app/lib/data/daos/user/app_meta_dao.dart` — `read(String key)`, `write(String key, String value)`,
  `readAll()`. This is what `AppMetaMarkerStore` (T03) sits on.
- `app/lib/data/daos/user/user_profile_dao.dart` — `watchProfile()`, `updateProfile(...)`.
- `app/test/data/daos/user/` — one test file per DAO.

## Why it is built this way

**Every mutation is one `db.transaction` with every query inside awaited.** A missing `await` inside
`transaction(() async {` lets a query run after the transaction has closed; drift calls that data loss
and `persistence-drift` rule 4 calls it a release blocker. `recordUse` is the case that matters most
here: it writes the `species_recent` row **and** the catch in one commit, so a crash cannot leave a
recents list that remembers a fish the log does not have.

**The write returns after the commit, and nothing republishes.** `SPEC.md` §13's crash-safety row is
explicit: the catch is persisted *before* the UI animates. So the DAO's `Future` resolves only after the
durable commit, the committed write marks the table dirty, drift re-runs every watching query and the
`StreamProvider` emits. There is no `state =`, no optimistic insert and no manual refresh — an
optimistic pre-commit update shows a fact the disk never held, which on this app is a catch the fisher
believes is recorded.

**Streams are scoped, and the scope is not decoration.** An unscoped `watch()` over `catch` re-runs on
every write anywhere in the table; at the §13 budget of ~8,000 rows that is a full scan behind every
quick-add. `watchTallyForDay` is keyed by day plus jurisdiction plus zone so `idx_catch_zone` and
`idx_catch_created` both serve it, and `watchForTrip` is keyed by `trip_id` so `idx_catch_trip` does.
Each has an `EXPLAIN QUERY PLAN` assertion in its test, per `schema-and-daos.md`.

**History pages by keyset, never `OFFSET`.** `pageBefore` is `WHERE created_at < :cursor ORDER BY
created_at DESC LIMIT n`, which rides `idx_catch_created` and stays constant-cost as the log grows.
`OFFSET` degrades linearly and `check-persistence-bans.sh` check 2 fails on the string. The cursor is
the ISO-8601 `created_at` string, and it works as a cursor precisely because ISO-8601 UTC sorts
lexicographically in chronological order — the property the epic's Risks section relies on to keep §7.2's
`TEXT` timestamps.

**The tally is a fold over rows, not a stored counter.** `persistence-drift` rule 6: a stored count is a
second source of truth that drifts, and the drift is invisible until somebody counts by hand. The tally
query is a `GROUP BY species_id` over the day's catches; at eight catches a day it costs nothing, and it
cannot disagree with the log it is derived from.

**The `==` trap is decided here rather than in the UI epics.** Riverpod 3 filters provider updates with
`==`, and `List.==` is identity — so every drift re-query rebuilds every list consumer even when nothing
changed. `FLUTTER_GUIDE.md` §5.3's mitigations 1 and 2 are adopted: the DAO methods are narrow, so one
write does not re-run a five-table join, and the counts that widgets actually watch are exposed as
their own streams (`watchTallyForDay` returns a small value type with `==`, not a `List<CatchRow>`),
which is what lets a consumer `select()` down to one field. Mitigation 3 (`distinct` with a list
equality) is deliberately **not** adopted: it costs an O(n) comparison on every emission and buys
nothing until a subtree is measured expensive.

**`species_recent` is upserted on its composite key.** `insertOnConflictUpdate` on `(species_id,
jurisdiction_code, zone_code)` increments `use_count` and stamps `last_used_at`. A plain insert would
split one species' history across duplicate rows and make the Check-home recents list show the same fish
twice — the exact defect the `WITHOUT ROWID` composite primary key of T04 exists to prevent.

**Rejected: a `watchAll()` on `catch`.** It is the convenient method and it is the one that turns every
quick-add into a full-table re-query in every open screen. There is no unscoped catch stream; callers
take a trip, a day + zone, or a page.

**Rejected: soft delete.** `schema-and-daos.md` prescribes `is_deleted` behind one shared filter, and
`SPEC.md` §7.2 has no such column. Undo for a deleted catch is a UI concern for E13, which can hold the
row in memory for the length of a SnackBar; adding a column §7.2 does not have would change §12's export
shape. Recorded here so E13 does not add it silently.

**Rejected: writing the verdict's wording from the engine.** `outcome_detail` holds "the factual finding
text as shown" (§7.2), and that text is assembled in `app/lib/ui/` from ARB and `content_string` (D-7).
The DAO stores whatever string it is handed; it never composes one, and `packages/rule_engine/` never
supplies one.

## Tests first

Write every row before touching a DAO. Run them. **They must fail.** Rows 4 and 5 are the ones most
likely to pass early against a partial implementation — if they do, the assertion is on the final state
rather than on the emission sequence; fix the test.

All tests use `UserDatabase(NativeDatabase.memory())` with `addTearDown(db.close)`.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `CatchDao.insertCatch commits before its Future resolves` | insert, then read on a second handle | row visible | §13's crash safety: the catch is persisted before the UI animates |
| 2 | `CatchDao.insertCatch and SpeciesRecentDao.recordUse commit in one transaction` | force the second write to fail | neither row present | A recents list that remembers a fish the log does not have |
| 3 | `CatchDao.insertCatch stores the citation reference and content version as literals` | insert with both | columns hold the given strings | §7.2's immutable history — the row must restate itself after its rule is retired |
| 4 | `CatchDao.watchForTrip emits once on subscription and again after an insert` | listen, then insert | 2 emissions, second contains the new row | The reactive contract E13's UI depends on; asserting only the final state hides a stream that never re-emits |
| 5 | `CatchDao.watchForTrip emits nothing when a catch on another trip is inserted` | listen on trip 1, insert on trip 2 | 1 emission | Scoping. drift reschedules watching queries on any write to the table, so the `where` is the only thing that limits it |
| 6 | `CatchDao.watchTallyForDay groups the day's catches by species` | 3 catches, 2 species | 2 groups with counts 2 and 1 | S8's tally, derived on read rather than stored |
| 7 | `CatchDao.watchTallyForDay excludes catches from another zone` | same day, two zones | only the requested zone | §4.5's zone filtering; a tally that mixes zones is a wrong bag-limit reading |
| 8 | `CatchDao.watchTallyForDay uses idx_catch_zone` | `EXPLAIN QUERY PLAN` | plan names the index, no `SCAN catch` | This runs on the Check home, inside the 1.2 s budget |
| 9 | `CatchDao.pageBefore returns the rows immediately older than the cursor` | 5 catches, cursor at the 3rd | rows 4 and 5, newest first | Keyset pagination; the cursor is the ISO timestamp and it sorts chronologically |
| 10 | `CatchDao.pageBefore returns an empty page at the end of the log` | cursor older than everything | empty | The boundary an `OFFSET` implementation gets right and a bad `<=` gets wrong by one row |
| 11 | `CatchDao.deleteCatch removes the row and leaves its trip intact` | delete one of two | 1 catch, trip present | Deleting a fish is not deleting a trip |
| 12 | `TripDao.endTrip leaves every catch on the trip` | end a trip with 3 catches | 3 catches, `trip_id` unchanged | Ending is a timestamp, not a cascade |
| 13 | `SpeciesRecentDao.recordUse increments use_count on a repeat` | record twice | 1 row, `use_count` 2 | The upsert on the composite key; a plain insert shows the same fish twice on the home screen |
| 14 | `SpeciesRecentDao.watchRecent orders by last_used_at descending` | 3 species used out of order | most recent first | S1's recents strip is the first thing on screen; the order is the feature |
| 15 | `SpeciesRecentDao.watchRecent excludes another zone's history` | two zones | only the requested one | Recents are per zone (§7.2's composite key), because the fish are |
| 16 | `SavedZoneDao.reorder assigns contiguous sort_order values in one transaction` | reorder 3 | 0, 1, 2 | A partial reorder leaves two zones claiming the same position |
| 17 | `UserProfileDao.watchProfile re-emits after an update` | listen, update `length_unit` | 2 emissions | Settings feed every screen; a profile stream that does not re-emit is a unit change nobody sees |
| 18 | `AppMetaDao.write replaces the value for an existing key` | write twice | 1 row | T03's marker lives here and must be unambiguous |
| 19 | `no user DAO uses OFFSET` | grep the DAO sources in a test | no match | The gate covers `app/lib`; this keeps the reason attached to the rule |

```dart
// app/test/data/daos/user/catch_dao_test.dart
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/models/user_fixtures.dart';

void main() {
  late UserDatabase db;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);
  });

  test('CatchDao.watchForTrip emits once on subscription and again after an insert', () async {
    await db.tripDao.startTrip(kTripGalicia);
    final emissions = <int>[];
    final sub = db.catchDao.watchForTrip(1).listen((rows) => emissions.add(rows.length));
    addTearDown(sub.cancel);
    await pumpEventQueue();

    await db.catchDao.insertCatch(kCatchCentolla);
    await pumpEventQueue();

    expect(emissions, [0, 1],
        reason: 'the committed write must make the watched query re-emit — nothing republishes by hand');
  });

  test('CatchDao.watchForTrip emits nothing when a catch on another trip is inserted', () async {
    await db.tripDao.startTrip(kTripGalicia);
    await db.tripDao.startTrip(kTripRiaDeArousa);
    final emissions = <int>[];
    final sub = db.catchDao.watchForTrip(1).listen((rows) => emissions.add(rows.length));
    addTearDown(sub.cancel);
    await pumpEventQueue();

    await db.catchDao.insertCatch(kCatchCentolla.copyWith(tripId: const Value(2)));
    await pumpEventQueue();

    expect(emissions, hasLength(1),
        reason: 'drift reschedules every watching query on any write to the table; the where clause '
            'is the only thing that limits what this consumer sees');
  });

  test('CatchDao.insertCatch and SpeciesRecentDao.recordUse commit in one transaction', () async {
    await expectLater(
      db.catchDao.insertCatchAndRecordUse(kCatchCentolla, kRecentUseWithBadZone),
      throwsA(anything),
    );

    expect(await db.select(db.catchTable).get(), isEmpty,
        reason: 'a half-applied write leaves recents remembering a fish the log does not have');
    expect(await db.select(db.speciesRecent).get(), isEmpty);
  });

  // … one test per remaining row above, one behaviour each
}
```

## Implementation outline

1. Write one `@DriftAccessor` per DAO, scoped to the tables it touches. `insertCatchAndRecordUse` is the
   one cross-table method and it lives on `CatchDao` because both tables are in its accessor set; every
   query inside its `transaction` is awaited.
2. Every `watch…` method takes its scope as a required parameter. There is no zero-argument catch stream.
3. `watchTallyForDay` returns `List<SpeciesTally>` — a small immutable value type with `==` — not a list
   of row classes, so a consumer can `select()` down to a count without rebuilding on every re-query.
4. `pageBefore` uses `..where((c) => c.createdAt.isSmallerThanValue(cursor))..orderBy([desc(createdAt)])
   ..limit(limit)`. No `OFFSET`, anywhere.
5. `recordUse` is `insertOnConflictUpdate` with `use_count = use_count + 1` and `last_used_at` stamped
   from the injected `Clock`, never `DateTime.now()` (`state-management-riverpod` rule 10).
6. `reorder` runs one transaction assigning `sort_order` from the list index.
7. Add the `EXPLAIN QUERY PLAN` assertions alongside the queries they cover, in the same test file.
8. Re-run the suite. 19 green, and T04's and T05's still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 tests pass, and each failed first.
- [ ] Every mutation is exactly one `db.transaction`, and every query inside is awaited.
- [ ] No DAO method returns before its commit; no optimistic pre-commit update exists.
- [ ] Every `watch…` method is scoped by a required parameter; no unscoped stream on `catch`.
- [ ] `pageBefore` is keyset; `OFFSET` appears nowhere and `check-persistence-bans.sh app/lib` is clean.
- [ ] The tally is a fold over rows; no stored count, streak or total exists in the schema or the code.
- [ ] `last_used_at`, `created_at` and `updated_at` are stamped from an injected `Clock`; `DateTime.now()`
      appears nowhere in `app/lib/data/`.
- [ ] The three `EXPLAIN QUERY PLAN` assertions (tally, trip, page) name the index and not a table scan.
- [ ] No DAO writes a foreign key into any `reference.db` table.
- [ ] No `is_deleted` column and no soft-delete filter is introduced.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-persistence-bans.sh        app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-drift-confinement.sh       app/lib
$FLUTTER_SKILLS/state-management-riverpod/scripts/ban-legacy-providers.sh  app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(data): add the user DAOs and the streams the UI watches

Seven accessors over user.db: catches, trips, recents, saved zones, rule
flags, app_meta and the singleton profile. Every mutation is one
db.transaction with every query inside awaited — a dropped await lets a
query run after the transaction closes, which drift calls data loss — and
each Future resolves only after the durable commit, so SPEC 13's "the catch
is persisted before the UI animates" holds structurally rather than by
discipline. The committed write makes the watched query re-emit; nothing
republishes by hand.

Every watch method is scoped by a required parameter. drift reschedules
every watching query on any write to the table, so an unscoped catch stream
would turn each quick-add into a full-table re-query in every open screen at
the ~8,000 rows SPEC 13 budgets. History pages by keyset on the ISO
created_at cursor, which sorts chronologically because it is ISO-8601 UTC.

The tally is a GROUP BY over the day's rows, not a stored counter: a stored
count is a second source of truth, and its drift is invisible until somebody
counts by hand.

Task: E05/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
