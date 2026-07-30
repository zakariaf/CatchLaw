# Google's Official Flutter Reference Architecture App — Compass App

**Research date:** 2026-07-27
**Local toolchain:** Flutter 3.44.6 stable (2026-07-08)
**Method:** Every file below was read directly from GitHub via `gh api`. No file is paraphrased from a blog. Where I could not verify something, it says "unverified".

---

## 0. TL;DR — what I actually found

| Question | Answer (verified) |
|---|---|
| Does the Compass App exist? | **Yes.** `flutter/samples` → `compass_app/` (app at `compass_app/app`, dummy server at `compass_app/server`). |
| Is it maintained? | **Yes, actively.** Most recent commits touching `compass_app`: **2026-06-19** (7 commits that day, incl. "Migrate compass_app to SharedPreferencesAsync (#2841)", "[compass_app] Scope LogoutViewModel to route builder — fix #2604 (#2819)"). Prior: 2026-04-15, 2026-01-27. |
| Is it *the* reference for the official docs? | **Yes.** `docs.flutter.dev/app-architecture/case-study` is written from this exact code. Source of that doc: `flutter/website` → `sites/docs/src/content/app-architecture/case-study/*.md` (last touched 2026-07-23). |
| State management used | **`ChangeNotifier` + `ListenableBuilder`** (no third-party state package). NOT riverpod, NOT bloc. |
| DI used | **`package:provider`** `MultiProvider` at app root + `context.read()` inside `go_router` route builders. |
| Is it 100% current? | **No.** Several parts are behind (see §11 "Stale / superseded"). Most notably the checked-in `.freezed.dart` files are **freezed 2.x output** while `pubspec.yaml` declares `freezed: ^3.0.0`, and localization is a **hand-rolled hardcoded English map**, not ARB/`gen_l10n`. |
| Is there a newer "compass_25"? | Yes, `flutter/demos/compass_25` — but it is a **flat, non-MVVM Cupertino/adaptive I/O demo**, and `flutter/demos` self-describes as *"unmaintained code that supports talks, blogs, and other experiments."* **Do not use it as an architecture reference.** |

Primary sources:
- https://github.com/flutter/samples/tree/main/compass_app
- https://github.com/flutter/website/tree/main/sites/docs/src/content/app-architecture
- https://docs.flutter.dev/app-architecture

---

## 1. Where it lives — verified repo layout

```
flutter/samples @ main
└── compass_app/
    ├── README.md
    ├── app/                 ← the Flutter app (this is what matters)
    ├── server/              ← a throwaway shelf/dart_frog-style HTTP server used only by the "staging" flavor
    └── docs/                ← 4 PNG screenshots
```

Reproduce this yourself:

```bash
gh api "repos/flutter/samples/git/trees/main?recursive=1" --jq '.tree[].path' | grep -i compass
```

(Note for zsh users: the `?recursive=1` **must be quoted** or zsh will try to glob it.)

---

## 2. COMPLETE directory tree of `compass_app/app`

This is the real tree, transcribed from the repo tree API (platform folders `android/ ios/ macos/ linux/ windows/ web/` collapsed — they are stock `flutter create` output with nothing architecture-relevant).

```
compass_app/app/
├── analysis_options.yaml
├── devtools_options.yaml
├── pubspec.yaml
├── .metadata                      # says channel: "beta", revision ee624bc4fd41...
│
├── assets/
│   ├── activities.json            # seed data for the "local" (offline) flavor
│   ├── destinations.json
│   ├── logo.svg
│   └── user.jpg
│
├── lib/
│   ├── main.dart                  # MainApp widget + default main() that delegates to development
│   ├── main_development.dart      # entry point: local/asset data
│   ├── main_staging.dart          # entry point: HTTP server data
│   │
│   ├── config/
│   │   ├── assets.dart            # abstract final class Assets { static const ... }
│   │   └── dependencies.dart      # ALL dependency injection lives here
│   │
│   ├── routing/
│   │   ├── routes.dart            # abstract final class Routes { static const ... }
│   │   └── router.dart            # GoRouter config + redirect + ViewModel construction
│   │
│   ├── utils/
│   │   ├── result.dart            # sealed class Result<T> { Ok<T> | Error<T> }
│   │   ├── command.dart           # Command0<T> / Command1<T,A> (ChangeNotifier)
│   │   └── image_error_listener.dart
│   │
│   ├── domain/
│   │   ├── models/                # UI-facing immutable models (freezed)
│   │   │   ├── activity/activity.dart (+ .freezed.dart, .g.dart)
│   │   │   ├── booking/booking.dart
│   │   │   ├── booking/booking_summary.dart
│   │   │   ├── continent/continent.dart
│   │   │   ├── destination/destination.dart
│   │   │   ├── itinerary_config/itinerary_config.dart
│   │   │   └── user/user.dart
│   │   └── use_cases/             # OPTIONAL domain layer
│   │       └── booking/
│   │           ├── booking_create_use_case.dart
│   │           └── booking_share_use_case.dart
│   │
│   ├── data/
│   │   ├── repositories/          # organised BY ENTITY, each with an abstract + N impls
│   │   │   ├── activity/
│   │   │   │   ├── activity_repository.dart          # abstract
│   │   │   │   ├── activity_repository_local.dart
│   │   │   │   └── activity_repository_remote.dart
│   │   │   ├── auth/
│   │   │   │   ├── auth_repository.dart              # abstract, extends ChangeNotifier
│   │   │   │   ├── auth_repository_dev.dart
│   │   │   │   └── auth_repository_remote.dart
│   │   │   ├── booking/         (booking_repository{,_local,_remote}.dart)
│   │   │   ├── continent/       (continent_repository{,_local,_remote}.dart)
│   │   │   ├── destination/     (destination_repository{,_local,_remote}.dart)
│   │   │   ├── itinerary_config/
│   │   │   │   ├── itinerary_config_repository.dart
│   │   │   │   └── itinerary_config_repository_memory.dart
│   │   │   └── user/            (user_repository{,_local,_remote}.dart)
│   │   └── services/
│   │       ├── shared_preferences_service.dart
│   │       ├── local/
│   │       │   └── local_data_service.dart           # rootBundle asset loading
│   │       └── api/
│   │           ├── api_client.dart
│   │           ├── auth_api_client.dart
│   │           └── model/                            # WIRE models, separate from domain models
│   │               ├── booking/booking_api_model.dart (+ .freezed.dart, .g.dart)
│   │               ├── login_request/login_request.dart
│   │               ├── login_response/login_response.dart
│   │               └── user/user_api_model.dart
│   │
│   └── ui/                        # organised BY FEATURE
│       ├── core/                  # shared, feature-agnostic UI
│       │   ├── localization/applocalization.dart
│       │   ├── themes/
│       │   │   ├── colors.dart
│       │   │   ├── dimens.dart    # responsive size tokens via a sealed-ish abstract final class
│       │   │   └── theme.dart
│       │   └── ui/                # shared widgets — NOTE: called "ui", deliberately NOT "widgets"
│       │       ├── back_button.dart
│       │       ├── blur_filter.dart
│       │       ├── custom_checkbox.dart
│       │       ├── date_format_start_end.dart
│       │       ├── error_indicator.dart
│       │       ├── home_button.dart
│       │       ├── scroll_behavior.dart
│       │       ├── search_bar.dart
│       │       └── tag_chip.dart
│       │
│       ├── activities/
│       │   ├── view_models/activities_viewmodel.dart
│       │   └── widgets/
│       │       ├── activities_screen.dart
│       │       ├── activities_header.dart
│       │       ├── activities_list.dart
│       │       ├── activities_title.dart
│       │       ├── activity_entry.dart
│       │       └── activity_time_of_day.dart
│       ├── auth/
│       │   ├── login/
│       │   │   ├── view_models/login_viewmodel.dart
│       │   │   └── widgets/{login_screen.dart, tilted_cards.dart}
│       │   └── logout/
│       │       ├── view_models/logout_viewmodel.dart
│       │       └── widgets/logout_button.dart
│       ├── booking/
│       │   ├── view_models/booking_viewmodel.dart
│       │   └── widgets/{booking_screen.dart, booking_body.dart, booking_header.dart}
│       ├── home/
│       │   ├── view_models/home_viewmodel.dart
│       │   └── widgets/{home_screen.dart, home_screen_container.dart, home_title.dart}
│       ├── results/
│       │   ├── view_models/results_viewmodel.dart
│       │   └── widgets/{results_screen.dart, result_card.dart}
│       └── search_form/
│           ├── view_models/search_form_viewmodel.dart
│           └── widgets/{search_form_screen.dart, search_form_continent.dart,
│                        search_form_date.dart, search_form_guests.dart,
│                        search_form_submit.dart}
│
├── test/                          # mirrors lib/ exactly
│   ├── data/
│   │   ├── repositories/
│   │   │   ├── activity/{activity_repository_local_test.dart, activity_repository_remote_test.dart}
│   │   │   ├── auth/auth_repository_remote_test.dart
│   │   │   ├── booking/booking_repository_remote_test.dart
│   │   │   ├── continent/continent_repository_remote_test.dart
│   │   │   └── destination/{destination_repository_local_test.dart, destination_repository_remote_test.dart}
│   │   └── services/api/{api_client_test.dart, auth_api_client_test.dart}
│   ├── domain/use_cases/booking/{booking_create_use_case_test.dart, booking_share_use_case_test.dart}
│   ├── ui/
│   │   ├── activities/activities_screen_test.dart
│   │   ├── auth/{login_screen_test.dart, logout_button_test.dart}
│   │   ├── booking/booking_screen_test.dart
│   │   ├── home/widgets/home_screen_test.dart
│   │   ├── results/{results_screen_test.dart, results_viewmodel_test.dart}
│   │   └── search_form/
│   │       ├── view_models/search_form_viewmodel_test.dart
│   │       └── widgets/{search_form_continent_test.dart, search_form_date_test.dart,
│   │                    search_form_guests_test.dart, search_form_screen_test.dart,
│   │                    search_form_submit_test.dart}
│   └── utils/command_test.dart
│
├── testing/                       # NOT test/ — a "version of your app you don't ship"
│   ├── app.dart                   # testApp() harness that pumps a MaterialApp
│   ├── mocks.dart                 # mocktail Mock classes (MockGoRouter, MockHttpClient, ...)
│   ├── fakes/
│   │   ├── repositories/fake_{activities,auth,booking,continent,destination,itinerary_config,user}_repository.dart
│   │   └── services/fake_{api_client,auth_api_client,shared_preferences_service}.dart
│   ├── models/{activity,booking,destination,user}.dart   # kBooking, kDestination1, ... constants
│   └── utils/result.dart          # extension ResultCast<T> on Result<T> { asOk, asError }
│
└── integration_test/
    ├── app_local_data_test.dart
    └── app_server_data_test.dart
```

**Source:** the official docs reproduce (a simplified version of) this exact tree — https://docs.flutter.dev/app-architecture/case-study#package-structure

The doc's own explanation of *why* this split (verbatim from `sites/docs/src/content/app-architecture/case-study/index.md`):

> The `data` folder organizes code **by type**, because repositories and services can be used across different features and by multiple view models. The `ui` folder organizes the code **by feature**, because each feature has exactly one view and exactly one view model.

> There are two test-related directories at the same level as `lib`: `test/` has the test code, and its own structure matches `lib/`. **`testing/` is a subpackage that contains mocks and other testing utilities which can be used in other packages' test code. The `testing/` folder could be described as a version of your app that you don't ship.**

---

## 3. File & class naming conventions (derived from the actual filenames)

**WHAT:** Name every file `snake_case.dart` after the class it contains, with an architectural suffix. Name the *class* after the architectural role.

| Role | File pattern | Class pattern | Real example |
|---|---|---|---|
| View (screen) | `<feature>_screen.dart` | `<Feature>Screen` | `home_screen.dart` → `HomeScreen` |
| View (sub-widget) | `<feature>_<part>.dart` | `<Feature><Part>` | `search_form_guests.dart` → `SearchFormGuests` |
| ViewModel | `<feature>_viewmodel.dart` | `<Feature>ViewModel` | `booking_viewmodel.dart` → `BookingViewModel` |
| Repository (interface) | `<entity>_repository.dart` | `<Entity>Repository` (abstract) | `booking_repository.dart` |
| Repository (impl) | `<entity>_repository_<flavor>.dart` | `<Entity>Repository<Flavor>` | `booking_repository_remote.dart` → `BookingRepositoryRemote` |
| Service | `<thing>_service.dart` / `api_client.dart` | `<Thing>Service` / `ApiClient` | `local_data_service.dart` → `LocalDataService` |
| Use case | `<entity>_<verb>_use_case.dart` | `<Entity><Verb>UseCase` | `booking_create_use_case.dart` → `BookingCreateUseCase` |
| Domain model | `<model>.dart` in `domain/models/<model>/` | `<Model>` | `booking.dart` → `Booking` |
| Wire model | `<model>_api_model.dart` | `<Model>ApiModel` | `booking_api_model.dart` → `BookingApiModel` |
| Fake | `fake_<thing>.dart` | `Fake<Thing>` | `fake_booking_repository.dart` → `FakeBookingRepository` |
| Test | `<source_file_name>_test.dart` | — | `search_form_viewmodel_test.dart` |
| Test fixture constant | in `testing/models/<model>.dart` | `k<Thing>` | `kBooking`, `kDestination1` |

**Critical detail people get wrong:** the ViewModel file suffix is **`_viewmodel.dart` (one word, no underscore between "view" and "model")**, but the *directory* is **`view_models/`** (two words). Both are real and both appear in every feature. Verified: `lib/ui/booking/view_models/booking_viewmodel.dart`.

**WHY the shared-widget folder is `ui/core/ui/` and not `widgets/`** — from the official recommendations YAML (`flutter/website` → `sites/docs/src/data/architectureRecommendations.yml`):

> For clarity, we do not recommend using names that can be confused with objects from the Flutter SDK. For example, you should put your shared widgets in a directory called `ui/core/`, rather than a directory called `/widgets`.

**SOURCE:** https://github.com/flutter/website/blob/main/sites/docs/src/data/architectureRecommendations.yml

---

## 4. `analysis_options.yaml` (real, verbatim)

`compass_app/app/analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - combinators_ordering
    - directives_ordering
    - omit_local_variable_types
    - prefer_final_fields
    - prefer_final_in_for_each
    - prefer_final_locals
    - prefer_relative_imports
```

**Note an inconsistency worth knowing:** the rest of `flutter/samples` uses a shared lint package. `form_app/analysis_options.yaml` and `testing_app/analysis_options.yaml` are each exactly one line:

```yaml
include: package:analysis_defaults/flutter.yaml
```

…and `analysis_defaults/lib/flutter.yaml` (the *stronger* config, which compass_app declares as a dev_dependency but does **not** actually include) is:

```yaml
include: package:flutter_lints/flutter.yaml

formatter:
  trailing_commas: preserve
  page_width: 79

analyzer:
  language:
    strict-casts: true
    strict-inference: true

linter:
  rules:
    avoid_types_on_closure_parameters: true
    avoid_void_async: true
    cancel_subscriptions: true
    close_sinks: true
    directives_ordering: true
    test_types_in_equals: true
    throw_in_finally: true
    unawaited_futures: true
    unnecessary_breaks: true
    unnecessary_statements: true
    use_super_parameters: true
```

**MY RECOMMENDATION for your app:** use the **union** of both — i.e. `analysis_defaults/lib/flutter.yaml` plus compass_app's `prefer_relative_imports`, `prefer_final_locals`, `omit_local_variable_types`. `strict-casts: true` + `strict-inference: true` are the highest-value two lines in either file and neither `flutter_lints` nor compass_app's own options turn them on by default. `cancel_subscriptions` / `close_sinks` matter a lot for a drift app (drift `.watch()` streams). Skip `page_width: 79` unless you like it; the samples repo uses it for docs-embedding reasons (`<?code-excerpt?>` snippets must fit on the website).

**SOURCES:**
- https://github.com/flutter/samples/blob/main/compass_app/app/analysis_options.yaml
- https://github.com/flutter/samples/blob/main/analysis_defaults/lib/flutter.yaml
- `flutter_lints` latest on pub.dev: **6.0.0, published 2025-05-27** (verified via `api.pub.dev`). Actively maintained by the Flutter team (`dart-lang/lints`).

---

## 5. `pubspec.yaml` (real, verbatim)

```yaml
name: compass_app
description: >-
  A sample app that helps users build and book itineraries for trips.
publish_to: none
version: 0.1.0
resolution: workspace

environment:
  sdk: ^3.9.0-0

dependencies:
  cached_network_image: ^3.4.1
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_svg: ^2.0.16
  freezed_annotation: ^3.0.0
  go_router: ^16.0.0
  google_fonts: ^6.2.1
  intl: any
  json_annotation: ^4.9.0
  logging: ^1.3.0
  provider: ^6.1.2
  share_plus: ^10.1.3
  shared_preferences: ^2.3.5

dev_dependencies:
  analysis_defaults:
    path: ../../analysis_defaults
  flutter_test:
    sdk: flutter
  mocktail_image_network: ^1.2.0
  mocktail: ^1.0.4
  integration_test:
    sdk: flutter
  build_runner: ^2.4.14
  freezed: ^3.0.0
  json_serializable: ^6.9.0

flutter:
  uses-material-design: true
  assets:
    - assets/activities.json
    - assets/destinations.json
    - assets/logo.svg
    - assets/user.jpg
```

Two things to copy verbatim into your own pubspec:

1. **`publish_to: none`** — mandatory for an app; without it `dart pub publish` guards don't apply and `pub` will complain about missing publish metadata.
2. **`resolution: workspace`** — this is Dart **pub workspaces** (Dart 3.6+). `compass_app/app` is a member of the `flutter/samples` root workspace declared in `/pubspec.yaml`:

```yaml
name: samples
environment:
  sdk: ^3.9.0-0
workspace:
  - analysis_defaults
  - compass_app/app
  - compass_app/server
  - ...
```

**WHY this matters directly for your app:** you have *a pure-Dart domain package (rule engine) + a Flutter app + a CLI content-build tool*. That is exactly the shape `resolution: workspace` was built for — one shared `pubspec.lock`, one `.dart_tool/package_config.json`, `dart pub get` once at the root, no `dependency_overrides` hacks, and the CLI tool and the app provably use the same version of the domain package. Compass App uses it for the identical reason (app + server share the workspace). **Do this.**

Version currency check (all verified against `api.pub.dev` on 2026-07-27):

| Package | Compass pins | Latest on pub | Verdict |
|---|---|---|---|
| `go_router` | `^16.0.0` | **17.3.0** (2026-06-02) | sample is one major behind |
| `freezed` | `^3.0.0` | **3.2.5** (2026-02-03); `4.0.0-dev.3` in progress | fine, but see §11 |
| `provider` | `^6.1.2` | **6.1.5+1** (2025-08-19) | current major; maintained |
| `shared_preferences` | `^2.3.5` | **2.5.5** (2026-03-25) | fine |
| `mocktail` | `^1.0.4` | **1.0.5** (2026-04-10) | fine, maintained (Very Good Ventures) |
| `flutter_lints` | via `analysis_defaults` `^6.0.0` | **6.0.0** (2025-05-27) | current |
| `drift` (yours) | — | **2.34.2** (2026-07-14) | very actively maintained |
| `flutter_riverpod` (yours) | — | **3.4.1** (2026-07-26) | very actively maintained |

---

## 6. Real code — the four load-bearing utilities

### 6.1 `lib/utils/result.dart` — the sealed Result type (verbatim)

This is the single most copy-worthy file in the whole sample. It is **Dart 3 sealed classes**, so `switch` over it is *exhaustive* and the analyzer errors if you forget a case.

```dart
/// Utility class to wrap result data
///
/// Evaluate the result using a switch statement:
/// ```dart
/// switch (result) {
///   case Ok(): {
///     print(result.value);
///   }
///   case Error(): {
///     print(result.error);
///   }
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Creates a successful [Result], completed with the specified [value].
  const factory Result.ok(T value) = Ok._;

  /// Creates an error [Result], completed with the specified [error].
  const factory Result.error(Exception error) = Error._;
}

/// Subclass of Result for values
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  /// Returned value in result
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// Subclass of Result for errors
final class Error<T> extends Result<T> {
  const Error._(this.error);

  /// Returned error in result
  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
```

**SOURCE:** https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/result.dart

**WHY:** Every repository and service method returns `Future<Result<T>>` instead of throwing. Errors become part of the type signature, so a ViewModel physically cannot forget to handle them (the analyzer flags a non-exhaustive switch). This is why the whole codebase has almost no `try/catch` in the UI layer.

**GOTCHAS (real, and they will bite you):**
- The class is literally named **`Error`**, which shadows `dart:core`'s `Error`. Every file that imports `result.dart` loses access to `dart:core.Error`. The sample accepts this. **My recommendation: rename to `Failure`** (or `Err`) in your app. `dart:core.Error` shows up in `FlutterError.onError` handling, `AssertionError`, `StateError` — you will want it.
- `Result.error` takes `Exception`, not `Object`. `Error`s (assertion failures, `StateError`) are deliberately *not* wrappable — they represent bugs and should crash.
- `Result<T>` has **no** `map`/`fold`/`when`. The team deliberately kept it to ~40 lines. Add `asOk`/`asError` in a *test-only* extension (see §9.3) so production code is forced through exhaustive switches.

**Documented alternative if you want a package:** `sites/docs/src/content/app-architecture/design-patterns/result.md` exists; `result_dart` (Flutterando) is at 2.2.0, published 2026-03-07. My recommendation is still: **copy the 40 lines**. Zero dependency, zero version risk, and it's what the Flutter team ships.

### 6.2 `lib/utils/command.dart` — the Command pattern (verbatim)

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import 'result.dart';

typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);

/// Facilitates interaction with a ViewModel.
///
/// Encapsulates an action,
/// exposes its running and error states,
/// and ensures that it can't be launched again until it finishes.
abstract class Command<T> extends ChangeNotifier {
  Command();

  bool _running = false;

  /// True when the action is running.
  bool get running => _running;

  Result<T>? _result;

  /// true if action completed with error
  bool get error => _result is Error;

  /// true if action completed successfully
  bool get completed => _result is Ok;

  /// Get last action result
  Result? get result => _result;

  /// Clear last action result
  void clearResult() {
    _result = null;
    notifyListeners();
  }

  /// Internal execute implementation
  Future<void> _execute(CommandAction0<T> action) async {
    // Ensure the action can't launch multiple times.
    // e.g. avoid multiple taps on button
    if (_running) return;

    // Notify listeners.
    // e.g. button shows loading state
    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

/// [Command] without arguments.
class Command0<T> extends Command<T> {
  Command0(this._action);
  final CommandAction0<T> _action;
  Future<void> execute() async {
    await _execute(_action);
  }
}

/// [Command] with one argument.
class Command1<T, A> extends Command<T> {
  Command1(this._action);
  final CommandAction1<T, A> _action;
  Future<void> execute(A argument) async {
    await _execute(() => _action(argument));
  }
}
```

**SOURCE:** https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/command.dart
**Docs page:** https://docs.flutter.dev/app-architecture/design-patterns/command

**WHY:** A `Command` collapses `isLoading`/`error`/`hasCompleted` for *one* action into one object, so a ViewModel with 4 actions doesn't grow 12 boolean fields. The `if (_running) return;` guard makes double-tap protection structural rather than something each button must remember.

**Notable divergence between the two official copies:** the version in `flutter/website` (`examples/app-architecture/command/lib/command.dart`, docs updated 2026-06-10) declares `final class Command0<T>` / `final class Command1<T, A>`; the version checked into `flutter/samples` still says plain `class`. Prefer the `final class` variant.

The docs also now explicitly point at a package alternative (added by PR "Update and clarify command package suggestion", 2026-06-10):

> Check pub.dev for other ready-to-use implementations of the command pattern, such as the [`command_it`] package.

`command_it` is at **9.5.1, published 2026-02-20** (github.com/flutter-it/command_it) — maintained, but it is a *third-party* recommendation, not a Flutter-team package. **My recommendation:** copy the ~90 lines. It's less code than the import line is worth arguing about.

### 6.3 `lib/config/dependencies.dart` — dependency injection at the app root (verbatim, abridged)

```dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
// ... 25 relative imports of every repository/service/use-case ...

/// Shared providers for all configurations.
List<SingleChildWidget> _sharedProviders = [
  Provider(
    lazy: true,
    create: (context) => BookingCreateUseCase(
      destinationRepository: context.read(),
      activityRepository: context.read(),
      bookingRepository: context.read(),
    ),
  ),
  Provider(
    lazy: true,
    create: (context) => BookingShareUseCase.withSharePlus(),
  ),
];

/// Configure dependencies for remote data.
List<SingleChildWidget> get providersRemote {
  return [
    Provider(create: (context) => AuthApiClient()),
    Provider(create: (context) => ApiClient()),
    Provider(create: (context) => SharedPreferencesService()),
    ChangeNotifierProvider(
      create: (context) => AuthRepositoryRemote(
            authApiClient: context.read(),
            apiClient: context.read(),
            sharedPreferencesService: context.read(),
          ) as AuthRepository,          // <-- cast to the ABSTRACT type
    ),
    Provider(
      create: (context) =>
          DestinationRepositoryRemote(apiClient: context.read())
              as DestinationRepository,
    ),
    // ...
    ..._sharedProviders,
  ];
}

/// Configure dependencies for local data.
/// The user is always logged in.
List<SingleChildWidget> get providersLocal {
  return [
    ChangeNotifierProvider.value(value: AuthRepositoryDev() as AuthRepository),
    Provider.value(value: LocalDataService()),
    Provider(
      create: (context) =>
          DestinationRepositoryLocal(localDataService: context.read())
              as DestinationRepository,
    ),
    // ...
    ..._sharedProviders,
  ];
}
```

And the entry points:

```dart
// lib/main_development.dart
void main() {
  Logger.root.level = Level.ALL;
  runApp(MultiProvider(providers: providersLocal, child: const MainApp()));
}

// lib/main_staging.dart
void main() {
  Logger.root.level = Level.ALL;
  runApp(MultiProvider(providers: providersRemote, child: const MainApp()));
}

// lib/main.dart — the default entry point just delegates
void main() {
  development.main();   // Launch development config by default
}
```

**SOURCE:** https://github.com/flutter/samples/blob/main/compass_app/app/lib/config/dependencies.dart

**The four techniques worth stealing here, regardless of whether you use provider or riverpod:**

1. **`as SomeAbstractType` on every `create`.** This is the whole trick. It registers `DestinationRepositoryRemote` *under the key* `DestinationRepository`, so nothing downstream can accidentally depend on the concrete class. Riverpod equivalent: type the provider explicitly — `final destinationRepositoryProvider = Provider<DestinationRepository>((ref) => DestinationRepositoryLocal(...));`.
2. **Flavors are a list of providers, not `#ifdef`s.** `providersLocal` vs `providersRemote` swap the *entire data layer* by changing one `runApp` argument. **This is directly reusable for your app**: `providersProduction` (real drift DBs) vs `providersGolden` (in-memory drift via `NativeDatabase.memory()` + a fixed clock + a fixed locale) makes golden tests across 6 locales trivial and hermetic.
3. **One file, `config/dependencies.dart`, holds all wiring.** No `@injectable` annotations, no codegen, no service locator. Grep-able.
4. **`lazy: true` on the expensive things.** Use-cases are created on first `read()`, not at `runApp`. **This matters for your 1.2s cold-start budget** — do NOT open your drift databases eagerly in `main()`; register them lazily and open on first repository call (this is exactly what `TodoRepository` does in the official SQL recipe, see §12.2).

**Documented rationale** (`case-study/dependency-injection.md`, verbatim):

> In the Compass app, *dependency injection* is handled using `package:provider`. **Based on their experience building Flutter apps, teams at Google recommend using `package:provider` to implement dependency injection.**
>
> Services are exposed only so they can immediately be injected into repositories via the `BuildContext.read` method from provider… Repositories are then exposed so that they can be injected into view models as needed.
>
> Within the view model or repository, the injected component should be private. … Private methods prevent the view, which has access to the view model, from calling methods on the repository directly.

**SOURCE:** https://docs.flutter.dev/app-architecture/case-study/dependency-injection

### 6.4 `lib/routing/routes.dart` + `router.dart` — routing and per-route ViewModel construction

```dart
// routes.dart — verbatim, whole file (minus the license header)
abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const search = '/$searchRelative';
  static const searchRelative = 'search';
  static const results = '/$resultsRelative';
  static const resultsRelative = 'results';
  static const activities = '/$activitiesRelative';
  static const activitiesRelative = 'activities';
  static const booking = '/$bookingRelative';
  static const bookingRelative = 'booking';
  static String bookingWithId(int id) => '$booking/$id';
}
```

The pattern: every route is declared twice — an absolute `x` built by string-interpolating a relative `xRelative`. `GoRoute(path: Routes.searchRelative)` nests correctly under the parent route, while `context.go(Routes.search)` navigates absolutely. One source of truth, no `'/'`-concatenation bugs. Parameterised routes get a static *function*: `Routes.bookingWithId(id)`. Note `abstract final class` — cannot be extended, cannot be implemented, cannot be instantiated; it's a namespace.

```dart
// router.dart — verbatim excerpt
GoRouter router(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: true,
  redirect: _redirect,
  refreshListenable: authRepository,     // repository IS the Listenable
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) {
        final logoutViewModel = LogoutViewModel(
          authRepository: context.read(),
          itineraryConfigRepository: context.read(),
        );
        return HomeScreenContainer(logoutViewModel: logoutViewModel);
      },
      routes: [
        GoRoute(
          path: Routes.searchRelative,
          builder: (context, state) {
            final viewModel = SearchFormViewModel(
              continentRepository: context.read(),
              itineraryConfigRepository: context.read(),
            );
            return SearchFormScreen(viewModel: viewModel);
          },
        ),
        // ...
        GoRoute(
          path: Routes.bookingRelative,
          builder: (context, state) {
            final viewModel = BookingViewModel(
              itineraryConfigRepository: context.read(),
              createBookingUseCase: context.read(),
              shareBookingUseCase: context.read(),
              bookingRepository: context.read(),
            );
            // When opening the booking screen directly
            // create a new booking from the stored ItineraryConfig.
            viewModel.createBooking.execute();
            return BookingScreen(viewModel: viewModel);
          },
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                final viewModel = BookingViewModel(/* ... */);
                viewModel.loadBooking.execute(id);
                return BookingScreen(viewModel: viewModel);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
```

**SOURCE:** https://github.com/flutter/samples/blob/main/compass_app/app/lib/routing/router.dart

**WHY route builders construct ViewModels:** it ties a ViewModel's lifetime to a route, not to the widget tree root, and gives each screen a fresh ViewModel on each navigation. `refreshListenable: authRepository` means the router re-evaluates `_redirect` whenever the auth repository calls `notifyListeners()` — so logout kicks you to `/login` with no imperative navigation anywhere.

**And note the bug they had to fix:** PR **#2819 (2026-06-19), "[compass_app] Scope LogoutViewModel to route builder — fix #2604"** — the ViewModel used to be created higher up and leaked across routes. The `HomeScreenContainer` (§7.3) exists purely to give `HomeViewModel` a `dispose()`. **Lesson: a ViewModel created in a `builder:` is never disposed by go_router.** If your ViewModel owns a stream subscription (drift `.watch()`), you MUST wrap it in a `StatefulWidget` container that disposes it — see §7.3.

---

## 7. Real code — the MVVM triangle

### 7.1 A real ViewModel: `HomeViewModel` (verbatim, whole file)

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../data/repositories/booking/booking_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/booking/booking_summary.dart';
import '../../../domain/models/user/user.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required BookingRepository bookingRepository,
    required UserRepository userRepository,
  }) : _bookingRepository = bookingRepository,
       _userRepository = userRepository {
    load = Command0(_load)..execute();       // <-- kicks off on construction
    deleteBooking = Command1(_deleteBooking);
  }

  final BookingRepository _bookingRepository;
  final UserRepository _userRepository;
  final _log = Logger('HomeViewModel');
  List<BookingSummary> _bookings = [];
  User? _user;

  late Command0 load;
  late Command1<void, int> deleteBooking;

  List<BookingSummary> get bookings => _bookings;

  User? get user => _user;

  Future<Result> _load() async {
    try {
      final result = await _bookingRepository.getBookingsList();
      switch (result) {
        case Ok<List<BookingSummary>>():
          _bookings = result.value;
          _log.fine('Loaded bookings');
        case Error<List<BookingSummary>>():
          _log.warning('Failed to load bookings', result.error);
          return result;
      }

      final userResult = await _userRepository.getUser();
      switch (userResult) {
        case Ok<User>():
          _user = userResult.value;
          _log.fine('Loaded user');
        case Error<User>():
          _log.warning('Failed to load user', userResult.error);
      }

      return userResult;
    } finally {
      notifyListeners();
    }
  }

  Future<Result<void>> _deleteBooking(int id) async {
    final resultDelete = await _bookingRepository.delete(id);
    switch (resultDelete) {
      case Ok<void>():
        _log.fine('Deleted booking $id');
      case Error<void>():
        _log.warning('Failed to delete booking $id', resultDelete.error);
        return resultDelete;
    }

    // After deleting the booking, reload the bookings list.
    final resultLoadBookings = await _bookingRepository.getBookingsList();
    switch (resultLoadBookings) {
      case Ok<List<BookingSummary>>():
        _bookings = resultLoadBookings.value;
        _log.fine('Loaded bookings');
        notifyListeners(); // notify only when data changes
      case Error<List<BookingSummary>>():
        _log.warning('Failed to load bookings', resultLoadBookings.error);
        return resultLoadBookings;
    }

    return resultLoadBookings;
  }
}
```

**SOURCE:** https://github.com/flutter/samples/blob/main/compass_app/app/lib/ui/home/view_models/home_viewmodel.dart

The exact ViewModel idioms, distilled:

1. **Dependencies are named required constructor params, immediately assigned to `final` private fields** in the initializer list. Never `late`, never nullable, never a service locator lookup.
2. **Commands are public `late` fields, actions are private methods.** `load = Command0(_load)` — the View can call `viewModel.load.execute()` but can never call `_load` directly, and cannot reach `_bookingRepository` at all.
3. **`..execute()` in the constructor** for a load that should fire immediately. Documented in the docs as intentional ("`HomeViewModel._load` is called in the constructor of `HomeViewModel`").
4. **Exhaustive `switch` over `Result`**, with `case Ok<List<BookingSummary>>():` — note the **explicit type argument on the pattern**. This is what makes `result.value` promote to the right type.
5. **`try { ... } finally { notifyListeners(); }`** so listeners fire on both success and failure paths.
6. **A `Logger` per ViewModel**, named after the class: `final _log = Logger('HomeViewModel');` using `package:logging` (no `print`, no `debugPrint`).
7. Commit **#2839 (2026-06-19), "refactor: remove redundant notifyListeners in HomeViewModel deleteBooking"** left the comment `// notify only when data changes` — they actively prune redundant notifications.

### 7.2 A real View: `HomeScreen` (verbatim excerpts)

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.viewModel,
    required this.logoutViewModel,
  });

  final HomeViewModel viewModel;
  final LogoutViewModel logoutViewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.deleteBooking.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.deleteBooking.removeListener(_onResult);
    widget.viewModel.deleteBooking.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.deleteBooking.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        key: const ValueKey(bookingButtonKey),
        onPressed: () => context.go(Routes.search),
        label: Text(AppLocalization.of(context).bookNewTrip),
        icon: const Icon(Icons.add_location_outlined),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: ListenableBuilder(
          listenable: widget.viewModel.load,          // <-- listen to the COMMAND
          builder: (context, child) {
            if (widget.viewModel.load.running) {
              return const Center(child: CircularProgressIndicator());
            }
            if (widget.viewModel.load.error) {
              return ErrorIndicator(
                title: AppLocalization.of(context).errorWhileLoadingHome,
                label: AppLocalization.of(context).tryAgain,
                onPressed: widget.viewModel.load.execute,
              );
            }
            return child!;                            // <-- child is NOT rebuilt
          },
          child: ListenableBuilder(
            listenable: widget.viewModel,             // <-- listen to the VIEWMODEL
            builder: (context, _) {
              return CustomScrollView(
                slivers: [ /* ... */
                  SliverList.builder(
                    itemCount: widget.viewModel.bookings.length,
                    itemBuilder: (_, index) => _Booking(
                      key: ValueKey(widget.viewModel.bookings[index].id),
                      booking: widget.viewModel.bookings[index],
                      onTap: () => context.push(
                        Routes.bookingWithId(widget.viewModel.bookings[index].id),
                      ),
                      confirmDismiss: (_) async {
                        await widget.viewModel.deleteBooking.execute(
                          widget.viewModel.bookings[index].id,
                        );
                        if (widget.viewModel.deleteBooking.completed) {
                          return true;   // removes the dismissible from the list
                        } else {
                          return false;  // the dismissible stays in the list
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onResult() {
    if (widget.viewModel.deleteBooking.completed) {
      widget.viewModel.deleteBooking.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalization.of(context).bookingDeleted)),
      );
    }
    if (widget.viewModel.deleteBooking.error) {
      widget.viewModel.deleteBooking.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalization.of(context).errorWhileDeletingBooking),
        ),
      );
    }
  }
}

class _Booking extends StatelessWidget {           // <-- private widget class, not a
  const _Booking({ /* ... */ });                   //     _buildBooking() helper method
  // ...
}
```

**SOURCE:** https://github.com/flutter/samples/blob/main/compass_app/app/lib/ui/home/widgets/home_screen.dart

The View idioms:

- **The View takes exactly one ViewModel as a constructor arg** (here two, because logout is a separate feature's ViewModel). It never touches `context.read<Repository>()`.
- **Nested `ListenableBuilder`s with the `child:` escape hatch.** The outer one listens to the *Command* (loading/error chrome); the inner listens to the *ViewModel* (data). Passing the inner tree as `child:` means the outer rebuild does **not** rebuild the list. This is the single biggest perf idiom in the file.
- **One-shot side effects (snackbars, dialogs, navigation-on-success) go through `addListener` in `initState`, NOT inside `build`.** Then `clearResult()` so it fires once. This is the correct answer to "how do I show a snackbar when an async action finishes" in `ChangeNotifier` MVVM.
- **`didUpdateWidget` re-wires the listener** when the ViewModel instance changes. Easy to forget; they didn't.
- **Sub-widgets are private `StatelessWidget` classes (`class _Booking extends StatelessWidget`), not `Widget _buildBooking()` methods.** This is also rule #4 in the Flutter team's own LLM style guide (see §10): *"Use small, private Widget classes instead of private helper methods that return a Widget."*
- **Widget keys for tests are top-level `const String` in the same file**: `const String bookingButtonKey = 'booking-button';`, used as `key: const ValueKey(bookingButtonKey)` and found in tests via `find.byKey(const ValueKey(bookingButtonKey))`.
- `heroTag: null` on the FAB with a linked issue comment — a real workaround, real link: https://github.com/flutter/flutter/issues/115358

### 7.3 The `*_screen_container.dart` pattern — how they dispose ViewModels

This file exists *only* because go_router route builders never dispose what they create. Verbatim, whole file:

```dart
class HomeScreenContainer extends StatefulWidget {
  const HomeScreenContainer({super.key, required this.logoutViewModel});

  final LogoutViewModel logoutViewModel;

  @override
  State<HomeScreenContainer> createState() => _HomeScreenContainerState();
}

class _HomeScreenContainerState extends State<HomeScreenContainer> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(
      bookingRepository: context.read<BookingRepository>(),
      userRepository: context.read<UserRepository>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      viewModel: _viewModel,
      logoutViewModel: widget.logoutViewModel,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
```

**SOURCE:** https://github.com/flutter/samples/blob/main/compass_app/app/lib/ui/home/widgets/home_screen_container.dart

**WHY this is important for your app:** you will have drift `.watch()` stream subscriptions in ViewModels. A leaked subscription on a `Stream` from a `Database` keeps the ViewModel alive forever. **Every ViewModel that owns a subscription needs this container.** Note: `HomeScreenContainer` is the *only* screen that has one — the other five ViewModels in the sample are NOT disposed. That is a real, acknowledged gap in the sample (it's why issue #2604 existed), not an endorsement.

**With riverpod you get this for free** — `ref.onDispose` / autoDispose providers make the container widget unnecessary. That is a genuine advantage of your stack over the sample's.

---

## 8. Data layer — repositories, services, and model separation

### 8.1 Abstract repository + N implementations

```dart
// data/repositories/booking/booking_repository.dart — verbatim, whole file
import '../../../domain/models/booking/booking.dart';
import '../../../domain/models/booking/booking_summary.dart';
import '../../../utils/result.dart';

abstract class BookingRepository {
  /// Returns the list of [BookingSummary] for the current user.
  Future<Result<List<BookingSummary>>> getBookingsList();

  /// Returns a full [Booking] given the id.
  Future<Result<Booking>> getBooking(int id);

  /// Creates a new [Booking].
  Future<Result<void>> createBooking(Booking booking);

  /// Delete booking
  Future<Result<void>> delete(int id);
}
```

Implementations: `BookingRepositoryLocal implements BookingRepository` (asset JSON + in-memory list) and `BookingRepositoryRemote implements BookingRepository` (HTTP). Note: **`implements`, not `extends`** — no shared base class, no template-method inheritance.

The only exception is `AuthRepository`, which is `abstract class AuthRepository extends ChangeNotifier` because go_router uses it as a `refreshListenable`:

```dart
abstract class AuthRepository extends ChangeNotifier {
  /// Returns true when the user is logged in
  /// Returns [Future] because it will load a stored auth state the first time.
  Future<bool> get isAuthenticated;
  Future<Result<void>> login({required String email, required String password});
  Future<Result<void>> logout();
}
```

**Official rationale** (architectureRecommendations.yml, confidence: **strong**):

> Creating abstract repository classes allows you to create different implementations, which can be used for different app environments, such as "development" and "staging".

**Direct mapping to your app:** `ReferenceRepository` (abstract) → `ReferenceRepositoryDrift` (the read-only asset DB) and `ReferenceRepositoryFixture` (an in-memory table for goldens/tests). Same for the writable user DB.

### 8.2 Domain model vs API/wire model — they are physically different classes

```dart
// domain/models/booking/booking.dart — the UI-facing model
@freezed
class Booking with _$Booking {
  const factory Booking({
    int? id,
    required DateTime startDate,
    required DateTime endDate,
    required Destination destination,      // <-- a full nested object
    required List<Activity> activity,      // <-- full nested objects
  }) = _Booking;

  factory Booking.fromJson(Map<String, Object?> json) => _$BookingFromJson(json);
}
```

```dart
// data/services/api/model/booking/booking_api_model.dart — the wire model
@freezed
class BookingApiModel with _$BookingApiModel {
  const factory BookingApiModel({
    int? id,
    required DateTime startDate,
    required DateTime endDate,
    /// Booking name
    /// Should be "Destination, Continent"
    required String name,
    required String destinationRef,        // <-- just a String ref
    required List<String> activitiesRef,   // <-- just String refs
  }) = _BookingApiModel;

  factory BookingApiModel.fromJson(Map<String, Object?> json) =>
      _$BookingApiModelFromJson(json);
}
```

And the **repository does the translation** — this is the entire point:

```dart
// data/repositories/booking/booking_repository_remote.dart — verbatim excerpt
@override
Future<Result<void>> createBooking(Booking booking) async {
  try {
    final bookingApiModel = BookingApiModel(
      startDate: booking.startDate,
      endDate: booking.endDate,
      name: '${booking.destination.name}, ${booking.destination.continent}',
      destinationRef: booking.destination.ref,
      activitiesRef: booking.activity.map((activity) => activity.ref).toList(),
    );
    return _apiClient.postBooking(bookingApiModel);
  } on Exception catch (e) {
    return Result.error(e);
  }
}

@override
Future<Result<Booking>> getBooking(int id) async {
  try {
    final resultBooking = await _apiClient.getBooking(id);
    switch (resultBooking) {
      case Error<BookingApiModel>():
        return Result.error(resultBooking.error);
      case Ok<BookingApiModel>():         // <-- empty case body: just a type guard
    }
    final booking = resultBooking.value;  // promoted to Ok<BookingApiModel>

    // Load destinations if not loaded yet
    if (_cachedDestinations == null) { /* ... */ }

    final destination = _cachedDestinations!.firstWhere(
      (destination) => destination.ref == booking.destinationRef,
    );
    // ... hydrate activities ...
    return Result.ok(Booking(
      id: booking.id,
      startDate: booking.startDate,
      endDate: booking.endDate,
      destination: destination,       // <-- refs resolved into objects
      activity: activities,
    ));
  } on Exception catch (e) {
    return Result.error(e);
  }
}
```

**SOURCE:** https://github.com/flutter/samples/blob/main/compass_app/app/lib/data/repositories/booking/booking_repository_remote.dart

Note the **`case Ok<T>():` with an empty body used as an early-return type guard** — an idiom that appears repeatedly. It's `if (result is Error) return ...` but exhaustive.

**Official position on this** (architectureRecommendations.yml, confidence: **conditional — "Use in large apps"**):

> **Create separate API models and domain models.** Using separate models adds verbosity, but prevents complexity in ViewModels and use-cases.

**MY OPINIONATED CALL FOR YOUR APP:** **Yes, do it, but only at the drift boundary.** drift generates a data class per table (e.g. `RuleRow`) which is a *persistence* model with DB-shaped columns (ints for enums, ISO strings for dates, denormalised joins). Your ViewModels and your pure-Dart rule-engine package must NOT see `RuleRow`. Map `RuleRow → Rule` (your domain type, defined in the pure-Dart package) inside the repository. This is non-negotiable for you specifically because **your domain package must have zero Flutter and zero drift imports** in order to be usable from the CLI content-build tool. Drift's generated classes drag in `package:drift`; if your domain types are drift rows, your "pure Dart" package isn't pure.

The docs say the same thing in the offline-first recipe:

> In apps that have complex data … you might want to have one data class for the API and database services, and another for the UI. For example, `UserProfileLocal` for the database entity, `UserProfileRemote` for the API response object, and then `UserProfile` for the UI data model class. **The `UserProfileRepository` would take care of converting from one to the other when necessary.**

**SOURCE:** https://docs.flutter.dev/app-architecture/design-patterns/offline-first

### 8.3 Services

Services are thin, own no state beyond what the platform gives them, and are the *only* things that touch `dart:io`, `rootBundle`, plugins, etc.

```dart
// data/services/local/local_data_service.dart — verbatim excerpt
class LocalDataService {
  Future<List<Activity>> getActivities() async {
    final json = await _loadStringAsset(Assets.activities);
    return json.map<Activity>(Activity.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> _loadStringAsset(String asset) async {
    final localData = await rootBundle.loadString(asset);
    return (jsonDecode(localData) as List).cast<Map<String, dynamic>>();
  }
}
```

```dart
// data/services/shared_preferences_service.dart — verbatim, whole class
class SharedPreferencesService {
  static const _tokenKey = 'TOKEN';
  final _log = Logger('SharedPreferencesService');

  Future<Result<String?>> fetchToken() async {
    try {
      final sharedPreferences = SharedPreferencesAsync();
      _log.finer('Got token from SharedPreferences');
      return Result.ok(await sharedPreferences.getString(_tokenKey));
    } on Exception catch (e) {
      _log.warning('Failed to get token', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> saveToken(String? token) async {
    try {
      final sharedPreferences = SharedPreferencesAsync();
      if (token == null) {
        _log.finer('Removed token');
        await sharedPreferences.remove(_tokenKey);
      } else {
        _log.finer('Replaced token');
        await sharedPreferences.setString(_tokenKey, token);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to set token', e);
      return Result.error(e);
    }
  }
}
```

**Note:** this was migrated in PR **#2841 (2026-06-19), "Migrate compass_app to SharedPreferencesAsync"** — from the legacy `SharedPreferences.getInstance()` singleton to the newer `SharedPreferencesAsync` API. **If you find any tutorial using `SharedPreferences.getInstance()`, it is stale.** Use `SharedPreferencesAsync` (or `SharedPreferencesWithCache` if you need synchronous reads after a warm-up). Key names live as `static const` on the service. `shared_preferences` latest: **2.5.5, 2026-03-25**, maintained in `flutter/packages`.

### 8.4 The in-memory repository — a directly reusable pattern for you

```dart
// data/repositories/itinerary_config/itinerary_config_repository_memory.dart — verbatim
/// In-memory implementation of [ItineraryConfigRepository].
class ItineraryConfigRepositoryMemory implements ItineraryConfigRepository {
  ItineraryConfig? _itineraryConfig;

  @override
  Future<Result<ItineraryConfig>> getItineraryConfig() async {
    return Result.ok(_itineraryConfig ?? const ItineraryConfig());
  }

  @override
  Future<Result<bool>> setItineraryConfig(ItineraryConfig itineraryConfig) async {
    _itineraryConfig = itineraryConfig;
    return const Result.ok(true);
  }
}
```

Registered with `Provider.value(value: ItineraryConfigRepositoryMemory() as ItineraryConfigRepository)`. **Even ephemeral, in-RAM state gets a repository interface** so ViewModels never share mutable state directly. This is how they pass the multi-step wizard state (continent → dates → guests → destination → activities) between five screens without a global.

### 8.5 Simple caching in a repository

```dart
// data/repositories/destination/destination_repository_remote.dart — verbatim
/// Remote data source for [Destination].
/// Implements basic local caching.
/// See: https://docs.flutter.dev/get-started/fwe/local-caching
class DestinationRepositoryRemote implements DestinationRepository {
  DestinationRepositoryRemote({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  List<Destination>? _cachedData;

  @override
  Future<Result<List<Destination>>> getDestinations() async {
    if (_cachedData == null) {
      final result = await _apiClient.getDestinations();
      if (result is Ok<List<Destination>>) {
        _cachedData = result.value;
      }
      return result;
    } else {
      return Result.ok(_cachedData!);
    }
  }
}
```

**Directly applicable to your read-only reference DB.** Your pre-seeded asset DB never changes at runtime, so a nullable `_cached` field in the repository, populated on first read, is exactly right — and it's the single easiest thing you can do to keep cold start under 1.2s: read once, cache forever, never re-query.

---

## 9. Testing — structure, harness, and real test files

### 9.1 The structure rule

- **`test/` mirrors `lib/` exactly.** `lib/ui/home/widgets/home_screen.dart` → `test/ui/home/widgets/home_screen_test.dart`.
- **`testing/` is a sibling of `lib/` and `test/`**, not inside either. It holds fakes, mocks, fixture constants, and the widget-test harness. Because it's a normal source directory in the package, both `test/` and `integration_test/` can import from it with relative paths (`import '../../../../testing/app.dart';`).
- Test file name = source file name + `_test.dart`. Top-level `group('<ClassName> tests', ...)`.

**Caveat — the sample is not perfectly consistent:** `test/ui/results/results_viewmodel_test.dart` sits directly under `results/`, while `test/ui/search_form/view_models/search_form_viewmodel_test.dart` uses the mirrored `view_models/` subfolder. Pick the mirrored form and be consistent.

**No golden tests exist in the sample.** There is no `test/goldens/` directory, no `matchesGoldenFile` anywhere in `compass_app`. **The Compass App gives you zero guidance on goldens.** You are on your own for that (out of scope for this lane, but flag it: do not expect the reference app to answer it).

### 9.2 The shared widget-test harness `testing/app.dart` (verbatim, whole file)

```dart
Future<void> testApp(
  WidgetTester tester,
  Widget body, {
  GoRouter? goRouter,
}) async {
  tester.view.devicePixelRatio = 1.0;
  await tester.binding.setSurfaceSize(const Size(1200, 800));
  await mockNetworkImages(() async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          AppLocalizationDelegate(),
        ],
        theme: AppTheme.lightTheme,
        home: InheritedGoRouter(
          goRouter: goRouter ?? MockGoRouter(),
          child: Scaffold(body: body),
        ),
      ),
    );
  });
}
```

**SOURCE:** https://github.com/flutter/samples/blob/main/compass_app/app/testing/app.dart

**Four things here are gold, and three of them apply directly to your golden-test-across-6-locales requirement:**

1. **`tester.view.devicePixelRatio = 1.0`** — pins DPR so widget geometry is deterministic.
2. **`tester.binding.setSurfaceSize(const Size(1200, 800))`** — pins the logical surface. **For goldens you MUST do both of these**, otherwise the golden depends on the host machine.
3. **`localizationsDelegates` are wired in the harness**, so every widget test runs with real localizations. **Your version of this should take a `Locale? locale` parameter** and pass `locale:` + `supportedLocales:` to `MaterialApp` — that one change turns `testApp` into your 6-locale golden harness, and passing `const Locale('ar')` gives you RTL for free via `Directionality` derived from the locale.
4. **`InheritedGoRouter(goRouter: goRouter ?? MockGoRouter(), ...)`** — injecting a mocked router into the tree so `context.go(...)` inside a widget can be `verify()`'d without a real router. `mockNetworkImages` comes from `mocktail_image_network` (^1.2.0) — irrelevant to you since you have no network, but the *technique* (wrap the pump in a zone that stubs a platform dependency) transfers to stubbing your camera/GPS plugins.

### 9.3 The test-only `Result` cast extension (verbatim, whole file)

```dart
// testing/utils/result.dart
import 'package:compass_app/utils/result.dart';

extension ResultCast<T> on Result<T> {
  /// Convenience method to cast to Ok
  Ok<T> get asOk => this as Ok<T>;

  /// Convenience method to cast to Error
  Error get asError => this as Error<T>;
}
```

**WHY it lives in `testing/` and not `lib/`:** production code must go through exhaustive `switch`; tests are allowed to assert-and-crash. Keeping the unsafe cast out of `lib/` is deliberate. Copy this exact split.

### 9.4 A real ViewModel unit test (verbatim excerpt)

```dart
// test/ui/search_form/view_models/search_form_viewmodel_test.dart
import 'package:compass_app/ui/search_form/view_models/search_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/fakes/repositories/fake_continent_repository.dart';
import '../../../../testing/fakes/repositories/fake_itinerary_config_repository.dart';

void main() {
  group('SearchFormViewModel Tests', () {
    late SearchFormViewModel viewModel;

    setUp(() {
      viewModel = SearchFormViewModel(
        continentRepository: FakeContinentRepository(),
        itineraryConfigRepository: FakeItineraryConfigRepository(),
      );
    });

    test('Initial values are correct', () {
      expect(viewModel.valid, false);
      expect(viewModel.selectedContinent, null);
      expect(viewModel.dateRange, null);
      expect(viewModel.guests, 0);
    });

    test('Setting guests updates correctly', () {
      viewModel.guests = 2;
      expect(viewModel.guests, 2);
      // Guests number should not be negative
      viewModel.guests = -1;
      expect(viewModel.guests, 0);
    });

    test('Set all values and save', () async {
      expect(viewModel.valid, false);
      viewModel.guests = 2;
      viewModel.selectedContinent = 'CONTINENT';
      viewModel.dateRange = DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 31),
      );
      expect(viewModel.valid, true);
      await viewModel.updateItineraryConfig.execute();
      expect(viewModel.updateItineraryConfig.completed, true);
    });
  });
}
```

**No mocking framework at all.** `FakeContinentRepository` is a hand-written class implementing the abstract repository. **Official position (confidence: strong):**

> **Make fakes for testing (and write code that takes advantage of fakes.)** Fakes aren't concerned with the inner workings of any given method as much as they're concerned with inputs and outputs. If you have this in mind while writing application code, you're forced to write modular, lightweight functions and classes with well defined inputs and outputs.

A real fake (verbatim excerpt):

```dart
// testing/fakes/repositories/fake_booking_repository.dart
class FakeBookingRepository implements BookingRepository {
  List<Booking> bookings = List.empty(growable: true);   // <-- public, inspectable
  int sequentialId = 0;

  @override
  Future<Result<void>> createBooking(Booking booking) async {
    final bookingWithId = booking.copyWith(id: sequentialId++);
    bookings.add(bookingWithId);
    return Result.ok(null);
  }

  @override
  Future<Result<void>> delete(int id) async {
    bookings.removeWhere((booking) => booking.id == id);
    return Result.ok(null);
  }
  // ...
}
```

The fake's state is a **public mutable field** so tests can assert on it directly: `expect(bookingRepository.bookings, isEmpty);`.

`mocktail` is used *only* for things you can't reasonably hand-write — `MockGoRouter`, `MockHttpClient`. `testing/mocks.dart` (verbatim excerpt):

```dart
class MockGoRouter extends Mock implements GoRouter {}
class MockHttpClient extends Mock implements HttpClient {}
class MockHttpHeaders extends Mock implements HttpHeaders {}
class MockHttpClientRequest extends Mock implements HttpClientRequest {}
class MockHttpClientResponse extends Mock implements HttpClientResponse {}

extension HttpMethodMocks on MockHttpClient {
  void mockGet(String path, Object object) { /* ... */ }
  void mockPost(String path, Object object, [int statusCode = 201]) { /* ... */ }
  void mockDelete(String path) { /* ... */ }
}
```

Note `mocktail`, **not** `mockito` — no codegen, no `.mocks.dart`, no `build_runner` in the test loop. `mocktail` 1.0.5 (2026-04-10), maintained by Very Good Ventures.

### 9.5 A real widget test (verbatim excerpt)

```dart
// test/ui/home/widgets/home_screen_test.dart
void main() {
  group('HomeScreen tests', () {
    late HomeViewModel viewModel;
    late LogoutViewModel logoutViewModel;
    late MockGoRouter goRouter;
    late FakeBookingRepository bookingRepository;

    setUp(() {
      bookingRepository = FakeBookingRepository()..createBooking(kBooking);
      viewModel = HomeViewModel(
        bookingRepository: bookingRepository,
        userRepository: FakeUserRepository(),
      );
      logoutViewModel = LogoutViewModel(
        authRepository: FakeAuthRepository(),
        itineraryConfigRepository: FakeItineraryConfigRepository(),
      );
      goRouter = MockGoRouter();
      when(() => goRouter.push(any())).thenAnswer((_) => Future.value(null));
    });

    Future<void> loadWidget(WidgetTester tester) async {
      await testApp(
        tester,
        HomeScreen(viewModel: viewModel, logoutViewModel: logoutViewModel),
        goRouter: goRouter,
      );
    }

    testWidgets('should navigate to search', (tester) async {
      await loadWidget(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('booking-button')));
      await tester.pumpAndSettle();
      verify(() => goRouter.go(Routes.search)).called(1);
    });

    testWidgets('should delete booking', (tester) async {
      await loadWidget(tester);
      await tester.pumpAndSettle();
      await tester.drag(find.text('name1, Europe'), const Offset(-1000, 0));
      await tester.pumpAndSettle();
      expect(find.text('name1, Europe'), findsNothing);
      expect(bookingRepository.bookings, isEmpty);   // assert on the FAKE's state
    });

    testWidgets('fail to delete booking', (tester) async {
      // Create a ViewModel with a repository that will fail to delete
      viewModel = HomeViewModel(
        bookingRepository: _BadFakeBookingRepository()..createBooking(kBooking),
        userRepository: FakeUserRepository(),
      );
      await loadWidget(tester);
      await tester.pumpAndSettle();
      await tester.drag(find.text('name1, Europe'), const Offset(-1000, 0));
      await tester.pumpAndSettle();
      expect(find.text('name1, Europe'), findsOneWidget);   // still there
    });
  });
}

/// A locally-defined failing variant, right in the test file.
class _BadFakeBookingRepository extends FakeBookingRepository {
  @override
  Future<Result<void>> delete(int id) async {
    return Result.error(Exception('Failed to delete booking'));
  }
}
```

**SOURCE:** https://github.com/flutter/samples/blob/main/compass_app/app/test/ui/home/widgets/home_screen_test.dart

**The `_BadFakeXRepository extends FakeXRepository` idiom, declared privately at the bottom of the test file, is the cleanest error-path testing pattern in the whole sample.** Steal it. For you: `_BadFakeReferenceRepository` that returns `Result.error(DatabaseException(...))` lets you test "reference DB corrupt / missing asset" without mocking drift.

Also note `Future<void> loadWidget(WidgetTester tester)` — the docs version of this snippet writes `void loadWidget(...) async` which trips the `avoid_void_async` lint in `analysis_defaults`. **The repo code is correct; the docs snippet is stale.** Trust the repo.

### 9.6 A real data-layer test

```dart
// test/data/repositories/activity/activity_repository_local_test.dart — verbatim
void main() {
  group('ActivityRepositoryLocal tests', () {
    // To load assets
    TestWidgetsFlutterBinding.ensureInitialized();

    final repository = ActivityRepositoryLocal(
      localDataService: LocalDataService(),
    );

    test('should get by destination ref', () async {
      final result = await repository.getByDestination('alaska');
      expect(result, isA<Ok>());

      final list = result.asOk.value;
      expect(list.length, 20);

      final activity = list.first;
      expect(activity.name, 'Glacier Trekking and Ice Climbing');
    });
  });
}
```

`TestWidgetsFlutterBinding.ensureInitialized()` is required to use `rootBundle` in a plain `test()`. **You will need exactly this** to load your pre-seeded reference `.db` asset in a unit test.

### 9.7 Integration tests

```dart
// integration_test/app_local_data_test.dart — verbatim excerpt
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test with local data', () {
    testWidgets('Create booking', (tester) async {
      await tester.pumpWidget(
        MultiProvider(providers: providersLocal, child: const MainApp()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey(bookingButtonKey)));
      await tester.pumpAndSettle();
      expect(find.byType(SearchFormScreen), findsOneWidget);
      // ... full 5-screen wizard walkthrough ...
      expect(find.text('Amalfi Coast, Europe'), findsOneWidget);
    });
  });
}
```

The integration test **reuses `providersLocal` from `lib/config/dependencies.dart` verbatim** — the entire real app, only the data flavor swapped. This is the payoff of §6.3 technique #2.

A real, still-open constraint documented in `compass_app/README.md`:

> Running the tests together with `flutter test integration_test` will fail. See: https://github.com/flutter/flutter/issues/101031

So each integration test file must be run individually: `flutter test integration_test/app_local_data_test.dart`. Plan your CI accordingly.

---

## 10. The Flutter team's own LLM style guide (bonus find — `flutter/samples/.prompts/llm.md`)

This is an **undocumented but authoritative** file: `flutter/samples/.prompts/llm.md`, opening line *"You are an expert Dart and Flutter developer on the Flutter team at Google. Your code must adhere to this style guide."* There is a companion `.prompts/code_freshness.md` that instructs an AI to audit every sample against it. It is the most concentrated statement of Flutter-team code style I found. Directly relevant extracts (verbatim):

**Flutter-specific patterns:**
> - Prefer composition over inheritance.
> - Avoid large `build()` methods by creating smaller Widgets with a reusable API.
> - **Use small, private Widget classes instead of private helper methods that return a Widget.**
> - Use lazy lists wherever possible using `ListView.builder`.

**State management:**
> - **Don't use a third party package for state management unless explicitly asked to do so.**
> - **Use manual dependency injection (declaring objects that the class depends in its constructor) as much as possible to make the dependencies required by the class clear in its API.**
> - If asked to use Provider, use it for app-level objects that are used often.
> - **Use Model-View-ViewModel for application architecture.**
> - Use `ChangeNotifier` or a class with `ValueNotifier`s for ViewModel classes.
> - Use a `ListenableBuilder` to listen to changes to the ViewModel.
> - Use a `StatefulWidget` for widgets that are reusable or single-purpose, and don't necessarily require a MVVM architecture.

**Naming (Flutter-specific):**
> - **Global constants: begin with prefix "k"**: `kDefaultTimeout`, `kMaxItems`
> - Avoid abbreviations: use `button` instead of `btn`
> - Acronyms: capitalize acronyms longer than two letters like regular words: `HttpClient` not `HTTPClient`
> - Unused parameters: use wildcards (`_`) for unused callback parameters
> - Directories: `lowercase_with_underscores`; Source files: `user_profile_widget.dart`

**Import ordering (strict):** dart core (alphabetical) → package imports (alphabetical) → relative imports (alphabetical) → exports. This is enforced by the `directives_ordering` lint, which compass_app enables.

**Testing:**
> - Use `package:integration_test` for integration tests.
> - **Use `package:checks` instead of matchers from `package:test` or `package:matcher`.**

**Data / codegen:**
> - Use `json_serializable` and `json_annotation` for parsing and encoding JSON data.
> - Use `fieldRename: FieldRename.snake` to encode data with snake case.
> - Use `build_runner` for any generated code in the app.

**Advanced:**
> - **Use Patterns and pattern-matching features where possible.**

**SOURCE:** https://github.com/flutter/samples/blob/main/.prompts/llm.md

**Three honest contradictions you should know about:**

1. `.prompts/llm.md` says *"DO use explicit types for variables (avoid var/dynamic): `final List<User> users = [];`"* — but `compass_app/analysis_options.yaml` enables **`omit_local_variable_types`**, which lints *against* that. The lint wins in the sample's own code (`final result = await ...` everywhere). **Follow the lint, not the prompt.**
2. `.prompts/llm.md` recommends **`package:checks`** over `matcher`. **Zero test files in `compass_app` use it** — they all use `expect(x, y)` from `flutter_test`. `package:checks` is a `dart-lang` package but adoption is not there. **My recommendation: stay on `flutter_test`'s `expect`.** Nothing in the reference app uses `checks`, and golden-test tooling (`matchesGoldenFile`) is `matcher`-based anyway.
3. *"Don't use a third party package for state management unless explicitly asked to do so"* is an instruction to an LLM writing samples, not a prohibition on riverpod. The architecture docs explicitly bless alternatives (see §13).

---

## 11. STALE / SUPERSEDED — what NOT to copy from the Compass App

These are the things I would actively change if I were forking it today (2026-07-27, Flutter 3.44.6).

### 11.1 The checked-in `.freezed.dart` files are freezed 2.x output — **regenerate**

`compass_app/app/pubspec.yaml` says `freezed: ^3.0.0`, but `lib/domain/models/booking/booking.freezed.dart` contains:

```dart
final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. ...'
);

Booking _$BookingFromJson(Map<String, dynamic> json) {
  return _Booking.fromJson(json);
}
```

`_privateConstructorUsedError` is **freezed 2.x scaffolding**. Compare with the freezed-3-generated file in `flutter/website` (`examples/app-architecture/offline_first/lib/domain/model/user_profile.freezed.dart`, generated with `freezed: ^3.2.5`), which has no such symbol and instead emits `mixin _$UserProfile { ... }` with an inline `copyWith` extension. **Conclusion: the sample's generated code is stale and was not regenerated after the freezed 3 bump.**

Correspondingly, the model *declarations* use the freezed 2 form:

```dart
// compass_app — OLD form
@freezed
class Booking with _$Booking { ... }
```

whereas the official docs examples use the freezed 3 form:

```dart
// flutter/website examples — CURRENT form
@freezed
abstract class Todo with _$Todo { ... }

@freezed
abstract class UserProfile with _$UserProfile { ... }
```

**WHAT TO DO:** use `@freezed abstract class X with _$X` (or `sealed class` for unions). freezed 3.0.0 (2025-02-25) introduced "mixed mode" which keeps the old syntax working, which is why compass_app still compiles — but the docs have moved and so should you. `freezed` latest stable **3.2.5 (2026-02-03)**; `4.0.0-dev.3` (2026-06-13) is in progress and drops `final` in constructor params (Dart 3.13 no longer allows it) — **don't adopt the dev channel.**

**SOURCE:** https://github.com/rrousselGit/freezed/blob/master/packages/freezed/CHANGELOG.md

**For your app specifically:** freezed's build cost is real and you have a lot of models. Consider using freezed **only** for models that need `copyWith` + deep equality + JSON; for pure value objects in the rule-engine package, hand-written `final class` with `==`/`hashCode` (or Dart 3 records for tuples) is faster to build and keeps the domain package dependency-free. The official recommendation is `confidence: recommend`, not `strong`, and it explicitly warns: *"These code generation packages can add significant build time to your applications if you have a lot of models."*

### 11.2 Localization is a hand-rolled hardcoded English map — **do NOT copy this**

`lib/ui/core/localization/applocalization.dart` is, verbatim:

```dart
class AppLocalization {
  static AppLocalization of(BuildContext context) {
    return Localizations.of(context, AppLocalization);
  }

  static const _strings = <String, String>{
    'activities': 'Activities',
    'bookNewTrip': 'Book New Trip',
    'nameTrips': '{name}\'s Trips',
    'selected': '{1} selected',
    // ... ~35 entries, English only ...
  };

  // If string for "label" does not exist, will show "[LABEL]"
  static String _get(String label) => _strings[label] ?? '[${label.toUpperCase()}]';

  String get activities => _get('activities');
  String nameTrips(String name) => _get('nameTrips').replaceAll('{name}', name);
  String selected(int value) => _get('selected').replaceAll('{1}', value.toString());
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<AppLocalization> load(Locale locale) {
    return SynchronousFuture(AppLocalization());
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalization> old) => false;
}
```

There is **no ARB file, no `l10n.yaml`, no `flutter gen-l10n`, and `isSupported` hard-returns true only for `'en'`.** `flutter_localizations` is in the pubspec purely for `GlobalMaterialLocalizations`/`GlobalWidgetsLocalizations`.

**This is a deliberate sample simplification, not guidance.** `.replaceAll('{1}', ...)` for pluralization is not pluralization — it produces "1 selected" and "2 selected" but cannot express Arabic's six plural categories (`zero/one/two/few/many/other`).

**WHAT TO DO INSTEAD (for your 6-locale + Arabic RTL app):** use **ARB + `flutter_localizations` + `flutter gen-l10n`** with ICU `plural`/`select`, which is what you already planned. The Compass App has **nothing** to teach you here. The one thing worth keeping is the *shape*: a single `AppLocalization.of(context)` accessor used at every call site, so swapping the implementation is a one-file change — and `gen-l10n`'s generated `AppLocalizations.of(context)` has exactly that shape.

Two things the Compass App does that DO help RTL, and that you should keep:
- All padding goes through `EdgeInsets.symmetric(horizontal: ...)` and `EdgeInsets.only(right: ...)`. **Watch out:** `EdgeInsets.only(right:)` in `home_screen.dart`'s `Dismissible` background is a **direction-unaware** call — it will be wrong in Arabic. Use `EdgeInsetsDirectional.only(end:)` throughout your app. The sample gets this wrong; don't copy it.
- `DismissDirection.endToStart` (not `rightToLeft`) — this one IS direction-aware and correct.

### 11.3 `go_router` is one major version behind

`^16.0.0` in the sample; **17.3.0** is current (2026-06-02, `flutter/packages`). Nothing in the sample's router usage looks 17-incompatible, but pin `^17.0.0` in a new app and check the changelog rather than assuming.

### 11.4 The `Error` name collision (see §6.1) — rename to `Failure`.

### 11.5 Only one of six ViewModels is disposed

`HomeScreenContainer` disposes `HomeViewModel`; `BookingViewModel`, `SearchFormViewModel`, `ResultsViewModel`, `ActivitiesViewModel`, `LoginViewModel` are constructed in `go_router` `builder:` callbacks and **never disposed**. Harmless in the sample (they hold no subscriptions). **Not harmless in your app** (drift streams). Either wrap every screen in a container, or use riverpod's autoDispose.

### 11.6 `.metadata` says `channel: "beta"`

`compass_app/app/.metadata` records `channel: "beta"`, revision `ee624bc4fd41413cbb89099b0701a42287643d9a`. I could not verify which Flutter version that revision corresponds to — treat as unverified. Practically: the sample targets `sdk: ^3.9.0-0` while the flutter/website architecture examples have already moved to `sdk: ^3.12.0` (PR "Update SDK constraints and code for Dart 3.12", 2026-05-18). **The website examples are the fresher of the two official sources.**

### 11.7 What *predates* Dart 3 and is absent — good news

The Compass App is fully post-Dart-3: sealed classes, exhaustive switch patterns, `switch` expressions (`Dimens.of` uses `switch (MediaQuery.sizeOf(context).width) { > 600 && < 840 => desktop, _ => mobile }`), `final class`/`abstract final class`, `super.key`. **Any tutorial you find that wraps results in `Either<L,R>` from `dartz`, or uses `freezed` unions purely to model success/error, or uses `Provider.of<T>(context, listen: false)` instead of `context.read<T>()`, predates this guidance.**

---

## 12. Adapting this to YOUR app (offline, drift ×2, riverpod, 6 locales + RTL, pure-Dart domain package)

### 12.1 Proposed directory tree

Keep the Compass structure; change only what your stack demands.

```
your_app/                          # pub workspace root: `workspace: [app, packages/rules, tools/content_builder]`
├── pubspec.yaml                   # name: your_app_workspace, workspace: [...]
├── analysis_options.yaml          # the union config from §4
│
├── packages/rules/                # PURE DART. No flutter, no drift, no freezed-on-flutter.
│   ├── pubspec.yaml               # resolution: workspace ; deps: (meta, collection) ONLY
│   ├── lib/rules.dart             # single export barrel
│   ├── lib/src/model/*.dart       # domain value types (Rule, Measurement, ...)
│   ├── lib/src/engine/*.dart
│   └── test/
│
├── tools/content_builder/         # CLI. Depends on packages/rules + drift (for building the .db)
│   ├── pubspec.yaml               # resolution: workspace
│   └── bin/build_content.dart
│
└── app/
    ├── pubspec.yaml               # resolution: workspace ; depends on packages/rules
    ├── assets/db/reference.db     # the pre-seeded read-only DB
    ├── l10n/*.arb                 # ar, en, fr, ...  (6 locales)
    ├── l10n.yaml
    ├── lib/
    │   ├── main.dart / main_development.dart
    │   ├── config/
    │   │   ├── assets.dart
    │   │   └── dependencies.dart          # riverpod overrides live here (see 12.3)
    │   ├── routing/{routes.dart, router.dart}
    │   ├── utils/{result.dart, command.dart}      # or drop command.dart if using AsyncValue
    │   ├── data/
    │   │   ├── repositories/
    │   │   │   ├── reference/{reference_repository.dart, reference_repository_drift.dart}
    │   │   │   └── measurement/{measurement_repository.dart, measurement_repository_drift.dart}
    │   │   └── services/
    │   │       ├── db/reference_database.dart     # drift @DriftDatabase (read-only)
    │   │       ├── db/user_database.dart          # drift @DriftDatabase (writable)
    │   │       ├── pdf_export_service.dart
    │   │       ├── camera_service.dart
    │   │       └── location_service.dart
    │   ├── domain/
    │   │   └── models/                    # thin: mostly re-exports from packages/rules
    │   └── ui/
    │       ├── core/{localization/, themes/{colors,dimens,theme}.dart, ui/<shared widgets>}
    │       ├── ruler/{view_models/ruler_viewmodel.dart, widgets/{ruler_screen.dart, ruler_painter.dart}}
    │       └── <other features>/
    ├── test/                              # mirrors lib/
    │   └── goldens/                       # <feature>_<locale>.png
    ├── testing/                           # fakes, fixtures, testApp() harness with locale param
    └── integration_test/
```

Only two structural deltas from Compass: `packages/` + `tools/` as workspace siblings, and `test/goldens/`.

### 12.2 The official SQL recipe, and how it maps to drift

The docs recipe `docs.flutter.dev/app-architecture/design-patterns/sql` (source: `flutter/website` → `examples/app-architecture/todo_data_service/`) uses `sqflite`, but **explicitly names drift as a drop-in for the `DatabaseService` role**:

> Internally, the `TodoRepository` uses the `DatabaseService`, which implements the access to the SQL database using the `sqflite` package. **You can implement the same `DatabaseService` using other storage packages like `sqlite3`, `drift` or even cloud storage solutions like `firebase_database`.**

The recipe's repository (verbatim):

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
  // ...
}
```

**The lazy-open guard (`if (!_database.isOpen()) await _database.open();`) is the pattern to copy for your cold-start budget.** Your `ReferenceDatabase` should not be opened in `main()`. The recipe also warns, correctly:

> In some cases, you might want to close the database when you are done with it. … It's recommended that you check with the database package authors for recommendations.

**SOURCE:** https://docs.flutter.dev/app-architecture/design-patterns/sql

**drift-specific adaptations (my recommendations, not from the sample):**
- The `DatabaseService` role in drift is the `@DriftDatabase` class itself — it already *is* the service. So your layering is: `ReferenceDatabase` (drift, generated) → `ReferenceRepositoryDrift implements ReferenceRepository` (maps `RuleRow` → `Rule`, returns `Result<T>`) → ViewModel/Notifier. Do **not** let drift's generated row classes escape the repository (see §8.2).
- Your `Result` wrapping happens in the repository, not the database class — drift throws, so the repository is where `try/on Exception catch (e) { return Result.error(e); }` lives. This mirrors exactly how `ApiClient` throws and `BookingRepositoryRemote` wraps.
- **Two databases = two abstract repositories, never one.** The read-only reference repo exposes only getters; the user repo exposes mutations. A repository that can't write is the cheapest possible guarantee that you never write to a read-only asset DB.
- `close_sinks` / `cancel_subscriptions` lints (§4) exist precisely for drift `.watch()`.

### 12.3 Provider → riverpod translation of `config/dependencies.dart`

Compass's DI file has three properties worth preserving verbatim in riverpod:

| Compass (provider) | Your equivalent (riverpod 3.4.1) |
|---|---|
| `Provider(create: (c) => XRemote(...) as X)` — registers under the abstract type | `final xProvider = Provider<X>((ref) => XDrift(ref.watch(dbProvider)));` — **write the `<X>` type argument explicitly**; that is the direct analogue of the `as X` cast |
| `providersLocal` vs `providersRemote` lists | `ProviderScope(overrides: [...])` — `overridesProduction` / `overridesGolden` lists in `config/dependencies.dart` |
| `lazy: true` | riverpod providers are lazy by default — you get this for free |
| ViewModel constructed in `go_router` `builder:` + manually disposed in a container widget | `NotifierProvider` / `AsyncNotifierProvider` with autoDispose — **the `*_screen_container.dart` files become unnecessary**; this is a strict improvement over the sample |
| `Command0`/`Command1` for running/error/completed | riverpod's `AsyncValue` already models `loading`/`data`/`error`. **My recommendation: drop `Command` entirely and use `AsyncValue` + `ref.listen` for one-shot side effects.** Keeping both is redundant state. Keep `Result` for the *repository return type* (it forces exhaustive handling at the layer boundary); use `AsyncValue` for the *UI state*. |

The `ProviderScope(overrides: [...])` swap is what makes hermetic golden tests across 6 locales possible: one `overridesGolden` list with in-memory drift (`NativeDatabase.memory()`), a fixed `DateTime`, a fixed random seed — then loop `for (final locale in kSupportedLocales)`.

Both packages are healthy: `provider` 6.1.5+1 (2025-08-19), `flutter_riverpod` **3.4.1 (2026-07-26 — yesterday)**. Riverpod is the more actively developed of the two. Note the docs' own position (verbatim from the architecture recommendations):

> **Use `ChangeNotifiers` and `Listenables` to handle widget updates** — confidence: **conditional**. *"There are many options to handle state-management, and ultimately the decision comes down to personal preference."*

and from the case study:

> The UI of this app leans heavily on view models and `ChangeNotifier`, but it could've easily been written with streams, or with other libraries such as **`riverpod`**, `flutter_bloc`, and `signals`.

**So: using riverpod is explicitly sanctioned by the official guidance. The layering (View / ViewModel / Repository / Service) is the part that is "strongly recommended"; the notification mechanism is not.**

### 12.4 What to do about the domain layer

The official position (confidence: **conditional**):

> **Use a domain layer.** A domain layer is only needed if your application has exceedingly complex logic that crowds your ViewModels, or if you find yourself repeating logic in ViewModels. In very large apps, use-cases are useful, but in most apps they add unnecessary overhead.

Compass has exactly **two** use-cases (`BookingCreateUseCase`, `BookingShareUseCase`) across the whole app, and only where logic spanned three repositories.

**You have a rule engine that must be shared with a CLI tool. That is the textbook case where the answer is unambiguously YES** — and yours is stronger than the sample's, because your domain layer is a *separate pub package* with enforced zero Flutter/drift dependencies, not just a folder. Follow `BookingCreateUseCase`'s shape (constructor-injected repositories, returns `Result<T>`, one public method) for the *app-side* orchestration classes, and keep the actual rule evaluation in `packages/rules` as pure functions over pure data.

---

## 13. Anti-patterns / what NOT to do

Each of these is either explicitly stated by the official docs, or directly evidenced by the sample's code.

1. **Do NOT put logic in widgets.** Official, confidence **strong**. The only logic a View may contain: *"Simple if-statements to show and hide widgets based on a flag or nullable field in the ViewModel; animation logic that relies on the widget to calculate; layout logic based on device information, like screen size or orientation; simple routing logic."* Everything else is a ViewModel method. — https://github.com/flutter/website/blob/main/sites/docs/src/data/architectureRecommendations.yml

2. **Do NOT give a View access to a Repository.** The View gets exactly one ViewModel. If a widget calls `context.read<SomeRepository>()`, the layering is broken. Compass enforces this by making repository fields private (`final BookingRepository _bookingRepository;`).

3. **Do NOT name your shared-widgets folder `widgets/`.** Official: use `ui/core/`. Reason given: names that collide with Flutter SDK concepts are confusing. (Compass does use `widgets/` *inside a feature* — `ui/home/widgets/` — that's fine; it's the top-level shared one that must be `ui/core/ui/`.)

4. **Do NOT use `Widget _buildFoo()` helper methods.** Use a private `class _Foo extends StatelessWidget`. Stated in `.prompts/llm.md`, practised throughout the sample (`class _Booking extends StatelessWidget` in `home_screen.dart`). Helper methods break `const`-ness and defeat the element-tree diff.

5. **Do NOT let a `ListenableBuilder` wrap more than it must** — pass the stable subtree as `child:` and return `child!`. `home_screen.dart` does this twice; without it, every loading-state flip rebuilds the whole list.

6. **Do NOT show snackbars/dialogs/navigate from inside `build()`.** Register a listener on the Command/notifier in `initState`, act, then `clearResult()`. Remove it in `dispose()` and re-wire it in `didUpdateWidget`.

7. **Do NOT throw across a repository boundary.** Return `Result<T>`. Repositories/services catch with `on Exception catch (e) { return Result.error(e); }` — note **`on Exception`**, not bare `catch`, so `Error`s (programmer bugs) still crash.

8. **Do NOT use `dartz`/`Either`/`fpdart` for results.** Official guidance is a 40-line hand-rolled `sealed class Result<T>`. Exhaustive `switch` over sealed classes is a language feature since Dart 3; `Either<L,R>` is a pre-Dart-3 workaround. If you want a package, the docs name `result_dart` (2.2.0, 2026-03-07) — but the reference app copies the file.

9. **Do NOT expose concrete repository types in DI.** Always register under the abstract type (`as BookingRepository` / `Provider<BookingRepository>`). Otherwise flavor-swapping and faking silently stop working.

10. **Do NOT eagerly construct expensive dependencies at `runApp`.** Compass marks use-cases `lazy: true`; the SQL recipe opens the DB on first repository call. For a 1.2s cold-start budget on low-end Android, **nothing that touches disk should run before the first frame.**

11. **Do NOT use `mockito` + `build_runner` for test doubles.** The reference app uses hand-written fakes for everything it owns, and `mocktail` (no codegen) only for third-party types it can't hand-write. Codegen in the test loop is the slowest thing in a Flutter repo.

12. **Do NOT put unsafe result casts (`asOk`) in `lib/`.** They live in `testing/utils/result.dart`. Production code goes through exhaustive switches.

13. **Do NOT copy the Compass App's localization.** Hardcoded English map + `.replaceAll('{1}', ...)`. See §11.2. Use ARB + `gen-l10n` + ICU plurals.

14. **Do NOT use `EdgeInsets.only(left:/right:)` in an RTL app.** Use `EdgeInsetsDirectional.only(start:/end:)`. The sample uses the non-directional form in `home_screen.dart` — it's an English-only sample; you are not.

15. **Do NOT confuse `flutter/demos/compass_25` with the reference app.** `flutter/demos` self-describes as *"unmaintained code that supports talks, blogs, and other experiments."* `compass_25` is a flat `lib/{screens,widgets,model}` Cupertino/Firebase demo with no ViewModels, no repositories, and no `Result`. It is a *visual* demo, not an *architectural* one.

16. **Do NOT add new samples to `flutter/samples` expecting them to be reviewed.** The repo README now states: *"in most cases, we're not currently adding new samples to this repository while we rethink sample code in the new LLM world."* Consequence for you: this repo is a **maintained but frozen-in-scope** reference. Cross-check anything you take from it against `flutter/website`'s `examples/app-architecture/`, which is on a faster update cadence (Dart 3.12, freezed 3 syntax).

---

## 14. The complete official recommendation table (verbatim, with confidence levels)

From `flutter/website` → `sites/docs/src/data/architectureRecommendations.yml` (the data behind https://docs.flutter.dev/app-architecture/recommendations). Confidence key: **strong** = "always implement this in a new app"; **recommend** = "will likely improve your app"; **conditional** = "in certain circumstances".

**Separation of concerns**
| Recommendation | Confidence |
|---|---|
| Use clearly defined data and UI layers. | **strong** |
| Use the repository pattern in the data layer. | **strong** |
| Use ViewModels and Views in the UI layer. (MVVM) | **strong** |
| Use `ChangeNotifier`s and `Listenable`s to handle widget updates. | conditional |
| Do not put logic in widgets. | **strong** |
| Use a domain layer. | conditional ("Use in apps with complex logic requirements.") |

**Handling data**
| Recommendation | Confidence |
|---|---|
| Use unidirectional data flow. | **strong** |
| Use `Command`s to handle events from user interaction. | recommend |
| Use immutable data models. | **strong** |
| Use `freezed` or `built_value` to generate immutable data models. | recommend |
| Create separate API models and domain models. | conditional ("Use in large apps.") |

**App structure**
| Recommendation | Confidence |
|---|---|
| Use dependency injection. (recommends `package:provider`) | **strong** |
| Use `go_router` for navigation. ("preferred way to write 90% of Flutter applications") | recommend |
| Use standardized naming conventions for classes, files and directories. | recommend |
| Use abstract repository classes. | **strong** |

**Testing**
| Recommendation | Confidence |
|---|---|
| Test architectural components separately, and together. ("unit tests for every service, repository and ViewModel; widget tests for views — **testing routing and dependency injection are particularly important**") | **strong** |
| Make fakes for testing (and write code that takes advantage of fakes). | **strong** |

**Officially recommended external resources** (from the same page — these are the *only* third-party sources the Flutter team endorses here):
- `very_good_cli` — https://cli.vgv.dev/ (Very Good Ventures app template; "generates a similar app structure")
- Very Good Engineering architecture docs — https://engineering.verygood.ventures/architecture/architecture/
- `flutter_lints` — https://pub.dev/packages/flutter_lints
- DevTools — https://docs.flutter.dev/tools/devtools

---

## 15. Source index — everything cited, all verified reachable on 2026-07-27

**Code (read via `gh api repos/flutter/samples/contents/<path>`):**
- https://github.com/flutter/samples/tree/main/compass_app
- `compass_app/README.md`, `compass_app/app/{pubspec,analysis_options,devtools_options}.yaml`, `.metadata`
- `compass_app/app/lib/{main,main_development,main_staging}.dart`
- `compass_app/app/lib/config/{dependencies,assets}.dart`
- `compass_app/app/lib/routing/{router,routes}.dart`
- `compass_app/app/lib/utils/{result,command}.dart`
- `compass_app/app/lib/domain/models/{booking/booking,booking/booking_summary,destination/destination,itinerary_config/itinerary_config}.dart`
- `compass_app/app/lib/domain/use_cases/booking/booking_create_use_case.dart`
- `compass_app/app/lib/data/repositories/{booking/booking_repository,booking/booking_repository_local,booking/booking_repository_remote,destination/destination_repository_remote,auth/auth_repository,auth/auth_repository_remote,itinerary_config/itinerary_config_repository_memory}.dart`
- `compass_app/app/lib/data/services/{api/api_client,local/local_data_service,shared_preferences_service}.dart`
- `compass_app/app/lib/data/services/api/model/booking/booking_api_model.dart`
- `compass_app/app/lib/ui/home/{view_models/home_viewmodel,widgets/home_screen,widgets/home_screen_container}.dart`
- `compass_app/app/lib/ui/booking/{view_models/booking_viewmodel,widgets/booking_screen}.dart`
- `compass_app/app/lib/ui/search_form/view_models/search_form_viewmodel.dart`
- `compass_app/app/lib/ui/auth/logout/view_models/logout_viewmodel.dart`
- `compass_app/app/lib/ui/core/{localization/applocalization,themes/theme,themes/dimens,ui/error_indicator}.dart`
- `compass_app/app/test/{ui/home/widgets/home_screen_test,ui/search_form/view_models/search_form_viewmodel_test,utils/command_test,data/repositories/activity/activity_repository_local_test}.dart`
- `compass_app/app/testing/{app,mocks,fakes/repositories/fake_booking_repository,models/destination,utils/result}.dart`
- `compass_app/app/integration_test/app_local_data_test.dart`
- `/pubspec.yaml` (workspace root), `/analysis_defaults/{pubspec.yaml,lib/flutter.yaml}`, `/README.md`, `/.prompts/{llm,code_freshness}.md`

**Docs (read via `gh api repos/flutter/website/contents/<path>`, published at docs.flutter.dev):**
- https://docs.flutter.dev/app-architecture/guide — `sites/docs/src/content/app-architecture/guide.md`
- https://docs.flutter.dev/app-architecture/case-study — `.../case-study/index.md`
- https://docs.flutter.dev/app-architecture/case-study/dependency-injection — `.../case-study/dependency-injection.md`
- https://docs.flutter.dev/app-architecture/case-study/testing — `.../case-study/testing.md`
- https://docs.flutter.dev/app-architecture/recommendations — `.../recommendations.md` + `sites/docs/src/data/architectureRecommendations.yml`
- https://docs.flutter.dev/app-architecture/design-patterns/command — `.../design-patterns/command.md`
- https://docs.flutter.dev/app-architecture/design-patterns/sql — `.../design-patterns/sql.md`
- https://docs.flutter.dev/app-architecture/design-patterns/offline-first — `.../design-patterns/offline-first.md`
- Runnable doc examples: `flutter/website/examples/app-architecture/{command,result,offline_first,optimistic_state,todo_data_service}/`

**Package metadata (via `api.pub.dev`, 2026-07-27):** freezed 3.2.5 · flutter_lints 6.0.0 · provider 6.1.5+1 · go_router 17.3.0 · shared_preferences 2.5.5 · mocktail 1.0.5 · drift 2.34.2 · flutter_riverpod 3.4.1 · command_it 9.5.1 · result_dart 2.2.0
**Changelog:** https://github.com/rrousselGit/freezed/blob/master/packages/freezed/CHANGELOG.md

**Explicitly NOT a reference:** `flutter/demos/compass_25` (repo description: *"This repo is for unmaintained code that supports talks, blogs, and other experiments."*).

**Not verified / no evidence found:**
- Which Flutter version `compass_app/app/.metadata` revision `ee624bc4fd41413cbb89099b0701a42287643d9a` corresponds to.
- Any golden-test guidance in the Compass App — there is none.
- Any RTL/bidi guidance in the Compass App — there is none; `AppLocalizationDelegate.isSupported` returns true only for `'en'`.
