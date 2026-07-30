#!/usr/bin/env bash
set -euo pipefail
# check_lonja_controls.sh — proves every input control is a ruled Lonja instrument, not Material chrome.
# Usage: scripts/check_lonja_controls.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# The failures this catches are silent: a raw TextField in a feature ships Material's 4dp radius,
# filled surfaceVariant ground and 48dp height, and nobody notices until a screenshot lands on a
# wet deck. Heuristic greps, not a compiler — it proves shape, never semantics, and passing it is a
# floor rather than proof. The ONE escape hatch is a trailing `// lonja-core-ok` on the offending
# line, for genuine primitives inside lib/ui/core/. Nothing else is exempt.
#
# Checks:
#   1. Raw Material input widgets constructed outside a ui/core directory.
#   2. BorderRadius/Radius.circular above 2 — paper has no pills; the only allowed radius is 2.
#   3. Hardcoded hit-target numbers where a LonjaTargets constant belongs.
#   4. InputDecoration(filled: true) and OutlineInputBorder — the filled box the ruled line replaces.
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "check_lonja_controls: target dir '$TARGET' not found" >&2
  exit 2
fi
GEN_RE='\.g\.dart$|\.freezed\.dart$|\.drift\.dart$|\.gr\.dart$'
CORE_RE='/ui/core/'
OK_RE='lonja-core-ok'
fail=0
report() {
  local label="$1" hits="$2"
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}
echo "== check_lonja_controls @ $TARGET =="

# 1. Material primitives belong to ui/core only; features compose the Lonja wrappers.
report "raw Material input outside ui/core (compose LonjaSearchField / LonjaSwitch / LonjaSegmented)" \
  "$(grep -rnE '(^|[^A-Za-z0-9_])(TextField|TextFormField|CupertinoTextField|SwitchListTile|Switch|SegmentedButton|Slider|CheckboxListTile|Checkbox|RadioListTile|Radio)\(' --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -vE "$CORE_RE" | grep -vE "$OK_RE" || true)"

# 2. A radius above 2 turns a printed rule into app chrome.
report "BorderRadius.circular above 2 (use BorderRadius.zero; LonjaChip alone may use 2)" \
  "$(grep -rnE '(BorderRadius|Radius)\.circular\(\s*([3-9]|[1-9][0-9]+|2\.[1-9])' --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -vE "$OK_RE" || true)"

# 3. Wet gloves need 56 / 66 from one source, never a literal sprinkled per screen.
report "hardcoded target size (read LonjaTargets.control / .gloveControl / .separation)" \
  "$(grep -rnE '(minHeight|minWidth|maxHeight|minimumSize|fixedSize)\s*:\s*(const\s+)?(Size(\.fromHeight|\.fromWidth|\.square)?\(\s*)?[0-9]' --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -vE 'LonjaTargets' | grep -vE "$OK_RE" || true)"

# 4. The filled rounded box is exactly what the ruled entry line replaces.
report "filled or outlined InputDecoration (use DecoratedBox + Border.all at 1.5 ink)" \
  "$(grep -rnE 'filled\s*:\s*true|OutlineInputBorder\(|UnderlineInputBorder\(' --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -vE "$OK_RE" || true)"

echo
if [ "$fail" -ne 0 ]; then
  echo "check_lonja_controls: FAIL — review the hits above." >&2; exit 1
fi
echo "check_lonja_controls: OK ($TARGET)"
