---
name: lonja-icons-and-plates
description: >-
  Enforces the Lonja icon and illustration system for Catchlaw — one authored stroked icon family on
  the 24 grid at 1.45 stroke with butt caps and mitre joins, a stroke width tracking the theme ink
  weight and NEVER the glyph size, the fixed 16/22/30/44 size scale with cap-height alignment,
  LonjaIcon and LonjaGlyph in place of banned Icons., CupertinoIcons. and IconData literals, the
  engraved species plate with its PL. XVII number, 0.7 and 1.1 hatching and mandatory illustrator
  provenance, the silhouette-versus-plate rule for protected and look-alike species, binomial asset
  keys such as epinephelus_coioides, the no-illustration empty-state policy, and a total ban on
  emoji. Use when adding an icon, wiring a species plate, building an empty state, naming an asset
  under assets/plates/, choosing between SvgPicture and a painted path table, sizing a glyph beside a
  label, or reviewing any Icon, LonjaIcon or LonjaPlate call in a diff.
---

# Lonja Icons and Plates

An icon in Catchlaw is **a burin stroke, not a pictogram**: the same engraved line that draws the
fish draws the chevron, so a screen reads as one printed plate rather than a UI kit pasted onto
paper. This skill owns the icon source decision, the size and stroke scale, optical alignment,
species plate authorship and provenance, asset naming, empty-state art policy and the emoji ban. It
does NOT own colour values, type roles, semantic-label wording, or RTL mirroring policy.

Read the reference for the task at hand:
- `references/icon-system.md` — source decision matrix, the 24 grid, size scale, stroke resolution,
  optical alignment, glyph inventory, asset layout.
- `references/engraved-plates.md` — silhouette versus plate, frame anatomy, hatching weights,
  look-alike pairs, provenance record, sunlight and night behaviour.

Run `scripts/check_lonja_icons.sh` before a PR.

Colour hexes and the stroke-weight token live in `lonja-design-tokens`; the serif/sans/mono roles and
the ink weight this stroke tracks live in `lonja-typography`; this skill governs everything drawn
with a line rather than set in type.

## Non-negotiable rules

1. **ONE icon family, authored in-house.** No `Icons.`, no `CupertinoIcons.`, no `font_awesome`, no
   `IconData(0xe5c4, fontFamily: 'MaterialIcons')`; every glyph comes from `LonjaIcons` in
   `lib/design/icons/lonja_icon_paths.g.dart`. **WHY:** Material glyphs are filled, on a different
   grid with rounded joins — ONE in a screen of engraved strokes reads as a rendering bug, and the
   user is judging whether this app looks like the law.
2. **Every glyph is stroked line art on the 24 grid.** `PaintingStyle.stroke`, `StrokeCap.butt`,
   `StrokeJoin.miter`, no fill, no rounded corners, no two-tone; closed shapes are outlines.
   **WHY:** the vocabulary is an engraver's burin, one filled counter breaks the family, and fills
   collapse to a solid blob in the sunlight theme.
3. **Stroke width tracks the theme ink weight, NEVER the glyph size.** Read
   `LonjaIconTheme.of(context).strokeWidth` — 1.45 on paper, 1.45 on night (light-on-dark blooms, so
   it is NOT thickened), 1.95 in sunlight; a 44 px mark and a 16 px mark carry the SAME width.
   **WHY:** the burin does not change width with the size of the figure, so scaling the stroke makes
   every size a different icon set, and a hardcoded 1.45 freezes sunlight out.
4. **Four icon sizes only: 16, 22, 30, 44.** `LonjaIconSize.caption`, `.ui`, `.stamp`, `.mark`; any
   other number is a defect. Glove mode grows the TARGET BOX (56 dp to 64 dp), never the glyph.
   **WHY:** an off-scale 20 px glyph lands its horizontals on half-pixels and goes furry, and growing
   glyphs in glove mode reflows every row.
5. **NO emoji, anywhere.** Not in Dart literals, `app_*.arb`, a `semanticLabel`, a debug `print` or a
   test name. Ban the dingbats too: no U+2713, no U+26A0. Use `LonjaIcons.tick`, `.cross`, `.ban`,
   `.warn`. **WHY:** emoji render from a colour font the app does not control, are filled where
   everything else is stroked, are announced six different ways across six locales, and a fish emoji
   beside a AED 3,000 verdict reads as commentary on the law.
6. **Every icon is labelled or explicitly excluded — never neither.** `LonjaIcon` asserts
   `semanticLabel != null || excludedByAncestor`; a mark beside its own words goes inside
   `ExcludeSemantics`. Label CONTENT, the 44 px target floor and the never-colour-alone rule are
   owned by `accessibility-as-code`. **WHY:** an unlabelled lone glyph is announced as "image" at
   05:40 in the dark, and a labelled glyph beside identical text is announced twice.
7. **A plate is evidence; a silhouette is a hint.** A silhouette (140x64, outline only) may identify
   a species in a LIST. A plate (300x124, outline plus hatching plus diagnostic marks, framed,
   numbered `PL. XVII · fig. 1`) is REQUIRED on any result or account for a protected species or
   either member of a look-alike pair. **WHY:** the verdict is only as good as the identification, a
   smudge of outline cannot separate two emperors, and the fisher carries the fine.
8. **EVERY plate records its illustrator and death year, or it does not compile.** `PlateProvenance`
   requires non-nullable `illustrator`, `illustratorDeathYear`, `sourceWork`, `sourceYear` and
   `licence`; the public-domain determination is owned by `catchlaw-content-pipeline`. **WHY:** plates
   are the one asset class in a no-network app that can carry someone else's copyright, and an
   unattributed engraving is a takedown that ships to every installed device.
9. **Plates and silhouettes are keyed by the binomial, never a common name.**
   `epinephelus_coioides`, lower_snake_case, ASCII, no locale, no rank, no `_v2`. Never `hamour` (one
   of six local names), never `grouper` (160 species). **WHY:** a locale-named key silently binds the
   artwork to one locale, and `grouper.svg` collides the first time a second grouper is imported.
10. **Empty states get a rule, one mark and one sentence — NEVER an illustration.** No spot art, no
    mascot, no cartoon fish, no `assets/illustrations/`. At most ONE 44 px `LonjaIconSize.mark` glyph
    in `ink-faint` `#6C7871`. **WHY:** the plates are legal evidence; spending engraved art
    decoratively on "nothing here yet" devalues the one place the drawing does real work.
11. **Rasters are banned from the UI.** The only bitmaps are the launcher icon and splash under
    `assets/brand/`, referenced by the platform, not by Dart. Any raster reaching `Image.asset` MUST
    ship `2.0x/` and `3.0x/` siblings; sized decode and `cacheWidth` are owned by
    `flutter-performance`. **WHY:** a 1x PNG on a 3x device is the most visible quality failure
    possible on a screen otherwise made of hairlines.
12. **A mark is NEVER the only signal.** Glyph plus word plus colour, always — `LonjaIcons.ban` +
    "Protected species" + `oxblood #7A2320`; wording is owned by `catchlaw-verdict-contract` and the
    pairing table by `lonja-verdict-and-status`. **WHY:** sunlight deletes every grey and the user
    may be colour-blind, in gloves, at dawn; glyph and word must survive alone.

## The one icon family

Glyph path data is generated into a const table on the 24 grid, so there is no font to bundle, no
asset to decode and nothing to load before first paint — which matters in a 100% offline app.

```dart
// WRONG — a filled Material glyph on a rounded grid, in a screen of engraved strokes.
IconButton(icon: const Icon(Icons.arrow_back), onPressed: context.pop);
const Icon(Icons.check_circle, color: Color(0xFF2E5E3A));  // filled, and colour-only.

// RIGHT — one authored family, stroked, resolved from the theme.
const LonjaIcon(LonjaIcons.back, semanticLabel: 'Back');
const LonjaIcon(LonjaIcons.tick, size: LonjaIconSize.stamp, tone: LonjaTone.verdant);

// lib/design/icons/lonja_icon_paths.g.dart — generated; 24-grid, stroke-only path data.
class LonjaIcons {
  const LonjaIcons._();
  static const back = LonjaGlyph('back', ['m15 4-8 8 8 8'], mirrorInRtl: true);
  static const tick = LonjaGlyph('tick', ['m3.5 12.5 5.5 6L20.5 5.5']);
  static const ban = LonjaGlyph('ban', ['M3 12a9 9 0 1 0 18 0a9 9 0 1 0-18 0', 'M5.6 5.6 18.4 18.4']);
}
```

## Size, stroke and optical alignment

Four sizes, one stroke per theme. The gap from glyph to label is 4 — the smallest step on the Lonja
4-pt spine — and vertical alignment is to cap height, never to the line box.

```dart
enum LonjaIconSize {
  caption(16),  // beside mono 13 citations and 10.5 caps labels
  ui(22),       // default — nav chrome, list rows, buttons
  stamp(30),    // the verdict stamp mark
  mark(44);     // section marks and the single empty-state mark
  const LonjaIconSize(this.px);
  final double px;
}

// WRONG — stroke scaled with the glyph; the 44 px mark reads as a different family.
final strokeWidth = 1.45 * size.px / 22;
// WRONG — a literal lifted from the mockup, frozen into the paper theme.
canvas.drawPath(path, Paint()..strokeWidth = 1.45);

// RIGHT — one stroke per theme, constant across all four sizes.
final icons = LonjaIconTheme.of(context);   // paper 1.45 · night 1.45 · sunlight 1.95
final burin = Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = icons.strokeWidth
  ..strokeCap = StrokeCap.butt
  ..strokeJoin = StrokeJoin.miter
  ..color = tone.resolve(context);
canvas.drawPath(path, burin);
```

## The engraved plate

A plate is a numbered figure: outline at 1.6, sparse hatching at 0.7 and 50% opacity, structural
hatching at 1.1 and 70%, inside a frame with a 3 px inner rule, captioned in Arabic, serif and italic
binomial, and set 48 above the verdict stamp.

```dart
// PL. XVII · fig. 1 — 300x124 grid. Outline 1.6 · hatch 0.7 · strong hatch 1.1.
const hamourPlate = PlateSpec(
  key: 'epinephelus_coioides',
  plateNo: 'PL. XVII',
  figureNo: 1,
  strokes: [
    PlateStroke('M10 33c5-14 25-24 52-24 21 0 39 9 47 23-8 14-26 24-47 24Z', PlateInk.outline),
    PlateStroke('M110 32c8-8 17-12 26-13-5 8-5 18 0 26-9-1-18-5-26-13Z', PlateInk.outline),
    PlateStroke('M78 22c-2 10-2 20 0 30M92 20c-2 11-2 22 0 33', PlateInk.hatch),
  ],
  provenance: PlateProvenance(
    illustrator: 'Francis Day',
    illustratorDeathYear: 1889,
    sourceWork: 'The Fishes of India',
    sourceYear: 1878,
    licence: 'public-domain',
  ),
);

// WRONG — no provenance; PlateSpec has no default, so this does not compile.
const shariPlate = PlateSpec(key: 'lethrinus_nebulosus', strokes: [/* ... */]);

// RIGHT — the widget draws the frame and states its own number.
const LonjaPlate(hamourPlate, semanticLabel: 'Engraved plate of an orange-spotted grouper');
```

Full worked file: `examples/lonja_plate.dart`.

## When a plate is required

The surface does not choose freely: protected species and look-alike pairs always get the full plate.

```dart
// WRONG — a protected species identified by a 44 px silhouette on the result screen.
LonjaSilhouette(species.key, size: 44);

// RIGHT — the guard makes the wrong pairing impossible to ship.
Widget speciesArt(SpeciesRef s, ArtSurface surface) {
  final needsPlate = s.isProtected || s.lookAlikeOf != null;
  assert(!(needsPlate && surface == ArtSurface.listRow),
      'plate required for ${s.scientificName}: protected or look-alike');
  return switch (surface) {
    ArtSurface.listRow when !needsPlate => LonjaSilhouette(s.key, size: 44),
    _ => LonjaPlate(platesByKey[s.key]!, semanticLabel: s.plateLabel),
  };
}

// Look-alike pairs — BOTH members get a plate, never a silhouette. The four pairs and the
// character each plate must draw are tabulated in `references/engraved-plates.md`.
```

Full worked file: `examples/lonja_plate.dart`.

## Asset naming and layout

Authored SVG never ships; it is the source `catchlaw-content-pipeline` turns into const Dart, keyed
by binomial so the artwork survives translation and species splits. The full directory layout is in
`references/icon-system.md`.

```dart
// WRONG — keyed by common names: 'hamour' is one of six locale names for this fish and
// 'grouper' names 160 species; both collide on the next content import.
const plates = {'hamour': hamourPlate, 'grouper': hamourPlate};

// RIGHT — keyed by the binomial, lower_snake_case, ASCII, no locale, no version suffix.
const platesByKey = <String, PlateSpec>{
  'epinephelus_coioides': hamourPlate,     // هامور · Hamour · Orange-spotted grouper
  'lethrinus_nebulosus': shariPlate,       // شعري · Sha'ri · Spangled emperor
  'scomberomorus_commerson': kanaadPlate,  // كنعد · Kanaad
  'venerupis_corrugata': ameixaPlate,      // Ameixa babosa · Rias Baixas
};
```

## Empty states and the emoji ban

An empty state is a printed page with no entry on it: a rule, one mark, one sentence of serif prose.

```dart
// WRONG — a spot illustration and an emoji.
Column(children: [
  Image.asset('assets/illustrations/empty_basket.png', width: 220),
  const Text('🎣 Nothing here yet!'),
]);

// WRONG — an emoji as a status mark: a filled colour font this app does not control,
// announced six different ways across six locales.
Text('⚠️ ${l10n.ruleDataExpired}');

// RIGHT — a rule, one mark, one statement of fact; the mark is decorative, so it is excluded.
Column(children: [
  const LonjaRule(),                                       // hairline #C2C5BB
  const SizedBox(height: 24),
  const ExcludeSemantics(
      child: LonjaIcon(LonjaIcons.book, size: LonjaIconSize.mark, tone: LonjaTone.inkFaint)),
  const SizedBox(height: 12),
  Text(l10n.noCatchesRecordedToday, style: LonjaType.of(context).body),
]);
```

## Anti-patterns

- **`Icon(Icons.arrow_back)`** — a filled Material glyph with rounded joins; one makes every authored
  stroke on the screen look accidental.
- **`IconData(0xe5c4, fontFamily: 'MaterialIcons')`** — smuggles the banned family past a name grep.
- **`Text('✅ Meets the minimum')`** — a colour-font dingbat standing in for `LonjaIcons.tick`,
  announced unpredictably in Arabic and unstyleable in sunlight.
- **`strokeWidth: 1.45` hardcoded in a painter** — freezes the paper theme; sunlight's 1.95 never
  arrives and the glyph vanishes on a wet screen at noon.
- **`size: 20` or `size: 28`** — off the 16/22/30/44 scale; horizontals land on half-pixels.
- **`Transform.scale` on a `LonjaIcon`** — scales the stroke with the glyph, producing a second icon
  family at every call site.
- **`LonjaSilhouette` on a protected-species result** — no diagnostic marks to verify the ID against.
- **`PlateSpec` with a nullable `provenance`** — an unattributed engraving on every device, with no
  network to recall it.
- **`assets/plates/hamour.svg`** — a locale-bound key that breaks in Galicia and Brazil and collides
  with the next grouper added to the reference database.
- **`assets/illustrations/empty_basket.png`** — decorative art spending the plates' credibility on an
  empty list, and a raster with no 2.0x/3.0x siblings.
- **`Icons.adaptive.arrow_back`** — the general-Flutter mirroring answer; there is no Material glyph
  here to adapt, so use `LonjaGlyph(mirrorInRtl: true)`.

## Definition of done

- [ ] `scripts/check_lonja_icons.sh` is clean over `lib/`.
- [ ] No `Icons.`, `CupertinoIcons.`, `IconData(` or third-party icon package in `lib/` (rule 1).
- [ ] Zero emoji or dingbats in `lib/**/*.dart` and `lib/l10n/*.arb`, labels included (rule 5).
- [ ] Every glyph size is one of 16, 22, 30, 44, no call site scales a glyph, and no `strokeWidth`
      literal exists outside `LonjaIconTheme` (rules 3, 4).
- [ ] Every `LonjaIcon` has a `semanticLabel` or an `ExcludeSemantics` ancestor (rule 6).
- [ ] Protected and look-alike species resolve to `LonjaPlate` on result surfaces (rule 7).
- [ ] Every new `PlateSpec` carries `illustrator`, `illustratorDeathYear`, `sourceWork`, `sourceYear`
      and `licence`, and its key is a lower_snake_case binomial (rules 8, 9).
- [ ] No file under `assets/illustrations/`; any raster reached from Dart has `2.0x/` and `3.0x/`
      siblings (rules 10, 11).

## Related skills

- See `lonja-design-tokens` for the ink, rule and semantic hex values and the per-theme stroke-width
  token that `LonjaIconTheme` reads.
- See `lonja-typography` for the type roles and the ink weight the icon stroke is calibrated to.
- See `lonja-verdict-and-status` for the mark-to-verdict-word pairing and stamp treatment.
- See `accessibility-as-code` for `semanticLabel` wording, the `ExcludeSemantics` policy, the 44 px
  target floor and the never-colour-alone rule these marks satisfy.
- See `i18n-rtl-l10n` for directional geometry, `Icons.adaptive` and which glyphs mirror in Arabic —
  `mirrorInRtl` implements that policy, it does not define it.
- See `flutter-performance` for sized image decode, `cacheWidth` and `RepaintBoundary` around plates.
- See `custom-canvas-and-gestures` for `CustomPainter`/`shouldRepaint` and the zero-allocation
  `paint()` discipline `LonjaIconPainter` and `LonjaPlatePainter` must follow.
- See `catchlaw-content-pipeline` for authoring plate SVG, the public-domain determination and the
  SVG-to-Dart step that produces `plate_specs.g.dart`.
- See `design-system-structure` for `ThemeExtension` mechanics, `lerp`/`copyWith` and the asserting
  `of(context)` that `LonjaIconTheme` is built on.

## References

- Flutter API — `CustomPainter`: https://api.flutter.dev/flutter/rendering/CustomPainter-class.html
- Flutter API — `Path`: https://api.flutter.dev/flutter/dart-ui/Path-class.html
- Flutter API — `ExcludeSemantics`: https://api.flutter.dev/flutter/widgets/ExcludeSemantics-class.html
- Flutter docs — assets and resolution-aware 2.0x/3.0x: https://docs.flutter.dev/ui/assets/assets-and-images
- pub.dev — path_drawing, `parseSvgPathData`: https://pub.dev/packages/path_drawing
- W3C — SVG 2 stroke properties: https://www.w3.org/TR/SVG2/painting.html
