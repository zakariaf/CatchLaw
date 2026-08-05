# The design gap

`design/direction-2-lonja.html` is the design. This file is what the app does instead, screen by
screen, produced by reading the mockup's markup and CSS against `app/lib/ui/` — not from
screenshots, so every entry names a class or a widget.

**The headline.** Twenty screens compared. **Four do not exist at all.** The other sixteen exist and
are assembled wrongly: 268 elements missing, 143 in the wrong place, size, case or weight, and 99
the app renders that the mockup does not have.

**The good news, and it shapes the plan.** Almost none of this is a missing design system. The
tokens, the type ramp, the rules, the plate surface, the facts table, the citation footnote and the
tracked eyebrow all exist and are gate-enforced. Sixteen of the twenty screens are a restructuring
job — the parts are in the box and assembled in the wrong order.

| Screen | In the app | Missing | Misplaced | Extra | Effort |
|---|---|---:|---:|---:|---|
| First launch extraction (S-first-run) — direction-2- | **no** | 19 | 0 | 0 | L |
| S7 Identify (dichotomous key) | **no** | 16 | 0 | 0 | L |
| S20 — Penalties (Reference branch) | **no** | 14 | 0 | 0 | L |
| S12 Reference hub | **no** | 11 | 0 | 3 | L |
| S2 Result — closed season (with the amber/ochre expi | partial | 15 | 17 | 11 | M |
| S2 Result — Meets (species detail + verdict) | partial | 15 | 13 | 9 | M |
| S2 Result — fails (below the minimum) | partial | 15 | 11 | 7 | M |
| S1 Check (home) | partial | 14 | 10 | 8 | M |
| S14 Settings | partial | 14 | 9 | 6 | M |
| S3 — Ruler (measure the fish on the glass) | partial | 15 | 8 | 5 | M |
| S5 — Species search (Arabic, RTL) | partial | 15 | 8 | 5 | M |
| S8 Today | partial | 16 | 6 | 5 | M |
| Sunlight mode — the S2 species/result screen (below- | partial | 10 | 12 | 9 | M |
| S10 Trips | partial | 14 | 7 | 4 | M |
| S2 Result — Protected (species detail + verdict resu | partial | 13 | 8 | 8 | M |
| Glove mode — S1 Check re-set for wet hands (mockup ` | partial | 10 | 10 | 7 | M |
| S4 Calibration — calibrate the ruler against an ISO/ | partial | 12 | 6 | 3 | M |
| S13 Rule text reader (Arabic) | partial | 11 | 6 | 1 | M |
| D4 — "Two rules apply here" ambiguity dialog (mockup | partial | 10 | 6 | 4 | M |
| S6 — Browse by shape | partial | 9 | 6 | 4 | M |

`Missing` = in the mockup, absent from the app. `Misplaced` = in both, wrong order/size/case/weight.
`Extra` = the app renders it, the mockup does not. `S` restyle · `M` restructure · `L` does not exist.

---

## First launch extraction (S-first-run) — direction-2-lonja.html, "FIRST LAUNCH EXTRACTION" slot

**In the app:** no · **effort:** L
· **files:** `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/data/services/reference_installer.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/data/bootstrap_data.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/main.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/app.dart`

The screen does not exist: extraction runs headlessly (ReferenceInstaller.ensureInstalled() is invoked at bootstrap_data.dart:164 with its onProgress callback omitted, from a provider, never from a widget), there is no progress widget anywhere under app/lib/ui/, no install/extract/firstRun key in app_en.arb, and app.dart routes straight to AppShell — so the whole determinate-bar takeover has to be built from nothing.

**Missing**

- 1. Status-bar strip (.sb): mono 10.5px/.04em ink2 clock '20:11' at the start; at the end a .off badge 'NO SIGNAL · OFFLINE BY DESIGN' in sans 8.5px, .18em tracking, uppercase, boxed in a 1px rule border with 1px 4px padding, then a 13px battery glyph and '91%'. Sits on paper2 with a 1px hairline bottom. (Device chrome in the mockup, but it is the only screen that carries the offline badge.)
- 2. First-run masthead — NOT the standard .mast app bar: a plain .pad with 34px top padding, no 2px ink bottom border, no zone chip, no rules-checked chip, no back affordance, and no bottom nav anywhere on the screen (a full takeover). Inside it a .mast-row with align-items:flex-start.
- 3. .wordmark 'CatchLaw' at the start: serif, 23px (up from the standard 19px), weight 600, uppercase, .16em letter-spacing; with a nested <small> block 'Is this legal?' on its own line — serif italic, 10.5px, .06em, weight 400, ink3, 2px top margin, text-transform:none.
- 4. .mast-meta at the end of the same row, text-align:end, mono 9.5px, .12em tracking, uppercase, ink3, two lines split by <br>: 'FIRST RUN' / 'ONE TIME ONLY'.
- 5. .hr.hv — a 2px SOLID INK rule (not the 1px hairline), 16px margin block, closing the masthead.
- 6. Engraved grouper silhouette: full-width inline SVG, 96px tall, currentColor ink at opacity .9, drawn edge-to-edge inside the pad with no plate frame, no 'PL. XVII' number, no caption, no illustrator line. Overlaid with a .hatch group — three short curved shading strokes at stroke-width .7, opacity .5.
- 7. Headline <h3> 'Setting out the rule book' — serif, 25px, weight 600, line-height 1.15, 20px top margin, SENTENCE CASE (not uppercase, not tracked).
- 8. Lede .lede-s 'Unpacking the Ras Al Khaimah rule pack, the plates and the legal text so that everything opens instantly, for good.' — serif 15px, line-height 1.5, ink2, 8px top margin. Names the jurisdiction, and avoids the word 'downloading' deliberately.
- 9. Determinate progress bar .prog, 26px below the lede: 12px tall, 1.5px solid ink border, radius 0, paper2 ground, fill (.prog i) in harbour blue --blue at width:68%, inset-block:0 and inset-inline-start:0 so it mirrors under RTL. A ::after overlay paints ten decile tick marks — repeating-linear-gradient(90deg) at rgba(22,32,28,.35), 1px wide every 10% — over both filled and unfilled halves. No spinner, no CircularProgressIndicator, no indeterminate state.
- 10. Count row under the bar, 9px gap, justify-content:space-between: at the start a mono 12px ink2 count '2,143 of 3,180 entries' (grouped thousands, real entry count — not bytes and not a percentage alone); at the end a mono 12px ink '68%'.
- 11. Section label .lab-rule 'Being installed' — sans 9.5px, .2em tracking, uppercase, weight 600, ink3, followed by a flex:1 1px rule filling to the line end with a 10px gap.
- 12. Manifest table .rt, four rows, margin-top:0 so it sits tight under the label. th: start-aligned, sans 9.5px, .16em, uppercase, ink3, weight 600, width 44%, 9px block padding, baseline-aligned. td: END-aligned, serif 15px ink, 9px block padding. First row carries a 1px solid ink top rule; every row a 1px DOTTED rule underneath.
- 13. Row 1 — 'RULE PACK' / 'RAK-GULF v2026.2' plus an <em> '· done' in italic ink2 at 13.5px.
- 14. Row 2 — 'LEGAL TEXT' / 'MD 580/2015, 24 articles · done'.
- 15. Row 3 — 'SPECIES PLATES' / mono-14px '31' of mono-14px '31' with the italic '· done'; the numerals are mono inside an otherwise serif cell.
- 16. Row 4 — 'GLOSSARY AND KEY' / 'In progress…' with NO '· done' em, which is how in-flight is distinguished from complete: text alone, no colour, no spinner, no tick.
- 17. Reassurance .note, 18px top margin, sans 11.5px, line-height 1.5, ink3: 'About 4 seconds remaining.' with the numeral 4 in mono, then 'This happens once. Nothing is being downloaded — all of it was already inside the app when you installed it, and there is no network request to fail.'
- 18. Footer block pinned with margin-top:auto (the body is a flex column) and padding-block 20px/26px: a 1px .hr hairline, then a .note 'No account. No sign-in. No sync. Once this finishes, CatchLaw never waits for anything again.'
- 19. The layout contract itself: .body is display:flex/flex-direction:column so the footer sinks to the bottom on a tall device while the masthead, plate, headline and table stay top-anchored.

---

## S7 Identify (dichotomous key)

**In the app:** no · **effort:** L

The screen does not exist: E14 (Identification key) is marked v2 in epics/README.md and epics/RELEASES.md, and the only trace in app/lib/ui is the entry-point button `LonjaButton.primary(label: l10n.identifyThisFish)` inside `_SearchEmptyState` in app/lib/ui/species/widgets/species_search_screen.dart, wired in app/lib/ui/check/check_screen.dart line 99 as `onIdentify: () {}` — a deliberate no-op with a comment saying S7's key is E14's, so nothing routes to a couplet, no `ui/identify/` directory exists, and no ARB key for any couplet, breadcrumb, candidate count or skip copy is authored.

**Missing**

- Top-to-bottom element 1 — status bar `.sb`: time '05:42' at the start, and at the end 'No signal · offline by design' (`.off`), the `#i-batt` icon at 14px, and '83%'.
- Element 2 — a back-and-title app bar `.bar` (NOT the `.mast` gazette masthead the app ships in lonja_masthead.dart): 1px rule bottom border, a 44px `.iconbtn` back affordance with a 22px `#i-back` glyph and margin-inline-start:-10px, an `h2` in serif 18px/600 with letter-spacing .01em reading 'Identify this fish', and a right-aligned `.sup` in mono 9.5px, letter-spacing .1em, uppercase, ink3, reading 'Key · couplet 4'. The app has no back-title bar widget at all — only LonjaMasthead.
- Element 3 — `.lab` eyebrow 'Answers so far': sans 9.5px, letter-spacing .2em, uppercase, weight 600, ink3.
- Element 4 — the `.crumb` decision trail: a wrapping flex chain, sans 11px ink2 with `›` separators in ink3 as `<i>` elements, gap 5px/7px — 'Salt water › Bony fish, not a ray › Single dorsal fin › Body deeper than 1∶3'. Nothing in the app records or renders a traversal trail.
- Element 5 — a heavy `.hr.hv` divider: 2px solid ink (not the 1px hairline `.hr`), margin-block 14px 0. app/lib/ui/core/ui/lonja_rule.dart exists but nothing draws this couplet-opening rule.
- Element 6 — a baseline-aligned two-part header row: at the start, mono 11px letter-spacing .14em ink3 'COUPLET 4 · THE TAIL'; at the end, a `.pill.bl` (blue, mono 9px, letter-spacing .12em, uppercase, 1px currentColor border, 2px/5px padding) containing a mono '18' plus 'SPECIES REMAIN' — the live count of what is still possible.
- Element 7 — the couplet question as an `h3`: serif 21px, weight 600, line-height 1.2, margin-top 8px — 'Look at the tail fin only.'
- Element 8 — the two `.opt` couplet buttons in a `.btn-row` grid (gap 12px, padding-top 14px). Each is a full-width 1.5px solid ink border on paper2, min-height 112px, flex row with gap s4, padding s4, text-align start, and contains, in order: a 112x62 `.fish` silhouette at stroke-width 1.6 (`#f-kanaad`, `#f-hamour`); a `.k` key label in mono 9.5px ink3 letter-spacing .1em, margin-bottom 3px ('4 a' / '4 b'); a `.t` lead in serif 17px line-height 1.25 ink ('Deeply forked, or crescent-shaped with stiff points' / 'Rounded, square, or only slightly notched'); and a `.d` consequence line in sans 11.5px ink3, margin-top 4px ('Leads to 7 species · Kanaad, Sha'ri, Zubaidi' / 'Leads to 11 species · Hamour, Safi, Badh'). LonjaSilhouette exists and the sil/*.svg assets are on disk, but no option-card widget uses them.
- Element 9 — a `.btn.ghost.sm` back-one-step button carrying the `#i-back` glyph: rule-grey border, ink2, weight 500, min-height 46px, 13.5px, label 'Back one step'.
- Element 10 — a `.lab-rule` section head: the `.lab` 'If the tail is damaged' followed by a 1px hairline `::after` filling the rest of the row (margin-block s6 s4). LonjaSectionLabel may cover the pattern but this instance is unauthored.
- Element 11 — the damaged-tail `.note`: sans 11.5px, line-height 1.5, ink3 — 'Skip this couplet and answer on the mouth instead. The key will take two more steps but reaches the same 18 species.'
- Element 12 — a second `.btn.ghost.sm` with margin-top 12px, label 'Skip this couplet' (the alternate-route affordance).
- Element 13 — a 1px `.hr` hairline separating the skip block from the closing note.
- Element 14 — the offline provenance `.note`: 'No photograph is taken and nothing leaves the device. The key is the printed one from the reference section, walked one couplet at a time.'
- Element 15 — a 20px trailing spacer above the nav.
- Element 16 — the five-destination `.nav` strip with Check selected (`.ni.on`): Check, Today, Trips, Reference, Settings. LonjaNavStrip exists in app/lib/ui/core/ui/lonja_nav_strip.dart, so this is the one piece of chrome already built — but it is never composed with an identify screen because there is none.

---

## S20 — Penalties (Reference branch)

**In the app:** no · **effort:** L

Nothing in app/lib/ui implements S20 — there is no PenaltiesScreen, no route to one and no ARB copy; only the drift `penalty` table (app/lib/data/services/tables/reference/penalty.dart) and the epic file epics/E15-reference/T06-s20-penalties.md exist, and the Reference branch (app/lib/ui/reference/widgets/reference_screen.dart) currently renders the species browse grid instead of the S12 hub that would link to it.

**Missing**

- Pushed-route app bar (.bar): 44dp back `.iconbtn` with #i-back at 22px, an h2 title "Penalties", and a trailing `.sup` jurisdiction stamp "IV · UAE". The app has no bar of this shape anywhere — ReferenceScreen prints a bare `type.title` Text with no back affordance and no jurisdiction chip.
- Lede paragraph (.lede-s, serif 15px/1.5, ink2, 16px top pad): "What a breach of the size, season, protection or gear rules carries in the United Arab Emirates." No equivalent widget or ARB key.
- The penalties ledger table (.ptab inside .xscroll) — this is the whole point of the screen and it is entirely absent. Header row `th`: sans 9.5px, letter-spacing .14em, uppercase, ink3, weight 600, text-align start, border-bottom 1.5px solid ink — columns OFFENCE / FINE / LICENCE. Two body rows (First offence / Second offence), `td` padding 11px 8px 11px 0, vertical-align top, border-bottom 1px dotted rule; first column pinned to 34% width. There is no LonjaLedgerTable, no penalties row widget, and DataTable is banned so this has to be authored.
- The oxblood fine cell (.ptab .fine): mono 14px, colour oxblood, weight 600 — "AED 3,000" / "AED 5,000", with a plain-serif word beside it ("First offence") carrying the non-colour signal. Nothing in the app renders a currency amount at all; there is no money/currency formatter beside app/lib/ui/core/format/measurement_format.dart.
- Licence-consequence cells with an inline `.mono` span for the duration ("Suspension for 6 months", "Revocation") — mono tabular figures inside serif prose.
- Horizontal-scroll wrapper (.xscroll, overflow-x:auto) around the three-column table so it survives large text scale rather than wrapping. No scrolling table container exists in app/lib/ui/core/ui/.
- Section eyebrow with trailing hairline (.lab-rule + .lab): "What counts as an offence" — sans 9.5px, letter-spacing .2em, uppercase, ink3, weight 600, with a 1px rule flexing to the end of the line. The app HAS this component (app/lib/ui/core/ui/lonja_section_label.dart) but no screen uses it for penalties.
- The five-row offence definition table (.rt): th start-aligned eyebrow at 44% width (sans 9.5px, .16em tracking, uppercase, ink3), td end-aligned serif 15px ink, first row bordered top 1px solid ink, every row bottom 1px dotted. Rows in order: Below the minimum → Landing, holding or selling; Closed season → Any size, any gear; Protected species → Taking, holding, transporting or offering for sale; Over the bag limit → Per person and per vessel; Gear breach → Mesh, length or prohibited method. app/lib/ui/result/widgets/result_rule_facts_table.dart is the closest existing analogue but is bound to a verdict's findings, not to penalty definitions.
- The worked-example panel (.diag, 1px rule border, paper2 ground, 12px padding): `.dl` label "WORKED EXAMPLE" (sans 10.5px, .14em tracking, uppercase, ink3, 600) above `.dd` serif 13.5px/1.4 ink2 prose carrying four mono spans — 38 cm, 45 cm, AED 3,000, 120 AED, AED 90. No such panel; app/lib/ui/core/ui/lonja_panel.dart exists but nothing composes this.
- Two-footnote citation block (.cite with margin-inline:0): a 44%-wide 1px ink `.fnrule` above, then footnote ¹ (mono 9px superscript) with `.who` in small-caps at .06em tracking — "United Arab Emirates — Ministerial Decision 580/2015, Art. 3 · published 2015-11-03 · checked 2026-07-14" — then footnote ² "Amounts are those recorded in the bundled rule pack. Courts and inspectors may apply additional federal provisions." app/lib/ui/result/widgets/result_citation_footnote.dart implements the single-footnote form for the verdict surface; the two-footnote, pack-caveat variant does not exist.
- Permanent disclaimer bar (.disc with margin-inline:0): 2px solid ink top border, 1px rule bottom, paper3 ground, 15px #i-info glyph, sans 11.5px/1.45 ink2, bold lead "Reference only — not legal advice." then "Verify with the Ministry of Climate Change & Environment." app/lib/ui/result/widgets/result_disclaimer.dart is the equivalent widget but is scoped to the result surface and never mounted on a reference page.
- Bottom nav strip with Reference selected while a pushed detail route is on screen. LonjaNavStrip exists (app/lib/ui/core/ui/lonja_nav_strip.dart) but no penalties route participates in it.
- The entry point itself: SPEC §6's S12 reference hub card `reference_section_penalties` routing to this screen (epics/E15-reference/T01) — ReferenceScreen currently pushes straight into SpeciesBrowseScreen, so there is no surface from which S20 could ever be reached.
- The empty state required by E15/T09 for a jurisdiction with no `penalty` rows ("no penalty recorded", never "there are no penalties").

---

## S12 Reference hub

**In the app:** no · **effort:** L
· **files:** `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/reference/widgets/reference_screen.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/reference/widgets/rule_text_screen.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/species/widgets/species_browse_screen.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/core/ui/app_shell.dart`

The Reference destination is routed and renders something, but it is S6 (the silhouette browse grid) — not one element of S12's table-of-contents hub exists: no gazette masthead, no lede, no roman-numeral leader-dot contents list, no "Sources held" instrument blocks.

**Missing**

- Gazette masthead (`header.mast`, 2px solid ink #16201C bottom rule, paper ground): serif wordmark "Reference" at 19px / .16em tracking / uppercase / weight 600, with an italic serif 10.5px `small` "Contents" stacked under it. The app prints a bare `Text(l10n.navReference, style: type.title)` in mixed case with no tracking, no italic sub-line and no 2px rule.
- Masthead right-hand `.mast-meta`: mono 9.5px, .12em tracking, uppercase, ink3, end-aligned, two lines "RAK-GULF" / "v2026.2" — the zone and pack version. `LonjaMasthead` exists but carries place + checkedOn + a "change place" TextButton, and is not used on this screen at all.
- Lede paragraph `.lede-s` (serif 15px, line-height 1.5, ink2), first thing in the body above the contents: "Everything a verdict is drawn from, held in full on this device and readable without a signal."
- Section eyebrow `.lab-rule` reading "Contents" — sans 9.5px, .2em tracking, uppercase, weight 600, ink3, followed by a 1px #C2C5BB hairline running to the end of the line. (`LonjaSectionLabel` is the equivalent widget and is never called here.)
- The contents list itself: `div.toc` with a 2px solid ink top rule, containing seven `button.toc-i` rows, each min-height 60px, 12px/20px padding, separated by a 1px #CFCFC4 hairline.
- Per-row anatomy of `.toc-i`, baseline-aligned in a 10px-gap flex row: mono roman numeral `.rn` in a fixed 26px gutter, ink3, 10.5px, .06em; serif `.tt2` title at 17.5px ink, nowrap; a flexing dotted leader `.dots` (1px dotted ink3, translated -4px); a mono `.cnt` count at 11px ink2 pinned to the end; then a full-width sans 11.5px ink3 `.sub` subtitle on a second line, indented 36px to clear the numeral gutter.
- The seven contents entries in this exact top-to-bottom order, with their counts and subtitles: I Rule text / 24 art. / "Ministerial Decision 580/2015, verbatim, Arabic and English"; II Protected species / 18 / "Plates, distinguishing features, what protection covers"; III Gear and methods / 11 / "Gargoor mesh, hand-line, net length, prohibited methods"; IV Penalties / 2 tiers / "Fines and licence consequences, by offence"; V Licences / 5 / "Vessel, fisher and gear licences and what each permits"; VI Glossary / 96 / "TL · FL · SL · CW · SHL · ML and the local terms"; VII Changelog / 7 / "What changed in each rule pack, and when it was checked". Nothing in `app/lib` names any of these seven sections — no ARB key, no route, no widget.
- Second section eyebrow `.lab-rule` "Sources held", below the contents list.
- Two `.instr` instrument blocks, each with a 3px harbour #1B4D5E inline-start border and 11px inline-start padding: `.k` jurisdiction (sans 9.5px, .16em tracking, uppercase, weight 600, ink3), `.t` instrument + article (serif 15px ink), `.c` dates (mono 10.5px ink3). Content: "UNITED ARAB EMIRATES / Ministerial Decision 580/2015, Art. 3 / published 2015-11-03 · checked 2026-07-14" and "GALICIA / Orde do 27 de xullo de 2012, Anexo II / DOG núm. 226 · checked 2026-06-02".
- Closing `.note` (sans 11.5px ink3): "Both texts are stored complete. The app quotes them; it does not summarise them."
- Tappability of the contents rows — every `.toc-i` is a `button`; entry I is the only one the app could satisfy today (`RuleTextScreen` exists but is reachable only from a citation tap on the result surface, never from Reference).

**Extra**

- The whole S6 browse surface occupies the Reference slot: `ReferenceScreen` (app/lib/ui/reference/widgets/reference_screen.dart) wraps `SpeciesBrowseScreen` in an `Expanded`, so the branch shows a family-grouped grid of 132px-extent silhouette tiles — a grid of cards, precisely the shape the S12 caption says the hub is *not* ("rather than a grid of cards").
- Two stacked screen titles, because `ReferenceScreen` prints `navReference` ("Reference") in `type.title` and then embeds `SpeciesBrowseScreen`, which is itself a `Scaffold` printing `browseByShapeTitle` ("Browse by shape") in `type.title` again. The mockup has one masthead.
- Per-family `LonjaSectionLabel` headings and the silhouette tiles' `uiSmall` species names — list furniture that belongs to S6, not to the reference hub.

---

## S2 Result — closed season (with the amber/ochre expired-rule-pack bar)

**In the app:** partial · **effort:** M

The result machinery all exists — stamp, facts table, footnote, disclaimer — but as rendered on `SpeciesDetailScreen` it is a differently ordered page: no app bar, no ochre expiry bar (`StaleRuleBar` is imported and never mounted), the plate has no frame/plate-number/caption and sits under a 32px name block instead of over one, and the mockup's three-part stamp (uppercase tracked headline + serif sub-line with mono figures + tracked meta line) collapses into one 42px sentence-case sentence.

**Missing**

- The `.bar` app bar entirely: `SpeciesDetailScreen` builds `Scaffold(body: SafeArea(...))` with no AppBar — so no 44px back `iconbtn`, no serif 18px/600 species name `h2`, and no end-aligned mono 9.5px uppercase tracked `.sup` date ('14 MAR 2026')
- The `.amber` expiry bar. `StaleRuleBar` (app/lib/ui/result/widgets/stale_rule_bar.dart) is fully built but rendered nowhere: `ResultSection` does not include it, and `species_detail_screen.dart` line 19 imports `lonja_stale_bar.dart` and never uses it. The mockup's bar sits directly under the app bar, above the plate: warn glyph + ochre top/bottom 1px borders + ochre-tint ground + sans 11.5px 'Rule data expired 2026-06-30 — still shown…'. The app instead only whispers the pack expiry as a `provenance` line appended under footnote 1
- The `.plate-frame`: 1px ink border with an inset 1px rule (`::after{inset:3px}`) on `paper2`. `LonjaPlateSurface` draws only a 2px top rule over `surfaceSunk` — no box, no inset second rule
- The `.plate-no` label 'PL. IX · fig. 3' — mono 9px, .16em tracking, uppercase, absolutely positioned top-start inside the frame. Nothing in the app draws a plate number
- The `.plate-cap` caption under the plate: Arabic `.loc` 27px, transliteration `.tr` serif 19px/600, `· English name` `.en` serif 15px on the same baseline row, then `.sci` 'Lethrinus nebulosus — Lethrinidae' italic 13.5px on its own line. The app has no caption under the art at all
- The `.stamp-sub` line as a separate node: serif 15.5px in ink (not the verdict ink) with `.mono` 15px/600 figures for '14' and '61', plus 'Applies to all sizes.' The app's `signalsFor(closedSeason).measured == false` drops `subLine`, and the whole sentence is folded into `verdictClosedSeasonInForce` so the day counts render at 42px serif with no mono/tabular figures
- The `.stamp-meta` line 'Closure · not a size rule' — sans 10.5px, .14em tracking, uppercase, in the stamp's ochre. `_VerdictStamp` has no third slot; there is no non-colour category label under the rules
- The calendar glyph is present (`LonjaIcons.closedSeason`) but three of the mockup's five table rows are not produced: 'Closed until … <em>inclusive</em>', 'Reopens <mono>1 May 2026</mono> <em>· in 48 days</em>', 'Size rule — None recorded for this species', 'Also closed — Safi <em>· same dates</em>'. `_factsFor(ClosedSeasonFinding)` emits exactly two facts: 'Dates' (start to end) and 'Today' (day n of m)
- The `<em>` qualifier run inside a table value (italic, ink2, 13.5px — 'inclusive', '· same dates'). `RuleFact` is a flat label/value pair with no qualifier slot
- The `.note` under the table — sans 11.5px, ink3, 'Badh (Yellowfin seabream) carries a separate closure, 1 April to 1 June.' `ResultNote` exists but is the no-stamp substitute (`display.note` is only non-null when there is no stamp), so a note can never appear beside a closed-season stamp
- The pack-expiry sentence as its OWN numbered footnote ('²Bundled rule pack RAK-GULF v2026.2 passed its validity date on 2026-06-30…'). In the app the provenance is an unnumbered trailing line under footnote 1
- `.cite .who` small-caps: `font-variant:small-caps; letter-spacing:.06em` for the authority name. The app renders the authority with `type.eyebrow` (sans, 14px, 1.68px tracking) on its own line
- The disclaimer's chrome: `.disc` info glyph, `paper3` ground, 2px ink top border and 1px rule bottom border, and the mono 8.5px uppercase `.fix` line 'Shown on every result · cannot be dismissed'. `ResultDisclaimer` is two bare `Text` widgets with no icon, no ground, no rules
- The bottom `.btn-row` action 'Add to today' with the plus icon (`#i-plus`) — a 56px-min outline `.btn`. The app's terminal action is `LonjaButton.secondary` labelled from `l10n.catchRecord` with no leading glyph
- The 5-cell `.nav` ledger strip. `SpeciesDetailScreen` is pushed as a full-screen `MaterialPageRoute` from `check_screen.dart:66` / `reference_screen.dart:34`, outside `AppShell`, so `LonjaNavStrip` is not on this screen

**Misplaced**

- ORDER — plate vs. name. Mockup: plate figure first, names as its caption beneath. App: `_SpeciesHeader` (name 32px display, 'Family: …', italic binomial) is child 0 and `_SpeciesArtPanel` is child 2, so the naming block is above the art and in the wrong type sizes (display 32px vs the mockup's 27px Arabic / 19px transliteration pairing)
- ORDER — the ochre bar. Where it does surface at all it is at the very bottom of the page as a footnote provenance line; the mockup puts it third from the top, above the plate, as a full-bleed band
- ORDER — measurement before the verdict. `_MeasureSlot` (a `LonjaButton.secondary` labelled 'Measure' / the last reading) sits between the names and `SpeciesVerdict`; the mockup's closed-season screen has no measurement affordance in the body and only one button, at the foot
- ORDER — the rule table is below the secondary findings list in `ResultSection` (`ResultFindingsList` then `ResultRuleFactsTable`); the mockup runs stamp → table → note with no separate findings list between them
- ORDER — the disclaimer is the last thing in `ResultSection`, then `_RecordCatchAction` is appended by the parent screen after it. Same relative order as the mockup (disclaimer then button) but the button is outside the result block and gets the parent's uniform gutter rather than the mockup's `padding-block:16px 20px` btn-row
- Stamp headline SIZE and CASE: `type.verdict` is serif 42px/w700, sentence case, and the ARB string carries the whole closure sentence, so 'Closed season — 1 March to 30 April. In force today, day 14 of 61.' wraps to four or five 42px lines. Mockup `.stamp.long .stamp-ink h3` is 21px, `text-transform:uppercase`, `letter-spacing:.005em`, `line-height:1.02`, deliberately broken at two lines with an explicit `<br>`
- Stamp tilt: app `kVerdictStampTilt = -0.0096` rad ≈ -0.55°, which matches `transform:rotate(-.55deg)` — but the app's `Transform.rotate` wraps the padded block including its top gap, and the mockup rotates only the ruled band
- Stamp rules: `_DoubleRule` draws two `LonjaRules.rule` lines separated by `LonjaRules.strong`; the mockup is `border-top/bottom:4px double currentColor` — check the composite reads as 4px total, not 2 × rule + 2px gap
- Stamp glyph size: `LonjaIconSize.stamp` is 30 (matches `.stamp-ink .ic{width:30px}`), but it is aligned `CrossAxisAlignment.start` against a 42px cap height; the mockup's `.stamp-ink` is `align-items:center`
- Rule-table dividers: `ResultRuleFactsTable` puts a solid `Divider(height: LonjaRules.rule)` ABOVE every row. Mockup `.rt tr` is `border-bottom:1px dotted var(--rule)` with a solid `1px ink` only on `tr:first-child`'s top — dotted vs solid, and below vs above
- Rule-table columns: app is `Expanded(flex 1)` label / `Expanded(flex 2)` value. Mockup `.rt th{width:44%}` with the value column taking the rest — label column is materially wider in the mockup
- Rule-table label case: `fact.label` is the raw ARB value 'Dates' / 'Today' in `type.eyebrow`; the mockup `.rt th` is `text-transform:uppercase` at 9.5px with .16em tracking. Flutter has no text-transform, so these render title-case
- Rule-table value face: app uses `type.datum` (mono 18px) for every value; the mockup `.rt td` is serif 15px with only the figure spans in `.mono` 14px, so dates read as prose with monospaced numerals rather than wholly monospaced
- Citation footnote SHAPE: app splits it into three stacked `Text` nodes (authority in eyebrow / instrument+article in `type.citation` mono 16px / 'published … · checked …' mono 16px). Mockup is one flowing serif 12px paragraph with a `<sup>` mono 9px marker and only the authority differentiated by small-caps
- Citation footnote RULE: the 44%-wide ink rule (`footnoteRuleKey`, `widthFactor:0.44`) is drawn inside EVERY `ResultCitationFootnote`, so two instruments give two rules. Mockup `.cite .fnrule` appears once above the whole footnote block
- Citation marker: app prints a full-size `type.articleNumber` (mono 14px, .84px tracking) inline at the start of the row; the mockup uses `vertical-align:super` at 9px
- Disclaimer type: app uses `type.legalSmall` (serif 17px) for the body and `type.citation` (mono 16px) for 'It cannot be dismissed.' Mockup is sans 11.5px body with a bold ink lead-in, and the fix line is mono 8.5px uppercase with .14em tracking — the app's two lines are roughly 1.5× the mockup's size and the wrong families

**Extra**

- `_OtherNamesBlock` — a 'Other names' section label, one line per locale name, and a closing `LonjaRule.row()` between the plate and the measure slot. The mockup folds the local/transliterated/English names into the plate caption and shows no such section
- `_MeasureSlot` — a full-width secondary button ('Measure' or the last reading) inside the body
- `_SpeciesHeader`'s 'Family: Lethrinidae' as its own `uiSmall` line. The mockup carries the family appended to the binomial: 'Lethrinus nebulosus — Lethrinidae'
- `_SpeciesHeader`'s conditional `speciesProtectedAnywhere` datum line when `account.isProtectedAnywhere`
- The copy affordance in the footnote: `IconButton` keyed `result-citation-copy` with the `_CopyMark` two-square glyph and `Clipboard.setData(printedLine)`
- The footnote's tappable region — the whole `ResultCitationFootnote` is an `InkWell` (`openKey`) onto the verbatim rule text. The mockup's closed-season footnote is static text
- `SelectableText(sourceUrl)` under the footnote when the instrument records one
- `ResultFindingsList` — a per-finding line block (marker + tick/cross/open-question glyph + sentence + 'instrument · article') between the stamp and the table
- `_RecordCatchAction`'s latched label swap to `l10n.catchRecorded` after a successful write
- Haptic announcement on stamp change (`ResultHaptics.announce` from `_ResultSectionState._announce`)
- Sunlight-skin reversal: `LonjaSkinScope` flips the stamp to reversed-out ink on a solid ground and drops the tilt (D-20) — no counterpart in the mockup

---

## S2 Result — Meets (species detail + verdict)

**In the app:** partial · **effort:** M

The verdict half exists and is well built (tilted stamp between double rules, facts table, footnote, disclaimer), but the identification half of the mockup is a different composition — no app bar, no framed engraved plate with plate number and caption block, names above the art instead of captioned below it — and the stamp itself collapses the mockup's three-line headline/sub/meta hierarchy into one 42px wrapping sentence plus a 36px mono margin line.

**Missing**

- `.bar` app bar entirely: SpeciesDetailScreen is `Scaffold(body: SafeArea(...))` with no `appBar`, so the back `iconbtn`, the `<h2>Hamour</h2>` title, and the `.sup` zone tag (mono 9.5px, .1em tracking, uppercase, ink3, pushed to the inline end) have no equivalent
- The five-destination `.nav` strip with Check selected: the screen is pushed as a bare `MaterialPageRoute` from check_screen.dart:66 and reference_screen.dart:34, i.e. outside `AppShell`/`LonjaNavStrip`, so the result takeover loses the nav the mockup keeps
- `.plate-frame` engraving frame — 1px ink border + 6px padding + the `::after` inset-3px hairline second frame on `paper2`. `LonjaPlateSurface` draws only a 2dp top `BorderDirectional` over `surfaceSunk`; there is no box, no double frame
- `.plate-no` 'PL. XVII · fig. 1' — mono 9px, .16em tracking, uppercase, ink3, absolutely positioned top/inline-start over the art. Nothing in `LonjaPlateSurface` or `LonjaSilhouette` prints a plate number
- The `.hatch` group (stroke-width .7, opacity .5) that makes the art read as an engraving; `LonjaSilhouette` renders a flat authored SVG with no hatching layer
- `figcaption.plate-cap` as a block: the baseline-aligned flex row of Arabic `هامور` (27px Naskh) + `.tr` 'Hamour' (serif 19px, w600, .02em) + `.en` '· Orange-spotted grouper' (serif 15px ink2), with `.sci` 'Epinephelus coioides — Serranidae' italic 13.5px ink3 wrapping to its own full-width line. The app has no caption under the art at all
- `.stamp-meta` — the tracked uppercase summary line 'Size rule satisfied · season open · within bag limit' (sans 10.5px, .14em, currentColor). `VerdictStampDisplay` has only `headline` + `subLine`; there is no third slot
- Three of the five `.rt` table rows: Season ('Open all year'), Bag limit ('5 per person · 3 recorded'), Zone ('Ras Al Khaimah · Gulf, salt'). `ResultSection` feeds `ResultRuleFactsTable` only `display.findings.first.facts`, so a MEETS on a size rule yields Measured + Minimum and nothing else
- `.rt` italic `em` qualifiers inside a cell ('total length (TL)', '· 3 recorded', '· Gulf, salt') — `RuleFact` is a flat label/value pair with one style
- `.rt td.vd` — the verdant-600 pass cell. `_FactLine` only ever tints a value `verdictFail` (via `fact.isOutcome`); there is no pass ink for a table cell
- `.rt tr:first-child{border-top:1px solid var(--ink)}` and `border-bottom:1px dotted var(--rule)`: the table opens on a solid ink rule and separates on dotted hairlines. `ResultRuleFactsTable` emits a plain `Divider(height: LonjaRules.rule)` above every row — solid, uniform, and no opening ink rule
- The `.lnk` line 'Read Article 3 in full →' (blue, underlined, sans 11.5px, its own paragraph under the citation). `ResultCitationFootnote` makes the whole block an `InkWell` with no visible affordance text
- `.cite .who` — the jurisdiction set inline in small-caps (.06em, 13px) inside one serif 12px running sentence
- The `.disc` container: `paper3` ground, `border-top:2px solid ink`, `border-bottom:1px solid rule`, 10/11px padding, and the 15px info glyph. `ResultDisclaimer` is two bare `Text` widgets with no box, no rule and no icon
- The primary `.btn.dark` 'Add to today' with the `#i-plus` glyph — `_RecordCatchAction` renders `LonjaButton.secondary` with a text-only 'Record catch' label

**Misplaced**

- ORDER — identification block: mockup is plate art first, then the caption naming it. App is `_SpeciesHeader` (name, family, binomial) FIRST, then `_SpeciesArtPanel`. The names sit above the art instead of captioning it
- ORDER — the app inserts `_OtherNamesBlock` (section label + one line per locale + `LonjaRule.row()`) and `_MeasureSlot` between the art and the stamp; in the mockup the stamp is struck directly 48dp under the plate with nothing between
- Stamp headline: mockup `.stamp-ink h3` is serif 26px/1.02, w700, `text-transform:uppercase`, and short ('MEETS THE MINIMUM'). App uses `type.verdict` = serif 42px, w700, letterSpacing -0.84, no uppercase, and `head.sentence` is the full 'Meets the minimum — 47 cm measured, minimum 45 cm (total length)' — one wrapping sentence where the mockup has a short tracked headline
- Stamp sub-line: mockup `.stamp-sub` is serif 15.5px/1.35 in body ink with mono-15px-600 spans on the figures ('47 cm measured · minimum 45 cm · total length'). App prints `type.measure` = MONO 36px w600 and a different sentence entirely (`_marginFor` → 'Over the minimum by 2 cm')
- Stamp glyph: `.stamp-ink .ic` is 30px at stroke-width 1.7, vertically centre-aligned with the headline (`align-items:center`). App uses `LonjaIconSize.stamp` inside a `Row` with `CrossAxisAlignment.start`, so it top-aligns against a 42px line
- Stamp tilt: mockup `rotate(-.55deg)`; app `kVerdictStampTilt = -0.0096 rad` ≈ -0.55deg — matches, but the mockup's rules are `4px double currentColor` on both edges while `_DoubleRule` draws two `LonjaRules.rule` lines split by a `LonjaRules.strong` gap
- Facts table labels: mockup `.rt th` is sans 9.5px, .16em, uppercase, ink3, fixed 44% width, baseline-aligned. App uses `type.eyebrow` (sans 14px, letterSpacing 1.68, no `text-transform`) in `Expanded(flex:1)` against `Expanded(flex:2)` — larger, wider and only uppercase if the ARB string already is
- Facts table values: mockup `.rt td` is SERIF 15px end-aligned with a mono 14px span only on the figure. App sets the whole value in `type.datum` (mono 18px) — mono where the mockup is serif, and one step larger
- Citation block: mockup is one serif 12px/1.5 paragraph — `¹ UNITED ARAB EMIRATES — Ministerial Decision 580/2015, Art. 3 · published … · checked …`. App stacks three separate lines (jurisdiction in `type.eyebrow`, instrument+article in `type.citation` mono 16px, dates in mono 16px), so a 12px running footnote becomes a three-line mono stack roughly the weight of the facts table
- Footnote rule: mockup `.cite .fnrule` is 44% wide, 1px, `var(--ink)` at .85 opacity. App draws it at `widthFactor: 0.44` but in `tokens.hairline` — the faint rule slot, not ink
- Disclaimer body: mockup is sans 11.5px/1.45 with a bold ink lead-in. App uses `type.legalSmall` (SERIF 17px) — wrong family and half again the size
- Disclaimer fine print: mockup `.fix` is mono 8.5px, .14em, uppercase, 'Shown on every result · cannot be dismissed'. App prints `type.citation` (mono 16px, no uppercase) with the shorter 'It cannot be dismissed.'
- Final action: mockup's is the screen's one primary (`.btn.dark`, solid, with plus glyph); app's is `LonjaButton.secondary` (outline) and unlabelled by a glyph

**Extra**

- `_SpeciesHeader` family line — 'Family Serranidae' in `type.uiSmall`; the mockup folds the family into the `.sci` caption line ('Epinephelus coioides — Serranidae')
- `_SpeciesHeader` protected-anywhere datum line (`l10n.speciesProtectedAnywhere`), shown when `account.isProtectedAnywhere`
- `_OtherNamesBlock` — a 'Other names' `LonjaSectionLabel`, one `type.legal` line per locale, and a closing `LonjaRule.row()`
- `_MeasureSlot` — a secondary button routing to `MeasureScreen`, whose label becomes the reading once measured. The mockup's S2 arrives already measured
- `ResultFindingsList` — the secondary findings printed as marker + glyph + serif 19px sentence + a mono instrument/article line each. The mockup carries the same information only as `.rt` table rows
- `ResultCitationFootnote`'s copy `IconButton` with the `_CopyMark` nested-square affordance (no equivalent in `.cite`)
- `ResultCitationFootnote`'s `SelectableText` source URL and the `provenance` line under the first footnote
- Loading (`LonjaListSkeleton`) and raw `Text('$error')` states inside `SpeciesVerdict`
- `_RecordCatchAction`'s latched 'Recorded' label state

---

## S2 Result — fails (below the minimum)

**In the app:** partial · **effort:** M

The app has all the load-bearing blocks — plate, struck double-ruled stamp, ruled facts table, 44%-rule citation footnote, permanent disclaimer — but it renders them as a species account with the verdict bolted underneath rather than as the mockup's result page: no app bar/back/zone eyebrow, the names sit above the plate instead of as an engraved caption below it, the stamp collapses the mockup's three type registers (uppercase serif headline / serif+mono detail / tracked sans meta) into one 42px wrapping sentence plus a 36px mono margin line, and the measurement diagram, the Season and penalty rows, the second footnote and the "Read Article 3 in full" link are absent.

**Missing**

- App bar (.bar): no AppBar/LonjaMasthead at all on SpeciesDetailScreen — it is a bare Scaffold(body: SafeArea(...)) pushed by MaterialPageRoute from check_screen.dart:66. The mockup's 44px back .iconbtn, the serif 18px/600 species title 'Hamour', and the mono 9.5px uppercase .1em-tracked .sup zone label 'Ras Al Khaimah' pinned to the line end are all absent.
- Plate frame: .plate-frame's 1px ink border with the inset 1px rule ::after (double engraved frame) — LonjaPlateSurface draws only a 2px hairlineStrong TOP border over a surfaceSunk block, no box frame, no inset second rule.
- Plate number: .plate-no 'PL. XVII · fig. 1', mono 9px, .16em tracking, uppercase, absolutely positioned top-start over the frame. Nothing in _SpeciesArtPanel or LonjaSilhouette prints a plate/figure number.
- Engraved hatching: the .hatch <g> at stroke-width .7 / opacity .5 over the fish.
- Plate caption (.plate-cap) as a baseline-aligned wrapping row: Arabic .loc 27px + transliteration .tr serif 19px/600 + '· Orange-spotted grouper' .en serif 15px ink2 on one baseline, with the italic .sci 'Epinephelus coioides — Serranidae' 13.5px ink3 on its own full-width line beneath. The app has no caption under the plate at all.
- Stamp detail line (.stamp-sub): serif 15.5px '38 cm measured · minimum 45 cm · total length' with mono 15px/600 numerals. The app's stamp sub-slot carries the margin instead (see misplaced).
- Stamp meta line (.stamp-meta): sans 10.5px, uppercase, .14em tracking, oxblood, 'Short by 7 cm · rule fails on size only'. VerdictStampDisplay has only headline + subLine — there is no third slot in _VerdictStamp.
- Rule table rows: 'Season — Open all year' and 'First offence — AED 3,000 + 6-month suspension'. ResultRuleFactsTable is fed display.findings.first.facts only (result_section.dart:98), so nothing outside the headline finding appears; the ARB carries only findingFactMeasured/Minimum/Maximum/Dates/Today/Recorded/Limit/Period — no penalty, no season-status fact.
- Italic annotation inside a table value (.rt td em, 13.5px ink2): 'total length (TL)', '+ 6-month suspension'. _FactLine renders one flat mono datum string with no secondary italic run.
- Measurement diagram block (.diag) entirely: the 1px-rule paper2 box, the .dl eyebrow 'HOW THIS SPECIES IS MEASURED' (sans 10.5px, .14em, uppercase, ink3, 600), the dimension-arrow SVG with the mono 9px .dimtxt 'TL — SNOUT TO TAIL TIP', and the .dd serif 13.5px prose 'Total length (TL): tip of the snout … Not fork length.' ResultMethodDiagram exists at ui/result/widgets/result_method_diagram.dart but is referenced by nothing — ResultSection never builds it.
- Second footnote: '² Penalty schedule: Art. 21, same instrument.' The app derives footnotes only from finding/note/ambiguity citations (_footnotes in result_section.dart).
- The .lnk affordance 'Read Article 3 in full →' — blue, underlined, sans 11.5px. The app's route to the verbatim article is an invisible InkWell wrapping the whole footnote (openKey), with no visible label, no colour, no arrow. On this screen the callback is a no-op: species_detail_screen.dart:296 passes onOpenRuleText: (int _) {}.
- Disclaimer chrome (.disc): the 15px info glyph, the paper3 ground, the 2px ink top rule and 1px rule bottom rule, and the bold lead-in 'Reference only — not legal advice.' set apart from the verify sentence. ResultDisclaimer is two undecorated Texts on the page ground.
- Bottom navigation (.nav, five destinations with Check selected). The species/result route is a full push with no LonjaNavStrip.
- Stale/expired bar on this screen — LonjaStaleBar is used only in species_search_screen.dart:67; neither SpeciesDetailScreen nor ResultSection mounts one (stale info survives only as footnote provenance text).

**Misplaced**

- ORDER: mockup is bar → plate → plate caption (names) → stamp → table → diagram → citations → disclaimer → 'Add to today' → nav. App is _SpeciesHeader (names) → _SpeciesArtPanel (plate) → _OtherNamesBlock → _MeasureSlot button → stamp → secondary findings → facts table → footnotes → disclaimer → 'Record this catch'. The names move from a caption UNDER the plate to a heading ABOVE it, and two blocks the mockup does not have are wedged between the plate and the stamp.
- Species name typography: mockup sets the local name inside the caption at 27px Arabic / 19px serif 600 beside a 15px English gloss; the app sets account.primaryName alone at type.display (serif 32px, w600, -0.16 tracking) with no sibling gloss, and adds a 'Family Serranidae' uiSmall line the mockup has no equivalent for.
- Binomial: mockup .sci is 13.5px italic serif in ink3 as the last line of the caption; the app uses type.binomial at 17px italic under the family line, above the plate.
- Stamp headline: mockup h3 is serif 26px/1.02, w700, UPPERCASE, letter-spacing .005em, short ('Below the minimum'), with the numbers demoted to the sub-line. The app prints ARB verdictBelowMinimum — 'Below the minimum — {measured} {unit} measured, minimum {threshold} {unit} ({method})' — as ONE sentence in type.verdict (serif 42px, w700, height 1.02, letterSpacing -0.84), sentence case, no text-transform, wrapping to two or three lines.
- Stamp sub-line role and size: the mockup's slot holds the measurement detail at serif 15.5px; the app puts the margin sentence ('Short of the minimum by 7 cm', ARB verdictMarginShortOfMinimum) there at type.measure — mono 36px, w600 — which is 2.3x the mockup's line and the wrong register (mono display numerals vs serif prose with mono numerals inline).
- Stamp glyph: mockup .stamp-ink .ic is 30px at stroke-width 1.7 with an 11px gap; the app uses LonjaIcon(size: LonjaIconSize.stamp) with an 8px (LonjaSpace.s2) end padding, and the glyph is top-aligned to a 42px headline rather than centre-aligned to a 26px one.
- Table header cells: mockup .rt th is sans 9.5px, .16em tracking, uppercase, ink3, width 44%, start-aligned; the app's label uses type.eyebrow (sans 14px, 1.68px tracking, w600) in an Expanded(flex 1) against Expanded(flex 2), i.e. a 33/67 split, and relies on ARB casing rather than a text-transform.
- Table values: mockup .rt td is serif 15px end-aligned with mono 14px only for the numeral run; the app sets the entire value in type.datum (mono 18px) — the words and the numbers share the monospace face.
- Table rules: mockup is a 1px SOLID ink rule above the first row and 1px DOTTED --rule between rows; the app emits a Material Divider(height: LonjaRules.rule) before every row — solid, uniform, and one above the first row only by accident of the loop.
- Citation footnote layout: mockup runs one continuous serif 12px paragraph — small-caps .who 'UNITED ARAB EMIRATES' inline, then '— Ministerial Decision 580/2015, Art. 3 · published … · checked …' — after a mono 9px superscript marker. The app stacks three separate lines (jurisdiction in type.eyebrow sans/tracked, instrument+article in type.citation mono 16px, dates in mono muted), so nothing is small-caps, nothing is serif, and the marker is a leading articleNumber cell rather than a superscript.
- Primary action: mockup .btn is a 1.5px ink-outlined 56px full-width button labelled 'Add to today' with a 20px plus glyph. The app renders LonjaButton.secondary with ARB catchRecord 'Record this catch' and no leading glyph.

**Extra**

- _OtherNamesBlock — a 'OTHER NAMES' LonjaSectionLabel, a list of every other-locale name, and a closing LonjaRule.row, between the plate and the verdict. The mockup folds the other names into the plate caption.
- _MeasureSlot — a full-width secondary button ('Measure', or the reading once taken) sitting directly above the stamp. The mockup's S2-fails has already been measured and shows no measure affordance on this screen.
- 'Family Serranidae' line in _SpeciesHeader (the mockup carries the family only inside the italic .sci string, 'Epinephelus coioides — Serranidae').
- speciesProtectedAnywhere statement line in _SpeciesHeader when the species is protected somewhere — no counterpart on the mockup's fails screen.
- ResultFindingsList of secondary findings between the stamp and the facts table (result_section.dart:114).
- A copy IconButton (ResultCitationFootnote.copyKey, a nested-squares _CopyMark) inside the footnote row, and a SelectableText source URL beneath it — neither appears in the mockup's .cite block.
- Loading/error affordances inline in the page: LonjaListSkeleton(rows: 2) in the verdict slot and a raw Text('$error') for a failed evaluation.

---

## S1 Check (home)

**In the app:** partial · **effort:** M

CheckScreen exists and covers roughly the top third of the mockup — a place line, a recents strip and a search field — but it drops the wordmark masthead, both chips, the two-up Browse/Identify row, the whole tally bar and the "On this device" pack note, and every element it does keep is rendered as plain stacked text rather than the ruled, bordered, tracked printed-page anatomy the CSS specifies.

**Missing**

- Wordmark masthead. .mast holds .wordmark "CatchLaw" — serif 19px, uppercase, letter-spacing .16em, weight 600 — with a block-level italic serif tagline <small>Is this legal?</small> at 10.5px in --ink3 underneath. The app's LonjaMasthead renders no product name and no tagline at all; nothing in lib/ui/ references appTitle.
- Dated mast-meta line. .mast-meta on the trailing side of .mast-row: mono 9.5px, uppercase, letter-spacing .12em, two lines "MON 27 JUL" / "2026". Absent — the app shows no current date anywhere on Check.
- The 2px ink rule that closes the masthead (.mast { border-bottom:2px solid var(--ink) }) sitting directly under the wordmark row. The app does emit a LonjaRule.section (2px) but under a different content block — see misplaced.
- Zone chip (.chip.zone). A tappable pill with a #i-pin glyph at 14px in --blue, bold place name, then " · Gulf, salt" (the water type) in --ink2, then a trailing chevron; --blue border with --blue-t tint fill, 38px min-height. The app has no chip, no pin glyph, no chevron, and never shows water type on Check.
- Rules-checked seal chip (.chip.seal). Second chip in the same .chips flex row: #i-seal glyph in --verdant, label "Rules checked" plus the date in bold, --rule border on --paper2. The app has the date but as bare citation-style text inside the masthead column, with no glyph, no border, and no "Rules checked" wording.
- Leading search glyph. .search .ic is a 22px #i-search in full --ink. LonjaSearchField has no prefix icon at all.
- The search field as a boxed entry. .search is a four-sided 1.5px solid --ink border on a --paper2 ground, min-height 60px, 12px inline padding, sitting flush at 16px margins. LonjaSearchField draws only a BorderDirectional bottom rule (ruleBearing at 1px, accent at 2px on focus) with a transparent ground — three of the four sides and the tinted fill are absent.
- Recents card anatomy. Each .rec is a 96×96 bordered tile on --paper2 stacking four things vertically: a 34px-tall engraved fish silhouette (<use href="#f-hamour">), the Arabic vernacular in the Naskh face at 15px, the transliteration in sans 10px/.04em in --ink2, and a mono 9px rule datum ("45 cm TL", "1 Mar–30 Apr"). The app's check/widgets/recents_strip.dart renders one centred Text(entry.displayName) at type.ui — no silhouette (LonjaSilhouette exists in lib/ui/core/ui/ but is not called here), no Arabic/transliteration pair, no rule datum, no tile border, no tile background.
- The two-up action row. .btn-row.two is a 1fr 1fr grid holding "Browse by shape" (#i-shape) and "Identify this fish" (#i-key) as .btn — 56px min-height, 1.5px solid --ink outline, sans 15px weight 600, letter-spacing .03em, 20px leading glyph. On Check these two buttons do not render: they exist only inside _SearchEmptyState in species_search_screen.dart, which is reached only after a query returns nothing — and CheckScreen passes them onIdentify: () {} and onBrowseByShape: () {}, so both are dead.
- The tally bar. .tally: 2px solid --ink top rule, 1px --rule bottom, 58px min-height, holding an eyebrow .k "Today · trip open 04:55" (sans 9.5px, .2em, uppercase, 600) over a serif 15px .v line "4 recorded · Hamour <mono>3</mono>" followed by a five-cell .pips row (8×12px boxes, filled ones on) and an italic <em>2 of 5 remaining</em>, with a trailing 16px chevron marking it tappable. Nothing on the Check screen surfaces the day's tally — dayTallyProvider is watched only by today_screen.dart.
- The pip meter itself (.pips i / .pips i.on) as a non-colour bag-limit signal. No equivalent widget exists anywhere in lib/ui/.
- "On this device" block. A second .lab-rule label followed by a .note paragraph: "Rule pack RAK-GULF v2026.2 · 3,180 entries · 48.2 MB. Nothing is fetched, nothing is sent, no account is held." Check renders no pack identity, no entry count, no size, and no offline statement — the nearest string, settingsOfflineNote, lives on Settings.
- Bottom nav ledger ground and cell divisions. .nav sits on --paper2 (sunk) with a 2px --ink top rule; each .ni carries a 1px --hair border-inline-end except the last. LonjaNavStrip paints tokens.surface with no per-cell hairlines.
- Selected-destination treatment. .ni.on gets a 3px --blue (#1B4D5E) rail via ::before, a lifted --paper ground, and --ink text. LonjaNavStrip's _NavCell gives the selected cell a top BorderSide of tokens.onSurface at LonjaRules.strong (2px, ink) and no ground change — the harbour rail and the lifted paper are both gone.

**Misplaced**

- Top-to-bottom order. Mockup: masthead(wordmark+date) → chips(zone, seal) → search → "Recently checked" label+rule → recents strip → two-up buttons → tally bar → "On this device" note → nav. App (check_screen.dart _Check): LonjaMasthead(place block) → RecentsStrip(label+rule+strip) → SpeciesSearchScreen(stale bar, "Species" eyebrow, search field, result count, results) → nav. The search field is BELOW the recents strip in the app and ABOVE it in the mockup, and everything from the button row down is absent.
- The place is rendered where the wordmark belongs. LonjaMasthead's first row is Column[eyebrow "Answering for", type.subtitle place, type.citation "checked <date>"] + a trailing "Change place" TextButton — i.e. the zone chip's content has been promoted into the masthead slot the mockup reserves for the product name, and the mockup's own masthead content has nowhere to go.
- The place value is a raw zone code. LonjaMasthead is passed place.zoneCode; the mockup prints a display name plus water type — "Ras Al Khaimah · Gulf, salt".
- Checked-date wording and weight. Mockup: "Rules checked <b>2026-07-14</b>" — the date in weight 600 --ink inside a bordered chip with a verdant seal glyph. App: l10n.checkPackChecked → "checked 2026-07-14", one flat run at type.citation in onSurfaceMuted, no emphasis split.
- Section label case and tracking. .lab is uppercase via text-transform with letter-spacing .2em at 9.5px. LonjaSectionLabel uses type.microLabel (12.5px, letterSpacing 2) and deliberately does not case-transform (banned by check_lonja_type.sh check 6), so "Recent here" reads sentence-case where the mockup reads "RECENTLY CHECKED".
- Section label wording. Mockup "Recently checked"; app checkRecentsLabel "Recent here".
- Recents strip geometry. Mockup tiles are a fixed 96px wide and ≥96px tall with 10px gaps. The app sizes the row to tokens.density.rowHeight (56 regular / 72 glove) and constrains each item only to minWidth: tokens.density.tapMin (48/56) with an end gap of LonjaSpace.s2 — roughly half the mockup's tile in both axes, and too short for the four stacked lines the mockup carries.
- Nav label type. .ni span is sans 9px, uppercase, letter-spacing .11em, weight 600. _NavCell uses type.microLabel (12.5px, letterSpacing 2) with no casing — noticeably larger and mixed-case.
- Nav cell height. .ni is min-height 62px; _NavCell floors at tokens.density.tapMin (48 regular).
- Section-rule placement. The mockup's .lab-rule hairline is 1px --rule beside the label; the app pairs LonjaSectionLabel's LonjaRule.block (1px) correctly, but LonjaMasthead closes with LonjaRule.section (2px hairlineStrong) under the place block, where the mockup's 2px ink rule belongs under the wordmark row instead.

**Extra**

- "Change place" TextButton in the masthead (l10n.checkChangePlace). The mockup carries no such button — changing zone is the .chip.zone itself, marked by its trailing chevron.
- A persistent "Species" field label above the search box (l10n.speciesSearchLabel at type.eyebrow, from species_search_screen.dart). The mockup's search has no label — the italic placeholder carries it.
- Different placeholder copy. App: "hamour, mero, Epinephelus". Mockup: "Search species — هامور, Hamour, grouper" (leads with the verb and shows the Arabic script first).
- A result-count line under the field — l10n.speciesSearchResultCount(n, jurisdictionCount) at type.datum. No such counter on the mockup's S1.
- LonjaStaleBar rendered at the top of the Check body when the pack is expired. The mockup shows the .amber bar only on S2 result screens; on S1 the currency of the data is carried by the .chip.seal (with .chip.stale as its expired variant, an inline chip rather than a full-width bar).
- A first-launch CheckEmptyState block ("Nothing checked here yet" + body) standing where the strip would be. The mockup authors no empty state for S1.
- Nested Scaffold + SafeArea: SpeciesSearchScreen is a full Scaffold embedded inside CheckScreen's Scaffold body, so Check pays for two scaffolds and two SafeAreas.
- A search results region (two sliver groups "In your zone" / "Elsewhere in this jurisdiction") occupying the Expanded below the field. This is S5's surface; on the mockup S1 that vertical space holds the button row, the tally bar and the device note.

---

## S14 Settings

**In the app:** partial · **effort:** M

The screen exists at /Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/settings/widgets/settings_screen.dart and covers roughly half the mockup's controls, but it is built as a stacked label-then-control form (section label, full-width segmented block, spacer, repeat) instead of the mockup's ledger of full-bleed 58px `.set-row` lines — key + subline on the start side, value/chevron/toggle on the end side, dotted hairline between — and it has no masthead, no group headings, and no Zone, coordinate-capture, storage, export, import or about rows.

**Missing**

- The `.mast` masthead entirely: the serif 19px uppercase .16em-tracked `.wordmark` "Settings", its italic serif 10.5px `<small>` subline "No account · nothing to sign in to", the end-aligned mono 9.5px uppercase `.mast-meta` "CATCHLAW / 3.2.0" version block, and the 2px solid ink bottom border. The app prints a bare `Text(l10n.navSettings, style: type.title)` inside the scroll view; `LonjaMasthead` exists (ui/core/ui/lonja_masthead.dart) but is only used by check_screen.dart.
- All four `.lab-rule.tight` group headings — "Language and figures", "Where you fish", "Reading conditions", "This device". The app's `LonjaSectionLabel`s name individual controls ("Language", "Digits", "Length shown in", "Ruler") instead of grouping them, and the two switches sit under no heading at all.
- The `.set-row` anatomy itself: a 58px min-height full-bleed row with `.k` (serif 15.5px) over `.sub` (sans 11px ink3) on the start side and a `.v` (mono 12px ink2) / chevron / control flushed to the end. No widget in app/lib/ui/core/ui implements this; the app stacks label above control in a Column.
- The 1px dotted `--rule` divider under every row (`border-bottom:1px dotted var(--rule)`), including the `border-bottom:0` on the final "About and licences" row.
- Every `.sub` explanatory line: "6 held · العربية · English · Galego · Español · Português (BR) · اردو" under Language, "Western or Arabic-Indic digits" under Numerals, "Lengths and weights" under Units, "Rules, species list and limits follow this" under Zone, "Calibrated with a card on 2026-07-02" under Ruler calibration. Only the two switches carry notes in the app (settingsSunlightNote / settingsGloveNote).
- The Zone row — key "Zone", value "Ras Al Khaimah" + `.chev`. The app has ZonePickerScreen (ui/zones/zone_picker_screen.dart) but Settings does not link to it; only check_screen's masthead does.
- The calibration VALUE `162.4 px / 10 mm` in mono `.v` with the `/ 10 mm` denominator in --ink3. The app prints only "Not calibrated" / "Calibrated {on}" as a `type.datum` line with no px-per-mm figure.
- The "Coordinate capture" row with its `.sw2` toggle (off) and the subline "Stored on this device only · never transmitted".
- The "Storage used" row with the mono value "48.2 MB" and subline "Rule packs, plates and your trips".
- The "Export" row (sub "Trips and checks as CSV") with the 19px `#i-export` glyph flushed end.
- The "Import a rule pack" row (sub "From a file someone hands you · .catchlaw") with the `#i-import` glyph.
- The "About and licences" row (sub "Sources, plate credits, version history") with a 15px chevron. There is no about/licences screen anywhere under app/lib/ui.
- The end-flushed chevron affordance (`.ic.chev`) on every navigating row — Language, Zone, About. The app has no chevrons on this screen.
- The `.hr` hairline above the closing note inside a 16px/22px padded block — the app uses `LonjaRule.row()` and a s3 gap.

**Misplaced**

- Top-to-bottom ORDER. Mockup: masthead → Language and figures (Language, Numerals, Units) → Where you fish (Zone, Ruler calibration, Coordinate capture) → Reading conditions (Sunlight, Glove) → This device (Storage, Export, Import, About) → hairline + offline note. App: title → Language (list) → Digits → Length shown in → Sunlight → Glove → Ruler → rule + offline note. The ruler moves from third-from-top in the mockup's second group to second-from-bottom in the app, landing AFTER the two reading-mode switches instead of before them.
- The screen title. Mockup `.wordmark` is 19px serif, `text-transform:uppercase`, `letter-spacing:.16em`, w600, with a subline and an end-aligned version block on the same baseline row. App uses `type.title` — serif 26px, `letterSpacing: 0`, sentence case, alone on its line.
- Language is a single row in the mockup (key + `.v` "English" + chevron, opening a picker) and a seven-item in-page list in the app (`_LanguageChoice`: Follow the device, English, Español, Galego, Català, Português, العربية), each a `tapMin`-height Row with an em-dash marker column. That converts one 58px row into ~7 rows of vertical space and pushes everything below it down.
- Numerals: the mockup `.seg` is a TWO-cell inline control ("0–9" / "٠–٩"), 1.5px ink border, mono 12px, `margin-inline-start:auto` so it hangs at the end of the row. The app renders `LonjaSegmented<NumeralSystem>` as a full-width three-cell block (Automatic / 0123 / ٠١٢٣) on its own line under a section label, each cell `Expanded`.
- Units: mockup `.seg` is two cells, "cm / mm" as one cell and "in" as the other. App renders three equal cells cm | mm | in, again full-width on its own line rather than end-flushed inside a row.
- The toggles. Mockup `.sw2` is a 46×26 square-cornered track with an 18×18 thumb that slides start→end and turns `--blue` when on. The app's `LonjaSwitch._MarkBox` is a ~20dp square check box (LonjaSpace.s5) that fills with `tokens.onSurface` and draws a tick — a checkbox, not a track. The app also bolds the label to w700 when on; the mockup keeps the `.k` weight constant.
- Section-label type. Mockup `.lab` is sans 9.5px, uppercase, `.2em` tracking, w600, --ink3, followed by a 1px `--rule` hairline. App `LonjaSectionLabel` uses `type.microLabel` — sans 12.5px, letterSpacing 2 logical px, w600 — with `LonjaRule.block()`; larger and un-cased (casing is deliberately banned by check_lonja_type.sh check 6, so this is a known divergence, not an oversight).
- Horizontal bleed. Mockup rows run edge to edge with `padding-inline:var(--s5)` and their dividers touching both margins; the app wraps everything in `SingleChildScrollView(padding: EdgeInsetsDirectional.all(tokens.density.gutter))`, so no rule or divider can reach the screen edge.
- The closing offline note is in the right position (last) but is a different sentence and a different role: mockup `.note` is sans 11.5px/1.5 --ink3, "CatchLaw has no account, no sign-in and no server. It has never made a network request and does not contain the code to make one."; app uses `type.legalSmall` (serif) with `settingsOfflineNote` = "CatchLaw holds everything it needs on this phone. It has no account and no network code."

**Extra**

- `_LanguageChoice`'s "Follow the device" option and its em-dash selection marker column — the mockup shows a resolved value ("English") on one row, with no device-default entry visible.
- A "Català" locale in `_LanguageChoice._names`; the mockup's Language subline lists six held languages as العربية · English · Galego · Español · Português (BR) · اردو (no Catalan, and it names Urdu — worth checking against D-3, which governs the shipped locale set).
- A third "Automatic" cell in the Digits segmented control; the mockup's `.seg` has only the two digit systems.
- A separate "mm" cell in the Units control; the mockup pairs cm and mm in one cell.
- `LonjaButton.secondary(label: l10n.calibrateAction)` pushing `CalibrationScreen` — a full primary-ladder button. The mockup exposes calibration only as a tappable `.set-row` showing the current px value.
- The `profile.when` loading branch (bare `Text(l10n.navSettings, style: type.title)`) and error branch (raw `'$e'` in `type.legal`) — no equivalent states in the mockup.

---

## S3 — Ruler (measure the fish on the glass)

**In the app:** partial · **effort:** M

The app has a ruler screen at /Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/ruler/widgets/measure_screen.dart, but it is a different screen: a drag-cursor ruler stretched to fill the page plus a full numeric keypad, where the mockup is a fixed full-bleed tick band with a calibration provenance line, a fork-length method diagram, a mono 44px step-and-mark running total with step pips, and manual entry demoted to a single "Type instead" ghost button.

**Missing**

- The full-bleed .rulerbox band itself: paper2 ground, 2px solid ink bottom rule, 6px bottom padding, and the tick band running edge-to-edge so the zero mark sits ON the physical screen edge. In the app RulerView is wrapped in Padding(EdgeInsetsDirectional.all(tokens.density.gutter)) inside measure_screen.dart, so zero is inset by a full gutter — which contradicts the mockup's own instruction 'Lay the screen edge at the snout'.
- The calibration provenance line under the ruler: .note 'Calibrated 2026-07-02 · <span class="mono">162.4 px per 10 mm</span>'. No such string exists in app_en.arb for this screen; the only calibrated-on string is settingsRulerCalibrated, on Settings.
- The whole .diag measurement-method block: 1px rule border on paper2, an eyebrow .dl (sans 10.5px, uppercase, .14em tracking, ink3, 600) reading 'Measurement method — fork length', an 86px fish SVG with a .dim dimension line and .dimtxt mono 9px caption 'FL — SNOUT TO FORK OF TAIL', and a .dd serif 13.5px ink2 paragraph 'Kanaad is measured to the fork of the tail, not the tip. Measuring to the tip will read roughly 4 cm long.' ResultMethodDiagram exists but lives in ui/result/widgets/ and carries neither the dimension caption nor the .dd prose.
- The 'Step and mark' .lab-rule eyebrow (sans 9.5px, uppercase, .2em tracking, 600, followed by a 1px hairline filling the line).
- The .readout row: .big mono 44px/line-height 1 running total '42.0', .u serif 17px 'cm so far' baseline-aligned beside it, and a trailing .pill bl mono uppercase 'STEP 3 OF 5' pushed to the end.
- The .steps progress row: five 7px-high boxes, 1px ink2 border, first three filled ink.
- The step instructions note: 'Lay the screen edge at the snout, mark, slide the phone along the fish and mark again. Each step adds 8.0 cm. Minimum for Kanaad is 65 cm FL.' — including the per-species minimum stated with its method (65 cm FL).
- The primary 'Step and mark' button (.btn pri, blue field, ruler glyph, min-height 64px). RulerViewModel.mark(), .undo(), .cancel() and .accept() all exist in ruler_viewmodel.dart and NO widget in ui/ calls any of them — the whole step-and-mark interaction is unrouted.
- The 'Type instead' ghost button (.btn ghost with the i-abc glyph).
- The 'Re-calibrate with a card' ghost button (.btn ghost sm, 46px, i-card glyph). The app offers CalibrationScreen only in the calibration == null branch; once calibrated there is no re-calibrate affordance anywhere on the screen.
- Icons on every button — i-ruler, i-abc, i-card at 20px. The three LonjaButton calls in measure_screen.dart pass label only.
- The closing privacy note: 'Fish on the board, phone on the fish. No photograph is taken and no coordinate is read unless coordinate capture is switched on in Settings.'
- The species name in the app-bar title: mockup reads 'Measure — Kanaad'; the app renders l10n.measureTitle = 'Measure' with no subject.
- The app bar's trailing .sup meta (mono 9.5px, uppercase, .1em tracking, ink3) reading 'Ruler'.
- The bottom .nav strip with the five destinations and Check active. MeasureScreen is pushed as a bare MaterialPageRoute with its own Scaffold, so LonjaNavStrip/AppShell chrome is gone entirely.

**Misplaced**

- Ruler size and vertical behaviour: the mockup band is a fixed 34px tick strip plus a 10px numeral row, docked immediately under the app bar. The app puts RulerView inside an Expanded (measure_screen.dart line 89), so a 64px-tall CustomPaint is top-anchored in a region that swallows all remaining vertical space, leaving a large blank field between the ruler and the section rule.
- Tick geometry is shorter and lighter than the mockup: RulerPainter._buildTicks uses 22 / 14 / 8 logical px for cm / 5mm / mm; the mockup .ticks gradients are 30 / 18 / 10px. The mockup also draws the cm tick at 1.6px against 1px for the others, where the painter strokes all three classes with the same _tick paint at hairline (1/devicePixelRatio) width, so the cm ticks do not read as heavier.
- Centimetre numerals are in the wrong place and the wrong role: RulerPainter.paint lays them inside the canvas at y=24 in type.articleNumber. The mockup puts them in a separate .rnums grid row BELOW the tick band — 8 columns of exactly 48px, mono 10px, ink2, 3px inline-start padding.
- The primary action is inverted. The mockup's one primary is 'Step and mark' at the head of the .btn-row (64px, blue); the app's LonjaButton.primary is 'Use this length' (l10n.measureUse) sitting last in the Column, and 'Step and mark' has no button at all.
- Manual entry has the wrong weight and the wrong position. The mockup gives it one ghost button, 'Type instead', in the button row. The app gives it the entire lower half of the screen — 'Or type the length' label, a live '{mm} millimetres' readout in type.measure, and an 11-key _Keypad — placed directly beneath the ruler where the mockup has the method diagram.
- The section divider is the wrong element: measure_screen.dart uses a bare full-width LonjaRule.section() (strong weight). The mockup's equivalent is .lab-rule — a tracked uppercase eyebrow word followed by a 1px hairline occupying only the remainder of the line.
- The app bar is plain Material AppBar(title: Text(...)) rather than the mockup's .bar: paper ground, 1px hairline bottom rule, a 44px .iconbtn back target with -10px inline-start margin, and a serif 18px/600 .01em title.
- The readout typography is wrong even where a number is shown: the app prints the typed length through l10n.measureManualReading ('{mm} millimetres') in type.measure; the mockup's number is mono 44px at line-height 1 and -.02em tracking with a separate serif 17px unit phrase beside it.

**Extra**

- _Keypad in measure_screen.dart — digits 1-9 and 0 as 64dp-wide LonjaButton.secondary tiles plus a 96dp 'Back' backspace, laid out in a Wrap. The mockup's S3 has no keypad on screen at all.
- The 'Or type the length' label (l10n.measureManualLabel) and the live '{mm} millimetres' echo of the typed digits.
- The 'Use this length' primary button (l10n.measureUse), disabled at zero.
- The whole uncalibrated branch that REPLACES the ruler: 'This screen is not calibrated' headline, the measureUncalibratedBody paragraph and a secondary 'Calibrate' button. The mockup always shows a live ruler and treats calibration as a small trailing ghost button.
- A horizontal-drag cursor: GestureDetector(onHorizontalDragUpdate) driving RulerViewModel.dragTo, painted by RulerPainter as a full-height accent line at LonjaRules.strong. The mockup's instrument is step-and-mark against the screen edge and has no draggable cursor.

---

## S5 — Species search (Arabic, RTL)

**In the app:** partial · **effort:** M
· **files:** `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/species/widgets/species_search_screen.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/core/ui/lonja_species_line.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/core/ui/lonja_search_field.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/check/check_screen.dart`

The app has a real species-search screen (`/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/species/widgets/species_search_screen.dart`, embedded in `check_screen.dart`) with a working field and result rows, but it renders roughly a third of the mockup: it is missing the `.bar` app bar, both `.chip`s, the fish silhouette, the pill, the chevron, the per-row rule line, and the three lower blocks (other names, similar in shape, citation footnote), and it replaces the mockup's "one matching result" label with two invented group headings.

**Missing**

- `.bar` app bar entirely: back `.iconbtn` (44x44, 22px chevron, mirrored by `[dir=rtl] .chev{transform:scaleX(-1)}`), serif 18px/600 screen title "بحث عن نوع", and the trailing `.sup` — mono 9.5px, uppercase, .1em tracking, ink3 — carrying the zone name. The app shows `LonjaMasthead` instead (eyebrow + place + checked-on + a "Change place" TextButton), which is a different component with a different job.
- `.chips` row under the bar: the tappable `.chip.zone` (blue 1px border, blue-tint fill, 14px pin glyph, bold zone name + " · الخليج، مياه مالحة" water type, trailing chevron) and the `.chip.seal` (verdant seal glyph, "تم التحقق" + mono date). Neither exists as a bordered 38px-min chip anywhere on this screen.
- Leading 22px search glyph inside the field (`.search .ic`) — `LonjaSearchField` has no prefix icon.
- Trailing clear/X affordance (`#i-x` at 18px, `margin-inline-start:auto`) — no clear button in `LonjaSearchField`.
- The four-sided field frame: `.search` is `border:1.5px solid var(--ink)` on all sides over `--paper2`, min-height 60px. `LonjaSearchField` draws only a `BorderDirectional(bottom:)` hairline and no fill.
- `.lab-rule` construction itself — an eyebrow label followed by a 1px `--rule` hairline that fills the remaining width (`.lab-rule::after{flex:1;height:1px}`). The app prints bare `Text` headings with a full-width `LonjaRule.section()` beneath, never label-then-inline-rule.
- The fish silhouette in each row (`.row .fish`, 52x30, stroke 1.6, ink). `LonjaSpeciesLine` accepts an `art` slot but `_ResultGroup` never passes one — `LonjaSilhouette` is only used in `species_browse_screen.dart` and `species_detail_screen.dart`.
- The row detail line `.row .d` — sans 11.5px ink2, e.g. "الحد الأدنى ٤٥ سم — الطول الكلي" / "موسم إغلاق ١ أبريل – ١ يونيو", with the figure in mono `<b class="mono">`. `LonjaSpeciesLine` renders name + binomial only; no third line, and `MinimumSizeHint` is deliberately dropped to null in `_hintWord`.
- The trailing `.row .chev` (15px, ink3, mirrored under RTL) on every row.
- The highlighted best-match state `.row.hl` — `--paper2` ground plus a 3px `--blue` inline-start rail. No highlight variant exists on `LonjaSpeciesLine`.
- The "أسماء أخرى لهذا النوع" block: `.lab-rule` plus a `.note` paragraph of vernaculars separated by ` · ` with each Latin name in its own `dir="ltr"` span. The app has an `_OtherNamesBlock`, but it lives in `species_detail_screen.dart` (S2), not on the search screen.
- The "أنواع مشابهة في الشكل · ٤" block: a counted label plus four full `.row`s with silhouette, name, binomial, rule line and pill. `look_alike_card.dart` exists but is not on this screen.
- The `.cite` footnote at the bottom of the screen: a 44%-width 1px ink `.fnrule`, then serif 12px ink2 citation "قرار وزاري رقم ٥٨٠/٢٠١٥، المادة ٣ · نُشر في ٢٠١٥-١١-٠٣ · روجع في ٢٠٢٦-٠٧-١٤.", then a second paragraph disclaimer "للاسترشاد فقط — ليست استشارة قانونية. تحقق من وزارة التغير المناخي والبيئة." Nothing on the search screen carries a citation or disclaimer.
- The verdict `.pill` as a bordered stamp — mono 9px, uppercase, .12em tracking, `1px solid currentColor`, padding 2px 5px, coloured verdant (`مفتوح`) or ochre (`إغلاق`). The app prints the hint as unboxed text.
- Arabic-Indic numerals throughout (٤٥ سم, ٢٠٢٦-٠٧-١٤, ٥٨٠/٢٠١٥). `numeral_system.dart` notes CLDR gives `ar` a `latn` default, so this only appears if the user has switched the setting; the mockup treats it as the Arabic default.

**Misplaced**

- Top-to-bottom order. Mockup: bar → chips → search → "one matching result" label-rule → highlighted row → other names → similar in shape → citation footnote. App (via `check_screen.dart` > `_Check`): masthead → recents strip / empty state → [stale bar] → "Species" eyebrow → search field → result count → "In your zone" heading + rule + rows → "Elsewhere in this jurisdiction" heading + rule + rows. Everything after the field diverges.
- The result count. Mockup sets it as a `.lab` eyebrow sentence — sans 9.5px, .2em tracking, uppercase, ink3, w600 — reading "نتيجة واحدة مطابقة", inline with a hairline. The app prints `l10n.speciesSearchResultCount` in `type.datum`: mono 18px, tabular figures, "١ من ٣١". Wrong family, roughly double the size, wrong case/tracking, and a bare ratio instead of a sentence.
- Result-group headings. The mockup has none; the app splits results under `speciesGroupInYourZone` / `speciesGroupElsewhere` in `type.eyebrow` (sans 14px, 1.68px tracking) over a `LonjaRule.section()` (2px strong). The mockup's only heading above the results is the match count.
- The species name in a row. Mockup `.row .n` is the Arabic face at 19px/1.25 regular weight; the app uses `type.subtitle` — serif 22px, w600. Bigger, bolder, and serif rather than the Arabic stack.
- The binomial. Mockup `.row .s` is serif italic 12.5px ink3; app `type.binomial` is serif italic 17px. Roughly 36% too large relative to the name.
- Row dividers. Mockup: `.rows{border-top:1px solid var(--ink)}` above the group and `1px dotted var(--rule)` between rows. App: a solid 2px `LonjaRule.section()` above the group and a solid `LonjaRule.row()` (`LonjaRules.hair`, hairline tone) below each row — solid where the mockup is dotted.
- The one-word hint's position and rendering. Mockup puts a bordered pill in `.row .end` and then a chevron outboard of it; the app puts unboxed `type.datum` (mono 18px) as the last child of the Row with no chevron after it, so the trailing edge reads as text rather than a stamp.
- Field text size. `.search .val` is serif 19px, and `LonjaSearchField` uses `type.legal` (serif 19px) — matching — but the field's minimum height is `tokens.density.tapMin` rather than the mockup's fixed 60px, and the hint is a Material `hintText` that vanishes on input where the mockup keeps `.lab`-style meaning outside the field.

**Extra**

- `LonjaMasthead` (`app/lib/ui/core/ui/lonja_masthead.dart`): place-label eyebrow, place name, "checked on" citation line and a "Change place" `TextButton` above a section rule — S5 in the mockup carries none of this; the place appears only as the bar's `.sup` and the zone chip.
- `RecentsStrip` / `CheckEmptyState` between the masthead and the search field (`check_screen.dart` lines 85–92). The mockup shows recents on S1, not on S5.
- `LonjaStaleBar` conditionally above everything when `state.isPackExpired`. The S5 mockup has no `.amber` / stale bar (it uses the verdant `.chip.seal` instead).
- A standalone "الأنواع" eyebrow label above the field (`l10n.speciesSearchLabel`, `type.eyebrow`). The mockup has no label over `.search`.
- The empty-state block `_SearchEmptyState` with `LonjaEmptyState` + two `LonjaButton`s (identify / browse by shape). Not part of the S5 mockup, which shows the populated state only.

---

## S8 Today

**In the app:** partial · **effort:** M
· **files:** `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/log/widgets/today_screen.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/log/view_models/catch_log_providers.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/core/ui/app_shell.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/core/ui/lonja_masthead.dart`

The Today branch exists and reads the right data, but it renders a bare heading + ISO date + a vertical list of binomials with two buttons per row — none of the mockup's masthead, summary table, section labels, silhouette rows, tally pips, action pair or citation footnote is present, so the screen matches the mockup in name only.

**Missing**

- The `header.mast` masthead entirely. TodayScreen is a bare Scaffold body with no app bar; AppShell supplies only the bottom LonjaNavStrip. The mockup's mast carries a 2px solid ink bottom rule, a `.wordmark` and a `.mast-meta`, and LonjaMasthead exists in the codebase but is used only by CheckScreen.
- `.wordmark small` — the italic serif 10.5px sub-line under the title: 'Trip open since 04:55'. There is no trip state on this screen at all, although `openTripProvider` already exists in catch_log_providers.dart.
- `.mast-meta` — the end-aligned two-line mono 9.5px uppercase, .12em-tracked block 'MON 27 JUL' / 'RAS AL KHAIMAH'. The app prints no zone/place name anywhere on Today.
- The whole `table.rt` trip summary block: three rows, `th` sans 9.5px uppercase .16em at 44% width / `td` end-aligned serif 15px with mono figures — 'Fish recorded 7', 'Vessel limit 41 kg of 60 kg', 'Gear Hand-line · 4 gargoor'. It has a 1px solid ink top rule and dotted `--rule` row dividers. Nothing in the app aggregates or displays a day total, a vessel-limit fraction or gear.
- Both `.lab-rule` section labels — 'Against the bag limits' and 'Not counted toward a limit' — sans 9.5px uppercase .2em with the hairline that runs from the label to the edge (`::after`). LonjaSectionLabel exists but is never called from today_screen.dart.
- The `.rows` container's 1px solid ink top rule and the per-row `1px dotted var(--rule)` bottom border. The app uses `LonjaRule.row()` as a separator between items only, with no ink rule opening the block.
- The 52x30 `.fish` silhouette leading every row (`#f-hamour`, `#f-zubaidi`, `#f-kanaad`, `#f-saw`). LonjaSilhouette exists and is used in species_browse/species_detail, never here.
- The local common name plus inline Arabic — `.n.lat` serif 16px w600 'Hamour' with a 16px `.ar` 'هامور'. The app row shows only `entry.scientificName`.
- The `.d` rule line under the name — sans 11.5px 'Limit 5 per person · min 45 cm TL', 'No number limit · min 65 cm FL', 'Bycatch note · 06:20 · gargoor 3'. The app prints no limit, no minimum size and no method on this screen.
- The `.pips` tally — five 8x12px bordered boxes, `.on` filled with ink, sitting in the row's `.end` column. This is the non-colour redundancy the caption calls out and it does not exist in the app.
- The end-column mono 12px remaining figure — '2 of 5 remaining', '8 of 10 remaining' — and its variant for an unlimited species: '2 recorded' over a muted mono '14.2 kg'. The app has no weight anywhere.
- The `.pill.ox` PROTECTED chip — mono 9px, uppercase, .12em tracked, 1px oxblood box — on the fourth row. No status chip on any app row.
- The `.note` paragraph under 'Not counted toward a limit': sans 11.5px prose about the 38 cm Hamour checked at 05:42 and recorded below the minimum. The app has no below-minimum/not-counted section.
- The bottom `.btn-row`: `.btn.dark` primary 'Record another' (solid ink field, paper text, 56px min-height, square, 20px plus icon) and `.btn` outline 'End trip' with a clock icon. The app offers no screen-level action and no primary at all.
- The `.cite` footnote block — a 44%-width 1px ink `.fnrule` above serif 12px text with a mono `sup` 1: 'Bag and vessel limits — Ministerial Decision 580/2015, Art. 3 · published 2015-11-03 · checked 2026-07-14.'
- Edge-to-edge row layout. The mockup pads prose in `.pad` (padding-inline only) and lets `.rows` and the rules span the full width; the app wraps the whole screen in one `EdgeInsetsDirectional.all(tokens.density.gutter)` so nothing can bleed to the edge.

**Misplaced**

- The title. Mockup `.wordmark` is serif 19px, w600, uppercase, letter-spacing .16em, sitting inside the mast above a 2px ink rule. App uses `Text(l10n.todayHeadline, style: type.title)` — serif 26px, w600, letterSpacing 0, sentence case 'Today' — as a free-floating first child of a padded Column.
- The date. Mockup puts it end-aligned in the mast as tracked uppercase mono 9.5px over a second line naming the zone. App puts `todayIsoProvider` ('2026-08-05') immediately under the title, start-aligned, in `type.datum` — mono 18px muted — i.e. wrong position, roughly double the size, numeric ISO instead of 'MON 27 JUL', and no zone line.
- Row anatomy. Mockup `.row` is one horizontal 64px-min tappable button: silhouette | `.m` name+detail block | `.end` figures, gap `--s4`. App `_TallyLine` is a vertical `Column(crossAxisAlignment: start)` — name, then count line, then a button Row — inside a `ConstrainedBox(minHeight: tokens.density.rowHeight)`. Nothing is end-aligned and the row is not a tap target.
- The species name. Both show a name, but the app shows the binomial (`type.binomial`, serif 17px w400) where the mockup shows the local name in serif 16px w600 with Arabic inline; the mockup carries no binomial on S8 at all.
- The count. Present in both but in the wrong place, form and wording: app renders `todayCountKept` = '{count} recorded · {kept} kept' in mono `type.datum` at the start of the row, below the name; the mockup splits it into the left rule line (the limit) and the right end column (pips + 'N of M remaining').
- The actions. Mockup has zero per-row controls and a single screen-level pair at the bottom, with 'Record another' as the one primary. The app puts two `LonjaButton.secondary` ('Kept', 'Remove one') inside every tally row as full-width `Expanded` children, so the visual weight of the list is buttons rather than figures, and the screen has no primary action.

**Extra**

- Per-row `LonjaButton.secondary` pair 'Kept' / 'Remove one' (`l10n.todayMarkKept`, `l10n.todayUndoOne`) wired to `markOneKept` / `removeLatest` — no equivalent affordance in the mockup.
- The scientific binomial as the row's primary line — the mockup's S8 rows are keyed on the local/Arabic name.
- An ISO numeric date string ('2026-08-05') as a standalone second line.
- A two-variant empty state `_TodayEmptyState` — `todayNothingRecorded` vs `todayNoPlace` in `type.subtitle` (serif 22px) plus a `type.legal` body. The mockup's S8 has no empty state.
- A raw error branch rendering `Text('$error', style: type.legal)` — an unstyled exception string on the screen.

---

## Sunlight mode — the S2 species/result screen (below-minimum verdict for Hamour) rendered in the third theme

**In the app:** partial · **effort:** M

The screen exists (SpeciesDetailScreen + ResultSection) and the sunlight palette and the stamp's reverse-out are genuinely implemented, but the page is assembled in a different order and the stamp itself is wrong: the mockup's short uppercase tracked headline plus separate serif detail line is one 42px wrapping sentence in the app, the plate has neither frame, PL. number nor caption, and the measurement diagram, the Shortfall/Season rows and the primary "Add to today" action are absent.

**Missing**

- The `.bar` app bar entirely — SpeciesDetailScreen is `Scaffold(body: SafeArea(...))` with no `appBar`. Mockup has a 44px back `.iconbtn` (chevron, mirrored under RTL), a serif 18px/600 title carrying the fish's local name ("Hamour"), and a mono 9.5px 0.1em uppercase `.sup` theme tag ("SUNLIGHT") pushed to the end with `margin-inline-start:auto`.
- The engraved plate frame: `.plate-frame` is a bordered box (2px in sunlight) with a second inset 1px frame drawn by `.plate-frame::after{inset:3px}`. The app's `LonjaPlateSurface` draws only a `BorderDirectional(top:)` hairlineStrong rule over a `surfaceSunk` fill — and in sunlight `surfaceSunk == surface == white100`, so the panel is a bare top rule with no frame at all.
- `.plate-no` — the mono, letterspaced, uppercase plate number "PL. XVII" positioned inside the frame. Nothing in `lonja_plate.dart` or `lonja_silhouette.dart` emits it.
- `.plate-cap` — the caption block *under* the art: `.loc` Arabic 27px هامور, `.tr` serif 19px/600 "Hamour", then `.sci` italic 13.5px muted "Epinephelus coioides" on its own full-width line. The app has no caption; the names live in `_SpeciesHeader` above the plate instead.
- The `.diag` measurement-method box: 2px-bordered panel, `.dl` sans 10.5px 0.14em uppercase label "MEASURED AS", the fish drawing with a `.dim` 2px dimension line and end ticks, and the mono 11px `.dimtxt` caption "TL — SNOUT TO TAIL TIP". `ResultMethodDiagram` exists at ui/result/widgets/result_method_diagram.dart but is imported by nothing except its own test — `ResultSection.build` never composes it, so it never reaches the screen.
- Two of the four `.rt` rows: "Shortfall — 7.0 cm" and "Season — Open". `VerdictPresenter._sizeFacts` emits only Measured and Minimum; the shortfall is diverted into the stamp sub-line and there is no season row on a size finding at all.
- The primary action `.btn.pri` "Add to today" — a plus glyph plus label, black ground / white text, 2.5px border, 16px in sunlight, in a `.btn-row` with `padding-block:16px 20px`. The app's terminal action is `LonjaButton.secondary(label: l10n.catchRecord)` = an outlined "Record this catch" with no icon.
- The disclaimer's construction: `.disc` is a bounded block — `border-top:3px solid #000` in sunlight, white ground, 10px/11px inset padding, a 15px info glyph in a flex row, a bold lead clause "Reference only — not legal advice." then the verify sentence. `ResultDisclaimer` is two bare `Text` widgets with no icon, no rule, no ground and no bolded lead.
- The citation footnote's sunlight-doubled rule: `.phone.sun .cite .fnrule{height:2px}` over the 44%-wide rule. The app's `footnoteRuleKey` box is fixed at `LonjaRules.rule` (1px) in `tokens.hairline`.
- The `.sb` status strip with the bordered uppercase "No signal" chip (mono 10.5px time, battery glyph, 78%) and its 2px bottom rule in sunlight — mockup device chrome, but it is the only place the offline claim is stated on this screen.

**Misplaced**

- ORDER, top to bottom. Mockup: bar → plate (art + caption) → stamp → rule table → method diagram → citation → disclaimer → primary button → nav. App (`SpeciesDetailScreen.build` then `ResultSection.build`): `_SpeciesHeader` names → `_SpeciesArtPanel` plate → `_OtherNamesBlock` → `_MeasureSlot` button → stamp → secondary findings → facts table → citation footnotes → disclaimer → `_RecordCatchAction`. Two whole blocks (other names, the Measure button) sit between the plate and the stamp, where the mockup has nothing.
- The stamp headline. Mockup `.stamp-ink h3` is a SHORT uppercase serif phrase — `text-transform:uppercase`, 26px (29px in sunlight), weight 700, `letter-spacing:.005em` — reading "BELOW THE MINIMUM". The app passes `stamp.headline` = the whole ARB sentence `verdictBelowMinimum` = "Below the minimum — 38 cm measured, minimum 45 cm (total length)", sentence case, set in `type.verdict` at fontSize 42 / w700 / letterSpacing −0.84, in an `Expanded(child: Text(...))` with no ellipsis — so it wraps to three lines where the mockup has one tracked line.
- The stamp sub-line. Mockup `.stamp-sub` is serif 15.5px (17px/600 in sunlight) over two lines — "38 cm measured" / "minimum 45 cm · total length" — with the figures in 15px mono spans. The app renders `_marginFor()` ("Short of the minimum by 7 cm") in `type.measure`, which is the 36px mono measurement step — roughly the size of the mockup's headline, carrying different content.
- The stamp's inner rules in sunlight. `.phone.sun .stamp{border:0}` deletes the double rules once the block reverses out. `_VerdictStamp` keeps both `_DoubleRule`s (1px + 2px gap + 1px, drawn in the inherited ink) inside the reversed `_Ground`, so white rules ride on the oxblood field. The reverse-out itself, `tilt: 0` and `ColoredBox` ground are correct (D-20 / LonjaSkinScope).
- Stamp padding and inset. Mockup sunlight: `padding:var(--s5) var(--s4)` (24/16) inside the block, `margin-inline:var(--s4)`. App: `EdgeInsetsDirectional.fromSTEB(s4, s7, s4, 0)` outside plus a flat `EdgeInsetsDirectional.all(LonjaSpace.s3)` (12) inside `_Ground` — a 48px top gap and half the internal padding.
- The `.rt` table's ruling. Mockup sunlight: `tr:first-child{border-top:2px solid #000}` and `tr{border-bottom:1.5px solid #000}` — a heavier opening rule and a solid rule under every row. `ResultRuleFactsTable` emits `Divider(height: LonjaRules.rule)` ABOVE each row and nothing below the last, so there is no closing rule and no weighted head.
- The `.rt` column split. Mockup `th{width:44%}` with the value column end-aligned. The app uses `Expanded(flex:1)` for the label and `Expanded(flex:2)` for the value — a 33/67 split.
- The `.rt` label type. Mockup sunlight `th{font-size:11px;letter-spacing:.1em}` uppercase; the app uses `type.eyebrow` at fontSize 14 / letterSpacing 1.68 (≈0.12em) — larger and more tracked than the sunlight-specific override.
- Colour on a table cell. The sunlight caption is explicit that the verdict oxblood is "one colour left in the whole interface", and `.phone.sun .rt td` is plain black at 17px/600. `_FactLine` still paints `fact.isOutcome ? tokens.verdictFail : tokens.onSurface` — a second oxblood on the page under sunlight.
- The citation block's shape. Mockup `.cite p` is ONE serif 12px sentence: "Ministerial Decision 580/2015, Art. 3 · published 2015-11-03 · checked 2026-07-14." `ResultCitationFootnote` renders a four-part stack — a mono superscript marker, a tracked uppercase jurisdiction eyebrow line, the instrument line, then the dates line — inside a `tapMin`-high `InkWell` with a trailing copy `IconButton`.
- The species names' size and position. Mockup sets them as the plate's caption (27px Arabic / 19px serif / 13.5px italic binomial). `_SpeciesHeader` puts `primaryName` ABOVE the plate at `type.display` = 32px w600 letterSpacing −0.16, and the binomial at `type.binomial` muted.
- Plate art height: `LonjaSilhouette(height: 160)` vs `.plate-art{height:126px}`, and the app draws a flat `assets/sil/*.svg` silhouette where the mockup draws an engraved plate with `.hatch` shading at 1.6 stroke (2.1 in sunlight).

**Extra**

- `_SpeciesHeader`'s family line — "Family {familyName}" in `type.uiSmall` muted. No equivalent anywhere on the mockup screen.
- `_SpeciesHeader`'s conditional `l10n.speciesProtectedAnywhere` line in `type.datum`.
- `_OtherNamesBlock` — a `LonjaSectionLabel` "OTHER NAMES" plus one `type.legal` line per locale plus a closing `LonjaRule.row()`, sitting between the plate and the stamp.
- `_MeasureSlot` — a full-width `LonjaButton.secondary` labelled "Measure" (or the reading) between the names and the stamp. The mockup screen arrives already measured and shows no measure affordance.
- `ResultFindingsList(display.secondary)` — a secondary-findings block between the stamp and the table.
- The citation footnote's extras: the numeric marker, the jurisdiction eyebrow line, the `copyKey` copy-to-clipboard `IconButton` with its nested-squares `_CopyMark`, the optional `provenance` line, and the `SelectableText` `source_url`.
- `ResultDisclaimer`'s second line — `l10n.disclaimerNotDismissable` ("It cannot be dismissed.") in `type.citation` at `onSurfaceFaint`. The mockup carries the equivalent `.fix` micro-line only on the ambiguity-dialog variant, not on this screen.
- `_RecordCatchAction` — a secondary "Record this catch" button with a `_recorded` latch, in the slot the mockup gives to the primary "Add to today".
- `LonjaListSkeleton` loading and raw `Text('$error')` error states inside the verdict slot.

---

## S10 Trips

**In the app:** partial · **effort:** M
· **files:** `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/log/widgets/trips_screen.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/log/view_models/catch_log_providers.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/domain/models/trip.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/core/ui/lonja_masthead.dart`

A Trips screen exists at /Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/log/widgets/trips_screen.dart, but it is a bare headline + one action button + an unstyled two-line list, where the mockup is a landings ledger: gazette masthead with a mono trip-count meta line, a four-chip filter row, month-grouped rule-labelled sections, 64dp rows with leading route glyph / date-led serif line / sans detail line / trailing pill-or-duration / chevron, then a totals table and an export affordance — roughly six of the nine stacked blocks are absent.

**Missing**

- The `header.mast` masthead entirely: TripsScreen renders a plain `Text(l10n.tripsHeadline, style: type.title)` inside a `Padding`, not `LonjaMasthead` (which exists at ui/core/ui/lonja_masthead.dart and is used only by check_screen.dart). No 2px ink bottom border, no paper ground band.
- `.wordmark small` — the italic serif 10.5px ink3 subline "Kept on this device only". There is no ARB key for it; the screen states nothing about where trips live.
- `.mast-meta` — the end-aligned mono 9.5px uppercase 0.12em-tracked two-line count "12 TRIPS / SINCE 1 MAY". The app never counts or dates the ledger.
- The whole `.chips` filter row: four `.chip` buttons (38px min-height, 1px `--rule` border, `--paper2` ground, sans 12px) — "All zones" in the `.chip.sel` inverted ink-field state, plus "This month", "By species", "With a fail". There is no chip widget anywhere under app/lib/ui/core/ui/ and no filter state in catch_log_providers.dart.
- Month grouping. The mockup opens the list with a `.lab-rule` reading "July 2026" (`.lab` = sans 9.5px, 0.2em tracking, uppercase, w600, plus a hairline to the margin). The app has `LonjaSectionLabel`, which is exactly this device, and does not use it — `tripsProvider` rows are emitted as one flat ungrouped `ListView.separated`.
- The `.rows` container's 1px solid ink top rule above the first row (the app only puts `LonjaRule.row()` BETWEEN rows, nothing above the first).
- The leading `#i-route` glyph on every row (`.row .ic.lead`, 22px, ink2). `_TripLine` has no leading widget at all.
- The trailing `.end` slot in all three of its forms: the `.pill` (mono 9px, uppercase, 0.12em tracking, 1px currentColor box, 2/5 padding) in `bl` OPEN, `ox` 1 FAIL and `oc` STALE DATA variants, and the `.mono` 12px elapsed duration ("4h 30m", "6h 25m"). No pill widget exists in app/lib and no duration is computed from startedAt/endedAt.
- The `.chev` trailing chevron (15px, ink3, `scaleX(-1)` under `[dir=rtl]`), and with it the whole tap affordance — the mockup row is a `<button>`; `_TripLine` is a `ConstrainedBox`/`Padding`/`Column` with no InkWell, no onTap, no route to a trip detail.
- Every per-trip fact the detail line carries: `.d` reads "Ras Al Khaimah · 04:55 — now · 7 fish · 41 kg" — clock times, fish count and landed weight. The app prints only two ISO dates via `tripsRunning`/`tripsEnded` (`_TripLine._day` substrings the first 10 chars, so the time of day is deliberately discarded).
- The second `.lab-rule` section head "Totals · 1 May to 27 July 2026".
- The entire `.rt` totals table: five th/td rows — Trips 12, Fish recorded 132, Landed weight 402 kg, Checks failing a rule (`td.ox`, oxblood w600) `9` + italic em `· 6.8%`, Bycatch notes 3. th is sans 9.5px 0.16em uppercase ink3 at 44% width start-aligned; td is serif 15px end-aligned with `.mono` 14px inside; 1px solid ink above the first row and 1px dotted between. No table widget and no aggregate query exists.
- The `.btn.ghost.sm` export affordance (46px min-height, `--rule` border, ink2, w500, 13.5px, with `#i-export` glyph): "Export as CSV to this phone".
- The `.note` beneath it (sans 11.5px, ink3): "Trips are never uploaded. Exporting writes a file into your own storage and nothing else happens to it." NOTE: the app's own doc comment on TripsScreen explicitly refuses export ("No export, no share sheet, no submit") citing SPEC §5, while SPEC §10 admits share_plus via E17/T05 — this is a real mockup-vs-code disagreement, not just an unbuilt widget, and should be settled as a D-n before anyone builds the button.

**Misplaced**

- Screen title case and weight: mockup `.wordmark` is serif 19px, w600, UPPERCASE, 0.16em letter-spacing. App uses `type.title` = serif 26px, w600, letterSpacing 0, sentence case. Bigger, untracked, uncased — and note `check_lonja_type.sh` check 6 bans a case transform in UI code, so the uppercase must come from the ARB value or a tracked style, not `toUpperCase()`.
- Row hierarchy is inverted. Mockup leads the `.m` block with the DATE (`.n.lat`, serif 16px w600, "Mon 27 Jul") and demotes the place into the sans 11.5px `.d` line. `_TripLine` leads with `trip.label ?? trip.zoneCode` at `type.subtitle` (serif 22px w600) and puts the dates underneath. Place and date have swapped both position and size.
- The open-trip marker. Mockup marks it twice — an inline sans 12px ink3 "· open" appended inside the date line AND a `.pill.bl` OPEN in the trailing slot. The app encodes it only as prose inside the detail string (`tripsRunning`, "Running since {since}"), with no trailing mark, which also weakens invariant 4's redundant-signal habit.
- The detail line's type role. Mockup `.d` is sans 11.5px ink2. App uses `type.datum` — mono 18px w500 tabular-figures, muted. Wrong family, wrong size, and mono/tabular is reserved by lonja-typography for measurements, article numbers and citations, not a prose detail line.
- Dates are raw ISO. `_TripLine._day` yields "2026-07-27"; the mockup prints "Mon 27 Jul" with a weekday. (The substring is a deliberate choice documented in the widget, so this is a decision to revisit, not an oversight.)
- Row height and separator. Mockup `.row` is min-height 64px with 10px/`--s5` padding and a 1px DOTTED `--rule` bottom border on every row. App uses `tokens.density.rowHeight` as a minHeight with `LonjaSpace.s2` vertical padding and a `LonjaRule.row()` separator only between items — worth confirming the row rule is the dotted weight, since lonja-lists-and-tables specifies hairline dotted C2C5BB.
- Empty state position and content. Mockup has no empty state authored for S10; the app's `_TripsEmptyState` sits where the ledger goes, which is fine — but it renders below a Start-a-trip button that the mockup does not have, so the first thing on an empty Trips screen is a control the design puts nowhere on this screen.

**Extra**

- The Start/End trip control: `LonjaButton.primary(l10n.tripsStart)` / `LonjaButton.secondary(l10n.tripsEnd)` sits directly under the headline, above the list. S10 has no start/stop affordance at all — its only button is the ghost export at the foot of the column. If the control must stay, it belongs where the mockup puts an action (foot of column, ghost weight), not as the primary at the top; lonja-buttons also allows only one primary per screen, and this one competes with nothing.
- A silent loading state: `loading: () => const SizedBox.shrink()`. lonja-lists-and-tables requires a loading skeleton as one of the four mandatory list states; the mockup shows the populated ledger, but an invisible loading state is an app-only behaviour and a gate-relevant gap.
- A raw error state: `error: (Object e, StackTrace _) => Text('$e', style: type.legal)` prints the exception object to the fisher. Nothing in the mockup, and it is a user-facing sentence nobody wrote.
- `_TripsEmptyState` (tripsNone + tripsNoneBody). Reasonable to keep, but it has no counterpart in the mockup and its copy is untested against S10's tone.

---

## S2 Result — Protected (species detail + verdict result surface)

**In the app:** partial · **effort:** M

The app has a real S2 in `SpeciesDetailScreen` + `ResultSection` and gets the deep structure right (stamp between double rules, then facts, then citation footnote, then disclaimer), but the top third is a different screen — no app bar/back/zone line, no engraved plate frame or plate caption, an identification header stacked above the art instead of a figcaption below it — and the protected state itself is stripped to a bare headline: no sub-line, no meta line, and deliberately zero table rows where the mockup prints six.

**Missing**

- App bar (.bar): 44dp back `iconbtn` (#i-back), serif 18px/600 species title "Al-minshar", and the end-aligned mono 9.5px uppercase +.1em `.sup` zone line "Ras Al Khaimah". `SpeciesDetailScreen` builds `Scaffold(body: SafeArea(...))` with no `appBar` at all, so the pushed route has no back affordance and never names the zone the verdict was evaluated against.
- Engraved plate frame (.plate-frame): 1px ink border with a second inset 1px rule via `::after`, on paper2. `LonjaPlateSurface` draws only a `BorderDirectional(top: hairlineStrong)` over `surfaceSunk` — a top rule, not a framed plate.
- Plate number `.plate-no` "PL. II · fig. 1" — mono 9px, +.16em, uppercase, absolutely positioned top-inline-start inside the frame. Nothing in `LonjaPlateSurface`/`LonjaSilhouette` renders one.
- The `.hatch` engraving overlay (stroke-width .7, opacity .5) over the fish art.
- Plate caption `.plate-cap` as a single baseline-aligned wrapping row: Arabic `.loc` "المنشار" at 27px Naskh, `.tr` "Al-minshar" serif 19/600, `.en` "· Green sawfish" serif 15 ink2, then `.sci` "Pristis zijsron — Pristidae" italic 13.5 ink3 on its own line. The app has no caption under the art and never prints the Arabic local name and the English common name beside the transliteration.
- `.stamp-sub` for the protected state — "All sizes, all seasons, all gear. Sale and possession are prohibited with it." (serif 15.5). `signalsFor(VerdictCategory.protected)` sets `measured: false`, and `ResultVerdictPanel` uses that to null the sub-line entirely, so the protected stamp prints one line and nothing else.
- `.stamp-meta` — "Protection · no size or season applies", sans 10.5px, +.14em, uppercase, in the stamp ink. `VerdictStampDisplay` has no meta/third-line field at all; the mockup's every-stamp third line does not exist in the app.
- The whole six-row protected `.rt` table: Status / Fully protected (ox), Size rule / *Not applicable*, Season / *Not applicable*, If taken incidentally / Recorded as a bycatch note, First offence / AED 3,000 + 6-month suspension, Second offence / AED 5,000 + licence revocation. `verdict_presenter.dart` line 382 is `ProtectedFinding() => const <RuleFact>[]`, so `ResultRuleFactsTable` returns `SizedBox.shrink()` and the protected screen shows no numbers whatsoever.
- The `.diag` block "DISTINGUISHING FEATURE" — ruled 1px box on paper2, `.dl` sans 10.5 uppercase +.14em label over `.dd` serif 13.5 prose about the 24–28 toothed rostrum. `ResultMethodDiagram` exists but is referenced from no screen, and it is a measurement-method diagram, not an identification-feature block.
- The footnote's small-caps authority `.who` ("United Arab Emirates", font-variant small-caps, +.06em) set inside one flowing serif 12px sentence with a mono superscript marker. The app splits it into three stacked lines (jurisdiction in `type.eyebrow`, instrument+article in `type.citation`, dates in `type.citation`) with the marker in `type.articleNumber` in a leading column.
- The `.lnk` action "Open the protected species list →" — blue underlined sans 11.5 under the footnote. `ResultSection` is handed `onOpenRuleText: (int _) {}` from `SpeciesDetailScreen`, so the equivalent affordance is a no-op with no visible label.
- The disclaimer's `#i-info` icon and its ruled surround: `.disc` has paper3 ground, 2px ink top border and a 1px hairline bottom border. `ResultDisclaimer` is two bare `Text`s with no icon, no ground and no rules.
- The primary action "Add to today as a bycatch note" with the `#i-plus` glyph in a `.btn-row` — a full-width bordered button. The app's `_RecordCatchAction` is `LonjaButton.secondary(label: l10n.catchRecord)`, i.e. generic wording, no icon, and not the protected-specific bycatch phrasing.

**Misplaced**

- ORDER, top of screen: the mockup runs app bar → plate art → caption naming the fish. The app runs `_SpeciesHeader` (primary name at `type.display` 32px, "Family Pristidae", italic binomial, plus a `speciesProtectedAnywhere` datum line) → `_SpeciesArtPanel`. The identification text is above the art instead of being the figcaption below it, and it is four stacked lines instead of one baseline row.
- Stamp headline case and size: `.stamp-ink h3` is serif, `text-transform:uppercase`, +.005em, 26px dropping to 21px under `.stamp.long`, and the protected copy is authored to break over two lines ("Protected species —<br>taking prohibited"). The app prints the raw ARB value `verdictProtected` = "Protected species — taking prohibited." — sentence case, trailing full stop, at `type.verdict` 42px/w700/-0.84 tracking, so it wraps as one oversized sentence with no long-headline step.
- Stamp glyph: mockup `.stamp-ink .ic` is 30px at stroke-width 1.7, vertically centred against the headline (`align-items:center`). The app uses `LonjaIconSize.stamp` inside a `Row` with `crossAxisAlignment: CrossAxisAlignment.start`, so the ban mark hangs at the top of a 42px two-line headline instead of centring on it.
- Tilt: mockup `transform:rotate(-.55deg)`; app `kVerdictStampTilt = -0.0096` rad ≈ -0.55°, so this one matches — but the app additionally zeroes it and reverses to a solid ground in the sunlight skin, which the mockup has no equivalent of.
- Rule-table row anatomy: mockup `.rt th` is start-aligned sans 9.5px uppercase +.16em at a fixed 44% column, `.rt td` is end-aligned serif 15px with mono numerals and italic `em` qualifiers; rows are separated by `1px dotted var(--rule)` with a `1px solid ink` rule above the first row only. `ResultRuleFactsTable` uses `Expanded`/`Expanded(flex:2)` (≈33%/67%, not 44%), `type.eyebrow` 14px for the label, `type.datum` mono 18px for the value (mockup values are serif with mono only on the figure), a plain Material `Divider` before *every* row (solid, not dotted, and one above the first as well as between), and it has no italic qualifier run inside a value.
- Citation footnote rule: mockup `.fnrule` is 44% wide at 1px in full ink at .85 opacity; the app's `footnoteRuleKey` block is `FractionallySizedBox(widthFactor: 0.44)` in `tokens.hairline` — the width matches, the ink is the lighter hairline slot.
- Disclaimer fine print: mockup `.fix` is mono 8.5px uppercase +.14em reading "Shown on every result · cannot be dismissed"; the app prints `disclaimerNotDismissable` = "It cannot be dismissed." in `type.citation` (mono 16px, sentence case, no tracking) — right idea, wrong scale, case and wording.
- Body gutter: the mockup pads the plate, table and footnote with `--s5` while the stamp bleeds to the same gutter and the nav/status chrome does not. The app wraps the whole `SingleChildScrollView` in one `EdgeInsetsDirectional.all(tokens.density.gutter)` and then `ResultVerdictPanel` adds its own `LonjaSpace.s4` inset, so the stamp is indented further than everything above it rather than aligning with the plate frame.

**Extra**

- `_SpeciesHeader` family line — "Family: Pristidae" in `type.uiSmall`. The mockup folds the family into the `.sci` line as "Pristis zijsron — Pristidae" and never labels it.
- `speciesProtectedAnywhere` line — "Protected somewhere in this jurisdiction" in `type.datum` under the header. The mockup states protection once, in the stamp.
- `_OtherNamesBlock` — a "Other names" section label, a list of every locale name, and a trailing `LonjaRule.row()`. The mockup carries the other names inline in the plate caption and has no such block.
- `_MeasureSlot` — a `LonjaButton.secondary` labelled "Measure" (or the last reading) pushing `MeasureScreen`, sitting between the names block and the stamp. The protected mockup has no measurement affordance at all, and putting one above a prohibition stamp implies a threshold.
- The copy-to-clipboard `IconButton` (`_CopyMark`, two nested squares) inside `ResultCitationFootnote`. No copy affordance in the mockup.
- `SelectableText(sourceUrl)` under the footnote when the instrument records one.
- The pack `provenance` line under the first footnote — only ever shown in the mockup's closed-season variant, not the protected one.
- `ResultFindingsList` secondary-findings block between the stamp and the table; the protected mockup shows only the stamp and the table.

---

## Glove mode — S1 Check re-set for wet hands (mockup `.phone.glove`, CSS §13)

**In the app:** partial · **effort:** M

The Check screen and a real glove density both exist (`LonjaDensity.glove` wired through `app.dart` → `LonjaTheme`), but the app renders roughly half the mockup's blocks, in a different top-to-bottom order (search below the recents strip instead of above it), and its glove density is one flat `tapMin: 56` where the mockup grows each target class separately to 56/66/72/126×118/84.

**Missing**

- Masthead wordmark: `.wordmark` "CatchLaw" — serif 19px, uppercase, .16em tracking, w600 — with its italic serif `small` subline ("Glove mode · 56–84 dp targets"). `LonjaMasthead` renders an eyebrow "place" label + place name instead; no wordmark anywhere in lib/ui/.
- Masthead `.mast-meta`: right-aligned two-line mono uppercase date block ("MON 27 JUL" / "2026") at 9.5px/.12em on the baseline of the wordmark row.
- The `.chips` row entirely: `.chip.zone` (pin glyph + bold "Ras Al Khaimah" + trailing chevron, harbour border and tint) and `.chip.seal` (verdant seal glyph + "Checked" + bold `2026-07-14`), 56dp min-height in glove. No chip widget exists under lib/ui/core/ui/.
- The `.btn-row`: two full-width square outlined buttons, 66dp in glove — "Browse by shape" (shape glyph) and "Identify this fish" (key glyph) — standing permanently under the strip. In the app these two labels exist only inside `_SearchEmptyState` (species_search_screen.dart:225-226) when a query returns zero rows, and `check_screen.dart:99-100` passes `onIdentify: () {}` / `onBrowseByShape: () {}`.
- The `.tally` bar: 2px ink top rule + 1px hairline bottom, 72dp in glove, carrying the `.k` eyebrow "TODAY", the serif `.v` line "Hamour 3 … 2 of 5 remaining" with the italic remainder, and a trailing chevron. `dayTallyProvider` exists in ui/log/view_models/ but nothing surfaces it on Check.
- The `.pips` meter (5 cells, 8×12px, 1px ink2 border, filled = ink) — no equivalent widget in the app.
- Recents tile anatomy: `.rec .fish` silhouette at 44px in glove, `.n` Arabic name at 19px, `.t` sans transliteration at 10px/.04em, `.r` mono rule line ("45 cm TL", "65 cm FL", "Closed"). `LonjaSilhouette` exists but is used only by species_detail_screen.dart and species_browse_screen.dart, never by the Check strip.
- The differentiated glove target set — chips 56, buttons 66, search 72, tiles 126×118, nav 84 (CSS §13 lines 681-694). `LonjaDensity.glove` carries one `tapMin: 56` plus `rowHeight: 72`, so buttons, search, chips and nav all land on 56.
- Vertical hairline dividers between nav cells (`.ni { border-inline-end: 1px solid var(--hair) }`) and the paper-lifted ground on the selected cell (`.ni.on { background: var(--paper) }`).
- The `.sb` status strip's "No signal · offline by design" legend (mockup frame chrome; the app draws no such line).

**Misplaced**

- ORDER, the biggest divergence. Mockup: masthead → chips → search → "Recently checked" label+strip → button row → tally → nav. App (`_Check.build`, check_screen.dart:71-105): masthead → "Recently checked" label+strip (or `CheckEmptyState`) → `SpeciesSearchScreen` (eyebrow + search field + results) → nav. The search field sits BELOW the recents strip; the mockup puts it above.
- Search field frame: `.search` is a 1.5px full ink box on paper2 with a 26px leading search glyph and an italic serif placeholder at 18.5px, 72dp tall in glove. `LonjaSearchField` is a bottom-border-only `DecoratedBox` at `tapMin` (56 in glove), has NO leading search glyph at all, and its hint uses `type.legal` (19px serif) with no glove uplift.
- The checked date: mockup puts it in the `.chip.seal` on the chips row with a bold mono date; the app stacks `checkPackChecked` as a left-aligned `type.citation` line under the place name inside the masthead.
- The place affordance: mockup is the tappable `.chip.zone` with a trailing chevron; app is a trailing `TextButton` labelled "Change place" sitting beside the place text (lonja_masthead.dart:71-77).
- Nav selected state: mockup `.ni.on::before` is a 3px harbour `--blue` rule plus a lifted paper ground and a filled glyph; `_NavCell` (lonja_nav_strip.dart:95-97) draws a `LonjaRules.strong` top rule in `tokens.onSurface` ink with no ground change.
- Nav cell size and type: mockup glove `.ni` is 84dp with 28px glyphs and 10px/.11em uppercase labels; the app uses `tokens.density.tapMin` (56), `LonjaIconSize.ui`, and `type.microLabel` at 12.5px with 2.0px tracking.
- Recents tile: mockup `.rec` is a 1px-bordered 126×118 card with four stacked elements; the app renders a single centred `Text(entry.displayName)` at `type.ui` inside an unbordered `InkWell` with `minWidth: tapMin` in a strip of `height: rowHeight` (recents_strip.dart:63-89).
- Section label: `LonjaSectionLabel` is the right device (tracked label + rule to the margin, matching `.lab-rule`), but the app's `microLabel` is 12.5px/2.0px tracking against `.lab`'s 9.5px/.2em, and the gap before the rule is `LonjaSpace.s2` (8) against the mockup's 10px.
- Target separation: glove `tapGap` is `LonjaSpace.s2` = 8, but the mockup's glove caption and note both assert 12dp minimum between free-standing targets (8 is called the floor, not the glove value); the mockup's `.chips`, `.strip` and `.btn-row` all take `gap: var(--s4)` = 12px in glove.
- Screen gutter: glove `gutter` is `LonjaSpace.s5` = 24 in the app; the mockup's `.pad`/`.chips`/`.search` inline padding is `--s5` = 16px and is not enlarged by §13 at all ("only the hit areas and the gutters grow" applies to the gaps, not the page margin).

**Extra**

- "Change place" `TextButton` in the masthead row (lonja_masthead.dart:73).
- An eyebrow `checkPlaceLabel` label above the place name in the masthead — the mockup has no label above the zone chip.
- An eyebrow `speciesSearchLabel` label above the search field (species_search_screen.dart:73) — the mockup search box carries only its icon and placeholder.
- A `speciesSearchResultCount` datum line under the search field (species_search_screen.dart:84-91).
- `CheckEmptyState` (serif headline + muted body, check_empty_state.dart) rendered in the strip's place when there are no recents — the mockup glove screen always shows four tiles.
- `LonjaStaleBar` above the search block when the pack is expired (species_search_screen.dart:67) — correct per invariant 5, but absent from this mockup screen.
- A second `Scaffold` + `SafeArea` nested inside the Check `Scaffold`, because `SpeciesSearchScreen` is a full screen embedded as the `Expanded` child.

---

## S4 Calibration — calibrate the ruler against an ISO/IEC 7810 ID-1 card

**In the app:** partial · **effort:** M

The screen exists at /Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/ruler/widgets/calibration_screen.dart, but it is a four-widget stub — body sentence, a 96dp sunken slider strip with a 3dp ink bar, one datum line and one primary button — where the mockup is a dimensioned engineering drawing (framed card outline, dimension lines, five corner handles) followed by a four-row "Resulting scale" table and a secondary reset; roughly two-thirds of the mockup's content has no widget at all.

**Missing**

- App-bar supra label: `.bar .sup` mono 9.5px, uppercase, .1em tracking, ink3, pushed to the end edge — "ONCE PER DEVICE". The app's AppBar carries a title and nothing else.
- The ISO constant line above the drawing: `.note` (sans 11.5px / 1.5 / ink3) reading "Every card of this format is identical:" with a `.mono` run "ISO/IEC 7810 ID-1 — 85.60 × 53.98 mm". The app names only the width (85.60) and never the height (53.98), and never the standard as a mono run.
- The framed drawing well: outer `div` with `border:1px solid var(--rule)`, `background:var(--paper2)`, padding 22px/10px/26px. The app's handle sits on `tokens.surfaceSunk` with a 1px hairline box and no outer frame.
- The card outline itself: a 266×168px rectangle, `1.5px solid var(--ink)` on `var(--paper3)`, with a 7px-inset `1px dashed var(--ink3)` inner rule. The app draws no card shape at all — only a horizontal fill band whose width is `state.handleWidthPx`.
- The dimension SVG inside the outline: `.dim` stroke-1 leader lines plus `.dimtxt` (mono 9px, .06em tracking) labels "85.60 mm" along the bottom and "53.98 mm" up the end edge, plus the corner registration tick `M24 30h60M24 30v34`. No CustomPainter or SvgPicture equivalent exists.
- The five corner handles: four 18×18px squares with `2px solid var(--blue)` on paper at each corner, plus one filled 22×22px `var(--blue)` handle at the bottom-end corner that is the actual drag target. The app has a single 3dp ink bar (`LonjaRules.stamp`) as its only affordance.
- The centred instruction under the drawing: `.note` `text-align:center` "Drag the filled handle · pinch to fine-tune". There is no pinch/scale gesture in `CalibrationViewModel` either — only `onHorizontalDragUpdate` → `dragTo`.
- The `.lab-rule` section label "RESULTING SCALE" (sans 9.5px, .2em tracking, uppercase, 600, ink3, with a 1px rule running to the end edge). `LonjaSectionLabel` exists in ui/core/ui/ and is used on Settings, but not here.
- The whole `.rt` results table — 4 rows, `th` start-aligned sans 9.5px uppercase .16em tracking at 44% width, `td` end-aligned serif 15px with `.mono` 14px values, 1px ink rule above the first row and dotted rules between: "Pixels per 10 mm — 162.4", "Screen density — 412 dp · 2.625×" (the multiplier in `td em` italic ink2 13.5px), "Expected error — ± 1.5 mm · over 30 cm", "Last calibrated — 2026-07-02". The app shows no resulting scale, no density, no error band and no date; the calibrated date is only rendered on Settings (settings_screen.dart line ~145).
- The secondary action `.btn.ghost.sm` "Reset to screen default" (46px min-height, 13.5px label, rule-grey outline) below the primary.
- The closing `.pad` note: "A case or a screen protector changes nothing — the card sits on the glass and the glass is what is being measured." No ARB key exists for it.
- The bottom `nav` strip with the five destinations and Settings selected. The app pushes `CalibrationScreen` as a bare `MaterialPageRoute` from Settings and from `measure_screen.dart` line 84, so `LonjaNavStrip` is not rendered.

**Misplaced**

- Title text and weight: mockup `.bar h2` is serif 18px/600, "Calibrate the ruler"; the app renders `l10n.calibrateTitle` = "Calibrate" in the default Material AppBar title style.
- The lede: mockup `.lede-s` is serif 15px/1.5 ink2 and describes the physical act ("Place any bank, ID or transport card flat on the screen. Drag the corner until the printed outline sits exactly on its edges"). The app's first line is `type.legal` with `calibrateFitBody` — "drag the black line to its right edge" — which describes a slider, not a card outline, and it swaps to `calibrateVerifyBody` on the second step.
- Position of the card-dimension text: mockup puts the ISO note ABOVE the drawing as a `.note` with a mono run; the app puts `calibrateCardWidth` BELOW the handle as `type.datum` in `onSurfaceMuted`, so the physical constant reads as a caption on the control rather than as the premise of the screen.
- Primary button label: mockup is always "Save calibration"; the app's single `LonjaButton.primary` reads "Check it" on the fit step and "Save the calibration" only on the verify step, so the mockup's save affordance is one tap deeper.
- Order below the drawing: mockup runs drawing → "Resulting scale" label → results table → primary → ghost reset → closing note. The app runs handle → card-width caption → primary → (conditional) refusal text, collapsing four blocks into one caption line.
- The drag control's geometry: the mockup's control is two-dimensional (a card-shaped rectangle sized by a corner handle, both dimensions visible); the app's is one-dimensional (a full-width 96dp strip, fill = `tokens.accent` at 18% alpha, terminated by a 3dp `tokens.onSurface` bar), so the fisher matches one edge rather than seating a whole card.

**Extra**

- A two-step fit → verify flow (`CalibrationStep.fit` / `.verify` in calibration_viewmodel.dart) with step-dependent body copy and a step-dependent primary label. The mockup shows one step with a single Save.
- The plausibility refusal line `l10n.calibrateImplausible` rendered as `type.legalSmall` in `onSurfaceMuted` when `state.lastOutcome != null`. The mockup has no error slot (its equivalent honesty is the "Expected error ± 1.5 mm" table row, which the app lacks).
- A plain Material `AppBar` rather than the mockup's ruled `.bar` (1px rule-bottom on paper, 44px back `iconbtn` with -10px start margin).

---

## S13 Rule text reader (Arabic)

**In the app:** partial · **effort:** M
· **files:** `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/reference/widgets/rule_text_screen.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/domain/models/legal_article.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/result/widgets/result_citation_footnote.dart`, `/Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/species/widgets/species_detail_screen.dart`

A stub reader exists — `RuleTextScreen` prints an English title line, an English "published … · checked …" line, then a flat stack of articleRef eyebrow + body — but it has no app bar, no search field, no article chip row, no margin gutter, no rule table, no closing citation footnote, no nav strip, and nothing in the app ever navigates to it (every `onOpenRuleText` is a no-op and `lib/routing/` holds only `destination_placeholder.dart`), so roughly a quarter of the mockup screen is on the page and the rest is absent.

**Missing**

- App bar (`.bar`): a 44x44 `.iconbtn` back chevron (mirrored under RTL), an `<h2>` serif 18px/600 screen title "نص القرار", and a `.sup` instrument short-form "٥٨٠/٢٠١٥" in mono 9.5px, .1em tracking, uppercase, ink3, pushed to the far end by `margin-inline-start:auto`, all over a 1px hairline bottom rule. The app screen is a bare `Scaffold(body: SafeArea(...))` with no `AppBar` at all — there is no way back off it.
- Full-text search field (`.search`, min-height 52px here): 1.5px solid ink border, paper2 ground, 22px search glyph, placeholder "ابحث في النص الكامل" set in the Arabic face at 17px ink3 with `font-style:normal` (the field's default italic is deliberately cancelled for Arabic). `LonjaSearchField` exists in `ui/core/ui/` and is not used here. The screen's own doc comment defers this to E15.
- Article navigation chips (`.chips` / `.chip`): six ruled cells — selected "المادة ٣" as `.chip.sel` (ink fill, paper text, ink border) followed by ١ ٢ ٤ ٥ ٦ at 1px rule border, paper2, sans 12px ink2, min-height 38px, `--s3` gaps. Nothing in the app scrolls or jumps between articles.
- The baseline grid behind the body (`.baseline`): `repeating-linear-gradient` ruling every 32px at `rgba(22,32,28,.055)`, offset 6px — the caption calls it out explicitly as part of the design intent. The app's `SingleChildScrollView` paints on plain surface.
- The masthead block above the first article — three separate lines the app collapses into one: (a) an issuing-authority eyebrow `.lab` "وزارة التغير المناخي والبيئة", sans 9.5px, 600, ink3, with `letter-spacing` overridden to 0 for Arabic; (b) the full instrument title as an `<h3>` in the Arabic face at 21px/1.6/700 — the actual published wording, not a Latin identifier; (c) a `.hr.hv` 2px solid-ink rule closing the masthead.
- The `.gut` margin-gutter layout: `display:grid; grid-template-columns:52px minmax(0,1fr)`, with `.g-no` holding a two-line mono 9.5px ink3 end-aligned marker ("المادة" / "(٣)") in the margin and `.g-bd` carrying a 1px `border-inline-start` hairline plus `--s4` inset. This is the screen's signature — the caption names it "article numbers in the margin" — and the app has no gutter, no vertical hairline, and no margin column.
- The `جدول (١)` rule table (`table.rt`) sitting inside its own gutter block: `tr:first-child` gets a 1px solid ink top rule, every `tr` a 1px dotted `--rule` bottom; `th` is the vernacular species name (Arabic face, 14px, ink, tracking forced to 0) at 44% width, start-aligned; `td` is end-aligned serif 15px carrying a `.mono` figure ("٤٥ سم") followed by an italic `<em>` method name ("الطول الكلي") in ink2 at 13.5px. Three rows: هامور/كنعد/زبيدي.
- The closing `.cite` footnote block: a `.fnrule` 44%-width 1px ink rule at 0.85 opacity, then serif 12px/1.5 ink2 prose — "هذا النص محفوظ بالكامل على الجهاز ولا يُختصر. الترجمة الإنجليزية متاحة للاسترشاد فقط." — the offline-completeness and translation-is-guidance-only notice.
- The `.lnk` action "عرض النص بالإنجليزية ←" (blue, underlined at 2px offset, sans 11.5px) — the language switch onto the English text. `LegalArticle` is single-locale by construction and the app offers no locale affordance.
- The bottom `.nav` strip with Reference (`المرجع`) selected — 3px harbour top rail, lifted paper ground, RTL labels switching to the Arabic face at 11px with tracking dropped to 0. `LonjaNavStrip` exists but this screen is not built inside `AppShell`.
- Any route onto the screen. `ResultCitationFootnote.onOpenRuleText` is wired to `(int _) {}` at `species_detail_screen.dart:296` and defaulted to `(int _) {}` in `species_detail_placeholders.dart:66`; no `GoRoute` for it exists. The mockup screen is reachable; the app one is dead code.

**Misplaced**

- Order and identity of the header. Mockup top-to-bottom inside the body: authority eyebrow → Arabic instrument title (21px/700) → published/checked note → 2px ink rule → articles. App: a single `Text('${citation.instrument}, ${citation.article}', style: type.title)` — a Latin-script string that fuses instrument and article number into the headline, with no authority eyebrow above it, no Arabic-face title, and no `.hr.hv` closing rule below. The article number belongs in the margin gutter, not in the title.
- The published/checked line is English-only and un-styled per-token. App prints `'published ${citation.publishedOn} · checked ${citation.checkedOn}'` as one `type.citation` run in muted ink. Mockup uses `.note` (sans 11.5px ink3) with Arabic connective words "نُشر في" / "روجع في" and only the two dates set in `.mono`, so the figures read as data against the prose.
- The article marker's placement and typeface. App renders `article.articleRef` as a full-width `type.eyebrow` line stacked directly above the body with `bottom: LonjaSpace.s1` — a heading. Mockup puts it in a fixed 52px start-side margin column, end-aligned, in mono 9.5px with .06em tracking and ink3, wrapped over two lines, and the body is separated from it by a vertical hairline rather than by vertical space.
- Body text alignment. `.legal` is `text-align:justify` at 16.5px / line-height 2.05 in the Arabic face; the app uses `type.legal` with `textAlign: TextAlign.start`, so the Arabic column is ragged where the mockup is justified to the gutter rule.
- Inter-article spacing is uniform in the app (`bottom: LonjaSpace.s5` on every article). The mockup varies it deliberately: the table block follows Art. 3 at `margin-top:8px` (tight, because it belongs to that article), while Art. 4 opens at `margin-top:16px` (a new article).
- Padding model. App applies `EdgeInsetsDirectional.all(tokens.density.gutter)` to the whole scroll view, so the header, articles and any future rules all share one inset. Mockup scopes horizontal inset to `.pad` (`padding-inline:var(--s5)`) inside a full-bleed scroll body, which is what lets the baseline grid and the `.hr.hv` run edge-to-edge.

**Extra**

- `_directionFor(article.locale)` sets `textDirection` per article body from the law's locale — the mockup is a single Arabic instrument and shows no mixed-direction case. Correct behaviour, just not something the mockup exercises.

---

## D4 — "Two rules apply here" ambiguity dialog (mockup `.scrim > .dlg` inside the D4 slot) → app `ResultAmbiguityDialog` / `ResultAmbiguityBlock`

**In the app:** partial · **effort:** M

The app has a working, correctly-refusing ambiguity modal, but it is an unheaded scrollable panel of label/value tables and N+1 identical outline buttons, where the mockup is a headed gazette notice — eyebrow, serif headline, 2px ink rule, serif lede, two rail-marked instrument blocks written as prose, a closing note, the disclaimer, and a primary/ghost footer pair.

**Missing**

- Dialog header block (`.dlg-h`) entirely: the app `AlertDialog` passes no `title:`. Mockup has an eyebrow `.lab` "CONFLITO DE INSTRUMENTOS" (sans 9.5px, letter-spacing .2em, uppercase, ink3, w600) sitting above the headline.
- The serif headline `.dlg-h h3` "Duas regras se aplicam aqui" (serif 21px, w600, line-height 1.15) as a distinct title line. The app's nearest equivalent is `ambiguity.sentence` (`l10n.verdictAmbiguous`, "Two rules of equal standing apply here.") rendered in `type.subtitle` with nothing above it.
- The 2px solid ink rule under the header (`.dlg-h{border-bottom:2px solid var(--ink)}`) separating title from body. The app draws no rule between the sentence and the first rule panel — only a `LonjaSpace.s3` gap.
- The serif lede paragraph (`.lede-s`, serif 15px overridden to 14px, ink2) that states the situating fact — "Este ponto está a `1.180 m` da barragem e dentro da área da represa. Dois instrumentos cobrem o local" — with the distance in `.mono` and the refusal in `<b>`. Nothing in `AmbiguityDisplay` carries a lede; there is one `sentence` field and no place for the locating measurement.
- Per-instrument jurisdiction eyebrow `.instr .k` — "FEDERAL" / "ESTADUAL" (sans 9.5px, .16em tracking, uppercase, ink3, w600). `AmbiguousRuleDisplay` has `instrumentId`, `facts` and `citation`; there is no jurisdiction-tier label field, so the app cannot print one.
- The 3px `border-inline-start` rail on each `.instr` block, harbour `--blue` on the first and `--ochre` on the second, with `padding-inline-start:11px` — the mark that makes two co-equal instruments visually separable without ranking them.
- The `.note` closing paragraph (sans 11.5px, line-height 1.5, ink3): "Os dois instrumentos estão em vigor neste ponto… e não classifica um como mais forte que o outro." The app prints no closing note inside the dialog.
- The disclaimer `.disc` inside the dialog — info glyph, `paper3` field, `border-top:2px solid ink`, `border-bottom:1px solid rule`, bold lead "Apenas para referência — não é orientação jurídica." plus the `.fix` line (mono 8.5px, .14em tracking, uppercase) "Exibido em todo resultado · não pode ser dispensado". `ResultDisclaimer` exists and is unconditional in `ResultSection`, but it is not in the dialog tree at all — the modal that covers the screen shows no disclaimer.
- The `.dlg-f` footer actions: a filled primary `btn pri` (harbour field, 56dp min-height, sans 15px w600, .03em tracking) "Ver as duas regras", and beneath it a `btn ghost sm` (rule-grey border, ink2, w500, 46dp, 13.5px) "Trocar de zona". The app has no continue action and no change-zone action of any kind.
- The instrument statement written as serif prose (`.instr .t`, serif 15px/1.4, ink) with figures inlined in mono — "Piracema — período de defeso. Cota diária de `10 kg` mais `1` exemplar." The app has no prose statement per instrument; it renders `ResultRuleFactsTable` label/value rows instead.

**Misplaced**

- ORDER. Mockup top→bottom: eyebrow → serif headline → 2px ink rule → serif lede → instrument 1 → instrument 2 → note → disclaimer → primary → ghost. App (`result_ambiguity_dialog.dart` lines 99-122): sentence → rule panel 1 → rule panel 2 → one outline button per rule → defer button → the same sentence again. The refusal sentence brackets the whole dialog instead of heading it, and the actions sit above the last text block rather than in a footer below everything.
- The citation line. Mockup `.instr .c` is mono 10.5px, ink3, instrument name plus check date only: "Instrução normativa federal · verificado em 2026-06-18". `ResultAmbiguityBlock` line 49-51 prints a four-part line "instrument, article · published YYYY-MM-DD · checked YYYY-MM-DD" in `type.citation` + `onSurfaceMuted` — more fields, and it sits inside the panel rather than hanging off a coloured rail.
- Instrument container. Mockup `.instr` is unfilled, unframed, marked only by a 3px start rail on a paper ground. The app wraps each rule in `LonjaPanel` — `surfaceSunk` fill plus a full hairline `Border.all` at `LonjaRules.rule` on all four sides.
- Dialog frame. Mockup `.dlg` is `background:paper` with a `1.5px solid ink` border (plus a drop shadow the Lonja token law bans, so its absence in the app is correct). The app's `AlertDialog` takes `dialogTheme` — square, elevation 0, `tokens.surface` — but carries no border of its own; the visible frame comes from a second `LonjaPanel` wrapped around the entire dialog content (line 98), so the app reads as panel-inside-dialog where the mockup reads as one ruled sheet.
- Action rungs and count. Mockup has exactly two buttons and they are graded: one filled harbour primary at 56dp, one grey ghost at 46dp. The app emits N+1 `LonjaButton.secondary` (outline, same weight, same height) — one per instrument labelled with `rule.citation.instrument`, plus the defer button. This is a deliberate, documented divergence (lines 104-106: a primary among them would rank the instruments), so it should be reconciled by changing the mockup, not the code.
- The distance figure. In the mockup `1.180 m` appears twice in mono — once in the `.rt` table behind the scrim ("Distância da barragem") and once in the dialog lede. In the app it can only appear as a `RuleFact` row inside `ResultRuleFactsTable`, right-aligned in `type.datum`, never inside a sentence.

**Extra**

- The refusal sentence is rendered twice in the same dialog: `ResultAmbiguityBlock` line 35 in `type.subtitle` (serif 22px w600), then again at `result_ambiguity_dialog.dart` line 121 in `type.uiSmall` below the buttons. The mockup states it once, in the headline, plus a differently-worded `.note`.
- `ResultRuleFactsTable` rows inside each instrument block — a `Divider` hairline per row, eyebrow-styled label start-aligned, `type.datum` tabular value end-aligned, `verdictFail` colour and w600 when `fact.isOutcome`. The mockup's dialog has no table inside the instruments; its `.rt` table is on the species screen behind the scrim.
- A `SingleChildScrollView` around the whole dialog body. The mockup dialog is a fixed vertically-centred sheet with no scroll affordance.
- `AlertDialog`'s default `contentPadding` / `insetPadding`, on top of the `LonjaPanel`'s own `tokens.density.gutter` padding — two padding systems where the mockup has one (`.dlg-b{padding:var(--s5)}`).

---

## S6 — Browse by shape

**In the app:** partial · **effort:** M

The grid exists (`SpeciesBrowseScreen` at /Users/zakariafatahi/50-apps-challenge/E02/app/lib/ui/species/widgets/species_browse_screen.dart, mounted inside `ReferenceScreen`), but it is only the bare bones of the mockup: silhouette + one name per tile under a family label, with no ruled `.bar` header, no chips, no species counts, no binomial line, no `+ N more` overflow cells, no other-zones section and no citation footnote — and it stacks two 26px serif titles where the mockup has one 18px serif bar.

**Missing**

- The `.bar` header row entirely: 44px back `.iconbtn` (#i-back) + serif 18px/600 `<h2>Browse by shape` + mono 9.5px uppercase .1em-tracked `.sup` "31 species" pushed to the trailing edge, all over a 1px bottom rule on paper. The app renders a plain padded `Text` and no back affordance, no total count, no bottom rule.
- The `.chips` row directly under the bar: `.chip.zone` (blue border, blue-tint ground, #i-pin icon, bold "Ras Al Khaimah") and a neutral `.chip` (#i-shape icon, "6 families"). Nothing in the app renders a zone chip or a family count on this screen.
- The per-family count in the `.lab-rule` heading — the mockup labels read "Groupers & rock fish · 4", "Emperors, breams & rabbitfish · 9", "Torpedo-bodied & pelagic · 7", "Flattened & rostrate · 11". `LonjaSectionLabel(text: family.localisedFamilyName)` prints the family name alone; `FamilyGroup` carries `species.length` but the screen never shows it.
- The italic binomial `.bcell .s` under each name (serif 9.5px italic, ink3, centred, line-height 1.2 — e.g. `Epinephelus coioides`, `Lethrinus nebulosus`). `SpeciesTile.scientificName` is populated and documented as "set small and last", but `_SilhouetteTile` never renders it — the tile is silhouette + `displayName` only.
- The overflow cells: `.bcell` with a mono 13px `+ 2` and `.s` "more in Serranidae", and `+ 9` / "more in this family" in the flattened group. The app's `SliverGrid.builder` renders every species with no truncation and no more-cell, so a 11-species family floods the grid.
- The whole "Other zones on this device" block: the `.lab-rule` label, the `.note` paragraph (sans 11.5px ink3) "Rías Baixas — Banco de Cambados · salt · 14 entries. Represa de Jurumirim · fresh · 22 entries.", and its 6-cell `.bgrid` of other-pack species whose `.s` line carries measurement + binomial ("38 mm SHL · Venerupis corrugata", "120 mm CW · Maja squinado", "Piracema · Jurumirim"). The app shows a single pack's families and nothing about other installed packs.
- The trailing `.cite` footnote: 44%-wide 1px ink `.fnrule`, then serif 12px ink2 line with a mono `<sup>1</sup>`, small-caps .06em-tracked `.who` "Galicia", the instrument "Orde do 27 de xullo de 2012, Anexo II · DOG núm. 226" and "checked 2026-06-02". The browse screen carries no citation at all.
- The grid's printed-plate construction: `.bgrid` is `gap:1px; background:var(--rule); border-block:1px solid var(--rule)` — hairline seams between cells and a top and bottom rule across the full grid. The app uses whitespace gaps (`tokens.density.tapGap`) with no seam rules and no grid-edge rules.
- Cell content centring: `.bcell` is `align-items:center` with `.s` `text-align:center`. Every text in the app tile is `TextAlign.start` under `CrossAxisAlignment.start`.

**Misplaced**

- Header order and weight. Mockup: one ruled bar with an 18px serif title. App: `ReferenceScreen` prints `l10n.navReference` ("Reference") in `type.title` — serif 26px/w600 — at the gutter, and then `SpeciesBrowseScreen` prints `l10n.browseByShapeTitle` ("Browse by shape") in the same 26px `type.title` immediately below it. Two stacked 26px serif headings where the mockup has one 18px one, and neither is the mockup's.
- Family label typography. `.lab` is sans 9.5px, w600, `letter-spacing:.2em`, `text-transform:uppercase`, ink3, with a 1px rule running to the margin. The app's `LonjaSectionLabel` uses `type.microLabel` — sans 12.5px, w600, letterSpacing 2 — with a `LonjaRule.block()`, and deliberately prints the text as authored (no upper-casing, per `check_lonja_type.sh` check 6), so the label is larger and mixed-case rather than the small tracked caps of the mockup.
- Species name style. `.bcell .n` is 15px in the Arabic face (or serif 13px for the Latin-script other-zones cells), centred, line-height 1.15, and is explicitly "set larger than the binomial". The app uses `type.uiSmall` — sans 15px, w500, letterSpacing 0.3 — start-aligned, `maxLines: 2` with `TextOverflow.ellipsis`, where the mockup wraps instead of truncating.
- Column count and tile proportion. The mockup is a fixed `repeat(3,1fr)` grid with `min-height:96px` cells and a 36px-tall silhouette that spans the full cell width. The app uses `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 132, childAspectRatio: 0.85)`, so column count floats with width (4 columns on a wide phone, 3 only near 396dp) and the silhouette takes an `Expanded` share of a taller tile rather than a fixed 36px band.
- Silhouette treatment. In the mockup the drawing sits directly on `.bcell` paper, separated from its neighbours only by the 1px grid seam. In the app each silhouette is wrapped in a `DecoratedBox` with `tokens.surfaceSunk` fill and `Border.all(color: tokens.hairline)` on all four sides — a boxed thumbnail per tile instead of a continuous ruled plate, and `LonjaSilhouette` adds its own `LonjaSpace.s3` padding and `tokens.surface` ground inside that box, so the tile has two nested grounds.
- Vertical rhythm between label and grid. `.lab-rule` uses `margin-block: var(--s6) var(--s4)` and `.tight` (`margin-top: var(--s5)`) for every family after the first. The app applies one fixed `top: LonjaSpace.s4, bottom: LonjaSpace.s2` to every family heading, so the first group is not given the extra opening space and subsequent groups are not tightened.

**Extra**

- A second screen title: "Reference" from `ReferenceScreen` above "Browse by shape" — the mockup's bar carries exactly one title.
- A `LonjaListSkeleton` loading state and a `LonjaEmptyState` (headline `browseNoSpeciesHeadline` / body `browseNoSpeciesBody`, with `primary: SizedBox.shrink()` so the empty state has an empty action slot) for both the error and empty cases. The mockup shows no such states.
- A per-tile sunk-panel frame (`tokens.surfaceSunk` + full hairline border) around every silhouette — described above, but it is an element the mockup does not have at all rather than a restyle of one it does.
- `Semantics(button: true, label: tile.displayName)` wrapping each `InkWell` and a `ConstrainedBox(minHeight: tokens.density.tapMin)` — correct for the app, no mockup counterpart (the mockup's `min-height:96px` is the nearest thing).

---
