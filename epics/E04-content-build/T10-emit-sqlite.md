# E04/T10 — Emit SQLite: schema, FTS5, determinism, sha256

| | |
|---|---|
| **Epic** | E04 — Content builder and the Galicia seed |
| **Branch** | `epic/04-content-build` (shared) |
| **Commit** | `feat(content_builder): emit reference.db deterministically with FTS5 and a sha256 sidecar` |
| **Depends on** | T03 (`content_string` rows), T07 (`*_norm` columns and the A7 phase) |
| **Size** | L |
| **Spec** | `SPEC.md` §7.1 (the whole schema), §7.4 (the build's separate asset), §13 (FTS < 200 ms, first launch < 6 s), §9.4 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-reference-database` | Rules 3, 4, 5 and 6 — the file is opened read-only and never migrated, replaced wholesale, gated by a sidecar plus a generated constant, and extracted through a sha256-verified temp file. This task produces the bytes all four rules assume |
| `catchlaw-content-pipeline` | Rule 1 and the emit half of "The tool is the deliverable" — a reproducible, diffable, explainable database |
| `catchlaw-rule-engine` | The `body_norm` column exists because FTS5's `unicode61` does not fold Arabic orthographic variants; the tokenizer choice follows from the normalisation contract |
| `catchlaw-conventions-index` | Rule 7 — three database files, and the shipped one is read-only |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.1 | The complete schema, verbatim: every table, every `CHECK`, every index, `WITHOUT ROWID` on `key_leaf_species` and `content_string`, and the `legal_text_fts` declaration |
| `SPEC.md` | §7.1, the `legal_text` comment | Why `body_norm` exists: FTS5 `unicode61` does **not** fold Arabic orthographic variants |
| `SPEC.md` | §7.4 | The build emits a tiny separate asset carrying `build_date` and `schema_version`, plus a generated Dart constant |
| `SPEC.md` | §13 | Legal-text FTS < 200 ms; first launch < 6 s for a ~10 MB copy plus the FTS index build |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | Rules 3–6; "The circular build-date check"; "Temp file, atomic rename, orphan sweep" | `kReferenceBuildId`, `kReferenceBytes`, `kReferenceSha256`, and that the sha256 is verified against the **decompressed** file |
| `.claude/skills/catchlaw-content-pipeline/examples/content_build_assertions.dart` | `main()` | Emit, then run A7 against the emitted bytes, then delete the file if parity fails |
| `epics/DECISIONS.md` | D-6, D-1 | The `.gz` asset at `app/assets/db/`, the sha256, the read-only open; and that extraction and the generated constant are E05/T01–T03 |
| `epics/CONVENTIONS.md` | §8 | The floor under this task, including the no-`print`-outside-`kDebugMode` rule — this is a CLI, so `stdout.writeln` is the correct channel and `print` is still not |

## What this delivers

- `tools/content_builder/lib/src/emit/schema.sql` — `SPEC.md` §7.1, verbatim, as an asset compiled
  into the package. One copy, checked against the spec by eye once, then never retyped.
- `tools/content_builder/lib/src/emit/emit_reference_db.dart` — the emitter.
- `tools/content_builder/lib/src/emit/build_sidecar.dart` — writes
  `app/assets/db/reference.build.json`.
- `app/assets/db/reference.db` — the emitted database (git-ignored; the `.gz` is what ships).
- `app/assets/db/reference.db.gz` — the shipping asset D-6 names.
- `app/assets/db/reference.build.json` — `{"build_id", "build_date", "schema_version", "bytes",
  "sha256"}`.
- `tools/content_builder/test/emit/emit_reference_db_test.dart`,
  `test/emit/determinism_test.dart`, `test/emit/fts_test.dart`.

## Why it is built this way

**The schema is `SPEC.md` §7.1 verbatim, in one file, and nothing generates it.** §7.1 is
authoritative and E05 will generate its drift tables from the same source. Two hand-maintained
copies of a schema disagree within a month, and the disagreement surfaces as a `no such column` on a
user's phone. **Rejected:** building the schema from the Dart row models, which reverses the
authority — the models exist to serve §7.1, not the other way round.

**`PRAGMA foreign_keys = ON`, and then `PRAGMA foreign_key_check` afterwards.** §7.1 opens with the
pragma. Enabling it during the build catches an ordering mistake at the insert that made it; running
`foreign_key_check` at the end catches the ones a deferred constraint let through. Both run; neither
is redundant. `PRAGMA integrity_check` runs last and must return exactly `ok`.

**FTS5 external content, `tokenize='unicode61 remove_diacritics 2'`, over `body_norm` and not over
`body`.** §7.1's own comment gives the reason: `unicode61` does not fold Arabic orthographic variants,
so the tokenizer alone cannot make `الهامور` and `هامور` meet. `remove_diacritics 2` handles the Latin
side — Galician and Catalan accents — and `body_norm`, written by T07 from the engine's fold, handles
the Arabic side. The `content='legal_text'` external-content form keeps the verbatim text stored once;
the index is populated with an explicit
`INSERT INTO legal_text_fts(rowid, body_norm) SELECT id, body_norm FROM legal_text` after the base
table is filled, because an external-content table does not populate itself.

**Byte-identical rebuild, and what that actually requires.** The emitter must be reproducible or the
sha256 in the sidecar is a number that changes for no reason and stops being evidence of anything.
Four things make it so, and each is a deliberate choice:

1. **No clock.** `content_meta.build_date` comes from `--build-date` and `generator_commit` from
   `--generator-commit`, both required by T01. `DateTime.now()` appears nowhere in the package.
2. **Explicit primary keys, assigned from sorted authored ids.** Letting SQLite assign rowids makes
   the file depend on insert order, and insert order depends on directory-walk order, which depends
   on the filesystem.
3. **Fixed page geometry**: `PRAGMA page_size = 4096`, `PRAGMA auto_vacuum = NONE`,
   `PRAGMA journal_mode = DELETE` so no `-wal` is left beside the file (which
   `catchlaw-reference-database` rule 3 warns breaks every later sha256 check).
4. **`VACUUM INTO` the final path.** The build happens in a temp file; the shipped file is written
   fresh by `VACUUM INTO`, so freelist churn and page fragmentation from the build cannot reach it.

The residual, stated honestly: byte-identity holds **for a fixed SQLite library version**. The header
records the writing library, and a page-layout change between releases would move bytes. So the test
compares **two builds inside one run** rather than a build against a checked-in golden hash, and the
epic's Risks records what a golden hash would require. **Rejected:** a checked-in expected sha256; it
would fail on the next `dart pub upgrade` for a reason unrelated to the content, and the fix would be
to delete the test.

**The sidecar carries the sha256 of the *uncompressed* file.** `catchlaw-reference-database` rule 6
verifies the digest after decompression, against `kReferenceSha256`, and drives the determinate
progress bar from `kReferenceBytes` — also the uncompressed count. A digest of the `.gz` would be
verified before the bytes that matter existed.

**The sidecar is `app/assets/db/reference.build.json`, beside the `.gz`.** `SPEC.md` §7.4 calls it
`assets/content_build.json`; `catchlaw-reference-database` rule 5 calls it
`assets/db/reference.build.json`. D-6 fixes the `.gz` at `app/assets/db/reference.db.gz`, so the
sidecar sits beside the file it describes. This is a consequence of D-6, not a new decision, and E05
reads whichever path it finds documented here.

**This task does not emit the generated Dart constant.** `catchlaw-reference-database` rule 5 wants
`kReferenceBuildId`, `kReferenceBytes` and `kReferenceSha256` in `app/lib/data/reference/`. D-6 says
extraction is applied by E05/T01–T03, and that is where the constant belongs: E05 owns the extraction
contract and generates the constant from this sidecar. Emitting Dart into `app/lib/` from E04 would
put two epics in one file. **Rejected**, and named in the epic's follow-ups so E05 does not go looking
for it.

**`reference.db` is git-ignored; `reference.db.gz` is committed.** The shipping artefact is the
compressed one (D-6 item 1), and committing both would double every content diff for no reader.

## Tests first

Write every row before touching `emit_reference_db.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `emitReferenceDb creates every table in §7.1` | a minimal corpus | `sqlite_master` lists all 22 tables plus `legal_text_fts` | A table the emitter forgot is a screen with no data in E15 |
| 2 | `emitReferenceDb creates every index in §7.1` (loop over the seven named indexes) | same | `$index` present | `idx_name_search` is what makes `< 50 ms at 2,400 names` possible; a missing index is a slow app, not a broken one, so nothing else catches it |
| 3 | `emitReferenceDb declares content_string and key_leaf_species WITHOUT ROWID` | same | both flagged in the schema | §7.1 says so, and the storage difference is real at 2,400 × 6 rows |
| 4 | `emitReferenceDb passes PRAGMA foreign_key_check with zero rows` | a full fixture corpus | empty result | A dangling foreign key is a crash on a phone with no debugger attached |
| 5 | `emitReferenceDb passes PRAGMA integrity_check` | same | `ok` | The cheapest possible proof the file is not truncated |
| 6 | `emitReferenceDb writes content_meta schema_version, build_date and generator_commit` | `--build-date 2026-08-14 --generator-commit 4f2c1ab` | three rows with those values | §7.1's comment names exactly these three |
| 7 | `emitReferenceDb writes the build date from the option and never from the clock` | build date in the past | that date, unchanged | Determinism, and the plate ratchet in T06 depends on the same value |
| 8 | `legal_text_fts is declared with unicode61 remove_diacritics 2` | emitted schema | the tokenize clause | The Latin half of the fold; §7.1 specifies the exact string |
| 9 | `legal_text_fts returns a row for a Galician query with accents removed` | body containing `veda`, query `vedá` | one row | `remove_diacritics 2` proved by behaviour, not by reading the DDL |
| 10 | `ar - legal_text_fts returns a row for a query normalised through the engine` | Arabic body, query folded by `normaliseSpeciesTerm` | one row | The Arabic half: `unicode61` cannot fold it, `body_norm` must |
| 11 | `legal_text_fts is populated for every legal_text row` | 5 rows | 5 indexed rows | An external-content FTS table does not populate itself, and an empty index fails silently |
| 12 | `emitReferenceDb produces byte-identical files from identical input` | the same corpus emitted twice | equal sha256 | The sidecar's digest must mean something |
| 13 | `emitReferenceDb assigns primary keys from sorted authored ids` | rows loaded in two different orders | identical `id` assignment | The mechanism behind case 12; a failure here explains a failure there |
| 14 | `emitReferenceDb leaves no -wal or -journal file beside the output` | after emit | only the `.db` | `catchlaw-reference-database` rule 3: a stray `-wal` breaks every later sha256 check |
| 15 | `buildSidecar records the sha256 and byte count of the uncompressed file` | emitted pair | sidecar matches the `.db`, not the `.gz` | Rule 6 verifies the digest **after** decompression |
| 16 | `emitReferenceDb writes nothing when the failure list is non-empty` | a corpus with one A1 failure | no `.db`, no `.gz`, no sidecar | Skill rule 2, at the point where bytes would actually be created |
| 17 | `emitReferenceDb deletes the output when A7 parity fails` | corrupted `*_norm` after emit | no `.db` left behind | The example's comment: an unindexed database is worse than none |
| 18 | `emitReferenceDb opens the emitted file read-only in the verification pass` | — | the verification connection is read-only | A writable verification open is how a `-wal` appears after the digest was taken |

```dart
// tools/content_builder/test/emit/determinism_test.dart
import 'dart:io';
import 'package:content_builder/src/emit/emit_reference_db.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('emitReferenceDb', () {
    test('produces byte-identical files from identical input', () async {
      final source = kGaliciaFixtureSource;
      final first = await emitReferenceDb(source, tempOut('a.db'), buildDate: kBuildDate);
      final second = await emitReferenceDb(source, tempOut('b.db'), buildDate: kBuildDate);

      expect(sha256OfFile(first), sha256OfFile(second));
    });

    test('leaves no -wal or -journal file beside the output', () async {
      final out = tempOut('c.db');
      await emitReferenceDb(kGaliciaFixtureSource, out, buildDate: kBuildDate);

      expect(
        Directory(out.parent.path).listSync().map((e) => e.path),
        everyElement(isNot(anyOf(endsWith('-wal'), endsWith('-journal')))),
      );
    });
  });
}
```

```dart
// tools/content_builder/test/emit/fts_test.dart
import 'package:content_builder/src/emit/emit_reference_db.dart';
import 'package:rule_engine/rule_engine.dart' show normaliseSpeciesTerm;
import 'package:test/test.dart';

void main() {
  group('legal_text_fts', () {
    test('is declared with unicode61 remove_diacritics 2', () async {
      final db = await emitAndOpenReadOnly(kGaliciaFixtureSource);

      expect(
        db.select("SELECT sql FROM sqlite_master WHERE name = 'legal_text_fts'").single['sql'],
        contains("tokenize='unicode61 remove_diacritics 2'"),
      );
    });

    test('ar - returns a row for a query normalised through the engine', () async {
      final db = await emitAndOpenReadOnly(kArabicLegalTextSource);
      final query = normaliseSpeciesTerm('الهامور');

      expect(
        db.select('SELECT rowid FROM legal_text_fts WHERE body_norm MATCH ?', [query]),
        hasLength(1),
      );
    });
  });
}
```

**Run:** `(cd tools/content_builder && dart test test/emit)` → every case red. If case 12 passes now,
`emitReferenceDb` is returning the same file twice — check the two output paths differ before
believing it.

## Implementation outline

1. `schema.sql` transcribed from `SPEC.md` §7.1 in one sitting, then diffed against the spec line by
   line as part of review. This is the one place in the epic where a transcription error is invisible
   to every test that does not name the column.
2. Open a temp database; set `page_size`, `auto_vacuum`, `journal_mode` **before** the first write —
   `page_size` cannot change after a page exists.
3. Execute `schema.sql` as one script, with `foreign_keys = ON`.
4. Assign integer primary keys per table from the authored ids, sorted, so the mapping is a pure
   function of the corpus.
5. Insert in dependency order — `jurisdiction`, `zone`, `zone_ring`, `family`, `species`,
   `species_name`, `measurement_method`, `citation`, `rule`, the rest — inside one transaction.
6. Populate `legal_text_fts` explicitly after `legal_text`.
7. `content_meta` last, from the CLI options.
8. `foreign_key_check`, then `integrity_check`, then `VACUUM INTO` the output path; close; the temp
   file is deleted.
9. Run T07's A7 parity against the emitted file, opened **read-only**. On failure, delete the output
   and exit 1.
10. Gzip to `reference.db.gz`; write the sidecar with the uncompressed digest and byte count.
11. Add `app/assets/db/reference.db` to `.gitignore`; commit the `.gz` and the sidecar.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 rows pass, and each failed first.
- [ ] `schema.sql` matches `SPEC.md` §7.1 table for table, `CHECK` for `CHECK`, index for index —
      reviewed against the spec, not against memory.
- [ ] Two builds of the Galicia corpus produce equal sha256, and the sidecar carries that digest, the
      uncompressed byte count and the build date.
- [ ] `PRAGMA foreign_key_check` returns zero rows and `PRAGMA integrity_check` returns `ok` on the
      shipped file.
- [ ] No `-wal`, `-shm` or `-journal` file exists beside `app/assets/db/reference.db` after a build.
- [ ] `grep -rn "DateTime.now" tools/content_builder` still returns nothing.
- [ ] `app/assets/db/reference.db` is git-ignored; `reference.db.gz` and `reference.build.json` are
      committed.
- [ ] **Recorded for E05:** the sidecar path is `app/assets/db/reference.build.json`, its digest is of
      the decompressed file, and the generated Dart constant is E05's to write (D-6).

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content_builder): emit reference.db deterministically with FTS5 and a sha256 sidecar

The schema is SPEC.md §7.1 verbatim in one file. E05 generates its drift
tables from the same source, and two hand-maintained copies of a schema
disagree within a month — the disagreement surfacing as `no such column` on
somebody's phone.

legal_text_fts indexes body_norm rather than body, with unicode61
remove_diacritics 2. §7.1's own comment gives the reason: unicode61 does not
fold Arabic orthographic variants, so the tokenizer alone cannot make الهامور
and هامور meet. remove_diacritics 2 covers the Galician and Catalan accents;
body_norm, written by T07 from the engine's fold, covers the rest. External
content does not populate itself, so the index is filled explicitly.

Byte-identity is bought with four things: no clock anywhere, primary keys
assigned from sorted authored ids, fixed page geometry with journal_mode
DELETE so no -wal is left beside the file, and VACUUM INTO for the final
write. It holds for a fixed SQLite version — the header records the writing
library — so the test compares two builds inside one run rather than against a
checked-in hash that would fail on the next pub upgrade for a reason unrelated
to the content.

The sidecar's digest and byte count are of the UNCOMPRESSED file, because that
is what the installer verifies after decompression and what drives the
determinate first-launch bar. The generated Dart constant belongs to E05/T01
per D-6 and is deliberately not written here.

Task: E04/T10
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
