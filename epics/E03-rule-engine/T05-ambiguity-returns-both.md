# E03/T05 — Ambiguity: return both, choose neither

| | |
|---|---|
| **Epic** | E03 — Rule engine: resolution, findings and verdicts |
| **Branch** | `epic/03-rule-engine` (shared) |
| **Commit** | `feat(rule_engine): detect an equal-specificity disagreement and return every rival rule` |
| **Depends on** | T04 (a ranked list is the input; equal specificity is only meaningful after ranking) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.3 step 4; §5.1 argument 3; §4.1 "Ambiguity handling"; §6 dialog D4 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 6: a tie that disagrees is returned, never broken — with every tie-break anyone will propose named and refused, including "expired loses" |
| `catchlaw-verdict-contract` | Rule 6 and the `reduce` anti-pattern. This is one of the five arguments in `SPEC.md` §5.1 for why the product is a reference tool, so the wording of the refusal is a legal artefact |
| `catchlaw-conventions-index` | Rule 9 routing: the *detection* is the engine's, the D4 dialog is `lonja-dialogs-and-surfaces` and E10's |
| `dart3-idioms-and-coding-standards` | Comparing value substance without an `==` that includes identity fields |
| `testing-strategy` | Pure unit; and why a three-rival case is not the same test as a two-rival case |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.3 step 4 | "If the top two share `specificity` and disagree, return **both** and render D4. The app never silently reports the more permissive rule" |
| `SPEC.md` | §5.1 argument 3 | *"It refuses to resolve genuine legal ambiguity … An advice product would pick one."* This task is that sentence in code |
| `SPEC.md` | §4.1 "Ambiguity handling" row | The acceptance condition: "Never silently reports the more permissive rule" |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "The tie matrix" (all six rows) and the `outcomeEquals` paragraph beneath it | Every case this task must distinguish, and the exact field list `outcomeEquals` may and may not look at |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rule 6; "A tie is reported, not broken"; the `ranked.first` anti-pattern | The four refused tie-breaks and the WHY clause for the commit body |
| `.claude/skills/catchlaw-verdict-contract/references/the-five-part-carve-out.md` | Part 3, including the "Banned resolutions" paragraph | Seven named ways to resolve a tie, all of which are advice. Also "different specificity is not ambiguity" |
| `.claude/skills/catchlaw-verdict-contract/SKILL.md` | Rule 6 and the "Refusing to resolve ambiguity" block | `reduce((a, b) => a.minLengthCm > b.minLengthCm ? a : b)` named as the defect it is |
| `epics/DECISIONS.md` | D-7 | The refusal is expressed as a returned list of rules, not as a sentence |

## What this delivers

- `packages/rule_engine/lib/src/resolve/conflict.dart` —
  `bool outcomeEquals(Rule, Rule)` and `List<Candidate> findConflict(List<Candidate> ranked, List<Zone> zonePath)`.
- `packages/rule_engine/lib/rule_engine.dart` — exports `conflict.dart`.
- `packages/rule_engine/test/resolve/conflict_test.dart`.

`findConflict` returns the empty list when there is no conflict, and **every** candidate at the top
specificity when there is one — in the source order T04 preserved. It does not construct a verdict;
T10 wraps its output in `Ambiguous`.

## Why it is built this way

**The refusal is a product feature, and it is load-bearing legally.** `SPEC.md` §5.1 lists five
structural commitments that keep CATCHLAW inside the brief's *"reference/logging tool with no
advisory function"* carve-out. The third is this one, stated as a contrast: *"An advice product would
pick one."* `the-five-part-carve-out.md` sharpens it into one of the three things that void the
carve-out outright — *"any silent resolution of a genuine legal conflict"*. So this is not an
engineering preference about tie-breaking, and a future `/simplify` pass that spots "we could just
take the first one" must be answered with this paragraph.

**Every tie-break is refused by name, so that none of them gets reinvented.**
`catchlaw-rule-engine` rule 6 and `the-five-part-carve-out.md` part 3 between them list: `.first`,
newest wins, strictest wins, most permissive wins, expired loses, `sort` by anything, a "recommended"
badge, an autofocused primary action, and rendering one rule with an "another rule may apply"
footnote. The last four are E10's problem; the first five are this file's, and all five produce a
verdict no instrument supports.

**"Expired loses" is the subtle one.** It feels like careful engineering — prefer the rule that is
still in force. It is deletion semantics from T03 wearing a tie-break costume: it means that on the
day one of two conflicting instruments lapses, the app silently starts reporting the other one, with
no warning and no second citation. `resolution-algorithm.md`'s tie matrix has the row explicitly —
*"equal specificity, one expired, differ → `Ambiguous(both)` — expiry is NOT a tie-breaker"*.

**`outcomeEquals` compares substance and nothing else.** `resolution-algorithm.md` fixes both lists.
Compared: kind, threshold, unit, method, closure dates — concretely, for our `Rule`, that is
`isProtected`, `minSizeMm`, `maxSizeMm`, `measurementMethod`, `bagLimit`, `bagLimitUnit`,
`bagLimitPeriod`, `vesselLimit`, and the season windows. Never compared: `id`, `validFrom`,
`validTo`, `citation`, `citationLineageId`, `zoneId`, `specificity`, or row order. The reason is in
the same paragraph: *"Two identically-worded rules from two instruments are not an ambiguity; they
are corroboration."* A national decision and a local order that both say 45 cm total length are two
citations for one fact, and printing D4 over them would teach a fisher to dismiss the dialog.

**Rejected: `Rule`'s own `==`.** It includes `id` and `citation`, so it would report corroboration as
a conflict — the exact inversion. `outcomeEquals` is a separate, explicitly-listed comparison, and a
test asserts that two rules differing only in citation are equal under it.

**All rivals are returned, not two.** `resolution-algorithm.md`'s tie matrix, last row: *"three or
more equal, two agree; one differs → `Ambiguous(all at that specificity)`."* Returning only the two
that disagree would drop a third citation the fisher is entitled to read aloud, and it would make the
returned set depend on which pair the implementation happened to compare first.

**Only the top rung is examined.** `the-five-part-carve-out.md` part 3, table row 2: a zone rule
plus a national rule is a `SingleRule` and the national rule still appears in the rule table.
Different specificity is not ambiguity — T04 already settled it and the settlement is legitimate,
because a narrower instrument beating a wider one is what the instruments themselves say. A conflict
lower down the ladder is not surfaced as a conflict; those candidates become secondary findings in
T09.

**`findConflict` returns candidates, not a verdict.** T10 owns the sealed union. Keeping this task to
a predicate plus a selection means its 15 tests can be read without a `Resolution` existing, and it
means `Ambiguous` has exactly one construction site.

## Tests first

Write all 15 rows before creating `conflict.dart`. Run them. **They must fail.** Row 2 is the one
most likely to pass early against an implementation that compares `Rule` with `==` — if it does, the
implementation is wrong in the direction that reports corroboration as conflict.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `outcomeEquals reports two rules with the same minimum size as equal` | both 450 mm TL | true | The corroboration case: two instruments saying the same thing must not raise D4 |
| 2 | `outcomeEquals ignores the citation` | same 450 mm, different `Citation` and `citationLineageId` | true | `resolution-algorithm.md`: the comparison is substance only. Using `Rule.==` here inverts the whole feature |
| 3 | `outcomeEquals ignores valid_from and valid_to` | same 450 mm, one lapsed in 2024 | true | Expiry is not part of a rule's substance; it is a fact about the instrument's currency |
| 4 | `outcomeEquals reports two different minimum sizes as unequal` | 380 mm and 450 mm | false | The Galician 38 mm / 40 mm trace from `resolution-algorithm.md` |
| 5 | `outcomeEquals reports the same number under two methods as unequal` | 650 mm TL and 650 mm FL | false | `the-five-part-carve-out.md` part 3, row 4: same specificity, different methods is a conflict. 65 cm fork is roughly 71 cm total — the number alone is not the outcome |
| 6 | `outcomeEquals reports differing protected flags as unequal` | one `isProtected` | false | Protection is the highest-precedence outcome; two instruments disagreeing about it is the most consequential conflict there is |
| 7 | `outcomeEquals reports differing closure windows as unequal` | 1 Mar–30 Apr and 1 Mar–15 Apr | false | `resolution-algorithm.md` lists closure dates in the compared set; a fortnight is a real disagreement |
| 8 | `findConflict returns an empty list when the top two differ in specificity` | bank 20 + region 0, disagreeing | `[]` | Different specificity is not ambiguity — a narrower instrument beating a wider one is what the instruments say |
| 9 | `findConflict returns an empty list when two equally specific rules agree` | two bank-20 rules, both 380 mm | `[]` | Corroboration, at the list level this time |
| 10 | `findConflict returns both rules when two equally specific rules disagree` | two bank-20 rules, 380 mm and 400 mm | both, in source order | `SPEC.md` §7.3 step 4. The headline case |
| 11 | `findConflict returns all three when three are equally specific and one differs` | three bank-20 rules, two agreeing | all three, source order | The tie matrix's last row: dropping the two that agree loses a citation and makes the output depend on comparison order |
| 12 | `findConflict returns both rules when one of two disagreeing rivals is expired` | two bank-20 rules, one `isExpired` | both | Rule 6 and the tie matrix: expiry is not a tie-breaker. This is the tie-break that looks most like good engineering |
| 13 | `findConflict returns both rules when a jurisdiction-wide rule disagrees with a region rule` | null-zone rule + region rule, disagreeing | both | Both rank 0 by T04's deliberate choice; this is the conflict that ranking-by-anything would have hidden |
| 14 | `findConflict returns an empty list for a single candidate` | 1 candidate | `[]` | The ordinary path. A conflict detector that fires on one rule fires on every screen |
| 15 | `findConflict returns an empty list for no candidates` | `[]` | `[]` | The boundary a `ranked.first` implementation throws on |

```dart
// packages/rule_engine/test/resolve/conflict_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('outcomeEquals', () {
    test('ignores the citation', () {
      final a = kRuleCambadosMinSize;
      final b = kRuleCambadosMinSize.copyWith(
        citation: kCitationPlanCambados,
        citationLineageId: 'ga-plan-cambados',
      );
      expect(outcomeEquals(a, b), isTrue);
    });

    test('reports the same number under two methods as unequal', () {
      final tl = kRuleKanaadMinSize.copyWith(measurementMethod: MeasurementMethod.totalLength);
      final fl = kRuleKanaadMinSize.copyWith(measurementMethod: MeasurementMethod.forkLength);
      expect(outcomeEquals(tl, fl), isFalse);
    });
  });

  group('findConflict', () {
    test('returns both rules when one of two disagreeing rivals is expired', () {
      final live = Candidate(rule: kRuleCambadosMinSize.copyWith(minSizeMm: 40), isExpired: false);
      final lapsed = Candidate(rule: kRuleCambadosMinSize.copyWith(minSizeMm: 38), isExpired: true);
      final conflict = findConflict([live, lapsed], kGaliciaZonePath);
      expect(conflict, hasLength(2));
      expect(conflict.map((c) => c.rule.minSizeMm), [40, 38]);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `dart test test/resolve/conflict_test.dart` → 15 failures. If row 2 or row 12 passes now,
the test is wrong.

## Implementation outline

1. `lib/src/resolve/conflict.dart`, `outcomeEquals(Rule a, Rule b)` first. Compare the nine
   substantive fields plus the season windows, explicitly, one `&&` per field. **Do not** delegate to
   `Rule.==` and **do not** write it as a negated field-difference list — the explicit form is what a
   reviewer can check against `resolution-algorithm.md`'s sentence.
2. Season-window comparison: two `List<ClosedSeason>` are equal in substance when they have the same
   length and the same set of `(recurrence, startMonth, startDay, endMonth, endDay, startDate,
   endDate)` tuples. Ids and citations are excluded, same reason as above.
3. `findConflict(List<Candidate> ranked, List<Zone> zonePath)`:
   - empty input → `const []`.
   - compute the top specificity with `specificityOf` (T04), take every candidate at it.
   - if fewer than two, `const []`.
   - if every rival `outcomeEquals` the first, `const []`.
   - otherwise return the rivals, **in the order they arrived**. No `sort`, no `reduce`, no `.first`
     escaping the function.
4. Export from the barrel.
5. Re-run the suite. All 15 green; T01–T04 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 15 tests pass, and each failed first.
- [ ] Branch coverage on `conflict.dart` is 100%.
- [ ] `outcomeEquals` reads `id`, `citation`, `citationLineageId`, `validFrom`, `validTo`, `zoneId`
      and `specificity` **nowhere** — checkable by reading the function in one screen.
- [ ] `grep -rnE 'reduce\(|\.first' packages/rule_engine/lib/src/resolve/conflict.dart` returns
      nothing.
- [ ] `findConflict` returns rivals in arrival order, proved by row 10's ordered expectation and not
      only by `hasLength`.
- [ ] A three-rival conflict returns three, not two.
- [ ] The doc comment on `findConflict` cites `SPEC.md` §5.1 argument 3, so that the next reader
      knows why the obvious simplification is refused.

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

Expect `/simplify` to propose collapsing `findConflict` to `ranked.first`. Reject it in the commit
body and cite `SPEC.md` §5.1 argument 3.

## Commit

```
feat(rule_engine): detect an equal-specificity disagreement and return every rival rule

SPEC 7.3 step 4, which is also SPEC 5.1 argument 3: the product refuses to
resolve genuine legal ambiguity, and an advice product would pick one. Every
tie-break is refused by name — first, newest, strictest, most permissive,
and "expired loses", which is the subtle one because it looks like careful
engineering while meaning that the day one of two conflicting instruments
lapses, the app silently starts reporting the other with no second citation.

outcomeEquals compares substance only: kind, thresholds, unit, method and
closure windows. Not id, not validFrom, not citation, not zone. Two
instruments that say the same thing are corroboration, not a conflict, and
raising D4 over them teaches a fisher to dismiss it.

Every rival at the top specificity is returned, not the two that happened to
be compared, so a third citation is never dropped.

Task: E03/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
