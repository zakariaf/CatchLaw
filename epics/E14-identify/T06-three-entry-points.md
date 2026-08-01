# E14/T06 — Three entry points

| | |
|---|---|
| **Epic** | E14 — The identification key |
| **Branch** | `epic/14-identify` (shared) |
| **Commit** | `feat(identify): reach S7 from Check, the search empty state and browse by shape` |
| **Depends on** | T01 (there must be a screen to route to) |
| **Size** | S |
| **Spec** | `SPEC.md` §4.3 row "Entry points", §6 S1, §6 S5, §6 S6, §14 (the manual reachability check) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `navigation-and-routing` | Three call sites, one route. Route declaration, the typed destination and how a widget test drives a push all live here |
| `lonja-navigation-chrome` | S6's action sits in the app bar — the masthead's chip and action rules, the translated tooltip, and `check_lonja_nav.sh`'s hardcoded-string scan |
| `lonja-buttons` | `Identify this fish` is verbatim in the approved label corpus. Rule 1 decides its variant on each of the three screens; rule 8 requires a `semanticLabel` on the icon-only app-bar action |
| `lonja-lists-and-tables` | S5's empty state is authored by `references/the-four-states.md`, and this task adds an action to it without breaking its one-primary rule |
| `catchlaw-conventions-index` | Rule 9 — route before you edit. Two of the three screens belong to E08 and one to E12; this task changes their wiring, not their design |
| `accessibility-as-code` | Every one of the three actions is labelled and meets the target floor |
| `widget-golden-and-a11y-testing` | The three reachability tests are widget tests, and they are the deliverable |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.3 row "Entry points" | "S7 is reachable from three places (**this was a defect in the first draft**)" — the sentence this task exists to answer |
| `SPEC.md` | §6 S1 | The Check screen's element list: Recents strip, Search species, Browse by shape, **Identify this fish** |
| `SPEC.md` | §6 S5 | The empty state: "no matches → **Identify this fish** and **Browse by shape**, plus a note that the list covers the active jurisdiction only" |
| `SPEC.md` | §6 S6 | "**Identify this fish** action in the app bar" |
| `SPEC.md` | §14 dynamic checklist | "Specifically confirm S7 is reachable from S1, S5's empty state and S6" — a manual device check these tests do not replace |
| `SPEC.md` | §7.1 `family`, `species.taxon_group` | Two different columns at two different granularities — the reason no entry point pre-selects a group |
| `.claude/skills/lonja-buttons/references/button-anatomy.md` | "Label wording", "Icon-only buttons" | `Identify this fish` in the corpus; icon-only requires `semanticLabel` forwarded to `tooltip`, in a 44dp box |
| `.claude/skills/lonja-navigation-chrome/SKILL.md` | rules 4, 6 | Every chrome string through `AppLocalizations`; the mirrored, translated affordance |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Empty" | The empty-state anatomy this task must not break: headline, body, exactly one primary |
| `.claude/skills/catchlaw-conventions-index/SKILL.md` | rule 9, routing table | Which skill owns each of the three surfaces being edited |
| `FLUTTER_GUIDE.md` | §8.1, §6.1 | Widget classes; test naming |
| `epics/DECISIONS.md` | D-3 | `actionIdentifyThisFish` in all six ARB files — reuse whichever key E08 or E12 already created |

## What this delivers

- `app/lib/routing/` — one route for S7, declared once, with a typed destination the three call sites
  share. No screen constructs a `MaterialPageRoute` at its call site.
- The `Identify this fish` action wired on **S1** (E12's Check screen).
- The `Identify this fish` action wired in **S5's empty state** (E08's species search).
- The `Identify this fish` action wired into **S6's app bar** (E08's browse by shape).
- `app/lib/l10n/app_{ar,en,es,gl,ca,pt_BR}.arb` — `actionIdentifyThisFish` and
  `identifyActionTooltip` if E08/E12 have not already added them. Reuse before adding.
- Tests: `app/test/ui/identify/identify_entry_points_test.dart`.

## Why it is built this way

**Three tests, because a missing entry point is how this was lost the first time.** §4.3 records the
defect in the spec itself, and §14 lists the same check as a manual device step. That is a spec saying
the same thing twice, which is what it does when something has already gone wrong once. The three
assertions are the deliverable of this task; everything else is wiring.

**These tests do not discharge the §14 check.** A widget test proves the tap reaches the route. It
does not prove the screen renders on a physical device in airplane mode with the content extracted,
which is what §14's dynamic list asks for and what E21 executes. Both exist on purpose: the widget
test catches the regression on every push, the device check catches what a test harness cannot.

**One route, three call sites.** The three entry points must land on the same route object, not on
three constructions of the same screen. Three constructions would give the auto-disposing view model
three provider scopes to be created in, and a defect fixed at one call site would survive at the other
two — which is the shape of the original defect, not its opposite. Row 4 asserts the single
destination directly.

**No entry point pre-selects a taxon group.** Entering the key from S6, where the user is already
looking at a family grid, invites pre-selecting the group so he skips a couplet. It is rejected for
two reasons. §7.1 models `family` and `species.taxon_group` as different columns at different
granularities, and inferring one from the other is an inference the content does not license — a
family grid position is not a statement about the taxon group. And a pre-selected group makes the
trail's first step invisible: the user never chose it, so "Why am I here?" has an unanswerable first
answer, which is precisely the auditability §5.2 buys by rejecting a classifier.

**S5's empty state gains an action without losing its shape.** §6 S5 already specifies two actions
there — `Identify this fish` and `Browse by shape` — plus the note that the list covers the active
jurisdiction only. `the-four-states.md` allows one primary, so the second action steps down the
ladder exactly as T03's dead end does. Row 5 pins the jurisdiction note, because the cheapest way to
break someone else's screen is to add a widget to it and re-flow what was already there.

**S6's action is icon-only, so it carries a `semanticLabel`.** §6 S6 puts it in the app bar, where
there is no room for a label. `lonja-buttons` rule 8 requires the label anyway and forwards it to
`tooltip`, which is what `IconButton` wires into its own `Semantics` node — so it must not also be
wrapped in a second `Semantics`, which double-announces.

**Rejected: a fourth entry point from S2.** Tempting, because the result screen is where a
misidentification becomes visible. It is not in §4.3's three, and adding one silently would make the
count in the spec wrong in the other direction. If it is wanted, it is a spec change first.

## Tests first

Write every row before touching a production file. Run them. **They must fail.** A row that passes
before the implementation exists is testing nothing — and here that failure mode is real, because two
of these screens already exist and may already build a button that goes nowhere.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `CheckScreen opens the identification key from Identify this fish` | S1 rendered | S7's route pushed | §6 S1's element list; entry point one of three |
| 2 | `SpeciesSearchScreen empty state opens the identification key from Identify this fish` | S5 with a query matching nothing | S7's route pushed | §6 S5's empty state; **this is the one the first draft lost** |
| 3 | `BrowseByShapeScreen opens the identification key from the app bar action` | S6 rendered | S7's route pushed | §6 S6's app-bar action; entry point three of three |
| 4 | `Identify route receives all three Identify this fish actions` | drive all three | the same route path each time | Three constructions of one screen is how a fix at one call site misses two |
| 5 | `SpeciesSearchScreen empty state states the jurisdiction note beside both actions` | S5 empty | headline, note and two actions all present | Adding a widget to someone else's authored state is the cheapest way to break it |
| 6 | `IdentifyScreen opens at the taxon_group entry points from every entry point` | enter from each of the three | `IdentifyEntryPoints`, no group selected | A pre-selected group makes the trail's first answer unanswerable |
| 7 | `BrowseByShapeScreen Identify action carries a translated tooltip` | S6 in `ar` | non-empty `ar` tooltip, one `Semantics` node | Icon-only with no accessible name is silent to TalkBack; a second `Semantics` double-announces |

```dart
// app/test/ui/identify/identify_entry_points_test.dart
import 'package:flutter_test/flutter_test.dart';

import '../../utils/harness.dart';

void main() {
  testWidgets('CheckScreen opens the identification key from Identify this fish', (tester) async {
    final router = await pumpAppAt(tester, const CheckRoute());

    await tester.tap(find.text(enIdentifyThisFish));
    await tester.pumpAndSettle();

    expect(router.currentPath, IdentifyRoute.path);
  });

  testWidgets(
    'SpeciesSearchScreen empty state opens the identification key from Identify this fish',
    (tester) async {
      final router = await pumpAppAt(tester, const SpeciesSearchRoute());
      await tester.enterText(find.byType(LonjaSearchField), 'zzzzz');
      await tester.pumpAndSettle();

      await tester.tap(find.text(enIdentifyThisFish));
      await tester.pumpAndSettle();

      expect(router.currentPath, IdentifyRoute.path);
    },
  );

  testWidgets('BrowseByShapeScreen opens the identification key from the app bar action',
      (tester) async {
    final router = await pumpAppAt(tester, const BrowseByShapeRoute());

    await tester.tap(find.byTooltip(enIdentifyThisFish));
    await tester.pumpAndSettle();

    expect(router.currentPath, IdentifyRoute.path);
  });
}
```

**Run:** `cd app && flutter test test/ui/identify/identify_entry_points_test.dart` → 7 failures. If any
passes now, that test is wrong — and if row 1 or row 3 passes because E08 or E12 already wired a
placeholder, delete the placeholder before writing the real route rather than leaving two.

## Implementation outline

1. Declare S7's route once, beside the routes E12 already declared. One path constant, one typed
   destination.
2. Wire S1's existing `Identify this fish` action to it. If E12 left the action absent, add it in the
   position §6 S1 gives it — after `Browse by shape`, above the tally bar. If E12 left it pointing at
   a placeholder, remove the placeholder in this commit.
3. Wire S5's empty-state action. Do not restructure the state: headline, body, note, then the two
   actions on the ladder.
4. Add S6's app-bar action: `LonjaIconButton` with a required `semanticLabel` from ARB.
5. Reuse `actionIdentifyThisFish` if E08 or E12 already created it. Two ARB keys with the same value
   is a translation bill paid twice and two strings that will drift.
6. Re-run the whole `app/` suite — this task edits three screens that already have tests, and those
   tests are the second half of the safety net.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 7 tests pass, and each failed first.
- [ ] Exactly one route declaration for S7; `grep -rn 'MaterialPageRoute' app/lib/ui/species/
      app/lib/ui/check/` finds no hand-built route to the key.
- [ ] No entry point passes a pre-selected `TaxonGroup`.
- [ ] S5's empty state still carries its headline, its jurisdiction note and exactly one primary.
- [ ] The S6 action carries a non-empty `semanticLabel` in all six locales and is not wrapped in a
      second `Semantics`.
- [ ] No duplicate `actionIdentifyThisFish` key was introduced (D-3).
- [ ] The commit body records that §14's manual airplane-mode confirmation is E21's, not this task's.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh          app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh         app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh           app/lib
tools/gates/no_directional_geometry.sh                                     app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(identify): reach S7 from Check, the search empty state and browse by shape

SPEC §4.3 records that a missing entry point was a defect in the first draft
and §14 lists the same reachability as a manual device check, so it is
asserted here three times — once per screen — rather than trusted. The three
actions land on one route object, because three constructions of the same
screen is exactly the shape that lets a fix at one call site miss the other
two.

No entry point pre-selects a taxon group. SPEC §7.1 models family and
species.taxon_group as different columns at different granularities, so
inferring one from the other is an inference the content does not license —
and a group the user never chose makes the decision trail's first answer
unanswerable, which is the auditability SPEC §5.2 buys by rejecting a
classifier.

These widget tests do not discharge the §14 dynamic check; E21 walks S7 from
all three places on a device in airplane mode.

Task: E14/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
