# E22/T04 — Iberia: the remaining orders, in `es` and `ca`

| | |
|---|---|
| **Epic** | E22 — Content authoring at scale |
| **Release** | **v2 — deferred.** Not built for v1; see `epics/RELEASES.md` |
| **Branch** | `epic/22-content/T04-iberia-orders` (cut from a current `main`) |
| **Commit** | `feat(content): author the remaining comunidad autónoma orders, with Catalan legal text (A12)` |
| **Depends on** | T01 (the authoring guide and A11) |
| **Size** | L |
| **Spec** | `SPEC.md` §8 Spanish rule-rows row, §9.1 (`es`, `gl`, `ca` justification), §9.6, §7.1, §9.5 gender |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Rule 11 — verbatim text is bundled single-locale — and `references/licence-provenance.md`'s Spain row, whose carve-out is **broader** than Brazil's and is the reason an annex table may be reproduced here and not there |
| `catchlaw-conventions-index` | Invariant 5: an *orden de vedas* is annual and lapses on a date, so half these rows will be expired at some point and every one of them must still evaluate |
| `catchlaw-rule-engine` | Rules 4 and 5 — lineage collapse and the specificity ladder. A CCAA order amended mid-season, and a bank or reserve inside it, are the two shapes Iberian content actually has |
| `catchlaw-reference-database` | Rule 8 — the citation text lands on the fisher's catch row; an *orde* and an *orden* are different words in different languages and neither is translated into the other |
| `testing-strategy` | Corpus tests over the real `content/es-*/` trees; loop naming that interpolates the jurisdiction so `--plain-name` can select one |
| `dependency-hygiene` | A12 is a comparison of two string sets and needs nothing added to the package |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, Spanish rule-rows row | *Orde da Xunta de Galicia 27/07/2012 and successors; each CCAA's orden de vedas*, and Art. 13 LPI quoted in full — including *"las traducciones oficiales"* and the note that it **excludes the disposición as a whole, so annex tables and official diagrams are covered** |
| `SPEC.md` | §9.1, `gl` and `ca` rows | Why Galician and Catalan are not padding: each is the official publication language of the instrument being bundled — Catalonia, Valencia and the Balearics publish their fishing orders in Catalan |
| `SPEC.md` | §9.6, whole | `legal_text_locales` records what exists; S13 renders a language-availability notice; the fallback chain never substitutes a different language of law; an unofficial translation is outside the Art. 13 carve-out, which covers **official** translations only |
| `SPEC.md` | §7.1, `jurisdiction` and `legal_text` | `legal_text_locales TEXT NOT NULL -- CSV, e.g. 'ar' or 'gl,es'`, and that `legal_text` carries its own `citation_id` |
| `SPEC.md` | §9.5, "Gender" | Five of six locales carry grammatical gender; `ca` is one of them, and the build asserts non-NULL |
| `.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` | "The statutory carve-outs, and their edges"; "Sourcing" | Spain's row — the whole *disposición*, text **and annexes** — its exclusion for separately authored artwork, and the `boe.es` / `xunta.gal` host rule |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | A2, A3; "A1 — the required-when matrix" | The locale and gender coverage this content must satisfy, and the year-wrapping closure rule |
| `epics/DECISIONS.md` | D-3 | Six locales, `app_ca.arb` ships, `ur` does not; and the sourcing reason Catalan is here at all |
| `epics/E04-content-build/T05-citations-and-assets.md` | "Why it is built this way" | The `accepted_hosts` allowlist these citations are checked against, and the `no_vernacular` refinement this content will use |
| `FLUTTER_GUIDE.md` | §6.1, §6.4 | Test naming with receipts, and the loop-naming rule that makes `--plain-name ES-VC` select one jurisdiction |

## What this delivers

- `content/es-ct/`, `content/es-vc/`, `content/es-ib/` — Catalonia, the Valencian Community and the
  Balearic Islands, whose orders are published in Catalan (`SPEC.md` §9.1).
- One sibling directory per further comunidad autónoma that publishes an *orden de vedas*, each in
  its own PR.
- Each directory complete: `jurisdiction.yaml`, `zones.yaml`, `citations.yaml`, `rules.yaml`,
  `closed_seasons.yaml`, `licence_types.yaml`, `gear_rules.yaml`, `penalties.yaml`,
  `legal_text.yaml`, `strings.yaml`, `changes.yaml`, `snapshot.json`.
- `content/CHANGELOG/es-ct.md` and one per sibling, generated.
- `tools/content_builder/lib/src/assert/a12_legal_text_locales.dart` — `LegalTextLocaleAssertion`.
- `tools/content_builder/lib/src/provenance/accepted_hosts.dart` — one entry per new CCAA, with its
  gazette host and the Art. 13 LPI provision quoted once and referenced by each (T03's shape).
- `tools/content_builder/test/assert/a12_legal_text_locales_test.dart`,
  `test/content/es_ct_corpus_test.dart`.

## Why it is built this way

**Art. 13 LPI is broader than Brazil's carve-out, and that difference is load-bearing.**
`SPEC.md` §8 quotes it and adds the reading: it excludes the *disposición* as a whole, **so annex
tables and official diagrams are covered**. `licence-provenance.md` says the same and names the edge —
photographs and artwork *merely reproduced alongside*, if separately authored, are not. So an Iberian
size table printed as an annex to the orden may be reproduced verbatim in `legal_text`, and T05's
Brazilian equivalent may not, because Lei 9.610 art. 8 IV reads *os textos* only. Two jurisdictions,
two rules, one corpus — and the mistake is to apply whichever one was learned first. `AUTHORING.md`
(T01) gains a row naming the difference; this task's corpus test proves an Iberian annex table ships
as `legal_text` while T05's proves a Brazilian diagram ships as originated art.

**`legal_text_locales` must equal what is actually in the corpus, so A12 exists.** §9.6 gives the
column one job — *records what exists* — and S13 renders a language-availability notice from it
(E06/T07). Nothing in E04's ten assertions compares the column against the rows, because Galicia
alone could not disagree with itself. Iberia is where it starts to: an author adds a Catalan article,
forgets the column, and S13 tells a Catalan speaker no Catalan text exists while the text sits in the
database. A12 compares the two sets in both directions and fails on either mismatch.

**A12 also refuses a locale outside the six.** D-3 fixes them at `ar`, `en`, `es`, `gl`, `ca`,
`pt_BR`. A `legal_text_locales` of `'va'` or `'ca-ES-valencia'` is a plausible-looking authoring
mistake — the Valencian Community's language question is a real one — and it would render as no
notice at all rather than as an error. The set is `kShippedLocales` (E04/T03), which is declared once.

**An official translation is a separate row with its own citation; an unofficial one is forbidden.**
Art. 13 covers *"las traducciones oficiales"*, and §9.6 says the carve-out covers official
translations **only**. So where a CCAA publishes its order in both Catalan and Spanish, both ship —
each as its own `legal_text` row, each pointing at the citation for the version it was transcribed
from, because §7.1 gives `legal_text` its own `citation_id`. What may not happen is an `es` row
transcribed from nothing, produced by translating the Catalan ourselves: that is a new derivative
work of our own making, outside the carve-out entirely, and a liability if it is wrong.
**Rejected:** one `legal_text` row with a translations map — it would make the unofficial case
representable and would lose the per-version citation.

**Catalan carries gender, and `ca` is the locale that gets it forgotten.** §9.5 and A3 (E04/T04): five
of six locales require non-NULL `gender`, and `ca` was the locale D-3 had to *add* — three places in
the skills still say `ur`. Every `species_name` row this task authors in `ca` carries `m` or `f`, and
the corpus test loops the gendered locales rather than spot-checking one.

**These orders lapse annually, and the expired ones ship.** An *orden de vedas* is an annual
instrument. Invariant 5 and `catchlaw-rule-engine` rule 1: expiry tags, it never filters. An author
looking at a lapsed 2025 order has three options and only one is right — author it with its real
`valid_to` and let the ochre bar say so; **not** delete it (the fisher then gets "no rule recorded"
for a species Spain plainly regulates), and **not** extend `valid_to` to keep the bar off the screen
(a fabricated validity window on a legal statement). The corpus test asserts at least one expired
instrument is present and still resolves, because a corpus with none has not exercised the invariant.

**Amendments share a `lineage_id`; a bank or reserve gets a `zone_id` and a specificity.**
`catchlaw-rule-engine` rule 4 collapses to the greatest `valid_from` per `(zone_id,
citation_lineage_id)`, and rule 5's ladder ranks exclusion 40 · reserve 30 · bank 20 · subzone 10 ·
region 0. Iberian content has both shapes — a mid-season *modificación* and a shellfish bank inside a
ría — and getting the lineage wrong lets a superseded amendment outrank the order that replaced it.
This is authoring, not code: T01's guide names both, and A8 is what catches the pair that ties.

## Tests first

Write every row before authoring YAML or touching `a12_legal_text_locales.dart`. Run them.
**They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `LegalTextLocaleAssertion reports A12 when a locale in legal_text is absent from legal_text_locales` | `ca` rows, column `'es'` | one `A12` naming `ca` | The text exists and S13 says it does not |
| 2 | `LegalTextLocaleAssertion reports A12 when a locale in legal_text_locales has no rows` | column `'ca,es'`, only `ca` rows | one `A12` naming `es` | S13 offers a language the corpus cannot render |
| 3 | `LegalTextLocaleAssertion accepts a jurisdiction whose sets match` | `'ca,es'` and both present | no failures | The green path, and the bilingual shape |
| 4 | `LegalTextLocaleAssertion accepts a single-locale jurisdiction` | `'ar'` and `ar` rows only | no failures | The Gulf shape must not be broken by an Iberian assertion |
| 5 | `LegalTextLocaleAssertion reports A12 for a locale outside the shipped six` | column `'va'` | one `A12` naming `va` | D-3; a plausible-looking Valencian mistake that would render as no notice at all |
| 6 | `LegalTextLocaleAssertion reports A12 when legal_text_locales is empty` | `''` | one `A12` | §7.1 marks the column `NOT NULL`; empty is the null nobody catches |
| 7 | `LegalTextLocaleAssertion ignores the order of the CSV` | `'es,ca'` vs `'ca,es'` | no failures either way | The column is a set; an ordering rule would fail a correct corpus |
| 8 | `LegalTextLocaleAssertion reports A12 when a jurisdiction has no legal_text rows at all` | column `'ca'`, no rows | one `A12` | A jurisdiction that ships rules with no text is a citation nobody can expand — §4.6's S13 promise |
| 9 | `ES-CT corpus declares legal_text_locales matching its published languages` | `jurisdiction.yaml` | equals the locale set in `legal_text.yaml` | The assertion, proved against real content rather than a fixture |
| 10 | `ES-CT corpus ships every legal_text row with its own citation_id` | `legal_text.yaml` | every row resolves | An official translation is a different published version and cites the version it came from |
| 11 | `$juris corpus carries a gender on every species_name in $locale` (loop over ES-CT, ES-VC, ES-IB × `ca`, `es`) | `vernacular.yaml` | no `A3` | §9.5; `ca` is the locale D-3 added and the one that gets forgotten |
| 12 | `$juris corpus carries a measurement_method on every size rule` (loop over the three) | `rules.yaml` | no `A1` | A CCAA annex is a size table; A1's recorded cause is a size copied without its column header |
| 13 | `ES-CT corpus reproduces an annex size table as legal_text` | one annex article | present as a `legal_text` row | Art. 13 covers the whole *disposición*; the difference from Brazil is only real if it is used |
| 14 | `$juris corpus cites only boe.es or the CCAA gazette host` (loop over the three) | `citations.yaml` | no `A9` | `licence-provenance.md`: a consolidated third-party database is paraphrased and out of date |
| 15 | `$juris corpus quotes the Art. 13 LPI provision` (loop over the three) | provenance entry | `provision` non-empty, `verified: true` | T03's evidence shape, applied to the jurisdiction whose statute is already ✅ verified in §8 |
| 16 | `ES-CT corpus retains an expired instrument and still resolves it` | a lapsed *ordre* | the rule resolves with `isExpired` true | Invariant 5; a corpus with no expired row has not exercised it |
| 17 | `ES-CT corpus shares one lineage_id across an order and its modification` | order + *modificació* | one distinct `lineage_id`, two `valid_from` | Rule 4's collapse; a separate lineage lets the superseded text outrank its replacement |
| 18 | `ES-CT corpus ranks a reserve above the region it sits inside` | reserve rule + region rule | reserve wins on specificity | Rule 5's ladder, exercised by real content rather than a unit fixture |
| 19 | `$juris corpus carries between 100 and 150 rule rows` (loop over the three) | authored rows | in range | `SPEC.md` §8's per-jurisdiction volume; a twelve-row corpus passes every other assertion |
| 20 | `$juris corpus keys no content_string to a legal_text id` (loop over the three) | `strings.yaml` | no match | `check_content_pipeline.sh` check 6; the temptation here is a "Spanish version" of a Catalan article |

```dart
// tools/content_builder/test/assert/a12_legal_text_locales_test.dart
import 'package:content_builder/src/assert/a12_legal_text_locales.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('LegalTextLocaleAssertion', () {
    test('reports A12 when a locale in legal_text is absent from legal_text_locales', () {
      final source = contentSourceWithLegalText(column: 'es', rowLocales: const ['ca', 'es']);
      final failures = const LegalTextLocaleAssertion().run(source).toList();

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A12');
      expect(failures.single.message, contains('ca'));
    });

    test('ignores the order of the CSV', () {
      final source = contentSourceWithLegalText(column: 'es,ca', rowLocales: const ['ca', 'es']);

      expect(const LegalTextLocaleAssertion().run(source), isEmpty);
    });

    test('reports A12 for a locale outside the shipped six', () {
      final source = contentSourceWithLegalText(column: 'va', rowLocales: const ['va']);

      expect(const LegalTextLocaleAssertion().run(source).single.message, contains('va'));
    });

    // … one test per row above, one behaviour each
  });
}
```

```dart
// tools/content_builder/test/content/es_ct_corpus_test.dart
import 'package:content_builder/src/load/content_source.dart';
import 'package:test/test.dart';

void main() {
  late ContentSource corpus;

  setUpAll(() async {
    corpus = await ContentSource.load(Directory('../../content'));
  });

  for (final juris in const ['ES-CT', 'ES-VC', 'ES-IB']) {
    for (final locale in const ['ca', 'es']) {
      test('$juris corpus carries a gender on every species_name in $locale', () {
        final names = corpus.speciesNamesFor(juris, locale: locale);

        expect(names, isNotEmpty);
        expect(names.map((n) => n.gender), everyElement(isNotNull));
      });
    }
  }

  test('ES-CT corpus retains an expired instrument and still resolves it', () {
    final expired = corpus.rulesFor('ES-CT').where((r) => r.validUntil != null);

    expect(expired, isNotEmpty);
    expect(corpus.resolve(expired.first, on: DateTime.utc(2026, 9, 1)).isExpired, isTrue);
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `(cd tools/content_builder && dart test test/assert/a12_legal_text_locales_test.dart
test/content/es_ct_corpus_test.dart)` → 20 failures. Case 7 is the one to watch: an implementation
that compares the raw CSV strings passes cases 1–3 and fails 7, and an implementation that compares
sorted sets passes 7 and must still fail 1 before the content exists.

## Implementation outline

1. `LegalTextLocaleAssertion` — parse `legal_text_locales` as a set (split on `,`, trim, reject
   empties); collect the distinct locales of the jurisdiction's `legal_text` rows; report the
   symmetric difference in both directions, each as its own `A12` naming the locale and the side it
   is missing from.
2. Validate both sets against `kShippedLocales` (E04/T03) — one list, declared once, per D-3.
3. Register after A11.
4. Add each new CCAA to `accepted_hosts.dart` with its gazette host, referencing the single Art. 13
   LPI provision block; §8 already marks Spain ✅ verified with the BOE link, so `verified: true`
   here is supported rather than asserted.
5. **Then author the content**, one comunidad autónoma per PR: transcribe the *orden de vedas* and
   its annexes from the gazette; author citations with a human `retrieved_on`; author rule rows with
   their measurement methods; transcribe the verbatim articles into `legal_text.yaml` in the
   published language(s), each with its own citation; author `strings.yaml` keys and their six
   translations; author `changes.yaml`.
6. Author Catalan vernacular names with gender as part of each CCAA slice, and record the
   `vernacular` and `rules` sign-offs in `content/reviewers.yaml` (T01's A11). T06 completes the
   remaining locales for the same species.
7. Regenerate `snapshot.json` and `content/CHANGELOG/<code>.md`; rebuild the `.gz` last.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 20 rows pass, and each failed first.
- [ ] 100 % branch coverage on `a12_legal_text_locales.dart`, including both directions of the
      mismatch and the outside-the-six case.
- [ ] `dart run content_builder:build` exits 0 over the whole `content/` tree, and every new CCAA's
      changelog is current under `--check`.
- [ ] Every new jurisdiction has an `accepted_hosts` entry with the Art. 13 LPI provision quoted, its
      gazette host, and `verified: true`.
- [ ] Every `legal_text` row names the published language it was transcribed from and carries its own
      `citation_id`; no row is a translation we produced.
- [ ] Every `ca` and `es` `species_name` row carries a non-NULL `gender`.
- [ ] At least one expired instrument is present per CCAA that has one, authored with its real
      `valid_to`, and it still resolves.
- [ ] `content/reviewers.yaml` carries `rules` and `legal_text` sign-offs for `ca` and `es` covering
      each new jurisdiction's corpus hash.
- [ ] The Art. 13 versus art. 8 IV difference is written into `content/AUTHORING.md`, with T05 named
      as the other side of it.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
dart run content_builder:build --in content/ --out app/assets/db/reference.db \
  --build-date "$(date -u +%F)" --generator-commit "$(git rev-parse --short HEAD)" --check
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
feat(content): author the remaining comunidad autónoma orders, with Catalan legal text (A12)

SPEC.md §9.1's test for a locale is that it is the official publication
language of the instrument being bundled. Catalonia, Valencia and the Balearics
publish their fishing orders in Catalan, so their verbatim text ships in ca —
not in a Spanish rendering of it, which §9.6 puts outside the Art. 13 carve-out
because that covers official translations only.

A12 makes jurisdiction.legal_text_locales agree with the corpus in both
directions. Galicia alone could not disagree with itself, so E04 had no reason
to check it; Iberia is where an author adds a Catalan article and forgets the
column, and S13 then tells a Catalan speaker no Catalan text exists while the
text sits in the database. A locale outside the six fails too — 'va' would have
rendered as no notice at all rather than as an error.

Art. 13 LPI excludes the disposición as a whole, so an annex size table may be
reproduced verbatim here. Lei 9.610 art. 8 IV reads "os textos" only, so the
Brazilian equivalent may not. Two jurisdictions, two rules, one corpus, and the
mistake is applying whichever was learned first — so AUTHORING.md now names the
difference and T05 is the other side of it.

An orden de vedas is annual. The expired ones are authored with their real
valid_to and still resolve, per invariant 5: deleting one gives "no rule
recorded" for a species Spain plainly regulates, and extending valid_to to keep
the ochre bar off the screen fabricates a validity window on a legal statement.

Task: E22/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
