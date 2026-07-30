#!/usr/bin/env bash
set -euo pipefail
# check_rule_engine.sh — proves the domain core stays pure, dateless, and never deletes an expired rule.
# Usage: scripts/check_rule_engine.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# Four silent failures live here. A Flutter import compiles in the app and breaks only the content
# CLI. A valid_to filter passes every test until the day a ruleset lapses, then quietly reports
# "no rule recorded" for every species in it. DateTime.now() makes closures untestable and flaps CI
# at midnight. A second copy of the normaliser drifts until Arabic search returns nothing.
# Heuristic greps, not a compiler — passing is a floor, not proof.
# Escape hatch: a trailing `// rule-engine-ok` on a Dart line. Nothing else is exempt.
#
# Checks:
#   1. package:flutter or dart:ui imported inside the pure domain package
#   2. valid_to / validTo used as a filter predicate instead of an isExpired tag
#   3. DateTime.now() inside the domain package instead of the injected clock
#   4. Arabic normalisation reimplemented outside the single normalise.dart
#   5. A pubspec.yaml for the domain package that declares a flutter dependency
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then echo "check_rule_engine: target dir '$TARGET' not found" >&2; exit 2; fi
GEN_RE='\.g\.dart$|\.freezed\.dart$|\.drift\.dart$|\.gr\.dart$'
OK_RE='rule-engine-ok'
# The pure domain core, by convention: a rule_engine package or a domain/ layer.
DOMAIN_RE='rule_engine|/domain/'
# The single sanctioned home of the normalisation contract.
NORM_RE='normalise\.dart$|normalize\.dart$'
fail=0
report() { local label="$1" hits="$2"; if [ -n "$hits" ]; then echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1; fi; }
echo "== check_rule_engine @ $TARGET =="

DOMAIN_FILES="$(find "$TARGET" -type f -name '*.dart' 2>/dev/null | grep -E "$DOMAIN_RE" | grep -vE "$GEN_RE" || true)"
if [ -z "$DOMAIN_FILES" ]; then
  echo "  note: no domain files matched /$DOMAIN_RE/ under '$TARGET' — checks 1-4 had nothing to read."
fi

# Matches on CODE only: a // comment tail is stripped before the test, so prose and deliberate
# WRONG illustrations never trip the gate, while the escape hatch is read from the original line.
dgrep() { # dgrep <pattern> [path-regex-to-exclude]
  local pattern="$1" skip="${2:-}" f
  [ -z "$DOMAIN_FILES" ] && return 0
  local files="$DOMAIN_FILES"
  if [ -n "$skip" ]; then files="$(echo "$files" | grep -vE "$skip" || true)"; fi
  [ -z "$files" ] && return 0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    pat="$pattern" ok="$OK_RE" path="$f" awk '
      BEGIN { pat = ENVIRON["pat"]; ok = ENVIRON["ok"]; path = ENVIRON["path"] }
      { code = $0; sub(/\/\/.*/, "", code)
        if (code ~ pat && $0 !~ ok) printf "%s:%d:%s\n", path, NR, $0 }' "$f"
  done <<EOF
$files
EOF
}

# 1. The package has no Flutter dependency, so this must be a compile error, never a live import.
report "Flutter or dart:ui imported into the pure domain package (use package:meta instead)" \
  "$(dgrep "^[[:space:]]*import[[:space:]]+['\"](package:flutter/|dart:ui)")"

# 2. Expiry TAGS a rule; it never removes one. isBefore() for isExpired is fine, isAfter() is a filter.
report "valid_to used as a filter (tag isExpired instead; never drop the row)" \
  "$(dgrep '(\.where\(|removeWhere|retainWhere|takeWhile|WHERE)[^;]*valid_?[Tt]o|valid_?[Tt]o[^;]*(isBiggerThan|isSmallerThan|isAfter\()')"

# 3. The evaluation date is a parameter, never a reading.
report "DateTime.now() in the domain package (take req.on from the injected Clock)" \
  "$(dgrep 'DateTime\.now\(\)')"

# 4. One normaliser, called by both the CLI indexer and the runtime query.
report "normalisation reimplemented outside normalise.dart (index and query keys will drift)" \
  "$(dgrep '(replaceAll|RegExp)\([^;]*(\\u06|ـ|آ|أ|إ|ٱ|ى|ة|ً|ٌ|ٍ|َ|ُ|ِ|ّ|ْ)|(String|_)[A-Za-z]*[Nn]ormali[sz]e[A-Za-z]*\(' "$NORM_RE")"

# 5. The guarantee behind check 1: no flutter dependency in the domain package's pubspec.
report "domain package pubspec declares a flutter dependency (it must not)" \
  "$(find . -type f -name 'pubspec.yaml' 2>/dev/null | grep -E "$DOMAIN_RE" \
      | while IFS= read -r f; do
          [ -z "$f" ] && continue
          if grep -qE '^[[:space:]]+flutter:[[:space:]]*$' "$f" && grep -qE '^[[:space:]]+sdk:[[:space:]]*flutter' "$f"; then
            echo "$f: declares an sdk: flutter dependency"
          fi
        done || true)"

echo
if [ "$fail" -ne 0 ]; then echo "check_rule_engine: FAIL — review the hits above." >&2; exit 1; fi
echo "check_rule_engine: OK ($TARGET)"
