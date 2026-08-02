import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';

/// One published row of the Lonja type ramp.
class TypeRow {
  /// Records one step as `type-ramp.md` prints it.
  const TypeRow(this.step, this.face, this.size, this.weight, this.height, this.trackingPx);

  /// The step name.
  final String step;

  /// `serif`, `sans` or `mono`.
  final String face;

  /// Logical pixels at textScaler 1.0.
  final double size;

  /// The published weight.
  final FontWeight weight;

  /// A multiple of [size], so it scales.
  final double height;

  /// Absolute logical pixels, which do NOT scale.
  final double trackingPx;
}

/// `type-ramp.md` "The ramp", typed out.
///
/// Transcribed and not derived, for the reason every table in this directory
/// is: a list generated from [LonjaTypeScale] would compare the file with
/// itself and pass forever.
const List<TypeRow> kTypeRamp = <TypeRow>[
  TypeRow('verdict', 'serif', 40.0, FontWeight.w700, 1.02, -0.8),
  TypeRow('display', 'serif', 30.0, FontWeight.w600, 1.1, -0.15),
  TypeRow('title', 'serif', 23.0, FontWeight.w600, 1.15, 0.0),
  TypeRow('subtitle', 'serif', 19.0, FontWeight.w600, 1.25, 0.0),
  TypeRow('legal', 'serif', 16.0, FontWeight.w400, 1.62, 0.08),
  TypeRow('legalSmall', 'serif', 14.0, FontWeight.w400, 1.55, 0.14),
  TypeRow('binomial', 'serif', 15.0, FontWeight.w400, 1.45, 0.15),
  TypeRow('uiLarge', 'sans', 17.0, FontWeight.w600, 1.2, 0.17),
  TypeRow('ui', 'sans', 15.0, FontWeight.w500, 1.35, 0.15),
  TypeRow('uiSmall', 'sans', 13.0, FontWeight.w500, 1.4, 0.26),
  TypeRow('eyebrow', 'sans', 10.5, FontWeight.w600, 1.1, 1.47),
  TypeRow('microLabel', 'sans', 9.5, FontWeight.w600, 1.1, 1.9),
  TypeRow('measure', 'mono', 34.0, FontWeight.w600, 1.0, -0.34),
  TypeRow('datum', 'mono', 15.0, FontWeight.w500, 1.3, 0.15),
  TypeRow('citation', 'mono', 12.0, FontWeight.w400, 1.5, 0.24),
  TypeRow('articleNumber', 'mono', 11.0, FontWeight.w600, 1.0, 0.66),
];

/// One step of [LonjaTypeScale], addressed by name.
///
/// A `switch` and not a map: a step added without a case here is a compile
/// error, which is what lets the table be trusted.
TextStyle typeStep(LonjaTypeScale scale, String step) => switch (step) {
  'verdict' => scale.verdict,
  'display' => scale.display,
  'title' => scale.title,
  'subtitle' => scale.subtitle,
  'legal' => scale.legal,
  'legalSmall' => scale.legalSmall,
  'binomial' => scale.binomial,
  'uiLarge' => scale.uiLarge,
  'ui' => scale.ui,
  'uiSmall' => scale.uiSmall,
  'eyebrow' => scale.eyebrow,
  'microLabel' => scale.microLabel,
  'measure' => scale.measure,
  'datum' => scale.datum,
  'citation' => scale.citation,
  'articleNumber' => scale.articleNumber,
  _ => throw ArgumentError.value(step, 'step', 'not a Lonja type step'),
};
