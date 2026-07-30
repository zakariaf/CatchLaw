# Effective Dart — naming, style, docs, usage, design

**Lane:** "how to name things" (+ the style/usage/design rules that actually change how code reads)
**Researched:** 2026-07-27
**Toolchain this was verified against:** Flutter 3.44.6 stable (2026-07-08), **Dart 3.12.2 stable** (2026-06-09), DevTools 2.57.0 — confirmed by running `flutter --version` / `dart --version` on this machine.
**Target app:** 100% offline Flutter app, two drift SQLite DBs, flutter_riverpod, 6 locales incl. Arabic RTL, plus a pure-Dart domain package shared with a CLI content-build tool.

## Primary sources used (all fetched and read in full)

| Source | What it is | Last touched |
|---|---|---|
| https://dart.dev/effective-dart/style | Official style guide | source `style.md` last changed 2026-05-12 |
| https://dart.dev/effective-dart/documentation | Official documentation guide | source `documentation.md` |
| https://dart.dev/effective-dart/usage | Official usage guide | source `usage.md` |
| https://dart.dev/effective-dart/design | Official design guide | source `design.md` last changed **2026-06-04** |
| https://dart.dev/effective-dart | Overview + severity-level definitions + glossary | — |
| https://github.com/dart-lang/site-www/tree/main/src/content/effective-dart | The markdown *source* of the four pages above (I read these, not a rendered scrape) | — |
| https://dart.dev/tools/dart-format | `dart format` config: `page_width`, `trailing_commas` | source last changed 2026-02-05 |
| https://github.com/dart-lang/lints/blob/main/lib/core.yaml + `recommended.yaml` | What `package:lints` actually turns on | `lints` 6.1.0, published 2026-01-30 |
| https://github.com/flutter/packages/blob/main/packages/flutter_lints/lib/flutter.yaml | What `flutter_lints` adds on top | `flutter_lints` 6.0.0, published **2025-05-27** (over a year old — see §12) |
| https://github.com/flutter/flutter/blob/master/analysis_options.yaml | The Flutter team's own, opinionated lint set (277 lines) | live master |
| https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md | Flutter repo style guide — the credible dissenting voice | live master |
| https://github.com/dart-lang/sdk/blob/main/CHANGELOG.md | Dart 3.13 / 3.14 status | live main |
| https://github.com/dart-lang/dart_style/blob/main/CHANGELOG.md | The "tall style" formatter switch | live main |

Everything below is either a quote/paraphrase of one of those, an empirically verified result from running the local toolchain, or explicitly labelled **[opinion]**.

---

## 0. How to read Effective Dart's severity words

You will see these five words on every rule. They are not decoration — they define how much room you have.
Source: https://dart.dev/effective-dart#how-to-read-the-guides

| Word | Meaning (verbatim intent) | Practical policy for this project |
|---|---|---|
| **DO** | "practices that should always be followed. There will almost never be a valid reason to stray" | Enforce with a lint if one exists. No exceptions without a code comment. |
| **DON'T** | "things that are almost never a good idea" | Same. |
| **PREFER** | "practices that you *should* follow… may be circumstances where it makes sense to do otherwise" | Default yes; deviation needs a one-line reason in review. |
| **AVOID** | "the dual to prefer: stuff you shouldn't do but where there may be good reasons to on rare occasions" | Default no. |
| **CONSIDER** | "practices that you might or might not want to follow, depending on circumstances" | Team decides once, then applies consistently. |

Also worth internalising the **glossary** (same page), because the rules use these words precisely:
- **library member** = top-level field/getter/setter/function.
- **class member** = constructor, field, getter, setter, function, operator inside a class.
- **variable** = top-level variables, parameters, locals. **Not** static or instance fields.
- **property** = top-level variable, getter, setter, or field. "Roughly any field-like named construct."

The two overarching themes on the same page: **Be consistent** and **Be brief** — *"If there are multiple ways to say something, you should generally pick the most concise one… The goal is code that is economical, not dense."*

---

## 1. The one-page checklist

Print this. Everything after §1 is the justification.

**Identifiers**
- [ ] Types, enums, typedefs, type parameters, **extensions**: `UpperCamelCase`
- [ ] Everything else (members, top-level defs, variables, parameters, named parameters, **constants**, **enum values**): `lowerCamelCase`
- [ ] Packages, directories, source files, **import prefixes**: `lowercase_with_underscores`
- [ ] Acronyms >2 letters: like a word (`HttpRequest`, `Uri`, `Nasa`, `PdfExporter`). Exactly 2 letters: keep both caps *if English caps them* (`ID`, `TV`, `UI`), else word-case (`Mr`, `St`, `Rd`)
- [ ] Abbreviation at the start of a `lowerCamelCase` name → all lowercase (`httpConnection`, `uiState`, `pdfBytes`)
- [ ] No `k` prefixes, no Hungarian notation, no leading `_` on locals/params/prefixes
- [ ] Unused callback params: `_` (Dart ≥3.7 wildcards — multiple `_` allowed)
- [ ] No `library my_name;` — bare `library;` only, and only to hang a doc comment on

**Imports**
- [ ] `dart:` block, blank line, `package:` block, blank line, relative block. Each block sorted alphabetically. `export`s in their own section after all imports
- [ ] Never `../lib/…`, never `/lib/` in a path. Crossing into `lib` (e.g. from `test/`) → `package:`
- [ ] Inside `lib/`, prefer relative

**Functions and methods** (the section people get wrong)
- [ ] Side effect is the point → **imperative verb phrase**: `save()`, `refresh()`, `removeFirst()`
- [ ] Returning a value is the point → **noun phrase / non-imperative verb**: `elementAt()`, `firstWhere()`, `codeUnitAt()`
- [ ] Never start with `get`. `getUserProfile()` → getter `userProfile`, or method `loadUserProfile()`/`fetchUserProfile()`
- [ ] Copies state into a new object → `to___()`. Returns a live view backed by the original → `as___()`
- [ ] Don't name the parameter in the method: `list.add(e)` not `list.addElement(e)`
- [ ] Boolean property → non-imperative verb phrase: `isEmpty`, `hasData`, `canClose`, `shouldConfirm`. Positive form, never the negation
- [ ] Boolean *named parameter* → you may drop the verb: `growable: true`, `caseSensitive: false`

**Docs**
- [ ] `///` never `/** */`. Doc comment goes **above** any annotation
- [ ] First line is a one-sentence summary ending in `.`, then a **blank `///` line**, then everything else
- [ ] Function with side effects → third-person verb ("Deletes…", "Starts…"). Non-boolean property → noun phrase ("The number of…"). Boolean → "Whether …"
- [ ] `[squareBrackets]` for identifiers, `[Class.member]`, `[Point.new]` for unnamed constructors
- [ ] Document the getter **or** the setter, never both
- [ ] No `@param` / `@returns` / `@throws` — use prose

**Types**
- [ ] Annotate: return types on non-local functions, all parameters, uninitialised variables, fields/top-level vars whose type isn't obvious
- [ ] Don't annotate: initialised locals, closure parameters, initializing formals (`this.x`, `super.key`), inferred type arguments
- [ ] Never leave a generic raw (`List numbers` → `List<num> numbers`). Write `dynamic` on purpose or not at all

---

## 2. Identifier casing — with before/after

### 2.1 DO name types using `UpperCamelCase`
Lint: `camel_case_types` (in `package:lints/core.yaml`, so already on).
**Covers:** classes, enum types, typedefs, **type parameters**, and annotation classes.
**Why:** consistent visual signal for "this is a type"; the eye pattern-matches it faster than reading it.

```dart
// GOOD  (dart.dev/effective-dart/style)
class SliderMenu { ... }
class HttpRequest { ... }
typedef Predicate<T> = bool Function(T value);
```

Annotation classes are still `UpperCamelCase`. If the annotation's constructor takes no parameters, make a `lowerCamelCase` **const** for it:

```dart
// GOOD
class Foo { const Foo([Object? arg]); }
const foo = Foo();

@foo
class C { ... }
```
Source: https://dart.dev/effective-dart/style#do-name-types-using-uppercamelcase

### 2.2 DO name extensions using `UpperCamelCase`
Lint: `camel_case_extensions` (already on).
```dart
// GOOD
extension MyFancyList<T> on List<T> { ... }
extension SmartIterable<T> on Iterable<T> { ... }
```
For this app that means `extension RulerTickGeometry on double`, not `extension rulerTickGeometry`.
Source: https://dart.dev/effective-dart/style#do-name-extensions-using-uppercamelcase

### 2.3 DO name packages, directories, and source files using `lowercase_with_underscores`
Lints: `file_names`, `package_names` (both already on).
**Why (the actual reason, not "because"):** *"Some file systems are not case-sensitive, so many projects require filenames to be all lowercase. Using a separating character allows names to still be readable in that form. Using underscores as the separator ensures that the name is still a valid Dart identifier, which may be helpful if the language later supports symbolic imports."*

```
GOOD                      BAD
my_package                mypackage
└─ lib                    └─ lib
   ├─ file_system.dart       ├─ file-system.dart
   └─ slider_menu.dart       └─ SliderMenu.dart
```
Source: https://dart.dev/effective-dart/style#do-name-packages-and-file-system-entities-using-lowercase-with-underscores

Concretely for this app: `lib/features/ruler/ruler_painter.dart`, `lib/data/reference_database.dart`, `packages/rule_engine/lib/src/rule_evaluator.dart`. Not `RulerPainter.dart`, not `ruler-painter.dart`.

### 2.4 DO name import prefixes using `lowercase_with_underscores`
Lint: `library_prefixes` (already on).
```dart
// GOOD
import 'dart:math' as math;
import 'package:drift/drift.dart' as drift;

// BAD
import 'dart:math' as Math;
import 'package:drift/drift.dart' as Drift;
import 'package:angular_components/angular_components.dart' as angularComponents; // camelCase is wrong too
```
Note the Flutter-repo convention on top of this: *"The `dart:math` library is always imported `as math`."* — https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md#import-conventions
Also relevant: `no_leading_underscores_for_library_prefixes` is on by default in `package:lints/recommended.yaml`.
Source: https://dart.dev/effective-dart/style#do-name-import-prefixes-using-lowercase_with_underscores

### 2.5 DO name other identifiers using `lowerCamelCase`
Lint: `non_constant_identifier_names` (already on).
```dart
// GOOD
var count = 3;
HttpRequest httpRequest;
void align(bool clearItems) { ... }
```
Source: https://dart.dev/effective-dart/style#do-name-other-identifiers-using-lowercamelcase

### 2.6 PREFER `lowerCamelCase` for constant names — **including enum values**
Lint: `constant_identifier_names` (on via `package:lints/recommended.yaml`).

```dart
// GOOD                                    // BAD
const pi = 3.14;                           const PI = 3.14;
const defaultTimeout = 1000;               const DefaultTimeout = 1000;
final urlScheme = RegExp('^([a-z]+):');    final URL_SCHEME = RegExp('^([a-z]+):');

class Dice {                               class Dice {
  static final numberGenerator = Random();   static final NUMBER_GENERATOR = Random();
}                                          }
```

**Why (three concrete reasons given by the Dart team, not style preference):**
1. `SCREAMING_CAPS` looks bad for enum-ish values (CSS colours etc.).
2. Constants often get changed to non-const `final` later — which would force a rename.
3. `enum.values` is itself const and lowercase, so caps are already inconsistent with the language.

Allowed exceptions: adding to a file that already uses `SCREAMING_CAPS`, or generating Dart parallel to Java (protobuf enums).
Source: https://dart.dev/effective-dart/style#prefer-using-lowercamelcase-for-constant-names

> **Caveat for Flutter devs:** the Flutter *repo* explicitly disables `constant_identifier_names` ("needs an opt-out") and mandates a `k` prefix on global constants. See §11 — do **not** copy that into an app.

### 2.7 DO capitalize acronyms and abbreviations longer than two letters like words
**Why:** *"given an identifier `HTTPSFTP`, the reader can't tell if it refers to `HTTPS` `FTP` or `HTTP` `SFTP`."* Word-casing disambiguates: `HttpsFtp` vs `HttpSftp`.

```dart
// GOOD                          // BAD
Http   // hypertext transfer     HTTP
Nasa   // national aeronautics   NASA
Uri    // uniform resource id    URI
Esq    // esquire                esq
Ave    // avenue                 ave

// Two letters, capitalized in English → stay capitalized:
ID  TV  UI                       Id   Tv   Ui
// Two letters, NOT capitalized in English → word-case:
Mr  St  Rd                       MR   ST   RD
```

And the rule people forget — **at the start of a `lowerCamelCase` identifier the abbreviation is all lowercase**:
```dart
var httpConnection = connect();
var tvSet = Television();
var mrRogers = 'hello, neighbor';
```
Source: https://dart.dev/effective-dart/style#do-capitalize-acronyms-and-abbreviations-longer-than-two-letters-like-words

**Applied to this app — the exact names to use:**

| Concept | ✅ Use | ❌ Not |
|---|---|---|
| PDF export | `PdfExporter`, `pdfBytes`, `exportPdf()` | `PDFExporter`, `PDFBytes`, `exportPDF()` |
| SQL / SQLite | `SqlBuilder`, `sqliteFile`, `SqliteDatabase` | `SQLBuilder`, `SQLiteDatabase` |
| SVG | `SvgIcon`, `svgAsset` | `SVGIcon` |
| GPS | `GpsFix`, `gpsFix`, `readGpsFix()` | `GPSFix` |
| URL / URI | `Uri`, `assetUrl` | `URL`, `URI` (except `dart:core`'s own `Uri`, which already follows the rule) |
| RTL | `RtlLayout`, `isRtl` | `RTLLayout`, `isRTL` |
| ARB (localization) | `ArbLoader`, `arbFile` | `ARBLoader` |
| UI (two letters, capped in English) | `UiState`… **no** — see below | |

The `UI` case is the sharp edge. The rule says two-letter acronyms capitalised in English stay capitalised — so the *bare* identifier is `UI`. But inside a compound `UpperCamelCase` name, `UIState` reads ambiguously and Flutter's own APIs word-case it. **[opinion]** Use `UiState` / `uiState` in compounds and reserve bare `UI` for standalone; the important thing is you pick one and never mix. Flutter's guide covers the analogous `iOS` problem and lands on `IOS` when unavoidable, while telling you to avoid it entirely: *"use alternatives like 'Cupertino' or 'UIKit' instead when possible."* (https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md#capitalize-identifiers-consistent-with-their-spelling)

### 2.8 PREFER using wildcards for unused callback parameters — **Dart ≥ 3.7 only**
```dart
// GOOD
futureOfVoid.then((_) {
  print('Operation complete.');
});

// Wildcards are non-binding, so you can repeat `_`:
.onError((_, _) {
  print('Operation failed.');
});
```
**Version gate (matters):** non-binding wildcard variables require **language version ≥ 3.7**. Below that you need `__`, `___`. Our floor is Dart 3.12, so we're clear. Two migration lints exist: `no_wildcard_variable_uses` (already on via `core.yaml`) and `unnecessary_underscores` (verified to exist in the SDK linter; **not** on by default — worth adding).

**Scope limit people miss:** this applies only to *anonymous and local* functions. *"top-level functions and method declarations don't have that context, so their parameters must be named so that it's clear what each parameter is for, even if it isn't used."* So a `CustomPainter.shouldRepaint(RulerPainter oldDelegate)` keeps its name even if unused.
Source: https://dart.dev/effective-dart/style#prefer-using-wildcards-for-unused-callback-parameters

### 2.9 DON'T use a leading underscore for identifiers that aren't private
**Why:** *"Dart uses a leading underscore… to mark members and top-level declarations as private. This trains users to associate a leading underscore with one of those kinds of declarations."* There is **no such thing as private** for locals, parameters, local functions, or import prefixes — a leading `_` there is a lie to the reader.
Lints on by default: `no_leading_underscores_for_local_identifiers`, `no_leading_underscores_for_library_prefixes`.
Source: https://dart.dev/effective-dart/style#dont-use-a-leading-underscore-for-identifiers-that-arent-private

### 2.10 DON'T use prefix letters
```dart
// GOOD          // BAD
defaultTimeout   kDefaultTimeout
```
**Why:** *"Hungarian notation and other schemes arose in the time of BCPL, when the compiler didn't do much to help you understand your code. Because Dart can tell you the type, scope, mutability, and other properties of your declarations, there's no reason to encode those properties in identifier names."*
Source: https://dart.dev/effective-dart/style#dont-use-prefix-letters
⚠️ This is the single biggest live conflict with the Flutter repo style guide — see §11.1.

### 2.11 DON'T explicitly name libraries
```dart
// BAD
library my_library;

// GOOD — bare `library;`, used only to attach a library-level doc comment / annotation
/// A really great test library.
@TestOn('browser')
library;
```
**Why:** *"Dart generates a unique tag for each library based on its path and filename. Naming libraries overrides this generated URI. Without the URI, it can be harder for tools to find the main library file in question."* Lint `unnecessary_library_name` is on by default.
Source: https://dart.dev/effective-dart/style#dont-explicitly-name-libraries

Knock-on rule (Usage guide): **DO use strings in `part of` directives**, lint `use_string_in_part_of_directives` (on by default in `core.yaml`).
```dart
// GOOD                                   // BAD
part of '../../my_library.dart';          part of my_library;
```
**This one bites drift and Riverpod codegen directly** — every `part 'x.g.dart';` file must be a URI string. Modern `build_runner` generators emit the string form; if you see `part of some_name;` in hand-written glue code, fix it.
Source: https://dart.dev/effective-dart/usage#do-use-strings-in-part-of-directives

---

## 3. Imports and library layout

### 3.1 Directive ordering — one lint covers all of it: `directives_ordering`
**Not enabled by `flutter_lints`. Turn it on.** (Flutter's own repo enables it: line 111 of `flutter/analysis_options.yaml`.)

Four sub-rules, all from https://dart.dev/effective-dart/style#ordering:
1. **DO place `dart:` imports before other imports.**
2. **DO place `package:` imports before relative imports.**
3. **DO specify exports in a separate section after all imports.**
4. **DO sort sections alphabetically.**

Sections are separated by a blank line.

```dart
// GOOD — a realistic file from this app
import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule_engine/rule_engine.dart';

import 'reference_database.dart';
import 'user_database.dart';

export 'user_database.dart' show UserDatabase;
```

```dart
// BAD — export interleaved with imports, unsorted
import 'src/error.dart';
export 'src/error.dart';
import 'src/foo_bar.dart';
```
Sorting is *string* sort, so `'foo.dart'` sorts before `'foo/foo.dart'`:
```dart
// GOOD          // BAD
import 'foo.dart';        import 'foo/foo.dart';
import 'foo/foo.dart';    import 'foo.dart';
```

### 3.2 DON'T allow an import path to reach into or out of `lib`
Lint: `avoid_relative_lib_imports` (on by default in `core.yaml`).
**Why it's a real bug and not style:** *"Dart thinks those are imports of two completely unrelated libraries."* You get duplicated class identities, `is` checks failing, and static members having two copies.

```dart
// test/api_test.dart — BAD
import 'package:my_package/api.dart';
import '../lib/api.dart';   // ← same file, different library, silent breakage

// test/api_test.dart — GOOD
import 'package:my_package/api.dart';  // Don't reach into 'lib'.
import 'test_utils.dart';              // Relative within 'test' is fine.
```
Two mechanical rules: **don't use `/lib/` in import paths**, **don't use `../` to escape `lib`**.
Source: https://dart.dev/effective-dart/usage#dont-allow-an-import-path-to-reach-into-or-out-of-lib

### 3.3 PREFER relative import paths (inside `lib/`) — **and yes, this is contested**
Lint: `prefer_relative_imports` (not on by default; there's a mutually exclusive `always_use_package_imports`).

Official position: *"When an import does not reach across `lib`, prefer using relative imports. They're shorter."*

```dart
// lib/api.dart                    // lib/src/utils.dart
import 'src/stuff.dart';           import '../api.dart';
import 'src/utils.dart';           import 'stuff.dart';
```

**The disagreement.** Two credible camps:
- **dart.dev + flutter/flutter**: relative inside `lib`. Flutter's `analysis_options.yaml` enables `prefer_relative_imports` (line 196) and comments out `always_use_package_imports` with *"# we do this commonly"* (line 50).
- **Flutter repo style guide, refined**: *"Under `lib/src`, for in-folder import, use relative import. For cross-folder import, import the entire package with absolute import."* (https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md#import-conventions)
- **Common app-team practice**: `always_use_package_imports` everywhere, because it survives file moves cleanly and makes copy-paste between files safe.

**Recommendation for this app [opinion]:** enable **`prefer_relative_imports`** in the app and in `packages/rule_engine`, and use `package:` when crossing a package boundary (app → `rule_engine`, CLI tool → `rule_engine`). Reason: with a workspace of 3 Dart packages, `package:` imports across packages make the dependency direction visible at a glance in every file — which is exactly the property you want when the whole point of the domain package is that it must not import Flutter. Within a package, relative imports are shorter and the IDE refactors them correctly. Do **not** enable both lints; they conflict.

### 3.4 DON'T import libraries inside another package's `src` directory
Lint: `implementation_imports` (on by default in `recommended.yaml`).
**Why:** *"package maintainers… are free to make sweeping changes to code under `src` without it being a breaking change… a minor, theoretically non-breaking point release of that package could break your code."*
Source: https://dart.dev/effective-dart/usage#dont-import-libraries-that-are-inside-the-src-directory-of-another-package

**How to enforce "the domain package has no Flutter imports" (mechanically, not by review):** simply do **not** list `flutter` in `packages/rule_engine/pubspec.yaml` dependencies. Then any `import 'package:flutter/…'` is an analyzer error (unresolved URI), reinforced by `depend_on_referenced_packages` which is on by default in `package:lints/core.yaml`. This is the only zero-effort, CI-proof guarantee; a lint that "bans Flutter imports" does not exist in the SDK linter (verified against the 268 rule files in `dart-lang/sdk/pkg/linter/lib/src/rules/`).

---

## 4. FUNCTION AND METHOD NAMING — the core of this lane

This is the part of Effective Dart that changes code the most and is skipped the most. All of §4 is from https://dart.dev/effective-dart/design#names unless noted. The `get`-prefix rule was **last revised 2026-06-04** (dart-lang/site-www PR #7322) to broaden it from "method" to "function or method" — so it now explicitly covers top-level functions in your pure-Dart domain package, not just class methods.

### 4.1 The decision procedure

```
Does the member need arguments?
├─ NO ──► Does it have user-visible side effects, do surprising work,
│         or is it non-idempotent?
│         ├─ NO  ──► GETTER, noun phrase        rectangle.area, db.isOpen
│         └─ YES ──► METHOD, imperative verb    window.refresh(), db.close()
└─ YES ─► Is returning a value the point, or is the side effect the point?
          ├─ VALUE  ──► METHOD, noun phrase     list.elementAt(3), string.codeUnitAt(4)
          ├─ SIDE FX ─► METHOD, imperative verb list.add(e), queue.removeFirst()
          └─ VALUE, but the WORK matters ──► METHOD, imperative verb
                                             database.downloadData(), graph.solveConstraints()
```

### 4.2 PREFER an imperative verb phrase for a function/method whose main purpose is a side effect
**Why:** *"an invocation reads like a command to do that work."*
```dart
// GOOD
list.add('element');
queue.removeFirst();
window.refresh();
```
App examples: `userDb.saveMeasurement(m)`, `exporter.writePdf(path)`, `controller.resetRuler()`.

### 4.3 PREFER a noun phrase or non-imperative verb phrase if returning a value is the primary purpose
**Why:** *"the member is syntactically a method, but conceptually it is a property"* — it just needs an argument to pick *which* value.
```dart
// GOOD
var element = list.elementAt(3);
var first   = list.firstWhere(test);
var char    = string.codeUnitAt(4);
```
Deliberately softer than 4.2: *"Sometimes a method has no side effects but is still simpler to name with a verb phrase like `list.take()` or `string.split()`."*

App examples: `rules.matchFor(input)` (noun-ish), `refDb.speciesById(id)`, `ruler.tickAt(index)`.

### 4.4 CONSIDER an imperative verb phrase if you want to draw attention to the work
**Why:** *"It may be prone to runtime failures, or use heavyweight resources like networking or file I/O. In cases like this, where you want the caller to think about the work the member is doing, give the member a verb phrase name that describes that work."*
```dart
// GOOD
var table = database.downloadData();
var packageVersions = packageGraph.solveConstraints();
```
Then the crucial hedge: *"the work an operation performs is often an implementation detail… Most of the time, name your members based on **what** they do for the caller, not **how** they do it."*

**Applied to this offline app** — this is precisely the "cold start under 1.2 s" lever. Anything that hits SQLite, decodes an SVG, rasterises a PDF page, or opens the camera should be a **verb-named method**, so a reader instantly sees "this costs something" at the call site:
```dart
// GOOD — the cost is visible at every call site
final rules = await refDb.loadRuleSet();      // reads the pre-seeded asset DB
final bytes = await exporter.renderPdf(doc);  // rasterises
final fix   = await locator.readCurrentFix(); // single-shot GPS

// BAD — reads like a free field access, hides a disk hit and a GPS wait
final rules = refDb.ruleSet;
final fix   = locator.currentFix;
```

### 4.5 AVOID starting a function or method name with `get`
**Two-step fix, verbatim from the guide:**
1. If it needs no arguments → *"the method or function should be a getter with `get` removed from the name. For example, instead of a method named `getBreakfastOrder()`, define a getter named `breakfastOrder`."*
2. If it *does* need arguments, still drop `get`, and then either use a noun phrase, *"or use a verb phrase name if the caller cares about the work being done, but pick a verb that more precisely describes the work than `get`, like `create`, `download`, `fetch`, `calculate`, `request`, `aggregate`, etc."*

**Before → after (real shapes from this app):**

| ❌ Before | ✅ After | Which rule |
|---|---|---|
| `getBreakfastOrder()` | `breakfastOrder` (getter) | no args → getter |
| `getMeasurements()` | `loadMeasurements()` | hits SQLite → verb that names the work |
| `getRuleById(String id)` | `ruleById(String id)` | pure lookup, value is the point |
| `getPdfBytes()` | `renderPdf()` | the work is expensive and worth flagging |
| `getIsValid()` | `isValid` (getter) | boolean property |
| `getCurrentLocale()` | `currentLocale` (getter) | no args, cheap |
| `getLocalizedName(Locale l)` | `localizedName(Locale l)` | value is the point |
| `getTickSpacing(double w)` | `tickSpacingFor(double w)` | noun phrase, arg disambiguated |

Source: https://dart.dev/effective-dart/design#avoid-starting-a-function-or-method-name-with-get

### 4.6 PREFER `to___()` for a copy, `as___()` for a view
Lint: `use_to_and_as_if_applicable` (not on by default; Flutter's repo disables it with *"has false positives, so we prefer to catch this by code-review"* — line 272).

**The distinction that matters:** `to___()` returns a **snapshot** with its own copy of the state. `as___()` returns a **view** — *"that object refers back to the original. Later changes to the original object are reflected in the view."*

```dart
// GOOD — copies
list.toSet();
stackTrace.toString();
dateTime.toLocal();

// GOOD — views backed by the original
var map    = table.asMap();
var list   = bytes.asFloat32List();
var future = subscription.asFuture();
```
App: `measurement.toJson()` (snapshot), `rowSet.asMap()` (view). If you write `asJson()` you are lying about lifetime.
Sources: https://dart.dev/effective-dart/design#prefer-naming-a-method-to___-if-it-copies-the-objects-state-to-a-new-object and `…#prefer-naming-a-method-as___-if-it-returns-a-different-representation-backed-by-the-original-object`

### 4.7 AVOID describing the parameters in the name
**Why:** *"The user will see the argument at the call site, so it usually doesn't help readability to also refer to it in the name itself."*
```dart
// GOOD              // BAD
list.add(element);   list.addElement(element)
map.remove(key);     map.removeKey(key)
```
**Exception that is not a loophole** — mention the parameter when it disambiguates overload-like siblings:
```dart
// GOOD
map.containsKey(key);
map.containsValue(value);
```
App: `db.deleteMeasurement(id)` is fine (it says *what* is deleted, not what the parameter is); `db.deleteMeasurementById(id)` is redundant unless there's also `deleteMeasurementByDate`.

### 4.8 Boolean naming
**PREFER a non-imperative verb phrase for a boolean property or variable.**
Good names start with:
- a form of *to be*: `isEnabled`, `wasShown`, `willFire` — *"by far, the most common"*
- an auxiliary verb: `hasElements`, `canClose`, `shouldConsume`, `mustSave`
- an active verb, **rarely**: `ignoresInput`, `wroteFile` — *"these are rare because they are usually ambiguous. `loggedResult` is a bad name because it could mean 'whether or not a result was logged' or 'the result that was logged'."*

```dart
// GOOD           // BAD
isEmpty           empty          // Adjective or verb?
hasElements       withElements   // Sounds like it might hold elements.
canClose          closeable      // Sounds like an interface.
closesWindow      closingWindow  // Returns a bool or a window?
canShowPopup      showPopup      // Sounds like it SHOWS the popup.
hasShownPopup
```
The governing principle: *"A boolean name should never sound like a command to tell the object to do something, because accessing a property doesn't change the object."*

**PREFER the "positive" name.**
```dart
// GOOD
if (socket.isConnected && database.hasData) { socket.write(database.read()); }

// BAD — forces the reader to do a double negation
if (!socket.isDisconnected && !database.isEmpty) { socket.write(database.read()); }
```
Ambiguous cases (saved/unchanged?): *"lean towards the choice that is less likely to be negated by users or has the shorter name."* Exception: if users overwhelmingly need the negative, use it.
Flutter's guide says the same thing more bluntly: *"when you have a property or argument named 'disabled' or 'hidden', it leads to code such as `input.disabled = false`… which is very confusing."* (https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md#avoid-double-negatives-in-apis)

**CONSIDER omitting the verb for a named boolean *parameter*.**
```dart
// GOOD
Isolate.spawn(entryPoint, message, paused: false);
var copy = List.from(elements, growable: true);
var regExp = RegExp(pattern, caseSensitive: false);
```
App: `ExportOptions(includeImages: true, rtl: true)` reads better than `shouldIncludeImages`.

Sources: https://dart.dev/effective-dart/design#prefer-a-non-imperative-verb-phrase-for-a-boolean-property-or-variable, `…#prefer-the-positive-name-for-a-boolean-property-or-variable`, `…#consider-omitting-the-verb-for-a-named-boolean-parameter`

### 4.9 PREFER a noun phrase for a non-boolean property or variable
**Why:** *"The reader's focus is on **what** the property is. If the user cares more about **how** a property is determined, then it should probably be a method with a verb phrase name."*
```dart
// GOOD                    // BAD
list.length                list.deleteItems
context.lineWidth
quest.rampagingSwampBeast
```

### 4.10 The four supporting name-quality rules
- **DO use terms consistently.** `pageCount` field ⇒ `updatePageCount()`, not `renumberPages()`. `toSomething()` to match `toList()`; `asSomething()` to match `asMap()`. Prefer a familiar concept name (`Point`) over a clever one (`Cartesian`). *"The goal is to take advantage of what the user already knows."*
- **AVOID abbreviations.** *"Unless the abbreviation is more common than the unabbreviated term, don't abbreviate."* `pageCount` not `numPages`; `buildRectangles` not `buildRects`; but `HttpRequest` not `HypertextTransferProtocolRequest`.
- **PREFER putting the most descriptive noun last.** `ChunkedConversionSink` (a `ConversionSink` that's chunked), `CssFontFaceRule` (a rule). ❌ `RuleFontFaceCss` — *"Not a CSS."* ❌ `CanvasRenderingContext2D` — *"Not a 2D."*
  App: `ReferenceDatabase` not `DatabaseReference`; `RulerTickPainter` not `PainterRulerTick`; `ArabicNumeralFormatter` not `FormatterArabicNumeral`.
- **CONSIDER making the code read like a sentence** — but *"you can go too far"*:
  ```dart
  // GOOD                                     // BAD (over-done)
  if (errors.isEmpty) { }                     if (theCollectionOfErrors.isEmpty) { }
  subscription.cancel();
  monsters.where((m) => m.hasClaws);          monsters.producesANewSequenceWhereEach((m) => m.hasClaws);
  ```

### 4.11 DO follow existing mnemonic conventions for type parameters
`E` element, `K`/`V` key/value, `R` return type (visitors), otherwise `T`, `S`, `U` (multiple letters exist so nesting doesn't shadow: `class Future<T> { Future<S> then<S>(...) }`). A descriptive name is fine too: `class Graph<Node, Edge>`.
For the rule engine: `Rule<T>` / `RuleResult<T>` are right; a visitor is `RuleVisitor<R>`.
Source: https://dart.dev/effective-dart/design#do-follow-existing-mnemonic-conventions-when-naming-type-parameters

### 4.12 Flutter-specific callback naming (Flutter repo style guide, not Effective Dart)
*"When naming callbacks, use `FooCallback` for the typedef, `onFoo` for the callback argument or property, and `handleFoo` for the method that is called. If `Foo` is a verb, prefer the present tense (`onTap` not `onTapped`). Never call a method `onFoo`. If a property is called `onFoo` it must be a function type."*
```dart
typedef MeasurementCallback = void Function(Measurement m);

class RulerWidget extends StatefulWidget {
  const RulerWidget({super.key, this.onMeasure});
  final MeasurementCallback? onMeasure;   // property → onFoo
}

class _RulerWidgetState extends State<RulerWidget> {
  void handleMeasure(Measurement m) { ... }   // method → handleFoo
}
```
Note this section also says *"Prefer using `typedef`s to declare callbacks"* — which **contradicts** Effective Dart's *"PREFER inline function types over typedefs."* See §11.3.
Source: https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md#naming-rules-for-typedefs-and-function-variables

---

## 5. Getter vs. method vs. setter — the gauntlet

Source: https://dart.dev/effective-dart/design#do-use-getters-for-operations-that-conceptually-access-properties

**The mental model that fixes everything:** *"In Dart, all dotted names are member invocations that may do computation. Fields are special—they're getters whose implementation is provided by the language. In other words, getters are not 'particularly slow fields' in Dart; fields are 'particularly fast getters'."*

A member should be a **getter** only if **all five** hold:
1. **Takes no arguments and returns a result.**
2. **The caller cares mostly about the result**, not how it's produced. *"This does not mean the operation has to be particularly fast… `IterableBase.length` is O(n), and that's OK."* But if it does a *surprising* amount of work, make it a verb-named method. ❌ `connection.nextIncomingMessage` (network I/O), ❌ `expression.normalForm` (possibly exponential).
3. **No user-visible side effects.** Hidden caching, logging, lazy computation are all fine. ❌ `stdout.newline`, ❌ `list.clear`.
4. **Idempotent.** ❌ `DateTime.now` — *"New result each time."* It's fine to return a *new* list/future each call as long as the contents/completion value are the same: *"the result value should be the same in the aspects that the caller cares about."*
5. **Doesn't expose the whole original state** — if it does, it's a `to___()` or `as___()`.

```dart
// GOOD getters
rectangle.area;
collection.isEmpty;
button.canShow;
dataSet.minimumValue;
```

**Setters** are the mirror image: single argument, no result, changes state, idempotent (*"Calling the same setter twice with the same value should do nothing the second time as far as the caller is concerned"*). Lint `use_setters_to_change_properties`.

**DON'T define a setter without a corresponding getter** (lint `avoid_setters_without_getters`, enabled in Flutter's repo). *"A setter without a getter means you can use `=` to modify it, but not `+=`."* And the important nuance: don't add a fake getter just to satisfy this — *"If you have some piece of an object's state that can be modified but not exposed in the same way, use a method instead."*

**Where Flutter disagrees — and it matters for the 1.2 s cold-start budget.** The Flutter repo style guide is stricter:
> *"Property getters should be efficient (e.g. just returning a cached value, or an O(1) table lookup). If an operation is inefficient, it should be a method instead… Similarly, a getter that returns a Future should not kick-off the work represented by the future, since getters appear idempotent and side-effect free. Instead, the work should be started from a method or constructor, and the getter should just return the preexisting Future."*
> — https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md#getters-feel-faster-than-methods

**Recommendation [opinion]:** adopt **Flutter's stricter rule** for this app. Effective Dart's "O(n) is fine" was written for library authors reasoning about API shape; you're reasoning about a startup budget on a low-end Android device. Concretely: **no getter in this codebase may touch SQLite, decode an SVG, read an asset, or start a Future.** `Future`-returning getters are permitted only when they return an already-started future (`Future<void> get ready => _ready;`).

Two supporting Usage rules:
- **DON'T wrap a field in a getter and setter unnecessarily** (lint `unnecessary_getters_setters`, on by default). *"Dart doesn't have this limitation [Java/C#]. Fields and getters/setters are completely indistinguishable. You can expose a field in a class and later wrap it in a getter and setter without having to touch any code that uses that field."*
  ```dart
  // GOOD                     // BAD
  class Box {                 class Box {
    Object? contents;           Object? _contents;
  }                             Object? get contents => _contents;
                                set contents(Object? v) { _contents = v; }
                              }
  ```
- **PREFER using a `final` field to make a read-only property.**
  ```dart
  // GOOD                    // BAD
  class Box {                class Box {
    final contents = [];       Object? _contents;
  }                            Object? get contents => _contents;
                             }
  ```
- **AVOID public `late final` fields without initializers** — *"a `late final` field without an initializer **does** define a setter. If that field is public, then the setter is public. This is rarely what you want."* Four fixes offered: drop `late`; use a factory constructor; initialize at declaration; or make it private with a public getter.

---

## 6. Documentation

All from https://dart.dev/effective-dart/documentation.

### 6.1 The mechanical rules
- **DO use `///`** (lint `slash_for_doc_comments`, on by default). `/** */` is legacy JavaDoc style; *"`/**` and `*/` add two content-free lines."*
- **DON'T use block comments for documentation.** `/* */` is only for temporarily commenting out code.
- **DO format comments like sentences** — capitalize (unless it's a case-sensitive identifier), end with `.`, *"This is true for all comments: doc comments, inline stuff, even TODOs. Even if it's a sentence fragment."*
- **DO put doc comments before metadata annotations.**
  ```dart
  // GOOD                                   // BAD
  /// A button that can be flipped on and off.   @Component(selector: 'toggle')
  @Component(selector: 'toggle')                 /// A button that can be flipped on and off.
  class ToggleComponent {}                       class ToggleComponent {}
  ```
- **PREFER writing doc comments for public APIs** (lint `public_member_api_docs`, off by default). *"You don't have to document every single library, top-level variable, type, and member, but you should document most of them."*
- **CONSIDER writing doc comments for private APIs** too.

### 6.2 The two rules that most change how docs read
**DO start doc comments with a single-sentence summary.**
```dart
// GOOD
/// Deletes the file at [path] from the file system.
void delete(String path) { ... }

// BAD
/// Depending on the state of the file system and the user's permissions,
/// certain operations may or may not be possible. If there is no file at
/// [path] or it can't be accessed, this function throws either [IOError]
/// or [PermissionError], respectively. Otherwise, this deletes the file.
void delete(String path) { ... }
```

**DO separate the first sentence into its own paragraph.** (Blank `///` line.)
```dart
// GOOD
/// Deletes the file at [path].
///
/// Throws an [IOError] if the file could not be found. Throws a
/// [PermissionError] if the file is present but could not be deleted.
void delete(String path) { ... }

// BAD
/// Deletes the file at [path]. Throws an [IOError] if the file could not
/// be found. Throws a [PermissionError] if the file is present but could
/// not be deleted.
void delete(String path) { ... }
```
**Why it's not cosmetic:** *"tools like `dart doc` use the first paragraph as a short summary in places like lists of classes and members."* Without the blank line, your class index page shows a wall of text.

### 6.3 Doc opening phrase must match the member kind
This mirrors §4's naming rules exactly, which is the point — name and doc agree.

| Member kind | Opening | Example |
|---|---|---|
| Function/method, side effect is the point | **third-person verb** | `/// Connects to the server and fetches the query results.` `/// Starts the stopwatch if not already running.` |
| Non-boolean variable/property (incl. getters) | **noun phrase** | `/// The current day of the week, where `0` is Sunday.` `/// The number of checked buttons on the page.` |
| Boolean variable/property | **"Whether …"** | `/// Whether the modal is currently displayed to the user.` `/// Whether resizing the current browser window will also resize the modal.` |
| Method that is conceptually a property | **noun phrase / "Whether"** | `/// The [index]th element of this iterable in iteration order.` → `E elementAt(int index);` `/// Whether this iterable contains an element equal to [element].` → `bool contains(Object? element);` |
| Library or type | **noun phrase, describing an *instance*** | `/// A chunk of non-breaking output text terminated by a hard or soft newline.` |

Explicit note in the guide: **don't write "Whether or not"** — *"usage of 'or not' with 'whether' is superfluous."*

Also: *"This is true even for getters which may do calculation or other work. What the caller cares about is the **result** of that work, not the work itself."*

### 6.4 AVOID redundancy with the surrounding context
```dart
// GOOD
class RadioButtonWidget extends Widget {
  /// Sets the tooltip to [lines].
  ///
  /// The lines should be word wrapped using the current font.
  void tooltip(List<String> lines) { ... }
}

// BAD
class RadioButtonWidget extends Widget {
  /// Sets the tooltip for this radio button widget to the list of strings in
  /// [lines].
  void tooltip(List<String> lines) { ... }
}
```
And the permission to say nothing: *"If you really don't have anything interesting to say that can't be inferred from the declaration itself, then omit the doc comment. It's better to say nothing than waste a reader's time telling them something they already know."*

Flutter's guide sharpens this into a **test**: *"If someone could have written the same documentation without knowing anything about the class other than its name, then it's useless."*
```dart
// BAD                                  // GOOD
/// The background color.               /// The color with which to fill the circle.
final Color backgroundColor;            ///
                                        /// Changing the background color will cause the
                                        /// avatar to animate to the new color.
                                        final Color backgroundColor;
```
Plus: *"avoid saying 'Note:', or starting a sentence with 'Note that'. It adds nothing."*
— https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md#avoid-useless-documentation

### 6.5 DO use square brackets for in-scope identifiers
Lint: `comment_references` (off by default; Flutter's repo has it disabled pending a linter bug).
```dart
/// Throws a [StateError] if ...
///
/// Similar to [anotherMethod()], but ...

/// Similar to [Duration.inDays], but handles fractional days.

/// To create a point, call [Point.new] or use [Point.polar] to ...
```
`[Class.member]` for members, **`[Class.new]` for the unnamed constructor**, parentheses optional but clarify you mean a function.
Full reference: https://dart.dev/tools/doc-comments/references (verified live, includes "doc imports" for referencing types you don't import).

### 6.6 DO use prose, not tags
```dart
// BAD
/// Defines a flag with the given name and abbreviation.
///
/// @param name The name of the flag.
/// @param abbr The abbreviation for the flag.
/// @returns The new flag.
/// @throws ArgumentError If there is already an option with
///     the given name or abbreviation.
Flag addFlag(String name, String abbreviation) => ...

// GOOD
/// Defines a flag with the given [name] and [abbreviation].
///
/// The [name] and [abbreviation] strings must not be empty.
///
/// Returns a new flag.
///
/// Throws a [DuplicateFlagException] if there is already an option named
/// [name] or there is already an option using the [abbreviation].
Flag addFlag(String name, String abbreviation) => ...
```
The recommended sentence starters: **"The \[parameter\] …"**, **"Returns …"**, **"Throws …"**.

### 6.7 DON'T document both the getter and the setter
*"`dart doc` treats the getter and setter like a single field, and if both … have doc comments, then `dart doc` discards the setter's doc comment."* So the second doc comment is silently thrown away.
```dart
// GOOD
/// The pH level of the water in the pool.
///
/// Ranges from 0-14, representing acidic to basic, with 7 being neutral.
int get phLevel => ...
set phLevel(int level) => ...
```

### 6.8 Prose style
- **PREFER brevity.** *"Be clear and precise, but also terse."*
- **AVOID abbreviations and acronyms unless obvious.** *"Many people don't know what 'i.e.', 'e.g.' and 'et al.' mean."*
- **PREFER "this" over "the"** to refer to the receiver: `/// The value this box wraps.` `/// Whether this box contains a value.`
- **AVOID excessive markdown**; **AVOID HTML**; **PREFER backtick fences** over 4-space indentation (indent-style breaks inside lists).
- **CONSIDER including code samples** — *"Humans are great at generalizing from examples, so even a single code sample makes an API easier to learn."*
- **CONSIDER a library-level doc comment** on `library;`, including: one-sentence summary, terminology, a couple of complete samples, links to the most important classes.

**For the pure-Dart `rule_engine` package this is the highest-ROI documentation in the project** — it's the only package with two independent consumers (the app and the CLI build tool), so the library doc comment is where the shared vocabulary gets defined.

---

## 7. Usage rules that matter most in practice

Source: https://dart.dev/effective-dart/usage.

### 7.1 Collections
- **DO use collection literals** (lint `prefer_collection_literals`, on by default).
  ```dart
  // GOOD                              // BAD
  var points = <Point>[];              var addresses = Map<String, Address>();
  var addresses = <String, Address>{}; var counts = Set<int>();
  var counts = <int>{};
  ```
  Named constructors (`List.from`, `Map.fromIterable`) are exempt.
  The real payoff is spread + control-flow elements:
  ```dart
  // GOOD
  var arguments = [
    ...options,
    command,
    ...?modeFlags,
    for (var path in filePaths)
      if (path.endsWith('.dart')) path.replaceAll('.dart', '.js'),
  ];
  ```
  This is exactly how Flutter widget `children:` lists should be built — never `addAll`/`if`-then-`add` chains.
- **DON'T use `.length` to see if a collection is empty** (lints `prefer_is_empty`, `prefer_is_not_empty`, both on). *"The Iterable contract does not require that a collection know its length or be able to provide it in constant time."* Use the form that avoids negation: `words.isNotEmpty`, not `!words.isEmpty`.
- **AVOID `Iterable.forEach()` with a function literal** (lint `avoid_function_literals_in_foreach_calls`, on). Use `for (final x in xs)`. `people.forEach(print)` (a tear-off) is fine; `Map.forEach` is always fine.
- **DO use `whereType<T>()`** (lint `prefer_iterable_whereType`, on) instead of `.where((e) => e is int)` — the latter returns `Iterable<Object>`, and `.where(...).cast<int>()` creates two wrappers with redundant runtime checks.
- **AVOID `cast()`.** *"The `cast()` method returns a lazy collection that checks the element type on every operation."* Three better options, in order: create it with the right type; cast each element on access; eagerly `List<T>.from()`.
- **DON'T use `List.from()` unless you intend to change the type** — `iterable.toList()` preserves the type argument; `List.from(iterable)` yields `List<dynamic>`.

### 7.2 `final` vs `var` on locals — pick a rule and never deviate
> *"There are two rules in wide use… Use `final` for local variables that are not reassigned and `var` for those that are. **Or:** Use `var` for all local variables, even ones that aren't reassigned. Never use `final` for locals. Either rule is acceptable, but pick **one** and apply it consistently throughout your code. That way when a reader sees `var`, they know whether it means that the variable is assigned later in the function."*

**Recommendation [opinion]: rule 1 (`final` when not reassigned), enforced with `prefer_final_locals`.** Reason: it's the rule Flutter's own repo enforces (`- prefer_final_locals`, line 178 of `flutter/analysis_options.yaml`), it makes `var` a genuine signal of mutation, and it's the only one of the two that a lint can enforce. Note Flutter also comments out `unnecessary_final` with *"conflicts with prefer_final_locals"* — you cannot have both.
Also add `prefer_final_in_for_each` for `for (final x in xs)`.
Source: https://dart.dev/effective-dart/usage#do-follow-a-consistent-rule-for-var-and-final-on-local-variables

Separately, at the *declaration* level: **PREFER making fields and top-level variables `final`** (lint `prefer_final_fields`, on by default). *"State that is not mutable… is easier for programmers to reason about."* This also unlocks type promotion (§7.3).

### 7.3 Null
- **DON'T explicitly initialize variables to `null`** and **DON'T use an explicit default value of `null`** (lint `avoid_init_to_null`, on). *"There's no concept of 'uninitialized memory' in Dart."*
- **DON'T use `true`/`false` in equality operations.** `if (b)` / `if (!b)`, never `if (b == true)`.
  For a *nullable* bool, the guide is specific: use `if (nullableBool ?? false)` if you want null→false, **or** `if (nullableBool != null && nullableBool)` if you also want type promotion inside the body. `nullableBool == true` is condemned for three reasons: it doesn't signal null-handling; it looks like the redundant non-nullable case; and *"if `nullableBool` is null, then `nullableBool == true` means the condition evaluates to `false`"* — confusing logic. Crucially: *"Using a null-aware operator such as `??` on a variable inside a condition doesn't promote the variable to a non-nullable type."*
- **AVOID `late` variables if you need to check whether they are initialized.** *"Dart offers no way to tell if a `late` variable has been initialized."* Use a non-`late` nullable and check for `null`.
- **CONSIDER type promotion or null-check patterns.** Type promotion works for locals, parameters, and **private final fields** — which is another reason to follow "private + final" by default.
  ```dart
  // GOOD — Dart 3 null-check pattern
  @override
  String toString() {
    if (this.response case var response?) {
      return 'Could not complete upload to ${response.url} '
          '(error code ${response.errorCode}): ${response.reason}.';
    }
    return 'Could not upload (no response).';
  }

  // GOOD — shadow into a local (make it `final` to avoid writing back to the wrong thing)
  final response = this.response;
  if (response != null) { ... }

  // BAD — `!` sprinkled everywhere
  if (response != null) {
    return '... ${response!.url} ... ${response!.errorCode} ...';
  }
  ```
  Warning attached to the local-shadow trick: *"if the field might change while the local is still in scope, then the local might have a stale value."*

### 7.4 Error handling
- **AVOID catches without `on` clauses** (lint `avoid_catches_without_on_clauses`, off by default; Flutter's repo has it blocked on a linter bug). *"Pokémon exception handling is very likely not what you want. Does your code correctly handle StackOverflowError or OutOfMemoryError? … Do you want any `assert()` statements inside that code to effectively vanish since you're catching the thrown AssertionErrors?"* If you must catch broadly, *"it is usually better to catch `Exception` than to catch all types."*
- **DON'T discard errors from catches without `on` clauses.** *"Log it, display it to the user or rethrow it, but do not silently discard it."* (Lint `empty_catches` is on by default and catches the worst case.)
- **DO throw `Error` subtypes only for programmatic errors** (bugs); **DON'T explicitly catch `Error`** (lint `avoid_catching_errors`) — *"it should unwind the entire callstack, halt the program, and print a stack trace."*
- **DO use `rethrow`** (lint `use_rethrow_when_possible`, on by default). **Why:** *"`rethrow` preserves the original stack trace… `throw` on the other hand resets the stack trace to the last thrown position."*
  ```dart
  // GOOD                                  // BAD
  try { somethingRisky(); }                try { somethingRisky(); }
  catch (e) {                              catch (e) {
    if (!canHandle(e)) rethrow;              if (!canHandle(e)) throw e;
    handle(e);                               handle(e);
  }                                        }
  ```
  **For a fully offline app this is the difference between a usable and a useless crash report**, since you have no error-reporting network call to fall back on — the stack trace in the local log is all you get.

### 7.5 Asynchrony
- **PREFER async/await over raw futures.** *"Asynchronous code is notoriously hard to read and debug… `async`/`await` improves readability and lets you use all of the Dart control flow structures within your async code."*
  ```dart
  // GOOD
  Future<int> countActivePlayers(String teamName) async {
    try {
      var team = await downloadTeam(teamName);
      if (team == null) return 0;
      var players = await team.roster;
      return players.where((player) => player.isActive).length;
    } on DownloadException catch (e) {
      log.error(e);
      return 0;
    }
  }
  ```
  Note the `on DownloadException catch (e)` — async/await is what lets you use a *typed* catch, which is what §7.4 demands.
- **DON'T use `async` when it has no useful effect.**
  ```dart
  // GOOD                                                    // BAD
  Future<int> fastestBranch(Future<int> l, Future<int> r) {   ... async {
    return Future.any([l, r]);                                  return Future.any([l, r]);
  }                                                           }
  ```
  `async` *is* useful when: you `await`; you throw asynchronously (`async` + `throw` beats `return Future.error(...)`); or you want a value implicitly wrapped (`async` beats `Future.value(...)`).
- **AVOID using `Completer` directly.** *"Completer is needed for two kinds of low-level code: new asynchronous primitives, and interfacing with asynchronous code that doesn't use futures."*
- **DO test for `Future<T>`, not `T`, when disambiguating a `FutureOr<T>`** whose type argument could be `Object` — because `Future<Object>` *is* an `Object`, so `is T` returns true for the future itself.
- **AVOID `FutureOr<T>` as a return type** (design guide) — *"only use `FutureOr<T>` in contravariant positions"*, i.e. parameters and callback return types, never your own return type. `Future<int> triple(FutureOr<int> value) async => (await value) * 3;` is the good shape.
- **DO use `Future<void>`** for async members that produce no value (not `Future` or `Future<Null>`).

### 7.6 Cascades, arrows, `this.`, `new`, `const`
- **AVOID returning `this` for a fluent interface** (lint `avoid_returning_this`) — *"Method cascades are a better solution."*
  ```dart
  // GOOD                        // BAD
  var buffer = StringBuffer()     var buffer = StringBuffer()
    ..write('one')                    .write('one')
    ..write('two')                    .write('two')
    ..write('three');                 .write('three');
  ```
- **CONSIDER `=>` for simple members** (lint `prefer_expression_function_bodies`, off by default) — but *"People writing code seem to love `=>`, but it's very easy to abuse it… If your declaration is more than a couple of lines or contains deeply nested expressions—cascades and conditional operators are common offenders—do yourself and everyone who has to read your code a favor and use a block body."*
  ```dart
  // BAD — this is what abuse looks like
  Treasure? openChest(Chest chest, Point where) => _opened.containsKey(chest)
      ? null
      : _opened[chest] = (Treasure(where)..addAll(chest.contents));
  ```
  Flutter's repo agrees and states the mechanical version: *"Use a block (with braces) when a body would wrap onto more than one line."* — it disables `prefer_expression_function_bodies` for that reason.
- **DON'T use `this.`** except to avoid shadowing or to redirect to a named constructor (lint `unnecessary_this`, on by default). Note the surprising fact: *"constructor parameters never shadow fields in constructor initializer lists"*, so `Box(Object? value) : value = value, super(value);` works.
- **DON'T use `new`** (lint `unnecessary_new`, on) — *"consider it deprecated."* **DON'T use `const` redundantly** (lint `unnecessary_const`, on): inside a const collection literal, const constructor call, metadata annotation, const variable initializer, or a switch-case expression, `const` is implicit.
- **DO use initializing formals** (`this.x`) and **super parameters** (`super.key`); **DO use `;` not `{}`** for empty constructor bodies; **DON'T use `late` when a constructor initializer list will do**; **DO initialize fields at their declaration when possible.**
- **DO use a function declaration to bind a function to a name** (lint `prefer_function_declarations_over_variables`, on) — `void localFunction() {}`, not `var localFunction = () {};`
- **DON'T create a lambda when a tear-off will do** (lint `unnecessary_lambdas`, off by default, has known false positives per Flutter's config):
  ```dart
  // GOOD                                        // BAD
  charCodes.forEach(print);                      charCodes.forEach((c) { print(c); });
  charCodes.forEach(buffer.write);               charCodes.forEach((c) { buffer.write(c); });
  charCodes.map(String.fromCharCode);            charCodes.map((c) => String.fromCharCode(c));
  charCodes.map(StringBuffer.new);               charCodes.map((c) => StringBuffer(c));
  ```
  Note `StringBuffer.new` — the unnamed-constructor tear-off. Same syntax as the `[Point.new]` doc reference.

### 7.7 AVOID storing what you can calculate
```dart
// GOOD                                  // BAD
class Circle {                           class Circle {
  double radius;                           double radius;
  Circle(this.radius);                     double area;
                                           double circumference;
  double get area => pi * radius * radius; Circle(double radius)
  double get circumference =>                : radius = radius,
      pi * 2.0 * radius;                       area = pi * radius * radius,
}                                              circumference = pi * 2.0 * radius;
                                         }
```
**Why it's a correctness bug, not just waste:** *"the code is **wrong**. The problem with caches is invalidation… Here, we never do, even though `radius` is mutable."*
The escape hatch, with conditions: *"you may need to cache the result of a slow calculation, but only do that **after** you know you have a performance problem, do it carefully, and leave a comment explaining the optimization."*
**Directly applicable to the ruler `CustomPainter`** — derive tick positions in `paint()` or a getter from a single source of truth; don't precompute a parallel array in the constructor that goes stale when the widget rebuilds with a new scale.

---

## 8. Design: API shape rules that change how code reads

Source: https://dart.dev/effective-dart/design.

- **PREFER making declarations private.** *"Narrow public interfaces are easier for you to maintain and easier for users to learn. As a nice bonus, the analyzer will tell you about unused private declarations so you can delete dead code. It can't do that if the member is public because it doesn't know if any code outside of its view is using it."* — the dead-code detection is the underrated half.
- **CONSIDER declaring multiple classes in the same library.** *"privacy in Dart works at the library level, not the class level, this is a way to define 'friend' classes like you might in C++."* For the drift layer, put the DAO and its private row-mapping helpers in one library and keep the helpers `_private`.
- **AVOID positional boolean parameters** (lint `avoid_positional_boolean_parameters`, off by default; Flutter's repo says *"would have been nice to enable this but by now there's too many places that break it"*).
  ```dart
  // BAD                            // GOOD
  Task(true);                       Task.oneShot();
  Task(false);                      Task.repeating();
  ListBox(false, true, true);       ListBox(scroll: true, showScrollbars: true);
  Button(false);                    Button(ButtonState.enabled);
  ```
  Exempt: setters, where the name carries the meaning — `listBox.canScroll = true;`
- **AVOID mandatory parameters that accept a special "no argument" value.** `string.substring(start)`, not `string.substring(start, null)`.
- **AVOID optional positional parameters if the user may want to omit earlier ones** — that's what named parameters are for.
- **DO use inclusive start and exclusive end** for ranges: `[0,1,2,3].sublist(1, 3) // [1, 2]`, `'abcd'.substring(1, 3) // 'bc'`. *"It's particularly important to be consistent here because these parameters are usually unnamed. If your API takes a length instead of an end point, the difference won't be visible at all at the call site."*
- **AVOID returning nullable `Future`, `Stream`, and collection types** — return an empty collection / a non-nullable future of a nullable type / a stream that emits nothing. Exception only when `null` *means something different* from empty.
- **AVOID defining a one-member abstract class when a function will do** (lint `one_member_abstracts`) — `typedef Predicate<E> = bool Function(E element);`
- **AVOID defining a class that contains only static members** (lint `avoid_classes_with_only_static_members`). *"In idiomatic Dart, classes define kinds of objects. A type that is never instantiated is a code smell."* **But** the guide immediately grants the exception you'll actually use: *"with constants and enum-like types, it may be natural to group them in a class"* (`class Color { static const red = '#f00'; … }`). Flutter's repo disables the lint entirely: *"we do this commonly for `abstract final class`es"*.
- **AVOID using runtime type tests to fake overloading.** *"faking overloading this way turns a compile time method selection into a choice that happens at runtime."* Define differently named methods.
- **DO use class modifiers (`final`, `interface`, `base`, `sealed`) to control extension/implementation** rather than documenting your intent and hoping. This *replaced* the old "DO document if your class supports being extended" guideline — the old anchors are still in the page as hidden redirects. Dart 3.0+.
- **PREFER a pure `mixin` or pure `class` over a `mixin class`** (lint `prefer_mixin`; Flutter enables it). *"`mixin class` is mostly meant to help migrate pre-3.0.0 classes."*
- **CONSIDER making your constructor `const`** if all fields are final — *"a `const` constructor is a commitment in your public API."* For the rule engine's immutable value types, do it: it lets rule definitions live in `const` tables, which is free at startup.
- **Equality:** DO override `hashCode` if you override `==` (lint `hash_and_equals`, on); DO make `==` reflexive/symmetric/transitive; AVOID custom equality for **mutable** classes (lint `avoid_equals_and_hash_code_on_mutable_classes`; Flutter enables it) — *"Most hash-based collections… assume an object's hash code will be the same forever"*; **DON'T make the parameter to `==` nullable** (lint `avoid_null_checks_in_equality_operators`):
  ```dart
  // GOOD
  bool operator ==(Object other) => other is Person && name == other.name;
  // BAD
  bool operator ==(Object? other) => other != null && other is Person && name == other.name;
  ```
  *"The language specifies that `null` is equal only to itself, and that the `==` method is called only if the right-hand side is not `null`."*

---

## 9. Type annotations — when to write them, when to shut up

Source: https://dart.dev/effective-dart/design#types. The guide's own three-line summary:
> *"Do annotate when inference doesn't have enough context, even when `dynamic` is the type you want. Don't annotate locals and generic invocations unless you need to. Prefer annotating top-level variables and fields unless the initializer makes the type obvious."*

| Situation | Rule | Lint |
|---|---|---|
| Variable **without** an initializer | **DO annotate** | `prefer_typing_uninitialized_variables` (on) |
| Field / top-level var, non-obvious type | **DO annotate** | `type_annotate_public_apis` (off; Flutter enables) |
| Field / top-level var, obvious type | may omit (`const screenWidth = 640;`) | — |
| Initialized **local** | **DON'T annotate** | `omit_local_variable_types` (off) |
| Return type of a non-local function | **DO annotate** | `always_declare_return_types` (off; Flutter enables) |
| Parameters of a function declaration | **DO annotate** | — |
| Function **expression** (closure) parameters | **DON'T annotate** | `avoid_types_on_closure_parameters` (off) |
| Initializing formals (`this.x`, `super.key`) | **DON'T annotate** | `type_init_formals` (on) |
| Generic invocation, not inferred | **DO write type args** | — |
| Generic invocation, correctly inferred | **DON'T write type args** | — |
| Raw generic (`List x`) | **never** | — |
| You genuinely want `dynamic` | **DO write `dynamic`** | — |

Key examples:
```dart
// DO annotate uninitialized                    // BAD
List<AstNode> parameters;                        var parameters;
if (node is Constructor) { ... }

// DON'T redundantly annotate initialized locals
var desserts = <List<Ingredient>>[];             List<List<Ingredient>> desserts = <List<Ingredient>>[];
for (final recipe in cookbook) { ... }           for (final List<Ingredient> recipe in cookbook) { ... }

// …UNLESS you need a wider type than the initializer (classic Flutter build method):
Widget build(BuildContext context) {
  Widget result = Text('You won!');              // annotated on purpose
  if (applyPadding) {
    result = Padding(padding: EdgeInsets.all(8.0), child: result);
  }
  return result;
}

// DON'T annotate closure params                 // BAD
var names = people.map((person) => person.name); var names = people.map((Person person) => person.name);

// DON'T annotate initializing formals           // BAD
Point(this.x, this.y);                           Point(double this.x, double this.y);
MyWidget({super.key});                           MyWidget({Key? super.key});

// DO write non-inferred type args               // BAD
var playerScores = <String, int>{};              var playerScores = {};
final events = StreamController<Event>();        final events = StreamController();

// DON'T write inferred ones                     // BAD
final Completer<String> response = Completer();  final Completer<String> response = Completer<String>();
var items = Future.value([1, 2, 3]);             var items = Future<List<int>>.value(<int>[1, 2, 3]);

// AVOID incomplete generics                     // BAD
List<num> numbers = [1, 2, 3];                   List numbers = [1, 2, 3];
var c = Completer<Map<String, int>>();           var completer = Completer<Map>();
```
**Why raw generics are dangerous:** *"Dart will not try to 'fill in' the rest of the type for you using the surrounding context. Instead, it silently fills in any missing type arguments with `dynamic`."*

**Why write `dynamic` explicitly:** *"A casual reader of your code who sees that an annotation is missing has no way of knowing if you intended it to be `dynamic`, expected inference to fill in some other type, or simply forgot."* But it's fine to let inference *propagate* `dynamic` (`var users = json['users'];` where `json` is `Map<String, dynamic>`).

**AVOID `dynamic` unless you want to disable static checking.** Use `Object?` (all values) or `Object` (all but null) instead: *"`dynamic` not only accepts all objects, but it also permits all operations."*

**PREFER full signatures in function type annotations**: `bool Function(String) test`, not bare `Function test`. **PREFER inline function types over typedefs**, and **PREFER function type syntax for parameters**: `Iterable<T> where(bool Function(T) predicate)`, not the C-style `bool predicate(T element)` (lint `use_function_type_syntax_for_parameters`, on by default). **DON'T use the legacy typedef syntax** (`typedef int Comparison<T>(T a, T b);`) — it's deprecated and has the notorious footgun that `typedef bool TestNumber(num);` types the parameter as `dynamic` named `"num"`. **DON'T specify a return type for a setter** (lint `avoid_return_types_on_setters`, on).

---

## 10. Formatting and the formatter — what actually changed recently

### 10.1 DO format your code using `dart format`
*"The official whitespace-handling rules for Dart are **whatever `dart format` produces**."* Everything else in the Formatting section only exists because the formatter can't fix it.

**CONSIDER changing your code to make it more formatter-friendly**: *"If your code has particularly long identifiers, deeply nested expressions… the formatted output may still be hard to read. When that happens, reorganize or simplify your code… Think of `dart format` as a partnership."*
Source: https://dart.dev/effective-dart/style#formatting

### 10.2 The "tall style" switch — **date this one**
`dart_style` **3.0.0** rewrote the formatter. Per its CHANGELOG: *"The formatter uses the language version of the formatted code to determine which style you get. If the language version is 3.6 or lower, the code is formatted with the old style. If 3.7 or later, you get the new tall style."* The language version comes from your pubspec's min SDK constraint.
Source: https://github.com/dart-lang/dart_style/blob/main/CHANGELOG.md

**Consequence: any Flutter formatting advice written before ~Feb 2025 (Dart 3.7) is stale.** In particular, the old folk rule "always add a trailing comma so the formatter explodes the widget tree" **stopped working by default**: `dart format` now *"Adds trailing commas to any argument or parameter list that splits across multiple lines, and removes them from ones that don't."*

### 10.3 `formatter:` config in `analysis_options.yaml` — **verified locally**
```yaml
# analysis_options.yaml
formatter:
  page_width: 100
  trailing_commas: preserve
```
- `page_width` requires language version ≥ **3.7**.
- `trailing_commas: preserve` requires language version ≥ **3.8**.
Source: https://dart.dev/tools/dart-format#configure-the-formatter

**I ran this on the local toolchain (Flutter 3.44.6 / Dart 3.12.2) to be sure.** Same input file, two configs:

```dart
// input
Widget build() {
  return Column(
    children: [Text('a'), Text('b')],
  );
}

// after `dart format`, WITHOUT trailing_commas: preserve
Widget build() {
  return Column(children: [Text('a'), Text('b')]);
}

// after `dart format`, WITH trailing_commas: preserve
Widget build() {
  return Column(
    children: [Text('a'), Text('b')],
  );
}
```

**Recommendation: set `trailing_commas: preserve`.** For a widget-tree-heavy app it restores manual control over line breaks, keeps deep trees readable, and — the underrated part — keeps git diffs one-line-per-change instead of reformatting a whole subtree when you add a child. Flutter's own repo doesn't use `preserve` only because retrofitting it would require *"10,000+ code locations… reformatted by hand"* (see their comment on `require_trailing_commas`, line 204) — that's a migration-cost argument, not a design argument, and it doesn't apply to a greenfield app.

### 10.4 PREFER lines 80 characters or fewer — **and the credible dissent**
Effective Dart: *"Readability studies show that long lines of text are harder to read because your eye has to travel farther… The main offender is usually `VeryLongCamelCaseClassNames`. Ask yourself, 'Does each word in that type name tell me something critical or prevent a name collision?'"* Exceptions: URIs/paths in comments or imports, and multi-line strings.

**flutter/flutter uses `page_width: 100`** and explicitly disables `lines_longer_than_80_chars` with the comment *"not required by flutter style"*. Their style guide: *"Prefer a maximum line length of roughly 100 characters for comments and docs… Line length for code is automatically handled by `dart format`, which is configured to use a maximum line length of 100."*

**Recommendation [opinion]: use `page_width: 100`.** Reason: Flutter widget trees nest 5–8 levels deep before you write any logic; at 80 columns the formatter shreds them into unreadable one-argument-per-line towers. The people who maintain the most Flutter code in the world went to 100 for exactly this reason. Keep 80 for the pure-Dart `rule_engine` package if you like — but consistency across the workspace is worth more than the extra 20 columns, so pick 100 everywhere. Do **not** enable `lines_longer_than_80_chars` (it also fights `page_width`).

### 10.5 DO use curly braces for all flow control statements
Lint: `curly_braces_in_flow_control_structures` (on by default). **Why:** the [dangling else](https://en.wikipedia.org/wiki/Dangling_else) problem.
```dart
// GOOD
if (isWeekDay) { print('Bike to work!'); } else { print('Go dancing or read a book!'); }

// Exception: no else, and the whole statement fits on one line
if (arg == null) return defaultValue;

// But if the body wraps, use braces
if (overflowChars != other.overflowChars) {     // GOOD
  return overflowChars < other.overflowChars;
}
if (overflowChars != other.overflowChars)       // BAD
  return overflowChars < other.overflowChars;
```
Flutter's repo goes further and enables `always_put_control_body_on_new_line`.

---

## 11. Where credible sources genuinely disagree

These are real, current, documented conflicts — not internet noise. In each case I give a recommendation and the reason.

### 11.1 `k` prefix on global constants — **the big one**
| Source | Position |
|---|---|
| Effective Dart, "DON'T use prefix letters" | `kDefaultTimeout` is the *literal bad example*. Rationale: Dart tells you type/scope/mutability, so don't encode them in the name. |
| Flutter repo style guide, "Begin global constant names with prefix 'k'" | `const double kParagraphSpacing = 1.5;` `const String kSaveButtonTitle = 'Save';` |

**Note the escape hatch inside Flutter's own rule**, which almost everyone quoting it omits: *"However, where possible **avoid global constants**. Rather than `kDefaultButtonColor`, consider `Button.defaultColor`. If necessary, consider creating an `abstract final class` to hold relevant constants."*

**Recommendation: follow Effective Dart — no `k` prefix — and take Flutter's own advice to avoid free-floating global constants entirely.** Reasoning: the `k` convention exists in flutter/flutter because that codebase has thousands of file-scope constants in a framework where `import 'package:flutter/material.dart'` dumps an enormous namespace into every file; the prefix is collision-avoidance scar tissue. An application doesn't have that problem. Scope constants to the type they belong to:
```dart
// GOOD (app)                                  // Avoid
abstract final class RulerMetrics {            const double kRulerTickSpacing = 8.0;
  static const double tickSpacing = 8.0;       const int kMaxRuleDepth = 12;
  static const int maxTicks = 400;
}
class RuleEngine {
  static const int maxDepth = 12;
}
```
Note `abstract final class X { static const ... }` is the sanctioned form of the "class of only static members" exception (§8) and is what Flutter's own config calls out.
Because you're not using `k`, leave `constant_identifier_names` **enabled** (it's on by default via `package:lints`) — Flutter's repo disables it precisely because of `k`.

### 11.2 80 vs 100 columns
See §10.4. **Recommendation: 100** (`formatter: page_width: 100`), matching flutter/flutter.

### 11.3 Inline function types vs `typedef` for callbacks
| Source | Position |
|---|---|
| Effective Dart, "PREFER inline function types over typedefs" | *"in most cases, users want to see what the function type actually is right where it's used"* — with the concession *"It may still be worth defining a typedef if the function type is particularly long or frequently used."* |
| Flutter repo style guide | *"Prefer using `typedef`s to declare callbacks. Typedefs benefit from having documentation on the type itself and make it easier to read and find common callsites for the signature."* Also disables `avoid_private_typedef_functions` with *"we prefer having typedef"*. |

**Recommendation: `typedef` for public widget callbacks (`onFoo`), inline function types everywhere else.** The typedef's real advantage is that it's a documentable, greppable, dartdoc-linkable entity — which matters exactly for widget callbacks that appear in many call sites, and not at all for a one-off `bool Function(Rule)` predicate inside the rule engine. This lands on Effective Dart's own stated concession, so it isn't really a violation.

### 11.4 `omit_local_variable_types` vs `omit_obvious_local_variable_types`
Effective Dart says "DON'T redundantly type annotate initialized local variables" and points at `omit_local_variable_types`. flutter/flutter disables that in favour of the newer, narrower **`omit_obvious_local_variable_types`** with the comment *"superset of omit_obvious_local_variable_types"*, and pairs it with `type_annotate_public_apis`. There are also `specify_nonobvious_local_variable_types` / `specify_nonobvious_property_types` in the SDK linter (all four verified to exist).
**Recommendation: `omit_obvious_local_variable_types`.** It removes the noise (`var list = <int>[];`) without forcing you to drop a clarifying annotation on a local whose type comes from a three-call chain — which is common in drift query code.

### 11.5 Getter cost: "O(n) is fine" vs "getters must be O(1)"
See §5. **Recommendation: Flutter's stricter rule**, because of the 1.2 s cold-start budget.

### 11.6 `public_member_api_docs`
Effective Dart says PREFER doc comments for public APIs. flutter/flutter enables the lint only *"on a case-by-case basis"* per-package.
**Recommendation:** enable `public_member_api_docs` **only in `packages/rule_engine`** (the shared, two-consumer package), not in the app. Documenting every `_HomeScreenState` field is busywork; documenting the rule engine's contract is the whole point of extracting it.

---

## 12. Concrete `analysis_options.yaml` for this project

Three packages, three files. `flutter_lints` **6.0.0** was published **2025-05-27** — it is maintained (it's a first-party flutter/packages package and just tracks `package:lints`), but it is *thin*: 10 Flutter rules on top of `package:lints/recommended.yaml`. It leaves most of the Effective Dart rules in this document **unenforced**. Do not treat "no analyzer warnings" as "follows Effective Dart".

### 12.1 App: `analysis_options.yaml`
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true      # enforces "AVOID writing incomplete generic types"
  errors:
    invalid_annotation_target: ignore   # common with freezed/riverpod codegen
  exclude:
    - "**/*.g.dart"             # drift + riverpod codegen
    - "**/*.freezed.dart"
    - "lib/l10n/generated/**"   # gen-l10n output

formatter:
  page_width: 100
  trailing_commas: preserve

linter:
  rules:
    # --- Effective Dart rules that flutter_lints does NOT enable ---
    - directives_ordering                  # §3.1
    - prefer_relative_imports              # §3.3 (do NOT also enable always_use_package_imports)
    - comment_references                   # §6.5
    - omit_obvious_local_variable_types    # §11.4
    - prefer_final_locals                  # §7.2
    - prefer_final_in_for_each
    - always_declare_return_types          # §9
    - type_annotate_public_apis            # §9
    - avoid_positional_boolean_parameters  # §8
    - use_to_and_as_if_applicable          # §4.6
    - avoid_setters_without_getters        # §5
    - use_setters_to_change_properties     # §5
    - avoid_catching_errors                # §7.4
    - avoid_equals_and_hash_code_on_mutable_classes
    - avoid_null_checks_in_equality_operators
    - unnecessary_underscores              # §2.8
    - prefer_mixin
    - sort_constructors_first              # Flutter convention (§ class member order)
    - sort_unnamed_constructors_first
    - unawaited_futures                    # cheap here: no network, so a stray future is a real bug
```
Rules deliberately **not** enabled, with reasons: `lines_longer_than_80_chars` (conflicts with `page_width: 100`), `prefer_expression_function_bodies` (conflicts with "braces for multi-line bodies"), `public_member_api_docs` (app-level noise), `always_use_package_imports` (conflicts with `prefer_relative_imports`), `unnecessary_final` (conflicts with `prefer_final_locals`), `avoid_catches_without_on_clauses` (known false-positive load — enforce in review instead), `unnecessary_lambdas` (known false positives per flutter/flutter's config).

### 12.2 Pure-Dart domain package: `packages/rule_engine/analysis_options.yaml`
```yaml
include: package:lints/recommended.yaml   # NOT flutter_lints — this package must not see Flutter

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

formatter:
  page_width: 100
  trailing_commas: preserve

linter:
  rules:
    - directives_ordering
    - prefer_relative_imports
    - public_member_api_docs        # §11.6 — this is the shared contract, document it
    - comment_references
    - always_declare_return_types
    - type_annotate_public_apis
    - prefer_final_locals
    - prefer_final_in_for_each
    - avoid_positional_boolean_parameters
    - use_to_and_as_if_applicable
    - avoid_catching_errors
    - one_member_abstracts
    - avoid_classes_with_only_static_members
```
And **the enforcement that actually matters:** `packages/rule_engine/pubspec.yaml` must not list `flutter` as a dependency. That makes any `import 'package:flutter/...'` an unresolved-URI analyzer error, backed by `depend_on_referenced_packages` (already in `package:lints/core.yaml`). No lint can do this for you.

### 12.3 CLI content-build tool
Same as 12.2, minus `public_member_api_docs` (it has no external consumers), plus keep `avoid_print` **off** — it's a command-line tool and `print` is its output channel. `avoid_print` comes from `flutter_lints`, so if the tool includes only `package:lints/recommended.yaml` you get this for free.

### 12.4 Generated code
`**/*.g.dart` from drift and riverpod will violate `public_member_api_docs`, `directives_ordering`, `omit_obvious_local_variable_types`, and line-length rules. Exclude them under `analyzer: exclude:` (12.1). Do **not** try to lint generated code into shape.

---

## 13. Advice that is STALE or SUPERSEDED — flag these in review

| Stale advice you'll find online | Status | What's true now |
|---|---|---|
| `SCREAMING_CAPS` for constants (Java habit) | **Superseded.** The Dart team switched away deliberately | `lowerCamelCase`, incl. enum values. Lint `constant_identifier_names`. https://dart.dev/effective-dart/style#prefer-using-lowercamelcase-for-constant-names |
| "Add a trailing comma so the formatter keeps the widget tree expanded" | **Stale since Dart 3.7 / dart_style 3.0.0.** The formatter now adds *and removes* trailing commas | Set `formatter: trailing_commas: preserve` (needs lang version ≥ 3.8). Verified locally, §10.3 |
| "80 columns, always" | **Contested.** Still the dart.dev preference | flutter/flutter uses `page_width: 100` and disables `lines_longer_than_80_chars` |
| `library my_library;` + `part of my_library;` | **Superseded.** Legacy feature, discouraged | Bare `library;` (only for docs/annotations); `part of 'path.dart';`. Lints `unnecessary_library_name`, `use_string_in_part_of_directives` |
| `typedef int Comparison<T>(T a, T b);` | **Deprecated syntax** | `typedef Comparison<T> = int Function(T a, T b);` Lint `prefer_generic_function_type_aliases` |
| `new Foo()` | Deprecated in practice since Dart 2 | Omit `new`. Lint `unnecessary_new` |
| `Future<Null>` / bare `Future` for void-returning async | Superseded once `void` became a valid type argument | `Future<void>` |
| "DO document if your class supports being extended / used as an interface" | **Superseded by Dart 3.0 class modifiers.** The old headings survive only as hidden anchors in design.md | Use `final` / `interface` / `base` / `sealed` class modifiers |
| `__`, `___` for multiple unused callback params | Superseded at Dart 3.7 | Wildcard `_` is non-binding and repeatable: `.onError((_, _) { … })`. Migration lint `unnecessary_underscores` |
| Any pre-Dart-3 guidance on nullable field access using `!` everywhere | Superseded by patterns | Null-check pattern `if (this.response case var response?)` or a `final` local shadow. §7.3 |
| Manual `Predicate` abstract classes, visitor boilerplate written before sealed classes | Superseded | Dart 3 `sealed class` + exhaustive `switch` patterns; `typedef` for one-member callbacks |
| **"Use the new concise constructor syntax (`new _internal(...)`, `factory(...)`)"** | **NOT YET USABLE — see below** | ⚠️ |

### ⚠️ The trap: `PREFER using concise constructor syntax` is documented but not yet available to you
https://dart.dev/effective-dart/usage now contains a guideline **"PREFER using concise constructor syntax"** (lint `unnecessary_type_name_in_constructor`), showing:
```dart
// The guide's "good" example
class Logger {
  final String name;
  factory(String name) => _cache[name] ??= Logger._internal(name);
  new _internal(this.name);
  new fromJson(Map<String, Object?> json) : name = json['name'] as String;
  static final Map<String, Logger> _cache = {};
}
```
with the version note: *"This guideline only applies to libraries with a language version of at least **3.13**."*

**Your toolchain is Dart 3.12.2, and Dart 3.13 is not released.** `dart-lang/sdk`'s `CHANGELOG.md` on `main` lists **"## 3.13.0 — Released on: Unreleased"**, describing primary constructors and the `new`/`factory` in-body forms; 3.14.0 is also "Unreleased" and only `3.14.0-*.dev` tags exist. dart.dev's own site banner currently reads "Supercharge your productivity with Dart 3.12!".

**Action: do not write this syntax.** Keep `Logger._internal(this.name);` and `factory Logger(...)`. Do **not** enable `unnecessary_type_name_in_constructor`. Revisit when the Flutter stable channel ships Dart ≥ 3.13. (Related signal: flutter/flutter's `analysis_options.yaml` carries `# TODO(kallentu): Remove this lint once the Dart SDK in Flutter is on version 3.13.` next to `avoid_final_parameters` — the Flutter repo is also still pre-3.13.)

**Most recent real change to the naming rules:** dart-lang/site-www PR #7322, merged **2026-06-04**, retitled *"AVOID starting a **method** name with `get`"* → *"AVOID starting a **function or method** name with `get`"*, explicitly extending it to top-level functions. Relevant to your `rule_engine` package, which is mostly top-level functions.

---

## 14. Anti-patterns — what NOT to do

Ranked by how often they show up in real Flutter codebases.

1. **`getFoo()` methods.** The single most common violation. If it takes no arguments, it's a getter named `foo`. If it takes arguments, drop `get` and pick a real verb (`load`, `fetch`, `render`, `calculate`) or a noun phrase.
2. **`k`-prefixed constants copied from the Flutter framework.** Framework scar tissue, not app style. Scope constants to a type. (§11.1)
3. **`SCREAMING_CAPS` constants and enum values.** Java muscle memory. The Dart team removed this on purpose.
4. **`SliderMenu.dart` / `slider-menu.dart` file names.** Breaks on case-insensitive filesystems and violates `file_names`.
5. **`import 'package:my_app/x.dart'` and `import '../lib/x.dart'` in the same test.** Dart treats these as two unrelated libraries; you get duplicate class identities and `is` checks that mysteriously fail.
6. **Interleaving `export` between `import`s**, or unsorted import blocks. Turn on `directives_ordering` and stop thinking about it.
7. **Doc comment with no blank line after the first sentence.** Your `dart doc` index becomes a wall of text, because the tool uses the first *paragraph*, not the first sentence.
8. **Doc comments on both the getter and the setter.** `dart doc` silently discards the setter's.
9. **`@param` / `@returns` / `@throws` in Dart doc comments.** Not a thing. Use prose + `[squareBrackets]`.
10. **Documentation you could have written from the name alone.** `/// The background color.` on `final Color backgroundColor;` — delete it or make it say something.
11. **Expensive getters.** `db.allMeasurements` that runs a query. Rename to `loadAllMeasurements()`. In a 1.2 s cold-start budget, a getter that hits disk is a bug in the API, not just in the name.
12. **Caching derived values in the constructor** (`area`, `circumference`) and then mutating the source. This is a correctness bug wearing a performance costume.
13. **`catch (e) { }`** or `catch (e) { throw e; }`. The first swallows `AssertionError` and your asserts vanish; the second resets the stack trace. Use `on X catch (e)` and `rethrow`.
14. **`if (nullableBool == true)`.** Use `?? false` (signals null-handling) or `!= null && b` (also promotes).
15. **`.where((e) => e is Foo).cast<Foo>()`.** Two wrappers, redundant runtime checks. `whereType<Foo>()`.
16. **`people.forEach((p) { ... })`.** Use `for (final p in people)`. Tear-offs (`people.forEach(print)`) are fine.
17. **`Map<String, X>()` / `Set<X>()` constructors** instead of `<String, X>{}` / `<X>{}`.
18. **Raw generics** (`List numbers = [1,2,3];`, `Completer<Map>()`). Silently becomes `dynamic`. Turn on `strict-raw-types`.
19. **Type-annotating closure parameters** (`people.map((Person p) => p.name)`) and initializing formals (`Point(double this.x, ...)`). Both are inferred; the annotation is pure noise.
20. **`return this;` for method chaining.** Use cascades (`..`).
21. **`Utils` / `Helpers` classes of only static members.** *"A type that is never instantiated is a code smell."* Top-level functions, or `abstract final class` if you're genuinely grouping constants.
22. **A one-member abstract class used as a callback interface.** `typedef`.
23. **`bool operator ==(Object? other)`.** The parameter is never null. `Object`.
24. **`abc.filter(...)` / `errors.empty`.** Names that read ambiguously as command-or-question. `where(...)`, `isEmpty`.
25. **Negative boolean names** (`isDisabled`, `isHidden`, `notReady`) forcing `!x` at every call site.
26. **Mixing `var` and `final` on locals with no rule.** Then `var` carries no information at all. Pick one and lint it.
27. **`late` on a field you then need to check "is it set yet?"** — Dart gives you no way to ask. Use a nullable field.
28. **Public `late final` fields with no initializer** — you just published a setter you didn't mean to.
29. **Linting generated code.** Exclude `**/*.g.dart`.
30. **Assuming `flutter_lints` ≈ Effective Dart.** It's 10 Flutter rules on top of `package:lints/recommended.yaml`; roughly half of this document is unenforced by it.

---

## 15. Naming conventions to standardise on for *this* app

Derived from the rules above. Marked **[opinion]** where it's my synthesis rather than a quotable rule.

**Files and directories** (§2.3 — `file_names`, hard rule):
```
lib/
  main.dart
  app.dart
  l10n/app_en.arb, app_ar.arb, app_fr.arb …        # snake_case, locale suffix
  data/
    reference_database.dart      # read-only, asset-shipped
    user_database.dart           # writable
    reference_database.g.dart    # generated, excluded from lint
  features/ruler/ruler_painter.dart, ruler_screen.dart
  features/export/pdf_exporter.dart
packages/rule_engine/lib/
  rule_engine.dart               # the public library (with a library-level doc comment)
  src/rule_evaluator.dart, src/rule_parser.dart
tools/content_build/bin/content_build.dart
```

**Types** [opinion, following §4.10 "most descriptive noun last"]:
`ReferenceDatabase`, `UserDatabase`, `RulerPainter`, `PdfExporter`, `GpsLocator`, `CameraCapture`, `RuleEngine`, `RuleSet`, `RuleResult` — never `DatabaseReference`, `PainterRuler`, `ExporterPdf`.

**Riverpod providers** [opinion — no citable rule exists; `riverpod_lint` 3.1.6 has no provider-naming lint, verified against its 15 rule files]: a provider *is* a value, so it takes a **noun phrase**, and codegen already appends `Provider` (`@riverpod SomeThing someThing(Ref ref)` → `someThingProvider`). So name the annotated function as a noun: `currentMeasurements`, `activeRuleSet`, `preferredLocale` → `currentMeasurementsProvider`, etc. Notifier classes are `UpperCamelCase` nouns: `MeasurementListNotifier`. Never `getMeasurementsProvider` (§4.5).

**drift** [opinion]: table classes are plural nouns (`Measurements`), row classes singular (`Measurement`), DAOs `<Thing>Dao` (`MeasurementDao` — `Dao` is a 3-letter acronym, so word-cased per §2.7, *not* `MeasurementDAO`). Query methods follow §4.4: anything touching disk is a verb — `loadMeasurements()`, `saveMeasurement()`, `deleteMeasurement(id)` — never a getter.

**Booleans** [derived from §4.8]: `isRtl`, `hasCameraPermission`, `canExportPdf`, `shouldShowOnboarding`, `isDatabaseReady`. Never `notRtl`, `noPermission`, `disableExport`.

**Widget callbacks** [Flutter style guide, §4.12]: `typedef MeasurementCallback = void Function(Measurement m);` → property `onMeasure`, handler method `handleMeasure`.

**Golden test files** [opinion, following `file_names`]: `ruler_screen_ar_golden.png`, `ruler_screen_en_golden.png` — locale code in the name, snake_case, so the RTL goldens sort next to their LTR counterparts.

---

## 16. Source index (all verified reachable 2026-07-27)

- https://dart.dev/effective-dart — overview, severity levels, glossary, full rule summary
- https://dart.dev/effective-dart/style
- https://dart.dev/effective-dart/documentation
- https://dart.dev/effective-dart/usage
- https://dart.dev/effective-dart/design
- https://github.com/dart-lang/site-www/tree/main/src/content/effective-dart — markdown source of the four pages
- https://github.com/dart-lang/site-www/pull/7322 — 2026-06-04, `get`-prefix rule broadened to functions
- https://dart.dev/tools/dart-format — `page_width`, `trailing_commas: preserve`
- https://dart.dev/tools/doc-comments/references — what `[brackets]` can reference
- https://dart.dev/tools/linter-rules — canonical rule pages (`/tools/linter-rules/<rule>`)
- https://dart.dev/language/constructors — concise constructor syntax table (Dart 3.13+)
- https://github.com/dart-lang/lints/blob/main/lib/core.yaml and `/lib/recommended.yaml` — `lints` 6.1.0
- https://github.com/flutter/packages/blob/main/packages/flutter_lints/lib/flutter.yaml — `flutter_lints` 6.0.0
- https://github.com/flutter/flutter/blob/master/analysis_options.yaml — the Flutter team's own config
- https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md — the dissenting view
- https://github.com/dart-lang/sdk/blob/main/CHANGELOG.md — Dart 3.13 status ("Unreleased")
- https://github.com/dart-lang/sdk/tree/main/pkg/linter/lib/src/rules — the 268 real lint rule names (used to verify every rule cited above)
- https://github.com/dart-lang/dart_style/blob/main/CHANGELOG.md — tall style / language-version-gated formatting

**Sources deliberately NOT used:** Medium posts, "Top N Flutter tips" listicles, Stack Overflow answers, and any blog. Every rule above traces to dart.dev, a dart-lang/ or flutter/ repository, or a command I ran on this machine.

**Not verified / no evidence found:**
- Whether Flutter stable will pick up Dart 3.13 on a known date — no evidence found; 3.13.0 is marked "Unreleased" in the SDK changelog.
- Any lint that forbids importing `package:flutter` from a pure-Dart package — searched all 268 SDK linter rules; none exists. Use the pubspec-dependency mechanism instead.
- A canonical Riverpod provider-naming rule from the Riverpod maintainer — `riverpod_lint` 3.1.6 ships no such lint; §15's provider naming is my derivation from Effective Dart, marked as opinion.
