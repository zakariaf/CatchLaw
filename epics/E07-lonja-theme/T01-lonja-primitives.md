# E07/T01 — `LonjaPrimitives`: the tier-one pigment box

| | |
|---|---|
| **Epic** | E07 — Lonja design system foundation |
| **Branch** | `epic/07-lonja-theme` (shared) |
| **Commit** | `feat(theme): add the 25 L*-named Lonja pigments and the arithmetic that proves each name` |
| **Depends on** | — (E06 merged) |
| **Size** | M |
| **Spec** | `SPEC.md` §13 (contrast ≥ 4.5:1, ≥ 7:1 in sunlight — the floors every one of these pigments exists to clear), §4.9 (sunlight mode) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-design-tokens` | Owns every value in this file. Rule 2 fixes the naming law — a primitive is named by measured CIE L\*, never by rank or appearance — and `references/token-tables.md` is the table this file transcribes |
| `catchlaw-conventions-index` | Rule 9 (route before you edit) and the ownership seam in `references/routing-table.md`: values are `lonja-design-tokens`, the `ThemeExtension` machinery around them is `design-system-structure`. This task is entirely on the values side |
| `naming-conventions` | The class, file and test names; and why `grey700` / `darkGrey` / `brandPrimary` are rejected names rather than merely different ones |
| `dart3-idioms-and-coding-standards` | `abstract final class` for a namespace that must never be instantiated or extended, and the const discipline |
| `flutter-performance` | Why these are `static const` and not a map or an enum: const canonicalisation is what makes a token read free and a `const` widget subtree possible |
| `testing-strategy` | Which level this belongs at — pure widget-less unit tests over arithmetic, no `pumpWidget`, no binding |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "Tier 1 — the pigment box" | All 25 rows: name, hex, measured L\*, family, mockup alias, what binds it. This is the table the file transcribes and the test re-derives |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "Adding or changing a token" | The five-step process. Step 1 is the rule this task's proof automates: a name whose number does not match its hex is a defect, not a nit |
| `.claude/skills/lonja-design-tokens/SKILL.md` | Rules 1, 2, 3 | One home under `lib/theme/`; measured names; a primitive read outside `lib/theme/` is a defect |
| `.claude/skills/lonja-design-tokens/examples/lonja_tokens.dart` | The `LonjaPrimitives` block | The worked shape — `abstract final class`, `static const`, the L\* in the trailing comment. Do not diverge from it silently |
| `.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh` | Checks 1 and 2 | What the gate actually greps: `Color(0x` and `Colors.` outside `/theme/`, and `LonjaPrimitives.` outside `/theme/`. This file is the one place both are legal |
| `SPEC.md` | §13, accessibility row | The floors: contrast ≥ 4.5:1, ≥ 7:1 in sunlight mode. Every pigment in the box exists to hit one of them in one of three themes |
| `FLUTTER_GUIDE.md` | §8.2 | `const` and canonicalisation — the reason these are compile-time constants and not a lookup |
| `FLUTTER_GUIDE.md` | §2.5, §6.2 | Where the file goes, where its test goes, and why fixtures live in `app/testing/` rather than `app/test/` |
| `epics/DECISIONS.md` | D-2 | The palette lives at `app/lib/theme/`, not `app/lib/ui/core/themes/`, because every `lonja-*` gate exempts by the path fragment `/theme/` |

## What this delivers

- `app/lib/theme/lonja_primitives.dart` — `abstract final class LonjaPrimitives` with 25
  `static const Color` fields, each carrying a `///` line stating its measured CIE L\*, its mockup
  alias where one exists, and which theme binds it. Nothing else: no spacing, no rule weights, no
  semantic names, no `ThemeData`.
- `app/testing/theme/colour_math.dart` — `cieLStar(Color)`, `relativeLuminance(Color)` and
  `contrastRatio(Color, Color)`, the sRGB → linear → Y → L\* chain and the WCAG 2.x contrast
  formula. Test-only, never shipped (`CONVENTIONS.md` §6), and reused by T03's contrast proof and
  T08's greyscale proof.
- `app/testing/theme/pigment_table.dart` — `const kPigmentTable`, a `List<PigmentRow>` transcribed
  by hand from `token-tables.md`: name string, the `LonjaPrimitives` constant, the expected 32-bit
  ARGB literal, and the expected L\* to one decimal.
- `app/test/theme/lonja_primitives_test.dart`.

## Why it is built this way

**The name is the falsifiable claim.** `ink11` is `#16201C` because its CIE L\* is 11.2, and
arithmetic says so. That is the entire argument for the naming law in `lonja-design-tokens` rule 2,
and it is worth nothing unless something actually runs the arithmetic — otherwise the number in the
name is decoration that drifts the first time a hex is nudged. So the L\* is computed in a test from
the hex, twice: once against the tabled decimal (±0.05, which is tighter than any plausible eye) and
once against the integer in the name itself (±0.6, which is the largest gap the published table
contains — `paper90` measures 90.54). A pigment whose hex changes without its name changing fails
the second assertion, which is exactly the review that step 1 of "Adding or changing a token" asks a
human to perform.

**The tolerance on the tabled value is tight on purpose.** `ink07` has a relative luminance of
0.00774, which sits **below** the CIE knee at (6/29)³ = 0.008856, so it is the one pigment in the box
that must be resolved on the piecewise-linear branch rather than the cube root. An implementation
that uses the cube root everywhere reports 6.94 instead of 6.99 and reports **−16.00** for `black00`.
±0.05 catches the first; `black00` catches the second unmistakably. Both are in the test table.

**Two files, because the import line is a signal.** The 4 pt spine, the rule weights, the radius
ceiling and the motion durations are tier-one values too, but a widget is *supposed* to read
`LonjaSpace.s4` — check 5 of `check_lonja_tokens.sh` whitelists exactly that — while a widget that
reads `LonjaPrimitives.paper90` is a defect the same script fails on. Keeping them in separate files
makes the import statement itself diagnostic: a feature file importing `lonja_primitives.dart` is
already wrong, before a reviewer reads a single line of its body. The scales land in
`lonja_tokens.dart` in T02, which is also where `lonja-design-tokens` rule 1 puts them.

**Rejected: a `Map<String, Color>` as the public API.** A map read is not a const expression at a
call site, so it forfeits the canonicalisation `FLUTTER_GUIDE.md` §8.2 measures, and a typo'd key is
a runtime null instead of a compile error. The map exists — but as a *test* fixture in
`app/testing/`, where its only job is to be iterated.

**Rejected: an `enum Pigment` with a colour field.** It reads well and it makes the count checkable
by `values.length`, but every call site then becomes `Pigment.paper90.colour`, one indirection deeper
than the tokens that will actually be read, and the gate's grep for `LonjaPrimitives\.` no longer
matches. A gate that can be renamed around is not a gate.

**Rejected: Material's greys.** `Colors.grey.shade400` carries a warm bias that fights the
green-grey cast of the whole paper palette, and `ColorScheme.fromSeed` generates thirty tonal values
nobody measured, none of which appear in any contrast table. Both are banned by check 1 of the gate
outside `lib/theme/`; neither is used inside it either.

**The fixture is a transcription, and that is the point.** `kPigmentTable` is typed out from
`token-tables.md` by hand rather than derived from `LonjaPrimitives`. If it were derived, the test
would compare the file with itself and pass forever. Transcribed, it fails when the code and the
published table disagree — which is the only failure worth catching here.

## Tests first

Write every row before touching `lonja_primitives.dart`. Run them. **They must fail** — the class
does not exist, so they will not even compile, and a compile failure counts as red. If any test
passes once the file compiles but before its constants are filled in, that test is wrong.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `cieLStar returns 0.0 for black` | `Color(0xFF000000)` | `0.0` | The lower anchor, and the case a cube-root-only implementation returns −16 for |
| 2 | `cieLStar returns 100.0 for white` | `Color(0xFFFFFFFF)` | `100.0` | The upper anchor of the scale every primitive name is expressed in |
| 3 | `cieLStar resolves the linear branch below the CIE knee` | `LonjaPrimitives.ink07` | `6.99 ± 0.01` | `ink07`'s Y is 0.00774, under (6/29)³; the cube root gives 6.94 and the whole naming law loses its footing at the dark end |
| 4 | `contrastRatio returns 21.00 for black on white` | `black00`, `white100` | `21.00 ± 0.005` | The helper T03 and T08 both depend on; if it is wrong every contrast proof in the epic is wrong together |
| 5 | `contrastRatio is symmetric in its arguments` | `ink11`, `paper90` both ways | equal | WCAG defines the ratio as lighter-over-darker; an implementation that takes the arguments in order returns < 1 half the time |
| 6 | loop × 25 — `LonjaPrimitives.<name> measures L* <tabled>` | each `kPigmentTable` row | `± 0.05` | The tabled decimal in `token-tables.md` is a published measurement; this is the assertion that keeps the code and the table one thing |
| 7 | loop × 25 — `LonjaPrimitives.<name> carries its measured lightness in its name` | each row | `|L* − nameNumber| < 0.6` | Rule 2. A hex nudged without a rename is exactly the drift the naming law exists to prevent; 0.6 is the widest gap the published table contains (`paper90` at 90.54) |
| 8 | loop × 25 — `LonjaPrimitives.<name> is the ARGB value published for it` | each row | exact `int` equality with the row's literal | Catches a transposed hex digit that happens to land within 0.6 L\* of the right lightness |
| 9 | `kPigmentTable lists twenty-five pigments` | `kPigmentTable.length` | `25` | "Twenty-five primitives, and adding a twenty-sixth is a reviewed change." A silent 26th is what this asserts against |
| 10 | `kPigmentTable binds every name to a distinct value` | the 25 colours | 25 distinct | Two names for one hex means one of them is a lie about what the theme binds |
| 11 | `LonjaPrimitives.paper90 and .paper89 are different colours` | both | not equal | 1.2 L\* apart, one is the paper ground and one is night's primary text; swapping them is the single most plausible copy-paste in the file |
| 12 | `LonjaPrimitives.ochre47 and .ochre38 are different colours` | both | not equal | `ochre38` exists only so sunlight's warn clears 7:1; using `ochre47` there ships 3.97:1 into the theme built for 100,000 lux |
| 13 | `LonjaPrimitives.paper90 is a canonicalised const` | `identical(const Color(0xFFE6E4DC), LonjaPrimitives.paper90)` | `true` | `FLUTTER_GUIDE.md` §8.2 mechanism 1: the const short-circuit only exists if these really are compile-time constants |

```dart
// app/testing/theme/colour_math.dart  — test-only; never imported from lib/.
import 'dart:math' as math;
import 'dart:ui';

/// Relative luminance, WCAG 2.x: sRGB channels linearised, then Rec. 709 weights.
double relativeLuminance(Color c) {
  double channel(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// CIE L* (D65, sRGB). The piecewise-linear branch below the knee is not optional:
/// ink07 lives there, and black00 returns -16 without it.
double cieLStar(Color c) {
  final double y = relativeLuminance(c);
  const double delta = 6 / 29;
  final double f = y > delta * delta * delta
      ? math.pow(y, 1 / 3).toDouble()
      : y / (3 * delta * delta) + 4 / 29;
  return 116 * f - 16;
}

double contrastRatio(Color a, Color b) {
  final double la = relativeLuminance(a), lb = relativeLuminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}
```

```dart
// app/test/theme/lonja_primitives_test.dart
import 'package:catchlaw/theme/lonja_primitives.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/colour_math.dart';
import '../../testing/theme/pigment_table.dart';

void main() {
  group('cieLStar', () {
    test('returns 0.0 for black', () {
      expect(cieLStar(const Color(0xFF000000)), closeTo(0.0, 0.01));
    });

    test('resolves the linear branch below the CIE knee', () {
      expect(cieLStar(LonjaPrimitives.ink07), closeTo(6.99, 0.01));
    });
  });

  group('LonjaPrimitives', () {
    // Loop-generated: the parameter is interpolated so --plain-name can select one row.
    for (final PigmentRow row in kPigmentTable) {
      test('.${row.name} measures L* ${row.lStar}', () {
        expect(cieLStar(row.colour), closeTo(row.lStar, 0.05));
      });

      test('.${row.name} carries its measured lightness in its name', () {
        expect((cieLStar(row.colour) - row.nameNumber).abs(), lessThan(0.6));
      });

      test('.${row.name} is the ARGB value published for it', () {
        expect(row.colour.toARGB32(), row.argb);
      });
    }

    test('.paper90 and .paper89 are different colours', () {
      expect(LonjaPrimitives.paper90, isNot(LonjaPrimitives.paper89));
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/theme/lonja_primitives_test.dart` → 85 failures (13 named rows,
three of which are loops of 25: 10 single tests plus 75). If any passes before
`lonja_primitives.dart` holds its constants,
the test is wrong — fix the test before writing a line of `lib/`.

## Implementation outline

1. `app/testing/theme/colour_math.dart` first: it is what the tests assert *with*, so it exists
   before the thing under test. Three functions, no class, no state.
2. `app/testing/theme/pigment_table.dart`: `class PigmentRow` (`name`, `colour`, `argb`,
   `lStar`, `nameNumber`) and `const kPigmentTable` typed out from the tier-1 table in
   `token-tables.md`, in the table's own order. Do not generate it from the class under test.
3. `app/lib/theme/lonja_primitives.dart`: `abstract final class LonjaPrimitives`, private
   constructor unnecessary — `abstract final` already makes instantiation and subclassing compile
   errors. 25 `static const Color`, grouped by family in the table's order, each with a `///` line:
   the measured L\*, the mockup alias if any, and what binds it. `CONVENTIONS.md` §8 requires doc
   comments on public API, and here the doc comment is the claim the test verifies.
4. Run the suite. Fix hexes, never tolerances. A row that will not come within 0.6 L\* of its name is
   a naming defect: rename the primitive, and add its row to `token-tables.md` in the same change —
   that file's step 1, not a local decision.
5. Confirm `check_lonja_tokens.sh app/lib` still passes: this file is inside `/theme/`, so checks 1
   and 2 exempt it, and nothing outside it names a pigment yet.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 13 named tests pass, including the three 25-row loops, and each failed first.
- [ ] Every primitive is within 0.05 of its tabled L\* and 0.6 of the integer in its own name.
- [ ] `LonjaPrimitives` is `abstract final` — instantiation and `extends` are compile errors, not
      review comments.
- [ ] `grep -rn "LonjaPrimitives\." app/lib --include='*.dart' | grep -v '/theme/'` returns nothing.
- [ ] `grep -rn "Colors\." app/lib/theme` returns nothing — the pigment box names no Material colour,
      not even `Colors.transparent`.
- [ ] `app/lib/theme/lonja_primitives.dart` contains no `TextStyle`, no `EdgeInsets`, no
      `BorderRadius`, no `Duration` and no semantic name (`surface`, `onSurface`, `accent`, …).
- [ ] `app/testing/theme/` is imported by tests only: `grep -rn "testing/theme" app/lib` is empty.
- [ ] Every public constant carries a `///` line naming its measured L\*.

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
feat(theme): add the 25 L*-named Lonja pigments and the arithmetic that proves each name

lonja-design-tokens rule 2 says a primitive is named by its measured CIE L*
and never by rank or appearance, because a rank scale has no room to insert
and an appearance name inverts catastrophically. That claim is only worth
making if something runs the arithmetic, so the test computes L* from each
hex and checks it twice: against the decimal published in token-tables.md
(±0.05) and against the integer in the primitive's own name (±0.6, the widest
gap the table contains, at paper90's 90.54).

The tolerance is tight because ink07's luminance sits below the CIE knee at
(6/29)^3: a cube-root-only implementation reports 6.94 instead of 6.99, and
-16.00 for black00. Both are test rows.

The pigment box gets its own file rather than sharing one with the 4pt spine.
A widget is supposed to read LonjaSpace.s4 and is never allowed to read
LonjaPrimitives.paper90, so the import line is diagnostic on its own: a
feature file importing lonja_primitives.dart is wrong before anyone reads its
body. The fixture table in app/testing/ is transcribed by hand from
token-tables.md rather than derived from the class, so the test compares the
code with the published table instead of with itself.

Task: E07/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
