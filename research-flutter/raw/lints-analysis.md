# Linting, Static Analysis and Enforced Code Quality — Flutter 3.44.6 / Dart 3.12.2

**Research date:** 2026-07-27
**Target toolchain (verified locally):** `Flutter 3.44.6 • stable • rev ee80f08bbf • 2026-07-08` / `Dart SDK 3.12.2 (stable, 2026-06-09)`
**Target app:** 100% offline Android + iOS app; two drift SQLite DBs; flutter_riverpod; 6 locales incl. Arabic RTL; a pure-Dart domain package (rule engine) with no Flutter imports; custom painting, SVG, PDF, camera, single-shot GPS, golden tests; cold start < 1.2 s on low-end Android.

**Everything in this document that is marked VERIFIED was executed against the local Dart 3.12.2 toolchain in a scratch package.** Every rule name and every diagnostic code in the final `analysis_options.yaml` was run through `dart analyze --fatal-infos` and produced **zero** `undefined_lint`, `unrecognized_error_code`, `duplicate_rule` or incompatible-rule diagnostics — both standalone and combined with the complete `flutter_lints` 6.0.0 rule set.

---

## 0. Executive summary — the eight things that actually matter

1. **`custom_lint` is dead.** Its README carries a "no longer under active development" warning and it cannot resolve alongside modern tooling on Dart 3.12. Use the official `plugins:` system instead. (§4)
2. **The analyzer plugin system changed shape in Dart 3.10 / Flutter 3.38.** `plugins:` is now a **top-level** key in `analysis_options.yaml`, not `analyzer: plugins:`. Every tutorial older than ~Nov 2025 is wrong. (§4)
3. **`riverpod_lint` 3.1.6 — the latest release, published 2026-07-26 — does not resolve on this toolchain.** Pin `3.1.4`. VERIFIED reproduction in §4.3.
4. **`dart_code_metrics` is gone.** GitHub repo archived 2023-07-16; pub SDK constraint is `<3.0.0`, i.e. it literally cannot run on Dart 3. It became the commercial DCM (dcm.dev). (§5)
5. **The legacy `analyzer: strong-mode: implicit-casts/implicit-dynamic` keys are silent no-ops** — no warning, no effect. Thousands of projects still carry them believing they do something. VERIFIED. (§9.1)
6. **`flutter_lints` deliberately dropped the `prefer_const_*` lints in 5.0.0** because Flutter's own benchmarks found no statistically significant real-world performance difference. I still recommend enabling them — but for a different reason than most people think. (§6.1)
7. **`unreachable_from_main` still false-positives on user-defined operators on Dart 3.12.2**, even though the tracking issue is closed. VERIFIED reproduction. Do not enable it project-wide. (§9.3)
8. **There is no lint that can prove "no networking".** The provable mechanisms are: (a) don't declare the dependency, (b) omit `android.permission.INTERNET`, (c) a guard test. A working guard test is in §8.

---

## 1. What is actually in each official rule set

### 1.1 `package:lints` — the Dart team's set

- **Latest: `lints` 6.1.0**, published **2026-01-30**. Source: `curl -s https://pub.dev/api/packages/lints`.
- **The repo `dart-lang/lints` is ARCHIVED** (`{"archived": true, "pushed_at": "2024-12-20"}` via `gh api repos/dart-lang/lints`). It moved into the `dart-lang/core` monorepo at `pkgs/lints`.
  **If you read `github.com/dart-lang/lints` you are reading a stale 5.1.1 snapshot.** The live files are:
  - https://github.com/dart-lang/core/blob/main/pkgs/lints/lib/core.yaml
  - https://github.com/dart-lang/core/blob/main/pkgs/lints/lib/recommended.yaml

**`core.yaml` (36 rules, as of lints 6.1.0)** — verbatim rule list:

```
avoid_empty_else, avoid_relative_lib_imports, avoid_shadowing_type_parameters,
avoid_types_as_parameter_names, await_only_futures, camel_case_extensions,
camel_case_types, collection_methods_unrelated_type,
curly_braces_in_flow_control_structures, dangling_library_doc_comments,
depend_on_referenced_packages, empty_catches, file_names, hash_and_equals,
implicit_call_tearoffs, library_annotations, no_duplicate_case_values,
no_wildcard_variable_uses, non_constant_identifier_names,
null_check_on_nullable_type_parameter, prefer_generic_function_type_aliases,
prefer_is_empty, prefer_is_not_empty, prefer_iterable_whereType,
prefer_typing_uninitialized_variables, provide_deprecation_message,
secure_pubspec_urls, strict_top_level_inference, type_literal_in_constant_pattern,
unintended_html_in_doc_comment, unnecessary_overrides,
unrelated_type_equality_checks, use_string_in_part_of_directives, valid_regexps,
void_checks
```

**`recommended.yaml`** = `core.yaml` + 57 more (`annotate_overrides` … `use_super_parameters`, incl. the 6.x additions `unnecessary_underscores` and `use_null_aware_elements`).

**Version deltas that date the advice** (source: `pkgs/lints/CHANGELOG.md`):

| lints version | Date | Change |
|---|---|---|
| 5.0.0 | 2024-09-25 | +`invalid_runtime_check_with_js_interop_types`, +`unnecessary_library_name`, **−`avoid_null_checks_in_equality_operators`** |
| 5.1.0/5.1.1 | 2024-12-20 | +`unintended_html_in_doc_comment`; moved to `dart-lang/core` |
| 6.0.0 | 2025-04-15 | +`strict_top_level_inference` (core), +`unnecessary_underscores` (recommended); requires Dart 3.8 |
| 6.1.0 | 2026-01-30 | +`use_null_aware_elements`; "Run `dart format` with the new style" |

### 1.2 `package:flutter_lints`

- **Latest: `flutter_lints` 6.0.0**, published **2025-05-27** — **14 months old at time of writing**. Source: `curl -s https://pub.dev/api/packages/flutter_lints`.
- **Include path is `package:flutter_lints/flutter.yaml`** — the file in `lib/` is literally named `flutter.yaml`. (Confirmed by `gh api repos/flutter/packages/contents/packages/flutter_lints/lib/flutter.yaml` and by the `flutter create` template at `packages/flutter_tools/templates/app/analysis_options.yaml.tmpl`, which emits `include: package:flutter_lints/flutter.yaml`.) There is no `recommended.yaml` in this package — if a source tells you to include `package:flutter_lints/recommended.yaml`, it is wrong.
- Its `pubspec.yaml` says `sdk: ^3.10.0` and `lints: ^6.0.0` — which resolves to **lints 6.1.0**, so you do get `use_null_aware_elements`.
- The unreleased `NEXT` entry in `flutter/packages`' CHANGELOG bumps the floor to Flutter 3.38 / Dart 3.10.

**The entire Flutter-specific delta is 10 rules** (verbatim from `flutter.yaml`):

```yaml
include: package:lints/recommended.yaml

linter:
  rules:
    - avoid_print
    - avoid_unnecessary_containers
    - avoid_web_libraries_in_flutter
    - no_logic_in_create_state
    - prefer_const_constructors_in_immutables
    - sized_box_for_whitespace
    - sort_child_properties_last
    - use_build_context_synchronously
    - use_full_hex_values_for_flutter_colors
    - use_key_in_widget_constructors
```

**Source:** https://github.com/flutter/packages/blob/main/packages/flutter_lints/lib/flutter.yaml

**flutter_lints 5.0.0 (2024-09-25) REMOVED `prefer_const_constructors`, `prefer_const_declarations`, `prefer_const_literals_to_create_immutables`.** See §6.1 — this is the single most consequential and least-known change in the set.

**Bottom line:** `flutter_lints` totals **102 rules**. Dart 3.12.2 ships **251 lint rules** (`pkg/linter/tool/machine/rules.json`), of which **224 are stable**. **flutter_lints leaves 125 stable rules turned off.** It is a floor, not a ceiling.

### 1.3 `package:very_good_analysis` (Very Good Ventures)

- **Latest: 10.3.0**, published **2026-06-18**. `environment: sdk: ^3.12.0` — it tracks the current SDK. Source: `curl -s https://pub.dev/api/packages/very_good_analysis`.
- **Maintenance status: ACTIVE and healthy.** Release cadence in the last 12 months: 10.0.0 (2025-08-22, Dart 3.9) → 10.1.0 (2026-02-02, Dart 3.10) → 10.2.0 (2026-02-16, Dart 3.11) → 10.3.0 (2026-06-18, Dart 3.12). It ships a versioned file per release (`lib/analysis_options.10.3.0.yaml`) so you can pin exactly.
- **It does NOT `include:` `lints` or `flutter_lints`** — it is a standalone, self-contained ~200-rule list, plus `strict-casts`/`strict-inference`/`strict-raw-types`, plus `formatter: trailing_commas: preserve`, plus `analyzer: errors:` overrides.
- **Source:** https://github.com/VeryGoodOpenSource/very_good_analysis/blob/main/lib/analysis_options.10.3.0.yaml

**Two curation decisions worth stealing (both are recent and evidence-driven):**

| Change | Version | Reason (primary source) |
|---|---|---|
| Removed `prefer_expression_function_bodies` | 10.1.0-rc.2 (2025-12-09) | [PR #187](https://github.com/VeryGoodOpenSource/very_good_analysis/pull/187) |
| Removed `unreachable_from_main` | 10.3.0-rc.1 (2026-06-02) | [Issue #197](https://github.com/VeryGoodOpenSource/very_good_analysis/issues/197): *"There are still many unresolved issues related to this lint … especially this [false positive issue](https://github.com/dart-lang/sdk/issues/61891)"* |

**Two problems with VGA 10.3.0 as a drop-in:**

1. **It still enables two rules the Dart team deprecated in the 3.13 dev cycle**: `one_member_abstracts` and `avoid_private_typedef_functions`. Source: Dart SDK CHANGELOG 3.13.0 — *"deprecated: `avoid_private_typedef_functions`, and `one_member_abstracts`. If there is desire to keep using these, they can be re-implemented with analyzer plugins."*
2. **It sets `public_member_api_docs`, `lines_longer_than_80_chars`, `require_trailing_commas`, `prefer_int_literals`, `cascade_invocations` and `discarded_futures` on.** Those are correct for a consultancy that publishes packages. They are wrong for a private app. See §9.

**Verdict:** VGA is a legitimately maintained, high-quality set and the best off-the-shelf strict option. **My recommendation is still to build your own list on top of `flutter_lints`** (§7) because (a) you need per-directory divergence for the pure-Dart domain package vs. the app vs. the CLI tool, and (b) VGA's curation is aimed at published packages and forces you to disable a dozen rules anyway. If you disagree and want the batteries-included path, use `very_good_analysis: ^10.3.0` and then explicitly disable the rules listed in §9.

---

## 2. The rule index — what's actually there in Dart 3.12.2

**Canonical index:** https://dart.dev/tools/linter-rules
**Machine-readable source of truth:** `https://raw.githubusercontent.com/dart-lang/sdk/3.12.2/pkg/linter/tool/machine/rules.json` (251 entries, JSON, one object per rule with `name`, `state`, `categories`, `incompatible`, `fixStatus`, `sinceDartSdk`).

**⚠️ VERIFIED CAVEAT: `rules.json` at the `3.12.2` tag is stale.** It omits `simple_directive_paths`, even though the Dart 3.12.0 CHANGELOG announces it and `dart analyze` on 3.12.2 accepts it. Do not treat `rules.json` as authoritative for the newest rules — test with `dart analyze` instead (see §10.4).

**States in 3.12.2:** 224 stable, 14 removed, 10 experimental, 3 deprecated.

**Deprecated in 3.12.2 — do not enable, they will be removed:**

| Rule | Deprecated in |
|---|---|
| `avoid_null_checks_in_equality_operators` | (removed from `lints` 5.0.0) |
| `prefer_final_parameters` | Dart 3.11 CHANGELOG |
| `use_if_null_to_convert_nulls_to_bools` | Dart 3.11 CHANGELOG |

**Deprecated in the Dart 3.13 dev cycle (forward-looking — VGA still ships these):** `avoid_private_typedef_functions`, `one_member_abstracts`.

**Mutually incompatible pairs** (from `rules.json`; the analyzer reports conflicts since Dart 3.10 — *"Lint rules which are incompatible with each other and which are specified in included analysis options files are now reported"*):

```
always_specify_types      <-> avoid_types_on_closure_parameters
always_specify_types      <-> omit_local_variable_types
always_specify_types      <-> omit_obvious_local_variable_types
always_specify_types      <-> omit_obvious_property_types
always_use_package_imports<-> prefer_relative_imports
avoid_final_parameters    <-> prefer_final_parameters
omit_local_variable_types <-> specify_nonobvious_local_variable_types
omit_obvious_property_types <-> type_annotate_public_apis
prefer_double_quotes      <-> prefer_single_quotes
prefer_final_in_for_each  <-> unnecessary_final
prefer_final_locals       <-> unnecessary_final
prefer_final_parameters   <-> unnecessary_final
```

**Rules newer than Flutter 3.44.6 — do NOT put these in your config yet (VERIFIED: `dart analyze` on 3.12.2 emits `undefined_lint`):**
`no_raw_types` (3.13), `async_return_with_no_await` (3.13), `empty_container_bodies`, `initialize_in_field_declaration`, `no_dynamic_casts`, `unnecessary_const_in_enum_constructor`, `unnecessary_primary_constructor_body`, `unnecessary_type_name_in_constructor`, `use_declaring_parameters`, `use_primary_constructors`.

This matters because **`flutter/flutter`'s own `analysis_options.yaml` on `master` contains `no_raw_types` and other dev-SDK rules.** If you copy that file onto stable 3.44.6 you get `undefined_lint` warnings that fail CI under `--fatal-warnings` (which is **on by default** for `dart analyze`).

---

## 3. `analysis_options.yaml` mechanics — the parts people get wrong

**Reference:** https://dart.dev/tools/analysis

### 3.1 `analyzer: language:` — the strictness switches

```yaml
analyzer:
  language:
    strict-casts: true      # no implicit downcast from dynamic
    strict-inference: true  # error when inference would land on dynamic
    strict-raw-types: true  # error on bare List / Map / Future
```

**WHY:** These three are the highest-leverage lines in the whole file, because they upgrade *type-system holes* to *errors*, not merely style opinions. `strict-casts` in particular closes the single most common source of runtime `TypeError` in Dart: a `dynamic` value flowing silently into a typed slot. That is exactly the shape of bug you get reading rows out of a drift `customSelect` or a decoded ARB/JSON payload.

**VERIFIED:**
```dart
void main() {
  dynamic d = 'hello';
  int n = d;            // error - invalid_assignment   (strict-casts)
  List raw = <int>[1];  // warning - strict_raw_type    (strict-raw-types)
  print('$n $raw');
}
```
With only the legacy `strong-mode:` keys set instead, `dart analyze` reports **`No issues found!`** — see §9.1.

**Genuine disagreement:** `flutter/flutter` enables only `strict-casts` and `strict-inference`, **not** `strict-raw-types`. `flutter/packages` and `very_good_analysis` enable all three.
**My recommendation: all three.** The framework repo omits `strict-raw-types` because 11 years of accumulated code uses bare `List`/`Future`; you are greenfield and pay zero migration cost. Sources: [flutter/flutter analysis_options.yaml](https://github.com/flutter/flutter/blob/master/analysis_options.yaml), [flutter/packages analysis_options.yaml](https://github.com/flutter/packages/blob/main/analysis_options.yaml).

### 3.2 `analyzer: errors:` — severity overrides

Severities: `ignore`, `info`, `warning`, `error`. Works for **both** analyzer diagnostics and lint rule names.

**VERIFIED: the analyzer validates these names.** A bogus key produces `warning - 'totally_bogus_code_xyz' isn't a recognized diagnostic code. - unrecognized_error_code`. This is a free correctness check on your config — but it also means a stale copy-pasted config **fails CI** under the default `--fatal-warnings`.

**VERIFIED as recognized on 3.12.2:** `unused_import`, `unused_local_variable`, `unused_element`, `unused_field`, `unnecessary_import`, `dead_code`, `todo`, `missing_return`, `missing_required_param`, `invalid_annotation_target`, `body_might_complete_normally_catch_error`, `invalid_use_of_visible_for_testing_member`, `invalid_use_of_protected_member`, `deprecated_member_use`, `deprecated_member_use_from_same_package`, `doc_directive_unknown`, `record_literal_one_positional_no_trailing_comma`.
**VERIFIED as NOT recognized:** `implicit_dynamic` (a very common stale paste).

### 3.3 `analyzer: exclude:` — the subtle part nobody documents

**VERIFIED experiment.** Config `exclude: ["**/*.g.dart"]`, plus:

```dart
// lib/thing.g.dart  (excluded)
int broken() { return 'not an int'; }   // <- real type error
String ok() => 'hi';

// lib/main.dart  (not excluded)
import 'thing.g.dart';
void main() { int x = ok(); print(x); }
```

`dart analyze` output:
```
error - lib/main.dart:2:23 - A value of type 'String' can't be assigned to a variable of type 'int'. - invalid_assignment
```

**The excluded file is still fully resolved and type-checked as part of the library graph — `exclude` only suppresses *reporting of diagnostics located inside* those files.** Callers still get correct types.

**The corollary is the important bit: a real error inside generated code is silently swallowed.** If a drift schema change makes the generated DAO not compile, `exclude: ["**/*.g.dart"]` hides it and you discover it at `flutter build` time instead.

**RECOMMENDATION: do NOT blanket-exclude `**/*.g.dart` in a drift project.** You don't need to — **drift already suppresses lints in its own output**:

```dart
const String generatedHeader = '''
// GENERATED BY drift_dev, DO NOT MODIFY.
// ignore_for_file: type=lint,unused_import
// ''';
```
Source: https://github.com/simolus3/drift/blob/develop/drift_dev/lib/src/utils/header.dart

`freezed` does the same (`// ignore_for_file: type=lint` plus a per-rule list) — verified against `benchmarks/lib/src/equal.freezed.dart` in `rrousselGit/freezed`.

`// ignore_for_file: type=lint` is the documented escape hatch that turns off *all* lint rules for a file while leaving *errors and warnings* on. That is exactly the behaviour you want for generated code, and it is strictly better than `exclude`.

So: **exclude only `build/**` and the Flutter-tooling-generated registrant.** Add `**/*.mocks.dart` only if you use `mockito` (its output does not self-suppress) — `flutter/packages` excludes `'**/*.pb.dart'`, `'**/*.g.dart'`, `'**/*.mocks.dart'` for exactly that reason, but they support protobuf and mockito and don't use drift.

### 3.4 `formatter:` — new in Dart 3.7, and it interacts with a lint

```yaml
formatter:
  page_width: 100          # default 80
  trailing_commas: automate # default; alternative: preserve
```

- `flutter/flutter` and `flutter/packages` both use `page_width: 100`.
- `very_good_analysis` uses `trailing_commas: preserve` **because** it enables `require_trailing_commas`.
- Per-file override: `// dart format width=80` as the first line (seen in real freezed output).
- Region override: **VERIFIED** — `// dart format off` … `// dart format on` preserves a block verbatim through `dart format`.

**Opinionated call:** use `page_width: 100`, keep `trailing_commas: automate` (the default), and **do not** enable `require_trailing_commas`. The Dart 3.7+ "tall style" formatter decides splitting itself; forcing manual commas re-imposes the pre-3.7 tax and produces churn on every refactor. `flutter/flutter` agrees for a pragmatic reason: *"would be nice, but requires a lot of manual work: 10,000+ code locations."* VGA disagrees. If your team specifically wants hand-controlled widget-tree shape for golden-test review, switch to `preserve` + `require_trailing_commas` — that is the only defensible reason.

### 3.5 `include:` and nested options files — a real footgun

Merge order: included files apply in listed order, then local keys override. Multiple includes are allowed:
```yaml
include:
  - package:flutter_lints/flutter.yaml
  - ../analysis_options_shared.yaml
```

**VERIFIED FOOTGUN: a nested `analysis_options.yaml` completely REPLACES the parent for its subtree — it does not inherit.**

```
analysis_options.yaml            ->  linter: rules: [prefer_single_quotes]
lib/sub/analysis_options.yaml    ->  linter: rules: [eol_at_end_of_file]
```
Result: `lib/top.dart` gets `prefer_single_quotes`. `lib/sub/deep.dart` gets **only** `eol_at_end_of_file` — `prefer_single_quotes` is not applied. You must write `include: ../../analysis_options.yaml` in the nested file.

This matters directly for your layout (app + pure-Dart domain package + CLI content tool): every sub-package's options file must `include:` the shared root file or it silently loses everything.

### 3.6 Suppressing diagnostics

```dart
// ignore: invalid_assignment
// ignore: invalid_assignment, dead_code
// ignore_for_file: unused_local_variable
// ignore_for_file: type=lint          // all lints, keeps errors+warnings
// ignore: some_plugin/some_code       // plugin diagnostics (Dart 3.10+)
```
Also works in `pubspec.yaml` (Dart 3.3+) for e.g. `sort_pub_dependencies`.

Two rules police this and you should enable both (§7): **`document_ignores`** (every `// ignore:` needs an explanatory comment) and **`unnecessary_ignore`** (flags `// ignore:` comments for diagnostics that no longer fire). Together they stop suppression rot, which is the main failure mode of strict linting.

---

## 4. Custom lints: the plugin system changed. Most advice online is obsolete.

### 4.1 The new system (Dart 3.10 / Flutter 3.38, Nov 2025)

**Official doc:** https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server_plugin/doc/using_plugins.md

> *"Analyzer plugins are supported starting in Dart 3.10 (Flutter 3.38). Analyzer plugins are specified in the top-level `plugins` section … This is similar to how analyzer plugins are enabled in the legacy analyzer plugin system. However, in the legacy system, this `plugins` section is listed under the top-level `analyzer` section. In the new analyzer plugin system, `plugins` is a top-level section."*

```yaml
# NEW (Dart 3.10+) — top level
plugins:
  riverpod_lint: 3.1.4

# also valid: map form with version + per-rule config
plugins:
  my_plugin:
    version: ^1.0.0
    diagnostics:
      rule_1: true
      rule_3: false
```

Key facts from the official doc, all load-bearing:
- Plugin **warnings** are on by default; plugin **lints** are OFF by default and must be listed under `diagnostics:`.
- **You must restart the Dart Analysis Server after editing `plugins:`.** (VS Code: *Dart: Restart Analysis Server*.)
- **`plugins:` cannot be specified in a nested `analysis_options.yaml`** — root/workspace only. This is a hard constraint for a multi-package repo: plugin config lives at the workspace root, period.
- The analysis server resolves plugins in a synthetic package via `dart pub upgrade`, in a separate isolate. **Dart 3.10 pins `analysis_server_plugin: ^0.3.0`.**
- Since Dart 3.11 the server re-uses an AOT snapshot of the plugin entrypoint, *"saving … on the order of 10 seconds"* per IDE session / `dart analyze` run.

**`analysis_server_plugin` is first-party** (`dart-lang/sdk/pkg/analysis_server_plugin`), latest **0.3.20 published 2026-07-13**. Actively maintained.

### 4.2 `custom_lint` — DEAD. Do not use in 2026.

The README of `invertase/dart_custom_lint` opens with:

> **[!WARNING]** *"This package is no longer under active development. Please see [this comment](https://github.com/invertase/dart_custom_lint/issues/379#issuecomment-3861787414). The official [`analysis_server_plugin`](https://pub.dev/packages/analysis_server_plugin) is now the recommended approach for building custom lints."*

Corroborating facts, all verified:
- `gh api repos/invertase/dart_custom_lint` → `{"archived": true, "pushed_at": "2026-03-24", "open_issues_count": 51}`.
- Last pub release **0.8.1, 2025-09-09** (~10.5 months stale).
- Rémi Rousselet (original author) on issue #379, 2026-01-26: *"I don't have publishing rights to the project anymore since it's under the Invertase ownership and I left."* And 2026-02-06: *"Do note that an official solution for custom_lint exists now: `analysis_server_plugin`. I would advise migrating your lints to the official solution."*
- **VERIFIED — it pins a 9-month-old analyzer.** `dart pub get` with `custom_lint: ^0.8.1` resolves **`analyzer 8.4.0`** (published 2025-10-15). The current analyzer is **14.1.0** (2026-06-18). Because `custom_lint` runs its *own* analyzer instance, analyzer 8.4.0 predates dot shorthands (Dart 3.10, Nov 2025) and private named parameters (Dart 3.12, May 2026) — it cannot parse your source.
- **VERIFIED — it cannot coexist with current riverpod_lint:**
  ```
  Because riverpod_lint >=3.1.4-dev.1 depends on analyzer_plugin ^0.14.0 and
  custom_lint 0.8.1 depends on analyzer_plugin ^0.13.0, riverpod_lint >=3.1.4-dev.1
  is incompatible with custom_lint 0.8.1. … version solving failed.
  ```

**Action:** if any guide tells you to add `custom_lint` to `dev_dependencies` and `analyzer: plugins: - custom_lint` to `analysis_options.yaml`, that guide is obsolete. Delete both.

### 4.3 `riverpod_lint` — use it, but PIN 3.1.4

- **Repo: `rrousselGit/riverpod`, actively maintained** (`pushed_at` 2026-07-26, 7343 stars). `riverpod_lint` 3.1.6 published **2026-07-26 — one day before this research**.
- **It has migrated to the official plugin system.** Its pubspec depends on `analysis_server_plugin: ^0.3.0` + `analyzer: ^13.0.0` and **no longer depends on `custom_lint`**. Its README:
  > *"Riverpod_lint is implemented using [analysis_server_plugin]. As such, it is installed through `analysis_options.yaml` … create an `analysis_options.yaml` next to your `pubspec.yaml` and add: `plugins:\n  riverpod_lint: <version number>`"*

**⚠️ VERIFIED BUG — riverpod_lint 3.1.6 (latest) does not resolve on Flutter 3.44.6 / Dart 3.12.2:**

```
$ cat analysis_options.yaml
plugins:
  riverpod_lint: ^3.1.6
$ dart analyze
An error occurred while executing an analyzer plugin: ... The `dart pub upgrade` command failed:
  Because riverpod_analyzer_utils >=1.0.0-dev.10 depends on analyzer ^12.0.0 and
  riverpod_lint >=3.1.6 depends on analyzer ^13.0.0, riverpod_analyzer_utils >=1.0.0-dev.10
  is incompatible with riverpod_lint >=3.1.6.
```

Version sweep on this exact toolchain:

| riverpod_lint | Result |
|---|---|
| `3.1.3` | ✗ fails (`analysis_server_plugin` / `analyzer_plugin` conflict) |
| **`3.1.4`** | ✅ **`Analyzing ... No issues found!`** |
| `3.1.6` | ✗ fails (`riverpod_analyzer_utils` pins analyzer ^12, riverpod_lint needs ^13) |

**Use `plugins: { riverpod_lint: 3.1.4 }` — an exact pin, not a caret range.** A caret range resolves to 3.1.6 and breaks your IDE and CI. Re-test on every Flutter upgrade.

**What riverpod_lint gives you** (from its README) — 15 lints plus 6 assists. The ones that pay for themselves in this app:
- `missing_provider_scope` — *"Flutter applications using Riverpod should have a `ProviderScope` widget at the top of the widget tree."* Catches the #1 Riverpod setup bug at analysis time instead of at runtime.
- `avoid_ref_inside_state_dispose`, `avoid_public_notifier_properties`, `protected_notifier_properties`, `async_value_nullable_pattern`, `provider_parameters`.
- Generator-only ones (`provider_dependencies`, `scoped_providers_should_specify_dependencies`, `notifier_extends`, `functional_ref`, …) only fire if you use `riverpod_generator`.
- Assists: *Wrap with `Consumer`*, *Wrap with `ProviderScope`*, *Convert widget to `ConsumerWidget`/`ConsumerStatefulWidget`*.

### 4.4 `import_lint` — a real, working import-ban plugin

- **`import_lint` 2.0.0, published 2026-04-18.** Repo `kawa1214/import-lint`, not archived, only 33 stars — small, but it is current and it has migrated to the new `plugins:` system.
- Its README states: *"`import_lint` requires Dart 3.10 or later (analyzer plugin support was added in Dart 3.10 / Flutter 3.38)."* Inspired by `eslint/no-restricted-paths`.

**VERIFIED WORKING on Flutter 3.44.6:**

```yaml
plugins:
  import_lint: ^2.0.0

import_lint:
  rules:
    domain_must_not_import_ui:
      target: "package:myapp/domain/**.dart"
      from: "package:myapp/ui/**.dart"
      except: []
```
```
info - lib/domain/d.dart:1:1 - Found Import Lint Error: domain_must_not_import_ui
       Try removing the import. - import_lint
```

**⚠️ VERIFIED LIMITATION: it cannot ban `dart:` libraries.** `from: "dart:io"` crashes the plugin isolate with `package is required` at `import_lint/src/config/constraint.dart:26`, dumping a 28-frame stack trace into `dart analyze` output. **`import_lint` bans `package:` URIs only.**

**Verdict:** worth adding for *architecture layering* (domain must not import UI, UI must not import drift internals). It is **not** the answer to "prove no networking" — see §8.

---

## 5. `dart_code_metrics` — dead and commercial. Verified.

| Evidence | Value |
|---|---|
| pub latest | **5.7.6, published 2023-07-16** — 3 years stale |
| Its `environment.sdk` | **`>=2.18.0 <3.0.0`** — it *cannot run on Dart 3 at all*, let alone 3.12 |
| Its `analyzer` constraint | `>=5.1.0 <5.14.0` (current analyzer: 14.1.0) |
| `gh api repos/dart-code-checker/dart-code-metrics` | `{"archived": true, "pushed_at": "2023-07-16"}` |
| `homepage` / `documentation` in its own pubspec | **`https://dcm.dev/`** and `https://dcm.dev/docs/getting-started/` |

**What actually happened:** the OSS `dart_code_metrics` package and its GitHub repo were both frozen on 2023-07-16, and the project relaunched as the commercial **DCM** (dcm.dev), distributed as the `dcm` binary. The pub ecosystem still carries `dart_code_metrics_presets` (**2.32.0, 2026-06-17**, homepage `https://dcm.dev/`) — an actively-published *rule preset* package that is useless without the paid DCM binary.

**Plain answer for 2026: do not use `dart_code_metrics`. It is impossible to use — the SDK constraint excludes Dart 3.** If you want the cyclomatic-complexity / maintainability-index / unused-code analysis it used to provide for free, your options are (a) pay for DCM, or (b) write the two or three checks you actually care about as an `analysis_server_plugin`, or (c) accept that `unreachable_from_main` + `unnecessary_ignore` + code review covers 80% of it. I recommend (c) for a solo/small-team app.

---

## 6. The two genuine disagreements between credible sources

### 6.1 The `const` lints: `flutter_lints` says no, `flutter/flutter` says yes

**The facts.** `flutter_lints` 5.0.0 removed `prefer_const_constructors`, `prefer_const_declarations` and `prefer_const_literals_to_create_immutables`, keeping only `prefer_const_constructors_in_immutables`. The rationale is stated verbatim in [dart-lang/lints#205](https://github.com/dart-lang/lints/issues/205) by the Flutter team:

> *"In theory, const-ness should give apps a performance boost, but during development the lints enforcing const are constantly nagging developers … To evaluate whether we are making the right trade-offs here between annoyingness and performance we ran some benchmarks (see flutter/flutter#149932). **The benchmarks have not shown sufficient evidence to suggest that there is a statistically significant difference in performance between const and nonconst for real world apps.** … I suggest we keep the fourth const lint (`prefer_const_constructors_in_immutables`) because it is very narrow in scope and generally doesn't cause any pain."*

And [flutter/flutter#149932](https://github.com/flutter/flutter/issues/149932) is the benchmark issue itself: *"For now we will limit our investigations to app developers … We are not evaluating whether we should turn these lints off for the framework."*

Meanwhile `flutter/flutter` and `flutter/packages` still enable all four in their own repos, and `very_good_analysis` 10.3.0 enables all four.

**My recommendation: enable all three, and treat them as free.** Reasoning:
- The objection in #205 is explicitly about **developer annoyance during editing**, not about `const` being useless or harmful. The measured effect was "not statistically significant", not "zero".
- All three have `fixStatus: hasFix`. `dart fix --code=prefer_const_constructors --apply` bulk-fixes them in one command. If you wire `dart fix --apply` into your pre-commit or a CI fixup job, the annoyance the Flutter team measured **does not exist for you**.
- You have a **1.2 s cold-start budget on a low-end Android device**. `const` widget subtrees are canonicalised at compile time — no allocation, no GC pressure, and identical `const` instances short-circuit `Element.update`. That is small per-widget but you are optimising exactly the regime (weak CPU, cold JIT-free AOT start, many static chrome widgets) where small constants add up.
- The counter-argument does *not* apply to a 6-locale RTL app with a lot of static chrome; it applies to apps where most widgets are data-driven and can't be const anyway.

**Do not** treat them as blockers separate from the rest of the config — just run `dart fix --apply` before committing.

### 6.2 `always_use_package_imports` vs `prefer_relative_imports`

These are mutually exclusive. The ecosystem is genuinely split:

| Source | Choice |
|---|---|
| `flutter/flutter` | `prefer_relative_imports` (explicitly: *"# - always_use_package_imports # we do this commonly"*) |
| `flutter/samples` compass_app (official architecture sample) | `prefer_relative_imports` |
| `very_good_analysis` 10.3.0 | `always_use_package_imports` |

**My recommendation: `always_use_package_imports`.** Three concrete reasons for *this* app:
1. **`import_lint` rules and every grep-based guard are written against `package:` URIs.** Mixed import styles mean your architectural bans have a trivially-exploitable hole.
2. **The classic duplicate-library bug.** If `a.dart` is reached once as `package:app/a.dart` and once as `../a.dart`, older toolchains treated them as two libraries with two copies of every top-level `final`/static. Uniform `package:` imports make that impossible by construction.
3. You have **three packages** (app, pure-Dart domain, CLI content tool). Cross-package imports must be `package:` anyway; making intra-package imports match removes the "which style here?" decision entirely.

`flutter/flutter` chooses relative imports because the SDK is vendored and path-shifted — a constraint you do not have. compass_app is a teaching sample, not a considered policy.

I additionally promote `always_use_package_imports` to `error` (§7) so it is unambiguously non-negotiable.

### 6.3 `unawaited_futures` vs `discarded_futures`

- `flutter/flutter` disables **both**: *"# - unawaited_futures # too many false positives, especially with the way AnimationController works"* and *"# - discarded_futures # too many false positives, similar to unawaited_futures"*.
- `very_good_analysis` enables **both**.

**My recommendation: enable `unawaited_futures` and promote it to `error`; do NOT enable `discarded_futures`.**

- `unawaited_futures` fires only inside `async` bodies. In an offline app the dominant failure mode is a **silently dropped drift write** — the user taps save, an exception is swallowed into an unobserved `Future`, and the row never lands. Making that an error is worth the friction. Escape hatch: `unawaited(controller.forward())` from `dart:async`, which is explicit and greppable. Pair it with **`unnecessary_unawaited`** (new in Dart 3.9) so stale `unawaited()` calls get cleaned up.
- `discarded_futures` fires on Future-returning calls in *synchronous* functions. Flutter's callback types (`VoidCallback`, `GestureTapCallback`) are synchronous by signature, so every `onPressed: () { _save(); }` trips it. `flutter/flutter`'s reasoning applies squarely to any Flutter app. Skip it.

---

## 7. THE RECOMMENDED `analysis_options.yaml`

**VERIFIED: this exact file passes `dart analyze --fatal-infos` on Dart 3.12.2 with zero `undefined_lint`, zero `unrecognized_error_code`, zero `duplicate_rule` and zero incompatible-rule diagnostics — both standalone and merged with the complete `flutter_lints` 6.0.0 rule set.**

```yaml
# =============================================================================
# analysis_options.yaml — repository root
# Toolchain: Flutter 3.44.6 (stable) / Dart 3.12.2
# Verified: every rule name and diagnostic code below is accepted by Dart 3.12.2.
# Re-verify after every Flutter upgrade with:  dart analyze --fatal-infos
# =============================================================================

# flutter_lints 6.0.0 == lints/core (36) + lints/recommended (57) + 10 Flutter rules.
# NOTE: the file is flutter.yaml, NOT recommended.yaml.
# https://github.com/flutter/packages/blob/main/packages/flutter_lints/lib/flutter.yaml
include: package:flutter_lints/flutter.yaml

# -----------------------------------------------------------------------------
# Analyzer plugins. TOP-LEVEL section — NOT under `analyzer:`. Dart 3.10+ only.
# Cannot be specified in a nested analysis_options.yaml (root/workspace only).
# Restart the Dart Analysis Server after editing this block.
# https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server_plugin/doc/using_plugins.md
# -----------------------------------------------------------------------------
plugins:
  # EXACT PIN, not a caret range. riverpod_lint 3.1.6 (latest, 2026-07-26) fails
  # version solving on this SDK: riverpod_analyzer_utils 1.0.0-dev.10 pins
  # analyzer ^12 while riverpod_lint 3.1.6 needs ^13. 3.1.4 resolves cleanly.
  riverpod_lint: 3.1.4

  # Architectural import bans. Bans package: URIs only — it CANNOT ban `dart:`
  # libraries (crashes the plugin isolate). See the "no networking" section.
  import_lint: ^2.0.0

# Layering rules consumed by the import_lint plugin above.
import_lint:
  rules:
    # The rule engine is pure Dart. It must never reach into the UI layer.
    domain_must_not_import_ui:
      target: "package:myapp/**.dart"
      from: "package:myapp/ui/**.dart"
      except: []
    # Only the data layer may touch drift directly.
    ui_must_not_import_drift:
      target: "package:myapp/ui/**.dart"
      from: "package:drift/**.dart"
      except: []

analyzer:
  # ---------------------------------------------------------------------------
  # Type-system strictness. The three highest-value lines in this file: they
  # close type holes rather than express style opinions. strict-casts alone
  # eliminates the most common source of runtime TypeError (dynamic -> typed),
  # which is exactly the shape of bug you get from drift customSelect rows.
  # flutter/flutter omits strict-raw-types only because of legacy code; you are
  # greenfield and pay no migration cost.
  # ---------------------------------------------------------------------------
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

  errors:
    # --- Noise suppression -----------------------------------------------
    # Required because CI runs --fatal-infos; TODOs must not fail the build.
    todo: ignore
    # Needed if you annotate factory-constructor params (@JsonKey/@Default).
    # Delete this line if you never see the diagnostic.
    invalid_annotation_target: ignore

    # --- Analyzer diagnostics promoted to hard errors ---------------------
    # WHY: these are all "you wrote something with no effect". They accumulate
    # silently and each one is dead weight in an AOT snapshot you are trying to
    # keep small for a 1.2s cold start.
    unused_import: error
    unused_local_variable: error
    unused_element: error
    unused_field: error
    unnecessary_import: error
    dead_code: error
    # Silently-swallowed async errors: `.catchError((e) {})` on a Future<T>
    # where the callback falls off the end returning null.
    body_might_complete_normally_catch_error: error
    missing_required_param: error
    # @visibleForTesting / @protected leaking into production paths.
    invalid_use_of_visible_for_testing_member: error
    invalid_use_of_protected_member: error

    # --- Lints promoted to hard errors ------------------------------------
    # Severity is the only real enforcement knob: an `info` is advisory, an
    # `error` cannot be merged. Reserve `error` for things that are data-loss,
    # crash, or architecture violations.
    unawaited_futures: error            # a dropped drift write == silent data loss
    use_build_context_synchronously: error  # use-after-dispose crash across await
    avoid_dynamic_calls: error          # runtime NoSuchMethodError + blocks AOT devirtualisation
    cancel_subscriptions: error         # leaked StreamSubscription on a drift .watch()
    avoid_slow_async_io: error          # File.exists() async is slower than sync; cold-start path
    avoid_type_to_string: error         # Type.toString() is garbage under --obfuscate
    collection_methods_unrelated_type: error
    unrelated_type_equality_checks: error
    # --- Architecture, non-negotiable -------------------------------------
    avoid_web_libraries_in_flutter: error  # bans dart:html / dart:js == bans XHR/fetch
    depend_on_referenced_packages: error   # cannot import a transitive dep by accident
    always_use_package_imports: error
    avoid_relative_lib_imports: error

    # NOTE: deprecated_member_use is deliberately left at its default (warning).
    # flutter/flutter sets it to `ignore` because they must support N SDK
    # versions at once (flutter/flutter#143312). You pin exactly one Flutter
    # version, so a deprecation warning is actionable signal, not noise.

  exclude:
    - build/**
    - "**/generated_plugin_registrant.dart"
    # DELIBERATELY NOT excluding **/*.g.dart:
    #   1. drift already emits `// ignore_for_file: type=lint,unused_import`
    #      in its generated header, so there is no lint noise to suppress.
    #      https://github.com/simolus3/drift/blob/develop/drift_dev/lib/src/utils/header.dart
    #      freezed does the same.
    #   2. VERIFIED: `exclude` suppresses diagnostics *inside* those files but
    #      still resolves them. A genuine compile error in generated code
    #      (e.g. after a drift schema change) would be silently hidden and only
    #      surface at `flutter build` time.
    # Add "**/*.mocks.dart" here ONLY if you use mockito — its output does not
    # self-suppress. (flutter/packages excludes *.g.dart / *.pb.dart / *.mocks.dart
    # because they use protoc and mockito, not drift.)

formatter:
  # flutter/flutter and flutter/packages both use 100.
  page_width: 100
  # trailing_commas left at the default `automate`. The Dart 3.7+ tall-style
  # formatter decides splitting itself; `preserve` + require_trailing_commas
  # re-imposes the pre-3.7 manual-comma tax and churns diffs on every refactor.
  # Force a region open with `// dart format off` / `// dart format on`.

linter:
  rules:
    # =========================================================================
    # A. CORRECTNESS — bugs the type system cannot catch. Highest value.
    # =========================================================================
    - avoid_dynamic_calls          # dynamic dispatch: runtime NoSuchMethodError, and it
                                   # defeats AOT devirtualisation (category: binarySize)
    - cast_nullable_to_non_nullable # `x as Foo` where x is Foo? -> hidden TypeError
    - unawaited_futures            # see the unawaited/discarded discussion
    - unnecessary_unawaited        # (Dart 3.9) removes stale unawaited() calls
    - unnecessary_statements       # `a.b;` / `x == y;` — expressions with no effect
    - literal_only_boolean_expressions  # `if (true && false)` — always dead branches
    - no_self_assignments          # `this.x = x;` typo'd as `x = x;`
    - test_types_in_equals         # operator== that forgets to check `other is T`
    - throw_in_finally             # a throw in finally swallows the original exception
    - only_throw_errors            # `throw 'string'` loses the stack trace
    - avoid_type_to_string         # runtimeType/Type.toString() is meaningless under
                                   # --obfuscate, which you will use for release builds
    - no_runtimeType_toString      # same, plus it is genuinely slow (category: nonPerformant)
    - switch_on_type               # (Dart 3.9) `switch (x.runtimeType)` never matches
                                   # subtypes — a real trap with sealed-class rule nodes
    - matching_super_parameters    # super.foo bound to the wrong positional slot
    - conditional_uri_does_not_exist  # a typo'd conditional-import URI silently
                                   # falls through to the default branch
    - missing_whitespace_between_adjacent_strings  # 'Hello''world' — bites in i18n strings
    - no_adjacent_strings_in_list  # a missing comma in a list literal silently concatenates
    - deprecated_consistency       # @Deprecated on a class but not its constructors
    - avoid_slow_async_io          # cold-start path: async File.exists/stat are slower
    - cancel_subscriptions         # leaked StreamSubscription (drift .watch(), sensors)
    - avoid_void_async             # `void` async swallows errors; use Future<void>
    - unnecessary_await_in_return
    - unnecessary_null_aware_operator_on_extension_on_nullable
    - tighten_type_of_initializing_formals
    - avoid_unused_constructor_parameters
    - avoid_equals_and_hash_code_on_mutable_classes  # mutating a key breaks Map/Set
    - avoid_field_initializers_in_const_classes      # silently defeats const-ness
    - prefer_asserts_in_initializer_lists            # asserts that run before field init
    - prefer_void_to_null                            # `Null` as a return type is a trap
    # Experimental but enabled by flutter/flutter in its own repo:
    - annotate_redeclares
    - implicit_reopen
    - invalid_case_patterns        # Dart 3 pattern-syntax migration guard
    - unnecessary_null_checks
    - use_late_for_private_fields_and_variables  # caveat: `late` converts a null into
                                   # a LateInitializationError; that is usually what
                                   # you want, but it IS a behaviour change

    # =========================================================================
    # B. TYPING — the pure-Dart domain package is a published-ish API surface.
    # WHY: the rule engine is consumed by BOTH the app and the CLI content tool.
    # Inferred/implicit types there become silent breaking changes.
    # =========================================================================
    - always_declare_return_types
    - type_annotate_public_apis
    - avoid_positional_boolean_parameters   # `evaluate(true, false)` is unreadable
    # The modern Effective Dart trio (Dart 3.6/3.7). This is what flutter/flutter
    # uses now. It supersedes the old always_specify_types vs omit_local_variable_types
    # fight: annotate where the type is NOT obvious, omit where it is.
    - omit_obvious_local_variable_types
    - specify_nonobvious_local_variable_types
    - specify_nonobvious_property_types

    # =========================================================================
    # C. IMPORTS & ARCHITECTURE
    # =========================================================================
    - always_use_package_imports   # see the package-vs-relative discussion.
                                   # Incompatible with prefer_relative_imports.
    - directives_ordering
    - combinators_ordering
    - simple_directive_paths       # NEW in Dart 3.12 — flags './' and '../' noise.
                                   # NOTE: absent from rules.json at the 3.12.2 tag
                                   # but VERIFIED accepted by dart analyze 3.12.2.
    - unnecessary_library_directive

    # =========================================================================
    # D. IGNORE HYGIENE — the failure mode of every strict lint config is
    # `// ignore:` rot. These two rules are the antidote and are the most
    # under-rated pair in the whole index.
    # =========================================================================
    - document_ignores             # (3.5) every // ignore: needs a reason comment
    - unnecessary_ignore           # (3.8) flags // ignore: for diagnostics that no
                                   # longer fire — otherwise they outlive the bug
    - flutter_style_todos          # forces // TODO(user): msg, https://issue-url

    # =========================================================================
    # E. FLUTTER / RENDERING / COLD START
    # =========================================================================
    - use_colored_box              # ColoredBox < Container: one less RenderObject
    - sized_box_shrink_expand      # SizedBox.shrink()/expand() are const-able
    - use_enums                    # enhanced enums replace hand-rolled sentinel classes
    - use_named_constants          # reuses the canonicalised const instance
    # const lints — removed from flutter_lints 5.0.0 (dart-lang/lints#205) because
    # of DEVELOPER ANNOYANCE, not because const is useless. All three are
    # `dart fix`-able in bulk, so the annoyance cost is ~0 if you run
    # `dart fix --apply`. Kept on for the low-end-Android cold-start budget.
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables

    # =========================================================================
    # F. STYLE — cheap, auto-fixable, and they stop code-review bikeshedding.
    # =========================================================================
    - prefer_single_quotes
    - prefer_final_locals
    - prefer_final_in_for_each
    - avoid_final_parameters       # (prefer_final_parameters is DEPRECATED in 3.11)
    - sort_constructors_first
    - sort_unnamed_constructors_first
    - eol_at_end_of_file
    - unnecessary_parenthesis
    - unnecessary_breaks           # Dart 3 switch: `break` at the end of a case is dead
    - unnecessary_lambdas
    - prefer_if_elements_to_conditional_expressions
    - noop_primitive_operations
    - avoid_escaping_inner_quotes
    - avoid_redundant_argument_values
    - avoid_bool_literals_in_conditional_expressions
    - no_literal_bool_comparisons
    - avoid_setters_without_getters
    - leading_newlines_in_multiline_strings
    - missing_code_block_language_in_doc_comment
    - use_is_even_rather_than_modulo
    - use_truncating_division
    - use_setters_to_change_properties
    - use_test_throws_matchers
```

### 7.1 Nested override for the pure-Dart domain package

Put this at `packages/rule_engine/analysis_options.yaml`. **The `include:` line is mandatory** — VERIFIED, a nested file without it discards the entire parent config for that subtree (§3.5). Note that `plugins:` cannot appear here.

```yaml
# packages/rule_engine/analysis_options.yaml
# The `include` is NOT optional: a nested analysis_options.yaml REPLACES the
# parent for its subtree. Without this line the package silently loses every
# rule configured at the root.
include: ../../analysis_options.yaml

linter:
  rules:
    # This package is a real API consumed by two clients (the app and the CLI
    # content build tool). Undocumented public members are a maintenance debt
    # here in a way they are not inside the app.
    - public_member_api_docs
    # It must never depend on Flutter. This is belt-and-braces: the primary
    # guarantee is that its pubspec.yaml has no `flutter:` dependency, which
    # makes `import 'package:flutter/...'` an unresolved-URI COMPILE ERROR.
    - avoid_print          # this package has no business printing
```

**The single most important line for "no Flutter imports in the domain package" is not a lint at all — it is the absence of `flutter:` from `packages/rule_engine/pubspec.yaml`.** With `depend_on_referenced_packages` promoted to `error` (root config), any Flutter import in that package is both an unresolved URI *and* a lint error. That is a compiler-level guarantee; no lint can beat it.

### 7.2 Relaxations for `test/`

Do **not** create `test/analysis_options.yaml` (you'd lose everything and have to re-include). Instead put the handful of test-specific relaxations at the top of the test files that need them, e.g. `// ignore_for_file: avoid_dynamic_calls` — and because `document_ignores` is on, you'll be forced to write down why.

---

## 8. Proving "no networking" — what actually works

**There is no Dart lint rule that bans an arbitrary import.** `depend_on_referenced_packages` bans importing packages you didn't declare; it does not ban declared ones. `avoid_web_libraries_in_flutter` bans `dart:html`/`dart:js`/`dart:js_util`/`dart:js_interop` — genuinely useful here because that is where `XMLHttpRequest`/`fetch` live, but it says nothing about `dart:io`. There is **no `package:banned_imports` on pub.dev** (searched; no such package).

Use these four layers, in order of strength:

### Layer 1 (strongest, non-bypassable): don't declare the dependency

If `http`, `dio`, `web_socket_channel`, `grpc` etc. are not in `pubspec.yaml`, `import 'package:http/http.dart'` is an **unresolved-URI compile error**. Combined with `depend_on_referenced_packages: error` (promoted in §7), you also cannot reach a networking package that arrives transitively. This is a compiler guarantee, not a lint.

Audit it in CI: `dart pub deps --style=compact` and assert none of the known networking packages appear anywhere in the tree.

### Layer 2 (strongest OS-level proof): omit the platform permission

**Android: do not declare `<uses-permission android:name="android.permission.INTERNET"/>` in `AndroidManifest.xml`.** Without it the OS refuses every socket operation, regardless of what your Dart code contains. This is the only mechanism that produces a claim a security reviewer can verify without reading your source, and it is the one thing on this list that is *provable to a third party*. Note that `flutter run`/debug builds inject INTERNET via `android/app/src/debug/AndroidManifest.xml` for the Dart VM service — make sure the **main** and **release** manifests do not.

On iOS there is no equivalent opt-out permission; rely on layers 1, 3 and 4.

### Layer 3: `import_lint` for package-URI bans (§4.4)

Works, VERIFIED, but cannot express `dart:io` bans.

### Layer 4: a guard test. VERIFIED WORKING.

This is the layer that covers `dart:io`'s networking half, which you cannot ban wholesale because you need `File`, `Directory` and `Platform` for the drift databases, the shipped asset DB and the PDF export.

**Precedent:** the Flutter team does exactly this rather than using lints. `flutter/flutter`'s `dev/bots/analyze.dart` contains `verifyNoBadImportsInFlutter()` and `verifyNoBadImportsInFlutterTools()` — hand-written source scanners run in CI. They also keep hand-written AST rules in `dev/bots/custom_rules/` (`no_stop_watches.dart`, `avoid_future_catcherror.dart`, `no_double_clamp.dart`, …) built on `package:analyzer`'s `ResolvedUnitResult`. If banning things by convention were achievable with lints alone, the Flutter team would not maintain that directory.

```dart
// test/no_network_test.dart — VERIFIED: this test runs and correctly flags
// `HttpClient` in lib/ while ignoring legitimate `Platform.isAndroid` usage.
import 'dart:io';
import 'package:test/test.dart';

/// Identifiers that can only come from the networking half of `dart:io`.
/// (`dart:html` / `dart:js*` are already banned by `avoid_web_libraries_in_flutter`,
/// which this config promotes to `error`.)
const bannedIdentifiers = <String>[
  'HttpClient', 'HttpServer', 'HttpRequest', 'WebSocket',
  'Socket', 'RawSocket', 'SecureSocket', 'ServerSocket', 'RawServerSocket',
  'RawDatagramSocket', 'InternetAddress', 'NetworkInterface',
];

const bannedImports = <String>[
  'dart:html', 'dart:js', 'dart:js_interop', 'dart:js_util',
  'package:http/', 'package:dio/', 'package:web_socket_channel/',
];

void main() {
  test('no networking API is referenced anywhere under lib/', () {
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        for (final id in bannedIdentifiers) {
          if (RegExp('\\b$id\\b').hasMatch(line)) {
            offenders.add('${entity.path}:${i + 1}: $id');
          }
        }
        for (final imp in bannedImports) {
          if (line.contains("'$imp") || line.contains('"$imp')) {
            offenders.add('${entity.path}:${i + 1}: $imp');
          }
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'Networking is forbidden:\n${offenders.join('\n')}');
  });
}
```

Actual output when `lib/bad.dart` contains `HttpClient()`:
```
Expected: empty
  Actual: ['lib/bad.dart:3: HttpClient']
Networking is forbidden:
lib/bad.dart:3: HttpClient
```

**If you want this to be exact rather than textual, promote it to an `analysis_server_plugin`** (official, first-party, `analysis_server_plugin: ^0.3.20`) that walks resolved ASTs and reports on `ImportDirective` / `NamedType` elements whose `library.uri` is `dart:io` and whose name is in the banned set. Model it on `flutter/flutter/dev/bots/custom_rules/no_stop_watches.dart`. That is roughly 80 lines and it becomes an IDE squiggle instead of a test failure. Worth it if this constraint is a product/marketing claim rather than a personal preference.

**A note on `deprecated_member_use`:** it is *not* a mechanism for banning imports. It only fires for members annotated `@Deprecated` upstream. You cannot use it to ban third-party APIs.

---

## 9. Anti-patterns — what NOT to do

### 9.1 Silent no-op options that thousands of projects still carry

**VERIFIED: the following produces `No issues found!` on Dart 3.12.2 — no warning, no effect, nothing.**

```yaml
# ❌ ALL OF THIS IS DEAD. It does NOTHING on Dart 3.
analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
```

The `strong-mode` keys were superseded by `language: strict-casts:` / `strict-inference:` / `strict-raw-types:` and removed in Dart 3.0. **The analyzer does not warn about them** — unlike `analyzer: errors:`, where a bogus key *does* produce `unrecognized_error_code`. So a project can carry `implicit-casts: false` for years while implicit dynamic casts sail straight through. If you inherit a codebase, this is the first line to grep for.

Related: `implicit_dynamic` under `analyzer: errors:` **is** flagged (`'implicit_dynamic' isn't a recognized diagnostic code`) — verified.

### 9.2 Obsolete plugin wiring

```yaml
# ❌ legacy plugin system + a package that no longer resolves
analyzer:
  plugins:
    - custom_lint
```
Replace with the top-level `plugins:` section (§4.1). And drop `custom_lint` / `custom_lint_builder` from `dev_dependencies` entirely — it pins analyzer 8.4.0 and cannot coexist with current riverpod_lint (§4.2).

### 9.3 Rules commonly enabled that are actively counterproductive

| Rule | Why NOT | Source |
|---|---|---|
| **`unreachable_from_main`** | **VERIFIED still broken on 3.12.2.** Reports every user-defined operator (`<`, `+`, `~/`, …) as unreachable even when used. Your rule engine and ruler-painting code will define operators on value types. VGA removed it in 10.3.0 for this reason. | [dart-lang/sdk#61891](https://github.com/dart-lang/sdk/issues/61891); [VGV#197](https://github.com/VeryGoodOpenSource/very_good_analysis/issues/197) |
| **`always_specify_types`** | Incompatible with **four** other rules and with modern Effective Dart. Superseded by `omit_obvious_*` + `specify_nonobvious_*` (Dart 3.6/3.7). `flutter/flutter`: *"# - always_specify_types # conflicts with omit_obvious_local_variable_types"* | rules.json `incompatible` |
| **`prefer_final_parameters`** | **DEPRECATED in Dart 3.11.** Use `avoid_final_parameters` instead. | Dart SDK CHANGELOG 3.11.0 |
| **`avoid_null_checks_in_equality_operators`** | **DEPRECATED**; removed from `lints` 5.0.0. | lints CHANGELOG 5.0.0 |
| **`use_if_null_to_convert_nulls_to_bools`** | **DEPRECATED in Dart 3.11.** | Dart SDK CHANGELOG 3.11.0 |
| **`one_member_abstracts`**, **`avoid_private_typedef_functions`** | **Deprecated in the Dart 3.13 dev cycle.** VGA 10.3.0 still ships both. Don't add them to new configs. | Dart SDK CHANGELOG 3.13.0 |
| **`use_decorated_box`** | `DecoratedBox` and `Container` are **not** equivalent — Container inserts extra padding. The lint's suggested fix changes rendering. `flutter/flutter`: *"# - use_decorated_box # leads to bugs"* | flutter/flutter analysis_options.yaml |
| **`use_string_buffers`** | Known false positives. `flutter/flutter`: *"has false positives: dart-lang/sdk#34182"*. VGA enables it anyway. | [dart-lang/sdk#34182](https://github.com/dart-lang/sdk/issues/34182) |
| **`lines_longer_than_80_chars`** | The formatter already enforces `page_width`. This lint additionally counts *comment* lines and long URLs, which the formatter cannot wrap. Pure noise. `flutter/flutter`: *"not required by flutter style"*. | flutter/flutter analysis_options.yaml |
| **`require_trailing_commas`** | Fights the Dart 3.7+ tall-style formatter. Requires `trailing_commas: preserve` and reintroduces manual comma maintenance. `flutter/flutter`: *"10,000+ code locations would need to be reformatted by hand"*. | flutter/flutter analysis_options.yaml |
| **`public_member_api_docs`** on an app | You will write `/// The home page.` above `class HomePage`. Zero information, real cost. Scope it to the domain package only (§7.1). `flutter/flutter`: *"enabled on a case-by-case basis"*. | flutter/flutter analysis_options.yaml |
| **`discarded_futures`** | Flutter's `VoidCallback`-shaped callbacks are synchronous by signature, so every `onPressed: () { save(); }` fires it. See §6.3. | flutter/flutter analysis_options.yaml |
| **`cascade_invocations`** | Rewrites readable sequential statements into `..` chains that are harder to debug (you cannot set a breakpoint on one link). `flutter/flutter`: *"doesn't match the typical style of this repo"*. | flutter/flutter analysis_options.yaml |
| **`sort_pub_dependencies`** | Prevents grouping and commenting pinned transitive dependencies — which you *will* need (see riverpod_lint 3.1.4). `flutter/flutter`: *"prevents separating pinned transitive dependencies"*. | flutter/flutter analysis_options.yaml |
| **`avoid_catches_without_on_clauses`** | Blocked on an unresolved linter issue and structurally wrong for an offline app, where a broad catch at the drift / PDF / camera / GPS boundary is the correct design. `flutter/flutter`: *"blocked on dart-lang/linter#3023"*. | flutter/flutter analysis_options.yaml |
| **`avoid_catching_errors`** | *"blocked on dart-lang/linter#4998"*. | flutter/flutter analysis_options.yaml |
| **`prefer_relative_imports`** | See §6.2 — breaks import-ban tooling in a multi-package repo. | rules.json `incompatible` |
| **`parameter_assignments`**, **`prefer_int_literals`**, **`always_put_required_named_parameters_first`**, **`prefer_expression_function_bodies`**, **`avoid_returning_this`**, **`prefer_constructors_over_static_methods`**, **`unnecessary_lambdas`*** | Each explicitly rejected by `flutter/flutter` with a stated reason (false positives / style disagreement). VGA enables most of them. `prefer_expression_function_bodies` was removed by VGA itself in 10.1.0-rc.2. | flutter/flutter analysis_options.yaml |
| **`prefer_foreach`** | Rewrites `for (final x in xs) f(x)` into `xs.forEach(f)` — which allocates a closure per call and is slower. Directly counter to a cold-start budget. | rules.json category analysis |
| **`always_put_control_body_on_new_line`** | Redundant once `curly_braces_in_flow_control_structures` (already in `lints/core`) is on, because the formatter then always breaks the line anyway. | lints/core.yaml |
| **`close_sinks`** | `flutter/flutter`: *"not reliable enough"*. VGA explicitly sets `close_sinks: ignore` in its `errors:` block. Both authorities say no. | flutter/flutter + VGA analysis_options |

\* `unnecessary_lambdas` is in my recommended set despite flutter/flutter's objection (*"has false positives: linter#498"*); it is `hasFix` and the false positives are rare in app code. If it annoys you, drop it — it is the lowest-value rule on the list.

### 9.4 Process anti-patterns

- **Copying `flutter/flutter`'s `analysis_options.yaml` from `master`.** It targets the Dart dev SDK. On stable 3.44.6 it contributes `no_raw_types` → `undefined_lint` → **CI failure**, because `dart analyze` has `--fatal-warnings` on by default. VERIFIED.
- **Trusting `rules.json` at a release tag.** It omitted `simple_directive_paths` at the `3.12.2` tag. VERIFIED. `dart analyze` is the ground truth.
- **Adding a caret range for an analyzer plugin.** `riverpod_lint: ^3.1.4` resolves to 3.1.6, which is broken on this SDK. Pin exactly. VERIFIED.
- **Excluding `**/*.g.dart` "to reduce noise".** You hide real compile errors in generated code and gain nothing, because drift and freezed already emit `// ignore_for_file: type=lint`. VERIFIED.
- **Writing a nested `analysis_options.yaml` without `include:`.** Silently discards the entire parent config. VERIFIED.
- **Turning everything on at once on an existing codebase.** Add rules in batches, run `dart fix --code=<rule> --apply` per rule (68 of the 125 non-default stable rules have `fixStatus: hasFix`), commit each batch separately.

---

## 10. CI wiring

### 10.1 The commands

```bash
# Formatting — must be first; a format-only diff should never reach review.
dart format --output=none --set-exit-if-changed .

# Analysis. --fatal-infos is what makes lints actually enforced: lint rules
# default to `info` severity, and WITHOUT this flag every lint in your config
# is advisory. This is the single most commonly missed line in Flutter CI.
flutter analyze --fatal-infos --fatal-warnings

# Assert the config itself is clean: `undefined_lint` / `unrecognized_error_code`
# / `duplicate_rule` are reported as warnings against analysis_options.yaml, so
# the command above already catches a stale config. Verify after every upgrade.

# Prove no networking (see §8)
dart test test/no_network_test.dart
dart pub deps --style=compact   # inspect for http/dio/grpc/web_socket_channel
```

**`--fatal-warnings` defaults to ON for `dart analyze`** (`--[no-]fatal-warnings ... (defaults to on)`). `--fatal-infos` defaults to OFF. Both flags exist on `flutter analyze` too — verified against the local toolchain.

### 10.2 Bulk fixing

```bash
dart fix --dry-run                              # preview everything
dart fix --apply                                # apply everything
dart fix --code=prefer_const_constructors --apply   # one rule at a time (preferred)
```
Per-rule application is how you adopt a strict config on an existing codebase without a 4000-line diff. `--code` accepts a comma-separated list.

### 10.3 Ordering matters
Run `dart format` **before** `dart analyze`. Several rules (`eol_at_end_of_file`, `unnecessary_parenthesis`, the const lints' fix output) interact with formatting; fixing then formatting produces a stable fixpoint, the reverse does not.

### 10.4 Verify the config on every Flutter upgrade

```bash
# From an empty scratch package containing only your analysis_options.yaml:
dart analyze --fatal-infos .
# Expect: "No issues found!"
# Any output here is a rule name, diagnostic code, or plugin version that your
# new SDK no longer accepts.
```

This is exactly how every claim in this document was validated. It takes two seconds and it is the only reliable way to keep an aggressive config from silently rotting across Flutter releases.

---

## 11. Package status summary (all figures from the pub.dev API on 2026-07-27)

| Package | Latest | Published | Status | Use it? |
|---|---|---|---|---|
| `lints` | 6.1.0 | 2026-01-30 | Official; repo moved to `dart-lang/core` (old repo archived) | Transitively, via flutter_lints |
| `flutter_lints` | 6.0.0 | 2025-05-27 | Official; 14 months old but current; `NEXT` in-repo bumps to Flutter 3.38 | **Yes — as the base** |
| `very_good_analysis` | 10.3.0 | 2026-06-18 | **Actively maintained**, tracks Dart 3.12, versioned files per release | Good alternative; needs ~12 rules disabled |
| `analysis_server_plugin` | 0.3.20 | 2026-07-13 | **Official** (`dart-lang/sdk/pkg/`); the sanctioned custom-lint path | Yes, if you write custom rules |
| `riverpod_lint` | 3.1.6 | 2026-07-26 | Very active; migrated off custom_lint. **3.1.6 does not resolve on Dart 3.12.2** | **Yes — pinned to `3.1.4`** |
| `import_lint` | 2.0.0 | 2026-04-18 | Small (33★) but current; new `plugins:` system; cannot ban `dart:` URIs | Optional — for layering |
| `build_runner` | 2.15.3 | 2026-07-27 | Extremely active (released today) | Yes (drift codegen) |
| `custom_lint` | 0.8.1 | 2025-09-09 | **ABANDONED** — repo archived, README warns, pins analyzer 8.4.0 | **No** |
| `dart_code_metrics` | 5.7.6 | 2023-07-16 | **DEAD + COMMERCIAL** — repo archived, `sdk: <3.0.0`, moved to dcm.dev | **No — it cannot run on Dart 3** |
| `dart_code_metrics_presets` | 2.32.0 | 2026-06-17 | Published presets for the paid DCM binary | Only if you buy DCM |

---

## 12. Complete source list

**Official docs**
- https://dart.dev/tools/analysis
- https://dart.dev/tools/linter-rules
- https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server_plugin/doc/using_plugins.md
- https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server_plugin/doc/writing_a_plugin.md
- https://github.com/dart-lang/sdk/blob/main/CHANGELOG.md (3.10.0 / 3.11.0 / 3.12.0 / 3.13.0 sections)
- `https://raw.githubusercontent.com/dart-lang/sdk/3.12.2/pkg/linter/tool/machine/rules.json`

**Official rule sets**
- https://github.com/dart-lang/core/blob/main/pkgs/lints/lib/core.yaml
- https://github.com/dart-lang/core/blob/main/pkgs/lints/lib/recommended.yaml
- https://github.com/dart-lang/core/blob/main/pkgs/lints/CHANGELOG.md
- https://github.com/flutter/packages/blob/main/packages/flutter_lints/lib/flutter.yaml
- https://github.com/flutter/packages/blob/main/packages/flutter_lints/CHANGELOG.md

**Real configs read in full**
- https://github.com/flutter/flutter/blob/master/analysis_options.yaml
- https://github.com/flutter/packages/blob/main/analysis_options.yaml
- https://github.com/flutter/samples/blob/main/compass_app/app/analysis_options.yaml
- https://github.com/VeryGoodOpenSource/very_good_analysis/blob/main/lib/analysis_options.10.3.0.yaml
- `flutter_tools/templates/app/analysis_options.yaml.tmpl` (local SDK, `flutter create` output)

**Decision records / issues**
- https://github.com/dart-lang/lints/issues/205 — why the const lints left flutter_lints
- https://github.com/flutter/flutter/issues/149932 — the const benchmark
- https://github.com/VeryGoodOpenSource/very_good_analysis/issues/197 — why VGA dropped `unreachable_from_main`
- https://github.com/dart-lang/sdk/issues/61891 — `unreachable_from_main` operator false positive
- https://github.com/invertase/dart_custom_lint/issues/379 — custom_lint end-of-life
- https://github.com/dart-lang/sdk/issues/34182 — `use_string_buffers` false positives

**Enforcement precedent**
- https://github.com/flutter/flutter/blob/master/dev/bots/analyze.dart (`verifyNoBadImportsInFlutter`)
- https://github.com/flutter/flutter/tree/master/dev/bots/custom_rules
- https://github.com/simolus3/drift/blob/develop/drift_dev/lib/src/utils/header.dart
- https://github.com/kawa1214/import-lint
- https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod_lint/README.md
