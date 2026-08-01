# E03/T06 — Closed seasons: wrap-around, fixed windows, leap years

| | |
|---|---|
| **Epic** | E03 — Rule engine: resolution, findings and verdicts |
| **Branch** | `epic/03-rule-engine` (shared) |
| **Commit** | `feat(rule_engine): evaluate closed seasons across the year boundary and through 29 February` |
| **Depends on** | T01 (`ClosedSeason`, `Citation`), T02 (`Result`), T03 (`parseIsoDate`) |
| **Size** | L |
| **Spec** | `SPEC.md` §7.1 `closed_season`; §7.3 finding precedence; §4.1 "Rule evaluation"; §14 the clock-backwards test; §15 step 2 ("leap-year season boundaries") |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 3 (the date is a parameter — a season is the reason that rule exists), rule 7 (`closedSeason` sits second in precedence), and the "closure spanning a year boundary" edge case |
| `catchlaw-verdict-contract` | Rule 3: the numeric margin is always printed. For a closure that means the window **and** "day 14 of 61", so the engine must produce both numbers rather than a boolean |
| `catchlaw-conventions-index` | Invariant 3: the finding introduced here is the first one, so it is where the required non-nullable `Citation` becomes structural |
| `dart3-idioms-and-coding-standards` | Sealed base class shape, enhanced enums, records for a value with no identity |
| `error-handling-typed-results` | An `annual` row with no month bounds is a content defect, not a season that is never in force |
| `testing-strategy` | Frozen dates; and why 2024 and 2025 are two tests and not one parameterised one |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.1 `closed_season` | `recurrence CHECK (recurrence IN ('annual','fixed'))`, the two nullable bound pairs, `rule_id … ON DELETE CASCADE`, nullable `citation_id` |
| `SPEC.md` | §7.3, precedence sentence | `closedSeason` ranks second, below `is_protected` and above `max_size_mm` |
| `SPEC.md` | §15 step 2 | "including expiry semantics, D4 ambiguity, and **leap-year season boundaries**" — the leap year is named in the build order, not discovered here |
| `SPEC.md` | §14, "Set the clock backwards two years" | "seasonal rules evaluate against the device date without crashing" |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "Edge cases", the closure rows; "Finding precedence" row 2; the Sha'ri worked trace | "Closure spanning a year boundary (1 Nov - 28 Feb) — compared on month-day, wrapping; never on absolute dates"; "A closure whose instrument is expired — still evaluated, still tagged" |
| `.claude/skills/catchlaw-verdict-contract/SKILL.md` | "The sentence grammar of a finding", closure line | `'Closed season — 1 March to 30 April. In force today, day 14 of 61.'` — the two integers this task owes E10, and the arithmetic that produces 61 and 14 |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §2, closed-season row | The same numbers again from the invariant side: "In force today, day 12 of 61" |
| `FLUTTER_GUIDE.md` | §7.2 | The sealed `Finding` base and exhaustive switching over it |
| `epics/DECISIONS.md` | D-7 | The finding carries integers and ISO dates; the sentence is E10's |

## What this delivers

- `packages/rule_engine/lib/src/season/season_window.dart` —
  `Result<SeasonStatus> seasonStatus(ClosedSeason season, String on)`, where
  `typedef SeasonStatus = ({bool inForce, String startsOn, String endsOn, int dayOfClosure, int lengthInDays})`.
- `packages/rule_engine/lib/src/findings/finding.dart` — `sealed class Finding`,
  `enum FindingKind`, `enum FindingOutcome`. **The base introduced here** because this is the first
  task that constructs a finding; T10 closes the union and proves its invariants across all six
  subtypes.
- `packages/rule_engine/lib/src/findings/closed_season_finding.dart` — `ClosedSeasonFinding`.
- `packages/rule_engine/lib/rule_engine.dart` — exports the three new files.
- `packages/rule_engine/test/season/season_window_annual_test.dart`,
  `packages/rule_engine/test/season/season_window_fixed_test.dart`,
  `packages/rule_engine/test/findings/closed_season_finding_test.dart`.

Three test files rather than one, per `FLUTTER_GUIDE.md` §6.2's instruction to split large test files
by behaviour.

## Why it is built this way

### The arithmetic is done on materialised dates, not on month-day pairs

The naive implementation of an annual recurrence compares `(month, day)` tuples and stops there. It
answers *is it in force* correctly and cannot answer either of the other two questions the product
needs. `catchlaw-verdict-contract`'s finding grammar requires `Closed season — 1 March to 30 April.
In force today, day 14 of 61.` Rule 3 of that skill makes the numeric margin mandatory rather than
decorative: without it the app has published its own conclusion instead of quoting a rule.

So `seasonStatus` materialises the occurrence that contains (or next follows) `on` into two concrete
dates, and derives everything from them:

- `lengthInDays = endsOn.difference(startsOn).inDays + 1` — inclusive of both ends. 1 March to 30
  April is 31 + 30 = **61**, which is the number in the skill's own example sentence.
- `dayOfClosure = on.difference(startsOn).inDays + 1` when in force, `0` otherwise. 14 March is day
  **14** of that window, which is the other number in the same sentence.

The payoff is the leap year. A 1 February to 31 March annual closure is 60 days in 2024 and 59 days
in 2025, and 1 March is day 30 in 2024 and day 29 in 2025. A month-day implementation with a lookup
table of month lengths gets this wrong once every four years, in one direction, silently. Materialised
dates get it right because `DateTime.utc(2024, 3, 1).difference(DateTime.utc(2024, 2, 1)).inDays` is
29 and the calendar did the work.

**Every date is UTC.** `parseIsoDate` (T03) returns UTC midnight, and `Duration.inDays` truncates. On
local-time `DateTime`s, a window crossing a daylight-saving transition is 58.958 days, which
truncates to 58, and the closure is reported one day shorter than it is for half the year in Spain and
Brazil. This is not hypothetical arithmetic — both jurisdictions observe or have observed DST, and
the Galician *vedas* windows sit across the March transition.

### The wrap is a branch on the bounds, not on the date

`resolution-algorithm.md`: *"Closure spanning a year boundary (1 Nov - 28 Feb) — compared on
month-day, wrapping; never on absolute dates."* A window wraps when its start month-day is **after**
its end month-day. That is the only test; it does not depend on `on` at all, which matters because
the same closure must behave identically on 15 December and 15 January.

Materialising a wrapping occurrence takes three cases, and all three are tested:

| `on` relative to the bounds | Occurrence materialised as |
|---|---|
| on or after the start month-day | starts this year, ends **next** year |
| on or before the end month-day | started **last** year, ends this year |
| between the end and the start | the next occurrence: starts this year, ends next year, `dayOfClosure = 0` |

The third case is why `lengthInDays` is returned even when `inForce` is false: E10 renders a
satisfied closure row in the rule table beneath a different headline
(`resolution-algorithm.md`: *"Non-deciding findings are NOT discarded"*), and that row states the
window.

### 29 February inside a window is a date; 29 February as a bound is a content defect

Inside a window it is handled by construction — 1 February to 31 March in 2024 contains it, and the
materialised arithmetic counts it. As a *bound* of an **annual** recurrence it is undefined: three
years in four there is no such date, and the engine would have to invent 28 February or 1 March,
either of which adds or removes a day of closure that no instrument declared. `SPEC.md` §7.3 and §7.1
are silent, and no bundled instrument is known to do it. It therefore returns
`Failure(MalformedSeason)`, which E04's build assertions will surface at authoring time rather than at
sea. Epic risk 4 records what would change the ruling. In a **fixed** window 29 February is an
ordinary date and is accepted.

### The finding carries integers and ISO dates, never a sentence

D-7. `ClosedSeasonFinding` holds `startsOn`, `endsOn` (ISO-8601, materialised), `dayOfClosure`,
`lengthInDays`, `inForce`, `recurrence`, plus the base's `citation` and `isExpired`. E06 and E10 turn
those into `Closed season — 1 March to 30 April. In force today, day 14 of 61.` in six locales. There
is no `String` in this package that a translator could ever be handed.

### The `Finding` base lands here, and why that is not arbitrary

Something has to declare `sealed class Finding` and this is the first task that constructs one. The
base carries exactly two fields — `required Citation citation` and `required bool isExpired` — plus
two abstract getters, `kind` and `outcome`. Putting the citation on the *base* rather than on each
subtype is what makes `CONVENTIONS.md` §9 invariant 3 structural: there is no way to write a
`Finding` subclass that forgets it, because the superclass constructor demands it.
`FindingOutcome` has three members — `passes`, `fails`, `indeterminate` — because
`resolution-algorithm.md` closes with the sentence that governs T07 and T08 as much as this one:
*"Anything marked `indeterminate` prints as an open question in the rule table and NEVER as a pass."*
A closure is never indeterminate: the device has a date, so the answer always exists.

### Rejected

- **`bool isInClosedSeason(...)`.** It is the whole implementation the naive version writes and it
  cannot produce the two integers the verdict grammar requires.
- **A month-length lookup table.** It is where the leap-year bug lives, and `SPEC.md` §15 step 2
  names leap-year season boundaries as a thing the core must get right.
- **Evaluating a closure against the *rule's* `validFrom`/`validTo` rather than `on`.** They are
  different questions: expiry is about the instrument's currency (T03), a closure is about today's
  date. `resolution-algorithm.md`: *"a closure whose instrument is expired — still evaluated, still
  tagged `isExpired`."*
- **Throwing on a malformed season.** T02 fixed the channel; a content defect that throws out of a
  pure function is a defect the content builder cannot report against a row number.

## Tests first

Write all 24 rows before creating `season_window.dart`. Run them. **They must fail.** Rows 9–12 are
the leap-year rows: if any of them passes now, the fixture year is wrong.

Every test passes an explicit `on`. No test reads a clock.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `seasonStatus reports a fixed window in force on its first day` | 2026-03-01…2026-04-30, on 2026-03-01 | `inForce`, day 1 of 61 | Inclusive start. A `>` would make the first day of every closure open |
| 2 | `seasonStatus reports a fixed window in force on its last day` | same, on 2026-04-30 | `inForce`, day 61 of 61 | Inclusive end, the mirror error |
| 3 | `seasonStatus reports a fixed window not in force the day before it opens` | same, on 2026-02-28 | not in force, day 0 of 61 | The boundary either side of row 1 |
| 4 | `seasonStatus reports a fixed window not in force the day after it closes` | same, on 2026-05-01 | not in force | The boundary either side of row 2 |
| 5 | `seasonStatus counts 61 days from 1 March to 30 April` | same, on 2026-03-14 | day 14 of 61 | The exact numbers in `catchlaw-verdict-contract`'s worked sentence; if this row is wrong, E10 prints a wrong sentence with full confidence |
| 6 | `seasonStatus returns the materialised start and end dates` | same, on 2026-03-14 | `startsOn` 2026-03-01, `endsOn` 2026-04-30 | E10 prints the window; a finding that knows only "in force" cannot state what it is in force under |
| 7 | `seasonStatus reports an annual window in force inside its months` | annual 3-1…4-30, on 2026-03-14 | day 14 of 61 | The Sha'ri trace from `resolution-algorithm.md`, in the recurrence that actually ships |
| 8 | `seasonStatus reports an annual window not in force outside its months` | same, on 2026-05-01 | not in force | The other half |
| 9 | `seasonStatus counts 60 days for a 1 February to 31 March annual window in 2024` | annual 2-1…3-31, on 2024-03-01 | day 30 of 60 | **The leap-year row.** February 2024 has 29 days |
| 10 | `seasonStatus counts 59 days for a 1 February to 31 March annual window in 2025` | same, on 2025-03-01 | day 29 of 59 | The same window, one year later, one day shorter. Rows 9 and 10 together are what a month-length table gets wrong |
| 11 | `seasonStatus reports a fixed window containing 29 February in force on that date` | 2024-02-01…2024-03-01, on 2024-02-29 | in force, day 29 of 30 | 29 February is a real date in a fixed window and the app will be used on it |
| 12 | `seasonStatus returns a Failure for an annual window bounded on 29 February` | annual 2-29…3-31 | `Failure(MalformedSeason)` | Undefined in `SPEC.md`; inventing 28 February adds or removes a day of closure no instrument declared. Epic risk 4 |
| 13 | `seasonStatus reports an annual window that wraps the year end in force in December` | annual 12-1…1-31, on 2026-12-15 | in force, day 15 of 62 | The wrap, first case: the occurrence starts this year and ends next |
| 14 | `seasonStatus reports an annual window that wraps the year end in force in January` | same, on 2027-01-15 | in force, day 46 of 62 | The wrap, second case: the occurrence started **last** year. Day 46 is 31 December days plus 15 |
| 15 | `seasonStatus reports an annual window that wraps the year end in force on its last day` | same, on 2027-01-31 | in force, day 62 of 62 | The far boundary of a wrapped window, which off-by-one lives in |
| 16 | `seasonStatus reports an annual window that wraps the year end not in force in June` | same, on 2027-06-15 | not in force, day 0, length 62 | The third wrap case, and the reason `lengthInDays` is returned when `inForce` is false |
| 17 | `seasonStatus counts 122 days for a 1 November to 1 March window ending in a leap year` | annual 11-1…3-1, on 2024-01-15 | length 122 | The wrap **and** the leap year at once — `resolution-algorithm.md`'s own 1 Nov–28 Feb example, extended one day so February matters |
| 18 | `seasonStatus counts 121 days for a 1 November to 1 March window ending in a common year` | same, on 2025-01-15 | length 121 | The pair to row 17; a wrapped window's length depends on which February it lands in |
| 19 | `seasonStatus returns a Failure for an annual recurrence with no month bounds` | annual, all four nulls | `Failure(MalformedSeason)` naming the field | A content defect, not a season that is never in force — the T02 boundary |
| 20 | `seasonStatus returns a Failure for a fixed recurrence with no dates` | fixed, both nulls | `Failure(MalformedSeason)` | The other half of row 19 |
| 21 | `seasonStatus evaluates a date two years before a fixed window without throwing` | 2026-03-01…2026-04-30, on 2024-01-01 | not in force, length 61 | `SPEC.md` §14's clock-backwards test as a unit test |
| 22 | `ClosedSeasonFinding requires a citation and reports the closed season kind` | construct one | `kind == FindingKind.closedSeason`, citation present | Invariant 3 made structural on the base class; the first finding is where that becomes true |
| 23 | `ClosedSeasonFinding fails when the closure is in force and passes when it is not` | two findings | `outcome` `fails` / `passes` | `outcome` is what T09 ranks; a closure that reports `indeterminate` would be dropped from the headline |
| 24 | `ClosedSeasonFinding carries is_expired from its rule` | in-force closure on a lapsed instrument | `isExpired` true, `outcome` still `fails` | `resolution-algorithm.md`: a closure whose instrument is expired is still evaluated. Expiry must not soften the finding |

```dart
// packages/rule_engine/test/season/season_window_annual_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:rule_engine/testing/utils/result.dart';
import 'package:test/test.dart';

ClosedSeason _annual(int sm, int sd, int em, int ed) => ClosedSeason(
      id: 1,
      ruleId: 1,
      recurrence: Recurrence.annual,
      startMonth: sm,
      startDay: sd,
      endMonth: em,
      endDay: ed,
      citation: kCitationMd580,
    );

void main() {
  group('seasonStatus', () {
    test('counts 60 days for a 1 February to 31 March annual window in 2024', () {
      final status = seasonStatus(_annual(2, 1, 3, 31), '2024-03-01').asOk.value;
      expect(status.lengthInDays, 60);
      expect(status.dayOfClosure, 30);
    });

    test('counts 59 days for a 1 February to 31 March annual window in 2025', () {
      final status = seasonStatus(_annual(2, 1, 3, 31), '2025-03-01').asOk.value;
      expect(status.lengthInDays, 59);
      expect(status.dayOfClosure, 29);
    });

    test('reports an annual window that wraps the year end in force in January', () {
      final status = seasonStatus(_annual(12, 1, 1, 31), '2027-01-15').asOk.value;
      expect(status.inForce, isTrue);
      expect(status.startsOn, '2026-12-01');
      expect(status.dayOfClosure, 46);
      expect(status.lengthInDays, 62);
    });

    test('returns a Failure for an annual window bounded on 29 February', () {
      expect(seasonStatus(_annual(2, 29, 3, 31), '2024-03-01'), isA<Failure<SeasonStatus>>());
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `dart test test/season/ test/findings/` → 24 failures. If rows 9 and 10 both pass now, they
are asserting the same constant and one of them is wrong.

## Implementation outline

1. `lib/src/findings/finding.dart`: `enum FindingKind { protected, closedSeason, maxSize, minSize,
   bagLimit, vesselLimit }` — declaration order is the precedence order T09 formalises, but T09 owns
   the integers; `enum FindingOutcome { passes, fails, indeterminate }`; `sealed class Finding` with
   `required Citation citation`, `required bool isExpired`, `FindingKind get kind`,
   `FindingOutcome get outcome`.
2. `lib/src/season/season_window.dart`:
   a. Validate: `annual` needs all four month-day bounds; `fixed` needs both dates; either bound of an
      `annual` window on 29 February is a defect. Return `Failure(MalformedSeason)` naming the field.
   b. `fixed` → parse both dates with `parseIsoDate`. Done.
   c. `annual` → decide `wraps = (startMonth, startDay) > (endMonth, endDay)` as a tuple comparison.
      Non-wrapping: both bounds in `on`'s year. Wrapping: the three-case table above.
   d. Derive `inForce`, `dayOfClosure`, `lengthInDays` from the two materialised dates. One code path
      for both recurrences from here down — that shared tail is the point of materialising.
3. `lib/src/findings/closed_season_finding.dart`: `final class ClosedSeasonFinding extends Finding`
   with the six fields plus `super.citation` and `super.isExpired`. `kind` returns
   `FindingKind.closedSeason`; `outcome` returns `fails` when `inForce`, else `passes`.
4. Export all three from the barrel.
5. Re-run the whole suite. All 24 green; T01–T05 still green.

**Naming trap, again:** do not call the materialisation helper `_normaliseWindow`.
`check_rule_engine.sh` check 4 fails the build on it. `_materialise` or `_occurrenceFor` is fine.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 24 tests pass, and each failed first.
- [ ] Branch coverage on `lib/src/season/` and `lib/src/findings/` is 100%, including all three wrap
      cases and both `Failure` returns.
- [ ] `grep -rn 'DateTime.now()' packages/rule_engine/lib` still returns nothing.
- [ ] No month-length table, no `daysInMonth`, no hardcoded `28` or `29` in `lib/src/season/`.
- [ ] Every `DateTime` constructed in `lib/src/season/` is UTC.
- [ ] `Finding` declares `citation` as a required non-nullable field on the base, so no subtype can
      omit it.
- [ ] `ClosedSeasonFinding` has no `String` field other than the two ISO dates, and no string literal.
- [ ] `lengthInDays` is returned even when `inForce` is false.

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
feat(rule_engine): evaluate closed seasons across the year boundary and through 29 February

The occurrence is materialised into two concrete UTC dates and everything is
derived from them. A month-day comparison answers "in force" and cannot
answer the two questions the verdict grammar requires — the window and "day
14 of 61" — and a month-length lookup table gets the leap year wrong once
every four years in one direction, silently. A 1 February to 31 March annual
closure is 60 days in 2024 and 59 in 2025; the calendar does that arithmetic
and we do not.

UTC is not incidental. Duration.inDays truncates, so a window crossing a
daylight-saving transition on local DateTimes measures 58.958 days and
reports the closure a day short for half the year in Spain and Brazil.

A window wraps when its start month-day is after its end month-day, which is
a test on the bounds and never on the date, so 15 December and 15 January
resolve the same closure. lengthInDays is returned even when the closure is
not in force, because a satisfied closure still prints its window in the
rule table.

29 February inside a fixed window is an ordinary date. As a bound of an
annual recurrence it is undefined by SPEC 7.3, so it is a content defect
rather than a guess between 28 February and 1 March — either of which adds
or removes a day of closure no instrument declared.

Task: E03/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
