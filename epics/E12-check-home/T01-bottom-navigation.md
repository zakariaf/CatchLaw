# E12/T01 — The bottom navigation

| | |
|---|---|
| **Epic** | E12 — Check home and the navigation shell |
| **Branch** | `epic/12-check-home` (shared) |
| **Commit** | `feat(check): add the frozen five-destination nav strip and the shell that routes it` |
| **Depends on** | E11 merged (S9 exists); nothing inside this epic |
| **Size** | M |
| **Spec** | `SPEC.md` §6 "Bottom navigation, enumerated", §4.9 (glove targets, one-handed reach) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-navigation-chrome` | Owns the frozen five, the ruled-strip treatment, the four-signal selected state and the rule that every chrome string resolves through `AppLocalizations`. This task is that skill's subject matter. |
| `lonja-design-tokens` | The strip spends `surfaceSunk`, `onSurface`, `hairline`, `accent` and `density`; a raw hex here fails the token gate and ships a colour no theme defines. |
| `catchlaw-conventions-index` | Invariant 4 (colour is never the only signal) and rule 11 (chrome never draws connectivity, sync or account) both land on this widget. |
| `navigation-and-routing` | `StatefulShellRoute`, branch navigators and the route constants live there. This task builds the shell; that skill owns the router mechanics. |
| `adaptive-layout` | The safe-area contract and the width at which a bottom strip becomes a rail. This task pins the strip to the bottom in both orientations and must know where that decision stops being ours. |
| `state-management-riverpod` | The shell reads the glove-density flag and the selected branch index without rebuilding the whole tree. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6, first paragraph | The enumeration: five items, fixed, always visible, labelled and iconned |
| `SPEC.md` | §4.9 | 56 dp glove targets with 8 dp separation; primary actions in the bottom third |
| `.claude/skills/lonja-navigation-chrome/SKILL.md` | rules 1–7, 11, 12 | The frozen five, the ledger strip, the selected-state stack, translated chrome, directional geometry |
| `.claude/skills/lonja-navigation-chrome/references/nav-anatomy-and-states.md` | "The five destinations, frozen", "Strip metrics", "The selected-state signal stack", "Edge cases" | Every measured value below: 62/76 dp, 2 dp ink rule, 3 dp rail, 21 dp glyph, 9 sp label, the 320 dp cell arithmetic |
| `.claude/skills/lonja-navigation-chrome/examples/lonja_bottom_nav.dart` | whole | The worked shape — the enum with its glyph pair, `_NavCell`, the `Semantics(selected:)` wrapper. Do not diverge silently |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "Tier 2", "The density set" | `surfaceSunk`, `hairline`, `accent`, `onSurface`; `tapMin` 48/56, `tapGap` 4/8 |
| `FLUTTER_GUIDE.md` | Part 1.2 | The exhaustive allow-list of logic a View may contain — the shell holds routing logic and nothing else |
| `FLUTTER_GUIDE.md` | Part 8.2 | Why every cell that can be `const` is `const`: the measured subtree short-circuit |
| `epics/DECISIONS.md` | D-2, D-3, D-8 | Tokens live in `app/lib/theme/`; six locales; directional geometry is a grep gate |
| `epics/CONVENTIONS.md` | §5, §6 | Test naming and where the tests live |

## What this delivers

- `app/lib/ui/core/ui/lonja_destination.dart` — `enum LonjaDestination { check, today, trips, reference, settings }`
  carrying its outline/filled glyph pair and an exhaustive `label(AppLocalizations)` switch.
- `app/lib/ui/core/ui/lonja_nav_strip.dart` — the strip, plus the private `_LonjaNavCell` it is built
  from. One public widget, one file.
- `app/lib/ui/core/ui/app_shell.dart` — the `StatefulShellRoute.indexedStack` body: branch child above,
  strip below, system inset applied by the strip itself.
- `app/lib/routing/routes.dart` — the path constants for the five branches and for `/identify`.
- `app/lib/routing/router.dart` — the five branches registered, `initialLocation` set to Check.
- `app/lib/routing/destination_placeholder.dart` — the one named stand-in for Today, Trips, Reference
  and Settings, whose dartdoc names E13, E15 and E16 as its replacements.
- `app/lib/l10n/app_*.arb` × 6 — `navCheck`, `navToday`, `navTrips`, `navReference`, `navSettings`.
- `app/test/ui/core/ui/lonja_nav_strip_test.dart`, `app/test/routing/app_shell_test.dart`.

The four unbuilt destinations get **one** placeholder class, not four. It renders the destination's own
translated label and an empty body, so it adds no ARB key that a later epic has to delete.

## Why it is built this way

**Five values in an enum, not a list literal.** `nav-anatomy-and-states.md` does the arithmetic: five
cells at 320 dp width is 64 dp each, above the 56 dp glove floor in `SPEC.md` §4.9; a sixth drops them
to 53 dp and fails it. An enum makes the count a compile-time fact that `check_lonja_nav.sh` check 3
reads, and makes a new destination a compile error in the label switch until it has been translated
into all six locales (D-3). A `List<NavigationDestination>` grows by one in a PR nobody blocks.

**The selected cell carries four signals and colour is the fourth.** Ground lifting from `surfaceSunk`
to `surface`, a 3 dp rail on the **top** edge, the filled glyph variant, and label weight 600 against
500. The sunlight theme deletes `accent` entirely — `token-tables.md` binds it to `black00` there — so
a colour-only selection state simply vanishes on deck at noon, which is invariant 4. The rail is on the
top edge because a bottom rail is hidden by the thumb that just pressed it.

**`StatefulShellRoute.indexedStack`, not five root routes.** Each branch keeps its own navigator, so
pushing S5 inside Check and then visiting Reference and coming back returns to S5 rather than to S1.
Rebuilding the branch would be visible as a lost search box at exactly the moment the user was
interrupted.

**Rejected: `NavigationBar`.** Material's bar ships an elevation, a stadium indicator pill and a
scrolled-under tint. The pill replaces the top rail — the one signal that survives the sunlight theme —
and the shadow floats the strip off the paper, which is the authority claim the whole design rests on.
Defeating those three defaults costs more code than the 40 lines the strip takes.

**Rejected: hiding the strip when the keyboard is up.** `nav-anatomy-and-states.md` is explicit: the
strip is pushed up by the view insets and never hidden, because a target that disappears and reappears
under a thumb causes mis-taps. This is tested, not assumed.

**Rejected: four separate placeholder screens.** Four screens means four ARB keys, four widgets and
four deletions in three later epics. One placeholder that renders the destination's existing label
means E13 replaces a route builder and nothing else.

## Tests first

Write every row before touching `lonja_nav_strip.dart`. Run them. **They must fail.** A row that passes
now is testing a default rather than this widget — fix the test before writing production code.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `LonjaDestination declares five values in the order check, today, trips, reference, settings` | — | `values` matches the literal list | The frozen five; thumb memory is built in the dark and destroyed by a reorder |
| 2 | `LonjaDestination.label resolves every value through AppLocalizations` | loop over `values` | each label equals the matching `AppLocalizations` getter | A literal ships English chrome into the Arabic build with no analyzer warning |
| 3 | `LonjaNavStrip renders one cell per destination and no more` | strip at 360 dp | 5 cells | The count is the whole contract; a sixth breaks the 56 dp floor |
| 4 | `LonjaNavStrip marks the current cell selected for the screen reader` | current = `trips` | `Semantics(selected: true)` on cell 3 only | TalkBack's equivalent of the rail; without it the selection is invisible to a screen reader |
| 5 | `LonjaNavStrip draws the selected rail on the top edge of the cell` | current = `check` | top `BorderSide` width 3 on cell 0, absent elsewhere | A bottom rail is covered by the thumb that just pressed it |
| 6 | `LonjaNavStrip switches the selected cell to the filled glyph` | current = `today` | cell 1 renders the filled `IconData`, the rest outline | Signal 3, the one that survives greyscale and sunlight |
| 7 | `sunlight - LonjaNavStrip distinguishes the selected cell with the accent colour removed` | sunlight theme, current = `check` | ground, rail and glyph still differ | Sunlight binds `accent` to `black00`; invariant 4 |
| 8 | `glove - LonjaNavStrip measures 76 dp tall` | `LonjaDensity.glove` | strip height 76, not 62 | §4.9's 56 dp target floor is met by height plus cell width, not by hit-slop |
| 9 | `LonjaNavStrip keeps every cell at least 56 dp wide at 320 dp width` | surface 320 dp | each cell ≥ 56 dp | The exact arithmetic that forbids a sixth destination |
| 10 | `RTL - LonjaNavStrip draws the cell hairline on the inline-end edge` | `TextDirection.rtl` | hairline mirrors to the left of each cell | `BorderDirectional`, not `Border(right:)`; D-8 |
| 11 | `LonjaNavStrip omits the hairline on the last cell` | — | cell 4 has no end border | An orphan rule against the trim reads as a printing defect |
| 12 | `LonjaNavStrip pads its bottom by the system view padding` | `viewPadding.bottom = 34` | 34 dp below the cells, ink rule still flush to the trim | Full-bleed: `SafeArea` around the strip would leave a gap the ink rule cannot cross |
| 13 | `LonjaNavStrip stays visible when the keyboard insets the view` | `viewInsets.bottom = 280` | strip still hit-testable | A target that vanishes and returns under the thumb causes mis-taps |
| 14 | `LonjaNavStrip renders no connectivity, sync or badge affordance` | — | no badge, no sync/wifi/cloud glyph in the subtree | Invariant 1's surface consequence: an affordance is a promise of a network that does not exist |
| 15 | `ar - LonjaNavStrip renders the destination labels from app_ar.arb` | locale `ar` | the five Arabic labels | D-3; six locales ship together or the feature does not ship |
| 16 | `AppShell selects the check branch on the first frame` | fresh router | index 0, no database read required | `nav-anatomy-and-states.md` cold-start edge case: the strip renders before any query completes |
| 17 | `AppShell restores the Check branch route when the user returns from Reference` | push S5, tap Reference, tap Check | S5 still on screen | Why `StatefulShellRoute` rather than five root routes |
| 18 | `AppShell routes each destination to its own branch location` | tap each cell | router location matches `routes.dart` | The five taps are the only navigation the strip performs |

```dart
// app/test/ui/core/ui/lonja_nav_strip_test.dart
import 'package:catchlaw/ui/core/ui/lonja_destination.dart';
import 'package:catchlaw/ui/core/ui/lonja_nav_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/harness.dart'; // pumpLonja(...) — theme, density, locale, MediaQuery

void main() {
  test('LonjaDestination declares five values in the order check, today, trips, reference, settings',
      () {
    expect(LonjaDestination.values, <LonjaDestination>[
      LonjaDestination.check,
      LonjaDestination.today,
      LonjaDestination.trips,
      LonjaDestination.reference,
      LonjaDestination.settings,
    ]);
  });

  testWidgets('LonjaNavStrip draws the selected rail on the top edge of the cell', (tester) async {
    await pumpLonja(tester, const LonjaNavStrip(current: LonjaDestination.check));

    final cells = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).toList();
    final selected = (cells.first.decoration as BoxDecoration).border! as BorderDirectional;
    expect(selected.top.width, 3);
    expect(selected.bottom, BorderSide.none);
  });

  testWidgets('LonjaNavStrip keeps every cell at least 56 dp wide at 320 dp width', (tester) async {
    await pumpLonja(tester, const LonjaNavStrip(current: LonjaDestination.check),
        surfaceSize: const Size(320, 640));

    for (final d in LonjaDestination.values) {
      expect(tester.getSize(find.byKey(ValueKey(d))).width, greaterThanOrEqualTo(56));
    }
  });

  testWidgets('RTL - LonjaNavStrip draws the cell hairline on the inline-end edge', (tester) async {
    await pumpLonja(tester, const LonjaNavStrip(current: LonjaDestination.check),
        textDirection: TextDirection.rtl);

    final first = tester.getRect(find.byKey(const ValueKey(LonjaDestination.check)));
    final second = tester.getRect(find.byKey(const ValueKey(LonjaDestination.today)));
    expect(first.left, greaterThan(second.left)); // check sits on the right in Arabic
  });

  // … one test per row above, one behaviour each
}
```

```dart
// app/test/routing/app_shell_test.dart
testWidgets('AppShell restores the Check branch route when the user returns from Reference',
    (tester) async {
  await pumpApp(tester);
  await tester.tap(find.byKey(const ValueKey('check.search')));
  await tester.pumpAndSettle();
  expect(find.byType(SpeciesSearchScreen), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey(LonjaDestination.reference)));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey(LonjaDestination.check)));
  await tester.pumpAndSettle();

  expect(find.byType(SpeciesSearchScreen), findsOneWidget);
});
```

**Run:** `cd app && flutter test test/ui/core/ui/lonja_nav_strip_test.dart test/routing/app_shell_test.dart`
→ 18 failures. If any passes now, the test is wrong.

## Implementation outline

1. `lonja_destination.dart`: the enum with `(outline, filled)` glyph fields from `lonja-icons-and-plates`'
   set, `glyph({required bool on})`, and an exhaustive `label(AppLocalizations)` switch. No default arm.
2. Add `navCheck` … `navSettings` to `app_en.arb`, then to `app_ar.arb`, `app_es.arb`, `app_gl.arb`,
   `app_ca.arb`, `app_pt_BR.arb` in the same commit. Run `gen-l10n`.
3. `lonja_nav_strip.dart`: `DecoratedBox` over a `Row` of five `Expanded` cells, `surfaceSunk` ground,
   2 dp `onSurface` top rule, bottom padding from `MediaQuery.viewPaddingOf(context).bottom`. Height
   from `LonjaTokens.of(context).density`.
4. `_LonjaNavCell`: `Semantics(selected:, button:)` over an `InkWell` over a `DecoratedBox` with a
   `BorderDirectional(top:, end:)`. `ValueKey(destination)` on the cell so the tests can address it.
   Every constructor that can be `const` is `const` (`FLUTTER_GUIDE.md` Part 8.2).
5. `routes.dart`: `checkPath`, `todayPath`, `tripsPath`, `referencePath`, `settingsPath`, `identifyPath`.
6. `router.dart`: `StatefulShellRoute.indexedStack` with five branches, `initialLocation: checkPath`,
   builder returning `AppShell`.
7. `destination_placeholder.dart`: one widget taking a `LonjaDestination`, rendering its translated
   label. Dartdoc: replaced by E13 (today, trips), E15 (reference), E16 (settings).
8. Re-run the suite. All 18 green and nothing E08–E11 shipped goes red.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 tests pass, and each failed first.
- [ ] `LonjaDestination` has exactly five values and no `default` arm anywhere it is switched on.
- [ ] No string literal appears as a `label:`, `tooltip:`, `semanticLabel:` or bare `Text()` in any
      file under `app/lib/ui/core/ui/` or `app/lib/routing/`.
- [ ] Every colour, gap and rule weight in the strip comes from `LonjaTokens`; no `Color(0x`, no
      numeric `EdgeInsets`, no `elevation:` above 0, no `BorderRadius`.
- [ ] `destination_placeholder.dart` is referenced by exactly four route builders and nowhere else.
- [ ] The five ARB keys exist in all six locales (D-3).
- [ ] The strip renders identically at `textScaler` 2.0 apart from ellipsised labels — the strip does
      not grow.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh   app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh    app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
tools/gates/no_directional_geometry.sh app/lib
```

Every gate takes the target directory explicitly. They exit 2 on a missing directory, and at this
repository root a bare default of `lib/` does not exist (D-1).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(check): add the frozen five-destination nav strip and the shell that routes it

Five cells at 320 dp width is 64 dp each, above the 56 dp glove floor in
SPEC.md §4.9; a sixth destination drops them to 53 dp. The count is therefore
an enum the gate can read rather than a list literal a PR can grow, and the
label switch is exhaustive so a new value cannot ship untranslated.

The selected cell carries a lifted ground, a 3 dp top rail, the filled glyph
and weight 600 before colour is spent, because the sunlight theme binds accent
to black and a colour-only selection state disappears on deck at noon.

Today, Trips, Reference and Settings point at one named placeholder that
renders their own translated label; E13, E15 and E16 replace a route builder
and nothing else.

Task: E12/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
