# Navigation Anatomy and States

Every measured value the Lonja bottom strip, masthead and back affordance are built from, across the
three themes and the glove-mode density switch. Structure and token plumbing belong to
`lonja-design-tokens`; this file holds the numbers.

## The five destinations, frozen

| # | `LonjaDestination` | ARB key | Glyph (outline / filled) | Holds | Why it is one of the five |
|---|---|---|---|---|---|
| 1 | `check` | `navCheck` | `fish` / `fishFilled` | Species search, ruler, verdict entry | The ten-second job; it is destination one because the thumb rests there |
| 2 | `today` | `navToday` | `tally` / `tallyFilled` | Today's tally, bag limits so far | The only screen that changes hour to hour |
| 3 | `trips` | `navTrips` | `route` / `routeFilled` | Past trips, per-trip tallies, export | Records, read far more than written |
| 4 | `reference` | `navReference` | `book` / `bookFilled` | The booklet: instruments, articles, penalties, plates | The document the app claims to be |
| 5 | `settings` | `navSettings` | `sliders` / `slidersFilled` | Zone, locale, theme, glove mode, data currency | Everything configurable, in one place, last |

**Rejected destinations, permanently:** `Map` (no location service, no tiles offline), `More`
(an overflow menu is an admission the count is wrong), `Profile` (there is no account),
`Sync` (there is no network), `Search` (it is the top of Check).

## Strip metrics

| Property | Paper (default) | Night | Sunlight | Glove mode delta |
|---|---|---|---|---|
| Strip height (excl. system inset) | 62dp | 62dp | 62dp | 76dp |
| Ground | `paper-sunk` `#DEDBD1` | `#131A17` | `sun-paper` `#FFFFFF` | unchanged |
| Top rule | 2dp `ink` `#16201C` | 2dp `#C9D2CB` | 3dp `sun-ink` `#000000` | 3dp |
| Cell hairline (inline-end) | 1dp `rule` `#C2C5BB` | 1dp `#2C3830` | 1.5dp `#000000` | unchanged |
| Selected rail | 3dp `harbour` `#1B4D5E` | 3dp `#6FB3C4` | 4dp `sun-ink` `#000000` | 4dp |
| Selected ground | `paper` `#E6E4DC` | `#18211D` | `#FFFFFF` with 1.5dp inset frame | unchanged |
| Glyph size | 21dp | 21dp | 22dp | 24dp |
| Label size / tracking | 9sp / 0.11em, uppercase | same | 10sp / 0.11em | 10sp |
| Label weight (unselected / selected) | 500 / 600 | 500 / 600 | 600 / 700 | same |
| Corner radius, elevation, shadow | 0, 0, none | 0, 0, none | 0, 0, none | unchanged |
| Bottom padding | `MediaQuery.viewPaddingOf(context).bottom` | same | same | same |

The strip is full-bleed: it must touch both screen edges. `SafeArea` is never wrapped around it;
the inset is applied to its own `Padding` so the ink rule stays flush against the bezel.

Arabic overrides the label face: tracking drops to 0, the arabic stack replaces sans, and the size
rises to 11sp — plain uppercase Latin tracking mangles Arabic joining forms.

## The selected-state signal stack

Ordered by survival. A selected cell must differ in signals 1-3 with all colour removed.

| # | Signal | Unselected | Selected | Survives sunlight? | Survives greyscale? |
|---|---|---|---|---|---|
| 1 | Ground | `paper-sunk` | `paper` (lighter) | yes | yes |
| 2 | Top rail | absent | 3dp rail present | yes (turns `sun-ink`) | yes |
| 3 | Glyph | outline | filled | yes | yes |
| 4 | Label weight | 500 | 600 | yes | yes |
| 5 | Colour | `ink-faint` `#6C7871` | `ink` `#16201C` + harbour rail | no (harbour deleted) | no |

`Semantics(selected: true, button: true)` is set on the selected cell so TalkBack and VoiceOver
announce "selected" — the screen-reader equivalent of signal 2. The rail sits on the **top** edge, not
the bottom: a bottom rail is hidden by the thumb that just pressed it.

## Masthead anatomy

| Slot | Face / size | Tracking | Colour | Notes |
|---|---|---|---|---|
| Wordmark | serif 19sp, 600, uppercase | 0.16em | `ink` | Arabic build swaps to the arabic stack, tracking 0, 22sp |
| Wordmark kicker | serif italic 10.5sp, 400 | 0.06em | `ink-faint` | The offline-by-design line; the ONLY status text allowed |
| Mast-meta | mono 9.5sp, uppercase | 0.12em | `ink-faint` | Two lines, trailing-aligned, tabular figures: `MON 27 JUL` / `2026` |
| Bottom rule | 2dp | — | `ink` | Never a shadow, never `scrolledUnderElevation` |
| Chip row | see `chips-and-currency.md` | — | — | `Wrap`, 8dp spacing, never a horizontal scroller |

Pushed routes swap the wordmark block for a **bar row**: back button, serif 18sp title, an optional
mono 9.5sp uppercase superscript on the trailing side, and a 1dp `rule` bottom hairline instead of the
2dp ink rule. The mast-meta line does not repeat on pushed routes; the chip row does.

## Back affordance

| Property | Value |
|---|---|
| Target | 44dp square, 56dp in glove mode |
| Glyph | `LonjaGlyphs.back`, 22dp, stroke 1.6 |
| Placement | leading, `EdgeInsetsDirectional.only(start: 4)` |
| RTL | `Transform.flip(flipX: true)` when `Directionality.of(context) == TextDirection.rtl` |
| Tooltip | `l10n.backTooltip`, never a literal |
| Action | `Navigator.of(context).maybePop()` |
| Present on | every pushed route, including the verdict takeover |

The system back gesture is a supplement. Wet gloves and a wet screen defeat edge swipes, so the
visible affordance is the contract.

## Verdict takeover

| Element | Normal route | Verdict route |
|---|---|---|
| Bottom strip | present | **suppressed** (`bottomNavigationBar: null`) |
| Masthead | wordmark + mast-meta + chips | bare back row + currency chip |
| Zone chip | present | present (jurisdiction is part of the claim) |
| Currency chip | present | present, always |
| Disclaimer | not required | **required, non-dismissable, on-screen** |
| Exit | five destinations + back | back only |

**The cost, stated:** removing the strip removes four one-tap exits. It is accepted because at 05:40
with a live fish in the bin, five competing targets under a stamp that must be read in ten seconds is
worse than one. The mitigations are mandatory: back is visible without scrolling at textScaler 1.0,
the takeover is never more than one level deep, and the system back gesture is never intercepted.

## Edge cases

- **textScaler 2.0** — labels ellipsize to one line rather than wrapping; the strip does not grow.
  The glyph, ground, rail and weight signals still distinguish the selection, so an ellipsized label
  is not a failure.
- **320dp width** — 5 cells x 64dp = 320dp; at exactly 320dp the cells are 64dp wide, still above the
  56dp floor. A sixth destination drops them to 53dp and fails the floor.
- **Landscape phone** — the strip stays at the bottom and keeps 62dp; it does not become a rail.
  The rail switch is a width decision owned by `adaptive-layout`.
- **Keyboard visible** — the strip is pushed up by the view insets; it is never hidden, because a
  hidden strip re-appearing under the thumb causes mis-taps.
- **Cold start** — the strip renders with `check` selected before any database read completes; it
  never shows a spinner or an empty state.
