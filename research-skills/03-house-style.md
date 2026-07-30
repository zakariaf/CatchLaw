# House Style of `Flutter-Claude-Code-Skills`

**Extracted:** 2026-07-30 · **Source of truth:** `/Users/zakariafatahi/50-apps-challenge/Flutter-Claude-Code-Skills`
at git `bbaeda0` ("docs: correct slug casing to canonical Flutter-Skills").
**Corpus measured:** 33 `SKILL.md`, 67 `references/*.md`, 39 `scripts/*.sh`, 33 `examples/*`.
**Tooling verified on disk:** `claude` v2.1.220; `claude plugin validate <path> [--strict]` exists
(`--strict` = "Treat warnings as errors (exit 1)… unrecognized fields, missing metadata").

Every number below was **measured** from the files, not estimated. Where CONTRIBUTING.md's stated
rule and the actual corpus disagree, both are given and the divergence is flagged **[DIVERGENCE]**.

---

## 0. Facts you must not get wrong

| Fact | Verified value | Evidence |
|---|---|---|
| Frontmatter fields used **anywhere** in the 33 skills | exactly three: `name`, `description`, `disable-model-invocation` | parsed all 33 frontmatters |
| Skills using `disable-model-invocation: true` | 2 — `run-codegen`, `run-migration` | parsed frontmatter |
| Directory name == frontmatter `name` | true in 33/33 | CONTRIBUTING.md §"Skill format" + verified |
| `description` char length | min 611 (`flutter-performance`), max 998 (`design-system-structure`), **mean 870, median 902** | measured |
| Stated cap | truncated at **1,536 chars**; working cap **~1000** | CONTRIBUTING.md lines 80–81 |
| `SKILL.md` total lines | min 131, max 332, **mean 214, median 213**; stated target ≤ ~320 | measured; CONTRIBUTING.md line 82 |
| Non-negotiable rules per skill | min 6, max 16, **mean 10.9, median 11** | measured (359 rules total) |
| Anti-pattern bullets per skill | min 5, max 13, **mean 10, median 10** | measured |
| Definition-of-done items per skill | min 4, max 13, **mean 8, median 9** | measured |
| `references/*.md` line count | min 35, max 237, **median ~108** | measured (67 files) |
| `examples/*.dart` line count | min 46, max 229, median ~100 | measured |
| `scripts/*.sh` line count | min 21, max 129, median ~61 | measured (39 files) |
| Shebang | `#!/usr/bin/env bash` in **39/39** | measured |
| `set` line | `set -euo pipefail` in **36/39**; `set -uo pipefail` in 3 | measured |
| Script file mode | `755` on all 39 | `stat -f %A` |
| `${CLAUDE_SKILL_DIR}` | **CONTRIBUTING.md line 97 mandates it; ZERO skills actually use it** — every SKILL.md writes bare `scripts/<name>.sh` | grep — **[DIVERGENCE]** |

**Anti-fabrication note.** There is no `when_to_use`, `allowed-tools`, `license`, `version`, `model`,
or `tags` field in this repo's skills. CONTRIBUTING.md line 80 *mentions* an "optional `when_to_use`"
as part of the truncation budget, but **no skill in the corpus uses it**. Do not add it.
CONTRIBUTING.md line 85: *"Do not add other frontmatter fields."*

---

## 1. The blank `SKILL.md` template (house style)

Copy this verbatim; replace every `‹…›`. Ordering of `##` headings is fixed — verified identical in
33/33 skills for the four terminal sections (`Anti-patterns` → `Definition of done` →
`Related skills` → `References`).

````markdown
---
name: ‹kebab-case-name, MUST equal the directory name›
description: ‹ONE sentence, third person, no subject. Opens with "Enforces " (25/33). Lists the
  concrete mechanisms/APIs/symbols it governs, em-dash- or colon-introduced, comma-chained. Then a
  second sentence beginning exactly "Use when " listing 5–8 concrete trigger situations, comma-
  chained, last item joined with "or ". Ends with a period. Target 850–950 chars; hard ceiling 1000.›
---

# ‹Title Case name, or the kebab name verbatim — both occur; see §1.1›

‹ONE paragraph, 250–550 chars (median 373). Sentence 1 = the philosophy/thesis in a memorable,
opinionated form (often a definition: "A design system is code that is *incapable of holding a stray
opinion*"). Sentence 2–3 = what this skill owns and, critically, what it does NOT own. Final clause =
scope trigger, usually "Applies to ‹surface›." Bold the load-bearing phrase.›

‹RICH SKILLS ONLY — omit for a single-file skill. Verbatim lead line:›
Read the reference for the task at hand:
- `references/‹topic-a›.md` — ‹comma-separated list of the 4–6 subtopics inside, lowercase, no period›.
- `references/‹topic-b›.md` — ‹…›.
- `references/‹topic-c›.md` — ‹…›.

‹RICH SKILLS ONLY — verbatim shape:›
Run `scripts/‹check-a›.sh` and `scripts/‹check-b›.sh` before a PR.

‹OPTIONAL boundary sentence, 1–2 lines: "‹Neighbouring concern› lives in `‹other-skill›`; this skill
governs ‹the remainder›." Used to pre-empt overlap.›

## Non-negotiable rules

‹A numbered list of 9–12 rules (median 11). Each rule = a bolded imperative lead clause in `**…**`
(median 54 chars), then 1–3 sentences of mechanism with real API names in backticks, then the
rationale. See §3 for the full rule formula.›

1. **‹Bolded imperative claim.›** ‹Mechanism, with real symbols.› ‹Rationale — why it bites.›
2. …

## ‹Topic section 1 — a verb-led or noun-led title naming the mechanism›

‹The "how". 1 short prose paragraph + ONE fenced ```dart block ≤ 30 lines, in a NEUTRAL generic
domain (Note/Task/Product/Account/Order/Item/Reminder). Wrong/Right pairs are commented inline as
`// WRONG — …` / `// RIGHT — …`. Close with a pointer: "Full worked file: `examples/‹x›.dart`."›

## ‹Topic section 2›
## ‹Topic section 3›
‹4–8 topic sections total (median 6). These are the only free-form headings.›

## Anti-patterns

‹5–13 bullets (median 10). Two accepted bullet shapes — pick one and keep it consistent within the
file:
  A) `- **\`the thing\`** — the consequence, in one clause.`     (widget-composition style)
  B) `- \`the thing\` — the consequence.`                        (i18n-rtl-l10n style)
Every bullet names a CONCRETE construct (a symbol, a call, a file shape) and then the failure it
causes. Never a vague "don't be sloppy".›

- **‹`Concrete.construct()` or a named shape›** — ‹the specific way it bites›.

## Definition of done

‹A reviewer-tickable checklist, 4–13 items (median 9). Two accepted shapes:
  A) `- [ ] ‹assertion› (rule N).`   — checkbox + a back-reference to the rule number. Preferred:
     20/33 skills use `- [ ]`; the rule back-reference `(rule N)` appears in the strongest skills
     (custom-canvas-and-gestures, flutter-conventions-index, design-system-structure).
  B) plain `- ‹assertion›` bullets (adaptive-layout, forms-and-input, navigation-and-routing).
The FIRST item of a rich skill is almost always "`scripts/‹x›.sh` is clean over `lib/`".›

- [ ] `scripts/‹check›.sh` is clean over `lib/`.
- [ ] ‹Observable, binary assertion› (rule ‹N›).

## Related skills

‹4–11 bullets (median 7). Two accepted phrasings, see §6. Pick ONE per file.
Every named skill must exist. Each bullet says WHY the sibling matters here, not just that it exists.›

- See `‹sibling-skill›` for ‹the specific thing it owns that this skill leans on›.

## References

‹4–10 bullets. Official docs only: api.flutter.dev, docs.flutter.dev, dart.dev, riverpod.dev,
pub.dev, m3.material.io, w3.org/WAI. Shape: `- ‹Source› — \`Symbol\`: ‹url›` or `- ‹Label›: ‹url›`.
Bare URLs, not markdown links, in 32/33 (naming-conventions is the one exception).›

- ‹Flutter API — `Symbol`›: https://api.flutter.dev/…
````

### 1.1 Divergences to be aware of when choosing

| Choice | Majority behaviour | Minority (still valid) |
|---|---|---|
| H1 | Title Case, human-readable (`Widget Composition`, `i18n, RTL & Localization`) — 32/33 | `design-system-structure` uses the kebab name verbatim |
| "WHY:" label in rules | **absent** — 29/33 skills fold the rationale into an em-dash or trailing sentence | 4/33 (`adaptive-layout`, `design-system-structure`, `flutter-conventions-index`, `service-boundary-and-native`) use a literal `WHY:` on ~every rule. CONTRIBUTING.md line 72 says "each rule + a terse WHY" — the *concept* is mandatory, the *literal token* is not |
| Line wrapping | 22/33 write long unwrapped markdown lines (p90 ≈ 220 chars) | 11/33 hard-wrap at ~100 cols (`testing-strategy`, `i18n-rtl-l10n`, `run-migration`, `value-objects-money-and-units`, `widget-golden-and-a11y-testing`, `lint-and-style-config`, `flutter-architecture`, `scaffold-feature-module`, `codegen-and-toolchain`, `run-codegen`). Either is accepted; **be consistent within a file** |
| Extra trailing section | — | 5 skills append `## Provider / ChangeNotifier appendix` AFTER `References` or between `Related skills` and `References` (`app-startup-and-bootstrap`, `flutter-architecture`, `scaffold-feature-module`, `service-boundary-and-native`, `state-management-riverpod`) — mandated by CONTRIBUTING.md house convention 1 for state/architecture skills |
| `## When multi-package (workspace)` | — | 6 skills fence monorepo guidance under this exact heading (CONTRIBUTING.md house convention 2) |

---

## 2. The DESCRIPTION FORMULA

### 2.1 Measured anatomy (all 33 descriptions)

| Metric | Value |
|---|---|
| Total length | 611–998 chars; **mean 870, median 902**; ~106 words |
| Sentence count | 2 (a "what it enforces" sentence + a "Use when" sentence) |
| Contains literal `Use when ` | **32/33** (only `flutter-conventions-index` omits it — it opens `Use at the start of any Flutter/Dart work`) |
| Position of `Use when` | starts at **47%–84%** of the string; **mean 68%, median 68%** |
| Pre-`Use when` half | 319–809 chars, **median 629** |
| `Use when` clause | 0–482 chars, **median 273** |
| Trigger items in the `Use when` clause | 0–13 commas, **mean 6.4, median 6** |
| Opening verb | **`Enforces` 25/33**. Others: `Runs` ×2 (both `disable-model-invocation` runbooks), `Governs` ×1 (`persistence-drift`), `Structures` ×1 (`design-system-structure`), `Stands` ×1, `Wires` ×1, `The` ×1 (`flutter-conventions-index`, the index skill) |
| Symbol/identifier tokens per description | **mean 16.4** (range 4–27) → roughly **1 concrete symbol every 6–7 words** |
| Em dash `—` present | 21/33 |
| Backticks present | 6/33 — **descriptions are mostly backtick-free plain prose**; symbols are written bare (`AutovalidateMode.onUserInteraction`, not `` `AutovalidateMode.onUserInteraction` ``) |
| Ends with `.` | 32/33 |
| Ends the `Use when` clause with `…or reviewing ‹surface›.` | 13/33 |

### 2.2 The fill-in-the-blank formula

```
‹VERB› ‹the ONE-PHRASE THESIS of the discipline›‹ — | : | (nothing)›
  ‹mechanism 1 with its real API symbol›,
  ‹mechanism 2›,
  ‹mechanism 3›,
  … ‹6–12 mechanisms, comma-chained, "and" before the last›.
Use when ‹trigger 1: a verb + the artefact›,
  ‹trigger 2›,
  ‹trigger 3›,
  … ‹5–8 triggers›,
  or ‹final trigger, usually "reviewing ‹surface› in a diff"›.
```

Concretely:

- **VERB** = `Enforces` unless the skill is (a) a manual runbook → `Runs`, (b) a whole-layer owner →
  `Governs`, (c) a structural organiser → `Structures`, (d) the index → a noun phrase.
- **THESIS** ends with `—` when what follows is a list of *mechanisms*, or with `:` when what follows
  is a named *contract* (`Enforces the gen-l10n/ARB localization contract:`).
- **Mechanism list**: pack the exact identifiers a matching task would type. Aim for
  **~16 symbol tokens** total. Symbols go in bare (no backticks). Bad: "manages state properly".
  Good: `AutovalidateMode.onUserInteraction`, `NativeDatabase.memory`, `MediaQuery.sizeOf`,
  `EdgeInsetsDirectional`, `shouldRepaint`, `--delete-conflicting-outputs`.
- **`Use when`** starts at ~68% of the string. Each trigger is `‹gerund verb› ‹concrete artefact›`:
  *adding*, *building*, *writing*, *wiring*, *choosing*, *editing*, *reviewing*, *fixing*, *touching*.
- **Named-file triggers matter.** `i18n-rtl-l10n` ends with `or touching app_*.arb`; `forms-and-input`
  names `TextFormField`, `FocusNode`, `onFieldSubmitted`. Filenames and symbol names are the highest-
  signal triggers in the corpus.
- **Boundary hand-off** (optional last sentence, seen in `persistence-drift`):
  `Migrations and their tests live in run-migration.` — disambiguates against a sibling skill.

### 2.3 Eight real descriptions, as measured

1. **`flutter-performance` (611 ch — the shortest, a good floor)**
   > Enforces Flutter runtime performance — const subtrees, minimal rebuild scope via
   > ref.watch(select), lazy ListView/GridView builders and slivers, sized image decode
   > (cacheWidth/ResizeImage), heavy work off the UI isolate via compute/Isolate, surgical
   > RepaintBoundary, dispose everything, and measurement in profile mode on a floor device. **Use
   > when** optimizing UI, diagnosing jank or dropped frames, tuning long lists or images, reviewing
   > rebuild/repaint scope, **or when the task mentions** const, select, ListView.builder, cacheWidth,
   > compute, RepaintBoundary, AnimatedBuilder, DevTools, raster thread, or 60/120fps.

   *Note the `or when the task mentions ‹bare keyword list›` tail — a legitimate variant (2/33) for
   packing extra trigger nouns cheaply.*

2. **`naming-conventions` (642 ch)** — `Enforces` + parenthetical rule-set + `so ‹the payoff›` + a
   long ban list (`no get-prefix, no Hungarian, no SCREAMING_CAPS`). `Use when creating a file,
   naming a class/enum/mixin/…/parameter, organizing imports, choosing a role suffix, or reviewing a
   diff for naming and directive ordering.` — note the **slash-chained enumeration** to pack 10
   trigger nouns into one comma slot.

3. **`design-review-workflow` (665 ch)** — `Enforces one structured end-of-build design/QA pass —
   never per-task — on the release build: ‹matrix› … and a dated sign-off artifact that gates
   release.` Shows the **`— never X —` interjection** used to kill the most likely misuse inside the
   description itself.

4. **`testing-strategy` (891 ch)** — `Enforces test doctrine where shape follows code not the
   pyramid:` then **semicolon-chained** clauses (not commas) because each clause is itself long.
   Ends `…or triaging a flaky-suite failure.`

5. **`run-migration` (924 ch, `disable-model-invocation: true`)** — opens `Runs the forward-only
   Drift/SQLite schema-migration ritual — **the most dangerous deterministic operation in an
   offline-first app: a bad migration silently destroys on-device rows that exist nowhere else.**`
   → for a destructive runbook, the description states the **stakes** before the mechanism, and
   inserts a bare sentence `Manual, side-effecting workflow.` before `Use when`.

6. **`value-objects-money-and-units` (950 ch)** — `Enforces a pure-Dart value-object core that
   stores every quantity canonically … and converts only at the presentation edge; **forbids**
   double/num money, cross-currency arithmetic, …; **routes** every division … ; **derives** totals
   …` → parallel third-person verbs (`stores`/`forbids`/`routes`/`derives`) as the list spine.
   Its `Use when` ends by naming **bug classes**: `or fixing float-money, hardcoded-100,
   cross-currency, off-by-a-cent, or stored-total-drift bugs.`

7. **`widget-composition` (970 ch)** — one of only 6 with backticks (`` `Widget _buildX()` ``,
   `` `.builder` ``). `Use when building or refactoring any screen or widget, splitting a large
   build() into components, writing GridView/ListView/LayoutBuilder/SafeArea/Scaffold, wiring
   onTap/onLongPress/Draggable, choosing a key or data class, or reviewing widget code in a diff.`

8. **`custom-canvas-and-gestures` (992 ch — near the ceiling)** — 21 symbol tokens. Uses **caps for
   emphasis** inside the description (`one shared affine transform read by BOTH painter and
   hit-tester`) — a recurring house tic (also `EVERY await`, `ONLY`, `LAST`, `NEVER`).

9. **`design-system-structure` (998 ch — the measured maximum)** — begins `Structures a Flutter
   design system as tokens→theme→modifiers→shapes …` (arrow notation for a pipeline is house style)
   and closes `…or reviewing any widget that renders a color, radius, duration, or font.`

### 2.4 Description QA checklist

- [ ] 850–950 chars (measure it; hard stop at 1000).
- [ ] Opens with a third-person verb, no subject, no "This skill…".
- [ ] `Use when ` appears at 60–75% of the string.
- [ ] ≥ 12 concrete symbol/filename tokens in the first half.
- [ ] 5–8 comma-chained triggers, last joined with `or `.
- [ ] Names at least one **filename or file glob** the task would touch.
- [ ] No backticks (unless you have a strong reason — only 6/33 use them).
- [ ] Ends with a period.

---

## 3. The RULE FORMULA (`## Non-negotiable rules`)

### 3.1 Measured

| Metric | Value |
|---|---|
| Rules per skill | 6–16, **median 11** |
| Rule length | 43–828 chars, **mean 307, median 288** (≈ 41 words) |
| Starts with a bolded lead `**…**` | **358 / 359** |
| Bolded lead length | 14–179 chars, **median 54** |
| Contains literal `WHY:` | 45/359 (13%), concentrated in 4 skills |
| When `WHY:` is used, its position | 42%–82% through the rule, **median 67%** — i.e. it is the **last clause**, 42/45 |
| `WHY:` clause length | 45–177 chars, **median 87** — one sentence, no period-chained follow-up |
| Contains an em dash `—` | ~190/359 (the rationale delimiter when `WHY:` is absent) |
| Ends with an italic sibling cross-ref `*(\`skill\`)*` | 14 rules, all in `flutter-conventions-index` |

### 3.2 The formula

```
N. **‹Imperative claim, ~54 chars, ending in a period INSIDE the bold›**
   ‹Mechanism sentence: the exact API/symbol/file, plus the banned alternative,
    written as "never X", "not X", or "— never X".›
   ‹Rationale: EITHER "WHY: ‹one sentence, ~87 chars, no period-chain›."
              OR an em-dash clause / trailing sentence delivering the same thing.›
   ‹Optional: "(‹owning-skill›)" or "*(\`skill-a\`, \`skill-b\`)*" when another skill owns the depth.›
```

Rules of the rule:

1. **The bold lead is a claim, not a topic.** `**Widgets are dumb.**` — not `**Widgets**`.
2. **The rationale is always consequence-shaped**, i.e. it names the failure mode:
   *"a fallback silently ships a theme no test verified"*, *"a dropped `Future` swallows errors no
   lint catches"*, *"rank scales have no room to insert and lie in dark mode"*. Never "it's cleaner".
3. **Emphatic CAPS** on the pivotal word: `NEVER`, `EVERY`, `ONLY`, `BOTH`, `LAST`, `OUT`.
4. **State a rule once.** CONTRIBUTING.md line 116: *"it doesn't restate a rule another skill already
   owns — state it once, cross-reference it elsewhere."* The corpus does this explicitly inside rules,
   e.g. design-system-structure rule 7: *"The never-color-alone floor itself … is owned by
   `accessibility-as-code`; this skill only enforces that the color reinforcing them is a derived slot."*
5. **Gate-backed rules name their script**: *"…fails `scripts/check_raw_values.sh`"*.
6. Numbers/limits are **not** restated — CONTRIBUTING.md line 53: complexity numbers live only in
   `dart3-idioms-and-coding-standards`; other skills cite that table.

### 3.3 Four real rules, of four different kinds

**(a) A short definitional rule — `naming-conventions` #1 (193 ch, no `WHY:`, rationale as a trailing sentence):**
> 1. **Types are `UpperCamelCase`.** Classes, enums, mixins, extensions, typedefs, type parameters:
>    `TaskScreen`, `OrderStatus`, `Predicate<T>`. Consistent shape makes types visually distinct from values.

**(b) A mechanism rule with a mechanism-level explanation — `widget-composition` #1 (no `WHY:`, the
rationale IS the mechanism):**
> 1. **Extract a `Widget` class, never a `Widget`-returning method.** `Widget _buildHeader()` is
>    *not* a widget — its subtree has no `Element` of its own, so `Element.updateChild` never gets
>    to compare old vs. new and short-circuit; it rebuilds with the parent, cannot be `const`,
>    cannot take a `Key`, and `find.byType` cannot reach it in a test.

**(c) A gate-backed rule with an explicit `WHY:` — `design-system-structure` #2:**
> 2. **Two token tiers; widgets read only the semantic tier.** Tier 1 = primitives named by the
>    **measured value** (`neutral12` = OKLCH lightness ×100), never by rank (`grey700`), appearance
>    (`darkGrey`), or brand (`brandPrimary`). Tier 2 = semantic slots named by role (`surface`,
>    `onSurface`, `hairline`, `accent`). A widget that reaches a Tier-1 primitive has hardcoded one
>    theme. **WHY:** rank scales have no room to insert and lie in dark mode; appearance names invert
>    catastrophically; brand names die with the brand.

**(d) A cross-cutting rule with `WHY:` + an italic skill cross-ref — `flutter-conventions-index` #9:**
> 9. **Async is never silent.** `await` everything or handle the `Future` explicitly; no
>    fire-and-forget arrow callbacks. Guard `BuildContext`/`mounted` after every `await`; dispose
>    controllers, subscriptions, timers, and sinks. **WHY:** a dropped `Future` swallows errors no
>    lint catches. *(`async-safety`)*

**(e) Bonus — a boundary/deference rule, `design-system-structure` #12** (shows how a new skill
should hand a concern back to an owner):
> 12. **The reduced-motion flag is read from `MediaQuery` (`disableAnimationsOf`), never app state**
>     — it feeds `resolveMotion` (this skill's helper, below). Reading the *other* platform a11y flags
>     (`boldTextOf`, `highContrastOf`, `textScaler`) from `MediaQuery` rather than a stale app-state
>     copy is owned by `accessibility-as-code`.

### 3.4 Recommendation for new skills

Use the **literal `WHY:` form**. It is the CONTRIBUTING-blessed shape (line 72), it is what the four
strongest/most-referenced skills do (including the index), and it forces you to actually write the
consequence. Target: bold lead ≤ 60 chars, whole rule 250–350 chars, `WHY:` as the final clause at
~85–100 chars.

---

## 4. The SCRIPT CONVENTION

Read: all 39 `skills/*/scripts/*.sh`.

### 4.1 Measured skeleton

| Element | Convention | Count |
|---|---|---|
| Shebang | `#!/usr/bin/env bash` | 39/39 |
| Strict mode | `set -euo pipefail` | 36/39 (3 use `set -uo pipefail` — deliberately, so accumulating greps that return 1 don't abort: `check-codegen-hygiene.sh`, `check-softdelete-parity.sh`, `verify_feature.sh`) |
| Position of `set` | Either **line 2** (before the comment block) — 16 files — or **after** the usage/comment block — 23 files. Both fine; the header comment is what must be present | 39/39 have both |
| `# Usage:` line | present in 39/39, in the top comment block | 39/39 |
| Arg 1 | a target directory, defaulted with `"${1:-lib}"` (or `lib/`, `lib/features`, `test`, a manifest path) | 34/39 |
| Missing-dir handling | `[ ! -d "$TARGET" ]` guard, then either `exit 0` with a `note:`/`SKIP:` line (benign) or `exit 2` with a `usage`/`FAIL` line (misuse) | ~30/39 |
| Exit codes | `0` = pass/nothing to scan (17 sites) · `1` = violation found (20 sites) · `2` = bad usage / target not found (21 sites) | measured |
| Executable bit | `755` | 39/39 |
| App paths | **never hardcoded** — several scripts say so in the header (`"Hardcodes no app-specific paths"`) | CONTRIBUTING.md line 96 |
| Filename style | **mixed**: 19 hyphenated (`check-widget-composition.sh`), 20 underscored (`check_raw_values.sh`). Convention is **per-skill consistent**, not repo-wide | measured |
| Naming verbs | `check-*` / `check_*` (25), `verify-*` (3), `run_*`/`regen`/`analyze`/`audit` (5), `ban-*`/`banned-*` (2), `*-gates` (2), `scaffold_*` (1) | measured |
| bash 3.2 (macOS) portability | called out explicitly in 2 headers ("Portable to bash 3.2 (macOS default): no mapfile"); one script *does* use `mapfile` (`check-scheduler-purity.sh`) | grep |

### 4.2 Output vocabulary (measured across the 39)

- Section banner: `echo "== ‹what› =="` (15 files) or `echo "==> ‹what›"` (9 files)
- Per-check verdicts: `FAIL` (21 files), `OK:` (13), `PASS` (9), `WARN` (5), `SKIP` (6), `✗` (2)
- Helper functions, the canonical trio (`check-persistence-bans.sh`):
  ```bash
  bad()  { echo "FAIL  $1"; fail=1; }
  warn() { echo "WARN  $1"; }
  pass() { echo "PASS  $1"; }
  ```
- Accumulator idiom: **never fail fast on the first hit** — set `fail=1` and keep scanning, then fail
  once at the bottom with the whole list. Stated explicitly in `banned-strings.sh`:
  *"ACCUMULATES every offender, and fails ONCE with the full list."*
- Every grep is `|| true`-suffixed so `set -e` doesn't kill the run on a clean check.
- Generated files are always exempted: `*.g.dart`, `*.freezed.dart`, `*.drift.dart`, `*.gr.dart`,
  `app_localizations*.dart`.
- Optional-toolchain guard: `if ! command -v flutter >/dev/null 2>&1; then echo "note — flutter not
  on PATH; skipping analyze"; exit 0; fi`
- Suppression escape hatch, when one exists, is a **trailing line comment** documented in the header,
  e.g. `// adaptive-ok`, `// ignore: swallowed_catch`. Never a config file.

### 4.3 Reusable blank script template

```bash
#!/usr/bin/env bash
set -euo pipefail
# ‹script-name›.sh — ‹one line: what invariant this proves›.
# Usage: scripts/‹script-name›.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# ‹2–5 lines: why this gate exists, i.e. the silent failure it catches. Say what it
# does NOT do ("Heuristic greps, not a compiler", "Not exhaustive — passing this is a
# floor, not proof"). Name the escape hatch if there is one, and say nothing else is exempt.›
#
# Checks:
#   1. ‹check one›
#   2. ‹check two›
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "‹script-name›: target dir '$TARGET' not found" >&2
  exit 2
fi

GEN_RE='\.g\.dart$|\.freezed\.dart$|\.drift\.dart$|\.gr\.dart$'

fail=0
report() {                       # report <label> <grep-output>
  local label="$1" hits="$2"
  if [ -n "$hits" ]; then
    echo "✗ $label"
    echo "$hits" | sed 's/^/    /'
    fail=1
  fi
}

echo "== ‹script-name› @ $TARGET =="

# 1. ‹what this needle proves, and the fix in one clause›
report "‹short label› (‹the fix›)" \
  "$(grep -rnE '‹pattern›' --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)"

# 2. ‹…›
report "‹short label› (‹the fix›)" \
  "$(grep -rnE '‹pattern›' --include='*.dart' "$TARGET" || true)"

echo
if [ "$fail" -ne 0 ]; then
  echo "‹script-name›: FAIL — review the hits above." >&2
  exit 1
fi
echo "‹script-name›: OK ($TARGET)"
```

Generator scripts (`scaffold_feature.sh` is the only one) differ: they validate argc
(`if [[ $# -lt 1 || $# -gt 2 ]]; then echo "usage: $(basename "$0") <feature-name-snake> [lib-dir]" >&2; exit 2; fi`),
validate the arg shape with a regex (`^[a-z][a-z0-9_]*$`), refuse to overwrite (`if [[ -e "$DEST" ]]
… exit 1`), emit files via `cat > … <<EOF` heredocs whose content is itself commented with the
house rules, and **finish by printing the manual steps they cannot do**.

Pre-PR check (README + CONTRIBUTING): `find skills -name '*.sh' -print0 | xargs -0 -n1 bash -n`.

---

## 5. REFERENCE and EXAMPLE conventions

### 5.1 `references/<topic>.md`

- **Count:** 2–4 per rich skill (median 3). Exactly one directory level deep. No sub-folders.
- **Length:** 35–237 lines, **median ~108**. The five longest (>180) belong to the skills that
  deliberately hold a table-heavy catalogue (`a11y-guidelines-and-limits.md` 237,
  `result-failure-spine.md` 204, `state-di-riverpod.md` 199).
- **Filename:** kebab-case, **topic-shaped and A-and-B-joined**: `token-tiers-and-themeextension.md`,
  `gestures-and-semantics.md`, `numerals-and-calendars.md`, `coverage-and-budget.md`,
  `commit-vs-gitignore.md`. Never `details.md` / `advanced.md`.
- **Opening, verbatim shape (3/3 sampled identical):**
  ```markdown
  # ‹Title Case topic›‹ — deep dive›            ← the "— deep dive" suffix is optional (used by 1 of 3 sampled)

  ‹One-sentence framing: which half of the skill this is and what question it answers.›

  ## ‹First mechanism›
  ```
- **Tables are the dominant device.** Every sampled reference opens its first section with a
  3–5-column markdown table (`| Naming style | Example | Why it rots |`,
  `| Collaborator | Responsibility | Forbidden to hold |`, `| Layer | Runner | Binding | Doubles |
  Key teardown |`). The rightmost column is always the *consequence* / *why*.
- References are **pointed to from the SKILL.md intro block**, never orphaned.

### 5.2 `examples/<name>.dart`

- **Count:** 2–3 per rich skill. **Length:** 46–229 lines, median ~100.
- **Filename:** `lower_snake_case.dart`, named after the thing demonstrated
  (`scene_painter.dart`, `typed_result_boundary.dart`, `status_encoding.dart`, `task_form.dart`).
  Non-Dart examples keep their real name (`build.yaml`, `analysis_options.yaml`,
  `gitattributes.example`).
- **Mandatory header comment** (CONTRIBUTING.md line 94: *"open each with a `//` comment stating
  what it demonstrates"*). Verified in 33/33. The measured shape is a **3–6-line `//` block**, never
  a `///` docstring, immediately before the first `import`:
  ```dart
  // Demonstrates ‹the pattern›: ‹clause 1›, ‹clause 2›, ‹clause 3›, and ‹clause 4›.
  // ‹Optional line: the critical gotcha, in caps where it matters.›
  // Generic domain: ‹Note|Task|Product|Account|Order|Item|Reminder›.
  // Conceptually compiles against ‹flutter | flutter + flutter_riverpod | …›.

  import 'package:flutter/material.dart';
  ```
- **Opening verb:** `// Demonstrates …` is the majority; `// Shows: …` (adaptive-layout ×2) and
  `// Demonstrates: …` (dart3-idioms ×3, i18n ×2) also occur. **Be consistent within one skill.**
- The header **states its limits honestly** (CONTRIBUTING.md house convention 3). Real instances:
  *"Conceptually compiles against flutter."*, *"This file is illustrative; the `some_secure_storage`
  package is a stand-in for…"*, *"All hex/radii are illustrative placeholders owned by your design
  source of truth."*, *"inlined here for one self-contained illustration. In the app tree they split:…"*.
- **Domain:** neutral generic nouns only — `Note`, `Task`, `Product`, `Account`, `Order`, `Item`,
  `Reminder` (CONTRIBUTING.md lines 18–19).
- YAML/config examples use a `#` header block with the same content contract, and
  `analysis_options.yaml` opens with a `# ===…===` banner rule.

---

## 6. CROSS-LINKING convention

### 6.1 `## Related skills` phrasing

232 bullets measured. **Two phrasings, both current, roughly 50/50 — pick one per file:**

**Form A — "See" form** (106 bullets; 16 skills incl. `testing-strategy`, `design-system-structure`,
`custom-canvas-and-gestures`, `error-handling-typed-results`, `i18n-rtl-l10n`):
```markdown
- See `‹skill-name›` for ‹the specific thing that skill owns which this one leans on›.
```

**Form B — "bare backtick + em dash" form** (118 bullets; 16 skills incl. `widget-composition`,
`project-structure-and-packages`, `state-management-riverpod`, `navigation-and-routing`):
```markdown
- `‹skill-name›` — ‹the specific thing that skill owns which this one leans on›.
```

Rules that hold in **both** forms:

1. **4–11 bullets, median 7.** Never a bare list of names.
2. The clause after the name is always **what that skill owns**, phrased so the reader knows when to
   leave. Best-in-class (widget-composition → i18n-rtl-l10n):
   *"owns the directional-geometry (`EdgeInsetsDirectional`/`AlignmentDirectional`) and
   ARB-localization rules the strings and insets these widgets render must follow."*
3. Skill names are **always in backticks**, always the exact directory name.
4. The relationship is stated **directionally** where relevant: *"it owns the `resolveMotion`
   reduced-motion helper this skill's animation path defers to."*
5. `flutter-conventions-index` is the sole exception: it has **no bullets** — a two-sentence
   paragraph instead, because it links everything via its routing table.
6. CONTRIBUTING.md line 116: *"Confirm … that its `Related skills` links resolve to real names."*

### 6.2 Routing into `flutter-conventions-index`

CONTRIBUTING.md line 116 makes this **mandatory**: *"Confirm the new skill is reachable from
`flutter-conventions-index` (add it to the routing table)."*

The routing table lives under `## Route to the right skill` in
`skills/flutter-conventions-index/SKILL.md` (lines 29–65). Header is exactly:

```markdown
| When you are… | Open |
|---|---|
```

**Exactly one row must be added per new skill:**

```markdown
| ‹Gerund-led task phrase naming the concrete artefacts› | `‹new-skill-name›` |
```

Verified row conventions:

- Left cell starts with a **gerund**: *Deciding…*, *Writing…*, *Building…*, *Adding…*,
  *Configuring…*, *Wiring…*, *Choosing…*, *Fixing…*, *Running…*, *Scaffolding…*, *Structuring…*,
  *Modeling…*, *Editing…*, *Orienting…*, *Applying…*.
- Left cell packs **concrete symbols/filenames**, not abstractions:
  `| Configuring the app router, redirects/auth guards, deep links, nav shells, transitions, PopScope, 404 |`,
  `| Adding a Drift table, DAO, or `.watch` stream |`,
  `| Writing `///` doc comments on the public surface |`.
- Right cell is the bare skill name in backticks. **One skill per row, no prose, no "(rich)".**
- No trailing period in either cell.
- Rows are ordered roughly by the build order, not alphabetically.

**Full checklist for landing a new skill in this repo** (from CONTRIBUTING.md + observed artefacts):

| # | Artefact | What to add |
|---|---|---|
| 1 | `skills/<name>/SKILL.md` | the skill (+ `references/`, `examples/`, `scripts/` if rich) |
| 2 | `skills/flutter-conventions-index/SKILL.md` | **one row** in the `## Route to the right skill` table (**mandatory**) |
| 3 | sibling skills' `## Related skills` | reciprocal bullets where the relationship is real |
| 4 | `README.md` `## The skills` | one `\| \`name\` **(rich)** \| ‹what it governs› \|` row in the right `###` category table |
| 5 | `AGENTS.md` `## Intent → skill map` | a row if the skill introduces a new *intent*, else append to an existing row's list |
| 6 | `skills.json` | bump `count`, append a `skills[]` entry: `{name, description, category, categoryLabel, priority, rich, manual, path}` — `category` ∈ `core-flutter`/`architecture`/`structure-foundation`/`data`/`quality-testing`/`i18n-a11y`/`workflow-tooling`; `path` = `skills/<name>` |
| 7 | `docs/skills.json` | **byte-identical copy of `skills.json`** (verified identical today) |
| 8 | `docs/skills-data.js` | `window.SKILLS = [ …same array… ];` |
| 9 | validate | `claude plugin validate . --strict` · `find skills -name '*.sh' -print0 \| xargs -0 -n1 bash -n` · the raw-value grep in CONTRIBUTING.md line 111 |

---

## 7. COVERAGE MAP — what already has an owner, what is a genuine gap

Method: grep of every `SKILL.md`, `references/`, `examples/`, `scripts/` for each topic's
characteristic symbols, plus reading the owning skill's rules. "Owner" = the skill whose
**Non-negotiable rules** actually bind the topic, not merely mention it.

| # | Topic the user wants | Verdict | Owning skill(s), exact name | Evidence / what's actually covered |
|---|---|---|---|---|
| 1 | **Buttons** | **GAP** (component-level) | partial: `widget-composition` (extraction/const/keys), `accessibility-as-code` (44px target, `Semantics(button:true)`), `async-safety` (the `onTap: () => vm.save(x)` Future-drop hole), `design-system-structure` (the token slots a button reads) | No skill names `ElevatedButton`/`FilledButton`/`TextButton`/`IconButton`/`SegmentedButton`. `Button` matches only 6 SKILL.md files, ≤2 hits each, all incidental. **A button-anatomy skill (variant ladder, state matrix, loading/disabled semantics, min target, icon+label slots) is a real gap.** |
| 2 | **Menus / navigation** | **OWNED** | `navigation-and-routing` (router, redirects, deep links, shells, `go` vs `push`, `PopScope`, 404) + `adaptive-layout` (`NavigationBar`→`NavigationRail`→`NavigationDrawer` by width, 6 hits) | Both bind it in Non-negotiable rules. *Menu surfaces specifically* (`PopupMenuButton`, `MenuAnchor`, `DropdownMenu`) have **zero** corpus hits → narrow gap if the app needs authored menus. |
| 3 | **Text & typography** | **OWNED** | `design-system-structure` (`references/typography-and-fonts.md`: bundling, `LicenseRegistry`, `FontWeight` drives `wght`, `FontVariation` no-ops, fallback cascades, `fontSize:` banned outside `lib/theme/`) + `accessibility-as-code` (text scale, never clamp/`FittedBox`/ellipsis, `boldText`) + `custom-canvas-and-gestures` (`references/text-and-shapes.md`, measured `TextPainter` fitting) | Type *scale/ramp values* are deliberately out of scope (CONTRIBUTING.md lines 13–16: design-token values belong in the app's own `.claude/skills/`) — so an **app-level type-ramp skill is legitimate and not a duplicate**. |
| 4 | **Type system / value types** | **OWNED** | `dart3-idioms-and-coding-standards` (sealed, class modifiers, records, immutability & equality, `references/construct-verdict-table.md`) + `value-objects-money-and-units` (canonical storage, `allocate()`, units) + `error-handling-typed-results` (`Result<T, F extends Failure>` spine) | Fully covered. Do not restate. |
| 5 | **Testing structure** | **OWNED** | `testing-strategy` (tier-by-code, `references/test-layers.md`, fakes-over-mocks, in-memory Drift, `ProviderContainer`, `fakeAsync`, coverage floors) + `widget-golden-and-a11y-testing` (harness, overflow/textScale matrix, golden lanes, a11y gate) | Fully covered, incl. `test/` directory shape via `references/test-layers.md`. |
| 6 | **File layout** | **OWNED** | `project-structure-and-packages` (`references/single-package-layout.md`, `scripts/check_structure.sh`, junk-drawer ban) + `flutter-architecture` (layer DAG) + `naming-conventions` (file = primary declaration) + `scaffold-feature-module` (the fixed feature anatomy + generator) | Fully covered. |
| 7 | **Function naming** | **OWNED** | `naming-conventions` — rule 2 (`lowerCamelCase` members/functions), rule 9 (units in the name), rule 11 (`no get-prefix`; "Functions are verb phrases (`loadTasks()`, `scheduleReminder()`); non-boolean getters are noun phrases"), plus the DoD item "Booleans read as assertions; functions are verb phrases; getters are noun phrases with no `get` prefix." | Fully covered. |
| 8 | **Clean code** | **OWNED** | `dart3-idioms-and-coding-standards` (the *sole* home of complexity numbers — CONTRIBUTING.md line 53: method ≤30, `build()` ≤80, file ≤300, positional ≤3, nesting ≤3/5; `references/complexity-and-honesty.md`) + `lint-and-style-config` + `dartdoc-conventions` | Fully covered; **never restate the numbers**, cite the table. |
| 9 | **Forms & inputs** | **OWNED** | `forms-and-input` (rich: `Form`/`GlobalKey<FormState>`, sync vs async validation, focus/keyboard traversal, formatters, disposal, derived submit, `scripts/check_forms.sh`, 2 references, 2 examples) | Fully covered. |
| 10 | **Lists & tables** | **PARTIAL → narrow gap** | lists: `widget-composition` (8 hits — `.builder` lists, key policy, `GridView` axis trap, `references/structural-layout.md`) + `flutter-performance` (lazy lists/slivers, sized image decode) + `persistence-drift` (keyset/seek pagination, never `OFFSET`) + `adaptive-layout` (list-detail) | **Tables have no owner**: `DataTable` has **zero** corpus hits. List *rows/tiles* as a component (leading/trailing slots, dividers, swipe actions, empty/loading/error states) are also unowned. A "data display: lists, rows, tables, empty states" skill is a real gap. |
| 11 | **Dialogs** | **GAP** | nothing. `showDialog`/`AlertDialog`/`showModalBottomSheet` appear **only** in `navigation-and-routing/examples/shell_scaffold.dart`; `SnackBar` appears in `scaffold-feature-module` (3) and `error-handling-typed-results` (1, the undo snackbar) | No skill's rules bind dialog/sheet/snackbar policy (when modal vs route, barrier dismissal, focus return, destructive confirmation, result typing, RTL/a11y of the barrier). **Genuine gap.** |
| 12 | **Icons / illustration** | **GAP** | partial only: `accessibility-as-code` (every `Icon`/`Image` labelled or `ExcludeSemantics`), `i18n-rtl-l10n` (`Icons.adaptive.*`, mirroring), `flutter-performance` (sized image decode, `cacheWidth`/`ResizeImage`), `design-system-structure` (icon as a redundant status signal) | No owner for the **icon system itself**: source/set choice, sizing scale, `IconData` vs SVG vs asset, optical alignment, illustration/empty-state art, asset naming. `SvgPicture`/`Lottie`/`illustration` have **zero** corpus hits. **Genuine gap.** |
| 13 | **RTL / Arabic** | **OWNED** | `i18n-rtl-l10n` (rich: ARB/gen-l10n contract, `nullable-getter:false`, ICU plural/select incl. Arabic's six CLDR forms, directional-only geometry, FSI/PDI bidi isolation, per-locale `NumberFormat` with pinned numbering system, UTC+ASCII canonical storage, normalize-before-parse; `references/rtl-and-bidi.md`, `references/numerals-and-calendars.md`, `scripts/check_arb_parity.sh`, `scripts/check_i18n_bans.sh`) + `widget-golden-and-a11y-testing` (RTL golden lanes) | Fully covered, Arabic explicitly named. |
| 14 | **Theming modes** | **OWNED** | `design-system-structure` — rule 5 (hand-author light **and** dark, attach every extension to **both** `ThemeData`s), rule 9 (restore the persisted theme before first paint, explicit fallback), rule 4 (never `fromSeed`/`dynamic_color`), rule 8 (reduced motion → `Duration.zero`); + `app-startup-and-bootstrap` (`main()` ordering) + `state-management-riverpod` (`themeModeProvider`) | Fully covered *structurally*. **Token values** are explicitly out of scope for this library → an app-level palette/mode-values skill is legitimate. |
| 15 | **Performance** | **OWNED** | `flutter-performance` (`const` subtrees, `.select` rebuild scoping, lazy lists/slivers, sized image decode, off-isolate `compute`, surgical `RepaintBoundary`, dispose, profile-mode measurement) + `custom-canvas-and-gestures` (zero-allocation `paint()`) | Fully covered. |
| 16 | **Offline guarantees** | **PARTIAL → gap** | `error-handling-typed-results` owns *never-lose-data* (`references/never-lose-data.md`, soft-delete + undo, transactional write) and `persistence-drift` owns durability (persist-before-publish, WAL, backups). "offline-first" is named in `run-migration` and `flutter-architecture` as an assumption | No skill binds **offline as a product guarantee**: no connectivity model, no queue/outbox, no conflict resolution, no "works with airplane mode on" acceptance contract. If the app has no network at all, most of this is moot — but the **explicit "no network code path exists" invariant + its gate** is unowned. Judge against the app. |
| 17 | **Local database** | **OWNED** | `persistence-drift` (rich: Drift/sqlite3 confined to `lib/data/`, STRICT tables + CHECK/FK/partial-UNIQUE, `beforeOpen` pragmas, one `db.transaction` per mutation, persist-before-publish, keyset pagination, WAL-safe backups; 3 references, 3 examples, 2 scripts) + `run-migration` (forward-only migration ritual, manual-only) + `codegen-and-toolchain`/`run-codegen` (drift_dev) | Fully covered. `references/persistence-without-drift.md` even covers the no-Drift case. |
| 18 | **Content / data pipeline** | **GAP** | essentially nothing. `assets/`, `rootBundle`, `seed data`, `bundled data` have **≤1 incidental hit** (`flutter-performance` mentions assets only for image decode) | Nothing owns: authoring content out-of-band (JSON/CSV/YAML), validating it in CI, generating Dart or seeding SQLite from it, versioning it against `schemaVersion`, or the l10n of bundled content. **Genuine gap, and it is the largest one.** |

### 7.1 Summary

**Already owned — do not rebuild, cite instead (10):** menus/navigation · text & typography
(structure) · type system/value types · testing structure · file layout · function naming ·
clean code · forms & inputs · RTL/Arabic · theming modes (structure) · performance · local database.

**Genuine gaps worth new skills (5):**
1. **Dialogs / modals / transient surfaces** — nothing owns it.
2. **Content / data pipeline** — nothing owns it; largest gap.
3. **Icons & illustration system** — only a11y labelling and mirroring are owned.
4. **Buttons & action components** — only extraction, tap-target, and Future-drop are owned.
5. **Data display: lists, rows, tables, empty/loading/error states** — lazy-list *mechanics* are
   owned by `widget-composition`/`flutter-performance`; the *component* and `DataTable` are not.

**Judgement calls (2):**
6. **Offline guarantees** — durability is owned; "offline as a product contract + its gate" is not.
7. **App-level token *values*** (type ramp, palette, mode values) — deliberately excluded from this
   library (CONTRIBUTING.md lines 13–16), so an app-scoped skill is *correct*, not a duplicate.
   It must live in the app's `.claude/skills/`, not in this plugin.

---

## 8. Two hard constraints inherited from CONTRIBUTING.md

1. **Scope split (lines 6–19).** This plugin holds only *general, reusable* Flutter skills.
   **Design-token values** (colours, hex, radii, shadows, elevation, fonts, magic durations) and
   **app-domain skills** must live in the individual app's `.claude/skills/`. Examples in the plugin
   must use neutral domains (`Note`, `Task`, `Product`, `Account`, `Order`, `Item`, `Reminder`) —
   *"never a real app's nouns."* → **New app-specific skills for E02 belong in the app repo, and may
   name real values and real nouns; new general skills belong here and may not.**
2. **Single-ownership (line 116).** *"it doesn't restate a rule another skill already owns — state it
   once, cross-reference it elsewhere."* Every new skill must open with a boundary sentence naming
   what it defers to, and every overlapping rule must end by naming the owning skill.

## 9. Open items / unverified

- Whether `docs/skills-data.js` and `docs/skills.json` are hand-maintained or generated: **no
  generator script exists in the repo** (no `tools/`, no `package.json`, no Makefile) → assume
  hand-maintained. **Unverified** beyond that.
- `${CLAUDE_SKILL_DIR}` resolution semantics: CONTRIBUTING.md line 97 asserts it "resolve[s] at
  personal, project, or plugin scope"; **no evidence found in this repo or in any SKILL.md**, and no
  skill uses it. Treat as unverified guidance, and follow the corpus (bare `scripts/x.sh`).
- CONTRIBUTING.md line 37 says "the existing 33"; `skills.json` `count` is 33; 33 directories on
  disk. Consistent as of 2026-07-30.
