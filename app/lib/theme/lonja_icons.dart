import 'package:flutter/material.dart';

/// One authored glyph, drawn on a 24-unit grid.
///
/// Paths are built in Dart rather than parsed from path-data strings: a string
/// needs a parser, a parser needs its own tests, and the whole reason this
/// family exists is that a glyph must be one stroked shape nobody can nudge.
@immutable
class LonjaGlyph {
  /// Names the glyph and how to draw it.
  const LonjaGlyph(this.name, this.draw, {this.mirrorInRtl = false});

  /// The glyph's name, for diagnostics and for test names.
  final String name;

  /// Builds the path on the 24-unit grid.
  final Path Function() draw;

  /// Whether the glyph implies a direction and must mirror under RTL.
  ///
  /// False for everything in the verdict set. A tick, a cross and a ban are
  /// fixed-meaning marks: mirroring them makes an Arabic screen look like a
  /// different app rather than the same one read the other way.
  final bool mirrorInRtl;
}

/// The four sizes, and there is no fifth.
///
/// A size not on this list is a glyph that reads as a different family beside
/// the ones that are, because the stroke does NOT scale with the size.
enum LonjaIconSize {
  /// 16 — beside a citation or a caps label.
  caption(16),

  /// 22 — nav chrome, list rows, buttons.
  ui(22),

  /// 30 — the verdict stamp mark.
  stamp(30),

  /// 44 — a section mark or an empty-state mark.
  mark(44);

  const LonjaIconSize(this.px);

  /// The rendered box, in logical pixels.
  final double px;
}

/// The stroke weight, one per skin.
///
/// A `ThemeExtension` rather than a field on `LonjaTokens`, because the tokens
/// bind exactly fourteen slots and E07 froze that number against a test. The
/// weight is constant across all four sizes on purpose: scaling it with the box
/// is what makes a 44 px mark read as a different family from a 16 px one.
///
/// `token-tables.md` still has no row for it — E07 risk 5, unresolved there and
/// named again in D-20, because a skill correction lands as its own task.
@immutable
class LonjaIconTheme extends ThemeExtension<LonjaIconTheme> {
  /// Binds the stroke.
  const LonjaIconTheme({required this.stroke});

  /// The burin width: 1.45 on paper and night, 1.95 in sunlight.
  final double stroke;

  /// The icon theme in scope.
  ///
  /// Asserts rather than falling back, exactly as `LonjaTokens.of` does: a
  /// fallback stroke is a fourth theme nobody authored and no golden rendered.
  static LonjaIconTheme of(BuildContext context) {
    final LonjaIconTheme? icons = Theme.of(context).extension<LonjaIconTheme>();
    assert(icons != null, 'no LonjaIconTheme in scope — mount through resolveLonjaTheme');
    return icons!;
  }

  @override
  LonjaIconTheme copyWith({double? stroke}) => LonjaIconTheme(stroke: stroke ?? this.stroke);

  @override
  LonjaIconTheme lerp(covariant LonjaIconTheme? other, double t) =>
      other == null ? this : LonjaIconTheme(stroke: stroke + (other.stroke - stroke) * t);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LonjaIconTheme && other.stroke == stroke;

  @override
  int get hashCode => stroke.hashCode;
}

/// The authored family.
///
/// Stroked, on a 24-unit grid, and the only source of a glyph in this app.
/// `lonja-icons-and-plates` rule 1 bans the Material namespace outright, and it
/// is not a style preference: a filled Material glyph beside engraved strokes
/// reads as a control from another application, on the one screen whose whole
/// job is to look like a printed instrument rather than like software.
abstract final class LonjaIcons {
  /// The rule is met.
  static const LonjaGlyph tick = LonjaGlyph('tick', _tick);

  /// The rule is breached — a failed test, and a bigger one would pass.
  static const LonjaGlyph cross = LonjaGlyph('cross', _cross);

  /// Taking is prohibited — not a failed test, and no bigger one passes.
  static const LonjaGlyph ban = LonjaGlyph('ban', _ban);

  /// A closure is in force.
  static const LonjaGlyph closedSeason = LonjaGlyph('closedSeason', _closedSeason);

  /// The Check branch — a fish, seen from the side.
  static const LonjaGlyph fish = LonjaGlyph('fish', _fish);

  /// The Today branch — a day's tally.
  static const LonjaGlyph tally = LonjaGlyph('tally', _tally);

  /// The Trips branch — a hull.
  static const LonjaGlyph boat = LonjaGlyph('boat', _boat);

  /// The Reference branch — a bound volume.
  static const LonjaGlyph book = LonjaGlyph('book', _book);

  /// The Settings branch — a rule with a set mark.
  static const LonjaGlyph adjust = LonjaGlyph('adjust', _adjust);

  /// Back to the screen this one was pushed from.
  ///
  /// The one glyph in the family that mirrors, and it must: a chevron is not a
  /// fixed-meaning mark like the tick or the ban, it points at the edge the
  /// previous screen went out through — the leading edge in `en`, the trailing
  /// one in `ar`.
  static const LonjaGlyph back = LonjaGlyph('back', _back, mirrorInRtl: true);

  /// Onward, to the screen this row opens.
  ///
  /// Mirrors for the same reason [back] does, and in the same direction: it
  /// points at the edge the next screen comes in from — the trailing edge in
  /// `en`, the leading one in `ar`.
  static const LonjaGlyph forward = LonjaGlyph('forward', _forward, mirrorInRtl: true);

  /// The entry line reads a name.
  ///
  /// A glass, not a Material magnifier: the field it heads is a ruled line on
  /// paper, and the one mark on it has to belong to the same burin as the fish
  /// beside it.
  static const LonjaGlyph search = LonjaGlyph('search', _search);

  /// The question could not be answered from what the fisher supplied.
  ///
  /// Its own mark rather than a faded tick: an open question rendered as a pale
  /// pass is a rule reported as checked when nothing was checked.
  static const LonjaGlyph openQuestion = LonjaGlyph('openQuestion', _openQuestion);

  /// The standing notice at the foot of the sheet.
  ///
  /// A ringed lower-case *i* and never a filled Material badge: the disclaimer
  /// is printed apparatus, and a solid roundel beside it reads as an alert the
  /// reader may dismiss — which is the one thing this notice is not.
  static const LonjaGlyph info = LonjaGlyph('info', _info);

  /// One more row goes into the private log.
  ///
  /// A bare cross of two strokes, on the same 24 grid as the rest: it marks an
  /// addition to a ledger the fisher keeps, not a floating action.
  static const LonjaGlyph plus = LonjaGlyph('plus', _plus);
}

Path _tick() => Path()
  ..moveTo(3.5, 12.5)
  ..lineTo(9, 18.5)
  ..lineTo(20.5, 5.5);

Path _cross() => Path()
  ..moveTo(5, 5)
  ..lineTo(19, 19)
  ..moveTo(19, 5)
  ..lineTo(5, 19);

Path _ban() => Path()
  ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 9))
  ..moveTo(5.6, 5.6)
  ..lineTo(18.4, 18.4);

Path _closedSeason() => Path()
  ..addRect(const Rect.fromLTWH(3.5, 6.5, 17, 14))
  ..moveTo(3.5, 11)
  ..lineTo(20.5, 11)
  ..moveTo(8, 3.5)
  ..lineTo(8, 6.5)
  ..moveTo(16, 3.5)
  ..lineTo(16, 6.5)
  ..moveTo(7, 15.5)
  ..lineTo(17, 15.5);

Path _openQuestion() => Path()
  ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 9))
  ..moveTo(12, 16.5)
  ..lineTo(12, 16.5)
  ..moveTo(9, 9.5)
  ..lineTo(15, 9.5)
  ..moveTo(15, 9.5)
  ..lineTo(12, 13.5);

Path _info() => Path()
  ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 9))
  ..moveTo(12, 11)
  ..lineTo(12, 17)
  ..moveTo(12, 7.5)
  ..lineTo(12, 8.2);

Path _plus() => Path()
  ..moveTo(12, 4.5)
  ..lineTo(12, 19.5)
  ..moveTo(4.5, 12)
  ..lineTo(19.5, 12);

Path _back() => Path()
  ..moveTo(15, 4)
  ..lineTo(7, 12)
  ..lineTo(15, 20);

Path _search() => Path()
  ..addOval(Rect.fromCircle(center: const Offset(10.5, 10.5), radius: 6.5))
  ..moveTo(15.2, 15.2)
  ..lineTo(20.5, 20.5);

Path _forward() => Path()
  ..moveTo(9, 4)
  ..lineTo(17, 12)
  ..lineTo(9, 20);

Path _fish() => Path()
  ..moveTo(3, 12)
  ..lineTo(9, 6.5)
  ..lineTo(17, 6.5)
  ..lineTo(21, 12)
  ..lineTo(17, 17.5)
  ..lineTo(9, 17.5)
  ..close()
  ..moveTo(3, 12)
  ..lineTo(1.5, 8.5)
  ..moveTo(3, 12)
  ..lineTo(1.5, 15.5);

Path _tally() => Path()
  ..moveTo(5, 5)
  ..lineTo(5, 19)
  ..moveTo(9.5, 5)
  ..lineTo(9.5, 19)
  ..moveTo(14, 5)
  ..lineTo(14, 19)
  ..moveTo(18.5, 5)
  ..lineTo(18.5, 19)
  ..moveTo(3.5, 17)
  ..lineTo(20, 7);

Path _boat() => Path()
  ..moveTo(3, 14.5)
  ..lineTo(21, 14.5)
  ..lineTo(17.5, 20)
  ..lineTo(6.5, 20)
  ..close()
  ..moveTo(12, 14.5)
  ..lineTo(12, 3.5)
  ..moveTo(12, 5)
  ..lineTo(18, 10)
  ..lineTo(12, 10);

Path _book() => Path()
  ..addRect(const Rect.fromLTWH(4, 4, 16, 16))
  ..moveTo(8, 4)
  ..lineTo(8, 20)
  ..moveTo(11, 9)
  ..lineTo(17, 9)
  ..moveTo(11, 13)
  ..lineTo(17, 13);

Path _adjust() => Path()
  ..moveTo(3.5, 8)
  ..lineTo(20.5, 8)
  ..moveTo(3.5, 16)
  ..lineTo(20.5, 16)
  ..addOval(Rect.fromCircle(center: const Offset(9, 8), radius: 2.5))
  ..addOval(Rect.fromCircle(center: const Offset(15, 16), radius: 2.5));
