# `content/` — the authoring format

This directory is the product. `app/assets/db/reference.db` is a build artefact of it, and the app is
a viewer for that artefact. A wrong row here costs a fisher a fine, so every row is authored out of
band, asserted in CI, and shipped byte-reproducibly.

Build it with:

```bash
dart run content_builder:build \
  --in content/ --out app/assets/db/reference.db \
  --build-date 2026-08-14 --generator-commit "$(git rev-parse --short HEAD)"
```

**Every assertion is fatal.** A non-empty failure list means exit 1 and **no** database is written —
not a partial one, and not a previous one left in place and reported as fresh. There is no `--force`,
no `--skip-assertions` and no `--allow-missing-locale`; passing one of those three names exits 2 with
an explanation, because the flag that exists is the flag CI uses at 18:00 on a Friday.

Exit codes: **0** built · **1** failures, nothing written · **2** the invocation was wrong and no
content was read.

## The layout

One directory per jurisdiction, so a new one is a sibling that touches nothing already shipping.

```
content/
├── shared/            families.yaml  measurement_methods.yaml  species.yaml  vernacular.yaml
│                      plates.yaml  lookalikes.yaml  key_nodes.yaml  glossary.yaml  strings.yaml
├── es-ga/             jurisdiction.yaml  zones.yaml  citations.yaml  rules.yaml
│                      closed_seasons.yaml  licence_types.yaml  gear_rules.yaml  penalties.yaml
│                      legal_text.yaml  changes.yaml  strings.yaml  snapshot.json
└── CHANGELOG/         es-ga.md
```

A file name outside this list is a failure, not a file that is skipped: `rule.yaml` for `rules.yaml`
is a file nobody reads and nobody misses. So is a misspelt section — `speceis:` loads as "no rows",
and a whole file goes missing without one line of output.

## Every file, and the sections it holds

A section is named after the `SPEC.md` §7.1 table it becomes, pluralised. Field names are the SQL
column names exactly; a tidier spelling costs the next reader a diff between the schema, this format
and the emitter, and one of the three will be wrong.

Foreign keys are the **authored string ids** — `venerupis-corrugata`, `es-ga-rias-baixas` — never the
`INTEGER PRIMARY KEY`s. The build assigns those; an integer authored by hand is a number two people
have to keep in step across eleven files.

### `shared/` — every jurisdiction's

| File | Sections | Becomes |
|---|---|---|
| `families.yaml` | `families` | `family` |
| `measurement_methods.yaml` | `measurement_methods` | `measurement_method` |
| `species.yaml` | `species` | `species` |
| `vernacular.yaml` | `species_names` | `species_name` |
| `plates.yaml` | `plates` | the licence ledger behind `species.plate_asset` — not a table |
| `lookalikes.yaml` | `lookalikes` | `lookalike` |
| `key_nodes.yaml` | `key_nodes`, `key_options`, `key_leaf_species` | the three identification-key tables |
| `glossary.yaml` | `glossary_terms` | `glossary_term` |
| `strings.yaml` | `strings` | `content_string` |

The identification key is one graph across three tables and is authored in one file. Split over three,
a node, its options and its leaves can disagree in a diff nobody reads as a whole.

### `<jurisdiction>/` — one directory per authority

| File | Sections | Becomes |
|---|---|---|
| `jurisdiction.yaml` | `jurisdiction` | `jurisdiction` |
| `zones.yaml` | `zones`, `zone_rings` | `zone`, `zone_ring` |
| `citations.yaml` | `citations` | `citation` |
| `rules.yaml` | `rules` | `rule` |
| `closed_seasons.yaml` | `closed_seasons` | `closed_season` |
| `licence_types.yaml` | `licence_types` | `licence_type` |
| `gear_rules.yaml` | `gear_rules` | `gear_rule` |
| `penalties.yaml` | `penalties` | `penalty` |
| `legal_text.yaml` | `legal_texts` | `legal_text` |
| `changes.yaml` | `changes` | `content_change` |
| `strings.yaml` | `strings` | `content_string` |
| `snapshot.json` | — | the previous build's state, read by the changelog diff. Not authored by hand |

A zone's rings are its geometry and are meaningless apart from it, so they share a file.

**`content_meta` is not authored.** Its three rows — `schema_version`, `build_date` and
`generator_commit` — come from the build's own `--build-date` and `--generator-commit`. Authoring them
would let the file disagree with the run that produced it.

## Two fields that are computed, never written

- **`species_name.search_norm` and `legal_text.body_norm`.** Computed by the build with the engine's
  own `normaliseSpeciesTerm()`, imported from `package:rule_engine/rule_engine.dart` — the exact
  function the search field calls. A second normaliser that folds one more Arabic diacritic means
  `كنعد` typed at 05:40 with wet hands matches zero rows that were written, and the app reports "no
  such species" rather than failing loudly.
- **`zone_ring.point_count`.** Derived from `coords`. A hand-kept count and a hand-kept list disagree
  the first time a coordinate is added.

## Two dates that are read by a human, never by the clock

`citation.retrieved_on` and `jurisdiction.checked_on` claim that a person opened the gazette that day.
`DateTime.now()` records when a machine ran, which is not what the footnote says. Both are authored,
and `--build-date` is required input for the same reason plus one more: T10 requires two builds of
identical input to produce byte-identical files, and a clock reading makes that untestable.

## Verbatim legal text is single-locale

`legal_text` carries **one** `locale`, the language the authority published in — Arabic for the Gulf,
Galician and/or Spanish for Galicia, Catalan for Catalonia, Portuguese for Brazil. No `content_string`
row may key a `legal_text.*` id. An unofficial translation of a penal instrument is a liability and
falls outside Spain's Art. 13 LPI carve-out, which covers *official* translations only. The editorial
**summary** is translated, and is labelled a summary in all six locales.

## Locales

Six, per D-3: `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`. There is no fallback chain at build time — every
`*_key` resolves in every one of them or the build dies. A missing key renders a blank line under the
verdict stamp, and blank is not a verdict.

## GAPS

Recorded per `epics/CONVENTIONS.md` §4: a rule that lives in neither registry is written down, not
worked around locally.

*(Nothing recorded yet. E04/T02 adds the first entry.)*
