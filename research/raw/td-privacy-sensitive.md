# TD — Privacy-Sensitive Groups Who Refuse Cloud Tools
Phase 1 discovery, top-down. Run date: 2026-07-27.

## Environment constraints hit during this run (read before judging coverage)
- reddit.com blocked (per brief) — not attempted.
- The session's **WebSearch budget was exhausted at 200/200 after my 10th search**. Everything after that was done with WebFetch on known URLs plus public JSON APIs (iTunes Search/Lookup, iTunes customer-reviews RSS, Discourse `search.json`, hn.algolia.com).
- Fallback search engines were all blocked: Bing via WebFetch returned unrelated junk; DuckDuckGo HTML/lite returned HTTP 202 anti-bot; Mojeek gave one page then 403 "automated queries"; searx.be / priv.au / search.inetol.net / searxng.site returned captcha / 429 / 403; Ecosia 403; Brave 429; Startpage anti-bot; Marginalia renders results in JS.
- `gh search repos` and `gh api search/repositories` returned empty for every query (no network or no auth from this sandbox) — so no GitHub-issue evidence in this file.
- No PDF text extractor on this machine (`pdftotext` absent, PyObjC/Quartz absent), so the BACP GPiA065 PDF could not be read even though it downloaded.

---

### Solo private-practice therapists / counsellors building their own local-only note systems
- **Query:** `HIPAA client notes` (Discourse search API on forum.obsidian.md), after WebSearch `therapist private practice "offline" notes app "not use cloud" HIPAA EHR refuse`
- **Source:** Obsidian community forum (Discourse) | **URL:** https://forum.obsidian.md/t/61642 | **Date:** thread opened 2023-06-15, last reply 2025-07-11, 5,127 views, 13 posts | VERIFIED FETCH (pulled `/t/61642.json` and read post bodies)
- **Paraphrase:** A counsellor asks other mental-health professionals to critique a *locally stored* psychotherapy-notes system he built rather than use a commercial EHR; over two years other therapists join in, one saying it is "interesting to think about escaping commercial EHRs" and that with AI in the mix "the best way to counter this is to run the entire system offline," while flagging that HIPAA still expects an access audit trail and intrusion detection.
- **Points to:** An offline-only, account-free clinical **process-notes** app: per-client vault, session templates (intake battery, session note, treatment-plan review), fast client switching, an on-device tamper-evident access/audit log, local encryption with a real key, and print/PDF export for subpoena or transfer of care.
- **Offline necessity:** Psychotherapy process notes are the single most sensitive record class a clinician holds; these clinicians are explicitly refusing to put them on a vendor's server at all, and a locked-down local app is the only architecture that satisfies them. Not a "would be nice offline" case — the whole motivation is *never leaves the device*.
- **Audience size:** unknown exactly. Thread has 5,127 views; the sub-segment is "solo private-practice therapists who reject cloud EHRs", which is plausibly small but I could **not** verify a number (BACP and APA membership pages I fetched did not state one — see no-evidence section).
- **Data/licence note:** No bundled dataset needed. Note frameworks (SOAP/DAP/BIRP) are generic formats, not copyrighted content. Deliberately exclude any diagnostic criteria (DSM/ICD text is licensed) and any dosing/assessment scoring.

---

### Foster carers' statutory daily logs (England ≈56k carers)
- **Query:** `foster carer daily log recording requirement "daily diary" app data protection social worker sees notes number of foster carers UK Ofsted`
- **Source:** GOV.UK official statistics | **URL:** https://www.gov.uk/government/statistics/fostering-in-england-1-april-2024-to-31-march-2025/main-findings-fostering-in-england-1-april-2024-to-31-march-2025 | **Date:** published 2025 (data as at 31 March 2025) | VERIFIED FETCH
- **Paraphrase:** England had 56,345 approved mainstream foster carers across roughly 33,4xx approved mainstream fostering households as at 31 March 2025, down 1% year on year.
- **Supporting source 1:** Lika Family Fostering | **URL:** https://likafamilyfostering.co.uk/daily-logs-foster-carers/ | **Date:** 2021-01-06 | VERIFIED FETCH — spells out that the daily log must capture unexplained injuries, allegations, self-harm, missing episodes, family contact, school engagement, professional visits and consequences imposed, that logs are "regularly sent to the young person's social worker" and become part of the local authority's record, and warns "missing logs build up quickly."
- **Supporting source 2:** Rainbow Fostering Services | **URL:** https://www.rainbowfostering.com/blog/keeping-records-safely-gdpr-and-safeguarding-in-daily-notes | **Date:** 2024-08-05 | VERIFIED FETCH — tells carers never to move records over "Unsecured platforms (e.g. WhatsApp, personal email)", to keep paper in locked cabinets not shared with family, and to keep digital devices password-protected and encrypted.
- **Points to:** An offline foster-carer daily-log app: one timeline per child, structured safeguarding categories (injury / allegation / missing / contact / medical / education / achievement), quick voice-to-text at 11pm, photo evidence held inside the app sandbox rather than the camera roll, month-end export as a clean PDF/CSV the supervising social worker will accept, and hard local retention rules.
- **Offline necessity:** The content is UK GDPR *special category* data about a looked-after child, and agency policy explicitly forbids the consumer cloud channels carers would otherwise reach for. Logs also become evidence in allegation and care proceedings, so provenance matters more than sync. Carers write them late at night on a phone in a house shared with the child and birth family.
- **Audience size:** 56,345 approved mainstream foster carers in England alone (GOV.UK, 31 Mar 2025). Add Scotland/Wales/NI and Australia/NZ/Ireland and it stays comfortably inside the target band for a paid niche app.
- **Data/licence note:** No dataset strictly required. Optionally bundle the *Fostering Services: National Minimum Standards* and the Fostering Services (England) Regulations as an offline reference — UK Crown copyright under the Open Government Licence v3.0, which permits commercial reuse with attribution (verify per document).

---

### Domestic-abuse survivors keeping an incident log — the sector's own app has disappeared
- **Query:** `domestic violence survivor evidence log app abuser shared iCloud account sees photos safety planning NNEDV` (plus targeted fetches)
- **Source:** NNEDV Safety Net Project | **URL:** https://www.techsafety.org/documentationtips | **Date:** page carries a 2025 copyright and a "2025" sample log | VERIFIED FETCH
- **Paraphrase:** NNEDV's own guidance tells survivors to "keep a log of all incidents, even if you are not sure if you want to involve the police or courts," and warns that if the abuser discovers the survivor is documenting, the abuse may escalate.
- **Supporting source 1:** NNEDV Safety Net | **URL:** https://www.techsafety.org/choosingapps/ | **Date:** page undated, linked PDF filename shows 2017 | VERIFIED FETCH — warns that "even if you delete an app from your device, the history of the download will still exist on the device, within any backups or synced records, or your App Store/Google Play store account."
- **Supporting source 2 (gap evidence):** VAWnet event record for the NNEDV webinar introducing **DocuSAFE**, the free evidence-collection app for survivors, launched 2020-05-07 | **URL:** https://vawnet.org/events/understanding-and-using-docusafe-documentation-evidence-collection-app | **Date:** 2020-05-11 | VERIFIED FETCH.
- **Supporting source 3 (gap evidence):** DocuSAFE now appears withdrawn — https://www.techsafety.org/docusafe and https://www.techsafety.org/docusafe-privacy-policy both return **HTTP 404** (fetched 2026-07-27), the Google Play listing `org.nnedv.docusafe` returns 404, and an iTunes Search API query for "DocuSAFE" returns no matching app in the US store. VERIFIED (verified by absence — I confirmed the 404s and the empty store query myself; I could not find a retirement announcement, so treat "withdrawn" as inference).
- **Points to:** A disguised, account-free, 100% local incident log: timestamped entries with location optional, in-app camera whose photos never touch the camera roll, per-entry SHA hash + immutable created-at for evidential weight, PIN with a decoy/panic mode, and a one-tap "court chronology" PDF export the survivor can hand to an advocate or solicitor.
- **Offline necessity:** Strongest case in this whole file. The threat model *is* the cloud — the abuser frequently controls or shares the Apple/Google account, sees family-sharing purchase history, and can restore the survivor's backup. Anything with an account, a sync, or a purchase receipt leaks. It also has to work with no signal (rural, refuge, phone in airplane mode).
- **Audience size:** unknown. I could not verify a defensible number for "survivors actively keeping a documentation log" and will not guess. Distribution channel is nameable though: DV coalitions and advocate networks that already publish NNEDV's documentation guidance.
- **Data/licence note:** No bundled dataset. Do **not** bundle legal advice or jurisdiction-specific "what counts as evidence" text — that is the liability line. Pure capture + export only.

---

### Court and community interpreters' NDA-bound glossaries
- **Query:** `court interpreter glossary NDA confidential "offline" app terminology management` and `proz.com forum interpreters glossary app phone courtroom "no internet" terminology booth`
- **Source:** InterpretBank (the incumbent tool) | **URL:** https://www.interpretbank.com/ | **Date:** fetched 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** The category-leading interpreter terminology tool is a Windows/macOS desktop program at €349 perpetual or €9.99–15.99/month, and its mobile story is a **WebApp you sync to** — offline access on a phone exists only after syncing glossaries through their cloud.
- **Points to:** A phone-native, no-account offline glossary + assignment-prep notebook for public-service interpreters: per-assignment glossary vaults that can be destroyed when the job ends, sub-second bilingual lookup while someone is talking, a "add term I just fluffed" one-tap capture, numbers/names scratchpad, and per-assignment billing minutes. Explicitly no upload path.
- **Offline necessity:** Court holding areas, custody suites, tribunal basements, hospital interiors and prison visit rooms routinely have no signal, and many courts require phones in airplane mode or off. Separately, glossaries built from case bundles or client material are covered by NDAs/confidentiality codes, so syncing them to a vendor's server is a professional-conduct problem, not just a preference.
- **Audience size:** **unknown / not verified.** I tried NAJIT (`najit.org/about/` → 404), CCHI (homepage states certification since 2009 but publishes no count), and the US Courts federal interpreter page (no counts). Do not quote a number for this niche until a state-judiciary roster is counted directly.
- **Data/licence note:** Content is user-entered, so no licence risk in the core product. Optional bundled seed glossaries could come from US state/federal court publications (e.g. the 2024 Federal Court Interpreter Orientation Manual and Glossary on uscourts.gov, Tennessee AOC's legal terminology glossary, Florida courts' Consortium glossary) — US federal government works are public domain, state works need per-state checking. **Do not** bundle any paid terminology database.

---

### Home-birth midwives (CPMs) — offline labour observation log
- **Query:** `doula birth notes app "offline" hospital no signal basement labor documentation private practice` plus direct verification fetches
- **Source:** NARM (North American Registry of Midwives) | **URL:** https://narm.org/ | **Date:** figure stated as of 2024-10-15 | VERIFIED FETCH
- **Paraphrase:** NARM reports 4,772 Certified Professional Midwife credentials issued as of 15 October 2024 (up from 4,120 in Nov 2021) — a precisely nameable community right in the target size band.
- **Supporting source:** Mobile Doula (the closest incumbent) | **URL:** https://apps.apple.com/us/app/mobile-doula/id909265632 | **Date:** metadata pulled from the iTunes Lookup API 2026-07-27: v1.0.189, last updated 2026-05-21, 338 ratings, 4.75 avg | VERIFIED FETCH — its own description says it works with no internet but that "once an internet connection is detected all of your data will backup to the Mobile Doula servers", i.e. offline is a resilience feature layered on an account-based cloud product, not a privacy stance. It is also aimed at doulas' business admin, not at timed clinical observations.
- **Points to:** An offline labour/visit **observation log** for home-birth midwives and birth-centre staff: interval timers for fetal heart tone checks, one-tap vitals and contraction entries onto a scrolling timeline, freeform narrative, medications/supplies given, and a PDF export for the client's own record and for transfer-of-care handover.
- **Offline necessity:** Births happen in the client's house, often deep rural, sometimes over 24–48 hours; signal is unreliable and the midwife's hands are busy. Records are also legally exposed — CPM scope of practice is restricted or unlicensed in several US states and home-birth records get subpoenaed, so practitioners are structurally hostile to a vendor holding them.
- **Audience size:** 4,772 CPM credentials (NARM, Oct 2024), plus a larger pool of birth-centre and community midwives internationally.
- **Data/licence note:** No dataset. **Liability guardrail:** must be recording-only — no normal ranges, no partograph action lines, no alerts, no "consider transfer" logic. The moment it advises, it is a medical device.

---

### Correctional educators and prison-programme volunteers (reported, but weak as a phone app)
- **Query:** `prison education teacher no internet laptop "offline" classroom incarcerated students technology restrictions`
- **Source:** The Markup | **URL:** https://themarkup.org/machine-learning/2025/08/07/prison-education | **Date:** 2025-08-07 | VERIFIED FETCH
- **Paraphrase:** Reporting on Cal State LA's Prison Graduation Initiative describes instructors pairing incarcerated students with on-campus peers who print library materials to carry inside, and pre-loading academic articles onto thumb drives so students can read them offline on prison classroom desktops.
- **Points to:** Offline content packaging / offline reference for correctional education.
- **Offline necessity:** Real and absolute inside the wire.
- **Audience size:** unknown from this article (it names two programmes and three students, no totals).
- **Honest verdict — WEAK for our purposes:** the people who need it most cannot carry a phone. Most facilities require staff and volunteers to lock phones away too, and students have prison-issued laptops, not Android/iOS devices. A Flutter phone app is the wrong form factor for this constraint. Reporting it so it is not re-discovered later.

---

### Stigmatised self-tracking — account dependence is the thing users actually get burned by
- **Query:** iTunes customer-reviews RSS + App Store review page for Epsy (id 1479108189)
- **Source:** Apple App Store reviews | **URL:** https://apps.apple.com/us/app/epsy-seizure-log-for-epilepsy/id1479108189?see-all=reviews | **Date:** review dated May (most recent page, fetched 2026-07-27) | VERIFIED FETCH
- **Paraphrase:** A one-star reviewer titled "Loved it, Now I hate it" reports the app logged them out after an update and lost every log, note and medication entry, and that the forced logout recurs monthly.
- **Supporting source:** eMoods Bipolar Mood Tracker reviews via the iTunes reviews RSS (`.../id=1184456130/sortby=mostrecent/json`), review dated 2018-11-22 | VERIFIED FETCH — a user notes it saves "on one device with option of backing it up" and *wishes* it had a login, i.e. the local-first model is already the norm here.
- **Points to:** Account-free, local-only symptom/seizure diaries.
- **Offline necessity:** Moderate. The data is genuinely stigmatised (seizures, psychiatric symptoms) and users don't want it on a server, but honestly **offline is not strictly required** for most of these — it's a preference plus a data-loss argument.
- **Audience size:** large and already contested — Epsy 1,668 ratings, EpiCentr 1,475, eMoods 4,190, Bearable 5,952, HarmLess 8,740 (all from the iTunes Search API, 2026-07-27).
- **Data/licence note:** none.
- **Honest verdict — WEAK/MODERATE.** Crowded, and the offline argument is a preference not a necessity. Only worth revisiting for a specific stigma where no app exists at all.

---

### Self-harm trackers — the privacy users want is "hide it from my parents", and it is already served
- **Query:** iTunes Search `self harm recovery tracker` → App Store reviews for HarmLess (id 1537897066)
- **Source:** Apple App Store reviews | **URL:** https://apps.apple.com/us/app/harmless-self-harm-tracker/id1537897066?see-all=reviews | **Date:** reviews spanning 2022-06-21 to 2025-06-22 | VERIFIED FETCH
- **Paraphrase:** A reviewer values the app's password specifically because their parents check their phone; other reviews complain only about the premium paywall — nobody raises servers, accounts or syncing.
- **Points to:** Nothing new. 4.8★ across ~8,700 ratings, actively maintained.
- **Offline necessity:** Weak — the threat model is a person holding the phone, which a PIN already solves.
- **Audience size:** large, well served.
- **Verdict — DEAD END.**

---

### Human-rights fieldworkers and war-crimes documenters — already solved, do not pursue
- **Query:** direct verification fetch after the DV thread
- **Source:** Tella (Horizontal, 501(c)(3)) | **URL:** https://tella-app.org/ | **Date:** fetched 2026-07-27 | VERIFIED FETCH
- **Paraphrase:** Tella is an offline-first, open-source, free-forever mobile app built to "collect, protect and hide sensitive data" for activists, journalists and human-rights defenders, works with no account, and can transfer files to nearby devices fully offline.
- **Points to:** Nothing — this niche is covered by a well-funded nonprofit, and eyeWitness to Atrocities covers the chain-of-custody variant.
- **Verdict — DEAD END.** Add to the already-checked list.

---

### Doulas — partially served by an offline-capable but cloud-backed incumbent
- **Query:** `doula birth notes app "offline" hospital no signal basement labor documentation private practice`
- **Source:** Mobile Doula | **URL:** http://www.mobiledoulaapp.com/Doula-Tablet-App.aspx and https://apps.apple.com/us/app/mobile-doula/id909265632 | **Date:** app last updated 2026-05-21 | VERIFIED FETCH (iTunes Lookup API)
- **Paraphrase:** An actively maintained iPad/iPhone doula practice app that explicitly markets working at a home or hospital birth with no WiFi, then backs everything up to its own servers when a connection appears.
- **Points to:** Business-admin side of doula work is taken. The unserved slice is the *clinical observation timeline* (see the midwife entry), and a genuinely serverless option for doulas who object to a vendor holding client health histories.
- **Audience size:** 338 US App Store ratings suggests a small installed base; DONA-certified doulas number in the low thousands (not verified here).
- **Verdict — MODERATE at best; overlaps the midwife lead.**

---

## No evidence found (dead-end queries and failed verifications)
Recording these so they are not repeated.

- `BACP membership size` — fetched https://www.bacp.co.uk/about-us/about-bacp/ : page states no membership number. The GPiA065 confidentiality/record-keeping PDF (https://www.bacp.co.uk/media/20401/bacp-confidentiality-and-record-keeping-crp-gpia065-jan24.pdf) downloaded but **could not be text-extracted** on this machine. Its content on cloud storage is therefore **unverified**.
- `RID (Registry of Interpreters for the Deaf) membership count` — https://rid.org/about-rid/ returns 404; https://rid.org/ body was truncated and contained no figure. No evidence found.
- `Association of Professional Chaplains membership count` — https://www.professionalchaplains.org/about-apc/ redirects to https://www.apchaplains.org/, which publishes no membership figure. No evidence found. Chaplain/hospice-volunteer visit-note niche remains **unsized and unevidenced**.
- `CCHI certified healthcare interpreter count` — https://cchicertification.org/ publishes no total. No evidence found.
- `Federal certified court interpreter count / annual interpreting events` — http://www.uscourts.gov/court-programs/federal-court-interpreters gives categories and fees but no counts. No evidence found.
- `IAFN / SANE membership count and offline forensic documentation tools` — WebSearch `"sexual assault nurse examiner" documentation forensic photography body map offline tablet IAFN members number` returned protocol and training documents only, no membership figure and no discussion of offline tooling. Also note: SANE documentation sits close to the clinical-liability line and is probably auto-reject territory.
- `CASA / guardian ad litem volunteer count` — https://nationalcasagal.org/our-work/the-casa-gal-model/ only states that programmes "train more than 24,000 new community advocates" per year, gives no total volunteer count and says nothing about documentation tooling. The CASA/GAL angle (home-visit notes on abused children, held by an untrained volunteer, confidential from the family) is **plausible but unevidenced** — worth one more pass when search budget exists.
- `Harm-reduction street outreach documentation burden` — the open-access qualitative study at https://pmc.ncbi.nlm.nih.gov/articles/PMC11363392/ (2024-08-30) was fetched in full and contains **nothing** about how outreach workers document encounters, paperwork burden, or reluctance to record identifying data. No evidence found for this niche.
- `DocuSAFE retirement announcement` — no announcement located; only the 404s and store absence documented above.
- `Existing foster-carer daily-log iOS app` — iTunes Search for `foster carer log` returned only unrelated apps (Foster Friendly, Care.com, WellSky). Weak negative evidence, not proof of absence.
- `Existing offline interpreter glossary iOS app` — iTunes Search for `interpreter glossary` returned only live-interpreting and machine-translation apps. Weak negative evidence.
- `Existing incident-log / abuse-documentation iOS app` — iTunes Search for `incident log abuse` and `abuse journal diary evidence` returned only generic locked-diary apps and law-enforcement evidence tools (Axon). Weak negative evidence, consistent with the DocuSAFE gap.
- `Obsidian/Logseq forum threads for chaplains, doulas/midwives, prison workers, DV advocates, interpreters` — Discourse `search.json` on forum.obsidian.md and discuss.logseq.com returned no relevant threads for any of those terms. No evidence found.
- `GitHub projects/issues in these niches` — `gh search repos` and `gh api search/repositories` returned empty for all four queries tried; no GitHub evidence obtainable in this environment.
- `Journalists' source management / lawyers' client intake` — not reached before the search budget ran out. Untouched, not disproved.
- Untouched for the same reason: lactation consultants, social workers/child protection staff, needle-exchange workers specifically, prison-visit volunteers, addiction recovery sponsors, hospice volunteers, sign-language interpreters, asylum caseworkers.
