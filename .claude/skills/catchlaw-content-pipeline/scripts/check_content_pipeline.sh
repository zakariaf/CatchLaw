#!/usr/bin/env bash
set -euo pipefail
# check_content_pipeline.sh — proves the authored content and its build tool cannot ship a row
# that the build assertions would have rejected.
# Usage: scripts/check_content_pipeline.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/;
#        pass . to cover content/, tools/ and packages/ as well)
#
# Every failure here is silent: a *_key with no content_string row renders a blank line under
# the verdict stamp, a citation with no retrieved_on prints a footnote that claims a check
# nobody made, an unattributable plate ships an infringement, and a second normalise() makes
# Arabic search return nothing at all. Heuristic greps, not a compiler — this is a floor, not
# proof; the real gate is `dart run content_builder:build`. The ONLY exemption is a trailing
# `content-pipeline-ok` comment on the offending line (// in Dart, # in YAML); nothing else.
#
# Checks:
#   1. A *_key referenced in YAML or Dart with no matching content_string definition
#   2. A citation block carrying an instrument but no retrieved_on
#   3. A plate block with no illustrator or no illustrator_death_year
#   4. Normalisation reimplemented outside packages/shared (or the shared package)
#   5. A min_size / max_size block with no measurement_method
#   6. A legal_text.* id keyed into the translatable content_string table
#   7. A publication-date licence test (the US pre-1930 rule) anywhere in the tree
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "check_content_pipeline: target dir '$TARGET' not found" >&2
  exit 2
fi
GEN_RE='\.g\.dart$|\.freezed\.dart$|\.drift\.dart$|\.gr\.dart$'
SHARED_RE='packages/shared/|/catchlaw_shared/'
OK_RE='content-pipeline-ok'
fail=0
report() {
  local label="$1" hits="$2"
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}
echo "== check_content_pipeline @ $TARGET =="

# 1. A key nobody defined is a blank line under the stamp, and blank is not a verdict.
#    Definitions live anywhere a content_string row is authored; references are `*_key: value`.
DEFS="$(grep -rhoE "^[[:space:]]*(- )?key:[[:space:]]*[\"']?[A-Za-z0-9_.-]+" \
        --include='*.yaml' --include='*.yml' "$TARGET" 2>/dev/null \
        | sed -E "s/.*key:[[:space:]]*[\"']?//" | sort -u || true)"
report "a *_key is referenced but never defined as a content_string key" \
  "$(grep -rnE "[a-z_]+_key:[[:space:]]*[\"']?[A-Za-z0-9_.-]+" \
       --include='*.yaml' --include='*.yml' --include='*.dart' "$TARGET" 2>/dev/null \
     | grep -vE "$GEN_RE" | grep -vE "$OK_RE" \
     | while IFS= read -r hit; do
         k="$(printf '%s' "$hit" | sed -E "s/.*_key:[[:space:]]*[\"']?([A-Za-z0-9_.-]+).*/\1/")"
         if ! printf '%s\n' "$DEFS" | grep -qxF "$k"; then echo "$hit"; fi
       done || true)"

# 2. retrieved_on is the footnote's claim that a human opened the gazette. It is authored.
report "citation with no retrieved_on (add the date a human read the gazette)" \
  "$(find "$TARGET" \( -name '*.yaml' -o -name '*.yml' \) -type f 2>/dev/null | while read -r f; do
       awk -v F="$f" '
         /^[[:space:]]*-[[:space:]]*id:/ { if (blk && want && !got) print F ":" s ": " id;
                                           blk=1; want=0; got=0; s=NR;
                                           id=$0; sub(/^[^:]*:[[:space:]]*/, "", id); next }
         /instrument:|article:/ { want=1 }
         /retrieved_on:/       { got=1 }
         END { if (blk && want && !got) print F ":" s ": " id }
       ' "$f"
     done || true)"

# 3. An unidentifiable illustrator can never be cleared, so the plate is DROPPED — not pending.
report "plate with no illustrator / illustrator_death_year (DROP it, do not flag it)" \
  "$(find "$TARGET" \( -name '*plate*.yaml' -o -name '*plate*.yml' \) -type f 2>/dev/null \
     | while read -r f; do
         awk -v F="$f" '
           /^[[:space:]]*-[[:space:]]*id:/ { if (blk && !(who && when) && !orig) print F ":" s;
                                             blk=1; who=0; when=0; orig=0; s=NR; next }
           /illustrator:[[:space:]]*[^[:space:]]/ { if ($0 !~ /unknown|unidentified|TBD/) who=1 }
           /illustrator_death_year:[[:space:]]*[0-9]/ { when=1 }
           /origin:[[:space:]]*originated/ { orig=1 }
           END { if (blk && !(who && when) && !orig) print F ":" s }
         ' "$f"
       done || true)"

# 4. Two normalisers means the index and the query disagree, and Arabic search returns nothing.
NORM_RE='(String[[:space:]]+(normalise|normalize|normalizeForSearch|stripDiacritics|foldArabic)[[:space:]]*\()|(searchNorm[[:space:]]*=[[:space:]]*[a-zA-Z_.]*\.(toLowerCase|replaceAll)\()'
report "normalisation reimplemented outside the shared package (import normalise() instead)" \
  "$(grep -rnE "$NORM_RE" --include='*.dart' "$TARGET" 2>/dev/null \
     | grep -vE "$GEN_RE" | grep -vE "$SHARED_RE" | grep -vE "$OK_RE" || true)"

# 5. "45 cm" measured how? TL and FL differ by 6-9 cm on a Kanaad.
report "min_size/max_size block with no measurement_method (TL, FL, CW or SHL)" \
  "$(find "$TARGET" \( -name '*.yaml' -o -name '*.yml' \) -type f 2>/dev/null | while read -r f; do
       awk -v F="$f" '
         /^[[:space:]]*-[[:space:]]*id:/ { if (blk && sz && !mm) print F ":" s;
                                           blk=1; sz=0; mm=0; s=NR; next }
         /(min_size|max_size):[[:space:]]*[0-9]/ { sz=1 }
         /measurement_method:[[:space:]]*(TL|FL|CW|SHL)/ { mm=1 }
         END { if (blk && sz && !mm) print F ":" s }
       ' "$f"
     done || true)"

# 6. Verbatim penal text is single-locale. A translation of it is a liability, not a feature.
report "legal_text.* keyed into the translatable content_string table (bundle it single-locale)" \
  "$(grep -rnE "(key|content_key|string_key):[[:space:]]*[\"']?legal_text[._]" \
       --include='*.yaml' --include='*.yml' --include='*.dart' "$TARGET" 2>/dev/null \
     | grep -vE "$GEN_RE" | grep -vE "$OK_RE" || true)"

# 7. "Pre-1930 is public domain" is the US rule and clears nothing in ES, BR or AE.
report "publication-date licence test (use the illustrator death-year test)" \
  "$(grep -rnE '(published_?[Yy]ear|publication_?year|pub_?year)[^A-Za-z0-9]{0,4}[<>][^=]?[[:space:]]*(19[0-9]{2}|20[0-9]{2})' \
       --include='*.dart' --include='*.yaml' --include='*.yml' "$TARGET" 2>/dev/null \
     | grep -vE "$GEN_RE" | grep -vE "$OK_RE" || true)"

echo
if [ "$fail" -ne 0 ]; then
  echo "check_content_pipeline: FAIL — review the hits above." >&2; exit 1
fi
echo "check_content_pipeline: OK ($TARGET)"
