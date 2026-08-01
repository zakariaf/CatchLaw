# E19/T07 — One-handed reach

| | |
|---|---|
| **Epic** | E19 — Accessibility, sunlight and glove modes |
| **Branch** | `epic/19-accessibility` (shared) |
| **Commit** | `fix(a11y): put every primary action in the bottom third, and prove it` |
| **Depends on** | T01 (the registry and `primaryActionKey`); T02 (`expectMinimumSeparation`) |
| **Size** | S |
| **Spec** | `SPEC.md` §4.9 "One-handed reach" row (*primary actions in the bottom third* — **the one row in §4.9 with no "Done looks like"**), §3 (*achievable with one thumb, in sunlight, wearing wet gloves, in under five seconds*), §6 (every screen's element list) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-buttons` | Rule 1 — exactly one primary per screen — and `references/variant-ladder-and-states.md`'s edge cases, which make **zero** primaries legal and two never |
| `accessibility-as-code` | Rule 9 and its warning that thumb-optimised placement (important controls low and central) actively pessimises linear screen-reader scanning — which is why traversal order is asserted separately in T01 |
| `adaptive-layout` | Rule 8 — `SafeArea`, display cutouts and keyboard insets; the bottom third of a viewport is not the bottom third of a screen with a gesture bar in it |
| `lonja-verdict-and-status` | `references/verdict-anatomy.md`'s vertical order — the action is slot 10, and this task changes where slot 10 is mounted without changing that it is slot 10 |
| `widget-golden-and-a11y-testing` | Rule 1 (pin the device) and rule 8 (computed geometry over blessed pixels) — "bottom third" is a rect comparison, not a picture |
| `catchlaw-conventions-index` | Invariant 2 — a primary action's label names what happens and never what to do with the fish; moving a button must not change its words |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.9, one-handed-reach row | The requirement — *primary actions in the bottom third* — and the fact that its done column is **empty**, which this task fills |
| `SPEC.md` | §3 | The sentence the acceptance condition is derived from: one thumb, in sunlight, wearing wet gloves, under five seconds |
| `SPEC.md` | §6, S1–S23 | Which screens have a primary action at all, and what it is — the registry's `primaryActionKey` comes from here |
| `.claude/skills/lonja-buttons/references/variant-ladder-and-states.md` | "The ladder", "Edge cases" | One primary per screen; zero is correct for a reference or species account; the `FloatingActionButton` ban |
| `.claude/skills/lonja-verdict-and-status/references/verdict-anatomy.md` | "The vertical order — fixed, no exceptions" | Slot 10 is *a single Add to today button*, and the order is a printing order |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "The density set" | `tapGap` 4/8 — the clearance a primary action must keep from the nav strip |
| `.claude/skills/adaptive-layout/SKILL.md` | rule 8 | Read insets through `MediaQuery.paddingOf` / `viewInsetsOf`; the measurable viewport is what the assertion uses |
| `epics/DECISIONS.md` | D-8 | A layout fix uses directional geometry; `EdgeInsets.only(left:` is a grep gate |

## What this delivers

- `app/test/a11y/support/reach_metrics.dart` — `bottomThirdOf(tester)` and
  `expectInBottomThird(...)`, measured against the **viewport**, never against a scroll extent.
- `app/test/a11y/one_handed_reach_test.dart` — the per-surface loop in both densities and at both
  scales, the one-primary rows, and the nav-clearance row.
- A structural change in `app/lib/ui/result/widgets/result_section.dart`: the `Add to today` action
  moves out of the scrolling column into a pinned bottom slot. It is still slot 10 and still the
  last thing in reading order; it is no longer three flicks below the fold.
- Whatever other placements the loop turns out to fail.

## Why it is built this way

**§4.9's one-handed-reach row has an empty "Done looks like" cell — the only row in the table that
does. So this task writes one, and says so.** The condition it writes:

> For every surface that declares a primary action, that action's rect lies **wholly below two
> thirds of the viewport height** at first paint, without scrolling, at text scale 1.0 and 2.0, in
> both densities.

Three parts of that are choices, and each is derived rather than invented. *Wholly below*, not
"centred below", because a 66 dp control whose centre clears the line still has a third of its
target above it. *At first paint, without scrolling*, because §3 gives the whole interaction five
seconds and a scroll to find the action is not in that budget. *In both densities and at 2.0*,
because a bottom-anchored row that a glove and a 200% scale push upward has stopped satisfying the
requirement in exactly the conditions §3 describes.

**The viewport, not the scroll extent.** Measuring the threshold against a scrollable's content
height would make every long screen pass trivially: a 2,000 dp column has a "bottom third" starting
at 1,333 dp, which is off-screen. The helper reads the pinned view size the harness set, and its own
self-test asserts the threshold does not move when the content grows. An audit whose instrument
scales with the thing it is measuring is not an audit.

**S2's action moves out of the scroll, and that is the finding.** `verdict-anatomy.md` fixes the
printed order: stale bar, plate, stamp, table, diagram, citation, disclaimer, **action**. On a
320 × 640 surface that puts `Add to today` two or three flicks below the fold, and §4.9 says primary
actions are in the bottom third. The two are reconcilable because that order is a *printing* order,
not a statement that the sheet scrolls as one piece: a pinned bottom action row is still slot 10 and
still last in reading order, so T01's traversal row (verdict → citation → disclaimer) is unchanged.
**Rejected: leaving it in the flow.** It costs a two-flick scroll with a live fish in the bin, and
it is the single most-used action in the app after the search field.

**One primary, asserted in the tree.** `check_lonja_buttons.sh` check 2 fails a **file** that builds
two primaries, which is the right grep and cannot see the case that actually happens: two widgets in
two files composed onto one route. Row 5 counts primaries in the rendered tree, per surface, which is
where the rule was always about.

**Zero primaries is legal, and a null must not make the loop vacuous.** A reference list or a
species account correctly has none. So `primaryActionKey` being null is a *declaration*, and row 1
asserts the surface really builds none — otherwise a screen with a mis-registered null silently
opts out of every row in this file, which is the same failure mode as an audit registry with a
missing surface.

**Clearance from the nav strip.** The nav is five fixed items along the bottom edge and the primary
action sits directly above it. Without a clearance assertion, "in the bottom third" is satisfied by a
control flush against `Today`, and a gloved thumb aiming at one lands on the other. The floor is
`density.tapGap` — 4 dp standard, 8 dp glove — reusing T02's helper rather than a second
implementation of the same arithmetic.

**Rejected — a `FloatingActionButton` as the reach fix.** It is banned outright: it floats, it
casts, it is round, and this app's surfaces are printed. The bottom action row is the affordance.

**Rejected — asserting reach with a golden.** A blessed picture of a button in the wrong place
passes forever. `getRect` fails with the measured `top` and the threshold in the message.

**Rejected — a "thumb zone" arc or a radial reachability model.** There is no number in `SPEC.md`
for it, deriving one would be inventing a measurement, and §4.9 says "bottom third" in words. The
simplest reading of the requirement is the one that is checkable and the one a reviewer can confirm
by hand.

## Tests first

Write every row before moving a widget. Run them. **They must fail** — S2's action is in the scroll
column, and any screen whose action row sits above a tall body will fail row 4 first. Rows marked
×N are generated over the surfaces whose `primaryActionKey` is non-null; the count is recorded in
the definition of done so a shrinking loop is visible.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `Every surface declaring no primary action builds none` | the surfaces with a null `primaryActionKey` | zero primary-variant widgets in the tree | Zero primaries is legal; a mis-registered null silently exempts a screen from every row below, which is an audit with a hole in it |
| 2 | `bottomThirdOf measures the viewport, not the scroll extent` | a 2,000 dp column in a 640 dp viewport | threshold is 426.7, not 1,333.3 | The instrument's self-test: a threshold that grows with the content passes every long screen for free |
| 3 ×N | `${s.id} ${s.name} places its primary action in the bottom third` | surface, standard, 1.0 | `rect.top ≥ viewport.height × 2 / 3` | The acceptance condition §4.9 does not state, applied where the fisher's thumb actually is |
| 4 ×N | `glove - ${s.id} ${s.name} places its primary action in the bottom third` | surface, glove, 1.0 | same | Glove raises every target and widens every gutter; a row that just cleared the line at 48 dp can be pushed above it at 56 |
| 5 ×N | `${s.id} ${s.name} places its primary action in the bottom third at 200% text` | surface, standard, 2.0 | same | The condition has to hold in the conditions §3 describes, not only at the defaults |
| 6 ×N | `${s.id} ${s.name} builds exactly one primary action` | surface | exactly one primary-variant widget | `lonja-buttons` rule 1, asserted in the tree — `check_lonja_buttons.sh` check 2 is per-file and cannot see two files composing onto one route |
| 7 ×N | `${s.id} ${s.name} clears the bottom navigation by the density's tap gap` | surface, both densities | gap ≥ `density.tapGap` | "In the bottom third" is otherwise satisfied by a control flush against `Today`, and a gloved thumb aiming at one lands on the other |
| 8 | `Result screen reaches Add to today without scrolling` | S2, 320 × 640, standard | the action is on screen at first paint | The finding: `verdict-anatomy.md`'s slot 10 sits below plate, stamp, table, diagram, citation and disclaimer, which is two flicks with a fish in the bin |
| 9 | `Result screen keeps the citation and the disclaimer above the pinned action` | S2 | citation and disclaimer rects are above the action's rect | Pinning the action must not reorder the sheet; slot 10 stays slot 10, and T01's traversal row still holds |

```dart
// app/test/a11y/support/reach_metrics.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The y below which a primary action must sit: two thirds of the VIEWPORT,
/// never of a scrollable's content extent — a threshold that grows with the
/// content passes every long screen for free.
double bottomThirdOf(WidgetTester tester) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio * 2 / 3;

void expectInBottomThird(
  WidgetTester tester, {
  required Finder action,
  required String surfaceId,
}) {
  final double threshold = bottomThirdOf(tester);
  final Rect rect = tester.getRect(action);
  expect(rect.top, greaterThanOrEqualTo(threshold),
      reason: '$surfaceId: the primary action starts at ${rect.top.toStringAsFixed(1)}dp; '
          'the bottom third begins at ${threshold.toStringAsFixed(1)}dp — one thumb '
          'does not reach it (SPEC.md §3, §4.9)');
}
```

```dart
// app/test/a11y/one_handed_reach_test.dart
import 'package:catchlaw/theme/lonja_density.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/a11y/audited_surfaces.dart';
import '../utils/harness.dart';
import 'support/reach_metrics.dart';

void main() {
  final Iterable<AuditedSurface> withPrimary =
      kAuditedSurfaces.where((AuditedSurface s) => s.primaryActionKey != null);

  for (final AuditedSurface surface in withPrimary) {
    for (final LonjaDensity density in <LonjaDensity>[
      LonjaDensity.standard,
      LonjaDensity.glove,
    ]) {
      final String prefix = density == LonjaDensity.glove ? 'glove - ' : '';

      testWidgets('$prefix${surface.id} ${surface.name} places its primary action in '
          'the bottom third', (WidgetTester tester) async {
        tester.useDevice(Device.compact); // 320 x 640 logical
        await surface.pump(tester, A11yAxes(density: density));

        expectInBottomThird(
          tester,
          action: find.byKey(ValueKey<String>(surface.primaryActionKey!)),
          surfaceId: surface.id,
        );
      });
    }
  }

  for (final AuditedSurface surface
      in kAuditedSurfaces.where((AuditedSurface s) => s.primaryActionKey == null)) {
    testWidgets('${surface.id} ${surface.name} builds no primary action',
        (WidgetTester tester) async {
      await surface.pump(tester, const A11yAxes());
      expect(primaryActionsIn(tester), isEmpty,
          reason: '${surface.id} registers no primary action but builds one, so every '
              'reach row skips it');
    });
  }

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/a11y/one_handed_reach_test.dart` → row 8 fails, rows 3–5 fail
on S2 and on any screen whose action row floats above a tall body, and row 2 fails until the helper
exists. If every row passes on the first run, check that `primaryActionKey` is populated: an
all-null registry makes this entire file a no-op that reports success.

## Implementation outline

1. Write `reach_metrics.dart` and row 2 first. Verify the instrument before trusting it.
2. Write the loop. Run. The failures are the work list.
3. S2: move the action out of `result_section.dart`'s scrolling column into a pinned bottom slot
   below the scrollable — `Column(children: [Expanded(child: scrollingSheet), _ActionRow()])`, inside
   the existing `SafeArea`. The printed order is unchanged: the action is still slot 10 and still
   last in reading order. Re-run T01's traversal row (verdict → citation → disclaimer) and E10's own
   panel tests.
4. Any other failing surface: anchor the action row to the bottom of the body rather than letting it
   follow content. Use `Align(alignment: AlignmentDirectional.bottomCenter)` or a bottom slot in the
   scaffold — directional alignment only (D-8).
5. Row 7: reuse T02's `expectMinimumSeparation` against the nav-strip rect. Do not write a second
   gap calculation.
6. Nothing here changes a label. Moving a control must not restate it — the wording is
   `catchlaw-verdict-contract`'s, and `check_lonja_buttons.sh` checks 4 and 5 are the grep.
7. **Re-run T03's matrix.** A pinned footer takes viewport height away from the scrolling body, and
   the 2.0 and 3.0 rungs on S2 are the cases that will notice.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 9 rows pass (3–7 generated), and each failed first.
- [ ] The number of surfaces with a non-null `primaryActionKey` is stated in the commit body, so a
      later shrink of the loop is visible in the history rather than silent.
- [ ] Every one of them places its action wholly below two thirds of the viewport at 1.0 and 2.0, in
      both densities, at first paint and without scrolling.
- [ ] Every surface with a null `primaryActionKey` is proved to build none.
- [ ] Exactly one primary action per surface, asserted in the tree, not only by the per-file grep.
- [ ] S2's action is pinned, and the citation and disclaimer still render above it.
- [ ] T03's matrix re-run and still green; T01's traversal row re-run and still green.
- [ ] No `FloatingActionButton` anywhere (`check_lonja_buttons.sh` check 7).
- [ ] No new `EdgeInsets.only(left:` or `right:` — `no_directional_geometry.sh` clean (D-8).
- [ ] The acceptance condition this task invented is written down in the test file's header comment,
      not only in this task file, because the test outlives the plan.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                app/lib
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh     app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
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
fix(a11y): put every primary action in the bottom third, and prove it

SPEC.md §4.9's one-handed-reach row is the only row in that table with an
empty "done looks like" cell, so this commit writes one: a primary action's
rect lies wholly below two thirds of the VIEWPORT at first paint, without
scrolling, at 1.0 and 2.0 text scale, in both densities. Wholly, because a
control whose centre clears the line still has a third of its target above
it. The viewport rather than the scroll extent, because a threshold that
grows with the content passes every long screen for free.

The finding is S2. verdict-anatomy.md's printing order puts Add to today
below the plate, stamp, table, diagram, citation and disclaimer, which is
two flicks with a live fish in the bin, so it moves to a pinned bottom slot
— still slot 10, still last in reading order, and the citation and
disclaimer are asserted to render above it.

One primary per surface is now counted in the rendered tree.
check_lonja_buttons.sh check 2 fails a file that builds two and cannot see
two files composed onto one route, which is the case that happens.

Task: E19/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
