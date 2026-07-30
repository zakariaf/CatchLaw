---
name: lonja-dialogs-and-surfaces
description: >-
  Enforces Lonja modal and transient-surface policy across CATCHLAW dialogs, sheets, snackbars
  and plates — earning a modal only for a decision that must resolve before the user continues,
  squaring LonjaPanel and LonjaPlate off as ruled inset paper with no BoxShadow, no BorderRadius,
  no elevation and no scrim gradient, forcing barrierDismissible false on destructive and ambiguity
  modals, returning typed results like AmbiguityChoice instead of a bare bool, naming the consequence
  in the confirm label instead of OK, restoring focus to the opener after showLonjaDialog, and
  rendering the AmbiguityDialog that prints both conflicting instruments and refuses to choose.
  Use when adding showDialog or showModalBottomSheet, building lonja_ambiguity_dialog.dart,
  writing a destructive confirmation, wiring a SnackBar undo window, styling a panel or plate
  surface, choosing a modal over a route, or reviewing any barrier or dialog result in a diff.
---

# Lonja Dialogs And Surfaces

A CATCHLAW dialog is **a slip of paper pasted square onto the page, not a card floating above it**.
This skill owns when a modal is earned at all, barrier and focus policy, destructive confirmation
copy, the typed result a modal hands back, snackbar and undo policy, and the ruled-inset treatment
of every panel, plate and sheet. It does NOT own routing, theme plumbing, semantics floors, or the
legal reasoning that decides a verdict is ambiguous in the first place.

Read the reference for the task at hand:
- `references/modal-decision-matrix.md` — modal versus route, barrier policy, focus capture and
  return, destructive labels, typed results, the ambiguity case.
- `references/surfaces-and-plates.md` — panel and plate anatomy, rule weights, inset depth, sheet
  geometry, snackbar slab, three-theme and glove-mode values.

Run `scripts/check_lonja_dialogs.sh` before a PR.

Routes and deep links live in `navigation-and-routing`; verdict wording lives in
`catchlaw-verdict-contract`. This skill governs everything drawn *over* a route.

## Non-negotiable rules

1. **A modal is EARNED only by a decision that must resolve.** A modal exists to block until the
   user answers a question the app cannot proceed without — discard this measurement, choose between
   two conflicting instruments. Anything informational, browsable, or dismissable-by-ignoring is a
   route or an inline panel. A modal used as a container teaches Khalid to swipe modals away
   reflexively, and the one modal that mattered gets swiped away too.

2. **EVERY dialog returns a typed result, never a bare bool.** Declare
   `showLonjaDialog<AmbiguityChoice>` and pop `AmbiguityChoice.deferredToBoth`, never `true`. A
   `bool?` collapses three distinct outcomes — confirmed, declined, dismissed by barrier — into two
   and a null the caller silently treats as "no". On a destructive path that null is how a species
   record disappears without the user having confirmed anything.

3. **Destructive confirm labels NAME the consequence, NEVER "OK".** The button reads
   `Discard measurement` or `Delete this catch entry`, and the cancel reads `Keep it`. "OK" /
   "Cancel" / "Yes" / "No" are banned literals — `check_lonja_dialogs.sh` fails on them. A label
   that does not state its own effect is unreadable at 05:40 with wet hands, and the user confirms
   by muscle memory rather than by intent.

4. **`barrierDismissible` is FALSE on destructive and ambiguity modals.** Set it explicitly to
   `false` and never rely on the default; a tap-outside must not be able to resolve a question with
   legal weight. Wet hands on a 6-inch phone generate stray barrier taps constantly, and an
   accidental dismissal that reads as "declined" is indistinguishable from a deliberate one in the
   result the caller receives.

5. **The ambiguity dialog shows BOTH rules and picks neither.** When two equally specific
   instruments cover the same catch — a federal minimum and a state minimum over Represa de
   Jurumirim — render both plates in full with both citations and offer no "recommended" affordance.
   Choosing on the user's behalf converts the app from a quoting instrument into an adviser, which
   is exactly the liability `catchlaw-verdict-contract` exists to refuse.

6. **Lonja surfaces are ruled and inset — NEVER elevated cards.** `elevation: 0`,
   `shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)`, `surfaceTintColor:
   Colors.transparent`, a 1px `rule` `#C2C5BB` border, `paper-sunk` `#DEDBD1` fill. No `BoxShadow`,
   no `Card`, no gradient scrim. A shadow is a claim that the surface floats in space; this app's
   authority comes from looking printed, and a drop shadow reads as an ad overlay.

7. **Focus is captured on open and RESTORED to the opener.** Capture
   `FocusManager.instance.primaryFocus` before `showLonjaDialog`, put a `FocusScope` with
   `autofocus` on the primary action inside, and refocus the captured node in the `.then` after it
   pops. Without the restore, TalkBack and VoiceOver drop the cursor to the top of the route and the
   user re-reads the whole result screen to find where they were.

8. **A snackbar NEVER carries an action the user must take.** Snackbars announce a completed,
   already-committed fact — "Measurement saved" — plus at most one *optional* `Undo`. Anything
   required, anything with a consequence, anything legal goes in a modal or on the surface itself. A
   snackbar auto-dismisses in four seconds and is invisible to a user looking at a fish, so a
   required action placed there is an action that never happens.

9. **The undo window is 8 seconds and the write is DEFERRED.** Hold the delete in memory, show
   `SnackBar(duration: Duration(seconds: 8))`, and commit to the writable drift DB only in the
   dismissal callback when `reason != SnackBarClosedReason.action`. Writing first and reversing on
   undo means a crash inside the window makes an "undoable" delete permanent with no trace.

10. **Sheets are squared off — no handle, no rounded top, no drag.** `showModalBottomSheet` takes
    `shape: const RoundedRectangleBorder()`, `showDragHandle: false`, `isDismissible` matching the
    same policy as a dialog barrier, and a 2px `rule-strong` `#A9AC9F` top rule instead of a pill. A
    rounded, handled sheet is Material chrome; it breaks the printed-document illusion that carries
    this app's authority.

11. **The result disclaimer NEVER migrates into a dialog.** The non-dismissable disclaimer stays
    rendered on the result surface itself; it may never be moved behind an "info" dialog, a tooltip
    or a `showDialog` triggered by an ⓘ button. A disclaimer the user can dismiss, or never open, is
    a disclaimer that was not shown — which is precisely the argument that defeats it.

12. **A modal NEVER blocks on I/O — no spinner over a barrier.** This app is 100% offline; every
    lookup is a local drift query measured in single-digit milliseconds. If a dialog needs data, the
    caller resolves it *before* opening and passes it in. A barrier-blocking spinner implies network
    latency the app does not have and invites the user to look for a connection that does not exist.

## Earning a modal versus a route

Ask one question: can the user keep doing anything useful while this is on screen? If yes it is a
route or an inline `LonjaPanel`, never a modal. Species accounts, citation detail, zone pickers and
the settings surface are all routes; only an unresolved decision blocks.

```dart
// WRONG — a modal used as a container for browsable content.
showDialog<void>(
  context: context,
  builder: (_) => const SpeciesAccountDialog(species: hamour),
);

// RIGHT — browsable content is a route; only a blocking decision is a modal.
context.push('/species/epinephelus-coioides');

// RIGHT — a decision that must resolve before anything else can happen.
final choice = await showLonjaDialog<DiscardOutcome>(
  context: context,
  barrierDismissible: false,
  builder: (_) => const DiscardMeasurementDialog(lengthCm: 38),
);
if (choice == DiscardOutcome.discarded) ref.read(measurementProvider.notifier).clear();
```

Full worked file: `examples/lonja_ambiguity_dialog.dart`.

## The ambiguity dialog

Two equally specific instruments covering one catch is a fact about the law, not a bug in the rule
engine. Print both plates at equal weight, in source order, with both citations, and let the user
carry the conflict. There is no primary button and no "recommended" badge.

```dart
// WRONG — the app silently resolves the conflict and states one verdict.
final rule = candidates.reduce((a, b) => a.minLengthCm > b.minLengthCm ? a : b);
return VerdictStamp(rule: rule);

// RIGHT — both instruments rendered, neither privileged, choice deferred to the user.
return LonjaAmbiguityDialog(
  candidates: candidates, // 2 rules, equal specificity, source order preserved
  onResolved: (AmbiguityChoice c) => Navigator.of(context).pop(c),
);
// Both actions are equal-weight outlined LonjaButtons:
//   'Apply 45 cm — Ministerial Decision 580/2015, Art. 3'
//   'Apply 50 cm — Represa de Jurumirim, Portaria 12/2021, Art. 8'
// plus 'Show both — decide on the water' -> AmbiguityChoice.deferredToBoth
```

Full worked file: `examples/lonja_ambiguity_dialog.dart`.

## Typed results, not bool

A dialog's return type is its contract. Use an `enum` for a closed choice or a `sealed` class when
the outcome carries data, so the caller must handle dismissal explicitly.

```dart
// WRONG — three outcomes crushed into bool?; the barrier tap becomes "declined".
final ok = await showDialog<bool>(context: context, builder: (_) => const ConfirmDialog());
if (ok == true) await repo.delete(entryId);

// RIGHT — dismissal is a named, unmissable case.
enum DiscardOutcome { discarded, kept, dismissed }

final outcome = await showLonjaDialog<DiscardOutcome>(
  context: context,
  barrierDismissible: false,
  builder: (_) => const DiscardMeasurementDialog(lengthCm: 38),
);
switch (outcome) {
  case DiscardOutcome.discarded: await repo.delete(entryId);
  case DiscardOutcome.kept || DiscardOutcome.dismissed || null: break; // no write
}
```

Full worked file: `examples/lonja_ambiguity_dialog.dart`.

## Panels and plates: the ruled inset

A `LonjaPanel` is a `paper-sunk` `#DEDBD1` field inside a 1px `rule` `#C2C5BB` hairline. A
`LonjaPlate` is the same box carrying engraved species line art with a 2px `rule-strong` `#A9AC9F`
top rule. Both are flat. In sunlight theme every grey is deleted: rules go to `sun-ink` `#000000`
on `sun-paper` `#FFFFFF`.

```dart
// WRONG — Material elevation, radius and tint; reads as a floating ad card.
Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
     child: child);

// RIGHT — a pasted slip: square, ruled, inset, zero shadow.
final c = LonjaColors.of(context);
DecoratedBox(
  decoration: BoxDecoration(
    color: c.paperSunk,                                  // #DEDBD1
    border: Border.all(color: c.rule, width: 1),         // #C2C5BB hairline
  ),
  child: Padding(padding: const EdgeInsets.all(LonjaSpace.plate), child: child),
);
```

Full worked file: `examples/lonja_plate_surface.dart`.

## Snackbars and the undo window

A snackbar is a receipt for something already done. It is a squared `paper-sunk` slab with a
`rule-strong` top edge, `behavior: SnackBarBehavior.fixed`, no radius, no float. The only action it
may carry is `Undo`, and the destructive write waits for the window to close.

```dart
// WRONG — write now, reverse later; a crash in the window makes it permanent.
await repo.delete(entryId);
messenger.showSnackBar(SnackBar(content: const Text('Deleted'),
  action: SnackBarAction(label: 'Undo', onPressed: () => repo.restore(entry))));

// RIGHT — deferred write, 8-second window, commit only if not undone.
var undone = false;
messenger
    .showSnackBar(SnackBar(
      duration: const Duration(seconds: 8),
      behavior: SnackBarBehavior.fixed,
      content: const Text('Kanaad entry removed'),
      action: SnackBarAction(label: 'Undo', onPressed: () => undone = true),
    ))
    .closed
    .then((reason) async {
      if (!undone && reason != SnackBarClosedReason.action) await repo.delete(entryId);
    });
```

Full worked file: `examples/lonja_plate_surface.dart`.

## Barrier, focus and RTL

The barrier is a flat `ink` wash at 62% opacity — never a gradient, never a blur. Capture the
focused node before opening and restore it after popping. Barrier geometry, dialog alignment and
action-row order must be directional, which `i18n-rtl-l10n` owns: use `EdgeInsetsDirectional` and
let the row reverse itself under Arabic rather than swapping widget order by hand.

```dart
// WRONG — blurred gradient scrim, physical padding, focus abandoned on close.
showDialog(context: context, barrierColor: Colors.black54,
  builder: (_) => Padding(padding: const EdgeInsets.only(left: 24), child: dialog));

// RIGHT — flat ink barrier, directional insets, focus returned to the opener.
final opener = FocusManager.instance.primaryFocus;
final result = await showLonjaDialog<AmbiguityChoice>(
  context: context,
  barrierDismissible: false,
  barrierColor: LonjaColors.of(context).ink.withValues(alpha: 0.62), // #16201C
  builder: (_) => const Padding(
    padding: EdgeInsetsDirectional.only(start: 24, end: 24),
    child: LonjaAmbiguityDialog(),
  ),
);
opener?.requestFocus();
```

Full worked file: `examples/lonja_ambiguity_dialog.dart`.

## Anti-patterns

- **`showDialog<bool>(...)`** — collapses confirm, decline and barrier-dismiss into `bool?`, and the
  null path silently becomes the destructive default.
- **`TextButton(child: Text('OK'))`** — states no consequence; confirmed by reflex at 05:40 rather
  than by intent, and untranslatable into Arabic without inventing the meaning.
- **`barrierDismissible: true` on a delete confirm** — a stray wet-hand tap outside resolves a
  legally weighted question and the caller cannot tell it from a deliberate decline.
- **`Card(elevation: 4)` as a panel** — a drop shadow claims the surface floats; the Lonja document
  is printed and flat, and the shadow reads as third-party ad chrome.
- **`BorderRadius.circular(12)` on any Lonja surface** — rounds a pasted slip of paper into a
  Material component and breaks the plate grid alignment with the margin article numbers.
- **`showModalBottomSheet(showDragHandle: true)`** — the pill handle is Material vocabulary and
  invites a drag gesture the squared sheet does not support.
- **`SnackBar` carrying "Tap to re-measure"** — a required action in a surface that vanishes in four
  seconds while the user is looking at a fish, not the phone.
- **A "recommended" badge in the ambiguity dialog** — turns a quoting tool into a liable adviser.
- **An ⓘ button opening the disclaimer** — a disclaimer behind a tap was never shown.
- **`CircularProgressIndicator` inside a dialog** — implies network latency a 100% offline app cannot
  have, sending the user hunting for a signal.
- **`AlertDialog` with default theming** — inherits Material 3 radius, tint and elevation; use the
  Lonja dialog shell so the shape is squared and the fill is `paper-sunk`.

## Definition of done

- [ ] `scripts/check_lonja_dialogs.sh` is clean over `lib/`.
- [ ] Every modal blocks a decision that must resolve; nothing browsable is modal (rule 1).
- [ ] No dialog or sheet returns `bool`; dismissal is a handled named case (rules 2, 4).
- [ ] Every confirm names its consequence; no `OK`/`Cancel`/`Yes`/`No` literal survives (rule 3).
- [ ] Destructive and ambiguity modals set `barrierDismissible: false` explicitly (rule 4).
- [ ] The ambiguity dialog shows both instruments, both citations, no primary action (rule 5).
- [ ] Every panel, plate, sheet and dialog has `elevation: 0`, zero radius, no `BoxShadow` (rule 6).
- [ ] Focus is captured before open and restored after pop, verified under TalkBack (rule 7).
- [ ] Any `SnackBar` is informational, ≤ 1 optional `Undo`, 8-second deferred write (rules 8, 9).
- [ ] The result disclaimer is still rendered inline, not behind a modal or tooltip (rule 11).

## Related skills

- See `lonja-design-tokens` for the exact values behind `paper-sunk`, `rule` and the sunlight swaps.
- See `design-system-structure` for the `ThemeExtension` mechanics and `of(context)` asserts.
- See `lonja-buttons` for the equal-weight outlined action row and glove-mode 56dp targets.
- See `catchlaw-verdict-contract` for why two equally specific instruments must both be shown.
- See `navigation-and-routing` for the `GoRouter` routes browsable content belongs on instead.
- See `i18n-rtl-l10n` for directional barrier insets, Arabic action-row order and the ARB keys.
- See `accessibility-as-code` for the dialog `Semantics` scope, announcement and 44px floor.
- See `lonja-verdict-and-status` for the stamp and glyph-plus-word pairing inside each plate.
- See `async-safety` for `mounted` guards around every `await showLonjaDialog`.

## References

- Flutter API — `showDialog`: https://api.flutter.dev/flutter/material/showDialog.html
- Flutter API — `showModalBottomSheet`: https://api.flutter.dev/flutter/material/showModalBottomSheet.html
- Flutter API — `ScaffoldMessengerState.showSnackBar`: https://api.flutter.dev/flutter/material/ScaffoldMessengerState/showSnackBar.html
- Flutter API — `FocusScope`: https://api.flutter.dev/flutter/widgets/FocusScope-class.html
- Flutter API — `DialogThemeData`: https://api.flutter.dev/flutter/material/DialogThemeData-class.html
- Flutter docs — Dialogs cookbook: https://docs.flutter.dev/cookbook/design/dialogs
