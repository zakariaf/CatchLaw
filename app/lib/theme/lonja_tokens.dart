import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

/// The 4 pt spacing spine. Eight steps, and nothing between them.
///
/// There is no `s0`, because a zero gap is `EdgeInsets.zero`. An off-spine
/// value cannot be scaled by glove mode, which multiplies named steps and has
/// no idea what a `13` was.
abstract final class LonjaSpace {
  /// 4 — glyph-to-word, tabular cell padding.
  static const double s1 = 4;

  /// 8 — icon-to-label, inline rule inset.
  static const double s2 = 8;

  /// 12 — list-row vertical padding.
  static const double s3 = 12;

  /// 16 — screen gutter, block padding.
  static const double s4 = 16;

  /// 24 — between blocks in a section.
  static const double s5 = 24;

  /// 32 — section separation.
  static const double s6 = 32;

  /// 48 — above the verdict stamp.
  static const double s7 = 48;

  /// 64 — page head to first article.
  static const double s8 = 64;
}

/// The four rule weights, and there is no fifth.
///
/// A `1.5` renders as a printing defect at 3× and vanishes at 1×.
abstract final class LonjaRules {
  /// 0.5 — tabular row separation.
  static const double hair = 0.5;

  /// 1.0 — default divider, block frame.
  static const double rule = 1;

  /// 2.0 — section head underscore, active tab.
  static const double strong = 2;

  /// 3.0 — the verdict stamp frame, **and nothing else**.
  static const double stamp = 3;
}

/// Two radii. Square corners are what the booklet has.
abstract final class LonjaRadii {
  /// The default for every surface.
  static const BorderRadius none = BorderRadius.zero;

  /// 2 — the ceiling. Chips and the ruler thumb only.
  static const BorderRadius hair = BorderRadius.all(Radius.circular(2));
}

/// Motion durations. There is no shadow group, no gradient group and no
/// elevation group, because a printed sheet has no z-axis.
abstract final class LonjaMotion {
  /// The reduced-motion resolution.
  static const Duration none = Duration.zero;

  /// 90 ms — a state change on a control.
  static const Duration quick = Duration(milliseconds: 90);

  /// 140 ms — a route transition.
  static const Duration page = Duration(milliseconds: 140);
}

/// How big a target is and how far it sits from the next one.
///
/// Orthogonal to the palette by construction: each of the three themes is built
/// with either value, giving six renderings from three palettes rather than six
/// palettes.
///
/// Named parameters rather than the worked example's five positional doubles.
/// A transposition of `rowHeight` and `tapMin` compiles, passes the analyzer,
/// and produces a 56 dp row containing a 48 dp target that nobody notices until
/// a golden. The values are `lonja-design-tokens`'; the constructor shape is
/// `dart3-idioms-and-coding-standards`'.
@immutable
class LonjaDensity {
  /// Describes one density.
  const LonjaDensity({
    required this.tapMin,
    required this.tapGap,
    required this.rowHeight,
    required this.hitSlop,
    required this.gutter,
  });

  /// Ungloved. `SPEC.md` §13's floor is ≥ 48 dp; this sits on it.
  static const LonjaDensity standard = LonjaDensity(
    tapMin: 48,
    tapGap: 4,
    rowHeight: 56,
    hitSlop: 0,
    gutter: LonjaSpace.s4,
  );

  /// Gloved, or wet, or both.
  ///
  /// `SPEC.md` §4.9: all primary targets ≥ 56 dp with ≥ 8 dp separation. A
  /// gloved or wet thumb loses roughly 8 dp of precision, and separation is
  /// what prevents the adjacent-target mis-tap — which is the half people drop
  /// when they read the size and stop.
  static const LonjaDensity glove = LonjaDensity(
    tapMin: 56,
    tapGap: LonjaSpace.s2,
    rowHeight: 72,
    hitSlop: 4,
    gutter: LonjaSpace.s5,
  );

  /// The smallest side of a primary target.
  final double tapMin;

  /// The separation between two adjacent targets — what prevents the
  /// adjacent-target mis-tap.
  final double tapGap;

  /// A species row, which stays one-thumb scannable.
  final double rowHeight;

  /// Extends the hit box without moving the ink.
  final double hitSlop;

  /// The screen gutter.
  final double gutter;

  @override
  bool operator ==(Object other) =>
      other is LonjaDensity &&
      other.tapMin == tapMin &&
      other.tapGap == tapGap &&
      other.rowHeight == rowHeight &&
      other.hitSlop == hitSlop &&
      other.gutter == gutter;

  @override
  int get hashCode => Object.hash(tapMin, tapGap, rowHeight, hitSlop, gutter);

  @override
  String toString() => 'LonjaDensity(tapMin: $tapMin, tapGap: $tapGap)';
}

/// The thirteen semantic slots, plus density.
///
/// **A widget reads a slot, never a pigment** (`lonja-design-tokens` rule 3).
/// A slot is a *role*, so one widget is correct in three palettes:
/// [onSurfaceMuted] is the citation line whether it resolves to `ink30` on
/// paper, `paper72` on night or `black00` in sunlight. A primitive read
/// hardcodes one theme — it stays bone-white at night and mid-grey in sunlight,
/// which is exactly where the fisher has ten seconds and no shade.
///
/// A `CustomPainter` has no `BuildContext` and cannot reach [of]. It takes a
/// snapshot in its constructor and answers `shouldRepaint` with
/// `old.tokens != tokens`, which is why [==] covers all fourteen fields — a
/// field missing from the comparison is a painter that will not repaint on a
/// theme change.
@immutable
class LonjaTokens extends ThemeExtension<LonjaTokens> {
  /// Binds all fourteen. There is no default and no fallback.
  const LonjaTokens({
    required this.surface,
    required this.surfaceSunk,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.onSurfaceFaint,
    required this.hairline,
    required this.hairlineStrong,
    required this.ruleBearing,
    required this.accent,
    required this.onAccent,
    required this.verdictPass,
    required this.verdictFail,
    required this.verdictWarn,
    required this.density,
  });

  /// The sheet.
  final Color surface;

  /// Recessed stock.
  final Color surfaceSunk;

  /// Primary text, and the verdict word.
  final Color onSurface;

  /// Secondary text, citations.
  final Color onSurfaceMuted;

  /// Captions at 19 sp and above. **Never a fact** — the limit is global and is
  /// set by the worst theme.
  final Color onSurfaceFaint;

  /// Row separation, ornament. Never the sole boundary of a control.
  final Color hairline;

  /// Section separation, ornament.
  final Color hairlineStrong;

  /// Control frames and the active-tab rule — the rule that *identifies*
  /// rather than decorates, and so carries a 3:1 floor.
  final Color ruleBearing;

  /// Chrome: links, focus, selection.
  final Color accent;

  /// Text on an accent fill.
  final Color onAccent;

  /// Meets the rule.
  final Color verdictPass;

  /// Fails the rule.
  final Color verdictFail;

  /// Stale rule data — the ochre bar. Never a fill, because `ochre47` measures
  /// 3.97:1 and clears a frame but not text.
  final Color verdictWarn;

  /// The fourteenth field, and not a colour.
  final LonjaDensity density;

  /// The tokens in scope.
  ///
  /// Asserts rather than falling back. A fallback ships a palette that no
  /// contrast table covers and no golden lane rendered, and it does it
  /// silently: the screen looks fine, in a fourth theme nobody authored.
  static LonjaTokens of(BuildContext context) {
    final LonjaTokens? tokens = Theme.of(context).extension<LonjaTokens>();
    assert(
      tokens != null,
      'No LonjaTokens on this ThemeData. Build the theme with LonjaTheme.paper(), '
      '.night() or .sunlight() rather than a bare ThemeData.',
    );
    return tokens!;
  }

  /// This token set with a different [density].
  ///
  /// **Narrowed on purpose, and the narrowing is the feature.** The obvious
  /// fourteen-optional version lets any call site mint a palette that no
  /// contrast table covers — and it is literally how a derived "sunlight" keeps
  /// the mid-greys it exists to delete: `paper.copyWith(surface: white100,
  /// onSurface: black00)` leaves `onSurfaceFaint` at `ink49`, which measures
  /// 4.5:1 on white and disappears at 100,000 lux. Density is the one axis a
  /// caller may vary, because it is orthogonal by construction.
  @override
  LonjaTokens copyWith({LonjaDensity? density}) => LonjaTokens(
    surface: surface,
    surfaceSunk: surfaceSunk,
    onSurface: onSurface,
    onSurfaceMuted: onSurfaceMuted,
    onSurfaceFaint: onSurfaceFaint,
    hairline: hairline,
    hairlineStrong: hairlineStrong,
    ruleBearing: ruleBearing,
    accent: accent,
    onAccent: onAccent,
    verdictPass: verdictPass,
    verdictFail: verdictFail,
    verdictWarn: verdictWarn,
    density: density ?? this.density,
  );

  /// Colours interpolate; **density snaps**.
  ///
  /// A cross-fade between two palettes is legitimate. A half-interpolated tap
  /// target is not: 52 dp is legal in neither mode, and a hit box that changes
  /// size mid-animation is a mis-tap waiting for a wet hand.
  @override
  LonjaTokens lerp(ThemeExtension<LonjaTokens>? other, double t) {
    if (other is! LonjaTokens) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return LonjaTokens(
      surface: c(surface, other.surface),
      surfaceSunk: c(surfaceSunk, other.surfaceSunk),
      onSurface: c(onSurface, other.onSurface),
      onSurfaceMuted: c(onSurfaceMuted, other.onSurfaceMuted),
      onSurfaceFaint: c(onSurfaceFaint, other.onSurfaceFaint),
      hairline: c(hairline, other.hairline),
      hairlineStrong: c(hairlineStrong, other.hairlineStrong),
      ruleBearing: c(ruleBearing, other.ruleBearing),
      accent: c(accent, other.accent),
      onAccent: c(onAccent, other.onAccent),
      verdictPass: c(verdictPass, other.verdictPass),
      verdictFail: c(verdictFail, other.verdictFail),
      verdictWarn: c(verdictWarn, other.verdictWarn),
      density: t < 0.5 ? density : other.density,
    );
  }

  /// Every field, in constructor order, so a review can read the two off
  /// against each other.
  List<Object> get _props => <Object>[
    surface,
    surfaceSunk,
    onSurface,
    onSurfaceMuted,
    onSurfaceFaint,
    hairline,
    hairlineStrong,
    ruleBearing,
    accent,
    onAccent,
    verdictPass,
    verdictFail,
    verdictWarn,
    density,
  ];

  @override
  bool operator ==(Object other) => other is LonjaTokens && listEquals(other._props, _props);

  @override
  int get hashCode => Object.hashAll(_props);
}
