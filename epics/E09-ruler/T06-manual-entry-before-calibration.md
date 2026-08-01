# E09/T06 — Manual entry, before any calibration exists

| | |
|---|---|
| **Epic** | E09 — Ruler and calibration |
| **Branch** | `epic/09-ruler` (shared) |
| **Commit** | `feat(ruler): complete the measure step by keypad on a device that has never been calibrated` |
| **Depends on** | T05 (the keypad is one tap from S3, and S3 must exist) |
| **Size** | M |
| **Spec** | `SPEC.md` §4.2 (manual entry row: **works before calibration**), §6 S2 error state, §6 S3, §14 (the dynamic checklist line this makes executable) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-forms-and-controls` | Owns the keypad: the 3×4 ruled grid, mono tabular figures, the unit in a fixed non-editable slot, and rule 6 — the keypad works before calibration, always |
| `catchlaw-measurement-ruler` | Rule 9 — manual entry is the ground floor and only the ruler tab is ever disabled; rule 11 — a display string is a leaf and never travels back into a field |
| `forms-and-input` | The mechanics `lonja-forms-and-controls` deliberately omits: controller and focus disposal, keyboard type, derived-not-stored enablement |
| `i18n-rtl-l10n` | Rules 7 and 11: normalise digits and separators to ASCII before any parse, and never `int.parse` on raw input |
| `value-objects-money-and-units` | The keypad accumulator that sidesteps the locale decimal separator entirely |
| `accessibility-as-code` | Every key is a labelled ≥ 44 dp single-tap target; the out-of-range state is a word and a glyph, not a colour |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.2 "Manual entry" | Big numeric keypad, cm/mm/inch per locale, one tap from the ruler, **works before calibration so the core loop is complete on first launch** |
| `SPEC.md` | §6 S2 error state | "ruler not calibrated → inline Calibrate prompt; manual entry remains available" |
| `SPEC.md` | §14 dynamic checklist | "repeat using **manual length entry before ever calibrating**, confirming the loop is complete on a virgin install" — this task turns that line into a widget test |
| `.claude/skills/lonja-forms-and-controls/references/search-field-and-keypad.md` | "The keypad", "Keypad before calibration: the contract", "Unit and method copy" | The 3×4 layout, key sizes, the four-row availability table with no cell in which the keypad is unavailable, and the three simultaneously-visible slots |
| `.claude/skills/lonja-forms-and-controls/SKILL.md` | rules 2, 4, 5, 6 | Raw Material inputs live only in `ui/core/`; a hint may not carry the unit; every quantity is mono tabular; the keypad never gates on calibration |
| `.claude/skills/catchlaw-measurement-ruler/references/ruler-and-calibration.md` | "Manual entry is the ground floor" | The four-row condition table and the reason: no answer at 05:40 for a fisher who left the card ashore |
| `.claude/skills/catchlaw-measurement-ruler/references/measurement-methods.md` | "Edge cases" | Accept 1..3000 mm; a 3 m fish is a typo, not a catch; the keypad is labelled mm for `shl`/`cw` and cm for `tl`/`fl`/`sl`/`ml` |
| `.claude/skills/value-objects-money-and-units/references/canonical-storage.md` | "The cents-accumulator for keypad input" | `accumulate(current, digit) => current * 10 + digit`, which never touches a locale separator |
| `.claude/skills/i18n-rtl-l10n/references/numerals-and-calendars.md` | "Parse — normalize FIRST", "Separators — the trap" | `1٫5` means 1.5, not 15; the two distinct digit blocks; `normalizeToAscii` before any parse |
| `.claude/skills/accessibility-as-code/SKILL.md` | rules 1, 5, 8 | Labelled keys, no `FittedBox`/ellipsis to make the readout fit, ≥ 44 px targets |
| `epics/E09-ruler/epic.md` | Risk 7 | Whether `LonjaKeypad` already exists is an E07 question; this file states both branches |

## What this delivers

- `app/lib/ui/core/ui/lonja_keypad.dart` — `LonjaKeypad`, the 3×4 ruled grid, **if E07 did not already
  publish it**. If E07 did, this task consumes it and delivers nothing here. It is `ui/core/` either
  way: `lonja-forms-and-controls` rule 2 keeps raw Material inputs out of feature code, and
  `check_lonja_controls.sh` check 1 enforces exactly that boundary.
- `app/lib/ui/ruler/widgets/manual_length_entry.dart` — `ManualLengthEntry`: the readout in mono
  tabular figures, the fixed non-editable unit slot, the method caption, the keypad, and the
  out-of-range state. Reachable from S3's **Type instead** and from S2's not-calibrated error state.
- `app/lib/ui/ruler/view_models/manual_entry_viewmodel.dart` — `ManualEntryViewModel extends
  Notifier<ManualEntryState>`: a millimetre accumulator, `digit(int)`, `backspace()`, `clear()`,
  `accept(MeasurementMethod)`. No `TextEditingController` and no parsing of a rendered string.
- ARB keys in all six locales: `manualEntryTitle`, `manualEntryUnitCm`, `manualEntryUnitMm`,
  `manualEntryOutOfRange` (ICU, `{min}`/`{max}`), `manualEntryAcceptAction`,
  `rulerNeedsCalibration` (the one-line reason on the disabled ruler tab), `calibrateAction`.
- Tests: `app/test/ui/ruler/manual_entry_viewmodel_test.dart`,
  `app/test/ui/ruler/manual_entry_screen_test.dart`, and the epic's headline case
  `app/test/ui/ruler/virgin_install_measure_test.dart`.

## Why it is built this way

**This is the task that makes the product complete on a virgin install.** Everything else in the
epic depends on a bank card. This does not. `SPEC.md` §4.2 states it as an acceptance condition —
"works before calibration, so the core loop is complete on first launch" — and §14 tests it on a
device in airplane mode. The failure it prevents is specific: a `CalibrateFirstScreen` standing
between the fisher and a number at 05:40, when the fish is alive, the tide is going, and the app has
asked him for a bank card he left ashore. *Rejected, explicitly:*
`if (calibration == null) return const DisabledMeasureStep();`, which is named as an anti-pattern by
both `catchlaw-measurement-ruler` and `lonja-forms-and-controls` and is the obvious first
implementation.

**Only the ruler tab is ever disabled, and it says why in one line.** The keypad is live in all four
rows of the skill's availability table — never calibrated, calibrated, calibration rejected this
session, screen smaller than the card. The disabled ruler carries `rulerNeedsCalibration` plus a
Calibrate action, so the state is legible rather than merely dead.

**Digits accumulate; nothing is parsed.** Each key press is `value = value * 10 + digit` straight
into millimetres, so the locale decimal separator never enters the problem. `1٫5` means 1.5 and not
15, and normalising digits without normalising separators corrupts the entry silently — the reason
`i18n-rtl-l10n` rule 7 exists. *Rejected:* a `TextField` with a numeric keyboard and
`int.parse(controller.text)`. It throws on a Persian or Arabic soft keyboard, it makes the separator
a live hazard, and it re-introduces the display-string round trip that rule 11 forbids:
449 mm shown as "45 cm" and re-parsed as 450 manufactures a pass at the exact millimetre that costs
AED 3,000.

**The unit and the method are outside the editable text.** `lonja-forms-and-controls` rule 4: the
hint is the only slot allowed to disappear, so it may never carry the field's name, its unit or its
method. A `cm` that existed only in a hint takes the unit with it on the first keystroke, which is
how 38 mm becomes 38 cm. Three slots, always visible: the figure (mono, tabular), the unit (fixed,
non-editable), the method (`Total length (TL)`, `Shell length`).

**The keypad's unit follows the rule row's method.** `mm` for `shl` and `cw` rules — a Galician user
typing `3.8` for a 38 mm *Venerupis corrugata* is a real failure — and `cm` for `tl`, `fl`, `sl` and
`ml`. The stored value is millimetres either way; the unit is a label and a divisor, nothing more.

**Out of range is a state, not an exception.** Accept 1..3000 mm. Outside it the accept action is
disabled and `manualEntryOutOfRange` states the band; nothing is stored. A 3 m fish is a typo. The
state is carried by a word plus a marginal glyph in `ochre`, never `oxblood` — `oxblood` is reserved
for a verdict, and an input that borrows it makes a typo look like a legal failure.

**Enablement is derived.** `forms-and-input` rule 5: no stored `_isValid` bool. The accept action is
enabled iff the accumulator is in range, computed at build time.

## Tests first

Write every row before touching `manual_length_entry.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ManualEntryViewModel.digit accumulates into millimetres` | keys 4, 5, 0 with a cm unit | `450` mm | The accumulator, and the fact that the stored unit never changes with the label |
| 2 | `ManualEntryViewModel.digit accumulates millimetres directly for a shell-length rule` | keys 3, 8 with an mm unit | `38` mm | *Venerupis corrugata* at 38 mm SHL — the case where the cm habit is wrong |
| 3 | `ManualEntryViewModel.backspace removes the last digit` | 4, 5, 0, backspace | `45` | Wet-hand correction without clearing |
| 4 | `ManualEntryViewModel.digit is inert past the entry ceiling` | six digits | the value stops changing, no error state | `search-field-and-keypad.md`: further keys are inert, not error states |
| 5 | `ManualEntryViewModel.accept refuses a value of zero` | no digits | accept disabled, nothing produced | The boundary a `> 0` check gets wrong first |
| 6 | `ManualEntryViewModel.accept refuses a value above 3000 mm` | 3001 mm | accept disabled, `manualEntryOutOfRange` shown | A 3 m fish is a typo, not a catch |
| 7 | `ManualEntryViewModel.accept produces a Measurement carrying the rule's method` | 450 mm, method `tl` | `Measurement(lengthMm: 450, method: tl)` | Rule 3, again: no figure without its method |
| 8 | `ManualLengthEntry keeps the unit visible with the figure empty` | fresh | the unit slot renders `cm` with no digits present | The unit-in-the-hint failure, asserted with text absent |
| 9 | `ManualLengthEntry keeps the unit visible with the figure present` | 450 | the unit slot still renders `cm` | And with text present — both halves, per the skill's definition of done |
| 10 | `ManualLengthEntry shows the measurement method beside the figure` | method `fl` | `Fork length (FL)` present | An unlabelled figure is read as total length |
| 11 | `ManualLengthEntry sets every figure in tabular figures` | 111 then 000 | the readout's `getSize().width` is unchanged between the two | Proportional digits reflow under a wet thumb and get re-read instead of trusted |
| 12 | `ManualLengthEntry renders no progress or network affordance` | fresh | no `CircularProgressIndicator` in the tree | Rule 9: a spinner in a fully offline app is a lie |
| 13 | `ar - ManualLengthEntry stores ASCII millimetres when the keys render Arabic-Indic` | numeral system `arab`, keys ٤ ٥ ٠ | the accumulator holds `450` | The keypad reads the shaped glyph and always writes a canonical ASCII value |
| 14 | `glove - ManualLengthEntry sizes every key at the glove key target` | glove density | every key clears the `SPEC.md` §4.9 glove floor of 56 dp | The keypad is used with gloves on more often than anything else in the app |
| 15 | `ManualLengthEntry meets androidTapTargetGuideline` | default | `await expectLater(tester, meetsGuideline(androidTapTargetGuideline))` | Advisory tripwire; row 14 is the gate |
| 16 | `RulerScreen reaches manual entry in one tap` | S3, calibrated | one tap on Type instead shows the keypad | `SPEC.md` §4.2: "One tap from the ruler" |
| 17 | `Measure step completes by keypad alone with no calibration row` | fake repository returns null, species and rule fixed | a `Measurement(450, tl)` is produced and the ruler was never enabled | **The §14 line, executable.** This is the test the epic exists to be able to run |
| 18 | `RulerScreen states one reason the ruler is unavailable` | calibration null | `rulerNeedsCalibration` present exactly once, with a Calibrate action | A dead control with no explanation reads as broken hardware |

```dart
// app/test/ui/ruler/virgin_install_measure_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show MeasurementMethod;

import '../../support/harness.dart';

void main() {
  testWidgets('Measure step completes by keypad alone with no calibration row',
      (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpRulerScreen(calibration: null); // virgin install

    await tester.tap(find.byKey(const ValueKey('type_instead_action')));
    await tester.pump();
    for (final key in <String>['4', '5', '0']) {
      await tester.tap(find.byKey(ValueKey('keypad_$key')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const ValueKey('manual_accept_action')));
    await tester.pump();

    expect(tester.lastMeasurement.lengthMm, 450);
    expect(tester.lastMeasurement.method, MeasurementMethod.tl);
    expect(tester.rulerWasEnabled, isFalse);
  });
}
```

```dart
// app/test/ui/ruler/manual_entry_viewmodel_test.dart
import 'package:catchlaw/ui/ruler/view_models/manual_entry_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ManualEntryViewModel subject(ProviderContainer c) =>
      c.read(manualEntryViewModelProvider.notifier);

  test('ManualEntryViewModel.accept refuses a value above 3000 mm', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final viewModel = subject(container);
    for (final d in <int>[3, 0, 0, 1]) {
      viewModel.digit(d);
    }
    expect(container.read(manualEntryViewModelProvider).canAccept, isFalse);
  });

  test('ManualEntryViewModel.digit accumulates millimetres directly for a '
      'shell-length rule', () {
    final container = ProviderContainer(overrides: [
      manualEntryUnitProvider.overrideWithValue(LengthUnit.mm),
    ]);
    addTearDown(container.dispose);
    subject(container)
      ..digit(3)
      ..digit(8);
    expect(container.read(manualEntryViewModelProvider).valueMm, 38);
  });
}
```

**Run:** `cd app && flutter test test/ui/ruler` → 18 failures. Row 17 is the one to watch: if it
passes before the keypad exists, the harness is not really starting from a null calibration.

## Implementation outline

1. Check whether `app/lib/ui/core/ui/lonja_keypad.dart` exists. If not, build it there: a 3×4 grid,
   `7 8 9 / 4 5 6 / 1 2 3 / . 0 ⌫`, keys sized from the theme's key target, one shared grid rule and
   a heavier outer frame, mono tabular figures. The decimal key renders the **locale's** separator
   glyph and writes a canonical `.`; with a millimetre accumulator it is inert for `mm` units and
   shifts the scale for `cm`.
2. `ManualEntryState`: `valueMm`, `unit`, `method`, derived `canAccept` (`1 <= valueMm <= 3000`).
   No stored validity flag.
3. `ManualEntryViewModel`: pure accumulator intent methods; `accept` returns a `Measurement` built
   with the rule row's method.
4. `ManualLengthEntry`: three slots in a `Column` — label (sans caps), figure + fixed unit in a
   `Row`, method caption. Then the keypad. Then the accept action.
5. Wire S3's **Type instead** to it, and expose the same entry point for E10 to use from S2's
   not-calibrated error state (E10 wires the screen; this task exports the widget and the provider).
6. Disable the ruler tab when `calibration == null`, with `rulerNeedsCalibration` and a Calibrate
   action beside it. Never disable, hide or gate the keypad.
7. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 tests pass, and each failed first.
- [ ] No `TextField`, `TextFormField` or `TextEditingController` exists anywhere in
      `app/lib/ui/ruler/` — the value is an accumulator, not a parsed string.
- [ ] No `int.parse` or `double.parse` on any user-entered text in the diff.
- [ ] The unit and the method are asserted visible with the figure both empty and present.
- [ ] `check_lonja_controls.sh app/lib` is clean, including check 1 (no raw Material input outside
      `ui/core/`) and check 3 (no hardcoded target number).
- [ ] There is no code path in `app/lib` where `calibration == null` disables, hides or gates manual
      entry — verified by reading every `calibration == null` branch in the diff.
- [ ] All six ARB files gained the same keys; the out-of-range copy states the band and does not
      instruct.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh   app/lib
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh    app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh          app/lib
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
feat(ruler): complete the measure step by keypad on a device that has never been calibrated

The core loop must not depend on a one-time setup step. A CalibrateFirstScreen
between the fisher and a number at 05:40 — fish alive, tide going, bank card
ashore — is the single failure this task exists to prevent, so the keypad is
live in all four rows of the availability table and only the ruler tab is ever
disabled, with one line saying why.

Digits accumulate straight into millimetres, so the locale decimal separator
never enters the problem and no display string is ever parsed back: 449 mm
shown as "45 cm" and re-read as 450 manufactures a pass at exactly the
millimetre that costs AED 3,000. The unit and the method sit in fixed slots
outside the editable figure, because a unit that lives in a hint dies on the
first keystroke and 38 mm silently becomes 38 cm.

SPEC 14's "manual length entry before ever calibrating" line is now a widget
test rather than a manual step.

Task: E09/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
