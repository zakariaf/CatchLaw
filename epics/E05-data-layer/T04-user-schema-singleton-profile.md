# E05/T04 — The user schema and the singleton profile

| | |
|---|---|
| **Epic** | E05 — Data layer: two drift databases |
| **Branch** | `epic/05-data-layer` (shared) |
| **Commit** | `feat(data): model user.db in drift with the singleton user_profile row` |
| **Depends on** | — (parallel with T01–T03) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.2 in full, including the paragraph on why `catch` denormalises; §7.4 bullet 3 (`onCreate` runs the schema and inserts the singleton row) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-reference-database` | Rules 1, 8 and 10: no table crosses the line, the catch row denormalises what it was judged under, and `user.db` lives in the support directory and **is** backed up |
| `persistence-drift` | Rules 2, 3 and 5: invariants in the schema (`STRICT`, `CHECK`, FK with explicit `onDelete`), the per-connection pragmas set in `setup`/`beforeOpen`, and canonical storage |
| `catchlaw-conventions-index` | Rule 11 — no identifier ever leaves the device; nothing in this schema is a device id, an install UUID or an account |
| `testing-strategy` | Rule 4: a real `NativeDatabase.memory()`, never a mocked DAO. A `CHECK` proved by a stub is not proved |
| `run-migration` | This schema is version 1 of a forward-only sequence; the strategy and its snapshot are T05's, and this task must not pre-empt them |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.2 | The authoritative DDL: 7 tables, 5 indexes, every `CHECK`, every default, `CHECK (id = 1)` on `user_profile` |
| `SPEC.md` | §7.2 closing paragraph | Why `catch` denormalises `scientific_name`, `rule_citation_ref` and `content_version` — "History is immutable" |
| `SPEC.md` | §7.4 bullet 3 | "`onCreate` runs the schema above and inserts the singleton `user_profile` row" |
| `SPEC.md` | §13 | The DB-size row: 5 yrs × 200 trips × 8 catches ≈ 8,000 rows ≈ < 4 MB, plus ~200 KB per photo |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | rules 1, 8, 10; "Denormalising the judgment onto the catch row" | The principle. The column list there is illustrative — `SPEC.md` §7.2 is the schema that ships |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "Ownership matrix", "The `catches` row: what is copied and why" | The Sha'ri closed-season counter-example: a live join would retroactively declare a lawful March 2025 catch an offence |
| `$FLUTTER_SKILLS/persistence-drift/SKILL.md` | rules 2, 3; "Schema: invariants in the table"; "The connection: pragmas per open" | `isStrict`, `customConstraints`, and the `setup:` block that re-asserts `foreign_keys` on every open |
| `$FLUTTER_SKILLS/persistence-drift/references/schema-and-daos.md` | "Invariants live in the schema" | Why `CHECK` beats a call-site guard, and the warning against baking a configurable layout into a `CHECK` |
| `FLUTTER_GUIDE.md` | §2.5 | `data/services/user_database_service.dart`, and rule 7: databases open lazily, never in `main()` |
| `FLUTTER_GUIDE.md` | §5.2 | `LazyDatabase` + `NativeDatabase.createInBackground` |
| `epics/DECISIONS.md` | D-3 | `user_profile.locale_override` holds one of six locale tags — `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`. Never `ur`, never bare `pt` |

## What this delivers

- `app/lib/data/services/user_database_service.dart` — the `@DriftDatabase` class `UserDatabase`,
  `static const understoodSchemaVersion = 1`, `schemaVersion => understoodSchemaVersion`, and
  `userExecutor(File file)` returning a `LazyDatabase` over `NativeDatabase.createInBackground(file,
  setup: …)`.
- `app/lib/data/services/tables/user/` — 7 `Table` subclasses covering `SPEC.md` §7.2 exactly:
  `user_profile.dart` · `saved_zone.dart` · `trip.dart` · `catch.dart` · `species_recent.dart` ·
  `rule_flag.dart` · `app_meta.dart`.
- A minimal `MigrationStrategy` with `onCreate: (m) => m.createAll()` and a `beforeOpen` that re-asserts
  the per-connection pragmas and inserts the singleton `user_profile` row under
  `if (details.wasCreated)`. The `stepByStep` machinery, the committed snapshot and the migration tests
  are **T05's** and are not started here.
- Generated `.g.dart`, committed.
- `app/test/data/user_schema_test.dart`.

## Why it is built this way

**The singleton is enforced by the schema, not by the code that writes it.** `SPEC.md` §7.2 puts
`CHECK (id = 1)` on `user_profile`, so a second settings row is not merely discouraged — it cannot be
written. `persistence-drift` rule 2 is the general form: a corrupt row must be unrepresentable at the
storage layer rather than policed in Dart, because the policing is one forgotten call site away from
being absent. The insert itself goes in `beforeOpen` under `if (details.wasCreated)` — the one place
`persistence-drift` rule 3 licenses seeding — and not in `onCreate`, where a failure would abort the
create and leave a half-built database.

**`catch` stores literals, not foreign keys into `reference.db`.** §7.2's closing paragraph is
categorical: a content update can renumber or retire a rule, and a three-year-old record must still say
what it said when it was recorded. `two-database-contract.md` gives the case that makes it concrete —
شعري Sha'ri carries a closed season of 1 March to 30 April; if a later pack moves that window, a live
join would retroactively declare a lawful March 2025 catch an offence. `species_id` is stored as a soft
hint for "show me this species again" and nothing on the record screen may read through it; if it no
longer resolves, the row still renders completely.

**`STRICT` is added; no column of §7.2 changes.** `persistence-drift` rule 2 wants `STRICT` tables so a
column never silently coerces a type — `length_mm` accepting the string `'380'` is exactly the class of
defect that surfaces three screens later as an arithmetic error. It adds a storage-level guarantee and
changes no column name, no type and no value, so §7.2 still describes what ships.

**Timestamps stay `TEXT`, against `persistence-drift` rule 5's preference.** §7.2 types `created_at`,
`updated_at`, `started_at` and `last_used_at` as `TEXT`, and §12's export format is built on those
shapes. `SPEC.md` is authoritative for the product, so this task follows it — and it is safe to, because
ISO-8601 UTC strings sort lexicographically in chronological order, so `idx_catch_created` serves
`ORDER BY created_at DESC` and T08's keyset cursor exactly as an integer column would. The divergence is
recorded in the epic's Risks rather than resolved here; **no task quietly switches a column type**.

**The pragmas are re-asserted on every open, and the set differs from the reference database's.**
`foreign_keys` and `synchronous` are per-connection and are not persisted in the file, so they are set
in `setup` on every open; `journal_mode = WAL` is persisted in the header but is set idempotently so a
freshly created or restored database adopts it. `synchronous = FULL` rather than `NORMAL` because this
is non-regenerable data: SQLite states that WAL + `NORMAL` transactions may roll back after a power
failure, and there is no cloud copy to recover from. This is the opposite of T01's connection, which
sets nothing that writes — the two databases have opposite lifecycles and therefore opposite pragma
sets, which is the point.

**`species_recent` is `WITHOUT ROWID` with a three-column primary key.** §7.2 says so. The table is
read on every Check-home render (E12) keyed by exactly `(species_id, jurisdiction_code, zone_code)`, so
the primary key *is* the access path and a rowid would be one extra indirection on the 1.2 s cold-start
path.

**Rejected: the audit-column mixin, UUID primary keys and soft delete.** `schema-and-daos.md` prescribes
all three for a generic offline app: a text UUID PK, `created_at`/`updated_at`/`row_revision`,
`is_deleted`/`deleted_at`, and one shared base query filtering soft-deletes. §7.2 has none of them —
integer primary keys, no revision counter, hard deletes. The reasons the mixin exists are merge-safety
across devices and reconciliation for a future sync; CATCHLAW has no account, no sync and no second
device (`catchlaw-conventions-index` rule 11), so the mixin buys nothing and would add five columns to
every one of the 8,000 rows §13 budgets. Adopting it would also change the export format §12 specifies.

**Rejected: naming the drift class after the table.** `catch` is a Dart reserved word, and drift's
singulariser turns a table class `Catches` into a data class `Catche`. The table class is `Catches` with
`@override String get tableName => 'catch'` so the SQL matches §7.2 exactly, and `@DataClassName('CatchRow')`
so the generated type reads. `catch` is not an SQLite keyword, so the table name needs no quoting.

## Tests first

Write every row before touching a table class. Run them. **They must fail** — a `CHECK` that passes
before the constraint exists means the test inserted a row the constraint would also have accepted.

`app/test/data/user_schema_test.dart` uses `UserDatabase(NativeDatabase.memory())` with `addTearDown(db.close)`.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `UserDatabase reports understoodSchemaVersion 1` | fresh | `1` | The number T05 bumps and T06 compares against. Two names for it would drift |
| 2 | `UserDatabase exposes all 7 tables of SPEC 7.2` | `db.allTables` | length 7, names match §7.2 | A table missing from `@DriftDatabase` is invisible until the epic that needs it |
| 3 | `UserDatabase declares the 5 indexes of SPEC 7.2` | `sqlite_master` | the 5 §7.2 names | `idx_catch_created` is what makes the tally query and T08's cursor cheap |
| 4 | `UserDatabase creates exactly one user_profile row on first open` | fresh open | 1 row, `id` = 1 | §7.4 bullet 3, and the row every settings read depends on existing |
| 5 | `user_profile rejects a second row` | insert `id: 2` | `SqliteException` | The `CHECK (id = 1)`. Two settings rows means two answers to "what unit am I in" |
| 6 | `user_profile applies the SPEC 7.2 defaults on creation` | read the row | `numeral_system` `auto`, `length_unit` `cm`, `capture_coordinates` 0, `sunlight_mode` 0, `glove_mode` 0 | The defaults are product decisions: coordinates off unless opted in (§7.2), units in cm |
| 7 | `user_profile rejects a numeral_system outside auto, latn and arab` | insert `'deva'` | `SqliteException` | §9.3's numeral lever has exactly three settings; a fourth would render digits nobody chose |
| 8 | `user_profile rejects a length_unit outside cm, mm and in` | insert `'ft'` | `SqliteException` | The ruler reads this. An unknown unit is a measurement with no scale |
| 9 | `catch rejects an outcome outside meets, fails, attention and unknown` | insert `'ok'` | `SqliteException` | The four §7.2 outcomes are the four the result screen renders; a fifth renders nothing |
| 10 | `catch keeps its row when its trip is deleted` | insert catch on a trip, delete the trip | catch present, `trip_id` `NULL` | `ON DELETE SET NULL` from §7.2. Deleting a trip must never delete the fish that were in it |
| 11 | `catch stores scientific_name, rule_citation_ref and content_version as literals` | insert, then assert no FK to any reference table | columns hold the given strings | The immutable-history paragraph of §7.2, asserted structurally |
| 12 | `saved_zone rejects a duplicate jurisdiction_code and zone_code pair` | insert twice | `SqliteException` | §7.2's `UNIQUE`. A duplicated saved zone is a picker with the same entry twice |
| 13 | `species_recent is stored WITHOUT ROWID with its three-column primary key` | `sqlite_master.sql` | `WITHOUT ROWID`, PK `(species_id, jurisdiction_code, zone_code)` | The access path of the Check-home recents query, on the 1.2 s path |
| 14 | `species_recent replaces rather than duplicates on a repeated use` | `insertOnConflictUpdate` twice | 1 row, `use_count` 2 | The composite PK is the dedupe key; a second row would split one species' history |
| 15 | `app_meta stores one value per key` | write the same key twice | 1 row, latest value | The marker of T03 lives here; two rows for one key make the marker ambiguous |
| 16 | `UserDatabase enforces foreign keys on every open` | reopen the same file, then violate an FK | `SqliteException` | `foreign_keys` is per-connection and OFF by default; SQLite silently no-ops FK actions when it is off |
| 17 | `UserDatabase opens in WAL journal mode with synchronous FULL` | `PRAGMA journal_mode`, `PRAGMA synchronous` | `wal`, `2` | Non-regenerable data: WAL + `NORMAL` may roll back after power loss, and there is no cloud copy |
| 18 | `every user table is declared STRICT` | `sqlite_master.sql` for each | contains `STRICT` | A `length_mm` that silently accepts `'380'` is an arithmetic error three screens away |

```dart
// app/test/data/user_schema_test.dart
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late UserDatabase db;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);
  });

  test('UserDatabase creates exactly one user_profile row on first open', () async {
    final rows = await db.select(db.userProfile).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 1);
  });

  test('user_profile rejects a second row', () async {
    await expectLater(
      db.customStatement('INSERT INTO user_profile (id) VALUES (2)'),
      throwsA(isA<SqliteException>()),
      reason: 'CHECK (id = 1): two settings rows means two answers to "what unit am I in"',
    );
  });

  test('catch keeps its row when its trip is deleted', () async {
    await db.customStatement(
      "INSERT INTO trip (id, started_at, jurisdiction_code, zone_code) "
      "VALUES (1, '2026-07-14T05:41:12Z', 'ES-GA', 'RIAS-BAIXAS')",
    );
    await db.customStatement(
      "INSERT INTO catch (id, trip_id, jurisdiction_code, zone_code, species_id, "
      "scientific_name, outcome, created_at, updated_at) VALUES "
      "(1, 1, 'ES-GA', 'RIAS-BAIXAS', 7, 'Epinephelus marginatus', 'meets', "
      "'2026-07-14T05:41:12Z', '2026-07-14T05:41:12Z')",
    );

    await db.customStatement('DELETE FROM trip WHERE id = 1');

    final rows = await db.customSelect('SELECT trip_id FROM catch WHERE id = 1').get();
    expect(rows, hasLength(1), reason: 'deleting a trip must never delete the fish that were in it');
    expect(rows.single.data['trip_id'], isNull);
  });

  // … one test per remaining row above, one behaviour each
}
```

## Implementation outline

1. Write the 7 `Table` subclasses, transcribing `SPEC.md` §7.2 column by column. Each gets
   `isStrict => true`; every enumerable column gets its `CHECK` through `customConstraints`;
   `species_recent` gets `withoutRowId => true` and its three-column `primaryKey`.
2. `Catches` overrides `tableName` to `catch` and carries `@DataClassName('CatchRow')`.
3. Declare the 5 indexes with `@TableIndex` so test 3 can see them in `sqlite_master`.
4. Write `UserDatabase`: `understoodSchemaVersion`, `schemaVersion`, and a `MigrationStrategy` with
   `onCreate: (m) => m.createAll()` and a `beforeOpen` that runs
   `PRAGMA foreign_keys = ON`, then inserts the `user_profile` row under `if (details.wasCreated)`.
5. Write `userExecutor(File file)` — `LazyDatabase` over `NativeDatabase.createInBackground(file,
   setup: …)` with `journal_mode = WAL`, `synchronous = FULL`, `foreign_keys = ON`, `busy_timeout = 5000`.
   The path is injected; resolving it is the composition root's job in T09.
6. `dart run build_runner build --delete-conflicting-outputs` from `app/`. Commit the generated file.
7. Re-run the suite. 18 green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 tests pass, and each failed first.
- [ ] `UserDatabase.allTables` has exactly 7 entries and their names match `SPEC.md` §7.2.
- [ ] Every table is `STRICT`; every §7.2 `CHECK` exists and is proved by a rejecting test.
- [ ] Exactly one `user_profile` row exists after a fresh open, and a second is unwritable.
- [ ] No column of `catch` is a foreign key into any `reference.db` table.
- [ ] `foreign_keys`, `journal_mode`, `synchronous` and `busy_timeout` are set in `setup`/`beforeOpen`
      and asserted on a reopened file, not only on a fresh one.
- [ ] No column added beyond §7.2; no audit column, no UUID, no soft-delete flag.
- [ ] `understoodSchemaVersion` is the single source of the version number; `schemaVersion` returns it.
- [ ] `app/lib/main.dart` is unchanged by this task.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-drift-confinement.sh       app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-persistence-bans.sh        app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(data): model user.db in drift with the singleton user_profile row

SPEC 7.2 as 7 STRICT drift tables and 5 indexes. The settings row is a
singleton because the schema says so — CHECK (id = 1) makes a second row
unwritable rather than merely discouraged — and it is inserted in beforeOpen
under details.wasCreated, the one place seeding belongs.

catch stores scientific_name, rule_citation_ref and content_version as
literals with no foreign key into reference.db. A pack that moves Sha'ri's
closed season must not retroactively declare a lawful March 2025 catch an
offence, and a live join would.

The connection sets journal_mode = WAL, synchronous = FULL, foreign_keys = ON
and a busy timeout on every open: the first two because this is the only
copy of the log that exists, the third because SQLite defaults it off and
silently no-ops every FK action when it is.

Task: E05/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
