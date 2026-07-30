# The Lonja Icon System — deep dive

The mechanical half of the skill: where a glyph comes from, how big it is, how thick its line is,
where it sits beside type, and what its file is called.

## Why a painted path table beat the alternatives

| Option | What it costs | Verdict |
|---|---|---|
| `IconData` from a bundled icon font (`Icons.`, a custom `.ttf`) | Glyphs are FILLED outlines; stroke width, cap and join are baked at font-build time and cannot vary by theme. Needs a font file, a `LicenseRegistry` entry and a build step. | REJECTED — cannot do the 1.45→1.95 sunlight step, and fills break the engraved family. |
| `SvgPicture.asset` (flutter_svg) | Stroke attributes are baked into the file. Three themes × 36 glyphs = 108 files, or a per-theme asset directory. Adds a runtime parse and an asset-load frame before first paint. | REJECTED for UI icons — kept ONLY as the authoring format under `assets_src/`. |
| Raster PNG at 1x/2x/3x | Four assets per glyph per theme, no `currentColor`, no stroke control, and visible resampling next to a 1 px hairline. | BANNED (rule 11). |
| **Const path-data table + `CustomPainter`** | You must generate the Dart and you must not hand-edit it. Path parsing is done once and memoised. | **CHOSEN** — one source, stroke resolved at paint time, zero assets, nothing to load before first paint in a 100% offline app. |

Path strings are parsed with `parseSvgPathData` from `package:path_drawing`, cached in a
`static final Map<String, Path>` keyed by the glyph id, and scaled from the 24 grid with
`Path.transform(Matrix4.diagonal3Values(k, k, 1).storage)` where `k = size.px / 24`.

## The 24 grid and its drawing constraints

| Constraint | Value | Reason |
|---|---|---|
| Canvas | `viewBox="0 0 24 24"` | Every glyph in the mockup sprite is authored here. |
| Live area | 22 × 22, 1 unit of air on every side | Keeps a 1.95 sunlight stroke inside the box without clipping. |
| Fill | none, ever | `PaintingStyle.stroke` only. |
| Cap | `StrokeCap.butt` | A burin ends square. Round caps read as a UI kit. |
| Join | `StrokeJoin.miter` | Sharp corners; `miterLimit` left at the default 4. |
| Corner radii | 0 | No rounded rectangles anywhere in the icon set. |
| Subpath budget | ≤ 6 subpaths, ≤ 12 points | Beyond that it stops reading at 16 px. |
| Coordinate precision | 1 decimal place | `M15 4` and `m3.5 12.5` — more precision is noise. |

## Size scale

| Token | px | Target box (standard) | Target box (glove) | Where it appears |
|---|---|---|---|---|
| `LonjaIconSize.caption` | 16 | 44 dp | 56 dp | Beside mono 13 citations and 10.5 caps labels |
| `LonjaIconSize.ui` | 22 | 56 dp | 64 dp | Default — nav chrome, list rows, buttons |
| `LonjaIconSize.stamp` | 30 | 56 dp | 64 dp | The verdict stamp mark, beside serif 26 |
| `LonjaIconSize.mark` | 44 | n/a (not tappable) | n/a | Section marks, the single empty-state mark |

Glove mode changes the BOX, never the glyph. Minimum separation between adjacent targets is 8 dp in
both densities.

## Stroke resolution

| Theme | Icon stroke | Plate outline | Hatch | Strong hatch |
|---|---|---|---|---|
| paper (default) | 1.45 | 1.60 | 0.70 @ 50% | 1.10 @ 70% |
| night | 1.45 | 1.60 | 0.70 @ 50% | 1.10 @ 70% |
| sunlight | 1.95 | 2.10 | 1.00 @ 100% | 1.45 @ 100% |

Night is deliberately NOT thickened: a light stroke on a dark ground already blooms, and adding
width closes the counters. Sunlight is thickened because the screen is being read through glare and
every grey has been deleted.

All six numbers live in `LonjaIconTheme`, a `ThemeExtension` attached to all three `ThemeData`s. The
extension mechanics — `lerp`, `copyWith`, the asserting `of(context)` — are owned by
`design-system-structure`; the VALUES are owned here and in `lonja-design-tokens`.

## Optical alignment

| Situation | Rule |
|---|---|
| Glyph beside a label in a row | Gap is exactly 4. Align the glyph box to the label's CAP HEIGHT, not the line box centre. |
| The alignment mechanism | `LonjaIcon` applies `baselineNudge` from `LonjaIconTheme` (−1.0 at `ui`, −0.5 at `caption`, −1.5 at `stamp`). Never an ad-hoc `Padding`. |
| Glyph inside a tap target | Centred in the 56 dp box; the box, not the glyph, is what `Semantics` and the hit test see. |
| Glyph in a mono run (citations) | `caption`, aligned to the mono cap height, with tabular figures unaffected. |
| Circular glyphs (`seal`, `ban`, `clock`, `globe`) | Rendered 1 unit larger on the 24 grid, because a circle reads smaller than a square of the same bounds. Already baked into the path data. |
| Text scaling | The glyph does NOT scale with `textScaler`; the row grows and the glyph stays put. Text-scale policy is owned by `accessibility-as-code`. |

## RTL mirroring

`LonjaGlyph` carries a `mirrorInRtl` bool, applied as
`Transform(transform: Matrix4.diagonal3Values(-1, 1, 1), alignment: Alignment.center)`. This skill
owns the FLAG on each glyph; WHICH glyphs mirror, and everything about `Icons.adaptive`, directional
insets and bidi isolation, is owned by `i18n-rtl-l10n`.

| Glyph | `mirrorInRtl` | Note |
|---|---|---|
| `back`, `chevron`, `export`, `import`, `route` | true | Direction of travel reverses. |
| `tick`, `cross`, `ban`, `warn`, `seal`, `clock`, `calendar` | false | Marks and symbols are absolute. |
| `ruler`, `tally` | false | The measurement graticule reads left-to-right in every locale. |
| `fish`, `net`, and every species silhouette | false | A fish faces the way it was engraved; mirroring it changes the specimen. |

## Glyph inventory

Thirty-six glyphs, ids as generated into `LonjaIcons`. Anything not on this list needs a new
authored SVG through `catchlaw-content-pipeline`, not a Material substitute.

| Group | Glyphs |
|---|---|
| Navigation | `back`, `chevron`, `plus`, `search`, `history` |
| Domain | `fish`, `net`, `ruler`, `tally`, `scale`, `route`, `zone`, `pin`, `globe` |
| Verdict marks | `tick`, `cross`, `ban`, `warn`, `seal`, `shield` |
| Reference | `book`, `document`, `card`, `database`, `abc`, `key`, `shape` |
| Time and data | `calendar`, `clock`, `export`, `import`, `info`, `battery`, `nosignal` |
| Settings | `sliders`, `licence` |

`nosignal` exists to state that the app needs no signal. There is NO cloud glyph, NO sync glyph and
NO refresh spinner in the set, and none may be added.

## Asset and file layout

```
assets_src/icons/back.svg                    authored 24-grid SVG, reviewed, NOT bundled
assets_src/plates/epinephelus_coioides.svg   authored 300x124 plate, NOT bundled
assets/brand/                                launcher icon + splash — the only rasters
lib/design/icons/lonja_icon_paths.g.dart     generated const LonjaGlyph table
lib/design/icons/lonja_icon.dart             LonjaIcon, LonjaIconButton, LonjaIconPainter
lib/design/icons/lonja_icon_theme.dart       LonjaIconTheme ThemeExtension
lib/design/plates/plate_specs.g.dart         generated PlateSpec table + provenance
lib/design/plates/lonja_plate.dart           LonjaPlate, LonjaSilhouette, LonjaPlatePainter
```

Naming rules: authored SVG is `lower_snake_case.svg`; icon files take the glyph id
(`back.svg`, not `arrow-back.svg`, not `ic_back_24.svg`); plate files take the binomial
(`epinephelus_coioides.svg`). No size suffix, no `ic_` prefix, no locale, no `_v2`.
`pubspec.yaml` declares `assets/brand/` and nothing else under `assets/`.

## The one escape hatch

A line comment `// lonja-icon-ok` on the offending line suppresses `scripts/check_lonja_icons.sh`
for that line, and must be followed by a reason. It exists for the platform-required launcher
tooling and for golden-test fixtures. Nothing else is exempt — not "temporary", not a spike branch.
