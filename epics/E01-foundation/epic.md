# E01 — Foundation, workspace and the offline gates

| | |
|---|---|
| **Branch** | `epic/01-foundation` |
| **After** | nothing — this is the first epic |
| **Tasks** | 9 |
| **Spec** | `SPEC.md` §10 (tech stack), §11 (Android and iOS in full), §14 static block, §15 step 1, §5.3 (the offline guarantee stated accurately) |
| **Guide** | `FLUTTER_GUIDE.md` Part 2.4, Part 2.5, Part 4.1–4.7 |
| **Members** | the workspace root, `app/`, `packages/rule_engine/`, `packages/analysis_defaults/`, `tools/content_builder/` |

## What this epic achieves

When this merges, the repository resolves as a single Dart pub workspace with four members and one
`pubspec.lock`, and the offline guarantee has stopped being a sentence in `SPEC.md` and become three
running checks. A pull request that adds `http` to `app/pubspec.yaml`, that lets a third package pull
`http` transitively, that writes `Image.network` into `app/lib`, or that lets `android.permission.INTERNET`
back into a shipping manifest cannot go green. Nothing a user can see is built here. What a later epic can
rely on is that `packages/rule_engine/` cannot import Flutter, that every member shares one lint config,
that every one of the sixteen skill gates runs against its real target directory on every PR, and that a
gate which scans nothing is a failure rather than a pass.

This epic writes almost no Dart. Its output is a workspace that resolves and a CI that fails loudly.

## Where we are now

The branch is cut from a `main` that holds documents and no code:

- `SPEC.md`, `FLUTTER_GUIDE.md`, plus `IDEAS.md`, `SHORTLIST.md`, `REVIEW-CHANGES.md`,
  `OFFLINE_APP_IDEA_RESEARCH.md`, `README.md` and the `research/`, `research-flutter/`,
  `research-skills/`, `design/` trees.
- `epics/CONVENTIONS.md`, `epics/DECISIONS.md`, `epics/README.md`, `epics/TEMPLATE.md`.
- `.claude/skills/` — sixteen skills, each shipping a runnable `scripts/check_*.sh` that takes an
  optional target directory and exits 2 when it does not exist.
- `.github/CODEOWNERS`, `.github/pull_request_template.md`, `.github/workflows/validate.yml`.

There is **no** `pubspec.yaml`, no `app/`, no `packages/`, no `tools/`, no `.dart_tool/`, no Dart file
anywhere. `.gitignore` already ignores `.dart_tool/`, `build/`, `coverage/` and `**/failures/`, already
declines to ignore generated Dart (`FLUTTER_GUIDE.md` Part 7.4 commits it), and does **not** ignore
`pubspec.lock` — which is correct for an application and must stay that way.

Two facts about `validate.yml` that this epic changes the meaning of, and that T03 and T04 must handle
rather than inherit:

- Its `invariants` job's "No imperative verdict strings" step is guarded by
  `if [ ! -d lib ] && [ ! -d app ]`. It has never scanned anything. From T01 onward `app/` exists and the
  step starts doing work.
- Its "No networking dependency" step greps the **root** `pubspec.yaml`. After T01 that file is the
  workspace root, which by design declares no dependencies at all — so the step becomes structurally
  incapable of failing. It is kept (it still guards the root against a stray dependency) but it stops
  being the check that matters. The real dependency list moves to `app/pubspec.yaml` and is covered by
  T04.

## Why this epic exists here in the order

`SPEC.md` §15 step 1 puts skeleton and CI first and states the reason plainly: *every §14 static check
wired in from commit one, so the offline guarantee can never regress*. That is a dependency, not a
preference. A gate added after the code it governs has to be introduced against a tree that already
violates it, and the resolution is always to weaken the gate.

Every other epic also needs a package to live in. `epics/README.md` makes E02 depend on E01 and everything
else transitively; `packages/rule_engine/` cannot hold a normalisation function until T01 has created it,
and E02's zero-Flutter guarantee is delivered by T01's pubspec rather than by anything E02 writes
(`FLUTTER_GUIDE.md` §4.6 layer 1).

It also cannot come later than the first line of Dart for a narrower reason: `FLUTTER_GUIDE.md` §4.3's
nested-options trap (T02) silently drops every configured rule in `packages/rule_engine/`. Discovered in
E03, that is a package's worth of code analysed under a config nobody chose.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | Workspace skeleton and the toolchain floor | `T01-workspace-skeleton.md` | M | — |
| T02 | Shared lints and the nested-options trap | `T02-shared-lints.md` | M | T01 |
| T03 | CI: format, analyze and test across every workspace member | `T03-ci-format-analyze-test.md` | M | T01, T02 |
| T04 | CI: the direct-dependency allowlist diff | `T04-ci-dependency-allowlist.md` | L | T01, T03 |
| T05 | CI: the banned-API grep and the layer-4 guard test | `T05-ci-banned-api-grep.md` | S | T01, T03 |
| T06 | Android: the release manifest without INTERNET | `T06-android-release-manifest.md` | M | T01, T03 |
| T07 | iOS: usage strings, and the honesty about what iOS cannot prove | `T07-ios-usage-strings.md` | M | T01, T03 |
| T08 | Wire the sixteen skill gates into CI, and prove they scanned something | `T08-skill-gates-in-ci.md` | L | T02, T03, T05, T06 |
| T09 | Correct the skills that disagree with the spec | `T09-correct-skill-locales.md` | S | T01 (its tests live in `app/test/policy/`) |

**A note on commit scopes.** `CONVENTIONS.md` §3 lists `rule_engine`, `content_builder`, `theme`, `check`,
`ruler`, `l10n`, `data`, `ci` as examples of "the package or feature". E01 introduces packages that did not
exist when that list was written, so it also uses `workspace`, `android` and `ios`. No other scope is
invented anywhere in this epic.

## Definition of done for the epic

Every task's own definition of done (`CONVENTIONS.md` §8 plus the task file), and additionally:

- [ ] All 9 tasks committed, one commit each, every `Task: E01/T<nn>` trailer present.
- [ ] `dart pub get` at the repository root resolves with no `dependency_overrides`. Exactly one
      `pubspec.lock` and exactly one `.dart_tool/` exist, both at the root, and `pubspec.lock` is tracked.
- [ ] `dart format --output=none --set-exit-if-changed .` and `flutter analyze --fatal-infos` are clean
      across all four members.
- [ ] `packages/rule_engine/pubspec.yaml` declares no `flutter` dependency. The purity of the engine is a
      compile-level guarantee (`FLUTTER_GUIDE.md` §4.6 layer 1), not a grep result.
- [ ] Three of the four offline layers are live and red on a planted violation: **layer 1** the undeclared
      dependency plus the allowlisted transitive edges (T04), **layer 2** the absent Android INTERNET
      permission, proved on a built AAB (T06), **layer 4** the guard test and the §14 grep over `app/lib`
      (T05). **Layer 3** is recorded as not a proof (T07). The device packet capture is E21.
- [ ] All sixteen `.claude/skills/*/scripts/check_*.sh` run in CI against their real target directories,
      and every one reports the number of files it scanned. A row that scanned zero files fails the job
      (T08, `CONVENTIONS.md` §7).
- [ ] The four skill files T09 names carry no `app_ur.arb`, no `app_pt.arb`, no `packages/content_build/`
      and no `content_build` executable (D-3, D-4). Every remaining file that still does is listed in
      `tools/gates/known_skill_drift.txt` with the epic and task that fixes it, and a test asserts that set
      does not grow.
- [ ] The five product invariants in `CONVENTIONS.md` §9 are untouched. E01 adds no user-visible string,
      no verdict type and no colour.
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin --delete-branch` (D-9); branch deleted.

## Risks and the things that will bite

1. **`flutter analyze` at a workspace root that is not a Flutter package.** The root `pubspec.yaml` is
   `catchlaw_workspace` and declares no `flutter` dependency. Whether `flutter analyze --fatal-infos`
   invoked there analyses all four members in one context is not verified anywhere in `FLUTTER_GUIDE.md`.
   *Resolved by:* running it once against the real tree in T03. If it does not cover every member, T03
   falls back to one analyze step per member and the workflow says why.

2. **`import_lint` has no target yet.** `FLUTTER_GUIDE.md` §4.3's `plugins:` block declares
   `ui_must_not_import_drift` over `package:catchlaw/ui/**.dart` — a directory that does not exist until
   E08, against `package:drift`, which is not a dependency until E05. Part 4 states the config was executed
   with zero `undefined_lint`, but not against an empty target set. *Resolved by:* T02's definition of done
   requires `flutter analyze` to emit zero plugin diagnostics. If the rule errors on an unmatched target,
   the rule body moves to E05 and the `plugins:` block keeps only `riverpod_lint` — recorded in T02's
   commit body, not silently dropped.

3. **A tenth conflict, not in `DECISIONS.md`.** `lint-and-style-config` rule 2 requires building on
   `very_good_analysis` with a version-stamped include. `FLUTTER_GUIDE.md` Part 4.2 rejects VGA for a
   private app — it turns on `public_member_api_docs`, `lines_longer_than_80_chars`,
   `require_trailing_commas` and `discarded_futures`, and still ships two rules deprecated in the 3.13
   cycle — and builds on `flutter_lints` instead. T02 follows `FLUTTER_GUIDE.md`, because Part 4 was
   executed against Dart 3.12.2 and this epic's brief makes the guide authoritative for how code is
   written, and it records the divergence in `analysis_options.yaml` itself. *Resolved by:* adding a
   `D-10` to `DECISIONS.md`. Until that exists the divergence is a comment in a file, which is weaker
   than a decision and is named here for that reason.

4. **A member with no test suite.** `packages/analysis_defaults/` ships a YAML file and no Dart, so it has
   no suite. A member with no suite and a member whose CI line was deleted look identical. *Resolved by:*
   T03 carries an explicit `no-suite` list in the workflow and a policy test asserting
   `members == suites ∪ no-suite`.

5. **`dart pub deps --json` is a schema T04 depends on.** The gate reads `packages[].kind` ∈
   `{root, direct, dev, transitive}` and `packages[].dependencies`, the same keys
   `dependency-hygiene/scripts/audit_deps.py` reads. A future SDK that changes the shape would leave the
   gate walking an empty graph and reporting success. *Resolved by:* T04 tests 9 and 10 — an empty
   allowlist fails, and unparseable input fails.

6. **The http edges do not exist yet.** `printing`, `flutter_svg` and `share_plus` are not dependencies
   until E17, E08 and E17 respectively, so at E01 the transitive-edge check has no live subject.
   *Resolved by:* T04 is proved against checked-in `dart pub deps --json` fixtures, and the allowlist file
   is regenerated in the epic that adds each package. The fixture set is the evidence the gate works
   before its subject arrives.

7. **Nothing iOS can be built on the Linux runner.** T07's deliverables are verified by a source-level
   policy test only. That is not a gap being hidden — `SPEC.md` §11 says outright that the first draft's
   proposed iOS proofs were worthless and that the iOS guarantee rests on the dependency allowlist plus a
   mandatory device packet capture. *Resolved by:* E21. T07 states the limit in the plist itself.

8. **D-1 names E01/T09 as its skill-correction site; this epic's task list scopes T09 to D-3 and D-4.**
   The routing table's layer map still places the app at the repository root (`lib/`, `assets/`) and T09
   does not change those rows — it changes only the ARB filenames, the RTL-lane wording and the content
   builder's name and path. The rows remain overruled by D-1 and are not load-bearing for any gate, since
   D-1 already records that no script needs editing. *Resolved by:* a line in `DECISIONS.md` naming the
   task that rewrites the routing table's root-relative paths. Widening T09 here would change what the
   task covers, which the plan forbids.

9. **The same two defects run deeper in `catchlaw-content-pipeline` than T09 may reach.** That skill's
   shipped-locale list is `['ar','en','es','gl','pt_BR','ur']`, its gendered-locale set includes `ur` and
   omits `ca`, its build-assertions table carries a row justifying `ur` as a "Gulf crew language", and it
   names the CLI `tools/content_build` throughout — including in a runnable example. Correcting it means
   deciding Catalan's gender rule and removing a locale from a build assertion, which are content
   decisions, and the skill is a `.github/CODEOWNERS` legal-liability surface. D-4 names **E04/T01** and
   D-3 names **E06/T01** as the appliers. *Resolved by:* `tools/gates/known_skill_drift.txt`, written in
   T09, which lists every remaining file with its owning epic, and a test that fails if the set grows. It
   is a scheduled correction with a test behind it, not an omission.

10. **`check_app_invariants.sh` fans out.** Its check 9 delegates to every sibling `check_*.sh` with the
    **same** target, so `check_app_invariants.sh app/lib` runs the engine and content-pipeline gates over
    the app tree. It also derives `ROOT` as `dirname(TARGET)`, so with `app/lib` it finds only
    `app/pubspec.yaml` and prints `no rule_engine package found … layer check skipped`. A green run of that
    one script is therefore **not** coverage of the engine. *Resolved by:* T08's table runs
    `check_rule_engine.sh packages/rule_engine/lib` and `check_content_pipeline.sh tools/content_builder`
    as their own rows.

11. **Flutter 3.44.6 must be fetchable by `subosito/flutter-action@v2` on `ubuntu-24.04`.** D-5 records the
    version as verified stable on 2026-07-08, but availability to that action on that image is not
    verifiable from here. *Resolved by:* the first run of T03's job. If the version is not published for
    the runner, `.fvmrc` and D-5 need revisiting together — not `.fvmrc` alone.

## PR description

### What changed

The repository became a Dart pub workspace with four members — `app/` (the Flutter app),
`packages/rule_engine/` (pure Dart), `packages/analysis_defaults/` (shared lints) and
`tools/content_builder/` (the CLI) — on Flutter 3.44.6 / Dart `^3.12.0`. `.github/workflows/validate.yml`
gained four jobs: format/analyze/test across every member, the direct-dependency allowlist diff, the
`SPEC.md` §14 banned-API grep with the layer-4 guard test, and a runner for all sixteen skill gates that
fails when a gate scans an empty tree. The Android shipping manifests removed `android.permission.INTERNET`
and disabled backup; the iOS `Info.plist` gained two usage strings in six locales and a written statement
of what iOS cannot prove. Four files under `.claude/skills/` were corrected to the six shipped locales and
the content builder's real name.

### Why

`SPEC.md` §15 step 1 requires every §14 static check wired in from commit one so the offline guarantee can
never regress. §5.3 records that the first draft's claim "no HTTP client is linked" was **false** —
`printing` and `flutter_svg` both declare `http` — so the guarantee is not "no client exists" but "exactly
two transitive edges exist, they are diffed on every PR, and every API that could reach them is grep-banned".
That correction is why the allowlist gate exists at all rather than a one-line pubspec grep.

### How it was verified

`dart pub get` at the root resolves to one `pubspec.lock` and one `.dart_tool/`. `dart format
--set-exit-if-changed .` and `flutter analyze --fatal-infos` are clean across four members. Each new gate
was proved red against a planted violation before it was proved green: checked-in `dart pub deps --json`
fixtures for the third http edge, the direct `http` and the dev-only edge; Dart fixture files for each of
the fifteen §14 needles; an empty directory for every skill gate. The Android claim is read off a built
release AAB with `aapt2 dump xmltree`, not off the source manifest. The iOS claim is read off
`Info.plist` and is explicitly **not** a proof — see below.

### Product invariants touched

None weakened. Invariant 1 (no network code path) is the subject of T04, T05 and T06 and is strengthened
from a statement into three failing checks. Invariants 2–5 are untouched: this epic adds no user-visible
string, no verdict type, no colour and no expiry handling.

### Follow-ups deliberately not in this PR

- **The iOS packet capture** (`rvictl -s` + Wireshark) and the Android PCAPdroid capture — E21. `SPEC.md`
  §11 is explicit that the iOS half of the guarantee rests on them, and CI on Linux cannot produce either.
- **Layer 3 is not a proof.** ATS blocks cleartext only; it is left at its strict default and no
  `NSAppTransportSecurity` key is declared. T07 says so in the plist.
- **The directional-padding grep** `tools/gates/no_directional_geometry.sh` — D-8, E06/T05. There is no UI
  to scan yet.
- **The routing table's root-relative paths** in `catchlaw-conventions-index` — D-1, see Risk 8.
- ~~**`catchlaw-content-pipeline`'s locale list, gender set and `content_build` naming** — D-3 (E06/T01)
  and D-4 (E04/T01).~~ **Done in the E01 close-out instead.** The deferral rested on the gendered-locale
  set being an open content decision; it is not — `SPEC.md` §9.5 line 815 names the gendered locales and
  §9.1 line 840 justifies Catalan, both already written. `tools/gates/known_skill_drift.txt` is now empty
  and the test asserts the stale set equals it, so the register went from "these six are excused" to "no
  file may carry the old wording". Risk 9 is closed. The close-out also caught an eighth-place path drift
  the register never tracked: `assets/reference.db` for `app/assets/db/reference.db`.
- **The codegen freshness gate** (`build_runner` + `git diff --exit-code`) — there is no generated code
  until E05.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch` (D-9); then and only then start E02.
