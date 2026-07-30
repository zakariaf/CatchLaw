# State Management for Flutter in 2026 — A Decision, Not a Survey

**Research date:** 2026-07-27
**Target toolchain (verified locally):** Flutter 3.44.6 stable (2026-07-08) · Dart SDK 3.12.2 stable (2026-06-09)
**Target app:** 100% offline Android + iOS, two drift/SQLite databases, six locales incl. Arabic RTL, pure-Dart domain package, cold start < 1.2 s on low-end Android.

Every version number and every quote in this document was pulled from `pub.dev/api`, `raw.githubusercontent.com`, or `docs.flutter.dev` on 2026-07-27. Nothing here is from memory.

---

## 0. THE DECISION (read this if you read nothing else)

**Use `flutter_riverpod` 3.4.1 with `riverpod_generator` code generation. Do not use `flutter_bloc`. Do not use `signals`. Do not use `provider`.**

Concretely, for this app:

| Layer | What to use | Why |
|---|---|---|
| Database handles | `Provider<AppDatabase>` / `Provider<ReferenceDatabase>`, **not** autoDispose, injected via `ProviderScope(overrides:)` at the root | Single instance, closable, swappable in tests |
| Anything read from SQL | `@riverpod Stream<T> foo(Ref ref) => db.query().watch();` — a **StreamProvider** | drift already is the observable store. Do not mirror rows into a Notifier. |
| Writes | Plain methods on a repository class exposed by a plain `Provider`, called from the UI via `ref.read(repoProvider).doThing()` | The write returns `void`/`Future<void>`; the drift stream pushes the new state back. No state held anywhere. |
| UI-only state that is *not* in SQL (filters, selected unit, wizard step, ruler calibration) | `@riverpod class X extends _$X` — a **Notifier** | This is the only state you actually "manage" |
| Ephemeral state (TextEditingController, animations, "is this expanded") | `StatefulWidget` + `setState` | Riverpod's own docs say providers are the wrong tool here |
| Pure-Dart rule engine package | **No state-management dependency at all.** Plain classes + `sealed` results. | Keeps it Flutter-free and usable from your CLI content tool |
| DI | Riverpod providers + `overrides` | You get DI, caching, disposal and testing in one primitive |

**The single most important insight for this app:** with drift, roughly 80% of what other apps call "state management" disappears. SQLite *is* your store, drift's `watch()` *is* your change notification, and Riverpod is a thin, testable, disposable cache/DI layer on top. If you find yourself writing an `AsyncNotifier` that holds a `List<Row>` copied out of the database, you have made a mistake.

**Second most important:** Riverpod 3's automatic pausing of off-screen providers and drift's pause-aware `QueryStream` compose *perfectly* — navigating away from a screen actually stops running its SQL. This is verified in source below (§7.5) and is a real cold-start/battery win nobody blogs about.

---

## 1. Verified version matrix (pub.dev API, 2026-07-27)

```
flutter_riverpod      3.4.1        2026-07-26   sdk ^3.12.0
riverpod              3.4.1        2026-07-26
hooks_riverpod        3.4.1        2026-07-26
riverpod_annotation   4.0.5        2026-07-26   -> depends on riverpod 3.4.1 (pinned exact)
riverpod_generator    4.0.6        2026-07-26   -> depends on riverpod_annotation 4.0.5 (pinned exact)
riverpod_lint         3.1.6        2026-07-26   -> NO custom_lint dependency since 3.1.0
custom_lint           0.8.1        2025-09-09   (no longer needed by riverpod_lint)

flutter_bloc          9.1.1        2025-05-02   <- 14 months since last publish
bloc                  9.2.1        2026-05-12
bloc_test            10.0.0        2025-01-12
bloc_lint             0.4.2        2026-07-04
bloc_concurrency      0.3.0        2025-01-12

signals               7.1.0        2026-05-29
signals_flutter       7.1.0        2026-05-29

provider              6.1.5+1      2025-08-19   <- 11 months; repo alive but feature-frozen
state_notifier        1.0.0        2023-08-16   <- effectively dead, legacy only
flutter_hooks         0.21.3+1     2025-08-19

drift                 2.34.2       2026-07-14
drift_flutter         0.3.1        2026-07-11
build_runner          2.15.3       2026-07-27
```

> **Gotcha to put in your `pubspec.yaml`:** the Riverpod family does **not** share a major version. `riverpod_generator` is on **4.x** while `riverpod`/`flutter_riverpod` are on **3.x** and `riverpod_lint` is on **3.1.x**. `riverpod_annotation` pins `riverpod` to an **exact** version (`"riverpod": "3.4.1"`), so bumping one forces bumping all. Pin all four together and bump them as a set.
> Source: `curl -s https://pub.dev/api/packages/riverpod_annotation` → `latest.pubspec.dependencies`.

Recommended `pubspec.yaml` fragment:

```yaml
environment:
  sdk: ^3.12.0          # matches local Dart 3.12.2 and riverpod 3.4.1's floor

dependencies:
  flutter_riverpod: ^3.4.1
  riverpod_annotation: ^4.0.5
  drift: ^2.34.2
  drift_flutter: ^0.3.1

dev_dependencies:
  build_runner: ^2.15.3
  riverpod_generator: ^4.0.6
  drift_dev: ^2.34.0
  # riverpod_lint is NOT a dev_dependency any more — see §6.6
```

---

## 2. What Flutter's OFFICIAL guidance actually says

### 2.1 It deliberately does not prescribe a package

From <https://docs.flutter.dev/app-architecture/recommendations>, the state-management row is graded **Conditional** (not "Strongly recommend"):

> **Use `ChangeNotifiers` and `Listenables` to handle widget updates.** — *Conditional.* "The `ChangeNotifier` API is part of the Flutter SDK and provides a convenient way for widgets to observe ViewModel changes. Many options exist for state management; the decision comes down to personal preference."

And <https://docs.flutter.dev/data-and-backend/state-mgmt/options> lists only SDK primitives (`setState`, `ValueNotifier`/`InheritedNotifier`, `InheritedWidget`/`InheritedModel`) and then punts:

> "The best choice for your app often depends on the app's complexity, your team's preferences, and the specific problems you need to solve."

**It does not name Riverpod, Bloc, or signals at all.** Anyone telling you "Flutter officially recommends X" for state management is wrong. What Flutter *does* prescribe is **architecture**, and that architecture is package-agnostic.

### 2.2 What it DOES prescribe (and you should follow all of it)

Same page, `Strongly recommend` tier — these are non-negotiable and orthogonal to your package choice:

- **Clearly defined data and UI layers.** Data layer holds most business logic.
- **Repository pattern in the data layer**, with **abstract repository classes**.
- **MVVM: ViewModels and Views in the UI layer.**
- **Do not put logic in widgets.** Views may only contain "simple if-statements to show/hide widgets, animation logic, layout logic based on device info, and simple routing logic."
- **Unidirectional data flow.** Updates flow data → UI; interactions flow UI → data.
- **Immutable data models** (and `Recommend`: use `freezed` or `built_value`).
- **Dependency injection** — and here it *does* name a package: **`provider`**.
- **Test architectural components separately and together; make fakes.**

`Recommend` tier: **Commands** to handle user-interaction events; `go_router` for navigation.
`Conditional` tier: a domain layer with use-cases — "adds unnecessary overhead in most apps."

### 2.3 Yes, Flutter's own sample really does use ChangeNotifier + provider — verified

I read the actual source of `flutter/samples` `compass_app` (last touched 2026-06-19):

`compass_app/app/lib/ui/home/view_models/home_viewmodel.dart`:

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
  ...
  late Command0 load;
  late Command1<void, int> deleteBooking;
```
<https://github.com/flutter/samples/blob/main/compass_app/app/lib/ui/home/view_models/home_viewmodel.dart>

`compass_app/app/lib/config/dependencies.dart` uses `package:provider`'s `Provider`/`ChangeNotifierProvider` + `context.read()` for DI:

```dart
Provider(
  create: (context) =>
      BookingRepositoryRemote(apiClient: context.read()) as BookingRepository,
),
```
<https://github.com/flutter/samples/blob/main/compass_app/app/lib/config/dependencies.dart>

Its `pubspec.yaml` lists `provider: ^6.1.2` and **no** riverpod/bloc.

**My reading of this:** the Flutter team chose the lowest-common-denominator SDK primitive so the sample teaches *architecture*, not a package. It is not an endorsement of `ChangeNotifier` as the best tool. Notice the sample had to hand-roll a `Command`/`Result` abstraction (`utils/command.dart`, `utils/result.dart`) to get loading/error handling that Riverpod gives you for free via `AsyncValue` and `Mutation`. Take the *architecture* from compass_app and the *machinery* from Riverpod.

---

## 3. Rejecting the alternatives (with reasons, not vibes)

### 3.1 `provider` — REJECT

- Last publish **2025-08-19** (`6.1.5+1`); repo not archived, last commit 2026-03-10 was a docs-only change. Feature-frozen, not abandoned.
- Maintained by **rrousselGit**, the same author as Riverpod. Riverpod exists specifically because `provider`'s `InheritedWidget` foundation cannot do reliable auto-dispose, cannot take arguments, and cannot express `listen` semantics.
- Riverpod's FAQ explains the technical limits plainly (<https://riverpod.dev/docs/root/faq>):
  > "It is not possible to implement an 'on change' listener with `InheritedWidget`… Widgets listening to an `InheritedWidget` never stop listening to it… `InheritedWidget` has no way to track when widgets stop listening to them."
- Its only remaining edge is that Flutter's docs recommend it for DI. Riverpod does DI strictly better (typed, compile-checked, overridable per-test, no `BuildContext`).

**Verdict:** using `provider` in 2026 means shipping a strictly-less-capable version of a library the same author replaced. No.

### 3.2 `flutter_bloc` — REJECT for this app, but it is not bad

Bloc is a genuinely well-built, well-maintained library. `bloc` 9.2.1 (2026-05-12), `bloc_lint` 0.4.2 (2026-07-04). `flutter_bloc` 9.1.1 hasn't been published since 2025-05-02, which reflects API stability rather than abandonment — the core `bloc` package is still shipping features (`MultiBlocObserver` in 9.2.0, `onDone` in 9.1.0).

Its testing story is excellent and is arguably better than Riverpod's:

```dart
blocTest(
  'emits [1] when CounterIncrementPressed is added',
  build: () => counterBloc,
  act: (bloc) => bloc.add(CounterIncrementPressed()),
  expect: () => [1],
);
```
<https://github.com/felangel/bloc/blob/master/docs/src/components/testing/CounterBlocTestBlocTestSnippet.astro>

Bloc's architecture doc is also very good, and its "Connecting Blocs through Domain" section describes *exactly* the pattern this app should use — except the reactive source is drift instead of a hand-written repository stream:

> "Two blocs can listen to a stream from a repository and update their states independent of each other whenever the repository data changes. Using reactive repositories to keep state synchronized is common in large-scale enterprise applications."
> <https://bloclibrary.dev/architecture/> (source: `docs/src/content/docs/architecture.mdx` in `felangel/bloc`)

**When Bloc genuinely beats Riverpod:**
1. You need an **auditable event log** — every user interaction is a named, serializable event passing through `BlocObserver`. For regulated/analytics-heavy apps this is a real feature.
2. Large teams needing enforced uniformity — Bloc has exactly one way to do things; Riverpod has five.
3. Complex event *sequencing* — `bloc_concurrency` gives you `droppable()`, `restartable()`, `sequential()` transformers declaratively.

**Why it loses here:**
- **Ceremony tax.** For an offline app whose state is a SQL query, `sealed class Event` + `on<Event>` + `emit(state.copyWith(...))` is pure overhead. You would write ~40 lines of Bloc to replicate what `db.q().watch()` gives you in one.
- **No dependency injection.** Bloc needs `RepositoryProvider` — which is `package:provider` under the hood. You would end up with two systems.
- **No caching / auto-dispose / family.** Riverpod's `family` + `autoDispose` map naturally onto "one provider per reference-DB entity id."
- **Bloc's own rule "no bloc should know about any other bloc"** means cross-cutting derived state (e.g. "ruler calibration × selected locale × rule-engine verdict") must be recombined in the widget layer with `BlocListener`, which is exactly the "logic in widgets" that Flutter's architecture doc forbids. Riverpod's `ref.watch` composes providers in the data layer where it belongs.

### 3.3 `signals` — REJECT

- `signals` / `signals_flutter` **7.1.0**, 2026-05-29. Actively maintained (`rodydavis/signals.dart`, ~800 stars, last push 2026-07-20). Not abandoned.
- The reactivity model (fine-grained signals/computed/effects) is elegant and genuinely reduces rebuilds.
- **But:** ~800 stars vs Riverpod's ecosystem; almost no third-party integration; you will be the first person to hit any drift-interop bug; and for an offline app the rebuild-granularity win is negligible because your bottleneck is SQL + custom painting, not `setState` churn.
- Adopting a small-ecosystem reactivity library for a shippable production app is a risk with no matching payoff here.

### 3.4 `ValueNotifier` / `ChangeNotifier` + `InheritedWidget` — REJECT as the primary mechanism, KEEP for leaves

You *could* build this app with them (compass_app proves it). You'd have to hand-roll: DI wiring, disposal, `Result`/loading-state types, per-key caching, and test overrides — i.e. reimplement 60% of Riverpod, worse.

**But do keep them where they belong:**
- `ValueNotifier` inside a single widget for e.g. the ruler's drag offset — avoids `setState` rebuilding the whole subtree.
- `ChangeNotifier` for anything you hand to a Flutter API that expects a `Listenable` (e.g. `AnimatedBuilder`, `ListenableBuilder`, custom painters' `repaint:` argument). **For your on-screen ruler `CustomPainter`, pass a `Listenable` to `super(repaint: …)` rather than rebuilding via a provider** — that repaints without rebuilding widgets.
- Note Riverpod 3.4.0 added `ref.watch(counterProvider.listenable)` returning a `ValueListenable<int>`, which is a clean bridge into `CustomPainter(repaint:)`. (Source: `packages/riverpod/CHANGELOG.md`, 3.4.0 entry.)

---

## 4. Riverpod 3: what changed, and what advice is now STALE

Riverpod 3.0.0 shipped **2025-09-10**. Anything written before that date about Riverpod is suspect. Primary source: <https://riverpod.dev/docs/whats_new> and `website/docs/3.0_migration.mdx`.

### 4.1 STALE ADVICE — flag these hard in any tutorial you read

| Stale pattern | Status in 3.4.1 | Do this instead |
|---|---|---|
| `StateProvider` | **Moved to `package:flutter_riverpod/legacy.dart`.** Still works, deliberately quarantined. | `NotifierProvider` |
| `StateNotifierProvider` / `StateNotifier` | Legacy import. `state_notifier` pkg last published **2023-08-16**. | `Notifier` / `NotifierProvider` |
| `ChangeNotifierProvider` (Riverpod's) | Legacy import. | `Notifier` |
| `.autoDispose` modifier chains, `AutoDisposeNotifier`, `AutoDisposeRef` | **Interfaces removed/unified.** Migration guide: "do a case-sensitive replace of `AutoDispose` to `` (empty string)." Manual providers now take `isAutoDispose: true`. | `@riverpod` (autoDispose is the default) or `Provider(isAutoDispose: true, …)` |
| `FamilyNotifier`, `FamilyAsyncNotifier`, `FamilyStreamNotifier` | **Removed.** Fused into `Notifier`/`AsyncNotifier`/`StreamNotifier`. | Family params go on `build()` (codegen) or a constructor field (manual) |
| `ExampleRef`, `FutureProviderRef`, `ProviderRef` etc. | **All `Ref` subclasses removed.** `Ref` lost its type parameter. | `Ref` |
| `ref.state` inside a functional provider; `ref.listenSelf`; `ref.future` | Moved onto Notifiers: `Notifier.state`, `Notifier.listenSelf`, `AsyncNotifier.future`. | Convert to a Notifier class |
| `asyncValue.valueOrNull` | **Renamed to `.value`** (now `ValueT?`). | `.value` |
| "Use codegen, macros are coming" | **Macros were cancelled.** See §5. | Decide on codegen for its own merits |
| `dart run custom_lint` in CI | riverpod_lint dropped `custom_lint` in **3.1.0 (2025-12-26)**. | `dart analyze` (see §6.6) |
| `ProviderContainer()` in tests | Superseded. | `ProviderContainer.test()` — auto-disposes |

### 4.2 NEW in 3.x that materially matters here

**`AsyncValue` is a `sealed class`.** Verified in `packages/riverpod/lib/src/core/async_value.dart:438` — `sealed class AsyncValue<ValueT>` with `final class AsyncData` / `AsyncLoading` / `AsyncError`. So exhaustive Dart 3 pattern matching works and the compiler enforces it:

```dart
final entries = ref.watch(entriesProvider);
return switch (entries) {
  AsyncData(:final value) => EntryList(entries: value),
  AsyncError(:final error) => ErrorView(error: error),
  AsyncLoading() => const _EntriesSkeleton(),
};
```

This is strictly better than `.when(data:, error:, loading:)` — it is compile-time exhaustive, and it composes with the rest of your Dart 3 code. Prefer `switch` over `.when` in new code.

**`Ref.mounted`** — mirrors `BuildContext.mounted`; refs now *throw* if touched after disposal (3.0 breaking change), so you need it after `await`:

```dart
final provider = FutureProvider<int>((ref) async {
  await Future.delayed(Duration(seconds: 1));
  if (!ref.mounted) throw MyException();
  return 42;
});
```
<https://riverpod.dev/docs/whats_new#refmounted>

**Automatic retry with exponential backoff (200 ms → 6.4 s) is ON BY DEFAULT.** This is the one 3.0 default that is actively *wrong for a 100% offline app.* A failing local query is a bug or a corrupt database — retrying it eight times silently hides the failure and burns startup budget. **Turn it off globally:**

```dart
void main() {
  runApp(
    ProviderScope(
      retry: (retryCount, error) => null, // never retry: we have no network
      child: const MyApp(),
    ),
  );
}
```
<https://riverpod.dev/docs/3.0_migration> ("Automatic retry")

**Errors are wrapped in `ProviderException`.** `try/catch` on your own exception types now needs unwrapping:

```dart
try {
  await ref.read(myProvider.future);
} on ProviderException catch (e) {
  if (e.exception is DatabaseCorruptException) { /* … */ }
}
```
(`AsyncValue.error` checks are unaffected — `value.error is NotFoundException` still works.)

**All providers now filter updates with `==`** (previously a mix of `==` and `identical`). This has a large, non-obvious consequence for drift — see §7.4.

**Mutations** and **offline persistence** are both marked **experimental** in 3.x. Offline persistence ships as `riverpod_sqflite`. **Do not use either in this project** — you already have drift for persistence, and experimental APIs in a shipping app are a liability. Mutations are for network form submissions; your writes are local and instantaneous.

**Known caveat you will hit** — from the FAQ, worth internalising:

> "When a provider's dependency changes, every dependent provider that still has a listener recomputes **immediately**, before the next frame… So if the same change is also what removes the listener… the dependent still recomputes once against the new value before its widget is unmounted. If that computation assumed the previous value, it throws."
>
> Recommended workaround: "make the computation total: return `null` (or a sentinel) for the transient state instead of throwing."
> <https://riverpod.dev/docs/root/faq>

Practically: derived providers that read `selectedItemProvider!` will throw one frame after the user clears the selection. Always write them total.

---

## 5. Code generation vs manual providers — and why the answer is YES here

This is where most 2024–2025 advice is now wrong. The Riverpod docs used to say "use codegen"; the current text is far more conditional. Verbatim from `website/docs/concepts/about_code_generation.mdx` on `master`:

> "The answer is: **Only if you already use code-generation for other things**. (cf Freezed, json_serializable, etc.)
> When the Dart team was working on a feature called 'macros', using code generation was the recommended way to use Riverpod. **Unfortunately, those have been cancelled.**
> While code-generation brings many benefits, it currently is still fairly slow… if you are not already using code generation in your project, it is probably not worth it to start using it just for Riverpod."

<https://riverpod.dev/docs/concepts/about_code_generation>

**Apply the test to this project: it passes decisively.** This app runs `drift_dev` under `build_runner` already (drift is codegen-mandatory), and per Flutter's own architecture guidance you should be running `freezed` for immutable domain models. The marginal cost of adding `riverpod_generator` to an existing `build_runner` pipeline is a handful of seconds. **So: use codegen.**

**And there is a second, stronger reason the docs bury:** *most of `riverpod_lint`'s valuable rules only work with the generator.* From `packages/riverpod_lint/README.md`, these are explicitly marked **"(riverpod_generator only)"**:

- `avoid_build_context_in_providers` ← the single most important architectural guardrail
- `provider_dependencies` ← correctness of scoping
- `scoped_providers_should_specify_dependencies`
- `avoid_keep_alive_dependency_inside_auto_dispose` ← memory-leak guard
- `unsupported_provider_value`
- `functional_ref`, `notifier_extends`, `notifier_build`, `riverpod_syntax_error`

Only `missing_provider_scope`, `provider_parameters`, `avoid_public_notifier_properties`, `avoid_ref_inside_state_dispose`, `async_value_nullable_pattern` and `protected_notifier_properties` work without it.

**Choosing manual providers means opting out of over half the static safety net.** For a solo-developer 50-app challenge where you are moving fast, the lints are worth more than the build time.

### Side-by-side (both verified from the official docs' snippet files)

Codegen — `website/docs/concepts2/family/notifier/codegen.dart`:
```dart
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User> build(String id) async {
    print(this.id);      // params are available on `this`
    return _fetch(id);
  }
}
// usage: ref.watch(userNotifierProvider('123'))
```

Manual equivalent — `website/docs/concepts2/family/notifier/raw.dart`:
```dart
final userProvider = AsyncNotifierProvider.autoDispose
    .family<UserNotifier, User, String>(UserNotifier.new);

class UserNotifier extends AsyncNotifier<User> {
  UserNotifier(this.id);
  final String id;

  @override
  Future<User> build() async => _fetch(id);
}
```

Note the codegen version is autoDispose by default; the manual one is not (you must write `.autoDispose` or `isAutoDispose: true`). That default alone prevents a whole class of leak.

**One caveat to configure:** codegen providers are `autoDispose` by default, which is *wrong* for your database handles. Opt out explicitly:

```dart
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => throw UnimplementedError();
```

---

## 6. Riverpod rules of the road

### 6.1 `ref.watch` vs `ref.read` vs `ref.listen`

Verbatim from `website/docs/concepts2/refs.mdx`:

- **`ref.watch`** — "declarative… the most common way to listen to providers, and **should be your go-to choice**." Use in `build()` of widgets and in provider initialisers.
- **`ref.listen`** — "a more manual way… useful when you want to perform a **side-effect** when a provider's state changes, such as showing a dialog, navigating to a new screen, logging." Safe to call inside `build()` (that is how it's designed); use `ref.listenManual` outside `build` (e.g. `initState`).
- **`ref.read`** — "interact with a provider's state inside button clicks." **Only** in callbacks (`onPressed`, `onTap`, gesture handlers).

The docs mark the misuse with `:::danger`:

> "**Do not use `ref.read` as a mean to 'optimize' your code by avoiding `ref.watch`.** This will make your code more brittle… Either use `ref.watch` anyway (as the difference is negligible) or use `select`… **This shouldn't be a bottle-neck in your apps. Do not over-optimize.**"

```dart
// ❌ read-to-avoid-rebuilds
final tick = ref.read(tickProvider);
// ✅
final tick = ref.watch(tickProvider);
// ✅ narrow the subscription properly
final isEven = ref.watch(tickProvider.select((t) => t.isEven));
```

`ref.invalidate` vs `ref.refresh`: `refresh` is literally `invalidate` + `read`. Use `invalidate` if you don't need the new value; a lint fires if you ignore `refresh`'s return.

### 6.2 `Notifier` public surface

`riverpod_lint`'s `avoid_public_notifier_properties`:

> "There should never be a case where you do `ref.watch(someProvider.notifier).someState`. Instead, you should do `ref.watch(provider).someState`."

Private (`_x`), `@protected`, and `@visibleForTesting` members are allowed. Everything the UI reads goes in `state`.

### 6.3 autoDispose

- `@riverpod` → autoDispose on. `@Riverpod(keepAlive: true)` → off.
- Manual → `Provider(isAutoDispose: true, (ref) => …)` (verified: `super.isAutoDispose = false` in `packages/riverpod/lib/src/providers/notifier/orphan.dart:86`). `.autoDispose` builders still exist for compatibility.
- Mechanism: listener count hits zero → `ref.onCancel` → wait one frame (`await null`) → still unused → dispose + `ref.onDispose`.
- Docs `:::caution`: "When providers receive parameters, it is **recommended** to enable automatic disposal… otherwise, one state per parameter combination will be created, which can lead to memory leaks."
- `ref.keepAlive()` for conditional caching (e.g. cache successful reference-DB lookups, not failed ones); the returned link can `close()` to revert.
- **Call `ref.onDispose` once per disposable object**, not once per provider — the docs recommend this precisely so a missing disposal is visually obvious.

### 6.4 `family`

- `:::caution` — "Parameters passed need to have a consistent `==`/`hashCode`. View 'family' as a Map." `ref.watch(myProvider([1, 2, 3]))` is a **bug** (list literals aren't `==`). The `provider_parameters` lint catches it.
- Perfect fit for your read-only reference DB: `@riverpod Future<Rule> rule(Ref ref, String ruleId)` caches per id and disposes when the screen leaves.
- `ProviderContainer.allProviders(family: myFamily)` (added 3.3.2-dev.1) lets you enumerate live family instances — handy for a debug screen.

### 6.5 Scoping — mostly avoid

The docs carry an explicit warning:

> ":::caution The scoping feature is highly complex and will likely be reworked in the future to be more ergonomic. Thread carefully."
> <https://riverpod.dev/docs/concepts2/scoping>

Scoping requires opting in with `dependencies: []` and threading `dependencies` through every consumer. **Use it for exactly one thing in this app: injecting the two database instances at the root via `ProviderScope(overrides:)`.** That is override-based injection, not per-subtree scoping, and it carries none of the complexity. Do not scope per-route.

### 6.6 riverpod_lint — the installation changed and every tutorial is wrong

**riverpod_lint 3.1.0 (2025-12-26) dropped `custom_lint`.** Verified: `riverpod_lint` 3.0.3's pubspec depends on `custom_lint`; 3.1.0+ does not (deps are now `analysis_server_plugin ^0.3.0`, `analyzer ^13.0.0`, `analyzer_plugin ^0.14.0`).

Old (obsolete) instructions: add `custom_lint` + `riverpod_lint` to `dev_dependencies`, add `custom_lint` to `analyzer.plugins`, run `dart run custom_lint`.

**Current, from `packages/riverpod_lint/README.md`:**

```yaml
# analysis_options.yaml — NOT pubspec.yaml
plugins:
  riverpod_lint: 3.1.6
```

> "Once `riverpod_lint` is installed, `dart analyze` will show warnings from the lint rules created by riverpod_lint."

So: **no dev_dependency, no separate CLI, `dart analyze` is your CI gate.** This requires a Dart SDK new enough for the `plugins:` key — Dart 3.12.2 is fine.

Note `bloc_lint` (0.4.2) migrated the same way, and `signals` shipped an analyzer-plugin migration in 2026-05. The `custom_lint` era is over across the ecosystem; `custom_lint` itself hasn't published since 2025-09-09.

---

## 7. THE KEY QUESTION — drift + Riverpod for an offline-only app

### 7.1 The mental model

> **The database is the store. Riverpod is the cache + DI + lifecycle layer. There is no third source of truth.**

drift's docs endorse the Riverpod pairing directly:

> "Riverpod can wrap streams with a `StreamProvider`. This technique is also used in the example app."
> <https://drift.simonbinder.eu/dart_api/streams/> (source: `docs/content/dart_api/streams.md`)

And `Selectable<T>` gives you the three watch methods you need:
`Stream<List<T>> watch()`, `Stream<T> watchSingle()`, `Stream<T?> watchSingleOrNull()`.

Critically: "All drift streams will emit an up-to-date result after listening to them (so you'll receive a snapshot even if the tables never change, and don't have to combine `get()` and `watch()`)." — meaning a `StreamProvider` will always resolve; you never need a `FutureProvider` + `StreamProvider` pair for the same query.

### 7.2 The layering (matches Flutter's architecture doc)

```
Widgets (ConsumerWidget)  ← dumb; switch on AsyncValue; onPressed → ref.read(repo).method()
        ↑ StreamProvider / Provider
Repository (plain Dart class, takes a DAO in its constructor)
        ↑
DAO (@DriftAccessor) — SQL only
        ↑
AppDatabase / ReferenceDatabase (drift)
```

The repository is where Flutter's `Strongly recommend: use abstract repository classes` lands. Make it abstract so goldens and unit tests can inject a fake without touching SQLite.

### 7.3 Real code — the whole vertical slice

**(a) Two database handles, injected at the root, never auto-disposed**

```dart
// lib/data/db/db_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'db_providers.g.dart';

/// Writable user database. Overridden in main().
@Riverpod(keepAlive: true)
UserDatabase userDatabase(Ref ref) =>
    throw UnimplementedError('override userDatabaseProvider in ProviderScope');

/// Read-only reference database shipped as an asset. Overridden in main().
@Riverpod(keepAlive: true)
ReferenceDatabase referenceDatabase(Ref ref) =>
    throw UnimplementedError('override referenceDatabaseProvider in ProviderScope');
```

*Why `throw UnimplementedError` + override rather than constructing inside the provider?* Because the reference DB needs an asset copied out of the bundle, which is `async` and platform-dependent, and because tests must be able to swap in `NativeDatabase.memory()` without the production path ever running. This is the standard Riverpod idiom for "value that must come from outside." The drift sample constructs inline instead (`static final StreamProvider<AppDatabase> provider = StateProvider((ref) {…})` in `examples/app/lib/database/database.dart:151`) — but note that sample uses the **legacy** `StateProvider` and a single DB; don't copy it verbatim.

**(b) `main()` — keep the async work off the critical path (cold-start budget)**

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // LazyDatabase defers ALL file I/O until the first query.
  // Nothing here blocks the first frame.
  final userDb = UserDatabase(LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    return NativeDatabase.createInBackground(File(p.join(dir.path, 'user.sqlite')));
  }));

  final refDb = ReferenceDatabase(LazyDatabase(() async {
    final path = await _copyAssetDbIfNeeded('assets/reference.sqlite');
    return NativeDatabase.createInBackground(File(path), readOnly: true);
  }));

  runApp(
    ProviderScope(
      retry: (retryCount, error) => null, // offline app: never retry
      overrides: [
        userDatabaseProvider.overrideWithValue(userDb),
        referenceDatabaseProvider.overrideWithValue(refDb),
      ],
      child: const MyApp(),
    ),
  );
}
```

`LazyDatabase` is real: `drift/lib/src/utils/lazy_database.dart` —
> "Declares a `LazyDatabase` that will run `opener` when the database is first requested to be opened."

`NativeDatabase.createInBackground` is real: `drift/lib/native.dart:157`. It moves SQLite onto a background isolate, which keeps the UI isolate free during startup — directly relevant to the 1.2 s budget.

**Cold-start rule:** never `await` a database open before `runApp`. Let the first frame paint a skeleton and let the `StreamProvider`'s `AsyncLoading` state cover the open.

**(c) The repository — a plain class, no Flutter, no Riverpod inside it**

```dart
// lib/data/repositories/measurement_repository.dart
abstract interface class MeasurementRepository {
  Stream<List<Measurement>> watchAll();
  Stream<Measurement?> watchById(int id);
  Future<void> add(MeasurementDraft draft);
  Future<void> delete(int id);
}

class DriftMeasurementRepository implements MeasurementRepository {
  DriftMeasurementRepository(this._dao);
  final MeasurementDao _dao;

  @override
  Stream<List<Measurement>> watchAll() => _dao.watchAll();

  @override
  Stream<Measurement?> watchById(int id) => _dao.watchById(id);

  @override
  Future<void> add(MeasurementDraft draft) => _dao.insert(draft);

  @override
  Future<void> delete(int id) => _dao.deleteById(id);
}
```

Note: **the repository takes no `Ref` and imports no Riverpod.** That is what makes it unit-testable and what lets your pure-Dart rule engine consume the same types.

**(d) The providers — this is the whole "state management" for read paths**

```dart
// lib/data/repositories/measurement_providers.dart
@Riverpod(keepAlive: true)
MeasurementRepository measurementRepository(Ref ref) =>
    DriftMeasurementRepository(ref.watch(userDatabaseProvider).measurementDao);

/// Auto-disposing (default): when the list screen leaves, the SQL stream stops.
@riverpod
Stream<List<Measurement>> measurements(Ref ref) =>
    ref.watch(measurementRepositoryProvider).watchAll();

/// A family: one live query per id, disposed on navigation away.
@riverpod
Stream<Measurement?> measurement(Ref ref, int id) =>
    ref.watch(measurementRepositoryProvider).watchById(id);

/// Derived state — computed in the data layer, NOT in the widget.
@riverpod
Stream<List<Measurement>> visibleMeasurements(Ref ref) {
  final filter = ref.watch(measurementFilterProvider);   // a Notifier
  return ref.watch(measurementRepositoryProvider).watchAll()
      .map((all) => all.where(filter.matches).toList(growable: false));
}
```

**Return the stream. Do not `await for` it.** Writing `await for (final rows in stream) { state = AsyncData(rows); }` inside an `AsyncNotifier` is a common and wrong pattern: it re-implements what `StreamProvider` does, loses error propagation, and leaks the subscription.

**(e) UI-only state that is not in SQL → a `Notifier`**

```dart
@riverpod
class MeasurementFilter extends _$MeasurementFilter {
  @override
  Filter build() => const Filter.all();

  void setUnit(Unit unit) => state = state.copyWith(unit: unit);
  void clear() => state = const Filter.all();
}
```

**(f) The widget — dumb, exhaustive, no logic**

```dart
class MeasurementListScreen extends ConsumerWidget {
  const MeasurementListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(visibleMeasurementsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.measurements)),
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
}
```

Everything in that widget is on Flutter's allowed list: "simple if-statements to show/hide widgets… layout logic… simple routing logic." No `if (items.length > 3 && user.isPremium)`. No SQL. No `context` in providers.

**(g) Writes need no state at all**

The drift sample makes the point better than prose can:

```dart
void _addTodoEntry() {
  // We write the entry here. Notice how we don't have to call setState()
  // or anything - drift will take care of updating the list automatically.
  final database = ref.read(AppDatabase.provider);
  database.todoEntries.insertOne(TodoEntriesCompanion.insert(...));
}
```
<https://github.com/simolus3/drift/blob/develop/examples/app/lib/screens/home.dart>

That is the entire write path. The insert marks the table dirty, drift re-runs every watching query, the `StreamProvider` emits, the widget rebuilds. **No `emit`, no `state =`, no `notifyListeners()`.**

### 7.4 Rebuild economics — the `==` trap (important, non-obvious)

Riverpod 3 filters all provider updates with `==`, and `AsyncValue`'s `==` is:

```dart
// packages/riverpod/lib/src/core/async_value.dart:654
bool operator ==(Object other) {
  return runtimeType == other.runtimeType &&
      other is AsyncValue<ValueT> &&
      other._loading == _loading &&
      other.valueFilled == valueFilled &&
      other._errorFilled == _errorFilled;
}
```

where `_DataRecord<ValueT> = (ValueT, {DataKind? kind, DataSource? source})` (line 350) — a Dart record, which compares its fields with `==`.

**Consequence:**
- `StreamProvider<Measurement?>` (single row): drift's generated row classes implement `==`, so a re-emitted identical row is **filtered — no rebuild**. Free win.
- `StreamProvider<List<Measurement>>`: `List.==` is **identity**. Two different `List` instances with identical contents are never `==`. So **every drift re-query rebuilds every list consumer**, even if nothing changed.

Combine this with drift's own warning:

> "Stream queries generally update more often than they have to, since we can't filter for updates on specific rows only… Whenever an insert, an update, or a deletion is made through drift APIs, the associated queries are rescheduled and will run again."
> <https://drift.simonbinder.eu/dart_api/streams/>

**Mitigations, in order of preference:**

1. **Keep list queries narrow.** One write to `measurements` should not re-run a query joining five tables. Split DAO methods.
2. **`select()` at the consumer** so a widget only rebuilds on the field it uses:
   ```dart
   final count = ref.watch(measurementsProvider.select((a) => a.value?.length ?? 0));
   ```
3. **Deduplicate in the provider** with a content-equal comparison:
   ```dart
   @riverpod
   Stream<List<Measurement>> measurements(Ref ref) =>
       ref.watch(measurementRepositoryProvider)
          .watchAll()
          .distinct(const ListEquality<Measurement>().equals); // package:collection
   ```
   This runs an O(n) comparison to avoid an O(n) widget rebuild — worth it when the widget subtree is expensive (your ruler / custom painter), not worth it for a 10-row list.
4. **For the custom-painted ruler specifically:** don't drive it from a `StreamProvider` rebuild at all. Bridge to a `Listenable` (`ref.watch(p.listenable)`, new in 3.4.0) and pass it to `CustomPainter(repaint: …)`. That repaints without rebuilding the widget tree.

### 7.5 The pause/resume synergy — verified in both source trees, and it is excellent

Riverpod 3 pauses providers whose consumers are not visible, keyed on `TickerMode`:

> "Providers that are not used by the visible widget tree are paused… Riverpod relies on `TickerMode` to determine if a widget is visible or not."
> <https://riverpod.dev/docs/whats_new#listeners-inside-widgets-that-are-not-visible-are-now-paused>

For a `StreamProvider`, "pause" means calling `StreamSubscription.pause()` — verified in `packages/riverpod/lib/src/core/element.dart:164-192`:

```dart
WhenComplete handleStream(Ref ref, Stream<ValueT> Function() create) {
  ...
  subscription = stream.listen(data, onError: error, onDone: done);
  final asyncSub = (
    cancel: subscription.cancel,
    pause: subscription.pause,
    resume: subscription.resume,
    abort: subscription.cancel,
  );
  ...
}

@override
void onCancel() {
  super.onCancel();
  _cancelSubscription?.pause?.call();
}
```

For most streams a pause means *buffering* — you'd get a burst of stale events on resume. **Drift does not do that.** `drift/lib/src/runtime/executor/stream_queries.dart` implements `QueryStream` with `Stream.multi(..., isBroadcast: true)` and explicit per-subscription pause handling:

```dart
// It could be that we have no active, but some paused listeners. In
// that case, we still want to invalidate cached data but there's no
// point in fetching new data now. We'll load the query again after
// a listener unpauses.
if (_activeListeners > 0) {
  fetchAndEmitData();
}
```

and on resume (`_onListenOrResume`), because `_lastData` was nulled by the invalidation, it re-runs `fetchAndEmitData()` — one fresh result, no stale backlog.

**Net effect for your app:** push a detail route on top of the list → the list's SQL query genuinely stops executing while it's off-screen; pop back → exactly one fresh query runs. You get this for free by using `StreamProvider` and doing nothing clever. This alone is a strong argument for Riverpod 3 + drift over any hand-rolled `StreamBuilder` approach, which would keep querying forever.

(If you ever need to defeat it — e.g. a background sync indicator that must keep updating behind a modal — wrap the consumer in `TickerMode(enabled: true, child: …)`.)

### 7.6 The pure-Dart rule-engine package

**Do not put Riverpod in it.** Riverpod *can* run in pure Dart (`ProviderContainer` without Flutter — see `concepts2/containers.mdx`), and that's genuinely useful for your CLI content-build tool if it grows complex. But a domain package should have zero framework dependencies so it stays trivially testable and reusable.

Correct shape:
- `packages/rule_engine/` — plain Dart. `sealed class RuleResult` + pattern matching. No `flutter`, no `riverpod`, no `drift`.
- The Flutter app wires it in with one provider:
  ```dart
  @Riverpod(keepAlive: true)
  RuleEngine ruleEngine(Ref ref) => RuleEngine(rules: ref.watch(compiledRulesProvider));
  ```
- The CLI tool constructs `RuleEngine()` directly with `new`.

Bloc's own lint set has a rule named `avoid_flutter_imports` for exactly this reason — the principle is not controversial, only the enforcement is. You can enforce it yourself with `dart analyze` in the package plus a CI grep for `package:flutter`.

---

## 8. Testing

### 8.1 Unit-testing providers

From `website/docs/how_to/testing/unit_test.dart`:

```dart
void main() {
  test('Some description', () {
    // Create a ProviderContainer for this test.
    // DO NOT share ProviderContainers between tests.
    final container = ProviderContainer.test();

    expect(container.read(provider), equals('some value'));
  });
}
```

`ProviderContainer.test()` (new in 3.0) **auto-disposes at test end** — you no longer need `addTearDown(container.dispose)`.

**Caution from the docs** — this bites constantly with autoDispose providers:

> "Be careful when using `container.read` when providers are automatically disposed. If your provider is not listened to, chances are that its state will get destroyed in the middle of your test. In that case, consider using `container.listen`."

```dart
final subscription = container.listen<String>(provider, (_, _) {});
expect(subscription.read(), 'Some value'); // keeps the provider alive
```

**Async providers** — read `.future`, not the provider:

```dart
await expectLater(container.read(provider.future), completion('some value'));
```

### 8.2 Overrides (this is your fake-injection mechanism)

```dart
final container = ProviderContainer.test(
  overrides: [
    exampleProvider.overrideWith((ref) => 'Hello from tests'),
  ],
);
```

For this app, the canonical test harness is: **override the two DB providers with in-memory drift databases**, then exercise the real repositories and real providers.

```dart
ProviderContainer testContainer({List<Override> extra = const []}) {
  final db = UserDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return ProviderContainer.test(
    overrides: [userDatabaseProvider.overrideWithValue(db), ...extra],
  );
}
```

This gives you **integration-grade coverage at unit-test speed** — real SQL, real drift stream semantics, no I/O, no mocks to keep in sync. For an offline app this is the highest-leverage testing decision available, and it is why I'd take Riverpod's override system over `bloc_test`'s nicer ergonomics.

### 8.3 Widget & golden tests (relevant to your six-locale goldens)

```dart
testWidgets('…', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [measurementRepositoryProvider.overrideWithValue(FakeRepo())],
      child: const MaterialApp(home: MeasurementListScreen()),
    ),
  );
  final container = tester.container();   // new in 3.0: WidgetTester.container
  expect(container.read(someProvider), …);
});
```

**For golden tests across six locales including Arabic RTL:** override the repository with a **deterministic fake returning a fixed list** — never a real database (timestamps, autoincrement ids and row order will make goldens flaky). Then loop locales:

```dart
for (final locale in const [Locale('en'), Locale('ar'), Locale('fr'), …]) {
  testWidgets('list golden $locale', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [measurementRepositoryProvider.overrideWithValue(const FixedRepo())],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MeasurementListScreen(),
      ),
    ));
    await expectLater(find.byType(MeasurementListScreen),
        matchesGoldenFile('goldens/list_${locale.languageCode}.png'));
  });
}
```

Because the repository is an `abstract interface class` with no Riverpod inside, `FixedRepo` is ten lines and needs no mocking library.

### 8.4 Do NOT mock Notifiers

> "It is generally discouraged to mock Notifiers… Instead, you should likely introduce a level of abstraction in the logic of your Notifier, such that you can mock that abstraction. For instance, rather than mocking a Notifier, you could mock a 'repository' that the Notifier uses."

If you must, your mock has to **subclass** (not `implement`) the generated base — and with codegen it must live in the same file as the Notifier to see `_$MyNotifier`.

This constraint is itself an argument for the architecture in §7: if your Notifiers hold only UI state and your data comes from repositories, you never need to mock a Notifier.

---

## 9. Cold-start checklist (< 1.2 s on low-end Android)

1. **Nothing `await`ed before `runApp`.** Use `LazyDatabase` so the file open happens on first query, inside an `AsyncLoading` state.
2. **`NativeDatabase.createInBackground`** so SQLite runs on a background isolate (`drift/lib/native.dart:157`).
3. **Turn off Riverpod's automatic retry** (§4.2) — a retrying failed provider burns 200 ms + 400 ms + 800 ms… of startup for no reason in an offline app.
4. **Do not eagerly initialise providers you don't need on the first frame.** Riverpod's `_EagerInitialization` widget pattern (<https://riverpod.dev/docs/how_to/eager_initialization>) is for things the whole app needs. Use it for *at most* the settings/locale provider:
   ```dart
   class _EagerInitialization extends ConsumerWidget {
     const _EagerInitialization({required this.child});
     final Widget child;
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       ref.watch(appSettingsProvider);
       return child;   // returning `child` unchanged means Flutter skips rebuilding it
     }
   }
   ```
   The docs explicitly explain why this doesn't rebuild the world: "it returns a `child`, rather than instantiating `MaterialApp` itself… when a widget doesn't change, Flutter doesn't rebuild it."
5. **`AsyncValue.requireValue`** in downstream widgets once something is eagerly initialised, so you don't pay for `AsyncValue` pattern matching in fifty widgets.
6. **The reference DB asset copy is a one-time cost on first launch only** — gate it behind a version check, don't `File.exists` + re-copy every start.
7. **`riverpod_generator`'s output is tree-shakeable const-ish code**; it adds no measurable startup cost. `ProviderScope` itself is a single `InheritedWidget`.

---

## 10. Anti-patterns — what NOT to do

**Architecture**

1. ❌ **Business logic in widgets.** Flutter grades this `Strongly recommend` against. A `ConsumerWidget.build` should read providers and return widgets. Nothing else.
2. ❌ **Mirroring database rows into a Notifier.** `class MeasurementsNotifier extends AsyncNotifier<List<Measurement>>` that loads rows into `state` gives you two sources of truth and stale data. Use `StreamProvider`.
3. ❌ **`await for` over a drift stream inside a Notifier.** Leaks the subscription, swallows errors, duplicates `StreamProvider`.
4. ❌ **Reusing `WidgetRef` as if it were `Ref`.** Riverpod's FAQ: *"relying on `WidgetRef` is equivalent to relying on `BuildContext`. It is effectively putting your logic in the UI layer, which is not recommended… Such code should be refactored to **always** use `Ref`."* Move the logic into a Notifier method; the widget calls `ref.read(p.notifier).method()`.
5. ❌ **`BuildContext` inside a provider or a Notifier method.** Caught by `avoid_build_context_in_providers` (codegen only — another reason to use codegen). If a Notifier needs to navigate, it shouldn't; return a state the router watches, or use `ref.listen` in the widget.

**Riverpod specifics**

6. ❌ **`ref.read` to dodge rebuilds.** Docs `:::danger`. Use `select`.
7. ❌ **Initialising providers from `initState`:**
   ```dart
   void initState() { super.initState(); ref.read(provider).init(); } // DON'T
   ```
   > "Providers should initialize themselves. They should not be initialized by an external element such as a widget. Failing to do so could cause possible race conditions and unexpected behaviors."
8. ❌ **Side effects in a provider's initialiser.**
   ```dart
   final submitProvider = FutureProvider((ref) async {
     final formState = ref.watch(formState);
     return http.post(...);   // DON'T — providers are "read" operations
   });
   ```
9. ❌ **Providers as instance fields.** "Providers should exclusively be top-level final variables." Instance fields cause memory leaks. (`static final` is allowed but unsupported by the generator.)
10. ❌ **Passing a provider as a widget constructor parameter** (`Example({required this.provider})`) — defeats static analysis and all the lints.
11. ❌ **Using providers for ephemeral state** — selected item, form state, animations, `TextEditingController`. Docs: *"leaving and re-entering the form should typically reset the form state… Failing to do so could break your app's back button, due to a new page overriding the state of a previous page."* Use `StatefulWidget`.
12. ❌ **Family parameters without stable `==`.** `ref.watch(p([1,2,3]))` is a leak generator.
13. ❌ **Public non-`state` properties on a Notifier.** Never `ref.watch(p.notifier).someField`.
14. ❌ **Trying to "reset all providers" on logout/reset.** Docs call it an anti-pattern; make dependents `ref.watch` the root provider instead.
15. ❌ **Leaving automatic retry on in an offline app.** See §4.2.
16. ❌ **`ProviderContainer()` in tests.** Use `ProviderContainer.test()`.
17. ❌ **Deep scoping with `dependencies:`.** The docs themselves say it "will likely be reworked." Use root overrides only.

**Tooling / staleness**

18. ❌ **Copy-pasting `StateProvider` / `StateNotifierProvider` / `ChangeNotifierProvider` from a tutorial.** They now require `import 'package:flutter_riverpod/legacy.dart'` — if the import looks like that, the tutorial is pre-3.0. (Even drift's own example app still uses `StateProvider` from `legacy.dart`. Read it for the drift patterns, not the Riverpod ones.)
19. ❌ **Adding `custom_lint` to `dev_dependencies` and running `dart run custom_lint`.** Obsolete since riverpod_lint 3.1.0. Use `plugins:` in `analysis_options.yaml` + `dart analyze`.
20. ❌ **Using `riverpod_sqflite` / offline persistence, or `Mutation`.** Both experimental; both redundant here.

---

## 11. Where credible sources genuinely disagree

**(a) "Does Flutter recommend `provider` for DI?" — Yes, and I'm overriding it.**
`docs.flutter.dev/app-architecture/recommendations` says *Strongly recommend: use dependency injection… Recommends using the `provider` package.* I disagree for this app. `provider` is feature-frozen, its author built Riverpod as the successor, and running two DI systems (Riverpod for state, provider for DI) is strictly worse than one. **Recommendation: Riverpod providers + `overrides` for DI. Take Flutter's *principle* (inject, don't use globals), reject its *package*.**

**(b) "Should you use Riverpod codegen?" — the docs say *only if you already use codegen*; I say yes here.**
The docs are being conservative for the general audience because build_runner is slow and macros died. But (i) this project already runs `drift_dev` + likely `freezed`, so the pipeline cost is already paid, and (ii) the docs undersell how much of `riverpod_lint` is codegen-gated. **Recommendation: codegen. Revisit only if `build_runner watch` becomes painful on your machine.**

**(c) "Bloc vs Riverpod."** Both camps are right about different apps. Bloc's event-log auditability and enforced uniformity are real advantages on large teams and regulated products. Neither applies to a solo offline utility app where the state is a SQL query. **Recommendation: Riverpod, and I'd reverse this only if you needed a serialized audit trail of user actions.**

**(d) "Is `.when()` or `switch` the right way to consume `AsyncValue`?"** Most existing material uses `.when()`. Since `AsyncValue` became `sealed` in 3.0, `switch` is compile-time exhaustive and `.when()` is not. **Recommendation: `switch`.** Flag `.when()`-only tutorials as pre-Dart-3-idiom.

**(e) "Does Riverpod's off-screen pausing help or hurt?"** Riverpod's docs frame it as "possibly saving resources"; a generic stream consumer would call it a stale-data hazard. For drift specifically I verified it is a clean win (§7.5). **Recommendation: leave it on. Only reach for `TickerMode` if you find a background-updating widget that must keep running.**

---

## 12. Sources (all fetched 2026-07-27)

**Official Flutter**
- Architecture recommendations — <https://docs.flutter.dev/app-architecture/recommendations>
- State-management options — <https://docs.flutter.dev/data-and-backend/state-mgmt/options>
- `compass_app` ViewModel — <https://github.com/flutter/samples/blob/main/compass_app/app/lib/ui/home/view_models/home_viewmodel.dart>
- `compass_app` DI — <https://github.com/flutter/samples/blob/main/compass_app/app/lib/config/dependencies.dart>

**Riverpod (docs + source, `rrousselGit/riverpod@master`)**
- What's new in 3.0 — <https://riverpod.dev/docs/whats_new>
- 3.0 migration — <https://github.com/rrousselGit/riverpod/blob/master/website/docs/3.0_migration.mdx>
- DO/DON'T — <https://riverpod.dev/docs/root/do_dont>
- FAQ — <https://riverpod.dev/docs/root/faq>
- About code generation — <https://riverpod.dev/docs/concepts/about_code_generation>
- Refs (watch/read/listen) — <https://github.com/rrousselGit/riverpod/blob/master/website/docs/concepts2/refs.mdx>
- Automatic disposal — <https://github.com/rrousselGit/riverpod/blob/master/website/docs/concepts2/auto_dispose.mdx>
- Family — <https://github.com/rrousselGit/riverpod/blob/master/website/docs/concepts2/family.mdx>
- Scoping — <https://github.com/rrousselGit/riverpod/blob/master/website/docs/concepts2/scoping.mdx>
- Containers — <https://github.com/rrousselGit/riverpod/blob/master/website/docs/concepts2/containers.mdx>
- Testing — <https://riverpod.dev/docs/how_to/testing> (+ snippet sources under `website/docs/how_to/testing/`)
- Eager initialization — <https://riverpod.dev/docs/how_to/eager_initialization>
- `riverpod_lint` README (lint list + `plugins:` install) — <https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod_lint/README.md>
- CHANGELOG (3.0.0 → 3.4.1) — <https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod/CHANGELOG.md>
- `AsyncValue` source (sealed + `==`) — <https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod/lib/src/core/async_value.dart>
- Stream pause implementation — <https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod/lib/src/core/element.dart> (`handleStream`, `onCancel`)
- `isAutoDispose` param — <https://github.com/rrousselGit/riverpod/blob/master/packages/riverpod/lib/src/providers/notifier/orphan.dart>

**Drift (`simolus3/drift@develop`)**
- Stream queries doc — <https://github.com/simolus3/drift/blob/develop/docs/content/dart_api/streams.md>
- `QueryStream` pause-aware source — <https://github.com/simolus3/drift/blob/develop/drift/lib/src/runtime/executor/stream_queries.dart>
- `LazyDatabase` — <https://github.com/simolus3/drift/blob/develop/drift/lib/src/utils/lazy_database.dart>
- Riverpod example app — <https://github.com/simolus3/drift/blob/develop/examples/app/lib/screens/home/state.dart> and `.../screens/home.dart`

**Bloc (`felangel/bloc@master`)**
- Why Bloc — <https://github.com/felangel/bloc/blob/master/docs/src/content/docs/why-bloc.mdx>
- Architecture (incl. "Connecting Blocs through Domain") — <https://github.com/felangel/bloc/blob/master/docs/src/content/docs/architecture.mdx>
- Testing / `bloc_test` — <https://github.com/felangel/bloc/blob/master/docs/src/content/docs/testing.mdx>
- CHANGELOGs — `packages/bloc/CHANGELOG.md`, `packages/flutter_bloc/CHANGELOG.md`

**Package metadata** — `https://pub.dev/api/packages/<name>` for every version/date in §1.
**Signals** — <https://github.com/rodydavis/signals.dart> (repo activity, not archived).

*Not consulted, by policy: Medium, dev.to, SEO listicles, Reddit.*

---

## 13. Unverified / open items

- I did not benchmark `build_runner` incremental times with `drift_dev` + `riverpod_generator` + `freezed` together on this machine. The claim "marginal cost is small" is reasoning from the fact that drift already mandates build_runner, not a measurement. **Measure it before committing.**
- `bloclibrary.dev` returned HTTP 403 to WebFetch; all Bloc quotes come from the source `.mdx` in `felangel/bloc@master`, which is what that site renders.
- I did not find any official Flutter or Riverpod guidance specifically about RTL/locale interaction with state management. No evidence found that locale handling needs anything beyond a `Notifier<Locale>` watched by `MaterialApp`.
- `riverpod_generator` 4.0.6 lists `mockito ^5.4.4` as a **regular** dependency (not dev). Odd but harmless — it's a dev_dependency of your app either way.
- Riverpod 3.x offline persistence (`riverpod_sqflite`) and `Mutation` are still labelled experimental as of 3.4.1; I did not evaluate their stability because this project should not use them.
