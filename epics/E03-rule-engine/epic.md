# E03 — Rule engine: resolution, findings and verdicts

| | |
|---|---|
| **Branch** | `epic/03-rule-engine` |
| **After** | E02 merged |
| **Tasks** | 11 |
| **Spec** | `SPEC.md` §7.3 (this epic *is* §7.3), §7.1 (`rule`, `closed_season`, `zone`, `citation`), §4.1, §5.1, §13 (rule evaluation < 10 ms) |
| **Guide** | `FLUTTER_GUIDE.md` §1.6, §1.9, §2.5, §6.1, §6.4, §7.2, §7.5 |
| **Package** | `packages/rule_engine/` |

## What this epic achieves

After this merges, the question the whole product exists to answer can be answered in pure Dart:
given a jurisdiction, a zone, a species, a water type, a date, a measurement and today's tally,
`packages/rule_engine/` returns a sealed `Resolution` — one headline finding, the secondary findings
beneath it, the citation of every instrument involved, and an `isExpired` flag — or it returns both
conflicting rules and refuses to choose, or it says the species is not in this jurisdiction's list,
or it says no rule is recorded here. It states none of that in words: the engine returns numbers,
enums and `Citation` values, and `app/lib/ui/` turns them into sentences from E06 onward (D-7).

Two later epics stop being blocked. E04 can validate authored YAML with the same value types the app
will read it through, which is what `SPEC.md` §15 step 3 means by *"imports the §2 package so data
is validated by the code that will read it"*. E10 can build the result screen against a type it can
switch on exhaustively rather than a bag of nullable fields.

## Where we are now

E01 cut the pub workspace of D-1 — `app/`, `packages/rule_engine/`, `packages/analysis_defaults/`,
`tools/content_builder/` — and wired every `SPEC.md` §14 static check into CI from the first commit.

E02 left `packages/rule_engine/` as a package that builds and tests under plain `dart test`: a
`pubspec.yaml` that declares no `flutter:` SDK dependency (so a Flutter import is a compile error and
not a lint, per `catchlaw-rule-engine` rule 2), a nested `analysis_options.yaml` that includes the
workspace root's, the single sanctioned barrel `lib/rule_engine.dart` (`FLUTTER_GUIDE.md` §2.6), and
the `SPEC.md` §9.4 normalisation contract under `lib/src/` with its five-input acceptance test.

What does not exist: any domain model, any error type, any resolution. In `FLUTTER_GUIDE.md` §2.5's
tree, `packages/rule_engine/lib/src/models/`, `lib/src/failure.dart` and `lib/src/rule_evaluator.dart`
are still empty names on a page. Nothing in the repository can yet turn a rule row into a finding.

## Why this epic exists here in the order

It cannot come earlier than E02 because `SPEC.md` §4.1 makes species resolution a precondition of
rule evaluation — `resolve()` takes a `speciesId` that search has already produced, and the
normalisation contract that produces it is E02's.

It must not come later than E04 because `SPEC.md` §15 step 3 requires the content builder to
validate authored YAML *through the types that will read it at runtime*. If E04 shipped first it
would grow its own parallel model set, and the day the two disagree is the day a `reference.db`
passes every build assertion and produces a wrong finding on a phone. The same argument covers E05:
`app/lib/data/model/` maps drift rows into these types and cannot be written before they exist.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | The domain models | `T01-domain-models.md` | M | — |
| T02 | The `Failure` type | `T02-failure-type.md` | S | T01 |
| T03 | Candidate selection, and why expiry does not delete | `T03-candidate-selection.md` | L | T01, T02 |
| T04 | Zone ancestry and the specificity ladder | `T04-zone-ancestry-specificity.md` | M | T03 |
| T05 | Ambiguity: return both, choose neither | `T05-ambiguity-returns-both.md` | M | T04 |
| T06 | Closed seasons: wrap-around, fixed windows, leap years | `T06-closed-seasons.md` | L | T01 |
| T07 | Size findings and the measurement method | `T07-size-findings.md` | M | T06 |
| T08 | Bag limit and vessel limit | `T08-bag-and-vessel-limits.md` | M | T07 |
| T09 | Precedence and the headline finding | `T09-precedence-and-headline.md` | M | T06, T07, T08 |
| T10 | The sealed verdict types | `T10-sealed-verdicts.md` | M | T05, T09 |
| T11 | Unknown species versus no rule recorded | `T11-unknown-versus-no-rule.md` | S | T10 |

T06 is deliberately not blocked on the resolution chain: closed-season arithmetic reads a
`ClosedSeason` and a date and nothing else, so it can be built the moment T01 lands.

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once all eleven have landed:

- [ ] All 11 tasks committed, one commit each, every `Task: E03/T<nn>` trailer present.
- [ ] `dart test` green in `packages/rule_engine/`, with **100% branch coverage** on
      `lib/src/resolve/`, `lib/src/season/`, `lib/src/findings/` and `lib/src/verdict/`
      (`CONVENTIONS.md` §6; `FLUTTER_GUIDE.md` §6.3).
- [ ] `packages/rule_engine/` still has zero `package:flutter` imports — proved by its pubspec, not
      by grep (`FLUTTER_GUIDE.md` §2.5 rule 8).
- [ ] `grep -rn 'valid_to\|validTo' packages/rule_engine/lib` shows `validTo` only as a field, as an
      `isBefore` comparison and as a printed date — never inside `.where`, `removeWhere`,
      `retainWhere` or `takeWhile`. This is the epic's headline correctness property.
- [ ] `grep -rn 'DateTime.now()' packages/rule_engine/lib` returns nothing.
- [ ] The `SPEC.md` §14 expiry test is reproducible as a unit test: a rule with `valid_to` two years
      in the past still produces a finding with its numbers intact and `isExpired == true`.
- [ ] Every `Resolution` variant returns a non-empty `citations` list; no `Citation?` exists anywhere
      in the package (`CONVENTIONS.md` §9 invariant 3).
- [ ] No `.dart` file under `lib/src/findings/` or `lib/src/verdict/` contains a string literal
      outside an `import`/`export`/`part` directive (D-7).
- [ ] `evaluate` resolves 20 candidate rows in **under 10 ms** (`SPEC.md` §13), asserted as a test.
- [ ] `check_rule_engine.sh packages/rule_engine/lib` and
      `check_app_invariants.sh packages/rule_engine/lib` both clean.
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin`; branch deleted (D-9).

## Risks and the things that will bite

**1. `citation lineage` has no column.** `SPEC.md` §7.3 collapses candidates to the greatest
`valid_from` *per `(zone_id, citation lineage)`*, and `catchlaw-rule-engine`
`references/resolution-algorithm.md` names the key `citation_lineage_id`. There is no such column in
`SPEC.md` §7.1 — `citation` has `id`, `instrument_type_key`, `instrument_ref`, `article_ref` and no
lineage. The engine therefore takes `citationLineageId` as a field on its own `Rule` value type
(T01) and the mapper must supply it. **What resolves it:** E04 adding `citation.lineage_id` to the
authored schema, with a build assertion that a 2018 amendment and the 2015 instrument it amends share
one lineage id and a different-instrument local order does not. Until then, a mapper that sets
lineage to the citation id makes stage 2 collapse nothing, which is the safe direction — it produces
an `Ambiguous` where a collapse was wanted, never a silent pick.

**2. `vessel_limit` carries no unit and no period.** `SPEC.md` §7.1 gives `bag_limit` a
`bag_limit_unit` and a `bag_limit_period`; `vessel_limit` is a bare `INTEGER`. T08 therefore models a
vessel limit as a count with no period, because the engine may not state a period the instrument as
transcribed did not give it. **What resolves it:** E04 or E22 finding a real bundled vessel limit
expressed in kilograms or per trip, which would require a schema change mirroring the bag columns.

**3. `MeasurementMethod.custom` is not unique.** `SPEC.md` §4.2 allows *"a per-jurisdiction custom
method"* and §7.1 gives it the single code `CUSTOM`. Two jurisdictions' custom methods are then equal
under `==`. T07's comparison is sound only because stage 1 has already filtered to one jurisdiction.
**What resolves it:** E04 asserting that each jurisdiction's custom method gets a distinct
`measurement_method.code`, so the enum cannot conflate two of them.

**4. An annual recurrence bounded on 29 February is undefined.** `SPEC.md` §7.3 and §7.1 say nothing
about it, and no bundled instrument is known to use it. T06 treats it as a content defect and returns
a `Failure` rather than guessing 28 February or 1 March — both of which are a day of closure the
engine would have invented. **What resolves it:** E22 surfacing a real instrument that does it, at
which point `SPEC.md` §7.3 needs one sentence and T06 needs one branch.

**5. `List.sort` in Dart is not stable.** The ambiguity contract in
`catchlaw-verdict-contract/references/the-five-part-carve-out.md` part 3 requires both conflicting
rules to print *in source order*. T04 sorts with an index-decorated comparator for exactly this
reason. Any later `.sort` added to a candidate or finding list reintroduces the defect silently, and
it shows up as a screen that renders two orders on two runs of the same input.

**6. `specificity` exists twice.** `SPEC.md` §7.1 stores `rule.specificity INTEGER NOT NULL` and
§7.3 publishes the ladder that produces it. The engine derives from the zone kind and never reads the
column (T04). If E04 writes a value that disagrees with the ladder, nothing in this epic notices.
**What resolves it:** E04 asserting `rule.specificity == ladder(zone.zone_kind)` at build time.

**7. The < 10 ms budget is measured on the wrong machine.** `SPEC.md` §13 names a Snapdragon 665 for
the launch targets and does not name a device for rule evaluation. T10's benchmark runs on CI, which
is faster than the phone. It is a regression guard, not a proof. **What resolves it:** E21 measuring
the same fixture on a physical low-end device as part of the §14 walkthrough.

## PR description

### What changed

`packages/rule_engine/` gains the whole of `SPEC.md` §7.3. Eleven commits, in order: the immutable
domain models; the sealed `Result`/`Failure` pair copied from `FLUTTER_GUIDE.md` §1.6; candidate
selection with lineage collapse and the `isExpired` tag; zone ancestry and the specificity ladder;
ambiguity detection; closed-season arithmetic; size, bag and vessel findings; finding precedence; the
sealed `Resolution` union; and the two distinct absence states.

### Why

`SPEC.md` §7.3 is the product. It is also the one place in the codebase where a mistake is a legal
exposure rather than a bug, which is why the selection predicate omits `valid_to`, the tie is
returned rather than broken, and the engine holds no sentence in any language.

### How it was verified

100% branch coverage over `lib/src/resolve/`, `lib/src/season/`, `lib/src/findings/` and
`lib/src/verdict/`. Frozen dates throughout — no test reads a wall clock. The `SPEC.md` §14 expiry
scenario and the clock-set-backwards scenario are both unit tests here before they are device tests
in E21. `check_rule_engine.sh` and `check_app_invariants.sh` clean over
`packages/rule_engine/lib`. `evaluate` benchmarked at 20 candidate rows against the §13 10 ms budget.

### Product invariants touched

Invariant 3 (every result carries a required, non-nullable `Citation`) and invariant 5 (an expired
ruleset is still evaluated and still shown) are both *established* here — this epic is where they
become mechanically true rather than aspirational. Invariant 2 is protected by omission: D-7 keeps
every word out of this package, so there is no sentence here to make imperative. Invariants 1 and 4
are untouched — no network, no colour.

### Follow-ups deliberately not in this PR

- The wall-clock `Clock` implementation: it belongs where it has a consumer, in E10.
- Point-in-polygon zone selection: the engine takes a materialised `zonePath` and E11 produces it.
- Every user-visible string, in every locale: D-7, delivered by E06 and E10.
- The `citation.lineage_id` schema column: risk 1 above, owned by E04.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start E04.
