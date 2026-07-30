# FLUTTER_GUIDE.md — How to write the code for this app

**Toolchain this is written against:** Flutter **3.44.6** stable (2026-07-08) / Dart **3.12.2** (2026-06-09).
**Researched:** 2026-07-27, from primary sources only — `docs.flutter.dev` (read from the `flutter/website`
repo source, not the rendered HTML, to avoid paraphrase drift), `dart.dev/effective-dart`, the
`flutter/samples` Compass App source, `flutter/flutter`'s own `analysis_options.yaml` and style guide,
and the pub.dev + GitHub APIs for every version and maintenance claim.

> **Status:** Complete — Parts 1–9.

**How to read this.** Every rule states WHAT, WHY, a REAL example, and a SOURCE. Where credible sources
genuinely disagree, that is called out and a decision is made — "it depends" is a non-answer. Anything
marked **[opinion]** is a judgement call, not a citation.

---

## Part 0 — The three facts that date everything else

1. **Official Flutter app-architecture guidance did not exist before November 2024.** The pages were
   published 2024-11-18 (`flutter/website` PR #11300), with the case study following on 2024-12-02.
   **Any "Clean Architecture in Flutter" or "BLoC is the recommended pattern" article from 2021–2023
   predates the existence of an official answer.** Treat it as superseded, not merely old.

2. **Dart 3 (May 2023) changed what good code looks like.** Sealed classes + exhaustive `switch` +
   patterns replace a large class of older boilerplate. Any `Result` or state-union sample that does not
   use `sealed` and pattern matching is pre-Dart-3 and should be rewritten.

3. **The layering is prescribed; the state-management library is not.** In Flutter's own
   recommendations file, *every* separation-of-concerns item is **Strongly recommend** except
   "Use `ChangeNotifier`s and `Listenable`s", which is only **Conditional**, with the note *"ultimately
   the decision comes down to personal preference"* — and `package:riverpod` is named explicitly as an
   alternative. **That sentence is the licence to use Riverpod without deviating from official guidance.**
   Source: [`architectureRecommendations.yml`](https://github.com/flutter/website/blob/main/sites/docs/src/data/architectureRecommendations.yml)

---

# Part 1 — Architecture

## 1.1 Two layers, and a rule about who may talk to whom

> *"Your Flutter application should split into two broad layers, the UI layer and the Data layer."*
> *"These are called 'layers' because each layer can only communicate with the layers directly below or
> above it. **The UI layer shouldn't know that the data layer exists, and vice versa.**"*
> — [concepts](https://docs.flutter.dev/app-architecture/concepts)

Four components: **View** and **ViewModel** (UI layer), **Repository** and **Service** (data layer),
plus an optional **domain layer** of use-cases.

The enforceable contract, reproduced exactly from
[dependency-injection](https://docs.flutter.dev/app-architecture/case-study/dependency-injection):

| Component | Rules of engagement |
|---|---|
| **View** | Aware of exactly **one** ViewModel, and never of any other layer or component. The ViewModel is passed in as a constructor argument. |
| **ViewModel** | Belongs to exactly one View, which can see its data; the ViewModel never knows a View exists. Aware of one or more **Repositories**, passed into its constructor. |
| **Repository** | Aware of many **Services**, passed into its constructor. Used by many ViewModels, never aware of them. |
| **Service** | Used by many Repositories, never aware of a Repository or anything else. |

Plus these hard rules from the [guide](https://docs.flutter.dev/app-architecture/guide):

- *"Views and view models should have a one-to-one relationship."*
- *"Repositories should never be aware of each other."* If logic needs two repositories, combine in the
  ViewModel or the domain layer.
- *"There should be a repository class for each different type of data handled in your app."*
- *"Your app should have one service class per data source."*
- Injected dependencies are **private fields**: *"It's important that the service is a private member,
  so that the UI layer can't bypass the repository and call a service directly."*

**A "feature" is defined by the UI, not the data.** *"Every instance of a paired view and view model
defines one feature in your app. This is often a screen in your app, but it doesn't have to be."* The
docs' own example is a `LogoutViewModel` + a single button. So "one ViewModel per screen" is the wrong
rule — it is one ViewModel per *feature*, and a feature can be a button.

## 1.2 What a View may contain — an exhaustive allow-list

> *"The only logic a view should contain is:
> * Simple if-statements to show and hide widgets based on a flag or nullable field in the view model
> * Animation logic
> * Layout logic based on device information, like screen size or orientation
> * Simple routing logic
>
> All logic related to data should be handled in the view model."*
> — [guide](https://docs.flutter.dev/app-architecture/guide)

"Do not put logic in widgets" is **Strongly recommend**.

**Why this matters more for us than for most apps:** we ship six locales with golden tests including
RTL. A View with logic in it multiplies the golden matrix by the number of its branches. A View with no
logic renders identically given identical ViewModel state, so goldens vary only locale and text
direction. The architecture pays for itself directly in test count.

## 1.3 What a ViewModel may and may not do

**May:** transform repository data for presentation (filter, sort, aggregate); hold the current UI
state so the View can rebuild without losing it; expose callbacks for events.

**Must not:**
- know a View exists;
- hold a `BuildContext`, show a `SnackBar`, or navigate — the View listens and performs the UI action;
- talk to a Service (only Repositories, and optionally use-cases);
- **expose mutable state.** The official code is explicit:

```dart
List<BookingSummary> _bookings = [];

/// Items in an [UnmodifiableListView] can't be directly modified,
/// but changes in the source list can be modified. Since _bookings
/// is private and bookings is not, the view has no way to modify the
/// list directly.
UnmodifiableListView<BookingSummary> get bookings => UnmodifiableListView(_bookings);
```

> *"UI state is an immutable snapshot of data that is required to fully render a view."*
> — [ui-layer](https://docs.flutter.dev/app-architecture/case-study/ui-layer)

## 1.4 Repositories, Services, and where our two databases go

**Repository** — *"the source of truth for a single type of application data, and it should be the only
place where that data type is mutated."* Handles caching, error handling, retry, refreshing.

**Service** — *"They're only used to isolate data-loading, and they hold no state. Your app should have
one service class per data source."* *"As a rule of thumb, services are most helpful when the necessary
data lives outside of your application's Dart code."*

SQLite lives outside your Dart code, so **drift belongs behind a Service**. Camera, GPS, PDF writing and
`rootBundle` are each a Service too. Minimum set for CATCHLAW:

```
ReferenceDatabaseService   (drift, read-only asset DB, lazy-open)
UserDatabaseService        (drift, writable DB, lazy-open)
CameraService · LocationService · PdfExportService · AssetBundleService
```

**The "Services hold no state" rule and drift.** A drift `DatabaseConnection` *is* state. The official
SQL pattern resolves this: the `DatabaseService` owns `_database` and exposes `isOpen()`/`open()`, and
the **Repository** is the one that checks and opens it. Treat the connection as a resource handle, not
application state. Follow the official shape:

```dart
class TodoRepository {
  TodoRepository({required this._database});
  final DatabaseService _database;

  Future<Result<List<Todo>>> fetchTodos() async {
    if (!_database.isOpen()) {
      await _database.open();
    }
    return _database.getAll();
  }
}
```
— [design-patterns/sql](https://docs.flutter.dev/app-architecture/design-patterns/sql)

**drift is explicitly sanctioned by name:** *"You can implement the same `DatabaseService` using other
storage packages like `sqlite3`, `drift`…"* (same page). drift is **2.34.2, published 2026-07-14** —
actively maintained.

**Lazy-open is load-bearing for our 1.2 s cold-start budget.** The database is *not* opened in `main()`;
it opens on first use. drift gives you this via `LazyDatabase`. **Never open a database in `main()`.**

**Two repositories, one per data type — not one per database.** `ReferenceRepository` (read-only) and
`MeasurementRepository` (read/write). They must never call each other; a screen that joins reference
data with user data does it in a **use-case**.

**NEW, May 2026 — repositories own app-wide session state.** This section is absent from essentially
every third-party summary (`flutter/website` PR #13352, merged 2026-05-04):

> *"Because repositories are the single source of truth for application data, they are also the ideal
> place to manage **app-wide lifecycle state**—state that needs to be shared across multiple view models
> but shouldn't persist beyond the current application session… typically managed through a service
> locator or dependency injection container."*

That is the official blessing for putting the active measurement session, the loaded rule-engine
context, and the current unit/locale selection in a Repository rather than inventing a "global
ViewModel".

## 1.5 Abstract repositories — Strongly recommend

> *"Creating abstract repository classes allows you to create different implementations, which can be
> used for different app environments."*

Real code, and the single most relevant file in the reference app for an offline build — a repository
whose only source is bundled assets:

```dart
abstract class ActivityRepository {
  /// Get activities by [Destination] ref.
  Future<Result<List<Activity>>> getByDestination(String ref);
}

/// Local implementation of ActivityRepository. Uses data from assets folder.
class ActivityRepositoryLocal implements ActivityRepository {
  ActivityRepositoryLocal({required LocalDataService localDataService})
    : _localDataService = localDataService;

  final LocalDataService _localDataService;

  @override
  Future<Result<List<Activity>>> getByDestination(String ref) async {
    try {
      final activities = (await _localDataService.getActivities())
          .where((activity) => activity.destinationRef == ref)
          .toList();
      return Result.ok(activities);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
```

Note **`implements`, not `extends`** — no shared base class, no template-method inheritance.

For us: `ReferenceRepository` → `ReferenceRepositoryDrift` (the asset DB) and
`ReferenceRepositoryFixture` (in-memory, for goldens). Same for the user DB. **Every repository gets an
abstract interface and a fake.**

## 1.6 The `Result` type — copy it, don't depend on it

Dart's exceptions are unchecked, so *"developers might forget to catch exceptions, and the different
application layers and components could throw exceptions that aren't documented."* The answer is a
sealed union that puts errors in the type signature.

```dart
sealed class Result<T> {
  const Result();
  const factory Result.ok(T value) = Ok._;
  const factory Result.error(Exception error) = Error._;
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);
  final T value;
  @override
  String toString() => 'Result<$T>.ok($value)';
}

final class Error<T> extends Result<T> {
  const Error._(this.error);
  final Exception error;
  @override
  String toString() => 'Result<$T>.error($error)';
}
```
— [utils/result.dart](https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/result.dart)

Unwrap with an **explicitly typed** pattern, which is what promotes `result.value`:

```dart
switch (result) {
  case Ok<UserProfile>():
    userProfile = result.value;
  case Error<UserProfile>():
    error = result.error;
}
```

**Four things to know before you copy it:**

1. **It shadows `dart:core`'s `Error`.** Every file importing `result.dart` loses `dart:core.Error` —
   which you want for `AssertionError`, `StateError`, `FlutterError.onError`. **[opinion] Rename ours to
   `Failure`.** You then diverge from every doc snippet, which is a real but acceptable cost.
2. **The error channel is `Exception`, not `Object`.** A `TypeError` from a bad cast escapes
   Result-based control flow entirely. Do not treat `Result` as crash-proofing.
3. **It drops stack traces.** For an app that cannot phone home, the local stack trace is all you get.
   Either add a `StackTrace?` field or convert to `AsyncValue.error(e, st)` at the provider boundary
   while the trace is still in scope.
4. **`asOk` is TEST-ONLY.** The docs show `result.asOk.value` in production-looking code, but in the
   real Compass app `asOk` lives in [`testing/utils/result.dart`](https://github.com/flutter/samples/blob/main/compass_app/app/testing/utils/result.dart),
   not `lib/`. It is an unchecked cast that throws on the error path and defeats the entire point.
   **Never ship it.**

`result_dart` (2.2.0, 2026-03-07) exists and is named in the docs. **Vendor the 40 lines instead** —
zero dependency, zero version risk, and it is what the Flutter team ships.

## 1.7 Skip the Command pattern — we have Riverpod

The Command pattern wraps an action and exposes `running` / `completed` / `error`, with an
`if (_running) return;` guard that makes double-tap protection structural. It is **Recommend**, not
Strongly recommend, and the docs say plainly:

> *"it's not a pattern that every app will want to implement. Whether you want to use it is highly
> dependent on other architectural choices you make. **Many libraries that help you manage state have
> their own tools to solve these problems.**"*
> — [ui-layer](https://docs.flutter.dev/app-architecture/case-study/ui-layer)

**[opinion] Skip `Command` in this app.** Riverpod's `AsyncValue<T>` is a strict superset: it models
loading/data/error as a sealed union, survives rebuilds because it lives in the provider rather than the
widget, and `state = await AsyncValue.guard(...)` does what `Command._execute` does. Building `Command`
on top of Riverpod is two state machines that will drift apart.

**Keep two things from the pattern:**
- the **naming** (`load`, `delete`, `export`) so the code still reads like the official architecture;
- the **idempotency rule** — Riverpod does *not* give you double-tap protection for free. Guard it.

**Never nest `AsyncValue<Result<T>>`.** You get four states where two are meaningful. Unwrap the
`Result` in the notifier and set `AsyncValue.error` instead.

## 1.8 There is no official guidance for a 100%-offline app

Worth stating plainly so nobody wastes a day looking. The
[offline-first page](https://docs.flutter.dev/app-architecture/design-patterns/offline-first) is written
for apps that *have* a server and degrade gracefully — every sample on it has an `ApiClientService`.
"Offline-first" there means *cache and sync*, not *no network*.

**The one pattern that transfers** is "local only":

> *"This approach requires that the data has been preloaded at some point into the database, and
> requires a synchronization mechanism…"*

Delete the `sync()` and that is exactly our reference-DB repository — except our preload happens at
build time in the content tool rather than at runtime from a server.

**A second, subtler transfer.** The page recommends a stream that emits local-then-remote so the UI can
render before the slow source resolves. Substitute *cheap local read* and *expensive local computation*
and the shape is exactly how to hit a 1.2 s cold start: emit something renderable before the expensive
work finishes.

**Explicitly do NOT add** `connectivity_plus`, `workmanager`, `battery_plus`, or a `synchronized`
column. Every one costs cold-start time and permissions for nothing.

**Do NOT copy the page's ViewModel snippet** — it does
`await repository.getUserProfile().listen(...).asFuture<void>()`, which leaks if the ViewModel is
disposed mid-stream. Riverpod handles cancellation via `ref.onDispose`; drift's `.watch()` gives you the
re-emitting stream for free.

## 1.9 The domain layer is mandatory for us

Use-cases are **Conditional** in general — *"in most apps they add unnecessary overhead"* — and are
justified when logic (1) merges data from multiple repositories, (2) is exceedingly complex, or (3) is
reused by different view models.

**We hit all three.** The rule engine is complex and is reused by the app *and* the CLI content tool;
and because repositories must never know each other, joining reference data with user data has nowhere
else to live. The domain layer is not optional here.

**One caveat the docs don't cover:** the official use-cases live in `lib/domain/` inside the Flutter app
and freely import `package:logging`. Ours is a *separate pure-Dart package with no Flutter imports* —
stricter and better, but don't expect the docs to help with the package boundary.

## 1.10 Where the official docs contradict themselves

Knowing these prevents pointless team arguments. All verified.

| # | Contradiction | Resolution |
|---|---|---|
| a | The guide says *"most of the logic in your Flutter application lives in view models"*; the recommendations file says the data layer *"contains most of the business logic"*. | **UI logic → ViewModel. Business rules → domain package.** Our rule engine is unambiguously the latter. |
| b | The simplified `Command` catches exceptions; the full `Command0`/`Command1` does not. | If you copy the full class, your action bodies must not throw. (Moot — we skip Command.) |
| c | The offline-first page's repositories `throw` and use bare `catch (e)`; the SQL page and the Compass app use `Result`. | **Follow the SQL page and the app.** |
| d | Docs show `asOk` in production code; the app defines it test-only. | Test-only. See §1.6. |
| e | The key-value page shows `SharedPreferences.getInstance()`; the Compass app migrated to `SharedPreferencesAsync` on 2026-06-19. | **Follow the app.** |
| f | `provider` is "Strongly recommended" for DI, while `data-and-backend/state-mgmt/options` has stopped recommending any package at all. | **Take the *structure* from the architecture docs; choose the *library* yourself.** |

**On `provider` specifically.** Verified 2026-07-27: `provider` 6.1.5+1 was published **2025-08-19**
(~11 months ago; repo alive, last commit docs-only), while the same author shipped `flutter_riverpod`
**3.4.1 on 2026-07-26**. `provider` is *not* abandoned — it is stable and feature-complete — but calling
it "the recommended DI solution" in 2026 is the weakest part of the official guidance.

---

# Part 2 — Project and file structure

## 2.1 The prescribed tree

> *"The `data` folder organizes code **by type**, because repositories and services can be used across
> different features and by multiple view models. The `ui` folder organizes the code **by feature**,
> because each feature has exactly one view and exactly one view model."*
> — [case-study#package-structure](https://docs.flutter.dev/app-architecture/case-study#package-structure)

This settles the feature-first-vs-layer-first argument: **it is both, deliberately, on different axes.**

```
lib/
  ui/
    core/
      ui/                       ← shared widgets. NOT called "widgets" — see §2.3
      themes/
    <feature_name>/
      view_models/
        <feature>_viewmodel.dart
      widgets/
        <feature>_screen.dart
  domain/
    models/
    use_cases/
  data/
    repositories/
    services/
    model/                      ← wire/DB models, mapped at the repository boundary
  config/
  routing/
  utils/
  main.dart · main_development.dart · main_staging.dart
test/     { data, domain, ui, utils }   ← mirrors lib/
testing/  { fakes, models }             ← "a version of your app that you don't ship"
```

**`testing/` is a third top-level directory beside `lib/` and `test/`**, and it is the piece most teams
miss: *"a subpackage that contains mocks and other testing utilities which can be used in other
packages' test code."* Fakes live there, not in `test/`, so goldens and integration tests share them.

## 2.2 File and class naming — from the real filenames

| Role | File | Class | Real example |
|---|---|---|---|
| Screen | `<feature>_screen.dart` | `<Feature>Screen` | `home_screen.dart` → `HomeScreen` |
| Sub-widget | `<feature>_<part>.dart` | `<Feature><Part>` | `search_form_guests.dart` |
| ViewModel | `<feature>_viewmodel.dart` | `<Feature>ViewModel` | `booking_viewmodel.dart` |
| Repository (abstract) | `<entity>_repository.dart` | `<Entity>Repository` | `booking_repository.dart` |
| Repository (impl) | `<entity>_repository_<flavor>.dart` | `<Entity>Repository<Flavor>` | `booking_repository_local.dart` |
| Service | `<thing>_service.dart` | `<Thing>Service` | `local_data_service.dart` |
| Use case | `<entity>_<verb>_use_case.dart` | `<Entity><Verb>UseCase` | `booking_create_use_case.dart` |
| Domain model | `<model>.dart` | `<Model>` | `booking.dart` |
| Fake | `fake_<thing>.dart` | `Fake<Thing>` | `fake_booking_repository.dart` |
| Test | `<source>_test.dart` | — | `search_form_viewmodel_test.dart` |
| Test fixture const | in `testing/models/` | `k<Thing>` | `kBooking`, `kDestination1` |

**The detail everyone gets wrong:** the ViewModel *file* is `booking_viewmodel.dart` (one word) but the
*directory* is `view_models/` (two words). Both are real and consistent across every feature.

## 2.3 Do not name a directory `widgets/`

> *"For clarity, we do not recommend using names that can be confused with objects from the Flutter SDK.
> For example, you should put your shared widgets in a directory called `ui/core/`, rather than a
> directory called `/widgets`."*

## 2.4 Multi-package: use Dart pub workspaces, not melos

We have three packages — the app, the pure-Dart rule engine, and the CLI content builder. `flutter/samples`
itself uses **Dart pub workspaces** (Dart ≥ 3.6) for exactly this shape:

```yaml
# repository root pubspec.yaml
name: catchlaw_workspace
environment:
  sdk: ^3.12.0
workspace:
  - app
  - packages/rule_engine
  - tools/content_builder
  - packages/analysis_defaults
```

```yaml
# app/pubspec.yaml
name: catchlaw
publish_to: none          # mandatory for an app
resolution: workspace     # <- makes it a workspace member
```

One shared `pubspec.lock`, one `.dart_tool`, one `dart pub get` at the root, no `dependency_overrides`
hacks, and the CLI tool and the app provably use the same version of the rule engine.
**Do not reach for melos** for three packages — workspaces are built in and have zero maintenance surface.
Docs: [dart.dev/tools/pub/workspaces](https://dart.dev/tools/pub/workspaces)

Note `analysis_defaults` in that list: `flutter/samples` factors shared lints into a package every member
depends on as a dev dependency. Do the same so all three packages share one config.

## 2.5 The concrete tree for CATCHLAW

```
catchlaw/
├── pubspec.yaml                       # workspace root
├── analysis_options.yaml              # the one in Part 4
│
├── packages/rule_engine/              # PURE DART. No flutter dependency at all.
│   ├── pubspec.yaml                   #   → any package:flutter import is a COMPILE ERROR
│   ├── analysis_options.yaml          #   → must `include: ../../analysis_options.yaml`
│   └── lib/
│       ├── rule_engine.dart           # library doc comment lives here — highest-ROI docs
│       └── src/
│           ├── models/                # immutable, const constructors
│           ├── failure.dart           # our renamed sealed Result
│           └── rule_evaluator.dart
│
├── tools/content_builder/             # Dart CLI: authoring YAML → reference.db
│   └── lib/  bin/
│
└── app/
    ├── lib/
    │   ├── ui/
    │   │   ├── core/{ui,themes}/
    │   │   ├── check/{view_models,widgets}/
    │   │   ├── ruler/{view_models,widgets}/
    │   │   ├── species/ · identify/ · log/ · reference/ · settings/
    │   ├── domain/{models,use_cases}/
    │   ├── data/
    │   │   ├── repositories/
    │   │   │   ├── reference_repository.dart  + _drift.dart + _fixture.dart
    │   │   │   ├── measurement_repository.dart + _drift.dart
    │   │   │   └── settings_repository.dart    + _prefs.dart
    │   │   ├── services/
    │   │   │   ├── reference_database_service.dart   # drift, read-only, lazy
    │   │   │   ├── user_database_service.dart        # drift, writable, lazy
    │   │   │   ├── camera_service.dart · location_service.dart
    │   │   │   ├── pdf_export_service.dart · asset_bundle_service.dart
    │   │   └── model/                 # drift row → domain mapping ONLY here
    │   ├── config/ · routing/ · l10n/
    │   └── main.dart
    ├── test/     {data, domain, ui, utils}
    ├── testing/  {fakes, models}
    └── integration_test/
```

**Eight rules to enforce in review, each traceable to a quote in Part 1:**

1. No widget imports anything from `data/`.
2. No ViewModel imports anything from `data/services/`.
3. `ReferenceRepository` and `MeasurementRepository` never reference each other — joins go in `domain/use_cases/`.
4. Every repository has an abstract interface and a fake in `testing/fakes/`.
5. Every public repository method returns `Future<Result<T>>` or `Stream<T>`.
6. Domain models are immutable; **drift row classes never escape `data/`**.
7. Databases open lazily, never in `main()`.
8. `rule_engine` has zero `package:flutter` imports — guaranteed by its pubspec, not by discipline (§4.6).

## 2.6 Barrel files

The reference app uses **none** — every import is a direct relative path to the specific file. Neither
Effective Dart nor the architecture guidance recommends barrels. **[opinion] Use exactly one:**
`packages/rule_engine/lib/rule_engine.dart`, because it is a real package boundary with two consumers
and a library-level doc comment belongs there. Do not add barrels inside `app/lib/` — they create
import cycles and defeat the analyzer's unused-import detection.

---

# Part 3 — Naming and clean code (Effective Dart)

Everything here is from [dart.dev/effective-dart](https://dart.dev/effective-dart) unless noted. The
severity words are load-bearing: **DO**/**DON'T** = no exceptions; **PREFER**/**AVOID** = deviation needs
a stated reason; **CONSIDER** = decide once as a team.

## 3.1 The one-page checklist

**Identifiers**
- Types, enums, typedefs, type parameters, extensions → `UpperCamelCase`
- Everything else — members, variables, parameters, **constants**, **enum values** → `lowerCamelCase`
- Packages, directories, files, import prefixes → `lowercase_with_underscores`
- Acronyms > 2 letters → like a word: `Http`, `Uri`, `Nasa`, `PdfExporter`. Exactly 2 letters → keep caps
  only if English does (`ID`, `TV`, `UI`); otherwise word-case (`Mr`, `St`)
- Abbreviation at the *start* of a `lowerCamelCase` name → all lowercase: `httpConnection`, `pdfBytes`
- **No `k` prefixes**, no Hungarian notation, no leading `_` on locals/params/prefixes
- Unused callback params → `_` (Dart ≥ 3.7 allows repeats)

**Imports**
- `dart:` block, blank line, `package:` block, blank line, relative block; each sorted alphabetically
- Never `../lib/…`; crossing into `lib` (e.g. from `test/`) → `package:`

**The acronyms table for this app:**

| Concept | ✅ | ❌ |
|---|---|---|
| PDF | `PdfExporter`, `pdfBytes`, `exportPdf()` | `PDFExporter`, `exportPDF()` |
| SQL/SQLite | `SqlBuilder`, `SqliteDatabase` | `SQLBuilder`, `SQLiteDatabase` |
| SVG | `SvgIcon`, `svgAsset` | `SVGIcon` |
| GPS | `GpsFix`, `readGpsFix()` | `GPSFix` |
| RTL | `RtlLayout`, `isRtl` | `RTLLayout`, `isRTL` |
| ARB | `ArbLoader`, `arbFile` | `ARBLoader` |

## 3.2 Function and method naming — the decision procedure

This is the part of Effective Dart that changes code the most and is skipped the most. The `get`-prefix
rule was **revised 2026-06-04** to cover top-level *functions*, not just methods — so it applies to our
pure-Dart rule engine too.

```
Does the member need arguments?
├─ NO ──► Side effects? surprising work? non-idempotent?
│         ├─ NO  ──► GETTER, noun phrase          rectangle.area, db.isOpen
│         └─ YES ──► METHOD, imperative verb      window.refresh(), db.close()
└─ YES ─► Is returning a value the point, or the side effect?
          ├─ VALUE   ──► METHOD, noun phrase      list.elementAt(3)
          ├─ SIDE FX ──► METHOD, imperative verb  list.add(e)
          └─ VALUE, but the WORK matters ──► METHOD, imperative verb
                                             database.downloadData()
```

**AVOID starting a function or method name with `get`.** Two-step fix: if it needs no arguments, make it
a getter with `get` removed; if it does, drop `get` and use a noun phrase, *"or … a verb that more
precisely describes the work than `get`, like `create`, `download`, `fetch`, `calculate`, `request`,
`aggregate`."*

| ❌ Before | ✅ After | Rule |
|---|---|---|
| `getBreakfastOrder()` | `breakfastOrder` (getter) | no args → getter |
| `getMeasurements()` | `loadMeasurements()` | hits SQLite → name the work |
| `getRuleById(String id)` | `ruleById(String id)` | pure lookup, value is the point |
| `getPdfBytes()` | `renderPdf()` | expensive → flag it |
| `getIsValid()` | `isValid` (getter) | boolean property |
| `getTickSpacing(double w)` | `tickSpacingFor(double w)` | noun phrase |

**CONSIDER an imperative verb when you want to draw attention to the work.** This is directly our
cold-start lever — anything that hits SQLite, decodes an SVG, rasterises a PDF or opens the camera
should be a **verb-named method** so the cost is visible at every call site:

```dart
// GOOD — the cost is visible
final rules = await refDb.loadRuleSet();
final bytes = await exporter.renderPdf(doc);
final fix   = await locator.readCurrentFix();

// BAD — reads like a free field access, hides a disk hit and a GPS wait
final rules = refDb.ruleSet;
final fix   = locator.currentFix;
```

**Other naming rules that matter:**
- **`to___()` copies, `as___()` is a live view backed by the original.** `measurement.toJson()` is a
  snapshot; if you write `asJson()` you are lying about lifetime.
- **AVOID describing the parameter in the name.** `list.add(e)` not `list.addElement(e)`. Exception when
  it disambiguates siblings: `map.containsKey` / `map.containsValue`.
- **Booleans:** non-imperative verb phrase — `isEmpty`, `hasElements`, `canClose`, `shouldConsume`.
  *"A boolean name should never sound like a command."* `canShowPopup` not `showPopup`.
  **Prefer the positive form** — `if (socket.isConnected)`, never `if (!socket.isDisconnected)`.
  For a named boolean *parameter*, drop the verb: `growable: true`, `caseSensitive: false`.
- **Most descriptive noun last:** `ReferenceDatabase` not `DatabaseReference`; `RulerTickPainter` not
  `PainterRulerTick`.
- **AVOID abbreviations** unless more common than the full term: `pageCount` not `numPages`.

**Flutter's callback convention** (Flutter repo style guide, not Effective Dart): `FooCallback` for the
typedef, `onFoo` for the property, `handleFoo` for the method that runs. *"Never call a method `onFoo`.
If a property is called `onFoo` it must be a function type."*

## 3.3 Getter vs method — adopt Flutter's stricter rule

The mental model: *"getters are not 'particularly slow fields' in Dart; fields are 'particularly fast
getters'."*

Effective Dart permits an O(n) getter (`IterableBase.length` is O(n)). **Flutter's repo is stricter:**

> *"Property getters should be efficient (e.g. just returning a cached value, or an O(1) table lookup).
> If an operation is inefficient, it should be a method instead… a getter that returns a Future should
> not kick-off the work represented by the future, since getters appear idempotent and side-effect
> free."*

**[opinion] Adopt Flutter's rule.** Effective Dart is reasoning about API shape; we are reasoning about a
startup budget on a low-end Android device. Concretely: **no getter in this codebase may touch SQLite,
decode an SVG, read an asset, or start a Future.** A `Future`-returning getter is allowed only when it
returns an already-started future (`Future<void> get ready => _ready;`).

## 3.4 Documentation

- `///`, never `/** */`. Doc comment goes **above** any annotation.
- **One-sentence summary, then a blank `///` line, then the rest.** Not cosmetic: `dart doc` uses the
  first paragraph as the summary in class and member lists.
- Opening phrase must match the member kind — and this mirrors the naming rules exactly, which is the
  point: **name and doc agree.**

| Kind | Opening | Example |
|---|---|---|
| Function with side effects | third-person verb | `/// Deletes the file at [path].` |
| Non-boolean property/getter | noun phrase | `/// The number of checked buttons.` |
| Boolean | **"Whether …"** | `/// Whether the modal is displayed.` |
| Class/library | noun phrase describing an *instance* | `/// A chunk of non-breaking output text.` |

- Never *"Whether or not"* — the "or not" is superfluous.
- `[squareBrackets]` for identifiers; `[Class.member]`; **`[Point.new]`** for unnamed constructors.
- **Prose, not tags.** No `@param` / `@returns` / `@throws`. Use *"The [name] …"*, *"Returns …"*, *"Throws …"*.
- **Document the getter or the setter, never both** — `dart doc` silently discards the setter's comment.
- Flutter's test for useless docs: *"If someone could have written the same documentation without
  knowing anything about the class other than its name, then it's useless."* And: *"avoid saying 'Note:'
  … It adds nothing."*

**The `rule_engine` library-level doc comment is the highest-ROI documentation in the project** — it is
the only package with two independent consumers, so it is where the shared vocabulary gets defined.

## 3.5 Usage rules with real consequences

- **`final` for locals that aren't reassigned, `var` for those that are.** Effective Dart says either
  convention is fine but *"pick one and apply it consistently."* **[opinion] Use `final`**, enforced by
  `prefer_final_locals` — it is what `flutter/flutter` enforces, it makes `var` a genuine signal of
  mutation, and it is the only one of the two a lint can enforce. (You cannot also have
  `unnecessary_final`; they conflict.)
- **DO use `rethrow`, never `throw e`.** *"`rethrow` preserves the original stack trace… `throw` resets
  the stack trace to the last thrown position."* **For a fully offline app this is the difference
  between a usable and a useless crash report** — the local stack trace is all you get.
- **AVOID catches without `on` clauses.** *"Does your code correctly handle StackOverflowError or
  OutOfMemoryError? … Do you want any `assert()` statements to effectively vanish?"*
- **DON'T discard errors** — log, display, or rethrow.
- **AVOID storing what you can calculate.** *"The problem with caches is invalidation."* Directly
  applicable to the ruler `CustomPainter`: derive tick positions from one source of truth; don't
  precompute a parallel array that goes stale on rebuild.
- **DON'T use `.length` to test emptiness** — `isNotEmpty`, not `!isEmpty`.
- **PREFER async/await over raw futures** — it is what lets you use a *typed* `on X catch (e)`.
- **DON'T use `async` when it has no effect**; **DO use `Future<void>`** for async members with no value.
- **AVOID `late` if you need to check whether it's initialised** — Dart gives you no way to ask.
- Nullable bool: `if (b ?? false)` or `if (b != null && b)`, never `b == true`. Note *"a null-aware
  operator … doesn't promote the variable to a non-nullable type."*

## 3.6 Type annotations

> *"Do annotate when inference doesn't have enough context… Don't annotate locals and generic
> invocations unless you need to. Prefer annotating top-level variables and fields unless the
> initializer makes the type obvious."*

| Situation | Rule |
|---|---|
| Variable **without** initializer | **DO** annotate |
| Field / top-level var, non-obvious type | **DO** annotate |
| Initialized **local** | **DON'T** annotate |
| Return type of a non-local function | **DO** annotate |
| Closure parameters | **DON'T** annotate |
| Initializing formals (`this.x`, `super.key`) | **DON'T** annotate |
| Raw generic (`List x`) | **Never** — *"Dart silently fills in any missing type arguments with `dynamic`"* |
| You genuinely want `dynamic` | **DO** write `dynamic` |

The classic exception where you *do* annotate a local — widening beyond the initializer:

```dart
Widget build(BuildContext context) {
  Widget result = Text('You won!');   // annotated on purpose
  if (applyPadding) {
    result = Padding(padding: EdgeInsets.all(8), child: result);
  }
  return result;
}
```

## 3.7 API design rules worth internalising

- **PREFER making declarations private.** The underrated half: *"the analyzer will tell you about unused
  private declarations so you can delete dead code. It can't do that if the member is public."*
- **AVOID positional boolean parameters.** `Task.oneShot()` / `Task.repeating()`, not `Task(true)`.
- **DO use inclusive start, exclusive end** for ranges.
- **AVOID returning nullable `Future`, `Stream`, or collections** — return empty instead, unless `null`
  genuinely means something different.
- **DO override `hashCode` if you override `==`**; **AVOID custom equality on mutable classes**;
  **DON'T make the `==` parameter nullable** — *"the `==` method is called only if the right-hand side
  is not `null`."*
- **CONSIDER a `const` constructor** when all fields are final. For the rule engine's value types, do
  it — it lets rule tables live in `const` data, which costs nothing at startup.
- **DO use class modifiers** (`final`, `interface`, `base`, `sealed`) instead of documenting your intent
  and hoping. This *replaced* the old "document if your class supports extension" guideline.

---

# Part 4 — Enforcement: lints and static analysis

Everything in this Part was **executed against the local Dart 3.12.2 toolchain**. The config below
passes `dart analyze --fatal-infos` with zero `undefined_lint`, zero `unrecognized_error_code` and zero
incompatible-rule diagnostics, both standalone and merged with the full `flutter_lints` 6.0.0 set.

## 4.1 Eight facts that invalidate most online advice

1. **`custom_lint` is dead.** Repo archived (`pushed_at` 2026-03-24); README says *"no longer under
   active development… the official `analysis_server_plugin` is now the recommended approach."* It pins
   `analyzer 8.4.0` (2025-10-15) versus the current 14.1.0, so it literally cannot parse Dart 3.12
   source. If a guide tells you to add `custom_lint` to `dev_dependencies`, delete both lines.
2. **The plugin system moved in Dart 3.10 / Flutter 3.38.** `plugins:` is now a **top-level** key, not
   `analyzer: plugins:`. Every tutorial older than ~Nov 2025 is wrong.
3. **`riverpod_lint` 3.1.6 (latest, 2026-07-26) does not resolve on this toolchain** — version solving
   fails on `analyzer ^12` vs `^13`. **Pin exactly `3.1.4`**, not a caret range.
4. **`dart_code_metrics` is gone.** Repo archived 2023-07-16; its own SDK constraint is `<3.0.0`, so it
   cannot run on Dart 3 at all. It became the commercial DCM (dcm.dev).
5. **`analyzer: strong-mode: implicit-casts/implicit-dynamic` are silent no-ops.** No warning, no effect.
   Thousands of projects carry them believing they do something. Grep for this first in any inherited codebase.
6. **`flutter_lints` dropped the `prefer_const_*` lints in 5.0.0** — because of developer annoyance, not
   because `const` stopped mattering. We turn them back on (§4.3).
7. **`flutter_lints` is a floor, not a ceiling:** 102 rules out of 224 stable ones. It leaves 125 off.
8. **No lint can prove "no networking."** The provable mechanisms are the dependency graph, the Android
   manifest, and a guard test (§4.6).

## 4.2 What is actually in each rule set

- **`lints` 6.1.0** (2026-01-30) — `core.yaml` 36 rules, `recommended.yaml` +57.
  ⚠️ **The `dart-lang/lints` repo is ARCHIVED**; the live files are in `dart-lang/core` at `pkgs/lints`.
  Reading the old repo gives you a stale 5.1.1 snapshot.
- **`flutter_lints` 6.0.0** (2025-05-27, 14 months old). The include path is
  `package:flutter_lints/flutter.yaml` — **there is no `recommended.yaml` in this package.** Its entire
  Flutter-specific delta is 10 rules: `avoid_print`, `avoid_unnecessary_containers`,
  `avoid_web_libraries_in_flutter`, `no_logic_in_create_state`, `prefer_const_constructors_in_immutables`,
  `sized_box_for_whitespace`, `sort_child_properties_last`, `use_build_context_synchronously`,
  `use_full_hex_values_for_flutter_colors`, `use_key_in_widget_constructors`.
- **`very_good_analysis` 10.3.0** (2026-06-18) — actively maintained, standalone ~200-rule list. Good,
  but aimed at *published packages*: it turns on `public_member_api_docs`, `lines_longer_than_80_chars`,
  `require_trailing_commas` and `discarded_futures`, which are wrong for a private app, and it still
  ships two rules the Dart team deprecated in the 3.13 cycle. **[opinion] Build our own on top of
  `flutter_lints`** — we need per-package divergence anyway.

## 4.3 The recommended `analysis_options.yaml`

Place at the workspace root. Full annotated version in
[`research-flutter/raw/lints-analysis.md`](research-flutter/raw/lints-analysis.md) §7; the essentials:

```yaml
include: package:flutter_lints/flutter.yaml

# TOP-LEVEL — not under `analyzer:`. Dart 3.10+. Cannot appear in a nested options file.
# Restart the Dart Analysis Server after editing.
plugins:
  riverpod_lint: 3.1.4        # EXACT pin — 3.1.6 fails version solving on Dart 3.12.2
  import_lint: ^2.0.0         # architectural import bans (package: URIs only)

import_lint:
  rules:
    ui_must_not_import_drift:
      target: "package:catchlaw/ui/**.dart"
      from: "package:drift/**.dart"
      except: []

analyzer:
  language:
    strict-casts: true        # the three highest-value lines in the file: they close
    strict-inference: true    # type-system holes rather than express style opinions
    strict-raw-types: true
  errors:
    todo: ignore
    # dead weight in an AOT snapshot we're keeping small for a 1.2s cold start
    unused_import: error
    unused_local_variable: error
    unused_element: error
    unused_field: error
    dead_code: error
    # data-loss / crash / architecture — an `info` is advisory, an `error` can't merge
    unawaited_futures: error              # a dropped drift write == silent data loss
    use_build_context_synchronously: error
    cancel_subscriptions: error           # leaked subscription on a drift .watch()
    avoid_dynamic_calls: error
    avoid_web_libraries_in_flutter: error # bans dart:html/dart:js == bans XHR/fetch
    depend_on_referenced_packages: error
    always_use_package_imports: error
    avoid_relative_lib_imports: error
  exclude:
    - build/**
    - "**/generated_plugin_registrant.dart"
    # DELIBERATELY NOT excluding **/*.g.dart — see §4.4

formatter:
  page_width: 100             # what flutter/flutter and flutter/packages use

linter:
  rules:
    # A. Correctness
    - avoid_dynamic_calls
    - cast_nullable_to_non_nullable
    - unawaited_futures
    - unnecessary_statements
    - throw_in_finally
    - only_throw_errors
    - avoid_type_to_string          # meaningless under --obfuscate, which we use
    - switch_on_type                # `switch (x.runtimeType)` never matches subtypes —
                                    # a real trap with sealed-class rule nodes
    - cancel_subscriptions
    - avoid_slow_async_io           # cold-start path
    - avoid_void_async
    - missing_whitespace_between_adjacent_strings   # bites in i18n strings
    - no_adjacent_strings_in_list   # a missing comma silently concatenates
    - avoid_equals_and_hash_code_on_mutable_classes
    - avoid_field_initializers_in_const_classes     # silently defeats const-ness
    # B. Typing — rule_engine is a real API with two consumers
    - always_declare_return_types
    - type_annotate_public_apis
    - avoid_positional_boolean_parameters
    - omit_obvious_local_variable_types
    - specify_nonobvious_local_variable_types
    # C. Imports & architecture
    - always_use_package_imports
    - directives_ordering
    - combinators_ordering
    - simple_directive_paths        # NEW in Dart 3.12
    # D. Ignore hygiene — the antidote to `// ignore:` rot
    - document_ignores              # every ignore needs a reason
    - unnecessary_ignore            # flags ignores whose diagnostic no longer fires
    - flutter_style_todos
    # E. Rendering / cold start
    - use_colored_box               # one less RenderObject than Container
    - sized_box_shrink_expand
    - use_enums
    - prefer_const_constructors     # dropped by flutter_lints 5.0.0 for annoyance, not
    - prefer_const_declarations     # for lack of value. All three are `dart fix`-able
    - prefer_const_literals_to_create_immutables
    # F. Style
    - prefer_single_quotes
    - prefer_final_locals
    - prefer_final_in_for_each
    - sort_constructors_first
    - unnecessary_parenthesis
    - unnecessary_breaks            # Dart 3: `break` at the end of a case is dead code
    - use_setters_to_change_properties
    - use_test_throws_matchers
```

**Nested override for the pure-Dart package** — the `include:` line is **mandatory**:

```yaml
# packages/rule_engine/analysis_options.yaml
# A nested options file REPLACES the parent for its subtree. Without this line the
# package silently loses every rule configured at the root. (Verified.)
include: ../../analysis_options.yaml

linter:
  rules:
    - public_member_api_docs   # two consumers → undocumented members are real debt
    - avoid_print
```

## 4.4 Do not blanket-exclude `**/*.g.dart`

**Verified:** `exclude` still *resolves and type-checks* excluded files — it only suppresses reporting of
diagnostics located inside them. So a genuine compile error in generated code (say, after a drift schema
change) is silently swallowed and only surfaces at `flutter build` time.

You don't need the exclude anyway: **drift already emits `// ignore_for_file: type=lint,unused_import`
in its generated header**, and freezed does the same. `type=lint` turns off all lint rules for a file
while leaving errors and warnings on — exactly the right behaviour, and strictly better than `exclude`.
Add `**/*.mocks.dart` only if you use mockito, whose output does not self-suppress.

## 4.5 Ignore hygiene

The failure mode of every strict lint config is `// ignore:` rot. Two rules are the antidote and are the
most under-rated pair in the index: **`document_ignores`** (every ignore needs an explanatory comment)
and **`unnecessary_ignore`** (flags ignores whose diagnostic no longer fires). Enable both.

Relatedly: **do not create `test/analysis_options.yaml`** — you would lose the whole root config and have
to re-include it. Put per-file `// ignore_for_file:` at the top of the tests that need it, and
`document_ignores` will force you to write down why.

## 4.6 Proving "no networking" — four layers

There is **no Dart lint that bans an arbitrary import**, and there is no `package:banned_imports` on
pub.dev. Use these in order of strength:

**Layer 1 — don't declare the dependency (compiler guarantee).** If `http`, `dio`, `web_socket_channel`
are absent from `pubspec.yaml`, importing them is an unresolved-URI **compile error**. With
`depend_on_referenced_packages: error` you also cannot reach a transitively-arriving networking package.
Audit in CI with `dart pub deps --style=compact`.

*This is also how we guarantee the rule engine has no Flutter imports:* simply do not list `flutter` in
`packages/rule_engine/pubspec.yaml`. **That is a compiler-level guarantee no lint can beat.**

**Layer 2 — omit the Android permission (OS guarantee, and the only third-party-verifiable one).**
No `<uses-permission android:name="android.permission.INTERNET"/>` in the **main and release** manifests
and the OS refuses every socket regardless of what the Dart code says. Note `flutter run` injects it via
`android/app/src/debug/AndroidManifest.xml` for the VM service — that is fine and expected.

**Layer 3 — `import_lint`** for `package:` URI bans. Verified working. ⚠️ It **cannot ban `dart:`
libraries** — `from: "dart:io"` crashes the plugin isolate.

**Layer 4 — a guard test**, which is what covers `dart:io`'s networking half. We cannot ban `dart:io`
wholesale because we need `File`, `Directory` and `Platform` for the databases and PDF export.

```dart
// test/no_network_test.dart — verified working
const bannedIdentifiers = <String>[
  'HttpClient', 'HttpServer', 'WebSocket', 'Socket', 'RawSocket', 'SecureSocket',
  'ServerSocket', 'RawDatagramSocket', 'InternetAddress', 'NetworkInterface',
];
const bannedImports = <String>[
  'dart:html', 'dart:js', 'dart:js_interop', 'package:http/', 'package:dio/',
];
// …walk lib/**.dart, skip comment lines, collect offenders, expect(offenders, isEmpty)
```

**Precedent:** the Flutter team does exactly this rather than using lints —
`flutter/flutter/dev/bots/analyze.dart` contains `verifyNoBadImportsInFlutter()`, and
`dev/bots/custom_rules/` holds hand-written AST rules (`no_stop_watches.dart`,
`avoid_future_catcherror.dart`). **If banning things by convention were achievable with lints alone,
the Flutter team would not maintain that directory.**

Because our no-network claim is a *product* claim and not a preference, it is worth promoting this to an
`analysis_server_plugin` (first-party, `^0.3.20`) that walks resolved ASTs — roughly 80 lines, and it
becomes an IDE squiggle instead of a test failure.

## 4.7 Package status — verified 2026-07-27 via the pub.dev and GitHub APIs

| Package | Latest | Published | Status |
|---|---|---|---|
| `flutter_riverpod` | 3.4.1 | 2026-07-26 | Very active |
| `drift` | 2.34.2 | 2026-07-14 | Very active |
| `go_router` | 17.3.0 | 2026-06-02 | Active (flutter/packages) |
| `flutter_lints` | 6.0.0 | 2025-05-27 | Active, but 14 months old |
| `lints` | 6.1.0 | 2026-01-30 | Active — **repo moved to `dart-lang/core`** |
| `very_good_analysis` | 10.3.0 | 2026-06-18 | Active |
| `mocktail` | 1.0.5 | 2026-04-10 | Active |
| `freezed` | 3.2.5 | 2026-02-03 | Active |
| `provider` | 6.1.5+1 | 2025-08-19 | Stable, low activity |
| `riverpod_lint` | 3.1.6 | 2026-07-26 | Active — **but pin 3.1.4** |
| `analysis_server_plugin` | 0.3.20 | 2026-07-13 | Active, first-party |
| ~~`custom_lint`~~ | 0.8.1 | 2025-09-09 | **ARCHIVED — do not use** |
| ~~`dart_code_metrics`~~ | 5.7.6 | 2023-07-16 | **DEAD — cannot run on Dart 3** |

---

# Part 5 — State management: Riverpod + drift

## 5.1 The decision

**Use `flutter_riverpod` 3.4.1 with `riverpod_generator`. Not bloc, not signals, not provider.**

Flutter's official docs **do not name a state-management package at all** — `state-mgmt/options` lists
only SDK primitives and then punts. Anyone saying "Flutter officially recommends X" is wrong. What
Flutter prescribes is *architecture*, and that is package-agnostic (Part 1).

| Layer | Use | Why |
|---|---|---|
| Database handles | `Provider<UserDatabase>` / `Provider<ReferenceDatabase>`, **keepAlive**, injected via `ProviderScope(overrides:)` | Single instance, closable, swappable in tests |
| Anything read from SQL | **`StreamProvider`** wrapping `query.watch()` | drift already *is* the observable store |
| Writes | Plain methods on a repository behind a plain `Provider` | The write returns `void`; the drift stream pushes the new state back |
| UI-only state not in SQL (filter, unit, wizard step, ruler calibration) | `@riverpod class X extends _$X` — a **Notifier** | This is the only state you actually "manage" |
| Ephemeral (TextEditingController, animation, "is this expanded") | `StatefulWidget` + `setState` | Riverpod's own docs say providers are the wrong tool |
| `rule_engine` package | **No state library at all** | Keeps it Flutter-free and CLI-usable |

**The insight that matters most here:** with drift, ~80% of what other apps call state management
disappears. SQLite is the store, `watch()` is the change notification, Riverpod is a thin testable
cache/DI layer. **If you write an `AsyncNotifier` holding a `List<Row>` copied out of the database, you
have made a mistake.**

**Version gotcha for `pubspec.yaml`:** the Riverpod family does *not* share a major version.
`riverpod_generator` is **4.0.6**, `flutter_riverpod`/`riverpod` are **3.4.1**, `riverpod_lint` is
**3.1.x**. `riverpod_annotation` pins `riverpod` to an *exact* version, so bumping one forces bumping
all. **Pin all four and bump as a set.** And per Part 4, `riverpod_lint` is no longer a `dev_dependency`
— it goes in `analysis_options.yaml` under `plugins:`.

## 5.2 The vertical slice

**Databases: open lazily, never block the first frame.**

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // LazyDatabase defers ALL file I/O until the first query.
  // createInBackground moves SQLite onto a background isolate.
  final userDb = UserDatabase(LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    return NativeDatabase.createInBackground(File(p.join(dir.path, 'user.sqlite')));
  }));

  final refDb = ReferenceDatabase(LazyDatabase(() async {
    final path = await _copyAssetDbIfNeeded('assets/db/reference.sqlite');
    return NativeDatabase.createInBackground(File(path), readOnly: true);
  }));

  runApp(ProviderScope(
    retry: (retryCount, error) => null,     // offline app: never retry
    overrides: [
      userDatabaseProvider.overrideWithValue(userDb),
      referenceDatabaseProvider.overrideWithValue(refDb),
    ],
    child: const CatchlawApp(),
  ));
}
```

**Never `await` a database open before `runApp`.** Let the first frame paint a skeleton and let the
`StreamProvider`'s `AsyncLoading` cover the open.

**The repository takes no `Ref` and imports no Riverpod** — that is what makes it unit-testable:

```dart
abstract interface class MeasurementRepository {
  Stream<List<Measurement>> watchAll();
  Future<void> add(MeasurementDraft draft);
}

class DriftMeasurementRepository implements MeasurementRepository {
  DriftMeasurementRepository(this._dao);
  final MeasurementDao _dao;

  @override
  Stream<List<Measurement>> watchAll() => _dao.watchAll();
  @override
  Future<void> add(MeasurementDraft draft) => _dao.insert(draft);
}
```

**Providers — this is the entire read path:**

```dart
@Riverpod(keepAlive: true)
MeasurementRepository measurementRepository(Ref ref) =>
    DriftMeasurementRepository(ref.watch(userDatabaseProvider).measurementDao);

/// Auto-disposing: when the screen leaves, the SQL stream stops.
@riverpod
Stream<List<Measurement>> measurements(Ref ref) =>
    ref.watch(measurementRepositoryProvider).watchAll();
```

**Return the stream. Do not `await for` it.** Writing
`await for (final rows in stream) { state = AsyncData(rows); }` inside an `AsyncNotifier` re-implements
`StreamProvider`, loses error propagation, and leaks the subscription.

**The widget is dumb and exhaustive:**

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final items = ref.watch(visibleMeasurementsProvider);
  return Scaffold(
    body: switch (items) {
      AsyncData(:final value) when value.isEmpty => const EmptyState(),
      AsyncData(:final value) => MeasurementList(items: value),
      AsyncError(:final error) => ErrorView(error: error),
      AsyncLoading() => const MeasurementListSkeleton(),
    },
    floatingActionButton: FloatingActionButton(
      // read, not watch — this is a callback
      onPressed: () => ref.read(measurementRepositoryProvider).add(draft),
      child: const Icon(Icons.add),
    ),
  );
}
```

**Writes need no state at all.** The insert marks the table dirty, drift re-runs every watching query,
the `StreamProvider` emits, the widget rebuilds. No `emit`, no `state =`, no `notifyListeners()`.

## 5.3 The `==` rebuild trap — non-obvious and important

Riverpod 3 filters provider updates with `==`, and `AsyncValue.==` compares its value with `==`.

- `StreamProvider<Measurement?>` (single row): drift's generated row classes implement `==`, so a
  re-emitted identical row is **filtered — no rebuild.** Free win.
- `StreamProvider<List<Measurement>>`: **`List.==` is identity.** Two different `List` instances with
  identical contents are never `==`, so **every drift re-query rebuilds every list consumer** even when
  nothing changed.

Compounded by drift's own warning: *"Stream queries generally update more often than they have to…
Whenever an insert, an update, or a deletion is made through drift APIs, the associated queries are
rescheduled and will run again."*

Mitigations, in order:
1. **Keep list queries narrow** — one write should not re-run a five-table join. Split DAO methods.
2. **`select()` at the consumer:** `ref.watch(p.select((a) => a.value?.length ?? 0))`.
3. **Deduplicate in the provider:** `.distinct(const ListEquality<Measurement>().equals)`. Worth an O(n)
   comparison only when the subtree is expensive.
4. **For the ruler specifically:** don't drive the painter from a rebuild at all. Bridge to a
   `Listenable` (`ref.watch(p.listenable)`, new in 3.4.0) and pass it to `CustomPainter(repaint: …)`.
   That repaints without rebuilding the widget tree.

## 5.4 The pause/resume synergy — a free win

Riverpod 3 pauses providers whose consumers aren't visible (keyed on `TickerMode`); for a
`StreamProvider` that means `StreamSubscription.pause()`. For most streams a pause means *buffering* —
you'd get a burst of stale events on resume. **drift does not do that**: its `QueryStream` invalidates
cached data while paused and re-runs exactly one fresh query on resume.

**Net effect:** push a detail route over the list and the list's SQL genuinely stops executing; pop back
and exactly one fresh query runs. You get this by using `StreamProvider` and doing nothing clever — a
hand-rolled `StreamBuilder` would keep querying forever.

## 5.5 Riverpod anti-patterns

- ❌ An `AsyncNotifier` mirroring database rows into `state`.
- ❌ `await for` over a stream inside a notifier.
- ❌ `ref.watch` inside a callback — use `ref.read`.
- ❌ Nesting `AsyncValue<Result<T>>`.
- ❌ Putting Riverpod inside a repository or the domain package.
- ❌ Two DI mechanisms (Riverpod *and* get_it).

---

# Part 6 — Testing

## 6.1 How to name tests — with receipts

**The rule:** `<Subject> <present-tense verb phrase> [when/with <condition>]`. Subject first.
**No `should`. No `it`. No given/when/then.**

This is not a preference — it is written down and maintained by the Flutter team in
[`Writing-Effective-Tests.md`](https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Writing-Effective-Tests.md):

> *"It is common to find tests that are simply named after the object under test rather than the
> behavior under test… The developer probably already knows which object is being tested, so these
> names are no better than an empty string."*
>
> ```dart
> // Bad test name
> test('ListView', () {...});
> // Better test name
> test('Shrink-wrapped ListView resizes to match its content height', () {...});
> ```

Two more rules from the same doc: **one behaviour per test** (*"when multiple behaviors exist within a
test then reported test failures become misleading"*) and **only include relevant details**.

**What they actually do** — real names from `packages/flutter/test/material/app_bar_test.dart`:

```
'AppBar centers title on iOS'
'AppBar centerTitle:false title start edge is 16.0 (RTL)'
'AppBar titleSpacing:32 title start edge is 32.0 (LTR)'
'AppBar respects toolbarHeight'
'AppBar does not update the leading if a route is popped case 1'
'Material3 - AppBar drawer icon has default color'
'SliverGeometry throws error when layoutExtent exceeds paintExtent'
```

Five observations, all directly applicable:
1. **Subject-first**, always — the class or member under test.
2. **Simple present, third person**: `centers`, `has`, `respects`, `defaults to`, `does not update`.
   **Zero occurrences of `should`.**
3. **Conditions encoded with literal argument syntax**: `centerTitle:false`, `titleSpacing:32`,
   `(LTR)`/`(RTL)`. This makes `grep titleSpacing` find every test about it.
4. **Variant prefixes for cross-cutting axes**: `Material3 - `. Ours is `RTL - ` or `ar - `.
5. Names are long and nobody minds. `"when"` is fine as a *condition* clause; it is `should` that is absent.

**Groups.** Used sparingly, at most one level deep, and `group + test` must read as **one sentence** —
that is the design intent, since group descriptions are prefixed onto test names. `package:test`'s own
README: `group('String')` + `test('.split() splits the string on the delimiter')` →
`String .split() splits the string on the delimiter`. **Never `group('<Thing> tests')`** — that is
exactly the "named after the object under test" anti-pattern.

A Flutter idiom worth stealing: `group()` accepts any `Object`, so `group(CalendarDatePicker, () {…})`
passes a `Type` and is refactor-safe.

**A genuine disagreement, and the call.** `flutter/samples/compass_app` — the official architecture
reference — uses `group('ResultsViewModel tests', () { test('should load items', …) })`.
**Follow `flutter/flutter`, not compass_app.** Reasoning: compass_app's names are worse on their own
terms (`'should load items'` says nothing about which items or under what condition); `group('X tests')`
is the documented anti-pattern; `should` costs 7 characters and adds zero information, since every test
asserts something should happen; and flutter/flutter's convention is backed by a maintained normative
document while compass_app's is backed by nobody writing it down.

**Applied here:**

```dart
// test/domain/ruler_scale_test.dart
group('RulerScale', () {
  test('.tickCount returns 10 ticks per centimetre at 1.0 zoom', () { … });
  test('.labelFor throws RangeError when index is negative', () { … });
});

// test/data/measurement_dao_test.dart
test('MeasurementDao.watchAll emits again after an insert', () async { … });
test('MeasurementDao.deleteAll leaves the reference database untouched', () async { … });

// test/ui/check/check_screen_test.dart
testWidgets('CheckScreen shows the empty state when no rule matches', (tester) async { … });
testWidgets('RTL - CheckScreen places the ruler on the left edge', (tester) async { … });
testWidgets('CheckScreen meets androidTapTargetGuideline', (tester) async { … });
```

**For loop-generated tests, always interpolate the parameter into the description** — otherwise you get
N identically-named tests and `--plain-name` is useless. flutter/flutter does exactly this:
`testWidgets('shows dates for $locale', …)`.

## 6.2 File organisation

- **`_test.dart` is a hard requirement** — `flutter test` finds files by that pattern. A helper file must
  **not** end in `_test.dart` or the runner executes it as an empty suite and fails. Name helpers
  `harness.dart`, `fakes.dart`, `golden.dart`.
- **`test/` mirrors `lib/`.** **`testing/` sits beside them** (Part 2) so both `test/` and
  `integration_test/` can import fakes that are never compiled into the app.
- **Split large test files** by behaviour — official guidance: `button_layout_test.dart`,
  `button_semantics_test.dart`, `button_interaction_test.dart`, not one `button_test.dart`.
- **Golden files live next to the test file** — not a style choice, it is enforced: `LocalFileComparator`
  *"treats the golden key as a relative path from the test file's directory."*
  Add `**/failures/` to `.gitignore` — the comparator writes diff PNGs there on mismatch.
- **`flutter_test_config.dart`** is directory-scoped setup, scanned *up* from the test file, stopping at
  the first hit or at `pubspec.yaml`. This is where font loading for goldens goes.

## 6.3 Tooling verdicts

| Question | Verdict |
|---|---|
| `golden_toolkit` | **DEAD.** Marked *discontinued* on pub.dev, last publish 2023-02-21, SDK constraint `<3.0.0` — it cannot resolve on Dart 3. |
| `alchemist` | Alive but slow-moving (0.14.0, 2026-03-13). **Bad fit for Arabic goldens** — its CI mode replaces glyphs with blocks. |
| Goldens in 2026 | **Built-in `matchesGoldenFile` + a ~60-line harness.** |
| `mocktail` vs `mockito` | **mocktail** — no codegen, no `build_runner` in the test loop. Both maintained. |
| `integration_test` | Ships **inside the SDK**. The pub.dev package (1.0.2+3, 2021) is a stale corpse — never depend on it by version. |
| `patrol` | Very active (4.8.0, 2026-07-24). Only worth it for **native** UI — permission dialogs. We need camera + GPS permissions, so: a maybe. |
| Coverage | 100% of the pure-Dart rule engine. ~80% of `lib/` excluding generated. Don't chase 100% app-wide. |

## 6.4 The budget

Because the app is offline there is no network flakiness — the classic argument for a fat
integration-test layer does not apply. **Push weight down the pyramid:**

| Layer | What | Runs where |
|---|---|---|
| Pure-Dart unit | Rule engine — the bulk, aim 100% branch coverage | `dart test`, milliseconds, no Flutter |
| drift unit | Queries + migrations via `NativeDatabase.memory()` | `flutter test` |
| Riverpod unit | `ProviderContainer.test()`, one per provider with real logic | `flutter test` |
| Widget | One per screen + `paints` matcher tests for the painter | `flutter test` |
| Golden | 4–6 screens × 6 locales × 2 themes — keep the *matrix* small | Linux CI only |
| Integration | 2–4 happy paths incl. real file I/O, PDF, camera stub | Device |

**Two hard-won golden points:**
1. **Goldens need a real font or every locale renders identical empty boxes.** `flutter test` uses a
   test font with no Arabic coverage, so your `ar` golden would be indistinguishable from `en` and the
   test worthless. Load a font with Arabic glyphs via `FontLoader` in `flutter_test_config.dart`.
2. **Goldens are host-platform-dependent.** Generate and verify on one platform (Linux CI) and make that
   the only source of truth, or they churn on every macOS machine.

---

# Part 7 — Clean code in Dart 3

## 7.1 Set your SDK floor deliberately

```yaml
environment:
  sdk: ^3.12.0
```

**Dart language features are language-versioned per package.** If your lower bound says `^3.0.0`, dot
shorthands and private named parameters are *compile errors in your files* even though the SDK supports
them. This is the #1 "why doesn't this feature work for me" trap.

| Feature | Landed | Available on 3.12.2? |
|---|---|---|
| Sealed classes, patterns, records, exhaustive `switch` | 3.0 | ✅ |
| Extension types (zero-cost value objects) | 3.3 | ✅ |
| Pub workspaces | 3.6 | ✅ |
| Null-aware collection elements `[?maybeNull]` | 3.8 | ✅ |
| Dot shorthands (`.start`, `.a4`) | 3.10 | ✅ |
| Private named parameters | 3.12 | ✅ |
| **Primary constructors** (`class Point(var int x…)`) | 3.13 | ❌ **unreleased** |

**Do not write primary-constructor syntax yet.** freezed already has a `4.0.0-dev` line supporting it,
but it will not compile on this toolchain.

## 7.2 Sealed classes replace a lot of old boilerplate

Model closed domain unions as `sealed` and switch exhaustively — the analyzer errors if you miss a case.
This is how the rule engine's outcome type should be built, and it is why `Result`/`Failure` (§1.6) is
40 lines rather than a package. Records replace tuple classes and out-parameters. Class modifiers
(`final`, `interface`, `base`, `sealed`) express extension intent that used to be a doc comment and a
prayer.

## 7.3 Code generation: real measured numbers

**"build_runner is slow" is out of date.** It was substantially rewritten in 2026: 2.13.0 gave
*"speedup of between 1.4x for small initial builds to 4x for large incremental builds"*; 2.14.0 defaults
to AOT compilation.

Measured on this machine (30 `@freezed` models + `fromJson`, freezed 3.2.5, build_runner 2.15.3):

| Scenario | Wall time |
|---|---|
| First-ever build (compiles the builder AOT snapshot too) | 18.1 s |
| Cold build after `rm -rf .dart_tool/build` | 12.7 s |
| **No-op rebuild** | **0.59 s** |
| **One-file change rebuild** | **0.62 s** |

**Conclusion: codegen costs ~13 s once on CI and ~0.6 s during development. That is not a reason to
avoid it.** The real cost of freezed is not build time — it is **21× code amplification** (452
hand-written lines → 9,510 generated), IDE indexing, and the fact that one analyzer bump can block the
pipeline. Budget 30–60 s cold on CI once `drift_dev` and `riverpod_generator` are added.

## 7.4 Check generated files INTO git

Settled by evidence, not opinion — verified by reading the repos today:

| Repo | `.g.dart` committed? |
|---|---|
| `flutter/samples` (compass_app) | ✅ Yes |
| `rrousselGit/riverpod` | ✅ 170 files |
| `simolus3/drift` | ✅ 31 files |

**Why:** a fresh clone + `flutter run` works with no 13 s build step; code review shows what the
generator actually produced, so you catch generator regressions; goldens and CI need no codegen stage;
IDE analysis works immediately.

The one legitimate counter-argument is merge conflicts. **The fix is `.gitattributes`, not
`.gitignore`:**

```gitattributes
*.g.dart        linguist-generated=true -diff
*.freezed.dart  linguist-generated=true -diff
```

## 7.5 Error handling

Use `Result`/`Failure` inside the data layer and the pure-Dart package (it cannot import Riverpod, so it
needs *some* error-carrying return type, and sealed classes make it free). Let Riverpod's `AsyncValue`
carry it into the UI. **Do not double-wrap** (§1.7). `rethrow`, never `throw e` — it preserves the stack
trace, which for an app that cannot phone home is the only diagnostic you will ever get.

---

# Part 8 — Widgets and performance

## 8.1 Never return widgets from a helper method — and the actual reason

There is **no lint** for this, so it has to be a review rule. There are exactly three first-party
statements and they agree; the strongest is a `{@template}` deliberately shared between `StatelessWidget`
and `StatefulWidget` in `framework.dart`:

> *"When trying to create a reusable piece of UI, prefer using a widget rather than a helper method…
> a `State.setState` call would require Flutter to entirely rebuild the returned wrapping widget. If a
> `Widget` was used instead, Flutter would be able to efficiently re-render only those parts that
> really need to be updated."*

**Three mechanisms are in play, and people conflate them.**

**Mechanism 1 — the identity short-circuit.** `Element.updateChild` contains
`if (hasSameSuperclass && child.widget == newWidget)`, and `Widget.operator ==` is `@nonVirtual` and
delegates to `Object.==` — i.e. **`identical()`**. When it hits, the entire subtree below is skipped: no
`update`, no `build`, no layout, no paint. The only two ways to get the same instance back are a `const`
constructor (Dart canonicalises const expressions) or caching in a `final` field. **Measured:**
`identical(makeConst(), makeConst())` is `true`; `identical(makeNew(), makeNew())` is `false`.

**Mechanism 2 — `BuildContext` scoping. This is the one nobody talks about and it is unconditionally
true.** A helper method has no `BuildContext` of its own; it uses the *caller's*. So `Theme.of(context)`,
`MediaQuery.sizeOf(context)`, `AppLocalizations.of(context)` all register **the parent element** as the
dependent, and the parent's entire build method re-runs when the inherited value changes. A widget
subclass gets its own `Element`, its own `BuildContext`, its own dependency registration.

**Measured**, changing an inherited value by one:

```
HELPER after : host=2 banner=2 sibling=1     <-- host rebuilt
CLASS  after : host=1 banner=2 sibling=1     <-- host did NOT rebuild
```

**For this app that is decisive:** a helper method touching `AppLocalizations.of(context)` anywhere in a
screen makes the *whole screen* rebuild on every locale change. With six locales and an RTL flip, that
is not academic.

**The honest nuance.** Measured with both sides non-const: `helper: subtree=3 leaf=1 | non-const class:
subtree=3 leaf=1` — **identical.** A non-const widget subclass rebuilds exactly as often as a helper
method under `setState`. Equally, a helper returning a fully-`const` expression is short-circuited just
like a const widget. So the accurate statement is:

> Extracting to a `StatelessWidget` **enables** the const short-circuit and **always** scopes
> inherited-widget dependencies. Extracting to a widget you then instantiate non-const, from a parent
> with no inherited dependencies, buys approximately nothing at runtime.

**Follow the rule anyway**, because Mechanism 2 is unconditional and dominant here; because you can add
`const` later but cannot add an `Element` later without a refactor; because DevTools' *Track Widget
Builds* is useless if half your UI is anonymous closures, and on a 1.2 s budget you will need it; and
because the cost is one class declaration.

**Practical shape** — private widget classes in the same file, not a file per widget:

```dart
class CheckScreen extends ConsumerWidget {
  const CheckScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Scaffold(body: Column(children: [_Header(), _RulerPane(), _Footer()]));
}

class _Header extends StatelessWidget {   // private, same file, const-able
  const _Header();                        // no `key` — the lint exempts private classes
  @override
  Widget build(BuildContext context) => Text(AppL10n.of(context).checkTitle);
}
```

**Composition, not inheritance:** never `extends` a concrete widget (`class MyCard extends Card` is
wrong). Extend only `StatelessWidget`/`StatefulWidget`/`RenderObjectWidget` and *contain* what you
wanted to specialise. And minimise node count — *"instead of an elaborate arrangement of `Row`s,
`Column`s, `Padding`s… consider using just an `Align`… Instead of an intricate layering of multiple
`Container`s… consider a single `CustomPaint`."*

## 8.2 `const`

Three wins in decreasing order: the subtree short-circuit above (**measured**: `const child Leaf.build
calls = 1 | non-const = 2` after one `setState` — extrapolate to 60 saved subtree rebuilds/second during
a drag); **zero allocation per build**, which on a low-end Android heap is the difference between a
smooth scroll and a young-gen GC mid-frame; and better AOT constant folding.

`flutter_lints` dropped `prefer_const_*` in 5.0.0 for *developer annoyance*, not because const stopped
mattering. Part 4 turns all three back on — they are bulk-fixable with `dart fix --apply`, so the
annoyance cost is ~0.

## 8.3 The `CustomPainter` for the ruler

- **`Directionality` does not affect a `CustomPainter`'s canvas.** `paint(Canvas, Size)` gives you a raw
  canvas whose origin is always top-left. A painter cannot read `Directionality` — it has no
  `BuildContext`. **Pass `textDirection` in explicitly and include it in `shouldRepaint`.**
- If you ever need a mirrored painter, use the canonical SDK pattern (`canvas.scale(-1, 1)` +
  `translate`), which appears in `decoration_image.dart` and `progress_indicator.dart`. **Draw text
  *after* `restore()` or every glyph comes out mirrored.** `Matrix4.rotationY(pi)` appears in **zero**
  places in the framework source — it is a blog-post idiom that introduces a 4×4 perspective transform
  where a 2D scale suffices.
- Cache `Paint` and `TextPainter` objects; don't allocate in `paint()`.
- Drive repaints via `CustomPainter(repaint: listenable)` rather than widget rebuilds (§5.3).

---

# Part 9 — Localisation, RTL, and build

## 9.1 The numbering-system trap — the finding that will most affect the Arabic build

**Dart's `intl` has no numbering-system API, and the `-u-nu-` Unicode extension is silently ignored.**
Verified output, intl 0.20.2 on Dart 3.12.2:

```
ar     num=1,234,567.89          <-- LATIN digits
ar_EG  num=١٬٢٣٤٬٥٦٧٫٨٩          <-- Arabic-Indic
ar_DZ  num=1.234.567,89          <-- Latin digits, European separators
ar_SA / ar_MA / ar_AE            <-- silently fall back to `ar`
ar-u-nu-arab -> 1,234,567        <-- extension ACCEPTED AS A STRING AND DISCARDED
```

**Plain `ar` uses Latin digits.** This is correct per CLDR and it surprises almost everyone. Dart's
`number_symbols_data.dart` contains **only three** Arabic entries: `ar`, `ar_DZ`, `ar_EG`.

This corrects `SPEC.md` §9.3 in the right direction and gives the mechanism: the lever is the public
mutable `numberFormatSymbols` map, and `ZERO_DIGIT` *is* the numbering system —
`NumberFormat` computes `zeroOffset = symbols.ZERO_DIGIT.codeUnitAt(0) - asciiZero`.

```dart
/// Call ONCE during bootstrap, before any NumberFormat is constructed.
void useArabicIndicDigits() {
  numberFormatSymbols['ar'] = numberFormatSymbols['ar_EG']!;
}
```

**Recommendation: ship Latin digits for `ar` (do nothing) and expose the Settings toggle
`SPEC.md` already specifies.** Mutating `numberFormatSymbols` is process-wide and order-dependent — it
must happen before the first `NumberFormat` is built and it will **silently corrupt golden tests running
in a shared isolate**. If you do it, do it in `main()` before `runApp`, and reset it in
`setUp`/`tearDown` of any digit-sensitive test.

## 9.2 RTL

`GlobalWidgetsLocalizations` maps locale → direction. **All locales are LTR except six language codes:**
`ar`, `fa`, `he`, `ps`, `sd`, `ur`. Note what is *absent*: `ckb`, `dv`, `yi`, and the legacy code `iw`.

**Measured:**
```
EdgeInsetsDirectional(start:40)  ltr.left=40.0  rtl.left=0.0    <-- flips
EdgeInsets(left:40)              ltr.left=40.0  rtl.left=40.0   <-- never flips
```

| Physical (ban) | Directional (use) |
|---|---|
| `EdgeInsets.only(left:, right:)` | `EdgeInsetsDirectional.only(start:, end:)` |
| `Alignment.centerLeft` | `AlignmentDirectional.centerStart` |
| `BorderRadius.only(topLeft:)` | `BorderRadiusDirectional.only(topStart:)` |
| `Positioned(left:, right:)` | `PositionedDirectional(start:, end:)` |

`EdgeInsets.all()` and `EdgeInsets.symmetric(horizontal:)` are direction-neutral and fine. **A physical
`left` inset is a bug that manifests in 1 of 6 locales and will never be caught by a test running in `en`.**

**Forcing the ruler LTR** — this is the right mechanism, and `SPEC.md` §9.3 called it correctly:

```dart
Directionality(
  textDirection: TextDirection.ltr,   // the instrument is physical; locale must not mirror it
  child: CustomPaint(painter: RulerPainter(
    textDirection: TextDirection.ltr,
    numberFormat: NumberFormat.decimalPattern(   // but DIGITS follow the app locale
      Localizations.localeOf(context).toString()),
  )),
)
```

**Why `Directionality` and not a `Transform`:** `Directionality` changes *layout* semantics for the
subtree with **zero** effect on hit-testing coordinates. A flip matrix mirrors pixels but leaves
hit-test geometry transformed and renders tick labels as unreadable mirrored glyphs.

**`Bidi` helpers** (`intl`): `Bidi.enforceLtrInText()` around user-supplied Latin content inside an RTL
paragraph fixes bracket/number scrambling — e.g. a user's catch note shown in Arabic chrome. Don't
blanket-apply it; Flutter's text engine does full UBA bidi correctly for well-formed content. Note the
casing: `enforceLtrInText`, **not** `enforceLTRInText`.

## 9.3 The Android manifest — confirms the SPEC

Part 4 §4.6 and `SPEC.md` §11 agree and are confirmed: omitting `android.permission.INTERNET` from the
**main and release** manifests is the only mechanism that produces a claim a third party can verify
without reading source. `flutter run` injects it via `android/app/src/debug/AndroidManifest.xml` for the
Dart VM service — that is expected and fine.

---

# Appendix — the 15 rules to enforce in review

1. No widget imports anything from `data/`. No ViewModel imports anything from `data/services/`.
2. Repositories never reference each other — joins go in `domain/use_cases/`.
3. Every repository has an abstract interface and a fake in `testing/fakes/`.
4. Every public repository method returns `Future<Result<T>>` or `Stream<T>`.
5. drift row classes never escape `data/`. Domain models are immutable.
6. Databases open lazily. **Never `await` a DB open before `runApp`.**
7. No getter touches SQLite, decodes an SVG, reads an asset, or starts a Future.
8. Expensive operations get **verb** names so the cost is visible at the call site.
9. No function returns a `Widget` — extract a private `StatelessWidget` in the same file.
10. No `EdgeInsets.only(left:/right:)` or `Alignment.*Left/*Right` in UI code.
11. The ruler subtree is explicitly `Directionality(textDirection: ltr)`; the painter takes
    `textDirection` as a parameter and includes it in `shouldRepaint`.
12. No `should` in a test name. Subject-first, present tense, one behaviour per test.
13. Helper files in `test/` never end in `_test.dart`.
14. `rethrow`, never `throw e`.
15. `rule_engine` has zero `package:flutter` imports — guaranteed by its pubspec, not by discipline.

---

*Full research, with every source URL and the measured experiments, is in
[`research-flutter/raw/`](research-flutter/raw/) — 10 files, ~15,500 lines.*
