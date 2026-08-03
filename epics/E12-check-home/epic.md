# E12 — Check home and the navigation shell

| | |
|---|---|
| **Branch** | `epic/12-check-home` |
| **Release** | **v1** (T01, T02, T04, T05, T06, T07, T08) and v2 (the rest) — `epics/RELEASES.md`, D-22 |
| **After** | E10 and E11 merged |
| **Tasks** | 8 |
| **Spec** | `SPEC.md` §3 (the core loop), §6 bottom navigation and S1, §4.1 (species picker, four paths), §4.5 (today's tally), §4.9 (one-handed reach), §13 (< 1.2 s cold start, < 6 s first launch), §15 step 10 |
| **Package** | `app/` |

## What this epic achieves

When this merges the app has a front door. It launches straight to Check with the last-used zone
already selected — no splash, no login, no onboarding, no what's-new — and from that first frame all
four species paths named in `SPEC.md` §4.1 are one tap away: the six-species Recents strip, the search
field, Browse by shape, and Identify this fish. A five-item bottom strip — Check, Today, Trips,
Reference, Settings — is fixed furniture underneath, and today's tally against the bag limit is stated
on Check without navigating away. Before this epic the screens built by E08 to E11 could only be
reached by a test driving a route directly; after it, a person holding the phone can walk from launch
to a verdict to `+ Add to today`. `SPEC.md` §15 step 10 calls this **the first point at which the
five-second target is testable**, and T07 is where that stops being an aspiration and becomes an
integration test that walks the loop and records the number.

## Where we are now

The branch is cut from a `main` that already carries:

- `app/lib/main.dart` and the `ProviderScope` with both drift databases opened lazily — E05, per D-6:
  `assets/db/reference.db.gz` extracted to application support, verified by sha256, opened
  `readOnly: true`; `user.db` writable and the only irreplaceable file.
- `app/lib/l10n/app_ar.arb`, `app_en.arb`, `app_es.arb`, `app_gl.arb`, `app_ca.arb`, `app_pt_BR.arb` —
  E06, six locales exactly (D-3), with the CI check that fails on a key missing from any of them.
- `app/lib/theme/` — E07, the three hand-authored Lonja themes and the `LonjaTokens` extension with
  its `density` field (D-2).
- `app/lib/ui/species/` — E08: S5 species search, S6 browse by shape, the static half of S2.
- `app/lib/ui/ruler/` — E09: S3, S4, step-and-mark, manual entry that works before calibration.
- `app/lib/ui/result/` — E10: S2 complete, including the verdict stamp, the findings list, the required
  `Citation`, the ochre stale bar, Flag this rule, the disclaimer, and the `+ Add to today` action that
  `SPEC.md` §6 S2 enumerates.
- `app/lib/ui/zones/` — E11: S9, the bbox prefilter, ray casting, GPS as a suggestion only.

What does not exist: any shell. There is no bottom navigation, no S1, no launch target, and no route
from a cold start to a species. `packages/rule_engine/` is finished and holds no user-visible sentence
in any language (D-7); every word this epic renders comes from ARB or from `content_string`.

Two destinations this epic wires have no screen yet — Today (S8) and Trips (S10) arrive in E13,
Reference (S12) in E15, Settings (S14) in E16. T01 registers all five branches and points the four
unbuilt ones at a single named placeholder whose dartdoc says which epic replaces it.

## Why this epic exists here in the order

It cannot come earlier because S1 is a hub: the Recents strip routes to S2 (E10), the search field to
S5 and Browse by shape to S6 (E08), and the zone chip to S9 (E11). A Check screen built before those
exist would be a screen of dead links, and the four-paths acceptance condition in §4.1 — "four paths
land on the same species detail" — would be untestable.

It must not come later because everything after it needs a shell to hang off. E13's catch log lives
behind the Today and Trips destinations; E14's identification key is reached from S1; E15's reference
section is destination four. `SPEC.md` §15 puts Check home at step 10 with dependencies `[6, 8, 9]`,
which are exactly E08, E10 and E11.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | The bottom navigation | `T01-bottom-navigation.md` | M | — |
| T02 | S1 — the Check screen | `T02-check-screen.md` | L | T01 |
| T03 | The tally summary bar | `T03-tally-summary-bar.md` | M | T02 |
| T04 | The empty state, and the keyboard that does not appear | `T04-empty-state-and-keyboard.md` | S | T02 |
| T05 | No jurisdiction set | `T05-no-jurisdiction-set.md` | S | T02 |
| T06 | Cold start under 1.2 s, with nothing awaited before `runApp` | `T06-cold-start-budget.md` | L | T01, T02 |
| T07 | The five-second core loop | `T07-five-second-core-loop.md` | L | T02–T06 |

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once the epic is whole:

- [ ] All 7 tasks committed, one commit each, every `Task: E12/T<nn>` trailer present.
- [ ] A cold launch lands on Check with the last-used zone selected, and no splash, login, onboarding
      or what's-new screen exists anywhere in `app/lib/` (`SPEC.md` §3 step 1).
- [ ] All four species paths in `SPEC.md` §4.1 are reachable in one tap from S1, and a widget test
      asserts each one's destination route.
- [ ] `LonjaDestination` declares exactly five values in the order check, today, trips, reference,
      settings, and `check_lonja_nav.sh` counts them.
- [ ] `flutter test` green in `app/`, and `app/lib/ui/check/` carries no untested branch beyond the
      ~80% app floor in `CONVENTIONS.md` §6.
- [ ] `.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh app/lib` clean.
- [ ] `.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh app/lib` clean.
- [ ] `.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh app/lib` clean.
- [ ] `.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib` clean —
      including check 8, an awaiting `main()` ahead of `runApp`.
- [ ] `tools/gates/no_directional_geometry.sh app/lib` clean (D-8).
- [ ] Every ARB key added by this epic exists in all six locales (D-3), and no chrome string is a Dart
      literal.
- [ ] `flutter run --profile --trace-startup` on the reference device reports
      `timeToFirstFrameRasterizedMicros` under 1,200,000, and the figure is pasted into the PR body.
- [ ] `app/integration_test/five_second_loop_test.dart` walks launch → species → length → result →
      add to today, in `en` and in `ar`, and reports its measured elapsed time.
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin`; branch deleted.

## Risks and the things that will bite

**1. `+ Add to today` may not exist yet.** `SPEC.md` §6 S2 enumerates it as an S2 element and E10 owns
S2, but `epics/README.md`'s one-line summary of E10 does not name it. T07 cannot walk step 5 of §3
without it. *Resolution:* before starting T07, grep `app/lib/ui/result/` for the write into `catch`. If
it is absent it is an E10 gap; there is no branch left to reopen, so it is added in T07's commit and
the PR body says so in as many words. The repository method it calls is the one E13 will extend, not a
second one.

**2. Nothing may ever write `species_recent`.** The Recents strip reads
`species_recent (species_id, jurisdiction_code, zone_code, use_count, last_used_at)` from `SPEC.md`
§7.2, but the write happens when a species is picked — which is E08's and E10's path. If neither epic
wrote it, the strip is permanently empty and T02's tests would pass against a fake while the app shows
the T04 empty state forever. *Resolution:* T02's definition of done includes an integration-level
assertion that picking a species from S5 raises `use_count`; if the write is missing, T02's commit adds
the single repository method that performs it.

**3. The 1.2 s number cannot be produced by CI.** `SPEC.md` §13 fixes the target on a Snapdragon 665;
GitHub's runners are not that device and an emulator figure would be a fiction. *Resolution:* CI
enforces the two structural properties that make the budget achievable — no `await` before `runApp`
(gate check 8) and no asset decoding on the launch path — and the wall-clock number comes from
`flutter run --profile --trace-startup` on a physical device, recorded in the PR. **What would fully
resolve it:** naming one specific handset in the repository as *the* reference device, which no
document currently does.

**4. "Recents from one indexed query" cannot be literally true.** `SPEC.md` §13 says recents come from
one indexed query, but `species_recent` lives in `user.db` and the names and silhouettes live in
`reference.db` — two files by design (§7, D-6). The honest reading is one indexed query per database
and no per-row lookup; T06 states it and tests it. If a reviewer wants the literal reading, the only
mechanism is `ATTACH`, and T06 records why that is rejected.

**5. Two emphasised actions in the S1 empty state.** `SPEC.md` §6 S1 says Browse and Identify are both
emphasised; `lonja-lists-and-tables/references/the-four-states.md` says an empty state carries exactly
one primary action and two is a defect. SPEC is authoritative for the product, and the skill's rule
binds a *list's* empty body — S1's empty state is the screen's, not a list's. T04 states this in full
rather than picking silently. If that reading is wrong, it belongs in `DECISIONS.md` as a tenth entry,
not in a task file.

**6. Golden lane inflation.** `the-four-states.md` specifies eleven lanes per list screen; `CONVENTIONS.md`
§6 caps the whole product at 4–6 screens × 6 locales × 2 themes on Linux CI. This epic contributes S1
as **one** screen and takes only the `en` and `ar` empty-state lanes, which `the-four-states.md` names
as the two reviewers skip. The sunlight and glove lanes for S1 belong to E19 and E20.

**7. The Identify route has no builder until E14.** T02 wires the action to the `/identify` path and
asserts the router location, not the screen. If E14 renames the path, one constant in
`app/lib/routing/routes.dart` changes.

## PR description

### What changed

- A five-destination Lonja navigation strip (`check, today, trips, reference, settings`), frozen as an
  enum, drawn as a ruled ledger strip, and a `StatefulShellRoute` that keeps each branch's navigator
  state.
- S1 — Check: zone chip to S9, content-currency chip to S23, a six-species Recents strip scoped to the
  active zone and ordered by frequency then recency, the search field, Browse by shape, Identify this
  fish, and the tally summary bar.
- The no-recents state, with the search field ready and deliberately unfocused.
- The no-jurisdiction state: the zone chip reads "Choose your area" and routes to S9. No error state.
- The launch path: nothing awaited before `runApp`, no asset decoding, no splash animation, both
  databases opened on their first query.
- An integration test that walks the whole core loop and reports the time it took.

### Why

`SPEC.md` §3 is the product: at 05:40 with a fish alive in the bin there are perhaps ten seconds before
returning it stops being worthwhile. Everything in this epic is downstream of that sentence — the
absence of a splash, the last-used zone already selected, the four paths one tap away, the primary
actions in the bottom third for a single wet-gloved thumb, and a search field that does not summon a
keyboard over the two actions a first-time user needs.

### How it was verified

- `flutter test` in `app/`, including widget tests for all four entry points and the two golden lanes
  of the empty state.
- Four gate scripts against `app/lib`, plus `tools/gates/no_directional_geometry.sh`.
- `flutter run --profile --trace-startup` on the reference device: `timeToFirstFrameRasterizedMicros`
  recorded here.
- `flutter test integration_test/five_second_loop_test.dart` in `en` and `ar`, with the measured
  elapsed time recorded here.

### Product invariants touched

- **1, no network:** nothing in this epic adds a dependency; the gate covers `app/lib` and every
  pubspec.
- **2, statement of fact:** the tally bar and both chips state facts. No imperative, in Dart or in any
  of the six ARB files.
- **4, colour is never the only signal:** the selected nav cell carries ground, rail, filled glyph and
  weight before colour; the currency chip changes its words as well as its hue.
- **5, stale beats absent:** the currency chip escalates and never blocks, and the unknown-check-date
  state is a statement, not an error.

### Follow-ups deliberately not in this PR

- The Today, Trips, Reference and Settings screens (E13, E15, E16) — four branches point at one named
  placeholder.
- The identification key behind `/identify` (E14).
- The sunlight and glove golden lanes for S1 (E19), and the six-locale golden matrix (E20).
- The on-device offline walkthrough of §14 (E21).

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start the next epic.
