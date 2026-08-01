# E08/T04 — S6 — browse by shape

| | |
|---|---|
| **Epic** | E08 — Species: search, browse and the static detail |
| **Branch** | `epic/08-species` (shared) |
| **Commit** | `feat(species): build S6 as a silhouette grid grouped by localised family name` |
| **Depends on** | T01 (`SpeciesSearchHit` and the reference repository), T03 (`SpeciesArt`, the Lonja components) |
| **Size** | M |
| **Spec** | `SPEC.md` §6 S6, §4.3 "Silhouette browse" and "Entry points", §7.1 `family`, §9.2 (Tier 2) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-icons-and-plates` | Owns the silhouette: the 140 × 64 grid, the stroke that tracks the theme and never the size, the binomial asset key, and the sunlight stroke this screen's legibility claim rests on |
| `lonja-lists-and-tables` | `LonjaSectionLabel` is the gazette device that replaces every `ListView` header tile and every `Card` title; the divider ladder the family headings use |
| `widget-composition` | `references/structural-layout.md` owns the grid: computed cell sizing, the cross/main-axis trap, and the rule against asserting a minimum tile size |
| `lonja-typography` | The family heading is a ramp step; §9.2's family name is *content*, so rule 10 forbids `.toUpperCase()` on it |
| `catchlaw-reference-database` | The family and species reads are two more indexed statements inside `reference.db`, opened read-only |
| `persistence-drift` | `idx_species_family` is the access pattern; the query plan is proved in a test |
| `catchlaw-conventions-index` | Routing: `family.name_key` → `content_string` is E06's resolver, not a second one authored here |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S6 | The two elements: the grid grouped by family with localised names, and *Identify this fish* in the app bar |
| `SPEC.md` | §4.3 "Silhouette browse" row | "Grid of black-on-white outlines grouped by family, **family names in the active locale**. Legible at arm's length in sunlight" |
| `SPEC.md` | §4.3 "Entry points" row | S6 is the third of S7's three entry points |
| `SPEC.md` | §7.1 `family` and `species` | `family.name_key`, `species.family_id`, `idx_species_family`, `silhouette_asset TEXT NOT NULL` |
| `SPEC.md` | §9.2 Tier 2 and the fallback chain | Family names are bundled content in `content_string`, and the chain is requested locale → jurisdiction default → `en` → scientific name |
| `SPEC.md` | §9.1 `gl` row | Why a Galician family name is not padding: the Xunta publishes in Galician |
| `SPEC.md` | §13 "Low-end devices" | "No image caching beyond the visible grid; SVGs rasterised at display size and cached by key" |
| `.claude/skills/lonja-icons-and-plates/references/engraved-plates.md` | "Silhouette versus plate", "Plate anatomy and ink weights" | 140 × 64, outline plus the eye, ≤ 8 subpaths; outline 1.60 on paper and 2.10 in sunlight |
| `.claude/skills/lonja-icons-and-plates/references/icon-system.md` | "Why a painted path table beat the alternatives", "RTL mirroring" | The rejected options and why; a fish never mirrors |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The divider ladder", "Choosing a container" | `LonjaSectionLabel`; `CustomScrollView` + slivers for rows plus interleaved section labels |
| `Flutter-Skills: widget-composition/references/structural-layout.md` | "Computed cell sizing", "The GridView axis trap" | `(viewport − chrome − gaps) / count`; never assert a minimum tile size; `crossAxisSpacing` is the gap between columns |
| `.claude/skills/lonja-typography/references/type-ramp.md` | The ramp table | `microLabel` for the gazette rubric, `legalSmall` for the tile caption |
| `FLUTTER_GUIDE.md` | §1.2, §8.1 | The View allow-list; private widget classes, not helper methods |
| `epics/DECISIONS.md` | D-2, D-3 | Theme at `app/lib/theme/`; the six locales, `ca` not `ur` and not `fr` |

## What this delivers

- `app/lib/domain/models/family_group.dart` — an immutable value: `familyId`, `scientificFamily`,
  `localisedFamilyName`, `UnmodifiableListView<SpeciesTile>`; and `SpeciesTile` with `speciesId`,
  `silhouetteAsset`, `plateAsset`, `displayName`, `scientificName`, `isProtected`.
- `app/lib/data/repositories/species_browse_repository.dart` (+ `_drift.dart`) —
  `Future<Result<List<FamilyGroup>>> browseByFamily({required String locale})`.
- `app/lib/data/services/dao/species_browse_dao.dart` — one statement over `species` joined to
  `family`, ordered by family then by the display name, served by `idx_species_family`.
- `app/lib/ui/species/view_models/species_browse_view_model.dart` — an
  `AsyncNotifierProvider.autoDispose` exposing `List<FamilyGroup>`.
- `app/lib/ui/species/widgets/species_browse_screen.dart` — S6, with private `_FamilySliver`,
  `_SilhouetteTile` and `_BrowseEmptyState` widget classes in the same file.
- `app/lib/ui/core/ui/lonja_section_label.dart` — the gazette device: an uppercase tracked
  `microLabel` label followed by a flex-filling 1 px rule, taking its text **already cased** from
  the resolver.
- ARB keys in all six files: `browseByShapeTitle`, `browseNoSpeciesHeadline`,
  `browseNoSpeciesBody`.
- Tests: `app/test/ui/species/species_browse_screen_test.dart`,
  `app/test/data/repositories/species_browse_repository_test.dart`.

## Why it is built this way

**The family name is localised, and that is the point of the screen.** §4.3 states it in bold and
§9.1 gives the reason: the Xunta publishes its size tables *in Galician*, and a Spanish-only — or
worse, Latin-only — app presents a Galician legal text in translation to a Galician-speaking
mariscadora. `family.name_key` resolves through E06's `content_string` resolver with §9.2's full
fallback chain (requested locale → jurisdiction `default_locale` → `en` → scientific name), so a
missing key degrades to the binomial rather than to a raw key or a blank heading. That resolver is
**not** re-authored here; `catchlaw-conventions-index` rule 10 forbids forking a rule into a second
place, and §9.2's chain is one rule.

**No `.toUpperCase()` on the heading.** `LonjaSectionLabel` is a tracked uppercase device, but
`lonja-typography` rule 10 bans casing a content string in a widget: it is a no-op on Arabic,
a Turkish-dotted-i hazard on Latin, and it shouts a name that the reference is supposed to quote.
The family name is Tier-2 **content**, so it arrives cased as authored, and the label's rubric
styling comes from the ramp. Under `ar` the tracked eyebrow has no Arabic form at all — 
`arabic-and-scripts.md` replaces tracking with weight, colour and the hairline rule, and letter
spacing on Arabic is always exactly zero because positive tracking severs the cursive joins.

**Silhouettes, not plates, on this grid.** `engraved-plates.md`'s required-art table gives
"Zone browse list | any | silhouette". A silhouette claims *"this is roughly the shape you have"*;
a plate claims *"these are the characters that identify this specimen"* and carries the legal
weight. S6 is a shape-recognition surface — the user does not yet know what the fish is — so the
weaker claim is the correct one, and a plate here would spend the plates' credibility on a browse
grid. The protected marker still appears, as a `LonjaPill` on the tile, because a fisher browsing
shapes should see that a shape is protected before he taps.

**Legible at arm's length in sunlight, stated as three testable facts.** §4.3's acceptance
condition is a sentence, so it is discharged as:

1. The silhouette painter reads `LonjaIconTheme.of(context).plateOutline` — 1.60 on paper and night,
   **2.10 in sunlight** — and never a literal. A hardcoded 1.45 freezes the paper theme and the
   glyph vanishes on a wet screen at noon.
2. The tile's drawn silhouette width at the tightest device preset is asserted with `getSize`,
   computed rather than hardcoded, so the assertion moves with the layout instead of pinning it.
3. Sunlight deletes every grey: the tile ground is `sun-paper` `#FFFFFF`, the outline is `sun-ink`
   `#000000`, and the dotted rules become solid. That is a theme fact, and the sunlight golden lane
   in T08 is where it is seen.

**Computed cell sizing, never a constant.** `structural-layout.md` gives both halves: a tile
dimension is `(viewport − chrome − gaps) / count` computed at layout time, and you must **never**
assert a minimum tile size — a floor fires exactly where large text needs the room most, at 200%
`textScaler`, and clips the caption it was meant to protect. So the delegate is
`SliverGridDelegateWithMaxCrossAxisExtent`, which adapts the column count to the width, and the real
constraint asserted in T08 is that the caption fits at every text scale.

**The axis trap, named because it is silent.** In a vertical grid `crossAxisSpacing` is the gap
between *columns* and `mainAxisSpacing` is the gap between *rows*. Getting them backwards looks
almost right and only shows once the design uses unequal gutters. Both come from the Lonja 4-pt
spine in `app/lib/theme/`, never from a literal — `check_lonja_tokens.sh` check 5 fails a numeric
literal inside `EdgeInsets` outside `lib/theme/`.

**Rejected: `SvgPicture.asset` for the silhouette.** `icon-system.md` rejects it for UI line art:
stroke attributes are baked into the file, so three themes × the asset set means a per-theme asset
directory, and it adds a runtime parse plus an asset-load frame before first paint. §13 also bans
image caching beyond the visible grid. The const path table plus a `CustomPainter` resolves the
stroke at paint time with nothing to load — which matters most in a 100% offline app on 2 GB of RAM.

**Rejected: `GridView` for the whole screen.** The screen is rows *plus interleaved section
labels*, which `row-and-table-anatomy.md`'s container table routes to `CustomScrollView` and
slivers, not to one list with type switches. Each family is a `SliverToBoxAdapter` heading followed
by a `SliverGrid`.

**Rejected: mirroring the silhouette in RTL.** `icon-system.md` sets `mirrorInRtl: false` for
`fish` and every species silhouette, and `engraved-plates.md` says a specimen faces the way it was
engraved. Mirroring it changes the specimen. The chevron mirrors; the fish does not.

## Tests first

Write every row before touching `species_browse_screen.dart`. Run them. **They must fail.**

| # | Test name | Case | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SpeciesBrowseRepository.browseByFamily groups every species under its family` | 3 families, 9 species | 3 groups, correct membership | §6 S6's one structural requirement |
| 2 | `SpeciesBrowseRepository.browseByFamily resolves the family name in the active locale` | locale `gl`, `Veneridae` | Galician name, not `Veneridae` | §4.3's bold clause and §9.1's argument; this is the assertion the whole screen exists for |
| 3 | `SpeciesBrowseRepository.browseByFamily falls back to en when gl has no family key` | locale `gl`, key only in `en` | the `en` value | §9.2's chain, second-to-last link |
| 4 | `SpeciesBrowseRepository.browseByFamily falls back to the scientific family when no key resolves` | key in no locale | `Veneridae` | The last link — never a raw key, never blank |
| 5 | `SpeciesBrowseRepository.browseByFamily orders families by their localised name` | `gl` names out of alphabetical binomial order | localised alphabetical | Ordering by the binomial would put a Galician grid in Latin order, which reads as random |
| 6 | `SpeciesBrowseRepository.browseByFamily orders species inside a family by display name` | 3 species | alphabetical by display name | A grid the user scans needs a stable, guessable order |
| 7 | `SpeciesBrowseDao.browseByFamily uses idx_species_family` | `EXPLAIN QUERY PLAN` | plan contains `idx_species_family` | §13's low-end-device line; a 400-row join without the index shows up only on the 2 GB Android |
| 8 | `SpeciesBrowseRepository.browseByFamily returns a failure when the reference database is unreadable` | closed executor | `Result` failure | The `error` state has to be reachable to be rendered |
| 9 | `SpeciesBrowseScreen renders one section label per family` | 3 families | 3 `LonjaSectionLabel`s | The gazette device replaces every header tile; a `Card` title here would fail the lists gate |
| 10 | `SpeciesBrowseScreen renders the family name as authored, without upper-casing` | `Ameixas e berberechos` | text is byte-identical | `lonja-typography` rule 10 — a no-op on Arabic and a Turkish-i hazard on Latin |
| 11 | `ar - SpeciesBrowseScreen renders the family heading with zero letter spacing` | locale `ar` | style `letterSpacing == 0` | Positive tracking severs the cursive joins and هامور becomes ه ا م و ر |
| 12 | `SpeciesBrowseScreen renders every tile as a silhouette` | mixed protected and ordinary | all `LonjaSilhouette` | `engraved-plates.md`: a browse list is a shape hint, not an identification claim |
| 13 | `SpeciesBrowseScreen marks a protected species tile with a glyph and a word` | protected species | glyph and word present | Invariant 4, and the fisher should see it before he taps |
| 14 | `SpeciesBrowseScreen computes the tile width from the viewport` | 320 and 412 dp | tile width differs | `structural-layout.md`: a hardcoded tile breaks on the next screen size |
| 15 | `SpeciesBrowseScreen keeps the silhouette aspect at 140 by 64` | any tile | ratio within one logical pixel | `engraved-plates.md`'s grid; a squashed fish is a different fish |
| 16 | `sunlight - SpeciesBrowseScreen draws the silhouette outline at 2.10` | sunlight theme | painter stroke `2.10` | §4.3's "legible at arm's length in sunlight", discharged as a number instead of a wish |
| 17 | `SpeciesBrowseScreen draws the silhouette outline at 1.60 in paper density` | paper theme | painter stroke `1.60` | The negative half: without it, a painter hardcoded at 2.10 passes test 16 |
| 18 | `RTL - SpeciesBrowseScreen does not mirror the silhouette` | locale `ar` | painter receives no mirror transform | `icon-system.md` sets `mirrorInRtl: false` on every species silhouette |
| 19 | `RTL - SpeciesBrowseScreen lays the grid from the start edge` | locale `ar` | first tile `dx` > last tile `dx` | The grid itself must mirror even though the fish does not — the two are separate decisions |
| 20 | `SpeciesBrowseScreen offers Identify this fish from the app bar` | tap | route pushed to S7 | §4.3's third entry point; E14/T06 asserts the set of three |
| 21 | `SpeciesBrowseScreen opens the species detail when a tile is tapped` | tap a tile | route pushed with the species id | §4.1: four paths land on the same species detail |
| 22 | `SpeciesBrowseScreen passes the species id to its callback, not the tile value` | tap after a rebuild | callback receives the id | `rebuild-mechanics.md`'s stale-closure hole |
| 23 | `SpeciesBrowseScreen renders the authored empty state when no species are recorded` | 0 families | headline and body present | `the-four-states.md`: `SizedBox.shrink()` is the exact defect the lists gate exists to kill |
| 24 | `SpeciesBrowseScreen renders a ruled skeleton while loading` | `AsyncLoading` | skeleton, no spinner | No network, so no spinner — a local read that needs one is a query bug |
| 25 | `SpeciesBrowseScreen renders the error state when the read fails` | `AsyncError` | headline and diagnostic line | `error` outranks every other state |
| 26 | `SpeciesBrowseScreen builds only the visible tiles` | 400 species | fewer than 400 tiles built | §13: no image caching beyond the visible grid, on 2 GB of RAM |

```dart
// app/test/ui/species/species_browse_screen_test.dart
import 'package:catchlaw/ui/species/widgets/species_browse_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';
import '../../../testing/models/k_species.dart';

void main() {
  testWidgets('SpeciesBrowseScreen renders the family name as authored, without upper-casing',
      (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(
      const SpeciesBrowseScreen(),
      locale: const Locale('gl'),
      overrides: [speciesBrowseViewModelProvider.overrideWith(
        () => StubBrowseViewModel(groups: [kFamilyAmeixas]), // 'Ameixas e berberechos'
      )],
    );
    await tester.pump();

    // lonja-typography rule 10: casing a content string in a widget is a no-op on
    // Arabic and a Turkish-i hazard on Latin.
    expect(find.text('Ameixas e berberechos'), findsOneWidget);
    expect(find.text('AMEIXAS E BERBERECHOS'), findsNothing);
  });

  testWidgets('sunlight - SpeciesBrowseScreen draws the silhouette outline at 2.10',
      (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(
      const SpeciesBrowseScreen(),
      theme: LonjaThemeMode.sunlight,
      overrides: [speciesBrowseViewModelProvider.overrideWith(
        () => StubBrowseViewModel(groups: [kFamilyAmeixas]),
      )],
    );
    await tester.pump();

    final painter = tester
        .widget<CustomPaint>(find.descendant(
          of: find.byType(LonjaSilhouette).first,
          matching: find.byType(CustomPaint),
        ))
        .painter! as LonjaSilhouettePainter;

    // SPEC §4.3: "legible at arm's length in sunlight", as a number.
    expect(painter.outlineWidth, 2.10);
  });

  testWidgets('RTL - SpeciesBrowseScreen does not mirror the silhouette', (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(
      const SpeciesBrowseScreen(),
      locale: const Locale('ar'),
      overrides: [speciesBrowseViewModelProvider.overrideWith(
        () => StubBrowseViewModel(groups: [kFamilyGroupers]),
      )],
    );
    await tester.pump();

    // A specimen faces the way it was engraved; mirroring it changes the specimen.
    expect(find.byType(LonjaSilhouette).evaluate().every(_hasNoMirrorTransform), isTrue);
  });

  // … one test per row in the table above, one behaviour each
}
```

**Run:** `cd app && flutter test test/ui/species/species_browse_screen_test.dart test/data/repositories/species_browse_repository_test.dart`
→ 26 failures. If test 17 passes early, the painter is reading a literal rather than
`LonjaIconTheme`, and test 16 will pass for the wrong reason once the theme is wired.

## Implementation outline

1. `SpeciesBrowseDao`: one statement, `SELECT … FROM species s JOIN family f ON f.id = s.family_id
   ORDER BY s.family_id`, served by `idx_species_family`. Grouping happens in the repository, not in
   SQL, so the family name can be resolved through E06's resolver before ordering.
2. The repository resolves `family.name_key` through `content_string` with §9.2's chain, then sorts
   families by the resolved name using a locale-aware collator, then sorts each family's species by
   display name. Sorting after resolution is why the grouping is Dart.
3. `LonjaSectionLabel` in `app/lib/ui/core/ui/`: a `Row` of the `microLabel` text plus an
   `Expanded(child: DecoratedBox(...))` carrying `rules.sectionLabel`. No `Divider` widget — the
   ladder is `BorderSide`s.
4. `SpeciesBrowseScreen`: `CustomScrollView`; per family a `SliverToBoxAdapter` heading and a
   `SliverGrid.builder` with `SliverGridDelegateWithMaxCrossAxisExtent`. Spacing values come from
   the theme's 4-pt spine.
5. `_SilhouetteTile`: a `const`-constructible private class holding `LonjaSilhouette`, the display
   name in `legalSmall`, the binomial in `binomial`, and the protected `LonjaPill` when applicable.
   The whole tile is one `InkWell` at `LonjaTargets.control` / `gloveControl`.
6. The painter takes `outlineWidth` from `LonjaIconTheme.of(context)` at the widget, not inside
   `paint()` — `check_lonja_tokens.sh` check 8 bans `Theme.of` and `LonjaTokens.of` inside a
   `*_painter.dart`, because a painter takes a snapshot.
7. Wire the app-bar action to S7's route, the same placeholder seam T03 uses.
8. Add three ARB keys to all six files.
9. Re-run the suite. All 26 green, T01–T03 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 26 tests pass, and each failed first.
- [ ] Every family heading resolves through `family.name_key` → `content_string`, with §9.2's full
      fallback chain, and the `gl` case is asserted with a real Galician string.
- [ ] `grep -rn '\.toUpperCase()' app/lib/` returns nothing.
- [ ] The silhouette stroke resolves from `LonjaIconTheme`, and both the paper (1.60) and sunlight
      (2.10) values are asserted.
- [ ] No tile dimension is a literal, and no test asserts a *minimum* tile size.
- [ ] `crossAxisSpacing` and `mainAxisSpacing` both come from the theme's spacing spine, and their
      meaning is asserted by a test that uses unequal gutters.
- [ ] No species silhouette mirrors under `ar`; the grid itself does.
- [ ] The grid builds lazily — a 400-species fixture builds fewer than 400 tiles.
- [ ] Three ARB keys exist in all six locales (D-3).
- [ ] *Identify this fish* is reachable from the app bar; the three-entry-point assertion is
      E14/T06's.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
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
feat(species): build S6 as a silhouette grid grouped by localised family name

Family names come from family.name_key through content_string with SPEC §9.2's
full fallback chain, so a Galician grid says the Galician family name and a
missing key degrades to the binomial rather than to a raw key. §9.1 is the
argument: the Xunta publishes tallas minimas in Galician, and a Latin-headed
grid presents a Galician legal text in translation to a Galician-speaking
mariscadora.

Silhouettes, not plates: engraved-plates.md gives a browse list the weaker claim
— "this is roughly the shape you have" — because the user does not yet know what
the fish is. The protected pill still appears on the tile so he sees it before he
taps.

"Legible at arm's length in sunlight" is discharged as three assertions: the
outline stroke resolves from LonjaIconTheme at 1.60 paper and 2.10 sunlight, the
tile width is computed from the viewport rather than hardcoded, and the aspect
stays 140:64.

Task: E08/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
