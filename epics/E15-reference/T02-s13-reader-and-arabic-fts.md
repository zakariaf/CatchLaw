# E15/T02 — S13, the rule-text reader, and Arabic FTS in under 200 ms

| | |
|---|---|
| **Epic** | E15 — The reference section |
| **Branch** | `epic/15-reference` (shared) |
| **Commit** | `feat(reference): add S13 with FTS5 search over body_norm folded by the engine` |
| **Depends on** | T01 (the hub route and `ReferenceScreenHeader`) |
| **Size** | L |
| **Spec** | `SPEC.md` §6 S13, §4.6 (rule text, citation per finding), §7.1 (`legal_text`, `legal_text_fts`, `citation`), §9.4, §13 (FTS < 200 ms), §14 (the airplane-mode Arabic check), §5.3 (`source_url` is selectable text) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-reference-database` | Rules 3 and 11: the reference DB opens read-only and registers no migration, and no `ATTACH` or shared executor spans the two files. This task adds the first query that touches `legal_text_fts` |
| `persistence-drift` | Rules 1, 7 and 8: drift stays inside `app/lib/data/`, DAOs return value objects, reads are scoped `.watch()` streams. The index/`EXPLAIN QUERY PLAN` discipline in `references/schema-and-daos.md` is what makes the 200 ms claim checkable |
| `lonja-typography` | Rule 2 (anything quoting the law is serif), rule 7 (the 65-character measure that scales), rule 8 (**never truncate legal text**), rule 9 (Arabic tracking is zero) |
| `lonja-forms-and-controls` | The search field is a ruled entry line; rule 7 — the field never fights the user's script, and no formatter strips diacritics from what the user sees |
| `lonja-lists-and-tables` | The hit list is a lazy builder list with all four states; the loading body is a ruled skeleton, never a spinner |
| `catchlaw-verdict-contract` | The citation quadruple, and rule 5: a finding is unconstructable without it. The article header renders instrument, article, published and checked |
| `catchlaw-conventions-index` | Invariant 1 — `source_url` is text, never handed to a launcher; invariant 6 — the one-way layer map this task's DAO sits at the bottom of |
| `i18n-rtl-l10n` | Bidi isolation of the ISO dates and the instrument number inside Arabic prose; directional geometry throughout |
| `widget-golden-and-a11y-testing` | `useDevice` before `pumpApp`; the real-font golden lane, because Arabic script joining is exactly what Ahem cannot prove |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S13 | The element list: full-text search, article navigation, citation header, "as checked on" date, the language-availability notice (T03) |
| `SPEC.md` | §7.1 | `legal_text(id, jurisdiction_id, citation_id, locale, article_ref, body, body_norm, sort_order)`; `legal_text_fts USING fts5(body_norm, content='legal_text', content_rowid='id', tokenize='unicode61 remove_diacritics 2')`; the comment above it saying why `body_norm` exists |
| `SPEC.md` | §9.4 | The ordered Arabic fold, especially step 1 (NFKC over Presentation Forms) and step 5 (the leading `ال`) |
| `SPEC.md` | §13 | "Legal-text FTS — < 200 ms — FTS5 over `body_norm`" |
| `SPEC.md` | §14 | "Arabic full-text search of the legal text returns results in airplane mode (`هامور` and `الهامور` both hit)" and "Tapping a citation expands S13 and copies to clipboard. **No browser opens.**" |
| `SPEC.md` | §5.3 | `authority_url` and `citation.source_url` are selectable text only; the banned symbol list |
| `SPEC.md` | §8 | "populate `search_norm` and `body_norm` with the same normalisation function the app uses, imported from the shared package — not reimplemented", and the ~3 MB per-jurisdiction verbatim-text budget |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | rules 3, 11 | Read-only open, no migration surface, the `ATTACH` ban |
| `.claude/skills/catchlaw-reference-database/references/two-database-contract.md` | "The ATTACH ban", "Test matrix" | Why no SQL spans the two files, and the fixture cases to mirror |
| `.claude/skills/persistence-drift/references/schema-and-daos.md` | "The index & query-plan strategy", "DAOs vs repositories" | Prove the plan in a test; DAOs are single-table and return value objects; `NativeDatabase.memory()` for fast logic tests |
| `.claude/skills/lonja-typography/references/type-ramp.md` | the ramp, "Measures" | `legal` 16/1.62, `citation` 12 mono, `articleNumber` 11 mono; `LonjaMeasure.legal` 500, `marginRail` 56 |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Arabic resolution rules", "Numerals" point 5 | `legal` in `ar` is 17.9 px, height 1.80, tracking 0; citation dates stay Western-digit ISO in every locale. **Note:** this file's locale list names `fr`; D-3 settles the six locales as `ar en es gl ca pt_BR` and E08's epic already logged the discrepancy — do not propagate it |
| `.claude/skills/lonja-forms-and-controls/references/search-field-and-keypad.md` | "Script handling", "Edge cases" | The visible text is the user's, the query string is the engine's; the no-result copy is a fact, not "Try again" |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Precedence", "Loading skeleton" | `stale` is orthogonal; no spinner, no "Loading…" |
| `FLUTTER_GUIDE.md` | Part 5.2 | The vertical slice: repository takes no `Ref`, providers return the stream, the widget switches exhaustively on `AsyncValue` |
| `FLUTTER_GUIDE.md` | Part 6.4 | Where this belongs in the pyramid: drift unit over `NativeDatabase.memory()`, one widget test per screen, goldens narrow |
| `epics/DECISIONS.md` | D-1, D-6, D-7 | Paths; the read-only open; the engine holds no user-visible sentence |

## What this delivers

- `app/lib/data/fts5_match_expression.dart` — `String fts5MatchExpression(String folded)`. Turns an
  already-folded query into a safe FTS5 `MATCH` expression, or returns `null` when the fold left
  nothing to search for.
- `app/lib/data/daos/legal_text_dao.dart` — `LegalTextDao` on the read-only `ReferenceDatabase`:
  `search`, `articlesFor`, `articleById`. Returns domain values; no drift row escapes.
- `app/lib/domain/models/legal_text_article.dart` — `LegalTextArticle` (id, `articleRef`, `body`,
  `sortOrder`, `Citation`), immutable, const constructor.
- `app/lib/data/repositories/legal_text_repository.dart` (abstract) and
  `legal_text_repository_drift.dart` (impl); a fake in `app/testing/fakes/fake_legal_text_repository.dart`.
- `app/lib/ui/reference/rule_text_screen.dart` — `RuleTextScreen` (S13).
- `app/lib/ui/reference/view_models/rule_text_viewmodel.dart` — `RuleTextViewModel`.
- `app/lib/ui/reference/widgets/legal_text_citation_header.dart` — instrument type (localised
  through `content_string`), `instrument_ref`, `article_ref`, `published_on`, `source_url` as
  `SelectableText` with copy-to-clipboard, and the "as checked on" date.
- `app/lib/ui/reference/widgets/legal_text_hit_row.dart` and `legal_text_article_body.dart`.
- `app/testing/models/legal_text_fixtures.dart` — `kArticleArabicBareStem`,
  `kArticleArabicArticlePrefixed`, `kGaliciaSentinelToken`.
- Tests: `app/test/data/fts5_match_expression_test.dart`,
  `app/test/data/legal_text_dao_test.dart`, `app/test/data/legal_text_fts_latency_test.dart`,
  `app/test/ui/reference/rule_text_screen_test.dart`.

## Why it is built this way

**FTS5 `unicode61` does not fold Arabic orthography, and that is the whole reason `body_norm` exists.**
`SPEC.md` §7.1 puts the reason in a comment above the table, and it is worth being precise about what
`remove_diacritics 2` does and does not do. It strips *combining marks*, so the harakat
(U+064B–U+0652) do come off. It does **not** decompose `أ` (U+0623), `إ` (U+0625), `آ` (U+0622),
`ة` (U+0629) or `ى` (U+0649) — those are distinct base codepoints, not a base plus a mark — and it
does not perform NFKC, so the Arabic Presentation Forms block (U+FB50–U+FEFF) that OCR of a gazette
PDF emits (§9.4 step 1) stays exactly as it arrived. A tokenizer alone therefore cannot make `هامور`
and `الهامور` the same token. The fold has to happen **before** indexing, which is what E04 did to
populate `body_norm`, and **before** querying, which is what this task does.

**The query is folded by the same function, imported, never reimplemented.**
`SPEC.md` §8 states it as a build requirement: the same normalisation function the app uses, imported
from the shared package, not reimplemented. This task imports it from
`package:rule_engine/rule_engine.dart` and adds no fold of its own — not a `toLowerCase()`, not a
`replaceAll`, not a "just strip the alef" convenience. **Rejected:** a small local normaliser in
`app/lib/data/`, which would work on the day it was written and drift from `body_norm` at the next
content build, at which point Arabic search returns nothing and every test in this file still passes,
because the tests would be folding with the same broken copy. The epic's definition of done greps for
exactly that.

**The MATCH expression is built, never interpolated.**
`MATCH` takes a query *language*, not a string. A reader typing `"` produces a syntax error; typing
`AND`, `NOT`, `NEAR` or `*` produces a query they did not ask for; typing `-` produces a negation.
`fts5MatchExpression` therefore double-quotes every token (doubling any internal `"`), joins them with
a space — FTS5's implicit AND — and appends `*` to the final token so a partially typed word still
matches while the reader types. **Rejected:** passing the folded string straight to `MATCH`, which is
the injection-shaped defect of a query language nobody thinks of as one.

**An empty fold is a state, not an error.**
A reader who has typed only tatweel or harakat leaves the fold with an empty string, and
`MATCH ''` is an FTS5 syntax error. `fts5MatchExpression` returns `null` in that case and the view
model falls back to the full article list for the jurisdiction — the same body the screen shows before
anything is typed. **Rejected:** catching the `SqliteException` and rendering the error state, which
turns a reader pressing shift into a corrupt-database message.

**Hits are located, not highlighted.**
FTS5's `snippet()` and `highlight()` return offsets into the *indexed* column. That column is
`body_norm`, whose length differs from `body` — tatweel stripped, harakat removed, the leading `ال`
gone. Those offsets do not map. So a hit row shows `article_ref` plus the opening run of `body`, and
opening it renders the article verbatim with no highlight at all. **Rejected:** rendering
`snippet(legal_text_fts, …)` to the reader, which would put *normalised* law on screen — an Arabic
legal text with its diacritics deleted, presented as the published wording. That is precisely the
substitution §9.6 exists to prevent, arriving through a convenience function.

**Ordering is `bm25()` then `sort_order`, capped at 40.**
`bm25` ranks relevance; `sort_order` breaks ties in the instrument's own order so two equally ranked
articles never swap places between runs. The cap is 40 — the same number `SPEC.md` §13 puts on species
search, for the same reason: past forty hits the reader is refining the query, not scrolling.

**`source_url` is text with a copy affordance, and nothing else.**
§5.3 is explicit that an `ACTION_VIEW` intent would cause a fetch under the browser's own permission
and defeat the Android guarantee. `SelectableText` plus `Clipboard.setData` satisfies §4.6's
"offers copy-to-clipboard" and §14's "no browser opens". **Rejected:** `url_launcher`, `launchUrl`,
`AndroidIntent` — all four are on §14's static grep list and `check_no_network.sh` fails the build.

**Legal prose is never truncated and never clamped.**
`lonja-typography` rule 8: no `maxLines`, no `TextOverflow.ellipsis`, no `FittedBox` on `t.legal` or
`t.citation`; the column is `LonjaMeasure.legal * MediaQuery.textScalerOf(context).scale(1)` and the
page scrolls. Truncating a citation removes the article number that makes the quotation checkable.

**The Arabic tests build their own corpus; the rebuild guard uses the real one.**
E04 seeded **Galicia**, whose instruments are published in Galician and Spanish; §16 R1 records that
the Gulf texts are the open risk and are not transcribed yet. So the Arabic assertions here run
against a small hand-authored `legal_text` fixture in an in-memory database, normalised through
`package:rule_engine` exactly as the builder does. Separately, one test queries the **committed
Galicia fixture as E04 built it** for `kGaliciaSentinelToken` — and a second test asserts that token
really occurs in a `legal_text.body` row, so the sentinel cannot rot into a tautology. That pair is
the guard for epic Risk 3: `legal_text_fts` is an external-content table, and if the builder ever
stops issuing its rebuild, every query returns zero rows and the app renders a perfectly authored
"no matches" state instead of failing.

## Tests first

Write every row before touching `legal_text_dao.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `fts5MatchExpression quotes a single token` | `هامور` | `"هامور"*` | The base case, and it proves the prefix star lands on the last token |
| 2 | `fts5MatchExpression doubles an embedded double quote` | `sa"id` | `"sa""id"*` | The injection-shaped defect: an unescaped quote is an FTS5 syntax error, i.e. a crash from one keystroke |
| 3 | `fts5MatchExpression neutralises an FTS5 operator typed as text` | `talla NOT minima` | `"talla" "NOT" "minima"*` | `NOT` is a query operator; unquoted it silently inverts the reader's search |
| 4 | `fts5MatchExpression returns null for an empty fold` | `ــَـ` (tatweel + harakat) | `null` | `MATCH ''` is a syntax error; this is the branch that stops it becoming an error screen |
| 5 | `LegalTextDao.search matches هامور when the body writes الهامور` | body `الهامور`, query `هامور` | 1 hit | §14's airplane-mode check, direction one. The reason `body_norm` exists |
| 6 | `LegalTextDao.search matches الهامور when the body writes هامور` | body `هامور`, query `الهامور` | 1 hit | §14's airplane-mode check, direction two. Symmetry is not free — it holds only because both sides use one fold |
| 7 | `LegalTextDao.search matches هامور when the body writes هامورة` | body `هامورة`, query `هامور` | 1 hit | §9.4 step 4's terminal-form collapse, reaching the index rather than only the unit test in E02 |
| 8 | `LegalTextDao.search matches a Presentation-Form spelling of هامور` | body written in U+FB50–U+FEFF | 1 hit | §9.4 step 1. This is what OCR of a gazette PDF actually emits, and `unicode61` will not NFKC it |
| 9 | `LegalTextDao.search matches ria when the body writes ría` | `gl` body, query `ria` | 1 hit | The Latin branch of §9.4 — Galician, Catalan, Spanish and Portuguese all carry diacritics |
| 10 | `LegalTextDao.search excludes an article from another jurisdiction` | two jurisdictions, one token | only the active one | The reference DB holds every jurisdiction; an unscoped query quotes Brazilian law at a Galician reader |
| 11 | `LegalTextDao.search excludes an article in another locale` | `gl` and `es` bodies of one instrument | only the requested locale | §9.6 in the data layer: two published languages of one instrument must not interleave in one result list |
| 12 | `LegalTextDao.search orders by bm25 then sort_order` | two equally ranked articles | instrument order | A result list that reorders between identical runs is unusable for citing |
| 13 | `LegalTextDao.search caps the result list at 40` | 60 matching articles | 40 rows | The stated cap; without it a one-letter prefix query returns the whole instrument |
| 14 | `LegalTextDao.search returns a hit for the Galicia sentinel token` | the committed E04 fixture | ≥ 1 hit | The external-content rebuild guard (epic Risk 3). Fails loudly instead of the app going quiet |
| 15 | `Galicia fixture contains the sentinel token in a legal_text body` | the committed E04 fixture | ≥ 1 row | Stops test 14 decaying into a tautology if the seed's wording changes |
| 16 | `LegalTextDao.search completes in under 200 ms over a 3 MB body_norm corpus` | §8's budget, median of 100 queries | < 200 ms | §13's target, as a CI regression guard. The device figure is E21's |
| 17 | `LegalTextDao.search uses the FTS index rather than scanning legal_text` | `EXPLAIN QUERY PLAN` | plan names `legal_text_fts` | A plan change is how a 200 ms query becomes a 4 s one without any test going red |
| 18 | `RuleTextScreen renders the article body verbatim` | article with harakat and tatweel | rendered text equals `body`, not `body_norm` | The rendering half of §9.6: the reader sees published law, never the index |
| 19 | `RuleTextScreen renders the citation header with instrument, article, published and checked dates` | one article | all four present | `catchlaw-verdict-contract` rule 5's quadruple, on the screen the citation row expands into |
| 20 | `RuleTextScreen copies source_url to the clipboard and opens no browser` | tap copy | clipboard set; no launcher invoked | §14's check and §5.3's guarantee, asserted rather than assumed |
| 21 | `RuleTextScreen states the fact when no article matches` | query with no hits | the authored empty copy, no `Try again` | Empty surface 1 of T09's eight; the copy rule from `search-field-and-keypad.md` |
| 22 | `ar - RuleTextScreen sets the article body in the serif legal step` | `Locale('ar')` | resolved style is `t.legal` | `lonja-typography` rule 2: law set in the UI sans reads as a push notification |
| 23 | `RuleTextScreen applies no maxLines and no ellipsis to the article body` | long article at textScaler 2.0 | no `TextOverflow.ellipsis`, no clipping | Rule 8. Truncating removes the article number that makes the quotation checkable |

```dart
// app/test/data/legal_text_dao_test.dart
import 'package:catchlaw/data/daos/legal_text_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart';   // the fold — imported, never reimplemented

import '../../testing/models/legal_text_fixtures.dart';

void main() {
  late ReferenceDatabase db;
  late LegalTextDao dao;

  setUp(() async {
    db = ReferenceDatabase(NativeDatabase.memory());   // catchlaw-db-ok
    await seedLegalText(db, kArabicArticleFixtures);   // body_norm via normaliseArabic
    dao = LegalTextDao(db);
  });
  tearDown(() => db.close());

  test('LegalTextDao.search matches هامور when the body writes الهامور', () async {
    final hits = await dao.search(
      jurisdictionId: kJurisdictionRak,
      locale: 'ar',
      query: 'هامور',
    );
    expect(hits, hasLength(1));
    expect(hits.single.articleRef, 'Art. 3');
  });

  test('LegalTextDao.search matches الهامور when the body writes هامور', () async {
    final hits = await dao.search(
      jurisdictionId: kJurisdictionRak,
      locale: 'ar',
      query: 'الهامور',
    );
    expect(hits, hasLength(1));
  });

  test('LegalTextDao.search uses the FTS index rather than scanning legal_text',
      () async {
    final plan = await db
        .customSelect('EXPLAIN QUERY PLAN ${dao.searchSql}',
            variables: dao.searchPlanProbeVariables)
        .get();
    expect(plan.map((r) => r.data['detail']).join(' '),
        contains('legal_text_fts'));
  });

  // … one test per row of the table above, one behaviour each.
}
```

```dart
// app/test/data/fts5_match_expression_test.dart
import 'package:catchlaw/data/fts5_match_expression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fts5MatchExpression doubles an embedded double quote', () {
    expect(fts5MatchExpression('sa"id'), '"sa""id"*');
  });

  test('fts5MatchExpression returns null for an empty fold', () {
    expect(fts5MatchExpression(''), isNull);
  });
}
```

```dart
// app/test/data/legal_text_fts_latency_test.dart
// A REGRESSION GUARD with SPEC.md §13's number as its ceiling — not a device measurement.
// The device figure is E21's §14 pass on physical hardware.
test('LegalTextDao.search completes in under 200 ms over a 3 MB body_norm corpus',
    () async {
  await seedLegalTextToBytes(db, targetBodyNormBytes: 3 * 1024 * 1024); // SPEC.md §8
  final samples = <int>[];
  for (var i = 0; i < 100; i++) {
    final sw = Stopwatch()..start();
    await dao.search(jurisdictionId: kJurisdictionGalicia, locale: 'gl', query: 'talla');
    samples.add(sw.elapsedMicroseconds);
  }
  samples.sort();
  expect(samples[49] / 1000, lessThan(200),
      reason: 'median of 100 queries exceeded the SPEC.md §13 ceiling');
});
```

**Run:** `cd app && flutter test test/data/ test/ui/reference/rule_text_screen_test.dart` → 23
failures. If any passes now, the test is wrong — in particular, tests 5 to 8 passing before
`LegalTextDao` exists would mean the fixture is being searched by something other than the index.

## Implementation outline

1. Write `fts5MatchExpression`. Tokenise on whitespace **after** the fold, quote each token, double
   internal `"`, join with a space, append `*` to the last token. Return `null` on empty.
2. Write `LegalTextDao` with the three methods. The search SQL, as one `customSelect`:

   ```sql
   SELECT lt.id, lt.article_ref, lt.body, lt.sort_order, lt.citation_id
   FROM legal_text_fts f
   JOIN legal_text lt ON lt.id = f.rowid
   WHERE f MATCH :match
     AND lt.jurisdiction_id = :jurisdiction
     AND lt.locale = :locale
   ORDER BY bm25(f), lt.sort_order
   LIMIT 40
   ```

   `content_rowid='id'` is what makes `f.rowid = legal_text.id` true; do not join on anything else.
   Map rows to `LegalTextArticle` inside the DAO — no drift row crosses into `domain/` or `ui/`.
3. Fold the incoming query with `package:rule_engine`'s exported function **before** calling
   `fts5MatchExpression`. Add no normalisation of your own anywhere in `app/lib/`.
4. Write the repository interface, its drift implementation and the fake. The repository takes no
   `Ref` and imports no Riverpod (`FLUTTER_GUIDE.md` Part 5.2).
5. Write `RuleTextViewModel`: it holds the query text, the resolved legal-text locale (T03 will
   supply the resolution; for now default to `jurisdiction.default_locale` when it appears in
   `legal_text_locales`, else the first CSV entry), and exposes `AsyncValue<List<LegalTextArticle>>`.
6. Write `RuleTextScreen`: `ReferenceScreenHeader`, `LonjaSearchField`, the hit list as a lazy
   builder with all four states, and the article body under
   `LonjaMeasure.legal * textScalerOf(context).scale(1)` with no `maxLines`.
7. Write `LegalTextCitationHeader`. Instrument type through `content_string`; `instrument_ref` and
   `article_ref` in `citation`/`articleNumber`; `published_on` and `retrieved_on` as Western-digit
   ISO in every locale, bidi-isolated; `source_url` as `SelectableText` with a copy action.
8. Article navigation: a jump list ordered by `sort_order`, scrolling the body to the chosen
   `article_ref`.
9. Re-run the whole suite, not just this file.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 23 tests pass, and each failed first.
- [ ] `grep -rnE 'toLowerCase|replaceAll|normalis|normaliz' app/lib/data/ app/lib/ui/reference/`
      shows no fold other than the call into `package:rule_engine`.
- [ ] `هامور` and `الهامور` each return the same article in both directions, through the real index.
- [ ] The median of 100 searches over a 3 MB `body_norm` corpus is under 200 ms on CI, and the commit
      body says this is a regression guard rather than the §13 device figure.
- [ ] `EXPLAIN QUERY PLAN` names `legal_text_fts`; the assertion is a test, not a comment.
- [ ] No `snippet(`, `highlight(` or offset arithmetic over `body` exists anywhere in the diff.
- [ ] The rendered article body is byte-identical to `legal_text.body`; `body_norm` never reaches a
      `Text`.
- [ ] `check_no_network.sh app/lib` is clean; no `launchUrl`, `url_launcher`, `AndroidIntent` or
      `ACTION_VIEW` appears.
- [ ] `ReferenceDatabase` is still opened `readOnly: true` and still registers no migration;
      `check_reference_db.sh app/lib` is clean.
- [ ] No `ATTACH`, and no `QueryExecutor` shared with `user.db`.
- [ ] `packages/rule_engine/` untouched (D-7).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh       app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh    app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh     app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
tools/gates/no_directional_geometry.sh                                       app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(reference): add S13 with FTS5 search over body_norm folded by the engine

FTS5's unicode61 tokenizer strips combining marks but never decomposes أ, إ, آ,
ة or ى, and never applies NFKC to the Presentation Forms that OCR of a gazette
PDF emits. So هامور and الهامور cannot become one token in the index — which is
why legal_text carries body_norm, and why the query is folded by the same
function from packages/rule_engine that wrote that column rather than by a local
copy that would drift at the next content build.

MATCH takes a query language, not a string: every token is quoted, embedded
quotes are doubled, and an empty fold returns the full article list instead of a
syntax error. Hits are located by article_ref, never highlighted — snippet()
returns offsets into body_norm, which would put normalised law on screen.

source_url renders as selectable text with copy-to-clipboard. Nothing is handed
to a browser (SPEC.md §5.3, §14).

The 200 ms assertion is a CI regression guard with SPEC.md §13's number as its
ceiling. The device figure belongs to E21's §14 pass.

Task: E15/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
