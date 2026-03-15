#!/usr/bin/env bash
# check_reviews.sh — daily cron script that flags decisions whose review date has arrived.
# Safe to run multiple times (idempotent per row).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSV="$SCRIPT_DIR/decisions.csv"

if [[ ! -f "$CSV" ]]; then
  echo "decisions.csv not found at $CSV" >&2
  exit 1
fi

TODAY="$(date +%F)"

FLAGGED="$(python3 - "$CSV" "$TODAY" <<'PYEOF'
import csv, sys, io, datetime

csv_path = sys.argv[1]
today    = sys.argv[2]

rows    = []
flagged = 0

with open(csv_path, newline="", encoding="utf-8") as fh:
    reader = csv.DictReader(fh)
    fieldnames = reader.fieldnames
    for row in reader:
        if row["status"] == "pending" and row["review_date"] <= today:
            row["status"] = "REVIEW_DUE"
            flagged += 1
        rows.append(row)

with open(csv_path, "w", newline="", encoding="utf-8") as fh:
    writer = csv.DictWriter(fh, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
    writer.writeheader()
    writer.writerows(rows)

print(flagged)
PYEOF
)"

if [[ "$FLAGGED" -gt 0 ]]; then
  echo "$(date +%F) check_reviews: flagged $FLAGGED decision(s) as REVIEW_DUE."
else
  echo "$(date +%F) check_reviews: no decisions due today."
fi
