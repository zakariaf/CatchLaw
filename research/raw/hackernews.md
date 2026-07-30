# Hacker News mining — Phase 1 discovery (offline-first, small-audience app leads)

Method: `hn.algolia.com/api/v1/search` JSON API (stories + comments) plus `api/v1/items/<id>` to read
whole threads. ~27 distinct queries run. Every URL below was returned by the API in this session.
Where I am inferring an audience size or a licence I say so explicitly — I did not verify user counts.

---

### Minority / sign-language offline dictionaries
- **Query:** `"sign language" app`
- **Source:** Hacker News comment | **URL:** https://news.ycombinator.com/item?id=32302151 | **Date:** 2022-08-01
- **Paraphrase:** A developer says he built an offline mobile dictionary for New Zealand Sign Language ~2012 because no app existed, using dictionary data already compiled by a university Deaf Studies research unit.
- **Points to:** A fully-offline dictionary/phrasebook for one specific small language where an academic institution has already produced the lexicon (signs, images, video stills, grammar notes).
- **Offline necessity:** Deaf users look up a sign mid-conversation, in shops, classrooms and hospitals where they cannot wait for a load; the corpus is small enough to ship whole so there is no reason to ever hit a network.
- **Licence caution:** in the follow-up thread the same author states the NZSL data was CC-BY-NC-SA — **NC blocks commercial use**. Any real build needs a differently-licensed corpus.

### Offline dictionaries generally (Wiktionary-derived)
- **Query:** `"Why I built a dictionary app"`
- **Source:** Hacker News story (533 pts, 177 comments) | **URL:** https://news.ycombinator.com/item?id=32300466 | **Date:** 2022-08-01
- **Paraphrase:** The author's whole motivation is that mainstream dictionary apps are online-only, ad-stuffed and forget what you looked up; in the thread other commenters describe building offline dictionaries for Pashto (no app existed) and Spanish from Wiktionary dumps.
- **Points to:** Offline dictionary + morphology/conjugation engine for one under-served language, built on a Wiktionary/Wikidata dump (CC BY-SA — commercial-OK with attribution).
- **Offline necessity:** Learners and diaspora speakers use these abroad, on transit, and on cheap data plans; a dictionary that spins is a dictionary you stop using.

### Humanitarian / conservation field data collection (ODK-class, but serverless)
- **Query:** `"ODK Collect"` and `KoboToolbox`
- **Source:** Hacker News story thread (49 pts, 17 comments) | **URL:** https://news.ycombinator.com/item?id=17161550 | **Date:** 2018-05-26
- **Paraphrase:** Real users in the thread describe an NGO running public-health surveys in DR Congo on phones plus a battery pack, and a Western Australian turtle-conservation programme that captured ~12k tracks/nests over ~2k survey hours with ODK; one commenter objects that field staff often prefer paper and re-key at home because unlocking, PINs and touch entry are worse in the field.
- **Points to:** A no-server, no-account offline field-recording app for one specific survey protocol (nest counts, transects, ringing, quadrats) with hardened one-thumb entry and plain-file export.
- **Offline necessity:** Beaches, forests and rural clinics have no coverage at all; the existing tools assume a server you must stand up and sync to.

### Nonprofit data collection — existing tools are disliked
- **Query:** `KoboToolbox`
- **Source:** Ask HN | **URL:** https://news.ycombinator.com/item?id=15003940 | **Date:** 2017-08-13
- **Paraphrase:** A nonprofit tech person asks what data-collection software to use and reports KoBoToolbox is "mostly great" but buggy, with poor Android UX, awkward export and no way to amend a submission.
- **Points to:** A single-purpose offline form/record app that fixes exactly those complaints (edit after submit, sane export) without the server half.
- **Offline necessity:** The whole category exists because enumerators work where there is no network.

### Amateur radio portable operating (POTA / SOTA activators)
- **Query:** `"Parks on the Air"`
- **Source:** Hacker News story (112 pts) | **URL:** https://news.ycombinator.com/item?id=41913057 | **Date:** 2024-10-22
- **Paraphrase:** A large HN thread about Parks on the Air, where hams drive to a park, set up a temporary low-power station and try to log 10+ contacts; several commenters describe doing this most weekends while camping.
- **Points to:** An offline activation logger — UTC clock discipline, park/summit reference, Maidenhead grid, dupe checking, band/mode rules, ADIF + Cabrillo export by file share.
- **Offline necessity:** The activity is defined by being in a park or on a summit; cell coverage there is unreliable-to-absent and the log must never be lost.

### Someone is already scratching this itch (unfinished)
- **Query:** `"amateur radio" logging`
- **Source:** Hacker News comment on "Ask HN: What are you working on? (March 2025)" | **URL:** https://news.ycombinator.com/item?id=43535590 | **Date:** 2025-03-31
- **Paraphrase:** A commenter says he is building yet another ham logging tool specifically for hunting POTA/SOTA activators because the million existing ones do not fit that workflow.
- **Points to:** Confirms the niche is felt but under-tooled; the *activator* side (offline) is the part that must not need a network.
- **Offline necessity:** As above — logging happens at the operating position, in the field.

### Personal-use ham logger, never productised
- **Query:** `"amateur radio" logging`
- **Source:** Hacker News comment on "Ask HN: Have you created programs for only your personal use?" | **URL:** https://news.ycombinator.com/item?id=31024866 | **Date:** 2022-04-14
- **Paraphrase:** A ham wrote his own minimal CLI contact logger because every existing program involved too much clicking and selecting.
- **Points to:** Speed-first offline logging UI (one-hand, glove-friendly, no modal dialogs) as the actual differentiator.
- **Offline necessity:** Logging is done mid-QSO with no time and often no signal.

### Celestial navigation / sight reduction for offshore sailors and cadets
- **Query:** `"celestial navigation"`
- **Source:** Hacker News story (114 pts) | **URL:** https://news.ycombinator.com/item?id=42657208 | **Date:** 2025-01-10
- **Paraphrase:** A USNI piece argues ships must keep practising celestial navigation; HN commenters discuss doing sight reduction at sea with a sextant plus a calculator, link to nautical almanac resources, and note usable second-hand sextants go for $100–150.
- **Points to:** An offline sight-reduction workbook: almanac ephemeris, sun/star/moon/planet sights, running fix, plotting sheet, star finder, practice sights with error grading.
- **Offline necessity:** Mid-ocean there is no data at all, and the entire point of the skill is functioning when GPS/comms are denied or dead.
- **Data note (unverified licence, but likely fine):** US Naval Observatory / NGA sight-reduction publications are US-Government works and typically public domain — must be confirmed before building.

### Teaching / learning inside prisons
- **Query:** `offline` (tags=ask_hn)
- **Source:** Ask HN | **URL:** https://news.ycombinator.com/item?id=11189320 | **Date:** 2016-02-28
- **Paraphrase:** A volunteer teaching incarcerated young adults asks how to teach web design and programming when the only hardware is old MDM-managed iPads with zero internet; commenters point at analogous prison programmes and say everything must be local-only.
- **Points to:** A completely self-contained learn-to-code / vocational-skill app: bundled lessons, local runtime, local checker, no account, no network permission at all.
- **Offline necessity:** Correctional facilities forbid internet outright; an app that even *attempts* a connection is not installable.

### Offline drill/practice apps for a niche skill (proof the category lands)
- **Query:** `offline` (tags=show_hn)
- **Source:** Show HN (369 pts, 169 comments) | **URL:** https://news.ycombinator.com/item?id=44498296 | **Date:** 2025-07-08
- **Paraphrase:** OffChess ships ~100k chess puzzles entirely on-device; commenters say they wanted it for an eight-hour flight and for places with no signal, and note Lichess only lets you cache ~50 puzzles offline.
- **Points to:** The same shape applied to an under-served discipline — Go tsumego, bridge bidding, shogi tsume, Morse/CW head-copy, aviation oral-exam drills — where a large public-domain problem set exists.
- **Offline necessity:** People drill in exactly the dead zones: planes, subways, waiting rooms, bathrooms; the incumbents deliberately cripple offline caching.

### Single-trail / single-route offline companion
- **Query:** `offline` (tags=show_hn)
- **Source:** Show HN (475 pts, 141 comments) | **URL:** https://news.ycombinator.com/item?id=33420852 | **Date:** 2022-11-01
- **Paraphrase:** A dev shipped an offline-ready companion for one long-distance hiking trail; in the comments one person calls AllTrails putting offline maps behind a paywall "downright evil" on safety grounds, and another says he is building an equivalent for adventure-motorcycling trip planning.
- **Points to:** Deep, curated, offline companion for **one** named long trail / pilgrimage route / paddling route — huts, water sources, resupply, permits, elevation, bail-out points — as a bundled dataset, not a map subscription.
- **Offline necessity:** On the trail there is no signal, and the map is the safety item; the incumbents' business model actively withholds it.

### Field/off-grid reference: no LLM, deterministic search
- **Query:** `"plant identification" offline`
- **Source:** Show HN (49 pts) | **URL:** https://news.ycombinator.com/item?id=46406486 | **Date:** 2025-12-27
- **Paraphrase:** A Show HN for an offline-first modular field computer (offline maps, plant ID, survival reference) drew objections that you should not put an LLM anywhere near life-or-death lookups and should ship a full-text search index instead.
- **Points to:** A curated, deterministic offline reference for a specific field domain — searchable, citable, no generation — which is exactly the fiddly, long-tail work nobody wants to do.
- **Offline necessity:** The user is off-grid by definition; also a hallucination-free requirement rules out any cloud model.

### E-ink / off-grid reference wishlist
- **Query:** `"plant identification" offline`
- **Source:** Hacker News comment on "Off-Grid Cyberdeck with RPI and Pelican Case" | **URL:** https://news.ycombinator.com/item?id=31404731 | **Date:** 2022-05-17
- **Paraphrase:** A commenter lists what he wants on a low-power offline device: Wikipedia, an emergency medical handbook, and plant identification, because there is nothing good for no-connectivity scenarios.
- **Points to:** Bundled offline reference packs for a specific outdoors context.
- **Offline necessity:** The stated scenario is "no internet available at all".

### Apps actively destroy their own offline cache on bad signal
- **Query:** `"airplane mode" app`
- **Source:** Hacker News comment on "Should we design for iffy internet?" | **URL:** https://news.ycombinator.com/item?id=44304255 | **Date:** 2025-06-17
- **Paraphrase:** A commenter says apps are more usable in airplane mode than on a weak connection, because a bad connection makes them wipe cached data trying and failing to refresh, and cites Spotify on the subway.
- **Points to:** Positioning: "never talks to a network" is a *feature* users can feel, not just a spec line.
- **Offline necessity:** Weak signal is worse than no signal for any app that assumes connectivity.

### Bad connectivity wipes local data (second, independent report)
- **Query:** `"airplane mode" app`
- **Source:** Hacker News comment on an RSS-reader thread | **URL:** https://news.ycombinator.com/item?id=47483245 | **Date:** 2026-03-22
- **Paraphrase:** Same complaint from a different user: with no connection apps serve cached data, but with a *bad* connection they throw the cache away trying to refresh.
- **Points to:** Corroborates the above; strengthens the "no network code path at all" design stance.
- **Offline necessity:** Same.

### Structural-signal evidence: places with genuinely zero coverage
- **Query:** `"no cell signal"`
- **Source:** Hacker News comment on "SMS 2FA is not just insecure, it's also hostile to mountain people" | **URL:** https://news.ycombinator.com/item?id=43988378 | **Date:** 2025-05-14
- **Paraphrase:** Thread and comment describe people who simply cannot receive an SMS where they live/work, including office buildings whose coated windows block cell signal.
- **Points to:** Any tool aimed at mountain/rural/indoor-industrial users must assume zero connectivity, including for onboarding.
- **Offline necessity:** These users cannot even complete a signup flow, let alone use a synced app.

### Rural school / locked-down student network
- **Query:** `"no cell signal"`
- **Source:** Hacker News comment on a student-device-monitoring thread | **URL:** https://news.ycombinator.com/item?id=42379916 | **Date:** 2024-12-10
- **Paraphrase:** A school IT person says student internet is content-inspected with a mandatory root certificate and there is no cell signal because the school is rural, so the filtered school network is the only option.
- **Points to:** Classroom tools that install once and never call out — nothing to whitelist, nothing to inspect, nothing to break.
- **Offline necessity:** Locked-down/filtered network plus no cellular fallback.

### Teachers building their own offline tools
- **Query:** `offline` (tags=ask_hn)
- **Source:** Hacker News post | **URL:** https://news.ycombinator.com/item?id=46353359 | **Date:** 2025-12-22
- **Paraphrase:** A teacher describes making single-file HTML tools that run offline with no backend for their own classroom productivity.
- **Points to:** A packaged offline classroom toolkit for one subject/level (seating, random pairing, rubric scoring, timers with subject-specific content) that survives school firewalls.
- **Offline necessity:** School networks are filtered and unreliable; teachers cannot pause a lesson for a spinner.

### Student pilots / ground school
- **Query:** `ForeFlight`
- **Source:** Show HN | **URL:** https://news.ycombinator.com/item?id=45536776 | **Date:** 2025-10-10
- **Paraphrase:** A dev posts an all-in-one toolkit built while doing private-pilot training and explicitly says it is not trying to be ForeFlight or Garmin Pilot.
- **Points to:** An offline student-pilot study/checkride companion (E6B, weight & balance, FAR/AIM search, oral-exam question bank) — the training half, not the navigation half.
- **Offline necessity:** Cockpit and hangar have no data; more importantly checkride prep and practical exams are done device-locked/no-internet. **Auto-reject anything using live weather or live charts.**
- **Corroborating post:** https://news.ycombinator.com/item?id=46081502 (2025-11-28) — another pilot shipping self-built aviation calculators for the same reason.

### Long trips with no connectivity at all
- **Query:** `offline` (tags=ask_hn)
- **Source:** Ask HN | **URL:** https://news.ycombinator.com/item?id=8125375 | **Date:** 2014-08-02
- **Paraphrase:** Someone going to Africa for five weeks with very limited connectivity asks how to take enough content offline.
- **Points to:** "Pack-before-you-go" bundles — the app should be complete on install, with zero first-launch download.
- **Offline necessity:** The trip *is* the offline period; anything not pre-loaded is unavailable for weeks.

### Extended outage / resilience audience
- **Query:** `offline` (tags=ask_hn)
- **Source:** Ask HN (156 pts, 132 comments) | **URL:** https://news.ycombinator.com/item?id=33017733 | **Date:** 2022-09-29
- **Paraphrase:** A large thread asking what offline resources to keep for internet outages; answers centre on Kiwix, OsmAnd and other fully-local tools.
- **Points to:** Curated offline reference packs; also a distribution channel (this audience actively shares such apps).
- **Offline necessity:** The premise of the thread is that the network is gone.
- **Related, weaker:** https://news.ycombinator.com/item?id=30507155 (2022-03-01), same question, small thread.

### Remote work with no internet for a week
- **Query:** `offline` (tags=ask_hn)
- **Source:** Ask HN (58 pts, 87 comments) | **URL:** https://news.ycombinator.com/item?id=37733904 | **Date:** 2023-10-02
- **Paraphrase:** Someone heading to "the middle of nowhere" asks how to work productively with no connectivity for a week.
- **Points to:** Offline reference/documentation bundles for a specific profession.
- **Offline necessity:** Explicit — no connection for the whole period.

### Mesh / off-grid comms community (adjacent, mostly auto-reject)
- **Query:** `Meshtastic`
- **Source:** Hacker News comment | **URL:** https://news.ycombinator.com/item?id=48037042 | **Date:** 2026-07-24
- **Paraphrase:** A user describes running a Meshtastic node and joining a regional mesh community for beginner off-grid comms.
- **Points to:** A real, findable, small, hardware-owning offline audience — but the messaging use-case itself is comms/sync and therefore out of scope.
- **Offline necessity:** Genuine, but the app category conflicts with the "no sharing/community" rule; only useful as an *audience* to sell an offline reference/planning tool to.

### Ambient corroboration: offline-only tools do get real HN traction
- **Query:** `offline` (tags=show_hn)
- **Source:** Show HN listings | **URL:** https://news.ycombinator.com/item?id=48529990 | **Date:** 2026-06-14
- **Paraphrase:** Top of the "offline" Show HN list (712 pts) is a tool that packages a whole site into a single binary for offline viewing — offline-only utilities reliably reach the HN front page.
- **Points to:** Launch channel validation rather than a niche.
- **Offline necessity:** n/a (channel evidence).

---

## Explicit negatives / no-evidence notes

- **Query:** `KoboToolbox ODK offline data collection` (multi-term) — **no evidence found** (Algolia returned 0 hits; multi-word queries are AND-ish, had to split them).
- **Query:** `offline field` scoped to story 45333021 ("Why haven't local-first apps become popular?") — **no evidence found** (0 hits inside that thread).
- **Query:** `wildland firefighter` — thin: only news stories about the profession, **no evidence found** of anyone wanting/building an offline tool for them on HN. The niche may still be real; HN is just not where they talk.
- **Query:** `cave survey caving` — **no usable evidence found**; hits were about caving as a hobby and one comment on cave-survey instruments (https://news.ycombinator.com/item?id=30672722, 2022-03-14) noting surveyors still use tape/compass/laser rather than software. Weak but not nothing.
- **Query:** `search and rescue offline map` — **no usable evidence found** (results were about mountain-rescue callouts and GNSS, not tooling gaps).
- **Query:** `"community health worker"` — **no evidence found** of a tooling gap on HN; only policy/salary discussion.
- **Query:** `"no good offline"` — five hits, all about mainstream categories (git UI, note outliners, camera DVR); nothing niche enough to use.

## Rejected on the brief's own rules
- Meshtastic/mesh messaging, offline SOS (https://news.ycombinator.com/item?id=43551767, 2025-04-01) — comms/sharing + safety-critical liability.
- Offline LLM assistants (multiple Show HNs) — generic, and the Waycore thread shows the community itself objects to LLMs for field-critical lookups.
- Offline note/kanban/journal/budget apps — explicitly excluded generic categories; they dominate the `offline` Show HN list.
- Anything built on live spots/prices/weather (POTA *hunting* spots, aviation weather, transit times).
