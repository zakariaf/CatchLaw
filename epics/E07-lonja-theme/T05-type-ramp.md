# E07/T05 — The type ramp: serif for the law, mono for every number

| | |
|---|---|
| **Epic** | E07 — Lonja design system foundation |
| **Branch** | `epic/07-lonja-theme` (shared) |
| **Commit** | `feat(theme): add the sixteen-step Lonja type ramp with its Arabic resolution` |
| **Depends on** | T03 (the ramp is attached to the three `ThemeData` builders and varies its weight floor by theme) |
| **Size** | L |
| **Spec** | `SPEC.md` §4.9 (font scaling: layouts survive 200% text scale), §9.3 and §9.4 (Arabic text and the RTL build), §13 (< 1.2 s cold start — no font is decoded on the launch path), §5.3 (the offline guarantee: no font is ever fetched) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-typography` | Owns every value in this task: the four faces, the sixteen steps, the mandatory roles, tracking in logical pixels, the Arabic resolution and the reading measures |
| `lonja-design-tokens` | The ramp carries no colour — a step's colour comes from a `LonjaTokens` slot at the call site. Rule 1's "one home" is why `fontSize:` is legal only under `lib/theme/` |
| `design-system-structure` | `ThemeExtension` mechanics again, and font bundling policy. Used, not restated |
| `i18n-rtl-l10n` | Owns numeral-system selection and bidi isolates; this task owns only the faces and the tabular figures. The seam is in the routing table: "Arabic-Indic digits in a measurement → `i18n-rtl-l10n`, not `lonja-typography`" |
| `accessibility-as-code` | Owns the never-clamp `textScaler` floor and 200% scaling. The ramp must survive it and must never cap it |
| `catchlaw-offline-guarantee` | Why `GoogleFonts` and any runtime font fetch are banned outright: a font that fails to load is a blank verdict screen on a boat |
| `testing-strategy` | Unit level for the 16 steps; widget level only for `of(context)`, which needs a `Localizations` scope |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `.claude/skills/lonja-typography/references/type-ramp.md` | "The four faces" | The four `fontFamilyFallback` stacks, verbatim and in order |
| `.claude/skills/lonja-typography/references/type-ramp.md` | "The ramp" | All sixteen rows: face, size, weight, height, tracking in em **and** in logical px, and where each step is mandatory |
| `.claude/skills/lonja-typography/references/type-ramp.md` | "Measures", "Per-theme response", "Common conversion errors" | `LonjaMeasure`'s five constants; sunlight one weight step up and never below w500; the five conversion errors, two of which are order-of-magnitude |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Arabic resolution rules", "Line-height headroom" | The four properties that change together for `ar`, and the six explicit line-heights |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Zero tracking is not a preference", "Italic", "Numerals" | Why tracking severs cursive joins; why `binomial` keeps the Latin serif italic under `ar`; why the `ar` `measure` readout is 1.10 and not the `+0.15` default |
| `.claude/skills/lonja-typography/SKILL.md` | Rules 1–12 | Especially 3 (tabular figures on every mono step), 5 (tracking in px, never em), 9 (Arabic tracking is always 0), 12 (no `smallCaps`, no runtime webfont) |
| `.claude/skills/lonja-typography/examples/lonja_text_theme.dart` | whole file | The worked shape. It declares **13** of the 16 steps and diverges from the reference on two Arabic line-heights — see "Why it is built this way" |
| `.claude/skills/lonja-typography/scripts/check_lonja_type.sh` | Checks 1, 2, 3, 4, 8 | Raw `TextStyle(` and font metrics outside `/theme/`; webfonts; Material `textTheme` roles; and check 8, which fails any file declaring a mono face without `FontFeature.tabularFigures` |
| `SPEC.md` | §9.1 | The six shipped locales and why each one is shipped |
| `epics/DECISIONS.md` | D-3 | The six locales are `ar en es gl ca pt_BR`. Catalan ships; Urdu does not; and the typography reference's locale list is wrong (it says `fr`) |

## What this delivers

- `app/lib/theme/lonja_faces.dart` — `abstract final class LonjaFaces` with the four
  `List<String>` stacks: `serif`, `sans`, `mono`, `arabic`. System stacks only; the app bundles and
  fetches no font.
- `app/lib/theme/lonja_typography.dart`:
  - `@immutable class LonjaTypeScale` — the sixteen named `TextStyle` steps, and the two factories
    `LonjaTypeScale.latin({FontWeight minWeight})` and `.arabic({FontWeight minWeight})`.
  - `class LonjaType extends ThemeExtension<LonjaType>` — carries **both** scales (`latin`,
    `arabic`), with `static LonjaTypeScale of(BuildContext)` selecting on
    `Localizations.localeOf(context).languageCode == 'ar'`, a `copyWith`, a snapping `lerp` and
    value equality.
  - `abstract final class LonjaMeasure` — `legal` 500, `legalNarrow` 380, `heading` 300,
    `marginRail` 56, `digitColumn` 92.
- `app/lib/theme/lonja_theme.dart` — `_build` attaches a `LonjaType` to every `ThemeData`;
  `sunlight()` passes `minWeight: FontWeight.w500`.
- `app/test/theme/lonja_type_ramp_test.dart`, `app/test/theme/lonja_type_arabic_test.dart`,
  `app/test/theme/lonja_type_resolution_test.dart`.

## Why it is built this way

**Type is the argument.** A minimum-size rule for هامور exists as a numbered article in a ministerial
decision, and this app's authority comes from looking like the instrument it quotes rather than like
a consumer utility. So the serif is not decoration: it is the signal that a sentence is a statement of
law, and the sans is the signal that a control is app chrome. Keeping them disjoint is what lets the
verdict stamp be believed at 05:40. Every comparable numeral is mono with tabular figures, because
`38 cm` and `188 cm` must share a decimal spine in a species table and because the live ruler readout
in E09 would otherwise shiver sideways on every frame while a fish is held against it.

**The scale resolves the script at `of(context)`, not at `ThemeData` construction — and that is
forced, not preferred.** `theme:` is an argument to `MaterialApp`, evaluated before the app resolves
a locale; `Localizations` is installed *below* `MaterialApp`, so no `ThemeData` builder can know
whether it is about to render Arabic. The extension therefore carries both scales and picks one at
read time, where both `Theme` and `Localizations` are in scope. The alternative — rebuilding the
whole `ThemeData` per locale above `MaterialApp` — would also double the golden matrix from six lanes
to twelve for a value that changes nothing but the type. **Rejected** on both counts.

**Tracking is authored in logical pixels and never in em.** Flutter's `letterSpacing` is absolute
logical px, so the mockup's `0.14em` on a 10.5 px eyebrow is `letterSpacing: 1.47`. Copying the CSS
number verbatim ships one-tenth of the intended tracking, and a gazette rubric collapses into a plain
bold label — a mistake that survives review because it looks *nearly* right. Every step's px value is
tabled in `type-ramp.md` beside its em intent, and test 3 pins the conversion for the worst case.

**Every mono step declares `FontFeature.tabularFigures()`, without exception**, and check 8 of
`check_lonja_type.sh` fails a file that declares a mono face and does not mention the feature. It is
a file-level grep, so declaring the feature once for three of four mono steps would still pass the
gate — which is why there is a per-step test as well.

**The Arabic scale changes four things together.** Face → the Naskh stack, size → ×1.12, height →
the table, tracking → exactly `0`. The uplift is because Arabic reads a size smaller at the same
nominal size, with its meaningful strokes in a shorter x-height band crowded with dots. The zero is
not a preference: Arabic is a joining script, so positive tracking inserts space *inside* a connected
word and `هامور` renders as `ه ا م و ر`, which a native reader must reassemble letter by letter —
destroying the five-second read the product exists to deliver. `binomial` is the single step that
does **not** swap: scientific names are Latin binomials in every locale including `ar`, and there is
no true italic master in the Arabic stack, so a synthetic oblique would slant a cursive RTL script
into unreadability.

**Where the worked example and the reference disagree, the reference wins, and the divergence is
recorded.** `examples/lonja_text_theme.dart` declares 13 of the 16 steps — it omits `subtitle`,
`uiLarge` and `microLabel` — and gives Arabic line-heights of 1.75 for `legalSmall` and 1.30 for
`articleNumber`, where `arabic-and-scripts.md`'s stated rule (`legal` 1.80, others `+0.15`) yields
1.70 and 1.15. This task ships all sixteen steps and the reference's derivation: six heights are
tabled explicitly, `measure` is **1.10** because the numerals section says so in as many words (the
dots need the room, and `+0.15` on a 1.00 readout would re-centre the digits), and every remaining
step is its Latin height `+0.15`. The example is a worked shape, not a table of record.

**Sunlight raises a weight floor rather than resizing anything.** `type-ramp.md`'s per-theme response
gives sunlight "one weight step up on serif prose for glare" and states that sunlight never goes
below w500 on any step. One floor expresses both: `minWeight: FontWeight.w500`, applied across the
scale. The three themes therefore change colour and weight and **never size**, so a golden lane
compares like with like and a text-scale audit does not have to be repeated per theme.

**Glove mode cannot touch the ramp, by construction.** Density lives on `LonjaTokens` and the ramp
takes no density parameter, so `legal`, `verdict` and `citation` are identical at both densities —
which is what `type-ramp.md` demands, because enlarging the legal column to make room for fat targets
is how a citation gets pushed off screen. The one thing glove mode does change is *which* chrome step
a control picks (`uiLarge` rather than `ui`), and that is a call-site decision, made in T07.

**`lerp` snaps rather than interpolating.** A theme change animates over `LonjaMotion.page` (140 ms);
interpolating sixteen `TextStyle`s every frame across that window allocates on the build path for a
visual difference nobody can see in a face change. `other` at `t >= 0.5`, the receiver below it.

**No webfont, ever.** `GoogleFonts.ebGaramond()` is a network fetch in a 100 % offline app: on a boat
it renders a blank verdict screen. The four stacks are system faces resolved on device, which also
keeps the launch path free of font decoding — `SPEC.md` §13's < 1.2 s cold start says "no asset
decoding on the launch path". Check 3 of `check_lonja_type.sh` and check 1 of
`check_app_invariants.sh` both fail on it.

## Tests first

Write every row before touching `lonja_typography.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | loop × 16 — `LonjaTypeScale.latin sets <step> to <size>px w<weight> height <h> tracking <t>` | each published row | all four metrics equal | The ramp *is* the table in `type-ramp.md`; a step that drifts is invisible until two screens disagree about what 16 px means |
| 2 | loop × 4 — `LonjaTypeScale.latin declares tabular figures on <step>` | `measure`, `datum`, `citation`, `articleNumber` | `FontFeature.tabularFigures()` present | Check 8 of the type gate is a file-level grep: declaring the feature on three of four steps still passes it, and the fourth is the one that breaks a column |
| 3 | `LonjaTypeScale.latin sets eyebrow tracking to 1.47 logical pixels` | `eyebrow` | `1.47` | 0.14 em × 10.5 px. Copying the em value verbatim is an order-of-magnitude error that looks nearly right |
| 4 | `LonjaTypeScale.latin sets verdict tracking to -0.80 logical pixels` | `verdict` | `-0.80` | The other end of the same conversion: −0.02 em × 40 px, on the one step the whole result screen is built around |
| 5 | `LonjaTypeScale.latin declares exactly one italic step` | all 16 | only `binomial` | Italic anywhere else reads as editorial voice in a document whose entire claim is that it has none |
| 6 | `LonjaTypeScale.latin sets no step in a face outside the four stacks` | all 16 | each `fontFamilyFallback` is one of `LonjaFaces`' four | A one-off `fontFamily:` is how a seventeenth face enters and how check 2 of the gate starts firing |
| 7 | `ar - LonjaTypeScale.arabic scales <step> by 1.12` (loop × 15, `binomial` excluded) | each step | `latin.fontSize * 1.12` | Arabic reads a size smaller at the same nominal size; `legal` lands at 17.9 and `verdict` at 44.8 |
| 8 | `ar - LonjaTypeScale.arabic sets <step> tracking to zero` (loop × 15) | each step | `0` | Positive tracking severs cursive joins and `هامور` becomes five orphan glyphs. There is no acceptable positive value at any size in any theme |
| 9 | `ar - LonjaTypeScale.arabic sets legal line-height to 1.80` | `legal` | `1.80` | The tabled headline value; Arabic dot stacks clip against the line above at Latin heights |
| 10 | `ar - LonjaTypeScale.arabic sets the measure readout line-height to 1.10` | `measure` | `1.10` | The documented exception to `+0.15`: at 1.00 the dots clip, and at 1.15 the big readout stops sitting on its rule |
| 11 | `ar - LonjaTypeScale.arabic keeps binomial in the Latin serif italic` | `binomial` | Latin stack, italic, size unchanged | The only step that does not swap. A synthetic oblique on a Naskh face is unreadable |
| 12 | `ar - LonjaTypeScale.arabic sets every step in the Naskh stack` (loop × 15) | each step | `LonjaFaces.arabic` | A step that keeps the Latin serif falls back to a system default with no Arabic coverage and renders boxes |
| 13 | `LonjaType.of returns the Arabic scale when the locale is ar` | `Localizations` at `ar` | identical to `.arabic` | The resolution point; the reason the extension carries both scales |
| 14 | loop × 5 — `LonjaType.of returns the Latin scale for <locale>` | `en`, `es`, `gl`, `ca`, `pt_BR` | identical to `.latin` | D-3's six locales. `ca` is in the list because `arabic-and-scripts.md` names `fr` as the sixth locale and `SPEC.md` §9.1 does not |
| 15 | `sunlight - LonjaTheme.sunlight() sets legal prose at w500` | the attached scale | `FontWeight.w500` | One weight step up for glare, and the only per-theme type difference there is |
| 16 | `sunlight - no LonjaTheme.sunlight() step is below w500` (loop × 16) | each step | `index >= w500.index` | The floor stated as a floor; a per-step table would drift, a floor cannot |
| 17 | `LonjaTheme.paper() and LonjaTheme.night() set legal prose at w400` | both | `FontWeight.w400` | The floor must not leak into the other two themes: paper set in w500 is a different document |
| 18 | loop × 3 — `LonjaTheme.<theme>() sets identical metrics at both densities` | standard vs glove | every step equal | Glove mode must never resize `legal`, `verdict` or `citation`; here it cannot, and the test says so |
| 19 | loop × 5 — `LonjaMeasure.<name> is <v> logical pixels` | the five constants | 500, 380, 300, 56, 92 | A reading measure is a character count expressed as a constant; the multiplication by the live scale factor happens at the use site, never here |
| 20 | `LonjaType.lerp returns the other ramp at t 0.5` | two ramps | the other | Sixteen interpolated `TextStyle`s per frame buy nothing visible across a 140 ms face change |

```dart
// app/test/theme/lonja_type_ramp_test.dart
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/type_ramp_table.dart';

void main() {
  final LonjaTypeScale latin = LonjaTypeScale.latin();

  for (final RampRow row in kLatinRamp) {
    test('LonjaTypeScale.latin sets ${row.step} to ${row.size}px '
        'w${row.weight} height ${row.height} tracking ${row.tracking}', () {
      final TextStyle style = row.read(latin);
      expect(style.fontSize, row.size);
      expect(style.fontWeight, row.fontWeight);
      expect(style.height, row.height);
      expect(style.letterSpacing, closeTo(row.tracking, 0.001));
    });
  }

  test('LonjaTypeScale.latin declares exactly one italic step', () {
    final Iterable<RampRow> italics =
        kLatinRamp.where((RampRow r) => r.read(latin).fontStyle == FontStyle.italic);
    expect(italics.map((RampRow r) => r.step), <String>['binomial']);
  });

  // … one test per row above, one behaviour each
}
```

```dart
// app/test/theme/lonja_type_resolution_test.dart
import 'package:catchlaw/theme/lonja_faces.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<LonjaTypeScale> _scaleFor(WidgetTester tester, Locale locale) async {
  late LonjaTypeScale scale;
  await tester.pumpWidget(MaterialApp(
    locale: locale,
    supportedLocales: const <Locale>[
      Locale('ar'), Locale('en'), Locale('es'), Locale('gl'), Locale('ca'),
      Locale('pt', 'BR'),
    ],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: LonjaTheme.paper(),
    home: Builder(builder: (BuildContext context) {
      scale = LonjaType.of(context);
      return const SizedBox.shrink();
    }),
  ));
  return scale;
}

void main() {
  testWidgets('ar - LonjaType.of returns the Arabic scale when the locale is ar',
      (WidgetTester tester) async {
    final LonjaTypeScale scale = await _scaleFor(tester, const Locale('ar'));
    expect(scale.legal.fontFamilyFallback, LonjaFaces.arabic);
    expect(scale.legal.letterSpacing, 0);
  });

  for (final Locale locale in const <Locale>[
    Locale('en'), Locale('es'), Locale('gl'), Locale('ca'), Locale('pt', 'BR'),
  ]) {
    testWidgets('LonjaType.of returns the Latin scale for $locale',
        (WidgetTester tester) async {
      final LonjaTypeScale scale = await _scaleFor(tester, locale);
      expect(scale.legal.fontFamilyFallback, LonjaFaces.serif);
    });
  }
}
```

**Run:** `cd app && flutter test test/theme/` → 20 named rows, of which nine are loops (16, 4, 15,
15, 15, 5, 16, 3, 5), so 105 failures: 94 loop-generated plus 11 single. If any passes before
`lonja_typography.dart` exists, the test is wrong.

## Implementation outline

1. `app/testing/theme/type_ramp_table.dart` first: `kLatinRamp` and `kArabicRamp`, transcribed from
   `type-ramp.md` and `arabic-and-scripts.md`, each row carrying the step name, its four metrics and
   a `TextStyle Function(LonjaTypeScale)` reader. The Arabic heights are the six tabled ones,
   `measure` at 1.10, and `latin + 0.15` for the rest — record the derivation in a comment above the
   table, naming the two rows where the worked example disagrees.
2. `lonja_faces.dart`: four `static const List<String>` stacks, in the reference's order. Order is
   the fallback order and is not alphabetical.
3. `LonjaTypeScale.latin({FontWeight minWeight = FontWeight.w400})` with three local builders —
   `serif`, `sans`, `mono` — taking size, weight, height and tracking. `mono` adds
   `fontFeatures: _tabular` in the builder, so a step physically cannot be declared without it.
   Apply the floor once, in the builders: `weight.index < minWeight.index ? minWeight : weight`.
4. `LonjaTypeScale.arabic({FontWeight minWeight})` derives from the Latin scale: Naskh stack,
   `fontSize * 1.12`, the height from the table, `letterSpacing: 0` — and returns `binomial`
   untouched.
5. `LonjaType` — two fields, the selecting `of(context)`, `copyWith`, snapping `lerp`, and equality
   over the two scales.
6. `LonjaMeasure` — five constants, with a `///` line on each saying it must be multiplied by
   `MediaQuery.textScalerOf(context).scale(1)` at the use site and never stored pre-scaled.
7. `lonja_theme.dart`: attach `LonjaType` in `_build`; `sunlight()` passes
   `minWeight: FontWeight.w500`.
8. Re-run, then `check_lonja_type.sh app/lib`. Check 8 should be satisfied by construction; if it
   fires, a mono step was declared outside the mono builder.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 20 named tests pass, including the eight loops, and each failed first.
- [ ] Sixteen steps exist, matching `type-ramp.md` in size, weight, height and tracking.
- [ ] Every mono step carries `FontFeature.tabularFigures()`; every `ar` step has `letterSpacing: 0`
      and the 1.12 uplift, except `binomial`, which stays Latin serif italic.
- [ ] Sunlight sets no step below w500; paper and night set `legal` at w400.
- [ ] `grep -rn "fontSize\|fontFamily\|TextStyle(" app/lib --include='*.dart' | grep -v '/theme/'`
      returns nothing.
- [ ] `grep -rniE "google_fonts|GoogleFonts\." app/lib` returns nothing, and no font file is added
      to `app/pubspec.yaml`.
- [ ] `grep -rn "smallCaps\|toUpperCase()" app/lib` returns nothing.
- [ ] The ramp takes no density parameter, so glove mode cannot resize legal prose.
- [ ] `check_lonja_type.sh app/lib` clean, checks 1, 2, 3, 4 and 8 included.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/lonja-typography/scripts/check_lonja_type.sh app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh app/lib
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
feat(theme): add the sixteen-step Lonja type ramp with its Arabic resolution

A serif for anything that quotes the law, a mono with tabular figures for
anything comparable, and sans only for chrome that is not part of the
document. The app's authority comes from looking like the instrument it
quotes, and a finding of law set in the UI sans reads as a push notification.

The scale resolves the script at of(context) rather than at ThemeData
construction, and that is forced: theme: is an argument to MaterialApp,
evaluated before the app resolves a locale, while Localizations is installed
below it. Carrying both scales and choosing at read time is the only place
both are in scope — and it keeps the golden matrix at six lanes instead of
twelve.

Tracking is authored in logical pixels because Flutter's letterSpacing is
absolute: the mockup's 0.14em on a 10.5px eyebrow is 1.47, and copying the em
value ships a tenth of the intended tracking. Arabic tracking is exactly zero
at every size in every theme, because tracking inserts space inside a joined
word and هامور renders as five orphan glyphs. binomial is the one step that
keeps the Latin serif italic under ar: scientific names are Latin everywhere,
and the Naskh stack has no italic master.

Sixteen steps ship, not the worked example's thirteen, and the two Arabic
line-heights where the example and arabic-and-scripts.md disagree are resolved
in favour of the reference's stated rule. Sunlight raises a w500 floor across
the scale rather than resizing anything, so the three themes differ in colour
and weight and never in metrics.

Task: E07/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
