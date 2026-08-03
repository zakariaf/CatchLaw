# E22/T05 — Brazil: federal and per state

| | |
|---|---|
| **Epic** | E22 — Content authoring at scale |
| **Release** | **v2 — deferred.** Not built for v1; see `epics/RELEASES.md` |
| **Branch** | `epic/22-content/T05-brazil` (cut from a current `main`) |
| **Commit** | `feat(content): author the Brazilian federal and state rules, with every graphic annex originated` |
| **Depends on** | T01 (the authoring guide and A11), T03 (`applies_to` expansion and the provenance evidence fields) |
| **Size** | L |
| **Spec** | `SPEC.md` §8 Brazilian rule-rows row and Brazilian zone-polygon row, §9.1 `pt_BR` row, §7.1, §4.4, §9.5 gender |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Rule 7 and 8 (the plate ledger and the drop rule), and `references/licence-provenance.md`'s Brazil row — **`art. 8 IV` reads *os textos***, so a species drawing printed as a portaria annex is not cleared |
| `catchlaw-rule-engine` | Rule 4's lineage collapse and rule 6's tie contract: a federal portaria and a state instrução normativa that disagree is the normal case here, not an edge case |
| `catchlaw-conventions-index` | Invariant 5 — a piracema portaria is annual and lapses — and invariant 3, the citation on every row |
| `catchlaw-measurement-ruler` | Which method a Brazilian minimum is published in, and why a rule authored `both` for water type is the mistake this jurisdiction punishes |
| `lonja-icons-and-plates` | Rules 8 and 9, and `references/engraved-plates.md`'s provenance record — the ledger every originated Brazilian figure still has to fill in |
| `testing-strategy` | Corpus tests over the real `content/br*/` trees, loop-named per jurisdiction |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, Brazilian rule-rows row | *IBAMA/MPA portarias; state instruções normativas*; Lei 9.610/1998 art. 8 IV quoted; ✅ verified on planalto.gov.br; and the ⚠: **the exclusion is limited to *os textos*, so graphic annexes to a Brazilian portaria are not clearly covered — all measurement diagrams are therefore originated SVG** |
| `SPEC.md` | §8, Brazilian zone-polygon row | IBGE and ANA are **not** covered by art. 8; Natural Earth is the safe default — the polygons themselves are T09 |
| `SPEC.md` | §9.1, `pt_BR` row | Piracema, minimum sizes and quotas are per state and Portuguese-language; `pesca defeso tamanho minimo` returns 0 results in the BR store |
| `SPEC.md` | §7.1, `rule` and `zone` | `water_type CHECK (water_type IN ('salt','fresh','both'))` on both tables, and `jurisdiction.has_freshwater` |
| `SPEC.md` | §4.4 | *Freshwater zones never show marine rules*; and Brazilian dam exclusion radii as a named override class |
| `SPEC.md` | §9.5 | `pt_BR` is a gendered locale; dates read "1 March – 30 April", never ISO |
| `.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` | "The statutory carve-outs, and their edges"; "Worked decisions" | The Brazil edge stated as *the operative one*, and the worked row: a clam diagram for a Brazilian portaria annex is bundled as `origin: originated` |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | "A1 — the required-when matrix"; A8 contradiction classes | The year-wrapping closure rule (`wraps_year: true`, authored not inferred) and the national-versus-regional overlap class |
| `.claude/skills/lonja-icons-and-plates/references/engraved-plates.md` | "Provenance record" | The five mandatory fields, and that a commissioned figure uses `9999` as the death-year sentinel |
| `epics/E22-content/T03-gulf-rule-rows-and-verbatim-text.md` | "Why it is built this way" | The `applies_to` expansion this task reuses, and the provenance evidence fields it extends |
| `FLUTTER_GUIDE.md` | §6.1, §6.4 | Test naming with receipts, and the budget: the bulk of the proof sits in pure Dart, run in milliseconds |

## What this delivers

- `content/br/` — the federal jurisdiction: IBAMA and MPA portarias, authored once with `applies_to`
  listing the states they bind (T03's expansion).
- `content/br-sp/` and `content/br-mg/` — São Paulo and Minas Gerais, the two states `SPEC.md` §17
  names, each with its state instruções normativas.
- One sibling directory per further state, each in its own PR.
- `content/CHANGELOG/br.md`, `br-sp.md`, `br-mg.md` and siblings, generated.
- `tools/content_builder/lib/src/provenance/accepted_hosts.dart` — Brazilian entries with the art. 8
  IV provision quoted, `in.gov.br` plus the state gazette host, and a new
  `carveOut: CarveOutScope.textsOnly` on the Brazilian entries against
  `CarveOutScope.wholeDisposicion` on the Spanish ones.
- `tools/content_builder/lib/src/assert/a06_plate_licence.dart` — extended: a plate whose
  `source_work` is an official act of a `textsOnly` jurisdiction fails unless `origin: originated`.
- `content/shared/plates.yaml` — the originated Brazilian figures, each with a full ledger row.
- `tools/content_builder/test/assert/a06_brazil_annex_test.dart`,
  `test/content/br_corpus_test.dart`.

## Why it is built this way

**The Brazilian carve-out stops at the words, and the pipeline has to know that.**
`SPEC.md` §8 and `licence-provenance.md` agree and both flag it: Lei 9.610/1998 art. 8 IV excludes
*"os textos"* of laws, decrees, regulations, judicial decisions and official acts — unlike Spain's
Art. 13, which excludes the *disposición* as a whole. A species-identification drawing or a
measurement diagram printed as an annex to a portaria is therefore **not** cleared. Every such figure
we ship for a Brazilian rule is originated in-house and recorded in `plates.yaml` with
`origin: originated`.

Encoding it as prose in the authoring guide is not enough, because the mistake is invisible in review:
a traced annex diagram and an originated one look identical in a diff. So the scope becomes data —
`carveOut: textsOnly | wholeDisposicion` on the jurisdiction provenance entry, transcribed from
`licence-provenance.md`'s table — and A6 gains one rule: a plate whose `source_work` names an official
act of a `textsOnly` jurisdiction fails unless its `origin` is `originated`. Spain stays
`wholeDisposicion`, so T04's annex table is legal there and this rule does not fire on it.
**Rejected:** a global "no annex art anywhere" rule, which would throw away the Iberian annex diagrams
Art. 13 explicitly covers.

**A federal portaria is authored once, using T03's machinery.** IBAMA and MPA portarias bind states
that also legislate; §7.1 forces a per-jurisdiction `rule` row and the resolver matches a jurisdiction
exactly. `applies_to` plus expansion is already built and tested (T03), and reusing it means a federal
piracema window is edited in one place. The alternative was live once in this repository and will not
live twice.

**Federal versus state is the contradiction class A8 exists for.** `build-assertions.md` names it:
*a national and a regional March closure with different dates*, resolved by authoring an explicit
`supersedes:` on one. Brazil is where this actually happens — a state instrução normativa narrower
than the federal portaria, both in force, neither obviously outranking the other. The rule is
`catchlaw-rule-engine` rule 6: a tie that disagrees is **returned**, not broken. Where the
instruments genuinely disagree and neither supersedes, the corpus keeps both and the app shows D4's
ambiguity with two citations — which is more useful at an inspection than a confident single answer
that no instrument supports. What the author must not do is delete the inconvenient row to make A8
green.

**`water_type` is load-bearing here in a way it is not elsewhere.** Brazil has both, and §4.4 promises
*freshwater zones never show marine rules*. A rule authored `water_type: both` because the portaria
did not say is a river minimum applied to a coastal catch, and it passes every assertion. The corpus
test asserts no Brazilian rule uses `both` unless the instrument itself covers both waters, and
`jurisdiction.has_freshwater = 1` for the freshwater states. The dam exclusion radii §4.4 names are
`zone_kind: 'exclusion'`, specificity 40 — the top of the ladder — and their polygons are T09's
problem, not this task's.

**Piracema wraps the year, and the wrap is declared.** `build-assertions.md` records the edge:
*a closure authored `04-30` to `03-01` — a year-wrapping closure is legal but must set
`wraps_year: true` explicitly*, and E04/T02 landed the assertion. A piracema window running from
one November into the following February is exactly that shape. Inferring the wrap from
`end < start` would also silently "fix" a transposed pair, which is the other thing that shape means.

**`pt_BR` carries gender, and the dates are never ISO on screen.** §9.5: `pt_BR` is one of the five
gendered locales, and season windows read "1 de março – 30 de abril" through `intl`, never
`2026-03-01`. The content stores `MM-DD` per §7.1's `closed_season` columns; the formatting is
E06's. What this task must not do is author a pre-formatted date string into `content_string`,
because that string cannot be re-formatted for another locale and will render in Portuguese inside an
Arabic screen.

## Tests first

Write every row before authoring YAML or extending A6. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `PlateLicenceAssertion reports A6 when a plate is sourced from a texts-only jurisdiction's official act` | `source_work: Portaria IBAMA …`, `origin: public_domain` | one `A6` naming art. 8 IV | The operative Brazil edge, made un-shippable rather than documented |
| 2 | `PlateLicenceAssertion accepts an originated figure for a texts-only jurisdiction` | same `source_work`, `origin: originated` | no failures | `licence-provenance.md`'s worked row: the clam diagram is bundled as originated |
| 3 | `PlateLicenceAssertion accepts an annex figure from a whole-disposición jurisdiction` | `source_work: Orde da Xunta …`, `origin: public_domain` | no failures | Art. 13 covers annexes; a global ban would throw away Iberian diagrams |
| 4 | `CarveOutScope is textsOnly for every Brazilian jurisdiction` | the provenance table | `textsOnly` | Transcribed from `licence-provenance.md`, pinned so a new state cannot default to the Spanish scope |
| 5 | `PlateLicenceAssertion reports A6 when an originated Brazilian figure has no licence id` | `origin: originated`, no `licence` | one `A6` | The work-for-hire agreement id is the ledger row S17 renders |
| 6 | `BR corpus authors every federal portaria once with applies_to` | `content/br/rules.yaml` | every federal row carries `applies_to` | T03's machinery reused; a pasted per-state copy is the row that gets amended in one place only |
| 7 | `BR-SP corpus resolves a federal rule expanded from content/br` | expanded rows | present with `authored_from` | The expansion is what makes case 6 shippable |
| 8 | `BR corpus declares wraps_year on every closure whose end precedes its start` | piracema rows | `wraps_year: true` | `build-assertions.md`'s recorded edge; inferring it would silently "fix" a transposed pair |
| 9 | `BR corpus rejects a closure with a 02-29 boundary` | `season_end: 02-29` | one `A1` | The leap-day boundary `build-assertions.md` rejects — author `02-28` or `03-01` |
| 10 | `$juris corpus sets has_freshwater when it carries a fresh rule` (loop over BR, BR-SP, BR-MG) | `jurisdiction.yaml` | `1` where fresh rules exist | §4.4: freshwater zones never show marine rules, and the flag is what S9 reads |
| 11 | `$juris corpus authors water_type both only where the instrument covers both` (loop over the three) | `rules.yaml` | every `both` row cites an instrument covering both | A `both` authored out of doubt applies a river minimum to a coastal catch and passes every other assertion |
| 12 | `$juris corpus carries a gender on every pt_BR species_name` (loop over the three) | `vernacular.yaml` | no `A3` | §9.5; `pt_BR` is the locale D-3 had to correct the filename of |
| 13 | `$juris corpus carries a measurement_method on every size rule` (loop over the three) | `rules.yaml` | no `A1` | A1's recorded cause, and Brazilian minima are published in several methods |
| 14 | `$juris corpus cites only in.gov.br or the state gazette host` (loop over the three) | `citations.yaml` | no `A9` | `licence-provenance.md` rejects NGO fact sheets and blog transcriptions by name |
| 15 | `$juris corpus quotes the art. 8 IV provision` (loop over the three) | provenance entry | `provision` non-empty, `verified: true` | §8 marks Brazil ✅ verified on planalto.gov.br; the quote is the evidence, per T03's shape |
| 16 | `BR corpus keys no content_string to a legal_text id` | `strings.yaml` | no match | `check_content_pipeline.sh` check 6 |
| 17 | `BR corpus stores no pre-formatted date in content_string` | `strings.yaml` | no value matching a date pattern | §9.5: a formatted date cannot be re-formatted, and would render in Portuguese inside an Arabic screen |
| 18 | `BR corpus keeps both rules when a federal and a state closure disagree` | overlapping closures, no `supersedes` | A8 fires; neither row is deleted | Rule 6 — a disagreeing tie is returned. Deleting a row to make A8 green invents a verdict |
| 19 | `BR corpus resolves an explicit supersedes without ambiguity` | state row with `supersedes:` | resolves to one rule | The authored resolution `build-assertions.md` prescribes |
| 20 | `$juris corpus carries between 100 and 150 rule rows` (loop over BR-SP, BR-MG) | authored rows | in range | §8's per-jurisdiction volume |
| 21 | `BR corpus ships every legal_text row in pt_BR` | `legal_text.yaml` | every `locale: pt_BR` | §9.6, and D-3's filename correction: never `pt` |

```dart
// tools/content_builder/test/assert/a06_brazil_annex_test.dart
import 'package:content_builder/src/assert/a06_plate_licence.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('PlateLicenceAssertion', () {
    test('reports A6 when a plate is sourced from a texts-only jurisdiction official act', () {
      final source = contentSourceWithPlate(
        sourceWork: 'Portaria IBAMA nº 000, anexo II',
        jurisdiction: 'BR',
        origin: 'public_domain',
      );
      final failures = const PlateLicenceAssertion(buildYear: 2026).run(source).toList();

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A6');
      expect(failures.single.message, contains('art. 8 IV'));
    });

    test('accepts an annex figure from a whole-disposición jurisdiction', () {
      final source = contentSourceWithPlate(
        sourceWork: 'Orde da Xunta de Galicia, anexo I',
        jurisdiction: 'ES-GA',
        origin: 'public_domain',
      );

      expect(const PlateLicenceAssertion(buildYear: 2026).run(source), isEmpty);
    });

    // … one test per row above, one behaviour each
  });
}
```

```dart
// tools/content_builder/test/content/br_corpus_test.dart
import 'package:content_builder/src/load/content_source.dart';
import 'package:test/test.dart';

void main() {
  late ContentSource corpus;

  setUpAll(() async {
    corpus = await ContentSource.load(Directory('../../content'));
  });

  test('BR corpus declares wraps_year on every closure whose end precedes its start', () {
    final wrapping = corpus.closedSeasonsFor('BR').where((s) => s.endsBeforeItStarts);

    expect(wrapping, isNotEmpty);
    expect(wrapping.map((s) => s.wrapsYear), everyElement(isTrue));
  });

  for (final juris in const ['BR', 'BR-SP', 'BR-MG']) {
    test('$juris corpus authors water_type both only where the instrument covers both', () {
      for (final rule in corpus.rulesFor(juris).where((r) => r.waterType == 'both')) {
        expect(corpus.citation(rule.citationId).coversBothWaters, isTrue,
            reason: '${rule.id} claims both waters; ${rule.citationId} does not');
      }
    });
  }

  // … one test per row above, one behaviour each
}
```

**Run:** `(cd tools/content_builder && dart test test/assert/a06_brazil_annex_test.dart
test/content/br_corpus_test.dart)` → 21 failures. Case 3 is the one that must be red for the right
reason: it fails today because the fixture's jurisdiction has no `carveOut` at all, not because Spain
is being rejected — check the fixture before writing the rule, or the implementation will be built to
pass a mis-read failure.

## Implementation outline

1. Add `CarveOutScope` to the jurisdiction provenance type; transcribe the scope for every
   jurisdiction already in the table from `licence-provenance.md`'s carve-out table. A jurisdiction
   with no scope fails — silence is not permission, the same rule E04/T05 applied to the host
   allowlist.
2. Extend `PlateLicenceAssertion` with the one rule, keyed off the plate's `source_work` naming an
   official act of a `textsOnly` jurisdiction. Message quotes `art. 8 IV` so the author can find the
   reason without leaving the terminal.
3. Add the Brazilian entries to `accepted_hosts.dart`: `in.gov.br` and each state's gazette host, the
   art. 8 IV provision quoted once, `verified: true` supported by §8's planalto.gov.br verification.
4. **Then author the content**: federal portarias in `content/br/` with `applies_to`; São Paulo and
   Minas Gerais in their own directories; rule rows with measurement methods and water types;
   piracema closures with `wraps_year` declared; verbatim articles in `pt_BR`; keys and their six
   translations; `changes.yaml`.
5. Commission and record the originated figures for any Brazilian rule that needs one, each with the
   five `PlateProvenance` fields (`lonja-icons-and-plates` rule 8) and the `9999` death-year sentinel
   for commissioned work.
6. Where a federal and a state instrument genuinely disagree, author `supersedes:` only if one
   instrument actually says so. Otherwise leave both and let D4's ambiguity render — and record the
   pair in `content/AUTHORING.md`'s worked examples, because the next author will want to delete one.
7. Record `rules` and `legal_text` sign-offs for `pt_BR` in `content/reviewers.yaml` (T01's A11).

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 21 rows pass, and each failed first.
- [ ] 100 % branch coverage on the A6 extension, including the `wholeDisposicion` path that must not
      fire.
- [ ] No plate or figure used by Brazilian content is sourced from a portaria annex; every one is
      `origin: originated` with a complete ledger row.
- [ ] Every Brazilian jurisdiction entry carries `carveOut: textsOnly`, the quoted art. 8 IV
      provision, its gazette host and `verified: true`.
- [ ] Every year-wrapping closure declares `wraps_year: true`; no closure has a `02-29` boundary.
- [ ] No `water_type: both` row exists whose instrument does not cover both waters.
- [ ] Every `pt_BR` `species_name` carries a non-NULL `gender`; every `legal_text` row is `pt_BR`.
- [ ] `content/CHANGELOG/br.md`, `br-sp.md` and `br-mg.md` are current under `--check`.
- [ ] Any federal/state disagreement that survives is present as **both** rows, and is written up in
      `content/AUTHORING.md` as a worked example of why neither is deleted.
- [ ] `content/reviewers.yaml` carries `rules` and `legal_text` sign-offs for `pt_BR`.

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
feat(content): author the Brazilian federal and state rules, with every graphic annex originated

SPEC.md §8 flags the operative difference: Lei 9.610/1998 art. 8 IV excludes
"os textos" of official acts, not the act as a whole, so a species drawing or a
measurement diagram printed as a portaria annex is not cleared. Spain's Art. 13
does cover annexes. Both jurisdictions live in one corpus and the mistake is
applying whichever rule was learned first — and a traced annex diagram looks
identical to an originated one in a diff.

So the scope is data. Each jurisdiction carries carveOut: textsOnly or
wholeDisposicion, transcribed from licence-provenance.md, and A6 gains one
rule: a plate whose source_work is an official act of a texts-only
jurisdiction fails unless origin: originated. A global ban on annex art was
rejected — it would throw away the Iberian diagrams Art. 13 explicitly covers.

Federal portarias are authored once with applies_to and expanded per state,
reusing T03's machinery. Where a federal portaria and a state instrução
normativa genuinely disagree, both rows stay and D4's ambiguity renders two
citations: a tie that disagrees is returned, not broken, and deleting the
inconvenient row to make A8 green invents a verdict no instrument supports.

water_type is load-bearing here in a way it is not elsewhere. §4.4 promises
freshwater zones never show marine rules, and a row authored `both` out of
doubt applies a river minimum to a coastal catch while passing every other
assertion. Piracema closures that run from one November into the next February
declare wraps_year explicitly, because inferring the wrap would also silently
"fix" a transposed pair.

Task: E22/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
