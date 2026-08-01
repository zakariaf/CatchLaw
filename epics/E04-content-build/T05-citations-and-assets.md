# E04/T05 — Citations, silhouettes and one name per locale

| | |
|---|---|
| **Epic** | E04 — Content builder and the Galicia seed |
| **Branch** | `epic/04-content-build` (shared) |
| **Commit** | `feat(content_builder): fail the build on an unresolved citation, a missing silhouette or a missing vernacular name` |
| **Depends on** | T02 (`Failure`, the registry), T03 (`kShippedLocales`) |
| **Size** | M |
| **Spec** | `SPEC.md` §8 bullets 4 and 5, §7.1 `citation`, §9.2 (sourcing), §4.7 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Rules 6 and 12, `references/build-assertions.md` A4/A5/A9, and `references/licence-provenance.md` for the accepted gazette hosts per jurisdiction |
| `catchlaw-conventions-index` | Invariant 3 — every result carries a required, non-nullable `Citation`; A4 is what makes that representable in the data |
| `catchlaw-rule-engine` | Rule 9 — `Finding({required Citation citation})`. The engine cannot construct a finding without one, so an unresolved `citation_id` is a build failure and never a runtime null |
| `testing-strategy` | Loop naming across the six locales, one behaviour per test |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, bullets 4 and 5 | "assert every `citation_id` exists and has a `retrieved_on` date"; "assert every rule's species has a silhouette and ≥1 vernacular name per locale" |
| `SPEC.md` | §7.1, `citation` and `species` | The columns: `published_on`, `retrieved_on`, `source_url`, and `species.silhouette_asset TEXT NOT NULL` |
| `SPEC.md` | §8, the bundled-data table | The Galician row: Orde da Xunta 27/07/2012 and successors, Art. 13 LPI, and `assets/sil/` as the silhouette home |
| `SPEC.md` | §9.2 | Sourcing per tier; English comes solely from the CoL vernacular extension; FAO ASFIS is explicitly not used |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | A4, A5, A9 rows | The failure shapes, including `A5 species.yaml:31 'venerupis-corrugata' has no silhouette` |
| `.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` | "Sourcing: the gazette, and nothing else" | `boe.es` and `xunta.gal` for Spain; the sha256 and the human `retrieved_on` |
| `.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh` | check 2 | The awk window over `- id:` blocks — which fixes the citations.yaml block shape |
| `epics/CONVENTIONS.md` | §9, invariant 3 | The invariant this assertion protects |

## What this delivers

- `tools/content_builder/lib/src/assert/a04_citations.dart` — `CitationAssertion` (A4 + A9).
- `tools/content_builder/lib/src/assert/a05_species_assets.dart` — `SpeciesAssetAssertion`.
- `tools/content_builder/lib/src/provenance/accepted_hosts.dart` — the per-jurisdiction host
  allowlist from `licence-provenance.md`.
- `content/es-ga/citations.yaml` — the authored block shape.
- `tools/content_builder/test/assert/a04_citations_test.dart`,
  `test/assert/a05_species_assets_test.dart`.

The authored citation block, shaped so `check_content_pipeline.sh` check 2 can read it:

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

## Why it is built this way

**A4 is what makes invariant 3 representable.** `CONVENTIONS.md` §9 invariant 3 and
`catchlaw-rule-engine` rule 9 both require a non-nullable `Citation` on every finding. The engine
cannot enforce that against data — it can only refuse to compile a `Citation?`. The data side of the
same contract is A4: every `citation_id` referenced by a `rule`, `closed_season`, `licence_type`,
`gear_rule`, `penalty` or `legal_text` row resolves to a citation that exists and carries both dates.
Without it, the emit step writes a foreign key SQLite happily accepts as `NULL` on a nullable column,
and the first uncited finding is discovered by an inspector.

**`retrieved_on` is authored, and the tool must never be able to supply it.**
`licence-provenance.md` is explicit: the footnote on the result screen claims a human opened the
gazette on that date, and that claim must be true. `DateTime.now()` records when a machine ran. A4
therefore fails on a missing `retrieved_on`, and T01's ban on `DateTime.now()` anywhere in
`tools/content_builder/lib/` is what stops somebody helpfully filling it in. Two further checks make
the date meaningful rather than decorative: `retrieved_on` may not be earlier than `published_on`
(you cannot have read it before it existed) and may not be later than `--build-date` (you cannot have
read it after the build).

**A9's host allowlist ships with A4 because they fail together.** `licence-provenance.md` accepts
`boe.es` and `xunta.gal` for Spain, `in.gov.br` and the state equivalent for Brazil, and the UAE
Official Gazette domain for the UAE, and rejects NGO summaries, law-firm databases and commissioned
translations. A paraphrased minimum size is a wrong number, and it is wrong in a way that looks
entirely plausible in review. The allowlist is a `const` map keyed by jurisdiction code, so E22 adds
a jurisdiction and its hosts in one place. A jurisdiction with no allowlist entry fails — silence is
not permission here either.

**The UAE row is unresolved and must stay visibly unresolved.** `SPEC.md` §8 marks the Gulf licence
basis "cited but not independently verified in this session", and says the provision must be confirmed
per state **before that state's content ships**. The allowlist encodes this as a jurisdiction gate:
an entry carries `verified: true|false`, and a `false` entry fails A9 for every citation in that
jurisdiction. Galicia is `true`, with the BOE Art. 13 LPI link from the `SPEC.md` §8 table. This costs
E22 nothing it should not already be paying.

**`sha256` is an authoring field, not a §7.1 column.** `licence-provenance.md` requires a sha256 of
the fetched document. `SPEC.md` §7.1's `citation` table has no such column, and §7.1 is authoritative
for the schema. So the digest is asserted at build time and carried into the per-jurisdiction
changelog (T09), not into the database. **Rejected:** adding a `sha256` column. Inventing a column
puts the builder and E05's drift schema out of step, and E05 generates its tables from §7.1.

**A5 and the assertion this epic refines, once.** `SPEC.md` §8 bullet 5 requires every rule's species
to carry at least one vernacular name **per locale**. Read literally, *Venerupis corrugata* needs an
Arabic name. No Galician instrument names a clam in Arabic; the CoL vernacular extension may not
either; and `SPEC.md` §9.2 step 3 says plainly that *a wrong vernacular name is worse than no name,
because it produces a confident wrong finding*. Inventing a transliteration is also exactly what
`normalisation-contract.md` forbids — normalisation folds orthography and never guesses
transliteration.

The refinement: a species may carry, per locale, an authored declaration
`no_vernacular: { ar: reason.no_arabic_name_for_galician_bivalve }` whose value is a `*_key` and is
therefore itself translated into all six locales by T03's A2. A5 accepts that as coverage; a locale
with neither a name nor a declaration still fails. The declaration is reviewable, greppable, appears
in the T09 diff when it changes, and lets `SPEC.md` §9.2's fallback chain run down to the scientific
name — which is where the chain already ends. **Rejected:** accepting a silent gap, because a missing
name and a decided absence are then indistinguishable in a diff; and inventing an Arabic name, for the
reason §9.2 gives. This is the one place E04 does not implement a §8 bullet to the letter, it is
recorded in the epic's Risks, and what would resolve it is a §8 amendment.

**A silhouette is checked on disk, not in the string.** `SPEC.md` §7.1 makes
`species.silhouette_asset` `NOT NULL`, so a missing value is already a schema error. The failure that
actually happens is a path that points at a file nobody drew: `assets/sil/venerupis-corrugata.svg`
with no such file. A5 resolves the path against `app/assets/` and fails when it does not exist.
`build-assertions.md` records the cause — "a shellfish added late, art not commissioned".

## Tests first

Write every row before touching either assertion. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `CitationAssertion reports A4 when a rule's citation_id resolves to nothing` | `citation_id: es-ga-ghost` | one `A4` at the rule's line | Invariant 3's data half; the rule row is where the author looks |
| 2 | `CitationAssertion reports A4 when a citation has no retrieved_on` | citation with `instrument` and `article`, no `retrieved_on` | one `A4` at the citation's line | `SPEC.md` §8 bullet 4, and the footnote's claim |
| 3 | `CitationAssertion reports A4 when a citation has no published_on` | no `published_on` | one `A4` | The footnote prints both dates; one of them is not optional |
| 4 | `CitationAssertion reports A4 when retrieved_on precedes published_on` | published 2012, retrieved 2011 | one `A4` | Nobody read it before it existed; catches a transposed pair |
| 5 | `CitationAssertion reports A4 when retrieved_on is after the build date` | retrieved 2027, build 2026 | one `A4` | A future retrieval date is a typo or a copied template |
| 6 | `CitationAssertion accepts a complete citation` | the worked block above | no failures | The green path |
| 7 | `CitationAssertion checks citation_id on every referencing table` (loop over `rule`, `closed_season`, `licence_type`, `gear_rule`, `penalty`, `legal_text`) | an unresolved id on `$table` | one `A4` per case | Six tables carry a `citation_id`; a check that covers only `rule` ships five uncited surfaces |
| 8 | `CitationAssertion reports A9 when source_url host is outside the jurisdiction's allowlist` | `source_url` on an NGO domain | one `A9` | A third-party abstract is paraphrased, and a paraphrased minimum size is a wrong number |
| 9 | `CitationAssertion accepts xunta.gal and boe.es for ES-GA` (loop over the two) | `source_url` on `$host` | no failures | `licence-provenance.md`'s Spanish row |
| 10 | `CitationAssertion reports A9 when the jurisdiction's licence basis is unverified` | jurisdiction marked `verified: false` | one `A9` per citation | `SPEC.md` §8 forbids shipping a state whose provision is unconfirmed; the gate is the data, not a memo |
| 11 | `CitationAssertion reports A9 when a citation has no sha256` | block without `sha256` | one `A9` | The digest is what makes "we read this document" checkable later |
| 12 | `SpeciesAssetAssertion reports A5 when a rule's species has no silhouette file` | `silhouette_asset` pointing at a missing file | one `A5` naming the species id | The recorded cause: a shellfish added late, art not commissioned |
| 13 | `SpeciesAssetAssertion accepts a species whose silhouette file exists` | file present in the fixture tree | no failures | The green path |
| 14 | `SpeciesAssetAssertion reports A5 when a rule's species has no name for $locale` (loop over the six) | names in five locales | one `A5` naming `$locale` | Six locales, six chances; `pt_BR` is the one that gets forgotten |
| 15 | `SpeciesAssetAssertion accepts a declared no_vernacular for a locale` | `no_vernacular: {ar: reason.…}` | no failures | The refinement — a decided absence is coverage |
| 16 | `SpeciesAssetAssertion reports A5 when no_vernacular carries no reason key` | `no_vernacular: {ar: ''}` | one `A5` | An empty reason is a silent gap wearing the escape's clothes |
| 17 | `SpeciesAssetAssertion ignores a species that no rule references` | species with no rule | no failures | `SPEC.md` §8 scopes the assertion to a **rule's** species; the identification key carries species with no rule of their own |

```dart
// tools/content_builder/test/assert/a04_citations_test.dart
import 'package:content_builder/src/assert/a04_citations.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('CitationAssertion', () {
    test('reports A4 when a citation has no retrieved_on', () {
      final source = contentSourceWithCitation(retrievedOn: null);
      final failures = const CitationAssertion().run(source).toList();

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A4');
      expect(failures.single.message,
          "'es-ga-orde-2012-07-27-art4' has no retrieved_on");
    });

    for (final table in const [
      'rule', 'closed_season', 'licence_type', 'gear_rule', 'penalty', 'legal_text',
    ]) {
      test('checks citation_id on every referencing table ($table)', () {
        final source = contentSourceWithDanglingCitation(onTable: table);
        expect(const CitationAssertion().run(source), hasLength(1));
      });
    }

    // … one test per row above, one behaviour each
  });
}
```

```dart
// tools/content_builder/test/assert/a05_species_assets_test.dart
import 'package:content_builder/src/assert/a05_species_assets.dart';
import 'package:content_builder/src/locales.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('SpeciesAssetAssertion', () {
    for (final locale in kShippedLocales) {
      test("reports A5 when a rule's species has no name for $locale", () {
        final source = contentSourceMissingVernacular(locale: locale);
        final failures = const SpeciesAssetAssertion().run(source).toList();

        expect(failures, hasLength(1));
        expect(failures.single.message, contains(locale));
      });
    }

    test('accepts a declared no_vernacular for a locale', () {
      final source = contentSourceWithNoVernacular(
        locale: 'ar',
        reasonKey: 'reason.no_arabic_name_for_galician_bivalve',
      );
      expect(const SpeciesAssetAssertion().run(source), isEmpty);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `(cd tools/content_builder && dart test test/assert/a04_citations_test.dart
test/assert/a05_species_assets_test.dart)` → every case red. If any passes now, the test is wrong.

## Implementation outline

1. `accepted_hosts.dart` — `const Map<String, JurisdictionProvenance>` keyed by jurisdiction code,
   each carrying `hosts` and `verified`, transcribed from `licence-provenance.md` §"Sourcing" and the
   `SPEC.md` §8 licence table. A missing key is a failure, not a pass.
2. `CitationAssertion.run`: index citations by id once; walk the six referencing tables; yield A4 for
   an unresolved id at the *referencing* row's line and A4 for an incomplete citation at the
   *citation's* line.
3. Date ordering compared as dates, never as strings, and against `options.buildDate` — the value
   T01 made a required argument.
4. Host extraction with `Uri.parse(...).host`, matched by suffix so `www.xunta.gal` and `xunta.gal`
   both pass and `xunta.gal.example.com` does not.
5. `SpeciesAssetAssertion.run`: collect the set of species ids referenced by any `rule` row; for each,
   resolve `silhouette_asset` against the assets root passed in from the CLI, then check the six
   locales against names plus `no_vernacular` declarations.
6. Emit each `no_vernacular` reason as a `KeyReference` so T03's A2 forces its six translations.
7. Register both after A3 in `ContentSource.assertions`.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 rows pass, and each failed first.
- [ ] 100 % branch coverage on `a04_citations.dart` and `a05_species_assets.dart`.
- [ ] Every table in `SPEC.md` §7.1 that carries a `citation_id` column is covered by case 7.
- [ ] `retrieved_on` cannot be produced by the tool: `grep -rn "DateTime.now" tools/content_builder`
      still returns nothing.
- [ ] The `no_vernacular` refinement is documented in `content/README.md` with the `SPEC.md` §8
      wording it refines and the §9.2 reason it exists.
- [ ] A jurisdiction with `verified: false` fails every citation in it, proved by case 10.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content_builder): fail the build on an unresolved citation, a missing silhouette or a missing vernacular name

Invariant 3 says every result carries a required, non-nullable Citation. The
engine can only refuse to compile a Citation?; the data half is this
assertion. Every citation_id on rule, closed_season, licence_type, gear_rule,
penalty and legal_text must resolve, and the citation must carry both dates.

retrieved_on is authored and the tool cannot supply it: the footnote claims a
human opened the gazette that day, and DateTime.now() records when a machine
ran. It must also fall between published_on and --build-date, which catches a
transposed pair and a copied template.

The gazette host allowlist ships with it because they fail together — a
third-party abstract is paraphrased, and a paraphrased minimum size is wrong
in a way that reads as plausible. A jurisdiction whose licence basis is not
independently verified fails every citation in it, which is what SPEC.md §8
already requires of the Gulf states.

SPEC.md §8 bullet 5 read literally requires an Arabic name for a Galician
clam. §9.2 says a wrong vernacular name is worse than none. A species may
instead declare no_vernacular with a reason key, itself translated into all
six locales; a locale with neither a name nor a declaration still fails.
Recorded in content/README.md and in the epic's Risks as the one §8 bullet
this epic refines.

Task: E04/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
