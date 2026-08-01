## What changed

`tools/content_builder/` is now a tested pub-workspace member with a typed CLI, an authoring YAML
schema under `content/`, **ten fatal build assertions**, a deterministic SQLite emitter and Galicia's
structural seed. `dart run content_builder:build --in content/ --out app/assets/db/reference.db
--build-date <date> --generator-commit <sha>` exits 0 and writes `reference.db`, its gzipped shipping
copy and a build sidecar carrying the sha256 E05 verifies after extraction (D-6).

## Why

`SPEC.md` §8 calls the content pipeline a first-class deliverable and lists nine properties the build
must guarantee. Each is now an assertion that **fails** the build rather than warning, because a build
that warns is a build somebody ships. There is no `--force`, no `--skip-assertions` and no
`--allow-missing-locale`; passing one of those three names exits 2 with an explanation, because the
flag that exists is the flag CI uses at 18:00 on a Friday.

The build imports the normaliser from `packages/rule_engine/` and runs the **shipped** resolver over
the authored grid, so the data is validated by the code that will interpret it — `SPEC.md` §15 step 3.

## How it was verified

- `(cd tools/content_builder && dart test)` — 342 tests. **100 % branch coverage on
  `lib/src/assert/`**, measured by aggregating the per-isolate coverage JSON, because `format_coverage
  --lcov` emits no branch records at all.
- The build over `content/` exits 0; `PRAGMA foreign_key_check` returns no rows and `PRAGMA
  integrity_check` returns `ok`.
- Two consecutive builds produce byte-identical files with the same sha256.
- `--check` over the committed `snapshot.json` and changelog exits 0.
- `check_content_pipeline.sh` over `tools/content_builder` **and** over `content`.

## Product invariants touched

None weakened.

- **1, no network** — the builder reads the filesystem only. The gazette is fetched by a human and
  recorded by sha256, never by the tool.
- **3, every result carries a citation** — A4 makes an uncited rule row unshippable, on all six §7.1
  tables that carry a `citation_id`.
- **5, an expired ruleset is still evaluated** — `isExpired` appears nowhere in A8. A build that
  failed on a lapsed *orde de vedas* would do the damage §7.3 describes a year earlier and more
  permanently, by making the corpus unshippable until somebody deleted the rows.

## The thing this PR does not do, and why

**Galicia's rule rows are not authored.** The machine is finished; the moat is not. A rule row needs
four things only a human reading the *Orde da Xunta do 27 de xullo de 2012* can supply: the minimum
size and its measurement method, a `published_on` and a `retrieved_on` that claims a person opened the
gazette that day, a `sha256` of the fetched document, and the verbatim article text.

Writing a plausible-looking digest would be **precisely** the defect A9 exists to catch, committed by
the assertion's own author. E04's own risk note settles the rest: *a value nobody has read out of the
DOG is a defect, not a placeholder.* Recorded as **G-4** in `content/README.md` with the exact list of
what lands when the transcription is done.

`app/assets/sil/venerupis-corrugata.svg` is absent for the same reason — A5 requires a silhouette on
disk for every species a rule reaches, and originated line art is commissioned, not generated.

## Decisions and gaps recorded rather than settled quietly

- **G-1 / G-2** — `check_content_pipeline.sh` check 5 knows four measurement codes where §7.1 declares
  nine, **and** its regex cannot match this corpus's column names at all. Two of the gate's seven
  checks were inert; A1 covers check 5's ground, and the citation block was shaped so check 2 fires.
- **G-3** — `citations.yaml` deliberately unauthored; the block shape is documented.
- **G-4** — the transcription gap above.
- The gate table now runs `check_content_pipeline.sh` against **both** its documented targets. It ran
  against only `tools/content_builder`, so CI never scanned the authored corpus; the row for `content`
  would have been an empty scan before T03 authored the first `strings.yaml`, which is why it lands
  here.

## Follow-ups deliberately not in this PR

- Extraction, the generated Dart constant and the first-launch budget — D-6, E05/T01–T03.
- The DOG transcription, native-speaker review and plate clearance — E22.
- `ATTRIBUTIONS.md` assembly and S17 rendering — E18. This PR emits the generated plate section only.
- Widening `check_content_pipeline.sh` check 5 to the full §7.1 measurement-code list.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
