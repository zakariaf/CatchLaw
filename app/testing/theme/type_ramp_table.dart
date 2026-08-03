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
  TypeRow('title', 'serif', 24.0, FontWeight.w600, 1.15, 0.0),
  TypeRow('subtitle', 'serif', 20.0, FontWeight.w600, 1.25, 0.0),
  TypeRow('legal', 'serif', 17.0, FontWeight.w400, 1.62, 0.09),
  TypeRow('legalSmall', 'serif', 15.0, FontWeight.w400, 1.55, 0.15),
  TypeRow('binomial', 'serif', 16.0, FontWeight.w400, 1.45, 0.16),
  TypeRow('uiLarge', 'sans', 18.0, FontWeight.w600, 1.2, 0.18),
  TypeRow('ui', 'sans', 16.0, FontWeight.w500, 1.35, 0.16),
  TypeRow('uiSmall', 'sans', 14.0, FontWeight.w500, 1.4, 0.28),
  TypeRow('eyebrow', 'sans', 12.5, FontWeight.w600, 1.1, 1.75),
  TypeRow('microLabel', 'sans', 11.5, FontWeight.w600, 1.1, 2.3),
  TypeRow('measure', 'mono', 34.0, FontWeight.w600, 1.0, -0.34),
  TypeRow('datum', 'mono', 16.0, FontWeight.w500, 1.3, 0.16),
  TypeRow('citation', 'mono', 14.0, FontWeight.w400, 1.5, 0.28),
  TypeRow('articleNumber', 'mono', 12.5, FontWeight.w600, 1.0, 0.75),
];

/// The floor no step may go below.
///
/// The first ramp put `eyebrow` at 10.5 and `microLabel` at 9.5, and both were
/// unreadable on a phone at arm's length — reported from a device, not caught by
/// a golden, because a golden proves the pixels did not move and says nothing
/// about whether a person can read them. Below roughly this size a tracked
/// uppercase label stops resolving as words and becomes texture.
const double kSmallestReadableStep = 11.5;

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

/// The row named [step].
///
/// So a widget test can assert against the ramp instead of typing a number.
/// A hardcoded `17` in a button test is a second copy of the table, and the copy
/// is what disagrees the next time the ramp moves.
TypeRow rampStep(String step) => kTypeRamp.firstWhere((TypeRow r) => r.step == step);
