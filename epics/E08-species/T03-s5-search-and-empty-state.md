# E08/T03 — S5, and an empty state that routes onward

| | |
|---|---|
| **Epic** | E08 — Species: search, browse and the static detail |
| **Branch** | `epic/08-species` (shared) |
| **Commit** | `feat(species): build S5 with grouped results and an empty state that routes onward` |
| **Depends on** | T02 (the view model, the groups and the hints) |
| **Size** | M |
| **Spec** | `SPEC.md` §6 S5 (Elements and Empty state), §4.1 (species picker), §4.3 (entry points), §4.9 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | Owns the species row: the fixed slot order, the whole row as one target, the hairline instead of a card, and the four states this screen must author |
| `lonja-forms-and-controls` | Owns the search field as a ruled entry line, `LonjaTargets`, the never-`autofocus` rule and the ban on a spinner in an app with no network |
| `lonja-icons-and-plates` | Owns the silhouette-versus-plate decision on a search result row, the four glyph sizes, and the empty state's one-mark-no-illustration policy |
| `lonja-typography` | The row's name, binomial and hint each name a ramp step; no `TextStyle` may be authored here |
| `widget-composition` | Widget classes not `_build` methods, dumb views, lazy lists, `EdgeInsetsDirectional`, and the identity-not-content rule in the row's `onTap` |
| `state-management-riverpod` | `ref.watch` to show and `ref.read(p.notifier)` in the callbacks; the stale-closure hole in a list row is exactly the case it describes |
| `catchlaw-conventions-index` | Invariants 2, 4 and 5 land on this screen: no imperative in a row or an empty state, glyph plus word plus colour, and the ochre bar over live data |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S5 | Elements and the empty state, verbatim: two actions plus the active-jurisdiction note |
| `SPEC.md` | §4.1 "Species picker" row | Four paths land on the same species detail — this is one of them |
| `SPEC.md` | §4.3 "Entry points" row | "S7 is reachable from three places (this was a defect in the first draft)"; S5's empty state is one |
| `SPEC.md` | §4.9 "Glove mode" and "One-handed reach" | ≥ 56 dp targets with ≥ 8 dp separation; primary actions in the bottom third |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The species row — slot table", "Density", "Choosing a container" | The six slots and their ramp steps; 64 dp / 76 dp; `ListView.builder` for an unbounded homogeneous list |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | whole | Precedence, the authored Search empty copy, the loading skeleton shape, the stale bar geometry |
| `.claude/skills/lonja-forms-and-controls/references/search-field-and-keypad.md` | "The search field, slot by slot", "Edge cases" | Every slot including the `6 of 412` result count; the recents strip stays visible; never `autofocus` |
| `.claude/skills/lonja-icons-and-plates/references/engraved-plates.md` | "When a plate is REQUIRED" | Search result row: protected and look-alike get a plate, ordinary species get a silhouette |
| `.claude/skills/lonja-icons-and-plates/references/icon-system.md` | "Size scale", "RTL mirroring" | 16/22/30/44 only; the chevron mirrors, the fish does not |
| `Flutter-Skills: widget-composition/references/structural-layout.md` | "The window is edge-to-edge", "IME / keyboard insets", "Directional insets always" | Full-bleed background, `SafeArea` content, `resizeToAvoidBottomInset`, never `autofocus` at cold launch |
| `Flutter-Skills: widget-composition/references/rebuild-mechanics.md` | "Resolve identity, not content", "Keys" | `onTap: () => onOpen(row.speciesId)`; `ValueKey` on a variable-length list's rows |
| `FLUTTER_GUIDE.md` | §1.2 | The exhaustive allow-list for what a View may contain |
| `FLUTTER_GUIDE.md` | §8.1 | Private widget classes in the same file; the `BuildContext` scoping argument that decides it for a six-locale app |
| `epics/DECISIONS.md` | D-2, D-8 | The theme lives at `app/lib/theme/`; `EdgeInsets.only(left:` is banned by a grep gate |

## What this delivers

- `app/lib/ui/core/ui/lonja_search_field.dart` — the first Lonja control: a ruled entry line,
  `BorderRadius.zero`, a 1.5 px `ink` side, height from `LonjaTargets.control` / `gloveControl`, a
  persistent label above the rule, an illustrative hint, a trailing clear affordance and the
  `6 of 412` mono result count. The one raw `TextField` in the app, carrying `// lonja-core-ok`.
- `app/lib/ui/core/ui/lonja_species_row.dart` — the species row: one `InkWell` over the whole rect
  at `rowMinHeight`, the six slots in their fixed order, a dotted hairline the row draws itself.
- `app/lib/ui/core/ui/lonja_empty_state.dart` — a rule, one 44 px mark, a serif headline, a serif
  body and an action slot that takes one primary and an optional secondary.
- `app/lib/ui/core/ui/lonja_stale_bar.dart` — the ochre bar, non-dismissable, non-blocking.
- `app/lib/ui/core/ui/lonja_list_skeleton.dart` — six ruled skeleton rows, no spinner.
- `app/lib/ui/species/widgets/species_search_screen.dart` — S5, with private `_ResultGroup`,
  `_GroupHeading`, `_SearchEmptyState` and `_SearchErrorState` widget classes in the same file.
- `app/lib/ui/species/widgets/species_art.dart` — the art resolver: plate for protected and
  look-alike, silhouette otherwise, with the `assert` that makes the wrong pairing unshippable and
  the documented fall-back when `plate_asset` is null.
- `app/lib/routing/species_routes.dart` — the S5 route and its two onward routes.
- ARB keys in all six files (D-3): `speciesSearchLabel`, `speciesSearchHint`,
  `speciesSearchResultCount`, `speciesGroupInYourZone`, `speciesGroupElsewhere`,
  `speciesHintProtected`, `speciesHintClosed`, `speciesNoMatchHeadline`, `speciesNoMatchBody`,
  `identifyThisFish`, `browseByShape`, `rulePackExpired`.
- Tests: `app/test/ui/species/species_search_screen_test.dart`,
  `app/test/ui/core/ui/lonja_species_row_test.dart`,
  `app/test/ui/species/species_art_test.dart`.

## Why it is built this way

**The empty state carries two actions, and that is not the defect the skill bans.**
`lonja-lists-and-tables/references/the-four-states.md` says an empty state gets "exactly ONE
`LonjaButton.primary`; two competing actions is a defect". `SPEC.md` §6 S5 requires **Identify this
fish** *and* **Browse by shape**, and §4.3 records that S7 reachable from only one place was a
defect in the first draft — S5's empty state is one of the three fixes, and E14/T06 asserts all
three together. The resolution: one *primary* (**Identify this fish**) and one *secondary*
(**Browse by shape**). The skill's defect is two competing primaries, which this is not; its own
authored Search copy already ends "…or browse by shape". `SPEC.md` is authoritative for the product.
`epic.md` risk 1 records the seam and names the skill correction that would close it properly. This
epic does not edit a skill file.

**The jurisdiction note quotes a real count.** §6 S5 requires "a note that the list covers the
active jurisdiction only", and `the-four-states.md`'s sample body quotes a number. T02 puts
`jurisdictionSpeciesCount` on the state precisely so the note can say *214 entries are held for
Rías Baixas* rather than a constant that is wrong in every other jurisdiction. The headline names
the absence with the user's own typed string, unaltered — `search-field-and-keypad.md` rule: the
visible text is the user's.

**One `InkWell` over the whole row.** `lonja-lists-and-tables` rule 1, with its own reason: a
15 dp chevron hit box means the row silently does nothing to a wet neoprene finger at 05:40. The
chevron is inert decoration and never carries `onTap`. A widget test taps the row's **start edge**
— not its centre — because the centre passes even when only the chevron is wired.

**The art slot resolves to a plate for protected and look-alike species.**
`engraved-plates.md`'s required-art table is explicit for a *search result row*: protected → plate,
look-alike pair member → plate, ordinary → silhouette. The reason is that the verdict rests on the
identification, and a smudge of outline cannot separate two emperors. The slot **order** is
unchanged — slot 1 is the art slot in every case; only its size changes, which is what
`row-and-table-anatomy.md` permits ("A screen may OMIT a trailing slot; it may never reorder or
insert"). `SPEC.md` §7.1 makes `plate_asset` nullable and §8 drops any plate whose artist cannot be
identified, so the resolver falls back to the silhouette when `plate_asset` is null, and a test
pins that fallback so it is a decision rather than an accident (`epic.md` risk 5).

**No spinner, and the loading body is a ruled skeleton.** `lonja-forms-and-controls` rule 9 and
`the-four-states.md` both ban it, and the reason is the product's whole posture: a spinner in a
100% offline app makes the fisher wait for a network that does not exist. Six skeleton rows,
`paper-sunk` blocks, a 900 ms opacity pulse frozen under reduced motion. The count is six and is
never derived from the pending query.

**The stale bar composes with data; it does not replace it.** `the-four-states.md` puts `stale`
outside the exclusive three, and invariant 5 says an expired ruleset is still evaluated and still
shown. So the body is `error | loading | empty | data` and the bar rides above whichever one is
showing. Ochre, never oxblood: oxblood means the fish fails the rule, ochre means the paper is old,
and conflating them tells Khalid he has committed an offence when he has not.

**Never `autofocus`.** `search-field-and-keypad.md` and §6 S1 both say it, for the same reason:
the keyboard covers the recents strip, which is the fastest path to a verdict. The strip T07 builds
sits above the field on this screen, per that reference's first edge case.

**Rejected: `ListTile`.** Banned by `lonja-lists-and-tables` rule 3 — it hardcodes Material's
paddings, splash and three-line cap, silently overrides every Lonja type role the row sets, and its
leading/trailing slots do not mirror correctly in Arabic. Defeating it costs more than authoring the
row.

**Rejected: helper methods for the group heading and the row.** `FLUTTER_GUIDE.md` §8.1 gives the
decisive mechanism for *this* app: a helper method has no `BuildContext` of its own, so
`AppLocalizations.of(context)` inside one registers the **parent** element as the dependent and the
whole screen rebuilds on every locale change. With six locales and an RTL flip, that is not
academic. Private widget classes in the same file, per the same section's practical shape.

**Rejected: a debounce on the query.** `search-field-and-keypad.md` is explicit — the query is a
local indexed read that renders in the same frame as the keystroke, and if it does not, the fix is
the index, not a debounce. T01 already proved the index in a test.

## Tests first

Write every row before touching `species_search_screen.dart`. Run them. **They must fail.**

| # | Test name | Case | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SpeciesSearchScreen renders the in-zone group before the elsewhere group` | 2 + 2 rows | in-zone heading's `dy` < elsewhere heading's `dy` | §6 S5's ordering is the whole point of the grouping; asserting membership alone would pass with the groups swapped |
| 2 | `SpeciesSearchScreen omits the elsewhere heading when that group is empty` | all in zone | heading absent | An empty heading over nothing reads as a failed query |
| 3 | `SpeciesSearchScreen omits the in-zone heading when that group is empty` | none in zone | heading absent, elsewhere heading present | The Gulf case inverted: a species list for a jurisdiction with no polygons can be all-elsewhere |
| 4 | `SpeciesSearchScreen shows a protected row hint as glyph and word and colour` | protected species | glyph found, word found, oxblood tone | Invariant 4 — a bare oxblood dot states nothing in sunlight mode or to a colour-blind reader |
| 5 | `SpeciesSearchScreen shows a closed-season row hint as glyph and word and colour` | closed species | glyph, word, ochre | The second semantic hint; ochre not oxblood, per `the-four-states.md` |
| 6 | `SpeciesSearchScreen shows a minimum-size row hint as a mono tabular figure` | 450 mm, cm | text `45 cm`, style is the `datum` step | Slot 5 is mono tabular so `45 cm` and `188 cm` share a decimal spine down the column |
| 7 | `SpeciesSearchScreen renders no imperative in any row end slot` | mixed results | no word from the banned lexicon | Invariant 2, asserted on the rendered text rather than on the source, because the ARB is where it would enter |
| 8 | `LonjaSpeciesRow fires its callback when the start edge is tapped` | tap at `topLeft + (4, 32)` | callback fired once | `lonja-lists-and-tables` rule 1 — a centre tap passes even when only the chevron is wired |
| 9 | `LonjaSpeciesRow measures at least 64 dp tall in paper density` | default | `getSize().height >= 64` | The published `rowMinHeight`; a row that shrinks under a short name is a mis-hit |
| 10 | `glove - LonjaSpeciesRow measures at least 76 dp tall` | glove density | `>= 76` | §4.9's 56 dp floor is for controls; the row's own floor is 76 and is what a gloved thumb actually hits |
| 11 | `glove - LonjaSpeciesRow keeps the same slot order` | glove density | slot `dx` order unchanged | Rule 12: glove raises the row, it does not re-lay it out — a reflow doubles the golden matrix |
| 12 | `LonjaSpeciesRow passes the species id to its callback, not the row value` | tap after a rebuild | callback receives the id | `rebuild-mechanics.md`'s stale-closure hole: a re-tap after an edit must not act on a captured value |
| 13 | `SpeciesArt resolves a protected species to a plate` | `isProtected`, plate present | `LonjaPlate` | `engraved-plates.md`'s required-art table; the verdict rests on the identification |
| 14 | `SpeciesArt resolves a look-alike pair member to a plate` | `lookAlikeOf` set | `LonjaPlate` | The second half of the same table, and the reason T06's card exists |
| 15 | `SpeciesArt resolves an ordinary species to a silhouette` | neither | `LonjaSilhouette` | The negative case; without it the resolver could return a plate for everything and pass 13 and 14 |
| 16 | `SpeciesArt falls back to a silhouette when a protected species has no plate asset` | `isProtected`, `plateAsset` null | `LonjaSilhouette`, no throw | §8 drops any plate whose artist cannot be identified — `epic.md` risk 5, pinned as a decision |
| 17 | `SpeciesSearchScreen renders the authored empty state when nothing matches` | 0 hits | headline and body present | `the-four-states.md`: an unauthored empty state renders as a blank frame and a blank golden passes review |
| 18 | `SpeciesSearchScreen empty state offers Identify this fish` | 0 hits | button present, routes to S7 | §4.3's three entry points; this is one, and E14/T06 asserts the set |
| 19 | `SpeciesSearchScreen empty state offers Browse by shape` | 0 hits | button present, routes to S6 | The second action §6 S5 requires — the seam recorded in `epic.md` risk 1 |
| 20 | `SpeciesSearchScreen empty state states the active jurisdiction species count` | 214 seeded | body contains `214` | The note must quote a real count, not a constant that is wrong outside one jurisdiction |
| 21 | `SpeciesSearchScreen empty state quotes the query as typed` | typed `قباب` | body or headline contains `قباب` | The visible text is the user's; a screen that echoes a normalised form tells the fisher he typed something he did not |
| 22 | `SpeciesSearchScreen renders a ruled skeleton while loading` | `AsyncLoading` | 6 skeleton rows, no `CircularProgressIndicator` | A spinner in a 100% offline app is a lie; the count is fixed at six by the reference |
| 23 | `SpeciesSearchScreen renders the error state when the read fails` | `AsyncError` | headline, diagnostic line, no list | `error` outranks every other state; a corrupt asset DB is the only error this screen can have |
| 24 | `SpeciesSearchScreen renders the stale bar above a full result list` | expired pack, 4 hits | bar present, 4 rows present | Invariant 5 — the bar qualifies the data, it never replaces it |
| 25 | `SpeciesSearchScreen renders the stale bar above the empty state` | expired pack, 0 hits | bar and empty state both present | `the-four-states.md`: `stale` composes with `empty` too, and this is the pairing reviewers forget |
| 26 | `SpeciesSearchScreen renders no stale bar while loading` | expired pack, `AsyncLoading` | bar absent | The same reference: `stale` never composes with `loading`, because there is nothing yet to qualify |
| 27 | `SpeciesSearchScreen does not autofocus the search field` | first frame | keyboard not requested | `search-field-and-keypad.md` and §6 S1: the keyboard would cover the recents strip |
| 28 | `SpeciesSearchScreen shows the result count as a mono tabular figure` | 6 of 412 | text present, `citation`-class mono step | The count slot survives input, unlike the hint — that distinction is the reference's first table |
| 29 | `LonjaSearchField leaves هامور byte-identical after typing` | type `هامور` | controller text equals input | `lonja-forms-and-controls` rule 7: a legal tool that rewrites the user's language has lost them |
| 30 | `LonjaSearchField measures at least 56 dp tall, and 66 dp in glove density` | both densities | `>= 56`, `>= 66` | `LonjaTargets.control` / `gloveControl`; a wet gloved fingertip mis-hits Material's 48 |
| 31 | `RTL - SpeciesSearchScreen places the silhouette at the start edge` | `ar` | art `dx` > name `dx` | Directional geometry: an `EdgeInsets.only(left:` here puts the art under the name in Arabic (D-8) |
| 32 | `SpeciesSearchScreen renders every row inside a lazy builder` | 120 rows | fewer than 120 rows built | `lonja-lists-and-tables` anti-pattern: a `Column` in a scroll view builds all 3,180 entries at once |

```dart
// app/test/ui/species/species_search_screen_test.dart
import 'package:catchlaw/ui/species/widgets/species_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';
import '../../../testing/models/k_species.dart';

void main() {
  testWidgets('SpeciesSearchScreen renders the in-zone group before the elsewhere group',
      (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(
      const SpeciesSearchScreen(),
      overrides: [speciesSearchViewModelProvider.overrideWith(
        () => StubSearchViewModel(inZone: 2, elsewhere: 2),
      )],
    );
    await tester.pump();

    final inZone = tester.getTopLeft(find.bySemanticsLabel(l10nEn.speciesGroupInYourZone));
    final elsewhere = tester.getTopLeft(find.bySemanticsLabel(l10nEn.speciesGroupElsewhere));
    expect(inZone.dy, lessThan(elsewhere.dy));
  });

  testWidgets('SpeciesSearchScreen renders the stale bar above a full result list',
      (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(
      const SpeciesSearchScreen(),
      overrides: [speciesSearchViewModelProvider.overrideWith(
        () => StubSearchViewModel(inZone: 4, isPackExpired: true),
      )],
    );
    await tester.pump();

    // SPEC §4.7 / invariant 5: the bar qualifies the data, it never replaces it.
    expect(find.byType(LonjaStaleBar), findsOneWidget);
    expect(find.byType(LonjaSpeciesRow), findsNWidgets(4));
  });

  testWidgets('SpeciesSearchScreen empty state offers Identify this fish', (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(
      const SpeciesSearchScreen(),
      overrides: [speciesSearchViewModelProvider.overrideWith(
        () => StubSearchViewModel(inZone: 0, elsewhere: 0, query: 'قباب'),
      )],
    );
    await tester.pump();

    await tester.tap(find.bySemanticsLabel(l10nEn.identifyThisFish));
    await tester.pump();
    expect(routeSpy.pushed, ['/identify']); // SPEC §4.3 — one of S7's three entry points
  });

  // … one test per row in the table above, one behaviour each
}
```

```dart
// app/test/ui/core/ui/lonja_species_row_test.dart
import 'package:catchlaw/ui/core/ui/lonja_species_row.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';
import '../../../testing/models/k_species.dart';

void main() {
  testWidgets('LonjaSpeciesRow fires its callback when the start edge is tapped',
      (tester) async {
    useDevice(Device.small360);
    var tappedId = -1;
    await tester.pumpApp(LonjaSpeciesRow(
      row: kRowHamour,
      onOpen: (id) => tappedId = id,
    ));

    // The START edge, not the centre: a centre tap passes even when only the
    // chevron is wired, which is the defect lonja-lists-and-tables rule 1 exists for.
    final rect = tester.getRect(find.byType(LonjaSpeciesRow));
    await tester.tapAt(rect.topLeft + const Offset(4, 32));
    await tester.pump();

    expect(tappedId, kSpeciesHamour.id);
  });

  testWidgets('glove - LonjaSpeciesRow measures at least 76 dp tall', (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(
      LonjaSpeciesRow(row: kRowHamour, onOpen: (_) {}),
      density: LonjaDensity.glove,
    );
    expect(tester.getSize(find.byType(LonjaSpeciesRow)).height, greaterThanOrEqualTo(76));
  });

  // … one test per row in the table above, one behaviour each
}
```

**Run:** `cd app && flutter test test/ui/` → 32 failures. If test 22 passes early, the loading
branch is falling through to the empty state — `the-four-states.md` names collapsing `empty` into
`loading` as the most common way this contract is broken.

## Implementation outline

1. Build `LonjaSearchField` first, in `app/lib/ui/core/ui/`. It is the only raw `TextField` in the
   app and carries `// lonja-core-ok`. Height from `LonjaTargets`, no `filled`, no
   `OutlineInputBorder`, `BorderRadius.zero`.
2. `LonjaSpeciesRow` next: one `InkWell`, `BoxConstraints(minHeight: density.rowMinHeight)`,
   `EdgeInsetsDirectional.fromSTEB`, `BorderDirectional(bottom: rules.hairlineDotted)`. Slots 1–6
   in order. The chevron is inside `ExcludeSemantics` and owns no gesture.
3. `SpeciesArt` as a small resolver widget with the `assert` from
   `lonja-icons-and-plates`, extended with the documented `plateAsset == null` fallback.
4. `LonjaEmptyState`, `LonjaStaleBar` and `LonjaListSkeleton`. The empty state's action slot takes
   `primary` and an optional `secondary`; the mark is one 44 px `LonjaIconSize.mark` glyph inside
   `ExcludeSemantics`, and there is no illustration asset.
5. `SpeciesSearchScreen`: `Scaffold` with a full-bleed background and `SafeArea` content;
   `resizeToAvoidBottomInset: true` because the results scroll. The body is one exhaustive `switch`
   over the `AsyncValue`, wrapped in a `Column` whose first child is the conditional stale bar —
   the exact shape `the-four-states.md` prints.
6. `CustomScrollView` with two `SliverList.builder`s and two `SliverToBoxAdapter` headings, because
   the list interleaves section labels (`row-and-table-anatomy.md`'s container table).
7. Add all twelve ARB keys to all six files in this commit (invariant 12's spirit; D-3 for the
   filenames). No key lands in `app_en.arb` alone.
8. Wire the two onward routes. `Identify this fish` targets S7's route name, which E14 implements;
   until then the route resolves to a placeholder that the E14 task replaces — and test 18 asserts
   the *route push*, not the destination, so it keeps passing across that seam.
9. Re-run the suite. All 32 green, T01's and T02's still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 32 tests pass, and each failed first.
- [ ] `grep -rn 'ListTile\|DataTable\|DataColumn\|DataRow' app/lib/` returns nothing.
- [ ] No `Card`, `elevation`, `BorderRadius` above 2, or vertical gap separates two sibling rows.
- [ ] The empty state names the absence, quotes the typed query, states the jurisdiction count and
      offers exactly one primary plus one secondary action.
- [ ] All four states render, and the stale bar coexists with both `data` and `empty` and with
      neither `loading` nor `error`.
- [ ] No `CircularProgressIndicator`, `LinearProgressIndicator`, shimmer or cloud glyph anywhere in
      `app/lib/ui/species/`.
- [ ] `autofocus` appears nowhere on this screen.
- [ ] Every row's whole rect is the target, at 64 dp paper and 76 dp glove, proved by `getSize` and
      a start-edge tap.
- [ ] Twelve ARB keys exist in all six locales `ar`, `en`, `es`, `gl`, `ca`, `pt_BR` (D-3).
- [ ] No `Widget`-returning helper method in the changed files; every extracted piece is a class.
- [ ] No `EdgeInsets.only(left:` or `right:` — `no_directional_geometry.sh` clean (D-8).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh     app/lib
.claude/skills/lonja-icons-and-plates/scripts/check_lonja_icons.sh          app/lib
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
feat(species): build S5 with grouped results and an empty state that routes onward

The empty state carries two actions, and the-four-states.md's "exactly ONE
primary" is not violated: Identify this fish is the primary and Browse by shape
is the secondary. SPEC §4.3 records that S7 reachable from a single place was a
defect in the first draft, and this empty state is one of the three fixes;
E14/T06 asserts the set. The jurisdiction note quotes the real species count
from the view model rather than a constant that would be wrong everywhere except
one ria.

The stale bar composes with data and with the empty state and with neither
loading nor error, per the precedence table. An expired pack still lists every
species it has, because a stale rule beats no rule at sea.

Task: E08/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
