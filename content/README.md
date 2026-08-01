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
├── CHANGELOG/         es-ga.md          # generated: the per-jurisdiction diff
└── ATTRIBUTIONS/      plates.md         # generated: the plate licence ledger
```

`CHANGELOG/` and `ATTRIBUTIONS/` are written by the build, not read by it. Neither is a jurisdiction —
counting one would let a corpus with no jurisdiction at all pass the check that exists to catch
exactly that.

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

**An Arabic name that carries `ال` produces two `species_name` rows.** `SPEC.md` §9.4 step 5 requires
both the stripped and unstripped forms to be indexed — instruments write `الهامور` and fishers type
`هامور` — and §7.1 gives `species_name` one `search_norm` column and no `species_alias` table. So the
build emits a second row with the same `species_id`, `locale`, `name`, `gender` and `region_hint`,
`is_primary = 0`, and the stripped key. The article is not stripped when the remainder is under three
characters: that is a real word, not an article.

**The consequence lands on E08, and is written here rather than discovered there:** any list of names
for a species must `SELECT DISTINCT name` or filter on `is_primary`, or an Arabic species appears
twice.

## The citation block, and why it is not spelt like the schema

```yaml
citations:
  - id: es-ga-orde-2012-07-27-art4
    jurisdiction: ES-GA
    instrument_type_key: instrument.orde
    instrument: Orde do 27 de xullo de 2012
    article: Art. 4
    published_on: 2012-08-06
    retrieved_on: 2026-08-12          # the day a human opened the DOG
    source_url: https://www.xunta.gal/dog/…
    sha256: …                          # of the fetched document
    lineage_id: es-ga-orde-2012-07-27
```

`jurisdiction`, `instrument` and `article` rather than `SPEC.md` §7.1's
`jurisdiction_id`, `instrument_ref` and `article_ref`. This is the one block where the authored name
and the column name differ, and the gate is the reason: `check_content_pipeline.sh` check 2 is an
`awk` window looking for `instrument:` or `article:` beside `retrieved_on:`, and against `*_ref` names
it cannot fire at all. `DECISIONS.md` D-2's rule of thumb — where a gate and the prose disagree about
a **shape**, the gate wins. The §7.1 spellings still load, so a corpus authored either way is read.

**`source_url` must be an official gazette.** The accepted hosts are per jurisdiction: `boe.es` and
`xunta.gal` for Spain, `in.gov.br` and the state equivalent for Brazil, the UAE gazette domain for the
UAE. NGO summaries, law-firm databases and commissioned translations are rejected — an abstract is
both copyrighted and paraphrased, and a paraphrased minimum size is a wrong number that looks entirely
plausible in review. A jurisdiction with **no** allowlist entry fails: silence is not permission.

**`sha256` is an authoring field, not a column.** §7.1's `citation` table has no such column and §7.1
is authoritative for the schema, so the digest is asserted at build time and carried into the
changelog rather than into the database. Inventing a column would put this builder and E05's drift
schema out of step.

**The UAE is `verified: false` and must stay that way until somebody confirms it.** `SPEC.md` §8 marks
the Gulf licence basis "cited but not independently verified in this session" and says the provision
must be confirmed per state before that state's content ships. That is encoded in
`tools/content_builder/lib/src/provenance/accepted_hosts.dart` as a gate on the data rather than a
memo: every citation in an unverified jurisdiction fails A9.

## Plates: the illustrator death-year test

`content/shared/plates.yaml` is the licence ledger behind `species.plate_asset`. It is not a §7.1
table: it is the evidence A6 tests and E18 renders in S17, and it stays out of the database because a
licence claim belongs in the attribution page rather than in a column nobody reads.

A plate is cleared on its illustrator's **death year**, against the longest term among the
jurisdictions this app ships into:

| Jurisdiction | Term | Counted from |
|---|---|---|
| Spain, author died before 1987-12-07 | life + **80** | TRLPI transitional regime — the longest we ship into |
| EU, including Galicia within Spain | life + 70 | Directive 2006/116/EC |
| Brazil | life + 70 | Lei 9.610/1998 art. 41 |
| UAE | life + 50 | Berne minimum |

`term(deathYear) = deathYear <= 1987 ? 80 : 70`, and a plate clears when
`buildYear > deathYear + term(deathYear)`. For a **2026** build the artist must have died in **1945 or
earlier**; 1946 fails by one year and clears in 2027. The comparison is strictly greater — a `>=`
would ship every plate a year early. The build year comes from `--build-date`, not the clock: a plate
that re-clears itself at midnight on 1 January produces a different database from the same corpus with
no diff to show for it.

**"Published before 1930, therefore public domain" is the US rule** and clears nothing in Spain,
Brazil or the UAE. `source_year` is evidence about the artist and is never compared to a threshold; a
test in the builder's own suite greps this directory and `tools/content_builder/lib` for such a
comparison.

**The Jordan & Evermann trap**, in `SPEC.md` §8's own words: the plates of *Fishes of North and Middle
America* are excluded unless each staff illustrator is identified and cleared. Jordan (d. 1931) and
Evermann (d. 1932) clear the test, **but they are the authors — the artists are a separate question
the first draft simply missed.** Filling `illustrator` in with an author's name is not something code
can detect. What code does is refuse a block with no illustrator at all; the rest is the ledger review.

**An unattributable plate is deleted, never flagged.** `licence: unknown` and `review: later` are
states that ship, and an infringement claim against a fisheries-safety app is the story that ends the
project rather than the sprint. A6 fails on an absent illustrator and on the literal strings
`unknown`, `unidentified` and `TBD` — the same three `check_content_pipeline.sh` check 3 looks for, so
the build is never laxer than the grep.

`origin: originated` is our commissioned art: the silhouettes, the measurement diagrams, and every
diagram for a Brazilian rule, because Lei 9.610 art. 8 IV covers only *os textos*. It has no death
year to test and its ledger row is still mandatory, because S17 renders the whole ledger.

**The Galicia seed ships zero cleared plates.** Every `species.plate_asset` is NULL, which §7.1
permits, and the app renders the originated silhouette instead.

## When two instruments disagree: `supersedes:` and `ambiguity_ack:`

The shipped rule engine resolves every (species × zone × month × water type) cell of this corpus
before a database is written. Row-level checks cannot see a contradiction: two rows that each validate
perfectly can still say 380 mm and 400 mm about the same clam on the same bank in the same month, and
the tie would then be broken at sea, offline, in favour of whichever row the query returned first.

**`supersedes: <rule-id>`** is the first answer, and the common one: a newer instrument replaces an
older one. It is implemented as a **shared citation lineage**, not as a second precedence rule — the
engine already collapses candidates per `(zone_id, lineage)` and keeps the greatest `valid_from`, so
`SPEC.md` §7.3 resolves it itself. The superseded row stays in the corpus: the changelog and the
lineage both need it, and it is exempt from the unreachable-rule check for exactly that reason.

**`ambiguity_ack: { with: <rule-id>, reason_key: <key> }`** is for a disagreement the sources really
do contain. §7.3 step 4 and §6 D4 require the app to render **both** instruments when two at equal
specificity disagree, and never to silently report the more permissive one. If the build failed on
every ambiguity, no such pair could be authored, D4 would be unreachable, and the first genuine legal
conflict would have nowhere to go but a `supersedes:` the sources do not support — precisely the
silent choice §7.3 forbids. So the build fails on an **unacknowledged** ambiguity. Both rules must
carry the acknowledgement, each naming the other, and the reason key is what D4 renders — it is a
`*_key`, so A2 translates it six ways.

**Two minima measured by different methods are not a contradiction.** `min_size_mm: 450 TL` and
`min_size_mm: 400 FL` measure different parts of the fish; both must be shown, and neither
acknowledgement nor supersession is needed. The exemption is narrow: the rules must agree on
everything except the size pair, and their methods must differ. Two rules with different methods
**and** different bag limits are a real contradiction wearing a method.

**A protected species admits no size threshold**, even from another row. The precedence ladder
headlines `protected`, the size would never be read, and its number would be uncheckable. Delete the
size rule.

**An expired rule is never a build failure.** The Galician *orde de vedas* is reissued annually and
typically lapses on 30 April. Filtering on `valid_to` is what made every species fall through to "no
rule recorded" in the first draft; failing the build on one would do the same damage a year earlier
and more permanently, by making the corpus unshippable until somebody deleted the rows.

## When a species has no name in a locale

`SPEC.md` §8 bullet 5 read literally requires an Arabic name for *Venerupis corrugata*. No Galician
instrument names a clam in Arabic, and §9.2 step 3 is explicit that **a wrong vernacular name is worse
than no name**, because it produces a confident wrong finding. Inventing a transliteration is also
what the normalisation contract forbids: normalisation folds orthography and never guesses
transliteration.

So a species may declare the absence, per locale, with a reason:

```yaml
species:
  - id: venerupis-corrugata
    scientific_name: Venerupis corrugata
    silhouette_asset: sil/venerupis-corrugata.svg
    no_vernacular:
      ar: reason.no_arabic_name_for_galician_bivalve
```

The reason is itself a `*_key`, so A2 forces its six translations — an untranslated reason would be a
blank line explaining a blank line. A locale with **neither** a name nor a declaration still fails: a
silent gap and a decided absence must not look the same in a diff.

**This is the one place E04 does not implement a §8 bullet to the letter.** What would resolve it is a
§8 amendment, which no epic owns.

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
worked around locally. **The build tool is authoritative over the gate in every row below.** Widening
a gate's regex is a skill edit with an owner and a task id, not something a content task does to make
its own build green.

### G-1 — `check_content_pipeline.sh` check 5 knows four measurement codes; `SPEC.md` §7.1 declares nine

The gate matches `measurement_method:[[:space:]]*(TL|FL|CW|SHL)`. Galicia alone needs `CL` for *Maja
squinado* and `CW` for *Necora puber*, and §7.1 also declares `SL`, `ML`, `DW` and `CUSTOM`. Check 5
does **not** honour `content-pipeline-ok`, so there is no line-level exemption. A1 validates against
all nine, and `MeasurementCode` in `tools/content_builder/lib/src/model/enums.dart` is the list.

### G-2 — check 5 cannot fire on this corpus at all

Worse than G-1, and found while writing A1. Check 5 is an `awk` window keyed to a field name followed
immediately by a colon:

| Check | Wants | This corpus authors | Matches |
|---|---|---|---|
| 5 | `min_size:` / `max_size:` and `measurement_method:` | `min_size_mm:`, `max_size_mm:`, `measurement_method_id:` | never |

The column names are `SPEC.md` §7.1's, and for the `rule` table §7.1 wins — the emitted database's
columns and the authored field names are the same words on purpose. The consequence is that **check 5
is inert against `content/`**, and a green `check_content_pipeline.sh content` says nothing at all
about a size authored without a method. A1 covers its ground.

**Check 2 was heading the same way and does not, because E04/T05 shaped the citation block for it.**
It wants `instrument:` or `article:` beside `retrieved_on:`, and §7.1 spells those `instrument_ref`
and `article_ref`. The citation block authors the gate's spellings — the one place the authored name
and the column name differ, and D-2's rule of thumb is why. A4 covers the same ground regardless.

This is exactly the `CONVENTIONS.md` §7 shape — a green tick meaning "I found nothing" and one meaning
"I looked at nothing" are the same pixel — so it is written here rather than left to be rediscovered.

### G-3 — `content/es-ga/citations.yaml` is not authored yet, and that is deliberate

E04/T05 lists it as a deliverable. A citation block requires a `sha256` of the fetched gazette
document and a `retrieved_on` naming the day a human opened it. Neither can be produced without
actually fetching and reading the DOG, and writing a plausible-looking digest would be **precisely**
the defect A9 exists to prevent: a footnote claiming a check nobody made. The assertion ships here;
the transcription is E04/T11's, whose own risk note says a value nobody has read out of the DOG is a
defect rather than a placeholder. The block shape is documented above.
