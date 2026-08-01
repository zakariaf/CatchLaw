# E15/T04 — S18, protected species

| | |
|---|---|
| **Epic** | E15 — The reference section |
| **Branch** | `epic/15-reference` (shared) |
| **Commit** | `feat(reference): add S18, the protected-species list, browsable without a result` |
| **Depends on** | T01 (`ReferenceScreenHeader`, the hub route) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.6 (protected species), §6 S18, §6's shared line for S18–S23, §7.1 (`rule.is_protected`, `species`, `species_name`, `citation`), §4.1 (unknown species routes to S18) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | The whole screen. Rule 11 fixes the species-row slot order and forbids inserting a slot; rule 9 makes status glyph plus word plus colour; the four states and the ochre bar |
| `lonja-icons-and-plates` | The engraved silhouette at 52 × 30, and the plate-versus-silhouette fallback E08 already established |
| `lonja-typography` | The row's Arabic/serif name step, the italic `binomial`, and the mono `citation` step the rule line carries |
| `lonja-forms-and-controls` | The list is searchable; the field never fights the reader's script and never gets a spinner |
| `catchlaw-verdict-contract` | Rule 1 — "Protected species — taking prohibited." is the wording; "Release" and "Throw it back" are the failures. Rule 5 — the citation is part of the statement |
| `catchlaw-conventions-index` | Invariants 3, 4 and 5, all three of which this screen exercises at once |
| `persistence-drift` | The DAO is single-table-ish, scoped, and returns value objects; the index behind the query is proven in a test |
| `i18n-rtl-l10n` | Directional geometry, and the `ar` lane where the mixed-script row is decided |
| `widget-golden-and-a11y-testing` | `useDevice` first; the `getSize` tap-target loop; the empty and stale lanes |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.6 | "Protected species (S18) — full list with silhouettes, browsable independently" |
| `SPEC.md` | §6 S18–S23 | The shared contract: searchable list backed by its table, jurisdiction and content version in the header, every label through `content_string`, "not recorded for this jurisdiction" as the empty state |
| `SPEC.md` | §4.1 | The unknown-species case routes here — "No rule recorded for this species here. This does not mean it is legal." plus in-app navigation to S18. E10 owns that link; this task owns its destination |
| `SPEC.md` | §7.1 | `rule.is_protected`, `rule.zone_id` nullable meaning whole-jurisdiction, `rule.citation_id NOT NULL`, `species.silhouette_asset NOT NULL`, `species_name(locale, name, search_norm, is_primary)` |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rules 1, 6, 7, 8, 9, 11, 12 | Whole-row target; authored empty state; four states with `stale` orthogonal; a row states and never instructs; glyph + word + colour; **fixed slot order, never insert**; glove raises without re-laying out |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The species row — slot table" | The six slots in order, their type roles and colours; `LonjaSectionLabel` as the group device |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Empty", "Stale" | The empty-state parts; the ochre bar's geometry and the "row marker" it suggests |
| `.claude/skills/catchlaw-verdict-contract/references/verdict-copy-rules.md` | "Per-state wording" | "Protected species — taking prohibited." — no measurement slot, because a measurement implies a threshold |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariant 4's table | Oxblood carries two different states, so the glyph and the words must do the distinguishing |
| `.claude/skills/persistence-drift/references/schema-and-daos.md` | "The index & query-plan strategy" | Leading equality column, trailing sort; prove it with `EXPLAIN QUERY PLAN` |
| `FLUTTER_GUIDE.md` | Part 5.2, 5.3 | The vertical slice; `List.==` is identity, so keep the list query narrow |
| `epics/DECISIONS.md` | D-1, D-3, D-7 | Paths; six locales; the engine holds no sentence |

## What this delivers

- `app/lib/data/daos/protected_species_dao.dart` — `ProtectedSpeciesDao.watchProtected({jurisdictionId,
  zoneIdPath, locale, foldedQuery})`. Joins `rule` (`is_protected = 1`) → `species` → `species_name`
  → `citation`, scoped to the jurisdiction and to `zone_id IS NULL OR zone_id IN (…ancestry)`.
- `app/lib/domain/models/protected_species_entry.dart` — `ProtectedSpeciesEntry`: species id, local
  name, binomial, `silhouetteAsset`, `plateAsset`, zone scope, and a **non-nullable** `Citation`.
- `app/lib/data/repositories/protected_species_repository.dart` +
  `protected_species_repository_drift.dart` + `app/testing/fakes/fake_protected_species_repository.dart`.
- `app/lib/ui/reference/protected_species_screen.dart` — `ProtectedSpeciesScreen`.
- `app/lib/ui/reference/view_models/protected_species_viewmodel.dart`.
- ARB keys in all six files (D-3): `referenceProtectedTitle`, `referenceProtectedTakingProhibited`,
  `referenceProtectedScopeJurisdiction`, `referenceProtectedScopeZone`,
  `referenceProtectedEmptyHeadline`, `referenceProtectedEmptyBody`.
- Tests: `app/test/data/protected_species_dao_test.dart`,
  `app/test/ui/reference/protected_species_screen_test.dart`.

## Why it is built this way

**Browsable independently is the requirement, not a nicety.**
§4.6 says the list is "browsable independently" and §4.1 routes the unknown-species case here. A
fisher who has just been told "no rule recorded for this species here — this does not mean it is
legal" needs somewhere to go, and the answer is the list of things that are certainly prohibited. So
this screen takes no species argument, no measurement and no verdict: jurisdiction and zone, and
nothing else.

**The citation rides in the rule-line slot, because rule 11 forbids inserting one.**
Invariant 3 requires every result to carry its citation, and `rule.citation_id` is `NOT NULL` in
§7.1, so the data is there. But `lonja-lists-and-tables` rule 11 fixes the species-row slots at
silhouette → name → binomial → rule line → end slot → chevron, and says a screen "may OMIT a trailing
slot; it may never reorder or insert". Adding a citation line would be inserting one. So the rule
line carries both facts in one string —
`Taking prohibited · Orde 27/07/2012, Art. 12` — assembled in `app/lib/ui/` from an ARB template with
the instrument and article as placeholders. **Rejected:** a seventh slot (breaks the row contract
everywhere else in the app); a citation revealed only on tap (invariant 3 says every result *carries*
it, and the row is the result).

**Zone scope is a section head, not a row slot.**
Some protected rules are jurisdiction-wide (`zone_id IS NULL`) and some are a single bank or reserve.
That distinction has to be visible, and again it cannot be a new slot. `LonjaSectionLabel` groups the
list: one section for the jurisdiction-wide rules, one per zone that adds any. Sections are the
gazette device the skill already provides and they cost no row geometry.

**The end slot is spent, so staleness is carried by the bar alone — and that is stated, not hidden.**
Every row on this screen is `PROTECTED`, so the `LonjaPill` end slot is fully occupied.
`the-four-states.md` suggests a per-row ochre `STALE DATA` pill for affected rows; here there is
nowhere to put it, and an ochre tint with no glyph and no word would be colour as the only signal —
invariant 4. **Decision:** on S18, staleness is carried by the ochre `LonjaStaleBar` above the list,
which has glyph, word and hue, and by nothing per-row. **The cost, stated:** if a jurisdiction ever
mixes fresh and expired protection rules in one list, this screen says the *list* has stale data
without saying *which rows*. That is a real loss of precision and it is preferred to weakening
invariant 4. Invariant 5 is untouched: every row still renders, and nothing is disabled.

**The search filter folds through the engine, like everything else in this epic.**
The field filters on `species_name.search_norm`, folded by the same exported function from
`package:rule_engine` that T02 uses and that E04 used to write the column. No second fold enters
`app/lib`. **Rejected:** filtering the loaded list in Dart with `contains()` on the display name,
which would work in English and fail on `هامور` typed against a body that writes `الهامور` — the exact
defect §9.4 exists for.

**One `.watch()` stream, scoped, and deliberately narrow.**
`FLUTTER_GUIDE.md` §5.3: `List.==` is identity, so every drift re-query rebuilds every list consumer.
The query is scoped to (jurisdiction, zone path, locale, folded query) so a write anywhere else in
`user.db` cannot re-run it — and in fact this reads only `reference.db`, which never changes at run
time.

## Tests first

Write every row before touching `protected_species_dao.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ProtectedSpeciesDao.watchProtected returns only rules with is_protected = 1` | fixture with 3 protected, 5 sized rules | 3 entries | The screen's whole predicate. A size rule leaking in states a prohibition that does not exist |
| 2 | `ProtectedSpeciesDao.watchProtected includes a jurisdiction-wide rule with a null zone_id` | `zone_id IS NULL` | included | §7.1: NULL means the whole jurisdiction. Excluding it hides the broadest prohibitions |
| 3 | `ProtectedSpeciesDao.watchProtected includes a rule on an ancestor of the active zone` | subzone active, rule on the region | included | Zone ancestry, per §7.3's resolution shape. A bank sits inside a region that also protects |
| 4 | `ProtectedSpeciesDao.watchProtected excludes a rule on a sibling zone` | rule on another bank | excluded | The other half of ancestry: a Cambados-only protection is not a Rías Baixas-wide one |
| 5 | `ProtectedSpeciesDao.watchProtected excludes another jurisdiction` | two jurisdictions | only the active one | The reference DB holds every jurisdiction |
| 6 | `ProtectedSpeciesDao.watchProtected returns the primary name for the active locale` | `gl` and `es` names | the `gl` `is_primary` row | A species with three vernacular names must show one, and the same one every time |
| 7 | `ProtectedSpeciesDao.watchProtected filters on search_norm when a query is folded` | query `ameixa` against `Ameixa babosa` | 1 entry | The Latin branch of §9.4 reaching this screen |
| 8 | `ProtectedSpeciesDao.watchProtected filters هامور against a search_norm written as الهامور` | Arabic fixture | 1 entry | The Arabic branch, on a screen that is not S13. The fold has exactly one home |
| 9 | `ProtectedSpeciesDao.watchProtected returns an expired rule` | `valid_to` in the past | included | Invariant 5. A protection that lapsed on paper is still the last verified wording |
| 10 | `ProtectedSpeciesEntry cannot be constructed without a Citation` | analyzer | compile error | Invariant 3, enforced by the type rather than by review |
| 11 | `ProtectedSpeciesScreen renders the taking-prohibited wording and its instrument in the rule line` | one entry | both substrings in one row line | The slot-11 decision above, pinned so nobody "tidies" it into a seventh slot |
| 12 | `ProtectedSpeciesScreen renders a PROTECTED pill with a glyph and a word` | one entry | glyph and text present | Invariant 4 — oxblood also means below-minimum, so hue distinguishes nothing here |
| 13 | `ProtectedSpeciesScreen groups zone-scoped rules under a section label` | one wide, one zone rule | two `LonjaSectionLabel`s | Scope must be visible without a new row slot |
| 14 | `ProtectedSpeciesScreen shows the ochre stale bar above a full list when the pack is expired` | expired jurisdiction | bar present **and** all rows present | Invariant 5's exact shape: the bar composes with data, it never replaces it |
| 15 | `ProtectedSpeciesScreen renders the not-recorded state when no protected rule exists` | empty fixture | authored headline and body | Empty surface 3 of eight. A blank frame reads as a crash |
| 16 | `ProtectedSpeciesScreen contains no imperative in any row line` | every ARB value for this screen | no `release`, `return`, `keep`, `throw` | Rule 8 and `catchlaw-verdict-contract` rule 1, asserted over ARB in all six locales |
| 17 | `glove - ProtectedSpeciesScreen row measures 76 dp` | glove density | height ≥ 76 | §4.9's 56 dp floor, cleared by the Lonja row height |
| 18 | `ProtectedSpeciesDao.watchProtected uses idx_rule_lookup rather than scanning rule` | `EXPLAIN QUERY PLAN` | plan names the index | §7.1 ships `idx_rule_lookup`; a plan change is a silent regression |

```dart
// app/test/data/protected_species_dao_test.dart
import 'package:catchlaw/data/daos/protected_species_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/models/reference_fixtures.dart';

void main() {
  late ReferenceDatabase db;
  late ProtectedSpeciesDao dao;

  setUp(() async {
    db = ReferenceDatabase(NativeDatabase.memory());   // catchlaw-db-ok
    await seedReference(db, kGaliciaProtectedFixture);
    dao = ProtectedSpeciesDao(db);
  });
  tearDown(() => db.close());

  test('ProtectedSpeciesDao.watchProtected includes a rule on an ancestor '
      'of the active zone', () async {
    final entries = await dao
        .watchProtected(
          jurisdictionId: kJurisdictionGalicia,
          zoneIdPath: kZonePathCambados,   // [Rias Baixas, Banco de Cambados]
          locale: 'gl',
        )
        .first;
    expect(entries.map((e) => e.binomial), contains('Venerupis corrugata'));
  });

  test('ProtectedSpeciesDao.watchProtected returns an expired rule', () async {
    await seedReference(db, kExpiredProtectionFixture);   // valid_to in the past
    final entries = await dao
        .watchProtected(
          jurisdictionId: kJurisdictionGalicia,
          zoneIdPath: kZonePathCambados,
          locale: 'gl',
        )
        .first;
    expect(entries, isNotEmpty,
        reason: 'invariant 5: an expired ruleset is still evaluated and still shown');
  });

  // … one test per row of the table above, one behaviour each.
}
```

```dart
// app/test/ui/reference/protected_species_screen_test.dart
testWidgets('ProtectedSpeciesScreen shows the ochre stale bar above a full list '
    'when the pack is expired', (tester) async {
  tester.useDevice(Device.small);
  await tester.pumpApp(overrides: kExpiredGaliciaOverrides);
  expect(find.byType(LonjaStaleBar), findsOneWidget);
  expect(find.byType(LonjaSpeciesRow), findsNWidgets(3));   // composes, never replaces
});
```

**Run:** `cd app && flutter test test/data/protected_species_dao_test.dart
test/ui/reference/protected_species_screen_test.dart` → 18 failures. Test 10 is a compile-time
assertion: it fails by not compiling, which is the point.

## Implementation outline

1. Write `ProtectedSpeciesEntry` with a **required, non-nullable** `Citation` and a const
   constructor.
2. Write `ProtectedSpeciesDao`. One `customSelect` joining `rule`, `species`, `species_name`,
   `citation`, with `rule.is_protected = 1`, jurisdiction equality, the zone-ancestry `IN` clause and
   the optional `search_norm` prefix predicate. Map to `ProtectedSpeciesEntry` inside the DAO.
3. Fold the filter text with `package:rule_engine` in the view model, before it reaches the DAO.
   Add no fold in `app/lib`.
4. Write the repository, its drift implementation and the fake.
5. Write `ProtectedSpeciesScreen`: `ReferenceScreenHeader`, `LonjaSearchField`, `LonjaStaleBar` when
   the jurisdiction is expired, then a `CustomScrollView` of `LonjaSectionLabel` + `LonjaSpeciesRow`
   slivers — a builder, never a `Column` in a scroll view.
6. Author this screen's empty-state copy (surface 3 of eight) inline for now. T09 consolidates it.
7. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 tests pass, and each failed first.
- [ ] `ProtectedSpeciesEntry.citation` is non-nullable with no default and no `Citation.unknown()`.
- [ ] The row uses `LonjaSpeciesRow` with its published slot order; no seventh slot exists.
- [ ] The screen renders the ochre bar **and** every row when the jurisdiction is expired; no branch
      returns early on expiry.
- [ ] `grep -rniE '\b(keep|return|release|discard|throw)\b' app/lib/ui/reference/` returns nothing.
- [ ] The filter's only normalisation is the call into `package:rule_engine`.
- [ ] `check_lonja_lists.sh app/lib` is clean with no `// lonja-list-ok` hatch.
- [ ] `packages/rule_engine/` untouched (D-7).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-icons-and-plates/scripts/check_lonja_icons.sh          app/lib
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
feat(reference): add S18, the protected-species list, browsable without a result

SPEC.md §4.1 routes the unknown-species case here: a fisher told "no rule
recorded — this does not mean it is legal" needs the list of things that are
certainly prohibited, and it must be reachable without a species, a measurement
or a verdict.

The citation rides in the rule line rather than in a slot of its own, because
lonja-lists-and-tables rule 11 fixes the species-row slot order and forbids
inserting one. Zone scope is a section label for the same reason.

Every row is PROTECTED, so the pill slot is spent and per-row staleness has
nowhere to go. The ochre bar carries it instead — glyph, word and hue — and the
loss of per-row precision is accepted rather than shipping an ochre tint with no
glyph and no word, which would be colour as the only signal.

Task: E15/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
