#!/usr/bin/env bash
set -euo pipefail
# check_lonja_dialogs.sh — proves every modal in the tree is squared, barrier-explicit, typed and
# consequence-labelled.
# Usage: scripts/check_lonja_dialogs.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# The failures this catches are silent by construction: a showDialog<bool> compiles and ships, and
# its null branch quietly means "declined" on a destructive path; an "OK" button reads fine in
# English review and is unlabelled law in Arabic; a barrierDismissible left at the Flutter default
# is invisible in a diff. Heuristic greps, not a compiler — it cannot tell a destructive dialog from
# a benign one, so it judges by file and symbol names. The ONLY escape hatch is a trailing
# `// lonja-dialogs: allow` comment on the offending line; nothing else is exempt.
#
# Checks:
#   1. showDialog / showModalBottomSheet / showGeneralDialog outside a core dir or a *_dialog.dart
#   2. Modals typed as bool, or popped with a bare true/false
#   3. Banned button literals: OK, Cancel, Yes, No, Confirm, Dismiss
#   4. barrierDismissible: true on a destructive- or ambiguity-named surface
#   5. Elevation, shadow or radius on a Lonja dialog, sheet, panel or plate surface
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "check_lonja_dialogs: target dir '$TARGET' not found" >&2
  exit 2
fi
# Matches either a bare filename or a `path:line:` prefix in grep -rn output.
GEN_RE='\.(g|freezed|drift|gr)\.dart(:|$)'
ALLOW_RE='lonja-dialogs: allow'
fail=0
report() {
  local label="$1" hits="$2"
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}
echo "== check_lonja_dialogs @ $TARGET =="

report "modal opened outside core or a *_dialog.dart (move it, or wrap it in showLonjaDialog)" \
  "$(grep -rnE '\b(showDialog|showGeneralDialog|showModalBottomSheet)[<(]' --include='*.dart' "$TARGET" \
    | grep -vE "$GEN_RE" | grep -vE '/core/|_dialog\.dart:|_sheet\.dart:' | grep -vE "$ALLOW_RE" || true)"

report "modal result typed as bool (return an enum or a sealed AmbiguityChoice-style type)" \
  "$(grep -rnE '(showDialog|showGeneralDialog|showModalBottomSheet)<bool\??>|\.pop\([^)]*,[[:space:]]*(true|false)[[:space:]]*\)' \
    --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -vE "$ALLOW_RE" || true)"

report "banned button literal (name the consequence: 'Discard measurement', 'Keep it')" \
  "$(grep -rnE "'(OK|Ok|CANCEL|Cancel|YES|Yes|NO|No|Confirm|Dismiss)'" \
    --include='*_dialog.dart' --include='*_sheet.dart' --include='*.arb' "$TARGET" \
    | grep -vE "$GEN_RE" | grep -vE "$ALLOW_RE" || true)"

report "barrierDismissible: true on a destructive or ambiguity surface (must be false)" \
  "$(grep -rnE 'barrierDismissible:[[:space:]]*true|isDismissible:[[:space:]]*true' --include='*.dart' "$TARGET" \
    | grep -vE "$GEN_RE" | grep -iE 'delete|discard|destruct|ambigu|confirm|reset|erase|remove' \
    | grep -vE "$ALLOW_RE" || true)"

report "elevated or rounded Lonja surface (elevation: 0, BorderRadius.zero, no BoxShadow)" \
  "$(grep -rnE 'BoxShadow|elevation:[[:space:]]*[1-9]|BorderRadius\.(circular|only|vertical|horizontal)|showDragHandle:[[:space:]]*true|\bCard\(' \
    --include='*_dialog.dart' --include='*_sheet.dart' --include='*_panel.dart' --include='*_plate.dart' \
    --include='*_snackbar.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -vE "$ALLOW_RE" || true)"

echo
if [ "$fail" -ne 0 ]; then
  echo "check_lonja_dialogs: FAIL — review the hits above." >&2; exit 1
fi
echo "check_lonja_dialogs: OK ($TARGET)"
