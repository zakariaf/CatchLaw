# Search Field and Keypad — deep dive

The two controls that decide whether Khalid gets an answer in five seconds: the species search
field and the manual length keypad. Answers "what happens when a wet hand meets this input?".

## The search field, slot by slot

| Slot | Content | Style | Survives input? |
|---|---|---|---|
| Leading glyph | engraved magnifier, 22px | `ink` `#16201C` | yes |
| Label (above the rule) | `Species` | sans 9.5, `.2em` caps, `ink-faint` | yes |
| Hint | `Search species — هامور, Hamour, grouper` | serif 17 italic, `ink-faint` | **no** |
| Value | what was typed | serif 19, `ink` | — |
| Caret | `1.5`px, blinking, `Duration.zero` under reduced motion | `ink` | — |
| Trailing clear | engraved cross, only when non-empty | `ink-muted` `#3D4A44` | — |
| Result count | `6 of 412` | mono 11, tabular figures, `ink-faint` | yes |

The hint is the only slot allowed to disappear, which is exactly why it may never carry the field's
name, its unit, or its measurement method.

## Script handling: what the field does and does not do

| Concern | Field behaviour | Owner |
|---|---|---|
| Rendering `هامور` as typed | verbatim, no reshaping, arabic role stack | `lonja-typography` |
| Mixed `هامور Hamour` in one field | FSI/PDI bidi isolation of each run | `i18n-rtl-l10n` |
| Caret and glyph side | `EdgeInsetsDirectional`, mirrors with the locale | `i18n-rtl-l10n` |
| Casing | none applied; `textCapitalization: TextCapitalization.none` | this skill |
| Diacritic folding for matching | `Sha'ri` matches `Sha'ri`, `Ameixa` matches `ameixa` | `catchlaw-rule-engine` |
| Arabic normalisation for matching | alef/hamza/teh-marbuta folding, tatweel strip | `catchlaw-rule-engine` |
| Keyboard type | `TextInputType.text`, never `.name`, never `.emailAddress` | this skill |

The rule that binds them: **the visible text is the user's, the query string is the engine's.**
Never mutate the controller's text to make matching easier. If a search for `هامور` misses, the fold
in `catchlaw-rule-engine` is wrong; the field is not.

## Worked examples the field must handle

| Typed | Must match | Trap |
|---|---|---|
| `هامور` | Hamour / Orange-spotted grouper / *Epinephelus coioides* | Arabic-only input with a Latin-labelled row |
| `hamur` | Hamour | transliteration variant, no diacritics |
| `Sha'ri` | Sha'ri / Spangled emperor / *Lethrinus nebulosus* | apostrophe is a letter here, not punctuation |
| `kanaad` | Kanaad / *Scomberomorus commerson* | double vowel, no Arabic entered |
| `ameixa` | Ameixa babosa / *Venerupis corrugata* | Galician, unaccented input |
| `Epinephelus` | Hamour | scientific name search, Latin only |

`412` species live in the read-only pre-seeded drift asset database. The query is a local indexed
read: it renders in the same frame as the keystroke. If it does not, fix the index — do not add a
debounce, and never add a spinner.

## The keypad

A 3x4 grid of ruled keys. Mono figures, no letters, no ambiguity about the decimal separator.

```
 7   8   9
 4   5   6
 1   2   3
 .   0   ⌫
```

| Property | Value |
|---|---|
| Key min size | `LonjaTargets.key` 64, `LonjaTargets.gloveKey` 76 |
| Key gap | `1` `rule` `#C2C5BB` shared grid line; the outer frame is `1.5` `ink` |
| Figure style | mono, `FontFeature.tabularFigures()`, 26 |
| Decimal key | renders the **locale's** separator glyph, writes a canonical `.` |
| Backspace | engraved arrow, never the word `DEL`, never a destructive colour |
| Readout | mono 44, `ink`, above the grid, with a fixed unit slot beside it |
| Max entry | 3 integer digits + 1 decimal; further keys are inert, not error states |

Locale numeral shaping — whether the key shows `7` or `٧` — is owned by `i18n-rtl-l10n`. The keypad
reads the shaped glyph and always writes an ASCII canonical value.

## Keypad before calibration: the contract

| Device state | Ruler available | Keypad available | Screen shows |
|---|---|---|---|
| Fresh install, never calibrated | no | **yes** | keypad + a quiet line offering calibration |
| Calibrated `2026-07-02` | yes | **yes** | keypad + `Measure with the on-screen ruler` |
| Calibration stale or invalid | no | **yes** | keypad + `ochre` note that the ruler needs re-calibration |
| Screen size changed since calibration | no | **yes** | keypad + re-calibration offer |

There is no cell in which the keypad is unavailable. A `CalibrateFirstScreen` that stands between
the fisher and a number is the single worst failure this skill exists to prevent: the fish is alive,
the tide is going, and the app has asked for a bank card.

The calibration state model, the ruler itself and the unit conversion are owned by
`catchlaw-measurement-ruler`. This skill owns only the guarantee that the keypad is never gated on
any of it.

## Unit and method copy

Three things must be simultaneously visible whenever a length is being entered:

1. The **figure**, editable, mono, tabular.
2. The **unit**, fixed, serif, in its own non-editable slot — `cm` for Gulf finfish, `mm` for
   Galician bivalves.
3. The **method**, stated, serif caption — `Total length (TL)`, `Fork length (FL)`,
   `Shell length`.

Worked strings, verbatim from the rule data:

- `45` · `cm` · `Total length (TL)` — Hamour, *Epinephelus coioides*
- `65` · `cm` · `Fork length (FL)` — Kanaad, *Scomberomorus commerson*
- `38` · `mm` · `Shell length` — Ameixa babosa, *Venerupis corrugata*

A control never phrases any of this as an instruction. It states the measurement; the verdict
sentence and its statement-of-fact grammar are owned by `catchlaw-verdict-contract`.

## Edge cases

- **Empty search, keyboard open.** The recents strip stays visible above the keyboard; six species
  tabs are faster than typing with wet hands. Never `autofocus`.
- **No result.** The field keeps its text and states `No species matches هامور in this zone` — a
  fact, not `Try again`.
- **Text scaled to 200%.** The field grows; it never clamps, never `FittedBox`es, never ellipsises
  the value. Owned by `accessibility-as-code`; this skill only forbids the workarounds.
- **Paste of a long string.** Accepted verbatim, single line, horizontally scrollable. No truncation
  in the controller.
- **Glove mode toggled while focused.** Height animates to `Duration.zero` under reduced motion;
  focus and caret offset are preserved.
