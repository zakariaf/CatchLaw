# E03/T10 — The sealed verdict types

| | |
|---|---|
| **Epic** | E03 — Rule engine: resolution, findings and verdicts |
| **Branch** | `epic/03-rule-engine` (shared) |
| **Commit** | `feat(rule_engine): close the Resolution union and expose evaluate as the engine's only entry point` |
| **Depends on** | T05 (conflict detection), T09 (headline and secondary) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.3 in full; §4.1 "Result display", "Ambiguity handling", "Expired-rule handling"; §5.1; §13 (rule evaluation < 10 ms) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 9 (every finding carries a non-null `Citation`) and its "silence in the sources is not permission" block, which gives the union's shape |
| `catchlaw-verdict-contract` | Rules 5, 6 and 10, and the "citation quadruple is part of the sentence" block. This task builds the type the contract binds — and D-7 means it builds it with no sentence in it |
| `catchlaw-conventions-index` | Invariants 3 and 5, and the layer map: this is the surface `app/lib/data/` maps into and `app/lib/ui/` switches on |
| `dart3-idioms-and-coding-standards` | Sealed unions, exhaustive `switch` with no `default:`, and where a getter beats a stored field |
| `error-handling-typed-results` | `Result<Resolution>` is the public signature; the boundary T02 drew is enforced at the entry point |
| `testing-strategy` | `FLUTTER_GUIDE.md` §6.4's budget, and how to write a latency assertion that is a regression guard rather than theatre |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.3 in full | The four stages this function composes, and the sentence about what happens after step 4 |
| `SPEC.md` | §4.1 rows "Result display", "Ambiguity handling", "Expired-rule handling", "No-rule-vs-no-data" | The four acceptance conditions the union must make representable |
| `SPEC.md` | §5.1, all five arguments | Why the union has an `Ambiguous` arm and why no arm is a recommendation |
| `SPEC.md` | §13, "Rule evaluation \| < 10 ms" row | "Pure Dart over ≤ 20 candidate rows" — the benchmark's shape as well as its number |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rules 8, 9; "Silence in the sources is not permission" | The three-variant sketch: `Decided`, `NoLimitInInstrument`, `NoRuleFound`, and why they may not collapse |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "The tie matrix", "Worked traces", "Edge cases" | Eight end-to-end traces to reuse as the integration rows of this task's test table |
| `.claude/skills/catchlaw-verdict-contract/references/the-five-part-carve-out.md` | Parts 2 and 3, and "What voids the carve-out" | The citation quadruple as a structural requirement, and the three voiding acts none of which this type may permit |
| `.claude/skills/catchlaw-verdict-contract/SKILL.md` | Rule 10 and "Stale is shown; withholding is itself advice" | `Verdict.unavailable()` named as the defect it is — there is no such arm in this union |
| `FLUTTER_GUIDE.md` | §7.2, §7.5 | Sealed unions for a closed domain; `Result` in the pure-Dart package |
| `epics/DECISIONS.md` | D-7 | The whole of it. This task is where D-7 is proved rather than promised |

## What this delivers

- `packages/rule_engine/lib/src/verdict/resolution.dart` — `sealed class Resolution` with
  `Decided`, `Ambiguous` and `NoLimitInInstrument`. (T11 adds the two absence arms.)
- `packages/rule_engine/lib/src/rule_evaluator.dart` —
  `Result<Resolution> evaluate(EvaluationRequest request, Iterable<Rule> rows)`, the package's only
  public entry point, composing T03 → T04 → T05 → T09.
- `packages/rule_engine/lib/rule_engine.dart` — exports both, plus the library-level doc comment
  `FLUTTER_GUIDE.md` §2.6 says belongs on the barrel.
- `packages/rule_engine/test/verdict/resolution_test.dart`,
  `packages/rule_engine/test/rule_evaluator_test.dart`,
  `packages/rule_engine/test/verdict/no_strings_test.dart`,
  `packages/rule_engine/test/rule_evaluator_latency_test.dart`.

## Why it is built this way

### D-7 is proved here, not asserted

D-7 says `packages/rule_engine/` returns sealed `Verdict` and `Finding` values carrying numbers,
enums, a required `Citation` and an `isExpired` flag, and contains **no user-visible sentence in any
language**. `check_verdict_contract.sh` scans `app/lib` and `app/lib/l10n`, so no shipped gate looks
at this package for words — which is precisely why this task owes a test.

The test is mechanical: **no `.dart` file under `lib/src/findings/` or `lib/src/verdict/` contains a
string literal**, excluding `import`, `export` and `part` directives. Those two directories are the
whole verdict surface, and everything in them is an integer, an enum, a bool or a `Citation`. The
engine therefore has nothing to hand a translator and nothing to compose a sentence out of.

That is a statement about *literals*, deliberately — about text the engine **authors**. Two kinds of
`String` still travel through: ISO-8601 dates (`Citation.publishedOn`, `ClosedSeasonFinding.startsOn`)
and the two quoted fields `Citation.instrument` and `Citation.article`, which are verbatim references
transcribed from a published instrument. Neither is composed here and neither is localised — as
`product-invariants.md` §3 notes, the citation's digits stay Western in every locale because they are
quoted from print. A second assertion in the same test pins the distinction by field name: no field
anywhere in those directories is called `message`, `label`, `text`, `description`, `title` or
`summary`.

### One entry point, returning `Result<Resolution>`

`evaluate` is the only public function the app and `tools/content_builder/` call. Everything T03–T09
delivered stays exported for testing, but the composition lives in one place so that
`SPEC.md` §7.3's stage order — which `catchlaw-rule-engine` rule 4 calls fixed — is readable in
fifteen lines.

The `Result` wrapper carries only content defects, per T02's boundary table. Every legally meaningful
outcome is an `Ok`. The doc comment on `evaluate` says so in one sentence, because the shape invites
the opposite reading.

### The union's arms, and the two that do not exist

`catchlaw-rule-engine`'s "silence in the sources is not permission" block gives three variants and
this task delivers three of the five (T11 delivers the rest):

| Arm | Means | Constructed when |
|---|---|---|
| `Decided` | The instruments state something and one finding headlines it | the ranked list is non-empty and there is no conflict, and at least one finding exists |
| `Ambiguous` | Two or more equally specific rules disagree | `findConflict` returned a non-empty list |
| `NoLimitInInstrument` | The instrument was searched and positively records no limit | the winning candidate produced **zero** findings |

`NoLimitInInstrument` needs no new column. In `SPEC.md` §7.1 a rule row with no size columns, no bag
limit, no vessel limit, `is_protected = 0` and no `closed_season` children is exactly *an instrument
that covers this species here and records no limit* — a cited, positive statement, distinct from the
absence T11 handles. It carries the citation of the rule that made it.

The two arms that deliberately do not exist:

- **No `Verdict.unavailable()`, and no expiry arm.** `catchlaw-verdict-contract` rule 10 and
  `CONVENTIONS.md` §9 invariant 5: an expired ruleset is still evaluated and still shown. Withholding
  is itself advice — *"deciding the fisher is better off with nothing"* — and there is no network to
  recover from. Expiry is a `bool` on the base, not a branch.
- **No `Meets` arm.** A verdict that everything passes is a `Decided` whose headline has
  `outcome == passes`. A separate arm would let a caller switch on the arm instead of on the finding
  and lose the numbers, and `catchlaw-verdict-contract` rule 3 requires the margin to be printed even
  when the fish is legal — *"Meets the minimum — 47 cm measured, minimum 45 cm (total length)"*.

### The citation contract on the base

`sealed class Resolution` declares `List<Citation> get citations`, non-empty for every arm.
`Decided` and `NoLimitInInstrument` additionally expose a single non-nullable `Citation citation`.
That satisfies `CONVENTIONS.md` §9 invariant 3 uniformly without a `Citation?` anywhere: an arm that
genuinely involves several instruments (`Ambiguous`; and T11's two absence arms, which cite what was
searched) answers with all of them, and a test asserts every arm's list is non-empty. An empty list
would be the nullable citation wearing a different type, so that assertion is the invariant.

`bool get isExpired` is likewise on the base. `Decided` and `Ambiguous` compute it as *any source
involved has lapsed*, because E10's ochre bar is a statement about the data behind the whole result,
not about one row of it. **This is rule currency, not pack currency**: `jurisdiction.valid_until` in
`SPEC.md` §7.1 is a separate fact about the shipped content, owned by E05 and rendered by E10.

### The latency test

`SPEC.md` §13 budgets rule evaluation at **< 10 ms** over **≤ 20 candidate rows**. The test builds
exactly 20 rows, runs `evaluate` 1,000 times and asserts the mean is under 10 ms. It runs on CI,
which is faster than a Snapdragon 665, so it is a regression guard and not a proof — epic risk 7
names E21 as where the proof happens. It is still worth having: the failure it catches is somebody
adding an O(n²) `outcomeEquals` sweep or a `parseIsoDate` inside a loop, both of which are invisible
at three rows and both of which would be caught here at twenty.

### Rejected

- **`Verdict` as the type name.** `check_app_invariants.sh` check 4 has a heuristic that flags any
  file declaring a `Verdict` type without the word `citation` in it. Ours would pass, but the name
  `Resolution` is what `SPEC.md` §7.3 and `catchlaw-rule-engine` both use for the result of
  resolution, and `Verdict` is what `lonja-verdict-and-status` and E10 call the *rendered* thing.
  Two names for two layers is correct here.
- **`Resolution` carrying the winning `Rule`.** `Decided` carries findings, and every finding carries
  its own citation and expiry. Handing the app the rule row invites it to re-derive a verdict from
  the columns and re-rank the findings, which `catchlaw-rule-engine` rule 7 forbids.
- **An `evaluate` that takes a `Clock`.** T03 settled it: `on` is on the request.
- **Making `evaluate` async.** There is nothing to await. A `Future` would push every caller into an
  `AsyncValue` for a pure function that runs in microseconds.

## Tests first

Write all 21 rows before creating `resolution.dart`. Run them. **They must fail.** Rows 11–17 are the
end-to-end traces from `resolution-algorithm.md`; if one of them passes now, its fixture does not
exercise the pipeline.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `Resolution switches exhaustively with no default arm` | a `switch` over the three arms | compiles | The reason the union is sealed; T11 will add two arms and the analyzer must break every switch until they are handled |
| 2 | `Decided exposes the headline citation` | a decided verdict | `citation` is the headline's | Invariant 3 at the arm a fisher sees most |
| 3 | `Decided reports every citation involved` | headline + two secondaries from two instruments | 3 citations | The rule table prints all of them; a single citation would silently drop the corroborating instrument |
| 4 | `Decided reports is_expired when only a secondary finding is expired` | fresh headline, lapsed secondary | `isExpired` true | The ochre bar is a statement about the data behind the whole result |
| 5 | `Ambiguous reports a citation for every rule it holds` | two conflicting rules | 2 citations, source order | `the-five-part-carve-out.md` part 3: both plates at identical weight, source order, no primary |
| 6 | `Ambiguous holds the rules in source order` | as row 5 | order preserved | The refusal is only credible if the two are presented without ranking, and T04's stable sort is what feeds this |
| 7 | `NoLimitInInstrument carries the citation of the instrument searched` | a rule with no limits | 1 citation | It is a positive statement the instrument makes, not an absence — that is the whole difference from T11's arms |
| 8 | `every Resolution arm reports a non-empty citation list` (loop over the arms, arm interpolated) | one of each | `citations` not empty | An empty list is a nullable `Citation` wearing a different type; this row is the invariant |
| 9 | `no file under findings or verdict contains a string literal` | source scan | no hits | D-7, proved rather than promised. This package has nothing to hand a translator |
| 10 | `no field under findings or verdict is named for prose` | source scan for `message`, `label`, `text`, `description`, `title`, `summary` | no hits | The second half of D-7: a `String` field is fine when it is an ISO date or a quoted instrument reference and never when it is a sentence waiting to happen |
| 11 | `evaluate returns Decided for one matching rule` | Hamour, 380 mm TL, `AE-RK`, 2026-07-30 | `Decided`, `minSize` fails, 380 vs 450 | `resolution-algorithm.md`'s first worked trace |
| 12 | `evaluate returns Decided with the closure headlined and the size finding secondary` | Sha'ri, 520 mm TL, 2026-03-14 | `closedSeason` headline, `minSize` in `secondary` | The second worked trace, and the precedence path end to end |
| 13 | `evaluate returns Decided with is_expired for a lapsed piracema portaria` | Tucunaré, portaria lapsed 2026-02-28, on 2026-07-30 | `Decided`, `isExpired` true, numbers intact | The eighth worked trace; and `SPEC.md` §14's expiry test as a unit test. **A NoRuleFound here is a failure** |
| 14 | `evaluate returns Decided from the bank rule over the region rule` | Ameixa babosa, 34 mm SHL, `banco-de-cambados` | bank rule wins, `minSize` fails 34 vs 38 | The fifth worked trace: specificity resolving a non-conflict |
| 15 | `evaluate returns Decided with protected headlined over a bank size rule` | exclusion no-take + bank 38 mm | `protected` headline | The sixth trace: the exclusion at 40 beating the bank at 20 |
| 16 | `evaluate returns Ambiguous for two bank rules that disagree` | two 2024 orders, both bank 20, 38 mm and 40 mm | `Ambiguous`, both citations | The seventh trace, and `SPEC.md` §7.3 step 4 end to end |
| 17 | `evaluate returns NoLimitInInstrument for a rule that records no limit` | rule with every limit column null and no seasons | `NoLimitInInstrument` with its citation | The variant that must not be confused with T11's absence |
| 18 | `evaluate returns a Failure for a malformed rule row` | size column with no method | `Failure(MalformedRule)` | The T02 boundary at the public entry point |
| 19 | `evaluate does not read a clock` | source scan of `lib/` for `DateTime.now` | no hits | `catchlaw-rule-engine` rule 3, asserted rather than left to the gate's grep |
| 20 | `evaluate resolves 20 candidate rows in under 10 ms` | 20 rows, 1,000 iterations | mean under 10 ms | `SPEC.md` §13. Catches an O(n²) sweep or a parse inside a loop — invisible at three rows, obvious at twenty |
| 21 | `evaluate returns the same result for the same input on two runs` | any fixture, evaluated twice | identical headline, identical `secondary` order, identical `Ambiguous` order | Determinism is the property T04's stable sort and T09's index tie-break exist for, and nothing else in the suite asserts it end to end |

```dart
// packages/rule_engine/test/verdict/no_strings_test.dart
import 'dart:io';

import 'package:test/test.dart';

final _directive = RegExp(r'''^\s*(import|export|part)\b''');
final _literal = RegExp(r"""'[^']*'|"[^"]*\"""");

Iterable<File> _verdictSurface() => ['lib/src/findings', 'lib/src/verdict']
    .map(Directory.new)
    .expand((d) => d.listSync(recursive: true))
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'));

void main() {
  test('no file under findings or verdict contains a string literal', () {
    final hits = <String>[];
    for (final file in _verdictSurface()) {
      var lineNumber = 0;
      for (final line in file.readAsLinesSync()) {
        lineNumber++;
        final code = line.replaceFirst(RegExp(r'//.*'), '');
        if (_directive.hasMatch(code)) continue;
        if (_literal.hasMatch(code)) hits.add('${file.path}:$lineNumber: $line');
      }
    }
    expect(hits, isEmpty, reason: 'D-7: the engine holds no user-visible sentence in any language');
  });
}
```

```dart
// packages/rule_engine/test/rule_evaluator_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:rule_engine/testing/utils/result.dart';
import 'package:test/test.dart';

void main() {
  group('evaluate', () {
    test('returns Decided with is_expired for a lapsed piracema portaria', () {
      final rule = kRuleTucunareBagLimit.copyWith(validTo: '2026-02-28');
      final resolution = evaluate(kJurumirimRequest, [rule]).asOk.value;
      expect(resolution, isA<Decided>());
      expect(resolution.isExpired, isTrue);
      expect((resolution as Decided).headline, isA<BagLimitFinding>());
    });

    test('returns Ambiguous for two bank rules that disagree', () {
      final resolution =
          evaluate(kCambadosRequest, [kRuleCambadosVedas38, kRuleCambadosPlan40]).asOk.value;
      final ambiguous = resolution as Ambiguous;
      expect(ambiguous.citations, hasLength(2));
      expect(ambiguous.rules.map((r) => r.minSizeMm), [38, 40]);
    });
  });
}
```

**Run:** `dart test` → 21 failures (row 8 expands to three). If row 13 passes now, the fixture's
`validTo` is not in the past relative to its `on`.

## Implementation outline

1. `lib/src/verdict/resolution.dart`:
   - `sealed class Resolution` with `const Resolution()`, `List<Citation> get citations` and
     `bool get isExpired`, both abstract.
   - `final class Decided extends Resolution` — `Finding headline`, `List<Finding> secondary`;
     `Citation get citation => headline.citation`; `citations` is headline plus secondaries;
     `isExpired` is any of them.
   - `final class Ambiguous extends Resolution` — `List<Rule> rules` (2 or more, source order, with
     an assert), `List<bool> expiredFlags` folded into `isExpired`; `citations` maps the rules.
   - `final class NoLimitInInstrument extends Resolution` — `Citation citation`, `bool isExpired`.
2. `lib/src/rule_evaluator.dart`: `Result<Resolution> evaluate(EvaluationRequest, Iterable<Rule>)`:
   `selectCandidates` → `matchAndRank` → `findConflict` (return `Ambiguous` if non-empty) →
   `findingsFor` on the winning candidate and every lower-specificity survivor → `rankFindings` →
   `Decided`, or `NoLimitInInstrument` when the finding list is empty. The empty-ranked-list case is
   T11's; until then it returns `Failure` with an explicit "T11 owns this" doc comment — and T11
   deletes that line, which is what makes the dependency visible in the diff.
3. Library doc comment on `lib/rule_engine.dart`: what the package is, what it never contains (D-7),
   and the one-line boundary between `Result` and `Resolution`.
4. Re-run the whole suite. All 21 green; T01–T09 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 21 tests pass, and each failed first.
- [ ] Branch coverage on `lib/src/verdict/` and `rule_evaluator.dart` is 100%.
- [ ] `Resolution` has three arms, all `final`, and every `switch` over it in the package has no
      `default:`.
- [ ] There is no `unavailable`, `error`, `hidden` or `meets` arm.
- [ ] Every arm's `citations` is non-empty, asserted by row 8's loop over all arms.
- [ ] No string literal exists under `lib/src/findings/` or `lib/src/verdict/`.
- [ ] `evaluate` is the only public function in `rule_evaluator.dart`.
- [ ] The latency assertion is under 10 ms at 20 rows, and its doc comment says it is a CI regression
      guard rather than a device measurement.
- [ ] The barrel carries a library-level doc comment (`FLUTTER_GUIDE.md` §2.6).

## Gates

```bash
cd packages/rule_engine && dart format --set-exit-if-changed . && dart analyze && dart test
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh packages/rule_engine/lib
```

Check 4 of `check_app_invariants.sh` (nullable `Citation`) and check 6 (expiry used as a gate) are
the two that this task's diff could break. Both are heuristic greps; rows 4, 8 and 13 are the proof.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(rule_engine): close the Resolution union and expose evaluate as the engine's only entry point

Three sealed arms — Decided, Ambiguous, NoLimitInInstrument — each carrying
numbers, enums, a required non-nullable Citation and an isExpired flag, and
none carrying a word. D-7 is proved rather than promised: a test asserts no
file under lib/src/findings/ or lib/src/verdict/ contains a string literal
outside an import. The Strings that do travel are ISO dates and the two
verbatim citation fields quoted from a published instrument, neither
composed here and neither localised.

There is no unavailable arm and no expiry arm, because an expired ruleset is
evaluated and shown and withholding is itself advice with no network to
recover from. There is no Meets arm either: a legal fish is a Decided whose
headline passes, and the margin still prints.

NoLimitInInstrument needs no schema column — a rule row with no limits and
no seasons is exactly an instrument that covers this species and records
nothing, which is a positive cited statement rather than an absence.

evaluate returns Result<Resolution> and the Result arm carries content
defects only. Benchmarked at 20 candidate rows against the SPEC 13 budget of
10 ms; that runs on CI and is a regression guard, not a device measurement.

Task: E03/T10
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
