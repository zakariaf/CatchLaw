import 'package:catchlaw/theme/lonja_faces.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

/// Sixteen named steps. A seventeenth is added here and to
/// `lonja-typography/references/type-ramp.md` in the same commit — never
/// invented at a call site.
///
/// Sizes are logical pixels at `textScaler` 1.0. `height` is a multiple of
/// `fontSize`, so it scales; `letterSpacing` is absolute logical pixels and
/// does **not**.
@immutable
class LonjaTypeScale {
  /// Binds all sixteen. There is no default step.
  const LonjaTypeScale({
    required this.verdict,
    required this.display,
    required this.title,
    required this.subtitle,
    required this.legal,
    required this.legalSmall,
    required this.binomial,
    required this.uiLarge,
    required this.ui,
    required this.uiSmall,
    required this.eyebrow,
    required this.microLabel,
    required this.measure,
    required this.datum,
    required this.citation,
    required this.articleNumber,
  });

  /// The Latin ramp, shared by `en`, `es`, `gl`, `ca` and `pt_BR`.
  ///
  /// [minWeight] raises every step that falls below it. Sunlight passes
  /// `w500`: at 100 000 lux a `w400` stem thins to nothing against white long
  /// before its contrast ratio says anything is wrong.
  factory LonjaTypeScale.latin({FontWeight minWeight = FontWeight.w100}) => LonjaTypeScale(
    verdict: TextStyle(
      fontFamily: LonjaFaces.serif.first,
      fontFamilyFallback: LonjaFaces.serif,
      fontSize: 40,
      fontWeight: _atLeast(FontWeight.w700, minWeight),
      height: 1.02,
      letterSpacing: -0.8,
    ),
    display: TextStyle(
      fontFamily: LonjaFaces.serif.first,
      fontFamilyFallback: LonjaFaces.serif,
      fontSize: 30,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.1,
      letterSpacing: -0.15,
    ),
    title: TextStyle(
      fontFamily: LonjaFaces.serif.first,
      fontFamilyFallback: LonjaFaces.serif,
      fontSize: 23,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.15,
      letterSpacing: 0.0,
    ),
    subtitle: TextStyle(
      fontFamily: LonjaFaces.serif.first,
      fontFamilyFallback: LonjaFaces.serif,
      fontSize: 19,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.25,
      letterSpacing: 0.0,
    ),
    legal: TextStyle(
      fontFamily: LonjaFaces.serif.first,
      fontFamilyFallback: LonjaFaces.serif,
      fontSize: 16,
      fontWeight: _atLeast(FontWeight.w400, minWeight),
      height: 1.62,
      letterSpacing: 0.08,
    ),
    legalSmall: TextStyle(
      fontFamily: LonjaFaces.serif.first,
      fontFamilyFallback: LonjaFaces.serif,
      fontSize: 14,
      fontWeight: _atLeast(FontWeight.w400, minWeight),
      height: 1.55,
      letterSpacing: 0.14,
    ),
    binomial: TextStyle(
      fontFamily: LonjaFaces.serif.first,
      fontFamilyFallback: LonjaFaces.serif,
      fontSize: 15,
      fontWeight: _atLeast(FontWeight.w400, minWeight),
      height: 1.45,
      letterSpacing: 0.15,
      fontStyle: FontStyle.italic,
    ),
    uiLarge: TextStyle(
      fontFamily: LonjaFaces.sans.first,
      fontFamilyFallback: LonjaFaces.sans,
      fontSize: 17,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.2,
      letterSpacing: 0.17,
    ),
    ui: TextStyle(
      fontFamily: LonjaFaces.sans.first,
      fontFamilyFallback: LonjaFaces.sans,
      fontSize: 15,
      fontWeight: _atLeast(FontWeight.w500, minWeight),
      height: 1.35,
      letterSpacing: 0.15,
    ),
    uiSmall: TextStyle(
      fontFamily: LonjaFaces.sans.first,
      fontFamilyFallback: LonjaFaces.sans,
      fontSize: 13,
      fontWeight: _atLeast(FontWeight.w500, minWeight),
      height: 1.4,
      letterSpacing: 0.26,
    ),
    eyebrow: TextStyle(
      fontFamily: LonjaFaces.sans.first,
      fontFamilyFallback: LonjaFaces.sans,
      fontSize: 10.5,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.1,
      letterSpacing: 1.47,
    ),
    microLabel: TextStyle(
      fontFamily: LonjaFaces.sans.first,
      fontFamilyFallback: LonjaFaces.sans,
      fontSize: 9.5,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.1,
      letterSpacing: 1.9,
    ),
    measure: TextStyle(
      fontFamily: LonjaFaces.mono.first,
      fontFamilyFallback: LonjaFaces.mono,
      fontSize: 34,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.0,
      letterSpacing: -0.34,
      fontFeatures: LonjaFaces.tabular, // FontFeature.tabularFigures()
    ),
    datum: TextStyle(
      fontFamily: LonjaFaces.mono.first,
      fontFamilyFallback: LonjaFaces.mono,
      fontSize: 15,
      fontWeight: _atLeast(FontWeight.w500, minWeight),
      height: 1.3,
      letterSpacing: 0.15,
      fontFeatures: LonjaFaces.tabular, // FontFeature.tabularFigures()
    ),
    citation: TextStyle(
      fontFamily: LonjaFaces.mono.first,
      fontFamilyFallback: LonjaFaces.mono,
      fontSize: 12,
      fontWeight: _atLeast(FontWeight.w400, minWeight),
      height: 1.5,
      letterSpacing: 0.24,
      fontFeatures: LonjaFaces.tabular, // FontFeature.tabularFigures()
    ),
    articleNumber: TextStyle(
      fontFamily: LonjaFaces.mono.first,
      fontFamilyFallback: LonjaFaces.mono,
      fontSize: 11,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.0,
      letterSpacing: 0.66,
      fontFeatures: LonjaFaces.tabular, // FontFeature.tabularFigures()
    ),
  );

  /// The Arabic ramp.
  ///
  /// **Four things change together, and none of them is optional.** The face
  /// becomes the Naskh stack, because the Latin serif has no Arabic coverage.
  /// Every size is the tabled value × 1.12, because Arabic reads a size smaller
  /// at the same nominal size. `height` gains headroom for the ascenders,
  /// descenders and dot stacks — `legal` goes to 1.80 outright, `measure` to
  /// 1.10 because the dots need the room, and everything else takes +0.15.
  ///
  /// And `letterSpacing` is **always 0**. Arabic is a joining script: Latin
  /// tracking inserts space into a connected word, so `هامور` renders as
  /// `ه ا م و ر` and a native reader has to reassemble it letter by letter —
  /// which destroys the five-second read this product exists to deliver. There
  /// is no acceptable positive tracking on Arabic text at any size, in any
  /// theme.
  ///
  /// `eyebrow` and `microLabel` have no Arabic form as designed: tracking is
  /// what makes them, and an upper-casing transform on Arabic is a silent
  /// no-op. In `ar` they carry w700 instead, and their hierarchy comes from
  /// weight, colour and a rule.
  factory LonjaTypeScale.arabic({FontWeight minWeight = FontWeight.w100}) => LonjaTypeScale(
    verdict: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 44.8,
      fontWeight: _atLeast(FontWeight.w700, minWeight),
      height: 1.17,
      letterSpacing: 0,
    ),
    display: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 33.6,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.25,
      letterSpacing: 0,
    ),
    title: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 25.76,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.3,
      letterSpacing: 0,
    ),
    subtitle: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 21.28,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.4,
      letterSpacing: 0,
    ),
    legal: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 17.92,
      fontWeight: _atLeast(FontWeight.w400, minWeight),
      height: 1.8,
      letterSpacing: 0,
    ),
    legalSmall: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 15.68,
      fontWeight: _atLeast(FontWeight.w400, minWeight),
      height: 1.7,
      letterSpacing: 0,
    ),
    // The ONLY step that does not swap face in `ar`. Scientific names are
    // Latin binomials in every locale, and there is no true italic master in
    // the Arabic stack — `FontStyle.italic` there triggers a synthetic oblique
    // that slants a right-to-left cursive script into unreadability.
    binomial: TextStyle(
      fontFamily: LonjaFaces.serif.first,
      fontFamilyFallback: LonjaFaces.serif,
      fontSize: 15,
      fontWeight: _atLeast(FontWeight.w400, minWeight),
      height: 1.45,
      letterSpacing: 0.15,
      fontStyle: FontStyle.italic,
    ),
    uiLarge: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 19.04,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.35,
      letterSpacing: 0,
    ),
    ui: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 16.8,
      fontWeight: _atLeast(FontWeight.w500, minWeight),
      height: 1.5,
      letterSpacing: 0,
    ),
    uiSmall: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 14.56,
      fontWeight: _atLeast(FontWeight.w500, minWeight),
      height: 1.55,
      letterSpacing: 0,
    ),
    eyebrow: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 11.76,
      fontWeight: _atLeast(FontWeight.w700, minWeight),
      height: 1.25,
      letterSpacing: 0,
    ),
    microLabel: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 10.64,
      fontWeight: _atLeast(FontWeight.w700, minWeight),
      height: 1.25,
      letterSpacing: 0,
    ),
    measure: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 38.08,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.1,
      letterSpacing: 0,
    ),
    datum: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 16.8,
      fontWeight: _atLeast(FontWeight.w500, minWeight),
      height: 1.45,
      letterSpacing: 0,
    ),
    citation: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 13.44,
      fontWeight: _atLeast(FontWeight.w400, minWeight),
      height: 1.65,
      letterSpacing: 0,
    ),
    articleNumber: TextStyle(
      fontFamily: LonjaFaces.arabic.first,
      fontFamilyFallback: LonjaFaces.arabic,
      fontSize: 12.32,
      fontWeight: _atLeast(FontWeight.w600, minWeight),
      height: 1.15,
      letterSpacing: 0,
    ),
  );

  /// The verdict stamp, and nothing else.
  final TextStyle verdict;

  /// Species vernacular name on the account screen.
  final TextStyle display;

  /// Screen headings, section heads in a species account.
  final TextStyle title;

  /// Sub-heads, zone name on the result screen.
  final TextStyle subtitle;

  /// Article text, the reason line, the disclaimer.
  final TextStyle legal;

  /// Footnotes, source note, secondary legal prose.
  final TextStyle legalSmall;

  /// Scientific names ONLY — italic, the app’s only italic.
  final TextStyle binomial;

  /// Primary button labels in glove mode.
  final TextStyle uiLarge;

  /// Buttons, nav labels, chips.
  final TextStyle ui;

  /// Helper text, secondary chrome, zone chips.
  final TextStyle uiSmall;

  /// Tracked uppercase block labels: VERDICT, SPECIES, ZONE.
  final TextStyle eyebrow;

  /// Gazette margin rubrics, table column heads.
  final TextStyle microLabel;

  /// The single large measurement readout (38 cm).
  final TextStyle measure;

  /// Limits, table cells, min 45 cm total length.
  final TextStyle datum;

  /// Instrument, article, published date, checked date.
  final TextStyle citation;

  /// Margin rail article numbers (Art. 3).
  final TextStyle articleNumber;

  /// The sixteen steps in table order, for a loop that must not miss one.
  List<TextStyle> get steps => <TextStyle>[
    verdict,
    display,
    title,
    subtitle,
    legal,
    legalSmall,
    binomial,
    uiLarge,
    ui,
    uiSmall,
    eyebrow,
    microLabel,
    measure,
    datum,
    citation,
    articleNumber,
  ];

  @override
  bool operator ==(Object other) => other is LonjaTypeScale && listEquals(other.steps, steps);

  @override
  int get hashCode => Object.hashAll(steps);
}

FontWeight _atLeast(FontWeight weight, FontWeight floor) =>
    weight.value >= floor.value ? weight : floor;

/// Both scales, and the rule for choosing between them.
///
/// The choice is the resolved locale and nothing else: `ar` gets the Arabic
/// ramp, the five Latin locales share the Latin one. It is read at
/// `of(context)` time rather than baked into the `ThemeData`, because E06/T06
/// lets the locale change live and a scale captured at theme construction would
/// keep the Latin serif through an Arabic screen.
@immutable
class LonjaType extends ThemeExtension<LonjaType> {
  /// Carries both scales.
  const LonjaType({required this.latin, required this.arabic});

  /// `en`, `es`, `gl`, `ca`, `pt_BR`.
  final LonjaTypeScale latin;

  /// `ar` — the one RTL locale this product ships (D-3).
  final LonjaTypeScale arabic;

  /// The scale for the locale in scope.
  static LonjaTypeScale of(BuildContext context) {
    final LonjaType? type = Theme.of(context).extension<LonjaType>();
    assert(
      type != null,
      'No LonjaType on this ThemeData. Build the theme with LonjaTheme.paper(), '
      '.night() or .sunlight() rather than a bare ThemeData.',
    );
    return Localizations.localeOf(context).languageCode == 'ar' ? type!.arabic : type!.latin;
  }

  @override
  LonjaType copyWith({LonjaTypeScale? latin, LonjaTypeScale? arabic}) =>
      LonjaType(latin: latin ?? this.latin, arabic: arabic ?? this.arabic);

  /// Snaps rather than interpolating.
  ///
  /// A half-interpolated ramp is a font size no step defines, and a line that
  /// reflows mid-animation reads as a rendering fault rather than as a theme
  /// change.
  @override
  LonjaType lerp(ThemeExtension<LonjaType>? other, double t) {
    if (other is! LonjaType) return this;
    return t < 0.5 ? this : other;
  }

  @override
  bool operator ==(Object other) =>
      other is LonjaType && other.latin == latin && other.arabic == arabic;

  @override
  int get hashCode => Object.hash(latin, arabic);
}

/// Measure ceilings, in logical pixels.
///
/// A line of legal prose past roughly 500 px stops being scannable, and the
/// whole product is one five-second read.
abstract final class LonjaMeasure {
  /// Article text and the disclaimer.
  static const double legal = 500;

  /// Legal prose in a narrow column.
  static const double legalNarrow = 380;

  /// A heading, which wraps sooner than its body.
  static const double heading = 300;

  /// The gazette margin rail.
  static const double marginRail = 56;

  /// A column of comparable numerals.
  static const double digitColumn = 92;
}
