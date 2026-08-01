# E13/T02 — The catch record

| | |
|---|---|
| **Epic** | E13 — The catch log |
| **Branch** | `epic/13-catch-log` (shared) |
| **Commit** | `feat(data): record a catch that carries its own zone and its own citation` |
| **Depends on** | T01 (`iso_utc.dart`, the failure family, and the open-trip query the attachment reads) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.2 (`catch` and the denormalisation rationale), §4.5 (Catch record), §13 (crash safety) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `persistence-drift` | Rules 2, 4, 5, 7: the `CHECK` that mirrors the Dart enum, one transaction per mutation with every statement awaited, canonical storage, and the DAO↔repository split this write path sits on. |
| `catchlaw-reference-database` | `references/two-database-contract.md` — the column-by-column argument for why a catch row copies what it was judged under, and the ATTACH ban that forbids resolving any of it by join. |
| `error-handling-typed-results` | `references/never-lose-data.md` §1 — prep outside the transaction, the forbidden-inside table, and the rollback test that proves this write is all-or-nothing. |
| `catchlaw-conventions-index` | Invariants 2 and 3 in `references/product-invariants.md`: the stored `outcome_detail` is a statement of fact, and `rule_citation_ref` is what keeps a three-year-old row cited. |
| `lonja-buttons` | Rules 1, 2, 11, 12 for the `+ Add to today` control this task finally adds to S2 — one primary per screen, a verb label, and a busy latch so a bounced tap does not write two rows. |
| `state-management-riverpod` | Rule 5, the single write path, and the `void`-returning intent method that closes the dropped-`Future` hole on `onPressed`. |
| `service-boundary-and-native` | Rule 8 again: `created_at` comes from `clockProvider`, never `DateTime.now()`. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.2 `catch` + the paragraph under the SQL block | The 16 columns, the four indexes, and the reason `scientific_name`, `rule_citation_ref` and `content_version` are copied |
| `SPEC.md` | §4.5 rows "Catch record" and "History" | The zone codes on the catch itself, and why: "History filters by zone work for quick-added catches with no trip" |
| `SPEC.md` | §13 row "Crash safety" | "the catch is persisted before the UI animates" |
| `SPEC.md` | §12 "Import (S16)" | The merge key `(created_at, species_id, length_mm)` — three columns whose stored shape this task fixes for E17 |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "The `catches` row: what is copied and why", "The ATTACH ban" | The per-column table, the Sha'ri counter-example, and the ban on resolving any of it by join |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §2 and §3 | The banned imperative lexicon that `outcome_detail` must already satisfy, and the five `Citation` fields |
| `.claude/skills/lonja-buttons/SKILL.md` | Rules 1, 2, 11 and "Busy, and idempotent under a double tap" | The `+ Add to today` label, the latch, and the ban on a second primary on S2 |
| `$FLUTTER_SKILLS/persistence-drift/references/schema-and-daos.md` | "Invariants live in the schema", "Column type discipline" | `CHECK (col IN (...))` mirroring the Dart enum exactly |
| `$FLUTTER_SKILLS/error-handling-typed-results/references/never-lose-data.md` | §1 | The transaction shape and the rollback test |
| `FLUTTER_GUIDE.md` | Part 5.2 | "Writes need no state at all" — the insert marks the table dirty and the stream re-emits |
| `epics/DECISIONS.md` | D-7 | The engine returns types; the app owns every word. `outcome_detail` is written by the app, never by `packages/rule_engine/` |

## What this delivers

- `app/lib/domain/models/catch_record.dart` — the immutable `CatchRecord` value object, one field per
  `SPEC.md` §7.2 column, plus `enum CatchOutcome { meets, fails, attention, unknown }`.
- `app/lib/domain/models/catch_draft.dart` — what a caller hands in: species id, scientific name,
  length, measurement code, the four verdict literals, kept/released. Coordinates and photo are
  present as fields and are written `null` here; T04 and T05 wire them.
- `app/lib/data/services/user_db/daos/catch_dao.dart` — `@DriftAccessor(tables: [Catches])`,
  single-table: `insertCatch()`, `byId()`, `watchForTrip()`, `countSince()`.
- `app/lib/data/repositories/catch_log_repository.dart` — the abstract interface.
- `app/lib/data/repositories/catch_log_repository_drift.dart` — the drift implementation; owns the
  cross-table transaction that reads the open trip and inserts the catch.
- `app/lib/data/model/catch_mapper.dart` — row → `CatchRecord`, draft → companion. The only file that
  knows both shapes.
- `app/testing/fakes/fake_catch_log_repository.dart` — hand-written, `implements`, failure paths
  reachable.
- `app/lib/ui/log/providers/catch_log_providers.dart` — `catchLogRepositoryProvider`.
- **The `+ Add to today` control on S2**, added to E10's action row under `app/lib/ui/result/`, with
  its ARB key in all six locales of D-3. E10's PR body records this as its one deliberate hole.
- Tests: `app/test/data/repositories/catch_log_repository_test.dart`,
  `app/test/data/services/user_db/catch_schema_test.dart`,
  `app/test/data/model/catch_mapper_test.dart`,
  `app/test/ui/result/add_to_today_test.dart`.

## Why it is built this way

**The table class cannot be called `Catch`.** drift generates a getter from the table class name, so
a class `Catch` produces `$CatchTable get catch => …` on the database, and `catch` is a Dart keyword —
that does not compile. The class is `Catches` with `@DataClassName('CatchRow')` and an explicit
`@override String get tableName => 'catch';` so the **SQL** name stays exactly what `SPEC.md` §7.2
publishes and what E17's import reads. Test 18 asserts the name against `sqlite_master`, because this
is the kind of thing a rename fixes and a reviewer approves.

**`jurisdiction_code` and `zone_code` are on the catch because §4.5 says so, and this was a
first-draft defect.** The first design put them only on the trip. A quick-add has no trip, so S10's
zone filter simply could not see it — the filter silently returned a subset and looked like it
worked. Both codes are copied from the **active profile at record time**, not from the trip and not
resolved at render time: a fisher who crosses a bank boundary at 08:00 is still on one trip, and the
fish landed at 09:00 belongs to the zone it was landed in.

**`scientific_name`, `rule_citation_ref`, `content_version`, `outcome` and `outcome_detail` are
literals, and nothing on a record screen may resolve them by join.** §7.2's own paragraph is the
argument: a content update can renumber or retire a rule, and a three-year-old record must still say
what it said. `two-database-contract.md` gives the concrete failure — Sha'ri (*Lethrinus nebulosus*)
carries a closed season 1 March – 30 April; if a later pack moves that window, a live join would
retroactively declare a lawful March 2025 catch an offence. `species_id` is kept as a soft hint for
"show me this species again", and if it no longer resolves the row still renders completely.

**`outcome_detail` is written by the app, never by the engine.** D-7: `packages/rule_engine/` returns
sealed types carrying numbers, enums and a `Citation`, and holds no user-visible sentence in any
language. The sentence stored here is the one E10 rendered and the fisher actually saw — §7.2 calls it
"the factual finding text as shown". The repository stores the string it is handed; it does not
format, translate or re-derive it. It is still bound by invariant 2: no imperative, ever, and
`check_app_invariants.sh` check 3 scans for the banned lexicon.

**A consequence worth naming: the stored sentence carries no locale tag.** §7.2 has no locale column,
so a record made in `ar` still reads in Arabic after the fisher switches the app to `es`. That is the
correct behaviour — the row says what it said — but it means E17's CSV, whose headers are localised to
the *active* language, will carry a column of sentences that may be in another. Do not "fix" it by
re-rendering the sentence at export time; that would make the record mutable, which is the one thing
it must not be.

**The catch attaches to the open trip, or to nothing.** Never to the most recent closed trip. "Most
recent" is the tempting one-line query and it silently files this morning's fish into yesterday's trip
report, where it changes a total that E17 hands to an inspector. T01's `ux_one_open_trip` is what makes
"the open trip" a well-defined phrase.

**Recording a catch does not bump `species_recent`.** E12 bumps it when a species is opened, which is
already the path every recorded catch travels. A second bump here would rank a species at twice its
real use in S1's recents strip, and §4.1 specifies recents ordered by frequency then recency — a
frequency counted twice is not a frequency.

**Rejected: a nullable `outcome`.** §7.2 makes it `NOT NULL` with a four-value `CHECK`, and `unknown`
is one of the four. A nullable column plus an `unknown` value gives two representations of the same
state, and one of them will be written by an importer.

**Rejected: writing the row and then publishing optimistically.** `SPEC.md` §13 says the catch is
persisted *before* the UI animates. `record()` returns only after the durable commit, and the surface
updates because the watched query re-emits (`FLUTTER_GUIDE.md` §5.2 — "writes need no state at all").
There is no `state =` and no `ref.invalidate` on this path.

## Tests first

Write every row before touching `catch_dao.dart`. Run them. **They must fail.** If one passes now the
test is wrong — fix it before writing any production code.

All repository tests run against `NativeDatabase.memory()`. Test 9 opens a second, *fixture*
`reference.db` in which the rule has been renumbered; that is the only test in the epic that actually
exercises a content update.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `CatchLogRepository.record writes every SPEC §7.2 catch column` | a draft with every optional field populated | all 16 columns read back equal | No column is dead. E17 serialises every one of them, and a column nothing writes is a column E17 exports as NULL forever |
| 2 | `CatchLogRepository.record copies the active jurisdiction and zone onto the catch` | active zone `es-gal-rb`, no trip | row carries `es`, `es-gal-rb` | The §4.5 defect this epic exists to close |
| 3 | `CatchLogRepository.record stores the active zone, not the trip's zone` | trip opened in `es-gal-ar`, active zone now `es-gal-rb` | row carries `es-gal-rb` | The fisher crossed a boundary mid-trip; the trip's zone is only where he started |
| 4 | `CatchLogRepository.record leaves the stored codes intact when the active zone changes afterwards` | record, then switch zone | row unchanged | The row is a snapshot, not a view. A view would rewrite history every time he switches zones |
| 5 | `CatchLogRepository.record attaches the catch to the open trip` | one open trip | `trip_id` = that trip | §4.5 "catches attach to it" |
| 6 | `CatchLogRepository.record writes a null tripId when no trip is open` | no trips at all | `trip_id` IS NULL | The quick-add case that motivated columns 3 and 4 in the first place |
| 7 | `CatchLogRepository.record never attaches a catch to the most recently closed trip` | one closed trip, none open | `trip_id` IS NULL | "Most recent trip" is the tempting shortcut; it backdates this morning's fish into yesterday's report and changes a total E17 hands to an inspector |
| 8 | `CatchLogRepository.record copies scientificName, ruleCitationRef and contentVersion from the draft` | draft with all three | all three stored verbatim | §7.2's denormalisation rationale, as an assertion rather than a comment |
| 9 | `CatchRecord keeps its outcomeDetail and ruleCitationRef after the reference pack is replaced` | record, swap the fixture `reference.db` for one where the rule is renumbered and its citation retired, reopen | both unchanged, character for character | The acceptance condition of "history is immutable", and the Sha'ri counter-example in `two-database-contract.md` |
| 10 | `UserDatabase rejects an outcome outside the four SPEC §7.2 values` | raw insert `outcome = 'maybe'` | `SqliteException` | The `CHECK` and the Dart enum are two descriptions of one set; this is what stops them drifting |
| 11 | `CatchOutcome maps the stored value <value>` (loop over `meets`, `fails`, `attention`, `unknown`) | each of the four | the matching enum case | Loop-generated, parameter interpolated per `CONVENTIONS.md` §5. A fifth outcome must break the build, not silently become `unknown` |
| 12 | `CatchLogRepository.record rolls back and writes nothing when the insert violates a constraint` | forced violation | `Err(CatchLogTransactionRolledBack)` and `dumpAllRows()` byte-identical | `never-lose-data.md` §1's blocking test; a half-applied catch is invisible until S10 is read weeks later |
| 13 | `CatchDao.watchForTrip emits the new catch after record resolves` | subscribe, `await record`, read the next emission | the emission contains the row | The observable half of persist-before-publish (§13). If this needs a manual republish to pass, someone added a `state =` |
| 14 | `CatchLogRepository.record writes null latitude and longitude` | draft with a fix attached | both NULL | Coordinates are off by default (§4.5) and T05 owns the policy. A column written before its policy exists is a leak that ships |
| 15 | `CatchLogRepository.record writes a null photoPath` | any draft | `photo_path` IS NULL | Same reason, for T04. The photo directory does not exist yet |
| 16 | `CatchLogRepository.record stamps createdAt and updatedAt to the same instant` | `Clock.fixed` | both equal | §12 merges on `created_at` and tiebreaks on `updated_at`; an unequal pair on insert makes a brand-new row look edited and lose a merge it should win |
| 17 | `CatchMapper maps a row whose every nullable column is null` | length, method, detail, citation, version, photo, lat, lon all NULL | a `CatchRecord` with nulls, and back to an identical row | Eight of the 16 columns are nullable in §7.2; a mapper that assumes non-null throws on the first quick-add with no measurement |
| 18 | `UserDatabase names the catch table 'catch'` | `SELECT name FROM sqlite_master` | contains `catch`, not `catches` | The Dart keyword forces the class to be `Catches`; the SQL name must stay §7.2's because E17's import reads it |
| 19 | `CatchLogRepository.record leaves species_recent untouched` | record a catch | `species_recent` row count and `use_count` unchanged | E12 already bumps on species open; a second bump ranks a species at twice its real use in S1 |
| 20 | `AddToTodayButton writes one catch when tapped twice inside the latch` | two taps 90 ms apart | exactly one row | `lonja-buttons` rule 11 — wet fingers bounce, and two rows double the tally and the vessel aggregate |

```dart
// app/test/data/repositories/catch_log_repository_test.dart
void main() {
  late UserDatabase db;
  late CatchLogRepository repo;
  final t0 = DateTime.utc(2026, 8, 1, 6, 12, 0);

  setUp(() {
    db = UserDatabase(NativeDatabase.memory()); // catchlaw-db-ok — in-memory test harness
    repo = CatchLogRepositoryDrift(
      db,
      clock: Clock.fixed(t0),
      activeZone: const ActiveZone(jurisdictionCode: 'es', zoneCode: 'es-gal-rb'),
    );
  });
  tearDown(() => db.close());

  test('CatchLogRepository.record copies the active jurisdiction and zone onto the catch', () async {
    await repo.record(kDraftAmeixaBabosa);
    final row = await db.select(db.catches).getSingle();
    expect(row.jurisdictionCode, 'es');
    expect(row.zoneCode, 'es-gal-rb');
    expect(row.tripId, isNull); // no trip open — this is the quick-add case
  });

  test('CatchLogRepository.record never attaches a catch to the most recently closed trip', () async {
    await _seedClosedTrip(db, startedAt: t0.subtract(const Duration(days: 1)));
    await repo.record(kDraftAmeixaBabosa);
    expect((await db.select(db.catches).getSingle()).tripId, isNull);
  });

  test('CatchLogRepository.record rolls back and writes nothing when the insert violates a constraint',
      () async {
    final before = await db.dumpAllRows();
    final result = await repo.record(kDraftWithUnknownTripRef);
    expect((result as Err).failure, isA<CatchLogTransactionRolledBack>());
    expect(await db.dumpAllRows(), equals(before));
  });

  for (final value in CatchOutcome.values) {
    test('CatchOutcome maps the stored value ${value.name}', () {
      expect(catchOutcomeFromColumn(value.name), value);
    });
  }

  // … one test per row above, one behaviour each
}
```

```dart
// app/test/data/repositories/catch_immutability_test.dart
test('CatchRecord keeps its outcomeDetail and ruleCitationRef after the reference pack is replaced',
    () async {
  await repo.record(kDraftShari);          // recorded under RAK-GULF v2026.2
  final before = await repo.byId(1);

  await installReferenceFixture(kRenumberedPack); // rule renumbered, citation retired

  final after = await repo.byId(1);
  expect(after.outcomeDetail, before.outcomeDetail);
  expect(after.ruleCitationRef, before.ruleCitationRef);
  expect(after.contentVersion, 'v2026.2');  // still names the pack that judged it
});
```

**Run:** `cd app && flutter test test/data test/ui/result/add_to_today_test.dart` → 20 failures.

## Implementation outline

1. Read `app/lib/data/services/user_db/tables/catch_table.dart` **first**. E05 created it; this task
   adds no column and renames nothing. Confirm the class name, the `@DataClassName` and the
   `tableName` override before writing the DAO (epic Risks 1).
2. `catch_record.dart` — the value object and `enum CatchOutcome`. Immutable, `const` constructor,
   no drift import. `catchOutcomeFromColumn` is total over the four `CHECK` values and throws an
   `ArgumentError` on anything else: that is a bug, not a recoverable failure
   (`error-handling-typed-results` rule 7).
3. `catch_draft.dart` — the input type. Its four verdict fields are plain values handed in by the
   caller; nothing here imports `packages/rule_engine/`.
4. `catch_dao.dart` — single-table queries only, returning value objects.
5. `catch_log_repository_drift.dart` — holds `UserDatabase`. Shape:

   ```
   resolve now + iso from the injected Clock                  // outside the transaction
   read the active jurisdiction/zone from the profile          // outside the transaction
   try {
     await db.transaction(() async {
       final tripId = await tripDao.openTripId();              // awaited
       await catchDao.insertCatch(draft, tripId: tripId, ...);  // awaited
     });
     return Ok(record);
   } on SqliteException catch (e, st) { log (e, st) FIRST, then Err }
   ```
6. `catch_mapper.dart` — the only file that sees both `CatchRow` and `CatchRecord`. Every nullable
   column handled explicitly; no `!`.
7. `fake_catch_log_repository.dart` — `implements`, with constructors for the reachable failures.
8. **S2's `+ Add to today`.** A `LonjaButton.primary` in E10's action row under `app/lib/ui/result/`.
   Check the file first: S2 may already build a primary, and `check_lonja_buttons.sh` fails a file with
   two. If it does, this control is `LonjaButton.secondary` and the existing primary keeps its rank.
   The handler is a `void` intent method that latches on `_busy` before its first `await` and clears it
   in a `finally` gated on `mounted`. The label is an ARB key in all six locales — a verb phrase naming
   its object, never `Keep`, never `Add`.
9. Re-run the whole suite. T01's trip tests must still be green: the attachment query is new traffic
   against `ux_one_open_trip`.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 20 tests pass, and each failed first.
- [ ] Every one of `SPEC.md` §7.2's 16 `catch` columns is written by `record()` and read by a test.
- [ ] `app/lib/data/repositories/catch_log_repository_drift.dart` contains no `state =`, no
      `ref.invalidate` and no `ref` at all — the repository takes no `Ref` (`FLUTTER_GUIDE.md` §5.2).
- [ ] `record()` is exactly one `db.transaction`; the clock and the active zone are resolved before it
      opens; nothing unrelated is awaited inside it.
- [ ] No file outside `app/lib/data/` names `CatchRow`, and no file outside
      `app/lib/data/model/catch_mapper.dart` names both `CatchRow` and `CatchRecord`.
- [ ] The SQL table is named `catch`; the `CHECK` on `outcome` lists exactly the four §7.2 values.
- [ ] `check_app_invariants.sh` check 3 is clean over the new ARB keys in all six locales of D-3 —
      no `app_ur.arb`, no `app_pt.arb`.
- [ ] S2 builds exactly one `LonjaButtonVariant.primary`, and the new control's handler is idempotent
      under a double tap.
- [ ] `packages/rule_engine/` is not imported by anything added in this task.

## Gates

```bash
dart format --set-exit-if-changed .
cd app && flutter analyze && flutter test && cd ..
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                 app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh    app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-drift-confinement.sh        app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-persistence-bans.sh         app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(data): record a catch that carries its own zone and its own citation

The first draft put jurisdiction and zone only on the trip. A quick-add has no
trip, so S10's zone filter could not see it — and the filter still returned
rows, so it looked like it worked. Both codes are now copied onto the catch
from the active profile at record time, which also means a fisher who crosses
a bank boundary mid-morning gets each fish filed where it was landed rather
than where he started.

scientific_name, rule_citation_ref, content_version, outcome and
outcome_detail are literals and nothing resolves them by join. SPEC §7.2 gives
the reason and two-database-contract.md gives the case: Sha'ri carries a closed
season 1 March – 30 April, and a pack that later moves that window would make
a live join declare a lawful March 2025 catch an offence.

The catch attaches to the open trip or to nothing. Never to the most recent
closed trip: that one-line query files this morning's fish into yesterday's
report and changes a total E17 hands to an inspector.

Task: E13/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
