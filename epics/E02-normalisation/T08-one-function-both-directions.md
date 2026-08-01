# E02/T08 — One function, both directions, and the latency budget

| | |
|---|---|
| **Epic** | E02 — Rule engine: text normalisation |
| **Branch** | `epic/02-normalisation` (shared) |
| **Commit** | `test(rule_engine): pin index-query parity and the 50 ms fold budget at 2,400 names` |
| **Depends on** | T07 (the acceptance test and the fixture shape must exist) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.4 opening sentence, §13 (species search latency), §8 (the builder imports this function) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 10 is the claim this task tests: normalisation exists in exactly one function, because *"a near-copy in the CLI indexer drifts, and the index then holds keys the query can never produce"* |
| `catchlaw-content-pipeline` | The consumer on the other side: how `tools/content_builder/` shares this package through the pub workspace without a Flutter SDK |
| `catchlaw-conventions-index` | Rule 6, the layer map, and rule 8's performance framing — the numbers in this repo are budgets, not aspirations |
| `testing-strategy` | Which level a budget assertion belongs at, and how not to write a flaky one |
| `dart3-idioms-and-coding-standards` | The corpus generator: deterministic, no `Random` without a seed, no `DateTime.now()` |
| `dartdoc-conventions` | The library doc comment on `lib/rule_engine.dart` gains the shared-contract sentence — the highest-ROI documentation in the project |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.4 opening | *"One shared function, used identically when building `species_name.search_norm` / `legal_text.body_norm` and when normalising a query. Unit-tested in both directions."* This task is "both directions" |
| `SPEC.md` | §13 | `< 50 ms` at 400 species / 2,400 names, indexed `search_norm`, prefix query, capped at 40 results |
| `SPEC.md` | §8 "The content pipeline is a first-class deliverable" | *"populate `search_norm` and `body_norm` with the same normalisation function the app uses, imported from the shared package — not reimplemented"* |
| `SPEC.md` | §8 "Authoring volume" | Where 400 species and ~2,400 vernacular names come from — they are content estimates, not test parameters invented here |
| `.claude/skills/catchlaw-rule-engine/references/normalisation-contract.md` | "Failure modes this contract prevents" | *"Results appear then vanish after a content rebuild — a second normalise copy in the CLI drifted"* |
| `.claude/skills/catchlaw-content-pipeline/SKILL.md` | Rules 9 and 10; "Normalisation is imported, never reimplemented"; Anti-patterns | The consumer's own statement of this contract, its byte-for-byte parity pass, and the import path it names — which is **not** the one this epic uses. See the epic's risk 8 |
| `.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh` | check 4 and `NORM_RE` | The source-level guarantee this task's behavioural tests sit on top of |
| `FLUTTER_GUIDE.md` | §2.4, §2.6 | The workspace makes the app and the CLI provably use the same version of this package; the barrel is the seam |
| `FLUTTER_GUIDE.md` | §6.4 | The budget table: pure-Dart unit tests run in milliseconds, no Flutter |
| `epics/DECISIONS.md` | D-1, D-4 | `packages/rule_engine/`, and the consumer is `tools/content_builder/` with package name `content_builder` |

## What this delivers

- `packages/rule_engine/testing/models/species_corpus.dart` — a deterministic synthetic corpus of 400
  species ids and 2,400 names, sized to `SPEC.md` §8's authoring volume and §13's latency parameters.
- `packages/rule_engine/test/search/normalise_parity_test.dart` — the both-directions tests.
- `packages/rule_engine/test/search/normalise_budget_test.dart` — the `< 50 ms` tests.
- `packages/rule_engine/lib/rule_engine.dart` — the library doc comment gains the sentence naming
  `tools/content_builder/` as the second consumer and the fold order as a shared contract.

## Why it is built this way

**"Both directions" is a property, and this task states it as one.** §9.4 opens by saying the same
function builds `search_norm` and `body_norm` and normalises the query. Everything before T08 has asserted
transforms — this input becomes that string. That is necessary and not sufficient: the claim that matters
is that an alias folded at build time and a query folded at run time land on a key they share, for every
name, not for the nine T07 happens to name.

**The source-level guarantee already exists, and it is not this task's.** Check 4 of
`check_rule_engine.sh` reports any file other than `normalise.dart` that holds an Arabic character class
or a `normalise`-shaped function. That is what stops a second copy from being written. This task adds the
behavioural half: given one copy, does it actually round-trip? Both are needed, because a single function
can still be non-idempotent, and a non-idempotent fold drifts between a database built once and a query
folded on every keystroke.

**Idempotence is the property that makes the seam safe.** The builder folds an authored name into
`search_norm`. Later, someone re-runs the build over a database whose values are already folded, or the
app folds a query that a previous screen already folded. If `f(f(x)) != f(x)` anywhere, the index and the
query diverge and the symptom is the contract's *"results appear then vanish after a content rebuild"*.
So idempotence is asserted over the whole corpus rather than on the two or three strings each earlier task
could spare.

**The budget, and what it honestly measures.** §13 gives `< 50 ms` for species search at 400 species /
2,400 names — end to end, including the indexed prefix query over `search_norm` capped at 40 results.
Neither the database nor the query exists until E05. This task therefore spends the **whole** 50 ms
ceiling on the part E02 owns and asserts three things inside it: folding all 2,400 names once, folding one
query 2,400 times, and answering a lookup against the 400-species index. If the normalisation half fits
inside the whole budget with an order of magnitude to spare, E05 and E08 inherit headroom rather than a
budget already spent.

It is a **regression guard**, not a device measurement, and the test file says so in a comment. The device
measurement is §14's dynamic checklist and belongs to E21. To keep it from flapping: a warm-up pass before
the timed pass, `Stopwatch` rather than `DateTime.now()` (which `check_rule_engine.sh` check 3 bans in
this package anyway), and a single aggregate assertion rather than a per-call microsecond figure.

**The corpus is synthetic, and the file says so in its first line.** Real vernacular names arrive with
E04's Galicia seed and E22 — §8 is explicit that the content is the moat and that it is weeks of work. The
corpus is generated from the handful of real stems this epic already uses, fanned out to 400 ids × 6
locales (D-3) by composing each stem with an index, and deliberately seeded with orthographic variants —
a tatweel-inserted form, an article-prefixed form, a ta-marbuta form, a Presentation-Form paste — so that
every fold step is exercised at scale rather than only in the unit tests. It is deterministic: no
unseeded `Random`, no clock, so a failure is reproducible from the test name alone.

**Rejected: a source-scanning test that walks `tools/content_builder/` and `app/lib/`.** Neither exists on
this branch, and a test that walks a directory that may or may not be there is a test that passes for the
wrong reason — the empty-scan failure mode `CONVENTIONS.md` §7 names. The cross-package guarantee is
`check_rule_engine.sh` run over the whole repository in CI, which E01 wired, plus a definition-of-done
line in E04's builder task requiring the import rather than a copy.

**Rejected: `package:benchmark_harness`.** It is the right tool for comparing two implementations and the
wrong one for asserting a ceiling in a CI suite: it runs to statistical convergence, which costs seconds
per case and makes the suite slower than the thing it measures. A `Stopwatch` around a warmed loop is what
`FLUTTER_GUIDE.md` §6.4's "milliseconds, no Flutter" budget can afford.

**Rejected: relaxing the number to "fast" or to a percentage regression.** `SPEC.md` §13's figures are the
only ones anybody has agreed to. A percentage-of-last-run threshold has no fixed point and drifts upward
one commit at a time.

## Tests first

Write both files before touching `lib/rule_engine.dart`. Run them. **They must fail** — the corpus does
not exist. If a parity test passes now, the test is wrong: check it is not comparing a value with itself.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `normaliseSpeciesTerm folds "$authored" and "$typed" to a shared key` (loop over the contract's dual-index table) | (`الهامور`, `هامور`), (`هامورة`, `هامور`), (`هــامور`, `هامور`), (Presentation form, `هامور`) | `indexKeys` of each pair intersect | The both-directions claim of §9.4, stated as a property over the four ways the two sides can differ. Interpolated per `CONVENTIONS.md` §5 |
| 2 | `normaliseSpeciesTerm is idempotent across the 2,400-name corpus` | every name | `f(f(x)) == f(x)` | The seam between a build-time fold and a run-time fold. A single non-idempotent step is the contract's "results appear then vanish after a content rebuild" |
| 3 | `indexKeys is idempotent across the 2,400-name corpus` | every key it yields | `indexKeys(k)` yields `k` first | The article strip must not fire twice on a key that has already lost its article, or a rebuild produces a third key nothing points at |
| 4 | `SpeciesIndex.lookup resolves every authored name in the 2,400-name corpus` | every name | its own species id | Completeness. No name may fold to a key the query side cannot reproduce — the failure this whole epic exists to prevent, asserted at content scale |
| 5 | `SpeciesIndex.fromAliases maps no key onto two species ids in the 2,400-name corpus` | the whole corpus | no collision | The over-merge guard at scale. Steps 4–7 of the contract are lossy on purpose, and a collision in a corpus built from distinct stems means they are lossier than the contract allows |
| 6 | `normaliseSpeciesTerm folds the 2,400-name corpus in under 50 ms` | 2,400 names | elapsed `< 50 ms` | `SPEC.md` §13's number spent entirely on the index side. This is what E04's build loop costs per rebuild |
| 7 | `normaliseSpeciesTerm folds one query 2,400 times in under 50 ms` | one query, 2,400 iterations | elapsed `< 50 ms` | The query side. A per-keystroke fold that cost 20 µs would still fit §13 four hundred times over; this pins the order of magnitude |
| 8 | `SpeciesIndex.lookup answers 400 queries against the 400-species index in under 50 ms` | 400 distinct queries | elapsed `< 50 ms` | The two halves together. It is also the guard against someone making `indexKeys` allocate a `List` per call on the hot path |

```dart
// packages/rule_engine/test/search/normalise_budget_test.dart
//
// A regression guard, not a device measurement. SPEC §13's < 50 ms is an
// end-to-end target for species search including the indexed prefix query;
// that query does not exist until E05, so this spends the whole ceiling on
// the fold and leaves E05 and E08 the headroom. The device number is SPEC
// §14's dynamic checklist and belongs to E21.
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/species_corpus.dart';

const _budget = Duration(milliseconds: 50); // SPEC §13

void main() {
  final names = kSpeciesCorpus.names; // 2,400
  expect(names, hasLength(2400));

  group('normaliseSpeciesTerm', () {
    test('folds the 2,400-name corpus in under 50 ms', () {
      for (final name in names) {
        normaliseSpeciesTerm(name); // warm-up pass, not timed
      }
      final watch = Stopwatch()..start();
      for (final name in names) {
        normaliseSpeciesTerm(name);
      }
      watch.stop();
      expect(watch.elapsed, lessThan(_budget),
          reason: 'SPEC §13: < 50 ms at 400 species / 2,400 names');
    });

    // … rows 7 and 8 in the same shape
  });
}
```

```dart
// packages/rule_engine/test/search/normalise_parity_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/species_corpus.dart';
import '../../testing/species_index.dart';

/// How the authored form and the typed form differ, per the contract's
/// dual-index table.
const _pairs = <(String, String)>[
  ('الهامور', 'هامور'), // definite article
  ('هامورة', 'هامور'), // ta marbuta
  ('هــامور', 'هامور'), // tatweel
  ('ﻩﺍﻡﻭﺭ', 'هامور'), // Presentation Forms
];

void main() {
  group('normaliseSpeciesTerm', () {
    for (final (authored, typed) in _pairs) {
      test('folds "$authored" and "$typed" to a shared key', () {
        final indexed = indexKeys(authored).toSet();
        final queried = indexKeys(typed).toSet();
        expect(indexed.intersection(queried), isNotEmpty);
      });
    }

    test('is idempotent across the 2,400-name corpus', () {
      for (final name in kSpeciesCorpus.names) {
        final once = normaliseSpeciesTerm(name);
        expect(normaliseSpeciesTerm(once), once, reason: 'drifted on "$name"');
      }
    });

    // … rows 3, 4 and 5
  });
}
```

**Run:** `(cd packages/rule_engine && dart test test/search/normalise_parity_test.dart
test/search/normalise_budget_test.dart)` → 11 failures (8 rows, with row 1 expanding to four). If a
parity test passes now, the test is wrong.

## Implementation outline

1. Write `packages/rule_engine/testing/models/species_corpus.dart`. Open the file with a doc comment
   stating that it is synthetic, that it is sized to `SPEC.md` §8's authoring volume and §13's latency
   parameters, and that real names arrive with E04 and E22. Expose `kSpeciesCorpus` with `names` (2,400)
   and `aliases` (name → species id, 400 distinct ids).
2. Generate it deterministically: for each of the 400 ids, emit one name per locale (D-3's six: `ar`, `en`,
   `es`, `gl`, `ca`, `pt_BR`) by composing a real stem with the id's index. Rotate orthographic variants
   across the Arabic names — plain, article-prefixed, ta-marbuta, tatweel-inserted, Presentation-Form —
   so every fold step is exercised at scale. No unseeded `Random`, no clock.
3. Write the two test files. Assert the corpus size **inside** the test file, so a generator that silently
   produced 240 names fails loudly rather than passing a budget it never earned.
4. Extend the library doc comment in `lib/rule_engine.dart`: name `tools/content_builder/` (D-4) as the
   second consumer, state that the fold order is a contract shared with it, and cite `SPEC.md` §9.4 and
   §8. Do not restate the steps.
5. Re-run the whole suite. All 11 green, every earlier test still green.
6. Run both gate invocations, `lib/` and the package root.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 11 tests pass, and each failed first.
- [ ] Branch coverage on `lib/src/search/normalise.dart` is 100%, and the epic's coverage claim is now
      measurable end to end.
- [ ] The corpus is exactly 400 species ids and 2,400 names, asserted in the test rather than in a comment.
- [ ] The corpus generator is deterministic — no unseeded `Random`, no `DateTime.now()` (which check 3 of
      the gate bans in this package regardless).
- [ ] Every budget assertion has a warm-up pass and cites `SPEC.md` §13 in its `reason:`.
- [ ] `lib/rule_engine.dart` names `tools/content_builder/` as the second consumer and states that the
      order is a contract.
- [ ] `check_rule_engine.sh` is clean over `packages/rule_engine/lib` **and** over `packages/rule_engine`.
- [ ] The identical function is what `tools/content_builder/` will call — not a copy. E04's builder task
      carries the matching line in its own definition of done: it imports
      `package:rule_engine/rule_engine.dart` and reimplements nothing (`SPEC.md` §8), and runs the
      byte-for-byte parity pass `catchlaw-content-pipeline` rule 9 requires over every persisted column.
- [ ] The PR body raises the package-name gap (epic risk 8) so it is settled in `DECISIONS.md` before
      E04 types the import. Do not settle it in a task file.
- [ ] `packages/rule_engine/` still imports nothing from Flutter, and the epic's definition of done is
      now fully satisfied.

## Gates

Run from the repository root.

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
test(rule_engine): pin index-query parity and the 50 ms fold budget at 2,400 names

SPEC §9.4 opens by saying one function builds search_norm and body_norm and
normalises the query, unit-tested in both directions. Everything before this
asserted transforms; this asserts the property — an alias folded at build
time and a query folded at run time land on a key they share, for all 2,400
names rather than the nine the acceptance test happens to list.

Idempotence is the part that makes the seam safe. The builder folds once,
the app folds again on every keystroke, and a rebuild folds values that are
already folded; one non-idempotent step and results appear, then vanish
after a content rebuild.

The budget spends all of SPEC §13's 50 ms on the fold, because the indexed
prefix query it is really about does not exist until E05 — so E05 and E08
inherit headroom instead of a budget already gone. It is a regression guard
with a warm-up pass, not a device measurement; the device measurement is
§14's dynamic checklist in E21.

The corpus is synthetic and its first line says so. Real names arrive with
E04's Galicia seed and E22.

Task: E02/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
