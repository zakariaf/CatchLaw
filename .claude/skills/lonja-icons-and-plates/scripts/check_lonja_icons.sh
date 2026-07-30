#!/usr/bin/env bash
set -euo pipefail
# check_lonja_icons.sh — proves the UI is drawn with ONE authored stroked icon family, no emoji,
# no unlabelled glyphs, and no under-resolution rasters.
# Usage: scripts/check_lonja_icons.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# These four failures are silent: an emoji renders fine on the author's machine and is announced
# six different ways across six locales; a Material glyph looks "close enough" in a screenshot but
# is filled where everything else is stroked; an unlabelled Icon is announced as "image" only to a
# screen-reader user; and a 1x PNG only looks wrong on a 3x device. Heuristic greps, not a compiler
# — a passing run is a floor, not proof. The ONLY escape hatch is a trailing `// lonja-icon-ok`
# comment with a reason on the offending line; ARB values are NEVER exempt (there is no comment
# syntax inside JSON and no locale gets a waiver), and nothing else is exempt.
#
# Checks:
#   1. Emoji and colour-font dingbats in Dart source (UTF-8 byte-range heuristic)
#   2. The same lexicon in every ARB locale, app_ar.arb included — labels and plurals count
#   3. Raster assets referenced from Dart with no 2.0x/ and 3.0x/ sibling
#   4. Icon(/LonjaIcon( whose argument list has no semanticLabel and no Semantics ancestor above
#   5. Mixed icon families — Icons., CupertinoIcons., IconData(, and third-party icon packages
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "check_lonja_icons: target dir '$TARGET' not found" >&2
  exit 2
fi

# Matches both a bare filename and a `path:line:` prefix from grep -n.
GEN_RE='\.(g|freezed|drift|gr)\.dart(:|$)'
OK_RE='lonja-icon-ok'

fail=0
report() {
  local label="$1" hits="$2"
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}

echo "== check_lonja_icons @ $TARGET =="

# 1. Emoji and dingbats. U+1F300-1FAFF is F0 9F ..; U+2600-27BF and U+2B00-2BFF are E2 98-9D / E2 AD;
#    EF B8 8F is the U+FE0F variation selector. Bytes, so it works with BSD and GNU grep alike.
EMOJI_RE="$(printf '\xf0\x9f|\xe2\x98|\xe2\x99|\xe2\x9a|\xe2\x9b|\xe2\x9c|\xe2\x9d|\xe2\xad|\xef\xb8\x8f')"
report "emoji or dingbat in Dart source (use a LonjaIcons glyph)" \
  "$(LC_ALL=C grep -rnaE "$EMOJI_RE" --include='*.dart' "$TARGET" \
     | grep -vE "$GEN_RE" | grep -vE "$OK_RE" || true)"

# 2. The same bytes in ARB. A translator pasting an emoji into app_ar.arb ships a colour glyph
#    beside a AED 3,000 verdict, so no line here is exemptible.
report "emoji or dingbat in ARB (never exempt — every locale, incl. app_ar.arb)" \
  "$(LC_ALL=C grep -rnaE "$EMOJI_RE" --include='*.arb' "$TARGET" || true)"

# 3. Raster referenced from Dart with no 2.0x / 3.0x sibling.
raster_hits=""
while IFS= read -r ref; do
  [ -n "$ref" ] || continue
  dir="$(dirname "$ref")"; base="$(basename "$ref")"
  if [ ! -f "$dir/2.0x/$base" ] || [ ! -f "$dir/3.0x/$base" ]; then
    raster_hits="${raster_hits}${ref} (missing 2.0x/ or 3.0x/ sibling)
"
  fi
done <<EOF
$(grep -rhoE "'assets/[A-Za-z0-9_/.-]+\.(png|jpg|jpeg|webp)'" --include='*.dart' "$TARGET" \
    | tr -d "'" | sort -u || true)
EOF
report "raster asset without 2.0x/3.0x variants (rasters are banned in the UI)" \
  "$(printf '%s' "$raster_hits")"

# 4. Icon(/LonjaIcon( with neither a semanticLabel in its own argument list nor a Semantics/
#    ExcludeSemantics ancestor in the 3 lines above it. Only the FIRST such call on a line is
#    inspected, and a paren inside a string literal will confuse the scan — heuristic, not a parser.
sem_hits=""
while IFS= read -r -d '' f; do
  case "$f" in *.g.dart | *.freezed.dart | *.drift.dart | *.gr.dart) continue ;; esac
  hit="$(awk -v F="$f" '
    { L[NR] = $0 }
    END {
      for (i = 1; i <= NR; i++) {
        line = L[i]
        if (line ~ /lonja-icon-ok/) continue
        if (!match(line, /(^|[^A-Za-z0-9_])(Lonja)?Icon[ \t]*\(/)) continue
        # Walk the balanced argument list forward from the opening paren.
        args = ""; depth = 0; done = 0; j = i; pos = RSTART + RLENGTH - 1
        while (j <= NR && j < i + 40 && !done) {
          s = (j == i) ? substr(L[j], pos) : L[j]
          for (k = 1; k <= length(s); k++) {
            ch = substr(s, k, 1)
            if (ch == "(") depth++
            else if (ch == ")") { depth--; if (depth == 0) { done = 1; break } }
            args = args ch
          }
          args = args " "; j++
        }
        # An ExcludeSemantics/Semantics ancestor sits above the call.
        anc = ""; lo = (i - 3 > 1) ? i - 3 : 1
        for (m = lo; m <= i; m++) anc = anc " " L[m]
        if (args !~ /semanticLabel/ && anc !~ /ExcludeSemantics/ && anc !~ /Semantics[ \t]*\(/) {
          sub(/^[ \t]+/, "", line); printf "%s:%d:%s\n", F, i, line
        }
      }
    }' "$f" || true)"
  if [ -n "$hit" ]; then
    sem_hits="${sem_hits}${hit}
"
  fi
done < <(find "$TARGET" -name '*.dart' -type f -print0)
report "icon with no semanticLabel and no ExcludeSemantics (label it or exclude it)" \
  "$(printf '%s' "$sem_hits")"

# 5. Mixed icon families.
report "foreign icon family (every glyph comes from LonjaIcons)" \
  "$(grep -rnE '(^|[^A-Za-z0-9_])(Icons|CupertinoIcons|MdiIcons|FontAwesomeIcons)\.|IconData[ \t]*\(|package:(font_awesome_flutter|material_design_icons_flutter|flutter_vector_icons)/' \
     --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -vE "$OK_RE" || true)"

echo
if [ "$fail" -ne 0 ]; then
  echo "check_lonja_icons: FAIL — review the hits above." >&2; exit 1
fi
echo "check_lonja_icons: OK ($TARGET)"
