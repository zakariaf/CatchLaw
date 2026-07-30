# Phase 6 — Adversarial review: what was found and what changed

Three reviewers with fresh context attacked `SPEC.md`, `SHORTLIST.md` and `IDEAS.md` in separate lanes:
(1) offline guarantee + evidence integrity, (2) licensing + competitors, (3) localisation + completeness.
They were instructed to report only defects affecting correctness or the brief's stated requirements, to
verify rather than trust, and to say "nothing found" rather than invent.

They returned **30 findings: 5 blockers, 20 major, 5 minor.** All 30 were accepted and fixed. Nothing was
dismissed. Below is what each was and what changed.

---

## Blockers

### B1 — "No HTTP client is linked" was false
`printing` declares `http` as a direct dependency (for `PdfGoogleFonts`), and `flutter_svg` declares it
too (for `SvgPicture.network`). Both are on the required stack, so the spec's central claim was untrue
and its own CI gate ("`flutter pub deps` contains no networking package") could never have passed.
Worse, neither `PdfGoogleFonts` (which fetches TTFs from `fonts.gstatic.com` at render time) nor
`SvgPicture.network` was banned anywhere — and on iOS, with no OS-level backstop, either would have
succeeded silently.

**Fixed:** `SPEC.md` §5.3 now states the guarantee accurately — no HTTP client is *used*; `http` appears
transitively via exactly two documented, CI-diffed edges. §14 replaces the impossible gate with an
allowlist diff that fails on a third edge, and adds `PdfGoogleFonts|SvgPicture.network|Image.network|NetworkImage`
to the grep. §10 requires PDF fonts to load via `pw.Font.ttf(rootBundle.load(...))`.

### B2 — English vernacular names had no licensed source
§9.2 named the legal instruments as the source for `ar/es/gl/ca/pt_BR` and excluded English — but no
UAE, Xunta, CCAA or IBAMA instrument names species in English. The fallback named was FAO ASFIS, whose
licence the spec never stated. The reviewer fetched FAO's terms: copying is permitted for private study,
research, teaching and **non-commercial** products; commercial use requires written permission.

**Fixed:** ASFIS is dropped entirely. English vernacular names now come solely from the **Catalogue of
Life vernacular-name extension (CC BY 4.0)**, already bundled and already attributed. The `species.fao3a`
column is **deleted** — nothing read it and its licence was unnamed.

### B3 — §16 R1 contained a phased launch that shipped without Arabic
The risk mitigation read "ship Galicia + Spain + Brazil first and treat Arabic as a content problem… only
the launch order changes." That is a release phase that deletes the only RTL locale and the app's stated
moat, contradicting both the spec's own "no v2" preamble and the brief's requirement of multi-language
including RTL from the start. And the branch was live, not hypothetical — the UAE PDFs are flagged
unverified.

**Fixed:** the fallback sentence is deleted. R1 is now a content-*acquisition* risk whose mitigation
keeps Arabic in scope: a named budget line for a paid Arabic transcriber working from official gazette
PDFs, carried in §8's authoring paragraph. **The app does not ship until Arabic rule rows exist.**

### B4 — "Pre-1930 = public domain" is a US-only rule
The ~25 MB of bundled plates were cleared by publication date. Spain/EU run life+70 (Spain's TRLPI
transitional rule gives **80 years pma** for pre-1987 deaths), Brazil life+70, UAE life+50 — all from the
author's death. Bloch and Cuvier/Valenciennes are safe; Jordan (d. 1931) and Evermann (d. 1932) clear —
**but their plates' staff illustrators were never named and their death years never established.**

**Fixed:** §8 replaces the publication test with a per-image, per-jurisdiction death-year test, asserted
in the content build (`current_year > illustrator_death_year + 80`). Illustrator and death year are
recorded in `ATTRIBUTIONS.md` and rendered in S17. Any plate whose artist cannot be identified is dropped.

### B5 — The licence for the flagship (Gulf) ruleset was never named
Spain cited Art. 13 LPI, Brazil cited Lei 9.610 art. 8, Germany cited §5 UrhG — and the Gulf, which §9.1
calls "the moat", cited no statute at all, only an assertion plus a risk flag. The brief requires every
bundled dataset to have a licence named and verified.

**Fixed:** §8 now names **UAE Federal Decree-Law No. 38 of 2021, Art. 3** (successor to Federal Law
7/2002 Art. 3), excluding official documents including the texts of laws, regulations and decisions —
flagged as cited-but-not-independently-verified, and requiring an equivalent provision per Gulf state
before that state ships. It also requires transcription from the **official gazette or ministry PDF**,
never from FAOLEX's abstract or an FAO translation, which are FAO works under FAO terms.

---

## Major findings, grouped

**Offline guarantee (4).** The iOS proofs were worthless — ATS blocks only cleartext HTTP, and
Foundation/CFNetwork is linked by the Flutter engine regardless, so both stated tests would pass for an
app making calls on every screen. The "zero packets" test used an HTTP proxy, which Dart's `HttpClient`
ignores unless `findProxy` is set — invisible to the most likely failure mode — and only observed an idle
app. And "tappable" citations plus a "link to the protected-species list" had no defined behaviour, with
`url_launcher` neither used, banned, nor grepped (an `ACTION_VIEW` intent bypasses the Android
INTERNET removal entirely, since the browser has its own permission).
→ §11 states the iOS position honestly; §14 requires real packet capture (PCAPdroid/`tcpdump`,
`rvictl` + Wireshark) across a full walkthrough of S1–S23 plus export/import/GPS/camera, and an Android
per-uid byte-counter delta; §4.6 defines citation taps as in-app expansion plus copy-to-clipboard;
`url_launcher` is banned and grepped.

**Evidence integrity (3).** I claimed Spanish anglers "explicitly refuse to upload fishing positions".
A reviewer pulled all 58 PescaREC reviews: **not one says that.** The raw research hedged it; SHORTLIST
hardened it to "explicit refusal"; SPEC hardened it again into the product's opening paragraph. Also:
"no download" for the Xunta page was wrong (a 1.19 MB order PDF exists), and "the 12 people who left
angry reviews" misread `userRatingCount` for the current version (there are 58 written reviews).
→ The position claim is deleted from `SPEC.md` §0, §5 and §17 and corrected in the SHORTLIST evidence
table; the other two are corrected in place. Criterion 2 drops 5 → 4.

**Competitors (4).** Four were missed, and the "0 results in ES" headline was a **term-selection
artefact** — `tallas minimas pesca` returns 0, but `vedas pesca` returns an official Xunta app. Found:
**NORMAP** (Gobierno de Canarias, updated 2026-07-13 — nearly the whole feature set, actively
maintained), **Non piques – Non peques** (Xunta, abandoned since 2019), **EU RecFishing** (EU
Publications Office, June 2026, 24 languages, offline-capable catch declaration), and **iDfish**
(1,425 ratings, on-device offline AI — which **disproves** my claim that photo-AI cannot work offline).
→ All four added to the competitor list with their real differentiators; §5.2 rewritten with the true
reasons for excluding photo-AI; §5 repositions the catch log as a private complement to EU RecFishing;
criterion 6 drops 5 → 4 and criterion 8 drops 4 → 3 (two competitors are free government apps).

**The frozen snapshot self-destructed (1).** §7.3 selected only rules where `date` is inside
`[valid_from, valid_to)`. On the day a Spanish *orden de vedas* or a Brazilian piracema portaria expired,
every rule from it would drop out and every species would fall to "no rule recorded" — contradicting §4.7
("a stale rule is still better than nothing at sea") and §14 ("the app still produces verdicts"), and
turning a defensible frozen snapshot into a de facto live-data product, which is an auto-reject.
→ §7.3 now selects the most recent rule with `valid_from <= date` regardless of `valid_to`, tags it
`is_expired`, and renders the amber bar. §14 asserts a *finding is still produced*, not merely that the
bar appears.

**Legal-advice auto-reject never argued (1).** The brief permits liability-adjacent tools only as
"a reference/logging tool with no advisory function". A full-width green **KEEP** / red **RETURN** is an
imperative — application of law to facts.
→ New §5.1 argues the carve-out in five points, and the output is reworded throughout to statements of
fact: `BELOW THE MINIMUM — 38 cm, minimum 45 cm (total length)`. Colour and haptics are retained.

**Schema and completeness (7).** The `gender` field §9.5 depends on existed in no table; `key_node`'s
CHECK forced exactly one species per leaf, making §4.3's "candidate list, never a single confident
answer" and S7's dead-end state unrepresentable; `species.family`, `citation.instrument_type` and
`gear_rule.gear_code` were raw text with no localisation path (so Khalid, who "does not read scientific
names at all", would have seen Latin family names and English enum identifiers); glossary, changelog and
licence-type had screens but no tables; `licence_required` was a boolean that could not answer "which
licence"; `catch` had no zone column so zone filtering broke for quick-adds; six Reference destinations
had no screen spec; S7 was unreachable; the bottom nav was never enumerated; and an "optional app PIN"
appeared in the tech stack backed by nothing.
→ Added `family` table, `gender`, `instrument_type_key`, `gear_name_key`, `key_leaf_species`, nullable
`next_node_id`, `glossary_term`, `content_change`, `licence_type`, `jurisdiction_code`/`zone_code` on
`catch`, `numeral_system` on `user_profile`; added screens S18–S23; enumerated the bottom nav; gave S7
three entry points; added "Flag this rule" to S2; **removed the app PIN from scope** rather than leave it
half-specified; added the missing build-order steps.

**Localisation correctness (3).** Verified against CLDR 48: `ar` and `ar-AE` default to **`latn`**, not
Arabic-Indic — my stated default was backwards and wrong for Khalid in RAK; and `es`, `ca` and `pt` each
carry a `many` plural category, so my "one/other for all four" was wrong for three of them. The Arabic
normalisation could not satisfy its own acceptance test (`ة`→`ه` turns `هامورة` into `هاموره`, which is
neither equal to nor a prefix of `هامور`), omitted the definite article `ال` that legal instruments use,
and omitted NFKC folding of Presentation Forms — exactly what OCR of the gazette PDFs emits. And the FTS
table indexed raw `body`, so Arabic legal-text search was broken in the moat locale.
→ §9.3, §9.4 and §9.5 corrected; `legal_text.body_norm` added and indexed; a unit test asserting
`hamour`/`هامور`/`هامورة`/`الهامور`/`Epinephelus` resolve to one species id is now an acceptance
condition; new §9.6 states that verbatim law is bundled single-locale and gives S13 a
language-availability notice.

**First-launch extraction (1).** §7.4's rule ("if the bundled asset's `build_date` is newer than the
copy") was circular — on first launch there is no copy, and you cannot read `content_meta` from a
compressed asset without materialising it. And extracting ~10 MB plus building the FTS index cannot fit
a <1.2 s budget with "no spinner at any point".
→ The build date ships as a separate tiny asset plus a generated Dart constant; extraction is temp-file
+ atomic rename; §13 carves out a **first-launch budget of <6 s with a determinate progress indicator**;
§14 adds a force-quit-during-extraction test.

**Zone polygon licences (1).** Brazilian state and basin boundaries are IBGE/ANA cartographic products,
not annexes to a portaria, so Lei 9.610 art. 8 does not reach them; and Gulf emirate maritime boundaries
are not published as coordinate polygons at all. A 4 MB dataset was shipping under a licence assertion
that did not hold.
→ §8 splits the row by source, names each licence, defaults to **Natural Earth (public domain)** for
admin boundaries, and adds `jurisdiction.has_zone_polygons` so jurisdictions with no published
coordinates apply rules jurisdiction-wide. **We do not invent boundaries.**

---

## Minor findings

Manifest snippet missing `xmlns:tools` and the release source set (would not have compiled; debug and
profile builds legitimately need `INTERNET`) · Brazil's licence marked unverified in one document and
settled in the other, now reconciled with the verbatim art. 8 IV quote · the unverified 5,268/1,109 Gulf
figures now carried with their caveat, and §1 gains an explicit audience-sizing table that says plainly
where no defensible number exists · the "12 reviewers" miscount · the Xunta PDF.

---

## What the reviewers checked and found sound

Worth recording, because it is what the corrected evidence rests on:

- **The keystone survived.** The Emarat Al Youm 2019 article is live and does say the RAK Fishermen's
  Association's prior app required internet and that fishermen at sea could not use it.
- All six quoted Fish Rules reviews re-pulled verbatim from the RSS feed, with dates; 193 ratings /
  3.88★ / updated 2026-07-17 confirmed.
- Pesca en Castilla y León at 2.3★ with both content-error complaints, over the stated date range.
- BOE Art. 13 LPI verbatim; Lei 9.610 art. 8 IV verbatim on planalto.gov.br.
- Catalogue of Life `"license":"cc by"`, COL26.7, 5,413,595 taxa.
- Pesca na Regra updated 2026-04-25 with the 10 kg + 1 native quota and the 1,500 m dam exclusion.
- All eight storefront zero-result counts re-run independently the same day (AE/SA/KW/OM/QA/BH = 0;
  ES for `tallas minimas pesca` = 0; BR = 0).
- The GOV.UK figure of 56,345 foster carers (used for a different shortlisted idea) is exact.
- **Explicitly judged and rejected as a finding:** requiring language confirmation, jurisdiction choice
  and ruler calibration is *not* a violation of "fully functional on first launch before any setup" —
  all three are local and instant, nothing is downloaded or activated, and manual length entry keeps the
  core loop complete before calibration.
