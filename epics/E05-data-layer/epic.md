# E05 — Data layer: two drift databases

| | |
|---|---|
| **Branch** | `epic/05-data-layer` |
| **After** | E04 merged |
| **Tasks** | 10 |
| **Spec** | `SPEC.md` §7.1, §7.2, §7.4 (migration strategy in full), §13 (first launch < 6 s, cold start < 1.2 s), §14 (force-quit during extraction) |
| **Guide** | `FLUTTER_GUIDE.md` Part 1.4, 1.5, 1.6, 2.5, 5.1–5.4, 6.4 |
| **Package** | `app/` — with one emit step added to `tools/content_builder/` in T03 |
| **Decisions** | D-1 (paths), D-3 (six locales), D-5 (drift 2.34.2, Riverpod 3.4.1), D-6 (the merged extraction design), D-7 (no sentence in the engine) |

## What this epic achieves

When this merges, the app can read the rule book and can write the fisher's log, and the two cannot
touch each other. `reference.db` — everything in `SPEC.md` §7.1: 22 tables, 7 indexes and the
`legal_text_fts` virtual table — ships gzipped as an asset, is extracted once through a temp file and
an atomic rename, is verified by sha256, and is opened `readOnly: true` for the rest of its life. A
content update replaces that file wholesale and cannot reach `user.db`, which holds all 7 tables of
§7.2 including the singleton `user_profile` row, is migrated forward-only with a test per version, and
is refused rather than corrupted when it was written by a newer build. Neither database is awaited
before `runApp`. Every later epic gets typed repositories with abstract interfaces and fakes, so E06
onward can be built and tested without a device and without a real database file.

## Where we are now

The branch is cut from a `main` that already carries:

- **E01** — the pub workspace of D-1 (`app/`, `packages/rule_engine/`, `packages/analysis_defaults/`,
  `tools/content_builder/`), the analysis options of `FLUTTER_GUIDE.md` §4.3, the §14 static gates
  wired into CI, and the checked-in direct-dependency allowlist that §14 diffs against.
- **E02, E03** — `packages/rule_engine/`: the ordered normalisation fold of §9.4, the §7.3 resolution
  algorithm, the sealed `Verdict`/`Finding` types with their required `Citation`, and
  `packages/rule_engine/lib/src/failure.dart` — the `Result`/`Failure` spine that this epic's
  repositories return (`FLUTTER_GUIDE.md` §2.5's tree names that file).
- **E04** — `tools/content_builder/`, which turns authored YAML into `reference.db` with every §8
  assertion, seeded with Galicia. The build output exists; nothing in the app reads it yet.

What does not exist: any drift class, any DAO, any repository, `app/assets/db/reference.db.gz`,
`app/assets/content_build.json`, and any code in `app/lib/data/`. `app/lib/main.dart` exists from E01
as a composition root that opens nothing.

## Why this epic exists here in the order

It cannot come earlier: T01 mirrors `SPEC.md` §7.1 table for table, and the file it opens is produced
by `tools/content_builder/` — E04. T03 adds an emit step to that builder, which must therefore already
build. T07's DAO tests need a real `reference.db` to open, and only E04 can make one.

It must not come later: E06 (localisation) resolves `content_string` through the fallback chain, and
`content_string` is a `reference.db` table read through a DAO. E11 (zones) reads `zone` and `zone_ring`.
E13 (catch log) writes `catch` and `trip`. `epics/README.md` puts E05 in the **After** column of E06 and
E11 for exactly this reason, and `SPEC.md` §15 step 4 places the data layer immediately after the
content build for the same one.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | The reference schema, opened read-only | `T01-reference-schema-read-only.md` | L | — |
| T02 | Extraction: temp file, sha256, atomic rename | `T02-extraction-temp-sha256-rename.md` | L | T01 |
| T03 | The marker and the generated constant | `T03-marker-and-generated-constant.md` | M | T02, and T04 for `app_meta` |
| T04 | The user schema and the singleton profile | `T04-user-schema-singleton-profile.md` | M | — |
| T05 | `MigrationStrategy` and the fixture test harness | `T05-migration-strategy-and-fixtures.md` | L | T04 |
| T06 | Refuse a database from the future | `T06-refuse-database-from-the-future.md` | S | T05 |
| T07 | The reference DAOs | `T07-reference-daos.md` | M | T01 |
| T08 | The user DAOs | `T08-user-daos.md` | M | T04 |
| T09 | Repositories, interfaces and fakes | `T09-repositories-interfaces-fakes.md` | L | T07, T08 |
| T10 | Mappers: drift rows never escape `data/` | `T10-mappers-rows-stay-in-data.md` | M | T09 |

T04 has no dependency on T01–T03 and can be built in parallel by a second pair of hands; T03 needs
`app_meta` from T04 because D-6 puts the completion marker there. Everything else is a straight line.

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once the epic is whole:

- [ ] All 10 tasks committed, one commit each, every `Task: E05/T<nn>` trailer present.
- [ ] `cd app && flutter test` green; `dart format --set-exit-if-changed .` and `flutter analyze` clean
      at the workspace root.
- [ ] All 22 tables, 7 indexes and the `legal_text_fts` virtual table of `SPEC.md` §7.1 are reachable
      from `ReferenceDatabase`; all 7 tables and 5 indexes of §7.2 from `UserDatabase`.
- [ ] `check_reference_db.sh app/lib` clean — all five checks, no `// catchlaw-db-ok` outside the two
      test seams named in T01 and T05.
- [ ] `check_app_invariants.sh app/lib` clean.
- [ ] `app/lib/main.dart` contains no `await` on any executor, installer or database open. Proved by
      check 1 of `check_reference_db.sh`, not by reading.
- [ ] Opening the extracted `reference.db` and running the full suite leaves **no** `reference.db-wal`
      and **no** `reference.db-shm` beside it, and its sha256 still equals `kContentBuildSha256`.
- [ ] A force-quit simulated at every one of the eight write-sequence steps leaves either the previous
      `reference.db` or the new one — never a truncated file that opens.
- [ ] `user.db` is byte-identical before and after a refused open of a database from the future.
- [ ] Every repository has an abstract interface, a drift implementation, and a fake under
      `app/testing/fakes/`; every public method returns `Future<Result<T, F>>` or `Stream<T>`.
- [ ] No file outside `app/lib/data/` imports `package:drift` or `package:sqlite3`.
- [ ] `packages/rule_engine/` gains no dependency in this epic and still imports no Flutter and no drift.
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin`; branch deleted.

## Risks and the things that will bite

**1. A WAL-mode `reference.db` cannot be opened read-only.** If E04 leaves the built file in
`journal_mode = WAL`, a read-only open fails outright — SQLite must create a `-shm` before it can read
a WAL database, and it cannot on a read-only handle. The symptom is a `SqliteException` at first query,
long after the file looked fine on a developer machine where the `-wal` happened to exist. T01 asserts
`PRAGMA journal_mode` on the shipped file reads `delete` (or `off`) and that no sidecar appears after a
full suite run. If the assertion fails, the fix belongs in `tools/content_builder/` and is an E04
follow-up commit on this branch, not a change to the open.

**2. drift's table definitions and the content builder's DDL are two descriptions of one schema.**
E04 writes the DDL that creates `reference.db`; E05 writes the drift `Table` classes that read it. They
can drift apart silently — a renamed column produces a runtime `SqliteException` on one query, in one
locale, on one screen. T01 ships a parity test that opens a real built `reference.db` and selects every
column of every table; T07's DAO tests run against the same real file rather than a drift-created one.
This is a mitigation, not a fix: the only real fix is one generator, and that is out of scope here.

**3. `SPEC.md` §7.2 and `persistence-drift` disagree about column types, and neither is wrong.** §7.2
types timestamps as `TEXT` (ISO-8601) and primary keys as `INTEGER PRIMARY KEY`; `persistence-drift`
rule 5 wants UTC epoch millis as `INTEGER`, and `references/schema-and-daos.md` wants a text UUID PK
with audit columns and soft delete. `SPEC.md` is authoritative for the product and §12's export format
depends on §7.2's shapes, so this epic follows §7.2 — and it is safe to, because ISO-8601 UTC strings
sort lexicographically in chronological order, so `ORDER BY created_at DESC` and the keyset cursor of
T08 behave exactly as an integer would. **What would resolve it:** a `DECISIONS.md` entry naming §7.2
as the winner for CATCHLAW's storage shapes. Until that entry exists this paragraph is the record, and
no task quietly switches a column type.

**4. `run-migration` rule 1 and `persistence-drift` rule 10 prescribe different snapshot mechanisms.**
Rule 1 says copy the DB file and its `-wal`/`-shm` sidecars; rule 10 says never `File.copy` a database
and use `wal_checkpoint(TRUNCATE)` + `VACUUM INTO` + verify-by-reopen. `check-persistence-bans.sh`
check 1 fails any `.copy(` on a line mentioning a database and offers no escape hatch. T05 follows the
gate — the rule of thumb recorded in D-2 is that an executable gate beats prose about a path — and takes
the pre-migration snapshot with checkpoint + `VACUUM INTO` on a raw handle that is disposed before drift
opens the file. Restoring is a `rename`, never a copy.

**5. The first-launch budget is measured on a device this epic does not have.** §13's 6 s is specified
on a Snapdragon 665 and `catchlaw-reference-database/references/extraction-and-first-launch.md` names
Android 11 / 4 GB / eMMC as the reference device. Nothing in E05 can prove it; T02 asserts the shape
that makes it achievable — a streamed gunzip, progress reported at most every 64 KiB, a denominator
that is a real byte count — and the measurement is E21's, on hardware. **Do not** invent a number here.

**6. The `Result` spine's arity is E03's, not E05's.** `error-handling-typed-results` requires
`Result<T, F extends Failure>` so a `switch` over failures is exhaustive; `FLUTTER_GUIDE.md` §1.6 shows
the single-parameter `Result<T>` from `flutter/samples` and then lists the four reasons not to ship it
as written, including that its `Error` arm shadows `dart:core.Error`. T09 uses whatever E03 committed to
`packages/rule_engine/lib/src/failure.dart` and adds one sealed `DataFailure` family beneath it. **It
does not fork a second spine.** If E03 shipped the single-parameter form, changing the arity is an E03
follow-up and is recorded here rather than done quietly in E05.

**7. `crypto` is a new direct dependency and §14 diffs the allowlist.** T02 needs sha256. The package
is pure Dart and opens nothing, but the checked-in allowlist E01 ships is the only permitted set, so
the allowlist entry lands in T02's commit or CI fails on the very next push.

## PR description

### What changed

Two drift databases, with opposite lifecycles and no seam between them.

`reference.db` — the whole of `SPEC.md` §7.1 as drift tables plus the `legal_text_fts` virtual table,
`schemaVersion` frozen at 1, a `MigrationStrategy` whose `onCreate` and `onUpgrade` both throw, and a
`LazyDatabase` executor that opens `NativeDatabase.createInBackground(file, readOnly: true)`. It is
extracted from `app/assets/db/reference.db.gz` on first launch and after a content update: orphan `.tmp`
sweep, streamed gunzip to `reference.db.tmp` with determinate progress, sha256 and byte-count
verification, one `File.rename`, then the marker. The decision to extract compares a generated Dart
constant against `app_meta.content_build_date` and opens no reference database to make it.

`user.db` — the whole of §7.2, `onCreate` running the schema and inserting the single `user_profile`
row under its `CHECK (id = 1)`, forward-only `stepByStep` migration with a committed schema snapshot, a
checkpoint + `VACUUM INTO` snapshot taken before the open and restored if the open throws, and a
`PRAGMA user_version` check on a raw read-only handle that refuses a database from the future instead of
letting drift write into columns it cannot see.

On top: DAOs for both files, repositories with abstract interfaces and fakes, and row → domain mappers
confined to `app/lib/data/model/`.

### Why

`SPEC.md` §7 opens with the reason the split exists: *a content update replaces `reference.db` wholesale
and can never touch the user's catch log.* There is no account and no sync, so `user.db` is the only copy
of the fisher's history. Two files make a content drop structurally incapable of writing to it — the
update path only ever renames onto a path the user database does not live at.

The read-only open is not tidiness. A writable open lets drift run `onCreate` against shipped content and
drop a `-wal` beside it, after which the sha256 no longer matches and every later integrity check is a
false alarm (`catchlaw-conventions-index` rule 7).

The extraction gate is a generated constant against a marker because the obvious design — read
`content_meta.build_date` out of the shipped database — is circular: to read one row you must
materialise the ~10 MB the check exists to skip, on every launch (D-6, `SPEC.md` §7.4).

### How it was verified

- Every table, index, `CHECK` and `WITHOUT ROWID` clause of §7.1 and §7.2 asserted against a real
  `NativeDatabase`, never a mocked DAO (`testing-strategy` rule 4).
- The `SPEC.md` §14 force-quit case is a test, not a manual step: an extraction interrupted at each of
  the eight steps of the write sequence leaves no openable truncated database, and the next call
  succeeds.
- A read-only open followed by the full suite leaves no `-wal` and no `-shm`, and the file's sha256 is
  unchanged.
- A `user.db` at `user_version` = understood + 1 is refused with both numbers, and the file is
  byte-identical afterwards.
- Migration: the every-pair shape loop, a content test with a hostile fixture (apostrophes, Arabic,
  em dashes, whitespace-only), `PRAGMA integrity_check` = `ok`, `PRAGMA foreign_key_check` empty, and a
  forced mid-migration throw that restores the snapshot.
- `check_reference_db.sh app/lib`, `check_app_invariants.sh app/lib`, `check-drift-confinement.sh
  app/lib`, `check-persistence-bans.sh app/lib` and `check-swallowed-catch.sh app/lib` all clean.

### Product invariants touched

- **Invariant 1 (no network).** No dependency added here opens a socket. `crypto`, `path`,
  `path_provider`, `sqlite3_flutter_libs` are added to the checked-in allowlist in T02 and diffed by §14.
- **Invariant 3 (every result carries a citation).** `catch` denormalises `rule_citation_ref` and
  `content_version` per §7.2 so a three-year-old record still names the instrument that produced it.
- **Invariant 5 (stale beats absent).** Nothing in this epic filters on `valid_to`; expiry is §7.3's and
  is E03's, and the DAOs of T07 return expired rows unchanged.
- **Rule 8 of `catchlaw-conventions-index` (nothing awaited before `runApp`).** Both executors are
  `LazyDatabase`; the composition root constructs them synchronously.

### Follow-ups deliberately not in this PR

- The first-launch progress **screen** — the determinate bar, its copy and its non-dismissable
  disclaimer. T02 delivers the `onProgress(done, total)` callback and its byte denominator; the surface
  belongs to `lonja-verdict-and-status` and E12.
- The **refusal screen** for a database from the future. T06 delivers
  `UserDbFromTheFutureFailure(found:, understood:)` with a stable code and two typed integers; the
  sentence is an ARB key in six locales and belongs to E06.
- **Zone geometry decoding.** T07 returns `zone_ring.coords` as bytes; the Float64 unpacking and the
  point-in-polygon test are E11's.
- **Photo files.** `catch.photo_path` is a column here and nothing more; the camera service, the
  relative-path base directory and the bulk purge are E13 and E16.
- **Export and import.** T08 gives the catch log its streams; §12's four artefacts are E17.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start E06.

**A note on the two skill registries and the paths used throughout this epic.** `CONVENTIONS.md` §4
names them: the `catchlaw-*` and `lonja-*` skills live in this repository under `.claude/skills/`, and
the 33 general Flutter skills live in the separate `Flutter-Skills` plugin. Every task file below cites
in-repo skill files as `.claude/skills/<name>/…` and plugin skill files as `$FLUTTER_SKILLS/<name>/…`,
where `$FLUTTER_SKILLS` is that plugin's `skills/` directory — the two registries are not one tree and
writing them as if they were sends a builder looking for a file that is not there.

The same split applies to the gate commands. In-repo gates are invoked from the repository root as
`.claude/skills/<name>/scripts/check_*.sh app/lib`; they exit **2** on a missing directory, so the target
is always explicit (`CONVENTIONS.md` §7, D-1). Passing the target explicitly matters for the plugin
scripts too, and for the opposite reason: `check-drift-confinement.sh` prints `SKIP` and exits **0** when
its target is missing, which is exactly the pass-on-an-empty-scan failure `CONVENTIONS.md` §7 warns
about.
