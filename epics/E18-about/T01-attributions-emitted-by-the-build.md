# E18/T01 — `ATTRIBUTIONS.md`, emitted by the build

| | |
|---|---|
| **Epic** | E18 — About and attributions |
| **Branch** | `epic/18-about` (shared) |
| **Commit** | `feat(content_builder): emit ATTRIBUTIONS.md from the authored content` |
| **Depends on** | E04 (the builder, `content/plates.yaml`, `content/citations.yaml`, the CoL extract) |
| **Size** | M |
| **Spec** | `SPEC.md` §8 (every licence row, the public-domain test for plates, the pipeline's assertion list), §9.2 point 2 (CoL as the sole English source; ASFIS refused), §6 S17 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Owns the builder. Rule 2 (every assertion is fatal, no warning tier), rules 7 and 8 (the death-year test and the DROP rule), and the `load → assert → emit → changelog` shape this emitter plugs into |
| `catchlaw-conventions-index` | D-7's boundary in the other direction: the engine holds no sentence, and this file is nothing but sentences — it belongs to the builder, not to `packages/rule_engine/` |
| `dependency-hygiene` | The emitter must add no dependency to `tools/content_builder`; rule 6 says audit the tree, not the pubspec, and a Markdown or template package here would be a few hundred lines of first-party Dart bought at a permanent cost |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, the bundled-data table | One emitted section per row: the source, the licence, the verification status **as written**, and how it gets in |
| `SPEC.md` | §8, "The public-domain test for plates — corrected" | The death-year test, the 80-years-pma reason, and the rule that an unattributable plate is dropped |
| `SPEC.md` | §9.2 point 2 | Why English vernacular names come solely from the CoL extension, and the FAO ASFIS refusal with its non-commercial reason |
| `.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` | "Legal text: the statutory carve-outs", "Plates: the illustrator death-year test", "`plates.yaml` required fields", "Taxonomy: the Catalogue of Life extract" | The per-jurisdiction statute table, the term ladder, the exact field list a plate row must carry, and the `credit.col` attribution requirement |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | "The build assertions", "Failure format" | The assertion id / file:line / message shape this task's new assertion must match, and the "no partial emit" rule |
| `epics/DECISIONS.md` | D-4, D-3, D-1 | `tools/content_builder/`, package `content_builder`, executable `dart run content_builder:build`; six locales `ar en es gl ca pt_BR`; the workspace layout |
| `FLUTTER_GUIDE.md` | §7.4 | Generated files are checked **into** git — which is what makes the drift guard a reviewable diff rather than an invisible rebuild |
| `FLUTTER_GUIDE.md` | §3.4 | Doc comments on the emitter's public API: noun phrase for the document type, third-person verb for the emit function |

## What this delivers

- `tools/content_builder/lib/src/emit/attributions.dart` — `AttributionsDocument`, an immutable value
  assembled from `ContentSource`, and `String renderAttributions(ContentSource source, {required int buildYear})`.
- `tools/content_builder/lib/src/assert/a11_attributions_current.dart` — assertion **A11**: the
  rendered string must equal the bytes of `app/assets/legal/ATTRIBUTIONS.md` on disk, or the build
  fails with `A11 app/assets/legal/ATTRIBUTIONS.md is stale — re-run content_builder and commit it`.
- `tools/content_builder/bin/content_builder.dart` — A11 added to `runAllAssertions`; the emit step
  writes the file beside `emitChangelogs`.
- `app/assets/legal/ATTRIBUTIONS.md` — the emitted artefact, **committed**.
- `app/pubspec.yaml` — `assets/legal/` declared so `rootBundle` can read it (T02 consumes it).
- `tools/content_builder/test/emit/attributions_test.dart` — the ten tests below.
- No change to `packages/rule_engine/`. No new dependency in any pubspec.

## Why it is built this way

**Generated, because a hand-maintained file is false within one content release.** `SPEC.md` §8 makes
the plate ledger a licence control, not a courtesy: *"Every plate's illustrator and death year is
recorded in `ATTRIBUTIONS.md` and rendered in S17. Any plate whose artist cannot be identified is
dropped."* E22 adds jurisdictions in parallel from E04 onward and each one may add plates. A file a
human maintains is correct on the day it is written and wrong on the day the next plate lands — and
the wrongness is exactly a bundled image with no attribution, which is the infringement
`licence-provenance.md`'s drop rules exist to prevent. Generating it means the file cannot be stale,
because A11 refuses to emit a database whose companion attributions file has not been regenerated.

**A11 is a byte-compare against a committed file, not a "write it out and move on".** If the build
simply overwrote the file, a content change would silently rewrite it during someone else's unrelated
build and land in an unrelated diff. Comparing against the committed bytes makes the regeneration a
deliberate, reviewable line in the same commit as the content change — the same argument
`FLUTTER_GUIDE.md` §7.4 makes for checking generated Dart into git. It also matches the shape of A10,
which already fails when a jurisdiction's rows changed and its changelog did not.

**Rejected: storing the attributions text in `content_string`.** `SPEC.md` §8 asserts every `*_key`
resolves in `content_string` for *every* shipped locale with no fallback, so a `credit.*` key would
force six translations of a licence statement. §9.6 and `licence-provenance.md` both refuse to
translate a quoted instrument — an unofficial rendering of a licence is a new derivative that no
longer says what the licence says. Markdown in an asset keeps the quoted text in one language, which
is the correct outcome, and pushes the localisation problem to the section headings, where it belongs.

**Rejected: a second copy at the repository root.** Two `ATTRIBUTIONS.md` files is the drift this task
exists to kill, reintroduced one directory up. The bundled asset is the single copy; anyone who wants
to read it from the repository reads `app/assets/legal/ATTRIBUTIONS.md`.

**Rejected: emitting it from the app at runtime.** The app has no access to `content/plates.yaml` —
only to `reference.db`, which carries no illustrator column and should not grow one for a document
nobody queries. And the plate ledger has to exist for plates that were *dropped*, which never reach
the database at all.

**Rejected: a Markdown or templating package.** The document's grammar is ours and is small: `##`/`###`
headings, paragraphs, `-` lists, and pipe tables. `dependency-hygiene`'s weigh-and-usually-refuse list
names "a few hundred lines of first-party Dart" and "exists only to save typing"; both apply. It also
keeps T02's renderer honest — T02 parses exactly the subset T01 emits, and nothing else.

**Every emitted collection is sorted by a stable id.** Map iteration order is an implementation
detail, and a churny generator makes A11 fire on unrelated PRs until somebody switches it off.

**FAO ASFIS gets a row saying it is *not* used.** `SPEC.md` §9.2 records that the first draft named
ASFIS without checking its terms, which permit non-commercial use only. A source that was considered
and refused is more informative than silence, and it is checkable: the emitter also fails if any
`content/vernacular.yaml` row names ASFIS as its source.

**The UAE status is carried verbatim.** `SPEC.md` §8 marks Federal Decree-Law 38/2021 Art. 3 *cited
but not independently verified in this session*. The emitter reproduces that status; it does not
paraphrase it into confidence, and there is no code path that can set it to verified. That flips only
when `content/citations.yaml` carries a gazette `source_url`, a `sha256` and a human `retrieved_on`.

## Tests first

Write every row before touching `attributions.dart`. Run them. **They must fail** — `renderAttributions`
does not exist, so every one is a compile error, which is the strongest possible red. If a test passes
after you have written only the function signature, it is asserting nothing; fix the test.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `renderAttributions emits one plate row for every entry in plates.yaml` | a source with 3 plate entries | 3 rows in the plates table | `SPEC.md` §8 requires *every* plate's illustrator on screen; a filtered emitter is a bundled image with no attribution |
| 2 | `renderAttributions names the illustrator and the death year on every plate row` | Bloch, d. 1799 | row contains `Marcus Elieser Bloch` and `1799` | The death year is the licence test's only evidence; a row without it cannot be checked by a reader |
| 3 | `renderAttributions attributes the Catalogue of Life for the scientific names and for the vernacular extension` | the CoL extract | both uses named under one CC BY 4.0 attribution | One dataset, two distinct uses (§8 rows 4 and 5). A single "taxonomy" line attributes only the first |
| 4 | `renderAttributions records FAO ASFIS as not used with the non-commercial reason` | any source | a row naming ASFIS, "not used", and the non-commercial term | §9.2: the first draft named ASFIS without checking. A refusal nobody can read is not a correction |
| 5 | `renderAttributions carries the UAE citation status as cited but not independently verified` | UAE citation rows | the §8 status text, unaltered | Upgrading an unverified citation to verified in a generated file launders the exact claim §8 flagged |
| 6 | `renderAttributions names Art. 13 LPI for the Spanish rows and Lei 9.610/1998 art. 8 IV for the Brazilian rows` | ES + BR jurisdictions | both statutes, on their own rows | One blanket "official texts are free" sentence is wrong: Brazil's carve-out is limited to *os textos* |
| 7 | `renderAttributions marks Brazilian measurement diagrams as originated` | a BR plate with `origin: originated` | row reads `originated`, not a statutory basis | art. 8 IV covers only *os textos*, so a graphic annex is not cleared and ours must say so |
| 8 | `renderAttributions sorts plate rows by plate id` | plates authored out of order | rows in id order | Map order is not a contract; an unsorted emitter makes A11 fire on unrelated PRs until it is disabled |
| 9 | `renderAttributions returns identical bytes for two runs over one source` | same `ContentSource` twice | `a == b` | A11 is a byte-compare; a generator that is not idempotent cannot be gated |
| 10 | `A11 fails the build when the committed file differs from the rendered document` | file on disk with one changed death year | one `A11` failure, no `.db` written | The drift guard itself. Rule 2: fatal, no warning tier, no partial emit |
| 11 | `renderAttributions names Noto Sans and Noto Naskh Arabic under SIL OFL 1.1` | the fonts row | both families and the licence name | §8's fonts row is a bundled asset like any other; T03 ships the licence text this row points at |

```dart
// tools/content_builder/test/emit/attributions_test.dart
import 'package:content_builder/src/assert/a11_attributions_current.dart';
import 'package:content_builder/src/emit/attributions.dart';
import 'package:test/test.dart';

import '../fixtures/content_source_fixture.dart'; // kSourceThreePlates, kSourceEsBrAe

void main() {
  group('renderAttributions', () {
    test('emits one plate row for every entry in plates.yaml', () {
      final doc = renderAttributions(kSourceThreePlates, buildYear: 2026);
      expect(plateRowsOf(doc), hasLength(3));
    });

    test('names the illustrator and the death year on every plate row', () {
      final doc = renderAttributions(kSourceThreePlates, buildYear: 2026);
      expect(doc, contains('Marcus Elieser Bloch'));
      expect(doc, contains('1799'));
    });

    test('records FAO ASFIS as not used with the non-commercial reason', () {
      final doc = renderAttributions(kSourceEsBrAe, buildYear: 2026);
      expect(doc, contains('FAO ASFIS'));
      expect(doc, contains('not used'));
      expect(doc, contains('non-commercial'));
    });

    test('carries the UAE citation status as cited but not independently verified', () {
      final doc = renderAttributions(kSourceEsBrAe, buildYear: 2026);
      expect(doc, contains('cited but not independently verified'));
    });

    test('returns identical bytes for two runs over one source', () {
      expect(
        renderAttributions(kSourceEsBrAe, buildYear: 2026),
        renderAttributions(kSourceEsBrAe, buildYear: 2026),
      );
    });

    // … one test per row above, one behaviour each
  });

  group('A11', () {
    test('fails the build when the committed file differs from the rendered document', () {
      final failures = assertAttributionsCurrent(
        rendered: renderAttributions(kSourceThreePlates, buildYear: 2026),
        committed: kCommittedWithOneChangedDeathYear,
      );
      expect(failures, hasLength(1));
      expect(failures.single.render(), startsWith('A11 '));
    });
  });
}
```

**Run:** `cd tools/content_builder && dart test test/emit/attributions_test.dart` → 11 failures
(compile errors first). If any passes now, the test is wrong.

## Implementation outline

1. Add `tools/content_builder/test/fixtures/content_source_fixture.dart` with `kSourceThreePlates`
   and `kSourceEsBrAe`. Fixture constants are `k`-prefixed (`CONVENTIONS.md` §6). The file must not
   end in `_test.dart`.
2. Write `AttributionsDocument` as an immutable value with one field per emitted section: header,
   legal texts, taxonomy, vernacular, originated art, plates, zone polygons, fonts, refused sources.
3. Write `renderAttributions`. It builds the document from `ContentSource`, then renders it. The
   closed Markdown subset: `##`/`###` headings, blank-line-separated paragraphs, `-` list items, and
   pipe tables with a header row. Nothing else — T02's parser handles exactly this and no more.
4. Header carries the three `content_meta` keys the schema already defines — `schema_version`,
   `build_date`, `generator_commit` (`SPEC.md` §7.1) — plus `buildYear`, so an old file can be audited
   against the year that produced it (`licence-provenance.md`).
5. Sort: plates by `id`, jurisdictions by `code`, refused sources by name. Every collection, always.
6. Add the ASFIS guard beside A11: any `content/vernacular.yaml` row whose `source` names ASFIS is a
   failure, in the A-id shape from `build-assertions.md` ("Failure format").
7. Add A11 to `runAllAssertions` **before** `emitReferenceDb`, so a stale file writes no `.db` at all
   (rule 2, "no partial emit").
8. Emit the file in the emit phase, beside `emitChangelogs`.
9. Declare `assets/legal/` in `app/pubspec.yaml`. Run `dart run content_builder:build` and commit the
   generated file in this commit.
10. Re-run the suite. All 11 green, and every E04 assertion test still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 11 tests pass, and each failed first.
- [ ] `dart run content_builder:build` twice in a row produces no diff.
- [ ] Editing one `illustrator_death_year` in `content/plates.yaml` and rebuilding fails with a single
      `A11` line and writes no `.db`. Verified by hand, then reverted.
- [ ] The plate table row count equals the entry count in `content/plates.yaml`.
- [ ] The UAE status string is character-for-character `SPEC.md` §8's, and no code path can set it to
      verified.
- [ ] `tools/content_builder/pubspec.yaml` gained no dependency.
- [ ] `packages/rule_engine/` is untouched (D-7).
- [ ] `app/assets/legal/ATTRIBUTIONS.md` is committed and declared in `app/pubspec.yaml`.

## Gates

```bash
# from the repository root
cd tools/content_builder && dart format --set-exit-if-changed . && dart analyze && dart test
cd -
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder/lib
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
dart run content_builder:build --in content/ --out app/assets/db/reference.db
git diff --exit-code app/assets/legal/ATTRIBUTIONS.md
```

Both gate invocations pass an explicit target directory: the scripts exit 2 on a missing directory, and
a bare default would abort the run at this repository root (D-1).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content_builder): emit ATTRIBUTIONS.md from the authored content

A hand-maintained attributions file is correct on the day it is written and
wrong the day the next plate lands, and the wrongness is a bundled image with
no attribution — the exact case SPEC.md §8's drop rule exists to prevent. The
builder now renders the file from plates.yaml, citations.yaml and the CoL
extract, and assertion A11 fails the build when the committed copy is stale,
so regenerating it is a reviewable line in the same commit as the content
change rather than an invisible rebuild.

The UAE citation keeps §8's "cited but not independently verified" status
verbatim; no code path can raise it. FAO ASFIS gets a row saying it is not
used, with the non-commercial reason, because a refusal nobody can read is not
a correction.

Task: E18/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
