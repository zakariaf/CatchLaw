# E08/T05 — S2, the static half

| | |
|---|---|
| **Epic** | E08 — Species: search, browse and the static detail |
| **Branch** | `epic/08-species` (shared) |
| **Commit** | `feat(species): build the static half of S2 with the species header and its art` |
| **Depends on** | T01 (`SpeciesSearchHit`, the reference repository), T03 (`SpeciesArt`, the Lonja components) |
| **Size** | M |
| **Spec** | `SPEC.md` §6 S2 (Elements, static half), §9.2 (Tier 2 names), §9.5 (gender), §7.1 `species_name` |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-typography` | Owns the header entirely: the ramp steps, the Arabic resolution, the mixed-script `Text.rich` shape, and the rule that italic is only the binomial |
| `lonja-icons-and-plates` | Owns the plate versus silhouette decision on a species account, the plate frame and number, and the provenance record |
| `lonja-lists-and-tables` | The `pair` column class for the two-column facts table shape E10 will extend, and the divider ladder between page sections |
| `widget-composition` | Widget classes not `_build` methods, the lean `build()`, and full-bleed background versus `SafeArea` content |
| `state-management-riverpod` | The detail view model is `.autoDispose.family` keyed by species id — a stable equatable key, disposed on unmount |
| `catchlaw-reference-database` | The names query is a third indexed statement inside `reference.db`; `idx_name_species(species_id, locale)` is its access path |
| `catchlaw-conventions-index` | Invariant 3 decides what this screen may show: nothing rule-derived, so nothing owes a citation yet |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S2 "Elements" | The full element list, and which of them belong to E09 and E10 rather than here |
| `SPEC.md` | §6 S2 "Empty state" | "no rule for this species here" plus a button to S18 — E10's, and named here so it is not built twice |
| `SPEC.md` | §7.1 `species_name`, `species`, `idx_name_species` | `locale`, `is_primary`, `region_hint`, `gender`; `silhouette_asset` non-null, `plate_asset` nullable |
| `SPEC.md` | §9.2 Tier 2 and the fallback chain | Names are bundled content; the chain never renders a raw key |
| `SPEC.md` | §9.5 "Gender" | `species_name.gender` is non-NULL in every gendered locale; names are complete phrases, never assembled |
| `SPEC.md` | §8, "Detailed plates (optional)" and the public-domain test | Why `plate_asset` can legitimately be null |
| `.claude/skills/lonja-typography/references/type-ramp.md` | The ramp table and "Worked content per step" | `display` 30 for the vernacular, `legalSmall` 14, `binomial` 15 italic; the measures |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Mixed-script rows", "Arabic resolution rules", "Line-height headroom" | `Text.rich` with one span per run; the 1.12 uplift; `binomial` is the only step that keeps the Latin face under `ar` |
| `.claude/skills/lonja-icons-and-plates/references/engraved-plates.md` | "Silhouette versus plate", "When a plate is REQUIRED", "Semantics and the caption" | Species account → plate; the frame and `PL. XVII · fig. 1`; the plate number sits inside `ExcludeSemantics` |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The ledger table — column classes", "The divider ladder" | The `pair` class and `structural` rule this screen's sections use |
| `Flutter-Skills: widget-composition/references/structural-layout.md` | "The window is edge-to-edge; the targets are inset" | Full-bleed background, `SafeArea` content, margins inside |
| `FLUTTER_GUIDE.md` | §1.2, §1.3 | The View allow-list; the ViewModel exposes an immutable snapshot |
| `FLUTTER_GUIDE.md` | §8.1 | The `BuildContext` scoping argument — decisive on a six-locale screen full of localised text |
| `epics/DECISIONS.md` | D-2, D-3, D-7 | Theme path; six locales; every word here comes from ARB or `content_string`, never from the engine |

## What this delivers

- `app/lib/domain/models/species_account.dart` — an immutable value: `speciesId`,
  `scientificName`, `taxonGroup`, `silhouetteAsset`, `plateAsset`, `familyName`,
  `primaryName` (`SpeciesName`), `otherNames` (`UnmodifiableListView<SpeciesName>`),
  `isProtectedAnywhere`. `SpeciesName` carries `locale`, `name`, `gender`, `regionHint`,
  `isPrimary`.
- `app/lib/data/repositories/species_account_repository.dart` (+ `_drift.dart`) —
  `Future<Result<SpeciesAccount>> accountFor(int speciesId, {required String locale})`.
- `app/lib/data/services/dao/species_account_dao.dart` — one statement over `species_name` filtered
  by `species_id`, served by `idx_name_species`, joined to `species` and `family`.
- `app/lib/ui/species/view_models/species_detail_view_model.dart` — an
  `AsyncNotifierProvider.autoDispose.family<…, SpeciesAccount, int>`.
- `app/lib/ui/species/widgets/species_detail_screen.dart` — S2's static half, with private
  `_SpeciesHeader`, `_OtherNamesBlock`, `_SpeciesArtPanel` and `_MeasurementSlot` widget classes.
- `app/lib/ui/core/ui/lonja_plate.dart` and `lonja_silhouette.dart` — the plate with its frame,
  inner hairline and figure number, and the silhouette; both painted from the const path table.
- `app/lib/ui/species/widgets/species_detail_placeholders.dart` — the two named, empty slots E09 and
  E10 fill, each documented with the epic that owns it.
- ARB keys in all six files: `speciesOtherNames`, `speciesScientificName`, `speciesFamilyLabel`,
  `speciesPlateSemanticLabel`.
- Tests: `app/test/ui/species/species_detail_screen_test.dart`,
  `app/test/data/repositories/species_account_repository_test.dart`.

## Why it is built this way

**The header is ordered by what Khalid actually reads.** §6 S2 states it: local name large,
other-locale names small, scientific name smallest. The intent is a demotion — a fisher in Ras Al
Khaimah does not read Latin binomials, and a screen that leads with *Epinephelus coioides* has
buried the only word he recognises. The ramp is used as published:

| Line | Step | Latin | `ar` |
|---|---|---|---|
| Local name | `display` | serif 30 w600 | Naskh 33.6, height 1.25, tracking 0 |
| Other-locale names | `legalSmall` | serif 14 w400, `ink-muted` | Naskh 15.7, height 1.65 |
| Scientific name | `binomial` | serif 15 w400 **italic**, `ink-faint` | Latin serif italic, unchanged |

`binomial` is nominally 15 and `legalSmall` is 14, so the *last* line is one logical pixel larger
than the one above it. That is a live disagreement between two skill reference files —
`type-ramp.md` sets 15, `row-and-table-anatomy.md` sets 12.5 for the same content in a row — and
`epic.md` risk 2 records it with the correction that would close it. The demotion the spec asks for
is carried here by italic, by w400 against w400 at a lighter tone, and by position. **Rejected:**
adding a seventeenth ramp step. `lonja-typography` rule 4 says a missing size is added to the ramp
*and to its reference file* in the same commit; that reference belongs to a skill, and
`CONVENTIONS.md` §4 forbids inventing a local convention when the rule lives elsewhere. A feature
epic does not edit a skill.

**The header is `Text.rich`, one span per script run.** `arabic-and-scripts.md` is explicit: the
species header is inherently bilingual — `هامور Hamour · Epinephelus coioides` — and three faces
meet in one line. Building it from one `Text` with a single style falls back the Arabic to a face
with no coverage. Each run carries its own ramp step, each is wrapped in a bidi isolate so the `·`
separators and the Latin binomial do not reorder around the Arabic, and vertical alignment is
`TextBaseline.alphabetic` rather than a `Padding` nudge, which drifts at every `textScaler` value.
`binomial` is the one step that keeps the Latin serif italic under `ar`, because there is no true
italic master in the Arabic stack and the synthetic oblique slants a cursive script into
unreadability.

**Other-locale names are shown with their region hint, and never assembled.** §7.1 gives
`species_name.region_hint` (`RAK`, `Rías Baixas`) and §9.5 says content strings are authored as
complete phrases and an adjective is never concatenated onto a name at runtime. So the block renders
`name` and, when present, `region_hint` in its own slot — not `'$name ($hint)'` built in Dart, which
would need a different word order in four of six locales.

**Nothing here is rule-derived, so nothing owes a citation.** Invariant 3 says every *result*
carries a required, non-nullable `Citation`. This screen shows the species' own attributes —
names, family, art — read from `species` and `species_name`, which carry no `citation_id` because
they are taxonomy, not law. The moment a rule row appears on this screen it brings its citation with
it, and that moment is E10. Building the static half with no citation slot is therefore not a gap
to be filled later; it is the correct shape, and the two named placeholder widgets make the seam
explicit so E10 extends rather than re-lays the screen.

**Plate when there is one, silhouette when there is not.** `engraved-plates.md` requires a full
plate on a species account: it is the drawing the identification rests on, framed and numbered
`PL. XVII · fig. 1`, with hatching and diagnostic marks. But §7.1 makes `plate_asset` nullable and
§8 is categorical — "any plate whose artist cannot be identified is dropped" — because plates are
the one asset class in a no-network app that can carry someone else's copyright. So the resolver
renders the plate when the asset exists and the silhouette when it does not, and a test pins the
fallback. `epic.md` risk 5 names where the missing builder assertion belongs.

**The plate number is inside `ExcludeSemantics`.** `PL. XVII · fig. 1` is a printed-document
affordance, not information a screen reader needs before the species name. The plate itself takes
one `semanticLabel` describing the drawing; the caption is read as ordinary text.

**Rejected: a hero transition from the row's silhouette to the detail's plate.**
`engraved-plates.md` forbids animating, parallaxing or hero-transitioning a plate — it is a printed
figure. It is also two *different drawings* generated from different authored files, so there is no
shared element to animate between.

**Rejected: building the measurement toggle now.** §6 S2 lists the ruler / type-length toggle, the
result banner, the findings list, the rule facts table, the citation row, *Add to today*, *Flag this
rule*, the amber expiry bar and the disclaimer. Every one of those is E09 or E10, and building a
disabled version of any of them now would ship a control that states nothing — which is worse than
an honest absence on a screen a fisher trusts.

## Tests first

Write every row before touching `species_detail_screen.dart`. Run them. **They must fail.**

| # | Test name | Case | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SpeciesAccountRepository.accountFor returns the primary name for the active locale` | locale `ar`, Hamour | `primaryName.name == 'هامور'`, `locale == 'ar'` | The header's first line is the whole screen's anchor |
| 2 | `SpeciesAccountRepository.accountFor returns every other-locale name` | Hamour with 6 names | `otherNames.length == 5` | §6 S2 requires them, and the count proves the active-locale name is not duplicated into the block |
| 3 | `SpeciesAccountRepository.accountFor orders other-locale names by locale, deterministically` | run twice | identical order | An unordered block reshuffles between opens and looks like a bug |
| 4 | `SpeciesAccountRepository.accountFor falls back to en when the active locale has no name` | locale `ca` | `primaryName.locale == 'en'` | §9.2's chain; a blank header on a legal surface is the failure it prevents |
| 5 | `SpeciesAccountRepository.accountFor falls back to the scientific name when no vernacular name exists` | no `species_name` rows | `primaryName.name == scientificName` | The last link — never blank, never a raw key |
| 6 | `SpeciesAccountRepository.accountFor carries the region hint when one is recorded` | `region_hint` = `Rías Baixas` | hint present on the name | §7.1's column exists so two Galician names for one clam can be told apart |
| 7 | `SpeciesAccountRepository.accountFor carries the gender for a gendered locale` | `es` name | `gender` non-null | §9.5: the build asserts non-NULL in every gendered locale, and ICU `select` templates read it |
| 8 | `SpeciesAccountDao.namesFor uses idx_name_species` | `EXPLAIN QUERY PLAN` | plan contains `idx_name_species` | This runs on every species open, on the path to the < 1.2 s target |
| 9 | `SpeciesDetailScreen sets the local name in the display step` | Hamour | style is `display` | The largest line, and the one the fisher reads |
| 10 | `SpeciesDetailScreen sets the other-locale names in the legalSmall step` | Hamour | style is `legalSmall` | The middle rank of §6 S2's ordering |
| 11 | `SpeciesDetailScreen sets the scientific name in the binomial step, italic` | Hamour | style is `binomial`, `FontStyle.italic` | `lonja-typography` rule 11: italic is the binomial and nothing else in the app |
| 12 | `SpeciesDetailScreen places the local name above the other-locale names and the binomial last` | Hamour | `dy` order: local < other < binomial | §6 S2's ordering, asserted by geometry rather than by style, so it survives risk 2's size collision |
| 13 | `ar - SpeciesDetailScreen renders the local name with zero letter spacing` | locale `ar` | `letterSpacing == 0` | Positive tracking severs the cursive joins and هامور becomes ه ا م و ر |
| 14 | `ar - SpeciesDetailScreen keeps the binomial in the Latin serif italic` | locale `ar` | face is the Latin serif | `arabic-and-scripts.md`: the only step that does not swap face under `ar` |
| 15 | `ar - SpeciesDetailScreen renders the header as one Text.rich with a span per script run` | locale `ar` | ≥ 2 spans, each with its own style | One `Text` with a single style falls the Arabic back to a face with no coverage |
| 16 | `SpeciesDetailScreen renders the region hint in its own slot` | `Rías Baixas` | hint text is a separate widget from the name | §9.5: never assembled in Dart, because the word order differs by locale |
| 17 | `SpeciesDetailScreen renders a plate when the species has a plate asset` | plate present | `LonjaPlate` | `engraved-plates.md`: a species account gets the drawing the identification rests on |
| 18 | `SpeciesDetailScreen renders a silhouette when the species has no plate asset` | `plateAsset` null | `LonjaSilhouette`, no throw | §8 drops any plate whose artist cannot be identified — `epic.md` risk 5, pinned |
| 19 | `SpeciesDetailScreen excludes the plate figure number from semantics` | plate present | `PL.` not in the semantics tree | It is a printed-document affordance, not what a screen reader needs before the name |
| 20 | `SpeciesDetailScreen labels the plate with a description of the drawing` | plate present | `semanticLabel` non-empty | `lonja-icons-and-plates` rule 6: an unlabelled lone glyph is announced as "image" at 05:40 |
| 21 | `SpeciesDetailScreen renders no verdict, no measurement and no rule facts` | any species | none of those widgets present | The static half is a boundary, not a stage of completion; a disabled control that states nothing is worse than an absence |
| 22 | `SpeciesDetailScreen renders no citation row` | any species | absent | Invariant 3 in the positive direction: nothing here is rule-derived, so nothing owes one — and E10 adds the surface and its citation together |
| 23 | `SpeciesDetailScreen renders the error state when the account read fails` | `AsyncError` | headline and diagnostic line | A corrupt asset DB is the only error this screen can have |
| 24 | `SpeciesDetailScreen renders a skeleton while the account loads` | `AsyncLoading` | skeleton, no spinner | No network, so no spinner |
| 25 | `SpeciesDetailScreen does not truncate the header at 200 percent text scale` | `textScaler` 2.0 | no `maxLines`, no overflow exception | `lonja-typography` rule 8 and §4.9: layouts survive 200% with no clipping |
| 26 | `SpeciesDetailScreen bounds the other-names block by the scaled reading measure` | `textScaler` 2.0 | width equals `LonjaMeasure.legal × scale` | Rule 7: a fixed 500 px box holds ~65 characters at 1.0 and ~32 at 2.0 |

```dart
// app/test/ui/species/species_detail_screen_test.dart
import 'package:catchlaw/ui/species/widgets/species_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';
import '../../../testing/models/k_species.dart';

void main() {
  testWidgets(
      'SpeciesDetailScreen places the local name above the other-locale names and the binomial last',
      (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(
      const SpeciesDetailScreen(speciesId: 1),
      overrides: [speciesDetailViewModelProvider(1).overrideWith(
        () => StubDetailViewModel(account: kAccountHamour),
      )],
    );
    await tester.pump();

    // SPEC §6 S2: local name large, other-locale names small, scientific name
    // smallest. Asserted by geometry, so it survives the ramp collision recorded
    // in epic.md risk 2.
    final local = tester.getTopLeft(find.byKey(const ValueKey('species_local_name'))).dy;
    final other = tester.getTopLeft(find.byKey(const ValueKey('species_other_names'))).dy;
    final binomial = tester.getTopLeft(find.byKey(const ValueKey('species_binomial'))).dy;
    expect(local, lessThan(other));
    expect(other, lessThan(binomial));
  });

  testWidgets('SpeciesDetailScreen renders no citation row', (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(
      const SpeciesDetailScreen(speciesId: 1),
      overrides: [speciesDetailViewModelProvider(1).overrideWith(
        () => StubDetailViewModel(account: kAccountHamour),
      )],
    );
    await tester.pump();

    // Invariant 3, in the positive direction: nothing on the static half is
    // rule-derived, so nothing owes a citation. E10 adds the surface and its
    // citation in one commit.
    expect(find.byType(CitationRow), findsNothing);
    expect(find.byType(VerdictPanel), findsNothing);
  });

  testWidgets('ar - SpeciesDetailScreen keeps the binomial in the Latin serif italic',
      (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(
      const SpeciesDetailScreen(speciesId: 1),
      locale: const Locale('ar'),
      overrides: [speciesDetailViewModelProvider(1).overrideWith(
        () => StubDetailViewModel(account: kAccountHamour),
      )],
    );
    await tester.pump();

    final style = tester
        .widget<Text>(find.byKey(const ValueKey('species_binomial')))
        .style!;
    expect(style.fontStyle, FontStyle.italic);
    expect(style.fontFamilyFallback, LonjaFaces.serif); // never the Naskh stack
  });

  // … one test per row in the table above, one behaviour each
}
```

**Run:** `cd app && flutter test test/ui/species/species_detail_screen_test.dart test/data/repositories/species_account_repository_test.dart`
→ 26 failures. If test 21 or 22 passes before the screen exists, the finder is matching a widget
that has not been written and the test is asserting nothing — make it assert the header is present
in the same test so it cannot pass vacuously.

## Implementation outline

1. `SpeciesName` and `SpeciesAccount` first, `const`, with value equality.
2. `SpeciesAccountDao.namesFor(int speciesId)` — one statement on `idx_name_species`. The repository
   picks the primary through §9.2's chain (active locale + `is_primary`, active locale, `en`,
   scientific) and puts every other row in `otherNames`, ordered by locale code so test 3 holds.
3. `_SpeciesHeader` as a private widget class: one `Text.rich`, one `TextSpan` per script run, each
   wrapped in a bidi isolate, `textBaseline: TextBaseline.alphabetic`. Keys on the three lines so
   test 12 can measure them.
4. `_OtherNamesBlock`: a `ConstrainedBox` at `LonjaMeasure.legal * MediaQuery.textScalerOf(context)
   .scale(1)`, no `maxLines`, no `overflow`.
5. `LonjaPlate` and `LonjaSilhouette` in `app/lib/ui/core/ui/`, painted from the const path table.
   The plate draws its frame, its 3 px inset inner hairline and its figure number; the number sits
   inside `ExcludeSemantics`. Stroke widths come from `LonjaIconTheme`, read at the widget and
   passed into the painter — never read inside `paint()`.
6. `SpeciesDetailScreen`: full-bleed background, `SafeArea` content, one exhaustive `switch` over
   the `AsyncValue`, sections separated by the `structural` rule from the divider ladder.
7. `species_detail_placeholders.dart`: two `const` widgets, `MeasurementSlot` and `VerdictSlot`,
   each rendering nothing and each carrying a `///` doc comment naming E09 and E10 respectively.
   They exist so the layout E10 extends is the layout that shipped, not one it has to rebuild.
8. Add four ARB keys to all six files.
9. Re-run the suite. All 26 green, T01–T04 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 26 tests pass, and each failed first.
- [ ] The header's three lines are in §6 S2's order, asserted by geometry.
- [ ] The header is one `Text.rich` with a span per script run, each bidi-isolated.
- [ ] `binomial` is the only italic style used in the changed files, and only for scientific names.
- [ ] Every `ar` style in the changed files carries `letterSpacing: 0`.
- [ ] No `maxLines`, `TextOverflow.ellipsis` or `FittedBox` on any serif step here.
- [ ] The plate renders when `plate_asset` is present and the silhouette when it is null, both
      asserted.
- [ ] No verdict, measurement, rule fact, citation row, tally action, flag action, expiry bar or
      disclaimer appears — every one of them is E09's or E10's, and tests 21 and 22 pin it.
- [ ] The two placeholder widgets are documented with the epic that fills them.
- [ ] Four ARB keys exist in all six locales (D-3).
- [ ] `check_app_invariants.sh` check 4 (a verdict surface with no citation) is clean, and it is
      clean because there is no verdict surface.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-icons-and-plates/scripts/check_lonja_icons.sh          app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh    app/lib
tools/gates/no_directional_geometry.sh                                      app/lib
# from the Flutter-Skills plugin, per CONVENTIONS.md §4:
#   widget-composition  scripts/check-widget-composition.sh  app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(species): build the static half of S2 with the species header and its art

The header is one Text.rich with a span per script run, each bidi-isolated and
each carrying its own ramp step, because a single Text with one style falls the
Arabic back to a face with no coverage and reorders the Latin binomial around
it. The ordering SPEC §6 S2 asks for — local name large, other-locale names
small, scientific name smallest — is asserted by geometry rather than by size,
because type-ramp.md sets binomial at 15 and legalSmall at 14 while
row-and-table-anatomy.md sets the same content at 12.5. The demotion is carried
by italic, tone and position, and epic.md risk 2 names the skill correction that
would close the collision properly.

Nothing on this screen is rule-derived, so nothing owes a citation. That is the
correct shape, not a gap: E10 adds every rule-derived surface together with its
citation, into two named placeholder slots this commit ships empty.

Task: E08/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
