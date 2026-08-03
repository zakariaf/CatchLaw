---
name: catchlaw-content-pipeline
description: >-
  Governs the CatchLaw content pipeline that compiles hand-authored rules.yaml, species.yaml,
  vernacular.yaml, citations.yaml, zones.yaml and plates.yaml plus a Catalogue of Life extract into
  the read-only reference.db asset — the tools/content_builder CLI as a first-class deliverable, ten
  assertions that FAIL the build on a min_size with no measurement_method, an unresolved
  content_string key in any of the six locales, a null gender in a gendered locale, a citation with
  no retrieved_on, a plate failing the illustrator death-year test, a search_norm not written by the
  shared normalise, a rule-engine contradiction, or a missing per-jurisdiction changelog diff. Use
  when authoring rules.yaml or species.yaml, adding a locale or a vernacular name, extending
  tools/content_builder, seeding reference.db, adding a citation or a bundled plate, clearing a plate
  licence question, or reviewing content_builder_assertions.dart in a diff.
---

# CatchLaw Content Pipeline

Content is not data the app happens to read — it IS the product, and the app is a viewer for it. A
wrong row in `rules.yaml` costs Khalid AED 3,000 and six months of licence, so every row is authored
out of band, asserted in CI and shipped as a byte-reproducible `app/assets/db/reference.db`. This skill
owns the authoring formats, the `tools/content_builder` CLI, the assertions that fail the build, licence
provenance and the changelog. It does not own the runtime schema, resolution semantics, or wording.

Read the reference for the task at hand:
- `references/build-assertions.md` — the build assertions, the rules.yaml schema, required-when
  matrix, locale and gender coverage, normalisation parity, contradiction classes, failure format.
- `references/licence-provenance.md` — per-jurisdiction statutes, gazette-only sourcing, the
  death-year term ladder, the plate ledger, drop rules, the two translation tiers, COL attribution.

Run `scripts/check_content_pipeline.sh` before a PR.

Table definitions, DAOs and the lazy asset copy belong to `catchlaw-reference-database` and
`persistence-drift`; resolution semantics to `catchlaw-rule-engine`; ARB and gen-l10n to
`i18n-rtl-l10n`; wording to `catchlaw-verdict-contract`. This skill governs only how those bytes
come into existence.

## Non-negotiable rules

1. **The build tool is a tested package, never a shell script.** `tools/content_builder` is a pub
   workspace member with its own `pubspec.yaml`, unit tests and typed CLI:
   `dart run content_builder:build --in content/ --out app/assets/db/reference.db`. **WHY:** a
   `sqlite3 < load.sql` pipeline emits a database nobody can reproduce, diff, or explain to a regulator.

2. **Every assertion FAILS the build. There is no warning tier.** Non-empty failure list means
   `exitCode = 1` and no `.db` is written; there is no `--force`, no `--skip-assertions`, no
   `--allow-missing-locale`. **WHY:** a warning is a broken row that ships, and the flag that exists
   is the flag CI uses at 18:00 on a Friday to unblock a release.

3. **A `min_size` with no `measurement_method` is an ERROR, not a default.** Every size rule carries
   `measurement_method: TL | FL | CW | SHL` — `min_size: 650` on *Scomberomorus commerson* is fork
   length, not total. **WHY:** TL and FL differ by 6-9 cm on a Kanaad, so an inferred method turns a
   legal fish into a fine and a fine into a false acquittal.

4. **Every `*_key` resolves in `content_string` for EVERY shipped locale.** All six — `ar`, `en`,
   `es`, `gl`, `ca`, `pt_BR` — resolve or the build dies; there is no fallback chain to `en` and no
   empty-string placeholder. **WHY:** a missing key renders a blank line under the stamp, and blank
   is not a verdict, it is a screen he cannot act on.

5. **A `species_name` in a gendered locale carries a non-null `gender`.** `ar`, `es`, `gl`, `ca`
   and `pt_BR` require `gender: m | f`; only `en` may omit it. **WHY:** "la mero" instead of "el mero"
   reads as machine translation, and a document that reads machine-translated is not believed when
   it states a prohibition.

6. **Every `citation_id` resolves AND carries a human `retrieved_on`.** Instrument, article,
   `published_on`, `retrieved_on`, `source_url`, `sha256` — Ministerial Decision 580/2015, Art. 3,
   published 2015-11-03, retrieved 2026-07-14. **WHY:** an uncited verdict is an opinion, and
   `DateTime.now()` at build time records when a machine ran, not when a human read the gazette.

7. **Plates pass the illustrator DEATH-YEAR test, never a publication date.** "Pre-1930 is public
   domain" is the US rule and is WRONG for the EU (life+70), Spain (80 pma for pre-1987 deaths),
   Brazil (life+70) and the UAE (life+50). **WHY:** we ship into all four; an artist who died in
   1958 is still in copyright in Galicia while a US-only test waves the plate through.

8. **An unattributable plate is DROPPED, never bundled pending.** No identified illustrator and no
   death year means the row is deleted from `plates.yaml`, not marked `licence: unknown` or
   `review: later`. **WHY:** "pending" ships, and an infringement claim against a fisheries-safety
   app is the story that ends the project rather than the sprint.

9. **`search_norm` and `body_norm` come from the shared `normaliseSpeciesTerm()`.** Imported from
   `package:rule_engine/rule_engine.dart` — the exact function the search field calls — and a
   parity pass recomputes every persisted column byte-for-byte. **WHY:** a second normaliser that
   strips one more Arabic diacritic means "كنعد" typed at 05:40 matches nothing that was written.

10. **The shipped rule engine resolves the authored grid BEFORE it ships.** `package:rule_engine`
    evaluates every (species, zone, month) cell and any `ResolutionConflict` fails the build.
    **WHY:** two rows that each validate can still contradict, and the tie is broken at sea, offline,
    in favour of whichever row the query returned first.

11. **Verbatim legal text is bundled SINGLE-LOCALE, in the language of publication.** `legal_text`
    carries one `text_locale` — `ar` for UAE, `es` for Spain, `pt` for Brazil — and NO row in
    `content_string` may key a `legal_text.*` id. **WHY:** an unofficial translation of a penal
    instrument is a liability and falls outside Spain's Art. 13 LPI carve-out entirely.

12. **Text comes from the official gazette, never a third-party abstract.** `source_url` must point
    at the UAE Official Gazette, BOE/DOG or Diário Oficial da União, with a `sha256` of the fetched
    document; NGO summaries, aggregator sites and commissioned translations are rejected. **WHY:** an
    abstract is both copyrighted and paraphrased, and a paraphrased minimum size is a wrong number.

## The tool is the deliverable

`tools/content_builder` is a workspace member beside `packages/rule_engine`, imports the same shared
code the app does, and is reviewed like app code. Its `main` does exactly four things: load, assert,
emit, changelog — and it never reaches `emit` with a non-empty failure list.

```dart
// WRONG — an untested shell pipeline; the .db is not reproducible and not reviewable.
//   sqlite3 app/assets/db/reference.db < schema.sql && python3 tools/load.py content/*.yaml

// RIGHT — tools/content_builder/bin/build.dart, a tested CLI in the pub workspace.
Future<void> main(List<String> args) async {
  final opts = ContentBuildOptions.parse(args); // --in content/ --out app/assets/db/reference.db
  final source = await ContentSource.load(opts.inDir); // yaml + col_extract.tsv
  final failures = await runAllAssertions(source, kShippedLocales);
  if (failures.isNotEmpty) {
    for (final f in failures) stderr.writeln(f.render()); // A3 species.yaml:118 gender null (es)
    exitCode = 1; // no --force, no --skip-assertions, no warning tier
    return;       // and NOTHING is written to assets/
  }
  await emitReferenceDb(source, opts.outFile);
  await emitChangelogs(source, opts.changelogDir); // one .md per jurisdiction
}
```

Full worked file: `examples/content_builder_assertions.dart`.

## A size is a number AND a method

The pair is inseparable in the schema, not merely validated after the fact, so no code path can
construct a minimum without the method it is measured by. The loader is the only constructor.

```dart
// WRONG — nullable method; "45 cm" measured how? The engine has to guess, and it guesses TL.
class SizeRule { final int? minSizeMm; final String? measurementMethod; }

// RIGHT — the type makes the pair inseparable; A1 rejects the row before construction.
final class MinSizeRule extends RuleSpec {
  const MinSizeRule({required this.minSizeMm, required this.method, required this.citationId});
  final int minSizeMm;            // 450 — Epinephelus coioides, Ras Al Khaimah
  final MeasurementMethod method; // MeasurementMethod.totalLength — authored, never inferred
  final String citationId;        // 'ae-md-580-2015-art3'
}

if (row.containsKey('min_size') && !row.containsKey('measurement_method')) {
  failures.add(Failure.a1(file, row.line, 'min_size without measurement_method'));
}
```

Full worked file: `examples/content_builder_assertions.dart`.

## Two translation tiers, and one of them is single-locale

ARB is tier one and covers UI chrome only (`i18n-rtl-l10n`). The `content_string` table is tier two
and covers bundled content. Verbatim legal text is neither: one row, one language, labelled as the
original, never in a translatable table.

```dart
// WRONG — the verbatim article pushed through the translatable table. An unofficial rendering
// of a penal instrument is a liability and sits outside the Spanish Art. 13 LPI carve-out.
contentString.insert(key: 'legal_text.ae_md580_art3', locale: 'en', value: englishRendering);

// RIGHT — verbatim text is ONE row, in the language the authority published it.
legalText.insert(LegalTextRow(
  id: 'ae-md-580-2015-art3',
  textLocale: 'ar', // the UAE Official Gazette publishes in Arabic
  verbatim: articleThreeArabic,
  sourceUrl: gazetteUrl, sha256: digest, retrievedOn: DateTime.utc(2026, 7, 14),
));
// The editorial SUMMARY is translated, and is labelled a summary in all six locales.
for (final locale in kShippedLocales) { // ar en es gl ca pt_BR
  contentString.insert(key: 'summary.ae_md580_art3', locale: locale, value: summaries[locale]!);
}
```

Full worked file: `examples/content_builder_assertions.dart`.

## Normalisation is imported, never reimplemented

The build writes the index the app queries. If the two normalisers differ by one codepoint the
search box returns nothing and the fisher concludes the species is not in the app.

```dart
import 'package:rule_engine/rule_engine.dart' show normaliseSpeciesTerm;

// WRONG — a second normaliser inside the build tool. It folds one more Arabic diacritic than
// the app's does, so 'كنعد' typed with wet hands at 05:40 matches zero rows that were written.
String buildNorm(String s) => s.toLowerCase().replaceAll(RegExp(r'[ً-ْ]'), '');

// RIGHT — the app's own function, imported, plus a parity pass that fails the build.
row.searchNorm = normalise(row.localName); // 'هامور Hamour' and 'Ameixa babosa'
row.bodyNorm = normalise(row.body);
assertNormParity(db, columns: const [
  'species.search_norm', 'vernacular.search_norm', 'content_string.body_norm',
]); // A7 recomputes every persisted column and compares byte-for-byte
```

Full worked file: `examples/content_builder_assertions.dart`.

## Plates: the death-year test, not the publication-date test

A plate is cleared against the LONGEST term among the jurisdictions we ship into, counted from the
illustrator's death. Publication year is evidence about the artist, never the test itself.

```dart
// WRONG — the US rule applied to a six-locale app; "pre-1930" says nothing about Spain.
if (plate.publishedYear < 1930) bundle(plate);

// RIGHT — longest term across every shipped jurisdiction, counted from the artist's death.
int termFor(int deathYear) => deathYear <= 1987 ? 80 : 70; // ES 80 pma; EU/BR 70; AE 50

bool clearToBundle(PlateSpec p, int buildYear) =>
    p.illustrator != null &&
    p.illustratorDeathYear != null &&
    buildYear > p.illustratorDeathYear! + termFor(p.illustratorDeathYear!);

// Build year 2026 means the artist must have died in 1945 or earlier.
// Bloch, Marcus Elieser (d. 1799)  -> bundled, ledger row complete.
// Unattributed 1911 lithograph    -> DROPPED. Not 'pending', not 'licence: unknown'.
```

Full worked file: `examples/content_builder_assertions.dart`.

## Run the engine over the data, then diff the jurisdictions

Row-level assertions cannot see contradictions. The shipped engine is imported and run across the
authored grid, and only then is a per-jurisdiction changelog emitted as a diff against the last tag.

```dart
import 'package:rule_engine/rule_engine.dart';

// WRONG — every row validates, so ship it. Two rows that each validate still contradict.
if (rows.every(validateRow)) await emitReferenceDb(rows, out);

// RIGHT — resolve every authored cell with the same engine the phone will run.
final engine = RuleEngine(source.asRuleSet());
for (final cell in source.resolutionGrid()) { // species x zone x month, ~40k cells
  switch (engine.evaluate(cell)) {
    case ResolutionConflict(:final ruleIds):
      failures.add(Failure.a8(cell, 'two rules bite and neither outranks: $ruleIds'));
    case ResolutionMissingCitation(:final ruleId):
      failures.add(Failure.a4(cell, 'resolved rule $ruleId has no citation row'));
    default: // resolved cleanly
  }
}
await writeChangelog('content/CHANGELOG/ae-rak.md', diffAgainstTag(previous, source, 'AE-RAK'));
```

Full worked file: `examples/content_builder_assertions.dart`.

## Anti-patterns

- **`min_size: 450` with no `measurement_method:`** — TL and FL differ by 6-9 cm on a Kanaad, so the
  engine's guess is a wrong verdict on a legal fish.
- **`--skip-assertions` / `--force`** — the flag that exists is the flag a release uses on a Friday,
  and the row it waves through is the one that reaches an inspector.
- **`String normalise(String s)` declared inside `tools/content_builder`** — drifts from the app's by
  one codepoint and search silently returns nothing for Arabic input.
- **`if (plate.publishedYear < 1930)`** — the US test; Spain's 80 pma and Brazil's life+70 both
  outlive it, and we ship into both.
- **`illustrator: unknown` with `licence: review-later`** — unattributable means DROPPED; "pending"
  is a state that ships.
- **A commissioned English rendering of Ministerial Decision 580/2015 in `content_string`** — an
  unofficial translation of a penal instrument, presented as if it were the instrument.
- **`source_url` pointing at an NGO species-guide page** — a third-party abstract is copyrighted,
  paraphrased, and out of date the moment the gazette amends the article.
- **`retrieved_on: DateTime.now()` computed in the builder** — records when the build ran, not when
  a human opened the gazette, which is the only fact the footnote claims.
- **`gender: null` on an `es` `species_name`** — "la mero" destroys the printed-document register
  that is the entire reason the verdict is believed at all.
- **A rule hand-written into a drift migration** — bypasses every assertion, cannot be diffed per
  jurisdiction, and is invisible to the contradiction pass.

## Definition of done

- [ ] `scripts/check_content_pipeline.sh` is clean over `lib/`, and over `.` (so `content/` too).
- [ ] `dart run content_builder:build --in content/ --out app/assets/db/reference.db` exits 0, and a
      non-empty failure list writes no `.db` at all (rules 1, 2).
- [ ] No `min_size` row lacks `measurement_method`; every method is TL, FL, CW or SHL (rule 3).
- [ ] Every `*_key` resolves in `content_string` for `ar`, `en`, `es`, `gl`, `ca` and `pt_BR`, with
      no fallback chain (rule 4).
- [ ] Every `species_name` in a gendered locale carries a non-null `gender`, and every rule's species
      has a silhouette and at least one vernacular name per locale (rule 5).
- [ ] Every `citation_id` resolves and carries `published_on`, `retrieved_on`, a gazette `source_url`
      and a `sha256` (rules 6, 12).
- [ ] Every bundled plate names an illustrator who died in 1945 or earlier for a 2026 build, and
      unattributable plates are absent from `plates.yaml`, not flagged (rules 7, 8).
- [ ] The `*_norm` parity pass recomputes every persisted column with `package:rule_engine`
      `normaliseSpeciesTerm()` and matches byte-for-byte (rule 9).
- [ ] The contradiction pass resolves the full (species, zone, month) grid with zero
      `ResolutionConflict` (rule 10).
- [ ] `legal_text` holds exactly one locale per instrument, no `content_string` row keys a
      `legal_text.*` id, and `content/CHANGELOG/*.md` is regenerated and committed (rule 11).

## Related skills

- See `catchlaw-reference-database` for the read-only asset's table definitions, indexes, the lazy
  open and the asset-copy path this pipeline's output must satisfy.
- See `catchlaw-rule-engine` for the resolution and precedence semantics the contradiction pass
  imports rather than re-implements.
- See `catchlaw-verdict-contract` for the statement-of-fact wording every `content_string` summary
  is authored against.
- See `catchlaw-offline-guarantee` for why the whole corpus must be bundled and why an expired
  ruleset is still shipped and evaluated.
- See `catchlaw-measurement-ruler` for what TL, FL, CW and SHL mean at the fish, which is what
  `measurement_method` names.
- See `lonja-icons-and-plates` for how a cleared plate is rendered as an engraved silhouette and the
  sizes it must be supplied in.
- See `i18n-rtl-l10n` for tier-one ARB and gen-l10n, ICU plurals and the bidi isolation the Arabic
  content rows depend on.
- See `ci-pipeline-and-gates` for wiring `content_builder` and this skill's gate into the pipeline as
  a required check.

## References

- Dart — pub workspaces: https://dart.dev/tools/pub/workspaces
- Drift — documentation: https://drift.simonbinder.eu/
- Catalogue of Life — data download and licence: https://www.catalogueoflife.org/data/download
- WIPO — Berne Convention for the Protection of Literary and Artistic Works: https://www.wipo.int/treaties/en/ip/berne/
- EUR-Lex — Directive 2006/116/EC on the term of protection: https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex%3A32006L0116
- BOE — Texto Refundido de la Ley de Propiedad Intelectual: https://www.boe.es/buscar/act.php?id=BOE-A-1996-8930
- Planalto — Lei 9.610/1998 (direitos autorais): https://www.planalto.gov.br/ccivil_03/leis/l9610.htm
