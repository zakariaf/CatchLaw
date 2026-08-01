# E20/T03 — Numerals end to end, and the `numberFormatSymbols` reset

| | |
|---|---|
| **Epic** | E20 — RTL and locale hardening |
| **Branch** | `epic/20-rtl-hardening` (shared) |
| **Commit** | `test(l10n): pin numeral rendering end to end and guard numberFormatSymbols per test` |
| **Depends on** | T01 (the golden lane exists and is the thing a leaked swap would corrupt) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.3 "Numerals — corrected twice", §9.5 "Numbers", §6 S14, §14 last dynamic item |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `i18n-rtl-l10n` | Owns numerals: `references/numerals-and-calendars.md` carries the four digit systems, the separator trap, and the rule that every numeric input is normalised to ASCII before parse |
| `lonja-typography` | `references/arabic-and-scripts.md` decides the typographic consequences either way: Arabic-Indic digits have no tabular coverage, so the column is pinned; citation dates stay Western-digit ISO in every locale |
| `catchlaw-measurement-ruler` | Rule 1 and rule 11 — lengths are integer millimetres and a display string never travels back into a field, a query or a comparison |
| `catchlaw-conventions-index` | Invariant 3: the citation is a quotation from a printed instrument, which is why its digits do not localise |
| `testing-strategy` | Rule 3 (round-trip on every conversion) and rule 11 (a leaked global is the classic shared-mutable-state flake) |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.3, "Numerals — corrected twice" | Plain `ar` renders Western digits and that is correct for Ras Al Khaimah; `intl` has no numbering-system API; `-u-nu-` is accepted as a string and discarded; the only lever is `numberFormatSymbols`; the swap is process-wide and order-dependent |
| `SPEC.md` | §9.5, "Numbers" and "Units" | Locale decimal separator (`45,5 cm` in es/pt_BR/gl/ca); everything stored as integer millimetres, conversion display-only |
| `SPEC.md` | §6, S14 | `numeral system (auto / Western / Arabic-Indic)` is a user-facing setting, so all three branches are reachable by a user |
| `SPEC.md` | §14, last dynamic item | "the numbering system matches the resolved locale (Western for ar-AE)" |
| `FLUTTER_GUIDE.md` | Part 9.1, in full | The verified output table on intl 0.20.2 / Dart 3.12.2, the `ZERO_DIGIT` mechanism, and the warning about goldens sharing an isolate |
| `.claude/skills/i18n-rtl-l10n/references/numerals-and-calendars.md` | "The four digit systems", "Separators — the trap", "Parse — normalize FIRST" | U+0660–0669 vs U+06F0–06F9 are distinct blocks; `٫` U+066B is a decimal point and `٬` U+066C a grouping mark; `double.parse(normalizeToAscii(text))`, never `int.parse` on raw input |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Numerals", points 1–5 | No tabular coverage for Arabic-Indic; pin the column with `LonjaMeasure.digitColumn`; units glued with a non-breaking space in the ARB; **citation dates stay Western-digit ISO in every locale** |
| `.claude/skills/catchlaw-measurement-ruler/SKILL.md` | rules 1, 3, 11 | Integer millimetres; no figure without its method; one rounding, at capture |
| `epics/DECISIONS.md` | D-7 | The engine holds no user-visible sentence — every formatted number is assembled in `app/lib/ui/` |

## What this delivers

- `app/testing/l10n/numeral_symbols.dart` — the shared guard. `guardNumberFormatSymbols()` installs
  the `setUp`/`tearDown` pair; `withArabicIndicDigits(void Function() body)` performs the swap and
  restores it even if the body throws. A helper, so it does **not** end in `_test.dart`
  (`CONVENTIONS.md` §6).
- `app/test/l10n/numeral_system_test.dart` — the `intl`-behaviour rows and the guard's own tests.
- `app/test/ui/settings/numeral_preference_test.dart` — the end-to-end rows: the S14 preference
  driving what a rendered measurement, a citation and a manual-entry field actually contain.
- `app/test/ui/golden/golden.dart` — edited to delegate to the shared guard instead of carrying its
  own copy. T01 wrote the local version because the guard did not exist yet; two copies of a
  process-wide reset is exactly the drift `CONVENTIONS.md` §4 warns about.
- Any wiring gap this exposes in `app/lib/` is closed **in this commit** and named in the body.

## Why it is built this way

**The test encodes the finding, not the theory.** CLDR 48 gives `ar` and `ar-AE`
`defaultNumberingSystem: "latn"`, and `SPEC.md` §9.3 records that the first draft asserted the
opposite. But the thing that decides what a fisher sees is not CLDR — it is
`intl`'s `number_symbols_data.dart`, which contains **three** Arabic entries and no API to choose
among them. `FLUTTER_GUIDE.md` Part 9.1 measured the consequences on 0.20.2 / Dart 3.12.2:

```
ar            1,234,567.89        Latin digits
ar_EG         ١٬٢٣٤٬٥٦٧٫٨٩         Arabic-Indic
ar_DZ         1.234.567,89        Latin digits, European separators
ar_SA / ar_MA / ar_AE             fall back to ar
ar-u-nu-arab  1,234,567           the extension is accepted as a string and discarded
```

Every row in the first block below asserts one line of that table. If a future `intl` changes any of
them, this file is where it is discovered — one file, named failures, rather than an Arabic build that
quietly starts rendering the wrong digit block.

**`ZERO_DIGIT` *is* the numbering system.** `NumberFormat` computes
`zeroOffset = symbols.ZERO_DIGIT.codeUnitAt(0) - asciiZero`, so assigning
`numberFormatSymbols['ar'] = numberFormatSymbols['ar_EG']!` is not a hack around the API — it is the
mechanism. The test asserts `ar_EG`'s `ZERO_DIGIT` is U+0660 so the swap's meaning is pinned rather
than assumed.

**The reset is `setUp` *and* `tearDown`, and the `tearDown` asserts.** A `tearDown` that only restores
leaves a test that swapped and crashed mid-way looking innocent. The guard restores the snapshot and
then asserts `ZERO_DIGIT == '0'`, so a leak fails in the test that caused it rather than in whatever
runs next. This matters most for T01: 60 goldens sharing an isolate with one leaked swap re-render
every digit, and the failure mode is a *plausible-looking* diff that somebody re-blesses.

**Order-dependence is asserted, not assumed.** `FLUTTER_GUIDE.md` Part 9.1 says the swap "must happen
before the first `NumberFormat` is built". A `NumberFormat` constructed before the swap keeps its
digits afterwards, because it captured `zeroOffset` at construction. One row constructs a formatter,
swaps, formats, and asserts Latin digits — which turns a warning in a document into a property of the
build. It is also the row that explains why the runtime-switch row below exists.

**The runtime-switch row is where the real bug lives.** S14 lets the user change the numeral system
while the app is running. That only works if formatters are built per render. A `static final
NumberFormat` cached at class level anywhere in `app/lib/` renders the old digit block forever and
looks completely correct in every screenshot taken after a restart. No lint and no gate script catches
it; `check_i18n_bans.sh` covers geometry, icons, number splices, legacy bidi and font fetch, not a
cached formatter. So it is a behavioural test: flip the preference, pump, assert the digits changed.

**Where the swap runs, and why not literally in `main()`.** `FLUTTER_GUIDE.md` Part 9.1 says "do it in
`main()` before `runApp`". `catchlaw-conventions-index` rule 8 says nothing is awaited before
`runApp`, and cold start is budgeted at **< 1.2 s** (`SPEC.md` §13). Those are compatible, because the
expensive half is not the swap — a map assignment costs microseconds — it is *reading the preference*
out of `user.db`. So the swap runs when the numeral-system preference resolves, which is before the
first frame that formats anything, and the ordering constraint is proved by the order-dependence row
above rather than trusted. The engine is not involved at all: D-7 keeps every formatted string in
`app/lib/ui/`.

**Rejected: passing `ar-u-nu-arab` as a locale.** It is the documented-looking answer, it compiles, it
resolves, and it silently produces Latin digits. A row asserts exactly that, so nobody re-derives it.

**Rejected: a second numeral-formatting helper in `packages/rule_engine/`.** D-7 — the engine returns
integer millimetres and enum-tagged findings, and holds no user-visible sentence in any language.

**Rejected: asserting `auto` and `latn` render differently.** Under `intl` 0.20.2 they coincide for
every locale CATCHLAW ships, because `ar` is the only RTL locale and its `intl` default is Latin. Both
are asserted to render Latin **and** a comment records why the `auto` branch is not dead code: `auto`
means "whatever the resolved locale's CLDR default is", and the day a locale with a non-`latn` default
ships, the two diverge without any call site changing.

## Tests first

Write all of them before touching `app/testing/` or `app/lib/`. Run them. **They must fail** — the
guard does not exist, and the end-to-end rows assert behaviour nothing has ever exercised. A row that
passes early is a row asserting something already true for a different reason: rows 1 and 2 in
particular are `intl` facts and *will* pass once the file compiles, which is why they carry no
implementation of their own. They are regression pins, and the file's red-first evidence comes from
rows 8 onward.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `NumberFormat.decimalPattern('ar') formats 1234567.89 with Latin digits` | `1234567.89` | `1,234,567.89` | §9.3's headline correction: plain `ar` is Western, and that is right for Khalid in RAK |
| 2 | `NumberFormat.decimalPattern('ar_EG') formats 1234567.89 with Arabic-Indic digits` | same | `١٬٢٣٤٬٥٦٧٫٨٩` | The only Arabic entry in `intl` that yields U+0660–0669 — the source the swap borrows from |
| 3 | `NumberFormat.decimalPattern('ar_DZ') formats 1234567.89 with European separators` | same | `1.234.567,89` | The third entry, and the trap: Latin digits with `.` grouping. Borrowing `ar_DZ` by mistake changes separators, not digits |
| 4 | `NumberFormat.decimalPattern('ar-u-nu-arab') discards the extension` | `1234567` | `1,234,567` | The documented-looking answer that silently does nothing. Asserted so nobody re-derives it |
| 5 | `NumberFormat.decimalPattern('ar_AE') falls back to ar` | `1234567.89` | `1,234,567.89` | §14's "Western for ar-AE" — the fisher's own region resolves to the base entry |
| 6 | `numberFormatSymbols carries exactly ar, ar_DZ and ar_EG` | key scan | that set | The finding underneath rows 1–5. If a future `intl` adds `ar_SA`, row 5 changes meaning and this row is what says so |
| 7 | `numberFormatSymbols['ar_EG'] declares ZERO_DIGIT U+0660` | code unit | `0x0660` | `ZERO_DIGIT` *is* the numbering system; the swap is meaningless without this |
| 8 | `withArabicIndicDigits formats 45 as ٤٥ inside its body` | `45` | `٤٥` | The lever itself, proved at the smallest possible scope |
| 9 | `withArabicIndicDigits restores ZERO_DIGIT to 0 after its body throws` | body that throws | `'0'` afterwards | A swap left behind by a *failing* test is the one that corrupts the next sixty |
| 10 | `guardNumberFormatSymbols restores ZERO_DIGIT after a swapping test` | swap without restore | `'0'` in the next test | The `setUp`/`tearDown` contract `SPEC.md` §9.3 demands, asserted rather than trusted |
| 11 | `NumberFormat constructed before the swap keeps Latin digits after it` | construct → swap → format | `45` | Proves the order-dependence in Part 9.1 is real, and is the reason the runtime-switch row exists |
| 12 | `ar - MeasurementText renders 45 cm with Latin digits when numeralSystem is auto` | 450 mm, TL | contains `45`, not `٤٥` | The shipped default. §9.3 says Western is correct for `ar`; if this ever flips, a fisher's minimum-size comparison changes glyph block overnight |
| 13 | `ar - MeasurementText renders ٤٥ when numeralSystem is arab` | 450 mm, TL | contains `٤٥` (U+0664 U+0665) | The S14 setting has to do something, and this is the only thing it does |
| 14 | `ar - MeasurementText renders 45 with Latin digits when numeralSystem is latn` | 450 mm, TL | contains `45` | The third branch of the S14 control; asserted so the enum has no unreachable case |
| 15 | `ar - MeasurementText re-renders its digits when numeralSystem changes at runtime` | auto → arab, one pump | digits change in place | Catches a `static final NumberFormat`, which no lint and no gate script can see and which every post-restart screenshot hides |
| 16 | `ar - CitationFootnote keeps Western digits in published and checked dates when numeralSystem is arab` | `2015-11-03` · `2026-07-14` | ASCII digits | Invariant 3 and `arabic-and-scripts.md` numeral rule 5: a citation quotes a printed record, it does not present a number to read |
| 17 | `ar - MeasurementText keeps its method label beside the figure when numeralSystem is arab` | 450 mm, TL | method text present | `catchlaw-measurement-ruler` rule 3 — a bare `٤٥` is a defect in any numeral system |
| 18 | `es - MeasurementText renders 45,5 cm with a comma decimal separator` | 455 mm | contains `45,5` | §9.5: the Latin locales carry a different decimal mark, and an `ar`-only numeral task that ignored them would ship `45.5` to Galicia |
| 19 | `ManualLengthField stores 450 mm when ٤٥ is entered in centimetres` | `٤٥` | `lengthMm == 450` | `i18n-rtl-l10n` rule 7: an Arabic soft keyboard yields U+0660-block digits and `int.parse` throws on them. The cost is a lost measurement with the fish already in the bin |
| 20 | `ManualLengthField stores 455 mm when ٤٥٫٥ is entered in centimetres` | `٤٥٫٥` | `lengthMm == 455` | `1٫5` means 1.5, not 15. Normalising digits but not separators corrupts the entry silently |

```dart
// app/testing/l10n/numeral_symbols.dart   — helper, never shipped, never *_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/number_symbols_data.dart' show numberFormatSymbols;

/// The one lever SPEC.md §9.3 leaves open: ZERO_DIGIT *is* the numbering system, because
/// NumberFormat computes zeroOffset = ZERO_DIGIT.codeUnitAt(0) - asciiZero.
void useArabicIndicDigits() =>
    numberFormatSymbols['ar'] = numberFormatSymbols['ar_EG']!;

/// Swap for the duration of [body] and restore even when it throws.
T withArabicIndicDigits<T>(T Function() body) {
  final saved = numberFormatSymbols['ar']!;
  useArabicIndicDigits();
  try {
    return body();
  } finally {
    numberFormatSymbols['ar'] = saved;
  }
}

/// Install in any file that formats a number. The swap is PROCESS-WIDE: without this a
/// leak from one test re-renders every digit in every later test in the same isolate,
/// goldens included, and the diff looks plausible enough to re-bless.
void guardNumberFormatSymbols() {
  late Object saved;
  setUp(() => saved = numberFormatSymbols['ar']!);
  tearDown(() {
    numberFormatSymbols['ar'] = saved as dynamic;
    expect((numberFormatSymbols['ar']! as dynamic).ZERO_DIGIT, '0',
        reason: 'this test swapped numberFormatSymbols and did not put it back');
  });
}
```

```dart
// app/test/l10n/numeral_system_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols_data.dart' show numberFormatSymbols;

// testing/ sits beside lib/ and test/ (CONVENTIONS.md §6), so it is reached by a
// relative path — it is not a package and is never compiled into the app.
import '../../testing/l10n/numeral_symbols.dart';

void main() {
  guardNumberFormatSymbols();

  // Verified on intl 0.20.2 / Dart 3.12.2 — FLUTTER_GUIDE.md Part 9.1.
  test("NumberFormat.decimalPattern('ar') formats 1234567.89 with Latin digits", () {
    expect(NumberFormat.decimalPattern('ar').format(1234567.89), '1,234,567.89');
  });

  test("NumberFormat.decimalPattern('ar_EG') formats 1234567.89 with Arabic-Indic digits", () {
    expect(NumberFormat.decimalPattern('ar_EG').format(1234567.89), '١٬٢٣٤٬٥٦٧٫٨٩');
  });

  test("NumberFormat.decimalPattern('ar-u-nu-arab') discards the extension", () {
    // Accepted as a string, dropped during verifiedLocale fallback. Not a workaround.
    expect(NumberFormat.decimalPattern('ar-u-nu-arab').format(1234567), '1,234,567');
  });

  test('numberFormatSymbols carries exactly ar, ar_DZ and ar_EG', () {
    final arabic = numberFormatSymbols.keys
        .map((k) => '$k')
        .where((k) => k == 'ar' || k.startsWith('ar_'))
        .toSet();
    expect(arabic, unorderedEquals(<String>['ar', 'ar_DZ', 'ar_EG']));
  });

  test("numberFormatSymbols['ar_EG'] declares ZERO_DIGIT U+0660", () {
    final zero = (numberFormatSymbols['ar_EG']! as dynamic).ZERO_DIGIT as String;
    expect(zero.codeUnitAt(0), 0x0660);
  });

  test('NumberFormat constructed before the swap keeps Latin digits after it', () {
    final built = NumberFormat.decimalPattern('ar');   // captures zeroOffset now
    withArabicIndicDigits(() {
      expect(built.format(45), '45',
          reason: 'zeroOffset is captured at construction — this is why the swap must '
              'run before the first NumberFormat, and why a cached static formatter '
              'never honours the S14 setting');
      expect(NumberFormat.decimalPattern('ar').format(45), '٤٥');
    });
  });

  test('withArabicIndicDigits restores ZERO_DIGIT to 0 after its body throws', () {
    expect(() => withArabicIndicDigits<void>(() => throw StateError('boom')),
        throwsStateError);
    expect((numberFormatSymbols['ar']! as dynamic).ZERO_DIGIT, '0');
  });
}
```

**Run:** `cd app && flutter test test/l10n/numeral_system_test.dart test/ui/settings/` → red on the
guard, on the order-dependence row and on every end-to-end row. Rows 1–7 will go green the moment the
file compiles; that is expected and is stated above — they are regression pins on `intl`, not
assertions about code this task writes.

## Implementation outline

1. Write `app/testing/l10n/numeral_symbols.dart` with the three functions above.
2. Replace T01's local guard in `app/test/ui/golden/golden.dart` with an import of the shared one, and
   delete the duplicate.
3. Run rows 8–11. Fix the guard until they pass.
4. Run rows 12–20. Read each failure before changing anything: some will be missing wiring (the
   preference not reaching the formatter), some will be a cached formatter (row 15), some will be a raw
   `int.parse` on user text (rows 19–20).
5. Close each gap in `app/lib/ui/` — never by changing the assertion. Specifically:
   - one `numberFormatFor(Locale, NumeralSystem)` used by chrome **and** by the ruler painter, so a
     tick label and the readout beside it can never disagree;
   - `normalizeToAscii` in front of every numeric parse, folding U+0660–0669 **and** U+066B/U+066C;
   - the citation line formatted from its stored ISO string, not through `NumberFormat` at all.
6. Re-run the whole suite, then the golden lane on Linux — the goldens are the thing this task is
   protecting, and a change to the formatter path is exactly what would move them.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 20 rows pass; rows 8–20 each failed first.
- [ ] `guardNumberFormatSymbols()` is installed in every test file under `app/test/` that formats or
      renders a number, and `app/test/ui/golden/golden.dart` no longer carries its own copy.
- [ ] No `static final NumberFormat` or top-level `final NumberFormat` exists in `app/lib/` — row 15
      is the behavioural proof, and a `grep -rn 'final NumberFormat' app/lib` is run once by hand to
      confirm the structural one.
- [ ] Every numeric user input in `app/lib/` passes through `normalizeToAscii` before `parse`, and both
      digit ranges plus both separators are folded.
- [ ] `packages/rule_engine/` is untouched (D-7) and still declares no Flutter dependency.
- [ ] The 60 goldens from T01 are byte-identical after this task, or the change to each is explained in
      the commit body.
- [ ] Lengths are still integer millimetres everywhere; no `double` or `String` length field appeared
      (`catchlaw-measurement-ruler` rule 1).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze
cd app && flutter test --exclude-tags golden
cd app && flutter test --tags golden          # Linux; the lane this task exists to protect
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh app/lib
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
test(l10n): pin numeral rendering end to end and guard numberFormatSymbols per test

SPEC.md §9.3 and FLUTTER_GUIDE.md Part 9.1 record the finding this encodes:
intl 0.20.2 has no numbering-system API, -u-nu- is accepted as a string and
discarded, and number_symbols_data.dart holds three Arabic entries, so
ar_SA, ar_MA and ar_AE all resolve to ar and render Latin digits. Every one
of those lines is now a row that fails loudly if a future intl moves it.

The only lever is numberFormatSymbols, where ZERO_DIGIT is the numbering
system. It is process-wide and order-dependent: a formatter built before
the swap keeps its digits afterwards, which is asserted here and is the
reason a cached static NumberFormat would render the old block forever
while looking perfect in every screenshot taken after a restart. One test
flips the S14 preference at runtime and asserts the digits change in place.

app/testing/l10n/numeral_symbols.dart is now the single guard: snapshot in
setUp, restore in tearDown, and assert ZERO_DIGIT is back to '0' so a leak
fails in the test that caused it rather than in the sixty goldens sharing
its isolate. T01's local copy is deleted.

Citation dates stay Western in ar — a citation quotes a printed record.
Manual entry folds U+0660-0669 and U+066B/U+066C to ASCII before parsing,
because an Arabic soft keyboard yields ٤٥٫٥ and int.parse throws on it.

Task: E20/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
