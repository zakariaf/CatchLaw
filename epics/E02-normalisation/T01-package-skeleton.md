# E02/T01 — Package skeleton and the zero-Flutter proof

| | |
|---|---|
| **Epic** | E02 — Rule engine: text normalisation |
| **Branch** | `epic/02-normalisation` (shared) |
| **Commit** | `feat(rule_engine): create the pure-Dart package and prove it cannot import Flutter` |
| **Depends on** | E01 merged (workspace root, `analysis_options.yaml`, `packages/analysis_defaults/`) |
| **Size** | S |
| **Spec** | `SPEC.md` §10 (pure Dart core), §14 (the static allowlist), §15 step 2 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 2 is this task's whole point: the package declares no `flutter:` sdk dependency, so `import 'package:flutter/...'` is a **compile error**, not a lint someone can `// ignore:`. Rule 10 fixes where the normaliser will live |
| `catchlaw-conventions-index` | Invariant 1 (no network code path) and rule 6, the one-way layer map — this package sits at the top of it and knows nothing below |
| `dart3-idioms-and-coding-standards` | Owns the pure-Dart package shape per the routing table's layer map; SDK floor and class-modifier policy |
| `dartdoc-conventions` | The library-level doc comment in `lib/rule_engine.dart` is the highest-ROI documentation in the project (`FLUTTER_GUIDE.md` §3.4) and this task writes it |
| `naming-conventions` | Package, directory and file naming — `lowercase_with_underscores` throughout |
| `testing-strategy` | Which level a package-purity assertion belongs at: pure `dart test`, no widget binding, no Flutter |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `FLUTTER_GUIDE.md` | §2.4 | The workspace root member list and `resolution: workspace`; `analysis_defaults` as a shared dev dependency |
| `FLUTTER_GUIDE.md` | §2.5 | The concrete tree for `packages/rule_engine/`, and enforcement rule 8: zero `package:flutter` imports, guaranteed by the pubspec |
| `FLUTTER_GUIDE.md` | §2.6 | Exactly one barrel in this repository, and it is `packages/rule_engine/lib/rule_engine.dart` |
| `FLUTTER_GUIDE.md` | §4.3 | The nested `analysis_options.yaml`: the `include:` line is mandatory, plus `public_member_api_docs` and `avoid_print` |
| `FLUTTER_GUIDE.md` | §4.6 | The four layers of the no-networking proof; Layer 1 is the compiler, Layer 4 is the guard test this task writes |
| `FLUTTER_GUIDE.md` | §3.4 | Doc-comment shape: one-sentence summary, blank `///` line, then the rest |
| `SPEC.md` | §14 static block | The banned-identifier list the guard test reuses |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rules 2 and 10, Definition of done | The compile-error guarantee, and `normaliseSpeciesTerm` in `lib/src/search/normalise.dart` |
| `.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh` | Checks 1 and 5, and the `DOMAIN_RE` note | How the gate finds this package, and the "nothing to read" message that means it found nothing |
| `epics/DECISIONS.md` | D-1, D-5 | `packages/rule_engine/` is a workspace member; Dart SDK constraint `^3.12.0` |
| `epics/CONVENTIONS.md` | §6, §7 | Where tests live; a gate scanning an empty tree reports success, which is worse than no gate |

## What this delivers

- `packages/rule_engine/pubspec.yaml` — `name: rule_engine`, `resolution: workspace`,
  `environment: sdk: ^3.12.0` (D-5), **no `flutter:` key anywhere**, dev dependencies only.
- `packages/rule_engine/analysis_options.yaml` — the mandatory `include:` line plus
  `public_member_api_docs` and `avoid_print`.
- `packages/rule_engine/lib/rule_engine.dart` — the one barrel, carrying the library-level doc comment
  and a bare `library;` declaration. No exports yet; T02 adds the first.
- `packages/rule_engine/test/package_purity_test.dart` — the Layer 4 guard test.
- `packages/rule_engine/.gitignore` only if E01's root one does not already cover `.dart_tool/`; check
  first, do not add a second copy.

**Read before writing.** E01 may have left a placeholder `packages/rule_engine/pubspec.yaml` purely so
the root `workspace:` list resolves. If so, this task fills it in; the `workspace:` entry belongs to E01
and is not edited here. Match `app/pubspec.yaml`'s style for declaring `analysis_defaults` rather than
inventing a second style — one repository, one way of doing it.

## Why it is built this way

The no-Flutter rule is enforced by **absence**, not by discipline. `FLUTTER_GUIDE.md` §4.6 puts it
plainly: if `flutter` is not listed in the pubspec, `import 'package:flutter/material.dart'` is an
unresolved-URI compile error. That is a guarantee no lint can beat, and it is the reason the content
builder of E04 will be able to compile this package under a plain `dart run` with no Flutter SDK on the
machine. `catchlaw-rule-engine` rule 2 states the failure it prevents: one Flutter symbol stops the whole
content build.

The guard test exists anyway, as Layer 4, because the compile error only fires once someone actually
tries to build. A test that walks `lib/` and reports the offending file and line turns a confusing
resolution error into a named defect, and it is the precedent `FLUTTER_GUIDE.md` §4.6 cites —
`flutter/flutter/dev/bots/analyze.dart` maintains `verifyNoBadImportsInFlutter()` for exactly this reason.

**The walk asserts it visited something.** `CONVENTIONS.md` §7 names the failure mode that makes a gate
worse than no gate: a scan over a path with no files reports success. The same trap applies to a guard
test, so `_libDartFiles()` returns the file list and one test asserts the set is exactly
`{lib/rule_engine.dart}`. From T02 onward that set grows, and the assertion is updated deliberately rather
than being a wildcard nobody reads.

**One barrel, and this is it.** `FLUTTER_GUIDE.md` §2.6 records that the reference app uses none, and
takes the position that this package gets exactly one because it is a real package boundary with two
consumers and a library-level doc comment belongs there. The doc comment is written now, while the
vocabulary is being defined, not bolted on in T08.

**Rejected: `packages/rule_engine/lib/src/normalise/`.** `TEMPLATE.md` Part B illustrates the fold at
`lib/src/normalise/arabic_fold.dart`. Check 4 of `check_rule_engine.sh` excludes only files whose basename
is `normalise.dart` or `normalize.dart`, so a file called `arabic_fold.dart` holding an Arabic character
class is reported as a second, drifting normaliser — which is precisely the defect the check exists to
catch. `catchlaw-rule-engine` rule 10 names `lib/src/search/normalise.dart`, and D-2's rule of thumb is
that the gate script beats the prose whenever they disagree about a path. The directory is created in T02
with the file the gate expects.

**The pubspec is `name: rule_engine`, and that is a recorded gap rather than a settled decision.**
`catchlaw-content-pipeline` rule 9 imports the fold from `package:catchlaw_shared/text/normalise.dart` and
its rule 10 imports the engine from `package:catchlaw_rule_engine` — two package names for something D-1
places at `packages/rule_engine/`, plus a `catchlaw_shared` member D-1's workspace list does not contain.
Nothing in `DECISIONS.md` settles it. This epic uses `rule_engine` on three grounds: D-4 sets the
precedent that the directory name is the pubspec name; `FLUTTER_GUIDE.md` §2.5 puts the barrel at
`packages/rule_engine/lib/rule_engine.dart`, which resolves as `package:rule_engine/rule_engine.dart` and
under no other name; and D-1's member list has nowhere to put a fourth package. It belongs in
`DECISIONS.md`, which no task file may edit — E02's PR body raises it, and E04 cannot be written until it
is settled, because its builder has to type the import.

**Rejected: adding `test` and the normalisation dependency now.** `test` is added here because nothing
runs without it; the Unicode normalisation dependency is T02's, added with the first code that needs it
and justified in that commit body. A dependency added a task early is a dependency nobody can explain.

**Rejected: a `lib/src/` file in this commit.** There is nothing to put in it. An empty `src/` directory
is not tracked by git anyway, and a placeholder file would be dead code the analyzer cannot warn about.

## Tests first

Write every row before creating `pubspec.yaml`. Run them. **They must fail** — with a missing-file error,
which is the correct first failure for a package that does not exist. If any passes now, the test is
wrong: check it is not silently reading the repository-root `pubspec.yaml` instead of the package's.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `rule_engine package pubspec declares no flutter sdk dependency` | `pubspec.yaml` | no `sdk: flutter` line | `FLUTTER_GUIDE.md` §4.6 Layer 1 — the compile-error guarantee the whole package rests on, and check 5 of the gate |
| 2 | `rule_engine package pubspec declares no networking dependency` | `pubspec.yaml` | none of `http`, `dio`, `web_socket_channel`, `connectivity_plus`, `firebase_core` | Invariant 1. A transitive socket arrives through a direct dependency first, and this is the cheapest place to stop it |
| 3 | `rule_engine package lib imports no package:flutter and no dart:ui` | every `lib/**.dart` | no match on a non-comment line | Layer 4 of §4.6. Fires the moment someone adds the import, before they get to the pubspec |
| 4 | `rule_engine package lib names no banned networking identifier` | every `lib/**.dart` | none of `HttpClient`, `HttpServer`, `WebSocket`, `Socket`, `RawSocket`, `SecureSocket`, `ServerSocket`, `RawDatagramSocket`, `InternetAddress`, `NetworkInterface` | `dart:io` cannot be banned wholesale (§4.6 Layer 4) — the identifiers are what is actually banned, and `SPEC.md` §14 lists them |
| 5 | `rule_engine package lib holds exactly one barrel` | `lib/*.dart` | exactly `['lib/rule_engine.dart']` | `FLUTTER_GUIDE.md` §2.6 permits one. This is also the non-empty-scan assertion for tests 3 and 4 (`CONVENTIONS.md` §7) |
| 6 | `rule_engine package analysis_options includes the workspace configuration` | `analysis_options.yaml` | an `include:` line is present | `FLUTTER_GUIDE.md` §4.3, verified: a nested options file **replaces** the parent, so without this the package silently loses every rule |
| 7 | `rule_engine package analysis_options enables public_member_api_docs` | `analysis_options.yaml` | the rule is listed | Two consumers means an undocumented public member is real debt (§4.3). Also what makes T02's doc comment non-optional |

```dart
// packages/rule_engine/test/package_purity_test.dart
import 'dart:io';

import 'package:test/test.dart';

/// Every Dart file under `lib/`, sorted, as repository-relative paths.
///
/// `dart test` runs with the package directory as the working directory, so these
/// paths are relative to `packages/rule_engine/`.
List<String> _libDartPaths() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .map((f) => f.path.replaceAll(r'\', '/'))
    .where((p) => p.endsWith('.dart'))
    .toList()
  ..sort();

/// The lines of [path] with `//` comment tails removed, so a banned word quoted
/// in a doc comment does not fail the build.
Iterable<String> _codeLines(String path) => File(path)
    .readAsLinesSync()
    .map((line) => line.replaceFirst(RegExp(r'//.*'), ''));

const _bannedImports = <String>['package:flutter/', 'dart:ui'];

const _bannedIdentifiers = <String>[
  'HttpClient', 'HttpServer', 'WebSocket', 'Socket', 'RawSocket',
  'SecureSocket', 'ServerSocket', 'RawDatagramSocket', 'InternetAddress',
  'NetworkInterface',
];

const _bannedPackages = <String>[
  'http:', 'dio:', 'web_socket_channel:', 'connectivity_plus:', 'firebase_core:',
];

void main() {
  group('rule_engine package', () {
    test('pubspec declares no flutter sdk dependency', () {
      expect(File('pubspec.yaml').readAsStringSync(), isNot(contains('sdk: flutter')));
    });

    test('pubspec declares no networking dependency', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final banned in _bannedPackages) {
        expect(pubspec, isNot(contains(banned)), reason: '$banned is banned by invariant 1');
      }
    });

    test('lib holds exactly one barrel', () {
      final top = _libDartPaths().where((p) => p.split('/').length == 2).toList();
      expect(top, ['lib/rule_engine.dart']);
    });

    test('lib imports no package:flutter and no dart:ui', () {
      final paths = _libDartPaths();
      expect(paths, isNotEmpty, reason: 'an empty scan reports success — CONVENTIONS §7');
      final offenders = <String>[
        for (final path in paths)
          for (final line in _codeLines(path))
            if (_bannedImports.any(line.contains)) '$path: $line',
      ];
      expect(offenders, isEmpty);
    });

    // … tests 4, 6 and 7 in the same shape, one behaviour each
  });
}
```

**Run:** `(cd packages/rule_engine && dart test)` → 7 failures. If any passes now, the test is wrong.

## Implementation outline

1. Read `app/pubspec.yaml` and the root `pubspec.yaml`. Confirm `packages/rule_engine` is already a
   `workspace:` member and note how `analysis_defaults` is declared there. Do not change either file.
2. Write `packages/rule_engine/pubspec.yaml`: `name: rule_engine`, `resolution: workspace`,
   `environment: sdk: ^3.12.0`, `dev_dependencies:` with `analysis_defaults` declared the same way the app
   declares it. Add the runner with `dart pub add dev:test` and let it write the constraint — record the
   resolved version in the commit body rather than typing a guess.
3. Write `packages/rule_engine/analysis_options.yaml` exactly as `FLUTTER_GUIDE.md` §4.3 shows it: the
   `include:` line first, then `linter: rules:` with `public_member_api_docs` and `avoid_print`.
4. Write `packages/rule_engine/lib/rule_engine.dart`: a `///` library doc comment — one-sentence summary,
   blank `///` line, then the rest — followed by `library;`. Say what the package is (the pure-Dart core
   the app and `tools/content_builder/` both depend on), what it never contains (a Flutter import, a
   database row type, a user-visible sentence — D-7), and that its normalisation contract is shared with
   the builder. Do not restate the fold; point at `SPEC.md` §9.4.
5. `dart pub get` at the repository root. The workspace resolves as one lockfile.
6. Re-run the suite. All 7 green.
7. Run the gate and **read its output**: it must not print "no domain files matched".

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 7 tests pass, and each failed first.
- [ ] `packages/rule_engine/pubspec.yaml` contains the string `flutter` nowhere at all.
- [ ] `dart pub get` at the repository root resolves the workspace with one lockfile and no
      `dependency_overrides`.
- [ ] `lib/rule_engine.dart` carries a library doc comment whose first paragraph is one sentence
      (`FLUTTER_GUIDE.md` §3.4), and no `TODO`.
- [ ] `check_rule_engine.sh packages/rule_engine/lib` prints `OK` **and** does not print the
      "checks 1-4 had nothing to read" note.
- [ ] Nothing outside `packages/rule_engine/` changed.

## Gates

Run from the repository root — check 5 of the gate does its own `find .`, so the working directory
matters.

```bash
dart format --set-exit-if-changed packages/rule_engine
dart analyze packages/rule_engine
(cd packages/rule_engine && dart test)
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(rule_engine): create the pure-Dart package and prove it cannot import Flutter

The no-Flutter rule is enforced by absence rather than by review: with no
flutter key in the pubspec, package:flutter is an unresolved-URI compile
error, which is what lets tools/content_builder/ compile this package under
a plain dart run with no Flutter SDK present. A guard test walks lib/ as the
fourth layer of the offline proof and asserts the walk visited something,
because a scan over an empty tree reports success.

Task: E02/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
