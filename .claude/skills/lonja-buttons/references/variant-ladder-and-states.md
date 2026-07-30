# Variant Ladder and States

The half of `lonja-buttons` that answers "which variant, and what does it look like right now" — the
five-rung ladder, what earns each rung, the six-state matrix, and how all of it resolves across the
three themes and the glove density switch.

## The ladder

One rung per intent. The rung is decided by consequence, never by visual appetite.

| Rung | Field | Rule | Label | Earned when | Max per screen |
|---|---|---|---|---|---|
| `primary` | harbour `#1B4D5E` | 1.5dp harbour | `#EFF1EC` | This is the one thing the screen exists to let you do | **1** |
| `secondary` | transparent | 1.5dp ink `#16201C` | ink `#16201C` | A real alternative path the fisher may reasonably take | 2 |
| `quiet` | transparent | 1.5dp rule `#C2C5BB` | ink-muted `#3D4A44` | The escape route: skip, reset, change zone, type instead | 3 |
| `destructive` | oxblood `#7A2320` | 1.5dp oxblood | `#E9DCD6` | A row leaves the writable user database | 1 |
| `link` | none | none, 1dp underline at 2dp offset | ink `#16201C` | The action belongs inside a running sentence, e.g. the citation line | unlimited |

There is no sixth rung. A "tertiary", "tonal", "elevated" or "outlined-primary" request is a request
to re-rank the screen — fix the ranking instead.

### Deciding the rung

1. Does it destroy user data? -> `destructive`, plus a confirmation.
2. Is it the single reason this screen exists? -> `primary`. If two candidates survive, the screen is
   doing two jobs; split it or demote one.
3. Would a fisher plausibly take it instead of the primary? -> `secondary`.
4. Is it an exit, a reset, a skip, or a "no, do it another way"? -> `quiet`.
5. Does it sit inside a sentence rather than beside one? -> `link`.

## The six-state matrix

Nothing in this matrix moves, scales, casts a shadow, or ripples. Every cell is a field, a rule, or a
label change, resolved in `WidgetStateProperty.resolveWith`.

| State | primary | secondary / quiet | destructive | Non-colour signal |
|---|---|---|---|---|
| default | harbour field, 1.5dp rule | transparent, 1.5dp rule | oxblood field, 1.5dp rule | glyph + label |
| hovered | ink wash `alpha 0.04` over field | ink wash `alpha 0.04` | ink wash `alpha 0.04` | pointer cursor only |
| focused | rule -> 3dp ink | rule -> 3dp harbour | rule -> 3dp ink | rule weight doubles |
| pressed | ink wash `alpha 0.10` | ink wash `alpha 0.10` | ink wash `alpha 0.10` | wash, no ripple, no scale |
| disabled | paper-sunk `#DEDBD1` field, ink-faint `#6C7871` label, rule `#C2C5BB` | same | same | adjacent reason text |
| busy | field unchanged, `onPressed: null`, 1.5dp harbour rule on the bottom edge after 250ms | same | same | the bottom rule |

Hover exists for the tablet-with-trackpad case and for goldens; the primary user has no pointer.
Never make hover the only affordance for anything.

## Theme resolution

Buttons name slots. `lonja-design-tokens` resolves them. The button widget must contain **zero** hex.

| Slot | paper (default) | sunlight | night |
|---|---|---|---|
| `harbour` (primary field) | `#1B4D5E` | `#000000` | owned by `lonja-design-tokens` |
| `onHarbour` (primary label) | `#EFF1EC` | `#FFFFFF` | owned by `lonja-design-tokens` |
| `ink` (secondary rule/label) | `#16201C` | `#000000` | owned by `lonja-design-tokens` |
| `inkMuted` (quiet label) | `#3D4A44` | `#000000` | owned by `lonja-design-tokens` |
| `rule` (quiet rule) | `#C2C5BB` | `#000000` | owned by `lonja-design-tokens` |
| `paperSunk` (disabled field) | `#DEDBD1` | `#FFFFFF` | owned by `lonja-design-tokens` |
| `inkFaint` (disabled label) | `#6C7871` | `#000000` | owned by `lonja-design-tokens` |
| `oxblood` (destructive field) | `#7A2320` | `#8E0F0C` | owned by `lonja-design-tokens` |

**Sunlight is the stress test.** In sunlight every grey is deleted and the only surviving hue is
oxblood `#8E0F0C`; harbour, ink, ink-muted and rule all collapse to `#000000`. A ladder graded by hue
becomes one flat rung there. Grade by field-versus-outline and by rule weight, and the ladder holds:
primary is the only *filled* black box, destructive is the only *coloured* box, secondary and quiet
separate on rule weight and label weight (600 versus 500).

## Density: glove mode

Glove mode is orthogonal to theme — paper+glove, sunlight+glove and night+glove all exist. Read it
from `LonjaDensity.of(context).isGlove`, never from a width breakpoint or a platform check.

| Metric | standard | glove |
|---|---|---|
| regular action height | 56dp | 66dp |
| compact action height | 46dp | 66dp (compact ceases to exist) |
| icon-only box | 44 x 44dp | 56 x 56dp |
| leading glyph | 20dp | 22dp |
| icon-only glyph | 22dp | 24dp |
| label size / weight | 15dp / w600 | 16.5dp / w600 |
| gap between stacked actions | 8dp | 12dp |
| horizontal padding | 16dp | 16dp |

The 66dp figure is deliberate over-provision against the 56dp product floor: a neoprene glove over a
wet finger lands 15-20dp from the visual centre, and the tally row directly below the primary is a
different action.

## Disabled: the reason is part of the state

A disabled button without adjacent prose is a bug, not a style. The prose is ink-muted `#3D4A44`,
one line, stating the missing precondition, and it is a sibling in the same column — not a tooltip,
not a snackbar fired on tap.

| Situation | Disabled label | Adjacent reason |
|---|---|---|
| No zone chosen yet | `Identify this fish` | "Select a zone first — rules differ by zone." |
| Ruler not calibrated | `Save calibration` | "Calibrate against a bank card first." |
| Nothing recorded today | `End trip` | "No catch recorded today." |
| Reference data stale | `Add to today` | ochre `#8A6A16` note, and the button stays ENABLED — stale data is a warning, never a lock |

Never disable the path to a verdict. A stale rule set produces an ochre-flagged verdict with its
`checked` date; it does not produce a dead button.

## Busy: the 250ms rule

Both databases are on-device: the read-only pre-seeded asset DB and the writable user DB. A verdict
query, an insert and a CSV export all finish inside one or two frames. Therefore:

- 0-250ms: nothing visible changes. `onPressed` is null, the latch is set, the label is unchanged.
- past 250ms: a 1.5dp harbour rule animates along the bottom edge of the button box.
- past 2s: this is a defect, not a UX state. Something is doing I/O on the UI isolate — profile it
  (`flutter-performance`), do not add a spinner.

Never a `CircularProgressIndicator`, never a shimmer, never a cloud or sync glyph anywhere in this
app. The absence of network chrome is a product guarantee (`catchlaw-offline-guarantee`).

## Edge cases

| Case | Ruling |
|---|---|
| A screen with genuinely no primary action (a reference/species account) | Correct. Zero primaries is legal; two is not. |
| A `FloatingActionButton` | Banned. It floats, it casts, it is round. Use a bottom `primary` in the action row. |
| Two-across button rows (`btn-row two`, `1fr 1fr`) | Legal for one `secondary` + one `quiet`. Never for two primaries. |
| A button inside a list row | Demote to `quiet` compact, or make the whole row tappable (`lonja-lists-and-tables`). |
| A button in a dialog | The dialog owns its own action row; rung rules still apply (`lonja-dialogs-and-surfaces`). |
| Arabic (RTL) | The glyph slot mirrors with the text direction; use directional insets only (`i18n-rtl-l10n`). |
| A toggle that looks like a button | It is not a button. It selects state (`lonja-forms-and-controls`). |
