# E19/T02 — Targets: 48 dp, 56 dp in glove mode, 8 dp apart

| | |
|---|---|
| **Epic** | E19 — Accessibility, sunlight and glove modes |
| **Branch** | `epic/19-accessibility` (shared) |
| **Commit** | `fix(a11y): raise every target to 48 dp, and to 56 dp with 8 dp gaps in glove mode` |
| **Depends on** | T01 (the registry and the pinned-device harness); E07/T04 (`LonjaDensity`); E07/T07 (the button ladder bound to `LonjaTokens.density`) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.9 "Glove mode" row (*all primary targets ≥ 56 dp with ≥ 8 dp separation; result and species tiles pass at 56 dp*), §13 (targets ≥ 48 dp, ≥ 56 dp in glove mode), §3 (one thumb, wet gloves) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-design-tokens` | Rule 11 and `references/three-themes-and-modes.md` — glove mode is a density value set carried on `LonjaTokens.density`, orthogonal to the theme, and `references/token-tables.md` publishes the two rows this task asserts |
| `widget-golden-and-a11y-testing` | Rule 1 (pin the device or the test runs on 800 × 600), rule 8 (computed geometry over goldens), and `references/a11y-guidelines-and-limits.md`'s boundary-skip defect, which is why the `getSize` loop is the gate |
| `accessibility-as-code` | Rule 8 — the 44 px platform floor this product's 48 dp sits above, and the ban on precise-gesture-only affordances |
| `lonja-buttons` | Rule 7 and `references/variant-ladder-and-states.md`'s density table — the component figures this task reconciles against `SPEC.md` §13 |
| `adaptive-layout` | Rule 9 — never assume a fixed cell height; a target that is 48 dp because it was hardcoded to 48 dp is the bug T03 then finds at 200% |
| `testing-strategy` | Rule 11 — 112 geometry tests is a real cost, and the reduction lever is named before it is needed |
| `catchlaw-conventions-index` | `references/routing-table.md` seam: *a 56 dp glove target* is owned by `lonja-design-tokens` (the value) and `accessibility-as-code` (the floor it clears) — this task invents neither |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.9, glove-mode row | The requirement and its done condition, including the two surfaces it names by hand: result and species tiles |
| `SPEC.md` | §13, accessibility row | `targets ≥ 48 dp (≥ 56 dp glove mode)` — the standard-density floor, which §4.9 does not restate |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "The density set (glove mode)" | `standard` = tapMin 48, tapGap 4, rowHeight 56, hitSlop 0; `glove` = 56, 8, 72, 4 — and the note that the 44 dp platform floor belongs to `accessibility-as-code` |
| `.claude/skills/lonja-design-tokens/references/three-themes-and-modes.md` | "Glove mode is density, not a theme" | Why density and theme vary independently, and why density never changes a colour |
| `.claude/skills/lonja-buttons/references/variant-ladder-and-states.md` | "Density: glove mode" | The component figures — 56/66 regular, 46 compact, 44 icon-only — and the sentence *"deliberate over-provision against the 56dp product floor"* |
| `.claude/skills/widget-golden-and-a11y-testing/references/a11y-guidelines-and-limits.md` | "The four built-in guidelines", defect (a); "Tap targets: an explicit getSize loop" | The boundary skip, and the worked `getSize` loop this task generalises |
| `epics/E07-lonja-theme/epic.md` | Risks, item 1 | The 44/46/66 clash and the resolution already applied at E07/T07 — cited, not re-argued |
| `epics/DECISIONS.md` | D-1, D-8 | Gate invocation with an explicit target directory; directional geometry is a grep gate |

## What this delivers

- `app/test/a11y/support/target_metrics.dart` — `targetRectsOf(tester, surface)`,
  `expectMinimumTargetSize(...)` and `expectMinimumSeparation(...)`, the last of which pairs
  rectangles and ignores containment. Helpers, not `*_test.dart`.
- `app/test/a11y/tap_targets_test.dart` — the per-surface loop in both densities, plus the two
  component rows and the advisory tripwire.
- Whatever geometry fixes the loop turns out to require inside `app/lib/ui/` and
  `app/lib/ui/core/ui/`. The known candidates are named below; the set is not knowable in advance.

## Why it is built this way

**Measured with `getSize`, not with `meetsGuideline`.** `MinimumTapTargetGuideline` returns
`Evaluation.pass()` **without measuring** for any node within 0.001 of the view edge on all four
sides, and skips any node that is a link, hidden, or has neither a tap nor a long-press action. On an
edge-to-edge layout — which is every screen here, because the nav strip and the action row both
reach the bottom edge — that skip removes exactly the controls the fisher's thumb is aiming at. The
guideline stays as a one-line advisory tripwire on the six core surfaces, run with `await
expectLater` because it is an `AsyncMatcher`; the gate is an explicit loop over `targetKeys`.

**Both densities, because glove mode is orthogonal.** `three-themes-and-modes.md` is explicit that
theme answers *what light am I in* and density answers *what is my hand like*, and that they vary
independently. A gloved hand at night is common on a boat. So the loop is surface × density, not
surface × theme: density is the axis that changes geometry, and geometry is what this task asserts.
Colour is T04's axis and it never moves a rectangle.

**Separation is asserted, not assumed, and it is the harder half.** A 56 dp target with 2 dp of
clearance is a mis-tap waiting for a wet finger, and the token set carries `tapGap` precisely because
*"separation is what prevents the adjacent-target mis-tap"*. The helper pairs every two target rects
on the surface and, where they overlap on one axis, requires the gap on the other to clear
`density.tapGap` — 4 dp standard, 8 dp glove. Where one rect **contains** another it is skipped: a
tappable species row containing a tappable quick-add button has zero gap by construction and is not
a defect. That skip is itself a test row, because a helper that flags a legitimate nesting produces
noise, and a noisy audit is an audit somebody deletes.

**48 dp is the floor for this product, and 44 dp is not.** `accessibility-as-code` rule 8 sets a
44 × 44 platform floor; `token-tables.md` says in as many words that *"Lonja's 48/56 sits above it
deliberately and does not replace it"*; `SPEC.md` §13 says 48. Where a component still measures 44
or 46 — `variant-ladder-and-states.md` publishes an icon-only box of 44 × 44 and a compact action of
46 dp — it fails these rows and is raised to 48. **This is not a re-opened decision:** E07's Risks
record the same clash and E07/T07 resolved it for the button widget by binding it to
`LonjaTokens.density`. What this task adds is the sweep E07 could not run, because in E07 there were
no screens to sweep. Correcting the 44/46 figures in the skill's own reference is a follow-up named
in the epic, not work in this commit.

**The two token rows are duplicated on purpose.** E07 already asserts `LonjaDensity.glove` reports
`tapMin 56` and `tapGap 8` from the token side. These rows assert the same two numbers from the
consumer side, because they are the multiplier on 112 geometry assertions: lower `tapMin` to 44 and
every row below goes green while the product gets worse. `/simplify` will offer to delete them —
keep them, and keep the reason column that says why.

**Rejected — `MinimumTapTargetGuideline(size: Size(56, 56))` reconfigured for the glove lane.** The
constructor is public and `@visibleForTesting`, so this is tempting and cheap. It inherits the
boundary skip, which means it would silently not measure the nav strip or the bottom action row —
the two things glove mode exists for. Reconfiguring a guideline that skips the perimeter is a
green test over the perimeter.

**Rejected — a golden of each screen in glove mode as the proof.** A golden cannot assert anything;
it asserts that these pixels equal the pixels somebody blessed. Bless a 44 dp button once and it
passes forever. `getSize` fails with a sentence naming the control and its measurement.

**Rejected — inferring glove mode from screen width.** `lonja-buttons` rule 7 and its worked example
both name this: `MediaQuery.sizeOf(context).width < 400` is a phone in a pocket, not a glove. Density
is read from `LonjaTokens.density`, which the user sets in S14.

## Tests first

Write every row before touching a widget. Run them. **They must fail** — several will fail on the
44 dp icon box and the nav strip's separation before they fail anywhere interesting. Rows marked
×28 or ×6 are loop-generated and interpolate the surface into the description.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `LonjaDensity.standard reports tapMin 48 and tapGap 4` | the token | 48, 4 | These two numbers multiply 112 assertions below; lowering the token is the cheapest way to make all of them pass falsely |
| 2 | `LonjaDensity.glove reports tapMin 56 and tapGap 8` | the token | 56, 8 | `SPEC.md` §4.9's glove row, stated once as a number the loop reads rather than a literal it repeats |
| 3 ×28 | `${s.id} ${s.name} sizes every target at 48 dp or more` | surface, standard density, 320 dp | every registered target ≥ 48 × 48 | `SPEC.md` §13's standard-density floor, on the surface where it is actually rendered rather than on the component in isolation |
| 4 ×28 | `glove - ${s.id} ${s.name} sizes every target at 56 dp or more` | surface, glove density | every registered target ≥ 56 × 56 | §4.9's glove row. A screen that reads `LonjaTokens.density` in some places and a literal in others passes row 3 and fails this one |
| 5 ×28 | `${s.id} ${s.name} separates adjacent targets by 4 dp or more` | surface, standard | every non-nested pair clears `tapGap` | Size without separation is two adjacent 48 dp targets and one mis-tap |
| 6 ×28 | `glove - ${s.id} ${s.name} separates adjacent targets by 8 dp or more` | surface, glove | every non-nested pair clears 8 dp | The literal words of §4.9: *≥ 56 dp with ≥ 8 dp separation* |
| 7 ×6 | `${s.id} ${s.name} keeps every target at 48 dp with 200% text` | core surface, `TextScaler.linear(2.0)` | every target still ≥ 48 × 48 | A `Row` of chips that fits at 1.0 squeezes a sibling below the floor at 2.0 — the interaction T03's overflow net cannot see, because nothing overflowed |
| 8 ×6 | `glove - ${s.id} ${s.name} keeps every target at 56 dp with 200% text` | core surface, glove, 2.0 | every target still ≥ 56 × 56 | The worst case the product actually ships: big hands, big text, small phone |
| 9 | `LonjaIconButton renders a 48 dp box in standard density` | one icon button | ≥ 48 × 48 | `variant-ladder-and-states.md` publishes 44 × 44; `SPEC.md` §13 says 48. This row is the one that fails first, and it fails on purpose |
| 10 | `glove - LonjaIconButton renders a 56 dp box` | same, glove | ≥ 56 × 56 | The same control on the same screen with a glove on |
| 11 | `LonjaButton compact renders at 48 dp or more` | a compact action | ≥ 48 dp tall | The published compact height is 46 dp — two below the product floor, and invisible to every eye that has read the component spec |
| 12 | `Species row measures 56 dp or more` | a species tile, standard | height ≥ `rowHeight` 56 | §4.9 names *"result and species tiles"* by hand as the done condition; the tile is the most-tapped control in the app |
| 13 | `glove - Species row measures 72 dp or more` | a species tile, glove | height ≥ `rowHeight` 72 | `token-tables.md`'s glove `rowHeight`; a row that ignores density is one-thumb scannable only with bare hands |
| 14 | `expectMinimumSeparation ignores a target nested inside another` | a tappable row containing a tappable button | passes | The instrument's own self-test: a helper that flags a legitimate nesting produces noise, and a noisy audit gets deleted |
| 15 | `expectMinimumSeparation fails two targets 6 dp apart in glove mode` | two rects, 6 dp gap | fails with both keys named | The other half of the self-test: an assertion that cannot fail is not an assertion |
| 16 ×6 | `${s.id} ${s.name} meets the built-in tap-target guidelines (advisory)` | core surface, 2.0 scale | `androidTapTargetGuideline` and `iOSTapTargetGuideline` pass | A catastrophic-regression tripwire. It skips every node flush with the view edge, which is why rows 3–8 exist and this one is labelled advisory in its own name |

```dart
// app/test/a11y/support/target_metrics.dart
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/a11y/audited_surfaces.dart';

Map<String, Rect> targetRectsOf(WidgetTester tester, AuditedSurface surface) => <String, Rect>{
      for (final String key in surface.targetKeys)
        key: tester.getRect(find.byKey(ValueKey<String>(key))),
    };

void expectMinimumTargetSize(Map<String, Rect> targets, double floor, String surfaceId) {
  targets.forEach((String key, Rect rect) {
    expect(rect.width, greaterThanOrEqualTo(floor),
        reason: '$surfaceId "$key" is ${rect.width}dp wide; the floor is ${floor}dp');
    expect(rect.height, greaterThanOrEqualTo(floor),
        reason: '$surfaceId "$key" is ${rect.height}dp tall; the floor is ${floor}dp');
  });
}

/// Pairs every two targets and requires [gap] between them on the axis they do
/// not overlap on. A rect wholly containing another is skipped: a tappable row
/// with a tappable button inside it has no gap by construction.
void expectMinimumSeparation(Map<String, Rect> targets, double gap, String surfaceId) {
  final List<MapEntry<String, Rect>> entries = targets.entries.toList();
  for (int i = 0; i < entries.length; i++) {
    for (int j = i + 1; j < entries.length; j++) {
      final Rect a = entries[i].value;
      final Rect b = entries[j].value;
      if (a.contains(b.topLeft) && a.contains(b.bottomRight)) continue;
      if (b.contains(a.topLeft) && b.contains(a.bottomRight)) continue;

      final double horizontal = a.left < b.left ? b.left - a.right : a.left - b.right;
      final double vertical = a.top < b.top ? b.top - a.bottom : a.top - b.bottom;
      expect(horizontal >= gap || vertical >= gap, isTrue,
          reason: '$surfaceId "${entries[i].key}" and "${entries[j].key}" are '
              '${horizontal.clamp(0, double.infinity)}dp / '
              '${vertical.clamp(0, double.infinity)}dp apart; the floor is ${gap}dp');
    }
  }
}
```

```dart
// app/test/a11y/tap_targets_test.dart
import 'package:catchlaw/theme/lonja_density.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/a11y/audited_surfaces.dart';
import '../utils/harness.dart';
import 'support/target_metrics.dart';

void main() {
  test('LonjaDensity.glove reports tapMin 56 and tapGap 8', () {
    expect(LonjaDensity.glove.tapMin, 56.0);
    expect(LonjaDensity.glove.tapGap, 8.0);
  });

  for (final AuditedSurface surface in kAuditedSurfaces) {
    for (final LonjaDensity density in <LonjaDensity>[
      LonjaDensity.standard,
      LonjaDensity.glove,
    ]) {
      final String prefix = density == LonjaDensity.glove ? 'glove - ' : '';

      testWidgets(
          '$prefix${surface.id} ${surface.name} sizes every target at '
          '${density.tapMin.toInt()} dp or more', (WidgetTester tester) async {
        tester.useDevice(Device.compact); // 320 x 640 logical — the tightest surface
        await surface.pump(tester, A11yAxes(density: density));

        expectMinimumTargetSize(
            targetRectsOf(tester, surface), density.tapMin, surface.id);
      });

      testWidgets(
          '$prefix${surface.id} ${surface.name} separates adjacent targets by '
          '${density.tapGap.toInt()} dp or more', (WidgetTester tester) async {
        tester.useDevice(Device.compact);
        await surface.pump(tester, A11yAxes(density: density));

        expectMinimumSeparation(
            targetRectsOf(tester, surface), density.tapGap, surface.id);
      });
    }
  }

  for (final String id in kCoreLoopSurfaces) {
    final AuditedSurface surface =
        kAuditedSurfaces.firstWhere((AuditedSurface s) => s.id == id);

    testWidgets('${surface.id} ${surface.name} meets the built-in tap-target '
        'guidelines (advisory)', (WidgetTester tester) async {
      tester.useDevice(Device.compact);
      await surface.pump(tester, const A11yAxes(textScaler: TextScaler.linear(2.0)));

      // AsyncMatcher — a bare expect() here looks right and asserts nothing.
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    });
  }

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/a11y/tap_targets_test.dart` → 128 failures, concentrated on
the icon-only boxes and on wherever the nav strip meets the action row. If a glove row passes before
a single widget changes, check that `A11yAxes.density` actually reaches `LonjaTokens.density` in
`pumpLonja` — a density that never arrives makes every glove row a duplicate of its standard twin.

## Implementation outline

1. Write `target_metrics.dart` and its two self-test rows (14, 15) first. The instrument is verified
   before it is trusted; this is the same argument as E01/T08's for the gate scripts.
2. Write `tap_targets_test.dart` in full. Run. Record which surfaces fail and on which row — the
   failure list is the work list, in registry order.
3. Fix size failures at the component, never at the call site. An icon button that measures 44 dp is
   fixed once in `app/lib/ui/core/ui/`, where `BoxConstraints.tightFor` reads
   `LonjaTokens.of(context).density.tapMin`; fixing it per screen mints a new value per screen and
   `check_lonja_tokens.sh` check 5 fails the numeric literal anyway.
4. Fix separation failures with a `LonjaSpace` step, never with a literal gap. `s1` is 4 and `s2` is
   8 — the two `tapGap` values are already on the spine, which is not a coincidence.
5. Where a fix needs padding, use `EdgeInsetsDirectional` or the symmetric constructors.
   `EdgeInsets.only(left:` is banned by `tools/gates/no_directional_geometry.sh` (D-8), and a
   physical inset is invisible in review and wrong in `ar`.
6. Re-run rows 7 and 8. A fix that satisfies the 1.0 rows and fails the 2.0 rows means a fixed-height
   box was widened rather than made flexible — hand that to T03 rather than clamping the text here.
7. Re-run the whole `app` suite: E08–E18's own layout tests hold rects that this task moved.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 16 rows pass (3–8 and 16 generated), and each failed first.
- [ ] Every registered target on all 28 surfaces measures ≥ 48 dp standard and ≥ 56 dp glove, with
      ≥ 4 dp and ≥ 8 dp separation, at scale 1.0; the six core surfaces hold at 2.0 as well.
- [ ] No target floor is a numeric literal anywhere in `app/lib/` — every one resolves through
      `LonjaTokens.of(context).density` (`check_lonja_tokens.sh` check 5 is the grep behind this).
- [ ] No new `EdgeInsets.only(left:` or `right:` — `no_directional_geometry.sh` clean (D-8).
- [ ] The advisory guideline rows say "advisory" in their own names, and nothing in this task's
      commit body claims they are the gate.
- [ ] `LonjaDensity` itself is unchanged — this task moves widgets, not tokens.
- [ ] Nothing under `packages/rule_engine/` changed.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh           app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                app/lib
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
fix(a11y): raise every target to 48 dp, and to 56 dp with 8 dp gaps in glove mode

Measured with getSize over the registry rather than with
androidTapTargetGuideline, which returns pass() without measuring for any
node within 0.001 of the view edge — on an edge-to-edge layout that skips
the nav strip and the bottom action row, which are the two things a gloved
thumb is aiming at. The guideline stays as an advisory tripwire on the six
core surfaces.

Separation is the harder half and is asserted per pair, skipping a rect that
wholly contains another so a tappable row with a button inside it is not
reported as a 0 dp gap. Where a component still measured 44 or 46 dp it is
raised to the SPEC.md §13 floor of 48 by binding it to
LonjaTokens.density — the resolution E07/T07 already applied to the button
ladder, now swept across all 28 surfaces.

Task: E19/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
