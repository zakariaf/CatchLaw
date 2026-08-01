## What changed

Two drift databases with opposite lifecycles and no seam between them, plus the DAOs, repositories,
mappers and fakes every later epic reads them through. Ten of ten E05 tasks.

**`reference.db`** — the whole of `SPEC.md` §7.1 as 22 drift tables plus the `legal_text_fts` virtual
table, `schemaVersion` frozen at 1, a `MigrationStrategy` whose `onCreate` and `onUpgrade` both
throw, and a `LazyDatabase` executor over a **read-only sqlite3 handle**. Extracted from
`app/assets/db/reference.db.gz` on first launch and after a content update: orphan `.tmp` sweep,
cleared marker, streamed gunzip with determinate progress, sha256 and byte-count verification, one
`File.rename`, then the marker. The decision to extract compares a generated Dart constant against
`app_meta.content_build_date` and opens no reference database to make it.

**`user.db`** — the whole of §7.2, `onCreate` inserting the single `user_profile` row under its
`CHECK (id = 1)`, forward-only `stepByStep` migration, a checkpoint + `VACUUM INTO` snapshot taken
before the open and restored by `rename` if it throws, and a `user_version` read **out of the SQLite
header** that refuses a database from the future rather than letting drift write into columns it
cannot see.

**On top** — three repositories behind abstract interfaces, each with a drift implementation and a
bare-`implements` fake, and row → domain mappers confined to `app/lib/data/model/`.

## Why

`SPEC.md` §7 opens with the reason the split exists: *a content update replaces `reference.db`
wholesale and can never touch the user's catch log.* There is no account and no sync, so `user.db` is
the only copy of the fisher's history. Two files make a content drop structurally incapable of
writing to it — the update path only ever renames onto a path the user database does not live at.

The read-only open is not tidiness. A writable open lets drift run `onCreate` against shipped content
and drop a `-wal` beside it, after which the sha256 no longer matches and every later integrity check
is a false alarm on a database that is fine.

The extraction gate is a constant against a marker because the obvious design — read
`content_meta.build_date` out of the shipped database — is circular: reading one row means
materialising the payload the check exists to skip, on every launch (D-6, §7.4).

Repositories return `Future<Result<T>>` with a **sealed** `DataFailure` arm, so a `switch` at the call
site is exhaustive and a new failure is a compile error at every one of them. Reactive reads return a
plain `Stream`: `AsyncValue<Result<T>>` is four states where two are meaningful, and
`FLUTTER_GUIDE.md` §1.7 bans the nesting outright.

## How it was verified

- 316 tests. `flutter analyze --fatal-infos` clean, `dart format` clean.
- The **parity test**: drift's `Table` classes and `tools/content_builder`'s DDL are two descriptions
  of one schema with nothing forcing them to agree, so the suite opens the **real built file** and
  selects every column of every table.
- §14's force-quit case as a test, not a manual step: an extraction interrupted at each step of the
  write sequence leaves no openable truncated database, and the next call succeeds.
- A read-only open followed by the full suite leaves no `-wal`, no `-shm`, and the same sha256.
- A `user.db` at `user_version` = understood + 1 is refused with both numbers, and the file is
  byte-identical afterwards.
- Migration: the every-pair shape loop, a hostile content fixture (apostrophes, Arabic, em dashes,
  backslashes, a whitespace-only note), `PRAGMA integrity_check` = `ok`, `PRAGMA foreign_key_check`
  empty, and a forced mid-migration throw that restores the snapshot.
- One round-trip test per mapper on that same fixture, because `minLat: row.minLat, minLon:
  row.minLon` is a swap that compiles and puts a bounding box in the wrong hemisphere.
- `layering_test.dart` asserts the rules that decay first — no import edge between the reference and
  measurement repositories in either direction, no Riverpod in a repository, no drift row type outside
  `lib/data/`, no `asOk` anywhere — and asserts its **file list is non-empty first**, because a scan
  of an empty tree reports success.
- `run_skill_gates.sh` green over all seventeen invocations; `ban-legacy-providers.sh`,
  `check-swallowed-catch.sh` and `check-drift-confinement.sh` clean over `app/lib`.

## Product invariants touched

None weakened.

- **1, no network** — nothing added here opens a socket; `check_no_network.sh app/lib` is green.
- **3, every result carries a citation** — `toRule` and `toClosedSeason` take their `Citation` as a
  **required argument**. A default would satisfy the non-nullable field and print a footnote that
  cites nothing, which is the defect the invariant exists to make unrepresentable. The repository
  resolves citations first, and a rule whose citation does not resolve becomes a typed `DataNotFound`
  rather than a rule with a blank footnote. `catch` also denormalises `rule_citation_ref` and
  `content_version` per §7.2, so a three-year-old record still names the instrument behind it.
- **5, an expired ruleset is still evaluated** — nothing here filters on `valid_to`. Expiry is §7.3's
  and E03's, and the DAOs return expired rows unchanged.
- **Rule 8, nothing awaited before `runApp`** — both executors are `LazyDatabase`, `dataOverrides` is
  synchronous, and the test that proves it passes an `AppDirectories` that fails if it is called.

## Decisions raised rather than worked around

**D-16 — the read-only open.** `catchlaw-reference-database` prescribes
`NativeDatabase.createInBackground(file, readOnly: true)`, and drift 2.34.2 has no `readOnly`
parameter on that constructor. The alternative available there is a writable handle guarded by
`PRAGMA query_only`, which is a promise rather than a protection: the OS would still permit the write
that leaves a `-wal` and breaks every later sha256 check. D-6's guarantee rests on the handle, so the
handle is what is read-only. The cost is named — the open runs on the calling isolate rather than a
background one, and `LazyDatabase` still defers it to the first query, which is the property §5.2 is
actually protecting.

**D-17 — no committed drift schema snapshot.** `drift_dev` ≥ 2.34.1 needs `analyzer` ^13, which
`package:test` forbids in this workspace; pinned at 2.34.0 its `schema` subcommands refuse to run
against drift 2.34.2. The migration harness therefore asserts the every-pair shape loop and the
integrity pragmas directly, and the missing snapshot is an owned gap rather than a silently skipped
step.

## Follow-ups deliberately not in this PR

- The first-launch **progress screen**. T02 delivers `onProgress(done, total)` and its real byte
  denominator; the surface is E12's.
- The **refusal screen** for a database from the future. T06 delivers
  `DatabaseFromTheFuture(found:, understood:)` with a stable code and two typed integers; the sentence
  is an ARB key in six locales and belongs to E06.
- **Zone geometry decoding.** T07 returns `zone_ring.coords` as bytes; Float64 unpacking and
  point-in-polygon are E11's.
- **Photo files.** `catch.photo_path` is a column here and nothing more; the camera service is E13's.
- **Export and import.** T08 gives the catch log its streams; §12's four artefacts are E17's.
- **The `Result` arity.** E03 shipped the single-parameter `Result<T>`; E05 used it as shipped and
  added the sealed `DataFailure` beneath it rather than forking a second spine. Changing the arity is
  an E03 follow-up that no task owns, and risk 6 of the epic records it.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
