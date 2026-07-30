# Button Anatomy

The half of `lonja-buttons` that answers "what exactly is inside the box" — measured geometry, the
two slots, label wording, icon-only rules, action rows, and where a button stops being a button.

## The printed box

Every number below is measured from the approved Lonja mockup. They belong in `lib/theme/`, exposed
through the token extension; a feature file never types one of them.

| Property | Regular | Compact | Icon-only | Notes |
|---|---|---|---|---|
| min height | 56dp | 46dp | 44dp | glove: 66 / 66 / 56 |
| width | fills its column | fills its cell | 44dp fixed | `Size.fromHeight` + a stretching parent |
| corner radius | 0 | 0 | 0 | hard ceiling 2dp anywhere in the app |
| rule (border) width | 1.5dp | 1.5dp | 0 | 3dp when focused |
| horizontal padding | 16dp | 16dp | 0 | `--s5` in the mockup |
| gap between glyph and label | 10dp | 10dp | n/a | |
| leading glyph size | 20dp | 20dp | 22dp | glove: 22 / 22 / 24 |
| label family | sans | sans | n/a | `lonja-typography` owns the stack |
| label size | 15dp | 13.5dp | n/a | glove regular: 16.5dp |
| label weight | 600 (500 for `quiet`) | 600 | n/a | weight is a ladder signal, not decoration |
| label tracking | 0.03em | 0.03em | n/a | |
| label case | sentence case | sentence case | n/a | never ALL CAPS: Arabic has no case |
| elevation / shadow | 0 / none | 0 / none | 0 / none | non-negotiable |
| splash | `NoSplash.splashFactory` | same | same | paper does not ripple |

Serif is for law, species accounts and the verdict stamp; mono is for measurements, article numbers
and citations. A button is UI chrome, so its label is **sans** — with one exception: a button whose
label contains a measurement (`Use 45 cm total length`) sets that fragment in mono with tabular
figures, inline, via a `TextSpan`.

## The two slots

A Lonja button has a leading glyph slot and a label slot. That is the entire component.

| Slot | Allowed | Banned |
|---|---|---|
| leading | one 20dp `IconData` from the plate set | photos, avatars, coloured badges, emoji |
| label | one line of sentence-case verb phrase | two lines, a subtitle, a truncating `Text` |
| trailing | nothing | chevrons, counts, "new" pills, dropdown carets |

A trailing chevron means "this navigates" — that is a list row, not a button
(`lonja-lists-and-tables`). A dropdown caret means "this opens a menu" — that is a control
(`lonja-forms-and-controls`).

Long labels wrap to two lines rather than ellipsing; `Export as CSV to this phone` at 200% text scale
must stay readable. Never `maxLines: 1` with `TextOverflow.ellipsis` on an action, and never
`FittedBox` (text scaling is owned by `accessibility-as-code`).

## Label wording

Sentence case, verb first, object named, no terminal period, translated through ARB
(`i18n-rtl-l10n`) and never string-concatenated.

| Banned | Why it fails | Use instead |
|---|---|---|
| `OK` | names no consequence | `Save calibration` |
| `Yes` / `No` | only meaningful with the question in view | `Delete this trip` / `Cancel` -> `Back one step` |
| `Submit` | form vocabulary; nothing is submitted anywhere | `Add to today` |
| `Continue` / `Next` | names no destination | `Step and mark` |
| `Done` | ambiguous between "saved" and "left" | `End trip` |
| `Confirm` | echoes the dialog, not the action | repeat the verb: `Delete this trip` |
| `Keep` | **instructs the fisher about the fish** | not a button; the verdict states the fact |
| `Return` / `Throw it back` | same, plus it is advice | not a button |
| `Retry` | implies a network attempt | `Re-calibrate with a card` |
| `Calibration` (a noun) | a tab label, not an action | `Re-calibrate with a card` |

The approved label corpus, verbatim from the mockup: `Identify this fish`, `Add to today`,
`Add to today as a bycatch note`, `Record another`, `End trip`, `Save calibration`,
`Reset to screen default`, `Re-calibrate with a card`, `Export as CSV to this phone`,
`Back one step`, `Skip this couplet`, `Type instead`, `Browse by shape`, `Step and mark`,
`If the tail is damaged`. Match this register: plain, concrete, and about the app's own behaviour.

## Icon-only buttons

`LonjaIconButton` requires `semanticLabel` and forwards it to `tooltip`; `IconButton` wires
`tooltip` into its own `Semantics` node, so the tooltip **is** the accessible name — do not also wrap
the widget in a second `Semantics`, which double-announces.

| Requirement | Implementation |
|---|---|
| 44dp box around a 22dp glyph | `constraints: BoxConstraints.tightFor(width: 44, height: 44)`, `padding: EdgeInsets.zero` |
| glove mode | 56dp box, 24dp glyph |
| accessible name | required `semanticLabel` -> `tooltip` |
| square corners | `RoundedRectangleBorder(borderRadius: BorderRadius.zero)` in `IconButton.styleFrom` |
| optical alignment at a screen edge | negative directional inset of 10dp (`margin-inline-start:-10px` in the mockup) — use `EdgeInsetsDirectional`, never `EdgeInsets.only(left:)` |
| where it is allowed | masthead back/close, the ruler's fine controls | 
| where it is banned | as the screen's primary action, or anywhere the label would fit |

An icon-only button is never the primary action. The primary always carries words.

## Action rows

| Shape | When | Geometry |
|---|---|---|
| single full-width | the normal case | one child, `Size.fromHeight`, 16dp side padding |
| stacked column | primary above, then secondary, then quiet | gap 8dp, glove 12dp |
| two-across | one `secondary` + one `quiet` of equal weight | `1fr 1fr` grid, 8dp gap, glove 12dp |
| inline links | inside a citation or disclaimer paragraph | no box, 1dp underline at 2dp offset |

The action row sits below the content, above the bottom navigation, separated by a 1dp `#C2C5BB`
rule — never floating over content, never a persistent sticky bar with a shadow. The non-dismissable
disclaimer on the result screen sits **above** the action row and is never a button.

## Where a button stops being a button

| Construct | Owner | Reason |
|---|---|---|
| `SegmentedButton`, `FilterChip`, `Switch`, `Radio` | `lonja-forms-and-controls` | they select state; a button commits it |
| A tappable list row or species card | `lonja-lists-and-tables` | the row is the target, not a button inside it |
| Bottom navigation destinations | `lonja-navigation-chrome` | navigation is chrome, not action |
| The verdict stamp itself | `lonja-verdict-and-status` | it is a statement of fact and is not tappable |
| Dialog action rows | `lonja-dialogs-and-surfaces` | the surface owns its own row; rung rules still apply |
| The ruler's drag handle | `catchlaw-measurement-ruler` | a gesture surface, not a button |

## Anatomy checklist

- [ ] Height is 56 / 46 / 44dp, or 66 / 66 / 56dp in glove mode.
- [ ] Radius is 0; rule is 1.5dp, or 3dp when focused.
- [ ] `elevation` is 0 and `shadowColor` is transparent.
- [ ] `splashFactory` is `NoSplash.splashFactory`.
- [ ] At most one leading glyph; no trailing slot.
- [ ] Label is sans, sentence case, verb-first, from ARB, wrapping rather than ellipsing.
- [ ] Any measurement inside the label is mono with tabular figures.
- [ ] Icon-only carries a non-empty `semanticLabel` and is not the primary action.
- [ ] No hex literal appears anywhere in the widget file.
