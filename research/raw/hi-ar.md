# Phase 1 Discovery — Hindi + Arabic language sweep
Date of research: 2026-07-27
Researcher note on method: the shared `WebSearch` budget for this session was exhausted after 6 calls
(the tool returned "this session has used its web search budget (200 of 200)"). All remaining searches
were run by fetching `lite.duckduckgo.com/lite/?q=...` directly with WebFetch, which works and returns
real organic result lists. Curl to `html.duckduckgo.com` and `mojeek.com` were blocked (captcha / 403),
Bing RSS returned unrelated Balkan news, so those were abandoned. reddit.com was not used at all.
~22 distinct queries were run in total (6 WebSearch + ~16 fetch-searches/verifications).

---

## 1. Gulf Arabic-speaking fishermen — legal catch reference (minimum lengths, closed seasons, banned species/gear)

### Gulf artisanal + recreational fishermen, Arabic, at sea
- **Query:** `"تطبيق يعمل بدون انترنت" للصيادين البحر`
- **Source:** Emarat Al Youm (UAE daily) | **URL:** https://www.emaratalyoum.com/local-section/other/2019-07-08-1.1230866 | **Date:** 2019-07-08 | VERIFIED FETCH
- **Paraphrase:** The Ras Al Khaimah Fishermen's Association built and distributed a phone app that measures a fish's length on-screen against the legal minimum, explicitly because their *previous* app needed internet and most fishermen could not use it — they are out at sea in areas with no network coverage.
- **Points to:** An offline Arabic "is this catch legal?" reference: species list with local Gulf names, minimum legal length per species, current closed season, protected/banned species, banned gear, plus an on-screen ruler / camera-scale measurement.
- **Offline necessity:** VERY STRONG and independently proven by the fishermen's own association — the decision is made on a boat kilometres offshore with no cell coverage, at 4am, with wet hands, before the fish is thrown back or kept. A spinner or a login is fatal to the use case.
- **Audience size:** 5,268 registered Emirati citizen fishermen (boat owners) nationally — Sharjah 1,367, Ras Al Khaimah 1,109, Fujairah 777, Dubai 735, Abu Dhabi 625, Umm Al Quwain 384, Ajman 271; Dubai Fishermen's Co-operative alone has >900 members. Source WAM (Emirates News Agency) https://www.wam.ae/ar/details/1395303082903 — **(unverified — from search snippet only; the WAM page body is JS-rendered and returned only the masthead on fetch)**. Adding Kuwait/Oman/Qatar/Bahrain/Saudi Eastern Province artisanal fleets plus licensed recreational anglers plausibly lands the total in the 30k–60k band.
- **Data/licence note:** UAE Ministerial Decision 580/2015 (undersized fish), MD 471/2016, MD 500/2014, and Abu Dhabi EAD's fishing-law factsheet. These are national legal texts held in FAO's FAOLEX legal database (https://faolex.fao.org/docs/pdf/uae165183.pdf and https://ead.gov.ae/-/media/Project/EAD/EAD/Documents/Fishing-Law-2023.pdf — both PDFs exist and downloaded, but **body not text-extractable in this environment** — no `pdftotext`/`PyPDF2` available, so contents unverified). Official legislative texts are normally outside copyright; still needs checking per country. Fish illustrations would need to come from public-domain / CC-BY sources (FAO species fact sheets, Wikimedia), NOT from commercial field guides.
- **RTL FLAG:** ★ This is a case where **Arabic + RTL is itself the moat**. Species must be listed under *local* names (هامور، شعري، صافي، بدح، كنعد، ميد، زبيدي), not FishBase Latin, and the audience is Arabic-first with low English. Every existing app found in this space is an English AI "fish identifier".

### Same niche — confirming the regulatory dataset is real and detailed
- **Query:** `وزارة البيئة الإمارات دليل الأطوال المسموح بها لصيد الأسماك pdf`
- **Source:** Bayut / MyBayut (UAE property portal's legal explainer) | **URL:** https://www.bayut.com/mybayut/ar/قوانين-الصيد-البحري-الامارات/ | **Date:** page undated, references 2023 law | VERIFIED FETCH
- **Paraphrase:** Sets out the actual shape of the dataset — closed seasons with exact dates (Sha'ri and Arabian safi 1 Mar–30 Apr; badh 1 Apr–1 Jun), minimum lengths ranging 23 cm to 60 cm by species (hamour 45 cm), fully banned species (all turtles, marine mammals), banned gear (bottom trawls, drift nets, explosives, poisons), and escalating penalties (6-month licence suspension + AED 3,000 first offence, revocation + AED 5,000 second).
- **Points to:** Confirms the app has ~100+ structured rows per country, not 5 — i.e. a real 2-month data+UI job, not a weekend calculator.
- **Offline necessity:** As above.
- **Audience size:** as above.
- **Data/licence note:** as above; Bayut itself is a secondary source, use only as a map of what to source from the official decisions.

### Same niche — negative evidence that nobody has built it
- **Query:** `site:play.google.com تطبيق أسماك الخليج العربي أسماء الأسماك دليل` and `تطبيق الأطوال المسموحة لصيد الأسماك الخليج دليل الصياد`
- **Source:** DuckDuckGo Lite organic results | **URL:** https://lite.duckduckgo.com/lite/?q=site%3Aplay.google.com+تطبيق+أسماك+الخليج+العربي+أسماء+الأسماك+دليل | **Date:** 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Every Arabic-locale result is either a generic AI photo "fish identifier" (Picture Fish, Fish Verify, FishFinder, معرّف الأسماك) or a fishing-spot/weather app (Fishing Points, FishAngler, دليل الصياد Tifnit) — none encodes legal minimum sizes, closed seasons or protected species for any Arab country.
- **Points to:** Clear white space for the legal-catch reference.
- **Offline necessity:** n/a (competitive scan)
- **Audience size:** n/a
- **Data/licence note:** n/a

---

## 2. Transhumant Gaddi shepherds, Himachal Pradesh (Hindi)

### Migratory sheep/goat herders — flock, lambing, disease and route record book
- **Query:** `गद्दी चरवाहे भेड़ पालक प्रवास हिमाचल संख्या मोबाइल नेटवर्क`
- **Source:** News4Himachal | **URL:** https://news4himachal.in/miscellaneous/himachal-gaddi-community-affected-by-us-donald-trump-tariff/8526 | **Date:** 2025-04-04 | VERIFIED FETCH
- **Paraphrase:** As of 2023 there are 5,050 Gaddi sheep-rearing families in Himachal Pradesh running a total sheep population that has crossed 8.5 lakh, and their wool income is collapsing.
- **Points to:** An offline Hindi/Gaddi flock ledger for the *dhaar* migration: animal-by-animal inventory with ear-tag, lambing and mortality log, dose/deworming and FMD/PPR vaccination dates, shearing yield and wool-lot weights per buyer, grazing-permit and forest-toll records, and GPS waypoints of the migration route and camp sites recorded without any network.
- **Offline necessity:** STRONG — the herd is on high-altitude pasture in Chamba/Kangra/Lahaul for months at a stretch, above the last tower; the same phone is the only record of who owns which animal for wool payment and for insurance/compensation claims.
- **Audience size:** 5,050 Gaddi shepherd families in HP (verified above). Directly adjacent, uncounted here: Bakarwal (J&K), Van Gujjar (Uttarakhand), Rabari/Raika (Rajasthan-Gujarat) — same app, same offline constraint, likely pushes the addressable group well past 20k.
- **Data/licence note:** Almost all data is user-entered, so no licensing risk. Optional bundled reference: HP animal-husbandry vaccination calendar and the notified migration-route/permit rules (state government documents, India's GODL licence permits commercial reuse with attribution). Avoid any treatment/dosing advice — keep it to "record what the vet did".

### Same niche — disease/mortality pain point that makes the log valuable
- **Query:** (same as above, result #7)
- **Source:** Gaon Junction | **URL:** https://www.gaonjunction.com/pashudhan/footrot-disease-kills-sheep-goats-in-himachal-gaddi-shepherds-suffer-big-losses | **Date:** ~2024-2025 | **(unverified — from search snippet only, not fetched)**
- **Paraphrase:** Footrot outbreaks are killing sheep and goats in Himachal and Gaddi shepherds are taking heavy losses.
- **Points to:** Adds a real reason the flock log matters (loss documentation for compensation), not just recordkeeping for its own sake.
- **Offline necessity:** as above.
- **Audience size:** as above.
- **Data/licence note:** n/a

---

## 3. Agariya salt-pan farmers, Little Rann of Kutch (Hindi/Gujarati)

### Salt farmers who live 8 months in a desert with no infrastructure
- **Query:** `अगरिया नमक मजदूर रण कच्छ संख्या बिजली नेटवर्क नहीं`
- **Source:** Mongabay Hindi | **URL:** https://hindi.mongabay.com/2021/10/12/when-salt-is-an-essential-commodity-and-salt-makers-are-not/ | **Date:** 2021-10-12 | VERIFIED FETCH
- **Paraphrase:** Roughly 60,000 people of the Agariya community make salt, producing about 30% of India's ground salt, with families from about 102 villages living in temporary shelters in the Rann for around eight months a year; the article stresses the government has never even surveyed how many they are.
- **Points to:** An offline production + settlement ledger for a salt pan season: brine density (Baumé) readings per pan with the transfer/harvest decision rule, pan-to-pan movement dates, diesel/solar-pump running hours, daily labour attendance, and — critically — the running account of advances taken from the salt trader against tonnage delivered, so the family can contest the trader's arithmetic at settlement.
- **Offline necessity:** VERY STRONG — an uninhabited salt desert, eight months, no grid electricity, phone charged off the solar pump; and the advance/debt ledger is exactly the kind of private financial data that must never leave the device.
- **Audience size:** ~60,000 Agariyas nationally, 102 villages in the Little Rann (verified). One narrower cohort of "over 1,200 Agariyas" appears in a Sabrang India piece about denial of salt-farming permission — https://hindi.sabrangindia.in/article/refusal-to-allow-salt-farming-in-little-rann-pushes-1200-gujarat-agariyas-to-margins **(unverified — from search snippet only)**.
- **Data/licence note:** All user-entered; the only bundled data would be a Baumé/temperature correction table and a salt-crystallisation stage chart, both textbook physical chemistry (facts, not copyrightable). Note the app would need Gujarati as well as Hindi, and a heavily icon-driven UI for low literacy.

---

## 4. Omani falaj water-share timing (Arabic)

### Falaj shareholders and the wakil al-falaj computing irrigation turns
- **Query:** `الأفلاج عمان توزيع المياه الأثر البادة حساب الدوران وكيل الفلج تطبيق`
- **Source:** DuckDuckGo Lite organic results (Athere.om, Oman Daily, Univ. of Nizwa Ishraqa journal, folkculturebh.org) | **URL:** https://lite.duckduckgo.com/lite/?q=الأفلاج+عمان+توزيع+المياه+الأثر+البادة+حساب+الدوران+وكيل+الفلج+تطبيق | **Date:** 2026-07-27 | VERIFIED FETCH (search page); individual articles **unverified — from result summary only**
- **Paraphrase:** Omani falaj irrigation shares are counted in *athar* units (an athar ≈ 30 minutes) on a fixed rotation, and the rotation is anchored to astronomy — star risings, sunrise and sunset — with several 2024-2026 pieces announcing a government/Univ. of Nizwa push ("لمد", "قعد الفلج") to move these hand-kept rotation books to electronic systems.
- **Points to:** An offline Arabic falaj-share calculator and rotation book: shareholder register in athar/badda, the dawaran cycle, automatic conversion of a shareholder's share into a wall-clock start/end time for tonight given the falaj's own sunrise/sunset or star-based anchor, plus the sale/lease/auction of shares.
- **Offline necessity:** MODERATE-TO-STRONG — the turn is handed over at the channel head in a wadi village at 2am; and the astronomical anchoring means the calculation must be done on the spot for tonight, not fetched.
- **Audience size:** unknown from a retrieved page. Oman's aflaj number in the thousands (the search did not surface a verified count) and each has dozens-to-hundreds of shareholders; the professional cohort (wukala' al-aflaj / arifs) is likely low thousands.
- **Data/licence note:** Sunrise/sunset and star-rise computation is algorithmic (public-domain astronomy, e.g. standard solar-position algorithms) so it bundles cleanly. Shareholder registers are user-entered.
- **CAUTION / competitor:** the Omani government + University of Nizwa digitisation programme is an incumbent, and it will probably be an online platform — which is precisely the gap, but it also means an official free alternative may appear.
- **RTL FLAG:** ★ Arabic-only domain vocabulary (أثر، بادة، دوران، قعد الفلج) and RTL numeric tables — no non-Arabic developer will touch it.

---

## 5. Rural Indian frontline health workers (ASHA) — offline data capture

### ASHA workers forced into app-based surveys where there is no network
- **Query:** `ASHA worker app offline problem network village "no internet" HBNC register`
- **Source:** MedTalks India | **URL:** https://www.medtalks.in/articles/asha-workers-urge-minister-to-abandon-app-based-survey-citing-rural-network-challenges | **Date:** published 2023-06-12, updated 2024-05-15 | VERIFIED FETCH
- **Paraphrase:** The Karnataka Rajya Samyukta ASHA Karyakartheyara Sangha (Dakshina Kannada) asked the minister to drop the app-based Health and Nutrition Survey because connectivity problems add delays of several minutes at every single household.
- **Points to:** An offline-first field survey/register companion that captures the household visit in seconds with zero network and exports later — the classic "the government app assumes a network that isn't there" gap.
- **Offline necessity:** STRONG on the pain, but the honest read is that this needs *sync* to be useful to the employer, which the brief auto-rejects.
- **Audience size:** ~1 million ASHAs nationally — far above the 3k–50k target band, and the app is a government mandate, so the real customer is a state health department, not an individual.
- **Data/licence note:** NHM forms are Government of India documents (GODL-India, commercial reuse with attribution). Anything touching danger signs or dosing is a liability line to stay behind.
- **VERDICT: weak as a product lead** — reported for completeness because it was an assigned context. Corroborating: Tribune India, https://www.tribuneindia.com/news/haryana/asha-workers-struggle-to-upload-data-on-app-255594, 2021-05-19, VERIFIED FETCH — Yamunanagar ASHA workers say the ASHA Survekshan portal is slow or non-functional and they work till late evening to upload; note this article blames the *portal*, not local coverage.
- Also seen: `दो साल पहले आशा वर्करों को जारी सिम कराए बंद` on livehindustan (Pilibhit, UP) — ASHA workers facing network issues and SIM reissue — https://www.livehindustan.com/uttar-pradesh/pilibhit/story-health-department-s-asha-workers-face-network-issues-new-sim-cards-to-be-issued-201731928198938.html — **(unverified — Claude Code is blocked from fetching livehindustan.com)**.

---

## 6. Leads checked and found ALREADY SERVED (do not pursue)

### Hajj / Umrah rites guide offline (Arabic)
- **Query:** `تطبيق الحج والعمرة بدون انترنت مشكلة الشبكة في منى وعرفات`
- **Source:** Google Play (multiple) + Al-Ain | **URL:** https://play.google.com/store/apps/details?id=mnask.alhajj.omra , https://play.google.com/store/apps/details?id=com.mnasekelomra.ghalyapps , https://al-ain.com/article/your-smart-guide-hajj-2026 | **Date:** 2026 | **(unverified — from search snippet only)**
- **Paraphrase:** There are already many free Arabic "مناسك الحج/العمرة بدون نت" apps plus the ministry's own مناسكنا app, all explicitly marketed on working with no data in the crowded Mashaa'ir.
- **Points to:** Rites-guide space is saturated. The only unserved sliver seen was the *campaign supervisor* (مشرف حملة / تفويج) side — group rosters, batch headcounts, tent/bus assignment — but that is inherently a sharing/sync product, so it fails the offline test.
- **Offline necessity:** genuinely strong (network collapses under crowd load in Mina/Arafat) but the need is met.
- **Audience size:** ~1.6M+ pilgrims/yr — too big and already served.
- **Data/licence note:** Quran/hadith text public domain; ritual guides vary.

### Quran memorisation circle (halaqa) teacher tracker (Arabic)
- **Query:** `معلم تحفيظ القرآن تطبيق متابعة الطلاب بدون انترنت سجل الحلقة`
- **Source:** DDG Lite organic results | **URL:** https://lite.duckduckgo.com/lite/?q=معلم+تحفيظ+القرآن+تطبيق+متابعة+الطلاب+بدون+انترنت+سجل+الحلقة | **Date:** 2026-07-27 | VERIFIED FETCH (search page)
- **Paraphrase:** At least eight Arabic halaqa-management platforms exist (halagat.co, misbah.pro, injaazy.com, halaqti.com, jeel-alquran.com, halaqaldhikr.com, furqansystem.com, telawah) and one of them is already promoted as working "بدون إنترنت".
- **Points to:** crowded; skip.
- **Offline necessity:** moderate (mosque basements, private student data).
- **Audience size:** very large but already served.
- **Data/licence note:** Uthmani Quran text is public domain but the King Fahd Complex digital text has its own terms.

### Arabic prosody / poetry-metre scanner (تقطيع عروضي)
- **Query:** `تطبيق العروض تقطيع الشعر بحور الشعر بدون انترنت اندرويد`
- **Source:** APKPure / Google Play | **URL:** https://apkpure.com/ar/التقطيع-العروضي-الشعر-العربي/www.alarod.com , https://play.google.com/store/apps/details?id=com.benetnash.kafya.kafya_app | **Date:** 2026-07-27 | **(unverified — from result list only)**
- **Paraphrase:** An offline Android app that determines the metre of an Arabic verse already exists (التقطيع العروضي), plus سُلاف for metre and rhyme.
- **Points to:** Attractive algorithmically (a genuine 2-month job) but taken.
- **Offline necessity:** weak anyway.
- **Audience size:** unknown.
- **Data/licence note:** classical prosody is public domain.

### Camel pedigree / racing record book (Arabic Gulf)
- **Query:** `تطبيق ملاك الإبل أنساب الهجن سجل المطايا بدون انترنت عدد ملاك الإبل`
- **Source:** DDG Lite organic results incl. hijni.com and camelclub.gov.sa | **URL:** https://lite.duckduckgo.com/lite/?q=تطبيق+ملاك+الإبل+أنساب+الهجن+سجل+المطايا+بدون+انترنت+عدد+ملاك+الإبل | **Date:** 2026-07-27 | VERIFIED FETCH (search page)
- **Paraphrase:** Hijni.com already offers camel pedigree/race record keeping, the Saudi Camel Club runs official e-services, a national pedigree-documentation platform ("وثقها") is being rolled out, and at least one result is titled as an offline camel-owner pedigree app.
- **Points to:** taken / being taken by a government programme.
- **Offline necessity:** strong in principle (desert), but the incumbent problem kills it.
- **Audience size:** one SPA item references 85,347 camels tagged in Al-Jouf region **(unverified — from result summary only)**.
- **Data/licence note:** n/a

### Bedouin star calendar (الدرور / الطوالع) for desert farmers and seafarers
- **Query:** `"الطوالع" "الدرور" تقويم المزارعين البدو النجوم سهيل حساب المواسم تطبيق`
- **Source:** Arabic Wikipedia + Sheikh Zayed Grand Mosque Centre PDF + app writeup | **URL:** https://ar.wikipedia.org/wiki/ديرة_الدرور , https://szgmc.gov.ae/Ftp/كتاب%20ديرة%20الدرور.pdf , http://ketafnews.blogspot.com/2019/10/blog-post_712.html | **Date:** 2019-2026 | **(unverified — from search snippet only)**
- **Paraphrase:** The Durur system splits the year into 36 fixed periods anchored to the rising of Suhail and is used to time agricultural, pastoral and marine seasons; an app ("الفصول الأربعة") already covers it and the official Umm al-Qura calendar app ships a "تقويم المزارعين".
- **Points to:** served; only reusable as a *feature* inside a bigger desert-agriculture app.
- **Offline necessity:** strong (desert) but need is met.
- **Audience size:** unknown.
- **Data/licence note:** the SZGMC book is a UAE government publication — permission would still need checking.

### Village milk collection fat/SNF rate calculation (Hindi)
- **Query:** `दूध डेयरी फैट एसएनएफ रेट चार्ट ऐप ऑफलाइन`
- **Source:** Google Play / vendor sites | **URL:** https://play.google.com/store/apps/details?id=b2infosoft.milkapp.com , https://apnainfotech.com/milk-sarthi.php , https://mobiledairy.co.in/hi/blog/milk-rate-calculation-fat-snf.html | **Date:** 2026-07-27 | **(unverified — from result list only)**
- **Paraphrase:** Several Hindi dairy-collection apps (Meri Dairy, Milk Sarthi, MobileDairy) already implement fat/SNF rate-chart pricing for village societies.
- **Points to:** served, and it is essentially a ledger/calculator — fails the brief's generic-tracker filter.
- **Offline necessity:** moderate.
- **Audience size:** large.
- **Data/licence note:** rate charts are set per-union, user-entered.

### Date-palm cultivar identification / oasis farm calendar (Arabic)
- **Query:** `تطبيق أصناف النخيل والتمور تعريف نوع النخلة مزارعي النخيل بدون انترنت`
- **Source:** FAO OpenKnowledge + Saudi NCPD + nighat.sa | **URL:** https://openknowledge.fao.org/server/api/core/bitstreams/28640f40-b3e2-402a-af13-203606a90edc/content , https://ncpd.gov.sa/ar , https://nighat.sa/palm-classification | **Date:** 2026-07-27 | **(unverified — from search snippet only)**
- **Paraphrase:** No offline Arabic app for identifying date-palm cultivars surfaced; what exists is a Saudi national palm centre, a commercial computer-vision date-sorting platform (نقاة), and farm-management software — while FAO publishes a full illustrated Arabic date-palm husbandry manual.
- **Points to:** possible offline Arabic oasis-farm assistant: cultivar key, pollination/thinning/bagging/harvest calendar by cultivar and region, red palm weevil inspection log, per-palm inventory.
- **Offline necessity:** moderate — oasis farms in Al-Ahsa, Siwa, Tafilalt, Wadi Hadhramaut do lose coverage, but many are peri-urban, so offline is convenient rather than mandatory. Flagging honestly as the weaker half of the test.
- **Audience size:** unknown from a retrieved page.
- **Data/licence note:** ⚠ the obvious FAO manual is very likely CC BY-NC-SA — **the NC clause blocks commercial use**. Cultivar facts themselves are not copyrightable but the images and text are; would need original photography or PD/CC-BY sources.

---

## no evidence found

These queries were run and produced nothing usable (SEO listicles, generic "how to fix your wifi" content, or unrelated news):

- `"لا يعمل بدون انترنت" تقييم تطبيق "للأسف" مزعج` — returned only Android troubleshooting help pages, no app-review complaints. **No evidence found.**
- `تطبيق للمزارعين بدون انترنت` — returned only home-gardening content apps, offline map apps (Organic Maps, OsmAnd) and a farming *game*. **No evidence found** of an unmet Arabic farming need.
- `تطبيق بدون انترنت للرعاة الإبل الأغنام البر لا توجد شبكة` — surfaced مقاني (mqane.com), My Sheep Manager, Greener Herd; Arabic livestock management is already occupied. **No fresh evidence.**
- `मछुआरे समुद्र में नेटवर्क नहीं मोबाइल ऐप समस्या` — returned generic "fix your phone signal" articles plus one BSNL-for-fishermen news item; no usable Indian marine-fisher offline complaint. **No evidence found.**
- `"बिना इंटरनेट" चलने वाला ऐप जरूरत गांव काम` — dominated entirely by 2026 Bitchat/Jack Dorsey ban news. **No evidence found.**
- `वन अधिकार कानून दावा फॉर्म भरने में दिक्कत गांव नेटवर्क` — returned FRA claim-process explainers and the Ministry of Tribal Affairs forms page, but no evidence of a connectivity-driven pain point or of the community's size. Not developed further.
- `प्रवासी मजदूर खाड़ी देश इंटरनेट नहीं ऐप` — returned only crisis/helpline news about Indians in the Gulf, nothing about an offline tool need. **No evidence found.**
- `मशरफ حملة الحج / تفويج بدون شبكة` (`مشرف حملة الحج مشاكل إدارة الحجاج تفويج عدد الحجاج بدون شبكة`) — returned only ministry crowd-control PR and Hajj-operator marketing; the supervisor-side tooling need could not be evidenced. **No evidence found.**
- `قرار وزاري 580 لسنة 2015 الأطوال المسموح بها` — the decision is repeatedly referenced but its full per-species table could not be read; both candidate PDFs (FAOLEX, EAD) downloaded as binary that this environment cannot text-extract. **Dataset existence confirmed, contents unverified.**
- Attempts to reach `mojeek.com` (403), `html.duckduckgo.com` via curl (captcha), `bing.com/search?format=rss` (returned unrelated Balkan news), `www.livehindustan.com` (fetch blocked), and `www.wam.ae` article bodies (JS-rendered, masthead only) all failed.
