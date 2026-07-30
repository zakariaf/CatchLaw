---
name: lonja-buttons
description: >-
  Enforces the CatchLaw action ladder, buttons as printed stamps — one primary per screen and never
  two, LonjaButtonVariant primary a solid harbour 1B4D5E field at radius 0, secondary an ink outline,
  quiet a rule-grey outline, destructive oxblood 7A2320 behind a confirmation, link only in prose,
  zero elevation and NoSplash.splashFactory instead of shadows, a default, hover, focus,
  pressed, disabled and busy matrix resolved in WidgetStateProperty, 56dp regular and 46dp compact
  heights glove mode floors to 66dp, 44dp IconButton carrying a real semanticLabel, a busy latch so
  a double tap never writes two rows, and a verb label naming exactly what happens. Use when adding
  a button, styling ElevatedButton, FilledButton, TextButton, IconButton or SegmentedButton, editing
  lib/ui/core/lonja_button.dart, wiring onPressed to a Notifier, choosing between primary and quiet,
  adding a destructive affordance, or reviewing any tappable in a diff.
---

# Lonja Buttons

A Lonja button is a **stamp pressed onto paper, never a pill floating above it** — no shadow, no ripple, no gradient, radius at most 2dp, its whole hierarchy carried by field, rule weight and label. This skill owns the action ladder and how many of each is earned, the six-state matrix, target sizes under glove mode, the icon and label slots, destructive confirmation, and label wording. It does not own token values, the tap-target floor, async guards, or the dialog a destructive action opens.

Read the reference for the task at hand:
- `references/variant-ladder-and-states.md` — the five variants, what earns each, the six-state matrix, paper/night/sunlight resolution, glove metrics, disabled and busy semantics.
- `references/button-anatomy.md` — box metrics, icon and label slots, the label wording table, icon-only rules, button rows, the SegmentedButton boundary.

Run `scripts/check_lonja_buttons.sh` before a PR.

The 44dp tap-target floor and `Semantics(button: true)` are owned by `accessibility-as-code`; the dropped-`Future` hole in `onPressed: () => vm.record(fish)` is owned by `async-safety`; the confirmation dialog itself is owned by `lonja-dialogs-and-surfaces`; the hex behind every slot is owned by `lonja-design-tokens`. This skill governs the button that reads them.

## Non-negotiable rules

1. **ONE primary action per screen. Never two.** Exactly one `LonjaButtonVariant.primary` may be built per route; every other action steps down to `secondary`, `quiet` or an inline link. Two harbour fields force the fisher to decide which of two things is *the* thing to do while a live fish thrashes in the bin — the ladder exists to delete that decision, and `scripts/check_lonja_buttons.sh` fails any file that builds two.

2. **A button label is a verb phrase naming exactly what happens.** `Record another`, `Save calibration`, `End trip`, `Export as CSV to this phone` — NEVER `OK`, `Yes`, `Submit`, `Continue`, `Done` or `Confirm`. A label that does not name its own consequence forces a re-read at 05:40 in the dark with wet hands, and re-reads are precisely the cost this app exists to remove.

3. **NEVER put an instruction about the fish on a button.** `Keep`, `Return`, `Throw it back`, `Discard`, `Land it` are banned outright in all six locales. The app STATES a fact and the fisher decides; an imperative on a button converts a statement of law into advice this project is not licensed to give, which is the one failure that ends the project rather than the session (wording contract owned by `catchlaw-verdict-contract`).

4. **No elevation, no shadow, no ripple, radius <= 2.** `elevation: WidgetStatePropertyAll(0)`, transparent `shadowColor`, `splashFactory: NoSplash.splashFactory`, `RoundedRectangleBorder(borderRadius: BorderRadius.zero)`. A drop shadow says "floating card"; this app's authority comes from looking like the printed instrument it quotes, and ONE elevated button reframes the whole screen as an app rather than a document.

5. **Every button in `lib/` is a `LonjaButton` or a `LonjaIconButton`.** Raw `ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextButton`, `CupertinoButton` and `MaterialButton` are legal ONLY inside `lib/theme/` and `lib/ui/core/`, where the two wrappers are defined; the trailing escape hatch `// lonja-button-ok` is the only exemption. A hand-rolled `ButtonStyle` at a call site ships a fourth theme nobody golden-tests.

6. **Hierarchy is field plus rule weight — colour is NEVER the only difference.** primary = harbour `#1B4D5E` field with `#EFF1EC` label, secondary = transparent field with a 1.5dp ink `#16201C` rule, quiet = transparent field with a 1.5dp `#C2C5BB` rule and `#3D4A44` label. Grade by ink weight, because in sunlight mode harbour collapses to `#000000` and a colour-only ladder flattens to one indistinguishable step (the never-colour-alone floor itself is owned by `accessibility-as-code`).

7. **56dp regular, 46dp compact, and glove mode floors EVERY action to 66dp.** `LonjaDensity.of(context).isGlove` raises regular and compact alike to 66dp, the label from 15 to 16.5, and the row gap from 8 to 12dp; compact simply ceases to exist. A neoprene glove over a wet finger lands 15-20dp off the visual centre, so a 46dp control in glove mode is a mis-tap, and a mis-tap on this screen is a wrong verdict.

8. **An icon-only button requires a `semanticLabel` and 44dp of box.** `LonjaIconButton` takes `semanticLabel` as a required parameter and forwards it to `tooltip`, which is what `IconButton` wires into its own `Semantics` node; the 22dp glyph sits inside a 44dp box (56dp in glove) via `BoxConstraints.tightFor`. An unlabelled glyph is silent to TalkBack and VoiceOver and ambiguous to everyone reading an engraved plate at dawn.

9. **A disabled control states its reason in adjacent prose.** Field goes paper-sunk `#DEDBD1`, label `#6C7871` ink-faint, rule `#C2C5BB`, and one line of ink-muted text says what is missing — "Select a zone first". A dead grey control with no explanation reads as a broken app, and a fisher who believes the app is broken stops using it and keeps the undersized fish.

10. **Busy is a latch, NEVER a spinner.** Set `onPressed: null` for the duration and, past 250ms only, draw a 1.5dp harbour rule along the button's bottom edge; never a `CircularProgressIndicator`, never a cloud or sync glyph. Every operation here is a local SQLite read that finishes inside one frame, so a spinner teaches the user to wait for a network that does not exist and to distrust an instant answer.

11. **The handler is idempotent under rapid taps.** Guard with `if (_busy) return;` before the first `await`, flip the latch inside `setState`, and clear it in a `finally` gated on `mounted`. Two taps on `Record another` in the 90ms it takes wet fingers to bounce writes two rows to the user database and doubles the trip tally; the dropped-`Future` half of this hole is owned by `async-safety`.

12. **Destructive actions are oxblood and ALWAYS confirm.** `LonjaButtonVariant.destructive` is an oxblood `#7A2320` field with an `#E9DCD6` label and a leading glyph, it is never the screen's primary, and it routes through the confirmation surface owned by `lonja-dialogs-and-surfaces`, whose accept button repeats the verb — `Delete this trip`, never `Yes`. Oxblood is the FAILS-THE-RULE semantic, so an oxblood button that merely cancels teaches the fisher to read the verdict colour as chrome.

## The variant ladder

Five variants, ranked, and each one is *earned* rather than chosen: one `primary` per screen, `secondary` for the real alternative, `quiet` for the escape route, `destructive` behind a confirmation, `link` only inside running prose. The variant is an enum on `LonjaButton`, never a `ButtonStyle` assembled at the call site.

```dart
// WRONG — two harbour fields; the fisher must now rank them himself.
LonjaButton.primary(label: 'Record another', onPressed: vm.record),
LonjaButton.primary(label: 'End trip', onPressed: vm.endTrip),

// WRONG — a call-site ButtonStyle invents a sixth variant nobody golden-tests.
FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1B4D5E)), ...),

// RIGHT — one primary, the rest step down the ladder.
LonjaButton.primary(label: 'Record another', icon: LonjaIcons.stamp, onPressed: vm.record),
LonjaButton.secondary(label: 'Identify this fish', onPressed: vm.openKey),
LonjaButton.quiet(label: 'Skip this couplet', onPressed: vm.skip),
LonjaButton.destructive(label: 'Delete this trip', onPressed: vm.confirmDeleteTrip),
```

Full worked file: `examples/result_actions.dart`.

## Sizes, glove mode and separation

Regular is 56dp, compact 46dp, icon-only 44dp square. Glove mode is an orthogonal density switch, not a theme: it floors every action to 66dp, the icon box to 56dp, and the gap between stacked actions from 8 to 12dp. Read it from the density extension, never from a screen-width breakpoint.

```dart
final glove = LonjaDensity.of(context).isGlove;

// WRONG — compact survives glove mode and becomes a 46dp mis-tap target.
minimumSize: WidgetStatePropertyAll(Size.fromHeight(compact ? 46 : 56)),

// WRONG — density inferred from width; a phone in a pocket is not a glove.
final glove = MediaQuery.sizeOf(context).width < 400;

// RIGHT — glove floors both sizes and widens the gap.
minimumSize: WidgetStatePropertyAll(Size.fromHeight(glove ? 66 : (compact ? 46 : 56))),
// ...and the enclosing column:
Column(spacing: glove ? 12 : 8, children: actions),
```

Full worked file: `examples/lonja_buttons.dart`.

## The state matrix without shadows

Six states — default, hover, focus, pressed, disabled, busy — and not one of them may move the box, scale it, or cast anything. Hover and pressed are ink washes over the field; focus doubles the rule to 3dp and swaps it to harbour (to ink on a harbour field); disabled sinks to paper-sunk. Resolve all of it in `WidgetStateProperty.resolveWith`, never in local `setState`.

```dart
side: WidgetStateProperty.resolveWith((states) {
  if (states.contains(WidgetState.focused)) {
    // RIGHT — focus is a printed registration mark: heavier rule, same box.
    return BorderSide(color: variant.isFilled ? c.ink : c.harbour, width: 3);
  }
  return BorderSide(color: edge, width: 1.5);
}),
overlayColor: WidgetStateProperty.resolveWith((states) {
  if (states.contains(WidgetState.pressed)) return c.ink.withValues(alpha: 0.10);
  if (states.contains(WidgetState.hovered)) return c.ink.withValues(alpha: 0.04);
  return Colors.transparent; // WRONG would be an InkRipple: paper does not ripple.
}),
```

Full worked file: `examples/lonja_buttons.dart`.

## Icon and label slots

A button has at most two slots: one leading 20dp glyph and one label. No trailing chevrons, no badge counts, no second glyph. Icon-only is a separate widget with a required `semanticLabel`, and the glyph is an engraved-line-art `IconData` from the plate set, never a filled Material glyph.

```dart
// WRONG — icon-only with no accessible name; TalkBack reads "button".
IconButton(icon: const Icon(Icons.close), onPressed: pop),

// WRONG — two glyphs and a count turn a stamp into a toolbar.
LonjaButton.secondary(label: 'Trip', icon: a, trailingIcon: b, badge: 3, ...),

// RIGHT — one glyph, one label, or a labelled icon-only box.
LonjaButton.primary(label: 'Save calibration', icon: LonjaIcons.rule, onPressed: vm.save),
LonjaIconButton(icon: LonjaIcons.back, semanticLabel: 'Back one step', onPressed: vm.back),
```

Full worked file: `examples/lonja_buttons.dart`.

## Busy, and idempotent under a double tap

The only correct busy affordance is a latch: `onPressed` goes null, the label and the box do not change, and past 250ms a 1.5dp harbour rule appears along the bottom edge. The guard belongs in the handler, before the first `await` — the visual is a consequence of the latch, not the mechanism.

```dart
Future<void> _record() async {
  if (_busy) return;                 // RIGHT — the second wet tap is dropped.
  setState(() => _busy = true);
  try {
    await widget.onRecord();         // one INSERT into the writable user DB
  } finally {
    if (mounted) setState(() => _busy = false);
  }
}

// WRONG — fire-and-forget, no latch: two taps, two rows, two tally marks.
LonjaButton.primary(label: 'Record another', onPressed: () => vm.record(fish)),
// RIGHT — the latched handler, disabled while it runs.
LonjaButton.primary(label: 'Record another', busy: _busy,
    onPressed: _busy ? null : () => unawaited(_record())),
```

Full worked file: `examples/result_actions.dart`.

## Destructive actions and the confirm hand-off

Destructive means the user database loses a row. The oxblood field plus a glyph plus a verb naming the object is the button; the confirmation is a separate surface, and its accept button repeats the same verb so the fisher never confirms an unnamed action.

```dart
// WRONG — no confirmation, and "Yes" names nothing.
LonjaButton.destructive(label: 'Yes', onPressed: vm.deleteTrip),

// WRONG — destructive promoted to primary; oxblood now competes with the verdict.
LonjaButton.primary(label: 'Delete this trip', onPressed: vm.deleteTrip),

// RIGHT — oxblood, glyph, named object, confirmation owned by lonja-dialogs-and-surfaces.
LonjaButton.destructive(
  label: 'Delete this trip',
  icon: LonjaIcons.strike,
  onPressed: () => confirmDestructive(context, verb: 'Delete this trip'),
),
```

Full worked file: `examples/result_actions.dart`.

## Labels that state what happens

Every label is a verb phrase, sentence case, no terminal period, and it names the object it acts on. The real corpus is the mockup's own: `Identify this fish`, `Add to today`, `Add to today as a bycatch note`, `Record another`, `End trip`, `Save calibration`, `Reset to screen default`, `Re-calibrate with a card`, `Export as CSV to this phone`, `Back one step`, `Skip this couplet`, `Type instead`, `Browse by shape`.

```dart
// WRONG — none of these name a consequence; two of them give advice.
const banned = ['OK', 'Yes', 'Submit', 'Continue', 'Done', 'Keep', 'Return', 'Throw it back'];

// WRONG — a noun is a tab label, not an action.
LonjaButton.secondary(label: 'Calibration', onPressed: vm.openCalibration),

// RIGHT — verb, then the object it touches; translated through ARB, never concatenated.
LonjaButton.secondary(label: l10n.actionRecalibrateWithCard, onPressed: vm.openCalibration),
LonjaButton.quiet(label: l10n.actionExportCsvToThisPhone, onPressed: vm.export),
```

Full worked file: `examples/result_actions.dart`.

## Anti-patterns

- **`FilledButton(style: FilledButton.styleFrom(...))` at a call site** — invents an untested sixth variant and hardcodes one theme's hex into a feature file.
- **Two `LonjaButton.primary` on one route** — the fisher ranks them himself, badly, in the ten seconds he has.
- **`elevation: 2` or any `BoxShadow` on an action** — the screen stops reading as a printed instrument and the whole Lonja premise collapses.
- **`BorderRadius.circular(28)`** — a pill; the design language has exactly one rounded thing and it is not a button.
- **`CircularProgressIndicator` inside a button** — implies a network round-trip in a 100% offline app and trains distrust of instant answers.
- **`IconButton(icon: Icon(Icons.delete))` with no `tooltip`** — silent to screen readers and, on a plate-art icon set, ambiguous to sighted users too.
- **`onPressed: () => vm.record(fish)`** — drops the `Future` and skips the latch, so a bounced tap writes two rows (`async-safety` owns the Future half).
- **`Opacity(opacity: 0.4)` as the disabled state** — halves contrast on an already low-chroma palette and still explains nothing.
- **A `quiet` button used for the screen's real action** — the ladder inverts and the fisher's eye lands on the escape route.
- **Colour-only variant differences** — identical in sunlight mode, where harbour and ink both resolve to `#000000`.
- **`label: 'Keep'` / `'Return'`** — turns a statement of law into fishing advice, which is a legal exposure, not a copy nit.
- **`SegmentedButton` used to fire an action** — it selects state; an action button commits it (`lonja-forms-and-controls`).

## Definition of done

- [ ] `scripts/check_lonja_buttons.sh` is clean over `lib/`.
- [ ] Exactly one `LonjaButtonVariant.primary` is built per route (rule 1).
- [ ] Every label is a verb phrase naming its object, and no label instructs the fisher about the fish (rules 2, 3).
- [ ] No `elevation`, `BoxShadow`, `InkRipple` or radius above 2dp on any action; `splashFactory` is `NoSplash.splashFactory` (rule 4).
- [ ] No raw Material button constructor exists outside `lib/theme/` and `lib/ui/core/` (rule 5).
- [ ] Regular actions measure 56dp, compact 46dp, and a glove-mode golden shows 66dp with 12dp gaps (rules 6, 7).
- [ ] Every icon-only button passes a non-empty `semanticLabel` and renders in a 44dp box (rule 8).
- [ ] Every disabled action has adjacent prose naming what is missing (rule 9).
- [ ] Every async handler latches on `_busy` before its first `await` and clears it in a `finally` (rules 10, 11).
- [ ] Every destructive action is oxblood, is not the primary, and opens a confirmation whose accept button repeats the verb (rule 12).

## Related skills

- See `lonja-design-tokens` for the slot names and the paper/night/sunlight hex behind harbour, oxblood, paper-sunk and ink-faint that these buttons read.
- See `lonja-typography` for the sans action-label role, its 15/16.5dp sizes and 0.03em tracking, and the tabular figures a numeric label uses.
- See `lonja-dialogs-and-surfaces` for the confirmation surface a destructive button opens, its barrier policy and its typed result.
- See `lonja-forms-and-controls` for `SegmentedButton`, chips, switches and everything that selects state rather than committing it.
- See `lonja-icons-and-plates` for the engraved-line-art `IconData` set the 20dp leading slot draws from.
- See `accessibility-as-code` for the tap-target floor, `Semantics(button: true)`, the never-colour-alone rule and text scaling these buttons must survive.
- See `async-safety` for the dropped-`Future` and post-`await` `BuildContext` rules the latched handler depends on.
- See `widget-composition` for extracting `LonjaButton` as a `Widget` class rather than a `Widget _buildButton()` helper.
- See `catchlaw-verdict-contract` for the statement-of-fact wording law that forbids `Keep` and `Return` on any control.

## References

- Flutter API — `ButtonStyle`: https://api.flutter.dev/flutter/material/ButtonStyle-class.html
- Flutter API — `WidgetStateProperty`: https://api.flutter.dev/flutter/widgets/WidgetStateProperty-class.html
- Flutter API — `NoSplash`: https://api.flutter.dev/flutter/material/NoSplash-class.html
- Flutter API — `IconButton`: https://api.flutter.dev/flutter/material/IconButton-class.html
- Flutter API — `SegmentedButton`: https://api.flutter.dev/flutter/material/SegmentedButton-class.html
- Material 3 — Common buttons specs: https://m3.material.io/components/buttons/specs
- W3C WAI-ARIA APG — Button pattern: https://www.w3.org/WAI/ARIA/apg/patterns/button/
