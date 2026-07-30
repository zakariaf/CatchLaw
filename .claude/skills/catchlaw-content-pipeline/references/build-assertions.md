# Build Assertions

Scope: the ten assertions `tools/content_build` runs over `content/*.yaml` plus `col_extract.tsv`
before a single byte of `assets/reference.db` is written, their exact failure messages, the schema
they validate against, and the edge cases each one has already caught.

## The ten assertions

Every one of them is fatal. There is no warning tier, no `--force`, and no partial emit.

| Id | Proves | Failure message shape | Typical cause |
|---|---|---|---|
| A1 | Row validates against its table schema | `A1 rules.yaml:118 min_size without measurement_method` | a size copied from a PDF table without its column header |
| A2 | Every `*_key` resolves in `content_string` for all six locales | `A2 rules.yaml:204 key 'closure.sha_ri_spring' missing for gl, ur` | a new key added in `en` only |
| A3 | `species_name` in a gendered locale has non-null `gender` | `A3 vernacular.yaml:77 gender null for locale es` | a name pasted from a checklist with no gender column |
| A4 | `citation_id` resolves AND carries `retrieved_on` | `A4 citations.yaml:12 'ae-md-580-2015-art3' has no retrieved_on` | an article added before anyone opened the gazette |
| A5 | Every rule's species has a silhouette and one vernacular per locale | `A5 species.yaml:31 'venerupis-corrugata' has no silhouette` | a shellfish added late, art not commissioned |
| A6 | Every plate passes the illustrator death-year test | `A6 plates.yaml:56 illustrator unidentified — DROP` | a scan with no credit line |
| A7 | `*_norm` columns match the shared `normalise()` byte-for-byte | `A7 species.search_norm row 412 differs from normalise()` | a second normaliser inside the build tool |
| A8 | The engine resolves the authored grid with no conflict | `A8 (lethrinus-nebulosus, es-rias-baixas, 03) two rules bite: [r-088, r-141]` | a national and a regional closure overlapping |
| A9 | Licence provenance complete per jurisdiction | `A9 citations.yaml:40 source_url is not an official gazette host` | text taken from an NGO summary |
| A10 | A changelog diff exists for every touched jurisdiction | `A10 AE-RAK changed but content/CHANGELOG/ae-rak.md is unchanged` | a rule edited without regenerating |

## rules.yaml schema

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string, kebab | yes | stable forever; referenced by the changelog diff |
| `species_id` | string | yes | must resolve in `species.yaml` |
| `zone_id` | string | yes | `ae-rak`, `es-rias-baixas-cambados`, `br-jurumirim` |
| `jurisdiction` | enum | yes | `AE-RAK`, `ES-GA`, `BR-SP` — drives the changelog file |
| `kind` | enum | yes | `min_size`, `max_size`, `closed_season`, `protected`, `bag_limit`, `gear` |
| `min_size` | int, mm | when `kind: min_size` | **mm always**, never cm — `450`, `650`, `380` |
| `measurement_method` | enum | when any `*_size` present | `TL`, `FL`, `CW`, `SHL` |
| `season_start` / `season_end` | MM-DD | when `kind: closed_season` | inclusive both ends; `03-01` to `04-30` |
| `citation_id` | string | yes | must resolve in `citations.yaml` |
| `valid_from` / `valid_until` | date | yes / yes | a past `valid_until` means the ochre stale bar, not an omission |
| `summary_key` | string | yes | a `*_key` — A2 territory |

Real rows this schema is calibrated against:

| Species | Rule | Encoded |
|---|---|---|
| *Epinephelus coioides* (هامور Hamour) | min 45 cm total length | `min_size: 450`, `measurement_method: TL` |
| *Scomberomorus commerson* (كنعد Kanaad) | min 65 cm fork length | `min_size: 650`, `measurement_method: FL` |
| *Lethrinus nebulosus* (شعري Sha'ri) | closed 1 Mar to 30 Apr | `season_start: 03-01`, `season_end: 04-30` |
| *Venerupis corrugata* (Ameixa babosa) | 38 mm shell length | `min_size: 38`, `measurement_method: SHL` |

## A1 — the required-when matrix

A field is not "optional"; it is required conditionally, and the condition is checked, not assumed.

| If present | Then required | Why the default is unsafe |
|---|---|---|
| `min_size` or `max_size` | `measurement_method` | TL and FL differ by 6-9 cm on a Kanaad |
| `kind: closed_season` | `season_start`, `season_end`, `zone_id` | a closure with no zone applies everywhere by accident |
| `kind: bag_limit` | `limit`, `period` | "5" per what — day, trip, vessel? |
| `kind: gear` | `gear_code`, `summary_key` | a gear restriction with no prose is unreadable at 05:40 |
| `kind: protected` | **no** size or season fields | a measurement implies a threshold that does not exist |
| any `*_size` | units are mm | a `45` meant as cm silently becomes 45 mm |

Edge cases already caught: a `min_size: 45` intended as cm (A1 passes, so a range check backs it up
— any finfish `min_size` under 100 is flagged); a closure authored `04-30` to `03-01` (a
year-wrapping closure is legal but must set `wraps_year: true` explicitly); a leap-day `02-29`
season boundary (rejected — author `02-28` or `03-01`).

## A2 and A3 — locale coverage and gender

Six shipped locales. There is no fallback chain: a key resolves in every one or the build dies.

| Locale | Script / direction | Gendered | Notes |
|---|---|---|---|
| `ar` | Arabic, RTL | yes | the publication language of the UAE instruments |
| `en` | Latin, LTR | no | the ONLY locale allowed to omit `gender` |
| `es` | Latin, LTR | yes | `el mero`, `la almeja` |
| `gl` | Latin, LTR | yes | `a ameixa babosa` — never silently served `es` |
| `pt_BR` | Latin, LTR | yes | the publication language of the Brazilian instruments |
| `ur` | Arabic script, RTL | yes | Gulf crew language; RTL lanes cover it alongside `ar` |

`species_name` rows carry `(species_id, locale, name, gender, is_preferred)`. Exactly one
`is_preferred: true` per (species, locale) — two preferred names is an A3 failure, because the
result screen prints one and the species list prints the other.

## A6 — plates, in one line

`clear = illustrator != null && death_year != null && build_year > death_year + term(death_year)`,
where `term = death_year <= 1987 ? 80 : 70`. For a 2026 build the artist must have died in **1945 or
earlier**. Everything else is in `licence-provenance.md`.

## A7 — normalisation parity

`normalise()` lives in `packages/shared/lib/text/normalise.dart` and is imported by both the app's
search field and the build tool. A7 re-reads every persisted `*_norm` column out of the emitted
database, recomputes it from the source column, and compares bytes.

| Column | Source column | Used by |
|---|---|---|
| `species.search_norm` | `species.scientific_name` | binomial search |
| `vernacular.search_norm` | `vernacular.name` | the local-name search field |
| `content_string.body_norm` | `content_string.value` | full-text lookup in the reference browser |

What a divergent normaliser looks like in practice: the build tool folds `ـ` (tatweel) and the app
does not, so `كنعـد` typed by a fisher whose keyboard inserts kashida matches zero rows — and the app
reports "no such species" rather than failing loudly.

## A8 — contradiction classes

The grid is (species × zone × month) plus the four measurement methods, roughly 40k cells. The
engine is imported, not re-implemented, so a precedence change in `catchlaw-rule-engine` re-runs
here automatically.

| Class | Example | Resolution |
|---|---|---|
| Two rules bite, neither outranks | a national and a regional March closure for *Lethrinus nebulosus* with different dates | author an explicit `supersedes:` on one |
| Contradictory minima | `min_size: 450 TL` and `min_size: 480 TL` for the same species and zone | the newer instrument must `supersedes:` the older |
| Incomparable minima | `min_size: 450 TL` and `min_size: 400 FL` | legal, but both must be shown; the engine needs `measurement_method` on both — A1 guarantees it |
| Protected plus a size rule | a species marked `protected` that also carries a `min_size` | delete the size rule; protected admits no threshold |
| Orphan zone | a rule whose `zone_id` is not in `zones.yaml` | fix the zone or the rule |
| Dead validity window | `valid_from` after `valid_until` | a typo, always |

## Failure format

One line per failure, on stderr, `<assertion-id> <file>:<line> <message>`, sorted by file then line,
followed by a count. Never a stack trace, never a partial database, never exit 0.

```
A1 content/rules.yaml:118 min_size without measurement_method
A2 content/rules.yaml:204 key 'closure.sha_ri_spring' missing for gl, ur
A6 content/plates.yaml:56 illustrator unidentified — DROP the plate
content_build: 3 assertion failures; assets/reference.db not written
```
