# DECISIONS.md — conflicts resolved before the first line of code

`SPEC.md`, `FLUTTER_GUIDE.md` and `.claude/skills/` were written in three separate research passes.
They disagree in nine places. Each disagreement is settled here, once, with the losing source named so
nobody re-opens it. **A task file never re-litigates a decision on this page; it cites it as `D-n`.**

Where a decision changes a document or a skill, the task that performs the change is named. Until that
task lands, the document still says the old thing — that is expected, and it is why this page exists.

---

## D-1 — Repository layout: pub workspace, app under `app/`

**Decision.** The repository root is a bare pub-workspace package. Members:

```
catchlaw/                          # this repo
├── pubspec.yaml                   # name: catchlaw_workspace — workspace root, ships nothing
├── analysis_options.yaml
├── app/                           # the Flutter app       (name: catchlaw)
├── packages/rule_engine/          # pure Dart, zero Flutter
├── packages/analysis_defaults/    # shared lints, dev-dependency of every member
├── tools/content_builder/         # Dart CLI: authoring YAML → reference.db
└── epics/ · design/ · research*/  # already here
```

**Source.** `FLUTTER_GUIDE.md` §2.4 and §2.5, which follow `flutter/samples`.

**Overruled.** The `catchlaw-conventions-index` routing table places the app at the repository root
(`lib/`, `assets/`) and the builder at `packages/content_build/`. That layout would make the workspace
root simultaneously the Flutter app and the workspace owner — legal, but it puts `app/lib` and
`tools/` in one dependency namespace and contradicts the researched tree.

**Consequence for the gate scripts.** Every `.claude/skills/*/scripts/check_*.sh` takes an optional
`TARGET_DIR` and **exits 2 when the directory does not exist** — verified by reading them. So CI calls
them as `check_lonja_tokens.sh app/lib`, and a wrong path fails loudly instead of passing on an empty
scan. No script needs editing. **Do not** let a gate default to `lib/` in CI: at this repo root that
directory does not exist and the run would abort rather than scan `app/lib`.

**Applied by:** E01/T01. **Skill correction:** E01/T09.

---

## D-2 — The theme lives at `app/lib/theme/`, not `app/lib/ui/core/themes/`

**Decision.** `LonjaPrimitives`, `LonjaTokens`, `LonjaTheme` and the text theme live in
`app/lib/theme/`. Shared non-theme widgets keep `FLUTTER_GUIDE.md`'s home, `app/lib/ui/core/ui/`.

**Source.** Every `lonja-*` gate script exempts token constructs by matching the path fragment
`/theme/` (`THEME_RE='/theme/'`). A colour authored in `ui/core/themes/lonja_tokens.dart` matches too —
but `ui/core/themes/` also sits under `ui/`, and check 8 of `check_lonja_tokens.sh` bans
`Theme.of` / `LonjaTokens.of` inside `*_painter.dart`, which is a `ui/` neighbourhood rule. Keeping the
palette out of `ui/` keeps the two rule sets from overlapping.

**Overruled.** `FLUTTER_GUIDE.md` §2.1's `ui/core/themes/`. That is the general Flutter convention; the
gate script is executable and therefore wins.

**Rule of thumb:** the gate script beats the prose whenever they disagree about a path.

**Applied by:** E07/T01.

---

## D-3 — Six locales: `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`. Catalan ships; Urdu does not

**Decision.** ARB files are exactly:

```
app/lib/l10n/app_ar.arb   app_en.arb   app_es.arb   app_gl.arb   app_ca.arb   app_pt_BR.arb
```

**Amended by D-18**, which adds a seventh file, `app_pt.arb`, as the base fallback `gen-l10n` refuses
to build without. Six languages, seven files; everything else in this decision stands.

RTL golden lanes: **`ar` only**. There is one RTL locale in this product.

**Source.** `SPEC.md` §9.1, which justifies each locale by the publication language of the instrument
being bundled — Catalan because Catalonia, Valencia and the Balearics publish their fishing orders in
Catalan.

**Overruled.** Three places in the skills name `app_ur.arb` and speak of "Arabic and Urdu RTL lanes":
`catchlaw-conventions-index/SKILL.md` rule 12, its `references/routing-table.md`, and a report label in
`scripts/check_app_invariants.sh`. Urdu appears nowhere in `SPEC.md` and no bundled instrument is
published in it. `catchlaw-verdict-contract/SKILL.md` says `app_pt.arb`; the correct filename carries
the region, `app_pt_BR.arb`, because the content is Brazilian and not Iberian Portuguese.

**Applied by:** E06/T01. **Skill correction:** E01/T09 — four files, `ur` → `ca`, `app_pt` → `app_pt_BR`
— completed at the **E01 close-out**, which cleared the remaining two (`catchlaw-content-pipeline`'s
shipped-locale list and gendered set, `product-invariants.md` §3).

T09 deferred those two to E04/T01 and E06/T01 on the reading that the gendered-locale set was a content
decision. It was not: `SPEC.md` §9.5 line 815 already names the gendered locales exactly — `ar`, `es`,
`gl`, `ca`, `pt_BR` — and §9.1 line 840 supplies the Catalan row's justification verbatim. Nothing was
open. The lesson is registered in `known_skill_drift.txt`: check whether the judgement is already on
paper before scheduling an IOU for it.

---

## D-4 — The content builder is `tools/content_builder/`, package `content_builder`

**Decision.** One name: directory `tools/content_builder/`, pubspec `name: content_builder`,
executable `dart run content_builder:build`.

**Overruled.** `SPEC.md` §8 says `tools/build_content/`; the skills say `packages/content_build/`.
Three names for one deliverable was going to cost somebody an afternoon.

**The output path travels with the name:** `--out app/assets/db/reference.db`, the path E04/T01,
E04/T11 and E18/T01 already invoke and the one `catchlaw-reference-database` ships from
(`assets/db/reference.db.gz`). `catchlaw-content-pipeline` carried `assets/reference.db` in eight
places — the same pre-D-4 drift, missing its `db/` segment, and never registered because the drift
register only tracked the CLI name. Corrected at the E01 close-out.

**Applied by:** E04/T01. **Skill correction:** the E01 close-out — four files, including the runnable
example, renamed `content_build_assertions.dart` → `content_builder_assertions.dart` so one name means
one name in the filesystem too.

---

## D-5 — Toolchain floor

| | Version | Why |
|---|---|---|
| Flutter | **3.44.6** (stable, 2026-07-08) | `FLUTTER_GUIDE.md` Part 0, verified |
| Dart SDK constraint | **`^3.12.0`** | Pub workspaces need ≥ 3.6; 3.12 is what the guide verified against |
| Riverpod | **3.4.1** + `riverpod_generator` 4.0.6 | Guide Part 5, verified on pub.dev |
| drift | **2.34.2** | Guide Part 4.7 |

**Overruled.** `SPEC.md` §10's "Flutter 3.24+ / Dart 3.5+" and "flutter_riverpod ^2.5". The spec was
written first; the guide's numbers were verified later against the pub.dev and GitHub APIs. Dart 3.5
cannot resolve a workspace at all, so the spec's floor is not merely older — it is incompatible with
D-1.

**Applied by:** E01/T01.

---

## D-6 — Reference database: gzipped asset, temp file, atomic rename, sha256, JSON marker

**Decision.** All four mechanisms, together:

1. Ship `app/assets/db/reference.db.gz`.
2. Extract to a temp file under `getApplicationSupportDirectory()`, verify sha256, `rename()` into
   place. A partial extraction leaves only the temp file, which is deleted and retried next launch.
3. Write `app_meta.content_build_date` in `user.db` as the completion marker.
4. Decide whether to extract by comparing a **generated Dart constant** against that marker — no
   database open is required to make the decision.
5. Open the extracted file `readOnly: true`, always.

**Source.** `SPEC.md` §7.4 contributes the marker, the temp+rename and the "no open required" fix;
`catchlaw-reference-database` contributes the `.gz` asset, the sha256 and the read-only open. They are
complementary, not contradictory — the merge is the decision.

**Applied by:** E05/T01–T03.

---

## D-7 — The engine returns types; the app owns every word

**Decision.** `packages/rule_engine/` returns ~~sealed `Verdict` and `Finding`~~ **sealed
`Resolution` and `Finding`** (the top type's name is amended by **D-15**; this decision's substance is
untouched) values carrying numbers,
enums, a required `Citation` and an `isExpired` flag. It contains **no user-visible sentence**, in any
language. Wording comes from ARB (UI chrome) and `content_string` (bundled content), assembled in
`app/lib/ui/`.

**Why it needs saying.** `catchlaw-verdict-contract` bans imperatives "in Dart source and in all six
ARB files", which reads as though the engine holds strings. It does not. The contract binds the layer
that renders, and `check_verdict_contract.sh` scans `app/lib` and `app/lib/l10n` for exactly that
reason.

**Applied by:** E03/T10, enforced at E10/T10.

---

## D-8 — `EdgeInsets.only(left:` is banned by a grep gate, not by a lint

**Decision.** The directional-padding ban is a CI grep gate in `tools/gates/no_directional_geometry.sh`,
run over `app/lib`.

**Why.** `SPEC.md` §9.3 says "a lint rule bans `EdgeInsets.only(left:`". No such rule exists in
`package:lints`, `flutter_lints` or the analyzer's built-in set, and writing a custom analyzer plugin to
enforce one line is disproportionate. Calling it a lint when it is a grep is the kind of small
inaccuracy that makes a builder search for a rule name that was never published.

**Applied by:** E06/T05.

---

## D-9 — Merging your own PR on this repository

**Decision.** Each epic's PR is merged with `gh pr merge --squash --admin` **after** all checks report
success.

**Why.** The `main protection` ruleset requires one approving review **and** a code-owner review.
`.github/CODEOWNERS` names `@zakariaf` for everything, and GitHub does not let an author approve their
own pull request — so on a single-maintainer repository the requirement is unsatisfiable by design.
Repository-admin bypass is enabled in the ruleset for exactly this case. `--admin` uses that bypass; it
does **not** skip the status checks, which must already be green.

The ruleset also enforces `required_linear_history` and squash-only merges, so `--squash` is not a
preference — a merge commit is rejected.

**Not decided here:** commit signing. `required_signatures` was deliberately left off the ruleset
because SSH signing is not configured; if that changes, add the rule and every commit below needs
`-S`.

---

## D-10 — Lints build on `flutter_lints`, not `very_good_analysis`

**Decision.** The root `analysis_options.yaml` is `include: package:flutter_lints/flutter.yaml` plus the
promotions and rule list in `FLUTTER_GUIDE.md` Part 4.3. `very_good_analysis` is not a dependency.

**Source.** `FLUTTER_GUIDE.md` Part 4.2, executed against Dart 3.12.2.

**Overruled.** `lint-and-style-config` rule 2, which requires building on `very_good_analysis` with a
version-stamped include. VGA is aimed at *published packages*: it turns on `public_member_api_docs`,
`lines_longer_than_80_chars`, `require_trailing_commas` and `discarded_futures`, three of which are wrong
for a private app, and it still ships two rules the Dart team deprecated in the 3.13 cycle. It is also the
only place in E01 where a general skill is not followed, which is why the reason is written into
`analysis_options.yaml` itself rather than left to be reconstructed.

E01's Risk 3 named this decision as owed and recorded that until it existed the divergence was "a comment
in a file, which is weaker than a decision".

**Applied by:** E01/T02. **Recorded by:** E01/T03.

---

## ~~D-11 — `flutter analyze` gates; `dart analyze` reports, because only it loads the plugins~~

**Decision.** CI runs both. `flutter analyze --fatal-infos` is the release-blocking gate.
`dart analyze` runs immediately after as the single `continue-on-error` step in `validate.yml`, named
"Analyze with plugins (informational until Riverpod lands — D-11)". It is promoted to a blocking gate in
the epic that adds `flutter_riverpod`.

**Why.** `flutter analyze` does not load analyzer plugins; `dart analyze` does. Measured, not assumed:
pointing `import_lint` at a rule `app/lib/main.dart` must violate (`target: package:catchlaw/**.dart`,
`from: package:flutter/**.dart`) produced "No issues found" from `flutter analyze` and
`riverpod_lint`'s `missing_provider_scope` from `dart analyze` on the same tree. The analyzer also accepts
unknown top-level option keys in silence — a planted bogus key drew no diagnostic — so an absence of plugin
output is never evidence a plugin loaded. A workflow running only `flutter analyze` therefore carries a
`plugins:` block that is decoration, which is the failure `FLUTTER_GUIDE.md` Part 4.1 fact 2 describes
arriving through a different door.

`dart analyze` cannot block yet: `riverpod_lint` requires a `ProviderScope` the app cannot have until
`flutter_riverpod` is a dependency, and D-1/T01 defer every `SPEC.md` §10 package to the epic that first
uses it. Suppressing the diagnostic was rejected outright — editing a gate to make a build pass is
forbidden — so the warning stays visible and non-blocking instead.

**Overruled.** `ci-pipeline-and-gates` rule 10 and E01/T03's test 8 as written, both of which forbid
`continue-on-error` anywhere in the workflow. The blanket ban is replaced by a narrower and stronger
assertion: the `flutter` job may contain exactly one `continue-on-error`, it must sit on a step whose name
says `informational`, and the string may appear only once in the whole file. The exception is pinned to one
named step rather than left as a pattern to copy.

**Also recorded.** `import_lint` is inert under both commands — it did not fire even under `dart analyze`
against a target that must match — so its `ui_must_not_import_drift` rule is not the layer-3 guard
`FLUTTER_GUIDE.md` Part 4.6 assumes it is. E01's Risk 2 anticipated the rule *erroring* on its unmatched
`package:catchlaw/ui/**` target; it does nothing at all, which is worse. The remedy Risk 2 prescribes —
move the rule body to E05, where drift arrives and the target exists — stands, better justified.

**Applied by:** E01/T03.

> **SUPERSEDED by D-12, before it ever merged.** Its factual premise was measured on macOS only and is
> false on the runner: `flutter analyze` *does* load analyzer plugins on `ubuntu-24.04`. The first CI run
> failed on `missing_provider_scope` reported by the supposedly plugin-free blocking gate, which is how the
> error was caught. Struck rather than rewritten, per CLAUDE.md's amendment rule.

---

## D-12 — Both analyzers block; `import_lint` waits for E05; Riverpod arrives in E01

**Decision.** Three things, settled together because one measurement produced all of them.

1. **`validate.yml` runs `flutter analyze --fatal-infos` and `dart analyze`, both blocking.** Neither is
   informational, and the workflow carries no `continue-on-error` anywhere — E01/T03's test 8 is restored
   to the blanket ban it was written as.
2. **`import_lint` is removed from the `plugins:` block until E05**, together with its
   `ui_must_not_import_drift` rule body.
3. **`flutter_riverpod: ^3.4.1` is a dependency of `app/` from E01**, and `app/lib/main.dart` wraps the
   root in `ProviderScope`.

**What was measured.** `flutter analyze` loads analyzer plugins on `ubuntu-24.04` and does **not** on a
local macOS checkout of the same commit — verified in both directions, and the local behaviour is
reproducible across a clean `--no-pub` run. An absence of plugin output is therefore never evidence about
whether a plugin ran; only a diagnostic that must fire is. The analyzer also accepts unknown top-level
option keys in silence, so the `plugins:` key being *present* proves nothing either.

**Why `import_lint` goes.** With its rule declared it throws `import_lint is required` out of
`Config.fromAnalysisOptions` for every file analysed under a **nested** options file — it reads the options
file directly rather than the merged view, and `app/`, `packages/rule_engine/` and `tools/content_builder/`
each carry an `analysis_options.yaml` with no `import_lint:` key. That crashes the plugin server and makes
`dart analyze` exit 4. E01's Risk 2 anticipated the rule erroring on its unmatched
`package:catchlaw/ui/**.dart` target and prescribed this exact remedy: move the rule body to E05, where
drift arrives and the target exists, and keep `riverpod_lint` in the block. `FLUTTER_GUIDE.md` Part 4.6's
"Layer 3 — `import_lint`. Verified working." is overruled: it is not working as an analyzer plugin on this
toolchain, and layer 3 is not load-bearing for the offline guarantee, which rests on layers 1, 2 and 4.

**Why Riverpod arrives now.** With the plugin lane genuinely live, `riverpod_lint` reports
`missing_provider_scope` against a root widget that has no `ProviderScope`. The three ways out were to
satisfy it, to remove the plugin, or to suppress the diagnostic. Suppression is forbidden outright —
editing a gate to make a build pass. Removing `riverpod_lint` would contradict E01/T02's committed tests 2
and 3 and leave the block empty. So the lint is satisfied: D-5 already pins Riverpod 3.4.1, and
`catchlaw-conventions-index`'s own worked example is
`void main() => runApp(const ProviderScope(child: CatchlawApp()));`.

**Overruled.** E01/T01's "No dependency from `SPEC.md` §10 is declared yet", and its reasoning that each
arrives in the epic that first uses it. That reasoning was aimed at `flutter_svg` and `printing` dragging
their `http` edges in before T04's gate existed; `flutter_riverpod` has no `http` edge, and E01/T04's own
Risk 6 records that its allowlist otherwise has no live subject at all. The exception is this package only.

**Applied by:** E01/T03 (as a follow-up commit on the same branch, per `CONVENTIONS.md` §1 — the check
failed at step 4 and is fixed forward, never amended).

---

## D-13 — The vendored general Flutter skills live in `.claude/skills-flutter/`

**Decision.** `.claude/skills/` holds exactly the sixteen `catchlaw-*` and `lonja-*` skills this
repository authors. The 33 general Flutter skills, checked in so a fresh clone can read them without a
marketplace fetch, live in `.claude/skills-flutter/`. The `flutter@flutter-skills` plugin declaration in
`.claude/settings.json` stays: it is what keeps them upgradeable and what resolves the `flutter:<name>`
form the task files use.

**Why.** `check_app_invariants.sh` check 9 delegates to **every sibling** `check_*.sh` — it globs
`"$SKILLS_ROOT"/*/scripts/check_*.sh`, where `SKILLS_ROOT` is derived from its own location. With the
general skills as siblings, `check_app_invariants.sh app/lib` also ran their gates, and four of them
failed against E01's tree: `check_routing.sh` wants a `GoRouter` that E12 delivers, `check_arb_parity.sh`
wants an ARB template that E06 delivers, plus `check_adaptive.sh` and `check_forms.sh`. All sixteen of
this repository's own gates passed. The failures were correct statements about a general practice and
wrong questions to ask of a foundation epic.

Editing the skill to scope its fan-out was refused: CLAUDE.md forbids editing a gate to make a build
pass, and E01/T09 is the only task licensed to touch a skill at all. Separating the directories is the
change that makes the gate's existing behaviour correct rather than making the gate lie.

**Consequence.** `CONVENTIONS.md` §7's "sixteen" and CLAUDE.md's "two registries, kept apart by one
rule" become true of the filesystem and not only of the prose. `app/test/policy/skill_gates_test.dart`
requires a table row for **every** check script under `.claude/skills/`, unscoped by prefix, so a general
skill dropped back in fails a test instead of quietly re-breaking the fan-out.

The unnamespaced skill names (`accessibility-as-code`) stop resolving; the namespaced `flutter:` form
(`flutter:accessibility-as-code`) is the one every task file already writes, and it resolves from the
plugin.

**Applied by:** E01/T08.

---

## D-14 — The engine package is `rule_engine`; there is no `catchlaw_shared`

**Decision.** One package for the pure-Dart core: directory `packages/rule_engine/`, pubspec
`name: rule_engine`, imported as `package:rule_engine/rule_engine.dart`. The normalisation fold lives
inside it at `lib/src/search/normalise.dart` and is called `normaliseSpeciesTerm`. There is no
`catchlaw_shared` package and no `packages/shared/` directory.

**Overruled.** `catchlaw-content-pipeline` names two other packages for the same code: rule 9 imports the
fold from `package:catchlaw_shared/text/normalise.dart` and calls it `normalise()`, and rule 10 imports
the engine from `package:catchlaw_rule_engine`. Its `examples/content_builder_assertions.dart` imports
both. That is three names for two things, one of which does not exist.

**Grounds**, all three from documents that outrank the skill:

1. **D-1** places the package at `packages/rule_engine/` and its workspace member list has nowhere to put
   a fourth package. A `catchlaw_shared` member would have to be added to `pubspec.yaml`, and no decision
   adds it.
2. **D-4** sets the precedent that the directory name is the pubspec name — `tools/content_builder/` is
   `name: content_builder`. `packages/rule_engine/` is `name: rule_engine`.
3. **`FLUTTER_GUIDE.md` §2.5 and §2.6** put the one sanctioned barrel at
   `packages/rule_engine/lib/rule_engine.dart`, which resolves as `package:rule_engine/rule_engine.dart`
   and under no other name.

Splitting the fold into a separate `catchlaw_shared` would also buy nothing this repository needs: the
fold's two consumers are the app and `tools/content_builder/`, both of which already depend on
`rule_engine`, and `catchlaw-rule-engine` rule 2's purity guarantee applies to exactly one package.

**Applied by:** E02/T01 through T08, which ship the package and the fold under these names.

**Not corrected here, and it has an owner.** `check_content_pipeline.sh` line 32 carries
`SHARED_RE='packages/shared/|/catchlaw_shared/'`, an exemption for a package that does not exist. It is a
**gate pattern**, and `CLAUDE.md` forbids editing a gate's patterns — the rule exists so nobody widens a
gate to make a build pass, and the honest move when a gate is wrong is to say so rather than quietly
rewrite it. The gate is not failing: an exemption for a path nothing matches is inert, not dangerous.
**E04/T07 already names this** in its own Risks ("catchlaw_shared and the gate exempts packages/shared,
and neither exists here") and is the correction site.

---

## D-15 — The engine's types: `Resolution`, `Finding`, `Ambiguous`

**Decision.** The sealed union `packages/rule_engine/` returns is **`Resolution`**, with variants
`Decided`, `Ambiguous`, `NoRuleFound` and `UnknownSpecies`. The base type of one rule that fired is
**`Finding`**. The disagreeing-tie variant is **`Ambiguous`**.

Each of the three names is settled on its own evidence, because the three conflicts do not have the same
loser:

| Name | Chosen | Losing source |
|---|---|---|
| `Resolution` | `catchlaw-rule-engine`, E03's epic and T02, T05, T10, T11 | **D-7**, which says `Verdict` |
| `Finding` | **D-7**, `catchlaw-verdict-contract`, and E03/T06–T11 | `catchlaw-rule-engine`, which says `RuleFinding` |
| `Ambiguous` | `catchlaw-rule-engine` and E03/T05 | `catchlaw-verdict-contract` rule 6, which says `ConflictingRules` |

**D-7 is amended, not overturned.** Its substance — the engine returns numbers, enums, a required
`Citation` and an `isExpired` flag, and holds no user-visible sentence in any language — is untouched and
is what E03/T10 and E10/T10 enforce. Only the two type names it wrote in passing lose, and they lose
because eleven task files, their test tables and the epic's definition of done were all written against
`Resolution`, while D-7 names the type once and does not depend on it.

**`RuleFinding` has no constituency.** It appears in `catchlaw-rule-engine` and nowhere else: not in D-7,
not in `catchlaw-verdict-contract`, and not once in any of E03's eleven task files.

**On the vocabulary rule.** `CLAUDE.md` requires one word per concept and gives **verdict** for the whole
answer and **finding** for one rule that fired, and `Resolution` is not that word. The rule is about the
word used in *prose, ARB keys and column names* — where "verdict" continues to be the only word, in the
`verdictWarn` token, `lonja-verdict-and-status`, `check_lonja_verdict.sh` and every sentence the app
renders. What this decision fixes is a **class** name in a package the fisher never sees, whose own rule
(D-7) is that it contains no words at all. `finding` keeps its word in both registers.

**Applied by:** E03/T01 through T11.

---
## D-16 — `reference.db` is opened read-only through `NativeDatabase.opened`, not `createInBackground`

**Decision.** `referenceExecutor()` wraps a `sqlite3.open(path, mode: OpenMode.readOnly)` handle in
`NativeDatabase.opened(..., enableMigrations: false, closeUnderlyingOnClose: true)`, inside a
`LazyDatabase`. It does **not** use `NativeDatabase.createInBackground`.

**Losing source:** `catchlaw-reference-database/examples/reference_database.dart` and
`FLUTTER_GUIDE.md` §5.2, both of which write
`NativeDatabase.createInBackground(file, readOnly: true, setup: …)`.

**Why.** That parameter does not exist. drift 2.34.2's `createInBackground` takes `logStatements`,
`cachePreparedStatements`, `setup`, `sqlite3`, `enableMigrations`, `isolateSetup` and `readPool` — and
no `readOnly`. The nearest available thing is a **writable** file handle guarded by
`PRAGMA query_only = 1`, and that is a promise rather than a protection: the operating system would
still permit the write that leaves a `-wal` beside the file. D-6's integrity guarantee is a sha256 over
bytes that must not move, so the guarantee has to live in the handle, not in a pragma the next
`setup` edit could drop.

**The cost, named rather than glossed.** The open runs on the calling isolate instead of a background
one. `LazyDatabase` still defers it to the first **query**, so nothing is awaited before `runApp` —
which is the property §5.2 is actually protecting, and the one `catchlaw-conventions-index` rule 8,
`check_app_invariants.sh` check 8 and E01/T01 test 11 all enforce. If a measured cold-start regression
ever appears, the fix is a background isolate that still opens read-only, not a writable handle.

**What would resolve it.** A `readOnly` parameter on drift's background constructor, or a correction
to the two sources naming `NativeDatabase.opened`. Both are upstream of this repository.

**Applied by:** E05/T01, and by every later task that opens `reference.db`.

---
## D-17 — `user.db`'s migration harness ships without a committed drift snapshot, because `drift_dev schema` cannot run in this workspace

**Decision.** E05/T05 ships the real `MigrationStrategy`, the pre-open snapshot and atomic restore, the
every-pair migration loop and the hostile-fixture content test. It does **not** ship
`app/drift_schemas/user/drift_schema_v1.json`, `user_schema_versions.dart` or the generated era classes
under `app/test/drift/generated/`, and `onUpgrade` dispatches through a hand-written `switch` rather
than drift's `stepByStep`.

**Losing source:** E05/T05's "What this delivers", and `flutter:run-migration`'s prescribed workflow.

**Why — a version constraint, not a preference.** The chain is short and every link is forced:

| Link | Constraint | Set by |
|---|---|---|
| `drift` | **2.34.2** | D-5 |
| `drift_dev` that matches drift 2.34.2 | ≥ 2.34.1, which requires `analyzer ^13.0.0` | pub.dev |
| `flutter_test` | pins `test_api 0.7.11` | the Flutter SDK |
| `test_api 0.7.11` | forces `package:test` 1.31.0 | pub.dev |
| `package:test` 1.31.0 | caps `analyzer` below 13 | pub.dev |

One workspace is one resolution, so `drift_dev` must be **2.34.0** — the last version that accepts an
analyzer this workspace can also give `package:test`. Its code generator works against drift 2.34.2 and
produces the `.g.dart` this epic commits. Its `schema dump`, `schema steps` and `schema generate`
subcommands do **not**: they reach for `GeneratedDatabase.allSchemaEntities`, which drift 2.34.2's
`drift3_preview` shim does not declare, and the tool fails to compile before it reads a line of ours.

`dependency_overrides` would resolve it and D-1 forbids them by name.

**What ships instead, and what it does and does not prove.** The v1 content test writes hostile rows —
an apostrophe, Arabic, an em dash, a backslash, a whitespace-only note — through the current classes,
reopens the file, and reads them back. That proves the schema round-trips the values a
`columnTransformer` mangles silently. It does **not** prove a future migration preserves them, because
`migrateAndValidate` is what compares a committed `CREATE` statement against a live one and there is no
committed statement to compare against.

**What must happen before the first real migration.** E13 or E16 adds the first `from → to` pair, and
before it merges one of these must be true: `package:test` accepts analyzer 13, or `drift_dev` publishes
a release accepting analyzer 12, or the migration is verified by a hand-written before/after fixture
test that opens a v1 file built by this commit's schema. The third is always available and is the
fallback the every-pair loop is shaped for. **A migration that lands with none of the three is a
migration nobody has verified**, and the failure it hides is a fisher's catch log with a column silently
emptied.

**Applied by:** E05/T05, E05/T06. Read by E13 and E16 before either adds a column.

---

## D-18 — `app_pt.arb` ships as the base fallback beside `app_pt_BR.arb`, because `gen-l10n` will not build without it

**Decision.** `app/lib/l10n/` holds **seven** ARB files, not six:

```
app_ar.arb   app_en.arb   app_es.arb   app_gl.arb   app_ca.arb   app_pt.arb   app_pt_BR.arb
```

Six languages, seven files. `app_pt.arb` is a toolchain-required base, carries the same Brazilian
Portuguese text as `app_pt_BR.arb`, and is never the file a translator is pointed at — `app_pt_BR.arb`
remains the one the Brazilian content is authored into.

**Losing source.** D-3's "ARB files are exactly" list, and every restatement of "no `app_pt.arb`":
`epics/E06-localisation/epic.md` (twice), `epics/E16-settings/T02-language-numerals-units.md`,
`epics/E20-rtl-hardening/T02-plural-categories.md`, `epics/E18-about/T05-collected-transmitted-and-no-url.md`.
D-3's *substance* is untouched and is not re-argued: Catalan ships, Urdu does not, the region travels on
Portuguese, and `Locale('pt', 'BR')` is what `supportedLocales` carries.

**Why — the toolchain, not a preference.** On the Flutter pinned by D-5, `gen-l10n` throws before it
generates a line:

```
Arb file for a fallback, pt, does not exist, even though the following locale(s) exist: [pt_BR].
```

`flutter_tools/lib/src/localizations/gen_l10n_types.dart:753` raises it unconditionally — there is no
flag, and `--suppress-warnings` does not reach it because it is an `L10nException`, not a warning. The
same file, at line 662, rejects the obvious dodge: an `@@locale` that disagrees with its filename is
itself an error, so a file named `app_pt.arb` cannot declare `@@locale: pt_BR`. D-3 as written is not
merely inconvenient on this toolchain; it is unbuildable.

**The three options, and why the base file wins.**

| Option | What breaks |
|---|---|
| Seven files: `app_pt.arb` + `app_pt_BR.arb` | D-3's file **count**, and nothing else |
| Six files, Portuguese named `app_pt.arb` | `Locale('pt','BR')` never resolves — D-3's **substance**, and the reason E01/T09 gave for it |
| Six files, `app_pt_BR.arb` alone | does not build |

**The harm D-3 named cannot occur through this file.** E01/T09 justified the region with "a `pt` ARB
resolves on a Portugal-locale device and shows Brazilian state rules to somebody they do not apply to."
Rules do not travel in ARB. Tier 1 is UI chrome (`SPEC.md` §9.2); which jurisdiction's rules are
evaluated comes from the pack and the zone the fisher picks in S9, never from the UI locale. What a
`pt-PT` device actually gets from this base file is Portuguese chrome instead of English chrome, and
Portugal is not a shipped jurisdiction in either case.

**What this obliges.** Every task that adds an ARB key adds it to **seven** files. The parity gate
discovers the seventh by globbing `app_*.arb`, so it needs no edit and cannot be satisfied by six.
`AppLocalizations.supportedLocales` therefore carries seven entries, and E06/T01's test asserts the
seven — with `pt` present *as a base* and `ur` absent — rather than a bare count of six.

**Not amended:** `epics/E01-foundation/T09-correct-skill-locales.md`. Its statements were true when
written, its correction shipped, and the epic is merged; a completed task file is a record of what was
done, not a live instruction.

**Applied by:** E06/T01. Read by every later task that writes an ARB key, and by E20/T02.

---
## D-19 — A non-template ARB carries exactly one `@` block, and only to state the verdict constraint to its translator

**Decision.** Every `app_*.arb` that holds a `verdict*` or `finding*` key carries **one** metadata
block — `@verdictBelowMinimum`, whose `description` opens `STATEMENT OF FACT.` — and no other. The
template `app_en.arb` keeps a block per key, as before. Nothing else about tier-one authoring changes:
`app_en.arb` is still where a key is declared, still the only file carrying placeholders, and still the
file a translator is given alongside the target.

**Losing source.** `app/test/l10n/arb_scaffolding_test.dart`'s *"app_en.arb is the only ARB carrying
@ metadata blocks"*, written in E06/T01. The test is amended in this change rather than deleted: it
still fails on a second block, on a block for any other key, and on a block whose description drops the
constraint.

**Why the test cannot stand as written.** `check_verdict_contract.sh` check 6b globs every `*.arb`
holding a key matching `"(verdict|finding)[A-Za-z0-9_]*"` and fails any one of them that does not
contain the literal `STATEMENT OF FACT`. Parity requires every key in seven files (D-18). So the moment
the first `verdict*` key ships — E10/T01 — six files must carry that string and the test forbids the
only place ARB has to put it. There is no third option: a non-`@` key becomes a message and breaks
parity; a `@@x-…` global still starts with `@` and still fails the test.

**Why the gate wins on substance, not merely on the tie-break.** `verdict-copy-rules.md` says it
outright about the Arabic imperative — «احتفظ به» is short, fluent, exactly what a translator asked for
good Arabic produces, and invisible to every English-language grep: *"Both are caught only by the
`@description` shipping with the key."* The gate's rule is that the constraint travels **with the
translated file**. The test's rule is that duplicated descriptions drift. Both are true, and one block
per file is the smallest thing that satisfies the first while conceding almost nothing to the second —
the block carries no placeholders and no per-key wording, so there is nothing in it to drift out of
step with the template.

D-2's rule of thumb points the same way and is not the argument here: it settles a gate against
*prose*, and this is a gate against a *test*.

**What this obliges.** A task that adds the first `verdict*` or `finding*` key to a locale file adds
the constraint block in the same change. A task that adds any other `@` block to a non-template file is
adding drift, and the amended test still fails it.

**Not amended:** `epics/E06-localisation/T01-arb-scaffolding.md` row 10, on D-18's precedent — its
statement was true when written, it shipped, and the epic is merged; a completed task file is a record
of what was done rather than a live instruction.

**Applied by:** E10/T01, which ships the first `verdict*` keys and amends the test.

---
## D-20 — E10/T02 owns the authored icon family, and the verdict stamp is the one widget allowed to branch on the skin

**Decision.** Three things land together, in `app/lib/theme/`:

1. **`LonjaIcons`, `LonjaIcon` and `LonjaGlyphPainter`** — the authored, stroked family
   `lonja-icons-and-plates` rule 1 requires and no epic owned. E10/T02 ships the four glyphs the
   verdict stamp needs (`tick`, `cross`, `ban`, `closedSeason`); a later task adds a glyph when it has
   a consumer, never before.
2. **`LonjaIconTheme.stroke`** — 1.45 on paper and night, 1.95 in sunlight, constant across all four
   sizes. Plus **`LonjaMotion.haptic`**, 120 ms, because `check_lonja_tokens.sh` check 3 fails a
   literal `Duration` outside `lib/theme/`.
3. **`LonjaSkinScope`** — which skin the subtree renders in, read by exactly one file in the app and
   held to one by `app/test/theme/lonja_icons_test.dart`.

**Losing sources.**

| Source | What loses |
|---|---|
| `epics/E10-result/T02-the-verdict-panel.md` | `Icons.check`, `Icons.block`, `Icons.close` in its test table and outline. `check_lonja_icons.sh` check 5 bans the Material namespace outright, and the task file names that gate itself |
| `catchlaw-conventions-index/references/routing-table.md` | `lib/design/` as the home of icon paths. D-2 puts the design system at `app/lib/theme/`, E07 built it there, and D-1 already overrules the routing table's root-relative `lib/` paths |
| `lonja-verdict-and-status/references/states-and-signals.md` | its sunlight claim of "exactly one chromatic value (`#8E0F0C`)". E07's shipped sunlight palette carries three verdict chromas — `verdant36`, `oxblood28`, `ochre38` — and E07 argued each against `SPEC.md` §13's 7:1 floor. **The palette wins; the sentence is stale.** No greyscale-count test is written against the stale claim |

**Why the family could not be deferred again.** E07 risk 5 left it unowned and named E08 as its first
consumer; E08 shipped one-word text hints and needed no glyph. The verdict stamp cannot: invariant 4
is that colour is never the only signal, and protected and below-minimum share one ink by design —
`states-and-signals.md` spends a whole section on it. Hue therefore carries **zero** information
between them, and what separates them is the glyph, the words and the presence of the measurement
sub-line. Deferring the glyph would have shipped the one screen the product exists for with two of its
three signals.

**Why the skin branch is sanctioned exactly once.** E07's doctrine is that a widget never branches on
the skin — the palette does the work, and a block leaning on `surfaceSunk` also carries a rule because
in sunlight the change of stock does not exist. The sunlight stamp is not a colour swap: it reverses
out onto a solid ground and gives up its tilt, because at 100 000 lux a hairline frame around tilted
ink is absent rather than dim. That is a change of **construction**, and no palette entry can express
one. A fifteenth token was rejected: E07 froze fourteen against a test, and "stamp ground" would be a
slot that is transparent in two of three themes — a token whose value is "do not use me here".

**What this obliges.** A glyph is added to `LonjaIcons` by the task that renders it. A second reader of
`LonjaSkinScope.of` fails `lonja_icons_test.dart`, and the right answer is nearly always a palette
entry instead. `token-tables.md` has no row for the icon stroke or the haptic gap — the outstanding
skill correction E07 risk 5 asked for, still needing a task ID, like `product-invariants.md` §1.

**Applied by:** E10/T02.

---
## D-21 — `flutter_svg` reaches `http` through `vector_graphics` too, and a recorded edge whose PARENT does not ship is a failure

**Decision.** `tools/gates/allowlist/transitive_edges.txt` records, from this commit:

```
http <- flutter_svg
http <- vector_graphics
url_launcher_platform_interface <- share_plus
```

`http <- printing` is **commented out** and is re-recorded by E17, in the commit that adds
`printing`. A line is added by the epic that lands its package, not before.

**Losing sources.**

| Source | What loses |
|---|---|
| `SPEC.md` §14 and §10 | their http-edge list. Both name `flutter_svg` as the parent; the resolved graph on `flutter_svg ^2.0` has **two** — `flutter_svg` directly, and its own `vector_graphics`. The recorded set was incomplete rather than wrong |
| `tools/gates/allowlist/transitive_edges.txt`'s own E01 header | *"A recorded edge whose package is not in the shipping set is simply not checked, so the lines are inert until the package lands."* True of the **child**, false of the **parent** |

**Why the header was wrong.** The gate skips an edge only when its *child* is absent
(`if pkg not in ships: continue`, line 272). Once `http` ships, it compares the whole recorded parent
set against the shipping one, so `http <- printing` becomes a failure the moment any other package
pulls `http` in — which is exactly what adding `flutter_svg` did. The claim was never checked against
the gate, and D-2's rule of thumb settles it: the gate wins.

**Why the second parent is not a hole in invariant 1.** `vector_graphics` is inside `flutter_svg`'s
own package family — `flutter_svg → vector_graphics → http` — and both entry points that would use it
are grep-banned by `catchlaw-offline-guarantee` and by `check_no_network.sh`, which is green over
`app/lib`. What widened is the RECORD of the graph, not the guarantee: no HTTP client is constructed,
no fetching symbol is reachable, and the release Android manifest still grants no INTERNET permission.

**What this obliges.** The epic that adds `printing` or `share_plus` re-records its edge in the same
commit, regenerates `tools/gates/testdata/deps/deps_clean.json` from `dart pub deps --json`, and
re-runs `dart pub deps --json | python3 tools/gates/check_dependency_allowlist.py --write`. A resolver
upgrade that adds a third parent for `http` fails the gate, and that is the point.

**Applied by:** E10/T04, which adds `flutter_svg` for the measurement diagram.

---
## D-22 — `epics/RELEASES.md` is the release order, and it overrules `README.md`'s build order

**Decision.** The remaining ninety tasks are split into **v1 (thirteen tasks)** and **v2 (seventy-nine)**,
recorded in `epics/RELEASES.md`. Where the release order and the build order disagree, the release
order wins. Two tasks are added — `E12/T08` and `E22/T10` — and nothing is renumbered.

**Losing source.** `epics/README.md`'s *"22 epics, 181 tasks, hard dependencies… Building starts at
E01"* and the strict epic-by-epic order it implies, restated in `CLAUDE.md`. Its **substance** is
untouched: the dependency edges are real, E22 still runs in parallel from E04, and no v1 task is built
before an epic it depends on. What loses is the assumption that every task of an epic is built before
the next epic begins.

**Why the order had to bend.** Ten epics are merged and there is no application. `flutter run` opens a
window holding a `SizedBox.shrink()`. Everything E06 through E10 built is unreachable, and three
things stand between the tree and a working app:

1. **Nothing evaluates a rule.** No provider, no use case and no screen turns a species, a zone and a
   date into a `Resolution`. `E12/T02` and `E12/T07` both assume the seam exists; neither delivers it,
   and no other task in the plan does either. It is now `E12/T08`, and it is built first.
2. **The pack carries one species and no rule rows at all.** Every answer the app can currently give
   is `NoRuleFound` — which is honest, and useless. It is now `E22/T10`.
3. **`home:` is an empty box.** `E12/T01`.

Under a strict epic-by-epic order, reaching those three means building E11 whole (polygons with no
coordinate lists to test against, GPS whose denial must cost nothing) before E12 starts. Under the
release order it means thirteen tasks.

**Why v1 is Galicia and not the Gulf.** The product's headline case is Khalid in Ras Al Khaimah, and
v1 does not serve him. It ships Galicia because Galicia is what the repository already has seeded — a
jurisdiction, a zone, strings and a species — so the distance from here to a cited verdict is one
`rules.yaml` and its verbatim text. The Gulf pack is the first task of v2, and `RELEASES.md` says so
where it can be read rather than discovered.

**What this does not license.** No invariant is deferred. v1 has no network code, states facts and
never instructs, carries a required `Citation` on every finding, never spends colour as its only
signal, and evaluates an expired ruleset rather than withholding it — all five hold in the thirteen
tasks exactly as they hold in the ten merged epics. What v2 adds is *proof*: the greyscale golden, the
six-locale matrix, the packet capture. Writing a guarantee and proving it are different jobs, and only
the second one is deferred.

**Applied by:** this change, which adds `epics/RELEASES.md`, a `Release` column to `epics/README.md`,
a `Release:` line to each unmerged epic, and a deferral line to each v2 task inside a split epic.

---
