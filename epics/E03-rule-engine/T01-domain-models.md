# E03/T01 — The domain models

| | |
|---|---|
| **Epic** | E03 — Rule engine: resolution, findings and verdicts |
| **Branch** | `epic/03-rule-engine` (shared) |
| **Commit** | `feat(rule_engine): add the immutable domain models for SPEC 7.1 rule resolution` |
| **Depends on** | — (first task of the epic; E02 merged) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.1 (`rule`, `zone`, `citation`, `species`, `measurement_method`, `closed_season`), §7.3, §4.2 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 2 (no Flutter, `package:meta` not `package:flutter/foundation.dart` for `@immutable`) and rule 9 (`Citation` is required and non-nullable on everything that carries one) |
| `catchlaw-verdict-contract` | Rule 5 fixes the `Citation` quadruple — instrument, article, `publishedOn`, `checkedOn` — as the four required fields of this task's most important model |
| `catchlaw-conventions-index` | Invariant 3, and the one-way layer map: these types are the boundary the app and the content CLI both cross, so nothing drift-shaped or Flutter-shaped may enter |
| `dart3-idioms-and-coding-standards` | `final class`, const constructors, enhanced enums, and when a record beats a class |
| `error-handling-typed-results` | Not used here, but it fixes what a *validation* failure looks like so T01 does not invent throwing constructors that T02 then has to unpick |
| `testing-strategy` | Pure unit level, `dart test`, no widget binding |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.1, the `rule`, `zone`, `citation`, `species`, `measurement_method` and `closed_season` `CREATE TABLE` statements | Every column, every `CHECK` constraint, every nullability. The `CHECK` lists are the enum members |
| `SPEC.md` | §7.3 | Which of those columns resolution actually consumes, and that `valid_to` is data and never a predicate |
| `SPEC.md` | §4.2, last two rows | Why the measurement method is per-species-per-jurisdiction and comes from the active rule row |
| `FLUTTER_GUIDE.md` | §2.5 | `packages/rule_engine/lib/src/models/` — "immutable, const constructors" — and rule 6, drift row classes never escape `data/` |
| `FLUTTER_GUIDE.md` | §7.2 | Sealed and `final` class modifiers, enhanced enums, records instead of tuple classes |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rules 2, 9; Anti-patterns | `package:meta` for `@immutable`; `Citation? citation` named as the defect it is; a drift `RuleData` passed to `resolve()` named as the other one |
| `.claude/skills/catchlaw-verdict-contract/references/the-five-part-carve-out.md` | Part 2 | The four `Citation` fields and, per field, why it is not optional |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §3, the citation contract | `instrument` as printed and never abbreviated; `publishedOn` dates the law, not the build |
| `epics/DECISIONS.md` | D-1, D-7 | Where the package lives; the engine returns types, the app owns every word |

## What this delivers

- `packages/rule_engine/lib/src/models/citation.dart` — `Citation`, four required non-nullable
  fields.
- `packages/rule_engine/lib/src/models/measurement_method.dart` — `enum MeasurementMethod` with the
  nine `SPEC.md` §7.1 codes.
- `packages/rule_engine/lib/src/models/species.dart` — `Species`, `enum TaxonGroup`.
- `packages/rule_engine/lib/src/models/zone.dart` — `Zone`, `enum ZoneKind`, `enum WaterType`.
- `packages/rule_engine/lib/src/models/closed_season.dart` — `ClosedSeason`, `enum Recurrence`.
- `packages/rule_engine/lib/src/models/rule.dart` — `Rule`, `enum LimitUnit`, `enum LimitPeriod`.
- `packages/rule_engine/lib/src/models/landing.dart` — `Landing`, the measured individual.
- `packages/rule_engine/lib/rule_engine.dart` — the seven files exported from the single barrel.
- `packages/rule_engine/testing/models/fixtures.dart` — `kCitationMd580`, `kRuleHamourMinSize`,
  `kZoneRasAlKhaimah`, `kSpeciesHamour` and friends, `k`-prefixed per `CONVENTIONS.md` §6.
- `packages/rule_engine/test/models/*_test.dart` — one file per model.

## Why it is built this way

**These are value types, not row types.** `FLUTTER_GUIDE.md` §2.5 rule 6 says drift row classes never
escape `data/`, and `catchlaw-rule-engine` lists *"passing a drift `RuleData` row into `resolve()`"*
as an anti-pattern with a specific consequence: the content CLI could then no longer build a fixture
without opening SQLite, and `tools/content_builder/` is a plain `dart run` binary. Every model here
is constructible from three literals in a test file.

**Millimetres, everywhere, as `int`.** `SPEC.md` §7.1 stores `min_size_mm` and `max_size_mm` as
`INTEGER`. The engine keeps that unit end to end and `Landing.lengthMm` is an `int` too, so a size
comparison is integer comparison and there is no floating-point path from the ruler to the finding.
**Rejected:** carrying a `unit` string alongside the number, which is what
`catchlaw-rule-engine/examples/rule_resolution.dart` does in its illustrative typedef. Two rows in
one instrument expressed in two units is a content bug that E04 should reject, not a runtime branch
the engine should carry — and a `unit` field makes `38 cm` and `380 mm` two distinct values that
`outcomeEquals` (T05) would report as a legal conflict. Unit *rendering* is the app's, from E09's
locale preference.

**Dates are ISO-8601 `String`, exactly as `SPEC.md` §7.1 stores them, and this is not a shortcut.**
`DateTime` has no const constructor, so a model with a `DateTime` field can never be instantiated in
a `const` context — `const Rule(validFrom: DateTime.utc(2015, 11, 3))` does not compile. That would
cost `FLUTTER_GUIDE.md` §2.5's "immutable, const constructors" and, more concretely, it would make
every fixture in `testing/models/fixtures.dart` a runtime allocation and every fixture-shaped test
argument non-const. The string form also removes a whole bug family: there is no time component and
no timezone to normalise, which is the trap `DateTime.parse('2026-07-30')` sets by returning local
midnight. Comparison and arithmetic go through one helper, `parseIsoDate(String) -> DateTime` in UTC,
introduced by T03 and reused by T06. **Rejected:** `DateTime` fields with an `assert(d.isUtc)` — the
assert cannot fire in a const context because there are no const instances left to check.

**`Citation` has four required fields and no factory.** `catchlaw-verdict-contract` rule 5 and
`CONVENTIONS.md` §9 invariant 3 both make this structural rather than asserted: there must be no way
to construct a finding without one. The specific banned shapes are `Citation?`, a default value, and
`citation ?? Citation.unknown()`. `check_app_invariants.sh` check 4 greps for the first of those, so
this task's gate run is the moment that grep starts protecting something.

**`Rule` carries `citationLineageId`, which `SPEC.md` §7.1 has no column for.** `SPEC.md` §7.3
collapses on `(zone_id, citation lineage)` and there is no lineage column in the schema. Naming the
field here, on the engine's own type, puts the gap where a mapper must look at it instead of leaving
stage 2 (T03) to invent a key. Epic risk 1 records what would close it. The safe default — lineage =
citation id — collapses nothing and can only produce an `Ambiguous`, never a silent pick.

**`ClosedSeason.citation` is non-nullable even though the column is not.** `SPEC.md` §7.1 declares
`closed_season.citation_id INTEGER REFERENCES citation(id)` — nullable — while `rule.citation_id` is
`NOT NULL`. A nullable field here would put a `Citation?` in the package, which
`CONVENTIONS.md` §9 invariant 3 forbids and `check_app_invariants.sh` check 4 greps for. The
resolution is not an escape hatch and not a `?? Citation.unknown()`: a `closed_season` row is a child
of a `rule` (`rule_id NOT NULL … ON DELETE CASCADE`), so when the season names no instrument of its
own, the instrument is its parent rule's — a real, present, cited row. E05's mapper performs that
substitution once, in the layer that reads the schema, and the engine never sees the null. Record it
in the doc comment so the mapper's author finds the reason rather than the rule.

**`Rule` owns its `closedSeasons`.** `SPEC.md` §7.1 hangs `closed_season` off `rule_id` with
`ON DELETE CASCADE`; a season with no rule is not representable in the database and is not
representable here either. **Rejected:** a free-standing `List<ClosedSeason>` on the request, which
would let T09 attribute a closure to a rule that did not carry it and cite the wrong instrument.

**`ZoneKind` mirrors the `SPEC.md` §7.1 `CHECK` list, including `basin`.**
`catchlaw-rule-engine/references/resolution-algorithm.md`'s ladder table omits `basin`; §7.3's prose
says *"bank/basin 20"*. `SPEC.md` is authoritative for the product, so `basin` is a member and T04
gives it 20. The enum is plain here — the specificity integers arrive in T04, which is the task that
publishes the ladder.

**`@immutable` comes from `package:meta`.** `catchlaw-rule-engine` names
`import 'package:flutter/foundation.dart'` for `@immutable` as an anti-pattern with a concrete cost:
it drags Flutter into the shared package and breaks the CLI build. `package:meta` is a plain Dart
dependency.

**Rejected: `freezed`.** `FLUTTER_GUIDE.md` §7.3 measures the real cost of freezed as 21× code
amplification rather than build time. Seven small value types with hand-written `==` and `hashCode`
are ~250 lines total; the generated equivalent is thousands, and `dart3-idioms-and-coding-standards`
does not require codegen for a const value type. Records are used where a type has no identity
(`SeasonStatus` in T06); classes where it does.

**Rejected: validation in the constructors.** A `Rule` whose `minSizeMm` exceeds its `maxSizeMm`
violates the `CHECK` in `SPEC.md` §7.1 and is a content defect. Throwing from a const constructor
would make it unrepresentable in a test fixture that wants to prove the engine survives bad content.
T02 gives that class of problem a return type; asserts in these constructors are limited to what a
correct mapper can always satisfy.

## Tests first

Write every row before creating a single file under `lib/src/models/`. Run them. **They must fail** —
they will not even compile, which counts. If one passes now, the test is asserting something that
already exists and is therefore testing nothing.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `Citation requires an instrument, an article, a published date and a checked date` | the four arguments | constructs | The quadruple of `the-five-part-carve-out.md` part 2 is the whole citation contract |
| 2 | `Citation compares equal to an identical citation` | two identical literals | `==` true | T05's `outcomeEquals` must be able to exclude citation identity from a comparison, which needs `==` to mean value equality |
| 3 | `Citation is a compile-time constant` | `const Citation(...)` in a `const` context | compiles | `FLUTTER_GUIDE.md` §2.5 says const constructors; a fixture in `testing/models/` is `const` and a non-const constructor breaks every one |
| 4 | `MeasurementMethod exposes the nine SPEC 7.1 codes` | `MeasurementMethod.values` | codes `TL FL SL CW CL ML DW SHL CUSTOM` | The mapper round-trips `measurement_method.code`; a tenth or a missing member is a silent join failure in E05 |
| 5 | `MeasurementMethod.fromCode returns null for an unknown code` | `'XX'` | `null` | A content typo must reach T02's failure channel, not throw out of a mapper |
| 6 | `WaterType exposes salt, fresh and both` | `WaterType.values` | three members | `SPEC.md` §7.1 `CHECK (water_type IN ('salt','fresh','both'))`; `both` is the member the skill's example forgets and T03's filter turns on |
| 7 | `ZoneKind exposes the six SPEC 7.1 kinds` | `ZoneKind.values` | `region subzone bank basin reserve exclusion` | `basin` is absent from the skill's ladder table and present in §7.1 and §7.3; this test is what stops it being dropped again |
| 8 | `Zone accepts a null parent for a root zone` | `parentZoneId: null` | constructs | `SPEC.md` §7.1 `parent_zone_id INTEGER REFERENCES zone(id)` is nullable; the jurisdiction-level zone has no parent |
| 9 | `Rule accepts a null zone id meaning the whole jurisdiction` | `zoneId: null` | constructs | `SPEC.md` §7.1 comment `-- NULL = whole jurisdiction`; T04 ranks it at 0 |
| 10 | `Rule requires a non-nullable citation` | omit `citation` | does not compile (analyzer test, asserted by the gate not by `expect`) | Invariant 3 has to be structural; a `Citation?` here is the defect `check_app_invariants.sh` check 4 exists for |
| 11 | `Rule accepts a null valid_to meaning no expiry` | `validTo: null` | constructs | `SPEC.md` §7.1; `product-invariants.md` §5 — a pack with no `validUntil` is valid, never expired |
| 12 | `Rule carries its closed seasons` | one `ClosedSeason` | `rule.closedSeasons.length == 1` | The `ON DELETE CASCADE` relationship is modelled as containment so T09 cannot cite the wrong instrument for a closure |
| 13 | `ClosedSeason accepts an annual recurrence with month and day bounds only` | `recurrence: annual`, dates null | constructs | `SPEC.md` §7.1 makes all six bound columns nullable because the two recurrence kinds use different pairs |
| 14 | `ClosedSeason accepts a fixed recurrence with start and end dates only` | `recurrence: fixed`, months null | constructs | The other half of the same shape; T06 branches on `recurrence`, never on which fields happen to be null |
| 15 | `ClosedSeason requires a non-nullable citation` | the four arguments | constructs; no `Citation?` in the package | `SPEC.md` §7.1 makes `closed_season.citation_id` nullable and `rule.citation_id` `NOT NULL`. Invariant 3 wins on the engine side, so E05's mapper substitutes the parent rule's citation when the column is null. That keeps `check_app_invariants.sh` check 4 clean with zero escape hatches |
| 16 | `Landing carries a length in millimetres and the method it was taken by` | `lengthMm: 380`, `method: totalLength` | fields | `SPEC.md` §4.2 last row: the method comes from the active rule row, so a reading without one cannot be compared |
| 17 | `Rule compares equal to an identical rule` | two identical literals | `==` true | T03's lineage collapse and T05's conflict detection both put rules in collections; identity equality would make a map key useless |
| 18 | `rule_engine barrel exports every model` | `import 'package:rule_engine/rule_engine.dart'` and name all seven | compiles | `FLUTTER_GUIDE.md` §2.6 allows exactly one barrel and the app imports only through it; a model reachable only by `src/` path is a private type the mapper cannot use |
| 19 | `Rule.copyWith replaces valid_to and leaves every other field alone` | `kRuleHamourMinSize.copyWith(validTo: '2024-06-30')` | only `validTo` differs | T03 through T09 vary one field of one fixture per test; without `copyWith` each of those ~80 tests restates twenty arguments and stops saying which one it is about |

```dart
// packages/rule_engine/test/models/citation_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Citation', () {
    test('requires an instrument, an article, a published date and a checked date', () {
      const c = Citation(
        instrument: 'Ministerial Decision 580/2015',
        article: 'Art. 3',
        publishedOn: '2015-11-03',
        checkedOn: '2026-07-14',
      );
      expect(c.instrument, 'Ministerial Decision 580/2015');
      expect(c.article, 'Art. 3');
    });

    test('compares equal to an identical citation', () {
      expect(kCitationMd580, equals(kCitationMd580Copy));
    });
  });
}
```

```dart
// packages/rule_engine/test/models/rule_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Rule', () {
    test('accepts a null zone id meaning the whole jurisdiction', () {
      const r = Rule(
        id: 1,
        jurisdictionId: 7,
        zoneId: null,
        speciesId: 42,
        waterType: WaterType.salt,
        citation: kCitationMd580,
        citationLineageId: 'ae-md-580-2015',
        validFrom: '2015-11-03',
        validTo: null,
        minSizeMm: 450,
        measurementMethod: MeasurementMethod.totalLength,
        isProtected: false,
        closedSeasons: <ClosedSeason>[],
      );
      expect(r.zoneId, isNull);
      expect(r.minSizeMm, 450);
    });

    test('carries its closed seasons', () {
      expect(kRuleShariClosure.closedSeasons, hasLength(1));
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `dart test test/models/` in `packages/rule_engine/` → 19 failures (compile errors count as
failures). If any passes now, the test is wrong.

**Row 10 is not an `expect`.** "Does not compile" is asserted by the analyzer plus
`check_app_invariants.sh` check 4, not by the test runner. Write it as a comment in
`rule_test.dart` naming the gate, and make the gate run part of this task's done list.

## Implementation outline

1. Add `meta` to `packages/rule_engine/pubspec.yaml` `dependencies`. Nothing else. Confirm no
   `flutter:` key appeared.
2. `citation.dart` first — everything else references it. Four required `final` fields, `const`
   constructor, `==`, `hashCode`, `toString`. Dates are ISO-8601 `String`, matching `SPEC.md` §7.1's
   `TEXT` columns; parsing to `DateTime` belongs to whoever compares dates, and only T03 and T06 do.
3. The enums: `MeasurementMethod` (enhanced, with `code`, plus a static `fromCode` returning
   `MeasurementMethod?`), `TaxonGroup`, `WaterType`, `ZoneKind`, `Recurrence`, `LimitUnit`,
   `LimitPeriod`. Each member list is copied from its `CHECK` constraint in §7.1 and nowhere else.
4. `zone.dart`, `species.dart`, `closed_season.dart`, `landing.dart`, then `rule.dart` last because
   it depends on four of them. `Rule` and `Zone` get a hand-written `copyWith`; `Rule`'s uses a
   nullable-wrapper sentinel for `validTo` and `zoneId`, so `copyWith(validTo: null)` can mean "clear
   it" rather than "leave it". No other model needs one.
5. Export all seven from `lib/rule_engine.dart`. Add nothing else to the barrel.
6. `testing/models/fixtures.dart` — the `k`-prefixed constants the test tables above and every later
   task use. They are `const`. They live in `testing/`, never in `lib/` and never in a `_test.dart`
   file (`CONVENTIONS.md` §6).
7. Re-run. All 18 green.

**Naming trap:** `check_rule_engine.sh` check 4 greps for
`(String|_)[A-Za-z]*[Nn]ormali[sz]e[A-Za-z]*\(` outside `normalise.dart`. A helper called
`_normaliseDate(` in this package fails the gate. Call date helpers `dateOnly(` or `parseIsoDate(`.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 tests pass, and each failed first.
- [ ] Branch coverage on `lib/src/models/` is 100%.
- [ ] No `Citation?` anywhere in the package — `check_app_invariants.sh` check 4 clean.
- [ ] Every model has a `const` constructor and every field is `final`.
- [ ] `packages/rule_engine/pubspec.yaml` gained exactly one dependency, `meta`, and still declares
      no `flutter:` SDK dependency.
- [ ] Every enum member list is traceable to a `CHECK` constraint in `SPEC.md` §7.1 — `basin` and
      `both` included.
- [ ] `testing/models/fixtures.dart` exists, is `const` throughout, and is not named `*_test.dart`.
- [ ] Public API has doc comments; each model's comment names the `SPEC.md` §7.1 table it mirrors.

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
feat(rule_engine): add the immutable domain models for SPEC 7.1 rule resolution

Seven const value types mirroring the reference schema, so that resolution
and the content builder both read rows through the same code. Sizes are
integer millimetres end to end — a unit field would make 38 cm and 380 mm
two values that outcomeEquals reports as a legal conflict.

Citation has four required non-nullable fields and no factory, because
invariant 3 has to be structural rather than asserted. Rule carries a
citationLineageId that SPEC 7.1 has no column for; SPEC 7.3 collapses on it,
so the gap is named on the type the mapper has to fill rather than invented
in stage 2.

Task: E03/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
