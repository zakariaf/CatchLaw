# Authoring a jurisdiction

Content is not data the app happens to read — it **is** the product, and the app is a viewer for it. A
wrong row here costs a fisher a fine and six months of licence, and it renders exactly as beautifully
as a right one. That is the whole reason this file exists: nothing about a wrong minimum size looks
wrong.

`content/README.md` is the **format** — which file, which section, which column. This is the
**protocol** — where a number is allowed to come from, who checks it, and what to do when the answer
is that you cannot tell.

---

## The one rule

> **Transcribe what the instrument says. Never what it probably means.**

Every other rule below is that one, applied.

---

## Sourcing

**The gazette, or nothing.** `source_url` points at the official publication — DOG or BOE for Spain,
the UAE Official Gazette, the Diário Oficial da União for Brazil — and at nothing else. Not a
ministry's summary page, not a fishermen's association PDF, not a species guide, and not a news
article about the order.

An abstract is copyrighted, paraphrased, and out of date the moment the authority amends the article.
It is also usually *right*, which is what makes it dangerous: it will survive review.

**Record the digest of the document you actually fetched.**

```bash
curl -sL "<source_url>" -o /tmp/instrument.html
shasum -a 256 /tmp/instrument.html
```

That digest goes in `sha256`. If the page changes under you, the next build's digest differs and
somebody has to look at why — which is the point.

**`retrieved_on` is the day a person opened the gazette.** Not the day the build ran, and not the day
the file was edited. The footnote on the result screen claims somebody read that text on that date,
and a fisher shows that footnote to an inspector.

---

## Transcribing a size

Every size carries its method. `min_size_mm: 38` with no `measurement_method_id` fails the build (A1),
and it fails for the reason the whole product exists: total length and fork length differ by 6–9 cm on
the same fish, so a number with an unstated method is a confident wrong verdict.

Read the article that says **how** the thing is measured, not only the annex that says how big. They
are usually different articles. Galicia's 2012 order puts the sizes in Anexo I-B and the method in
Artigo 6.4(a) — *o eixe maior ou anteroposterior (LAP)* — and only the second one tells you it is
shell length.

**Millimetres, always, as an integer.** The instrument may print centimetres; the column is
`min_size_mm`. A finfish minimum under 100 mm is flagged by A1 as centimetres authored as
millimetres, which is the mistake this catches most often.

---

## When the instrument is ambiguous

This is the part that separates a transcription from a guess.

**A range, a note, or an exception you have not read is not a rule.** Galicia's ameixa babosa reads
`38 ou 35 mm (1)` in Anexo I-B, where note (1) grants 35 mm to banks named in an approved management
plan. The corpus carries **38** — the rule — and not 35, because the plan is a document nobody in this
repository has opened. A lower threshold authored on a note you have not read is wrong in the
direction that costs the fisher.

**Two rules that both apply and neither outranks: author both.** The engine answers `Ambiguous`, the
screen prints both with both citations in source order, and the app picks neither. Do not resolve it
by choosing the stricter one — "the stricter rule applies" is a legal conclusion, and it is one this
product does not draw.

**If you cannot tell, do not transcribe it.** The species keeps its honest `NoRuleFound`: *"No rule
recorded for this species here. This does not mean it is legal."* That is a true sentence. A guess is
not.

---

## Names

A wrong vernacular name is worse than no name, because it produces a confident wrong *finding* — the
fisher searches, matches the wrong fish, and reads a real rule about a different animal.

- A name comes from the authority's own tables, or from the Catalogue of Life for `en`, or from a
  native speaker. Not from a dictionary and not from a translation engine.
- A locale with no sourced name gets a **`no_vernacular:` declaration with a reason key**, not
  silence. A5 accepts a decided absence and rejects a gap, and the difference has to be visible in a
  diff.
- Gendered locales — `ar`, `ca`, `es`, `gl`, `pt_BR` — require `gender`. "la mero" reads as machine
  translation, and a document that reads machine-translated is not believed when it states a
  prohibition.
- The species falls back to the binomial, which is Latin, present in every locale, and never wrong.

---

## Verbatim text

One locale per instrument, in the language the authority published it. `legal_text` carries `gl` for
Galicia, `ar` for the UAE, `pt` for Brazil — and **no `content_string` row may key a `legal_text.*`
id**. An unofficial translation of a fisheries instrument is a liability and falls outside Spain's
Art. 13 LPI carve-out entirely.

The editorial *summary* is translated and is labelled a summary in all six locales. The article is
not.

---

## The reviewer protocol

A content change is reviewed by somebody who **opens the gazette themselves**. Not the diff — the
gazette. The review is four questions:

1. **Does the URL open the instrument, on the authority's own domain?**
2. **Does the article number in `citation.article` contain the number in `min_size_mm`?** Follow the
   annex reference if there is one.
3. **Does a different article state the measurement method, and does it match
   `measurement_method_id`?**
4. **Is there a note, an exception or an annex the transcription silently dropped?** If yes, either
   transcribe it or say in the PR why it was left out.

A reviewer who cannot answer all four has not reviewed it. "The diff looks right" is not a review of a
number that will be read to an inspector.

---

## Before the PR

```bash
dart run content_builder:build --in content/ --out app/assets/db/reference.db \
  --build-date <YYYY-MM-DD> --generator-commit "$(git rev-parse --short HEAD)"
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
cd app && flutter test test/data/shipped_pack_test.dart
```

Ten assertions fail the build and there is no warning tier, no `--force` and no
`--skip-assertions`. A flag that exists is the flag a release uses at 18:00 on a Friday, and the row
it waves through is the one that reaches an inspector.

Bump `content_version` and add a `changes.yaml` entry naming every row you touched. A10 fails a rule
edited without one, and §4.7's promise that the reader can see what changed is what it protects.

---

## What a machine may and may not do

Recorded because this corpus's first rule row was transcribed with machine help, and the boundary
should be explicit rather than assumed.

| May | May not |
|---|---|
| fetch the gazette and compute its digest | decide that an ambiguous article "probably means" something |
| read the article and quote it verbatim | supply a number the article does not print |
| draft the YAML and run the build | stand in for the reviewer's four questions |
| find the article that states the method | translate a vernacular name |

**A machine-drafted row is still an unreviewed row.** It is reviewed by a person opening the gazette,
exactly like every other one, and the PR says which rows were drafted that way.
