---
name: lonja-forms-and-controls
description: >-
  Enforces the Lonja input controls as printed instruments rather than Material chrome — the search
  field as a ruled entry line with a 1.5px ink hairline and BorderRadius.zero instead of a filled
  rounded box, square LonjaSwitch toggles because paper has no pills, LonjaSegmented as ruled cells
  sharing one divider, LonjaStepper and the big LonjaKeypad for manual length entry set in mono
  tabular figures, LonjaTargets.control at 56dp rising to 66dp under glove mode with 8dp separation
  for wet hands, serif value text over ink-faint italic hintText that never carries meaning typing
  destroys, and a species field that never rewrites the user's Arabic or diacritics. Use when
  building a search field, adding a toggle or segmented picker, wiring the numeric keypad, sizing a
  hit area for glove mode, writing placeholder or unit copy, styling InputDecoration, or reviewing
  any control in a diff.
---

# Lonja Forms and Controls

A control in CATCHLAW is not a widget that collects data; it is **an instrument printed on the
page** — a ruled entry line, a stamped cell, a numbered key — operated at 05:40 with wet hands, a
live fish in the bin and ten seconds. This skill owns the Lonja *values* and the *physical-context*
rules for search fields, toggles, segmented pickers, steppers and the numeric keypad. It owns
nothing about form mechanics.

Read the reference for the task at hand:
- `references/control-anatomy.md` — control inventory, ground and rule weights, state matrix, glove
  and sunlight re-encoding, banned Material defaults.
- `references/search-field-and-keypad.md` — search field anatomy, script and diacritic handling,
  keypad layout, keypad-before-calibration contract, unit and hint copy.

Run `scripts/check_lonja_controls.sh` before a PR.

`Form`, `GlobalKey<FormState>`, sync-vs-async validators, `FocusNode` traversal, `TextInputFormatter`
policy and controller disposal are owned entirely by `forms-and-input` and are NEVER restated here;
this skill governs only what a control looks like, how big it is, and what it is allowed to say.

## Non-negotiable rules

1. **Every control is a ruled line or a ruled cell — never a pill.** Corners are `BorderRadius.zero`
   and the side is `1.5` logical pixels of `ink` `#16201C`; the largest radius the system tolerates
   anywhere is `2`. `scripts/check_lonja_controls.sh` fails any `BorderRadius.circular(` above `2`.
   **WHY:** a rounded filled field reads as generic app chrome, and Lonja's whole authority is that
   it looks like the printed regulation it quotes.

2. **Raw `TextField`, `Switch`, `SegmentedButton`, `Slider`, `Checkbox` and `Radio` live ONLY in
   `lib/ui/core/`.** Feature code composes `LonjaSearchField`, `LonjaSwitch`, `LonjaSegmented`,
   `LonjaStepper` and `LonjaKeypad`. The single escape hatch is a trailing `// lonja-core-ok`.
   **WHY:** one raw `TextField` in a feature ships Material's 4dp radius, its filled
   `surfaceVariant` ground and its 48dp height straight past every review.

3. **EVERY primary target reads `LonjaTargets`, never a numeric literal.** `LonjaTargets.control`
   is `56`, `LonjaTargets.gloveControl` is `66`, `LonjaTargets.separation` is `8`, and the glove
   density switch — not a per-screen constant — chooses between them. **WHY:** a wet, cold,
   gloved fingertip has a contact patch near 15 mm; Material's 48dp default mis-hits, and a mis-hit
   here is a wrong verdict worth AED 3,000 and a six-month suspension.

4. **Placeholder text NEVER carries meaning that typing destroys.** `hintText` may only
   *illustrate* — `Search species — هامور, Hamour, grouper`. The field's name, its unit and its
   measurement method live in a persistent label above the rule and in a fixed trailing unit slot.
   **WHY:** the first keystroke erases the hint, and a `cm` that existed only in the hint takes the
   unit with it, which is how 38 mm becomes 38 cm.

5. **Value text is serif; EVERY quantity is mono with `FontFeature.tabularFigures()`.** The typed
   species name is serif at 19; `47.0`, `65`, `38 mm` are mono. **WHY:** proportional digits reflow
   as the keypad appends, and a number that shifts under a wet thumb gets re-read instead of
   trusted.

6. **The keypad works BEFORE ruler calibration exists, always.** `LonjaKeypad` is reachable from
   the measurement screen on a device that has never been calibrated, and never renders a
   "calibrate first" gate; calibration only *adds* the on-screen ruler as a second path.
   **WHY:** a first-launch fisher at 05:40 cannot go find a bank card to calibrate against, and a
   blocked entry path makes the app unusable exactly when it is needed.

7. **The species field NEVER fights the user's script.** No `textCapitalization`, no Latin-only
   formatter, no diacritic stripping in the visible text: `هامور`, `Sha'ri` and `Ameixa babosa`
   render exactly as typed. Fold-and-match happens on the query side in `catchlaw-rule-engine`, and
   the directional geometry of the icon, caret and clear affordance is owned by `i18n-rtl-l10n`.
   **WHY:** a legal tool that rewrites the user's own language as they type has already lost them.

8. **Selected state is fill AND weight AND position — never `harbour` alone.** A selected
   `LonjaSegmented` cell inverts to an `ink` ground with `paper` text and a 600 weight; `harbour`
   `#1B4D5E` is chrome only, and `verdant` `#2E5E3A`, `oxblood` `#7A2320` and `ochre` `#8A6A16`
   NEVER appear on an input control. **WHY:** semantic colour on a picker turns a choice into a
   verdict. The never-colour-alone floor itself is owned by `accessibility-as-code`.

9. **No control renders a network, sync, cloud or indeterminate-progress affordance.** Search reads
   the pre-seeded read-only drift asset database; there is no debounce spinner, no
   `CircularProgressIndicator`, no shimmer skeleton, no cloud glyph. **WHY:** a spinner in a 100%
   offline app is a lie that makes Khalid wait for a network that does not exist.

10. **Under the `sunlight` theme every grey leaves the control chrome.** Hairlines become `sun-ink`
    `#000000` at `2` logical pixels on `sun-paper` `#FFFFFF`; `ink-faint` `#6C7871` hint text is
    re-encoded as italic serif at full `sun-ink`, never as a lighter grey. **WHY:** on an open deck
    at midday a `#6C7871` hairline is simply not there, and an invisible field looks broken.

11. **Toggles are squares whose state is a word.** `LonjaSwitch` paints a `20`-logical-pixel square
    that fills solid `ink` when on, beside a `sans` label reading the state in words. There is no
    track, no knob, no travel animation. **WHY:** a knob position is a picture of a switch, paper
    has no moving parts, and the word is what survives a glance through spray.

## The search field is a ruled entry line

One hairline under a serif value, an ink glyph, no fill, no radius, no focus glow. Height comes
from the density switch; the hint is italic and disposable, the label above it is not.

```dart
final t = LonjaTokens.of(context);
final h = t.glove ? LonjaTargets.gloveControl : LonjaTargets.control; // 66 : 56

// WRONG — Material's filled, rounded, 48dp box with the label hidden inside it.
TextField(
  decoration: InputDecoration(
    filled: true,
    hintText: 'Species',                                    // the label lives in the hint
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

// RIGHT — a printed entry line; the label survives input, the hint only illustrates.
ConstrainedBox(
  constraints: BoxConstraints(minHeight: h),
  child: DecoratedBox(
    decoration: BoxDecoration(
      color: t.paperSunk,                                   // #DEDBD1
      border: Border.all(color: t.ink, width: 1.5),         // #16201C, BorderRadius.zero
    ),
    child: TextField(                                       // lonja-core-ok
      style: t.serifValue,                                  // 19, ink
      decoration: InputDecoration.collapsed(
        hintText: 'Search species — هامور, Hamour, grouper',
        hintStyle: t.serifHint,                             // italic, ink-faint #6C7871
      ),
    ),
  ),
);
```

Full worked file: `examples/lonja_search_field.dart`.

## Targets, separation and glove mode

Glove mode is an orthogonal density switch, not a theme. Read it once per control from the token
extension and let it choose the height; never branch on screen width, and never hardcode 44 or 48.

```dart
// WRONG — Material's floor, a magic number, and targets that touch.
Column(children: const [
  SizedBox(height: 48, child: LonjaSwitch(label: 'Glove mode')),
  SizedBox(height: 48, child: LonjaSwitch(label: 'Sunlight')),
]);

// RIGHT — one source for the height, one source for the gap.
final t = LonjaTokens.of(context);
final h = t.glove ? LonjaTargets.gloveControl : LonjaTargets.control;
Column(
  children: [
    ConstrainedBox(
      constraints: BoxConstraints(minHeight: h),
      child: const LonjaSwitch(label: 'Glove mode'),
    ),
    SizedBox(height: LonjaTargets.separation),               // 8, never 4
    ConstrainedBox(
      constraints: BoxConstraints(minHeight: h),
      child: const LonjaSwitch(label: 'Sunlight'),
    ),
  ],
);
```

Full worked file: `examples/lonja_search_field.dart`.

## Square toggles and ruled segmented cells

A segmented control is a row of ruled cells sharing one internal divider, not a rounded track. The
selected cell inverts; the unselected cells keep the `paper` ground and the `rule` hairline.

```dart
// WRONG — Material's pill with the state carried by accent colour alone.
SegmentedButton<Method>(
  segments: const [/* … */],
  style: ButtonStyle(
    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20))),
    backgroundColor: WidgetStatePropertyAll(Color(0xFF1B4D5E)),   // harbour as the only signal
  ),
);

// RIGHT — ruled cells; selection is an ink fill plus a heavier label.
LonjaSegmented<Method>(
  value: method,
  onChanged: onMethodChanged,
  cells: const [
    LonjaCell(Method.totalLength, 'Total length'),   // ink ground + paper text when selected
    LonjaCell(Method.forkLength, 'Fork length'),
    LonjaCell(Method.shellLength, 'Shell length'),
  ],
);
```

Full worked file: `examples/lonja_search_field.dart`.

## The keypad and the manual entry path

`LonjaKeypad` is the primary length input and the only one guaranteed to exist. It is a 3x4 grid of
ruled keys, mono figures, no decimal ambiguity, and it never blocks on calibration state.

```dart
// WRONG — the ruler is treated as the only instrument, so a fresh install cannot answer.
if (!calibration.isCalibrated) {
  return const CalibrateFirstScreen();                      // dead end at 05:40
}
return const RulerScreen();

// RIGHT — keypad always; the ruler is an additional path once calibrated.
Column(children: [
  LonjaKeypad(                                              // 3x4, each key >= LonjaTargets.control
    value: lengthCm,
    unit: 'cm',                                             // fixed trailing slot, not the hint
    onChanged: onLengthChanged,
  ),
  if (calibration.isCalibrated)
    const LonjaSecondaryAction(label: 'Measure with the on-screen ruler'),
]);
```

Full worked file: `examples/lonja_search_field.dart`.

## Labels, hints and the unit that must survive

Every numeric field states its unit and its measurement method outside the editable text. The
figure and the unit are separate slots so neither can be typed away or mis-parsed.

```dart
// WRONG — the unit and the method are hints, so both vanish on the first keystroke.
TextField(decoration: const InputDecoration(hintText: 'Length in cm (total length)'));

// RIGHT — persistent label, editable figure, fixed unit, stated method.
Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text('Measured length', style: t.labelCaps),              // sans, .2em, ink-faint
  Row(children: [
    Expanded(child: LonjaFigureField(value: lengthCm)),     // mono, tabularFigures
    Text('cm', style: t.serifUnit),                         // fixed slot, never editable
  ]),
  Text('Total length (TL)', style: t.serifCaption),         // method, always visible
]);
```

Full worked file: `examples/lonja_search_field.dart`.

## Anti-patterns

- **`BorderRadius.circular(12)` on any field or cell** — turns a printed rule into app chrome and
  fails `scripts/check_lonja_controls.sh`.
- **`InputDecoration(filled: true)`** — Material's `surfaceVariant` ground fights `paper` `#E6E4DC`
  and erases the hairline that carries the whole Lonja idiom.
- **`hintText: 'Length in cm'`** — the unit dies on the first keystroke and 38 mm silently becomes
  38 cm.
- **`SizedBox(height: 48)` around a control** — Material's floor, not Khalid's; wet gloves need 56,
  and 66 under glove mode.
- **`textCapitalization: TextCapitalization.words` on the species field** — mangles `هامور` and
  fights Galician and Portuguese casing.
- **A `TextInputFormatter` that strips diacritics in the field** — normalisation belongs to the
  match query in `catchlaw-rule-engine`, never to the bytes the user sees.
- **`CircularProgressIndicator` while searching** — there is no network; a local drift read that
  needs a spinner is a query bug, not a UI state.
- **`Switch` with its Material track and thumb** — a moving knob in a printed document, and its
  state is unreadable at a glance through spray.
- **`verdant`/`oxblood` on a selected segment or a focused border** — semantic colour on an input
  makes a picker look like a verdict.
- **Grey `ink-faint` hairlines left unchanged in the `sunlight` theme** — the field disappears in
  glare and reads as broken hardware.
- **`autofocus: true` on the search field** — hides the recents strip, the fastest path to a verdict.

## Definition of done

- [ ] `scripts/check_lonja_controls.sh` is clean over `lib/`.
- [ ] No control outside `lib/ui/core/` constructs a raw Material input widget (rule 2).
- [ ] Every control height and gap resolves through `LonjaTargets`, with no numeric literal
      (rule 3).
- [ ] Every field's unit, label and measurement method are visible with text present AND absent
      (rules 4, 5).
- [ ] The measurement screen reaches `LonjaKeypad` on an uncalibrated device, verified in a widget
      test (rule 6).
- [ ] Typing `هامور` and `Ameixa babosa` leaves the field text byte-identical (rule 7).
- [ ] Selected, focused and disabled states are each distinguishable in a greyscale screenshot
      (rule 8).
- [ ] No control renders a spinner, cloud, sync or progress affordance anywhere in the diff
      (rule 9).
- [ ] Paper, night and sunlight golden lanes are attached for every control touched, at glove and
      standard density (rules 3, 10).

## Related skills

- See `forms-and-input` for `Form`, `GlobalKey<FormState>`, sync-vs-async validation, focus
  traversal, `TextInputFormatter` policy and controller disposal — every form mechanic this skill
  deliberately omits.
- See `lonja-design-tokens` for the `LonjaTokens` extension, the `paper`/`ink`/`rule` slot names and
  the three-theme plus glove-density resolution these controls read.
- See `lonja-typography` for the serif, sans, mono and arabic role stacks and the
  `FontFeature.tabularFigures()` numeric style every figure field uses.
- See `lonja-buttons` for the square action button ladder, its 56dp floor and the pressed and
  disabled encodings a control's affordances must match.
- See `accessibility-as-code` for the never-colour-alone floor, `Semantics` labelling of a
  toggle's state and `textScaler` behaviour these controls must not clamp.
- See `i18n-rtl-l10n` for `EdgeInsetsDirectional` icon and caret placement, bidi isolation of mixed
  Arabic and Latin field text, and per-locale numeral shaping in the keypad.
- See `catchlaw-rule-engine` for the diacritic folding and Arabic normalisation applied to the
  search *query*, which this skill forbids applying to the visible text.
- See `catchlaw-measurement-ruler` for calibration state, the on-screen ruler and the unit model the
  keypad writes into.
- See `widget-composition` for extracting each control as a `const` `Widget` class rather than a
  `Widget _buildField()` method.

## References

- Flutter API — `TextField`: https://api.flutter.dev/flutter/material/TextField-class.html
- Flutter API — `InputDecoration`: https://api.flutter.dev/flutter/material/InputDecoration-class.html
- Flutter API — `FontFeature.tabularFigures`: https://api.flutter.dev/flutter/dart-ui/FontFeature/FontFeature.tabularFigures.html
- Flutter API — `TextInputType`: https://api.flutter.dev/flutter/services/TextInputType-class.html
- Flutter API — `BoxConstraints`: https://api.flutter.dev/flutter/rendering/BoxConstraints-class.html
- Material 3 — Accessibility basics: https://m3.material.io/foundations/accessible-design/accessibility-basics
