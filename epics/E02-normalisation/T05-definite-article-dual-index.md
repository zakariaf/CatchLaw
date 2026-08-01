# E02/T05 — Definite-article stripping, with dual indexing

| | |
|---|---|
| **Epic** | E02 — Rule engine: text normalisation |
| **Branch** | `epic/02-normalisation` (shared) |
| **Commit** | `feat(rule_engine): index the article-stripped and article-retained key for every term` |
| **Depends on** | T04 (the terminal collapse must already run — the article is stripped from the fold's output) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.4 "Arabic, in order" step 5 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 11 is this task in one line: the definite article is stripped **and** kept, both forms indexed, query included, and it names the failure if only the index side strips |
| `catchlaw-conventions-index` | Rule 6, the one-way layer map: `indexKeys` returns strings, not rows, and knows nothing about drift or the database that will store them |
| `dart3-idioms-and-coding-standards` | `sync*` versus returning a `List`, and the branch count this task adds — it is the only branching code in the package |
| `dartdoc-conventions` | `indexKeys` becomes the package's second public member and `public_member_api_docs` is on |
| `naming-conventions` | `indexKeys` is a noun phrase because returning the value is the point (`FLUTTER_GUIDE.md` §3.2) |
| `testing-strategy` | Pure unit level, and which of these are branch-coverage cases rather than behaviour cases |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.4 "Arabic, in order" step 5 | The exact rule, and why: *"legal instruments write `الهامور` while users type `هامور`"* |
| `SPEC.md` | §14 dynamic block | *"Arabic full-text search of the legal text returns results in airplane mode (`هامور` and `الهامور` both hit)"* — the release checklist depends on this task |
| `SPEC.md` | §7.1 | `species_name.search_norm` is one column with one index; two keys per alias means two rows, not two columns |
| `.claude/skills/catchlaw-rule-engine/references/normalisation-contract.md` | "The definite article: strip AND keep" | The five-row key table, the short-stem guard, and the 05:40 failure it prevents |
| `.claude/skills/catchlaw-rule-engine/examples/species_normalisation.dart` | `indexKeys`, `buildIndex`, `lookup` | The worked shape, including `if (k.isEmpty) return;` and the three-character guard |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rule 11 | Both keys point at one species id, query included |
| `FLUTTER_GUIDE.md` | §3.2, §3.7 | Noun-phrase naming; `AVOID returning nullable collections` — return empty instead |
| `FLUTTER_GUIDE.md` | §6.1 | Test naming with receipts |

## What this delivers

- `packages/rule_engine/lib/src/search/normalise.dart` — a second public member,
  `Iterable<String> indexKeys(String term)`, in the same file as the fold.
- `packages/rule_engine/lib/rule_engine.dart` — unchanged; the existing export already covers it.
- `packages/rule_engine/test/search/index_keys_test.dart`.
- No change to `normaliseSpeciesTerm`: it does **not** strip the article.

## Why it is built this way

**The article is a key variant, not a fold step.** `SPEC.md` §9.4 step 5 says to strip the leading `ال`
*"and index both the stripped and unstripped forms"*. If `normaliseSpeciesTerm` itself stripped it, the
unstripped key could never be produced by anything, and a fisher who types the article would miss. The
contract's failure-mode table names the symptom exactly — *"`الهامور` misses but `هامور` hits — article
stripped at index time only"* — and `catchlaw-rule-engine` rule 11 makes the point about who types what:
Khalid types the article.

So the fold stays total and lossless-in-one-direction, and a second function fans one term out to the one
or two keys it should be findable under. Both sides call `indexKeys`: the content builder writes a
`species_name` row per key, and the query tries the keys in order. That symmetry is T08's subject.

**Two keys, not two columns.** `SPEC.md` §7.1 gives `species_name` one `search_norm` column and one index
on it. A second key is therefore a second row, which is what E04 will author, and the prefix query in
E05/E08 needs no knowledge of articles at all.

**The unstripped key comes first, and the order is fixed.** The runtime lookup tries the keys in the order
`indexKeys` yields them, so an unstable order makes a two-hit index nondeterministic. The unstripped key
is the more specific match and is yielded first.

**The short-stem guard is the contract's, not an invention.** `normalisation-contract.md`:
*"Do not strip `ال` when the remainder is under three characters — that is a real word, not an article."*
Without it, a four-letter Arabic word that merely begins with the two letters `ا` `ل` is decapitated into
a two-letter stem that will collide with unrelated names, and a two-letter key in a prefix query capped at
40 results (§13) matches half the table.

**Rejected: stripping the article inside `normaliseSpeciesTerm`.** One function, one key, and the article
form unreachable. This is the classic bug the contract names.

**Rejected: stripping the article only when building the index.** The mirror image: the index holds
`هامور`, the fisher types `الهامور`, and the search returns nothing. `catchlaw-rule-engine` rule 11 states
it and §14's dynamic checklist tests for it on a device.

**Rejected: a `RegExp('^ال')`.** `startsWith` plus `substring(2)` is clearer, is what the worked example
does, and — not incidentally — keeps the file free of one more Arabic character class. A regex here buys
nothing and costs a construction.

**Rejected: returning `List<String>`.** `sync*` yields one or two values with no allocation when the
caller only wants the first, which is the query path's normal case. `FLUTTER_GUIDE.md` §3.7 forbids the
other tempting shape, a nullable collection: an unrecognised term yields nothing, never `null`.

## Tests first

Write every row before touching `normalise.dart`. Run them. **They must fail** — `indexKeys` will not
resolve. If one passes now, the test is wrong.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `indexKeys yields the unstripped and the stripped key for الهامور` | `الهامور` | `['الهامور', 'هامور']` | The §9.4 step 5 headline, and row 1 of the contract's key table |
| 2 | `indexKeys yields the unstripped key first` | `الهامور` | first element is `الهامور` | The lookup tries them in order; an unstable order makes a two-hit index nondeterministic |
| 3 | `indexKeys yields one key for a term with no article` | `هامور` | `['هامور']` | Row 2 of the key table. The common case must not grow a spurious second row in `species_name` |
| 4 | `indexKeys yields both keys for الشعري` | `الشعري` | `['الشعري', 'شعري']` | Row 4 of the key table, and a second species so the rule is not fitted to one word |
| 5 | `indexKeys yields one key when stripping ال would leave fewer than three characters` | `الفن` | `['الفن']` | The contract's short-stem guard, which is mechanical and deliberately over-cautious: below three remaining characters it declines to strip whether or not the `ا` `ل` really was an article, because a two-letter key under a prefix query capped at 40 results (§13) matches half the table |
| 6 | `indexKeys yields no keys for an empty string` | `''` | `[]` | The worked example's `if (k.isEmpty) return;`. An empty key in the index matches every prefix query |
| 7 | `indexKeys yields no keys for a whitespace-only string` | `'   '` | `[]` | The fold turns this into `''`; this asserts the guard reads the **folded** value and not the raw input |
| 8 | `indexKeys yields one key for a Latin binomial` | `Epinephelus coioides` | `['epinephelus coioides']` | The article rule is Arabic-only; a Latin term must not acquire a second key, and the folded form is what is indexed |
| 9 | `indexKeys strips the article from the folded form, not the raw input` | `الهامورة` | `['الهامور', 'هامور']` | Order: article stripping consumes T04's output. Strip first and the terminal `ة` survives into both keys |
| 10 | `indexKeys yields the same key for الهامور and for a Presentation-Form paste of it` | both | share `الهامور` | Ties this task to T03: the article check runs on canonical letters, so `ال` in Presentation Forms is still an article |
| 11 | `normaliseSpeciesTerm leaves the definite article in place` | `الهامور` | `الهامور` | The fold must **not** strip. If it did, the unstripped key would be unreachable and the article-typed query would miss |

Branch coverage: `indexKeys` is the only branching code in the package. Its branches are the empty guard
(rows 6 and 7 take it, rows 1–5 and 8–10 do not), the `startsWith` test (rows 1, 4, 5, 9 take it, rows 3
and 8 do not) and the length guard (row 5 takes it, rows 1, 4, 9 do not). Every branch has a case on both
sides, which is what 100% branch coverage on this file means concretely.

```dart
// packages/rule_engine/test/search/index_keys_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('indexKeys', () {
    test('yields the unstripped and the stripped key for الهامور', () {
      expect(indexKeys('الهامور').toList(), ['الهامور', 'هامور']);
    });

    test('yields one key for a term with no article', () {
      expect(indexKeys('هامور').toList(), ['هامور']);
    });

    test('yields one key when stripping ال would leave fewer than three characters', () {
      expect(indexKeys('الفن').toList(), ['الفن']);
    });

    test('yields no keys for an empty string', () {
      expect(indexKeys('').toList(), isEmpty);
    });

    test('strips the article from the folded form, not the raw input', () {
      expect(indexKeys('الهامورة').toList(), ['الهامور', 'هامور']);
    });

    // … one test per row above, one behaviour each
  });

  group('normaliseSpeciesTerm', () {
    test('leaves the definite article in place', () {
      expect(normaliseSpeciesTerm('الهامور'), 'الهامور');
    });
  });
}
```

**Run:** `(cd packages/rule_engine && dart test test/search/index_keys_test.dart)` → 11 failures. If any
passes now, the test is wrong.

## Implementation outline

1. Add `Iterable<String> indexKeys(String term) sync* { … }` to `normalise.dart`, below
   `normaliseSpeciesTerm`. It is public, so it needs a doc comment: a noun-phrase summary
   (`FLUTTER_GUIDE.md` §3.4), then a sentence saying that both the content builder and the runtime query
   call it and why both keys exist. Point at `SPEC.md` §9.4 step 5; do not restate it.
2. Body, in this order: fold once with `normaliseSpeciesTerm`; return if the result is empty; yield it;
   yield the article-stripped form only when the folded key starts with `ال` **and** at least
   three characters remain after the first two.
3. Use `startsWith` and `substring(2)`, not a `RegExp` — the worked example's shape, and one fewer
   character class in the file.
4. Re-run the whole suite. All 11 green, every earlier test still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 11 tests pass, and each failed first.
- [ ] Branch coverage on `normalise.dart` is 100%, with every branch of `indexKeys` exercised on both
      sides — the enumeration above is the checklist.
- [ ] `normaliseSpeciesTerm` still returns the article-retained form; its signature is unchanged.
- [ ] `indexKeys` returns an empty `Iterable`, never `null` (`FLUTTER_GUIDE.md` §3.7).
- [ ] `indexKeys` calls `normaliseSpeciesTerm` exactly once per invocation — the fold is not cheap enough
      to run twice on the query path's 50 ms budget (§13), and running it twice would be the first place a
      second copy could hide.
- [ ] The package exports exactly two public members from `src/search/`.
- [ ] `packages/rule_engine/` still imports nothing from Flutter.

## Gates

Run from the repository root.

```bash
dart format --set-exit-if-changed packages/rule_engine
dart analyze packages/rule_engine
(cd packages/rule_engine && dart test)
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
feat(rule_engine): index the article-stripped and article-retained key for every term

Legal instruments write الهامور; fishers type هامور. Strip the article only
when building the index and the article-typed query misses; strip it inside
the fold and the unstripped key becomes unreachable. So the fold stays total
and a second function fans a term out to both keys, which the builder writes
as two species_name rows and the query tries in a fixed order.

Below three remaining characters the article is left alone: that is a real
word, not an article, and a two-letter key matches half the table under a
prefix query.

Task: E02/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
