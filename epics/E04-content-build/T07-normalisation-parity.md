# E04/T07 — Normalisation comes from the engine, never a copy

| | |
|---|---|
| **Epic** | E04 — Content builder and the Galicia seed |
| **Branch** | `epic/04-content-build` (shared) |
| **Commit** | `feat(content_builder): populate search_norm and body_norm from the engine's normaliser` |
| **Depends on** | T01 (the loader), E02 (the normaliser and its exported article step) |
| **Size** | M |
| **Spec** | `SPEC.md` §8 bullet 7, §9.4 (the ordered fold and step 5), §7.1 `species_name.search_norm` and `legal_text.body_norm`, §13 (search latency) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rules 10 and 11 — normalisation exists in exactly one function, and the definite article is stripped **and** kept, both forms indexed. `references/normalisation-contract.md` is the contract this task consumes rather than restates |
| `catchlaw-content-pipeline` | Rule 9 and A7 — the parity pass recomputes every persisted `*_norm` column out of the emitted database and compares byte-for-byte |
| `catchlaw-conventions-index` | Rule 6, the one-way layer map: the builder imports the engine; the engine learns nothing about the builder |
| `project-structure-and-packages` | Why the workspace makes this a compile-time guarantee — one lock file, one resolved version of `rule_engine` for the app and the CLI |
| `testing-strategy` | The `ar - ` prefix on every Arabic case, per `CONVENTIONS.md` §5 |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, bullet 7 | "populate `search_norm` and `body_norm` with the same normalisation function the app uses, imported from the shared package — **not reimplemented**" |
| `SPEC.md` | §9.4 | The six ordered Arabic steps and the Latin fold; step 5 in particular — strip a leading `ال` **and index both forms** |
| `SPEC.md` | §7.1 | `species_name.search_norm TEXT NOT NULL`, `idx_name_search`, `legal_text.body_norm TEXT NOT NULL` |
| `SPEC.md` | §13 | `< 50 ms at 400 species / 2,400 names` — the indexed prefix query these columns exist to serve |
| `.claude/skills/catchlaw-rule-engine/references/normalisation-contract.md` | "The pipeline, in order", "The definite article: strip AND keep", "Failure modes this contract prevents" | The ten ordered steps, the two-key table, and the three-character guard on article stripping |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rules 10, 11; "The normalisation contract, in one place" | `normaliseSpeciesTerm` and its home, `lib/src/search/normalise.dart` |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | A7 row, "A7 — normalisation parity" | The column/source pairs and what a divergent normaliser looks like in practice |
| `.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh` | check 4 and `SHARED_RE` | Why a green gate is **not** the proof here |
| `epics/TEMPLATE.md` | Part B, E02/T04's definition of done | "The identical function is what `tools/content_builder/` calls — not a copy (E04/T07 depends on it)" |
| `epics/DECISIONS.md` | D-1, D-7 | The workspace has no `packages/shared`; the engine holds no user-visible sentence, and a search key is not one |

## What this delivers

- `tools/content_builder/lib/src/normalise/norm_columns.dart` — the population step, importing
  `normaliseSpeciesTerm` and the engine's article-stripping step from
  `package:rule_engine/rule_engine.dart` and declaring **no** string transform of its own.
- `tools/content_builder/lib/src/assert/a07_norm_parity.dart` — `NormParityAssertion`, run against
  the **emitted** database after `emitReferenceDb` (T10 wires the second phase).
- `tools/content_builder/test/normalise/norm_columns_test.dart`,
  `test/assert/a07_norm_parity_test.dart`, `test/normalise/no_second_normaliser_test.dart`.

## Why it is built this way

**"The shared package" is `packages/rule_engine/`, and three documents call it three things.**
`SPEC.md` §8 says "the shared package"; `catchlaw-content-pipeline` rule 9 says
`package:catchlaw_shared/text/normalise.dart`; `check_content_pipeline.sh` exempts
`packages/shared/`. D-1's workspace has four members and none of them is a `shared` package. The
normaliser lives in `packages/rule_engine/lib/src/search/normalise.dart`, put there by E02 and named
by `catchlaw-rule-engine` rule 10, and it is exported through the package's one barrel,
`packages/rule_engine/lib/rule_engine.dart` (`FLUTTER_GUIDE.md` §2.6 permits exactly that one
barrel). The builder imports `package:rule_engine/rule_engine.dart`. Because that path is outside the
gate's `SHARED_RE`, **gate check 4 is not what proves this task** — a green gate here means the grep
found nothing it recognises, not that no second normaliser exists. A7 and case 12 below are the proof.

**A second implementation is the defect this task prevents, and it is silent.**
`normalisation-contract.md` §"Failure modes" names it: *Results appear then vanish after a content
rebuild — a second normalise copy in the CLI drifted.* The builder writes the index; the app writes
the query. One extra folded diacritic in one of them and `كنعد` typed at 05:40 with wet hands matches
zero rows, and the app reports "no such species" rather than failing loudly. There is no user-visible
error state for this. That is why the guard is three-layered: import rather than declare; A7
recomputes every persisted column from the emitted bytes; and a test greps the builder's own source
for a declaration.

**A7 runs against the emitted database, not against the in-memory rows.** The
`content_build_assertions.dart` example runs it after `emitReferenceDb` and deletes the file if it
fails, because *an unindexed database is worse than none*. Recomputing from the in-memory model would
prove the model consistent with itself and say nothing about what SQLite stored — a truncated column,
a `TEXT` affinity surprise or an emit-order bug would all pass.

**The article's second key is a second `species_name` row, and `SPEC.md` §7.1 leaves no other
option.** §9.4 step 5 requires both the stripped and unstripped forms to be indexed;
`normalisation-contract.md` gives the two-key table and the reason (*the fisher types `الهامور`, the
index holds `هامور`, and the search returns nothing at 05:40 with the fish still moving*). §7.1's
`species_name` has one `search_norm` column and there is no `species_alias` table — and §7.1 is
authoritative for the schema. So for a name whose normalised form starts with `ال` and whose remainder
is at least three characters (`normalisation-contract.md`: *do not strip `ال` when the remainder is
under three characters — that is a real word, not an article*), the builder emits a **second**
`species_name` row with the same `species_id`, `locale`, `name`, `gender` and `region_hint`,
`is_primary = 0`, and the stripped key in `search_norm`. If the stripped key already exists for that
species and locale, no row is emitted.

**Rejected:** adding a `species_alias` table, which contradicts §7.1 and puts the builder out of step
with the drift schema E05 generates from it. **Rejected:** expanding the query instead of the index —
it would work for prefix search, but §9.4 step 5 says *index both*, and a query-side rule is invisible
to the FTS path and to E08's `search_norm` prefix query alike.

**The consequence lands on E08 and is recorded here, not discovered there.** A species with an Arabic
name carrying the article now has two `species_name` rows with the same display `name`. Any list of
names for a species must therefore select `DISTINCT name` or filter on `is_primary`. It is in this
task's definition of done so that E08 inherits it.

**Latin normalisation is not an afterthought for a Galician seed.** `SPEC.md` §9.4's Latin fold —
NFD, strip combining marks, lowercase — is what makes `ameixa babosa` reachable from a mis-accented
paste, and Galician, Catalan, Spanish and Portuguese all need it. The Galicia seed exercises the Latin
half of the same one function; the Arabic half is exercised by fixtures here and on real data in E20.

## Tests first

Write every row before touching `norm_columns.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `NormColumns.populate writes search_norm from normaliseSpeciesTerm` | `name: Ameixa babosa` | `ameixa babosa` | The base case, and it proves the imported function is the one being called |
| 2 | `ar - NormColumns.populate emits a second row for a name carrying the definite article` | `الهامور` | two rows: `search_norm` `الهامور` and `هامور` | §9.4 step 5 — index both forms |
| 3 | `ar - NormColumns.populate emits one row for a name with no definite article` | `هامور` | one row | No spurious duplicate for the common case |
| 4 | `ar - NormColumns.populate emits one row when the stripped key already exists` | `الهامور` and `هامور` on one species | three rows, not four | Deduplication; without it the species list grows a phantom entry per authored pair |
| 5 | `ar - NormColumns.populate does not strip ال when the remainder is under three characters` | a two-character remainder | one row | `normalisation-contract.md`'s guard — that is a real word, not an article |
| 6 | `NormColumns.populate marks the article-stripped row is_primary false` | `الهامور` marked primary | the extra row has `is_primary` 0 | Two primary rows would trip T04's A3 and make S5 print two names |
| 7 | `NormColumns.populate writes body_norm from the same function` | a Galician legal-text body | `normaliseSpeciesTerm(body)` | One function, two columns; the FTS index is built over this column |
| 8 | `NormParityAssertion reports A7 when a stored search_norm differs from the recomputed value` | a row hand-corrupted in the emitted DB | one `A7` naming the column and row id | The pass must actually read the database back, not the model |
| 9 | `NormParityAssertion accepts an article-stripped row` | the extra row from case 2 | no failures | Parity must know about the second key, or every Arabic name fails A7 |
| 10 | `NormParityAssertion reports A7 when a stored body_norm differs from the recomputed value` | corrupted `legal_text` row | one `A7` | Both columns, not just the famous one |
| 11 | `NormParityAssertion covers every *_norm column in §7.1` | the emitted schema | both columns visited, asserted by count | A column added later must not be silently unparited |
| 12 | `content_builder declares no normalisation function of its own` | the package's `lib/` | no declaration matching the normaliser names | The grep the gate cannot reliably do, run over our own source, in our own suite |
| 13 | `content_builder imports normaliseSpeciesTerm from package:rule_engine` | `norm_columns.dart` | the import present | Positive proof to go with case 12's negative |
| 14 | `ar - NormColumns.populate is idempotent over an already-normalised name` | a name equal to its own key | one row, unchanged | The fold is applied by the builder and by the app; drift between two applications is the failure mode |

```dart
// tools/content_builder/test/normalise/norm_columns_test.dart
import 'package:content_builder/src/normalise/norm_columns.dart';
import 'package:test/test.dart';

void main() {
  group('NormColumns', () {
    test('.populate writes search_norm from normaliseSpeciesTerm', () {
      final rows = NormColumns.populate([kNameRow(locale: 'gl', name: 'Ameixa babosa')]);

      expect(rows.single.searchNorm, 'ameixa babosa');
    });

    test('ar - .populate emits a second row for a name carrying the definite article', () {
      final rows = NormColumns.populate([kNameRow(locale: 'ar', name: 'الهامور')]);

      expect(rows.map((r) => r.searchNorm), ['الهامور', 'هامور']);
      expect(rows.last.isPrimary, isFalse);
    });

    test('ar - .populate does not strip ال when the remainder is under three characters', () {
      final rows = NormColumns.populate([kNameRow(locale: 'ar', name: 'الحد')]);

      expect(rows, hasLength(1));
    });
  });
}
```

```dart
// tools/content_builder/test/normalise/no_second_normaliser_test.dart
import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('content_builder declares no normalisation function of its own', () {
    final declaration = RegExp(
      r'\bString\s+(normalise|normalize|normaliseSpeciesTerm|foldArabic|stripDiacritics)\s*\(',
    );
    final offenders = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => declaration.hasMatch(f.readAsStringSync()))
        .map((f) => f.path);

    expect(offenders, isEmpty);
  });
}
```

**Run:** `(cd tools/content_builder && dart test test/normalise test/assert/a07_norm_parity_test.dart)`
→ every case red except possibly case 12, which passes trivially because `lib/` holds no normaliser
yet. That one is a **guard**, not a red-first case: note it in the commit body so nobody later reads
its green as evidence the TDD order was skipped.

## Implementation outline

1. Confirm the exported name. E02 owns it; `catchlaw-rule-engine` rule 10 says
   `normaliseSpeciesTerm(String)` in `lib/src/search/normalise.dart`, and the article step is exported
   alongside it. If E02 shipped a different identifier, use E02's — the requirement is that it is
   **imported** from `package:rule_engine/rule_engine.dart` and never redefined here.
2. `NormColumns.populate(List<SpeciesNameRow>) → List<SpeciesNameRow>`: one pass, appending the
   article-stripped row where the guard allows and deduplicating on
   `(speciesId, locale, searchNorm)`.
3. `legal_text.body_norm` populated by the same call, in the same file, so the two live together.
4. `NormParityAssertion.run(EmittedDb)`: for each `(normColumn, sourceColumn)` pair read every row's
   id, stored value and source value; a stored value matches when it equals the recomputed key **or**
   the article-stripped recomputed key; anything else is `A7`.
5. Wire A7 into the second failure phase in `run.dart` — after emit, and deleting the output file
   before exiting 1 (T10 owns the emit; this task owns the phase and the deletion).
6. Add the no-second-normaliser test, scoped to `lib/` so a test fixture naming the function does not
   trip it.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 14 rows pass; every one except case 12 failed first, and case 12 is labelled a guard in the
      commit body.
- [ ] 100 % branch coverage on `norm_columns.dart` and `a07_norm_parity.dart`.
- [ ] `tools/content_builder/lib/` contains no `replaceAll`, `toLowerCase` or `RegExp` applied to a
      name or body on its way into a `*_norm` column.
- [ ] A7 fails and the emitted file is **deleted** when a `*_norm` column is corrupted after emit.
- [ ] `packages/rule_engine/` is unchanged by this task except, if strictly required, an added
      `export` — no logic moves into the engine to make the builder's life easier, and D-7 still holds.
- [ ] **Recorded for E08:** a species may carry two `species_name` rows with the same display `name`
      and different `search_norm`. Any name list must `SELECT DISTINCT name` or filter on
      `is_primary`.
- [ ] `check_rule_engine.sh packages/rule_engine/lib` still clean, proving nothing was pushed down.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
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
feat(content_builder): populate search_norm and body_norm from the engine's normaliser

SPEC.md §8 bullet 7 says it in its own words: the same normalisation function
the app uses, imported from the shared package, not reimplemented. In D-1's
workspace that package is packages/rule_engine — the skills call it
catchlaw_shared and the gate exempts packages/shared, and neither exists here.

A second implementation is the defect this prevents, and it is silent. The
builder writes the index and the app writes the query; one extra folded
diacritic and كنعد typed with wet hands matches zero rows, and the app reports
"no such species" rather than failing. So the guard is three-layered: import
rather than declare, recompute every persisted *_norm column out of the
EMITTED database and compare byte-for-byte, and grep our own lib/ in our own
suite. Note that check 4 of check_content_pipeline.sh exempts only
packages/shared, so a green gate is not the proof here.

§9.4 step 5 requires both the stripped and unstripped forms of an Arabic name
to be indexed, and §7.1 has one search_norm column and no species_alias table.
The builder therefore emits a second species_name row carrying the same
display name with is_primary 0 and the stripped key. E08 must select DISTINCT
name or filter on is_primary; recorded in the task's definition of done rather
than left to be discovered.

The no-second-normaliser test is a guard and passed on first run because lib/
held no normaliser yet. Every other case failed first.

Task: E04/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
