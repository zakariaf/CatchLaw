#!/usr/bin/env bash
set -euo pipefail
# check_reference_db.sh — proves the two databases keep their lifecycles apart: nothing is awaited inside main(), the reference DB is opened read-only and never migrated, and every extraction lands via an atomic rename.
# Usage: scripts/check_reference_db.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# The silent failures this catches: an awaited open inside main(), which costs ~700 ms of black
# screen on a five-year-old Android and never shows up in a widget test; a reference DB opened
# writable, which lets Drift drop a -wal beside a shipped asset so every later sha256 check is a
# false alarm; a MigrationStrategy registered against content that is replaced wholesale; and an
# extraction that writes straight onto the live path, where a kill at 80% leaves a truncated file
# that opens cleanly and answers with wrong minimum lengths. Heuristic greps and awk windows, not a
# compiler — indirection through a helper, dynamic paths and constructors wrapped past the scan
# window all defeat it, so passing is a floor and not proof. The ONE escape hatch is a trailing line
# comment // catchlaw-db-ok on the offending line (a test harness opening an in-memory copy is the
# only intended use). Nothing else is exempt.
#
# Checks:
#   1. await on a database open, executor or installer inside the braces of main()
#   2. NativeDatabase in reference context with no readOnly: true within the call
#   3. MigrationStrategy / onCreate / onUpgrade / createAll on the reference database that does not throw
#   4. a file that decompresses and writes the payload but never calls File.rename
#   5. ATTACH DATABASE, which re-couples the two lifecycles
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then
  echo "check_reference_db: target dir '$TARGET' not found" >&2
  exit 2
fi
# Matches both `grep -l` output (bare path) and `grep -n` output (path:line:...).
GEN_RE='\.(g|freezed|drift|gr)\.dart(:|$)'
# POSIX ERE, passed to awk with -v: no \w (BSD grep and one-true-awk ignore it) and no backslash
# escapes at all, because awk -v expands them before the regex is compiled. [(] does the job.
OPEN_RE='NativeDatabase|LazyDatabase|QueryExecutor|open[A-Za-z_]*(Connection|Database)|ensureInstalled|ensureOpen|Installer[(]|Database[(]'
fail=0
report() {
  local label="$1" hits="$2"
  if [ -n "$hits" ]; then
    echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1
  fi
}
collect() { # collect <file-list> <awk-program>  -> newline-joined hits
  local files="$1" prog="$2" out="" hits=""
  [ -n "$files" ] || return 0
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    hits="$(awk -v path="$f" -v openre="$OPEN_RE" "$prog" "$f" || true)"
    if [ -n "$hits" ]; then
      [ -z "$out" ] || out="${out}"$'\n'
      out="${out}${hits}"
    fi
  done <<COLLECT_EOF
$files
COLLECT_EOF
  printf '%s' "$out"
}
echo "== check_reference_db @ $TARGET =="

# 1. An awaited open on the startup path, scoped to the braces of main() so that a LazyDatabase
#    callback elsewhere in the same file is not a false hit.
main_files="$(grep -rlE '^[[:space:]]*(Future<void>|void)[[:space:]]+main[[:space:]]*\(' \
  --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)"
report "awaited database open inside main() (rule 2 — defer it into LazyDatabase)" \
  "$(collect "$main_files" '
    { l = $0
      if (!inmain && l ~ /^[ \t]*(Future<void>|void)[ \t]+main[ \t]*\(/) { inmain = 1; depth = 0; seen = 0 }
      if (inmain) {
        if (l ~ /(^|[^A-Za-z_])await[ \t]/ && l ~ openre && l !~ /catchlaw-db-ok/)
          printf "%s:%d:%s\n", path, NR, l
        o = gsub(/\{/, "{", l); c = gsub(/\}/, "}", l)
        depth += o - c
        if (o > 0) seen = 1
        if (seen && depth <= 0) inmain = 0
      } }')"

# 2. The reference DB opened writable. The 8-lines-back context establishes that the call is the
#    reference one; the call itself plus 2 lines is where readOnly must appear.
native_files="$(grep -rlE 'NativeDatabase(\.createInBackground)?\(' --include='*.dart' "$TARGET" \
  | grep -vE "$GEN_RE" || true)"
report "reference DB opened writable (rule 3 — pass readOnly: true)" \
  "$(collect "$native_files" '
    { L[NR] = $0 }
    END { for (i = 1; i <= NR; i++) {
            if (L[i] !~ /NativeDatabase(\.createInBackground)?\(/) continue
            ctx = ""; call = ""
            for (j = (i - 8 < 1 ? 1 : i - 8); j <= i + 2 && j <= NR; j++) ctx = ctx " " L[j]
            for (j = i; j <= i + 2 && j <= NR; j++) call = call " " L[j]
            if (ctx ~ /catchlaw-db-ok/) continue
            if (tolower(ctx) !~ /reference/) continue
            if (call ~ /readOnly/) continue
            printf "%s:%d:%s\n", path, i, L[i] } }')"

# 3. A migration registered against content that is replaced wholesale. Callbacks that THROW are
#    the required shape and are not hits.
ref_files="$(grep -rlE 'class[[:space:]]+[A-Za-z_]*Reference[A-Za-z_]*Database' --include='*.dart' \
  "$TARGET" | grep -vE "$GEN_RE" || true)"
report "migration registered against reference.db (rule 4 — content is replaced, never migrated)" \
  "$(collect "$ref_files" '
    { L[NR] = $0 }
    END { for (i = 1; i <= NR; i++) {
            if (L[i] !~ /(MigrationStrategy\(|onUpgrade:|onCreate:|createAll|customStatement\()/) continue
            w = ""
            for (j = i; j <= i + 5 && j <= NR; j++) w = w " " L[j]
            if (w ~ /catchlaw-db-ok/) continue
            if (w ~ /(throw|StateError|UnsupportedError)/) continue
            printf "%s:%d:%s\n", path, i, L[i] } }')"

# 4. Extraction with no atomic rename anywhere in the file.
extract_files="$(grep -rlE '(gzip\.(decode|decoder)|GZipCodec|ZLibDecoder|rootBundle\.load\()' \
  --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)"
norename=""
if [ -n "$extract_files" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    grep -q 'catchlaw-db-ok' "$f" && continue
    grep -qE '(writeAsBytes|openWrite|writeAsString)' "$f" || continue
    if ! grep -qE '\.rename\(' "$f"; then
      [ -z "$norename" ] || norename="${norename}"$'\n'
      norename="${norename}${f}: decompresses and writes a payload but never calls File.rename"
    fi
  done <<EXT_EOF
$extract_files
EXT_EOF
fi
report "extraction with no atomic rename (rule 6 — write .tmp, verify, then rename)" "$norename"

# 5. Cross-database coupling.
report "ATTACH DATABASE (rule 11 — the rule engine takes plain Dart values)" \
  "$(grep -rniE 'attach[[:space:]]+database' --include='*.dart' "$TARGET" \
     | grep -vE "$GEN_RE" | grep -v 'catchlaw-db-ok' || true)"

echo
if [ "$fail" -ne 0 ]; then
  echo "check_reference_db: FAIL — review the hits above." >&2; exit 1
fi
echo "check_reference_db: OK ($TARGET)"
