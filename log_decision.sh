#!/usr/bin/env bash
# log_decision.sh — interactively log a decision to decisions.csv
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSV="$SCRIPT_DIR/decisions.csv"

# Ensure CSV exists with header
if [[ ! -f "$CSV" ]]; then
  echo "date,decision,reasoning,expected_outcome,review_date,status" > "$CSV"
fi

# ── helpers ────────────────────────────────────────────────────────────────────
prompt() {
  local var_name="$1"
  local label="$2"
  local input
  while true; do
    read -r -p "$label: " input
    input="$(echo "$input" | xargs)"   # trim whitespace
    if [[ -n "$input" ]]; then
      printf -v "$var_name" '%s' "$input"
      return
    fi
    echo "  (cannot be empty, please try again)"
  done
}

# Escape a field for CSV: wrap in quotes, double any internal quotes
csv_field() {
  local val="$1"
  val="${val//\"/\"\"}"   # double every "
  echo "\"$val\""
}

# ── gather input ───────────────────────────────────────────────────────────────
echo ""
echo "=== Decision Logger ==="
echo ""

prompt DECISION      "Decision"
prompt REASONING     "Reasoning"
prompt EXPECTED      "Expected outcome"

TODAY="$(date +%F)"
REVIEW_DATE="$(date -d "+30 days" +%F 2>/dev/null || date -v +30d +%F)"  # GNU / BSD

# ── write row ──────────────────────────────────────────────────────────────────
ROW="$(csv_field "$TODAY"),$(csv_field "$DECISION"),$(csv_field "$REASONING"),$(csv_field "$EXPECTED"),$(csv_field "$REVIEW_DATE"),$(csv_field "pending")"
echo "$ROW" >> "$CSV"

echo ""
echo "Logged. Review due: $REVIEW_DATE"
echo "Saved to: $CSV"
