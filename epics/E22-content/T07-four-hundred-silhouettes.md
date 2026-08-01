# E22/T07 — Four hundred silhouettes

| | |
|---|---|
| **Epic** | E22 — Content authoring at scale |
| **Branch** | `epic/22-content/T07-silhouettes` (cut from a current `main`) |
| **Commit** | `feat(content): originate ~400 species silhouettes and assert their shape budget (A14)` |
| **Depends on** | T01 (the authoring guide and A11) |
| **Size** | L |
| **Spec** | `SPEC.md` §8 silhouette row, §7.1 `species.silhouette_asset`, §4.9 (sunlight, glove), §13 (low-end devices, contrast), §6 S5/S6 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-icons-and-plates` | Owns the drawing. Rules 2, 3, 9 and 11, and `references/engraved-plates.md`'s silhouette column — the 140 × 64 grid, outline plus the eye, ≤ 8 subpaths, no hatching, and what a silhouette is allowed to claim |
| `catchlaw-content-pipeline` | A5 already fails the build on a missing silhouette; this task delivers the files that assertion has been waiting for, and adds the shape half of it |
| `catchlaw-conventions-index` | Invariant 4 — colour is never the only signal — is why a silhouette is monochrome geometry and not a tinted icon; and rule 9, routing: the drawing is Lonja's, the file is the pipeline's |
| `catchlaw-reference-database` | Rule 8's neighbourhood: `species.silhouette_asset` is `NOT NULL` in the shipped read-only asset, so a missing drawing is a build failure and never a runtime placeholder |
| `testing-strategy` | These are file-shape assertions over a real asset tree; pure Dart, no widget binding, and a golden would be the wrong tool |
| `dependency-hygiene` | The shape check parses XML with what the workspace already has; a new SVG package for four attribute checks is not warranted |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, "Species silhouettes" row | **Originated SVG line art**, ours, ~**6 MB / ~400 species**, `assets/sil/` |
| `SPEC.md` | §7.1, `species` | `silhouette_asset TEXT NOT NULL` — the column that makes a missing drawing unshippable |
| `SPEC.md` | §4.9 | Sunlight mode is *a third theme, not a dark-mode variant: maximum contrast, monochrome plus result colour*; glove mode grows targets to ≥ 56 dp |
| `SPEC.md` | §13 | Contrast ≥ 4.5:1, ≥ 7:1 in sunlight; *SVGs rasterised at display size and cached by key*; fully usable on 2 GB RAM, Android 7 |
| `.claude/skills/lonja-icons-and-plates/references/engraved-plates.md` | "Silhouette versus plate"; "Generation pipeline"; "What a plate must never be" | 140 × 64, outline plus the eye, no hatching, ≤ 8 subpaths, rendered at 44 px in list rows, what it claims — and the SVG shape contract: stroke-only, `stroke="currentColor"`, no `<style>`, no `<image>`, no gradients, no root `transform` |
| `.claude/skills/lonja-icons-and-plates/SKILL.md` | Rules 2, 3, 9, 11; "Asset naming and layout" | Stroke-only with butt caps and mitre joins; **stroke width tracks the theme ink weight, never the glyph size**; `lower_snake_case` binomial keys; rasters banned |
| `.claude/skills/lonja-icons-and-plates/references/icon-system.md` | "Asset and file layout"; "Naming rules" | `lower_snake_case.svg`, the binomial for a species file, no size suffix, no locale, no `_v2` — and the layout claim this task has to reconcile with `SPEC.md` §8 |
| `epics/DECISIONS.md` | D-1 | The app lives under `app/`, so `SPEC.md` §8's `assets/sil/` is `app/assets/sil/` |
| `epics/E04-content-build/T05-citations-and-assets.md` | A5 | The assertion that already resolves `silhouette_asset` against the assets root, and the recorded cause: *a shellfish added late, art not commissioned* |
| `FLUTTER_GUIDE.md` | §6.1, §6.4 | Test naming with receipts, and the budget: an SVG shape check is a pure-Dart unit test and a golden would be the wrong tool |

## What this delivers

- `app/assets/sil/<binomial>.svg` — roughly **400** originated line drawings, `lower_snake_case`
  binomial filenames, total under **6 MB** (`SPEC.md` §8).
- `content/shared/silhouettes.yaml` — the ledger: `species_id`, `asset`, `family_id`, the commissioned
  artist and the work-for-hire agreement id, `delivered_on`, `accepted_on`. Every drawing is
  originated, so the death-year test does not apply and the ledger row still does
  (`licence-provenance.md`, `plates.yaml` required fields).
- `tools/content_builder/lib/src/assert/a14_silhouette_shape.dart` — `SilhouetteShapeAssertion`.
- `tools/content_builder/lib/src/art/svg_shape.dart` — the SVG reader: viewBox, subpath count,
  banned elements and attributes, byte size.
- `content/ATTRIBUTIONS/silhouettes.md` — generated from the ledger, so `ATTRIBUTIONS.md` (E18) can
  state who drew the art without anybody maintaining a second list.
- `tools/content_builder/test/art/svg_shape_test.dart`,
  `test/assert/a14_silhouette_shape_test.dart`, `test/content/silhouette_corpus_test.dart`.

## Why it is built this way

**The SVG carries geometry; the theme carries ink.** `lonja-icons-and-plates` rule 3 is the whole
argument: stroke width tracks the theme's ink weight and **never** the glyph size, because the burin
does not change width with the size of the figure — and a hardcoded width *freezes sunlight out*. So
A14 requires `stroke="currentColor"` and **forbids** a `stroke-width` attribute anywhere in the file.
The renderer supplies the width from `LonjaIconTheme` (E07), which is what makes the same drawing
legible on paper at 1.45 and in sunlight at 1.95. An asset that ships its own width is legible on the
artist's screen and invisible on a wet phone at noon, and no test in this repository would catch it.

**"Legible at arm's length in sunlight" is bought with contrast and geometry, not with a number in a
file.** §4.9 defines sunlight mode as maximum contrast, monochrome plus result colour, and §13 sets
≥ 7:1 there. A stroke-only drawing with no fill and no grey inherits `ink` on `paper` or `sun-ink`
`#000000` on `sun-paper` `#FFFFFF` (`engraved-plates.md`), which is 21:1 — the contrast question is
answered by the theme. What this task owns is the geometry: **no fill**, so the shape cannot collapse
to a blob at 44 px; **≤ 8 subpaths**, so there is nothing thinner than an outline to lose; **outline
plus the eye only**, no hatching, because hatch lines at 44 px alias into grey. Those three are
`engraved-plates.md`'s silhouette column, and A14 checks all three.

**A silhouette is a hint and must not start claiming to be evidence.** `lonja-icons-and-plates`
rule 7 and `engraved-plates.md`: a silhouette says *"this is roughly the shape you have"*; a plate
says *"these are the characters that identify this specimen"*, and it is the plate that carries the
legal weight of the identification. The temptation, when a plate has not been cleared for a protected
species, is to add fin rays and spots to the silhouette until it will do. A14's subpath ceiling is
what makes that a build failure rather than a judgement call, and T08 is where the plate actually
comes from.

**Files are named `lower_snake_case` by the binomial, and any kebab-case seed asset is renamed here.**
`lonja-icons-and-plates` rule 9 and `icon-system.md`'s naming rules are explicit and give the reason:
a locale-named key silently binds artwork to one locale, and `grouper.svg` collides the first time a
second grouper is imported. `SPEC.md` names no convention at all, so there is no conflict to resolve —
the skill wins uncontested. E04's prose used `venerupis-corrugata.svg`; A14 pins snake_case, and this
task renames the seed asset and updates `species.silhouette_asset` in the same commit, because two
conventions in one directory is the state that produces a "file not found" for the 401st species.

**Where the file ends up at runtime is a gap, and this task says so instead of deciding it.**
`SPEC.md` §8 bundles ~6 MB under `assets/sil/` and §13 describes *SVGs rasterised at display size and
cached by key*; `icon-system.md` says authored SVG lives in `assets_src/`, is not bundled, and becomes
generated const Dart, with *`pubspec.yaml` declaring `assets/brand/` and nothing else under
`assets/`*. Neither is one of D-1…D-9 and no gate script enforces either, so D-2's tie-break does not
apply. This task authors the SVG at `app/assets/sil/` per `SPEC.md` §8, because SPEC is authoritative
for the product and the drawing is the deliverable under either layout. The rendering decision belongs
to E08 and needs a `DECISIONS.md` entry; it is recorded in this epic's Risks and named in
`content/AUTHORING.md`. **Rejected:** quietly generating a const Dart table here, which would decide a
UI question inside a content epic and put a 6 MB generated file in front of a reviewer who did not ask
for one.

**The size budget is per file and in aggregate, and the per-file number is derived, not invented.**
§8 gives ~6 MB for ~400 species — 15 KB each on average. A14's aggregate ceiling is **6 MB**, straight
from §8. Its per-file ceiling is **24 KB**: the average with headroom, so an unusually detailed
crustacean passes and a 300 KB file that somebody exported from a photo trace does not. §13's low-end
target — 2 GB RAM, Android 7 — is the reason a ceiling exists at all: the browse grid rasterises what
is visible, and one 300 KB path set is a frame drop on the device this app is for.

**A silhouette is never mirrored.** `icon-system.md`'s mirroring table: *a fish faces the way it was
engraved; mirroring it changes the specimen*. That is a rendering rule (E20 owns RTL), but it has an
authoring consequence this task owns — the drawing must be composed to read facing one way in both
`ar` and `en`, so a species whose diagnostic marking is on one flank is drawn with that flank shown.
`content/AUTHORING.md` gains the note; the artist brief carries it.

## Tests first

Write every row before commissioning a drawing or touching `svg_shape.dart`. Run them.
**They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SvgShape.read reports the viewBox` | `viewBox="0 0 140 64"` | `(140, 64)` | The grid `engraved-plates.md` fixes for a silhouette |
| 2 | `SilhouetteShapeAssertion reports A14 when the viewBox is not 140 by 64` | `0 0 300 124` | one `A14` | 300 × 124 is the **plate** grid; a plate shrunk into a row is the mistake the two grids exist to prevent |
| 3 | `SilhouetteShapeAssertion reports A14 when the file declares a stroke-width` | `stroke-width="1.6"` | one `A14` quoting the theme ink weight | Rule 3; a frozen width means sunlight never arrives and no widget test would catch it |
| 4 | `SilhouetteShapeAssertion reports A14 when stroke is not currentColor` | `stroke="#16201C"` | one `A14` | A literal ink colour survives the sunlight theme switch and stops being ink |
| 5 | `SilhouetteShapeAssertion reports A14 when a path declares a fill` | `fill="#000"` | one `A14` | Rule 2: closed shapes are outlines; a fill collapses to a blob at 44 px in sunlight |
| 6 | `SilhouetteShapeAssertion accepts fill="none"` | `fill="none"` | no failures | The explicit form an SVG editor writes, and it must not be mistaken for a fill |
| 7 | `SilhouetteShapeAssertion reports A14 when the file has more than eight subpaths` | 9 subpaths | one `A14` naming the count | `engraved-plates.md`'s ceiling; past it the drawing is claiming to be a plate |
| 8 | `SilhouetteShapeAssertion accepts a file with eight subpaths` | 8 | no failures | The boundary, on the passing side |
| 9 | `SilhouetteShapeAssertion reports A14 for a banned element` (loop over `image`, `style`, `linearGradient`, `text`) | one `<$element>` | one `A14` per case | The SVG shape contract; `<image>` in particular is a photograph smuggled past the raster ban (rule 11) |
| 10 | `SilhouetteShapeAssertion reports A14 for a transform on the root element` | `<svg transform=…>` | one `A14` | A root transform makes the viewBox a lie and every downstream size wrong |
| 11 | `SilhouetteShapeAssertion reports A14 when a file exceeds 24 KB` | a 25 KB file | one `A14` naming the size | Derived from §8's ~6 MB / ~400; a 300 KB path set is a traced photograph and a frame drop on Android 7 |
| 12 | `SilhouetteShapeAssertion reports A14 when the asset tree exceeds 6 MB` | a tree over budget | one `A14` naming the total | §8's number, checked in aggregate because 400 files can each pass and still blow it |
| 13 | `SilhouetteShapeAssertion reports A14 for a filename that is not a lower_snake_case binomial` (loop over `venerupis-corrugata.svg`, `Hamour.svg`, `epinephelus_coioides_v2.svg`) | `$name` | one `A14` per case | Rule 9 and `icon-system.md`: no kebab, no locale name, no version suffix |
| 14 | `SilhouetteShapeAssertion reports A14 when silhouettes.yaml names no artist for a drawing` | ledger row without artist | one `A14` | Originated art still fills a ledger row; S17 renders it |
| 15 | `SilhouetteShapeAssertion reports A14 when a file on disk has no ledger row` | orphan `.svg` | one `A14` | The reverse of A5: art nobody commissioned, attributed to nobody |
| 16 | `Silhouette corpus carries a drawing for every species` | `content/shared/species.yaml` | every `silhouette_asset` resolves | A5's promise, met at last; ~400 files |
| 17 | `Silhouette corpus groups every drawing under a family` | `silhouettes.yaml` × `families.yaml` | every `family_id` resolves | §7.1's `family` table; the browse surface reads it and an orphan family is an empty section |
| 18 | `Silhouette corpus keeps the whole tree under 6 MB` | `app/assets/sil/` | total under budget | §8's number, asserted against the real tree rather than a fixture |
| 19 | `sunlight - Silhouette corpus declares no colour value anywhere` | every file | no hex, no `rgb(`, no named colour except `currentColor` and `none` | §4.9: sunlight is monochrome plus result colour; invariant 4's other half — a drawing may not carry a signal at all |
| 20 | `Silhouette corpus renames the kebab-case seed asset` | `species.silhouette_asset` values | every value `lower_snake_case` | Two conventions in one directory is how the 401st species gets a "file not found" |

```dart
// tools/content_builder/test/assert/a14_silhouette_shape_test.dart
import 'package:content_builder/src/assert/a14_silhouette_shape.dart';
import 'package:content_builder/testing/fixtures/svg_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('SilhouetteShapeAssertion', () {
    test('reports A14 when the file declares a stroke-width', () {
      final source = contentSourceWithSilhouette(kSilhouetteWithStrokeWidth);
      final failures = const SilhouetteShapeAssertion().run(source).toList();

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A14');
      expect(failures.single.message, contains('stroke-width'));
    });

    test('accepts a file with eight subpaths', () {
      expect(
        const SilhouetteShapeAssertion().run(contentSourceWithSilhouette(kSilhouetteEightSubpaths)),
        isEmpty,
      );
    });

    for (final element in const ['image', 'style', 'linearGradient', 'text']) {
      test('reports A14 for a banned element ($element)', () {
        final source = contentSourceWithSilhouette(kSilhouetteContaining(element));

        expect(const SilhouetteShapeAssertion().run(source).single.message, contains(element));
      });
    }

    // … one test per row above, one behaviour each
  });
}
```

```dart
// tools/content_builder/test/content/silhouette_corpus_test.dart
import 'dart:io';
import 'package:content_builder/src/load/content_source.dart';
import 'package:test/test.dart';

void main() {
  late ContentSource corpus;

  setUpAll(() async {
    corpus = await ContentSource.load(Directory('../../content'));
  });

  test('Silhouette corpus carries a drawing for every species', () {
    for (final species in corpus.species) {
      final file = File('../../app/assets/sil/${species.silhouetteAsset}');

      expect(file.existsSync(), isTrue, reason: '${species.id} has no drawing');
    }
  });

  test('Silhouette corpus keeps the whole tree under 6 MB', () {
    final bytes = Directory('../../app/assets/sil')
        .listSync()
        .whereType<File>()
        .fold<int>(0, (sum, f) => sum + f.lengthSync());

    expect(bytes, lessThan(6 * 1024 * 1024));
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `(cd tools/content_builder && dart test test/art/ test/assert/a14_silhouette_shape_test.dart
test/content/silhouette_corpus_test.dart)` → 20 failures. Cases 12 and 18 will pass on an almost-empty
`app/assets/sil/` — they are budget ceilings, so they can only go red once the tree is full. Say so in
the commit body rather than pretending they were red; every other case must fail first, and case 6 in
particular passes against an implementation that ignores `fill` entirely.

## Implementation outline

1. `SvgShape.read(String xml)` — parse with the workspace's existing XML support; extract viewBox,
   element names, root attributes, `stroke`/`fill`/`stroke-width` occurrences, and count subpaths as
   `M`/`m` commands across every `d` attribute.
2. `SilhouetteShapeAssertion` — the shape rules, the filename rule, the byte ceilings, and the two
   directions of the ledger cross-check. One failure per violated rule, so a file breaking three
   reports three; the artist is going to fix all three.
3. Register after A13. Add A14 to `content/README.md`'s assertion list.
4. Emit `content/ATTRIBUTIONS/silhouettes.md` from `silhouettes.yaml`, sorted by family then binomial,
   written only after every assertion passes.
5. Rename the seed asset from kebab to snake_case and update `species.silhouette_asset`, in this
   commit, so no window exists where both conventions are live.
6. **Then commission the drawings**, batched by family: the artist brief carries the 140 × 64 grid,
   stroke-only with `stroke="currentColor"` and **no** `stroke-width`, outline plus the eye, ≤ 8
   subpaths, the facing rule, and the 24 KB ceiling. A family lands as one PR; a family that is not
   drawn yet has species that A5 already refuses to ship, which is the correct pressure.
7. Record an `accepted_on` per drawing after checking it at 44 px on a device in sunlight mode — the
   size and the theme it actually has to work at, not at 100 % on a desk monitor.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 20 rows pass, and each failed first except cases 12 and 18, whose exception is stated in the
      commit body.
- [ ] 100 % branch coverage on `a14_silhouette_shape.dart` and `svg_shape.dart`.
- [ ] Roughly 400 drawings exist under `app/assets/sil/`, every `species.silhouette_asset` resolves,
      and the tree is under 6 MB.
- [ ] No file declares `stroke-width`, a fill other than `none`, a colour value, a banned element or a
      root transform; every file is `viewBox="0 0 140 64"` with ≤ 8 subpaths.
- [ ] Every filename is a `lower_snake_case` binomial; no kebab-case asset remains anywhere.
- [ ] `content/shared/silhouettes.yaml` has a row per drawing with the artist, the agreement id and
      an `accepted_on`; `content/ATTRIBUTIONS/silhouettes.md` regenerates with no diff.
- [ ] The `assets/` versus `assets_src/` gap is written into `content/AUTHORING.md`, naming E08 as the
      epic that has to decide it and `DECISIONS.md` as where the decision belongs.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
dart run content_builder:build --in content/ --out app/assets/db/reference.db \
  --build-date "$(date -u +%F)" --generator-commit "$(git rev-parse --short HEAD)" --check
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
.claude/skills/lonja-icons-and-plates/scripts/check_lonja_icons.sh app/lib
```

`check_lonja_icons.sh` is pointed at `app/lib` and not at `app/assets`: its checks are over Dart
source, and its raster check (check 3) is the one that would notice if anybody answered a hard
drawing with a PNG. Passing it says nothing about the SVG shape — A14 is what says that
(`CONVENTIONS.md` §7).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content): originate ~400 species silhouettes and assert their shape budget (A14)

SPEC.md §8 sizes it — originated SVG line art, ~400 species, ~6 MB, assets/sil/
— and §7.1 makes species.silhouette_asset NOT NULL, so a missing drawing is a
build failure rather than a runtime placeholder. A5 has been waiting for these
files since E04.

The SVG carries geometry and the theme carries ink. A14 requires
stroke="currentColor" and forbids a stroke-width attribute outright:
lonja-icons-and-plates rule 3 says the stroke tracks the theme ink weight and
never the glyph size, and a width frozen into an asset is legible on the
artist's screen and invisible on a wet phone at noon. Nothing in the widget
tests would catch that.

Legibility at arm's length in sunlight is bought with contrast and geometry.
§4.9 makes sunlight monochrome at maximum contrast, so the theme answers the
contrast question; this task owns the geometry — no fill, so the shape cannot
collapse at 44 px; eight subpaths at most, so there is nothing thinner than an
outline to lose; outline plus the eye, because hatching aliases into grey at
that size. Those three are engraved-plates.md's silhouette column and A14
checks all three. The ceiling is also what stops a silhouette growing fin rays
and spots until it can stand in for an uncleared plate.

Filenames are lower_snake_case binomials per rule 9, and the kebab-case seed
asset is renamed in this commit — two conventions in one directory is how the
401st species gets a "file not found".

Whether the app renders from the bundled asset or from generated const Dart is
a real gap between SPEC.md §8 and icon-system.md, no gate enforces either, and
it is a rendering decision that belongs to E08 and to DECISIONS.md. The SVG is
the deliverable under both layouts, so it is authored at app/assets/sil/ and the
gap is written down rather than decided quietly here.

Task: E22/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
