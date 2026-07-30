// Demonstrates the complete Lonja type ramp as a single ThemeExtension: the four faces, all
// sixteen named steps with their real sizes/weights/heights/tracking, tabular figures on every
// mono step, the Arabic variant (1.12 optical uplift, height 1.80, letterSpacing 0), the reading
// measure constants, and a result-screen fragment that consumes steps by name only.
//
// Everything below lives under lib/theme/ — it is the ONLY place in CATCHLAW where a fontSize or
// a raw TextStyle( is legal. ThemeExtension plumbing conventions: see design-system-structure.

import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

/// System stacks. CATCHLAW bundles no runtime webfont: it is 100% offline.
abstract final class LonjaFaces {
  static const List<String> serif = <String>[
    'Iowan Old Style', 'Palatino Linotype', 'Palatino', 'Book Antiqua', 'Georgia',
    'Times New Roman', 'serif',
  ];
  static const List<String> sans = <String>[
    'ui-sans-serif', '-apple-system', 'Helvetica Neue', 'Segoe UI', 'Roboto', 'Arial',
    'sans-serif',
  ];
  static const List<String> mono = <String>[
    'ui-monospace', 'SF Mono', 'Menlo', 'Consolas', 'DejaVu Sans Mono', 'monospace',
  ];
  static const List<String> arabic = <String>[
    'Geeza Pro', 'Al Bayan', 'Damascus', 'Noto Naskh Arabic', 'Traditional Arabic', 'serif',
  ];
}

/// Reading measures in logical px at textScaler 1.0. ALWAYS multiply by the live scale factor.
abstract final class LonjaMeasure {
  static const double legal = 500; // ~65 characters of the 16px serif
  static const double legalNarrow = 380;
  static const double heading = 300;
  static const double marginRail = 56;
  static const double digitColumn = 92;
}

const List<FontFeature> _tabular = <FontFeature>[FontFeature.tabularFigures()];

@immutable
class LonjaType extends ThemeExtension<LonjaType> {
  const LonjaType({
    required this.verdict,
    required this.display,
    required this.title,
    required this.legal,
    required this.legalSmall,
    required this.binomial,
    required this.ui,
    required this.uiSmall,
    required this.eyebrow,
    required this.measure,
    required this.datum,
    required this.citation,
    required this.articleNumber,
  });

  final TextStyle verdict, display, title, legal, legalSmall, binomial;
  final TextStyle ui, uiSmall, eyebrow;
  final TextStyle measure, datum, citation, articleNumber;

  /// Latin ramp. Tracking is logical px = em x size (rule 5), never the em number itself.
  factory LonjaType.latin({FontWeight legalWeight = FontWeight.w400}) {
    TextStyle serif(double s, FontWeight w, double h, double t) => TextStyle(
          fontFamilyFallback: LonjaFaces.serif,
          fontSize: s, fontWeight: w, height: h, letterSpacing: t,
        );
    TextStyle sans(double s, FontWeight w, double h, double t) => TextStyle(
          fontFamilyFallback: LonjaFaces.sans,
          fontSize: s, fontWeight: w, height: h, letterSpacing: t,
        );
    TextStyle mono(double s, FontWeight w, double h, double t) => TextStyle(
          fontFamilyFallback: LonjaFaces.mono,
          fontSize: s, fontWeight: w, height: h, letterSpacing: t,
          fontFeatures: _tabular, // EVERY mono step, no exceptions (rule 3)
        );
    return LonjaType(
      verdict: serif(40, FontWeight.w700, 1.02, -0.80),
      display: serif(30, FontWeight.w600, 1.10, -0.15),
      title: serif(23, FontWeight.w600, 1.15, 0.00),
      legal: serif(16, legalWeight, 1.62, 0.08),
      legalSmall: serif(14, legalWeight, 1.55, 0.14),
      binomial: serif(15, FontWeight.w400, 1.45, 0.15).copyWith(fontStyle: FontStyle.italic),
      ui: sans(15, FontWeight.w500, 1.35, 0.15),
      uiSmall: sans(13, FontWeight.w500, 1.40, 0.26),
      eyebrow: sans(10.5, FontWeight.w600, 1.10, 1.47), // 0.14em x 10.5px
      measure: mono(34, FontWeight.w600, 1.00, -0.34),
      datum: mono(15, FontWeight.w500, 1.30, 0.15),
      citation: mono(12, FontWeight.w400, 1.50, 0.24),
      articleNumber: mono(11, FontWeight.w600, 1.00, 0.66),
    );
  }

  /// Arabic variant: Naskh stack, x1.12 optical uplift, extra height, tracking forced to 0.
  /// `binomial` is the ONE step that stays Latin serif italic (scientific names are Latin).
  factory LonjaType.arabic({FontWeight legalWeight = FontWeight.w400}) {
    final LonjaType base = LonjaType.latin(legalWeight: legalWeight);
    TextStyle ar(TextStyle s, double height) => s.copyWith(
          fontFamilyFallback: LonjaFaces.arabic,
          fontSize: s.fontSize! * 1.12,
          height: height,
          letterSpacing: 0, // rule 9 — tracking severs cursive joins
        );
    return LonjaType(
      verdict: ar(base.verdict, 1.15),
      display: ar(base.display, 1.25),
      title: ar(base.title, 1.30),
      legal: ar(base.legal, 1.80),
      legalSmall: ar(base.legalSmall, 1.75),
      binomial: base.binomial,
      ui: ar(base.ui, 1.50),
      uiSmall: ar(base.uiSmall, 1.55),
      eyebrow: ar(base.eyebrow, 1.25).copyWith(fontWeight: FontWeight.w700),
      measure: ar(base.measure, 1.10),
      datum: ar(base.datum, 1.45),
      citation: ar(base.citation, 1.65),
      articleNumber: ar(base.articleNumber, 1.30),
    );
  }

  static LonjaType of(BuildContext context) {
    final LonjaType? t = Theme.of(context).extension<LonjaType>();
    assert(t != null, 'LonjaType missing: add it to ThemeData.extensions.');
    return t!;
  }

  @override
  LonjaType copyWith({TextStyle? verdict, TextStyle? legal}) => LonjaType(
        verdict: verdict ?? this.verdict, display: display, title: title,
        legal: legal ?? this.legal, legalSmall: legalSmall, binomial: binomial,
        ui: ui, uiSmall: uiSmall, eyebrow: eyebrow,
        measure: measure, datum: datum, citation: citation, articleNumber: articleNumber,
      );

  @override
  LonjaType lerp(ThemeExtension<LonjaType>? other, double t) =>
      other is LonjaType && t >= 0.5 ? other : this;
}

/// Consumer: the result screen states a fact, cites its source, and names no metric.
class VerdictBlock extends StatelessWidget {
  const VerdictBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final LonjaType t = LonjaType.of(context);
    final double scale = MediaQuery.textScalerOf(context).scale(1);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: LonjaMeasure.legal * scale), // rule 7
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('VERDICT', style: t.eyebrow), // pre-cased label, from the ARB in production
          const SizedBox(height: 6),
          Text('Below the minimum', style: t.verdict), // statement of fact, never an instruction
          const SizedBox(height: 4),
          Text('38 cm', style: t.measure),
          Text('minimum 45 cm (total length)', style: t.legal), // no maxLines (rule 8)
          const SizedBox(height: 12),
          Text.rich(TextSpan(children: <TextSpan>[
            TextSpan(text: 'هامور Hamour  ·  ', style: t.display),
            TextSpan(text: 'Epinephelus coioides', style: t.binomial),
          ])),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            SizedBox(
              width: LonjaMeasure.marginRail,
              child: Text('Art. 3', style: t.articleNumber, textAlign: TextAlign.end),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Separate Text widgets, never a hand-placed '\n' inside a string.
                  Text('Ministerial Decision 580/2015, Art. 3', style: t.citation),
                  Text('published 2015-11-03 · checked 2026-07-14', style: t.citation),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
