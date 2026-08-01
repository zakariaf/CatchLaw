# E19/T05 — The greyscale golden

| | |
|---|---|
| **Epic** | E19 — Accessibility, sunlight and glove modes |
| **Branch** | `epic/19-accessibility` (shared) |
| **Commit** | `test(a11y): prove no state is carried by colour alone` |
| **Depends on** | T01 (the registry); E10/T02 (`kVerdictSignals`, the four categories); E06/T08 (the real font in `flutter_test_config.dart`) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.9 "Colour independence" row (*result never relies on colour alone — icon + words + colour; passes a greyscale screenshot test*), §13 (never colour alone) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-verdict-and-status` | Rules 3 and 4, and `references/states-and-signals.md`'s signal matrix — which three signals each category spends, and why protected cannot be below-minimum in another shade |
| `catchlaw-conventions-index` | Invariant 4 and `references/product-invariants.md`'s state table — this task is that invariant's proof, and `check_app_invariants.sh` check 5 is its grep |
| `widget-golden-and-a11y-testing` | `references/golden-two-lanes.md` (goldens earn their keep only for what geometry cannot see; tag them; block `--update-goldens`) and the argument in `references/a11y-guidelines-and-limits.md` that grayscale is **not** an independent contrast channel |
| `accessibility-as-code` | Rule 6 and "Never state through color alone" — icon shape, the word, the structure, and the position, as independent channels |
| `lonja-design-tokens` | Rule 9 — semantic colour is framed, never filled, which is why the frame survives desaturation as a shape rather than as a hue |
| `testing-strategy` | Rule 3 — the byte-difference row is an invariant over all six pairs, not one lucky example |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.9 "Colour independence" row | The requirement and its done condition, which names a greyscale **screenshot** test by hand |
| `.claude/skills/lonja-verdict-and-status/references/states-and-signals.md` | "The signal matrix", "Why protected cannot be below-minimum in another shade", "Greyscale and sunlight proof" | The per-category glyph, headline and structural third; the four goldens that skill requires before a verdict change lands |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariant 4 table | The five states and the note that oxblood carries two of them, so hue distinguishes nothing between them |
| `.claude/skills/widget-golden-and-a11y-testing/references/golden-two-lanes.md` | "First decide whether you need a golden at all", "Discipline" | Why a golden cannot assert anything; `@Tags(['golden'])`; generate in one pinned environment; block accidental blessing |
| `.claude/skills/widget-golden-and-a11y-testing/references/a11y-guidelines-and-limits.md` | "Contrast: a pure-Dart unit test" | The proof that `contrastRatio(gray(a), gray(b)) == contrastRatio(a, b)` — which is why this task is not a contrast test |
| `FLUTTER_GUIDE.md` | §6.4, both golden points | Real fonts or every locale renders identical boxes; goldens are host-dependent, so one platform is the source of truth |
| `epics/CONVENTIONS.md` | §6, §9 invariant 4 | Golden files live next to their test; `**/failures/` is already ignored |

## What this delivers

- `app/test/a11y/support/greyscale.dart` — `kDesaturate` (the 5 × 4 luminance matrix),
  the `Greyscale` wrapper widget, and `applyDesaturation(int argb)` for the instrument's self-test.
- `app/test/a11y/signal_independence_test.dart` — the structural gate: glyph, headline and the
  presence or absence of the measurement sub-line, per category, plus the pairwise byte difference
  with hue removed.
- `app/test/a11y/greyscale_golden_test.dart` — `@Tags(['golden'])`, six `matchesGoldenFile` cases.
- `app/test/a11y/goldens/` — six blessed PNGs, generated on Linux CI only:
  `greyscale_verdict_meets.png`, `greyscale_verdict_below_minimum.png`,
  `greyscale_verdict_closed_season.png`, `greyscale_verdict_protected.png`,
  `greyscale_stale_over_meets.png`, `greyscale_species_results.png`.

## Why it is built this way

**Three artefacts, and only one of them is the gate.**

1. **The structural rows are the gate.** Each category is asserted to carry its glyph, its headline
   and its structural third, and the four glyphs and four headlines are asserted pairwise distinct.
   These fail with a sentence naming the category and the missing signal.
2. **The pairwise byte difference is the mechanical proof.** Each category is rendered inside a
   `RepaintBoundary` wrapped in a saturation-zero `ColorFiltered`, converted to PNG bytes through
   `RenderRepaintBoundary.toImage()`, and every one of the six pairs is asserted to differ. This is
   the sentence *"passes a greyscale screenshot test"* turned into an assertion instead of a
   screenshot somebody looked at. It is **necessary and not sufficient** — two images could differ by
   one antialiased pixel — which is exactly why row 1 exists above it.
3. **The six goldens are the regression record.** A golden cannot assert anything; it asserts that
   these pixels equal the pixels somebody blessed. Its value here is that the blessed image is
   *readable by a human in a pull request*: a reviewer sees the four stamps with the hue removed and
   can tell them apart, or cannot. That is worth six files and no more.

**This is not a contrast test, and saying so is load-bearing.** `Color.computeLuminance()` is
chroma-blind, so any correct grey of a colour preserves its luminance exactly, and therefore
`contrastRatio(gray(a), gray(b)) == contrastRatio(a, b)` for **all** pairs — wrapping the WCAG
inputs in a `gray()` proves nothing. Contrast is T04's job and is asserted on colour values there.
What a desaturated **render** does prove is something a ratio cannot: that the four states remain
mutually distinguishable when hue is removed, which is a property of the glyph, the wording and the
layout rather than of any two colours.

**Protected and below-minimum are the pair the whole test exists for.** Both print in oxblood
`#7A2320`, so hue carries **zero** information between them, and they are different offences with
different penalties. They are separated by `Icons.block` against `Icons.close`, by their headlines,
and structurally: protected prints **no measurement sub-line at all**, because a measurement would
imply a threshold that does not exist. A reader who takes only the colour reads "too small" and
reaches for a bigger one of the same protected species. That is the failure, stated in
`states-and-signals.md`, that this task is the guard against.

**Six goldens, not twenty-four.** `states-and-signals.md` asks for four goldens per category —
paper colour, paper desaturated, sunlight, and RTL Arabic. Paper-colour and sunlight lanes are E07's
(its DoD already runs six lanes: three themes × two densities); the RTL Arabic lane is E20's, which
owns the six-locale matrix. This task owns the **desaturated** lane and nothing else, plus two
surfaces beyond the stamp: the stale axis over an otherwise unchanged verdict, and the S5 results
list, whose one-word hints (`45 cm` / `protected` / `closed`) are the app's other colour-coded state.
`FLUTTER_GUIDE.md` §6.4 says keep the golden **matrix** small; this is the smallest set that covers
every state in invariant 4's table.

**The filter is a gamma-space luminance matrix, deliberately.** `kDesaturate` weights the channels
0.2126 / 0.7152 / 0.0722 and applies them to the encoded values, which is what a system-wide
grayscale accessibility mode does. `computeLuminance()` linearises first, so the two are not
photometrically identical — and they agree on the only question being asked, *is there any
difference left*. The instrument gets its own self-test row, because a filter that is subtly wrong
turns six goldens into six pictures of nothing.

**Rejected — `alchemist`'s CI lane for these images.** `FLUTTER_GUIDE.md` §6.3 records that its CI
mode replaces glyphs with coloured blocks; a lane that erases the words would erase two of the three
signals under test.

**Rejected — a greyscale golden of every one of the 28 surfaces.** Twenty-eight blessed images that
red on any host that rasterises differently, to guard a property that only four screens actually
carry. The rest of the app's states are words and shapes already.

**Rejected — `--update-goldens` in CI.** A pipeline step that blesses turns the suite into a ratchet
that approves whatever shipped. Regeneration is a deliberate, reviewed, local act in a titled commit.

## Tests first

Write every row before touching the widgets. Run them. **They must fail** — and the goldens do not
exist, so their rows fail on a missing file, which is the correct first failure. Bless the six images
**only after** rows 1–9 pass, or the blessed picture records whatever was wrong.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `applyDesaturation returns equal channels for a saturated red` | `#FFFF0000` | R == G == B | The instrument's self-test. A matrix with a transposed row leaves chroma in place and turns six goldens into six pictures of nothing |
| 2 ×4 | `ResultVerdictPanel for ${category} carries a glyph, a headline and a structural third` | each category | the glyph, the headline text, and the sub-line present or absent per the signal matrix | Three signals per state, at most one of which may be hue — the structural gate the golden sits on top of |
| 3 | `The four verdict categories use four distinct glyphs` | `kVerdictSignals` | four different `IconData` | Reusing `Icons.close` for `.protected` collapses two legally distinct offences into one mark the moment hue is gone |
| 4 | `The four verdict categories use four distinct headlines` | `kVerdictSignals` | four different strings | The word is the second non-hue signal; two categories sharing a headline leaves only the glyph |
| 5 | `VerdictCategory.protected prints no measurement sub-line and belowMinimum does` | both | absent, then present | The structural third for the pair that shares oxblood — the one distinction hue cannot make |
| 6 ×6 | `greyscale - the ${a} and ${b} stamps render different pixels` | each of the six category pairs | PNG bytes differ | *"Passes a greyscale screenshot test"* as an assertion. Necessary, not sufficient — row 2 is why |
| 7 | `greyscale - the stale bar changes the sheet without changing the stamp` | meets, fresh vs expired | the two renders differ, and the stamp subtree's bytes do not | Staleness is an axis, not a fifth category: the bar states the date and the verdict beneath it is unchanged |
| 8 | `greyscale - the species search hints render differently for 45 cm, protected and closed` | S5 with three rows | the three hint subtrees differ | The app's other colour-coded state. A hint that is only a colour is a hint that says nothing in the sun |
| 9 | `Species search hints state a word for every hint state` | S5 rows | each hint's text is non-empty | The cheap structural half of row 8, and the one that names which row is wrong |
| 10 ×4 | `greyscale - the ${category} stamp matches its golden` | each category, desaturated | `matchesGoldenFile` | The human-readable regression record; a reviewer can see four distinguishable stamps or cannot |
| 11 | `greyscale - the stale bar over a meets stamp matches its golden` | expired meets | `matchesGoldenFile` | The ochre bar is the fifth row of invariant 4's table and has no glyph-versus-glyph pair to compare against |
| 12 | `greyscale - the species results list matches its golden` | S5, three hint states | `matchesGoldenFile` | The one non-verdict surface in the invariant-4 table |

```dart
// app/test/a11y/support/greyscale.dart
import 'package:flutter/widgets.dart';

/// A 5x4 saturation-zero matrix using Rec. 709 luminance weights, applied to
/// encoded channel values — which is what a system-wide grayscale
/// accessibility mode does. Deliberately not computeLuminance(), which
/// linearises first; the two agree on the only question asked here, namely
/// whether any difference survives.
const List<double> kDesaturate = <double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
];

class Greyscale extends StatelessWidget {
  const Greyscale({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColorFiltered(
        colorFilter: const ColorFilter.matrix(kDesaturate),
        child: RepaintBoundary(key: const ValueKey<String>('greyscale.boundary'), child: child),
      );
}

/// The same arithmetic in pure Dart, so the matrix can be self-tested without
/// rendering anything.
({int r, int g, int b}) applyDesaturation(int r, int g, int b) {
  final int y = (kDesaturate[0] * r + kDesaturate[1] * g + kDesaturate[2] * b).round();
  return (r: y, g: y, b: y);
}
```

```dart
// app/test/a11y/signal_independence_test.dart
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:catchlaw/ui/result/widgets/result_verdict_signals.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/models/result_fixtures.dart';
import '../utils/harness.dart';
import 'support/greyscale.dart';

Future<Uint8List> desaturatedBytes(WidgetTester tester) async {
  final RenderRepaintBoundary boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey<String>('greyscale.boundary')));
  final ui.Image image = await boundary.toImage();
  final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void main() {
  test('The four verdict categories use four distinct glyphs', () {
    final Set<IconData> glyphs =
        kVerdictSignals.values.map((VerdictSignals s) => s.glyph).toSet();
    expect(glyphs, hasLength(4),
        reason: 'two categories share a mark, so with hue removed they are one state');
  });

  final List<VerdictCategory> categories = VerdictCategory.values;
  for (int i = 0; i < categories.length; i++) {
    for (int j = i + 1; j < categories.length; j++) {
      final VerdictCategory a = categories[i];
      final VerdictCategory b = categories[j];

      testWidgets('greyscale - the ${a.name} and ${b.name} stamps render different pixels',
          (WidgetTester tester) async {
        await pumpGreyscaleStamp(tester, kStampFor(a));
        final Uint8List first = await desaturatedBytes(tester);

        await pumpGreyscaleStamp(tester, kStampFor(b));
        final Uint8List second = await desaturatedBytes(tester);

        expect(first, isNot(equals(second)),
            reason: '${a.name} and ${b.name} are indistinguishable without hue — '
                'invariant 4');
      });
    }
  }

  // … one test per row above, one behaviour each
}
```

```dart
// app/test/a11y/greyscale_golden_test.dart
@Tags(<String>['golden'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../utils/harness.dart';
import 'support/greyscale.dart';

/// The blessed filenames, declared rather than derived: a slug computed from an
/// enum name silently renames every golden the day somebody renames a category.
const Map<VerdictCategory, String> kGoldenSlug = <VerdictCategory, String>{
  VerdictCategory.meets: 'meets',
  VerdictCategory.belowMinimum: 'below_minimum',
  VerdictCategory.closedSeason: 'closed_season',
  VerdictCategory.protected: 'protected',
};

void main() {
  for (final VerdictCategory category in VerdictCategory.values) {
    testWidgets('greyscale - the ${category.name} stamp matches its golden',
        (WidgetTester tester) async {
      tester.useDevice(Device.compact);
      await pumpGreyscaleStamp(tester, kStampFor(category));

      await expectLater(
        find.byKey(const ValueKey<String>('greyscale.boundary')),
        matchesGoldenFile('goldens/greyscale_verdict_${kGoldenSlug[category]}.png'),
      );
    });
  }
}
```

**Run:** `cd app && flutter test test/a11y/signal_independence_test.dart` → 1 + 4 + 3 + 6 + 2
failures. Then `flutter test --tags golden test/a11y/greyscale_golden_test.dart` → six failures on
missing files. **Do not bless until the structural rows are green**, or the blessed image is a
picture of the bug.

## Implementation outline

1. Write `greyscale.dart` and row 1. Verify the instrument before rendering anything with it.
2. Write `signal_independence_test.dart` in full. Run. Rows 2–5 are assertions about
   `kVerdictSignals` as E10/T02 built it; if one fails, the fix is in E10's signals map, in this
   commit, with the category named in the commit body.
3. Rows 6–8 need each subject inside the `Greyscale` wrapper's `RepaintBoundary`. Add
   `pumpGreyscaleStamp` and `pumpGreyscaleSurface` to `app/test/utils/harness.dart` — one wrapper,
   used by both the byte-difference rows and the golden rows, so the golden and the assertion can
   never diverge in what they render.
4. Only then write `greyscale_golden_test.dart`, tagged `@Tags(['golden'])` so
   `flutter test --exclude-tags golden` stays fast.
5. Generate the six blessed PNGs **on Linux CI**, not locally. `FLUTTER_GUIDE.md` §6.4 point 2:
   font rasterisation, subpixel positioning and antialiasing differ across hosts, and a macOS-blessed
   file reds the lane on every subsequent run.
6. Confirm `app/test/a11y/goldens/` is committed and `**/failures/` is still ignored.
7. Re-run the whole `app` suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 rows pass (2, 6 and 10 generated), and each failed first.
- [ ] The six pairwise byte-difference cases cover **all** six category pairs, not a sample.
- [ ] Six golden files exist under `app/test/a11y/goldens/`, generated on Linux CI only, and the
      commit body names the CI run that produced them.
- [ ] `@Tags(['golden'])` on the golden file; `flutter test --exclude-tags golden` runs the
      structural rows without any image comparison.
- [ ] CI does not pass `--update-goldens` anywhere.
- [ ] `check_app_invariants.sh app/lib` check 5 (colour-only status encoding) and
      `check_lonja_verdict.sh app/lib` check 6 are clean — the greps this task's assertions back.
- [ ] No file in this task claims the greyscale render proves contrast; the word "contrast" appears
      only as a pointer to T04.
- [ ] Nothing under `packages/rule_engine/` changed.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze
cd app && flutter test --exclude-tags golden
cd app && flutter test --tags golden          # Linux CI only
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh    app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(a11y): prove no state is carried by colour alone

Invariant 4 was an instruction to reviewers. It is now three artefacts, and
only one of them is the gate: each category is asserted to carry its glyph,
its headline and its structural third, and the four glyphs and four
headlines are pairwise distinct. On top of that, each pair of stamps is
rendered through a saturation-zero filter and its PNG bytes compared — six
pairs, all six different — which is SPEC.md §4.9's "passes a greyscale
screenshot test" written as an assertion rather than as a screenshot
somebody looked at once.

The pair this exists for is protected against below-minimum. Both print in
oxblood, so hue carries zero information between them; they separate on
Icons.block against Icons.close, on the headline, and on protected printing
no measurement sub-line at all. A reader who takes only the colour reads
"too small" and reaches for a bigger one of the same protected species.

Six goldens, on the desaturated lane only: the colour and sunlight lanes
are E07's and the Arabic RTL lane is E20's. Blessed on Linux CI.

Task: E19/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
