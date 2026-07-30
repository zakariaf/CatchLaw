#!/usr/bin/env bash
set -euo pipefail
# check_measurement.sh — proves a length is an integer of millimetres carrying its method, and that
# no painter tries to read or fake a text direction.
# Usage: scripts/check_measurement.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# Every failure here is silent. A double length rounds under the 45 cm limit on one device and over
# it on another. A bare "38 cm" renders perfectly and is read as the wrong method. A painter that
# calls Directionality.of() reads a tree it is not painting, and Matrix4.rotationY(pi) ships every
# glyph backwards only in the locale nobody screenshots. Heuristic greps plus one awk brace-scan,
# not a compiler — passing this is a floor, not proof the ruler is accurate. It does NOT measure
# accuracy, and it cannot see a method that is present but wrong. The ONLY escape hatch is a trailing
# `// measurement-ok` on the offending line; the plausibility-band constants carry it deliberately,
# and nothing else is exempt.
#
# Checks:
#   1. A length declared as double or String (or drift real()/text()) instead of int millimetres
#   2. A measurement rendered with a bare mm/cm literal instead of formatMeasurement
#   3. Directionality or a *.of(context) lookup inside a class extending CustomPainter
#   4. Matrix4.rotationY anywhere (use canvas.scale(-1, 1) + translate)
#   5. A hardcoded px-per-mm constant, or millimetres derived from devicePixelRatio
#   6. MeasurementMethod declared on a species type instead of on the rule row
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "check_measurement: target dir '$TARGET' not found" >&2
  exit 2
fi
GEN_RE='\.g\.dart$|\.freezed\.dart$|\.drift\.dart$|\.gr\.dart$'
# grep -rn emits "path:line:text", so the filename anchors above become ":" boundaries.
GEN_LINE_RE="${GEN_RE//'$'/:}"
HATCH_RE='measurement-ok'
fail=0
report() {
  local label="$1" hits="$2"
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}
echo "== check_measurement @ $TARGET =="

# 1. Millimetres are integers. A double drifts, a localised string is uncomparable.
#    Names ending in Px/Pixels are exempt: a raw pixel span is legitimately a double.
report "length held as double/String (store int lengthMm)" \
  "$({ grep -rnE '(double|String)[[:space:]]+[a-zA-Z_]*[Ll]ength[a-zA-Z_]*[[:space:]]*[;=,)]' --include='*.dart' "$TARGET" || true
       grep -rnE '[a-zA-Z_]*[Ll]ength(Cm|Metres|Meters|Inches)\b' --include='*.dart' "$TARGET" || true
       grep -rnE '(RealColumn|TextColumn)[[:space:]]+get[[:space:]]+[a-zA-Z_]*[Ll]ength' --include='*.dart' "$TARGET" || true; } \
     | grep -vE "$GEN_LINE_RE" | grep -vE '[Ll]ength(Px|Pixels)\b' | grep -v "$HATCH_RE" | sort -u)"

# 2. A number without its method is a defect, not a shortcut.
report "bare mm/cm literal (print via formatMeasurement with its method)" \
  "$(grep -rnE "['\"][^'\"]*[[:space:]](mm|cm)\b" --include='*.dart' "$TARGET" \
     | grep -vE "$GEN_LINE_RE" | grep -vE 'formatMeasurement|MeasurementMethod|method' | grep -v "$HATCH_RE" || true)"

# 3. A CustomPainter has no BuildContext; textDirection is a constructor field. Scans the body of
#    every `extends CustomPainter` class by brace depth, so a view in the same file is not a hit.
report "direction read inside a CustomPainter (pass labelDirection in, compare in shouldRepaint)" \
  "$(find "$TARGET" -name '*.dart' -type f -print0 | xargs -0 awk '
       FNR == 1 { inp = 0; depth = 0 }
       /class[ \t]+[A-Za-z_0-9]+[^{]*extends[ \t]+CustomPainter/ { inp = 1; depth = 0 }
       inp {
         if ($0 !~ /^[ \t]*\/\// && $0 ~ /Directionality|TextDirection\.of\(|Theme\.of\(|MediaQuery\.of\(/)
           print FILENAME ":" FNR ":" $0
         n = gsub(/\{/, "{"); m = gsub(/\}/, "}"); depth += n - m
         if (depth <= 0 && n + m > 0) inp = 0
       }' 2>/dev/null | grep -vE "$GEN_LINE_RE" | grep -v "$HATCH_RE" || true)"

# 4. Zero framework precedent, and it mirrors every glyph it touches.
report "Matrix4.rotationY (use canvas.scale(-1, 1) + translate, text after restore)" \
  "$(grep -rnE 'Matrix4\.rotationY' --include='*.dart' "$TARGET" | grep -vE "$GEN_LINE_RE" | grep -v "$HATCH_RE" || true)"

# 5. Physical DPI is not knowable from Flutter; a constant scale is a saved 40% error.
report "hardcoded px-per-mm or DPI arithmetic (calibrate against the ID-1 card)" \
  "$({ grep -rniE '[a-zA-Z_]*pxPerMm[a-zA-Z_]*[[:space:]]*=[[:space:]]*[0-9]' --include='*.dart' "$TARGET" || true
       grep -rnE 'devicePixelRatio[^;]*(25\.4|160)|(25\.4|160)[^;]*devicePixelRatio' --include='*.dart' "$TARGET" || true; } \
     | grep -vE "$GEN_LINE_RE" | grep -v "$HATCH_RE" | sort -u)"

# 6. The same fish is measured differently in two countries: the method is a rule column.
report "measurement method on a species type (it belongs to the rule row)" \
  "$(grep -rnE 'MeasurementMethod' --include='*species*.dart' "$TARGET" | grep -vE "$GEN_LINE_RE" | grep -v "$HATCH_RE" || true)"

echo
if [ "$fail" -ne 0 ]; then
  echo "check_measurement: FAIL — review the hits above." >&2; exit 1
fi
echo "check_measurement: OK ($TARGET)"
