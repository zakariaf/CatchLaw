# E06/T01 — ARB scaffolding for six locales

| | |
|---|---|
| **Epic** | E06 — Localisation infrastructure |
| **Branch** | `epic/06-localisation` (shared) |
| **Commit** | `feat(l10n): scaffold six-locale ARB and gen-l10n wiring` |
| **Depends on** | E05 merged. No task in this epic. |
| **Size** | M |
| **Spec** | `SPEC.md` §9.1, §9.2 tier 1, §9.3 first two bullets; D-3 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-conventions-index` | Rule 12 names the six ARB files — and names them **wrongly** (`app_ur.arb`, `app_pt.arb`). D-3 overrules it. Load it so the correction is deliberate rather than accidental, and so rule 2's imperative ban applies to the first ARB values written |
| `i18n-rtl-l10n` | Owns `references/arb-and-icu.md`: the `l10n.yaml` key set, `nullable-getter: false`, the template-first workflow, and the iOS `CFBundleLocalizations` pitfall |
| `lonja-typography` | `references/arabic-and-scripts.md` — what changes for `ar` and, specifically, that units are glued to values with a non-breaking space **in the ARB**, never in Dart. The first ARB values must not get that wrong |
| `naming-conventions` | ARB key casing, the file-equals-primary-declaration rule for `app_localizations.dart`, and the import ordering in the app widget |
| `testing-strategy` | Which tier each assertion belongs at: `supportedLocales` is a pure unit test, direction resolution needs a widget pump |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.1 | The six locales and the justification per locale — the publication language of the instrument being bundled |
| `SPEC.md` | §9.2 "Tier 1 — UI chrome" | ARB is chrome only, ~400 strings eventually; bundled content is **not** ARB (that is T03) |
| `SPEC.md` | §9.3 bullets 1–2 | `MaterialApp` with `supportedLocales`; **no hardcoded `Directionality` anywhere** |
| `epics/DECISIONS.md` | D-3 | Exactly six ARB filenames; `ca` ships, `ur` does not; `app_pt_BR.arb` carries the region |
| `epics/DECISIONS.md` | D-1, D-5 | `app/` is the Flutter package; Flutter 3.44.6 / Dart `^3.12.0` |
| `epics/DECISIONS.md` | D-7 | The engine holds no user-visible sentence — nothing in this task adds a string to `packages/rule_engine/` |
| `FLUTTER_GUIDE.md` | §2.5 | `app/lib/l10n/` is already the home for this in the prescribed tree |
| `FLUTTER_GUIDE.md` | §7.4 | Generated files are committed to git; `.gitattributes` handles the merge noise, not `.gitignore` |
| `FLUTTER_GUIDE.md` | §9.2 | `GlobalWidgetsLocalizations` maps locale → direction; `ar` is the only RTL code we ship |
| `.claude/skills/i18n-rtl-l10n/references/arb-and-icu.md` | "l10n.yaml — the settings that matter", "Step-by-step", "Pitfalls" | The key set, template-first order, and the iOS `CFBundleLocalizations` trap |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Numerals" point 3 | Units glue to values with a non-breaking space in the ARB |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §2 | The banned imperative lexicon that every ARB value is measured against |

## What this delivers

- `app/l10n.yaml` — the `gen-l10n` configuration.
- `app/lib/l10n/app_en.arb` — **the template**. Keys and every `@key` metadata block are declared here
  and nowhere else.
- `app/lib/l10n/app_ar.arb`, `app_es.arb`, `app_gl.arb`, `app_ca.arb`, `app_pt_BR.arb` — the same keys,
  translated, no `@` metadata (D-3).
- `app/lib/l10n/gen/app_localizations.dart` and the six `app_localizations_*.dart` — generated,
  **committed** (`FLUTTER_GUIDE.md` §7.4).
- `app/lib/app.dart` — `localizationsDelegates`, `supportedLocales`, `locale: null` (device-driven;
  T06 replaces the `null`).
- `app/ios/Runner/Info.plist` — `CFBundleLocalizations` with all six, or the locale is never offered on
  iOS however well Android behaves.
- `.gitattributes` — `*.g.dart` and the generated localisations marked `linguist-generated=true -diff`.
- `app/test/l10n/arb_scaffolding_test.dart`, `app/test/l10n/locale_direction_test.dart`.

**The starter key set is four keys.** This task is scaffolding, not authoring; each later task adds the
keys it needs (T04 the numeral-system labels, T07 the language-availability notice, E07+ the screens).
Four is enough to exercise parity, a plural, and a locale-distinguishing value:

| Key | Shape | Why it is one of the four |
|---|---|---|
| `appTitle` | plain | Needed by `MaterialApp.onGenerateTitle`; the only key that is legitimately identical in all six |
| `searchResultCount` | ICU `plural`, `{count}` `int` | S5 caps at 40 results (`SPEC.md` §13). Gives T02 a real plural message to check all six `ar` categories against, in this same PR |
| `settingsLanguage` | plain | S14's label. Its value differs per locale, so a test can prove the `ar` bundle actually loaded rather than falling back to `en` |
| `settingsLanguageSystemDefault` | plain | "Follow the device" — the null-override state T06 persists |

## Why it is built this way

**Six files, and which six, is settled.** D-3 fixes the list against `SPEC.md` §9.1, where each locale
is justified by the publication language of the instrument being bundled. Three places in the skills
say `app_ur.arb` and one says `app_pt.arb`; they are wrong and E01/T09 corrects them. This task writes
the correct filenames and adds a test that asserts `ur` is **absent**, because a copy-paste from
`catchlaw-conventions-index` rule 12 is the single most likely way for this to regress.

**`nullable-getter: false` is the highest-value line in `l10n.yaml`.** With it, `AppLocalizations.of`
returns non-null and a missing or mistyped key is an **analyzer error**. Without it, a typo renders an
empty widget and ships. `arb-and-icu.md` calls it the single most valuable setting and it costs one
line.

**The template is `app_en.arb` even though English is authored last.** `SPEC.md` §9.2 point 4 says
English Tier-2 content is the *last* language authored — that is about bundled content, not chrome. The
ARB template must be the one language every tool defaults to and every generator error message quotes.
Nothing in §9.2 asks for a different template, and `gen-l10n` has one.

**Generated output is committed.** `FLUTTER_GUIDE.md` §7.4 settles this by reading `flutter/samples`,
`riverpod` and `drift` — all three commit generated Dart. For this repo it is decisive twice over: the
golden lane (T08) and every CI job then need no codegen stage, and a fresh clone analyses immediately.

**No `Directionality` is constructed anywhere.** `SPEC.md` §9.3 says so and `rtl-and-bidi.md` explains
the failure: a root `Directionality(TextDirection.rtl)` makes physical-side bugs *look* correct and
breaks any LTR island. Direction is a consequence of the resolved locale via
`GlobalWidgetsLocalizations`, and the tests below assert it by pumping two locales rather than by
inspecting source. `SPEC.md` §9.3 does record one deliberate exception — the ruler, which must not
mirror — but the ruler is E09 and does not exist yet. T05's gate is what keeps that exception from
multiplying.

**Rejected: a shared `l10n` workspace package.** `arb-and-icu.md` offers it for multi-package setups.
D-1's workspace has exactly one Flutter package (`app/`); `packages/rule_engine/` may not hold a
user-visible sentence at all (D-7) and `tools/content_builder/` is a CLI. A package for one consumer is
an indirection with no second caller.

**Rejected: `Locale('pt_BR')`.** That constructs a *language code* containing an underscore, which
matches nothing. The ARB **filename** is `app_pt_BR.arb` and the Dart value is
`Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR')` — equivalently `Locale('pt', 'BR')`.
T06's tests hammer this; T01 must not seed the wrong form in `supportedLocales`.

**Rejected: adding all ~400 keys now.** `SPEC.md` §9.2 sizes Tier 1 at ~400 strings, but a key with no
widget behind it cannot be reviewed, cannot be tested and rots. Keys arrive with their screens; parity
is enforced from key one by T02.

## Tests first

Write every row before `l10n.yaml` exists. Run them. **They must fail** — most with a compile error,
because `AppLocalizations` is not generated yet. A compile failure *is* a red test here; what must not
happen is a row that goes green before the ARB files are written. If one does, the row is asserting
something that was already true and is testing nothing — fix the row.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `AppLocalizations.supportedLocales contains ar, en, es, gl, ca and pt_BR` | — | set equality, 6 entries | D-3's whole content, asserted once |
| 2 | `AppLocalizations.supportedLocales excludes ur` | — | no `ur` entry | `catchlaw-conventions-index` rule 12 still says `app_ur.arb`; this row is what stops a copy-paste from it |
| 3 | `AppLocalizations.supportedLocales carries pt_BR as language pt with country BR` | — | `Locale('pt','BR')` | `Locale('pt_BR')` is a language code with an underscore — it matches nothing and looks right |
| 4 | `CatchlawApp resolves TextDirection.rtl when the locale is ar` | `Locale('ar')` | `TextDirection.rtl` | The one RTL locale (D-3). Proves the `Global*` delegates are registered |
| 5 | `CatchlawApp resolves TextDirection.ltr when the locale is $code` | loop: `en`, `es`, `gl`, `ca`, `pt_BR` | `TextDirection.ltr` | Five rows, parameter interpolated (`CONVENTIONS.md` §5). Catches a stray root `Directionality(rtl)` that would make all six RTL |
| 6 | `CatchlawApp flips direction when the locale changes from en to ar` | rebuild with a new `locale` | `ltr` then `rtl` | Direction must be a *consequence* of the locale, live, with no restart — the property T06 depends on |
| 7 | `ar - AppLocalizations.settingsLanguage differs from the en value` | `Locale('ar')` | not equal to the `en` string | The only cheap proof that the `ar` bundle loaded rather than silently falling back to the template |
| 8 | `l10n.yaml sets nullable-getter to false` | read `app/l10n.yaml` | key present, value `false` | A missing key here turns every later typo from an analyzer error into an empty widget. No Dart test can observe the setting after the fact |
| 9 | `app_$locale.arb declares @@locale $locale` | loop over all six files | `@@locale` equals the filename's locale | An `app_pt_BR.arb` whose `@@locale` says `pt` generates the wrong class and resolves the wrong bundle, silently |
| 10 | `app_en.arb is the only ARB carrying @ metadata blocks` | all six files | only `app_en.arb` has `@key` objects | Template-first (`arb-and-icu.md` step 1). Metadata in two files drifts, and the second copy is never regenerated |
| 11 | `Info.plist declares CFBundleLocalizations for all six locales` | read the plist | six entries incl. `pt-BR` | The documented iOS pitfall: Android offers the locale, iOS does not, and nothing fails at build time |
| 12 | `every ARB value is free of the banned imperative lexicon` | all six files | no hit | Invariant 2 (`product-invariants.md` §2) applies to ARB values from the first key, in every locale |

```dart
// app/test/l10n/arb_scaffolding_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _shipped = <Locale>[
  Locale('ar'),
  Locale('en'),
  Locale('es'),
  Locale('gl'),
  Locale('ca'),
  Locale('pt', 'BR'),
];

void main() {
  test('AppLocalizations.supportedLocales contains ar, en, es, gl, ca and pt_BR', () {
    expect(AppLocalizations.supportedLocales.toSet(), _shipped.toSet());
  });

  test('AppLocalizations.supportedLocales excludes ur', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode),
      isNot(contains('ur')),
    );
  });

  test('AppLocalizations.supportedLocales carries pt_BR as language pt with country BR', () {
    final pt = AppLocalizations.supportedLocales
        .singleWhere((l) => l.languageCode == 'pt');
    expect(pt.countryCode, 'BR');
  });

  test('l10n.yaml sets nullable-getter to false', () {
    final yaml = File('l10n.yaml').readAsStringSync();
    expect(yaml, contains(RegExp(r'^nullable-getter:\s*false\s*$', multiLine: true)));
  });

  for (final name in const <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR']) {
    test('app_$name.arb declares @@locale $name', () {
      final arb = jsonDecode(File('lib/l10n/app_$name.arb').readAsStringSync())
          as Map<String, dynamic>;
      expect(arb['@@locale'], name);
    });
  }

  // Invariant 2 — product-invariants.md §2, every locale, from the first key.
  test('every ARB value is free of the banned imperative lexicon', () {
    const banned = <String>[
      'keep', 'return', 'release', 'discard', 'throw it back',
      'put it back', 'toss', 'retain', 'land it',
    ];
    for (final name in const <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR']) {
      final arb = jsonDecode(File('lib/l10n/app_$name.arb').readAsStringSync())
          as Map<String, dynamic>;
      for (final entry in arb.entries.where((e) => !e.key.startsWith('@'))) {
        final value = (entry.value as String).toLowerCase();
        for (final word in banned) {
          expect(value, isNot(contains(word)),
              reason: 'app_$name.arb / ${entry.key} contains "$word"');
        }
      }
    }
  });
}
```

```dart
// app/test/l10n/locale_direction_test.dart
import 'package:catchlaw/app.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<TextDirection> _pumpAndReadDirection(WidgetTester tester, Locale locale) async {
  late TextDirection observed;
  await tester.pumpWidget(CatchlawApp(
    locale: locale,
    home: Builder(builder: (context) {
      observed = Directionality.of(context);
      return const SizedBox.shrink();
    }),
  ));
  await tester.pump();
  return observed;
}

void main() {
  testWidgets('CatchlawApp resolves TextDirection.rtl when the locale is ar', (tester) async {
    expect(await _pumpAndReadDirection(tester, const Locale('ar')), TextDirection.rtl);
  });

  // Loop-generated: the parameter is interpolated, per CONVENTIONS.md §5.
  for (final locale in const <Locale>[
    Locale('en'), Locale('es'), Locale('gl'), Locale('ca'), Locale('pt', 'BR'),
  ]) {
    final code = locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    testWidgets('CatchlawApp resolves TextDirection.ltr when the locale is $code',
        (tester) async {
      expect(await _pumpAndReadDirection(tester, locale), TextDirection.ltr);
    });
  }

  testWidgets('CatchlawApp flips direction when the locale changes from en to ar',
      (tester) async {
    expect(await _pumpAndReadDirection(tester, const Locale('en')), TextDirection.ltr);
    expect(await _pumpAndReadDirection(tester, const Locale('ar')), TextDirection.rtl);
  });

  testWidgets('ar - AppLocalizations.settingsLanguage differs from the en value',
      (tester) async {
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(ar.settingsLanguage, isNot(en.settingsLanguage));
  });
}
```

**Run:** `cd app && flutter test test/l10n/` → 12 rows red (rows 1–3, 5–7, 9–12 counting the loops).
Rows that fail to compile are red; that is expected until `flutter gen-l10n` has run once.

## Implementation outline

1. Write `app/l10n.yaml`. **Run `flutter gen-l10n --help` first** and take the key names from the tool
   — `arb-dir`, `template-arb-file`, `output-localization-file`, `output-class`, `nullable-getter` are
   documented in `arb-and-icu.md`; whether this Flutter still has `synthetic-package`, and whether
   `output-dir: lib/l10n/gen` needs it, is not settled in this repo (epic Risk 1). The tool names an
   unknown key in its error — read it, do not guess a second time.
2. Write `app/lib/l10n/app_en.arb` with the four keys and their `@key` metadata blocks: a
   `description` per key and a typed `placeholders` object for `searchResultCount` (`count`, `int`).
3. Mirror the four keys into the other five files, **without** `@` metadata. `ar` gets all six ICU
   plural categories on `searchResultCount`; `es`, `ca` and `pt_BR` get `one`/`many`/`other`; `gl` gets
   `one`/`other` (`SPEC.md` §9.5 — T02 turns this into a gate). Glue any unit to its value with a
   non-breaking space inside the ARB value, never in Dart (`arabic-and-scripts.md`, Numerals 3).
4. `flutter gen-l10n`, then `flutter analyze`. Commit the generated files; add the `.gitattributes`
   lines from `FLUTTER_GUIDE.md` §7.4.
5. Wire `app/lib/app.dart`: `localizationsDelegates` = `AppLocalizations.localizationsDelegates` plus
   `GlobalMaterialLocalizations.delegate`, `GlobalWidgetsLocalizations.delegate`,
   `GlobalCupertinoLocalizations.delegate`; `supportedLocales: AppLocalizations.supportedLocales`;
   `locale` a constructor parameter defaulting to `null` so the device drives it and the tests can pin
   it. T06 replaces the default with the persisted override.
6. Add the six `CFBundleLocalizations` entries to `app/ios/Runner/Info.plist` (`pt-BR` with a hyphen —
   it is a BCP-47 tag there, not a Dart filename).
7. Re-run the suite. All rows green, and nothing outside `app/` changed.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 rows (18 tests after loop expansion) pass, and each failed first.
- [ ] `app/lib/l10n/` holds exactly six `app_*.arb` files; `ls app/lib/l10n/app_*.arb | wc -l` is 6.
- [ ] `grep -rn "Directionality(" app/lib` returns nothing.
- [ ] `grep -rn "app_ur\|app_pt\.arb" app/` returns nothing.
- [ ] The generated `app_localizations*.dart` files are committed, not ignored.
- [ ] `packages/rule_engine/` is untouched by this commit (D-7).
- [ ] No ARB value contains an imperative from `product-invariants.md` §2.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/i18n-rtl-l10n/scripts/check_arb_parity.sh                  app/lib/l10n
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
```

Every gate takes its target directory explicitly (D-1): they exit 2 on a missing directory, so a bare
default would abort the run rather than scan the wrong tree.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(l10n): scaffold six-locale ARB and gen-l10n wiring

Six locales — ar, en, es, gl, ca, pt_BR — because each is the publication
language of an instrument we bundle (SPEC.md §9.1). Not ur: no bundled
instrument is published in it, and the three skill files that say otherwise
are corrected by E01/T09. The Portuguese file carries its region because the
content is Brazilian.

nullable-getter is false, so a mistyped key is an analyzer error rather than
an empty widget. No Directionality is constructed anywhere: direction is a
consequence of the resolved locale, and the tests prove it by pumping ar and
en rather than by reading source.

Four starter keys, not four hundred. A key with no widget behind it cannot be
reviewed; keys arrive with their screens, and T02 gates parity from key one.

Task: E06/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
