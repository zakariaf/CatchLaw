# E11/T08 — Water type belongs to the zone

| | |
|---|---|
| **Epic** | E11 — Zones and point-in-polygon |
| **Branch** | `epic/11-zones` (shared) |
| **Commit** | `feat(zones): derive the water type from the active zone so fresh water never shows marine rules` |
| **Depends on** | T04 (the toggle exists), T07 (`EvaluationScope` and `WatchEvaluationScope`) |
| **Size** | S |
| **Spec** | `SPEC.md` §4.4 ("Fresh vs salt": where a jurisdiction splits them, the zone carries the water type; freshwater zones never show marine rules), §6 S9 (the water-type toggle), §7.1 (`zone.water_type`, `rule.water_type`, `licence_type.water_type`, `jurisdiction.has_freshwater`/`has_saltwater`), §7.2 (`user_profile`, `app_meta`, and what a `catch` row does and does not carry), §7.3 (water_type is a selection predicate) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | `references/resolution-algorithm.md`'s request table: `waterType` is a **parameter** of `resolve()`, so getting it wrong is not a bug the engine can catch. Rule 12's argument about method mismatch is the same argument one column over |
| `catchlaw-reference-database` | Rule 8 and the two-database contract: a catch row denormalises what it was judged under, which is why the water type has to travel on a value rather than be re-derived later |
| `state-management-riverpod` | Rule 4, derive-don't-store: the water type is derived from the zone row and from one `app_meta` key, never mirrored into a third place |
| `error-handling-typed-results` | Rules 3 and 4: the string → enum mapping is exhaustive and an unknown value is a typed failure rather than a silent default |
| `lonja-lists-and-tables` | `references/row-and-table-anatomy.md`'s settings row: the toggle is a value slot on a ruled row, not a floating control |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.4, "Fresh vs salt" | "Where a jurisdiction splits them, the zone carries the water type. Freshwater zones never show marine rules" |
| `SPEC.md` | §6 S9 | "water-type toggle where applicable" |
| `SPEC.md` | §7.1, `zone.water_type` | `CHECK (water_type IN ('salt','fresh','both'))` — the closed set the mapper switches over |
| `SPEC.md` | §7.1, `rule.water_type` and `licence_type.water_type` | The same three values on the rows that get selected, and the reason the request must carry a concrete one |
| `SPEC.md` | §7.1, `jurisdiction.has_freshwater` / `has_saltwater` | The two columns that decide whether the toggle exists at all |
| `SPEC.md` | §7.2, `user_profile` | It carries `active_jurisdiction` and `active_zone_code` and **no water-type column** — the gap this task works around |
| `SPEC.md` | §7.2, `app_meta` | The key/value table in `user.db` that needs no migration |
| `SPEC.md` | §7.2, `catch` | The columns a catch row actually has, and the closing paragraph on why they are literals |
| `SPEC.md` | §7.3 step 1 | Water type is part of the selection predicate, alongside jurisdiction and species |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "The request", "Worked traces" | `waterType` as a request field; "Jurumirim is `.fresh`" |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | rule 12 | A measurement is compared only against its own method — the same shape of silent cross-comparison this task prevents one column over |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | rule 8 | A catch row denormalises what it was judged under, with the reason |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "The `catches` row: what is copied and why" | The Sha'ri counter-example: a live join would retroactively declare a lawful catch an offence |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The settings row" | 58/68 dp, serif key, `LonjaSegmented` in the value slot |
| `.claude/skills/error-handling-typed-results/references/result-failure-spine.md` | "Failure taxonomy per boundary" | Stable code plus typed params for the unknown-value case |
| `epics/E11-zones/epic.md` | Risks 8 and 9 | The two recorded schema gaps this task works within rather than around |

## What this delivers

- `app/lib/data/model/water_type_mapper.dart` — `Result<WaterType, DataFailure> waterTypeFrom(String)`,
  an exhaustive `switch` over §7.1's `'salt'`, `'fresh'` and `'both'`, with an unknown value returning
  `DataConstraintViolated('water_type')` rather than defaulting.
- `app/lib/data/repositories/settings_repository.dart` gains
  `Stream<WaterType?> watchActiveWaterType()` and
  `Future<Result<void, DataFailure>> setActiveWaterType(WaterType)`, both over E05/T08's `AppMetaDao`
  under the key `active_water_type`; mirrored in the drift implementation and the fake.
- Change to `app/lib/domain/use_cases/watch_evaluation_scope.dart` — the water type on the scope is the
  active zone's `water_type` when that is `salt` or `fresh`, and the stored `app_meta` choice when it is
  `both`.
- Change to `app/lib/ui/zones/view_models/zone_picker_view_model.dart` — `confirmSelection` refuses a
  `both` zone until the toggle has been answered, and the screen states why.
- Change to `app/lib/ui/zones/widgets/water_type_toggle.dart` — it now writes, through
  `SettingsRepository`, and it is still rendered only when the jurisdiction carries both
  `has_freshwater` and `has_saltwater`.
- Change to `app/lib/ui/result/view_models/` — the display model carries `waterType` from the scope, so
  whatever writes a catch copies a literal instead of re-deriving one.
- `app/lib/l10n/app_*.arb` × 6 — `zoneWaterChoiceRequired`.
- `app/test/data/model/water_type_mapper_test.dart`,
  `app/test/domain/use_cases/water_type_scope_test.dart`,
  `app/test/ui/zones/water_type_toggle_test.dart` (extended from T04).

## Why it is built this way

**The zone is the source, because §4.4 says so and because nothing else is.** "Where a jurisdiction
splits them, the zone carries the water type." So the water type is read off `zone.water_type` and is
not a user preference, not a per-species attribute and not an inference from the species' habitat. A
tucunaré caught in Represa de Jurumirim is fresh because the *zone* is fresh, and it would still be
fresh if somebody landed one in a tidal creek.

**A `both` zone is the one case that needs an answer, and it gets asked rather than guessed.**
`resolve()` takes a scalar `waterType` (`resolution-algorithm.md`'s request table), so a zone whose
`water_type` is `both` cannot build a request on its own. Defaulting to `salt` is the failure §4.4's row
names in its own words: a Brazilian reservoir zone defaulted to salt shows marine rules in fresh water.
So `confirmSelection` refuses a `both` zone until the toggle is answered, and the screen states the fact
(`zoneWaterChoiceRequired`). One extra tap, in the one case where the instrument itself is ambiguous
about which body of water the fisher is standing in.

**The choice lives in `app_meta`, and that is second-best on purpose.** §7.2 gives `user_profile`
`active_jurisdiction` and `active_zone_code` and no third field, and adding one is a forward-only
`user.db` migration with a fixture test — E05/T05's ritual, owned by E05, not by a UI epic that happened
to notice. `app_meta` is a key/value table that already exists in `user.db`, already has a DAO
(E05/T08), and needs no schema change. The epic's Risks section records the gap and names what would
resolve it: a `DECISIONS.md` entry adding `user_profile.active_water_type`. Until then this is where the
value is, written down once so nobody has to find it by grep.

**The stored choice is ignored the moment it stops applying.** Switch from a `both` zone to a salt-only
zone and the scope reads `salt` from the zone row, regardless of a stored `fresh`. The `app_meta` key is
an answer to a question about one zone, not a global mode — that is what `derive-don't-store` buys, and
test 8 is the assertion that keeps it true.

**The mapper is exhaustive and does not default.** §7.1's `CHECK` constraint means the three values are
the only ones the database can hold, so a fourth is a corrupted file or a schema that moved under us.
`error-handling-typed-results` rule 3's shape applies: a typed `DataConstraintViolated('water_type')`
with a stable code, not `?? WaterType.salt`. A silent default here reproduces the exact failure §4.4
forbids, and it does it invisibly.

**`catchlaw-rule-engine/references/resolution-algorithm.md` shows a `.brackish` variant that §7.1 cannot
store.** Its request table lists `.marine` / `.brackish` / `.fresh`; §7.1's `CHECK` allows
`'salt' | 'fresh' | 'both'`. The schema is authoritative for what can exist, so the mapper covers three
database values, and if E03's enum carries a fourth variant it is unreachable from any bundled row. The
`switch` in the mapper is exhaustive over the enum, so the day a value is added the build breaks here
rather than silently selecting nothing. This divergence is recorded in the epic's Risks; no task quietly
renames an engine enum from a UI epic.

**The water type travels on the value, because a catch has to be able to restate itself.**
`catchlaw-reference-database` rule 8 and the two-database contract's Sha'ri counter-example make the
principle concrete: a live join against a pack that has been replaced retroactively rewrites a
three-year-old record. §4.4 asks the catch to carry the water type it was evaluated under, and §7.2's
`catch` table has no such column — so this task puts `waterType` on the `EvaluationScope` and carries it
through the result display, which is where E13's writer will pick it up as a literal. Adding the column
is E13's, with its own migration and its own fixture test. **This task does not add a column to
`user.db`**, and the epic's Risks section says so with the resolution named.

**The toggle's presence rule is unchanged from T04.** It renders when and only when the jurisdiction row
carries `has_freshwater = 1` and `has_saltwater = 1`. What changes here is that it now writes. Keeping
the presence rule in one place — the jurisdiction row — means a Gulf jurisdiction never grows the
control and a Brazilian one never loses it.

**Rejected: a global fresh/salt switch in Settings.** It is one control for a fact that varies per
zone, so it would be wrong for at least one saved zone at all times, and §4.4 puts the water type on the
zone in as many words. S14's list in §6 does not include it either.

**Rejected: inferring the water type from the species.** `species.taxon_group` says nothing about where
a fish was caught, several species are catadromous, and the rules are written per water body rather than
per animal. Inferring would also put a second, untested copy of a legal distinction in the app.

**Rejected: passing `both` through to `resolve()` as a wildcard.** It would match salt rules and fresh
rules at once and hand the fisher two contradictory findings under a D4 ambiguity dialog that is meant
for two instruments disagreeing, not for the app failing to ask a question. `catchlaw-rule-engine` rule
6 exists for genuine ambiguity in the sources; this is ambiguity in our input.

## Tests first

Write every row before touching `water_type_mapper.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `waterTypeFrom maps salt to the marine variant` | `'salt'` | `Ok(WaterType.salt)` | §7.1's first permitted value |
| 2 | `waterTypeFrom maps fresh to the fresh variant` | `'fresh'` | `Ok(WaterType.fresh)` | The second, and the one §4.4's guarantee is about |
| 3 | `waterTypeFrom fails with DataConstraintViolated for an unrecognised value` | `'brackish'` | `Err(DataConstraintViolated('water_type'))` | A silent `?? salt` default reproduces exactly the failure §4.4 forbids, invisibly |
| 4 | `EvaluationScope carries fresh for a freshwater zone` | Jurumirim, `water_type: 'fresh'` | `WaterType.fresh` | The derivation, at its source |
| 5 | `EvaluationScope carries salt for a saltwater zone` | Rías Baixas, `'salt'` | `WaterType.salt` | The control case |
| 6 | `EvaluationScope carries the stored choice for a both zone` | `'both'` zone, `app_meta` holds `fresh` | `WaterType.fresh` | The one case the zone cannot answer alone |
| 7 | `ZonePickerNotifier.confirmSelection refuses a both zone until the water type is answered` | `'both'` zone, no stored choice | no `setActiveZone` call, `zoneWaterChoiceRequired` shown | Defaulting to salt shows marine rules in a reservoir — §4.4's row, in its own words |
| 8 | `EvaluationScope ignores a stored fresh choice in a salt-only zone` | stored `fresh`, zone `'salt'` | `WaterType.salt` | The `app_meta` key answers a question about one zone, not a global mode |
| 9 | `a freshwater zone produces no finding sourced from a salt rule` | fresh zone, species with both a salt and a fresh rule | only the fresh rule's finding | §4.4's headline guarantee, end to end |
| 10 | `a saltwater zone produces no finding sourced from a fresh rule` | the mirror | only the salt rule's finding | The guarantee is symmetric; a one-sided filter passes test 9 |
| 11 | `WaterTypeToggle writes the choice through SettingsRepository` | tap fresh | one `setActiveWaterType(WaterType.fresh)` | The toggle existed in T04 and did nothing; this is the wiring |
| 12 | `changing the water type re-emits the evaluation scope once` | toggle fresh → salt | exactly one new scope | Two watches would fire twice and evaluate against a half-updated scope |
| 13 | `WaterTypeToggle is absent when the jurisdiction has one water type` | `has_freshwater = 0` | not rendered | Unchanged from T04, re-asserted because this task touches the widget |
| 14 | `the result display carries the water type it was evaluated under` | fresh zone, verdict rendered | the display model's `waterType` is `fresh` | §4.4 asks the catch to carry it; §7.2 has no column, so the value is what E13 will copy |
| 15 | `ar - WaterTypeToggle renders both labels from AppLocalizations` | locale `ar` | both Arabic strings, no Latin literal | D-3, and a segmented control is the easiest place to leave a literal |

```dart
// app/test/domain/use_cases/water_type_scope_test.dart
void main() {
  test('EvaluationScope ignores a stored fresh choice in a salt-only zone', () async {
    final settings = FakeSettingsRepository(
      profile: kProfileRiasBaixas,          // zone.water_type == 'salt'
      appMeta: {'active_water_type': 'fresh'},
    );

    final scope = await WatchEvaluationScope(
      settings: settings,
      reference: FakeReferenceRepository(kReferenceGalicia),
    )().first;

    expect(scope.waterType, WaterType.salt,
        reason: 'the app_meta key answers a question about a both-zone, not a global mode');
  });

  test('a freshwater zone produces no finding sourced from a salt rule', () async {
    final findings = await evaluateInFixture(
      zone: kZoneJurumirim,                 // water_type: 'fresh'
      species: kSpeciesTucunare,
      rules: [kRuleTucunareFresh, kRuleTucunareSalt],
    );

    expect(findings.map((f) => f.ruleId), <int>[kRuleTucunareFresh.id],
        reason: 'SPEC 4.4: freshwater zones never show marine rules');
  });
}
```

```dart
// app/test/data/model/water_type_mapper_test.dart
void main() {
  test('waterTypeFrom fails with DataConstraintViolated for an unrecognised value', () {
    final result = waterTypeFrom('brackish');

    switch (result) {
      case Ok(:final value):
        fail('an unrecognised water_type must not resolve to $value — a silent default '
            'reproduces exactly the failure SPEC 4.4 forbids, invisibly');
      case Err(:final failure):
        expect(failure, isA<DataConstraintViolated>());
        expect(failure.code, 'data.constraint_violated');
    }
  });
}
```

**Run:** `cd app && flutter test test/data/model/ test/domain/use_cases/ test/ui/zones/` → 15 new
failures, every earlier test still green. If any new one passes now, the test is wrong.

## Implementation outline

1. `water_type_mapper.dart`: one function, one `switch` over the three string literals. This one **does**
   carry a `default:` arm returning `Err(DataConstraintViolated('water_type'))`, and that is not a
   violation of `error-handling-typed-results` rule 4 — `String` is not a sealed type and has no
   exhaustiveness to defeat; the arm exists because a fourth value means the file is corrupt. Beside it,
   the reverse direction is an exhaustive `switch` over the engine's `WaterType` with **no** `default:`,
   so a new enum variant is a compile error here rather than a silent miss.
2. `settings_repository.dart` + the drift implementation + the fake: `watchActiveWaterType` reads
   `app_meta` under `active_water_type` and maps it; `setActiveWaterType` writes it in one transaction.
3. `watch_evaluation_scope.dart`: after resolving the zone row, `switch` on its `water_type` —
   `salt` and `fresh` resolve directly, `both` reads `watchActiveWaterType()` and yields nothing until
   it has an answer.
4. `zone_picker_view_model.dart`: `confirmSelection` checks the `both` case first and sets the
   `zoneWaterChoiceRequired` arm on the state instead of writing.
5. `water_type_toggle.dart`: the `onChanged` handler is a `void` intent method that owns its own
   `unawaited(...).catchError(...)`; it reads the current value from `watchActiveWaterType()` rather
   than holding it locally.
6. Carry `waterType` from `EvaluationScope` onto E10's display model — one field, no derivation.
7. Add `zoneWaterChoiceRequired` to all six ARB files and run E06's completeness check.
8. Re-run the whole app suite and the engine suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 15 tests pass, and each failed first.
- [ ] `waterTypeFrom` has no fallback value and no `?? WaterType.salt` anywhere in `app/lib`.
- [ ] The reverse `switch` over the engine's `WaterType` has no `default:` arm.
- [ ] A `both` zone cannot be confirmed without an answer, and no code path builds an
      `EvaluationRequest` with a guessed water type.
- [ ] The stored `app_meta` choice never overrides a zone that states its own water type.
- [ ] `packages/rule_engine/` is unchanged; no engine enum is renamed from this epic.
- [ ] `user.db`'s schema is unchanged — no column added, no `schemaVersion` bump (the gap and its
      resolution are recorded in the epic's Risks).
- [ ] `waterType` reaches the result display as one field carried from the scope, not re-derived.
- [ ] `zoneWaterChoiceRequired` exists in all six locales (D-3) and states a fact rather than an
      instruction.
- [ ] `check_app_invariants.sh app/lib` and `check_reference_db.sh app/lib` are clean.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
cd packages/rule_engine && dart test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh    app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh     app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(zones): derive the water type from the active zone so fresh water never shows marine rules

SPEC 4.4 puts the water type on the zone: "where a jurisdiction splits them,
the zone carries the water type. Freshwater zones never show marine rules."
So EvaluationScope reads zone.water_type and nothing else — not a settings
switch, not the species' habitat, not an inference.

A zone whose water_type is 'both' is the one case the zone cannot answer,
and it gets asked rather than guessed: confirmSelection refuses until the
toggle is answered, and the screen states why. Defaulting to salt is the
failure SPEC 4.4 names in its own words — a Brazilian reservoir showing
marine rules. The answer lives in user.db's app_meta under
active_water_type, deliberately second-best: SPEC 7.2 gives user_profile no
water column and adding one is a forward-only migration owned by E05, not by
a UI epic that noticed the gap. The epic's Risks record it and name the
resolution. A stored choice is ignored the moment the active zone states its
own water type.

The string-to-enum mapping is exhaustive and never defaults: SPEC 7.1's
CHECK means three values are the only ones the file can hold, so a fourth is
a corrupt database and returns a typed DataConstraintViolated rather than
silently selecting the wrong body of water.

Task: E11/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
