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
