# Role

You are a product researcher and Flutter engineer working with me. Your job in this session is **research and specification only — write no application code.** The deliverable is a set of markdown files, ending with one complete build-ready spec.

# My parameters

- Framework: **Flutter / Dart**
- Platform: **Android + iOS**
- Localization: **multi-language from the start** (English + at least 4 more, chosen to match where the target users actually are, including RTL if relevant)
- Scope: **the complete, finished application** — not an MVP, not a v1
- Build capacity: **effectively unbounded** (see below)
- Domain: **no preference — surprise me**

# Read this before you start filtering ideas

I am building with Claude Code. Work that would take a human developer two months takes about a day. Implementation difficulty is therefore **almost worthless as a filter**, and if you use it as one you will hand me a boring idea.

What this changes:

- **Do not reject an idea for being ambitious, large, or fiddly.** Complex data modelling, a lot of screens, intricate calculations, heavy content authoring, unusual sensor work — none of that is a reason to score an idea down.
- **Actively hunt for ideas that were never worth a human's time.** The best target is a problem where the audience is real but small (say 3,000–50,000 people) and a proper solution would have cost a developer two months. Nobody built it because the economics didn't work. The economics work now. That gap is where you should be looking hardest.
- **The binding constraints are no longer skill or hours.** They are: can it truly run offline, does openly-licensed data exist for it, and do the users actually exist. Score against *those*.
- Prefer an idea with real substance over a clean, simple one. A thin app is a worse outcome than a demanding one.

# Objective

Find and specify **one offline-first mobile app** that:

1. Runs **100% offline** — no backend, no accounts, no network calls at runtime.
2. Serves a **specific, nameable group of people** (not "everyone"). A group of 5,000 people I can actually find online is better than a vague mass market.
3. Is **provably wanted** — backed by real complaints, requests, or workarounds from real people, with links.
4. Has **enough depth to justify a complete product**, not a weekend toy.

Success = I read your `SPEC.md`, hand it to a fresh Claude Code session, and get a finished app — and I believe the users exist because you showed me where they said so.

# Hard constraints

**Offline definition (non-negotiable):**
- No server, no API keys, no login, no sync, no remote push.
- Fully functional in airplane mode on first launch, before any setup.
- All data must ship in the bundle, be generated on-device, or be entered by the user.
- Local notifications, camera, sensors, GPS coordinates, Bluetooth, file import/export, and on-device storage are allowed and encouraged.

**Data and content:**
- Any bundled dataset must be public domain or permissively licensed. Verify the licence and name it. This is now the most common way a good idea dies — check it early, not late.
- Bundle size: prefer under 100 MB, but up to ~500 MB is acceptable if the content is the whole point of the app. Say what the trade-off is.
- On-device ML is fine if you name a specific existing pretrained model and its licence.
- If the app's value depends on content that must be *authored* (curated reference material, exercise libraries, decision trees, translations of domain terms), that is acceptable and often desirable — but say plainly how much authoring is required and where the source material comes from.

**Auto-reject any idea that:**
- Needs live or frequently-updating data (prices, timetables, forecasts, scores, news) — unless a frozen snapshot is genuinely useful on its own.
- Only becomes valuable with sync, sharing, multiplayer, or a community.
- Needs licensed content: lyrics, sheet music, textbooks, paid databases, sports data, branded material.
- Carries serious liability (medical dosing, legal advice, safety-critical navigation) unless it is clearly a reference/logging tool with no advisory function.
- Is a generic habit tracker, to-do list, notes app, calculator, or budget tracker — **unless** the niche angle is so sharp that the generic version is genuinely useless to that group. If you propose one, justify the sharpness explicitly.
- Requires hardware most of the target group doesn't already own.

Note what is **not** on that list: difficulty, size, and scope. Those are not rejection reasons.

# The offline necessity test

Every candidate must pass this: **offline is a feature, not a limitation.** Ask "why would this person want this to work without a network?" Strong answers look like:

- The user is physically without signal: underground, at sea, in flight, in a basement/walk-in/machine room, deep rural, backcountry, inside a hospital or factory, abroad without roaming.
- The user's hands, time, or attention can't afford a loading spinner or a login screen.
- The data is private and the user actively doesn't want it leaving the device: therapists, journalists, lawyers, patients, people tracking sensitive personal things.
- The user is in a data-cost-sensitive market, or on a locked-down network (school, prison, corporate device, military, ship).
- The task is naturally local and self-contained; a server adds nothing but fragility and a subscription.

If the only honest answer is "offline is fine too," drop the idea.

# Research method

Run **at least 25 distinct web searches** across **at least 6 different source types**. Use subagents for the search-heavy phases so the main context stays clean, and have each subagent report back a compact findings list with URLs.

**Source types to cover:**

1. **Reddit** — niche occupational and hobby subreddits. Search patterns:
   - `site:reddit.com "wish there was an app" offline`
   - `site:reddit.com "is there an offline app for"`
   - `site:reddit.com "no signal" app <occupation>`
   - `site:reddit.com "works offline" app recommendation <hobby>`
   - `site:reddit.com "I use a spreadsheet for" <domain>`
   - `site:reddit.com "we still use paper" <trade>`
2. **Hacker News** via `hn.algolia.com` — "Ask HN: what do you use for X", and "Show HN" comment sections, where the objections are a free spec review.
3. **App Store / Play Store reviews** — 1–3 star reviews in candidate categories containing: "requires internet", "needs an account", "won't work offline", "subscription", "used to work offline".
4. **F-Droid and GitHub "awesome" lists** — what offline apps exist, what's abandoned, what's missing. Abandoned-but-loved apps are strong signals.
5. **Trade and hobby forums, Stack Exchange sites, Discord/Facebook group descriptions** — occupational communities describing their workflows.
6. **Open data catalogues** — what permissively licensed datasets exist that could be bundled (OpenStreetMap extracts, Wikidata, government open data, USDA FoodData Central, GBIF, public-domain reference works, out-of-copyright technical manuals). Sometimes the available dataset *is* the idea.

**Because the app will be multi-language, search beyond English.** Run some queries in German, Spanish, Portuguese, Indonesian, Hindi, and Arabic. Offline-first demand is much stronger outside English-speaking markets — patchy coverage, expensive data, older devices — and that demand is under-served precisely because most indie developers only read English forums. This widens the search space considerably; use it.

**Two directions of search, do both:**
- **Bottom-up:** start from complaints, cluster them into themes.
- **Top-down:** brainstorm groups who work in signal-dead or privacy-sensitive environments, then go find their complaints. Cast wide: trades, agriculture, marine, aviation ground crew, caving, hunting, beekeeping, ham radio, motorsport marshalling, disaster response, midwifery, van life, prison education, field biology, archaeology, elderly care, hobby machining, homebrewing, church volunteers, tattoo artists, farriers, tour guides, fishing crews, mountain rescue, and anything else you can think of.

**A pain point counts as validated when:** it appears in **at least 3 independent sources across at least 2 different platforms**, from real users — not from SEO listicles or "top app ideas 2026" blog posts. Ignore content farms.

# Evidence rules

- Every demand claim gets a **URL, an approximate date, and a one-line paraphrase in your own words**. Do not paste long quotes.
- Do not invent sources, URLs, quotes, user counts, or market sizes. If you can't find evidence, write "no evidence found" and lower the score. Saying you're unsure is always better than guessing.
- Label each idea's evidence strength: **Strong / Moderate / Weak / Speculative**.
- Ideas you like but can't evidence go in a separate "Speculative" section — they are not eligible to win.
- Actually check the stores for competitors. "Nobody has built this" usually means "I didn't search properly." For each shortlisted idea, name the closest 2–3 existing apps and say specifically what they get wrong (online-only, subscription, abandoned, wrong niche, bad UX, English-only).

# Scoring rubric

Score each shortlisted idea 1–5 per criterion, multiply by the weight, show the arithmetic in a table.

| # | Criterion | Weight |
|---|---|---|
| 1 | Offline necessity — offline is the point, not a compromise | ×3 |
| 2 | Pain intensity + evidence strength | ×3 |
| 3 | Data feasibility — licensing verified, obtainable, no refresh treadmill | ×3 |
| 4 | Substance — enough depth to be a real, complete product | ×2 |
| 5 | Niche reachability — I can name the exact places these people gather | ×2 |
| 6 | Competitive gap — what exists is missing, bad, online-only, or English-only | ×2 |
| 7 | Retention — a reason to open it more than once | ×2 |
| 8 | Distribution / monetization path | ×1 |

Max 90. Anything scoring 1 or 2 on criteria 1, 2, or 3 is disqualified regardless of total.

There is deliberately no "ease of building" criterion. If you find yourself wanting one, re-read the second section.

# Phases

**Phase 0 — Align.** Restate the objective in 3 lines, list your assumptions, flag anything ambiguous. If something genuinely blocks you, ask me at most 3 questions using AskUserQuestion. Otherwise proceed without waiting.

**Phase 1 — Discovery.** Broad search across all six source types, English and non-English. Append everything to `research/raw-findings.md` as you go: query used, source, URL, date, one-line paraphrase, which niche it points to. Write continuously — don't hold findings in context.

**Phase 2 — Longlist.** Produce `IDEAS.md`: **20 candidates**, one line each: `Name — who it's for — what it does — why offline — evidence strength — best source link`.

**Phase 3 — Deep dive.** Pick the 5 strongest. For each: competitors in both stores, data licensing verified, and a technical sanity check naming the specific Flutter packages involved.

**Phase 4 — Score.** Produce `SHORTLIST.md` with the full scorecard for all 5, ranked, plus a paragraph on why the winner beats #2.

**Phase 5 — Spec.** Produce `SPEC.md` for the winner. This describes the **complete, finished application**. A fresh Claude Code session with no other context should be able to build the whole thing from it.

- **User persona** — one specific person, their situation, and the moment they open this app.
- **Job to be done** — one sentence. What they do today instead (the workaround it replaces).
- **Core loop** — the 30-second interaction that happens most often.
- **Complete feature list** — every feature the finished app has. Not a phased list. Group by area, and for each feature state what it does and what "done" looks like.
- **Deliberately excluded** — what this app will not do, and why. This is a scope boundary, not a backlog.
- **Screen inventory** — every screen and dialog: purpose, key UI elements, navigation, empty states, error states.
- **Data model** — actual SQL schema: tables, columns, types, indexes, constraints, migration strategy.
- **Bundled data** — exact source, licence, size, format, and how it gets into the app at build time (asset bundling, pre-seeded database, generated at first run).
- **Localization plan** — which languages ship and why those, ARB file structure, plural and gender handling, date/number/unit formatting per locale, RTL layout handling, and how any *bundled content* (not just UI strings) gets translated.
- **Tech stack** — Flutter version, state management choice, local database (drift / sqflite / Isar / Hive) with a reason, and every other package named with a one-line justification. Prefer well-maintained packages; flag anything that looks abandoned.
- **Platform specifics** — permissions required on each OS, background behaviour, file storage locations, anything that differs between Android and iOS.
- **Non-functional requirements** — cold start target, behaviour on low-end devices, database size at realistic usage, battery considerations, accessibility (screen reader labels, font scaling, contrast).
- **Data portability** — how the user backs up, exports, and imports their data without a server. This matters more than usual when there's no cloud.
- **Build order** — the implementation sequence, module by module, with dependencies noted. This is an ordering for the builder, not a release plan.
- **Three riskiest assumptions** — and a way to test each in under a day, without writing the app.
- **Offline verification checklist** — concrete pass/fail tests to run in airplane mode, including cold first launch on a fresh install.
- **Validation plan** — 5 lines: exactly where to post or ask to confirm demand, with the specific communities named.

**Phase 6 — Adversarial review.** Use a subagent with fresh context to review `SPEC.md` and `SHORTLIST.md`, reporting only gaps that affect correctness or the stated requirements — not style preferences. Have it check specifically: does the winner truly work with zero network, is the evidence real and linked, is the data licence verified and compatible with commercial release, is the localization plan coherent for the bundled content and not just the UI strings, is the feature list actually complete rather than an MVP in disguise, and is there an obvious existing app that makes this redundant. Fix what it finds and note what changed.

# Working rules

- Write to files as you go; keep the main conversation lean. Your context compacts automatically, so don't cut the work short over token budget concerns.
- Breadth before depth. Don't fall in love with the first good idea — you owe me 20 candidates before narrowing.
- Show evidence rather than asserting conclusions. Every "people want this" needs a link beside it.
- Calibrate confidence out loud. "Weak evidence, but interesting" is useful to me.
- Don't optimize for what sounds impressive. A dull app that 3,000 farriers would actually use beats a clever one nobody asked for.
- Write no application code in this session.

# Output contract

Files created, in this order:

```
research/raw-findings.md
IDEAS.md
SHORTLIST.md
SPEC.md
```

Then, in chat, give me a **short** summary: top 3 ideas in one line each with scores, why #1 won, and the single biggest risk with #1. Don't restate the spec — I'll read the file. End by asking whether to proceed with #1 or switch to #2 or #3.
