#!/usr/bin/env bash
set -euo pipefail
# check_lonja_nav.sh — proves the navigation chrome is translated, directional and frozen at five.
# Usage: scripts/check_lonja_nav.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# The three failures this catches are all silent: a hardcoded nav label renders English chrome in
# the Arabic build with no analyzer warning; a physical EdgeInsets.only(left:/right:) in a nav or
# chip widget puts the back affordance under the wrong thumb only when someone runs the app in
# Arabic; and a sixth destination merges cleanly, breaking the 56dp cell floor at 320dp and every
# thumb position learned in the dark. Heuristic greps, not a compiler — passing is a floor, not
# proof. The ONE escape hatch is a trailing line comment // lonja-nav-ok, for a string that is a
# proper noun in every locale (a species binomial, an instrument number). Nothing else is exempt,
# and no chrome label, tooltip or chip ever qualifies.
#
# Checks:
#   1. Hardcoded chrome strings — label:/tooltip:/semanticLabel: or Text() taking a literal, and
#      bare destination names, anywhere under TARGET_DIR.
#   2. Physical EdgeInsets.only(left:/right:) inside nav, app-bar, masthead, chrome or chip files
#      (selected by FILENAME, so no app-specific path is hardcoded).
#   3. Destination count — any enum whose name ends in Destination must declare exactly 5 values,
#      and any file using NavigationDestination( must use it exactly 5 times.
#   4. Floating-bar tells — elevation/shadow/indicatorShape/borderRadius on a NavigationBar, and
#      scrolledUnderElevation on an AppBar.
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped, as is app_localizations*.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "check_lonja_nav: target dir '$TARGET' not found" >&2
  exit 2
fi

GEN_RE='\.g\.dart$|\.freezed\.dart$|\.drift\.dart$|\.gr\.dart$|app_localizations.*\.dart$'
CHROME_INCLUDES=(--include='*nav*.dart' --include='*app_bar*.dart' --include='*appbar*.dart'
                 --include='*masthead*.dart' --include='*chrome*.dart' --include='*chip*.dart'
                 --include='*shell*.dart')

fail=0
report() {
  local label="$1" hits="$2"
  hits="$(printf '%s' "$hits" | grep -v 'lonja-nav-ok' || true)"
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}

echo "== check_lonja_nav @ $TARGET =="

# 1a. A label/tooltip/semanticLabel argument taking a string literal instead of an ARB lookup.
report "hardcoded chrome label (route it through AppLocalizations)" \
  "$(grep -rnE "(label|tooltip|semanticLabel|helpText):[[:space:]]*(const[[:space:]]+)?['\"]" \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)"

# 1b. A destination name written as a bare Text() literal.
report "hardcoded destination name in Text() (use l10n.navCheck etc.)" \
  "$(grep -rnE "Text\([[:space:]]*(const[[:space:]]+)?['\"](Check|Today|Trips|Reference|Settings|Back)['\"]" \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)"

# 2. Physical horizontal insets in chrome widgets (use EdgeInsetsDirectional / BorderDirectional).
report "physical inset in a chrome widget (use EdgeInsetsDirectional)" \
  "$(grep -rnE "EdgeInsets\.only\([^)]*(left|right):" \
      "${CHROME_INCLUDES[@]}" "$TARGET" | grep -vE "$GEN_RE" || true)"

# 3a. Any *Destination enum must declare exactly five values.
enum_hits="$(
  grep -rlE 'enum[[:space:]]+[A-Za-z0-9_]*Destination[A-Za-z0-9_]*[[:space:]]*\{' \
    --include='*.dart' "$TARGET" 2>/dev/null | grep -vE "$GEN_RE" || true
)"
enum_bad=""
if [ -n "$enum_hits" ]; then
  enum_bad="$(
    echo "$enum_hits" | while IFS= read -r f; do
      [ -n "$f" ] || continue
      awk '
        # Line comments are stripped per line: a trailing "// species search, ruler" would
        # otherwise contribute its comma to the count.
        function clean(s) { sub(/\/\/.*/, "", s); return s }
        function emit(b,   n, parts, i, c) {
          sub(/[};].*/, "", b)
          # Enhanced enums carry the outline/filled glyph pair as constructor arguments:
          # check(fish, fishFilled) is ONE destination, not two. Strip innermost parens
          # repeatedly so nested argument lists collapse before the split on commas.
          while (b ~ /\([^()]*\)/) gsub(/\([^()]*\)/, "", b)
          gsub(/[ \t\r]/, "", b)
          n = split(b, parts, ","); c = 0
          for (i = 1; i <= n; i++) if (parts[i] != "") c++
          if (c != 5) printf "%s:%d  %s declares %d destinations (expected exactly 5)\n",
                              FILENAME, hdr, name, c
        }
        inb { l = clean($0); body = body " " l; if (l ~ /[};]/) { inb = 0; emit(body) } ; next }
        /enum[ \t]+[A-Za-z0-9_]*Destination[A-Za-z0-9_]*[ \t]*\{/ {
          hdr = FNR; name = $2; gsub(/[^A-Za-z0-9_]/, "", name)
          body = clean($0); sub(/^[^{]*\{/, "", body)
          if (body ~ /[};]/) emit(body); else inb = 1
        }
      ' "$f" || true
    done
  )"
fi
report "destination enum is not frozen at five (rule 1)" "$enum_bad"

# 3b. A file that uses NavigationDestination must use it exactly five times.
dest_files="$(grep -rlE 'NavigationDestination\(' --include='*.dart' "$TARGET" 2>/dev/null \
                | grep -vE "$GEN_RE" || true)"
dest_bad=""
if [ -n "$dest_files" ]; then
  dest_bad="$(
    echo "$dest_files" | while IFS= read -r f; do
      [ -n "$f" ] || continue
      n="$(grep -cE 'NavigationDestination\(' "$f" || true)"
      if [ "$n" != "5" ]; then
        echo "$f  declares $n NavigationDestination entries (expected exactly 5)"
      fi
    done
  )"
fi
report "NavigationDestination count is not five (rule 1)" "$dest_bad"

# 4. Floating-bar and scrolled-under tells: the strip and masthead are printed, not layered.
report "floating nav bar tell (elevation/indicator/radius must be zero — rule 2)" \
  "$(grep -rnE '(elevation|indicatorShape|indicatorColor|borderRadius|shadowColor)[[:space:]]*:' \
      "${CHROME_INCLUDES[@]}" "$TARGET" \
      | grep -vE "$GEN_RE" \
      | grep -vE ':[[:space:]]*(0|0\.0|null|Colors\.transparent|BorderRadius\.zero)' || true)"

report "masthead lifts on scroll (set scrolledUnderElevation: 0 — rule 7)" \
  "$(grep -rnE 'scrolledUnderElevation[[:space:]]*:[[:space:]]*[1-9]' \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)"

echo
if [ "$fail" -ne 0 ]; then
  echo "check_lonja_nav: FAIL — review the hits above." >&2; exit 1
fi
echo "check_lonja_nav: OK ($TARGET)"
