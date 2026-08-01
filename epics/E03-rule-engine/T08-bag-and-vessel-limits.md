# E03/T08 — Bag limit and vessel limit

| | |
|---|---|
| **Epic** | E03 — Rule engine: resolution, findings and verdicts |
| **Branch** | `epic/03-rule-engine` (shared) |
| **Commit** | `feat(rule_engine): evaluate bag and vessel limits against the tally for the rule's period` |
| **Depends on** | T07 (the finding shape the size findings established) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.1 `rule.bag_limit`, `bag_limit_unit`, `bag_limit_period`, `vessel_limit`; §7.2 `catch`/`trip`; §7.3 precedence; §4.1; §4.5 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 7 (bag limit ranks fifth, vessel limit sixth and last) and the "bag limit with no catch log — indeterminate" edge case |
| `catchlaw-verdict-contract` | Rule 3: "Above the daily bag — 9 recorded, limit 6" — both integers come from here. And the edge-case ruling that a limit rule with no number prints its transcribed wording rather than a paraphrase |
| `catchlaw-conventions-index` | Rule 11: the tally is derived from `user.db` and no identifier leaves the device; the engine receives counts, never a fisher |
| `dart3-idioms-and-coding-standards` | Enhanced enums for the unit and the period; integer arithmetic over floating-point mass |
| `error-handling-typed-results` | A `bag_limit` with a null unit or period is a content defect, not a limit that never binds |
| `testing-strategy` | Table-driven over the three periods with the period interpolated into the description |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.1 `rule` | `bag_limit INTEGER`, `bag_limit_unit CHECK (... 'count','kg')`, `bag_limit_period CHECK (... 'day','trip','season')`, and `vessel_limit INTEGER` with **no** unit and **no** period |
| `SPEC.md` | §7.2 | Where a tally comes from: the writable `user.db`, which E13 fills and E05 reads |
| `SPEC.md` | §7.3, precedence sentence | Bag limit fifth, vessel limit sixth |
| `SPEC.md` | §4.1 "Rule evaluation" row | "(jurisdiction, zone, species, date, length, **today's tally**)" — the tally is a declared input, not an afterthought |
| `SPEC.md` | §4.5 | The catch log is entirely local, and a tally exists only if the fisher has been logging |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "Finding precedence" rows 5 and 6; "Edge cases", the bag-limit row | "per-person, per-day"; "per-hull, the widest scope, last"; "bag limit with no catch log — `indeterminate`; the app records nothing about the fisher by default" |
| `.claude/skills/catchlaw-verdict-contract/references/the-five-part-carve-out.md` | "Edge cases", first row | "A gear or bag-limit rule with no number — print the transcribed wording and its citation; do not paraphrase" |
| `.claude/skills/catchlaw-verdict-contract/SKILL.md` | Rule 3 | The margin sentence, which needs the recorded count and the limit as two integers |
| `epics/DECISIONS.md` | D-7 | The period and the unit travel as enums; "daily" is a word E06 owns |

## What this delivers

- `packages/rule_engine/lib/src/models/catch_tally.dart` — the type arrived with the request in T03;
  this task gives it `int? countFor(LimitPeriod)` and `int? gramsFor(LimitPeriod)`, the two accessors
  a caller finally exists for.
- `packages/rule_engine/lib/src/findings/limit_finding.dart` — `BagLimitFinding`,
  `VesselLimitFinding`, and `Result<List<Finding>> limitFindings(Rule, CatchTally?, {required bool isExpired})`.
- `packages/rule_engine/lib/rule_engine.dart` — exports both new files.
- `packages/rule_engine/test/findings/limit_finding_test.dart`.

## Why it is built this way

### The tally is an input, and its absence is indeterminate

`SPEC.md` §4.1 lists today's tally among the rule engine's inputs alongside date and length, so this
is not an optional enrichment. But `SPEC.md` §4.5 makes the catch log a feature the fisher chooses to
use, and `resolution-algorithm.md` states the consequence: *"bag limit with no catch log —
`indeterminate`; the app records nothing about the fisher by default."*

A `null` tally therefore produces a finding with the limit stated, the recorded count absent and an
`indeterminate` outcome. It is not a pass. Reporting a bag limit as satisfied because the app has no
data is the same error class as reporting an untranscribed species as legal, and
`resolution-algorithm.md` closes with the rule that covers both: *"anything marked `indeterminate`
prints as an open question in the rule table and NEVER as a pass."*

### Mass is counted in grams, as an integer

`bag_limit_unit` may be `kg`, and `bag_limit` is an `INTEGER` — so the instrument's number is a whole
number of kilograms. The tally is carried in **grams**, and the comparison is
`tally.gramsFor(period) > limit * 1000`. Kilograms as `double` would put `0.1 + 0.2 == 0.30000000000000004`
on the path between a fisher's eighth fish and a fine, and the failure would appear only at the
boundary, which is the only place anybody looks. Integer grams also match how E13 will store a
catch's mass and how E17 will export it.

### The period selects which tally is read, and the rule owns the period

`bag_limit_period` is one of `day`, `trip`, `season`. `CatchTally` exposes
`int countFor(LimitPeriod)` and `int gramsFor(LimitPeriod)` and the finding reads the one the *rule*
names. **Rejected:** defaulting an absent period to `day`. `resolution-algorithm.md` calls the bag
limit "per-person, per-day" as the common case, but a Galician *season* quota compared against a
day's tally passes on every single day of a season it has already exhausted — a false pass, at scale,
in the direction that costs the fisher. An absent period on a row that has a `bag_limit` is a
`Failure(MalformedRule)`.

### The vessel limit carries no period, because the schema gives it none

`SPEC.md` §7.1 gives `bag_limit` a unit column and a period column and gives `vessel_limit` neither.
The engine may not state a period an instrument did not give it — that would be the app interpreting,
which `the-five-part-carve-out.md` part 4 forbids. So `VesselLimitFinding` carries `limit` and
`recorded` as counts and no period at all, and E10 prints the transcribed wording from the rule's
`notes_key` beside it (the carve-out's first edge case: *"print the transcribed wording and its
citation; do not paraphrase"*).

The `recorded` value it compares is the **vessel** tally, which is a different number from the
personal one and which `SPEC.md` §7.2 does not currently distinguish either. `CatchTally` therefore
carries `vesselCount` as its own field rather than reusing the day count, so that E13 can fill it
correctly when the schema supports it and the engine does not silently equate one fisher with one
hull in the meantime. When `vesselCount` is null the finding is `indeterminate`. Epic risk 2 records
the schema question.

### Boundaries: the limit is the last permitted value

`bag_limit = 6` means six are permitted. `fails` is therefore `recorded > limit`, strictly — six
recorded is a pass, seven is a failure. The margin sentence in `catchlaw-verdict-contract` rule 3
reads *"Above the daily bag — 9 recorded, limit 6"*, which is only correct under that reading.

**The tally is what has already been recorded, not what is in hand.** The engine compares the
existing tally against the limit and states the fact. It does not add one for the fish being checked,
because whether that fish is being kept is a decision the fisher makes and the app does not model —
adding it would make the finding a prediction about an action, which is the advisory shape the
carve-out excludes. E13 records the catch, the tally changes, and the next check states the new fact.

### Rejected

- **One `LimitFinding` with a `bool isVessel`.** T09 ranks on `kind`, and the two limits are the two
  lowest rungs of the precedence ladder for a stated reason — per-person versus per-hull. Two `final`
  subclasses make that visible.
- **Reading a bag limit's unit from the tally.** The unit is a property of the instrument, not of the
  fisher's log. A `kg` rule compared against a count is a `Failure(MalformedRule)` if the tally cannot
  answer in grams, never a silent unit swap.
- **Modelling "no number" limits here.** `the-five-part-carve-out.md`'s first edge case is a rule
  whose limit is words rather than a number. In `SPEC.md` §7.1 that row simply has a null
  `bag_limit` and a `notes_key`, so it produces no limit finding and E10 prints the note. Nothing to
  build.

## Tests first

Write all 19 rows before creating `limit_finding.dart`. Run them. **They must fail.** Rows 2 and 3
are the boundary pair; an implementation using `>=` passes one and fails the other.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `limitFindings reports a bag limit failure above the limit` | 9 recorded, limit 6, day, count | `BagLimitFinding`, `fails` | `catchlaw-verdict-contract` rule 3's worked sentence, "9 recorded, limit 6" |
| 2 | `limitFindings reports a bag limit pass exactly at the limit` | 6 recorded, limit 6 | `passes` | The limit is the last permitted value; a `>=` reading criminalises the sixth fish |
| 3 | `limitFindings reports a bag limit failure one above the limit` | 7 recorded, limit 6 | `fails` | The other side of the same boundary, so a constant cannot satisfy both |
| 4 | `limitFindings carries the recorded count and the limit` | as row 1 | `recorded` 9, `limit` 6 | The margin is always printed, so the engine always produces both integers |
| 5 | `limitFindings reads the tally for the period the rule names` (loop over `day`, `trip`, `season`, period interpolated into the description) | tally 2/5/40, limit 6 | only the season row fails | The period is the rule's, not a default. A season quota compared against a day's tally passes every day of an exhausted season |
| 6 | `limitFindings compares a kg bag limit against the tally in grams` | 21,000 g recorded, limit 20 kg | `fails` | `SPEC.md` §7.1 allows `kg`; the conversion happens once, here, in integers |
| 7 | `limitFindings reports a kg bag limit pass exactly at the limit` | 20,000 g, limit 20 kg | `passes` | The kg boundary, which floating-point kilograms get wrong and only at this value |
| 8 | `limitFindings reports indeterminate when there is no tally` | `tally: null`, limit 6 | `indeterminate` | `resolution-algorithm.md` edge case. Not a pass: the same error class as reporting an untranscribed species legal |
| 9 | `limitFindings carries the limit when there is no tally` | as row 8 | `limit` 6, `recorded` null | The rule table still states the rule when the fisher has not been logging |
| 10 | `limitFindings emits nothing for a rule with no bag limit and no vessel limit` | both null | `[]` | A size-only rule must not produce a phantom limit finding |
| 11 | `limitFindings returns a Failure when a bag limit has no period` | limit 6, `bagLimitPeriod: null` | `Failure(MalformedRule)` | Defaulting to `day` produces a false pass on every day of an exhausted season quota |
| 12 | `limitFindings returns a Failure when a bag limit has no unit` | limit 6, `bagLimitUnit: null` | `Failure(MalformedRule)` | Count and kilograms are not interchangeable and there is no way to guess which was meant |
| 13 | `limitFindings returns a Failure when a kg limit meets a tally that counts only individuals` | kg rule, tally with no grams | `Failure(MalformedRule)` | A silent unit swap is the failure this row exists to make impossible |
| 14 | `limitFindings reports a vessel limit failure above the limit` | 30 on the hull, limit 25 | `VesselLimitFinding`, `fails` | The sixth rung of the ladder, and the one with the widest scope |
| 15 | `limitFindings reports indeterminate for a vessel limit with no vessel count` | `vesselCount: null` | `indeterminate` | One fisher is not one hull, and equating them would be the engine inventing a number |
| 16 | `limitFindings emits both a bag limit and a vessel limit finding for a rule carrying both` | both columns set | 2 findings, `bagLimit` and `vesselLimit` kinds | One row may carry both and neither may be dropped |
| 17 | `limitFindings requires a citation on every finding it emits` | any | `finding.citation` is the rule's | Invariant 3 |
| 18 | `limitFindings carries is_expired from the candidate` | expired candidate | `isExpired` true, outcome unchanged | Invariant 5: expiry annotates, never softens |
| 19 | `CatchTally reports zero for a period with nothing recorded` | empty tally, `day` | 0 | Zero recorded is a real, determinate answer and must not be confused with a null tally |

```dart
// packages/rule_engine/test/findings/limit_finding_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:rule_engine/testing/utils/result.dart';
import 'package:test/test.dart';

void main() {
  group('limitFindings', () {
    for (final period in LimitPeriod.values) {
      test('reads the tally for the period the rule names when the period is $period', () {
        const tally = CatchTally(countDay: 2, countTrip: 5, countSeason: 40, vesselCount: 2);
        final rule = kRuleTucunareBagLimit.copyWith(bagLimit: 6, bagLimitPeriod: period);
        final finding = limitFindings(rule, tally, isExpired: false).asOk.value.single;
        expect(
          finding.outcome,
          period == LimitPeriod.season ? FindingOutcome.fails : FindingOutcome.passes,
        );
      });
    }

    test('reports a kg bag limit pass exactly at the limit', () {
      const tally = CatchTally(countDay: 4, gramsDay: 20000, vesselCount: 1);
      final rule = kRuleTucunareBagLimit
          .copyWith(bagLimit: 20, bagLimitUnit: LimitUnit.kg, bagLimitPeriod: LimitPeriod.day);
      expect(limitFindings(rule, tally, isExpired: false).asOk.value.single.outcome,
          FindingOutcome.passes);
    });

    test('reports indeterminate when there is no tally', () {
      final findings = limitFindings(kRuleTucunareBagLimit, null, isExpired: false).asOk.value;
      final finding = findings.single as BagLimitFinding;
      expect(finding.outcome, FindingOutcome.indeterminate);
      expect(finding.limit, 6);
      expect(finding.recorded, isNull);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `dart test test/findings/limit_finding_test.dart` → 19 failures (row 5 expands to three). If
row 2 or row 8 passes now, the test is wrong.

## Implementation outline

1. `lib/src/models/catch_tally.dart`: the class landed in T03 with `countDay`, `countTrip`,
   `countSeason`, `gramsDay`, `gramsTrip`, `gramsSeason` (each `int?` — null means the log cannot
   answer in that unit for that period) and `vesselCount`. Add the two accessors,
   `int? countFor(LimitPeriod)` and `int? gramsFor(LimitPeriod)`, each a `switch` over the enum with
   no `default:` arm so a fourth period cannot be added without a compile error here.
2. `lib/src/findings/limit_finding.dart`:
   - `final class BagLimitFinding extends Finding` with `limit`, `recorded` (`int?`), `unit`,
     `period`. `kind` returns `FindingKind.bagLimit`; `outcome` is `indeterminate` when `recorded` is
     null, else `fails` on `recorded > effectiveLimit`.
   - `final class VesselLimitFinding extends Finding` with `limit` and `recorded` (`int?`). No unit,
     no period, deliberately. `kind` returns `FindingKind.vesselLimit`.
   - `Result<List<Finding>> limitFindings(Rule, CatchTally?, {required bool isExpired})`: reject the
     three content defects first, then emit `BagLimitFinding` then `VesselLimitFinding` when the
     corresponding column is non-null.
3. For a `kg` rule, `effectiveLimit` is `limit * 1000` and `recorded` is `gramsFor(period)`. Both
   integers. Never construct a `double` in this file.
4. Export both files from the barrel.
5. Re-run the whole suite. All 19 green; T01–T07 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 tests pass, and each failed first.
- [ ] Branch coverage on `limit_finding.dart` and `catch_tally.dart` is 100%, including all three
      periods, both units and all three `Failure` returns.
- [ ] No `double` appears in `limit_finding.dart` or `catch_tally.dart`.
- [ ] The comparison is `>`, never `>=`.
- [ ] `VesselLimitFinding` has no period field and no unit field.
- [ ] A null tally never produces `passes`, anywhere in the file.
- [ ] No default is applied to `bagLimitPeriod` or `bagLimitUnit`.
- [ ] The engine does not add the fish in hand to the tally — the doc comment says why.

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
feat(rule_engine): evaluate bag and vessel limits against the tally for the rule's period

The period comes from the rule and is never defaulted. A season quota
compared against a day's tally passes on every day of a season it has
already exhausted — a false pass, at scale, in the direction that costs the
fisher — so a bag limit with no period is a content defect instead.

Mass is integer grams against a kilogram limit multiplied by a thousand.
Kilograms as double puts 0.1 + 0.2 on the path between the eighth fish and a
fine, and it only misbehaves at the boundary, which is the only place anyone
looks.

A null tally is indeterminate, never a pass: reporting a bag limit satisfied
because the app has no data is the same error as reporting an untranscribed
species legal. The engine also does not add the fish in hand to the tally —
whether it is kept is the fisher's decision, and predicting it would make
the finding advisory.

The vessel limit carries no period because SPEC 7.1 gives it no period
column, and stating one the instrument did not give is interpretation.

Task: E03/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
