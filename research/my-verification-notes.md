# Main-agent verification notes (checks I ran myself, not delegated)

Date: 2026-07-27

## Environment limitation — must be disclosed in every deliverable

**reddit.com is unreachable from this environment.** I verified this personally:
`site:reddit.com "is there an offline app for" no signal work` returned only
alternativeto.net, dev.to and App Store noise — zero reddit.com results. `WebFetch` on
reddit.com / old.reddit.com is refused outright, and reddit.com/about.json is blocked.

The brief asked for six source types with Reddit first. **I substituted equivalent primary
sources rather than fabricating Reddit citations:** Discourse forums via their public `.json`
API (iNaturalist, ODK, gCaptain), the Stack Exchange public API (reachable even though the
websites are not), the Hacker News Algolia JSON API, Apple App Store `?see-all=reviews` pages
(which render real dated review text), the authenticated GitHub REST API via `gh`, F-Droid
search and category pages, XenForo/vBulletin trade forums, and government/NGO documents.

Six source types were still covered. **Zero Reddit URLs appear anywhere in these deliverables.**
Every "no evidence found" in the raw findings is a real dead end, not a hidden Reddit block.

Additional access walls hit by the agents (recorded so they aren't re-tried): beesource.com,
hvac-talk.com, practicalmachinist.com, homebrewtalk.com, cruisersforum.com, arboristsite.com,
controlbooth.com, birdforum.net, gearspace.com, forum.woodenboat.com, rpls.com, allnurses.com,
cloudynights.com, forestryforum.com, app.aws.org, forums.mikeholt.com, trawlerforum.com,
justuseapp.com — all 403 / 402 / Cloudflare. Google Play listing pages return no review text
to a fetcher; Apple's do.

---

## Licence / competitor checks I ran personally

### Bird banding companion — WEAKENED, then largely killed

- **Alpha codes + band sizes are clean.** USGS Bird Banding Laboratory publishes species alpha
  codes (https://www.pwrc.usgs.gov/BBL/Bander_Portal/login/speclist.php), band sizes
  (https://www.pwrc.usgs.gov/BBL/Bander_Portal/login/sizes.php) and the banding data code manual
  (https://www.pwrc.usgs.gov/BBL/manual/summary.php). US Geological Survey works are US federal
  government works → public domain. The NABBP dataset is published on ScienceBase
  (https://usgs.gov/labs/bird-banding-laboratory/data).
- **But the lookup slot is crowded, not vacant.** Beyond the two stale Nemesis apps the review
  agent found, there are at least two more live competitors:
  https://apps.apple.com/th/app/bird-code-lookup/id1613972286 (Bird Code Lookup, iPad) and
  https://apps.apple.com/cn/app/id1523235152 (Schechter ABA/AOU Bird Codes, which already carries
  USGS species numbers and banding sizes). Reference: https://nemesisbird.com/nemesis-code/
- **And the deep content is copyright-blocked.** The part that would give this app real substance —
  ageing and sexing by moult, skull ossification, wing formulae — lives in Pyle's *Identification
  Guide to North American Birds*, which is commercially copyrighted. There is no public-domain
  equivalent. Without it the app is another thin code lookup competing with four existing ones.
- **Verdict: demote.** Clean data for the shallow half, licence-blocked for the deep half.
  This is exactly the failure mode the brief warned about — check licensing early, not late.

### Fishing-legality reference — competitor check I ran myself (this is the winner, so I checked it hard)

Run 2026-07-27 against `itunes.apple.com/search` (live API, real result counts) and the iTunes
customer-review RSS. All figures below are values I retrieved, not snippets.

**The concept is proven and monetised — in the United States only:**

| App | Store | Ratings | Avg | Last update |
|---|---|---|---|---|
| Fish Rules: Local Fishing Laws (`id597875361`) | US | 193 | 3.88 | 2026-07-17 |
| FishVerify: ID & Regulations (`id1121514756`) | US | 2,098 | 4.60 | 2026-04-13 |
| Fish Washington (WA Dept of Fish & Wildlife) | US | 6,951 | 4.33 | 2026-01-30 |

Fish Rules' own store description says *"Works offline so you can check rules anywhere"* and lists
coverage as "Maine to Texas, California, Hawaii, and the Caribbean" — i.e. **US saltwater only**.

**Its recent 1–2 star reviews are, almost verbatim, the failure modes this brief predicts**
(retrieved from `itunes.apple.com/us/rss/customerreviews/id=597875361/sortby=mostrecent/json`):

- *"Incorrect Information, Poorly Managed App"* — rules out of sync with current regulations, and the
  reviewer names the consequence: citations, fines, imprisonment.
- *"Not always accurate"* — reported errors left uncorrected for over a year.
- *"Paid $30 for nothing"* — a purchase that will not unlock, stuck in a login loop.
- *"ZERO CUSTOMER SERVICE"* — paid Pro, cannot use maps or save a home port.
- *"Used to be good"* / *"Buggy upgrade"* — full-screen ads that block scrolling to the species list.
- A login flow that demands Gmail + two-factor **on an app whose whole selling point is offline use**.

So: demand is proven, willingness to pay is proven, and the incumbent is account-gated, ad-gated,
subscription-gated and factually stale. That is corroboration, not a blocker.

**Outside the US the category is empty. I searched eight storefronts myself:**

| Query | Storefronts | Result |
|---|---|---|
| `الاطوال المسموحة للاسماك` (permitted fish lengths) | AE, SA, KW, OM, QA, BH | **0 results in all six** |
| `tallas minimas pesca` | ES | **0 results** |
| `pesca defeso tamanho minimo` | BR | **0 results** |
| `دليل الصياد` / `الصيد البحري` | AE, SA, KW, OM, QA, BH | only Windfinder, Windy, Fishing Points, English AI fish-ID apps and arcade games |
| `fish rules regulations` | ES, BR | Fish Rules and FishVerify appear but with **0 ratings** — listed globally, US data only |

No app in any Arabic, Spanish or Portuguese storefront encodes minimum sizes, closed seasons or
protected species for its own waters. The nearest things are weather apps and photo-AI fish
identifiers, which are server-bound by architecture and therefore useless at sea.

### Copyright kills confirmed across the sweep (do not build on these)

| Domain | Blocking asset | Owner |
|---|---|---|
| Electrical sizing | NEC tables 310.16, Chapter 9 | NFPA |
| Welding procedure/qualification text | D1.1, ASME Section IX | AWS / ASME |
| Blacksmith & bladesmith heat treat | Heat Treater's Guide (~$250) | ASM International |
| Bird ageing/sexing | Pyle Identification Guide | Slate Creek Press |
| International rules of the road | COLREG consolidated text | IMO (US *Inland* Rules are PD) |
| Refrigerant/psychrometric property tables | ASHRAE handbooks, REFPROP | ASHRAE / NIST (CoolProp is the MIT-licensed way in) |
| Sign language dictionaries | filmed sign video corpora; NZSL data is CC-BY-NC-SA | universities / NC clauses |
| Pesticide product labels | manufacturer labels | agrochemical companies |
| Bat call classification | BatDetect2 is **CC BY-NC 4.0** | non-commercial → unusable |

### Clean, verified-permissive assets found so far

- **US federal government works → public domain:** USGS BBL codes; USCG Navigation Rules (Inland);
  NOAA Chart No. 1; NOAA tidal harmonic constants; NWCG/FEMA ICS forms (ICS-214, SF-261);
  USNO/NGA sight-reduction Pub. 229/249; USDA PLANTS, National Wetland Plant List, hydric soil
  indicators; FAA publications; US military FM/TM manuals; NASA technical reports; GNIS.
- **CoolProp** — MIT licence, commercially usable thermophysical property library.
- **TICON-4 tidal constants** — CC BY 4.0 (per flaterco.com/xtide/harmonics.html, *unverified — I have
  not fetched that page myself*). XTide's own free harmonics file is NOAA-derived (US waters, PD);
  its UK/NL file is **non-free** and frozen at 2011.
- **Natural Earth** — public domain. **GeoNames** — CC-BY. **Wikidata** — CC0.
  **OpenStreetMap** — ODbL (attribution + share-alike on *derived databases*; needs care).
  **Wiktionary/Wikipedia** — CC-BY-SA (share-alike trap for bundled content).
- **Log rules** (Doyle, Scribner, International 1/4") — 19th/early-20th century formulas, PD.
- **VSOP87 / Yale BSC / OpenNGC / SAC 8.1** — freely redistributable, *per-catalogue verification needed*.

### Slots confirmed OCCUPIED (do not enter)

HiveCompanion (offline-first beekeeping, one-time purchase) · Mustad EQUINET (farriers) ·
IRPG App (NWCG pocket guide, free + offline) · Deckhand (commercial fishing e-logbook) ·
TopoDroid + SexyTopo + Cave09 (cave survey, Android) · whoBIRD (on-device BirdNET, 886★) ·
OpenTracks (offline GPS tracks, 1.4k★, alive on Codeberg) · Timberlog (log scaling) ·
Field Manager / Let'sGeo (geology core logging) · 8 F-Droid ham apps (exam, logging, Morse) ·
CDC/NIOSH Mobile Pocket Guide · every FAR/AIM reader · Falconry Journal + FalconryLab + Falconry
Journal Pro (~4k US falconers, 3 apps) · a 2025 wave of "no internet, no account" welding and
machinist calculators.

### Design constraints extracted from real 1-star reviews (these are non-negotiable in the spec)

Three independent dated reviews describe the *same* failure — the data was already on the phone
and a gate stood between the user and it:

- Fieldpiece Job Link (HVAC), Mar/May 2026 — forced login several times a day, dies on remote jobs.
  https://apps.apple.com/us/app/fieldpiece-job-link/id873693898?see-all=reviews&platform=iphone
- onX Backcountry, 30 Sep 2024 — random logout, cannot log back in without cell service, downloaded
  maps unreachable. https://apps.apple.com/us/app/onx-backcountry-trail-gps-app/id1529165366?see-all=reviews
- ShroomID, 20 Jun 2024 — update logs you out then blocks you behind an onboarding survey.
  https://apps.apple.com/us/app/shroomid-identify-mushrooms/id1547653790
- Mountain Project, 14 Jan 2012 — "offline" content locked because the app re-validates the
  subscription online. https://apps.apple.com/us/app/mountain-project/id452308783?see-all=reviews&platform=iphone

**Therefore the winning app must have: zero accounts, zero licence revalidation, zero onboarding
gates, zero network code paths, and full function on cold first launch in airplane mode.**
Two independent HN reports also note that a *bad* connection is worse than none, because apps
discard their cache trying to refresh (https://news.ycombinator.com/item?id=44304255,
https://news.ycombinator.com/item?id=47483245). The app should not contain networking code at all.
