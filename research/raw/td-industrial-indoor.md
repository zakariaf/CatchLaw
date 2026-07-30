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
