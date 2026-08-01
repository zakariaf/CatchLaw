# E04 — Content builder and the Galicia seed

| | |
|---|---|
| **Branch** | `epic/04-content-build` |
| **After** | E03 merged |
| **Tasks** | 11 |
| **Spec** | `SPEC.md` §8 (in full, including "The public-domain test for plates — corrected" and "The content pipeline is a first-class deliverable"), §7.1, §9.2, §9.5, §15 step 3 |
| **Package** | `tools/content_builder/` (D-4), plus authored YAML under `content/` and the emitted asset under `app/assets/db/` |

## What this epic achieves

At the end of this epic a single command — `dart run content_builder:build --in content/ --out
app/assets/db/reference.db --build-date <date> --generator-commit <sha>` — turns hand-authored YAML
into a `reference.db` that carries the whole `SPEC.md` §7.1 schema, opens read-only, answers an FTS5
query over Galician and Spanish legal text, and is byte-identical when rebuilt from identical input.
Galicia (`ES-GA`) is seeded end to end: jurisdiction, zones, species, vernacular names in all six
locales, citations into the DOG, rule rows transcribed from the *Orde da Xunta de Galicia*, and the
verbatim legal text in the language the Xunta published it in.

Every one of the nine bullets under `SPEC.md` §8 "The content pipeline is a first-class deliverable"
is an assertion that **fails** the build. There is no warning tier, no `--force` and no
`--skip-assertions`: a non-empty failure list writes no database at all. That is the point of the
epic. `SPEC.md` §8 closes with *the code is a fortnight; the content is the moat* — this is the
machine that keeps the moat honest, and E22 pours the remaining jurisdictions through it unchanged.

## Where we are now

The branch is cut from a `main` that already carries:

- **E01** — the pub workspace of D-1: root `pubspec.yaml` listing `app`, `packages/rule_engine`,
  `tools/content_builder` and `packages/analysis_defaults` as members, the root
  `analysis_options.yaml`, and the §14 static gates in CI.
- **E02** — `packages/rule_engine/lib/src/search/normalise.dart`, the single ordered fold of
  `SPEC.md` §9.4, exported through `package:rule_engine/rule_engine.dart`. E02/T08 is the other half
  of the contract this epic's T07 completes: one function, two callers.
- **E03** — the `SPEC.md` §7.3 resolution algorithm, expiry tagging, the specificity ladder, the
  ambiguity contract and the sealed `Resolution` family, all pure Dart with no Flutter import.

What does **not** exist: `tools/content_builder/` beyond whatever empty member E01 registered in the
workspace, any authored YAML, any `reference.db`, and any asset under `app/assets/db/`. E05 cannot
start until this epic emits the file it extracts, and E22 cannot start until this epic publishes the
authoring format it fills.

## Why this epic exists here in the order

`SPEC.md` §15 step 3 puts the content schema and build tool immediately after the shared pure-Dart
core, and says why in one line: *Imports the §2 package so data is validated by the code that will
read it.* That is a hard dependency, not a preference. T07 imports the normaliser from
`packages/rule_engine/` and T08 imports the resolver from the same place; neither can be written
before E02 and E03 have shipped them, and writing a second copy in the builder is the specific defect
`SPEC.md` §8 bullet 7 exists to forbid.

It cannot come later either. E05 extracts and opens `reference.db`; E06's `content_string` resolver
reads rows this build writes; E08 searches the `search_norm` column this build populates. Every epic
from E05 onward consumes the artefact this one produces.

`SPEC.md` §15 step 19 says content authoring *runs in parallel from step 3 onward and is the long
pole*. E22's branch is cut the moment this one merges, which is why the authoring format is the
deliverable here and not just the tool.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | The CLI, and the authoring YAML schema | `T01-cli-and-yaml-schema.md` | M | — |
| T02 | Row validation: the build errors | `T02-row-validation.md` | M | T01 |
| T03 | Every key resolves, in every shipped locale | `T03-locale-key-coverage.md` | M | T01 |
| T04 | Gender is non-NULL in every gendered locale | `T04-gender-coverage.md` | S | T03 |
| T05 | Citations, silhouettes and one name per locale | `T05-citations-and-assets.md` | M | T02 |
| T06 | The plate test: illustrator, death year, eighty years | `T06-plate-licence-test.md` | M | T02 |
| T07 | Normalisation comes from the engine, never a copy | `T07-normalisation-parity.md` | M | T01 |
| T08 | Run the engine over the authored data | `T08-engine-over-data.md` | L | T05 |
| T09 | The per-jurisdiction diff into `content_change` | `T09-content-change-diff.md` | M | T02 |
| T10 | Emit SQLite: schema, FTS5, determinism, sha256 | `T10-emit-sqlite.md` | L | T03, T07 |
| T11 | The Galicia seed and the end-to-end build | `T11-galicia-seed.md` | L | T02–T10 |

The assertion ids `A1`–`A10` are the stable ones from
`.claude/skills/catchlaw-content-pipeline/references/build-assertions.md`. This epic lands them in
this order: A1 (T02), A2 (T03), A3 (T04), A4/A5/A9 (T05), A6 (T06), A7 (T07), A8 (T08), A10 (T09).
T01 lands the registry they plug into; T10 lands the emitter; T11 lands the data.

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once all eleven have landed:

- [ ] All 11 tasks committed, one commit each, every `Task: E04/Tnn` trailer present.
- [ ] `dart run content_builder:build --in content/ --out app/assets/db/reference.db --build-date
      <date> --generator-commit <sha>` exits 0 on the Galicia seed and writes
      `app/assets/db/reference.db`, `app/assets/db/reference.db.gz` and
      `app/assets/db/reference.build.json`.
- [ ] Ten assertions exist, all ten are fatal, and a fabricated failure of each one exits 1 and leaves
      **no** `.db` behind. No `--force`, `--skip-assertions` or `--allow-missing-locale` exists, and
      passing one of those three names exits 2 with an explanation.
- [ ] `(cd tools/content_builder && dart test)` green, with **100 % branch coverage on
      `lib/src/assert/`** — an unexercised branch in an assertion is an assertion that does not exist.
- [ ] Two consecutive builds from identical input produce byte-identical `reference.db` files
      (identical sha256), and `app/assets/db/reference.build.json` records that sha256, the
      uncompressed byte count and the build date.
- [ ] The emitted database passes `PRAGMA foreign_key_check` (zero rows) and `PRAGMA integrity_check`
      (`ok`), and `legal_text_fts` is declared `tokenize='unicode61 remove_diacritics 2'` and returns
      rows for a Galician query.
- [ ] `content/es-ga/` is complete: every `*_key` resolves in `ar`, `en`, `es`, `gl`, `ca` and
      `pt_BR` (D-3); every `species_name` row in a gendered locale carries a non-NULL `gender`; every
      citation resolves and carries `retrieved_on`; every rule's species has a silhouette.
- [ ] `content/CHANGELOG/es-ga.md` and `content/es-ga/snapshot.json` are committed and current — the
      same command with `--check` exits 1 when they are stale.
- [ ] `packages/rule_engine/` still holds no user-visible sentence in any language (D-7), and
      `tools/content_builder/lib/` declares no normalisation function of its own.
- [ ] `.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder`
      and `… content` both clean.
- [ ] `.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib` still
      clean — this epic must not have pushed anything into the engine to make the builder's life easier.
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin`; branch deleted.

## Risks and the things that will bite

**Byte-identical rebuild is only defined against a pinned SQLite.** The emitted file's header carries
the writing library's version, and page layout can move between SQLite releases. T10's determinism
test therefore compares **two builds inside one run**, not a build against a checked-in hash, and the
build records `content_meta.generator_commit` so a stale `.db` can be traced. If a checked-in golden
hash is ever wanted, the `sqlite3` package version must be pinned in the root `pubspec.lock` first and
the hash regenerated on every bump. Naming this now stops somebody adding a golden-hash test that
fails on the next `dart pub upgrade`.

**`SPEC.md` §8 bullet 5 taken literally makes the Galicia seed unshippable.** It requires every rule's
species to carry at least one vernacular name *per locale* — including `ar` for *Venerupis
corrugata*. No Galician instrument names a clam in Arabic, and `SPEC.md` §9.2 step 3 is explicit that
*a wrong vernacular name is worse than no name*. T05 refines the assertion exactly once: a species may
carry, per locale, an authored `no_vernacular:` declaration with a reason key, which satisfies A5 and
lets `SPEC.md` §9.2's fallback chain run down to the scientific name. A silent gap still fails. This
is the one place E04 does not implement a §8 bullet to the letter; what would resolve it is a §8
amendment, which is outside this epic.

**`SPEC.md` §7.1 has no `species_alias` table, and §9.4 step 5 needs two search keys per Arabic
name.** T07 satisfies both by emitting a second `species_name` row carrying the same display `name`
with `is_primary = 0` and the article-stripped `search_norm`. The consequence lands on E08: a name
list must select `DISTINCT name`, or an Arabic species will appear twice. It is written down in T07's
definition of done so E08 inherits it rather than discovers it.

**`check_content_pipeline.sh` check 5 only recognises `TL`, `FL`, `CW` and `SHL`.** `SPEC.md` §7.1
declares nine measurement codes, and Galicia needs `CL` for *Maja* and `CW` for *Necora*. A row using
a code outside the gate's four trips a heuristic grep that has no escape hatch on that check, because
checks 2, 3 and 5 do not honour `content-pipeline-ok`. The mitigation is structural and is specified
in T01: negative and out-of-range fixtures live as **inline YAML strings in Dart**, never as `.yaml`
files inside a scanned tree. Real content that legitimately uses `CL`, `SL`, `ML`, `DW` or `CUSTOM`
still trips the gate; T02 records this as a gap per `CONVENTIONS.md` §4 — the build tool validates
against the full §7.1 list and is authoritative, and widening the gate's regex is a skill edit that
belongs with the other skill corrections, not here.

**Three names for one shared function — settled by D-14.** `SPEC.md` §8 says "the shared package";
`catchlaw-content-pipeline` says `package:catchlaw_shared/text/normalise.dart`;
`check_content_pipeline.sh` exempts `packages/shared/`. D-1's workspace has no such member — the
normaliser lives in `packages/rule_engine/`, put there by E02 and named by `catchlaw-rule-engine`
rule 10. The builder imports from `package:rule_engine/rule_engine.dart`, and because that path is
outside the gate's `SHARED_RE`, gate check 4 is **not** what proves the parity — T07's A7 pass is.
Nobody should read a green gate as proof here.

**`retrieved_on` and `build_date` are authored, never read from the clock.** Determinism forbids
`DateTime.now()` in the emitter, and
`.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` forbids it in a citation
for a different reason: the footnote claims a human opened the gazette that day. Both land as required
CLI input or required YAML fields. The cost is that a build with no `--build-date` exits 2 rather than
guessing, which will surprise somebody once.

**The Galicia numbers in this epic are placeholders until the DOG is transcribed.** `SPEC.md` §8 sizes
a jurisdiction at roughly 100–150 rule rows; the only Galician row with a value published anywhere in
this repository is *Venerupis corrugata*, 38 mm shell length. No task file invents a minimum size.
T11 states the transcription source and the assertions the transcription must satisfy; the values come
from the instrument, and a value nobody has read out of the DOG is a defect, not a placeholder.

## PR description

### What changed

`tools/content_builder/` now exists as a tested pub-workspace member with a typed CLI, an authoring
YAML schema under `content/`, ten fatal build assertions, a deterministic SQLite emitter and the
Galicia seed. `dart run content_builder:build` compiles `content/` into
`app/assets/db/reference.db`, its gzipped shipping copy and a build sidecar carrying the sha256 that
E05 verifies after extraction (D-6).

### Why

`SPEC.md` §8 calls the content pipeline a first-class deliverable and lists nine properties the build
must guarantee. Each is now an assertion that fails the build rather than warns, because a build that
warns is a build somebody ships. The build imports the normaliser from `packages/rule_engine/` and
runs the shipped resolver over the authored rows, so the data is validated by the code that will
interpret it — `SPEC.md` §15 step 3.

### How it was verified

- `(cd tools/content_builder && dart test)` — every assertion has a red-first failing case and a
  passing case; 100 % branch coverage on `lib/src/assert/`.
- Ten fabricated bad-input builds, one per assertion, each exiting 1 with no `.db` written.
- Two consecutive builds of `content/` producing identical sha256.
- `PRAGMA foreign_key_check` and `PRAGMA integrity_check` on the emitted file.
- `check_content_pipeline.sh` over `tools/content_builder` and over `content`.

### Product invariants touched

None weakened. Invariant 1 (no network) — the builder reads the filesystem only; the gazette PDFs are
fetched by a human and recorded by sha256, never by the tool. Invariant 3 (every result carries a
citation) — A4 makes an uncited rule row unshippable. Invariant 5 (an expired ruleset is still
evaluated) — T08 runs the engine over the authored grid and explicitly does **not** treat
`isExpired` as a failure; an expired Galician *orde de vedas* is a normal, shippable row.

### Follow-ups deliberately not in this PR

- Extraction, the generated Dart constant and the first-launch budget — D-6, E05/T01–T03.
- The remaining jurisdictions, native-speaker review and plate clearance — E22.
- `ATTRIBUTIONS.md` assembly and S17 rendering — E18. T06 emits the generated plate section only.
- Widening `check_content_pipeline.sh` check 5 to the full `SPEC.md` §7.1 measurement-code list.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start the next epic. E22's branch
is cut from `main` immediately after this merge and runs alongside E05 onward.
