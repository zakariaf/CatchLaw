#!/usr/bin/env bash
# no_directional_geometry.sh — reject physical-side geometry in hand-authored Dart.
#
# D-8. SPEC.md §9.3 calls this "a lint rule"; there is no such rule in
# package:lints, in flutter_lints, or in the analyzer's built-in set, and a
# custom analyzer plugin to enforce one line is disproportionate. So it is a
# grep, and calling it a lint would send the next builder looking for a rule
# name that was never published.
#
# A physical `left` inset is a bug that manifests in one locale out of six and
# will never be caught by a test running in `en` (FLUTTER_GUIDE.md §9.2).
#
# Usage: tools/gates/no_directional_geometry.sh <target-dir>
#   Always pass the target. D-1: a bare default scans the wrong tree, silently.
#
# Exit codes:
#   0  clean, and it says how many Dart files it read
#   1  a hit, or ZERO Dart files scanned — a gate that scans nothing must not
#      report success (CONVENTIONS.md §7)
#   2  the target directory does not exist
#
# Escape hatch: a trailing `// catchlaw-directional-ok` on the single offending
# line, with a comment saying why. Exactly one hatch, per CONVENTIONS.md §7, and
# its only sanctioned user is E09's ruler — SPEC.md §9.3's one exception, which
# must not mirror. Never widen the patterns to make a build pass.
#
# Generated Dart is skipped: *.g.dart, *.freezed.dart and app_localizations*.dart
# are not hand-authored, and flagging them would make the gate unfixable.
set -euo pipefail

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  echo "FAIL: no target directory given — pass one explicitly (D-1)" >&2
  exit 2
fi
if [[ ! -d "$TARGET" ]]; then
  echo "FAIL: target dir not found: $TARGET" >&2
  exit 2
fi

# The files this gate is willing to speak about.
#
# A read loop and not `mapfile`: macOS ships bash 3.2, where mapfile does not
# exist, and a gate that only runs on the CI image is a gate nobody runs before
# pushing.
FILES=()
while IFS= read -r f; do
  FILES+=("$f")
done < <(
  find "$TARGET" -type f -name '*.dart' \
    ! -name '*.g.dart' ! -name '*.freezed.dart' ! -name 'app_localizations*.dart' \
    | sort
)

echo "== no_directional_geometry @ $TARGET =="
echo "scanned ${#FILES[@]} dart files"

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "FAIL: no hand-authored Dart under $TARGET — a scan over nothing is not evidence" >&2
  exit 1
fi

status=0

# $1 = label, $2 = extended regex.
#
# Two filters, and both earn their place:
#
#   * a line carrying the hatch is dropped, so the marker exempts its own line
#     and nothing else;
#   * a COMMENT-ONLY line is dropped. app.dart's doc comment explains why no
#     Directionality is constructed by naming the construct, and a scan that
#     cannot tell a prohibition from its rationale forces the rationale out of
#     the file — which is how a rule survives as a regex and dies as knowledge.
#     A trailing comment after real code is untouched, because the code half
#     still matches.
#
# -H so the filename is always printed, even for a single-file scan: a gate that
# fails without naming the file is a gate nobody can act on.
scan() {
  local label="$1" pattern="$2" hits
  hits="$(grep -HnE "$pattern" "${FILES[@]}" 2>/dev/null \
    | grep -v 'catchlaw-directional-ok' \
    | grep -vE '^[^:]+:[0-9]+:[[:space:]]*(//|\*)' || true)"
  if [[ -n "$hits" ]]; then
    status=1
    echo "== BANNED: $label =="
    echo "$hits"
    echo
  fi
}

# EdgeInsets.fromLTRB is banned OUTRIGHT, including the symmetric case a regex
# cannot distinguish. EdgeInsets.symmetric says the symmetric thing better, and
# a hatch on every harmless site trains people to add the marker without reading
# it.
scan "physical EdgeInsets — use EdgeInsetsDirectional.only(start:, end:) or .fromSTEB" \
  'EdgeInsets\.only\([^)]*(left|right):|EdgeInsets\.fromLTRB\('

scan "physical Alignment — use AlignmentDirectional.centerStart / .topStart / …" \
  'Alignment\.(center|top|bottom)(Left|Right)'

scan "physical Positioned — use PositionedDirectional(start:, end:)" \
  'Positioned\((.*,)?[[:space:]]*(left|right):'

scan "physical TextAlign — use TextAlign.start / .end" \
  'TextAlign\.(left|right)'

scan "physical BorderRadius — use BorderRadiusDirectional.only(topStart:, …)" \
  'BorderRadius\.only\([^)]*(topLeft|topRight|bottomLeft|bottomRight):'

scan "non-adaptive directional icon — use Icons.adaptive.arrow_back / .arrow_forward" \
  'Icons\.arrow_(back|forward)([^_]|$)'

# A hardcoded root Directionality makes every physical-side bug LOOK correct and
# breaks any LTR island. Direction is a consequence of the resolved locale
# reaching GlobalWidgetsLocalizations, and of nothing else.
scan "constructed Directionality — direction is a consequence of the locale (SPEC.md §9.3)" \
  'Directionality\('

if [[ "$status" -eq 0 ]]; then
  echo "no_directional_geometry: OK ($TARGET)"
else
  echo "no_directional_geometry: FAIL ($TARGET)"
fi
exit "$status"
