# E16/T02 — Language, numeral system, units

| | |
|---|---|
| **Epic** | E16 — Settings |
| **Branch** | `epic/16-settings` (shared) |
| **Commit** | `feat(settings): add language override, numeral system and length unit` |
| **Depends on** | T01 (the repository), E06 (the six ARB files and the `numberFormatSymbols` lever), E07 (the Lonja themes) |
| **Size** | M |
| **Spec** | `SPEC.md` §6 S14, §9.3 (numerals), §9.5 (units, numbers, dates), §11 Both (the override persists independently) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-forms-and-controls` | `LonjaSegmented` is the control for all three settings here: ruled cells, `BorderRadius.zero`, selection carried by fill **and** weight **and** position, never by `harbour` alone |
| `lonja-lists-and-tables` | The settings row is a row of a printed register — 58 dp, hairline separated, one tap target, an authored empty state, no `ListTile` |
| `catchlaw-conventions-index` | The layer map: this screen reads a provider, never a DAO; and the S14 screen must not offer to fetch, check or refresh anything |
| `i18n-rtl-l10n` | ARB keys in all six locales, bidi isolation of `العربية` beside `Galego`, directional geometry, and the numeral shaping this screen switches |
| `state-management-riverpod` | `ref.watch` for the row values, `ref.read` in the `onChanged` callback, `select` at the `MaterialApp` so a unit change does not rebuild the whole app |
| `accessibility-as-code` | `Semantics` on a segmented cell, the toggled state, and 200% text scale on a three-cell row |
| `widget-golden-and-a11y-testing` | The `ar` RTL, sunlight and glove lanes for the three new rows |
| `naming-conventions` | `SettingsScreen`, `SettingsLanguageRow`, ARB key names, and the test names below |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S14, the element list | The order of the screen: language override, numeral system, units, zone defaults, ruler calibration, sunlight, glove, coordinate capture, storage, export, import, about |
| `SPEC.md` | §9.3, "Numerals — corrected twice" | Why `ar` renders Western digits by default; why the `-u-nu-` extension is silently discarded; that `numberFormatSymbols` is the only lever and it belongs to bootstrap |
| `SPEC.md` | §9.5, "Units" and "Numbers" | Millimetres are the only stored unit, conversion is display-only; the locale decimal separator |
| `SPEC.md` | §11 Both | "Locale follows the system by default; the S14 override persists independently, because a Galician-speaking user may run a Spanish-locale phone" |
| `FLUTTER_GUIDE.md` | Part 5.2 | The dumb exhaustive widget over an `AsyncValue`; `ref.read` in callbacks |
| `FLUTTER_GUIDE.md` | Part 5.3 | `select()` at the consumer — why `MaterialApp` watches three fields, not the whole record |
| `FLUTTER_GUIDE.md` | Part 5.5 | No `ref.watch` inside a callback; no notifier mirroring rows |
| `FLUTTER_GUIDE.md` | Part 6.1 | Test naming with receipts; the `ar - ` and `RTL - ` prefixes |
| `.claude/skills/lonja-forms-and-controls/SKILL.md` | Rules 1, 2, 3, 8, 11; "Square toggles and ruled segmented cells" | Radius 0, the 1.5 px ink rule, `LonjaTargets` rather than a literal, and selection as ink fill plus 600 weight |
| `.claude/skills/lonja-forms-and-controls/references/control-anatomy.md` | Control inventory; Targets and density; Sunlight re-encoding | Segmented picker: `paper` ground, 1 px `rule` outer with a shared internal divider, radius 0, 56 / 66 dp; and what every grey becomes in sunlight |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | Rules 1, 2, 3, 6, 12 | Whole-row tap target, hairline separation, `ListTile` banned, an authored empty state, glove raises rows without re-laying them out |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The settings row"; "Density" | 58 dp / 68 dp glove, serif 15.5 sp key, sans 11 sp `ink-faint` sub-line, value slot after a `Spacer()` |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §1 | Nothing on this screen may check for, download or refresh anything |
| `epics/DECISIONS.md` | D-3 | The six locales are `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`; there is no `ur` and no `app_pt.arb` |
| `epics/DECISIONS.md` | D-8 | `EdgeInsets.only(left:` is banned by a grep gate over `app/lib`, not by a lint |
| `epics/CONVENTIONS.md` | §5, §9 | Test naming; the five invariants no task may weaken |

## What this delivers

- `app/lib/ui/settings/widgets/settings_screen.dart` — `SettingsScreen`, the S14 scaffold: a
  `CustomScrollView` of `LonjaSectionLabel`-headed groups, in the §6 S14 element order. T03–T07 add
  sections to it and add no second screen.
- `app/lib/ui/settings/widgets/settings_row.dart` — `SettingsRow`, the 58 dp / 68 dp register row from
  `row-and-table-anatomy.md`: serif key, optional sans sub-line, `Spacer()`, value slot.
- `app/lib/ui/settings/widgets/settings_language_row.dart` — `SettingsLanguageRow`, seven options.
- `app/lib/ui/settings/widgets/settings_numeral_row.dart` — `SettingsNumeralRow`, three cells.
- `app/lib/ui/settings/widgets/settings_unit_row.dart` — `SettingsUnitRow`, three cells.
- `app/lib/l10n/app_{ar,en,es,gl,ca,pt_BR}.arb` — the keys listed below, in all six files, in this
  commit (D-3).
- Changes to the `MaterialApp` owner (`CatchlawApp`, the widget `FLUTTER_GUIDE.md` §5.2's bootstrap
  snippet names): `locale:` resolves from `userSettingsProvider`.
- `app/test/ui/settings/settings_language_row_test.dart`,
  `app/test/ui/settings/settings_numeral_row_test.dart`,
  `app/test/ui/settings/settings_unit_row_test.dart`,
  `app/test/ui/settings/settings_screen_test.dart`.

ARB keys added: `settingsTitle`, `settingsSectionLanguage`, `settingsLanguageLabel`,
`settingsLanguageMatchPhone`, `settingsNumeralLabel`, `settingsNumeralAuto`, `settingsNumeralWestern`,
`settingsNumeralArabicIndic`, `settingsLengthUnitLabel`, `settingsLengthUnitCm`,
`settingsLengthUnitMm`, `settingsLengthUnitInch`, `settingsLengthUnitStoredNote`.

## Why it is built this way

**The override is a column, not a device setting.** `SPEC.md` §11 Both states the case exactly: a
Galician-speaking user may run a Spanish-locale phone. So `locale_override` is `NULL` by default —
`MaterialApp.locale: null` means "resolve from the platform" — and a non-null value pins the app
regardless of what the system later becomes. The row's first option is "Match the phone", which writes
`NULL`; the six others write a locale tag.

**Each locale is labelled in its own language.** `العربية`, `English`, `Español`, `Galego`, `Català`,
`Português (Brasil)`. **Rejected: labelling each option in the current UI language** ("Arabic",
"Spanish", "Galician"…), which is the common pattern and is exactly wrong here: the user who most needs
this control is the one who cannot read the language currently on screen. A user handed a phone that
booted into Arabic must be able to find `Galego` by shape. This is the one list in the app whose labels
are deliberately **not** translated, and it is commented as such.

**The numeral row writes the preference and nothing else.** `SPEC.md` §9.3 is unambiguous about the
mechanism: `intl` 0.20.2 has no numbering-system API, `ar-u-nu-arab` is accepted as a string and
silently discarded, and the only supported lever is the public mutable `numberFormatSymbols` map, whose
`ZERO_DIGIT` *is* the numbering system. **E06/T04 owns that swap.** This row writes
`user_profile.numeral_system` and calls the E06-owned apply function; it does not touch the map itself,
and it never constructs a locale with a `-u-nu-` extension. **Rejected:
`Locale.fromSubtags(languageCode: 'ar', ... )` with a Unicode extension** — §9.3 records that it
produces `1,234,567` and no error.

**The map swap is process-wide and order-dependent, which makes one thing illegal here.** Because
`NumberFormat` computes its zero offset when it is *constructed*, a `NumberFormat` cached in a field or
a top-level `final` keeps the digits it was born with, and the setting appears not to work until the
app restarts. This task therefore bans a cached `NumberFormat` in `app/lib`, checks it by grep, and has
a test (row 8) that switches the setting and asserts a figure re-renders without a restart. §9.3 also
warns that the map "will silently corrupt golden tests sharing an isolate unless reset in
`setUp`/`tearDown`", so every test file here saves and restores `numberFormatSymbols['ar']`.

**Three cells, and each cell shows its own digits.** The numeral options read
`Auto`, `Western 0123`, `Arabic-Indic ٠١٢٣`. The samples are **literal strings**, never a formatted
number — a sample pushed through `NumberFormat` renders in the *active* system and both cells become
identical, which is the defect row 6 exists to catch. Showing the digits is also what makes the control
usable to someone who cannot read the label.

**Units are display-only, and the stored value never moves.** `catchlaw-measurement-ruler` rule 1 and
rule 11 and `SPEC.md` §9.5 all say the same thing: everything is stored as integer millimetres and
conversion is display-only, rounded exactly once at capture. Switching this row therefore changes zero
rows in `catch`. It changes which unit `formatMeasurement` renders — the formatter E09 already owns.
**Rejected: a second formatting helper in `ui/settings/`.** Two formatters is how `449 mm` becomes
`45 cm` in one place and `44.9 cm` in another, and `check_measurement.sh` check 2 fails a bare `mm`/`cm`
literal for exactly that reason.

**The screen has zero primary buttons.**
`lonja-buttons/references/variant-ladder-and-states.md` Edge cases: "A screen with genuinely no primary
action … Correct. Zero primaries is legal; two is not." Settings has no single thing it exists to let
you do. Every action on S14 is a row tap or a `secondary` / `quiet` button, and the destructive purge in
T06 is the only filled box on the screen.

**The screen never writes on mount.** A `build` that normalises a value — resolving an inch default,
writing back a canonicalised locale tag — silently overwrites the user's own choice every time they
open Settings. Row 12 asserts zero writes on first frame. See the epic's Risk 2 for the `en` + US-region
inch default this deliberately declines to apply.

## Tests first

Write every row before touching any widget file. Run them. **They must fail.** If a row passes before
the widget exists, it is asserting against the harness rather than the screen — fix the test.

Every widget test in this task installs `FakeSettingsRepository` through a `ProviderScope` override, so
none of them opens a database. Every file that reaches numerals saves `numberFormatSymbols['ar']` in
`setUp` and restores it in `tearDown` (`SPEC.md` §9.3).

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SettingsLanguageRow lists seven options` | default settings | "Match the phone" plus the six locales of D-3 | Six locales ship or the feature does not ship; a five-option list means a locale was dropped from the picker but not from the ARB set |
| 2 | `SettingsLanguageRow labels each locale in its own language` | default settings | finds `العربية`, `English`, `Español`, `Galego`, `Català`, `Português (Brasil)` | The design decision above; a translated label list regresses the moment someone "fixes" it into ARB keys |
| 3 | `SettingsLanguageRow writes null when Match the phone is chosen` | tap "Match the phone" after `'gl'` | `setLocaleOverride(null)` called once | `NULL` is what makes the app follow the system again; a setter that writes the resolved system tag pins it forever |
| 4 | `ar - SettingsLanguageRow marks the active option when localeOverride is 'ar'` | `localeOverride: 'ar'` | the `العربية` cell is selected | The selected-state read path; the value comes from the column, never from `Localizations.localeOf` |
| 5 | `RTL - SettingsLanguageRow places the value slot at the end edge` | `localeOverride: 'ar'` | value slot's start edge is greater than the key's | `TextAlign.right` and `EdgeInsets.only(left:)` both look correct in `en` and put the value under its own label in `ar` (D-8) |
| 6 | `SettingsNumeralRow renders the Arabic-Indic sample as ٠١٢٣ when numeralSystem is latn` | `numeralSystem: latn` | the cell contains the literal `٠١٢٣` | The sample must not go through `NumberFormat`; if it does, both cells read `0123` and the control cannot be used |
| 7 | `SettingsNumeralRow writes arab when the Arabic-Indic cell is tapped` | tap | `setNumeralSystem(NumeralSystem.arab)` once | The write path |
| 8 | `ar - SettingsNumeralRow re-renders a figure in Arabic-Indic digits without a restart` | `ar` locale, switch `auto` → `arab` | a rendered `1234` becomes `١٢٣٤` in the same pump | The cached-`NumberFormat` defect: this is the only test that fails when a formatter is hoisted to a field |
| 9 | `SettingsNumeralRow passes no Unicode extension to Localizations` | switch to `arab` | the resolved `Locale` has no `-u-nu-` subtag | `SPEC.md` §9.3: the extension is accepted and silently discarded, so code that "works" this way is a lie that ships |
| 10 | `SettingsUnitRow writes LengthUnit.inch when the inch cell is tapped` | tap `inch` | `setLengthUnit(LengthUnit.inch)` once | The write path, and the `'in'` code round-trip is T01 row 9 |
| 11 | `SettingsUnitRow leaves every stored length_mm unchanged` | a catch at `450`, switch cm → inch → mm | `SELECT length_mm` still `450` | The canonical-unit invariant; a unit switch that rewrote rows would corrupt the whole catch log irreversibly |
| 12 | `SettingsScreen performs no write on first frame` | pump the screen | zero setter calls on the fake | A screen that normalises on build overwrites the user's choice on every visit |
| 13 | `SettingsScreen renders the S14 sections in the §6 order` | pump | section labels in the spec's order | The order is the spec's, not the order the sections happened to be added in over five commits |
| 14 | `glove - SettingsRow measures 68 dp with glove mode on` | `gloveMode: true` | row height ≥ 68 | `row-and-table-anatomy.md`: 58 → 68 dp; glove raises rows and does not re-lay them out |
| 15 | `SettingsRow measures 58 dp with glove mode off` | default | row height ≥ 58 | The paired floor; without both, a regression to Material's 48 dp passes |
| 16 | `sunlight - SettingsNumeralRow draws its cell rules in sun-ink` | sunlight theme | no `ink-faint` grey in the row's borders | `control-anatomy.md`, Sunlight re-encoding: a grey hairline is simply not there on an open deck at midday |
| 17 | `SettingsScreen builds no LonjaButtonVariant.primary` | pump | zero primaries | Settings has no single reason to exist; two primaries fails `check_lonja_buttons.sh` and zero is the correct count here |

```dart
// app/test/ui/settings/settings_numeral_row_test.dart
import 'package:catchlaw/domain/models/numeral_system.dart';
import 'package:catchlaw/ui/settings/widgets/settings_numeral_row.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/number_symbols_data.dart';

import '../../../testing/harness.dart';

void main() {
  late Object? savedArabicSymbols;

  setUp(() => savedArabicSymbols = numberFormatSymbols['ar']);
  tearDown(() {
    // SPEC 9.3: the map is process-wide and will silently corrupt every later
    // test in this isolate if a case leaves it swapped.
    numberFormatSymbols['ar'] = savedArabicSymbols!;
  });

  testWidgets(
    'SettingsNumeralRow renders the Arabic-Indic sample as ٠١٢٣ when numeralSystem is latn',
    (tester) async {
      await tester.pumpWidget(
        settingsHarness(settings: kDefaultSettings.copyWith(numeralSystem: NumeralSystem.latn)),
      );
      expect(find.text('٠١٢٣'), findsOneWidget);
      expect(find.text('0123'), findsOneWidget);
    },
  );

  testWidgets('SettingsNumeralRow writes arab when the Arabic-Indic cell is tapped',
      (tester) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(settingsHarness(repository: repo));
    await tester.tap(find.text('٠١٢٣'));
    await tester.pump();
    expect(repo.numeralSystemWrites, [NumeralSystem.arab]);
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/ui/settings/` → 17 failures. If any passes now, the test is wrong.

## Implementation outline

Only after the tests are red.

1. `settings_row.dart` first — every later task in this epic composes it. `Row` inside a `DecoratedBox`
   with a `BorderDirectional(bottom: …)` hairline, `ConstrainedBox(minHeight: 58 | 68)` read from the
   density extension, never a literal in the file. No `ListTile` (`lonja-lists-and-tables` rule 3).
2. `settings_screen.dart` — a `CustomScrollView` of slivers with `LonjaSectionLabel` headers, in the
   §6 S14 order, with the language section populated and stubs for T03–T07's sections. `switch` over
   the `AsyncValue` exhaustively (`FLUTTER_GUIDE.md` §5.2): `AsyncData` → the list, `AsyncError` → the
   authored error state, `AsyncLoading` → the ruled skeleton. **No `CircularProgressIndicator`**
   (`the-four-states.md`).
3. The three rows. Each is a `SettingsRow` whose value slot is a `LonjaSegmented`; each `onChanged` is
   `ref.read(settingsRepositoryProvider).setX(v)` — `read`, never `watch`, in a callback
   (`FLUTTER_GUIDE.md` §5.5).
4. ARB: add all thirteen keys to all six files in this commit, with the locale-name labels marked in
   the `@` metadata as deliberately untranslated.
5. `CatchlawApp`: `locale: ref.watch(userSettingsProvider.select((s) => s.valueOrNull?.localeOverride))`
   mapped to a `Locale?`. `select` rather than a bare `watch`, so a unit change does not rebuild the
   whole app (`FLUTTER_GUIDE.md` §5.3).
6. Wire the numeral write to E06/T04's apply function. Do not re-implement the swap.
7. Re-run the whole suite. Every E06 localisation test must still be green — if one has gone red, the
   `numberFormatSymbols` restore in `tearDown` is missing somewhere.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 rows pass, and each failed first.
- [ ] All thirteen ARB keys exist in `app_ar.arb`, `app_en.arb`, `app_es.arb`, `app_gl.arb`,
      `app_ca.arb` and `app_pt_BR.arb` (D-3). No `app_pt.arb`, no `app_ur.arb`.
- [ ] `grep -rn "NumberFormat" app/lib | grep -E "^\S+:\s*(final|static|const)"` returns nothing — no
      cached formatter anywhere (`SPEC.md` §9.3).
- [ ] `grep -rn "u-nu-\|numberFormatSymbols" app/lib/ui` returns nothing: the lever is E06's, not this
      screen's.
- [ ] `grep -rn "ListTile\|DataTable" app/lib/ui/settings` returns nothing
      (`lonja-lists-and-tables` rule 3).
- [ ] Golden lanes attached for the three new rows: `en` paper, `ar` paper, `ar` paper glove, `en`
      sunlight (`the-four-states.md` lanes 1, 2, 3, 5).
- [ ] The screen survives 200% text scale with no clipping on a 5-inch frame (`SPEC.md` §13,
      Accessibility).
- [ ] `SettingsScreen` builds zero `LonjaButtonVariant.primary`.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh   app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh        app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh               app/lib
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh    app/lib
tools/gates/no_directional_geometry.sh                                    app/lib
```

Every gate takes the target directory explicitly; each exits 2 on a missing directory, and a bare
default would look for `lib/` at the repository root, which does not exist (D-1).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(settings): add language override, numeral system and length unit

The locale list labels each option in its own language rather than in the
current UI language, because the user who needs this control most is the
one who cannot read what is on screen — a Galician speaker handed a phone
that booted into Arabic (SPEC 11 Both).

The numeral row writes user_profile.numeral_system and calls E06's apply
function. It does not construct a locale with a -u-nu- extension: SPEC 9.3
records that intl 0.20.2 accepts that string and silently discards it, so
the code would look right and render Western digits forever. Because the
map swap is read when a NumberFormat is CONSTRUCTED, no NumberFormat may be
cached in a field, and a test switches the setting and asserts a figure
re-renders in the same pump.

The unit row is display-only. Millimetres remain the only stored unit
(SPEC 9.5), and a test asserts a 450 mm catch still reads 450 after two
unit switches.

Task: E16/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
