# E02/T04 — Collapse the Arabic word-final forms

| | |
|---|---|
| **Epic** | E02 — Rule engine: text normalisation |
| **Branch** | `epic/02-normalisation` (shared) |
| **Commit** | `feat(rule_engine): collapse the Arabic word-final ta marbuta and ha to nothing` |
| **Depends on** | T03 (NFKC and the letter-family folds must already run) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.4 "Arabic, in order" step 4 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Owns `references/normalisation-contract.md` — the ordered fold and the property every step must preserve. Rule 10 names the terminal collapse as part of the one sanctioned function |
| `catchlaw-conventions-index` | Invariant 6, the one-way layer map: this is pure Dart and may not reach for Flutter |
| `dart3-idioms-and-coding-standards` | Function length, and pattern matching over a hand-rolled code-unit switch |
| `testing-strategy` | Which level this belongs at — pure unit, no widget binding |
| `naming-conventions` | The private step name and the test names below |
| `dartdoc-conventions` | The public doc comment gains the prefix-property sentence; the private step gets none |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.4 "Arabic, in order" step 4 | The exact rule, and the first draft's bug it exists to fix |
| `SPEC.md` | §9.1 | The five Gulf species names, two of which end in `ي` — the evidence behind the alef-maqsura split |
| `SPEC.md` | §13 | Species search is a prefix query over an indexed `search_norm`, capped at 40 results, under 50 ms — the reason the prefix property is load-bearing |
| `.claude/skills/catchlaw-rule-engine/references/normalisation-contract.md` | whole | The contract the app and the builder share; step 7 and its word-final-only warning |
| `.claude/skills/catchlaw-rule-engine/examples/species_normalisation.dart` | whole | The worked shape — do not diverge from it silently |
| `FLUTTER_GUIDE.md` | §6.1 | Test naming with receipts |
| `epics/DECISIONS.md` | D-7 | The engine holds no user-visible string; the fold produces keys, and the display name is stored unmodified elsewhere |

## What this delivers

- `packages/rule_engine/lib/src/search/normalise.dart` — the `_collapseTerminals` step, wired into the
  ordered fold after the letter-family folds of T03 and before the digit map of T06.
- `packages/rule_engine/test/search/normalise_terminals_test.dart`.
- No public API change: `normaliseSpeciesTerm` keeps its signature.

## Why it is built this way

`SPEC.md` §9.4 records that the first draft folded `ة` → `ه`, producing `هاموره` from `هامورة`. That
string is neither equal to nor a **prefix of** `هامور`, which is what a user types. Because search is a
prefix query over an indexed `search_norm` column (§13, `< 50 ms` at 400 species / 2,400 names), losing
the prefix property does not merely rank a result lower — it removes it from the result set entirely.
The spec's own acceptance test could not have passed.

So the two word-final forms `ة` and `ه` collapse to **nothing** at the end of a word rather than to a
shared letter. `هامورة` → `هامور`, `هاموره` → `هامور`, `هامور` → `هامور`, and the prefix property holds
for all three.

**Word-final only.** `ه` is a common medial letter; deleting it everywhere would fold unrelated species
together. The step is anchored to a word boundary, and a test asserts a medial `ه` survives.

**Alef maqsura is not deleted here, and that is a deliberate divergence from a plain reading of §9.4 step
4.** §9.4 step 4 names three characters — `ة`, `ه` and `ى` — and says to collapse them word-finally. The
normalisation contract splits them: it folds `ى` → `ي` at step 6 and deletes only `ة` and `ه` at step 7.
The contract is right, and `SPEC.md` §9.1 is the evidence. Two of the five Gulf species §9.1 names,
`شعري` and `صافي`, end in `ي`. A word-final `ي` is never deleted, because deleting it would put `شعري` on
the same key as `شعر`. If a word-final `ى` were deleted while `ي` was kept, then `شعرى` — which is how a
great many Arabic keyboards and OCR passes render exactly that name — would land on `شعر` while `شعري`
landed on `شعري`, and the two spellings of one species would be on two different keys. That is the split
the contract's step 6 exists to close, and closing it is worth more than the literal reading of a
three-character list.

Folding rather than deleting also satisfies what §9.4 step 4 actually asks for. The requirement is stated
as *"so `هامورة` and `هامور` share a prefix"*. `هامور` **is** a prefix of `هاموري`, so the prefix property
survives the fold; it is the `ة` case, where the extra character carries no sound and no meaning, that
needs deletion. T03 owns the `ى` → `ي` line; this task owns `ة` and `ه`.

**`\b` will not do.** Dart's `RegExp` word boundary is defined on ASCII word characters, so `\b` does not
fire between `ة` and a space, and fires in places nobody intends inside Arabic text. The anchor is an
explicit negative lookahead on the Arabic letter block: a terminal form followed by anything that is not
an Arabic letter, or by end of string. That makes the Arabic comma `،` (U+060C) a word boundary, which is
what the OCR of a gazette list of species will actually produce.

**Rejected: running this before the letter-family folds.** `ى` and `ي` interact — the order in §9.4 is a
contract, and `normalisation-contract.md` states the fold is ordered and shared with the content builder.
A different order in the two places produces a database whose keys the app cannot reproduce.

**Rejected: a global `replaceAll(RegExp('[ةه]'), '')`.** It is one character shorter and it merges
unrelated species. `normalisation-contract.md` names it directly: *"Deleting a medial `ه` would merge
unrelated names; anchor the pattern with a word boundary or apply it per token, never with a global
`replaceAll`."* The failure-mode table lists the symptom as "two species collapse into one".

**Rejected: tokenising the string, folding each token, rejoining.** It produces the same result and it
loses the original whitespace, which T02's step 10 has already normalised and which the acceptance test
in T07 asserts. One lookahead does the same job in one line.

## Tests first

Write every row before touching `normalise.dart`. Run them. **They must fail.** If one passes now, the
test is wrong — the likeliest cause is an input that was already terminal-free, so check the input really
ends in `ة` or `ه`.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `normaliseSpeciesTerm strips a word-final ta marbuta` | `هامورة` | `هامور` | The §9.4 step 4 headline case |
| 2 | `normaliseSpeciesTerm leaves a bare stem unchanged` | `هامور` | `هامور` | Idempotence with case 1 — both must land on one key, which is the whole point |
| 3 | `normaliseSpeciesTerm strips a word-final ha` | `هاموره` | `هامور` | This is the exact string §9.4 records the first draft producing. The corrected fold must land it on the same key, not merely stop creating it |
| 4 | `normaliseSpeciesTerm keeps a medial ha` | `شهري` | `شهري` | The over-fold guard: a medial `ه` must survive, or unrelated names merge |
| 5 | `normaliseSpeciesTerm keeps a word-final ya` | `شعري` | `شعري` | T03 folded `ى` onto `ي`; this task must not now delete it. `شعري` is one of the five species §9.1 names |
| 6 | `normaliseSpeciesTerm strips a terminal form in each word of a phrase` | `سمكة كبيرة` | `سمك كبير` | Word-final means every word, not the string's last character |
| 7 | `normaliseSpeciesTerm strips a terminal form before an Arabic comma` | `هامورة،` | `هامور،` | The boundary is not end-of-string. `،` is U+060C, outside the Arabic letter block, and it is what a gazette species list is punctuated with |
| 8 | `normaliseSpeciesTerm is idempotent` | `هامورة` folded twice | `هامور` | A fold applied twice — once by the builder, once by the app — must not drift |
| 9 | `normaliseSpeciesTerm runs the terminal collapse after the alef fold` | `أهامورة` | `اهامور` | Order is part of the contract; this is T03 and this task asserted together |
| 10 | `normaliseSpeciesTerm returns an empty string when the input is empty` | `''` | `''` | The boundary the lookahead will get wrong first |
| 11 | `normaliseSpeciesTerm maps هامورة and هامور to the same key` | both | equal | States the property rather than the transform. This is the row §9.4's acceptance test rests on, and it survives a later refactor that changes the output alphabet |

```dart
// packages/rule_engine/test/search/normalise_terminals_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('normaliseSpeciesTerm', () {
    test('strips a word-final ta marbuta', () {
      expect(normaliseSpeciesTerm('هامورة'), 'هامور');
    });

    test('strips a word-final ha', () {
      // هاموره is what the first draft's ة -> ه fold produced (SPEC §9.4 step 4).
      expect(normaliseSpeciesTerm('هاموره'), 'هامور');
    });

    test('keeps a medial ha', () {
      expect(normaliseSpeciesTerm('شهري'), 'شهري');
    });

    test('keeps a word-final ya', () {
      expect(normaliseSpeciesTerm('شعري'), 'شعري');
    });

    test('strips a terminal form in each word of a phrase', () {
      expect(normaliseSpeciesTerm('سمكة كبيرة'), 'سمك كبير');
    });

    test('maps هامورة and هامور to the same key', () {
      expect(normaliseSpeciesTerm('هامورة'), normaliseSpeciesTerm('هامور'));
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `(cd packages/rule_engine && dart test test/search/normalise_terminals_test.dart)` → 11
failures. If any passes now, the test is wrong.

## Implementation outline

1. Add `_collapseTerminals(String)` to `normalise.dart`, private, with no doc comment (`///` on a private
   step is noise — `CONVENTIONS.md` §8).
2. Anchor on a word boundary that is correct for Arabic. `\b` is defined on ASCII word characters and
   will not do. Match a terminal form followed by end-of-string or a non-letter, with a negative lookahead
   on the Arabic letter block U+0621–U+064A:
   `RegExp('[\u0629\u0647](?![\u0621-\u064A])')`, replaced with the empty string. Escapes, not
   literals, for the reason T03 gives: a reviewer cannot approve a character class they cannot see.
3. Insert the call into the ordered fold, **after** the letter-family folds of T03 and **before** the
   digit map of T06 — that is contract position 7.
4. Extend the doc comment on `normaliseSpeciesTerm` with the prefix-property sentence and a pointer to
   `SPEC.md` §9.4 step 4. Do not restate the rule.
5. Re-run the suite. All 11 green, and every earlier normalisation test still green — test 5 and T03's
   `شعرى` test together are what catch an over-broad character class.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 11 tests pass, and each failed first.
- [ ] Branch coverage on `normalise.dart` is 100%.
- [ ] `normaliseSpeciesTerm` has the same signature it had before this task.
- [ ] The terminal character class contains exactly U+0629 and U+0647 — no `ى`, no `ي`.
- [ ] The anchor is a lookahead on U+0621–U+064A; the string `\b` appears nowhere in the file.
- [ ] `packages/rule_engine/` still imports nothing from Flutter.
- [ ] The identical function is what `tools/content_builder/` will call — not a copy. E04, which builds
      `search_norm` and `body_norm` per `SPEC.md` §8, depends on that and on this order.

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
feat(rule_engine): collapse the Arabic word-final ta marbuta and ha to nothing

Folding ة to ه produced هاموره, which is neither equal to nor a prefix of
هامور — so a prefix search for what a user actually types could never reach
the species. The two terminal forms now collapse to nothing at a word
boundary, and a medial ه is left alone.

Alef maqsura is not in that class. SPEC §9.4 step 4 lists it with ة and ه,
but SPEC §9.1 names شعري and صافي, a word-final ي is never deleted, and
deleting a word-final ى while keeping ي would put the two common spellings
of one species on two different keys. T03 folds ى onto ي instead, which
keeps the prefix property step 4 asks for and merges the two typings.

The boundary is a negative lookahead on U+0621-U+064A, not \b: Dart's word
boundary is ASCII-defined and does not fire before an Arabic comma.

Task: E02/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
