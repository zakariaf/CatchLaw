# Surfaces And Plates

Scope: the geometry, rule weights, fills and per-theme values for every Lonja transient surface —
dialog shell, panel, plate, bottom sheet, snackbar slab and barrier.

## 1. The governing idea

Every Lonja surface is **printed matter, not glass**. A panel is a field ruled onto the page; a plate
is a slip pasted onto it. Neither casts a shadow, because neither is above the page — they are *on*
it. The moment a surface gains elevation, tint or a radius it stops reading as a document and starts
reading as an app overlay, and the app's entire authority claim is a document claim.

Consequences, without exception:

- `elevation: 0` and `surfaceTintColor: Colors.transparent` on every Material-derived surface.
- `BorderRadius.zero` everywhere. No `circular(4)`, no "just the top corners".
- Zero `BoxShadow`, zero `Card`, zero `Material(type: MaterialType.card)`.
- Zero gradients, including the barrier, including sheet scrims.
- Separation is achieved by **rules and fills only**.

## 2. Rule weights

| Token | Hex | Width | Used for |
|---|---|---|---|
| `rule` | `#C2C5BB` | 1 px | panel border, list dividers, plate hairline |
| `rule-strong` | `#A9AC9F` | 2 px | plate top rule, sheet top edge, snackbar top edge |
| `rule-strong` | `#A9AC9F` | 3 px | dialog shell border (the pasted-slip edge) |

Rules are always `BorderSide` on a `Border` or `DecoratedBox` — never a `Divider` widget with default
Material insets, which introduces 16 dp of physical (non-directional) padding.

## 3. Fills, per theme

| Surface | paper | night | sunlight |
|---|---|---|---|
| App ground | `paper` `#E6E4DC` | `ink` `#16201C` | `sun-paper` `#FFFFFF` |
| Panel / plate fill | `paper-sunk` `#DEDBD1` | `#1E2A25` | `sun-paper` `#FFFFFF` |
| Dialog shell fill | `paper` `#E6E4DC` | `#1E2A25` | `sun-paper` `#FFFFFF` |
| Snackbar slab | `paper-sunk` `#DEDBD1` | `#1E2A25` | `sun-paper` `#FFFFFF` |
| Border | `rule` `#C2C5BB` | `#3D4A44` | `sun-ink` `#000000` |
| Barrier | `ink` `#16201C` @ 0.62 | `#16201C` @ 0.78 | `sun-ink` `#000000` @ 0.90 |
| Body text | `ink` `#16201C` | `paper` `#E6E4DC` | `sun-ink` `#000000` |
| Secondary text | `ink-muted` `#3D4A44` | `#A9AC9F` | `sun-ink` `#000000` |
| Caption / checked date | `ink-faint` `#6C7871` | `#6C7871` | `sun-ink` `#000000` |

**Sunlight is a real third theme, not a contrast tweak.** Every grey is deleted: `ink-muted`,
`ink-faint` and `rule` all collapse to `sun-ink` `#000000` on `sun-paper` `#FFFFFF`. Exactly one
colour survives — the semantic verdict (`verdant` `#2E5E3A`, `oxblood` `#7A2320`, `ochre` `#8A6A16`).
`harbour` `#1B4D5E` is chrome and is deleted in sunlight along with the greys.

Token names and the `ThemeExtension` that carries them belong to `lonja-design-tokens` and
`design-system-structure`; this table is the surface-side contract those tokens must satisfy.

## 4. Dialog shell anatomy

```
┌─ 3 px rule-strong ─────────────────────────────┐
│  24 dp inset                                   │
│  TITLE — serif, 20/26, ink                     │  statement of fact
│  ── 1 px rule ──────────────────────────────   │
│  BODY — serif, 16/24, ink                      │
│  PLATE(s) — see §5                             │
│  CITATION — mono, 12/16, ink-faint             │
│  24 dp inset                                   │
│  ── 1 px rule ──────────────────────────────   │
│  ACTION ROW — sans, 16, 56 dp tall (glove)     │
└────────────────────────────────────────────────┘
```

Geometry:

| Property | Value |
|---|---|
| Max width | 480 dp; below that, `paper` inset 24 dp on each side |
| Insets | `EdgeInsetsDirectional`, `start`/`end` 24 dp, vertical 24 dp |
| Title type | serif, 20/26 — it is legal text, so it is serif |
| Action label type | sans, 16, never serif |
| Numbers, dates, articles | mono with tabular figures |
| Action row height | 48 dp standard, **56 dp in glove mode**, 8 dp gap minimum |
| Action alignment | trailing in LTR, mirrored automatically under Arabic |
| Vertical stacking | if either label wraps, stack full-width with 8 dp gaps |

Type role assignment is owned by `lonja-typography`; the serif-for-legal-text / mono-for-figures
split is restated here only because it is load-bearing for the dialog shell.

## 5. Plate anatomy

A plate carries one instrument or one species. Structure, top to bottom:

1. 2 px `rule-strong` top rule, full bleed to the plate edge.
2. Optional engraved species line art (owned by `lonja-icons-and-plates`) — never a photo, never a
   coloured illustration, never a Material icon.
3. Vernacular + scientific name: `هامور Hamour` / `Orange-spotted grouper` /
   `Epinephelus coioides`.
4. The measurement in mono with tabular figures: `min 45 cm total length`.
5. The citation block in mono at `ink-faint`: `Ministerial Decision 580/2015, Art. 3 · published
   2015-11-03 · checked 2026-07-14`.
6. 16 dp inset all round (20 dp in glove mode).

The citation is a design feature at full opacity in its own ruled band — never 10 pt, never 40%
alpha, never collapsed behind a chevron.

## 6. Bottom sheets

| Property | Value |
|---|---|
| `shape` | `const RoundedRectangleBorder()` — square, all four corners |
| `showDragHandle` | `false`, always |
| `backgroundColor` | dialog shell fill for the active theme |
| `elevation` | `0` |
| `barrierColor` | the same flat barrier wash as a dialog |
| `isDismissible` | mirrors the dialog barrier policy for the same decision class |
| `enableDrag` | `false` on any sheet with a typed result |
| Top edge | 2 px `rule-strong`, drawn by the sheet body, not by the shape |
| Safe area | `useSafeArea: true`; bottom inset padded, not clipped |

A sheet is used instead of a dialog only when the content is a *list of options at equal weight* that
would overflow a 480 dp dialog — a zone list, for example. It is never used to make a blocking
decision feel casual.

## 7. Snackbar slab

| Property | Value |
|---|---|
| `behavior` | `SnackBarBehavior.fixed` |
| `shape` | square; no radius, no margin, no float |
| Top edge | 2 px `rule-strong` `#A9AC9F` |
| Fill | `paper-sunk` `#DEDBD1` (per §3 by theme) |
| Text | sans 15/20 at `ink`; figures in mono |
| Action | at most one, label `Undo`, `harbour` `#1B4D5E` in paper/night, `sun-ink` in sunlight |
| Duration | 4 s plain, 8 s with `Undo` |
| Elevation | `0` |

## 8. Glove mode

Glove mode is an orthogonal density switch, not a theme. Inside dialogs and sheets it changes:

| Property | Standard | Glove |
|---|---|---|
| Action row height | 48 dp | **56 dp minimum** |
| Gap between actions | 8 dp | **≥ 8 dp, stacked if labels wrap** |
| Plate inset | 16 dp | 20 dp |
| Dialog inset | 24 dp | 28 dp |
| Barrier alpha | unchanged | unchanged |

It never changes colours, rule weights or type roles — only spacing and target size.

## 9. What never appears on a Lonja surface

- A cloud, sync, refresh or signal glyph — the app is 100% offline and has nothing to sync.
- A progress spinner over a barrier — every read is a local drift query.
- A close "×" in the dialog corner on a decision modal — the actions are the only exits.
- A drag handle, a pull indicator, or a "swipe down to dismiss" hint.
- A coloured banner with no glyph and no word — colour is never the only signal.
- A dismissable disclaimer of any kind.
