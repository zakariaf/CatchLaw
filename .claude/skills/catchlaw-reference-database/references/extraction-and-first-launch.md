# Extraction and First Launch

The build-time payload, the non-circular installation gate, the temp-plus-atomic-rename write, the
orphan sweep, the determinate progress budget, and what happens when each step fails.

## What the content tool emits

Four artefacts, produced together, versioned together, never edited by hand.

| Artefact | Size | Purpose |
|---|---|---|
| `assets/db/reference.db.gz` | ~11 MB gz / 41 MB raw | the payload |
| `assets/db/reference.build.json` | ~180 B | readable WITHOUT decompressing anything |
| `lib/data/reference/reference_build.g.dart` | ~6 lines | what THIS binary expects |
| `reference.schema.json` (repo only) | — | schema dump for the content tool's own tests |

`reference.build.json`:

```json
{ "buildId": "2026.07.14+3", "bytes": 41582592,
  "sha256": "b7c1…", "contentVersion": "2026.07.14+3",
  "checkedAt": "2026-07-14", "zones": 214, "species": 3180 }
```

`reference_build.g.dart`:

```dart
const kReferenceBuildId = '2026.07.14+3';
const kReferenceBytes   = 41582592;
const kReferenceSha256  = 'b7c1…';
```

**Both exist on purpose.** The Dart constant is what the gate compares (zero I/O, cannot drift from
the binary). The JSON sidecar is what the installer reads for the byte count that drives the
determinate bar and for the counts shown on the "About the rule book" screen — none of which should
require opening 41 MB of SQLite. Adding a field is a sidecar change; adding a field the GATE depends
on is a `reference_build.g.dart` change.

## The circular check, stated plainly

The tempting gate is "open the shipped DB, read `content_meta.build_id`, compare". It cannot work:

1. `reference.db.gz` is an asset, not a file. `sqlite3_open` cannot address it.
2. To read one row you must decompress 41 MB to disk — the whole job.
3. So the check costs exactly what it was meant to avoid, on EVERY launch.

The gate is therefore a stamp on disk versus a constant in the binary:

```
INSTALLED file exists AND reference.db exists AND INSTALLED == kReferenceBuildId
    -> return reference.db          (~2 ms, two stat calls and a 20-byte read)
otherwise
    -> extract                       (first launch, or a build whose payload moved)
```

`content_meta` still exists inside the DB and is still authoritative for display — it is simply never
part of the decision to extract.

## The write sequence

Order matters at every step. Each line below is a state that survives a kill.

| # | Step | State if killed here |
|---|---|---|
| 1 | `dir.create(recursive: true)` | empty dir; harmless |
| 2 | sweep `*.tmp` in `dir` | leftovers from an earlier kill are gone |
| 3 | delete `INSTALLED` | gate reads "not installed" — correct, because we are about to overwrite |
| 4 | stream gunzip → `reference.db.tmp` | a `.tmp` orphan; swept at step 2 next launch |
| 5 | `sink.flush()` then `sink.close()` | bytes are durable |
| 6 | verify sha256 and length vs the sidecar | mismatch → delete `.tmp`, fail loudly |
| 7 | `tmp.rename(db.path)` | **atomic** — either the old file or the new one, never half |
| 8 | write `INSTALLED` = `kReferenceBuildId`, `flush: true` | missing stamp → re-extract next launch |

Step 3 before step 4 is the subtle one. If the stamp survived a failed extraction, a kill between 7
and 8 would be indistinguishable from success — you would trust a file you never verified.

Step 8 after step 7 is the other one. The stamp is a claim about the file at `db.path`; writing it
first makes it a claim about a file that does not exist yet.

`File.rename` within the same directory is atomic on both APFS and ext4/f2fs. Never rename ACROSS
filesystems (e.g. from a temp dir) — that degrades to copy-then-delete and loses atomicity.

## Progress and the budget

| Phase | Budget | Surface |
|---|---|---|
| cold start, already installed | **under 1.2 s** to interactive | no progress UI at all |
| first launch, extraction | **under 6 s** on the low-end reference device | determinate bar |
| content update after app update | under 6 s, same path | determinate bar |

The extraction budget is explicitly CARVED OUT of the interactive target — they are different
promises and must be measured separately. Regressing 1.2 s → 3 s is a defect even if extraction
stayed at 5 s.

Progress rules:

- Denominator is `kReferenceBytes` from the sidecar, never a guess and never a percentage of chunks.
- Report at most every 64 KiB, and coalesce to at most one setState per frame.
- Copy is a statement: `Preparing the rule book · 62 %`. Never `Loading…`, `Downloading…`,
  `Syncing…`, `Connecting…` — three of those imply a network this app does not have.
- No `CircularProgressIndicator`, no indeterminate `LinearProgressIndicator`.
- The bar screen carries the disclaimer and is not dismissable; it has no Cancel.
- Reference device for the budget: Android 11, 4 GB RAM, eMMC — not a flagship, not an emulator.

## Failure ladder

| Failure | Detection | Response |
|---|---|---|
| asset missing from the bundle | `rootBundle.load` throws | `ReferenceAssetMissingFailure` — unrecoverable, blocking screen, states the build id |
| gunzip error mid-stream | `FormatException` | delete `.tmp`, retry ONCE, then `ReferencePayloadCorruptFailure` |
| sha256 or length mismatch | step 6 | delete `.tmp`, retry ONCE, then `ReferencePayloadCorruptFailure` |
| disk full | `FileSystemException` errno 28 | `ReferenceNoSpaceFailure(needed: kReferenceBytes)` — states the megabytes required |
| rename fails | `FileSystemException` | leave the old `reference.db` intact; the previous pack keeps working |
| killed mid-extraction | `.tmp` present next launch | swept at step 2, extraction restarts from zero |
| stamp present, DB missing | gate check | extract |
| DB present, stamp missing | gate check | extract (cheaper than proving the file is right) |

A failed UPDATE never degrades the installed pack: the old `reference.db` is only ever replaced by a
verified file at step 7. An expired-but-installed pack is still evaluated and shown behind the ochre
stale bar — a stale rule beats no rule at sea. That bar is owned by `lonja-verdict-and-status`.

## Verifying by hand

```bash
# Byte count and hash that must match reference.build.json and reference_build.g.dart.
gzip -dc assets/db/reference.db.gz | wc -c
gzip -dc assets/db/reference.db.gz | shasum -a 256

# What the shipped pack claims about itself (repo copy only — never do this at run time).
sqlite3 build/reference.db 'SELECT build_id, checked_at FROM content_meta;'

# Cold-start and first-launch timings, measured separately.
flutter run --profile --trace-startup
adb shell run-as com.catchlaw.app ls -l files/reference/
```

If `wc -c` disagrees with `kReferenceBytes`, the progress bar is calibrated against a payload that is
not the one shipping — the bar will finish at 94 % or run past 100 %, and every review will read it
as "extraction is slow" rather than "the constants are stale".
