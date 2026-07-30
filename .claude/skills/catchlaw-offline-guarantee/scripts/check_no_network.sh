#!/usr/bin/env bash
set -euo pipefail
# check_no_network.sh — proves no code path in this app can reach a socket.
# Usage: scripts/check_no_network.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# "100% offline" is a store claim and a regulatory statement, and it dies silently: a dependency
# added for one screen, a PdfGoogleFonts call in an export, an INTERNET permission merged back in
# by a plugin. None of these fail at runtime — on Android they fail as a blank plate at 05:40 with
# no signal, and on iOS they do not fail at all, they just send. Heuristic greps, not a compiler:
# the real guarantees are the absent dependency (layer 1) and the absent permission (layer 2).
# Escape hatch: a trailing `// no-network-ok` on a Dart line that is a provable false positive
# (an identifier such as socketPathLabel). pubspec.yaml and AndroidManifest.xml are NEVER exempt.
#
# Checks:
#   1. Banned networking package declared in pubspec.yaml (layer 1)
#   2. depend_on_referenced_packages not promoted to error in analysis_options.yaml (layer 1)
#   3. android.permission.INTERNET granted in a shipping AndroidManifest (layer 2)
#   4. Networking half of dart:io used under TARGET — File/Directory/Platform stay legal (layer 4)
#   5. Fetching APIs under TARGET — Image.network, NetworkImage, PdfGoogleFonts, launchUrl (layer 4)
#   6. Banned package imported under TARGET (layer 4)
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then echo "check_no_network: target dir '$TARGET' not found" >&2; exit 2; fi
ROOT="$(cd "$TARGET/.." && pwd)"
GEN_RE='\.g\.dart$|\.freezed\.dart$|\.drift\.dart$|\.gr\.dart$'
OK_RE='no-network-ok'
BANNED_PKGS='http|dio|chopper|web_socket_channel|grpc|connectivity_plus|internet_connection_checker|url_launcher|webview_flutter|flutter_inappwebview|google_fonts|cached_network_image|firebase_core|firebase_[a-z_]+|googleapis|googleapis_auth|supabase_flutter|sentry_flutter|posthog_flutter|amplitude_flutter'
fail=0
report() { local label="$1" hits="$2"; if [ -n "$hits" ]; then echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1; fi; }
echo "== check_no_network @ $TARGET =="

# 1. Layer 1. A declared dependency turns every import below into legal code.
if [ -f "$ROOT/pubspec.yaml" ]; then
  report "banned networking package in pubspec.yaml (layer 1 — remove the dependency)" \
    "$(grep -nE "^ +($BANNED_PKGS): " "$ROOT/pubspec.yaml" | grep -v '^ *#' || true)"
else
  echo "  note: no pubspec.yaml beside '$TARGET' — skipping layer 1 dependency check"
fi

# 2. Layer 1. Without the promotion, a transitive http (via printing) imports cleanly from lib/.
if [ -f "$ROOT/analysis_options.yaml" ]; then
  if ! grep -qE 'depend_on_referenced_packages: *error' "$ROOT/analysis_options.yaml"; then
    report "depend_on_referenced_packages is not error (add it under analyzer: errors:)" \
      "$ROOT/analysis_options.yaml: a transitive http edge is importable from $TARGET"
  fi
fi

# 3. Layer 2. debug/ and profile/ legitimately grant INTERNET for the Dart VM service.
if [ -d "$ROOT/android/app/src" ]; then
  report "INTERNET granted in a shipping AndroidManifest (add tools:node=\"remove\")" \
    "$(grep -rn 'android.permission.INTERNET' --include='AndroidManifest.xml' "$ROOT/android/app/src" \
        | grep -vE '/(debug|profile)/' | grep -v 'tools:node="remove"' | grep -vE ':[0-9]+: *<!--' || true)"
  noxmlns=""
  while IFS= read -r m; do
    [ -z "$m" ] && continue
    grep -q 'xmlns:tools' "$m" || noxmlns="${noxmlns}${m}: uses tools: markers with no xmlns:tools"$'\n'
  done <<EOF
$(grep -rl 'tools:node="remove"' --include='AndroidManifest.xml' "$ROOT/android/app/src" || true)
EOF
  report "tools:node=\"remove\" without xmlns:tools on the manifest element (the merge will fail)" \
    "${noxmlns%$'\n'}"
fi

# 4. Layer 4. dart:io is banned by SYMBOL: File, Directory and Platform are needed by drift.
report "networking dart:io symbol (File/Directory/Platform stay legal; sockets do not)" \
  "$(grep -rnE '\b(HttpClient|HttpClientRequest|HttpServer|HttpOverrides|SecurityContext|RawDatagramSocket|WebSocket|WebSocketTransformer|InternetAddress|NetworkInterface)\b|\b(Raw|Secure|Server)?Socket\b' \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"

# 5. Layer 4. Every one of these has an assets/ replacement; the transitive http edge stays dead.
report "fetching API (use assets/: AssetImage, SvgPicture.asset, pw.Font.ttf, printed citation)" \
  "$(grep -rnE '\bImage\.network\b|\b(Cached)?NetworkImage\b|\bNetworkAssetBundle\b|\bFadeInImage\.assetNetwork\b|\bSvgPicture\.network\b|\bPdfGoogleFonts\b|\b(canL|l)aunchUrl(String)?\b|\bConnectivityResult\b|\bConnectivity\(\)' \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"

# 6. Layer 4. Catches a transitive import even before pubspec.yaml is touched.
report "banned package imported (layer 1 should have made this a compile error)" \
  "$(grep -rnE "import +['\"]package:($BANNED_PKGS)/" --include='*.dart' "$TARGET" \
      | grep -vE "$GEN_RE" || true)"

echo
if [ "$fail" -ne 0 ]; then echo "check_no_network: FAIL — review the hits above." >&2; exit 1; fi
echo "check_no_network: OK ($TARGET)"
