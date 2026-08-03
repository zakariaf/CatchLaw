# E08/T11 — The silhouette is drawn, and the art is bundled

| | |
|---|---|
| **Epic** | E08 — Species: search, browse and the static detail |
| **Branch** | `fix/content-date-assertions` |
| **Commit** | `fix(species): draw the silhouette, and ship the art that was never bundled` |
| **Depends on** | T05 (the panel that reserved the box), T06 (the browse grid that reserved the tile) |
| **Size** | S |
| **Spec** | `SPEC.md` §6 S2 (Elements), §6 S6 (browse by shape), §8 (originated art) |
| **Found by** | Looking at S2 on a simulator: a grey rectangle where the animal should be |
| **Corrects** | `epics/RELEASES.md`'s "plates and silhouettes" row, which scoped both out of v1 as one thing |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-icons-and-plates` | What a silhouette is, at what sizes, and why it is never tinted to a theme slot |
| `catchlaw-content-pipeline` | Rules 7 and 8 — the death-year test and the drop rule — which are why a PLATE is absent and a silhouette is not |
| `catchlaw-offline-guarantee` | `SvgPicture.asset` and no other constructor; the fetching one is grep-banned and D-21 records the `http` edge |
| `flutter:widget-golden-and-a11y-testing` | Why every existing widget test was blind to this, and what asserts against the real bundle instead |

## What went wrong

Two independent defects, shipped together, neither with a test.

**The resolver was never built.** `_SpeciesArtPanel` and `_SilhouetteTile` each drew a framed box with
`const SizedBox.expand()` inside it and a comment deferring the art to an owner. On a device that is a
grey rectangle in the place a fisher looks first — and on a screen whose entire claim is that it is a
printed reference, an empty frame reads as a **photograph that failed to load**, which is worse than
no frame at all.

**`assets/sil/` was never listed in `pubspec.yaml`.** `app/assets/sil/venerupis-corrugata.svg` exists,
is authored, is real originated line art — and shipped nowhere. So even a correct widget would have
drawn nothing.

**A5 did not catch the second one.** It asserts the silhouette file exists *on disk* under the assets
root, which it does. Nothing asserted it reaches the *bundle*. Those are different claims and only the
second one is what the phone sees.

**Why no test saw either.** Every widget test in the suite passes a fake or a stub; none loads an
asset through `rootBundle`. The one assertion that can fail here is one that reads the real manifest.

## The scoping call this corrects

`epics/RELEASES.md` lists *"plates and silhouettes"* under **what v1 ships without**, justified by "a
plate ships only when its illustrator died in 1945 or earlier". That reasoning is correct **for
plates** and wrong for silhouettes, and the row merged two different things:

- A **plate** is a historical engraving. It clears on its illustrator's death year against the longest
  term among four jurisdictions, and today none clear — `content/shared/plates.yaml` is `plates: []`
  and every `plate_asset` is null. Genuinely absent, correctly so.
- A **silhouette** is SVG line art drawn for this app. No illustrator, no term, no ledger row.
  `species.silhouette_asset` is NOT NULL and A5 requires one for every species carrying a rule — so it
  was never optional, and scoping it out was scoping out a field the schema makes mandatory.

## What this delivers

- `app/lib/ui/core/ui/lonja_silhouette.dart` — `LonjaSilhouette`: the pack's asset key, the bundle
  prefix, `SvgPicture.asset`, a bounded placeholder and a full-width slip.
- Both call sites wired: `_SpeciesArtPanel` (plate when one cleared, silhouette otherwise) and
  `_SilhouetteTile` in the browse grid, where the drawing *is* the tile.
- `app/pubspec.yaml` — `- assets/sil/`, a directory rather than a file list.
- `speciesSilhouetteSemanticLabel` in all seven ARB files, with the template's constraint.
- `app/test/ui/core/lonja_silhouette_test.dart` — four tests against `rootBundle`.

## Why it is built this way

**One widget, two call sites.** The detail panel and the browse tile had the same stub for the same
reason. A resolver in each is two places for the next content update to get wrong.

**A directory in `pubspec.yaml`, not a file list.** One entry per species is a line every content
update has to remember, and the update that forgets it ships a blank frame that no test sees — which
is exactly what happened.

**Never tinted.** `colorFilter` is deliberately not applied. The art carries its own strokes and is
authored to read at arm's length on a wet screen; recolouring line art to a theme slot is how a
drawing whose whole job is to be recognisable becomes a silhouette of a silhouette.

**The placeholder is bounded.** `SizedBox.expand()` inside a scroll view is an unbounded-height
assertion the moment the asset is absent — which is every widget test, none of which loads a real
bundle. `SizedBox(height: height)` keeps the layout the rest of the screen was measured against.

**Full width, explicitly.** `LonjaPlateSurface` is a slip pasted across the page. A `DecoratedBox`
left to size itself shrinks to the drawing's aspect ratio and pastes the slip two thirds of the way
across, which reads as a layout accident rather than as stock.

## Tests first

| # | Test name | Expected | Why this case exists |
|---|---|---|---|
| 1 | `LonjaSilhouette prefixes the pack asset key with the bundle root` | `assets/sil/…` | The pack stores the key without the prefix so one value addresses both a content file and a bundle entry |
| 2 | `the shipped silhouette loads from the bundle` | the SVG source | **The assertion that fails when `assets/sil/` drops out of `pubspec.yaml`** — verified by removing the line and watching it fail |
| 3 | `the shipped silhouette is line art rather than an embedded image` | no `<image`, no `base64` | A raster pasted into an SVG wrapper carries whatever copyright the raster carried, which defeats the reason a silhouette is not a plate |
| 4 | `the shipped silhouette declares a viewBox so it scales to any tile` | contains `viewBox` | Without one, flutter_svg uses the intrinsic size and the browse grid renders a clam the size of a full stop |

## Definition of done

- [ ] All four pass, and test 2 was seen failing with the pubspec line removed.
- [ ] Both call sites draw the art; neither retains a `SizedBox.expand()` placeholder.
- [ ] `check_lonja_icons.sh` and `check_app_invariants.sh` are green over `app/lib`.
- [ ] `RELEASES.md`'s "ships without" row is corrected to name plates only.
- [ ] The drawing is confirmed on a device, not only in a golden.
