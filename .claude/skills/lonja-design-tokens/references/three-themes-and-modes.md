# Three Themes and Modes

How paper, night and sunlight are authored, why sunlight cannot be derived, how glove mode stays orthogonal to all three, and how a token snapshot travels to a painter, an isolate and a golden.

## The three themes at a glance

| | paper | night | sunlight |
|---|---|---|---|
| Ground | `paper90` #E6E4DC | `ink07` #101714 | `white100` #FFFFFF |
| Recessed stock | `paper87` #DEDBD1 | `ink10` #161E1A | **same as ground** |
| Greys in use | 5 | 5 | **0** |
| Chromatic slots | `accent` + 3 verdicts | `accent` + 3 verdicts | **3 verdicts only** |
| Lowest text pair | 3.62:1 (`onSurfaceFaint`) | 5.12:1 | 21.00:1 |
| Trigger | default | user choice or platform dark | user choice, one tap from the result screen |
| Feels like | the regulations booklet indoors | the same booklet under a deck lamp | the same booklet in full Gulf noon |

All three are `ThemeData` objects built by `LonjaTheme.paper()`, `.night()` and `.sunlight()`, each with a complete `LonjaTokens` extension attached. There is no fourth theme and no runtime-generated theme.

## Why sunlight is a palette, not an inversion

Sunlight exists because at roughly 100,000 lux, through a salt-hazed screen, with the brightness sensor already saturated, the *middle* of the tonal range disappears first. A device shows you the extremes and mud in between.

A derived theme keeps the middle. Run the arithmetic on the tempting one-liner:

```
paper.copyWith(surface: white100, onSurface: black00)
  onSurfaceMuted stays ink30  #3D4A44 -> 9.7:1 on white   (looks fine on a desk)
  onSurfaceFaint stays ink49  #6C7871 -> 4.5:1 on white   (gone in the sun)
  hairline       stays paper79 #C2C5BB -> 1.6:1 on white  (gone indoors too)
  accent         stays harbour30       -> a blue that reads as grey outdoors
```

Every one of those is a *measured pass* on a bench and a *failure in the hand*. So sunlight deletes the middle entirely rather than compressing it: six neutral slots collapse to `black00`, `surfaceSunk` collapses into `surface`, and `accent` gives up `harbour` because chrome colour is the first thing to lose when there is one colour to spend. What survives is the verdict — the only chroma in the build, and therefore unmistakably the answer.

This is also why sunlight is not "high contrast mode". High contrast raises ratios; sunlight *removes tonal steps*. A widget that relied on `surfaceSunk` to mark a block must also carry a rule, because in sunlight the stock change does not exist.

## Authoring or changing a theme

1. Write all thirteen slots explicitly. A `copyWith` chain from another theme is how a grey survives into sunlight.
2. Bind slots to primitives, never to hexes. If the primitive you need does not exist, add it to the pigment box first with its measured L\*.
3. Fill the contrast row for the slot in `references/token-tables.md` for **this** theme, against both `surface` and `surfaceSunk`.
4. Attach the `LonjaTokens` extension to the `ThemeData` and carry the `density` field through — a theme built without a density is a compile error, not a default.
5. Add or refresh the golden lane. Three themes times two densities is six lanes, and all six are cheap because the palettes are const.

## Glove mode is density, not a theme

Glove mode answers a different question from the theme. The theme answers *what light am I in*; glove mode answers *what is my hand like*. They vary independently: a gloved hand at night is common on a boat, and a bare hand in sunlight is common on a quay.

| Axis | Values | Lives on | Persisted as |
|---|---|---|---|
| Theme | paper, night, sunlight | `ThemeMode`-equivalent enum, one `ThemeData` each | an enum name in the user DB |
| Density | standard, glove | `LonjaTokens.density`, a value field | a bool in the user DB |

Folding the two axes into one enum produces `paper`, `paperGlove`, `night`, `nightGlove`, `sunlight`, `sunlightGlove` — six palettes to hand-author, six sets of contrast rows to maintain, and a guarantee that the least-used combination silently drifts. Keeping them orthogonal means the palette work stays at three and the density work stays at one table.

Density affects geometry only. It never changes a colour, a rule weight or a radius. If a change to glove mode wants a different colour, the requirement is wrong: contrast must already be sufficient for a bare hand.

## The snapshot contract

`LonjaTokens` is `@immutable`, const-constructible, and implements `==`/`hashCode` over every field. That makes it a value that can leave the widget tree safely.

| Consumer | Receives | Never |
|---|---|---|
| A widget | `LonjaTokens.of(context)` at `build` time | a cached field from `initState` |
| A `CustomPainter` | `LonjaTokens` in the constructor, compared in `shouldRepaint` | `BuildContext` or `Theme.of` inside `paint()` |
| A golden test | a const `LonjaTokens` built directly | a `pumpWidget` that relies on the ambient default |
| A pure layout helper | the two or three fields it needs | the whole token object "for later" |

A painter that stores a `BuildContext` walks the element tree on the raster path once per frame, and its `shouldRepaint` degenerates to `true` because it has nothing to compare. The snapshot makes repaint a value comparison, which is both correct and free. The painter/scene split itself is owned by `custom-canvas-and-gestures`.

Caching a snapshot in `initState` is the mirror-image bug: the widget keeps the palette it was born with and never repaints when the theme changes, so the first sunlight tap does nothing.

## Which slot do I reach for?

| I am painting… | Slot | Not |
|---|---|---|
| the screen background | `surface` | `Colors.white`, `Theme.of(context).scaffoldBackgroundColor` |
| a quoted article block | `surfaceSunk` | a shadowed `Card` |
| the species name, the measurement, the verdict word | `onSurface` | `onSurfaceMuted` |
| the citation line, "checked 2026-07-14" | `onSurfaceMuted` | `onSurfaceFaint` — it is 3.62:1 on paper |
| a 19sp+ ornamental caption | `onSurfaceFaint` | anything carrying a fact |
| a divider between species rows | `hairline` | `ruleBearing` — it will shout |
| the frame of a tappable control | `ruleBearing` | `hairline` at 1.37:1 |
| a link, focus ring, or the active tab | `accent` | `verdictPass` — green is meaning |
| the verdict stamp frame and glyph | `verdictPass`/`Fail`/`Warn` | a fill of the same colour |
| a zone chip for Ras Al Khaimah | `ruleBearing` frame, `onSurface` text | an `accent` fill |

## What this file does not own

The `ThemeExtension` `lerp`/`copyWith` contract, the asserting `of(context)` accessor and hand-authored `ColorScheme` construction are owned by `design-system-structure`. Persisting and restoring the chosen theme before first paint is owned by `app-startup-and-bootstrap` and `state-management-riverpod`; this skill only guarantees that whatever is restored is one of exactly three named palettes and one of exactly two densities.
