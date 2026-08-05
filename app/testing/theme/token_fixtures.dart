import 'dart:ui' show Color;

import 'package:catchlaw/theme/lonja_tokens.dart';

/// Probes, deliberately **not** palettes.
///
/// Every field holds a distinct value that no theme binds, because the whole
/// job of the equality loop is to notice a field missing from `_props` — and a
/// probe built from real slot bindings can have two fields swapped and still
/// compare equal.
const LonjaTokens kTokensProbe = LonjaTokens(
  surface: Color(0xFF010101),
  surfaceSunk: Color(0xFF020202),
  onSurface: Color(0xFF030303),
  onSurfaceMuted: Color(0xFF040404),
  onSurfaceFaint: Color(0xFF050505),
  hairline: Color(0xFF060606),
  hairlineStrong: Color(0xFF070707),
  ruleBearing: Color(0xFF080808),
  accent: Color(0xFF090909),
  onAccent: Color(0xFF0A0A0A),
  verdictPass: Color(0xFF0B0B0B),
  verdictFail: Color(0xFF0C0C0C),
  verdictWarn: Color(0xFF0D0D0D),
  density: LonjaDensity.standard,
);

/// A second probe, distinct in every field, for the `lerp` rows.
const LonjaTokens kTokensProbeB = LonjaTokens(
  surface: Color(0xFF111111),
  surfaceSunk: Color(0xFF121212),
  onSurface: Color(0xFF131313),
  onSurfaceMuted: Color(0xFF141414),
  onSurfaceFaint: Color(0xFF151515),
  hairline: Color(0xFF161616),
  hairlineStrong: Color(0xFF171717),
  ruleBearing: Color(0xFF181818),
  accent: Color(0xFF191919),
  onAccent: Color(0xFF1A1A1A),
  verdictPass: Color(0xFF1B1B1B),
  verdictFail: Color(0xFF1C1C1C),
  verdictWarn: Color(0xFF1D1D1D),
  density: kDensityProbe,
);

/// A density that is not `standard` and not `glove`, so a row asserting on it
/// cannot pass by accident.
const LonjaDensity kDensityProbe = LonjaDensity(
  tapMin: 99,
  tapGap: 9,
  rowHeight: 99,
  hitSlop: 9,
  gutter: 99,
  actionHeight: 99,
  entryHeight: 99,
  navHeight: 99,
  tileWidth: 99,
  tileHeight: 99,
);

/// The **widening** builder production is forbidden to have.
///
/// `LonjaTokens.copyWith` takes `density` and nothing else on purpose: any
/// wider and a call site can mint a palette no contrast table covers and no
/// golden lane renders. A test needs exactly that power to build a token set
/// differing in one slot, so it lives here — `CONVENTIONS.md` §6 already
/// reserves `testing/` for a version of the app that is not shipped.
LonjaTokens tokensWith(
  LonjaTokens base, {
  Color? surface,
  Color? surfaceSunk,
  Color? onSurface,
  Color? onSurfaceMuted,
  Color? onSurfaceFaint,
  Color? hairline,
  Color? hairlineStrong,
  Color? ruleBearing,
  Color? accent,
  Color? onAccent,
  Color? verdictPass,
  Color? verdictFail,
  Color? verdictWarn,
  LonjaDensity? density,
}) => LonjaTokens(
  surface: surface ?? base.surface,
  surfaceSunk: surfaceSunk ?? base.surfaceSunk,
  onSurface: onSurface ?? base.onSurface,
  onSurfaceMuted: onSurfaceMuted ?? base.onSurfaceMuted,
  onSurfaceFaint: onSurfaceFaint ?? base.onSurfaceFaint,
  hairline: hairline ?? base.hairline,
  hairlineStrong: hairlineStrong ?? base.hairlineStrong,
  ruleBearing: ruleBearing ?? base.ruleBearing,
  accent: accent ?? base.accent,
  onAccent: onAccent ?? base.onAccent,
  verdictPass: verdictPass ?? base.verdictPass,
  verdictFail: verdictFail ?? base.verdictFail,
  verdictWarn: verdictWarn ?? base.verdictWarn,
  density: density ?? base.density,
);

/// One field of [LonjaTokens], and how to change just that field.
class TokenField {
  /// Names a field and the mutation that isolates it.
  const TokenField(this.name, this.mutate);

  /// The field's identifier, interpolated into the test name.
  final String name;

  /// [base] with this one field replaced.
  final LonjaTokens Function(LonjaTokens base) mutate;
}

/// All fourteen fields.
///
/// `_props` is the one place a slot can be silently dropped, and the
/// consequence is a `CustomPainter` that will not repaint on a theme change
/// (`lonja-design-tokens` rule 12). A fourteen-row loop makes the missing field
/// name itself; one aggregate assertion would only say "not equal failed".
const List<TokenField> kTokenFields = <TokenField>[
  TokenField('surface', _surface),
  TokenField('surfaceSunk', _surfaceSunk),
  TokenField('onSurface', _onSurface),
  TokenField('onSurfaceMuted', _onSurfaceMuted),
  TokenField('onSurfaceFaint', _onSurfaceFaint),
  TokenField('hairline', _hairline),
  TokenField('hairlineStrong', _hairlineStrong),
  TokenField('ruleBearing', _ruleBearing),
  TokenField('accent', _accent),
  TokenField('onAccent', _onAccent),
  TokenField('verdictPass', _verdictPass),
  TokenField('verdictFail', _verdictFail),
  TokenField('verdictWarn', _verdictWarn),
  TokenField('density', _density),
];

const Color _other = Color(0xFFFE01FE);

LonjaTokens _surface(LonjaTokens b) => tokensWith(b, surface: _other);
LonjaTokens _surfaceSunk(LonjaTokens b) => tokensWith(b, surfaceSunk: _other);
LonjaTokens _onSurface(LonjaTokens b) => tokensWith(b, onSurface: _other);
LonjaTokens _onSurfaceMuted(LonjaTokens b) => tokensWith(b, onSurfaceMuted: _other);
LonjaTokens _onSurfaceFaint(LonjaTokens b) => tokensWith(b, onSurfaceFaint: _other);
LonjaTokens _hairline(LonjaTokens b) => tokensWith(b, hairline: _other);
LonjaTokens _hairlineStrong(LonjaTokens b) => tokensWith(b, hairlineStrong: _other);
LonjaTokens _ruleBearing(LonjaTokens b) => tokensWith(b, ruleBearing: _other);
LonjaTokens _accent(LonjaTokens b) => tokensWith(b, accent: _other);
LonjaTokens _onAccent(LonjaTokens b) => tokensWith(b, onAccent: _other);
LonjaTokens _verdictPass(LonjaTokens b) => tokensWith(b, verdictPass: _other);
LonjaTokens _verdictFail(LonjaTokens b) => tokensWith(b, verdictFail: _other);
LonjaTokens _verdictWarn(LonjaTokens b) => tokensWith(b, verdictWarn: _other);
LonjaTokens _density(LonjaTokens b) => tokensWith(b, density: kDensityProbe);
