# Phase 1 — Raw Findings (consolidated)

Generated 2026-07-27 by concatenating the 14 per-agent discovery files in `research/raw/`.
Each section below is one agent's lane, written continuously during the search as required by the brief.

## READ FIRST — environment limitations that shaped this corpus

1. **reddit.com is unreachable from this environment.** Verified personally by the main agent:
   `site:reddit.com` queries return only alternativeto.net / dev.to / App Store noise, and WebFetch on
   reddit.com and old.reddit.com is refused. **Zero Reddit URLs appear anywhere in this corpus.**
   Equivalent primary sources were substituted: Discourse JSON APIs (gCaptain, iNaturalist, ODK, GBIF,
   Obsidian, F-Droid), the Stack Exchange API, the HN Algolia API, Apple App Store `?see-all=reviews`
   pages and the iTunes review RSS, the authenticated GitHub REST API, F-Droid search, the eCFR API,
   Google Play storefront search, and government/NGO/regulator documents. Six source types were still covered.

2. **The session WebSearch budget (200 calls) was exhausted partway through.** Agents that ran after that
   point switched to direct primary-source retrieval — WebFetch, curl with a browser UA, `gh api`, and public
   JSON APIs. That is arguably *stronger* evidence than search snippets, which is why most licence findings
   below are marked VERIFIED FETCH rather than sourced from a snippet.

3. **Many trade forums are now behind Cloudflare or Tollbit paywalls** and returned 403/402: beesource,
   hvac-talk, practicalmachinist, homebrewtalk, cruisersforum, arboristsite, controlbooth, birdforum, bto.org,
   wildlabs.net, rpls.com, allnurses, cloudynights, forestryforum, app.aws.org, forums.mikeholt.com,
   trawlerforum, snowpilot.org, taxidermy.net. Google Play listing pages do not render review text to a
   fetcher; Apple's do. Every such case is marked "(unverified — from search snippet only)" in place.

4. Every agent was instructed that fabricating a URL is the worst possible failure, and that
   "no evidence found" is a correct answer. Each file ends with its own dead-end list.

---

## Index

- [store-reviews](raw/store-reviews.md)
- [reddit-paper-spreadsheet](raw/reddit-paper-spreadsheet.md)
- [hackernews](raw/hackernews.md)
- [fdroid-github](raw/fdroid-github.md)
- [forums-stackexchange](raw/forums-stackexchange.md)
- [wishlist-nonreddit](raw/wishlist-nonreddit.md)
- [de-es](raw/de-es.md)
- [pt-id](raw/pt-id.md)
- [hi-ar](raw/hi-ar.md)
- [td-field-outdoor](raw/td-field-outdoor.md)
- [td-industrial-indoor](raw/td-industrial-indoor.md)
- [td-privacy-sensitive](raw/td-privacy-sensitive.md)
- [td-misc-odd](raw/td-misc-odd.md)
- [data-catalogues](raw/data-catalogues.md)

---


# ============================================================
# SOURCE FILE: research/raw/store-reviews.md
# ============================================================

# Phase 1 Discovery — App Store / Google Play review mining

**Assignment:** find 1–3 star reviews from apps that BROKE their offline users.
**Date of research:** 2026-07-27
**Method note:** `play.google.com` listing pages returned no review text to WebFetch, and
`justuseapp.com`, `cruisersforum.com` and `hvac-talk.com` returned 403 / cross-host redirects.
The reliable primary channel was Apple's `apps.apple.com/...?see-all=reviews` pages, which render
real review title + star + reviewer + date + text. Every finding marked **VERIFIED** below was
fetched by me and the review text was present on the page. Findings marked
**(unverified — from search snippet only)** came back in a search result summary and I could not
re-confirm them on the live page; treat those as leads, not evidence.

Searches run: 18 distinct queries (listed inline under each finding, plus the dead-ends at the bottom).

---

## VERIFIED FINDINGS

### HVAC / commercial refrigeration technicians (mechanical rooms, rooftops, crawlspaces)
- **Query:** `reviews "no cell service" "does not work offline" field reference app disappointed` (site: apps.apple.com)
- **Source:** Apple App Store — Fieldpiece Job Link, Ratings & Reviews | **URL:** https://apps.apple.com/us/app/fieldpiece-job-link/id873693898?see-all=reviews&platform=iphone | **Date:** reviews dated Mar 20, May 27, Mar 3 (recent), plus 2018/2022
- **Paraphrase:** Multiple HVAC techs rate it 1 star because it forces a login several times a day and dies in remote/low-signal jobs — one says outright there is no reason the app should need cell service or an account at all to read his probes; another says that without internet it is completely useless.
- **Points to:** A 100% on-device HVAC/refrigeration field companion — PT/superheat/subcooling targets, psychrometrics, charge calc, airflow, electrical, refrigerant property tables (CoolProp is MIT-licensed, commercially usable) — that never asks who you are.
- **Offline necessity:** The job site *is* a basement mechanical room, a walk-in freezer, or a rooftop unit behind steel — the technician is standing exactly where LTE does not reach, holding gauges, with no free hand for a login screen.

### Commercial refrigeration PT-chart users (gap: incumbent is stale and thin)
- **Query:** `hvac-talk OR contractortalk forum app "went to subscription" refrigerant PT chart app "no internet" mechanical room`
- **Source:** Apple App Store — HVAC PT Chart (Carmel Software) | **URL:** https://apps.apple.com/us/app/hvac-pt-chart/id508212589 | **Date:** last app update 19 Feb 2023; reviews 2012, 2016, 2019, 2021
- **Paraphrase:** The most-cited PT chart app has only 8 ratings, was last updated in Feb 2023 (adding R-454B), and its reviews are complaints about layout and a dark-mode bug rather than praise — the category incumbent is essentially abandoned.
- **Points to:** Same as above; confirms the incumbent is weak, not that the niche is served. A modern offline refrigerant/thermo reference has an open field.
- **Offline necessity:** Same physical situation — the tech opens this while standing at the condenser, not at a desk.

### Bird banders / ringers (mist-net stations, ~5k permitted banders in North America)
- **Query:** `bird banding app alpha codes band size offline field station no cell service banders app review`
- **Source:** Apple App Store — Bird Codes (Nemesis Code), Ratings & Reviews | **URL:** https://apps.apple.com/us/app/bird-codes/id500496362 | **Date:** review 03 Nov 2023 (3★) and 29 Mar 2022 (4★); app last updated 26 Sep 2017
- **Paraphrase:** A bander gives 3 stars saying the app hasn't been updated in six years and is woefully behind after numerous taxonomic splits, lumps and renames; another says he relies on it daily but it is out of date and needs the 2014/2016/2021 taxonomy added.
- **Points to:** A maintained offline banding companion — AOS/BBL 4-letter and 6-letter alpha codes, band size by species, BBL status/how-aged/how-sexed codes, molt-cycle terminology, a species-list-by-region filter — all bundled, all public-domain US government data.
- **Offline necessity:** A bird is in your hand and the net run is on a clock; the station is a marsh or a ridge with no bars, and you need the code in under two seconds with one hand.

### Bird banders — confirmation that the sister app is also frozen
- **Query:** same as above
- **Source:** Apple App Store — Band Codes (Nemesis Code) | **URL:** https://apps.apple.com/us/app/band-codes/id509221314 | **Date:** last updated 26 Sep 2017; review 28 Nov 2018
- **Paraphrase:** The free companion app that banders use for band sizes has 4 total ratings and has not shipped a version since 2017; its one review is a bander defending it while banding Neotropical migrants in Costa Rica.
- **Points to:** Confirms both incumbents in this niche are dead; a single well-built app could take the whole category.
- **Offline necessity:** Costa Rican banding stations, boreal MAPS stations — connectivity is not part of the workflow.

### Climbers using route beta at the crag (pattern: "offline" that phones home to check your subscription)
- **Query:** `reviews "no cell service" "does not work offline" field reference app disappointed` (site: apps.apple.com)
- **Source:** Apple App Store — Mountain Project, Ratings & Reviews | **URL:** https://apps.apple.com/us/app/mountain-project/id452308783?see-all=reviews&platform=iphone | **Date:** 14 Jan 2012 (1★)
- **Paraphrase:** A climber travelling in Thailand with no service found his downloaded crag data locked because the app insists on periodically re-validating the subscription online, and calls the offline functions completely useless.
- **Points to:** Not the climbing content itself (user-generated, licensed) but the design principle: any paid offline app that revalidates a licence over the network is broken by definition. Whatever we build must validate a purchase zero times.
- **Offline necessity:** The person is at a limestone crag in another country with no roaming; the whole reason he pre-downloaded was that he knew this.

### Backcountry / off-grid map users — logged out with no way back in
- **Query:** `"Gaia GPS" OR "onX" OR "Avenza" app store reviews 1 star "have to log in" offline maps disappeared no service backcountry 2025`
- **Source:** Apple App Store — onX Backcountry, Ratings & Reviews | **URL:** https://apps.apple.com/us/app/onx-backcountry-trail-gps-app/id1529165366?see-all=reviews | **Date:** 30 Sep 2024 (1★, "Don't ever use if you don't have cell service"); 05 Aug 2022 (2★)
- **Paraphrase:** A user says the app randomly logs you out and you cannot log back in without cell service, so the maps you already downloaded are unreachable; a second says onX's login server crashed on day two and the app simply would not open.
- **Points to:** The strongest single design constraint for this whole project: no account, no session, no token expiry. Also points at a market of people actively looking for account-free replacements for account-gated field tools.
- **Offline necessity:** Reviewer's own handle is "Lost in the wood" — the failure happens precisely at the moment of need.

### Foragers — updates that interrupt you mid-field
- **Query:** `reviews mushroom OR foraging OR tracks identification app "needs internet" "no service" woods offline 1 star update broke` (site: apps.apple.com)
- **Source:** Apple App Store — ShroomID | **URL:** https://apps.apple.com/us/app/shroomid-identify-mushrooms/id1547653790 | **Date:** 20 Jun 2024
- **Paraphrase:** A kayaker/forager complains that app updates log him out and then block him behind onboarding surveys, which he calls really annoying when he is trying to identify something in the woods.
- **Points to:** Reinforces the "no onboarding, no re-auth, first-launch-usable" requirement. Mushroom ID itself is crowded and carries poisoning liability — deprioritise the category, keep the lesson.
- **Offline necessity:** Standing in the woods with a specimen in hand; a survey wall is a hard stop.

### Divers showing a logbook to a dive shop abroad
- **Query:** `reviews scuba diving log OR marine engineer OR merchant marine exam app "needs internet" offline at sea ship no wifi complaint` (site: apps.apple.com / play.google.com)
- **Source:** Apple App Store — Diviac Scuba Diving Logbook | **URL:** https://apps.apple.com/us/app/diviac-scuba-diving-logbook/id930068909 | **Date:** 18 May 2016 (1★); app rated 1.8/5 overall, last version May 2015
- **Paraphrase:** A diver titles her 1-star review "Needs Ability to View Logbook with no Internet Connection" and explains that diving internationally without cell service she cannot show her logbook to the dive operator, so the app loses to a paper log.
- **Points to:** An offline dive logbook / dive-shop-presentable log — but note the niche now has offline options (PADI app logs offline), so this is corroborating evidence of the pattern more than a fresh opening.
- **Offline necessity:** A liveaboard or a shore shop in Indonesia; the operator wants to see your last dive *now*, and you have no roaming.

### Merchant mariners / recreational skippers — COLREGS reference (public-domain text, dormant incumbent)
- **Query:** `cruisersforum sailing app "requires internet" offline COLREGS OR tides OR "navigation rules" complaint`
- **Source:** Apple App Store — Navigation Rules (Calculated Industries) | **URL:** https://apps.apple.com/us/app/navigation-rules/id327936562 | **Date:** last updated 07 Dec 2021 (v4.1.9); reviews 2012–2024
- **Paraphrase:** The $3.99 COLREGS/Inland Rules app has a 4.8 rating over 385 ratings and reviewers call it required reading and excellent study material — but it has not been updated since Dec 2021 and is a flat text dump with search and favourites only.
- **Points to:** An offline rules-of-the-road *trainer* rather than reader: lights-and-shapes recogniser, sound-signal drills, day-shape quizzes, give-way/stand-on scenario practice, built on the USCG-published Navigation Rules text (US federal, public domain).
- **Offline necessity:** You use this at sea, at night, on a boat with no coverage — and increasingly in a licence-exam room where phones must be in airplane mode.

### Aviation/ham hobbyists — content locked behind live membership checks
- **Query:** `reviews ham radio repeater directory OR ARRL app "requires internet" offline no cell coverage complaint 1 star` (site: apps.apple.com / play.google.com)
- **Source:** Apple App Store — ARRL Magazines | **URL:** https://apps.apple.com/us/app/arrl-magazines/id531766442 | **Date:** fetched 2026-07-27; reviews 2017, 2019
- **Paraphrase:** The official ARRL magazine app sits at 1.8/5 across 264 ratings, with reviewers complaining it forgets your reading position, ships updates roughly once a year, and generally performs badly.
- **Points to:** Not a build target (QST content is licensed) — but the 1.8/264 rating is proof that an incumbent serving a small technical membership can be terrible for years without anyone replacing it.
- **Offline necessity:** Hams read this on planes, in field-day tents and at remote repeater sites.

---

## LEADS FROM SEARCH SNIPPETS — NOT RE-CONFIRMED ON THE LIVE PAGE

### Backcountry mapping — Gaia GPS login-while-offline
- **Query:** `"Gaia GPS" OR "onX" OR "Avenza" app store reviews 1 star "have to log in" offline maps disappeared no service backcountry 2025`
- **Source:** search-result summary of Apple/Play/Trustpilot pages | **URL:** https://apps.apple.com/au/app/gaia-gps-mobile-trail-maps/id1201979492?see-all=reviews | **Date:** ~2024–2025 **(unverified — from search snippet only; the US reviews page I fetched showed only a 1★ "Declining" review about track recording, not the login complaint)**
- **Paraphrase:** Users reportedly describe the app refusing to open in the wilderness without a fresh login, and premium members reportedly being unable to log back in, plus offline map libraries needing full re-download after updates.
- **Points to:** Same design constraint (never require a session), and a specifically angry, specifically identifiable user group.
- **Offline necessity:** Trailhead, no bars, paid app refuses to open.

### Surveyors / foresters using Avenza — download caps and broken map opening
- **Query:** `Avenza Maps app reviews "requires" login offline surveyors forestry complaint account`
- **Source:** search-result summary | **URL:** https://apps.apple.com/us/app/avenza-maps-offline-mapping/id388424049?see-all=reviews&platform=iphone | **Date:** ~Dec 2025 **(unverified — from search snippet only; justuseapp.com mirror returned HTTP 403)**
- **Paraphrase:** Reviewers reportedly dropped to 1 star after a December 2025 update stopped legally purchased government map sheets (e.g. Vicmaps) from opening, and after the Plus tier was hard-capped at 20 map downloads a year.
- **Points to:** Offline georeferenced-PDF map reading is a paid, professional need being squeezed — adjacent, but map rendering is a heavy lift and the data is per-jurisdiction.
- **Offline necessity:** Forestry cruising and cadastral survey happen in stands and paddocks with no coverage; the map was bought precisely to work there.

### Cruising sailors — apps that "phone home" defeating offline charts
- **Query:** `cruisersforum sailing app "requires internet" offline COLREGS OR tides OR "navigation rules" complaint`
- **Source:** Cruisers & Sailing Forums thread titled "Offline maps are useless with apps that phone home" | **URL:** https://www.cruisersforum.com/forums/f121/offline-maps-are-useless-with-apps-that-phone-home-288930.html | **Date:** ~Aug 2024 **(unverified — URL appeared in search results but the site returned HTTP 403 to my fetch, so I could not read the posts)**
- **Paraphrase:** The thread title alone states the pattern, and the search summary indicates a cruiser abandoned the Navionics mobile app because it periodically tried to contact home during extended remote cruising.
- **Points to:** Offshore sailors are a nameable, findable, vocal audience for genuinely airplane-mode software.
- **Offline necessity:** Mid-ocean. There is no network, full stop, for weeks.

### Wetland delineators / environmental consultants — offline-first is the whole product
- **Query:** `wetland delineation app offline National Wetland Plant List indicator status hydric soil field app complaints no signal`
- **Source:** Ecobot product site (vendor, not a review) | **URL:** https://ecobot.com/ | **Date:** current **(vendor marketing, not user evidence)**
- **Paraphrase:** The one serious product in this space markets itself on offline capture across all nine USACE regional supplements with regional indicator status and hydric soil indicators built in — i.e. it is enterprise-priced software validating that the need is real.
- **Points to:** A cheap, single-practitioner offline field reference: National Wetland Plant List indicator status by region, USDA hydric soil indicator keys, USDA PLANTS species data — all US federal public domain.
- **Offline necessity:** The work is literally done standing in a swamp; and the delineator has a data form to fill in a specific order under a permit deadline.
- **Caveat:** I found NO user-review evidence of an app breaking here. This is inference, not a review finding. Needs its own validation pass.

---

## DEAD ENDS (recorded so we do not repeat them)

- `play store review "used to work offline" "now requires internet" app update 1 star` — **no evidence found**; returned Google support pages only.
- `plant identification app reviews "requires internet" offline "no longer works"` — **no primary evidence found**; results were entirely SEO listicles (mobileappdaily, citycacti, snappit) which I ignored per the rules.
- `reddit "app used to work offline" update "now requires an account" angry review` — **no evidence found**; returned Reddit's own login-wall story instead.
- `site:reddit.com app "worked offline" "now needs internet" ruined update field work` — **no evidence found**.
- `reddit "offline" app "went subscription" ruined professionals "I just want" reference app no internet basement` — **no evidence found**.
- `NIOSH Pocket Guide app discontinued industrial hygienists offline chemical hazard app complaints` — niche is **already served**: the official CDC/NIOSH Mobile Pocket Guide (https://apps.apple.com/us/app/niosh-mobile-pocket-guide/id1450966582) works offline. Skip.
- `wildland firefighter IRPG app "no longer" OR "requires internet"` — niche is **already served**: the IRPG App (https://play.google.com/store/apps/details?id=com.irpg) is fully offline with the 2025 edition. Skip.
- `celestial navigation app review "requires internet" sight reduction almanac offline sailors complaint` — niche is **already served**: several offline perpetual-almanac apps exist (Celestial Nav, Celestial Navigation 360, open-source Celeste). Skip.
- `reviews electrician OR welder OR machinist calculator app "requires internet"` — **saturated**; a wave of 2025-era welding/machinist calculator apps all advertise "no internet, no account" as their headline feature. Skip.
- `reviews beekeeping OR hive OR livestock record app "requires internet"` — **saturated**; at least six 2025-vintage beekeeping apps advertise local-first SQLite and offline logging. Skip.
- `reviews caving OR cave survey OR mine rescue app "no signal underground"` — Cave09 already advertises full offline cave mapping; no review complaints surfaced. **No evidence found.**
- `reviews forestry timber cruise OR soil Munsell OR geology field app "requires internet"` — mostly already offline (USFS FScruiser, SilvaCruise, SoilHue on-device). **No evidence found.**
- `reviews speech therapy OR ABA data collection app "requires internet" school wifi offline privacy` — TallyFlex/ABA Matrix already ship offline session workflows. **No evidence found.**
- `reviews FAR AIM OR "A&P mechanic" reference app "requires internet"` — **saturated**; every FAR/AIM app advertises full offline access. Skip.
- `sign language dictionary app ASL offline reviews subscription requires internet` — real paywall complaints exist but the underlying asset is filmed video, which is not public-domain. Skip on licensing.

## Cross-cutting conclusion from the review corpus

The single most repeated 1-star sentence across every category I mined is not "add offline mode" — it is
**"why does this need an account?"** Three independent, dated, verified reviews (Fieldpiece Mar/May,
onX Backcountry Sep 2024, ShroomID Jun 2024) describe the same failure: the data was already on the
phone, and a session/login/survey wall stood between the user and it at the exact moment of need.
Any app we build must have **zero accounts, zero licence revalidation, zero onboarding gates**, and must
be fully usable on first launch in airplane mode. That is not a feature; per these users it is the product.


# ============================================================
# SOURCE FILE: research/raw/reddit-paper-spreadsheet.md
# ============================================================

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


# ============================================================
# SOURCE FILE: research/raw/hackernews.md
# ============================================================

# Hacker News mining — Phase 1 discovery (offline-first, small-audience app leads)

Method: `hn.algolia.com/api/v1/search` JSON API (stories + comments) plus `api/v1/items/<id>` to read
whole threads. ~27 distinct queries run. Every URL below was returned by the API in this session.
Where I am inferring an audience size or a licence I say so explicitly — I did not verify user counts.

---

### Minority / sign-language offline dictionaries
- **Query:** `"sign language" app`
- **Source:** Hacker News comment | **URL:** https://news.ycombinator.com/item?id=32302151 | **Date:** 2022-08-01
- **Paraphrase:** A developer says he built an offline mobile dictionary for New Zealand Sign Language ~2012 because no app existed, using dictionary data already compiled by a university Deaf Studies research unit.
- **Points to:** A fully-offline dictionary/phrasebook for one specific small language where an academic institution has already produced the lexicon (signs, images, video stills, grammar notes).
- **Offline necessity:** Deaf users look up a sign mid-conversation, in shops, classrooms and hospitals where they cannot wait for a load; the corpus is small enough to ship whole so there is no reason to ever hit a network.
- **Licence caution:** in the follow-up thread the same author states the NZSL data was CC-BY-NC-SA — **NC blocks commercial use**. Any real build needs a differently-licensed corpus.

### Offline dictionaries generally (Wiktionary-derived)
- **Query:** `"Why I built a dictionary app"`
- **Source:** Hacker News story (533 pts, 177 comments) | **URL:** https://news.ycombinator.com/item?id=32300466 | **Date:** 2022-08-01
- **Paraphrase:** The author's whole motivation is that mainstream dictionary apps are online-only, ad-stuffed and forget what you looked up; in the thread other commenters describe building offline dictionaries for Pashto (no app existed) and Spanish from Wiktionary dumps.
- **Points to:** Offline dictionary + morphology/conjugation engine for one under-served language, built on a Wiktionary/Wikidata dump (CC BY-SA — commercial-OK with attribution).
- **Offline necessity:** Learners and diaspora speakers use these abroad, on transit, and on cheap data plans; a dictionary that spins is a dictionary you stop using.

### Humanitarian / conservation field data collection (ODK-class, but serverless)
- **Query:** `"ODK Collect"` and `KoboToolbox`
- **Source:** Hacker News story thread (49 pts, 17 comments) | **URL:** https://news.ycombinator.com/item?id=17161550 | **Date:** 2018-05-26
- **Paraphrase:** Real users in the thread describe an NGO running public-health surveys in DR Congo on phones plus a battery pack, and a Western Australian turtle-conservation programme that captured ~12k tracks/nests over ~2k survey hours with ODK; one commenter objects that field staff often prefer paper and re-key at home because unlocking, PINs and touch entry are worse in the field.
- **Points to:** A no-server, no-account offline field-recording app for one specific survey protocol (nest counts, transects, ringing, quadrats) with hardened one-thumb entry and plain-file export.
- **Offline necessity:** Beaches, forests and rural clinics have no coverage at all; the existing tools assume a server you must stand up and sync to.

### Nonprofit data collection — existing tools are disliked
- **Query:** `KoboToolbox`
- **Source:** Ask HN | **URL:** https://news.ycombinator.com/item?id=15003940 | **Date:** 2017-08-13
- **Paraphrase:** A nonprofit tech person asks what data-collection software to use and reports KoBoToolbox is "mostly great" but buggy, with poor Android UX, awkward export and no way to amend a submission.
- **Points to:** A single-purpose offline form/record app that fixes exactly those complaints (edit after submit, sane export) without the server half.
- **Offline necessity:** The whole category exists because enumerators work where there is no network.

### Amateur radio portable operating (POTA / SOTA activators)
- **Query:** `"Parks on the Air"`
- **Source:** Hacker News story (112 pts) | **URL:** https://news.ycombinator.com/item?id=41913057 | **Date:** 2024-10-22
- **Paraphrase:** A large HN thread about Parks on the Air, where hams drive to a park, set up a temporary low-power station and try to log 10+ contacts; several commenters describe doing this most weekends while camping.
- **Points to:** An offline activation logger — UTC clock discipline, park/summit reference, Maidenhead grid, dupe checking, band/mode rules, ADIF + Cabrillo export by file share.
- **Offline necessity:** The activity is defined by being in a park or on a summit; cell coverage there is unreliable-to-absent and the log must never be lost.

### Someone is already scratching this itch (unfinished)
- **Query:** `"amateur radio" logging`
- **Source:** Hacker News comment on "Ask HN: What are you working on? (March 2025)" | **URL:** https://news.ycombinator.com/item?id=43535590 | **Date:** 2025-03-31
- **Paraphrase:** A commenter says he is building yet another ham logging tool specifically for hunting POTA/SOTA activators because the million existing ones do not fit that workflow.
- **Points to:** Confirms the niche is felt but under-tooled; the *activator* side (offline) is the part that must not need a network.
- **Offline necessity:** As above — logging happens at the operating position, in the field.

### Personal-use ham logger, never productised
- **Query:** `"amateur radio" logging`
- **Source:** Hacker News comment on "Ask HN: Have you created programs for only your personal use?" | **URL:** https://news.ycombinator.com/item?id=31024866 | **Date:** 2022-04-14
- **Paraphrase:** A ham wrote his own minimal CLI contact logger because every existing program involved too much clicking and selecting.
- **Points to:** Speed-first offline logging UI (one-hand, glove-friendly, no modal dialogs) as the actual differentiator.
- **Offline necessity:** Logging is done mid-QSO with no time and often no signal.

### Celestial navigation / sight reduction for offshore sailors and cadets
- **Query:** `"celestial navigation"`
- **Source:** Hacker News story (114 pts) | **URL:** https://news.ycombinator.com/item?id=42657208 | **Date:** 2025-01-10
- **Paraphrase:** A USNI piece argues ships must keep practising celestial navigation; HN commenters discuss doing sight reduction at sea with a sextant plus a calculator, link to nautical almanac resources, and note usable second-hand sextants go for $100–150.
- **Points to:** An offline sight-reduction workbook: almanac ephemeris, sun/star/moon/planet sights, running fix, plotting sheet, star finder, practice sights with error grading.
- **Offline necessity:** Mid-ocean there is no data at all, and the entire point of the skill is functioning when GPS/comms are denied or dead.
- **Data note (unverified licence, but likely fine):** US Naval Observatory / NGA sight-reduction publications are US-Government works and typically public domain — must be confirmed before building.

### Teaching / learning inside prisons
- **Query:** `offline` (tags=ask_hn)
- **Source:** Ask HN | **URL:** https://news.ycombinator.com/item?id=11189320 | **Date:** 2016-02-28
- **Paraphrase:** A volunteer teaching incarcerated young adults asks how to teach web design and programming when the only hardware is old MDM-managed iPads with zero internet; commenters point at analogous prison programmes and say everything must be local-only.
- **Points to:** A completely self-contained learn-to-code / vocational-skill app: bundled lessons, local runtime, local checker, no account, no network permission at all.
- **Offline necessity:** Correctional facilities forbid internet outright; an app that even *attempts* a connection is not installable.

### Offline drill/practice apps for a niche skill (proof the category lands)
- **Query:** `offline` (tags=show_hn)
- **Source:** Show HN (369 pts, 169 comments) | **URL:** https://news.ycombinator.com/item?id=44498296 | **Date:** 2025-07-08
- **Paraphrase:** OffChess ships ~100k chess puzzles entirely on-device; commenters say they wanted it for an eight-hour flight and for places with no signal, and note Lichess only lets you cache ~50 puzzles offline.
- **Points to:** The same shape applied to an under-served discipline — Go tsumego, bridge bidding, shogi tsume, Morse/CW head-copy, aviation oral-exam drills — where a large public-domain problem set exists.
- **Offline necessity:** People drill in exactly the dead zones: planes, subways, waiting rooms, bathrooms; the incumbents deliberately cripple offline caching.

### Single-trail / single-route offline companion
- **Query:** `offline` (tags=show_hn)
- **Source:** Show HN (475 pts, 141 comments) | **URL:** https://news.ycombinator.com/item?id=33420852 | **Date:** 2022-11-01
- **Paraphrase:** A dev shipped an offline-ready companion for one long-distance hiking trail; in the comments one person calls AllTrails putting offline maps behind a paywall "downright evil" on safety grounds, and another says he is building an equivalent for adventure-motorcycling trip planning.
- **Points to:** Deep, curated, offline companion for **one** named long trail / pilgrimage route / paddling route — huts, water sources, resupply, permits, elevation, bail-out points — as a bundled dataset, not a map subscription.
- **Offline necessity:** On the trail there is no signal, and the map is the safety item; the incumbents' business model actively withholds it.

### Field/off-grid reference: no LLM, deterministic search
- **Query:** `"plant identification" offline`
- **Source:** Show HN (49 pts) | **URL:** https://news.ycombinator.com/item?id=46406486 | **Date:** 2025-12-27
- **Paraphrase:** A Show HN for an offline-first modular field computer (offline maps, plant ID, survival reference) drew objections that you should not put an LLM anywhere near life-or-death lookups and should ship a full-text search index instead.
- **Points to:** A curated, deterministic offline reference for a specific field domain — searchable, citable, no generation — which is exactly the fiddly, long-tail work nobody wants to do.
- **Offline necessity:** The user is off-grid by definition; also a hallucination-free requirement rules out any cloud model.

### E-ink / off-grid reference wishlist
- **Query:** `"plant identification" offline`
- **Source:** Hacker News comment on "Off-Grid Cyberdeck with RPI and Pelican Case" | **URL:** https://news.ycombinator.com/item?id=31404731 | **Date:** 2022-05-17
- **Paraphrase:** A commenter lists what he wants on a low-power offline device: Wikipedia, an emergency medical handbook, and plant identification, because there is nothing good for no-connectivity scenarios.
- **Points to:** Bundled offline reference packs for a specific outdoors context.
- **Offline necessity:** The stated scenario is "no internet available at all".

### Apps actively destroy their own offline cache on bad signal
- **Query:** `"airplane mode" app`
- **Source:** Hacker News comment on "Should we design for iffy internet?" | **URL:** https://news.ycombinator.com/item?id=44304255 | **Date:** 2025-06-17
- **Paraphrase:** A commenter says apps are more usable in airplane mode than on a weak connection, because a bad connection makes them wipe cached data trying and failing to refresh, and cites Spotify on the subway.
- **Points to:** Positioning: "never talks to a network" is a *feature* users can feel, not just a spec line.
- **Offline necessity:** Weak signal is worse than no signal for any app that assumes connectivity.

### Bad connectivity wipes local data (second, independent report)
- **Query:** `"airplane mode" app`
- **Source:** Hacker News comment on an RSS-reader thread | **URL:** https://news.ycombinator.com/item?id=47483245 | **Date:** 2026-03-22
- **Paraphrase:** Same complaint from a different user: with no connection apps serve cached data, but with a *bad* connection they throw the cache away trying to refresh.
- **Points to:** Corroborates the above; strengthens the "no network code path at all" design stance.
- **Offline necessity:** Same.

### Structural-signal evidence: places with genuinely zero coverage
- **Query:** `"no cell signal"`
- **Source:** Hacker News comment on "SMS 2FA is not just insecure, it's also hostile to mountain people" | **URL:** https://news.ycombinator.com/item?id=43988378 | **Date:** 2025-05-14
- **Paraphrase:** Thread and comment describe people who simply cannot receive an SMS where they live/work, including office buildings whose coated windows block cell signal.
- **Points to:** Any tool aimed at mountain/rural/indoor-industrial users must assume zero connectivity, including for onboarding.
- **Offline necessity:** These users cannot even complete a signup flow, let alone use a synced app.

### Rural school / locked-down student network
- **Query:** `"no cell signal"`
- **Source:** Hacker News comment on a student-device-monitoring thread | **URL:** https://news.ycombinator.com/item?id=42379916 | **Date:** 2024-12-10
- **Paraphrase:** A school IT person says student internet is content-inspected with a mandatory root certificate and there is no cell signal because the school is rural, so the filtered school network is the only option.
- **Points to:** Classroom tools that install once and never call out — nothing to whitelist, nothing to inspect, nothing to break.
- **Offline necessity:** Locked-down/filtered network plus no cellular fallback.

### Teachers building their own offline tools
- **Query:** `offline` (tags=ask_hn)
- **Source:** Hacker News post | **URL:** https://news.ycombinator.com/item?id=46353359 | **Date:** 2025-12-22
- **Paraphrase:** A teacher describes making single-file HTML tools that run offline with no backend for their own classroom productivity.
- **Points to:** A packaged offline classroom toolkit for one subject/level (seating, random pairing, rubric scoring, timers with subject-specific content) that survives school firewalls.
- **Offline necessity:** School networks are filtered and unreliable; teachers cannot pause a lesson for a spinner.

### Student pilots / ground school
- **Query:** `ForeFlight`
- **Source:** Show HN | **URL:** https://news.ycombinator.com/item?id=45536776 | **Date:** 2025-10-10
- **Paraphrase:** A dev posts an all-in-one toolkit built while doing private-pilot training and explicitly says it is not trying to be ForeFlight or Garmin Pilot.
- **Points to:** An offline student-pilot study/checkride companion (E6B, weight & balance, FAR/AIM search, oral-exam question bank) — the training half, not the navigation half.
- **Offline necessity:** Cockpit and hangar have no data; more importantly checkride prep and practical exams are done device-locked/no-internet. **Auto-reject anything using live weather or live charts.**
- **Corroborating post:** https://news.ycombinator.com/item?id=46081502 (2025-11-28) — another pilot shipping self-built aviation calculators for the same reason.

### Long trips with no connectivity at all
- **Query:** `offline` (tags=ask_hn)
- **Source:** Ask HN | **URL:** https://news.ycombinator.com/item?id=8125375 | **Date:** 2014-08-02
- **Paraphrase:** Someone going to Africa for five weeks with very limited connectivity asks how to take enough content offline.
- **Points to:** "Pack-before-you-go" bundles — the app should be complete on install, with zero first-launch download.
- **Offline necessity:** The trip *is* the offline period; anything not pre-loaded is unavailable for weeks.

### Extended outage / resilience audience
- **Query:** `offline` (tags=ask_hn)
- **Source:** Ask HN (156 pts, 132 comments) | **URL:** https://news.ycombinator.com/item?id=33017733 | **Date:** 2022-09-29
- **Paraphrase:** A large thread asking what offline resources to keep for internet outages; answers centre on Kiwix, OsmAnd and other fully-local tools.
- **Points to:** Curated offline reference packs; also a distribution channel (this audience actively shares such apps).
- **Offline necessity:** The premise of the thread is that the network is gone.
- **Related, weaker:** https://news.ycombinator.com/item?id=30507155 (2022-03-01), same question, small thread.

### Remote work with no internet for a week
- **Query:** `offline` (tags=ask_hn)
- **Source:** Ask HN (58 pts, 87 comments) | **URL:** https://news.ycombinator.com/item?id=37733904 | **Date:** 2023-10-02
- **Paraphrase:** Someone heading to "the middle of nowhere" asks how to work productively with no connectivity for a week.
- **Points to:** Offline reference/documentation bundles for a specific profession.
- **Offline necessity:** Explicit — no connection for the whole period.

### Mesh / off-grid comms community (adjacent, mostly auto-reject)
- **Query:** `Meshtastic`
- **Source:** Hacker News comment | **URL:** https://news.ycombinator.com/item?id=48037042 | **Date:** 2026-07-24
- **Paraphrase:** A user describes running a Meshtastic node and joining a regional mesh community for beginner off-grid comms.
- **Points to:** A real, findable, small, hardware-owning offline audience — but the messaging use-case itself is comms/sync and therefore out of scope.
- **Offline necessity:** Genuine, but the app category conflicts with the "no sharing/community" rule; only useful as an *audience* to sell an offline reference/planning tool to.

### Ambient corroboration: offline-only tools do get real HN traction
- **Query:** `offline` (tags=show_hn)
- **Source:** Show HN listings | **URL:** https://news.ycombinator.com/item?id=48529990 | **Date:** 2026-06-14
- **Paraphrase:** Top of the "offline" Show HN list (712 pts) is a tool that packages a whole site into a single binary for offline viewing — offline-only utilities reliably reach the HN front page.
- **Points to:** Launch channel validation rather than a niche.
- **Offline necessity:** n/a (channel evidence).

---

## Explicit negatives / no-evidence notes

- **Query:** `KoboToolbox ODK offline data collection` (multi-term) — **no evidence found** (Algolia returned 0 hits; multi-word queries are AND-ish, had to split them).
- **Query:** `offline field` scoped to story 45333021 ("Why haven't local-first apps become popular?") — **no evidence found** (0 hits inside that thread).
- **Query:** `wildland firefighter` — thin: only news stories about the profession, **no evidence found** of anyone wanting/building an offline tool for them on HN. The niche may still be real; HN is just not where they talk.
- **Query:** `cave survey caving` — **no usable evidence found**; hits were about caving as a hobby and one comment on cave-survey instruments (https://news.ycombinator.com/item?id=30672722, 2022-03-14) noting surveyors still use tape/compass/laser rather than software. Weak but not nothing.
- **Query:** `search and rescue offline map` — **no usable evidence found** (results were about mountain-rescue callouts and GNSS, not tooling gaps).
- **Query:** `"community health worker"` — **no evidence found** of a tooling gap on HN; only policy/salary discussion.
- **Query:** `"no good offline"` — five hits, all about mainstream categories (git UI, note outliners, camera DVR); nothing niche enough to use.

## Rejected on the brief's own rules
- Meshtastic/mesh messaging, offline SOS (https://news.ycombinator.com/item?id=43551767, 2025-04-01) — comms/sharing + safety-critical liability.
- Offline LLM assistants (multiple Show HNs) — generic, and the Waycore thread shows the community itself objects to LLMs for field-critical lookups.
- Offline note/kanban/journal/budget apps — explicitly excluded generic categories; they dominate the `offline` Show HN list.
- Anything built on live spots/prices/weather (POTA *hunting* spots, aviation weather, transit times).


# ============================================================
# SOURCE FILE: research/raw/fdroid-github.md
# ============================================================

# Phase 1 Discovery — F-Droid & GitHub mining

Researcher note on method: F-Droid category/search pages were fetched directly. GitHub facts (stars,
last push date, archived flag, license, issue titles/dates) were pulled from the **authenticated
GitHub REST API via `gh`**, so star counts and dates below are real values read at 2026-07-27, not
snippets. Anything I did *not* retrieve myself is explicitly marked `(unverified — from search
snippet only)`.

---

## PART A — ABANDONED-BUT-LOVED (proven demand, vacated slot)

### Offline tide & tidal-current prediction (sea kayakers, clam/shellfish diggers, surfcasters, mudflat walkers)
- **Query:** `gh api search/repositories q="xtide in:name,description stars:>2"`
- **Source:** GitHub API | **URL:** https://github.com/manimaul/mxtide-android | **Date:** last push 2020-03-08 (read 2026-07-27)
- **Paraphrase:** "MX Mariner Tides", an XTide-based Android tide app with a live Play Store listing (`com.mxmariner.tides`), stopped receiving commits in March 2020 and still has 10 open issues.
- **Points to:** A modern offline tide + tidal-current app that computes predictions locally from harmonic constants, for any station, years ahead, with no network.
- **Offline necessity:** The moment you need a tide height you are standing on a beach, a mudflat, a jetty or in a kayak — the exact places with no bars.

### Same slot, users still asking after abandonment
- **Query:** `gh api repos/manimaul/mxtide-android/issues?state=all`
- **Source:** GitHub API | **URL:** https://github.com/manimaul/mxtide-android/issues/23 | **Date:** opened 2021-10-01, still open
- **Paraphrase:** A user filed a "Tide Widget" request 18 months *after* the last commit; another asked for "Show last location Details by default" in April 2022 — people kept using and requesting features on a dead app.
- **Points to:** Same as above, plus a home-screen tide widget as a headline feature.
- **Offline necessity:** A widget that renders today's curve with zero network calls is the whole value proposition.

### Predecessors in the same slot, all dead
- **Query:** `gh api search/repositories q="xtide in:name,description"`
- **Source:** GitHub API | **URL:** https://github.com/manimaul/MX-Tides | **Date:** last push 2020-02-07 (9 stars)
- **Paraphrase:** The legacy Android XTide app is dead; its iOS sibling https://github.com/manimaul/MX-Tides-iOS has not been touched since 2013-11-01, and https://github.com/shralpmeister/shralptide (iPhone XTide port) since 2012-01-08.
- **Points to:** A cross-platform Flutter tide app is the obvious unfilled successor — every prior attempt was single-platform and single-maintainer.
- **Offline necessity:** Same; also these were all built offline-first because XTide is a local computation, not a web service.

### F-Droid's only tide app is one country
- **Query:** https://search.f-droid.org/?q=tide&lang=en
- **Source:** F-Droid search | **URL:** https://search.f-droid.org/?q=tide&lang=en | **Date:** retrieved 2026-07-27
- **Paraphrase:** The single tide result in all of F-Droid is "NZ Tides" (`com.palliser.nztides`), "Tide table for New Zealand" — one developer solved it for his own coastline and nobody generalised it.
- **Points to:** A worldwide offline tide app; the "scratch my own coastline" pattern proves the itch and proves nobody did the 2-month general version.
- **Offline necessity:** New Zealand's coast is exactly where signal ends; that is why he built it offline.

### Data licence for the above — genuinely permissive for the US, mixed elsewhere
- **Query:** `XTide harmonics free tcd NOAA public domain non-free harmonics restrictions`
- **Source:** flaterco.com (XTide) via web search | **URL:** https://flaterco.com/xtide/harmonics.html | **Date:** ongoing (unverified — from search snippet only, page not fetched directly)
- **Paraphrase:** XTide ships a *free* harmonics file built from NOAA data (US waters, public domain) and a separate *non-free* file for UK/NL that has not been updated since 2011; a newer TICON-4-based set is CC BY 4.0.
- **Points to:** Ship US + TICON-4 stations commercially; be explicit that UK/NL/HO data is off-limits. Licence homework is part of why nobody built it.
- **Offline necessity:** Harmonic constants are a few hundred KB per region — bundling them is trivial, which is why the whole app can be airplane-mode-native.

### F-Droid apps whose upstream repos died (systemic signal)
- **Query:** `github archived "this app is no longer maintained" F-Droid offline app users fork request`
- **Source:** GitLab (fdroiddata issue tracker) | **URL:** https://gitlab.com/fdroid/fdroiddata/-/issues/3366 | **Date:** issue is open, undated on page
- **Paraphrase:** An F-Droid maintainer audit found roughly 286 app source repos archived and 19 deleted — close to 10% of the whole catalogue is orphaned.
- **Points to:** Not one app idea but a hunting ground: F-Droid's archive is a list of "someone shipped this, users installed it, then it died".
- **Offline necessity:** n/a — meta-signal.

### OpenTracks — loved, but fled GitHub
- **Query:** `gh api search/repositories q="offline android archived:true stars:>150"`
- **Source:** GitHub API | **URL:** https://github.com/OpenTracksApp/OpenTracks | **Date:** archived, last push 2025-08-24, 1,398 stars
- **Paraphrase:** The best-known privacy-first offline GPS track recorder archived its GitHub repo and moved to Codeberg; 1.4k stars sit on a read-only page.
- **Points to:** Confirms a large, motivated offline-fitness audience but the slot is *occupied* (project alive elsewhere) — do not build a track recorder.
- **Offline necessity:** Its selling point is recording without any account or upload.

### Analog darkroom timing — one 2011 Android attempt, nothing since
- **Query:** `gh api search/repositories q="darkroom timer in:name,description stars:>3"`
- **Source:** GitHub API | **URL:** https://github.com/mikewebkist/DarkroomTimer | **Date:** last push 2011-03-23 (4 stars)
- **Paraphrase:** The only Android darkroom timer on GitHub is fifteen years stale; the active darkroom-timer projects (e.g. https://github.com/lo1ol/DarkroomTimer, 35 stars, 2026-04-19) are all *hardware* builds, not phone apps.
- **Points to:** A red-safelight film/print app: f-stop enlarger timer, dev/stop/fix step sequencer, dilution and push/pull calculator, chemical-exhaustion log.
- **Offline necessity:** Darkrooms are basements and windowless bathrooms with no signal, you are in the dark with wet hands, and a spinner or a login is physically impossible to deal with.

---

## PART B — CONSPICUOUSLY MISSING FROM F-DROID (absence is informative)

Every line below is a search I actually ran on `search.f-droid.org` on 2026-07-27.

### Maritime / sailing — literally zero apps
- **Query:** https://search.f-droid.org/?q=sailing&lang=en
- **Source:** F-Droid search | **URL:** https://search.f-droid.org/?q=sailing&lang=en | **Date:** 2026-07-27
- **Paraphrase:** "sailing" returns no results at all; "sailing marine nautical" also returns nothing, and the Navigation category's 6 pages are entirely OSM/transit/hiking with no marine app.
- **Points to:** A whole professional-and-hobby vertical (mariners) has no FOSS mobile presence — see Part C for the specific maritime concepts.
- **Offline necessity:** Off soundings there is no cell service at all, and satellite data is metered by the megabyte.

### Bat / ultrasonic bioacoustics — zero apps
- **Query:** https://search.f-droid.org/?q=bat+detector&lang=en
- **Source:** F-Droid search | **URL:** https://search.f-droid.org/?q=bat+detector&lang=en | **Date:** 2026-07-27
- **Paraphrase:** No bat-detector or ultrasonic-recording app exists in F-Droid.
- **Points to:** An on-device bat-call recorder/classifier (see the BatDetect2 note in Part C).
- **Offline necessity:** Bat surveying happens after dark in woodland and along rivers; recordings are hundreds of MB and cannot be uploaded from a field site.

### Offline species identification for anything that isn't a bird — zero apps
- **Query:** https://search.f-droid.org/?q=plant&lang=en and https://search.f-droid.org/?q=mushroom&lang=en
- **Source:** F-Droid search | **URL:** https://search.f-droid.org/?q=plant&lang=en | **Date:** 2026-07-27
- **Paraphrase:** All eleven "plant" hits are watering reminders, grow trackers and gardening companions; there is no plant-ID app, and "mushroom" returns only an unrelated Unicode keyboard.
- **Points to:** The whoBIRD pattern (bundle an open model, run it on-device) applied to plants, fungi, insects or fish — the slot next to the one proven hit is empty.
- **Offline necessity:** Identification happens where the organism is: woods, moorland, coast — and foragers deliberately do not want their find locations leaving the phone.

### Sign language — zero apps
- **Query:** https://search.f-droid.org/?q=sign+language&lang=en
- **Source:** F-Droid search | **URL:** https://search.f-droid.org/?q=sign+language&lang=en | **Date:** 2026-07-27
- **Paraphrase:** No sign-language dictionary, fingerspelling trainer or reference exists in F-Droid; on GitHub the only comparable work is stale research code such as https://github.com/Mquinn960/sign-language (57 stars, last push 2019-05-11).
- **Points to:** An offline fingerspelling / core-vocabulary drill app for a specific national sign language.
- **Offline necessity:** Learners drill in transit and in classrooms; more importantly deaf users need reference where there is no wifi. **Caveat: signed-video corpora are rarely commercially licensed — treat this as licence-blocked until proven otherwise.**

### Trades reference — zero apps
- **Query:** https://search.f-droid.org/?q=electrician&lang=en , https://search.f-droid.org/?q=welding&lang=en , https://search.f-droid.org/?q=forestry&lang=en
- **Source:** F-Droid search | **URL:** https://search.f-droid.org/?q=electrician&lang=en | **Date:** 2026-07-27
- **Paraphrase:** "electrician", "welding" and "forestry" all return zero relevant apps; the only trade tool anywhere in Science & Education is "Drill Press Assistant" (a spindle-speed calculator).
- **Points to:** Machine-shop / workshop reference bundles (speeds & feeds, thread and tap charts, drill/tap sizes, material tables) — all of which are public engineering data.
- **Offline necessity:** Machine rooms, basements and shop floors are Faraday cages; you have oily gloves and a running spindle.
- **Caveat:** electrical/welding *codes* (NEC/NFPA, AWS) are copyrighted — auto-reject anything that needs the code text.

### Avalanche / backcountry snow — zero apps
- **Query:** https://search.f-droid.org/?q=avalanche&lang=en
- **Source:** F-Droid search | **URL:** https://search.f-droid.org/?q=avalanche&lang=en | **Date:** 2026-07-27
- **Paraphrase:** Only a crypto wallet and a marble game match "avalanche" — no snowpack, slope-angle or observation-recording tool.
- **Points to:** A snowpack **observation-recording** app (pit profiles, ECT/CT results, layer hardness/grain, slope angle) — deliberately NOT a forecast or a go/no-go verdict.
- **Offline necessity:** Above treeline there is no signal, and forecasts are the one thing you must download before you leave.
- **Caveat:** anything that outputs a *decision* is safety-critical → auto-reject. Recording-only is the survivable version.

### Beekeeping — zero apps in F-Droid, but the commercial slot is already taken
- **Query:** https://search.f-droid.org/?q=beekeeping&lang=en , plus `beekeeping app offline "no signal" apiary hive records`
- **Source:** F-Droid search + vendor site | **URL:** https://hivecompanion.app/ | **Date:** retrieved via search 2026-07-27 (unverified — from search snippet only)
- **Paraphrase:** F-Droid has nothing, but HiveCompanion already markets itself as an offline-first, one-time-purchase beekeeping logbook for beekeepers standing at an open hive miles from signal.
- **Points to:** Skip — the offline-first framing is already the competitor's headline.
- **Offline necessity:** Real (rural apiaries, gloved hands) but the need is met.

### Phrasebooks — zero apps
- **Query:** https://search.f-droid.org/?q=phrasebook&lang=en
- **Source:** F-Droid search | **URL:** https://search.f-droid.org/?q=phrasebook&lang=en | **Date:** 2026-07-27
- **Paraphrase:** No phrasebook app of any kind; the only offline language tooling is dictionaries (Aard 2, QuickDic, Sumatora) and one on-device translator.
- **Points to:** A *domain* phrasebook rather than a tourist one — e.g. a medical-encounter or maritime-VHF phrasebook — where the vocabulary is closed and the setting is signal-free.
- **Offline necessity:** Abroad without roaming is the canonical no-network case.

---

## PART C — WHAT EXISTS AND WHERE THE REMAINING GAP IS

### Celestial navigation — three hobby projects, no real app
- **Query:** `gh api search/repositories q="celestial navigation in:name,description stars:>5"`
- **Source:** GitHub API | **URL:** https://github.com/alinnman/celestial-navigation | **Date:** last push 2026-07-17, 23 stars, MIT, 14 open issues
- **Paraphrase:** "Celeste" is a one-person MIT-licensed celestial-navigation toolkit whose own description promises it runs on an Android phone *without an internet connection*; alongside it sit https://github.com/ms8r/celnav (24 stars, last push 2024-08-20) and the OpenCPN plugin https://github.com/seandepagnier/celestial_navigation_pi (21 stars, 2024-01-23).
- **Points to:** A polished offline sight-reduction app: sextant sight entry, index/dip/refraction corrections, local ephemeris, intercept + running fix plot, star/planet identification and a "which body is up tonight" planner.
- **Offline necessity:** Celestial navigation is by definition what you do when GPS and cell are gone; mid-ocean is the entire use case, and the ephemeris is a computation, not a feed.
- **Licence note:** ephemeris theories (VSOP87 etc.) and US sight-reduction tables (Pub. 229/249, NGA/USNO) are public-domain US-government work — clean for commercial use.

### Maritime pocket reference — three independent 2026 attempts, all tiny
- **Query:** `gh api search/repositories q="buoyage in:name,description"` and `q="colregs in:name,description"`
- **Source:** GitHub API | **URL:** https://github.com/jessehawbolt/abeam | **Date:** created/pushed 2026-07-14, 1 star
- **Paraphrase:** "Abeam" is a brand-new offline PWA of COLREGs, VHF scripts and Seaway/Great Lakes reference for Canadian mariners; separately https://github.com/FractalDoctor/DatumMark (2026-03-08, 0 stars) is an IALA buoyage reference and exam-revision app, and https://github.com/Forwardboy009/COLREGS72 (4 stars) died in 2016.
- **Paraphrase (why it matters):** Three unconnected people built the same thing badly in the same twelve months.
- **Points to:** An offline mariner's reference + drill app — light/shape/sound-signal recognition drills, IALA A/B buoyage quiz, COLREGs text, VHF/distress phrase scripts, chart-symbol lookup.
- **Offline necessity:** You are on the water, out of range, and the reason you're reaching for it is that a vessel is bearing down on you at night.
- **Licence note:** US Navigation Rules (33 CFR / USCG) and NOAA Chart No. 1 are public domain. IMO's own COLREG publication is *not* — use the US federal text.

### Cave surveying — Android is served, iOS has nothing
- **Query:** `gh api search/repositories q="topodroid in:name,description"`
- **Source:** GitHub API | **URL:** https://github.com/marcocorvi/topodroid | **Date:** last push 2026-07-26, 74 stars, 31 forks, GPL-3.0
- **Paraphrase:** TopoDroid is very actively maintained (dozens of issues opened and closed in mid-2026, including new BLE instrument support) but is Android-only and single-maintainer.
- **Points to:** Not a clone — the gap is iOS, and adjacent underground work (mine/tunnel inspection logging, sketch-on-plan field notes) that TopoDroid does not cover.
- **Offline necessity:** Underground is the purest possible no-signal environment; also the phone is the only instrument you have and the survey must not be lost.

### On-device species ID — whoBIRD proves the pattern; the models for other taxa are mostly non-commercial
- **Query:** `gh api search/repositories q="bioacoustic in:name,description stars:>5"` and `q="batdetect"`
- **Source:** GitHub API | **URL:** https://github.com/woheller69/whoBIRD | **Date:** last push 2026-07-20, 886 stars, GPL-3.0
- **Paraphrase:** whoBIRD runs BirdNET fully on-device for 6,000+ species and has 886 stars — proof that "bundle an open model, never touch the network" is a beloved formula.
- **Points to:** The same formula for bats, orthoptera, frogs or fish.
- **Offline necessity:** Surveys happen at night in woodland; audio files are far too large to upload from the field.
- **HARD LICENCE FINDING:** I read the licence file directly — https://github.com/macaodha/batdetect2 (101 stars, active 2026-06-23) is **CC BY-NC 4.0, i.e. non-commercial, unusable**. Its predecessor https://github.com/macaodha/batdetect (73 stars, last push 2023-07-04) is reported by the API as CC-BY-4.0, which *would* be usable — this needs verifying before betting on it.

### Offline botanical keys — one person just built one by hand
- **Query:** `gh api search/repositories q="plant identification offline in:name,description stars:>5"`
- **Source:** GitHub API | **URL:** https://github.com/sgoedecke/vicflora-offline | **Date:** last push 2025-11-14
- **Paraphrase:** A developer built an offline-first plant identification and keying tool from the VicFlora (Victoria, Australia) dataset — again the "solve my own region" pattern, again nobody generalised it.
- **Points to:** An offline interactive dichotomous key for a named regional flora, with couplet history, back-tracking, glossary of morphological terms and a "why did I land here" trail.
- **Offline necessity:** Keying happens standing in a bog with the specimen in hand; state-flora datasets are frequently CC-BY, so the whole thing ships in the APK.

### Ham radio — well served, do not enter
- **Query:** https://search.f-droid.org/?q=amateur+radio&lang=en
- **Source:** F-Droid search | **URL:** https://search.f-droid.org/?q=amateur+radio&lang=en | **Date:** 2026-07-27
- **Paraphrase:** Eight ham apps already exist including "KC3ICT Ham Study" (offline FCC exam flashcards), "Hamfisted" (German licence exam), "Dahdidahdit" Morse trainer and two logbooks.
- **Points to:** Avoid — exam prep, logging and Morse are all taken despite the public-domain FCC question pool.
- **Offline necessity:** Genuinely high (field days, POTA/SOTA activations) which is exactly why it's already crowded.

### Field-biology recording — a live micro-genre worth studying
- **Query:** https://f-droid.org/en/categories/science-education/
- **Source:** F-Droid category page | **URL:** https://f-droid.org/en/categories/science-education/ | **Date:** 2026-07-27
- **Paraphrase:** Science & Education contains TransektCount and TourCount (butterfly transect monitoring for European recorders), Feltbok (bird sighting export), Field Survey (a field-logbook builder) and Manholer (manhole field logging) — hyper-specific offline recording tools, each clearly built by one practitioner for their own scheme.
- **Points to:** The template works: pick one recording scheme with a published protocol and build the definitive offline recorder for it.
- **Offline necessity:** Transects and surveys are walked in places with no service, and the recorder must never lose a count.

### Health/medical offline reference — one interesting precedent
- **Query:** https://f-droid.org/en/categories/sports-health/
- **Source:** F-Droid category page | **URL:** https://f-droid.org/en/categories/sports-health/ | **Date:** 2026-07-27
- **Paraphrase:** "Épione" is an offline directory of French health facilities built from FINESS open data, and "Mood Cairns" advertises literally no network access — both prove that an open government dataset plus zero-network is a shippable F-Droid product.
- **Points to:** The "bundle a national open dataset, no network permission" pattern generalises to many countries and registries.
- **Offline necessity:** Épione's users are looking up a facility while travelling or in a hospital basement; Mood Cairns' users want the data never to leave the device.

---

## PART D — DEAD ENDS FOUND (recorded so we don't re-search them)

- **"awesome offline first" / "awesome local first" lists are all developer tooling, not app ideas.** Retrieved list index: https://github.com/schickling/awesome-local-first and https://github.com/pablomaurer/awesome-offline-first-database — these catalogue CRDT/sync databases (PouchDB, RxDB, Automerge). Zero end-user app leads. Note also that half of "local-first" in these lists means *sync*, which is an auto-reject for us.
- **Searching GitHub for archived high-star "offline android" repos returns libraries, not apps.** `gh api search/repositories q="offline android in:name,description,readme stars:>300 pushed:<2023-01-01"` returned RoboSpice, nytimes/Store, android-priority-jobqueue etc. Star-sorted GitHub search is the wrong instrument for finding niche end-user apps; domain-keyword search is the right one.
- **`gh api search/issues q='"offline" "would be great" ... android'` returned generic "please port to iOS/Android" issues,** e.g. https://github.com/johannesjo/super-productivity-android/issues/3 ("App fails to start without internet connection", opened 2020-10-28, 17 comments). Real but generic offline frustration, not a niche.
- **F-Droid's RFP tracker is about packaging existing apps, not requesting new ones** — https://gitlab.com/fdroid/rfp/-/issues/1905 is a request to package a Telegram fork. Not a source of unmet needs.
- **Offline tide apps DO exist commercially on iOS** (Tides Anywhere, Shore TideChart, Tide Alert — from App Store search results, unverified beyond listing text), so the tide lead is "abandoned in FOSS/Android", not "nobody has ever done it".


# ============================================================
# SOURCE FILE: research/raw/forums-stackexchange.md
# ============================================================

# Phase 1 Discovery — Trade Forums, Stack Exchange, Community Group Sizing

**Researcher lane:** occupational/hobby forums, Stack Exchange network, community group descriptions
**Date of research:** 2026-07-27

## Method & access notes (read this first)

- Many of the assigned trade forums are now behind **Tollbit paywalls or Cloudflare/JS walls** and could not be read: `beesource.com` (307 → `tollbit.beesource.com`, then HTTP 402 Payment Required), `hvac-talk.com` (307 → tollbit), `practicalmachinist.com` (403), `homebrewtalk.com` (403), `cruisersforum.com` (403), `arboristsite.com` (403), `controlbooth.com` (403), `birdforum.net` (403), `gearspace.com` (403), `forum.woodenboat.com` (403), `mapletrader.com` (Cloudflare JS challenge), `hvacsite.com` (JS required).
  Where I could only see a search-engine snippet for those, the finding is explicitly marked **(unverified — from search snippet only)**.
- Forums I **did** read in full: `rocketryforum.com`, `ukcaving.com`, `talk.newagtalk.com`, `iforgeiron.com`, `winemakingtalk.com`, `tripolivegas.com`.
- Stack Exchange web pages are not fetchable from this environment, but the **Stack Exchange public API is**, so SE findings below were pulled as raw question bodies with real score/view/date fields.
- **No Reddit sizing data** — reddit.com/about.json is blocked here. Where I state a community size it is from a page I actually retrieved.

---

## STRONG LEADS

### High-power / model rocketry — offline flight & inventory log
- **Query:** `rocketryforum.com "no cell service" OR "no signal" launch site app offline thread`
- **Source:** The Rocketry Forum (TRF) | **URL:** https://www.rocketryforum.com/threads/app-for-logging-rocket-launches.175293/ | **Date:** Oct 2022 (thread still active later)
- **Paraphrase:** A professional software developer asks whether any iPhone/Android app exists for logging rocket flights; the community's senior member answers that the general answer is "no", that he hacked something in Airtable, and that a purpose-built app would be preferable "especially one that would work off-line."
- **Points to:** A purpose-built offline rocket/flight/motor/inventory logbook — rockets, builds, motors, flights, altimeter results, photos, all on-device.
- **Offline necessity:** High-power launch sites are desert playas and remote farm fields with zero cellular coverage; the whole logging event happens where the network isn't.

### High-power rocketry — the missing app already has a written spec
- **Query:** `rocketryforum.com "no cell service" OR "no signal" launch site app offline thread` (followed the in-thread link)
- **Source:** The Rocketry Forum | **URL:** https://www.rocketryforum.com/threads/a-phone-app-that-i-really-want.164851/ | **Date:** Feb 2021
- **Paraphrase:** A member lays out a complete feature list and database schema for the flight-logging app he wants (rockets → launches → flights, motor pull-downs, auto date/place, photo attach, browse by rocket or by day); a second member says he has filled seven 3x5 notebooks in ten years because nothing digital fits the workflow; a third says he would write it but never did.
- **Points to:** The exact app spec, written by the users themselves, with pull-down-driven entry so it can be used one-handed in wind and glare.
- **Offline necessity:** Data is captured at the pad and the recovery field; today it goes into a paper notebook that then never gets transcribed.

### High-power rocketry — audience is nameable and correctly sized
- **Query:** `high power rocketry forum "no cell service" launch site app offline flight simulation Tripoli members`
- **Source:** Tripoli Vegas (club launch page) | **URL:** https://tripolivegas.com/launchschedule.html | **Date:** current (retrieved 2026-07)
- **Paraphrase:** The club instructs high-power flyers to screenshot their Tripoli/NAR membership cards before driving out, explicitly because there is no cell service at the launch site.
- **Sizing (retrieved):** National Association of Rocketry lists ~8,850 members / 200 affiliated sections — https://en.wikipedia.org/wiki/National_Association_of_Rocketry ; Tripoli Rocketry Association is the second body — https://en.wikipedia.org/wiki/Tripoli_Rocketry_Association . Combined US certified high-power population is a low five-figure number.
- **Points to:** Same offline rocketry logbook; membership cards, cert level and motor inventory could live in the same offline app.
- **Offline necessity:** The club itself designs its check-in procedure around the absence of signal.

### Cave surveying — existing offline tools work but are brittle and expert-only
- **Query:** `ukcaving.com thread app phone survey Topodroid PocketTopo underground offline`
- **Source:** UK Caving forum, Surveying section | **URL:** https://ukcaving.com/board/index.php?threads/pocket-topo-for-android-operating-system-mobile-phone.23957/ | **Date:** Aug 2018
- **Paraphrase:** Cave surveyors describe abandoning dedicated PDAs as unreliable and unobtainable, then report repeated Bluetooth drop-outs between the DistoX and both PocketTopo and TopoDroid in tight passage, app crashes when adding passage detail, and one self-described non-technical caver saying he can survey but cannot operate the software.
- **Points to:** A far simpler offline cave-survey capture app (centreline + splays + sketch) aimed at the non-technical caver, tolerant of Bluetooth loss, exporting to Survex/Therion.
- **Offline necessity:** Absolute — this is data capture hundreds of metres underground, sometimes past a sump.
- **Caveat:** Real leaders already exist (TopoDroid, SexyTopo, Cave09); the gap is UX and robustness, plus a Bluetooth hardware dependency (DistoX) that complicates a pure-software product.

---

## MODERATE LEADS

### Row-crop farmers — field-operation records still live in spreadsheets
- **Query:** `talk.newagtalk.com app offline "no cell service" field records spreadsheet`
- **Source:** AgTalk (Precision Talk forum) | **URL:** https://talk.newagtalk.com/forums/thread-view.asp?tid=1142953&mid=10555721 | **Date:** Jan 2024
- **Paraphrase:** Asked for a phone app to track field operations, the best answer offered is to build your own Google Sheet with a Form for entry, or nest OneNote pages by Client > Farm > Field and re-key into a spreadsheet later.
- **Points to:** An offline per-field operations log (product, rate, cost, acres, date, weather) with no account, exporting CSV.
- **Offline necessity:** Moderate — rural fields frequently drop signal, but the thread does not say so explicitly, and the segment is well funded and heavily served by John Deere Operations Center and similar.

### Small-lot winemakers — cellar records are lost paper notebooks
- **Query:** `winemaker forum cellar records app offline spreadsheet SO2 additions "no signal" winery lab logbook`
- **Source:** Winemaking Talk | **URL:** https://www.winemakingtalk.com/threads/winemaking-software.69254/ | **Date:** May 2019 (2 pages, still referenced)
- **Paraphrase:** A software engineer asks for winemaking log software because he is on his third lost notebook this year and cannot remember any of his wines' ABV; replies are a mix of self-built Google Sheets tracking SO2 levels, additions, rackings and tastings, paper tucked in with the carboy, and BeerSmith repurposed.
- **Points to:** An offline batch/vessel log with built-in SO2, acid, chaptalisation and fortification calculators and a searchable history.
- **Offline necessity:** Weak-to-moderate. Cellars and barrel rooms are signal dead zones, but a home winemaker's cellar usually has wifi. Offline is a nice-to-have here, not the point.

### Blacksmiths / bladesmiths — heat-treat reference on the shop floor
- **Query:** `iforgeiron.com forum "heat treat" steel data chart app phone shop reference`
- **Sources:** I Forge Iron | **URLs:** https://www.iforgeiron.com/topic/68159-blacksmithing-app-for-phone/ (May 2021) and https://www.iforgeiron.com/topic/35231-heat-treaters-guide-app/ (Oct 2013, 62 replies, 45.8k views, last reply Dec 2025)
- **Paraphrase:** A new smith asks for the app that tells you a steel's composition and which quench goes with it and can only find blacksmith RPG games; the answer is the free ASM/HTS "Heat Treater's Guide Companion", and smiths immediately warn that its times are for thick sections and are wrong for blade-thin stock.
- **Points to:** A section-thickness-aware heat-treat assistant for bladesmiths.
- **Offline necessity:** Real (forge shops, barns, no signal, dirty hands), but…
- **AUTO-REJECT RISK:** the useful dataset is ASM's ~$250 copyrighted Heat Treater's Guide. There is no public-domain equivalent. Fails the commercial-licensing test.

### HVAC / commercial refrigeration field techs — mechanical rooms have no signal
- **Query:** `hvac-talk.com forum app "no signal" basement mechanical room PT chart phone` and `"HVAC" technician forum "no service" crawl space basement phone app offline refrigerant chart annoying`
- **Source:** HVAC-Talk | **URL:** https://hvac-talk.com/vbb/threads/1911421-PT-chart | **Date:** thread listed by search, content **not retrievable** (Tollbit 402) — *(unverified — from search snippet only)*
- **Paraphrase:** Techs swap recommendations for phone P/T-chart apps for checking refrigerant charge and note that they are often in basements and mechanical rooms with no signal.
- **Points to:** An offline refrigerant/psychrometric toolkit (P/T, superheat/subcool targets, glide, duct and airflow math).
- **Offline necessity:** Strong — attics, crawlspaces, basements, rooftop plant rooms.
- **AUTO-REJECT RISK:** Audience is ~400k US HVAC techs, far above the 3k–50k band, and the P/T-chart space is already crowded (HVAC Buddy, Danfoss Ref Tools, HVAC PT Chart, measureQuick). Only viable if narrowed hard, e.g. marine or transport refrigeration.

### Passengers / geography enthusiasts — offline in-flight moving map
- **Query:** Stack Exchange API, `site=aviation q=offline`
- **Source:** Aviation Stack Exchange | **URL:** https://aviation.stackexchange.com/questions/91605/how-to-track-a-flight-that-i-am-flying-in-using-the-gps-antenna-in-my-mobile-pho | **Date:** Feb 2022 | 7,751 views, only 1 answer
- **Paraphrase:** A first-time flyer downloaded gigabytes of offline maps and expected his phone's GPS to plot his position over them mid-flight, discovered it doesn't work, and asks how to track the aircraft with no internet.
- **Points to:** A true airplane-mode moving map that names the terrain, rivers, cities and airports below you, built on public-domain data (Natural Earth, OurAirports, GNIS).
- **Offline necessity:** Absolute — airplane mode at 35,000 ft, paid wifi refused.
- **Caveat:** Audience is "anyone who flies", i.e. not a nameable 3k–50k niche, and modern iOS/Android GPS behaviour has partly closed the technical gap.

### Field naturalists — offline flora/fauna identification
- **Query:** Stack Exchange API, `site=outdoors q="is there an app"` / `q=offline`
- **Source:** The Great Outdoors Stack Exchange | **URL:** https://outdoors.stackexchange.com/questions/21531/is-there-an-app-to-identify-flora-and-fauna | **Date:** Jan 2019 | 755 views, 4 answers
- **Paraphrase:** A hiker asks which plant/animal ID apps exist and, specifically, whether any of them work offline.
- **Points to:** A regional offline dichotomous key / field guide with no server round-trip.
- **Offline necessity:** Strong (you identify things exactly where there is no signal), but the big incumbents (Seek/iNaturalist, PlantNet) have partial offline modes and the "which regional flora, licensed how" question decides everything.

### Amateur satellite operators — pass prediction with no internet
- **Query:** Stack Exchange API, `site=ham q=offline`
- **Source:** Amateur Radio Stack Exchange | **URL:** https://ham.stackexchange.com/questions/17633/calculating-satellite-passes-without-an-internet-tracker | **Date:** Nov 2020 | 503 views, 2 answers
- **Paraphrase:** An operator who cannot get online asks how to compute where a satellite will be and when the next pass is, what orbital elements to collect beforehand, and how fast those go stale.
- **Points to:** An SGP4 propagator with cached elements and a printable pass sheet.
- **Offline necessity:** Real for field/emergency operating.
- **AUTO-REJECT RISK:** TLEs decay in days — this needs periodically refreshed live data, which violates the no-network-at-runtime rule unless framed as "works from whatever you last loaded".

### Bird ringers / banders — species codes and biometrics in the field
- **Query:** `bird banding ringers forum offline data entry app "no signal" field station spreadsheet`
- **Source:** BTO (British Trust for Ornithology) | **URL:** https://www.bto.org/our-science/projects/bird-ringing-scheme/taking-part/resources-ringers/ringing-nrs-info-app | **Date:** current *(unverified — from search snippet only)*
- **Paraphrase:** BTO ships a "Ringing & NRS Info" app carrying species data, ring sizes, biometrics and the ringing codes a volunteer needs in the field.
- **Points to:** Already partly built by the scheme operator itself.
- **Offline necessity:** Very strong (mist-net rides at dawn in reedbeds).
- **Verdict:** Mostly served in the UK; a US/BBL equivalent using the public-domain USGS alpha codes might still be open, but no forum evidence of demand was found.

---

## NICHES CHECKED AND FOUND ALREADY SOLVED (do not pursue)

### Beekeeping hive records — already an offline-first commercial app
- **Query:** `beesource.com forum "is there an app" hive records offline no signal`
- **Source:** HiveCompanion product site | **URL:** https://hivecompanion.app/ | **Date:** current (site retrieved 2026-07)
- **Paraphrase:** A shipping product that markets itself as offline-first beekeeping records — everything on the phone, no cloud, no account, no subscription, usable at an out-apiary with no signal.
- **Points to:** Exactly the app this brief describes, already built. The forum demand was real (multiple Beesource threads on hive apps) and someone acted on it.
- **Offline necessity:** Confirms the thesis; the slot is taken.

### Farriers — Mustad ships an offline-capable farrier app
- **Query:** `farrier forum hoof shoeing records app spreadsheet "I wish" barn no signal`
- **Source:** Apple App Store — EQUINET by Mustad | **URL:** https://apps.apple.com/us/app/equinet/id1459492568 | **Date:** current *(unverified — from search snippet only)*
- **Paraphrase:** A manufacturer-backed farrier business app that explicitly advertises working online *and* offline because farriers spend their day in low-signal barns.
- **Offline necessity:** Strong, and already addressed by a well-funded incumbent.

### Falconry weight management — at least three apps already
- **Query:** `falconry forum app weight log "spreadsheet" hawk daily weights track`
- **Source:** Apple App Store — Falconry Journal | **URL:** https://apps.apple.com/us/app/falconry-journal/id1607391134 | **Date:** current *(unverified — from search snippet only)*
- **Paraphrase:** A paper-journal replacement that logs weights, feeds and kills, computes weight loss per hour, predicts future weight and exports to a spreadsheet; FalconryLab and Falconry Journal Pro compete with it.
- **Verdict:** ~4,000 US falconers, three apps. Saturated.

### Wildland firefighting — the pocket guide is already a free offline app
- **Query:** `wildland firefighter forum IRPG app offline "no cell service" fireline pocket guide phone`
- **Source:** Google Play — IRPG App (2025) | **URL:** https://play.google.com/store/apps/details?id=com.irpg | **Date:** 2025 edition *(unverified — from search snippet only)*
- **Paraphrase:** A free, ad-free, fully offline, full-text-searchable digital edition of the NWCG Incident Response Pocket Guide.
- **Verdict:** The obvious public-domain-dataset play (NWCG is US Government PD) is done.

### Exploration geology core logging — three offline products competing
- **Query:** `exploration geologist core logging offline app field "no internet" drill site spreadsheet forum`
- **Sources:** Field Manager https://fieldmanagermining.com/ ; Let'sGeo https://www.letsgeo.world/manual.php *(unverified — from search snippets only)*
- **Paraphrase:** Both market 100%-offline field logging with local-only storage for geologists at remote drill sites.
- **Verdict:** Served, and by people who know the domain.

### Merchant mariners / COLREGS — many offline study apps
- **Query:** `merchant mariner cadet forum COLREGS rules of the road study offline app "at sea" no internet ship`
- **Source:** Apple App Store — ColRegs: Rules of the Road | **URL:** https://apps.apple.com/us/app/colregs-rules-of-the-road/id494839562 | **Date:** current *(unverified — from search snippet only)*
- **Verdict:** Crowded; also the authoritative IMO text is copyrighted (only the US Inland Rules are PD).

### Commercial fishing logbooks — offline e-logbook already regulated and built
- **Query:** `commercial fishermen forum electronic logbook offline "no signal" at sea app paper logbook complaint`
- **Source:** Deckhand | **URL:** https://deckhandlogbook.com/electronic-logbook-commercial-fishermen/ | **Date:** current *(unverified — from search snippet only)*
- **Verdict:** Offline capture, sync when in range, NOAA/AFMA compliant. Compliance-driven and already occupied.

### Theatre rigging calculators — evidence exists but is unreadable and the domain is liability-heavy
- **Query:** `controlbooth.com theatre technician app offline backstage "no signal" rigging calculator wish existed`
- **Source:** ControlBooth | **URL:** https://www.controlbooth.com/threads/staging-rigging-workbox.25045/page-2 | **Date:** unknown — **HTTP 403, content not retrievable** *(unverified — from search snippet only)*
- **Paraphrase:** A rigger's ideal workbox list includes "a calculator with Trig functions! or even better iPhone or Android Rigging app!"
- **Verdict:** Bridle and load calculations are safety-critical — a wrong number drops a truss on people. AUTO-REJECT on liability.

### Wildlife rehabilitation records — promising signal, source could not be read
- **Query:** `wildlife rehabilitator forum offline app intake records fluid calculation "no internet" spreadsheet NWRA members`
- **Source:** International Wildlife Rehabilitation Council, "Keeping Your Data Straight" | **URL:** https://theiwrc.org/keeping-records/ | **Date:** unknown — **site returned "Error establishing a database connection"** *(unverified — from search snippet only)*
- **Paraphrase:** The IWRC's own guidance reportedly lists web-based options (WILD-ONe, WRMD) alongside Excel and pen-and-paper, and names the internet requirement as the major downside of the cloud tools.
- **Points to:** An offline intake/patient log for permitted rehabbers.
- **Offline necessity:** Moderate-to-strong (barns, transport, rural intakes) and privacy-adjacent (permit records).
- **Caveat:** I could not read the page. Also: any feeding/fluid dosing feature is a medical-liability trap and would have to be excluded.

---

## QUERIES THAT RETURNED NOTHING USEFUL

- `site:outdoors.stackexchange.com offline app` — **no evidence found** (search engine returned only App Store listings and SEO listicles, no SE content).
- `practicalmachinist.com forum "I wish there was an app" shop floor no cell signal` — **no evidence found** for the wish itself; the only real hits were threads about cell signal boosters in metal shop buildings, and all were 403.
- `disboard.org discord server members luthier OR "wildlife rehab" OR farrier ...` — **no evidence found**; Disboard tag pages did not expose member counts for any occupational server in the results.
- `"members" Facebook group beekeepers OR luthiers OR "wildlife rehabilitators" ...` — **no evidence found**; Facebook group member counts are not exposed to this search index. The only page-like counts surfaced were Facebook *Page* likes (British Farriers and Blacksmiths Association ~11,992 likes; The Farrier Group ~8,129 likes) which are not group membership and which I could not verify on-page. Treat as **unverified**.
- `court interpreter conference interpreter forum glossary app offline booth confidentiality "no internet" ProZ` — **no evidence found** on any forum; only vendor pages for InterpretBank.
- `maple syrup producers forum app records sugarbush "no cell service" spreadsheet tracking tapping` — MapleTrader thread found by title but blocked by Cloudflare; **content unverified**. SapTapApps and Maple Syrup Time are both network-dependent (forecast/sap-flow driven), so the space is not obviously served offline but I have no primary-source demand evidence.
- Stack Exchange API sweeps for `"is there an app"` on `woodworking`, `gardening`, `aviation`, `biology`, `boating` — **zero results each**. Same sweep for `offline app` on `homebrew`, `mechanics`, `cooking`, `photo`, `sustainability`, `martialarts` — **zero results each**. These communities simply do not phrase tooling gaps that way.


# ============================================================
# SOURCE FILE: research/raw/wishlist-nonreddit.md
# ============================================================

# Wishlist mining — people explicitly asking for an offline app (NON-REDDIT sources)

**Researcher note on method / environment limits (read this first):**

- Reddit was not used at all. No reddit URL is cited as evidence anywhere below.
- The `WebSearch` tool hit its session budget (200/200) after 2 calls, so almost all retrieval
  below was done with **direct HTTP against structured APIs** (Discourse `search.json` / `t/<id>.json`,
  Stack Exchange API, HN Algolia, Lemmy `/api/v3/search`, iTunes Search API, Apple App Store
  customer-review RSS) plus `WebFetch` against `lite.duckduckgo.com`.
- Search engines that were **blocked** in this environment: Mojeek (403 after 2 queries),
  searx.be / baresearch.org / search.hbubli.cc (Anubis or antibot challenge), Ecosia (403),
  Yep (403), Startpage (303), `html.duckduckgo.com` (CAPTCHA after ~4 queries).
  `lite.duckduckgo.com` kept working and was used for the rest.
- Sites that returned **403 to both curl and WebFetch** (so their bodies are unverified):
  `wildlabs.net`, `birdforum.net`, `bto.org`, `forestryforum.com`, `homebrewtalk.com`,
  `mapletrader.com`, `community.esri.com`, `dco.uscg.mil`.
- Anything marked "unverified" below is from a search-result snippet only.

---

## Strongest cluster: merchant mariners (deep-sea, no internet for weeks)

`forum.gcaptain.com` runs Discourse, so its full JSON API is reachable. It turned out to be the
single richest non-Reddit vein found. Three separate, independent, verified asks below.

### Merchant mariners studying for USCG licence/QMED exams at sea
- **Query:** Discourse API `forum.gcaptain.com/search.json?q=study+exam+offline+app` then `/t/59083.json`
- **Source:** gCaptain Discourse forum | **URL:** https://forum.gcaptain.com/t/qmed-books-study-materials/59083 | **Date:** 2021-04-12 | VERIFIED FETCH
- **Paraphrase:** A mariner about to ship out as a wiper for six months with Military Sealift Command asks what books or *offline* learning material he can take to study for his QMED exams while at sea; the accepted answer is "buy a USB thumb drive from marineradvancement.com, no internet required, all you need is a Windows computer."
- **Points to:** A fully offline USCG deck/engineering exam-prep app (question bank + illustrations + spaced repetition + module-by-module mock exams) that runs on the phone already in the mariner's pocket instead of a USB stick and a laptop.
- **Offline necessity:** The user is literally at sea for six months; shipboard internet is metered, awful, or absent, and the study window is the watch-off hours in a cabin. This is the textbook "physically has no signal" case.
- **Audience size:** ~200,000 Americans hold a valid Merchant Mariner Credential as of 2023 (GAO figure, reported at https://www.marinelink.com/news/numbers-gao-examines-americas-mariner-541247 — *unverified, snippet only*); the National Maritime Center processed ~75,000 credential requests in 2024 (https://www.workboat.com/coast-guard-awards-50-million-contract-to-modernize-mariner-credentialing-program — *unverified, snippet only*). The people actually *sitting an exam* in a given year — the real buyers — are a subset, plausibly in the 10k–40k band.
- **Data/licence note:** USCG/NMC examination questions are US federal government work → public domain, commercially usable. Caveat found in the evidence: the USCG *pulled the published banks off its website* around 2016 (see next finding), so sourcing a current bank needs care; older published banks and 46 CFR subject areas remain PD.

### Same niche, second independent signal: the question banks are being passed hand-to-hand
- **Query:** Discourse API `forum.gcaptain.com/search.json?q=question+bank+app`
- **Source:** gCaptain Discourse forum | **URL:** https://forum.gcaptain.com/t/uscg-deck-question-banks/44513 | **Date:** 2017-04-02 (8,966 views, 18 posts, replies through 2018) | VERIFIED FETCH
- **Paraphrase:** A mariner asks whether anyone downloaded the USCG deck question banks before the Coast Guard removed them from its site, complaining that the only people who have them are monetising them behind study-site paywalls; a half-dozen other mariners queue up in the thread asking to be emailed a copy.
- **Points to:** Confirms both the demand and that the incumbent solutions are subscription web study sites (which are useless at sea).
- **Offline necessity:** Same as above — study happens on a ship.
- **Audience size:** 8,966 views on one thread on one forum is a decent floor signal for a niche this specific.
- **Data/licence note:** As above; note the sourcing risk explicitly.

### Deck officers' offline onboard calculation/reference toolbox
- **Query:** Discourse API `forum.gcaptain.com/search.json?q=offline+calculator`
- **Source:** gCaptain Discourse forum | **URL:** https://forum.gcaptain.com/t/former-sea-captain-building-an-offline-android-tool-for-deck-officers-feedback-welcome/75117 | **Date:** 2026-04-11 | VERIFIED FETCH
- **Paraphrase:** A former sea captain announces he is building an Android app ("CaptainCalc") for masters and deck officers covering draft survey, stability support calculations, voyage calculations, celestial tools and maritime reference, explicitly "for everyday onboard use, especially when internet access is limited or unavailable at sea."
- **Points to:** A one-tool offline bridge/deck-officer calculation suite. Note: someone is already three months into building this, which is evidence the gap is real but also that the lane is now occupied by an insider.
- **Offline necessity:** Bridge and deck work mid-ocean; no connectivity, and hands/time do not permit a spinner.
- **Audience size:** unknown for "deck officers" specifically; a mariner in https://forum.gcaptain.com/t/stats-on-number-of-current-license-holders/69149 (2024-04-14, VERIFIED FETCH) reports that the licence-holder breakdown by tonnage is not published at all and requires a FOIA request — i.e. the audience is genuinely hard to size from public data.
- **Data/licence note:** Draft-survey and stability *formulas* are public; ship-specific hydrostatic tables and loading manuals are vessel proprietary — a general app must let the user key in their own. Celestial nav is an already-checked dead end. **Watch out: stability/loading calculations for actual voyage decisions are safety-critical — this would need to stay firmly on the "training/cross-check" side of the liability line.**

### Offline tide & current prediction for mariners — CHECKED AND ALREADY SOLVED
- **Query:** Discourse API `forum.gcaptain.com/search.json?q=app+that+works+offline`
- **Source:** gCaptain Discourse forum | **URL:** https://forum.gcaptain.com/t/tides-and-currents-computer/58579 | **Date:** 2021-03-02 | VERIFIED FETCH
- **Paraphrase:** A tug sailor asks whether any tide-and-current app or software exists that does not require an internet connection; other mariners immediately answer with XTide-derived apps that carry 3,000+ stations offline.
- **Points to:** Nothing to build. **Recording this as a negative result so nobody re-mines it.**
- **Offline necessity:** Strong, but already met.
- **Audience size:** n/a.
- **Data/licence note:** NOAA harmonic constituents are public domain; XTide is GPL (copyleft — matters if you wanted to reuse the engine commercially).

---

## Field naturalists: an offline copy of *your own* observation archive

### Personal offline field record / "pocket herbarium" for naturalists
- **Query:** Discourse API `forum.inaturalist.org/search.json?q=offline+app+wish`, then `/t/12840.json` and `/t/55319.json`
- **Source:** iNaturalist Discourse forum | **URL:** https://forum.inaturalist.org/t/allow-offline-access-to-observation-data-and-map/12840 | **Date:** 2020-05-27, with replies 2021-06-17 and 2026-05-16 | VERIFIED FETCH
- **Paraphrase:** Users want their own past observations and a map available offline; one says outright that he uses the mobile app as his personal herbarium and "often doesn't have phone service to access the web interface," and asks for offline search of his own records by taxon.
- **Points to:** A standalone offline field notebook that ingests your exported observation archive (CSV + selected photos + a low-res basemap/hillshade) and lets you search it by taxon and location in the field with no network — effectively a personal, offline natural-history database.
- **Offline necessity:** Deep-field botany/entomology sites with no coverage; the whole point of checking a past ID is that you're standing in front of the organism.
- **Audience size:** unknown; thread views 1,132 and 324 respectively. iNaturalist overall is far larger than 50k, so the honest read is that the *buyable* niche is "naturalists who do repeat-visit fieldwork off-grid", not all iNat users. **Sizing is the weak point of this lead.**
- **Data/licence note:** iNaturalist observation data is exportable by the user and mostly CC-licensed (CC0/CC-BY/CC-BY-NC varies per record — the NC ones are a commercial-use trap if you *bundle* them; bundling nothing and only importing the *user's own* export sidesteps this entirely). Basemaps would need OSM-derived tiles (ODbL — attribution + share-alike on derived data).

- **Second, corroborating thread:** https://forum.inaturalist.org/t/ability-to-download-observations-for-offline-reference/55319 | **Date:** 2024-09-10 | VERIFIED FETCH — a field worker says "when doing field work, there have been many times I've wished I could quickly search previous observations of mine within a given region to verify IDs, however this is obviously not possible [offline]"; the thread then works out that a few GB + a low-res hillshade would be acceptable.

### Offline taxonomic name resolution (developer-facing, weaker)
- **Query:** Discourse API `discourse.gbif.org/search.json?q=offline+app`
- **Source:** GBIF Discourse | **URL:** https://discourse.gbif.org/t/looking-for-offline-enabled-name-id-lookup-in-gbif-taxonomy-backbone-with-10k-matches-s/3019 | **Date:** 2021-08-19 | unverified — from search-result listing only (title/date from the API, body not fetched)
- **Paraphrase:** Someone asks for an offline-capable name/ID lookup against the GBIF taxonomic backbone at >10k matches/second.
- **Points to:** An embeddable offline taxonomic-name matcher — but this is a developer/library need, not a consumer app.
- **Offline necessity:** Weak-to-moderate (it's about throughput/independence more than signal).
- **Audience size:** unknown, small.
- **Data/licence note:** GBIF backbone taxonomy is CC-BY-4.0 — **good**, commercially usable with attribution.

---

## Craft / home distillers: TTB gauging done on paper because nothing pocketable exists

### Offline TTB proof-gauging and barrel-volume tracking
- **Query:** `lite.duckduckgo.com` — `craft distillers forum proof gallons gauging app offline TTB tables spreadsheet`
- **Source:** HomeDistiller phpBB forum | **URL:** https://homedistiller.org/forum/viewtopic.php?t=93455 | **Date:** 2024-09-17 | VERIFIED FETCH (via WebFetch; note `homedistiller.org/forum/search.php` returns 403, only `viewtopic.php` is readable)
- **Paraphrase:** Thread "Calculators: Spirit Hydrometer Temp Correction and Spirit Volume by Weight and Proof" — a distiller says a digitised TTB Table 4 fulfilled a need he'd been chasing for months, and describes weighing a barrel wet-and-empty then using the *paper* tables to work out current volume from current weight and ABV; a follow-up poster asks for help using Table 4 to account for two years of angels' share plus sampling.
- **Points to:** An offline gauging/proofing app: hydrometer temperature correction (Table 1), proof-gallon and wine-gallon determination from weight and proof (Tables 2/3/4), dilution/blending to target proof, and a barrel log that tracks fill weight → current volume → loss over time.
- **Offline necessity:** Moderate-to-strong. The measurements happen on a rickhouse/barrel-room or still-deck floor — often a metal building or a stone warehouse with no signal — with wet hands, a hydrometer and a thermometer in the other hand. It is also a records-keeping activity people are wary of putting in someone else's cloud.
- **Audience size:** unknown from a page I retrieved. (Trade-association counts of US craft distilleries were not retrievable — the association sites were not reachable in this environment. Treat as "low thousands of US DSPs plus a much larger home-distilling hobby population" and verify separately.)
- **Data/licence note:** The gauging tables live in **27 CFR Part 30** (eCFR: https://www.ecfr.gov/current/title-27/chapter-I/subchapter-A/part-30 — *unverified, snippet only*) and TTB publishes the table PDFs itself (e.g. https://www.ttb.gov/system/files?file=images/pdfs/foia_Gauging_Manual_Tables/Table_4.pdf — *unverified, snippet only*). US federal regulations and government works → **public domain, commercially usable**. Existing partial competition found: "Experience Distilled" calculator on Google Play, and UC Davis's Excel Table 4 calculator — neither is a complete offline gauging + barrel-log app.

---

## Field data recording where the incumbents need a server

### Field wildlife/ecology surveying in low-coverage countries
- **Query:** Discourse API `forum.getodk.org/search.json?q=offline+app+wish`, then `/t/24086.json`
- **Source:** ODK (Open Data Kit) Discourse | **URL:** https://forum.getodk.org/t/need-help-for-wildlife-survey-using-browser-based-forms-avoiding-future-time-offline-maps/24086 | **Date:** 2019-12-29 | VERIFIED FETCH
- **Paraphrase:** A researcher running wildlife surveys in India needs surveyors to drop precise sighting locations on a map, but there is little or no connectivity in the survey areas; the answer is a manual `.mbtiles` file-copy into `/odk/layers/tiles/`.
- **Points to:** A self-contained offline survey/mapping recorder where the basemap is a first-class in-app thing, not a file you sideload with a cable.
- **Offline necessity:** Strong (remote survey transects).
- **Audience size:** unknown.
- **Data/licence note:** OSM/ODbL tiles or public-domain satellite/hillshade. **Caution: this whole space is ODK/KoBo/Fulcrum territory and is inherently sync-shaped, which the brief auto-rejects.** Reported only because the recurring complaint — "getting an offline basemap onto the device is a manual file-copy chore" — is a genuinely reusable insight for any offline field app.
- **Corroborating (unverified, title only from the API):** https://forum.getodk.org/t/provide-a-way-to-get-mbtiles-to-collect-without-having-to-manually-place-files-in-the-layers-directory/42206 — 2023-07-11, **47 posts** on exactly this complaint.

### Bird ringers / nest recorders — someone is building the offline-first tool themselves
- **Query:** `lite.duckduckgo.com` — `bird ringers banding data entry app offline no signal forum request`
- **Source:** BirdForum (XenForo) tag page | **URL:** https://www.birdforum.net/tags/birdingapps-fieldbirding-offlinebirding/ | **Date:** unknown (tag page) | **unverified — from search snippet only** (birdforum.net returned HTTP 403 to both curl and WebFetch)
- **Paraphrase:** The snippet shows a poster sharing an early test build of a PWA for bird observations, ringing and nest mapping, "developed primarily for real field use, not desktop data entry," whose headline property is offline-first, working without signal.
- **Points to:** A ringing/nest-record field recorder: ring number sequences, biometrics (wing chord, mass, fat/muscle scores), age/sex codes, retrap handling, nest visit histories — all keyed fast, one-handed, at a mist-net ride at 05:30 with a bird in the other hand.
- **Offline necessity:** Very strong — ringing sites are woods, reedbeds and saltmarsh; and the *speed* constraint (bird in hand, welfare clock running) means a network round-trip is unacceptable even where there is signal.
- **Audience size:** unknown — BTO's own ringer-count pages were 403. Ringing schemes are national and licensed, so the number is knowable from regulators (BTO for Britain & Ireland, EURING for Europe, USGS Bird Banding Lab for North America); this needs a follow-up on a reachable network.
- **Data/licence note:** EURING exchange codes and species code lists are published openly by EURING; USGS BBL band-size and species-code tables are US federal → public domain. The commonly used *ageing/sexing* reference (Pyle) is copyrighted and must NOT be bundled.

### Fisheries observers at sea — offline apps exist but are institution-issued, not buyable
- **Query:** `lite.duckduckgo.com` — `fisheries observer at sea data entry app offline no internet forum catch sampling`
- **Source:** Pacific Community (SPC) FAME programme | **URL:** https://fame.spc.int/fisheries-data/electronic-approaches | **Date:** n.d. (programme page; OLLO launched 2019) | **unverified — from search snippet only**
- **Paraphrase:** SPC built "OLLO" (Offline LongLine Observer), an Android app on ruggedised tablets that lets observers record every field of the SPC/FFA Longline Regional Observer Workbook without connectivity.
- **Points to:** The pattern is confirmed (at-sea observers genuinely need 100% offline recording) but each regional programme has commissioned its own bespoke tool. A generic product would collide with programme-mandated data standards.
- **Offline necessity:** Absolute — weeks on a longliner.
- **Audience size:** small (hundreds to low thousands per regional programme).
- **Data/licence note:** Species code lists from FAO/ASFIS are freely published; regional observer workbook layouts are programme-controlled. **Probably not a good independent lead** — recorded so it isn't re-chased.

---

## Field linguistics / language documentation

### Offline wordlist elicitation and lexicon building in villages with no power or network
- **Query:** `lite.duckduckgo.com` — `field linguists offline android app lexicon elicitation transcription remote village no internet`
- **Source:** GitHub | **URL:** https://github.com/rulingAnts/Quickstart_Android | **Date:** unknown | **unverified — from search snippet only**
- **Paraphrase:** An Android app written to help trained linguists, fieldworkers and community members systematically elicit and document minority languages via comparative wordlists (Quickstart Wordlist of Melanesia, Comparative African Wordlist) — i.e. someone built their own because the desktop tools (FLEx, ELAN) don't go to the village.
- **Points to:** A phone-native offline elicitation kit: wordlist prompts, IPA-aware keyboard, audio capture tied to each item, gloss + example sentence, export to standard interchange formats.
- **Offline necessity:** Very strong — documentation fieldwork happens in places chosen precisely because they are remote; and recordings of a community's speech are sensitive data that should not leave the device by default.
- **Audience size:** unknown; field linguists / language-documentation workers plausibly low thousands worldwide.
- **Data/licence note:** IPA chart and the standard comparative wordlists are freely circulated in the discipline; Swadesh lists are public domain. Corroborating project: https://github.com/FieldDB/FieldDB ("an offline/online field database ... developed collectively by field linguists", *unverified, snippet only*).

---

## Evidence of the *pattern* from App Store reviews (real users, real complaints, verified via the review RSS API)

These are not niches on their own but they are verified, dated, first-person statements that offline
failure is what breaks the job. Retrieved via `itunes.apple.com/us/rss/customerreviews/...`.

### Offline field guides that turn out not to be offline
- **Query:** iTunes Search API `term=bird+survey+field+data` → review RSS for id 333227386
- **Source:** Apple App Store review, Audubon Bird Guide | **URL:** https://apps.apple.com/us/app/id333227386?see-all=reviews | **Date:** recent (mostRecent feed, retrieved 2026-07-27) | VERIFIED FETCH
- **Paraphrase:** 2-star review titled "Why no guide when I have no internet?" — the reviewer pre-downloaded all the bird packs specifically so the guide would work without internet, went somewhere with no internet, and no species account would load.
- **Points to:** Genuinely-offline reference content as a product property people will punish you for faking.
- **Offline necessity:** Strong.
- **Audience size:** too large for this brief (birding is a mass hobby) — cited as pattern evidence, not as a lead.
- **Data/licence note:** Bird imagery/audio is heavily licensed; this is why the incumbents are cloud-shaped.

### Dive professionals logging on the boat
- **Source:** Apple App Store review, PADI app | **URL:** https://apps.apple.com/us/app/id1490797188?see-all=reviews | **Date:** recent (retrieved 2026-07-27) | VERIFIED FETCH
- **Paraphrase:** 1-star "Offline sync never works" — did all the eLearning on a plane and lost it, and says nobody at PADI has ever tried using the app on a boat after a dive because it doesn't work offline.
- **Points to:** Offline-first dive/course logging for instructors and divemasters on liveaboards.
- **Offline necessity:** Strong (boat, mid-ocean, wet).
- **Audience size:** large overall; the *instructor/divemaster* slice is small but distribution is agency-controlled.
- **Data/licence note:** Agency course content is proprietary — auto-reject on licensed content unless scoped to the user's own logbook.

### Rural trade techs
- **Source:** Apple App Store review, Housecall Pro | **URL:** https://apps.apple.com/us/app/id692833651?see-all=reviews | **Date:** recent (retrieved 2026-07-27) | VERIFIED FETCH
- **Paraphrase:** 3-star from a tech pointing out that a fair number of companies work in rural areas with little to no cell service and the app's "start my time" times out and makes it look like he started late.
- **Points to:** Confirms the "field service in a dead zone" pattern. Generic on its own.
- **Offline necessity:** Strong.
- **Audience size:** large.
- **Data/licence note:** n/a.

### Farmers in the paddock
- **Source:** Apple App Store review, Tractor GPS – Field Guidance | **URL:** https://apps.apple.com/us/app/id1661207294?see-all=reviews | **Date:** recent (retrieved 2026-07-27) | VERIFIED FETCH
- **Paraphrase:** 3-star — bought it to spray weeds, discovered the paddock has no cell coverage, and the tracking jumped around and was unusable.
- **Points to:** GNSS-only, no-network agricultural guidance/recording.
- **Offline necessity:** Strong.
- **Audience size:** large.
- **Data/licence note:** n/a.

### Backcountry navigation that quietly needs a server
- **Source:** Apple App Store review, Gaia GPS | **URL:** https://apps.apple.com/us/app/id1201979492?see-all=reviews | **Date:** recent (retrieved 2026-07-27) | VERIFIED FETCH
- **Paraphrase:** 1-star "Features not working offline … where you need it" — snap-to-trail silently requires a network despite all maps and layers being downloaded.
- **Points to:** Pattern evidence only; navigation is an auto-reject (safety-critical) and OpenTracks-style recorders are an already-checked dead end.

---

## Checked and rejected (so they don't get re-mined)

- **Archaeology field recording** — searched via `lite.duckduckgo.com`; the space is crowded with offline-capable products already (Field Vantage, Diggit, FieldTap, iDAI.field/`github.com/dainst/idai-field`, Brown University's Kiosk which advertises working "entirely independent of the internet"). *unverified — snippets only.*
- **Land surveying / COGO** — crowded; an explicitly offline product already ships (`cogo.vendrato.com`, "all completely offline"), plus X-Survey, Locus GIS, several Play Store toolkits. *unverified — snippets only.*
- **Aircraft maintenance reference** — "AMA Toolkit … the ultimate 100% OFFLINE reference and calculation toolset built for every Aircraft Maintenance Technician" already exists on Google Play, alongside amttoolbox.com and several hangar-reference web apps. *unverified — snippets only.*
- **Wildlife rehabilitation records** — at least six products (Injured2Wild, CritterDesk, Bramble, PawsTrack, IWRC RAVEN); all cloud/records-management shaped. *unverified — snippets only.*
- **Handweaving drafts** — iWeaveIt, WeavePoint, Weave Designer, Seizenn, WeaveAway already cover drawdown editing on tablets; handweaving.net holds 77,000 drafts. Offline is a nice-to-have in a studio, not a necessity → weak lead. *unverified — snippets only.*
- **Mine rescue / underground mining checklists** — search returned only SEO-shaped vendor pages (Inspectly360, "offline-first architecture is mandatory for underground mining apps") and MSHA/GMG PDFs; no first-person ask found. *unverified — snippets only.*
- **Elevator mechanics** — the natural product (wiring diagrams / controller manuals) is manufacturer-copyrighted, and the community is tiny (HW Forums "Elevator Mechanics" shows 166 members / 86 posts). Auto-reject on licensed content. *unverified — snippet only.*
- **Wetland delineation** — plausible on paper (USACE 1987 manual + regional supplements + National Wetland Plant List + hydric soil indicators are all US federal public domain), but I found **no first-person ask** — only that products already exist and are tiny: BioApp: Wetland Delineation (App Store id1579117594, 15 ratings) and Aquod (id6763209904, 5 ratings), both confirmed via the iTunes Search API (VERIFIED FETCH). Small-but-served. Needs a real forum ask before it's worth anything.

---

## no evidence found

Queries and channels that were run and produced nothing usable:

- Stack Exchange API `search/advanced?q=offline app` on sites: **gardening, woodworking, boating, sound, photo, expatriates, sustainability, scifi** — zero results each.
- Stack Exchange API on **outdoors, aviation, ham, bicycles, travel, diy, academia** — results existed but were 100% offline-maps/GPS/navigation questions (an already-checked dead end).
- Stack Exchange **softwarerecs**: full enumeration of the `offline` tag (4 pages, ~300 questions, sorted by votes) plus queries `offline android`, `offline iOS`, `without internet`, `no internet connection`, `works offline field`, `offline identification`, `offline reference`, `offline database app`. Result: overwhelmingly generic desktop/consumer software (markdown editors, PDF viewers, password managers, music players, offline maps). No occupational niche surfaced. `offline identification` returned zero results.
- HN Algolia comment search for `offline app doesn't exist`, `wish there was an offline app`, `no offline app exists`, `had to build my own offline`, `works in airplane mode`, `app that works without internet` — all hits were generic developer/tech discussion, no occupational niche.
- Lemmy (`lemmy.world/api/v3/search`, Comments, TopAll) for `is there an offline app`, `wish there was an app that works offline`, `no app exists offline`, `app that doesn't need internet`, `offline field app` — all hits were generic tech/privacy/gaming threads. `wish there was an app that works offline` returned zero comments.
- F-Droid forum (`forum.f-droid.org`) searches `looking for an offline app`, `app request offline`, `does not exist app offline`, `wish there was`, plus a full read of the 863-post evergreen thread https://forum.f-droid.org/t/what-types-of-apps-are-you-missing-from-the-foss-ecosystem/183 — the entire wishlist is consumer/tech (launchers, weather, clocks, backup, keyboards, dictionaries). Zero occupational/field niches.
- `discourse.gbif.org` searches `offline field data` and `no internet field` — nothing relevant. `discuss.ardupilot.org` search `offline app wish` — nothing relevant. `forum.arduino.cc` — nothing relevant. `community.openstreetmap.org` — only offline-maps threads.
- `forums.aavso.org` (Discourse) searches `offline app`, `no internet in the field`, `app for phone charts` — nothing relevant; amateur variable-star observers are not asking for an offline app in public.
- GitHub issue search via `gh search issues` for `offline app does not exist` (0 results) and `"there is no offline" app` (1 irrelevant result).
- `wildlabs.net` (the obvious conservation-technology community) — **could not be searched at all**, HTTP 403 to both curl and WebFetch. This is a real gap in this sweep and should be retried from another network; it is the single most likely place to find first-person "I need an offline field tool" posts.
- `bto.org` ringer-count pages and `birdforum.net` thread bodies — HTTP 403; the bird-ringing lead above is therefore snippet-only.
- `dco.uscg.mil/nmc/exam_questions/` — HTTP 403, so the current public availability and exact contents of the USCG question banks could **not** be verified and must be checked before committing to that lead.


# ============================================================
# SOURCE FILE: research/raw/de-es.md
# ============================================================

# Phase 1 Discovery — German & Spanish language search

Researcher note on method (important for judging the evidence below):
The session's WebSearch quota was exhausted after 6 queries (the counter is shared across the
orchestration session, not this agent). Brave / Mojeek / DuckDuckGo / SearxNG / Marginalia all
returned CAPTCHA or 403 to direct HTTP afterwards, so general keyword discovery died early.
I switched to evidence sources that stayed reachable:

* the **Apple App Store search API** (`itunes.apple.com/search?...&country=de|es`) — this is a real,
  retrievable snapshot of what exists in the *German* and *Spanish* storefronts, which is exactly the
  "is the language itself the gap?" question I was assigned;
* **WebFetch on apps.apple.com review pages** (real DE/ES user complaints);
* **WebFetch on official/association sites** for data-licence and audience anchoring.

Everything below that says VERIFIED FETCH was actually retrieved on 2026-07-27. Where I could not
open a page or could not confirm a number, I say so.

---

## STRONG / MODERATE LEADS

### Spanish wildland firefighters (bomberos forestales) — no Spanish field pocket guide exists

- **Query:** `itunes.apple.com/search?term=bomberos+forestales&country=es` ; also `extincion incendios forestales` ; `incendios forestales comportamiento`
- **Source:** Apple App Store search API, ES storefront | **URL:** https://itunes.apple.com/search?term=bomberos+forestales&country=es&entity=software&limit=15 | **Date:** 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Searching the Spanish store for "bomberos forestales" returns exactly two things — a wildfire-*news* alert app (Incendios Forestales España, 4.69★, 154 ratings) and a fire-truck arcade game; "extinción incendios forestales" and "incendios forestales comportamiento" return zero results.
- **Points to:** An offline Spanish-language field handbook for forest-fire crews — the Spanish IRPG: watch-out/situación de riesgo checklists, LCES-equivalent, slope-wind-fuel behaviour rules of thumb, safety-zone sizing, hose/pump friction-loss tables, helitransport weight limits, incident-organisation cards, radio protocol templates, personal shift/exposure log.
- **Offline necessity:** Crews work inside the monte with no coverage, smoke, gloves, one hand on a tool; phones are on battery-saver. A spinner or a login screen is a non-starter mid-shift. (The English IRPG is already an offline app — the *language* is the gap, not the concept.)
- **Audience size:** unknown — I could not retrieve a page giving the number of bomberos forestales in Spain. The figure ~20,000 is widely quoted but I did not verify it, so I am not asserting it.
- **Data/licence note:** Regional and MITECO field manuals; anything that is a "disposición legal o reglamentaria" or an "acto/acuerdo/dictamen de organismo público" is *excluded from copyright* by Art. 13 LPI (verified, see licence anchors below). Non-legal training manuals would need re-authoring or a PSI-reuse check under RD 1495/2011. **Liability caveat:** fire-behaviour guidance sits close to the "safety-critical" auto-reject line — a reference/checklist tool is defensible, a predictive spread calculator is not.
- **Language gap:** EXPLICIT. English offline IRPG apps exist; no Spanish/Catalan/Galician/Euskera equivalent found in the ES store.

### Galician marisqueo & Spanish coastal fishing — legal sizes / vedas are web-only, no offline app

- **Query:** `itunes.apple.com/search?term=tallas+minimas+pesca&country=es` (0 results) ; `marisqueo` ; `normativa pesca` ; plus direct fetch of the Xunta's official minimum-size page
- **Source:** Xunta de Galicia — Pesca de Galicia | **URL:** https://www.pescadegalicia.gal/gl/tallas-minimas | **Date:** page live 2026-07-27, underlying rule = Orde do 27 de xullo de 2012 | VERIFIED FETCH
- **Paraphrase:** Galicia's official minimum extraction/commercialisation sizes live as four HTML tables plus measuring diagrams and shellfish-bank exception maps on a government web portal — web-only, no dataset download, no offline mode.
- **Source:** Apple App Store search API, ES storefront | **URL:** https://itunes.apple.com/search?term=tallas+minimas+pesca&country=es&entity=software | **Date:** 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Zero apps in the Spanish store for "tallas mínimas pesca"; the "marisqueo" results are a brand-new tide app and two Galician cofradía notice-board apps (Confraría de Muros, Lonxa de Campelo).
- **Points to:** Offline "¿es legal esta pieza?" reference — species list with photos, the official measuring method diagram per group (bivalvos vs cefalópodos vs crustáceos), minimum size, current veda window, bank-specific exceptions, plus a purely local catch tally. No account, no server.
- **Offline necessity:** You are ankle-deep on an intertidal flat or on rocks, wet hands, no coverage, and the decision (keep or return it alive) has to happen in seconds. This is the textbook case for offline.
- **Audience size:** unknown — the Xunta's own statistics portal (https://www.pescadegalicia.gal/gl/estatisticas, VERIFIED FETCH) publishes lonxa sales, price quotations and OCUPESCA employment series but no licence/permex headcount. Galicia's shellfish-gatherer population is commonly described as a few thousand; I could not verify it.
- **Data/licence note:** The Orde is a regional legal instrument → Art. 13 LPI excludes it from copyright (verified). Diagrams reproduced from the Orde's annexes fall under the same article. Clean commercial position.

### Spanish hunting — the annual "orden de vedas" has no offline reader at all

- **Query:** `itunes.apple.com/search?term=orden+de+vedas&country=es` (0) ; `vedas caza` (0) ; `caza normativa` (0)
- **Source:** Apple App Store search API, ES storefront | **URL:** https://itunes.apple.com/search?term=vedas+caza&country=es&entity=software | **Date:** 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Three different Spanish-language queries for hunting-season/closed-season regulation apps return literally nothing in the Spanish store.
- **Points to:** Per-comunidad-autónoma offline reader of the annual Orden de Vedas — species × dates × permitted methods × comarca/zone × bag limits, with a "what may I shoot here today" answer derived from a stored GPS fix and the offline zone polygons, plus the paper "cartilla de capturas" as a local log.
- **Offline necessity:** The monte at dawn has no coverage; the rules change every season and differ by zone within one region; getting it wrong is a sanction.
- **Audience size:** unknown as a verified figure. Spain-wide licence holders are in the high hundreds of thousands, which is *above* the 3k–50k target — but a single-region product (e.g. Navarra, Asturias, Cantabria, La Rioja) lands squarely inside it.
- **Data/licence note:** Órdenes de Vedas are published in regional gazettes = "disposiciones legales o reglamentarias" → Art. 13 LPI, no copyright (verified). Zone boundaries usually published as regional open-data shapefiles. Downside: content must be refreshed annually — bundle a season, ship an update, still 100% offline at runtime.

### Spanish bodega / enology calculators — Germany has them, Spain does not

- **Query:** `itunes.apple.com/search?term=enologia&country=es` ; `vinificacion` ; `enologia bodega calculo` (0 results)
- **Source:** Apple App Store search API, ES storefront | **URL:** https://itunes.apple.com/search?term=enologia&country=es&entity=software&limit=15 | **Date:** 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The Spanish store's "enología" results are wine-tourism, tasting-note and label-scanner apps plus two supplier-branded tools (Agrovin; Lamothe-Abiet OenoSolutions) and Oenotools, whose last update was 2019 — there is no independent Spanish cellar-calculation app.
- **Source (contrast, German side):** WebSearch result set for "Winzer Kellerwirtschaft App Anreicherung Schwefel Berechnung" | **URL:** https://play.google.com/store/apps/details?id=at.rb.winzer2020 and https://nahe-news.de/2026/03/26/odernheimer-entwickler-bringen-weinrechner-app-fuer-winzer-heraus/ | **Date:** app listing current; article dated 2026-03-26 | *(unverified — from search snippet only; both pages were not opened, and winzerblog.de returned HTTP 500 to both WebFetch and curl)*
- **Paraphrase:** German-speaking winemakers already have at least two dedicated calculation apps covering Aufschwefelung, Entsäuerung/Doppelsalz, Anreicherung and Restsüße; a further German Weinrechner app launched in March 2026.
- **Points to:** Offline Spanish/Catalan cellar calculator: SO₂ libre/total/molecular at a given pH, sulfitado dosing per hL, corrección de acidez (tartárico / carbonato cálcico / bitartrato), chaptalización within the legal ceiling, Baumé/Brix/densidad → grado probable, cuadrado de Pearson for blends, tank volume from dip-stick geometry, coadyuvante dosing, plus a local batch log per depósito.
- **Offline necessity:** Cellars are thick-walled concrete/steel sheds; the decision is taken standing at the tank at 3 a.m. during vendimia with wet hands. Nobody walks outside to get a bar of signal to work out a sulphite addition.
- **Audience size:** unknown as a verified count. Spain has roughly four thousand registered bodegas and a few thousand practising enólogos — that band is exactly the target size, but I could not retrieve a page to confirm it.
- **Data/licence note:** Legal ceilings come from EU Reg. (EU) 2019/934 annexes and Spanish RD — EU/Spanish law, freely reusable (Art. 13 LPI; Commission Decision 2011/833/EU for EU documents). The chemistry itself (Henderson-Hasselbalch for molecular SO₂, Pearson square) is not copyrightable.
- **Language gap:** EXPLICIT — DE market served by ≥2 dedicated tools, ES market (largest vineyard area in the world) served by none that is independent and offline.

### German field ecology / Kartierung — the German store is empty

- **Query:** `itunes.apple.com/search?term=Vegetationsaufnahme&country=de` (0) ; `Pflanzensoziologie` (0) ; `Biotopkartierung` (0) ; `Brutvogelkartierung` (0) ; `Zeigerwerte` (0) ; `Kartierung Arten` (0)
- **Source:** Apple App Store search API, DE storefront | **URL:** https://itunes.apple.com/search?term=Biotopkartierung&country=de&entity=software | **Date:** 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Six separate German technical terms for field ecological survey work return zero apps each in the German storefront, while adjacent professional verticals (Baumkontrolle, Schornsteinfeger) return 9–14 apps.
- **Points to:** An offline relevé/mapping recorder in German: plot header (Fläche, Exposition, Neigung, Deckung je Schicht), searchable German vascular-plant list by 4-letter code, Braun-Blanquet cover-abundance picker, repeat-visit comparison, on-device computation of mean Ellenberg indicator values, Biotoptyp key of the relevant Bundesland, CSV/Turboveg export by file share.
- **Offline necessity:** Bogs, dunes, alpine grassland, forest interiors and night-time amphibian/bat transects — all-day sessions where the phone must not burn battery on radios, and where the current practice is a clipboard because nobody trusts a cloud form.
- **Audience size:** unknown. I fetched https://www.bbn-online.de/ (Bundesverband Beruflicher Naturschutz, VERIFIED FETCH) hoping for a membership count and the site publishes none; it only cites 150 federally recognised conservation associations as of 2026-01-07.
- **Data/licence note:** Would need a German species list (GermanSL is publicly distributed — licence NOT verified by me), Ellenberg-type indicator values (the 2023 European re-analysis is believed to be CC-BY — NOT verified by me), and Bundesland Biotoptypen keys, which as amtliche Werke are covered by §5 UrhG. **Verify both dataset licences before building.**

### German pomology / determining old apple & pear varieties

- **Query:** `itunes.apple.com/search?term=Pomologie&country=de` (0) ; `Apfelsorten bestimmen` (2)
- **Source:** Apple App Store search API, DE storefront | **URL:** https://itunes.apple.com/search?term=Apfelsorten+bestimmen&country=de&entity=software | **Date:** 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** "Pomologie" returns zero apps; "Apfelsorten bestimmen" returns two thin consumer apps, one at 3.29★ from 7 ratings and one with no ratings at all — nothing resembling a serious determination key.
- **Source:** Pomologen-Verein e.V. | **URL:** https://www.pomologen-verein.de/ | **Date:** 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The association describes 20+ years of members preserving varieties and running Sortenbestimmung, and already ships a fruit-tree app ("APP SEPP") — but publishes no membership figure anywhere on the homepage.
- **Points to:** Offline dichotomous determination key for old German/Austrian/Swiss apple and pear varieties — Kelchgrube/Stielgrube morphology, Kernhaus cross-section, Berostung, Schalenpunkte, ripening window, regional distribution, with a side-by-side candidate comparison and a local find log.
- **Offline necessity:** Determination happens in a Streuobstwiese or at a village Sortenausstellung — rural, poor coverage, fruit in one hand and a knife in the other.
- **Audience size:** unknown (association publishes none). The realistic pool — Pomologen-Verein members plus Streuobst practitioners and Obst- und Gartenbauverein Sortenbestimmer in DE/AT/CH — is plausibly a few thousand, i.e. in range, but this is my estimate and not a retrieved figure.
- **Data/licence note:** 19th-century German pomological standard works (Lucas, Oberdieck, Engelbrecht) are long out of copyright and contain both descriptions and plates — an unusually clean public-domain corpus. Modern association lists (e.g. Rote Liste alter Obstsorten) are *not* free and must be avoided.

---

## WEAKER / HONEST-DOUBT LEADS

### Spanish sign-language dictionary — the leading tools require a connection

- **Query:** `itunes.apple.com/search?term=lengua+de+signos&country=es`
- **Source:** Apple App Store search API, ES storefront | **URL:** https://itunes.apple.com/search?term=lengua+de+signos&country=es&entity=software | **Date:** 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The Sématos LSE/LSC/LSF dictionary's own store description states plainly that the app requires an internet connection; the main alternative, CNSE's DILSE (10,000+ signs, 887 ratings), is a portal-backed dictionary.
- **Points to:** A fully offline LSE dictionary/phrasebook.
- **Offline necessity:** Moderate — a deaf user in a hospital corridor, a rural clinic or on the metro genuinely cannot wait for a video to buffer.
- **Audience size:** unknown; DILSE's 887 ratings is the only retrieved number.
- **Data/licence note:** **Blocker.** Sign dictionaries are video corpora owned by CNSE/Sématos — not licensable for commercial reuse. Building this means filming ~10k signs. That is why nobody has done it, and it is why I rate this weak despite the clear demand.

### Spanish phytosanitary vademécum — offline is already being sold as a feature

- **Query:** `itunes.apple.com/search?term=fitosanitarios&country=es`
- **Source:** Apple App Store search API, ES storefront | **URL:** https://itunes.apple.com/search?term=fitosanitarios&country=es&entity=software&limit=15 | **Date:** 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Among 14 Spanish phytosanitary apps, Lainco Agro explicitly advertises fast **offline** access to product datasheets in the field, and Vademécum Fito/Nutri has not been updated since 2018 — i.e. the market wants offline, and the neutral reference is stale.
- **Points to:** Offline vademécum of MAPA-registered plant-protection products: crop × pest → authorised actives, dose per hL/ha, plazo de seguridad, tank-mix order, LMR, EPI required.
- **Offline necessity:** Real (invernadero, parcela, tractor cab) but partly a convenience.
- **Audience size:** far above 50,000 (carné de aplicador holders) — outside the brief's target band.
- **Data/licence note:** The Registro de Productos Fitosanitarios is an official public register → Art. 13 LPI. **But** registrations are revoked/changed continuously, so a bundled snapshot goes stale and the app edges toward needing live data. Flagged accordingly.

### German cattle hoof trimming (Klauenpflege)

- **Query:** `itunes.apple.com/search?term=Klauenpflege&country=de`
- **Source:** Apple App Store search API, DE storefront | **URL:** https://itunes.apple.com/search?term=Klauenpflege&country=de&entity=software | **Date:** 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Exactly one app exists (Klauenprofi), and it is restricted to LKV member farms in DE/AT.
- **Points to:** Offline hoof-lesion recording on the trimming crush — standard lesion codes per claw/zone, per-cow history, herd lameness summary.
- **Offline necessity:** Strong (steel barn, no signal, filthy wet gloves, animal restrained for 90 seconds).
- **Audience size:** likely well under the 3,000 floor for professional trimmers in Germany alone; would need DE+AT+CH+ES to be viable. Unverified.
- **Data/licence note:** The ICAR Claw Health Atlas is the de-facto lesion standard and is freely downloadable — licence for redistribution NOT verified.

---

## USEFUL NEGATIVE RESULT: the classic German trades are already saturated and already offline

Retrieved 2026-07-27 from the DE storefront via the App Store search API (all VERIFIED FETCH):

- **Schornsteinfeger** (`term=Schornsteinfeger&country=de`) — 14 apps. AgzessMobile's own description advertises working "ganz ohne bestehende Internetverbindung"; ZIV-Handwerksregeln sits at 4.55★ with 95 ratings; TIS Mobile bundles each Bundesland's KÜO/FeuVO. Nothing to build here.
- **Baumkontrolle / Baumkataster** — 9 and 8 apps, including IP SYSCON's MQ ("primär offline") and SUN-Mobil ("Erfassung … offline (ohne Internet)"), plus StammDaten doing FLL-2020 tree inspection with LiDAR and NFC. Saturated.
- **Gefahrgut / ADR** — Gefahrgut-Helfer at 4.65★ from 1,446 ratings with the full ADR 2025 database offline. Saturated.
- **Jagd / Schonzeiten** — Revierwelt and Jagdgefährte both market offline maps; Hunting Plus (4.39★, 107 ratings) and a brand-new "Jagdzeiten" app already cover all 16 Bundesländer; Fangzeit and PetriCheck cover angling closed seasons across DE/AT/CH and beyond. Saturated.
- **Handwerker/Baustelle** — MeinHandwerker-App, Werkli, das Programm, plancraft all ship offline modes for Keller/Tiefgarage/Funkloch (WebSearch result set, 2026-07-27, unverified — from search snippet only).
- **Atemschutzüberwachung (Feuerwehr)** — Dräger FireGround builds its own on-scene network, MissionBuddies works without internet, MP-FEUER ASD is free for all DE/AT/CH fire services (WebSearch result set, unverified — from search snippet only).

Conclusion for the German market: the gap is **not** in the well-organised trades (each has a Verband and a software vendor). It is in the *unorganised expert hobby/field-science* niches — vegetation and species mapping, pomology — where there is no Verband big enough to commission software.

---

## LICENCE ANCHORS (both VERIFIED FETCH, 2026-07-27)

- **Germany — §5 UrhG:** https://www.gesetze-im-internet.de/urhg/__5.html — "Gesetze, Verordnungen, amtliche Erlasse und Bekanntmachungen sowie Entscheidungen … genießen keinen urheberrechtlichen Schutz." So Landesverordnungen (Schonzeiten, Biotoptypenschlüssel, KÜO) can be bundled commercially.
- **Spain — Art. 13 LPI:** https://www.boe.es/buscar/act.php?id=BOE-A-1996-8930&p=20190302&tn=1#a13 — "No son objeto de propiedad intelectual las disposiciones legales o reglamentarias … los actos, acuerdos, deliberaciones y dictámenes de los organismos públicos, así como las traducciones oficiales." So órdenes de vedas, tallas mínimas and regional fishing/hunting orders can be bundled commercially.

These two anchors are what make the ES/DE regulatory-reference leads above buildable at all.

---

## COMPLAINT EVIDENCE ACTUALLY RETRIEVED (thin, and I want to be honest about it)

### PescaREC (official Spanish recreational-fishing app) is rated 1.9/5
- **Query:** apps.apple.com review page for PescaREC
- **Source:** Apple App Store ES reviews | **URL:** https://apps.apple.com/es/app/pescarec/id6752486687?see-all=reviews | **Date:** reviews from late 2025–2026 | VERIFIED FETCH
- **Paraphrase:** 1.9★ from 12 reviews: registration and licence-detection failures, mandatory-field errors, and strong resistance to uploading fishing locations, which users treat as private.
- **Points to:** Reinforces the offline-reference lead above — a private, on-device tool that never transmits a position is the exact opposite of what fishers are rejecting here.
- **Offline necessity:** Privacy as much as coverage — "mis zonas son secretas" is a data-must-not-leave-the-device argument.
- **Honest caveat:** No reviewer explicitly complained about lack of coverage at sea. I am not going to pretend they did.

### Pesca en Castilla y León (official regional app) — 2.3/5, content wrong
- **Source:** Apple App Store ES reviews | **URL:** https://apps.apple.com/es/app/pesca-en-castilla-y-le%C3%B3n/id1672539106?see-all=reviews | **Date:** reviews 2024-05 to 2026-03 | VERIFIED FETCH
- **Paraphrase:** Anglers report wrong season end-dates for some river stretches and days marked as kill-permitted when the region is catch-and-release only.
- **Points to:** The official regulation apps are inaccurate, which is a straightforward opening for a carefully-curated offline one.
- **Audience size:** unknown; the app has only 4 ratings.

### GSA (Umweltbundesamt hazmat app for German responders) — 2.6/5, login failures
- **Source:** Apple App Store DE reviews | **URL:** https://apps.apple.com/de/app/gsa/id1486352326?see-all=reviews | **Date:** retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Reviewers report crashes on search and, after updates, being unable to log in at all — an emergency reference tool gated behind authentication.
- **Points to:** Generic principle for this whole hunt: an account gate is itself the failure mode people complain about, even when the data is local.
- **Honest caveat:** No reviewer said "doesn't work without internet" in so many words.

---

## no evidence found

Queries and fetches that produced nothing usable:

- `"gibt es eine App" die "ohne Internet" funktioniert Forum gesucht` (WebSearch) — only SEO listicles ("12 Offline-Apps", "7 tolle offline Apps"), no real user demand signal. **no evidence found.**
- `"aplicación que funcione sin internet" foro campo sin cobertura` (WebSearch) — only listicles and mesh-messenger articles. **no evidence found.**
- `Handwerker Baustelle App offline kein Empfang Keller Aufmaß Forum` (WebSearch) — returned vendor marketing pages only, all of which already offer offline mode; confirms saturation rather than a gap.
- `Feuerwehr Atemschutzüberwachung App offline Einsatzstelle kein Netz Forum` (WebSearch) — four existing offline-capable solutions; niche closed.
- `gutefrage.net "App ohne Internet"` — **never executed**: the WebSearch quota ran out on this exact query, and every fallback engine (Brave, Mojeek, DuckDuckGo html/lite, searx.be, baresearch.org, priv.au, Marginalia) returned CAPTCHA/403/429. **no evidence found; site not sampled.**
- forum.wildundhund.de threads "Welche Revierapp nutzt ihr?" / "Jagdliche Apps" — HTTP 403 to WebFetch (XenForo/Cloudflare). Could not read the bodies. **(unverified — from search snippet only:** a snippet indicated a hunter saying he cannot make location-based entries in parts of his Revier because there is no reception.**)**
- winzerblog.de "10 kellerwirtschaftliche Smartphone Apps die ich gerne hätte" — HTTP 500 to both WebFetch and curl with a browser UA. This looked like the single best German wishlist source for the wine lead and I could not open it. **no evidence retrieved.**
- landtreff.de (phpBB, guest search works): `App offline Netz` → "Die Suche ergab 3 Treffer" but the result rows did not parse and I could not extract the thread URLs; `kein Empfang App` and `Funkloch` returned pages my parser could not read. **no citable evidence.**
- forocoches.com / meneame.net / imkerforum.de — homepages reachable via curl (HTTP 200) but their search endpoints require login or JS; not sampled.
- https://www.pescadegalicia.gal/gl/estatisticas — VERIFIED FETCH, but publishes **no** count of licensed mariscadores/permex. Audience size for that lead stays unknown.
- https://www.pomologen-verein.de/ — VERIFIED FETCH, publishes **no** membership figure.
- https://www.bbn-online.de/ — VERIFIED FETCH, publishes **no** membership figure.
- es.wikipedia "Marisqueo", "Bombero", "Caza" — VERIFIED FETCH via the MediaWiki API; none contain the headcounts I needed.
- `itunes.apple.com/search?term=Grabungsdokumentation&country=de` → 0 results. Archaeological field recording looked like a gap, but the DAI's free, offline-capable Field Desktop already serves it, so I did not pursue it.
- reddit.com — not attempted, per the environment warning.


# ============================================================
# SOURCE FILE: research/raw/pt-id.md
# ============================================================

# Phase 1 Discovery — Brazilian Portuguese & Indonesian
Researcher pass date: 2026-07-27

## Method / tooling note (read before trusting anything below)
- Reddit was **not** touched (blocked per brief). No reddit URL appears here.
- The `WebSearch` tool budget (200/200) was exhausted after 8 queries. Remaining searches were run through
  (a) `lite.duckduckgo.com` fetched via WebFetch, (b) Brave Search HTML fetched via curl, (c) the **iTunes Search API**
  (`itunes.apple.com/search`), (d) **Google Play store search pages** fetched via curl, and (e) the **OpenAlex** works API.
  DuckDuckGo and Brave both began serving CAPTCHA/429 partway through; several public SearxNG instances, Mojeek,
  Ecosia, Startpage and Bing were all blocked or JS-only from this environment.
- `gov.br` (Brazilian federal), `tanamanpangan.pertanian.go.id` and `uptptph.kalbarprov.go.id` all return **401/403**
  to both WebFetch and curl from here. Where I wanted a number from those, I say "unknown".
- **Play Store / App Store search results are used as *negative* evidence** ("nobody built it"). Those searches were
  genuinely executed and their raw result lists are quoted in each finding.

---

### Indonesia — POPT (Pengendali/Pengamat Organisme Pengganggu Tumbuhan): offline pest-scouting & fortnightly reporting
- **Query:** `jumlah petugas POPT pertanian Indonesia kekurangan tenaga pengamat hama` (Brave) → then direct fetch
- **Source:** Change.org petition (Indonesian national POPT community) | **URL:** https://www.change.org/p/popt-siap-menjadi-bagian-kementerian-pertanian-untuk-mengawal-swasembada-pangan-indonesia | **Date:** references the Komisi IV DPR RI / Kementan working meeting of 10 June 2026; retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** A live national petition by Indonesia's crop-protection field officers, carrying **4,183 verified signatures**, describes POPT as the technical staff who do pest observation, forecasting, control and farmer coaching in production centres, and asks that their employment be moved under the Ministry of Agriculture.
- **Points to:** An offline-first Android field notebook that implements the official POPT observation protocol (fixed sample plots + patrol) with species/damage counts, automatic attack-intensity and area-affected maths, and export of the standard fortnightly report form.
- **Offline necessity:** The whole job is standing in a paddy field or plantation block counting tillers and hoppers; POPT sub-areas are deliberately remote production centres, and the officer must key numbers while hands are on the crop, not wait on a login.
- **Audience size:** ≥4,183 (verified petition signatures, a floor not a ceiling). Sibling profession for context: **31,500 penyuluh pertanian** in service (Republika, 11 Feb 2019, https://www.republika.co.id/berita/ekonomi/pertanian/19/02/11/pmrk9g423-indonesia-kekurangan-40-ribu-penyuluh-pertanian — VERIFIED FETCH).
- **Data/licence note:** Bundle Kementan's own *Juknis Pengamatan dan Pelaporan OPT dan DPI Tanaman Pangan* (pest list, sampling rules, damage categories). PDF confirmed live and downloadable: HTTP 200, `application/pdf`, 1,891,956 bytes, `Content-Disposition: filename="Juknis pengamatan OPT dan DPI Tanaman Pangan.pdf"` at https://mplk.politanikoe.ac.id/index.php/info-ps-mplk/download/category/4-e-book-panduan?download=32%3Ajuknis-pengamatan-opt-dan-dpi-tanaman-pangan (headers verified; I did **not** parse the PDF body). Indonesian government technical guidance — needs a licence check but is distributed freely by state institutions.

### Indonesia — the official OPT reporting system is explicitly *online-based* (the gap, stated by the ministry itself)
- **Query:** `aplikasi pengamatan OPT POPT lapangan offline sinyal laporan mingguan padi` (Brave)
- **Source:** Tempo (Kementan advertorial) | **URL:** https://www.tempo.co/info-tempo/kementan-aplikasi-silap-opt-efektif-kendalikan-hama-tanaman-578147 | **Date:** 28 September 2020 | VERIFIED FETCH
- **Paraphrase:** The ministry says OPT observation used to be recorded on paper in the field and that its replacement, Silap OPT, is a **web/Android system "berbasis online"** whose point is getting data to headquarters fast — i.e. the design centre of gravity is the server, not the officer standing in the field.
- **Points to:** The same POPT app as above, positioned as the *capture* layer that Silap OPT never was: works cold in airplane mode, produces the exact numbers the officer then types into the government portal back at the office.
- **Offline necessity:** The ministry's own framing ("data langsung diinput ketika melakukan pengamatan") only works if the app does not need a network at the moment of observation; the current one does.
- **Audience size:** see previous finding.
- **Data/licence note:** No content needs to be copied from Silap OPT — only the published observation methodology.

### Indonesia — POPT observation protocol is dense enough to be a real 2-month build
- **Query:** same Brave query as above
- **Source:** Politeknik Pertanian Negeri Kupang (MPLK teaching material) | **URL:** https://mplk.politanikoe.ac.id/index.php/pengelolaan-opt/1118-pengamatan-tetap-opt-tanaman-pangan | **Date:** undated course page; retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The protocol splits each officer's territory into 4 sub-areas, each with one permanent sample plot plus roaming patrol, with week-1 and week-2 rounds aggregated into first-half-of-month and second-half-of-month reports, plus ad-hoc "laporan khusus" when an outbreak trend appears.
- **Points to:** Territory model + plot model + rolling fortnight aggregation + incident reports — genuinely fiddly state management, which is exactly why no indie has done it.
- **Offline necessity:** Rounds happen on foot across four scattered sub-areas; the aggregation must survive a phone that never sees a tower during the round.
- **Audience size:** see first finding.
- **Data/licence note:** Methodology is public teaching/state material; pest species list would come from the Juknis.

### Indonesia — market-level proof that "offline" is a first-class product requirement, not a nice-to-have
- **Query:** Google Play ID store search `rekomendasi pemupukan spesifik lokasi kecamatan`
- **Source:** Google Play (Indonesia storefront) | **URL:** https://play.google.com/store/apps/details?id=gov.kementan.ipubers_off | **Date:** retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The Ministry of Agriculture ships a **separate build literally named "iPubers Offline"** for subsidised-fertiliser redemption (publisher "Integrasi Pupuk Bersubsidi Kementan - PIHC"), rated 2.8 with 1k+ downloads — a government that had to fork its own app because rural kiosks have no signal.
- **Points to:** Not an app idea in itself; it is the strongest single piece of evidence that Indonesian rural software fails on connectivity and that an offline-first competitor has room.
- **Offline necessity:** Confirmed by the state's own product decision.
- **Audience size:** n/a (evidence item).
- **Data/licence note:** n/a.

### Indonesia — nelayan tide/sea data: the only Indonesian-language app "solves" offline by caching on land
- **Query:** Google Play ID store search `pasang surut offline nelayan`
- **Source:** Google Play (Indonesia storefront) | **URL:** https://play.google.com/store/apps/details?id=com.harisdevs.cekpasangsurutairlaut | **Date:** retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The listing's own selling point #8 is "Mode Hemat Kuota (Offline)" and it opens by asking whether you *keep losing signal out at sea* — but it only replays data that was already loaded while on land; 1k+ downloads, and every other result in that search is a foreign English-language tide app.
- **Points to:** A true offline tide/moon/current predictor for Indonesian ports computed on-device from harmonic constants, in Indonesian, that is correct on a cold first launch in airplane mode.
- **Offline necessity:** Very strong — small-boat fishers lose signal within a few km of shore and the tide decision (when to cross the reef flat, when the estuary mouth is passable) is taken at sea.
- **Audience size:** unknown for this app's actual user base beyond "1 rb+ downloads"; the national artisanal-fisher population is far larger than the 3k–50k target, so the addressable slice would need narrowing (e.g. one province, or tambak/aquaculture pond operators).
- **Data/licence note:** ⚠️ **Weakest point.** Tide harmonic constants for Indonesian stations are BIG/Pushidrosal products with unclear commercial-reuse terms; global open alternatives (FES/TPXO) are largely academic-use-only. Would need a real licence audit before this is buildable. Marking this lead **Weak** for that reason, despite the excellent offline story.

### Indonesia — petugas IB / inseminator: cattle breeding records in villages with no signal
- **Query:** `inseminator "inseminasi buatan" aplikasi pencatatan ternak offline iSIKHNAS SMS kendala sinyal desa` (WebSearch) + Google Play ID search `inseminasi buatan sapi pencatatan inseminator`
- **Source:** Google Play (Indonesia storefront), result list | **URL:** https://play.google.com/store/search?q=inseminasi%20buatan%20sapi%20pencatatan%20inseminator&c=apps&hl=id&gl=ID | **Date:** retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The Indonesian store returns no Indonesian-language insemination record-keeping tool — the hits are generic foreign herd managers (`com.bivatec.cattle_manager`, `com.zaheer.livestock`, `com.kelimesoft.suruyonetimi`) plus a Brazilian Embrapa app; the only domestic hit is a general `peternak.os.swv` farmer app.
- **Points to:** An offline service-record app for AI technicians: cow ID, oestrus date, straw/bull code, service number, expected calving date, PKB/ATR follow-up dates, per-farmer roster — the exact fields iSIKHNAS asks for, captured before there is any signal.
- **Offline necessity:** Strong — the technician works standing in a village kandang, often on a motorbike route through areas the brief would call "deep rural"; the historical national workaround was SMS-based reporting.
- **Audience size:** unknown from a verified page. (iSIKHNAS wiki page https://wiki.isikhnas.com/w/Farmer_Registration_and_Animal_ID returned HTTP 500 when I tried to open it, so its content is **unverified - from search snippet only**: snippet said farmer/animal registration is performed by inseminators in their villages.)
- **Data/licence note:** Almost no bundled dataset needed — a small gestation-table and breed/straw reference. Licence risk near zero. Downside: this is close to a "logbook", so it must earn its keep on domain depth (gestation maths, service-per-conception stats, government report shapes).

### Indonesia — bidan desa / e-Kohort KIA: connectivity is a named implementation problem (but a poor indie target)
- **Query:** `aplikasi bidan desa offline pencatatan kohort tanpa sinyal kendala` (DuckDuckGo Lite via WebFetch)
- **Source:** DuckDuckGo results page listing Indonesian midwifery journals | **URL:** https://lite.duckduckgo.com/lite/?q=aplikasi+bidan+desa+offline+pencatatan+kohort+tanpa+sinyal+kendala | **Date:** retrieved 2026-07-27 | VERIFIED FETCH of the results page; the underlying journal articles are **unverified - from search snippet only**
- **Paraphrase:** Multiple Indonesian nursing/midwifery journals evaluate e-Kohort KIA rollout and the snippets repeatedly flag incomplete data capture and **network connectivity problems**, alongside complaints that the paper cohort register is slow and has too many columns.
- **Points to:** An offline pre-capture companion for the maternal/child cohort register.
- **Offline necessity:** Real (village posyandu, home visits) — but…
- **Audience size:** unknown; Indonesian village midwives number in the tens of thousands.
- **Data/licence note:** ⚠️ **I recommend rejecting this.** It is a mandatory government reporting instrument, so an unofficial app cannot close the loop, and anything touching pregnancy risk scoring drifts toward the medical-liability exclusion in the brief. Logged for completeness only. **Weak.**

### Indonesia — juru sembelih halal (JULEHA): organised, named, certified community — but thin offline case
- **Query:** `aplikasi juru sembelih halal juleha offline panduan tanpa internet` (DuckDuckGo Lite via WebFetch)
- **Source:** Asosiasi JULEHA Indonesia | **URL:** https://www.juleha.or.id/ | **Date:** retrieved 2026-07-27 | VERIFIED FETCH (site opened; **no membership figures published on it**)
- **Paraphrase:** There is a formal national association of halal slaughtermen founded in Gresik in 2016 offering SKKNI-based competency training, i.e. a genuinely nameable, certifiable community — but the site publishes no headcount.
- **Points to:** An offline SKKNI-based slaughter competency checklist / animal-welfare pre-slaughter inspection recorder for Idul Adha temporary slaughter points.
- **Offline necessity:** Weak-to-moderate — mosque yards and village slaughter points during Idul Adha are crowded and network-congested, and hands are wet/busy, but "offline is fine too" is an honest verdict here.
- **Audience size:** unknown (association publishes none).
- **Data/licence note:** The competency standard is SKKNI (Indonesian national work-competency standard, government-issued) — likely usable, but the substance overlaps paid halal-certification training material. **Weak.**

### Brazil — offline per-state fishing-legality reference (piracema / tamanho mínimo / cota / apetrechos)
- **Query:** `aplicativo offline tamanho mínimo de captura pesca amadora espécies permitido Brasil` (DuckDuckGo Lite) + Google Play BR searches `pesca defeso tamanho minimo` and `piracema legislacao pesca estado` + iTunes Search API `pesca amadora defeso` / `pesca tamanho minimo legislacao` (both `count=0` in the BR storefront)
- **Source:** Pesca na Regra (web-only aggregator) | **URL:** https://pescanaregra.com.br/pesca/sao-paulo/ | **Date:** page states "atualizado em 2026-04-25"; retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Someone has already done the hard editorial work of normalising all 27 states' piracema dates, minimum sizes, quotas and licence rules — but only as a **website**, and the São Paulo page even spells out quota rules ("até 10 kg + 1 exemplar de espécies não nativas") and the 1,500 m exclusion around dams and rapids that a fisher needs to know while standing on the bank.
- **Points to:** An offline app that answers "can I legally keep this fish, right here, right now?" — pick state/basin → species → measured length vs. legal minimum → in/out of defeso → daily quota → gear legality, with a ruler screen and a species picker by common regional name.
- **Offline necessity:** Very strong and non-negotiable: the decision happens on a riverbank, a reservoir or a boat, i.e. precisely where there is no signal, and it has to be answered in seconds while the fish is alive.
- **Audience size:** unknown from a page I could actually open — every federal source (gov.br/mpa) returned 401/403 to me, so I will not guess a licence-holder count. The *named, findable* slice is Brazilian sport-fishing clubs, guides and pesqueiro operators.
- **Data/licence note:** The content is IBAMA/MPA/state normative instructions and portarias. Brazilian Lei 9.610/1998 art. 8 excludes official acts (leis, decretos, regulamentos) from copyright, so verbatim rule text should be commercially reusable — **must be re-verified with a lawyer**, and the app must never scrape pescanaregra.com.br's own editorial compilation.
- **Competitive check (VERIFIED FETCH):** Google Play BR search for `piracema legislacao pesca estado` returned **only fishing video games and foreign forecast apps** (`com.tensquaregames.letsfish2`, `com.FishingPlanetLLC.FishingPlanet`, `com.miros.whentofish`…). The search for `pesca defeso tamanho minimo` surfaced exactly one relevant Brazilian app, `seguro.defeso.app.consulta`, which is a *benefit-payment lookup* (needs a server), not a rules reference. Apple's BR storefront returns `resultCount=0` for both regulation queries.

### Brazil — Caderneta Agroecológica: a real, documented methodology with zero digital tooling
- **Query:** OpenAlex works API, `caderneta agroecologica mulheres agricultoras` + Google Play BR search `caderneta agroecologica`
- **Source:** OpenAlex API / Revista de Educação Popular (UFU) | **URL:** https://doi.org/10.14393/rep-2022-62077 | **Date:** 2022 (record retrieved 2026-07-27) | VERIFIED FETCH (OpenAlex returned **17 works**; I also opened the article landing page)
- **Paraphrase:** The "caderneta agroecológica" is an established field instrument in which rural women record everything their backyard/plot produces — consumed, given away, bartered, sold — to make invisible female farm economics visible; documented in use across the Bahia semi-arid Pró-Semiárido programme, Minas Gerais Zona da Mata and the Nordeste II region.
- **Points to:** An offline weekly production notebook modelled exactly on the paper caderneta: product list with regional names, unit conversions (lata, prato, molho, cambada), destination categories (consumo / troca / doação / venda), weekly cycle, and end-of-cycle totals — with everything staying on the phone.
- **Offline necessity:** Strong on two counts: the recording moment is in the quintal/roça in the semi-arid interior where there is no coverage, **and** the data is household income detail that women in these programmes have concrete reasons not to upload anywhere.
- **Audience size:** unknown as a headcount — the literature describes programme-level cohorts (Pró-Semiárido/BA, CTA-ZM/MG, Nordeste II) rather than a national total. Directionally this looks like a low-thousands-to-low-tens-of-thousands community, which is the right band, but **I could not verify a number and will not invent one.**
- **Data/licence note:** Almost no bundled data required — the value is the domain-correct data model plus regional unit vocabulary. Anything reused from a specific NGO's caderneta layout needs permission; the underlying method is described in openly-licensed academic literature.
- **Competitive check (VERIFIED FETCH):** Google Play BR search `caderneta agroecologica` returns **no such app** — only generic agri products (Agrio, xFarm, Plantix, AgroBEET, `br.embrapa.pisciculturacerta`). iTunes BR `caderneta agroecologica` → `resultCount=0`.

### Brazil — rural drinking-water operators (chlorine/turbidity logs): open field, no listing found
- **Query:** Google Play BR search `cloro residual analise agua tratamento`
- **Source:** Google Play (Brazil storefront) results | **URL:** https://play.google.com/store/search?q=cloro%20residual%20analise%20agua%20tratamento&c=apps&hl=pt_BR&gl=BR | **Date:** retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The Brazilian store has utility-side and consumer-side water apps (`br.gov.ana.aguasesgotos`, `br.gov.ana.declaraagua`, Sabesp, Aegea, plus a pile of "drink more water" reminders) but nothing for the person who walks to a small rural treatment unit and writes down residual chlorine, pH and turbidity.
- **Points to:** An offline operator logbook for small/rural water systems: per-point sampling schedule, residual-chlorine and turbidity entry with in-range/out-of-range logic against the national potability standard, monthly summary export.
- **Offline necessity:** Moderate-to-strong — pump houses, reservoirs and rural treatment skids are exactly the "basement/machine room, deep rural" case in the brief.
- **Audience size:** unknown; not verified. Indonesian mirror of the same gap: Play ID search `pamsimas kpspams air minum desa` also returned no village water-committee field app (only PDAM/meter apps and hydration trackers) — VERIFIED FETCH.
- **Data/licence note:** Potability parameter limits come from the Brazilian Ministry of Health potability annex (official act, likely reusable) — but this lead is **Speculative** until I find real operator complaints, and it risks reading as a generic logger.

### Brazil — meliponicultura (native stingless bees): genuinely *different* from the rejected beekeeping lead, but already contested
- **Query:** iTunes Search API `meliponicultura abelhas nativas` (BR) + Google Play BR search `meliponicultura abelha sem ferrao`
- **Source:** Apple App Store BR / Google Play BR | **URL:** https://apps.apple.com/br/app/beeapp-abelha-sem-ferr%C3%A3o/id6782711253 | **Date:** retrieved 2026-07-27 | VERIFIED FETCH (iTunes API record: 0 ratings; Play listing `br.app.bee.beeapp` shows only **5+ downloads**)
- **Paraphrase:** Brazilian stingless-bee keeping already has at least four domestic apps — BeeApp (`br.app.bee.beeapp`), MeliponApp (`com.cleios.meliponapp`), IFBee (`com.programaandroid.ifbee`) and `app.beeh` — but all are tiny/new, so the niche is occupied rather than solved.
- **Points to:** If pursued at all, the differentiator would be the part none of them do: an offline **species identification key** for Brazilian Meliponini plus the SisFauna/IBAMA legal-keeping rules per species and state.
- **Offline necessity:** Moderate — meliponários are in quintais and rural properties, often without coverage.
- **Audience size:** unknown.
- **Data/licence note:** Species data would come from taxonomic literature and Flora/Fauna do Brasil-style open datasets; must be checked. **Given the brief explicitly lists beekeeping hive logs as a dead end, I am flagging this Weak and not recommending it.**

---

## Rejected on contact (already served — do not spend time here)
- **Brazil, ACS / e-SUS Território** — the Ministry of Health's own Android app for community health agents already has an offline mode and is described as used by 100k+ professionals. *(unverified - from search snippet only; source: https://manualdaweb.com/aplicativos/e-sus-territorio/ and https://sisaps.saude.gov.br/sistemas/esusaps/docs/manual/TERRITORIO/territorio_02/)*
- **Indonesia, kader posyandu** — KaderKita (https://www.kaderkita.com/) and the Ministry's ASIK both advertise offline posyandu capture with later auto-upload. *(unverified - from search snippet only)*
- **Brazil, caminhoneiros / diário de bordo** — at least four commercial products already advertise offline journey capture: diarioabordo.com.br, https://diario.app/, https://www.borealbr.com.br/, https://www.g2trucker.com.br/. *(unverified - from search snippet only, via https://lite.duckduckgo.com/lite/?q=aplicativo+offline+caminhoneiro+jornada+di%C3%A1rio+de+bordo+sem+sinal+estrada, VERIFIED FETCH of the results page)*
- **Brazil, agrotóxico carência / AGROFIT** — Compêndio Agrícola (AgroReceita) and AgroApp already ship AGROFIT-derived data offline. *(unverified - from search snippet only)*
- **Brazil, Normas Regulamentadoras (NR) readers** — iTunes BR returns five live apps (Consultor NR, SST - Central | NR, NHO e CA, SegTrab Pocket, GNRx - Auditoria, Escola SST Online). *(VERIFIED FETCH via iTunes Search API)*
- **Indonesia, penyuluh pertanian reporting** — Sahabat Penyuluh, Sisuluh and Ruang Penyuluh already exist, though all appear to be web/server-first; a purely offline competitor is still arguable but the space is crowded. *(unverified - from search snippet only)*

---

## no evidence found
Queries that returned nothing usable, or that I could not complete because of blocking:

- `"aplicativo que funciona sem internet" roça sem sinal fórum` (WebSearch) — returned only mesh-messenger listicles and travel blogs; **no evidence found** of a rural-Brazil occupational need.
- `aplikasi offline tanpa kuota petani nelayan forum` (WebSearch) — returned SEO game-listicles ("game farming offline tanpa kuota") and a 2015 Kominfo press release; **no evidence found**.
- `kaskus.co.id aplikasi offline "tanpa internet" butuh rekomendasi kerja lapangan` (WebSearch) — returned only POS/attendance vendor blogs, zero Kaskus threads; **no evidence found**. Kaskus appears effectively unreachable through the search paths available here.
- `"guru" "daerah 3T" aplikasi offline "tidak ada sinyal" administrasi e-rapor kendala` (WebSearch) — all results were e-Rapor install/troubleshooting SEO pages about Dapodik sync, not about signal-less teaching; **no evidence found** of a distinct offline teacher-tool niche.
- `"pengamat organisme pengganggu tumbuhan" jumlah POPT se-Indonesia orang` (DDG Lite) — literally "No results found"; **no evidence found** for a national POPT headcount.
- `"caderneta agroecológica" quantas mulheres agricultoras registro produção quintal` (Brave) and `"caderneta agroecológica" mulheres agricultoras número de cadernetas preenchidas` (DDG Lite) — Brave returned 0 parsed results then 429; DDG served a CAPTCHA. **No evidence found** for a participant headcount.
- `aplikasi "tanpa kuota" keluhan "harus online" ulasan pengguna aplikasi pemerintah` (Brave) — 0 results before rate-limiting. I could not surface first-person Indonesian review complaints; **no evidence found**. (Google Play review text is not rendered in the server-side HTML I can fetch, and the Apple ID storefront has almost no Indonesian-language niche apps to read reviews of.)
- `"agente indígena de saúde" aldeia sem internet registro SIASI papel dificuldade sistema` (WebSearch, then DDG Lite) — DDG returned only legislative-status articles about regulating the AIS/AISAN professions (e.g. https://www.camara.leg.br/proposicoesWeb/prop_mostrarintegra?codteor=1775010, unverified). **No evidence found** about their field data-capture workflow or headcount, because gov.br/FUNAI/SESAI return 401/403 from this environment. This remains an *unproven but attractive* lead: a small, nameable, absolutely-no-signal workforce.
- Google Play ID search `POPT pengamatan OPT pelaporan` — **no Indonesian POPT field app exists** in the store (results were foreign scouting/plant-ID apps). Recorded as a *gap*, not a dead end.
- Google Play ID search `identifikasi hama penyakit padi` — no offline Indonesian-language rice pest key; only cloud AI plant-ID apps and low-quality content apps. Recorded as a *gap*.
- Apple iTunes Search API `pengamatan hama OPT` (ID storefront) — `resultCount=0`.
- Mojeek, Ecosia, Startpage, Bing (curl and WebFetch), and public SearxNG instances (searx.tiekoetter.com, search.inetol.net, priv.au, opnxng.com, baresearch.org, searxng.site, search.hbubli.cc, searx.perennialte.ch, northboot.xyz) — all 403/429/JS-only. Not usable from here.
- `https://wiki.isikhnas.com/w/Farmer_Registration_and_Animal_ID` — HTTP 500 on fetch; content **unverified**.
- `https://tanamanpangan.pertanian.go.id/detil-konten/iptek/155`, `https://uptptph.kalbarprov.go.id/artikel/POPT_Keren`, `https://www.gov.br/funai/...` — 401/403 to both curl and WebFetch; not readable.

## Where language itself is the competitive gap
1. **Indonesian rice/palawija pest identification and scouting.** Every result in the Play ID search was an English-first cloud AI plant doctor. An offline, Indonesian-language, Kementan-methodology-faithful pest key has no incumbent.
2. **Indonesian tide/sea data for small-boat fishers.** The store is full of English tide apps built for US/EU recreational boaters; the one Indonesian entrant markets "hemat kuota" but still needs to have been online.
3. **Brazilian fishing legality.** The rules are per-state, in Portuguese, in normative instructions — an English-language global fishing app structurally cannot carry them, and no Brazilian one has been built offline.
4. **Brazilian caderneta agroecológica.** The vocabulary itself (lata, molho, cambada, quintal, troca) is the product; nothing generic can substitute.


# ============================================================
# SOURCE FILE: research/raw/hi-ar.md
# ============================================================

# Phase 1 Discovery — Hindi + Arabic language sweep
Date of research: 2026-07-27
Researcher note on method: the shared `WebSearch` budget for this session was exhausted after 6 calls
(the tool returned "this session has used its web search budget (200 of 200)"). All remaining searches
were run by fetching `lite.duckduckgo.com/lite/?q=...` directly with WebFetch, which works and returns
real organic result lists. Curl to `html.duckduckgo.com` and `mojeek.com` were blocked (captcha / 403),
Bing RSS returned unrelated Balkan news, so those were abandoned. reddit.com was not used at all.
~22 distinct queries were run in total (6 WebSearch + ~16 fetch-searches/verifications).

---

## 1. Gulf Arabic-speaking fishermen — legal catch reference (minimum lengths, closed seasons, banned species/gear)

### Gulf artisanal + recreational fishermen, Arabic, at sea
- **Query:** `"تطبيق يعمل بدون انترنت" للصيادين البحر`
- **Source:** Emarat Al Youm (UAE daily) | **URL:** https://www.emaratalyoum.com/local-section/other/2019-07-08-1.1230866 | **Date:** 2019-07-08 | VERIFIED FETCH
- **Paraphrase:** The Ras Al Khaimah Fishermen's Association built and distributed a phone app that measures a fish's length on-screen against the legal minimum, explicitly because their *previous* app needed internet and most fishermen could not use it — they are out at sea in areas with no network coverage.
- **Points to:** An offline Arabic "is this catch legal?" reference: species list with local Gulf names, minimum legal length per species, current closed season, protected/banned species, banned gear, plus an on-screen ruler / camera-scale measurement.
- **Offline necessity:** VERY STRONG and independently proven by the fishermen's own association — the decision is made on a boat kilometres offshore with no cell coverage, at 4am, with wet hands, before the fish is thrown back or kept. A spinner or a login is fatal to the use case.
- **Audience size:** 5,268 registered Emirati citizen fishermen (boat owners) nationally — Sharjah 1,367, Ras Al Khaimah 1,109, Fujairah 777, Dubai 735, Abu Dhabi 625, Umm Al Quwain 384, Ajman 271; Dubai Fishermen's Co-operative alone has >900 members. Source WAM (Emirates News Agency) https://www.wam.ae/ar/details/1395303082903 — **(unverified — from search snippet only; the WAM page body is JS-rendered and returned only the masthead on fetch)**. Adding Kuwait/Oman/Qatar/Bahrain/Saudi Eastern Province artisanal fleets plus licensed recreational anglers plausibly lands the total in the 30k–60k band.
- **Data/licence note:** UAE Ministerial Decision 580/2015 (undersized fish), MD 471/2016, MD 500/2014, and Abu Dhabi EAD's fishing-law factsheet. These are national legal texts held in FAO's FAOLEX legal database (https://faolex.fao.org/docs/pdf/uae165183.pdf and https://ead.gov.ae/-/media/Project/EAD/EAD/Documents/Fishing-Law-2023.pdf — both PDFs exist and downloaded, but **body not text-extractable in this environment** — no `pdftotext`/`PyPDF2` available, so contents unverified). Official legislative texts are normally outside copyright; still needs checking per country. Fish illustrations would need to come from public-domain / CC-BY sources (FAO species fact sheets, Wikimedia), NOT from commercial field guides.
- **RTL FLAG:** ★ This is a case where **Arabic + RTL is itself the moat**. Species must be listed under *local* names (هامور، شعري، صافي، بدح، كنعد، ميد، زبيدي), not FishBase Latin, and the audience is Arabic-first with low English. Every existing app found in this space is an English AI "fish identifier".

### Same niche — confirming the regulatory dataset is real and detailed
- **Query:** `وزارة البيئة الإمارات دليل الأطوال المسموح بها لصيد الأسماك pdf`
- **Source:** Bayut / MyBayut (UAE property portal's legal explainer) | **URL:** https://www.bayut.com/mybayut/ar/قوانين-الصيد-البحري-الامارات/ | **Date:** page undated, references 2023 law | VERIFIED FETCH
- **Paraphrase:** Sets out the actual shape of the dataset — closed seasons with exact dates (Sha'ri and Arabian safi 1 Mar–30 Apr; badh 1 Apr–1 Jun), minimum lengths ranging 23 cm to 60 cm by species (hamour 45 cm), fully banned species (all turtles, marine mammals), banned gear (bottom trawls, drift nets, explosives, poisons), and escalating penalties (6-month licence suspension + AED 3,000 first offence, revocation + AED 5,000 second).
- **Points to:** Confirms the app has ~100+ structured rows per country, not 5 — i.e. a real 2-month data+UI job, not a weekend calculator.
- **Offline necessity:** As above.
- **Audience size:** as above.
- **Data/licence note:** as above; Bayut itself is a secondary source, use only as a map of what to source from the official decisions.

### Same niche — negative evidence that nobody has built it
- **Query:** `site:play.google.com تطبيق أسماك الخليج العربي أسماء الأسماك دليل` and `تطبيق الأطوال المسموحة لصيد الأسماك الخليج دليل الصياد`
- **Source:** DuckDuckGo Lite organic results | **URL:** https://lite.duckduckgo.com/lite/?q=site%3Aplay.google.com+تطبيق+أسماك+الخليج+العربي+أسماء+الأسماك+دليل | **Date:** 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Every Arabic-locale result is either a generic AI photo "fish identifier" (Picture Fish, Fish Verify, FishFinder, معرّف الأسماك) or a fishing-spot/weather app (Fishing Points, FishAngler, دليل الصياد Tifnit) — none encodes legal minimum sizes, closed seasons or protected species for any Arab country.
- **Points to:** Clear white space for the legal-catch reference.
- **Offline necessity:** n/a (competitive scan)
- **Audience size:** n/a
- **Data/licence note:** n/a

---

## 2. Transhumant Gaddi shepherds, Himachal Pradesh (Hindi)

### Migratory sheep/goat herders — flock, lambing, disease and route record book
- **Query:** `गद्दी चरवाहे भेड़ पालक प्रवास हिमाचल संख्या मोबाइल नेटवर्क`
- **Source:** News4Himachal | **URL:** https://news4himachal.in/miscellaneous/himachal-gaddi-community-affected-by-us-donald-trump-tariff/8526 | **Date:** 2025-04-04 | VERIFIED FETCH
- **Paraphrase:** As of 2023 there are 5,050 Gaddi sheep-rearing families in Himachal Pradesh running a total sheep population that has crossed 8.5 lakh, and their wool income is collapsing.
- **Points to:** An offline Hindi/Gaddi flock ledger for the *dhaar* migration: animal-by-animal inventory with ear-tag, lambing and mortality log, dose/deworming and FMD/PPR vaccination dates, shearing yield and wool-lot weights per buyer, grazing-permit and forest-toll records, and GPS waypoints of the migration route and camp sites recorded without any network.
- **Offline necessity:** STRONG — the herd is on high-altitude pasture in Chamba/Kangra/Lahaul for months at a stretch, above the last tower; the same phone is the only record of who owns which animal for wool payment and for insurance/compensation claims.
- **Audience size:** 5,050 Gaddi shepherd families in HP (verified above). Directly adjacent, uncounted here: Bakarwal (J&K), Van Gujjar (Uttarakhand), Rabari/Raika (Rajasthan-Gujarat) — same app, same offline constraint, likely pushes the addressable group well past 20k.
- **Data/licence note:** Almost all data is user-entered, so no licensing risk. Optional bundled reference: HP animal-husbandry vaccination calendar and the notified migration-route/permit rules (state government documents, India's GODL licence permits commercial reuse with attribution). Avoid any treatment/dosing advice — keep it to "record what the vet did".

### Same niche — disease/mortality pain point that makes the log valuable
- **Query:** (same as above, result #7)
- **Source:** Gaon Junction | **URL:** https://www.gaonjunction.com/pashudhan/footrot-disease-kills-sheep-goats-in-himachal-gaddi-shepherds-suffer-big-losses | **Date:** ~2024-2025 | **(unverified — from search snippet only, not fetched)**
- **Paraphrase:** Footrot outbreaks are killing sheep and goats in Himachal and Gaddi shepherds are taking heavy losses.
- **Points to:** Adds a real reason the flock log matters (loss documentation for compensation), not just recordkeeping for its own sake.
- **Offline necessity:** as above.
- **Audience size:** as above.
- **Data/licence note:** n/a

---

## 3. Agariya salt-pan farmers, Little Rann of Kutch (Hindi/Gujarati)

### Salt farmers who live 8 months in a desert with no infrastructure
- **Query:** `अगरिया नमक मजदूर रण कच्छ संख्या बिजली नेटवर्क नहीं`
- **Source:** Mongabay Hindi | **URL:** https://hindi.mongabay.com/2021/10/12/when-salt-is-an-essential-commodity-and-salt-makers-are-not/ | **Date:** 2021-10-12 | VERIFIED FETCH
- **Paraphrase:** Roughly 60,000 people of the Agariya community make salt, producing about 30% of India's ground salt, with families from about 102 villages living in temporary shelters in the Rann for around eight months a year; the article stresses the government has never even surveyed how many they are.
- **Points to:** An offline production + settlement ledger for a salt pan season: brine density (Baumé) readings per pan with the transfer/harvest decision rule, pan-to-pan movement dates, diesel/solar-pump running hours, daily labour attendance, and — critically — the running account of advances taken from the salt trader against tonnage delivered, so the family can contest the trader's arithmetic at settlement.
- **Offline necessity:** VERY STRONG — an uninhabited salt desert, eight months, no grid electricity, phone charged off the solar pump; and the advance/debt ledger is exactly the kind of private financial data that must never leave the device.
- **Audience size:** ~60,000 Agariyas nationally, 102 villages in the Little Rann (verified). One narrower cohort of "over 1,200 Agariyas" appears in a Sabrang India piece about denial of salt-farming permission — https://hindi.sabrangindia.in/article/refusal-to-allow-salt-farming-in-little-rann-pushes-1200-gujarat-agariyas-to-margins **(unverified — from search snippet only)**.
- **Data/licence note:** All user-entered; the only bundled data would be a Baumé/temperature correction table and a salt-crystallisation stage chart, both textbook physical chemistry (facts, not copyrightable). Note the app would need Gujarati as well as Hindi, and a heavily icon-driven UI for low literacy.

---

## 4. Omani falaj water-share timing (Arabic)

### Falaj shareholders and the wakil al-falaj computing irrigation turns
- **Query:** `الأفلاج عمان توزيع المياه الأثر البادة حساب الدوران وكيل الفلج تطبيق`
- **Source:** DuckDuckGo Lite organic results (Athere.om, Oman Daily, Univ. of Nizwa Ishraqa journal, folkculturebh.org) | **URL:** https://lite.duckduckgo.com/lite/?q=الأفلاج+عمان+توزيع+المياه+الأثر+البادة+حساب+الدوران+وكيل+الفلج+تطبيق | **Date:** 2026-07-27 | VERIFIED FETCH (search page); individual articles **unverified — from result summary only**
- **Paraphrase:** Omani falaj irrigation shares are counted in *athar* units (an athar ≈ 30 minutes) on a fixed rotation, and the rotation is anchored to astronomy — star risings, sunrise and sunset — with several 2024-2026 pieces announcing a government/Univ. of Nizwa push ("لمد", "قعد الفلج") to move these hand-kept rotation books to electronic systems.
- **Points to:** An offline Arabic falaj-share calculator and rotation book: shareholder register in athar/badda, the dawaran cycle, automatic conversion of a shareholder's share into a wall-clock start/end time for tonight given the falaj's own sunrise/sunset or star-based anchor, plus the sale/lease/auction of shares.
- **Offline necessity:** MODERATE-TO-STRONG — the turn is handed over at the channel head in a wadi village at 2am; and the astronomical anchoring means the calculation must be done on the spot for tonight, not fetched.
- **Audience size:** unknown from a retrieved page. Oman's aflaj number in the thousands (the search did not surface a verified count) and each has dozens-to-hundreds of shareholders; the professional cohort (wukala' al-aflaj / arifs) is likely low thousands.
- **Data/licence note:** Sunrise/sunset and star-rise computation is algorithmic (public-domain astronomy, e.g. standard solar-position algorithms) so it bundles cleanly. Shareholder registers are user-entered.
- **CAUTION / competitor:** the Omani government + University of Nizwa digitisation programme is an incumbent, and it will probably be an online platform — which is precisely the gap, but it also means an official free alternative may appear.
- **RTL FLAG:** ★ Arabic-only domain vocabulary (أثر، بادة، دوران، قعد الفلج) and RTL numeric tables — no non-Arabic developer will touch it.

---

## 5. Rural Indian frontline health workers (ASHA) — offline data capture

### ASHA workers forced into app-based surveys where there is no network
- **Query:** `ASHA worker app offline problem network village "no internet" HBNC register`
- **Source:** MedTalks India | **URL:** https://www.medtalks.in/articles/asha-workers-urge-minister-to-abandon-app-based-survey-citing-rural-network-challenges | **Date:** published 2023-06-12, updated 2024-05-15 | VERIFIED FETCH
- **Paraphrase:** The Karnataka Rajya Samyukta ASHA Karyakartheyara Sangha (Dakshina Kannada) asked the minister to drop the app-based Health and Nutrition Survey because connectivity problems add delays of several minutes at every single household.
- **Points to:** An offline-first field survey/register companion that captures the household visit in seconds with zero network and exports later — the classic "the government app assumes a network that isn't there" gap.
- **Offline necessity:** STRONG on the pain, but the honest read is that this needs *sync* to be useful to the employer, which the brief auto-rejects.
- **Audience size:** ~1 million ASHAs nationally — far above the 3k–50k target band, and the app is a government mandate, so the real customer is a state health department, not an individual.
- **Data/licence note:** NHM forms are Government of India documents (GODL-India, commercial reuse with attribution). Anything touching danger signs or dosing is a liability line to stay behind.
- **VERDICT: weak as a product lead** — reported for completeness because it was an assigned context. Corroborating: Tribune India, https://www.tribuneindia.com/news/haryana/asha-workers-struggle-to-upload-data-on-app-255594, 2021-05-19, VERIFIED FETCH — Yamunanagar ASHA workers say the ASHA Survekshan portal is slow or non-functional and they work till late evening to upload; note this article blames the *portal*, not local coverage.
- Also seen: `दो साल पहले आशा वर्करों को जारी सिम कराए बंद` on livehindustan (Pilibhit, UP) — ASHA workers facing network issues and SIM reissue — https://www.livehindustan.com/uttar-pradesh/pilibhit/story-health-department-s-asha-workers-face-network-issues-new-sim-cards-to-be-issued-201731928198938.html — **(unverified — Claude Code is blocked from fetching livehindustan.com)**.

---

## 6. Leads checked and found ALREADY SERVED (do not pursue)

### Hajj / Umrah rites guide offline (Arabic)
- **Query:** `تطبيق الحج والعمرة بدون انترنت مشكلة الشبكة في منى وعرفات`
- **Source:** Google Play (multiple) + Al-Ain | **URL:** https://play.google.com/store/apps/details?id=mnask.alhajj.omra , https://play.google.com/store/apps/details?id=com.mnasekelomra.ghalyapps , https://al-ain.com/article/your-smart-guide-hajj-2026 | **Date:** 2026 | **(unverified — from search snippet only)**
- **Paraphrase:** There are already many free Arabic "مناسك الحج/العمرة بدون نت" apps plus the ministry's own مناسكنا app, all explicitly marketed on working with no data in the crowded Mashaa'ir.
- **Points to:** Rites-guide space is saturated. The only unserved sliver seen was the *campaign supervisor* (مشرف حملة / تفويج) side — group rosters, batch headcounts, tent/bus assignment — but that is inherently a sharing/sync product, so it fails the offline test.
- **Offline necessity:** genuinely strong (network collapses under crowd load in Mina/Arafat) but the need is met.
- **Audience size:** ~1.6M+ pilgrims/yr — too big and already served.
- **Data/licence note:** Quran/hadith text public domain; ritual guides vary.

### Quran memorisation circle (halaqa) teacher tracker (Arabic)
- **Query:** `معلم تحفيظ القرآن تطبيق متابعة الطلاب بدون انترنت سجل الحلقة`
- **Source:** DDG Lite organic results | **URL:** https://lite.duckduckgo.com/lite/?q=معلم+تحفيظ+القرآن+تطبيق+متابعة+الطلاب+بدون+انترنت+سجل+الحلقة | **Date:** 2026-07-27 | VERIFIED FETCH (search page)
- **Paraphrase:** At least eight Arabic halaqa-management platforms exist (halagat.co, misbah.pro, injaazy.com, halaqti.com, jeel-alquran.com, halaqaldhikr.com, furqansystem.com, telawah) and one of them is already promoted as working "بدون إنترنت".
- **Points to:** crowded; skip.
- **Offline necessity:** moderate (mosque basements, private student data).
- **Audience size:** very large but already served.
- **Data/licence note:** Uthmani Quran text is public domain but the King Fahd Complex digital text has its own terms.

### Arabic prosody / poetry-metre scanner (تقطيع عروضي)
- **Query:** `تطبيق العروض تقطيع الشعر بحور الشعر بدون انترنت اندرويد`
- **Source:** APKPure / Google Play | **URL:** https://apkpure.com/ar/التقطيع-العروضي-الشعر-العربي/www.alarod.com , https://play.google.com/store/apps/details?id=com.benetnash.kafya.kafya_app | **Date:** 2026-07-27 | **(unverified — from result list only)**
- **Paraphrase:** An offline Android app that determines the metre of an Arabic verse already exists (التقطيع العروضي), plus سُلاف for metre and rhyme.
- **Points to:** Attractive algorithmically (a genuine 2-month job) but taken.
- **Offline necessity:** weak anyway.
- **Audience size:** unknown.
- **Data/licence note:** classical prosody is public domain.

### Camel pedigree / racing record book (Arabic Gulf)
- **Query:** `تطبيق ملاك الإبل أنساب الهجن سجل المطايا بدون انترنت عدد ملاك الإبل`
- **Source:** DDG Lite organic results incl. hijni.com and camelclub.gov.sa | **URL:** https://lite.duckduckgo.com/lite/?q=تطبيق+ملاك+الإبل+أنساب+الهجن+سجل+المطايا+بدون+انترنت+عدد+ملاك+الإبل | **Date:** 2026-07-27 | VERIFIED FETCH (search page)
- **Paraphrase:** Hijni.com already offers camel pedigree/race record keeping, the Saudi Camel Club runs official e-services, a national pedigree-documentation platform ("وثقها") is being rolled out, and at least one result is titled as an offline camel-owner pedigree app.
- **Points to:** taken / being taken by a government programme.
- **Offline necessity:** strong in principle (desert), but the incumbent problem kills it.
- **Audience size:** one SPA item references 85,347 camels tagged in Al-Jouf region **(unverified — from result summary only)**.
- **Data/licence note:** n/a

### Bedouin star calendar (الدرور / الطوالع) for desert farmers and seafarers
- **Query:** `"الطوالع" "الدرور" تقويم المزارعين البدو النجوم سهيل حساب المواسم تطبيق`
- **Source:** Arabic Wikipedia + Sheikh Zayed Grand Mosque Centre PDF + app writeup | **URL:** https://ar.wikipedia.org/wiki/ديرة_الدرور , https://szgmc.gov.ae/Ftp/كتاب%20ديرة%20الدرور.pdf , http://ketafnews.blogspot.com/2019/10/blog-post_712.html | **Date:** 2019-2026 | **(unverified — from search snippet only)**
- **Paraphrase:** The Durur system splits the year into 36 fixed periods anchored to the rising of Suhail and is used to time agricultural, pastoral and marine seasons; an app ("الفصول الأربعة") already covers it and the official Umm al-Qura calendar app ships a "تقويم المزارعين".
- **Points to:** served; only reusable as a *feature* inside a bigger desert-agriculture app.
- **Offline necessity:** strong (desert) but need is met.
- **Audience size:** unknown.
- **Data/licence note:** the SZGMC book is a UAE government publication — permission would still need checking.

### Village milk collection fat/SNF rate calculation (Hindi)
- **Query:** `दूध डेयरी फैट एसएनएफ रेट चार्ट ऐप ऑफलाइन`
- **Source:** Google Play / vendor sites | **URL:** https://play.google.com/store/apps/details?id=b2infosoft.milkapp.com , https://apnainfotech.com/milk-sarthi.php , https://mobiledairy.co.in/hi/blog/milk-rate-calculation-fat-snf.html | **Date:** 2026-07-27 | **(unverified — from result list only)**
- **Paraphrase:** Several Hindi dairy-collection apps (Meri Dairy, Milk Sarthi, MobileDairy) already implement fat/SNF rate-chart pricing for village societies.
- **Points to:** served, and it is essentially a ledger/calculator — fails the brief's generic-tracker filter.
- **Offline necessity:** moderate.
- **Audience size:** large.
- **Data/licence note:** rate charts are set per-union, user-entered.

### Date-palm cultivar identification / oasis farm calendar (Arabic)
- **Query:** `تطبيق أصناف النخيل والتمور تعريف نوع النخلة مزارعي النخيل بدون انترنت`
- **Source:** FAO OpenKnowledge + Saudi NCPD + nighat.sa | **URL:** https://openknowledge.fao.org/server/api/core/bitstreams/28640f40-b3e2-402a-af13-203606a90edc/content , https://ncpd.gov.sa/ar , https://nighat.sa/palm-classification | **Date:** 2026-07-27 | **(unverified — from search snippet only)**
- **Paraphrase:** No offline Arabic app for identifying date-palm cultivars surfaced; what exists is a Saudi national palm centre, a commercial computer-vision date-sorting platform (نقاة), and farm-management software — while FAO publishes a full illustrated Arabic date-palm husbandry manual.
- **Points to:** possible offline Arabic oasis-farm assistant: cultivar key, pollination/thinning/bagging/harvest calendar by cultivar and region, red palm weevil inspection log, per-palm inventory.
- **Offline necessity:** moderate — oasis farms in Al-Ahsa, Siwa, Tafilalt, Wadi Hadhramaut do lose coverage, but many are peri-urban, so offline is convenient rather than mandatory. Flagging honestly as the weaker half of the test.
- **Audience size:** unknown from a retrieved page.
- **Data/licence note:** ⚠ the obvious FAO manual is very likely CC BY-NC-SA — **the NC clause blocks commercial use**. Cultivar facts themselves are not copyrightable but the images and text are; would need original photography or PD/CC-BY sources.

---

## no evidence found

These queries were run and produced nothing usable (SEO listicles, generic "how to fix your wifi" content, or unrelated news):

- `"لا يعمل بدون انترنت" تقييم تطبيق "للأسف" مزعج` — returned only Android troubleshooting help pages, no app-review complaints. **No evidence found.**
- `تطبيق للمزارعين بدون انترنت` — returned only home-gardening content apps, offline map apps (Organic Maps, OsmAnd) and a farming *game*. **No evidence found** of an unmet Arabic farming need.
- `تطبيق بدون انترنت للرعاة الإبل الأغنام البر لا توجد شبكة` — surfaced مقاني (mqane.com), My Sheep Manager, Greener Herd; Arabic livestock management is already occupied. **No fresh evidence.**
- `मछुआरे समुद्र में नेटवर्क नहीं मोबाइल ऐप समस्या` — returned generic "fix your phone signal" articles plus one BSNL-for-fishermen news item; no usable Indian marine-fisher offline complaint. **No evidence found.**
- `"बिना इंटरनेट" चलने वाला ऐप जरूरत गांव काम` — dominated entirely by 2026 Bitchat/Jack Dorsey ban news. **No evidence found.**
- `वन अधिकार कानून दावा फॉर्म भरने में दिक्कत गांव नेटवर्क` — returned FRA claim-process explainers and the Ministry of Tribal Affairs forms page, but no evidence of a connectivity-driven pain point or of the community's size. Not developed further.
- `प्रवासी मजदूर खाड़ी देश इंटरनेट नहीं ऐप` — returned only crisis/helpline news about Indians in the Gulf, nothing about an offline tool need. **No evidence found.**
- `मशरफ حملة الحج / تفويج بدون شبكة` (`مشرف حملة الحج مشاكل إدارة الحجاج تفويج عدد الحجاج بدون شبكة`) — returned only ministry crowd-control PR and Hajj-operator marketing; the supervisor-side tooling need could not be evidenced. **No evidence found.**
- `قرار وزاري 580 لسنة 2015 الأطوال المسموح بها` — the decision is repeatedly referenced but its full per-species table could not be read; both candidate PDFs (FAOLEX, EAD) downloaded as binary that this environment cannot text-extract. **Dataset existence confirmed, contents unverified.**
- Attempts to reach `mojeek.com` (403), `html.duckduckgo.com` via curl (captcha), `bing.com/search?format=rss` (returned unrelated Balkan news), `www.livehindustan.com` (fetch blocked), and `www.wam.ae` article bodies (JS-rendered, masthead only) all failed.


# ============================================================
# SOURCE FILE: research/raw/td-field-outdoor.md
# ============================================================

# TD — Field & Outdoor (signal-dead work environments)

Phase 1 discovery, 2026-07-27. Top-down: start from groups working where there is no signal, then hunt for real complaints/tooling gaps.

**Method note / environment constraints:**
- The session's WebSearch budget was exhausted after 6 calls. Remaining searching was done by WebFetch against `https://lite.duckduckgo.com/lite/?q=...` (works), plus `gh` CLI GitHub search, the iNaturalist Discourse JSON API, and the Stack Exchange API. `html.duckduckgo.com` and `mojeek.com` returned anti-bot/anomaly pages; `surveyorconnect.com` (→ rpls.com) and `snowpilot.org` are behind Cloudflare and returned 403 to direct fetches.
- reddit.com was not used at all (blocked in this environment).
- Anything I only saw as a search-result listing is explicitly marked "unverified - from search snippet only".

---

## Bird banding / ringing station data capture

- **Query:** `bird banding station paper data sheets BANDIT software data entry tedious banders mobile app`
- **Source:** UX case study (Jessica Elroy, contracted usability study of USGS BANDIT) | **URL:** https://www.jessicaelroyux.com/np-bandit | **Date:** undated, references BANDIT 4.x era (~2019-2022) | VERIFIED FETCH
- **Paraphrase:** A formal usability study of the USGS bird-banding submission software found banders get lost in the navigation, are swamped by fields they never use, hit slow scrolling on large data-entry jobs, and that some knowingly submit wrong data rather than go looking for help with the codes.
- **Points to:** An offline banding-sheet app for the banding table: species alpha code, band number series, age/sex, wing chord, mass, fat, skull, brood patch, net number and net-run time, with per-species validation and a clean end-of-day export.
- **Offline necessity:** Banding stations run at dawn in marshes, riparian scrub and mountain passes with no coverage; nets are checked on a hard 20-40 minute clock, one hand holds a live bird, and the current fallback is a wet paper sheet transcribed at night.
- **Audience size:** ~6,000 active banders in Canada + US (Wikipedia, North American Bird Banding Program — VERIFIED FETCH of https://en.wikipedia.org/wiki/North_American_Bird_Banding_Program); the MAPS network alone accounts for >1,200 stations since 1989 (VERIFIED FETCH of https://www.birdpop.org/pages/maps.php).
- **Data/licence note:** BBL 4-letter alpha codes, species list and band-size-by-species tables come from USGS/Bird Banding Laboratory = US Government work, public domain. AVOID bundling the Pyle *Identification Guide to North American Birds* ageing/molt criteria (copyright, Slate Creek Press). The IBP MAPS manual is freely downloadable but would need permission.

### Supporting evidence — people pay humans to key in their paper sheets

- **Query:** `bird banding app offline iPad data entry banders "data sheets" transcribe evening station`
- **Source:** Two Moons LLC (commercial service) | **URL:** https://www.twomoons.systems/services/bird-banding | **Date:** accessed 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** A consultancy sells banding projects a bespoke hosted data-entry portal explicitly positioned to "replace or supplement paper data sheets", charging a setup fee plus an annual hosting fee — i.e. the transcription burden is large enough that groups outsource it.
- **Points to:** Same as above; confirms willingness to pay and confirms every existing option is a *hosted web* product.
- **Offline necessity:** A hosted portal is exactly the wrong shape for a station with no bars.
- **Audience size:** see above.
- **Data/licence note:** as above.

### Supporting evidence — nothing offline exists in open source

- **Query:** `gh search repos "bird banding"` (GitHub CLI, authenticated)
- **Source:** GitHub | **URL:** https://github.com/ndswecker/SnatchItCore | **Date:** last push 2024-07-11 | VERIFIED (gh CLI)
- **Paraphrase:** The only serious open-source banding data-collection project is a Django full-stack *web* application with 2 stars; the other dozen hits are analysis notebooks and a 2013 JavaScript code-lookup toy — no offline mobile app exists.
- **Points to:** Green field for a Flutter offline banding app.
- **Offline necessity:** as above.
- **Audience size:** as above.
- **Data/licence note:** as above.

---

## Field archaeology — single-context recording + Harris matrix on a tablet

- **Query:** `field archaeology context sheet recording tablet offline Harris matrix "paper" digital recording problems site no wifi`
- **Source:** BAJR (British Archaeological Jobs Resource) practical guide | **URL:** https://www.bajr.org/single-context-recording/ | **Date:** undated guide, live 2026 | VERIFIED FETCH
- **Paraphrase:** BAJR's guide describes the working method as filling in a paper "context card" box by box per excavated context, cross-referencing plans/photos/samples, with the stratigraphic sequence of those planned contexts growing into a Harris matrix as the dig proceeds.
- **Points to:** An offline single-context recording app: context sheets with controlled vocabularies, sample/photo/plan cross-refs, and a live Harris matrix built from stratigraphic relationships with cycle detection and automatic layout.
- **Offline necessity:** Excavations sit in ploughed fields, quarries and road corridors; site huts have no wifi, and the honest current fallback is pencil on a pre-printed card in the rain.
- **Audience size:** CIfA had 3,931 members / 3,033 accredited professionals at 21 July 2020 (Wikipedia summary seen in search listing — unverified - from search snippet only). Plausible UK+IE commercial field staff on the order of 5,000-7,000.
- **Data/licence note:** No proprietary dataset needed — the value is the recording model. Historic England's *Archaeological Recording Manual* (2018) is published under the Open Government Licence (commercial reuse permitted) and could seed the context-type vocabularies. MoLAS/MoLA's site manual is copyright and should not be copied verbatim.
- **Competition note:** "Kiosk" (Brown University) is a real offline iPad recording platform — iPad-only, academic, tied to its own sync appliance. FAIMS (Australia) exists but is heavyweight. A cross-platform, no-server, no-account Flutter version is still open.

---

## Trail crews / trail condition surveys (USFS TRACS)

- **Query:** `volunteer trail crew work log hours reporting paper form TRACS trail condition survey app`
- **Source:** US Forest Service, official TRACS page | **URL:** https://www.fs.usda.gov/managing-land/trails/trail-management-tools/tracs | **Date:** live 2026 | VERIFIED FETCH
- **Paraphrase:** TRACS is the Forest Service's standardised trail inventory/condition-assessment method, distributed as a PDF and an Excel workbook with a printed user guide assembled in a 3-ring binder; the page mentions no mobile app, no offline tool and no field device at all.
- **Points to:** An offline TRACS-shaped trail survey app: log segment-by-segment condition, deferred-maintenance items, trail class/design parameter conformance, work accomplished and volunteer hours, with GPS-stamped items and a CSV/XLSX export that matches the agency workbook.
- **Offline necessity:** Trail assessment happens miles from a trailhead, often multi-day; the official field medium is literally waterproof paper.
- **Audience size:** unknown for USFS staff; volunteer maintainers are large and nameable (Appalachian Trail Conservancy, PCTA, North Country Trail Association clubs all publish printable work logs — seen in the same result listing, unverified - from search snippet only).
- **Data/licence note:** TRACS forms, codes and the trail class matrix are US Government works = public domain, safe to bundle commercially.
- **Supporting detail:** The TRACS forms workbook (`TRACS_Forms_10_2008.xls`, fs.usda.gov) is reported to recommend printing onto "write-in-the-rain paper" (unverified - from search snippet only; the .xls itself was not opened).

---

## Ski patrol / avalanche control route logging and misfire records

- **Query:** `ski patrol avalanche control explosive shot record magazine inventory paper log book requirement`
- **Source:** California DIR, Title 8 §5357 (state safety order) | **URL:** https://www.dir.ca.gov/Title8/5357.html | **Date:** current regulation, accessed 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** California's avalanche-control safety order requires operators to try to determine and record whether each round fired actually detonated, and to record the approximate location of every known or suspected misfire.
- **Points to:** An offline avalanche-control route log: charges drawn from the magazine, shot-by-shot record per start zone, results observed, GPS-pinned dud/misfire locations carried forward to the next day's route card, and reconciliation of charges out vs. charges used.
- **Offline necessity:** This is recorded on a ridge in a storm, in gloves, at 3,000 m, before the lifts open — no signal, no time, and the record is legally required the same day.
- **Audience size:** unknown precisely; American Avalanche Association membership figures were not retrievable (their site gave no number in search listings). Order-of-magnitude: a few thousand North American avalanche-control workers.
- **Data/licence note:** State safety orders (CA Title 8) and federal ATF explosives recordkeeping rules are public-domain government text. Route/start-zone names are the operator's own data. AVOID bundling CAA/AAA copyrighted observation manuals verbatim.
- **Risk flag:** Adjacent to safety-critical work; the app must be a *record*, never a recommendation about whether a slope is safe.

---

## Snow profile / snowpit recording for avalanche professionals

- **Query:** `snow profile snowpit recording app offline avalanche professional CAA OGRS paper form`
- **Source:** search result listing for snowpilot.org and avalancheassociation.ca | **URL:** https://snowpilot.org | **Date:** accessed 2026-07-27 | unverified - from search snippet only (snowpilot.org returns HTTP 403 to direct fetch — Cloudflare)
- **Paraphrase:** SnowPilot is the free/open tool avalanche workers use to graph and database snowpits and export CAAML, but it presents as a hosted web application; the Canadian Avalanche Association's OGRS 2024 remains the paper-form standard for observations.
- **Points to:** A fully offline snow-profile recorder: hand-hardness/grain-form/grain-size layer entry with ICSSG symbols, temperature profile, ECT/CT/PST stability test results, drawn profile rendering, CAAML export.
- **Offline necessity:** The pit is dug at treeline or above it, in cold and wind; a web form is unusable there, so the profile is written on a plastic card and re-typed later.
- **Audience size:** unknown — I could not retrieve an AAA or CAA membership number from any page.
- **Data/licence note:** CAAML is an open XML schema; ICSSG (IACS) classification symbols are from a freely published UNESCO/IACS technical document, but the CAA OGRS manual itself is a copyrighted publication — reimplement the concepts, do not copy the manual.
- **Verdict:** Moderate at best — SnowPilot already covers most of the need and I could not verify the offline gap or the audience size.

---

## BLM grazing permittees — on-allotment livestock use records

- **Query:** `BLM grazing permittee actual use report paper form number of permittees recordkeeping burden`
- **Source:** BLM / eCFR result listing | **URL:** https://www.blm.gov/sites/default/files/docs/2023-12/4130-005.pdf | **Date:** form rev. 2023, requirement current | unverified - from search snippet only
- **Paraphrase:** BLM administers roughly 18,000 grazing permits and leases, and 43 CFR 4130.3-2(d) requires each permittee to file an Actual Grazing Use Report (Form 4130-005) within 15 days of finishing annual grazing use.
- **Points to:** An offline allotment/pasture use log — head counts, class of livestock, on/off dates per pasture, water and salt checks, AUM roll-up — that prints/exports straight into the 4130-005 layout.
- **Offline necessity:** Moderate. The riding and counting happens on allotments with no coverage, but the filing itself happens at the ranch house where there may be internet.
- **Audience size:** ~18,000 BLM permits/leases (BLM, via search listing).
- **Data/licence note:** BLM forms, 43 CFR text and AUM conversion factors are US Government works = public domain.

---

## Radio-telemetry triangulation in the field

- **Query:** `radio telemetry triangulation field bearings LOAS software discontinued locate animal in field calculate error ellipse`
- **Source:** search result listing for Ecological Software Solutions LOAS | **URL:** https://www.ecostats.com/loas | **Date:** accessed 2026-07-27 | unverified - from search snippet only
- **Paraphrase:** The standard tool for turning telemetry bearings into animal locations is LOAS, a Windows desktop package with a spreadsheet/GIS interface used for post-processing; nothing in the results is a field/phone tool.
- **Points to:** An offline triangulation app — take compass bearings from N stations, get the maximum-likelihood intersection and error ellipse immediately, so the tracker knows which drainage to walk into next rather than finding out a week later.
- **Offline necessity:** Very strong — tracking is done on ridgelines with a Yagi antenna, no signal, and the answer is only useful in the next ten minutes.
- **Audience size:** unknown. Wildlife telemetry practitioners are plausibly a few thousand worldwide but I found no membership or licence count.
- **Data/licence note:** No bundled dataset needed at all — pure geodesy/statistics (Lenth MLE, Andrews estimator, magnetic declination via the public-domain WMM/IGRF coefficient set).

---

## Railway track inspection (short lines) — FRA Part 213 records

- **Query:** `railroad track inspector paper inspection forms FRA 213 defect report shortline no cell signal tablet`
- **Source:** eCFR (US federal regulation) | **URL:** https://www.ecfr.gov/current/title-49/subtitle-B/chapter-II/part-213/subpart-F/section-213.241 | **Date:** current | unverified - from search snippet only
- **Paraphrase:** 49 CFR 213.241 requires each track inspection to be recorded with date, track inspected, and the location and type of every defect found; FRA's own compliance manual has inspectors completing a paper track inspection form.
- **Points to:** An offline track-walk/hi-rail inspection log keyed to milepost, with the Part 213 class-by-class gage/alinement/crosslevel/profile threshold tables built in as reference and a remedial-action clock per defect.
- **Offline necessity:** Strong — track inspection happens in canyons, tunnels, prairie and yard trackage with no coverage, on foot, daily.
- **Audience size:** unknown; ~600 short-line/regional railroads in the US each employing a handful of qualified inspectors would put the addressable group in the low thousands (this 600 figure is from memory, NOT retrieved — treat as unverified).
- **Data/licence note:** 49 CFR Part 213 and FRA forms are US Government works = public domain.
- **Risk flag:** Defect thresholds shade into safety-critical territory; the app should present the regulation text and let the qualified inspector decide, not compute a "safe/unsafe" verdict.

---

## Native seed collection (Seeds of Success)

- **Query:** `native seed collection Seeds of Success protocol field data form paper collectors number of crews`
- **Source:** BLM result listing | **URL:** https://www.blm.gov/programs/natural-resources/native-plant-communities/native-seed-collection | **Date:** a "SOS Paper Collection Form 2026" is listed | unverified - from search snippet only
- **Paraphrase:** BLM's Seeds of Success program still publishes a *paper* collection form for the 2026 season alongside its technical protocol.
- **Points to:** An offline seed-collection recorder: population size estimate, phenology, voucher and collection numbers, associated species, habitat/soil, land ownership, photo attachment, exported in SOS field-data-form order.
- **Offline necessity:** Strong — collections are made on remote public land, often on foot, with a full crew day between vehicle and signal.
- **Audience size:** unknown — no crew or collector count was retrievable.
- **Data/licence note:** SOS protocol, form fields and BLM habitat/soil code lists are public domain; USDA PLANTS species codes are also US Government works.

---

## Bat roost emergence counts

- **Query:** `bat survey emergence count volunteer paper recording form app roost count no signal`
- **Source:** result listing spanning FWS, Bat Conservation Trust NBMP and state programs | **URL:** https://cdn.bats.org.uk/uploads/pdf/Our%20Work/NBMP/BatTrack/Emergence-count-survey-form.pdf | **Date:** current NBMP form | unverified - from search snippet only
- **Paraphrase:** Emergence counts are still run off printed survey forms in the UK NBMP and several US state programs, while some states have moved to ArcGIS Survey123.
- **Points to:** An offline dusk emergence-count tallier: sunset-anchored timer, per-minute tally with haptic-only feedback, weather fields, exports to NBMP/NABat form layout.
- **Offline necessity:** Moderate — many roosts are on houses and churches with coverage; the harder constraint is darkness and a two-hand tally, not signal.
- **Audience size:** unknown; NBMP is a large UK volunteer scheme but no participant count was retrieved.
- **Data/licence note:** NBMP/FWS form structures are freely published; UK government/NGO material would need an OGL or explicit permission check.

---

## no evidence found / dead ends

Queries that returned nothing usable, or that turned up an existing offline product and are therefore **rejected as fresh leads**:

- `sled dog musher kennel record keeping paper notebook training log dog rotation "no cell service" software` — **MushingPlan** (https://mushingplan.com/) already advertises an offline-first architecture for GPS tracks, dog records and kennel tasks with later sync, freemium at €9.99–29.99/month. Rejected.
- `station hand outback cattle sheep paddock records mob tally paper notebook no mobile coverage app Australia` — **Mobble** (mobble.io) explicitly "online and offline"; **PaddockHQ** and the offline-first Windows "Outback Stockbook" also exist. Rejected.
- `distribution line patrol pole inspection paper forms lineman rural electric cooperative no cell coverage tablet` — **speqtiv** sells electric-cooperative pole-inspection software marketed on offline capability replacing paper line patrol. Rejected.
- `creel survey clerk angler interview paper form clipboard tablet offline fisheries biologist` — **MyCreel** (mycreel.com) already covers roving and access-point creel surveys; Michigan DNR clerks already enter interviews into a smartphone app. Rejected.
- `search and rescue team ICS 214 ICS 204 paper forms field team clue log offline app SAR volunteers` — **ICS NOW** (icsnow.app) already creates and emails ICS-214 forms offline from a phone. Also **TrailTriage** (blackelkmountainmedicine.com) already covers offline wilderness SOAP notes. Rejected as-is.
- `mountain rescue team paper forms "no signal" spreadsheet tracking gear check offline app` — no first-hand complaint retrievable; results were association/Wikipedia pages only. **no evidence found.**
- `field botanist vegetation quadrat survey data entry paper datasheet "no cell service" app frustration` — returned only vendor pages (Harvest Your Data, ABR, Pl@ntNet) and a how-to blog. **no evidence found** of a specific unmet gap.
- `"still using paper" field biologist survey data "wish there was an app" offline remote no signal` — DuckDuckGo returned zero results. **no evidence found.**
- `rangeland monitoring AIM DIMA Access database field crew "paper data sheets" transcription errors problem` — confirmed DIMA is a Microsoft Access database and that AIM training covers both apps and paper, but **no first-hand complaint found**; BLM already funds electronic capture.
- `mining claim staking corner posts location notice requirements prospector field app offline BLM state rules` — regulations (43 CFR 3832/3833) found, but **no evidence found** of a community complaining about tooling, and no community-size figure.
- `herpetology drift fence pitfall trap array check data sheet paper snake survey app offline field` — protocols found (FWC, USGS TM 2-A5, NZ DOC) but **no complaint and no app-gap evidence found**.
- `reindeer herding earmark identification Sami merking register app corral herders number of herders` — cultural/tourism pages only; **no earmark register, no app, and no herder count found.** Would need Norwegian/Sámi-language sources (landbruksdirektoratet.no) to progress.
- `registered guide outfitter Alaska hunt record client paper form number of licensed guides bush no internet` — the statutory hunt-record requirement (AS 08.54.760, 12 AAC 75.210) was found, but **no licensee count and no complaint found.**
- `American Avalanche Association number of members professional avalanche workers 2025` — **no membership number found** on any retrievable page.
- iNaturalist Discourse API search (`offline no cell service field`) — only four weak feature-request threads (e.g. topic 55319 "Ability to download observations for offline reference", 2024-09-10, 4 posts). Not a strong signal.
- GIS Stack Exchange API search (`offline field data collection no internet`) — three unrelated hits about ArcGIS Collector sync and QGIS performance. **no evidence found.**
- Direct fetches that failed: `snowpilot.org` (403 Cloudflare), `surveyorconnect.com`/`rpls.com` (Cloudflare, no Discourse JSON API), `html.duckduckgo.com` (anomaly/anti-bot), `mojeek.com` (empty result markup).


# ============================================================
# SOURCE FILE: research/raw/td-industrial-indoor.md
# ============================================================

# TD — Industrial / Indoor Dead-Zone Trades (Phase 1 Discovery)

Date of research: 2026-07-27
Assignment: top-down from groups working in indoor signal dead zones or gloves/hands-busy conditions.

## Method / environment caveats (read first)

- Reddit is blocked in this environment. No reddit URL is cited anywhere below.
- **The WebSearch tool budget (200 calls) was exhausted after 11 searches** (the session had prior usage). From that point on I searched/retrieved via direct `curl` with a browser user-agent, the **iTunes/App Store public search + customer-review RSS APIs**, the **eCFR API**, the **HN Algolia API** and the **Stack Exchange API**, all of which are reachable.
- General web search engines were then unavailable: Bing RSS returns topic-noise and ignores `site:` operators, DuckDuckGo / Mojeek / Startpage / Ecosia / SearXNG instances all return captcha or 429. This limited my ability to find *specific forum threads*. Where I could not find a thread I say so rather than invent one.
- Several trade forums 403 on WebFetch but serve fine to `curl` with a desktop UA (mb.nawcc.org, conservation-wiki.com, briarpress.org). Cloudflare blocked: controlbooth.com (403), taxidermy.net (202 challenge), alloyavenue.com (500), homedistiller.org, nmc.uscg.mil / dco.uscg.mil (Akamai Access Denied), bls.gov (bot block).
- **App-store saturation checks below were run programmatically** against `itunes.apple.com/search?entity=software&country=us`. Rating counts are live values from that API on 2026-07-27. Review quotes are paraphrased from `itunes.apple.com/us/rss/customerreviews/id=<N>/json`.

---

## STRONGEST LEAD

### Art conservators + museum registrars — offline condition reporting & materials/solvent bench reference

- **Query:** `art conservator solvent Teas chart solubility triangle app conservators tool gap` / `"American Institute for Conservation" membership number conservators 2025 members` / App Store `conservator condition report`
- **Source:** Apple App Store customer-review RSS (Articheck, id 1453674384) | **URL:** https://apps.apple.com/us/app/articheck/id1453674384?see-all=reviews | **Date:** reviews Feb 2023, Dec 2021, Dec 2020 | VERIFIED FETCH (via iTunes review RSS)
- **Paraphrase:** The one real condition-reporting app for the field is a ~$710/year subscription; a 1-star reviewer says it is "not recommended for conservators" because long text blocks did not save, and two other reviewers report it crashing repeatedly and losing a whole large project's work.
- **Points to:** A single-purchase, fully-offline condition-report + treatment-record app for conservators/registrars: object record, damage annotation on a photo, controlled vocabulary, PDF export, no account.
- **Offline necessity:** STRONG. Condition reports are written inside collection vaults, sub-basement stores, freight-forwarder crate rooms, art-fair loading docks, on scaffolding inside churches and in trucks — all metal/concrete signal dead zones; a crash-and-lose-your-work cloud app is exactly the failure mode reported. Second, independent reason: report contents (object locations, damage, insurance-relevant condition) are confidential and many institutions forbid third-party cloud storage.
- **Audience size:** AIC "over 3,500 members in over twenty countries" (https://en.wikipedia.org/wiki/American_Institute_for_Conservation, VERIFIED FETCH). Independently, the AIC Wiki reports **1,680 registered users, 621 with "Creator" rights, 2,383,252 words of content** (https://www.conservation-wiki.com/wiki/Special:Statistics, VERIFIED FETCH). Add museum registrars/collection managers and the addressable pool is roughly 10–25k in the anglophone world. Right in the target band.
- **Data/licence note:** **CLEAN.** Getty Vocabularies (Art & Architecture Thesaurus for material/object/damage terminology, ULAN, TGN) are explicitly released under **Open Data Commons Attribution License (ODC-By) 1.0** — commercial use permitted with attribution (https://www.getty.edu/research/tools/vocabularies/obtain/index.html, VERIFIED FETCH; full N-Triples dumps downloadable). ⚠️ The AIC Wiki (conservation-wiki.com) carries **no visible licence statement** — `AIC_Wiki:General_disclaimer` and `AIC_Wiki:Copyrights` are both empty pages (VERIFIED FETCH). Treat AIC Wiki text as **not licensed for reuse**; do not bundle it.

### Same audience, second app: solvent-selection / Teas triangle bench tool

- **Query:** `art conservator solvent Teas chart solubility triangle app conservators tool gap`
- **Source:** CoOL (Conservation OnLine, FAIC) tutorial | **URL:** https://cool.culturalheritage.org/byform/tutorials/conscitut/teas_chart/ | **Date:** undated tutorial, FAIC-hosted | VERIFIED FETCH
- **Paraphrase:** FAIC's own teaching page walks conservators through using Teas charts to pick solvents but explicitly does **not** contain the solvent parameter values — it tells the reader to go find the data elsewhere.
- **Source (corroborating):** WAAC Newsletter, Christopher McGlinchey, "Boundaries of the Teas Solubility Concept" | **URL:** https://cool.culturalheritage.org/waac/wn/wn24/wn24-2/wn24-205.html | **Date:** May 2002 (Vol 22 No 2) | VERIFIED FETCH
- **Paraphrase:** A conservation scientist notes the more accurate solubility equation "requires additional data and is most easily solved via computer program rather than a visual chart" — i.e. the profession is still using a hand-drawn triangle because nobody shipped the computer program to the bench.
- **Points to:** Offline solvent-blend calculator: pick a target resin/varnish, get fd/fp/fh coordinates, blend two or three solvents and see the mixture point move on a Teas triangle, with evaporation rate, health/GHS hazard and retention warnings per solvent.
- **Offline necessity:** MODERATE-STRONG. Solvent testing happens on a scaffold, in a chapel, in a store room; hands are gloved and a swab is in one of them; you need a two-tap answer, not a login.
- **Audience size:** subset of the AIC 3,500 plus European equivalents (ICON UK, E.C.C.O.) — paintings/objects/architecture conservators, maybe 5–8k.
- **Data/licence note:** Hansen/Teas fractional parameters for ~200 solvents are numeric *facts* published across the literature since Teas (1968) — facts are not copyrightable, but a *curated table* copied verbatim from Hansen's handbook would be. Safest path: derive/compile from primary papers + **PubChem** (US NIH, explicitly public domain) for CAS numbers, flash points and GHS hazard statements. ⚠️ **CAMEO** (cameo.mfa.org, MFA Boston materials encyclopedia) would be the obvious source but I **could not retrieve it** — the site returned empty bodies on two attempts, so its licence is **unverified**. Do not assume it is reusable.

---

## MODERATE LEADS

### Letterpress printers — antique press & metal-type identification

- **Query:** (direct fetch, search unavailable) https://briarpress.org/discussion
- **Source:** Briar Press discussion index | **URL:** https://briarpress.org/discussion | **Date:** live index read 2026-07-27, most recent post 26 Jul 2026 | VERIFIED FETCH
- **Paraphrase:** The forum's own category counters show **9,933 posts** filed under "Press and typeface identification" and **16,502** under "Troubleshooting the press" — and the visible recent-topic list is dominated by "Need help identifying a press", "Type Identification Help", "Manufacturer", "Identify", "unknown 8x12 chase", posted repeatedly by the same handful of people.
- **Points to:** An offline visual identification key: answer questions about the press frame/chase/throw-off/serial plate to narrow to manufacturer + model + date range; plus a metal-type specimen matcher (measure a lowercase 'a', check the pin mark and nick pattern).
- **Offline necessity:** WEAK-MODERATE, and I will say so honestly. Shops usually have wifi. The genuine offline moments are the ones that matter commercially though: identifying a press in a barn, a rural estate sale, a scrapyard or a basement before you commit to buying and hauling it — that is exactly where there is no signal and no time.
- **Audience size:** Briar Press's own counters: 50,544 posts in General discussion, 17,669 in Beginners, 33 guests online at read time. No member total is exposed. Best estimate of active letterpress printers worldwide: low tens of thousands; genuinely unknown from a retrieved page.
- **Data/licence note:** ✅ Good. Pre-1930 American/British type foundry specimen books (ATF 1923 specimen book, Inland, Barnhart Bros & Spindler) and press manufacturer catalogues are **public domain in the US** and scanned on the Internet Archive. ⚠️ Briar Press's own "Press Names" registry and "Cuts & Caps" library are **© 1995–2026 One Art New York, Inc.** (copyright line VERIFIED on briarpress.org page footer) — must not be scraped.

### Small-scale / farmstead cheesemakers — the make sheet

- **Query:** `cheesemaker "make sheet" pH acidity log paper notebook creamery small scale record keeping forum`
- **Source:** CheeseForum.org thread "Cheese Making Record Sheet" | **URL:** https://cheeseforum.org/forum/index.php?topic=9286.0 | **Date:** thread with long-tenured members (5,820 and 5,016 posts) | VERIFIED FETCH
- **Paraphrase:** Members trade home-made printable/fillable record sheets and critique each other's fields (multiple milks, multiple starters, rennet form, whey-drain pH target, flocculation factor, aging notes) — i.e. the profession's data model is being reinvented as PDFs in a forum thread.
- **Source (corroborating):** Center for Dairy Research, Univ. of Wisconsin | **URL:** https://www.cdr.wisc.edu/assets/pipeline-pdfs/pipeline_2020_vol31_04.pdf | **Date:** 2020, Vol 31 No 4 | unverified - from search snippet only
- **Paraphrase:** CDR's guidance is that without a recorded pH-development curve it is essentially impossible to diagnose a cheese defect after the fact.
- **Points to:** An offline make-sheet app: batch record with timestamped pH/temp/time entries, flocculation-multiplier timer, per-recipe target curve overlay, and a legal-name check against the federal cheese standards of identity.
- **Offline necessity:** MODERATE-STRONG. Farmstead make rooms are wet, steel-clad and usually on deep-rural properties; hands are gloved and wet; entries are time-critical (flocculation point, cut, drain), so a spinner or a login is disqualifying. Records are also a regulatory artefact you do not want in someone else's cloud.
- **Audience size:** **unknown from a retrieved page.** American Cheese Society and Guild of Book Workers do not expose member counts on their public pages (checked, VERIFIED FETCH — no numbers present). Order-of-magnitude guess only: a few thousand licensed artisan cheese plants in the US/UK/AU plus a much larger hobby tail.
- **Data/licence note:** ✅ Excellent. **21 CFR Part 133 "Cheeses and Related Cheese Products"** (moisture/fat minima and legal composition for every standardised cheese) is a US federal regulation — public domain, and machine-readable via the free eCFR API. I confirmed Part 133 exists and is retrievable: `GET https://www.ecfr.gov/api/versioner/v1/structure/2026-01-01/title-21.json` returns `Part 133—Cheeses and Related Cheese Products` with Subparts A and B (VERIFIED FETCH, HTTP 200, 2.68 MB). Recipes themselves are procedures/facts, but do not lift text from Caldwell or Curd Nerd.
- **App-store gap:** searching the App Store for `cheese making record` returns **only consumer cheese-*tasting* apps** (Cheezus 1 rating, Fromag.io 8, Grate Cheese 11, Good Cheese 12). Zero professional make-sheet apps. VERIFIED via iTunes search API.

### Glass artists / kiln workers — annealing schedule calculator

- **Query:** App Store `glass kiln annealing schedule`
- **Source:** Apple App Store search API | **URL:** https://apps.apple.com/us/app/tap-kiln-control-mobile/id1084198187 (154 ratings), https://apps.apple.com/us/app/kilnlink/id1422985590 (96 ratings), https://apps.apple.com/us/app/bartlett-kilnaid/id1336294986 (55 ratings) | **Date:** live query 2026-07-27 | VERIFIED FETCH (API)
- **Paraphrase:** Every kiln-related app in the store is an OEM *remote-monitoring* client that by definition requires a network; nothing in the store computes an annealing/soak schedule from glass type and thickness.
- **Points to:** Offline annealing/firing-schedule calculator — enter COE/glass family, thickest section, slab vs. blown, get segment-by-segment ramp/soak/cool with strain-point-anchored hold times, plus COE compatibility warnings.
- **Offline necessity:** MODERATE. Hot shops and kiln rooms are steel buildings, often basements or industrial units; you are programming the controller with tongs nearby and a timer running. But an honest note: many studios do have wifi, so offline here is "strongly preferable" rather than "physically forced".
- **Audience size:** unknown from a retrieved page — Glass Art Society's About page exposes no member count (checked, VERIFIED FETCH, no numbers). Likely low tens of thousands worldwide including hot glass, fusing and lampwork.
- **Data/licence note:** The annealing-time formulas and glass strain/anneal points are physical constants published in Bullseye TechNotes and Corning literature — the *numbers* are facts, but ⚠️ Bullseye's TechNotes documents are copyrighted and must not be reproduced. Compile from primary/technical-datasheet values and cite.

### Bookbinders — bench planner and imposition

- **Query:** App Store `bookbinding`
- **Source:** Apple App Store search API | **URL:** https://apps.apple.com/us/app/foliowright-bookbinding/id6791231460 (0 ratings), https://apps.apple.com/us/app/8-up-page-impositions/id491154303 (0 ratings) | **Date:** live query 2026-07-27 | VERIFIED FETCH (API)
- **Paraphrase:** The only two genuinely bookbinding-specific apps in the US store have zero ratings each; everything else returned is a reading-list tracker.
- **Points to:** Offline binding bench planner: signature/imposition layout, spine-swell and board-thickness calculation, grain-direction check, sewing-station spacing, case measurements from text-block dimensions.
- **Offline necessity:** WEAK — bench work, usually with wifi. I am recording this as a real gap but a poor fit for the offline test.
- **Audience size:** Guild of Book Workers publishes no member count on its About page (VERIFIED FETCH). Unknown.
- **Data/licence note:** No third-party dataset needed — all geometry/arithmetic. Clean.

### Taxidermists

- **Query:** App Store `taxidermy`
- **Source:** Apple App Store search API | **URL:** https://apps.apple.com/us/app/matuska-taxidermy/id1539895864 (529 ratings, a supplier catalogue) | **Date:** live query 2026-07-27 | VERIFIED FETCH (API)
- **Paraphrase:** The only meaningful taxidermy app is a supply company's shopping catalogue; there is no professional measurement/specimen-intake tool.
- **Points to:** Offline specimen intake: customer + animal record, the standard cape/carcass measurement set, form-size selection, tanning batch log, photo of the mount reference.
- **Offline necessity:** MODERATE. Measurements are taken at a hunting camp, a check station or in a walk-in freezer — no signal, cold, gloved hands.
- **Audience size:** unknown — taxidermy.net returned a Cloudflare challenge (HTTP 202) and I could not read member counts.
- **Data/licence note:** ⚠️ Form/mannikin size charts are the manufacturers' proprietary catalogues (Matuska, McKenzie, Research Mannikins). Bundling them is a licensing kill. Only the measurement *protocol* and the user's own records are safe.

---

## WEAK / SPECULATIVE

### Watchmakers — caliber lift-angle reference
- **Query:** `watchmaker forum "beat error" "amplitude" timing chart lift angle database spreadsheet`
- **Source:** NAWCC Message Board | **URL:** https://mb.nawcc.org/threads/timing-machine-beat-error.97074/ | **Date:** thread, no visible date on fetched copy | VERIFIED FETCH (via curl; WebFetch 403s)
- **Paraphrase:** Watchmakers argue about whether an implausible beat-error reading is the watch or the machine, and repeatedly guess at the lift angle ("probably less than 52 degrees, more like 36 or 40") because the correct per-caliber value is not to hand.
- **Points to:** Offline lift-angle + caliber spec lookup with a beat-error/amplitude explainer.
- **Offline necessity:** **WEAK — offline is fine but not the point.** The bench has wifi. Rejecting on the offline test.
- **Audience size:** AWCI exposes no member count publicly (VERIFIED FETCH). Unknown.
- **Data/licence note:** ⚠️ The existing lift-angle lists (watchguy.co.uk, lepsi.ch) are individually-compiled copyrighted compilations. You would have to build the table yourself.

### Water & wastewater plant operators
- **Query:** `wastewater treatment plant operator "no cell service" plant rounds paper log clipboard complaint`
- **Source:** O*NET OnLine 51-8031.00 | **URL:** https://www.onetonline.org/link/summary/51-8031.00 | **Date:** 2024 employment, page updated 2026 | VERIFIED FETCH
- **Paraphrase:** 132,400 US water/wastewater operators, whose listed duties include recording meter and gauge readings on specified forms and completing discharge monitoring reports.
- **Points to:** Offline rounds + process-control math (MCRT/SRT, F/M, detention time, chlorine dose).
- **Offline necessity:** STRONG on paper (below-grade galleries, wet wells, digester decks, remote rural lift stations).
- **Why I am marking it weak anyway:** the segment is **already served** — AWWA ships an official Opcert exam-prep app (741 ratings, https://apps.apple.com/us/app/awwa-opcert-exam-prep/id1574553544) and there are at least four operator calculators/exam apps in the store (Wastewater Manager, Water Operator Exam Prep 2026, RandyAI, Wastewater Operator Calculator). VERIFIED via iTunes search API. Also 132,400 is well above the 3k–50k band.
- **Data/licence note:** ✅ formulas and EPA/state operator manuals are US federal/state public domain.

### Brewery / winery cellar staff
- **Query:** App Store `brewery cellar log`
- **Source:** Apple App Store search API | **Date:** 2026-07-27 | VERIFIED FETCH (API)
- **Paraphrase:** Everything returned is a consumer wine-collection or beer-rating app (InVintory 4,327 ratings, Untappd 213,182); there is no professional cellar/tank log.
- **Points to:** Offline tank/vessel log — gravity, temp, DO, transfers, CIP records.
- **Offline necessity:** MODERATE (cellars are concrete basements). But this edges toward a generic log app, and BeerSmith/Brewfather already occupy the adjacent space.
- **Audience size:** unknown.
- **Data/licence note:** No external data needed.

---

## AUTO-REJECTED / ALREADY SERVED (checked so nobody re-checks)

### Elevator & escalator technicians — REJECT, already served
- **Query:** `elevator technician "no signal" hoistway machine room phone app paperwork`
- **Source:** LiftGrid product page; Avia Enterprises blog | **URL:** https://getliftgrid.com/mobile-app , https://aviaenterprises.net/blog/technician-safety-low-connectivity-offline-inspections/ | **Date:** current | unverified - from search snippet only
- **Paraphrase:** LiftGrid markets itself as an offline-first Android app built for basement shafts with no signal — jobs, checklists, parts, photos and signatures all working offline. The offline-first elevator field-service niche is taken.

### Reefer / marine transport refrigeration technicians — REJECT, served AND licence kill
- **Query:** `reefer container technician alarm code troubleshooting offline app ship deck "no internet" refrigerated`
- **Source:** Maersk Container Industry; Carrier Transicold | **URL:** https://www.mcicontainers.com/service/star-cool-apps/ , https://www.carrier.com/container-refrigeration/en/worldwide/products/data-tools/ | **Date:** current | unverified - from search snippet only
- **Paraphrase:** Both Carrier (ContainerLINK) and Maersk (Star Cool Service) already ship free apps with **offline** alarm-code lookup, offline manuals and offline converters for exactly this on-deck no-internet use case.
- **Licence kill:** the alarm-code tables are OEM proprietary anyway.

### Piano tuners — REJECT, saturated
- App Store `piano tuning technician` returns pianoscope (274 ratings), PianoMeter (41), plus Verituner and TuneLab; the open-source Entropy Piano Tuner also exists. VERIFIED via iTunes search API.

### Locksmiths — REJECT on licence
- App Store `locksmith key code` returns InstaCode Live (42 ratings), AutoCode (110), AutoProAPP (36). The depth-and-space / key-code databases are commercially licensed products (WH Software, American Key Supply); there is no openly-licensed bitting dataset. VERIFIED via iTunes search API.

### Welding QC / CWI — REJECT on licence
- The reference content a CWI actually needs is **AWS D1.1 / AWS QC1 / ASME IX**, all paid standards. Multiple CWI quiz apps already exist (CWI Exam Prep, CWI Welding Exam Prep, AWS-CWI Practices and Exams). VERIFIED via iTunes search API. **Paid-standard licensing kill.**

### Power station / substation techs — REJECT on licence
- The core field reference is arc-flash / PPE category tables from **NFPA 70E** and clearance tables from **NESC (IEEE C2)** — both paid standards. Not searched further; flagged as a licensing kill on principle.

### Stage lighting / stagehands — REJECT on licence
- App Store `stagehand rigging lighting` returns "Stagehand" (19 ratings) which bundles the **Roscolux, GAM, Lee and Apollo** gel swatch books — i.e. the useful data in this niche is manufacturer-copyrighted colour data, and rigging load calculation is on the safety-liability reject list. VERIFIED via iTunes search API.

### Merchant mariner / marine engineer exam prep — REJECT, served
- App Store `merchant mariner exam` returns Sea Trials (375 ratings) whose own description states all questions come from publicly available USCG materials, plus The Nautical School ExamTutor+ and several others. The public-domain USCG question bank has already been mined. VERIFIED via iTunes search API. (I could not reach nmc.uscg.mil or dco.uscg.mil directly — Akamai Access Denied.)

### Marine engineers — engine room logbook — REJECT
- The commercial-ship engine-room log and the Oil Record Book are **legally required to be maintained in a prescribed paper/official form** under MARPOL; and the reference publications (IMO, ICS Engine Room Procedures Guide, Marine Insight ebooks) are all paid/copyrighted. App Store `marine engineer engine room` shows only a hobby-boater "Marine Engine Logbook" (3 ratings). VERIFIED via iTunes search API.

### Dry cleaners — REJECT
- App Store `stain removal dry cleaner` returns only consumer pickup-and-delivery services (Tide Cleaners 7,931 ratings, CleanCloud 2,463). The professional stain-removal decision charts are **DLI (Drycleaning & Laundry Institute) paid member content** — licensing kill. VERIFIED via iTunes search API.

### Weaving / handloom drafts — REJECT, just got served
- App Store `weaving draft loom` returns two brand-new draft editors: Loom Weaving Drafts (id 6771689143, 0 ratings) and Bower: Weaving Design (id 6766585971, 1 rating, WIF import/export). Someone shipped this in 2026. VERIFIED via iTunes search API.

### Commercial kitchen / cold-chain HACCP logs — REJECT as generic
- App Store `HACCP kitchen temperature log` returns Kitchen HACCP Logs (0 ratings) and RiskLimiter Kitchen (0 ratings) alongside a wall of consumer smart-thermometer apps. The walk-in-freezer Faraday-cage offline argument is genuinely strong and the FDA Food Code is public domain, **but** the resulting product is a temperature log — which falls under the "generic tracker" auto-reject, and the audience (every restaurant) is far too large to be nameable.

---

## No evidence found

These queries produced nothing usable — either the tool returned generic/unrelated content, the target site blocked retrieval, or the search budget had run out. Recorded so they are not repeated:

- `elevator technician "no signal" hoistway machine room phone app paperwork` → only vendor marketing, no first-person technician complaint thread. **No primary evidence found.**
- `marine engineer ship engine room offline app reference "no internet" forum` → returned only ebook shops and a Google Play listing. **No forum thread found.**
- `piano tuner "no app" temperament calculation offline tuning forum thread` → returned only App Store listings. **No forum thread found.**
- `wastewater treatment plant operator "no cell service" plant rounds paper log clipboard complaint` → returned only agency guidance PDFs and job ads. **No operator complaint thread found.**
- `locksmith forum "depth and space" chart book field van "no signal" key bitting app` → returned trade-magazine articles and vendor pages only. **No forum thread found.**
- `conservator condition report field survey historic building "no wifi" tablet paper forms conservation` → returned conservation-firm service pages and NPS/Getty guidance; **nothing about offline data capture.** No evidence found.
- `theatre stagehand sound engineer offline reference app pinout connector DMX venue "no cell signal" backstage` → **search budget exhausted before this query ran.** Not searched. controlbooth.com subsequently returned HTTP 403 to direct fetch, so the theatre-tech community was never reached.
- Attempted and failed to retrieve: cameo.mfa.org (empty body ×2 — CAMEO licence **unverified**), taxidermy.net/forums (HTTP 202 Cloudflare), alloyavenue.com (HTTP 500), homedistiller.org (connection failed), nmc.uscg.mil and dco.uscg.mil/nmc/exams (Akamai Access Denied), bls.gov/oes (bot block), conservation-wiki.com api.php (non-JSON response).
- Association member counts I tried and **could not** verify from a retrieved page: American Cheese Society, Guild of Book Workers, Glass Art Society, AWCI (watchmakers), Piano Technicians Guild, ALOA (locksmiths) — none publish a member total on their public About/Membership pages.
- Groups on the assignment list that I could **not** reach any primary evidence for at all, and about which I am asserting nothing: submarine/mine workers, industrial electricians & PLC/instrumentation techs, HVAC plant-room techs, bakers, hobby machinists, luthiers/instrument repair, museum registrars as a distinct group, printers (offset), darkroom photographers, gunsmiths, tannery workers, foundry workers.


# ============================================================
# SOURCE FILE: research/raw/td-privacy-sensitive.md
# ============================================================

# TD — Privacy-Sensitive Groups Who Refuse Cloud Tools
Phase 1 discovery, top-down. Run date: 2026-07-27.

## Environment constraints hit during this run (read before judging coverage)
- reddit.com blocked (per brief) — not attempted.
- The session's **WebSearch budget was exhausted at 200/200 after my 10th search**. Everything after that was done with WebFetch on known URLs plus public JSON APIs (iTunes Search/Lookup, iTunes customer-reviews RSS, Discourse `search.json`, hn.algolia.com).
- Fallback search engines were all blocked: Bing via WebFetch returned unrelated junk; DuckDuckGo HTML/lite returned HTTP 202 anti-bot; Mojeek gave one page then 403 "automated queries"; searx.be / priv.au / search.inetol.net / searxng.site returned captcha / 429 / 403; Ecosia 403; Brave 429; Startpage anti-bot; Marginalia renders results in JS.
- `gh search repos` and `gh api search/repositories` returned empty for every query (no network or no auth from this sandbox) — so no GitHub-issue evidence in this file.
- No PDF text extractor on this machine (`pdftotext` absent, PyObjC/Quartz absent), so the BACP GPiA065 PDF could not be read even though it downloaded.

---

### Solo private-practice therapists / counsellors building their own local-only note systems
- **Query:** `HIPAA client notes` (Discourse search API on forum.obsidian.md), after WebSearch `therapist private practice "offline" notes app "not use cloud" HIPAA EHR refuse`
- **Source:** Obsidian community forum (Discourse) | **URL:** https://forum.obsidian.md/t/61642 | **Date:** thread opened 2023-06-15, last reply 2025-07-11, 5,127 views, 13 posts | VERIFIED FETCH (pulled `/t/61642.json` and read post bodies)
- **Paraphrase:** A counsellor asks other mental-health professionals to critique a *locally stored* psychotherapy-notes system he built rather than use a commercial EHR; over two years other therapists join in, one saying it is "interesting to think about escaping commercial EHRs" and that with AI in the mix "the best way to counter this is to run the entire system offline," while flagging that HIPAA still expects an access audit trail and intrusion detection.
- **Points to:** An offline-only, account-free clinical **process-notes** app: per-client vault, session templates (intake battery, session note, treatment-plan review), fast client switching, an on-device tamper-evident access/audit log, local encryption with a real key, and print/PDF export for subpoena or transfer of care.
- **Offline necessity:** Psychotherapy process notes are the single most sensitive record class a clinician holds; these clinicians are explicitly refusing to put them on a vendor's server at all, and a locked-down local app is the only architecture that satisfies them. Not a "would be nice offline" case — the whole motivation is *never leaves the device*.
- **Audience size:** unknown exactly. Thread has 5,127 views; the sub-segment is "solo private-practice therapists who reject cloud EHRs", which is plausibly small but I could **not** verify a number (BACP and APA membership pages I fetched did not state one — see no-evidence section).
- **Data/licence note:** No bundled dataset needed. Note frameworks (SOAP/DAP/BIRP) are generic formats, not copyrighted content. Deliberately exclude any diagnostic criteria (DSM/ICD text is licensed) and any dosing/assessment scoring.

---

### Foster carers' statutory daily logs (England ≈56k carers)
- **Query:** `foster carer daily log recording requirement "daily diary" app data protection social worker sees notes number of foster carers UK Ofsted`
- **Source:** GOV.UK official statistics | **URL:** https://www.gov.uk/government/statistics/fostering-in-england-1-april-2024-to-31-march-2025/main-findings-fostering-in-england-1-april-2024-to-31-march-2025 | **Date:** published 2025 (data as at 31 March 2025) | VERIFIED FETCH
- **Paraphrase:** England had 56,345 approved mainstream foster carers across roughly 33,4xx approved mainstream fostering households as at 31 March 2025, down 1% year on year.
- **Supporting source 1:** Lika Family Fostering | **URL:** https://likafamilyfostering.co.uk/daily-logs-foster-carers/ | **Date:** 2021-01-06 | VERIFIED FETCH — spells out that the daily log must capture unexplained injuries, allegations, self-harm, missing episodes, family contact, school engagement, professional visits and consequences imposed, that logs are "regularly sent to the young person's social worker" and become part of the local authority's record, and warns "missing logs build up quickly."
- **Supporting source 2:** Rainbow Fostering Services | **URL:** https://www.rainbowfostering.com/blog/keeping-records-safely-gdpr-and-safeguarding-in-daily-notes | **Date:** 2024-08-05 | VERIFIED FETCH — tells carers never to move records over "Unsecured platforms (e.g. WhatsApp, personal email)", to keep paper in locked cabinets not shared with family, and to keep digital devices password-protected and encrypted.
- **Points to:** An offline foster-carer daily-log app: one timeline per child, structured safeguarding categories (injury / allegation / missing / contact / medical / education / achievement), quick voice-to-text at 11pm, photo evidence held inside the app sandbox rather than the camera roll, month-end export as a clean PDF/CSV the supervising social worker will accept, and hard local retention rules.
- **Offline necessity:** The content is UK GDPR *special category* data about a looked-after child, and agency policy explicitly forbids the consumer cloud channels carers would otherwise reach for. Logs also become evidence in allegation and care proceedings, so provenance matters more than sync. Carers write them late at night on a phone in a house shared with the child and birth family.
- **Audience size:** 56,345 approved mainstream foster carers in England alone (GOV.UK, 31 Mar 2025). Add Scotland/Wales/NI and Australia/NZ/Ireland and it stays comfortably inside the target band for a paid niche app.
- **Data/licence note:** No dataset strictly required. Optionally bundle the *Fostering Services: National Minimum Standards* and the Fostering Services (England) Regulations as an offline reference — UK Crown copyright under the Open Government Licence v3.0, which permits commercial reuse with attribution (verify per document).

---

### Domestic-abuse survivors keeping an incident log — the sector's own app has disappeared
- **Query:** `domestic violence survivor evidence log app abuser shared iCloud account sees photos safety planning NNEDV` (plus targeted fetches)
- **Source:** NNEDV Safety Net Project | **URL:** https://www.techsafety.org/documentationtips | **Date:** page carries a 2025 copyright and a "2025" sample log | VERIFIED FETCH
- **Paraphrase:** NNEDV's own guidance tells survivors to "keep a log of all incidents, even if you are not sure if you want to involve the police or courts," and warns that if the abuser discovers the survivor is documenting, the abuse may escalate.
- **Supporting source 1:** NNEDV Safety Net | **URL:** https://www.techsafety.org/choosingapps/ | **Date:** page undated, linked PDF filename shows 2017 | VERIFIED FETCH — warns that "even if you delete an app from your device, the history of the download will still exist on the device, within any backups or synced records, or your App Store/Google Play store account."
- **Supporting source 2 (gap evidence):** VAWnet event record for the NNEDV webinar introducing **DocuSAFE**, the free evidence-collection app for survivors, launched 2020-05-07 | **URL:** https://vawnet.org/events/understanding-and-using-docusafe-documentation-evidence-collection-app | **Date:** 2020-05-11 | VERIFIED FETCH.
- **Supporting source 3 (gap evidence):** DocuSAFE now appears withdrawn — https://www.techsafety.org/docusafe and https://www.techsafety.org/docusafe-privacy-policy both return **HTTP 404** (fetched 2026-07-27), the Google Play listing `org.nnedv.docusafe` returns 404, and an iTunes Search API query for "DocuSAFE" returns no matching app in the US store. VERIFIED (verified by absence — I confirmed the 404s and the empty store query myself; I could not find a retirement announcement, so treat "withdrawn" as inference).
- **Points to:** A disguised, account-free, 100% local incident log: timestamped entries with location optional, in-app camera whose photos never touch the camera roll, per-entry SHA hash + immutable created-at for evidential weight, PIN with a decoy/panic mode, and a one-tap "court chronology" PDF export the survivor can hand to an advocate or solicitor.
- **Offline necessity:** Strongest case in this whole file. The threat model *is* the cloud — the abuser frequently controls or shares the Apple/Google account, sees family-sharing purchase history, and can restore the survivor's backup. Anything with an account, a sync, or a purchase receipt leaks. It also has to work with no signal (rural, refuge, phone in airplane mode).
- **Audience size:** unknown. I could not verify a defensible number for "survivors actively keeping a documentation log" and will not guess. Distribution channel is nameable though: DV coalitions and advocate networks that already publish NNEDV's documentation guidance.
- **Data/licence note:** No bundled dataset. Do **not** bundle legal advice or jurisdiction-specific "what counts as evidence" text — that is the liability line. Pure capture + export only.

---

### Court and community interpreters' NDA-bound glossaries
- **Query:** `court interpreter glossary NDA confidential "offline" app terminology management` and `proz.com forum interpreters glossary app phone courtroom "no internet" terminology booth`
- **Source:** InterpretBank (the incumbent tool) | **URL:** https://www.interpretbank.com/ | **Date:** fetched 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The category-leading interpreter terminology tool is a Windows/macOS desktop program at €349 perpetual or €9.99–15.99/month, and its mobile story is a **WebApp you sync to** — offline access on a phone exists only after syncing glossaries through their cloud.
- **Points to:** A phone-native, no-account offline glossary + assignment-prep notebook for public-service interpreters: per-assignment glossary vaults that can be destroyed when the job ends, sub-second bilingual lookup while someone is talking, a "add term I just fluffed" one-tap capture, numbers/names scratchpad, and per-assignment billing minutes. Explicitly no upload path.
- **Offline necessity:** Court holding areas, custody suites, tribunal basements, hospital interiors and prison visit rooms routinely have no signal, and many courts require phones in airplane mode or off. Separately, glossaries built from case bundles or client material are covered by NDAs/confidentiality codes, so syncing them to a vendor's server is a professional-conduct problem, not just a preference.
- **Audience size:** **unknown / not verified.** I tried NAJIT (`najit.org/about/` → 404), CCHI (homepage states certification since 2009 but publishes no count), and the US Courts federal interpreter page (no counts). Do not quote a number for this niche until a state-judiciary roster is counted directly.
- **Data/licence note:** Content is user-entered, so no licence risk in the core product. Optional bundled seed glossaries could come from US state/federal court publications (e.g. the 2024 Federal Court Interpreter Orientation Manual and Glossary on uscourts.gov, Tennessee AOC's legal terminology glossary, Florida courts' Consortium glossary) — US federal government works are public domain, state works need per-state checking. **Do not** bundle any paid terminology database.

---

### Home-birth midwives (CPMs) — offline labour observation log
- **Query:** `doula birth notes app "offline" hospital no signal basement labor documentation private practice` plus direct verification fetches
- **Source:** NARM (North American Registry of Midwives) | **URL:** https://narm.org/ | **Date:** figure stated as of 2024-10-15 | VERIFIED FETCH
- **Paraphrase:** NARM reports 4,772 Certified Professional Midwife credentials issued as of 15 October 2024 (up from 4,120 in Nov 2021) — a precisely nameable community right in the target size band.
- **Supporting source:** Mobile Doula (the closest incumbent) | **URL:** https://apps.apple.com/us/app/mobile-doula/id909265632 | **Date:** metadata pulled from the iTunes Lookup API 2026-07-27: v1.0.189, last updated 2026-05-21, 338 ratings, 4.75 avg | VERIFIED FETCH — its own description says it works with no internet but that "once an internet connection is detected all of your data will backup to the Mobile Doula servers", i.e. offline is a resilience feature layered on an account-based cloud product, not a privacy stance. It is also aimed at doulas' business admin, not at timed clinical observations.
- **Points to:** An offline labour/visit **observation log** for home-birth midwives and birth-centre staff: interval timers for fetal heart tone checks, one-tap vitals and contraction entries onto a scrolling timeline, freeform narrative, medications/supplies given, and a PDF export for the client's own record and for transfer-of-care handover.
- **Offline necessity:** Births happen in the client's house, often deep rural, sometimes over 24–48 hours; signal is unreliable and the midwife's hands are busy. Records are also legally exposed — CPM scope of practice is restricted or unlicensed in several US states and home-birth records get subpoenaed, so practitioners are structurally hostile to a vendor holding them.
- **Audience size:** 4,772 CPM credentials (NARM, Oct 2024), plus a larger pool of birth-centre and community midwives internationally.
- **Data/licence note:** No dataset. **Liability guardrail:** must be recording-only — no normal ranges, no partograph action lines, no alerts, no "consider transfer" logic. The moment it advises, it is a medical device.

---

### Correctional educators and prison-programme volunteers (reported, but weak as a phone app)
- **Query:** `prison education teacher no internet laptop "offline" classroom incarcerated students technology restrictions`
- **Source:** The Markup | **URL:** https://themarkup.org/machine-learning/2025/08/07/prison-education | **Date:** 2025-08-07 | VERIFIED FETCH
- **Paraphrase:** Reporting on Cal State LA's Prison Graduation Initiative describes instructors pairing incarcerated students with on-campus peers who print library materials to carry inside, and pre-loading academic articles onto thumb drives so students can read them offline on prison classroom desktops.
- **Points to:** Offline content packaging / offline reference for correctional education.
- **Offline necessity:** Real and absolute inside the wire.
- **Audience size:** unknown from this article (it names two programmes and three students, no totals).
- **Honest verdict — WEAK for our purposes:** the people who need it most cannot carry a phone. Most facilities require staff and volunteers to lock phones away too, and students have prison-issued laptops, not Android/iOS devices. A Flutter phone app is the wrong form factor for this constraint. Reporting it so it is not re-discovered later.

---

### Stigmatised self-tracking — account dependence is the thing users actually get burned by
- **Query:** iTunes customer-reviews RSS + App Store review page for Epsy (id 1479108189)
- **Source:** Apple App Store reviews | **URL:** https://apps.apple.com/us/app/epsy-seizure-log-for-epilepsy/id1479108189?see-all=reviews | **Date:** review dated May (most recent page, fetched 2026-07-27) | VERIFIED FETCH
- **Paraphrase:** A one-star reviewer titled "Loved it, Now I hate it" reports the app logged them out after an update and lost every log, note and medication entry, and that the forced logout recurs monthly.
- **Supporting source:** eMoods Bipolar Mood Tracker reviews via the iTunes reviews RSS (`.../id=1184456130/sortby=mostrecent/json`), review dated 2018-11-22 | VERIFIED FETCH — a user notes it saves "on one device with option of backing it up" and *wishes* it had a login, i.e. the local-first model is already the norm here.
- **Points to:** Account-free, local-only symptom/seizure diaries.
- **Offline necessity:** Moderate. The data is genuinely stigmatised (seizures, psychiatric symptoms) and users don't want it on a server, but honestly **offline is not strictly required** for most of these — it's a preference plus a data-loss argument.
- **Audience size:** large and already contested — Epsy 1,668 ratings, EpiCentr 1,475, eMoods 4,190, Bearable 5,952, HarmLess 8,740 (all from the iTunes Search API, 2026-07-27).
- **Data/licence note:** none.
- **Honest verdict — WEAK/MODERATE.** Crowded, and the offline argument is a preference not a necessity. Only worth revisiting for a specific stigma where no app exists at all.

---

### Self-harm trackers — the privacy users want is "hide it from my parents", and it is already served
- **Query:** iTunes Search `self harm recovery tracker` → App Store reviews for HarmLess (id 1537897066)
- **Source:** Apple App Store reviews | **URL:** https://apps.apple.com/us/app/harmless-self-harm-tracker/id1537897066?see-all=reviews | **Date:** reviews spanning 2022-06-21 to 2025-06-22 | VERIFIED FETCH
- **Paraphrase:** A reviewer values the app's password specifically because their parents check their phone; other reviews complain only about the premium paywall — nobody raises servers, accounts or syncing.
- **Points to:** Nothing new. 4.8★ across ~8,700 ratings, actively maintained.
- **Offline necessity:** Weak — the threat model is a person holding the phone, which a PIN already solves.
- **Audience size:** large, well served.
- **Verdict — DEAD END.**

---

### Human-rights fieldworkers and war-crimes documenters — already solved, do not pursue
- **Query:** direct verification fetch after the DV thread
- **Source:** Tella (Horizontal, 501(c)(3)) | **URL:** https://tella-app.org/ | **Date:** fetched 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Tella is an offline-first, open-source, free-forever mobile app built to "collect, protect and hide sensitive data" for activists, journalists and human-rights defenders, works with no account, and can transfer files to nearby devices fully offline.
- **Points to:** Nothing — this niche is covered by a well-funded nonprofit, and eyeWitness to Atrocities covers the chain-of-custody variant.
- **Verdict — DEAD END.** Add to the already-checked list.

---

### Doulas — partially served by an offline-capable but cloud-backed incumbent
- **Query:** `doula birth notes app "offline" hospital no signal basement labor documentation private practice`
- **Source:** Mobile Doula | **URL:** http://www.mobiledoulaapp.com/Doula-Tablet-App.aspx and https://apps.apple.com/us/app/mobile-doula/id909265632 | **Date:** app last updated 2026-05-21 | VERIFIED FETCH (iTunes Lookup API)
- **Paraphrase:** An actively maintained iPad/iPhone doula practice app that explicitly markets working at a home or hospital birth with no WiFi, then backs everything up to its own servers when a connection appears.
- **Points to:** Business-admin side of doula work is taken. The unserved slice is the *clinical observation timeline* (see the midwife entry), and a genuinely serverless option for doulas who object to a vendor holding client health histories.
- **Audience size:** 338 US App Store ratings suggests a small installed base; DONA-certified doulas number in the low thousands (not verified here).
- **Verdict — MODERATE at best; overlaps the midwife lead.**

---

## No evidence found (dead-end queries and failed verifications)
Recording these so they are not repeated.

- `BACP membership size` — fetched https://www.bacp.co.uk/about-us/about-bacp/ : page states no membership number. The GPiA065 confidentiality/record-keeping PDF (https://www.bacp.co.uk/media/20401/bacp-confidentiality-and-record-keeping-crp-gpia065-jan24.pdf) downloaded but **could not be text-extracted** on this machine. Its content on cloud storage is therefore **unverified**.
- `RID (Registry of Interpreters for the Deaf) membership count` — https://rid.org/about-rid/ returns 404; https://rid.org/ body was truncated and contained no figure. No evidence found.
- `Association of Professional Chaplains membership count` — https://www.professionalchaplains.org/about-apc/ redirects to https://www.apchaplains.org/, which publishes no membership figure. No evidence found. Chaplain/hospice-volunteer visit-note niche remains **unsized and unevidenced**.
- `CCHI certified healthcare interpreter count` — https://cchicertification.org/ publishes no total. No evidence found.
- `Federal certified court interpreter count / annual interpreting events` — http://www.uscourts.gov/court-programs/federal-court-interpreters gives categories and fees but no counts. No evidence found.
- `IAFN / SANE membership count and offline forensic documentation tools` — WebSearch `"sexual assault nurse examiner" documentation forensic photography body map offline tablet IAFN members number` returned protocol and training documents only, no membership figure and no discussion of offline tooling. Also note: SANE documentation sits close to the clinical-liability line and is probably auto-reject territory.
- `CASA / guardian ad litem volunteer count` — https://nationalcasagal.org/our-work/the-casa-gal-model/ only states that programmes "train more than 24,000 new community advocates" per year, gives no total volunteer count and says nothing about documentation tooling. The CASA/GAL angle (home-visit notes on abused children, held by an untrained volunteer, confidential from the family) is **plausible but unevidenced** — worth one more pass when search budget exists.
- `Harm-reduction street outreach documentation burden` — the open-access qualitative study at https://pmc.ncbi.nlm.nih.gov/articles/PMC11363392/ (2024-08-30) was fetched in full and contains **nothing** about how outreach workers document encounters, paperwork burden, or reluctance to record identifying data. No evidence found for this niche.
- `DocuSAFE retirement announcement` — no announcement located; only the 404s and store absence documented above.
- `Existing foster-carer daily-log iOS app` — iTunes Search for `foster carer log` returned only unrelated apps (Foster Friendly, Care.com, WellSky). Weak negative evidence, not proof of absence.
- `Existing offline interpreter glossary iOS app` — iTunes Search for `interpreter glossary` returned only live-interpreting and machine-translation apps. Weak negative evidence.
- `Existing incident-log / abuse-documentation iOS app` — iTunes Search for `incident log abuse` and `abuse journal diary evidence` returned only generic locked-diary apps and law-enforcement evidence tools (Axon). Weak negative evidence, consistent with the DocuSAFE gap.
- `Obsidian/Logseq forum threads for chaplains, doulas/midwives, prison workers, DV advocates, interpreters` — Discourse `search.json` on forum.obsidian.md and discuss.logseq.com returned no relevant threads for any of those terms. No evidence found.
- `GitHub projects/issues in these niches` — `gh search repos` and `gh api search/repositories` returned empty for all four queries tried; no GitHub evidence obtainable in this environment.
- `Journalists' source management / lawyers' client intake` — not reached before the search budget ran out. Untouched, not disproved.
- Untouched for the same reason: lactation consultants, social workers/child protection staff, needle-exchange workers specifically, prison-visit volunteers, addiction recovery sponsors, hospice volunteers, sign-language interpreters, asylum caseworkers.


# ============================================================
# SOURCE FILE: research/raw/td-misc-odd.md
# ============================================================

# TD — Misc / Odd & Overlooked Groups (Phase 1 Discovery)

Date of research: 2026-07-27
Researcher note on method: reddit.com is blocked in this environment and was not used. The
session's WebSearch budget was exhausted after 6 successful queries, so the remainder of the
research was done with (a) the **iTunes/App Store Search API** (`itunes.apple.com/search`) to
map what already exists in each niche, (b) **Apple App Store review pages**
(`apps.apple.com/...?see-all=reviews`) as the substitute for Reddit — these render real user
complaint text, (c) **DuckDuckGo Lite/HTML via WebFetch** as a search substitute (frequently
CAPTCHA-throttled — noted where it failed), (d) the **GitHub API via `gh`** for licence checks,
(e) **HN Algolia** and **Stack Exchange API** (tested, low yield for these niches), and
(f) direct fetches of association / regulator pages for community size.
Bing's RSS endpoint returned SEO-poisoned junk and was abandoned. Mojeek 403'd.

---

## STRONG LEADS

### Motorsport marshals, post chiefs and rally stage crews
- **Query:** `motorsport marshal post chief signals flag app "no signal" paper forms rally` (WebSearch), then direct fetch of the Motorsport UK volunteer page
- **Source:** Motorsport UK (national governing body) | **URL:** https://www.motorsportuk.org/volunteers/ | **Date:** retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Motorsport UK says its 9,500 registered volunteers — marshals, scrutineers, timekeepers, rescue/recovery — are what make 5,000 UK motorsport events a year possible.
- **Source (supporting):** FIA Rally Safety Guidelines 2021 (3rd ed.) | **URL:** https://www.fia.com/sites/default/files/rally_safety_guidelines_2021_en_v6_web.pdf | **Date:** 2021 | unverified — from search snippet only
- **Paraphrase:** FIA guidance describes marshal posts strung along closed public-road stages in remote terrain, with the chief marshal responsible for making sure each post has the correct paperwork.
- **Source (supporting):** British Motorsports Marshals Club | **URL:** https://www.marshals.co.uk/ | **Date:** retrieved 2026-07-27 | VERIFIED FETCH — BMMC calls itself the largest marshal body in the UK but publishes no membership figure.
- **App-landscape check:** iTunes Search API for `motorsport marshal` and `rally marshal post` returned **only racing games and magazines** (Motorsport Manager, F1 Clash, CarX Rally, Rally Tripmeter). Zero marshal-facing tools. (VERIFIED — API call.)
- **Points to:** An offline marshal's post kit — flag/light signal drill trainer, post log (times, incidents, car numbers, radio messages passed), incident report builder, post-to-post checklist, signing-on/hours record, and a marshal grade/upgrade logbook that produces a PDF at end of event.
- **Offline necessity:** Rally stages are forest tracks and closed mountain roads with no coverage at all; circuit posts sit inside concrete-and-catchfence dead zones. Marshals wear gloves, stand in the rain, and cannot wait on a spinner or a login while a car is off. This is the strongest form of the offline test: no signal, hands busy, safety-relevant timing.
- **Audience size:** 9,500 Motorsport UK registered volunteers (verified fetch, 2026). Comparable national bodies (MSA-adjacent clubs in IE/AU/NZ/ZA, SCCA/NASA workers in the US) multiply this; the addressable English-language marshal population plausibly sits in the 20k–60k band.
- **Data/licence note:** Do **not** bundle the Motorsport UK Yearbook ("Blue Book") or FIA Appendix H text — both copyrighted. Bundle only: the flag/light *meanings* as short original prose (facts, restated), the ICS-style post log structure, and user-entered data. FIA Rally Safety Guidelines is a freely published PDF but redistribution rights are unclear — reference it, don't copy it.

### Disaster-response volunteers filling ICS forms (CERT, SAR teams, ARES/RACES)
- **Query:** `ARES RACES ICS-213 radiogram message form app offline no internet emergency communications` (WebSearch) + App Store review mining
- **Source:** Apple App Store reviews for the "ICS-214" app (Mike Comer) | **URL:** https://apps.apple.com/us/app/ics-214/id6520380813?see-all=reviews | **Date:** reviews 2024-07 to 2025-09 | VERIFIED FETCH
- **Paraphrase:** Eleven reviewers — clearly real responders — praise a bare-bones single-form app for producing a clean unwatermarked ICS-214 on deployment, then list obvious gaps: no chronological auto-sort, an 79-character limit, agency names truncated in the PDF, and one report of the app failing mid-incident.
- **Source (supporting):** FEMA Emergency Management Institute ICS Resource Center | **URL:** https://training.fema.gov/icsresource/icsforms.aspx | **Date:** retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** FEMA publishes ~35 ICS forms (201, 202, 203, 204, 205, 205A, 206, 207, 208, 209, 211, 213, 213RR, 214, 215, 215A, 218, 219 T-cards in ten colours, 220, 221, 225) as fillable PDFs plus the NIMS ICS Forms Booklets.
- **Source (supporting):** ARRL ARES programme page | **URL:** https://www.arrl.org/ares | **Date:** retrieved 2026-07-27 | VERIFIED FETCH — ARES describes itself as the volunteers who operate "when all else fails", i.e. precisely when cell and internet are gone. No membership number published on that page.
- **Source (supporting):** Mountain Rescue Association | **URL:** https://mra.org (via search snippet) | **Date:** 2025 | unverified — from search snippet only — "137 affiliated member teams" across 32 states and two countries.
- **App-landscape check (VERIFIED, iTunes API):** the entire category is three tiny apps — ICS Dashboard (7 ratings, supports *one* form), ICS-214 (11 ratings), InciNotes ICS 214 (2.5 stars, 20 ratings, **last updated 2016**) — plus Cal OES's official FIRESCOPE FOG ICS 420-1 reader (2 ratings). Nothing covers the form set.
- **Points to:** A complete offline ICS field kit: fillable ICS 201/202/204/205/205A/206/213/213RR/214/309, a colour-coded T-card (ICS 219) resource tracker, an ICS-213 / ARRL-radiogram message composer with a sequential traffic log, and PDF export by AirDrop/Bluetooth/USB. All state on device.
- **Offline necessity:** Categorical. The scenario the tool exists for is the scenario in which the network is down. A cloud form app is disqualified by definition; several of the reviewed apps already fail this by asking for iCloud sync.
- **Audience size:** MRA alone ~137 teams (≈5,000–6,000 credentialled searchers); ARES units in 71 ARRL sections; state/county CERT programmes. The *serious, ICS-fluent, form-filling* slice — not the whole 600k-trained CERT population — is plausibly 20k–50k in the US. Precise regulator number: **not found**; ARRL does not publish ARES enrolment on the public page.
- **Data/licence note:** FEMA/NIMS ICS forms are works of a US federal agency and are conventionally treated as public domain — but note the FEMA page carries **no explicit licence statement** (verified), so confirm before shipping. Do **not** bundle ARRL's FSD-3 numbered radiogram texts (ARL messages) without checking ARRL copyright; the bare radiogram *format* (preamble/address/text/signature) is a procedure, not protected expression.

### High-power and model rocketry (deepening the existing lead)
- **Query:** `"model rocketry" ThrustCurve API data licence offline simulator app motor database` (blocked — budget), replaced by GitHub API licence check + iTunes API sweep
- **Source:** GitHub, `openrocket/motor-database` | **URL:** https://github.com/openrocket/motor-database | **Date:** last commit 2026-07-26 | VERIFIED FETCH (via `gh api`)
- **Paraphrase:** OpenRocket's motor data is a **GPL-3.0** repo that pulls John Coker's ThrustCurve.org API weekly, caches the raw `.eng`/`.rse` files and compiles them into a single gzipped **SQLite `motors.db`** published on GitHub Pages — i.e. a ready-made, downloadable, offline-shaped motor dataset.
- **Source (supporting):** Wikipedia, National Association of Rocketry | **URL:** https://en.wikipedia.org/wiki/National_Association_of_Rocketry | **Date:** retrieved 2026-07-27 | VERIFIED FETCH — "over 8,000 members and 200 affiliated clubs"; infobox gives 8,850 (The Electronic Rocketeer #156, July 2022).
- **Source (supporting):** Wikipedia, Tripoli Rocketry Association | **URL:** https://en.wikipedia.org/wiki/Tripoli_Rocketry_Association | **Date:** retrieved 2026-07-27 | VERIFIED FETCH — confirms TRA runs prefecture launches and LDRS/BALLS but publishes **no** membership figure there.
- **App-landscape check (VERIFIED, iTunes API):** searching `model rocket motor simulation` and `rocketry altimeter flight` returns **only arcade games** (Spaceflight Simulator, Rocket Sky!, SimpleRockets) and generic barometric altimeters. There is no mobile OpenRocket, no mobile motor picker, no flight-card tool. OpenRocket is desktop Java; RockSim is desktop and paid.
- **Points to:** An offline flight-line companion — bundled ThrustCurve motor database with thrust curves; motor-vs-airframe selector (thrust-to-weight, rail exit velocity, Cd/mass entry); simple 1-DOF/3-DOF sim for apogee, optimal delay and drift radius given wind; recovery bearing/distance calculator; RSO flight-card generator; certification-flight logbook; parachute descent-rate and shock-cord sizing.
- **Offline necessity:** High-power launches are held on dry lakebeds, prairie farmland and desert playas precisely because they are empty — Black Rock, Lucerne, Argonia and similar sites have no cellular coverage. The flyer needs the delay-grain answer standing at the pad with a motor in hand, in wind, before the RSO waves them off. (Direct "no cell service" quote from a club page: **no evidence found** — DDG returned zero results for that query twice, so treat the connectivity claim as inference from site geography, not a cited source.)
- **Audience size:** NAR ~8,850 members / 200 clubs (verified); Tripoli adds a few thousand more; UKRA/EuRoC and university teams beyond that. Comfortably in the 10k–30k band.
- **Data/licence note:** The compiled motor DB is **GPL-3.0** — usable commercially but copyleft, which is awkward inside a closed-source Flutter binary. Safer route: pull the underlying `.eng`/`.rse` files from **ThrustCurve.org's public API** and check John Coker's own terms directly (his data is manufacturer-supplied certification data — largely factual). NAR/TRA certified-motor lists are published tables of facts. Physics/atmosphere models (US Standard Atmosphere 1976) are US-government public domain.

---

## MODERATE LEADS

### Blacksmiths and bladesmiths (shop-floor metallurgy reference)
- **Query:** `iforgeiron forum unknown steel heat treat chart shop reference` (DDG Lite via WebFetch)
- **Source:** ABANA (Artist-Blacksmith's Association of North America) | **URL:** https://abana.org/about/ | **Date:** retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** ABANA calls itself North America's largest blacksmithing body and states there are roughly 90 affiliate groups worldwide; it gives no headline member count beyond "members numbered in the thousands".
- **Source (supporting):** I Forge Iron heat-treating forum | **URL:** https://www.iforgeiron.com/forum/68-heat-treating-general-discussion/ | **Date:** ongoing | unverified — from search snippet only
- **Source (supporting):** ShopFloorCalc heat-treat reference | **URL:** https://shopfloorcalc.com/heat-treat/ | **Date:** 2025-ish | unverified — from search snippet only — a searchable web reference of normalize/anneal/harden/temper/quench data for 70+ alloys, i.e. someone already proved the demand exists but built it as a website.
- **App-landscape check (VERIFIED, iTunes API):** searching `blacksmith forge` returns **only idle/clicker games** (Forge Ahead, Shop Titans, Blade Forge 3D). Zero real tools.
- **Points to:** An offline forge/shop reference: heat-treat schedules per alloy (1084, 1095, 5160, 52100, W1, O1, A2, D2, 4140…), spark-test and file-test identification key for mystery scrap steel, forging-colour↔temperature chart with a camera-free manual matcher, bar-bending/scroll developed-length calculator, upset and taper stock math, tong/hardy/punch sizing tables, coal-vs-propane BTU and anvil-rebound notes, plus a per-project heat log.
- **Offline necessity:** Forges are metal sheds, basements and rural outbuildings; the smith's hands are gloved and sooty, the steel is at temperature and the answer is needed in seconds. Moderate rather than absolute — a lot of shops do have wifi.
- **Audience size:** ~90 ABANA affiliates (verified); ABANA-scale North American membership is "thousands". Add UK BABA, Australian ABA and the knifemaking overlap and the serious population is plausibly 15k–40k. No precise regulator number exists (unlicensed craft).
- **Data/licence note:** Heat-treat temperatures are facts and individually uncopyrightable, but a *compiled table* copied from ASM Handbook / Machinery's Handbook would infringe the compilation. Build the table from manufacturer datasheets (Crucible, Aldo, Uddeholm) restated in your own structure, plus public-domain US military/NIST handbook data. No safety-critical liability (not structural or rigging).

### Orienteers (control descriptions, course planning, punch discipline)
- **Query:** `orienteering IOF control descriptions symbols app training offline` (WebSearch)
- **Source:** Iknow-O | **URL:** https://www.iknow-o.com/ | **Date:** retrieved via search 2026-07 | unverified — from search snippet only
- **Paraphrase:** The best-known IOF control-description trainers (Iknow-O, Octavian Droobers' 22-level quiz) are browser tools on club websites, not apps.
- **Source (supporting):** British Orienteering historical membership | **URL:** https://archives.shef.ac.uk/agents/corporate_entities/167 | **Date:** covers 1998 | unverified — from search snippet only — ~10,000 members and 150+ clubs by 1998.
- **Source (supporting):** OIA member news on British Orienteering | **URL:** https://www.theoia.co.uk/member-news/british-orienteering-participation-surges-again-in-2025 | **Date:** 2025/2026 | unverified — from search snippet only — 156,300 total runs in 2025, up from 149,294 in 2024.
- **App-landscape check (VERIFIED, iTunes API):** `orienteering control description` returns satnav apps, an "Orienteering" app with **0 ratings**, and a virtual-orienteering game with 48. The IOF symbol set has essentially no native mobile presence.
- **Points to:** An offline orienteering trainer/reference — full IOF control-description symbol set with drill modes and multi-language column-by-column decoding, ISOM/ISSprOM map-symbol reference, pace-counting and rough-vs-fine navigation drills, split-time self-analysis from a manually entered or GPX-imported run, and a course-planner's checklist.
- **Offline necessity:** Orienteering happens in forest and moorland with no coverage, and the pre-start quarantine explicitly bans connected devices at serious events — a networked app is not merely inconvenient, it is *disallowed*. That is an unusually clean offline argument.
- **Audience size:** British Orienteering ~10,000 members historically (1998, unverified); 156k runs/yr in GB (unverified). IOF has 70+ member federations; Nordic membership is far larger. English-language addressable core plausibly 20k–50k.
- **Data/licence note:** The IOF "International Specification for Control Descriptions" and ISOM map spec are IOF copyright — **do not** bundle the PDFs or redraw the plates verbatim. Redraw symbols as original vector art and write your own definitions; the symbol *system* is a functional standard but the published artwork is not free. This is the main risk on this lead and should be checked with IOF before build.

### Rockhounds and mineral field identification (dichotomous key, not photo-AI)
- **Query:** `mineral identification field` / `rockhounding lapidary gem` (iTunes Search API)
- **Source:** Apple App Store reviews for "Rushmap — Rockhounding Spots" | **URL:** https://apps.apple.com/us/app/rushmap-rockhounding-spots/id6772910515?see-all=reviews | **Date:** reviews through 2026-07 | VERIFIED FETCH
- **Paraphrase:** Reviewers of the leading rockhounding-site app complain about a $10/month subscription with no trial, **server errors at login**, and location records so poor that construction firms are listed as mines — nobody complains about offline because the app is server-bound by design.
- **App-landscape check (VERIFIED, iTunes API):** every top mineral-ID result — Rock Identifier: Stone ID (76,007 ratings), Rock ID, RockIn, Ruby Glint, Rock & Crystal Identifier — is a **photo-AI identifier**, which necessarily round-trips an image to a server. There is no offline determinative key.
- **Points to:** A genuinely offline mineral/rock determination app built as a proper dichotomous key: Mohs hardness by scratch kit, streak colour, lustre, cleavage/fracture, habit, specific gravity by water displacement, acid reaction, magnetism, fluorescence — narrowing a candidate list with photographs and confidence, plus a field log with GPS, a UV/shortwave notes section, and a lapidary side (rough yield, saw/dop/cab sequence, faceting angle refs).
- **Offline necessity:** Rockhounding is a desert/quarry/roadcut/tailings-pile activity; the classic sites (Nevada, Arizona, Utah, Australian goldfields) are hours from coverage. Photo-AI is exactly the wrong architecture there.
- **Audience size:** unknown precisely. The serious, key-using rockhound/lapidary slice (club members: AFMS/regional federations, UK Russell Society) is much smaller than the 76k crystal-app installs; plausibly 20k–60k club-affiliated in the US. No verified figure retrieved — treat as unknown.
- **Data/licence note:** Mineral property data must **not** come from Mindat (proprietary). Usable sources: USGS publications (US-government public domain), the Mineralogical Society of America's freely posted *Handbook of Mineralogy* (check redistribution terms), RRUFF, and Wikipedia mineral infoboxes (CC-BY-SA — attribution and share-alike obligations make it awkward inside a closed app). Safest is to compile the key yourself from multiple public sources.

### Ammunition reloaders at the bench (and competitive shooters at the range)
- **Query:** `ammunition reloading log` (iTunes Search API), then App Store review mining
- **Source:** Apple App Store reviews for the Hodgdon Reloading Manual app | **URL:** https://apps.apple.com/us/app/hodgdon-reloading-manual/id673528110?see-all=reviews | **Date:** review dated 2020-04-02 (plus 2020-12-15, 2024-04-25) | VERIFIED FETCH
- **Paraphrase:** A reviewer reports the manual re-downloads its pages every time it is opened, which is useless in a reloading room with no wifi, and that a paid purchase cannot even be restored while offline; another gets "cannot connect to server" and can never sign in.
- **Points to:** An offline reloading bench logbook and range diary — per-load recipes the user enters themselves, brass/case lifecycle (firings, trim length, annealing, primer-pocket condition), chronograph statistics (ES/SD, ladder and OCW analysis), group measurement from a photographed target with a scale reference, barrel round-count and throat-erosion tracking, and a G1/G7 ballistic solver.
- **Offline necessity:** Reloading benches are in basements, garages and outbuildings; ranges are rural and often inside berms. Moderate-to-strong. Additional privacy angle: many owners are actively unwilling to put a searchable inventory of their firearms, components and quantities on someone else's server — a real "must not leave the device" case.
- **Audience size:** unknown from a retrieved regulator page. Proxy signal only: the Hornady Reloading Guide app has 16,653 App Store ratings and Hodgdon's 805 (verified via iTunes API), implying a US handloading population well into the hundreds of thousands — likely **larger** than the 3k–50k target band, which weakens this as a "small audience" fit.
- **Data/licence note:** **Hard constraint — do not bundle published load data.** Hodgdon/Hornady/Sierra/Lyman load tables are copyrighted and carry real liability if wrong. Ship the app with *no* load data: the user enters their own from their manual. Ballistic drag functions (G1/G7 Siacci/Ingalls tables) originate in US and European government ordnance work and are public domain; ICAO standard atmosphere likewise. Liability posture: keep it a *logbook*, never a load *recommender*.

### Gundog handlers and field-trial competitors
- **Query:** `Kennel Club gundog field trials number of trials held each year entries` (DDG Lite via WebFetch)
- **Source:** The Royal Kennel Club | **URL:** https://www.royalkennelclub.com/activities/heritage-sports/field-trials-and-working-gundogs/new-to-field-trials/ | **Date:** retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The RKC states that over 700 field trials plus many working tests are run every year, mostly in the autumn/winter shooting season, with assessors observing handlers through a day's work and a Working Gundog Certificate listing the tasks achieved.
- **App-landscape check (VERIFIED, iTunes API):** `gundog field trial` returns a magazine app with 0 ratings and a 2016 "Gundog training" app with **2 ratings**. Effectively nothing.
- **Points to:** An offline field-trial and training companion — judge's running-order and scoring sheet (eye-wipes, first-dog-down, marked/blind retrieves, steadiness faults), handler's training diary per dog with drill progressions, a WGC task checklist, retrieve-count and distance log, plus season/game-book totals and a PDF for the club secretary.
- **Offline necessity:** Trials are run walking a line across shot-over farmland, moor and root fields — no signal, driving rain, one hand on a lead and the other on a whistle. A judge cannot wait for a page load between dogs.
- **Audience size:** 700+ RKC trials/year (verified). Individual competitor count not published; UK working-gundog handlers are plausibly 5k–15k, with a comparable US (AKC/HRC/NAVHDA) population. Fits the target band.
- **Data/licence note:** RKC "J Regulations" for field trials are copyrighted — do not bundle the text. The *structure* of a score sheet and the list of standard faults are procedural facts and can be re-expressed. Everything else is user-entered.

---

## WEAK / ALREADY-SERVED (report so we don't re-walk them)

### Canyoneering — largely served, but confirms the offline thesis
- **Query:** `canyoneering` (iTunes API) → App Store reviews
- **Source:** Apple App Store reviews for "Canyoneer" | **URL:** https://apps.apple.com/us/app/canyoneer/id1604449898?see-all=reviews | **Date:** reviews 2022-01 to 2024-10 | VERIFIED FETCH
- **Paraphrase:** Reviewers describe Canyoneer as "offline, easy to use RopeWiki" and prize the offline near-me feature, while complaining that its bundled GPX tracks fall out of sync with RopeWiki updates.
- **Points to:** Offline canyon beta is already solved on iOS by a 16-rating indie app; the residual gap is Android + fresher data, not a new category.
- **Offline necessity:** Genuine — slot canyons have zero signal — but the need is already met.
- **Audience size:** small; Canyoneer has 16 ratings, Road Trip Ryan's guide app 563.
- **Data/licence note:** RopeWiki content licensing would need checking before any redistribution; that is the real blocker here.

### Change ringing (church bell ringers) — method library already offline
- **Query:** `bellringers forum change ringing app android methods offline` (DDG Lite)
- **Source:** Blueline (Android) | **URL:** https://play.google.com/store/apps/details?id=uk.me.rsw.bl | **Date:** retrieved via search 2026-07 | unverified — from search snippet only
- **Paraphrase:** Blueline already ships an **offline** copy of the CCCBR method collections with custom place-notation entry, and iAgrams/Methodology cover diagram viewing.
- **App-landscape check (VERIFIED, iTunes API):** `bell ringing method` on iOS returns Mobel (22 ratings) and a pile of doorbell/sound apps — the iOS side is thin, but the core data problem is solved on Android.
- **Offline necessity:** Real (stone towers are RF-hostile) but the specific need is taken.
- **Audience size:** not established from a retrieved page.
- **Data/licence note:** the CCCBR Methods Library terms would need checking; not pursued further.

### Metal detecting — offline find-logging already exists
- **Query:** `metal detecting app record finds field no phone signal "Portable Antiquities Scheme" record offline` (WebSearch)
- **Source:** LuckyFind: Metal Detecting App | **URL:** https://apps.apple.com/us/app/luckyfind-metal-detecting-app/id1601993650 | **Date:** retrieved via search 2026-07 | unverified — from search snippet only
- **Paraphrase:** LuckyFind already advertises offline-first find logging with GPS coverage mapping that syncs later, which is exactly the gap I was probing.
- **Audience size:** NCMD membership is deliberately unpublished; a critic's blog headline cites ~38,000 (**unverified — from search snippet only**, https://paul-barford.blogspot.com/2025/02/national-council-for-metal-detecting_13.html).
- **Data/licence note:** PAS/British Museum finds data would be the interesting bundle (coin and artefact typologies) and its licence is worth a separate check — but the logging app itself is taken.

### Homebrewing / cider making — the incumbent is already offline-capable
- **Query:** `Brewfather requires internet cloud "offline" complaint brewing basement no signal homebrew app` (WebSearch)
- **Source:** Brewfather documentation | **URL:** https://docs.brewfather.app/ | **Date:** retrieved via search 2026-07 | unverified — from search snippet only
- **Paraphrase:** Brewfather is a PWA that explicitly supports working with no connection and re-syncing afterwards, so the "brewing in a basement with no signal" pain I expected is already handled.
- **Note:** cider-specific tooling is genuinely absent (iTunes `cider making` returns a casino game, a rating app and a music remote — VERIFIED), so molecular-SO2/pH, tannin and blending calculators for small cidermakers remain unbuilt — but the audience is small and the offline case is weak.

### Aircraft de-icing holdover times — already built, repeatedly
- **Query:** `deicing holdover time tables app ramp crew offline FAA HOT tables winter 2025` (WebSearch)
- **Source:** FAA Holdover Time Guidelines Winter 2025-2026 | **URL:** https://www.faa.gov/other_visit/aviation_industry/airline_operators/airline_safety/deicing/FAA_2025-26_Holdover_Tables.pdf | **Date:** issued 2025-08-12 | unverified — from search snippet only
- **Paraphrase:** FAA republishes the HOT tables each August as a free PDF, and at least four App Store products already wrap them (Deicing Holdover id867627045, Holdover Time id1600468704, plus two 0-rating 2025/2026 entrants — VERIFIED via iTunes API).
- **Verdict:** dead as a fresh lead. The *data* is ideal (US federal, annually reissued, public) but the app exists.

### Tour guides working abroad — speculative
- **Query:** `tour guide abroad no roaming data offline notes app guiding groups` (DDG Lite)
- **Source:** GuideZap | **URL:** https://www.guidezap.com | **Date:** retrieved via search 2026-07 | unverified — from search snippet only
- **Paraphrase:** The offline-tour-guide space that exists is aimed at *tourists* avoiding roaming charges, not at the working guide.
- **Points to:** A guide-facing offline kit (commentary script cards, headcount/roll call, per-stop timings, multi-currency tip splits, group manifest, emergency contact sheet). Plausible but I found **no complaint evidence** from guides themselves — treat as speculative until a guide forum (WFTGA, ITMI) is reachable.
- **Offline necessity:** Strong in principle (guides work abroad on foreign SIMs, underground, in museums, at sea) — but unevidenced.
- **Audience size:** unknown.

---

## No evidence found

These queries were run and returned nothing usable; recording them so they are not repeated.

- `rocket launch site "no cell service" bring printed Tripoli prefecture playa` (DDG Lite) — **zero results**, twice. Could not source a first-party club statement that HPR launch sites lack coverage; the claim in the rocketry lead above is inference from site geography and must be marked as such.
- `motorsport marshal forum "no phone signal" rally stage radio log paperwork` (DDG HTML) — CAPTCHA-blocked; no marshal-forum complaint text retrieved. The marshal lead rests on the governing-body volunteer count plus the empty app landscape, not on a quoted marshal.
- `CERT volunteer ICS 214 activity log app offline "no internet" disaster` (DDG HTML) — CAPTCHA-blocked.
- `change ringing bell tower app method library offline "no signal" ringers` (WebSearch) — returned Ringing Room/Mobel but no ringer complaint about connectivity.
- `"technical diving" decompression planner app offline complaint forum` (WebSearch) — many deco planners exist (MultiDeco, V-Planner, Baltic Deco, Divesoft); **no offline complaints found**, and deco planning is auto-rejected on liability anyway.
- `pigeon racing club software velocity calculation loft coordinates offline app` (DDG Lite) — LoftVelo, PigeonRaceAnalyser ("your data stays on your device") and Loftmate already exist; no complaints surfaced. Space is served.
- `ARRL ARES number of registered members 2024 field organization statistics` (DDG Lite) — only overall ARRL membership (137,114 at end of 2024, per ei7gl.blogspot.com, **unverified**). **ARES enrolment count: no evidence found.**
- `Mountain Rescue Association number of teams members volunteers United States` (DDG Lite) — team count found (137, unverified) but **no individual-member total**.
- `National Council for Metal Detecting membership numbers detectorists UK` (DDG Lite) — NCMD does not publish figures; only a critic's blog headline.
- Hacker News Algolia (`"no cell service" offline app`, comments) — returned only consumer satnav/email threads. **No niche-hobby signal.**
- Stack Exchange API (`outdoors` site, 40,731 users) — reachable and confirmed live, but no offline-tooling complaint threads surfaced for these niches.
- F-Droid Discourse search (`offline field app request`) — two irrelevant topics only.
- Bing RSS endpoint — returned SEO-poisoned, off-topic results for every query; unusable. Mojeek returned HTTP 403.
- **Not reached at all this session** (budget exhausted before I got to them): expedition medics (auto-reject on liability anyway), storm spotters and aurora hunters (auto-reject — live data), hot air balloon chase crews, sailplane pilots (XCSoar incumbent), thru-hikers/Camino (FarOut incumbent, licensed content), historical reenactors, Morris dancers, puppeteers/circus, mosque/temple volunteers, van lifers/overlanders (iOverlander incumbent), bikepackers, freedivers (STAmina, 5,439 ratings — served), birders on big years, shipwreck divers, fossil hunters (only photo-AI apps exist — same architectural gap as rockhounds, worth a second pass), aviation ramp agents (iTunes sweep found **zero** ramp-facing tools — worth a second pass).


# ============================================================
# SOURCE FILE: research/raw/data-catalogues.md
# ============================================================

# Phase 1 Discovery — Open Data Catalogues & Licence Audit
**Assignment:** survey open data catalogues for permissively-licensed datasets rich enough to *be* the app idea; verify every licence.
**Date of research:** 2026-07-27

## Method note (read this first)
The shared **WebSearch budget for this session was exhausted (200/200) after 5 searches**, so the bulk of this
audit was done by **retrieving primary sources directly** — WebFetch, `curl` against public APIs, and the
authenticated `gh` CLI against GitHub. That is arguably better evidence than search snippets: almost every
licence below comes from the canonical terms page, the repo's own `LICENSE` file, or a machine-readable
metadata API. Roughly 40 distinct primary-source retrievals were made.
Anything I could not open is explicitly marked **(unverified)**.

---

# 🔴 HARD NOs — licence kills found. Read these before anything else.

### KILL 1 — BirdNET models are NonCommercial. Any offline bird-sound-ID app is dead on arrival.
- **Query:** direct fetch of `raw.githubusercontent.com/birdnet-team/BirdNET-Analyzer/main/README.md`
- **Source:** GitHub raw | **URL:** https://github.com/birdnet-team/BirdNET-Analyzer | **Date:** repo pushed 2026-07-27 | **VERIFIED FETCH**
- **Paraphrase:** The BirdNET *source code* is MIT, but the README's License section states the **models** are licensed **CC BY-NC-SA 4.0**, and the maintainers explicitly frame "educational and research purposes" as the permitted non-commercial use.
- **Points to:** Do NOT build a paid/commercial offline birdsong identifier on BirdNET weights. Exact licence string: `Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)`.
- **Offline necessity:** n/a — this is a kill, not a lead.
- **Audience size:** n/a
- **Data/licence note:** Possible legal substitute: **Google Perch** (`google-research/perch`, **Apache-2.0** on the repo, verified via `gh api`) — but the *deployed model weights* live on Kaggle Models and I could **not** retrieve that page (Kaggle returned no body). Treat Perch's weight licence as **(unverified)** until someone opens the Kaggle model card. YAMNet (521 AudioSet event classes, in `tensorflow/models/research/audioset/yamnet`) is a general audio-event model, not species-level.

### KILL 2 — NIST Standard Reference Data (incl. the NIST Chemistry WebBook) is copyrighted and may NOT be redistributed.
- **Query:** direct fetch of the NIST SRD public-law page
- **Source:** NIST | **URL:** https://www.nist.gov/srd/public-law | **Date:** page cites Public Law 114-329 (2017-01-06) | **VERIFIED FETCH**
- **Paraphrase:** Under the Standard Reference Data Act, NIST secures **copyright on behalf of the United States** for SRD, and the page states SRD may not be reproduced, stored in a retrieval system, or transmitted in any form without prior permission.
- **Points to:** Any "offline thermophysical properties / steam tables / refrigerant properties" app that bundles WebBook data is a licence violation. The WebBook FAQ itself (https://webbook.nist.gov/chemistry/faq/, VERIFIED FETCH) is silent on terms, which is not consent.
- **Offline necessity:** n/a
- **Audience size:** n/a
- **Data/licence note:** **The legal replacement is CoolProp** — `CoolProp/CoolProp`, **MIT licence**, ~69 MB repo, verified via `gh api` 2026-07-27. CoolProp gives you 120+ pure fluids and humid-air properties with no redistribution restriction. **REFPROP is a paid NIST product — flag as paid.** **ASHRAE Handbook/Standards are paid — flag as paid.**

### KILL 3 — SNOMED CT needs a paid Affiliate licence outside Member countries, and app/browser deployment needs special permission.
- **Query:** direct fetch of SNOMED International's licensing page
- **Source:** SNOMED International | **URL:** https://www.snomed.org/get-snomed | **Date:** retrieved 2026-07-27 | **VERIFIED FETCH**
- **Paraphrase:** Use is free inside Member countries, but non-Member territory deployment needs an annual MLDS licence with charges based on use and territory, and the page says other deployment modes such as web applications and browsers "require special permission and fees."
- **Points to:** A worldwide-distributed offline clinical terminology app cannot bundle SNOMED CT. Kill it now.
- **Audience size:** n/a
- **Data/licence note:** Exact position: Affiliate Licence Agreement required; fee-exempt categories exist but are not automatic.

### KILL 4 — ICD-11 is CC BY-ND. You may embed it, but you may NOT modify it or build mappings.
- **Query:** direct fetch of the WHO ICD-11 licence PDF
- **Source:** WHO | **URL:** https://icd.who.int/en/docs/icd11-license.pdf | **Date:** retrieved 2026-07-27 | **VERIFIED FETCH (PDF)**
- **Paraphrase:** ICD-11 is under `Creative Commons Attribution-NoDerivs 3.0 IGO (CC BY-ND 3.0 IGO)`; embedding the unchanged code/title/URI in commercial software is allowed, but adapting the classification, producing a competing classification, or publishing mappings/crosswalks requires a separate written WHO agreement.
- **Points to:** An offline ICD-11 *browser* is legal. An offline ICD-10↔ICD-11 *crosswalk* or a "simplified" coding helper is not, without WHO paperwork.
- **Offline necessity:** Hospital clinical-coding staff often work on locked-down networks or in basement records departments; but honestly most coders have intranet access — offline is a convenience, not a necessity. **Weak on the offline test.**
- **Audience size:** unknown
- **Data/licence note:** Attribution string required; ND clause is the trap.

### KILL 5 — half the small Vosk speech models are NC / AGPL / GPL. Check per-language before you ship.
- **Query:** parsed the licence column out of the Vosk model table
- **Source:** Alpha Cephei | **URL:** https://alphacephei.com/vosk/models | **Date:** retrieved 2026-07-27 | **VERIFIED FETCH (table parsed)**
- **Paraphrase:** Most small models (~30–53 MB) are Apache 2.0, but `vosk-model-small-fr-pguyot-0.3`, `vosk-model-nl-spraakherkenning-0.6(+lgraph)` and `vosk-model-tl-ph-generic-0.6` are **CC-BY-NC-SA**, the `daanzu` and `linto` (fr/ar) models are **AGPL**, the `zamia` models are **LGPL-3.0**, and `vosk-model-pt-fb` is **GPLv3**.
- **Points to:** Offline voice-command / dictation features are viable, but only on the Apache-2.0 subset (en-us, en-in, cn, ru, es, it, de, tr, vi, uk, fa, ar, ca, el, pt-small, nl-small, fr-small).
- **Data/licence note:** Apache-2.0 small models verified per row: `vosk-model-small-en-us-0.15` 40M, `vosk-model-small-ru-0.22` 45M, `vosk-model-small-es-0.42` 39M, `vosk-model-small-it-0.22` 48M, `vosk-model-small-fa-0.42` 53M, `vosk-model-small-uk-v3-nano` 73M, etc.

### KILL 6 (soft) — GBIF and iNaturalist are a mixed bag; CC BY-NC datasets are unusable commercially.
- **Query:** direct fetch of the GBIF course material on data principles
- **Source:** GBIF docs | **URL:** https://docs.gbif.org/course-introduction-to-gbif/en/principles-of-gbif-mediated-data.html | **Date:** retrieved 2026-07-27 | **VERIFIED FETCH**
- **Paraphrase:** GBIF publishers must pick one of exactly three licences — **CC0**, **CC BY**, or **CC BY-NC** — and GBIF itself acknowledges CC-BY-NC "has a significant effect on the reusability of data"; separately, **images inside a dataset are not covered by the dataset licence** and may be more restrictive.
- **Points to:** You *can* build a commercial offline species-occurrence app, but you must filter the download to CC0+CC BY records only, and you cannot use the photos.
- **Data/licence note:** `www.gbif.org/terms` and `/terms/data-user` are behind Cloudflare and returned a JS challenge to both WebFetch and curl — **(the exact terms text is unverified; the licence triplet above is verified from docs.gbif.org)**. The iNaturalist help page returned 403 — iNat's per-observation licence split (CC0 / CC BY / CC BY-NC, with CC BY-NC historically the default for photos) is **(unverified this session)**.

---

# 🟢 Datasets that are CLEAN for a commercial offline bundle

### Global tide prediction from harmonic constants — the standout find
- **Query:** direct fetch of PANGAEA DOI metadata for the TICON tidal-constants dataset
- **Source:** PANGAEA | **URL:** https://doi.pangaea.de/10.1594/PANGAEA.951610 | **Date:** published 2022-12-08, retrieved 2026-07-27 | **VERIFIED FETCH (schema.org JSON-LD)**
- **Paraphrase:** TICON-3 (Hart-Davis, Dettmering & Seitz) publishes **40 tidal constituents for 3,471 tide gauges worldwide** as a single 2.7 MB text file, and the metadata block gives `license: https://creativecommons.org/licenses/by/4.0/` with `conditionsOfAccess: unrestricted`.
- **Points to:** A fully offline global tide-and-tidal-stream predictor that *computes* highs/lows from bundled harmonic constants rather than fetching a timetable. Pair it with a species/activity layer: bait-digging and hand-gathering windows, shore-angling marks, sea-kayak tidal-gate planning, foreshore archaeology / mudlarking access windows, intertidal ecology survey timing.
- **Offline necessity:** Very strong. The user is standing on a beach, a mudflat, a rock ledge or in a kayak at 05:00 with no signal, wet hands, and a hard deadline set by the water. A spinner or a login is unusable. Tide prediction is *astronomy arithmetic*, not a live feed — it does not trip the "needs live data" auto-reject.
- **Audience size:** unknown from this source. The dataset itself gives 3,471 gauges; community sizing must come from another workstream.
- **Data/licence note:** Bundle `TICON_3.txt` (2.7 MB, 14 columns incl. lat/lon, constituent name, amplitude cm, Greenwich phase lag, stddevs, gauge type coastal/river/lake). Licence: **CC BY 4.0** — attribution only, commercial redistribution fine. ⚠️ Add a "not for navigation" disclaimer; harmonic-only predictions exclude surge/meteorological effects.

### NOAA CO-OPS harmonic constituents — US coverage, public domain, machine-readable
- **Query:** direct API call to the CO-OPS MDAPI harcon endpoint and station index
- **Source:** NOAA Tides & Currents API | **URL:** https://api.tidesandcurrents.noaa.gov/mdapi/prod/webapi/stations.json?type=harcon and .../stations/8443970/harcon.json | **Date:** retrieved 2026-07-27 | **VERIFIED FETCH (live API)**
- **Paraphrase:** NOAA exposes **1,360 US stations with published harmonic constants**, each returning constituent name, amplitude, GMT and local phase, speed in deg/hr, and the analysis epoch — as plain JSON with no key and no terms gate.
- **Points to:** The US half of the offline tide app above; also currents, and datum conversion.
- **Offline necessity:** Same as above — this is a one-time bundle, not a runtime call.
- **Audience size:** 1,360 harcon stations (verified from the API's own count field).
- **Data/licence note:** US Government work → public domain in the US. The station index and harcon JSON are small enough to ship whole (tens of KB per station × 1,360 ≈ a few MB compressed). The human-facing page https://tidesandcurrents.noaa.gov/harcon.html states no licence (VERIFIED FETCH, silent).

### OurAirports — public domain aviation reference, whole planet in ~24 MB
- **Query:** direct fetch of the OurAirports data page
- **Source:** OurAirports | **URL:** https://ourairports.com/data/ | **Date:** files last modified 2026-07-26, retrieved 2026-07-27 | **VERIFIED FETCH**
- **Paraphrase:** The page states plainly that all data is released to the **Public Domain** with no guarantee of accuracy; current file sizes are airports.csv 12.7 MB, airport-comments.csv 4.7 MB, runways.csv 4.0 MB, navaids.csv 1.5 MB, airport-frequencies.csv 1.3 MB.
- **Points to:** An offline strip/aerodrome reference — runway surface, length, lighting, frequencies, navaids, elevation, comments — for bush and backcountry GA pilots, glider pilots, microlight/ultralight pilots and ferry pilots. Not charts, not weather, not NOTAMs (all of which would trip the auto-reject) — just the immutable facts about the field you are diverting to.
- **Offline necessity:** Strong. In the air with no cell service, or on a strip in the middle of nowhere. Also: ForeFlight-class subscriptions are expensive and heavy for the low end of GA.
- **Audience size:** unknown (community must be sized separately). File-level facts verified.
- **Data/licence note:** Public Domain, explicitly stated. Zero licence risk. ⚠️ This is adjacent to "safety-critical navigation" — position it as a reference/lookup, not as a nav aid.

### Catalogue of Life — 5.4 million taxa, CC BY, machine-verified
- **Query:** direct API call `api.checklistbank.org/dataset/315777`
- **Source:** ChecklistBank / Catalogue of Life API | **URL:** https://www.checklistbank.org/dataset/315777 | **Date:** release COL26.7, issued 2026-07-14 | **VERIFIED FETCH (JSON API)**
- **Paraphrase:** The July 2026 COL release reports `"license": "cc by"` with `"size": 5413595` taxa and DOI 10.48580/dgyhw, assembled from 93+ updated expert checklists.
- **Points to:** The taxonomic spine for any offline field-recording app — a naming authority you can ship. Synonymy resolution offline is genuinely hard and genuinely valuable.
- **Offline necessity:** Depends on the app built on top; the backbone itself is a bundle, so it never needs network.
- **Audience size:** n/a (infrastructure)
- **Data/licence note:** **CC BY** — attribution only, commercial bundling fine. Darwin Core Archive; the full 5.4M-name dump is large, so ship a clade subset. ITIS (https://www.itis.gov/, VERIFIED FETCH 2026-07-27) is the US alternative at **993,167 scientific names and 166,746 common names** as of 2026-06-26 — but ITIS's own `data_policy.html` returned **404**, so its licence statement is **(unverified)**; as a US federal product it is presumptively public domain.

### GeoNames — 25 M place names, CC BY 4.0
- **Query:** direct fetch of the GeoNames about page
- **Source:** GeoNames | **URL:** https://www.geonames.org/about.html | **Date:** retrieved 2026-07-27 | **VERIFIED FETCH**
- **Paraphrase:** GeoNames states it is free under a **Creative Commons Attribution 4.0 License** and contains over 25 million names across 12 million unique features, of which 4.8 million are populated places and 16 million are alternate names.
- **Points to:** Offline "where am I / what is that hill called" gazetteer; also offline place-name search for any field app without shipping OSM.
- **Offline necessity:** Strong wherever the user is deep rural or abroad without roaming.
- **Audience size:** n/a (infrastructure)
- **Data/licence note:** **CC BY 4.0** — attribution only. The daily dump size was not stated on the page (allCountries is order-of 400 MB uncompressed in practice) — ship a country subset.

### Natural Earth — genuinely public domain basemap, no attribution required
- **Query:** direct fetch of the Natural Earth terms page
- **Source:** Natural Earth | **URL:** https://www.naturalearthdata.com/about/terms-of-use/ | **Date:** retrieved 2026-07-27 | **VERIFIED FETCH**
- **Paraphrase:** All raster and vector Natural Earth data is in the **public domain**, attribution is explicitly **not required** (only suggested), at 1:10m, 1:50m and 1:110m scales.
- **Points to:** The zero-risk basemap for any offline map view where OSM's ODbL is unwelcome — coastlines, borders, rivers, bathymetry, populated places, at world/regional zoom.
- **Offline necessity:** The whole point of shipping a basemap is that the map works with the radio off.
- **Audience size:** n/a (infrastructure)
- **Data/licence note:** **Public domain**, no conditions. This is the cleanest geo licence in the entire audit.

### OpenStreetMap ODbL — usable, but understand exactly what you are agreeing to
- **Query:** direct fetch of the OSMF Produced Work community guideline
- **Source:** OpenStreetMap Foundation wiki | **URL:** https://osmfoundation.org/wiki/Licence/Community_Guidelines/Produced_Work_-_Guideline | **Date:** retrieved 2026-07-27 | **VERIFIED FETCH**
- **Paraphrase:** The test is intent — if the published output is meant to let someone extract the original data it is a Database; otherwise it is a **Produced Work**, and rendered raster tiles are usually Produced Works; but the guideline still says that if you publish a Produced Work the **underlying database has to be published as well** under ODbL §4.6.
- **Points to:** Practical rule for a Flutter app: shipping *rendered* tiles = Produced Work → attribute "© OpenStreetMap contributors" visibly and you're fine. Shipping a *queryable* extract (routing graph, POI database, geocoder index) = a Derivative Database → you must offer that database under ODbL. Your app *code* stays proprietary either way; the database does not.
- **Offline necessity:** n/a (infrastructure)
- **Audience size:** n/a
- **Data/licence note:** **ODbL 1.0**. The share-alike bites the *data*, never the app binary. If you don't want that obligation at all, use Natural Earth + GeoNames instead.

### Copernicus DEM GLO-30 / GLO-90 — free worldwide elevation, commercial redistribution allowed
- **Query:** direct fetch of the Copernicus Data Space COP-DEM collection description
- **Source:** Copernicus Data Space Ecosystem | **URL:** https://dataspace.copernicus.eu/explore-data/data-collections/copernicus-contributing-missions/collections-description/COP-DEM | **Date:** retrieved 2026-07-27 | **VERIFIED FETCH**
- **Paraphrase:** GLO-30 (1 arc-second) and GLO-90 (3 arc-second) cover ~149 million km² worldwide under a free licence permitting redistribution, provided you carry the exact string "© DLR e.V. 2010-2014 and © Airbus Defence and Space GmbH 2014-2018 provided under COPERNICUS by the European Union and ESA; all rights reserved", with a different string for adapted products.
- **Points to:** Offline terrain profiles, horizon/skyline computation, viewshed, slope/aspect — for anything from stargazing site selection to radio-path planning to hill-walking route feasibility.
- **Offline necessity:** Strong — the user is on the hill, not at a desk.
- **Audience size:** n/a (infrastructure)
- **Data/licence note:** GeoTIFF/DTED, 1°×1° tiles, ~5–15 MB per GLO-30 tile and ~1–5 MB per GLO-90 tile. **The attribution string is mandatory and must be reproduced literally.**

### JPL DE440 / DE442 planetary ephemerides — 31 MB gets you 300 years of the solar system
- **Query:** direct listing of the JPL SSD ephemeris FTP browser
- **Source:** JPL Solar System Dynamics | **URL:** https://ssd.jpl.nasa.gov/ftp/eph/planets/bsp/ | **Date:** listing retrieved 2026-07-27; de442 dated 2026-07-15 | **VERIFIED FETCH (directory listing)**
- **Paraphrase:** `de440s.bsp` is **31.2 MB** (the short, 1849–2150 span), `de440.bsp` is 114.3 MB, `de441.bsp` is 3.08 GB, and a newer **de442.bsp (114.2 MB) was posted 2026-07-15**; the coverage page states DE440 spans 1549-12-31 to 2650-01-25.
- **Points to:** Any offline astronomical-computation app that needs sub-arcsecond planetary/lunar positions without VSOP87's truncation error — eclipse circumstances, occultation timing, lunar libration/terminator, Jovian satellite events.
- **Offline necessity:** Very strong — observers are at dark-sky sites, which by definition are far from towers.
- **Audience size:** n/a (infrastructure)
- **Data/licence note:** No licence or restriction statement appears on the JPL ephemeris export page (VERIFIED FETCH — it is silent). NASA-produced works are US Government works and are presumptively public domain, but **the absence of an explicit grant is worth one email to JPL before shipping**.

### VSOP87 and the IAU constellation boundaries — tiny, ancient, and freely served by CDS
- **Query:** direct fetch of VizieR catalogue records VI/81 and VI/49 plus the VI/49 FTP listing
- **Source:** CDS / VizieR | **URLs:** https://cdsarc.cds.unistra.fr/viz-bin/cat/VI/81 and https://cdsarc.cds.unistra.fr/ftp/VI/49/ | **Date:** VI/49 files last touched 2024-07-23; retrieved 2026-07-27 | **VERIFIED FETCH**
- **Paraphrase:** VSOP87 (Bretagnon & Francou 1988) is 48 data files covering six coordinate variants for all planets; the Delporte/IAU constellation boundaries (Davenhall & Leggett 1989, VI/49) are just `bound_18.dat` 40 KB, `bound_20.dat.gz` 119 KB and `constbnd.dat` 45 KB.
- **Points to:** Everything an offline planetarium/observing-planner needs for planet positions and "which constellation is this in", in under 200 KB plus series coefficients.
- **Offline necessity:** Strong (dark sites have no signal).
- **Audience size:** n/a (infrastructure)
- **Data/licence note:** ⚠️ **The VizieR JSON metadata for VI/81, VI/49 and V/50 has an empty `license` field** (I grepped it — no value returned). CDS asks for an acknowledgement of the VizieR service (DOI 10.26093/cds/vizier). These are 1980s scientific tables published in A&A; practically everyone ships them, but **the licence is formally unstated — treat as grey, cite generously**. Yale Bright Star Catalogue (V/50) records: **9,110 stars** (verified from VizieR metadata).

### OpenNGC and HYG — deep-sky and star catalogues, but both are ShareAlike
- **Query:** `gh api` on both repos + direct fetch of their LICENSE files and README
- **Source:** GitHub | **URLs:** https://github.com/mattiaverga/OpenNGC and https://github.com/astronexus/HYG-Database | **Date:** OpenNGC pushed 2026-07-26; HYG pushed 2025-02-14 | **VERIFIED FETCH**
- **Paraphrase:** OpenNGC's README says it exists specifically because other NGC/IC databases have licence limits, and it ships `LICENSES/CC-BY-SA-4.0.txt` plus `LICENSES/MIT.txt`; HYG's `LICENSE` file is a plain **CC BY-SA 4.0** statement.
- **Points to:** An offline deep-sky observing-programme tracker (Messier / Herschel 400 / Caldwell / RASC lists) with red-light UI and a logbook.
- **Offline necessity:** Strong — dark-sky sites, gloves, red light, no signal, and you must not blow your dark adaptation waiting for a spinner.
- **Audience size:** unknown from these sources.
- **Data/licence note:** ⚠️ **ShareAlike trap, but a survivable one.** CC BY-SA 4.0 obliges you to license *adapted material* under CC BY-SA. Converting the CSV into a bundled SQLite file is plausibly an adaptation → publish that SQLite under CC BY-SA. It does **not** infect your Flutter source. Budget for shipping the converted DB as a downloadable artefact alongside the app.

### Wikidata — CC0, the only big knowledge graph with no strings
- **Query:** direct fetch of Wikidata's licensing policy page
- **Source:** Wikidata | **URL:** https://www.wikidata.org/wiki/Wikidata:Licensing | **Date:** retrieved 2026-07-27 | **VERIFIED FETCH**
- **Paraphrase:** All structured data in the main, property and lexeme namespaces is under the **Creative Commons CC0 License**, so no attribution is legally required for any reuse including commercial; only free-text in other namespaces falls under CC BY-SA 4.0.
- **Points to:** Bundling curated fact-sets (identifiers, taxonomies, cross-references, lexemes for language apps) with zero licence overhead.
- **Offline necessity:** depends on the app
- **Audience size:** n/a (infrastructure)
- **Data/licence note:** **CC0 1.0.** ⚠️ Contrast with **Wikipedia/Wiktionary article text: CC BY-SA 4.0** — bundling Wiktionary definitions means the bundled text corpus (and any adaptation of it) must be offered under CC BY-SA with attribution to contributors. Again the app *code* is unaffected, but a "we scraped Wiktionary" dictionary is not a proprietary asset.

### Tatoeba — CC BY sentences, but read the audio footnote
- **Query:** direct fetch of the Tatoeba downloads page
- **Source:** Tatoeba | **URL:** https://tatoeba.org/en/downloads | **Date:** retrieved 2026-07-27 | **VERIFIED FETCH**
- **Paraphrase:** Sentences are under **CC BY 2.0 FR** with a subset under **CC0 1.0**; the licence on each audio file is chosen by its contributor and **audio with no licence specified cannot be reused outside Tatoeba**.
- **Points to:** Offline sentence-mining / minimal-pair / listening-drill apps for less-common language pairs.
- **Offline necessity:** Moderate-to-strong for the "abroad without roaming / commuting underground / data-cost-sensitive market" cases.
- **Audience size:** n/a
- **Data/licence note:** Filter the audio dump by the licence column before bundling — this is a real trap for anyone who just grabs the tarball.

### Project Gutenberg — the texts are free; only the trademark costs money
- **Query:** direct fetch of the Project Gutenberg permission policy
- **Source:** Project Gutenberg | **URL:** https://www.gutenberg.org/policy/permission.html | **Date:** retrieved 2026-07-27 | **VERIFIED FETCH**
- **Paraphrase:** Most PG ebooks are US public domain so nobody can grant or withhold permission, but "Project Gutenberg" is a registered trademark and *commercial* use trading on that name triggers royalties.
- **Points to:** Strip the PG boilerplate/trademark, keep the public-domain text, ship offline. This is the standard route for bundling pre-1930 handbooks and manuals.
- **Offline necessity:** depends on the app
- **Audience size:** n/a
- **Data/licence note:** Same logic extends to pre-1930 engineering/trade handbooks scanned at Internet Archive / HathiTrust — the *text* is PD; some scan providers assert terms on the *scan*. (HathiTrust and Internet Archive terms **not fetched this session — unverified**.)

### Language & speech assets that are clean
- **Query:** `gh api` + raw LICENSE fetches across cmudict / Open English WordNet / FrequencyWords / UD / Common Voice
- **Source:** GitHub | **Date:** retrieved 2026-07-27 | **VERIFIED FETCH**
- **Paraphrase / per-item:**
  - **CMU Pronouncing Dictionary** (`cmusphinx/cmudict`): the LICENSE file is a 2-clause BSD-style CMU grant permitting redistribution in source and binary form — **clean for commercial bundling**. ~4 MB repo.
  - **Open English WordNet** (`globalwordnet/english-wordnet`): LICENSE.md says derived from Princeton WordNet under the WordNet License and further developed under **CC BY 4.0**, attribution to both required. ~538 MB repo (the release files are far smaller). **Clean.**
  - **FrequencyWords** (`hermitdave/FrequencyWords`): repo LICENSE is **MIT**, ~560 MB — ⚠️ but the word lists are derived from OpenSubtitles, whose upstream licence is murky. Flag before shipping.
  - **Universal Dependencies** `UD_English-EWT`: **CC-BY-SA-4.0** per GitHub metadata. ⚠️ UD treebanks are licensed *individually* and some are **NC** — check each language separately.
  - **Common Voice** (`common-voice/cv-dataset`): the 2026-06 release reports **294 languages / 28,893 validated hours** of scripted speech and 78 languages / 273 hours of spontaneous speech (VERIFIED from the repo README). The repo itself is MPL-2.0; the **dataset** is customarily CC0 but the dataset licence statement now lives on Mozilla Data Collective and I could **not** open it — **(licence unverified this session; the counts are verified)**.
  - **LibriVox** (public-domain audiobooks) — **not fetched this session, unverified.**

### On-device ML with clean licences (all verified via `gh api`, 2026-07-27)
| Model / toolkit | Repo | Licence | Notes |
|---|---|---|---|
| Whisper | `openai/whisper` | **MIT** | 105 k stars; tiny/base variants are the mobile-viable ones |
| whisper.cpp | `ggml-org/whisper.cpp` | **MIT** | 52 k stars; the practical route to Whisper on a phone |
| faster-whisper | `SYSTRAN/faster-whisper` | **MIT** | 24 k stars |
| Vosk API | `alphacep/vosk-api` | **Apache-2.0** | 15 k stars; models licensed separately — see KILL 5 |
| sherpa-onnx | `k2-fsa/sherpa-onnx` | Apache-2.0 *(licence field truncated in my fetch — treat as **near-verified**)* | ASR + TTS + VAD + diarization, explicitly "without Internet connection", Android/iOS |
| Silero VAD | `snakers4/silero-vad` | **MIT** | 9.7 k stars, ~122 MB repo |
| MediaPipe | `google-ai-edge/mediapipe` | **Apache-2.0** | 36 k stars; hand/pose/face/segmentation on-device |
| Tesseract language data | `tesseract-ocr/tessdata_fast` | **Apache-2.0** | 344 MB for 100+ languages → ~1–5 MB each |
| RapidOCR | `RapidAI/RapidOCR` | **Apache-2.0** | ONNX-Runtime OCR, 7 k stars |
| PaddleOCR | `PaddlePaddle/PaddleOCR` | **Apache-2.0** | 86 k stars, 100+ languages |
| Perch (bird audio) | `google-research/perch` | **Apache-2.0** (repo) | ⚠️ deployed weights on Kaggle — **unverified** |
| PlantNet-300K | `plantnet/PlantNet-300K` | **BSD-2-Clause** | a *training dataset*, not a shipped classifier; PlantNet's production model is not openly released |

### Food & nutrition
- **USDA FoodData Central** — https://fdc.nal.usda.gov/ | **VERIFIED FETCH of the FAQ**, which confirms CSV and JSON downloads but is **silent on licence**. A search result (Ag Data Commons listing, https://data.nal.usda.gov/dataset/fooddata-central-0) states the data is public domain and published under **CC0 1.0 Universal** with a request (not a requirement) to cite FDC — but the Ag Data Commons page redirects to `agdatacommons.nal.usda.gov` which returned **403**, so the exact CC0 string is **(unverified — from search snippet only)**. Treat FDC as almost certainly clean (US Government work) but confirm before launch.
- **Open Food Facts** — https://world.openfoodfacts.org/terms-of-use and /data | **VERIFIED FETCH of both.** Database under **ODbL 1.0**, individual contents under **DbCL 1.0**, product images under **CC BY-SA**. Commercial use explicitly permitted with attribution + share-alike. Dump sizes verified from the data page: CSV export **~0.9 GB gzipped / ~9 GB uncompressed**, plus MongoDB dump, JSONL, RDF and a Parquet mirror on Hugging Face. ⚠️ Too big to ship whole — a single-country, few-column subset is the only viable bundle, and that subset is a Derivative Database that must itself be offered under ODbL.
- **FAO/INFOODS** — https://www.fao.org/infoods/infoods/tables-and-databases/en/ | **VERIFIED FETCH**, but the page is a *directory of third-party tables*, states most tables are not held by the Secretariat and many are out of print, and gives **no licence information at all**. Weak lead; each regional table would need chasing individually.

### Health (beyond the kills)
- **NLM download terms** — https://www.nlm.nih.gov/databases/download/terms_and_conditions.html | **VERIFIED FETCH.** No licence agreement needed for FTP downloads; you must credit "Courtesy of the U.S. National Library of Medicine", must not imply endorsement, and must either stay current or conspicuously disclose that your copy is not the latest. **This covers MeSH cleanly.**
- **RxNorm** — https://www.nlm.nih.gov/research/umls/rxnorm/docs/termsofservice.html | **VERIFIED FETCH.** A **free UMLS licence (UTS account) is required to download**; commercial embedding is permitted with the prescribed attribution sentence; ⚠️ **proprietary source vocabularies inside RxNorm carry extra restrictions under §12 of the UMLS agreement** — so "RxNorm" is not uniformly free, and the full UMLS Metathesaurus definitely is not.
- **MedlinePlus** — https://medlineplus.gov/about/developers/webservices/ | **VERIFIED FETCH.** A full health-topic **XML bulk download exists**, attribution required, no logo use. ⚠️ The page does **not** state a licence or public-domain dedication — **(the PD status is unverified)**.
- **WHO Essential Medicines List (eEML)** — https://list.essentialmeds.org/ | **VERIFIED FETCH.** Contains **1,418 recommendations covering 667 medicines and 156 therapeutic equivalents**, exportable as PDF/XLSX/DOCX. ⚠️ **No licence statement visible on the page — unverified.** Also note: any app that presents medicine information edges toward the medical-liability auto-reject; a *formulary availability reference* is safer than anything dose-shaped, but this is a caution flag.

### Chemistry / physics constants
- **CODATA 2022 fundamental constants** — https://physics.nist.gov/cuu/Constants/Table/allascii.txt | **VERIFIED FETCH** (366 lines, plain ASCII, header reads "Fundamental Physical Constants — Complete Listing, 2022 CODATA adjustment"). Tiny, trivially bundleable. ⚠️ Sits on a NIST server and therefore in the shadow of the SRD copyright issue in KILL 2, though the constants themselves are internationally-agreed *facts* rather than a compiled SRD product.
- **PubChem / NCBI** — https://www.ncbi.nlm.nih.gov/home/about/policies/ | **VERIFIED FETCH.** NCBI-created content is public domain and NCBI places no restrictions on distribution of its molecular database contents, **but** it explicitly cannot warrant depositor-contributed material and tells redistributors to honour the original submitter's terms. Usable with care; not a blanket grant.

### Grey / unresolved
- **Munsell soil colour** — https://munsell.com/color-blog/ now **301-redirects to https://www.pantone.com/** (VERIFIED FETCH of the redirect), i.e. Munsell is a Pantone/X-Rite commercial product and the physical Soil Color Charts are copyrighted. The **Munsell Renotation Data** is offered free by the RIT Munsell Color Science Laboratory (https://www.rit.edu/science/munsell-color-science-lab-educational-resources, VERIFIED FETCH) as six-column hue/value/chroma → CIE x,y,Y files under illuminant C and the 1931 2° observer, distributed "as is" with **no stated licence**. ⚠️ Facts are not copyrightable and the 1943 renotation is old science, but the **Munsell name is a trademark** — do not brand an app "Munsell".
- **Xeno-canto** — https://xeno-canto.org/about/terms returned an **Anubis "Access Denied"** wall to WebFetch. Its recordings are known to sit under an assortment of Creative Commons licences, many of them **NC** — **(unverified; assume mixed and filter by licence field before any commercial use)**.
- **World Flora Online** — https://www.worldfloraonline.org/downloadData failed with a **TLS certificate error** in this environment. **(unverified)**
- **USDA PLANTS** — https://plants.sc.egov.usda.gov/home returned a JS-only shell with no readable content. **(unverified)**
- **GNIS download page** — https://www.usgs.gov/us-board-on-geographic-names/download-gnis-data returned **CloudFront 403**. **(unverified)** — presumptively US Government public domain.
- **NGA Pub 229 / Pub 249 sight-reduction tables** — `msc.nga.mil` failed DNS resolution and `msi.nga.mil` returned "Request Rejected" (403). **(unverified)** — presumptively US Government public domain, but note the assignment's existing dead-end list already covers celestial navigation.
- **OPUS parallel corpora** — https://opus.nlpl.eu/ | **VERIFIED FETCH** of the headline numbers (**1,214 corpora, ~102.9 billion sentence pairs, 1,038 languages**), but the front page carries **no licensing statement whatsoever**; each corpus (OpenSubtitles, ParaCrawl, CCMatrix, NLLB, Europarl, Tatoeba) has its own terms and several are not safely redistributable. ⚠️ Never treat "it's on OPUS" as "it's open".
- **US Army publications (FM/TM/ATP/TC)** — https://armypubs.army.mil/ | **VERIFIED FETCH** of the publication-type list, but the site states **nothing about copyright or Distribution Statement A vs restricted** on its landing page. **(the public-domain assumption is unverified)** — individual PDFs carry their own distribution statement and that must be checked per document.
- **Copernicus `spacedata.copernicus.eu`** — connection refused (ECONNREFUSED). The Data Space Ecosystem mirror was used instead and is cited above.

---

## App concepts the data itself argues for (ranked by how much the *dataset* does the work)

1. **Offline global tide & tidal-window planner** — TICON-3 (CC BY 4.0, 2.7 MB, 3,471 gauges) + NOAA harcon (PD, 1,360 US stations). Audience: bait-diggers, hand-gatherers, shore anglers, sea kayakers, foreshore/mudlarking permit-holders, intertidal surveyors. Offline is the point: mudflat at dawn, no signal, wet hands, a hard water deadline. Two months of work is exactly right — harmonic synthesis, nodal corrections, 40 constituents, a station index, a map, and a window-planner UI.
2. **Offline deep-sky observing-programme tracker** — OpenNGC (CC-BY-SA) + HYG (CC-BY-SA) + VSOP87/VI-49 (grey but tiny) + DE440s (31 MB). Red-light UI, gloves, no signal at a dark site. Watch the ShareAlike obligation on the bundled DB.
3. **Offline aerodrome/strip facts reference** — OurAirports (Public Domain, ~24 MB total). Runways, surfaces, lighting, frequencies, navaids, elevations, user comments. No weather, no NOTAMs, no charts — deliberately staying out of the live-data and safety-critical zones.
4. **Offline terrain-horizon / skyline tool** — Copernicus GLO-90 (1–5 MB per tile, commercial redistribution allowed with the mandatory attribution string). Viewshed, sun/moon rise-behind-ridge, radio path.
5. **Offline OCR + phrase reference for locked-down or no-roaming contexts** — tessdata_fast (Apache-2.0, ~1–5 MB/language) + Tatoeba CC BY sentences + Apache-2.0 Vosk small models. All three licences verified clean.

---

## No evidence found / could not verify
Queries and fetches that returned nothing usable:

- `https://www.gbif.org/terms` and `/terms/data-user` — Cloudflare JS challenge to both WebFetch and curl. **No evidence retrieved** for GBIF's terms text (the licence triplet came from docs.gbif.org instead).
- `https://www.inaturalist.org/pages/help#cc` — HTTP 403. **No evidence found** for the current iNaturalist CC0/CC-BY/CC-BY-NC split.
- `https://xeno-canto.org/about/terms` — Anubis anti-bot wall. **No evidence found.**
- `https://www.worldfloraonline.org/termsofuse` and `/downloadData` — TLS certificate verification failure. **No evidence found.**
- `https://plants.sc.egov.usda.gov/home` — JS-only shell, no body text. **No evidence found** for USDA PLANTS licence or record count.
- `https://www.itis.gov/data_policy.html` — HTTP 404. **No evidence found** for an explicit ITIS licence.
- `https://www.usgs.gov/us-board-on-geographic-names/download-gnis-data` — CloudFront 403. **No evidence found** for GNIS file sizes/terms.
- `https://msc.nga.mil/Publications/Sight-Reduction-Tables` — DNS failure; `https://msi.nga.mil/Publications` — 403 "Request Rejected". **No evidence found** for Pub 229/249 availability.
- `https://www.kaggle.com/models/google/bird-vocalization-classifier` — page returned link text only, no model card. **No evidence found** for the Perch weight licence.
- `https://commonvoice.mozilla.org/en/datasets` — page returned title only. **No evidence found** for the Common Voice dataset licence string (counts came from the cv-dataset repo instead).
- `https://agdatacommons.nal.usda.gov/articles/FoodData_Central/24668133` — HTTP 403. **No evidence found**; the CC0 claim for FoodData Central rests on a search snippet only.
- `https://pubchem.ncbi.nlm.nih.gov/docs/downloads` — page returned title only. **No evidence found** for PubChem bulk-file sizes.
- `https://spacedata.copernicus.eu/collections/copernicus-digital-elevation-model` — ECONNREFUSED.
- `https://cds.unistra.fr/legal.html` — HTTP 404; VizieR's `license` metadata field is **empty** for V/50, VI/49 and VI/81. **No evidence found** for an explicit CDS catalogue licence.
- `https://cwbi-apps.sec.usace.army.mil/nwpl_static/index.html` (National Wetland Plant List) — connection failed (HTTP 000). **No evidence found.**
- `https://opus.nlpl.eu/` — page loaded but contains **no licensing statement**; per-corpus terms not retrieved.
- HathiTrust, Internet Archive, LibriVox, FAA/USCG/NWCG/FEMA publication terms, MobileNet/EfficientNet model-card licences, and the WHO GHO open-data licence were **not reached** before the research budget ran out.

**Search-budget note:** the session's shared WebSearch allowance (200 calls) was exhausted after 5 searches in this
assignment. All remaining evidence above was gathered by direct primary-source retrieval (WebFetch, curl, `gh api`),
which is why nearly every licence is marked VERIFIED FETCH rather than sourced from a snippet.

