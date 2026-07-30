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
