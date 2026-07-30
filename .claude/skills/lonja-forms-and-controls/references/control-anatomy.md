# Control Anatomy — deep dive

The measured half of the skill: what each Lonja control is made of, how big it is, and how every
state is encoded once the greys are deleted. Answers "what exactly do I draw?".

## Control inventory

| Control | Lonja construct | Ground | Rule | Radius | Min height (std / glove) |
|---|---|---|---|---|---|
| Species search | `LonjaSearchField` | `paper-sunk` `#DEDBD1` | `1.5` `ink` `#16201C` all sides | `0` | 60 / 72 |
| Figure entry | `LonjaFigureField` | `paper-sunk` | `1.5` `ink` bottom only | `0` | 56 / 66 |
| Toggle | `LonjaSwitch` | `paper` `#E6E4DC` | `1.5` `ink` on the 20px square | `0` | 56 / 66 |
| Segmented picker | `LonjaSegmented` | `paper` | `1` `rule` `#C2C5BB` outer, shared internal divider | `0` | 56 / 66 |
| Stepper | `LonjaStepper` | `paper-sunk` | `1.5` `ink`, `rule-strong` `#A9AC9F` between cells | `0` | 56 / 66 |
| Numeric keypad key | `LonjaKeypad` cell | `paper` | `1` `rule` grid, `1.5` `ink` outer | `0` | 64 / 76 |
| Filter chip | `LonjaChip` | `paper-sunk` | `1` `rule` | `2` (the only radius) | 44 / 56 |

`LonjaChip` at radius `2` is the single exception in the system; it exists because a chip abuts a
scrolling strip where a hard corner clips visually. Nothing else may claim it.

## Targets and density

| Token | Value | Applies to |
|---|---|---|
| `LonjaTargets.control` | `56` | every primary interactive control, standard density |
| `LonjaTargets.gloveControl` | `66` | the same controls when the glove switch is on |
| `LonjaTargets.separation` | `8` | minimum gap between any two targets, both densities |
| `LonjaTargets.key` | `64` | a keypad key, standard density |
| `LonjaTargets.gloveKey` | `76` | a keypad key, glove density |
| `LonjaTargets.chip` | `44` | a chip in a horizontally scrolling strip only |

Glove mode is read from the token extension, never from `MediaQuery.sizeOf` and never from a
per-screen bool. It is orthogonal to the three themes: paper, night and sunlight each have a glove
and a standard density, giving six golden lanes per control.

## State matrix

Every row must be distinguishable in a greyscale screenshot. Colour is one signal among three,
never the only one.

| State | Rule weight | Ground | Text | Extra mark |
|---|---|---|---|---|
| Default | `1.5` `ink` | `paper-sunk` | `ink` serif 19 | — |
| Hint (empty) | `1.5` `ink` | `paper-sunk` | `ink-faint` `#6C7871` italic serif 17 | — |
| Focused | `2.5` `ink` | `paper-sunk` | `ink` serif 19 | blinking `1.5`px caret |
| Selected (cell) | `1.5` `ink` | `ink` `#16201C` | `paper` `#E6E4DC` sans 600 | leading 3px `ink` bar |
| Disabled | `1` `rule` `#C2C5BB` | `paper` | `ink-faint` | 45-degree hairline hatch |
| Error | `2.5` `ink` | `paper-sunk` | `ink` | `ochre` `#8A6A16` marginal glyph + word |

Notes:

- Error on an **input** uses `ochre`, never `oxblood`. `oxblood` `#7A2320` is reserved for a
  verdict; an input that borrows it makes a typo look like a legal failure.
- Disabled is the hatch first and the colour second. A disabled control that differs only by
  opacity is invisible on a wet screen.
- The focused rule thickens rather than glows. There is no `BoxShadow` anywhere in the control
  system; the Lonja document is flat.

## Sunlight re-encoding

The sunlight theme is a genuine third theme, not a contrast filter. Every grey is deleted; exactly
one colour survives, and it is the semantic verdict — which never appears on an input at all.

| Paper value | Sunlight value | Consequence |
|---|---|---|
| `paper` `#E6E4DC` | `sun-paper` `#FFFFFF` | control ground |
| `paper-sunk` `#DEDBD1` | `sun-paper` `#FFFFFF` | inset surfaces collapse into the ground |
| `ink` `#16201C` | `sun-ink` `#000000` | text and rules |
| `rule` `#C2C5BB` | `sun-ink` `#000000` at `1` | hairlines survive as thin black, not grey |
| `rule-strong` `#A9AC9F` | `sun-ink` `#000000` at `2` | structural rules thicken |
| `ink-faint` `#6C7871` hint | `sun-ink` italic serif | hints keep their italic, lose their grey |
| `harbour` `#1B4D5E` chrome | `sun-ink` | the accent is deleted, not darkened |

Because `paper-sunk` collapses, a sunlight search field is distinguished from the page **only** by
its rule. That is why the rule weight, not the fill, is the load-bearing part of the anatomy.

## Banned Material defaults

| Default | Why it breaks Lonja | Replacement |
|---|---|---|
| `InputDecoration(filled: true)` | `surfaceVariant` fights `paper` and hides the rule | `DecoratedBox` with `Border.all` |
| `OutlineInputBorder()` | 4dp radius, floating label cutout | `BorderRadius.zero` + persistent label above |
| `UnderlineInputBorder()` | animates thickness and tints on focus | fixed `1.5` to `2.5` step, no tint |
| `Switch` track and thumb | a moving knob on a printed page | `LonjaSwitch` 20px square + state word |
| `SegmentedButton` shape | `StadiumBorder` pill | `LonjaSegmented` ruled cells |
| `Slider` | no discrete legible value under a wet thumb | `LonjaStepper` or `LonjaKeypad` |
| Ripple / `InkWell` splash | a spreading circle is not a printed reaction | instant ink-fill on press |
| 48dp `kMinInteractiveDimension` | below the wet-glove floor | `LonjaTargets.control` = 56 |

## Semantics and motion boundaries

- The `Semantics` label and the toggled state of every control, the 44px absolute floor, and
  `textScaler` behaviour are owned by `accessibility-as-code`. This skill only raises the floor to
  56 and forbids clamping.
- Press feedback is an instant ink fill with `Duration.zero` under reduced motion; the reduced
  motion resolution helper itself is owned by `design-system-structure`.
- `EdgeInsetsDirectional` for the leading glyph, the trailing unit slot and the clear affordance,
  plus bidi isolation of a field holding both `هامور` and `Hamour`, are owned by `i18n-rtl-l10n`.
- The `ThemeExtension` that carries `LonjaTokens`, its `lerp`, its `copyWith` and its asserting
  `of(context)` are owned by `lonja-design-tokens`; this file only fixes the values.
