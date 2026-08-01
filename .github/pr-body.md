# E02 — Rule engine: text normalisation

`packages/rule_engine/` now carries one function that turns any spelling of a fish name into one search key, and both sides of the search — the query the fisher types and the column the content builder writes — call that same function.

`hamour`, `HAMOUR`, `هامور`, `هامورة`, `الهامور`, `هــامور`, a Presentation-Form paste out of a gazette PDF, `Epinephelus coioides` and `epinephelus  coioides` all reach `epinephelus-coioides`, while `شعري` stays firmly on `lethrinus-nebulosus` and the unauthored `shari` reaches nothing at all.

## What changed

`normaliseSpeciesTerm` implements the ordered fold of `SPEC.md` §9.4 — NFKC, tatweel, harakat and superscript alef, the alef family, hamza on waw and ya, alef maqsura onto ya, the word-final ta-marbuta and ha collapse, both Arabic-Indic digit ranges, the Latin NFD fold with invariant lowercase, whitespace collapse. `indexKeys` produces the article-stripped and article-retained keys §9.4 step 5 requires. Both live in `lib/src/search/normalise.dart` and are exported from the one barrel.

The package declares no `flutter` dependency, so `import 'package:flutter/…'` here is a compile error rather than a lint — which is what will let `tools/content_builder/` compile it under a plain `dart run` with no Flutter SDK installed.

## Why

`SPEC.md` §4.1 makes local-name search a unit test and not a manual check, and §8 requires the content builder to import this function rather than reimplement it. Two corrections §9.4 records are pinned by name in the suite:

- **NFKC runs first** because OCR of the gazette PDFs emits Arabic Presentation Forms. Fold the alef family before it and the class never matches U+FE83, the Presentation Form survives into the key, Latin search keeps working and Arabic search silently returns nothing.
- **The word-final collapse deletes rather than folds `ة` to `ه`**, because `هاموره` is neither equal to nor a *prefix of* `هامور`, and §13 makes search a prefix query — so the first draft's fold would have removed the fish from the result set entirely, not merely ranked it lower.

## Verification

- **116 tests** in `packages/rule_engine`, 134 in `app`, 1 in the builder
- **100% coverage on `normalise.dart`** — 33/33 lines, **15/15 branches**
- `check_rule_engine.sh` clean over `packages/rule_engine/lib` **and** `packages/rule_engine`, the second target proving no second normaliser hides in `test/` or `testing/`
- All sixteen skill gates green; `dart format` and `flutter analyze --fatal-infos` clean
- No file under `app/lib/` changed

### The `< 50 ms` budget, measured

| | |
|---|---|
| index side | 12.2 ms for 2,400 names folded once |
| query side | 9.5 ms for 2,400 folds — **~4 µs per fold** |

Both inside §13's ceiling, but the two numbers are not comparable and only one competes with the search budget. The 12.2 ms is a **build** cost that E04 pays once per rebuild, off the device, never while a fisher is waiting. The number that competes is ~4 µs per query fold, so **E05 and E08 inherit essentially the whole 50 ms**, not 38 ms of it. Written into the test file so the next reader does not have to re-derive it.

## Risk 7 resolved — the branch-coverage invocation

The epic recorded the tooling as unverified. It is now:

```bash
dart test --coverage=<dir> --branch-coverage
dart pub global run coverage:format_coverage --lcov --in=<dir> --out=lcov.info --report-on=lib
```

Three things worth knowing, all of which cost a cycle here:

1. `--branch-coverage` is a **`dart test`** flag. `format_coverage` rejects it outright.
2. `format_coverage --lcov` emits **no** `BRF`/`BRDA` records. Branch data lives only in the raw JSON's `branchHits`.
3. **Branch hits must be aggregated across the per-isolate JSON files.** Reading one file reports false gaps — it showed 4 uncovered branches that are covered by other isolates. A naive check here would have failed a definition-of-done item that is actually met.

## D-14 — the package name, settled

E02's Risk 8 recorded three names for one package with nothing in `DECISIONS.md` settling them. **D-14 is in this PR**, naming `catchlaw-content-pipeline` as the losing source: one package, `packages/rule_engine/`, `name: rule_engine`, imported as `package:rule_engine/rule_engine.dart`. No `catchlaw_shared`, no `packages/shared/`.

It is in the PR rather than a task because `CONVENTIONS.md` forbids a *task* from amending `DECISIONS.md`, not an epic — and leaving E04 blocked on a decision this epic had already made in code would have been the worse reading. The skill's rules 9 and 10 and its worked example are corrected in the same change, per the amendment rule.

**One hit deliberately not corrected:** `check_content_pipeline.sh` line 32 exempts `packages/shared/|/catchlaw_shared/`, a path that does not exist. That is a **gate pattern**, and `CLAUDE.md` forbids editing one — the rule exists so nobody widens a gate to make a build pass, and the honest move is to say so rather than quietly rewrite it. The gate is not failing; an exemption matching nothing is inert. **E04/T07 already names it in its Risks and is the correction site.**

## Learned by executing

- **A mutation script that reverts with `git checkout -- <file>` deletes uncommitted work.** It cost T03's implementation once, and the symptom was a mutation that stayed green because the target text no longer existed. Mutation scripts here now back up to a file.
- **Green-on-arrival tests prove nothing, and two of them were weak.** T03's over-merge guard compares `هامور` and `شعري`; under a fold mapping *every* Arabic letter to alef it stays green, because the two words differ in length. §9.1 names five species that must stay apart, so a second test asserts all five reach five distinct keys — same mutation, that one goes red.
- **The §9.4 acceptance test does not prove what it looks like it proves.** Removing the article strip leaves `الهامور` — the row §9.4 names for exactly that rule — **green**, because `الهامور` is itself an authored alias. Only `الشعري`, authored without the article, can reach its species through the stripped key. The test file now says so at the assertion.
- **E01's deps fixtures were a shape `dart pub deps --json` never emits.** They had been hand-trimmed to the three keys the gate reads, so a gate that broke on the real output would have kept a green suite. Regenerating verbatim restored `version`, `source`, `directDependencies` and `devDependencies`, and the derivation is now a script rather than four hand-patched JSON files per new dependency.

## Follow-ups deliberately not here

- The SQL side of §13 — the indexed prefix query over `species_name.search_norm`, capped at 40 results. E05 and E08.
- The builder that calls this function to populate `search_norm` and `body_norm`. E04, per §8.
- FTS5 over `body_norm` with `unicode61 remove_diacritics 2`. E15.
- Authored alias rows. Normalisation folds orthography and never generates a transliteration, so `hammour` is content, not code.
- `check_content_pipeline.sh`'s `SHARED_RE` — E04/T07, as above.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
