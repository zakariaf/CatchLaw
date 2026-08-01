# E01 — Foundation, workspace and the offline gates

Closes the first epic of `epics/README.md`. Nine tasks, one commit each, every `Task: E01/Tnn` trailer present.

## What changed

The repository became a Dart pub workspace with four members — `app/` (the Flutter app),
`packages/rule_engine/` (pure Dart), `packages/analysis_defaults/` (shared lints) and
`tools/content_builder/` (the CLI) — on Flutter 3.44.6 / Dart `^3.12.0`, with one committed
`pubspec.lock`. `.github/workflows/validate.yml` gained a `format · analyze · test` job carrying the
dependency-allowlist diff, the `SPEC.md` §14 banned-API grep, and a runner for all sixteen skill gates that
fails when a gate scans an empty tree; plus an `android-release-manifest` job that reads the merged manifest
off a built AAB. The Android shipping manifests removed `android.permission.INTERNET` and disabled backup;
the iOS `Info.plist` gained two usage strings in six locales and a written statement of what iOS cannot
prove. Four files under `.claude/skills/` were corrected to the six shipped locales and the content
builder's real name.

Nothing a user can see is built here. What a later epic can rely on is that `packages/rule_engine/` cannot
import Flutter, that every member shares one lint config, that every one of the sixteen skill gates runs
against its real target directory on every PR, and that a gate which scans nothing is a failure rather than
a pass.

## Why

`SPEC.md` §15 step 1 requires every §14 static check wired in from commit one so the offline guarantee can
never regress. §5.3 records that the first draft's claim "no HTTP client is linked" was **false** —
`printing` and `flutter_svg` both declare `http` — so the guarantee is not "no client exists" but "exactly
two transitive edges exist, they are diffed on every PR, and every API that could reach them is
grep-banned". That correction is why the allowlist gate is edge-level rather than a one-line pubspec grep.

## How it was verified

Each new gate was proved **red against a planted violation** before it was proved green:

| Gate | Proved red by |
|---|---|
| dependency allowlist | `http: ^1.5.0` added to `app/pubspec.yaml` on the live graph — named three ways, then reverted |
| banned-API grep + layer-4 guard | `HttpClient()` pasted into `app/lib/main.dart` — both turned red naming `main.dart:10` |
| Android manifest | the merged manifest read off the built AAB, not off our source |
| skill-gate runner | row 1 pointed at an empty directory (`scanned 0 files`) and at a missing one |
| nested-options trap | the `include:` line removed from `packages/rule_engine/analysis_options.yaml` |
| `check_no_network` check 2 | the restated `depend_on_referenced_packages: error` removed from `app/analysis_options.yaml` |
| iOS absence keys | `NSAppTransportSecurity`, `NSPhotoLibraryUsageDescription` and the always-location key each planted |
| debug/profile INTERNET grants | the template's grants deleted — the tests assert the grant is **present** |

Six things were learned by executing rather than assuming, and each changed the work:

1. **`aapt2` cannot read an AAB.** `SPEC.md` §14 bullet 3 names it; it answers "could not identify format of
   APK", and the prescribed `grep -q INTERNET` over that error text finds nothing and **reports success**.
   `apkanalyzer` was worse — it printed an `ERROR` and exited `0`. The job uses `bundletool` and asserts the
   dump produced a manifest before trusting any grep over it.
2. **`flutter analyze` loads analyzer plugins on `ubuntu-24.04` and not on macOS.** The first CI run failed
   on a diagnostic the local machine never showed. Both analyzers now block (D-12).
3. **`import_lint` crashes the plugin server** — `import_lint is required`, thrown for every file under a
   nested options file, exit 4. Deferred to E05 exactly as Risk 2 prescribed.
4. **`dart pub deps --json` has two shapes**, and a workspace emits the one with no `direct`/`dev` kinds at
   all. The gate handles both (Risk 5, arriving early).
5. **The six iOS localizations did not ship.** All twelve `Info.plist` assertions passed while
   `Runner.app` contained only `Base.lproj`; creating `.lproj` directories is not what ships them. Caught by
   building on a Mac and listing the bundle.
6. **The gate runner had its own failure mode inside it** — `while read` dropped the final line of a table
   with no trailing newline, silently never running the sixteenth gate.

`dart pub get` at the root resolves to one `pubspec.lock` and one `.dart_tool/`. `dart format
--set-exit-if-changed .`, `flutter analyze --fatal-infos` and `dart analyze` are clean across four members.
131 tests pass. All sixteen skill gates report a non-zero scanned-file count.

## Product invariants touched

None weakened. Invariant 1 (no network code path) is the subject of T04, T05 and T06 and is strengthened
from a statement into three failing checks. Invariants 2–5 are untouched: this epic adds no user-visible
string, no verdict type, no colour and no expiry handling.

## Decisions raised

Four new entries in `epics/DECISIONS.md`, each with the losing source named:

- **D-10** — lints build on `flutter_lints`, not `very_good_analysis` (the divergence E01's Risk 3 said was
  owed).
- **~~D-11~~** — struck before it ever merged. Its premise was measured on macOS only and is false on the
  runner; superseded rather than quietly rewritten.
- **D-12** — both analyzers block; `import_lint` waits for E05; `flutter_riverpod` and a `ProviderScope`
  arrive in E01 because satisfying `riverpod_lint` was the only option that was not suppression.
- **D-13** — the vendored general Flutter skills move to `.claude/skills-flutter/`, because
  `check_app_invariants.sh` check 9 fans out to every *sibling* gate.

## Follow-ups deliberately not in this PR

- **The iOS and Android packet captures** — E21. `SPEC.md` §11 is explicit that the iOS half of the
  guarantee rests on them, and CI on Linux cannot produce either.
- **Layer 3 is not a proof.** ATS is left at its strict default and no `NSAppTransportSecurity` key is
  declared. `Info.plist` says so, with the four false claims tabulated.
- **`flutter run` hot reload** was not confirmed on hardware this session; the debug/profile grants it
  depends on are in place and asserted by tests.
- **The directional-padding grep** — D-8, E06/T05. There is no UI to scan yet.
- **The routing table's root-relative paths** — D-1, still owed a task ID.
- **`catchlaw-content-pipeline`'s locale list, gender set and `content_build` naming**, plus five more files
  — all six are listed in `tools/gates/known_skill_drift.txt` with their owning epic, and a test asserts the
  set matches reality exactly.
- **The codegen freshness gate** — there is no generated code until E05.
- **App version metadata** (`CFBundleShortVersionString`) — E21.
