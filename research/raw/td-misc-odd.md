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
