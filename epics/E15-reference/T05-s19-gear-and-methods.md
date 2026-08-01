# E15/T05 — S19, gear and methods

| | |
|---|---|
| **Epic** | E15 — The reference section |
| **Branch** | `epic/15-reference` (shared) |
| **Commit** | `feat(reference): add S19, gear and methods, with every gear name resolved through content_string` |
| **Depends on** | T04 (`ReferenceScreenHeader` is in place; the list envelope and empty-state pattern are established) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.6 (gear and methods), §6 S19, §6's shared line for S18–S23, §7.1 (`gear_rule`), §9.2 tier 2, §9.5 (complete phrases, never assembled) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | The log-row envelope this screen borrows, the ledger column classes it deliberately does not use, the divider ladder and the four states |
| `lonja-typography` | The serif headline / sans detail / mono citation split inside one row; rule 10 — no `.toUpperCase()` on a gear name |
| `lonja-forms-and-controls` | The search field, and rule 7 — the field never rewrites what the reader typed |
| `catchlaw-verdict-contract` | `NOT ALLOWED` is a state; "Do not use", "Avoid" and "Stop using" are the failures. Rule 5 — the citation is part of the statement |
| `catchlaw-conventions-index` | Invariant 3 (`gear_rule.citation_id` is `NOT NULL`, so there is no excuse) and invariant 4 |
| `persistence-drift` | DAO shape, scoping and value-object mapping |
| `i18n-rtl-l10n` | Every gear name is tier-2 content resolved per locale; bidi isolation of `mesh ≥ 50 mm` inside Arabic prose |
| `widget-golden-and-a11y-testing` | The `ar` and `gl` lanes, where a localised gear name is either right or obviously wrong |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.6 | "Gear and methods (S19) — banned gear, banned methods, mesh sizes, hook restrictions — **gear names localised**" |
| `SPEC.md` | §6 S18–S23 | The shared contract for all six list screens |
| `SPEC.md` | §7.1 | `gear_rule(jurisdiction_id, zone_id, species_id, gear_code, gear_name_key, is_allowed, constraint_key, citation_id)`; `species_id` NULL means all species; `constraint_key` is the `'mesh ≥ 50 mm'` slot |
| `SPEC.md` | §9.2 | Tier 2 names gear names and constraints explicitly; and the sourcing rule — lift the wording from the instrument itself |
| `SPEC.md` | §9.5 | "Content strings are otherwise authored as complete phrases, never assembled from fragments, and an adjective is never concatenated onto a name at runtime" |
| `SPEC.md` | §8 | The builder asserts every `*_key` — `gear_rule.gear_name_key` named specifically — resolves in `content_string` for every shipped locale |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The log row", "The ledger table — column classes", "Choosing a container" | The 22 × 22 glyph / serif 16 headline / sans 11.5 detail / `LonjaPill` end-slot envelope; the four column classes; "a wider-than-screen ledger scrolls" |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Empty" | The parts of an authored empty state and its copy rules |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rules 4, 8, 9 | Tabular end-aligned numerics; a row states and never instructs; glyph + word + colour |
| `.claude/skills/catchlaw-verdict-contract/references/verdict-copy-rules.md` | "The grep lexicon", families A and E | The banned imperatives; softened absence |
| `.claude/skills/lonja-typography/references/type-ramp.md` | `title`, `legal`, `datum`, `citation` | The steps a gear row and its section rubric use |
| `FLUTTER_GUIDE.md` | Part 5.2 | The vertical slice |
| `epics/DECISIONS.md` | D-1, D-3 | Paths; the six locales |

## What this delivers

- `app/lib/data/daos/gear_rule_dao.dart` — `GearRuleDao.watchGearRules({jurisdictionId, zoneIdPath})`,
  scoped to the jurisdiction and to `zone_id IS NULL OR zone_id IN (…ancestry)`, ordered
  `is_allowed ASC, gear_code ASC` so prohibitions come first and the order is stable.
- `app/lib/domain/models/gear_rule_entry.dart` — `GearRuleEntry`: `gearCode`, `gearNameKey`,
  `isAllowed`, `constraintKey`, `speciesId`, zone scope, and a non-nullable `Citation`.
- `app/lib/data/repositories/gear_rule_repository.dart` + `_drift.dart` + a fake.
- `app/lib/ui/reference/gear_and_methods_screen.dart` — `GearAndMethodsScreen`.
- `app/lib/ui/reference/widgets/gear_rule_row.dart` — `GearRuleRow`, on the log-row envelope.
- `app/lib/ui/reference/reference_label_filter.dart` — `bool matchesFoldedQuery(String label, String
  foldedQuery)`. **The shared label filter for every screen whose searchable text is a
  `content_string` value**; T07 and T08 consume it.
- `app/lib/ui/reference/view_models/gear_and_methods_viewmodel.dart`.
- ARB keys in all six files (D-3): `referenceGearTitle`, `referenceGearSectionNotAllowed`,
  `referenceGearSectionConditions`, `referenceGearAppliesToAllSpecies`,
  `referenceGearAppliesToSpecies`, `referenceGearUnlistedFootnote`,
  `referenceGearEmptyHeadline`, `referenceGearEmptyBody`.
- Tests: `app/test/data/gear_rule_dao_test.dart`,
  `app/test/ui/reference/gear_and_methods_screen_test.dart`,
  `app/test/ui/reference/reference_label_filter_test.dart`.

## Why it is built this way

**Rows, not a ledger table, because the columns will not fit at 320 dp.**
The natural ledger shape is gear | applies to | condition | citation, four columns of prose.
`row-and-table-anatomy.md` is clear that a ledger wider than the screen **scrolls** — it never wraps a
cell and never shrinks the type — and a horizontally scrolling primary screen on a wet deck is a
screen half of whose content is invisible. So S19 uses the **log-row envelope** the same file
documents: a 22 × 22 leading glyph, a serif 16 headline (the localised gear name), a sans 11.5 detail
line, and a `LonjaPill` end slot. **Rejected:** a four-column `Table` inside a horizontal scroller;
`DataTable` in any form (rule 3). The ledger table is used in T06, where the columns really are
narrow numerics.

**What the screen lists, and the footnote that stops the omission being read as a ban.**
Two sections: everything with `is_allowed = 0`, then everything with `is_allowed = 1` **and** a
`constraint_key`. Gear that is allowed with no recorded condition is not listed, because an
exhaustive list of permitted gear is not what §4.6 asks for and would be enormous. But silence about
a gear must not read as prohibition — the mirror image of §4.1's "no rule recorded does not mean it
is legal". So the screen carries a permanent footnote stating, as a fact, that it lists recorded
prohibitions and recorded conditions and that gear absent from it has neither recorded against it in
this jurisdiction. **Rejected:** listing every permitted gear (unbounded, and content the instruments
do not enumerate); listing nothing and letting the reader infer (the failure this footnote exists to
prevent).

**`constraint_key` is one authored phrase, resolved whole.**
`mesh ≥ 50 mm` arrives from `content_string` as a complete string, in the reader's locale, exactly as
§9.5 requires. **Rejected:** a numeric `mesh_mm` column formatted at run time — it does not exist in
§7.1, it would put the comparison operator in Dart, and §9.5 forbids assembling a phrase from
fragments precisely because the operator, the unit and the noun all inflect differently across the six
locales. The consequence is that a mesh size is *prose*, not a numeric column, so rule 4's tabular
end-alignment does not apply here — that rule binds comparable figures in a column, and there is no
such column on this screen.

**The label filter folds both sides, and it is one function used by three screens.**
`species_name` has a `search_norm` column, so T04 filters in SQL. `content_string` has no such column
(§7.1), so a gear name cannot be prefix-matched in SQL without a fold the database does not carry.
`matchesFoldedQuery` therefore folds the **candidate label** with the same imported function from
`package:rule_engine` and compares it against the already-folded query, in Dart, over a list of tens
of rows. This is not a second fold: it is the one function applied to both sides. **Rejected:**
`label.toLowerCase().contains(query)`, which cannot match `هامور` against `الهامور` and would be the
epic's only place where the §9.4 contract does not hold. **Named for later:** if a jurisdiction ever
ships enough gear rules for an in-memory filter to matter, the fix is a `search_norm` column on
`content_string` in the content builder, not a fold in `app/lib`.

**Species-scoped gear rules are qualified in the detail line.**
`gear_rule.species_id` is nullable and NULL means all species. A rule that binds one species says so
in the detail line, resolved through `species_name` in the active locale. The log-row detail line is a
compound by design — `row-and-table-anatomy.md` shows
`Ras Al Khaimah · 04:55 — now · 7 fish · 41 kg` — so this needs no new slot, unlike the species row in
T04.

## Tests first

Write every row before touching `gear_rule_dao.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `GearRuleDao.watchGearRules orders prohibitions before conditions` | mixed `is_allowed` | `is_allowed = 0` rows first | The screen's information order; a stable sort also stops rows swapping between runs |
| 2 | `GearRuleDao.watchGearRules includes a rule with a null zone_id` | jurisdiction-wide rule | included | §7.1: NULL is the whole jurisdiction |
| 3 | `GearRuleDao.watchGearRules includes a rule on an ancestor of the active zone` | region rule, subzone active | included | Zone ancestry, as in T04 |
| 4 | `GearRuleDao.watchGearRules excludes another jurisdiction` | two jurisdictions | only the active one | The reference DB holds every jurisdiction |
| 5 | `GearRuleEntry cannot be constructed without a Citation` | analyzer | compile error | Invariant 3; `gear_rule.citation_id` is `NOT NULL`, so there is no excuse for a nullable field |
| 6 | `GearAndMethodsScreen resolves every gear name through content_string` | `gl` locale | the `gl` value, not the key | §4.6's "gear names localised" is the acceptance condition for this screen |
| 7 | `ar - GearAndMethodsScreen resolves every gear name through content_string` | `ar` locale | the `ar` value | The locale where a leaked `*_key` is least recoverable by guessing |
| 8 | `GearAndMethodsScreen renders no raw content_string key` | every locale | no rendered text matches `^[a-z_.]+$` and equals a known key | The failure mode of a missing tier-2 string, caught in the app as well as in the builder |
| 9 | `GearAndMethodsScreen renders the constraint phrase whole` | `constraint_key` = mesh phrase | the resolved value, unmodified | §9.5. Any splitting or reassembly in Dart shows up here |
| 10 | `GearAndMethodsScreen qualifies a species-scoped rule with the species name` | `species_id` set | species name in the detail line | A gear rule that binds one species and reads as universal is a wrong prohibition |
| 11 | `GearAndMethodsScreen renders the unlisted-gear footnote` | any non-empty list | footnote present | The omission-is-not-a-ban decision above, pinned |
| 12 | `GearAndMethodsScreen renders a NOT ALLOWED pill with a glyph and a word` | one prohibition | glyph and text present | Invariant 4 |
| 13 | `GearAndMethodsScreen contains no imperative in any row or section label` | every ARB value for this screen, six locales | none of families A or B | `catchlaw-verdict-contract` rules 1 and 2 |
| 14 | `GearAndMethodsScreen renders the not-recorded state when no gear rule exists` | empty fixture | authored headline and body | Empty surface 4 of eight |
| 15 | `matchesFoldedQuery matches هامور against a label written الهامور` | label and query | `true` | The §9.4 contract holding on a screen whose searchable text has no `search_norm` column |
| 16 | `matchesFoldedQuery matches ria against a label written ría` | `gl` label | `true` | The Latin branch, for Galician, Catalan, Spanish and Portuguese labels |
| 17 | `matchesFoldedQuery returns true for an empty query` | `''` | `true` | The unfiltered list is the default view; an empty query must not empty the screen |
| 18 | `GearAndMethodsScreen shows the ochre stale bar above a full list when the pack is expired` | expired jurisdiction | bar present and all rows present | Invariant 5 |

```dart
// app/test/ui/reference/reference_label_filter_test.dart
import 'package:catchlaw/ui/reference/reference_label_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart';   // the one fold, both sides

void main() {
  test('matchesFoldedQuery matches هامور against a label written الهامور', () {
    expect(
      matchesFoldedQuery('الهامور', normaliseArabic('هامور')),
      isTrue,
    );
  });

  test('matchesFoldedQuery returns true for an empty query', () {
    expect(matchesFoldedQuery('nasa de nécora', ''), isTrue);
  });
}
```

```dart
// app/test/ui/reference/gear_and_methods_screen_test.dart
testWidgets('GearAndMethodsScreen renders the constraint phrase whole', (tester) async {
  tester.useDevice(Device.small);
  await tester.pumpApp(overrides: kGaliciaGearOverrides, locale: const Locale('gl'));
  // SPEC.md §9.5: authored as a complete phrase, never assembled from fragments.
  expect(find.text(kGearConstraintPhraseGl), findsOneWidget);
});
```

**Run:** `cd app && flutter test test/data/gear_rule_dao_test.dart test/ui/reference/` → 18 failures.
Test 17 is the one most likely to pass early — a stub returning `true` unconditionally would pass it
and fail 15 and 16, which is why all three exist.

## Implementation outline

1. Write `GearRuleEntry` with a required non-nullable `Citation`.
2. Write `GearRuleDao`: one scoped `customSelect` joining `gear_rule`, `citation` and — when
   `species_id` is non-null — `species_name` in the active locale. Order
   `is_allowed ASC, gear_code ASC`.
3. Write `matchesFoldedQuery` in `reference_label_filter.dart`: fold the candidate with the imported
   function, return `true` on an empty query, otherwise substring-match the folded label against the
   folded query. Document that both sides use the same import.
4. Write `GearRuleRow` on the log-row envelope: leading glyph, serif headline (localised gear name),
   sans detail line (`<zone scope> · <constraint> · <instrument> <article>`), `LonjaPill` end slot.
5. Write `GearAndMethodsScreen`: header, search field, two `LonjaSectionLabel` sections, the footnote,
   and the four states. Builder-constructed slivers, never a `Column` in a scroll view.
6. Add the eight ARB keys with constraint-carrying `@description`s, mirror into all six locales,
   `flutter gen-l10n`.
7. Author this screen's empty-state copy (surface 4 of eight) inline; T09 consolidates it.
8. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 tests pass, and each failed first.
- [ ] Every gear name and every constraint on screen came from `content_string`; no `*_key` string
      reaches a `Text` in any of the six locales.
- [ ] No constraint phrase is split, joined, or has a unit appended in Dart (§9.5).
- [ ] `matchesFoldedQuery` is the only label filter in `app/lib/ui/reference/`, and its only
      normalisation is the imported one.
- [ ] The unlisted-gear footnote renders whenever the list is non-empty.
- [ ] `GearRuleEntry.citation` is non-nullable.
- [ ] `check_lonja_lists.sh app/lib` and `check_verdict_contract.sh app/lib` are clean.
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
feat(reference): add S19, gear and methods, with every gear name resolved through content_string

Banned gear, banned methods and the conditions attached to permitted gear, per
jurisdiction and per zone ancestry, on the log-row envelope rather than a
four-column ledger — gear | applies to | condition | citation does not fit 320 dp
and a horizontally scrolling primary screen hides half its content on a wet deck.

The screen lists recorded prohibitions and recorded conditions, so it carries a
permanent footnote stating that gear absent from it has neither recorded against
it here. Silence about a gear must not read as a ban, which is SPEC.md §4.1's
rule pointed the other way.

Mesh sizes and hook restrictions arrive from content_string as complete phrases
and are rendered whole. §9.5 forbids assembling one from fragments because the
operator, the unit and the noun inflect differently across the six locales.

Label search folds both the query and the candidate with the one function from
packages/rule_engine, because content_string carries no search_norm column.

Task: E15/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
