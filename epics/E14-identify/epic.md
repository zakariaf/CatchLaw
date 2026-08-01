# E14 — The identification key

| | |
|---|---|
| **Branch** | `epic/14-identify` |
| **After** | E08 merged |
| **Tasks** | 7 |
| **Spec** | `SPEC.md` §4.3 (in full), §5.2 (why photo-AI is excluded), §6 S7, §7.1 (`key_node`, `key_option`, `key_leaf_species`), §14 (the S7 reachability check) |
| **Package** | `app/` — `app/lib/ui/identify/`, `app/lib/domain/`, `app/lib/data/` |

## What this epic achieves

A fisher holding a fish he cannot name answers up to six illustrated either/or questions and is handed
a **list of candidates**, never a single confident answer. He can see every answer that led him there,
tap any of them to go back, and back out of a terminal state one step at a time. Where the key
legitimately runs out of questions, he lands on a stated dead end — "No match. Browse by shape or
search by name." — and not on an error. Where two or more species remain, the strictest applicable
rule is listed first, so an ambiguous identification never reads more permissively than its safest
candidate. When this merges, S7 exists and is reachable from all three places `SPEC.md` §4.3 names:
S1, S5's empty state, and S6.

This is the epic that pays for the §5.2 exclusion. Photo-AI is not excluded because it cannot run
offline — it demonstrably can, and `SPEC.md` §5.2 names the app that proves it. It is excluded because
no commercially licensable training corpus exists for these species, because **a key is auditable and
a classifier is not**, and because the one competitor with genuine offline recognition gates that
recognition behind an account and a subscription. Every task below is the auditability half of that
argument being made real: the trail (T04) is the audit, the multi-candidate result (T02) is the
refusal to be confident, and the ordering (T07) is what makes the refusal safe to read.

## Where we are now

The branch is cut after E13 merges — the sequence in `README.md` is strict for every epic except E22,
so E09–E13 are already in `main` even though the hard dependency recorded for E14 is E08.

What exists and who put it there, per `README.md`'s epic table:

- **E05** — `reference.db` extracted once and opened `readOnly: true` under
  `getApplicationSupportDirectory()`, plus the drift `ReferenceDatabase` in
  `app/lib/data/services/`. `key_node`, `key_option` and `key_leaf_species` are already **in** that
  file: they are part of the §7.1 schema E04 builds and E05 ships. Nothing reads them yet.
- **E06** — six ARB files (`ar`, `en`, `es`, `gl`, `ca`, `pt_BR`; D-3) and the `content_string`
  resolver with the §9.2 fallback chain. `key_node.question_key` and `key_option.label_key` are Tier-2
  content strings — §9.2 names "key questions and options" explicitly — so they resolve through that
  resolver and never through ARB.
- **E07** — the Lonja theme at `app/lib/theme/` (D-2), glove density, the three themes.
- **E08** — S5 (species search, including its empty state) and S6 (browse by shape), and the species
  row those screens are built from.
- **E12** — S1 and the five-destination bottom nav.

What does not exist: any Dart that reads a `key_*` table, any route to S7, any of the three
`Identify this fish` call sites resolving anywhere real. `packages/rule_engine/` is complete and this
epic does not touch it.

Where this document names a file E08 or E12 delivered, it names what `README.md` says those epics
deliver. If E08 named the browse screen differently, T06 wires the actual file rather than the one
written here.

## Why this epic exists here in the order

`SPEC.md` §15 step 12 puts the identification key after step 4 (the data layer) and step 6 (species
search, browse and detail), and the reason is not convenience:

- The key's terminal product is a **species id**, and every candidate row is a tap through to S2.
  Without E08 there is no S2 to land on and no species row to render a candidate in, so the key would
  end in a dead link.
- Two of the three entry points are screens E08 owns (S5's empty state and S6's app bar). Building
  the key first would mean building it with one entry point and retrofitting two — which is exactly
  how the first draft lost one.
- The candidate ordering in T07 reads resolved rules, which is E03's engine reached through E05's
  repositories. Both are merged well before this point.

It must not come later because E19 (accessibility) and E20 (RTL hardening) audit *all* UI, and S7 is
UI. A screen that lands after the audit epics is a screen nobody audited.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | Traversing the key | `T01-traversing-the-key.md` | M | — |
| T02 | Candidates: one or more, never one confident answer | `T02-candidates-never-one-answer.md` | M | T01 |
| T03 | The dead end is a terminal state | `T03-dead-end-terminal-state.md` | S | T01, T02 |
| T04 | The decision trail | `T04-decision-trail.md` | M | T01, T03 |
| T05 | The candidate count and the six-couplet ceiling | `T05-candidate-count-and-couplet-ceiling.md` | M | T01, T02 |
| T06 | Three entry points | `T06-three-entry-points.md` | S | T01 |
| T07 | Multi-candidate ordering | `T07-multi-candidate-ordering.md` | M | T02, T05 |

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once all seven have landed:

- [ ] All 7 tasks committed, one commit each, every `Task: E14/T<nn>` trailer present.
- [ ] S7 is reachable from S1, from S5's empty state and from S6 — three widget tests in T06, one per
      entry point. This does **not** discharge the §14 manual check; E21 walks it in airplane mode.
- [ ] No path through the key in the shipped `reference.db` exceeds **6 couplets** (§4.3), asserted by
      T05 over the built graph and not only over fixtures.
- [ ] A leaf always yields **one or more** candidates and the count is stated even when it is 1.
- [ ] `key_option.next_node_id IS NULL` renders the S7 dead-end terminal state; no code path treats it
      as an error, and no dead end is a trap — `Back one step` is present on it.
- [ ] `flutter test` green in `app/`; 100% branch coverage on `app/lib/domain/models/key_path.dart`,
      `app/lib/domain/use_cases/key_depth.dart` and
      `app/lib/domain/use_cases/order_key_candidates.dart`, which are pure Dart with no widget
      binding. The app as a whole holds its ~80% floor (`CONVENTIONS.md` §6).
- [ ] `packages/rule_engine/` is byte-identical to its state at branch point. The key is content
      navigation, not rule resolution, and the strictness rank is derived in `app/lib/domain/` from
      verdicts E03 already produces (D-7).
- [ ] No new user-visible sentence exists in `packages/rule_engine/` (D-7); every key question and
      option label resolves through `content_string`, every chrome string through ARB in all six
      locales (D-3).
- [ ] Gates clean against real directories: `check_app_invariants.sh app/lib`,
      `check_lonja_tokens.sh app/lib`, `check_lonja_lists.sh app/lib`, `check_lonja_buttons.sh app/lib`,
      `check_lonja_icons.sh app/lib`, `check_lonja_nav.sh app/lib`, `check_reference_db.sh app/lib`,
      `tools/gates/no_directional_geometry.sh app/lib`.
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin --delete-branch` (D-9).

## Risks and the things that will bite

**1. The seed content may ship no key at all.** E04 seeded Galicia; §8 and E22 say the content is the
long pole. If `key_node` holds no root for any `taxon_group`, T01's entry-point list is empty — and
`lonja-lists-and-tables` rule 6 forbids rendering a blank frame. `SPEC.md` §6 S7 describes no state for
"this content version ships no key". **What would resolve it:** one line in §6 S7 from the spec owner,
or an ARB key reviewed alongside the other five locales. Until then T01 renders the same authored
terminal state as the dead end rather than nothing, and the epic records that the copy is provisional.
Do not invent a second wording for it.

**2. The six-couplet ceiling is a property of content this epic does not author.** T05 can only assert
it against whatever `reference.db` exists when it runs. The assertion is worth having only if it runs
against the **built** database, not a hand-written fixture. **What would resolve it:** confirm E05 left
a reusable built-`reference.db` fixture for its data tests. If it did not, the ceiling check moves into
`tools/content_builder` where E22 will trip over it, and T05 keeps only the pure-Dart `keyDepth` tests.
Decide this before writing T05's tests, not after.

**3. `key_node.taxon_group` carries no `CHECK` constraint.** §7.1 constrains `species.taxon_group` to
eight values and leaves `key_node.taxon_group` as bare `TEXT NOT NULL`. A typo in authored content
therefore produces a root node that no entry point can reach, silently. T01 maps it through a closed
`TaxonGroup` enum and surfaces an unmapped value as a typed failure rather than dropping the row.
**What would resolve it:** the same `CHECK` on `key_node`, or an assertion in the content builder —
both belong to E04/E22, not here. Record it; do not add a constraint from this epic.

**4. Two parentless nodes in one `taxon_group`.** The schema permits it; §4.3 says "a deterministic
dichotomous key per family group", which does not. T01 treats more than one root per group as a content
defect and fails typed rather than picking the lowest id and hoping.

**5. `key_option.figure_asset` is nullable.** §6 S7 says "two large illustrated options". If the seed
ships null figures, an option is label-only. That is a content gap for E22, not a UI failure — T01
renders a label-only option correctly and a test pins that behaviour, so a missing figure never
collapses the layout.

**6. `SPEC.md` §13 publishes no latency target for the key.** It targets search (< 50 ms at 400 species
/ 2,400 names), rule evaluation (< 10 ms) and FTS (< 200 ms) — the key appears in none of them. T05
therefore designs against a structural constraint (one subtree-count query per S7 session, memoised;
never a query per tap) rather than against a number, and no task invents one. If a target is wanted, it
belongs in §13.

**7. `parent_node_id` and `next_node_id` can disagree.** `parent_node_id` is a back-pointer;
`next_node_id` is the edge the user actually walks. T05 computes reachability over `next_node_id` and a
test pins that choice with a fixture where the two disagree, because getting this backwards produces a
candidate count that is right in testing and wrong on a real graph.

## PR description

### What changed

S7, the identification key, in full: couplet traversal over `key_node` and `key_option` from a
`taxon_group` root; candidate lists backed by `key_leaf_species` with its `rank`; the nullable
`next_node_id` rendered as a terminal state; a tappable decision trail with `Back one step` and
`Start over`; a live candidate count and an assertion that no path exceeds six couplets; the three
entry points from S1, S5's empty state and S6; and multi-candidate ordering that puts the strictest
applicable rule first.

New: `app/lib/ui/identify/`, `app/lib/domain/models/key_*.dart`,
`app/lib/domain/use_cases/{key_depth,order_key_candidates}.dart`,
`app/lib/data/repositories/key_repository*.dart`, `app/lib/data/services/key_dao.dart`,
`app/testing/fakes/fake_key_repository.dart`, `app/testing/models/key_fixtures.dart`, and one route.

### Why

`SPEC.md` §4.3 and §6 S7. The identification path is the reason §5.2's exclusion is defensible: a key
is auditable and a classifier is not, and a wrong confident classification on a protected species is
the worst failure this app could produce. Every design choice in this PR follows from refusing to be
confident — the multi-candidate result, the visible count at n=1, the trail, and the strictest-first
ordering.

### How it was verified

90 tests across the seven tasks (13 · 12 · 10 · 17 · 17 · 7 · 14), each written before its
implementation and each observed failing first. Three of them are the three entry points, because a
missing entry point was the defect in the first draft and §14 lists it as a manual check as well. Pure-Dart domain code (`key_path.dart`,
`key_depth.dart`, `order_key_candidates.dart`) is at 100% branch coverage. Gates listed in the epic
DoD are clean against `app/lib`. The §14 airplane-mode walk of S7 is **not** in this PR; E21 runs it.

### Product invariants touched

- **1 — no network code path:** untouched. Every byte read here comes from the read-only
  `reference.db`.
- **2 — a verdict states a fact and never instructs:** the key produces **no verdict at all**. It has
  neither a measurement nor a zone, so it cannot. The dead-end and candidate-row wording states what
  the app holds; the two dead-end actions are verb phrases about the app's own behaviour
  (`Browse by shape`, `Search by name`), which is the approved label register, and never about the
  fish.
- **3 — every result carries a required `Citation`:** not weakened. A candidate row shows the §6 S5
  one-word hint (`45 cm` / `protected` / `closed`), which is a category label and not a rule
  statement; the cited statement is made on S2, one tap away. No `Citation` is constructed anywhere in
  `app/lib/ui/identify/`.
- **4 — colour is never the only signal:** the protected candidate carries glyph, word and hue, and a
  `sunlight - ` test asserts it is still distinguishable with colour removed.
- **5 — an expired ruleset is still evaluated and still shown:** T07 ranks an **expired** protected
  rule as protected. Expiry does not demote a candidate down the list.

### Follow-ups deliberately not in this PR

- The look-alike warning card. §4.3 lists it, but §6 S2 puts it on the result screen, which is E10's.
  E14 reads the `lookalike` table only to decide plate-versus-silhouette (`lonja-icons-and-plates`
  rule 7).
- Key content beyond the seed jurisdiction — E22, the long pole.
- The golden matrix in six locales and the greyscale proof — E19 and E20 own the harness and the lanes.
- The §14 manual confirmation that S7 is reachable from all three places in airplane mode — E21.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch` (D-9); then and only then start E15.
