---
name: lonja-design-tokens
description: >-
  Governs every aesthetic VALUE in the Lonja design system for CatchLaw — the two-tier palette from
  L-star-named primitives paper90 E6E4DC, ink11 16201C, harbour30 1B4D5E, verdant36 2E5E3A,
  oxblood28 7A2320 and ochre47 8A6A16 up to role slots surface, onSurface, hairline, ruleBearing,
  accent and verdictPass, the 4pt spacing spine s1 through s8, the four rule weights 0.5, 1, 2 and
  3, a radius ceiling of 2, the no-shadow no-elevation policy, the three hand-authored themes paper,
  night and sunlight, the orthogonal glove density set, and the LonjaTokens snapshot a painter takes
  in its constructor. Use when adding a colour or gap, editing lib/theme/lonja_tokens.dart, choosing
  a rule weight or radius, authoring the sunlight palette, reaching for Colors. or Color(0x or
  BoxShadow or BorderRadius.circular, tuning glove-mode targets, checking a contrast pair, or
  reviewing any widget that paints a colour, rule, gap or radius in a diff.
---

# Lonja Design Tokens

A token is a **measured value with a name that cannot lie about it** — `ink11` is #16201C because its CIE L\* is 11.2, and arithmetic, not taste, says so. This skill owns every aesthetic VALUE in CatchLaw: the pigment box, the spacing spine, the rule weights, the radius ceiling, the motion durations, the density set, and the three hand-authored themes they compose into. It does not own how a `ThemeExtension` is declared, lerped or read, nor type ramps, component anatomy, or what a verdict colour *means*.

Read the reference for the task at hand:
- `references/token-tables.md` — the 25 primitives, the 13 semantic slots, spacing spine, rule weights, radii, durations, density set, and the measured contrast table for all three themes.
- `references/three-themes-and-modes.md` — paper, night and sunlight authoring, why sunlight is not an inversion, glove mode as orthogonal density, snapshot passing, and the golden lane matrix.

Run `scripts/check_lonja_tokens.sh` before a PR.

`ThemeExtension` mechanics — the `copyWith`/`lerp` contract, the asserting `of(context)` accessor, attaching an extension to every `ThemeData`, hand-authored `ColorScheme`, reduced motion, font bundling — live in `design-system-structure`; this skill governs the VALUES those mechanics carry. Type ramps live in `lonja-typography`; what a verdict colour *means* lives in `lonja-verdict-and-status`.

## Non-negotiable rules

1. **Every value in the app has exactly ONE home, under `lib/theme/`.** `lonja_primitives.dart` holds the pigment box, `lonja_tokens.dart` holds the `LonjaTokens` `ThemeExtension`, `lonja_theme.dart` holds the three builders. A raw `Color(0x…)`, `Colors.*`, `BoxShadow`, `BorderRadius.circular`, `fontSize:` or a numeric `EdgeInsets` anywhere else fails `scripts/check_lonja_tokens.sh`; the ONLY escape hatch is a trailing `// lonja-token-ok`. **WHY:** a value authored inside a widget is invisible to the three-theme sweep, so it ships a colour no theme defines and no golden covers.

2. **Primitives are named by measured CIE L\*, never by rank or appearance.** `paper90` = #E6E4DC (L\* 90.5), `ink11` = #16201C (11.2), `ink30` = #3D4A44 (30.2), `harbour30` = #1B4D5E, `verdant36` = #2E5E3A, `oxblood28` = #7A2320, `ochre47` = #8A6A16. Never `grey700`, never `darkGrey`, never `brandPrimary`. **WHY:** rank scales have no room to insert and appearance names invert catastrophically, while a measured number is falsifiable in one line of Dart.

3. **Widgets read semantic slots ONLY; a primitive read is a defect.** `LonjaTokens.of(context).surface`, never `LonjaPrimitives.paper90`. The thirteen slots are `surface`, `surfaceSunk`, `onSurface`, `onSurfaceMuted`, `onSurfaceFaint`, `hairline`, `hairlineStrong`, `ruleBearing`, `accent`, `onAccent`, `verdictPass`, `verdictFail` and `verdictWarn`. **WHY:** a primitive read hardcodes one theme — it stays bone-white in night and mid-grey in sunlight, which is precisely where Khalid has ten seconds and no shade.

4. **Lonja has NO shadows, NO gradients, NO elevation, and radius ceiling 2.** `BoxShadow`, `LinearGradient`, `RadialGradient`, `elevation:` above `0`, bare `Card()` and any radius past `LonjaRadii.hair` (2) are banned; `LonjaRadii.none` (0) is the default. Separation is carried by a rule, a `surfaceSunk` change, or spine whitespace. **WHY:** paper does not float — a drop shadow reframes a legal document as a dismissible card and the printed authority the app borrows evaporates.

5. **Four rule weights exist and there is no fifth.** `LonjaRules.hair` 0.5, `.rule` 1.0, `.strong` 2.0, `.stamp` 3.0. Every `BorderSide(width:)`, `Divider(thickness:)` and `Border.all(width:)` takes one of the four. **WHY:** an ad-hoc `1.5` renders as a printing defect at 3x and disappears entirely at 1x, so the document looks badly printed rather than authoritative.

6. **Hairlines are ORNAMENT; anything that identifies uses `ruleBearing`.** `hairline` (#C2C5BB, 1.37:1 on paper) and `hairlineStrong` (#A9AC9F, 1.81:1) separate rows and sections only. The frame of a control, the verdict stamp and the active-tab rule take `ruleBearing` (#3D4A44, 7.29:1). **WHY:** a 1.37:1 boundary is invisible on a wet screen at arm's length; the 3:1 non-text floor itself is owned by `accessibility-as-code`.

7. **Spacing is the 4pt spine: eight steps, nothing between them.** `LonjaSpace.s1` 4, `s2` 8, `s3` 12, `s4` 16, `s5` 24, `s6` 32, `s7` 48, `s8` 64. `EdgeInsets` and `SizedBox` take a step, never a literal; directional-only geometry is owned by `i18n-rtl-l10n`. **WHY:** off-spine padding cannot be scaled by glove mode, which multiplies named steps and has no idea what a `13` was supposed to mean.

8. **Three themes, hand-authored; sunlight is NOT an inversion.** `LonjaTheme.paper()`, `.night()`, `.sunlight()`. Sunlight deletes every grey: `onSurfaceMuted`, `onSurfaceFaint`, `hairline`, `hairlineStrong`, `ruleBearing` and `accent` ALL collapse to `black00`, `surfaceSunk` equals `surface` (`white100`), and exactly one colour survives — the verdict. **WHY:** an algorithmically derived third theme regenerates the mid-greys that vanish at 100,000 lux on a salt-hazed screen, which is the entire reason sunlight exists.

9. **`harbour` is chrome; `verdant`, `oxblood` and `ochre` are MEANING — and meaning is framed, never filled.** `accent` may never be bound to a semantic pigment, no semantic pigment may paint a link, focus ring or selection, and no surface is ever filled with one: a verdict is a `.stamp` frame over `surface` with the word and glyph in `onSurface`. **WHY:** `paper90` on `ochre47` measures 3.97:1, so a filled warning stamp is unreadable, and an accent-coloured button beside an oxblood verdict teaches the eye that colour is decoration.

10. **EVERY slot ships a measured contrast row in ALL three themes.** 4.5:1 for text, 3:1 for a bearing rule or glyph, recorded in `references/token-tables.md`. `onSurfaceFaint` measures 3.62:1 on paper, so it is legal only at 19sp and above and NEVER carries a fact: no measurement, no citation, no date. **WHY:** "Below the minimum — 38 cm" set in an unreadable grey is a fact the user cannot act on, and the AED 3,000 is his, not ours.

11. **Glove mode is a density token set, orthogonal to `ThemeMode`.** `LonjaDensity.standard` (tapMin 48, tapGap 4, rowHeight 56) versus `.glove` (tapMin 56, tapGap 8, rowHeight 72), carried on `LonjaTokens.density`. There is no `ThemeMode.gloveNight`. **WHY:** folding density into the theme enum turns three hand-authored palettes into six and three golden lanes into twelve, and the sixth palette is the one nobody ever checks.

12. **A painter takes a token SNAPSHOT in its constructor, never a `BuildContext`.** `LonjaTokens` is `@immutable` with value equality; `PlatePainter(tokens: LonjaTokens.of(context))` and `shouldRepaint` compares `old.tokens != tokens`. **WHY:** `Theme.of` inside `paint()` re-enters the element tree every frame and makes repaint unprovable. *(the painter/scene split is owned by `custom-canvas-and-gestures`)*

## The two tiers, concretely

Tier 1 is the pigment box: 25 primitives whose names carry their measured lightness. Tier 2 is `LonjaTokens`, thirteen role slots that a theme binds to primitives. Widgets touch tier 2 and nothing else.

```dart
// WRONG — a primitive read, and a hex that no theme knows about.
Container(
  color: LonjaPrimitives.paper90,                       // bone-white in night mode
  child: Text('Hamour', style: TextStyle(color: const Color(0xFF16201C))),
);

// RIGHT — role slots, resolved by whichever of the three themes is live.
final t = LonjaTokens.of(context);
Container(
  color: t.surface,
  padding: const EdgeInsets.all(LonjaSpace.s4),
  child: Text('هامور  Hamour', style: TextStyle(color: t.onSurface)),
);
// Bound in one place only, lib/theme/lonja_theme.dart:
//   paper    surface=paper90  #E6E4DC  onSurface=ink11   13.12:1
//   night    surface=ink07    #101714  onSurface=paper89 13.84:1
//   sunlight surface=white100 #FFFFFF  onSurface=black00 21.00:1
```

Full worked file: `examples/lonja_tokens.dart`.

## Rules and surfaces, never shadows

A printed page separates things with a rule, a change of stock, or space. Lonja has the same three moves and no fourth. `surfaceSunk` is the recessed stock (#DEDBD1 on paper); in sunlight it is identical to `surface`, because white paper has no second stock.

```dart
// WRONG — Material elevation, a blur, and a 2010s corner radius.
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: citation,
);

// RIGHT — a hairline-ruled block on sunk stock, square corners.
final t = LonjaTokens.of(context);
DecoratedBox(
  decoration: BoxDecoration(
    color: t.surfaceSunk,
    border: Border(top: BorderSide(color: t.hairline, width: LonjaRules.rule)),
  ),
  child: const Padding(
    padding: EdgeInsets.symmetric(horizontal: LonjaSpace.s4, vertical: LonjaSpace.s3),
    child: Text('Ministerial Decision 580/2015, Art. 3 · checked 2026-07-14'),
  ),
);
```

Full worked file: `examples/lonja_theme.dart`.

## The 4pt spine and glove density

Gaps come from `LonjaSpace`; touch geometry comes from `LonjaTokens.density`, which the theme carries and glove mode swaps wholesale. Density is a value set, not a theme and not a `MediaQuery` read.

```dart
// WRONG — literal gaps, and a target that is only big enough with dry hands.
Padding(
  padding: const EdgeInsets.all(13),
  child: SizedBox(height: 44, child: MeasureButton()),
);

// RIGHT — spine steps, and the live density set.
final t = LonjaTokens.of(context);
Padding(
  padding: const EdgeInsets.all(LonjaSpace.s4),
  child: Column(children: [
    SizedBox(height: t.density.tapMin, child: const MeasureButton()),  // 48 / 56
    SizedBox(height: t.density.tapGap),                                //  4 /  8
    SizedBox(height: t.density.tapMin, child: const ZoneButton()),
  ]),
);
```

Full worked file: `examples/lonja_tokens.dart`.

## Sunlight is a third palette, not an inversion

Sunlight is authored by hand from `white100` and `black00`. Every neutral slot collapses to black, `accent` loses `harbour` entirely, and the only chromatic values left are the three verdict pigments — darkened so each clears 7:1 on white. `LonjaTokens.copyWith` is narrowed to `density` for exactly this reason.

```dart
// WRONG — a derived third theme; the greys come straight back.
LonjaTokens sunlight(LonjaTokens paper) =>
    paper.copyWith(surface: white100, onSurface: black00);  // muted/faint/hairline still grey

// RIGHT — hand-authored, every grey deleted, one colour left.
const sunlight = LonjaTokens(
  surface: LonjaPrimitives.white100, surfaceSunk: LonjaPrimitives.white100,
  onSurface: LonjaPrimitives.black00, onSurfaceMuted: LonjaPrimitives.black00,
  onSurfaceFaint: LonjaPrimitives.black00, hairline: LonjaPrimitives.black00,
  hairlineStrong: LonjaPrimitives.black00, ruleBearing: LonjaPrimitives.black00,
  accent: LonjaPrimitives.black00, onAccent: LonjaPrimitives.white100,
  verdictPass: LonjaPrimitives.verdant36,   //  7.56:1 on white
  verdictFail: LonjaPrimitives.oxblood28,   // 10.05:1 on white
  verdictWarn: LonjaPrimitives.ochre38,     //  7.07:1 on white
  density: LonjaDensity.standard,
);
```

Full worked file: `examples/lonja_theme.dart`.

## Semantic colour is framed, never filled

The verdict is a stamp: a `.stamp`-weight frame in the verdict colour, the glyph and the word in `onSurface`. Colour is the third signal, never the only one — and the statement is a fact, never an instruction.

```dart
// WRONG — filled stamp (3.97:1 for warn), colour as the only signal, an instruction.
Container(color: t.verdictFail, child: const Text('Throw it back'));

// RIGHT — framed stamp; glyph + word + colour; a statement of fact.
final t = LonjaTokens.of(context);
DecoratedBox(
  decoration: BoxDecoration(
    color: t.surface,
    border: Border.all(color: t.verdictFail, width: LonjaRules.stamp),
  ),
  child: Padding(
    padding: const EdgeInsets.all(LonjaSpace.s4),
    child: Row(children: [
      Icon(LonjaGlyphs.belowMinimum, color: t.verdictFail),          // glyph
      const SizedBox(width: LonjaSpace.s2),
      Text('Below the minimum — 38 cm, minimum 45 cm (total length)',
          style: TextStyle(color: t.onSurface)),                     // word, 13.12:1
    ]),
  ),
);
```

Full worked file: `examples/lonja_theme.dart`.

## Painters take a snapshot

The engraved species plate is a `CustomPainter`. It receives a `LonjaTokens` value in its constructor and compares it in `shouldRepaint`; it never reaches for a `BuildContext`.

```dart
// WRONG — theme lookup inside paint(), and repaint that cannot be reasoned about.
class PlatePainter extends CustomPainter {
  const PlatePainter(this.context);
  final BuildContext context;
  @override
  void paint(Canvas c, Size s) {
    final t = LonjaTokens.of(context);              // element-tree walk, every frame
    c.drawLine(Offset.zero, Offset(s.width, 0), Paint()..color = t.hairline);
  }
  @override
  bool shouldRepaint(PlatePainter old) => true;     // cannot know, so always repaints
}

// RIGHT — an immutable snapshot, compared by value.
class PlatePainter extends CustomPainter {
  const PlatePainter({required this.tokens});
  final LonjaTokens tokens;
  @override
  void paint(Canvas c, Size s) => c.drawLine(Offset.zero, Offset(s.width, 0),
      Paint()..color = tokens.hairline..strokeWidth = LonjaRules.hair);
  @override
  bool shouldRepaint(PlatePainter old) => old.tokens != tokens;
}
// Built with: CustomPaint(painter: PlatePainter(tokens: LonjaTokens.of(context)))
```

Full worked file: `examples/lonja_tokens.dart`.

## Anti-patterns

- **`Color(0xFF1B4D5E)` in a widget** — a fourth, undeclared theme that no golden lane renders and no contrast row covers.
- **`Colors.grey.shade400`** — a Material grey with a warm bias that fights the green-grey cast of the whole paper palette.
- **`BoxShadow(blurRadius: 12)`** — turns the regulations booklet into a floating card and drops the document authority the entire direction is built on.
- **`Card()` with default elevation** — smuggles a shadow and a 12dp radius past review because neither appears in the diff.
- **`BorderRadius.circular(12)`** — the corner radius of a 2010s consumer app; the booklet it quotes has square corners.
- **`ColorScheme.fromSeed(seedColor: harbour30)`** — generates 30 tonal values nobody measured and silently overrides the hand-authored slots.
- **`LonjaPrimitives.verdant36` read inside a verdict widget** — locks the paper-theme green into night, where it measures 2.1:1 against `ink07`.
- **`sunlight = paper.copyWith(surface: white100)`** — leaves `onSurfaceMuted`, `onSurfaceFaint` and every hairline grey, which is the exact failure sunlight exists to prevent.
- **`EdgeInsets.all(13)`** — off-spine, so glove mode cannot scale it and the row lands 3dp short of the tap floor.
- **`Divider(thickness: 1.5)`** — a fifth rule weight that renders as a printing defect at 3x and vanishes at 1x.
- **`ThemeMode.gloveNight`** — folds an orthogonal density axis into the theme enum and doubles the palettes and golden lanes forever.
- **`Theme.of(context)` inside `paint()`** — an element-tree walk on the raster path, after which `shouldRepaint` can no longer be honest.

## Definition of done

- [ ] `scripts/check_lonja_tokens.sh` is clean over `lib/`.
- [ ] Every colour is a semantic slot on `LonjaTokens`; no `LonjaPrimitives.` or `Colors.` reference exists outside `lib/theme/` (rules 1, 3).
- [ ] Every new or changed primitive is named for its measured CIE L\* and has a row in `references/token-tables.md` (rule 2).
- [ ] `BoxShadow`, gradients and `elevation:` above `0` appear nowhere in `lib/`, and no radius exceeds 2 (rule 4).
- [ ] Every stroke width is one of `LonjaRules.hair`/`.rule`/`.strong`/`.stamp`, and every rule that identifies a control or frames a verdict uses `ruleBearing` (rules 5, 6).
- [ ] Every gap is a `LonjaSpace` step; no numeric literal appears in an `EdgeInsets` or `SizedBox` outside `lib/theme/` (rule 7).
- [ ] All three themes are hand-authored, and every changed slot has a measured contrast figure in all three at 4.5:1 for text and 3:1 for bearing rules and glyphs (rules 8, 10).
- [ ] No surface is filled with `verdictPass`/`verdictFail`/`verdictWarn`; every verdict is framed and carries a glyph and a word (rule 9).
- [ ] The glove lane renders every primary target at 56dp or more with 8dp separation, driven by `LonjaTokens.density` and not by a second theme (rule 11).
- [ ] Every `CustomPainter` takes `LonjaTokens` in its constructor and compares it in `shouldRepaint` (rule 12).

## Related skills

- See `design-system-structure` for the `ThemeExtension` machinery this skill fills with values — the `copyWith`/`lerp` contract, the asserting `of(context)` accessor, hand-authored `ColorScheme`, and the `resolveMotion` reduced-motion helper the duration tokens feed.
- See `lonja-typography` for the type ramp and the serif/sans/mono/arabic stacks with tabular figures, which consume these colour and spacing tokens but own every font value.
- See `lonja-verdict-and-status` for what `verdictPass`/`verdictFail`/`verdictWarn` mean, the statement-of-fact copy contract, and the glyph set the framed stamp pairs with the colour.
- See `lonja-icons-and-plates` for the engraved plate assets and icon sizing scale that read `hairline`, `ruleBearing` and the `LonjaSpace` steps.
- See `accessibility-as-code` for the never-colour-alone floor, the 3:1 non-text contrast rule and `textScaler` handling that these measured pairs are checked against.
- See `custom-canvas-and-gestures` for the painter/scene split and zero-allocation `paint()` that the token snapshot in rule 12 exists to serve.
- See `flutter-performance` for the `const` subtrees and `.select` scoping that make a const `LonjaTokens` snapshot cheap to pass down a screen.
- See `widget-golden-and-a11y-testing` for the golden harness that must run paper, night, sunlight and the glove lane as separate cases.
- See `catchlaw-conventions-index` for routing between the Lonja surface skills and the CatchLaw domain skills.

## References

- Flutter API — `ThemeExtension`: https://api.flutter.dev/flutter/material/ThemeExtension-class.html
- Flutter API — `Color`: https://api.flutter.dev/flutter/dart-ui/Color-class.html
- Flutter API — `BorderSide`: https://api.flutter.dev/flutter/painting/BorderSide-class.html
- Flutter API — `VisualDensity`: https://api.flutter.dev/flutter/material/VisualDensity-class.html
- Flutter docs — Share styles with themes: https://docs.flutter.dev/cookbook/design/themes
- Material 3 — Color roles: https://m3.material.io/styles/color/roles
- W3C WAI — Contrast (Minimum) 1.4.3: https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
- W3C WAI — Non-text Contrast 1.4.11: https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html
