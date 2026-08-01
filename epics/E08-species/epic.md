# E08 — Species: search, browse and the static detail

| | |
|---|---|
| **Branch** | `epic/08-species` |
| **After** | E07 merged |
| **Tasks** | 8 |
| **Spec** | `SPEC.md` §4.1 (species picker, local-name search), §4.3 (silhouette browse, look-alike warnings), §6 S5, S6 and the static half of S2, §13 (search latency, cold start) |
| **Guide** | `FLUTTER_GUIDE.md` Part 1.2, 1.3, 5.2, 5.3, 8.1 |
| **Packages** | `app/` (`app/lib/data/`, `app/lib/domain/`, `app/lib/ui/species/`, `app/lib/ui/core/ui/`) |
| **Commit scopes** | `species` for feature UI and view models, `data` for repositories and DAOs (`CONVENTIONS.md` §3: "the package or feature") |

## What this epic achieves

When this merges, a fisher can find a fish. Typing `hamour`, `هامور`, `هامورة`, `الهامور` or
`Epinephelus` reaches one species in under 50 ms at 400 species and 2,400 names; the results arrive
grouped **in your zone** first and **elsewhere in this jurisdiction** second, each row carrying the
local name, its silhouette and a one-word hint — a size, `protected` or `closed`. When nothing
matches, the screen routes onward instead of stopping: **Identify this fish**, **Browse by shape**,
and a line saying the list covers the active jurisdiction only. Browse by shape lays every species
out as a black-on-white silhouette grid grouped by family, with **the family names in the reader's
own language** — a Galician grid says *Vieiras*, not *Pectinidae*. Tapping any of those paths lands
on the same species detail, whose header sets the local name large, the other-locale names small and
the scientific name last, because Khalid does not read Latin binomials. Recents are recorded per
zone and ordered by frequency then recency, so the six species he actually catches are one tap from
the top of the screen.

Three of `SPEC.md` §6's screens exist after this epic: S5 complete, S6 complete, and S2 in its
static half. E09 adds the ruler, E10 adds the verdict, and E12 mounts the recents strip on S1. This
epic is also the first of S7's three entry points to become real: S5's empty state offers
**Identify this fish**, and E14/T06 is where all three entry points are asserted together.

## Where we are now

The branch is cut from a `main` that already carries seven merged epics:

- **E01** — the pub workspace (`pubspec.yaml`, `analysis_options.yaml`, `app/`,
  `packages/rule_engine/`, `packages/analysis_defaults/`, `tools/content_builder/`) and every §14
  static gate wired into CI (D-1, D-5).
- **E02** — the shared §9.4 fold in `packages/rule_engine/`, with its acceptance test. This epic
  calls that function; it does not reimplement it.
- **E03** — §7.3 resolution, expiry semantics, D4 ambiguity, sealed `Verdict` and `Finding` types
  carrying a required `Citation` and no user-visible sentence in any language (D-7).
- **E04** — `tools/content_builder/` and the Galicia seed, so a real `reference.db` exists with
  `species`, `species_name.search_norm`, `family`, `lookalike`, `rule` and `content_string` rows.
- **E05** — `app/lib/data/services/reference_database_service.dart` and
  `user_database_service.dart`: two drift databases, the read-only open, and the atomic first-launch
  extraction (D-6).
- **E06** — six ARB files `app_ar.arb`, `app_en.arb`, `app_es.arb`, `app_gl.arb`, `app_ca.arb`,
  `app_pt_BR.arb` (D-3), the `content_string` resolver with §9.2's fallback chain, and the
  numeral-system lever from §9.3.
- **E07** — `app/lib/theme/` (D-2): the three themes, glove density, the type ramp and the
  `check_lonja_tokens.sh` gate green.

What does **not** exist yet: `app/lib/ui/species/` in any form, `app/lib/data/repositories/` for
species, and — per the delivery line for E07 in `epics/README.md`, which names three themes, glove
density, the type ramp and the tokens gate — any Lonja **component**. So this epic authors the first
three components in `app/lib/ui/core/ui/`: `LonjaSearchField`, `LonjaSpeciesRow` and
`LonjaEmptyState`. They are shared, so they live in `app/lib/ui/core/ui/` per `FLUTTER_GUIDE.md`
§2.5 and D-2, not under `app/lib/ui/species/`.

E02's normalisation and E04's `search_norm` column are the load-bearing gap this epic closes: until
now the fold existed and the column was populated, but nothing queried them.

## Why this epic exists here in the order

It cannot come earlier. The search reads `species_name.search_norm`, which only exists once E04 has
built `reference.db` and E05 has extracted and opened it. The family names on S6 resolve through
`family.name_key` → `content_string` in the active locale, which is E06's resolver and its fallback
chain. Every surface here is set in the Lonja ramp and coloured from `app/lib/theme/`, which is E07.
`SPEC.md` §15 step 6 states the dependency set as `[2,4,5]` — the pure core, the data layer and
localisation — and this epic adds E07 because a screen that predates the theme is a screen that gets
re-authored.

It must not come later. E09 (ruler) and E10 (result) both land **on S2**, so S2's static half must
exist for them to extend rather than invent; `epics/README.md` records E10 as depending on E08 and
E09 together. E14 (identification key) depends on E08 because S7's candidate list taps through to
S2. E12 mounts the recents strip and is the first point at which §3's five-second target is testable
— it cannot be tested against a species picker that does not exist.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | The search query | `T01-the-search-query.md` | M | — |
| T02 | The view model and the two result groups | `T02-view-model-and-result-groups.md` | M | T01 |
| T03 | S5, and an empty state that routes onward | `T03-s5-search-and-empty-state.md` | M | T02 |
| T04 | S6 — browse by shape | `T04-s6-browse-by-shape.md` | M | T01 |
| T05 | S2, the static half | `T05-s2-static-half.md` | M | T01 |
| T06 | The look-alike card | `T06-look-alike-card.md` | S | T05 |
| T07 | Recents | `T07-recents.md` | M | T03, T05 |
| T08 | Widget and golden tests for S5, S6 and S2 | `T08-widget-and-golden-tests.md` | L | T03, T04, T05, T06, T07 |

**Reading the reference tables.** A path beginning `.claude/skills/` is a `catchlaw-*` or `lonja-*`
bundle in this repository. A path prefixed `Flutter-Skills:` is one of the 33 general skills in the
separate plugin, which is not checked out here — `CONVENTIONS.md` §4 has the two registries and the
rule that neither restates the other.

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once the epic is whole:

- [ ] All 8 tasks committed, one commit each, every `Task: E08/T<nn>` trailer present.
- [ ] `cd app && flutter test` green; `app/lib/ui/species/` and `app/lib/data/repositories/`
      at or above the ~80% app coverage floor of `CONVENTIONS.md` §6, generated code excluded.
- [ ] Typing `hamour`, `Hamour`, `هامور`, `هامورة`, `الهامور` and `Epinephelus` each returns exactly
      one species id, and it is the same id — the §9.4 acceptance test, now executed through the
      real query rather than the fold alone.
- [ ] The search returns in **< 50 ms at 400 species / 2,400 names** on the CI runner, measured as a
      median over 100 queries against an in-memory fixture; the device figure is E21's (§14).
- [ ] `EXPLAIN QUERY PLAN` asserts `idx_name_search` is used for the prefix range — a test, not a
      code comment.
- [ ] S5, S6 and S2 each render all four states from
      `lonja-lists-and-tables/references/the-four-states.md`, and the ochre stale bar coexists with
      data on S5 rather than replacing it (invariant 5).
- [ ] S5's empty state reaches **Identify this fish** and **Browse by shape**, and carries the
      active-jurisdiction note. The three-entry-point assertion for S7 itself is E14/T06.
- [ ] Every family heading on S6 renders through `family.name_key` → `content_string` in the active
      locale; the `gl` golden lane shows Galician family names, not Latin.
- [ ] Recents are per `(jurisdiction_code, zone_code)`, ordered `use_count DESC, last_used_at DESC`,
      and served by one indexed query (§13's cold-start line).
- [ ] `packages/rule_engine/` is unchanged by this epic — no user-visible sentence entered it (D-7).
- [ ] All six gates clean against `app/lib`:
      `check_app_invariants.sh`, `check_lonja_tokens.sh`, `check_lonja_type.sh`,
      `check_lonja_lists.sh`, `check_lonja_controls.sh`, `check_lonja_icons.sh`, plus
      `check_reference_db.sh` and `tools/gates/no_directional_geometry.sh` (D-8).
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin --delete-branch` (D-9); branch deleted.

## Risks and the things that will bite

**1. The empty state needs two actions and the skill allows one.**
`lonja-lists-and-tables/references/the-four-states.md` says an empty state carries "exactly ONE
`LonjaButton.primary`; two competing actions is a defect". `SPEC.md` §6 S5 requires **both**
*Identify this fish* and *Browse by shape*, and §4.3 records that S7 reachable from only one place
was a defect in the first draft. **Resolution, applied in T03:** one primary (*Identify this fish*)
and one secondary (*Browse by shape*). The skill's defect is two competing *primaries*, which this
is not, and the skill's own authored Search copy already ends "…or browse by shape". `SPEC.md` is
authoritative for the product. **What would resolve it properly:** a correction to
`the-four-states.md` naming the router case, in the same style as D-3's skill corrections. Not
E08's file to edit.

**2. The type ramp has no step below `binomial` at 15.**
`SPEC.md` §6 S2 orders the header "local name large, other-locale names small, scientific name
smallest". `lonja-typography/references/type-ramp.md` sets `binomial` at 15 and `legalSmall` at 14,
so the binomial is nominally one logical pixel *larger* than the other-locale line — and
`lonja-lists-and-tables/references/row-and-table-anatomy.md` sets the row binomial at 12.5, so the
two reference files already disagree with each other. **Resolution, applied in T05:** the ramp is
used as published (`display` 30 → `legalSmall` 14 → `binomial` 15 italic `ink-faint`), and the
demotion the spec asks for is carried by italic, weight and `ink-faint` rather than by size. Adding
a seventeenth step would fork a reference table E08 does not own, which rule 4 of `lonja-typography`
forbids doing at a call site and which `CONVENTIONS.md` §4 forbids doing locally. **What would
resolve it:** reconcile 12.5 and 15 in `lonja-typography`, or add a named `binomialSmall` step —
either way in the skill, not in a feature.

**3. The unit shown for a bivalve shell length is unresolved.**
`SPEC.md` §9.5 says lengths are stored as integer millimetres and displayed in the user's
`length_unit` (`cm` default). `lonja-forms-and-controls/references/search-field-and-keypad.md` shows
`38` · `mm` · `Shell length` for *Ameixa babosa*, i.e. millimetres regardless of the setting.
**Resolution, applied in T02:** the hint renders §9.5's rule through **one** function,
`LengthDisplay.format`, so there is a single place to change. **What would resolve it:**
`catchlaw-measurement-ruler` owns units and rounding; E09 decides and consumes `LengthDisplay`
rather than duplicating it.

**4. A fifth skill file names the wrong sixth locale.**
D-3 lists four files that say `ur` or `app_pt.arb` and assigns their correction to E01/T09.
`lonja-typography/references/arabic-and-scripts.md` names the six locales as
`ar · en · es · gl · pt-BR · fr` — Catalan replaced by French, which appears nowhere in `SPEC.md`.
This is a fifth file, outside D-3's list. **Mitigation:** every task in this epic writes `ca` and
never `fr`, per D-3. **What would resolve it:** add the file to E01/T09's correction list, or a
follow-up correction task.

**5. A protected species needs a plate and `plate_asset` is nullable.**
`lonja-icons-and-plates/references/engraved-plates.md` requires a full `LonjaPlate` on a search
result row for any protected or look-alike species. `SPEC.md` §7.1 declares
`species.plate_asset TEXT` nullable, and §8 makes plates optional and per-image cleared — "any plate
whose artist cannot be identified is dropped". So a protected species can legitimately reach the app
with no plate. **Resolution, applied in T03 and T05:** the art resolver renders `plate_asset` when
present and falls back to `silhouette_asset` when it is null, and a widget test pins that fallback
so it is a decision rather than an accident. **What would resolve it:** §8's builder assertion list
has no "protected species must have a plate" rule; E22 is where it belongs, alongside plate
clearance for the remaining jurisdictions.

**6. `species_recent` as published cannot serve its own read.**
`SPEC.md` §7.2 declares `PRIMARY KEY (species_id, jurisdiction_code, zone_code) WITHOUT ROWID` and
no index. The read is `WHERE jurisdiction_code = ? AND zone_code = ? ORDER BY use_count DESC,
last_used_at DESC LIMIT 6`, whose leading filter column is not the leading key column — so the
`WITHOUT ROWID` primary key cannot serve it, and §13's "recents from one indexed query" on the
< 1.2 s cold-start path is not met by the schema as printed. **Resolution, applied in T07:** a
forward-only `user.db` migration adds
`idx_recent_zone (jurisdiction_code, zone_code, use_count DESC, last_used_at DESC)` with the schema
test `run-migration` requires, and an `EXPLAIN QUERY PLAN` assertion proves it is used.

**7. The 50 ms number cannot be honestly proved on CI.**
§13's target is stated against a Snapdragon 665. The CI runner is not one, so T01's latency test is
a **regression guard** with the spec's number as its ceiling, not a proof. **What would resolve it:**
the §14 dynamic pass in E21, on physical devices of both platforms. Nothing in this epic may be
described as having measured the device figure.

**8. `search_norm` is only as good as the build that wrote it.**
The query and the content builder must call the *same* fold — E02/T04's definition of done already
requires that the identical function is what `tools/content_builder/` calls, not a copy. If the two
ever diverge, this epic's search silently returns nothing for Arabic and every test here still
passes, because the tests build their fixture with the same function the query uses.
**Mitigation:** T01 adds one test that reads `search_norm` **as written by E04** out of the
committed Galicia fixture and asserts the query finds it, rather than only testing against rows the
test itself normalised.

**9. The greyscale screenshot test §4.9 promises cannot fail.**
§4.9's acceptance condition for colour independence is "passes a greyscale screenshot test", and
`catchlaw-conventions-index/references/product-invariants.md` names a greyscale golden as the proof
of invariant 4. `widget-golden-and-a11y-testing/references/a11y-guidelines-and-limits.md` shows the
arithmetic: `Color.computeLuminance()` is chroma-blind, so any correct `gray(c)` reconstructs a grey
of exactly that luminance and `wcag(gray(a), gray(b)) == wcag(a, b)` for **all** a and b. Greyscale
carries zero signal beyond the WCAG ratio; a greyscale screenshot cannot fail a pairing that a
colour one passes. **Resolution, applied in T08:** this epic asserts the composition — glyph **and**
word **and** hue on every semantic state — which is the property that actually survives Android's
system-wide greyscale mode. **What would resolve it:** E19 owns the whole-app pass and should write
a pure-Dart WCAG **luminance ratio between the two state colours** (which fails exactly when the
only signal is chroma), optionally with APCA as a genuine second channel — not a greyscale image.

## PR description

### What changed

Three of `SPEC.md` §6's screens, plus the data layer under them:

- An index-backed prefix query over `species_name.search_norm` capped at 40 species, with a second
  arm over `species.scientific_name`, behind `SpeciesSearchRepository`.
- A search view model that splits results into **in your zone** and **elsewhere in this
  jurisdiction** and computes one-word row hints (`protected` / `closed` / a size) from the rule
  rows, with the producing `Citation` required on the row model.
- **S5** — search field, grouped results, all four list states, and an empty state that routes to
  *Identify this fish* and *Browse by shape* with the active-jurisdiction note.
- **S6** — a computed grid of black-on-white silhouettes grouped by family, family names resolved
  through `family.name_key` in the active locale, *Identify this fish* in the app bar.
- **S2, static half** — species header ordered local name → other-locale names → binomial,
  silhouette or plate, and the look-alike card. No measurement, no verdict, no rule facts.
- **Recents** — per `(jurisdiction_code, zone_code)`, `use_count DESC, last_used_at DESC`, written
  on every S2 open, with the `user.db` index that read needs.
- The first three Lonja components in `app/lib/ui/core/ui/`.

### Why

`SPEC.md` §15 step 6 places species search, browse and the static detail after the pure core, the
data layer and localisation, and before the ruler and the result. §4.1 makes four paths to one
species detail the acceptance condition for the species picker; this PR builds three of them and
leaves S7 to E14. §4.3 records that S7 reachable from a single place was a defect in the first
draft; S5's empty state is one of the three fixes.

### How it was verified

- The §9.4 acceptance inputs are executed through the real query, not the fold alone, and land on
  one species id.
- `EXPLAIN QUERY PLAN` assertions prove `idx_name_search` and `idx_recent_zone` are used.
- A latency regression test holds the search under 50 ms at 400 species / 2,400 names on CI. The
  device figure is E21's §14 pass and is not claimed here.
- Four list states per screen, plus the ochre stale bar composed with data.
- Golden lanes in `ar` (script joining and mirroring) and `gl` (localised family names), Ahem and
  real-font, per `widget-golden-and-a11y-testing`.
- Row tap targets asserted at 64 dp paper / 76 dp glove by `getSize`, tapped at the start edge.
- All eight gates clean against `app/lib`.

### Product invariants touched

`CONVENTIONS.md` §9, none weakened:

1. **No network** — every byte comes from `reference.db`, `user.db` and the ARB. No new dependency.
2. **Statement, never instruction** — the row hints are `protected`, `closed` and a size; no
   imperative reaches a row end slot or an empty-state headline.
3. **Required `Citation`** — the row-hint model carries a non-nullable `Citation` because the hint
   is derived from a rule row. S2's static half renders nothing rule-derived, so it owes none yet;
   E10 adds every rule-derived surface together with its citation.
4. **Never colour alone** — `protected` is glyph plus word plus oxblood; `closed` is glyph plus word
   plus ochre.
5. **Stale is shown** — an expired pack still produces hints and still renders the list, with the
   non-blocking ochre bar above it.

### Follow-ups deliberately not in this PR

- The ruler, manual entry and the measurement-method diagram on S2 — E09.
- The result banner, findings list, rule facts table, citation row, *Add to today*, *Flag this
  rule*, the amber expiry bar and the disclaimer — E10.
- S7 itself and the three-entry-point assertion — E14, specifically E14/T06.
- Mounting the recents strip on S1 with the tally bar — E12.
- The greyscale screenshot proof and the 200% audit as a whole-app pass — E19.
- The six-locale golden matrix as a whole-app pass — E20.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch` (D-9); then and only then start E09.
