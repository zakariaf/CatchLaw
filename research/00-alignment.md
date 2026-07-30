# Phase 0 — Alignment

## Objective (3 lines)

1. Find **one** Flutter (Android + iOS) app that runs **100% offline** — no server, no account, no network at runtime, fully functional in airplane mode on cold first launch — and ships multi-language from day one.
2. It must serve a **specific, nameable group of roughly 3,000–50,000 people** whose pain is provable with dated links from real forums, store reviews and issue trackers — not a mass market, not a listicle.
3. Deliver, in order: `research/raw-findings.md` → `IDEAS.md` (20 candidates) → `SHORTLIST.md` (5 scored) → `SPEC.md` (the complete finished application). **No application code this session.**

## Assumptions I am proceeding on

| # | Assumption | Why |
|---|---|---|
| A1 | "Complete, finished application" means `SPEC.md` lists every feature as final. Build order is an *ordering for the builder*, not a release plan. | Stated explicitly in the brief. |
| A2 | Implementation difficulty, screen count, data-modelling complexity and content-authoring volume are **not** filters, and I will actively prefer heavy ideas. | Brief says so twice and warns that using difficulty as a filter yields a boring idea. |
| A3 | Commercial release is intended, so bundled data must be **commercially redistributable**. CC-BY-NC, "research use only", and paid standards (ISO/DIN/ASME/ANSI) are hard kills. CC-BY-SA is a *trap flag* (share-alike may infect derived content) and must be handled deliberately. | The brief demands a verified licence and a monetization path. |
| A4 | Existing sibling projects in this repo (`Offline-AAC`, `MATRIX`, `RANGE-SIM`, `khodroyar`, `car-and-pain`, `SplitFair`, `brain-games`) are prior work. I will avoid landing on the same territory. | Avoids duplicating the user's own portfolio. |
| A5 | Bundle size: under 100 MB preferred. Anything over ~150 MB must carry an explicit justification paragraph naming the trade-off. | Brief allows up to ~500 MB "if the content is the whole point". |
| A6 | "At least 4 more languages beyond English, chosen to match where the target users actually are, including RTL if relevant" means the language set is a *finding*, not a default. I will pick languages from the evidence, not from a generic top-5 list. | Brief ties localisation to the actual audience. |
| A7 | On-device ML is permitted but every model must be named specifically with its licence and size. No hand-waving about "a small classifier". | Brief requires it. |
| A8 | A pain point is validated only at **≥3 independent sources across ≥2 platforms**, from real users. SEO listicles and "top app ideas" blogs are ignored entirely. | Brief's validation bar. |

## Ambiguities flagged (resolved by assumption, not blocking)

- **"Bundle up to ~500 MB acceptable"** — resolved by A5: I will treat >150 MB as requiring explicit justification, because Play Store's 200 MB base APK / 1 GB AAB limits and iOS cellular-download thresholds have real distribution consequences that the brief doesn't mention.
- **"Multi-language from the start"** — resolved by A6: languages derived from evidence about where the users are, and the spec must explain how *bundled content* (not just UI strings) gets translated, including who authors the domain-term translations.
- **"Monetization path" is weighted ×1** — I read this as "must not be structurally unmonetizable", not "must have a business plan". A one-time paid app or paid unlock is a sufficient answer given there is no server to fund.
- **Domain: "no preference — surprise me"** — treated as full latitude. No question asked.

## What would have blocked me (nothing did)

I considered asking about (a) whether a paid-app-only monetization is acceptable, (b) whether the user's existing `Offline-AAC` project rules out assistive/accessibility domains, and (c) target bundle-size hard ceiling. All three are answerable by reasonable default (A3, A4, A5), so per the brief I proceeded without asking.

## Method note

Phase 1 discovery ran as a 14-agent parallel workflow across four groups:

- **Bottom-up (6 agents):** Reddit "wish there was an app" patterns; Reddit paper/spreadsheet workarounds; Hacker News via the `hn.algolia.com` JSON API; App Store / Play Store 1–3 star reviews; F-Droid + GitHub abandoned-but-loved and awesome lists; trade forums + Stack Exchange + community group sizes.
- **Non-English (3 agents):** German + Spanish; Brazilian Portuguese + Indonesian; Hindi + Arabic (Arabic chosen partly because RTL is itself a competitive gap).
- **Top-down (4 agents):** signal-dead outdoor occupations; indoor dead-zone / hands-busy trades; privacy-refusing professions; odd and overlooked hobby/volunteer groups.
- **Data (1 agent):** open data catalogue sweep with licence verification, on the theory that sometimes the available dataset *is* the idea.

Every agent was instructed that fabricating a URL is the worst possible failure mode, and that "no evidence found" is a correct answer.
