# Routing Table

The complete task-to-skill matrix: all 16 app skills in this repo, all 33 general skills in the
Flutter plugin, the layer each one governs, and the tie-breaks for tasks that look like two owners.
The invariants themselves are in `product-invariants.md`.

## Layer map, and who owns each layer

| Path | What lives there | Owning skills |
|---|---|---|
| `pubspec.yaml` (root) | pub workspace: the app plus `packages/*` | `project-structure-and-packages`, `dependency-hygiene` |
| `packages/rule_engine/` | pure Dart, zero Flutter, zero drift — rules and verdicts | `catchlaw-rule-engine`, `dart3-idioms-and-coding-standards` |
| `tools/content_builder/` | CLI that builds and signs the reference DB | `catchlaw-content-pipeline` |
| `assets/db/` | the shipped `reference.db` payload, opened read-only | `catchlaw-reference-database` |
| `lib/data/` | drift: reference DAOs, `user.db`, mappers into engine types | `persistence-drift`, `catchlaw-reference-database` |
| `lib/theme/` | `lonja_primitives.dart`, `lonja_tokens.dart`, `lonja_theme.dart` | `lonja-design-tokens`, `lonja-typography` |
| `lib/design/` | icon paths, engraved plate specs | `lonja-icons-and-plates` |
| `lib/ui/core/` | shared Lonja widgets | the `lonja-*` component skills |
| `lib/ui/<feature>/` | screens and their notifiers | `state-management-riverpod`, `scaffold-feature-module` |
| `lib/l10n/` | `app_ar.arb`, `app_en.arb`, `app_es.arb`, `app_gl.arb`, `app_pt_BR.arb`, `app_ca.arb` | `i18n-rtl-l10n` |
| `test/`, `test/goldens/` | unit, widget, golden, RTL lanes | `testing-strategy`, `widget-golden-and-a11y-testing` |

Direction of dependency: `packages/rule_engine/` knows nothing. `lib/data/` depends on the engine.
`lib/ui/` depends on `lib/data/` through providers. Nothing ever points back up.

## App skills — 16 rows

| Working on | Read |
|---|---|
| a colour, gap, rule weight, radius, duration, glove density or theme value | `lonja-design-tokens` |
| a type role, serif legal text, mono tabular figures, Arabic faces | `lonja-typography` |
| an action button, its label, the variant ladder, a destructive confirm | `lonja-buttons` |
| app bar, tabs, zone chip, back affordance, data-currency banner | `lonja-navigation-chrome` |
| text field, numeric keypad, segmented control, switch, filter chip | `lonja-forms-and-controls` |
| species row, ledger table, list states, empty basket, keyset scroll UI | `lonja-lists-and-tables` |
| modal, bottom sheet, ambiguity dialog, plate surface, barrier policy | `lonja-dialogs-and-surfaces` |
| icon set, glyph geometry, engraved species plate, asset sizing | `lonja-icons-and-plates` |
| result screen, verdict stamp, stale bar, citation footnote, disclaimer | `lonja-verdict-and-status` |
| anything asserting the absence of network, sync, accounts or telemetry | `catchlaw-offline-guarantee` |
| reference DB schema, seeding, extraction, sha256, the read-only open | `catchlaw-reference-database` |
| `content_builder` CLI, rule packs, validity dates, source provenance | `catchlaw-content-pipeline` |
| evaluation order, precedence, seasons, bag limits, zones, gear rules | `catchlaw-rule-engine` |
| verdict WORDING, banned imperatives, citation string format | `catchlaw-verdict-contract` |
| TL / FL / CW / SHL, units, rounding, the on-screen ruler and calibration | `catchlaw-measurement-ruler` |
| which skill owns a change, the invariants, the layer map | `catchlaw-conventions-index` (this one) |

## General skills — 33 rows

| Working on | Read |
|---|---|
| `Semantics`, 44dp targets, text scaling, never-colour-alone | `accessibility-as-code` |
| breakpoints, tablet layout, orientation, safe areas | `adaptive-layout` |
| `main.dart`, `bootstrap.dart`, splash, first-launch extraction, warm-up | `app-startup-and-bootstrap` |
| `await` across a `BuildContext`, cancellation, dropped futures, debounce | `async-safety` |
| GitHub Actions, gates, artefact upload, required checks | `ci-pipeline-and-gates` |
| `build_runner`, generated file policy, drift and riverpod generators | `codegen-and-toolchain` |
| `CustomPainter`, `shouldRepaint`, gesture arenas, zero-allocation `paint()` | `custom-canvas-and-gestures` |
| sealed classes, records, patterns, function length, complexity numbers | `dart3-idioms-and-coding-standards` |
| doc comments, `///` style, what must be documented | `dartdoc-conventions` |
| adding, pinning, auditing or removing a package | `dependency-hygiene` |
| reviewing a UI change, screenshots, the design pass | `design-review-workflow` |
| `ThemeExtension` mechanics, `copyWith`/`lerp`, `of(context)`, `ColorScheme` | `design-system-structure` |
| `Result`, `Failure`, error surfaces, recovery paths | `error-handling-typed-results` |
| layer boundaries, repositories, dependency direction | `flutter-architecture` |
| any general Flutter topic whose owner is unclear | `flutter-conventions-index` |
| `const`, `select`, `RepaintBoundary`, lazy lists, jank, frame budget | `flutter-performance` |
| `Form`, validators, focus order, input formatters, keyboard types | `forms-and-input` |
| ARB keys, `gen_l10n`, ICU plurals, bidi, numeral systems, directional geometry | `i18n-rtl-l10n` |
| `analysis_options.yaml`, lint rules, formatter settings | `lint-and-style-config` |
| a scheduled local notification (closed-season reminders) | `local-notifications-scheduler` |
| naming a class, file, provider, test or ARB key | `naming-conventions` |
| GoRouter routes, deep links, redirects, typed route args | `navigation-and-routing` |
| drift DAOs, transactions, streams, keyset pagination, isolates | `persistence-drift` |
| package boundaries, workspace members, folder shape | `project-structure-and-packages` |
| actually running `build_runner` now | `run-codegen` |
| writing or running a schema migration | `run-migration` |
| creating a new feature module from scratch | `scaffold-feature-module` |
| platform channels, native plugins, service abstractions | `service-boundary-and-native` |
| `Notifier`, `AsyncNotifier`, provider scopes, ref lifecycles | `state-management-riverpod` |
| what to test, at which level, and what not to test | `testing-strategy` |
| a unit type, quantity or money value object | `value-objects-money-and-units` |
| extracting a widget, `Widget` class versus `_buildX()` helper | `widget-composition` |
| golden harness, RTL lanes, a11y assertions in tests | `widget-golden-and-a11y-testing` |

## Ownership seams — the tasks that look like two owners

| Task | Owner | Not |
|---|---|---|
| the hex of `verdictFail` | `lonja-design-tokens` | `lonja-verdict-and-status` (it owns the meaning) |
| the `ThemeExtension` boilerplate around those hexes | `design-system-structure` | `lonja-design-tokens` (values only) |
| the sentence "Below the minimum — 38 cm, minimum 45 cm" | `catchlaw-verdict-contract` | `lonja-verdict-and-status` (it sets the type) |
| which rule fired to produce that sentence | `catchlaw-rule-engine` | either surface skill |
| the ruler that produced 38 cm | `catchlaw-measurement-ruler` | `lonja-forms-and-controls` |
| the drift DAO that read the size rule | `persistence-drift` | `catchlaw-reference-database` (schema and seeding) |
| the SQL that built the shipped file | `catchlaw-content-pipeline` | `catchlaw-reference-database` |
| extracting the asset at first launch | `catchlaw-reference-database` | `app-startup-and-bootstrap` (frame budget only) |
| Arabic-Indic digits in a measurement | `i18n-rtl-l10n` | `lonja-typography` (faces and tabular figures) |
| a 56dp glove target | `lonja-design-tokens` (the value) | `accessibility-as-code` (the 44dp floor it must clear) |
| a `CustomPainter` reading tokens | `custom-canvas-and-gestures` | `lonja-icons-and-plates` (the plate geometry) |
| "should this be offline?" — it already is | `catchlaw-offline-guarantee` | any feature skill |

Tie-break rule: the MORE SPECIFIC skill wins, and the app skill wins over the general skill only for
values and domain law. If a row is missing here, add it in the same PR as the ambiguity.

## Reading order for a cold session

1. This index — invariants, layer map, routing.
2. The owning skill from the table above.
3. Its `references/` file for the task at hand.
4. `flutter-conventions-index` only if the task is general Flutter with no app-specific angle.
