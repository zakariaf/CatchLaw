#!/usr/bin/env bash
set -euo pipefail
# check_lonja_buttons.sh — proves the Lonja action ladder holds across the widget tree.
# Usage: scripts/check_lonja_buttons.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# Every failure this gate catches is silent at runtime: a second primary action just looks
# like a busier screen, an unlabelled icon button just reads as "button" to TalkBack, an
# elevated button just looks slightly wrong, and a 'Keep' label is a legal exposure nobody
# will file a bug for. Heuristic greps, not a compiler — passing this is a floor, not proof.
# The ONLY exemption is a trailing `// lonja-button-ok` on the offending line; nothing else.
#
# Checks:
#   1. Raw Material/Cupertino button constructors outside lib/theme/ and lib/ui/core/
#   2. More than one primary action built in a single file
#   3. Icon-only buttons with no semanticLabel and no tooltip
#   4. Labels that name no consequence (OK, Yes, Submit, Continue, Done, Confirm, Retry)
#   5. Labels that instruct the fisher about the fish (Keep, Return, Throw it back, Discard)
#   6. Elevation, shadow, or a corner radius above 2dp in any *button*.dart
#   7. FloatingActionButton and CircularProgressIndicator anywhere in an action
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "check_lonja_buttons: target dir '$TARGET' not found" >&2
  exit 2
fi
GEN_RE='\.g\.dart$|\.freezed\.dart$|\.drift\.dart$|\.gr\.dart$'
CORE_RE='/(theme|ui/core)/'
OK_RE='lonja-button-ok'
fail=0
report() {
  local label="$1" hits="$2"
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}
echo "== check_lonja_buttons @ $TARGET =="

# 1. Only lib/theme/ and lib/ui/core/ may name a raw Material button.
report "raw Material button outside theme/core (use LonjaButton / LonjaIconButton)" \
  "$(grep -rnE '(ElevatedButton|FilledButton|OutlinedButton|TextButton|MaterialButton|CupertinoButton)\(' \
     --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -vE "$CORE_RE" | grep -vE "$OK_RE" || true)"

# 2. One primary action per screen; the ladder does the ranking, not the fisher.
report "more than one primary action in one file (demote to secondary or quiet)" \
  "$(grep -rlE 'LonjaButton\.primary\(|LonjaButtonVariant\.primary' --include='*.dart' "$TARGET" \
     | grep -vE "$GEN_RE" | grep -vE "$CORE_RE" | while read -r f; do
         n="$(grep -cE 'LonjaButton\.primary\(|LonjaButtonVariant\.primary' "$f" || true)"
         if [ "${n:-0}" -gt 1 ]; then echo "$f: $n primary actions"; fi
       done || true)"

# 3. An icon with no accessible name is silent to TalkBack and VoiceOver.
report "icon-only button without semanticLabel/tooltip (add semanticLabel:)" \
  "$(find "$TARGET" -name '*.dart' -type f | grep -vE "$GEN_RE" | while read -r f; do
       awk -v F="$f" '
         /(LonjaIconButton|IconButton)\(/ { s=NR; buf=""; c=1 }
         c { buf = buf " " $0
             if (NR - s >= 8 || /\)[,;][[:space:]]*$/) {
               if (buf !~ /semanticLabel:/ && buf !~ /tooltip:/)
                 print F ":" s ": icon button with no accessible name"
               c=0 } }
       ' "$f"
     done || true)"

# 4. A label that names no consequence forces a re-read with a live fish in the bin.
WEAK_RE="label: *'(OK|Ok|Yes|No|Submit|Continue|Next|Done|Confirm|Retry|Go|Apply)'"
report "label names no consequence (use a verb phrase naming the object)" \
  "$(grep -rnE "$WEAK_RE" --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)"

# 5. The app states a fact; it never instructs. This one is a legal exposure, not a nit.
ADVICE_RE="label: *'(keep|return|throw it back|throw back|discard|land it|release it)'"
report "label instructs the fisher about the fish (BANNED — state the fact instead)" \
  "$(grep -rnEi "$ADVICE_RE" --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)"

# 6. A stamp is printed onto paper; it does not float above it.
report "shadow/elevation/radius above 2dp on a button (radius 0, elevation 0)" \
  "$(grep -rnE 'elevation: *(WidgetStatePropertyAll\()?[1-9]|BoxShadow\(|BorderRadius\.circular\( *([3-9]|[1-9][0-9])' \
     --include='*button*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -vE "$OK_RE" || true)"

# 7. No FAB (it floats and it is round) and no spinner (there is no network).
report "FloatingActionButton or in-button spinner (use a bottom primary / a busy latch)" \
  "$(grep -rnE 'FloatingActionButton|CircularProgressIndicator' --include='*.dart' "$TARGET" \
     | grep -vE "$GEN_RE" | grep -vE "$OK_RE" || true)"

echo
if [ "$fail" -ne 0 ]; then
  echo "check_lonja_buttons: FAIL — review the hits above." >&2; exit 1
fi
echo "check_lonja_buttons: OK ($TARGET)"
