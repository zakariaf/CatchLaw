#!/usr/bin/env bash
set -uo pipefail
# run_skill_gates.sh — run every skill gate in the table, and refuse to trust one
# that scanned nothing.
# Usage: tools/gates/run_skill_gates.sh [TABLE]   (default tools/gates/skill_gates.tsv)
#
# FOR THE STRANGER AT 2AM, which is the only reader worth writing for:
# every check_*.sh exits 2 when its target directory is MISSING — that part is
# already right. A directory that EXISTS and holds nothing takes a different path:
# each check is a `grep -r ... || true`, an empty hit set is not a violation, and
# the script prints "check_x: OK (app/lib)" and exits 0. A green tick meaning
# "I found nothing" and a green tick meaning "I looked at nothing" are the same
# pixel, and this repository's offline claim is read off those greens.
#
# So this runner COUNTS BEFORE IT RUNS. Every row declares the glob its gate
# actually reads; a row whose target holds fewer than min_files matching files is
# not run at all and is reported as an EMPTY SCAN. The count is printed for every
# row, passing or failing, because the number is the evidence: "check_x: OK" is a
# claim, "check_x: OK — 47 files scanned" is a check.
#
# It runs ALL rows before failing (policy-grep-gate.md: accumulate, fail once).
# Stopping at the first red hides fifteen results and teaches one fix per push.
#
# Lines a gate prints containing "skip" are collected as NOTES, not failures.
# Some skips are correct at E01 — no ARB files until E06, no /theme/ until E07 —
# and a note makes "which checks did not actually run?" answerable from the job
# log instead of from four hundred lines of bash.
#
# This runner never edits a gate. Editing a skill is E01/T09's licence.

TABLE="${1:-tools/gates/skill_gates.tsv}"
if [ ! -f "$TABLE" ]; then
  echo "run_skill_gates: table '$TABLE' not found" >&2; exit 2
fi

fail=0
summary=""
notes=""

# `|| [ -n "$raw" ]` so a table whose final line carries no trailing newline does
# not lose its last row. Without it the sixteenth gate is silently never run —
# which is this runner's own failure mode, arriving through its own front door.
while IFS= read -r raw || [ -n "$raw" ]; do
  line="${raw%%#*}"
  line="$(printf '%s' "$line" | sed -e 's/[[:space:]]*$//')"
  [ -z "$line" ] && continue

  script="$(printf '%s' "$line" | cut -f1)"
  target="$(printf '%s' "$line" | cut -f2)"
  glob="$(printf '%s' "$line" | cut -f3)"
  minf="$(printf '%s' "$line" | cut -f4)"
  name="$(basename "$script")"

  if [ ! -f "$script" ]; then
    echo "✗ $name — script not found at $script"
    summary="${summary}  MISSING SCRIPT  ${name}  ${script}"$'\n'
    fail=1
    continue
  fi

  if [ ! -d "$target" ]; then
    # D-1's consequence, named row and named path — not a bare relayed exit 2.
    echo "✗ $name — target directory does not exist: $target"
    summary="${summary}  MISSING TARGET  ${name}  ${target}"$'\n'
    fail=1
    continue
  fi

  # Build the find expression from the comma-separated glob column.
  findargs=()
  first=1
  IFS=',' read -ra pats <<< "$glob"
  for p in "${pats[@]}"; do
    if [ "$first" = 1 ]; then findargs+=( -name "$p" ); first=0
    else findargs+=( -o -name "$p" ); fi
  done
  count="$(find "$target" -type f \( "${findargs[@]}" \) 2>/dev/null | wc -l | tr -d ' ')"

  echo "— $name  ($target, glob $glob) — scanned $count files"

  if [ "$count" -lt "$minf" ]; then
    echo "  ✗ would have passed over an empty tree — see CONVENTIONS.md §7. Gate NOT run."
    summary="${summary}  EMPTY SCAN      ${name}  ${target}  ${count} files"$'\n'
    fail=1
    continue
  fi

  out="$(bash "$script" "$target" 2>&1)"; rc=$?
  printf '%s\n' "$out" | sed 's/^/  /'

  skipped="$(printf '%s\n' "$out" | grep -i 'skip' || true)"
  if [ -n "$skipped" ]; then
    notes="${notes}  ${name}:"$'\n'"$(printf '%s\n' "$skipped" | sed 's/^[[:space:]]*/    /')"$'\n'
  fi

  if [ "$rc" -ne 0 ]; then
    summary="${summary}  FAIL exit ${rc}   ${name}  ${target}  ${count} files"$'\n'
    fail=1
  else
    summary="${summary}  OK              ${name}  ${target}  ${count} files"$'\n'
  fi
done < "$TABLE"

echo
echo "=============================== skill gate summary ==============================="
printf '%s' "$summary"
if [ -n "$notes" ]; then
  echo
  echo "notes — checks that reported a SKIP. Not failures; some are correct before the"
  echo "epic that gives them a subject. An unexplained one is a defect in the table."
  printf '%s' "$notes"
fi
echo "================================================================================="

if [ "$fail" -ne 0 ]; then
  echo "run_skill_gates: FAIL — see the summary above." >&2
  exit 1
fi
echo "run_skill_gates: OK"
