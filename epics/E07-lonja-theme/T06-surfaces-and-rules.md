# E07/T06 — Surfaces, rules and plates: separation without a z-axis

| | |
|---|---|
| **Epic** | E07 — Lonja design system foundation |
| **Branch** | `epic/07-lonja-theme` (shared) |
| **Commit** | `feat(theme): add the ruled Lonja surfaces and remove every elevation from the three themes` |
| **Depends on** | T03 (the palettes and `_build` must exist), and reads T04's density for its insets |
| **Size** | M |
| **Spec** | `SPEC.md` §4.9 (sunlight mode: monochrome plus result colour — the theme in which a stock change does not exist), §13 (contrast: an ornament hairline may not be the only boundary of a control), §11 "Both" |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-dialogs-and-surfaces` | Owns panel, plate and sheet anatomy: the ruled inset, the fills per theme, the 2 px plate top rule, and rule 6 — Lonja surfaces are ruled and inset, never elevated cards |
| `lonja-design-tokens` | Owns the four rule weights, the radius ceiling of 2, the `surfaceSunk` slot and rule 6: hairlines are ornament, and anything that identifies a control takes `ruleBearing` |
| `widget-composition` | `LonjaRule`, `LonjaPanel` and `LonjaPlate` are `Widget` classes, never `Widget _buildPanel()` helpers. This skill owns the extraction rule; `FLUTTER_GUIDE.md` §8.1 supplies the measured reason |
| `flutter-performance` | `const` constructors and the identity short-circuit these surfaces are designed to hit |
| `accessibility-as-code` | The 3:1 non-text contrast floor a control frame must clear, which is why an ornament hairline at 1.37:1 may not be one |
| `catchlaw-conventions-index` | Rule 10 — the general rules above are cited, not restated, in this repo |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `.claude/skills/lonja-dialogs-and-surfaces/references/surfaces-and-plates.md` | §1 "The governing idea", §2 "Rule weights" | Printed matter, not glass: `elevation: 0`, `surfaceTintColor: Colors.transparent`, `BorderRadius.zero`, no `Card`, no gradient — and rules drawn as `BorderSide`, never as a `Divider` widget |
| `.claude/skills/lonja-dialogs-and-surfaces/references/surfaces-and-plates.md` | §3 "Fills, per theme", §5 "Plate anatomy", §6–§8 | The surface-side contract the tokens must satisfy, the plate's 2 px top rule and inset, sheet and snackbar geometry, and the glove-mode inset row |
| `.claude/skills/lonja-dialogs-and-surfaces/SKILL.md` | Rules 6, 10 | The ruled inset, and squared sheets with no drag handle |
| `.claude/skills/lonja-design-tokens/references/token-tables.md` | "Rule weights, radii, motion" | `hair` 0.5, `rule` 1.0, `strong` 2.0, `stamp` 3.0 — and that `stamp` is the verdict frame and nothing else |
| `.claude/skills/lonja-design-tokens/references/three-themes-and-modes.md` | "Why sunlight is a palette, not an inversion", closing paragraph | "A widget that relied on `surfaceSunk` to mark a block must also carry a rule, because in sunlight the stock change does not exist." This task's central test |
| `.claude/skills/lonja-design-tokens/SKILL.md` | Rules 4, 5, 6 | No shadows, no gradients, no elevation, radius ceiling 2; four weights; hairline is ornament and `ruleBearing` identifies |
| `.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh` | Check 5 | Scans `*_dialog.dart`, `*_sheet.dart`, `*_panel.dart`, `*_plate.dart`, `*_snackbar.dart` for `BoxShadow`, `elevation: [1-9]`, any `BorderRadius.*`, `showDragHandle: true` and bare `Card(`. The file names below are chosen so this check actually covers them |
| `FLUTTER_GUIDE.md` | §8.1 | The measured reason these are widget classes: a helper method has no `BuildContext` of its own, so `Theme.of(context)` inside it registers the **parent** element and rebuilds the whole screen |
| `FLUTTER_GUIDE.md` | §8.2 | `const` and the identity short-circuit |
| `epics/DECISIONS.md` | D-2, D-8 | The theme's home; and the directional-geometry gate these widgets' insets must satisfy |

## What this delivers

- `app/lib/theme/lonja_theme.dart` — `_build` gains the component themes, identical in shape across
  all three palettes:
  - `dividerTheme`: `hairline`, `LonjaRules.rule`, `space: LonjaSpace.s4`.
  - `cardTheme`: `elevation: 0`, `margin: EdgeInsets.zero`, `surfaceSunk`, square shape.
  - `dialogTheme`, `bottomSheetTheme`, `snackBarTheme`: `elevation: 0`, transparent
    `surfaceTintColor`, square shapes, `SnackBarBehavior.fixed`.
  - `splashFactory: NoSplash.splashFactory`, app-wide. Paper does not ripple.
- `app/lib/ui/core/ui/lonja_rule.dart` — `LonjaRule`, four named constructors mapping the four
  documented uses: `.row()` (`hairline` at `hair`), `.block()` (`hairline` at `rule`), `.section()`
  (`hairlineStrong` at `strong`) and `.bearing()` (`ruleBearing` at `rule`).
- `app/lib/ui/core/ui/lonja_panel.dart` — `LonjaPanel`: `surfaceSunk` fill, a `hairline` border at
  `LonjaRules.rule`, square corners, and `density.gutter` of inset.
- `app/lib/ui/core/ui/lonja_plate.dart` — `LonjaPlateSurface`: the pasted slip. A full-bleed
  `hairlineStrong` top rule at `LonjaRules.strong`, `surfaceSunk` fill, `density.gutter` inset,
  square. It carries a child; the engraved artwork inside it belongs to `lonja-icons-and-plates` and
  to the epic that first draws one.
- `app/testing/theme/pump_lonja.dart` — `pumpLonja(tester, child, {skin, gloved, locale})`, the
  harness T07 and T08 also use, so there is one place that decides how a Lonja widget is mounted.
- `app/test/ui/core/lonja_rule_test.dart`, `lonja_panel_test.dart`, `lonja_plate_test.dart`,
  `app/test/theme/lonja_surface_theme_test.dart`.

## Why it is built this way

**A printed page separates things three ways: a rule, a change of stock, or space.** Lonja has the
same three and no fourth. The moment a surface gains elevation, tint or a radius it stops reading as
a document and starts reading as an app overlay — and the app's whole authority claim is a document
claim. One elevated card reframes the screen, so the ban is absolute and applies **inside**
`lib/theme/` too: check 3 of `check_lonja_tokens.sh` is the only check in that script with no
`/theme/` exemption for shadows, gradients and non-zero elevation.

**In sunlight there is no second stock, so a panel must also carry a rule.** `surfaceSunk` equals
`surface` there — white paper has no recessed stock — so any block marked *only* by a change of fill
becomes invisible at exactly the moment the user is standing in 100,000 lux. `LonjaPanel` therefore
draws its border unconditionally rather than "when the fill is too close to the ground", and test 3
is the assertion that keeps it that way. This is the single most transferable consequence of T03's
palette work, and it is why this task exists as a task rather than as four lines inside T03.

**Hairlines are ornament; anything that identifies takes `ruleBearing`.** `hairline` measures 1.37:1
on paper — invisible on a wet screen at arm's length — which is fine for separating two rows of a
table and unacceptable as the frame of a tappable control. `ruleBearing` measures 7.29:1 and clears
the 3:1 non-text floor with room. Encoding this as four named constructors rather than as two free
parameters means a call site cannot combine them wrongly: there is no `LonjaRule(tone: hairline,
weight: stamp)` to write.

**No `Divider` widget.** Material's `Divider` introduces 16 dp of *physical*, non-directional padding
and its own thickness defaults; both are wrong here, and the physical padding is what D-8's
`no_directional_geometry.sh` gate exists to catch elsewhere. A rule is a `BorderSide` on a `Border`,
drawn by a `DecoratedBox`. The `dividerTheme` is still configured, because Material widgets
underneath us draw their own dividers and must not draw them at 1.5 px in Material grey.

**Widget classes, never `Widget _buildPanel()`.** `FLUTTER_GUIDE.md` §8.1's mechanism 2 is
unconditional and decisive here: a helper method has no `BuildContext` of its own, so a
`LonjaTokens.of(context)` inside it registers the **caller's** element as the dependent and the
entire screen rebuilds when the theme or the locale changes. Measured in the guide: `host=2` with a
helper, `host=1` with a widget class. With three themes, a density toggle, six locales and an RTL
flip, that is not academic — and test 15 measures it here rather than trusting the citation.

**The plate inset is `density.gutter` (16 / 24), not the reference's 16 / 20.**
`surfaces-and-plates.md` §8 gives a glove plate inset of 20 dp. Twenty is not a step on the 4 pt
spine — `s4` is 16 and `s5` is 24, and `lonja-design-tokens` rule 7 says there is nothing between the
steps, because an off-spine value is exactly what glove mode cannot scale. Using `density.gutter`
gives one source for the number and keeps it scalable. The divergence is 4 dp of padding in one
mode; the alternative is a literal that fails check 5 of the token gate outside `lib/theme/`.

**Rejected: `Card`.** It smuggles a shadow and a 12 dp radius past review because neither appears in
the diff. **Rejected: `Material(elevation: 1)` "for a subtle lift".** There is no lift; the sheet is
the page. **Rejected: making the panel's border conditional on the theme** — `if (skin == sunlight)
border else null` is a fourth code path that only one golden lane covers, and it re-introduces the
question the unconditional rule answers.

## Tests first

Write every row before touching `lonja_panel.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `LonjaPanel fills with the surfaceSunk slot` | paper | `paper87` | The recessed stock is one of the three legal separations; the other two are a rule and whitespace |
| 2 | `LonjaPanel draws a hairline border at LonjaRules.rule` | paper | colour `paper79`, width `1.0` | The border is the second signal, and its weight is one of exactly four |
| 3 | `sunlight - LonjaPanel keeps a visible boundary when surfaceSunk equals surface` | sunlight | fill `white100`, border `black00` at 21.00:1 | The block would otherwise vanish in the theme built for glare. This is the transferable consequence of sunlight having no second stock |
| 4 | `LonjaPanel insets its child by the density gutter` | standard | `EdgeInsets.all(16)` | The inset comes from the density set, so glove mode can scale it; a literal cannot be scaled |
| 5 | `glove - LonjaPanel insets its child by 24 dp` | glove | `EdgeInsets.all(24)` | The glove gutter, and the reason 20 dp was not used: it is off the spine |
| 6 | loop × 3 — `LonjaPanel casts no shadow in the <theme> theme` | each theme | `BoxDecoration.boxShadow` null or empty | Paper does not float, asserted at the widget rather than only greped by the gate |
| 7 | `LonjaPanel draws square corners` | any | `borderRadius` null or `BorderRadius.zero` | The booklet it quotes has square corners; the ceiling of 2 exists for chips and the ruler thumb only |
| 8 | loop × 4 — `LonjaRule.<name> draws <weight> dp in the <slot> tone` | each constructor | weight and colour | Four documented uses, four constructors, no free combination |
| 9 | `LonjaRule.bearing draws in the ruleBearing slot rather than the hairline` | paper | `ink30`, not `paper79` | 1.37:1 is invisible on a wet screen; a control frame must clear 3:1, and this is the constructor a control reaches for |
| 10 | `LonjaPlateSurface draws a full-bleed top rule at LonjaRules.strong` | paper | `paper70` at `2.0`, full width | The plate is a slip pasted onto the page; the top rule is what says so |
| 11 | `LonjaPlateSurface uses no radius and no shadow` | any theme | square, no shadow | Check 5 of `check_lonja_dialogs.sh` scans `*_plate.dart`; the test fails first and in a friendlier place |
| 12 | loop × 3 — `LonjaTheme.<theme>() reports zero elevation on card, dialog, sheet and snackbar themes` | each builder | all `0` | The cheapest way a shadow ships is a Material default nobody overrode |
| 13 | loop × 3 — `LonjaTheme.<theme>() squares the card, dialog and sheet shapes` | each builder | `BorderRadius.zero` | "No `circular(4)`, no just-the-top-corners" |
| 14 | loop × 3 — `LonjaTheme.<theme>() sets a transparent surfaceTintColor on dialogs and sheets` | each builder | alpha `0` | Material 3 tints a surface by elevation; a tint is a shadow expressed as a colour |
| 15 | `LonjaPanel rebuilds without rebuilding its host when the theme changes` | host + panel, theme swapped | host builds `1`, panel builds `2` | `FLUTTER_GUIDE.md` §8.1 mechanism 2, measured here instead of cited. A helper method makes this `2`/`2` and re-runs the whole screen |
| 16 | `LonjaTheme.paper() disables the ink splash` | — | `NoSplash.splashFactory` | A ripple is motion on paper; it also survives every no-shadow grep, because it is not a shadow |
| 17 | `LonjaTheme.paper() sets the divider thickness to LonjaRules.rule and the hairline colour` | — | `1.0`, `paper79` | Material widgets under us draw their own dividers; unthemed they arrive in Material grey at a weight that is not one of the four |

```dart
// app/test/ui/core/lonja_panel_test.dart
import 'package:catchlaw/theme/lonja_primitives.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/core/ui/lonja_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

BoxDecoration _decorationOf(WidgetTester tester) =>
    tester.widget<DecoratedBox>(find.descendant(
      of: find.byType(LonjaPanel),
      matching: find.byType(DecoratedBox),
    )).decoration as BoxDecoration;

void main() {
  testWidgets('LonjaPanel fills with the surfaceSunk slot', (WidgetTester tester) async {
    await pumpLonja(tester, const LonjaPanel(child: Text('Art. 3')));
    expect(_decorationOf(tester).color, LonjaPrimitives.paper87);
  });

  testWidgets('sunlight - LonjaPanel keeps a visible boundary when surfaceSunk equals surface',
      (WidgetTester tester) async {
    await pumpLonja(tester, const LonjaPanel(child: Text('Art. 3')),
        skin: LonjaSkin.sunlight);
    final BoxDecoration decoration = _decorationOf(tester);
    expect(decoration.color, LonjaPrimitives.white100);
    expect((decoration.border! as Border).top.color, LonjaPrimitives.black00);
  });

  // … one test per row above, one behaviour each
}
```

```dart
// app/test/ui/core/lonja_panel_rebuild_test.dart
// FLUTTER_GUIDE.md §8.1 mechanism 2, measured rather than cited. `const _Host()` is
// canonicalised, so Element.updateChild's identity short-circuit skips it on the second
// pump; the panel below still rebuilds, because it registered a Theme dependency of its
// own. A `Widget _buildPanel(context)` helper inside _Host would register that dependency
// on _Host's element instead, and hostBuilds would be 2.
int hostBuilds = 0;
int probeBuilds = 0;

class _Host extends StatelessWidget {
  const _Host();
  @override
  Widget build(BuildContext context) {
    hostBuilds++; // reads no inherited value
    return const LonjaPanel(child: _Probe());
  }
}

class _Probe extends StatelessWidget {
  const _Probe();
  @override
  Widget build(BuildContext context) {
    probeBuilds++;
    return Text('Art. 3', style: TextStyle(color: LonjaTokens.of(context).onSurface));
  }
}

void main() {
  testWidgets('LonjaPanel rebuilds without rebuilding its host when the theme changes',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(theme: LonjaTheme.paper(), home: const _Host()));
    await tester.pumpWidget(MaterialApp(theme: LonjaTheme.night(), home: const _Host()));
    expect(hostBuilds, 1);
    expect(probeBuilds, 2);
  });
}
```

**Run:** `cd app && flutter test test/ui/core/ test/theme/lonja_surface_theme_test.dart` → 17 named
rows, of which five are loops (3, 4 and three of 3), so 29 failures. If any passes before the
widgets exist, the test is wrong.

## Implementation outline

1. `app/testing/theme/pump_lonja.dart` first — `pumpLonja(WidgetTester, Widget, {LonjaSkin skin =
   LonjaSkin.paper, bool gloved = false, Locale locale = const Locale('en')})` wrapping the child in
   a `MaterialApp` built by `resolveLonjaTheme`, with E06's localisation delegates. One harness, so
   T07's and T08's tests mount widgets identically.
2. `LonjaRule` — a `StatelessWidget` with four `const` named constructors, each fixing a tone and a
   weight; `build` returns a `SizedBox(height: weight)` wrapped in a `ColoredBox`, reading its
   colour from `LonjaTokens.of(context)`. No `Divider`.
3. `LonjaPanel` — `const` constructor, `DecoratedBox` with `color: t.surfaceSunk` and
   `border: Border.all(color: t.hairline, width: LonjaRules.rule)`, no `borderRadius`, a `Padding`
   of `EdgeInsets.all(t.density.gutter)`, then the child. The border is unconditional.
4. `LonjaPlateSurface` — a `Column` of a full-bleed `LonjaRule.section()` and the padded child inside
   a `DecoratedBox` filled with `surfaceSunk`. The top rule is drawn by the body, not by a shape.
5. `_build` in `lonja_theme.dart` gains the five component themes and `splashFactory`. Each is
   written once and takes its colours from the palette parameter, so all three themes stay identical
   in shape and differ only in slot values.
6. Re-run the whole suite: T03's theme tests assert the palette, these assert the chrome, and neither
   should need to change for the other.
7. `check_lonja_dialogs.sh app/lib` — the new `*_panel.dart` and `*_plate.dart` names bring these
   files under its check 5 for the first time.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 named tests pass, including the five loops, and each failed first.
- [ ] `LonjaPanel` draws its border unconditionally, and the sunlight test proves the boundary
      survives `surfaceSunk == surface`.
- [ ] Every rule weight in `app/lib/ui/` is a `LonjaRules` constant; no literal width exists.
- [ ] `grep -rnE "BoxShadow|LinearGradient|RadialGradient|elevation: *[1-9]|\bCard\(" app/lib`
      returns nothing.
- [ ] `grep -rn "Divider(" app/lib/ui` returns nothing — rules are `BorderSide`s.
- [ ] No `borderRadius` anywhere in `app/lib/ui/core/ui/`; the two radius tokens are unused so far
      and that is correct.
- [ ] Every new widget is a `Widget` class with a `const` constructor; `grep -rn "Widget _build" app/lib/ui/core`
      returns nothing.
- [ ] `check_lonja_dialogs.sh app/lib` and `check_lonja_tokens.sh app/lib` both clean.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh app/lib
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
feat(theme): add the ruled Lonja surfaces and remove every elevation from the three themes

A printed page separates things with a rule, a change of stock, or space, and
Lonja has the same three moves and no fourth. Every component theme now sets
elevation 0, a transparent surfaceTintColor, a square shape and NoSplash —
because one elevated card reframes a legal document as a dismissible overlay,
and the app's whole authority claim is a document claim.

LonjaPanel draws its hairline border unconditionally. In sunlight surfaceSunk
equals surface — white paper has no recessed stock — so a block marked only by
a fill change disappears at exactly the moment the user is standing in
100,000 lux. Making the border conditional would add a fourth code path that
one golden lane covers.

LonjaRule ships four named constructors instead of two free parameters, so a
call site cannot frame a control in an ornament hairline: hairline measures
1.37:1 on paper and is fine between two table rows, while a control frame has
to clear 3:1, which is what ruleBearing's 7.29:1 is for.

No Divider widget anywhere: Material's introduces 16dp of physical,
non-directional padding. The plate inset is density.gutter, 16 or 24, rather
than surfaces-and-plates' 16/20 — 20 is not a step on the 4pt spine, and an
off-spine value is precisely what glove mode cannot scale.

These are widget classes, not _buildPanel() helpers: a helper has no
BuildContext of its own, so LonjaTokens.of(context) inside one registers the
caller's element and rebuilds the entire screen on a theme change. The test
measures that instead of citing it.

Task: E07/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
