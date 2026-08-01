# E02/T06 — Digits to ASCII, on both sides of the search

| | |
|---|---|
| **Epic** | E02 — Rule engine: text normalisation |
| **Branch** | `epic/02-normalisation` (shared) |
| **Commit** | `feat(rule_engine): map Arabic-Indic and Eastern Arabic-Indic digits to ASCII` |
| **Depends on** | T05 (the fold is complete except for this step; `indexKeys` must already exist to assert both sides) |
| **Size** | S |
| **Spec** | `SPEC.md` §9.4 "Arabic, in order" step 6 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 10 lists the digit map as the last step of the one sanctioned function; the contract's step 8 gives the two ranges |
| `catchlaw-conventions-index` | Rule 6: this maps digits for **keys**, never for display. Numeral rendering for the user belongs to the app layer and to `i18n-rtl-l10n` |
| `dart3-idioms-and-coding-standards` | `replaceAllMapped` with a code-unit offset versus a ten-entry map; which one the complexity numbers prefer |
| `naming-conventions` | The private step name, and the loop-test descriptions |
| `testing-strategy` | Parameterised tests: one behaviour per digit, with the parameter interpolated |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.4 "Arabic, in order" step 6 | The exact rule and the two ranges: U+0660–0669 and U+06F0–06F9 |
| `SPEC.md` | §9.3 "Numerals — corrected twice" | Why this is a **key** transform and not a display one: what the user reads is decided by `numberFormatSymbols` at bootstrap, not here |
| `.claude/skills/catchlaw-rule-engine/references/normalisation-contract.md` | Pipeline step 8; "Character reference"; "What normalisation is NOT" | The two ranges, and the row that puts numeral rendering for the user in `i18n-rtl-l10n` |
| `.claude/skills/catchlaw-rule-engine/examples/species_normalisation.dart` | the two `replaceAllMapped` lines and the `٣٨` assertion | The worked shape and one concrete expected value |
| `FLUTTER_GUIDE.md` | §6.1 | *"For loop-generated tests, always interpolate the parameter into the description"* |
| `epics/CONVENTIONS.md` | §5 | The same rule, stated as house law |

## What this delivers

- `packages/rule_engine/lib/src/search/normalise.dart` — the digit map, inserted at contract position 8:
  after the terminal collapse of T04 and before the Latin fold T02 left at the bottom.
- `packages/rule_engine/test/search/normalise_digits_test.dart`.
- No public API change.

| Range | Name | Maps to |
|---|---|---|
| U+0660–U+0669 | Arabic-Indic digits `٠١٢٣٤٥٦٧٨٩` | ASCII `0`–`9` |
| U+06F0–U+06F9 | Extended (Eastern) Arabic-Indic digits `۰۱۲۳۴۵۶۷۸۹` | ASCII `0`–`9` |

## Why it is built this way

**Two ranges, one target, because both are typed.** The contract's character reference lists them
separately and its step 8 gives the reason: *"zone codes and sizes are typed in either numeral set"*. A
device configured for Persian or Urdu digit entry produces U+06F0–06F9 even for Arabic text — neither is
a shipping locale (D-3), but a keyboard is not a locale — and the two
ranges are visually near-identical for several digits. Mapping only the first range passes every test
written with `٣٨` and fails silently on a keyboard nobody tested.

**Both directions, and that is the sentence in §9.4.** Step 6 says the map applies to the index and the
query. It comes free here: both sides call `normaliseSpeciesTerm`, so a digit typed in either numeral set
lands on the same key as the digit the builder wrote. T08 makes that symmetry an explicit test over the
whole corpus; this task asserts it once, at the smallest scale, so the property is pinned before the
corpus exists.

**This is a key transform and never a display one.** `SPEC.md` §9.3 records that the numeral system the
user *sees* is decided by swapping an entry in `intl`'s `numberFormatSymbols` map at bootstrap, process-
wide and order-dependent, and that it has nothing to do with the search key. The contract's "What
normalisation is NOT" table puts numeral rendering for the user in `i18n-rtl-l10n`. Nothing in this
package ever formats a number a person reads — D-7 again, from a different angle.

**Rejected: `int.parse` per character, or a `Map<String, String>` of twenty entries.** The code-unit
offset is what the worked example does — `m[0]!.codeUnitAt(0) - 0x0660` — and it is both shorter and
impossible to get half-right by typing nineteen of twenty rows correctly. The twenty-entry map is the
version where one row has a typo nobody sees.

**Rejected: mapping the Arabic decimal separator U+066B and the thousands separator U+066C.** They are
punctuation inside a formatted number, not digits, and §9.4 step 6 names only the two digit ranges. A
species search key never contains a formatted number; a rule note that does is display text, which this
package does not hold.

**Rejected: widening the class to "any Unicode decimal digit".** It would silently swallow Devanagari and
Thai digits, which appear in no shipping locale (D-3) and whose presence in a key would mean something
went wrong upstream. An explicit range is a boundary a test can sit on.

## Tests first

Write every row before touching `normalise.dart`. Run them. **They must fail.** If one passes now, the
test is wrong — check the input really contains the Arabic-Indic code point and not an ASCII digit that
looks like one in the editor.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `normaliseSpeciesTerm maps Arabic-Indic "٠" to "0"` … through `"٩"` to `"9"` (loop, 10 cases) | each of U+0660–U+0669 | the ASCII digit | One behaviour per digit, parameter interpolated per `CONVENTIONS.md` §5, so `--plain-name` selects one. A ten-case loop is the only way an off-by-one inside the range is visible |
| 2 | `normaliseSpeciesTerm maps Eastern Arabic-Indic "۰" to "0"` … through `"۹"` to `"9"` (loop, 10 cases) | each of U+06F0–U+06F9 | the ASCII digit | The second range, which a single-range implementation passes row 1 without |
| 3 | `normaliseSpeciesTerm maps a multi-digit Arabic-Indic number` | `٣٨` | `38` | The worked example's own assertion. Multi-digit is where a per-character map that forgets to be global fails |
| 4 | `normaliseSpeciesTerm leaves an ASCII digit unchanged` | `45` | `45` | The no-op case. A map that subtracts an offset unconditionally corrupts this one |
| 5 | `normaliseSpeciesTerm maps digits inside an Arabic phrase` | `المنطقة ٣` | `المنطق 3` | A real shape: a zone code. It also asserts the digit map runs **after** T04's terminal collapse, since `ة` is gone |
| 6 | `normaliseSpeciesTerm leaves the Arabic percent sign unchanged` | `٪` | `٪` | U+066A sits immediately above the Arabic-Indic range. An off-by-one on the upper bound silently corrupts a percentage; this is the boundary test that catches it |
| 7 | `normaliseSpeciesTerm leaves the Arabic-Indic range's lower neighbour unchanged` | U+065F | U+065F | The other end of the same boundary. U+065F ARABIC WAVY HAMZA BELOW is not a digit and must survive the subtraction. It also deliberately survives T03: the contract's harakat range is U+064B–U+0652 plus U+0670, and U+065F is in neither |
| 8 | `normaliseSpeciesTerm maps the two numeral sets onto one key` | `٥` and `۵` | equal, and both `5` | The point of having two ranges: a Persian-keyboard five and an Arabic-keyboard five are the same key |
| 9 | `indexKeys maps digits on the query side as well as the index side` | `٣٨` and `38` | share a key | §9.4 step 6 says "in both the index and the query", and `indexKeys` is what both sides call |

```dart
// packages/rule_engine/test/search/normalise_digits_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('normaliseSpeciesTerm', () {
    for (var d = 0; d < 10; d++) {
      final arabicIndic = String.fromCharCode(0x0660 + d);
      test('maps Arabic-Indic "$arabicIndic" to "$d"', () {
        expect(normaliseSpeciesTerm(arabicIndic), '$d');
      });
    }

    for (var d = 0; d < 10; d++) {
      final eastern = String.fromCharCode(0x06F0 + d);
      test('maps Eastern Arabic-Indic "$eastern" to "$d"', () {
        expect(normaliseSpeciesTerm(eastern), '$d');
      });
    }

    test('leaves the Arabic percent sign unchanged', () {
      expect(normaliseSpeciesTerm('٪'), '٪');
    });

    test('maps the two numeral sets onto one key', () {
      expect(normaliseSpeciesTerm('٥'), normaliseSpeciesTerm('۵'));
      expect(normaliseSpeciesTerm('٥'), '5');
    });

    // … one test per row above, one behaviour each
  });

  group('indexKeys', () {
    test('maps digits on the query side as well as the index side', () {
      expect(indexKeys('٣٨').toList(), indexKeys('38').toList());
    });
  });
}
```

**Run:** `(cd packages/rule_engine && dart test test/search/normalise_digits_test.dart)` → 27 failures
(9 rows, with rows 1 and 2 expanding to ten each). If any passes now, the test is wrong.

## Implementation outline

1. Add the two `replaceAllMapped` calls to `normalise.dart` at contract position 8 — after the terminal
   collapse, before the Latin fold. Use the code-unit offset form the worked example uses, with the range
   written as `\u` escapes.
2. Give each line a trailing comment naming the range and what produces it (`// U+0660-U+0669 Arabic-Indic
   — an Arabic keyboard's digits`).
3. Re-run the whole suite. All 27 new tests green and every earlier test still green; test 5 is the one
   that catches an insertion made above the terminal collapse instead of below it.
4. At this point the fold is complete: every one of the contract's ten steps is in the file, in order.
   Read the function top to bottom against `normalisation-contract.md`'s pipeline table before committing.
   The two must diff cleanly, because T07 and E04 both assume they do.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 27 tests pass, and each failed first.
- [ ] Branch coverage on `normalise.dart` is 100%.
- [ ] The function now contains all ten contract steps, in the contract's order, and a reviewer can walk
      the two side by side.
- [ ] Both digit ranges are present; neither is a subset of the other's implementation.
- [ ] No number in this package is ever formatted for display — no `intl`, no `NumberFormat`, no locale.
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
feat(rule_engine): map Arabic-Indic and Eastern Arabic-Indic digits to ASCII

Both ranges, because both get typed: a device set up for Persian or Urdu
digit entry emits U+06F0-06F9 even for Arabic text — a keyboard is not a
locale, and D-3's six do not bound what a keyboard sends — and several of those
glyphs are visually all but identical to U+0660-0669. Mapping only the
first range passes every test written with ٣٨ and fails silently on a
keyboard nobody tried.

The boundary tests sit on U+065F and U+066A, one code point either side of
the Arabic-Indic range: an off-by-one there corrupts an Arabic percent sign
without changing any digit test.

This maps digits for keys only. What the user reads is decided by the
numberFormatSymbols swap at bootstrap (SPEC §9.3), which is nothing to do
with this package.

Task: E02/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
