# Verdict Anatomy

The physical construction of the CatchLaw result surface: what is printed, in what order, at what
measurement, and what each of the three themes does to it.

## The vertical order — fixed, no exceptions

| # | Slot | Element | Rule |
|---|---|---|---|
| 1 | status bar | "No signal · offline by design" | never a cloud, sync or refresh affordance |
| 2 | app bar | species name + zone (`Hamour` · `Ras Al Khaimah`) | back is the only action |
| 3 | expiry | `StaleRuleBar`, ochre | present ONLY when the rule pack is past its validity date |
| 4 | plate | engraved species plate + caption (`lonja-icons-and-plates`) | identification before judgement |
| 5 | stamp | the verdict, between double rules | 48dp below the plate, the only tilted element |
| 6 | table | the rule table (measured, minimum, season, penalty) | figures mono, tabular |
| 7 | diagram | measurement method or distinguishing feature | optional, bordered, `paper-sunk` ground |
| 8 | citation | footnote rule + instrument, article, dates | LAST printed block |
| 9 | disclaimer | `LonjaDisclaimer` | permanent, unconditional |
| 10 | action | a single `Add to today` button | never phrased as an instruction about the fish |

Spacing spine (4-pt): 2 hairline offsets · 4 icon-to-label · 8 glove separation floor · 12 row
internals · 16 page margin · 24 block break · 32 section break · **48 plate to stamp**.

## Stamp geometry

| Property | Value | Note |
|---|---|---|
| Top and bottom rule | 4dp double, `currentColor` | 1dp line, 1.5dp gap, 1dp line |
| Tilt | `-0.55deg` = `Transform.rotate(angle: -0.0096)` | the press is never quite square |
| Vertical padding | 16dp top, 10dp bottom, inside the rules | |
| Horizontal inset | page margin only (16dp) | the stamp is not indented from the sheet |
| Glyph | 30dp, stroke 1.7, `currentColor` | never a filled Material icon |
| Glyph-to-headline gap | 11dp | |
| Headline | serif 26 / 1.02, `w700`, uppercase, tracking `.005em` | 21 when the headline wraps to 2 lines |
| Sub-line | serif 15.5 / 1.35 in `ink`, figures mono 15 `w600` | absent for `.closedSeason` and `.protected` |
| Meta line | sans 10.5, tracking `.14em`, uppercase, `currentColor` | 7dp below the sub-line |
| Fill | none | except the sunlight reversal |

The stamp is drawn in one `DefaultTextStyle` so glyph, rules, headline and meta cannot drift apart;
only the sub-line steps down to `ink` so the measurement stays black-green rather than semantic.

## The rule table

`th` sans 9.5, tracking `.16em`, uppercase, `ink-faint`, start-aligned, 44% width; `td` serif 15,
end-aligned, figures mono 14 with `FontFeature.tabularFigures()`; rows separated by a 1dp dotted
`rule`, first row topped by a 1dp solid `ink`. A cell that states a rule outcome takes the semantic
ink and `w600` (`Open all year` in verdant, `Fully protected` in oxblood) — and only such cells do.

## The citation footnote

| Part | Setting |
|---|---|
| Footnote rule | 44% width, 1dp, `ink` at 85% opacity, 9dp above the text |
| Marker | superscript mono 9, 3dp trailing space |
| Jurisdiction | small-caps, tracking `.06em`, 13, `ink` |
| Body | serif 12 / 1.5, `ink-muted` |
| Content order | jurisdiction — instrument, article · published YYYY-MM-DD · checked YYYY-MM-DD |
| Second marker | the penalty schedule or the rule-pack provenance, on its own line |
| Link | "Read Article 3 in full" — sans 11.5, harbour, underlined, offset 2dp; opens local text only |

Worked example: `¹ UNITED ARAB EMIRATES — Ministerial Decision 580/2015, Art. 3 · published
2015-11-03 · checked 2026-07-14.` Dates are ISO, mono, never localised into ambiguity, never
relative ("2 weeks ago" is not a citation).

## The permanent disclaimer

Ground `paper-sunk` `#DEDBD1`, 2dp solid `ink` top border, 1dp `rule` bottom border, 10dp/11dp
padding, 15dp info glyph in `ink-muted`, text sans 11.5 / 1.45 in `ink-muted` with the lead clause
in `ink` `w600`: **"Reference only — not legal advice."** followed by the verifying authority. Below
it, mono 8.5, tracking `.14em`, uppercase, `ink-faint`: "Shown on every result · cannot be
dismissed." That last line is part of the contract — it tells the reader the disclaimer is
structural, so its absence is legible.

## The ochre stale bar

Full-bleed, directly under the app bar, above the plate: ground `#E8E0C6`, 1dp `#8A6A16` rules top
and bottom, 17dp warning glyph, sans 11.5 / 1.45 text with the date in `w700`. It is `flex: none` —
it never scrolls away with the body, and it never overlays the verdict. It carries no dismiss
control and no retry: there is nothing to retry, the device has no network by design
(`catchlaw-offline-guarantee`).

## Sunlight reversal

| Token / part | Paper | Sunlight |
|---|---|---|
| `paper`, `paper-sunk` | `#E6E4DC`, `#DEDBD1` | `#FFFFFF` both |
| `ink-muted`, `ink-faint`, `rule` | `#3D4A44`, `#6C7871`, `#C2C5BB` | `#000000` all three |
| `harbour` | `#1B4D5E` | `#000000` |
| `verdant`, `ochre` | `#2E5E3A`, `#8A6A16` | `#000000` |
| `oxblood` | `#7A2320` | `#8E0F0C` — the only chroma left on the screen |
| Stamp | hairline rules, tilted, no fill | solid ground, `#FFFFFF` ink, tilt 0, borders removed |
| Stamp headline / sub-line | 26 / 15.5 | 29 / 17 `w600` |
| Table rows | 1dp dotted | 1.5dp solid `#000000`, first row 2dp |
| Table values | serif 15 | serif 17 `w600` |
| Footnote rule, disclaimer border | 1dp, 2dp | 2dp, 3dp |
| Plate frame / stroke | 1dp / 1.1 | 2dp / 2.1 |

Sunlight is selected by the user, never inferred from an ambient-light sensor: the fisher decides,
because the phone is often in shade while the sheet he is reading is not.

## Glove mode

Orthogonal to theme. On this screen it changes only the action row and the nav: primary targets go
from 56dp to 64–66dp, nav items to 84dp, separation never below 8dp. The stamp, table, citation and
disclaimer are read, not tapped, and do not change size — glove mode is a target-density switch, not
a text-scale switch (text scaling is owned by `accessibility-as-code`).

## RTL and Arabic

The whole surface mirrors: the gutter article number moves to the start edge, the footnote rule
starts at the start edge, the table's `th`/`td` alignment follows `start`/`end`, and the stamp's
glyph precedes the headline in reading order. Latin instrument names and ISO dates inside Arabic
verdict text are wrapped in FSI/PDI; the Arabic verdict headline is set in the Naskh stack at 22/1.9
with tracking 0. Directional geometry and bidi isolation are owned by `i18n-rtl-l10n`.

## Semantics tree

One node for the stamp: `MergeSemantics` wrapping `Semantics(header: true, label: ...)` where the
label reads category first, then the measurement, then the unit. The glyph is
`ExcludeSemantics` — it repeats the headline. The citation is one node read verbatim; the
disclaimer is one node and is never `ExcludeSemantics`. Depth and target sizes are owned by
`accessibility-as-code`.
