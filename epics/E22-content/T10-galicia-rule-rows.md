# E22/T10 — Galicia rule rows and verbatim text

| | |
|---|---|
| **Epic** | E22 — Content authoring at scale |
| **Release** | **v1**, and it is built **second** in this epic, after T01's protocol exists |
| **Branch** | `epic/22-content-galicia` |
| **Commit** | `content(es-ga): transcribe the shellfish minimum sizes and their verbatim articles` |
| **Depends on** | E04 (the builder), E22/T01 (the authoring guide and the reviewer protocol) |
| **Size** | L |
| **Spec** | `SPEC.md` §7.1, §8, §9.6; `catchlaw-content-pipeline` rules 3, 4, 5, 6, 9, 11, 12 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Owns everything here: the ten build assertions, the required-when matrix, gazette-only sourcing, the two translation tiers |
| `catchlaw-rule-engine` | Rule 12 — a size is a number AND a method, and the method is authored, never inferred |
| `catchlaw-verdict-contract` | Every `content_string` summary is written against the statement-of-fact contract |
| `catchlaw-measurement-ruler` | What SHL means at the animal, which is what `measurement_method` names |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `content/README.md` | the citation block, the computed fields | The authored spellings, and the two columns the build computes rather than reads |
| `content/es-ga/jurisdiction.yaml` | whole | What is already seeded: `default_locale: gl`, `legal_text_locales: gl`, `has_zone_polygons: false` |
| `content/shared/strings.yaml` | `measurement.shl.*` | The one measurement method the seeded species uses |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | all of them | Each one fails the build; there is no warning tier |
| `.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` | gazette-only sourcing | Why an NGO summary is rejected even when it is correct |

## What this delivers

- `content/es-ga/rules.yaml` — the **first rule rows this repository has ever carried**. The
  shellfish minimum sizes of the Rías Baixas, each with its `measurement_method`, its `citation_id`,
  its `valid_from`, and its zone.
- `content/es-ga/citations.yaml` — each instrument with `instrument`, `article`, `published_on`,
  `retrieved_on`, a `xunta.gal` or `boe.es` `source_url` and the `sha256` of the fetched document.
- `content/es-ga/legal_text.yaml` — the verbatim articles, **single-locale in `gl`**, the language the
  Xunta published them in. No `content_string` row may key a `legal_text.*` id.
- `content/shared/species.yaml` — the species the transcribed rules actually cover. The pack carries
  one today; a rule row pointing at a species that is not there fails A1.
- `content/shared/strings.yaml` — the `content_string` rows every new `*_key` needs, in all six
  locales, with no fallback.
- `content/CHANGELOG/es-ga.md` — regenerated.
- `app/assets/db/reference.db` — rebuilt, and byte-reproducible.

## Why it is built this way

**Every answer the app can currently give is `NoRuleFound`.** The pack carries a jurisdiction, a zone,
strings and one species, and zero rule rows. That is an honest state and a useless one: v1's entire
claim is a cited verdict, and there is nothing to cite. This task is the difference between an app
that works and an app that runs.

**Galicia and not the Gulf, and the reason is arithmetic rather than preference.** The product's
headline case is Khalid in Ras Al Khaimah, and v1 does not serve him — `RELEASES.md` says so where it
can be read. Galicia is already seeded: jurisdiction, zone, strings, `default_locale: gl`. The
distance from here to a cited verdict is one `rules.yaml` and its verbatim text. The Gulf needs all of
that plus a jurisdiction, its zones, its species and Arabic transcription, and it is E22/T02–T03.

**Gazette or nothing.** `source_url` points at the DOG or the BOE, with the `sha256` of the fetched
document. An NGO species guide is copyrighted, paraphrased, and out of date the moment the Xunta
amends the article — and a paraphrased minimum size is a wrong number that reads entirely plausibly in
review.

**`retrieved_on` is the day a human opened the gazette.** Not a build timestamp. The footnote on the
result screen claims a person read that text on that date, and that claim has to be true — it is the
only thing on the screen that tells a fisher how current the transcription is.

**No `min_size` without its `measurement_method`.** A1 fails the build on one, and the reason is the
whole product: a number measured by an unstated method is a confident wrong verdict. Every row here
carries `SHL` for shell length, authored and never inferred.

**Rejected — seeding a plausible rule to unblock v1.** A wrong minimum size renders identically to a
right one, survives review, and is read to an inspector. If an article cannot be sourced from the
gazette it is not transcribed, and the species keeps its honest `NoRuleFound`.

## Tests first

Content is asserted by the build, not by a Dart test, and every assertion fails it. Run the builder
before authoring, see it pass over an empty rule set, then author.

| # | Assertion | What it catches |
|---|---|---|
| 1 | A1 — `min_size` with no `measurement_method` | The number-without-a-method that is this product's core failure |
| 2 | A2 — a `*_key` missing from any of the six locales | A blank line under the stamp, which is not a verdict |
| 3 | A3 — a `species_name` with no `gender` in a gendered locale | "la mero" reads as machine translation, and a machine-translated prohibition is not believed |
| 4 | A4 — a `citation_id` that does not resolve | An uncited verdict is an opinion |
| 5 | A6 — a plate with no cleared illustrator | Not applicable yet: v1 bundles no plates |
| 6 | A7 — `search_norm` parity against the engine's own normaliser | A name typed at 05:40 that matches nothing |
| 7 | A8 — a contradiction the row-level checks cannot see | Two rows that each validate and disagree |
| 8 | A9 — a `source_url` that is not an accepted gazette host | A paraphrase presented as an instrument |
| 9 | A10 — the committed changelog and snapshot out of step | A build nobody can reproduce |
| 10 | §9.6 — a `content_string` row keying a `legal_text.*` id | An unofficial translation of a penal instrument |

Plus, in `app/`:

| # | Test name | Expected |
|---|---|---|
| 11 | `the shipped pack carries at least one rule row` | The regression that makes "zero rules" fail loudly if a pack is ever emptied |
| 12 | `every rule row in the shipped pack names a measurement method` | A1 asserted against the built artefact and not only against the source |

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] `dart run content_builder:build --in content/ --out app/assets/db/reference.db` exits 0.
- [ ] Every rule row carries `measurement_method`, `citation_id` and `valid_from`.
- [ ] Every citation carries a gazette `source_url`, a `sha256` and a human `retrieved_on`.
- [ ] `legal_text` holds `gl` and only `gl`.
- [ ] `check_content_pipeline.sh content` and `... tools/content_builder` are both clean.
- [ ] The app, run against the rebuilt pack, reaches a cited verdict for a real species.

## Gates

```bash
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
dart run content_builder:build --in content/ --out app/assets/db/reference.db
cd app && flutter test
```

## Commit

```
content(es-ga): transcribe the shellfish minimum sizes and their verbatim articles

The first rule rows this repository has carried. Until now every answer the
app could give was NoRuleFound — honest, and useless.

Every source is the DOG or the BOE with the sha256 of the fetched document,
because an NGO summary is copyrighted, paraphrased, and out of date the
moment the Xunta amends the article. retrieved_on is the day a human opened
the gazette, not a build timestamp: the footnote claims a person read that
text on that date.

Task: E22/T10
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
