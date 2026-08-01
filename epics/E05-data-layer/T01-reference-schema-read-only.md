# E05/T01 — The reference schema, opened read-only

| | |
|---|---|
| **Epic** | E05 — Data layer: two drift databases |
| **Branch** | `epic/05-data-layer` (shared) |
| **Commit** | `feat(data): model reference.db in drift and open it read-only` |
| **Depends on** | E04 merged — `tools/content_builder/` must be able to produce a real `reference.db` |
| **Size** | L |
| **Spec** | `SPEC.md` §7.1 in full; §7.4 bullet 1 (shipped whole, disposable) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-reference-database` | Owns the two-database contract. Rules 1, 3, 4 and 10 are this task: no table crosses, `readOnly: true` always, both migration callbacks throw, and the file lives under `getApplicationSupportDirectory()/reference/` |
| `catchlaw-conventions-index` | Rule 7 (three files, two databases, the shipped one read-only) and rule 8 (nothing awaited before `runApp`) — this task must not weaken either |
| `persistence-drift` | Drift itself: `@DriftDatabase` wiring, `Table` subclasses, `customConstraints`, `withoutRowId`, the `setup:` pragma seam, and why `NativeDatabase` FFI rather than `sqflite` |
| `testing-strategy` | Rule 4: the data layer is tested against a real engine, never a mocked DAO. Also the `db.close()` teardown that stops `.watch()` timers leaking between tests |
| `run-migration` | Read to know what **not** to do here: `reference.db` is the one database in this app for which the whole ritual is forbidden |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.1 | The authoritative DDL. 22 tables, 7 indexes, the `legal_text_fts` virtual table, every `CHECK`, every `WITHOUT ROWID` |
| `SPEC.md` | §7.4 bullet 1 | `reference.db` is shipped whole and disposable — the sentence that justifies a frozen `schemaVersion` |
| `SPEC.md` | §13 | The cold-start line: "`reference.db` opened lazily read-only" is the mechanism, < 1.2 s is the target |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | Non-negotiable rules 1, 3, 4, 10, 11; "The split, in one file each"; "Opening lazily, and never before `runApp`" | The exact `MigrationStrategy` shape whose callbacks throw, and the `LazyDatabase` executor |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "Ownership matrix", "Directories, and the ones that are wrong", "The ATTACH ban" | Why the support directory and not documents/temp/cache; why no shared `QueryExecutor` |
| `.claude/skills/catchlaw-reference-database/examples/reference_database.dart` | lines 32–48 | The worked `ReferenceDatabase` + `referenceExecutor()` — do not diverge from it silently |
| `.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh` | checks 2 and 3 | The gate's actual windows: `readOnly` must appear within the call + 2 lines, and the word "reference" within 8 lines above it; a migration callback is a hit unless `throw`/`StateError`/`UnsupportedError` appears within 6 lines |
| `.claude/skills/catchlaw-conventions-index/SKILL.md` | rules 6, 7, 8 | The one-way layer map and the read-only open |
| `FLUTTER_GUIDE.md` | §2.5 | Where these files go: `data/services/`, and rule 6 — drift row classes never escape `data/` |
| `FLUTTER_GUIDE.md` | §5.2 | `LazyDatabase` + `NativeDatabase.createInBackground`, and "Never `await` a database open before `runApp`" |
| `FLUTTER_GUIDE.md` | §7.4 | Generated files are committed; `.gitattributes`, not `.gitignore` |
| `epics/DECISIONS.md` | D-1, D-5, D-6 | Paths, drift 2.34.2, and the five-part extraction design this task implements part 5 of |

## What this delivers

- `app/lib/data/services/reference_database_service.dart` — the `@DriftDatabase` class
  `ReferenceDatabase`, `schemaVersion` frozen at `1`, a `MigrationStrategy` whose `onCreate` and
  `onUpgrade` both `throw StateError`, and `referenceExecutor()` returning a `LazyDatabase` over
  `NativeDatabase.createInBackground(file, readOnly: true, setup: …)`.
- `app/lib/data/services/tables/reference/` — one file per table group, 22 `Table` subclasses covering
  `SPEC.md` §7.1 exactly:
  `jurisdiction.dart` · `zone.dart` (zone, zone_ring) · `taxonomy.dart` (family, species, species_name)
  · `measurement.dart` · `citation.dart` · `rule.dart` (rule, closed_season) · `licence.dart` ·
  `gear.dart` · `penalty.dart` · `lookalike.dart` · `glossary.dart` · `content_change.dart` ·
  `key.dart` (key_node, key_leaf_species, key_option) · `content_string.dart` · `legal_text.dart` ·
  `content_meta.dart`.
- `app/lib/data/services/tables/reference/legal_text_fts.drift` — the `CREATE VIRTUAL TABLE … USING
  fts5` declaration. An fts5 table cannot be expressed as a Dart `Table` subclass; a `.drift` file is
  how drift is told the relation exists so T07 can query it typed.
- `app/lib/data/services/reference_database_service.g.dart` and the generated `.drift.dart`, committed.
- `app/testing/fixtures/reference_fixture.dart` — `ReferenceDatabase.forTesting()`, the one in-memory
  seam, and `openBuiltReference()` which opens the real file produced by `tools/content_builder/`.
- `app/test/data/reference_schema_test.dart`, `app/test/data/reference_open_test.dart`.
- `app/pubspec.yaml` gains `drift`, `sqlite3`, `sqlite3_flutter_libs`, `path`, `path_provider` and the
  `drift_dev` dev-dependency at the versions D-5 pins; each is added to the checked-in §14
  direct-dependency allowlist in the same commit.

## Why it is built this way

**`schemaVersion` is frozen at 1 and both migration callbacks throw.** `reference.db` is generated, not
evolved: `SPEC.md` §7.4 calls it "shipped whole and disposable", and
`catchlaw-reference-database` rule 4 spells out the consequence — an incrementally patched reference
database has no single provenance, so `catch.content_version` (§7.2) stops being able to name the pack
that produced a verdict. Throwing callbacks make that unrepresentable rather than merely discouraged.
`check_reference_db.sh` check 3 accepts a `MigrationStrategy` on a `*Reference*Database` class **only**
when `throw`, `StateError` or `UnsupportedError` appears within six lines of it, which is the same
statement in executable form.

**`readOnly: true` is a correctness requirement, not a nicety.** Open the extracted file writable and
drift is entitled to run `onCreate` against shipped content and to leave a `-wal` beside it. From that
moment the file's sha256 no longer matches `kContentBuildSha256`, so T02's integrity check reports a
corrupt payload on a database that is fine — and every later launch re-extracts ~10 MB to fix a problem
the open created. `catchlaw-conventions-index` rule 7 and
`catchlaw-reference-database` rule 3 say the same thing from two directions.

**The read-only open constrains the pragmas.** `persistence-drift` rule 3 sets `journal_mode = WAL`,
`synchronous = FULL`, `foreign_keys = ON` and `busy_timeout` in `setup` on every open. Three of those
are writes. On this connection `setup` sets **only** `PRAGMA query_only = 1;` and `PRAGMA busy_timeout`
— `query_only` is belt-and-braces against a future `INSERT` reaching this handle, and neither writes to
the file. `foreign_keys` is deliberately left off: it governs DML, there is none here, and turning it on
buys nothing on a connection that cannot write.

**The shipped file must not be in WAL journal mode.** SQLite has to create a `-shm` before it can read
a WAL-mode database, and it cannot on a read-only handle: the open fails outright. This is the failure
that will not reproduce on a developer machine, because a stale `-wal` from an earlier writable open is
sitting there making it work. Test 12 asserts `PRAGMA journal_mode` on the real built file reads
`delete` or `off`. If it does not, the fix is in `tools/content_builder/` — E04's DDL — and never a
relaxation of the open.

**Rejected: creating the schema with drift.** The tempting shortcut is `onCreate: (m) => m.createAll()`
so tests get a database for free. It would mean two independent descriptions of one schema — drift's
`Table` classes and the content builder's DDL — with nothing forcing them to agree, and the divergence
would surface as a runtime `SqliteException` on one query in one locale. `createAll()` therefore exists
only behind `ReferenceDatabase.forTesting()`, is marked `@visibleForTesting`, carries the single
`// catchlaw-db-ok` this task is allowed, and is the exact use the skill names as intended for that
escape hatch. The DAO tests of T07 run against a **real built file**, not against `forTesting`.

**Rejected: one drift database over both files with `ATTACH`.** It would make joins across the two
trivial and would re-couple the lifecycles the split exists to separate: a content update renames a new
file over `reference.db`, and any handle spanning both is then pointing at an unlinked inode.
`check_reference_db.sh` check 5 fails on the string, and `two-database-contract.md` gives the second
reason — one connection is one busy timeout, one WAL and one crash surface, so a corrupt reference
database would take `user.db` down with it.

**Rejected: `getApplicationDocumentsDirectory()` or `getTemporaryDirectory()`.** Documents is
user-visible on iOS, so the fisher can delete the rule book by tidying up. Temporary and the OS cache
directory are reclaimed under storage pressure without the app running — the single worst place for the
file whose entire value is answering with no signal. `two-database-contract.md` tabulates all four
candidates; support is the only one that is correct.

**A note on declaration order.** `SPEC.md` §7.1 declares `rule` before `licence_type`, and `rule` has a
foreign key into it. That is legal SQL — SQLite resolves foreign-key targets at DML time, not at
`CREATE` time — but drift's generated `createAll()` orders tables itself, so the `forTesting` seam is
not affected either way. `zone.parent_zone_id` is a self-reference and is expressed with
`customConstraints` rather than `references(Zone, #id)`, which would ask the generator to order a table
against itself.

## Tests first

Write every row before touching a table class. Run them. **They must fail** — there is no
`ReferenceDatabase` to import yet, so the failure is a compile error, and that counts. If a row passes,
the test is asserting something other than what it names; fix the test before writing any production
code.

`app/test/data/reference_schema_test.dart` uses `ReferenceDatabase.forTesting(NativeDatabase.memory())`.
`app/test/data/reference_open_test.dart` uses the real file from `openBuiltReference()`.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ReferenceDatabase reports schemaVersion 1` | `forTesting` | `1` | The version is frozen. A bump here is how somebody starts treating content as migratable |
| 2 | `ReferenceDatabase.migration throws from onCreate` | invoke `migration.onCreate` | `StateError` | Rule 4 in executable form: content is shipped, never created |
| 3 | `ReferenceDatabase.migration throws from onUpgrade` | invoke `migration.onUpgrade(m, 1, 2)` | `StateError` | The other half. `onUpgrade` is the one an `ALTER TABLE` would arrive through |
| 4 | `ReferenceDatabase exposes all 22 tables of SPEC 7.1` | `db.allTables` | length 22, names match the §7.1 set | A table silently missing from `@DriftDatabase` is invisible until the screen that needs it, five epics later |
| 5 | `ReferenceDatabase declares the 7 indexes of SPEC 7.1` | `sqlite_master` where `type='index'` and `name LIKE 'idx_%'` | the 7 §7.1 names | Search latency (< 50 ms at 2,400 names) is an index, not a hope |
| 6 | `species_name rejects a gender outside m, f and n` | insert `gender: 'x'` | `SqliteException` | §7.1's `CHECK`. §9.5 needs gender to be trustworthy in five gendered locales |
| 7 | `zone rejects a water_type outside salt, fresh and both` | insert `water_type: 'brackish'` | `SqliteException` | The `CHECK` that keeps §7.3's resolution from matching nothing |
| 8 | `rule rejects max_size_mm below min_size_mm` | insert `min 450, max 380` | `SqliteException` | §7.1's table-level `CHECK`. An inverted window makes every fish both too small and too large |
| 9 | `content_string is stored WITHOUT ROWID` | `sqlite_master.sql` for `content_string` | contains `WITHOUT ROWID` | §7.1 says so, and it is the difference between one page read and two on every localised string |
| 10 | `key_leaf_species is stored WITHOUT ROWID with a composite primary key` | `sqlite_master.sql` | `WITHOUT ROWID`, PK `(node_id, species_id)` | The §7.1 shape S7's candidate lists depend on |
| 11 | `zone_ring cascades when its zone is deleted` | delete a zone with rings, FKs on | ring rows gone | `ON DELETE CASCADE` only fires with `PRAGMA foreign_keys = ON`; this proves the pragma reached the connection |
| 12 | `built reference.db reports a journal_mode that a read-only open can read` | `openBuiltReference` | `delete` or `off`, never `wal` | The failure that does not reproduce locally, because a stale `-wal` is masking it |
| 13 | `referenceExecutor opens the built file read-only` | attempt `INSERT` through it | `SqliteException` | The whole point. If this passes, drift can write to shipped content |
| 14 | `opening the built reference.db leaves no -wal and no -shm beside it` | open, query, close, list the directory | only `reference.db` | The sidecar is what breaks every later sha256 check — invariant 7's stated failure mode |
| 15 | `opening the built reference.db leaves its sha256 unchanged` | hash before and after a full read pass | equal | Restates 14 as the property that actually matters to T02 |
| 16 | `ReferenceDatabase selects every column of every table in the built file` | one `SELECT *` per table | no throw, column names match the drift schema | The parity test: drift's `Table` classes and the content builder's DDL are two descriptions of one schema |

```dart
// app/test/data/reference_open_test.dart
import 'dart:io';

import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../testing/fixtures/reference_fixture.dart';

void main() {
  late ReferenceDatabase db;
  late File file;

  setUp(() async {
    (db, file) = await openBuiltReference();
    addTearDown(db.close);
  });

  test('built reference.db reports a journal_mode that a read-only open can read', () async {
    final raw = sqlite3.open(file.path, mode: OpenMode.readOnly);
    addTearDown(raw.dispose);
    final mode = (raw.select('PRAGMA journal_mode').first.columnAt(0)! as String).toLowerCase();
    expect(mode, anyOf('delete', 'off'),
        reason: 'a WAL-mode file cannot be opened read-only: SQLite must create a -shm first');
  });

  test('referenceExecutor opens the built file read-only', () async {
    await expectLater(
      db.customStatement("INSERT INTO content_meta (key, value) VALUES ('x', 'y')"),
      throwsA(isA<SqliteException>()),
    );
  });

  test('opening the built reference.db leaves no -wal and no -shm beside it', () async {
    await db.customSelect('SELECT count(*) FROM species').get();
    await db.close();
    final siblings = file.parent
        .listSync()
        .whereType<File>()
        .map((f) => f.path.split(Platform.pathSeparator).last)
        .toList();
    expect(siblings, isNot(anyElement(endsWith('-wal'))));
    expect(siblings, isNot(anyElement(endsWith('-shm'))));
  });

  test('opening the built reference.db leaves its sha256 unchanged', () async {
    final before = (await sha256.bind(file.openRead()).first).toString();
    await db.customSelect('SELECT count(*) FROM species_name').get();
    await db.close();
    final after = (await sha256.bind(file.openRead()).first).toString();
    expect(after, before, reason: 'a read must not mutate shipped content');
  });

  // … rows 16 and the remaining schema rows in reference_schema_test.dart
}
```

```dart
// app/test/data/reference_schema_test.dart
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late ReferenceDatabase db;

  setUp(() {
    db = ReferenceDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
  });

  test('ReferenceDatabase reports schemaVersion 1', () {
    expect(db.schemaVersion, 1);
  });

  test('ReferenceDatabase.migration throws from onUpgrade', () {
    expect(
      () => db.migration.onUpgrade!(Migrator(db), 1, 2),
      throwsA(isA<StateError>()),
    );
  });

  test('rule rejects max_size_mm below min_size_mm', () async {
    await expectLater(
      db.customStatement(
        'INSERT INTO rule (jurisdiction_id, species_id, water_type, min_size_mm, '
        'max_size_mm, citation_id, valid_from) VALUES (1, 1, \'salt\', 450, 380, 1, \'2026-01-01\')',
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  // … one test per remaining row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/data/` → 16 failures. If any passes now, the test is wrong.

## Implementation outline

1. Add the dependencies of D-5 to `app/pubspec.yaml` and the same names to the checked-in §14
   direct-dependency allowlist. `flutter pub get` at the workspace root.
2. Write the 22 `Table` subclasses, transcribing `SPEC.md` §7.1 column by column. Every enumerable
   column gets its `CHECK` through `customConstraints`; `content_string` and `key_leaf_species` get
   `withoutRowId => true` and their composite `primaryKey`. Do not add columns §7.1 does not have.
3. Write `legal_text_fts.drift` with the fts5 declaration exactly as §7.1 spells it, including
   `content='legal_text'`, `content_rowid='id'` and `tokenize='unicode61 remove_diacritics 2'`.
4. Declare the 7 indexes. drift's `@TableIndex` carries them into the generated schema so test 5 can
   see them in `sqlite_master`.
5. Write `ReferenceDatabase`: `schemaVersion => 1`, the throwing `MigrationStrategy`, and the
   `@visibleForTesting` `forTesting` constructor whose strategy is `onCreate: (m) => m.createAll()` and
   which carries `// catchlaw-db-ok` with a comment naming this task.
6. Write `referenceExecutor(File file)` — a `LazyDatabase` whose callback returns
   `NativeDatabase.createInBackground(file, readOnly: true, setup: …)`. Keep the word `reference` within
   eight lines above the `NativeDatabase(` call and `readOnly: true` on the call itself or the two lines
   after it, or check 2 of the gate cannot see them. **The file path argument is injected**; T02 owns
   resolving it, and that is what keeps this task testable without `path_provider`.
7. `dart run build_runner build --delete-conflicting-outputs` from `app/`. Commit the generated files
   (`FLUTTER_GUIDE.md` §7.4).
8. Write `app/testing/fixtures/reference_fixture.dart`: `openBuiltReference()` shells out to nothing —
   it reads the file `tools/content_builder/` wrote into `build/reference.db` and copies it into the
   test's temp directory so a test can never mutate the build output.
9. Re-run the suite. 16 green, and nothing else in the workspace changed.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 16 tests pass, and each failed first.
- [ ] `ReferenceDatabase.allTables` has exactly 22 entries and their names match `SPEC.md` §7.1.
- [ ] `schemaVersion` is `1`; both migration callbacks throw; neither is reachable in the app.
- [ ] The only `// catchlaw-db-ok` in this commit is on `ReferenceDatabase.forTesting`, and its comment
      names E05/T01.
- [ ] `NativeDatabase.createInBackground` for the reference file passes `readOnly: true`, and check 2 of
      `check_reference_db.sh` sees it.
- [ ] `setup:` on the reference connection sets no pragma that writes to the file.
- [ ] No `ATTACH` anywhere; no `QueryExecutor` shared with anything.
- [ ] Generated `.g.dart` / `.drift.dart` are committed, and `*.g.dart linguist-generated=true -diff` is
      already in `.gitattributes` from E01.
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
feat(data): model reference.db in drift and open it read-only

SPEC 7.1 as 22 drift tables, 7 indexes and the fts5 declaration, with
schemaVersion frozen at 1 and both migration callbacks throwing. The open
is readOnly: true and its setup pragmas write nothing: a writable open lets
drift run onCreate against shipped content and drop a -wal beside it, after
which the sha256 no longer matches and every later integrity check is a
false alarm. Tests assert no -wal and no -shm survive a full read pass, and
that the built file's journal_mode is one a read-only handle can open at
all — a WAL-mode file needs to create a -shm first and simply fails.

Task: E05/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
