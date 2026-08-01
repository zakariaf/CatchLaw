---
name: catchlaw-conventions-index
description: >-
  The front door to the CatchLaw repository and the routing table every other skill hangs off — the
  five product invariants of a wholly offline app with no network code path, verdicts phrased as
  statements of fact and never instructions, a citation on every result, colour as never the only
  signal and an expired ruleset still evaluated behind an ochre bar, the one-way layer map from the
  pure-Dart rule_engine package through lib/data/ to lib/ui/, the pub workspace shared with the
  content_builder CLI, the three database files assets/db/reference.db.gz, the extracted reference.db
  and the writable user.db, and a task-to-skill matrix spanning the sixteen app skills
  and thirty-three general ones. Use at the start of any CatchLaw work, before editing
  bootstrap.dart, when deciding which skill owns a change, when a task crosses rule_engine, data and
  ui, when adding a dependency to pubspec.yaml, or when reviewing a diff that touches an invariant.
---

# Catchlaw Conventions Index

CatchLaw is a printed regulations booklet that happens to run on a phone: no account, no network, no opinion, and no second chance at 05:40 with wet hands. This skill is the front door — it owns the five product invariants, the one-way layer map, the workspace and three-database shape, and the routing table that names which skill owns a change. It owns no component, no token value and no rule semantics: every row here is a pointer, and a pointer that restates its target is a defect.

Read the reference for the task at hand:
- `references/product-invariants.md` — the five invariants in full, banned symbol lists, the stale-versus-absent matrix, the citation field contract, and how each invariant is proved.
- `references/routing-table.md` — the complete task-to-skill matrix for all sixteen app skills and thirty-three general skills, ownership seams, tie-breaks, and the layer-to-skill map.

Run `scripts/check_app_invariants.sh` before a PR.

General Flutter practice is NOT in this repo: `const` policy, Riverpod, GoRouter, Drift mechanics, ARB plumbing, goldens, lints and CI gates all live in the 33-skill plugin behind `flutter-conventions-index`. This repo holds only token VALUES (`lonja-*`) and app-domain law (`catchlaw-*`).

## Non-negotiable rules

1. **CatchLaw ships with NO network code path, at all, ever.** `package:http`, `dio`, `HttpClient`, `Socket`, `WebSocket`, `connectivity_plus`, Firebase, Sentry and any analytics SDK are banned from `pubspec.yaml` and from `lib/`; every byte comes from an asset or from the app's own SQLite files. **WHY:** one `await http.get` on the result path turns a five-second answer into an indefinite spinner exactly where there is no signal to unblock it.

2. **A verdict STATES a fact and never instructs the fisher.** "Below the minimum — 38 cm, minimum 45 cm (total length)", never "Keep", "Return" or "Throw it back", in Dart source and in all six ARB files including `app_ar.arb`. The wording law itself lives in `catchlaw-verdict-contract`. **WHY:** an imperative converts a quotation of law into fishing advice, and advice that is wrong is OUR liability, not Khalid's AED 3,000.

3. **Every result carries its citation as a REQUIRED, non-nullable field.** `Citation` names instrument, article, published date and last-checked date: `Ministerial Decision 580/2015, Art. 3 · published 2015-11-03 · checked 2026-07-14`. A `Citation?` on a verdict type is a defect. **WHY:** an uncited verdict is an opinion, and the man in front of an inspector needs the article number rather than our confidence.

4. **Colour is NEVER the only signal on any surface.** Every state spends a glyph and a word alongside its hue — verdant meets, oxblood fails, ochre stale — and the mechanics are owned by `accessibility-as-code` and `lonja-verdict-and-status`. **WHY:** sunlight mode deletes every grey, salt haze eats chroma, and a red-green-only screen states nothing to eight percent of the men who will read it.

5. **An expired ruleset is still EVALUATED and still shown.** Expiry sets a flag that renders the non-blocking ochre `StaleRuleBar`; it never returns early, never disables a control, never shows an error screen and never gates the result behind a dialog. **WHY:** there is no network to refresh from, so blocking on staleness converts a slightly old answer into no answer at all — a stale rule beats no rule at sea.

6. **The layer map runs ONE WAY: `packages/rule_engine/` to `lib/data/` to `lib/ui/`.** The engine has zero `package:flutter` imports and zero knowledge of drift; `lib/data/` maps rows into engine types; `lib/ui/` never queries a DAO directly. **WHY:** a Flutter import in the engine breaks the `content_builder` CLI that shares it through the pub workspace and forces every rule test to boot a widget binding.

7. **Three database FILES, two drift databases, and the shipped one is READ-ONLY.** `assets/db/reference.db.gz` is extracted once to `reference.db` under `getApplicationSupportDirectory()` and opened `readOnly: true`; `user.db` is the only writable one and the only irreplaceable one. **WHY:** a writable open lets drift run `onCreate` against shipped content and drop a `-wal` beside it, after which the sha256 no longer matches and every later integrity check is a false alarm.

8. **Nothing is awaited before `runApp`.** Both databases open through `LazyDatabase` + `NativeDatabase.createInBackground`, first-launch extraction runs behind a DETERMINATE progress bar under 6 s, and cold start stays under 1.2 s on low-end Android. **WHY:** every `await` before the first frame is a black screen indistinguishable from a crashed app on the boat where it matters.

9. **Route BEFORE you edit: find the owning skill in the table, then read it.** One row, one owner; if two look plausible, the more specific skill wins and `references/routing-table.md` records the tie-break. **WHY:** a change made without its owning skill re-derives a rule that already exists and gets it subtly wrong, and subtle wrongness in a legal statement is the whole risk surface.

10. **A general rule is never FORKED into an app skill.** `lonja-*` skills carry values, `catchlaw-*` skills carry domain law; anything about widgets, state, routing, codegen or CI is cited, not restated. **WHY:** a forked rule drifts from its origin within two PRs and then two skills disagree in front of a model that cannot tell which one is current.

11. **No account, no login, no sync, and no identifier ever leaves the device.** No `signIn`, no `deviceId`, no install UUID, no remote config, no crash upload; `user.db` is local, exportable by the user and by nobody else. **WHY:** the app's entire promise is that there is nothing to leak, and a device identifier is a sync feature waiting for a product manager to find it.

12. **Six locales ship together or the feature does not ship.** `app_ar.arb`, `app_en.arb`, `app_es.arb`, `app_gl.arb`, `app_ca.arb` and `app_pt_BR.arb` gain the key in the same PR, with an Arabic RTL lane in the golden matrix; mechanics belong to `i18n-rtl-l10n`. **WHY:** a missing Arabic key falls back to English inside a legal statement, which is the one place a fisher cannot guess the meaning.

## The layer map is a one-way street

`packages/rule_engine/` is pure Dart with zero Flutter imports, shared through pub workspaces with `tools/content_builder/`. It takes plain values and returns a sealed verdict; it never sees a `Color`, a `BuildContext` or a DAO.

```dart
// WRONG — packages/rule_engine/lib/src/size_rule.dart
import 'package:flutter/material.dart';            // engine now needs a widget binding
import 'package:catchlaw/data/species_dao.dart';   // and reaches DOWN into the app
Color evaluate(double cm) => cm < 45 ? Colors.red : Colors.green;  // a UI decision, in the engine

// RIGHT — pure values in, sealed verdict out; the app and the CLI both call this.
sealed class Verdict { const Verdict({required this.citation}); final Citation citation; }

final class BelowMinimum extends Verdict {
  const BelowMinimum({
    required this.measuredCm, required this.minimumCm,
    required this.method, required super.citation,
  });
  final double measuredCm;          // 38.0
  final double minimumCm;           // 45.0  Epinephelus coioides
  final MeasurementMethod method;   // MeasurementMethod.totalLength
}

Verdict evaluateSize(SizeRule rule, Measurement m) => m.cm < rule.minimumCm
    ? BelowMinimum(measuredCm: m.cm, minimumCm: rule.minimumCm,
        method: rule.method, citation: rule.citation)
    : Meets(citation: rule.citation);
```

Full worked file: `examples/catchlaw_layering.dart`.

## Three files, two databases, nothing awaited

The shipped asset is extracted once, then opened read-only. `user.db` is the only writable database. Neither is awaited before the first frame.

```dart
// WRONG — bootstrap.dart: two awaits before runApp, and a write to the shipped content.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ref = await openReferenceDb();                       // 2.4 s of black screen
  await ref.customStatement('PRAGMA user_version = 3');      // mutates reference.db
  runApp(CatchlawApp(reference: ref));
}

// RIGHT — first frame immediately; both databases open on their first query.
void main() => runApp(const ProviderScope(child: CatchlawApp()));

LazyDatabase referenceExecutor() => LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'reference', 'reference.db'));  // extracted copy
      if (!file.existsSync()) {
        await ReferenceInstaller.install(                    // determinate progress bar
          asset: 'assets/db/reference.db.gz', target: file); // temp + atomic rename + sha256
      }
      return NativeDatabase.createInBackground(file, readOnly: true);
    });
```

Full worked file: `examples/catchlaw_layering.dart`.

## Stale beats absent

Expiry is a flag on the pack, not a branch in the flow. The same evaluation runs; an ochre bar states the date above an otherwise unchanged result.

```dart
// WRONG — expiry treated as an error state, on a device with no way to fix it.
if (pack.validUntil.isBefore(today)) {
  return const RulePackExpiredScreen();     // Khalid now has no rule at all
}

// RIGHT — evaluate regardless, state the staleness, block nothing.
final verdict = engine.evaluate(landing, pack);        // one code path, fresh or stale
return Column(children: [
  if (pack.validUntil.isBefore(today))
    StaleRuleBar(expiredOn: pack.validUntil),          // ochre 8A6A16, non-blocking
  VerdictPanel(verdict: verdict),                      // unchanged stamp, unchanged wording
  CitationFootnote(citation: verdict.citation),        // required, never null
  const LonjaDisclaimer(),                             // unconditional, non-dismissable
]);
```

Full worked file: `examples/catchlaw_layering.dart`.

## Routing table — find the owner, then read it

One row, one owner. The complete matrix, including every general skill not listed here, is in `references/routing-table.md`.

| Working on | Read |
|---|---|
| a colour, gap, rule weight, radius or theme value | `lonja-design-tokens` |
| a type ramp, serif legal text, mono tabular figures, Arabic faces | `lonja-typography` |
| an action, its label, variant ladder or destructive confirm | `lonja-buttons` |
| app bar, tabs, zone chip, back affordance, currency banner | `lonja-navigation-chrome` |
| a text field, keypad, segmented control, switch or chip | `lonja-forms-and-controls` |
| a species row, ledger table, list state or empty basket | `lonja-lists-and-tables` |
| a modal, sheet, ambiguity dialog or plate surface | `lonja-dialogs-and-surfaces` |
| an icon, glyph set or engraved species plate | `lonja-icons-and-plates` |
| the result screen, stamp, stale bar, citation footnote, disclaimer | `lonja-verdict-and-status` |
| anything about the absence of network, sync or accounts | `catchlaw-offline-guarantee` |
| the read-only reference DB, its schema, seeding or extraction | `catchlaw-reference-database` |
| the `content_builder` CLI, rule packs, checksums, publish dates | `catchlaw-content-pipeline` |
| rule evaluation, precedence, seasons, bag limits, zones | `catchlaw-rule-engine` |
| verdict WORDING, banned imperatives, citation strings | `catchlaw-verdict-contract` |
| TL, FL, CW, SHL, units, rounding, the on-screen ruler | `catchlaw-measurement-ruler` |
| a `Notifier`, `AsyncNotifier`, provider scope or rebuild | `state-management-riverpod` |
| a drift DAO, transaction, query or pagination | `persistence-drift` |
| a schema change or migration step | `run-migration` |
| a GoRouter route, deep link or redirect | `navigation-and-routing` |
| `main.dart`, `bootstrap.dart`, first-launch extraction, splash | `app-startup-and-bootstrap` |
| an ARB key, ICU plural, bidi text or numeral system | `i18n-rtl-l10n` |
| `Semantics`, tap targets, text scaling, never-colour-alone | `accessibility-as-code` |
| a `Result`, `Failure` type or error surface | `error-handling-typed-results` |
| a `CustomPainter`, gesture or `shouldRepaint` | `custom-canvas-and-gestures` |
| a new feature folder or package boundary | `scaffold-feature-module` / `project-structure-and-packages` |
| a golden, RTL lane or widget test | `widget-golden-and-a11y-testing` / `testing-strategy` |
| `build_runner`, generated files, CI gates | `codegen-and-toolchain` / `ci-pipeline-and-gates` |
| anything general Flutter not listed above | `flutter-conventions-index` |

## Anti-patterns

- **`http.get(Uri.https('api.catchlaw.app', '/rules'))`** — an offline app that hangs forever on the one boat where it is used.
- **`connectivity_plus` in `pubspec.yaml`** — implies a code path that reacts to connectivity, which implies there is one.
- **`import 'package:flutter/material.dart'` inside `packages/rule_engine/`** — breaks `content_builder`, and makes every rule test boot a widget binding.
- **`await database.open()` before `runApp`** — a black screen that is indistinguishable from a crash.
- **`NativeDatabase(referenceFile)` without `readOnly: true`** — drift runs `onCreate` against shipped content and leaves a `-wal` that breaks every later sha256 check.
- **`Text('Throw it back')`** — an instruction, so a wrong one is our liability rather than a misread rule.
- **`final Citation? citation;`** on a verdict type — makes an uncited verdict representable, and something will represent it.
- **`if (pack.isExpired) return const ErrorScreen();`** — trades a slightly old answer for no answer, with no network to recover.
- **`switch (category) { case fails: return oxblood; }`** with no glyph — colour as the only signal, unreadable in sunlight mode.
- **`FirebaseAnalytics.instance.logEvent(...)`** — a network call, an identifier and a consent problem in one line.
- **`prefs.setString('deviceId', uuid)`** — invents the identity the product promised does not exist.
- **A `const`-constructor or `RepaintBoundary` rule restated in a `lonja-*` skill** — forks `flutter-performance` and drifts from it within two PRs.

## Definition of done

- [ ] `scripts/check_app_invariants.sh` is clean over `lib/`.
- [ ] No networking, connectivity, analytics, crash-reporting or auth symbol appears in `lib/` or `pubspec.yaml` (rules 1, 11).
- [ ] No user-visible string instructs the fisher, in Dart or in any of the six ARB files (rule 2).
- [ ] Every verdict type carries a non-nullable `Citation` with instrument, article, published and checked dates (rule 3).
- [ ] Every status is carried by glyph plus word plus colour, and survives a greyscale golden (rule 4).
- [ ] An expired pack still evaluates, still renders its verdict, and adds only the ochre `StaleRuleBar` (rule 5).
- [ ] `packages/rule_engine/` has zero `package:flutter` and zero `package:drift` imports, and `lib/ui/` touches no DAO (rule 6).
- [ ] `reference.db` is opened `readOnly: true`, `user.db` is the only writable one, and neither is awaited before `runApp` (rules 7, 8).
- [ ] Every changed area names its owning skill in the PR description, and no general-plugin rule was copied into this repo (rules 9, 10).
- [ ] All six ARB files gained the same keys, with the `ar` golden lane green (rule 12).

## Related skills

- See `catchlaw-offline-guarantee` for the full ban list, the asset-only data policy and the proof that no code path can reach the network.
- See `catchlaw-rule-engine` for evaluation order, precedence between size, season, protection and bag limits, and the sealed verdict types.
- See `catchlaw-verdict-contract` for the exact statement-of-fact wording, the banned-imperative lexicon and the citation string format.
- See `catchlaw-reference-database` for the two-database contract, the read-only open, extraction and sha256 verification of the shipped `reference.db`.
- See `catchlaw-content-pipeline` for the `content_builder` CLI, rule-pack validity dates and how a pack is published.
- See `catchlaw-measurement-ruler` for TL, FL, CW and SHL, unit handling and the on-screen ruler.
- See `lonja-design-tokens` for the pigment box and spacing spine every Lonja surface skill reads.
- See `flutter-conventions-index` for the thirty-three general Flutter skills this repo defers to rather than restates.
- See `project-structure-and-packages` for the pub-workspace mechanics that let the app and `content_builder` share `rule_engine`.

## References

- Dart docs — Pub workspaces: https://dart.dev/tools/pub/workspaces
- Dart docs — Package layout conventions: https://dart.dev/tools/pub/package-layout
- Flutter docs — Architecture guide: https://docs.flutter.dev/app-architecture/guide
- Flutter docs — Assets and images: https://docs.flutter.dev/ui/assets/assets-and-images
- Flutter API — `rootBundle`: https://api.flutter.dev/flutter/services/rootBundle.html
- Drift docs — Getting started and platform setup: https://drift.simonbinder.eu/setup/
- path_provider API — `getApplicationSupportDirectory`: https://pub.dev/documentation/path_provider/latest/path_provider/getApplicationSupportDirectory.html
- W3C WAI — Use of Color 1.4.1: https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html
