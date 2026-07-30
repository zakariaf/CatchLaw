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
