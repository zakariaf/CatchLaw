# E12/T08 — The evaluation seam

| | |
|---|---|
| **Epic** | E12 — Check home and the navigation shell |
| **Release** | **v1**, and it is built **FIRST** in this epic — T02 and T07 both assume it exists |
| **Branch** | `epic/12-check-home` (shared) |
| **Commit** | `feat(check): evaluate a species in a zone and hand the result to E10` |
| **Depends on** | E03 (the evaluator), E05 (the repositories), E10 (the presenter), E11/T04 (an active zone) |
| **Size** | L |
| **Spec** | `SPEC.md` §3 (the core loop), §7.3 (resolution), §4.1 (rule evaluation), §13 (the budget) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Owns what `evaluate` needs and what it returns; this task supplies the inputs and touches none of the semantics |
| `catchlaw-conventions-index` | The one-way layer map. This is a `domain/use_cases/` join over three repositories, and `ui/` never touches a DAO |
| `catchlaw-reference-database` | Which repository answers which half of the question, and why the two databases are never joined in SQL |
| `flutter:state-management-riverpod` | Where the seam is bound, and why the family key is a value type rather than a record of live objects |
| `flutter:async-safety` | **Load it by name** — its frontmatter does not parse, so it will not auto-invoke |
| `catchlaw-verdict-contract` | Nothing in this file produces a sentence. If a string appears here, the seam is in the wrong layer |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.3 | The two-stage resolution the engine performs, and what the app must hand it |
| `SPEC.md` | §4.1 "Rule evaluation" | The acceptance condition: every finding names its rule row and citation |
| `packages/rule_engine/lib/src/rule_evaluator.dart` | whole | The signature this task feeds. **Read it before designing anything** |
| `app/lib/ui/result/view_models/verdict_presenter.dart` | `present` | What comes out the other end, and the `ResultContext` it needs |
| `epics/DECISIONS.md` | D-6, D-7, D-22 | Two databases; the engine holds no sentence; why this task exists at all |

## What this delivers

- `app/lib/domain/use_cases/evaluate_catch_use_case.dart` — `EvaluateCatchUseCase`, one method
  taking a species id, the active zone, a landing date and an optional reading, returning
  `Result<Resolution>`. It gathers the rules, the zone chain and the tally, calls
  `packages/rule_engine`, and returns. **It contains no wording and no widget.**
- `app/lib/ui/result/view_models/result_providers.dart` — `resolutionProvider`, a family over a
  value-typed request, and `resultDisplayProvider` joining it to T01's presenter. The provider E10/T01
  deliberately did not build, because the thing it would have watched did not exist.
- `app/lib/ui/species/widgets/species_detail_screen.dart` — the verdict slot, fed. The screen already
  mounts `SpeciesVerdictSlot`; this passes it a display instead of `null`.
- `app/testing/fakes/fake_evaluate_catch_use_case.dart`.
- `app/test/domain/evaluate_catch_use_case_test.dart`,
  `app/test/ui/result/result_providers_test.dart`.

## Why it is built this way

**This is the seam ten merged epics assumed and none of them built.** E03 returns a sealed
`Resolution` from plain values. E05 can read every one of those values. E10 turns a `Resolution` into
six languages. Nothing calls any of it: `flutter run` opens a `SizedBox.shrink()`, and every screen
E08, E09 and E10 shipped is unreachable. D-22 records how that happened — the plan described the
engine, the data and the surface, and never the wire between them.

**A use case and not a repository method.** It joins three sources — the rule rows and zone chain from
`reference.db`, the tally from `user.db`, the reading from E09 — and `FLUTTER_GUIDE.md` §1.9 puts
every cross-repository join in `domain/use_cases/`. A repository that reached into the other database
would also be the first thing in the app to hold both handles at once, which is exactly what D-6's
`ATTACH` ban exists to prevent.

**It returns a `Resolution` and never a sentence.** D-7 keeps user-visible wording out of the engine;
this file keeps it out of the domain layer for the same reason. The presenter is where numbers become
words, and it is the only place `check_verdict_contract.sh` has to sweep.

**The family key is a value type.** A Riverpod family keyed on anything with identity `==` re-creates
its provider on every rebuild, and for this family that means re-reading `reference.db` on every frame
of a ruler drag. `EvaluationRequest` carries a species id, a zone id, an ISO date and an optional
integer reading — four values, structural equality, and a drag that does not move the millimetre
produces no query at all.

**A failure is a failure, not an absence.** A read that threw and a species with no rule are different
facts, and `NoRuleFound` is a legal statement this task must never manufacture from a broken database.
The use case returns `Result<Resolution>`; the provider surfaces the error; the screen shows it.
Collapsing the two would put "no rule recorded for this species here" on screen because a file was
locked.

**Rejected — evaluating inside the presenter.** It would make the one pure, synchronous, six-locale
class asynchronous and database-bound, and every wording test would need a database.

**Rejected — evaluating in `SpeciesDetailScreen`'s `build`.** `FLUTTER_GUIDE.md` §1.2's allow-list,
and a query per relayout during a ruler drag.

## Tests first

Write every row before touching the use case. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `EvaluateCatchUseCase.evaluate returns a Decided for a species with a rule` | seeded rule, reading below the minimum | `Decided` whose headline is the minimum-size finding | The baseline the whole product is |
| 2 | `EvaluateCatchUseCase.evaluate returns NoRuleFound for a species with no rule row` | species present, no rule | `NoRuleFound` carrying the instruments searched | The state the pack is in today, and it must be reachable honestly |
| 3 | `EvaluateCatchUseCase.evaluate returns UnknownSpecies for an id this jurisdiction lacks` | unknown id | `UnknownSpecies` | §4.1's two visually distinct absences start here |
| 4 | `EvaluateCatchUseCase.evaluate passes the zone chain the rule engine needs` | subzone with a parent | the parent's rule reaches the subzone | §7.3 step 2, and the failure is a rule that silently stops applying |
| 5 | `EvaluateCatchUseCase.evaluate carries the reading and its method unchanged` | 380 mm TL | the finding's `measuredMm` is 380 and its method TL | A reading altered between the ruler and the engine is a wrong verdict |
| 6 | `EvaluateCatchUseCase.evaluate evaluates with no reading` | reading null | the size finding is indeterminate, never a pass | An unmeasured fish has not met the minimum; nobody has checked |
| 7 | `EvaluateCatchUseCase.evaluate evaluates an expired rule rather than dropping it` | rule past `valid_to` | a `Decided` with `isExpired` true | Invariant 5 at the seam, not only at the surface |
| 8 | `EvaluateCatchUseCase.evaluate reports a broken read as a failure` | repository throws | `Failure`, and never `NoRuleFound` | "No rule recorded" is a legal statement; a locked file is not one |
| 9 | `EvaluateCatchUseCase.evaluate reads the tally for the landing date` | catch log with 9 today | the bag-limit finding sees 9 | The one place both databases are involved in one answer |
| 10 | `EvaluateCatchUseCase.evaluate opens no second database handle` | any | one reference handle, one user handle, no `ATTACH` | D-6 |
| 11 | `resultDisplayProvider presents the resolution the use case returned` | fake use case | the display's stamp headline is the presenter's sentence | The join E10/T01 deliberately left unbuilt |
| 12 | `resultDisplayProvider does not re-query when the request is unchanged` | same request twice | one call on the fake | A family keyed on identity re-reads the pack on every frame of a drag |
| 13 | `resultDisplayProvider re-queries when the reading changes by a millimetre` | 380 then 381 | two calls | The other half of 12: it must not cache away a real change |
| 14 | `SpeciesDetailScreen renders the verdict when a reading exists` | seeded species and rule | the stamp is on screen | The slot stops being empty; this is the task's visible outcome |

## Implementation outline

1. `EvaluationRequest` — a value type with `==` and `hashCode` over species id, zone id, ISO date and
   the optional reading in millimetres with its method.
2. `EvaluateCatchUseCase.evaluate` — gather, call, return. Every failure path returns `Failure`.
3. `resolutionProvider` — a `FutureProvider.autoDispose.family` over the request.
4. `resultDisplayProvider` — joins `resolutionProvider` and `verdictPresenterProvider`, both of which
   already exist.
5. Feed `SpeciesVerdictSlot`. Delete nothing E10 built; it was written to be fed.
6. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 14 tests pass, and each failed first.
- [ ] No user-visible string anywhere in `evaluate_catch_use_case.dart`.
- [ ] No `ATTACH`, and no file holding both database handles except the use case's constructor.
- [ ] A broken read is never rendered as an absence.
- [ ] `flutter run` reaches a verdict from the Check screen with no code edits.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh    app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(check): evaluate a species in a zone and hand the result to E10

Ten epics built an engine, a database, six locales and a result surface, and
nothing connected them: flutter run opened a SizedBox.shrink(). This is the
wire, and D-22 records how the plan came to omit it.

A use case rather than a repository method, because it joins reference.db,
user.db and the ruler's reading, and because a repository that reached into
the other database would be the first thing in the app holding both handles
at once — which is what D-6's ATTACH ban exists to prevent.

It returns a Resolution and never a sentence. A broken read returns a
Failure and never NoRuleFound: "no rule recorded for this species here" is a
legal statement, and a locked file is not one.

Task: E12/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
