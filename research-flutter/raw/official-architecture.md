# Flutter's Official App Architecture Guidance — Primary Source Extraction

**Research date:** 2026-07-27
**Toolchain this is written against:** Flutter 3.44.6 stable (Dart 3.12.2). Verified against
`https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json` — Flutter 3.44.6
released 2026-07-09, `dart_sdk_version: 3.12.2`. (3.44.7 and 3.44.8 also exist on stable, released
2026-07-20 and 2026-07-23.)
**Method:** Everything below was read from the *source markdown* of docs.flutter.dev in the
`flutter/website` repo (`main` @ last commit 2026-07-24) plus the real code in `flutter/samples`.
Reading the repo source rather than the rendered HTML avoids paraphrase drift — the quotes are
byte-exact. Rendered pages were spot-checked live and match.

Repo paths used:
- Docs prose: `https://github.com/flutter/website/tree/main/sites/docs/src/content/app-architecture`
- Runnable examples: `https://github.com/flutter/website/tree/main/examples/app-architecture`
- Recommendation data: `https://github.com/flutter/website/blob/main/sites/docs/src/data/architectureRecommendations.yml`
- Reference app: `https://github.com/flutter/samples/tree/main/compass_app`

---

## 0. How old is this guidance, and is it stale?

This matters because "Flutter architecture" advice on the open web is mostly older than the official
guidance and therefore contradicts it.

| Date | Event | Evidence |
|---|---|---|
| 2024-11-18 | Initial architecture guidance pages published | flutter/website PR #11300, `git log src/content/app-architecture/index.md` |
| 2024-12-02 | Case-study pages published | PR #11414 |
| 2024-12-11 | Design-pattern index page published | PR #11468 |
| 2025-02-12 | Examples reformatted for Dart 3.7 | PR #11702 |
| 2025-08-19 | Examples updated for new lints | PR #12325 |
| 2026-05-04 | **"Managing app-wide session state" section added to the guide** | PR #13352 — this is new; most secondary write-ups do not have it |
| 2026-05-18 | SQL design-pattern page updated for **Dart 3.12** | PR #13397 |
| 2026-06-19 | Compass app migrated to `SharedPreferencesAsync` | flutter/samples commit |
| 2026-07-24 | Last commit on flutter/website main at time of research | `gh api repos/flutter/website/commits` |

**Practical consequence:** any architecture blog post dated before **November 2024** predates the
existence of official Flutter architecture guidance entirely. Treat "Clean Architecture in Flutter",
"BLoC is the recommended pattern", and "put your business logic in a Cubit" articles from 2021–2023
as *superseded* — not wrong necessarily, but not what Flutter's docs now prescribe. Likewise, any
`Result`/`Command` sample that does not use `sealed` classes and `switch` pattern matching predates
Dart 3 (May 2023) and should be rewritten.

**One page that has NOT been updated:** `data-and-backend/state-mgmt/options` used to name specific
packages (provider, Riverpod, BLoC, etc.). It no longer endorses any of them — it now just links to
the pub.dev `#state-management` topic. Source:
`https://docs.flutter.dev/data-and-backend/state-mgmt/options`. This is a deliberate retreat to
neutrality on state management, while the architecture guide remains opinionated about *structure*.

---

## 1. The prescribed layers — exact wording

### 1.1 Two layers, mandatory

> "[Separation-of-concerns] is the most important principle to follow when designing your Flutter
> app. Your Flutter application should split into two broad layers, the UI layer and the Data
> layer."
> — https://docs.flutter.dev/app-architecture/guide

> "This guide recommends you split your application into the following components:
> * Views
> * View models
> * Repositories
> * Services"
> — same page

### 1.2 The layer-communication rule (quote it to your team, verbatim)

> "These are called 'layers' because each layer can only communicate with the layers directly below
> or above it. The UI layer shouldn't know that the data layer exists, and vice versa."
> — https://docs.flutter.dev/app-architecture/concepts

Note the deliberate asymmetry with the MVVM mapping:

> "Views and view models make up the UI layer of an application. Repositories and services represent
> the data of an application, or the model layer of MVVM."
> — https://docs.flutter.dev/app-architecture/guide

### 1.3 The "rules of engagement" table — this is the single most quotable artifact

Reproduced exactly from
https://docs.flutter.dev/app-architecture/case-study/dependency-injection :

| Component | Rules of engagement |
|---|---|
| **View** | 1. A view is only aware of exactly one view model, and is never aware of any other layer or component. When created, Flutter passes the view model to the view as an argument, exposing the view model's data and command callbacks to the view. |
| **ViewModel** | 1. A ViewModel belongs to exactly one view, which can see its data, but the model never needs to know that a view exists. 2. A view model is aware of one or more repositories, which are passed into the view model's constructor. |
| **Repository** | 1. A repository can be aware of many services, which are passed as arguments into the repository constructor. 2. A repository can be used by many view models, but it never needs to be aware of them. |
| **Service** | 1. A service can be used by many repositories, but it never needs to be aware of a repository (or any other object). |

Additional hard rules stated elsewhere in the guide:

> "Views and view models should have a one-to-one relationship."
> "Repositories should never be aware of each other. If your application has business logic that
> needs data from two repositories, you should combine the data in the view model or in the domain
> layer, especially if your repository-to-view-model relationship is complex."
> "There should be a repository class for each different type of data handled in your app."
> "Your app should have one service class per data source."
> — https://docs.flutter.dev/app-architecture/guide

And on privacy of injected dependencies:

> "Private methods prevent the view, which has access to the view model, from calling methods on the
> repository directly."
> — https://docs.flutter.dev/app-architecture/case-study/dependency-injection

> "It's important that the service is a private member, so that the UI layer can't bypass the
> repository and call a service directly."
> — https://docs.flutter.dev/app-architecture/case-study/data-layer

---

## 2. Views: exactly what a View may contain

**WHAT:** A View is a widget (or composition of widgets). It receives a ViewModel as a constructor
argument and does nothing but render it and forward events.

**The exhaustive allow-list, quoted:**

> "In Flutter, views are the widget classes of your application. Views are the primary method of
> rendering UI, and shouldn't contain any business logic. They should be passed all data they need
> to render from the view model.
>
> The only logic a view should contain is:
> * Simple if-statements to show and hide widgets based on a flag or nullable field in the view model
> * Animation logic
> * Layout logic based on device information, like screen size or orientation.
> * Simple routing logic
>
> All logic related to data should be handled in the view model."
> — https://docs.flutter.dev/app-architecture/guide

The recommendations data file states the same thing as a **Strongly recommend** item titled
literally **"Do not put logic in widgets."** with a slightly different wording of item 2 —
"Animation logic **that relies on the widget to calculate**". Source:
https://github.com/flutter/website/blob/main/sites/docs/src/data/architectureRecommendations.yml

**Three responsibilities of the widgets inside a view, quoted:**

> "* They display the data properties from the view model.
> * They listen for updates from the view model and re-render when new data is available.
> * They attach callbacks from the view model to event handlers, if applicable."
> — https://docs.flutter.dev/app-architecture/case-study/ui-layer

**WHY:** it makes the widget layer trivially replaceable and testable, and it means golden tests
exercise pure rendering. For an app with six locales and RTL golden tests, this is not a style
preference — a View with logic in it multiplies your golden matrix by the number of logic branches.

**REAL EXAMPLE** (from https://github.com/flutter/samples/tree/main/compass_app, quoted in
https://docs.flutter.dev/app-architecture/case-study/ui-layer):

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
    );
  }
}
```

> "Most of the time, a view's only inputs should be a `key`, which all Flutter widgets take as an
> optional argument, and the view's corresponding view model."

**"View" is not "widget":**

> "'View' is an abstract term, and one view doesn't equal one widget. Widgets are composable, and
> several can be combined to create one view. Therefore, view models don't have a one-to-one
> relationship with widgets, but rather a one-to-one relationship with a *collection* of widgets."
> — https://docs.flutter.dev/app-architecture/guide

**A feature is defined by the UI layer, not by the data:**

> "A feature of an application is user centric, and therefore defined by the UI layer. Every
> instance of a paired *view* and *view model* defines one feature in your app. This is often a
> screen in your app, but it doesn't have to be."

The docs' own example: a `LogoutViewModel` + `LogoutView` that is just a single button, droppable
anywhere. So "one ViewModel per screen" is *wrong* as a rule; it's one ViewModel per *feature*, and
a feature can be a button.

---

## 3. ViewModels: what they may and may not do

**Responsibilities, quoted exactly:**

> "A view model's main responsibilities include:
> * Retrieving application data from repositories and transforming it into a format suitable for
>   presentation in the view. For example, it might filter, sort, or aggregate data.
> * Maintaining the current state needed in the view, so that the view can rebuild without losing
>   data. For example, it might contain boolean flags to conditionally render widgets in the view,
>   or a field that tracks which section of a carousel is active on screen.
> * Exposes callbacks (called **commands**) to the view that can be attached to an event handler,
>   like a button press or form submission."
> — https://docs.flutter.dev/app-architecture/guide

**Inputs/outputs contract, quoted:**

> "a view model in the logic layer should only take in data sources as inputs, such as repositories,
> and should only expose commands and data formatted for views."
> — https://docs.flutter.dev/app-architecture/concepts

**What a ViewModel MUST NOT do (derived directly from the quoted rules):**
- must not know about a View (rule: "the model never needs to know that a view exists")
- must not hold a `BuildContext`, show a `SnackBar`, or navigate — those are View concerns; the
  official pattern is that the View *listens* to the ViewModel/Command and performs the UI action
  (see `_onViewModelChanged` in §5.4)
- must not talk to a Service — only to Repositories (and optionally use-cases)
- must not expose a mutable collection. The official code is explicit:

```dart
List<BookingSummary> _bookings = [];

/// Items in an [UnmodifiableListView] can't be directly modified,
/// but changes in the source list can be modified. Since _bookings
/// is private and bookings is not, the view has no way to modify the
/// list directly.
UnmodifiableListView<BookingSummary> get bookings => UnmodifiableListView(_bookings);
```
— https://docs.flutter.dev/app-architecture/case-study/ui-layer

**UI state must be immutable:**

> "The output of a view model is data that a view needs to render, generally referred to as **UI
> State**, or just state. UI state is an immutable snapshot of data that is required to fully render
> a view."
> — https://docs.flutter.dev/app-architecture/case-study/ui-layer

The docs also suggest, when a ViewModel gets wide, promoting the state to a dedicated class:

> "In some cases, you might want to create objects that specifically represent the UI state. For
> example, you could create a class named `HomeUiState`."

**REAL, COMPLETE ViewModel** (not a doc excerpt — the actual file
`compass_app/app/lib/ui/home/view_models/home_viewmodel.dart`, read via
`gh api repos/flutter/samples/contents/...`):

```dart
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required BookingRepository bookingRepository,
    required UserRepository userRepository,
  }) : _bookingRepository = bookingRepository,
       _userRepository = userRepository {
    load = Command0(_load)..execute();
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
      // ...
      return userResult;
    } finally {
      notifyListeners();
    }
  }
}
```

Three things to steal from this file:
1. Commands are created **in the constructor**, and `load` is fired immediately with the cascade
   `Command0(_load)..execute()`.
2. `notifyListeners()` is in a `finally`, so the UI is refreshed on the error path too.
3. The real `_deleteBooking` has a comment `notifyListeners(); // notify only when data changes` —
   i.e. the team explicitly de-duplicated notifications (flutter/samples PR #2839, merged
   2026-06-19, "remove redundant notifyListeners in HomeViewModel deleteBooking").

---

## 4. Repositories and Services

### 4.1 Repository — quoted

> "[Repository] classes are the source of truth for your model data. They're responsible for polling
> data from services, and transforming that raw data into **domain models**. Domain models represent
> the data that the application needs, formatted in a way that your view model classes can consume.
> There should be a repository class for each different type of data handled in your app.
>
> Repositories handle the business logic associated with services, such as:
> * Caching
> * Error handling
> * Retry logic
> * Refreshing data
> * Polling services for new data
> * Refreshing data based on user actions"
> — https://docs.flutter.dev/app-architecture/guide

> "A repository's sole responsibility is to manage application data. A repository is the source of
> truth for a single type of application data, and it should be the only place where that data type
> is mutated."
> — https://docs.flutter.dev/app-architecture/case-study/data-layer

### 4.2 NEW (May 2026): repositories own app-wide session state

This section did not exist before flutter/website PR #13352 (merged 2026-05-04) and is absent from
essentially every third-party summary of Flutter architecture:

> "Because repositories are the single source of truth for application data, they are also the ideal
> place to manage **app-wide lifecycle state**—state that needs to be shared across multiple view
> models but shouldn't persist beyond the current application session.
>
> Examples of app-wide lifecycle state include an active user session, in-memory data caches, or
> transient application settings. Because view models and repositories have a many-to-many
> relationship, multiple view models can depend on the same repository instance (typically managed
> through a service locator or dependency injection container). This allows distinct features to
> reactively observe and modify the same shared state through streams and methods exposed by the
> repository, without violating the clean one-to-one boundary between a view and its view model."
> — https://docs.flutter.dev/app-architecture/guide

**Why this matters for your app:** it is the official blessing for putting cross-screen state — the
active measurement session, the loaded rule-engine context, the current unit system, the in-memory
cache of the read-only reference DB — in a Repository rather than inventing a "global ViewModel" or
a bare Riverpod `StateNotifier` floating outside the layers. Note the explicit endorsement of a
**service locator** here, which slightly softens the strict constructor-injection line elsewhere.

### 4.3 Service — quoted

> "Services are in the lowest layer of your application. They wrap API endpoints and expose
> asynchronous response objects, such as `Future` and `Stream` objects. **They're only used to
> isolate data-loading, and they hold no state.** Your app should have one service class per data
> source. Examples of endpoints that services might wrap include:
> * The underlying platform, like iOS and Android APIs
> * REST endpoints
> * Local files
>
> As a rule of thumb, services are most helpful when the necessary data lives outside of your
> application's Dart code."
> — https://docs.flutter.dev/app-architecture/guide

> "A service class is the least ambiguous of all the architecture components. It's stateless, and
> its functions don't have side effects. Its only job is to wrap an external API."
> — https://docs.flutter.dev/app-architecture/case-study/data-layer

**Direct mapping for your app:** SQLite is "outside your Dart code", so drift belongs behind a
Service. Camera, GPS, PDF writing, and file-system access are all platform APIs → one Service each.
`rootBundle` asset loading is "local files" → a Service. That gives you, minimally:
`ReferenceDatabaseService` (read-only asset DB), `UserDatabaseService` (writable DB),
`CameraService`, `LocationService`, `PdfExportService`, `AssetBundleService`.

The "hold no state" rule is the one you will be tempted to break, because a drift `DatabaseConnection`
*is* state. Two defensible readings: (a) treat the open connection as a resource handle rather than
application state and keep it in the Service; (b) hold the connection in the Repository. The official
SQL design pattern does **(a)** — `DatabaseService` owns `_database` and exposes `isOpen()`/`open()`,
and the *Repository* is the one that checks and opens it. Follow (a).

### 4.4 Domain models vs API/DB models

> "Repositories output application data as domain models."
> "These data models differ from API models in that they only contain the data needed by the rest of
> the app. API models contain raw data that often needs to be filtered, combined, or deleted to be
> useful to the app's view models. The repo refines the raw data and outputs it as domain models."
> — https://docs.flutter.dev/app-architecture/case-study/data-layer

Splitting them is only **Conditional** ("Use in large apps") per the recommendations file. For your
app the split is worth it in exactly one place: drift's generated row classes are *not* domain
models — they are the DB representation. Map them at the Repository boundary. This is also the only
way to keep your pure-Dart rule-engine package free of drift imports.

### 4.5 Abstract repository classes — **Strongly recommend**

> "Repository classes are the sources of truth for all data in your app, and facilitate communication
> with external APIs. Creating abstract repository classes allows you to create different
> implementations, which can be used for different app environments, such as 'development' and
> 'staging'."
> — architectureRecommendations.yml, category `app-structure`, `confidence: strong`

**REAL EXAMPLE** — this is the single most relevant file in the whole reference app for an
offline-only build, because it is a repository whose *only* source is bundled assets
(`compass_app/app/lib/data/repositories/activity/activity_repository_local.dart`):

```dart
/// Local implementation of ActivityRepository
/// Uses data from assets folder
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

with the interface:

```dart
/// Data source for activities.
abstract class ActivityRepository {
  /// Get activities by [Destination] ref.
  Future<Result<List<Activity>>> getByDestination(String ref);
}
```

and the asset-reading Service (`data/services/local/local_data_service.dart`):

```dart
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

Note: `LocalDataService.getContinents()` is *synchronous* and returns hard-coded `const` objects.
So "Service wraps an external API" is applied loosely in the reference app itself — a Service can be
a constant table. Useful precedent for your seeded reference data.

---

## 5. The Command pattern — official description and full code

Source: https://docs.flutter.dev/app-architecture/design-patterns/command
Runnable example: https://github.com/flutter/website/tree/main/examples/app-architecture/command
Production copy: https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/command.dart

### 5.1 What it is, quoted

> "A command is a class that wraps a method and helps to handle the different states of that method,
> such as running, complete, and error."

> "The `execute()` method sets the running state to `true` and resets the `error` and `completed`
> states. When the action finishes, the `running` state changes to `false` and the `completed` state
> to `true`.
>
> If the `running` state is `true`, the command cannot begin executing again. This prevents users
> from triggering a command multiple times by pressing a button rapidly.
>
> The command's `execute()` method captures any thrown `Exceptions` automatically and exposes them in
> the `error` state."

### 5.2 WHY the docs say to use it — the real reason

> "The `Command.execute` method is asynchronous, so it can't guarantee that the data will be
> available when the view wants to render. This gets at *why* the Compass app uses `Commands`. …
> Because the `load` command is a property that exists on the view model rather than something
> ephemeral, it doesn't matter when the `load` method is called or when it resolves. For example, if
> the load command resolves before the `HomeScreen` widget was even created, it isn't a problem
> because the `Command` object still exists, and exposes the correct state."
> — https://docs.flutter.dev/app-architecture/case-study/ui-layer

The docs link to the actual bug this fixed:
https://github.com/flutter/samples/pull/2449#pullrequestreview-2328333146

### 5.3 The full official `Command` class (verbatim, `examples/app-architecture/command/lib/command.dart`)

```dart
// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'result.dart';

/// Defines a command action that returns a [Result] of type [T].
/// Used by [Command0] for actions without arguments.
typedef CommandAction0<T> = Future<Result<T>> Function();

/// Defines a command action that returns a [Result] of type [T].
/// Takes an argument of type [A].
/// Used by [Command1] for actions with one argument.
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);

/// Facilitates interaction with a view model.
///
/// Encapsulates an action,
/// exposes its running and error states,
/// and ensures that it can't be launched again until it finishes.
///
/// Use [Command0] for actions without arguments.
/// Use [Command1] for actions with one argument.
///
/// Actions must return a [Result] of type [T].
///
/// Consume the action result by listening to changes,
/// then call to [clearResult] when the state is consumed.
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;

  /// Whether the action is running.
  bool get running => _running;

  Result<T>? _result;

  /// Whether the action completed with an error.
  bool get error => _result is Error;

  /// Whether the action completed successfully.
  bool get completed => _result is Ok;

  /// The result of the most recent action.
  ///
  /// Returns `null` if the action is running or completed with an error.
  Result<T>? get result => _result;

  /// Clears the most recent action's result.
  void clearResult() {
    _result = null;
    notifyListeners();
  }

  /// Execute the provided [action], notifying listeners and
  /// setting the running and result states as necessary.
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

/// A [Command] that accepts no arguments.
final class Command0<T> extends Command<T> {
  /// Creates a [Command0] with the provided [CommandAction0].
  Command0(this._action);

  final CommandAction0<T> _action;

  /// Executes the action.
  Future<void> execute() async {
    await _execute(_action);
  }
}

/// A [Command] that accepts one argument.
final class Command1<T, A> extends Command<T> {
  /// Creates a [Command1] with the provided [CommandAction1].
  Command1(this._action);

  final CommandAction1<T, A> _action;

  /// Executes the action with the specified [argument].
  Future<void> execute(A argument) async {
    await _execute(() => _action(argument));
  }
}
```

Two discrepancies worth knowing (both real, both in the docs):
- The **simplified** `Command` shown mid-page (`lib/main.dart (Command)`) catches
  `on Exception catch (error)` inside `_execute`. The **full** `Command` above does **not** catch —
  it relies on the action returning `Result`, so a genuinely thrown exception propagates. The
  doc prose ("captures any thrown `Exceptions` automatically") describes the *simplified* one. If
  you copy the full class, your `_load()` bodies must not throw.
- The full class's doc comment says `result` "Returns `null` if the action is running or completed
  with an error" — that is wrong; `_result` holds the `Error` object after a failed action, which is
  exactly how `bool get error => _result is Error` works. Treat the comment as a doc bug.

### 5.4 Consuming a Command from a View (official pattern)

```dart
body: ListenableBuilder(
  listenable: widget.viewModel.load,
  builder: (context, child) {
    if (widget.viewModel.load.running) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.viewModel.load.error != null) {
      return Center(
        child: Text('Error: ${widget.viewModel.load.error}'),
      );
    }

    return child!;
  },
  child: ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) {
      // ···
    },
  ),
),
```
— https://docs.flutter.dev/app-architecture/design-patterns/command

Nested `ListenableBuilder`s: the outer one listens to the **Command** (running/error), the inner one
listens to the **ViewModel** (data). The `child:` parameter means the inner tree is built once and
reused. That is a real performance idiom, not decoration.

One-shot UI effects (snackbars, navigation) go in a listener, and **must** clear the result:

```dart
void _onViewModelChanged() {
  if (widget.viewModel.load.error != null) {
    widget.viewModel.load.clear();
    // Show Snackbar
  }
}
```

> "You need to clear the error state each time you execute this action, otherwise this action happens
> each time `notifyListeners()` is called."

### 5.5 Is the Command pattern mandatory?

No. It is **Recommend**, not **Strongly recommend**:

> "Use `Commands` to handle events from user interaction. — Commands prevent rendering errors in your
> app, and standardize how the UI layer sends events to the data layer." (`confidence: recommend`)

and the docs say plainly:

> "This pattern standardizes how common UI problems are solved in the app, making your codebase less
> error-prone and more scalable, but it's not a pattern that every app will want to implement.
> Whether you want to use it is highly dependent on other architectural choices you make. Many
> libraries that help you manage state have their own tools to solve these problems."
> — https://docs.flutter.dev/app-architecture/case-study/ui-layer

**This is the escape hatch for a Riverpod app.** `AsyncValue<T>` from Riverpod is a strict superset
of what `Command` provides: it models `loading` / `data` / `error` as a sealed union, survives
rebuilds because it lives in the provider (not the widget), and `AsyncNotifier`'s
`state = await AsyncValue.guard(...)` does what `Command._execute` does. Writing `Command0`/`Command1`
on top of Riverpod is duplicated machinery. **Recommendation: skip `Command` in a Riverpod app; use
`AsyncValue` and `AsyncNotifier`, and keep the *naming* (`load`, `delete`, `export`) so the code still
reads like the official architecture.** Retain the *rule* that a Command must be idempotent under
rapid taps — Riverpod does not give you that for free.

---

## 6. The Result type — official description and full code

Source: https://docs.flutter.dev/app-architecture/design-patterns/result
Runnable example: https://github.com/flutter/website/tree/main/examples/app-architecture/result
Production copy: https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/result.dart

### 6.1 The motivating argument, quoted

> "As mentioned in the [Error handling documentation], Dart's exceptions are unhandled exceptions.
> This means that methods that throw exceptions don't need to declare them, and calling methods
> aren't required to catch them either.
>
> This can lead to situations where exceptions are not handled properly. In large projects,
> developers might forget to catch exceptions, and the different application layers and components
> could throw exceptions that aren't documented. This can lead to errors and crashes."

> "You can attempt to solve this by documenting the `ApiClientService`, warning about the possible
> exceptions it might throw. However, since the view model doesn't use the service directly, other
> developers working in the codebase might miss this information."

### 6.2 Key takeaways, quoted

> "- `Result` classes force the calling method to check for errors, reducing the amount of bugs
>    caused by uncaught exceptions.
> - `Result` classes help improve control flow compared to try-catch blocks.
> - `Result` classes are `sealed` and can only return `Ok` or `Error` instances, allowing the code to
>   unwrap them with a switch statement."

### 6.3 Full official `Result` (verbatim; identical in the docs example and in compass_app)

```dart
/// Utility class that simplifies handling errors.
///
/// Return a [Result] from a function to indicate success or failure.
///
/// A [Result] is either an [Ok] with a value of type [T]
/// or an [Error] with an [Exception].
///
/// Use [Result.ok] to create a successful result with a value of type [T].
/// Use [Result.error] to create an error result with an [Exception].
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

/// A successful [Result] with a returned [value].
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  /// The returned value of this result.
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// An error [Result] with a resulting [error].
final class Error<T> extends Result<T> {
  const Error._(this.error);

  /// The resulting error of this result.
  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
```

Design notes that are easy to miss:
- `Ok._` and `Error._` have **private** constructors, so `Result.ok(...)` / `Result.error(...)` are
  the only construction paths. `sealed` + private ctors = an exhaustively-switchable closed union.
- `Error` **shadows** `dart:core`'s `Error`. This is a real footgun: in any file that imports both,
  `Error` means the Result subclass. The official code accepts this. If you write a pure-Dart domain
  package it is worth aliasing or renaming (`Failure`) — but be aware you are then diverging from
  every doc snippet.
- The error channel is typed `Exception`, **not** `Object`. So `Error`s (`StateError`,
  `AssertionError`) and anything thrown that isn't an `Exception` cannot be carried. All the official
  catch clauses are `on Exception catch (e)` — which means a `TypeError` from a bad cast will escape
  your Result-based control flow entirely. Know this before you rely on Result for crash-proofing.

### 6.4 Unwrapping (official)

```dart
Future<void> load() async {
  final result = await userProfileRepository.getUserProfile();
  switch (result) {
    case Ok<UserProfile>():
      userProfile = result.value;
    case Error<UserProfile>():
      error = result.error;
  }
  notifyListeners();
}
```

Note the switch cases use the **explicitly typed** `Ok<UserProfile>()` form, not bare `Ok()`. That is
what makes `result.value` promote to `UserProfile` rather than `dynamic`. Copy the style.

### 6.5 `asOk` is TEST-ONLY — a detail the docs get wrong

The data-layer case study writes `final booking = resultBooking.asOk.value;`
(https://docs.flutter.dev/app-architecture/case-study/data-layer). In the real Compass app, `asOk`
does **not** exist in `lib/` — it is defined in `compass_app/app/testing/utils/result.dart`, a
separate `testing/` sub-package:

```dart
extension ResultCast<T> on Result<T> {
  /// Convenience method to cast to Ok
  Ok<T> get asOk => this as Ok<T>;

  /// Convenience method to cast to Error
  Error get asError => this as Error<T>;
}
```
(verified via `gh search code "asOk repo:flutter/samples"` — every non-`testing/` hit is under
`test/`.)

**Do not put `asOk` in production code.** It is an unchecked cast that throws on the error path and
defeats the entire point of `Result`. In tests it is fine because a wrong cast should fail the test.

### 6.6 Result vs Riverpod's AsyncValue — the genuine disagreement

The docs recommend `Result` at the Repository/Service boundary and use it at every layer. Riverpod
users often argue the opposite: let repositories throw, and let `AsyncValue.guard` catch at the
provider boundary, since `AsyncValue` already carries `error` + `stackTrace`.

**Recommendation for this app: use `Result` inside the data layer and the pure-Dart domain package;
let Riverpod's `AsyncValue` carry it into the UI.** Reasoning:
1. The pure-Dart rule engine cannot import Riverpod, so it needs *some* error-carrying return type.
   `Result` (or your own `sealed` union) is that type, and Dart 3 sealed classes make it free.
2. `Result` loses the stack trace — the official class stores only `Exception error`. For an offline
   app where you cannot phone home, losing stack traces is a real cost. Either extend the official
   class with a `StackTrace? stackTrace` field, or convert to `AsyncValue.error(e, st)` at the
   provider boundary where the stack trace is still available.
3. Do **not** double-wrap: `AsyncValue<Result<T>>` is an anti-pattern — you get four states where two
   are meaningful. Unwrap the `Result` in the notifier and re-throw or set `AsyncValue.error`.

Named alternatives from the docs (verified on pub.dev today): `result_dart` (2.2.0, published
2026-03-07, active), `result_type`, `multiple_result`. Given the class is ~30 lines, **vendor it**;
do not take a dependency.

---

## 7. Offline-first — the page, in full, and what changes when there is no remote

Source: https://docs.flutter.dev/app-architecture/design-patterns/offline-first
Runnable example: https://github.com/flutter/website/tree/main/examples/app-architecture/offline_first

### 7.1 The page's own framing (and its blind spot)

> "An offline-first application is an app capable of offering most or all of its functionality while
> being disconnected from the internet. Offline-first applications usually rely on stored data to
> offer users temporary access to data that would otherwise only be available online."

**Read that second sentence carefully.** The entire page is written for apps that *have* a server and
degrade gracefully. Every code sample on the page involves `ApiClientService`. **There is no official
Flutter guidance for a 100%-offline app with no remote source at all.** Say "no evidence found" if
someone asks for it — do not invent one. What *is* transferable is stated below.

### 7.2 The one architectural sentence that survives with no remote

> "As explained in the common architecture concepts guide, repositories act as the single source of
> truth. They are responsible for presenting local or remote data, and should be the only place where
> data can be modified. In offline-first applications, repositories combine different local and remote
> data sources to present data in a single access point, independently of the connectivity state of
> the device."

With one source instead of two, this collapses to: **the Repository owns the local database Service
and is the only writer.** Which is exactly the SQL design pattern (§8), not the offline-first pattern.

### 7.3 The three read strategies, quoted and assessed

**(a) Local as fallback** — try remote, catch, fall back to DB.
```dart
Future<UserProfile> getUserProfile() async {
  try {
    final apiUserProfile = await _apiClientService.getUserProfile();
    await _databaseService.updateUserProfile(apiUserProfile);
    return apiUserProfile;
  } catch (e) {
    final databaseUserProfile = await _databaseService.fetchUserProfile();
    if (databaseUserProfile != null) {
      return databaseUserProfile;
    } else {
      throw Exception('User profile not found');
    }
  }
}
```
→ **N/A for your app.** Also note this snippet abandons `Result` and throws — the page is internally
inconsistent with the Result recommendation.

**(b) Stream that emits local-then-remote** — the page calls this "a better alternative".
```dart
Stream<UserProfile> getUserProfile() async* {
  final userProfile = await _databaseService.fetchUserProfile();
  if (userProfile != null) {
    yield userProfile;
  }
  try {
    final apiUserProfile = await _apiClientService.getUserProfile();
    await _databaseService.updateUserProfile(apiUserProfile);
    yield apiUserProfile;
  } catch (e) {
    // Handle the error
  }
}
```
> "First, the stream emits the locally stored data using the `DatabaseService`. This call is generally
> faster and less error prone than a network call, and by doing it first the view model can already
> display data to the user."

→ **The *shape* is highly relevant even offline.** Substitute "cheap local read" for "database" and
"expensive local computation" for "network": e.g. yield the cached ruler calibration immediately,
then yield the recomputed rule-engine result. This is the correct pattern for hitting a 1.2 s cold
start — emit something renderable before the expensive work finishes.

The ViewModel-side consumption is officially:
```dart
Future<void> load() async {
  await _userProfileRepository
      .getUserProfile()
      .listen(
        (userProfile) {
          _userProfile = userProfile;
          notifyListeners();
        },
        onError: (error) {
          // handle error
        },
      )
      .asFuture<void>();
}
```
→ **Do not copy this in a Riverpod app.** It creates a subscription that is never cancelled if the
ViewModel is disposed mid-stream. Riverpod's `StreamProvider` / `ref.watch` handles cancellation via
`ref.onDispose`. Use that instead. (With drift, `.watch()` on a query gives you exactly this stream
for free, re-emitting on every write.)

**(c) Local only + explicit sync** — this is the closest the docs get to your case:
```dart
Future<UserProfile> getUserProfile() async {
  final userProfile = await _databaseService.fetchUserProfile();
  if (userProfile == null) {
    throw Exception('Data not found');
  }
  return userProfile;
}

Future<void> sync() async { /* ... */ }
```
> "Another possible approach uses locally stored data for read operations. This approach requires that
> the data has been preloaded at some point into the database, and requires a synchronization
> mechanism that can keep the data up to date."

→ **Delete `sync()` and you have your reference-DB repository.** "Preloaded at some point into the
database" is literally your pre-seeded asset DB — except your preload happens at build time in the
content tool rather than at runtime from a server. The docs do not cover shipping a pre-seeded DB as
an asset; that is drift/sqflite territory, not architecture territory.

### 7.4 Write strategies

- **Online-only writing** — API first, DB only on success. N/A.
- **Offline-first writing** — DB first, then best-effort API:
```dart
Future<void> updateUserProfile(UserProfile userProfile) async {
  await _databaseService.updateUserProfile(userProfile);
  try {
    await _apiClientService.putUserProfile(userProfile);
  } catch (e) {
    // Handle the error
  }
}
```
→ With the API line deleted this is just "Repository writes to DB". **The transferable rule is
ordering: persist first, then do the volatile thing.** For your app: write the measurement to the
user DB *before* generating the PDF or writing the photo file, so a crash during export never loses
the record.

### 7.5 Synchronization — everything in this section is N/A

`Timer.periodic(...) => sync()`, the `bool synchronized` flag on the model, `workmanager`,
`connectivity_plus`, `battery_plus`, Firebase Cloud Messaging push-triggered sync. **None of it
applies.** Explicitly: **do not add `connectivity_plus` or a `synchronized` column** to a
no-network app. Every one of those packages costs cold-start time and permissions for nothing.

### 7.6 The page's stated takeaways, quoted

> "- When reading data, you can use a `Stream` to combine locally stored data with remote data.
> - When writing data, decide if you need to be online or offline, and if you need synchronizing data
>   later or not.
> - When implementing a background sync task, take into account the device status and your
>   application needs, as different applications may have different requirements."

### 7.7 Verdict for a no-network app

**The offline-first design-pattern page is the wrong page for you.** Your reference pages are:
1. `design-patterns/sql` — how a Repository + DatabaseService pair works (§8),
2. `design-patterns/key-value-data` — for preferences (§9),
3. `case-study/data-layer` §"Development versus staging environments" — the abstract-repository +
   `*Local` implementation pattern (§4.5),
which together give you: `ReferenceRepository` (read-only, backed by asset DB service) and
`MeasurementRepository` (read/write, backed by user DB service), both returning domain models, both
returning `Result`, neither aware of the other.

Two repositories over two different databases is a clean fit for the guidance because the rule is
"one repository per *type of data*", not "one per database". If a screen needs to join reference data
with user data, the guidance is explicit: **do it in a use-case in the domain layer, not by having one
repository call the other.**

---

## 8. Persistent storage architecture: SQL

Source: https://docs.flutter.dev/app-architecture/design-patterns/sql
Runnable example: https://github.com/flutter/website/tree/main/examples/app-architecture/todo_data_service
(updated 2026-05-18 for Dart 3.12, flutter/website PR #13397)

### 8.1 The layer split it prescribes

> "- UI layer with `TodoListScreen` and `TodoListViewModel`
> - Domain layer with `Todo` data class
> - Data layer with `TodoRepository` and `DatabaseService`"

### 8.2 drift is explicitly sanctioned

> "Internally, the `TodoRepository` uses the `DatabaseService`, which implements the access to the SQL
> database using the `sqflite` package. **You can implement the same `DatabaseService` using other
> storage packages like `sqlite3`, `drift` or even cloud storage solutions like `firebase_database`.**"

This is the official statement that swapping sqflite for **drift** does not violate the architecture.
drift on pub.dev: **2.34.2, published 2026-07-14** — actively maintained, repo `simolus3/drift`.

### 8.3 The Repository (verbatim) — note who opens the database

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

  Future<Result<Todo>> createTodo(String task) async {
    if (!_database.isOpen()) {
      await _database.open();
    }
    return _database.insert(task);
  }

  Future<Result<void>> deleteTodo(int id) async {
    if (!_database.isOpen()) {
      await _database.open();
    }
    return _database.delete(id);
  }
}
```

> "The `TodoRepository` acts as the source of truth for all the ToDo items. View models must use this
> repository to access to the ToDo list, and it should not expose any implementation details on how
> they are stored."

**Lazy-open is directly relevant to your 1.2 s cold-start budget** — the DB is not opened in `main()`,
it is opened on first use. With drift you get this for free (`LazyDatabase`), and you should use it:
open the read-only reference DB lazily on first query, not during `runApp`.

### 8.4 Every DB method returns Result

```dart
Future<Result<Todo>> insert(String task) async {
  try {
    final id = await _database!.insert(_todoTableName, {
      _taskColumnName: task,
    });
    return Result.ok(Todo(id: id, task: task));
  } on Exception catch (e) {
    return Result.error(e);
  }
}
```

> "All the `DatabaseService` operations use the `Result` class to return a value, as recommended by
> the [Flutter architecture recommendations]. This facilitates handling errors in further steps in the
> application code."

Also: define table/column names as constants —
> "It's a good idea to define the table and column names as constants to avoid typos when writing SQL
> code."
```dart
static const String _todoTableName = 'todo';
static const String _idColumnName = '_id';
static const String _taskColumnName = 'task';
```
(With drift this is moot — the generated API is the constant.)

### 8.5 ID generation belongs to the DB, not the ViewModel

> "ToDo items contain a unique identifier generated by the database. This is why the view model
> doesn't create the ToDo item, but rather the `TodoRepository` does."

Good rule. Your `MeasurementRepository.create(...)` should return the created domain object with the
DB-assigned id, not take a pre-built object with a client-side id.

### 8.6 On closing the database

> "In some cases, you might want to close the database when you are done with it. For example, when
> the user leaves the screen, or after a certain time has passed. This depends on the database
> implementation as well as your application requirements. **It's recommended that you check with the
> database package authors for recommendations.**"

i.e. the docs punt. For drift, follow drift's own docs, not this page.

### 8.7 Wiring in `main()` (verbatim)

```dart
void main() {
  late DatabaseService databaseService;
  if (kIsWeb) {
    throw UnsupportedError('Platform not supported');
  } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseService = DatabaseService(databaseFactory: databaseFactoryFfi);
  } else {
    databaseService = DatabaseService(databaseFactory: databaseFactory);
  }

  runApp(
    MainApp(
      todoRepository: TodoRepository(database: databaseService),
    ),
  );
}
```

Note this example uses **plain constructor injection with no DI container at all** — the repository is
a constructor argument to the app widget. Which is a reminder that `package:provider` is a
convenience, not a requirement.

---

## 9. Persistent storage architecture: Key-value data

Source: https://docs.flutter.dev/app-architecture/design-patterns/key-value-data

Same four-part shape: `ThemeSwitch` (View) → `ThemeSwitchViewModel` → `ThemeRepository` →
`SharedPreferencesService`. Two things worth stealing:

**(1) The Service exists purely to hide the third-party package.**
```dart
class SharedPreferencesService {
  static const String _kDarkMode = 'darkMode';

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, value);
  }

  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDarkMode) ?? false;
  }
}
```
> "…hiding this third-party dependency from the rest of the application"

**(2) A Repository can expose a broadcast Stream for app-wide state** — the mechanism the May-2026
"app-wide session state" section refers to:
```dart
class ThemeRepository {
  ThemeRepository(this._service);

  final _darkModeController = StreamController<bool>.broadcast();
  final SharedPreferencesService _service;

  Future<Result<void>> setDarkMode(bool value) async {
    try {
      await _service.setDarkMode(value);
      _darkModeController.add(value);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  /// Stream that emits theme config changes.
  /// ViewModels should call [isDarkMode] to get the current theme setting.
  Stream<bool> observeDarkMode() => _darkModeController.stream;
}
```

**Direct application:** your **locale** and **unit system** selections are exactly this — persisted
key-value settings that must be observable app-wide so `MaterialApp` rebuilds. The official shape is
a `SettingsRepository` exposing an observable stream, consumed by a `MainAppViewModel` that drives
`MaterialApp.locale`. In Riverpod this is one `NotifierProvider<SettingsNotifier, Settings>` watched
by the root widget. Same architecture, less plumbing.

Note the `MainAppViewModel` in the example **does** cancel its subscription in `dispose()` — copy
that discipline:
```dart
@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

Note also: the Compass app migrated off `SharedPreferences.getInstance()` to
**`SharedPreferencesAsync`** on 2026-06-19 (flutter/samples commit "Migrate compass_app to
SharedPreferencesAsync (#2841)"), but the design-pattern page still shows the legacy API. **The page
is stale relative to the reference app.** Use `SharedPreferencesAsync` (or
`SharedPreferencesWithCache` if you need synchronous reads at startup).

---

## 10. Optimistic state

Source: https://docs.flutter.dev/app-architecture/design-patterns/optimistic-state

Structure: `SubscribeButton` (StatefulWidget) + `SubscribeButtonViewModel` (ChangeNotifier) +
`SubscriptionRepository`. Update the ViewModel state immediately, call the repository, revert on
failure and surface a SnackBar via a ViewModel listener that resets the error flag:

```dart
void _onViewModelChange() {
  if (widget.viewModel.error) {
    widget.viewModel.error = false;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Failed to subscribe')));
  }
}
```

> "It's important to call `removeListener()` when the widget is disposed of, in order to avoid errors."

**Relevance to a fully offline app: low but non-zero.** Local SQLite writes are fast enough that
optimistic UI is usually unnecessary. It *does* apply to genuinely slow local operations — PDF
generation, a large drift transaction, camera capture. The advanced note is the useful bit:

> "you can use this technique to create a more advanced solution by incorporating a third temporal
> state that indicates that the action is still running."

i.e. three-state (`idle` / `pending` / `committed`) rather than optimistic-binary. That maps to
`AsyncValue` directly.

---

## 11. Dependency injection

Source: https://docs.flutter.dev/app-architecture/case-study/dependency-injection

### 11.1 What the docs actually say

> "In every case, communication between two layers is facilitated by passing a component into the
> constructor methods (of the components that consume its data), such as a `Service` into a
> `Repository`."

```dart
class MyRepository {
  MyRepository({required MyService myService})
          : _myService = myService;

  late final MyService _myService;
}
```

> "In the Compass app, *dependency injection* is handled using [`package:provider`]. **Based on their
> experience building Flutter apps, teams at Google recommend using `package:provider` to implement
> dependency injection.**"

And the recommendation entry, **Strongly recommend**:

> "Use dependency injection. — Dependency injection prevents your app from having globally accessible
> objects, which makes your code less error prone. We recommend you use the
> [provider](https://pub.dev/packages/provider) package to handle dependency injection."
> — architectureRecommendations.yml

The official wiring (real file `compass_app/app/lib/config/dependencies.dart`, abridged in the docs):

```dart
runApp(
  MultiProvider(
    providers: [
      Provider(create: (context) => AuthApiClient()),
      Provider(create: (context) => ApiClient()),
      Provider(create: (context) => SharedPreferencesService()),
      ChangeNotifierProvider(
        create: (context) => AuthRepositoryRemote(
          authApiClient: context.read(),
          apiClient: context.read(),
          sharedPreferencesService: context.read(),
        ) as AuthRepository,
      ),
      // ...
    ],
    child: const MainApp(),
  ),
);
```

ViewModels are constructed **in the router**, not in providers:

```dart
GoRoute(
  path: Routes.home,
  builder: (context, state) {
    final viewModel = HomeViewModel(
      bookingRepository: context.read(),
    );
    return HomeScreen(viewModel: viewModel);
  },
),
```

> "Services are exposed only so they can immediately be injected into repositories via the
> `BuildContext.read` method from `provider`… Repositories are then exposed so that they can be
> injected into view models as needed."

The real `dependencies.dart` goes one step further than the docs show: it exports **two provider
lists**, `providersRemote` and `providersLocal`, selected by the entry point (`main_development.dart`
vs `main_staging.dart`). That is the concrete payoff of the "use abstract repository classes"
recommendation.

### 11.2 Maintenance reality check on `package:provider`

Verified 2026-07-27 via `pub.dev/api/packages/provider` and `gh api repos/rrousselGit/provider`:

| | provider | flutter_riverpod | get_it |
|---|---|---|---|
| Latest version | **6.1.5+1** | **3.4.1** | **9.2.1** |
| Published | **2025-08-19** (~11 months ago) | **2026-07-26** (yesterday) | 2026-02-20 |
| Repo last push | 2026-03-10 (docs-only commit) | 2026-07-26 | — |
| Archived? | No | No | No |
| Same author | Rémi Rousselet | Rémi Rousselet | Thomas Burkhart |

**Assessment:** `provider` is **not abandoned** — the repo is alive and it is a stable, feature-complete
package that genuinely needs few releases. But its author's active work is unambiguously on Riverpod
(3.4.1 shipped the day before this research), and `provider` has had **no functional release in ~15
months**. Calling it "the recommended DI solution" in 2026 is the weakest part of the official
guidance. The docs themselves hedge in the UI-layer note:

> "`ChangeNotifier` and `ListenableBuilder` … are part of the Flutter SDK, and provide a good
> solution for updating the UI when state changes. **You can also use a robust third-party state
> management solution, such as `package:riverpod`, `package:flutter_bloc`, or `package:signals`.**"
> — https://docs.flutter.dev/app-architecture/case-study/ui-layer

and in the case-study conclusion:

> "The UI of this app leans heavily on view models and `ChangeNotifier`, but it could've easily been
> written with streams, or with other libraries such as `riverpod`, `flutter_bloc`, and `signals`."
> — https://docs.flutter.dev/app-architecture/case-study

### 11.3 Mapping the official DI rules onto Riverpod (recommendation)

Riverpod is *both* the DI container and the state layer. The layer rules survive intact; the
mechanism changes. Rules to keep:

| Official rule | Riverpod equivalent | Enforcement |
|---|---|---|
| Services injected into Repositories via ctor | `Provider<Repo>((ref) => Repo(service: ref.watch(serviceProvider)))` | keep the ctor param; do **not** call `ref` inside the Repository |
| Repositories injected into ViewModels via ctor | Notifier reads `ref.watch(repoProvider)` in `build` | acceptable; the Notifier *is* the ViewModel |
| Injected dependency must be **private** | make the Repository field private in the Notifier | a `ref` held by a widget can reach any provider — this is the one rule Riverpod actively weakens |
| Views know exactly one ViewModel | a `ConsumerWidget` should `ref.watch` **one** viewmodel provider | lint this in review; it is the easiest rule to violate accidentally |
| Repositories never know each other | never `ref.watch(otherRepoProvider)` inside a repository provider's body beyond ctor wiring | put cross-repo logic in a use-case provider |
| Services hold no state | `Provider`, not `NotifierProvider` | — |

**The single biggest risk of Riverpod-plus-official-architecture is rule 4:** because any widget with
a `WidgetRef` can `ref.watch(anyRepositoryProvider)`, the "UI layer shouldn't know that the data layer
exists" rule is unenforced by the compiler. Mitigate by convention: repository providers live in
`data/` and are only ever read from `domain/` or viewmodel providers; add a custom lint or a
`// ignore_for_file` convention if you care enough.

**`get_it`:** never mentioned in the architecture docs. It is a service locator, which the
recommendation ("prevents your app from having globally accessible objects") argues *against* — but
note the May-2026 app-wide-state section explicitly says "typically managed through a **service
locator** or dependency injection container", so the docs are no longer uniformly hostile to it.
`get_it` 9.2.1 (2026-02-20) is actively maintained under the `flutter-it` org. **Recommendation: do
not add `get_it` alongside Riverpod.** Two DI mechanisms in one app is strictly worse than either.

---

## 12. Optional domain layer / use-cases

Source: https://docs.flutter.dev/app-architecture/guide

> "As your app grows and adds features, you might need to abstract away logic that adds too much
> complexity to your view models. These classes are often called interactors or **use-cases**."

> "Use-cases are primarily used to encapsulate business logic that would otherwise live in the view
> model and meets one or more of the following conditions:
> 1. Requires merging data from multiple repositories
> 2. Is exceedingly complex
> 3. The logic will be reused by different view models"

The pros/cons table, verbatim:

| Pros | Cons |
|---|---|
| ✅ Avoid code duplication in view models | ❌ Increases complexity of your architecture, adding more classes and higher cognitive load |
| ✅ Improve testability by separating complex business logic from UI logic | ❌ Testing requires additional mocks |
| ✅ Improve code readability in view models | ❌ Adds additional boilerplate to your code |

Rules if you adopt it:

> "* Use-cases depend on repositories
> * Use-cases and repositories have a many-to-many relationship
> * View models depend on one or more use-cases *and* one or more repositories"

> "A good approach is to add use-cases only when needed. … The example app used later in this guide
> has use-cases for some features, but also has view models that interact with repositories directly."

> "This method of using use-cases ends up looking less like a layered lasagna, and more like a plated
> dinner with two mains (UI and data layers) and a side (domain layer)."

Recommendation confidence: **Conditional** — "A domain layer is only needed if your application has
exceeding complex logic that crowds your ViewModels, or if you find yourself repeating logic in
ViewModels. In very large apps, use-cases are useful, but in most apps they add unnecessary overhead."

**Verdict for your app: adopt it — you already have.** A rule engine shared between the app and a
CLI content tool is condition 2 (exceedingly complex) and condition 3 (reused) simultaneously, and
joining reference-DB data with user-DB data is condition 1. The official position that repositories
must never know each other makes the domain layer *mandatory* for you, not optional.

**Concrete real use-case** (`compass_app/app/lib/domain/use_cases/booking/booking_create_use_case.dart`)
— note it depends on three repositories, returns `Result`, and logs:

```dart
class BookingCreateUseCase {
  BookingCreateUseCase({
    required DestinationRepository destinationRepository,
    required ActivityRepository activityRepository,
    required BookingRepository bookingRepository,
  }) : _destinationRepository = destinationRepository,
       _activityRepository = activityRepository,
       _bookingRepository = bookingRepository;

  final DestinationRepository _destinationRepository;
  // ...
  final _log = Logger('BookingCreateUseCase');

  Future<Result<Booking>> createFrom(ItineraryConfig itineraryConfig) async {
    if (itineraryConfig.destination == null) {
      _log.warning('Destination is not set');
      return Result.error(Exception('Destination is not set'));
    }
    // ... switch on each repository Result, early-return on Error
  }
}
```

**One caveat the docs do not address:** these use-cases live in `lib/domain/` inside the Flutter app
and freely import `package:logging` and the repository interfaces. Your rule engine is a *separate
pure-Dart package with no Flutter imports*. That is a **stricter** and better structure than the
reference app, and it is compatible with the guidance — but be aware the official use-case examples
are not Flutter-free, so don't expect the docs to help you with the package boundary. Use
`dart:` + `package:meta` only, and keep `Result` (or your own sealed union) defined in the pure
package so both the app and the CLI can use it.

---

## 13. Package structure

Source: https://docs.flutter.dev/app-architecture/case-study#package-structure

> "There are two popular means of organizing code:
> 1. By feature … 2. By type …
> The architecture recommended in this guide lends itself to a combination of the two. Data layer
> objects (repositories and services) aren't tied to a single feature, while UI layer objects (views
> and view models) are."

The prescribed tree, verbatim:

```
lib/
  ui/
    core/
      ui/
        <shared_widgets>
      themes/
    <feature_name>/
      view_models/
        <view_model_class>.dart
      widgets/
        <feature_name>_screen.dart
        <other_widgets>
  domain/
    models/
      <model_name>.dart
  data/
    repositories/
      <repository_class>.dart
    services/
      <service_class>.dart
    model/
      <api_model_class>.dart
  config/
  utils/
  routing/
  main_staging.dart
  main_development.dart
  main.dart
test/            // Contains unit and widget tests.
  data/
  domain/
  ui/
  utils/
testing/         // Contains mocks that other classes need to execute tests.
  fakes/
  models/
```

> "The data folder organizes code by type, because repositories and services can be used across
> different features and by multiple view models. The ui folder organizes the code by feature, because
> each feature has exactly one view and exactly one view model."

> "`testing/` is a subpackage that contains mocks and other testing utilities which can be used in
> other packages' test code. **The `testing/` folder could be described as a version of your app that
> you don't ship. It's the content that is tested.**"

**Naming convention — Recommend:**
> "We recommend naming classes for the architectural component they represent. For example, you may
> have the following classes: `HomeViewModel`, `HomeScreen`, `UserRepository`, `ClientApiService`.
> For clarity, we do not recommend using names that can be confused with objects from the Flutter SDK.
> For example, you should put your shared widgets in a directory called `ui/core/`, rather than a
> directory called `/widgets`."
> — architectureRecommendations.yml

### 13.1 Multi-package repos: use Dart pub workspaces

The docs' folder tree is single-package, but the reference repo is not. `flutter/samples` root
`pubspec.yaml` declares:

```yaml
name: samples
environment:
  sdk: ^3.9.0-0
workspace:
  - analysis_defaults
  - compass_app/app
  - compass_app/server
  # ...
```

and `compass_app/app/pubspec.yaml` declares `resolution: workspace`. Verified via
`gh api repos/flutter/samples/contents/pubspec.yaml`. Docs: https://dart.dev/tools/pub/workspaces

**This is the officially-supported monorepo mechanism** (Dart ≥ 3.6) and is exactly what you want for
`app/` + `packages/rule_engine/` (pure Dart) + `tools/content_builder/` (CLI). One shared lockfile,
one `.dart_tool`, one `dart pub get`. **Do not reach for melos** for a three-package repo — pub
workspaces are built in and have zero maintenance surface.

Note `analysis_defaults` in that workspace list: flutter/samples factors shared lints into a package
that every sample depends on as a dev dependency. Do the same so the app, the pure package, and the
CLI share one `analysis_options.yaml`. `flutter_lints` is at **6.0.0 (2025-05-27)**, maintained in
`flutter/packages`.

---

## 14. Testing guidance

Source: https://docs.flutter.dev/app-architecture/case-study/testing

> "**To test the UI logic of the view model, you should write unit tests that don't rely on Flutter
> libraries or testing frameworks.**"

> "Repositories are a view model's only dependencies (unless you're implementing use-cases), and
> writing `mocks` or `fakes` of the repository is the only setup you need to do."

> "The most important thing to take away is that view and view model tests only require mocking
> repositories if your architecture is sound."

> "To write unit tests for any given repository, mock the services that it depends on."

Recommendations (both **Strongly recommend**):
> "Test architectural components separately, and together. — Write unit tests for every service,
> repository and ViewModel class. These tests should test the logic of every method individually.
> Write widget tests for views. Testing routing and dependency injection are particularly important."

> "Make fakes for testing (and write code that takes advantage of fakes.) — Fakes aren't concerned
> with the inner workings of any given method as much as they're concerned with inputs and outputs.
> If you have this in mind while writing application code, you're forced to write modular, lightweight
> functions and classes with well defined inputs and outputs."

Fakes, not mocks, for repositories — real example:
```dart
class FakeBookingRepository implements BookingRepository {
  List<Booking> bookings = List.empty(growable: true);

  @override
  Future<Result<void>> createBooking(Booking booking) async {
    bookings.add(booking);
    return Result.ok(null);
  }
  // ...
}
```

A shared widget-test harness — note it fixes `devicePixelRatio` and surface size, which is exactly
what you need for stable goldens:
```dart
void testApp(
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

**For your golden tests across six locales:** extend `testApp` with a `Locale` parameter and a
`Directionality`-aware wrapper; the architecture pays off because a View with no logic renders
identically given identical ViewModel state, so you only vary locale/text-direction, not behaviour.
`mocktail` is the mocking package used by the reference app.

---

## 15. Anti-patterns — what the docs explicitly say NOT to do

Direct prohibitions, each with its source:

1. **"Do not put logic in widgets."** — the only allowed View logic is the four-item list in §2.
   (architectureRecommendations.yml, `confidence: strong`)
2. **The UI layer must not know the data layer exists.** "The UI layer shouldn't know that the data
   layer exists, and vice versa." (concepts) → no `context.read<SomeRepository>()` inside a View.
3. **Repositories must never be aware of each other.** "If your application has business logic that
   needs data from two repositories, you should combine the data in the view model or in the domain
   layer." (guide)
4. **Services must not be reachable from the UI.** "It's important that the service is a private
   member, so that the UI layer can't bypass the repository and call a service directly."
   (case-study/data-layer)
5. **ViewModels must not expose repositories.** "Private methods prevent the view, which has access to
   the view model, from calling methods on the repository directly."
   (case-study/dependency-injection)
6. **Do not expose mutable state from a ViewModel.** Use `UnmodifiableListView` /
   immutable models. "Data should be immutable and persistent, and views should contain as little
   logic as possible." (concepts); "Use immutable data models" is `confidence: strong`.
7. **Data must not be mutated outside the SSOT.** "If the data can be modified in the app, the SSOT
   class should be the only class that can do so." (concepts) — and "The most important idea is that
   data changes always happen in the SSOT, which is the data layer."
8. **Do not name a directory `/widgets`.** "you should put your shared widgets in a directory called
   `ui/core/`, rather than a directory called `/widgets`" — because it collides mentally with the
   Flutter SDK. (architectureRecommendations.yml)
9. **Do not let a one-shot UI effect fire repeatedly.** "You need to clear the error state each time
   you execute this action, otherwise this action happens each time `notifyListeners()` is called."
   (design-patterns/command)
10. **Do not create a use-case for everything.** "Your application code will be extremely modular and
    testable, but it also adds a significant amount of unnecessary overhead. A good approach is to
    add use-cases only when needed." (guide)
11. **Do not let exceptions cross layers undocumented.** The whole Result page exists because
    "developers might forget to catch exceptions, and the different application layers and components
    could throw exceptions that aren't documented."

Additional anti-patterns I am asserting (not from the docs — flagged as such), justified above:

12. **Do not use `asOk` in production code.** It is a test-only extension in the real Compass app
    (§6.5) and is an unchecked cast.
13. **Do not build `Command` on top of Riverpod.** `AsyncValue`/`AsyncNotifier` already provide it
    (§5.5). Duplicated state machines drift.
14. **Do not nest `AsyncValue<Result<T>>`.** Unwrap at the notifier boundary (§6.6).
15. **Do not add `connectivity_plus`, `workmanager`, `battery_plus`, or a `synchronized` column** to a
    no-network app just because the offline-first page mentions them (§7.5).
16. **Do not `await` a `StreamSubscription.asFuture()` in a ViewModel** as the offline-first page
    shows — it leaks if the ViewModel is disposed first (§7.3).
17. **Do not run two DI mechanisms.** Riverpod *or* provider *or* get_it — not two (§11.3).
18. **Do not open databases in `main()`.** The official SQL pattern lazily opens on first repository
    call; with a 1.2 s cold-start budget this is load-bearing (§8.3).

---

## 16. Where the official docs contradict themselves (and what I recommend)

These are real, verifiable inconsistencies. Knowing them prevents pointless team arguments.

**(a) Where does "most" of the business logic live?**
- guide.md, UI layer §: "In the architecture design described on this page, **most of the logic in
  your Flutter application lives in view models.**"
- architectureRecommendations.yml, separation-of-concerns #1: "The data layer exposes application data
  to the rest of the app, and **contains most of the business logic in your application.**"

Flat contradiction. **My reading and recommendation:** the guide means *UI* logic (formatting,
filtering-for-display, flags), the recommendation means *domain* logic (rules, validation, invariants).
Resolve it by naming: **UI logic → ViewModel; business rules → domain package / repository.** For your
app the rule engine is unambiguously business logic and belongs in the pure-Dart package, with the
ViewModel doing nothing but adapting its output to widget-shaped state.

**(b) Does the Command pattern catch exceptions?** The simplified `Command` does; the full
`Command`/`Command0`/`Command1` does not (§5.3).

**(c) Does the offline-first page follow the Result recommendation?** No — its repository methods
`throw` and use bare `catch (e) { // Handle the error }`. The SQL page and the Compass app do use
`Result`. **Follow the SQL page and the Compass app.**

**(d) `asOk` in a docs snippet vs. test-only in the real app** (§6.5).

**(e) `SharedPreferences.getInstance()` in the key-value page vs. `SharedPreferencesAsync` in the
Compass app since 2026-06-19** (§9). Follow the app.

**(f) `provider` is "strongly recommended" while `state-mgmt/options` has stopped recommending any
package at all** (§0, §11.2). The architecture docs are opinionated; the state-management docs have
gone neutral. **Follow the *structure* from the architecture docs; choose the *library* yourself.**

**(g) One dead internal link:** architectureRecommendations.yml links to `/get-started/fwe/state-management`;
no such file exists in `sites/docs/src/content/get-started/` on main (verified by tree listing). The
live equivalent content is under `/learn/pathway/tutorial/change-notifier`. Cosmetic, but a reminder
that the recommendations data file is less maintained than the prose.

---

## 17. Concrete architecture for THIS app, expressed in official terms

```
packages/rule_engine/          ← pure Dart, no flutter imports. Contains: domain models,
                                 sealed Result (or Failure), the rule evaluator.
                                 Depended on by BOTH app/ and tools/content_builder/.
tools/content_builder/         ← Dart CLI. Reads authoring input, emits the pre-seeded
                                 reference .sqlite asset. Depends on rule_engine + drift.
app/
  lib/
    ui/
      core/ui/                 ← shared widgets (RulerPainter, LocalizedText, …)
      core/themes/
      <feature>/
        view_models/
        widgets/
    domain/
      models/                  ← re-export or thin adapters over rule_engine models
      use_cases/               ← anything joining reference data + user data
    data/
      repositories/
        reference_repository.dart        (abstract) + _drift.dart (impl)
        measurement_repository.dart      (abstract) + _drift.dart (impl)
        settings_repository.dart         (abstract) + _prefs.dart (impl)
      services/
        reference_database_service.dart  (drift, read-only asset DB, lazy-open)
        user_database_service.dart       (drift, writable DB, lazy-open)
        camera_service.dart
        location_service.dart
        pdf_export_service.dart
        asset_bundle_service.dart        (SVG / ARB-adjacent assets)
      model/                   ← drift row → domain mapping lives here
    config/
    routing/
    l10n/
  test/   { data, domain, ui, utils }
  testing/ { fakes, models }   ← shipped-nowhere fake repositories, shared with goldens
```

Root `pubspec.yaml` with a `workspace:` list covering all three packages
(https://dart.dev/tools/pub/workspaces).

Rules to enforce in review, all traceable to a quote above:
1. No widget imports anything from `data/`.
2. No ViewModel/Notifier imports anything from `data/services/`.
3. `ReferenceRepository` and `MeasurementRepository` never reference each other — joins go in
   `domain/use_cases/`.
4. Every repository has an `abstract` interface; every one has a fake in `testing/fakes/`.
5. Every public repository method returns `Future<Result<T>>` or `Stream<T>`.
6. Domain models are immutable; drift row classes never escape `data/`.
7. Databases open lazily, never in `main()`.
8. `rule_engine` has zero `package:flutter` imports — enforce with a CI check
   (`grep -r "package:flutter" packages/rule_engine/lib && exit 1`).

---

## 18. Package status audit (verified 2026-07-27 via pub.dev API + GitHub)

| Package | Latest | Published | Status | Note |
|---|---|---|---|---|
| `provider` | 6.1.5+1 | 2025-08-19 | Stable, low activity | Repo not archived; last code release ~11 months ago. Officially "strongly recommended" for DI. |
| `flutter_riverpod` | 3.4.1 | 2026-07-26 | Very active | Requires Dart `^3.12.0` — compatible with Flutter 3.44.6 (Dart 3.12.2). |
| `riverpod` (pure Dart) | 3.4.1 | 2026-07-26 | Very active | Usable from a pure-Dart package if ever needed — but keep the rule engine dependency-free. |
| `get_it` | 9.2.1 | 2026-02-20 | Active (`flutter-it` org) | Never mentioned in architecture docs. |
| `command_it` | 9.5.1 | 2026-02-20 | Active | Recommended *by name* in the command design-pattern page. |
| `watch_it` | 2.4.2 | 2026-02-20 | Active | Not mentioned in the docs; same org as get_it/command_it. |
| `freezed` | 3.2.5 | 2026-02-03 | Active | "Recommend" in the recommendations. Docs warn: "can add significant build time … if you have a lot of models." |
| `result_dart` | 2.2.0 | 2026-03-07 | Active | Named in the Result page. Vendoring the 30-line class is still better. |
| `go_router` | 17.3.0 | 2026-06-02 | Active (flutter/packages) | "Recommend": "go_router is the preferred way to write 90% of Flutter applications." Requires Flutter ≥ 3.38. |
| `drift` | 2.34.2 | 2026-07-14 | Active | Explicitly named as an acceptable `DatabaseService` implementation. |
| `flutter_lints` | 6.0.0 | 2025-05-27 | Active (flutter/packages) | Recommended in the resources list. |
| `very_good_cli` | 1.3.0 | 2026-06-29 | Active (Very Good Ventures) | Listed in official "Recommended resources". Commercial vendor's OSS tool — fine, but it is a third party's opinion, not Flutter's. |

**Nothing in the officially-recommended set is abandoned.** The only maintenance concern is
`provider`'s release cadence.

---

## 19. Official "Recommended resources" list, verbatim

From https://docs.flutter.dev/app-architecture/recommendations :

> * Code and templates
>   * [Compass app source code] — Source code of a full-featured, robust Flutter application that
>     implements many of these recommendations. → https://github.com/flutter/samples/tree/main/compass_app
>   * [very_good_cli] — A Flutter application template made by the Flutter experts Very Good Ventures.
>     → https://cli.vgv.dev/
> * Documentation
>   * [Very Good Engineering architecture documentation] →
>     https://engineering.verygood.ventures/architecture/architecture/
> * Tooling
>   * [Flutter developer tools] → https://docs.flutter.dev/tools/devtools
>   * [flutter_lints] → https://pub.dev/packages/flutter_lints

Caveat worth recording: the two VGV links are the *only* non-Flutter-team sources the official docs
endorse. VGV's own architecture docs prescribe **BLoC**, not MVVM — so following that link leads to
advice that conflicts with the page linking to it. Noted, not resolved by the docs.

---

## 20. `resources/architectural-overview` — what it is and is not

Source: https://docs.flutter.dev/resources/architectural-overview

This page is about **Flutter the framework's internals**, not about how to structure your app. Its
sections: Architectural layers, Anatomy of an app, Reactive user interfaces, Widgets, Composition,
Building widgets, Widget state, State management, Rendering and layout, Build: from Widget to Element,
Layout and rendering, Platform embedding, Platform channels, FFI, Rendering native controls, Hosting
Flutter content, Flutter web support.

Its only app-architecture-adjacent content is the `InheritedWidget` explanation and this paragraph:

> "As applications grow, more advanced state management approaches that reduce the ceremony of
> creating and using stateful widgets become more attractive. Many Flutter apps use utility packages
> like [provider], which provides a wrapper around `InheritedWidget`. Flutter's layered architecture
> also enables alternative approaches to implement the transformation of state into UI, such as the
> [flutter_hooks] package."

**Do not confuse this page with `/app-architecture`.** It answers "how does Flutter work", not "how
should I structure my app". It is however the correct reference for the parts of your app that touch
the framework directly — custom painting (the ruler), the build/layout/paint pipeline, and FFI
(relevant if you use drift's native SQLite via `sqlite3_flutter_libs`).

---

## 21. Quick-reference: the recommendations with their official priority

From https://github.com/flutter/website/blob/main/sites/docs/src/data/architectureRecommendations.yml
(rendering confirmed live at https://docs.flutter.dev/app-architecture/recommendations)

Priority definitions, quoted:
> "**Strongly recommend:** You should always implement this recommendation if you're starting to build
> a new application. You should strongly consider refactoring an existing app to implement this
> practice unless doing so would fundamentally clash with your current approach.
> **Recommend**: This practice will likely improve your app.
> **Conditional**: This practice can improve your app in certain circumstances."

**Separation of concerns**
| Recommendation | Priority |
|---|---|
| Use clearly defined data and UI layers. | Strongly recommend |
| Use the repository pattern in the data layer. | Strongly recommend |
| Use ViewModels and Views in the UI layer. (MVVM) | Strongly recommend |
| Use `ChangeNotifiers` and `Listenables` to handle widget updates. | **Conditional** |
| Do not put logic in widgets. | Strongly recommend |
| Use a domain layer. | Conditional |

**Handling data**
| Recommendation | Priority |
|---|---|
| Use unidirectional data flow. | Strongly recommend |
| Use `Commands` to handle events from user interaction. | Recommend |
| Use immutable data models. | Strongly recommend |
| Use freezed or built_value to generate immutable data models. | Recommend |
| Create separate API models and domain models. | Conditional |

**App structure**
| Recommendation | Priority |
|---|---|
| Use dependency injection. | Strongly recommend |
| Use go_router for navigation. | Recommend |
| Use standardized naming conventions for classes, files and directories. | Recommend |
| Use abstract repository classes. | Strongly recommend |

**Testing**
| Recommendation | Priority |
|---|---|
| Test architectural components separately, and together. | Strongly recommend |
| Make fakes for testing (and write code that takes advantage of fakes.) | Strongly recommend |

**The single most important entry for a Riverpod app:** "Use `ChangeNotifiers` and `Listenables`" is
only **Conditional**, with the note "There are many options to handle state-management, and ultimately
the decision comes down to personal preference." Every *other* separation-of-concerns item is
**Strongly recommend**. **The layering is prescribed; the state-management library is not.** That
sentence is the licence to use Riverpod without deviating from official guidance.

---

## 22. Verification notes / what I could not verify

- Every URL in this document was either fetched successfully (HTTP 200) or read through
  `gh api` / `raw.githubusercontent.com` during this session.
- All Dart code blocks are copied byte-for-byte from `flutter/website` `examples/app-architecture/`,
  from the docs' own markdown source, or from `flutter/samples/compass_app`. Where a snippet is
  abridged in the docs (`// ···`), I have said so or substituted the real file.
- The docs contain **no** dedicated "dependency injection" page under `design-patterns/`. The six
  design-pattern pages are exactly: optimistic-state, key-value-data, sql, offline-first, command,
  result (confirmed by the repo tree *and* by fetching the live index page). DI is covered only under
  `case-study/dependency-injection`.
- **No official Flutter guidance exists for**: shipping a pre-seeded read-only SQLite database as an
  asset; two-database architectures; cold-start budgets; RTL-aware architecture; or architecture for
  a Flutter app + pure-Dart CLI sharing a domain package. Statements about those in this document are
  my extrapolation and are labelled as such. **No evidence found** for any official position on them.
- I did not verify VGV's engineering docs content beyond noting they exist and are officially linked.
