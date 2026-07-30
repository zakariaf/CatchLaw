# Modal Decision Matrix

Scope: deciding whether a surface is a modal, a route or an inline panel in CATCHLAW, and the
barrier, focus, label and result policy that follows from that decision.

## 1. The single question

> Can the user do anything useful, anywhere in the app, while this surface is on screen?

- **Yes** → route (`context.push`) or inline `LonjaPanel`. Never a modal.
- **No, the app genuinely cannot continue until they answer** → modal.

There is no third answer. "It felt lighter as a dialog" is not an answer.

## 2. The matrix

| Surface | Blocks? | Verdict | Barrier | Result type |
|---|---|---|---|---|
| Species account — Epinephelus coioides | no | route `/species/:id` | — | — |
| Citation detail — Ministerial Decision 580/2015, Art. 3 | no | route | — | — |
| Zone picker — Ras Al Khaimah / Rias Baixas | no | route or inline panel | — | — |
| Unit switch cm ↔ mm | no | inline segmented control | — | — |
| Stale-data notice (checked 2026-07-14) | no | inline `ochre` panel on result | — | — |
| Discard current measurement | yes | modal | `false` | `DiscardOutcome` |
| Delete a saved catch entry | yes | modal | `false` | `DeleteOutcome` |
| Two equally specific rules apply | yes | **ambiguity modal** | `false` | `AmbiguityChoice` |
| Reset the user database | yes | modal, typed confirm | `false` | `ResetOutcome` |
| First-run locale + zone selection | yes | full route, not a modal | — | — |
| "Measurement saved" | no | snackbar, 4 s, no action | — | — |
| "Entry removed" + Undo | no | snackbar, 8 s, deferred write | — | — |

First-run setup is a route because it is multi-step and resumable; a modal that owns four steps is a
route wearing a barrier.

## 3. Barrier policy

| Modal class | `barrierDismissible` | Back button | Rationale |
|---|---|---|---|
| Destructive (discard, delete, reset) | `false` | intercepted → `dismissed` | stray wet-hand taps |
| Ambiguity | `false` | intercepted → `deferredToBoth` | legal-liability defence |
| Non-destructive confirm | `false` | pops → `dismissed` | consistency; one habit only |
| Informational | n/a — must not be a modal | — | — |

Always pass `barrierDismissible` explicitly. Relying on the Flutter default (`true`) means the
policy is invisible in the diff and `check_lonja_dialogs.sh` cannot reason about it.

Barrier paint is a flat wash, never a gradient and never a blur:

| Theme | Barrier colour | Alpha |
|---|---|---|
| paper | `ink` `#16201C` | 0.62 |
| night | `ink` `#16201C` | 0.78 |
| sunlight | `sun-ink` `#000000` | 0.90 |

## 4. Focus capture and return

1. Before `showLonjaDialog`, capture `final opener = FocusManager.instance.primaryFocus`.
2. Inside the dialog, the outermost child is a `FocusScope`; the first *non-destructive* action gets
   `autofocus: true`. Never autofocus the destructive action — a stray Enter on a hardware keyboard
   would confirm it.
3. After the `await` returns, `opener?.requestFocus()`.
4. Guard the whole tail with `if (!context.mounted) return;` — see `async-safety`.

Directional geometry (which side the confirm sits on, `EdgeInsetsDirectional`, mirrored barrier
insets under Arabic) is owned by `i18n-rtl-l10n`. Do not hand-swap children by locale here.

## 5. Destructive labels

The confirm button is a verb phrase naming the effect. The cancel button names the *preservation*,
not the abstention.

| Situation | Confirm label | Cancel label |
|---|---|---|
| Discard measurement (38 cm, Hamour) | `Discard measurement` | `Keep it` |
| Delete catch entry (Kanaad, 2026-07-14) | `Delete this catch entry` | `Keep the entry` |
| Reset user database | `Erase all saved catches` | `Keep my catches` |
| Clear a zone override | `Clear the zone override` | `Keep Ras Al Khaimah` |

Banned literals, enforced by the gate: `OK`, `Ok`, `Cancel`, `CANCEL`, `Yes`, `No`, `Confirm`,
`Dismiss`. Every label is an ARB key; `i18n-rtl-l10n` owns the key naming and the Arabic form.

Copy stays a statement of fact, never an instruction — the title says
`This measurement will be discarded`, never `Are you sure you want to discard?` and never
`You should discard this`.

## 6. Typed results

Model closed choices as an `enum`; model outcomes carrying data as a `sealed class`. Never `bool`.

```dart
enum DiscardOutcome { discarded, kept, dismissed }

sealed class AmbiguityChoice {
  const AmbiguityChoice();
}

final class AppliedInstrument extends AmbiguityChoice {
  const AppliedInstrument(this.instrumentId);
  final String instrumentId; // 'ae-md-580-2015-art3'
}

final class DeferredToBoth extends AmbiguityChoice {
  const DeferredToBoth();
}
```

Callers must handle every case, including `null` (the dialog was torn down by a route pop). A `null`
result NEVER falls through to a write.

## 7. The ambiguity case

Preconditions, all of which the rule engine asserts before the dialog is even constructed:

1. Two or more candidate rules match the same species, gear, zone and date.
2. They are of **equal specificity** — the engine could not rank them.
3. Their outcomes differ (a 45 cm minimum versus a 50 cm minimum).

Presentation contract:

- Both candidates rendered as full `LonjaPlate` blocks, in source order, at identical visual weight.
- Each plate carries: instrument name, article, publication date, last-checked date.
- Two equal-weight outlined actions plus a third, `Show both — decide on the water`.
- No default, no `autofocus` on either instrument action, no colour distinction between them.
- The non-dismissable disclaimer remains on the result surface underneath; it is not restated here.

Why the app refuses to choose is a legal question owned by `catchlaw-verdict-contract`. This skill
only guarantees the presentation cannot leak a preference.

## 8. Snackbar policy

| Rule | Value |
|---|---|
| Informational only | required actions go in a modal or on the surface |
| Max actions | 1, and it must be optional (`Undo`) |
| Duration, no action | 4 s |
| Duration, with `Undo` | 8 s |
| Behaviour | `SnackBarBehavior.fixed`, zero radius, no float, no margin |
| Write ordering | deferred; commit in `.closed` when `reason != SnackBarClosedReason.action` |
| Queueing | `hideCurrentSnackBar()` before showing a second; never stack |

Never show a snackbar for a verdict, a citation, a failure to read the rule database, or anything a
prosecutor could ask about. Those are surfaces, not toasts.
