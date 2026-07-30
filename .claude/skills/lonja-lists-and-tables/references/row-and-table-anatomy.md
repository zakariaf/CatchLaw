# Row and Table Anatomy

The measured geometry of every CatchLaw row and ledger table — each slot, each rule weight, each
alignment — and how all three behave in Arabic, glove mode and sunlight mode.

## The species row — slot table

Order is fixed (rule 11). A screen may OMIT a trailing slot; it may never reorder or insert.

| # | Slot | Widget | Type role | Colour token | Size |
|---|---|---|---|---|---|
| 1 | Silhouette | `SpeciesSilhouette` | — | `ink` | 52 x 30, stroke 1.6 |
| 2 | Local name | `Text` | arabic 19sp / serif 16sp semibold | `ink` | line-height 1.25 |
| 3 | Binomial | `Text` | serif 12.5sp italic | `ink-faint` | single line, no ellipsis clamp |
| 4 | Rule line | `Text` | sans 11.5sp | `ink-muted` | 2sp top margin |
| 5 | End slot | `Text` / `LonjaPill` | mono 12sp tabular | `ink-muted` | `TextAlign.end`, `flex: none` |
| 6 | Chevron | `LonjaGlyph` | — | `ink-faint` | 15 x 15, inert, mirrors in RTL |

Slot 2 is the recognition anchor. In `ar` it is the Arabic name at 19sp with the Latin transliteration
demoted to 16sp inline; in `en`, `gl`, `es` and `pt_BR` the Latin name leads and the Arabic follows
inline at 16sp. Both orders are the same widget with a swapped `TextSpan` order — never two widgets.

Real content for goldens: `هامور Hamour · Epinephelus coioides · min 45 cm total length`,
`كنعد Kanaad · Scomberomorus commerson · min 65 cm fork length`,
`Ameixa babosa · Venerupis corrugata · 38 mm shell length`.

## The log row

Same envelope, different slots: a leading 22 x 22 glyph instead of a silhouette, a serif 16sp
headline, a sans 11.5sp detail line, and an end slot that is usually a `LonjaPill`.

| Slot | Content example |
|---|---|
| Leading glyph | route / tally / warn, 22 x 22, `ink-muted` |
| Headline | `Mon 27 Jul` + an inline sans 12sp qualifier `· open` |
| Detail | `Ras Al Khaimah · 04:55 — now · 7 fish · 41 kg` |
| End slot | `LonjaPill` — `OPEN` (harbour), `STALE DATA` (ochre), `PROTECTED` (oxblood) |
| Chevron | present only when the row opens a detail route |

## The settings row

Min height 58dp (68dp glove). Serif 15.5sp key, sans 11sp `ink-faint` sub-line, and a value slot that
is mono 12sp text, a `LonjaSwitch`, or a `LonjaSegmented`. The value slot is `margin-inline-start:
auto` — expressed in Flutter as `const Spacer()` — never a fixed width.

## The ledger table — column classes

| Class | Alignment | Type role | Width policy | Example |
|---|---|---|---|---|
| `label` | start | serif 14sp `ink` | `FlexColumnWidth(34)` | `First offence` |
| `numeric` | end | mono 14sp tabular | `FlexColumnWidth(33)` | `AED 3,000`, `41 kg`, `132` |
| `prose` | start | serif 14sp `ink-muted` | `FlexColumnWidth(33)` | `Suspension for 6 months` |
| `pair` | start label / end value | sans 9.5sp caps + serif 15sp | `44% / 56%` | the two-column rule table |

The `pair` class is the compact rule table used inside a verdict or a Today screen: an uppercase
tracked sans key on the start edge and a serif value on the end edge, dotted hairline between rows,
1px solid `ink` above the first row. It is a `Table`, not a `Row` per line, so the key column stays
aligned when one value wraps to two lines.

Tone overrides on a numeric cell are semantic only: `oxblood` for a fine or a failing count,
`verdant` for a compliant count, `ochre` for a stale figure. Never tint a cell for emphasis.

## The divider ladder

| Slot | Weight | Style | Colour | Where |
|---|---|---|---|---|
| `hairlineDotted` | 1px | dotted | `rule` #C2C5BB | between sibling rows, between ledger body rows |
| `groupOpen` | 1px | solid | `ink` #16201C | above the first row of a group |
| `ledgerHead` | 1.5px | solid | `ink` #16201C | under a ledger header row |
| `structural` | 1px | solid | `rule-strong` #A9AC9F | between page sections, above a footer |
| `sectionLabel` | 1px | solid | `rule` #C2C5BB | the trailing rule of a `LonjaSectionLabel` |

`LonjaSectionLabel` is the gazette device: an uppercase tracked sans 9.5sp label followed by a
flex-filling 1px rule. It replaces every `ListView` header tile and every `Card` title.

Nothing on this ladder is a `Divider` widget. Rows own their bottom `BorderSide` so that a dismissed
row takes its own rule with it, leaving no orphaned line where the row used to be.

## Numeric alignment and RTL mirroring

| Concern | Correct | Wrong | What breaks |
|---|---|---|---|
| Cell padding | `EdgeInsetsDirectional` | `EdgeInsets.only(left:)` | padding lands on the wrong edge in `ar` |
| Numeric alignment | `TextAlign.end` | `TextAlign.right` | figure sits under its own label in `ar` |
| Row borders | `BorderDirectional` | `Border(left:)` | the group accent stripe flips sides |
| Swipe direction | `DismissDirection.endToStart` | `.rightToLeft` | swipe becomes the scroll direction in `ar` |
| Chevron | mirrored glyph | `Icons.chevron_right` | arrow points away from the destination |
| Digits | locale `NumberFormat` | `'$n'` | Arabic-Indic digits never appear (`i18n-rtl-l10n`) |

Figures are ALWAYS tabular, in every locale and every numbering system. `41 kg` above `402 kg` above
`7` must share a common right edge; that is what makes a ledger scannable one-handed on a moving boat.

## Density: paper, glove, sunlight

| Metric | Paper (default) | Glove | Sunlight |
|---|---|---|---|
| `rowMinHeight` | 64dp | 76dp | 64dp |
| Settings row | 58dp | 68dp | 58dp |
| Target separation | 8dp | 12dp | 8dp |
| Horizontal padding | 20dp | 20dp | 20dp |
| Hairline colour | `rule` #C2C5BB | `rule` #C2C5BB | `sun-ink` #000000 |
| Hairline style | dotted | dotted | solid |
| Secondary text | `ink-muted` | `ink-muted` | `sun-ink` #000000 |
| Tertiary text | `ink-faint` | `ink-faint` | `sun-ink` #000000 |

Sunlight mode deletes every grey: `ink-muted` and `ink-faint` both collapse to `sun-ink`, the paper
becomes `sun-paper` #FFFFFF, dotted rules become solid, and the ONLY colour left in the row is the
semantic verdict on a `LonjaPill`. Type roles, sizes and slot order are identical — a row must be
recognisably the same row across all three themes.

Glove mode is orthogonal to theme: any of the three themes can be in glove density. That is 6 golden
lanes per row, doubled to 12 by `ar` RTL. `widget-golden-and-a11y-testing` owns the harness.

## Choosing a container

| You have | Use | Never |
|---|---|---|
| A homogeneous list of rows, unbounded | `ListView.builder` + `LonjaRow` | `Column` in a scroll view |
| Rows plus interleaved section labels | `CustomScrollView` + slivers | one `ListView` with type switches |
| 2–6 label/value pairs of known length | `Table` with the `pair` class | a `Column` of `Row`s |
| A true grid of penalties or limits | `Table` with fixed column classes | `DataTable`, `GridView` |
| A wider-than-screen ledger | `Table` inside a horizontal `SingleChildScrollView` | shrinking the font |
| Fewer than 8 static rows, fixed at build | `Column` of const rows | `ListView` with `shrinkWrap: true` |

A ledger that overflows horizontally scrolls; it never wraps a cell, never shrinks the type, and never
ellipsises a figure. The label column stays visible because it is the narrowest and comes first.
