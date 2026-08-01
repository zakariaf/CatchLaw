# E02/T02 — The Latin fold: NFD, strip combining marks, lowercase

| | |
|---|---|
| **Epic** | E02 — Rule engine: text normalisation |
| **Branch** | `epic/02-normalisation` (shared) |
| **Commit** | `feat(rule_engine): fold Latin diacritics and case into one search key` |
| **Depends on** | T01 (the package and its barrel must exist) |
| **Size** | S |
| **Spec** | `SPEC.md` §9.4 "Latin", §7.1 (`species_name.search_norm`) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 10 fixes the function's name and its home: `normaliseSpeciesTerm` in `lib/src/search/normalise.dart`, one function, both directions |
| `catchlaw-conventions-index` | Rule 10 — a general rule is never forked into an app skill, which is why the function keeps the skill's name even though it also folds `legal_text.body_norm` |
| `dart3-idioms-and-coding-standards` | Function length, `final` locals, and whether a step is a private helper or an inline line |
| `dartdoc-conventions` | `public_member_api_docs` is on for this package (`FLUTTER_GUIDE.md` §4.3); `normaliseSpeciesTerm` needs a real doc comment |
| `naming-conventions` | `normaliseSpeciesTerm` is an imperative verb phrase because the work is the point (`FLUTTER_GUIDE.md` §3.2) |
| `testing-strategy` | Pure unit level, no binding, no fixtures beyond string literals |
| `dependency-hygiene` | This task adds the first real dependency of the package; it must clear the §14 allowlist |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.4 "Latin" | The exact rule: NFD, strip combining marks (`ñ`→`n`, `ç`→`c`, `ã`→`a`, `á`→`a`), lowercase; and which locales need it |
| `SPEC.md` | §9.1 | Why `gl`, `ca`, `es` and `pt_BR` are shipping locales at all — the fold has four customers, not one |
| `SPEC.md` | §14 static block | The direct-dependency allowlist the new dependency must be added to |
| `.claude/skills/catchlaw-rule-engine/references/normalisation-contract.md` | Steps 9 and 10; "Latin and scientific names"; "What normalisation is NOT" | The fold's position in the ordered pipeline, the Latin key table, and the ban on locale-sensitive casing |
| `.claude/skills/catchlaw-rule-engine/examples/species_normalisation.dart` | whole | The worked shape of `normaliseSpeciesTerm` — do not diverge from it silently |
| `FLUTTER_GUIDE.md` | §3.2, §3.4, §3.6 | Verb-phrase naming, doc-comment opening, when to annotate |
| `FLUTTER_GUIDE.md` | §6.1 | Test naming with receipts |
| `epics/DECISIONS.md` | D-3 | The six locales; four of them need this fold |

## What this delivers

- `packages/rule_engine/lib/src/search/normalise.dart` — new file, holding
  `String normaliseSpeciesTerm(String input)` with the Latin half of the fold and the whitespace step.
- `packages/rule_engine/lib/rule_engine.dart` — one `export 'src/search/normalise.dart';` line added.
- `packages/rule_engine/test/search/normalise_latin_test.dart`.
- `packages/rule_engine/pubspec.yaml` — one added dependency: a pure-Dart Unicode normalisation
  implementation supplying NFD (and, from T03, NFKC).
- One line added to the §14 direct-dependency allowlist E01 checked in.

## Why it is built this way

**The Dart SDK does not normalise Unicode.** `dart:core` offers neither NFD nor NFKC, and §9.4 needs
both. There are two honest ways forward and this task takes the first:

1. **Depend on a pure-Dart Unicode normalisation package.** Selection criteria, all four required: pure
   Dart with no `flutter` dependency (`catchlaw-rule-engine` rule 2); no `dart:io` and no transitive
   networking edge (invariant 1, `SPEC.md` §14); implements NFD and NFKC over the full Unicode range, not
   a Latin subset; currently published and resolvable on the D-5 toolchain. Resolve it with `dart pub add`
   at execution time, read its `pubspec.yaml`, and **record the resolved name and version in this
   commit's body**. No version is written into this plan, because none has been verified here.
2. **Fallback, only if nothing clears those criteria:** generate a decomposition table restricted to
   Latin-1 Supplement, Latin Extended-A and Arabic Presentation Forms A and B. If that path is taken the
   function is named for what it does — never `nfkc` — because a partial NFKC that calls itself NFKC is
   exactly how the app's fold and the builder's fold come to disagree while both look correct.

**Invariant lowercase, never locale-sensitive.** The contract's "What normalisation is NOT" table is
explicit: use `String.toLowerCase()`, and never a locale-aware casing from `intl`. The Turkish dotless
`ı` is a real hazard, and a search key whose value depends on the device locale is a key the builder
cannot reproduce.

**Latin last, whitespace after it.** The contract numbers the Latin fold step 9 and the whitespace
collapse step 10, and NFKC is step 1. This task therefore writes the function with its two steps at the
**bottom**, leaving room above them for T03 to T06 to insert steps 1 to 8 in order. The file reads
top-to-bottom in the same order the contract lists, so a reviewer can diff prose against code.

**The name says "species" and the function also folds legal text.** `SPEC.md` §7.1 records that
`legal_text.body_norm` *"carries the same fold as `species_name.search_norm`"*, so `normaliseSpeciesTerm`
is doing more than its name says. The name is kept anyway: `catchlaw-rule-engine` rule 10 fixes it, and
`catchlaw-conventions-index` rule 10 forbids forking a rule that already exists somewhere. Renaming it
here would leave the skill, the worked example and the code disagreeing in front of the next reader.

**Rejected: one public function per script.** `normaliseLatin` and `normaliseArabic` as separate exported
functions would let a caller pick one — and a caller who picks wrong produces a key nothing matches. The
contract is a single ordered pipeline over the whole string; script detection is not one of its steps.
Arabic and Latin text pass through every step, and steps that do not apply are no-ops.

**Rejected: stripping punctuation.** `Orange-spotted grouper` keeps its hyphen. The fold folds
orthography; it does not tokenise. Tokenising belongs to FTS5 (`SPEC.md` §7.1, `unicode61`), which is
E15's problem, and a hyphen removed here would make the app's key differ from the FTS tokeniser's for no
gain.

## Tests first

Write every row before creating `normalise.dart`. Run them. **They must fail** — the import will not
resolve, which is the correct first failure. If any passes now, the test is wrong: check it is not
asserting a string against itself.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `normaliseSpeciesTerm folds n-tilde to n` | `Señorita` | `senorita` | The `ñ`→`n` case §9.4 names; `señorita` is a shipping-locale vernacular name, so this is real content and not a lab string |
| 2 | `normaliseSpeciesTerm folds c-cedilla and a-tilde to c and a` | `Cação` | `cacao` | Two of the four characters §9.4 names, in one authored `pt_BR` name — the locale D-3 keeps as `pt_BR`, not `pt` |
| 3 | `normaliseSpeciesTerm folds a-acute to a` | `Sábalo` | `sabalo` | The fourth character §9.4 names, from `es` |
| 4 | `normaliseSpeciesTerm folds e-acute to e` | `Nécora` | `necora` | Galician. §9.1 makes `gl` a shipping locale because the Xunta publishes its size tables in it; the fold has to cover its accents too |
| 5 | `normaliseSpeciesTerm lowercases a scientific name` | `EPINEPHELUS COIOIDES` | `epinephelus coioides` | The contract's Latin table. Scientific names arrive from the Catalogue of Life in mixed case and from users in any case |
| 6 | `normaliseSpeciesTerm collapses a run of spaces to one` | `epinephelus  coioides` | `epinephelus coioides` | Contract step 10, and a row of the §9.4 acceptance table T07 will assert end to end. OCR loves double spaces |
| 7 | `normaliseSpeciesTerm trims leading and trailing whitespace` | `'  hamour '` | `hamour` | A paste out of a PDF carries both, and an untrimmed key is a key nothing matches |
| 8 | `normaliseSpeciesTerm keeps an internal hyphen` | `Orange-spotted grouper` | `orange-spotted grouper` | Contract Latin table. The over-fold guard: this is a fold, not a tokeniser |
| 9 | `normaliseSpeciesTerm maps a precomposed and a decomposed a-acute to one key` | `Sábalo` vs `Sábalo` | equal, and both `sabalo` | Proves NFD actually ran — the second input carries U+0061 followed by U+0301, not U+00E1. A lookup table of precomposed characters passes tests 1–4 and fails this one |
| 10 | `normaliseSpeciesTerm is idempotent for a Latin term` | `Ameixa babosa` folded twice | `ameixa babosa` | The builder folds at build time and the app folds at query time; a non-idempotent step makes a rebuilt database drift from the running app |
| 11 | `normaliseSpeciesTerm returns an empty string when the input is empty` | `''` | `''` | The boundary the trim-and-collapse code gets wrong first |
| 12 | `normaliseSpeciesTerm returns an empty string when the input is only whitespace` | `'   '` | `''` | Distinct from 11: this one exercises the collapse *and* the trim, and it is what an accidental space-bar press sends from the search field |

```dart
// packages/rule_engine/test/search/normalise_latin_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('normaliseSpeciesTerm', () {
    test('folds n-tilde to n', () {
      expect(normaliseSpeciesTerm('Señorita'), 'senorita');
    });

    test('folds c-cedilla and a-tilde to c and a', () {
      expect(normaliseSpeciesTerm('Cação'), 'cacao');
    });

    test('keeps an internal hyphen', () {
      expect(normaliseSpeciesTerm('Orange-spotted grouper'), 'orange-spotted grouper');
    });

    test('maps a precomposed and a decomposed a-acute to one key', () {
      const precomposed = 'S\u00E1balo'; // a-acute as one code point
      const decomposed = 'Sa\u0301balo'; // a + combining acute
      expect(precomposed, isNot(decomposed), reason: 'the inputs must genuinely differ');
      expect(normaliseSpeciesTerm(precomposed), normaliseSpeciesTerm(decomposed));
      expect(normaliseSpeciesTerm(decomposed), 'sabalo');
    });

    test('is idempotent for a Latin term', () {
      final once = normaliseSpeciesTerm('Ameixa babosa');
      expect(normaliseSpeciesTerm(once), once);
      expect(once, 'ameixa babosa');
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `(cd packages/rule_engine && dart test test/search/normalise_latin_test.dart)` → 12 failures.
If any passes now, the test is wrong.

## Implementation outline

1. Choose the normalisation dependency against the four criteria above. Add it with `dart pub add`, then
   open its `pubspec.yaml` and confirm no `flutter` and no networking package in its own dependencies.
   Add it to the §14 direct-dependency allowlist in the same commit.
2. Create `packages/rule_engine/lib/src/search/normalise.dart`. Write `normaliseSpeciesTerm(String input)`
   with a doc comment that opens with a third-person verb (`FLUTTER_GUIDE.md` §3.4), states that the
   content builder and the runtime query both call it, and points at `SPEC.md` §9.4 rather than restating
   the steps.
3. Implement, in this order, leaving a comment marking where steps 1–8 will be inserted by T03–T06:
   - NFD the whole string;
   - delete combining marks `[̀-ͯ]`;
   - `toLowerCase()` with no locale argument;
   - collapse `\s+` to a single space and `trim()`.
   Use `\u` escapes for the combining-mark range: a literal combining mark in source is invisible and
   therefore unreviewable.
4. Add `export 'src/search/normalise.dart';` to `lib/rule_engine.dart`, under the library doc comment.
5. Update T01's "lib holds exactly one barrel" expectation only if it needs it — it should not; the new
   file is two directories down and the assertion is on top-level `lib/*.dart` only.
6. Re-run the whole suite. All 12 new tests green and T01's 7 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 tests pass, and each failed first.
- [ ] Branch coverage on `normalise.dart` is 100% (there are no branches in it yet — this is the baseline
      the later tasks must hold).
- [ ] The new dependency's name and resolved version are named in the commit body, and it appears on the
      §14 direct-dependency allowlist.
- [ ] The new dependency pulls in no `flutter`, no `dart:io` and no networking package — checked by
      reading `dart pub deps --style=compact`, not assumed.
- [ ] `normaliseSpeciesTerm` has a doc comment; the file has no other public member.
- [ ] `packages/rule_engine/` still imports nothing from Flutter, and T01's guard test still passes.
- [ ] The Latin steps sit at the **bottom** of the function, with a marker comment for steps 1–8.

## Gates

Run from the repository root.

```bash
dart format --set-exit-if-changed packages/rule_engine
dart analyze packages/rule_engine
(cd packages/rule_engine && dart test)
dart pub deps --style=compact
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
feat(rule_engine): fold Latin diacritics and case into one search key

Galician, Catalan, Spanish and Portuguese all publish their species names
with accents the fisher will not type, so ñ ç ã á fold away through NFD and
a combining-mark strip rather than through a table of precomposed letters —
a table passes the four cases SPEC §9.4 names and fails a decomposed paste.
Lowercasing is invariant, never locale-aware: a key whose value depends on
the device locale is a key the content builder cannot reproduce.

The Dart SDK ships no Unicode normalisation, so this commit adds the first
dependency of the package and puts it on the §14 allowlist.

Task: E02/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
