#!/usr/bin/env bash
set -euo pipefail
# check_app_invariants.sh — proves the five CatchLaw product invariants hold across the whole repo.
# Usage: scripts/check_app_invariants.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# Every invariant here fails silently: a networking import compiles, an imperative verdict renders,
# a nullable citation type-checks, a colour-only state passes every widget test, and an expired pack
# that returns early looks like careful error handling. None of them are caught by the analyzer.
# Heuristic greps, not a compiler — passing is a floor, not proof. This script does NOT verify
# wording nuance, contrast ratios or golden coverage; those belong to the owning skills and to CI.
# Escape hatch: a trailing `// catchlaw-invariant-ok` on a Dart line that is provably fine. ARB
# values and pubspec dependencies are NEVER exempt, and nothing else is exempt.
#
# Checks:
#   1. Invariant 1 — networking, connectivity, telemetry or auth symbols in Dart
#   2. Invariant 1 — the same families declared as dependencies in any pubspec.yaml
#   3. Invariant 2 — imperative verdict strings in Dart and in every ARB locale
#   4. Invariant 3 — a nullable Citation, or a verdict surface with no citation
#   5. Invariant 4 — a verdict/status mapped to a Color in a file with no glyph
#   6. Invariant 5 — expiry that returns early, blocks, disables or errors
#   7. Layer map — package:flutter or package:drift imported inside rule_engine
#   8. Startup — an awaiting main() ahead of runApp
#   9. Delegated gates — every sibling skill's check_*.sh, if installed
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "check_app_invariants: target dir '$TARGET' not found" >&2
  exit 2
fi
ROOT="$(cd "$(dirname "$TARGET")" && pwd)"
GEN_RE='\.g\.dart$|\.freezed\.dart$|\.drift\.dart$|\.gr\.dart$|app_localizations'
OK_RE='catchlaw-invariant-ok'
fail=0
report() {
  local label="$1" hits="$2"
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}
echo "== check_app_invariants @ $TARGET =="

# 1. Invariant 1 — there is no network code path, and no identity to report.
report "networking symbol in Dart (offline app: read an asset or a local table)" \
  "$(grep -rnE "package:(http|dio|chopper|retrofit|grpc|web_socket_channel|connectivity_plus|internet_connection_checker|firebase[a-z_]*|sentry[a-z_]*|amplitude[a-z_]*|posthog[a-z_]*)/|\b(HttpClient|WebSocket\.connect|Socket\.connect|RawDatagramSocket|NetworkAssetBundle|InternetAddress\.lookup)\b|Image\.network|Uri\.https?\(" \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"
report "account, sync or telemetry symbol in Dart (no login, no id, no upload)" \
  "$(grep -rnE '\b(signIn|signOut|signUp|logIn|authToken|accessToken|refreshToken|deviceId|installId|anonymousId|remoteConfig|logEvent|trackEvent|captureException|uploadCrash|syncNow|pushToken)\b' \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"

# 2. Invariant 1 — a dependency that can open a socket is a code path, declared or not.
pubspecs="$(find "$ROOT" -maxdepth 3 -name pubspec.yaml -not -path '*/.dart_tool/*' 2>/dev/null || true)"
if [ -n "$pubspecs" ]; then
  report "networking or telemetry dependency in pubspec.yaml (nothing may reach a socket)" \
    "$(echo "$pubspecs" | tr '\n' '\0' | xargs -0 grep -nE '^\s{2}(http|dio|chopper|retrofit|grpc|web_socket_channel|connectivity_plus|internet_connection_checker|firebase_[a-z_]+|sentry_flutter|amplitude_flutter|posthog_flutter|google_sign_in|sign_in_with_apple|supabase_flutter):' 2>/dev/null || true)"
else
  echo "· no pubspec.yaml found under $ROOT — dependency check skipped"
fi

# 3. Invariant 2 — a verdict states a fact. ARB values can never be exempted.
report "imperative verdict string in Dart (state the measurement and the shortfall)" \
  "$(grep -rniE "['\"](Keep|Return|Release|Discard|Throw|Toss|Retain|Land it|Put it back|Do not keep)\b|(throw it back|put it back|keep it|return it|release it|safe to keep)" \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"
report "imperative verdict string in ARB (every locale, incl. app_ar.arb and app_ca.arb)" \
  "$(grep -rniE '": *"(Keep|Return|Release|Discard|Throw|Toss|Retain)\b|"[^"]*(throw it back|put it back|keep it|return it|release it|safe to keep)[^"]*"' \
      --include='*.arb' "$TARGET" || true)"

# 4. Invariant 3 — Citation is required and non-nullable, and every verdict surface takes one.
report "nullable Citation (make it required and non-null; an uncited verdict is an opinion)" \
  "$(grep -rnE '\bCitation\?|citation: *null|Citation\? +[a-z]' \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"
uncited=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  grep -qiE 'citation' "$f" || uncited="${uncited}${f}: declares a verdict type or surface with no citation"$'\n'
done <<EOF
$(grep -rlE 'class [A-Za-z0-9_]*Verdict[A-Za-z0-9_]*\b|sealed class Verdict\b' \
    --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)
EOF
report "verdict without a citation (invariant 3)" "${uncited%$'\n'}"

# 5. Invariant 4 — colour is never the only signal.
colouronly=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if grep -qE '\bColor\b|Colors\.' "$f" && ! grep -qE 'IconData|Icons\.|semanticLabel|Text\(' "$f"; then
    colouronly="${colouronly}${f}: status mapped to colour with no glyph or word in the file"$'\n'
  fi
done <<EOF
$(grep -rlE 'VerdictCategory|VerdictStatus|verdictColor|statusColor|categoryColor' \
    --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)
EOF
report "colour-only status encoding (glyph + word + colour, always)" "${colouronly%$'\n'}"

# 6. Invariant 5 — a stale pack is evaluated and shown; it never gates anything.
report "expiry used as a gate (evaluate anyway and add the ochre StaleRuleBar)" \
  "$(grep -rnE 'if *\([^)]*(isExpired|isStale|expired|validUntil)[^)]*\) *\{? *(return|throw)|(isExpired|isStale|expired)[^;]*\? *(const )?[A-Za-z0-9_]*(Error|Expired|Unavailable|Empty)[A-Za-z0-9_]*\(|enabled: *![^;]*(isExpired|isStale)|onPressed: *[^;]*(isExpired|isStale)[^;]*\? *null' \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"

# 7. Layer map — the engine is pure Dart, shared with the content_builder CLI.
engine_dirs="$(find "$ROOT" -maxdepth 4 -type d -name 'rule_engine' -not -path '*/.dart_tool/*' 2>/dev/null || true)"
if [ -n "$engine_dirs" ]; then
  hits=""
  while IFS= read -r d; do
    [ -z "$d" ] && continue
    found="$(grep -rnE "^import 'package:(flutter|drift|flutter_riverpod|path_provider)/" \
        --include='*.dart' "$d" | grep -vE "$GEN_RE" || true)"
    if [ -n "$found" ]; then hits="${hits}${found}"$'\n'; fi
  done <<EOF
$engine_dirs
EOF
  report "Flutter or drift import inside rule_engine (it must stay pure Dart)" "${hits%$'\n'}"
else
  echo "· no rule_engine package found under $ROOT — layer check skipped"
fi

# 8. Startup — the first frame is never behind an await.
report "awaiting main() (open both databases lazily; runApp first)" \
  "$(grep -rnE '(void|Future<void>) +main\(\) +async' \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"

# 9. Delegated gates — run every sibling skill's checker that happens to be installed.
SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd || true)"
ran=0
if [ -n "${SKILLS_ROOT:-}" ] && [ -d "$SKILLS_ROOT" ]; then
  for s in "$SKILLS_ROOT"/*/scripts/check_*.sh; do
    [ -f "$s" ] || continue
    case "$s" in *check_app_invariants.sh) continue ;; esac
    ran=$((ran + 1))
    echo "-- delegating to $(basename "$(dirname "$(dirname "$s")")")/$(basename "$s")"
    if ! bash "$s" "$TARGET"; then fail=1; fi
  done
fi
if [ "$ran" -eq 0 ]; then echo "· no sibling skill gates installed — delegation skipped"; fi

echo
if [ "$fail" -ne 0 ]; then
  echo "check_app_invariants: FAIL — review the hits above." >&2; exit 1
fi
echo "check_app_invariants: OK ($TARGET)"
