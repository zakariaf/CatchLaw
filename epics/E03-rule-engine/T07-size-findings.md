# E03/T07 — Size findings and the measurement method

| | |
|---|---|
| **Epic** | E03 — Rule engine: resolution, findings and verdicts |
| **Branch** | `epic/03-rule-engine` (shared) |
| **Commit** | `feat(rule_engine): compare a landing against min and max size only under its own method` |
| **Depends on** | T06 (the `Finding` base and `FindingOutcome`) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.1 `rule.min_size_mm`, `max_size_mm`, `measurement_method_id`; §7.3 precedence; §4.1 "Result display"; §4.2 last two rows |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 12: a measurement is compared **only** against its own method, a mismatch is reported and never converted — with the arithmetic that makes it a AED 3,000 error |
| `catchlaw-verdict-contract` | Rules 3 and 4: the numeric margin is always printed and the method is named beside it. Both are numbers this task must produce, since the engine holds no words |
| `catchlaw-measurement-ruler` | Owns TL, FL, CW and SHL capture, the unit and the rounding that happen **before** a reading reaches `EvaluationRequest`. This task must not re-do any of it |
| `catchlaw-conventions-index` | Routing rule 9: measurement capture is `catchlaw-measurement-ruler` and E09; the comparison is here |
| `dart3-idioms-and-coding-standards` | Two `final` subclasses over one class with a mode flag |
| `testing-strategy` | Boundary-value tests: equal-to-minimum is its own row, not a variation |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.1 `rule` | `min_size_mm INTEGER`, `max_size_mm INTEGER`, `measurement_method_id INTEGER REFERENCES`, and the `CHECK (min_size_mm IS NULL OR max_size_mm IS NULL OR max_size_mm >= min_size_mm)` |
| `SPEC.md` | §7.1 `measurement_method` | The nine codes; `diagram_asset` and the two `*_key` columns are app-side and never enter the engine |
| `SPEC.md` | §4.1 "Result display" | `"Below the minimum — 38 cm, minimum 45 cm (total length)"` — the three numbers and the method the finding must carry |
| `SPEC.md` | §4.2, last two rows | "Method is per-species-per-jurisdiction … the diagram always comes from the active jurisdiction's rule row" |
| `SPEC.md` | §7.3, precedence sentence | `max_size_mm` outranks `min_size_mm`; both sit below the closure |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rule 12; the `minCm compared against a fork-length reading` anti-pattern | 65 cm fork length is roughly 71 cm total length; crossing them manufactures a pass at the centimetre |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | The Kanaad rows of the worked-trace table; the `reading == null` edge case | `methodMismatch` never compared; a null reading makes the size finding `indeterminate`, not a pass |
| `.claude/skills/catchlaw-verdict-contract/references/the-five-part-carve-out.md` | Part 4, the "44.6 cm, close enough" row | The engine states the number and the threshold; rounding is `catchlaw-measurement-ruler`'s |
| `FLUTTER_GUIDE.md` | §7.2 | Sealed union, `final` subclasses |
| `epics/DECISIONS.md` | D-7 | `MeasurementMethod` travels as an enum; "total length" is a word E06 owns |

## What this delivers

- `packages/rule_engine/lib/src/findings/size_finding.dart` — `MinimumSizeFinding`,
  `MaximumSizeFinding`, and `List<Finding> sizeFindings(Rule, Landing?)`.
- `packages/rule_engine/lib/src/findings/finding.dart` — `FindingOutcome` gains no members;
  `methodMismatch` is modelled as a *field* on the size findings, not a fourth outcome (see below).
- `packages/rule_engine/lib/rule_engine.dart` — exports `size_finding.dart`.
- `packages/rule_engine/test/findings/size_finding_test.dart`.

## Why it is built this way

### Millimetres, integers, and no unit field

T01 fixed the unit: `SPEC.md` §7.1 stores `min_size_mm` and `max_size_mm` as `INTEGER` and
`Landing.lengthMm` is an `int`. The comparison is therefore integer comparison, and the whole class
of floating-point boundary bugs — `44.999999999999996 < 45.0` — does not exist on this path. The
finding carries `measuredMm` and `thresholdMm` and the app divides by ten for a `cm` display in
whichever numeral system E06 resolves.

`the-five-part-carve-out.md` part 4 rules that a 44.6 cm measurement is stated, not rounded to
"close enough". Rounding from the ruler's pixels to a whole millimetre is
`catchlaw-measurement-ruler`'s and happens in E09, before `Landing` is constructed. By the time a
value reaches this function it is a decided integer, and this function does not second-guess it.

### The method is compared, never converted

`catchlaw-rule-engine` rule 12 gives the number: 65 cm fork length on Kanaad is roughly 71 cm total
length. A conversion factor applied to bridge the two would manufacture a pass at the centimetre that
costs AED 3,000, and it would be the app performing an interpretation — which
`the-five-part-carve-out.md` part 4 bans outright. So when
`landing.method != rule.measurementMethod`, the finding is emitted with `methodMismatch: true`, an
`indeterminate` outcome, and **no comparison performed at all**: `measuredMm` is still carried so the
app can state what was measured and under which method, and the threshold is still carried so it can
state what the rule requires and under which method. Two facts, side by side, and no conclusion.

**`methodMismatch` is a field, not a fourth `FindingOutcome`.** The outcome the rest of the engine
needs is "this does not decide anything", which is exactly `indeterminate` — T09 must not headline it
and T10 must not report it as a pass, and both of those follow from the existing member.
`resolution-algorithm.md`'s closing sentence covers it: *"anything marked `indeterminate` prints as
an open question in the rule table and NEVER as a pass."* A fourth member would force every switch in
T09 and T10 to grow an arm that behaves identically to `indeterminate`.

**The `custom` method is safe here only because of stage 1.** `SPEC.md` §4.2 allows a per-jurisdiction
custom method and §7.1 gives it one code, `CUSTOM`, so two jurisdictions' custom methods compare
equal. T03's selection has already filtered to a single `jurisdictionId`, and `SPEC.md` §4.2 says the
diagram — and therefore the method the ruler captured under — comes from the active jurisdiction's
rule row. Within one request the comparison is sound. Epic risk 3 records the schema change that
would make it sound unconditionally.

### A missing reading is indeterminate, not a pass

`resolution-algorithm.md` edge case: *"`reading == null` on a size rule — the size finding is
`indeterminate`, not a pass; closure and protection still evaluate."* This is the same legal argument
as T11's: silence is not permission. A fisher who picks a species without measuring gets a page that
states the size rule and states that no measurement has been taken — never a green stamp.

### Boundaries are inclusive on the legal side

`min_size_mm` is a *minimum*: a fish exactly at it meets the rule. `max_size_mm` is a *maximum*: a
fish exactly at it meets the rule too. So `fails` is `measuredMm < minSizeMm` and
`measuredMm > maxSizeMm`, strictly. Off-by-one here is not a rounding nicety — it is the difference
between a legal fish and an offence at the one millimetre where the instrument is most precise, and it
is the direction a `<=` typo fails in.

### One rule can produce two size findings

`SPEC.md` §7.1 lets one row carry both `min_size_mm` and `max_size_mm` — that is a slot limit, and
`resolution-algorithm.md`'s precedence table explains why `maxSize` outranks `minSize`: *"slot rules
protect spawners"*. `sizeFindings` therefore returns a `List<Finding>` of zero, one or two elements
rather than a single nullable finding, and T09 ranks them.

### Rejected

- **A `SizeFinding` with a `bool isMinimum`.** Two `final` subclasses give T09 a `kind` to rank on
  and give E10 two different sentences without a conditional inside one widget.
- **Converting FL to TL with a species-specific factor.** Named as the anti-pattern it is by rule 12,
  and it is an interpretation the app is not entitled to make. There is no such factor in the
  reference schema and there will not be one.
- **Returning `null` when the rule has no size columns.** An empty list composes; a nullable finding
  makes every caller in T09 write the same null check.
- **Comparing against `Landing.massGrams` here.** Mass belongs to the bag limit in T08. A size rule
  is a length rule.

## Tests first

Write all 17 rows before creating `size_finding.dart`. Run them. **They must fail.** Rows 3 and 6 are
the boundary rows; a `<=` implementation passes one and fails the other, so both are needed.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `sizeFindings reports a minimum size failure below the threshold` | 380 mm against 450 mm TL | `MinimumSizeFinding`, `fails` | The `SPEC.md` §4.1 headline example, the Hamour trace |
| 2 | `sizeFindings carries the measured value and the threshold` | as row 1 | `measuredMm` 380, `thresholdMm` 450 | `catchlaw-verdict-contract` rule 3: the numeric margin is always printed, so the engine must always produce it |
| 3 | `sizeFindings reports a minimum size pass exactly at the threshold` | 450 mm against 450 mm | `passes` | A minimum is inclusive. A `<=` typo makes a legal fish illegal at the one value where the instrument is most precise |
| 4 | `sizeFindings reports a minimum size pass above the threshold` | 470 mm against 450 mm | `passes` | The ordinary case, so rows 1 and 3 are not both satisfied by a constant |
| 5 | `sizeFindings reports a maximum size failure above the threshold` | 1220 mm against 1200 mm | `MaximumSizeFinding`, `fails` | `resolution-algorithm.md`'s slot example, "122 cm, maximum 120 cm" |
| 6 | `sizeFindings reports a maximum size pass exactly at the threshold` | 1200 mm against 1200 mm | `passes` | The mirror of row 3, and the mirror typo |
| 7 | `sizeFindings emits two findings for a slot rule` | rule with both 450 and 1200 | 2 findings, `maxSize` and `minSize` kinds | `SPEC.md` §7.1 allows both columns on one row; a single-finding return would drop one of them |
| 8 | `sizeFindings emits nothing for a rule with no size columns` | both null | `[]` | A bag-limit-only rule must not produce a phantom size finding |
| 9 | `sizeFindings reports method mismatch when the reading is fork length and the rule is total length` | 700 mm FL against 650 mm TL | `methodMismatch` true, `indeterminate` | Rule 12. Under conversion this reads as a pass at 71 cm; under naive comparison it reads as a pass at 70 vs 65 — both wrong, both confident |
| 10 | `sizeFindings performs no comparison when the method mismatches` | 300 mm FL against 650 mm TL | `indeterminate`, **not** `fails` | The mismatch must not be resolved by accident in the direction that happens to look strict |
| 11 | `sizeFindings carries both methods when they mismatch` | as row 9 | `readingMethod` FL, `ruleMethod` TL | E10 states both facts side by side; a finding that knows only one cannot |
| 12 | `sizeFindings reports indeterminate when there is no reading` | `landing: null`, rule 450 mm | `indeterminate` | `resolution-algorithm.md` edge case. Silence is not a pass — the same argument as T11 |
| 13 | `sizeFindings carries the threshold when there is no reading` | as row 12 | `thresholdMm` 450 | The rule table still states the rule when nothing has been measured |
| 14 | `sizeFindings compares a shell length reading against a shell length rule` | 34 mm SHL against 38 mm SHL | `fails` | The Ameixa babosa trace; proves the method equality is not hardcoded to TL |
| 15 | `sizeFindings requires a citation on every finding it emits` | any | `finding.citation` is `kCitationMd580` | Invariant 3, at the one place a finding is constructed from a rule |
| 16 | `sizeFindings carries is_expired from the candidate` | expired candidate | `isExpired` true, `outcome` unchanged | Invariant 5: expiry annotates, it never softens or gates the finding |
| 17 | `sizeFindings returns a Failure when a measurement method is absent from a size rule` | 450 mm, `measurementMethod: null` | `Failure(MalformedRule)` | `catchlaw-verdict-contract` rule 4: a number with no named method is a wrong verdict stated with confidence. Better a content defect than a stated fact with no method |

```dart
// packages/rule_engine/test/findings/size_finding_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('sizeFindings', () {
    test('reports a minimum size pass exactly at the threshold', () {
      final findings = sizeFindings(
        kRuleHamourMinSize, // minSizeMm 450, MeasurementMethod.totalLength
        const Landing(lengthMm: 450, method: MeasurementMethod.totalLength),
        isExpired: false,
      ).asOk.value;
      expect(findings.single.outcome, FindingOutcome.passes);
    });

    test('reports method mismatch when the reading is fork length and the rule is total length', () {
      final findings = sizeFindings(
        kRuleKanaadMinSize, // minSizeMm 650, MeasurementMethod.forkLength
        const Landing(lengthMm: 700, method: MeasurementMethod.totalLength),
        isExpired: false,
      ).asOk.value;
      final finding = findings.single as MinimumSizeFinding;
      expect(finding.methodMismatch, isTrue);
      expect(finding.outcome, FindingOutcome.indeterminate);
      expect(finding.readingMethod, MeasurementMethod.totalLength);
      expect(finding.ruleMethod, MeasurementMethod.forkLength);
    });

    test('emits two findings for a slot rule', () {
      final rule = kRuleHamourMinSize.copyWith(maxSizeMm: 1200);
      final findings = sizeFindings(
        rule,
        const Landing(lengthMm: 1220, method: MeasurementMethod.totalLength),
        isExpired: false,
      ).asOk.value;
      expect(findings.map((f) => f.kind), [FindingKind.maxSize, FindingKind.minSize]);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `dart test test/findings/size_finding_test.dart` → 17 failures. If row 3 or row 6 passes
now, the test is wrong.

## Implementation outline

1. `lib/src/findings/size_finding.dart`:
   - `final class MinimumSizeFinding extends Finding` with `thresholdMm`, `measuredMm` (nullable —
     null means nothing was measured), `ruleMethod`, `readingMethod` (nullable), `methodMismatch`.
     `kind` returns `FindingKind.minSize`.
   - `final class MaximumSizeFinding extends Finding`, same shape, `kind` returns
     `FindingKind.maxSize`.
   - `outcome` on each: `indeterminate` when `measuredMm == null || methodMismatch`; otherwise
     `fails`/`passes` on the strict comparison.
2. `Result<List<Finding>> sizeFindings(Rule rule, Landing? landing, {required bool isExpired})`:
   - a rule with a size column and no `measurementMethod` is a `Failure(MalformedRule)`.
   - emit `MaximumSizeFinding` first, then `MinimumSizeFinding`, so the list is already in precedence
     order for the common case. T09 still sorts — this is readability, not a contract.
3. Export from the barrel.
4. Re-run the whole suite. All 17 green; T01–T06 still green.

**Do not** add a conversion table, a species factor, or a `MeasurementMethod.approximatelyEquals`.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 tests pass, and each failed first.
- [ ] Branch coverage on `size_finding.dart` is 100%, including both boundary rows and both
      indeterminate causes.
- [ ] No arithmetic anywhere in the file converts between two `MeasurementMethod` values.
- [ ] Comparisons are `<` and `>`, never `<=` or `>=`.
- [ ] Both size findings carry `measuredMm` and `thresholdMm` even when the outcome is
      `indeterminate`.
- [ ] `FindingOutcome` still has exactly three members.
- [ ] No `double` appears in `size_finding.dart`.

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
feat(rule_engine): compare a landing against min and max size only under its own method

Integer millimetres end to end, so the boundary is exact: a minimum is
inclusive and a maximum is inclusive, and fails is a strict comparison in
both directions. That off-by-one is the difference between a legal fish and
an offence at the one value where the instrument is most precise.

A reading taken under a different method is never converted and never
compared. 65 cm fork length on Kanaad is roughly 71 cm total length, so a
factor would manufacture a pass at the centimetre — and applying one is the
app interpreting, which the carve-out forbids outright. The finding carries
both methods and both numbers and states no conclusion.

methodMismatch is a field rather than a fourth FindingOutcome: what the rest
of the engine needs is "this decides nothing", which is indeterminate, and a
fourth member would grow an identical arm on every switch in T09 and T10.

A missing reading is indeterminate, not a pass — the same argument as an
untranscribed species. Silence is not permission.

Task: E03/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
