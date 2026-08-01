# E07/T02 — `LonjaTokens`: the semantic slots, as a `ThemeExtension`

| | |
|---|---|
| **Epic** | E07 — Lonja design system foundation |
| **Branch** | `epic/07-lonja-theme` (shared) |
| **Commit** | `feat(theme): add the LonjaTokens ThemeExtension, the 4pt spine and the four rule weights` |
| **Depends on** | T01 (the pigment box must exist before anything can bind a slot to one) |
| **Size** | L |
| **Spec** | `SPEC.md` §13 (contrast and target floors — the slots are what those floors are stated about), §4.9 (glove mode, sunlight mode) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-design-tokens` | Owns the thirteen slot names and what each one means, the 4 pt spine, the four rule weights, the radius ceiling and the motion durations. Rule 3 is the law this file exists to make enforceable: widgets read slots, never primitives |
| `design-system-structure` | Owns the `ThemeExtension` machinery — the `copyWith`/`lerp` contract, the asserting `of(context)` accessor, attaching an extension to a `ThemeData`. This task **uses** those mechanics and does not restate them; the seam is named explicitly in `catchlaw-conventions-index/references/routing-table.md` |
| `catchlaw-conventions-index` | The seam above, and rule 10: a general rule is never forked into an app skill. If something here reads like `design-system-structure` guidance restated, delete it |
| `flutter-performance` | Why `LonjaTokens` is `@immutable` with value equality and a const constructor — a const token snapshot is what makes a `const` subtree and an honest `shouldRepaint` possible |
| `dart3-idioms-and-coding-standards` | Named required parameters over a five-positional-double constructor; function length; `listEquals` over a hand-rolled comparison chain |
| `testing-strategy` | Unit level for the value semantics; one widget test only for `of(context)`, because that is the only behaviour that needs an element tree |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "Tier 2 — the thirteen semantic slots" | The slot names, their roles, and the note that `density` is the fourteenth field and is not a colour |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "The 4pt spacing spine", "Rule weights, radii, motion", "The density set" | Every number in this file: `s1`–`s8`, 0.5/1/2/3, radius 0 and 2, `Duration.zero`/90 ms/140 ms, and `standard` = 48/4/56/0/`s4` |
| `.claude/skills/lonja-design-tokens/references/three-themes-and-modes.md` | "The snapshot contract" | Why `==` must cover every field, what a painter receives, and the mirror-image bug of caching a snapshot in `initState` |
| `.claude/skills/lonja-design-tokens/SKILL.md` | Rules 3, 5, 6, 7, 11, 12 | Slots not primitives; four rule weights and no fifth; hairlines are ornament and `ruleBearing` identifies; the spine; density is orthogonal; a painter takes a snapshot |
| `.claude/skills/lonja-design-tokens/examples/lonja_tokens.dart` | whole file | The worked shape: `abstract final class` scales, `@immutable` extension, asserting `of`, narrowed `copyWith`, density-snapping `lerp`, `listEquals` over `_props` |
| `.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh` | Checks 5, 6, 8, 10 | The four greps this file's constants exist to satisfy: named `EdgeInsets` steps, named stroke widths, no `LonjaTokens.of` in a painter, named durations |
| `.claude/skills/catchlaw-conventions-index/references/routing-table.md` | "Ownership seams" | "the `ThemeExtension` boilerplate around those hexes → `design-system-structure`, not `lonja-design-tokens` (values only)" |
| `FLUTTER_GUIDE.md` | §8.1, §8.2 | The identity short-circuit and `BuildContext` scoping — why the accessor is `of(context)` at build time and never a cached field |
| `FLUTTER_GUIDE.md` | §8.3 | A `CustomPainter` has no `BuildContext` and cannot read an inherited value, so everything it needs is passed in explicitly **and included in `shouldRepaint`** — which is why `==` here must cover all fourteen fields. E09's ruler is the painter that depends on it |
| `epics/DECISIONS.md` | D-2 | `app/lib/theme/`, and why the gate's `/theme/` fragment decides it |

## What this delivers

- `app/lib/theme/lonja_tokens.dart`:
  - `abstract final class LonjaSpace` — `s1` 4 … `s8` 64. No `s0`: a zero gap is `EdgeInsets.zero`.
  - `abstract final class LonjaRules` — `hair` 0.5, `rule` 1.0, `strong` 2.0, `stamp` 3.0.
  - `abstract final class LonjaRadii` — `none` `BorderRadius.zero`, `hair` 2. There is no third.
  - `abstract final class LonjaMotion` — `none` `Duration.zero`, `quick` 90 ms, `page` 140 ms.
  - `class LonjaDensity` — `@immutable`, value equality, named required parameters, and the single
    instance `standard` (48 / 4 / 56 / 0 / `s4`). `glove` arrives in T04.
  - `class LonjaTokens extends ThemeExtension<LonjaTokens>` — thirteen `Color` slots plus `density`,
    a const constructor with all fourteen `required`, `static LonjaTokens of(BuildContext)` that
    asserts rather than falling back, `copyWith({LonjaDensity? density})`, `lerp` in which colours
    interpolate and density snaps, and `==`/`hashCode` over all fourteen fields.
- `app/testing/theme/token_fixtures.dart` — `kTokensProbe`, a const token set with fourteen
  deliberately distinct values, and `tokensWith({...})`, a **widening** builder taking all fourteen
  fields as named optionals. Test-only.
- `app/test/theme/lonja_tokens_test.dart`, `app/test/theme/lonja_scales_test.dart`.

## Why it is built this way

**Thirteen slots and no fourteenth colour.** A slot is a *role*, so a widget can be written once and
be correct in three palettes: `onSurfaceMuted` is the citation line whether it resolves to `ink30` on
paper, `paper72` on night or `black00` in sunlight. A primitive read hardcodes one theme — it stays
bone-white in night and mid-grey in sunlight, which is precisely where the fisher has ten seconds and
no shade. That is `lonja-design-tokens` rule 3, and this file is what makes it available; T08 is what
makes it enforced.

**`copyWith` is narrowed to `density`, and the narrowing is the feature.** `ThemeExtension` requires
a `copyWith`, and the obvious implementation takes fourteen optionals. That implementation lets any
call site mint a palette that no contrast table covers and no golden lane renders — and it is
literally how a derived "sunlight" keeps the mid-greys it exists to delete
(`paper.copyWith(surface: white100, onSurface: black00)` leaves `onSurfaceFaint` at `ink49`, which
measures 4.5:1 on white and disappears at 100,000 lux). Density is the one axis a caller may vary,
because it is orthogonal by construction. **Rejected:** the fourteen-optional `copyWith`, with a
comment asking people not to use it. A comment is not an API.

**`lerp` interpolates colour and *snaps* density.** A cross-fade between two palettes is legitimate:
`Color.lerp` on each slot produces a real intermediate colour. A half-interpolated tap target is not:
52 dp is legal in neither mode, and a hit box that changes size mid-animation is a mis-tap waiting for
a wet hand. So density takes `t < 0.5 ? density : other.density`.

**`==` covers all fourteen fields because a painter depends on it.** `lonja-design-tokens` rule 12
requires a `CustomPainter` to take a `LonjaTokens` snapshot in its constructor and answer
`shouldRepaint` with `old.tokens != tokens`. E09's ruler is that painter. If one field is missing
from `_props`, `shouldRepaint` returns `false` for a theme change that did alter the canvas, and the
ruler keeps painting paper-theme hairlines after the user taps into sunlight. That is why the
equality test is a fourteen-row loop and not one assertion — a missing field must name itself.

**`of(context)` asserts and never falls back.** A fallback ships a palette that no golden lane ever
rendered, and it does it silently: the screen looks *fine*, in some fourth theme nobody authored. The
assert fires in debug and in every test, which is where a missing extension will actually be
introduced. **Rejected:** `Theme.of(context).extension<LonjaTokens>() ?? LonjaPalettes.paper`.

**Named parameters on `LonjaDensity`, diverging from the worked example.** The example's
`LonjaDensity(48, LonjaSpace.s1, 56, 0, LonjaSpace.s4)` is five positional doubles in a row: a
transposition of `rowHeight` and `tapMin` compiles, passes the analyzer, and produces a 56 dp row
containing a 48 dp target that nobody notices until a golden. The values are unchanged and are what
`lonja-design-tokens` owns; the constructor shape is `dart3-idioms-and-coding-standards`' call. The
divergence is stated here rather than made silently.

**The widening builder lives in `app/testing/`.** The test needs to construct a token set that
differs from another in exactly one slot — which is precisely what production is forbidden to do.
Putting `tokensWith(...)` in `app/testing/theme/token_fixtures.dart` gives the test that power
without giving it to a feature file, and `CONVENTIONS.md` §6 already reserves `testing/` for "a
version of your app that you don't ship".

**The scales are `abstract final class`, not top-level constants.** `LonjaSpace.s4` reads at the call
site as a member of a named scale, and — decisively — checks 5, 6 and 10 of
`check_lonja_tokens.sh` whitelist a line by matching the strings `LonjaSpace.` and `LonjaRules.`.
Bare `const s4 = 16.0` would be invisible to the gate and a numeric `EdgeInsets` would pass review.

## Tests first

Write every row before touching `lonja_tokens.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | loop × 8 — `LonjaSpace.s<n> is <v> dp` | each step | 4, 8, 12, 16, 24, 32, 48, 64 | The spine is published in `token-tables.md`; an off-spine value cannot be scaled by glove mode, which multiplies named steps and has no idea what a `13` was |
| 2 | loop × 4 — `LonjaRules.<name> is <v>` | each weight | 0.5, 1.0, 2.0, 3.0 | Four weights and no fifth. A `1.5` renders as a printing defect at 3x and vanishes at 1x |
| 3 | `LonjaRadii.none is BorderRadius.zero` | — | `BorderRadius.zero` | The default for every surface; square corners are what the booklet has |
| 4 | `LonjaRadii.hair is a 2 dp radius` | — | `Radius.circular(2)` on all corners | The ceiling. Check 4 of the gate fails anything above it |
| 5 | loop × 3 — `LonjaMotion.<name> is <v>` | each duration | 0, 90 ms, 140 ms | Motion is a token group too; check 10 fails a literal `Duration(` outside `/theme/` |
| 6 | `LonjaDensity.standard reports 48 dp targets with 4 dp separation` | `.standard` | `tapMin 48`, `tapGap 4`, `rowHeight 56`, `hitSlop 0`, `gutter 16` | §13's standard floor is ≥ 48 dp; T04 adds the glove row against ≥ 56 dp |
| 7 | `LonjaDensity == returns false when tapMin alone differs` | two densities | not equal | Density is a field inside `LonjaTokens.==`; if `LonjaDensity.==` is identity, a glove switch never repaints a painter |
| 8 | loop × 14 — `LonjaTokens == returns false when <field> alone differs` | `kTokensProbe` vs `tokensWith(<field>: …)` | not equal | The `_props` list is the one place a slot can be silently dropped, and the consequence is a painter that will not repaint on a theme change (rule 12) |
| 9 | `LonjaTokens == returns true for two separately constructed identical token sets` | two builds | equal | Value equality, not identity — the snapshot has to survive being rebuilt each frame |
| 10 | `LonjaTokens.hashCode is equal for two identical token sets` | as above | equal | An `==` without a matching `hashCode` breaks every `Set` and `Map` the framework puts a theme in |
| 11 | `LonjaTokens.of returns the extension attached to the ThemeData` | `ThemeData(extensions: [kTokensProbe])` | identical to `kTokensProbe` | The only supported way for a widget to reach a value |
| 12 | `LonjaTokens.of throws an assertion when no LonjaTokens is attached` | bare `ThemeData()` | `AssertionError` | The alternative is a silent fourth palette; the assert must fire in tests, which is where it will happen |
| 13 | `LonjaTokens.copyWith replaces the density and leaves every colour slot` | `.copyWith(density: other)` | 13 slots identical, density replaced | The narrowing, asserted rather than commented |
| 14 | `LonjaTokens.copyWith returns an equal token set when given no argument` | `.copyWith()` | equal | There is no other lever; a caller cannot mint a palette by accident |
| 15 | `LonjaTokens.lerp returns the receiver when other is not a LonjaTokens` | `lerp(null, 0.5)` | identical to receiver | `ThemeExtension.lerp` is typed on the base class; the framework does pass other extensions |
| 16 | `LonjaTokens.lerp interpolates surface halfway at t 0.5` | two probes | `Color.lerp(a, b, 0.5)` | A theme cross-fade must actually cross-fade the colours |
| 17 | `LonjaTokens.lerp keeps the receiver density at t 0.49` | two densities | receiver's | A half-interpolated tap target is legal in neither mode |
| 18 | `LonjaTokens.lerp takes the other density at t 0.5` | two densities | other's | The snap point is defined, not incidental |
| 19 | `LonjaTokens is const-constructible and canonicalised` | `identical(kTokensProbe, kTokensProbe2)` where both are the same const expression | `true` | `FLUTTER_GUIDE.md` §8.2: the const short-circuit is the reason a token snapshot is free to pass down a screen |

```dart
// app/test/theme/lonja_tokens_test.dart
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/token_fixtures.dart';

void main() {
  group('LonjaTokens', () {
    // The parameter is interpolated, so `--plain-name 'onSurfaceFaint'` selects one row.
    for (final TokenField field in kTokenFields) {
      test('== returns false when ${field.name} alone differs', () {
        expect(kTokensProbe, isNot(field.mutate(kTokensProbe)));
      });
    }

    testWidgets('.of returns the extension attached to the ThemeData', (WidgetTester tester) async {
      late LonjaTokens read;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: const <ThemeExtension<dynamic>>[kTokensProbe]),
        home: Builder(builder: (BuildContext context) {
          read = LonjaTokens.of(context);
          return const SizedBox.shrink();
        }),
      ));
      expect(identical(read, kTokensProbe), isTrue);
    });

    test('.copyWith replaces the density and leaves every colour slot', () {
      final LonjaTokens dense = kTokensProbe.copyWith(density: kDensityProbe);
      expect(dense.density, kDensityProbe);
      expect(dense.copyWith(density: kTokensProbe.density), kTokensProbe);
    });

    test('.lerp keeps the receiver density at t 0.49', () {
      final LonjaTokens mid = kTokensProbe.lerp(kTokensProbeB, 0.49) as LonjaTokens;
      expect(mid.density, kTokensProbe.density);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/theme/` → 19 named rows, of which four are loops (8, 4, 3 and
14), so 44 failures. `.of` needs `testWidgets`; everything else is a plain `test`. If any passes
before `lonja_tokens.dart` exists, the test is wrong.

## Implementation outline

1. The four scale classes first — they are pure constants and every later file reads them.
2. `LonjaDensity`: `@immutable`, named required `tapMin`, `tapGap`, `rowHeight`, `hitSlop`,
   `gutter`, value equality over the five, and `static const standard`.
3. `LonjaTokens`: const constructor with fourteen `required` named parameters, fields grouped as the
   token table groups them (`surface`/`surfaceSunk`, the three `onSurface*`, the two hairlines and
   `ruleBearing`, `accent`/`onAccent`, the three verdicts, `density`).
4. `of(context)` — `Theme.of(context).extension<LonjaTokens>()`, `assert(tokens != null, …)` with a
   message naming `LonjaTheme`, then `!`. The mechanics are `design-system-structure`'s; do not
   re-explain them in the doc comment. Do say, in one line, that a painter takes a snapshot in its
   constructor instead of calling this — check 8 of the gate fails `LonjaTokens.of(` inside a
   `*_painter.dart`.
5. `copyWith({LonjaDensity? density})`, every other field passed through unchanged.
6. `lerp` — a local `Color c(Color a, Color b) => Color.lerp(a, b, t)!` for the thirteen, then the
   density snap. Return `this` when `other is! LonjaTokens`.
7. `_props` and `==`/`hashCode` via `listEquals` and `Object.hashAll`. Add each field to `_props` in
   the same order as the constructor so a review can read them off against each other.
8. Fixtures in `app/testing/theme/token_fixtures.dart`: `kTokensProbe` and `kTokensProbeB` with
   fourteen distinct values (they are probes, not palettes — do not use real slot bindings, or a
   swapped field can still compare equal), `kDensityProbe`, `tokensWith(...)`, and `kTokenFields`,
   the list of fourteen `(name, mutate)` records the equality loop iterates.
9. Re-run. Then delete anything `/simplify` finds — in particular, any convenience accessor that
   only wraps a slot read.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 named tests pass, including the four loops, and each failed first.
- [ ] `LonjaTokens.copyWith` accepts `density` and nothing else — verified by reading the signature,
      and by test 14.
- [ ] `_props` has exactly fourteen entries and the equality loop covers all fourteen.
- [ ] `LonjaTokens` and `LonjaDensity` are both `@immutable` with const constructors and no
      non-final field.
- [ ] `lonja_tokens.dart` names no primitive semantically: it declares slots, and binds none. Every
      binding is T03's.
- [ ] `grep -rn "extension<LonjaTokens>" app/lib | grep -v '/theme/'` returns nothing — `of` is the
      only door.
- [ ] `check_lonja_tokens.sh app/lib` clean, with the new constants present: checks 5, 6 and 10 now
      have `LonjaSpace.`, `LonjaRules.` and `LonjaMotion.` to whitelist against.
- [ ] No mechanic from `design-system-structure` is restated in a doc comment here (rule 10 of
      `catchlaw-conventions-index`).

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
feat(theme): add the LonjaTokens ThemeExtension, the 4pt spine and the four rule weights

Thirteen role slots plus density, so a widget can be written once and be
correct in three palettes. A primitive read hardcodes one theme; a slot read
resolves to whichever palette is live, which is the whole argument in
lonja-design-tokens rule 3.

copyWith is narrowed to density on purpose. The fourteen-optional version
lets any call site mint a palette that no contrast table covers and no golden
lane renders — and it is exactly how a derived sunlight keeps the mid-greys
it exists to delete. Density is the one axis a caller may vary, because it is
orthogonal by construction. lerp interpolates the colours and SNAPS the
density: a half-interpolated tap target is legal in neither mode.

== and hashCode cover all fourteen fields because a CustomPainter answers
shouldRepaint with old.tokens != tokens. One field missing from _props means
the ruler keeps painting paper hairlines after the user taps into sunlight,
so the equality test is a fourteen-row loop that names the offending field.

LonjaDensity takes named parameters rather than the worked example's five
positional doubles: transposing rowHeight and tapMin compiles, analyses clean
and produces a 56dp row around a 48dp target. The values are unchanged.

Task: E07/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
