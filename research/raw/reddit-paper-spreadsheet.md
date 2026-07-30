# Phase 1 Discovery — Trades & Professions Still Running on Paper or Spreadsheets

**Researcher note / methodology caveat (read first):**
Reddit is **hard-blocked** for this agent. Both `WebSearch` domain-filtering on `reddit.com` and `WebFetch` on `reddit.com` / `old.reddit.com` return an explicit block error ("The following domains are not accessible to our user agent"), and `site:reddit.com` queries returned zero Reddit results. **No Reddit evidence appears below, and none was invented.** I substituted equivalent primary sources: profession-specific forums (gCaptain, ODK, iNaturalist, RPLS, AWS, Practical Machinist, Mike Holt, Beesource, Forestry Forum, allnurses, Trawler Forum), trade press, and regulator documents.

Many trade forums are VerticalScope- or Cloudflare-protected and returned **HTTP 403** to `WebFetch`. Where I could not read the page body, the URL and title come from the search index and the finding is explicitly marked **(unverified — from search snippet only)**. Where I actually retrieved and read the thread, it is marked **[VERIFIED FETCH]**.

Searches run: 25. Date of research: 2026-07-27.

---

## TIER A — verified fetches (I read the actual thread/page)

### Professional mariners — proving sea service days for license upgrades
- **Query:** `sea time log book paper spreadsheet track hours mariner` (allowed_domains: forum.gcaptain.com)
- **Source:** gCaptain Professional Mariner Forum | **URL:** https://forum.gcaptain.com/t/sea-service-time/67668 | **Date:** ~Nov–Dec 2023 | **[VERIFIED FETCH]**
- **Paraphrase:** Mariners argue over what legally counts as a "day" of sea service and note that employers just issue letters off payroll records because nobody has the staff to reconstruct actual hours worked, so the mariner's own day-count is the only real record.
- **Points to:** An offline sea-service day ledger that applies USCG day-crediting rules (tonnage thresholds, 8h vs 12h day, underway vs in-port) per hitch and exports a signed-ready summary for the licensing packet.
- **Offline necessity:** The days are earned at sea where there is no usable internet; the record has to be enterable the day it happens, in the wheelhouse, on a personal phone.

### Professional mariners — building their own stability/strength math in Excel
- **Query:** `excel spreadsheet I made stability cargo calculation chief mate ship no internet onboard` (allowed_domains: forum.gcaptain.com)
- **Source:** gCaptain Professional Mariner Forum | **URL:** https://forum.gcaptain.com/t/about-stability-bm-sf-calculations-and-softwares/4351 | **Date:** Jul 2010 – Apr 2011 | **[VERIFIED FETCH]**
- **Paraphrase:** A deck officer spent months hand-building an Excel workbook for bending moment, shear force, GZ/KN curves, trim, GM and draft survey because commercial stability software was either ship-locked or priced beyond reach, and other officers queued up asking for a copy.
- **Points to:** An offline draft-survey / trim-and-stability worksheet app (vessel profile entered once, then per-voyage tank and cargo entry) — the calculation is generic, the vessel constants are the user's own data.
- **Offline necessity:** Done in the cargo office mid-ocean; also the second poster explicitly stalled because he could not finish the work while ashore away from the ship's stability book.
- **Caution:** Anything that outputs a *go/no-go* loading condition edges toward safety-critical liability. Scope it as a worksheet/checker, not an authority.

### Field naturalists / biological recorders — personal species records on paper and in home-made spreadsheets
- **Query:** `no cell service in the field offline notes paper notebook observations` (allowed_domains: forum.inaturalist.org)
- **Source:** iNaturalist Community Forum | **URL:** https://forum.inaturalist.org/t/how-do-you-keep-your-personal-records/18401 | **Date:** ~2021 | **[VERIFIED FETCH]**
- **Paraphrase:** Recorders describe archival-grade hard-bound surveyor notebooks kept since 1977, the Grinnell method of transcribing field notes into formatted species journals, typing notes into Excel after getting home, and one person who built a personal PostgreSQL/PostGIS database to avoid manual entry.
- **Points to:** An offline Grinnell-method field journal — dated locality header, habitat notes, species account entries, sketch space — that lives entirely on device and exports a clean archival text/CSV.
- **Offline necessity:** The whole point of the journal is that it is written *at* the locality, which is by definition rural/backcountry; and the users explicitly want records that outlive any service.

### Field naturalists — the app fails exactly where the work happens
- **Query:** `no cell service in the field offline notes paper notebook observations` (allowed_domains: forum.inaturalist.org)
- **Source:** iNaturalist Community Forum | **URL:** https://forum.inaturalist.org/t/inaturalist-next-with-poor-no-cell-phone-connectivity/55541 | **Date:** Sep–Nov 2024 | **[VERIFIED FETCH]**
- **Paraphrase:** Users in wetlands, conservation areas and abroad report the rewritten app won't let them type a species name they already know when offline, syncs unreliably, and takes ~25 minutes to push 8 records on weak signal — several reverted to the old version for remote trips.
- **Points to:** A pure-local field observation recorder with free-text taxon entry against a bundled taxonomy, zero sync, zero account, and an explicit "export when you get home" step.
- **Offline necessity:** Stated directly by the users: they are standing in a marsh with no bars and cannot record what they are looking at.
- **Data note:** Bundled taxonomy must be a permissively-licensed backbone (e.g. GBIF/Catalogue of Life extracts, ITIS which is US-government) — check licence per source before shipping.

### Field naturalists — building a spreadsheet because the platform gives no personal analytics
- **Query:** `"I built a spreadsheet" OR "made my own spreadsheet" track hive inspections beekeeper club apiary records no phone` (allowed_domains: forum.inaturalist.org, forum.getodk.org, forum.gcaptain.com)
- **Source:** iNaturalist Community Forum | **URL:** https://forum.inaturalist.org/t/my-observation-data-spreadsheet/12410 | **Date:** May 2020 (data since ~2017) | **[VERIFIED FETCH]**
- **Paraphrase:** A user maintained a three-year Excel workbook of monthly counts, species diversity, a "difficulty of finding a new species" metric and per-state breakdowns purely because the platform showed him nothing about himself; multiple others immediately asked for the file.
- **Points to:** An offline personal life-list / effort-analytics companion that ingests an export once and then works forever without a network.
- **Offline necessity:** Weaker here — this one is a *demand* signal (workaround proves want), not an offline-necessity signal. Pair it with the connectivity thread above.

### Beekeepers — hive inspection forms nobody can build
- **Query:** `"I built a spreadsheet" OR "made my own spreadsheet" track hive inspections beekeeper club apiary records no phone`
- **Source:** ODK Forum (Discourse) | **URL:** https://forum.getodk.org/t/beekeeper-need-help/27425 | **Date:** 16–24 Jun 2020 | **[VERIFIED FETCH]**
- **Paraphrase:** An amateur beekeeper wanted a ten-question per-hive visit form feeding a sheet, found JotForm wouldn't integrate and ODK too complex for his skill level, and needed a stranger to hand-build the XLSForm for him over a week.
- **Points to:** A zero-config offline hive-inspection logger: yard → hive → dated inspection with queen seen / brood pattern / stores / mite count / treatment / supers, plus per-hive history.
- **Offline necessity:** Out-apiaries are rural and frequently have no bars; hands are in gloves and sticky, so the interaction must be big-target and instant with no spinner or login.
- **Competition caution:** Beetight/HiveTracks/Apiary Book exist and most are account-based; an offline-only, no-account one is still open. Audience (serious sideliner/commercial beekeepers) plausibly in range, but hobbyists push the count well above 50k.

### Humanitarian / research field enumerators — offline form tooling is genuinely bad
- **Query:** `offline data collection paper forms field crew frustration` (allowed_domains: forum.getodk.org)
- **Source:** ODK Forum (Discourse) | **URL:** https://forum.getodk.org/t/choosing-the-best-offline-form-builder/2381 | **Date:** Jul 2013 | **[VERIFIED FETCH]**
- **Paraphrase:** A research team surveying in the DRC with "almost no internet" gave up on the offline Kobo form builder because bugs wiped prior edits, and ended up hand-editing XML before a longer survey.
- **Points to:** Not a direct app idea for us (this space has ODK/Kobo/CommCare) — it's corroboration that *offline-first field capture is a real, chronically underserved category*.
- **Offline necessity:** Absolute — the work happens where there is no connectivity at all.
- **Verdict:** Use as background, not as a lead. Category is occupied by well-funded NGO tooling.

### Water & wastewater plant operators — the legal paper logbook
- **Query:** `wastewater plant operator daily round sheet clipboard paper log no phones allowed plant forum`
- **Source:** Treatment Plant Operator magazine | **URL:** https://www.tpomag.com/online_exclusives/2014/10/put_it_in_writing_how_to_effectively_use_forms_logs_and_more | **Date:** 6 Oct 2014 | **[VERIFIED FETCH]**
- **Paraphrase:** Plant practice described as hard-bound numbered logbooks filled in ink, preprinted rounds forms and bench sheets on clipboards, spreadsheets for lab data, and dry-erase boards for shift handover — kept because regulators and courts may need to see them.
- **Points to:** An offline rounds/bench-sheet recorder with a fixed daily route (pH, turbidity, flow, tank levels, polymer dose, sludge), per-shift handover notes, and an append-only tamper-evident log.
- **Offline necessity:** Concrete-and-steel process buildings, wet wells and galleries kill signal; many utilities also forbid cloud storage of operational data; and the record must be creatable the instant the reading is taken.
- **Sizing caution:** US licensed water/wastewater operators are >100k, so a niche cut (e.g. small systems <10k population, or lagoon/package-plant operators) is needed to hit the target band.

### Oil & gas lease pumpers — daily gauge sheets in pen
- **Query:** `lease operator pumper daily gauge sheets paper "no cell service" oilfield forum spreadsheet`
- **Source:** Medium (post by GreaseBook founder — vendor-authored, treat as trade-press not user testimony) | **URL:** https://medium.com/@greasebook/excel-pumper-gauge-sheet-templates-and-what-one-oilman-decided-to-do-about-them-44113082a824 | **Date:** 28 Jul 2016 | **[VERIFIED FETCH]**
- **Paraphrase:** Describes the standard independent-operator workflow: the pumper handwrites tank gauges and run tickets on an industry paper gauge sheet and it can take days to a week before the office has accurate numbers.
- **Points to:** An offline lease route app — wells per lease, tank strapping tables, gauge-in/gauge-out, water/oil/gas, run tickets, downtime codes — producing a printable gauge sheet.
- **Offline necessity:** Lease roads and tank batteries in the Permian, Anadarko and Appalachia routinely have no coverage; the pumper is on a ladder in gloves.
- **Caveat:** Vendor blog, and GreaseBook already occupies the *connected* version of this. The unserved slice is the single-owner stripper-well operator who will not pay a subscription. US lease pumpers plausibly 25k–40k — good size fit.

---

## TIER B — real URLs, page body not retrievable (403/402). Treat as leads to re-verify.

### Land surveyors — paper field books still in the truck
- **Query:** `reddit surveyors "field book" paper notes "spreadsheet" still use`
- **Source:** RPLS.com Strictly Surveying forum | **URL:** https://rpls.com/forums/strictly-surveying/field-notes-field-books/ | **Date:** unknown (thread, likely 2010s) | **(unverified — from search snippet only; fetch returned 403)**
- **Paraphrase:** Surveyors describe still keeping field books — sketches, HI/HT, prism type, level runs for FEMA work — sometimes printing part of the job to mark up alongside the data collector, and delivering scanned book pages as PDF to clients.
- **Points to:** An offline digital field book: setup/backsight metadata, dimensioned sketch canvas, level-loop closure check, page-per-day paginated PDF export that looks like a field book.
- **Offline necessity:** Boundary and topo work happens on raw land, in canyons, under canopy; data collectors are proprietary and the phone is the fallback.
- **Sizing:** ~40k–50k licensed surveyors in the US — right at the top of the target band.

### Welding QC — welder continuity logs kept by hand
- **Query:** `welder continuity log 6 month qualification tracking "spreadsheet" shop QC forum how do you track welders`
- **Source:** American Welding Society member forum | **URL:** https://app.aws.org/forum/topic_show.pl?tid=35770 | **Date:** unknown | **(unverified — from search snippet only; fetch returned 403)**
- **Related snippet URLs (also unverified):** https://app.aws.org/forum/topic_show.pl?tid=33587 , https://app.aws.org/forum/topic_show.pl?tid=37198
- **Paraphrase:** QC people discuss that codes require no lapse beyond ~6 months (or 90 days) per process and that keeping each welder's continuity entries current becomes unmanageable once a shop has many welders.
- **Points to:** An offline welder-continuity tracker: welder → qualified process/position/thickness range → dated "welded on this process" ticks → automatic expiry countdown and audit-ready roster print.
- **Offline necessity:** The tick is made in the shop or on a jobsite/pipeline spread with no signal, by a CWI walking the floor; and shops resist putting personnel qualification data in someone else's cloud.
- **Data note:** Do **not** bundle AWS D1.1 / ASME IX text (copyrighted). Ship only user-entered dates and ranges.

### Machinists — the wall chart problem
- **Query:** `practicalmachinist forum "spreadsheet" thread "I made" tap drill chart shop floor no internet`
- **Source:** Practical Machinist | **URL:** https://www.practicalmachinist.com/forum/threads/wall-chart-decimals-tap-sizes.399996/ | **Date:** ~Feb 2022 | **(unverified — from search snippet only; fetch returned 403)**
- **Related:** https://www.practicalmachinist.com/forum/threads/anyone-have-a-tap-chart-with-metric-drill-sizes.264170/ (a member built one in OpenOffice Calc)
- **Paraphrase:** Machinists trade home-made tap/drill/decimal charts as JPEGs, PDFs and Excel files because no off-the-shelf chart has the specials and metric sizes they actually run.
- **Points to:** An offline machinist reference where the *tables are computed from formulas* (thread percent → tap drill, decimal equivalents, thread pitch, feeds/speeds from SFM) rather than copied from a copyrighted handbook.
- **Offline necessity:** Steel-clad shop floors are Faraday cages; hands are oily and the answer is needed at the machine in seconds.
- **Verdict:** Category is crowded with free calculator apps. Only interesting if it goes deep (shop-specific tool library, custom thread specials, per-machine feed override).

### Electricians — home-made NEC sizing spreadsheets circulating on the forum
- **Query:** `electricians spreadsheet I made conduit fill voltage drop calculator no service in the basement` (allowed_domains: forums.mikeholt.com)
- **Source:** Mike Holt's Forum | **URL:** https://forums.mikeholt.com/threads/new-nec-comprehensive-feeder-sizing-excel-spreadsheets.2574071/ | **Date:** unknown (recent thread id) | **(unverified — from search snippet only; fetch returned 403)**
- **Paraphrase:** A member published Google Sheets that size feeders end-to-end — ampacity with deratings, EGC selection, voltage drop and conduit sizing — because no single free tool chains those steps together.
- **Points to:** An offline feeder-sizing *worksheet* that chains the steps and shows its working, rather than another single-purpose calculator.
- **Offline necessity:** Electrical rooms, basements, parking structures and industrial plants have no signal, and the answer is needed with a conduit in hand.
- **Blocker:** NEC tables (310.16, Chapter 9) are NFPA copyright. Cannot bundle. This kills the lead unless the app takes user-entered table values — which nobody will do. **Likely reject on licensing.**

### Beekeepers — the spreadsheet thread
- **Query:** `beekeeping forum "I keep track" hive records "paper" OR "spreadsheet" no signal in the beeyard app`
- **Source:** Beesource Beekeeping Forums | **URL:** https://www.beesource.com/threads/hive-tracking-spreadsheet.309177/ | **Date:** unknown | **(unverified — fetch redirected to a paywall proxy, HTTP 402)**
- **Related (also unverified):** https://beekeepingforum.co.uk/threads/inspection-spreadsheet.49061/ , https://www.beesource.com/threads/beekeeping-record-keeping.341605/
- **Paraphrase:** Beekeepers describe paper hive cards, Google Forms feeding a sheet, dropdown-heavy Google Docs used with a stylus on a tablet, and transcribing notes back at the office after the inspection.
- **Points to:** Same as the ODK beekeeper finding — reinforces it.
- **Offline necessity:** Out-yards, gloves, smoke, and a tablet that must not need a login.

### Loggers / log buyers — printable tally sheets
- **Query:** `tally sheet paper notebook scaling logs record keeping spreadsheet sawmill` (allowed_domains: forestryforum.com)
- **Source:** The Forestry Forum | **URL:** https://forestryforum.com/board/index.php?topic=68693.0 | **Date:** unknown | **(unverified — from search snippet only; fetch returned 403)**
- **Paraphrase:** A log buyer asks the forum for a simple printable tally sheet to take to the landing, and the forum's own answer is a set of web calculators plus paper.
- **Points to:** Offline log-buying tally: species × diameter × length tick sheet, Doyle/Scribner/International board-foot conversion, per-load and per-landowner totals, printable settlement sheet.
- **Offline necessity:** Landings are deep in the woods with no service and the tally is made standing at the truck.
- **Competition:** Timberlog and Tally-I/O already sell exactly this — https://apps.apple.com/us/app/timberlog-timber-calculator/id1667253703 . **Occupied; deprioritise.**
- **Data note:** Doyle, Scribner and International 1/4" log rules are 19th/early-20th-century public-domain formulas — free to implement.

### Amateur astronomers — logging at the eyepiece
- **Query:** `observing log paper notebook red flashlight dark site no internet record eyepiece notes` (allowed_domains: cloudynights.com)
- **Source:** Cloudy Nights | **URL:** https://www.cloudynights.com/forums/topic/627912-observing-log-from-paper-to-voice-recorder-spreadsheet/ | **Date:** unknown | **(unverified — from search snippet only; fetch returned 403)**
- **Related (also unverified):** https://www.cloudynights.com/topic/468009-do-you-keep-an-astronomy-log-notebook/ , https://cloudynights.com/topic/415266-taking-notes-while-observing
- **Paraphrase:** Observers describe ballpoint on damp paper under a red flashlight in a bound composition book, some dictating into a voice recorder and transcribing to a spreadsheet later, and preferring paper because it's still readable decades on.
- **Points to:** A pure red-on-black offline observing log: session (site, seeing, transparency, equipment) → object entries with eyepiece/magnification, a sketch canvas, and a bundled DSO catalogue for one-tap object lookup.
- **Offline necessity:** Dark sites are chosen for being far from towns, i.e. no signal; a white screen destroys 30 minutes of dark adaptation; hands are cold and gloved.
- **Data note:** Strong. Messier, NGC/IC (via the public-domain-ish OpenNGC / SAC 8.1 datasets) and the Yale BSC are freely redistributable — **verify each licence** before bundling.
- **Competition:** SkySafari / Deep-Sky Planner / AstroPlanner exist but are planners; a log-first, red-first, offline-first tool is a narrower slot.

### Hospital nurses — the hand-drawn "brain sheet"
- **Query:** `brain sheet paper report sheet nurses made my own template shift` (allowed_domains: allnurses.com)
- **Source:** allnurses | **URL:** https://allnurses.com/brain-sheet-ed-t704451/ | **Date:** unknown | **(unverified — from search snippet only; fetch returned 403)**
- **Related (also unverified):** https://allnurses.com/share-your-quot-brain-quot-t191104/ , https://allnurses.com/report-sheet-samples-t138662/
- **Paraphrase:** Nurses hand-build their own per-shift paper sheets — often a 12-box hour grid with vitals at the top — and repeatedly say the only good brain sheet is one you made yourself, because no unit's template fits another's.
- **Points to:** A user-designable offline shift sheet: build your own field layout once, then a blank instance per shift, per patient, wiped at end of shift.
- **Offline necessity:** Steel/lead-shielded hospital interiors have poor signal, and the data is PHI that must never leave the device — no account, no cloud, auto-purge.
- **Sizing:** Far too large as "nurses" (millions). Would need a specific cut (e.g. ED charge nurses, hospice/home-health, flight/critical-care transport).

### Boat operators — ship's log kept in a spreadsheet
- **Query:** `commercial fishing logbook paper at sea "no internet" catch record spreadsheet skipper forum`
- **Source:** Trawler Forum | **URL:** https://www.trawlerforum.com/threads/using-spreadsheets-for-a-logbook.54108/ | **Date:** unknown | **(unverified — from search snippet only; fetch returned 403)**
- **Paraphrase:** Owners describe building their own Excel ship's logbook because they want control over which columns exist, rather than accepting a printed log's layout.
- **Points to:** Offline vessel log: engine hours, fuel burn, positions, weather, maintenance intervals derived from hours — a maintenance-by-hours engine that works with no connection.
- **Offline necessity:** Underway, offshore, no signal. Also crosses into commercial-fishing paper logbook requirements (NOAA still mandates paper logbooks for some Southeast permits: https://www.fisheries.noaa.gov/bulletin/clarification-paper-logbook-requirements-southeast-commercial-fishing-permit-holders — unverified snippet).

---

## TIER C — regulator / primary-document evidence (public-domain data confirmed)

### Elevator mechanics — a written machine-room log is legally mandated
- **Query:** `elevator mechanic "no cell service" machine room hoistway paper log write down measurements forum`
- **Source:** Nevada Administrative Code, via Justia | **URL:** https://regulations.justia.com/states/nevada/chapter-455c/elevators/requirements-standards-and-procedures/section-455c-523 | **Date:** current NAC | **(unverified — from search snippet only)**
- **Paraphrase:** Nevada requires every elevator machine room to hold a written log in which each mechanic records the reported trouble, date, time and corrective action for every callback, kept physically in the machine room.
- **Points to:** An offline callback/trouble-log app for elevator mechanics — building → car → dated callback entries, plus route history and a printable machine-room log page.
- **Offline necessity:** Best-in-class. Machine rooms, pits and hoistways in high-rises and basements have zero signal by construction; this is the archetypal "app must work in a Faraday cage" job.
- **Sizing:** ~25k–35k elevator constructors/mechanics in the US — an excellent fit for the target band.
- **Data note:** Ship no ASME A17.1 text (copyrighted). The log fields themselves are from state regulation and are free to model.

### Wildland fire — ICS-214 / Crew Time Report are public-domain forms filled in with a pen
- **Query:** `wildland firefighter ICS-214 unit log paper crew time report handwritten no cell service fireline`
- **Source:** FEMA EMI (US federal, public domain) | **URL:** https://training.fema.gov/emiweb/is/icsresource/assets/ics%20forms/ics%20form%20214,%20activity%20log%20(v3.1).pdf | **Date:** ICS forms v3.1 | **(URL from search index; PDF is a genuine FEMA asset — content not fetched)**
- **Also:** https://ftp.wildfire.gov/public/incident_specific_data/training/MT-BDF/S236/Single%20Resource%20Boss%20Kit/ALL%20-%20ICS-214%20Unit%20Log.pdf | NWCG position standards: https://www.nwcg.gov/positions/wildland-fire-investigation-team-leader/incident-position-description
- **Paraphrase:** Unit leaders, division supervisors and strike-team leaders are required to keep a handwritten ICS-214 activity log plus SF-261 crew time reports for every operational period, and these feed pay and after-action reports.
- **Points to:** An offline ICS-214 + CTR keeper: operational period header, timestamped one-tap activity entries, personnel roster, hours roll-up, PDF that matches the official form for hand-off to the Documentation Unit.
- **Offline necessity:** Total. The fireline has no coverage, the device is in a Nomex pocket, and the entry must be made at the moment it happens.
- **Data note:** ICS/NWCG forms are US-government works — **free to bundle and reproduce commercially.** This is the cleanest licensing story found in this whole sweep.
- **Sizing:** US wildland firefighters in supervisory positions that must keep a 214 — plausibly 20k–50k. Good fit.
- **Evidence gap:** I found the *forms and the requirement*, not practitioners complaining. Needs a follow-up pass on a live wildland-fire community (the old wildlandfire.com "Hotlist" forum is dead — its URLs now return "expired"/"coming soon" placeholders).

### Pesticide applicators — federally required records with no prescribed form
- **Query:** `pesticide application records paper notebook in the sprayer cab required by law farmers spreadsheet`
- **Source:** USDA Agricultural Marketing Service | **URL:** https://www.ams.usda.gov/rules-regulations/pesticide-records | **Date:** current | **(unverified — from search snippet only)**
- **Also:** https://extension.missouri.edu/publications/mp692 (MU Extension guidance)
- **Paraphrase:** Certified private applicators must record brand/product, location, crop, area treated, rate and date for every restricted-use application within 14 days and keep it two years — and USDA explicitly prescribes **no** federal form, so everyone uses a notebook or a home-made spreadsheet.
- **Points to:** An offline RUP spray-record keeper: fields/blocks defined once, then per-application entry with EPA reg number, rate, area, applicator, weather at application, REI/PHI countdown, and a compliant two-year printable record.
- **Offline necessity:** Entered from the sprayer cab in the middle of a field with no coverage, often gloved, and the 14-day rule means it must be captured now.
- **Data note:** The required-field list is US-government and free. **Do not bundle manufacturer product labels** — copyrighted, and label misstatement is a liability trap. Let the user type the product.
- **Sizing:** ~1M certified private applicators in the US — too big unless cut down (e.g. one state's stricter rule set, or a specialty crop like vineyards/orchards).

---

## Explicit "no evidence found" notes

- **Reddit, all queries:** no evidence found — Reddit is blocked at the tool level for this agent. `site:reddit.com` searches returned only Wikipedia, Gumroad and Scribd noise; direct fetches of `reddit.com` and `old.reddit.com` are refused. Any Reddit citation in this document would have been fabricated, so there are none.
- **Wildland fire practitioner forums:** no evidence found — wildlandfire.com and its Hotlist forum now serve expired-domain placeholders.
- **groups.io as a mining ground:** no evidence found — its global search surfaced only Groups.io's own help pages.
- **Arborist / TRAQ paper forms:** no evidence found — every result was vendor marketing (Forest Metrix et al.) or municipal pages; no practitioner thread surfaced.
- **Archaeology context sheets:** one relevant peer-reviewed paper exists (https://www.tandfonline.com/doi/full/10.1080/00934690.2021.1970444, "Digitally Recording Excavations on a Budget", 2021) but Taylor & Francis returned 403, so its contents are **unverified**.
- **Farriers:** searched, and the space is already crowded with commercial apps (Stable Secretary, EquineT, BarnBook). Weak lead.
- **HVAC superheat/subcooling:** searched, and there are already multiple explicitly "100% offline, all refrigerant data built-in" apps on both stores (e.g. https://play.google.com/store/apps/details?id=com.hvactools.superheat_subcool_calculator). **Saturated — reject.**
- **Cave survey:** searched; TopoDroid, Survex, Compass, CaveWhere already own the offline underground-survey workflow. **Occupied — deprioritise.**

## Ranked shortlist coming out of this sweep

1. **Elevator mechanic callback/machine-room log** — best offline necessity, right audience size, legally-defined fields, clean licensing.
2. **Wildland fire ICS-214 + Crew Time Report** — public-domain forms, absolute offline need; needs practitioner-voice evidence.
3. **Mariner sea-service day ledger** — verified pain, USCG rules are public domain, offline by definition.
4. **Land surveyor digital field book** — verified-ish paper workaround, top of size band.
5. **Welder continuity log** — clear unmanageable-spreadsheet pain, no copyright exposure if only dates are stored.
6. **Lease pumper offline gauge sheet** — right size, real paper workflow, incumbent is subscription/cloud only.
7. **Red-light offline astronomy observing log** — excellent offline rationale and public-domain catalogues; partly served by planners.
8. **Water/wastewater rounds & bench sheets** — strong legal-log angle, needs a narrower cut to fit the size band.
