#!/usr/bin/env bash
set -euo pipefail
# no_banned_apis.sh — SPEC.md §14 static block, bullet 2, over an explicit target directory.
# Usage: tools/gates/no_banned_apis.sh <TARGET_DIR>          e.g. app/lib   (D-1)
#
# WHAT A HIT MEANS FOR THE USER, which is the only thing worth writing here:
# CatchLaw ships without android.permission.INTERNET, so the kernel refuses every socket
# whatever the Dart code says. A call site matched below is therefore not a bug that shows up
# as an error — it is a feature that works on the reviewer's desk, on wifi, during the demo,
# and is silently dead at 05:40 off Ras Al Khaimah where the app is actually used.
#
# The fifteen needles are SPEC.md §14's list and no sixteenth. A needle added here without a
# spec line behind it is a promise this gate has to keep forever with nothing to point at
# (ci-pipeline-and-gates rule 1). The maintained SUPERSET for authoring lives in
# .claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh, which this gate does
# not edit and does not replace: the two lists differ in both directions, and where they
# disagree §14 wins for the release gate because §14 is the list the release signs.
#
# Uri.parse is deliberately NOT banned. authority_url and citation.source_url are stored as
# URIs and printed as selectable text, never as links (SPEC.md §5.3).
#
# Comments are stripped before matching, because every needle below is also what somebody
# types when explaining why it is banned — including this header.
# Escape hatch: a trailing `// no-network-ok`, the same marker the other two layers honour.
# Allowed only for a false-positive identifier; never on an import and never on a real call.

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  echo "no_banned_apis: usage: $0 <TARGET_DIR>  (e.g. app/lib)" >&2; exit 2
fi
if [ ! -d "$TARGET" ]; then
  echo "no_banned_apis: target dir '$TARGET' not found" >&2; exit 2
fi

GEN_RE='\.g\.dart$|\.freezed\.dart$|\.drift\.dart$|\.gr\.dart$'
FILES="$(find "$TARGET" -type f -name '*.dart' 2>/dev/null | grep -vE "$GEN_RE" || true)"
if [ -z "$FILES" ]; then
  # CONVENTIONS.md §7: a gate that scans a path with no files reports success, which is the
  # failure mode that makes a gate worse than no gate. Closed here, at this gate's own source.
  echo "no_banned_apis: no .dart file under '$TARGET' — refusing to pass over an empty tree" >&2
  exit 2
fi

# label @@ extended-regex @@ reason. The delimiter is @@ and not | because several of the
# regexes contain an alternation of their own. Word boundaries are spelled out rather than
# written \b, which is not portable between BSD and GNU grep -E.
B='(^|[^A-Za-z0-9_])'
RULES=(
  "package:http@@^[[:space:]]*import[[:space:]]+['\"]package:http/@@an HTTP client"
  "package:dio@@^[[:space:]]*import[[:space:]]+['\"]package:dio/@@an HTTP client"
  "HttpClient@@${B}HttpClient@@an HTTP client from dart:io"
  "Socket@@${B}Socket@@a TCP socket (WebSocket has its own rule; socketPathLabel does not match)"
  "WebSocket@@${B}WebSocket@@a web socket"
  "firebase@@${B}firebase@@a Firebase SDK: a network call, an identifier and a consent problem"
  "connectivity_plus@@connectivity_plus@@implies a code path reacting to connectivity"
  "PdfGoogleFonts@@PdfGoogleFonts@@fetches a TTF; use pw.Font.ttf(rootBundle.load(...))"
  "SvgPicture.network@@SvgPicture\.network@@use SvgPicture.asset"
  "Image.network@@Image\.network@@use Image.asset with assets/plates/"
  "NetworkImage@@NetworkImage@@use AssetImage / rootBundle"
  "url_launcher@@url_launcher@@hands off to the browser, which fetches under its own permission"
  "launchUrl@@${B}launchUrl@@print the citation as text, never as a link"
  "AndroidIntent@@AndroidIntent@@an ACTION_VIEW fetches under the browser's permission"
  "ACTION_VIEW@@ACTION_VIEW@@an ACTION_VIEW fetches under the browser's permission"
)

hits=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  for rule in "${RULES[@]}"; do
    label="${rule%%@@*}"; rest="${rule#*@@}"
    regex="${rest%%@@*}"; reason="${rest#*@@}"
    # sed only blanks the comment TAIL, so line numbering survives 1:1 and grep -n reports the
    # real line. Anchors in the regex therefore still mean start-of-line.
    while IFS= read -r m; do
      [ -z "$m" ] && continue
      n="${m%%:*}"
      # The escape hatch is read from the ORIGINAL line, not the comment-stripped view.
      orig="$(sed -n "${n}p" "$f")"
      case "$orig" in *no-network-ok*) continue ;; esac
      hits="${hits}::error file=${f},line=${n}::${label} — ${reason}
"
    done <<EOF
$(sed -E 's,//.*,,' "$f" | grep -nE "$regex" || true)
EOF
  done
done <<EOF
$FILES
EOF

if [ -n "$hits" ]; then
  echo "no_banned_apis: SPEC.md §14 banned API in $TARGET" >&2
  printf '%s' "$hits" >&2
  exit 1
fi

echo "no_banned_apis: OK ($TARGET, $(echo "$FILES" | wc -l | tr -d ' ') files)"
