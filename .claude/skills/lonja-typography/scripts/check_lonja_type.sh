#!/usr/bin/env bash
set -euo pipefail
# check_lonja_type.sh — proves every glyph in the app is set by the Lonja ramp, not by a call site.
# Usage: scripts/check_lonja_type.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# This gate exists because a stray TextStyle compiles, renders, and looks fine on the paper theme
# in the simulator — then keeps paper metrics on night, sunlight and glove mode, loses tabular
# figures so the ruler readout jitters, or tracks Arabic apart into unreadable orphan glyphs. None
# of that fails a build or a lint. Heuristic greps, not a compiler: it cannot see through helper
# functions or const factories. Trailing `// lonja-type: ok` exempts a single line; nothing else.
#
# Checks:
#   1. Raw TextStyle( construction outside a theme/ directory.
#   2. Literal fontSize:, fontFamily: or fontFamilyFallback: outside a theme/ directory.
#   3. GoogleFonts / google_fonts — a network font in a 100% offline app.
#   4. Material textTheme roles (bodyLarge, headlineSmall, …) that bypass LonjaType.of(context).
#   5. textScaler clamping or the deprecated textScaleFactor.
#   6. .toUpperCase() on text destined for the UI — case belongs in the ARB.
#   7. Truncation applied to legal, citation or verdict styles.
#   8. A monospace face declared in theme/ with no FontFeature.tabularFigures() in the same file.
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "check_lonja_type: target dir '$TARGET' not found" >&2
  exit 2
fi
GEN_RE='\.g\.dart$|\.freezed\.dart$|\.drift\.dart$|\.gr\.dart$'
THEME_RE='/theme/'
OK_RE='// *lonja-type: *ok'
fail=0
report() {
  local label="$1" hits="$2"
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}
echo "== check_lonja_type @ $TARGET =="

report "raw TextStyle( outside theme/ (name a ramp step: LonjaType.of(context).legal)" \
  "$(grep -rnE '(^|[^a-zA-Z])TextStyle\(' --include='*.dart' "$TARGET" \
    | grep -vE "$GEN_RE" | grep -vE "$THEME_RE" | grep -vE "$OK_RE" || true)"

report "font metric literal outside theme/ (add a step to lib/theme/lonja_typography.dart)" \
  "$(grep -rnE '(fontSize|fontFamily|fontFamilyFallback|letterSpacing) *:' --include='*.dart' \
    "$TARGET" | grep -vE "$GEN_RE" | grep -vE "$THEME_RE" | grep -vE "$OK_RE" || true)"

report "runtime webfont (CATCHLAW is 100% offline; use the system stacks in LonjaFaces)" \
  "$(grep -rniE 'google_fonts|GoogleFonts\.|fonts\.googleapis|http.*\.(ttf|otf|woff2?)' \
    --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)"

report "Material textTheme role bypasses the ramp (use LonjaType.of(context))" \
  "$(grep -rnE 'textTheme\.(display|headline|title|body|label)[A-Za-z]*' --include='*.dart' \
    "$TARGET" | grep -vE "$GEN_RE" | grep -vE "$THEME_RE" | grep -vE "$OK_RE" || true)"

report "textScaler clamped or deprecated textScaleFactor (see accessibility-as-code)" \
  "$(grep -rnE 'textScaleFactor|TextScaler\.linear\(|textScaler.*\.clamp\(|MediaQuery\(.*textScaler' \
    --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -vE "$OK_RE" || true)"

report "toUpperCase() in UI code (eyebrows ship pre-cased from the ARB; no-op on Arabic)" \
  "$(grep -rnE '\.toUpperCase\(\)' --include='*.dart' "$TARGET" \
    | grep -vE "$GEN_RE" | grep -vE "$OK_RE" || true)"

report "legal/citation/verdict text truncated (it must wrap and the page must scroll)" \
  "$(grep -rnE '(legal|citation|verdict|legalSmall)[^;]*(maxLines *:|TextOverflow\.ellipsis)' \
    --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -vE "$OK_RE" || true)"

mono_no_tabular=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if grep -qE "monospace|LonjaFaces\.mono" "$f" && ! grep -q 'FontFeature.tabularFigures' "$f"; then
    mono_no_tabular="${mono_no_tabular}${f}: declares a mono face with no tabularFigures"$'\n'
  fi
done < <(find "$TARGET" -type f -name '*.dart' | grep -vE "$GEN_RE" || true)
report "mono role without tabular figures (columns lose their decimal spine)" \
  "$(printf '%s' "$mono_no_tabular")"

echo
if [ "$fail" -ne 0 ]; then
  echo "check_lonja_type: FAIL — review the hits above." >&2; exit 1
fi
echo "check_lonja_type: OK ($TARGET)"
