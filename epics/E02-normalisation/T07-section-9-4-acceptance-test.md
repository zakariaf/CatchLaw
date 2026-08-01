# E02/T07 — The §9.4 acceptance test: five spellings, one species id

| | |
|---|---|
| **Epic** | E02 — Rule engine: text normalisation |
| **Branch** | `epic/02-normalisation` (shared) |
| **Commit** | `test(rule_engine): resolve every spelling of hamour to one species id` |
| **Depends on** | T06 (all ten contract steps must be in the fold) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.4 "Acceptance test (must exist as a unit test)", §4.1 "Local-name search" |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Its definition of done names this file: *"`normalise_test.dart` asserts `hamour`, `هامور`, `هامورة`, `الهامور` and `Epinephelus coioides` all resolve to one species id"*. Rule 11 adds the query side |
| `catchlaw-conventions-index` | Rule 6: the fixture returns a species-id string, never a drift row. Passing a database row into this package is a named anti-pattern |
| `testing-strategy` | Where a fixture lives, and why an acceptance test at this level needs a test double rather than a database |
| `naming-conventions` | Fixture constants and the double's name; the test names below |
| `dart3-idioms-and-coding-standards` | The double is ten lines of `Map` lookup and must stay that way — no logic of its own |
| `dartdoc-conventions` | The fixture file's own doc comment: what it stands in for, and what it is not |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.4 "Acceptance test" | The five inputs the spec names, verbatim |
| `SPEC.md` | §4.1 "Local-name search" | *"This is a unit test, not a manual check"* and *"Results in ≤50 ms"* — the acceptance condition, in the feature table |
| `SPEC.md` | §13 | Species search is an indexed prefix query over `search_norm`, capped at 40 results — what the double stands in for |
| `SPEC.md` | §7.1 `species_name` | The real shape: one row per name per locale, `search_norm` indexed. Two keys mean two rows |
| `.claude/skills/catchlaw-rule-engine/references/normalisation-contract.md` | "Acceptance test" | The eight-input table, which is a superset of §9.4's five, plus the separation assertion on `شعري` |
| `.claude/skills/catchlaw-rule-engine/examples/species_normalisation.dart` | `_aliases`, `buildIndex`, `lookup`, `main` | The alias fixture, the index shape and the exact assertions to reproduce |
| `epics/CONVENTIONS.md` | §6 | Where fixtures live: `testing/models/`, `k`-prefixed, never shipped, never ending in `_test.dart` |
| `epics/DECISIONS.md` | D-7 | The species id is a slug, not a sentence; nothing here is user-visible |

## What this delivers

- `packages/rule_engine/testing/models/species_aliases.dart` — the alias fixture: `kSpeciesAliases`, a
  `Map<String, String>` from an authored name to a species id, reproducing the worked example's table.
- `packages/rule_engine/testing/species_index.dart` — `SpeciesIndex`, a ten-line in-memory stand-in for
  the indexed prefix query of §13. It calls `indexKeys` and does nothing else.
- `packages/rule_engine/test/search/normalise_acceptance_test.dart` — the §9.4 acceptance test.
- Nothing under `lib/`. This task adds no production code.

`testing/` sits beside `lib/` and `test/` per `CONVENTIONS.md` §6 and `FLUTTER_GUIDE.md` §6.2, so it is
never compiled into the app or the builder. It is not under `lib/`, so it is imported from `test/` by a
relative path rather than by `package:`.

## Why it is built this way

**`SPEC.md` §4.1 makes this a unit test on purpose.** The feature table's "Done looks like" column says
*"Typing `hamour`, `هامور`, `هامورة`, `الهامور` or `Epinephelus` all reach the same species id. This is a
unit test, not a manual check."* A manual check of a search box proves the build you happened to run; a
unit test proves it on every commit, in CI, before the database exists. §9.4 repeats the requirement in
its own words — *"must exist as a unit test"* — and `catchlaw-rule-engine`'s definition of done names the
file.

**The double, and why it is honest.** There is no `reference.db` until E05, so the id has to come from
somewhere. `SpeciesIndex` is a `Map<String, String>` built by running `indexKeys` over every authored
alias and pointing every key at that alias's species id — which is exactly what E04's builder will do
into `species_name`, and exactly what E05's prefix query will read back. The double contains **no
normalisation of its own**: it calls `indexKeys` and looks up a map. If it ever grows a `replaceAll`, it
has become a second normaliser, and running `check_rule_engine.sh` against the whole package rather than
just `lib/` is what proves it has not.

What the double does not model is the *prefix* half of §13's query — it matches whole keys. That is
deliberate: the property under test is that the fold puts every spelling on the key the index holds, and
whole-key equality is the strictest form of that. Prefix behaviour is E08's, over real SQL.

**Nine inputs, not five.** §9.4 names five. `normalisation-contract.md`'s acceptance table names eight,
adding the tatweel spelling, the doubled space and the Presentation-Form paste; this task adds `HAMOUR`
from the worked example, which pins the invariant lowercase. The contract's set is a superset of the
spec's and every extra input traces to a step this epic built, so all nine are asserted.

**Two separation assertions, because a fold that merges everything passes every positive test.** `شعري`
must resolve to `lethrinus-nebulosus` and never to `epinephelus-coioides`, and `shari` — an unauthored
transliteration — must resolve to nothing at all. The contract states the first; the worked example
asserts the second with the comment *"an unauthored transliteration is a miss, not a guess"*. That is the
line between normalisation and invention: `hammour` is a row somebody authored, not a string the fold
produced.

**Rejected: asserting normalised strings instead of species ids.** `expect(normaliseSpeciesTerm('هامورة'),
'هامور')` is already asserted, five times over, in T02–T06. §4.1's acceptance condition is about reaching
*the same species id*, which is a different claim: it is about the fold and the dual-index fanning out
together. A test that asserts intermediate strings passes while the two disagree.

**Rejected: a `k`-free fixture name.** `FLUTTER_GUIDE.md` §3.1 bans `k` prefixes; `CONVENTIONS.md` §6
requires them for fixture constants in `testing/models/` and gives `kSpeciesHamour` as the example. The
narrower, later rule wins for fixtures, and only for fixtures — nothing under `lib/` gains a `k`.

**Rejected: putting `SpeciesIndex` in `lib/`.** It would be production code with no production caller:
the app resolves a species through drift, not through a `Map`. `FLUTTER_GUIDE.md` §3.7 makes the point
about private declarations — the analyzer can delete dead code it can see, and it cannot see an exported
symbol nobody calls.

## Tests first

Write the fixture and every row before writing `SpeciesIndex`. Run them. **They must fail** — the double
does not exist. If one passes now the test is wrong; the likely cause is a hand-built map in the test
file that never calls `indexKeys`.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SpeciesIndex.lookup resolves "hamour" to epinephelus-coioides` | `hamour` | `epinephelus-coioides` | The first of the five inputs §9.4 names, and the plain Latin transliteration the fisher's phone keyboard produces |
| 2 | `SpeciesIndex.lookup resolves "HAMOUR" to epinephelus-coioides` | `HAMOUR` | same | Invariant lowercase (T02). A search field with autocapitalisation on sends this |
| 3 | `SpeciesIndex.lookup resolves "هامور" to epinephelus-coioides` | `هامور` | same | The second of the five, and the baseline every Arabic case is compared against |
| 4 | `SpeciesIndex.lookup resolves "هامورة" to epinephelus-coioides` | `هامورة` | same | The third of the five. This is the row the first draft's `ة`→`ه` fold made impossible (T04) |
| 5 | `SpeciesIndex.lookup resolves "الهامور" to epinephelus-coioides` | `الهامور` | same | The fourth of the five, and the row that fails if the article is stripped on only one side (T05) |
| 6 | `SpeciesIndex.lookup resolves "هــامور" to epinephelus-coioides` | tatweel spelling | same | Contract acceptance row. Tatweel is typographic and a copy out of a justified PDF column carries it (T03) |
| 7 | `SpeciesIndex.lookup resolves "Epinephelus coioides" to epinephelus-coioides` | binomial | same | The fifth of the five. The scientific name is the one spelling that is stable across all six locales |
| 8 | `SpeciesIndex.lookup resolves "epinephelus  coioides" to epinephelus-coioides` | doubled space | same | Contract acceptance row. OCR and copy-paste both produce it (T02 step 10) |
| 9 | `SpeciesIndex.lookup resolves a Presentation-Form paste of هامور to epinephelus-coioides` | U+FEE9 U+FE8D U+FEE1 U+FEED U+FEAD | same | Contract acceptance row, and the §9.4 correction NFKC exists for. This is what the gazette PDF actually yields (T03) |
| 10 | `SpeciesIndex.lookup resolves "شعري" to lethrinus-nebulosus` | `شعري` | `lethrinus-nebulosus` | Separation. The folds of T03–T06 are lossy on purpose; this proves they are not lossy enough to merge two species §9.1 names |
| 11 | `SpeciesIndex.lookup resolves "الشعري" to lethrinus-nebulosus` | `الشعري` | `lethrinus-nebulosus` | The dual index applies to every species, not just the one the acceptance test is written around |
| 12 | `SpeciesIndex.lookup returns null for the unauthored transliteration "shari"` | `shari` | `null` | The line between folding and guessing. Transliteration variants are authored rows (E04), never generated |
| 13 | `SpeciesIndex.lookup resolves "Ameixa babosa" to venerupis-corrugata` | `Ameixa babosa` | `venerupis-corrugata` | A Galician name, so the acceptance test is not an Arabic-only test. §9.1 makes `gl` a shipping locale |
| 14 | `SpeciesIndex.lookup returns null for an empty query` | `''` | `null` | `indexKeys` yields nothing for an empty key (T05 row 6); this asserts the double does not turn that into a match-anything |

Rows 1–9 are written as one loop over `kHamourSpellings`, interpolating the query into the description
per `CONVENTIONS.md` §5, so a single failure names the spelling that broke.

```dart
// packages/rule_engine/test/search/normalise_acceptance_test.dart
import 'package:test/test.dart';

import '../../testing/models/species_aliases.dart';
import '../../testing/species_index.dart';

/// The nine spellings SPEC §9.4 and the normalisation contract require to reach
/// one species id. `ﻩﺍﻡﻭﺭ` is هامور in isolated Arabic
/// Presentation Forms-B — what a naive text extraction of a gazette PDF emits.
const kHamourSpellings = <String>[
  'hamour',
  'HAMOUR',
  'هامور',
  'هامورة',
  'الهامور',
  'هــامور',
  'Epinephelus coioides',
  'epinephelus  coioides',
  'ﻩﺍﻡﻭﺭ',
];

void main() {
  final index = SpeciesIndex.fromAliases(kSpeciesAliases);

  group('SpeciesIndex.lookup', () {
    for (final query in kHamourSpellings) {
      test('resolves "$query" to epinephelus-coioides', () {
        expect(index.lookup(query), 'epinephelus-coioides');
      });
    }

    test('resolves "شعري" to lethrinus-nebulosus', () {
      expect(index.lookup('شعري'), 'lethrinus-nebulosus');
    });

    test('returns null for the unauthored transliteration "shari"', () {
      expect(index.lookup('shari'), isNull);
    });

    // … one test per remaining row above, one behaviour each
  });
}
```

**Run:** `(cd packages/rule_engine && dart test test/search/normalise_acceptance_test.dart)` → 14
failures. If any passes now, the test is wrong.

## Implementation outline

1. Write `packages/rule_engine/testing/models/species_aliases.dart`. `kSpeciesAliases` reproduces the
   worked example's `_aliases` table: the Arabic and Latin names for `epinephelus-coioides`,
   `lethrinus-nebulosus`, `scomberomorus-commerson` and `venerupis-corrugata`, including the authored
   transliteration `hammour`. Give the file a doc comment saying what it is a fixture *for* and that it is
   not content — the real names arrive with E04's Galicia seed and E22.
2. Write `packages/rule_engine/testing/species_index.dart`. `SpeciesIndex.fromAliases` runs `indexKeys`
   over every alias and maps each key to the alias's species id; `lookup` runs `indexKeys` over the query
   and returns the first key that hits, or `null`. Nothing else. No `replaceAll`, no `RegExp`, no
   character literal.
3. Do not name either file `*_test.dart` — `flutter test` and `dart test` would execute them as empty
   suites and fail (`FLUTTER_GUIDE.md` §6.2).
4. Re-run the whole suite. All 14 green, every earlier test still green.
5. Run the gate against the **package root**, not just `lib/`, so `testing/` and `test/` are scanned. That
   is what proves the double holds no second normaliser.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 14 tests pass, and each failed first.
- [ ] All five inputs `SPEC.md` §9.4 names are among them, and all eight rows of the contract's acceptance
      table are covered.
- [ ] Both separation assertions pass: `شعري` → `lethrinus-nebulosus`, `shari` → `null`.
- [ ] `testing/species_index.dart` contains no `replaceAll`, no `RegExp` and no character-class literal;
      it calls `indexKeys` and looks up a `Map`.
- [ ] `check_rule_engine.sh packages/rule_engine` is clean — the wider target proves the previous point
      rather than asserting it.
- [ ] Nothing was added under `lib/`; `git diff --stat` shows `lib/` untouched.
- [ ] Neither new file ends in `_test.dart`.
- [ ] The fixture's doc comment says it is a fixture and not content, so nobody ships it as data.

## Gates

Run from the repository root. Note the **second** gate invocation: the package root rather than `lib/`.

```bash
dart format --set-exit-if-changed packages/rule_engine
dart analyze packages/rule_engine
(cd packages/rule_engine && dart test)
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(rule_engine): resolve every spelling of hamour to one species id

SPEC §4.1 says this is a unit test and not a manual check, and §9.4 says it
must exist as one. Nine spellings — hamour, HAMOUR, هامور, هامورة, الهامور,
the tatweel form, the binomial, a doubled-space binomial and a Presentation
Form paste — resolve to epinephelus-coioides, and each one traces to a step
this epic built.

Two separation assertions come with it, because a fold that merged
everything would pass all nine: شعري stays on lethrinus-nebulosus, and the
unauthored transliteration shari resolves to nothing. Normalisation folds
orthography; it never guesses a transliteration.

There is no reference.db until E05, so the id comes from a ten-line
in-memory index in testing/ that calls indexKeys and does nothing else.
Running check_rule_engine.sh over the whole package rather than lib/ is what
proves it has not grown a second normaliser.

Task: E02/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
