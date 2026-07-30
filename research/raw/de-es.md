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
