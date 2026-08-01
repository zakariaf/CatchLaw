# E21/T01 — The static block, automated against the built artefact

| | |
|---|---|
| **Epic** | E21 — Offline verification and release readiness |
| **Branch** | `epic/21-release` (shared) |
| **Commit** | `ci(ci): gate the release AAB manifest, the iOS plist and the dependency allowlist` |
| **Depends on** | — (first task of the epic; E20 merged) |
| **Size** | M |
| **Spec** | `SPEC.md` §14 static block (all five rows), §11 Android and iOS, §5.3 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-offline-guarantee` | Owns layer 2 (the absent permission) and the transitive allowlist. `references/four-layers.md` holds the merger rules and the exact allowlist table this gate diffs against |
| `ci-pipeline-and-gates` | Rules 1, 2, 3, 7, 9, 10: one gate per named contract, pinned runner and toolchain, `# VERIFY:` on an unconfirmed action version, the three-criteria bar for a grep gate, and gates that verify rather than bless |
| `dependency-hygiene` | Rules 6 and 7 and the refuse-outright list: the transitive tree is where a banned SDK arrives, and the audit reads `dart pub deps`, never `pubspec.yaml` |
| `catchlaw-conventions-index` | Invariant 1 and the routing tie-break — anything about the absence of network routes to `catchlaw-offline-guarantee`, so this task adds no rule of its own |
| `testing-strategy` | Which tier a shell gate belongs at: a policy test under `test/policy/` that shells out, not a widget test |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §14 "Static (CI — these fail the build)" | The five rows, verbatim, including the exact three allowlisted transitive edges |
| `SPEC.md` | §11 Android | The release-manifest element and `xmlns:tools`; the permission list that IS allowed (`ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`, `CAMERA`) |
| `SPEC.md` | §11 iOS | The two declared usage strings, and that `NSLocationAlwaysAndWhenInUseUsageDescription` is not declared |
| `SPEC.md` | §5.3 | Why the allowlist is two named edges and not "http is fine" |
| `FLUTTER_GUIDE.md` | Part 4.6 layer 2, Part 9.3 | Why the built manifest is the only third-party-verifiable layer, and why `debug/` keeps `INTERNET` |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "Layer 2 — the Android manifest and the merger", "The transitive allowlist" | The four source sets and their INTERNET policy; the three-row allowlist table this gate is the executable form of |
| `.claude/skills/catchlaw-offline-guarantee/SKILL.md` | rules 3, 4, 8 | `tools:node="remove"` in main and release; debug and profile keep INTERNET; a transitive edge is an allowlist entry |
| `ci-pipeline-and-gates` → `references/policy-grep-gate.md` (Flutter-Skills plugin) | "The three-criteria bar", "Strip comments first" | Why each check here qualifies, and `codeOf` / `xmlOf` comment stripping before matching |
| `dependency-hygiene` → `references/dependency-gate-and-audit.md` (Flutter-Skills plugin) | "Auditing the tree, not the pubspec" | `dart pub deps --json` as the input, and that the second hop is where the banned SDK arrives |
| `epics/CONVENTIONS.md` | §7 | Gate scripts take an explicit target and exit 2 when it is missing |
| `epics/DECISIONS.md` | D-1, D-5 | Paths (`app/`, `tools/gates/`) and the pinned Flutter 3.44.6 |

## What this delivers

- `.github/workflows/release-gates.yml` — a second workflow, separate from the fast per-PR one, with
  one job that builds `flutter build appbundle --release` from `app/` and three gate steps over the
  result. Pinned `runs-on: ubuntu-24.04` and `subosito/flutter-action@v2` with
  `flutter-version: '3.44.6'` (D-5).
- `tools/gates/check_release_aab_manifest.sh` — takes the AAB path, resolves `aapt2` from
  `$ANDROID_HOME/build-tools/*/aapt2`, runs
  `aapt2 dump xmltree <aab> --file base/manifest/AndroidManifest.xml`, and fails on
  `android.permission.INTERNET` or `android.permission.ACCESS_BACKGROUND_LOCATION`.
- `tools/gates/check_ios_privacy_plist.sh` — takes the plist path; fails on any ATS exception key
  (`NSAppTransportSecurity`, `NSAllowsArbitraryLoads`, `NSAllowsArbitraryLoadsInWebContent`,
  `NSAllowsLocalNetworking`, `NSExceptionDomains`) or on
  `NSLocationAlwaysAndWhenInUseUsageDescription`.
- `tools/gates/check_dependency_allowlist.sh` — takes the app directory; runs `dart pub deps --json`,
  collects every edge whose target is `http` or `url_launcher_platform_interface`, and diffs the set
  against `docs/deps-allowlist.txt`. Any edge not in the file, and any edge in the file that has
  disappeared, is a failure.
- `docs/deps-allowlist.txt` — three lines: `printing -> http`, `flutter_svg -> http`,
  `share_plus -> url_launcher_platform_interface`.
- `docs/release/spec-14-coverage.md` — the §14 static row → workflow job → step-name map.
- `app/test/policy/release_artifact_gates_test.dart` — drives each script against fixtures.
- `app/test/policy/spec_14_static_coverage_test.dart` — parses `SPEC.md` §14 and asserts the map is
  complete and points at steps that exist.
- `tools/gates/fixtures/` — `aab-manifest-clean.txt`, `aab-manifest-with-internet.txt`,
  `aab-manifest-with-background-location.txt`, `info-plist-clean.plist`,
  `info-plist-with-ats-exception.plist`, `info-plist-with-always-location.plist`,
  `deps-clean.json`, `deps-third-http-edge.json`.

## Why it is built this way

E01 already greps source. This task exists because a source grep is blind to the failure mode that
`tools:node="remove"` was written for: a plugin AAR whose own manifest declares `INTERNET`, merged into
the app at build time. `four-layers.md` says it plainly — a `remove` in `main/` strips a grant merged in
by a library manifest, "which is the case a grep over your own source can never catch". The only way to
know it worked is to read the merged manifest out of the artefact.

**The AAB, not an APK.** `SPEC.md` §14 names `aapt2 dump xmltree` on the AAB, and the AAB's
`base/manifest/AndroidManifest.xml` is the file Play splits into what installs. Checking a separately
built APK checks a different file produced by a different task, and the gate would then be asserting
something about an artefact nobody uploads.

**Rejected: `apkanalyzer manifest permissions app-release.apk`.** `four-layers.md` offers it as the
proof-from-the-artefact command, and it is a good one — for an APK. It is listed here as rejected only
because the shipped artefact is an AAB; if a debug APK ever needs the same check, that is the command.

**Rejected: `bundletool dump manifest`.** Equivalent output, but it is a separate JAR that must be
downloaded and version-pinned in CI. `aapt2` is already inside the Android SDK build-tools on the
runner, and `SPEC.md` names it. One fewer pinned download is one fewer thing that rots.

**Rejected: re-reading `app/android/app/src/release/AndroidManifest.xml`.** That is source, and
`check_no_network.sh` check 3 already covers it. Repeating it here would produce a second green check
that proves the same thing as the first while looking like it proves more.

**The allowlist gate reads `dart pub deps --json`, not `pubspec.yaml`.** `dependency-hygiene` rule 6:
the second hop is exactly where a banned SDK arrives, and a direct read of the pubspec cannot see it.
The gate is a set diff in both directions — an edge that vanishes is as interesting as one that appears,
because it means `four-layers.md`'s allowlist table has drifted from reality and the next audit finds
the discrepancy instead of us.

**The coverage map is a test, not a comment.** `docs/release/spec-14-coverage.md` claims each of the
five static rows runs somewhere. A claim in a Markdown file rots in one commit. The test parses §14,
counts the bullets, and fails when the count changes or when a mapped step name is absent from every
workflow file — so editing `SPEC.md` §14 forces the map to be updated in the same PR.

**Each of the three scripts passes the three-criteria bar** in `policy-grep-gate.md`: textually
decidable (a dumped manifest, a plist, a resolved dependency graph), silent when broken (the app builds
and every test is green with `INTERNET` merged back in), and one line to break (a plugin bump, a copied
plist stanza, a new dependency). The XML fixtures are comment-stripped before matching, per that same
reference, so a comment explaining why `INTERNET` is banned cannot trip the gate that bans it.

## Tests first

Write every row before creating a single script. Run them. **They must fail** — with "No such file or
directory" on the scripts, which is the correct first failure. If a row passes now, the test is wrong:
the most likely cause is asserting on a non-zero exit code that the missing binary produces anyway, so
assert on the specific exit code and on the message, never merely on "not zero".

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `check_release_aab_manifest.sh exits 2 when the artefact path does not exist` | `/nonexistent.aab` | exit `2` | `CONVENTIONS.md` §7: a gate that scans nothing must abort, not report success. This is the failure mode that makes a gate worse than no gate |
| 2 | `check_release_aab_manifest.sh fails when the merged manifest grants INTERNET` | `aab-manifest-with-internet.txt` | exit `1`, message names `android.permission.INTERNET` | The whole point of the task: a plugin AAR merging the permission back in is invisible to every source grep |
| 3 | `check_release_aab_manifest.sh fails when the merged manifest grants background location` | `aab-manifest-with-background-location.txt` | exit `1`, message names `ACCESS_BACKGROUND_LOCATION` | §14 row 3 bans two things, not one. A gate that only looks for `INTERNET` silently passes the other half |
| 4 | `check_release_aab_manifest.sh passes on a manifest granting only CAMERA and the two foreground location permissions` | `aab-manifest-clean.txt` | exit `0` | §11 permits exactly these three. A gate that fails on the permissions we do ship gets deleted in week two |
| 5 | `check_release_aab_manifest.sh ignores an INTERNET string inside an XML comment` | clean fixture with `<!-- INTERNET is never granted -->` | exit `0` | `policy-grep-gate.md`: the needle is also what a developer types when explaining the ban |
| 6 | `check_ios_privacy_plist.sh fails when NSAllowsArbitraryLoads is declared` | `info-plist-with-ats-exception.plist` | exit `1` | §14 row 4. §5.3 keeps ATS at its strict default and documents that it proves nothing — declaring an exception would be both useless and a false signal |
| 7 | `check_ios_privacy_plist.sh fails when NSLocationAlwaysAndWhenInUseUsageDescription is declared` | `info-plist-with-always-location.plist` | exit `1` | §11 iOS: the always-key is deliberately absent, and adding it is one paste away |
| 8 | `check_ios_privacy_plist.sh passes on a plist declaring only the two §11 usage strings` | `info-plist-clean.plist` | exit `0` | `NSLocationWhenInUseUsageDescription` and `NSCameraUsageDescription` must survive the gate — they are required, not tolerated |
| 9 | `check_dependency_allowlist.sh fails when a third http edge appears` | `deps-third-http-edge.json` | exit `1`, message names the third parent | §14 row 1 says a third edge fails. Without this case the gate is a spell-checker for a file nobody reads |
| 10 | `check_dependency_allowlist.sh fails when an allowlisted edge has disappeared` | `deps-clean.json` minus the `flutter_svg` edge | exit `1` | An edge that vanishes means the allowlist table in `four-layers.md` is now wrong. Silent drift in the other direction is how an audit finds the discrepancy before we do |
| 11 | `check_dependency_allowlist.sh passes on exactly the printing, flutter_svg and share_plus edges` | `deps-clean.json` | exit `0` | The three edges §14 row 1 names are legitimate. The gate must not be a ban on `http` existing anywhere |
| 12 | `check_dependency_allowlist.sh exits 2 when the app directory does not exist` | `/nonexistent` | exit `2` | Same floor as row 1, for the script that takes a directory rather than a file |
| 13 | `SPEC §14 static block lists five checks` | `../SPEC.md` | `5` | The coverage map is only meaningful if the thing it maps has not silently grown. A sixth static row added without an owner is exactly the drift this catches |
| 14 | `spec-14-coverage.md maps every static check to a workflow step that exists` | the map + `.github/workflows/*.yml` | every mapped step name found | A map that points at a renamed step is a map that says a check runs when it does not |

```dart
// app/test/policy/release_artifact_gates_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `flutter test` sets the working directory to the package root (`app/`), so the
/// repository root is one level up. Never build a path from `Platform.script`.
const String _repoRoot = '..';
const String _gates = '$_repoRoot/tools/gates';
const String _fixtures = '$_gates/fixtures';

ProcessResult _run(String script, List<String> args) =>
    Process.runSync('bash', <String>['$_gates/$script', ...args]);

void main() {
  group('check_release_aab_manifest.sh', () {
    test('exits 2 when the artefact path does not exist', () {
      final ProcessResult r = _run('check_release_aab_manifest.sh', <String>['/nonexistent.aab']);
      expect(r.exitCode, 2);
    });

    test('fails when the merged manifest grants INTERNET', () {
      final ProcessResult r = _run(
        'check_release_aab_manifest.sh',
        <String>['--dump', '$_fixtures/aab-manifest-with-internet.txt'],
      );
      expect(r.exitCode, 1);
      expect(r.stderr, contains('android.permission.INTERNET'));
    });

    test('passes on a manifest granting only CAMERA and the two foreground location permissions', () {
      final ProcessResult r = _run(
        'check_release_aab_manifest.sh',
        <String>['--dump', '$_fixtures/aab-manifest-clean.txt'],
      );
      expect(r.exitCode, 0, reason: r.stderr.toString());
    });

    // … rows 3, 5
  });

  group('check_dependency_allowlist.sh', () {
    test('fails when a third http edge appears', () {
      final ProcessResult r = _run(
        'check_dependency_allowlist.sh',
        <String>['--deps', '$_fixtures/deps-third-http-edge.json'],
      );
      expect(r.exitCode, 1);
      expect(r.stderr, contains('http'));
    });

    // … rows 10, 11, 12
  });
}
```

```dart
// app/test/policy/spec_14_static_coverage_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Everything between the "Static" heading and the "Dynamic" heading in SPEC.md §14.
List<String> _staticChecks() {
  final List<String> lines = File('../SPEC.md').readAsLinesSync();
  final int start = lines.indexWhere((String l) => l.startsWith('**Static (CI'));
  final int end = lines.indexWhere((String l) => l.startsWith('**Dynamic (manual'), start);
  return lines
      .sublist(start, end)
      .where((String l) => l.startsWith('- [ ] '))
      .toList(growable: false);
}

void main() {
  test('SPEC §14 static block lists five checks', () {
    expect(_staticChecks(), hasLength(5),
        reason: 'a static row was added or removed — update docs/release/spec-14-coverage.md');
  });

  test('spec-14-coverage.md maps every static check to a workflow step that exists', () {
    final String map = File('../docs/release/spec-14-coverage.md').readAsStringSync();
    final String workflows = Directory('../.github/workflows')
        .listSync()
        .whereType<File>()
        .map((File f) => f.readAsStringSync())
        .join('\n');
    final Iterable<String> stepNames =
        RegExp(r'`step:\s*([^`]+)`').allMatches(map).map((RegExpMatch m) => m.group(1)!);
    expect(stepNames, hasLength(5));
    for (final String name in stepNames) {
      expect(workflows, contains(name), reason: 'no workflow declares a step named "$name"');
    }
  });
}
```

**Run:** `cd app && flutter test test/policy/` → 14 failures. Any pass now is a wrong test.

## Implementation outline

1. Write the eight fixtures first. Produce `aab-manifest-clean.txt` by running
   `aapt2 dump xmltree` once by hand against a locally built AAB and trimming it — never hand-write the
   format, because a gate tuned to an invented format passes on real input by accident.
2. `check_release_aab_manifest.sh`: `set -euo pipefail`; accept either an AAB path or
   `--dump <file>` so the tests can drive it without an artefact. Resolve `aapt2` by globbing
   `$ANDROID_HOME/build-tools/*/aapt2`, take the highest version, echo the resolved absolute path, and
   exit 2 when none is found. Strip `<!-- … -->` before matching. Exit 2 for a missing target, 1 for a
   violation, 0 clean.
3. `check_ios_privacy_plist.sh`: same skeleton, over `app/ios/Runner/Info.plist`. Match the key names
   as `<key>…</key>` elements rather than as bare substrings, so a usage string that mentions ATS in
   prose does not trip it.
4. `check_dependency_allowlist.sh`: accept `--deps <json>` for the tests, otherwise run
   `dart pub deps --json` inside the given app directory. Walk the graph, emit `parent -> child` for
   every edge into `http` or `url_launcher_platform_interface`, sort, and `diff` against
   `docs/deps-allowlist.txt`. Report both directions of the diff.
5. `docs/deps-allowlist.txt`: three lines, alphabetically sorted, with a one-line header comment naming
   `SPEC.md` §14 row 1 as the authority.
6. `docs/release/spec-14-coverage.md`: a five-row table — §14 row, contract, workflow job,
   `` `step: <name>` ``. Rows 2 and 5 point at the steps E01 and E06 already created; this task does not
   re-implement them, it asserts they are still there and still required.
7. `.github/workflows/release-gates.yml`: `runs-on: ubuntu-24.04` (never `-latest`),
   `subosito/flutter-action@v2` with `flutter-version: '3.44.6'`, `channel: stable`,
   `actions/checkout@v4  # VERIFY: confirm current major`. Steps, named exactly as the map claims:
   `flutter pub get`, `build release aab`, `gate release manifest`, `gate ios plist`,
   `gate dependency allowlist`. No `continue-on-error` anywhere.
8. Re-run the suite. All 14 green, and every gate from E01 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 14 tests pass, and each failed first.
- [ ] Each of the three scripts exits `2` on a missing target, `1` on a violation, `0` clean.
- [ ] `check_release_aab_manifest.sh` logs the absolute path of the `aapt2` it resolved, so the
      checklist in T08 can record which binary produced the dump.
- [ ] `docs/deps-allowlist.txt` holds exactly the three edges `SPEC.md` §14 row 1 names, and no fourth.
- [ ] `docs/release/spec-14-coverage.md` has five rows and every named step exists in a workflow file.
- [ ] The workflow builds the AAB from `app/` and inspects **that** file — no path in the workflow
      reads `app/android/app/src/release/AndroidManifest.xml`.
- [ ] `flutter run` still hot-reloads after this change: `android/app/src/debug/AndroidManifest.xml` is
      untouched and still grants `INTERNET` (`catchlaw-offline-guarantee` rule 4).
- [ ] No gate added here is `continue-on-error`, and none mutates the repository.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze --fatal-infos && flutter test
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
bash -n tools/gates/check_release_aab_manifest.sh
bash -n tools/gates/check_ios_privacy_plist.sh
bash -n tools/gates/check_dependency_allowlist.sh
tools/gates/check_dependency_allowlist.sh app
tools/gates/check_ios_privacy_plist.sh app/ios/Runner/Info.plist
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
ci(ci): gate the release AAB manifest, the iOS plist and the dependency allowlist

Every offline check so far reads source, and a source grep cannot see an
INTERNET permission merged in from a plugin's own AAR manifest — which is the
exact case tools:node="remove" exists to defeat and the exact case nobody had
verified. These three gates read the artefact instead: aapt2 dump xmltree on
base/manifest/AndroidManifest.xml inside the release AAB, the Info.plist for ATS
exceptions and the always-location key, and dart pub deps diffed both ways
against the three transitive edges SPEC §14 allows. A coverage test parses §14
so a sixth static row cannot be added without an owner.

Task: E21/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
