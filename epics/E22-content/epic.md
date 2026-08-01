# E22 — Content authoring at scale

| | |
|---|---|
| **Branch** | `epic/22-content` (a series, not one PR — see "The epic loop") |
| **After** | E04 merged, then **in parallel with every other epic** |
| **Tasks** | 9 |
| **Spec** | `SPEC.md` §8 in full (every licence row and its verification status, "The public-domain test for plates — corrected", and the authoring-volume paragraph), §9.1, §9.2, §9.6, §16 R1, §7.1, §4.4, §15 step 19 |
| **Package** | `content/` (authored), `app/assets/sil/` and `app/assets/plate/` (originated art), `tools/content_builder/` (five new assertions and one audit CLI) |

## What this epic achieves

When this epic is complete, the app has content for every jurisdiction it claims: Gulf, Iberia and
Brazil, each with its rule rows, its verbatim legal text in the language the authority published it
in, its citations into the official gazette, and its zone polygons where coordinates exist. Roughly
400 species carry a silhouette and vernacular names in `ar`, `en`, `es`, `gl`, `ca` and `pt_BR`
(D-3) — about 2,400 names — every one of them either lifted from the legal instrument or, for
English alone, taken from the Catalogue of Life vernacular extension. Every locale has been read by
one native-speaking fisher or fisheries officer who was asked to disconfirm it. Every plate names an
illustrator and a death year, or it is not in the bundle.

None of that is code. `SPEC.md` §8 says the size of it plainly: 100–150 rule rows per jurisdiction —
the UAE decisions alone carry 100+ — ~400 species, ~2,400 vernacular names, ~400 silhouettes, and
the verbatim legal text. Several weeks of careful, checkable work. *The code is a fortnight; the
content is the moat, and it is why nobody has built this.* This epic's job is to make that work
checkable, not to make it smaller.

The code this epic does write is the machinery that keeps the authoring honest: five new build
assertions (A11–A15), an OCR-yield audit CLI, and one corpus test per jurisdiction slice that fails
before the content exists.

## Where we are now

The branch series is cut from the `main` that E04 merged into. It carries:

- **E04** — `tools/content_builder/`, the typed CLI `dart run content_builder:build --in content/
  --out app/assets/db/reference.db --build-date <date> --generator-commit <sha>`, ten fatal
  assertions A1–A10, the deterministic SQLite emitter, `content/README.md` documenting the authoring
  format, and the **Galicia seed** at `content/es-ga/`. Also `content/ATTRIBUTIONS/plates.md`,
  generated from `content/shared/plates.yaml` on every build, and
  `app/assets/db/reference.db.gz` + `reference.build.json`.
- **E02/E03** — `packages/rule_engine/`: the §9.4 ordered fold and the §7.3 resolver, both imported
  by the builder rather than copied (A7, A8).
- **E01** — the D-1 workspace and the §14 static gates.

What does **not** exist: any jurisdiction other than `ES-GA`; any Gulf or Brazilian directory under
`content/`; ~400 silhouettes (`app/assets/sil/` holds only what the Galicia seed needed); any cleared
plate at all — E04/T06's definition of done states the seed ships with zero, and every
`species.plate_asset` NULL; any reviewer sign-off; and any zone ring outside Galicia.

Concurrently, E05 through E21 are being built on the same `main`. They touch `app/lib/`,
`app/test/` and `packages/`. This epic touches `content/`, `app/assets/`, and
`tools/content_builder/`. The one shared artefact is `app/assets/db/reference.db.gz`, and that is
handled in Risks.

## Why this epic exists here in the order

It does not sit in the order. `SPEC.md` §15 step 19 puts content authoring in parallel *from step 3
onward* and calls it the long pole; `epics/README.md` publishes the same exception. Its only hard
dependency is step 3 — the schema and the build tool — because a jurisdiction authored against no
schema is a jurisdiction that will be re-authored. Everything else it needs is a human with a gazette
PDF and a reviewer with a boat.

It cannot wait until the app is finished. §8's volume estimate is weeks, the R1 test in T02 is the
riskiest assumption in the project (§16), and finding out in E21 that the Gulf gazettes cannot be
transcribed would leave no time to spend the transcriber budget line §8 already carries. **The app
does not ship until Arabic rule rows exist** (§16 R1) — so the test that decides how they are
obtained runs first, on day one of this epic.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | The authoring guide and the reviewer protocol | `T01-authoring-guide-and-reviewer-protocol.md` | L | — |
| T02 | The Gulf gazette test — R1 | `T02-gulf-gazette-test-r1.md` | L | T01 |
| T03 | Gulf rule rows and verbatim text | `T03-gulf-rule-rows-and-verbatim-text.md` | L | T01, T02 |
| T04 | Iberia: the remaining orders, in `es` and `ca` | `T04-iberia-remaining-orders.md` | L | T01 |
| T05 | Brazil: federal and per state | `T05-brazil-federal-and-per-state.md` | L | T01, T03 |
| T06 | Vernacular names in six locales, and native review | `T06-vernacular-names-and-native-review.md` | L | T01, T03, T04, T05 |
| T07 | Four hundred silhouettes | `T07-four-hundred-silhouettes.md` | L | T01 |
| T08 | Plate clearance, one image at a time | `T08-plate-clearance.md` | M | T03–T05, T07 |
| T09 | Zone polygons, and where Natural Earth substitutes | `T09-zone-polygons-and-natural-earth.md` | M | T04, T05 |

New build assertions, continuing E04's stable ids:

| Id | Assertion | Landed by |
|---|---|---|
| A11 | Every shipped locale in every jurisdiction carries a current reviewer sign-off | T01 |
| A12 | `legal_text` locales equal `jurisdiction.legal_text_locales`, and both are subsets of the six | T04 |
| A13 | Vernacular provenance follows the §9.2 sourcing order; English is CoL-only and authored last | T06 |
| A14 | Every silhouette is stroke-only originated SVG within the shape and size budget | T07 |
| A15 | Every zone polygon names a permitted `geometry_source`; no jurisdiction invents boundaries | T09 |

T02 adds no assertion — it adds a second executable, `dart run content_builder:ocr_audit`, which
never runs in the build path. T03, T05 and T08 extend A9 and A6 with data and coverage rules rather
than new ids, and each says so in its own file.

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once all nine have landed:

- [ ] All 9 tasks committed, one commit each, every `Task: E22/Tnn` trailer present, each on its own
      PR merged `--squash --admin`.
- [ ] `dart run content_builder:build --in content/ --out app/assets/db/reference.db --build-date
      <date> --generator-commit <sha>` exits 0 over the **whole** corpus, not one jurisdiction.
- [ ] Every jurisdiction directory under `content/` carries `jurisdiction.yaml`, `citations.yaml`,
      `rules.yaml`, `legal_text.yaml`, `changes.yaml`, `snapshot.json`, and a
      `content/CHANGELOG/<code>.md` that is current under `--check`.
- [ ] No jurisdiction ships whose licence basis is unverified: every `accepted_hosts.dart` entry that
      any citation references carries `verified: true` **and** the quoted exclusion provision (T03).
- [ ] Arabic rule rows exist. §16 R1's mitigation is recorded in `content/ae/R1-GAZETTE-TEST.md` with
      its measured yield, and if the test failed, the transcriber engagement is recorded there and the
      rows it produced are in `content/ae-rk/rules.yaml`.
- [ ] `content/reviewers.yaml` carries a sign-off for all six locales covering the current corpus
      hash, and A11 fails when it does not.
- [ ] ~400 species carry a silhouette under `app/assets/sil/`; total under **6 MB** (`SPEC.md` §8),
      and A14 is clean.
- [ ] Every plate in `content/shared/plates.yaml` names an illustrator and a death year; for a 2026
      build the illustrator died in 1945 or earlier; `content/ATTRIBUTIONS/plates.md` regenerates with
      no diff; no block carries `unknown`, `unidentified` or `TBD`.
- [ ] Every protected species and both members of each look-alike pair resolve to a cleared plate
      (`lonja-icons-and-plates` rule 7).
- [ ] `jurisdiction.has_zone_polygons = 0` for every Gulf jurisdiction, with zero `zone_ring` rows
      and every Gulf rule's `zone_id` NULL (§4.4, §8).
- [ ] `(cd tools/content_builder && dart test)` green, 100 % branch coverage on `lib/src/assert/`.
- [ ] `check_content_pipeline.sh tools/content_builder` and `check_content_pipeline.sh content` both
      clean, with every `content-pipeline-ok` exemption in the tree individually justified in the
      commit that added it.
- [ ] `packages/rule_engine/` still holds no user-visible sentence in any language (D-7) — this epic
      writes thousands of sentences and none of them lands there.
- [ ] Every PR's checks all SUCCESS; every PR merged `--squash --admin`; every branch deleted.

## Risks and the things that will bite

**R1 is the project's biggest risk and T02 is its one-day test.** `SPEC.md` §16 R1: neither candidate
PDF could be text-extracted during research. The test is `ocrmypdf` + Tesseract `ara` over the
**official gazette or ministry** PDFs — never FAOLEX abstracts, never an FAO-commissioned
translation, which is an FAO work under FAO terms (§8, and `licence-provenance.md` "Sourcing"). Pass
is **≥ 80 species rows with a numeric minimum length transcribed with confidence in a day, twenty of
them cross-checked against a second published source.** If it fails, the mitigation does **not**
remove Arabic: §8 already carries a named budget line for a paid Arabic-speaking transcriber working
from the official gazette, and §16 R1 states that the app does not ship until Arabic rule rows exist.
What resolves the risk either way is T02's recorded yield; what does not resolve it is deferring the
Gulf to a later release.

**The Gulf licence basis is cited but not independently verified.** `SPEC.md` §8 marks UAE Federal
Decree-Law No. 38 of 2021, Art. 3 as *"cited but not independently verified in this session"* and
requires an equivalent provision quoted **for each additional Gulf state before that state's content
ships**. E04/T05 already encodes this as a `verified: true|false` flag that fails A9 for every
citation in an unverified jurisdiction. T03 adds the quoted provision itself. A state whose provision
nobody has quoted stays out of the bundle; that is the design, not a blocker to route around.

**Brazil's zone polygons are unresolved and Brazil's graphic annexes are not covered.** IBGE malha
territorial and ANA Base Hidrográfica are **not** covered by Lei 9.610 art. 8 — they are cartographic
products, not annexes to a portaria — and each would need clearing under its own reuse terms.
**Natural Earth (public domain, no attribution required) is the safe default** for admin boundaries
(§8), and T09 makes `ibge` and `ana` rejected `geometry_source` values by name until cleared.
Separately, art. 8 IV covers *os textos* only, so every measurement diagram and species drawing for a
Brazilian rule is originated in-house (T05). What would resolve the polygon question is a written
clearance from IBGE or ANA; until then Natural Earth ships.

**Gulf zone polygons do not exist as published coordinates at all.** §8: emirate maritime boundaries
are not published as coordinate polygons in MD 580/2015 or its successors. §4.4 and §8 agree on the
answer — `has_zone_polygons = 0`, rules apply jurisdiction-wide, the zone picker hides the sub-zone
level. **We do not invent boundaries.** T09 makes that a build assertion so nobody "improves" it with
a traced coastline.

**A wrong vernacular name is worse than no name.** §9.2 step 3, verbatim, and the reason is that it
produces a confident wrong finding. The defence is one native-speaking fisher or fisheries officer
per locale, before release, and T01's A11 makes an unreviewed locale unshippable. The residual risk
is a reviewer who agrees with everything; T01's protocol therefore asks reviewers to **disconfirm**,
in the shape §17 step 5 uses for the validation interviews.

**~400 originated silhouettes is not an engineering task and cannot be estimated like one.** T07
lands the ledger, the shape assertion, the family batching and the budget; the drawings themselves
arrive per family. What would resolve the schedule risk is a commissioned artist with a per-family
delivery cadence; what will not is treating a missing drawing as a soft failure — A5 already makes it
a build error.

**Bundled SVG versus generated const Dart is a genuine seam between two authorities, and it is not
settled anywhere.** `SPEC.md` §8 ships silhouettes as ~6 MB under `assets/sil/` and plates as ~25 MB
under `assets/plate/`, and §13 describes the runtime behaviour that follows — *SVGs rasterised at
display size and cached by key; plates loaded only on S2*. `lonja-icons-and-plates` says the opposite:
authored SVG lives in `assets_src/`, is **not** bundled, becomes `plate_specs.g.dart`, and
*`pubspec.yaml` declares `assets/brand/` and nothing else under `assets/`*. No gate script enforces
either, so D-2's "the gate beats the prose" tie-break does not apply and this is a genuine gap
(`CONVENTIONS.md` §4: record it, do not invent a local convention).

What this epic does either way is unchanged: it authors the SVG, at `app/assets/sil/` and
`app/assets/plate/` per `SPEC.md` §8, with the provenance ledger the skill requires. Which of the two
the *app* renders from is a rendering decision owned by E08 and E10, and it needs a `DECISIONS.md`
entry, which is outside this epic's file scope. T07 and T08 both say so rather than deciding it
quietly. **File naming is settled, and by the skill:** `lower_snake_case` binomial
(`epinephelus_coioides.svg`), because rule 9 is explicit, gives its reason, and nothing in `SPEC.md`
names a convention at all.

**`check_content_pipeline.sh` check 5 only recognises `TL`, `FL`, `CW` and `SHL`.** `SPEC.md` §7.1
declares nine measurement codes. E04 recorded this as a gap that Galicia already hits with `CL` for
*Maja*; at three more jurisdictions it will fire on real rows in Iberia and Brazil, and checks 2, 3
and 5 do **not** honour the `content-pipeline-ok` escape hatch. The builder validates against the
full §7.1 list and is authoritative (`CONVENTIONS.md` §7: passing a gate is a floor, not proof).
Widening the gate's regex is a skill edit and belongs with the other skill corrections, not here. Do
not silence it by re-coding a rule to `CW` — that changes a legal measurement to make a grep quiet.

**The `.gz` asset is a binary file in a repository with eighteen concurrent branches.**
`app/assets/db/reference.db.gz` is rebuilt by every content PR and read by E05, E08 and E15. Git
cannot merge it. The rule for this epic: rebuild it as the **last** step before opening the PR, and
resolve any conflict on it by rebuilding from the merged `content/`, never by choosing a side. A
`.gz` chosen from one side of a conflict is a database that matches no corpus, and its sha256 is
recorded in `reference.build.json`, so the mismatch surfaces on a device rather than in review.

**`AE-RAK` and `AE-RK` are two spellings of one code.** `SPEC.md` §7.1 uses `'AE-RK'` in the
`jurisdiction.code` comment; `build-assertions.md` and `licence-provenance.md` write `AE-RAK` and
`ae-rak.md`. §7.1 is authoritative for the schema, so the code is **`AE-RK`** and the directory is
`content/ae-rk/`. T03 states it once so the changelog filename and the `accepted_hosts` key cannot
drift apart.

**English is authored last, and that is an ordering nobody enforces by habit.** §9.2 step 4. T06
encodes it as A13: an `en` vernacular row may not exist for a species that has no name in its
jurisdiction's `default_locale`. Without that, English gets authored first because it is the easiest,
and it becomes the source the other five are checked against — which is backwards, since English has
no legal instrument behind it at all.

## PR description

One of these per task PR; the sections below are the shared skeleton, filled from the task file.

### What changed

The jurisdiction slice or cross-cutting content this PR authors, by directory, with the row counts it
adds, and any new assertion it lands.

### Why

`SPEC.md` §8 and §15 step 19: the content is the deliverable and it runs in parallel. Name the
licence row from the §8 table that permits the redistribution, and its verification status.

### How it was verified

- `(cd tools/content_builder && dart test)` — the slice's corpus test, red before the content existed.
- `dart run content_builder:build` over the whole `content/` tree, exit 0.
- `--check` clean: `snapshot.json` and `content/CHANGELOG/<code>.md` regenerate with no diff.
- `check_content_pipeline.sh tools/content_builder` and `… content`.
- For a locale slice: the reviewer sign-off row in `content/reviewers.yaml` and what the reviewer
  disconfirmed.

### Product invariants touched

None weakened. Invariant 1 (no network) — every gazette PDF is fetched by a human and recorded by
sha256; no tool in this epic opens a socket, and `ocr_audit` reads local files only. Invariant 3
(every result carries a citation) — A4 already makes an uncited row unshippable and this epic only
adds rows that satisfy it. Invariant 5 (an expired ruleset is still evaluated) — an *orden de vedas*
or piracema portaria that has lapsed is authored with its real `valid_to` and ships; it is not
withheld and not silently renewed.

### Follow-ups deliberately not in this PR

Name the jurisdictions still unauthored, and the skill or `DECISIONS.md` edits this slice showed to
be needed but did not make.

## The epic loop

`CONVENTIONS.md` §1 is the ritual and every one of its five steps applies. **One deviation, and it is
the one `epics/README.md` already publishes:** E22 is the exception to the sequence — its branch is
cut once E04 merges and it runs alongside every other epic. Holding a single branch open for the
months this takes would mean rebasing a growing `content/` tree across seventeen merges and producing
a final diff nobody can review.

So the branch name `epic/22-content` is the **series**, and each task lands on its own branch cut
from a current `main`:

```bash
git checkout main && git pull --ff-only
git checkout -b epic/22-content/T03-gulf-rule-rows          # one task, one branch, one PR
# … the task loop, CONVENTIONS.md §2, one commit
gh pr create --base main --head epic/22-content/T03-gulf-rule-rows \
  --title "E22/T03 — Gulf rule rows and verbatim text" --body-file .github/pr-body.md
gh pr checks --watch
gh pr merge --squash --admin --delete-branch
```

**One PR per jurisdiction slice, not one enormous branch at the end.** Nine PRs, each reviewable in
an afternoon, each leaving `main` with a corpus that builds. Nothing else about §1 changes: one
commit per task, `/simplify` and `/code-review` before that commit, checks green before the merge,
`--squash --admin` per D-9.
