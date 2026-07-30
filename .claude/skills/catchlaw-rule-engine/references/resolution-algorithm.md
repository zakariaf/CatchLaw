# Resolution Algorithm

How a bag of candidate rule rows becomes exactly one headline finding, a list of secondary findings,
an ambiguity, or a defensible "no rule found" — with the expiry axis crossing every one of them.

## The request

`resolve()` is total over its input and reads nothing from the outside world.

| Field | Type | Example | Notes |
|---|---|---|---|
| `jurisdiction` | `String` | `'AE'` | ISO 3166-1 alpha-2; never inferred from locale |
| `speciesId` | `String` | `'epinephelus-coioides'` | resolved by search BEFORE this call |
| `waterType` | `WaterType` | `.marine` / `.brackish` / `.fresh` | Jurumirim is `.fresh` |
| `zonePath` | `List<String>` | `['AE', 'AE-RK', 'AE-RK-KHOR-KHWAIR']` | root first, active zone last |
| `on` | `DateTime` | `2026-07-30` | from the injected `Clock`, date-only, UTC-normalised |
| `reading` | `Measurement?` | `38 cm`, `MeasurementMethod.tl` | null when the fisher only picked a species |
| `searched` | `List<Citation>` | the instruments covering this zone | needed to build `NoRuleFound` |

## The four stages, in order

| # | Stage | Predicate | Drops rows? |
|---|---|---|---|
| 1 | Select | `jurisdiction` = , `species_id` = , `water_type` = , `valid_from <= on` | yes |
| 2 | Lineage collapse | greatest `valid_from` per `(zone_id, citation_lineage_id)` | yes |
| 3 | Zone match | `zone_id IS NULL` OR `zone_id` in `zonePath` | yes |
| 4 | Rank | sort DESC by `scope.specificity`, stable | no |

`valid_to` is absent from all four. Stage 2 collapses only WITHIN a lineage: a 2018 amendment to
Ministerial Decision 580/2015 replaces the 2015 row because they share `citation_lineage_id`
`ae-md-580-2015`; a Fujairah local order with a different lineage id survives untouched and reaches
stage 3 on its own merits.

## Zone ancestry and specificity

`zonePath` is materialised in the reference DB, so ancestry is a list membership test, not a
recursive CTE at 05:40. The ladder is a closed table on `ZoneScope`.

| Scope | Specificity | Meaning | Real example |
|---|---|---|---|
| `exclusion` | 40 | no-take area drawn inside something larger | a marine reserve core in Ras Al Khaimah |
| `reserve` | 30 | protected area with its own regime | Ras Al Khaimah mangrove reserve |
| `bank` | 20 | named productive ground | `Rias Baixas - Banco de Cambados` |
| `subzone` | 10 | administrative subdivision | an emirate-level fishing sector |
| `region` | 0 | the default territorial rule | `Ras Al Khaimah`, `Represa de Jurumirim` |

A `NULL` `zone_id` means "the whole jurisdiction" and ranks at 0, the same as `region`. That is
deliberate: a national minimum and a regional minimum that disagree is a genuine ambiguity, not
something the sort order should quietly settle.

## The tie matrix

| Top two rows | Outcomes | Result |
|---|---|---|
| different specificity | anything | `Decided(higher)`, the other becomes a secondary finding |
| equal specificity | identical | `Decided(either)` — same outcome, both citations printed |
| equal specificity | differ | `Ambiguous(both)` |
| equal specificity, one expired | differ | `Ambiguous(both)` — expiry is NOT a tie-breaker |
| equal specificity, same lineage | differ | impossible; stage 2 already collapsed them |
| three or more equal, two agree | one differs | `Ambiguous(all at that specificity)` |

`outcomeEquals` compares the substantive content only — kind, threshold, unit, method, closure dates
— never `ruleId`, `validFrom`, `citation` or row order. Two identically-worded rules from two
instruments are not an ambiguity; they are corroboration.

## The expiry axis

| `valid_to` | `on` | In the result set? | `isExpired` | Surface |
|---|---|---|---|---|
| `NULL` | any | yes | false | normal |
| `2027-01-01` | `2026-07-30` | yes | false | normal |
| `2026-06-30` | `2026-07-30` | **yes** | **true** | ochre `StaleRuleBar`, verdict unchanged |
| `2026-06-30` | `2026-06-30` | yes | false | boundary is inclusive — the last day counts |

Worked hazard: the Galician orden de vedas is reissued annually and typically lapses on 30 April.
With a `valid_to` filter, every Galician shellfish rule disappears on 1 May and Ameixa babosa reports
"no rule recorded" — as if Galicia had stopped regulating shellfish. The bundled snapshot is a legal
artefact with a known as-of date; deleting rows on expiry turns it into a live-data product that
cannot exist offline. Tag, print the date, evaluate anyway.

## Finding precedence

Every applicable rule produces a `RuleFinding`. Failures are ranked once, here.

| Order | `FindingKind` | Headline example | Why it outranks the next |
|---|---|---|---|
| 1 | `protected` | "Protected species — taking prohibited" | species-level; no size or season applies |
| 2 | `closedSeason` | "Closed season — 1 March to 30 April" | applies to all sizes |
| 3 | `maxSize` | "Above the maximum — 122 cm, maximum 120 cm" | slot rules protect spawners |
| 4 | `minSize` | "Below the minimum — 38 cm, minimum 45 cm" | applies to this individual |
| 5 | `bagLimit` | "Above the daily bag — 9 recorded, limit 6" | per-person, per-day |
| 6 | `vesselLimit` | "Above the vessel limit" | per-hull, the widest scope, last |

Non-deciding findings are NOT discarded: a closed-season headline still carries the size finding in
`secondary`, so the rule table can print "Size rule — 45 cm total length, satisfied" beneath a
closure. The stamp states one thing; the table states everything.

## Worked traces

| Input | Stage 1 | Stages 2-4 | Result |
|---|---|---|---|
| Hamour, 38 cm TL, `AE-RK`, 2026-07-30 | 1 row, MD 580/2015 Art. 3, region | no rivals | `Decided` — `minSize` fails, 38 vs 45 cm TL |
| Sha'ri, 52 cm TL, `AE-RK`, 2026-03-14 | 2 rows: closure + minSize | both region 0, outcomes agree in kind | `Decided` — `closedSeason` headlines, `minSize` passes into `secondary` |
| Kanaad, 70 cm FL, `AE-RK`, 2026-07-30 | 1 row, min 65 cm FL | — | `Decided` — meets; methods match |
| Kanaad, 70 cm **TL**, `AE-RK` | 1 row, min 65 cm FL | — | `methodMismatch` — never compared |
| Ameixa babosa, 34 mm SHL, `banco-de-cambados`, 2026-07-30 | region row 38 mm + bank row 38 mm | bank 20 beats region 0 | `Decided` — `minSize` fails, 34 vs 38 mm SHL, expired pack tagged |
| Ameixa babosa, `banco-de-cambados`, bank says 38 mm, exclusion says no-take | exclusion 40 beats bank 20 | — | `Decided` — `protected` headlines |
| Hypothetical: two 2024 orders, both bank 20, 38 mm vs 40 mm | both survive | equal specificity, differ | `Ambiguous` — both citations printed |
| Tucunaré, `BR-SP-JURUMIRIM`, piracema portaria lapsed 2026-02-28 | 1 row | — | `Decided` + `isExpired` true, ochre bar |

## Edge cases

| Case | Behaviour |
|---|---|
| `zonePath` has one element (jurisdiction only) | only `NULL` and jurisdiction-scoped rows match; still a valid answer |
| A rule with `valid_from` in the future | dropped at stage 1; it is not law yet |
| Two rows, same lineage, same `valid_from` | content bug — surface it as an ambiguity, do not pick |
| Species matched but zero rules anywhere | `NoRuleFound(searched:, checkedOn:)` — never a permissive verdict |
| Instrument explicitly states "no size limit" | `NoLimitInInstrument(citation:)` — a positive statement, cited |
| `reading == null` on a size rule | the size finding is `indeterminate`, not a pass; closure and protection still evaluate |
| Closure spanning a year boundary (1 Nov - 28 Feb) | compared on month-day, wrapping; never on absolute dates |
| A closure whose instrument is expired | still evaluated, still tagged `isExpired` |
| Bag limit with no catch log | `indeterminate`; the app records nothing about the fisher by default |

Anything marked `indeterminate` prints as an open question in the rule table and NEVER as a pass.
Determining that a rule cannot be evaluated is itself a statement of fact, and it is a safe one.
