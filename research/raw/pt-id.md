# Phase 1 Discovery — Brazilian Portuguese & Indonesian
Researcher pass date: 2026-07-27

## Method / tooling note (read before trusting anything below)
- Reddit was **not** touched (blocked per brief). No reddit URL appears here.
- The `WebSearch` tool budget (200/200) was exhausted after 8 queries. Remaining searches were run through
  (a) `lite.duckduckgo.com` fetched via WebFetch, (b) Brave Search HTML fetched via curl, (c) the **iTunes Search API**
  (`itunes.apple.com/search`), (d) **Google Play store search pages** fetched via curl, and (e) the **OpenAlex** works API.
  DuckDuckGo and Brave both began serving CAPTCHA/429 partway through; several public SearxNG instances, Mojeek,
  Ecosia, Startpage and Bing were all blocked or JS-only from this environment.
- `gov.br` (Brazilian federal), `tanamanpangan.pertanian.go.id` and `uptptph.kalbarprov.go.id` all return **401/403**
  to both WebFetch and curl from here. Where I wanted a number from those, I say "unknown".
- **Play Store / App Store search results are used as *negative* evidence** ("nobody built it"). Those searches were
  genuinely executed and their raw result lists are quoted in each finding.

---

### Indonesia — POPT (Pengendali/Pengamat Organisme Pengganggu Tumbuhan): offline pest-scouting & fortnightly reporting
- **Query:** `jumlah petugas POPT pertanian Indonesia kekurangan tenaga pengamat hama` (Brave) → then direct fetch
- **Source:** Change.org petition (Indonesian national POPT community) | **URL:** https://www.change.org/p/popt-siap-menjadi-bagian-kementerian-pertanian-untuk-mengawal-swasembada-pangan-indonesia | **Date:** references the Komisi IV DPR RI / Kementan working meeting of 10 June 2026; retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** A live national petition by Indonesia's crop-protection field officers, carrying **4,183 verified signatures**, describes POPT as the technical staff who do pest observation, forecasting, control and farmer coaching in production centres, and asks that their employment be moved under the Ministry of Agriculture.
- **Points to:** An offline-first Android field notebook that implements the official POPT observation protocol (fixed sample plots + patrol) with species/damage counts, automatic attack-intensity and area-affected maths, and export of the standard fortnightly report form.
- **Offline necessity:** The whole job is standing in a paddy field or plantation block counting tillers and hoppers; POPT sub-areas are deliberately remote production centres, and the officer must key numbers while hands are on the crop, not wait on a login.
- **Audience size:** ≥4,183 (verified petition signatures, a floor not a ceiling). Sibling profession for context: **31,500 penyuluh pertanian** in service (Republika, 11 Feb 2019, https://www.republika.co.id/berita/ekonomi/pertanian/19/02/11/pmrk9g423-indonesia-kekurangan-40-ribu-penyuluh-pertanian — VERIFIED FETCH).
- **Data/licence note:** Bundle Kementan's own *Juknis Pengamatan dan Pelaporan OPT dan DPI Tanaman Pangan* (pest list, sampling rules, damage categories). PDF confirmed live and downloadable: HTTP 200, `application/pdf`, 1,891,956 bytes, `Content-Disposition: filename="Juknis pengamatan OPT dan DPI Tanaman Pangan.pdf"` at https://mplk.politanikoe.ac.id/index.php/info-ps-mplk/download/category/4-e-book-panduan?download=32%3Ajuknis-pengamatan-opt-dan-dpi-tanaman-pangan (headers verified; I did **not** parse the PDF body). Indonesian government technical guidance — needs a licence check but is distributed freely by state institutions.

### Indonesia — the official OPT reporting system is explicitly *online-based* (the gap, stated by the ministry itself)
- **Query:** `aplikasi pengamatan OPT POPT lapangan offline sinyal laporan mingguan padi` (Brave)
- **Source:** Tempo (Kementan advertorial) | **URL:** https://www.tempo.co/info-tempo/kementan-aplikasi-silap-opt-efektif-kendalikan-hama-tanaman-578147 | **Date:** 28 September 2020 | VERIFIED FETCH
- **Paraphrase:** The ministry says OPT observation used to be recorded on paper in the field and that its replacement, Silap OPT, is a **web/Android system "berbasis online"** whose point is getting data to headquarters fast — i.e. the design centre of gravity is the server, not the officer standing in the field.
- **Points to:** The same POPT app as above, positioned as the *capture* layer that Silap OPT never was: works cold in airplane mode, produces the exact numbers the officer then types into the government portal back at the office.
- **Offline necessity:** The ministry's own framing ("data langsung diinput ketika melakukan pengamatan") only works if the app does not need a network at the moment of observation; the current one does.
- **Audience size:** see previous finding.
- **Data/licence note:** No content needs to be copied from Silap OPT — only the published observation methodology.

### Indonesia — POPT observation protocol is dense enough to be a real 2-month build
- **Query:** same Brave query as above
- **Source:** Politeknik Pertanian Negeri Kupang (MPLK teaching material) | **URL:** https://mplk.politanikoe.ac.id/index.php/pengelolaan-opt/1118-pengamatan-tetap-opt-tanaman-pangan | **Date:** undated course page; retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The protocol splits each officer's territory into 4 sub-areas, each with one permanent sample plot plus roaming patrol, with week-1 and week-2 rounds aggregated into first-half-of-month and second-half-of-month reports, plus ad-hoc "laporan khusus" when an outbreak trend appears.
- **Points to:** Territory model + plot model + rolling fortnight aggregation + incident reports — genuinely fiddly state management, which is exactly why no indie has done it.
- **Offline necessity:** Rounds happen on foot across four scattered sub-areas; the aggregation must survive a phone that never sees a tower during the round.
- **Audience size:** see first finding.
- **Data/licence note:** Methodology is public teaching/state material; pest species list would come from the Juknis.

### Indonesia — market-level proof that "offline" is a first-class product requirement, not a nice-to-have
- **Query:** Google Play ID store search `rekomendasi pemupukan spesifik lokasi kecamatan`
- **Source:** Google Play (Indonesia storefront) | **URL:** https://play.google.com/store/apps/details?id=gov.kementan.ipubers_off | **Date:** retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The Ministry of Agriculture ships a **separate build literally named "iPubers Offline"** for subsidised-fertiliser redemption (publisher "Integrasi Pupuk Bersubsidi Kementan - PIHC"), rated 2.8 with 1k+ downloads — a government that had to fork its own app because rural kiosks have no signal.
- **Points to:** Not an app idea in itself; it is the strongest single piece of evidence that Indonesian rural software fails on connectivity and that an offline-first competitor has room.
- **Offline necessity:** Confirmed by the state's own product decision.
- **Audience size:** n/a (evidence item).
- **Data/licence note:** n/a.

### Indonesia — nelayan tide/sea data: the only Indonesian-language app "solves" offline by caching on land
- **Query:** Google Play ID store search `pasang surut offline nelayan`
- **Source:** Google Play (Indonesia storefront) | **URL:** https://play.google.com/store/apps/details?id=com.harisdevs.cekpasangsurutairlaut | **Date:** retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The listing's own selling point #8 is "Mode Hemat Kuota (Offline)" and it opens by asking whether you *keep losing signal out at sea* — but it only replays data that was already loaded while on land; 1k+ downloads, and every other result in that search is a foreign English-language tide app.
- **Points to:** A true offline tide/moon/current predictor for Indonesian ports computed on-device from harmonic constants, in Indonesian, that is correct on a cold first launch in airplane mode.
- **Offline necessity:** Very strong — small-boat fishers lose signal within a few km of shore and the tide decision (when to cross the reef flat, when the estuary mouth is passable) is taken at sea.
- **Audience size:** unknown for this app's actual user base beyond "1 rb+ downloads"; the national artisanal-fisher population is far larger than the 3k–50k target, so the addressable slice would need narrowing (e.g. one province, or tambak/aquaculture pond operators).
- **Data/licence note:** ⚠️ **Weakest point.** Tide harmonic constants for Indonesian stations are BIG/Pushidrosal products with unclear commercial-reuse terms; global open alternatives (FES/TPXO) are largely academic-use-only. Would need a real licence audit before this is buildable. Marking this lead **Weak** for that reason, despite the excellent offline story.

### Indonesia — petugas IB / inseminator: cattle breeding records in villages with no signal
- **Query:** `inseminator "inseminasi buatan" aplikasi pencatatan ternak offline iSIKHNAS SMS kendala sinyal desa` (WebSearch) + Google Play ID search `inseminasi buatan sapi pencatatan inseminator`
- **Source:** Google Play (Indonesia storefront), result list | **URL:** https://play.google.com/store/search?q=inseminasi%20buatan%20sapi%20pencatatan%20inseminator&c=apps&hl=id&gl=ID | **Date:** retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The Indonesian store returns no Indonesian-language insemination record-keeping tool — the hits are generic foreign herd managers (`com.bivatec.cattle_manager`, `com.zaheer.livestock`, `com.kelimesoft.suruyonetimi`) plus a Brazilian Embrapa app; the only domestic hit is a general `peternak.os.swv` farmer app.
- **Points to:** An offline service-record app for AI technicians: cow ID, oestrus date, straw/bull code, service number, expected calving date, PKB/ATR follow-up dates, per-farmer roster — the exact fields iSIKHNAS asks for, captured before there is any signal.
- **Offline necessity:** Strong — the technician works standing in a village kandang, often on a motorbike route through areas the brief would call "deep rural"; the historical national workaround was SMS-based reporting.
- **Audience size:** unknown from a verified page. (iSIKHNAS wiki page https://wiki.isikhnas.com/w/Farmer_Registration_and_Animal_ID returned HTTP 500 when I tried to open it, so its content is **unverified - from search snippet only**: snippet said farmer/animal registration is performed by inseminators in their villages.)
- **Data/licence note:** Almost no bundled dataset needed — a small gestation-table and breed/straw reference. Licence risk near zero. Downside: this is close to a "logbook", so it must earn its keep on domain depth (gestation maths, service-per-conception stats, government report shapes).

### Indonesia — bidan desa / e-Kohort KIA: connectivity is a named implementation problem (but a poor indie target)
- **Query:** `aplikasi bidan desa offline pencatatan kohort tanpa sinyal kendala` (DuckDuckGo Lite via WebFetch)
- **Source:** DuckDuckGo results page listing Indonesian midwifery journals | **URL:** https://lite.duckduckgo.com/lite/?q=aplikasi+bidan+desa+offline+pencatatan+kohort+tanpa+sinyal+kendala | **Date:** retrieved 2026-07-27 | VERIFIED FETCH of the results page; the underlying journal articles are **unverified - from search snippet only**
- **Paraphrase:** Multiple Indonesian nursing/midwifery journals evaluate e-Kohort KIA rollout and the snippets repeatedly flag incomplete data capture and **network connectivity problems**, alongside complaints that the paper cohort register is slow and has too many columns.
- **Points to:** An offline pre-capture companion for the maternal/child cohort register.
- **Offline necessity:** Real (village posyandu, home visits) — but…
- **Audience size:** unknown; Indonesian village midwives number in the tens of thousands.
- **Data/licence note:** ⚠️ **I recommend rejecting this.** It is a mandatory government reporting instrument, so an unofficial app cannot close the loop, and anything touching pregnancy risk scoring drifts toward the medical-liability exclusion in the brief. Logged for completeness only. **Weak.**

### Indonesia — juru sembelih halal (JULEHA): organised, named, certified community — but thin offline case
- **Query:** `aplikasi juru sembelih halal juleha offline panduan tanpa internet` (DuckDuckGo Lite via WebFetch)
- **Source:** Asosiasi JULEHA Indonesia | **URL:** https://www.juleha.or.id/ | **Date:** retrieved 2026-07-27 | VERIFIED FETCH (site opened; **no membership figures published on it**)
- **Paraphrase:** There is a formal national association of halal slaughtermen founded in Gresik in 2016 offering SKKNI-based competency training, i.e. a genuinely nameable, certifiable community — but the site publishes no headcount.
- **Points to:** An offline SKKNI-based slaughter competency checklist / animal-welfare pre-slaughter inspection recorder for Idul Adha temporary slaughter points.
- **Offline necessity:** Weak-to-moderate — mosque yards and village slaughter points during Idul Adha are crowded and network-congested, and hands are wet/busy, but "offline is fine too" is an honest verdict here.
- **Audience size:** unknown (association publishes none).
- **Data/licence note:** The competency standard is SKKNI (Indonesian national work-competency standard, government-issued) — likely usable, but the substance overlaps paid halal-certification training material. **Weak.**

### Brazil — offline per-state fishing-legality reference (piracema / tamanho mínimo / cota / apetrechos)
- **Query:** `aplicativo offline tamanho mínimo de captura pesca amadora espécies permitido Brasil` (DuckDuckGo Lite) + Google Play BR searches `pesca defeso tamanho minimo` and `piracema legislacao pesca estado` + iTunes Search API `pesca amadora defeso` / `pesca tamanho minimo legislacao` (both `count=0` in the BR storefront)
- **Source:** Pesca na Regra (web-only aggregator) | **URL:** https://pescanaregra.com.br/pesca/sao-paulo/ | **Date:** page states "atualizado em 2026-04-25"; retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Someone has already done the hard editorial work of normalising all 27 states' piracema dates, minimum sizes, quotas and licence rules — but only as a **website**, and the São Paulo page even spells out quota rules ("até 10 kg + 1 exemplar de espécies não nativas") and the 1,500 m exclusion around dams and rapids that a fisher needs to know while standing on the bank.
- **Points to:** An offline app that answers "can I legally keep this fish, right here, right now?" — pick state/basin → species → measured length vs. legal minimum → in/out of defeso → daily quota → gear legality, with a ruler screen and a species picker by common regional name.
- **Offline necessity:** Very strong and non-negotiable: the decision happens on a riverbank, a reservoir or a boat, i.e. precisely where there is no signal, and it has to be answered in seconds while the fish is alive.
- **Audience size:** unknown from a page I could actually open — every federal source (gov.br/mpa) returned 401/403 to me, so I will not guess a licence-holder count. The *named, findable* slice is Brazilian sport-fishing clubs, guides and pesqueiro operators.
- **Data/licence note:** The content is IBAMA/MPA/state normative instructions and portarias. Brazilian Lei 9.610/1998 art. 8 excludes official acts (leis, decretos, regulamentos) from copyright, so verbatim rule text should be commercially reusable — **must be re-verified with a lawyer**, and the app must never scrape pescanaregra.com.br's own editorial compilation.
- **Competitive check (VERIFIED FETCH):** Google Play BR search for `piracema legislacao pesca estado` returned **only fishing video games and foreign forecast apps** (`com.tensquaregames.letsfish2`, `com.FishingPlanetLLC.FishingPlanet`, `com.miros.whentofish`…). The search for `pesca defeso tamanho minimo` surfaced exactly one relevant Brazilian app, `seguro.defeso.app.consulta`, which is a *benefit-payment lookup* (needs a server), not a rules reference. Apple's BR storefront returns `resultCount=0` for both regulation queries.

### Brazil — Caderneta Agroecológica: a real, documented methodology with zero digital tooling
- **Query:** OpenAlex works API, `caderneta agroecologica mulheres agricultoras` + Google Play BR search `caderneta agroecologica`
- **Source:** OpenAlex API / Revista de Educação Popular (UFU) | **URL:** https://doi.org/10.14393/rep-2022-62077 | **Date:** 2022 (record retrieved 2026-07-27) | VERIFIED FETCH (OpenAlex returned **17 works**; I also opened the article landing page)
- **Paraphrase:** The "caderneta agroecológica" is an established field instrument in which rural women record everything their backyard/plot produces — consumed, given away, bartered, sold — to make invisible female farm economics visible; documented in use across the Bahia semi-arid Pró-Semiárido programme, Minas Gerais Zona da Mata and the Nordeste II region.
- **Points to:** An offline weekly production notebook modelled exactly on the paper caderneta: product list with regional names, unit conversions (lata, prato, molho, cambada), destination categories (consumo / troca / doação / venda), weekly cycle, and end-of-cycle totals — with everything staying on the phone.
- **Offline necessity:** Strong on two counts: the recording moment is in the quintal/roça in the semi-arid interior where there is no coverage, **and** the data is household income detail that women in these programmes have concrete reasons not to upload anywhere.
- **Audience size:** unknown as a headcount — the literature describes programme-level cohorts (Pró-Semiárido/BA, CTA-ZM/MG, Nordeste II) rather than a national total. Directionally this looks like a low-thousands-to-low-tens-of-thousands community, which is the right band, but **I could not verify a number and will not invent one.**
- **Data/licence note:** Almost no bundled data required — the value is the domain-correct data model plus regional unit vocabulary. Anything reused from a specific NGO's caderneta layout needs permission; the underlying method is described in openly-licensed academic literature.
- **Competitive check (VERIFIED FETCH):** Google Play BR search `caderneta agroecologica` returns **no such app** — only generic agri products (Agrio, xFarm, Plantix, AgroBEET, `br.embrapa.pisciculturacerta`). iTunes BR `caderneta agroecologica` → `resultCount=0`.

### Brazil — rural drinking-water operators (chlorine/turbidity logs): open field, no listing found
- **Query:** Google Play BR search `cloro residual analise agua tratamento`
- **Source:** Google Play (Brazil storefront) results | **URL:** https://play.google.com/store/search?q=cloro%20residual%20analise%20agua%20tratamento&c=apps&hl=pt_BR&gl=BR | **Date:** retrieved 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The Brazilian store has utility-side and consumer-side water apps (`br.gov.ana.aguasesgotos`, `br.gov.ana.declaraagua`, Sabesp, Aegea, plus a pile of "drink more water" reminders) but nothing for the person who walks to a small rural treatment unit and writes down residual chlorine, pH and turbidity.
- **Points to:** An offline operator logbook for small/rural water systems: per-point sampling schedule, residual-chlorine and turbidity entry with in-range/out-of-range logic against the national potability standard, monthly summary export.
- **Offline necessity:** Moderate-to-strong — pump houses, reservoirs and rural treatment skids are exactly the "basement/machine room, deep rural" case in the brief.
- **Audience size:** unknown; not verified. Indonesian mirror of the same gap: Play ID search `pamsimas kpspams air minum desa` also returned no village water-committee field app (only PDAM/meter apps and hydration trackers) — VERIFIED FETCH.
- **Data/licence note:** Potability parameter limits come from the Brazilian Ministry of Health potability annex (official act, likely reusable) — but this lead is **Speculative** until I find real operator complaints, and it risks reading as a generic logger.

### Brazil — meliponicultura (native stingless bees): genuinely *different* from the rejected beekeeping lead, but already contested
- **Query:** iTunes Search API `meliponicultura abelhas nativas` (BR) + Google Play BR search `meliponicultura abelha sem ferrao`
- **Source:** Apple App Store BR / Google Play BR | **URL:** https://apps.apple.com/br/app/beeapp-abelha-sem-ferr%C3%A3o/id6782711253 | **Date:** retrieved 2026-07-27 | VERIFIED FETCH (iTunes API record: 0 ratings; Play listing `br.app.bee.beeapp` shows only **5+ downloads**)
- **Paraphrase:** Brazilian stingless-bee keeping already has at least four domestic apps — BeeApp (`br.app.bee.beeapp`), MeliponApp (`com.cleios.meliponapp`), IFBee (`com.programaandroid.ifbee`) and `app.beeh` — but all are tiny/new, so the niche is occupied rather than solved.
- **Points to:** If pursued at all, the differentiator would be the part none of them do: an offline **species identification key** for Brazilian Meliponini plus the SisFauna/IBAMA legal-keeping rules per species and state.
- **Offline necessity:** Moderate — meliponários are in quintais and rural properties, often without coverage.
- **Audience size:** unknown.
- **Data/licence note:** Species data would come from taxonomic literature and Flora/Fauna do Brasil-style open datasets; must be checked. **Given the brief explicitly lists beekeeping hive logs as a dead end, I am flagging this Weak and not recommending it.**

---

## Rejected on contact (already served — do not spend time here)
- **Brazil, ACS / e-SUS Território** — the Ministry of Health's own Android app for community health agents already has an offline mode and is described as used by 100k+ professionals. *(unverified - from search snippet only; source: https://manualdaweb.com/aplicativos/e-sus-territorio/ and https://sisaps.saude.gov.br/sistemas/esusaps/docs/manual/TERRITORIO/territorio_02/)*
- **Indonesia, kader posyandu** — KaderKita (https://www.kaderkita.com/) and the Ministry's ASIK both advertise offline posyandu capture with later auto-upload. *(unverified - from search snippet only)*
- **Brazil, caminhoneiros / diário de bordo** — at least four commercial products already advertise offline journey capture: diarioabordo.com.br, https://diario.app/, https://www.borealbr.com.br/, https://www.g2trucker.com.br/. *(unverified - from search snippet only, via https://lite.duckduckgo.com/lite/?q=aplicativo+offline+caminhoneiro+jornada+di%C3%A1rio+de+bordo+sem+sinal+estrada, VERIFIED FETCH of the results page)*
- **Brazil, agrotóxico carência / AGROFIT** — Compêndio Agrícola (AgroReceita) and AgroApp already ship AGROFIT-derived data offline. *(unverified - from search snippet only)*
- **Brazil, Normas Regulamentadoras (NR) readers** — iTunes BR returns five live apps (Consultor NR, SST - Central | NR, NHO e CA, SegTrab Pocket, GNRx - Auditoria, Escola SST Online). *(VERIFIED FETCH via iTunes Search API)*
- **Indonesia, penyuluh pertanian reporting** — Sahabat Penyuluh, Sisuluh and Ruang Penyuluh already exist, though all appear to be web/server-first; a purely offline competitor is still arguable but the space is crowded. *(unverified - from search snippet only)*

---

## no evidence found
Queries that returned nothing usable, or that I could not complete because of blocking:

- `"aplicativo que funciona sem internet" roça sem sinal fórum` (WebSearch) — returned only mesh-messenger listicles and travel blogs; **no evidence found** of a rural-Brazil occupational need.
- `aplikasi offline tanpa kuota petani nelayan forum` (WebSearch) — returned SEO game-listicles ("game farming offline tanpa kuota") and a 2015 Kominfo press release; **no evidence found**.
- `kaskus.co.id aplikasi offline "tanpa internet" butuh rekomendasi kerja lapangan` (WebSearch) — returned only POS/attendance vendor blogs, zero Kaskus threads; **no evidence found**. Kaskus appears effectively unreachable through the search paths available here.
- `"guru" "daerah 3T" aplikasi offline "tidak ada sinyal" administrasi e-rapor kendala` (WebSearch) — all results were e-Rapor install/troubleshooting SEO pages about Dapodik sync, not about signal-less teaching; **no evidence found** of a distinct offline teacher-tool niche.
- `"pengamat organisme pengganggu tumbuhan" jumlah POPT se-Indonesia orang` (DDG Lite) — literally "No results found"; **no evidence found** for a national POPT headcount.
- `"caderneta agroecológica" quantas mulheres agricultoras registro produção quintal` (Brave) and `"caderneta agroecológica" mulheres agricultoras número de cadernetas preenchidas` (DDG Lite) — Brave returned 0 parsed results then 429; DDG served a CAPTCHA. **No evidence found** for a participant headcount.
- `aplikasi "tanpa kuota" keluhan "harus online" ulasan pengguna aplikasi pemerintah` (Brave) — 0 results before rate-limiting. I could not surface first-person Indonesian review complaints; **no evidence found**. (Google Play review text is not rendered in the server-side HTML I can fetch, and the Apple ID storefront has almost no Indonesian-language niche apps to read reviews of.)
- `"agente indígena de saúde" aldeia sem internet registro SIASI papel dificuldade sistema` (WebSearch, then DDG Lite) — DDG returned only legislative-status articles about regulating the AIS/AISAN professions (e.g. https://www.camara.leg.br/proposicoesWeb/prop_mostrarintegra?codteor=1775010, unverified). **No evidence found** about their field data-capture workflow or headcount, because gov.br/FUNAI/SESAI return 401/403 from this environment. This remains an *unproven but attractive* lead: a small, nameable, absolutely-no-signal workforce.
- Google Play ID search `POPT pengamatan OPT pelaporan` — **no Indonesian POPT field app exists** in the store (results were foreign scouting/plant-ID apps). Recorded as a *gap*, not a dead end.
- Google Play ID search `identifikasi hama penyakit padi` — no offline Indonesian-language rice pest key; only cloud AI plant-ID apps and low-quality content apps. Recorded as a *gap*.
- Apple iTunes Search API `pengamatan hama OPT` (ID storefront) — `resultCount=0`.
- Mojeek, Ecosia, Startpage, Bing (curl and WebFetch), and public SearxNG instances (searx.tiekoetter.com, search.inetol.net, priv.au, opnxng.com, baresearch.org, searxng.site, search.hbubli.cc, searx.perennialte.ch, northboot.xyz) — all 403/429/JS-only. Not usable from here.
- `https://wiki.isikhnas.com/w/Farmer_Registration_and_Animal_ID` — HTTP 500 on fetch; content **unverified**.
- `https://tanamanpangan.pertanian.go.id/detil-konten/iptek/155`, `https://uptptph.kalbarprov.go.id/artikel/POPT_Keren`, `https://www.gov.br/funai/...` — 401/403 to both curl and WebFetch; not readable.

## Where language itself is the competitive gap
1. **Indonesian rice/palawija pest identification and scouting.** Every result in the Play ID search was an English-first cloud AI plant doctor. An offline, Indonesian-language, Kementan-methodology-faithful pest key has no incumbent.
2. **Indonesian tide/sea data for small-boat fishers.** The store is full of English tide apps built for US/EU recreational boaters; the one Indonesian entrant markets "hemat kuota" but still needs to have been online.
3. **Brazilian fishing legality.** The rules are per-state, in Portuguese, in normative instructions — an English-language global fishing app structurally cannot carry them, and no Brazilian one has been built offline.
4. **Brazilian caderneta agroecológica.** The vocabulary itself (lata, molho, cambada, quintal, troca) is the product; nothing generic can substitute.
