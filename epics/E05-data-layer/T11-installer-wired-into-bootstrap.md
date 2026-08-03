# E05/T11 — The installer runs before the pack is opened

| | |
|---|---|
| **Epic** | E05 — Data layer: two drift databases |
| **Branch** | `fix/v1-device-defects` |
| **Commit** | `fix(data): extract the shipped pack before opening it` |
| **Depends on** | T02 (the installer), T03 (the extraction decision), E12/T08 (the seam that reads the pack) |
| **Size** | S |
| **Spec** | `SPEC.md` §7.4 (first-launch extraction) |
| **Found by** | Running v1 on an iOS simulator. No test caught it |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-reference-database` | Rule 5 and the extraction ladder — the installer is the only path to a readable `reference.db`, and D-6 owns the mechanism |
| `catchlaw-offline-guarantee` | The failure is total offline unusability, which is the one thing this product may never do |
| `error-handling-typed-results` | `ensureInstalled()` returns `Result<File>`; the locate callback must not swallow the `Failure` |
| `testing-strategy` | Why a fake-executor suite is blind to this, and what the replacement assertion is |

## What went wrong

`ReferenceInstaller` was built in T02, its decision was built in T03, both were tested, and **nothing
called them.** `bootstrap_data.dart` handed `ReferenceDatabase` an executor that opened
`<support>/reference.db` directly — a path that exists only after extraction. On every device with a
clean install the open failed with `SqliteException(14)` and the Check screen showed *"The bundled rule
pack could not be read"*. The app was unusable on any phone it had never run on, which is every phone.

Nothing in 1459 tests saw it, and the reason is worth writing down: **every suite that reads the pack
constructs its own executor.** `shipped_pack_test.dart` opens the built artefact from `build/` by hand;
the repository suites open `NativeDatabase.memory()`. The one code path that composes the installer with
the database — the production one, in `bootstrap_data.dart` — was the one path no test exercised,
because it is the seam the tests exist to replace.

## What this delivers

- `app/lib/data/bootstrap_data.dart` — the reference executor's locate callback now awaits
  `ReferenceInstaller(...).ensureInstalled()` and opens the file it returns. A `Failure` throws its
  exception rather than falling through to a path that does not exist, so the error the user sees names
  the extraction rather than SQLite's errno.
- `app/test/data/bootstrap_data_test.dart` — the composition asserted at the seam, with a fake bundle.
- `dataOverrides` gains an injectable `AssetBundleService`, defaulting to `RootBundleAssetService()`,
  for the same reason `directories` is already a port: the production wiring is the thing under test,
  so the only thing a test may replace is what crosses the platform boundary.

## Why it is built this way

**Inside the `LazyDatabase` callback, not before `runApp`.** `main.dart` is not `async` and nothing is
awaited before the first frame (`catchlaw-conventions-index` rule 8, rejected twice already in E06).
Extraction is ~6 s on a cold install; hoisting it to bootstrap would be a blank screen for six seconds
and a straight violation of that rule. The `LazyDatabase` callback is exactly the seam that defers it to
the first query — which is the first query the Check screen makes, behind the determinate bar E12 shows.

**A `Failure` throws.** `ensureInstalled()` is total, and the two arms are not interchangeable: an
`Ok(File)` is a path that exists, a `Failure` is a device with no writable support directory or a
corrupt payload. Returning the un-extracted path on the failing arm is what produced the errno the
simulator showed, and it names SQLite where the real fault is the asset.

## Tests first

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `dataOverrides extracts the reference pack before the first query` | fake bundle over the real shipped gz, empty temp dir | the asset is read once and `reference.db` exists after the query | The shipped defect, stated as an assertion |
| 2 | `dataOverrides awaits nothing before the first query` | build the overrides and stop | zero asset reads, no file on disk | Rule 8: ~6 s before `runApp` is a black screen on a dark boat |
| 3 | `dataOverrides reads no asset when the pack is already installed` | a second container over the same directory | zero asset reads | Re-extracting ~10 MB every launch is the other half of T03's ladder |
| 4 | `dataOverrides opens the user database in the same directory` | one query on `user.db` | the file exists | The two databases are opened by two independent callbacks; neither may take the other's path |

The bundle is served from `assets/db/reference.db.gz` as committed, so the sha256 and byte count
`ReferenceInstaller` verifies are the ones `kReferenceBuild` carries. A synthetic payload cannot clear
that check, and loosening the check to accept one would delete the assertion.

**Not asserted here:** that a failed extraction surfaces `ReferenceInstallFailure` rather than a SQLite
errno. It does, and that is the fix — but `LazyDatabase` retains the rejected open future and the
harness reports it as an unhandled async error whatever the caller catches. That is drift's behaviour,
not ours, and it is asserted one layer down in `reference_installer_test.dart`.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 4 tests pass, and each failed first.
- [ ] Nothing is awaited before `runApp`; `check_app_invariants.sh` check 8 is green.
- [ ] A cold install on a simulator reaches a cited verdict without touching the network.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
```
