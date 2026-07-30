#!/usr/bin/env bash
set -euo pipefail
# check_verdict_contract.sh — proves the app states facts it can cite, and never counsels.
# Usage: scripts/check_verdict_contract.sh [TARGET_DIR]   (TARGET_DIR defaults to lib/)
#
# Every violation here is silent: an imperative, a second-person permission verb, an uncited
# finding or an edibility claim all compile, all pass the analyzer, all render beautifully, and
# each one turns a reference tool into a liable advisory product. Heuristic greps, not a compiler —
# passing is a floor, not proof. Escape hatch: a trailing `// verdict-contract-ok` on a Dart line
# that is provably not user-facing verdict copy. No ARB value is ever exempt; nothing else is.
#
# Checks:
#   1. Catch-handling imperative in a Dart string literal (keep / return / throw it back / land it)
#   2. Imperative or permission verb in an ARB verdict*/finding* value, every locale, plus a
#      separate Arabic pass (احتفظ / أعِدْه / يمكنك) no English-language pattern can see
#   3. Second person in a verdict string, in Dart or in ARB
#   4. A Verdict/Finding surface declared in a file that never mentions a citation
#   5. Edibility, toxin or health vocabulary anywhere in Dart or ARB
#   6. Inference hedges, softened-absence wording, and ARB verdict keys whose @description
#      does not carry the STATEMENT OF FACT constraint
# Generated files (*.g.dart / *.freezed.dart / *.drift.dart) are skipped.
# Hardcodes no app-specific paths. Exits non-zero on any violation.

TARGET="${1:-lib}"
if [ ! -d "$TARGET" ]; then echo "check_verdict_contract: target dir '$TARGET' not found" >&2; exit 2; fi
GEN_RE='\.(g|freezed|drift|gr)\.dart(:|$)|app_localizations' # matches `f.g.dart` and `f.g.dart:9:`
OK_RE='verdict-contract-ok'
fail=0
report() { local label="$1" hits="$2"; if [ -n "$hits" ]; then echo "✗ $label"; echo "$hits" | sed 's/^/    /'; fail=1; fi; }
echo "== check_verdict_contract @ $TARGET =="

# 1. An imperative opening a Dart literal, or a banned catch-handling phrase inside one.
report "imperative opening a Dart string (state the fact and the margin instead)" \
  "$(grep -rnE "['\"](Keep|Return|Release|Discard|Throw|Toss|Retain|Land it|Put it back)\b" \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"
report "banned catch-handling phrase in Dart (rule 1)" \
  "$(grep -rniE '(throw it back|put it back|keep it|return it|release it|toss it back|land it|do not keep)' \
      --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"

# 2. The same lexicon plus permission verbs in every ARB locale. Never exemptible.
report "imperative or permission verb in an ARB verdict value (rules 1, 2)" \
  "$(grep -rniE '"(verdict|finding)[A-Za-z0-9_]*" *: *"[^"]*(throw it back|put it back|keep it|return it|release it|land it|allowed to|permitted to|it is legal to)' \
      --include='*.arb' "$TARGET" || true)"
report "imperative opening an ARB verdict value (rule 1)" \
  "$(grep -rnE '"(verdict|finding)[A-Za-z0-9_]*" *: *"(Keep|Return|Release|Discard|Throw|Toss|Retain)\b' \
      --include='*.arb' "$TARGET" || true)"
# The Arabic imperative is one short fluent word; no English-language pattern above will see it.
report "Arabic imperative or second person in an ARB value (rule 2 — app_ar.arb)" \
  "$(grep -rnE 'احتفظ|أعِدْه|أعده|ارمه|أطلقه|لا تحتفظ|لا تصطد|يمكنك|بإمكانك' \
      --include='*.arb' "$TARGET" || true)"

# 3. Second person, scoped to verdict-carrying FILES so ordinary chrome copy is not swept up.
secondperson=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  hits="$(grep -niE "['\"][^'\"]*\b(you|your|yours)\b" "$f" | grep -v "$OK_RE" || true)"
  [ -n "$hits" ] && secondperson="${secondperson}$(echo "$hits" | sed "s|^|${f}:|")"$'\n'
done <<EOF
$(grep -rliE 'verdict|finding|minimum cm|measured|closed season|protected species' \
    --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)
EOF
report "second person in a verdict-carrying Dart file (rule 2)" "${secondperson%$'\n'}"
report "second person in an ARB verdict value (rule 2)" \
  "$(grep -rniE '"(verdict|finding)[A-Za-z0-9_]*" *: *"[^"]*\b(you|your|yours)\b' \
      --include='*.arb' "$TARGET" || true)"

# 4. A finding surface that never mentions a citation is a finding shipped as an opinion.
uncited=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if ! grep -qi 'citation' "$f"; then
    uncited="${uncited}${f}: declares a verdict/finding surface with no citation"$'\n'
  fi
done <<EOF
$(grep -rlE 'class [A-Za-z0-9]*(Verdict|Finding)[A-Za-z0-9]*(Panel|Screen|Page|Surface|Sheet|View|Body|Statement)?\b' \
    --include='*.dart' "$TARGET" | grep -vE "$GEN_RE" || true)
EOF
report "finding without a citation (Citation must be required and non-null — rule 5)" "${uncited%$'\n'}"

# 5. Health, edibility and toxin vocabulary. A different regulated domain; never exemptible.
report "edibility/health/toxin claim (rule 9 — voids the carve-out outright)" \
  "$(grep -rniE '(safe to eat|not safe to eat|edible|inedible|poisonous|venomous|ciguatera|scombroid|histamine|allergen|do not consume|mercury level)' \
      --include='*.dart' --include='*.arb' "$TARGET" | grep -vE "$GEN_RE" || true)"

# 6a. Inference hedges and softened absence: the app never reasons, and silence is not permission.
report "inference hedge or softened absence in user copy (rules 7, 8)" \
  "$(grep -rniE "['\"][^'\"]*(probably|most likely|appears to be|seems to be|counts as|close enough|no restrictions|nothing applies|all clear|good to go)" \
      --include='*.dart' --include='*.arb' "$TARGET" | grep -vE "$GEN_RE" | grep -v "$OK_RE" || true)"

# 6b. An ARB holding verdict keys must state the constraint to its translators at least once.
unconstrained=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if ! grep -q 'STATEMENT OF FACT' "$f"; then
    unconstrained="${unconstrained}${f}: verdict keys with no STATEMENT OF FACT @description"$'\n'
  fi
done <<EOF
$(grep -rlE '"(verdict|finding)[A-Za-z0-9_]*" *:' --include='*.arb' "$TARGET" || true)
EOF
report "ARB verdict keys with no constraint in @description (rule 12)" "${unconstrained%$'\n'}"

echo
if [ "$fail" -ne 0 ]; then echo "check_verdict_contract: FAIL — review the hits above." >&2; exit 1; fi
echo "check_verdict_contract: OK ($TARGET)"
