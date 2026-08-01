# E03/T03 — Candidate selection, and why expiry does not delete

| | |
|---|---|
| **Epic** | E03 — Rule engine: resolution, findings and verdicts |
| **Branch** | `epic/03-rule-engine` (shared) |
| **Commit** | `feat(rule_engine): select candidates on valid_from only and tag expiry instead of dropping rows` |
| **Depends on** | T01 (the models), T02 (`Result`) |
| **Size** | L |
| **Spec** | `SPEC.md` §7.3 step 1 and its "This is a correctness fix, not a nicety" paragraph; §7.1 `rule`; §4.1 "Expired-rule handling"; §14 the expiry test |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 1 is this task. It also supplies the lineage-collapse key, rule 3 (the date is a parameter), rule 4 (the fixed stage order), and the `where((t) => t.validTo.isBiggerThanValue(now))` anti-pattern by name |
| `catchlaw-verdict-contract` | Rule 10: an expired ruleset is evaluated and shown, never withheld. This task is the engine half of that; withholding is itself advice |
| `catchlaw-conventions-index` | Invariant 5 and its proof: `check_app_invariants.sh` check 6 greps for expiry used as a gate |
| `error-handling-typed-results` | Which of this stage's bad inputs are `Failure` and which are simply no candidates |
| `dart3-idioms-and-coding-standards` | Function length and the record-versus-class call for `Candidate` |
| `testing-strategy` | Frozen dates, no wall clock, pure unit |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.3 step 1 **and** the paragraph beginning "This is a correctness fix" | The predicate, the collapse key, the `is_expired` tag, and the argument this whole task exists to implement. Read the paragraph before writing a line |
| `SPEC.md` | §7.1 `rule` table | `valid_from TEXT NOT NULL`, `valid_to TEXT` with its `-- expiry does NOT delete` comment, `water_type CHECK (... 'salt','fresh','both')`, `idx_rule_lookup` |
| `SPEC.md` | §4.1 "Expired-rule handling" and "Unknown species" rows | "A verdict is still produced — this is tested in §14" |
| `SPEC.md` | §14, the two clock bullets | The device-level expiry test and the clock-backwards test this task makes reproducible as unit tests |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "The request", "The four stages, in order", "The expiry axis", "Edge cases" | The request field list, the stage table's "Drops rows?" column, the four-row expiry table including the inclusive boundary, and the same-lineage-same-`valid_from` ruling |
| `.claude/skills/catchlaw-rule-engine/examples/rule_resolution.dart` | Lines 66–101 and the comment block at 67–72 | The pipeline shape, and the two places this task deliberately diverges from it (below) |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rules 1, 3, 4; "Expiry tags a rule; it never removes one" | The WHY clauses, quotable in the commit body |
| `FLUTTER_GUIDE.md` | §1.9 | Why this logic is a domain package and not a repository method |
| `epics/DECISIONS.md` | D-1 | `packages/rule_engine/` |

## What this delivers

- `packages/rule_engine/lib/src/date.dart` — `DateTime parseIsoDate(String)`, UTC midnight, the one
  place a date string becomes a date.
- `packages/rule_engine/lib/src/resolve/evaluation_request.dart` — `EvaluationRequest`, the engine's
  complete input contract.
- `packages/rule_engine/lib/src/models/catch_tally.dart` — `CatchTally`, the counts field of that
  contract, as a `const` value type with its fields and no behaviour. T08 adds its two period
  accessors when it has a caller for them.
- `packages/rule_engine/lib/src/resolve/candidate.dart` — `Candidate`, a rule plus its `isExpired`
  tag.
- `packages/rule_engine/lib/src/resolve/candidate_selection.dart` —
  `Result<List<Candidate>> selectCandidates(EvaluationRequest, Iterable<Rule>)`: stage 1 (select) and
  stage 2 (lineage collapse), with the tag applied.
- `packages/rule_engine/lib/rule_engine.dart` — exports the three new public files.
- `packages/rule_engine/test/resolve/candidate_selection_test.dart`,
  `packages/rule_engine/test/resolve/expiry_test.dart`, `packages/rule_engine/test/date_test.dart`.

## Why it is built this way

### The one thing this task must get right

The selection predicate is `jurisdiction` **and** `species_id` **and** `water_type` **and**
`valid_from <= date`. There is no fourth clause. `valid_to` is not consulted, not compared, not
mentioned inside a `where`, and not used to order anything.

`SPEC.md` §7.3 spends a paragraph on why, and it is worth restating the shape of the failure because
it is not the shape most expiry bugs have. The first draft filtered on `date < valid_to`. That filter
is correct-looking, passes every test written on a Tuesday, and is wrong on exactly one class of row:
the annual instrument. A Spanish *orden de vedas* is reissued every year and typically lapses on 30
April; a Brazilian *piracema* portaria lapses at the end of the closure it declares. Those are
precisely the rows that carry a non-null `valid_to` — a permanent ministerial decision carries none.
So the filter does not degrade gracefully. On 1 May, every Galician shellfish rule disappears at once
and every one of those species falls through to "no rule recorded", which the app then renders as a
state that explicitly *does not imply legality* but which a fisher reads as an empty page.

The consequence §7.3 names is not "a wrong answer". It is that the product changes category. A
bundled snapshot with a known as-of date is a defensible thing to ship offline: it is a printed
booklet, and a booklet does not stop being a booklet on 1 May. A snapshot that silently empties
itself when its instruments lapse is a live-data product that has no way to fetch live data — the
brief's auto-reject, arrived at by accident. `SPEC.md` §4.7 and §14 both promise a verdict *plus* an
amber warning, and a filtered row can produce neither.

So expiry is a tag: `isExpired = validTo != null && validTo < on`. The row stays in the result set at
full strength, its numbers intact, and E10 renders an ochre bar above an otherwise unchanged verdict.

**The boundary is inclusive.** `resolution-algorithm.md`'s expiry table gives the case explicitly: a
rule with `valid_to = 2026-06-30` evaluated **on** 2026-06-30 is *not* expired. The last day counts,
because an instrument that is in force "until 30 June" is in force on 30 June. `isBefore` gives this
for free and `isAfter`-flavoured phrasings do not, which is also why `check_rule_engine.sh` check 2
treats `isBefore` as legitimate and `isAfter(` near `validTo` as a filter.

### Stage 2, and the tie the example gets wrong

Collapse to the greatest `valid_from` per `(zoneId, citationLineageId)`. The key is a pair for a
reason `resolution-algorithm.md` states plainly: a 2018 amendment supersedes the 2015 instrument it
amends because they share a lineage; a Fujairah local order with a different lineage survives
untouched and reaches stage 3 on its own merits. Collapsing on `zone_id` alone would let one
jurisdiction's newest instrument delete another authority's rule for the same water.

**Divergence from `examples/rule_resolution.dart`.** The example writes:

```dart
if (!latest.containsKey(k) || r.validFrom.isAfter(latest[k]!.validFrom)) latest[k] = r;
```

On an exact `valid_from` tie within one lineage, that keeps whichever row the iterator yielded first.
The same skill's `resolution-algorithm.md` edge-case table rules the other way: *"Two rows, same
lineage, same `valid_from` — content bug, surface it as an ambiguity, do not pick."* The reference
document wins, and the reason is the one the whole epic turns on: the map form makes a silent choice
between two instruments, which is the advisory act
`catchlaw-verdict-contract/references/the-five-part-carve-out.md` lists as one of the three things
that void the carve-out. So the collapse keeps **every** row at the maximum `valid_from` for its key,
and a tie arrives at T04 and T05 as two candidates that will be reported as `Ambiguous`. The
implementation is a group-then-filter, not a `Map` assignment.

### Water type, and the second thing the example gets wrong

`SPEC.md` §7.1 constrains `water_type` to `salt`, `fresh` or **`both`**. The example's predicate is
`r.waterType == req.waterType`, which drops every `both` row — and `both` is what a jurisdiction-wide
rule that applies in an estuary as well as at sea is authored as. The predicate is therefore:

```dart
rule.waterType == WaterType.both || rule.waterType == request.waterType
```

and `EvaluationRequest.waterType` asserts it is not `both`, because a fisher is standing in one or
the other. (`catchlaw-rule-engine/examples/rule_resolution.dart` also uses a `WaterType` of
`marine`/`brackish`/`fresh`; `SPEC.md` §7.1's `CHECK` constraint is authoritative and T01 already
followed it.)

### The whole request is declared here

`EvaluationRequest` gains all of its fields in this commit, including `landing`, `tally` and
`species`, which are not read until T07, T08 and T11. **Rejected:** growing it one required field per
task. A value type that gains a required field in five separate commits forces five rewrites of every
construction site inside one epic, and the diff of each of those tasks stops being about the thing it
is named after. The request is the engine's published contract and it is published once.

`/simplify` will flag the three unread fields in this commit. That finding is rejected in the commit
body, per `CONVENTIONS.md` §8 — which allows a finding to be resolved *or explicitly rejected*.

### No `Clock` interface in this package

`catchlaw-rule-engine` rule 3 requires the evaluation date to be a parameter and forbids
`DateTime.now()` under `lib/`. Both hold: `on` is a required field of the request.
`examples/rule_resolution.dart` additionally declares an `abstract interface class Clock` inside the
engine. **Rejected here.** With `on` required, a `Clock` in `lib/` would have no caller inside the
package, and `/simplify` would be correct to delete it. The seam rule 3 asks for is the required
field; the wall-clock implementation lands in E10 where something calls it.

## Tests first

Write every row before creating `candidate_selection.dart`. Run them. **They must fail.** Rows 5–11
are the ones that would pass against a `valid_to` filter on most days of the year — if any of them
passes now, the fixture date is wrong, not the implementation.

Every test uses a frozen `on`. No test constructs a date from the system clock.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `parseIsoDate returns a UTC midnight date` | `'2026-07-30'` | `DateTime.utc(2026, 7, 30)`, `isUtc` true | `DateTime.parse('2026-07-30')` returns **local** midnight; every comparison in the engine would then depend on the machine's timezone |
| 2 | `parseIsoDate rejects a value that is not a date` | `'not-a-date'` | throws `FormatException` | This is a mapper defect, not a content defect: E05 must never hand the engine a non-date, and a silent fallback would date a rule to the epoch |
| 3 | `selectCandidates keeps a rule whose jurisdiction, species and water type all match` | 1 matching rule | 1 candidate | The baseline; without it every other row is unfalsifiable |
| 4 | `selectCandidates drops a rule for another species` | 1 rule, different `speciesId` | 0 candidates | Stage 1's cheapest filter, and the one an index would otherwise be trusted to do |
| 5 | `selectCandidates keeps a rule whose water type is both when the request is salt` | rule `both`, request `salt` | 1 candidate | The `both` member exists in `SPEC.md` §7.1 and the skill's example predicate drops it; a jurisdiction-wide rule would vanish in salt water |
| 6 | `selectCandidates keeps a rule whose water type is both when the request is fresh` | rule `both`, request `fresh` | 1 candidate | The mirror case — one-sided handling of `both` is the likeliest partial fix |
| 7 | `selectCandidates drops a rule whose water type is fresh when the request is salt` | rule `fresh`, request `salt` | 0 candidates | The over-correction guard: `both` must widen the match, not disable it |
| 8 | `selectCandidates keeps a rule whose valid_from equals the evaluation date` | `validFrom == on` | 1 candidate | `SPEC.md` §7.3 says `valid_from <= date`; a strict `<` makes an instrument inapplicable on its own commencement day |
| 9 | `selectCandidates drops a rule whose valid_from is in the future` | `validFrom` = `on` + 1 day | 0 candidates | `resolution-algorithm.md` edge case: it is not law yet. An authored future amendment must not take effect early |
| 10 | `selectCandidates keeps a rule whose valid_to is in the past` | `validTo` two years before `on` | **1 candidate** | **The headline case.** `SPEC.md` §14's expiry test in unit form: a lapsed *orden de vedas* still produces a rule |
| 11 | `selectCandidates tags is_expired when valid_to is before the date` | as row 10 | `isExpired == true` | The tag is what E10's ochre bar reads; a kept row with no tag is a silently stale verdict |
| 12 | `selectCandidates leaves is_expired false when valid_to equals the date` | `validTo == on` | `isExpired == false` | `resolution-algorithm.md`'s expiry table, row 4: the boundary is inclusive, the last day counts |
| 13 | `selectCandidates leaves is_expired false when valid_to is null` | `validTo: null` | `isExpired == false` | `product-invariants.md` §5: a pack with no `validUntil` is valid, never expired. A null-as-expired bug would flag every permanent decision |
| 14 | `selectCandidates leaves is_expired false when valid_to is after the date` | `validTo` = `on` + 1 year | `isExpired == false` | The ordinary in-force case, so rows 11–13 cannot all be satisfied by returning a constant |
| 15 | `selectCandidates keeps the greatest valid_from within one citation lineage` | 2015 and 2018 rows, same lineage, same zone | 1 candidate, the 2018 row | `SPEC.md` §7.3 step 1; a superseded 2015 row outranking its own 2018 amendment is `catchlaw-rule-engine` rule 4's named failure |
| 16 | `selectCandidates keeps both rows when two lineages cover one zone` | 2015 MD lineage + a local-order lineage, same zone | 2 candidates | The collapse is per lineage; collapsing on zone alone deletes another authority's rule |
| 17 | `selectCandidates keeps both rows when two rows share a lineage and a valid_from` | identical `validFrom`, same lineage and zone | **2 candidates** | `resolution-algorithm.md` edge case: a content bug is surfaced as an ambiguity in T05, never resolved by iteration order |
| 18 | `selectCandidates keeps an expired row that supersedes a live one in the same lineage` | 2015 row no `validTo`, 2024 row `validTo` in the past | 1 candidate, the 2024 row, `isExpired` true | Expiry is not an input to the collapse. "Expired loses" is rule 1's deletion semantics wearing a tie-break costume |
| 19 | `selectCandidates returns an empty list when nothing matches` | 3 rules, none matching | `Ok([])` | Empty is a legitimate `Ok`, not a `Failure` — T11 turns it into a legal statement |
| 20 | `selectCandidates returns a Failure when a size rule carries no threshold` | `minSizeMm` and `maxSizeMm` both null on a row with a `measurementMethod` | `Failure(MalformedRule)` | The T02 boundary in practice: a content defect has no legal statement to make, so it may not become `Ok` |
| 21 | `selectCandidates evaluates a date two years before every valid_from without throwing` | `on` = 2024-01-01, rules from 2026 | `Ok([])` | `SPEC.md` §14: "set the clock backwards two years … without crashing". Date arithmetic that assumes forward time fails here first |
| 22 | `EvaluationRequest rejects a water type of both` | `waterType: both` | `AssertionError` | The fisher stands in salt or fresh water. A `both` request would make row 7's guard meaningless |

```dart
// packages/rule_engine/test/resolve/expiry_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:rule_engine/testing/utils/result.dart';
import 'package:test/test.dart';

const _on = '2026-07-30';

EvaluationRequest _request({String on = _on}) => EvaluationRequest(
      jurisdictionId: 7,
      speciesId: 42,
      species: kSpeciesHamour,
      waterType: WaterType.salt,
      zonePath: const <Zone>[kZoneUae, kZoneRasAlKhaimah],
      on: on,
      contentCheckedOn: '2026-07-14',
      searched: const <Citation>[kCitationMd580],
    );

void main() {
  group('selectCandidates', () {
    test('keeps a rule whose valid_to is in the past', () {
      final rule = kRuleHamourMinSize.copyWith(validTo: '2024-06-30');
      final candidates = selectCandidates(_request(), [rule]).asOk.value;
      expect(candidates, hasLength(1));
      expect(candidates.single.rule.minSizeMm, 450);
    });

    test('tags is_expired when valid_to is before the date', () {
      final rule = kRuleHamourMinSize.copyWith(validTo: '2024-06-30');
      expect(selectCandidates(_request(), [rule]).asOk.value.single.isExpired, isTrue);
    });

    test('leaves is_expired false when valid_to equals the date', () {
      final rule = kRuleHamourMinSize.copyWith(validTo: _on);
      expect(selectCandidates(_request(), [rule]).asOk.value.single.isExpired, isFalse);
    });

    test('keeps both rows when two rows share a lineage and a valid_from', () {
      final a = kRuleHamourMinSize.copyWith(id: 1, minSizeMm: 450);
      final b = kRuleHamourMinSize.copyWith(id: 2, minSizeMm: 500);
      expect(selectCandidates(_request(), [a, b]).asOk.value, hasLength(2));
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `dart test test/resolve/ test/date_test.dart` → 22 failures. If row 10, 11 or 17 passes now,
the test is wrong.

## Implementation outline

1. `lib/src/date.dart`: `DateTime parseIsoDate(String iso)` → split on `-`, `DateTime.utc(y, m, d)`,
   `FormatException` on anything else. Do **not** call it `normaliseDate` —
   `check_rule_engine.sh` check 4 greps `(String|_)[A-Za-z]*[Nn]ormali[sz]e[A-Za-z]*\(` outside
   `normalise.dart` and would fail the build.
2. `lib/src/resolve/evaluation_request.dart`: a `final class` with the ten fields from
   `resolution-algorithm.md`'s request table, adapted to the schema's integer ids. `const`
   constructor, `assert(waterType != WaterType.both)`, `assert(zonePath.isNotEmpty)`,
   `assert(searched.isNotEmpty)`, and a `copyWith` — later tasks vary one field of one request per
   test, and T11's `copyWith(species: null)` needs the same nullable-wrapper sentinel `Rule` uses.
   `lib/src/models/catch_tally.dart` lands here too: fields only, `const`, no behaviour until T08.
3. `lib/src/resolve/candidate.dart`: `final class Candidate { final Rule rule; final bool isExpired; }`.
   A class rather than a record because it is the value five later tasks pass around and a named
   type is what makes `List<Candidate>` readable in their signatures.
4. `lib/src/resolve/candidate_selection.dart`:
   a. Validate each row that survives stage 1 against the T02 defect list; return `Failure` on the
      first defect, naming the rule id and the field.
   b. Stage 1 filter — four clauses, `valid_to` absent. Write the comment from
      `examples/rule_resolution.dart` lines 67–72 above it, in your own words, so the next reader
      knows the omission is deliberate.
   c. Stage 2 — group by `(zoneId, citationLineageId)`, compute the maximum `validFrom` per group,
      keep **every** row equal to it.
   d. Map each survivor to a `Candidate`, computing
      `isExpired = validTo != null && parseIsoDate(validTo).isBefore(parseIsoDate(on))`.
      Use `isBefore`. Never `isAfter` on a line that mentions `validTo`.
5. Export the three files from the barrel.
6. Re-run the suite. All 22 green, T01 and T02 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 22 tests pass, and each failed first.
- [ ] Branch coverage on `lib/src/resolve/` and `lib/src/date.dart` is 100%.
- [ ] `grep -rn 'validTo' packages/rule_engine/lib` shows the field, one `isBefore` and nothing else.
      No `.where`, no `removeWhere`, no `retainWhere`, no `takeWhile`, no `isAfter` on those lines.
- [ ] `grep -rn 'DateTime.now()' packages/rule_engine/lib` returns nothing.
- [ ] The stage-1 predicate has exactly four clauses and one of them is not `valid_to`.
- [ ] A `valid_from` tie inside one lineage yields two candidates, not one.
- [ ] `EvaluationRequest` is declared complete; the commit body records `/simplify`'s unread-field
      finding as rejected, with the reason.
- [ ] No `Clock` type exists under `packages/rule_engine/lib/`.

## Gates

```bash
cd packages/rule_engine && dart format --set-exit-if-changed . && dart analyze && dart test
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh packages/rule_engine/lib
```

`check_rule_engine.sh` check 2 is the one that matters here. It is a heuristic grep and passing it is
a floor, not proof — row 10 of the test table is the proof.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(rule_engine): select candidates on valid_from only and tag expiry instead of dropping rows

SPEC 7.3 step 1: jurisdiction, species, water type and valid_from <= date.
There is no valid_to clause and there must never be one. The first draft's
date < valid_to filter is wrong on exactly one class of row — the annual
instrument, which is the only kind that carries a valid_to at all — so on
the day a Spanish orden de vedas or a Brazilian piracema portaria lapses,
every species it covered falls through to "no rule recorded". That turns a
frozen snapshot with a known as-of date into a live-data product with no way
to fetch live data. Expiry is a tag; the row stays, numbers intact, and E10
puts an ochre bar above an unchanged verdict.

The expiry boundary is inclusive: valid_to on the evaluation date is not
expired, because an instrument in force until 30 June is in force on 30 June.

Two deliberate divergences from the skill's worked example, both toward
refusing to choose. The lineage collapse keeps every row at the maximum
valid_from rather than whichever the iterator saw first, so the same-lineage
tie its own reference calls a content bug arrives at T05 as an ambiguity.
And the water-type predicate admits 'both', which strict equality drops —
that member is how a jurisdiction-wide rule is authored.

/simplify flagged landing, tally and species as unread in this commit.
Rejected: the request is the engine's published contract and is published
once; they are read at T07, T08 and T11.

Task: E03/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
