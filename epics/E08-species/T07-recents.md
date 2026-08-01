# E08/T07 — Recents

| | |
|---|---|
| **Epic** | E08 — Species: search, browse and the static detail |
| **Branch** | `epic/08-species` (shared) |
| **Commit** | `feat(data): record and read species recents per zone, by frequency then recency` |
| **Depends on** | T03 (S5, where the strip is mounted), T05 (S2, whose open records the use) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.1 "Species picker", §7.2 `species_recent`, §6 S1 (Recents strip, 6 species), §13 (cold start) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `persistence-drift` | The write is one transaction on `user.db`; the read is a scoped `.watch()`; the index plan is proved with `EXPLAIN QUERY PLAN`; `NativeDatabase.memory()` for the logic tests |
| `catchlaw-reference-database` | `species_recent` lives in `user.db` — the writable, irreplaceable one — and the join to `reference.db` is Dart, never `ATTACH` |
| `state-management-riverpod` | The single write path through the repository; `void` intent methods; rule 10 — `last_used_at` comes from `clockProvider`, never `DateTime.now()` |
| `lonja-lists-and-tables` | The strip's tiles obey the row rules: one target each, no card, no elevation, and an authored empty state |
| `lonja-forms-and-controls` | `references/search-field-and-keypad.md` is why the strip sits above the field and why the field never autofocuses |
| `widget-composition` | The strip is a lazy horizontal builder of `const` tile classes, with `ValueKey` identity |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.1 "Species picker" row | "recents are per-zone, ordered by frequency then recency" — the acceptance condition, verbatim |
| `SPEC.md` | §7.2 `species_recent` | The five columns, `PRIMARY KEY (species_id, jurisdiction_code, zone_code)`, `WITHOUT ROWID`, and that no index is declared |
| `SPEC.md` | §6 S1 "Elements" | "Recents strip (6 species)" — the count |
| `SPEC.md` | §7.4 `user.db` | drift's `MigrationStrategy`: numbered, forward-only, each shipping with a test that opens a fixture at version *n* and asserts row counts and sample values |
| `SPEC.md` | §13 "Subsequent cold start" | "< 1.2 s … recents from one indexed query" — the sentence this task has to make true |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "Ownership matrix", "The ATTACH ban" | `user.db` is the irreplaceable one; the cross-file join happens in Dart |
| `Flutter-Skills: persistence-drift/references/schema-and-daos.md` | "The index & query-plan strategy" | Leading column is the equality filter, trailing column the sort; prove it with `EXPLAIN QUERY PLAN` in a test |
| `.claude/skills/lonja-forms-and-controls/references/search-field-and-keypad.md` | "Edge cases", first bullet | "The recents strip stays visible above the keyboard; six species tabs are faster than typing with wet hands. Never `autofocus`" |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Empty" | An authored empty state, one action, no apology |
| `Flutter-Skills: state-management-riverpod/references/reads-and-side-effects.md` | "Action-path methods return void" | The silence bug: an arrow closure returning a `Future` into a `VoidCallback` drops the error |
| `FLUTTER_GUIDE.md` | §5.2, §5.3 | Return the stream, do not `await for` it; `List.==` is identity, so scope the query narrowly |
| `epics/DECISIONS.md` | D-6 | `user.db` is the writable one; the reference DB is read-only |

## What this delivers

- `app/lib/data/services/user_database_migrations.dart` — one numbered, forward-only migration step
  adding `CREATE INDEX idx_recent_zone ON species_recent (jurisdiction_code, zone_code, use_count
  DESC, last_used_at DESC)`, with the `schemaVersion` bump and the fixture-at-version-*n* test §7.4
  requires.
- `app/lib/data/services/dao/species_recent_dao.dart` — `watchRecents`, `recordUse`.
- `app/lib/domain/models/recent_species.dart` — `speciesId`, `useCount`, `lastUsedAt`,
  `displayName`, `silhouetteAsset`, `plateAsset`.
- `app/lib/data/repositories/species_recent_repository.dart` (+ `_drift.dart`) —
  `Stream<List<RecentSpecies>> watchRecents({required JurisdictionRef jurisdiction, required
  ZoneRef zone, int limit = 6})` and `Future<Result<void>> recordUse(int speciesId, …)`. The
  repository is the only place the two databases meet.
- `app/lib/ui/species/view_models/species_recents_view_model.dart` — a `StreamNotifier` whose
  `build()` returns the repository stream, `.autoDispose.family` keyed by the zone.
- `app/lib/ui/species/widgets/recents_strip.dart` — the strip, mounted on S5 above the search field.
- ARB keys in all six files: `recentsStripLabel`, `recentsEmptyHeadline`, `recentsEmptyBody`.
- Tests: `app/test/data/repositories/species_recent_repository_test.dart`,
  `app/test/data/services/user_database_migration_v_test.dart`,
  `app/test/ui/species/recents_strip_test.dart`.

## Why it is built this way

**The published schema cannot serve its own read.** §7.2 declares
`PRIMARY KEY (species_id, jurisdiction_code, zone_code) WITHOUT ROWID` and no index. The read this
feature needs is

```sql
SELECT * FROM species_recent
 WHERE jurisdiction_code = ? AND zone_code = ?
 ORDER BY use_count DESC, last_used_at DESC
 LIMIT 6;
```

whose equality filter leads with `jurisdiction_code`, which is the *second* column of the primary
key. A `WITHOUT ROWID` table's key is its b-tree, so a filter that does not lead with `species_id`
cannot use it — the read degrades to a full table scan plus a sort. §13 promises "recents from one
indexed query" on the < 1.2 s cold-start path, and that promise is not met by the schema as
printed. `schema-and-daos.md` states the fix precisely: the leading column is the equality filter
and the trailing column is the sort, so one index serves both. This task adds
`idx_recent_zone (jurisdiction_code, zone_code, use_count DESC, last_used_at DESC)` and proves it
with `EXPLAIN QUERY PLAN` in a test rather than in a comment. `epic.md` risk 6 records the gap.

**It is a forward-only migration, with the test §7.4 asks for.** `user.db` is the irreplaceable
file — no account, no sync, no server, and three seasons of trips exist nowhere else. §7.4 requires
numbered, forward-only steps, each shipping with a test that opens a fixture DB at version *n*,
migrates, and asserts row counts and sample values. Adding an index touches no row, so the assertion
is that every `species_recent` row survives byte-identical and the new index exists. That is the
cheapest possible migration and it is still written the same way, because the ritual is what makes
the expensive one safe.

**Frequency first, then recency, then a deterministic tiebreak.** §4.1's acceptance condition is
"ordered by frequency then recency". Two species can share both — the same `use_count` and the same
`last_used_at`, which happens whenever two are recorded inside the same clock tick. Without a third
key the strip reshuffles between two identical reads, which on a moving boat looks like the app
losing state. `species_id` is the tiebreak.

**The cross-database join is Dart, and it drops what no longer resolves.** `species_recent` holds
`species_id` in `user.db`; the name and the silhouette live in `reference.db`.
`catchlaw-reference-database` rule 11 bans `ATTACH`, because a wholesale content swap renames a new
file over the old one and any statement spanning both is then pointing at an unlinked inode. So the
repository reads the recents, then resolves the ids against the reference DB, and **omits any id
that no longer resolves** — a content update can retire a species, and a blank tile in a six-tile
strip is worse than five tiles. This is the one place this epic diverges from the
two-database-contract's catch-row guidance: a `catch` row must render completely from its own
denormalised columns because it is a legal record, but a recents tile is a shortcut, and a shortcut
to nothing is deleted rather than displayed.

**The write is one transaction and it happens on open, not on tap.** The use is recorded when S2
actually renders a species, not when a row is tapped, so a mis-tap that is immediately backed out of
still counts — but a row that is tapped and never resolves does not. The statement is a single
upsert:

```sql
INSERT INTO species_recent (species_id, jurisdiction_code, zone_code, use_count, last_used_at)
VALUES (?, ?, ?, 1, ?)
ON CONFLICT (species_id, jurisdiction_code, zone_code)
DO UPDATE SET use_count = use_count + 1, last_used_at = excluded.last_used_at;
```

One statement, one transaction, no read-modify-write, so two opens in the same second cannot lose a
count to a lost update. `persistence-drift` rule 4: the `Future` resolves only after the durable
commit, and the watching query re-emits on its own — no manual republish.

**`last_used_at` comes from the injected clock.** `state-management-riverpod` rule 10 bans
`DateTime.now()` in state logic. Here it is not ceremony: §14's dynamic checklist requires setting
the device clock backwards two years and asserting nothing crashes, and ordering by a timestamp is
exactly what a backwards clock disturbs. With an injected `Clock`, that is a unit test.

**The strip is on S5, above the field, and the field never autofocuses.**
`search-field-and-keypad.md`'s first edge case gives both halves of the reason: the recents strip
stays visible above the keyboard because six species tabs are faster than typing with wet hands, and
`autofocus` would raise the keyboard over it at cold launch. E12 mounts the same widget on S1; this
task builds it where it can be used immediately.

**Rejected: an `AsyncNotifier` mirroring rows into state.** A Riverpod anti-pattern
(`FLUTTER_GUIDE.md` §5.5) and a `persistence-drift` rule-6 violation — it is a second copy of a fact
the database already holds. `StreamNotifier` over the repository stream is the shape
`ownership-and-lifecycle.md` names for a live projection, and §5.4's pause/resume behaviour comes
free: pushing S2 over S5 genuinely stops the SQL, and popping back runs exactly one fresh query.

**Rejected: a `use_count` decay or a rolling window.** §4.1 says frequency then recency and nothing
about ageing. A decay function is a product decision nobody has made, it would make the ordering
untestable without freezing time in three places, and it would quietly demote the species a fisher
catches every winter. If it is ever wanted, it belongs in the spec first.

## Tests first

Write every row before touching `species_recent_dao.dart`. Run them. **They must fail.**

| # | Test name | Case | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SpeciesRecentRepository.recordUse inserts a row with a use count of one` | first open | one row, `use_count == 1` | The insert half of the upsert |
| 2 | `SpeciesRecentRepository.recordUse increments the use count on a second open` | two opens | `use_count == 2` | The update half; without it the strip is a recency list and §4.1's "frequency" is a lie |
| 3 | `SpeciesRecentRepository.recordUse updates last_used_at on a second open` | two opens, clock advanced | `last_used_at` is the later time | Recency is the second sort key and must actually move |
| 4 | `SpeciesRecentRepository.recordUse keeps separate counts per zone` | same species, two zones | two rows, each `use_count == 1` | §4.1's "per-zone"; one shared counter would carry a Galician clam into a Gulf strip |
| 5 | `SpeciesRecentRepository.recordUse keeps separate counts per jurisdiction` | same zone code, two jurisdictions | two rows | Zone codes are only unique within a jurisdiction (§7.1's `UNIQUE (jurisdiction_id, code)`) |
| 6 | `SpeciesRecentRepository.recordUse does not lose a count when two opens share a clock tick` | two upserts, same instant | `use_count == 2` | One statement, not read-modify-write; a lost update here silently flattens the ordering |
| 7 | `SpeciesRecentRepository.watchRecents orders by use count descending` | counts 5, 3, 1 | that order | The first sort key |
| 8 | `SpeciesRecentRepository.watchRecents orders by last used descending within an equal use count` | equal counts, different times | later first | The second key; without it the first is untestable in isolation |
| 9 | `SpeciesRecentRepository.watchRecents orders by species id when count and time are equal` | fully tied | ascending id, stable across two reads | A strip that reshuffles between reads looks like lost state on a moving boat |
| 10 | `SpeciesRecentRepository.watchRecents returns at most six species` | 9 rows | 6 | §6 S1's count, as a number rather than a habit |
| 11 | `SpeciesRecentRepository.watchRecents returns only the active zone's rows` | rows in 3 zones | only the active zone's | The per-zone requirement, on the read side |
| 12 | `SpeciesRecentRepository.watchRecents omits a species id absent from reference.db` | a retired id | that tile absent, the rest present | A content update can retire a species, and a blank tile is worse than five tiles |
| 13 | `SpeciesRecentRepository.watchRecents re-emits after a use is recorded` | watch, then record | second emission with the new count | `persistence-drift` rule 4: the committed write re-emits; nothing republishes by hand |
| 14 | `SpeciesRecentDao.watchRecents uses idx_recent_zone` | `EXPLAIN QUERY PLAN` | plan contains `idx_recent_zone` | §13's "one indexed query" on the < 1.2 s cold-start path — the whole reason this task ships a migration |
| 15 | `SpeciesRecentDao.watchRecents performs no temp b-tree sort` | `EXPLAIN QUERY PLAN` | plan has no `USE TEMP B-TREE` | The index's `DESC` columns must serve the `ORDER BY` too, or it is only half an index |
| 16 | `UserDatabase migration to v<n> adds idx_recent_zone` | fixture at v<n−1> | index present after migrate | §7.4's forward-only ritual |
| 17 | `UserDatabase migration to v<n> preserves every species_recent row` | fixture with 12 rows | 12 rows, sample values identical | §7.4: "asserts row counts and sample values" — `user.db` is the irreplaceable file |
| 18 | `UserDatabase migration to v<n> preserves every catch row` | fixture with trips and catches | counts unchanged | An index migration touching an unrelated table is the failure this catches |
| 19 | `SpeciesRecentRepository.recordUse stamps last_used_at from the injected clock` | fixed clock | exact stamp | Rule 10, and §14's backwards-clock check needs this to be a unit test |
| 20 | `RecentsStrip renders one tile per recent species` | 4 recents | 4 tiles | The strip's baseline |
| 21 | `RecentsStrip opens the species detail when a tile is tapped` | tap | route pushed with the id | §4.1: four paths land on the same species detail |
| 22 | `RecentsStrip passes the species id to its callback, not the tile value` | tap after a rebuild | callback receives the id | The stale-closure hole |
| 23 | `RecentsStrip renders its authored empty state on first launch` | 0 recents | headline and body present | §6 S1's empty state; a blank band above the field reads as a broken layout |
| 24 | `RecentsStrip stays visible when the search field has focus` | field focused | strip still laid out | `search-field-and-keypad.md`'s first edge case — the whole reason the strip is above the field |
| 25 | `glove - RecentsStrip tiles measure at least 66 dp` | glove density | `>= 66` | `LonjaTargets.gloveControl`; a mis-hit here costs the fastest path to a verdict |
| 26 | `RTL - RecentsStrip lays its tiles from the start edge` | locale `ar` | first tile `dx` > last tile `dx` | A horizontal strip is the easiest place to hardcode a left offset (D-8) |

```dart
// app/test/data/repositories/species_recent_repository_test.dart
import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/k_species.dart';
import '../../support/reference_fixture.dart';

void main() {
  test('SpeciesRecentRepository.watchRecents orders by species id when count and time are equal',
      () async {
    final repository = await buildRecentsRepository(); // in-memory user.db + Galicia fixture
    addTearDown(repository.dispose);

    await withClock(Clock.fixed(DateTime.utc(2026, 7, 27, 5, 41)), () async {
      for (final id in [kSpeciesShari.id, kSpeciesHamour.id, kSpeciesKanaad.id]) {
        await repository.recordUse(id, jurisdiction: kJurisdictionRak, zone: kZoneRak);
      }
    });

    final first = await repository.watchRecents(
      jurisdiction: kJurisdictionRak, zone: kZoneRak).first;
    final second = await repository.watchRecents(
      jurisdiction: kJurisdictionRak, zone: kZoneRak).first;

    // Fully tied on both sort keys — without the species_id tiebreak the strip
    // reshuffles between two identical reads.
    expect(first.map((r) => r.speciesId).toList(), second.map((r) => r.speciesId).toList());
    expect(first.map((r) => r.speciesId), orderedEquals(
      [kSpeciesHamour.id, kSpeciesShari.id, kSpeciesKanaad.id]..sort(),
    ));
  });

  test('SpeciesRecentRepository.watchRecents omits a species id absent from reference.db',
      () async {
    final repository = await buildRecentsRepository();
    addTearDown(repository.dispose);

    await repository.recordUse(kSpeciesHamour.id,
        jurisdiction: kJurisdictionRak, zone: kZoneRak);
    await repository.recordUse(999999, // retired by a content update
        jurisdiction: kJurisdictionRak, zone: kZoneRak);

    final recents = await repository.watchRecents(
      jurisdiction: kJurisdictionRak, zone: kZoneRak).first;

    // No ATTACH: the join is Dart, and a shortcut to nothing is deleted rather
    // than shown as a blank tile.
    expect(recents.map((r) => r.speciesId), [kSpeciesHamour.id]);
  });

  test('SpeciesRecentDao.watchRecents performs no temp b-tree sort', () async {
    final db = await buildUserDatabase(); // catchlaw-db-ok: in-memory migration probe
    addTearDown(db.close);

    final plan = await db.customSelect(
      'EXPLAIN QUERY PLAN '
      'SELECT * FROM species_recent WHERE jurisdiction_code = ? AND zone_code = ? '
      'ORDER BY use_count DESC, last_used_at DESC, species_id ASC LIMIT 6',
      variables: [Variable.withString('ES-GA'), Variable.withString('rias-baixas')],
    ).get();
    final detail = plan.map((r) => r.read<String>('detail')).join('\n');

    expect(detail, contains('idx_recent_zone'));
    expect(detail, isNot(contains('USE TEMP B-TREE')));
  });

  // … one test per row in the table above, one behaviour each
}
```

**Run:** `cd app && flutter test test/data/ test/ui/species/recents_strip_test.dart` → 26 failures.
Test 14 failing with a `SCAN species_recent` in its message is the confirmation that `epic.md`
risk 6 is real; do not "fix" it by dropping the `ORDER BY`. If any row passes before the DAO
exists, the test is wrong — most likely tests 7 or 8, where a one-row fixture makes any ordering
correct. Seed at least three rows with distinct counts and times before trusting either.

## Implementation outline

1. Write the migration first: bump `UserDatabase.schemaVersion`, add the `onUpgrade` step creating
   `idx_recent_zone`, and add the fixture-at-version-*n* test §7.4 requires. Tests 16–18 go red
   before any query exists.
2. `SpeciesRecentDao.recordUse` as the single upsert above, inside one `db.transaction`. It takes
   the timestamp as an argument; the repository supplies it from the clock.
3. `SpeciesRecentDao.watchRecents` as a scoped `.watch()` with the three-key `ORDER BY` and
   `LIMIT`. Narrow, per `FLUTTER_GUIDE.md` §5.3 — one write must not re-run a five-table join.
4. `DriftSpeciesRecentRepository` resolves the ids against the reference DAO in Dart, preserving the
   recents order and dropping unresolved ids. This is the only class in the app that holds a handle
   to both databases, and it holds two separate executors — never a shared one.
5. `SpeciesRecentsViewModel` as a `StreamNotifier` whose `build()` **returns** the stream. Do not
   `await for` it (`FLUTTER_GUIDE.md` §5.2: it re-implements `StreamProvider`, loses error
   propagation and leaks the subscription).
6. `RecentsStrip`: a horizontal `ListView.builder` of `const` tile classes with
   `ValueKey(speciesId)`, each tile one `InkWell` at `LonjaTargets.control` / `gloveControl`,
   separated by `LonjaTargets.separation`. Its empty state is authored, not a `SizedBox.shrink()`.
7. Mount it on S5 above the search field. Call `recordUse` from `SpeciesDetailScreen`'s view model
   when the account resolves — a `void` intent method that starts its own async work, never an arrow
   closure returning a `Future` into a callback.
8. Add three ARB keys to all six files.
9. Re-run the suite. All 26 green, T01–T06 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 26 tests pass, and each failed first.
- [ ] `idx_recent_zone` exists, `EXPLAIN QUERY PLAN` names it, and the plan contains no
      `USE TEMP B-TREE`.
- [ ] The migration is numbered and forward-only, and its test opens a fixture at the previous
      version and asserts `species_recent`, `trip` and `catch` row counts and sample values (§7.4).
- [ ] The ordering is `use_count DESC, last_used_at DESC, species_id ASC` and is stable across two
      identical reads.
- [ ] The limit is 6 and is a named constant (§6 S1).
- [ ] `recordUse` is one statement inside one transaction; there is no read-modify-write.
- [ ] `last_used_at` comes from `clockProvider`; `grep -rn 'DateTime.now()' app/lib/data/` is empty.
- [ ] No `ATTACH` and no shared `QueryExecutor`; the two databases meet only in the repository.
- [ ] An unresolvable `species_id` is omitted from the strip, not rendered blank.
- [ ] The strip has an authored empty state and stays laid out while the search field has focus.
- [ ] Three ARB keys exist in all six locales (D-3).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh    app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh     app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
tools/gates/no_directional_geometry.sh                                      app/lib
# from the Flutter-Skills plugin, per CONVENTIONS.md §4:
#   persistence-drift          scripts/check-drift-confinement.sh  app/lib
#   state-management-riverpod  scripts/ban-legacy-providers.sh     app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(data): record and read species recents per zone, by frequency then recency

SPEC §7.2 declares species_recent WITHOUT ROWID with a primary key leading on
species_id, and no index. The read leads on jurisdiction_code, so the primary key
cannot serve it and the query degrades to a scan plus a sort — which does not
meet §13's "recents from one indexed query" on the 1.2 s cold-start path. This
adds idx_recent_zone (jurisdiction_code, zone_code, use_count DESC,
last_used_at DESC) as a numbered forward-only migration with the fixture test
§7.4 requires, and proves it with EXPLAIN QUERY PLAN rather than a comment.

The ordering carries a third key, species_id, because two species recorded in
the same clock tick tie on both published keys and a strip that reshuffles
between identical reads looks like lost state.

The two databases meet only in the repository: no ATTACH, and a species_id that
no longer resolves after a content update is dropped from the strip rather than
drawn as a blank tile.

Task: E08/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
