# E08/T01 — The search query

| | |
|---|---|
| **Epic** | E08 — Species: search, browse and the static detail |
| **Branch** | `epic/08-species` (shared) |
| **Commit** | `feat(data): prefix-search species names over the indexed search_norm column` |
| **Depends on** | E02 (the §9.4 fold), E04 (`search_norm` populated), E05 (`ReferenceDatabase` open read-only) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.1 "Local-name search", §7.1 `species_name`, §9.4, §13 "Species search latency" |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-reference-database` | Owns the read-only open, the two-database split and the ATTACH ban — this query lives entirely inside `reference.db` and may not join across to `user.db` |
| `persistence-drift` | DAO-versus-repository split, value objects at the boundary, the `EXPLAIN QUERY PLAN` gate, `NativeDatabase.memory()` for logic tests |
| `catchlaw-conventions-index` | The one-way layer map: `packages/rule_engine/` → `app/lib/data/` → `app/lib/ui/`. This task is the middle layer and may not be reached from a widget |
| `state-management-riverpod` | The repository takes no `Ref` and imports no Riverpod; the provider that wires it is a plain `Provider` (DI), not `autoDispose` |
| `lonja-forms-and-controls` | Rule 7 and `references/search-field-and-keypad.md`: the visible text is the user's, the query string is the engine's. This task owns the query side of that split |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.1 "Local-name search" row | The acceptance condition: five inputs, one species id, ≤ 50 ms, "a unit test, not a manual check" |
| `SPEC.md` | §7.1, `species_name` and its two indexes | `search_norm`, `idx_name_search`, `idx_name_species`, and that `locale` is one of the six |
| `SPEC.md` | §9.4 whole | The ordered fold, and that the article `ال` is indexed both stripped and unstripped |
| `SPEC.md` | §13 "Species search latency" | `< 50 ms at 400 species / 2,400 names`, "indexed `search_norm`, prefix query, capped at 40 results" |
| `SPEC.md` | §8, "Authoring volume, stated plainly" | Where 400 species and 2,400 names come from |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "The ATTACH ban" | Why the zone join in T02 cannot be SQL |
| `Flutter-Skills: persistence-drift/references/schema-and-daos.md` | "DAOs vs repositories", "The index & query-plan strategy" | DAO holds the query, repository maps to value objects, `EXPLAIN QUERY PLAN` proved in a test |
| `.claude/skills/lonja-forms-and-controls/references/search-field-and-keypad.md` | "Worked examples the field must handle" | The six typed inputs this query must satisfy, including `Sha'ri` and `Epinephelus` |
| `FLUTTER_GUIDE.md` | §1.4, §2.5 | Drift belongs behind a Service; repositories live in `app/lib/data/repositories/`; drift rows never escape `data/` |
| `FLUTTER_GUIDE.md` | §6.1 | Test naming with receipts |
| `epics/DECISIONS.md` | D-1, D-6 | Paths; the reference DB is opened read-only |

## What this delivers

- `app/lib/domain/models/species_search_hit.dart` — an immutable value with a `const` constructor:
  `speciesId`, `scientificName`, `familyId`, `taxonGroup`, `silhouetteAsset`, `plateAsset` (nullable),
  `matchedName`, `matchedLocale`, `isPrimaryName`. Value equality, so `List` de-duplication and
  Riverpod's `==` filtering both behave (`FLUTTER_GUIDE.md` §5.3).
- `app/lib/data/repositories/species_search_repository.dart` — the abstract interface:
  `Future<Result<List<SpeciesSearchHit>>> search(String rawQuery, {required String locale})` and
  `Future<Result<int>> speciesCount()`.
- `app/lib/data/repositories/species_search_repository_drift.dart` — the implementation.
- `app/lib/data/services/dao/species_search_dao.dart` — a `@DriftAccessor` holding the two
  statements and nothing else.
- `app/lib/data/model/species_search_mapper.dart` — the only place a drift row becomes a
  `SpeciesSearchHit`.
- `app/lib/data/repositories/species_search_repository_provider.dart` — one plain `Provider`, no
  `autoDispose` (it wraps a process-lifetime database).
- `app/testing/fakes/fake_species_search_repository.dart` — a fake with a recorded call list.
- `app/testing/models/k_species.dart` — `kSpeciesHamour`, `kSpeciesShari`, `kSpeciesKanaad`,
  `kSpeciesAmeixa`, `kSpeciesAmeixaFina`.
- `app/testing/fixtures/species_corpus.dart` — builds a 400-species / 2,400-name in-memory corpus
  for the latency test.
- Tests: `app/test/data/repositories/species_search_repository_test.dart`,
  `app/test/data/repositories/species_search_query_plan_test.dart`,
  `app/test/data/repositories/species_search_latency_test.dart`.

No change to `packages/rule_engine/`. This task **calls** the E02 fold and does not extend it.

## Why it is built this way

**A range predicate, not `LIKE`.** The statement is

```sql
WHERE n.search_norm >= :q AND n.search_norm < :qUpper
```

where `:qUpper` is `:q` with its final code unit incremented. This is the one form SQLite can always
serve from `idx_name_search`. `LIKE 'q%'` *can* be optimised into the same range, but only when the
column collation is `BINARY`, `case_sensitive_like` is at its default, and the pattern's prefix is a
literal — three conditions a future `PRAGMA` or a `COLLATE NOCASE` on a rebuilt content DB can
silently remove, at which point the query degrades to a full scan and nothing fails. The range
cannot be defeated. `search_norm` is already lowercased and mark-stripped by §9.4, so nothing is
lost by comparing bytes.

**Rejected: FTS5.** `legal_text_fts` exists because §13 asks for full-text search over article
bodies in under 200 ms. A 2,400-row name table needs no inverted index, and §7.1's own comment on
`legal_text` records the decisive reason: *"FTS5 unicode61 does NOT fold Arabic orthographic
variants"*. That is exactly why `search_norm` exists. Reaching for FTS here would reintroduce the
bug the column was added to fix.

**Two statements, not one `GROUP BY`.** 2,400 names over 400 species means a species can match on
two names at once, and §13 caps the result at 40. A single `SELECT … GROUP BY n.species_id LIMIT 40`
would work, but SQLite's bare-column rule makes *which* name row survives the group
undefined unless the group carries exactly one `min()`/`max()` — so the name the user sees would be
arbitrary and could differ between two runs on the same data. Instead:

1. `SELECT DISTINCT n.species_id … ORDER BY length(n.search_norm), n.species_id LIMIT 40` —
   the index range narrows first, the sort runs over the matched rows only, and an exact match
   sorts above a longer name sharing the prefix. `species_id` is the tiebreak so the list never
   shuffles between identical queries.
2. `SELECT … FROM species_name n JOIN species s ON s.id = n.species_id WHERE n.species_id IN (…)`,
   served by `idx_name_species(species_id, locale)`, from which the mapper picks the display name:
   the active locale's `is_primary` row, else any active-locale row, else the `en` row, else the
   scientific name — §9.2's fallback chain, applied to names rather than to `content_string`.

Making that choice explicit in Dart is what makes it reviewable. It is also what lets T02 show
`هامور Hamour` in `ar` and `Hamour` in `en` from one query.

**A second arm over `species.scientific_name`.** §9.4's acceptance test requires `Epinephelus` to
resolve, and binomials live in `species`, not `species_name`. `scientific_name TEXT NOT NULL UNIQUE`
already carries `sqlite_autoindex_species_1`, a `BINARY` index. Binomials are always
capitalised-genus plus lowercase-species (ICZN), so the query capitalises the first letter of the
typed prefix and lowercases the rest before the range — one transform that makes `Epinephelus`,
`epinephelus` and `EPINEPHELUS` land on the same range. **Rejected:** adding a `sci_norm` column to
`reference.db`, because that schema belongs to E04 and changing it from a UI epic makes the shipped
asset and the builder disagree. **Also rejected:** a `LIKE '%q%'` scan of 400 rows, which meets the
target today but can use no index at all, so it must be re-measured every time §8's species count
moves.

**The empty query returns nothing.** An empty or whitespace-only query is not "match everything" —
400 rows is not a result set a fisher can read, and `search-field-and-keypad.md` is explicit that
the recents strip, not a dump, is what fills that state. The repository returns an empty list and
T02 renders the recents strip above the field.

**No cross-database join.** The zone grouping T02 needs (`in your zone` vs `elsewhere`) is a
`reference.db` question, but the *active* zone comes from `user.db`. `ATTACH` is banned by
`catchlaw-reference-database` rule 11 — a wholesale content swap would leave a live statement
pointing at an unlinked inode. The active zone therefore arrives as a plain Dart argument.

**Latency is guarded, not proved.** The test asserts the median of 100 queries over a
400-species / 2,400-name in-memory corpus is under 50 ms. A CI runner is not the Snapdragon 665
§13 names, so this is a regression guard. The device number is E21's §14 pass and is not claimed
here.

## Tests first

Write every row before touching `species_search_dao.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SpeciesSearchRepository.search returns the Hamour species id for hamour` | `'hamour'` | one hit, `kSpeciesHamour.id` | The §4.1 baseline: Latin transliteration typed with no diacritics |
| 2 | `SpeciesSearchRepository.search returns the Hamour species id for هامور` | `'هامور'` | same id | The Arabic half of the §9.4 acceptance test — the moat, per §16 R1 |
| 3 | `SpeciesSearchRepository.search returns the Hamour species id for هامورة` | `'هامورة'` | same id | §9.4 step 4: the terminal-form collapse must survive the round trip through SQL, not just the fold |
| 4 | `SpeciesSearchRepository.search returns the Hamour species id for الهامور` | `'الهامور'` | same id | §9.4 step 5: the instrument writes the article, the user does not; both forms are indexed |
| 5 | `SpeciesSearchRepository.search returns the Hamour species id for Epinephelus` | `'Epinephelus'` | same id | The fifth acceptance input, and the only one served by the `species` arm |
| 6 | `SpeciesSearchRepository.search matches a binomial typed in lower case` | `'epinephelus'` | same id | The capitalisation transform; a fisher does not type the genus capital |
| 7 | `SpeciesSearchRepository.search resolves five §9.4 inputs to one species id` | all five | `{kSpeciesHamour.id}` — a set of size 1 | The acceptance test as §4.1 states it: *one* id, asserted as a set so a second id fails loudly |
| 8 | `SpeciesSearchRepository.search matches a Galician name with a stripped diacritic` | `'ameixa'` | `kSpeciesAmeixa.id` | The Latin half of §9.4 — `gl`, `ca`, `es` and `pt_BR` all depend on NFD plus mark-strip |
| 9 | `SpeciesSearchRepository.search matches Sha'ri with the apostrophe typed` | `"Sha'ri"` | `kSpeciesShari.id` | `search-field-and-keypad.md` flags the apostrophe as a letter here, not punctuation |
| 10 | `SpeciesSearchRepository.search returns one hit for a species matching in two locales` | `'kanaad'` where `ar` and `en` rows both match | exactly one hit | The de-duplication the 40-result cap depends on; 2,400 names over 400 species guarantees this case |
| 11 | `SpeciesSearchRepository.search caps the result at 40 species` | a prefix matching 120 species | `length == 40` | §13's cap, stated as a number so nobody "improves" it to unbounded |
| 12 | `SpeciesSearchRepository.search orders an exact match above a longer prefix match` | `'ameixa'` with `Ameixa` and `Ameixa babosa` present | `Ameixa` first | Without an `ORDER BY` the `LIMIT 40` slice is arbitrary; this pins it |
| 13 | `SpeciesSearchRepository.search returns the same order for two identical queries` | `'a'` run twice | identical id lists | The `species_id` tiebreak; a list that reshuffles under a wet thumb is unusable |
| 14 | `SpeciesSearchRepository.search returns an empty list for an empty query` | `''` | `[]` | Not "match everything" — 400 rows is not a result, and the recents strip owns this state |
| 15 | `SpeciesSearchRepository.search returns an empty list for a whitespace query` | `'   '` | `[]` | The fold trims; a space typed by a gloved thumb must not dump the table |
| 16 | `SpeciesSearchRepository.search returns an empty list when nothing matches` | `'zzzz'` | `[]` | The empty state T03 renders needs a real empty result, not a thrown error |
| 17 | `SpeciesSearchHit carries the active-locale primary name when one exists` | locale `ar`, Hamour | `matchedName == 'هامور'`, `matchedLocale == 'ar'` | The display-name choice is a decision, not SQLite's bare-column rule |
| 18 | `SpeciesSearchHit falls back to en when the active locale has no name` | locale `ca`, a species with only `en` and `gl` | `matchedLocale == 'en'` | §9.2's fallback chain; a raw key or an empty row on a legal surface is the failure it prevents |
| 19 | `SpeciesSearchHit falls back to the scientific name when no vernacular name exists` | locale `ca`, a species with no `species_name` rows | `matchedName == scientificName` | The last link of the §9.2 chain — never blank |
| 20 | `SpeciesSearchDao.searchIds uses idx_name_search for the prefix range` | `EXPLAIN QUERY PLAN` | plan contains `idx_name_search` | §13's whole latency claim rests on the index; a plan that silently becomes a scan still passes every other test here |
| 21 | `SpeciesSearchDao.searchIds sorts the matched rows in a temp b-tree` | `EXPLAIN QUERY PLAN` | plan contains `USE TEMP B-TREE FOR ORDER BY` | Asserted deliberately so a later reader does not "fix" the sort by dropping the `ORDER BY` and losing test 12 |
| 22 | `SpeciesSearchRepository.search finds a name normalised by the content builder` | query against the committed Galicia fixture | one hit | Risk 8 in `epic.md`: every other test normalises its own fixture with the same function the query uses, so a builder/app divergence would be invisible |
| 23 | `SpeciesSearchRepository.search completes under 50 ms at 400 species and 2,400 names` | 100 queries, median | `< 50` ms | §13's number, as a regression guard on CI; the device figure is E21's |
| 24 | `SpeciesSearchRepository.search returns a failure when the reference database is unreadable` | a closed executor | `Result` failure, not a throw | The `error` state in `the-four-states.md` is a real branch and T03 must be able to render it |

```dart
// app/test/data/repositories/species_search_repository_test.dart
import 'package:catchlaw/data/repositories/species_search_repository.dart';
import 'package:catchlaw/data/repositories/species_search_repository_drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fixtures/species_corpus.dart';
import '../../../testing/models/k_species.dart';

void main() {
  late ReferenceDatabase db;
  late SpeciesSearchRepository repository;

  setUp(() async {
    db = ReferenceDatabase(NativeDatabase.memory()); // catchlaw-db-ok: in-memory test fixture
    await seedGaliciaAndGulfSample(db);
    repository = DriftSpeciesSearchRepository(db.speciesSearchDao);
  });
  tearDown(() => db.close());

  test('SpeciesSearchRepository.search returns the Hamour species id for هامور', () async {
    final hits = await repository.search('هامور', locale: 'ar');
    expect(hits.valueOrThrow.single.speciesId, kSpeciesHamour.id);
  });

  test('SpeciesSearchRepository.search resolves five §9.4 inputs to one species id', () async {
    const inputs = ['hamour', 'هامور', 'هامورة', 'الهامور', 'Epinephelus coioides'];
    final ids = <int>{};
    for (final input in inputs) {
      final hits = await repository.search(input, locale: 'ar');
      ids.addAll(hits.valueOrThrow.map((h) => h.speciesId));
    }
    expect(ids, {kSpeciesHamour.id});
  });

  test('SpeciesSearchRepository.search caps the result at 40 species', () async {
    await seedSpeciesSharingPrefix(db, prefix: 'zz', count: 120);
    final hits = await repository.search('zz', locale: 'en');
    expect(hits.valueOrThrow.length, 40);
  });

  test('SpeciesSearchRepository.search returns an empty list for an empty query', () async {
    expect((await repository.search('', locale: 'en')).valueOrThrow, isEmpty);
  });

  test('SpeciesSearchHit falls back to en when the active locale has no name', () async {
    final hits = await repository.search('ameixa', locale: 'ca');
    expect(hits.valueOrThrow.single.matchedLocale, 'en');
  });

  // … one test per row in the table above, one behaviour each
}
```

```dart
// app/test/data/repositories/species_search_query_plan_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fixtures/species_corpus.dart';

void main() {
  test('SpeciesSearchDao.searchIds uses idx_name_search for the prefix range', () async {
    final db = ReferenceDatabase(NativeDatabase.memory()); // catchlaw-db-ok: query-plan probe
    addTearDown(db.close);
    await seedGaliciaAndGulfSample(db);

    final plan = await db
        .customSelect(
          'EXPLAIN QUERY PLAN '
          'SELECT DISTINCT species_id FROM species_name '
          'WHERE search_norm >= ? AND search_norm < ? '
          'ORDER BY length(search_norm), species_id LIMIT 40',
          variables: [Variable.withString('ham'), Variable.withString('hin')],
        )
        .get();
    final detail = plan.map((r) => r.read<String>('detail')).join('\n');

    expect(detail, contains('idx_name_search'));
  });
}
```

```dart
// app/test/data/repositories/species_search_latency_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'SpeciesSearchRepository.search completes under 50 ms at 400 species and 2,400 names',
    () async {
      final repository = await buildCorpusRepository(species: 400, names: 2400);
      const queries = ['ham', 'ame', 'kan', 'sha', 'epi'];

      final samples = <int>[];
      for (var i = 0; i < 100; i++) {
        final sw = Stopwatch()..start();
        await repository.search(queries[i % queries.length], locale: 'ar');
        samples.add(sw.elapsedMicroseconds);
      }
      samples.sort();

      // SPEC §13: < 50 ms at 400 species / 2,400 names. A CI runner is not the
      // Snapdragon 665 the target names — this is a regression guard, and the
      // device figure comes from the §14 pass in E21.
      expect(samples[49] / 1000, lessThan(50));
    },
  );
}
```

**Run:** `cd app && flutter test test/data/repositories/` → 24 failures. If any passes now, the
test is wrong — most likely because the fixture builder is doing the normalisation the query is
supposed to do.

## Implementation outline

1. Write `SpeciesSearchHit` first, `const`, with value equality. Nothing else compiles without it.
2. Add `SpeciesSearchDao` as a `@DriftAccessor` on `ReferenceDatabase` with exactly two methods:
   `searchIds(String lower, String upper, String capLower, String capUpper)` and
   `hitsForIds(List<int> ids)`. No mapping, no fallback logic — the DAO returns rows.
3. Build the prefix bounds in one private function: normalise the raw query with the E02 fold, and
   return `null` when the result is empty. Increment the final code unit for the upper bound; if the
   final code unit is `0xFFFF`, append `\u0000` to the lower bound and use the unmodified string as
   the upper — the boundary a naive `+1` gets wrong.
4. Build the binomial bounds with the capitalise-first transform over the *raw* query, not the
   folded one — the fold lowercases, and `scientific_name` is stored as printed.
5. `DriftSpeciesSearchRepository.search` runs both arms, unions the ids preserving the vernacular
   arm's order, truncates to 40, then calls `hitsForIds`.
6. `species_search_mapper.dart` picks the display name in one function, in §9.2's order: active
   locale + `is_primary`, active locale, `en`, scientific name. One function, tested by rows 17–19.
7. Wrap the whole thing in the `Result` type from `FLUTTER_GUIDE.md` §1.6 so row 24 has something to
   assert. Every public repository method returns `Future<Result<T>>` (§2.5 rule 5).
8. Register `speciesSearchRepositoryProvider` as a plain `Provider` — the reference database is
   process-lifetime, so `autoDispose` would be wrong (`ownership-and-lifecycle.md`).
9. Re-run the suite. All 24 green, and E02's and E05's suites still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 24 tests pass, and each failed first.
- [ ] `EXPLAIN QUERY PLAN` names `idx_name_search`, asserted in a test rather than in a comment.
- [ ] The five §9.4 acceptance inputs resolve to a set of exactly one species id.
- [ ] The result is capped at **40 species** and the cap is a named constant, not a literal at the
      call site.
- [ ] No `drift` symbol — `Table`, `Companion`, a generated row class — appears outside
      `app/lib/data/` (`persistence-drift` rule 1).
- [ ] No `ATTACH` statement anywhere; the active zone enters as a Dart argument.
- [ ] `search()` calls the E02 fold, imported from `packages/rule_engine/` — not a copy
      (E02/T04's own definition of done requires the same function serves the content builder).
- [ ] The latency test's comment states plainly that CI is not the reference device and names E21.
- [ ] `packages/rule_engine/` is byte-unchanged by this commit.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh    app/lib
# from the Flutter-Skills plugin, per CONVENTIONS.md §4:
#   persistence-drift  scripts/check-drift-confinement.sh   app/lib
#   persistence-drift  scripts/check-persistence-bans.sh    app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(data): prefix-search species names over the indexed search_norm column

A range predicate on search_norm rather than LIKE 'q%': the LIKE optimisation
needs a BINARY collation, the default case_sensitive_like and a literal prefix,
and losing any of the three degrades silently to a full scan while every test
still passes. Two statements rather than one GROUP BY, because SQLite's
bare-column rule leaves the surviving name row undefined and the fisher would
see an arbitrary one of six locales. A second arm over species.scientific_name
with a capitalise-first transform makes Epinephelus — the fifth §9.4 acceptance
input — resolve through the existing UNIQUE index instead of a scan.

Task: E08/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
