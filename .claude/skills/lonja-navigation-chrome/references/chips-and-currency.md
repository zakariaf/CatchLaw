# Chips and Content Currency

The two chips that ride in the masthead on every rule-stating screen — the zone chip and the
rules-checked currency chip — plus the staleness ladder they encode. These are chrome that carries
trust, so their copy is as load-bearing as their colour.

## Chip taxonomy

| Chip | Purpose | Border | Ground | Glyph | Interactive |
|---|---|---|---|---|---|
| `zone` | States the jurisdiction the rules come from | 1dp `harbour` `#1B4D5E` | harbour at 8% | pin | yes — opens the zone picker |
| `currency` (fresh) | States when the rule data was last checked | 1dp `rule` `#C2C5BB` | `paper-sunk` `#DEDBD1` | seal, `verdant` `#2E5E3A` | no — it is a statement |
| `currency` (stale) | Same, escalated | 1dp `ochre` `#8A6A16` | ochre at 10% | seal, `ochre` | yes — opens the data page |
| `filter` | A selected list filter in Reference | 1dp `rule`, `ink` when selected | `paper-sunk` / `ink` when selected | none | yes |

There is no fourth chip. A chip that would show connectivity, GPS accuracy, account state or sync
progress is forbidden outright — see `catchlaw-offline-guarantee`.

## Chip metrics

| Property | Default | Glove mode |
|---|---|---|
| Min height | 38dp | 56dp |
| Padding | `EdgeInsetsDirectional.fromSTEB(11, 8, 11, 8)` | `(14, 12, 14, 12)` |
| Gap between glyph and text | 7dp | 9dp |
| Inter-chip spacing | 8dp (`Wrap(spacing: 8, runSpacing: 8)`) | 12dp |
| Corner radius | 0 | 0 |
| Label face | sans 12sp / arabic 13sp | sans 14sp |
| Emphasised span | weight 600, `ink` | same |
| Trailing chevron | 14dp, mirrors in RTL | 16dp |

Chips wrap onto a second run; they never scroll horizontally and never collapse behind an overflow
button. A chip the user cannot see is a trust signal that does not exist.

## The currency ladder

Age is measured from the rule row's `checked_at`, not from the app build date and not from
`DateTime.now()` at render.

| State | Age | Border / glyph colour | Words (English) | Behaviour |
|---|---|---|---|---|
| Fresh | 0-90 days | `verdant` `#2E5E3A` | `Rules checked 2026-07-14` | Chip only, not interactive |
| Ageing | 91-180 days | `ink-muted` `#3D4A44` | `Rules checked 2026-01-12` | Chip only; no colour alarm yet |
| Stale | 181+ days | `ochre` `#8A6A16` | `Rules last checked 2025-08-02 — verify locally` | Chip plus an ochre band under the masthead |
| Unknown | no `checked_at` | `ochre` | `Check date unknown — verify locally` | Chip plus band |

**Colour never moves alone.** Every step down the ladder changes the *words* as well as the colour and
tints the seal glyph. A stale chip rendered in greyscale must still read as stale.

**Nothing blocks.** The stale band is 1dp-ruled top and bottom in `ochre`, sits under the masthead,
and covers no content. There is no modal, no interstitial and no disabled state: a stale rule still
beats no rule at sea, and the user is standing on a boat with a fish in the bin.

## Date formatting

| Context | Format | Face | Example |
|---|---|---|---|
| Currency chip | ISO `yyyy-MM-dd` | mono, tabular figures | `2026-07-14` |
| Citation publication date | ISO `yyyy-MM-dd` | mono, tabular figures | `2015-11-03` |
| Mast-meta | `EEE d MMM` + `yyyy`, uppercase | mono, tabular figures | `MON 27 JUL` / `2026` |
| Closed-season range | locale-formatted day + month | serif | `1 Mar - 30 Apr` |

ISO dates stay ISO in every locale, including Arabic, and stay in Western digits: they are quoted
record identifiers, not prose. Locale-formatted dates and numeral-system selection are owned by
`i18n-rtl-l10n`; this file only fixes which of the two each slot uses.

## Copy rules

The chips obey the product's statement-of-fact constraint. They describe the record; they never
instruct.

| Allowed | Forbidden | Why |
|---|---|---|
| `Rules checked 2026-07-14` | `Up to date!` | A claim the app cannot verify offline |
| `Rules last checked 2025-08-02 — verify locally` | `Tap to update` / `Refresh rules` | Implies a network fetch that does not exist |
| `Ras Al Khaimah · Gulf, salt` | `Detecting location…` | There is no location lookup |
| `Check date unknown — verify locally` | `Offline — data may be wrong` | Offline is the design, not a fault |
| `Rias Baixas - Banco de Cambados` | `Zone: nearest` | Zone is chosen, never inferred |

Every one of these strings lives in `app_en.arb` and its five siblings and is read through
`AppLocalizations`. A literal in a chip fails `scripts/check_lonja_nav.sh`.

## Zone chip content

The chip shows the zone name, then a middot, then the water qualifier the rule set is scoped by:

- `Ras Al Khaimah · Gulf, salt`
- `Rias Baixas - Banco de Cambados · Atlantic, salt`
- `Represa de Jurumirim · reservoir, fresh`

The qualifier matters because the same species name maps to different instruments in salt and fresh
water. Tapping opens the zone picker; the chip never opens a map.

## RTL behaviour

| Element | LTR | RTL |
|---|---|---|
| Chip glyph | leading (left) | leading (right), unflipped — a pin and a seal are not directional |
| Trailing chevron | points right | `Transform.flip(flipX: true)`, points left |
| Chip padding | `EdgeInsetsDirectional.fromSTEB(11, 8, 11, 8)` | identical — the directional inset flips itself |
| Chip order in the `Wrap` | zone, then currency | identical source order; the `Wrap` lays out right-to-left |
| ISO date inside the label | `2026-07-14` | `2026-07-14`, isolated so bidi reordering cannot split it |

The date is wrapped in a `Directionality(textDirection: TextDirection.ltr, ...)` island inside the
Arabic label so the hyphens never reorder. Bidi isolation technique is owned by `i18n-rtl-l10n`; the
requirement that the date must not reorder is owned here.
