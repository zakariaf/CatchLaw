# Flutter Testing — Build Guide

**Research date:** 2026-07-27
**Target toolchain:** Flutter 3.44.6 stable (2026-07-08), Dart 3.x
**Target app:** 100% offline Android+iOS app; drift ×2 (read-only asset DB + writable user DB); flutter_riverpod; 6 locales incl. Arabic/RTL; pure-Dart domain package shared with a CLI tool; custom painting, SVG, PDF, camera, GPS, a11y, goldens across locales.

Everything below was read from primary sources. Every URL in this document was fetched or resolved during research. Where I could not verify something I say so explicitly.

---

## 0. TL;DR verdicts (read this if you read nothing else)

| Question | Verdict |
|---|---|
| Test naming style? | **Plain declarative sentence describing the behaviour**, subject first. NOT `should X when Y`. NOT given/when/then. This is what the Flutter team mandates in writing and what their 6000+ test files actually do. |
| `golden_toolkit`? | **DEAD. Do not use.** Marked *discontinued* on pub.dev, last publish 2023-02-21, SDK constraint `>=2.18.4 <3.0.0` — it literally cannot resolve on Dart 3. |
| `alchemist`? | Alive but slow-moving (0.14.0, 2026-03-13). Good for LTR component grids. **Bad fit for your Arabic goldens** — its CI mode replaces glyphs with blocks. |
| Golden tooling for 2026? | **Flutter's built-in `matchesGoldenFile` + your own ~60-line harness.** That is my recommendation for this app. |
| `mocktail` vs `mockito`? | **mocktail.** No codegen, no `build_runner` in your test loop. Both are maintained. |
| `integration_test`? | Ships **inside the Flutter SDK**. The pub.dev package (1.0.2+3, 2021) is a stale corpse — never depend on it by version. |
| `patrol`? | Very active (4.8.0, 2026-07-24). Only worth it if you need **native** UI (permission dialogs). Your app needs camera + GPS permissions, so it is a *maybe*. |
| Coverage target? | 100% of the pure-Dart domain package. ~80% line coverage for `lib/` excluding generated files. Do not chase 100% app-wide. |

---

## 1. The pyramid, per the official docs

Flutter's own definitions ([docs.flutter.dev/testing/overview](https://docs.flutter.dev/testing/overview)):

> A *unit test* tests a single function, method, or class. The goal of a unit test is to verify the correctness of a unit of logic under a variety of conditions.

> A *widget test* (in other UI frameworks referred to as *component test*) tests a single widget. The goal of a widget test is to verify that the widget's UI looks and interacts as expected.

> An *integration test* tests a complete app or a large part of an app. The goal of an integration test is to verify that all the widgets and services being tested work together as expected.

Their trade-off table, verbatim:

| Tradeoff | Unit | Widget | Integration |
|---|---|---|---|
| Confidence | Low | Higher | Highest |
| Maintenance cost | Low | Higher | Highest |
| Dependencies | Few | More | Most |
| Execution speed | Quick | Quick | Slow |

**Source:** https://docs.flutter.dev/testing/overview

### My budget for this app

Because the app is offline, there is no network flakiness — which means the classic argument for a fat integration-test layer (does the API contract hold?) does not apply. Push weight *down* the pyramid:

| Layer | What | Rough count | Runs where |
|---|---|---|---|
| Pure-Dart unit | Rule engine domain package | **The bulk.** Aim 100% branch coverage. | `dart test` — milliseconds, no Flutter |
| Drift unit | Queries + migrations, `NativeDatabase.memory()` | One file per DAO + one migration test per schema version | `flutter test` |
| Riverpod unit | Notifiers/providers via `ProviderContainer.test()` | One per provider with real logic | `flutter test` |
| Widget | Screens + the custom-painted ruler | One per screen, plus `paints` matcher tests for the painter | `flutter test` |
| Golden | Key screens × 6 locales × 2 themes | Keep the *matrix* small: 4–6 screens, not 40 | `flutter test --tags golden`, **Linux CI only** |
| Integration | 2–4 happy-path flows incl. real drift file I/O, PDF export, camera stub | Handful | Device/emulator |

---

## 2. HOW TO NAME TESTS — with receipts

This is the section you asked about most, so it is the longest.

### 2.1 The rule, stated by the Flutter team

From `docs/contributing/testing/Writing-Effective-Tests.md` in flutter/flutter, verbatim:

> ## Name tests based on the behavior being tested
>
> It is common to find tests that are simply named after the object under test rather than the behavior under test. For example, a developer might find tests that look like the following:
>
> ```dart
> // Bad test name
> test('ListView', () {...});
>
> // Bad test name
> test('RenderViewport', () {...});
> ```
>
> The above test names do not communicate anything useful to the developer reading the tests. The developer probably already knows which object is being tested, so these names are no better than an empty string. Instead, each test should succinctly declare the behavior under test and/or the expected results:
>
> ```dart
> // Better test name
> test('Shrink-wrapped ListView resizes to match its content height', () {...});
>
> // Better test name
> test('RenderViewport applies its offset to all child Slivers', () {...});
> ```

**Source:** https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Writing-Effective-Tests.md

Note the shape: **`<Subject> <verb in simple present> <object/condition>`**. No "should". No "it". No "given/when/then". Present-tense indicative, as if stating a fact about the system.

The same doc gives two more rules:

> ## One behavior per test
> Don't test multiple behaviors in a single test. When multiple behaviors exist within a test then reported test failures become misleading.

> ## Only include relevant details in a test
> Including irrelevant details in a test can only confuse the issue in the mind of the developer reading the test.

Their own worked example of splitting a multi-behaviour test shows the naming pattern for error cases:

```dart
test('SliverGeometry with no arguments is valid', () {
  expect(const SliverGeometry().debugAssertIsValid(), isTrue);
});

test('SliverGeometry throws error when layoutExtent exceeds paintExtent', () {
  expect(() {
    const SliverGeometry(layoutExtent: 10.0, paintExtent: 9.0).debugAssertIsValid();
  }, throwsFlutterError);
});
```

So: `throws error when <condition>` for negative cases. "when" is fine as a *condition* clause; it is "should" that is absent.

### 2.2 What they ACTUALLY do — real names from flutter/flutter

Extracted from `packages/flutter/test/material/app_bar_test.dart` (real, verbatim descriptions):

```
'AppBar centers title on iOS'
'AppBar centerTitle:true centers on Android'
'AppBar centerTitle:false title start edge is 16.0 (LTR)'
'AppBar centerTitle:false title start edge is 16.0 (RTL)'
'AppBar titleSpacing:32 title start edge is 32.0 (LTR)'
'AppBar drawer icon has default size'
'Material3 - AppBar drawer icon has default color'
'AppBar does not update the leading if a route is popped case 1'
'AppBar respects toolbarHeight'
"AppBar with EndDrawer doesn't have leading"
'AppBar.titleSpacing defaults to NavigationToolbar.kMiddleSpacing'
'Leading, title, and actions show correct default colors'
```

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter/test/material/app_bar_test.dart

Observations, all directly load-bearing for your convention:

1. **Subject-first.** Every name starts with the class or member under test: `AppBar`, `AppBar.titleSpacing`, `Checkbox`.
2. **Simple present, third person.** `centers`, `has`, `respects`, `defaults to`, `does not update`. Zero occurrences of `should`.
3. **Condition encoded inline with real values.** `centerTitle:false`, `titleSpacing:32`, `(LTR)` / `(RTL)`. Not prose — the actual argument syntax. This is a genuinely good idea: `grep` for `titleSpacing` finds every test about it.
4. **Variant prefixes for cross-cutting axes.** `Material3 - ` / `Material2 - ` prefixes. Your equivalent would be `RTL - ` or `ar - `.
5. Names are long. `'AppBar positioning of leading and trailing widgets with top padding'` is 66 chars and nobody minds.

From `packages/flutter/test/material/checkbox_test.dart`:

```
'Checkbox size is configurable by ThemeData.materialTapTargetSize'
'Checkbox semantics'
```

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter/test/material/checkbox_test.dart

(`'Checkbox semantics'` is a violation of their own rule — proof that the codebase is not perfectly consistent. Follow the doc, not the worst example.)

### 2.3 `group()` usage in flutter/flutter

Groups are used **sparingly** and only when a real cluster exists. From `app_bar_test.dart`:

```dart
group('Material3 - Icons are colored correctly by IconTheme and ActionIconTheme', () { ... });
group('WidgetStateColor scrolledUnder', () { ... });
```

Most of that 2500-line file is **top-level `testWidgets` with no group at all**. Nesting is at most 1 level. There is no "describe the class / describe the method / it does X" ceremony.

A Flutter idiom worth stealing — `group()` accepts any `Object`, so you can pass a `Type`:

```dart
group(CalendarDatePicker, () {
  // ...
});
```

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter_localizations/test/material/date_picker_test.dart

This is refactor-safe: rename the class, the group name follows.

### 2.4 What the Dart team does — the group-concatenation convention

`package:test`'s own README shows a different, equally official style that exploits the fact that **group descriptions are prefixed onto test descriptions**:

```dart
void main() {
  group('String', () {
    test('.split() splits the string on the delimiter', () {
      var string = 'foo,bar,baz';
      expect(string.split(','), equals(['foo', 'bar', 'baz']));
    });

    test('.trim() removes surrounding whitespace', () {
      var string = '  foo ';
      expect(string.trim(), equals('foo'));
    });
  });
}
```

**Source:** https://github.com/dart-lang/test/blob/master/pkgs/test/README.md

The reported name is `String .split() splits the string on the delimiter` — a complete sentence assembled from group + test. That is the design intent of `group()`: **the concatenation must read as a sentence.**

Confirmed in real dart-lang code, `pkgs/collection/test/equality_test.dart`:

```dart
test('IterableEquality - List', () { ... });
test('ListInequality length', () { ... });
group('DeepEquality', () {
  group('unordered', () {
    test('with identical collection types', () { ... });
    test('comparing collections and iterables', () { ... });
  });
  group('ordered', () {
    test('with identical collection types', () { ... });
  });
});
group('EqualityBy should use a derived value for ', () {
  test('equality', () { ... });
  test('hash', () { ... });
});
```

**Source:** https://github.com/dart-lang/core/blob/main/pkgs/collection/test/equality_test.dart

Note `'EqualityBy should use a derived value for '` + `'equality'` → `EqualityBy should use a derived value for equality`. The one "should" in the corpus lives in a *group* prefix, not a test name — and it still reads as one sentence.

### 2.5 Where compass_app disagrees (and why I'd ignore it)

`flutter/samples/compass_app` is the reference implementation for Flutter's official app-architecture guide, and it uses the `should X` style:

```dart
group('ResultsViewModel tests', () {
  test('should load items', () async {
    expect(viewModel.destinations.length, 2);
  });
});
```

```dart
group('LoginScreen test', () {
  testWidgets('should load screen', (WidgetTester tester) async { ... });
  testWidgets('should perform login', (WidgetTester tester) async { ... });
});
```

**Sources:**
https://github.com/flutter/samples/blob/main/compass_app/app/test/ui/results/results_viewmodel_test.dart
https://github.com/flutter/samples/blob/main/compass_app/app/test/ui/auth/login_screen_test.dart

**This is a genuine disagreement between two official Flutter properties.** My call: **follow flutter/flutter, not compass_app.**

Reasoning:
- compass_app's names are worse *on their own terms*. `'should load items'` does not say which items, from where, or under what condition. `'ResultsViewModel tests should load items'` — the word "tests" in the group name is pure noise; `group('X tests')` is exactly the "named after the object under test" anti-pattern that `Writing-Effective-Tests.md` explicitly calls bad.
- `should` costs 7 characters × every test and adds zero information. Every test asserts something *should* happen; that's what a test is.
- flutter/flutter's convention is backed by a written, maintained, normative document. compass_app's is backed by nobody writing it down.
- Declarative names double as documentation. `flutter test --plain-name "RTL"` over declarative names gives you a readable spec; over `should` names it gives you a to-do list.

### 2.6 The convention I recommend for this app

**Rule:** `test('<Subject> <present-tense verb phrase> [when/with <condition>]')`, subject-first, no `should`, no `it`, no given/when/then. One behaviour per test. Encode literal argument values in the name.

**Groups:** use a group only when ≥3 tests share a real axis, and make `group + test` read as one sentence. Max one level of nesting. Never `group('<Thing> tests')`.

**Variant prefixes** for cross-cutting axes, using the flutter/flutter `'<Axis> - '` form.

Applied to your app:

```dart
// test/domain/ruler_scale_test.dart  (pure Dart — package:test)
void main() {
  group('RulerScale', () {
    test('.tickCount returns 10 ticks per centimetre at 1.0 zoom', () { ... });
    test('.tickCount clamps to 1 tick per centimetre below 0.1 zoom', () { ... });
    test('.labelFor throws RangeError when index is negative', () { ... });
  });
}

// test/data/measurement_dao_test.dart
void main() {
  test('MeasurementDao.insert assigns an autoincrement id', () async { ... });
  test('MeasurementDao.watchAll emits again after an insert', () async { ... });
  test('MeasurementDao.deleteAll leaves the reference database untouched', () async { ... });
}

// test/ui/measure/measure_screen_test.dart
void main() {
  testWidgets('MeasureScreen shows the empty state when no measurements exist', (tester) async { ... });
  testWidgets('MeasureScreen shows a metric unit label for locale en', (tester) async { ... });
  testWidgets('RTL - MeasureScreen places the ruler on the right edge', (tester) async { ... });
  testWidgets('MeasureScreen meets androidTapTargetGuideline', (tester) async { ... });
}

// test/ui/measure/measure_screen_golden_test.dart
void main() {
  for (final locale in kSupportedLocales) {
    testWidgets('MeasureScreen renders correctly for locale ${locale.languageCode}', (tester) async { ... });
  }
}
```

For loop-generated tests, **always interpolate the parameter into the description** — otherwise you get N identically-named tests and `--plain-name` becomes useless. flutter/flutter does exactly this:

```dart
for (final Locale locale in testLocales.keys) {
  testWidgets('shows dates for $locale', (WidgetTester tester) async { ... });
}
```

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter_localizations/test/material/date_picker_test.dart

---

## 3. Test FILE organisation

### 3.1 The `_test.dart` suffix is a hard requirement

> To automatically find all files named `*_test.dart` inside a package's `test/` subdirectory, and run them inside the headless flutter shell as a test, use the `flutter test` command

**Source:** https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Running-and-writing-tests.md

`package:test` states the same and adds the escape hatch:

> the runner will recursively search the directory for files that match the test name pattern `*_test.dart`. The pattern can be overridden in `dart_test.yaml`. **When a path argument is a file instead of a directory it will be run as a test, regardless of the file name.**

**Source:** https://github.com/dart-lang/test/blob/master/pkgs/test/README.md

Practical consequence: **a helper file must NOT end in `_test.dart`**, or the runner will execute it as a suite with no tests and fail. Name helpers `test_app.dart`, `fakes.dart`, `golden_harness.dart`.

### 3.2 Mirror `lib/` in `test/` — this is what the official sample does

compass_app, verbatim tree:

```
compass_app/app/
  lib/
    data/repositories/booking/booking_repository.dart
    domain/use_cases/booking/booking_create_use_case.dart
    ui/results/view_models/results_viewmodel.dart
  test/
    data/repositories/booking/booking_repository_remote_test.dart
    domain/use_cases/booking/booking_create_use_case_test.dart
    ui/results/results_viewmodel_test.dart
    ui/results/results_screen_test.dart
    utils/command_test.dart
  testing/                     <-- NOT under test/
    app.dart
    mocks.dart
    fakes/repositories/fake_booking_repository.dart
    fakes/services/fake_api_client.dart
    models/booking.dart        <-- fixture constants
    utils/result.dart
  integration_test/
    app_local_data_test.dart
```

**Source:** https://github.com/flutter/samples/tree/main/compass_app/app

**The `testing/` directory is the single most copyable idea here.** It sits beside `lib/`, `test/` and `integration_test/`, so it can be imported by *both* `test/` and `integration_test/` while never being compiled into the shipped app (it is outside `lib/`). Test files reach it with relative imports: `import '../../../testing/fakes/repositories/fake_destination_repository.dart';`

### 3.3 Split large test files

Official guidance, verbatim:

> Organize tests into smaller, focused files grouped by feature, widget, or behavior, rather than creating large files with many unrelated test cases.
>
> Instead of keeping everything in a single file like:
> - `button_test.dart`
>
> that includes layout, semantics, and interaction tests, it can be split into:
> - `button_layout_test.dart`
> - `button_semantics_test.dart`
> - `button_interaction_test.dart`

**Source:** https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Running-and-writing-tests.md

### 3.4 Recommended layout for THIS app

```
packages/rule_engine/            # pure Dart, no flutter imports
  lib/
  test/
    evaluator_test.dart
    parser_test.dart
    fixtures/                    # .json / .txt inputs, NOT dart
      sample_rules.json
  dart_test.yaml

app/
  lib/
  assets/db/reference.sqlite     # pre-seeded read-only DB
  test/
    flutter_test_config.dart     # ← fonts + golden config, see §8.2
    data/
      reference_dao_test.dart
      user_dao_test.dart
      migrations/
        schema_test.dart
        generated/               # drift_dev schema generate output
    ui/
      measure/
        measure_screen_test.dart
        measure_screen_golden_test.dart
        goldens/                 # ← beside the test file (see §8.1)
          measure_screen.en.png
          measure_screen.ar.png
      widgets/
        ruler_painter_test.dart
  testing/                       # shared with integration_test/
    harness.dart                 # pumpApp(), pumpLocalised()
    golden.dart                  # goldenName(), font loading
    fakes/
      fake_camera.dart
      fake_location.dart
    fixtures/
      measurements.dart          # const test data
  integration_test/
    measure_flow_test.dart
    pdf_export_test.dart
```

**Golden files live next to the test file.** This is not a style choice — it is enforced by the framework:

> When using `flutter test`, a comparator implemented by `LocalFileComparator` is used if no other comparator is specified. **It treats the golden key as a relative path from the test file's directory.**

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/goldens.dart

Add to `.gitignore`:
```
**/failures/
```
`LocalFileComparator` writes diff/isolated/masterImage PNGs into a `failures/` folder beside the golden on mismatch.

### 3.5 `flutter_test_config.dart` — directory-scoped setup

Undersold and extremely useful. The framework scans **up** from the test file:

> Before a test file is executed, the Flutter test framework will scan up the directory hierarchy, starting from the directory in which the test file resides, looking for a file named `flutter_test_config.dart`. If it finds such a configuration file, the file will be assumed to have a `main` method with the following signature:
>
> ```dart
> Future<void> testExecutable(FutureOr<void> Function() testMain) async { }
> ```
>
> After the test framework finds a configuration file, it will stop scanning the directory hierarchy... Likewise, it will stop scanning the directory hierarchy when it finds a `pubspec.yaml`, since that signals the root of the project.

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/flutter_test.dart
**Implementation:** https://github.com/flutter/flutter/blob/master/packages/flutter_tools/lib/src/test/test_config.dart

Use it for: loading fonts once for all goldens, installing a tolerant golden comparator, setting `LeakTesting.settings`.

---

## 4. `flutter_test` essentials you will actually use

### 4.1 `pump()` vs `pumpAndSettle()`

From the official cookbook:

- **`tester.pump(Duration duration)`** — schedules one frame and rebuilds. With a `Duration`, advances the clock and schedules **a single** frame (not one frame per elapsed frame-interval). To *start* an animation you must `pump()` once with no duration to kick the ticker.
- **`tester.pumpAndSettle()`** — repeatedly pumps until no frames are scheduled.

> **Warning**: Can hang if animations never complete or if widgets continuously schedule new frames (e.g., infinite animations or widgets that rebuild indefinitely).

**Source:** https://docs.flutter.dev/cookbook/testing/widget/introduction

**Opinion:** `pumpAndSettle()` is a footgun in a custom-painting app. Your ruler will likely have a repeating/scroll animation. If any widget on screen schedules frames forever, `pumpAndSettle()` deadlocks until the 10-minute test timeout. Prefer explicit `await tester.pump(const Duration(milliseconds: 300))`. Reserve `pumpAndSettle()` for navigation transitions where you genuinely don't know the duration.

### 4.2 Matchers

| Matcher | Purpose |
|---|---|
| `findsOneWidget` | exactly one |
| `findsNothing` | none |
| `findsWidgets` | one or more |
| `findsNWidgets(n)` | exactly n |
| `matchesGoldenFile(path)` | rendering matches golden bitmap |

**Source:** https://docs.flutter.dev/cookbook/testing/widget/introduction

### 4.3 Controlling the test view — deterministic sizing

Verified API on `TestFlutterView` / `TestPlatformDispatcher`:

```dart
tester.view.physicalSize = const Size(1080, 1920);
tester.view.devicePixelRatio = 3.0;
addTearDown(tester.view.reset);                    // ← ALWAYS

tester.platformDispatcher.localeTestValue = const Locale('ar');
tester.platformDispatcher.textScaleFactorTestValue = 2.0;
tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures();
addTearDown(tester.platformDispatcher.clearAllTestValues);
```

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/window.dart (`class TestFlutterView` L1008, `set physicalSize` L1127, `void reset()` L1291; `class TestPlatformDispatcher` L179, `set localeTestValue` L285)

`binding.setSurfaceSize` also exists but the framework itself flags it:

> To avoid affecting other tests by leaking state, a test that uses this method should always reset the surface size to the default. For example, using `addTearDown`:
> ```dart
>   await binding.setSurfaceSize(someSize);
>   addTearDown(() => binding.setSurfaceSize(null));
> ```
> ... Instead of this method, consider setting `TestFlutterView.physicalSize`, which works for any view.
>
> `// TODO(pdblasi-google): Deprecate this.`

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/binding.dart (L1444–1467)

**Verdict: use `tester.view.physicalSize`, not `setSurfaceSize`.** compass_app's `testing/app.dart` uses `setSurfaceSize`; it is on a deprecation path.

---

## 5. Testing the pure-Dart domain package (the rule engine)

**WHAT:** Give the domain package its own `test/` and run it with `dart test`, never `flutter test`.

**WHY:** It is the highest-value, cheapest-to-run tier. `dart test` starts in ~200 ms with no Flutter shell. It also *enforces* the no-Flutter-imports constraint: if someone sneaks in `package:flutter/...`, `dart test` fails to compile. That's a free architectural lint. And the same suite guards the CLI content-build tool.

**EXAMPLE** — `packages/rule_engine/dart_test.yaml`:

```yaml
# Whole-package config. Applies to `dart test` in this package.
platforms: [vm]
concurrency: 8

tags:
  golden:
    skip: "goldens live in the app package, not here"
  slow:
    timeout: 2x
```

`dart_test.yaml` is the official whole-package configuration file:

> For configuration that applies across multiple files, or even the entire package, `test` supports a configuration file called `dart_test.yaml`.

**Source:** https://github.com/dart-lang/test/blob/master/pkgs/test/README.md

**Fixtures:** put non-Dart inputs in `test/fixtures/` and read them with `dart:io` — in a pure-Dart package there is no `rootBundle`. Resolve relative to the package root (the test runner's cwd is the package root):

```dart
final rules = File('test/fixtures/sample_rules.json').readAsStringSync();
```

**Tagging + filtering** (verbatim from the same README):

```dart
@Tags(['slow'])

import 'package:test/test.dart';

void main() {
  test('evaluates the full 5000-rule corpus', () { ... }, tags: 'slow');
}
```

> The `--tags` or `-t` flag will cause the test runner to only run tests with the given tags, and the `--exclude-tags` or `-x` flag will cause it to only run tests *without* the given tags. These flags also support boolean selector syntax. For example, you can pass `--tags "(chrome || firefox) && !slow"`.

> If the test runner encounters a tag that wasn't declared in the package configuration file, it'll print a warning, so be sure to include all your tags there.

**Source:** https://github.com/dart-lang/test/blob/master/pkgs/test/README.md

**Golden rule for the domain package:** because it has no I/O, no clock, no randomness that you don't inject, you can and should hit **100% branch coverage**. Nothing else in the app deserves that target.

---

## 6. Testing drift

### 6.1 In-memory databases

**WHAT:** Make the `QueryExecutor` an explicit constructor parameter; in tests pass `NativeDatabase.memory()`.

**WHY (from the drift docs, verbatim):** "The only important change from a regular drift database is the constructor: We make the `QueryExecutor` argument explicit instead of having a no-args constructor that passes a fixed executor." That's what makes the database testable at all without a device.

**EXAMPLE** — the official drift snippet, verbatim:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';
import 'database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        // Recommended for widget tests to avoid test errors.
        closeStreamsSynchronously: true,
      ),
    );
  });
  tearDown(() async {
    await database.close();
  });
}
```

**Source:** https://github.com/simolus3/drift/blob/develop/docs/lib/src/snippets/setup/testing.dart

The `closeStreamsSynchronously: true` bit is load-bearing and easy to miss. Drift's own note:

> By default, unsubscribing from a query stream created by drift will keep the stream open for one event loop iteration... In Flutter widget tests however, it's illegal to keep these timers open after a test concludes. To avoid issues with Drift in that setups, pass a `DatabaseConnection` with `closeStreamsSynchronously: true` to your database.

**Source:** https://github.com/simolus3/drift/blob/develop/docs/content/testing.md

Their example tests (verbatim), and note the naming — plain declarative, matching flutter/flutter:

```dart
test('users can be created', () async {
  final id = await database.createUser('some user');
  final user = await database.watchUserWithId(id).first;

  expect(user.name, 'some user');
});

test('stream emits a new user when the name updates', () async {
  final id = await database.createUser('first name');

  final expectation = expectLater(
    database.watchUserWithId(id).map((user) => user.name),
    emitsInOrder(['first name', 'changed name']),
  );

  await database.updateName(id, 'changed name');
  await expectation;
});
```

**Source:** https://drift.simonbinder.eu/testing/

### 6.2 Migration tests — mandatory for the writable user DB

**WHAT:** Export each schema version with `drift_dev schema dump`, generate verifier code, then assert every upgrade path.

**WHY:** Your user DB will migrate on real devices with real user data. A silently-wrong `onUpgrade` is unrecoverable data loss for an offline app with no server-side backup. This is the single highest-risk code path in the whole product.

**EXAMPLE** — drift's official snippet, verbatim:

```dart
import 'package:test/test.dart';
import 'package:drift_dev/api/migrations_native.dart';

// The generated directory from before.
import 'generated_migrations/schema.dart';

import '../migrations.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    // GeneratedHelper() was generated by drift, the verifier is an api
    // provided by drift_dev.
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('upgrade from v1 to v2', () async {
    // Use startAt(1) to obtain a database connection with all tables
    // from the v1 schema.
    final connection = await verifier.startAt(1);
    final db = MyDatabase(connection);

    // Use this to run a migration to v2 and then validate that the
    // database has the expected schema.
    await verifier.migrateAndValidate(db, 2);
  });
}
```

Generate with:
```
dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
```

And for data-integrity checks across a migration:
```
dart run drift_dev schema generate --data-classes --companions drift_schemas/ test/generated_migrations/
```

**Source:** https://github.com/simolus3/drift/blob/develop/docs/content/migrations/tests.md

Drift also notes: *"If you are using the `make-migrations` command, tests are already generated for you."*

### 6.3 The read-only asset DB

The reference DB ships as a Flutter asset. In `flutter test`, assets **are** available — the tool builds the asset bundle by default:

```
--test-assets    (defaults to on)
  Whether to build the assets bundle for testing.
  This takes additional time before running the tests.
  Consider using "--no-test-assets" if assets are not required.
```

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter_tools/lib/src/commands/test.dart

So `rootBundle.load('assets/db/reference.sqlite')` works in a widget test. Pattern: copy the asset bytes to a temp file in `setUpAll`, open with `NativeDatabase(File(...))`, and assert it is genuinely read-only (an insert throws). Note this test can only run under `flutter test`, not `dart test` — put it in `app/test/`, not in the domain package.

*Unverified:* I did not find an official drift doc page specifically about shipping a pre-seeded DB as a Flutter asset and testing it; the asset-availability claim above is verified from the flutter_tools source, the drift half is inference from `NativeDatabase`'s documented file constructor.

### 6.4 Deterministic time

If any SQL uses `CURRENT_TIMESTAMP` or `datetime('now')`, Dart's `withClock` will not affect it — SQLite is a C library. Drift's answer:

> For tests, the prebuilt `TestSqliteFileSystem` from the `sqlite3_test` package can be used to observe clocks installed by `withClock` (including widget tests). The file system should be configured in `setUpAll`, and can be unregistered in `tearDownAll`. Each test file using this should register the VFS under a unique name, since different tests might run in parallel in the same process.

**Source:** https://github.com/simolus3/drift/blob/develop/docs/content/testing.md

Simpler alternative for a new app: **never use SQL time functions.** Compute timestamps in Dart with an injected `Clock`. Then this whole problem evaporates.

---

## 7. Testing Riverpod

**Versions verified 2026-07-27:** `flutter_riverpod` **3.4.1** (published 2026-07-26, sdk `^3.12.0`), `riverpod` 3.4.1, `riverpod_generator` 4.0.6. Riverpod 3.0.0 stable landed 2025-09-10.

### 7.1 Unit-testing a provider — `ProviderContainer.test()`

**WHAT:** Use `ProviderContainer.test()`. Do not hand-roll a `createContainer` helper.

**WHY:** It is the purpose-built constructor that registers its own `addTearDown` disposal, added in 3.0.0 explicitly *"to replace the `createContainer` utility"* (riverpod CHANGELOG). Anything you'll find in a 2022–2024 blog post using a manual `createContainer` + `addTearDown(container.dispose)` is **superseded**.

**EXAMPLE** — official docs snippet, verbatim:

```dart
void main() {
  test('Some description', () {
    // Create a ProviderContainer for this test.
    // DO NOT share ProviderContainers between tests.
    final container = ProviderContainer.test();

    expect(
      container.read(provider),
      equals('some value'),
    );
  });
}
```

**Source:** https://github.com/rrousselGit/riverpod/blob/master/website/docs/how_to/testing/unit_test.dart
**Prose:** https://riverpod.dev/docs/how_to/testing

### 7.2 The autoDispose trap

Straight from the docs (verbatim caution block):

> Be careful when using `container.read` when providers are automatically disposed. If your provider is not listened to, chances are that its state will get destroyed in the middle of your test.
>
> In that case, consider using `container.listen`. Its return value enables reading the current value of provider anyway, but will also ensure that the provider is not disposed in the middle of your test.

**Source:** https://riverpod.dev/docs/how_to/testing

This bites hard and produces baffling flakes. Rule: **if the provider is autoDispose, `container.listen(...)` first, then read.**

### 7.3 Async providers

```dart
await expectLater(
  // We read "provider.future" instead of "provider".
  container.read(provider.future),
  completion('some value'),
);
```

**Source:** https://github.com/rrousselGit/riverpod/blob/master/website/docs/how_to/testing/await_future.dart

### 7.4 Widget tests with Riverpod

```dart
testWidgets('Some description', (tester) async {
  await tester.pumpWidget(
    const ProviderScope(child: YourWidgetYouWantToTest()),
  );

  final container = tester.container();   // ← flutter_riverpod 3.0.0-dev.16+

  expect(container.read(provider), 'some value');
});
```

**Source:** https://github.com/rrousselGit/riverpod/blob/master/website/docs/how_to/testing/full_widget_test.dart
`tester.container()` was added per the flutter_riverpod CHANGELOG ("Added widget test helper to find a `ProviderContainer` in the widget tree: `tester.container()`").

### 7.5 Overrides

```dart
final container = ProviderContainer.test(
  overrides: [
    exampleProvider.overrideWith((ref) => 'Hello from tests'),
  ],
);

await tester.pumpWidget(
  ProviderScope(
    overrides: [
      exampleProvider.overrideWith((ref) => 'Hello from tests'),
    ],
    child: const YourWidgetYouWantToTest(),
  ),
);
```

**Source:** https://github.com/rrousselGit/riverpod/blob/master/website/docs/how_to/testing/mock_provider.dart

### 7.6 DON'T mock Notifiers

Verbatim from the maintainer's docs:

> It is generally discouraged to mock Notifiers. This is because Notifiers cannot be instantiated on their own, and only work when used as part of a Provider.
>
> Instead, you should likely introduce a level of abstraction in the logic of your Notifier, such that you can mock that abstraction. For instance, rather than mocking a Notifier, you could mock a "repository" that the Notifier uses to fetch data from.
>
> If you insist on mocking a Notifier... Your mock must subclass the original Notifier base class: You cannot "implement" Notifier, as this would break the interface.

**Source:** https://riverpod.dev/docs/how_to/testing

**Applied to this app:** override the *drift DAO provider* with a fake, and let the real Notifier run. This gives you the Notifier's actual state machine under test — much higher value than a mocked shell. `NotifierProvider.overrideWithBuild` (added in 3.0.0) lets you override just `build()` without touching the methods.

### 7.7 Spying

```dart
container.listen<String>(
  provider,
  (previous, next) {
    print('The provider changed from $previous to $next');
  },
);
```

> You can then combine this with packages such as mockito or mocktail to use their `verify` API. Or more simply, you can add all changes in a list and assert on it.

**Source:** https://riverpod.dev/docs/how_to/testing

**Opinion:** just append to a `List` and `expect(states, [...])`. It reads better than `verify()` chains and the failure output is far more useful.

---

## 8. Golden tests

### 8.1 How `matchesGoldenFile` actually works

```dart
AsyncMatcher matchesGoldenFile(Object key, {int? version})
```

Verified facts from the framework source:

- Accepts a `Finder`, a `Future<ui.Image>`, or a `ui.Image`. For a `Finder`: *"the Finder must match exactly one widget and the rendered image of the first `RepaintBoundary` ancestor of the widget is treated as the image for the widget. As such, you may choose to wrap a test widget in a `RepaintBoundary` to specify a particular focus for the test."*
- The `key` is a `Uri` or `String`; `LocalFileComparator` *"treats the golden key as a relative path from the test file's directory"*, then does a **pixel-for-pixel comparison, returning true only if there's an exact match.**
- It is asynchronous — **you must `await expectLater(...)`**, not `expect(...)`.
- `flutter test --update-goldens` writes/overwrites the files.
- Under `flutter run` the default comparator is `TrivialComparator`, which prints a message and does nothing.

**Sources:**
https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html
https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/matchers.dart (L470–594)
https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/goldens.dart

Flutter's own naming convention for golden **files** (from their contributing doc):

> The argument to `matchesGoldenFile` is the filename for the screenshot. The part up to the first dot should exactly match the test filename (e.g. if your test is `widgets/foo_bar_test.dart`, use `foo_bar`). The `subtest` part should be unique to this `testWidgets` entry, and the part after that should be unique within the `testWidgets` entry.
>
> ```dart
>   await expectLater(
>     find.byType(RepaintBoundary),
>     matchesGoldenFile('test_name.subtest.subfile.png'),
>   );
> ```
>
> Put a `RepaintBoundary` widget around the part of the subtree that you want to verify. If you don't, the output will be a 2400x1800 image, since the tests by default use an 800x600 viewport with a device pixel ratio of 3.0.

**Source:** https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Writing-a-golden-file-test-for-package-flutter.md

So: `measure_screen.default.ar.png`, `measure_screen.empty.en.png`. Dotted namespacing, first segment = test file name.

Also from that doc, if you ever *do* want to invalidate all baselines: *"If you would like to instantly invalidate all prior renderings, changing the name of the golden file test will accomplish this."*

### 8.2 THE ARABIC GOLDEN GOTCHA — read this before you write a single golden

This is the most important, least-documented thing in this whole lane.

`flutter test` does **not** load your app's fonts. It substitutes a built-in test font called `FlutterTest`:

> In tests, if `fontFamily` isn't specified or the specified font families are not available, the default test font `FlutterTest` will be used.

And critically:

> **Unmapped codepoints will be mapped to the `.notdef` glyph in the test environment.**

The `FlutterTest` glyph-mapping table covers exactly four scripts: `DFLT` (ASCII punctuation/digits/symbols), `grek` (7 Greek letters), `hani` (27 CJK ideographs), `latn` (Latin). **Arabic (U+0600–U+06FF) is not in the table.**

**Source:** https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Flutter-Test-Fonts.md

**Consequence: your Arabic golden will be a wall of hollow `.notdef` boxes unless you explicitly load a font with Arabic coverage.** The golden will still *pass* (it's a deterministic image of boxes), so this fails silently — you get a green suite that verifies nothing about Arabic text rendering. The mirroring/layout still gets verified; the shaping, ligatures, and line-breaking do not.

The framework's prescribed fix, verbatim from `matchers.dart`:

```dart
testWidgets('Creating a golden image with a custom font', (WidgetTester tester) async {
  // Assuming the 'Roboto.ttf' file is declared in the pubspec.yaml file
  final Future<ByteData> font = rootBundle.load('path/to/font-file/Roboto.ttf');

  final FontLoader fontLoader = FontLoader('Roboto')..addFont(font);
  await fontLoader.load();

  await tester.pumpWidget(const MyWidget());

  await expectLater(
    find.byType(MyWidget),
    matchesGoldenFile('myWidget.png'),
  );
});
```

> The example above loads the desired font only for that specific test. To load a font for all golden file tests, the `FontLoader.load()` call could be moved in the `flutter_test_config.dart`. In this way, the font will always be loaded before a test:
>
> ```dart
> Future<void> testExecutable(FutureOr<void> Function() testMain) async {
>   setUpAll(() async {
>     final FontLoader fontLoader = FontLoader('SomeFont')..addFont(someFont);
>     await fontLoader.load();
>   });
>
>   await testMain();
> }
> ```

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/matchers.dart

### 8.3 Replacement for `loadAppFonts()` — copy-paste this

`golden_toolkit` provided `loadAppFonts()`, which auto-loaded everything in `FontManifest.json`. Since the package is dead, here is that logic, adapted from the (BSD-3-licensed) original so you own it:

**Original source:** https://github.com/eBay/flutter_glove_box/blob/master/packages/golden_toolkit/lib/src/font_loader.dart

`app/test/flutter_test_config.dart`:

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadAppFonts();
  return testMain();
}

/// `flutter test` only ships the `FlutterTest` font, which has NO Arabic
/// glyphs — every Arabic codepoint renders as `.notdef` (a hollow box).
/// Load every font declared in pubspec.yaml (and in dependencies) so that
/// goldens show real text.
///
/// Adapted from golden_toolkit's `loadAppFonts()` (eBay, BSD-3-Clause),
/// which is discontinued as of 2023.
/// https://github.com/eBay/flutter_glove_box/blob/master/packages/golden_toolkit/lib/src/font_loader.dart
Future<void> _loadAppFonts() async {
  final fontManifest = await rootBundle.loadStructuredData<Iterable<dynamic>>(
    'FontManifest.json',
    (string) async => json.decode(string) as Iterable<dynamic>,
  );

  for (final Map<String, dynamic> font in fontManifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(_derivedFontFamily(font));
    for (final Map<String, dynamic> fontType
        in (font['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(fontType['asset'] as String));
    }
    await loader.load();
  }
}

/// Fonts contributed by dependency packages are namespaced as
/// `packages/<pkg>/<family>`; strip/rewrite so Material's default
/// `Roboto` lookups resolve.
String _derivedFontFamily(Map<String, dynamic> fontDefinition) {
  if (!fontDefinition.containsKey('family')) return '';
  final family = fontDefinition['family'] as String;

  const overridable = <String>[
    'Roboto',
    '.SF UI Display',
    '.SF UI Text',
    '.SF Pro Text',
    '.SF Pro Display',
  ];

  if (overridable.contains(family)) return family;

  if (family.startsWith('packages/')) {
    final name = family.split('/').last;
    if (overridable.contains(name)) return name;
  } else {
    for (final Map<String, dynamic> fontType
        in (fontDefinition['fonts'] as List).cast<Map<String, dynamic>>()) {
      final asset = fontType['asset'] as String?;
      if (asset != null && asset.startsWith('packages')) {
        return 'packages/${asset.split('/')[1]}/$family';
      }
    }
  }
  return family;
}
```

**For this app you must additionally vendor an Arabic-capable font** (e.g. Noto Sans Arabic) into `assets/fonts/` and declare it in `pubspec.yaml` so the manifest picks it up. There is no font shipped with Flutter that covers Arabic in the test environment.

### 8.4 Golden tests across 6 locales including RTL — real, complete code

Two building blocks, both from flutter/flutter.

**(a) The table-driven locale loop.** Verbatim from `flutter_localizations`:

```dart
group(CalendarDatePicker, () {
  final arabicNumbers = intl.NumberFormat('0', 'ar');
  final testLocales = <Locale, Map<String, dynamic>>{
    const Locale('en', 'US'): <String, dynamic>{
      'textDirection': TextDirection.ltr,
      'expectedDaysOfWeek': <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'],
      'expectedMonthYearHeader': 'September 2017',
    },
    // Tests RTL.
    const Locale('ar', 'AR'): <String, dynamic>{
      'textDirection': TextDirection.rtl,
      'expectedDaysOfWeek': <String>['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'],
      'expectedDaysOfMonth': List<String>.generate(30, (int i) => arabicNumbers.format(i + 1)),
      'expectedMonthYearHeader': 'سبتمبر ٢٠١٧',
    },
  };

  for (final Locale locale in testLocales.keys) {
    testWidgets('shows dates for $locale', (WidgetTester tester) async {
      // ...
    });
  }
});
```

**(b) The localised pump helper.** Verbatim, same file:

```dart
Future<void> _pumpBoilerplate(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en', 'US'),
  TextDirection textDirection = TextDirection.ltr,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: textDirection,
        child: Localizations(
          locale: locale,
          delegates: GlobalMaterialLocalizations.delegates,
          child: Material(child: child),
        ),
      ),
    ),
  );
}
```

**Source (both):** https://github.com/flutter/flutter/blob/master/packages/flutter_localizations/test/material/date_picker_test.dart

Also note the RTL *assertion* technique in that test — it doesn't just eyeball a golden, it verifies cell ordering by comparing `tester.getCenter(...).dx` in the correct direction. Do this for your ruler: a golden proves it *looks* the same as last week; a `dx` assertion proves it's actually mirrored.

**Composed for this app** — `app/testing/golden.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/l10n/app_localizations.dart';

const kSupportedLocales = <Locale>[
  Locale('en'),
  Locale('ar'),
  Locale('fr'),
  Locale('es'),
  Locale('de'),
  Locale('tr'),
];

/// Pumps [child] inside a fully-localised app at a fixed physical size so
/// goldens are byte-identical across machines.
///
/// Do NOT pass `textDirection` — let `GlobalWidgetsLocalizations` derive it
/// from the locale. Hard-coding it is how RTL bugs hide: the widget renders
/// mirrored in the test and LTR in production.
Future<void> pumpLocalised(
  WidgetTester tester,
  Widget child, {
  required Locale locale,
  List<Override> overrides = const [],
  Size size = const Size(390, 844),   // iPhone 14 logical px
  double devicePixelRatio = 1.0,      // 1.0 keeps goldens small & readable
  ThemeMode themeMode = ThemeMode.light,
}) async {
  tester.view.physicalSize = size * devicePixelRatio;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: locale,
        supportedLocales: kSupportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: themeMode,
        theme: lightTheme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(child: child),   // ← bounds the golden
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// `<test file stem>.<subtest>.<locale>.png`, per flutter/flutter convention.
String goldenName(String stem, String subtest, Locale locale) =>
    'goldens/$stem.$subtest.${locale.toLanguageTag()}.png';
```

`app/test/ui/measure/measure_screen_golden_test.dart`:

```dart
@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/ui/measure/measure_screen.dart';

import '../../../testing/golden.dart';
import '../../../testing/fakes/fake_measurement_dao.dart';

void main() {
  for (final locale in kSupportedLocales) {
    testWidgets(
      'MeasureScreen renders the populated state for ${locale.languageCode}',
      (tester) async {
        await pumpLocalised(
          tester,
          const MeasureScreen(),
          locale: locale,
          overrides: [
            measurementDaoProvider.overrideWithValue(
              FakeMeasurementDao.withSamples(),
            ),
          ],
        );

        await expectLater(
          find.byType(MeasureScreen),
          matchesGoldenFile(goldenName('measure_screen', 'populated', locale)),
        );
      },
    );
  }

  testWidgets('MeasureScreen mirrors the ruler to the right edge in Arabic',
      (tester) async {
    await pumpLocalised(tester, const MeasureScreen(), locale: const Locale('ar'));

    // Assert the mirroring, don't just photograph it.
    final ruler = tester.getRect(find.byType(RulerStrip));
    final screen = tester.getRect(find.byType(MeasureScreen));
    expect(ruler.right, closeTo(screen.right, 1.0));
  });
}
```

Generate:
```
flutter test --update-goldens --tags golden
```
Verify locally / in CI:
```
flutter test --tags golden
```
Exclude from the fast loop:
```
flutter test -x golden
```

Declare the tag in `dart_test.yaml` so the runner stops warning:
```yaml
tags:
  golden:
    # Goldens are pixel-exact and platform-sensitive.
    # See CI: only the Linux job runs these.
```

### 8.5 Golden tooling in 2026 — the maintenance audit

Verified 2026-07-27 via `pub.dev/api` and the GitHub API.

| Package | Latest | Published | SDK constraint | Status |
|---|---|---|---|---|
| **golden_toolkit** | 0.15.0 | **2023-02-21** | `>=2.18.4 <3.0.0` | **DISCONTINUED on pub.dev.** Cannot resolve on Dart 3 at all. Host repo `eBay/flutter_glove_box` not archived but last pushed 2024-09-13, 51 open issues. |
| **alchemist** | 0.14.0 | 2026-03-13 | sdk `>=3.8.0`, flutter `>=3.32.0` | Alive but low-velocity. 8 commits in ~10 months. 37 open issues. Still 0.x. |
| **golden_screenshot** | 11.0.1 | 2026-03-20 | sdk `^3.8.0` | Active. Purpose-built for *store screenshots* with device frames, not regression testing. |
| built-in `matchesGoldenFile` | ships with 3.44.6 | 2026-07-08 | n/a | Maintained by the Flutter team. |

**Sources:**
https://pub.dev/packages/golden_toolkit (page carries the `-pub-tag-discontinued` marker)
https://pub.dev/api/packages/golden_toolkit
https://pub.dev/packages/alchemist · https://github.com/Betterment/alchemist
https://pub.dev/packages/golden_screenshot

**golden_toolkit is unambiguously dead. Any tutorial that tells you to use `loadAppFonts()`, `testGoldens()`, `DeviceBuilder` or `multiScreenGolden` is stale — flag it and move on.**

### 8.6 alchemist — what it gives you, and why I'm not recommending it here

Alchemist's honest pitch, from its own README:

> Alchemist can perform two kinds of golden tests. One is **platform tests**, which generate golden files with human readable text... The other is **CI tests**, which look and function the same as platform tests, except that the text blocks are replaced with colored squares.
>
> The reason for this distinction is that the output of platform tests is dependent on the platform the test is running on. In particular, individual platforms are known to render text differently than others. This causes readable golden files generated on macOS, for example, to be ever so slightly off from the golden files generated on other platforms, such as Windows or Linux, causing CI systems to fail the test.

**Source:** https://github.com/Betterment/alchemist

Its API:

```dart
group('ListTile Golden Tests', () {
  goldenTest(
    'renders correctly',
    fileName: 'list_tile',
    builder: () => GoldenTestGroup(
      scenarioConstraints: const BoxConstraints(maxWidth: 600),
      children: [
        GoldenTestScenario(
          name: 'with title',
          child: ListTile(title: Text('ListTile.title')),
        ),
        GoldenTestScenario(
          name: 'with title and subtitle',
          child: ListTile(
            title: Text('ListTile.title'),
            subtitle: Text('ListTile.subtitle'),
          ),
        ),
      ],
    ),
  );
});
```

Output layout: `test/goldens/ci/*.png` and `test/goldens/<platform>/*.png`.

**Genuine strengths:** the scenario-grid (many states in one image) is excellent, and 0.14.0 added `diffThreshold` for environment-dependent comparison failures.

**Why not for this app:**
1. **The CI mode replaces glyphs with coloured blocks.** For a 6-locale, Arabic-inclusive product, that guts the point — you cannot see whether Arabic shaped, whether a Turkish string overflowed, or whether a German compound wrapped. You'd end up running platform mode only, which is exactly what built-in goldens do.
2. **No locale support.** A code search over `Betterment/alchemist` for `locale` returns zero hits. You must wrap every scenario in your own `Localizations`/`Directionality` anyway — i.e. you write the harness regardless.
3. It's 0.x with an 8-commits-in-10-months cadence, and its whole value-add is ~200 lines of harness code you can own outright.

**Verdict: use the built-in `matchesGoldenFile` plus the ~60-line harness in §8.4.** Zero dependency risk, full control over the locale × theme × text-scale matrix, and real glyphs in every golden.

### 8.7 Cross-platform golden drift — the operational rule

Pixel comparison is **exact** by default (`LocalFileComparator` "returning true only if there's an exact match"). Font rasterisation differs between macOS/Linux/Windows. Alchemist's README documents the problem; Flutter's own solution is Skia Gold, which is infrastructure you are not going to run.

**Rule: goldens are generated and verified on exactly ONE platform — a pinned Linux container in CI.** Developers on macOS run `flutter test -x golden` locally, and regenerate goldens by pushing a branch that triggers the CI `--update-goldens` job. Anything else and you will spend your life re-approving 1-pixel diffs.

If you must tolerate small diffs, the framework documents a custom comparator (verbatim, abridged):

```dart
class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(super.testFile, {required double precisionTolerance})
      : assert(0 <= precisionTolerance && precisionTolerance <= 1,
               'precisionTolerance must be between 0 and 1'),
        _precisionTolerance = precisionTolerance;

  final double _precisionTolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    final bool passed = result.passed || result.diffPercent <= _precisionTolerance;
    if (passed) {
      result.dispose();
      return true;
    }
    final String error = await generateFailureOutput(result, golden, basedir);
    // ...
  }
}
```

Install it in `flutter_test_config.dart` (or per-test with `addTearDown` to restore). **Source:** https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/goldens.dart

**I'd skip tolerance.** A tolerance that's loose enough to absorb font-hinting differences is loose enough to hide a 2-px layout regression. Pin the platform instead.

---

## 9. Testing the custom-painted ruler — don't reach for goldens first

**WHAT:** Assert the *display list* with the `paints` matcher, not the pixels.

**WHY:** A golden tells you "something changed" and shows you a PNG diff. `paints` tells you "the tick at index 12 moved from x=48 to x=49" in the failure message. It is also immune to font/platform drift, runs in microseconds, and doesn't need regeneration when an unrelated colour changes.

**API, verbatim from the framework:**

```dart
expect(myRenderObject, paints..circle(radius: 10.0)..circle(radius: 20.0));
```

> This particular pattern would verify that the render object `myRenderObject` paints, among other things, two circles of radius 10.0 and 20.0 (in that order).
>
> Patterns are **subset** matches, meaning that any calls not described by the pattern are ignored. This allows, for instance, transforms to be skipped.

Also available: `paintsNothing`, `paintsAssertion`, `paintsExactlyCountTimes(Symbol methodName, int count)`.

`paints` applies to `RenderObject`s, `Finder`s resolving to a single `RenderObject`, and to raw painter functions with either signature:

```dart
void exampleOne(PaintingContext context, Offset offset) { }
void exampleTwo(Canvas canvas) { }
```

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/mock_canvas.dart

**EXAMPLE** for the ruler:

```dart
testWidgets('RulerPainter draws a major tick every 10 minor ticks', (tester) async {
  await tester.pumpWidget(
    const Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(width: 200, height: 60, child: RulerStrip(pixelsPerMm: 4)),
    ),
  );

  expect(
    find.byType(RulerStrip),
    paints
      ..line(p1: const Offset(0, 0),  p2: const Offset(0, 24))   // major
      ..line(p1: const Offset(4, 0),  p2: const Offset(4, 10))   // minor
      ..line(p1: const Offset(8, 0),  p2: const Offset(8, 10)),
  );
});

testWidgets('RulerPainter draws exactly 51 ticks across 200px at 4px/mm', (tester) async {
  await tester.pumpWidget(/* ... */);
  expect(find.byType(RulerStrip), paintsExactlyCountTimes(#drawLine, 51));
});

testWidgets('RulerPainter draws nothing when pixelsPerMm is zero', (tester) async {
  await tester.pumpWidget(/* ... pixelsPerMm: 0 ... */);
  expect(find.byType(RulerStrip), paintsNothing);
});
```

**Layer strategy for the ruler:** `paints` for geometry (tick spacing, counts, mirroring), one golden per theme for overall appearance, and a `shouldRepaint` unit test (`expect(painterA.shouldRepaint(painterB), isFalse)`) — that last one directly protects your 1.2 s cold-start budget.

---

## 10. Accessibility testing (cheap, and you asked for a11y)

`flutter_test` ships guideline matchers. Official sample, verbatim:

```dart
testWidgets('HomePage meets androidTapTargetGuideline', (WidgetTester tester) async {
  final SemanticsHandle handle = tester.ensureSemantics();
  await tester.pumpWidget(const MaterialApp(home: HomePage()));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  handle.dispose();
});
```

Available guidelines:
- `androidTapTargetGuideline` — tappable nodes ≥ 48×48 px
- `iOSTapTargetGuideline` — tappable nodes ≥ 44×44 px
- `textContrastGuideline` — WCAG AA contrast
- `MinimumTextContrastGuidelineAAA` — WCAG AAA
- `labeledTapTargetGuideline` — every tap/long-press node has a label

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/accessibility.dart

**Recommendation:** run all five guidelines against every screen, in a loop, for both `en` and `ar`. It is ~15 lines and catches an entire class of bug that no golden will. Note `meetsGuideline` is async → `await expectLater`.

For richer semantics assertions, `matchesSemantics(...)` — used heavily in flutter/flutter, e.g.:

```dart
expect(
  tester.getSemantics(find.byType(Focus).last),
  matchesSemantics(
    hasCheckedState: true,
    hasEnabledState: true,
    isEnabled: true,
    hasTapAction: true,
    hasFocusAction: true,
    isFocusable: true,
  ),
);
```

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter/test/material/checkbox_test.dart

---

## 11. Plugins in tests — camera, GPS, PDF, path_provider

In `flutter test` there is no native host code, so plugin calls throw:

```
MissingPluginException(No implementation found for method someMethodName on channel some_channel_name)
```

Flutter's documented options, **in their stated order of preference**:

1. **Wrap the plugin in your own API** *(recommended)* — "Tests remain unaffected by plugin API changes; tests only verify your code; works regardless of plugin implementation method."
2. Mock the plugin's public API — breaks on static methods / top-level functions.
3. Mock the plugin's platform interface — federated plugins only.
4. Mock the platform channel:
   ```dart
   TestDefaultBinaryMessenger.instance.setMockMethodCallHandler(
     MethodChannel('channel_name'),
     (MethodCall methodCall) async {
       // Handle mock calls
     },
   );
   ```
   — "Best reserved for plugin internal tests, not app tests."

> Wrapping plugin calls in your own API is the most robust testing strategy.

**Source:** https://docs.flutter.dev/testing/plugins-in-tests

**Applied to this app.** Define narrow domain-owned interfaces and put the plugin behind each one:

```dart
abstract interface class CameraCapture {
  Future<Uint8List> captureStill();
}

abstract interface class LocationFix {
  Future<({double lat, double lon, double accuracyM})?> singleShot();
}

abstract interface class DocumentStore {
  Future<File> writePdf(String name, Uint8List bytes);
}
```

Real implementations in `lib/data/platform/`, fakes in `testing/fakes/`, and a Riverpod provider per interface so `ProviderScope(overrides: [...])` swaps them. This also means your widget/golden tests never touch `path_provider` or `camera` at all — which is a large part of why they stay fast.

---

## 12. Mocking: mocktail vs mockito

Verified 2026-07-27:

| | mocktail | mockito |
|---|---|---|
| Latest | **1.0.5** | **5.7.0** |
| Published | 2026-04-10 | 2026-05-19 |
| Repo | https://github.com/felangel/mocktail (698★, pushed 2026-04-12) | https://github.com/dart-lang/build/tree/master/builder_pkgs/mockito |
| Codegen | **None** | **Required** (`build_runner` + `@GenerateMocks`) |
| Heavy deps | none | `analyzer ^13.0.0`, `build`, `code_builder`, `source_gen`, `dart_style` |
| Maintenance note | active, single maintainer (Felix Angelov) | active, **but `dart-lang/mockito` is now ARCHIVED**; the package moved into the `dart-lang/build` monorepo (CHANGELOG 5.6.4: *"Move to `dart-lang/build` monorepo"*) |

**Sources:** https://pub.dev/packages/mocktail · https://pub.dev/packages/mockito · https://github.com/dart-lang/build/tree/master/builder_pkgs/mockito · https://github.com/dart-lang/mockito (archived: true)

**Recommendation: mocktail.** Reasons, in order:

1. **No codegen in the test loop.** mockito requires a `build_runner` pass before your mocks compile. In an app that *already* runs `build_runner` for drift and riverpod_generator, adding mockito means every new mock is another full codegen cycle. mocktail mocks are three words: `class MockX extends Mock implements X {}`.
2. **Dependency weight.** mockito pulls `analyzer ^13.0.0` into your dev dependency graph. `analyzer` is the single most version-conflict-prone package in the Dart ecosystem; pinning it drags `drift_dev` and `riverpod_generator` version resolution with it.
3. **It's what official Flutter samples use.** compass_app declares `mocktail: ^1.0.4` and `mocktail_image_network: ^1.2.0`, with **no** mockito. (https://github.com/flutter/samples/blob/main/compass_app/app/pubspec.yaml)

**Caveats to know:**
- mocktail needs `registerFallbackValue(...)` in `setUpAll` for any custom type you use with `any()`. mockito's codegen handles this automatically. Minor, but it's the one real ergonomic tax.
- Flutter's own cookbook page is still titled "Mock dependencies using Mockito" (https://docs.flutter.dev/cookbook/testing/unit/mocking). This is **stale relative to Flutter's own architecture sample**, which uses mocktail. Treat the cookbook page as a mocking *concept* explainer, not as a package endorsement.

**Better than either: prefer hand-written fakes.** This is the official architecture guidance's actual stance, and it's what compass_app does:

```dart
// compass_app/testing/mocks.dart — mocks ONLY for third-party types
class MockGoRouter extends Mock implements GoRouter {}
class MockHttpClient extends Mock implements HttpClient {}
```
```dart
// compass_app/testing/fakes/repositories/… — fakes for YOUR OWN types
class FakeAuthRepository implements AuthRepository { ... }
```

**Source:** https://github.com/flutter/samples/blob/main/compass_app/app/testing/mocks.dart · https://docs.flutter.dev/app-architecture/case-study/testing

The rule that falls out of this: **fakes for interfaces you own, mocks for types you don't.** A `FakeMeasurementDao` with a real in-memory `List` produces tests that read like specifications; `when(() => dao.getAll()).thenAnswer(...)` produces tests that read like assembly. Reach for `mocktail` when you need to *verify an interaction* (`verify(() => goRouter.go('/')).called(1);`) — that is what mocks are actually for.

---

## 13. integration_test and patrol

### 13.1 `integration_test` ships with the SDK — the pub.dev page is a trap

pub.dev shows `integration_test 1.0.2+3`, published **2021-04-20**, sdk `>=2.2.2 <3.0.0`. That looks abandoned. It isn't — the package **moved into the Flutter SDK**:

```yaml
name: integration_test
description: Runs tests that use the flutter_test API as integration tests.
publish_to: none          # ← never published again

environment:
  sdk: ^3.11.0-0
resolution: workspace
```

**Source:** https://github.com/flutter/flutter/blob/master/packages/integration_test/pubspec.yaml

**Always depend on it as an SDK package:**

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
```
or `flutter pub add "dev:integration_test:{sdk: flutter}"`.

**Sources:** https://docs.flutter.dev/testing/integration-tests · https://github.com/flutter/samples/blob/main/compass_app/app/pubspec.yaml

**Anyone telling you `integration_test` is unmaintained is misreading pub.dev. Flag that as a stale claim.**

Structure and boilerplate (verbatim from the docs):

```
counter_app/
  lib/main.dart
  integration_test/app_test.dart
```

```dart
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('0'), findsOneWidget);
      final fab = find.byKey(const ValueKey('increment'));
      await tester.tap(fab);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    });
  });
}
```

Run: `flutter test integration_test/app_test.dart` (desktop, Android device, iOS device).

**Source:** https://docs.flutter.dev/testing/integration-tests

Real example from the official sample: https://github.com/flutter/samples/blob/main/compass_app/app/integration_test/app_local_data_test.dart

### 13.2 patrol — when it's worth it

Status verified 2026-07-27: **4.8.0, published 2026-07-24.** Repo `leancodepl/patrol` pushed **2026-07-27** (today), 1378★, 203 open issues, 162 versions. This is one of the most actively developed test packages in the ecosystem.

Its pitch, from the README:

> A powerful, multiplatform E2E UI testing framework for Flutter apps that overcomes the limitations of `integration_test` by handling **native interactions**. Developed by LeanCode since 2022.

**Commercial note — say it plainly:** patrol is open source but is a lead-generation asset for LeanCode. From the README:

> Patrol is an open-source framework created and maintained by LeanCode. However, if your company wants to scale fast and accelerate Patrol's adoption, we offer a set of value-added services on top of the core framework. — "Automate Flutter app testing with Patrol", "Patrol Setup & Patrol Training"

**Source:** https://github.com/leancodepl/patrol

It is **not** rug-pulled or gone-commercial in the sense the brief worries about — the core is MIT-adjacent OSS and shipping weekly. But the sustainability model is consultancy, and its native components (Android/iOS runners, Playwright web driver, ktor deps) are a large surface area that turns over fast: 4.7.0 (2026-07-13) → 4.7.1 → 4.8.0 in 11 days, with 4.7.0 requiring iOS Swift Package Manager migration steps.

**Verdict for this app: start with `integration_test`. Adopt patrol only when a permission dialog blocks you.**

- What patrol buys you that `integration_test` cannot do: tapping **native OS dialogs** — the Android/iOS camera and location permission prompts. Your app needs both.
- What it costs: native build config on both platforms, a separate CLI (`patrol_cli`), and a dependency whose native layer churns weekly.
- Pragmatic middle path: grant permissions out-of-band (`adb shell pm grant`, iOS simulator `xcrun simctl privacy ... grant`) in the CI script, then run plain `integration_test`. This covers ~90% of the value at ~10% of the cost. Reach for patrol only if you specifically want to *test the permission-denied UX path*, which is genuinely hard otherwise.

---

## 14. Coverage

### 14.1 Commands, verified against the CLI source

```
--coverage           Whether to collect coverage information.
--coverage-path      Where to store coverage information (if coverage is enabled).
                     (defaults to "coverage/lcov.info")
--branch-coverage    Whether to collect branch coverage information.
                     Implies collecting coverage data.
--merge-coverage     Whether to merge coverage data with "coverage/lcov.base.info".
                     Implies collecting coverage data. (Requires lcov.)
--coverage-package   A regular expression matching packages names to include in the
                     coverage report (if coverage is enabled). If unset, matches the
                     current package name.
```

**Source:** https://github.com/flutter/flutter/blob/master/packages/flutter_tools/lib/src/commands/test.dart

`--coverage-package` is the flag nobody knows about and you specifically need it: by default coverage only covers the *current* package. To include your `rule_engine` package in the app's report:

```bash
flutter test --coverage --coverage-package 'myapp|rule_engine'
```

For the pure-Dart package alone, use the `test` runner's own flag:

```bash
dart test --coverage-path=./coverage/lcov.info
```

> Coverage gathering is currently only implemented for tests run on the Dart VM or Chrome.

**Source:** https://github.com/dart-lang/test/blob/master/pkgs/test/README.md

### 14.2 Report generation

The official pipeline (verbatim from the `test` README):

```shell
## Run Dart tests and output coverage info to `./coverage/lcov.info`:
dart run test --coverage-path=./coverage/lcov.info

## Generate a human readable report:
genhtml -o ./coverage/report ./coverage/lcov.info

## Open the coverage report:
open ./coverage/report/index.html
```

> `genhtml` is one of the LCOV tools. See https://github.com/linux-test-project/lcov · Homebrew: https://formulae.brew.sh/formula/lcov

### 14.3 Exclude generated files — otherwise the number is a lie

You will have `*.g.dart` (drift, riverpod_generator, json_serializable), `*.drift.dart`, `*.freezed.dart`, and `app_localizations*.dart`. These are machine-generated; counting them inflates or deflates coverage arbitrarily.

```bash
flutter test --coverage --coverage-package 'myapp|rule_engine'

lcov --remove coverage/lcov.info \
  '*/*.g.dart' \
  '*/*.drift.dart' \
  '*/*.freezed.dart' \
  '*/l10n/*' \
  '*/generated_migrations/*' \
  -o coverage/lcov.info \
  --ignore-errors unused

genhtml coverage/lcov.info -o coverage/html
```

*Note:* the exact `lcov --remove` invocation is standard LCOV usage, not something documented by the Flutter team; `--ignore-errors unused` is needed on lcov ≥ 2.0 when a pattern matches nothing. Verify against your installed lcov version.

### 14.4 What target is actually sane

There is **no coverage target anywhere in Flutter's official documentation.** I looked; `docs/contributing/testing/Test-coverage-for-package-flutter.md` is entirely about *viewing* coverage (VS Code Coverage Gutters, Emacs `coverlay`, `--merge-coverage` for fast iteration) and never states a number. It also notes their own Coveralls integration has been broken for years.

**Source:** https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Test-coverage-for-package-flutter.md

So this is my opinion, stated as such:

| Target | Rationale |
|---|---|
| `packages/rule_engine` — **100% line, ~95% branch, enforced in CI** | Pure functions, no I/O, no UI. There is no excuse. This is your correctness core. |
| Drift DAOs + migrations — **~90%** | Every query and every migration path should execute at least once. |
| Riverpod notifiers — **~85%** | State machines; the uncovered slice is error branches you can't trigger offline. |
| `lib/ui/**` — **~50%, unenforced** | Widget coverage is a vanity metric. A screen can be 100% covered and completely broken. Goldens + a11y guidelines carry the real load here. |
| App-wide gate — **~75%, ratchet-only** | Set the gate at *current minus 1%* and only let it go up. Absolute targets get gamed with `expect(true, true)` tests. |

**Do not chase 100% app-wide.** The marginal test that takes `lib/` from 85% to 95% is almost always a test of generated code, a `toString()`, or an unreachable `default:` branch. That effort is better spent on one more locale golden.

### 14.5 Leak tracking — free extra signal

Flutter's framework tests use `leak_tracker` to fail tests that leave `Disposable`s undisposed:

> To enable leak tracking locally pass `--dart-define LEAK_TRACKING=true` to `flutter test`.
>
> ```
> Expected: leak free
>     Actual: <Instance of 'Leaks'>
>      Which: contains leaks:
>             notDisposed:
>               total: 1
>               objects:
>                 FocusNode:
>                   test: Align smoke test
> ```
>
> In general, leak tracking should be enabled, to verify that all disposables are disposed. If a test is opted out, the reasons should be clearly explained in the comments.

**Source:** https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Leak-tracking.md

*Note:* the `LEAK_TRACKING` define is documented for the **Flutter framework's own** test suite, wired through `packages/flutter/test/flutter_test_config.dart`. For an app you configure `LeakTesting.settings` in your own `flutter_test_config.dart`. Given your cold-start and memory constraints on low-end Android, this is worth an afternoon — undisposed `AnimationController`s and `ScrollController`s are exactly the kind of thing a custom-painting app accumulates.

---

## 15. CI shape for this app

```yaml
# Conceptual — adapt to your CI provider.
jobs:
  domain:                       # fastest, fails first
    run: |
      cd packages/rule_engine
      dart analyze --fatal-infos
      dart test --coverage-path=coverage/lcov.info
      # enforce 100%

  app-fast:                     # everything except goldens
    run: |
      flutter analyze --fatal-infos
      flutter test -x golden --coverage --coverage-package 'myapp|rule_engine'
      lcov --remove coverage/lcov.info '*/*.g.dart' '*/*.drift.dart' '*/l10n/*' -o coverage/lcov.info

  goldens:                      # PINNED LINUX IMAGE ONLY
    runs-on: ubuntu-<pinned>
    container: <pinned flutter 3.44.6 image>
    run: flutter test --tags golden

  integration:
    run: |
      # pre-grant camera + location so plain integration_test suffices
      adb shell pm grant com.example.myapp android.permission.CAMERA
      adb shell pm grant com.example.myapp android.permission.ACCESS_FINE_LOCATION
      flutter test integration_test
```

Other flags worth knowing (all verified in `flutter_tools/lib/src/commands/test.dart`):

| Flag | Use |
|---|---|
| `--fail-fast` | Stop after first failure. Great for the fast job. |
| `-j / --concurrency` | Concurrent test processes. Ignored for integration tests. |
| `--total-shards` / `--shard-index` | Split the suite across CI machines. |
| `--test-randomize-ordering-seed` | Catch inter-test state leakage. Run it nightly with `random`. |
| `--reporter` | `github` reporter exists in `package:test` for GH Actions annotations. |
| `--name` / `-n` | Regex over test names. |
| `--plain-name` | Plain substring over test names. |
| `--no-test-assets` | Skips asset bundling. **Do not use** — you need the asset DB and fonts. |
| `--start-paused` | Attach a debugger before the test runs. |

---

## 16. Anti-patterns — what NOT to do

1. **Don't name tests `should X`, and never `group('<Thing> tests')`.** `Writing-Effective-Tests.md` explicitly calls object-named tests bad, and `'X tests'` is exactly that with a noise word appended. Use declarative behaviour names. (§2)

2. **Don't use given/when/then in Dart test names.** Zero occurrences across flutter/flutter, flutter/samples, dart-lang/test, dart-lang/core, or drift's docs. It is a BDD import that nobody in this ecosystem uses. If you want the *structure*, use blank lines and a comment — which is what `Writing-Effective-Tests.md` demonstrates.

3. **Don't add `golden_toolkit`.** Discontinued; `<3.0.0` SDK bound makes it unresolvable. Any snippet using `testGoldens()`, `loadAppFonts()`, `DeviceBuilder`, or `multiScreenGolden` is from a dead package. (§8.5)

4. **Don't write an Arabic golden without loading an Arabic font.** It will pass, and it will be a picture of empty boxes. This is the single highest-severity trap in this document. (§8.2)

5. **Don't hard-code `textDirection: TextDirection.rtl` in your RTL golden harness.** That tests your test. Set `locale: Locale('ar')` and let `GlobalWidgetsLocalizations` derive direction — that's the code path production uses.

6. **Don't generate goldens on macOS and verify on Linux.** Font rasterisation differs; you'll get eternal 1-px diffs. One pinned platform. (§8.7)

7. **Don't reach for `pumpAndSettle()` by reflex.** It hangs forever on repeating animations. Use `pump(duration)`. (§4.1)

8. **Don't forget `addTearDown(tester.view.reset)`.** Leaked view state makes the *next* test fail, and the failure points at innocent code. Same for `binding.setSurfaceSize(null)`.

9. **Don't use `binding.setSurfaceSize`** — there's a `TODO(pdblasi-google): Deprecate this` on it and the docstring redirects you to `TestFlutterView.physicalSize`. (§4.3)

10. **Don't `container.read` an autoDispose Riverpod provider without `container.listen` first.** It can be disposed mid-test. Documented by the maintainer. (§7.2)

11. **Don't mock Riverpod Notifiers.** The maintainer says don't; mock the repository behind them. If you must, you have to *subclass* the generated base, not `implements` it. (§7.6)

12. **Don't forget `closeStreamsSynchronously: true`** on drift `DatabaseConnection`s used in widget tests — you'll get pending-timer failures. (§6.1)

13. **Don't depend on `integration_test` by version from pub.dev.** Use `sdk: flutter`. The published 1.0.2+3 is a 2021 fossil. (§13.1)

14. **Don't count generated files in coverage.** `*.g.dart` / `*.drift.dart` / `l10n/` make the number meaningless in both directions. (§14.3)

15. **Don't put helper code in a file ending `_test.dart`.** It'll be run as a suite and fail with "no tests". (§3.1)

16. **Don't skip `RepaintBoundary` around golden subjects.** Without it you photograph the whole 800×600 @ DPR 3.0 viewport = a 2400×1800 PNG per golden × 6 locales. Your repo will bloat and diffs become unreviewable. (§8.1)

17. **Don't test a widget and its ViewModel in the same test.** One behaviour per test; the ViewModel test should not need `WidgetTester` at all. That separation is the whole point of the architecture.

18. **Don't leave `test('...', () { expect(true, true); })` stubs to pad coverage.** Ratchet the gate instead of gaming it.

---

## 17. Package status summary (all verified 2026-07-27)

| Package | Version | Published | Verdict |
|---|---|---|---|
| `flutter_test` | SDK (3.44.6) | 2026-07-08 | Use. Foundation. |
| `integration_test` | SDK (3.44.6) | 2026-07-08 | Use via `sdk: flutter`. pub.dev copy is dead/irrelevant. |
| `test` (dart-lang) | 1.31.2 | 2026-06-27 | Use for the pure-Dart package. |
| `mocktail` | 1.0.5 | 2026-04-10 | **Use.** No codegen. |
| `mocktail_image_network` | 1.2.0+ | — | Only if you render network images. You don't (offline app). Skip. |
| `mockito` | 5.7.0 | 2026-05-19 | Maintained (now in `dart-lang/build` monorepo; old repo archived). Skip in favour of mocktail. |
| `alchemist` | 0.14.0 | 2026-03-13 | Alive, low velocity, no locale support, CI mode blocks glyphs. **Skip for this app.** |
| `golden_toolkit` | 0.15.0 | 2023-02-21 | **DISCONTINUED. Do not use.** |
| `golden_screenshot` | 11.0.1 | 2026-03-20 | Active. Different job (store screenshots). Optional. |
| `patrol` | 4.8.0 | 2026-07-24 | Very active; consultancy-backed. Adopt only for native permission dialogs. |
| `drift` / `drift_dev` | 2.34.2 / 2.34.5 | 2026-07-14 / 2026-07-22 | Use. Excellent testing story. |
| `flutter_riverpod` | 3.4.1 | 2026-07-26 | Use. `ProviderContainer.test()` + `tester.container()`. |

---

## 18. Explicitly stale / superseded advice to watch for

| Stale claim | Reality (2026-07-27) |
|---|---|
| "Use `golden_toolkit` and `loadAppFonts()`" | Discontinued 2023; `<3.0.0` SDK bound. Roll your own font loader (§8.3). |
| "`integration_test` is unmaintained (last publish 2021)" | Misreading pub.dev. It moved into the SDK with `publish_to: none`. |
| "Use `mockito` + `@GenerateMocks`" (Flutter cookbook page title) | Flutter's own architecture sample uses mocktail with zero mockito. |
| "Write a `createContainer()` helper with `addTearDown`" (Riverpod 2.x era) | Superseded by `ProviderContainer.test()` in Riverpod 3.0.0, which the CHANGELOG says was added "to replace the `createContainer` utility". |
| "Use `tester.binding.setSurfaceSize(...)`" | Framework has a deprecation TODO on it; use `tester.view.physicalSize`. |
| "`textScaleFactor` on MediaQueryData" | Replaced by `TextScaler` / `tester.platformDispatcher.textScaleFactorTestValue`. |
| "The test font is called Ahem" | `FlutterTest` replaced Ahem as the default (1024 upem vs 1000, better cross-platform metric stability). `matchers.dart` docstrings still say "Ahem" — the docstring is stale, `Flutter-Test-Fonts.md` is current. |
| Any pre-Dart-3 mocking guidance about null-safety workarounds | Moot. Both packages have been null-safe for years. |

---

## Appendix: verified source URLs

**Official docs**
- https://docs.flutter.dev/testing/overview
- https://docs.flutter.dev/cookbook/testing/widget/introduction
- https://docs.flutter.dev/cookbook/testing/unit/introduction
- https://docs.flutter.dev/cookbook/testing/unit/mocking
- https://docs.flutter.dev/testing/integration-tests
- https://docs.flutter.dev/testing/plugins-in-tests
- https://docs.flutter.dev/app-architecture/case-study/testing
- https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html

**flutter/flutter (branch: master)**
- docs/contributing/testing/Writing-Effective-Tests.md
- docs/contributing/testing/Running-and-writing-tests.md
- docs/contributing/testing/Writing-a-golden-file-test-for-package-flutter.md
- docs/contributing/testing/Flutter-Test-Fonts.md
- docs/contributing/testing/Test-coverage-for-package-flutter.md
- docs/contributing/testing/Leak-tracking.md
- packages/flutter/test/material/app_bar_test.dart
- packages/flutter/test/material/checkbox_test.dart
- packages/flutter_localizations/test/material/date_picker_test.dart
- packages/flutter_localizations/test/basics_test.dart
- packages/flutter_test/lib/flutter_test.dart
- packages/flutter_test/lib/src/matchers.dart
- packages/flutter_test/lib/src/goldens.dart
- packages/flutter_test/lib/src/mock_canvas.dart
- packages/flutter_test/lib/src/accessibility.dart
- packages/flutter_test/lib/src/window.dart
- packages/flutter_test/lib/src/binding.dart
- packages/flutter_tools/lib/src/commands/test.dart
- packages/flutter_tools/lib/src/test/test_config.dart
- packages/integration_test/pubspec.yaml

**flutter/samples (branch: main)** — compass_app: `app/testing/app.dart`, `app/testing/mocks.dart`, `app/pubspec.yaml`, `app/test/ui/auth/login_screen_test.dart`, `app/test/ui/results/results_viewmodel_test.dart`, `app/integration_test/app_local_data_test.dart`

**Other**
- https://github.com/dart-lang/test/blob/master/pkgs/test/README.md
- https://github.com/dart-lang/core/blob/main/pkgs/collection/test/equality_test.dart
- https://github.com/simolus3/drift/blob/develop/docs/content/testing.md
- https://github.com/simolus3/drift/blob/develop/docs/content/migrations/tests.md
- https://github.com/simolus3/drift/blob/develop/docs/lib/src/snippets/setup/testing.dart
- https://drift.simonbinder.eu/testing/
- https://riverpod.dev/docs/how_to/testing
- https://github.com/rrousselGit/riverpod/blob/master/website/docs/how_to/testing.mdx (+ `testing/*.dart` samples)
- https://github.com/Betterment/alchemist
- https://github.com/eBay/flutter_glove_box/blob/master/packages/golden_toolkit/lib/src/font_loader.dart
- https://github.com/leancodepl/patrol
- https://github.com/dart-lang/build/tree/master/builder_pkgs/mockito
- https://pub.dev/packages/{golden_toolkit,alchemist,mocktail,mockito,patrol,drift,flutter_riverpod,golden_screenshot}
