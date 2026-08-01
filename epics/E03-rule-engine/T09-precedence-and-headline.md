# E03/T09 — Precedence and the headline finding

| | |
|---|---|
| **Epic** | E03 — Rule engine: resolution, findings and verdicts |
| **Branch** | `epic/03-rule-engine` (shared) |
| **Commit** | `feat(rule_engine): rank findings by the SPEC 7.3 precedence and headline the first failure` |
| **Depends on** | T06, T07, T08 (all six finding kinds must exist before they can be ordered) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.3 final paragraph; §7.1 `rule.is_protected`; §4.1 "Rule evaluation" done-condition |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 7: the precedence is fixed, total, applied exactly **once**, and no surface re-ranks it — with the failure a re-sort produces on a protected sawfish |
| `catchlaw-verdict-contract` | Its edge-case ruling that a species which is protected **and** undersized gets one category plus the full rule table. The engine decides which category; it never decides the words |
| `catchlaw-conventions-index` | Invariant 4's consequence for us: the headline is what E10 gives a glyph and a word, so exactly one finding may hold that slot |
| `dart3-idioms-and-coding-standards` | A closed `const` map beside the enum, and comparator shape |
| `testing-strategy` | Why a two-failure test and a three-failure test are different tests |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.3, the final paragraph | "`is_protected` → closed season → `max_size_mm` → `min_size_mm` → bag limit → vessel limit. The first failure is headlined; the rest are listed as secondary findings" |
| `SPEC.md` | §7.1 `rule` | `is_protected INTEGER NOT NULL DEFAULT 0` — a flag on the row, not a table |
| `SPEC.md` | §4.1 "Rule evaluation" done-condition | "Protected status is reported first, then season, then max size, then min size, then bag limit, then vessel limit. Every finding names its rule row and citation" |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rule 7 and the "Finding precedence and the headline" block; the `findings.sort((a, b) => a.ruleId.compareTo(b.ruleId))` anti-pattern | The six precedence integers, and the WHY: a re-sorting screen headlines "below the minimum" for a protected sawfish — different offence, different penalty, landed fish |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "Finding precedence" (all six rows, with the reason each outranks the next) and the paragraph beneath it | Why `maxSize` beats `minSize`, why `vesselLimit` is last, and "Non-deciding findings are NOT discarded" |
| `.claude/skills/catchlaw-verdict-contract/references/the-five-part-carve-out.md` | "Edge cases", the protected-and-undersized row | One category plus the full rule table |
| `epics/DECISIONS.md` | D-7 | The headline is a `Finding` object, never a sentence and never a category name |

## What this delivers

- `packages/rule_engine/lib/src/findings/protected_finding.dart` — `ProtectedFinding`.
- `packages/rule_engine/lib/src/findings/precedence.dart` — the `const` precedence table,
  `int precedenceOf(FindingKind)`, and
  `({Finding headline, List<Finding> secondary}) rankFindings(List<Finding>)`.
- `packages/rule_engine/lib/src/findings/collect.dart` —
  `Result<List<Finding>> findingsFor(EvaluationRequest, Candidate)`, which runs the four producers
  (protected, closure, size, limits) over one candidate.
- `packages/rule_engine/lib/rule_engine.dart` — exports the three new files.
- `packages/rule_engine/test/findings/precedence_test.dart`,
  `packages/rule_engine/test/findings/collect_test.dart`.

## Why it is built this way

### The order is legal, not cosmetic, and it is applied once

`catchlaw-rule-engine` rule 7 states both halves: the ordering is fixed and total, and **no surface
re-ranks it**. The failure it names is specific. A protected sawfish that is also under the minimum
produces two failing findings. A screen that sorts by whatever came back from the query headlines
"below the minimum", which is a different offence with a different penalty, and which reads to a
fisher as a size problem — solvable by finding a bigger one. The species must never be taken at all.

So the ranking happens exactly once, in `rankFindings`, and both `Decided.headline` and
`Decided.secondary` (T10) are computed from it. E10 renders the list it is given.

### The precedence integers live beside the enum, once

`catchlaw-rule-engine`'s worked block gives them: protected 60, closedSeason 50, maxSize 40, minSize
30, bagLimit 20, vesselLimit 10. They are a `const Map<FindingKind, int>` in `precedence.dart`, and
`precedenceOf` is the only reader. **Rejected:** relying on `FindingKind.index`. The declaration
order in T06 happens to match today, and it is exactly the kind of coupling that breaks silently the
first time somebody adds a seventh kind in a tidy alphabetical position. An explicit map fails loudly
instead: `precedenceOf` throws on a kind with no entry, and a test enumerates `FindingKind.values` to
prove every member has one.

`resolution-algorithm.md` gives the reason for each rung, and they are worth keeping in the doc
comment because they are what stops somebody "fixing" the order: protected is species-level so no
size or season applies; a closure applies to all sizes; a slot maximum protects spawners; a minimum
applies to this individual; a bag limit is per-person; a vessel limit is per-hull and therefore the
widest scope and last.

### The headline is the first *failure*, and the fallback is not `findings.first`

`SPEC.md` §7.3: *"The first failure is headlined; the rest are listed as secondary findings."*
When nothing fails there is still a headline to produce — a species that meets every rule still needs
one thing at the top of the screen. `catchlaw-rule-engine/examples/rule_resolution.dart` writes
`failures.isNotEmpty ? failures.first : findings.first`, and `findings.first` is whatever order the
list happened to be in. That reintroduces query-order dependence, which is the single defect this
whole task exists to remove.

The rule here is therefore uniform: **sort every finding by precedence, then by arrival index; the
headline is the highest-precedence `fails`, or failing that the highest-precedence `passes`, or
failing that the highest-precedence `indeterminate`.** One deterministic function, three tiers, and
the same answer on every run.

`indeterminate` is last on purpose. `resolution-algorithm.md`: *"anything marked `indeterminate`
prints as an open question in the rule table and NEVER as a pass."* Headlining it above a determinate
pass would read as the app having failed; ranking it below one is correct, because a determinate pass
is a stronger statement than an open question. It still headlines when it is all there is, because
`SPEC.md` §4.1's "no-rule-vs-no-data" requirement means an open question must be visible rather than
hidden.

### Nothing is discarded

`resolution-algorithm.md`: *"Non-deciding findings are NOT discarded: a closed-season headline still
carries the size finding in `secondary`, so the rule table can print 'Size rule — 45 cm total length,
satisfied' beneath a closure. The stamp states one thing; the table states everything."* `secondary`
therefore holds every finding except the headline, in the same ranked order — passes and
indeterminates included. It is not a list of "other failures".

### `ProtectedFinding` lands here

`is_protected` is a boolean column with no threshold, no method and no period, so there is no
arithmetic to give it a task of its own — but it is the top rung of this ladder and the task that
publishes the ladder is the one that must be able to construct it. Its `outcome` is `fails` when the
flag is set; a rule with `is_protected = 0` produces no finding at all rather than a passing one,
because "this species is not protected" is not a statement any instrument makes about every species
in it, and printing it would be the app manufacturing a fact.

### `findingsFor` runs the producers in a fixed order

Protected, then closure, then size, then limits — the same order as the ladder, so the pre-sort list
is already close to sorted and a reader of `collect.dart` sees the precedence twice. The sort is
still applied; the ordering here is legibility, not a contract. `findingsFor` is where the three
`Result`-returning producers are unwrapped, so a single content defect in any of them fails the whole
evaluation rather than producing a partial finding list with a silent hole.

### Rejected

- **Ranking inside `Decided`'s constructor.** T10's type would then have logic in it, and the ranking
  would be re-run every time a verdict was copied.
- **A `Comparable` implementation on `Finding`.** It reads well and it puts the legal ordering on a
  type whose `compareTo` could be called from anywhere, including a `sort` on a surface — which rule
  7 bans by name. A free function in one file is greppable.
- **Dropping passing findings from `secondary`.** It halves the payload and it deletes the rule table
  `resolution-algorithm.md` requires.

## Tests first

Write all 18 rows before creating `precedence.dart`. Run them. **They must fail.** Row 3 is the one
that matters most: if it passes now, the finding list is accidentally in the right order and the test
is measuring the fixture, not the function.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `precedenceOf assigns protected 60, closedSeason 50, maxSize 40, minSize 30, bagLimit 20 and vesselLimit 10` | the six kinds | the six integers | The ladder is the task; a wrong rung is a wrong offence named with full confidence |
| 2 | `precedenceOf covers every FindingKind` (loop over `FindingKind.values`, kind interpolated) | each member | an entry exists | A seventh kind added later must fail here rather than sort to an arbitrary place |
| 3 | `rankFindings headlines the protected finding over a failing minimum size` | protected + minSize, both failing, minSize first in the list | headline is `protected` | Rule 7's named failure: the protected sawfish headlined as a size problem, which reads as solvable by finding a bigger one |
| 4 | `rankFindings headlines the closed season over a failing minimum size` | closure + minSize, both failing | headline is `closedSeason` | `resolution-algorithm.md`'s Sha'ri trace, 52 cm on 14 March |
| 5 | `rankFindings headlines the maximum size over a failing minimum size` | both failing | headline is `maxSize` | Slot rules protect spawners; the two size rungs are adjacent and the likeliest pair to be swapped |
| 6 | `rankFindings headlines the bag limit over a failing vessel limit` | both failing | headline is `bagLimit` | Per-person before per-hull — the bottom two rungs, and the pair nothing else in the suite distinguishes |
| 7 | `rankFindings keeps the passing size finding in secondary beneath a closure headline` | closure fails, minSize passes | `secondary` contains the minSize finding | `resolution-algorithm.md`: "the stamp states one thing; the table states everything" |
| 8 | `rankFindings keeps an indeterminate finding in secondary` | closure fails, bagLimit indeterminate | `secondary` contains it | An open question must be visible, per `SPEC.md` §4.1's no-rule-vs-no-data requirement |
| 9 | `rankFindings headlines the highest-precedence pass when nothing fails` | closure passes, minSize passes | headline is `closedSeason` | The fallback the skill's example gets wrong with `findings.first`; this row pins determinism |
| 10 | `rankFindings headlines a determinate pass over an indeterminate finding of higher precedence` | protected indeterminate (never happens today) and minSize passes | headline is the `minSize` pass | An open question is a weaker statement than a determinate pass, and headlining it reads as the app having failed |
| 11 | `rankFindings headlines an indeterminate finding when it is the only one` | one indeterminate bagLimit | headline is that finding | It must be visible rather than hidden; there is nothing else to say |
| 12 | `rankFindings preserves arrival order between two findings of the same kind` | two minSize findings from two candidates | same order in `secondary` | Two rules producing the same kind is ordinary at different specificities; an unstable tie-break reorders the rule table between runs |
| 13 | `rankFindings puts every finding except the headline in secondary` | 4 findings | headline + 3 | `secondary` is "everything else", not "the other failures" |
| 14 | `rankFindings throws on an empty list` | `[]` | `ArgumentError` | There is no headline to produce, and a nullable return would push the check into T10 and every later caller. T10 never calls it with an empty list |
| 15 | `findingsFor emits a protected finding for a rule with is_protected set` | `isProtected: true` | one `ProtectedFinding`, `fails` | The top rung, constructed |
| 16 | `findingsFor emits no protected finding for a rule with is_protected clear` | `isProtected: false` | no `ProtectedFinding` | "Not protected" is not a statement any instrument makes; printing it manufactures a fact |
| 17 | `findingsFor emits the closure, size and limit findings for a rule carrying all three` | full rule | 4 findings across 4 kinds | The producers are all wired, not just the one the last test touched |
| 18 | `findingsFor returns a Failure when any producer reports a content defect` | rule with a size column and no method | `Failure(MalformedRule)` | A partial finding list with a silent hole is worse than a refusal E04 can act on |

```dart
// packages/rule_engine/test/findings/precedence_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('precedenceOf', () {
    for (final kind in FindingKind.values) {
      test('covers $kind', () {
        expect(precedenceOf(kind), isPositive);
      });
    }
  });

  group('rankFindings', () {
    test('headlines the protected finding over a failing minimum size', () {
      final ranked = rankFindings([kFindingMinSizeFails, kFindingProtected]);
      expect(ranked.headline.kind, FindingKind.protected);
      expect(ranked.secondary.single.kind, FindingKind.minSize);
    });

    test('headlines a determinate pass over an indeterminate finding of higher precedence', () {
      final ranked = rankFindings([kFindingClosureIndeterminate, kFindingMinSizePasses]);
      expect(ranked.headline.kind, FindingKind.minSize);
      expect(ranked.headline.outcome, FindingOutcome.passes);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `dart test test/findings/precedence_test.dart test/findings/collect_test.dart` → 18 failures
(row 2 expands to six). If row 3 passes now, reorder the fixture list and watch it fail.

## Implementation outline

1. `lib/src/findings/protected_finding.dart`: `final class ProtectedFinding extends Finding`, no
   fields of its own beyond the base's `citation` and `isExpired`. `kind` returns
   `FindingKind.protected`; `outcome` returns `FindingOutcome.fails`, unconditionally — it is only
   ever constructed for a rule whose flag is set.
2. `lib/src/findings/precedence.dart`:
   - `const _precedence = <FindingKind, int>{ ... }` with the six integers.
   - `int precedenceOf(FindingKind kind)` — `_precedence[kind]!`, with a doc comment naming the
     reason each rung outranks the next.
   - `({Finding headline, List<Finding> secondary}) rankFindings(List<Finding> findings)`:
     `ArgumentError` on empty; decorate with the arrival index; sort by outcome tier
     (`fails` 2, `passes` 1, `indeterminate` 0) descending, then precedence descending, then index
     ascending; headline is the first, `secondary` is the rest.
3. `lib/src/findings/collect.dart`:
   `Result<List<Finding>> findingsFor(EvaluationRequest request, Candidate candidate)` — protected,
   then one `ClosedSeasonFinding` per season window, then `sizeFindings`, then `limitFindings`.
   Unwrap each `Result`; the first `Failure` short-circuits.
4. Export the three files from the barrel.
5. Re-run the whole suite. All 18 green; T01–T08 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 tests pass, and each failed first.
- [ ] Branch coverage on `precedence.dart`, `protected_finding.dart` and `collect.dart` is 100%.
- [ ] `grep -rn 'FindingKind.*index' packages/rule_engine/lib` returns nothing — the enum's
      declaration order is never load-bearing.
- [ ] The six precedence integers appear exactly once in `lib/`.
- [ ] `rankFindings` is the only place in the package that orders findings; no other file contains a
      `.sort` over a `List<Finding>`.
- [ ] `secondary` contains every non-headline finding, including passes and indeterminates.
- [ ] The doc comment on `_precedence` carries the six reasons from
      `resolution-algorithm.md`'s precedence table.

## Gates

```bash
cd packages/rule_engine && dart format --set-exit-if-changed . && dart analyze && dart test
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh packages/rule_engine/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(rule_engine): rank findings by the SPEC 7.3 precedence and headline the first failure

protected, closed season, max size, min size, bag limit, vessel limit —
applied exactly once, here, so no surface can re-rank it. A screen that
sorts by query order headlines "below the minimum" for a protected sawfish:
a different offence, a different penalty, and a sentence a fisher reads as
solvable by finding a bigger one.

The integers live in one const map rather than in FindingKind.index. The
declaration order matches today and would break silently the first time
somebody inserts a seventh kind alphabetically; a map with a test over
FindingKind.values fails loudly instead.

The headline fallback is not findings.first. When nothing fails, the ranking
is by outcome tier then precedence then arrival index — deterministic on
every run — because the skill example's findings.first reintroduces exactly
the query-order dependence this task removes. Indeterminate ranks below a
determinate pass, and still headlines when it is all there is.

Nothing is discarded: secondary carries every non-headline finding,
including the ones that passed, because the stamp states one thing and the
rule table states everything.

Task: E03/T09
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
