#!/usr/bin/env bash
set -euo pipefail
# check_lonja_lists.sh — proves every list is lazy, every divider is a token, and every list has an authored empty state.
# Usage: scripts/check_lonja_lists.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# The silent failure this catches: a list screen that renders nothing when the query returns zero
# rows. A blank frame is indistinguishable from a crash to a fisher with no signal, and a blank
# golden passes review. It also catches eager ListView( over a dynamic list, which builds all 3,180
# rule-pack entries at once, and raw colours smuggled into a Divider, which will not follow night or
# sunlight mode. Heuristic greps, not a compiler: multi-line constructors and indirection defeat it,
# and passing this is a floor, not proof. The ONE escape hatch is a trailing line comment
# // lonja-list-ok on any line of a file that legitimately cannot show an empty state (a fixed-length
# list built at compile time). Nothing else is exempt.
#
# Checks:
#   1. ListView( / GridView( / CustomScrollView with a non-const children: list — use .builder or slivers
#   2. Divider / VerticalDivider carrying a raw Color(0x..) or Colors.* instead of a LonjaRules BorderSide
#   3. A file that builds a lazy list but references no empty-state widget
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "check_lonja_lists: target dir '$TARGET' not found" >&2
  exit 2
fi
# Matches both `grep -l` output (bare path) and `grep -n` output (path:line:...).
GEN_RE='\.(g|freezed|drift|gr)\.dart(:|$)'
fail=0
report() {
  local label="$1" hits="$2"
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}
echo "== check_lonja_lists @ $TARGET =="

# 1. Eager list construction. ListView.builder / .separated / .custom do not match this needle.
report "eager list constructor (use ListView.builder, ListView.separated or slivers)" \
  "$(grep -rnE '(^|[^.[:alnum:]_])(ListView|GridView)\(' --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)"

# 2. A token value copied by hand into a Material divider.
report "Divider with a raw colour (use a LonjaRules BorderSide on the row itself)" \
  "$(grep -rn -A3 -E '(^|[^.[:alnum:]_])(Divider|VerticalDivider)\(' --include='*.dart' "$TARGET" \
     | grep -vE "$GEN_RE" | grep -E 'color:[[:space:]]*(const[[:space:]]+)?(Color\(0x|Colors\.)' || true)"

# 3. A lazy list with no authored empty state anywhere in the file.
list_files="$(grep -rlE '(ListView\.(builder|separated|custom)|SliverChildBuilderDelegate)' \
  --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)"
missing=""
if [ -n "$list_files" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if grep -q 'lonja-list-ok' "$f"; then continue; fi
    if ! grep -qE 'EmptyState|LonjaEmpty|emptyState|emptyBuilder|isEmpty[[:space:]]*\?' "$f"; then
      [ -z "$missing" ] || missing="${missing}"$'\n'
      missing="${missing}${f}: builds a lazy list but references no empty state"
    fi
  done <<LIST_EOF
$list_files
LIST_EOF
fi
report "list screen with no authored empty state (rule 6 — a blank screen is a defect)" "$missing"

echo
if [ "$fail" -ne 0 ]; then
  echo "check_lonja_lists: FAIL — review the hits above." >&2; exit 1
fi
echo "check_lonja_lists: OK ($TARGET)"
