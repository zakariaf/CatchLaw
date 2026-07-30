# SPEC.md — *Is This Legal?* / **CATCHLAW**

**An offline catch-legality reference for artisanal and recreational fishers in the Arabian Gulf,
Galicia and Iberia, and Brazil.**

This document describes the **complete, finished application**. It is not a phased plan and there is
no "v2". The Build Order section is an implementation *sequence*, not a release schedule.

A fresh Claude Code session with no other context should be able to build the whole thing from this
file. Evidence for every demand claim lives in `SHORTLIST.md` and `research/raw-findings.md`.

> **Revision note:** this spec was revised after a three-reviewer adversarial pass. Every change is
> itemised in `REVIEW-CHANGES.md`, including one blocker (a transitive `http` dependency that made the
> original "no HTTP client is linked" claim false), an evidence claim that the cited source did not
> support, and four competitors the first draft missed.

---

## 0. The one-paragraph version

You have just landed a fish. In under five seconds, with no signal, no account and wet hands, the app
states whether it meets the rules where you are standing — and if not, which rule it fails: below the
minimum, inside a closed season, protected, or past your bag limit. It shows *how* that species is
legally measured, with a diagram, because "length" means five different things depending on what you
are holding. It cites the actual ministerial decision or regional order the number comes from, and the
date that text was last checked. It keeps a running tally against your daily limit. Nothing it stores
ever leaves the phone, because there is no code in it that could send anything anywhere.

---

## 1. User persona

**Khalid, 46, Ras Al Khaimah.**

He owns a 9-metre fibreglass *tarrad* and fishes with two crew, mostly hand-lines and gargoor traps,
four to six kilometres off Al Rams. He holds an Emirati fishing licence. His phone is a three-year-old
Android. Arabic is his working language; his English is functional but slow, and he does not read
scientific names at all.

**The moment he opens the app:** 05:40, still dark, the trap is up on the gunwale and there is a
*sha'ri* in the bin that looks marginal. He is not sure whether it is *sha'ri* or *safi* — one of them
has a closed season starting in March. He has no bars. His hands are wet and covered in slime, and the
fish is alive. He has perhaps ten seconds before returning it stops being worthwhile. Getting it wrong
costs money and his licence.

Today he guesses. Sometimes he throws back a legal fish to be safe, which is income over the side.

**Secondary personas the same product serves without compromise:**

- **Marisa, 52, Cambados, Galicia.** A licensed *mariscadora* working the intertidal flats on foot with
  a *sacho*. The Xunta's minimum sizes and bank-specific exceptions live on a web portal she cannot
  reach standing in ankle-deep water at low tide. Works in Galician.
- **Rodrigo, 34, interior São Paulo.** Weekend sport angler at a reservoir. Piracema dates and the
  10 kg + one-native-fish quota differ by state and basin, and the 1,500 m exclusion around dams is what
  actually gets people fined. No signal at the bank.

**Audience size, stated plainly.** The brief asks for a nameable group of roughly 3,000–50,000.
This product's group is the union of three:

| Group | Count | Source and confidence |
|---|---|---|
| Gulf artisanal fishermen (UAE registered boat owners) | ~5,300 UAE; plausibly 30k–60k across UAE/OM/KW/QA/BH/Saudi Eastern Province | ⚠️ **Unverified.** The 5,268 figure traces to `wam.ae/ar/details/1395303082903`, whose body is JS-rendered; the number does not appear in the retrievable HTML. Treat as indicative only until confirmed against MOCCAE or the FAO UAE fishery profile. |
| Galician licensed shellfish gatherers and coastal fishers | low thousands | ⚠️ The Xunta's own statistics portal publishes lonxa sales and employment series but **no permex headcount**. Unverified. |
| Brazilian sport anglers reachable through clubs and colônias | unknown | ⚠️ Every federal source (gov.br, MPA) returned 401/403. Not estimated. |

**I am not going to invent a total.** The honest position is that the Gulf slice alone is credibly
inside the band, the group is precisely *nameable* (see §17), and the two figures I could verify
exactly — 193 Fish Rules ratings, 58 written PescaREC reviews — are floors, not populations.

---

## 2. Job to be done

> "Tell me right now whether this animal meets the rules here, in my language, without a network — and
> show me the rule so I can check it against the inspector's."

**What they do today (the workaround this replaces):** guessing from memory; a laminated card in the
wheelhouse two seasons out of date; a photo of a government web page taken while still in port; asking
another boat on VHF; or throwing back legal fish "to be safe". Marisa's is a printed A4 from the Xunta
portal gone soft in her pocket. Rodrigo's is a screenshot. Khalid's community's is an app their own
association had to commission.

---

## 3. Core loop (the 30-second interaction, and it is really 5 seconds)

1. Open app. It launches straight to **Check** with the last-used zone already selected. No splash, no
   login, no onboarding, no "what's new".
2. Tap the species. Four ways, all one tap from here: **Recents**, **search by local name**,
   **browse by silhouette**, or **Identify this fish** (the key, S7).
3. Lay the fish on the screen against the calibrated ruler, or type the length. The measurement-method
   diagram for *this* species is shown inline — snout-to-fork, total length, carapace width.
4. **Result**: a full-width statement of fact, with colour and haptic reinforcement —
   `MEETS THE MINIMUM · 47 cm (minimum 45 cm, total length)` in green, or
   `BELOW THE MINIMUM · 38 cm (minimum 45 cm, total length)` in red, or
   `CLOSED SEASON · 1 March – 30 April` in red.
   Never an instruction. See §5.1 for why this wording is load-bearing.
5. Optional single tap: **+ Add to today**. Updates the bag tally. Done.

Steps 1–4 must be achievable with one thumb, in sunlight, wearing wet gloves, in under five seconds.

---

## 4. Complete feature list

Every feature the finished app has. "Done" is the acceptance condition.

### 4.1 Check — the rule-evaluation engine

| Feature | What it does | Done looks like |
|---|---|---|
| Species picker | Recents, search, silhouette browse, and Identify — all one tap from Check | Four paths land on the same species detail; recents are per-zone, ordered by frequency then recency |
| Local-name search | Matches vernacular names in all six locales, diacritic-insensitive, with full Arabic orthographic normalisation (§9.4) | Typing `hamour`, `هامور`, `هامورة`, `الهامور` or `Epinephelus` all reach the same species id. This is a unit test, not a manual check. Results in ≤50 ms |
| Rule evaluation | Evaluates (jurisdiction, zone, species, date, length, today's tally) → an ordered list of factual findings | Protected status is reported first, then season, then max size, then min size, then bag limit, then vessel limit. Every finding names its rule row and citation |
| Result display | A statement of fact plus the numeric margin, never an imperative | "Below the minimum — 38 cm, minimum 45 cm (total length)" |
| Ambiguity handling | Where two equally specific rules apply, shows both and refuses to choose (dialog D4) | Never silently reports the more permissive rule |
| Expired-rule handling | A rule whose `valid_to` has passed is still evaluated, flagged `is_expired`, and rendered with the amber bar | See §7.3. A verdict is still produced — this is tested in §14 |
| Unknown species | Explicit "not in this jurisdiction's list" state that does **not** imply legality | "No rule recorded for this species here. This does not mean it is legal." + in-app navigation to the protected-species screen (S18) |
| No-rule-vs-no-data | Distinguishes "no size limit exists in this instrument" from "we have not transcribed this species" | Two visually distinct states |

### 4.2 Measurement

| Feature | What it does | Done looks like |
|---|---|---|
| On-screen ruler | Physically accurate ruler along the long edge | Within ±1.5 mm over 15 cm on a calibrated device |
| Calibration | One-time, using an ISO/IEC 7810 ID-1 card (85.60 × 53.98 mm — every bank card on earth) | Drag an outline to match a real card; stored as px-per-mm; re-calibratable from Settings |
| Step-and-mark | For fish longer than the screen: mark, slide, mark again, sum | Up to 4 segments, running total, cancel restores previous |
| Manual entry | Big numeric keypad, cm/mm/inch per locale | One tap from the ruler; **works before calibration**, so the core loop is complete on first launch |
| Measurement methods | Total, fork, standard length; carapace width and length; mantle length; disc width; shell length; plus a per-jurisdiction custom method | Each has an SVG diagram showing the two endpoints on a body of the right shape |
| Method is per-species-per-jurisdiction | The same species may be measured differently in two countries | The diagram always comes from the active jurisdiction's rule row |

### 4.3 Identification (deliberately not photo-AI — see §5.2)

| Feature | What it does | Done looks like |
|---|---|---|
| Morphological key | A deterministic dichotomous key per family group — body shape, fin count and position, barbels, mouth position, caudal shape, lateral line, colour markings | Never more than 6 couplets to a candidate list |
| Entry points | "Identify this fish" from S1, from S5's empty state, and from S6 | S7 is reachable from three places (this was a defect in the first draft) |
| Decision trail | The answers that led here, each tappable to go back | "Why am I here?" is answerable at every node |
| Candidate list | Returns **one or more** candidates, never a single confident answer | Backed by `key_leaf_species` (§7.1); multi-candidate results show the strictest applicable rule first, with the candidate count visible |
| Dead ends | A couplet may legitimately lead nowhere | `key_option.next_node_id` is nullable; S7 renders the dead-end state |
| Look-alike warnings | Per species, "commonly confused with X" with the difference stated | Every protected species carries one if a legal look-alike exists |
| Silhouette browse | Grid of black-on-white outlines grouped by family, **family names in the active locale** | Legible at arm's length in sunlight |

### 4.4 Jurisdiction and zone

| Feature | What it does | Done looks like |
|---|---|---|
| Jurisdiction picker | Country → region → sub-zone (emirate, comunidad autónoma, state, basin, bank) | Set once, changeable in two taps |
| Saved zones | Several named zones with quick-switch | Switching re-evaluates the current species instantly |
| GPS zone suggestion | Optional single-shot fix, matched by on-device point-in-polygon against bundled rings | Suggests, never auto-switches; fully usable with location denied |
| Fresh vs salt | Where a jurisdiction splits them, the zone carries the water type | Freshwater zones never show marine rules |
| Bank / reserve / exclusion overrides | Galician shellfish banks, Brazilian dam exclusion radii, Gulf marine reserves | Overrides visibly marked as exceptions with their own citation |
| Jurisdictions with no polygons | Where an authority publishes no coordinate boundaries, rules apply jurisdiction-wide | Zone picker hides the sub-zone level rather than inventing boundaries (§8) |

### 4.5 Catch log (entirely local)

| Feature | What it does | Done looks like |
|---|---|---|
| Today's tally | Live count per species against the bag limit | Visible on Check without navigating away |
| Trip log | Start/end a trip; catches attach to it; can be started retroactively | |
| Catch record | Species, length, method, findings, kept/released, timestamp, optional in-app photo, optional coordinates, **plus jurisdiction and zone codes stored on the catch itself** | History filters by zone work for quick-added catches with no trip |
| Location privacy | Coordinates opt-in per catch, off by default | A global Settings toggle disables capture entirely |
| Photo handling | In-app camera; images written inside the app sandbox | **Never** written to the shared camera roll |
| History | Filter by species, zone, date range; season and annual totals | Instant at 10,000 catches |
| Edit and delete | Any record editable; delete undoable for 10 seconds | |
| Storage management | Settings shows bytes used and offers bulk photo purge that keeps the records | |

### 4.6 Reference

| Feature | What it does | Done looks like |
|---|---|---|
| Rule text (S13) | The verbatim governing text per jurisdiction, searchable | FTS in ≤200 ms; **Arabic search works** via the normalised column (§7.1, §9.4) |
| Citation per finding | Instrument type (localised), reference number, article, publication date, source URL as **selectable text**, and the date we last checked | Tapping the citation row expands the bundled verbatim text in S13 and offers copy-to-clipboard. **It does not open a browser.** See §5.3 |
| Protected species (S18) | Full list with silhouettes, browsable independently | |
| Gear and methods (S19) | Banned gear, banned methods, mesh sizes, hook restrictions — **gear names localised** | |
| Penalties (S20) | What a violation costs, per jurisdiction, per occurrence | The screen that makes people keep the app |
| Licence types (S21) | Which licence class covers this zone and water type, with its description | Backed by `licence_type`, not by a boolean |
| Glossary (S22) | Domain terms per locale | Backed by `glossary_term` |
| Changelog (S23) | What changed between content versions, per jurisdiction | Backed by `content_change`, emitted by the build tool |

### 4.7 Trust and currency

| Feature | What it does | Done looks like |
|---|---|---|
| Content version banner | "Rules as published on <date>, checked <date>" per jurisdiction, on every result | |
| Expiry warning (D3) | When a rule's validity window has passed, a persistent amber bar — **and the rule is still evaluated** | Amber, never blocking. A stale rule beats nothing at sea. Tested in §14 |
| Per-jurisdiction changelog | See S23 | |
| Disclaimer | Non-dismissable single line on the result screen: "Reference only — not legal advice. Verify with <authority>." Full statement in S17 | On the result itself, not buried |
| Flag a wrong rule | Records a local note against the rule row, from a "Flag this rule" action on S2; included in every export | **Composes nothing and sends nothing.** The user exports and mails it themselves if they choose |

### 4.8 Data portability — §12.

### 4.9 Accessibility and field usability

| Feature | What it does | Done looks like |
|---|---|---|
| Glove mode | All primary targets ≥ 56 dp with ≥ 8 dp separation | Result and species tiles pass at 56 dp |
| Sunlight mode | A third theme (not a dark-mode variant): maximum contrast, monochrome plus result colour | Toggle in S14 and by long-press on the result |
| Screen reader | Every control labelled; the result announced as a live region | TalkBack and VoiceOver read the finding without navigating |
| Font scaling | Layouts survive 200% text scale | No clipping or overlap at 200% on a 5-inch screen |
| Colour independence | Result never relies on colour alone — icon + words + colour | Passes a greyscale screenshot test |
| Haptics | Distinct patterns for pass and fail | Usable without looking |
| One-handed reach | Primary actions in the bottom third | |

---

## 5. Deliberately excluded

A scope boundary, not a backlog.

| Excluded | Why |
|---|---|
| **Any outbound network call** | See §5.3 for the precise, honest formulation of this guarantee. |
| Accounts, login, sync, cloud backup, licence revalidation | Verified reviews across five apps describe users locked out of data already on their phone. This is the failure mode we exist to avoid. iDfish — the only competitor with genuine offline AI — **still requires an account before offline use is available**. |
| Photo-AI species identification | See §5.2. |
| Weather, tides, forecasts, sea state, solunar tables | Live data. Auto-reject. Excellent offline tide apps already exist. |
| Maps and chart tiles | Enormous, licence-encumbered, unnecessary — point-in-polygon answers the only geographic question we ask. |
| Catch sharing, leaderboards, social, spot marking | Sharing auto-reject. |
| Official catch declaration / regulatory submission | That needs a server and an approved schema. **Note the landscape changed:** the EU's own *RecFishing* app (Publications Office, updated 2026-06-18, 24 languages, offline-capable) now covers recreational catch declaration across the EU. CATCHLAW's log is explicitly a **private complement** to that, not a substitute, and must never present itself as satisfying a declaration duty. |
| Fish market prices | Live data. |
| Ciguatera, toxin, mercury or edibility advice | Health claims. Out. |
| Licence purchase or validation | Needs a server, and creates a false impression of legal standing. |
| Widgets, watch apps | Not part of this product. |

### 5.1 The legal-advice auto-reject, argued explicitly

The brief auto-rejects tools carrying serious liability including legal advice, *"unless it is clearly a
reference/logging tool with no advisory function."* An adversarial reviewer correctly pointed out that
the first draft's full-width green **KEEP** / red **RETURN** was an imperative — an application of law
to facts, i.e. advice — and that the spec never argued the carve-out. Both are fixed:

1. **The output is a statement of fact, never an instruction.** The app reports
   `BELOW THE MINIMUM — 38 cm, minimum 45 cm (total length)`, not "throw it back". It states what the
   published rule says and what the measurement was. The user applies it.
2. **Every finding carries its citation** — instrument, article, publication date, and the date we last
   checked — so the app is transparently a reader of a published instrument rather than an oracle.
3. **It refuses to resolve genuine legal ambiguity.** Where two equally specific rules apply, D4 shows
   both. An advice product would pick one.
4. **It never interprets.** No "this probably counts as", no analogies, no reasoning about edge cases.
   A species with no transcribed rule returns "no rule recorded — this does not mean it is legal."
5. **A non-dismissable disclaimer sits on the result screen itself**, naming the authority to verify with.

That is the same posture as a printed regulations booklet with a ruler on the back cover, which is what
it replaces. It is a reference tool.

### 5.2 Why photo-AI is excluded — the honest reason

The first draft claimed photo-AI "cannot work offline". **That is false**, and a reviewer proved it:
[iDfish](https://apps.apple.com/es/app/idfish/id1068033877) (IDVIABILITY PTY LTD, 1,425 ratings /
4.66★ in the AU store, updated 2026-04-28) runs on-device AI photo recognition with no internet
connection. The real reasons are:

1. **No commercially licensable training corpus exists** for Gulf, Iberian and Brazilian species
   photographs. This is the same licence wall §8 hits for illustrations, and it is decisive.
2. **A key is auditable and a classifier is not.** The user can see why the key landed where it did and
   can back out one step. A wrong confident classification on a protected species is the worst failure
   this app could have.
3. **iDfish itself shows the gate is the business model, not the ML** — it requires an account and a
   $9.99/yr subscription before offline use is available, which is precisely what we refuse.

### 5.3 The offline guarantee, stated accurately

The first draft claimed "no HTTP client is linked". **That was false.** `printing` declares `http` as a
direct dependency (for `PdfGoogleFonts`), and `flutter_svg` declares it too (for `SvgPicture.network`).
Both are on the required stack. The accurate guarantee is:

- **No HTTP client is *used*.** `package:http` appears transitively via `printing` and `flutter_svg`.
  Those two edges are on a documented, CI-diffed exception list. Any third edge fails the build.
- **The APIs that would use them are banned by grep**, not by hope: `PdfGoogleFonts`,
  `SvgPicture.network`, `Image.network`, `NetworkImage`, `launchUrl`, `url_launcher`, `AndroidIntent`,
  `ACTION_VIEW`. PDF fonts load only via `pw.Font.ttf(rootBundle.load('assets/fonts/…'))`.
- **On Android the OS enforces it**: the release manifest does not grant `INTERNET`, so any socket the
  app opens fails at the kernel.
- **On iOS there is no OS-level equivalent**, and the first draft's proposed proofs were worthless —
  ATS blocks only cleartext HTTP, and Foundation/CFNetwork is linked by the Flutter engine regardless.
  The iOS guarantee therefore rests on the dependency allowlist plus a mandatory device packet capture
  (§14). This is stated rather than glossed.
- **`authority_url` and `citation.source_url` are rendered as selectable text only.** Nothing in the app
  hands a URL to a browser: an `ACTION_VIEW` intent would cause a fetch under the browser's own
  permission, defeating the Android guarantee.

---

## 6. Screen inventory

**Bottom navigation, enumerated:** `Check` (S1) · `Today` (S8) · `Trips` (S10) · `Reference` (S12) ·
`Settings` (S14). Five items, fixed, always visible, labelled and iconned.

### S1 — Check (home)
- **Purpose:** the core loop. Launch target, always.
- **Elements:** zone chip (top-left, → S9) · content-currency chip (top-right, → S23) · Recents strip
  (6 species) · **Search species** field (→ S5) · **Browse by shape** (→ S6) ·
  **Identify this fish** (→ S7) · today's tally summary bar · bottom nav.
- **Empty state:** first launch with no recents — search field ready (not auto-focused, so the keyboard
  does not cover the screen); Browse and Identify emphasised.
- **Error state:** none possible. With no jurisdiction set the zone chip reads "Choose your area" → S9.

### S2 — Species detail / result
- **Elements:** species header (local name large, other-locale names small, scientific name smallest) ·
  silhouette · measurement-method diagram · **ruler** / **type length** toggle · result banner (factual
  statement, §5.1) · findings list · rule facts table · citation row (expands into S13; copy to
  clipboard) · look-alike card · **+ Add to today** · **Flag this rule** · amber expiry bar when
  applicable · disclaimer line.
- **Empty state:** no rule for this species here → the wording in §4.1 + button to S18.
- **Error state:** ruler not calibrated → inline **Calibrate** prompt; manual entry remains available.

### S3 — Ruler
- **Elements:** full-bleed ruler along the long edge · draggable end marker · live readout · method
  reminder with mini-diagram · **Step and mark** · **Type instead** · **Recalibrate**.
- **Error state:** implausible reported pixel density → force calibration before use.

### S4 — Calibration
- **Elements:** ID-1 card outline overlay · pinch/drag to fit a real card · live mm-per-pixel readout ·
  **Verify** step showing a 50 mm bar to check against the card's short edge · Save.
- **Error state:** result outside a plausible range → rejected with an explanation, not saved.

### S5 — Species search
- **Elements:** search field · results grouped "in your zone" then "elsewhere in this jurisdiction" ·
  each row shows local name, silhouette, and a one-word hint (`45 cm` / `protected` / `closed`).
- **Empty state:** no matches → **Identify this fish** and **Browse by shape**, plus a note that the
  list covers the active jurisdiction only.

### S6 — Browse by shape
- **Elements:** grid of silhouettes grouped by family, **family names localised** (`family_name_key`) ·
  **Identify this fish** action in the app bar.

### S7 — Identification key
- **Elements:** one couplet at a time, two large illustrated options · breadcrumb of answers ·
  **Back one step** · **Start over** · live candidate count.
- **Terminal states:** candidate list (1..n species) → tap through to S2; or dead end →
  "No match. Browse by shape or search by name."

### S8 — Today / tally
- **Elements:** per-species counts against limits · vessel-limit aggregate where applicable ·
  **End trip** · quick-add.
- **Empty state:** "No catches recorded today."

### S9 — Zone picker
- **Elements:** country → region → sub-zone · **Use my location** · saved zones with a star · water-type
  toggle where applicable.
- **Error state:** location denied or no fix → the manual list stays fully usable, with one line saying why.
- **Note:** jurisdictions with no published polygons show no sub-zone level at all (§4.4).

### S10 — Trips / history
- **Elements:** trip list · per-trip catches · filters (species, **zone**, date range) · totals.
- **Empty state:** "No trips yet."

### S11 — Catch detail
- **Elements:** all fields editable · photo · coordinates with a clear on/off state · delete with undo.

### S12 — Reference hub
- **Elements:** cards routing to S13, S18, S19, S20, S21, S22, S23.

### S13 — Rule text reader
- **Elements:** full-text search (normalised, so Arabic works) · article navigation · citation header ·
  "as checked on" date · **language-availability notice** when the verbatim text exists only in the
  jurisdiction's original language (§9.6).

### S14 — Settings
- **Elements:** language override · **numeral system** (auto / Western / Arabic-Indic) · units · zone
  defaults · ruler calibration · sunlight mode · glove mode · coordinate capture on/off · storage used
  + bulk photo purge · export (S15) · import (S16) · about (S17).

### S15 — Export · S16 — Import
As §12. S16 error state: malformed or newer-schema file → named, specific error, nothing written.

### S17 — About / legal
- **Elements:** full disclaimer · data sources and licences per jurisdiction · **`ATTRIBUTIONS.md`
  rendered in full**, including every plate's illustrator and death year (§8) · content version per
  jurisdiction · app version · a plain statement that the app collects and transmits nothing, and why
  no privacy-policy URL is needed.

### S18 — Protected species · S19 — Gear and methods · S20 — Penalties · S21 — Licence types · S22 — Glossary · S23 — Changelog
Each: a searchable list backed by its table (§7.1), with the jurisdiction and content version in the
header, every label resolved through `content_string`, and an empty state reading "not recorded for
this jurisdiction" (never a blank screen).

### Dialogs
D1 Delete confirmation (with undo) · D2 Calibration required · D3 Content expired (amber, dismissable
per session) · D4 Ambiguous zone — two rules apply · D5 First-run language confirmation (pre-selected
from system locale, one tap).

---

## 7. Data model

Two SQLite databases. The separation is deliberate: a content update replaces `reference.db` wholesale
and can never touch the user's catch log.

### 7.1 `reference.db` — read-only, shipped as an asset

```sql
PRAGMA foreign_keys = ON;

CREATE TABLE jurisdiction (
  id                INTEGER PRIMARY KEY,
  code              TEXT    NOT NULL UNIQUE,      -- 'AE-RK', 'ES-GA', 'BR-SP'
  country_iso2      TEXT    NOT NULL,
  name_key          TEXT    NOT NULL,
  authority_key     TEXT    NOT NULL,
  authority_url     TEXT,                         -- selectable text only; never launched
  has_freshwater    INTEGER NOT NULL DEFAULT 0,
  has_saltwater     INTEGER NOT NULL DEFAULT 1,
  has_zone_polygons INTEGER NOT NULL DEFAULT 0,   -- 0 => S9 hides the sub-zone level
  default_locale    TEXT    NOT NULL,
  legal_text_locales TEXT   NOT NULL,             -- CSV, e.g. 'ar' or 'gl,es' (see §9.6)
  content_version   TEXT    NOT NULL,
  published_on      TEXT    NOT NULL,
  checked_on        TEXT    NOT NULL,
  valid_until       TEXT
);

CREATE TABLE zone (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER NOT NULL REFERENCES jurisdiction(id),
  parent_zone_id  INTEGER REFERENCES zone(id),
  code            TEXT NOT NULL,
  name_key        TEXT NOT NULL,
  water_type      TEXT NOT NULL CHECK (water_type IN ('salt','fresh','both')),
  zone_kind       TEXT NOT NULL CHECK (zone_kind IN
                    ('region','subzone','bank','basin','reserve','exclusion')),
  geometry_source TEXT,                            -- attribution key; NULL when no polygon
  min_lat REAL, min_lon REAL, max_lat REAL, max_lon REAL,
  UNIQUE (jurisdiction_id, code)
);
CREATE INDEX idx_zone_juris ON zone(jurisdiction_id);
CREATE INDEX idx_zone_bbox  ON zone(min_lat, max_lat, min_lon, max_lon);

CREATE TABLE zone_ring (            -- packed little-endian Float64 [lat,lon] pairs
  id          INTEGER PRIMARY KEY,
  zone_id     INTEGER NOT NULL REFERENCES zone(id) ON DELETE CASCADE,
  ring_index  INTEGER NOT NULL,
  is_hole     INTEGER NOT NULL DEFAULT 0,
  point_count INTEGER NOT NULL,
  coords      BLOB    NOT NULL,
  UNIQUE (zone_id, ring_index)
);

CREATE TABLE family (
  id            INTEGER PRIMARY KEY,
  scientific    TEXT NOT NULL UNIQUE,   -- 'Lethrinidae'
  name_key      TEXT NOT NULL           -- localised family name -> content_string
);

CREATE TABLE species (
  id               INTEGER PRIMARY KEY,
  scientific_name  TEXT NOT NULL UNIQUE,
  col_id           TEXT,                            -- Catalogue of Life taxon id (CC BY 4.0)
  family_id        INTEGER NOT NULL REFERENCES family(id),
  taxon_group      TEXT NOT NULL CHECK (taxon_group IN
                     ('finfish','crustacean','bivalve','gastropod','cephalopod',
                      'echinoderm','elasmobranch','other')),
  silhouette_asset TEXT NOT NULL,
  plate_asset      TEXT                             -- optional; cleared per §8
);
CREATE INDEX idx_species_family ON species(family_id);

CREATE TABLE species_name (
  id          INTEGER PRIMARY KEY,
  species_id  INTEGER NOT NULL REFERENCES species(id) ON DELETE CASCADE,
  locale      TEXT NOT NULL,                        -- 'ar','es','gl','ca','pt_BR','en'
  name        TEXT NOT NULL,
  search_norm TEXT NOT NULL,                        -- normalised per §9.4
  gender      TEXT CHECK (gender IN ('m','f','n')), -- required in gendered locales; §9.5
  is_primary  INTEGER NOT NULL DEFAULT 0,
  region_hint TEXT                                  -- 'RAK', 'Rías Baixas'
);
CREATE INDEX idx_name_search  ON species_name(search_norm);
CREATE INDEX idx_name_species ON species_name(species_id, locale);

CREATE TABLE measurement_method (
  id             INTEGER PRIMARY KEY,
  code           TEXT NOT NULL UNIQUE,   -- 'TL','FL','SL','CW','CL','ML','DW','SHL','CUSTOM'
  name_key       TEXT NOT NULL,
  definition_key TEXT NOT NULL,
  diagram_asset  TEXT NOT NULL
);

CREATE TABLE citation (
  id                   INTEGER PRIMARY KEY,
  jurisdiction_id      INTEGER NOT NULL REFERENCES jurisdiction(id),
  instrument_type_key  TEXT NOT NULL,     -- localised label -> content_string
  instrument_ref       TEXT NOT NULL,     -- 'MD 580/2015'
  article_ref          TEXT,
  published_on         TEXT NOT NULL,
  source_url           TEXT,              -- selectable text only
  retrieved_on         TEXT NOT NULL
);

CREATE TABLE rule (
  id                    INTEGER PRIMARY KEY,
  jurisdiction_id       INTEGER NOT NULL REFERENCES jurisdiction(id),
  zone_id               INTEGER REFERENCES zone(id),   -- NULL = whole jurisdiction
  species_id            INTEGER NOT NULL REFERENCES species(id),
  water_type            TEXT NOT NULL CHECK (water_type IN ('salt','fresh','both')),
  min_size_mm           INTEGER,
  max_size_mm           INTEGER,
  measurement_method_id INTEGER REFERENCES measurement_method(id),
  bag_limit             INTEGER,
  bag_limit_unit        TEXT CHECK (bag_limit_unit IN ('count','kg')),
  bag_limit_period      TEXT CHECK (bag_limit_period IN ('day','trip','season')),
  vessel_limit          INTEGER,
  is_protected          INTEGER NOT NULL DEFAULT 0,
  licence_type_id       INTEGER REFERENCES licence_type(id),
  notes_key             TEXT,
  citation_id           INTEGER NOT NULL REFERENCES citation(id),
  valid_from            TEXT NOT NULL,
  valid_to              TEXT,                          -- expiry does NOT delete; see §7.3
  specificity           INTEGER NOT NULL DEFAULT 0,
  CHECK (min_size_mm IS NULL OR max_size_mm IS NULL OR max_size_mm >= min_size_mm)
);
CREATE INDEX idx_rule_lookup ON rule(jurisdiction_id, species_id, water_type, valid_from);
CREATE INDEX idx_rule_zone   ON rule(zone_id);

CREATE TABLE closed_season (
  id          INTEGER PRIMARY KEY,
  rule_id     INTEGER NOT NULL REFERENCES rule(id) ON DELETE CASCADE,
  recurrence  TEXT NOT NULL CHECK (recurrence IN ('annual','fixed')),
  start_month INTEGER, start_day INTEGER,
  end_month   INTEGER, end_day   INTEGER,
  start_date  TEXT,    end_date  TEXT,
  notes_key   TEXT,
  citation_id INTEGER REFERENCES citation(id)
);

CREATE TABLE licence_type (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER NOT NULL REFERENCES jurisdiction(id),
  zone_id         INTEGER REFERENCES zone(id),
  water_type      TEXT NOT NULL CHECK (water_type IN ('salt','fresh','both')),
  code            TEXT NOT NULL,
  name_key        TEXT NOT NULL,
  description_key TEXT NOT NULL,
  citation_id     INTEGER NOT NULL REFERENCES citation(id)
);

CREATE TABLE gear_rule (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER NOT NULL REFERENCES jurisdiction(id),
  zone_id         INTEGER REFERENCES zone(id),
  species_id      INTEGER REFERENCES species(id),   -- NULL = all species
  gear_code       TEXT NOT NULL,
  gear_name_key   TEXT NOT NULL,                    -- localised gear name
  is_allowed      INTEGER NOT NULL,
  constraint_key  TEXT,                             -- 'mesh ≥ 50 mm'
  citation_id     INTEGER NOT NULL REFERENCES citation(id)
);

CREATE TABLE penalty (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER NOT NULL REFERENCES jurisdiction(id),
  offence_key     TEXT NOT NULL,
  occurrence      INTEGER NOT NULL DEFAULT 1,
  amount_min      INTEGER, amount_max INTEGER,
  currency        TEXT,
  secondary_key   TEXT,
  citation_id     INTEGER NOT NULL REFERENCES citation(id)
);

CREATE TABLE lookalike (
  id             INTEGER PRIMARY KEY,
  species_id     INTEGER NOT NULL REFERENCES species(id) ON DELETE CASCADE,
  confused_with  INTEGER NOT NULL REFERENCES species(id),
  difference_key TEXT NOT NULL,
  UNIQUE (species_id, confused_with)
);

CREATE TABLE glossary_term (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER REFERENCES jurisdiction(id),   -- NULL = global
  term_key        TEXT NOT NULL,
  definition_key  TEXT NOT NULL,
  sort_order      INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE content_change (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER NOT NULL REFERENCES jurisdiction(id),
  from_version    TEXT NOT NULL,
  to_version      TEXT NOT NULL,
  summary_key     TEXT NOT NULL,
  detail_key      TEXT,
  changed_on      TEXT NOT NULL
);

-- Dichotomous key. A leaf is a node with no question and >=1 candidate species.
CREATE TABLE key_node (
  id             INTEGER PRIMARY KEY,
  taxon_group    TEXT NOT NULL,
  parent_node_id INTEGER REFERENCES key_node(id),
  question_key   TEXT                              -- NULL on a leaf
);
CREATE TABLE key_leaf_species (
  node_id    INTEGER NOT NULL REFERENCES key_node(id) ON DELETE CASCADE,
  species_id INTEGER NOT NULL REFERENCES species(id),
  rank       INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (node_id, species_id)
) WITHOUT ROWID;
CREATE TABLE key_option (
  id           INTEGER PRIMARY KEY,
  node_id      INTEGER NOT NULL REFERENCES key_node(id) ON DELETE CASCADE,
  option_index INTEGER NOT NULL,
  label_key    TEXT NOT NULL,
  figure_asset TEXT,
  next_node_id INTEGER REFERENCES key_node(id),     -- NULL = dead end (S7 terminal state)
  UNIQUE (node_id, option_index)
);

-- Every piece of BUNDLED CONTENT text. UI chrome lives in ARB files. See §9.
CREATE TABLE content_string (
  key    TEXT NOT NULL,
  locale TEXT NOT NULL,
  value  TEXT NOT NULL,
  PRIMARY KEY (key, locale)
) WITHOUT ROWID;

-- Verbatim legal text. body_norm carries the same fold as species_name.search_norm,
-- because FTS5 unicode61 does NOT fold Arabic orthographic variants.
CREATE TABLE legal_text (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER NOT NULL REFERENCES jurisdiction(id),
  citation_id     INTEGER NOT NULL REFERENCES citation(id),
  locale          TEXT NOT NULL,
  article_ref     TEXT,
  body            TEXT NOT NULL,
  body_norm       TEXT NOT NULL,
  sort_order      INTEGER NOT NULL
);
CREATE VIRTUAL TABLE legal_text_fts USING fts5(
  body_norm, content='legal_text', content_rowid='id',
  tokenize='unicode61 remove_diacritics 2'
);

CREATE TABLE content_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
-- 'schema_version','build_date','generator_commit'
```

### 7.2 `user.db` — writable

```sql
PRAGMA foreign_keys = ON;

CREATE TABLE user_profile (
  id                  INTEGER PRIMARY KEY CHECK (id = 1),
  locale_override     TEXT,
  numeral_system      TEXT NOT NULL DEFAULT 'auto'
                        CHECK (numeral_system IN ('auto','latn','arab')),
  length_unit         TEXT NOT NULL DEFAULT 'cm' CHECK (length_unit IN ('cm','mm','in')),
  active_jurisdiction TEXT,
  active_zone_code    TEXT,
  ruler_px_per_mm     REAL,
  ruler_calibrated_at TEXT,
  capture_coordinates INTEGER NOT NULL DEFAULT 0,
  sunlight_mode       INTEGER NOT NULL DEFAULT 0,
  glove_mode          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE saved_zone (
  id                INTEGER PRIMARY KEY,
  jurisdiction_code TEXT NOT NULL,
  zone_code         TEXT NOT NULL,
  label             TEXT,
  sort_order        INTEGER NOT NULL DEFAULT 0,
  UNIQUE (jurisdiction_code, zone_code)
);

CREATE TABLE trip (
  id                INTEGER PRIMARY KEY,
  started_at        TEXT NOT NULL,
  ended_at          TEXT,
  jurisdiction_code TEXT NOT NULL,
  zone_code         TEXT NOT NULL,
  label             TEXT,
  notes             TEXT
);
CREATE INDEX idx_trip_started ON trip(started_at DESC);

CREATE TABLE catch (
  id                INTEGER PRIMARY KEY,
  trip_id           INTEGER REFERENCES trip(id) ON DELETE SET NULL,
  jurisdiction_code TEXT NOT NULL,          -- on the catch, so zone filtering works
  zone_code         TEXT NOT NULL,          -- for quick-adds with no trip
  species_id        INTEGER NOT NULL,       -- soft ref: reference.db is a separate file
  scientific_name   TEXT NOT NULL,          -- denormalised; history survives content updates
  length_mm         INTEGER,
  measurement_code  TEXT,
  outcome           TEXT NOT NULL CHECK (outcome IN ('meets','fails','attention','unknown')),
  outcome_detail    TEXT,                   -- the factual finding text as shown
  rule_citation_ref TEXT,
  content_version   TEXT,
  was_kept          INTEGER NOT NULL DEFAULT 0,
  photo_path        TEXT,
  latitude REAL, longitude REAL,            -- NULL unless opted in
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
CREATE INDEX idx_catch_created ON catch(created_at DESC);
CREATE INDEX idx_catch_trip    ON catch(trip_id);
CREATE INDEX idx_catch_species ON catch(species_id);
CREATE INDEX idx_catch_zone    ON catch(jurisdiction_code, zone_code);

CREATE TABLE species_recent (
  species_id        INTEGER NOT NULL,
  jurisdiction_code TEXT NOT NULL,
  zone_code         TEXT NOT NULL,
  use_count         INTEGER NOT NULL DEFAULT 1,
  last_used_at      TEXT NOT NULL,
  PRIMARY KEY (species_id, jurisdiction_code, zone_code)
) WITHOUT ROWID;

CREATE TABLE rule_flag (
  id           INTEGER PRIMARY KEY,
  rule_id      INTEGER NOT NULL,
  citation_ref TEXT,
  note         TEXT NOT NULL,
  created_at   TEXT NOT NULL
);

CREATE TABLE app_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
```

**Why `catch` denormalises `scientific_name`, `rule_citation_ref` and `content_version`:** a content
update can renumber or retire a rule. A three-year-old catch record must still say what it said when it
was recorded, and must be able to show which ruleset produced it. History is immutable.

### 7.3 Rule resolution — expiry does not delete

Given `(jurisdiction, zone, species, water_type, date)`:

1. Select rules matching jurisdiction + species + water_type with `valid_from <= date`.
   **Do not filter on `valid_to`.** For each `(zone_id, citation lineage)` take the row with the greatest
   `valid_from`. Tag the result `is_expired = (valid_to IS NOT NULL AND valid_to < date)`.
2. Keep rows whose `zone_id` is NULL, equals the zone, or is an ancestor of the zone.
3. Sort by `specificity` descending — exclusion 40 > reserve 30 > bank/basin 20 > subzone 10 > region 0.
4. If the top two share `specificity` and disagree, return **both** and render D4. The app never silently
   reports the more permissive rule.

**This is a correctness fix, not a nicety.** The first draft filtered on `date < valid_to`, which meant
that on the day a Spanish annual *orden de vedas* or a Brazilian piracema portaria expired, every rule
sourced from it vanished and every species fell through to "no rule recorded". Those annual instruments
are exactly the rows that carry a `valid_to`. Filtering them out would have turned a defensible frozen
snapshot into a de facto live-data product — the brief's auto-reject — and would have contradicted §4.7
and §14, both of which promise a verdict plus an amber warning.

Finding precedence: `is_protected` → closed season → `max_size_mm` → `min_size_mm` → bag limit → vessel
limit. The first failure is headlined; the rest are listed as secondary findings.

### 7.4 Migration strategy

- **`reference.db`** is shipped whole and is disposable. The content build emits a tiny separate asset,
  `assets/content_build.json` (`{"build_date": "...", "schema_version": N}`), **and** a generated Dart
  constant. On start the app compares that constant against `app_meta.content_build_date` in `user.db` —
  no database open is required to decide, which the first draft's design made circular. If they differ,
  the asset DB is extracted to application support via a temp file plus atomic rename, then the marker
  is written. A partial extraction leaves the temp file, which is deleted and retried on next launch.
- **First launch has its own budget.** Extracting ~10 MB plus building the FTS index does not fit the
  interactive-launch target, so §13 carves it out explicitly and §14 tests it separately.
- **`user.db`** uses drift's `MigrationStrategy`: numbered, forward-only, each shipping with a test that
  opens a fixture DB at version *n*, migrates, and asserts row counts and sample values. `onCreate` runs
  the schema above and inserts the singleton `user_profile` row.
- The app refuses to open a `user.db` whose `schema_version` is *higher* than it understands and says so
  plainly, rather than corrupting it (this happens on downgrade).

---

## 8. Bundled data

Every row below states a licence that permits **commercial** redistribution, names it, and says whether
it is verified. Where it is not verified, that is stated rather than glossed.

| Asset | Source | Licence | Status | Size | How it gets in |
|---|---|---|---|---|---|
| **Spanish rule rows + verbatim text** | Orde da Xunta de Galicia 27/07/2012 and successors; each CCAA's *orden de vedas* | **Art. 13 LPI**: *"No son objeto de propiedad intelectual las disposiciones legales o reglamentarias… los actos, acuerdos, deliberaciones y dictámenes de los organismos públicos, así como las traducciones oficiales."* Excludes the **disposición as a whole**, so annex tables and official diagrams are covered | ✅ Verified at [BOE](https://www.boe.es/buscar/act.php?id=BOE-A-1996-8930&p=20190302&tn=1#a13) | ~3 MB | Authored YAML → build script |
| **Brazilian rule rows + verbatim text** | IBAMA/MPA portarias; state instruções normativas | **Lei 9.610/1998 art. 8, IV** — *"os textos de tratados ou convenções, leis, decretos, regulamentos, decisões judiciais e demais atos oficiais"*. A portaria is an *ato oficial* | ✅ Verified on planalto.gov.br. ⚠️ **The exclusion is limited to *os textos***, unlike Spain's whole-disposición wording — so **graphic annexes to a Brazilian portaria are not clearly covered**. All measurement diagrams are therefore originated SVG (row below) | ~3 MB | Authored YAML → build script |
| **Gulf rule rows + verbatim text** | UAE Ministerial Decisions 580/2015, 471/2016, 500/2014; Abu Dhabi EAD Fishing Law; equivalents per state | **UAE Federal Decree-Law No. 38 of 2021 on Copyright and Neighbouring Rights, Art. 3** (successor to Federal Law 7/2002 Art. 3), which excludes official documents including the texts of laws, regulations, resolutions and decisions | ⚠️ **Cited but not independently verified in this session.** Must be confirmed, and an equivalent provision quoted for each additional Gulf state, **before that state's content ships.** Text must be transcribed from the **official gazette or ministry PDF** — never from FAOLEX's abstract or any FAO-commissioned translation, which are FAO works under FAO terms | ~3 MB | Authored YAML → build script |
| Scientific names, families | [Catalogue of Life](https://www.checklistbank.org/dataset/315777), COL26.7 | **CC BY 4.0** (`"license": "cc by"`, 5,413,595 taxa) | ✅ Verified via the ChecklistBank API. Attribution in S17 and `ATTRIBUTIONS.md` | <1 MB (clade subset) | Build script |
| **Vernacular names, all six locales** | Primary: the legal instruments themselves (they name species in the local language). Cross-check and **the sole source for English**: the **Catalogue of Life vernacular-name extension** | **CC BY 4.0** — same dataset, same attribution | ✅ | <1 MB | Build script |
| Species silhouettes | **Originated SVG line art** | Ours | ✅ | ~6 MB / ~400 species | `assets/sil/` |
| Detailed plates (optional) | Pre-1930 ichthyological works — Bloch (d. 1799), Cuvier (d. 1832), Valenciennes (d. 1865) | **Public domain by author death year, tested per jurisdiction** — see the rule below | ⚠️ Per-image clearance required | ~25 MB | `assets/plate/` |
| Measurement diagrams | Originated SVG | Ours | ✅ | <1 MB | `assets/method/` |
| Key figures | Originated SVG | Ours | ✅ | ~3 MB | `assets/key/` |
| Zone polygons — Galicia | Coordinate annexes to the Orde | Art. 13 LPI (as above) | ✅ | ~1 MB | Build script |
| Zone polygons — Brazil | **IBGE malha territorial** and **ANA Base Hidrográfica Ottocodificada** | ⚠️ **NOT covered by Lei 9.610 art. 8** — these are IBGE/ANA cartographic products, not annexes to a portaria. Each must be cleared under its own reuse terms, **or** substituted with **Natural Earth (public domain, no attribution required)** for admin boundaries | ⚠️ Unresolved; Natural Earth is the safe default | ~2 MB | Build script |
| Zone polygons — Gulf | ⚠️ **Emirate maritime boundaries are not published as coordinate polygons** in MD 580/2015 or its successors | n/a | Where no coordinate list is printed in the decision, `jurisdiction.has_zone_polygons = 0` and rules apply jurisdiction-wide (§4.4). **We do not invent boundaries.** | 0 | — |
| Fonts | Noto Sans + **Noto Naskh Arabic** | **SIL OFL 1.1** — bundling permitted; the font files are not renamed and the OFL text ships in S17 | ✅ | ~8 MB subset | `assets/fonts/` |

**Total bundle target: 55–70 MB.** Under the 100 MB preference, so no size trade-off argument is needed.

### The public-domain test for plates — corrected

The first draft used "pre-1930 = public domain". **That is the US rule and is the wrong test for every
market this app ships to.** Spain and the EU run from the author's death (life+70, with Spain's TRLPI
transitional rule giving **80 years pma** for authors who died before 7 Dec 1987); Brazil is life+70
(Lei 9.610 art. 41); the UAE is life+50. Publication date is irrelevant.

The build tool therefore enforces, per image, a hard assertion alongside the existing citation checks:

```
require(illustrator_name is not null and illustrator_death_year is not null)
require(current_year > illustrator_death_year + 80)   # ES, the longest term we ship into
```

Every plate's illustrator and death year is recorded in `ATTRIBUTIONS.md` and rendered in S17.
**Any plate whose artist cannot be identified is dropped.** Note this specifically excludes the plates
of Jordan & Evermann's *Fishes of North and Middle America* unless each staff illustrator is identified
and cleared — Jordan (d. 1931) and Evermann (d. 1932) clear the test, but the artists are a separate
question the first draft simply missed.

### The content pipeline is a first-class deliverable

`tools/build_content/` takes hand-authored YAML plus the CoL extract and emits `reference.db`. It must:

- validate every rule row against a schema (a rule with `min_size_mm` and no `measurement_method_id` is a build error);
- assert every `*_key` — including `family.name_key`, `citation.instrument_type_key` and `gear_rule.gear_name_key` — resolves in `content_string` for **every** shipped locale, and fail otherwise;
- assert every `species_name` row in a gendered locale (`ar`, `es`, `gl`, `ca`, `pt_BR`) has a non-NULL `gender`;
- assert every `citation_id` exists and has a `retrieved_on` date;
- assert every rule's species has a silhouette and ≥1 vernacular name per locale;
- assert every plate passes the illustrator death-year test above;
- populate `search_norm` and `body_norm` with the same normalisation function the app uses, imported from the shared package — not reimplemented;
- run the **rule engine's own resolution logic** (§7.3, a pure Dart library with no Flutter imports) over the authored data to catch contradictions before they ship;
- emit the per-jurisdiction diff into `content_change`.

**Authoring volume, stated plainly:** roughly 100–150 rule rows per jurisdiction (the UAE decisions alone
carry 100+), ~400 species, ~2,400 vernacular names across six locales, ~400 silhouettes, and the verbatim
legal text. This is several weeks of careful, checkable work, and it includes a **named budget line for a
paid Arabic-speaking transcriber** to work from the official gazette PDFs (§16 R1). The code is a
fortnight; the content is the moat, and it is why nobody has built this.

---

## 9. Localization plan

### 9.1 Languages shipped, and why these

| Locale | Why this one | Evidence |
|---|---|---|
| **`ar` (RTL)** | The Gulf artisanal fleet is Arabic-first with low English. Species must appear as هامور، شعري، صافي، بدح، كنعد — not as Latin binomials. **This is the moat, and it is not optional** (§16 R1) | `الاطوال المسموحة للاسماك` returns **0 results in the AE, SA, KW, OM, QA and BH storefronts**; `دليل الصياد` and `الصيد البحري` return only weather apps, arcade games and English AI identifiers. Re-confirmed by an independent reviewer 2026-07-27 |
| **`es`** | Spain's fishing regulation is per-comunidad-autónoma and Spanish-language | The nearest incumbent, NORMAP, is Canarias-only and Spanish-only (§ SHORTLIST competitors) |
| **`gl`** | Galicia is Europe's marisqueo heartland and the Xunta publishes its size tables **in Galician** | [pescadegalicia.gal](https://www.pescadegalicia.gal/gl/tallas-minimas); the one Galician app, *Non piques – Non peques*, has not been updated since 2019-04-09 |
| **`ca`** | Catalonia, Valencia and the Balearics publish their own fishing orders in Catalan | Same statutory basis (Art. 13 LPI) |
| **`pt_BR`** | Piracema, minimum sizes and quotas are per-state and Portuguese-language | `pesca defeso tamanho minimo` → **0 results** in the BR store; Play BR returns only games |
| **`en`** | Baseline, plus expatriate and visiting anglers in every region above | — |

English plus five, including one RTL. On whether `gl` and `ca` are padding: they are not, and the test is
that each is the **official publication language of the instrument being bundled**. The Xunta publishes
tallas mínimas in Galician; Catalonia, Valencia and the Balearics publish their fishing orders in Catalan.
A Spanish-only app would be presenting a Galician legal text in translation to a Galician-speaking
mariscadora. That is exactly the work an English-reading indie developer never does.

### 9.2 Two-tier translation — the part most apps get wrong

- **Tier 1 — UI chrome:** standard Flutter ARB. `lib/l10n/app_en.arb` … `app_ar.arb`, `app_gl.arb`,
  `app_ca.arb`, `app_pt_BR.arb`, `app_es.arb`. Generated by `flutter gen-l10n`. ~400 strings.
- **Tier 2 — bundled content:** species names, family names, measurement definitions, rule notes, gear
  names and constraints, licence descriptions, penalty descriptions, glossary, key questions and options,
  jurisdiction and zone names, instrument-type labels — all in `content_string(key, locale, value)`.

Tier 2 is *domain* translation and cannot be handed to a general translator. Sourcing:

1. **Preferred — lift it from the legal instrument itself.** Every jurisdiction's order already names its
   species, gear and measurement methods in the local language, that text is copyright-free, and it is by
   definition the authoritative wording. Primary source for `ar`, `es`, `gl`, `ca`, `pt_BR`.
2. **English has no such source** — no UAE, Xunta, CCAA or IBAMA instrument names species in English.
   English vernacular names come **solely from the Catalogue of Life vernacular-name extension (CC BY 4.0)**,
   which is already in the bundle and already attributed. **FAO ASFIS is explicitly not used**: FAO's site
   terms permit copying for private study, research, teaching and **non-commercial** products only, with
   commercial use requiring written permission. That is incompatible with a paid app, and the first draft
   named ASFIS without checking.
3. **Review** by one native-speaking fisher or fisheries officer per locale before release. Budgeted.
   A wrong vernacular name is worse than no name, because it produces a confident wrong finding.
4. English is the *last* Tier-2 language authored, not the first.

**Fallback chain:** requested locale → jurisdiction `default_locale` → `en` → scientific name. A missing
Tier-2 string never renders a raw key or an empty string, because the build fails first (§8).

### 9.3 RTL and numerals

- `MaterialApp` with `supportedLocales`; no hardcoded `Directionality` anywhere.
- All padding and alignment use `EdgeInsetsDirectional` / `AlignmentDirectional` / `start`/`end`.
  A lint rule bans `EdgeInsets.only(left:` and `right:` in `lib/`.
- **The ruler does not mirror.** A physical measuring scale runs from the same edge regardless of script
  direction; mirroring it would put zero at the wrong end of a real fish. The ruler widget wraps itself in
  `Directionality(textDirection: TextDirection.ltr)` while its *labels* localise their numerals. A
  deliberate exception, commented as such in the code. Measurement diagrams likewise do not mirror — a
  fork-length arrow must point at the actual fork.
- **Numerals — corrected twice.** CLDR 48 gives `ar` and `ar-AE` `defaultNumberingSystem: "latn"`; the
  first draft asserted the opposite, so **plain `ar` renders Western digits** and that is the correct
  default for Khalid in RAK.
  ⚠️ **Implementation reality differs from CLDR and this is what the builder will actually hit.** Dart's
  `intl` 0.20.2 has **no numbering-system API at all**, and the `-u-nu-` Unicode extension is *accepted
  as a string and silently discarded* (`ar-u-nu-arab` → `1,234,567`). Its `number_symbols_data.dart`
  contains **only three** Arabic entries — `ar`, `ar_DZ`, `ar_EG`. So `ar_SA`, `ar_MA` and `ar_AE` all
  fall back to `ar` and render Latin digits regardless of what CLDR says, and `ar_DZ` renders Latin
  digits with *European* separators (`1.234.567,89`) and a different month name.
  **The only supported lever is the public mutable `numberFormatSymbols` map**, where `ZERO_DIGIT` *is*
  the numbering system (`NumberFormat` computes `zeroOffset = ZERO_DIGIT.codeUnitAt(0) - asciiZero`):
  `numberFormatSymbols['ar'] = numberFormatSymbols['ar_EG']!;`
  This is **process-wide and order-dependent** — it must run in `main()` before the first `NumberFormat`
  is constructed, and it will silently corrupt golden tests sharing an isolate unless reset in
  `setUp`/`tearDown`. `user_profile.numeral_system` (`auto`/`latn`/`arab`, exposed in S14) is therefore
  implemented by swapping that map entry at bootstrap, **not** by passing a locale extension.
- Golden tests render every screen in `ar` and assert no overflow.

### 9.4 Text normalisation

One shared function, used identically when building `species_name.search_norm` / `legal_text.body_norm`
and when normalising a query. Unit-tested in both directions.

**Arabic, in order:**
1. **NFKC** — folds Arabic Presentation Forms (U+FB50–U+FEFF), which is exactly what OCR of the gazette
   PDFs emits. The first draft omitted this.
2. Strip tatweel (U+0640) and all harakat.
3. `أ إ آ ٱ` → `ا` · `ؤ` → `و` · `ئ` → `ي`.
4. **Collapse word-final `ة`, `ه` and `ى` to a single terminal form**, so `هامورة` and `هامور` share a
   prefix. The first draft folded `ة`→`ه`, which produced `هاموره` — neither equal to nor a prefix of
   `هامور`, so its own acceptance test could not pass.
5. **Strip a leading definite article `ال`, and index both the stripped and unstripped forms**, because
   legal instruments write `الهامور` while users type `هامور`.
6. Map Arabic-Indic (U+0660–0669) and Eastern Arabic-Indic (U+06F0–06F9) digits to ASCII.

**Latin:** NFD, strip combining marks (`ñ`→`n`, `ç`→`c`, `ã`→`a`, `á`→`a`), lowercase. Needed by
Galician, Catalan, Spanish and Portuguese.

**Acceptance test (must exist as a unit test):** `hamour`, `هامور`, `هامورة`, `الهامور` and
`Epinephelus coioides` all resolve to one species id.

### 9.5 Plurals and gender

- **Plurals.** Arabic needs all six ICU categories (`zero`, `one`, `two`, `few`, `many`, `other`);
  an `ar` ARB entry missing any is a build failure. **Corrected against CLDR 48:** `es`, `ca` and `pt`
  each carry a `many` category, so those three use `one`/`many`/`other`. Only `gl` is `one`/`other`.
  The first draft asserted `one`/`other` for all four.
- **Gender.** Species, gear and zone names carry grammatical gender in five of six locales
  ("la lubina" vs "el rodaballo"). `species_name.gender` (and the equivalent on gear and zone name rows)
  stores it, and the build asserts it is non-NULL in every gendered locale — the first draft specified
  ICU `select` on a gender field that existed nowhere in the schema.
  Sentence templates that must inflect use ICU `select` on that field. **Content strings are otherwise
  authored as complete phrases, never assembled from fragments**, and an adjective is never concatenated
  onto a name at runtime.
- **Dates:** `intl`, locale-formatted. Season windows read "1 March – 30 April", never `2026-03-01`.
- **Numbers:** locale decimal separator (`45,5 cm` in es/pt_BR/gl/ca).
- **Units:** cm default everywhere; inches available, and default only for `en` with a US device region.
  Everything is **stored as integer millimetres**; conversion is display-only.
- **Currency:** each jurisdiction's own currency via `NumberFormat.currency`, never converted.

### 9.6 Verbatim legal text is single-locale, and the app says so

Bundled law exists **only in the language(s) the authority published it in** — Arabic for the Gulf,
Galician and/or Spanish for Galicia, Catalan for Catalonia, Portuguese for Brazil. We do not translate
legal text; an unofficial translation of a penal instrument would be both a liability and, in Spain,
outside the Art. 13 carve-out (which covers *official* translations only).

`jurisdiction.legal_text_locales` records what exists. S13 renders a language-availability notice when
the user's preferred locale is not among them. The §9.2 fallback chain applies to `content_string` only
and never silently substitutes a different language of law.

---

## 10. Tech stack

| Choice | Version | Why |
|---|---|---|
| **Flutter** | 3.24+ / Dart 3.5+ (stable) | Cross-platform requirement; mature RTL and `gen-l10n` |
| **drift** | ^2.20 | Chosen over sqflite, Isar and Hive deliberately: §7.3's resolution is genuinely relational (joins across rule, zone ancestry, closed_season, citation, content_string) and needs real SQL with indices. Drift gives compile-time-checked SQL, FTS5 access, a tested migration API, and — decisively — **two independent database instances in one app**. Isar and Hive are object stores and would force this into Dart. Raw sqflite loses type safety and migration testing |
| **sqlite3_flutter_libs** | ^0.5 | Bundles a modern SQLite with FTS5 compiled in |
| **flutter_riverpod** | ^2.5 | Compile-safe DI; the rule engine sits behind a provider as a pure function and is unit-testable without a widget tree |
| **flutter_localizations** + **intl** | SDK / ^0.19 | ARB, ICU plurals, CLDR numbering systems, per-locale formatting |
| **flutter_svg** | ^2.0 | Silhouettes, diagrams, key figures. ⚠️ **Transitively depends on `http`** (for `SvgPicture.network`). On the documented exception list; `SvgPicture.network` is grep-banned |
| **geolocator** | ^13.0 | Single-shot GPS fix only. No geocoding, no map, no network |
| **path_provider** | ^2.1 | Application-support directory |
| **camera** | ^0.11 | In-app capture so photos never enter the shared camera roll. `image_picker` is rejected for exactly that reason |
| **pdf** + **printing** | ^3.11 / ^5.13 | Trip report; `printing` also gives the share/print sheet, and both handle RTL with an embedded Arabic font. ⚠️ **`printing` transitively depends on `http`** (for `PdfGoogleFonts`). On the exception list; `PdfGoogleFonts` is grep-banned. **Fonts load only via `pw.Font.ttf(rootBundle.load(...))`** |
| **share_plus** | ^10.0 | Hand a file to the OS share sheet — the only outbound path, user-initiated and app-external. ⚠️ Pulls `url_launcher_platform_interface` transitively; on the exception list, and `launchUrl` is grep-banned |
| **file_picker** | ^8.1 | Import |
| **package_info_plus** / **device_info_plus** | ^8.0 / ^10.1 | Version display; screen-metric sanity checks for calibration |
| **vector_math** | ^2.1 | Point-in-polygon and bbox maths |

**Explicitly banned, and enforced by CI (§14):** `http` as a *direct* dependency, `dio`,
`connectivity_plus`, any `firebase_*`, any analytics, crash-reporting or ad SDK, `google_maps_flutter`,
`flutter_map`, `webview_flutter`, **`url_launcher`**, `android_intent_plus`, `image_picker`,
`flutter_secure_storage` (the first draft listed an optional app PIN backed by nothing in §4, §6 or §7;
the PIN is **removed from scope** rather than left half-specified).

**Maintenance flags:** `printing` and `pdf` share one maintainer and are the only single-maintainer
dependency on the critical path — PDF generation is isolated behind a `TripReportRenderer` interface so
it can be swapped without touching callers.

**Architecture:** feature-first folders (`features/check`, `features/species`, `features/ruler`,
`features/log`, `features/reference`, `features/settings`) over `core/` (rule engine, localisation,
normalisation, database, theming). The **rule engine and the normalisation functions are a pure Dart
package with no Flutter imports**, shared with `tools/build_content/` so the data is validated by the
same code that will interpret it.

---

## 11. Platform specifics

### Android

- **The release manifest does not grant `INTERNET`.** Full element, in
  `android/app/src/release/AndroidManifest.xml`:
  ```xml
  <manifest xmlns:android="http://schemas.android.com/apk/res/android"
            xmlns:tools="http://schemas.android.com/tools">
      <uses-permission android:name="android.permission.INTERNET" tools:node="remove" />
  </manifest>
  ```
  The `xmlns:tools` declaration is required or the build fails — the first draft's snippet omitted it.
  **Debug and profile builds retain `INTERNET` by design**, because Flutter's hot reload and the profile
  VM service need it; the removal applies to the release source set only. The Play data-safety form can
  then honestly declare that no data is collected or shared.
- Permissions, all optional and deferred to first use: `ACCESS_COARSE_LOCATION` / `ACCESS_FINE_LOCATION`
  (zone suggestion), `CAMERA` (catch photos). No storage permission — scoped storage plus SAF via share.
- `android:allowBackup="false"`, no `dataExtractionRules` — the catch log must not be swept into a
  Google backup the user did not choose. Portability is served by explicit export (§12).
- minSdk 24 (Android 7.0). Target device is a three-year-old mid-range phone.
- Files in `context.getFilesDir()` (app-private). No services, no `WAKE_LOCK`, no boot receiver.

### iOS

- **There is no iOS equivalent of removing the INTERNET permission, and the first draft's proposed proofs
  were worthless.** ATS blocks only cleartext HTTP and permits every TLS 1.2+ request; and "links no
  `Network.framework`" is not a test, because `dart:io`'s HttpClient uses BSD sockets in libSystem and
  `URLSession` comes from Foundation/CFNetwork, which the Flutter engine links unconditionally.
  The iOS guarantee rests on: (a) the CI dependency allowlist and API grep, and (b) a **mandatory device
  packet capture** before every release (§14). ATS is retained as defence-in-depth only, and is documented
  as not blocking HTTPS.
- `Info.plist` usage strings, localised into all six languages:
  `NSLocationWhenInUseUsageDescription`, `NSCameraUsageDescription`.
  **`NSLocationAlwaysAndWhenInUseUsageDescription` is not declared.**
- Files in Application Support. `NSURLIsExcludedFromBackupKey` is **not** set — iCloud device backup is
  the user's own encrypted backup and is acceptable; what we exclude is any *vendor* server. This
  differs deliberately from Android's `allowBackup="false"`, where the destination is Google's servers
  under a different trust model. Both choices are explained in S17.
- Minimum iOS 13. No background modes, no push entitlement, no App Groups, no Siri intents.

### Both

- **No push notifications of any kind** — there is no server to send them.
- Locale follows the system by default; the S14 override persists independently, because a
  Galician-speaking user may run a Spanish-locale phone.
- Dark mode supported; **sunlight mode is a third theme**, not a variant of either.
- Landscape on S3 (a 25 cm fish fits better across a phone held sideways) and S13; portrait elsewhere.

---

## 12. Data portability

There is no cloud, so this is load-bearing.

**Export (S15)**, via the system share sheet:

1. **`catchlaw-export-YYYYMMDD.json`** — the complete user dataset: profile, saved zones, trips, catches,
   rule flags, plus a header with `app_version`, `user_db_schema_version`, per-jurisdiction
   `content_versions` and `exported_at`. The round-trip format.
2. **`catches-YYYYMMDD.csv`** — flat, UTF-8 **with BOM** so Excel opens Arabic and Galician correctly;
   one row per catch; headers localised to the active language.
3. **`trip-report-YYYYMMDD.pdf`** — per trip: header, catch table, totals against limits, the content
   version and citation behind each finding, and the disclaimer. The artefact a fisher can hand to an
   inspector, a cofradía or an insurer. Rendered with the bundled Arabic font, never a downloaded one.
4. **Photos** — optional; when included the export is a `.zip` containing the JSON, CSV, PDF and a
   `photos/` directory, with `photo_path` rewritten to relative paths.

**Import (S16)** accepts the JSON or the zip, shows a preview (counts of trips, catches, flags; source
app version), and requires an explicit choice:

- **Merge** — deduplicates on `(created_at, species_id, length_mm)`; existing records win on conflict.
- **Replace** — wipes and restores; requires typing a confirmation word.

Import is transactional: a malformed file writes nothing and names the specific failure. A file from a
*newer* schema version is refused with a clear message rather than partially applied.

**Manual escape hatch:** S14 shows the on-device path of `user.db` and offers "Export raw database file",
so a user can open their data in SQLite on a laptop without our cooperation.

---

## 13. Non-functional requirements

| Requirement | Target | How it is met |
|---|---|---|
| **First launch** (one-time content extraction) | **< 6 s** on a Snapdragon 665, with a **determinate progress indicator** | ~10 MB asset copy + FTS index build. Carved out explicitly — it cannot fit the interactive target, and pretending otherwise was a defect in the first draft |
| Subsequent cold start to interactive Check | **< 1.2 s** on the same device | `reference.db` opened lazily read-only; recents from one indexed query; no asset decoding on the launch path; no splash animation |
| Species search latency | < 50 ms at 400 species / 2,400 names | Indexed `search_norm`, prefix query, capped at 40 results |
| Rule evaluation | < 10 ms | Pure Dart over ≤ 20 candidate rows |
| Point-in-polygon zone match | < 100 ms across all bundled zones | Indexed bbox prefilter, then ray-casting only on survivors |
| Legal-text FTS | < 200 ms | FTS5 over `body_norm` |
| Low-end devices | Fully usable on 2 GB RAM, Android 7 | No image caching beyond the visible grid; SVGs rasterised at display size and cached by key; plates loaded only on S2 |
| DB size at realistic usage | 5 yrs × 200 trips × 8 catches ≈ 8,000 rows ≈ **< 4 MB**, plus ~200 KB per photo | Photos are the only real growth; S14 shows usage and offers bulk photo purge that keeps the records |
| Battery | Negligible | No background execution, no polling, no radios. GPS is single-shot, user-initiated, 20 s timeout |
| Offline guarantee | See §5.3 and §14 | |
| Accessibility | WCAG 2.1 AA equivalent | Contrast ≥ 4.5:1 (≥ 7:1 in sunlight mode); targets ≥ 48 dp (≥ 56 dp glove mode); every control labelled; the result announced as a live region; layouts hold at 200% text scale; never colour alone |
| Crash safety | Data loss unacceptable | Every write transactional; the catch is persisted before the UI animates; no in-memory-only state that matters |
| Localisation completeness | Enforced | The content build fails on any missing `content_string` key in any shipped locale; CI fails on any ARB key missing from any locale, and on any `ar` plural missing a category |

---

## 14. Offline verification checklist

Pass/fail, on physical devices of both platforms, before every release.

**Static (CI — these fail the build):**

- [ ] Direct-dependency allowlist diff: the checked-in allowlist is the only permitted set. **`http` must appear only as a transitive edge from exactly `printing` and `flutter_svg`; `url_launcher_platform_interface` only from `share_plus`.** A third edge, or any direct `http`, fails.
- [ ] `grep -rnE "package:http|package:dio|HttpClient|Socket|WebSocket|firebase|connectivity_plus|PdfGoogleFonts|SvgPicture\.network|Image\.network|NetworkImage|url_launcher|launchUrl|AndroidIntent|ACTION_VIEW" lib/` returns nothing.
- [ ] The built release `AndroidManifest.xml` (via `aapt2 dump xmltree` on the AAB) contains **no** `android.permission.INTERNET`, and no background-location permission.
- [ ] `Info.plist` declares no ATS exceptions and no `NSLocationAlwaysAndWhenInUse`.
- [ ] Every ARB key exists in all six locales; every `ar` plural has all six categories.

**Dynamic (manual, on device):**

- [ ] **Cold first launch, fresh install, airplane mode enabled before the install completes.** Content extraction runs to completion with a determinate progress indicator, in under 6 s, and the app reaches Check. Nothing is downloaded.
- [ ] Force-quit **during** first-launch extraction; relaunch; extraction restarts cleanly and no corrupt DB is left behind.
- [ ] With airplane mode on **and** Wi-Fi off **and** cellular off: complete the full core loop — species, ruler calibration, measurement, finding, add to tally. Then repeat using **manual length entry before ever calibrating**, confirming the loop is complete on a virgin install.
- [ ] Every screen S1–S23 and dialogs D1–D5 reachable and functional in airplane mode. **Specifically confirm S7 is reachable from S1, S5's empty state and S6.**
- [ ] Arabic full-text search of the legal text returns results in airplane mode (`هامور` and `الهامور` both hit).
- [ ] Tapping a citation expands S13 and copies to clipboard. **No browser opens.**
- [ ] Export produces all four artefacts and the share sheet appears, in airplane mode. The PDF renders Arabic with the bundled font.
- [ ] Import of a previously exported zip succeeds, in airplane mode.
- [ ] Deny location permission: S9 remains fully usable and states why nothing was suggested.
- [ ] Deny camera permission: catches still recordable without a photo.
- [ ] **Expiry test — this is a correctness test, not a cosmetic one.** Set the device clock past a specific rule's `valid_to`. Assert (a) the amber bar appears **and** (b) that rule still produces a finding with its numbers intact. A "no rule recorded" result here is a failure.
- [ ] Set the clock **backwards** two years: seasonal rules evaluate against the device date without crashing, and the date used is displayed.
- [ ] Reinstall: confirm the catch log is gone (Android `allowBackup=false`) and that a pre-taken export restores it completely.
- [ ] **Packet capture, not a proxy.** A Charles/mitmproxy HTTP proxy is insufficient — Dart's `HttpClient` ignores the system proxy unless `findProxy` is set, so the most likely failure mode is invisible to it. Use **PCAPdroid or `tcpdump` on Android and `rvictl -s <udid>` + Wireshark on iOS**, capturing **while walking every screen S1–S23 and exercising export, import, GPS, camera, PDF render and SVG load**. Assert zero packets from the app's uid.
- [ ] Android per-uid byte counters: `TrafficStats.getUidRxBytes/getUidTxBytes` before and after that full walkthrough — delta must be exactly zero.
- [ ] Run the entire loop with the device in `ar` locale and RTL: the ruler reads correctly left-to-right, the numbering system matches the resolved locale (Western for ar-AE), and no layout overflows.

---

## 15. Build order

Dependencies in brackets. An ordering for the builder, not a release plan.

1. **Skeleton + CI** — project, feature-first folders, lint rules (including the directional-padding ban), and every §14 static check wired in from commit one, so the offline guarantee can never regress. *[—]*
2. **Shared pure-Dart core** — normalisation functions (§9.4) with their acceptance test, and the rule-resolution engine (§7.3) including expiry semantics, D4 ambiguity, and leap-year season boundaries. No Flutter imports. *[1]*
3. **Content schema + build tool** — YAML schema, every assertion in §8 (including gender, plate death-year, and `*_key` completeness), and the generator. Imports the §2 package so data is validated by the code that will read it. Seed with **Galicia**. *[2]*
4. **Data layer** — drift schemas for both DBs, `content_build.json` marker, atomic extraction with temp-file + rename, migration tests. *[3]*
5. **Localisation infrastructure** — ARB wiring, `content_string` resolver with the fallback chain, CLDR numbering-system resolution, plural-category CI check. Early, because retrofitting RTL is expensive. *[4]*
6. **Species search, browse, detail (static half)** — S5, S6, S2 without measurement. *[2,4,5]*
7. **Ruler + calibration** — S3, S4, step-and-mark, the deliberate LTR exception. Validate against a printed scale on three physical devices before proceeding. *[5]*
8. **Result UI** — S2 complete: factual-statement banner (§5.1), findings list, citation row expanding into S13, disclaimer, look-alike card, **Flag this rule**, amber expiry bar (D3). *[2,6,7]*
9. **Zone picker + point-in-polygon** — S9, bbox prefilter, ray-casting, GPS as suggestion, `has_zone_polygons = 0` handling. *[4]*
10. **Check home + bottom nav** — S1, recents, tally bar, all four species entry points. **First point at which the 5-second target is testable.** *[6,8,9]*
11. **Catch log** — S8, S10, S11: trips, catches with jurisdiction/zone codes, in-app camera, tally, zone filtering. *[4,10]*
12. **Identification key** — S7 with `key_leaf_species` candidate lists, dead ends, decision trail, and its three entry points. *[4,6]*
13. **Reference section** — S12, S13 (with Arabic FTS over `body_norm` and the language-availability notice), S18, S19, S20, S21, S22, S23. *[4,5]*
14. **Settings** — S14: language override, numeral system, units, modes, calibration entry, storage used + bulk photo purge. *[5,7,11]*
15. **Export / import** — S15, S16: JSON, CSV, PDF (bundled Arabic font), zip, merge/replace, transactional import. *[11]*
16. **About / attributions** — S17 rendering `ATTRIBUTIONS.md` in full, including every plate's illustrator and death year, the OFL text, and the no-collection statement. *[13]*
17. **Accessibility, sunlight and glove modes** — semantic labels, live regions, 200% audit, contrast audit, haptics, target sizes. *[all UI]*
18. **RTL and locale hardening** — golden tests in all six locales, Arabic plural categories, numeral-system resolution, the §9.4 acceptance test on real data. *[17]*
19. **Content authoring at scale** — the remaining jurisdictions, native-speaker review per locale, citation capture, plate clearance. **Runs in parallel from step 3 onward and is the long pole.** *[3]*
20. **Store presence** — localised listings and per-locale display names, data-safety declarations, screenshots shot in `ar` and `gl` rather than only `en`. *[all]*

---

## 16. The three riskiest assumptions

Each testable in under a day, without writing the app.

### R1 — "The Gulf legal texts can actually be obtained and transcribed."
The biggest one, and the reason criterion 3 scored 4 rather than 5. UAE Ministerial Decision 580/2015
and its successors are referenced everywhere, but neither candidate PDF (FAOLEX `uae165183.pdf`, EAD
`Fishing-Law-2023.pdf`) could be text-extracted during research. Arabic is the moat.

**One-day test:** on a normal machine, download the official **gazette/ministry** PDFs (not FAOLEX
abstracts) and run `ocrmypdf` + Tesseract `ara`. Count how many species rows with a numeric minimum
length come out clean. Cross-check twenty against a second published source.
**Pass = ≥ 80 species rows transcribed with confidence in a day.**

**If it fails, the mitigation does not remove Arabic from the product.** The first draft said "ship
Galicia + Spain + Brazil first and treat Arabic as a content problem" — that is a release phase that
deletes the only RTL locale and the stated moat, and it contradicts both this spec's own preamble and
the brief's requirement of multi-language *including RTL* from the start. The correct mitigation is a
**named budget line for a paid Arabic-speaking transcriber working from the official gazette** (already
carried in §8). **The app does not ship until Arabic rule rows exist.**

### R2 — "Fishers will pay for this, and the association channel works."
Everything rests on a 2019 news article about one association and a set of 1-star reviews. Nobody has
told me they would buy it.

**One-day test:** build a one-page mockup — the result screen, in Arabic and in Galician, with three
real species and their real numbers — and send it to twenty named organisations: the RAK Fishermen's
Association, the Dubai Fishermen's Co-operative, and eighteen Galician *confrarías* via the Federación
Galega de Confrarías. Ask one question: *"does this exist already, and would your members use it?"*
**Pass = ≥ 4 substantive replies, and at least one saying no such thing exists.** Note this test now has
to survive a harder bar: NORMAP already does much of this for the Canaries, so a reply of "yes, we have
NORMAP" is a real possible outcome and would force a rethink of the Spanish half.

### R3 — "An on-screen ruler is accurate and trusted enough to bet a fine on."
A 45 cm minimum with a 3 mm error is real legal exposure, and if fishers do not trust the ruler they
will use manual entry and the feature is dead weight.

**One-day test:** a single static HTML page with ID-1 card calibration and a ruler. Load it on six phones
from cheap Android to current iPhone. Measure a printed 300 mm engineering scale ten times per device
and record the error distribution. **Pass = median absolute error ≤ 1.5 mm over 150 mm, no device worse
than 3 mm.** Then hand two phones to actual fishers with wet hands and watch whether they use the ruler
or type the number. If the ruler fails, manual entry plus the measurement diagram is still a complete
product — but the feature list and the marketing change, so find out first.

---

## 17. Validation plan

1. **Gulf** — approach the **Ras Al Khaimah Fishermen's Association** and the **Dubai Fishermen's
   Co-operative Society** directly; they already commissioned an app for exactly this and are the most
   qualified group on earth to say whether this one is needed.
2. **Galicia** — post the Galician mockup to the **Federación Galega de Confrarías de Pescadores** and to
   the confrarías already shipping notice-board apps (**Confraría de Muros**, **Lonxa de Campelo**), and
   ask the Xunta's *Pesca de Galicia* team why **Non piques – Non peques** has not been updated since 2019.
3. **Spain, angler side** — reply publicly to the 1–2★ reviewers of **PescaREC** (58 written reviews in
   the ES storefront) and **Pesca en Castilla y León**, whose specific complaints — a licence check that
   locks you out, and published season dates that are simply wrong — are what this app answers. Then ask
   Canarian fishers directly whether **NORMAP** works for them offline, because that answer decides
   whether Spain is a real market or a solved one.
4. **Brazil** — contact **Pesca na Regra**, who have already normalised all 27 states as a website and
   know exactly how often the rules change; then two or three **colônias de pescadores** and pesqueiro
   operators in São Paulo and Minas Gerais.
5. **Cross-cutting** — ask each group a disconfirming question rather than a leading one: *"What do you
   use today when you're not sure, and what would have to be true for you to stop using it?"* A group
   that answers "I just know" is telling you the app is unnecessary for them, and that is worth more than
   a polite yes.
