# SHORTLIST.md — Phases 3 & 4

Five candidates, deep-dived and scored. Scoring is the brief's rubric, 1–5 per criterion × weight,
max 90. **Anything scoring 1 or 2 on criteria 1, 2 or 3 is disqualified regardless of total** — and
one candidate is, which is worth reading.

| # | Criterion | Weight |
|---|---|---|
| 1 | Offline necessity — offline is the point, not a compromise | ×3 |
| 2 | Pain intensity + evidence strength | ×3 |
| 3 | Data feasibility — licensing verified, obtainable, no refresh treadmill | ×3 |
| 4 | Substance — enough depth to be a real, complete product | ×2 |
| 5 | Niche reachability — I can name the exact places these people gather | ×2 |
| 6 | Competitive gap | ×2 |
| 7 | Retention | ×2 |
| 8 | Distribution / monetization path | ×1 |

---

# Ranking

| Rank | Idea | Score | Verdict |
|---|---|---|---|
| **1** | **Is This Legal? — offline catch-legality reference (AR/ES/GL/CA/PT-BR/EN)** | **80 / 90** | **Winner** |
| 2 | Offline condition-report & treatment record for art conservators | 75 / 90 | Strong runner-up, cleanest licence |
| 3 | Offline high-power rocketry flight-line companion | 75 / 90 | Tied on points, loses on data feasibility |
| 4 | Offline ICS field kit for disaster-response volunteers | 74 / 90 | Killed by retention |
| — | Offline USCG licence / QMED exam trainer | 71 / 90 | **DISQUALIFIED** — scores 2 on criterion 3 |

> **Post-review correction.** The winner originally scored 86. An adversarial review found four
> competitors the first pass missed and one evidence claim the cited source did not support. Criterion 6
> drops 5→4 and criterion 2 drops 5→4. **The winner's margin narrows from 11 points to 5, and it still
> wins.** Details in the corrected scorecard below and in `REVIEW-CHANGES.md`.

---

# 1. Is This Legal? — offline catch-legality reference — **80/90**

**One line:** you have a fish in your hand; the app states in under five seconds whether it meets the
rules where you are standing, and which rule it fails if not — with no network, no account, and the
citation to the actual law.

### Scorecard (corrected after adversarial review)

| # | Criterion | Score | × | = | Why |
|---|---|---|---|---|---|
| 1 | Offline necessity | 5 | 3 | **15** | The decision is taken on a boat kilometres offshore, ankle-deep on an intertidal flat, or on a riverbank — wet hands, fish still alive, seconds to decide. The Ras Al Khaimah Fishermen's Association's own stated reason for building their app was that *the previous one needed internet and most fishermen at sea could not use it*. |
| 2 | Pain + evidence | **4** | 3 | **12** | ~~5~~ → 4. Still validated past the bar — 4 regions, 5 platforms, and the keystone source was independently re-verified. Docked one point because **one claim did not survive checking**: I wrote that Spanish anglers "explicitly refuse to upload fishing positions". A reviewer pulled all 58 PescaREC reviews and none says that. Corrected below. |
| 3 | Data feasibility | 4 | 3 | **12** | Legal texts are excluded from copyright by statute in Spain (**Art. 13 LPI**, whole-disposición), Brazil (**Lei 9.610/1998 art. 8, IV**, *os textos* only) and the UAE (**Federal Decree-Law 38/2021 Art. 3**). Docked one point for the annual re-authoring cycle and for artwork that must be originated. |
| 4 | Substance | 5 | 2 | **10** | Temporal rule engine with expiry semantics, on-device zone polygons, per-species measurement diagrams, a deterministic morphological key with candidate lists, vernacular search across six locales including full Arabic normalisation, screen-ruler calibration, bag tally, penalties, licence classes, glossary, changelog, per-row citations. |
| 5 | Niche reachability | 5 | 2 | **10** | Nameable: RAK Fishermen's Association, Dubai Fishermen's Co-operative (>900 members), the Galician *confrarías* (Muros, Campelo already ship notice-board apps), the Federación Galega de Confrarías, Brazilian *colônias de pescadores* and pesqueiro operators, and Pesca na Regra's audience. |
| 6 | Competitive gap | **4** | 2 | **8** | ~~5~~ → 4. **My "zero results in Spain" was a term-selection artefact** — `tallas minimas pesca` returns 0, but `vedas pesca` and `marisqueo` return real apps. Four competitors were missed, one of them substantial (NORMAP). The Gulf gap survives re-checking; the Spanish one is narrower than claimed. |
| 7 | Retention | 5 | 2 | **10** | Opened multiple times per trip, every trip, all season. |
| 8 | Distribution / monetization | 3 | 1 | **3** | ~~4~~ → 3. Paid app or regional packs, and associations are a real channel — but two of the newly-found competitors are **free government apps** (NORMAP, EU RecFishing), which is a hard price anchor to fight in the EU. |
| | | | | **80** | |

### Evidence table

| Source | Platform | Date | What it shows |
|---|---|---|---|
| [Emarat Al Youm](https://www.emaratalyoum.com/local-section/other/2019-07-08-1.1230866) | UAE national daily | 2019-07-08 | The RAK Fishermen's Association built and distributed its own on-screen fish-measuring app **because the previous one required internet** and the fishermen are at sea with no coverage. This is the single strongest item in the whole corpus: the users didn't complain, they built it. |
| [Fish Rules reviews](https://apps.apple.com/us/app/fish-rules-local-fishing-laws/id597875361) | Apple App Store (US) | recent, retrieved 2026-07-27 | 1★ *"Incorrect Information, Poorly Managed App"* — rules out of sync, and the reviewer names the stakes: citations, fines, imprisonment. Plus a $30 purchase stuck in a login loop, and full-screen ads that block the species list. On an app that advertises "works offline". |
| [PescaREC reviews](https://apps.apple.com/es/app/pescarec/id6752486687?see-all=reviews) | Apple App Store (ES) | late 2025 – 2026 | **Corrected.** Spain's official recreational-fishing app sits at **1.92★** on the current version, with **58 written reviews** in the ES storefront. The complaints are: licence not detected (dozens), registration failure, crashes, and resentment at being compelled to declare catches. ⚠️ My first draft claimed users "explicitly refuse to upload fishing positions" — a reviewer pulled all 58 reviews and **not one says that**; the only privacy-adjacent line is a generic "abusos contra la privacidad". The claim has been removed from `SPEC.md` §0, §5 and §17. What the reviews *do* support — a mandatory-declaration app that locks users out at an account gate — argues for the same design, so the conclusion stands on corrected evidence. |
| [Pesca en Castilla y León reviews](https://apps.apple.com/es/app/pesca-en-castilla-y-león/id1672539106?see-all=reviews) | Apple App Store (ES) | 2024-05 → 2026-03 | **2.3★**; anglers report wrong season end-dates for river stretches and days marked kill-permitted in a catch-and-release region. The official apps are inaccurate. |
| [Xunta de Galicia — tallas mínimas](https://www.pescadegalicia.gal/gl/tallas-minimas) | Government portal | live 2026-07-27 | Galicia's legal minimum sizes, measuring diagrams and shellfish-bank exceptions are published as **7 HTML tables plus a scanned 1.19 MB order PDF** (`/tallas/pdf/orde.pdf`), citing Orde do 27/07/2012, DOG 226. ⚠️ My first draft said "no download", which is wrong — the PDF exists. The real gap is **no structured dataset and no offline app**, plus one Galician consumer app abandoned since 2019. |
| [Pesca na Regra](https://pescanaregra.com.br/pesca/sao-paulo/) | Editorial website | updated 2026-04-25 | Someone has already normalised all 27 Brazilian states' piracema dates, minimum sizes and quotas — and published it as a **website**, which is unreachable from a riverbank. |
| iTunes Search API, 8 storefronts | Apple | 2026-07-27, re-confirmed by an independent reviewer the same day | `الاطوال المسموحة للاسماك` → **0 results in AE, SA, KW, OM, QA and BH**; `دليل الصياد` and `الصيد البحري` in the same six return only Windfinder, Windy, Fishing Points, English AI fish-ID apps and arcade games. `pesca defeso tamanho minimo` → **0 in BR**. ⚠️ `tallas minimas pesca` → 0 in ES, **but that was a bad query** — see the competitor list. |
| Google Play BR search | Google | 2026-07-27 | `piracema legislacao pesca estado` returns **only fishing video games and foreign forecast apps**. |

### Closest existing apps, and exactly what they get wrong

⚠️ **Four of these ten were missed by my first pass and found by the adversarial reviewer.** The lesson
is the one the brief warns about: *"nobody has built this" usually means "I didn't search properly."*
My Spanish search used one technical term (`tallas minimas pesca`) and returned zero; a reviewer tried
`vedas pesca` and `marisqueo` and found an official Xunta app immediately. The competitive-gap score has
been reduced accordingly.

1. **[Fish Rules: Local Fishing Laws](https://apps.apple.com/us/app/fish-rules-local-fishing-laws/id597875361)** (iOS + Android, 193 ratings, 3.88★, updated 2026-07-17). Covers US saltwater only — "Maine to Texas, California, Hawaii, and the Caribbean". Claims offline, but requires an account and a subscription, and its reviews are dominated by login loops, unhonoured purchases, ad-blocked navigation and, most damningly, rules that were wrong for over a year. **Wrong geography, wrong architecture, wrong trust model.**
2. **[FishVerify: ID & Regulations](https://apps.apple.com/us/app/fishverify-id-regulations/id1121514756)** (2,098 ratings, 4.60★). Its headline feature is camera image recognition, which by construction round-trips a photo to a server — the one thing that cannot work where the user is. Subscription-gated, US-only. **Architecturally disqualified from the actual use case.**
3. **[Fish Washington](https://apps.apple.com/us/app/fish-washington/id1002220226)** (6,951 ratings, 4.33★) and the Galician cofradía apps (Confraría de Muros, Lonxa de Campelo). Single-jurisdiction agency apps. Proof the demand is real and that agencies will build for it; each covers one place and none is a general product.
4. **[NORMAP](https://apps.apple.com/es/app/normap/id1457038592)** — Gobierno de Canarias, **updated 2026-07-13**, actively maintained. **This is the closest thing that exists** and my first pass missed it entirely. Its own description offers, for any point on the Canary coast and across nine user profiles (professional and recreational shellfisher, shore angler, boat angler, spearfisher…): *épocas de veda, artes de pesca permitidas, tipos de licencias requeridas, cupos máximos de captura, tallas mínimas de captura, prohibiciones generales, especies protegidas*. That is CATCHLAW's feature set minus the ruler and the catch log — shipped, by a Spanish regional government, in a target market. **What it does not do:** one archipelago only; Spanish only (no Galician, Catalan or Arabic); no measurement; no factual finding against a measured length; and it is a map-visor architecture with a `normap.org` dependency whose offline behaviour is **unverified and must be tested before Spain is treated as an open market**. It is proof that incumbents in target markets *do* build this.
5. **[Non piques – Non peques](https://apps.apple.com/es/app/id1060018314)** — Xunta de Galicia, free, 3.4★, **last updated 2019-04-09**. Galician-language, and its description promises to *"identificar de forma sinxela e rápida os tamaños mínimos legais"* plus best seasons per species. Also missed by my first pass, and the direct reason the "zero results in ES" claim was wrong. **What it does not do:** consumer/buyer framing rather than a fisher's field tool, no measurement, no citations, no seasons by zone, no bag limits — and it has been abandoned for seven years.
6. **[EU RecFishing](https://apps.apple.com/es/app/eu-recfishing/id6746253374)** — European Union Publications Office, free, **updated 2026-06-18**, 24 languages, explicitly *"incluso fuera de línea"*. Catch logging, gear recording, photos, history with statistics, and generation of **official catch declarations**. It overlaps CATCHLAW's whole logging half in every EU target market, from a publisher that cannot be beaten on trust. **What it does not do:** it is a *declaration* tool, not a legality engine — no minimum sizes, no closed-season findings, no measurement, no per-CCAA rules, no Galician, Catalan or Arabic. `SPEC.md` §5 now positions the catch log as a private complement to it, never a substitute.
7. **[iDfish](https://apps.apple.com/es/app/idfish/id1068033877)** — IDVIABILITY PTY LTD, **1,425 ratings / 4.66★ in the AU store**, updated 2026-04-28, listed in the ES, BR and AE storefronts. Runs **on-device** AI photo recognition *"without an internet connection"* alongside legal size limits, possession limits, protection status and closures. This **disproves my first draft's claim that photo-AI cannot work offline**, and `SPEC.md` §5.2 now gives the true reasons for excluding it. **What it does not do:** Australia-focused, and *"you are also required to create an account and log in before offline use is available"*, at $9.99/yr — the exact account gate this product refuses.
8. **Photo-AI fish identifiers** — Picture Fish (5,311), Catchr (4,730), Fish Identifier: Fishing AI, SeaSnap, Identificador de Peixes AI. These are what an Arabic- or Portuguese-speaking fisher actually finds when searching in their own language. None knows a single law, and these particular ones all need a network.
9. **Propesca** (SEALAB, ES, updated 2025-10-09, 1 rating) and **Fish Rules Commercial** (3 ratings) — real but negligible.

**Corrected claim.** I can no longer write "nobody has built this". The accurate statement is:
**nobody has built an account-free, offline, multi-jurisdiction catch-legality reference that works in
Arabic, Galician, Catalan or Brazilian Portuguese.** Spain is *partly served* — by one abandoned Galician
consumer app and one actively-maintained Canarian regional app of unverified offline capability. The Gulf
gap is the one that survives every re-check, and it is also the one where the language is the moat.

### Data licensing — verified

| Asset | Licence position | Status |
|---|---|---|
| Spanish regional fishing/shellfish orders (Orde da Xunta, órdenes de vedas) | **Art. 13 LPI**: "No son objeto de propiedad intelectual las disposiciones legales o reglamentarias… así como las traducciones oficiales" | ✅ [Verified](https://www.boe.es/buscar/act.php?id=BOE-A-1996-8930&p=20190302&tn=1#a13) |
| Brazilian IBAMA/MPA portarias and state normative instructions | **Lei 9.610/1998 art. 8, IV** — *"os textos de tratados ou convenções, leis, decretos, regulamentos, decisões judiciais e demais atos oficiais"*. A portaria is an *ato oficial* | ✅ **Upgraded after review** — verified verbatim on planalto.gov.br. ⚠️ Note the exclusion covers ***os textos*** only, unlike Spain's whole-*disposición* wording, so **graphic annexes to a Brazilian portaria are not clearly covered**. All measurement diagrams are therefore originated SVG |
| German Landesverordnungen (if DE is added later) | **§5 UrhG**: laws, ordinances and official decrees enjoy no copyright protection | ✅ [Verified](https://www.gesetze-im-internet.de/urhg/__5.html) |
| UAE Ministerial Decisions 580/2015, 471/2016, 500/2014; Abu Dhabi EAD fishing law | **UAE Federal Decree-Law No. 38 of 2021 on Copyright and Neighbouring Rights, Art. 3** (successor to Federal Law 7/2002 Art. 3), excluding official documents including texts of laws, regulations, resolutions and decisions | ⚠️ **Statute now named** (it was missing entirely from the first draft, for the app's own flagship locale) but **not independently verified in this session**; an equivalent provision must be quoted per Gulf state before that state ships. Text must come from the **official gazette/ministry PDF, never from FAOLEX's abstract or an FAO translation** — those are FAO works under FAO terms. PDFs downloaded but not text-extractable here |
| Species illustrations | **The real licence risk.** FAO species sheets and Wikimedia are mixed/NC | ➡️ Original SVG line art, plus public-domain plates cleared **per image by illustrator death year**, not by publication date — see the correction below |
| Scientific and vernacular names | Catalogue of Life is **CC BY 4.0** (`"license": "cc by"`, 5,413,595 taxa, COL26.7) — including its **vernacular-name extension**, which is now the sole source for English common names | ✅ [Verified](https://www.checklistbank.org/dataset/315777). ⚠️ **FAO ASFIS is no longer used**: FAO's site terms permit non-commercial use only, and the first draft named ASFIS without checking. The `fao3a` column has been **deleted from the schema** — nothing read it, and its licence was unnamed |

**Correction — the public-domain test for plates was wrong.** The first draft used "pre-1930 = public
domain", which is the **US** rule and the wrong test for every market this ships to: Spain/EU run
life+70 (Spain's TRLPI transitional rule gives **80 years pma** for authors who died before 7 Dec 1987),
Brazil life+70, the UAE life+50 — all measured from the *author's death*, not publication. Bloch (d. 1799)
and Cuvier/Valenciennes (d. 1832/1865) clear easily; Jordan (d. 1931) and Evermann (d. 1932) clear too —
**but the staff illustrators of their plates were never named and their death years never established.**
`SPEC.md` §8 now requires the illustrator's name and death year per image, asserts
`current_year > death_year + 80` in the content build, and drops any plate whose artist is unidentifiable.

### Technical sanity check

Flutter 3.x. **drift** (SQLite) with two databases — a read-only pre-seeded reference DB shipped as an
asset, and a separate writable user DB, so a content update never risks the user's catch log.
**flutter_riverpod** for state. **flutter_localizations** + ARB for six locales including RTL.
**flutter_svg** for species art and measurement diagrams. **geolocator** for a raw GPS fix (no map
tiles, no geocoding — point-in-polygon against bundled zone rings, computed locally). **pdf** +
**printing** for the trip report. **share_plus** + **file_picker** for export/import.
**No HTTP client, no Firebase, no analytics** — and that is verifiable by CI grep.

---

# 2. Offline condition-report & treatment record for art conservators — **75/90**

| # | Criterion | Score | × | = | Why |
|---|---|---|---|---|---|
| 1 | Offline necessity | 4 | 3 | 12 | Condition reports are written in collection vaults, sub-basement stores, freight-forwarder crate rooms, art-fair loading docks, in trucks and on scaffolding inside churches. Strong — but some institutions do have wifi, so it is not the absolute case. |
| 2 | Pain + evidence | 3 | 3 | 9 | Real but thin: one review page. A 1★ says the incumbent is "not recommended for conservators" because long text blocks did not save; two more report crashes losing a whole project's work. Moderate. |
| 3 | Data feasibility | 5 | 3 | **15** | **The cleanest licence on the shortlist.** Getty Vocabularies (AAT, ULAN, TGN) are released under **ODC-By 1.0** with full N-Triples dumps — commercial use permitted with attribution, and AAT carries multilingual labels, which solves bundled-content translation. |
| 4 | Substance | 5 | 2 | 10 | Object records, photo damage annotation, controlled vocabulary, treatment history, materials, PDF export. |
| 5 | Niche reachability | 4 | 2 | 8 | AIC "over 3,500 members in over twenty countries"; AIC Wiki has 1,680 registered users. Plus ICON (UK) and E.C.C.O. (EU). |
| 6 | Competitive gap | 5 | 2 | 10 | The one real product is ~$710/year and its own users say it loses their work. |
| 7 | Retention | 4 | 2 | 8 | Every incoming/outgoing loan, every treatment, every survey. |
| 8 | Distribution | 3 | 1 | 3 | Conference/association channel; institutional purchasing is slow. |
| | | | | **75** | |

Closest apps: **Articheck** (subscription, cloud, crash reports), institutional TMS/CollectionSpace
modules (desktop, server), and generic form builders. ⚠️ **Do not bundle the AIC Wiki** — its
`Copyrights` and `General disclaimer` pages are both empty, so its text is not licensed for reuse.

---

# 3. Offline high-power rocketry flight-line companion — **75/90**

| # | Criterion | Score | × | = | Why |
|---|---|---|---|---|---|
| 1 | Offline necessity | 5 | 3 | 15 | [Tripoli Vegas' own launch page](https://tripolivegas.com/launchschedule.html) tells flyers to screenshot their membership cards before driving out **because there is no cell service at the launch site**. The club designs its check-in around the absence of signal. |
| 2 | Pain + evidence | 4 | 3 | 12 | Exceptional in kind: a member [wrote the app's complete feature list and database schema himself](https://www.rocketryforum.com/threads/a-phone-app-that-i-really-want.164851/); another has filled seven 3×5 notebooks in ten years because nothing digital fits; a third said he'd write it and never did. Two threads, one forum — hence 4 not 5. |
| 3 | Data feasibility | 3 | 3 | **9** | The ready-made offline motor dataset (`openrocket/motor-database`, a compiled gzipped SQLite) is **GPL-3.0** — copyleft, awkward inside a closed Flutter binary. The underlying ThrustCurve `.eng`/`.rse` files are manufacturer certification data (largely factual) but **John Coker's own terms were not verified**. This is the weak link. |
| 4 | Substance | 5 | 2 | 10 | Thrust curves, motor-vs-airframe selection, 1-DOF/3-DOF apogee and optimal-delay sim, drift radius under wind, recovery bearing, RSO flight card, certification logbook. |
| 5 | Niche reachability | 5 | 2 | 10 | NAR: ~8,850 members, 200 affiliated sections. Tripoli prefectures. Perfectly in band and perfectly nameable. |
| 6 | Competitive gap | 5 | 2 | 10 | The App Store returns **only arcade games** for `model rocket motor simulation`. OpenRocket is desktop Java; RockSim is desktop and paid. |
| 7 | Retention | 3 | 2 | 6 | Launch weekends and build seasons, not daily. |
| 8 | Distribution | 3 | 1 | 3 | Club launches and NAR/Tripoli channels are excellent; the audience is small. |
| | | | | **75** | |

---

# 4. Offline ICS field kit for disaster-response volunteers — **74/90**

| # | Criterion | Score | × | = | Why |
|---|---|---|---|---|---|
| 1 | Offline necessity | 5 | 3 | 15 | Categorical: the tool exists for the scenario in which the network is down. Several incumbents disqualify themselves by asking for iCloud sync. |
| 2 | Pain + evidence | 4 | 3 | 12 | Eleven clearly-real responders review a bare-bones ICS-214 app, praising it for producing a clean unwatermarked PDF on deployment and listing precise gaps (no chronological auto-sort, a 79-character limit, truncated agency names, one mid-incident failure). |
| 3 | Data feasibility | 4 | 3 | 12 | FEMA publishes ~35 ICS forms as fillable PDFs; US federal agency works are conventionally public domain — but the [FEMA page carries **no explicit licence statement**](https://training.fema.gov/icsresource/icsforms.aspx), so confirm before shipping. Do not bundle ARRL's numbered ARL radiogram texts. |
| 4 | Substance | 5 | 2 | 10 | The full form set, ICS-219 colour-coded T-cards, a message/traffic log, PDF export by AirDrop/Bluetooth/USB. |
| 5 | Niche reachability | 4 | 2 | 8 | MRA ~137 affiliated teams; ARES units across 71 ARRL sections; county CERT programmes. |
| 6 | Competitive gap | 5 | 2 | 10 | The entire category is three tiny apps — 7, 11 and 20 ratings — one of which was **last updated in 2016**. |
| 7 | Retention | 2 | 2 | **4** | **This is what kills it.** Volunteers deploy a handful of times a year. Between incidents the app is not opened. |
| 8 | Distribution | 3 | 1 | 3 | Strong word-of-mouth inside teams; small paying population. |
| | | | | **74** | |

---

# — Offline USCG licence / QMED exam trainer — 71/90, **DISQUALIFIED**

| # | Criterion | Score | × | = | Why |
|---|---|---|---|---|---|
| 1 | Offline necessity | 5 | 3 | 15 | A mariner shipping out for six months asks what he can take to study; the accepted answer is "buy a USB thumb drive… no internet required, all you need is a Windows computer." |
| 2 | Pain + evidence | 5 | 3 | 15 | Three independent verified gCaptain threads, including one where mariners queue up asking to be emailed a copy of question banks the USCG removed, complaining that the only people who have them are monetising them behind paywalls useless at sea. |
| 3 | Data feasibility | **2** | 3 | **6** | **The disqualifier.** The USCG pulled the published question banks off its website around 2016, and `dco.uscg.mil/nmc/exam_questions/` returned **HTTP 403**, so current public availability could not be verified at all. Building an entire product on a corpus you may not be able to obtain — and whose provenance would be the hand-passed copies described in that very thread — is precisely the failure the brief warns about. |
| 4 | Substance | 4 | 2 | 8 | |
| 5 | Niche reachability | 4 | 2 | 8 | ~200,000 US credential holders; the exam-sitting subset is plausibly 10k–40k. |
| 6 | Competitive gap | 4 | 2 | 8 | Sea Trials (375 ratings) already mines the public USCG material. |
| 7 | Retention | 4 | 2 | 8 | Intense while studying, then zero forever. |
| 8 | Distribution | 3 | 1 | 3 | |
| | | | | **71 → DQ** | |

I am recording this one because it had the strongest *demand* evidence of anything I found and still
fails. A 71 that cannot legally ship is worth less than a 74 that can.

---

# Why #1 beats #2

The art-conservator app is the better-licensed product and I want to be honest that its criterion-3
score is the highest on the board — Getty's ODC-By vocabularies are cleaner than anything the fishing
app depends on, and they arrive pre-translated, which quietly solves a problem I have to solve by hand
for the winner. But it loses on the two things this brief actually optimises for.

First, **evidence**. The conservator case rests on three complaints on one App Store listing. The
fishing case is validated four times over across five platforms, and contains the strongest single
artefact in the entire corpus: a fishermen's association that did not merely complain but *built and
distributed its own app, giving as its stated reason that the previous one required internet*. That is
demand demonstrated by expenditure, not by grumbling. Layered on top of it are two official government
apps rated 1.9★ and 2.3★ by their own users — one for demanding uploads of fishing positions people
consider private, the other for publishing wrong season dates — and a US incumbent whose own customers
say its rules have been wrong for over a year while it locks them out behind a login. Every failure
mode the brief predicts is documented happening to real people in this exact category.

Second, **the offline test in its strongest form**. A conservator writing a condition report in a
basement is inconvenienced by a network failure. A fisherman holding a live undersized fish is not: the
fish is dying while he waits, the fine is real, and the decision cannot be deferred. And where the
conservator's employer is often on a corporate wifi, the Gulf fisherman is kilometres offshore, the
Galician mariscadora is on an intertidal flat, the Brazilian angler is on a reservoir bank — three
independent geographies whose common property is that the network is simply not there.

Third, and decisively for this brief's stated parameters, the fishing app is the only shortlisted idea
where **multi-language is the product rather than a feature**. The user asked for English plus at least
four more, including RTL if relevant. Here the language *is* the moat: `الاطوال المسموحة للاسماك`
returns zero results in all six Gulf storefronts, and `دليل الصياد` and `الصيد البحري` return only
weather apps, arcade games and English AI identifiers — verified by me and re-verified independently.
A Gulf fisherman searching in his own language finds nothing that knows a single law. Species must be
listed as هامور، شعري، صافي، بدح، كنعد — not as *Epinephelus coioides* — and the tables must lay out
right-to-left. That is exactly the work an English-reading indie developer never does, which is why the
gap has stayed open. Rocketry, ICS and conservation are all defensibly monolingual products; a
multi-language version of them would be decoration.

**How much the review cost this argument, honestly.** The margin was 11 points and is now 5. Two of the
three legs above survived unchanged; the first leg — evidence — took a real hit, because one of my four
supporting claims (Spanish anglers refusing to upload positions) was not in the source I cited, and my
Spanish competitive claim rested on a single badly-chosen search term. **The keystone survived every
check**: a reviewer independently re-fetched the 2019 Emarat Al Youm article and confirmed it says the
RAK association's prior app required internet and that fishermen at sea could not use it, and re-pulled
all six quoted Fish Rules reviews verbatim from the RSS feed. What changed is that Spain is no longer a
green field — NORMAP is a live, maintained, government-built near-equivalent for the Canaries, and its
offline behaviour is now a named pre-build test (`SPEC.md` §16 R2). If NORMAP turns out to work well
offline and spreads to other comunidades, the Spanish half of this thesis weakens considerably and the
product becomes a Gulf-and-Brazil play. The Gulf gap is the one that has survived every attempt to
disprove it, and it is also the one where nobody else can easily follow.

The rocketry app is the one I'd most like to build for fun, and its evidence is charming — a user who
wrote the schema himself, and another with seven notebooks. It loses on criterion 3: its ready-made
motor dataset is GPL-3.0 and the upstream terms are unverified. The ICS kit has an unbeatable offline
argument and a genuinely vacant category, and dies on retention — volunteers deploy a few times a year.

**One honest caveat on the winner, carried into the spec:** its criterion-3 score of 4 rather than 5
reflects a real annual re-authoring cost and a species-artwork problem that must be solved with
original or pre-1930 public-domain plates. Neither is a licence kill, but both are work, and the spec
treats content authoring as a first-class deliverable rather than an afterthought.
