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
