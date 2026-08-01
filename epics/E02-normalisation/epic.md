# E02 — Rule engine: text normalisation

| | |
|---|---|
| **Branch** | `epic/02-normalisation` |
| **After** | E01 merged |
| **Tasks** | 8 |
| **Spec** | `SPEC.md` §9.4 (in full), §4.1 (local-name search), §13 (search latency), §7.1 (`species_name.search_norm`, `legal_text.body_norm`), §8 (the builder populates both) |
| **Guide** | `FLUTTER_GUIDE.md` Part 3, §6.1, §6.4, Part 7 |
| **Package** | `packages/rule_engine/` (D-1) |

## What this epic achieves

When this merges, one Dart function turns any spelling of a fish name into one search key, and both
sides of the search — the query the fisher types and the column the content builder writes — call that
same function. `hamour`, `HAMOUR`, `هامور`, `هامورة`, `الهامور`, `هــامور`, a Presentation-Form paste out
of a gazette PDF, `Epinephelus coioides` and `epinephelus  coioides` all land on the key that finds
`epinephelus-coioides`, while `شعري` stays firmly on `lethrinus-nebulosus`. That is the acceptance
condition `SPEC.md` §4.1 states for local-name search, and §4.1 says explicitly it is a unit test rather
than a manual check — T07 is that test.

Nothing here is user-visible. What later epics can rely on is narrower and more important: E04's content
builder can import `package:rule_engine/rule_engine.dart` and populate `species_name.search_norm` and
`legal_text.body_norm` (§7.1, §8) with the *identical* fold the app will use at query time, so the
shipped database can never hold a key the app is unable to reproduce.

## Where we are now

The branch is cut from a `main` that carries E01 — the pub workspace, `analysis_options.yaml`,
`packages/analysis_defaults/`, the CI wiring and every `SPEC.md` §14 static check (see `epics/README.md`,
row E01). D-1 fixes the layout: the workspace root is a bare package and `packages/rule_engine/` is one
of its members. D-5 fixes the toolchain: Flutter 3.44.6, Dart SDK constraint `^3.12.0`.

What does **not** exist yet:

- `packages/rule_engine/` as a real package. E01 may have left a placeholder there purely so
  `workspace:` resolves; **T01 begins by reading what is actually on disk** and fills it in rather than
  assuming. The `workspace:` entry itself belongs to E01 and is not edited here.
- Any normalisation code, anywhere. `SPEC.md` §15 step 2 puts the shared pure-Dart core immediately after
  the skeleton, and this epic is the first half of that step.
- Any database. There is no `reference.db` until E04/E05, so the §9.4 acceptance test resolves a species
  id through an in-memory index fixture in `packages/rule_engine/testing/`, not through SQL. That fixture
  is a stand-in for the indexed prefix query of §13, and T07 says so in as many words.

The known gap E01 leaves that this epic closes: `check_rule_engine.sh` currently has nothing to read.
Its own output says so — *"no domain files matched … checks 1-4 had nothing to read"* — which is exactly
the empty-scan failure mode `CONVENTIONS.md` §7 warns about. From T01 the gate is scanning a non-empty
tree.

## Why this epic exists here in the order

It cannot come earlier because it needs a workspace that resolves and a shared lint configuration; a
package with no `include:` line in its `analysis_options.yaml` silently loses every rule configured at
the root (`FLUTTER_GUIDE.md` §4.3, verified), and that is not a thing to discover in epic 12.

It must not come later because three consumers are already queued behind it. E03 builds resolution on top
of this package and inherits its no-Flutter guarantee. E04's builder is required by §8 to populate
`search_norm` and `body_norm` *"with the same normalisation function the app uses, imported from the
shared package — not reimplemented"*, so the function has to exist before the builder is written or the
builder will grow its own copy. E05 and E08 build the indexed prefix query of §13 over the column E04
wrote. Every one of those is a place where a second, drifting fold would produce a database whose keys
the app cannot reproduce — a search that silently returns nothing.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | Package skeleton and the zero-Flutter proof | `T01-package-skeleton.md` | S | — |
| T02 | The Latin fold — NFD, strip marks, lowercase | `T02-latin-fold.md` | S | T01 |
| T03 | The Arabic fold, steps 1 to 3 | `T03-arabic-fold-steps-1-3.md` | M | T02 |
| T04 | Collapse the Arabic word-final forms | `T04-collapse-arabic-terminals.md` | M | T03 |
| T05 | Definite-article stripping, with dual indexing | `T05-definite-article-dual-index.md` | M | T04 |
| T06 | Digits to ASCII | `T06-digits-to-ascii.md` | S | T05 |
| T07 | The §9.4 acceptance test | `T07-section-9-4-acceptance-test.md` | M | T06 |
| T08 | One function, both directions, and the latency budget | `T08-one-function-both-directions.md` | M | T07 |

The order is the fold's own order. `SPEC.md` §9.4 numbers its Arabic steps 1 to 6 and
`catchlaw-rule-engine/references/normalisation-contract.md` numbers the whole pipeline 1 to 10; each task
inserts its step at the numbered position and the tests of every earlier task must still pass. That is
not tidiness — the order is the contract E04 and E05 share, and a different order in two places produces
two different keys for one name.

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable at the epic level:

- [ ] All 8 tasks committed, one commit each, every `Task: E02/T<nn>` trailer present.
- [ ] `dart test` green in `packages/rule_engine/`, and 100% branch coverage on
      `lib/src/search/normalise.dart`.
- [ ] The §9.4 acceptance test passes on all nine spellings and both separation assertions (T07).
- [ ] `packages/rule_engine/` has zero `package:flutter` and zero `dart:ui` imports — proved by its
      pubspec (`FLUTTER_GUIDE.md` §4.6 Layer 1, a compiler guarantee), with the guard test as Layer 4.
- [ ] `check_rule_engine.sh packages/rule_engine/lib` clean, **and** its output does not contain the
      "nothing to read" note (`CONVENTIONS.md` §7).
- [ ] `check_rule_engine.sh packages/rule_engine` clean — the wider target also scans `test/` and
      `testing/`, which is how "there is exactly one normaliser" is proved rather than assumed.
- [ ] Exactly one file under `packages/rule_engine/lib/` is named `normalise.dart` and no other file in
      the package holds an Arabic character class.
- [ ] No file under `app/lib/` changed, so every `lonja-*` and `check_app_invariants.sh` gate is
      unaffected by this epic.
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin --delete-branch` (D-9).

## Risks and the things that will bite

**1. The Dart SDK ships no Unicode normalisation.** `dart:core` has neither NFKC nor NFD, and §9.4 opens
with NFKC. T02 resolves it by adding a dependency and T03 relies on it. **Mitigation:** the dependency is
chosen against stated criteria — pure Dart, no `flutter`, no `dart:io`, no transitive network edge — and
the resolved name and version go in T02's commit body and on the §14 direct-dependency allowlist in the
same commit. **What would resolve it definitively:** `dart pub add` at execution time plus reading the
resolved package's `pubspec.yaml`. Nothing in this plan names a version, because none has been verified.
The documented fallback, if no acceptable package exists, is a generated decomposition table restricted
to Latin-1 Supplement, Latin Extended-A and Arabic Presentation Forms A and B — named for what it does,
never named `nfkc`, because a partial NFKC calling itself NFKC is how the builder and the app come to
disagree.

**2. `SPEC.md` §9.4 step 4 and the normalisation contract split the alef maqsura differently.** §9.4 step
4 collapses word-final `ة`, `ه` **and** `ى`; the contract folds `ى` → `ي` at its step 6 and deletes only
`ة` and `ه` at step 7. They are not interchangeable: §9.1's own headline species list contains `شعري` and
`صافي`, so deleting a word-final `ى` while keeping a word-final `ي` puts the Egyptian-style and the Gulf
spelling of one name on two different keys. T03 owns the `ى` → `ي` fold and T04 records the reasoning in
full. **What would resolve it:** the per-locale native review §9.2 item 3 already budgets. If that review
disagrees, the change is one line in `normalise.dart` and one row in T04's test table.

**3. The Presentation-Form code points used as test inputs are asserted from the Unicode chart, not
measured.** T03 and T07 feed U+FEE9, U+FE8D, U+FEE1, U+FEED, U+FEAD and U+FE83 into the fold.
**Mitigation:** every such test expects the canonical Arabic string, so a wrong code point makes the test
**fail**, never silently pass. Cost is a debugging cycle, not a shipped defect. Verify each against
Unicode Presentation Forms-B (the chart `catchlaw-rule-engine/SKILL.md` cites in its References) before
committing.

**4. `check_rule_engine.sh` check 4 pins the filename, not the directory.** Its `NORM_RE` is
`(^|/)normalise\.dart$|(^|/)normalize\.dart$`, so *any* other file under `packages/rule_engine/lib`
containing `replaceAll(`/`RegExp(` with an Arabic literal or a `\u06` escape is reported as a second
normaliser. This is the intended constraint and it is why every fold step in T02–T06 lands in one file.
It also means `TEMPLATE.md` Part B's illustrative `lib/src/normalise/arabic_fold.dart` would trip the
gate; the executable script wins over the illustration, on the rule of thumb D-2 states. Path used
throughout this epic: `packages/rule_engine/lib/src/search/normalise.dart`, which is what
`catchlaw-rule-engine/SKILL.md` rule 10 names.

**5. The `< 50 ms` budget in T08 is measured in the Dart VM on CI hardware.** `SPEC.md` §13's number is
end-to-end for species search — indexed `search_norm`, prefix query, capped at 40 results — and the
SQLite half of that does not exist until E05. T08 therefore spends the whole 50 ms ceiling on the part
this epic owns, at 400 species / 2,400 names, which leaves E05 and E08 headroom rather than a budget
already consumed. **Mitigation:** a warm-up pass before timing, an order-of-magnitude margin, and an
explicit statement in the test file that this is a regression guard. The device number is §14's dynamic
checklist, owned by E21.

**6. The 2,400-name corpus in T08 is synthetic.** Real vernacular names arrive with E04's Galicia seed and
E22. A fold that is clean on generated data can still meet an orthography nobody planned for — the
Catalan interpunct `l·l` (U+00B7) does **not** decompose under NFD, and Catalan is a shipping locale
(D-3). **What would resolve it:** E04 re-runs T08's parity test over the real authored YAML before the
first `reference.db` ships. That re-run is a line in E04's definition of done, not a hope.

**8. ~~Three names exist for the package this epic creates, and none of them is settled in
`DECISIONS.md`.~~ SETTLED BY D-14, raised at the close of this epic.** `catchlaw-content-pipeline` rule 9 imports the fold from
`package:catchlaw_shared/text/normalise.dart` and calls it `normalise()`; its rule 10 imports the engine
from `package:catchlaw_rule_engine`; `catchlaw-rule-engine` rule 10 puts the fold inside
`packages/rule_engine/lib/src/search/normalise.dart` and calls it `normaliseSpeciesTerm`. D-1 places the
package at `packages/rule_engine/` and lists no `catchlaw_shared` member at all. **What this epic does,
and why:** pubspec `name: rule_engine`, imported as `package:rule_engine/rule_engine.dart`, with the fold
named `normaliseSpeciesTerm` and living inside that package. D-4 sets the precedent that the directory
name is the pubspec name, `FLUTTER_GUIDE.md` §2.5 puts the barrel at
`packages/rule_engine/lib/rule_engine.dart`, which only resolves under that package name, and D-1's member
list has no fourth package to put a `catchlaw_shared` in. **Resolved:** D-14 records exactly that, names
`catchlaw-content-pipeline` as the losing source, and applies the name to its rules 9 and 10 and its
worked example in the same change. E04 is unblocked; its builder types
`package:rule_engine/rule_engine.dart`.

**7. Branch-coverage tooling is unconfirmed on the pinned toolchain.** The 100% figure comes from
`FLUTTER_GUIDE.md` §6.3 and §6.4 and is not negotiable; the *tool* (`dart test --coverage` plus
`package:coverage` with `--branch-coverage`) has not been run here. **Mitigation:** the branch count in
this package is small and enumerable — every branch lives in `indexKeys`, and T05 lists them — so if the
tool is unavailable the enumeration stands until it is. Record the resolved invocation in E02's PR body.

## PR description

### What changed

`packages/rule_engine/` now exists as a pure-Dart workspace member with no Flutter dependency at all, and
it carries one function: `normaliseSpeciesTerm`, the ordered fold of `SPEC.md` §9.4, plus `indexKeys`,
which produces the article-stripped and article-retained keys §9.4 step 5 requires. Both live in
`lib/src/search/normalise.dart` and are exported from `lib/rule_engine.dart`, the single barrel
`FLUTTER_GUIDE.md` §2.6 permits.

The fold, in the contract's order: NFKC, tatweel, harakat and superscript alef, the alef family, hamza on
waw and ya, alef maqsura onto ya, word-final ta marbuta and ha, Arabic-Indic and Eastern Arabic-Indic
digits, the Latin NFD fold and invariant lowercase, whitespace collapse.

### Why

`SPEC.md` §4.1 makes local-name search a unit test, not a manual check, and §8 requires the content
builder to import this function rather than reimplement it. Two corrections §9.4 records are pinned by
name in the test suite: NFKC runs first because OCR of the gazette PDFs emits Arabic Presentation Forms,
and the word-final collapse deletes rather than folds `ة` to `ه`, because `هاموره` is neither equal to nor
a prefix of `هامور` and a prefix query would therefore have dropped the species from the result set
entirely.

### How it was verified

`dart test` in `packages/rule_engine/`, 100% branch coverage on `normalise.dart`. The §9.4 acceptance
test resolves nine spellings of one fish to `epinephelus-coioides` and proves separation on `شعري` and on
an unauthored transliteration. `check_rule_engine.sh` is clean over both `packages/rule_engine/lib` and
`packages/rule_engine`, the second target proving no second normaliser hides in `test/` or `testing/`.
The no-Flutter claim is a compiler guarantee from the pubspec (`FLUTTER_GUIDE.md` §4.6 Layer 1) with a
guard test as Layer 4. The `< 50 ms` figure is `SPEC.md` §13's, measured over 2,400 names in the VM.

### Product invariants touched

Invariant 1 (no network code path) is tightened: the new package declares no dependency that can open a
socket, and a test asserts it. Invariant 2 is untouched by construction and by D-7 — this package holds
no user-visible sentence in any language, and the only strings in it are Unicode escapes and a species-id
slug. Invariants 3, 4 and 5 are not reachable from here; there is no verdict, no colour and no expiry in
this epic.

### Follow-ups deliberately not in this PR

- The SQL side of §13 — the indexed prefix query over `species_name.search_norm`, capped at 40 results.
  E05 and E08.
- The builder that calls this function to populate `search_norm` and `body_norm`. E04, per §8.
- FTS5 over `body_norm` with `unicode61 remove_diacritics 2` (§7.1). E15, per §13's 200 ms figure.
- Authored alias rows. Normalisation folds orthography; it never generates a transliteration, so
  `hammour` is content, not code.
- ~~**A `DECISIONS.md` entry settling the package name.**~~ **Done — D-14, in this PR.** It is in the
  PR because `CONVENTIONS.md` forbids a TASK from amending `DECISIONS.md`, not the epic; raising it at
  the epic's close is the documented route, and leaving E04 blocked on a decision this epic already made
  in code would have been the worse reading. The one hit not corrected is
  `check_content_pipeline.sh`'s `SHARED_RE`, because it is a gate pattern — see D-14 and E04/T07.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task, tests
red first; `/simplify` and `/code-review` before each commit, not after; `gh pr create`;
`gh pr checks --watch`; merge only on all-green with `gh pr merge --squash --admin --delete-branch`
(D-9); then and only then start E03.
