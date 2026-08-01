# E04/T08 — Run the engine over the authored data

| | |
|---|---|
| **Epic** | E04 — Content builder and the Galicia seed |
| **Branch** | `epic/04-content-build` (shared) |
| **Commit** | `feat(content_builder): resolve the authored grid with the shipped rule engine` |
| **Depends on** | T05 (citations must resolve before the grid can be trusted), E03 (the resolver) |
| **Size** | L |
| **Spec** | `SPEC.md` §8 bullet 8, §7.3 (the resolution algorithm and step 4), §6 D4, §15 step 3 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rules 1, 4, 5, 6, 7 and 8, plus `references/resolution-algorithm.md` — the four stages, the tie matrix and the expiry axis this pass must import rather than re-derive |
| `catchlaw-content-pipeline` | Rule 10 and A8 — the shipped engine resolves the authored grid before it ships, and the contradiction classes table names what to look for |
| `catchlaw-conventions-index` | Invariant 5 — an expired ruleset is still evaluated. A build-time pass that treated `isExpired` as a failure would delete every annual instrument from the corpus |
| `testing-strategy` | This is the epic's largest test surface; the pyramid says it is pure unit work with no I/O |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, bullet 8 | "run the **rule engine's own resolution logic** (§7.3, a pure Dart library with no Flutter imports) over the authored data to catch contradictions before they ship" |
| `SPEC.md` | §7.3 | The four steps, the specificity ladder, and step 4: equal specificity plus disagreement returns **both** and renders D4 |
| `SPEC.md` | §6, D4 | The ambiguity dialog. It must remain reachable in production, which decides how A8 treats a genuine conflict |
| `SPEC.md` | §13 | `Rule evaluation < 10 ms` over ≤ 20 candidate rows — the per-evaluation budget this pass multiplies |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "The four stages, in order", "The tie matrix", "The expiry axis", "Edge cases" | The exact predicate order, `outcomeEquals` semantics, and the Galician *orde de vedas* worked hazard |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rules 1, 6, 8 | Expiry is tagged not filtered; a tie is reported not broken; "no rule found" never implies legality |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | A8 row, "A8 — contradiction classes" | Six classes, with the resolution for each — `supersedes:`, delete the size rule, fix the zone |
| `.claude/skills/catchlaw-content-pipeline/examples/content_builder_assertions.dart` | `assertNoContradictions` | The worked shape: construct the engine from the source, switch on the result, no `default:` that swallows a variant |
| `epics/CONVENTIONS.md` | §9, invariant 5 | The invariant this pass must not weaken |

## What this delivers

- `tools/content_builder/lib/src/resolve/rule_set_adapter.dart` — the authored rows mapped into the
  plain Dart record types `resolve()` takes. No drift, no SQLite; the engine must never see a row type
  that pins it to a database (`catchlaw-rule-engine` anti-patterns).
- `tools/content_builder/lib/src/resolve/resolution_grid.dart` — the grid generator.
- `tools/content_builder/lib/src/assert/a08_resolution.dart` — `ResolutionAssertion`.
- `content/es-ga/rules.yaml` — extended with the two authored escapes, `supersedes:` and
  `ambiguity_ack:`.
- `tools/content_builder/test/resolve/resolution_grid_test.dart`,
  `test/assert/a08_resolution_test.dart`.

## Why it is built this way

**Row-level assertions cannot see a contradiction.** A1 through A7 each look at one row. Two rows that
each validate perfectly can still say 380 mm and 400 mm about the same clam on the same bank in the
same month. `catchlaw-content-pipeline` rule 10 states the consequence exactly: the tie is broken at
sea, offline, in favour of whichever row the query returned first. So the shipped engine is imported
and run over the authored grid, and — because it is the *shipped* engine — a precedence change in E03
re-runs here for free rather than needing a second model of the rules kept in step by hand.

**The grid is (species × zone × month × water type), and the candidate fetch happens once per
species.** `SPEC.md` §13 budgets a single evaluation at under 10 ms over ≤ 20 candidate rows, and that
budget includes the device's row read. A naive implementation that re-collected candidates per cell
would multiply the expensive half by the whole grid; grouping the collection by
`(speciesId, waterType)` makes the sweep pure in-memory evaluation with no I/O at all. That is a
**structural** property, so case 13 asserts the collection call count rather than a wall-clock
threshold — a timing test on CI is a flake, and a flake in a fatal assertion gets disabled.

**The build reports the grid size it actually resolved.** `build-assertions.md` sizes a full corpus at
roughly 40 000 cells. Galicia alone is smaller and its size will change as E22 lands. The build prints
`content_builder: A8 resolved <n> cells in <m> ms` with the real numbers, so the cost is a measurement
somebody can act on rather than a claim in a document.

**`isExpired` is never a failure, and this is the sentence that keeps invariant 5 intact.**
`resolution-algorithm.md`'s worked hazard is Galician: the *orde de vedas* is reissued annually and
typically lapses on 30 April. `SPEC.md` §7.3 explains what filtering on `valid_to` did to the first
draft — every rule sourced from a lapsed instrument vanished and every species fell through to "no
rule recorded". A build assertion that failed on an expired row would do the same damage a year
earlier and more permanently, by making the corpus unshippable until somebody deleted the rows. A8
resolves with the injected build date, tags expiry, and ignores the tag. Case 8 pins this.

**A genuine ambiguity must remain shippable, or D4 is dead code.** This is the one real design
decision in the task. `build-assertions.md` says an A8 conflict is fixed by authoring an explicit
`supersedes:` on one rule. That covers the common case — a newer instrument replacing an older one —
and it is the right first answer. But `SPEC.md` §7.3 step 4 and §6 D4 require the app to render **both
rules** when two instruments at equal specificity genuinely disagree, and to never silently report the
more permissive one. If A8 failed on every `Ambiguous`, no such pair could ever be authored, D4 would
be unreachable, and the first genuine legal conflict would have nowhere to go but a `supersedes:` the
sources do not support — which is precisely the silent choice §7.3 forbids.

So A8 fails on an **unacknowledged** ambiguity. An acknowledged one carries
`ambiguity_ack: { with: <rule-id>, reason_key: <key> }` on both rules; the reason key is a `*_key` and
is therefore translated into all six locales by T03's A2, and it is what D4 renders. The
acknowledgement is greppable, appears in T09's diff when it changes, and is reviewed. **Rejected:**
failing on every ambiguity (D4 becomes unreachable, and an author under pressure writes a false
`supersedes:`). **Rejected:** passing every ambiguity with a warning — `catchlaw-content-pipeline`
rule 2 has no warning tier, and an unreviewed D4 in the field is two citations the fisher cannot
choose between.

**Corroboration is not ambiguity.** `resolution-algorithm.md` is explicit that `outcomeEquals`
compares substantive content only — kind, threshold, unit, method, closure dates — never `ruleId`,
`validFrom`, `citation` or row order. Two identically-worded rules from two instruments are
corroboration. A8 uses the engine's own comparison and does not write a second one.

**Incomparable minima are legal and must pass.** `min_size_mm: 450 TL` and `min_size_mm: 400 FL` for
one species are not a contradiction: they are two measurements of different things, both of which must
be shown. A1 guarantees both carry a method; A8 must not fail them. Case 10 pins it, because "two
different minima" is exactly the shape a naive contradiction check flags.

**`NoRuleFound` where the author wrote a rule is a wiring bug, and A8 catches it.**
`catchlaw-rule-engine` rule 8 keeps `NoRuleFound` a legitimate state — silence in the sources is not
permission. But if the corpus contains a rule for `(species, zone)` and the grid resolves that same
cell to `NoRuleFound`, the rule is unreachable: an orphan `zone_id`, a `valid_from` in the future, or
a `water_type` that matches nothing. That is a content defect and A8 reports it with the rule id that
went missing.

## Tests first

Write every row before touching `a08_resolution.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ResolutionGrid generates one cell per species, zone, month and water type` | 2 species × 3 zones × 12 months × 1 water type | 72 cells | The grid is the assertion's coverage; an off-by-one in the month loop hides a whole closure |
| 2 | `ResolutionGrid includes only the water types the jurisdiction declares` | jurisdiction with `has_freshwater: 0` | no `fresh` cells | Galicia declares saltwater; generating freshwater cells would report `NoRuleFound` for every one |
| 3 | `ResolutionAssertion reports A8 when two rules at equal specificity disagree` | two region rules, 380 mm and 400 mm | one `A8` naming both rule ids | The headline contradiction class |
| 4 | `ResolutionAssertion accepts an ambiguity carrying ambiguity_ack on both rules` | the same pair, acknowledged | no failures | D4 must remain reachable; §7.3 step 4 requires both rules to be renderable |
| 5 | `ResolutionAssertion reports A8 when ambiguity_ack names only one of the pair` | one-sided acknowledgement | one `A8` | A half-acknowledged pair is an author who stopped halfway, and D4 would render one citation |
| 6 | `ResolutionAssertion accepts a superseded pair` | older rule, newer rule with `supersedes:` | no failures | `build-assertions.md`'s prescribed fix must actually work |
| 7 | `ResolutionAssertion accepts two rules at different specificity` | bank rule and region rule disagreeing | no failures | The ladder resolves it; a check that flagged this would fail every real jurisdiction |
| 8 | `ResolutionAssertion accepts a rule whose valid_to is in the past` | `valid_to` before the build date | no failures, `isExpired` true on the resolution | Invariant 5, and the Galician *orde de vedas* hazard verbatim |
| 9 | `ResolutionAssertion reports A8 when a protected species also carries a size rule` | `is_protected: 1` plus a bank-level `min_size_mm` | one `A8` | Protected admits no threshold; the size finding would never be read and its number would be uncheckable |
| 10 | `ResolutionAssertion accepts two minima measured by different methods` | 450 TL and 400 FL | no failures | Legal and incomparable; both must be shown, and a naive check flags exactly this |
| 11 | `ResolutionAssertion reports A8 when a rule's zone_id is in no jurisdiction` | orphan `zone_id` | one `A8` at the rule's line | The rule is unreachable, and the species reports "no rule recorded" in the field |
| 12 | `ResolutionAssertion reports A8 when an authored rule never resolves in any cell` | `valid_from` after the build date | one `A8` naming the rule id | A rule nobody can reach is indistinguishable from a rule nobody wrote |
| 13 | `ResolutionAssertion collects candidate rows once per species and water type` | 3 species × 20 zones × 12 months | 3 collection calls | The structural budget; `SPEC.md` §13's per-evaluation cost must not be multiplied by the grid |
| 14 | `ResolutionAssertion reports the resolved cell count on stdout` | a small grid | `A8 resolved 72 cells` in the report | The number is measured and printed, never claimed |
| 15 | `ResolutionAssertion switches on every Resolution variant with no default arm` | — | compiles; a new variant is a compile error | `catchlaw-rule-engine` rule 8 — `NoRuleFound` and `NoLimitInInstrument` are different answers and a `default:` would fuse them |
| 16 | `RuleSetAdapter passes plain Dart records to the engine` | the adapter's output type | no SQLite or drift type in the signature | The engine must stay constructible from a fixture without opening a database |

```dart
// tools/content_builder/test/assert/a08_resolution_test.dart
import 'package:content_builder/src/assert/a08_resolution.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('ResolutionAssertion', () {
    test('reports A8 when two rules at equal specificity disagree', () {
      final source = contentSourceWithRivalMinima(
        zoneKind: 'region',
        first: 380,
        second: 400,
      );
      final failures = ResolutionAssertion(on: DateTime.utc(2026, 8, 14)).run(source).toList();

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A8');
      expect(failures.single.message, allOf(contains('r-001'), contains('r-002')));
    });

    test('accepts an ambiguity carrying ambiguity_ack on both rules', () {
      final source = contentSourceWithAcknowledgedAmbiguity();
      expect(ResolutionAssertion(on: DateTime.utc(2026, 8, 14)).run(source), isEmpty);
    });

    test('accepts a rule whose valid_to is in the past', () {
      final source = contentSourceWithExpiredRule(validTo: DateTime.utc(2026, 4, 30));
      expect(ResolutionAssertion(on: DateTime.utc(2026, 8, 14)).run(source), isEmpty);
    });

    test('collects candidate rows once per species and water type', () {
      final counting = CountingRuleSetAdapter(contentSourceWithSpecies(3, zones: 20));
      ResolutionAssertion(on: DateTime.utc(2026, 8, 14)).run(counting.source).toList();

      expect(counting.collectCalls, 3);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `(cd tools/content_builder && dart test test/resolve test/assert/a08_resolution_test.dart)` →
every case red. If case 8 or case 10 passes now, the fixture is wrong — those two are the cases a
naive implementation gets right by accident and a careful one gets wrong.

## Implementation outline

1. `RuleSetAdapter` maps loaded rows into whatever plain record types E03's `resolve()` takes. Read
   E03's signature; do not guess it, and do not add a convenience constructor to the engine.
2. `ResolutionGrid.of(ContentSource)` yields `(speciesId, zonePath, month, waterType)` cells, with the
   zone path materialised from the parent chain once per zone (`resolution-algorithm.md`: ancestry is
   a list membership test, not a recursive walk per cell).
3. Group cells by `(speciesId, waterType)`; collect candidates once per group; sweep the group's cells
   against the same candidate list.
4. Switch on the `Resolution` result with **no** `default:` arm: `Ambiguous` → check for a matching
   `ambiguity_ack` on both rules, otherwise `A8`; `NoRuleFound` → `A8` only if the corpus holds a rule
   for that species and jurisdiction; everything else passes.
5. The evaluation date is `options.buildDate` — the engine takes it as a parameter and reads no clock
   (`catchlaw-rule-engine` rule 3), and T01 already made it required input.
6. After the sweep, cross-check that every authored rule id appears in at least one resolution; any
   that does not is an unreachable rule.
7. Print `A8 resolved <n> cells in <m> ms` in the corpus summary.
8. Register after A6.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 16 rows pass, and each failed first.
- [ ] 100 % branch coverage on `a08_resolution.dart` and `resolution_grid.dart`.
- [ ] The switch over `Resolution` has no `default:` arm, so an E03 variant added later is a compile
      error here.
- [ ] `isExpired` appears in this task's code only as a value read and ignored — never in a filter,
      never in a failure condition. Invariant 5 is intact and case 8 proves it.
- [ ] `tools/content_builder/lib/src/resolve/` re-implements no part of `SPEC.md` §7.3: no
      specificity table, no zone-ancestry rule, no tie-break.
- [ ] The build prints the resolved cell count and elapsed milliseconds for the Galicia corpus.
- [ ] `ambiguity_ack` and `supersedes` are documented in `content/README.md`, with `SPEC.md` §7.3
      step 4 and §6 D4 as the reason the first exists.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content_builder): resolve the authored grid with the shipped rule engine

A1 through A7 each look at one row. Two rows that each validate can still say
380 mm and 400 mm about the same clam on the same bank in the same month, and
that tie is broken at sea, offline, in favour of whichever row the query
returned first. So the shipped engine — the same code the phone runs — sweeps
every (species, zone, month, water type) cell before a byte is written.

Expiry is read and ignored. resolution-algorithm.md's worked hazard is
Galician: the orde de vedas lapses on 30 April, and SPEC.md §7.3 records what
filtering on valid_to did to the first draft. An assertion that failed on an
expired row would do the same damage a year earlier and permanently, by making
the corpus unshippable until somebody deleted the rows.

A8 fails on an UNACKNOWLEDGED ambiguity. Failing on every ambiguity would make
D4 unreachable — §7.3 step 4 and §6 D4 require both rules to be rendered when
two instruments genuinely disagree — and would push an author under pressure
into a `supersedes:` the sources do not support, which is the silent choice
§7.3 forbids. An acknowledged pair carries ambiguity_ack on both rules with a
reason key that D4 renders and that A2 translates into all six locales.

Candidates are collected once per (species, water type) rather than per cell,
so §13's per-evaluation budget is not multiplied by the grid. The count is a
structural test, not a timing one; the build prints the real cell count and
elapsed time.

Task: E04/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
