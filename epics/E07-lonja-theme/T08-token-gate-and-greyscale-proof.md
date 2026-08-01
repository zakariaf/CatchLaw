# E07/T08 — The token gate, and the greyscale proof

| | |
|---|---|
| **Epic** | E07 — Lonja design system foundation |
| **Branch** | `epic/07-lonja-theme` (shared) |
| **Commit** | `test(check): prove the Lonja gates scan a real tree and that no state rides on colour alone` |
| **Depends on** | T01–T07 (the proof renders every artefact this epic ships) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.9 (colour independence — "passes a greyscale screenshot test"; font scaling — layouts survive 200% text scale), §13 (contrast floors), §14 (the static verification checklist this epic's gates belong to) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `widget-golden-and-a11y-testing` | Owns the golden harness, the lane matrix and a11y assertions in tests. The greyscale proof is one of its lanes, not a bespoke mechanism |
| `catchlaw-conventions-index` | Invariant 4 and how it is proved: "a greyscale golden in `widget-golden-and-a11y-testing`, not an eyeball". Check 4 of `check_app_invariants.sh` is the grep half of the same rule |
| `lonja-design-tokens` | The definition-of-done list this task executes against, and the reason each gate check exists |
| `accessibility-as-code` | Never-colour-alone, and `textScaler` handling — the 200 % lane must not clamp anything |
| `ci-pipeline-and-gates` | Where the gate invocations live, and why a golden is generated and verified on one platform only |
| `testing-strategy` | The budget: keep the golden **matrix** small, and put the weight on assertions rather than on pixels |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh` | header and all 10 checks | What each check greps, which have a `/theme/` exemption, and that check 9 has neither an exemption nor an escape hatch |
| `.claude/skills/lonja-design-tokens/SKILL.md` | "Definition of done" | The ten-line list this epic is measured against |
| `.claude/skills/lonja-design-tokens/references/three-themes-and-modes.md` | "Authoring or changing a theme", step 5 | Three themes × two densities is six lanes, and all six are cheap because the palettes are const |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | Invariant 4 | The state table — hue, glyph, word — and the observation that oxblood carries **two** states, so hue distinguishes nothing between below-minimum and protected |
| `.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh` | Checks 4, 5, 9 | The citation and colour-only greps, and check 9, which delegates to every sibling `check_*.sh` that is installed |
| `SPEC.md` | §4.9, colour-independence row | "Result never relies on colour alone — icon + words + colour. Passes a greyscale screenshot test" |
| `SPEC.md` | §14 | The offline verification checklist the static half of these gates belongs to; the dynamic half is E21's |
| `FLUTTER_GUIDE.md` | §6.2, §6.4 | Golden files live beside their test; goldens need a real font or every locale renders identical boxes; generate and verify on one platform |
| `CONVENTIONS.md` | §7 | "A gate that scans a path with no files reports success. That is the failure mode that makes a gate worse than no gate" |
| `epics/DECISIONS.md` | D-1, D-3 | Gates are always invoked with an explicit target directory; the six locales, of which `ar` is the only RTL lane |

## What this delivers

- `app/testing/theme/lonja_specimen.dart` — `LonjaSpecimenSheet`, a widget built **only** from what
  this epic ships: all sixteen type steps set in real content, the four rule weights, `LonjaPanel`,
  `LonjaPlateSurface`, and the three button rungs in their default, focused, disabled and busy
  states. It renders no verdict widget, no citation footnote and no stale bar — those are E10's, and
  a specimen that invents them would freeze a design nobody has reviewed.
- `app/test/theme/lonja_specimen_golden_test.dart` — eight lanes: three skins × two densities, one
  `ar` lane, and one greyscale lane. Tagged so CI runs them on Linux only.
- `app/test/theme/goldens/` — the eight `.png` files, beside their test as
  `LocalFileComparator` requires.
- `app/test/theme/greyscale_proof_test.dart` — the assertions that make the greyscale golden
  *evidence* rather than a picture: distinct fields, distinct rule weights, distinct labels, and the
  measured luminance collapse that makes all three necessary.
- `app/test/theme/gate_targets_test.dart` — proof that the directories the six gates scan are not
  empty.
- One CI line per gate that E01's workflow does not already invoke, and nothing else in
  `.github/`.

## Why it is built this way

**A passing gate is a floor, not proof — and an empty scan passes.** `CONVENTIONS.md` §7 is explicit:
a gate pointed at a path with no files reports success, which makes it worse than no gate, because
the green is now evidence of nothing. Until this epic, `check_lonja_tokens.sh app/lib` was green over
a tree with almost no colour in it. The first thing this task does is assert the targets are
non-empty; only then is a green worth reading.

**The greyscale proof is a correctness test, not a nicety.** Invariant 4 exists because sunlight
deletes every grey, salt haze eats chroma, and roughly eight percent of the men who will read this
screen cannot separate the two hues that matter most. The measurement that makes it concrete is in
this epic's own palette: the primary field is `harbour30` at L\* 30.28 and the destructive field is
`oxblood28` at L\* 27.96 — **2.3 L\* apart**. Desaturated they are the same box. The same arithmetic
applies downstream and worse: `product-invariants.md` records that oxblood carries *two* states,
below-minimum and protected, so hue distinguishes nothing between them even in full colour. Colour is
the third signal, never the first, and this is where that stops being a slogan.

**A golden alone would not prove it.** A greyscale `.png` proves the frame rendered; it does not
prove that a human could tell two controls apart, and it silently passes if both rungs become
identical grey boxes together. So the golden is paired with four assertions — the fields differ in
kind (filled versus outlined), the rule weights differ (1.0 versus 2.0), the labels differ, and the
two field luminances are within 3 L\* — and the last of those is what makes the first three
load-bearing rather than decorative.

**Eight lanes, and the matrix stops there.** `CONVENTIONS.md` §6 caps the golden matrix at 4–6
screens × 6 locales × 2 themes and says to keep it *small*; `three-themes-and-modes.md` prices three
themes × two densities at six lanes and calls them cheap because the palettes are const. One `ar`
lane is added because the Naskh resolution, the 1.12 uplift and the zero tracking are this epic's own
code and nothing else in E07 renders them; one greyscale lane is added because §4.9 asks for it by
name. The remaining five locales are E20's whole-app matrix and are not duplicated here.

**Linux only, and with E06's fonts.** Goldens are host-platform-dependent, so one platform is the
source of truth or they churn on every macOS machine; and `flutter test`'s default font has no Arabic
coverage, so an `ar` golden would be indistinguishable from an `en` one. Both problems are already
solved: E06 put font loading in `app/test/flutter_test_config.dart`, which is directory-scoped and
scanned upward, and CI runs on Linux. This task adds no second font-loading path and invents no
second tag name — if E06 established one for goldens, it is reused.

**The specimen lives in `app/testing/`, not in `app/lib/`.** It is a version of the app that is not
shipped (`CONVENTIONS.md` §6). Shipping it would put a demo screen in a production binary and,
worse, would make the gates scan it — a specimen legitimately renders a disabled button and a busy
latch side by side, which no real screen does.

**Its copy states facts.** The specimen sets `Below the minimum — 38 cm, minimum 45 cm (total
length)` and `Ministerial Decision 580/2015, Art. 3 · published 2015-11-03 · checked 2026-07-14`,
from `SPEC.md`'s own examples. A specimen is the thing people copy from, so an imperative in it
would propagate into a real screen and invariant 2 would be broken by an example rather than by a
decision.

**Rejected: a golden per widget.** Twenty-four small goldens churn on every spacing change and tell
nobody which one mattered. One sheet per lane fails once, with a diff a human can read.
**Rejected: asserting contrast inside the golden test.** Contrast is arithmetic and belongs in T03's
unit tests, where a failure names the slot instead of producing a pixel diff.

## Tests first

Write every row before the specimen renders. Run them. **They must fail** — the golden files do not
exist yet, so `matchesGoldenFile` fails rather than silently creating them. Generate the baselines
with `--update-goldens` only after the four non-golden proofs below are green, and never as the way
to make a red lane pass.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `Lonja gate targets contain Dart files` | `app/lib/theme`, `app/lib/ui/core/ui` | both non-empty | `CONVENTIONS.md` §7's failure mode: a gate over an empty tree is green and means nothing. Every gate result below depends on this one |
| 2 | `LonjaSpecimenSheet renders all sixteen type steps` | the sheet | 16 distinct steps found | A golden of a sheet that omits a step proves nothing about that step, and the omission is invisible in the image |
| 3 | `LonjaSpecimenSheet renders all four rule weights` | the sheet | 0.5, 1.0, 2.0, 3.0 present | Same argument, for the weights the whole separation system is built from |
| 4 | `LonjaSpecimenSheet states facts and never instructs` | every string in the sheet | none in the banned lexicon | A specimen is copied from; an imperative here becomes an imperative on a result screen |
| 5 | `LonjaSpecimenSheet lays out at textScaler 2.0 without overflow` | scale 2.0 | no overflow exception | `SPEC.md` §4.9's 200 % requirement, on the first surfaces that could break it. The whole-app audit is E19's |
| 6 | loop × 6 — `LonjaSpecimenSheet matches the <skin> golden at <density> density` | six combinations | pixel match | The six renderings T04's orthogonality produces, each one a lane somebody would otherwise never look at |
| 7 | `ar - LonjaSpecimenSheet matches the paper golden in Arabic` | `ar`, paper | pixel match | The Naskh stack, the 1.12 uplift and zero tracking are T05's code and nothing else in this epic renders them; without E06's font this lane would be empty boxes |
| 8 | `greyscale - LonjaSpecimenSheet matches the desaturated paper golden` | saturation 0 | pixel match | `SPEC.md` §4.9 asks for a greyscale screenshot test by name |
| 9 | `greyscale - the primary and destructive fields are within 3 L* of each other` | `harbour30`, `oxblood28` | `< 3.0` | The measurement that makes the other three assertions necessary: 2.3 L\* apart is the same box once hue is gone |
| 10 | `greyscale - LonjaButton.primary and .destructive differ in rule weight` | both | `1.0` vs `2.0` | The first non-colour signal, and the one that survives both sunlight and desaturation |
| 11 | `greyscale - LonjaButton.primary and .secondary differ in field rather than in hue` | both | filled vs transparent | The second: field-versus-outline is a shape difference, not a colour one |
| 12 | `greyscale - every button rung in the specimen carries a distinct label` | the three labels | three distinct strings | The third signal, and the only one a screen reader can use |

```dart
// app/test/theme/lonja_specimen_golden_test.dart
@Tags(<String>['golden'])
library;

import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/lonja_specimen.dart';
import '../../testing/theme/pump_lonja.dart';

const ColorFilter _greyscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0,
]);

void main() {
  for (final LonjaSkin skin in LonjaSkin.values) {
    for (final bool gloved in <bool>[false, true]) {
      final String density = gloved ? 'glove' : 'standard';
      testWidgets('LonjaSpecimenSheet matches the ${skin.name} golden at $density density',
          (WidgetTester tester) async {
        await pumpLonja(tester, const LonjaSpecimenSheet(), skin: skin, gloved: gloved);
        await expectLater(
          find.byType(LonjaSpecimenSheet),
          matchesGoldenFile('goldens/${skin.name}_$density.png'),
        );
      });
    }
  }

  testWidgets('greyscale - LonjaSpecimenSheet matches the desaturated paper golden',
      (WidgetTester tester) async {
    await pumpLonja(
      tester,
      const ColorFiltered(colorFilter: _greyscale, child: LonjaSpecimenSheet()),
    );
    await expectLater(
      find.byType(LonjaSpecimenSheet),
      matchesGoldenFile('goldens/paper_greyscale.png'),
    );
  });
}
```

```dart
// app/test/theme/greyscale_proof_test.dart
import 'package:catchlaw/theme/lonja_primitives.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/colour_math.dart';

void main() {
  test('greyscale - the primary and destructive fields are within 3 L* of each other', () {
    final double delta =
        (cieLStar(LonjaPrimitives.harbour30) - cieLStar(LonjaPrimitives.oxblood28)).abs();
    expect(delta, lessThan(3.0)); // 2.3 — the same box once hue is removed
  });

  // … one test per row above, one behaviour each
}
```

```dart
// app/test/theme/gate_targets_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final String path in <String>['lib/theme', 'lib/ui/core/ui']) {
    test('Lonja gate targets contain Dart files in $path', () {
      final Iterable<FileSystemEntity> dart = Directory(path)
          .listSync(recursive: true)
          .where((FileSystemEntity e) => e.path.endsWith('.dart'));
      expect(dart, isNotEmpty, reason: 'a gate over an empty tree reports success');
    });
  }
}
```

**Run:** `cd app && flutter test test/theme/` → 12 named rows, one of which is a loop of 6, so 17
failures. The eight golden lanes fail because no baseline exists; that is the correct red. If a
golden *passes* before the baseline is generated, the comparator is looking at the wrong directory.

## Implementation outline

1. `gate_targets_test.dart` first, then run the six gates by hand and read their output rather than
   their exit codes. A check that reports nothing on a tree you know contains 40 colours is a check
   that is not scanning what you think.
2. `LonjaSpecimenSheet` in `app/testing/theme/` — a `Column` of labelled blocks, one per artefact
   group, in a fixed 420 × 1400 logical-pixel box so the lanes are stable. Real content from
   `SPEC.md` and the type-ramp reference: `Below the minimum`, `38 cm`,
   `minimum 45 cm (total length)`, `Ministerial Decision 580/2015, Art. 3`, `هامور Hamour`,
   `Epinephelus coioides`.
3. The four non-golden proofs (rows 1–5, 9–12). They must be green *before* any baseline is
   generated, because a baseline generated from a broken sheet is a broken baseline that now passes
   forever.
4. `--update-goldens` on Linux, once, to produce the eight `.png` files beside the test. Commit them.
   Never regenerate a baseline to silence a diff: read the diff in `test/**/failures/`, which
   `.gitignore` already excludes.
5. Tag the golden file so CI's Linux job runs it and a local macOS run excludes it. Reuse E06's tag
   if it established one; do not add a second name for the same idea.
6. Check `.github/workflows` for the six gate invocations against `app/lib`. Add only the ones that
   are missing — a gate that exists and is not run is not a gate — and change nothing else in CI.
7. Run every gate one final time, then `/simplify` and `/code-review` across the whole epic's diff,
   not just this task's.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 named tests pass, including the loop of 6, and each failed first.
- [ ] `app/lib/theme` and `app/lib/ui/core/ui` are proved non-empty before any gate green is
      believed.
- [ ] Eight golden baselines exist beside their test and were generated on Linux.
- [ ] The greyscale lane is accompanied by four assertions, so the proof survives both rungs turning
      into identical grey boxes.
- [ ] The specimen renders all sixteen type steps and all four rule weights.
- [ ] The specimen contains no string from the banned lexicon in
      `product-invariants.md` invariant 2.
- [ ] All six gates clean against `app/lib`, each with the explicit target directory (D-1):
      `check_app_invariants.sh`, `check_lonja_tokens.sh`, `check_lonja_type.sh`,
      `check_lonja_buttons.sh`, `check_lonja_dialogs.sh`, `check_lonja_icons.sh`.
- [ ] `tools/gates/no_directional_geometry.sh app/lib` clean (D-8).
- [ ] Every gate the epic names is invoked by CI against `app/lib`.

## Gates

```bash
# CONVENTIONS.md §7 — believe nothing below until this prints a non-zero count.
find app/lib -name '*.dart' | wc -l

cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
cd .. && .claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh       app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh            app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh            app/lib
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh app/lib
.claude/skills/lonja-icons-and-plates/scripts/check_lonja_icons.sh     app/lib
tools/gates/no_directional_geometry.sh                                 app/lib
```

## Then

```
/simplify        → act on it, across the whole epic diff
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(check): prove the Lonja gates scan a real tree and that no state rides on colour alone

CONVENTIONS.md §7 says a gate pointed at an empty path reports success, which
makes it worse than no gate. check_lonja_tokens.sh app/lib has been green
since E01 over a tree with almost no colour in it, so the first assertion here
is that its targets contain Dart files at all; only then is a green worth
reading.

The greyscale proof is a correctness test, not a nicety. This epic's own
palette makes the case: the primary field is harbour30 at L* 30.28 and the
destructive field is oxblood28 at 27.96 — 2.3 L* apart, the same box once hue
is gone. Downstream it is worse, because oxblood carries two states,
below-minimum and protected, so hue distinguishes nothing between them even in
full colour.

A greyscale png alone would not prove anything: it passes just as happily if
both rungs become identical grey boxes together. So the lane is paired with
four assertions — fields differ in kind, rule weights differ, labels differ,
and the two field luminances are within 3 L* — and the last is what makes the
first three load-bearing.

Eight lanes and no more: three skins x two densities, one ar lane because the
Naskh resolution is this epic's own code and nothing else renders it, and one
greyscale lane because SPEC.md §4.9 asks for it by name. Generated on Linux
with E06's font config; the other five locales are E20's whole-app matrix.

Task: E07/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
