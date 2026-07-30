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
