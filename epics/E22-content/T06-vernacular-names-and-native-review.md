# E22/T06 — Vernacular names in six locales, and native review

| | |
|---|---|
| **Epic** | E22 — Content authoring at scale |
| **Branch** | `epic/22-content/T06-vernacular-names` (cut from a current `main`) |
| **Commit** | `feat(content): author ~2,400 vernacular names under the §9.2 sourcing order (A13)` |
| **Depends on** | T03, T04, T05 (the instruments are the primary source, so they must be transcribed first), T01 (A11) |
| **Size** | L |
| **Spec** | `SPEC.md` §9.2 in full, §8 vernacular-names and scientific-names rows, §9.1, §9.4, §9.5 gender, §7.1 `species_name` |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Rules 4, 5 and 9, and `references/licence-provenance.md` "Taxonomy" and "The two translation tiers" — CoL is CC BY 4.0 with an attribution row, and is never a source of legal content |
| `catchlaw-rule-engine` | Rules 10 and 11: one normaliser, and the definite article indexed **both** ways. Every name authored here is written into `search_norm` by that function, and the §9.4 acceptance test is the thing this content has to satisfy |
| `catchlaw-reference-database` | Rule 8 — `common_name` is denormalised onto the catch row, so a wrong name is permanent in a fisher's record |
| `catchlaw-conventions-index` | Rule 12 and D-3: six locales ship together or the feature does not ship; and the routing that keeps ARB (tier 1) out of this task entirely |
| `testing-strategy` | Loop naming across six locales with the parameter interpolated, so `--plain-name gl` selects one |
| `dependency-hygiene` | The CoL extract is an input file, not a package; nothing is added to `pubspec.yaml` to read a TSV |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.2, steps 1–4 and the fallback chain | The sourcing order; that English has **no** instrument source and comes **solely** from the CoL vernacular-name extension; that **FAO ASFIS is explicitly not used** because FAO's terms permit non-commercial use only; that review is by one native-speaking fisher or fisheries officer per locale; and that **English is the last Tier-2 language authored** |
| `SPEC.md` | §8, vernacular-names row | Primary is the legal instruments themselves; cross-check and sole English source is the CoL vernacular extension; CC BY 4.0; < 1 MB |
| `SPEC.md` | §8, scientific-names row | Catalogue of Life COL26.7, ChecklistBank dataset 315777, CC BY 4.0, attribution in S17 and `ATTRIBUTIONS.md` |
| `SPEC.md` | §7.1, `species_name` | The columns: `locale`, `name`, `search_norm`, `gender`, `is_primary`, `region_hint` — and the two indices a name is searched through |
| `SPEC.md` | §9.4 | The fold that writes `search_norm`, and the acceptance test: `hamour`, `هامور`, `هامورة`, `الهامور` and `Epinephelus coioides` all resolve to one species id |
| `SPEC.md` | §9.5, "Gender" | Five gendered locales; content strings are authored as complete phrases and never assembled from fragments |
| `.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` | "Taxonomy: the Catalogue of Life extract"; "The two translation tiers" | `credit.col` with the checklist version and download date; and that an invented `col_id` breaks the synonym chain silently |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rules 10, 11 | One `normaliseSpeciesTerm`; both article forms indexed; the acceptance test that pins it |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | A2, A3, A5 rows; "A2 and A3 — locale coverage and gender" | Six locales with no fallback chain, and exactly one preferred name per (species, locale) |
| `epics/E04-content-build/T05-citations-and-assets.md` | the `no_vernacular` refinement | A decided absence is coverage; a silent gap still fails |
| `FLUTTER_GUIDE.md` | §6.1, §6.4 | Test naming with receipts, and the loop-naming rule — six locales interpolated, or `--plain-name` is useless |

## What this delivers

- `content/shared/vernacular.yaml` — grown to roughly **2,400 rows** across `ar`, `en`, `es`, `gl`,
  `ca` and `pt_BR` for roughly **400 species** (`SPEC.md` §8).
- `tools/content_builder/lib/src/assert/a13_vernacular_provenance.dart` —
  `VernacularProvenanceAssertion`.
- `tools/content_builder/lib/src/model/vernacular_row.dart` — extended with `provenance` and
  `confirmed_by`.
- `content/shared/strings.yaml` — `credit.col` in all six locales, naming the checklist version and
  the download date (`licence-provenance.md` "Taxonomy").
- `content/reviewers.yaml` — the six `vernacular` sign-offs, one per locale, each listing what the
  reviewer disconfirmed.
- `tools/content_builder/test/assert/a13_vernacular_provenance_test.dart`,
  `test/content/vernacular_corpus_test.dart`.

The row, with the two fields this task adds:

```yaml
names:
  - id: epinephelus-coioides-ar-hamour
    species_id: epinephelus-coioides
    locale: ar
    name: هامور
    gender: m
    is_primary: true
    region_hint: RAK
    provenance: instrument:ae-md-580-2015-art3   # the decision names the species in Arabic
    # confirmed_by: es-ga-gl-vernacular-2026-09-14   # required only when provenance is col:
```

## Why it is built this way

**The sourcing order is a rule, so it is a build assertion.** `SPEC.md` §9.2 does not merely prefer
the instrument — it says *that text is copyright-free, and it is by definition the authoritative
wording*. A13 encodes the order as three provenance forms and one rule per locale:

| Locale | Accepted provenance | Rejected, and why |
|---|---|---|
| `ar`, `es`, `gl`, `ca`, `pt_BR` | `instrument:<citation_id>` · `review:<signoff_id>` · `col:<taxon_id>` **with** `confirmed_by:` | a bare `col:` — the CoL extension is a **cross-check** for these locales, and §9.2 step 3's warning is that a wrong name produces a confident wrong finding |
| `en` | `col:<taxon_id>` only | `instrument:` — §9.2 step 2 is explicit that **no** UAE, Xunta, CCAA or IBAMA instrument names species in English, so an `instrument:` provenance on an `en` row is a claim that cannot be true |
| any | — | `asfis:` — rejected **by name**, with the reason in the message |

**ASFIS is rejected by name, not merely absent.** §9.2: FAO's site terms permit copying for private
study, research, teaching and **non-commercial** products only, with commercial use requiring written
permission — *that is incompatible with a paid app, and the first draft named ASFIS without checking*.
An absent value is a value somebody adds; a rejected one is an argument already had. This is the same
pattern E04/T01 used for `--force` and T02 used for FAOLEX, and it is used here for the same reason:
ASFIS is the obvious dataset and it will be suggested.

**English is authored last, and A13 is what makes that ordering real.** §9.2 step 4 states it in five
words and nothing else enforces it. An `en` row may not exist for a species that has neither a name
nor a `no_vernacular` declaration in the jurisdiction's `default_locale`. Without that rule English
gets authored first because it is the easiest, and then it becomes the list the other five are
checked *against* — which is backwards, since English is the one locale with no legal instrument
behind it at all.

**A `col:` provenance names a real `col_id`.** `licence-provenance.md`: *an invented `col_id` added to
make a row validate is a data-integrity failure — the binomial stops resolving and the synonym chain
that maps a local name to Epinephelus coioides breaks silently*. A13 resolves every `col:` reference
against the checked-in extract and fails on a miss, so the failure is loud at build time instead of
silent at search time.

**A local name is kept with a `region_hint` rather than dropped.** §7.1 gives the column and its
examples — `'RAK'`, `'Rías Baixas'`. A name used in one port is not wrong; it is regional, and
dropping it is exactly the gap that makes a fisher conclude his species is not in the app. Several
names per (species, locale) are normal; **exactly one** carries `is_primary: true`, because the
result screen prints one and the species list prints the other.

**The column is `is_primary`, not `is_preferred`.** §7.1 declares `is_primary INTEGER NOT NULL
DEFAULT 0`; `build-assertions.md` writes `is_preferred: true`. §7.1 is authoritative for the schema.
Written down here once, because the two spellings would otherwise reach the YAML and the emitter
separately and the mismatch would surface as a column that is always zero.

**Every locale is reviewed by a native speaker, and the review is what this task ends on.** §9.2 step
3, budgeted, with the reason: *a wrong vernacular name is worse than no name, because it produces a
confident wrong finding.* T01's A11 makes an unreviewed locale unshippable and binds the sign-off to
a hash of the reviewed rows. The reviewer is asked to disconfirm — *which of these would send a
fisher to the wrong fish?* — and what they disconfirm is recorded, because an empty `disconfirmed`
list across six locales and 2,400 names is not a result, it is a form that was rubber-stamped.

**Arabic gets both article forms, and that is the search behaviour this content exists for.** §9.4
step 5 and `catchlaw-rule-engine` rule 11: legal instruments write `الهامور` while users type
`هامور`, so both index. E04/T07 emits the second `species_name` row carrying the same display name
with `is_primary = 0` and the article-stripped `search_norm`; this task's job is to author names the
fold can actually work on — not to transliterate, not to normalise by hand, and never to author a
name that has already been folded.

## Tests first

Write every row before authoring names or touching `a13_vernacular_provenance.dart`. Run them.
**They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `VernacularProvenanceAssertion reports A13 when a $locale row has no provenance` (loop over the six) | row without `provenance` | one `A13` per case | §9.2's order is unenforceable if a row can decline to say where it came from |
| 2 | `VernacularProvenanceAssertion accepts an instrument provenance for $locale` (loop over `ar`, `es`, `gl`, `ca`, `pt_BR`) | `instrument:<id>` | no failures | The preferred source, per §9.2 step 1 |
| 3 | `VernacularProvenanceAssertion reports A13 for an instrument provenance on an en row` | `en`, `instrument:<id>` | one `A13` quoting §9.2 step 2 | No instrument names species in English; the claim cannot be true |
| 4 | `VernacularProvenanceAssertion accepts a col provenance for an en row` | `en`, `col:<taxon>` | no failures | The sole English source |
| 5 | `VernacularProvenanceAssertion reports A13 for a bare col provenance on a $locale row` (loop over the five non-English) | `col:<taxon>`, no `confirmed_by` | one `A13` per case | CoL is a cross-check for these locales; a wrong name produces a confident wrong finding |
| 6 | `VernacularProvenanceAssertion accepts a col provenance confirmed by a sign-off for a $locale row` (loop over the five) | `col:` + `confirmed_by:` | no failures | The route a name takes when the instrument is silent and a reviewer supplied it |
| 7 | `VernacularProvenanceAssertion rejects an asfis provenance by name` | `asfis:<code>` | one `A13`, message names ASFIS and "non-commercial" | §9.2; the obvious dataset, with terms incompatible with a paid app |
| 8 | `VernacularProvenanceAssertion reports A13 when a col reference resolves to no taxon` | `col:` id absent from the extract | one `A13` | An invented `col_id` breaks the synonym chain silently |
| 9 | `VernacularProvenanceAssertion reports A13 when an instrument reference resolves to no citation` | `instrument:` id absent | one `A13` | The same failure A4 catches on rules, on the row that claims the wording is authoritative |
| 10 | `VernacularProvenanceAssertion reports A13 when a confirmed_by reference resolves to no sign-off` | dangling `confirmed_by` | one `A13` | A confirmation by nobody is the shape a rubber stamp takes |
| 11 | `VernacularProvenanceAssertion reports A13 when an en row exists with no default-locale name` | `en` only, no `ar` name and no `no_vernacular` | one `A13` | §9.2 step 4 — English authored last, made real |
| 12 | `VernacularProvenanceAssertion accepts an en row when the default locale declares no_vernacular` | `en` + declared absence | no failures | E04/T05's refinement: a decided absence is coverage |
| 13 | `Vernacular corpus carries exactly one is_primary per species and $locale` (loop over the six) | `vernacular.yaml` | one per pair | Two primaries means the result screen and the species list print different names |
| 14 | `Vernacular corpus carries a gender on every $locale row` (loop over `ar`, `es`, `gl`, `ca`, `pt_BR`) | `vernacular.yaml` | no `A3` | §9.5; `en` is the only locale allowed to omit it |
| 15 | `Vernacular corpus omits gender on en rows` | `en` rows | `gender` absent | A gender authored on English is a copied template, and it will be rendered by an ICU select that has no English form |
| 16 | `Vernacular corpus keeps a regional name with a region_hint` | a port-specific name | present, `region_hint` set, `is_primary: false` | §7.1's column; dropping the regional name is the gap that makes a fisher think his species is missing |
| 17 | `ar - Vernacular corpus authors names unfolded` | an `ar` name | `name != normaliseSpeciesTerm(name)` where the fold would change it | A pre-folded name displays as a stripped string on the result screen |
| 18 | `ar - Vernacular corpus resolves هامور and الهامور to one species` | both queries | one species id | §9.4's acceptance test, on real content rather than a unit fixture |
| 19 | `Vernacular corpus resolves hamour, هامورة and Epinephelus coioides to the same species` | the three remaining acceptance inputs | one species id | The other half of §9.4's acceptance test — the whole reason the fold is ordered |
| 20 | `Vernacular corpus carries a name or a declared absence for every rule's species in $locale` (loop over the six) | rule species × locale | no `A5` | §8 bullet 5 with E04/T05's refinement; six locales, six chances to leave a hole |
| 21 | `Vernacular corpus attributes the Catalogue of Life in all six locales` | `credit.col` | present in six, naming the checklist version and download date | CC BY 4.0 is a condition, not a courtesy; S17 renders it |
| 22 | `Vernacular corpus carries a vernacular sign-off for $locale` (loop over the six) | `reviewers.yaml` | no `A11` | The task ends on review, and A11 is what makes that non-optional |

```dart
// tools/content_builder/test/assert/a13_vernacular_provenance_test.dart
import 'package:content_builder/src/assert/a13_vernacular_provenance.dart';
import 'package:content_builder/src/locales.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('VernacularProvenanceAssertion', () {
    for (final locale in kShippedLocales.where((l) => l != 'en')) {
      test('reports A13 for a bare col provenance on a $locale row', () {
        final source = contentSourceWithName(locale: locale, provenance: 'col:1a2b3c');
        final failures = const VernacularProvenanceAssertion().run(source).toList();

        expect(failures, hasLength(1));
        expect(failures.single.id, 'A13');
        expect(failures.single.message, contains('confirmed_by'));
      });
    }

    test('reports A13 for an instrument provenance on an en row', () {
      final source = contentSourceWithName(locale: 'en', provenance: 'instrument:ae-md-580-2015-art3');

      expect(
        const VernacularProvenanceAssertion().run(source).single.message,
        contains('no instrument names species in English'),
      );
    });

    test('rejects an asfis provenance by name', () {
      final source = contentSourceWithName(locale: 'en', provenance: 'asfis:GPX');
      final failures = const VernacularProvenanceAssertion().run(source).toList();

      expect(failures.single.message, contains('non-commercial'));
    });

    // … one test per row above, one behaviour each
  });
}
```

```dart
// tools/content_builder/test/content/vernacular_corpus_test.dart
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/locales.dart';
import 'package:rule_engine/rule_engine.dart' show normaliseSpeciesTerm;
import 'package:test/test.dart';

void main() {
  late ContentSource corpus;

  setUpAll(() async {
    corpus = await ContentSource.load(Directory('../../content'));
  });

  for (final locale in kShippedLocales) {
    test('Vernacular corpus carries exactly one is_primary per species and $locale', () {
      for (final species in corpus.speciesIds) {
        final primaries = corpus.namesFor(species, locale: locale).where((n) => n.isPrimary);

        expect(primaries, hasLength(lessThanOrEqualTo(1)), reason: '$species / $locale');
      }
    });
  }

  test('ar - Vernacular corpus resolves هامور and الهامور to one species', () {
    final bare = corpus.speciesBySearchNorm(normaliseSpeciesTerm('هامور'));
    final withArticle = corpus.speciesBySearchNorm(normaliseSpeciesTerm('الهامور'));

    expect(bare, isNotEmpty);
    expect(bare, withArticle);
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `(cd tools/content_builder && dart test test/assert/a13_vernacular_provenance_test.dart
test/content/vernacular_corpus_test.dart)` → 22 failures. Case 13 is the one that can pass early: an
empty corpus has at most one primary per pair. Check the fixture has two before believing it, and
keep the `isNotEmpty` guard in case 18 for the same reason — a corpus test over no rows is a test of
nothing.

## Implementation outline

1. Extend the vernacular row model with `provenance` and `confirmedBy`, parsed into a small sealed
   `Provenance` union (`InstrumentSource`, `ColSource`, `ReviewSource`, `RejectedSource`) so the
   per-locale rule is a switch with no `default:` arm.
2. `VernacularProvenanceAssertion`: the per-locale table above; then reference resolution against
   citations, the CoL extract and `reviewers.yaml`; then the English-last rule.
3. `asfis:` parses to `RejectedSource` with its own message quoting the non-commercial term — not a
   generic "unknown provenance", because the author needs the argument, not the error.
4. Register after A12.
5. **Then author the names**, locale by locale in the §9.2 order: `ar` from the Gulf decisions, `es`
   and `gl` from the Galician and CCAA orders, `ca` from the Catalan orders, `pt_BR` from the
   portarias — then, last, `en` from the CoL vernacular extension.
6. Add `credit.col` to `content/shared/strings.yaml` in all six locales with the checklist version
   and the download date, so S17's attribution states which extract shipped.
7. Send each locale to its reviewer with the disconfirming questions from `content/REVIEW.md`; record
   the sign-off and what they disconfirmed; **fix what they disconfirmed before the sign-off hash is
   taken**, or the ledger records agreement with rows that have since changed.
8. Re-run the build; A11 and A13 together are what say the work is finished.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 22 rows pass, and each failed first.
- [ ] 100 % branch coverage on `a13_vernacular_provenance.dart`, including every arm of the
      per-locale table and the English-last rule.
- [ ] Roughly 2,400 rows across the six locales for roughly 400 species, and every rule's species has
      a name or a declared `no_vernacular` in each of the six.
- [ ] No row carries an `asfis:` provenance; no `en` row carries an `instrument:` provenance; no
      non-English row carries a bare `col:`.
- [ ] Every `col:` id resolves in the checked-in Catalogue of Life extract.
- [ ] Exactly one `is_primary` per (species, locale); every gendered locale's rows carry `gender`;
      no `en` row carries one.
- [ ] `credit.col` exists in all six locales with the checklist version and the download date.
- [ ] `content/reviewers.yaml` carries six `vernacular` sign-offs whose `scope_hash` matches the
      current corpus, and the fixes arising from each are committed **before** its hash.
- [ ] The §9.4 acceptance test passes over the real corpus, not only over the E02 unit fixture.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
dart run content_builder:build --in content/ --out app/assets/db/reference.db \
  --build-date "$(date -u +%F)" --generator-commit "$(git rev-parse --short HEAD)" --check
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content): author ~2,400 vernacular names under the §9.2 sourcing order (A13)

SPEC.md §9.2 sets an order and gives a reason for each step, so the order is a
build assertion rather than a paragraph. Names for ar, es, gl, ca and pt_BR are
lifted from the legal instrument, which already names the species in the local
language, is copyright-free and is by definition the authoritative wording.
English has no such source: no UAE, Xunta, CCAA or IBAMA instrument names a
species in English, so an instrument provenance on an en row is a claim that
cannot be true, and English comes solely from the Catalogue of Life vernacular
extension.

FAO ASFIS is rejected by name with the reason in the message. FAO's terms
permit non-commercial use only, which is incompatible with a paid app, and the
first draft named ASFIS without checking. An absent value is one somebody adds;
a rejected one is an argument already had.

English is authored last (§9.2 step 4), and A13 makes that real: an en row may
not exist for a species with no name and no declared absence in its
jurisdiction's default locale. Otherwise English gets authored first because it
is easiest, and becomes the list the other five are checked against — backwards,
since it is the one locale with no instrument behind it.

A col: provenance must resolve in the checked-in extract. An invented col_id
breaks the synonym chain silently, and a silent break here is a species that
cannot be searched. A regional name keeps its region_hint instead of being
dropped, and exactly one name per (species, locale) is is_primary — §7.1's
spelling, not build-assertions.md's is_preferred.

All six locales are signed off by a native-speaking fisher or fisheries
officer, with what they disconfirmed recorded and fixed before the sign-off
hash was taken. A wrong vernacular name is worse than no name, because it
produces a confident wrong finding.

Task: E22/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
