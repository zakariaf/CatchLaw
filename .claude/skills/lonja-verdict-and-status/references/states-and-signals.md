# States and Signals

The four verdict categories, the staleness axis that crosses them, and the signal budget each state
must spend so the screen survives greyscale, glare and a colour-blind reader.

## The signal matrix

Every state spends at least three signals, and NONE of the three may be hue.

| Category | Ink | Glyph | Headline (set by `catchlaw-verdict-contract`) | Sub-line | Meta line |
|---|---|---|---|---|---|
| `.meets` | verdant `#2E5E3A` | `Icons.check` | "Meets the minimum" | measurement | "Size rule satisfied · season open · within bag limit" |
| `.belowMinimum` | oxblood `#7A2320` | `Icons.close` | "Below the minimum" | measurement + shortfall | "Short by 7 cm · rule fails on size only" |
| `.closedSeason` | ochre `#8A6A16` | `Icons.event_busy` | "Closed season — 1 March to 30 April" | dates, day n of N | "Closure · not a size rule" |
| `.protected` | oxblood `#7A2320` | `Icons.block` | "Protected species — taking prohibited" | **none** | "Protection · no size or season applies" |
| stale (axis) | ochre `#8A6A16` | `Icons.warning_amber` | "Rule data expired 2026-06-30" | — | bar under the app bar |

Worked sub-lines: `47 cm measured · minimum 45 cm · total length` (Hamour, meets) ·
`38 cm measured · minimum 45 cm · total length` (Hamour, below minimum) ·
`In force today, day 14 of 61. Applies to all sizes.` (Sha'ri, closed season) ·
`All sizes, all seasons, all gear. Sale and possession are prohibited with it.` (protected).

## Why protected cannot be below-minimum in another shade

Both print in oxblood, because both are adverse and the palette holds one adverse ink. Hue therefore
carries **zero** information between them, and they are different offences:

| | `.belowMinimum` | `.protected` |
|---|---|---|
| What is wrong | this individual, this measurement | this species, always |
| Would a bigger fish be different | yes | no |
| Measurement sub-line | present, with the shortfall | absent — a measurement would imply a threshold |
| Glyph | `Icons.close` — a failed test | `Icons.block` — a prohibition |
| Table shape | Measured / Minimum / Shortfall | Status / Size rule: Not applicable / Season: Not applicable |
| Penalty row | first offence AED 3,000 + 6-month suspension | + second offence AED 5,000 + licence revocation |

A reader who takes only the colour reads "too small" and reaches for a bigger one of the same
species. That is the failure this rule exists to prevent.

## Staleness is an axis, not a fifth category

Any of the four categories may be stale. The bar states the expiry; the stamp is unchanged.

| | Fresh pack | Expired pack |
|---|---|---|
| `.meets` | stamp only | ochre bar + unchanged verdant stamp |
| `.belowMinimum` | stamp only | ochre bar + unchanged oxblood stamp |
| `.closedSeason` | stamp only | ochre bar + unchanged ochre stamp (bar and stamp are separate blocks, never merged) |
| `.protected` | stamp only | ochre bar + unchanged oxblood stamp |

The citation gains a second footnote marker naming the pack and its validity date: `² Bundled rule
pack RAK-GULF v2026.2 passed its validity date on 2026-06-30. The text above is the last verified
wording.` Nothing is greyed, blurred, hidden or gated. A stale rule beats no rule at sea.

## Precedence when several rules bite

The engine decides and hands down ONE category (`catchlaw-rule-engine`); the surface never re-ranks.
The order it applies, documented here so the surface's table can be read against it:

1. `.protected` — species-level prohibition outranks everything; no size or season is shown as
   applicable.
2. `.closedSeason` — a closure applies to all sizes, so it outranks a size result.
3. `.belowMinimum` — the individual fails the size rule.
4. `.meets` — every rule on record is satisfied.

Rules that did not decide the category still appear in the rule table (a closed-season stamp still
prints "Size rule — none recorded for this species"), so the fisher sees the whole picture without
the stamp equivocating.

## The absence of a rule is not a verdict

When the reference database holds no rule for this species in this zone, NOTHING is stamped. The
surface prints a serif note between the plate and the citation — "No size rule recorded for this
species in Ras Al Khaimah" — plus the citation of the instrument that was searched and its
last-checked date. Never a fifth stamp, never a grey stamp, never `.meets` by default: silence in
the sources is not permission.

## Banned imperatives, and what is printed instead

Wording is owned by `catchlaw-verdict-contract`; this table exists so the grep in
`scripts/check_lonja_verdict.sh` and the review both have the same list.

| Banned | Printed instead |
|---|---|
| "Keep" / "You can keep it" | "Meets the minimum — 47 cm measured, minimum 45 cm (total length)" |
| "Return it" / "Throw it back" / "Put it back" | "Below the minimum — 38 cm measured, minimum 45 cm (total length)" |
| "Release it" / "Do not land it" | "Protected species — taking prohibited" |
| "Do not fish for this now" | "Closed season — 1 March to 30 April. In force today, day 14 of 61." |
| "Retain" / "Discard" / "Land it" | the rule table row that states the fact |
| "Check again later" | "Rule data expired 2026-06-30 — still shown, verify before relying on it" |

The escape hatch is a trailing `// lonja-verdict-ok` on a line that is provably not a verdict string
(a settings label, a test fixture). Nothing else is exempt, and an ARB value can never be exempt.

## Greyscale and sunlight proof

Before a verdict change lands, four goldens per category are compared:

1. paper, colour — the reference.
2. paper, desaturated — the four categories must remain mutually distinguishable by glyph, headline
   and the presence or absence of the measurement sub-line alone.
3. sunlight — no grey pixel anywhere, exactly one chromatic value (`#8E0F0C`) and only on an adverse
   stamp.
4. RTL, Arabic — mirrored geometry, Naskh headline, ISO dates and Latin instrument names still
   correctly isolated.

Lanes and harness are owned by `widget-golden-and-a11y-testing`; what they must prove is owned here.

## Non-Gulf worked cases

| Case | Category | Sub-line | Citation |
|---|---|---|---|
| Ameixa babosa · *Venerupis corrugata* · 34 mm measured, 38 mm shell length | `.belowMinimum` | "34 mm measured · minimum 38 mm · shell length" | Xunta de Galicia instrument, Rias Baixas — Banco de Cambados |
| Kanaad · *Scomberomorus commerson* · 70 cm measured, 65 cm fork length | `.meets` | "70 cm measured · minimum 65 cm · fork length" | Ministerial Decision 580/2015 |
| Sha'ri · *Lethrinus nebulosus* · any size, 14 March | `.closedSeason` | "In force today, day 14 of 61. Applies to all sizes." | Ministerial Decision 580/2015, Art. 3 |

Units follow the instrument, never the locale: a Galician shell length stays in mm on an Arabic
device. Measurement conversion and rounding are owned by `catchlaw-measurement-ruler`.
