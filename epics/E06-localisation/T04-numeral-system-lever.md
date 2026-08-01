# E06/T04 — The numeral-system lever

| | |
|---|---|
| **Epic** | E06 — Localisation infrastructure |
| **Branch** | `epic/06-localisation` (shared) |
| **Commit** | `feat(l10n): drive the numeral system from user_profile via numberFormatSymbols` |
| **Depends on** | T01 (a resolved locale must exist); E05 (`user_profile.numeral_system`) |
| **Size** | L |
| **Spec** | `SPEC.md` §9.3 "Numerals — corrected twice"; §7.2 `user_profile.numeral_system`; §6 S14; §14 dynamic row "the numbering system matches the resolved locale (Western for ar-AE)" |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `i18n-rtl-l10n` | Owns numerals. `references/numerals-and-calendars.md` has the four digit systems, the separator trap, and the rule that the same formatter feeds chrome and canvas alike |
| `lonja-typography` | `references/arabic-and-scripts.md` — Arabic-Indic digits have **no tabular figure coverage**, so a numeral column in `ar` must be pinned rather than rely on figure widths, and citation dates stay Western-digit ISO in every locale |
| `catchlaw-conventions-index` | Rule 8: nothing is awaited before `runApp`. This task must not add an await to the launch path, and the design below is shaped by that |
| `app-startup-and-bootstrap` | Where a process-wide mutation is allowed to live, and what `main()` may and may not do before the first frame |
| `testing-strategy` | Rule 3 (round-trip), and the discipline that makes a process-wide mutation survivable in a shared isolate |
| `naming-conventions` | `NumeralSystem` enum values mirror the SQL `CHECK` set exactly; `Notifier` is the Riverpod role |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `FLUTTER_GUIDE.md` | Part 9.1 | **The finding, in full.** Verified output, the three Arabic entries, the discarded `-u-nu-` extension, `ZERO_DIGIT` as the lever, and the warning about goldens in a shared isolate |
| `SPEC.md` | §9.3 "Numerals — corrected twice" | CLDR 48 gives `ar` and `ar-AE` `defaultNumberingSystem: latn`, so plain `ar` renders Western digits and **that is correct for Khalid in RAK**. The first draft asserted the opposite |
| `SPEC.md` | §7.2 | `numeral_system TEXT NOT NULL DEFAULT 'auto' CHECK (numeral_system IN ('auto','latn','arab'))` — three values, and the Dart enum mirrors them |
| `SPEC.md` | §9.5 "Numbers", "Dates", "Units" | Locale decimal separator; dates via `intl`; everything stored as integer millimetres and converted only for display |
| `SPEC.md` | §14, last dynamic row | The device-level check: in `ar`, "the numbering system matches the resolved locale (Western for ar-AE)" |
| `SPEC.md` | §6, S14 | Where the user chooses: auto / Western / Arabic-Indic |
| `epics/DECISIONS.md` | D-5 | The toolchain floor. `intl`'s version is **not** pinned there — see "Why it is built this way" |
| `.claude/skills/i18n-rtl-l10n/references/numerals-and-calendars.md` | "The four digit systems", "Format — pin the numbering system", "Separators — the trap" | U+0660–0669 is Arabic-Indic and U+06F0–06F9 is Persian — distinct blocks; and the `-u-` extension is dropped during `verifiedLocale` fallback |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Numerals", points 1–5 | No tabular figures on Arabic-Indic digits; citation dates stay Western |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §3 | "Digits stay Western in every locale including `ar`… because they are quoted from a printed instrument" — the numeral lever must not reach a citation |

## The finding this task exists for

This is not a preference and it is not a line of configuration. `FLUTTER_GUIDE.md` Part 9.1 records
measured output; `SPEC.md` §9.3 records the same finding and the correction it forced. Restated here
because the whole design follows from it:

1. **`intl` has no numbering-system API at all.** There is no parameter, no setter, no locale option.
2. **The `-u-nu-` Unicode extension is accepted as a string and silently discarded.**
   `NumberFormat.decimalPattern('ar-u-nu-arab').format(1234567)` returns `1,234,567`. It does not throw
   and it does not warn. Anyone "fixing" this task by passing a locale extension will see code that
   compiles, runs, and is wrong.
3. **`number_symbols_data.dart` contains only three Arabic entries: `ar`, `ar_DZ`, `ar_EG`.** So
   `ar_SA`, `ar_MA` and `ar_AE` all fall back to `ar` and render Latin digits regardless of what CLDR
   says. `ar_DZ` renders Latin digits with *European* separators (`1.234.567,89`).
4. **CLDR 48 gives `ar` and `ar-AE` `defaultNumberingSystem: latn`.** Plain `ar` rendering Western
   digits is therefore *correct*, and it is the correct default for Khalid in Ras Al Khaimah.
   `SPEC.md` §9.3 records that the first draft asserted the opposite.
5. **The only supported lever is the public mutable `numberFormatSymbols` map**, where `ZERO_DIGIT`
   *is* the numbering system: `NumberFormat` computes `zeroOffset = ZERO_DIGIT.codeUnitAt(0) -
   asciiZero`. The swap is `numberFormatSymbols['ar'] = numberFormatSymbols['ar_EG']!`.
6. **That mutation is process-wide and order-dependent.** It must run before the `NumberFormat` that
   should observe it is constructed, and **it will silently corrupt golden tests sharing an isolate
   unless it is reset in `setUp` and `tearDown`.**

Point 6 is why this is a task and not a line.

## What this delivers

- `app/lib/l10n/numeral_system.dart`
  - `enum NumeralSystem { auto, latn, arab }` — the three values of the SQL `CHECK` (`SPEC.md` §7.2),
    with `fromDbValue` / `dbValue`.
  - `void applyNumeralSystem(NumeralSystem system)` — the map swap, idempotent, with the original `ar`
    entry captured once on first call and restored for `auto` and `latn`.
  - `NumberFormat numberFormatFor(Locale locale)` — the single formatter factory, constructed fresh on
    every call. Chrome and any painter use this one function
    (`numerals-and-calendars.md`, "Format — pin the numbering system").
  - `String normaliseDigitsToAscii(String input)` — folds U+0660–0669 and U+06F0–06F9 plus the `٫`
    U+066B decimal and `٬` U+066C grouping separators, for the S3 manual-entry keypad.
- `app/lib/l10n/numeral_system_notifier.dart` — `NumeralSystemNotifier`, an `AsyncNotifier` reading
  `user_profile.numeral_system` and calling `applyNumeralSystem`. The **one** place app code applies it.
- `app/lib/main.dart` — one synchronous call, `applyNumeralSystem(NumeralSystem.auto)`, before
  `runApp`. No await added (`catchlaw-conventions-index` rule 8).
- `app/testing/l10n/number_symbols_guard.dart` — `captureNumberSymbols()` /
  `restoreNumberSymbols()` / `assertNumberSymbolsPristine()`, used by every digit-sensitive test's
  `setUp` and `tearDown`, and by T08's `flutter_test_config.dart`.
- `app/lib/l10n/app_*.arb` — three new keys in all six files: `settingsNumeralSystem`,
  `settingsNumeralSystemAuto`, `settingsNumeralSystemLatn`, `settingsNumeralSystemArab`. Labels only;
  S14 is E16's.
- `app/test/l10n/numeral_system_test.dart`, `app/test/l10n/numeral_system_notifier_test.dart`,
  `app/test/l10n/no_cached_number_format_test.dart`.

## Why it is built this way

**The lever is the map, because there is no other lever.** Point 2 of the finding removes the obvious
alternative. Point 3 removes the second one — pinning `ar_AE` and letting CLDR decide does nothing,
because `intl` has no `ar_AE`. What remains is `ZERO_DIGIT`.

**`auto` and `latn` are the same swap — none — and that is deliberate, not an oversight.** `auto` means
"whatever CLDR says for the resolved locale", and CLDR 48 says `latn` for `ar` and `ar-AE` (finding
point 4). So today `auto` and `latn` produce identical output for every one of the six locales. They
are kept as separate values anyway, because `auto` is a *statement about deference* and `latn` is a
*statement about preference*: if a future CLDR or a future bundled jurisdiction changes the default for
some locale, `auto` must follow it and `latn` must not. Collapsing them now would silently convert
every user's deference into a preference.

**Order-dependence is handled by forbidding cached formatters, not by racing the bootstrap.**
`NumberFormat` captures its symbols at construction. The naive reading of finding point 6 is "read
`user_profile` before `runApp`" — but that is an await on the launch path, which
`catchlaw-conventions-index` rule 8 forbids and which `SPEC.md` §13 prices at a 1.2 s cold-start budget
we would be spending on a black screen. So instead:

- `main()` calls `applyNumeralSystem(NumeralSystem.auto)` synchronously. Zero I/O, zero await; the map
  is in a known state before anything in the process touches `intl`.
- Every `NumberFormat` in `app/lib` is constructed **at the point of use** through `numberFormatFor`,
  never stored. A formatter that is never retained cannot be stale.
- `NumeralSystemNotifier` applies the stored value when `user_profile` resolves. Anything that renders
  a number watches it, so a rebuild follows the swap.
- Row 13 below is a source scan asserting no top-level or `static final NumberFormat` exists in
  `app/lib`. That single grep is what makes the three bullets above true rather than aspirational.

**The test discipline is part of the deliverable.** Finding point 6's second half — *silently corrupt
golden tests sharing an isolate* — is the failure that costs a day: a golden fails in a file nobody
edited, with a diff showing digits, and the cause is three files away. `number_symbols_guard.dart`
exists so that discipline is one import rather than a habit, and T08 installs the pristine assertion at
the file level so the guard cannot be forgotten quietly.

**Citations are out of reach by construction.** `product-invariants.md` §3 requires citation digits to
stay Western in every locale, because they quote a printed instrument. Citation dates are stored and
rendered as ISO strings (`2015-11-03`), not through `NumberFormat`, so no map swap can reach them.
Row 12's absence from the list is deliberate: the invariant is preserved *structurally*, and E10 — which
renders the citation footnote — owns the assertion. It is named in this task's definition of done so
the reasoning is not lost.

**The `intl` version is under-determined and the tests are the resolution.** `SPEC.md` §10 lists
`intl ^0.19`; `FLUTTER_GUIDE.md` Part 9.1's output was verified on **0.20.2**; D-5 pins Flutter, Dart,
Riverpod and drift but not `intl`. This task does not invent a pin. Rows 1–4 assert the *emitted digit
block and the map's key set*, so whichever version resolves, the suite states the truth and a version
bump that changes the finding fails loudly. The resolved version goes in the commit body — a fact, not
a decision.

**Rejected: `Intl.defaultLocale = 'ar_EG'`.** It changes month names, the decimal separator and the
grouping separator along with the digits. `ar_EG` formatting is Egyptian, and Khalid is not in Egypt.
The finding's `ar_DZ` line is the warning: a locale swap drags an entire symbol set, separators and all.

**Rejected: post-processing formatted output with a digit-substitution pass.** It is what
`numerals-and-calendars.md`'s `localizeDigits` does for libraries that emit ASCII and have no symbol
table — a last resort for `shamsi_date` and `hijri`. `intl` *has* a symbol table, and substituting
after the fact would also rewrite digits inside strings that must stay Western (a citation, an
instrument number, a content version).

**Rejected: a `NumeralSystem` field on the rule engine's output.** D-7. The engine returns numbers; the
app formats them.

**Rejected: swapping `numberFormatSymbols['en']` for the `latn` case.** There is nothing to swap —
`en` is already Latin, and mutating an entry nobody asked about widens the blast radius of a
process-wide mutation for no gain. Row 8 asserts the blast radius stays at one key.

## Tests first

Write every row before `numeral_system.dart` exists. Run them. **They must fail.** Row 1 is the
dangerous one: `NumberFormat.decimalPattern('ar')` already emits Latin digits, so a naively written row
1 passes before any implementation exists. That does not make it a good test — it makes it a
**characterisation** row, and it must be written to fail first by asserting through
`numberFormatFor(const Locale('ar'))`, which does not compile yet. If any row is green before the
implementation, the row is wrong.

**Every row in this file runs under this `setUp`/`tearDown` pair. No exceptions:**

```dart
setUp(captureNumberSymbols);
tearDown(restoreNumberSymbols);
```

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `numberFormatFor emits Latin digits for ar before any swap` | `Locale('ar')`, 1234567 | `1,234,567` | Finding point 4. CLDR 48 says `latn` for `ar`, and this is the correct default for Khalid in RAK. The spec's first draft asserted the opposite |
| 2 | `NumberFormat.decimalPattern with a -u-nu-arab extension emits Latin digits` | `'ar-u-nu-arab'`, 1234567 | Latin digits | Finding point 2. The extension is accepted as a string and discarded. This row is the tombstone on the "obvious" fix |
| 3 | `numberFormatSymbols carries exactly ar, ar_DZ and ar_EG for Arabic` | the map's keys | `{ar, ar_DZ, ar_EG}` | Finding point 3. If a future `intl` adds `ar_AE` this row goes red and the whole lever can be reconsidered — which is the only way we would ever find out |
| 4 | `numberFormatFor emits the same digits for ar_AE as for ar` | `Locale('ar','AE')`, 1234567 | identical strings | The silent fallback, on Khalid's actual locale. Named in `SPEC.md` §14's last dynamic row |
| 5 | `applyNumeralSystem(arab) makes numberFormatFor emit U+0660 to U+0669 for ar` | `arab`, 1234567 | every digit in U+0660–0669 | The lever works. Asserted on **code points**, not on a string literal — a literal in a test file is invisible to review |
| 6 | `applyNumeralSystem(latn) restores Latin digits for ar after arab was applied` | `arab` then `latn` | `1,234,567` | The toggle is two-way. A one-way door would strand a user who tried Arabic-Indic once |
| 7 | `applyNumeralSystem(auto) leaves ar on Latin digits` | `auto` | `1,234,567` | `auto` defers to CLDR 48, which says `latn`. If this ever changes, `auto` must follow and `latn` must not |
| 8 | `applyNumeralSystem(arab) leaves the es formatter unchanged` | `arab`, `Locale('es')`, 1234.5 | `1.234,5` | Blast radius. A process-wide mutation that touched a second key would break the `es`/`gl`/`ca`/`pt_BR` decimal comma (`SPEC.md` §9.5, `45,5 cm`) |
| 9 | `applyNumeralSystem is idempotent when called twice with arab` | `arab`, `arab`, then `latn` | Latin digits restored | **The bug this row exists for:** a second `arab` call that re-captures the *already swapped* entry as the "original" makes `latn` unrecoverable. Nothing else would catch it |
| 10 | `a NumberFormat constructed before applyNumeralSystem(arab) keeps Latin digits` | construct, then swap, then format | Latin digits | Finding point 6's order-dependence, made visible. This is the row that justifies rows 13 and the no-caching rule |
| 11 | `restoreNumberSymbols returns numberFormatSymbols['ar'] to its original entry` | swap, restore | identical entry | The isolate-hygiene contract that protects every golden in T08 |
| 12 | `NumeralSystem.fromDbValue maps auto, latn and arab and throws on any other value` | `'auto'`, `'latn'`, `'arab'`, `'arabext'` | three values, then throws | Mirrors the SQL `CHECK` (`SPEC.md` §7.2). An unknown value must not silently become `auto` — that would hide a corrupt `user.db` |
| 13 | `app/lib holds no top-level or static final NumberFormat` | source scan of `app/lib` | no match | A retained formatter captures symbols at construction (row 10) and survives every later swap. One grep is what makes the whole design hold |
| 14 | `NumeralSystemNotifier applies arab when user_profile.numeral_system is arab` | in-memory `user.db` | `ar` emits Arabic-Indic | The wiring, driven headlessly through `ProviderContainer` (`testing-strategy` rule 7) |
| 15 | `NumeralSystemNotifier restores Latin digits when the stored value changes from arab to latn` | write `latn`, re-read | Latin digits | The live S14 toggle, with no restart |
| 16 | `normaliseDigitsToAscii folds Arabic-Indic digits and the U+066B decimal separator` | `'١٫٥'` | `'1.5'` | `1٫5` means 1.5, not 15. The S3 keypad accepts what an Arabic soft keyboard emits, and `int.parse` on raw input throws |
| 17 | `normaliseDigitsToAscii round-trips every integer formatted by numberFormatFor for $locale` | loop over the six locales, seeded values | parses back equal | Round-trip invariant (`testing-strategy` rule 3); the parameter is interpolated so `--plain-name` works |

```dart
// app/test/l10n/numeral_system_test.dart
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/number_symbols_data.dart';

import '../../testing/l10n/number_symbols_guard.dart';

bool _isArabicIndic(String formatted) => formatted
    .runes
    .where((r) => !'٬٫'.runes.contains(r))
    .every((r) => r >= 0x0660 && r <= 0x0669);

void main() {
  // Process-wide and order-dependent (FLUTTER_GUIDE.md Part 9.1). Without this
  // pair, one test in this file silently corrupts every later golden in the isolate.
  setUp(captureNumberSymbols);
  tearDown(restoreNumberSymbols);

  test('numberFormatFor emits Latin digits for ar before any swap', () {
    expect(numberFormatFor(const Locale('ar')).format(1234567), '1,234,567');
  });

  test('numberFormatSymbols carries exactly ar, ar_DZ and ar_EG for Arabic', () {
    final arabic = numberFormatSymbols.keys
        .cast<String>()
        .where((k) => k == 'ar' || k.startsWith('ar_'))
        .toSet();
    expect(arabic, {'ar', 'ar_DZ', 'ar_EG'});
  });

  test('applyNumeralSystem(arab) makes numberFormatFor emit U+0660 to U+0669 for ar', () {
    applyNumeralSystem(NumeralSystem.arab);
    expect(_isArabicIndic(numberFormatFor(const Locale('ar')).format(1234567)), isTrue);
  });

  test('applyNumeralSystem is idempotent when called twice with arab', () {
    applyNumeralSystem(NumeralSystem.arab);
    applyNumeralSystem(NumeralSystem.arab); // must not re-capture the swapped entry
    applyNumeralSystem(NumeralSystem.latn);
    expect(numberFormatFor(const Locale('ar')).format(1234567), '1,234,567');
  });

  test('a NumberFormat constructed before applyNumeralSystem(arab) keeps Latin digits', () {
    final early = numberFormatFor(const Locale('ar'));
    applyNumeralSystem(NumeralSystem.arab);
    expect(early.format(1234567), '1,234,567');           // symbols captured at construction
    expect(_isArabicIndic(numberFormatFor(const Locale('ar')).format(1234567)), isTrue);
  });

  test('applyNumeralSystem(arab) leaves the es formatter unchanged', () {
    applyNumeralSystem(NumeralSystem.arab);
    expect(numberFormatFor(const Locale('es')).format(1234.5), '1.234,5');
  });

  test('normaliseDigitsToAscii folds Arabic-Indic digits and the U+066B decimal separator',
      () {
    expect(normaliseDigitsToAscii('١٫٥'), '1.5');          // 1٫5 is 1.5, never 15
  });

  for (final locale in const <Locale>[
    Locale('ar'), Locale('en'), Locale('es'),
    Locale('gl'), Locale('ca'), Locale('pt', 'BR'),
  ]) {
    final code = locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    test('normaliseDigitsToAscii round-trips every integer formatted by '
        'numberFormatFor for $code', () {
      applyNumeralSystem(NumeralSystem.arab);              // the hostile case
      for (final value in const <int>[0, 1, 45, 450, 2400, 1234567]) {
        final formatted = numberFormatFor(locale).format(value);
        expect(int.parse(normaliseDigitsToAscii(formatted).replaceAll(RegExp(r'[.,]'), '')),
            value,
            reason: 'locale=$code value=$value formatted=$formatted');
      }
    });
  }
}
```

```dart
// app/test/l10n/no_cached_number_format_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // A retained NumberFormat captures its symbols at construction and survives
  // every later applyNumeralSystem call. FLUTTER_GUIDE.md Part 9.1.
  test('app/lib holds no top-level or static final NumberFormat', () {
    final offenders = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (RegExp(r'^\s*(static\s+)?final\s+NumberFormat\b').hasMatch(line)) {
          offenders.add('${file.path}:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'construct through numberFormatFor at the point of use; never retain');
  });
}
```

**Run:** `cd app && flutter test test/l10n/` → 17 rows red (22 tests after the loop expands). Row 1 must
be written against `numberFormatFor`, not against `NumberFormat.decimalPattern`, or it passes before
the implementation exists and proves nothing.

## Implementation outline

1. Write `number_symbols_guard.dart` **first**. Everything else in this task mutates a process-wide
   map; the guard is what makes running the tests safe.
2. Write `numeral_system.dart`:
   - the enum and `fromDbValue`/`dbValue`, mirroring the §7.2 `CHECK` set exactly;
   - a private, nullable `_originalArabicSymbols`, captured **only if still null** — this is row 9;
   - `applyNumeralSystem`: `arab` assigns `numberFormatSymbols['ar'] = numberFormatSymbols['ar_EG']!`;
     `auto` and `latn` restore the captured original;
   - `numberFormatFor(Locale)` — `NumberFormat.decimalPattern` on the locale's string form, constructed
     fresh every call, no memo, no `static`;
   - `normaliseDigitsToAscii` — both digit ranges *and* both separators
     (`numerals-and-calendars.md`: folding digits but not separators silently corrupts entered amounts).
   - `import 'package:intl/number_symbols_data.dart';` for `numberFormatSymbols`. If that is not the
     library exporting it on the resolved `intl`, the analyzer says so on the first compile — read the
     package's `lib/`, do not guess a second path (epic Risk 4).
3. Make rows 1–13 green. Row 13 is a source scan and will be green immediately; keep it, because its
   job starts in E08.
4. Add the one synchronous `applyNumeralSystem(NumeralSystem.auto)` call to `main()` **before**
   `runApp`. Assert by reading the diff that no `await` was added to the launch path
   (`catchlaw-conventions-index` rule 8; `SPEC.md` §13's 1.2 s cold start).
5. Write `NumeralSystemNotifier` over the E05 `user_profile` repository and make rows 14–15 green
   through `ProviderContainer`, not through a pump.
6. Add the four ARB keys to all six files. T02's gate is now live and will fail the moment one file is
   missed — that is the intended experience.
7. Re-run the **whole** suite, not just `test/l10n/`. A leaked symbol map shows up as an unrelated
   failure elsewhere, and that is exactly the signal to catch now rather than in E20.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 rows pass, and each failed first.
- [ ] Every test in this task's files runs under `captureNumberSymbols` / `restoreNumberSymbols`.
- [ ] The full suite passes when run twice in a row and when run with the file order reversed — a
      leaked symbol map is order-dependent by nature.
- [ ] `main()` gained exactly one synchronous call and **no** `await` (rule 8).
- [ ] `grep -rn "numberFormatSymbols" app/lib` matches exactly one file: `numeral_system.dart`.
- [ ] `grep -rn "u-nu-" app/lib` returns nothing outside a comment citing the finding.
- [ ] No `NumberFormat` is retained anywhere in `app/lib` (row 13).
- [ ] `NumeralSystem`'s values are exactly `auto`, `latn`, `arab` — the §7.2 `CHECK` set, no more.
- [ ] Citation rendering is untouched: citation dates remain ISO strings, so no swap can reach them
      (`product-invariants.md` §3). E10 owns the assertion; this task owns not breaking it.
- [ ] The resolved `intl` version is recorded in the commit body as a fact.
- [ ] The four new ARB keys exist in all six files and T02's gate is green.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/i18n-rtl-l10n/scripts/check_arb_parity.sh                  app/lib/l10n
.claude/skills/i18n-rtl-l10n/scripts/check_i18n_bans.sh                   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh               app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(l10n): drive the numeral system from user_profile via numberFormatSymbols

intl has no numbering-system API. The -u-nu- extension is accepted as a
string and silently discarded, and number_symbols_data.dart carries only ar,
ar_DZ and ar_EG — so ar_AE falls back to ar and renders Latin digits. Which
is correct: CLDR 48 gives ar and ar-AE defaultNumberingSystem latn, and
Western digits are the right default for Khalid in Ras Al Khaimah. SPEC.md
§9.3 records that the first draft asserted the opposite.

So the lever is the public mutable numberFormatSymbols map, where ZERO_DIGIT
is the numbering system. That mutation is process-wide and order-dependent,
which shapes everything else here: main() applies the default synchronously
with no await (rule 8), every NumberFormat is built at the point of use and
never retained — enforced by a source scan — and every digit-sensitive test
captures and restores the map, or it corrupts every later golden in the
isolate without saying so.

auto and latn produce identical output today and stay separate values on
purpose: auto defers to CLDR, latn is a user preference, and collapsing them
would convert deference into preference behind the user's back.

intl resolved to <version> in this workspace; the tests assert the emitted
digit block rather than the version, so a bump that changes the finding fails
loudly.

Task: E06/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
