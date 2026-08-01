# E01/T01 — Workspace skeleton and the toolchain floor

| | |
|---|---|
| **Epic** | E01 — Foundation, workspace and the offline gates |
| **Branch** | `epic/01-foundation` (shared) |
| **Commit** | `build(workspace): create the pub workspace with four members on Dart ^3.12.0` |
| **Depends on** | — (first task of the first epic) |
| **Size** | M |
| **Spec** | `SPEC.md` §10 (tech stack), §15 step 1 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `project-structure-and-packages` | Owns the physical directory tree. `references/workspace-and-packages.md` is the workspace ritual: `resolution: workspace` on every member, one root `pubspec.lock`, never `path:` + `dependency_overrides`, the pure-core manifest as the audit evidence |
| `codegen-and-toolchain` | `references/toolchain-and-workspace.md` holds the workspace resolution-failure table — the four symptoms this task's tests exist to prevent — and the rule that the SDK pin CI requests must equal the recorded one |
| `dependency-hygiene` | Rules 1, 2 and 4: caret ranges in the pubspec, the committed lock as the only pin, and the exact tested Flutter version recorded in a separate file that CI reads |
| `catchlaw-conventions-index` | Invariant 6, the one-way layer map, and rule 8 — nothing is awaited before `runApp`. `main.dart` is written here and `check_app_invariants.sh` check 8 greps for an `async main()` |
| `catchlaw-offline-guarantee` | Layer 1 is created in this task, by omission: what is absent from these five pubspecs is the guarantee. Rule 1 lists what may never appear |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `FLUTTER_GUIDE.md` | Part 2.4 "Multi-package: use Dart pub workspaces, not melos" | The root and `app/` pubspec shapes verbatim, and the reason `analysis_defaults` is in the member list |
| `FLUTTER_GUIDE.md` | Part 2.5 "The concrete tree for CATCHLAW" | The directory layout, and rule 8 of the eight review rules: the engine's purity is guaranteed by its pubspec |
| `FLUTTER_GUIDE.md` | Part 2.6 | Exactly one barrel in the repository: `packages/rule_engine/lib/rule_engine.dart` |
| `FLUTTER_GUIDE.md` | Part 4.6 layer 1 | Why an absent dependency is a stronger guarantee than any lint |
| `SPEC.md` | §10 | The dependency table and the explicitly-banned list. **Do not add any of it yet** — see "Why it is built this way" |
| `SPEC.md` | §15 step 1 | The order this task sits at the head of |
| `epics/DECISIONS.md` | D-1 | The layout: app at `app/`, engine at `packages/rule_engine/`, builder at `tools/content_builder/` |
| `epics/DECISIONS.md` | D-4 | One name for the builder: directory `tools/content_builder/`, package `content_builder` |
| `epics/DECISIONS.md` | D-5 | Flutter 3.44.6, Dart `^3.12.0`, and why `SPEC.md` §10's floor is not merely older but incompatible |
| `.claude/skills/project-structure-and-packages/references/workspace-and-packages.md` | "The workspace wiring", "The pure-core manifest is the audit evidence" | The member checklist and the one-lock rule |
| `.claude/skills/codegen-and-toolchain/references/toolchain-and-workspace.md` | "Workspace resolution-failure edge cases" | The four-row symptom table that tests 3, 4 and 5 encode |
| `.claude/skills/dependency-hygiene/references/sdk-pin-and-lint-include.md` | "Pin the record, not the tool" | `.fvmrc` is JSON, read with `jq -r '.flutter'`, and `subosito/flutter-action` accepts it as `flutter-version-file` |

## What this delivers

- `pubspec.yaml` — the workspace root. `name: catchlaw_workspace`, `publish_to: none`,
  `environment: sdk: ^3.12.0`, and a `workspace:` list of exactly four members in the order D-1 prints
  them: `app`, `packages/rule_engine`, `packages/analysis_defaults`, `tools/content_builder`. It declares
  no `dependencies:` and ships nothing.
- `.fvmrc` — `{ "flutter": "3.44.6" }`. JSON, one key, read by `jq` and by
  `subosito/flutter-action`'s `flutter-version-file` in T03.
- `app/pubspec.yaml` — `name: catchlaw`, `publish_to: none`, `resolution: workspace`,
  `environment: sdk: ^3.12.0`, `dependencies: flutter: {sdk: flutter}`,
  `dev_dependencies: flutter_test: {sdk: flutter}`, `yaml: ^3.1.2`.
- `app/lib/main.dart` — a synchronous `main()` and one `CatchlawApp` widget. No colour, no theme, no
  route, no database.
- `packages/rule_engine/pubspec.yaml` — `name: rule_engine`, `publish_to: none`,
  `resolution: workspace`, `dependencies: meta` only, `dev_dependencies: test`. **No `flutter:` line
  anywhere in the file.**
- `packages/rule_engine/lib/rule_engine.dart` — the single barrel, carrying the library-level doc comment.
- `packages/analysis_defaults/pubspec.yaml` — `name: analysis_defaults`, `publish_to: none`,
  `resolution: workspace`. Its lint content is T02's; this task creates the member so the workspace
  resolves.
- `tools/content_builder/pubspec.yaml` — `name: content_builder`, `publish_to: none`,
  `resolution: workspace`, `dependencies: rule_engine: {path: ../../packages/rule_engine}` expressed the
  workspace way (a plain `rule_engine:` line, resolved by the workspace).
- `tools/content_builder/bin/build.dart` — the executable stub, so `dart run content_builder:build`
  resolves from the first commit (D-4).
- `pubspec.lock` at the repository root, committed. No per-member lock exists.
- `app/test/policy/repo_root.dart` — the helper every later repository-level policy test in this epic
  uses. Not a test file: `CONVENTIONS.md` §6 forbids a helper ending in `_test.dart`.
- `app/test/policy/workspace_shape_test.dart`.

## Why it is built this way

**The workspace, not melos.** `FLUTTER_GUIDE.md` Part 2.4 and `flutter/samples` both use pub workspaces
for this exact shape. Pub links members; melos only orchestrates scripts
(`codegen-and-toolchain/references/toolchain-and-workspace.md`), and mixing `melos bootstrap` with
`resolution: workspace` produces duplicate resolution. Four packages do not earn a second tool with its
own configuration file and its own upgrade cadence.

**Rejected: `path:` + `dependency_overrides`.** It is the pre-3.6 way to link local packages and it defeats
single-context resolution — the property that makes an undeclared or upward import an *analysis* error
rather than a runtime surprise. `workspace-and-packages.md` states it outright: never wire members that
way.

**Rejected: the app at the repository root.** D-1 settles it. That layout would make the root
simultaneously the Flutter app and the workspace owner, which is legal but puts `app/lib` and `tools/` in
one dependency namespace. Do not re-argue it; cite D-1.

**Rejected: `SPEC.md` §10's "Flutter 3.24+ / Dart 3.5+".** D-5. Dart 3.5 cannot resolve a workspace at all,
so the spec's floor is not an older-but-workable number — it is incompatible with D-1. The guide's versions
were verified against the pub.dev and GitHub APIs after the spec was written.

**Rejected: an exact SDK version in `environment:`.** `dependency-hygiene` rules 1 and 4: the
`environment: sdk:` range exists so `pub` can solve, and it is not a record of what was tested. The exact
tested Flutter version goes in `.fvmrc`, which CI and a stranger both read. Pinning the range manufactures
unsolvable conflicts on the next bump and records nothing the lock is not already recording.

**Rejected: adding `SPEC.md` §10's dependency table now.** Every package in it — drift,
`sqlite3_flutter_libs`, Riverpod, `flutter_svg`, `geolocator`, `camera`, `pdf`, `printing`, `share_plus`,
`file_picker` — arrives in the epic that first uses it, with its `pubspec.lock` delta and its licence
recorded in the same commit (`dependency-hygiene` rules 3 and 6). Declaring them here would mean T04's
allowlist is written against a graph nobody has exercised, and `flutter_svg` and `printing` would drag
their `http` edges into the tree before the gate that governs them exists.

**Why `packages/rule_engine/pubspec.yaml` has no `flutter:` line, stated as the point rather than as
housekeeping.** `FLUTTER_GUIDE.md` §4.6 layer 1 and Part 2.5's review rule 8: an `import
'package:flutter/material.dart'` in the engine is then `Target of URI doesn't exist` — a compile error, not
a lint, not a grep, not a code review. It is the strongest guarantee available and it costs one omitted
line. `check_rule_engine.sh` check 5 also greps for it, and that grep is a floor under the compiler, not a
substitute for it.

**Why `meta` is the only runtime dependency of the engine.** The manifest *is* the purity audit
(`workspace-and-packages.md`). A second dependency is a second thing a reviewer has to reason about before
believing the engine is pure.

**Why `main()` is synchronous.** `catchlaw-conventions-index` rule 8 and `SPEC.md` §13's < 1.2 s cold start:
every `await` before the first frame is a black screen indistinguishable from a crashed app.
`check_app_invariants.sh` check 8 greps `(void|Future<void>) +main\(\) +async` under the target, so an async
`main` fails the gate as well as the target. The databases open lazily in E05; nothing in this task opens
anything.

**Why the policy tests live in `app/test/policy/`.** `ci-pipeline-and-gates/references/policy-grep-gate.md`
puts textually-decidable invariants in `test/policy/`, and `flutter test` sets the working directory to the
package root. The repository root is above that, so `repo_root.dart` walks up until it finds a
`pubspec.yaml` declaring `name: catchlaw_workspace` — never a path built from `Platform.script`, which the
same reference forbids because it breaks under a different test runner.

**Why `yaml` is a dev dependency of the app.** These tests read five pubspecs; regex-scanning YAML is how a
policy test starts passing for the wrong reason. `yaml` is pure Dart, opens nothing, and is dev-only —
`audit_deps.py` separates dev-reachable packages from shipping ones precisely so that a build-time tool is
not treated as a shipping defect.

## Tests first

Write every row into `app/test/policy/workspace_shape_test.dart` before creating a single pubspec. Run
them. **They must fail** — at T01 there is no `pubspec.yaml` at all, so `repoRoot()` throws and all twelve
error out. That is the correct red. If any test passes before the files exist, the test is asserting
nothing and must be fixed before any pubspec is written.

| # | Test name | Asserts | Why this case exists |
|---|---|---|---|
| 1 | `Workspace root declares exactly the four members` | `workspace:` == `[app, packages/rule_engine, packages/analysis_defaults, tools/content_builder]` | D-1 publishes four. A fifth member added without a plan changes the dependency namespace for every other member, and nothing else would notice |
| 2 | `Workspace root package is named catchlaw_workspace` | `name:` | The name is what tells a reader the root ships nothing. `FLUTTER_GUIDE.md` Part 2.4 |
| 3 | `Every workspace member declares resolution: workspace` | four pubspecs | The first row of the resolution-failure table: a member missing it resolves to a stale copy and its changes are not seen |
| 4 | `Every workspace member declares the Dart SDK constraint ^3.12.0` | four pubspecs + root | Row two: incompatible member constraints fail version solving with a message that names neither member. D-5 |
| 5 | `Exactly one pubspec.lock exists in the repository` | walk the tree | Row three: two lockfiles mean somebody ran `dart pub get` inside a package directory, and the two will disagree within a week |
| 6 | `pubspec.lock is not gitignored` | `.gitignore` | `dependency-hygiene` rule 2. This is an application: the committed lock is the only thing that makes a stranger's clone resolve the versions that were tested on a real device |
| 7 | `rule_engine pubspec declares no flutter dependency` | no `flutter:` key anywhere in the file | `FLUTTER_GUIDE.md` §4.6 layer 1 — the compile-level purity guarantee. E02 and E04 both depend on this being true and neither of them re-checks it |
| 8 | `rule_engine pubspec declares meta as its only runtime dependency` | `dependencies` == `{meta}` | The manifest is the audit artefact. Two dependencies is two things to reason about before believing the engine is pure |
| 9 | `content_builder package is named content_builder` | `tools/content_builder/pubspec.yaml` | D-4. Three names for one deliverable was going to cost somebody an afternoon; this is the test that keeps it at one |
| 10 | `.fvmrc records Flutter 3.44.6 as JSON` | `jsonDecode(...)['flutter']` | D-5, and `sdk-pin-and-lint-include.md`: the `flutter: 3.44.6` YAML form gets copied around and is wrong in this file. T03 reads it as `flutter-version-file` |
| 11 | `app main is not async` | `app/lib/main.dart` | Invariant 8 and `check_app_invariants.sh` check 8. An `await` before `runApp` is a black screen indistinguishable from a crash on the boat where it matters |
| 12 | `app pubspec sets publish_to to none` | `app/pubspec.yaml` | Mandatory for an app (`FLUTTER_GUIDE.md` Part 2.4). Without it a stray `dart pub publish` is a live command |

```dart
// app/test/policy/repo_root.dart
// Not a test file. CONVENTIONS.md §6: a helper must not end in _test.dart.
import 'dart:io';

/// The workspace root, found by walking up from the current directory until a
/// `pubspec.yaml` declaring `name: catchlaw_workspace` is reached.
///
/// `flutter test` sets the working directory to the package root (`app/`), so a
/// repository-level policy test cannot use a relative literal, and
/// `policy-grep-gate.md` forbids building a path from `Platform.script`.
Directory repoRoot() {
  var dir = Directory.current.absolute;
  while (true) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().contains('name: catchlaw_workspace')) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('no catchlaw_workspace pubspec.yaml above ${Directory.current.path}');
    }
    dir = parent;
  }
}

File repoFile(String relative) => File('${repoRoot().path}/$relative');

Directory repoDir(String relative) => Directory('${repoRoot().path}/$relative');
```

```dart
// app/test/policy/workspace_shape_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'repo_root.dart';

const members = <String>[
  'app',
  'packages/rule_engine',
  'packages/analysis_defaults',
  'tools/content_builder',
];

YamlMap pubspecOf(String relativeDir) =>
    loadYaml(repoFile('$relativeDir/pubspec.yaml').readAsStringSync()) as YamlMap;

void main() {
  test('Workspace root declares exactly the four members', () {
    final root = loadYaml(repoFile('pubspec.yaml').readAsStringSync()) as YamlMap;
    expect((root['workspace'] as YamlList).cast<String>(), members);
  });

  test('Workspace root package is named catchlaw_workspace', () {
    final root = loadYaml(repoFile('pubspec.yaml').readAsStringSync()) as YamlMap;
    expect(root['name'], 'catchlaw_workspace');
  });

  test('Every workspace member declares resolution: workspace', () {
    final offenders = <String>[
      for (final m in members)
        if (pubspecOf(m)['resolution'] != 'workspace') m,
    ];
    expect(offenders, isEmpty,
        reason: 'a member without resolution: workspace resolves a stale copy and '
            'its changes are never seen:\n${offenders.join('\n')}');
  });

  test('Every workspace member declares the Dart SDK constraint ^3.12.0', () {
    final offenders = <String>[
      for (final m in [...members, '.'])
        if ((pubspecOf(m)['environment'] as YamlMap)['sdk'] != '^3.12.0') m,
    ];
    expect(offenders, isEmpty,
        reason: 'version solving fails on mismatched member constraints, and names '
            'neither member in the message (D-5):\n${offenders.join('\n')}');
  });

  test('Exactly one pubspec.lock exists in the repository', () {
    final locks = repoRoot()
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('pubspec.lock') && !f.path.contains('/.dart_tool/'))
        .map((f) => f.path)
        .toList();
    expect(locks, hasLength(1),
        reason: 'a second lock means dart pub get ran inside a package directory:\n'
            '${locks.join('\n')}');
  });

  test('pubspec.lock is not gitignored', () {
    expect(repoFile('.gitignore').readAsLinesSync().map((l) => l.trim()),
        isNot(contains('pubspec.lock')),
        reason: 'this is an application — the committed lock is what makes a stranger\'s '
            'clone resolve the versions that were tested on a device');
  });

  test('rule_engine pubspec declares no flutter dependency', () {
    final raw = repoFile('packages/rule_engine/pubspec.yaml').readAsStringSync();
    expect(RegExp(r'^\s*flutter\s*:', multiLine: true).hasMatch(raw), isFalse,
        reason: 'the missing line IS the purity guarantee: an import of package:flutter '
            'is then a compile error, not a lint (FLUTTER_GUIDE §4.6 layer 1)');
  });

  test('rule_engine pubspec declares meta as its only runtime dependency', () {
    final deps = pubspecOf('packages/rule_engine')['dependencies'] as YamlMap;
    expect(deps.keys, ['meta']);
  });

  test('content_builder package is named content_builder', () {
    expect(pubspecOf('tools/content_builder')['name'], 'content_builder');
  });

  test('.fvmrc records Flutter 3.44.6 as JSON', () {
    final decoded = jsonDecode(repoFile('.fvmrc').readAsStringSync()) as Map<String, dynamic>;
    expect(decoded['flutter'], '3.44.6');
  });

  test('app main is not async', () {
    final raw = repoFile('app/lib/main.dart').readAsStringSync();
    expect(RegExp(r'(void|Future<void>)\s+main\(\)\s+async').hasMatch(raw), isFalse,
        reason: 'nothing is awaited before runApp — a black screen is indistinguishable '
            'from a crash (catchlaw-conventions-index rule 8)');
  });

  test('app pubspec sets publish_to to none', () {
    expect(pubspecOf('app')['publish_to'], 'none');
  });
}
```

**Run:** `cd app && flutter test test/policy/workspace_shape_test.dart` → 12 failures. Every one of them
is `StateError: no catchlaw_workspace pubspec.yaml above …` at this point, which is the correct red.

## Implementation outline

1. Create the root `pubspec.yaml` with the four members and `sdk: ^3.12.0`. Nothing else. Run
   `dart pub get` — it will fail, because the members do not exist yet. That failure is the map.
2. Create `packages/analysis_defaults/pubspec.yaml` (name, `publish_to`, `resolution`, `environment`) and
   `packages/analysis_defaults/lib/.gitkeep`. Its lint payload is T02.
3. Create `packages/rule_engine/pubspec.yaml` with `meta` and `test` and **no** `flutter` key, then
   `packages/rule_engine/lib/rule_engine.dart` with the library-level doc comment. It exports nothing yet;
   `FLUTTER_GUIDE.md` Part 2.6 sanctions exactly this one barrel and no other.
4. Create `tools/content_builder/pubspec.yaml` (`name: content_builder`) and
   `tools/content_builder/bin/build.dart` — a `main(List<String> args)` that prints its usage and exits 64.
   Prove `dart run content_builder:build` resolves.
5. Create `app/pubspec.yaml` and `app/lib/main.dart`. `main()` is `void main() => runApp(const
   CatchlawApp());`; `CatchlawApp` returns a `MaterialApp` with `home: const SizedBox.shrink()` and no
   `ThemeData` — the theme is D-2's and E07's, and a colour here would be the first thing a `lonja-*` gate
   catches in T08.
6. Create `.fvmrc` with the single `flutter` key.
7. `dart pub get` at the **repository root**. Confirm one `pubspec.lock` and one `.dart_tool/`, both at the
   root, and no per-member copies. If a per-member lock appeared, a `pub get` was run in the wrong
   directory — delete it, do not gitignore it.
8. Add `app/test/policy/repo_root.dart` and the twelve tests. Re-run: all green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 tests pass, and each failed first.
- [ ] `dart pub get` at the root resolves with **no** `dependency_overrides` section anywhere.
- [ ] `find . -name pubspec.lock -not -path '*/.dart_tool/*'` returns exactly one path, the root's, and it
      is tracked by git.
- [ ] `dart run content_builder:build` resolves and exits 64 (D-4's name is live from commit one).
- [ ] `grep -rn 'package:flutter' packages/rule_engine/` returns nothing, and `packages/rule_engine/`
      contains exactly one library file.
- [ ] `app/lib/main.dart` declares no `Color`, no `ThemeData` and no route.
- [ ] `.fvmrc` parses as JSON with `jq -r '.flutter'` and prints `3.44.6`.

## Gates

```bash
dart pub get                                    # at the repository root
dart format --output=none --set-exit-if-changed .
cd app && flutter analyze --fatal-infos && flutter test && cd ..
cd packages/rule_engine && dart analyze && cd ../..
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh app/lib
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib
```

Both gate scripts take an explicit target directory and exit 2 on a missing one (`CONVENTIONS.md` §7,
D-1). `check_no_network.sh` derives its root as the parent of the target, so it reads `app/pubspec.yaml`;
its `analysis_options.yaml` check is skipped at this task because that file does not exist yet — T02
creates it and makes that check live.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
build(workspace): create the pub workspace with four members on Dart ^3.12.0

SPEC.md §15 step 1 puts the skeleton first so every §14 static check can be
wired in from commit one. The layout is D-1's: app at app/, the engine at
packages/rule_engine/, the builder at tools/content_builder/, shared lints at
packages/analysis_defaults/. The floor is D-5's: Flutter 3.44.6 and Dart
^3.12.0, because SPEC.md §10's Dart 3.5 cannot resolve a workspace at all and
is therefore incompatible with the layout rather than merely older.

packages/rule_engine/pubspec.yaml declares no flutter dependency. That omission
is the guarantee E02 and E04 both rely on: an import of package:flutter is a
compile error there, which is stronger than any lint or grep can be.

No dependency from SPEC.md §10 is declared yet. Each arrives in the epic that
first uses it, so that T04's allowlist is written against a graph somebody has
exercised and flutter_svg and printing do not drag their http edges in before
the gate that governs them exists.

Task: E01/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
