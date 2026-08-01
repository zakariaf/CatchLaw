# E07/T04 — Glove density, orthogonal to the theme

| | |
|---|---|
| **Epic** | E07 — Lonja design system foundation |
| **Branch** | `epic/07-lonja-theme` (shared) |
| **Commit** | `feat(theme): add the glove density set and cross it with all three palettes` |
| **Depends on** | T03 (the three palettes must exist before density can be crossed with them) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.9 glove-mode row — "All primary targets ≥ 56 dp with ≥ 8 dp separation", done when "result and species tiles pass at 56 dp"; §13 accessibility row — "targets ≥ 48 dp (≥ 56 dp glove mode)" |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-design-tokens` | Rule 11 is this task in one line: glove mode is a density token set carried on `LonjaTokens.density`, and there is no `ThemeMode.gloveNight`. `references/token-tables.md` holds the five values |
| `accessibility-as-code` | Owns the 44 dp platform tap-target floor that Lonja's 48/56 sits above and does not replace. The relationship is named in the routing table's ownership seams: the value is `lonja-design-tokens`', the floor is `accessibility-as-code`' |
| `catchlaw-conventions-index` | The seam above, and rule 9 — route before editing, because "a 56 dp glove target" looks like it has two owners and does not |
| `design-system-structure` | The `ThemeData`-building mechanics the resolver uses; not restated here |
| `testing-strategy` | Pure unit level: this is a value set and a switch. Nothing here needs a widget tree |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "The density set (glove mode)" | The five values and the reason column: `tapMin` 48 → 56, `tapGap` 4 → 8, `rowHeight` 56 → 72, `hitSlop` 0 → 4, `gutter` `s4` → `s5`; and the note that the 44 dp platform floor is owned elsewhere |
| `.claude/skills/lonja-design-tokens/references/three-themes-and-modes.md` | "Glove mode is density, not a theme" | The two-axis table, what each axis is persisted as, and the arithmetic on folding them: six palettes, six contrast tables, and a guarantee that the least-used combination drifts |
| `.claude/skills/lonja-design-tokens/references/three-themes-and-modes.md` | "Authoring or changing a theme", step 4–5 | A theme built without a density is a compile error; three themes × two densities is six lanes and all six are cheap because the palettes are const |
| `.claude/skills/lonja-design-tokens/SKILL.md` | Rule 11, and "The 4pt spine and glove density" | The worked call site: `SizedBox(height: t.density.tapMin)` — 48 / 56 — with `t.density.tapGap` between two actions |
| `.claude/skills/lonja-design-tokens/examples/lonja_theme.dart` | `resolveLonjaTheme` and `LonjaSkin` | The worked crossing: a density parameter on each builder and one switch over three skins |
| `.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh` | Check 9 | `ThemeMode.glove`, `glovenight`, `glovepaper`, `glovesunlight`, case-insensitive, with **no** `/theme/` exemption and **no** escape hatch. The one gate check with no way out |
| `SPEC.md` | §4.9, glove-mode row | 56 dp and 8 dp, and what "done looks like" |
| `SPEC.md` | §13, accessibility row | The standard-density floor of 48 dp, which `LonjaDensity.standard` must clear |
| `epics/DECISIONS.md` | D-2 | The theme's home, and why the gate decides it |

## What this delivers

- `app/lib/theme/lonja_tokens.dart` — `LonjaDensity.glove`: `tapMin 56`, `tapGap LonjaSpace.s2` (8),
  `rowHeight 72`, `hitSlop 4`, `gutter LonjaSpace.s5` (24). One new constant; the class is T02's.
- `app/lib/theme/lonja_theme.dart`:
  - `enum LonjaSkin { paper, night, sunlight }` — the theme axis, and the only one.
  - A `{LonjaDensity density = LonjaDensity.standard}` parameter on `LonjaTheme.paper()`,
    `.night()` and `.sunlight()`, applied through `palette.copyWith(density: density)` — the single
    lever T02 left open.
  - `ThemeData resolveLonjaTheme({required LonjaSkin skin, required bool gloved})` — the one place
    in the app where the two axes cross.
- `app/test/theme/lonja_density_test.dart`.

**Not** delivered here: persistence. `three-themes-and-modes.md` records the shape — the skin as an
enum name and the density as a bool, both in `user.db` — and E16 (settings, S14) writes them. This
task guarantees only that whatever is restored is one of exactly three named palettes and one of
exactly two densities.

## Why it is built this way

**The two axes answer different questions.** The theme answers *what light am I in*; glove mode
answers *what is my hand like*. They vary independently, and both combinations that look unusual are
in fact common: a gloved hand at night is normal on a boat, and a bare hand in sunlight is normal on
a quay. Nothing about a palette follows from a hand.

**Folding them into one enum costs six of everything, forever.** `paper`, `paperGlove`, `night`,
`nightGlove`, `sunlight`, `sunlightGlove` is six palettes to hand-author, six sets of contrast rows
to keep measured, and twelve golden lanes — and it guarantees that the least-used combination drifts
silently, because nobody opens it. Orthogonal, the palette work stays at three (39 bindings, 33
contrast rows) and the density work stays at one five-row table, while the *renderings* still number
six. `check_lonja_tokens.sh` check 9 greps for exactly this mistake, case-insensitively, with no
`/theme/` exemption and no `// lonja-token-ok` escape hatch — the only check in the script with no
way out. That is a deliberate signal about how expensive the mistake is.

**Density is geometry, and only geometry.** It never changes a colour, a rule weight, a radius or a
type step. If a change to glove mode wants a different colour, the requirement is wrong: contrast
must already be sufficient for a bare hand. Test 8 states this as an equality —
`standard.copyWith(density: glove) == gloveTokens` — which is both the strongest available assertion
and a demonstration that `copyWith`'s narrowing in T02 was the right call: the only expressible
difference between the two token sets is the one that is allowed to differ.

**56 dp and 8 dp are `SPEC.md` §4.9's numbers, not a designer's preference.** A neoprene glove over a
wet finger loses roughly 8 dp of precision, and separation — not size — is what prevents the
adjacent-target mis-tap, which is why `tapGap` doubles as well as `tapMin` growing. `hitSlop` grows
the hit box by 4 dp without moving the ink, so the layout does not reflow when the setting changes.

**Rejected: Material's `VisualDensity`.** It exists, it is on `ThemeData`, and it is the wrong tool.
It is a −4…+4 scale expressed as a relative offset that Material components interpret individually;
it cannot state "56 dp minimum with an 8 dp gap", it does not reach a `LonjaPanel` or a
`CustomPainter`, and it would leave the app with two density mechanisms whose interaction nobody has
measured.

**Rejected: inferring glove mode from `MediaQuery`.** A width breakpoint says a phone is small; a
phone in a pocket is not a glove. This is a user setting about a hand, and there is no sensor for it.

**Rejected: a second `InheritedWidget` carrying density.** It would be a second inherited lookup for
a value the token set already carries, and — decisively — a `CustomPainter` takes one `LonjaTokens`
snapshot in its constructor (rule 12). A painter that needed a second source would have to read the
element tree, which check 8 of the gate fails.

## Tests first

Write every row before adding `LonjaDensity.glove`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `LonjaDensity.glove raises the tap target to 56 dp` | `.glove.tapMin` | `56` | `SPEC.md` §4.9's headline number; the whole task is downstream of it |
| 2 | `LonjaDensity.glove raises the separation to 8 dp` | `.glove.tapGap` | `LonjaSpace.s2` (8) | Separation is what prevents the adjacent-target mis-tap; §4.9 states it beside the size and it is the half people drop |
| 3 | `LonjaDensity.glove raises the row height to 72 dp` | `.glove.rowHeight` | `72` | §4.9's "done looks like" names species tiles, which are rows, not buttons |
| 4 | `LonjaDensity.glove extends the hit box by 4 dp` | `.glove.hitSlop` | `4` | The hit box grows without the ink moving; a layout that reflows on a settings toggle looks broken |
| 5 | `LonjaDensity.glove widens the gutter to 24 dp` | `.glove.gutter` | `LonjaSpace.s5` (24) | The sheet breathes when the hand is clumsy — and it stays on the 4 pt spine, so it can be scaled |
| 6 | `LonjaDensity.standard clears the 48 dp target floor` | `.standard.tapMin` | `>= 48` | `SPEC.md` §13's standard-density floor. Lonja sits above `accessibility-as-code`'s 44 dp deliberately and must not drift below the spec's own number |
| 7 | loop × 3 — `glove - LonjaTheme.<theme>(density: glove) carries the glove density` | each builder | `tokens.density == LonjaDensity.glove` | Six renderings, and the crossing must actually reach the extension rather than stopping at the builder's signature |
| 8 | loop × 3 — `glove - LonjaTheme.<theme>(density: glove) changes no colour slot` | standard vs glove tokens | `standard.copyWith(density: glove) == glove` | Density is geometry only. This equality also proves the narrowed `copyWith` from T02 is sufficient: nothing else can differ |
| 9 | loop × 6 — `resolveLonjaTheme(skin: <skin>, gloved: <bool>) binds the <skin> palette at <density> density` | all six combinations | palette and density both correct | The one crossing point in the app; a switch that drops a case is a screen that silently renders paper |
| 10 | `LonjaSkin declares exactly three values` | `LonjaSkin.values.length` | `3` | There is no fourth theme and no runtime-generated theme; a fourth value is how the density axis gets folded back in |
| 11 | `LonjaSkin declares no value whose name mentions a glove` | every `.name` | none contains `glove`, case-insensitive | The property check 9 of `check_lonja_tokens.sh` greps for, asserted where a developer will see it fail first |
| 12 | `LonjaTheme.paper() defaults to the standard density` | no argument | `LonjaDensity.standard` | The default must be the one a first launch gets, before any setting exists to restore |
| 13 | `glove - LonjaTokens.lerp snaps from standard to glove at t 0.5` | the two shipped densities | `glove` at 0.5, `standard` at 0.49 | T02 proved the snap with probes; this proves it for the pair that actually animates when the setting is toggled |
| 14 | `glove - every target in the glove set is at least 56 dp and every gap at least 8 dp` | the five fields | `tapMin >= 56`, `rowHeight >= 56`, `tapGap >= 8`, `gutter >= 8` | §4.9 stated as one assertion over the whole set, so a future sixth field cannot quietly land below the floor |

```dart
// app/test/theme/lonja_density_test.dart
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LonjaDensity', () {
    test('.glove raises the tap target to 56 dp', () {
      expect(LonjaDensity.glove.tapMin, 56);
    });

    test('.glove raises the separation to 8 dp', () {
      expect(LonjaDensity.glove.tapGap, LonjaSpace.s2);
    });
  });

  // A cross-cutting axis takes a prefix, so these are top-level: a group description is
  // prepended to the test name and would bury the prefix mid-sentence (CONVENTIONS.md §5).
  for (final LonjaSkin skin in LonjaSkin.values) {
    test('glove - LonjaTheme.${skin.name}(density: glove) changes no colour slot', () {
      final LonjaTokens standard =
          resolveLonjaTheme(skin: skin, gloved: false).extension<LonjaTokens>()!;
      final LonjaTokens gloved =
          resolveLonjaTheme(skin: skin, gloved: true).extension<LonjaTokens>()!;
      expect(standard.copyWith(density: LonjaDensity.glove), gloved);
    });
  }

  group('LonjaSkin', () {
    test('declares no value whose name mentions a glove', () {
      expect(
        LonjaSkin.values.where((LonjaSkin s) => s.name.toLowerCase().contains('glove')),
        isEmpty,
      );
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/theme/lonja_density_test.dart` → 14 named rows, of which three
are loops (3, 3 and 6), so 23 failures. If any passes before `LonjaDensity.glove` exists, the test is
wrong.

## Implementation outline

1. `LonjaDensity.glove` beside `standard` in `lonja_tokens.dart`, with the same named parameters and
   a `///` line naming `SPEC.md` §4.9 as the source of 56 and 8.
2. `enum LonjaSkin { paper, night, sunlight }` in `lonja_theme.dart`. Three values, no `system`
   member — platform brightness is `ThemeMode`'s job in `main.dart`, and mixing the two concepts in
   one enum is how a fourth palette appears.
3. Add `{LonjaDensity density = LonjaDensity.standard}` to the three builders and pass it into
   `_build`, which applies `palette.copyWith(density: density)` before constructing the `ThemeData`.
   No other call site may apply a density.
4. `resolveLonjaTheme({required LonjaSkin skin, required bool gloved})` — an exhaustive `switch`
   expression over `LonjaSkin`, so adding a value is a compile error rather than a silent default.
   Both parameters required: a default for `gloved` is a setting that silently disagrees with the
   one in `user.db`.
5. Re-run the suite, including T02's and T03's — the `copyWith` and equality tests are what protect
   this change.
6. `check_lonja_tokens.sh app/lib` and confirm check 9 reports nothing. It will pass trivially; the
   point is that test 11 fails loudly *before* the gate does, in a place a developer is already
   looking.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 14 named tests pass, including the three loops, and each failed first.
- [ ] `LonjaDensity.glove` reports `tapMin 56` and `tapGap 8`, matching `SPEC.md` §4.9 exactly.
- [ ] `LonjaDensity.standard` clears `SPEC.md` §13's 48 dp.
- [ ] Six theme × density combinations resolve, and each differs from its sibling in `density` and
      in no other field.
- [ ] `LonjaSkin` has three values; `grep -rniE 'glove(night|paper|sunlight)|ThemeMode\.glove' app/lib`
      returns nothing.
- [ ] No colour, rule weight, radius, duration or type step differs between the two densities.
- [ ] `resolveLonjaTheme` is the only place `LonjaSkin` and `gloved` meet, and its `switch` is
      exhaustive with no `default`.
- [ ] `check_lonja_tokens.sh app/lib` clean, check 9 included.

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
feat(theme): add the glove density set and cross it with all three palettes

SPEC.md §4.9 wants every primary target at 56dp with 8dp of separation. That
is a fact about a hand, not about light, so it is a value set carried on
LonjaTokens.density rather than a fourth theme: the theme answers what light
am I in, glove mode answers what is my hand like, and both unusual-looking
combinations are common — a gloved hand at night on a boat, a bare hand in
sunlight on a quay.

Folding the axes into one enum would produce paper, paperGlove, night,
nightGlove, sunlight and sunlightGlove: six palettes to hand-author, six sets
of contrast rows to keep measured, twelve golden lanes, and a guarantee that
the least-used combination drifts because nobody opens it. Orthogonal, the
palette work stays at three and the density work at one five-row table while
the renderings still number six. Check 9 of check_lonja_tokens.sh greps for
this exact mistake with no path exemption and no escape hatch.

Density is geometry only, and the test says so as an equality:
standard.copyWith(density: glove) == glove. That also demonstrates the
narrowed copyWith from T02 is sufficient — the only expressible difference
between the two token sets is the one allowed to differ.

VisualDensity was rejected: a -4..+4 relative scale cannot state a 56dp
minimum, does not reach a LonjaPanel or a painter, and would leave two density
mechanisms whose interaction nobody has measured.

Task: E07/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
