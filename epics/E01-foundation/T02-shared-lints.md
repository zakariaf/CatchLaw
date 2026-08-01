# E01/T02 — Shared lints and the nested-options trap

| | |
|---|---|
| **Epic** | E01 — Foundation, workspace and the offline gates |
| **Branch** | `epic/01-foundation` (shared) |
| **Commit** | `build(workspace): share one lint config and stop the nested-options rules loss` |
| **Depends on** | T01 (the four members must exist before they can share a config) |
| **Size** | M |
| **Spec** | `SPEC.md` §15 step 1 ("lint rules"), §14 static block (the analyzer half of layer 1) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lint-and-style-config` | Owns `analysis_options.yaml`. `references/config-mechanics.md` holds the two mechanics this task turns on: `errors:` re-ranks but never enables, and a mixed list/map `linter: rules:` block is a parse error — a broken analyzer, which is a green build |
| `catchlaw-offline-guarantee` | Rule 2: `depend_on_referenced_packages` promoted to **error** is layer 1's second half. Without it a transitive `http` arriving under `printing` imports cleanly from `app/lib` |
| `dependency-hygiene` | Rule 5 and `references/sdk-pin-and-lint-include.md`: the include filename is coupled to the resolved SDK, and a missing include is the failure mode that looks green |
| `project-structure-and-packages` | Why `analysis_defaults` is a member every other member dev-depends on rather than a copied file |
| `catchlaw-conventions-index` | Rule 10 — a general rule is never forked into an app skill. This task consumes `lint-and-style-config` and diverges from it once, in writing, with a reason |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `FLUTTER_GUIDE.md` | Part 4.3 "The recommended `analysis_options.yaml`" | The root file **verbatim**, including the `plugins:` block, the `analyzer: errors:` promotions, `formatter: page_width: 100` and the full `linter: rules:` list |
| `FLUTTER_GUIDE.md` | Part 4.3, the nested override at the bottom | `packages/rule_engine/analysis_options.yaml`, and the comment that says the `include:` line is mandatory |
| `FLUTTER_GUIDE.md` | Part 4.1, facts 2, 3, 5 and 6 | `plugins:` is top-level since Dart 3.10; pin `riverpod_lint` at exactly 3.1.4; `strong-mode:` keys are silent no-ops; `flutter_lints` dropped the `prefer_const_*` rules for annoyance, not for lack of value |
| `FLUTTER_GUIDE.md` | Part 4.2 | Why this project builds on `flutter_lints` rather than `very_good_analysis` — the divergence recorded below |
| `FLUTTER_GUIDE.md` | Part 4.4 | Why `**/*.g.dart` is **not** excluded: `exclude` still resolves and type-checks, so a real error in generated code is swallowed until `flutter build` |
| `FLUTTER_GUIDE.md` | Part 4.5 | `document_ignores` + `unnecessary_ignore`, and the ban on `test/analysis_options.yaml` |
| `FLUTTER_GUIDE.md` | Part 2.4 | `analysis_defaults` as a dev dependency of every member, following `flutter/samples` |
| `.claude/skills/lint-and-style-config/references/config-mechanics.md` | §1, §2, §4, §7 | The include-pin trap, `errors:` vs `linter:`, the exclude/coverage mirror, suppression discipline |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "Layer 1 — the banned package table" | The `depend_on_referenced_packages: error` snippet and the sentence explaining what it stops |
| `.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh` | check 2 | It greps the `analysis_options.yaml` **beside** its target directory. This is why `app/analysis_options.yaml` must state the promotion in its own text |
| `epics/DECISIONS.md` | D-1 | The gate scripts take an explicit target; `app/` is the app's root |

## What this delivers

- `analysis_options.yaml` at the repository root — `FLUTTER_GUIDE.md` Part 4.3 verbatim.
- `app/analysis_options.yaml` — `include: ../analysis_options.yaml`, plus a deliberately restated
  `analyzer: errors: depend_on_referenced_packages: error` with the reason written beside it.
- `packages/rule_engine/analysis_options.yaml` — `include: ../../analysis_options.yaml`, plus
  `public_member_api_docs` and `avoid_print`.
- `tools/content_builder/analysis_options.yaml` — `include: ../../analysis_options.yaml`.
- `packages/analysis_defaults/pubspec.yaml` gains `dependencies: flutter_lints: ^6.0.0`, and the three
  other members gain `dev_dependencies: analysis_defaults:` (workspace-resolved, no version, no `path:`).
- `packages/analysis_defaults/README.md` — three sentences saying what this package is and why it holds no
  Dart.
- `app/test/policy/lint_config_test.dart`.
- `pubspec.lock` regenerated and staged in the same commit (`dependency-hygiene` rule 3).

## Why it is built this way

**The nested-options trap is the whole task.** A nested `analysis_options.yaml` **replaces** the parent for
its subtree. `packages/rule_engine/analysis_options.yaml` exists to add `public_member_api_docs` — and
without its `include: ../../analysis_options.yaml` line the package silently loses `strict-casts`,
`unawaited_futures: error`, `always_use_package_imports`, every promoted error and every rule in the
Part 4.3 list. `FLUTTER_GUIDE.md` marks this "(Verified.)". The failure is invisible: `dart analyze` in
that package reports zero problems, which is exactly what a clean package looks like. Test 7 is the only
thing standing between E02 and a package's worth of code analysed under a configuration nobody chose.

**`plugins:` may not appear in a nested file.** `FLUTTER_GUIDE.md` Part 4.3 comments it on the key itself:
top-level, Dart 3.10+, *cannot appear in a nested options file*. So the block lives in the root file only,
and test 8 asserts no nested file grows one. Part 4.1 fact 2 is the matching trap in the other direction:
`analyzer: plugins:` is the pre-3.10 form, and every tutorial older than about November 2025 writes it.

**`app/analysis_options.yaml` restates `depend_on_referenced_packages: error` on purpose.** The `include:`
line already gives the app the promotion, so the restatement changes nothing about analysis. It exists
because `check_no_network.sh` check 2 greps the `analysis_options.yaml` sitting beside its target
directory and cannot follow an `include:`. Without the restated line that check silently skips — the gate
prints nothing and the job goes green, which is the E01/T08 failure mode arriving three tasks early. The
line carries its own comment saying so, at the point of temptation, exactly as `policy-grep-gate.md`
prescribes.

**Rejected: leaving `app/analysis_options.yaml` out entirely.** The analyzer walks up, so the app would
inherit the root config correctly and the file would be redundant. But the same gate check would then be
skipped forever, and a skipped check that prints nothing is indistinguishable from a passing one.

**Rejected: `very_good_analysis`.** `lint-and-style-config` rule 2 requires it with a version-stamped
include. `FLUTTER_GUIDE.md` Part 4.2 rejects it for this project with reasons that are specific rather than
stylistic: VGA is aimed at *published packages*, so it turns on `public_member_api_docs`,
`lines_longer_than_80_chars`, `require_trailing_commas` and `discarded_futures`, three of which are wrong
for a private app, and it still ships two rules the Dart team deprecated in the 3.13 cycle. Part 4 was
executed against the local Dart 3.12.2 toolchain and the `flutter_lints`-based config passes
`dart analyze --fatal-infos` with zero `undefined_lint`. This is the only place in E01 where a general
skill is not followed, and it is written into the file itself so nobody has to reconstruct the argument.
It is recorded as an unsettled conflict in the epic's Risks — a `D-10` in `DECISIONS.md` is what would
close it.

**Rejected: excluding `**/*.g.dart`.** `FLUTTER_GUIDE.md` Part 4.4, verified: `exclude` still resolves and
type-checks the excluded file and only suppresses *reporting* of diagnostics inside it. So a genuine
compile error in generated code — the shape produced by a drift schema change in E05 — is swallowed until
`flutter build`. It is also unnecessary: drift and freezed both emit
`// ignore_for_file: type=lint,unused_import` in their generated headers, which turns off lints while
leaving errors and warnings on. That is strictly better than an exclude.

**`riverpod_lint` is pinned to exactly `3.1.4`, not `^3.1.4`.** Part 4.1 fact 3: 3.1.6 fails version
solving on this toolchain (`analyzer ^12` versus `^13`). This is a deliberate exception to
`dependency-hygiene` rule 1's caret-ranges-only rule and it does not collide with that skill's audit
script, which reads pins in `pubspec.yaml`; this pin is in the `plugins:` block of
`analysis_options.yaml`. `custom_lint` is not added and never will be — Part 4.1 fact 1: the repository is
archived and pins an analyzer that cannot parse Dart 3.12 source.

**Why `analysis_defaults` exists at all.** `FLUTTER_GUIDE.md` Part 2.4 follows `flutter/samples`: the
shared lint dependency is factored into one package every member dev-depends on. `flutter_lints` has to be
resolvable for `include: package:flutter_lints/flutter.yaml` to load; putting it in one place means an
upgrade is one line rather than four, and the dev-dependency edge from each member is the visible record of
why it resolves. The package holds no Dart and therefore has no test suite — T03 records that as a decision
rather than letting it look like an omission.

## Tests first

Write `app/test/policy/lint_config_test.dart` before touching any YAML. Run it. **All twelve must fail** —
no `analysis_options.yaml` exists anywhere yet. A test that passes now is reading the wrong file.

| # | Test name | Asserts | Why this case exists |
|---|---|---|---|
| 1 | `Root analysis options include the flutter_lints rule set` | `include: package:flutter_lints/flutter.yaml` | The floor the whole config is built on. `flutter_lints` 6.0.0 has no `recommended.yaml`; the include path is the only correct one (Part 4.2) |
| 2 | `Root analysis options declare plugins as a top-level key` | `plugins:` at column 0, and no `plugins:` nested under `analyzer:` | Part 4.1 fact 2. The pre-3.10 form is accepted as unknown config and does nothing — a plugin that never loads produces the same output as a plugin with no findings |
| 3 | `Root analysis options pin riverpod_lint to exactly 3.1.4` | `riverpod_lint: 3.1.4`, no caret | Part 4.1 fact 3: a caret range resolves 3.1.6 and version solving fails on `analyzer ^12` vs `^13`. The failure is at resolve time, so it blocks everyone at once |
| 4 | `Root analysis options promote depend_on_referenced_packages to error` | under `analyzer: errors:` | Offline layer 1's second half. At warning level the rule is noise in a 400-line log and ships the same day (`catchlaw-offline-guarantee` rule 2) |
| 5 | `Root analysis options use list form throughout the linter rules block` | every entry under `linter: rules:` starts `- ` | `config-mechanics.md` §2: mixing `- rule` and `rule: true` in one block is a parse error, which is a broken analyzer, which is a green build |
| 6 | `App analysis options include the workspace root options file` | `include: ../analysis_options.yaml` | Without it the app loses every rule configured at the root, silently |
| 7 | `rule_engine analysis options include the workspace root options file` | `include: ../../analysis_options.yaml` | The headline trap, marked "(Verified.)" in Part 4.3. E02 and E03 write their whole package under this config |
| 8 | `No nested analysis options file declares a plugins key` | app, rule_engine, content_builder | Part 4.3: `plugins:` cannot appear in a nested options file. A copy-paste of the root file into a member is the way this happens |
| 9 | `App analysis options state depend_on_referenced_packages as error in their own text` | textual match in `app/analysis_options.yaml` | `check_no_network.sh` check 2 reads the file beside its target and cannot follow an `include:`. Deleting this line does not weaken the analyzer — it blinds the gate |
| 10 | `Root analysis options do not exclude generated Dart files` | no `*.g.dart` / `*.freezed.dart` / `*.drift.dart` under `analyzer: exclude:` | Part 4.4, verified: an exclude still type-checks the file and only hides its diagnostics, so a real error in drift output survives until `flutter build` |
| 11 | `Root analysis options enable document_ignores and unnecessary_ignore` | both in `linter: rules:` | Part 4.5. The failure mode of every strict config is `// ignore:` rot; these two are the antidote and are the pair most often left off |
| 12 | `No package declares a test analysis options file` | no `*/test/analysis_options.yaml` | Part 4.5: such a file replaces the whole root config for the test tree. Per-file `// ignore_for_file:` is the sanctioned alternative and `document_ignores` forces a reason |

```dart
// app/test/policy/lint_config_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'repo_root.dart';

const nested = <String>[
  'app/analysis_options.yaml',
  'packages/rule_engine/analysis_options.yaml',
  'tools/content_builder/analysis_options.yaml',
];

String rootText() => repoFile('analysis_options.yaml').readAsStringSync();

YamlMap rootYaml() => loadYaml(rootText()) as YamlMap;

void main() {
  test('Root analysis options include the flutter_lints rule set', () {
    expect(rootYaml()['include'], 'package:flutter_lints/flutter.yaml');
  });

  test('Root analysis options declare plugins as a top-level key', () {
    expect(rootYaml().containsKey('plugins'), isTrue);
    expect((rootYaml()['analyzer'] as YamlMap).containsKey('plugins'), isFalse,
        reason: 'analyzer: plugins: is the pre-Dart-3.10 form. It loads nothing and '
            'reports nothing, which reads exactly like a plugin with no findings');
  });

  test('Root analysis options pin riverpod_lint to exactly 3.1.4', () {
    expect((rootYaml()['plugins'] as YamlMap)['riverpod_lint'], '3.1.4',
        reason: 'a caret range resolves 3.1.6, which fails version solving on '
            'analyzer ^12 vs ^13 (FLUTTER_GUIDE 4.1 fact 3)');
  });

  test('Root analysis options promote depend_on_referenced_packages to error', () {
    final errors = (rootYaml()['analyzer'] as YamlMap)['errors'] as YamlMap;
    expect(errors['depend_on_referenced_packages'], 'error');
  });

  test('Root analysis options use list form throughout the linter rules block', () {
    expect(((rootYaml()['linter'] as YamlMap)['rules']) is YamlList, isTrue,
        reason: 'a block mixing "- rule" and "rule: true" is a config parse error — '
            'a broken analyzer reads as a green build');
  });

  test('App analysis options include the workspace root options file', () {
    final yaml = loadYaml(repoFile('app/analysis_options.yaml').readAsStringSync()) as YamlMap;
    expect(yaml['include'], '../analysis_options.yaml');
  });

  test('rule_engine analysis options include the workspace root options file', () {
    final yaml = loadYaml(
        repoFile('packages/rule_engine/analysis_options.yaml').readAsStringSync()) as YamlMap;
    expect(yaml['include'], '../../analysis_options.yaml',
        reason: 'a nested options file REPLACES the parent for its subtree — without '
            'this line the package silently loses every rule (FLUTTER_GUIDE 4.3)');
  });

  test('No nested analysis options file declares a plugins key', () {
    final offenders = <String>[
      for (final path in nested)
        if ((loadYaml(repoFile(path).readAsStringSync()) as YamlMap).containsKey('plugins')) path,
    ];
    expect(offenders, isEmpty,
        reason: 'plugins: is top-level only and cannot appear in a nested options '
            'file:\n${offenders.join('\n')}');
  });

  test('App analysis options state depend_on_referenced_packages as error in their own text', () {
    expect(repoFile('app/analysis_options.yaml').readAsStringSync(),
        contains('depend_on_referenced_packages: error'),
        reason: 'check_no_network.sh check 2 greps the options file beside its target '
            'and cannot follow an include: — without the restated line the gate skips');
  });

  test('Root analysis options do not exclude generated Dart files', () {
    final excludes =
        ((rootYaml()['analyzer'] as YamlMap)['exclude'] as YamlList).cast<String>();
    final offenders = excludes
        .where((e) => e.contains('.g.dart') || e.contains('.freezed.dart') || e.contains('.drift.dart'))
        .toList();
    expect(offenders, isEmpty,
        reason: 'exclude still resolves and type-checks the file and only hides its '
            'diagnostics, so a real error in generated code survives to build time '
            '(FLUTTER_GUIDE 4.4):\n${offenders.join('\n')}');
  });

  test('Root analysis options enable document_ignores and unnecessary_ignore', () {
    final rules = ((rootYaml()['linter'] as YamlMap)['rules'] as YamlList).cast<String>();
    expect(rules, containsAll(<String>['document_ignores', 'unnecessary_ignore']));
  });

  test('No package declares a test analysis options file', () {
    final offenders = repoRoot()
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path)
        .where((p) => p.endsWith('/test/analysis_options.yaml'))
        .toList();
    expect(offenders, isEmpty,
        reason: 'it replaces the whole root config for the test tree; use per-file '
            '// ignore_for_file: instead (FLUTTER_GUIDE 4.5):\n${offenders.join('\n')}');
  });
}
```

**Run:** `cd app && flutter test test/policy/lint_config_test.dart` → 12 failures, all
`FileSystemException` on a missing `analysis_options.yaml`. That is the correct red.

## Implementation outline

1. Copy `FLUTTER_GUIDE.md` Part 4.3's config into `analysis_options.yaml` at the repository root,
   **verbatim**, comments included. The comments are the reasoning and this is the file where a stranger
   goes looking for it.
2. Add `flutter_lints: ^6.0.0` to `packages/analysis_defaults/pubspec.yaml` under `dependencies`, and
   `analysis_defaults:` (bare, workspace-resolved) to `dev_dependencies` of `app`, `packages/rule_engine`
   and `tools/content_builder`.
3. Create `packages/rule_engine/analysis_options.yaml` with the `include:` line **first**, then
   `public_member_api_docs` and `avoid_print`. Two consumers make an undocumented public member real debt.
4. Create `tools/content_builder/analysis_options.yaml` with the `include:` line and nothing else.
5. Create `app/analysis_options.yaml` with the `include:` line and the restated
   `depend_on_referenced_packages: error`, with the comment naming `check_no_network.sh` check 2 as the
   reason.
6. Write `packages/analysis_defaults/README.md`: what it is, that it holds no Dart, and that T03's
   workflow lists it in the `no-suite` set for that reason.
7. `dart pub get` at the root; stage the `pubspec.lock` delta in this commit.
8. Run `flutter analyze --fatal-infos` from the root. **Read the output for plugin diagnostics, not just
   the exit code.** Zero `undefined_lint`, zero `unrecognized_error_code`, and — the open question from the
   epic's Risk 2 — zero errors from `import_lint` over its `package:catchlaw/ui/**.dart` target, which does
   not exist until E08. If the plugin errors on an unmatched target, move the `ui_must_not_import_drift`
   rule body to E05 (where drift arrives), keep `riverpod_lint` in the block, and say so in the commit body.
9. Re-run the twelve tests plus the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 tests pass, and each failed first.
- [ ] `flutter analyze --fatal-infos` from the repository root reports zero problems **and** zero plugin
      diagnostics. The plugin result is stated in the commit body either way.
- [ ] Removing the `include:` line from `packages/rule_engine/analysis_options.yaml` makes test 7 fail —
      confirmed once, by hand, then reverted. The trap this task exists for is proved to be trapped.
- [ ] `check_no_network.sh app/lib` passes **and** its check 2 no longer skips: it now finds
      `app/analysis_options.yaml` and reads the promotion out of it.
- [ ] `pubspec.lock` is staged in this commit alongside the pubspec edits (`dependency-hygiene` rule 3).
- [ ] The divergence from `lint-and-style-config` rule 2 is written in `analysis_options.yaml` as a comment
      naming `FLUTTER_GUIDE.md` Part 4.2, and is repeated in the commit body. It is not silent.
- [ ] No `custom_lint` and no `dart_code_metrics` anywhere (Part 4.1 facts 1 and 4).

## Gates

```bash
dart pub get
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
cd app && flutter test && cd ..
cd packages/rule_engine && dart analyze && cd ../..
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh app/lib
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
build(workspace): share one lint config and stop the nested-options rules loss

A nested analysis_options.yaml REPLACES the parent for its subtree. Without
`include: ../../analysis_options.yaml`, packages/rule_engine/ would silently
lose strict-casts, every promoted error and every rule in FLUTTER_GUIDE Part
4.3's list — and dart analyze there would report zero problems, which is what a
clean package also looks like. That is the failure this commit exists to make
impossible, and a test asserts the include line in each of the three members.

app/analysis_options.yaml restates depend_on_referenced_packages: error even
though the include already provides it. check_no_network.sh check 2 greps the
options file beside its target directory and cannot follow an include, so
without the restated line that check silently skips. The line carries its own
comment saying so.

Generated Dart is deliberately NOT excluded: FLUTTER_GUIDE Part 4.4 verified
that exclude still type-checks the file and only hides its diagnostics, so a
real error in drift output would survive until build time. drift and freezed
already emit ignore_for_file: type=lint in their headers.

Divergence, stated rather than smuggled: lint-and-style-config rule 2 mandates
very_good_analysis. This project builds on flutter_lints per FLUTTER_GUIDE Part
4.2, which rejects VGA as aimed at published packages and was executed against
Dart 3.12.2. DECISIONS.md does not yet settle this; the reason is written into
analysis_options.yaml.

Task: E01/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
