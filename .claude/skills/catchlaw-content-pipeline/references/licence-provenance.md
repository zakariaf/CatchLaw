# Licence Provenance

Scope: where every bundled byte of legal text, illustration and taxonomy is allowed to come from,
the statutes that make legal text usable in each jurisdiction we ship into, the illustrator
death-year test that replaces the American publication-date test, and the two translation tiers.

This file states the working rules the pipeline enforces. It is not legal advice and does not
replace counsel for a specific instrument.

## Legal text: the statutory carve-outs, and their edges

| Jurisdiction | Instrument | What it covers | What it does NOT cover |
|---|---|---|---|
| UAE | Federal Decree-Law 38/2021, Art. 3 | official documents, laws, regulations, judicial decisions and their official translations | private commentary, third-party abstracts, commissioned translations |
| Spain | TRLPI Art. 13 | the whole *disposición* — text **and annexes**, tables and schedules of legal and regulatory provisions | photographs and artwork merely reproduced alongside, if separately authored |
| Brazil | Lei 9.610/1998, art. 8, IV | **"os textos"** of laws, decrees, regulations, judicial decisions and official acts | **graphic annexes** — diagrams, species drawings and maps are not clearly covered |
| EU (Galicia via ES) | Directive 2006/116/EC | term harmonisation only; the exclusion itself is national | nothing in the directive makes official texts free |

The Brazil edge is the operative one. `art. 8 IV` reads *os textos*, so a species-identification
drawing printed as an annex to a Brazilian portaria is **not** cleared by the carve-out. Every
diagram we ship for a Brazilian rule is **originated in-house** and recorded in `plates.yaml` with
`origin: originated`. Spain's Art. 13 is broader and does cover annexes to the *disposición*, so a
BOE or DOG schedule table may be reproduced verbatim.

## Sourcing: the gazette, and nothing else

| Jurisdiction | Accepted source | `source_url` host | Rejected |
|---|---|---|---|
| UAE | UAE Official Gazette (الجريدة الرسمية) | the official gazette domain | ministry press releases, NGO species guides, aggregator PDFs |
| Spain | BOE (state) and DOG (Galicia) | `boe.es`, `xunta.gal` | consolidated third-party databases, law-firm summaries |
| Brazil | Diário Oficial da União, state DO | `in.gov.br` and the state equivalent | NGO fact sheets, blog transcriptions |

Every `citations.yaml` row carries `source_url`, `sha256` of the fetched document, `published_on`
and a human-entered `retrieved_on`. A9 rejects any host outside the accepted list. `retrieved_on` is
never `DateTime.now()` in the builder: the citation footnote on the result screen claims a human
checked the gazette on that date, and that claim must be true.

Worked row: Ministerial Decision 580/2015, Art. 3 · `published_on: 2015-11-03` ·
`retrieved_on: 2026-07-14` · `text_locale: ar` · sha256 of the gazette PDF.

## The two translation tiers

| Tier | Store | Content | Translated | Owner |
|---|---|---|---|---|
| 1 | `lib/l10n/app_*.arb` via gen-l10n | UI chrome — buttons, labels, errors | all six locales | `i18n-rtl-l10n` |
| 2 | `content_string` table in `reference.db` | bundled content — summaries, species prose, zone descriptions | all six locales | this skill |
| — | `legal_text` table | **verbatim** article text | **never** — single-locale | this skill |

Verbatim legal text is bundled **single-locale**, in the language the authority published it: `ar`
for UAE instruments, `es` (or `gl` where the DOG publishes bilingually) for Spain, `pt` for Brazil.
No row in `content_string` may key a `legal_text.*` id, and `scripts/check_content_pipeline.sh`
greps for exactly that.

Two reasons, and only the second is aesthetic:

1. An unofficial translation of a **penal** instrument is a liability. A fisher who relies on our
   English rendering of an Arabic decree and is fined has relied on a document nobody published.
2. Spain's Art. 13 carve-out attaches to the *disposición* as published. A translation we commission
   is a new derivative work of our own making and is outside the carve-out entirely.

The **editorial summary** is different: it is our own prose, it is translated into all six locales,
and it is rendered under a heading that says so. The verbatim block is rendered in its own
`Directionality` with a label naming the language and the word "official".

## Plates: the illustrator death-year test

"Published before 1930, therefore public domain" is the **US** rule. It is wrong everywhere we ship.

| Jurisdiction | Term | Counted from | Note |
|---|---|---|---|
| EU (Spain, and Galicia within it) | life + 70 | author's death | Directive 2006/116/EC |
| Spain, authors who died before 1987-12-07 | life + **80** | author's death | transitional regime from the 1879 Act |
| Brazil | life + 70 | 1 January of the year following death | Lei 9.610/1998, art. 41 |
| UAE | life + 50 | author's death | Berne minimum |
| Berne floor | life + 50 | author's death | the reason nothing shorter is safe |

The test the build applies is the longest of these:

```
term(deathYear)     = deathYear <= 1987 ? 80 : 70
clearToBundle(p, y) = p.illustrator != null
                   && p.illustratorDeathYear != null
                   && y > p.illustratorDeathYear + term(p.illustratorDeathYear)
```

For a **2026** build the illustrator must have died in **1945 or earlier**. This ratchets: a 2027
build clears 1946. The build year is `DateTime.now().year` at build time and is recorded in the
emitted database so an old `.db` can be audited against the year it was made.

### Worked decisions

| Plate | Illustrator | Death year | Decision |
|---|---|---|---|
| Grouper engraving, *Allgemeine Naturgeschichte der Fische* | Marcus Elieser Bloch | 1799 | **bundled** — 1799 + 80 = 1879, clear everywhere |
| Emperor plate from a 1911 monograph | credited artist, d. 1958 | 1958 | **rejected** — 1958 + 70 = 2028, still in copyright in the EU and Brazil |
| Anonymous 1911 lithograph | unidentified | unknown | **DROPPED** — an unidentifiable artist can never be cleared |
| Clam diagram for a Brazilian portaria annex | in-house | n/a | **bundled** as `origin: originated` — art. 8 IV covers only *os textos* |

### `plates.yaml` required fields

`id`, `species_id`, `origin` (`public_domain` or `originated`), `illustrator`,
`illustrator_death_year`, `source_work`, `source_year`, `source_url`, `licence`, `cleared_on`,
`cleared_by`. For `origin: originated` the illustrator is our commissioned artist and the licence is
the work-for-hire agreement id; the death-year test does not apply, but the ledger row is still
mandatory.

### Drop rules

- No identified illustrator → **DROP the row**. Not `licence: unknown`, not `review: later`, not a
  TODO. A pending state ships.
- Illustrator identified but death year unknown → **DROP**, and open a provenance task. An unknown
  death year is not an early one.
- A plate whose only source is a scan with no credit line → **DROP**, or commission an original.
- A plate cleared under the US rule alone → **DROP** and re-clear. `publishedYear` is evidence about
  the artist, never the test.

## Taxonomy: the Catalogue of Life extract

`col_extract.tsv` is a filtered extract of the Catalogue of Life checklist, used to validate
binomials and resolve synonyms — never as a source of legal content. COL is distributed under
CC BY 4.0, so the extract carries an attribution row in `content_string` under `credit.col`, shown
in the About screen with the checklist version and download date. An invented `col_id` added to make
a row validate is a data-integrity failure: the binomial stops resolving and the synonym chain that
maps a local name to *Epinephelus coioides* breaks silently.

## The per-jurisdiction changelog

Every build emits `content/CHANGELOG/<jurisdiction>.md` — `ae-rak.md`, `es-ga.md`, `br-sp.md` — as a
diff against the previous content tag: rules added, rules amended (old value → new value), rules
withdrawn, citations re-retrieved, plates added or dropped. A jurisdiction whose rows changed but
whose changelog did not is an A10 failure. The changelog is what a regulator, a translator or a
future maintainer reads to answer "when did this minimum change, and on whose authority".
