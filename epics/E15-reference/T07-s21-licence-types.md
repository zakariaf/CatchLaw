# E15/T07 — S21, licence types

| | |
|---|---|
| **Epic** | E15 — The reference section |
| **Branch** | `epic/15-reference` (shared) |
| **Commit** | `feat(reference): add S21, licence types, backed by the licence_type table` |
| **Depends on** | T04 (`ReferenceScreenHeader`), T05 (`matchesFoldedQuery`) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.6 (licence types — "Backed by `licence_type`, not by a boolean"), §6 S21, §6's shared line for S18–S23, §7.1 (`licence_type`, `zone.water_type`, `jurisdiction.has_freshwater`/`has_saltwater`), §4.4 (fresh vs salt) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | The sliver-built list, the section device, the divider ladder and the four states |
| `lonja-forms-and-controls` | `LonjaSegmented` for the water-type filter; rule 8 — selection is fill and weight, never semantic colour |
| `lonja-typography` | The `microLabel` code rubric, the serif name, and the `legalSmall` description under a scaling reading measure |
| `catchlaw-verdict-contract` | A licence description states what an instrument records; "You need licence B" is second person plus a permission verb, and both are banned |
| `catchlaw-conventions-index` | Invariant 3 — `licence_type.citation_id` is `NOT NULL`; invariant 5 — an expired jurisdiction still lists its classes |
| `persistence-drift` | The scoped DAO, the zone-ancestry predicate and value-object mapping |
| `i18n-rtl-l10n` | Every licence name and description is tier-2 content resolved per locale |
| `widget-golden-and-a11y-testing` | `useDevice` first; the segmented control's `isSemantics(selected:)` |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.6 | "Licence types (S21) — which licence class covers this zone and water type, with its description. **Backed by `licence_type`, not by a boolean**" |
| `SPEC.md` | §6 S21 and the S18–S23 line | The shared contract for all six list screens |
| `SPEC.md` | §7.1 | `licence_type(jurisdiction_id, zone_id, water_type CHECK IN ('salt','fresh','both'), code, name_key, description_key, citation_id)`; `rule.licence_type_id` as the FK that proves the table is the authority; `zone.water_type`; `jurisdiction.has_freshwater` / `has_saltwater` |
| `SPEC.md` | §4.4 | "Fresh vs salt — where a jurisdiction splits them, the zone carries the water type. Freshwater zones never show marine rules" |
| `SPEC.md` | §6 S9 | The water-type toggle "where applicable" — the same condition this screen reads |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "Choosing a container", "The divider ladder" | Slivers for rows plus interleaved section labels; `LonjaSectionLabel` as the gazette device |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Empty" | The authored empty state's parts and copy rules |
| `.claude/skills/lonja-forms-and-controls/SKILL.md` | rules 1, 3, 8 | Ruled cells, `LonjaTargets` for every height, selection as fill and weight |
| `.claude/skills/lonja-typography/SKILL.md` | rules 2, 7, 8 | The description is legal prose: serif, a measure that scales with `textScaler`, and never truncated |
| `.claude/skills/catchlaw-verdict-contract/references/verdict-copy-rules.md` | "The grep lexicon", family B | "you must", "allowed to", "permitted to" — the words a licence description attracts |
| `FLUTTER_GUIDE.md` | Part 5.2 | The vertical slice |
| `epics/DECISIONS.md` | D-1, D-3 | Paths; the six locales |

## What this delivers

- `app/lib/data/daos/licence_type_dao.dart` —
  `LicenceTypeDao.watchLicenceTypes({jurisdictionId, zoneIdPath, waterType})`, matching
  `zone_id IS NULL OR zone_id IN (…ancestry)` and `water_type IN (:waterType, 'both')`, ordered
  `code ASC`.
- `app/lib/domain/models/licence_type_entry.dart` — `LicenceTypeEntry`: `code`, `nameKey`,
  `descriptionKey`, `waterType`, zone scope, non-nullable `Citation`.
- `app/lib/domain/models/water_type.dart` — `enum WaterType { salt, fresh, both }` if E11 did not
  already declare one. **If E11 declared it, use E11's and author nothing.**
- `app/lib/data/repositories/licence_type_repository.dart` + `_drift.dart` + a fake.
- `app/lib/ui/reference/licence_types_screen.dart` — `LicenceTypesScreen`.
- `app/lib/ui/reference/widgets/licence_type_block.dart` — `LicenceTypeBlock`: code rubric, serif
  name, `legalSmall` description under a scaling measure, citation.
- `app/lib/ui/reference/view_models/licence_types_viewmodel.dart`.
- ARB keys in all six files (D-3): `referenceLicencesTitle`, `referenceLicenceWaterSalt`,
  `referenceLicenceWaterFresh`, `referenceLicenceScopeJurisdiction`, `referenceLicenceScopeZone`,
  `referenceLicencesEmptyHeadline`, `referenceLicencesEmptyBody`.
- Tests: `app/test/data/licence_type_dao_test.dart`,
  `app/test/ui/reference/licence_types_screen_test.dart`.

## Why it is built this way

**A boolean cannot answer the question this screen asks.**
§4.6's acceptance condition is explicit: backed by `licence_type`, not by a boolean. "A licence is
required" tells a fisher nothing he can act on — Galicia's marisqueo a pé and marisqueo a flote are
different classes with different scopes, and Brazilian freshwater and marine amateur licences are
different instruments. §7.1 also puts `licence_type_id` on `rule`, which settles the direction: the
table is the authority and a rule points *into* it. **Rejected:** a `rule.licence_required` boolean
(it does not exist, and inventing one would collapse "which class" into "yes"); deriving the class
from `rule.licence_type_id` alone (a licence class with no rule pointing at it would vanish, and a
class exists whether or not this jurisdiction's transcribed rules happen to reference it).

**Water type is a filter, not a fact about the reader.**
`zone.water_type` is `salt`, `fresh` or `both`. When the active zone is `salt` or `fresh`, the screen
states it and offers no control — there is nothing to choose. When it is `both`, or when the
jurisdiction declares `has_freshwater = 1 AND has_saltwater = 1`, a two-cell `LonjaSegmented` chooses.
The query always matches `water_type IN (:selected, 'both')`, so a class that covers both water types
appears under either selection. **Rejected:** always showing the toggle, which asks a reader standing
on a reservoir whether he is at sea; and filtering in Dart after loading everything, which would let
a marine class render for a freshwater zone for one frame — §4.4 says freshwater zones never show
marine rules, and "for one frame" is still showing.

**The description is legal prose, so it obeys the legal-prose rules.**
`licence_type.description_key` resolves to a paragraph an authority wrote. `lonja-typography` rule 2
puts it in the serif, rule 7 caps it at `LonjaMeasure.legal * MediaQuery.textScalerOf(context).scale(1)`
so the line length stays constant in characters from scale 0.85 to 3.0, and rule 8 forbids `maxLines`,
`TextOverflow.ellipsis` and `FittedBox` on it. **Rejected:** a two-line clamp with a "more" affordance
— a truncated licence description is the half that says which zones it excludes.

**A block, not a row.**
A licence class is a code, a name, a paragraph and a citation. That does not fit the species-row or
log-row envelopes and it is not a grid, so `row-and-table-anatomy.md`'s container table sends it to
slivers with interleaved section labels: `LonjaSectionLabel` carrying the `code`, then the block. The
list is still built lazily — `check_lonja_lists.sh` check 1 fails an eager `ListView(` over a dynamic
list, and a jurisdiction may declare more classes than fit a screen.

**Search filters the localised name and description, through the shared function.**
`matchesFoldedQuery` from T05, applied to both the resolved name and the resolved description, with
the query folded once by `package:rule_engine`. No second fold enters `app/lib`.

## Tests first

Write every row before touching `licence_type_dao.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `LicenceTypeDao.watchLicenceTypes includes a class with a null zone_id` | jurisdiction-wide class | included | §7.1: NULL is the whole jurisdiction, and most licence classes are |
| 2 | `LicenceTypeDao.watchLicenceTypes includes a class on an ancestor of the active zone` | region class, subzone active | included | Zone ancestry, as in T04 and T05 |
| 3 | `LicenceTypeDao.watchLicenceTypes excludes a class on a sibling zone` | class on another bank | excluded | The other half of ancestry |
| 4 | `LicenceTypeDao.watchLicenceTypes excludes a salt class when fresh is selected` | `water_type = 'salt'`, fresh selected | excluded | §4.4: "freshwater zones never show marine rules" |
| 5 | `LicenceTypeDao.watchLicenceTypes includes a both class under either water type` | `water_type = 'both'` | included under salt and under fresh | The `IN (:selected, 'both')` predicate; omitting `'both'` hides the most common class |
| 6 | `LicenceTypeDao.watchLicenceTypes excludes another jurisdiction` | two jurisdictions | only the active one | The reference DB holds every jurisdiction |
| 7 | `LicenceTypeEntry cannot be constructed without a Citation` | analyzer | compile error | Invariant 3; `licence_type.citation_id` is `NOT NULL` |
| 8 | `LicenceTypesScreen renders the water-type control when the active zone is both` | zone `water_type = 'both'` | `LonjaSegmented` present | The condition §6 S9 calls "where applicable", read here |
| 9 | `LicenceTypesScreen renders no water-type control when the active zone is salt` | zone `water_type = 'salt'` | control absent, the water type stated | Asking a question with one answer wastes a target on a wet deck |
| 10 | `LicenceTypesScreen requeries when the water type is switched` | pick fresh | the fresh-only class appears, the salt-only one leaves | The filter must reach the query, not just the label |
| 11 | `LicenceTypesScreen resolves every licence name and description through content_string` | `gl` locale | the `gl` values, not the keys | The S18–S23 shared contract |
| 12 | `LicenceTypesScreen applies no maxLines and no ellipsis to a description` | long description at textScaler 2.0 | no `TextOverflow.ellipsis` | `lonja-typography` rule 8; the truncated half is the part naming the exclusions |
| 13 | `LicenceTypesScreen caps the description at the scaling reading measure` | textScaler 1.0 and 2.0 | width equals `LonjaMeasure.legal × scale` in both | Rule 7: a fixed box holds ~65 characters at 1.0 and ~32 at 2.0 |
| 14 | `LicenceTypesScreen contains no second person or permission verb in any locale` | every ARB value for this screen | none of family B | "You must hold licence B" is exactly what a licence screen attracts |
| 15 | `LicenceTypesScreen renders the not-recorded state when no class matches` | empty fixture | authored headline and body | Empty surface 6 of eight |
| 16 | `LicenceTypesScreen shows the ochre stale bar above a full list when the pack is expired` | expired jurisdiction | bar present and every block present | Invariant 5 |
| 17 | `glove - LicenceTypesScreen water-type cell measures 66 dp` | glove density | height ≥ 66 | `LonjaTargets.gloveControl`, clearing §4.9's 56 dp floor |

```dart
// app/test/data/licence_type_dao_test.dart
test('LicenceTypeDao.watchLicenceTypes includes a both class under either water type',
    () async {
  await seedReference(db, kLicenceBothWaterFixture);
  for (final water in const [WaterType.salt, WaterType.fresh]) {
    final classes = await dao
        .watchLicenceTypes(
          jurisdictionId: kJurisdictionGalicia,
          zoneIdPath: kZonePathCambados,
          waterType: water,
        )
        .first;
    expect(classes.map((c) => c.code), contains('MAR-PE'),
        reason: 'a both-water class must appear under ${water.name}');
  }
});
```

```dart
// app/test/ui/reference/licence_types_screen_test.dart
testWidgets('LicenceTypesScreen caps the description at the scaling reading measure',
    (tester) async {
  for (final scale in const [1.0, 2.0]) {
    tester.useDevice(Device.small);
    await tester.pumpApp(
      overrides: kGaliciaLicenceOverrides,
      textScaler: TextScaler.linear(scale),
    );
    final box = tester.widget<ConstrainedBox>(
      find.byKey(const ValueKey('licence_description_measure')),
    );
    expect(box.constraints.maxWidth,
        moreOrLessEquals(LonjaMeasure.legal * scale, epsilon: 0.5));
  }
});
```

**Run:** `cd app && flutter test test/data/licence_type_dao_test.dart
test/ui/reference/licence_types_screen_test.dart` → 17 failures. Test 9 is the one most likely to pass
early, because a screen that renders no control at all passes it — which is why test 8 sits beside it.

## Implementation outline

1. Reuse E11's `WaterType` if it exists; otherwise declare it in
   `app/lib/domain/models/water_type.dart`. Do not declare a second one.
2. Write `LicenceTypeEntry` with a required non-nullable `Citation`.
3. Write `LicenceTypeDao`: one scoped `customSelect` joining `licence_type` and `citation`, with the
   zone-ancestry `IN` clause and `water_type IN (:selected, 'both')`, ordered `code ASC`.
4. Write the view model: read the active zone from E11's provider, derive whether the water-type
   control applies (`zone.water_type == both`, or the jurisdiction declares both water types), hold
   the selection, and pass it into the query.
5. Write `LicenceTypeBlock`: `LonjaSectionLabel` with the code, serif name, the description inside a
   `ConstrainedBox` at `LonjaMeasure.legal * MediaQuery.textScalerOf(context).scale(1)` with no
   `maxLines`, then the citation in the mono `citation` step.
6. Write `LicenceTypesScreen`: header, search field through `matchesFoldedQuery`, the water-type
   `LonjaSegmented` when applicable, a `CustomScrollView` of blocks, and the four states.
7. Author this screen's empty-state copy (surface 6 of eight) inline; T09 consolidates it.
8. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 tests pass, and each failed first.
- [ ] No boolean anywhere in the diff stands in for a licence class.
- [ ] The water-type filter reaches the SQL predicate; no post-query filtering in Dart.
- [ ] The description carries no `maxLines`, no `TextOverflow` and no `FittedBox`, and its measure
      multiplies by the live text scale.
- [ ] `LicenceTypeEntry.citation` is non-nullable.
- [ ] Exactly one `WaterType` enum exists in `app/lib/`.
- [ ] `check_lonja_lists.sh app/lib`, `check_lonja_type.sh app/lib` and
      `check_lonja_controls.sh app/lib` are clean.
- [ ] `packages/rule_engine/` untouched (D-7).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh     app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
tools/gates/no_directional_geometry.sh                                       app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(reference): add S21, licence types, backed by the licence_type table

SPEC.md §4.6 makes the acceptance condition explicit: backed by licence_type,
not by a boolean. "A licence is required" is unactionable — Galicia's marisqueo
a pé and a flote are different classes with different scopes — and §7.1 settles
the direction by putting licence_type_id on rule, so the table is the authority
and a rule points into it.

Water type is a query predicate, not a post-load filter: water_type IN
(:selected, 'both'), so a both-water class appears under either selection and a
marine class never renders for a freshwater zone, not even for one frame (§4.4).
The two-cell control appears only where the zone or the jurisdiction actually
splits the two.

The description is legal prose and is treated as such: serif, a reading measure
that multiplies by the live text scale, and no maxLines — the truncated half of
a licence description is the part that names its exclusions.

Task: E15/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
