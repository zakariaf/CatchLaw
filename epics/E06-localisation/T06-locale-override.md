# E06/T06 — A locale override that outlives the system locale

| | |
|---|---|
| **Epic** | E06 — Localisation infrastructure |
| **Branch** | `epic/06-localisation` (shared) |
| **Commit** | `feat(l10n): persist the locale override independently of the system locale` |
| **Depends on** | T01 (`supportedLocales`), T03 (the resolver takes the resolved locale), T04 (`auto` re-evaluates when the locale changes) |
| **Size** | M |
| **Spec** | `SPEC.md` §11 "Both" (locale follows the system; the S14 override persists independently); §7.2 `user_profile.locale_override`; §6 S14 and D5; §9.1 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `i18n-rtl-l10n` | `references/rtl-and-bidi.md` prescribes exactly this seam: a Riverpod `localeProvider` backed by a manual `Notifier`, never a legacy `StateProvider`, so a locale change rebuilds `MaterialApp`, re-flips `Directionality` and re-runs every lookup live |
| `state-management-riverpod` | `AsyncNotifier` shape, the single write path, and why `ProviderContainer` is how this is tested |
| `persistence-drift` | Writing the singleton `user_profile` row transactionally; `user.db` is the only writable database and the only irreplaceable one |
| `catchlaw-conventions-index` | Rule 8 — the profile read must not become an await before `runApp`; rule 11 — the override is a local preference, never an identifier |
| `testing-strategy` | Rule 7: drive the notifier headlessly through `ProviderContainer` overrides; never pump a widget to test state |
| `naming-conventions` | `LocaleNotifier` is the Riverpod role name; `Locale.fromSubtags` over a stringly-typed locale |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §11 "Both", bullet 2 | The requirement and its reason, in one sentence: *a Galician-speaking user may run a Spanish-locale phone* |
| `SPEC.md` | §7.2 | `user_profile.locale_override TEXT` — nullable, and nullable **means** "follow the device" |
| `SPEC.md` | §6, S14 | Where the user changes it |
| `SPEC.md` | §6, Dialogs, D5 | First-run language confirmation, pre-selected from the system locale, one tap. Not this task — but the state it writes is this task's |
| `SPEC.md` | §9.1 | Why `gl` and `ca` are not padding: each is the official publication language of an instrument being bundled. That argument is void if the app cannot be pinned to them |
| `epics/DECISIONS.md` | D-3 | The six locales, and `pt_BR` as a language-plus-region tag |
| `epics/DECISIONS.md` | D-6 | `user.db` is the writable database; `reference.db` is never written |
| `FLUTTER_GUIDE.md` | §9.2 | `GlobalWidgetsLocalizations` maps locale → direction; the six RTL language codes, of which we ship one |
| `.claude/skills/i18n-rtl-l10n/references/rtl-and-bidi.md` | "Direction is a locale consequence" | The `localeProvider` pattern, and why a live switch works only when the geometry is already directional (T05) |
| `.claude/skills/i18n-rtl-l10n/references/arb-and-icu.md` | "Widget vendors a delegate…" | The `MaterialApp` wiring shape, including `locale: ref.watch(localeProvider)` with `null` meaning "follow the device" |

## What this delivers

- `app/lib/l10n/locale_notifier.dart`
  - `LocaleNotifier extends AsyncNotifier<Locale?>` — `null` means "follow the device".
  - `Future<void> setOverride(Locale? locale)` — the single write path into
    `user_profile.locale_override`.
- `app/lib/l10n/locale_codec.dart`
  - `String? encodeLocale(Locale?)` / `Locale? decodeLocale(String?)` — the `pt_BR` ↔
    `Locale('pt','BR')` round trip, in one place.
- `app/lib/l10n/resolve_locale.dart`
  - `Locale resolveLocale({Locale? override, required List<Locale> deviceLocales, required List<Locale> supported})`
    — pure, no Flutter binding, no I/O. This is what the tests hammer.
- `app/lib/app.dart` — `locale: ref.watch(localeNotifierProvider).valueOrNull`, plus
  `localeListResolutionCallback: ` delegating to `resolveLocale`.
- `app/test/l10n/resolve_locale_test.dart`, `app/test/l10n/locale_notifier_test.dart`,
  `app/test/l10n/locale_codec_test.dart`.

## Why it is built this way

**`null` is the "follow the device" state, and it is stored as SQL `NULL`.** `SPEC.md` §7.2 declares
`locale_override TEXT` with no `NOT NULL` and no default. Encoding "follow the device" as the string
`'auto'` or `'system'` would put a fourth, non-locale value into a column whose other values are locale
tags, and every reader would need to know the sentinel. `NULL` already means "unset" in SQL and in Dart.

**Resolution is a pure function, separate from the notifier.** `resolveLocale` takes the override, the
device's locale *list* and the supported list, and returns one `Locale`. It touches no binding, so its
nine rows run in milliseconds with no pump and no container. The notifier's job shrinks to reading and
writing one column, which is what rows 10–13 test.

**The device's locale *list*, not its locale.** Both platforms expose an ordered list of user
preferences. A phone set to `es_ES` with `gl` second is a real configuration for exactly the user
`SPEC.md` §11 names, and taking only the first entry throws that information away. `MaterialApp` offers
`localeListResolutionCallback` for this; using `localeResolutionCallback` instead would be choosing the
lossy hook.

**The unsupported-device-locale fallback is `en`, explicitly.** Flutter's default when nothing matches
is the **first** entry of `supportedLocales`. `AppLocalizations.supportedLocales` is generated in ARB
file order, which puts `app_ar.arb` first alphabetically — so a German phone would launch the app in
Arabic, right-to-left, and nobody would understand why. Row 5 exists because this failure looks like a
bug in the RTL code and is not.

**Language-only matching is a real step, and `pt_PT` is why.** A Portuguese phone set to `pt_PT` shares
no exact tag with `pt_BR`. Falling through to `en` for that user would be worse than showing Brazilian
Portuguese, which is intelligible; and `SPEC.md` §9.2 note on the filename is about *content* being
Brazilian, not about refusing Portuguese speakers. So: exact tag, then language-only, then `en`. Note
the deliberate asymmetry with T03 row 8 — `content_string` does **not** language-match `pt` to `pt_BR`,
because there the two are different bundled texts rather than two dialects of chrome.

**The override survives a restart because it is a row, not a field.** `user.db` is the only writable
database (D-6) and the only irreplaceable one. Row 12 asserts the read-back against a real
`NativeDatabase.memory()` rather than a mocked DAO — a mock would prove nothing about the column
actually existing.

**Changing the locale re-evaluates the numeral system.** T04's `auto` means "whatever CLDR says for the
resolved locale". If the locale can change at runtime and the numeral system does not re-evaluate,
`auto` silently becomes "whatever CLDR said at launch". Row 14 ties the two together. Today the answer
is Latin digits for all six locales either way (T04's finding point 4), so the row asserts the *wiring*,
not a visible difference — which is precisely why it would otherwise never be noticed as missing.

**Rejected: reading the override before `runApp`.** It is an await on the launch path, banned by
`catchlaw-conventions-index` rule 8 and priced by `SPEC.md` §13's 1.2 s cold-start budget. The
`AsyncNotifier` starts at `AsyncLoading`, `MaterialApp` gets `locale: null` for that first frame and
follows the device — which is the correct default anyway (`SPEC.md` §11). The one visible consequence
is a possible single-frame flip for an overriding user, and a flip on frame one is not a flip anyone
sees.

**Rejected: `SharedPreferences` for the override.** `SPEC.md` §7.2 puts it in `user_profile`, and §12's
export must carry the user's settings. A preference living outside `user.db` would be silently absent
from every export and import — the exact class of bug §12's round trip exists to prevent.

**Rejected: a `StateProvider`.** `rtl-and-bidi.md` names it and rejects it. The override has a
persistence side effect on every write; a `StateProvider` has no place to put one, so the side effect
ends up at the call site, which means it ends up at *some* call sites.

**Rejected: implementing D5, the first-run language dialog, here.** It is a screen with a one-tap
confirmation and a pre-selection, and it belongs with the navigation shell (E12) and settings (E16).
This task delivers the state D5 writes and the resolution D5's pre-selection is computed from.

## Tests first

Write every row before `resolve_locale.dart` exists. Run them. **They must fail.** If row 1 passes
early, the test is calling Flutter's own resolution instead of ours.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `resolveLocale returns the device locale when there is no override` | device `[es_ES]`, no override | `es` | The default posture: `SPEC.md` §11, "locale follows the system by default" |
| 2 | `resolveLocale returns gl when the override is gl and the device is es_ES` | device `[es_ES]`, override `gl` | `gl` | **The headline case, quoted from `SPEC.md` §11:** a Galician-speaking user may run a Spanish-locale phone. §9.1's whole argument for shipping `gl` depends on this row |
| 3 | `resolveLocale keeps the override when the device locale changes from es to ar` | override `gl`, device changes | `gl` both times | "Persists independently" means independently of *changes*, not only of the initial value |
| 4 | `resolveLocale returns the second device locale when the first is unsupported` | device `[de_DE, gl_ES]` | `gl` | The ordered list is user intent; taking only `deviceLocales.first` would discard it |
| 5 | `resolveLocale returns en when no device locale is supported` | device `[de_DE]`, no override | `en` | Flutter's default is `supportedLocales.first`, which is `ar` in ARB order — a German phone would launch right-to-left in Arabic |
| 6 | `resolveLocale returns pt_BR when the device locale is pt_PT` | device `[pt_PT]` | `pt_BR` | Language-only match. Brazilian Portuguese is intelligible to a `pt_PT` reader; `en` is not |
| 7 | `resolveLocale returns ar when the device locale is ar_AE` | device `[ar_AE]` | `ar` | Khalid's device tag. `intl` has no `ar_AE` either (T04 finding point 3) — the two fallbacks must agree |
| 8 | `resolveLocale returns en when the override names an unsupported locale` | override `ur` | `en` | A `user.db` restored from an older export could carry a dropped locale (D-3 removed `ur`). Import must not brick the app |
| 9 | `resolveLocale returns the override even when it also appears in the device list` | device `[gl_ES]`, override `gl` | `gl` | Idempotence, and it pins the precedence order so a later refactor cannot invert it |
| 10 | `LocaleNotifier starts at null and follows the device` | fresh `user.db` | `null` | The unset state is `NULL`, not a sentinel string |
| 11 | `LocaleNotifier.setOverride writes pt_BR to user_profile.locale_override` | `Locale('pt','BR')` | column reads `pt_BR` | The encoding that reaches SQL is the one T03 and the ARB filenames use |
| 12 | `LocaleNotifier reads back the stored override from a reopened user.db` | write, reopen, read | `Locale('pt','BR')` | Persistence is the requirement. Against a real `NativeDatabase.memory()`, never a mocked DAO |
| 13 | `LocaleNotifier.setOverride(null) clears the override rather than storing a sentinel` | `null` | column is SQL `NULL` | Storing `'auto'` would put a non-locale value in a locale column and every reader would need the secret |
| 14 | `LocaleNotifier re-applies the numeral system when the override changes` | override `en` → `ar`, numeral `auto` | `applyNumeralSystem` called again | Otherwise `auto` means "whatever CLDR said at launch". Invisible today (both are Latin) and therefore never noticed as missing |
| 15 | `encodeLocale round-trips $tag` | loop over `ar`, `en`, `es`, `gl`, `ca`, `pt_BR` | equal locale | `Locale('pt_BR')` is a language code containing an underscore — it looks right and matches nothing |
| 16 | `CatchlawApp renders RTL when the override is ar and the device is en` | override `ar`, device `[en_GB]` | `TextDirection.rtl` | The end-to-end proof that the override reaches `Directionality` and that T05's directional sweep is what makes the live switch correct |

```dart
// app/test/l10n/resolve_locale_test.dart
import 'package:catchlaw/l10n/resolve_locale.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _supported = <Locale>[
  Locale('ar'), Locale('en'), Locale('es'),
  Locale('gl'), Locale('ca'), Locale('pt', 'BR'),
];

Locale _resolve(List<Locale> device, {Locale? override}) => resolveLocale(
      override: override,
      deviceLocales: device,
      supported: _supported,
    );

void main() {
  // SPEC.md §11: "a Galician-speaking user may run a Spanish-locale phone".
  test('resolveLocale returns gl when the override is gl and the device is es_ES', () {
    expect(_resolve(const [Locale('es', 'ES')], override: const Locale('gl')),
        const Locale('gl'));
  });

  test('resolveLocale returns the second device locale when the first is unsupported', () {
    expect(_resolve(const [Locale('de', 'DE'), Locale('gl', 'ES')]), const Locale('gl'));
  });

  // Flutter's own default is supportedLocales.first, which is ar in ARB order.
  test('resolveLocale returns en when no device locale is supported', () {
    expect(_resolve(const [Locale('de', 'DE')]), const Locale('en'));
  });

  test('resolveLocale returns pt_BR when the device locale is pt_PT', () {
    expect(_resolve(const [Locale('pt', 'PT')]), const Locale('pt', 'BR'));
  });

  test('resolveLocale returns ar when the device locale is ar_AE', () {
    expect(_resolve(const [Locale('ar', 'AE')]), const Locale('ar'));
  });

  // A user.db restored from an export predating D-3 can still name ur.
  test('resolveLocale returns en when the override names an unsupported locale', () {
    expect(_resolve(const [Locale('de', 'DE')], override: const Locale('ur')),
        const Locale('en'));
  });
}
```

```dart
// app/test/l10n/locale_notifier_test.dart
import 'package:catchlaw/l10n/locale_notifier.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/l10n/number_symbols_guard.dart';
import '../support/user_db.dart'; // NativeDatabase.memory() harness from E05

void main() {
  setUp(captureNumberSymbols);
  tearDown(restoreNumberSymbols);

  test('LocaleNotifier.setOverride writes pt_BR to user_profile.locale_override', () async {
    final db = openMemoryUserDb();
    addTearDown(db.close);
    final container = ProviderContainer(overrides: userDbOverrides(db));
    addTearDown(container.dispose);

    await container.read(localeNotifierProvider.future);
    await container
        .read(localeNotifierProvider.notifier)
        .setOverride(const Locale('pt', 'BR'));

    expect(await readLocaleOverrideColumn(db), 'pt_BR');
  });

  test('LocaleNotifier.setOverride(null) clears the override rather than storing '
      'a sentinel', () async {
    final db = openMemoryUserDb();
    addTearDown(db.close);
    final container = ProviderContainer(overrides: userDbOverrides(db));
    addTearDown(container.dispose);

    await container.read(localeNotifierProvider.future);
    final notifier = container.read(localeNotifierProvider.notifier);
    await notifier.setOverride(const Locale('gl'));
    await notifier.setOverride(null);

    expect(await readLocaleOverrideColumn(db), isNull);
  });
}
```

**Run:** `cd app && flutter test test/l10n/resolve_locale_test.dart test/l10n/locale_notifier_test.dart test/l10n/locale_codec_test.dart`
→ 16 rows red (21 tests after row 15's loop expands).

## Implementation outline

1. Write `locale_codec.dart` and make row 15 green. It is the smallest piece and every other file
   depends on getting `pt_BR` right.
2. Write `resolve_locale.dart` as a pure function, in this order: override (if supported) → exact tag
   match in the device list → language-only match in the device list → `en`. Make rows 1–9 green.
3. Write `LocaleNotifier` over E05's `user_profile` repository. `build()` reads the column and decodes
   it; `setOverride` encodes, writes in a transaction, and updates state. Make rows 10–13 green.
4. Wire the numeral re-application (row 14): `LocaleNotifier` and `NumeralSystemNotifier` both feed the
   formatter, so the dependency is declared in Riverpod, not by calling T04's function from this file.
   Whichever direction the container graph runs, assert the observable — that a locale change results
   in `applyNumeralSystem` being called again.
5. Wire `app.dart`: `locale: ref.watch(localeNotifierProvider).valueOrNull` and
   `localeListResolutionCallback` delegating to `resolveLocale`. Make row 16 green.
6. Re-run T01's direction tests. They pumped a `locale` parameter directly and must still pass — if
   they do not, the wiring took the parameter away and T01's guarantee went with it.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 16 rows pass, and each failed first.
- [ ] `locale_override` is `NULL` for "follow the device"; no sentinel string exists anywhere.
- [ ] The override survives a database close and reopen (row 12), against `NativeDatabase.memory()`.
- [ ] No `await` was added before `runApp` (rule 8); `main()` is unchanged by this commit except for
      nothing.
- [ ] An unsupported override and an unsupported device locale both land on `en`, never on
      `supportedLocales.first`.
- [ ] `Locale('pt_BR')` appears nowhere in the repository — `grep -rn "Locale('pt_BR')" app/` is empty.
- [ ] Changing the override re-applies the numeral system (row 14).
- [ ] D5, the first-run language dialog, is **not** implemented here and is named in the commit body as
      E12/E16's.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
tools/gates/no_directional_geometry.sh                                   app/lib
.claude/skills/i18n-rtl-l10n/scripts/check_arb_parity.sh                 app/lib/l10n
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(l10n): persist the locale override independently of the system locale

SPEC.md §11 states the requirement and its reason in one sentence: a
Galician-speaking user may run a Spanish-locale phone. §9.1's argument for
shipping gl and ca at all — that each is the official publication language of
an instrument we bundle — is void if the app cannot be pinned to them.

Resolution is a pure function over (override, device locale LIST, supported):
exact tag, then language-only, then en. The device list rather than the first
entry, because a phone with es first and gl second is exactly the user above.
en rather than Flutter's default of supportedLocales.first, because that is
ar in ARB order — a German phone would otherwise launch right-to-left in
Arabic and look like a bug in the RTL code.

"Follow the device" is SQL NULL, not a sentinel string: locale_override holds
locale tags, and a fourth non-locale value would be a secret every reader
needs. The row lives in user.db so §12's export carries it.

Nothing is awaited before runApp: the notifier starts loading, MaterialApp
takes locale: null for frame one, and following the device is the correct
default anyway.

D5, the first-run language dialog, is E12/E16's; this is the state it writes.

Task: E06/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
