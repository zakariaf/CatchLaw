# Token Tables

The complete Lonja value set: every tier-1 primitive with its measured lightness, every tier-2 slot with its per-theme binding, and the contrast figure for each pair in all three themes.

## Tier 1 — the pigment box

The name is the pigment family plus its **measured CIE L\*** (D65, sRGB). The number is not decoration: if the hex changes, the name changes. `paper` is the stock, `ink` is the impression, `harbour` is the crate blue, and `verdant`/`oxblood`/`ochre` are the three meanings. Twenty-five primitives, and adding a twenty-sixth is a reviewed change.

| Primitive | Hex | L\* | Family | Mockup alias | Used by |
|---|---|---|---|---|---|
| `white100` | #FFFFFF | 100.0 | paper | `sun-paper` | sunlight ground |
| `paper90` | #E6E4DC | 90.5 | paper | `paper` | paper ground, paper `onAccent` |
| `paper89` | #DDE2DB | 89.3 | paper | — | night primary text |
| `paper87` | #DEDBD1 | 87.4 | paper | `paper-sunk` | paper recessed stock |
| `paper79` | #C2C5BB | 79.0 | paper | `rule` | paper hairline |
| `paper72` | #A9B4AC | 72.3 | paper | — | night secondary text |
| `paper70` | #A9AC9F | 69.8 | paper | `rule-strong` | paper strong hairline |
| `paper57` | #7E8B83 | 56.6 | paper | — | night tertiary text, night bearing rule |
| `ink49` | #6C7871 | 49.3 | ink | `ink-faint` | paper tertiary text |
| `ink30` | #3D4A44 | 30.2 | ink | `ink-muted` | paper secondary text, paper bearing rule |
| `ink26` | #33413A | 26.1 | ink | — | night strong hairline |
| `ink22` | #2C3830 | 22.2 | ink | — | night hairline |
| `ink11` | #16201C | 11.2 | ink | `ink` | paper primary text |
| `ink10` | #161E1A | 10.4 | ink | — | night recessed stock |
| `ink07` | #101714 | 7.0 | ink | — | night ground, night `onAccent` |
| `black00` | #000000 | 0.0 | ink | `sun-ink` | every sunlight neutral |
| `harbour69` | #6FB3C4 | 69.2 | harbour | — | night accent |
| `harbour30` | #1B4D5E | 30.3 | harbour | `harbour` | paper accent |
| `verdant72` | #7FC08D | 72.3 | verdant | — | night `verdictPass` |
| `verdant36` | #2E5E3A | 35.8 | verdant | `verdant` | paper + sunlight `verdictPass` |
| `oxblood70` | #E19A95 | 70.4 | oxblood | — | night `verdictFail` |
| `oxblood28` | #7A2320 | 28.0 | oxblood | `oxblood` | paper + sunlight `verdictFail` |
| `ochre76` | #D8B84A | 75.7 | ochre | — | night `verdictWarn` |
| `ochre47` | #8A6A16 | 46.7 | ochre | `ochre` | paper `verdictWarn` (mark only) |
| `ochre38` | #6E5512 | 37.6 | ochre | — | sunlight `verdictWarn` |

## Tier 2 — the thirteen semantic slots

Widgets read only this column set. Each theme binds all thirteen; there is no fallback and no default.

| Slot | Role | paper | night | sunlight |
|---|---|---|---|---|
| `surface` | the sheet | `paper90` | `ink07` | `white100` |
| `surfaceSunk` | recessed stock | `paper87` | `ink10` | `white100` |
| `onSurface` | primary text, the verdict word | `ink11` | `paper89` | `black00` |
| `onSurfaceMuted` | secondary text, citations | `ink30` | `paper72` | `black00` |
| `onSurfaceFaint` | captions at 19sp and above | `ink49` | `paper57` | `black00` |
| `hairline` | row separation, ornament | `paper79` | `ink22` | `black00` |
| `hairlineStrong` | section separation, ornament | `paper70` | `ink26` | `black00` |
| `ruleBearing` | control frames, active-tab rule | `ink30` | `paper57` | `black00` |
| `accent` | chrome: links, focus, selection | `harbour30` | `harbour69` | `black00` |
| `onAccent` | text on an accent fill | `paper90` | `ink07` | `white100` |
| `verdictPass` | meets the rule | `verdant36` | `verdant72` | `verdant36` |
| `verdictFail` | fails the rule | `oxblood28` | `oxblood70` | `oxblood28` |
| `verdictWarn` | stale rule data | `ochre47` | `ochre76` | `ochre38` |

`density` is the fourteenth field on `LonjaTokens` and is not a colour — see the density set below.

## Measured contrast — paper theme

Ground #E6E4DC, recessed #DEDBD1. Text floor 4.5:1; bearing rules and glyphs 3:1; ornament hairlines have no floor and may never be the sole boundary of a control.

| Slot | Primitive | vs `surface` | vs `surfaceSunk` | Floor | Verdict |
|---|---|---|---|---|---|
| `onSurface` | `ink11` | 13.12 | 12.06 | 4.5 | pass |
| `onSurfaceMuted` | `ink30` | 7.29 | 6.70 | 4.5 | pass |
| `onSurfaceFaint` | `ink49` | 3.62 | 3.32 | 3.0 large only | pass at 19sp+, **never a fact** |
| `hairline` | `paper79` | 1.37 | 1.26 | ornament | pass (no floor) |
| `hairlineStrong` | `paper70` | 1.81 | 1.67 | ornament | pass (no floor) |
| `ruleBearing` | `ink30` | 7.29 | 6.70 | 3.0 | pass |
| `accent` | `harbour30` | 7.27 | 6.68 | 4.5 | pass |
| `onAccent` | `paper90` on `harbour30` | 7.27 | — | 4.5 | pass |
| `verdictPass` | `verdant36` | 5.94 | 5.46 | 4.5 | pass, text-safe |
| `verdictFail` | `oxblood28` | 7.90 | 7.26 | 4.5 | pass, text-safe |
| `verdictWarn` | `ochre47` | 3.97 | 3.65 | 3.0 | pass as **mark only** |

`ochre47` is the reason the verdict stamp is framed and never filled: at 3.97:1 it clears the non-text floor for a frame and a glyph but fails 4.5:1 as text, and `paper90` on an `ochre47` fill measures 3.97:1 too. The warning **word** is always `onSurface`.

## Measured contrast — night theme

Ground #101714, recessed #161E1A.

| Slot | Primitive | vs `surface` | vs `surfaceSunk` | Floor | Verdict |
|---|---|---|---|---|---|
| `onSurface` | `paper89` | 13.84 | 12.94 | 4.5 | pass |
| `onSurfaceMuted` | `paper72` | 8.50 | 7.95 | 4.5 | pass |
| `onSurfaceFaint` | `paper57` | 5.12 | 4.78 | 3.0 large only | pass, but still **never a fact**: the limit is global, set by the worst theme |
| `hairline` | `ink22` | 1.49 | 1.39 | ornament | pass (no floor) |
| `hairlineStrong` | `ink26` | 1.70 | 1.59 | ornament | pass (no floor) |
| `ruleBearing` | `paper57` | 5.12 | 4.78 | 3.0 | pass |
| `accent` | `harbour69` | 7.73 | 7.23 | 4.5 | pass |
| `onAccent` | `ink07` on `harbour69` | 7.73 | — | 4.5 | pass |
| `verdictPass` | `verdant72` | 8.51 | 7.96 | 4.5 | pass |
| `verdictFail` | `oxblood70` | 8.02 | 7.50 | 4.5 | pass |
| `verdictWarn` | `ochre76` | 9.42 | 8.81 | 4.5 | pass |

## Measured contrast — sunlight theme

Ground #FFFFFF. Every neutral is `black00` at 21.00:1. The three verdict pigments are the only chroma in the build, each cleared to AAA on white.

| Slot | Primitive | vs `surface` | Floor | Verdict |
|---|---|---|---|---|
| all neutrals and `accent` | `black00` | 21.00 | 4.5 | pass |
| `onAccent` | `white100` on `black00` | 21.00 | 4.5 | pass |
| `verdictPass` | `verdant36` | 7.56 | 4.5 | pass (AAA) |
| `verdictFail` | `oxblood28` | 10.05 | 4.5 | pass (AAA) |
| `verdictWarn` | `ochre38` | 7.07 | 4.5 | pass (AAA) |

## The 4pt spacing spine

Eight steps. `LonjaSpace` is the only source of a gap; there is no `s0` because a zero gap is `EdgeInsets.zero`.

| Step | dp | Typical use |
|---|---|---|
| `s1` | 4 | glyph-to-word, tabular cell padding |
| `s2` | 8 | icon-to-label, inline rule inset |
| `s3` | 12 | list-row vertical padding |
| `s4` | 16 | screen gutter, block padding |
| `s5` | 24 | between blocks in a section |
| `s6` | 32 | section separation |
| `s7` | 48 | above the verdict stamp |
| `s8` | 64 | page head to first article |

## Rule weights, radii, motion

There is no shadow group, no gradient group and no elevation group, because a printed sheet has no z-axis. Reduced-motion resolution of these durations is owned by `design-system-structure`.

| Group | Token | Value | Use |
|---|---|---|---|
| rules | `LonjaRules.hair` | 0.5 | tabular row separation |
| rules | `LonjaRules.rule` | 1.0 | default divider, block frame |
| rules | `LonjaRules.strong` | 2.0 | section head underscore, active tab |
| rules | `LonjaRules.stamp` | 3.0 | the verdict stamp frame, and nothing else |
| radii | `LonjaRadii.none` | 0 | the default for every surface |
| radii | `LonjaRadii.hair` | 2 | the ceiling; chips and the ruler thumb only |
| motion | `LonjaMotion.none` | `Duration.zero` | the reduced-motion resolution |
| motion | `LonjaMotion.quick` | 90 ms | state change on a control |
| motion | `LonjaMotion.page` | 140 ms | route transition |

## The density set (glove mode)

`LonjaDensity` is orthogonal to `ThemeMode`: each of the three themes is built with either value, giving six renderings from three palettes.

| Field | `standard` | `glove` | Why |
|---|---|---|---|
| `tapMin` | 48 | 56 | a gloved or wet thumb loses roughly 8dp of precision |
| `tapGap` | 4 | 8 | separation is what prevents the adjacent-target mis-tap |
| `rowHeight` | 56 | 72 | species rows stay one-thumb scannable |
| `hitSlop` | 0 | 4 | extends the hit box without moving the ink |
| `gutter` | `s4` (16) | `s5` (24) | the sheet breathes when the hand is clumsy |

The 44dp platform accessibility floor is owned by `accessibility-as-code`; Lonja's 48/56 sits above it deliberately and does not replace it.

## Adding or changing a token

1. Measure the L\* of the new hex, name the primitive for it, and add a tier-1 row above with its mockup alias if one exists. A name whose number does not match its hex is a defect, not a nit.
2. Bind it in all three theme builders in `lib/theme/lonja_theme.dart` — never in two.
3. Add its contrast figures to all three contrast tables, against both `surface` and `surfaceSunk`.
4. If it is chromatic, state whether it is chrome or meaning. There is no third category.
5. Re-run `scripts/check_lonja_tokens.sh` and the golden lanes for all three themes plus glove.
