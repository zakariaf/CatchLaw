# E05/T07 — The reference DAOs

| | |
|---|---|
| **Epic** | E05 — Data layer: two drift databases |
| **Branch** | `epic/05-data-layer` (shared) |
| **Commit** | `feat(data): add the reference DAOs and the legal-text FTS query surface` |
| **Depends on** | T01 (the tables and the read-only open) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.1 (the tables read here); §7.3 step 1 (do **not** filter on `valid_to`); §13 (search < 50 ms at 400 species / 2,400 names; FTS < 200 ms); §9.4 and §9.6 (why the FTS column is `body_norm`) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `persistence-drift` | Rules 1, 7 and 8: DAOs hold single-table queries, no drift symbol crosses the data boundary, reads are scoped. Plus the index and `EXPLAIN QUERY PLAN` strategy in `references/schema-and-daos.md` |
| `catchlaw-reference-database` | Rules 3 and 11: every query here runs on a read-only connection, and none of them may span the two files |
| `catchlaw-conventions-index` | Rule 6, the one-way layer map: these DAOs feed the engine plain values and never import from `ui/` |
| `testing-strategy` | Rule 4: the DAO tests open a **real built** `reference.db`, not a drift-created one — a mocked DAO proves nothing about SQL, indexes or the FTS tokenizer |
| `catchlaw-conventions-index` (routing) | Rule 9: rule *resolution* is `catchlaw-rule-engine`'s and E03's. This task returns rows; it decides nothing |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.1 | The tables, their indexes, and the `legal_text_fts` declaration with `content='legal_text'` and `content_rowid='id'` |
| `SPEC.md` | §7.3 step 1 | "**Do not filter on `valid_to`.**" The candidate query returns expired rows and tags nothing |
| `SPEC.md` | §7.3 opening paragraph | The candidate set: jurisdiction + species + water_type with `valid_from <= date`, zone `NULL`/equal/ancestor |
| `SPEC.md` | §13 | < 50 ms at 400 species / 2,400 names, prefix query on an indexed `search_norm`, **capped at 40 results**; FTS < 200 ms |
| `SPEC.md` | §9.4 | Why the search column is a normalised one: `هامور`, `هامورة`, `الهامور` and `hamour` must reach one species id |
| `SPEC.md` | §9.6 | Verbatim legal text is single-locale; `legal_text.locale` is what the availability notice reads |
| `$FLUTTER_SKILLS/persistence-drift/SKILL.md` | rules 1, 7, 8; "DAO + repository: one transaction, mapped to value objects" | The single-table DAO shape and the scoped `.watch()` rule |
| `$FLUTTER_SKILLS/persistence-drift/references/schema-and-daos.md` | "The index & query-plan strategy", "DAOs vs repositories" | Leading column is the equality filter, trailing the sort; prove it with `EXPLAIN QUERY PLAN` in a test |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "The ATTACH ban" | "The rule engine takes plain Dart values… No SQL spans both files" |
| `$FLUTTER_SKILLS/testing-strategy/references/test-layers.md` | "Data layer (Drift)" | Real engine, `addTearDown(db.close)`, and the edge list |
| `FLUTTER_GUIDE.md` | §2.5 | Rule 6 — drift row classes never escape `data/`; the DAOs live under `data/daos/` |
| `FLUTTER_GUIDE.md` | §5.3 | The `==` rebuild trap: relevant here because a `List` result is never `==` to the previous one |
| `epics/DECISIONS.md` | D-7 | `packages/rule_engine/` holds no user-visible sentence: these DAOs hand it numbers, enums and a `Citation`, never a rendered string |

## What this delivers

- `app/lib/data/daos/reference/species_dao.dart` — `searchByNormalisedPrefix(String prefix, {int limit
  = 40})`, `byId(int)`, `byFamily(int)`, `namesFor(int speciesId)`, `lookalikesFor(int speciesId)`.
- `app/lib/data/daos/reference/rule_dao.dart` — `candidatesFor({required int jurisdictionId, required
  int speciesId, required String waterType, required String onDate})` returning every matching row
  **including expired ones**, plus `closedSeasonsFor(Iterable<int> ruleIds)`.
- `app/lib/data/daos/reference/zone_dao.dart` — `byJurisdiction(int)`, `byCode(int, String)`,
  `bboxCandidates(double lat, double lon)`, `ringsFor(int zoneId)`.
- `app/lib/data/daos/reference/citation_dao.dart` — `byId(int)`, `byIds(Iterable<int>)`.
- `app/lib/data/daos/reference/content_string_dao.dart` — `resolve(Iterable<String> keys, String
  locale)` returning a `Map<String, String>` for the keys present in that locale.
- `app/lib/data/daos/reference/legal_text_dao.dart` — `search(String normalisedQuery, {int limit =
  50})` over `legal_text_fts`, `articlesFor(int jurisdictionId, String locale)`,
  `localesAvailable(int jurisdictionId)`.
- `app/lib/data/daos/reference/reference_meta_dao.dart` — `contentMeta()` for the About screen.
- `app/test/data/daos/` — one test file per DAO, all against the real built `reference.db`.
- `app/testing/fixtures/reference_fixture.dart` gains `seedSearchCorpus()` — 400 species and 2,400 names
  written into a scratch copy so the plan and cap assertions run at the size `SPEC.md` §13 specifies.

## Why it is built this way

**The rule query returns expired rows, and that is the correctness fix `SPEC.md` §7.3 exists to
record.** The first draft filtered on `date < valid_to`. On the day a Spanish annual *orden de vedas* or
a Brazilian piracema portaria expires, every rule sourced from it vanishes and every species falls
through to "no rule recorded" — and those annual instruments are precisely the rows that carry a
`valid_to`. `candidatesFor` therefore filters on `valid_from <= date` only. It does not tag, sort or
choose either: `is_expired`, the specificity ordering and the D4 ambiguity case are §7.3's algorithm and
belong to `packages/rule_engine/` (E03). A DAO that starts deciding is a second implementation of
resolution, and the two will disagree.

**Search is a prefix query on the indexed `search_norm` column, capped at 40.** §13 fixes the budget
(< 50 ms) and the shape (indexed `search_norm`, prefix query, 40 results) in one row. The normalisation
that fills the column is §9.4's ordered fold, run by the content builder through the **same** function
the app calls (E02, §8's pipeline requirement), which is why a prefix query works at all: `هامورة` folds
to `هامور`, so what the user types is a prefix of what is stored. The cap is in the DAO and not at the
call site, because an uncapped query at 2,400 names is a full scan that renders 2,400 rows nobody reads.

**The plan is asserted, the milliseconds are not.** A wall-clock assertion in `flutter test` on CI
hardware measures the CI runner, not the Snapdragon 665 §13 names. What is asserted here is the property
that makes the budget reachable: `EXPLAIN QUERY PLAN` shows `idx_name_search` in use and not a
`SCAN species_name`, at a seeded corpus of 400 species and 2,400 names. The device measurement is E21's
and is taken on hardware. Writing `expect(elapsed, lessThan(50))` here would be a green test that proves
nothing — `testing-strategy` rule 11's admitted gap is the honest form.

**FTS goes through `body_norm`, never `body`.** `SPEC.md` §7.1 says why in a comment on the table: fts5's
`unicode61` tokenizer does not fold Arabic orthographic variants, so an index over the verbatim `body`
would answer `هامور` and not `الهامور`. `body_norm` carries the same §9.4 fold as `search_norm`, so the
query string must be folded by the same function before it is handed to `MATCH` — an unfolded query
against a folded index is the defect that makes §14's "`هامور` and `الهامور` both hit" fail. The DAO
takes an already-normalised string and its parameter is named `normalisedQuery` so the obligation is
visible at every call site.

**`legal_text_fts` is declared in a `.drift` file and queried, never created.** It is an external-content
fts5 table over `legal_text`; drift cannot express fts5 as a `Table` subclass, and this database is never
created by drift anyway (T01). The `.drift` declaration exists so the query is typed and the column
names are checked at build time rather than at runtime in Arabic.

**These DAOs return drift row classes, and that is allowed.** `FLUTTER_GUIDE.md` §2.5 rule 6 bans a
drift row class from escaping `data/` — not from moving inside it. `persistence-drift` rule 1 asks DAOs
to map to value objects; here the mapping is one layer up, in `data/model/`, called by the repositories
of T09, because the mappers must serve both databases and because §7.3's engine input types are
assembled from several tables at once. The boundary the rules care about — nothing above `data/` sees a
row class — is enforced in T10 by a gate over `app/lib`. This is stated once, here, so nobody
re-derives it in the opposite direction.

**No `.watch()` on this database.** Content is immutable between extractions: a stream over a read-only
file that never changes emits once and then holds a subscription forever. Every reference read is a
`Future`. Streams belong to `user.db` (T08), where writes actually happen.

**Rejected: a single `ReferenceDao` with every query.** Six small `@DriftAccessor` classes scoped to the
tables they touch is what keeps `persistence-drift` rule 8 checkable — a DAO scoped to `[Species,
SpeciesName]` structurally cannot re-run a five-table join when a caller wanted a name.

**Rejected: joining `catch` to `species` to render the log.** That is an `ATTACH`, banned by
`catchlaw-reference-database` rule 11 and by check 5 of the gate. The catch row already carries
`scientific_name` as a literal (T04); the join is unnecessary as well as forbidden.

## Tests first

Write every row before touching a DAO. Run them. **They must fail.** Tests 1–4 and 12–15 run against the
real built `reference.db`; 5–8 run against a scratch copy seeded to the §13 corpus size.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `RuleDao.candidatesFor returns a rule whose valid_to is in the past` | rule expired yesterday | the row is present | §7.3's correctness fix. A DAO that filters here turns a defensible snapshot into "no rule recorded" |
| 2 | `RuleDao.candidatesFor excludes a rule whose valid_from is in the future` | `valid_from` tomorrow | absent | The one date filter §7.3 does specify |
| 3 | `RuleDao.candidatesFor returns rows for zone NULL, the zone itself and its ancestor` | three rules | all three | §7.3 step 2's candidate set. Filtering ancestors out in SQL is how a sub-zone loses its region's rules |
| 4 | `RuleDao.candidatesFor tags nothing and sorts nothing` | two rules of differing specificity | returned in insertion order, no `isExpired` field | Resolution is the engine's; a DAO that decides is a second implementation |
| 5 | `SpeciesDao.searchByNormalisedPrefix returns at most 40 rows` | corpus of 2,400 names, prefix matching 300 | 40 | §13's cap, in the DAO where it cannot be forgotten |
| 6 | `SpeciesDao.searchByNormalisedPrefix uses idx_name_search` | `EXPLAIN QUERY PLAN` at 2,400 names | plan names `idx_name_search`, no `SCAN species_name` | The property that makes < 50 ms reachable; the milliseconds are E21's, on hardware |
| 7 | `ar - SpeciesDao.searchByNormalisedPrefix reaches one species from هامور and الهامور` | both folded per §9.4 | same species id | §14's dynamic check, at the query layer where it is cheap to prove |
| 8 | `SpeciesDao.searchByNormalisedPrefix returns nothing for an empty prefix` | `''` | empty | The boundary a `LIKE ?||'%'` gets wrong first: every row matches |
| 9 | `ContentStringDao.resolve returns only the keys present in the requested locale` | 3 keys, 2 present in `gl` | 2 entries | The fallback chain is E06's; this DAO must not silently substitute another locale |
| 10 | `ContentStringDao.resolve reads content_string in one query` | 12 keys | 1 statement | Twelve round trips per screen is how the 1.2 s cold start goes |
| 11 | `ZoneDao.bboxCandidates returns only zones whose bounding box contains the point` | 3 zones, 1 containing | 1 | §13's polygon budget is a bbox prefilter then ray casting; the prefilter is here, the casting is E11's |
| 12 | `ZoneDao.ringsFor returns coords as bytes in ring_index order` | 2 rings | 2 rows, ordered, `coords` a `Uint8List` | Float64 unpacking is E11's; the DAO must not reinterpret the blob |
| 13 | `ar - LegalTextDao.search matches الهامور when the query is folded` | folded query | ≥ 1 row | §14: "`هامور` and `الهامور` both hit". This is that check at the SQL layer |
| 14 | `LegalTextDao.search matches nothing when the query is not folded` | raw `الهامور` against the folded index | empty | Names the trap in the suite: an unfolded query against a folded index looks like missing content |
| 15 | `LegalTextDao.localesAvailable returns the locales the jurisdiction publishes in` | `gl,es` jurisdiction | `['gl', 'es']` | §9.6's availability notice — the screen states which language the verbatim text exists in |
| 16 | `CitationDao.byIds returns every requested citation in one query` | 5 ids | 5 rows, 1 statement | Invariant 3: every result carries a citation, so this runs on every verdict |
| 17 | `every reference DAO query runs against a read-only connection` | attempt a write through each DAO's database | `SqliteException` | The T01 guarantee, re-asserted at the layer that will be tempted to cache |

```dart
// app/test/data/daos/species_dao_test.dart
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fixtures/reference_fixture.dart';

void main() {
  late ReferenceDatabase db;

  setUp(() async {
    db = await seedSearchCorpus(species: 400, names: 2400);
    addTearDown(db.close);
  });

  test('SpeciesDao.searchByNormalisedPrefix returns at most 40 rows', () async {
    final rows = await db.speciesDao.searchByNormalisedPrefix('sar');

    expect(rows, hasLength(40),
        reason: 'SPEC 13 caps the result set at 40; an uncapped query at 2,400 names is a full scan');
  });

  test('SpeciesDao.searchByNormalisedPrefix uses idx_name_search', () async {
    final plan = await db
        .customSelect(
          "EXPLAIN QUERY PLAN SELECT * FROM species_name "
          "WHERE search_norm LIKE 'sar' || '%' LIMIT 40",
        )
        .get();
    final detail = plan.map((r) => r.data['detail'] as String).join(' | ');

    expect(detail, contains('idx_name_search'));
    expect(detail, isNot(contains('SCAN species_name')),
        reason: '< 50 ms at 2,400 names is an index, not a hope');
  });

  test('ar - SpeciesDao.searchByNormalisedPrefix reaches one species from هامور and الهامور', () async {
    final bare = await db.speciesDao.searchByNormalisedPrefix(normaliseArabic('هامور'));
    final withArticle = await db.speciesDao.searchByNormalisedPrefix(normaliseArabic('الهامور'));

    expect(bare.single.speciesId, withArticle.single.speciesId);
  });
}
```

```dart
// app/test/data/daos/rule_dao_test.dart
void main() {
  test('RuleDao.candidatesFor returns a rule whose valid_to is in the past', () async {
    final rows = await db.ruleDao.candidatesFor(
      jurisdictionId: kGaliciaId,
      speciesId: kCentollaId,
      waterType: 'salt',
      onDate: '2026-07-14',
    );

    expect(rows.map((r) => r.id), contains(kExpiredVedasRuleId),
        reason: 'SPEC 7.3: expiry does not delete — filtering on valid_to is the defect it records');
  });

  // … one test per remaining row above, one behaviour each
}
```

## Implementation outline

1. Write one `@DriftAccessor` per DAO, each scoped to the tables it actually reads.
2. `candidatesFor` is a single `select` with `jurisdiction_id`, `species_id`, `water_type` and
   `valid_from <= :date` in the `where`, and **nothing about `valid_to`**. Add the comment naming §7.3 so
   the next reader does not "fix" it.
3. `searchByNormalisedPrefix` builds `search_norm LIKE :prefix || '%'` with a default `limit: 40`, and
   returns early on an empty prefix rather than issuing the query.
4. Add the `.drift` query for the FTS join: `SELECT lt.* FROM legal_text_fts f JOIN legal_text lt ON
   lt.id = f.rowid WHERE f.body_norm MATCH :q ORDER BY rank LIMIT :limit`. Name the parameter
   `normalisedQuery` in the Dart wrapper.
5. `resolve` issues one `IN` query and returns a `Map<String, String>`; it never substitutes another
   locale.
6. `bboxCandidates` filters on `min_lat <= :lat AND max_lat >= :lat AND min_lon <= :lon AND max_lon >=
   :lon` so `idx_zone_bbox` is usable; assert the plan.
7. Extend `reference_fixture.dart` with `seedSearchCorpus`, which copies the built database into a
   scratch file, opens it **writable in the fixture only** (carrying the second and last
   `// catchlaw-db-ok` of this epic, next to T01's), inserts the corpus, closes it, and reopens it
   read-only for the test.
8. Re-run the suite. 17 green, and T01's 16 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 tests pass, and each failed first.
- [ ] `candidatesFor` contains no reference to `valid_to`, and a test proves an expired rule is returned.
- [ ] No DAO tags, sorts or chooses between rules; resolution stays in `packages/rule_engine/`.
- [ ] `searchByNormalisedPrefix` caps at 40 by default and the `EXPLAIN QUERY PLAN` assertion names
      `idx_name_search` at a corpus of 400 species / 2,400 names.
- [ ] The FTS query reads `body_norm`, and its Dart parameter is named `normalisedQuery`.
- [ ] No `.watch()` anywhere on the reference database.
- [ ] No `ATTACH`, no query spanning both files; check 5 of `check_reference_db.sh` is green.
- [ ] No DAO returns a rendered sentence; D-7's boundary is intact.
- [ ] The fixture's writable open carries `// catchlaw-db-ok` and a comment naming E05/T07; nothing in
      `app/lib/` does.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-drift-confinement.sh       app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-persistence-bans.sh        app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(data): add the reference DAOs and the legal-text FTS query surface

Six single-table accessors over the read-only database: species search,
rule candidates, zones and rings, citations, content strings and legal text.

RuleDao.candidatesFor filters on valid_from and says nothing about valid_to.
SPEC 7.3 records why: the first draft filtered on date < valid_to, so on the
day a Spanish orden de vedas or a Brazilian piracema portaria expired, every
rule sourced from it vanished and every species fell through to "no rule
recorded" — and those annual instruments are exactly the rows that carry a
valid_to. Tagging, ordering and the D4 ambiguity case stay in the engine.

Species search is a prefix query on the indexed search_norm column capped at
40 rows, and the test asserts EXPLAIN QUERY PLAN uses idx_name_search at 400
species / 2,400 names rather than asserting milliseconds on a CI runner. The
FTS query reads body_norm, not body: unicode61 does not fold Arabic
orthographic variants, so an index over the verbatim text answers هامور and
not الهامور.

Task: E05/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
