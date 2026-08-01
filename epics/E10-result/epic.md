# E10 — The result screen

| | |
|---|---|
| **Branch** | `epic/10-result` |
| **After** | E08 and E09 merged |
| **Tasks** | 10 |
| **Spec** | `SPEC.md` §5.1 (all five points), §4.1, §4.7, §6 S2 and dialogs D3/D4, §7.3 (finding precedence), §5.3 (citations are selectable text) |
| **Package** | `app/` — `app/lib/ui/result/`, plus `app/lib/l10n/` and one repository in `app/lib/data/` |

## What this epic achieves

S2 stops being a species page with a ruler on it and becomes the screen the product exists to render.
A fisher picks a species, takes a measurement, and reads a statement of fact with the number he can
check against a printed instrument: *Below the minimum — 38 cm measured, minimum 45 cm (total
length)*, over a rule-facts table, over a citation naming the instrument, the article, the
publication date and the date a human last checked it, over a disclaimer that names the authority to
verify with and cannot be dismissed. Where two equally specific rules disagree, both are printed and
neither is chosen. Where the ruleset has lapsed, an ochre bar states the date and the rule is
evaluated anyway with its numbers intact. Nothing on the screen tells him what to do with the fish,
and nothing on the screen opens a browser.

After this merges, E12 can build S1 around a result that already works, and the §14 device checks
"tapping a citation expands S13 and copies to clipboard — no browser opens" and "set the device
clock past a rule's `valid_to`: the amber bar appears **and** that rule still produces a finding with
its numbers intact" have a screen to be executed against.

## Where we are now

The branch is cut from a `main` that already carries:

- `packages/rule_engine/` (E02, E03) — `normaliseSpeciesTerm`, and the §7.3 resolution pipeline
  returning sealed `Resolution` values: `Decided` (headline `RuleFinding` plus `secondary`),
  `Ambiguous`, `NoRuleFound`, `NoLimitInInstrument`. Every `RuleFinding` carries a non-nullable
  `Citation` and an `isExpired` flag, and `FindingKind` is the six-value precedence ladder. There is
  no user-visible sentence anywhere in the package (D-7).
- `tools/content_builder/` and `app/assets/db/reference.db.gz` (E04) — the Galicia seed, every
  `*_key` proven to resolve in all six locales, `content_change` emitted.
- `app/lib/data/` (E05) — the read-only reference database and the writable `user.db`, both opened
  lazily. `rule_flag` exists as a table with no writer.
- `app/lib/l10n/` (E06) — six ARB files (`ar`, `en`, `es`, `gl`, `ca`, `pt_BR` — D-3), the
  `content_string` resolver with the §9.2 fallback chain, the numeral-system lever, the RTL harness.
- `app/lib/theme/` (E07, D-2) — three themes including sunlight, glove density, the Lonja type ramp.
- `app/lib/ui/species/` (E08) — S5, S6 and the static half of S2: the species header, the silhouette
  and the look-alike card. The result half of S2 is an empty slot in `SpeciesDetailScreen`.
- `app/lib/ui/ruler/` (E09) — S3, S4, step-and-mark, and manual entry that works before calibration.
  A measurement reaches the result as integer millimetres plus a `MeasurementMethod`.

What does not exist: any verdict widget, any wording for a finding, the stale bar, the ambiguity
surface, the citation footnote, the disclaimer, the flag writer, and every `verdict*` / `finding*` /
`citation*` / `disclaimer*` ARB key.

## Why this epic exists here in the order

It cannot come earlier: the panel renders numbers the engine produces (E03), text the content
database holds (E04, E05), sentences the ARB carries in six locales (E06), type and semantic ink
from the Lonja ramp (E07), a species identity (E08) and a measurement (E09). `SPEC.md` §15 puts
"Result UI" at step 8 with dependencies *[2,6,7]* for exactly that reason.

It must not come later: `SPEC.md` §15 step 10 makes Check home depend on it, and step 10 is the
first point at which the five-second core loop is testable at all. E12, E13 (a catch record stores
`outcome_detail`, "the factual finding text as shown") and E17 (export carries the flags this epic
writes) all read what this epic defines.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | Verdict to display model | `T01-verdict-to-display-model.md` | M | — |
| T02 | The verdict panel | `T02-the-verdict-panel.md` | L | T01 |
| T03 | The findings list | `T03-the-findings-list.md` | M | T01, T02 |
| T04 | The rule-facts table and the measurement diagram | `T04-rule-facts-and-diagram.md` | M | T01 |
| T05 | The citation row | `T05-the-citation-row.md` | M | T01 |
| T06 | The stale bar, and D3 | `T06-the-stale-bar-and-d3.md` | M | T01, T02 |
| T07 | D4 — two rules, and no choice between them | `T07-d4-two-rules-no-choice.md` | M | T01, T05 |
| T08 | Flag this rule | `T08-flag-this-rule.md` | M | T01, T05 |
| T09 | The disclaimer that cannot be dismissed | `T09-the-disclaimer.md` | S | T01 |
| T10 | The verdict-contract gate, in six locales | `T10-verdict-contract-gate.md` | M | T01–T09 |

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once all ten have landed:

- [ ] All 10 tasks committed, one commit each, every `Task: E10/Tnn` trailer present.
- [ ] S2 renders all nine result states, each with its citation and the disclaimer: meets, below
      minimum, above maximum, closed season, protected, above bag limit, no rule recorded, no limit
      in instrument, ambiguous.
- [ ] Each of those nine renders again with the ruleset expired: the ochre bar appears, the finding
      text and every number beneath it are byte-identical to the fresh render, and no control is
      disabled. This is the widget-test half of the §14 expiry check.
- [ ] `check_verdict_contract.sh app/lib`, `check_lonja_verdict.sh app/lib`,
      `check_lonja_dialogs.sh app/lib`, `check_lonja_type.sh app/lib`, `check_lonja_tokens.sh
      app/lib` and `check_app_invariants.sh app/lib` are all clean, and each was confirmed to be
      scanning a non-empty tree (`CONVENTIONS.md` §7).
- [ ] `grep -rnE "launchUrl|url_launcher|AndroidIntent|ACTION_VIEW|Image\.network|SvgPicture\.network" app/lib/ui/result app/lib/ui/reference`
      returns nothing (§5.3, §14 static list).
- [ ] All six ARB files carry the same `verdict*` / `finding*` / `citation*` / `disclaimer*` key set,
      every number a placeholder, every `@description` opening `STATEMENT OF FACT.`
- [ ] The result is announced as one live region, and the four verdict signal sets are mutually
      distinguishable from glyph, headline and the presence or absence of the measurement sub-line
      alone — asserted structurally here; proved in pixels by E19's greyscale golden.
- [ ] Line coverage on `app/lib/ui/result/` is ≥ 80% excluding generated code (`CONVENTIONS.md` §6).
- [ ] PR checks all SUCCESS; merged with `--squash --admin`; branch deleted.

## Risks and the things that will bite

**1. `@description` blocks in non-template ARB files.** `check_verdict_contract.sh` check 6b requires
the literal string `STATEMENT OF FACT` in *every* ARB that holds a `verdict*` or `finding*` key, and
no ARB value is ever exemptible. Standard gen-l10n practice puts `@key` metadata only in the
template. The plan (T10) is to mirror the `@key` description blocks into all six files, because
`gen-l10n` reads placeholder metadata from the template and skips `@`-prefixed keys elsewhere.
**This is asserted, not verified in this session.** What resolves it: run `flutter gen-l10n` then
`flutter analyze` after the first mirrored file lands. If gen-l10n rejects it, the fallback is one
top-level `"@@x-verdict-constraint"` global attribute per file carrying the same sentence.

**2. S13 does not exist until E15.** §4.6 and the §14 device list both require that tapping a
citation expands the bundled verbatim text. E10 therefore ships a minimal rule-text destination
(T05): one indexed query on `legal_text` by `citation_id`, the body verbatim in the serif at the
legal measure, the citation header and the checked-on date. Full-text search, article navigation and
the §9.6 language-availability notice are E15's. The risk is two readers coexisting; the mitigation
is that the route name is registered exactly once and the file carries a `///` naming E15 as the
owner that replaces it.

**3. The haptic patterns have no number in `SPEC.md`.** §4.9 requires only "distinct patterns for
pass and fail". T02 fixes a concrete pattern; whether it is distinguishable through a wet glove is
unknown until a device is in hand. What resolves it: E19's haptics task and the E21 device pass. Do
not tune it by feel in the simulator.

**4. `liveRegion: true` re-announces on every semantics update.** A ruler that emits at several
frames a second could make TalkBack read the verdict continuously. Mitigation in T02: the panel
watches a `select`-narrowed display model, and a test asserts the semantics label is emitted once
across a rebuild carrying an identical model. If the announcement still repeats on device, the fix
is to gate the live region on a changed verdict, never to remove it.

**5. `VerdictCategory` has four values; `FindingKind` has six.** Resolved in T01 by making the
category select the *signal set* and the finding kind select the *sentence*. Recorded here because
the tempting shortcut — mapping a `maxSize` failure onto `.belowMinimum` and letting the headline
follow — prints "Below the minimum" over a 122 cm fish that failed a slot rule. If E03's
`Resolution` already carries a category, use it; never re-derive one from `measuredCm` or a date.

**6. The Gulf authority strings are not in the seed.** §4.7's disclaimer names the authority per
jurisdiction, resolved from `jurisdiction.authority_key` through `content_string`. E04 seeded
Galicia (Consellería do Mar). T09's other-jurisdiction cases therefore run against fixtures, not
against shipped content, until E22 authors them. The content build already fails on a missing
`*_key` in any locale (§8), so this is a coverage gap in the tests, not a runtime hazard.

## PR description

### What changed

S2 is complete. `app/lib/ui/result/` renders the result half of the species detail screen: a display
model assembled from ARB, `content_string` and the engine's numbers; the verdict stamp struck
between double rules and announced as a live region; the secondary findings in §7.3 precedence
order; the rule-facts table and the measurement diagram taken from the active jurisdiction's rule
row; the citation footnote with copy-to-clipboard and an in-app rule-text route; the non-blocking
ochre stale bar; the D4 ambiguity surface that prints both rules and picks neither; a local rule
flag written to `user.db`; and the non-dismissable disclaimer naming the authority to verify with.
All four verdict-shaped ARB key families exist in six locales with constraint-carrying descriptions,
and the wording contract is swept by a blocking test.

### Why

`SPEC.md` §5.1 argues the legal-advice carve-out in five parts, and four of the five are structural
properties of this screen: the output states a fact, every finding carries its citation, genuine
ambiguity is shown rather than resolved, and a non-dismissable disclaimer names the authority. §4.7
adds the fifth thing this screen owns — an expired rule is still evaluated and still shown, because
a stale rule beats no rule at sea. None of those are cosmetic and none of them fail loudly at
runtime, which is why they are enforced by gates and tests rather than by review.

### How it was verified

Every task's tests were written first and failed first. Nine result states are pumped fresh and
expired and asserted identical below the bar. Six locales are swept for imperatives, second person,
inference, health claims and softened absence, including an Arabic substring pass no
English-language grep can see. Six gate scripts run clean over `app/lib`. Coverage on
`app/lib/ui/result/` is ≥ 80% excluding generated code.

### Product invariants touched

All five (`CONVENTIONS.md` §9). Invariant 1: no network symbol on the result path, and the citation
row deliberately does not hand a URL to a browser. Invariant 2: every string on this screen is a
statement of fact. Invariant 3: `Citation` is required and non-null on every display type that
carries a finding. Invariant 4: glyph plus word plus hue on every state, with protected separated
from below-minimum by mark, wording and table shape. Invariant 5: expiry sets a flag and adds a bar;
it never returns early, disables a control or shows an error screen.

### Follow-ups deliberately not in this PR

- The greyscale, sunlight and RTL goldens of the result screen — E19 and E20 own the lanes.
- The full S13 rule-text reader with Arabic FTS and the §9.6 language notice — E15.
- Exporting the rule flags written here — E17.
- "+ Add to today", which needs the catch log — E13.
- Device haptics tuning and the §14 packet capture — E19 and E21.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task, in
order; `gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start E11.
