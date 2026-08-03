import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:flutter/painting.dart';

/// Everything the ruler painter needs, and nothing else.
///
/// **A value type, and that is what makes `shouldRepaint` answerable.** A
/// painter holding a notifier, a `BuildContext`, a clock or a domain rule
/// cannot say whether it needs to repaint — so it says `true`, and repaints
/// every frame while a wet hand holds the phone still.
/// `check_painter_hygiene.sh` fails that outright, and this type is why it
/// never comes up.
///
/// Every field is already resolved: the labels are formatted strings, the
/// colours are slot values read from the theme by the widget above, and the
/// stroke widths are numbers. The painter looks nothing up.
@immutable
class RulerScene {
  /// One frame's worth of ruler.
  const RulerScene({
    required this.pxPerMm,
    required this.spanPx,
    required this.tickLabels,
    required this.labelDirection,
    required this.labelStyle,
    required this.ink,
    required this.mark,
    required this.hairlinePx,
    required this.tickPx,
    required this.cursorPx,
  });

  /// The measured scale. **The same number the transform uses** — a painter
  /// that re-derived it from `size` would drift from the hit-tester, and a
  /// reading three pixels short of a legal minimum is a fine.
  final double pxPerMm;

  /// How long the rule is, in logical pixels.
  final double spanPx;

  /// One label per centimetre, already formatted in the reader's own digits.
  final List<String> tickLabels;

  /// Which way the labels read.
  ///
  /// Carried explicitly because the ruler itself does **not** mirror
  /// (`SPEC.md` §9.3's one documented exception): a scale that ran
  /// right-to-left would put zero under the fish's tail.
  final TextDirection labelDirection;

  /// Snapshotted from the theme by the widget above.
  final TextStyle labelStyle;

  /// The rule and its ticks.
  final Color ink;

  /// The moving cursor.
  final Color mark;

  /// Stroke widths, already in the terms the canvas draws in.
  final double hairlinePx;

  /// The centimetre tick.
  final double tickPx;

  /// The cursor.
  final double cursorPx;

  List<Object?> get _props => <Object?>[
    pxPerMm,
    spanPx,
    labelDirection,
    labelStyle,
    ink,
    mark,
    hairlinePx,
    tickPx,
    cursorPx,
  ];

  @override
  bool operator ==(Object other) =>
      other is RulerScene &&
      listEquals(other._props, _props) &&
      listEquals(other.tickLabels, tickLabels);

  @override
  int get hashCode => Object.hash(Object.hashAll(_props), Object.hashAll(tickLabels));
}
