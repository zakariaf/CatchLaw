# CONVENTIONS.md — how an epic and a task are executed

This page is the ritual. Every `epic.md` and every task file assumes it and does not repeat it.
Read it once per session, before the first task of an epic.

---

## 1. The epic loop

An epic is one branch and one pull request. Five steps, in order, no overlap between epics:

```bash
# 1 — branch from a current main
git checkout main && git pull --ff-only
git checkout -b epic/07-lonja-theme

# 2 — the tasks, in order, one commit each (§2)

# 3 — open the PR
gh pr create --base main --head epic/07-lonja-theme \
  --title "E07 — Lonja design system foundation" \
  --body-file .github/pr-body.md          # written from the epic's "PR description" section

# 4 — wait for the pipelines, do not merge on a pending check
gh pr checks --watch                       # blocks until every check reports
gh pr view --json statusCheckRollup -q '.statusCheckRollup[]|"\(.name) \(.conclusion)"'

# 5 — merge only when every check is SUCCESS, then delete the branch
gh pr merge --squash --admin --delete-branch
git checkout main && git pull --ff-only
```

**Never start the next epic before the previous PR is merged.** Epics are ordered by dependency; a
branch cut from an unmerged parent produces a diff nobody can review.

`--admin` is required and is not a shortcut — see `DECISIONS.md` D-9. It uses the repository-admin
bypass that exists because a single maintainer cannot approve their own PR. It does **not** skip
checks; step 4 is what makes the merge safe.

**If a check fails at step 4:** fix it on the same branch with an additional commit. Do not amend a
pushed commit — the ruleset enforces linear history and a force-push to a PR branch invalidates the
review trail.

---

## 2. The task loop

One task is one commit. The loop is test-first, and the two review commands run **before** the commit,
not after — their output is meant to change the code that gets committed.

```
1. Load the skills the task names.            ← Skill tool, before reading any source
2. Read the reference files the task names.
3. Write the tests from the task's test table. Run them. THEY MUST FAIL.
4. Write the minimum code that makes them pass. Run the whole suite.
5. Run the task's gate scripts. They must be clean.
6. /simplify        ← then act on it: delete what it finds, re-run the suite
7. /code-review     ← then act on it: fix what it confirms, re-run the suite
8. Commit, once (§3). Push.
```

**Step 3 is not optional and not a formality.** A test that passes before the implementation exists is
testing nothing. If it passes, the test is wrong — fix the test before writing any production code.

**Steps 6 and 7 produce work.** Running `/simplify` and reading the output is half the step. If it
finds a redundant abstraction, the abstraction goes before the commit. If `/code-review` confirms a
defect, it is fixed in the same commit — a follow-up commit for a defect the review caught in the same
task is churn.

More than one commit per task is acceptable when review turns up something real. Aim for one. Never
bundle two tasks into one commit: the task IDs are how the epic's progress is read.

---

## 3. Commit messages

```
<type>(<scope>): <subject, imperative, no trailing period>

<body: why, not what. What is in the diff.>

Task: E07/T03
```

`type` ∈ `feat` `fix` `test` `refactor` `chore` `docs` `build` `ci`.
`scope` is the package or feature: `rule_engine`, `content_builder`, `theme`, `check`, `ruler`, `l10n`,
`data`, `ci`.

The `Task:` trailer is the only mandatory trailer. It is what lets a reviewer walk from a commit back
to the specification that justified it.

Ending line for every commit, per the repository standard:

```
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```

---

## 4. Loading skills

Every task file opens with a **Skills to load** table. Load them with the Skill tool *before* reading
source, because a skill changes how the source should be read.

Two registries are in play:

- **`catchlaw-*` and `lonja-*`** — in this repository, under `.claude/skills/`. They carry token
  **values** and app-domain **law**.
- **the 33 general Flutter skills** — the separate `Flutter-Skills` plugin. They carry general
  practice: architecture, Riverpod, drift, goldens, naming, lints, CI.

A general rule is never restated in an app skill, and vice versa. If a task seems to need a rule that
lives in neither, that is a gap — record it, do not invent a local convention.

Route with `catchlaw-conventions-index` whenever ownership is unclear; its
`references/routing-table.md` is the complete matrix and names the tie-break for the seams.

---

## 5. Test naming — the house rule

`<Subject> <present-tense verb phrase> [when/with <condition>]`. **Subject first. No `should`. No `it`.
No given/when/then.** From `flutter/flutter`'s `Writing-Effective-Tests.md`; the full argument and the
receipts are in `FLUTTER_GUIDE.md` §6.1.

```dart
// right
test('RuleResolver.resolve tags is_expired when valid_to is in the past', () {});
test('ArabicFold.normalise maps الهامور and هامور to the same key', () {});
testWidgets('RTL - VerdictPanel places the glyph at the start edge', (t) async {});

// wrong
test('should resolve rules correctly', () {});      // `should`, and says nothing
group('RuleResolver tests', () {});                 // the documented anti-pattern
```

One behaviour per test. Conditions encoded with literal argument syntax — `centerTitle:false`,
`(RTL)`, `at 200% scale` — so `grep` finds every test about a thing. Cross-cutting axes take a prefix:
`RTL - `, `ar - `, `sunlight - `, `glove - `.

Loop-generated tests **must** interpolate the parameter into the description, or `--plain-name` is
useless.

---

## 6. Where tests live

```
<package>/test/          mirrors lib/          — unit, widget, golden
<package>/testing/       beside lib/ and test/ — fakes and fixtures, never shipped
app/integration_test/                          — device happy paths
```

- `_test.dart` is a hard requirement; a helper must **not** end in `_test.dart`. Name helpers
  `harness.dart`, `fakes.dart`, `golden.dart`.
- Golden files live next to their test file — `LocalFileComparator` resolves the key relative to the
  test file's directory. `**/failures/` is already in `.gitignore`.
- `flutter_test_config.dart` is directory-scoped and scanned upward. Font loading for goldens goes
  there (E06/T08).
- Fixture constants are `k`-prefixed and live in `testing/models/`: `kRuleGalicia`, `kSpeciesHamour`.

**The pyramid, per `FLUTTER_GUIDE.md` §6.4:** the pure-Dart rule engine carries the weight and aims at
100% branch coverage; the app aims at ~80% excluding generated code. There is no network, so there is
no argument for a fat integration layer. Keep the golden **matrix** small — 4–6 screens × 6 locales ×
2 themes, generated and verified on Linux CI only.

---

## 7. Gate scripts

The 16 skills each ship a runnable `scripts/check_*.sh`. They take an optional target directory and
**exit 2 if it does not exist**, so always pass the real one:

```bash
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
```

They are heuristic greps, not compilers. **Passing is a floor, not proof.** Each has one documented
escape hatch — a trailing `// catchlaw-invariant-ok` or `// lonja-token-ok` on a line that is provably
fine. ARB values and pubspec dependencies are never exempt.

A gate that scans a path with no files reports success. That is the failure mode that makes a gate
worse than no gate, so E01/T08 asserts each gate is scanning a non-empty tree before trusting it.

---

## 8. Definition of done — the floor under every task

A task's own `epic.md` and task file add to this; nothing removes from it.

- [ ] The tests named in the task exist, and each failed before the implementation existed.
- [ ] `dart format --set-exit-if-changed .` and `flutter analyze` are clean.
- [ ] The full suite passes, not just the new tests.
- [ ] Every gate script the task names is clean against the real target directory.
- [ ] `/simplify` has run and its findings are resolved or explicitly rejected in the commit body.
- [ ] `/code-review` has run and its confirmed findings are fixed.
- [ ] One commit, with the `Task:` trailer.
- [ ] No `TODO`, no commented-out code, no `print`, no `debugPrint` outside a `kDebugMode` guard.
- [ ] Public API has doc comments per `dartdoc-conventions`; a `///` on a private field is noise.

---

## 9. The five product invariants, which no task may weaken

Restated here only because they are the thing most likely to be broken by accident. The authority is
`catchlaw-conventions-index/references/product-invariants.md`.

1. **No network code path, ever.** Not a dependency, not an import, not a `dart:io` socket.
2. **A verdict states a fact and never instructs.** "Below the minimum — 38 cm, minimum 45 cm (total
   length)". Never "Keep", never "Return".
3. **Every result carries a required, non-nullable `Citation`.**
4. **Colour is never the only signal** — glyph plus word plus hue, always.
5. **An expired ruleset is still evaluated and still shown**, behind a non-blocking ochre bar.

If a task appears to require breaking one, the task is wrong. Stop and say so.

---

## 10. Anatomy of a task file

Every task file in every epic has these sections, in this order. An agent writing one fills all of
them; a builder executing one reads them top to bottom.

| Section | What it holds |
|---|---|
| Header table | ID, epic, branch, commit type/scope, depends-on, size |
| **Skills to load** | table: skill → why this task needs it |
| **Reference files** | table: file → section → what to take from it |
| **What this delivers** | the artefacts, by path |
| **Why it is built this way** | the technical reasoning, including what was rejected |
| **Tests first** | the complete test list as a table, then the test skeletons |
| **Implementation outline** | the steps, after the tests are red |
| **Definition of done** | task-specific checks, on top of §8 |
| **Gates to run** | the exact commands |
| **Commit** | the exact message |

Size: **S** ≈ under an hour, **M** ≈ half a day, **L** ≈ a day or more. If a task looks bigger than L,
it is two tasks.
