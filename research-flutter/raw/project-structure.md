# Flutter Project & File Structure — evidence-based build guide

**Research date:** 2026-07-27
**Target toolchain:** Flutter 3.44.6 stable (released 2026-07-08). Dart SDK shipped with Flutter 3.44 is
`^3.12.0` — verified from two independent pinned pubspecs: Very Good Ventures' `very_good_core` brick
(`sdk: ^3.12.0` / `flutter: ^3.44.0`) and Immich's `mobile/pubspec.yaml` (`sdk: '>=3.12.0 <4.0.0'`,
`flutter: 3.44.8`).
**Target app:** 100% offline Android+iOS app; two drift SQLite DBs (one read-only pre-seeded asset DB,
one writable user DB); flutter_riverpod; 6 locales incl. Arabic/RTL via ARB; pure-Dart rule-engine
package shared with a CLI content-build tool; custom painting, SVG, PDF export, camera, single-shot GPS,
a11y, golden tests across locales; cold start budget < 1.2 s on low-end Android.

Everything below is derived from directory trees and files I actually pulled from GitHub with `gh api`
on 2026-07-27, or from official docs/source I fetched. Where I could not verify something I say so.

---

## 0. TL;DR — the eight decisions

| # | Decision | Verdict |
|---|---|---|
| 1 | Feature-first vs layer-first | **Hybrid, exactly as Flutter's official guidance:** UI grouped by feature, data grouped by type. Not pure either. |
| 2 | Monorepo tool | **Dart pub workspaces** (`workspace:` + `resolution: workspace`). Melos only if you later need versioning/publishing scripts. |
| 3 | Where the pure-Dart domain package lives | `packages/<name>_domain/` as a workspace member, plus a second pure-Dart `packages/<name>_reference_db/` shared with the CLI. |
| 4 | ARB files | `app/lib/l10n/arb/*.arb`, generated code to `app/lib/l10n/gen/`, via `l10n.yaml`. **Never** `package:flutter_gen` — that's dead. |
| 5 | Barrel files | **No app-internal barrels.** Barrels only on the public API of your `packages/*`. |
| 6 | Import style inside `lib/` | Relative (`../../routing/routes.dart`), enforced with `prefer_relative_imports`. `package:` from `test/`. |
| 7 | Golden files | `app/test/goldens/<name>_<locale>.png`, resolved relative to the test file's directory. |
| 8 | Assets | `app/assets/<kind>/…`, one pubspec entry per directory (entries are **not** recursive), SVGs pre-compiled with the `vector_graphics_compiler` asset transformer. |

---

## 1. What I audited (all verified live on 2026-07-27)

| Repo | Stars | Last push | Why it counts |
|---|---|---|---|
| `flutter/samples` (`compass_app`) | 19,222 | 2026-07-21 | The **official** reference implementation of Flutter's architecture guide |
| `flutter/samples` (repo root) | — | — | Google's own Dart **pub workspace** monorepo, 38 members |
| `flutter/flutter` `packages/` | 177,950 | 2026-07-27 | Canonical package/barrel layout for Dart libraries |
| `localsend/localsend` | 86,142 | 2026-07-27 | Large production Flutter app, 55 locales, `app/` + `packages/` split |
| `immich-app/immich` (`mobile/`) | 108,939 | 2026-07-27 | Production app on **drift 2.34**, mid-migration to clean architecture, has in-repo architecture READMEs |
| `AppFlowy-IO/AppFlowy` (`frontend/appflowy_flutter`) | 74,331 | 2026-07-24 | Large desktop+mobile Flutter app, explicit `lib/features/` convention |
| `VeryGoodOpenSource/very_good_templates` | 170 | 2026-07-27 | The **live** source of `very_good_cli create` output (see §1.6 warning) |
| `saber-notes/saber` | 4,623 | 2026-07-25 | Offline-first, heavy custom painting, 20+ locales incl. **ar/fa/he (RTL)**, real golden tests |
| `KRTirtho/spotube` | 47,931 | 2026-07-25 | drift + ARB + `drift_schemas/` + migration tests |
| `simolus3/drift` `examples/app` | 3,251 | 2026-07-25 | The drift maintainer's own app layout |
| `firebase/flutterfire` | — | — | Evidence that a huge monorepo migrated melos → pub workspaces |

### 1.1 `flutter/samples/compass_app` — the official architecture sample

Top-level (`compass_app/`): `app/`, `server/`, `docs/`, `README.md`. Two separate Dart packages, both
members of the repo-root pub workspace.

`compass_app/app/`:

```
app/
├── android/ ios/ linux/ macos/ web/ windows/
├── assets/                      # activities.json, destinations.json, logo.svg, user.jpg
├── integration_test/            # app_local_data_test.dart, app_server_data_test.dart
├── lib/
│   ├── config/
│   │   ├── assets.dart          # typed asset path constants
│   │   └── dependencies.dart    # ALL DI wiring, one list per environment
│   ├── data/
│   │   ├── repositories/<feature>/<feature>_repository{,_local,_remote,_dev}.dart
│   │   └── services/
│   │       ├── api/{api_client,auth_api_client}.dart
│   │       ├── api/model/<name>/<name>_api_model.dart(+.freezed.dart/.g.dart)
│   │       ├── local/local_data_service.dart
│   │       └── shared_preferences_service.dart
│   ├── domain/
│   │   ├── models/<name>/<name>.dart(+.freezed.dart/.g.dart)
│   │   └── use_cases/booking/booking_{create,share}_use_case.dart
│   ├── routing/{router.dart,routes.dart}
│   ├── ui/
│   │   ├── core/
│   │   │   ├── localization/applocalization.dart
│   │   │   ├── themes/{colors.dart,dimens.dart,theme.dart}
│   │   │   └── ui/                 # ~9 shared widgets, flat
│   │   └── <feature>/
│   │       ├── view_models/<feature>_viewmodel.dart
│   │       └── widgets/<feature>_screen.dart + sub-widgets
│   ├── utils/{command.dart,result.dart,image_error_listener.dart}
│   ├── main.dart  main_development.dart  main_staging.dart
├── test/                        # mirrors lib/ exactly: test/data, test/domain, test/ui, test/utils
├── testing/                     # NOT under test/ — reusable fakes + model stubs
│   ├── app.dart
│   ├── fakes/repositories/fake_*.dart
│   ├── fakes/services/fake_*.dart
│   ├── mocks.dart
│   ├── models/{activity,booking,destination,user}.dart
│   └── utils/result.dart
├── analysis_options.yaml
└── pubspec.yaml
```

Source: `gh api repos/flutter/samples/git/trees/main?recursive=1` —
<https://github.com/flutter/samples/tree/main/compass_app/app>

Three non-obvious things this sample actually does:

1. **`testing/` is a sibling of `test/`, not a subfolder.** Tests import it with relative paths.
   Real import from `compass_app/app/test/ui/results/results_viewmodel_test.dart`:
   ```dart
   import 'package:compass_app/domain/models/itinerary_config/itinerary_config.dart';
   import 'package:compass_app/ui/results/view_models/results_viewmodel.dart';
   import 'package:flutter_test/flutter_test.dart';

   import '../../../testing/fakes/repositories/fake_destination_repository.dart';
   ```
   Note the mix: `package:` for library code, relative for test helpers.
2. **Inside `lib/` it uses relative imports.** From `lib/ui/results/widgets/results_screen.dart`:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:go_router/go_router.dart';

   import '../../../routing/routes.dart';
   import '../../core/localization/applocalization.dart';
   import '../../core/themes/dimens.dart';
   import '../view_models/results_viewmodel.dart';
   import 'result_card.dart';
   ```
   This is enforced: `compass_app/app/analysis_options.yaml` turns on `prefer_relative_imports`,
   `directives_ordering`, `combinators_ordering`, `prefer_final_locals`, `omit_local_variable_types`.
3. **`config/dependencies.dart` is a single file listing every provider, split per environment**
   (`providersLocal` / `providersRemote` / `_sharedProviders`). One place to read the whole object graph.
   It uses `provider`, not Riverpod — see §3.3.

### 1.2 `flutter/samples` root — Google's pub workspace

`flutter/samples/pubspec.yaml` (real, unedited head):

```yaml
name: samples
description: A collection of samples for Dart and Flutter.

environment:
  sdk: ^3.9.0-0

workspace:
  - analysis_defaults
  - animations
  - asset_transformation
  - asset_transformation/grayscale_transformer
  - compass_app/app
  - compass_app/server
  - ...
  - tool
```

Every member declares `resolution: workspace`. Shared lint config is itself a **package with no code**:

```yaml
# flutter/samples/analysis_defaults/pubspec.yaml
name: analysis_defaults
description: Analysis defaults for flutter/samples
publish_to: none
resolution: workspace

environment:
  sdk: ^3.9.0-0

# NOTE: Code is not allowed in this package. Do not add more dependencies.
# The `flutter_lints` dependency is required for `lib/flutter.yaml`.
dependencies:
  flutter_lints: ^6.0.0
```

`analysis_defaults/lib/flutter.yaml` (verbatim):

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

Consumed by a member as `include: package:analysis_defaults/flutter.yaml` with
`dev_dependencies: analysis_defaults: {path: ../../analysis_defaults}`.
Source: <https://github.com/flutter/samples/blob/main/analysis_defaults/pubspec.yaml>

**Copy this pattern.** It is the cleanest way I found to share lint rules across a workspace.

### 1.3 `localsend/localsend` — layer-first, and it works at 86k stars

```
localsend/
├── app/                    # the Flutter app (own pubspec)
│   ├── android/ ios/ linux/ macos/ web/ windows/
│   ├── assets/i18n/…       # translations shipped as assets
│   ├── lib/
│   │   ├── config/{init.dart,init_error.dart,refena.dart,theme.dart}
│   │   ├── gen/            # assets.gen.dart + strings*.g.dart (slang, 55 locales)
│   │   ├── model/{cross_file.dart, persistence/, state/, …}
│   │   ├── pages/          # one file (or folder) per screen
│   │   ├── provider/       # ALL state, flat-ish, by concern
│   │   ├── util/           # incl. util/native/, util/ui/
│   │   ├── widget/         # shared widgets: dialogs/, list_tile/, sliver/, watcher/
│   │   └── main.dart
│   ├── test/{mocks.dart, unit/{model,provider,util}}
│   ├── build.yaml
│   └── pubspec.yaml
├── cli/                    # Rust
├── packages/
│   ├── core/               # Rust
│   ├── localsend_isolates/ # Dart+Rust bridge package
│   └── typed_isolates/     # PURE DART package
├── server/                 # Rust
├── fastlane/ support/
└── AGENTS.md
```

`app/pubspec.yaml` wires the local package with a plain path dependency:

```yaml
dependencies:
  localsend_isolates:
    path: ../packages/localsend_isolates
```

And `packages/typed_isolates/pubspec.yaml` is a textbook pure-Dart package — no Flutter anywhere:

```yaml
name: typed_isolates
description: Create isolates and communicate with them in a type-safe manner.
version: 1.0.0

environment:
  sdk: ^3.5.0

dev_dependencies:
  lints: ^2.0.0
```

**Zero barrel files** in `app/lib/` (I checked: no file whose basename equals its parent directory).
Source: <https://github.com/localsend/localsend/tree/main/app/lib>

### 1.4 `immich-app/immich/mobile` — drift in production, with in-repo architecture docs

```
mobile/
├── android/ ios/
├── assets/            # png/svg/webp/json, flat + feature_message/
├── fonts/
├── bin/               # dart scripts
├── drift_schemas/main/drift_schema_v1..vN.json     # committed drift schema snapshots
├── integration_test/
├── openapi/           # generated API client as its OWN local package
├── packages/ui/       # local Flutter UI package (immich_ui)
├── pigeon/            # platform-channel definitions
├── scripts/  makefile  build.yaml  dcm_global.yaml
├── lib/
│   ├── constants/     # aspect_ratios, colors, enums, errors, filters, locales
│   ├── domain/        # README.md + models/ services/ utils/     <-- new architecture
│   ├── infrastructure/# README.md + entities/ repositories/ utils/ loaders/ mapper.dart
│   ├── presentation/  # actions/ pages/ widgets/                 <-- new architecture
│   ├── platform/      # *_api.g.dart (pigeon output)
│   ├── extensions/    # 18 files: build_context_extensions.dart, theme_extensions.dart, …
│   ├── mixins/  models/  pages/  providers/  services/  widgets/  # LEGACY layers
│   ├── theme/{color_scheme,dynamic_theme,theme_data}.dart
│   ├── utils/
│   └── main.dart
└── test/
    ├── flutter_test_config.dart      # global test bootstrap (official flutter_test hook)
    ├── domain/  infrastructure/  presentation/  providers/  repositories/
    ├── drift/main/                   # generated drift schema helpers
    ├── medium/                       # "medium" tests: real DB, no widgets
    ├── fixtures/*.stub.dart
    └── mocks/
```

`mobile/lib/domain/README.md` (verbatim excerpt):

> This directory contains the domain layer of Immich. The domain layer is responsible for the business
> logic of the app. It includes interfaces for repositories, models, services and utilities.
> **This layer should never depend on anything from the presentation layer or from the infrastructure layer.**
> … The presentation layer should never directly use repositories, but instead interact with the domain
> layer through services.

`mobile/lib/infrastructure/README.md`:

> The infrastructure layer provides concrete implementations of repository interfaces defined in the
> domain layer. These implementations are exposed through Riverpod providers in the root `providers`
> directory. … The domain layer should never directly instantiate repository implementations, but
> instead receive them through dependency injection.

Sources: <https://github.com/immich-app/immich/blob/main/mobile/lib/domain/README.md>,
<https://github.com/immich-app/immich/blob/main/mobile/lib/infrastructure/README.md>

Immich's drift entities are **one file per table** with modular codegen output beside them:
`infrastructure/entities/local_asset.entity.dart` + `local_asset.entity.drift.dart`, plus raw
`.drift` SQL files (`merged_asset.drift`) where a query is easier in SQL.

Immich's file naming uses **dot-suffixes** (`user.model.dart`, `asset.service.dart`,
`local_album.repository.dart`, `drift_album.page.dart`). This is legal but it **violates Effective Dart**,
which says "DO name packages, directories, and source files using `lowercase_with_underscores`"
(<https://dart.dev/effective-dart/style>). Don't copy it — see §3.4.

**Barrels:** only 7 in the whole `mobile/lib/` tree. Effectively "no barrels".

### 1.5 `AppFlowy-IO/AppFlowy/frontend/appflowy_flutter` — explicit `lib/features/`

```
frontend/
├── appflowy_flutter/
│   ├── lib/
│   │   ├── ai/  core/  date/  env/  flutter/  shared/  startup/  user/  util/  workspace/
│   │   ├── features/                      <-- the NEW convention
│   │   │   ├── page_access_level/{data/repositories, logic/*_bloc|event|state.dart}
│   │   │   ├── settings/{data/{models,repositories}, logic/, settings.dart}
│   │   │   ├── share_tab/{data/{models,repositories}, logic/, presentation/{*.dart,widgets/}}
│   │   │   ├── shared_section/{data/repositories, logic/, models/, presentation/}
│   │   │   ├── view_management/{logic/}
│   │   │   └── workspace/{data/repositories, logic/}
│   │   ├── mobile/{application,presentation}   # platform-forked UI
│   │   ├── plugins/{document,database,ai_chat,trash,…}   # legacy "plugin" grouping
│   │   └── main.dart
│   ├── packages/{appflowy_backend, appflowy_popover, appflowy_result, appflowy_ui,
│   │             flowy_infra, flowy_infra_ui, flowy_svg}
│   ├── integration_test/  test/  assets/  build.yaml  dart_dependency_validator.yaml
├── resources/  rust-lib/  scripts/  Makefile.toml
```

The per-feature shape is `<feature>/{data/{models,repositories}, logic/, presentation/{widgets/}}` —
a **pure feature-first** slice. AppFlowy uses barrels liberally (`features/settings/settings.dart`,
`lib/ai/ai.dart`, `.../widgets/widgets.dart`). Note that `lib/features/` is new and coexists with a much
larger legacy `lib/plugins/` + `lib/workspace/` tree: a real-world reminder that **partial migrations are
normal and survivable**, but also that you pay for them forever.
Source: <https://github.com/AppFlowy-IO/AppFlowy/tree/main/frontend/appflowy_flutter/lib/features>

### 1.6 `very_good_cli` / `very_good_templates` — pure feature-first, with a stale-source trap

⚠ **Flag:** the repo `VeryGoodOpenSource/very_good_core` is **ARCHIVED** (last push 2024-02-21). So are
`very_good_flutter_package`, `very_good_dart_package`, `very_good_dart_cli`, `very_good_wear_app`,
`very_good_flame_game`, `mockingjay`, `r13n`, and the `very_good_coverage` GitHub Action. All templates
now live in the single active repo **`VeryGoodOpenSource/very_good_templates`** (pushed 2026-07-27).
If you find a blog post pointing at `very_good_core`, it is out of date.

`very_good_core/__brick__` output (from the brick's own README, matching the actual `__brick__` tree):

```
├── analysis_options.yaml
├── l10n.yaml
├── lib
│   ├── app/{app.dart, view/app.dart}
│   ├── bootstrap.dart
│   ├── counter/{counter.dart, cubit/counter_cubit.dart, view/counter_page.dart}
│   ├── l10n/{arb/app_en.arb, arb/app_es.arb, l10n.dart}
│   ├── main_development.dart  main_production.dart  main_staging.dart
├── pubspec.yaml
├── test/{app/view, counter/{cubit,view}, helpers/{helpers.dart, pump_app.dart}}
├── android ios macos web windows
```

Real `l10n.yaml` from the brick — note `output-dir`, and the `header` hack to keep the formatter off
generated code:

```yaml
arb-dir: lib/l10n/arb
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n/gen
nullable-getter: false

# Needed to ensure the formatter does not run on the generated files.
# See https://github.com/dart-lang/dart_style/issues/864 for more information
header: "// dart format off\n// coverage:ignore-file"
```

Real `lib/l10n/l10n.dart` — a **one-line barrel plus a context extension**, the single most-copied
2-liner in Flutter:

```dart
import 'package:flutter/widgets.dart';
import 'package:my_app/l10n/gen/app_localizations.dart';

export 'package:my_app/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
```

Real `test/helpers/pump_app.dart` — this is where locale-aware widget/golden testing starts:

```dart
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: widget,
      ),
    );
  }
}
```

And crucially, `brick.yaml` now has a first-class `workspace` variable:

```yaml
  workspace:
    type: boolean
    description: >-
      Whether the generated project should resolve its dependencies from a
      parent Pub workspace.
    default: false
```

which emits `resolution: workspace` into the app's pubspec. **VGV has officially blessed pub workspaces.**
Sources: <https://github.com/VeryGoodOpenSource/very_good_templates/tree/main/very_good_core>

### 1.7 `saber-notes/saber` — the closest analogue to our app

Offline-first, heavy `CustomPainter` canvas, PDF import, 20+ locales including **ar / fa / he (RTL)**,
and real golden tests.

```
saber/
├── lib/
│   ├── components/{canvas,editor,files,home,misc,navbar,nextcloud,settings,theming,toolbar}
│   ├── data/{codecs,editor,extensions,file_manager,nextcloud,sentry,tools,
│   │         prefs.dart, routes.dart, locales.dart, flavor_config.dart, version.dart}
│   ├── i18n/{en.i18n.yaml … ar.i18n.yaml, strings.g.dart, strings_ar.g.dart, …}
│   ├── pages/
│   └── main.dart
├── packages/{onyxsdk_pen/, sbn/}     # sbn = pure-Dart file-format package
├── assets/  assets_raw/  shaders/  submodules/  patches/  metadata/
├── test/
│   ├── goldens/*.png                 # ALL goldens in one flat dir
│   ├── *_test.dart                   # flat: login_golden_test.dart, home_theme_test.dart, …
│   └── utils/test_user.dart
├── slang.yaml  analysis_options.yaml  pubspec.yaml
```

Real golden test (`test/login_golden_test.dart`, abridged):

```dart
import 'package:golden_screenshot/golden_screenshot.dart';

final _device = GoldenSmallDevices.iphone.device;

for (final step in LoginStep.values) {
  testGoldens(step.name, (tester) async {
    final app = _LoginApp(step);
    await tester.pumpWidget(app);
    await tester.loadAssets();
    await tester.pumpFrames(app, const Duration(seconds: 1));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/login_page_${step.name}.png'),
    );
  });
}
```

Two structural lessons: (a) golden paths are **relative to the test file's directory**, so a flat
`test/goldens/` only works because the tests themselves sit in `test/`; (b) `assets_raw/` (source SVG/AI)
is kept separate from `assets/` (what actually ships).
Source: <https://github.com/saber-notes/saber/blob/main/test/login_golden_test.dart>

### 1.8 `KRTirtho/spotube` and `simolus3/drift/examples/app` — drift conventions

Spotube (47.9k ★): `l10n.yaml` at project root, ARB in `lib/l10n/*.arb` → `lib/l10n/generated/`;
`drift_schemas/` at project root; `test/drift/app_db/{generated/schema_v1..v10.dart, migration_test.dart}`;
`lib/provider/database/` for the drift providers; `lib/{collections,components,extensions,hooks,modules,
pages,provider,services,utils}`.

drift's own `examples/app` (written by the drift maintainer):

```
examples/app/
├── build.yaml
├── drift_schemas/default/drift_schema_v1..v3.json
├── lib/
│   ├── database/
│   │   ├── connection/{connection.dart, native.dart, web.dart, unsupported.dart}
│   │   ├── database.dart  database.g.dart  database.steps.dart
│   │   ├── sql.drift
│   │   └── tables.dart
│   ├── screens/{home.dart, home/{card,drawer,state,todo_edit_dialog}.dart, backup/, search.dart}
│   └── main.dart
├── test/{database_test.dart, drift/default/{generated/schema*.dart, migration_test.dart}}
└── tool/builder.dart
```

Copy this verbatim for the DB folder: **`tables.dart` separate from `database.dart`, a `connection/`
subfolder with conditional-import files, `.steps.dart` committed, schema JSON snapshots committed under
`drift_schemas/<db-name>/`, and generated migration test helpers under `test/drift/<db-name>/generated/`.**
Immich uses the identical `drift_schemas/main/` + `test/drift/main/` naming, so this is now the de-facto
standard for multi-DB drift projects — and it is *named per database*, which matters because we have two.
Source: <https://github.com/simolus3/drift/tree/develop/examples/app>

### 1.9 `flutter/flutter/packages/flutter/lib` — the canonical barrel layout

```
packages/flutter/lib/
├── animation.dart  cupertino.dart  foundation.dart  gestures.dart  material.dart
├── painting.dart   physics.dart    rendering.dart   scheduler.dart semantics.dart
├── services.dart   widgets.dart    widget_previews.dart
└── src/{animation,cupertino,foundation,gestures,material,painting,…}/
```

`lib/material.dart` is literally nothing but a doc comment and ~300 `export 'src/material/*.dart';` lines.
This is the **only** barrel pattern I recommend: a *package* exposes one entrypoint library per public
surface, and hides implementation under `lib/src/`. Dart's package layout spec backs this: "The libraries
inside `lib` are publicly visible… Users should never import from another package's `lib/src` directory."
Sources: <https://github.com/flutter/flutter/blob/master/packages/flutter/lib/material.dart>,
<https://dart.dev/tools/pub/package-layout>

---

## 2. Feature-first vs layer-first — the direct answer

### 2.1 What real projects actually do

| Repo | Grouping | Shape |
|---|---|---|
| **flutter/samples compass_app** | **Hybrid** | UI feature-first (`ui/<feature>/{view_models,widgets}`); data layer-first (`data/repositories/<entity>/`, `data/services/`); `domain/models` flat |
| localsend | **Layer-first** | `pages/ provider/ model/ util/ widget/ config/` |
| immich (new code) | **Layer-first with a clean-arch split** | `domain/ infrastructure/ presentation/` + root `providers/` |
| immich (legacy) | Layer-first | `models/ pages/ providers/ services/ widgets/` |
| AppFlowy (new code) | **Feature-first** | `features/<feature>/{data,logic,presentation}` |
| very_good_core | **Feature-first** | `lib/<feature>/{cubit,view}` + `lib/app/`, `lib/l10n/` |
| saber | Layer-first | `components/ data/ pages/ i18n/` |
| spotube | Layer-first | `pages/ provider/ services/ components/ modules/ extensions/ hooks/ utils/` |
| drift example | Layer-first (tiny) | `database/ screens/` |

Score: 2 feature-first, 5 layer-first, 1 explicit hybrid. **Layer-first is what most large real apps
actually ship** — but note that every one of those layer-first apps has a `pages/<feature>/` or
`providers/<feature>/` sub-grouping inside the layer, i.e. they converge on the hybrid anyway.

### 2.2 What Flutter's official guidance says

From <https://docs.flutter.dev/app-architecture/case-study>, the *recommended* tree, verbatim:

```
lib/
├── ui/
│   ├── core/
│   │   ├── ui/
│   │   │   └── <shared widgets>
│   │   └── themes/
│   └── <FEATURE NAME>/
│       ├── view_model/
│       │   └── <view_model class>.dart
│       └── widgets/
│           ├── <feature name>_screen.dart
│           └── <other widgets>
├── domain/
│   └── models/
│       └── <model name>.dart
├── data/
│   ├── repositories/
│   │   └── <repository class>.dart
│   ├── services/
│   │   └── <service class>.dart
│   └── model/
│       └── <api model class>.dart
├── config/
├── utils/
├── routing/
├── main_staging.dart
├── main_development.dart
└── main.dart
```

And the stated rule for *why* it's hybrid:

> "Data layer objects (repositories and services) aren't tied to a single feature, while UI layer objects
> (views and view models) are."

The companion recommendations page (<https://docs.flutter.dev/app-architecture/recommendations>) adds:

- **"Use standardized naming conventions for classes, files and directories."** — `HomeViewModel`,
  `HomeScreen`, `UserRepository`, `ClientApiService`.
- **"Avoid names that confuse with Flutter SDK objects"** — explicitly: put shared widgets in `ui/core/`
  rather than `/widgets`.
- **"Use clearly defined data and UI layers."** (Strongly recommend)
- **"Use the repository pattern in the data layer."** / **"Use abstract repository classes."** (Strongly recommend)
- **"Do not put logic in widgets."** (Strongly recommend)
- **"Use a domain layer."** — *conditional*: "Only needed if your application has exceedingly complex
  logic crowding ViewModels, or if you repeat logic across ViewModels."

### 2.3 My recommendation for this app — firm

**Use the official hybrid, with the feature axis moved one level up so it also covers the data layer for
genuinely feature-owned data.** Concretely:

- `lib/ui/<feature>/{view_models,widgets}` — feature-first. Non-negotiable: this is where 80 % of the
  churn happens and feature-first is the only grouping that keeps a PR diff in one folder.
- `lib/data/{database,repositories,services}` — layer-first (by type). Rationale straight from the docs:
  our repositories are *not* feature-scoped. A `MeasurementRepository` will be read by the ruler screen,
  the history screen, and the PDF exporter. Sharding repositories by feature guarantees you'll be
  importing `../../ui/history/data/...` from the exporter within a month.
- `packages/<name>_domain/` — the rule engine leaves `lib/` entirely (see §4). This is *stronger* than
  the doc's `lib/domain/`: a separate package makes the "no Flutter imports" rule **compiler-enforced**,
  not a code-review convention.

**Do not use pure feature-first** for this app. Reasons specific to us: (a) the drift schema is one
physical artifact shared by every feature — it cannot live inside a feature folder; (b) six locales and a
shared ARB file force a global `l10n/`; (c) the custom-painted ruler and PDF exporter are cross-cutting
"capabilities", not features, and pure feature-first has no home for them except a junk-drawer `shared/`,
which is what AppFlowy's `lib/shared/` (30+ loose files) has become.

**Do not use pure layer-first** either. LocalSend's `lib/provider/` is 24 top-level files and folders with
no feature grouping; that only works because the app is one screen deep.

---

## 3. Where each kind of code goes

### 3.1 The rules

| Thing | Location | Why |
|---|---|---|
| Domain models (rule-engine types) | `packages/<name>_domain/lib/src/models/` | Shared with the CLI; no Flutter. |
| Reference-DB drift tables | `packages/<name>_reference_db/lib/src/tables/` | Written by the CLI, read by the app. Must be one schema definition, not two. |
| User-DB drift tables | `app/lib/data/database/user/tables.dart` | App-only. |
| Drift database classes | `app/lib/data/database/{user,reference}/database.dart` | Follows drift's own example. |
| Drift connection openers | `app/lib/data/database/<db>/connection.dart` | Isolates `drift_flutter` / asset-copy logic. |
| Repositories (abstract + impl) | `app/lib/data/repositories/<entity>_repository.dart` | Official guidance; not feature-scoped. |
| Platform services (camera, GPS, PDF, share) | `app/lib/data/services/<thing>_service.dart` | Thin wrappers over plugins so ViewModels stay testable. |
| Riverpod providers | **Next to what they provide**, not in a `providers/` folder | See §3.3. |
| ViewModels / Notifiers | `app/lib/ui/<feature>/view_models/<feature>_view_model.dart` | Official naming. |
| Screens | `app/lib/ui/<feature>/widgets/<feature>_screen.dart` | Official naming. |
| Feature-private widgets | `app/lib/ui/<feature>/widgets/` | Same folder as the screen. |
| Shared widgets | `app/lib/ui/core/ui/` | Official: *not* `lib/widgets/`. |
| Themes, colors, dimens, text styles | `app/lib/ui/core/themes/` | Official. |
| Custom painters (the ruler) | `app/lib/ui/core/painting/` if reusable, else `ui/ruler/widgets/` | Painters are UI, not utils. |
| Routing | `app/lib/routing/{router.dart,routes.dart}` | Official. |
| l10n ARB + generated | `app/lib/l10n/arb/` + `app/lib/l10n/gen/` | VGV template; §5.3. |
| `context.l10n` extension | `app/lib/l10n/l10n.dart` | VGV template. |
| Extensions | `app/lib/core/extensions/<type>_extensions.dart` | Immich's `extensions/` dir is the clearest real example (18 files, one per extended type). |
| Constants / enums | `app/lib/core/constants/` | Immich has `constants/{colors,enums,errors,locales,…}.dart`. |
| Utils (pure functions) | `app/lib/core/utils/` — and **prefer moving them into the domain package** | A util that doesn't import Flutter belongs in the domain package where the CLI can use it too. |
| DI wiring / bootstrapping | `app/lib/bootstrap.dart` + `app/lib/config/` | VGV `bootstrap.dart` + compass `config/dependencies.dart`. |
| Asset path constants | `app/lib/config/assets.dart` | compass_app does exactly this. |
| Entry points | `app/lib/main.dart` (+ flavors) | Official. |
| Test fakes/stubs | `app/testing/` (sibling of `test/`) | compass_app; keeps fakes out of coverage and lets `integration_test/` use them too. |
| Golden images | `app/test/goldens/` | §5.4. |

### 3.2 The complete annotated tree — create this verbatim

```
<repo-root>/
├── pubspec.yaml                     # WORKSPACE ROOT. name: _  publish_to: none  workspace: [...]
├── pubspec.lock                     # ONE lockfile for the whole repo (pub workspaces)
├── analysis_options.yaml            # include: package:analysis_defaults/dart.yaml  (root-level defaults)
├── .gitignore
├── README.md
├── AGENTS.md / CLAUDE.md            # LocalSend, Saber and VGV all ship one; put build commands here
│
├── app/                             # ── THE FLUTTER APP ──────────────────────────────
│   ├── pubspec.yaml                 #    resolution: workspace
│   ├── analysis_options.yaml        #    include: package:analysis_defaults/flutter.yaml
│   ├── l10n.yaml
│   ├── build.yaml                   #    drift_dev options (see §5.5)
│   ├── devtools_options.yaml
│   ├── .metadata
│   │
│   ├── android/                     #    generated by `flutter create`; never restructure
│   ├── ios/
│   │
│   ├── assets/                      #    ONLY what ships in the bundle
│   │   ├── db/
│   │   │   └── reference.sqlite     #    ← produced by tools/content_builder, committed or CI-built
│   │   ├── icons/                   #    .svg  (compiled by vector_graphics_compiler transformer)
│   │   ├── images/                  #    .png + 2.0x/ 3.0x/ variants
│   │   └── fonts/                   #    .ttf/.otf incl. an Arabic-capable face
│   ├── assets_raw/                  #    OPTIONAL: source .ai/.fig/unoptimised svg. NOT in pubspec.
│   │
│   ├── lib/
│   │   ├── main.dart                #    thin: WidgetsFlutterBinding + bootstrap()
│   │   ├── bootstrap.dart           #    error handlers, DB open, ProviderScope overrides, runApp
│   │   │
│   │   ├── config/
│   │   │   ├── assets.dart          #    class Assets { static const rulerTicks = 'assets/icons/…'; }
│   │   │   ├── app_config.dart      #    compile-time flags (const from --dart-define)
│   │   │   └── providers.dart       #    the few root overrides passed to ProviderScope
│   │   │
│   │   ├── core/                    #    cross-cutting, framework-y, feature-agnostic
│   │   │   ├── constants/
│   │   │   │   ├── locales.dart     #    const supportedLocales, rtlLocales
│   │   │   │   └── durations.dart
│   │   │   ├── extensions/
│   │   │   │   ├── build_context_extensions.dart
│   │   │   │   ├── datetime_extensions.dart
│   │   │   │   └── iterable_extensions.dart
│   │   │   ├── logging/logger.dart
│   │   │   └── result.dart          #    sealed class Result<T> (Dart 3 sealed + patterns)
│   │   │
│   │   ├── data/                    #    LAYER-FIRST. no Flutter widgets in here.
│   │   │   ├── database/
│   │   │   │   ├── reference/
│   │   │   │   │   ├── connection.dart      #  copies asset → app-support dir, opens READ-ONLY
│   │   │   │   │   └── reference_database.dart
│   │   │   │   │       (+ reference_database.g.dart, generated)
│   │   │   │   ├── user/
│   │   │   │   │   ├── connection.dart      #  drift_flutter driftDatabase(name: 'user')
│   │   │   │   │   ├── tables.dart
│   │   │   │   │   ├── user_database.dart
│   │   │   │   │   ├── user_database.g.dart
│   │   │   │   │   └── user_database.steps.dart   # committed; drift step-by-step migrations
│   │   │   │   └── converters/              #  TypeConverter<Enum,int> etc.
│   │   │   ├── repositories/
│   │   │   │   ├── measurement_repository.dart          # abstract + Drift impl in ONE file,
│   │   │   │   │                                        # OR split _local/_fake like compass_app
│   │   │   │   ├── reference_repository.dart
│   │   │   │   └── settings_repository.dart
│   │   │   └── services/
│   │   │       ├── camera_service.dart
│   │   │       ├── location_service.dart    #  single-shot GPS
│   │   │       ├── pdf_export_service.dart
│   │   │       ├── file_service.dart        #  path_provider wrapper
│   │   │       └── share_service.dart
│   │   │
│   │   ├── l10n/
│   │   │   ├── arb/
│   │   │   │   ├── app_en.arb       #    template
│   │   │   │   ├── app_ar.arb       #    RTL
│   │   │   │   ├── app_fr.arb  app_es.arb  app_de.arb  app_tr.arb
│   │   │   ├── gen/                 #    GENERATED — committed or gitignored, pick one and be consistent
│   │   │   │   ├── app_localizations.dart
│   │   │   │   └── app_localizations_*.dart
│   │   │   └── l10n.dart            #    export gen + `extension AppLocalizationsX on BuildContext`
│   │   │
│   │   ├── routing/
│   │   │   ├── routes.dart          #    path constants only, no widgets
│   │   │   └── router.dart          #    GoRouter instance
│   │   │
│   │   └── ui/                      #    FEATURE-FIRST
│   │       ├── core/
│   │       │   ├── themes/{colors.dart, dimens.dart, text_styles.dart, theme.dart}
│   │       │   ├── painting/{ruler_painter.dart, tick_geometry.dart}
│   │       │   └── ui/              #    shared widgets: app_scaffold.dart, error_indicator.dart,
│   │       │                        #    loading_indicator.dart, svg_icon.dart, empty_state.dart
│   │       ├── home/
│   │       │   ├── view_models/home_view_model.dart
│   │       │   └── widgets/{home_screen.dart, home_header.dart}
│   │       ├── ruler/
│   │       │   ├── view_models/ruler_view_model.dart
│   │       │   └── widgets/{ruler_screen.dart, ruler_canvas.dart, ruler_readout.dart}
│   │       ├── capture/             #    camera
│   │       ├── history/
│   │       ├── export/              #    PDF
│   │       └── settings/
│   │
│   ├── test/                        #    MIRRORS lib/ 1:1
│   │   ├── flutter_test_config.dart #    global bootstrap (silence logs, load fonts once)
│   │   ├── core/
│   │   ├── data/
│   │   │   ├── database/user_database_test.dart
│   │   │   └── repositories/measurement_repository_test.dart
│   │   ├── drift/
│   │   │   └── user/
│   │   │       ├── generated/schema.dart, schema_v1.dart, …   # `drift_dev schema generate`
│   │   │       └── migration_test.dart
│   │   ├── ui/<feature>/…_test.dart
│   │   ├── goldens/                 #    all .png goldens, named <widget>_<locale>_<theme>.png
│   │   └── golden/                  #    the golden TESTS themselves (…_golden_test.dart)
│   │
│   ├── testing/                     #    NOT under test/. Fakes shared by test/ AND integration_test/
│   │   ├── fakes/repositories/fake_measurement_repository.dart
│   │   ├── fakes/services/fake_location_service.dart
│   │   ├── models/…                 #    canned domain objects
│   │   └── pump_app.dart            #    WidgetTester extension with locale + theme params
│   │
│   ├── integration_test/
│   │   └── app_test.dart
│   └── drift_schemas/
│       └── user/drift_schema_v1.json …      # committed schema snapshots, one dir PER DATABASE
│
├── packages/                        # ── PURE-DART / SHARED CODE ─────────────────────
│   ├── <name>_domain/               #    THE RULE ENGINE. Zero Flutter. Zero drift.
│   │   ├── pubspec.yaml             #    resolution: workspace
│   │   ├── analysis_options.yaml    #    include: package:analysis_defaults/dart.yaml
│   │   ├── lib/
│   │   │   ├── <name>_domain.dart   #    THE barrel: export 'src/…';  (legit here — public API)
│   │   │   └── src/
│   │   │       ├── models/          #    sealed classes + pattern matching
│   │   │       ├── rules/           #    the engine
│   │   │       └── evaluation/
│   │   └── test/
│   │
│   ├── <name>_reference_db/         #    drift schema for the READ-ONLY DB. Pure Dart.
│   │   ├── pubspec.yaml             #    deps: drift, sqlite3   (NO flutter)
│   │   ├── build.yaml
│   │   ├── lib/
│   │   │   ├── <name>_reference_db.dart          # barrel
│   │   │   └── src/
│   │   │       ├── tables.dart
│   │   │       ├── reference_database.dart
│   │   │       └── reference_database.g.dart
│   │   └── test/
│   │
│   └── analysis_defaults/           #    NO CODE. lint config only. Copied from flutter/samples.
│       ├── pubspec.yaml
│       └── lib/{dart.yaml, flutter.yaml}
│
└── tools/
    └── content_builder/             #    THE CLI. Builds app/assets/db/reference.sqlite.
        ├── pubspec.yaml             #    resolution: workspace
        ├── bin/content_builder.dart #    entrypoint: `dart run content_builder`
        ├── lib/src/…                #    csv/yaml → domain → drift inserts
        ├── data/                    #    the human-edited source content (csv/yaml/json)
        └── test/
```

### 3.3 Riverpod-specific: where do providers go?

**No `lib/providers/` folder.** Put each provider in the file of the thing it provides.

Evidence and reasoning:
- I found **no official Riverpod guidance on folder structure**. `rrousselGit/riverpod`'s own
  `examples/pub` is flat (`lib/{main,search,detail,pub_repository}.dart` + `lib/pub_ui/`) and
  `examples/marvel` is `lib/src/{screens,widgets}` + loose files. Verified by tree; **no evidence found**
  that Riverpod prescribes a structure.
- The two large Riverpod apps I read both use a global `provider(s)/` directory — LocalSend
  `app/lib/provider/` (24 entries) and Immich `mobile/lib/providers/` (~40 entries) — and in **both**
  it has visibly become the largest, least-navigable folder in the repo. Immich's own
  `infrastructure/README.md` even says implementations "are exposed through Riverpod providers in the
  root `providers` directory", i.e. they've institutionalised the junk drawer.
- With `riverpod_generator`, the provider is a `@riverpod` annotation on the class/function itself, so
  physically separating it is impossible without an extra indirection file.

So:
```dart
// app/lib/data/repositories/measurement_repository.dart
@riverpod
MeasurementRepository measurementRepository(Ref ref) =>
    DriftMeasurementRepository(ref.watch(userDatabaseProvider));
```
and the ViewModel provider lives in `ui/ruler/view_models/ruler_view_model.dart`. One import path per
concept.

**Note on official docs vs our stack:** `docs.flutter.dev/app-architecture/recommendations` says
"Use dependency injection" and names **`provider`** as the recommended package. That reflects
compass_app's implementation choice, and the same page/companion pages explicitly allow
`riverpod`/`flutter_bloc`/`signals` as substitutes. Use `flutter_riverpod` (3.4.1, published
2026-07-26 — very much alive) and keep the *structure*; ignore the package name.

### 3.4 File naming — pick one and lint it

- **Rule:** `lowercase_with_underscores` for files and directories. Effective Dart, verbatim:
  "DO name packages, directories, and source files using `lowercase_with_underscores`."
  (<https://dart.dev/effective-dart/style>)
- **Type suffix goes in the name, separated by `_`:** `measurement_repository.dart`,
  `ruler_view_model.dart`, `location_service.dart`, `home_screen.dart`.
  This matches `docs.flutter.dev/app-architecture/recommendations`: "Use standardized naming conventions
  for classes, files and directories" (`HomeViewModel`, `HomeScreen`, `UserRepository`, `ClientApiService`).
- **Genuine disagreement:** Immich (108k ★) uses `user.model.dart` / `asset.service.dart` /
  `local_album.repository.dart`. It sorts beautifully in a file tree and greps trivially
  (`ls *.repository.dart`). But it breaks Effective Dart, confuses tooling that splits on `.`
  (e.g. anything that assumes `foo.g.dart` means "generated from foo"), and — decisively — **collides
  with build_runner's own convention**: drift emits `x.drift.dart` and `x.g.dart`, so
  `user.model.dart` + `user.model.g.dart` gets genuinely ambiguous.
  **Recommendation: use underscores.** The greppability win is real but not worth fighting codegen.
- Flutter's official guidance also says: name the ViewModel file after the screen it drives, and
  **avoid `lib/widgets/`** — "put shared widgets in `ui/core/` rather than `/widgets`" — because
  `widgets` collides with `package:flutter/widgets.dart` in the reader's head.

---

## 4. Local packages vs folders — and the exact wiring for our domain package + CLI

### 4.1 When to split into a package (my rule, backed by what the repos do)

Split into a separate package **only** when at least one is true:

1. **A different toolchain must consume it.** Our rule engine is consumed by `flutter test` *and* by
   `dart run`. A Dart CLI cannot import a library that transitively imports `package:flutter`. Making it
   a package with no Flutter dependency makes "no Flutter imports" a **compile error**, not a lint.
   → This alone justifies `packages/<name>_domain/`.
2. **Two entrypoints must agree on a binary artifact.** The CLI *writes* `reference.sqlite`; the app
   *reads* it. If the schema is defined twice, they will drift apart. One package, one drift schema.
   → justifies `packages/<name>_reference_db/`.
3. **You want to enforce a dependency direction.** `dependency_validator` /
   AppFlowy's `dart_dependency_validator.yaml` exist precisely for this. A package boundary is the only
   boundary Dart actually enforces.
4. **It's genuinely reusable and you'd publish it one day** (Saber's `packages/sbn` file-format package,
   LocalSend's `packages/typed_isolates`, Immich's `mobile/packages/ui`).

**Do NOT** split into packages for: "feature modularity", "faster builds", "clean architecture points".
None of the audited apps has a package-per-feature. AppFlowy has 7 packages for 74k stars of code and
they are all *infrastructure* (`flowy_svg`, `appflowy_result`, `appflowy_ui`), never features.
Package boundaries cost you: a pubspec to maintain, a `build_runner` invocation, an
`analysis_options.yaml`, and cross-package refactors that your IDE does worse.

### 4.2 Pub workspaces vs melos — use pub workspaces

**Pub workspaces** (Dart ≥ 3.6, `dart.dev/tools/pub/workspaces`) give you: a **single root
`pubspec.lock`**, a **single root `.dart_tool/package_config.json`**, one `dart pub get` for everything,
lower analyzer memory, and automatic local resolution of interdependent packages.

Evidence they've won:
- **`flutter/samples` is a pub workspace** with 38 members (see §1.2). Google's own sample monorepo.
- **`firebase/flutterfire` migrated to a pub workspace** — its root `pubspec.yaml` is
  `name: flutterfire_workspace` with a `workspace:` list of ~100 packages, and the melos config now lives
  under a `melos:` key *inside that same pubspec*, not in `melos.yaml`.
- GitHub code search for `"resolution: workspace" filename:pubspec.yaml` returns **2,772** files.
- VGV's `very_good_core` brick has a first-class `workspace` boolean (§1.6).
- Melos itself now tells you to set up pub workspaces first: "in all your packages `pubspec.yaml` files,
  add the `resolution: workspace` field" (<https://melos.invertase.dev/getting-started>).

**Melos (8.2.2, published 2026-07-13 — actively maintained)** is still useful, but only for what pub
workspaces don't do: running a command across all packages (`melos exec`), conventional-commit versioning,
and multi-package publishing. **We need none of those.** Skip melos; add it later in 10 minutes if you
ever want `melos run test:all`.

### 4.3 The exact wiring — copy these files

**`<repo-root>/pubspec.yaml`** (the workspace root; it is a package that contains no code):

```yaml
name: _
publish_to: none

environment:
  sdk: ^3.12.0

workspace:
  - app
  - packages/analysis_defaults
  - packages/myapp_domain
  - packages/myapp_reference_db
  - tools/content_builder
```

> Glob syntax (`workspace: ['packages/*']`) requires Dart ≥ 3.11 per dart.dev; with Dart 3.12 you may use
> it, but an explicit list is self-documenting and I'd keep it.

**`packages/myapp_domain/pubspec.yaml`** — the pure-Dart rule engine:

```yaml
name: myapp_domain
description: Offline rule engine. No Flutter, no I/O, no drift.
version: 0.1.0
publish_to: none
resolution: workspace

environment:
  sdk: ^3.12.0

dependencies:
  collection: ^1.19.1
  meta: ^1.16.0

dev_dependencies:
  analysis_defaults:
    path: ../analysis_defaults
  test: ^1.25.0
```

`packages/myapp_domain/analysis_options.yaml`:

```yaml
include: package:analysis_defaults/dart.yaml
```

`packages/myapp_domain/lib/myapp_domain.dart` — the one barrel that is a good idea:

```dart
/// Offline rule engine shared by the app and the content build tool.
library;

export 'src/models/measurement.dart';
export 'src/models/rule.dart';
export 'src/rules/rule_engine.dart';
```

(Pattern verified from `flutter/flutter/packages/flutter/lib/material.dart` and from VGV's
`very_good_dart_package` brick, whose `lib/{{project_name}}.dart` is literally
`library;` + `export 'src/{{project_name}}.dart';`.)

**`packages/myapp_reference_db/pubspec.yaml`** — drift, but pure Dart:

```yaml
name: myapp_reference_db
description: Drift schema for the read-only pre-seeded reference database.
version: 0.1.0
publish_to: none
resolution: workspace

environment:
  sdk: ^3.12.0

dependencies:
  drift: ^2.34.2          # verified pure Dart: deps are async, convert, collection, meta,
                          # stream_channel, sqlite3, path, stack_trace, web — NO flutter
  myapp_domain:
    path: ../myapp_domain
  sqlite3: ^3.5.0

dev_dependencies:
  analysis_defaults:
    path: ../analysis_defaults
  build_runner: ^2.4.14
  drift_dev: ^2.34.2
  test: ^1.25.0
```

**`tools/content_builder/pubspec.yaml`** — the CLI:

```yaml
name: content_builder
description: Builds app/assets/db/reference.sqlite from tools/content_builder/data/.
version: 0.1.0
publish_to: none
resolution: workspace

environment:
  sdk: ^3.12.0

dependencies:
  args: ^2.6.0
  csv: ^6.0.0
  drift: ^2.34.2
  myapp_domain:
    path: ../../packages/myapp_domain
  myapp_reference_db:
    path: ../../packages/myapp_reference_db
  path: ^1.9.1
  sqlite3: ^3.5.0

dev_dependencies:
  analysis_defaults:
    path: ../../packages/analysis_defaults
  test: ^1.25.0
```

Run it with `dart run content_builder --out ../../app/assets/db/reference.sqlite`, or from the repo root
`dart run tools/content_builder/bin/content_builder.dart`. This mirrors `flutter/samples`'s own
`tool/` package (`name: repo_tool`, `resolution: workspace`, deps `args/io/path/yaml/yaml_edit`) and the
`asset_transformation/grayscale_transformer` package (`bin/grayscale_transformer.dart`,
`resolution: workspace`, deps `args`+`image`, **wired into the app as a `dev_dependency` path package**).

**`app/pubspec.yaml`** (excerpt):

```yaml
name: myapp
publish_to: none
version: 0.1.0
resolution: workspace

environment:
  sdk: ^3.12.0
  flutter: ^3.44.0

dependencies:
  drift: ^2.34.2
  drift_flutter: ^0.3.1        # published 2026-07-11; the Flutter glue (path_provider +
                               # sqlite3_flutter_libs). Keep it OUT of the pure-Dart packages.
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^3.4.1
  flutter_svg: ^2.2.4
  intl: any
  myapp_domain:
    path: ../packages/myapp_domain
  myapp_reference_db:
    path: ../packages/myapp_reference_db

dev_dependencies:
  analysis_defaults:
    path: ../packages/analysis_defaults
  build_runner: ^2.4.14
  drift_dev: ^2.34.2
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

flutter:
  generate: true               # REQUIRED for gen-l10n
  uses-material-design: true
  assets:
    - assets/db/reference.sqlite
    - assets/images/
    - path: assets/icons/
      transformers:
        - package: vector_graphics_compiler
  fonts:
    - family: AppSans
      fonts:
        - asset: assets/fonts/AppSans-Regular.ttf
        - asset: assets/fonts/AppSans-Bold.ttf
          weight: 700
```

> The `transformers:` syntax above is copied from a **real** Flutter sample, not from prose:
> `flutter/samples/asset_transformation/pubspec.yaml` declares
> `- path: assets/svg.svg` / `transformers:` / `- package: vector_graphics_compiler`.
> Source: <https://github.com/flutter/samples/blob/main/asset_transformation/pubspec.yaml>

**Directory-entry gotcha:** in `flutter: assets:`, a directory entry is **not recursive** —
"Only files located directly in the directory are included. Resolution-aware asset image variants are the
only exception." So `assets/images/` picks up `assets/images/2.0x/foo.png` but **not**
`assets/images/onboarding/bar.png`. One entry per directory.
Source: <https://docs.flutter.dev/ui/assets/assets-and-images>

---

## 5. Assets, fonts, ARB, goldens, platform folders

### 5.1 Platform folders

`android/`, `ios/` stay exactly where `flutter create` puts them: at the root of the **app package**
(`app/android`, `app/ios`), never at the workspace root. Every single audited repo does this
(compass_app/app, mobile/, app/, appflowy_flutter/). Do not hand-restructure them; upgrade paths
(`flutter create --platforms=...`) assume the default layout.

Flavors: VGV puts flavor-specific Android resources in `android/app/src/{development,staging,main}/res/`
and separate Xcode schemes — verified in the `very_good_core` brick tree. If you don't need flavors
(we probably don't for a fully offline app), skip it; it's ~40 extra files.

### 5.2 Assets and fonts

- `app/assets/` at the app package root — universal across all audited repos.
- Group by kind (`icons/`, `images/`, `fonts/`, `db/`), not by feature. Every audited repo does kind-based.
- **Keep sources out of the bundle.** Saber's `assets_raw/` vs `assets/` split is the cleanest example
  I saw; Immich keeps both `.svg` and `.png` of its logo in `assets/`, which ships dead bytes.
- Ship the pre-seeded DB as `assets/db/reference.sqlite`. It must be listed in `pubspec.yaml`
  individually or via its directory. At runtime copy it out of the bundle to the app-support directory
  once (sqlite cannot open the read-only bundle path directly on either platform), then open it read-only.
- **Cold start (<1.2 s budget):** every entry in `flutter: assets:` grows `AssetManifest.bin`. Prefer a
  handful of directory entries. Precompile SVGs with `vector_graphics_compiler` (the transformer above)
  so `flutter_svg` doesn't parse XML at runtime — this is a first-frame cost you can delete for free.
- Generated asset constants: LocalSend uses `lib/gen/assets.gen.dart` and Spotube
  `lib/collections/assets.gen.dart` (both from `flutter_gen`). compass_app hand-writes
  `lib/config/assets.dart`. For a small asset set, hand-write it — one fewer codegen step, and
  `flutter_gen`'s runtime package has a history of being confused with the (now-dead) l10n synthetic
  `package:flutter_gen`.

### 5.3 l10n / ARB — and one piece of very stale advice to delete

**Layout (recommended):**
```
app/l10n.yaml
app/lib/l10n/arb/app_{en,ar,fr,es,de,tr}.arb
app/lib/l10n/gen/app_localizations{,_ar,_de,…}.dart      # generated
app/lib/l10n/l10n.dart                                   # export + context.l10n extension
```

`app/l10n.yaml`:
```yaml
arb-dir: lib/l10n/arb
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n/gen
output-class: AppLocalizations
nullable-getter: false
header: "// dart format off\n// coverage:ignore-file"
```
(Copied from the live VGV `very_good_core` brick.)

**Defaults, verified from flutter_tools source, not from a blog:**
`packages/flutter_tools/lib/src/commands/generate_localizations.dart` line 242 —
`final String defaultArbDir = _fileSystem.path.join('lib', 'l10n');` and `--output-dir` help text:
"If unspecified, this defaults to the same directory as the input directory specified in `--arb-dir`."
<https://github.com/flutter/flutter/blob/master/packages/flutter_tools/lib/src/commands/generate_localizations.dart>

🚨 **STALE ADVICE — DELETE ON SIGHT:** `import 'package:flutter_gen/gen_l10n/app_localizations.dart';`
and `synthetic-package: true`. The synthetic package was deprecated in Flutter 3.28.0-0.0.pre / stable
3.32.0 and is now dead: in current flutter_tools the flag's help string is literally
`'DEPRECATED. This flag cannot be enabled and should be removed.'` (same file, line 46).
Note that the *published guide page*
<https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization> still describes
`synthetic-package` as defaulting to `true` — **that page is out of date; the source is not.**
Migration doc: <https://docs.flutter.dev/release/breaking-changes/flutter-generate-i10n-source>.
You must have `flutter: generate: true` in `pubspec.yaml`.

**Arabic / RTL structural notes:**
- Nothing in the folder layout changes for RTL. `Directionality` comes from `MaterialApp`'s locale.
- Put `EdgeInsetsDirectional` / `AlignmentDirectional` usage under lint pressure, not folder pressure.
- Keep an `app/lib/core/constants/locales.dart` with `const supportedLocales` used by **both**
  `MaterialApp` and the golden-test parameter list, so a new locale can't be added to one and not the other.
- **Locale-aware assets:** if the ruler needs Eastern-Arabic numerals or a different tick font, add an
  `assets/fonts/` face rather than a per-locale asset folder — Flutter has no locale-based asset
  resolution (only resolution-based `2.0x/`).

### 5.4 Golden files

**Where they land:** `matchesGoldenFile(<path>)` resolves `<path>` relative to the **directory of the
test file** (via the ambient `goldenFileComparator`, a `LocalFileComparator` seeded with the test's URI —
see `packages/flutter_test/lib/src/_matchers_io.dart`). Verified empirically: Saber's tests live at
`test/*_test.dart`, call `matchesGoldenFile('goldens/login_page_done.png')`, and the files are at
`test/goldens/*.png`.

**Recommended layout for us (6 locales × light/dark):**
```
app/test/
├── flutter_test_config.dart        # loads fonts once, silences logs — runs before EVERY test file
├── golden/
│   ├── ruler_screen_golden_test.dart
│   └── home_screen_golden_test.dart
└── goldens/
    ├── ruler_screen_en_light.png
    ├── ruler_screen_ar_light.png
    └── …
```
With tests in `test/golden/`, reference goldens as `matchesGoldenFile('../goldens/ruler_screen_${locale}_light.png')`.
If you'd rather not have the `../`, flatten and put the golden tests directly in `test/` like Saber does.

**`flutter_test_config.dart` is a real, official flutter_test/flutter_tools feature** (handled by
`packages/flutter_tools/lib/src/test/test_config.dart`) — it's the only sanctioned place for
"run this before every test file in this directory subtree". Immich uses it exactly this way:

```dart
// immich mobile/test/flutter_test_config.dart
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Logger.root.level = Level.OFF;
  EasyLocalization.logger.enableBuildModes = [];
  debugPrint = (String? message, {int? wrapWidth}) {};
  return testMain();
}
```
Use ours to load the Arabic-capable font into the test font manifest — otherwise Arabic goldens render as
boxes.

**Tooling — check the dates:**
- ❌ `golden_toolkit` — **last published 2023-02-21 (v0.15.0)**; its repo `eBay/flutter_glove_box` last
  pushed 2024-09-13. **Effectively abandoned. Do not adopt.**
- ✅ `alchemist` (Betterment) — 0.14.0, published **2026-03-13**. Maintained.
- ✅ `golden_screenshot` (adil192 — the Saber maintainer, i.e. the author of the code I read) — 11.0.1,
  published **2026-03-20**. Device frames + `loadAssets()`. Good if you also want store screenshots.
- ✅ **Plain `flutter_test` + `matchesGoldenFile`** — zero dependencies, and it is what Saber's actual
  test file uses for the `expectLater`. For 6 locales × a handful of screens this is enough.
  My recommendation: start with plain `matchesGoldenFile` + your own `pumpApp(locale:, theme:)` helper in
  `app/testing/pump_app.dart`; add `alchemist` only if CI-vs-local font rendering becomes a problem.

### 5.5 drift-specific files

```
app/build.yaml                       # drift_dev options
app/drift_schemas/user/drift_schema_v1.json …
app/test/drift/user/generated/schema*.dart
app/test/drift/user/migration_test.dart
```
`drift_schemas/<db-name>/` and `test/drift/<db-name>/generated/` are the names used by **both**
drift's own example (`default`) and Immich (`main`) and Spotube (`app_db`). Because we have two databases,
name the directories `user/` and `reference/` explicitly. The reference DB is read-only and ships
pre-built, so it needs a schema snapshot but not a migration test; the user DB needs both.

Keep `database.steps.dart` committed (drift's step-by-step migration helper) — the drift example does.

---

## 6. Barrel files (`index.dart` / `foo.dart` re-exports)

### What real repos do — counted, not guessed

| Repo | Barrels in app `lib/` |
|---|---|
| flutter/samples compass_app | **0** |
| localsend `app/lib` | **0** |
| immich `mobile/lib` | **7** total (`constants/constants.dart`, `widgets/photo_view/photo_view.dart`, 4 settings widget groups) |
| drift `examples/app` | **0** |
| saber | **0** |
| very_good_core template | one per feature, 1–2 lines (`counter/counter.dart` = 2 exports; `app/app.dart` = 1 export) |
| AppFlowy | **many** (`features/settings/settings.dart`, `lib/ai/ai.dart`, `…/widgets/widgets.dart`) |
| flutter/flutter `packages/flutter` | **13** — one public library per surface, all re-exporting `lib/src/` |

### Verdict

**Do not use barrel files inside the app's `lib/`. Do use exactly one barrel per shared package.**

Why (reasons, not rules):

1. **Barrels break `prefer_relative_imports` and confuse the analyzer's "unused import" logic.** A barrel
   makes every symbol in a folder reachable from one import, so dead imports stop being detectable.
2. **Barrels create import cycles.** `ui/ruler/widgets/widgets.dart` exporting a widget that imports a
   sibling that imports the barrel is a cycle Dart tolerates but that makes incremental compilation and
   tree-shaking worse.
3. **Cold start matters here.** A barrel forces the whole folder into the same compilation unit for
   deferred-loading purposes. It won't matter on mobile AOT for a small app, but it removes an option you
   might want at 1.2 s.
4. **The two biggest, most-shipped codebases I read (LocalSend 86k ★, compass_app official) have exactly
   zero.** The one that leans on barrels (AppFlowy) also has the messiest `lib/shared/`. Correlation, not
   proof — but the direction is consistent.
5. **Barrels ARE right at a package boundary**, because that is the entire point of `lib/` vs `lib/src/`:
   "The libraries inside `lib` are publicly visible… Users should never import from another package's
   `lib/src` directory" (<https://dart.dev/tools/pub/package-layout>). `packages/myapp_domain/lib/myapp_domain.dart`
   is the contract; `lib/src/**` is free to be refactored.

**The one exception inside the app:** `app/lib/l10n/l10n.dart`, which is a barrel *plus* a
`BuildContext` extension. Every VGV-generated app has it, it's two lines, and it buys you `context.l10n`
everywhere. Keep it.

---

## 7. Anti-patterns — what NOT to do

1. **`lib/widgets/` for shared widgets.** Official guidance says the opposite: "put shared widgets in
   `ui/core/` rather than `/widgets`" — because it reads as `package:flutter/widgets.dart`.
   (<https://docs.flutter.dev/app-architecture/recommendations>)
2. **A global `lib/providers/` (or `lib/blocs/`) folder.** Both LocalSend and Immich have one and both
   have turned into 25–40-entry flat lists. Co-locate the provider with the thing it provides.
3. **`import 'package:flutter_gen/gen_l10n/app_localizations.dart';`** — dead since Flutter 3.32; the
   flag is now "DEPRECATED. This flag cannot be enabled and should be removed." Anything on the internet
   telling you to set `synthetic-package: true` predates 2025 and is wrong.
4. **`golden_toolkit`.** Last release 2023-02-21. If a tutorial uses `GoldenBuilder`/`multiScreenGolden`,
   it is ≥ 3 years stale — and so is everything else in that tutorial.
5. **Pointing at `VeryGoodOpenSource/very_good_core`.** Archived 2024-02-21. Live source is
   `very_good_templates/very_good_core`.
6. **Melos-first monorepos.** Adding `melos.yaml` before you've tried a plain pub workspace is 2023
   advice. flutterfire — melos's own flagship consumer — moved its config into the workspace root pubspec.
7. **A package per feature.** Zero of eight audited apps do it. You get 1 pubspec + 1 analysis_options +
   1 build_runner run per feature, and cross-feature refactors your IDE handles badly.
8. **Putting the pure-Dart domain code in `app/lib/domain/`** when a CLI must also use it. The moment
   anything under there transitively imports `dart:ui`, `dart run` breaks and you won't notice until CI.
   Package boundary = compiler-enforced.
9. **Two definitions of the reference-DB schema** (one in the CLI, one in the app). They will diverge.
   One package, imported twice.
10. **Business logic in `initState`/`build`.** "Do not put logic in widgets." (Strongly recommend,
    official.) The only things allowed in a widget: show/hide on a ViewModel flag, animation math, layout
    math from `MediaQuery`, trivial routing.
11. **Dot-suffixed filenames** (`user.model.dart`). Violates Effective Dart and collides with
    `build_runner`'s `.g.dart` / `.drift.dart` convention.
12. **Restructuring `android/` or `ios/`.** `flutter create --platforms` and every plugin's build script
    assume the generated layout.
13. **`test/` that doesn't mirror `lib/`.** compass_app, immich and VGV all mirror. When it doesn't
    mirror you cannot answer "is this file tested?" without grepping.
14. **Committing golden PNGs without a font-loading `flutter_test_config.dart`.** With six locales
    including Arabic, goldens generated on a machine with different font fallbacks are non-reproducible.
15. **Recursive-directory assumptions in `pubspec.yaml` assets.** Directory entries are not recursive.
    You will ship a build missing `assets/images/onboarding/*` and only find out on device.

---

## 8. Where credible sources genuinely disagree

| Question | Side A | Side B | My call |
|---|---|---|---|
| Feature-first vs layer-first | AppFlowy `lib/features/*`, VGV `lib/<feature>/` | LocalSend, Immich, Saber, Spotube: layer-first | **Hybrid (official)**: UI by feature, data by type. It's the only one that survives a cross-feature repository. |
| Relative vs `package:` imports inside `lib/` | compass_app enables `prefer_relative_imports`; Effective Dart says "use relative when staying within `lib/`" | Immich, LocalSend, VGV templates use `package:` everywhere | **Relative inside `lib/`, `package:` from `test/`.** Follow the official sample; it makes moving a whole feature folder a no-op. Enable the lint so it's not a debate. |
| Barrels | AppFlowy, VGV (tiny per-feature barrels) | compass_app, LocalSend, Saber, drift: none | **None in the app; one per package.** |
| Where the domain layer lives | Official docs: `lib/domain/` (and "only if you need it") | Immich: `lib/domain/` with a README enforcing direction | **Neither — a separate package**, because ours must compile without Flutter. Our case is stronger than the doc's. |
| DI package | Official recommendations page names `provider` | Immich, LocalSend, Spotube, Saber all use Riverpod/Refena | **flutter_riverpod 3.4.1.** Keep the official *structure*, ignore the package name; the docs explicitly allow substitutes. |
| File naming | Effective Dart: `lowercase_with_underscores` | Immich: `user.model.dart` | **Underscores.** Codegen suffix collisions decide it. |
| Generated l10n: commit or gitignore? | VGV commits nothing (gen/ is gitignored in the brick's `.gitignore` pattern) | LocalSend/Saber commit `strings*.g.dart` | **Commit `lib/l10n/gen/`.** It makes `git grep` on a string work, makes CI not depend on gen order, and the `header:` trick already excludes it from formatting and coverage. |

---

## 9. Create-it-now checklist

```bash
# 1. workspace root
mkdir myapp && cd myapp
cat > pubspec.yaml <<'YAML'
name: _
publish_to: none
environment:
  sdk: ^3.12.0
workspace:
  - app
  - packages/analysis_defaults
  - packages/myapp_domain
  - packages/myapp_reference_db
  - tools/content_builder
YAML

# 2. the app  (platforms limited on purpose — fewer folders, faster CI)
flutter create --platforms=android,ios --org com.example --project-name myapp app
#   then add `resolution: workspace` to app/pubspec.yaml

# 3. pure-Dart packages
dart create -t package packages/myapp_domain
dart create -t package packages/myapp_reference_db
mkdir -p packages/analysis_defaults/lib
#   add `resolution: workspace` + `publish_to: none` to each pubspec

# 4. the CLI
dart create -t console tools/content_builder
#   add `resolution: workspace`

# 5. one resolve for everything
dart pub get        # writes ONE pubspec.lock + ONE .dart_tool at the repo root

# 6. l10n + drift scaffolding
mkdir -p app/lib/l10n/arb app/lib/l10n/gen
mkdir -p app/lib/data/database/{user,reference} app/lib/data/{repositories,services}
mkdir -p app/lib/ui/core/{themes,ui,painting} app/lib/{routing,config,core/{constants,extensions}}
mkdir -p app/assets/{db,icons,images,fonts}
mkdir -p app/test/{golden,goldens,drift/user} app/testing/{fakes/repositories,fakes/services,models}
mkdir -p app/drift_schemas/{user,reference} app/integration_test
```

---

## 10. Source index (all fetched 2026-07-27)

**Official Flutter / Dart**
- App architecture case study (the tree): <https://docs.flutter.dev/app-architecture/case-study>
- App architecture recommendations: <https://docs.flutter.dev/app-architecture/recommendations>
- Pub workspaces: <https://dart.dev/tools/pub/workspaces>
- Package layout (`lib/` vs `lib/src/`): <https://dart.dev/tools/pub/package-layout>
- Effective Dart — Style (file naming, directive ordering): <https://dart.dev/effective-dart/style>
- Assets & images (non-recursive dir entries, resolution variants): <https://docs.flutter.dev/ui/assets/assets-and-images>
- l10n guide (⚠ page is stale re: `synthetic-package`): <https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization>
- Breaking change — generated l10n source: <https://docs.flutter.dev/release/breaking-changes/flutter-generate-i10n-source>
- flutter_tools `generate_localizations.dart` (ground truth for defaults + deprecation): <https://github.com/flutter/flutter/blob/master/packages/flutter_tools/lib/src/commands/generate_localizations.dart>
- flutter_tools `test/test_config.dart` (`flutter_test_config.dart` support): <https://github.com/flutter/flutter/blob/master/packages/flutter_tools/lib/src/test/test_config.dart>
- flutter_test `_matchers_io.dart` (`MatchesGoldenFile`): <https://github.com/flutter/flutter/blob/master/packages/flutter_test/lib/src/_matchers_io.dart>
- `packages/flutter/lib/material.dart` (canonical barrel): <https://github.com/flutter/flutter/blob/master/packages/flutter/lib/material.dart>

**Repos read**
- compass_app: <https://github.com/flutter/samples/tree/main/compass_app>
- flutter/samples workspace root: <https://github.com/flutter/samples/blob/main/pubspec.yaml>
- flutter/samples `analysis_defaults`: <https://github.com/flutter/samples/tree/main/analysis_defaults>
- flutter/samples `asset_transformation` (real transformer syntax): <https://github.com/flutter/samples/blob/main/asset_transformation/pubspec.yaml>
- LocalSend: <https://github.com/localsend/localsend/tree/main/app/lib>
- Immich mobile: <https://github.com/immich-app/immich/tree/main/mobile>
- Immich domain README: <https://github.com/immich-app/immich/blob/main/mobile/lib/domain/README.md>
- Immich infrastructure README: <https://github.com/immich-app/immich/blob/main/mobile/lib/infrastructure/README.md>
- AppFlowy features: <https://github.com/AppFlowy-IO/AppFlowy/tree/main/frontend/appflowy_flutter/lib/features>
- very_good_templates (LIVE): <https://github.com/VeryGoodOpenSource/very_good_templates/tree/main/very_good_core>
- very_good_core (ARCHIVED — do not use): <https://github.com/VeryGoodOpenSource/very_good_core>
- Saber: <https://github.com/saber-notes/saber> ; golden test: <https://github.com/saber-notes/saber/blob/main/test/login_golden_test.dart>
- Spotube: <https://github.com/KRTirtho/spotube>
- drift example app: <https://github.com/simolus3/drift/tree/develop/examples/app>
- flutterfire workspace root: <https://github.com/firebase/flutterfire/blob/main/pubspec.yaml>
- Melos getting started: <https://melos.invertase.dev/getting-started>

**Package status (pub.dev API, 2026-07-27)**
| Package | Latest | Published | Status |
|---|---|---|---|
| `drift` | 2.34.2 | 2026-07-14 | active, **pure Dart** |
| `drift_flutter` | 0.3.1 | 2026-07-11 | active |
| `sqlite3` | 3.5.0 | 2026-07-18 | active |
| `flutter_riverpod` | 3.4.1 | 2026-07-26 | active |
| `melos` | 8.2.2 | 2026-07-13 | active |
| `mason` | 0.1.2 | 2025-11-25 | active |
| `very_good_analysis` | 10.3.0 | 2026-06-18 | active |
| `alchemist` | 0.14.0 | 2026-03-13 | active |
| `golden_screenshot` | 11.0.1 | 2026-03-20 | active |
| `golden_toolkit` | 0.15.0 | **2023-02-21** | ❌ abandoned |
