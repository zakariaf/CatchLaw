# E13/T06 — S10: history at ten thousand rows

| | |
|---|---|
| **Epic** | E13 — The catch log |
| **Branch** | `epic/13-catch-log` (shared) |
| **Commit** | `feat(log): filter and page the catch history with a composite keyset cursor` |
| **Depends on** | T02 (the catch write path and its stored timestamp format) |
| **Size** | L |
| **Spec** | `SPEC.md` §6 S10, §4.5 (History — "Instant at 10,000 catches"), §7.2 (`catch` indexes), §7.1 (`closed_season`), §13 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `persistence-drift` | Rule 8 is the task: scoped `.watch()` streams and **keyset**, not `OFFSET`. Plus `references/schema-and-daos.md`'s index-and-query-plan strategy and its `EXPLAIN QUERY PLAN` gate. |
| `lonja-lists-and-tables` | The whole screen: the log-row anatomy, the divider ladder, lazy construction, and all four states of `references/the-four-states.md`. |
| `state-management-riverpod` | The paging ViewModel: one immutable state value, `.select` at consumers, `family` + `autoDispose` keyed on the filter, and rule 4 (derive, don't store). |
| `catchlaw-conventions-index` | Invariants 4 and 5 — the row's status pill, and a stale pack that adds an ochre bar without replacing a single row. |
| `run-migration` | The two composite indexes are a schema change and go through the forward-only ritual. `disable-model-invocation: true` — read it and execute it by hand. |
| `accessibility-as-code` | Rules 1, 5, 8: a 10,000-row list is where `TextOverflow.ellipsis` gets reached for, and rule 5 forbids it. |
| `error-handling-typed-results` | Rule 4: the page-load failure switch is exhaustive with no `default:`. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S10 | The four elements and the exact empty-state sentence: "No trips yet." |
| `SPEC.md` | §4.5 row "History" | "Filter by species, zone, date range; season and annual totals. Instant at 10,000 catches" |
| `SPEC.md` | §7.2 `catch` | The four indexes E05 created, and the column list a filter may name |
| `SPEC.md` | §7.1 `closed_season` | `recurrence`, `start_month`/`start_day`, `end_month`/`end_day`, `start_date`/`end_date` — keyed by `rule_id`, which is why a season total is per-species |
| `SPEC.md` | §13 row "DB size at realistic usage" | 5 yrs × 200 trips × 8 catches ≈ 8,000 rows — the shape the seeded fixture imitates |
| `$FLUTTER_SKILLS/persistence-drift/references/schema-and-daos.md` | "The index & query-plan strategy" | Leading column is the equality filter, trailing is the sort; keyset is `WHERE ts < :cursor ORDER BY ts DESC LIMIT n`; prove it with `EXPLAIN QUERY PLAN` in a test |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The log row", "Choosing a container", "Density" | The log-row slots, `ListView.builder` for an unbounded homogeneous list, 64 → 76 dp glove |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Precedence", "Loading skeleton", "Empty", "Stale", "Golden coverage matrix" | Six skeleton rows of the real shape, no spinner, no "Loading…", and lanes 6–11 |
| `FLUTTER_GUIDE.md` | Part 5.3 | `List.==` is identity, drift re-runs watching queries on every write, and the four mitigations in order |
| `FLUTTER_GUIDE.md` | Part 6.4 | The pyramid: drift unit tests over `NativeDatabase.memory()`, goldens kept to a small matrix on Linux CI |
| `epics/E13-catch-log/epic.md` | Risks 8, 9 | The season boundary that may not be queryable, and E05/T08's possibly single-column cursor |

## What this delivers

- `app/lib/data/services/user_db/user_database.dart` — `schemaVersion` bumped by exactly one, one
  appended step creating three composite indexes; the committed schema snapshot under
  `app/drift_schemas/`.
- `app/lib/data/services/user_db/daos/catch_history_dao.dart` — the filtered, paged reads and the
  narrow freshness query.
- `app/lib/domain/models/history_filter.dart` — `HistoryFilter(speciesId?, zone?, dateRange?)`,
  immutable and equatable, used as the `family` key.
- `app/lib/domain/models/history_page.dart` — `HistoryPage(rows, cursor, hasMore)` and
  `HistoryCursor(createdAt, id)`.
- `app/lib/domain/models/history_totals.dart` — the annual total and the optional season total.
- `app/lib/domain/use_cases/catch_history_use_case.dart` — the join with `ReferenceRepository` that
  resolves a season window and the species names.
- `app/lib/ui/log/history_screen.dart` — S10.
- `app/lib/ui/log/view_models/history_view_model.dart` — the paging `AsyncNotifier`.
- `app/lib/ui/log/widgets/lonja_catch_row.dart`, `history_filter_bar.dart`,
  `history_totals_panel.dart`, `history_empty_state.dart`, `history_skeleton.dart`.
- ARB keys ×6 for every filter label, total label and state sentence.
- Tests: `app/test/data/services/user_db/catch_history_dao_test.dart`,
  `app/test/data/services/user_db/catch_history_query_plan_test.dart`,
  `app/test/data/services/user_db/catch_history_scale_test.dart`,
  `app/test/domain/use_cases/catch_history_use_case_test.dart`,
  `app/test/ui/log/history_screen_test.dart`, and the golden lanes named below.

## Why it is built this way

**The cursor is `(created_at, id)`, not `created_at`.** `created_at` is not unique — two quick-adds in
the same millisecond are ordinary at 05:40 — and a cursor of `created_at` alone either **skips** rows
(strict `<` drops the whole tie group) or **repeats** them (`<=` returns the group again on the next
page). Both failures appear only at a page boundary, only when a tie straddles it, and never on a
developer's forty-row database. The cursor is therefore the pair, and the predicate is
`created_at < :ts OR (created_at = :ts AND id < :id)`. Tests 2 and 3 assert the two failure modes
separately, because a page that duplicates and a page that omits are different bugs.

**Read `app/lib/data/services/user_db/daos/` before writing anything.** E05/T08 shipped a keyset
cursor. If it is single-column, this task replaces it and every caller; if it is already composite,
this task keeps it and adds the filtered variants (epic Risks 9).

**Three composite indexes, and `id` is in all of them explicitly.** A page ordered
`created_at DESC, id DESC` cannot be produced in order by an index whose key stops at `created_at` —
the engine either sorts or scans, and either one is what makes the tenth page slower than the first.
`schema-and-daos.md`'s rule is that the leading column serves the equality filter and the trailing
column serves the sort, so:

```sql
CREATE INDEX idx_catch_created_id     ON catch(created_at DESC, id DESC);
CREATE INDEX idx_catch_zone_created   ON catch(jurisdiction_code, zone_code, created_at DESC, id DESC);
CREATE INDEX idx_catch_species_created ON catch(species_id, created_at DESC, id DESC);
```

Whether SQLite actually uses them is not settled by this paragraph. Tests 5, 6 and 7 assert
`EXPLAIN QUERY PLAN` reports `SEARCH … USING INDEX` and never `SCAN`, which is the only evidence that
counts. §7.2's published `idx_catch_created`, `idx_catch_species` and `idx_catch_zone` are **left in
place**: dropping a published index would be a §7.2 divergence, and they still serve other queries.

**Pages are one-shot reads; freshness is a separate, narrow watch.** `FLUTTER_GUIDE.md` §5.3 quotes
drift's own warning — every insert reschedules every watching query — and adds that
`StreamProvider<List<T>>` rebuilds every consumer regardless, because `List.==` is identity. A
`.watch()` on the *paged* query would therefore re-run and re-materialise every loaded page on every
write, which is precisely the "instant" this task is defending. So: each page is a `.get()`, and a
narrow watched query scoped to the active filter tells the ViewModel when to drop its accumulated tail
and refetch page one. **Rejected:** `.watch()` on the paged query (above); `OFFSET` pagination, which
`persistence-drift` rule 8 bans outright and which degrades linearly in the offset.

**"Instant at 10,000 catches" needs a number, and the number is one frame.** §4.5 gives the adjective
and no figure; §13's table has no row for this screen. One frame at 60 Hz is 16.67 ms, and a page
query that exceeds it drops a frame while the fisher is flinging the list — which is the observable
meaning of "not instant". So the scale test seeds 10,000 catches and asserts every page under 16 ms,
plus the property that distinguishes keyset from `OFFSET`: the **last** page is within 2× the first.
That measurement is on the CI host, which is not §13's Snapdragon 665; the device figure is E21's, and
the 2× property is the part that is hardware-independent.

**The annual total is the device-local calendar year. The season total is conditional.** §6 S10 asks
for both. The year is unambiguous and uses T03's `DayWindow` arithmetic extended to a year boundary. A
season window lives in `closed_season`, which §7.1 keys by `rule_id` — so it is per-species, and a
jurisdiction may publish none at all for the filtered selection. Where no window resolves, S10 renders
an authored absent line and **never silently substitutes the calendar year**, which would be a total
labelled "season" that is not one (epic Risks 8).

**The zone filter is the reason `jurisdiction_code` and `zone_code` sit on the catch.** §4.5's "Done
looks like" is one sentence: *"History filters by zone work for quick-added catches with no trip."*
Test 10 is that sentence.

**The list is lazy, the empty state is authored, and the loading state is not a spinner.**
`check_lonja_lists.sh` fails an eager `ListView(`; `the-four-states.md` bans
`CircularProgressIndicator` and every word in the "Loading…" family, because a spinner is network
language in an app that has no network. The skeleton is six rows of the real log-row shape.

## Tests first

Write every row before touching `catch_history_dao.dart`. Run them. **They must fail.** If one passes
now the test is wrong; fix the test before writing code.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `CatchHistoryDao.page returns rows in createdAt descending order` | 7 catches, page size 40 | newest first | The base contract every other row assumes |
| 2 | `CatchHistoryDao.page returns no row twice when createdAt values collide` | 5 rows sharing one `created_at`, page size 2 | 5 distinct ids across 3 pages | The single-column cursor with `<=` repeats the whole tie group, and only at a page boundary |
| 3 | `CatchHistoryDao.page skips no row when createdAt values collide` | same seed | the union equals the seed | The single-column cursor with strict `<` drops the tie group entirely. Duplication and omission are different bugs and need different tests |
| 4 | `CatchHistoryDao.page returns an empty page past the last row` | cursor beyond the oldest | zero rows, `hasMore` false | The terminating condition; without it the list paginates forever |
| 5 | `CatchHistoryDao.page searches an index for the unfiltered history query` | `EXPLAIN QUERY PLAN` | `SEARCH … USING INDEX`, no `SCAN` | The index-plan gate. An index that exists and is not used is an index that is not there |
| 6 | `CatchHistoryDao.page searches an index for the zone-filtered history query` | `EXPLAIN QUERY PLAN` | as above | The filter shape S10 uses most, and the one §4.5 names |
| 7 | `CatchHistoryDao.page searches an index for the species-filtered history query` | `EXPLAIN QUERY PLAN` | as above | The third shape; three shapes, three indexes, three assertions |
| 8 | `CatchHistoryDao.page returns the first page in under 16 ms at 10,000 catches` | 10,000 seeded rows | under one 60 Hz frame | The operational meaning of §4.5's "instant" — a slower page drops a frame mid-fling |
| 9 | `CatchHistoryDao.page returns the last page within twice the first page at 10,000 catches` | 10,000 rows, page 1 and page 250 | ratio ≤ 2 | The property `OFFSET` cannot satisfy, and the one that is independent of the host hardware |
| 10 | `CatchHistoryDao.page filtered by zone returns a catch that has no trip` | one quick-add, `trip_id` NULL | returned | §4.5's "Done looks like", verbatim, as a test |
| 11 | `CatchHistoryDao.page includes the start of a date range and excludes its end` | range `[d0, d1)` with rows at both bounds | the `d0` row only | Half-open ranges are the only ones that tile without gaps or overlaps; asserting the convention stops a later "fix" from double-counting |
| 12 | `CatchHistoryDao.page combines the species, zone and date filters` | all three set | only rows matching all three | The filters are independent in the UI and must be conjunctive in SQL |
| 13 | `CatchHistoryDao.watchFreshness emits when a catch is recorded` | insert while subscribed | one emission | The narrow watch that replaces watching the paged query |
| 14 | `CatchHistoryUseCase totals the device-local calendar year` | catches either side of 1 January local | only the current year counted | The annual total; the boundary is local, not UTC, for the same reason T03's day is |
| 15 | `CatchHistoryUseCase reports no season total when no season window resolves` | species with no `closed_season` row | an absent state, not a number | Epic Risks 8 — a calendar year labelled "season" is a false statement |
| 16 | `CatchHistoryUseCase totals the season when the resolved rule publishes a window` | annual recurrence 1 Mar – 30 Apr | the count inside that span | The positive path, without which case 15 passes trivially |
| 17 | `HistoryScreen renders the authored empty state with no trips` | zero rows | "No trips yet." and exactly one action | `SPEC.md` §6 S10 verbatim; a blank frame reads as a crash and a blank golden passes review |
| 18 | `HistoryScreen renders six skeleton rows of the log-row shape while the first page loads` | pending page | six skeletons, no `CircularProgressIndicator` | `the-four-states.md` — a spinner is network language in an app with no network |
| 19 | `HistoryScreen renders the stale bar above an unchanged list` | expired pack, 12 rows | bar present **and** 12 rows rendered | Invariant 5 |
| 20 | `HistoryScreen appends the next page when the list reaches its end` | scroll to the last row | page 2 requested once | Paging is a consequence of scrolling, not of a button |
| 21 | `HistoryScreen refetches page one when a catch is recorded` | record while S10 is open | the tail is dropped and page 1 is refetched once | The freshness path; without it a new catch appears only after leaving the screen |
| 22 | `HistoryScreen builds rows lazily at 10,000 catches` | 10,000 rows, one screenful | fewer than 40 `LonjaLogRow` widgets in the tree | `check_lonja_lists.sh` catches an eager `ListView(`; it does not catch a `shrinkWrap` that materialises everything |
| 23 | `ar - HistoryScreen end-aligns the row's numeric slot` | `ar` golden | figures on the end edge | `TextAlign.right` puts the figure under its own label in Arabic |
| 24 | `glove - HistoryScreen raises every row to 76 dp` | glove golden | 76 dp rows, 12 dp separation | `row-and-table-anatomy.md` "Density" |

```dart
// app/test/data/services/user_db/catch_history_dao_test.dart
void main() {
  test('CatchHistoryDao.page returns no row twice when createdAt values collide', () async {
    // Five quick-adds inside one millisecond: ordinary at 05:40, fatal to a single-column cursor.
    for (var i = 0; i < 5; i++) {
      await _insertCatch(db, createdAt: '2026-08-01T05:41:12.000Z');
    }

    final seen = <int>[];
    HistoryCursor? cursor;
    for (var p = 0; p < 3; p++) {
      final page = await dao.page(const HistoryFilter(), after: cursor, limit: 2);
      seen.addAll(page.rows.map((r) => r.id));
      cursor = page.cursor;
    }

    expect(seen, hasLength(5));
    expect(seen.toSet(), hasLength(5)); // no id returned twice
  });

  test('CatchHistoryDao.page filtered by zone returns a catch that has no trip', () async {
    await _insertCatch(db, tripId: null, jurisdiction: 'es', zone: 'es-gal-rb');

    final page = await dao.page(
      const HistoryFilter(zone: ZoneRef(jurisdictionCode: 'es', zoneCode: 'es-gal-rb')),
    );

    expect(page.rows, hasLength(1)); // SPEC §4.5 "Done looks like", as a test
  });
}
```

```dart
// app/test/data/services/user_db/catch_history_query_plan_test.dart
test('CatchHistoryDao.page searches an index for the zone-filtered history query', () async {
  final plan = await db.customSelect(
    'EXPLAIN QUERY PLAN ${dao.pageSqlFor(kZoneFilter)}',
  ).get();

  final detail = plan.map((r) => r.data['detail'] as String).join(' | ');
  expect(detail, contains('USING INDEX idx_catch_zone_created'));
  expect(detail, isNot(contains('SCAN')));
});
```

```dart
// app/test/data/services/user_db/catch_history_scale_test.dart
test('CatchHistoryDao.page returns the last page within twice the first page at 10,000 catches',
    () async {
  await seedCatches(db, count: 10000);           // §13's realistic shape, rounded up

  final first = await _timePage(after: null);
  var cursor = await _cursorForPage(250);
  final last = await _timePage(after: cursor);

  expect(first.inMicroseconds, lessThan(16000));  // one 60 Hz frame
  expect(last.inMicroseconds, lessThan(first.inMicroseconds * 2)); // keyset, not OFFSET
});
```

**Run:** `cd app && flutter test test/data/services/user_db test/domain/use_cases/catch_history_use_case_test.dart test/ui/log/history_screen_test.dart`
→ 24 failures.

## Implementation outline

1. **Read E05/T08's existing cursor first** (epic Risks 9). Decide replace-or-extend before writing a
   line, and say which in the commit body.
2. **The migration, by the `run-migration` ritual, in order.** Snapshot, `schemaVersion` + 1, one
   appended step creating the three indexes, `drift_dev make-migrations`, commit the snapshot and
   `schema_versions.dart`. Do not edit T01's step.
3. `history_filter.dart`, `history_page.dart`, `history_totals.dart` — immutable value types with
   value equality. `HistoryFilter` is the `family` key, so its `==` must be correct or the provider
   caches the wrong page (`state-management-riverpod`: never `family`-key on a mutable object).
4. `catch_history_dao.dart` — the paged `.get()`, the composite predicate, the narrow freshness
   `.watch()`, and a `pageSqlFor(filter)` seam the query-plan test can call. Single-table only.
5. `catch_history_use_case.dart` — the join: species names and the season window from
   `ReferenceRepository`, the counts from the DAO. Its failure switch is exhaustive with no `default:`.
6. `history_view_model.dart` — an `AsyncNotifier` over `HistoryState(pages, cursor, hasMore, filter)`.
   It appends on `loadMore()` and, on a freshness emission, drops the tail and refetches page one. No
   `await for` over any stream.
7. `history_screen.dart` — `CustomScrollView` with slivers (trip section labels interleave with catch
   rows, which `row-and-table-anatomy.md`'s container table routes to slivers rather than one
   `ListView` with type switches). All four states authored.
8. `lonja_catch_row.dart` — the log-row slots: leading 22 × 22 glyph, serif headline, sans detail
   line, `LonjaPill` end slot, chevron only because the row opens S11. One `InkWell` over the whole
   rect at `rowMinHeight`.
9. `history_totals_panel.dart` — the annual line always, the season line only when it resolves.
10. Wire S10 into E12's bottom-navigation **Trips** slot, replacing the placeholder.
11. Re-run the whole suite, including T01's and E05's migration tests.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 24 tests pass, and each failed first.
- [ ] `schemaVersion` moved by exactly one; one step appended; T01's step untouched; snapshot committed.
- [ ] `grep -rn "OFFSET\|\.offset(" app/lib/data` returns nothing.
- [ ] The cursor is the pair `(created_at, id)` everywhere, including in E05/T08's original caller.
- [ ] Three `EXPLAIN QUERY PLAN` assertions pass and none of the three plans contains `SCAN`.
- [ ] At 10,000 seeded rows: every page under 16 ms and the last page within 2× the first.
- [ ] The paged query is **not** watched; freshness comes from one narrow scoped stream.
- [ ] S10 authors all four states; the stale bar coexists with data.
- [ ] `check_lonja_lists.sh app/lib` is clean, and no `shrinkWrap: true` list exists in
      `app/lib/ui/log/`.
- [ ] No `TextOverflow.ellipsis`, `FittedBox` or computed `fontSize` on any real label in
      `app/lib/ui/log/` (`accessibility-as-code` rule 5).
- [ ] Golden lanes 1, 2, 3, 5, 6, 8 and 10 of `the-four-states.md`'s matrix exist for S10.

## Gates

```bash
dart format --set-exit-if-changed .
cd app && flutter analyze && flutter test && cd ..
grep -rn "OFFSET\|\.offset(" app/lib/data              # must return nothing
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                 app/lib
tools/gates/no_directional_geometry.sh                                      app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-drift-confinement.sh        app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-persistence-bans.sh         app/lib
$FLUTTER_SKILLS/state-management-riverpod/scripts/ban-legacy-providers.sh   app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(log): filter and page the catch history with a composite keyset cursor

created_at is not unique — two quick-adds inside one millisecond are ordinary
at 05:40 — so a cursor of created_at alone either repeats a tie group or drops
it, and only ever at a page boundary. The cursor is now the pair
(created_at, id) and two separate tests assert the two failure modes, because
a page that duplicates and a page that omits are different bugs.

Three composite indexes carry id explicitly: a page ordered
created_at DESC, id DESC cannot be produced in order by a key that stops at
created_at, and the engine would sort or scan instead. EXPLAIN QUERY PLAN
assertions are what prove it, not the index definitions.

Pages are one-shot reads and freshness is one narrow watched query. Watching
the paged query would re-run and re-materialise every loaded page on every
insert — drift's own documented behaviour, compounded by List.== being
identity — which is exactly the "instant at 10,000 catches" this task defends.

SPEC §4.5 gives the adjective and no figure, so the test uses one 60 Hz frame:
a page slower than 16 ms drops a frame mid-fling. The hardware-independent
half is that the last page stays within 2x the first, which OFFSET cannot do.

Task: E13/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
