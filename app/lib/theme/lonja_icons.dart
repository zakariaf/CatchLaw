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

  /// The question could not be answered from what the fisher supplied.
  ///
  /// Its own mark rather than a faded tick: an open question rendered as a pale
  /// pass is a rule reported as checked when nothing was checked.
  static const LonjaGlyph openQuestion = LonjaGlyph('openQuestion', _openQuestion);
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
