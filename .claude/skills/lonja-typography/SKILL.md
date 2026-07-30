---
name: lonja-typography
description: >-
  Enforces the Lonja type ramp and its four mandatory roles across CATCHLAW — serif for legal
  text, species accounts and the verdict stamp, sans for chrome and labels, mono with
  FontFeature.tabularFigures for every measurement, code, article number and citation, the Arabic
  Naskh stack at a 1.12 optical uplift, named steps verdict, display, legal, ui, eyebrow,
  datum, citation and articleNumber resolved only through LonjaType.of(context), tracking
  authored in logical pixels rather than em, a 65-character
  reading measure on legal prose that scales with textScaler, and a ramp that never clamps and
  never ships a runtime webfont. Use when adding a TextStyle, editing
  lib/theme/lonja_typography.dart, styling the verdict stamp or a species account, setting 38 cm
  or Ministerial Decision 580/2015 Art. 3, choosing between serif, sans and mono, wiring Arabic
  or RTL text, sizing headings, eyebrows and captions, or reviewing any text surface in a diff.
---

# Lonja Typography

Type is the argument. CATCHLAW is a printed regulations booklet that happens to run on a phone,
so the letterforms have to carry the authority the app is claiming: **a serif for anything that
quotes the law, a mono with tabular figures for anything that can be compared, and sans only for
chrome that is not part of the document.** This skill owns the ramp values, the four roles, their
line-heights, tracking, reading measure and Arabic optical size. It does not own ThemeExtension
plumbing, font bundling, colour values, or the never-clamp accessibility floor.

Read the reference for the task at hand:
- `references/type-ramp.md` — every step, size, weight, height, tracking, role, worked example.
- `references/arabic-and-scripts.md` — Naskh stack, optical uplift, zero tracking, numeral faces,
  bidi-safe line-height, mixed-script rows.

Run `scripts/check_lonja_type.sh` before a PR.

ThemeExtension mechanics, `of(context)` asserts, `lerp`/`copyWith` and font bundling live in
`design-system-structure`; colour and spacing values live in `lonja-design-tokens`; this skill
governs the type VALUES and which role is mandatory where.

## Non-negotiable rules

1. **EVERY TextStyle in the app comes from LonjaType.of(context).** The ramp is a
   `ThemeExtension` declared once in `lib/theme/lonja_typography.dart`; call sites name a step
   (`t.legal`, `t.datum`) and never a metric. A raw `TextStyle(fontSize: 15)` in a feature widget
   is invisible to the night and sunlight themes and to glove mode, so it silently keeps paper-
   theme metrics on a screen the fisher is reading in the dark.

2. **Anything that quotes the law is set in the SERIF.** The verdict stamp, the article text, the
   species account, the citation prose and the non-dismissable disclaimer use `t.verdict`,
   `t.legal` and `t.legalSmall` — never `t.ui`. A finding of law rendered in the UI sans reads as
   an app notification, and the whole liability posture of the product depends on it not doing
   that.

3. **EVERY comparable numeral is mono with tabularFigures.** Measurements, shell lengths, article
   numbers, decision numbers and both dates carry
   `fontFeatures: const [FontFeature.tabularFigures()]` from the ramp. With proportional digits
   `38 cm` and `188 cm` will not align in a species table, and the live ruler readout twitches
   sideways on every frame while Khalid is holding the fish against it.

4. **NEVER pass fontSize, fontFamily, height or fontWeight to copyWith at a call site.** The ONLY
   legal `copyWith` at a call site is `color` (and it should come from the theme too). If a size
   is missing, add a named step to the ramp and to `references/type-ramp.md`. One-off sizes are
   how a 16-step ramp becomes 40 sizes that no reviewer can hold in their head.

5. **Tracking is authored in logical pixels, NEVER em.** Flutter's `letterSpacing` is absolute
   logical px, so the mockup's `0.14em` on a 10.5px eyebrow is `letterSpacing: 1.47`, not `0.14`.
   Copying the CSS number verbatim ships an eyebrow with one hundredth of its intended tracking,
   which looks like a plain bold label rather than a gazette rubric.

6. **letterSpacing does NOT scale with textScaler; height does.** `height` is a multiple of
   `fontSize` so it survives every text size; `letterSpacing` is fixed, so at textScaler 2.0 a
   tracked eyebrow reads relatively tight. Accept it — do not multiply tracking by the scaler by
   hand, because that decouples the ramp from the platform and breaks golden tests.

7. **Legal prose is capped at 65 characters and the cap SCALES.** Use
   `maxWidth: LonjaMeasure.legal * MediaQuery.textScalerOf(context).scale(1)`, not a constant box.
   A fixed 500px box holds ~65 characters at scale 1.0 and ~32 at scale 2.0, turning a two-
   sentence article into a ladder the user will not finish reading in ten seconds.

8. **NEVER truncate legal text.** No `maxLines`, no `TextOverflow.ellipsis`, no `FittedBox` on
   `t.legal`, `t.legalSmall`, `t.verdict` or `t.citation` — they wrap and the page scrolls.
   Truncating a citation removes the article number that makes the verdict defensible; the
   never-clamp textScaler floor itself belongs to `accessibility-as-code`.

9. **Arabic letterSpacing is ALWAYS exactly zero.** Positive tracking severs the cursive joins, so
   هامور renders as ه ا م و ر — five orphaned glyphs that a native reader must decode letter by
   letter. The ramp zeroes tracking for `ar` and substitutes weight, colour and a hairline rule
   wherever Latin used a tracked eyebrow.

10. **NEVER uppercase a content string in a widget.** `.toUpperCase()` is a Latin-only,
    locale-hazardous transform (Turkish dotted i, no-op on Arabic) and it shouts species names.
    Eyebrow labels ship already-cased from the ARB; `Sha'ri`, `Epinephelus coioides` and
    `Ras Al Khaimah` are content and stay as authored.

11. **Italic is ONLY the scientific binomial.** `t.binomial` is the single italic step in the app
    and it exists for `Epinephelus coioides`, `Lethrinus nebulosus` and `Venerupis corrugata`.
    Italic anywhere else — emphasis, captions, disclaimers — reads as editorial voice in a
    document whose whole claim is that it has none.

12. **NEVER FontFeature.smallCaps() and NEVER a runtime webfont.** The system stacks have no true
    small-cap masters, so the feature is a silent no-op or a synthetic squash; use the tracked
    `t.eyebrow` instead. `GoogleFonts` and any network font fetch are banned outright — the app
    is 100% offline and a font that fails to load is a blank verdict screen.

## Why a serif, and where it is mandatory

The subject is a printed instrument. A minimum-size rule for هامور exists as a numbered article in
a ministerial decision, and the app's authority comes from looking like the thing it quotes rather
than like a consumer utility. The serif is not decoration: it is the signal that the sentence on
screen is a statement of law, and the sans is the signal that a control is merely app chrome.
Keeping the two disjoint is what lets the verdict stamp be believed at 05:40.

```dart
final t = LonjaType.of(context);
final c = LonjaColors.of(context);

// WRONG — the finding set in the UI sans; it reads like a push notification, not the law.
Text('Below the minimum', style: t.ui);

// RIGHT — serif stamp, and glyph + word + colour so colour is never the only signal.
Row(children: [
  Icon(LonjaGlyphs.belowMinimum, size: 28, color: c.oxblood),
  const SizedBox(width: 10),
  Text('Below the minimum', style: t.verdict.copyWith(color: c.oxblood)),
]),

// RIGHT — the quoted rule stays serif; its locator and dates stay mono.
Text('38 cm, minimum 45 cm (total length)', style: t.legal),
Text('Ministerial Decision 580/2015, Art. 3', style: t.citation),
Text('published 2015-11-03 · checked 2026-07-14', style: t.citation),
```

Full worked file: `examples/lonja_text_theme.dart`.

## Tabular figures and the measurement column

Every digit the fisher might compare belongs to the mono role, and every mono step in the ramp
carries `FontFeature.tabularFigures()` without exception. Tabular figures are what let a species
table stack `38 cm`, `45 cm` and `188 cm` on a shared decimal spine, and what stops the big
`t.measure` readout from shivering as the ruler updates several times a second.

```dart
// WRONG — proportional digits and metrics hardcoded at the call site.
const Text('38 cm', style: TextStyle(fontFamily: 'monospace', fontSize: 34));

// RIGHT — declared ONCE in lib/theme/lonja_typography.dart.
final TextStyle measure = TextStyle(
  fontFamilyFallback: LonjaFaces.mono,        // ui-monospace, SF Mono, Menlo, Consolas, …
  fontSize: 34,
  height: 1.0,
  letterSpacing: -0.34,                        // -0.01em × 34px (rule 5)
  fontWeight: FontWeight.w600,
  fontFeatures: const [FontFeature.tabularFigures()],
);

// RIGHT — call sites name steps only.
Text('38 cm', style: t.measure);
Text('min 45 cm total length', style: t.datum);       // هامور Hamour
Text('min 65 cm fork length', style: t.datum);        // كنعد Kanaad
Text('38 mm shell length', style: t.datum);           // Ameixa babosa
```

Full worked file: `examples/lonja_text_theme.dart`.

## Eyebrows, article numbers and the gazette margin

Lonja's structure is legible because the page is labelled the way a gazette is: a tiny tracked
uppercase eyebrow above each block, and a mono article number set out in the margin. Eyebrows are
fixed UI labels that arrive from the ARB already cased; article numbers are content and are always
mono so they align down the margin rail regardless of how many digits they carry.

```dart
// WRONG — casing content in the widget: a no-op on Arabic, Turkish-i hazard on Latin,
// and it shouts a species name that should be set as written.
Text(species.vernacular.toUpperCase(), style: t.eyebrow);

// RIGHT — eyebrows are pre-cased label strings; tracking comes from the ramp.
Text(l10n.eyebrowVerdict, style: t.eyebrow),     // VERDICT      10.5px / +1.47
Text(l10n.eyebrowZone, style: t.eyebrow),        // ZONE
Text('Ras Al Khaimah', style: t.uiSmall),

// RIGHT — the margin rail: mono, tabular, right-aligned to the rule.
SizedBox(
  width: LonjaMeasure.marginRail,
  child: Text('Art. 3', style: t.articleNumber, textAlign: TextAlign.end),
),
```

Full worked file: `examples/lonja_text_theme.dart`.

## Reading measure and textScaler

A reading measure is a character count, not a pixel width, so the constraint has to move with the
type. `LonjaMeasure.legal` is 500 logical px — roughly 65 characters of the 16px serif — and it is
multiplied by the current scale factor at every use, which keeps the line length constant in
characters from scale 0.85 to scale 3.0 while the column simply grows past the viewport and
scrolls.

```dart
// WRONG — fixed box plus a line cap: at textScaler 2.0 this holds ~32 characters and
// maxLines silently deletes the second half of the article.
const SizedBox(
  width: 500,
  child: Text(articleText, maxLines: 4, overflow: TextOverflow.ellipsis),
);

// RIGHT — character-constant measure, no cap, page scrolls (rules 7 and 8).
final scale = MediaQuery.textScalerOf(context).scale(1);
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: LonjaMeasure.legal * scale),
  child: Text(articleText, style: t.legal, softWrap: true),
);

// RIGHT — glue units so '45 cm' never breaks across lines; NEVER hand-place '\n'.
Text('minimum 45 cm (total length)', style: t.legal);
```

Full worked file: `examples/lonja_text_theme.dart`.

## Arabic: face, optical size, zero tracking

Arabic at the Latin's nominal size reads a size smaller, because the meaningful strokes sit in a
shorter x-height band crowded with dots. The ramp therefore resolves the script itself: for `ar`
every step swaps to the Naskh stack, multiplies size by 1.12, raises legal line-height to 1.80 for
the ascender and descender traffic, and forces `letterSpacing` to 0.

```dart
// WRONG — Latin stack plus tracking: the face falls back and the positive letterSpacing
// severs the joins, so هامور comes out as ه ا م و ر.
Text('هامور', style: t.legal.copyWith(letterSpacing: 1.2));

// RIGHT — the ramp reads Localizations.localeOf(context) and returns the ar variant.
final t = LonjaType.of(context);
Text('هامور', style: t.legal),            // 17.9px Geeza Pro, height 1.80, tracking 0
Text('الحد الأدنى 45 سم', style: t.datum),

// RIGHT — Arabic-Indic digits (٤٥) have no tabular coverage in the mono stack, so pin the
// column instead of trusting figure widths. Numeral SYSTEM choice: see i18n-rtl-l10n.
SizedBox(
  width: LonjaMeasure.digitColumn,
  child: Text(formattedLength, style: t.datum, textAlign: TextAlign.end),
),
```

Full worked file: `examples/lonja_text_theme.dart`.

## Anti-patterns

- **`TextStyle(fontSize: 15)`** — a metric outside `lib/theme/`; invisible to night, sunlight and
  glove mode, so it keeps paper-theme sizing on every other theme.
- **`Theme.of(context).textTheme.bodyLarge`** — bypasses the ramp entirely and hands you Material's
  Roboto-shaped defaults instead of the Lonja serif.
- **`t.legal.copyWith(fontSize: 18)`** — a nameless sixth serif size that no reference documents
  and no golden test covers.
- **`letterSpacing: 0.14`** — the CSS em value copied verbatim; ships 1/10th of the intended
  eyebrow tracking and the rubric collapses into a bold label.
- **`GoogleFonts.ebGaramond()`** — a network fetch in a 100% offline app; on a boat it renders a
  blank verdict screen.
- **`FontFeature.smallCaps()`** — no small-cap master exists in the system stacks; silently a no-op
  or a synthetic squash that fails at 9.5px.
- **`species.vernacular.toUpperCase()`** — no-op on كنعد, mangles Turkish, and shouts a name that
  the species account is supposed to quote.
- **`Text(citation, maxLines: 1, overflow: TextOverflow.ellipsis)`** — truncates the article number
  that makes the verdict defensible.
- **`FittedBox(child: Text('38 cm'))`** — scales type off the ramp so two measurements on one screen
  disagree about what 34px means.
- **`TextStyle(fontFamily: 'monospace')` without `tabularFigures`** — the ruler readout jitters and
  species-table columns lose their decimal spine.
- **`Text('هامور', style: t.legal.copyWith(letterSpacing: 1.2))`** — breaks cursive joining; the
  word stops being a word.
- **`Text('Below the minimum —\n38 cm')`** — a hand-placed newline that becomes a mid-word break at
  textScaler 2.0 and in every RTL locale.

## Definition of done

- [ ] `scripts/check_lonja_type.sh` is clean over `lib/`.
- [ ] No `TextStyle(`, `fontSize:` or `fontFamily:` literal exists outside `lib/theme/` (rule 1).
- [ ] Verdict, article text, species account and disclaimer all resolve to a serif step (rule 2).
- [ ] Every mono step in the ramp declares `FontFeature.tabularFigures()` (rule 3).
- [ ] Every `letterSpacing` in the ramp is a logical-pixel value, cross-checked as em × size
      against `references/type-ramp.md` (rule 5).
- [ ] Legal prose is wrapped in a measure that multiplies by `textScalerOf(context).scale(1)`, and
      carries no `maxLines` or `overflow` (rules 7, 8).
- [ ] Every `ar` step has `letterSpacing: 0`, the 1.12 uplift and height 1.80 (rule 9).
- [ ] No `.toUpperCase()` in `lib/`; eyebrow strings are cased in the ARB (rule 10).
- [ ] `t.binomial` is the only italic style used, and only for scientific names (rule 11).
- [ ] Goldens exist for the verdict screen at textScaler 1.0 and 2.0, in `en` and `ar`.

## Related skills

- See `design-system-structure` for `ThemeExtension`, the `of(context)` assert, `lerp`/`copyWith`
  and font bundling — it owns the plumbing this ramp is delivered through.
- See `lonja-design-tokens` for the paper, ink, harbour, verdant, oxblood and ochre values these
  styles are coloured with, and for the three themes plus glove mode.
- See `accessibility-as-code` for the never-clamp textScaler floor, contrast ratios and the
  44px/56px target minimums.
- See `i18n-rtl-l10n` for numeral-system selection, the `intl` `NumberFormat` Arabic-Indic gotcha,
  ARB authoring and bidi isolates.
- See `lonja-verdict-and-status` for how the stamp, glyph and disclaimer compose on the result
  screen.
- See `lonja-lists-and-tables` for species-table column widths that the tabular figures align to.
- See `widget-composition` for extracting `const` widget classes instead of style helper methods.
- See `widget-golden-and-a11y-testing` for the RTL and textScaler golden lanes named above.

## References

- Flutter API — `TextStyle`: https://api.flutter.dev/flutter/painting/TextStyle-class.html
- Flutter API — `FontFeature.tabularFigures`: https://api.flutter.dev/flutter/dart-ui/FontFeature/FontFeature.tabularFigures.html
- Flutter API — `TextStyle.height`: https://api.flutter.dev/flutter/painting/TextStyle/height.html
- Flutter API — `TextScaler`: https://api.flutter.dev/flutter/painting/TextScaler-class.html
- Flutter API — `DefaultTextStyle`: https://api.flutter.dev/flutter/widgets/DefaultTextStyle-class.html
- Flutter docs — Typography and fonts: https://docs.flutter.dev/ui/design/text/typography
- Flutter docs — Using custom fonts: https://docs.flutter.dev/cookbook/design/fonts
