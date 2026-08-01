# TEMPLATE.md — the shape of an `epic.md` and a task file

Two worked examples. Copy the structure, not the content. Every heading below is mandatory; a section
with nothing to say means the task is under-specified, not that the section is optional.

---

# Part A — `epic.md`

````markdown
# E02 — Rule engine: text normalisation

| | |
|---|---|
| **Branch** | `epic/02-normalisation` |
| **After** | E01 merged |
| **Tasks** | 8 |
| **Spec** | `SPEC.md` §9.4, §4.1 (local-name search), §13 (search latency) |
| **Package** | `packages/rule_engine/` |

## What this epic achieves

One paragraph, concrete, in the product's terms rather than the code's. What is true when this merges
that was not true before — and what a user could do, or what a later epic can now rely on.

## Where we are now

The state at the moment the branch is cut. What exists, what does not, and which earlier epic put it
there. Name the files that already exist. If a prior epic left a known gap this epic closes, say so.

## Why this epic exists here in the order

Why it cannot come earlier and must not come later. Cite the dependency, not the convenience.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | Package skeleton and the zero-Flutter proof | `T01-package-skeleton.md` | S | — |
| T02 | Latin fold — NFD, strip marks, lowercase | `T02-latin-fold.md` | S | T01 |
| … | | | | |

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable at the epic level:

- [ ] All 8 tasks committed, one commit each, every `Task:` trailer present.
- [ ] `dart test` green in `packages/rule_engine/`, 100% branch coverage on `src/normalise/`.
- [ ] The §9.4 acceptance test passes on all five inputs.
- [ ] `packages/rule_engine/` has zero `package:flutter` imports — proved by its pubspec, not by grep.
- [ ] `check_rule_engine.sh packages/rule_engine/lib` clean.
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin`; branch deleted.

## Risks and the things that will bite

Specific, named, with the mitigation. Not "this might be hard".

## PR description

The body to paste into `gh pr create`. Written now, while the reasoning is fresh:

### What changed
### Why
### How it was verified
### Product invariants touched
### Follow-ups deliberately not in this PR

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start the next epic.
````

---

# Part B — a task file

This is a complete example, not a skeleton. A task file that is shorter than this one is probably
missing the reasoning that makes it executable by someone who was not in the room.

````markdown
# E02/T04 — Collapse the Arabic word-final forms

| | |
|---|---|
| **Epic** | E02 — Rule engine: text normalisation |
| **Branch** | `epic/02-normalisation` (shared) |
| **Commit** | `feat(rule_engine): collapse Arabic word-final ta marbuta, ha and alef maqsura` |
| **Depends on** | T03 (alef/waw/ya unification must already run) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.4 step 4 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Owns `references/normalisation-contract.md` — the ordered fold and the property every step must preserve |
| `catchlaw-conventions-index` | Invariant 6, the one-way layer map: this is pure Dart and may not reach for Flutter |
| `dart3-idioms-and-coding-standards` | Function length, pattern matching over the code-unit switch |
| `testing-strategy` | Which level this belongs at — pure unit, no widget binding |
| `naming-conventions` | The function and test names below |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.4 "Arabic, in order" step 4 | The exact rule, and the first draft's bug it exists to fix |
| `.claude/skills/catchlaw-rule-engine/references/normalisation-contract.md` | whole | The contract the app and the builder share |
| `.claude/skills/catchlaw-rule-engine/examples/species_normalisation.dart` | whole | The worked shape — do not diverge from it silently |
| `FLUTTER_GUIDE.md` | §6.1 | Test naming with receipts |
| `epics/DECISIONS.md` | D-7 | The engine holds no user-visible string |

## What this delivers

- `packages/rule_engine/lib/src/normalise/arabic_fold.dart` — the `_collapseTerminals` step, wired
  into the ordered fold after alef unification.
- `packages/rule_engine/test/normalise/arabic_fold_terminals_test.dart`.
- No public API change: `normaliseArabic` keeps its signature.

## Why it is built this way

`SPEC.md` §9.4 records that the first draft folded `ة` → `ه`, producing `هاموره` from `هامورة`. That
string is neither equal to nor a **prefix of** `هامور`, which is what a user types. Because search is a
prefix query over an indexed `search_norm` column (§13, < 50 ms at 2,400 names), losing the prefix
property does not merely rank a result lower — it removes it from the result set entirely. The spec's
own acceptance test could not have passed.

So the three word-final forms `ة`, `ه` and `ى` collapse to **nothing** at the end of a word rather than
to a shared letter. `هامورة` → `هامور`, `هامور` → `هامور`, and the prefix property holds.

**Word-final only.** `ه` is a common medial letter; deleting it everywhere would fold unrelated
species together. The step is anchored to a word boundary, and a test asserts a medial `ه` survives.

**Rejected:** running this before alef unification. `ى` and `ي` interact — the order in §9.4 is a
contract, and `normalisation-contract.md` states the fold is ordered and shared with the content
builder. A different order in the two places produces a database whose keys the app cannot reproduce.

## Tests first

Write every row before touching `arabic_fold.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ArabicFold.normalise strips word-final ta marbuta` | `هامورة` | `هامور` | The §9.4 headline case |
| 2 | `ArabicFold.normalise leaves a bare stem unchanged` | `هامور` | `هامور` | Idempotence with case 1 — both must land on one key |
| 3 | `ArabicFold.normalise strips word-final alef maqsura` | `سلوى` | `سلو` | The third terminal form |
| 4 | `ArabicFold.normalise keeps a medial ha` | `شهري` | `شهري` | The over-fold guard: medial `ه` must survive |
| 5 | `ArabicFold.normalise strips a terminal form in each word of a phrase` | `سمكة كبيرة` | `سمك كبير` | Word-final means every word, not the string's last character |
| 6 | `ArabicFold.normalise is idempotent` | `هامورة` folded twice | `هامور` | A fold applied twice by the builder and the app must not drift |
| 7 | `ArabicFold.normalise runs after alef unification` | `أهامورة` | `اهامور` | Order is part of the contract (T03 + this task together) |
| 8 | `ArabicFold.normalise leaves an empty string empty` | `''` | `''` | The boundary the regex will get wrong first |

```dart
// packages/rule_engine/test/normalise/arabic_fold_terminals_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('ArabicFold', () {
    test('.normalise strips word-final ta marbuta', () {
      expect(normaliseArabic('هامورة'), 'هامور');
    });

    test('.normalise keeps a medial ha', () {
      expect(normaliseArabic('شهري'), 'شهري');
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `dart test test/normalise/arabic_fold_terminals_test.dart` → 8 failures. If any passes now,
the test is wrong.

## Implementation outline

1. Add `_collapseTerminals(String)` to `arabic_fold.dart`, private.
2. Anchor on a word boundary that is correct for Arabic — `\b` is defined on ASCII word characters and
   will not do. Match a terminal form followed by end-of-string or a non-letter.
3. Insert the call into the ordered fold, **after** alef unification and **before** article stripping.
4. Re-run the suite. All 8 green, and every earlier normalisation test still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 8 tests pass, and each failed first.
- [ ] Branch coverage on `arabic_fold.dart` is 100%.
- [ ] `normaliseArabic` has the same signature it had before this task.
- [ ] `packages/rule_engine/` still imports nothing from Flutter.
- [ ] The identical function is what `tools/content_builder/` calls — not a copy (E04/T07 depends on it).

## Gates

```bash
cd packages/rule_engine && dart format --set-exit-if-changed . && dart analyze && dart test
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
feat(rule_engine): collapse Arabic word-final ta marbuta, ha and alef maqsura

Folding ة to ه produced هاموره, which is neither equal to nor a prefix of
هامور — so a prefix search for what a user actually types could never reach
the species. The three terminal forms now collapse to nothing at a word
boundary, and a medial ه is left alone.

Task: E02/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
````

---

## What makes a task file good

- **The "why" section names what was rejected.** A task that only says what to build will be built
  differently by the next person who reads it.
- **Every test row has a reason.** "Why this case exists" is the column that stops a test being
  deleted the first time it fails.
- **It cites, never restates.** Point at `SPEC.md` §9.4 rather than re-typing the rule; the two copies
  will disagree within a month.
- **It is executable by someone with no context.** No "as discussed", no "the usual pattern".
- **Numbers are real.** `< 50 ms at 2,400 names`, `100% branch coverage`, `8 tests` — not "fast" and
  "well tested".
