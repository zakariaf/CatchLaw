#!/usr/bin/env bash
set -euo pipefail
# check_lonja_verdict.sh — proves the result surface states facts, cites them, and never hides them.
# Usage: scripts/check_lonja_verdict.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# The verdict screen is the one with legal exposure: an imperative turns a statement of law into
# advice, an uncited verdict is an opinion, and a disclaimer behind a flag is a disclaimer someone
# turns off in a hotfix. None of these fail at runtime and none are caught by the analyzer, so they
# are caught here. Heuristic greps, not a compiler — passing is a floor, not proof.
# Escape hatch: a trailing `// lonja-verdict-ok` on a Dart line that is provably not a verdict
# string. ARB values are NEVER exempt, and nothing else is exempt.
#
# Checks:
#   1. An imperative opening a Dart string literal (keep / return / throw / put it back …)
#   2. A banned verdict phrase inside any quoted Dart string, case-insensitive, word-bounded
#   3. The same lexicon in every ARB locale, including app_ar.arb — never exemptible
#   4. A public Verdict* widget class in a file with no citation slot
#   5. The disclaimer behind a conditional, a flag, or a dismiss path
#   6. Colour-only status encoding — a verdict-to-Color map with no glyph in the same file
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "check_lonja_verdict: target dir '$TARGET' not found" >&2
  exit 2
fi
GEN_RE='\.(g|freezed|drift|gr)\.dart(:|$)|app_localizations' # matches `f.g.dart` and `f.g.dart:9:`
OK_RE='lonja-verdict-ok'
fail=0
report() {
  local label="$1" hits="$2"
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}
echo "== check_lonja_verdict @ $TARGET =="

# The banned lexicon, shared by the Dart and the ARB passes. Case-insensitive, word-bounded.
LEAD='(keep|return|release|discard|throw|toss|retain|land|put)\b'
PHRASE='\b((throw|toss|put|chuck)[[:space:]]+(it|them|this)[[:space:]]+back'
PHRASE="$PHRASE"'|(keep|return|release|discard|retain|land|take)[[:space:]]+(it|them)\b'
PHRASE="$PHRASE"'|do[[:space:]]+not[[:space:]]+(keep|land|take|retain|return)\b'
PHRASE="$PHRASE"'|(you|it)[[:space:]]+(can|may|must|should)[[:space:]]+(be[[:space:]]+)?(kept|returned|released|landed|retained|thrown)\b'
PHRASE="$PHRASE"'|(safe|ok|okay|legal)[[:space:]]+to[[:space:]]+(keep|land|take))'

# 1. An imperative opening a Dart string literal — 'Keep', "Return", 'Throw it back', 'Put it back'.
report "imperative opening a Dart string literal (state the fact and the shortfall instead)" \
  "$(grep -rniE "['\"]${LEAD}" \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"

# 2. A banned phrase anywhere inside a quoted Dart string. The quote filter keeps `return this;`
#    and other ordinary control flow out of the hits.
report "banned verdict phrase in Dart (wording is owned by catchlaw-verdict-contract)" \
  "$(grep -rniE "$PHRASE" --include='*.dart' "$TARGET" | grep -E "['\"]" \
      | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"

# 3. The same lexicon in every ARB locale; an ARB value can NEVER be exempted, not even with the
#    escape hatch — a translated imperative is the same liability in six languages.
report "banned verdict phrase in ARB (every locale, incl. app_ar.arb)" \
  "$(grep -rniE "$PHRASE" --include='*.arb' "$TARGET" || true)"
report "imperative opening an ARB value" \
  "$(grep -rniE "\": *\"${LEAD}" --include='*.arb' "$TARGET" || true)"

# 4. A public verdict surface must take a citation. Private sub-widgets (_VerdictStamp) are exempt.
uncited=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if ! grep -qiE 'citation' "$f"; then
    uncited="${uncited}${f}: declares a verdict surface with no citation slot"$'\n'
  fi
done <<EOF
$(grep -rlE 'class [A-Za-z0-9]*(Verdict|Result)[A-Za-z0-9]*(Panel|Screen|Page|Sheet|View|Card|Body)\b' \
    --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)
EOF
report "verdict widget with no citation (Citation must be a required, non-null field)" "${uncited%$'\n'}"

# 5. The disclaimer is structural: no flag, no ternary, no Visibility, no dismiss.
report "disclaimer behind a conditional (make it an unconditional const child)" \
  "$(grep -rnE '(show|hide|dismiss|toggle|suppress)[A-Za-z0-9_]*Disclaimer|[A-Za-z0-9_]*Disclaimer[A-Za-z0-9_]*(Visible|Dismissed|Enabled|Shown|Hidden)|if *\([^)]*\) *(const )?[A-Za-z0-9_]*Disclaimer|\? *(const )?[A-Za-z0-9_]*Disclaimer|Visibility\([^)]*Disclaimer' \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"

# 6. A category-to-Color map with no glyph beside it is a colour-only encoding.
colouronly=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if grep -qE 'Color\(|Colors\.|Color\b' "$f" && ! grep -qE 'IconData|Icons\.' "$f"; then
    colouronly="${colouronly}${f}: verdict state mapped to colour with no glyph in the file"$'\n'
  fi
done <<EOF
$(grep -rlE 'VerdictCategory|VerdictStatus|verdictColor|statusColor' \
    --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)
EOF
report "colour-only status encoding (glyph + word + colour, always)" "${colouronly%$'\n'}"

echo
if [ "$fail" -ne 0 ]; then
  echo "check_lonja_verdict: FAIL — review the hits above." >&2; exit 1
fi
echo "check_lonja_verdict: OK ($TARGET)"
