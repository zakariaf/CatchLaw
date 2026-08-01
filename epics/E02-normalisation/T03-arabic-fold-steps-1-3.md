# E02/T03 — The Arabic fold, steps 1 to 3: NFKC, tatweel and harakat, the letter families

| | |
|---|---|
| **Epic** | E02 — Rule engine: text normalisation |
| **Branch** | `epic/02-normalisation` (shared) |
| **Commit** | `feat(rule_engine): run NFKC first, then strip tatweel and harakat and fold the letter families` |
| **Depends on** | T02 (`normalise.dart` and the Unicode normalisation dependency must exist) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.4 "Arabic, in order" steps 1, 2 and 3 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 10 states the ordering law in one line — "NFKC FIRST because Presentation Forms are what OCR emits" — and its anti-pattern list names `replaceAll('أ', 'ا')` before NFKC as a defect |
| `catchlaw-conventions-index` | Rule 6, the one-way layer map: this is pure Dart and may not reach for Flutter, `intl` or a locale |
| `dart3-idioms-and-coding-standards` | Function length and complexity as the fold grows to eight steps; whether each step is a private helper or a line |
| `dartdoc-conventions` | The doc comment on `normaliseSpeciesTerm` gains the ordering statement; a `///` on a private step function is noise |
| `naming-conventions` | Private step helpers, if any, are `lowerCamelCase` with a leading underscore and named for what they delete |
| `testing-strategy` | Pure unit level; a Presentation-Form input is a string literal, not a fixture file |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.4 "Arabic, in order" steps 1–3 | The exact rule, and the recorded correction: *"The first draft omitted this"* about NFKC |
| `SPEC.md` | §9.1 | Why `ar` is the moat, and the five species names — `هامور، شعري، صافي، بدح، كنعد` — that the folds must keep apart |
| `SPEC.md` | §8, Gulf row | Why OCR is in the picture at all: the Gulf text is transcribed from official gazette or ministry PDFs by a paid Arabic-speaking transcriber |
| `.claude/skills/catchlaw-rule-engine/references/normalisation-contract.md` | "The pipeline, in order" rows 1–6; "Character reference"; "Failure modes this contract prevents" | The code-point ranges, the ya-family row, and the symptom table that names "Arabic search returns nothing, Latin search works" as NFKC skipped |
| `.claude/skills/catchlaw-rule-engine/examples/species_normalisation.dart` | whole | The worked shape and the order of the `replaceAll` chain |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rule 10, "The normalisation contract, in one place", Anti-patterns | The `nfkc(input)` first line and the named anti-pattern this task must not commit |
| `FLUTTER_GUIDE.md` | §6.1 | Test naming, and the rule that a loop-generated test interpolates its parameter |
| `epics/CONVENTIONS.md` | §5 | Loop-generated tests interpolate the parameter into the description, or `--plain-name` is useless |

## What this delivers

- `packages/rule_engine/lib/src/search/normalise.dart` — steps 1 to 3 inserted **above** the Latin steps
  T02 left at the bottom, in the contract's numbered order.
- `packages/rule_engine/test/search/normalise_arabic_fold_test.dart`.
- No public API change: `normaliseSpeciesTerm` keeps its signature and its single export.

The steps, with the code points, exactly as the contract's character reference lists them:

| Contract step | What | Code points |
|---|---|---|
| 1 | NFKC over the whole string | folds Presentation Forms-A U+FB50–U+FDFF and Presentation Forms-B U+FE70–U+FEFF |
| 2 | delete tatweel | U+0640 |
| 3 | delete harakat and the superscript alef | U+064B–U+0652, U+0670 |
| 4 | alef family to plain alef | U+0622, U+0623, U+0625, U+0671 → U+0627 |
| 5 | hamza on waw and on ya | U+0624 → U+0648, U+0626 → U+064A |
| 6 | alef maqsura to ya | U+0649 → U+064A |
| — | delete the invisible marks | U+200C–U+200F (ZWNJ, ZWJ, LRM, RLM) |

## Why it is built this way

**NFKC first, and this is the whole point of the task.** `SPEC.md` §9.4 records the correction plainly:
step 1 exists because Arabic Presentation Forms are *"exactly what OCR of the gazette PDFs emits"*, and
*"the first draft omitted this"*. `SPEC.md` §8 explains where the OCR comes from — the Gulf rule rows and
verbatim text are transcribed from the official gazette or ministry PDF, with a named budget line for a
paid Arabic-speaking transcriber. Text extracted from those PDFs frequently arrives as U+FE70–U+FEFF
glyph forms rather than as U+0621–U+064A letters.

The failure mode is precise and silent. If the letter folds run before NFKC, `[آأإٱ]` never matches
U+FE83 and the fold leaves the Presentation Form standing. Latin search keeps working, Arabic search
returns nothing, and nothing in the code looks wrong — which is the first row of the contract's
"Failure modes this contract prevents" table. `catchlaw-rule-engine`'s anti-pattern list names it as
`replaceAll('أ', 'ا')` before NFKC.

**The invisible marks go too.** U+200C–U+200F are in the contract's character reference but not in
§9.4's numbered list. They are deleted here because a ZWJ or an RLM pasted from a bidi-formatted PDF sits
inside a word and makes an otherwise identical string a different key. They cannot be seen in a diff, in
a review or in a test failure message, which is exactly why they must not survive into a key.

**Alef maqsura is folded here, in step 6, and not deleted in T04.** `SPEC.md` §9.4 step 4 groups `ى` with
`ة` and `ه` as word-final forms to collapse; the contract splits it, folding `ى` → `ي` at step 6 and
deleting only `ة` and `ه` at step 7. The contract's split is the correct one and §9.1 is the evidence:
two of the five headline Gulf species it names, `شعري` and `صافي`, end in `ي`. Word-final `ي` is never
deleted — deleting it would merge `شعري` with `شعر`. So if word-final `ى` were deleted instead of folded,
an Egyptian-style spelling `شعرى` and the Gulf spelling `شعري` would land on two different keys, which is
the exact split the contract's step 6 exists to close. T04 carries the full argument; T03 owns the line
of code.

**Escapes, not literals.** Every character class is written with `\u` escapes. A literal harakat or a
literal ZWNJ in Dart source is invisible in a diff and in a review, and a reviewer cannot approve what
they cannot see. This also keeps every Arabic character class inside `normalise.dart`, which is what
check 4 of `check_rule_engine.sh` requires.

**Rejected: script detection.** Branching on "does this string contain Arabic" before running the Arabic
steps. It buys nothing measurable — the steps are `replaceAll` calls that do not match — and it adds a
branch the 100% branch-coverage target then has to cover with a synthetic input. The contract is one
ordered pipeline over the whole string; step 5 of the Latin table (`Hamour` → `hamour`) and the Arabic
steps run over the same characters without interfering.

**Rejected: folding `ه` to `ة` or vice versa anywhere in these steps.** That is T04's territory and
§9.4 records that the first draft got it wrong. Doing it here, globally, would delete a medial `ه`.

**Rejected: `unicode: true` with `\p{...}` property escapes.** Not needed for these steps, and its
behaviour on the D-5 toolchain has not been verified here. Explicit code-point ranges are unambiguous
and reviewable.

## Tests first

Write every row before touching `normalise.dart`. Run them. **They must fail.** If one passes now the
test is wrong — the most likely cause is a test whose input is already canonical, so check that the
Presentation-Form inputs really differ from their expected output before doing anything else.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `normaliseSpeciesTerm folds an Arabic Presentation Form to its canonical letter` | `'ﻩﺍﻡﻭﺭ'` | `هامور` | The §9.4 step 1 headline: a naive PDF text extraction of `هامور` emits isolated Presentation Forms |
| 2 | `normaliseSpeciesTerm treats a Presentation-Form paste and typed Arabic as one key` | as above, vs `هامور` | equal | States the property rather than the transform. This is the assertion T07 relies on |
| 3 | `normaliseSpeciesTerm runs NFKC before the alef fold` | `'ﺃ'` | `ا` (U+0627) | The recorded correction, isolated to one character. If the alef fold ran first it would not match U+FE83 and the output would not be a plain alef |
| 4 | `normaliseSpeciesTerm strips tatweel` | `هــامور` | `هامور` | Contract step 2, and a row of the §9.4 acceptance table T07 asserts end to end |
| 5 | `normaliseSpeciesTerm strips harakat` | `'هَامُور'` | `هامور` | Contract step 3. A voweled paste from a PDF is the symptom row "a voweled paste from a PDF misses" |
| 6 | `normaliseSpeciesTerm strips the superscript alef` | a term carrying U+0670 | the term without it | U+0670 sits outside the U+064B–U+0652 run, so a single-range implementation passes test 5 and fails this one |
| 7 | `normaliseSpeciesTerm folds "$form" to plain alef` (loop over U+0622, U+0623, U+0625, U+0671) | each form + `مور` | `امور` | Contract step 4, one behaviour per form. Interpolated per `CONVENTIONS.md` §5 so `--plain-name` can select one |
| 8 | `normaliseSpeciesTerm folds hamza-on-waw to waw` | a term with U+0624 | the same term with U+0648 | Contract step 5. Hamza placement is unstable across sources and keyboards |
| 9 | `normaliseSpeciesTerm folds hamza-on-ya to ya` | a term with U+0626 | the same term with U+064A | Contract step 5, the other carrier. Named explicitly in §9.4 step 3 |
| 10 | `normaliseSpeciesTerm folds alef maqsura to ya` | `شعرى` | `شعري` | Contract step 6. Gulf and Egyptian typing of the same name must land together — the argument in "Why it is built this way" |
| 11 | `normaliseSpeciesTerm deletes the zero-width and bidi marks` | `'ه‌امور'` | `هامور` | Contract character reference. An invisible character is invisible in the diff too, so only a test finds it |
| 12 | `normaliseSpeciesTerm keeps هامور and شعري on different keys` | both | not equal | The over-merge guard. Steps 4–6 are lossy on purpose and this is the cheap proof they are not lossy enough to merge two species §9.1 names |
| 13 | `normaliseSpeciesTerm is idempotent for an Arabic term` | `هامور` folded twice | `هامور` | The builder folds once at build time, the app folds again at query time; a non-idempotent step drifts the two |
| 14 | `normaliseSpeciesTerm folds a mixed Arabic and Latin string` | `هامور Epinephelus` | `هامور epinephelus` | Proves T02's Latin steps still run after the Arabic ones were inserted above them — the regression this insertion could cause |

```dart
// packages/rule_engine/test/search/normalise_arabic_fold_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

/// `هامور` as a naive PDF text extraction emits it: isolated Presentation Forms-B.
/// Heh U+FEE9, alef U+FE8D, meem U+FEE1, waw U+FEED, reh U+FEAD.
const _hamourPresentationForms = 'ﻩﺍﻡﻭﺭ';

/// The same word as an Arabic keyboard produces it.
const _hamourTyped = 'هامور'; // هامور

void main() {
  group('normaliseSpeciesTerm', () {
    test('folds an Arabic Presentation Form to its canonical letter', () {
      expect(_hamourPresentationForms, isNot(_hamourTyped),
          reason: 'the input must really be in Presentation Forms');
      expect(normaliseSpeciesTerm(_hamourPresentationForms), _hamourTyped);
    });

    test('runs NFKC before the alef fold', () {
      // U+FE83 is ALEF WITH HAMZA ABOVE, isolated form. The alef fold's class
      // does not contain it, so this can only pass if NFKC ran first.
      expect(normaliseSpeciesTerm('ﺃ'), 'ا');
    });

    test('deletes the zero-width and bidi marks', () {
      expect(normaliseSpeciesTerm('ه‌امور'), _hamourTyped);
    });

    for (final form in const ['آ', 'أ', 'إ', 'ٱ']) {
      test('folds "$form" to plain alef', () {
        expect(normaliseSpeciesTerm('$formمور'), 'امور');
      });
    }

    test('keeps هامور and شعري on different keys', () {
      expect(normaliseSpeciesTerm('هامور'), isNot(normaliseSpeciesTerm('شعري')));
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `(cd packages/rule_engine && dart test test/search/normalise_arabic_fold_test.dart)` → 17
failures (14 rows, with row 7 expanding to four). If any passes now, the test is wrong.

## Implementation outline

1. Verify every Presentation-Form code point in the test file against Unicode Presentation Forms-B before
   running anything — the chart `catchlaw-rule-engine/SKILL.md` names in its References. A wrong code
   point makes the test fail rather than silently pass, because the expectation is the canonical string,
   but it costs a debugging cycle to work that out from the failure message.
2. In `normalise.dart`, insert the NFKC call as the **first** statement of `normaliseSpeciesTerm`, above
   everything T02 wrote.
3. Add the deletions and folds in the contract's order, each one line, each with a trailing comment giving
   the code points in prose (`// U+0640 tatweel — a typographic stretch, never a letter`).
4. Keep the character classes as `\u` escapes. Do not add a second file: check 4 of
   `check_rule_engine.sh` excludes only `normalise.dart`, and a second file carrying an Arabic class is
   reported as a drifting normaliser.
5. Extend the doc comment on `normaliseSpeciesTerm` with one sentence stating that the order is a
   contract shared with `tools/content_builder/`, and cite `SPEC.md` §9.4. Do not restate the steps.
6. Re-run the whole suite. All new tests green and every T01 and T02 test still green — test 14 is the one
   that catches an insertion made in the wrong place.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 tests pass, and each failed first.
- [ ] Branch coverage on `normalise.dart` is 100%.
- [ ] The NFKC call is the first statement in the function body, with nothing above it.
- [ ] Every Arabic character class in the package is inside `normalise.dart`, written with `\u` escapes.
- [ ] `normaliseSpeciesTerm` has the same signature it had after T02.
- [ ] `packages/rule_engine/` still imports nothing from Flutter and nothing from `intl`.
- [ ] The steps appear in the file in the contract's numbered order, so the file diffs against the prose.

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
feat(rule_engine): run NFKC first, then strip tatweel and harakat and fold the letter families

The Gulf legal text is transcribed from gazette PDFs (SPEC §8), and a naive
text extraction of those PDFs emits Arabic Presentation Forms rather than
letters. Fold the alef family before NFKC and the class never matches, the
Presentation Form survives into the key, Latin search keeps working and
Arabic search silently returns nothing. So NFKC is the first statement in
the function and a test pins a Presentation-Form paste of هامور to the same
key as the typed word.

Alef maqsura is folded onto ya here rather than deleted word-finally in the
next task: SPEC §9.1 names شعري and صافي, and a word-final ya is never
deleted, so deleting a word-final ى would split the Egyptian spelling of a
name from the Gulf one.

Every character class is a \u escape. An invisible character is invisible in
review too.

Task: E02/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
