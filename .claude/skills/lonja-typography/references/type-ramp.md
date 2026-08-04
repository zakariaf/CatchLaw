# The Lonja Type Ramp

Scope: every step in the CATCHLAW ramp — its family role, size, weight, line-height, tracking, the
surfaces it is mandatory on, and the real content it was measured against.

## The four faces

Declared once as `fontFamilyFallback` lists in `lib/theme/lonja_faces.dart`. The app bundles no
webfont; these are system stacks, resolved offline, on device, every time.

| Role     | Stack                                                                                            |
|----------|--------------------------------------------------------------------------------------------------|
| `serif`  | Iowan Old Style, Palatino Linotype, Palatino, Book Antiqua, Georgia, Times New Roman, serif        |
| `sans`   | ui-sans-serif, -apple-system, Helvetica Neue, Segoe UI, Roboto, Arial, sans-serif                  |
| `mono`   | ui-monospace, SF Mono, Menlo, Consolas, DejaVu Sans Mono, monospace                                |
| `arabic` | Geeza Pro, Al Bayan, Damascus, Noto Naskh Arabic, Traditional Arabic, serif                        |

## The ramp

Sizes are logical pixels at textScaler 1.0. `height` is a multiple of `fontSize` (it scales).
`letterSpacing` is absolute logical px and does NOT scale — the em column is the design intent, the
px column is what you type. All mono steps carry `FontFeature.tabularFigures()`.

| Step            | Face  | Size | Weight | Height | Tracking (em) | Tracking (px) | Where it is mandatory                                   |
|-----------------|-------|------|--------|--------|---------------|---------------|---------------------------------------------------------|
| `verdict`       | serif | 42   | w700   | 1.02   | -0.020        | -0.84         | The verdict stamp, and nothing else                      |
| `display`       | serif | 32   | w600   | 1.10   | -0.005        | -0.16         | Species vernacular name on the account screen            |
| `title`         | serif | 26   | w600   | 1.15   |  0.000        |  0.00         | Screen headings, section heads in a species account      |
| `subtitle`      | serif | 22   | w600   | 1.25   |  0.000        |  0.00         | Sub-heads, zone name on the result screen                |
| `legal`         | serif | 19   | w400   | 1.62   |  0.005        |  0.10         | Article text, the reason line, the disclaimer            |
| `legalSmall`    | serif | 17   | w400   | 1.55   |  0.010        |  0.17         | Footnotes, source note, secondary legal prose            |
| `binomial`      | serif | 17   | w400   | 1.45   |  0.010        |  0.17         | Scientific names ONLY — italic, the app's only italic    |
| `uiLarge`       | sans  | 19   | w600   | 1.20   |  0.010        |  0.19         | Primary button labels in glove mode                      |
| `ui`            | sans  | 17   | w500   | 1.35   |  0.010        |  0.17         | Buttons, nav labels, chips                               |
| `uiSmall`       | sans  | 15   | w500   | 1.40   |  0.020        |  0.30         | Helper text, secondary chrome, zone chips                |
| `eyebrow`       | sans  | 14   | w600   | 1.10   |  0.120        |  1.68         | Tracked uppercase block labels: VERDICT, SPECIES, ZONE   |
| `microLabel`    | sans  | 12.5 | w600   | 1.10   |  0.160        |  2.00         | Gazette margin rubrics, table column heads               |
| `measure`       | mono  | 36   | w600   | 1.00   | -0.010        | -0.36         | The single large measurement readout (`38 cm`)           |
| `datum`         | mono  | 18   | w500   | 1.30   |  0.010        |  0.18         | Limits, table cells, `min 45 cm total length`            |
| `citation`      | mono  | 16   | w400   | 1.50   |  0.020        |  0.32         | Instrument, article, published date, checked date        |
| `articleNumber` | mono  | 14   | w600   | 1.00   |  0.060        |  0.84         | Margin rail article numbers (`Art. 3`)                   |

### The floor, and why the small end was lifted

**Nothing a fisher must read is set below 12.5.** The first ramp put `eyebrow` at 10.5 and
`microLabel` at 9.5, and both were unreadable on a phone at arm's length. The second put them at 12.5
and 11.5 — a 19 % lift — and was reported **still too small from the same device**, which is the only
evidence that decides this. These are the third values, and the lesson is worth more than the number:
a 19 % lift on a 10.5 px label is still a small label, and a half-measure on legibility costs a second
round trip to learn nothing new. The values were calibrated as if for a printed page held close; this app
is held at arm's length, at 05:40, in glare, with wet hands, by eyes that are frequently not young.
Below about 11.5 the tracked uppercase labels stop resolving as words and become texture.

`citation` moved 12 → 14 for a different reason. It is the instrument, the article and the two dates —
the text a fisher holds up to an inspector, and the only part of the screen that answers *"says who?"*.
Setting the provenance smaller than the helper text inverted what matters.

**The top of the ramp did not move.** `verdict`, `display`, `measure` are unchanged, so lifting the
bottom compressed the ratio rather than inflating the whole page: the stamp is still the largest thing
on the screen by a wide margin, and the hierarchy reads the same. `title` and `subtitle` moved one step
each only to keep the gap above `legal` from closing.

**Tracking is recomputed, never carried over.** The `em` column is the design intent and is unchanged;
the `px` column is `em × size` and every row was recalculated. Keeping the old pixel values would have
quietly loosened every tracked label in proportion to its lift — which on `eyebrow` is a 19 % size
increase against tracking that no longer matches it.

**Arabic follows automatically.** Every Arabic step is its Latin counterpart × 1.12 and carries
`letterSpacing: 0`, because letterspacing breaks Naskh joining. Both scales were rewritten from the
same table, so the uplift cannot drift between them.

Sixteen steps. If a design needs a seventeenth, it is added here and to
`lib/theme/lonja_typography.dart` in the same commit — never invented at a call site.

## Worked content per step

- `verdict` — `Below the minimum` · `Closed season` · `Meets the rule`
- `display` — `Hamour` · `Sha'ri` · `Ameixa babosa`
- `title` — `Orange-spotted grouper` · `Minimum size` · `Closed season`
- `subtitle` — `Ras Al Khaimah` · `Rias Baixas - Banco de Cambados` · `Represa de Jurumirim`
- `legal` — `38 cm, minimum 45 cm (total length)` · the non-dismissable disclaimer paragraph
- `legalSmall` — `Rule data last checked 2026-07-14. Verify against the published instrument.`
- `binomial` — `Epinephelus coioides` · `Lethrinus nebulosus` · `Scomberomorus commerson`
- `uiLarge` / `ui` / `uiSmall` — `Measure again` · `Species` · `Zone`
- `eyebrow` — `VERDICT` · `SPECIES` · `ZONE` · `CITATION`
- `microLabel` — `MINIMUM` · `SEASON` · `SOURCE`
- `measure` — `38 cm` · `65 cm` · `38 mm`
- `datum` — `min 45 cm total length` · `min 65 cm fork length` · `closed 1 Mar - 30 Apr`
- `citation` — `Ministerial Decision 580/2015, Art. 3` · `published 2015-11-03` · `checked 2026-07-14`
- `articleNumber` — `Art. 3` · `Art. 12` · `Anexo II`

## Measures

Reading measure is a character count expressed as a pixel constant times the live scale factor.
`LonjaMeasure` lives beside the ramp.

| Constant                  | Value | Meaning                                                       |
|---------------------------|-------|---------------------------------------------------------------|
| `LonjaMeasure.legal`      | 500   | ~65 characters of 16px serif. Cap for all `legal` prose.       |
| `LonjaMeasure.legalNarrow`| 380   | ~50 characters. Cards and dialogs.                             |
| `LonjaMeasure.heading`    | 300   | ~24 characters of 23px serif. Keeps titles to two tight lines. |
| `LonjaMeasure.marginRail` | 56    | Gazette margin column for `articleNumber`.                     |
| `LonjaMeasure.digitColumn`| 92    | Pinned numeral column, required for `ar` (see arabic reference).|

Always multiply by `MediaQuery.textScalerOf(context).scale(1)` at the use site. Never store a
pre-scaled value.

## Per-theme response

The three themes change colour and weight, never size. Glove mode changes the chrome step and
spacing, never the legal step.

| Theme / mode | Serif legal | Verdict stamp | Chrome step | Notes                                        |
|--------------|-------------|---------------|-------------|----------------------------------------------|
| paper        | w400        | w700          | `ui`        | Baseline ramp exactly as tabled above.        |
| night        | w400        | w700          | `ui`        | Ink lightens; metrics identical to paper.     |
| sunlight     | w500        | w700          | `ui`        | One weight step up on serif prose for glare.  |
| glove mode   | unchanged   | unchanged     | `uiLarge`   | Density switch: targets 56dp, gaps 8dp.       |

Sunlight never goes below w500 on any step. Glove mode NEVER shrinks or grows `legal`, `verdict`
or `citation` — enlarging the legal column to make room for fat targets is how a citation gets
pushed off screen.

## Line breaking

- Flutter has no `text-wrap: balance`. Approximate it by bounding headings with
  `LonjaMeasure.heading`, not by inserting `\n`.
- Glue value and unit with a non-breaking space in the ARB: `45 cm`, `38 mm`,
  `1 Mar`. A measurement split across lines is unreadable at a glance.
- Glue the instrument to its article: `Art. 3`.
- Never hyphenate. `Scomberomorus commerson` breaks between words or not at all.

## Common conversion errors

1. Copying `letter-spacing: .14em` as `letterSpacing: 0.14` — off by a factor of 10.5.
2. Copying `line-height: 26px` as `height: 26` — `height` is a ratio; 26 means 26× the font size.
3. Setting `height` on a single-line mono readout to something other than 1.0 — it re-centres the
   digits and the big `measure` step stops sitting on the rule.
4. Using `fontWeight: FontWeight.bold` instead of the tabled numeric weight — `bold` is w700 and
   over-sets every step that wanted w500 or w600.
5. Applying tracking to `legal` above 0.01em — long serif prose with visible tracking reads as a
   logo, not as an instrument.
