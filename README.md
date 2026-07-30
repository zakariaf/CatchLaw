# CatchLaw

**An offline catch-legality reference for artisanal and recreational fishers.**

You have just landed a fish. In under five seconds — with no signal, no account and wet hands —
CatchLaw states whether it meets the rules where you are standing, and if not, which rule it fails:
below the minimum size, inside a closed season, protected, or past your bag limit. It shows *how*
that species is legally measured, because "length" means five different things depending on what you
are holding. And it cites the actual ministerial decision or regional order the number came from,
with the date that text was last checked.

It runs **100% offline**. No server, no account, no sync, no network code path at all.

---

## Why this exists

At 05:40 off Ras Al Khaimah, a fish is alive in the bin and looks marginal. There is no signal. Hands
are wet and covered in slime. There are perhaps ten seconds before returning it stops being
worthwhile. Getting it wrong costs AED 3,000 and a six-month licence suspension.

Today the answer is a guess, a laminated card two seasons out of date, or a screenshot of a
government web page taken while still in port.

The strongest single piece of evidence behind this project is that the
[Ras Al Khaimah Fishermen's Association built and distributed its own app](https://www.emaratalyoum.com/local-section/other/2019-07-08-1.1230866)
(Emarat Al Youm, 2019-07-08) — giving as its stated reason that *the previous one required internet
and most fishermen at sea could not use it*. That is demand demonstrated by expenditure, not by
complaint.

## Status

**Specification and design complete. No application code yet.**

This repository currently holds the research, the specification, three design directions, and the
engineering guidance needed to build it.

---

## Repository map

| Path | What it is |
|---|---|
| `SPEC.md` | The complete, build-ready specification. Persona, feature list, screen inventory, SQL schema, bundled data and licences, localisation plan, tech stack, platform specifics, data portability, build order, riskiest assumptions, offline verification checklist. |
| `IDEAS.md` | The 24-candidate longlist the winner came from, with evidence strength and sources per candidate. |
| `SHORTLIST.md` | Five candidates deep-dived and scored against a weighted rubric, with competitor analysis and verified licensing. |
| `REVIEW-CHANGES.md` | What a three-reviewer adversarial pass found — 5 blockers, 20 major, 5 minor — and what changed. Includes the errors it caught in the first draft. |
| `FLUTTER_GUIDE.md` | How to write the code: architecture, project structure, naming, lints, state management, testing, Dart 3, performance, l10n/RTL. Researched from primary sources against Flutter 3.44.6 / Dart 3.12.2. |
| `design/` | Three complete HTML design directions, 20 screens each. **Lonja is the chosen direction.** |
| `.claude/skills/` | 16 Claude Code Agent Skills — nine for the Lonja design system, seven for the CatchLaw domain. |
| `research/` | Phase-1 discovery: 14 parallel search lanes, raw findings with URLs and dates. |
| `research-flutter/` | Flutter best-practice research, 10 lanes, ~15,500 lines, primary sources only. |
| `research-skills/` | How Claude Code Agent Skills actually work — the verified spec, authoring craft, and house style. |

## The design: Lonja

Three directions were built and compared screen-for-screen. **Lonja** was chosen: the app as an
*authoritative printed document* — the regulations booklet and the 19th-century ichthyological plate,
carried in an oilskin pocket. Its authority comes from looking like the law and the field guide it
actually quotes.

| Token | Value | Role |
|---|---|---|
| paper | `#E6E4DC` | surface — cool bone with a green-grey bias, not warm cream |
| ink | `#16201C` | primary text — green-black, never pure black |
| harbour | `#1B4D5E` | accent — the blue of Galician fish crates and hull paint |
| verdant | `#2E5E3A` | semantic: meets the rule |
| oxblood | `#7A2320` | semantic: fails the rule |
| ochre | `#8A6A16` | semantic: rule data is stale |

Serif for legal text (it *is* a legal document), monospace with tabular figures for every
measurement, code and citation. No shadows, no gradients, no elevation — paper does not float.

Three themes, not two: paper, night, and **sunlight** — a genuine third palette where every grey is
deleted and one colour survives. Plus **glove mode**, an orthogonal density switch raising every
primary target to 56 dp.

## The rules that are not style preferences

Four constraints in this app are legal or safety boundaries, and the skills enforce them mechanically:

1. **The result is a statement of fact, never an instruction.** "Below the minimum — 38 cm, minimum
   45 cm (total length)". Never "Keep", never "Return". `check_verdict_contract.sh` fails the build
   on an imperative in any `.dart` or `.arb` file.
2. **Every result carries its citation** — instrument, article, publication date, last-checked date.
3. **The app refuses to resolve genuine legal ambiguity.** Where two equally specific rules apply it
   shows both and picks neither.
4. **An expired ruleset is still evaluated and shown** behind a non-blocking amber bar. A stale rule
   beats no rule at sea — and filtering expired rules out would turn a defensible frozen snapshot
   into a live-data product.

## Offline is proved, not asserted

Four layers, strongest first:

1. **The dependency is not declared** — importing a networking package is a compile error.
2. **`android.permission.INTERNET` is absent from the release manifest** — the OS refuses every
   socket. This is the only layer a third party can verify without reading source.
3. **iOS has no equivalent opt-out.** Stated plainly rather than papered over; iOS rests on layers 1
   and 4.
4. **A guard test** bans the networking half of `dart:io`, which cannot be banned wholesale because
   `File`, `Directory` and `Platform` are needed for the databases and PDF export.

Verification is a real packet capture, not an HTTP proxy — Dart's `HttpClient` ignores the system
proxy unless `findProxy` is set.

## Claude Code skills

`.claude/skills/` holds 16 skills, each with `references/`, `examples/` and a runnable `scripts/*.sh`
gate.

**Lonja design system (9)** — `lonja-design-tokens` · `lonja-typography` · `lonja-buttons` ·
`lonja-navigation-chrome` · `lonja-forms-and-controls` · `lonja-lists-and-tables` ·
`lonja-dialogs-and-surfaces` · `lonja-icons-and-plates` · `lonja-verdict-and-status`

**CatchLaw domain (7)** — `catchlaw-conventions-index` · `catchlaw-offline-guarantee` ·
`catchlaw-reference-database` · `catchlaw-content-pipeline` · `catchlaw-rule-engine` ·
`catchlaw-verdict-contract` · `catchlaw-measurement-ruler`

These deliberately carry only **token values** and **app-domain rules**. General Flutter practice —
architecture, naming, testing, clean code, performance — lives in the separate
[Flutter-Skills](https://github.com/zakariaf/Flutter-Skills) plugin and is cross-referenced, never
restated.

Start with `catchlaw-conventions-index`; it routes any task to the skill that owns it.

## Licence

Not yet chosen. The bundled *content* has its own licensing story — legal texts are outside copyright
by statute in Spain (Art. 13 LPI), Brazil (Lei 9.610/1998 art. 8 IV) and the UAE (Federal Decree-Law
38/2021 Art. 3), but species artwork must be originated or cleared per image by the illustrator's
death year, not by publication date. See `SPEC.md` §8.

## A note on the evidence

Every demand claim in this repository carries a URL and a date. Where a source could not be verified
it is marked unverified rather than dressed up, and `REVIEW-CHANGES.md` records the claims that did
not survive checking — including one that the cited source did not actually support, and four
competitors the first pass missed.

**Reddit is unreachable from the environment this research ran in.** No Reddit citation appears
anywhere; equivalent primary sources were substituted and the limitation is disclosed in
`research/raw-findings.md`.
