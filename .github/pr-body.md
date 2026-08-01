# E03 — Rule engine: resolution, findings and verdicts

`packages/rule_engine/` now answers the question the whole product exists to answer, in pure Dart. Given a jurisdiction, a zone path, a species, a water type, a date, a measurement and today's tally, `evaluate` returns a sealed `Resolution` — and states none of it in words.

## What changed

Twelve commits: D-15 settling the type names, then the eleven tasks. The domain models; the vendored `Result`/`Failure` pair; candidate selection with lineage collapse and the expiry tag; zone ancestry and the specificity ladder; ambiguity detection; closed-season arithmetic; size, bag and vessel findings; finding precedence; the sealed `Resolution` union; and the two distinct absence states.

## The three things this epic had to get right

**Expiry tags; it never deletes.** The selection predicate is jurisdiction AND species AND water type AND `validFrom <= on`, and there is no fourth clause. A `date < validTo` filter is correct-looking, passes every test written on a Tuesday, and is wrong on exactly one class of row — the annual instrument. A Spanish *orden de vedas* lapses on 30 April; a permanent ministerial decision carries no `validTo` at all. So the filter does not degrade gracefully: on 1 May every Galician shellfish rule vanishes at once. What that costs is not a wrong answer but a **change of category** — a bundled snapshot with a known as-of date is a printed booklet, and a booklet does not stop being a booklet on 1 May.

**The tie is returned, never broken.** `.first`, newest wins, strictest wins, most permissive wins, expired loses — all five refused by name, in the doc comment, so none gets reinvented. "Expired loses" gets its own test because it feels like careful engineering: it means that on the day one of two conflicting instruments lapses, the app silently starts reporting the other one, with no warning and no second citation.

**Absence is never permission.** Three absences that look identical from a caller's seat and are legally miles apart — `NoLimitInInstrument`, `NoRuleFound`, `UnknownSpecies`. The wording belongs to E06 and E10 under D-7; what lands here is structural: **there is no way to reach a permissive outcome from an absence.** `Decided` requires a headline `Finding`, a `Finding` requires a rule to have been found, and neither absence arm can produce one. The `findings.isEmpty ? meets` shape is not avoided — it is unrepresentable.

## Verification

- **359 tests** in `packages/rule_engine`, 134 in `app`, 1 in the builder
- **Branch coverage 124/124 = 100%** over `lib/src/resolve/`, `lib/src/season/`, `lib/src/findings/` and `lib/src/verdict/`; line coverage 272/273
- `evaluate` resolves 20 candidate rows across four lineages in **under 10 ms**
- `check_rule_engine.sh` and `check_app_invariants.sh` clean over `packages/rule_engine/lib`; all sixteen skill gates green
- The epic's three headline greps all return nothing: `validTo` in no `.where`/`removeWhere`/`retainWhere`/`takeWhile`; no literal `DateTime.now()` under `lib/`; no nullable `Citation` anywhere
- No file under `app/lib/` changed
- Every test uses a frozen date; nothing reads a wall clock

**The one uncovered line is unreachable by construction and is reported rather than chased.** `precedenceOf`'s `StateError` fires only for a `FindingKind` with no entry in `kFindingPrecedence`, and T09's own test enumerates `FindingKind.values` to prove every member has one. Writing a test that reaches it would mean creating the exact state the other test forbids.

## D-15 — the type names, settled at the head of the epic

`CLAUDE.md` listed this under "do not decide these quietly" and named E03. The three conflicts turned out to have **three different losers**, so counting the hits before choosing turned a coin-flip between two skills into three separately-evidenced decisions:

| Name | Chosen from | Loser |
|---|---|---|
| `Resolution` | `catchlaw-rule-engine`, the epic, four task files | **D-7**, which says `Verdict` |
| `Finding` | D-7, `catchlaw-verdict-contract`, six task files | `catchlaw-rule-engine`'s `RuleFinding` |
| `Ambiguous` | `catchlaw-rule-engine`, T05 | `catchlaw-verdict-contract`'s `ConflictingRules` |

`RuleFinding` had no constituency at all — one skill, and **zero** task files. D-7 is amended with its old names struck rather than deleted; its substance, that the engine holds no user-visible sentence, is untouched and is what this epic proves.

## D-7, proved rather than promised

`check_verdict_contract.sh` scans `app/lib`, so no shipped gate looks at this package for words. `no_strings_test` asserts that no file under `lib/src/findings/` or `lib/src/verdict/` contains a string literal, plus a second test banning field names like `message`, `label` and `title`.

It found three literals on its first run, and **the fix was the substantive part of T10**: `MalformedRule` gained named constructors (`noSizeThreshold`, `noMeasurementMethod`, `noBagLimitPeriod`) so no caller writes a field name as free text — E04 matches on these, and free text would have made that a string comparison against a value somebody could typo. Two `throw` lines remain and are excluded as programmer errors that crash rather than render; **a third test caps that exclusion at two**, so it cannot become the hole every future literal is posted through.

## Deviations from the task files, all deliberate

- **`Finding` subtypes are `part`s of one library.** A `sealed` class can only be extended inside the library that declares it — which is precisely the property that makes a `switch` exhaustive. One file per subtype, per §6.2, with the seal intact.
- **`seasonStatus` takes a `ruleId`.** `MalformedSeason` names the offending row, and a `ClosedSeason` does not know its parent because T01 modelled §7.1's cascade as containment.
- **`EvaluationRequest` gained `searched` and nullable `species` in T11**, not T03 where the task file says they were declared. T03 shipped neither.
- **`EvaluationRequest` is not `const`.** An emptiness check on a `List` cannot be evaluated in a const context, so the constructor and the `searched` assert could not both survive. The assert won: a request is built once per evaluation, and an uncited absence shipping is what it stops.

## Learned by executing

- **The sealed union proved itself mid-epic.** T10's exhaustive-switch test stopped compiling the moment T11 added two arms. A `default:` would have compiled straight through both and reported an absence as whatever the fallback said.
- **`check_verdict_contract` fired three times on my own doc comments** — each quoting a banned phrase in order to explain that it is banned. The gate does not strip comments and does not care about intent. Reworded every time, never exempted.
- **Coverage had to be measured, not assumed.** The 100% target was at 85–94% when first checked, and one of the eleven gaps was worth having on its own: `Decided.isExpired`'s `||` short-circuits on the headline, so a lapsed instrument behind a *secondary* finding was untested — and the ochre bar would not have appeared for a verdict partly resting on a lapsed rule.

## Follow-ups deliberately not here

- The wall-clock `Clock` implementation — it belongs where it has a consumer, in E10.
- Point-in-polygon zone selection — the engine takes a materialised `zonePath`; E11 produces it.
- Every user-visible string, in every locale — D-7, delivered by E06 and E10.
- `citation.lineage_id` as a schema column — epic risk 1, owned by E04. The safe default (lineage = citation id) collapses nothing and can only produce an `Ambiguous`, never a silent pick.
- A build-time assertion that `rule.specificity` agrees with §7.3's ladder — epic risk 6, owned by E04. Nothing here reads the column, which is what makes that assertion the only place the two can be seen to diverge.
- A distinct `measurement_method.code` per jurisdiction's custom method — epic risk 3, owned by E04.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
