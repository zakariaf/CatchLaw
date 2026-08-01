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

RTL golden lanes: **`ar` only**. There is one RTL locale in this product.

**Source.** `SPEC.md` §9.1, which justifies each locale by the publication language of the instrument
being bundled — Catalan because Catalonia, Valencia and the Balearics publish their fishing orders in
Catalan.

**Overruled.** Three places in the skills name `app_ur.arb` and speak of "Arabic and Urdu RTL lanes":
`catchlaw-conventions-index/SKILL.md` rule 12, its `references/routing-table.md`, and a report label in
`scripts/check_app_invariants.sh`. Urdu appears nowhere in `SPEC.md` and no bundled instrument is
published in it. `catchlaw-verdict-contract/SKILL.md` says `app_pt.arb`; the correct filename carries
the region, `app_pt_BR.arb`, because the content is Brazilian and not Iberian Portuguese.

**Applied by:** E06/T01. **Skill correction:** E01/T09 — four files, `ur` → `ca`, `app_pt` → `app_pt_BR`.

---

## D-4 — The content builder is `tools/content_builder/`, package `content_builder`

**Decision.** One name: directory `tools/content_builder/`, pubspec `name: content_builder`,
executable `dart run content_builder:build`.

**Overruled.** `SPEC.md` §8 says `tools/build_content/`; the skills say `packages/content_build/`.
Three names for one deliverable was going to cost somebody an afternoon.

**Applied by:** E04/T01.

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

**Decision.** `packages/rule_engine/` returns sealed `Verdict` and `Finding` values carrying numbers,
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
