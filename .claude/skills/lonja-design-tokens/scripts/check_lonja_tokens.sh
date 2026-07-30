#!/usr/bin/env bash
set -euo pipefail
# check_lonja_tokens.sh — proves that no aesthetic value is authored outside lib/theme/.
# Usage: scripts/check_lonja_tokens.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# A hardcoded hex, a stray BoxShadow or an off-spine gap fails silently: it renders correctly in
# whichever theme the author happened to be looking at, and wrong in the other two. Nothing in the
# analyzer or the type system catches it, and a golden lane only catches it if that lane exists.
# Heuristic greps, not a compiler — passing this is a floor, not proof the palette is right.
# The ONLY escape hatch is a trailing `// lonja-token-ok` on the offending line; nothing else is
# exempt, and lib/theme/ is where these constructs are supposed to live.
#
# Checks:
#   1. Raw Color(0x…) or Colors.* outside lib/theme/
#   2. Tier-1 primitive reads (LonjaPrimitives.*) outside lib/theme/
#   3. Shadows, gradients and non-zero elevation anywhere
#   4. Corner radius outside lib/theme/, and any radius above the ceiling of 2
#   5. Numeric literals inside EdgeInsets outside lib/theme/ (the 4pt spine is named)
#   6. Literal stroke widths on BorderSide/Divider/Border outside lib/theme/
#   7. fontSize: outside lib/theme/ (the ramp is owned by lonja-typography)
#   8. Theme.of / LonjaTokens.of inside a *_painter.dart (painters take a snapshot)
#   9. Density folded into the theme enum (ThemeMode.glove*, *gloveNight)
#  10. Literal Duration(…) or Curves.* outside lib/theme/ (motion is a token group too)
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "check_lonja_tokens: target dir '$TARGET' not found" >&2
  exit 2
fi
GEN_RE='\.g\.dart$|\.freezed\.dart$|\.drift\.dart$|\.gr\.dart$'
# grep -rn emits "path:line:text", so the filename anchors above need to become ":" boundaries.
GEN_LINE_RE="${GEN_RE//'$'/:}"
THEME_RE='/theme/'
HATCH_RE='lonja-token-ok'
fail=0
report() {
  local label="$1" hits="$2"
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}
echo "== check_lonja_tokens @ $TARGET =="

# 1. A hex or a Material colour outside the theme is a fourth, undeclared palette.
report "raw colour outside lib/theme (read LonjaTokens.of(context).<slot>)" \
  "$(grep -rnE 'Color\(0x|Colors\.[a-zA-Z]' --include='*.dart' "$TARGET" | grep -vE "$GEN_LINE_RE" | grep -vE "$THEME_RE" | grep -v "$HATCH_RE" || true)"

# 2. A tier-1 read hardcodes one theme even though it looks like a token.
report "tier-1 primitive read outside lib/theme (use a semantic slot)" \
  "$(grep -rnE 'LonjaPrimitives\.' --include='*.dart' "$TARGET" | grep -vE "$GEN_LINE_RE" | grep -vE "$THEME_RE" | grep -v "$HATCH_RE" || true)"

# 3. Paper does not float: no z-axis anywhere, including inside lib/theme.
report "shadow, gradient or elevation (separate with a rule or surfaceSunk)" \
  "$(grep -rnE 'BoxShadow|LinearGradient|RadialGradient|SweepGradient|elevation:[[:space:]]*[1-9]|kElevationToShadow' --include='*.dart' "$TARGET" | grep -vE "$GEN_LINE_RE" | grep -v "$HATCH_RE" || true)"

# 4. Radius ceiling is 2: LonjaRadii.none or LonjaRadii.hair, nothing else.
report "corner radius outside lib/theme, or a radius above the ceiling of 2" \
  "$({ grep -rnE 'BorderRadius\.circular|Radius\.circular|RoundedRectangleBorder|StadiumBorder' --include='*.dart' "$TARGET" | grep -vE "$GEN_LINE_RE" | grep -vE "$THEME_RE" | grep -v "$HATCH_RE" || true
       grep -rnE 'circular\([[:space:]]*([3-9]|[1-9][0-9]+)' --include='*.dart' "$TARGET" | grep -vE "$GEN_LINE_RE" | grep -v "$HATCH_RE" || true; } | sort -u)"

# 5. Off-spine padding cannot be scaled by glove mode.
report "numeric EdgeInsets outside lib/theme (use LonjaSpace.s1..s8)" \
  "$(grep -rnE 'EdgeInsets(Directional)?\.(all|symmetric|only|fromLTRB)\([^)]*[0-9]' --include='*.dart' "$TARGET" | grep -vE "$GEN_LINE_RE" | grep -vE "$THEME_RE" | grep -v "$HATCH_RE" | grep -vE 'LonjaSpace\.' || true)"

# 6. Four rule weights exist; a literal is a fifth.
report "literal stroke width outside lib/theme (use LonjaRules.hair/rule/strong/stamp)" \
  "$(grep -rnE '(BorderSide|Border\.all|Divider|VerticalDivider)[^;]*(width|thickness):[[:space:]]*[0-9]' --include='*.dart' "$TARGET" | grep -vE "$GEN_LINE_RE" | grep -vE "$THEME_RE" | grep -v "$HATCH_RE" | grep -vE 'LonjaRules\.' || true)"

# 7. The type ramp is a value set too, and it lives in the theme.
report "fontSize outside lib/theme (use the ramp — lonja-typography)" \
  "$(grep -rnE 'fontSize:' --include='*.dart' "$TARGET" | grep -vE "$GEN_LINE_RE" | grep -vE "$THEME_RE" | grep -v "$HATCH_RE" || true)"

# 8. A painter that reads the tree cannot answer shouldRepaint honestly.
report "context/theme lookup inside a painter (pass a LonjaTokens snapshot)" \
  "$(grep -rnE 'Theme\.of\(|LonjaTokens\.of\(|BuildContext' --include='*_painter.dart' "$TARGET" | grep -vE "$GEN_LINE_RE" | grep -v "$HATCH_RE" || true)"

# 9. Density is orthogonal: 3 palettes x 2 densities, never 6 themes.
report "glove folded into the theme enum (use LonjaTokens.density)" \
  "$(grep -rniE 'ThemeMode\.glove|glovenight|glovepaper|glovesunlight' --include='*.dart' "$TARGET" | grep -vE "$GEN_LINE_RE" || true)"

# 10. Motion is a value set too: LonjaMotion.none/quick/page, resolved for reduced motion.
report "literal Duration or Curves outside lib/theme (use LonjaMotion.quick/page)" \
  "$(grep -rnE 'Duration\([[:space:]]*(milliseconds|seconds)|Curves\.[a-zA-Z]' --include='*.dart' "$TARGET" | grep -vE "$GEN_LINE_RE" | grep -vE "$THEME_RE" | grep -v "$HATCH_RE" || true)"

echo
if [ "$fail" -ne 0 ]; then
  echo "check_lonja_tokens: FAIL — review the hits above." >&2; exit 1
fi
echo "check_lonja_tokens: OK ($TARGET)"
