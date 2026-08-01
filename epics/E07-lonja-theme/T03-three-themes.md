# E07/T03 — Three themes: paper, night and sunlight

| | |
|---|---|
| **Epic** | E07 — Lonja design system foundation |
| **Branch** | `epic/07-lonja-theme` (shared) |
| **Commit** | `feat(theme): hand-author the paper, night and sunlight palettes and their ThemeData builders` |
| **Depends on** | T02 (the slots must exist before anything can bind them) |
| **Size** | L |
| **Spec** | `SPEC.md` §11 "Both" (dark mode supported; **sunlight mode is a third theme**, not a variant of either), §4.9 (sunlight mode: maximum contrast, monochrome plus result colour), §13 (contrast ≥ 4.5:1, **≥ 7:1 in sunlight mode**) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-design-tokens` | Owns all three palettes. Rule 8 states the sunlight authoring law — every grey deleted, `surfaceSunk` equal to `surface`, one colour surviving — and rule 10 requires a measured contrast row for every slot in all three themes |
| `design-system-structure` | Owns hand-authored `ColorScheme` construction and attaching an extension to a `ThemeData`. Used, not restated (`catchlaw-conventions-index` rule 10) |
| `accessibility-as-code` | Owns the contrast floors these measurements are checked against — 4.5:1 text, 3:1 non-text — and the fact that Lonja's numbers must clear them rather than replace them |
| `catchlaw-conventions-index` | Invariant 4: colour is never the only signal. Sunlight is the theme that makes that concrete, because it deletes every hue except the verdict |
| `flutter-performance` | Why all three palettes are `const`: three const palettes cost nothing and make six golden lanes cheap |
| `testing-strategy` | Unit level for the palettes, one widget test for the `MaterialApp` wiring; no goldens here — T08 owns those |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "Tier 2 — the thirteen semantic slots" | The 39 bindings: every slot in paper, night and sunlight |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | The three "Measured contrast" tables | Every ratio this task asserts, against both `surface` and `surfaceSunk`, with each slot's floor and the note that `onSurfaceFaint` is never a fact and `ochre47` is a mark only |
| `.claude/skills/lonja-design-tokens/references/three-themes-and-modes.md` | "Why sunlight is a palette, not an inversion" | The arithmetic on the tempting one-liner, and the rule that a widget relying on `surfaceSunk` must also carry a rule because in sunlight the stock change does not exist |
| `.claude/skills/lonja-design-tokens/references/three-themes-and-modes.md` | "Authoring or changing a theme" | The five steps: all thirteen slots explicit, bound to primitives, contrast rows filled, density carried, golden lane refreshed |
| `.claude/skills/lonja-design-tokens/SKILL.md` | Rules 8, 9, 10 | Sunlight is not an inversion; `harbour` is chrome and the three semantic pigments are meaning, framed and never filled; every slot ships a measured contrast row in all three themes |
| `.claude/skills/lonja-design-tokens/examples/lonja_theme.dart` | `LonjaPalettes` and `LonjaTheme._build` | The worked shape: every slot written out, no `copyWith` chain, a hand-authored `ColorScheme`, `extensions: <ThemeExtension<dynamic>>[t]` |
| `SPEC.md` | §11 "Both" | "Dark mode supported; **sunlight mode is a third theme**, not a variant of either" — the sentence this task implements |
| `SPEC.md` | §13, accessibility row | "Contrast ≥ 4.5:1 (≥ 7:1 in sunlight mode)" — the sunlight floor is the product's, not the WCAG minimum |
| `SPEC.md` | §4.9, sunlight row | "A third theme (not a dark-mode variant): maximum contrast, monochrome plus result colour. Toggle in S14 and by long-press on the result" |
| `FLUTTER_GUIDE.md` | §8.2 | `const` — three const palettes and what that buys |
| `epics/DECISIONS.md` | D-2 | Why `app/lib/theme/lonja_theme.dart` and not `app/lib/ui/core/themes/` |

## What this delivers

- `app/lib/theme/lonja_theme.dart`:
  - `abstract final class LonjaPalettes` — `paper`, `night`, `sunlight`, each a `const LonjaTokens`
    with **all thirteen slots written out** and bound to a `LonjaPrimitives` constant. No palette is
    derived from another.
  - `abstract final class LonjaTheme` — `paper()`, `night()`, `sunlight()`, each returning a
    `ThemeData` carrying its palette as a `LonjaTokens` extension, a hand-authored `ColorScheme`,
    `scaffoldBackgroundColor` from the `surface` slot and a fully transparent `shadowColor`.
- `app/lib/main.dart` — the E01 skeleton's `ThemeData` is removed and replaced with
  `theme: LonjaTheme.paper()`, `darkTheme: LonjaTheme.night()`, `themeMode: ThemeMode.system`.
  That is §11's "dark mode supported": the platform chooses between the two brightnesses.
- `app/testing/theme/palette_table.dart` — `kPaletteTable`, the 39 expected bindings transcribed
  from `token-tables.md` as `(theme, slot, primitiveName, Color)` rows, plus `kSlotReaders`, the
  thirteen `Color Function(LonjaTokens)` accessors the cross-palette comparisons iterate.
- `app/testing/theme/contrast_table.dart` — `kContrastTable`, the three measured contrast tables
  transcribed as `(theme, slot, vsSurface, vsSurfaceSunk, floor)` rows, with `floor` nullable for
  the two ornament hairlines.
- `app/test/theme/lonja_palettes_test.dart`, `app/test/theme/lonja_contrast_test.dart`,
  `app/test/theme/lonja_theme_test.dart`.

**Not** delivered here: the sunlight *selector*. §4.9 puts it in S14 (E16) and on a long-press on the
result (E10). This task ships the palette, the builder and the proof; the two controls that reach it
are later epics, and nothing here invents settings plumbing to compensate.

## Why it is built this way

**Sunlight is authored, not derived, and the arithmetic is the reason.** The tempting one-liner —
`paper.copyWith(surface: white100, onSurface: black00)` — leaves `onSurfaceMuted` at `ink30`
(9.29:1 on white, fine on a desk), `onSurfaceFaint` at `ink49` (4.60:1, gone in the sun), `hairline`
at `paper79` (1.75:1, gone indoors too) and `accent` at `harbour30`, a blue that reads as grey
outdoors. Every one of those is a measured pass on a bench and a failure in the hand. At roughly
100,000 lux through a salt-hazed screen the *middle* of the tonal range disappears first, so sunlight
deletes the middle rather than compressing it: seven neutral slots collapse to `black00`,
`surfaceSunk` collapses into `surface` because white paper has no second stock, and `accent` gives up
`harbour` because chrome colour is the first thing to spend. What survives is the verdict — the only
chroma in the build, and therefore unmistakably the answer.

This is also why sunlight is not "high contrast mode": high contrast raises ratios, sunlight removes
tonal steps. The consequence lands on every later epic and is stated here so it is not rediscovered:
a widget that relies on `surfaceSunk` to mark a block must **also** carry a rule, because in sunlight
the stock change does not exist. T06 is where that becomes a widget test.

**Every ratio is computed, not copied.** `lonja-design-tokens` rule 10 requires a measured contrast
row per slot per theme, and `token-tables.md` publishes 33 of them. This task re-derives all 33 from
the WCAG relative-luminance formula in T01's `colour_math.dart` and compares them with the published
figures to two decimal places, then checks each against its own floor. The floors are not uniform and
must not be flattened: `onSurfaceFaint` measures **3.62:1** on paper, which is legal at 19 sp and
above and **never carries a fact** — no measurement, no citation, no date; `ochre47` measures
**3.97:1**, which clears the non-text floor for a frame and a glyph and fails 4.5:1 as text, which is
exactly why a verdict stamp is framed and never filled. A blanket `expect(ratio, greaterThan(4.5))`
would fail on two legitimate rows and would teach the next author to relax the assertion.

**The sunlight floor is 7:1 and it is the product's, not WCAG's.** `SPEC.md` §13 says "≥ 7:1 in
sunlight mode". Every sunlight slot clears it: the neutrals at 21.00, `verdant36` at 7.56,
`oxblood28` at 10.05 and `ochre38` at 7.07. `ochre38` exists solely because paper's `ochre47`
measures 5.06:1 on white — a WCAG AA pass that misses the product's sunlight floor by two points.

**A hand-authored `ColorScheme`, never `ColorScheme.fromSeed`.** A seed generates thirty tonal values
nobody measured, none of which appear in any contrast table, and it silently overrides the slots
above it. The test asserts `colorScheme.primary` is **exactly** the `accent` slot — an equality a
seed can never satisfy by accident. `ColorScheme` is still populated because Material widgets read it
underneath us; it is a shim over the slots, not a second source of truth.

**Three palettes cost nothing.** They are `const`, so three palettes and six renderings (with T04's
density axis) are cheap, and the golden matrix stays at six lanes. That is the argument that keeps
glove mode out of the theme enum in T04.

**Rejected: generating the sunlight palette from paper with a "maximise contrast" transform.** It is
one function instead of thirteen lines, and it regenerates the mid-greys that vanish at noon — the
precise failure sunlight exists to prevent. Also rejected: expressing sunlight as a `ThemeMode`.
`ThemeMode` has three values and one of them is `system`; sunlight is neither light nor dark nor a
platform signal. T04's `LonjaSkin` is the enum that has room for it.

## Tests first

Write every row before touching `lonja_theme.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | loop × 39 — `LonjaPalettes.<theme> binds <slot> to <primitive>` | each `kPaletteTable` row | exact colour equality | The thirteen-slot contract, per theme. A slot bound to the wrong pigment is invisible until someone reads that screen in that theme |
| 2 | loop × 33 — `LonjaPalettes.<theme> renders <slot> at <ratio>:1 on its surface` | each `kContrastTable` row | `± 0.005` | The published measurement and the code must be one thing; a nudged hex changes a ratio silently |
| 3 | loop × 29 — `LonjaPalettes.<theme> clears the <floor>:1 floor for <slot>` | rows with a floor | `>= floor` | The floors differ per slot; flattening them to 4.5 would fail two legitimate rows and invite the assertion to be relaxed |
| 4 | `LonjaPalettes.paper renders onSurfaceFaint at 3.62:1, below the text floor` | `onSurfaceFaint` | `closeTo(3.62, 0.005)`, `lessThan(4.5)` | This is a *documented* sub-floor value. Asserting it explicitly stops a later author "fixing" the pigment and breaking the 19 sp-and-above rule it is built for |
| 5 | `LonjaPalettes.paper renders verdictWarn at 3.97:1, a mark-only value` | `ochre47` | `closeTo(3.97, 0.005)`, `lessThan(4.5)` | The reason the verdict stamp is framed and never filled; if this ever clears 4.5 someone changed the pigment |
| 6 | `sunlight - every LonjaPalettes.sunlight slot clears 7:1 against the surface` | the 11 measurable slots — the thirteen less `surface` and `surfaceSunk`, which are the ground | `>= 7.0` | `SPEC.md` §13's sunlight line, as one assertion per slot |
| 7 | `sunlight - LonjaPalettes.sunlight binds every neutral slot to black00` | 7 slots | `black00` | Rule 8. This is the assertion a `copyWith`-derived sunlight fails first |
| 8 | `sunlight - LonjaPalettes.sunlight binds surfaceSunk to surface` | — | `white100 == white100` | White paper has no second stock; the consequence for every panel is T06's |
| 9 | `sunlight - LonjaPalettes.sunlight shares exactly two slot values with LonjaPalettes.paper` | the 13 pairs | `verdictPass`, `verdictFail` only | The sharpest available proof that sunlight is not derived: a `copyWith` sunlight would share six neutrals and both hairlines |
| 10 | `sunlight - LonjaPalettes.sunlight holds exactly three chromatic values` | distinct slot values that are neither `white100` nor `black00` | 3 | "Exactly one colour survives — the verdict", counted |
| 11 | `LonjaPalettes.night shares no slot value with LonjaPalettes.paper` | the 13 pairs | none equal | Night is hand-authored too; a shared value means a slot was copied rather than chosen |
| 12 | loop × 3 — `LonjaTheme.<theme>() attaches its palette as a LonjaTokens extension` | each builder | `extension<LonjaTokens>()` identical to the palette | Without this the asserting `of(context)` from T02 throws on every screen |
| 13 | loop × 3 — `LonjaTheme.<theme>() paints the scaffold with the surface slot` | each builder | `scaffoldBackgroundColor == surface` | The ground the whole document sits on; Material's default is not one of our three |
| 14 | loop × 3 — `LonjaTheme.<theme>() binds colorScheme.primary to the accent slot` | each builder | exact equality | The `fromSeed` guard: a generated scheme cannot reproduce `harbour30` exactly |
| 15 | loop × 3 — `LonjaTheme.<theme>() binds colorScheme.error to the verdictFail slot` | each builder | exact equality | Material error surfaces underneath us must not introduce a fourth red |
| 16 | loop × 3 — `LonjaTheme.<theme>() sets a fully transparent shadowColor` | each builder | alpha `0` | Paper does not float, and the cheapest way a shadow appears is a Material default nobody overrode |
| 17 | `LonjaTheme.night() reports Brightness.dark` | — | `Brightness.dark` | Platform chrome, cursor colour and system overlays read this |
| 18 | `LonjaTheme.sunlight() reports Brightness.light` | — | `Brightness.light` | Sunlight is a *light* theme with a white ground; reporting dark would invert the system UI over it |
| 19 | `CatchlawApp paints the paper surface when the platform brightness is light` | `MaterialApp` under light | `paper90` | §11's dark-mode support, proved at the wiring rather than in prose |
| 20 | `CatchlawApp paints the night surface when the platform brightness is dark` | under dark | `ink07` | The other half of the same wiring |

```dart
// app/test/theme/lonja_contrast_test.dart
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/colour_math.dart';
import '../../testing/theme/contrast_table.dart';

void main() {
  group('LonjaPalettes', () {
    for (final ContrastRow row in kContrastTable) {
      test('.${row.theme} renders ${row.slot} at ${row.vsSurface}:1 on its surface', () {
        expect(contrastRatio(row.colour, row.surface), closeTo(row.vsSurface, 0.005));
      });

      final double? floor = row.floor;
      if (floor != null) {
        test('.${row.theme} clears the $floor:1 floor for ${row.slot}', () {
          expect(contrastRatio(row.colour, row.surface), greaterThanOrEqualTo(floor));
        });
      }
    }

    test('sunlight - LonjaPalettes.sunlight shares exactly two slot values with '
        'LonjaPalettes.paper', () {
      final int shared = kSlotReaders
          .where((Color Function(LonjaTokens) read) =>
              read(LonjaPalettes.sunlight) == read(LonjaPalettes.paper))
          .length;
      expect(shared, 2); // verdictPass and verdictFail, and nothing else
    });
  });
}
```

```dart
// app/test/theme/lonja_theme_test.dart
import 'package:catchlaw/theme/lonja_primitives.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LonjaTheme', () {
    test('.sunlight() reports Brightness.light', () {
      expect(LonjaTheme.sunlight().brightness, Brightness.light);
    });

    test('.paper() binds colorScheme.primary to the accent slot', () {
      final ThemeData theme = LonjaTheme.paper();
      expect(theme.colorScheme.primary, LonjaPrimitives.harbour30);
      expect(theme.extension<LonjaTokens>()!.accent, theme.colorScheme.primary);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/theme/` → 20 named rows, of which nine are loops (39, 33, 29,
11 and five of 3), so 138 failures: 127 loop-generated plus 11 single. If any passes before
`lonja_theme.dart` exists, the test is wrong.

## Implementation outline

1. `app/testing/theme/palette_table.dart` and `contrast_table.dart` first, both transcribed by hand
   from `token-tables.md`. Transcribe the ratios to two decimals exactly as published; do not round
   or "correct" one — a mismatch is a finding, not a typo to smooth over.
2. `LonjaPalettes.paper`, then `.night`, then `.sunlight`, each `const`, each with all thirteen
   slots written out in the token table's order, each bound to a `LonjaPrimitives` constant and
   never to a hex. Carry `density: LonjaDensity.standard`; a palette without a density is a compile
   error, not a default.
3. Comment each slot with its measured ratio, as the worked example does. The comment is a pointer
   to the test, not a substitute for it.
4. `LonjaTheme._build(LonjaTokens palette, Brightness brightness)` returning `ThemeData` with the
   hand-authored `ColorScheme` (`primary`/`onPrimary` from `accent`/`onAccent`,
   `secondary`/`onSecondary` from `ruleBearing`/`surface`, `error`/`onError` from
   `verdictFail`/`surface`, `surface`/`onSurface` from the matching slots),
   `scaffoldBackgroundColor`, a fully transparent `shadowColor`, and
   `extensions: <ThemeExtension<dynamic>>[palette]`. Component themes — divider, card, dialog,
   sheet, snackbar — are T06's; do not pre-empt them here.
5. Three public builders delegating to `_build`. `night` passes `Brightness.dark`; `paper` and
   `sunlight` pass `Brightness.light`.
6. If `flutter analyze` reports `useMaterial3` deprecated on the pinned 3.44.6 SDK, omit it: M3 is
   the default and a clean analyze is a hard condition (`CONVENTIONS.md` §8).
7. `app/lib/main.dart`: delete the skeleton's `ThemeData`, wire `theme`, `darkTheme` and
   `themeMode: ThemeMode.system`. Nothing is awaited before `runApp`
   (`catchlaw-conventions-index` rule 8) — this change adds no `await`.
8. Re-run the suite, then `check_lonja_tokens.sh app/lib`: check 1 should now find nothing, because
   the last `Colors.*` in the app left with the skeleton's theme.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 20 named tests pass, including the five loops, and each failed first.
- [ ] All 39 bindings match `token-tables.md`; all 33 ratios match to two decimal places.
- [ ] Every sunlight slot clears 7:1 (§13); the seven neutral slots and `accent` are `black00`;
      `surfaceSunk` equals `surface`.
- [ ] No palette is expressed with `copyWith`, and `grep -n "copyWith" app/lib/theme/lonja_theme.dart`
      returns nothing.
- [ ] `grep -rn "fromSeed" app/lib` returns nothing.
- [ ] `grep -rn "Color(0x" app/lib/theme/lonja_theme.dart` returns nothing — palettes bind
      primitives, never hexes.
- [ ] `app/lib/main.dart` names no `ThemeData` field that the three builders do not set.
- [ ] `check_lonja_tokens.sh app/lib` reports no raw colour anywhere in the app.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(theme): hand-author the paper, night and sunlight palettes and their ThemeData builders

SPEC.md §11 says sunlight is a third theme and not a variant of either other
one, so all three palettes are written out slot by slot and none is derived.
The tempting one-liner — paper.copyWith(surface: white100, onSurface: black00)
— leaves onSurfaceMuted at 9.7:1, onSurfaceFaint at 4.5:1, the hairline at
1.6:1 and accent as a blue that reads grey outdoors: every one a measured pass
on a bench and a failure in the hand. At 100,000 lux the middle of the tonal
range disappears first, so sunlight deletes the middle rather than compressing
it. Seven neutral slots collapse to black00, surfaceSunk collapses into
surface, and the only chroma left is the verdict.

All 33 published contrast figures are re-derived from the WCAG formula and
compared to two decimal places, then each against its own floor — which is not
uniform: onSurfaceFaint is 3.62:1 and legal only at 19sp and above, ochre47 is
3.97:1 and legal only as a frame and a glyph, and every sunlight slot clears
SPEC.md §13's 7:1. Two tests pin the sub-floor values so nobody "fixes" them.

ColorScheme is hand-authored. A seed generates thirty tonal values nobody
measured and silently overrides the slots, so the test asserts primary is
exactly the accent slot — an equality a seed cannot satisfy by accident.

Task: E07/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
