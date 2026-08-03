import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';

/// Which semantic ink a category is struck in.
///
/// A slot rather than a colour, and the reason is layering rather than taste:
/// the palette belongs to `lib/theme/`, so a feature file that named a colour
/// would be a second place the verdict inks live, and the second place is the
/// one nobody updates.
enum VerdictInk {
  /// Verdant. Every rule on record is met.
  pass,

  /// Oxblood. A rule fired against this fish.
  fail,

  /// Ochre. A closure, which is neither a pass nor a fault in this individual.
  warn,
}

/// Glyph, ink and structure for one category, as one value.
///
/// One record rather than a glyph map here and a colour map there. Two maps
/// drift, and the drift is silent: the day a category gains a colour but keeps
/// the previous glyph, the screen still renders and still looks deliberate.
typedef VerdictSignals = ({LonjaGlyph glyph, VerdictInk ink, bool measured});

/// The signal set for [category].
///
/// A total switch with no `default:` arm, so a fifth category fails to compile
/// here rather than borrowing the fourth's mark.
///
/// **Protected and belowMinimum share one ink**, so hue carries zero
/// information between them. They are separated by the glyph — a ban against a
/// failed test — by the headline words, and structurally: [measured] is false
/// for protected, so no measurement is printed at all. A reader who takes only
/// the colour otherwise reads "too small" and goes looking for a bigger one of
/// a species that may never be taken.
VerdictSignals signalsFor(VerdictCategory category) => switch (category) {
  VerdictCategory.meets => (glyph: LonjaIcons.tick, ink: VerdictInk.pass, measured: true),
  VerdictCategory.belowMinimum => (glyph: LonjaIcons.cross, ink: VerdictInk.fail, measured: true),
  // A closure applies at every size, so a measurement beside it would suggest
  // that some size escapes it.
  VerdictCategory.closedSeason => (
    glyph: LonjaIcons.closedSeason,
    ink: VerdictInk.warn,
    measured: false,
  ),
  // No size and no season applies. A measurement here implies a threshold that
  // does not exist.
  VerdictCategory.protected => (glyph: LonjaIcons.ban, ink: VerdictInk.fail, measured: false),
};
