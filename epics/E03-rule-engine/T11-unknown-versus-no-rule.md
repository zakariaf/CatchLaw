# E03/T11 — Unknown species versus no rule recorded

| | |
|---|---|
| **Epic** | E03 — Rule engine: resolution, findings and verdicts |
| **Branch** | `epic/03-rule-engine` (shared) |
| **Commit** | `feat(rule_engine): distinguish an unknown species from a species with no rule recorded` |
| **Depends on** | T10 (the sealed union it adds two arms to) |
| **Size** | S |
| **Spec** | `SPEC.md` §4.1 rows "Unknown species" and "No-rule-vs-no-data"; §7.3; §5.1 arguments 4 and 5; §6 screen S18 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 8: "no rule found" never implies legality, `NoRuleFound(searched:, checkedOn:)` is its own variant listing the instruments consulted, and it is never confused with `NoLimitInInstrument` |
| `catchlaw-verdict-contract` | Rule 7: the no-rule wording is fixed and may not be softened. The engine holds none of those words, so its job is to make sure exactly one of them is reachable |
| `catchlaw-conventions-index` | Invariant 3: these two arms have no single rule and therefore no single citation, and this is where that is resolved without a `Citation?` |
| `dart3-idioms-and-coding-standards` | Adding an arm to a sealed union and letting the analyzer find every switch |
| `testing-strategy` | Two states that are one line apart in code and a fine apart in consequence deserve separate, explicit tests |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.1, "Unknown species" row | *"Explicit 'not in this jurisdiction's list' state that does **not** imply legality"* and the in-app navigation to S18 |
| `SPEC.md` | §4.1, "No-rule-vs-no-data" row | *"Distinguishes 'no size limit exists in this instrument' from 'we have not transcribed this species'. Two visually distinct states"* |
| `SPEC.md` | §5.1, arguments 4 and 5 | *"It never interprets … A species with no transcribed rule returns 'no rule recorded — this does not mean it is legal.'"* |
| `SPEC.md` | §6, S18 | Where the app sends the reader next; the engine's job is only to make the state distinguishable |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rule 8; "Silence in the sources is not permission"; the `findings.isEmpty ? meets` anti-pattern | The three-variant sketch and the sentence "absence of evidence stamped as permission fails silently in exactly the zones with the thinnest content" |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "Edge cases", rows "Species matched but zero rules anywhere" and "Instrument explicitly states no size limit" | The two-way split this task completes, and the `searched`/`checkedOn` payload |
| `.claude/skills/catchlaw-verdict-contract/references/the-five-part-carve-out.md` | Part 4, the first table row | *"species not in the reference DB → 'No rule recorded for this species here. This does not mean it is legal.'"* |
| `.claude/skills/catchlaw-verdict-contract/SKILL.md` | Rule 7 and "The absence of a rule, and the wording that may not be softened" | The three wrong shapes: default-allow, softened, and nothing at all |
| `epics/DECISIONS.md` | D-7 | Both arms carry a list of citations and a date, and not one word of the fixed wording |

## What this delivers

- `packages/rule_engine/lib/src/verdict/resolution.dart` — two new arms, `UnknownSpecies` and
  `NoRuleFound`, closing the union at five.
- `packages/rule_engine/lib/src/rule_evaluator.dart` — the two routes into them, and the deletion of
  T10's placeholder `Failure` on an empty candidate list.
- `packages/rule_engine/test/verdict/absence_test.dart`.

## Why it is built this way

### Three absences, and only one of them is something an instrument says

By the end of this task the engine can be in three states that look identical from a caller's seat
and are legally miles apart. `catchlaw-rule-engine` rule 8 and
`resolution-algorithm.md`'s edge-case table between them fix all three:

| Arm | The world it describes | Payload |
|---|---|---|
| `NoLimitInInstrument` (T10) | The instrument covers this species here and **positively records no limit** | one `Citation` — the instrument says this |
| `NoRuleFound` (here) | The species is in the reference database; **no rule row** covers it in this zone | `searched`, `checkedOn` — what was looked in, and when it was last verified |
| `UnknownSpecies` (here) | The species id is **not in this jurisdiction's list** at all | `speciesId`, `searched`, `checkedOn` |

Collapsing any two of them is the failure `catchlaw-rule-engine` rule 8 names, in the sentence worth
quoting into the commit: *"absence of evidence stamped as permission fails silently in exactly the
zones with the thinnest content."* The zones with the thinnest content are the ones E22 has not
reached yet, which is most of them for most of the product's life.

`SPEC.md` §4.1 requires the last two to be *"two visually distinct states"*, which the app can only
render if the engine returns two distinct types. That is the whole of this task.

### Neither implies legality, and the engine's contribution to that is structural

The wording is `catchlaw-verdict-contract` rule 7's and it is fixed: *"No rule recorded for this
species here. This does not mean it is legal."* Both sentences, in all six locales, never softened to
"No restrictions found", never an empty screen. D-7 puts every one of those words in E06's ARB files
and E10's rendering, so this task's contribution is narrower and more durable: **there is no way to
reach a permissive outcome from an absence.** `Decided` requires a headline `Finding`, a `Finding`
requires a `Rule` to have been found, and neither of these two arms can produce one. The
`findings.isEmpty ? Decided.meets()` shape the skill lists as an anti-pattern is not merely avoided —
it is unrepresentable, because there is no `meets` constructor to reach for (T10).

### Both arms carry what was searched, and the list is non-empty

`resolution-algorithm.md` gives `NoRuleFound(searched:, checkedOn:)` its payload and the reason:
*"what was looked in, so he can say what was looked in."* That is `CONVENTIONS.md` §9 invariant 3
satisfied in the only way an absence can satisfy it — not with one citation, because there is no one
rule, but with the list of instruments that were consulted and the date the transcription was last
verified. A test asserts the list is non-empty, because an empty `List<Citation>` is a `Citation?` in
a different coat and would let an uncited absence ship.

`EvaluationRequest.searched` (declared in T03) already asserts non-empty at construction, and the
guarantee behind it is E04's: a bundled jurisdiction has at least one `citation` row or it would not
have passed the content build. That chain is worth stating in the doc comment, because the assert
looks arbitrary without it.

**This does not weaken invariant 3.** `CONVENTIONS.md` §9 says every result carries a required,
non-nullable `Citation`. Read literally against an arm that describes the absence of any rule, it
would require the engine to name an instrument for a rule that does not exist — which is
`catchlaw-verdict-contract`'s banned `?? 'Local fisheries rules'` fallback. The reading that holds
the invariant's purpose is the one implemented here: the result is never uncited, and where there is
no single source there is a non-empty list of the sources consulted. Recorded here rather than
complied with quietly, per `CONVENTIONS.md` §9's closing instruction.

### The species check happens first, and it is the request's to answer

`EvaluationRequest.species` is `Species?`, declared in T03. Null means the species id was not found
in this jurisdiction's list — a fact the reference database knows and the engine does not, since the
engine is handed rule rows and never queries. So `evaluate` checks `request.species == null` before
stage 1, and returns `UnknownSpecies`. **Rejected:** inferring it from an empty candidate list. That
conflates the two states this task exists to separate, and it would report a well-known species in a
zone nobody has transcribed as if the species itself were unrecognised — sending the reader to S18's
protected-species list for a fish that is simply not covered here.

### Adding two arms to a sealed union is the point of it being sealed

Every `switch` over `Resolution` in the package fails to compile until it handles both. That is
`FLUTTER_GUIDE.md` §7.2's argument for sealed classes made concrete, and it is why T10's exhaustive
switch test exists. Nothing in this package should need a `default:` arm afterwards, and the DoD
checks that none appeared.

## Tests first

Write all 12 rows before touching `resolution.dart`. Run them. **They must fail** — and T10's
exhaustive-switch test must fail too, which is expected and is the signal that the union grew.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `evaluate returns UnknownSpecies when the request carries no species` | `species: null`, rules present | `UnknownSpecies` | `SPEC.md` §4.1: an explicit "not in this jurisdiction's list" state |
| 2 | `evaluate returns UnknownSpecies before it inspects any rule row` | `species: null`, one malformed rule | `UnknownSpecies`, **not** `Failure` | The check is first; a content defect in an unrelated row must not mask the state the reader needs |
| 3 | `evaluate returns NoRuleFound when the species is known and no rule matches` | `species` present, 3 non-matching rules | `NoRuleFound` | `resolution-algorithm.md`: "species matched but zero rules anywhere" |
| 4 | `evaluate returns NoRuleFound when every matching rule is off the zone path` | rules for a sibling subzone | `NoRuleFound` | Absence in *this* zone is still absence; the state must not depend on which stage dropped the last row |
| 5 | `evaluate returns NoRuleFound when every matching rule has a future valid_from` | rules commencing next year | `NoRuleFound` | Third stage, same state. Rows 3–5 together prove one outcome from three different drop points |
| 6 | `UnknownSpecies is distinct from NoRuleFound` | one of each | `isA` on each, and neither matches the other | `SPEC.md` §4.1 requires two visually distinct states, which needs two types |
| 7 | `NoRuleFound reports the instruments that were searched` | `searched` of two citations | both, in order | `resolution-algorithm.md`: "what was looked in, so he can say what was looked in" |
| 8 | `NoRuleFound reports the date the content was last checked` | `contentCheckedOn` 2026-07-14 | that date | Bounds the claim: the app states how current the absence is, rather than asserting it timelessly |
| 9 | `UnknownSpecies reports the species id that was not found` | id 9999 | 9999 | E10 needs it to offer the S18 route and to let the reader report a gap |
| 10 | `every Resolution arm still reports a non-empty citation list` (loop over all five arms, arm interpolated) | one of each | not empty | Invariant 3 across the closed union — the row that would catch an absence arm shipping uncited |
| 11 | `neither absence arm exposes a passing outcome` | both arms | no member, getter or field named `meets`, `passes`, `legal` or `allowed` | `catchlaw-rule-engine` rule 8 and `catchlaw-verdict-contract` rule 7: the permissive reading must be unrepresentable, not merely unused |
| 12 | `Resolution switches exhaustively over five arms with no default` | a `switch` over all five | compiles | The union is closed; a sixth arm added later breaks this and every caller in E10 |

```dart
// packages/rule_engine/test/verdict/absence_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:rule_engine/testing/utils/result.dart';
import 'package:test/test.dart';

void main() {
  group('evaluate', () {
    test('returns UnknownSpecies before it inspects any rule row', () {
      final request = kHamourRequest.copyWith(species: null);
      final malformed = kRuleHamourMinSize.copyWith(measurementMethod: null);
      final resolution = evaluate(request, [malformed]).asOk.value;
      expect(resolution, isA<UnknownSpecies>());
    });

    test('returns NoRuleFound when every matching rule is off the zone path', () {
      final elsewhere = kRuleHamourMinSize.copyWith(zoneId: kZoneFujairah.id);
      final resolution = evaluate(kHamourRequest, [elsewhere]).asOk.value;
      expect(resolution, isA<NoRuleFound>());
      expect((resolution as NoRuleFound).searched, isNotEmpty);
      expect(resolution.checkedOn, '2026-07-14');
    });
  });

  group('Resolution', () {
    for (final resolution in kEveryResolutionArm) {
      test('reports a non-empty citation list for ${resolution.runtimeType}', () {
        expect(resolution.citations, isNotEmpty);
      });
    }
  });
}
```

**Run:** `dart test test/verdict/` → 12 failures (row 10 expands to five), plus T10's exhaustive
switch test failing to compile until the two arms are handled. That compile error is the expected
signal, not a regression.

## Implementation outline

1. `lib/src/verdict/resolution.dart`, two new arms:
   - `final class UnknownSpecies extends Resolution` — `int speciesId`, `List<Citation> searched`,
     `String checkedOn`. `citations` returns `searched`; `isExpired` returns `false`, with a doc
     comment: there is no rule here whose validity could have lapsed, and pack-level currency is
     `jurisdiction.valid_until`, which E05 owns and E10 renders.
   - `final class NoRuleFound extends Resolution` — `List<Citation> searched`, `String checkedOn`.
     Same `citations` and `isExpired`. Both assert `searched.isNotEmpty`.
2. `lib/src/rule_evaluator.dart`:
   - First line of `evaluate`: `if (request.species == null) return Ok(UnknownSpecies(...))`. Before
     stage 1, before any validation.
   - Replace T10's placeholder: an empty ranked list returns `Ok(NoRuleFound(...))`. Delete the
     "T11 owns this" comment.
3. Fix every `switch` the analyzer now flags. There should be exactly the ones T10 wrote; if a
   `default:` arm appears anywhere as the fix, that is the wrong fix.
4. Re-run the whole suite. All 12 green; T01–T10 still green, including T10's exhaustive-switch test
   now covering five arms.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 tests pass, and each failed first.
- [ ] Branch coverage on `lib/src/verdict/` and `rule_evaluator.dart` is 100%.
- [ ] `Resolution` has exactly five arms and every `switch` over it in the package is exhaustive with
      no `default:`.
- [ ] `UnknownSpecies` and `NoRuleFound` are distinct types, and no code path maps either to
      `Decided`, `NoLimitInInstrument` or a passing outcome.
- [ ] Both arms assert `searched.isNotEmpty`, and the doc comment names E04 as the guarantee behind
      it.
- [ ] `grep -rniE 'meets|allowed|legal|permitted' packages/rule_engine/lib/src/verdict` returns
      nothing.
- [ ] The species check runs before stage 1, proved by row 2.
- [ ] The epic's definition of done is now checkable: run it before opening the PR.

## Gates

```bash
cd packages/rule_engine && dart format --set-exit-if-changed . && dart analyze && dart test
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh packages/rule_engine/lib
```

This is the last task of the epic. After the gates, run the epic-level definition of done in
`epic.md` before `gh pr create`.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(rule_engine): distinguish an unknown species from a species with no rule recorded

SPEC 4.1 requires two visually distinct states, which the app can only
render if the engine returns two types. UnknownSpecies means the id is not
in this jurisdiction's list; NoRuleFound means the species is known and no
rule row covers it here. Neither is inferred from the other: reading an
empty candidate list as an unrecognised species would send a reader to the
protected-species screen for a fish that is simply not covered in this zone.

Both are separate again from NoLimitInInstrument, which is the one absence
an instrument actually states. Collapsing any two of the three is what rule
8 of the engine skill describes as absence of evidence stamped as
permission, failing silently in exactly the zones with the thinnest content
— which is most zones for most of this product's life.

Neither arm can reach a permissive outcome, and that is structural rather
than careful: Decided requires a headline Finding, a Finding requires a rule
to have been found, and there is no meets constructor anywhere to reach for.

Invariant 3 is held rather than bent. An absence has no single instrument to
cite, so each arm carries the non-empty list of instruments that were
searched and the date the transcription was last checked. An empty list
would be a nullable Citation in a different coat, so both arms assert
against it.

Task: E03/T11
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
