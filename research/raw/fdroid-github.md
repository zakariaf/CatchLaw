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
